import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root
    
    property string serverUrl: ""
    property bool connected: false
    property var lastError: ""
    property bool hasGpu: false
    
    // New properties for GPU and CPU temperature monitoring
    property real cpuTemp: 0
    property real gpuTemp: 0
    property real gpuUtilization: 0
    property real gpuMemoryUtilization: 0
    
    signal statsUpdated(var stats)
    signal connectionError(string error)
    
    function connect(address) {
        if (!address) {
            root.connected = false
            root.lastError = "Invalid address"
            root.connectionError("Invalid address")
            return
        }
        
        serverUrl = address.startsWith("http") ? address : "http://" + address
        checkConnection()
    }
    
    function checkConnection() {
        var xhr = new XMLHttpRequest()
        xhr.timeout = 5000
        xhr.open("GET", serverUrl + "/health")
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    root.connected = true
                    root.lastError = ""
                    fetchStats()
                } else {
                    root.connected = false
                    root.lastError = "Connection failed"
                    root.connectionError("Failed to connect to server")
                }
            }
        }
        
        xhr.onerror = function() {
            root.connected = false
            root.lastError = "Connection error"
            root.connectionError("Network error")
        }
        
        xhr.send()
    }
    
    function fetchStats() {
        if (!root.connected || !serverUrl) return
        
        var xhr = new XMLHttpRequest()
        xhr.timeout = 5000
        xhr.open("GET", serverUrl + "/stats")
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var stats = JSON.parse(xhr.responseText)
                    
                    // Update GPU availability based on stats
                    root.hasGpu = stats.gpu_temp !== null || 
                                 stats.gpu_utilization !== null || 
                                 stats.gpu_memory_utilization !== null
                    
                    // Update temperature and GPU properties
                    root.cpuTemp = stats.cpu_temp !== null ? stats.cpu_temp : 0
                    root.gpuTemp = stats.gpu_temp !== null ? stats.gpu_temp : 0
                    root.gpuUtilization = stats.gpu_utilization !== null ? stats.gpu_utilization : 0
                    root.gpuMemoryUtilization = stats.gpu_memory_utilization !== null ? stats.gpu_memory_utilization : 0
                    
                    root.statsUpdated(stats)
                } else {
                    root.lastError = "Failed to fetch stats"
                    root.connectionError("Failed to fetch stats")
                }
            }
        }
        
        xhr.onerror = function() {
            root.lastError = "Network error"
            root.connectionError("Network error while fetching stats")
        }
        
        xhr.send()
    }
} 