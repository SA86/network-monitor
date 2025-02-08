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
        memory_usage: 0,
        disk_usage: 0,
        network_speed: 0
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
        Layout.minimumHeight: 200
        
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
                
                PlasmaComponents.Label { text: "CPU Usage:" }
                PlasmaComponents.Label { text: root.systemStats.cpu_usage + "%" }
                
                PlasmaComponents.Label { text: "Memory Usage:" }
                PlasmaComponents.Label { text: root.systemStats.memory_usage + "%" }
                
                PlasmaComponents.Label { text: "Disk Usage:" }
                PlasmaComponents.Label { text: root.systemStats.disk_usage + "%" }
                
                PlasmaComponents.Label { text: "Network Speed:" }
                PlasmaComponents.Label { text: root.systemStats.network_speed + " MB/s" }
            }
            
            PlasmaComponents.TextField {
                id: serverAddress
                placeholderText: "Server Address (e.g., 192.168.1.100:8080)"
                Layout.fillWidth: true
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
        interval: 1000
        running: dataSource.connected
        repeat: true
        onTriggered: {
            dataSource.fetchStats()
        }
    }
} 