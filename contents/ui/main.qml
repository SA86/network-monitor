import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

Item {
    id: root
    
    property var systemStats: ({
        cpu_usage: 0,
        cpu_temp: 0,
        memory_usage: 0,
        disk_usage: 0,
        network_speed: 0,
        gpu_temp: 0,
        gpu_utilization: 0,
        gpu_memory_utilization: 0
    })
    
    DataSource {
        id: dataSource
        
        onStatsUpdated: function(stats) {
            root.systemStats = stats
        }
        
        onConnectionError: function(error) {
            connectionStatus.text = error
            connectionStatus.color = PlasmaCore.Theme.negativeTextColor
        }
    }
    
    Plasmoid.fullRepresentation: Item {
        Layout.minimumWidth: 300
        Layout.minimumHeight: 300
        
        ColumnLayout {
            anchors.fill: parent
            spacing: PlasmaCore.Units.smallSpacing
            
            PlasmaComponents.Label {
                text: "Hardware Monitor"
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            GridLayout {
                columns: 2
                rowSpacing: PlasmaCore.Units.smallSpacing
                columnSpacing: PlasmaCore.Units.largeSpacing
                Layout.margins: PlasmaCore.Units.smallSpacing
                
                // CPU Section
                PlasmaComponents.Label {
                    text: "CPU"
                    font.bold: true
                    Layout.columnSpan: 2
                    Layout.topMargin: PlasmaCore.Units.smallSpacing
                }
                
                PlasmaComponents.Label { text: "Usage:" }
                PlasmaComponents.Label { text: root.systemStats.cpu_usage + "%" }
                
                PlasmaComponents.Label { text: "Temperature:" }
                PlasmaComponents.Label { 
                    text: root.systemStats.cpu_temp !== null ? root.systemStats.cpu_temp + "°C" : "N/A"
                }
                
                // Memory Section
                PlasmaComponents.Label {
                    text: "Memory"
                    font.bold: true
                    Layout.columnSpan: 2
                    Layout.topMargin: PlasmaCore.Units.smallSpacing
                }
                
                PlasmaComponents.Label { text: "Usage:" }
                PlasmaComponents.Label { text: root.systemStats.memory_usage + "%" }
                
                // Storage & Network
                PlasmaComponents.Label {
                    text: "System"
                    font.bold: true
                    Layout.columnSpan: 2
                    Layout.topMargin: PlasmaCore.Units.smallSpacing
                }
                
                PlasmaComponents.Label { text: "Disk Usage:" }
                PlasmaComponents.Label { text: root.systemStats.disk_usage + "%" }
                
                PlasmaComponents.Label { text: "Network Speed:" }
                PlasmaComponents.Label { text: root.systemStats.network_speed + " MB/s" }
                
                // GPU Section (only shown if GPU is available)
                PlasmaComponents.Label {
                    text: "GPU"
                    font.bold: true
                    Layout.columnSpan: 2
                    Layout.topMargin: PlasmaCore.Units.smallSpacing
                    visible: dataSource.hasGpu
                }
                
                PlasmaComponents.Label { 
                    text: "Temperature:"
                    visible: dataSource.hasGpu
                }
                PlasmaComponents.Label { 
                    text: root.systemStats.gpu_temp !== null ? root.systemStats.gpu_temp + "°C" : "N/A"
                    visible: dataSource.hasGpu
                }
                
                PlasmaComponents.Label { 
                    text: "Utilization:"
                    visible: dataSource.hasGpu
                }
                PlasmaComponents.Label { 
                    text: root.systemStats.gpu_utilization !== null ? root.systemStats.gpu_utilization + "%" : "N/A"
                    visible: dataSource.hasGpu
                }
                
                PlasmaComponents.Label { 
                    text: "Memory Usage:"
                    visible: dataSource.hasGpu
                }
                PlasmaComponents.Label { 
                    text: root.systemStats.gpu_memory_utilization !== null ? root.systemStats.gpu_memory_utilization + "%" : "N/A"
                    visible: dataSource.hasGpu
                }
            }
            
            PlasmaComponents.TextField {
                id: serverAddress
                placeholderText: "Server Address (e.g., 192.168.1.100:8080)"
                Layout.fillWidth: true
                Layout.topMargin: PlasmaCore.Units.smallSpacing
            }
            
            PlasmaComponents.Label {
                id: connectionStatus
                text: dataSource.connected ? "Connected" : "Not Connected"
                color: dataSource.connected ? PlasmaCore.Theme.positiveTextColor : PlasmaCore.Theme.neutralTextColor
                Layout.alignment: Qt.AlignHCenter
            }
            
            PlasmaComponents.Button {
                text: dataSource.connected ? "Disconnect" : "Connect"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    if (!dataSource.connected) {
                        dataSource.connect(serverAddress.text)
                    } else {
                        dataSource.serverUrl = ""
                        dataSource.connected = false
                        connectionStatus.text = "Disconnected"
                        connectionStatus.color = PlasmaCore.Theme.neutralTextColor
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 3000  // Changed from 1000 to 3000 for 3-second polling
        running: dataSource.connected
        repeat: true
        onTriggered: {
            dataSource.fetchStats()
        }
    }
} 