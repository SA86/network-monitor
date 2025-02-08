from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import psutil
import uvicorn
from typing import Dict
import os
from dotenv import load_dotenv
import pynvml
import logging

load_dotenv()

# Initialize NVIDIA Management Library
try:
    pynvml.nvmlInit()
    has_gpu = True
except Exception as e:
    logging.warning(f"GPU monitoring not available: {str(e)}")
    has_gpu = False

app = FastAPI(title="Hardware Monitor Server")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_cpu_temperature() -> float:
    try:
        # Try to get CPU temperature from psutil
        temps = psutil.sensors_temperatures()
        if not temps:
            return None
            
        # First try to get from coretemp
        if 'coretemp' in temps:
            return sum(temp.current for temp in temps['coretemp']) / len(temps['coretemp'])
        
        # If coretemp not available, try the first available sensor
        for sensor_name, entries in temps.items():
            if entries:
                return entries[0].current
                
        return None
    except Exception:
        return None

def get_gpu_stats() -> Dict:
    if not has_gpu:
        return {
            "gpu_temp": None,
            "gpu_utilization": None,
            "gpu_memory_utilization": None
        }
        
    try:
        handle = pynvml.nvmlDeviceGetHandleByIndex(0)  # Get the first GPU
        temp = pynvml.nvmlDeviceGetTemperature(handle, pynvml.NVML_TEMPERATURE_GPU)
        utilization = pynvml.nvmlDeviceGetUtilizationRates(handle)
        memory = pynvml.nvmlDeviceGetMemoryInfo(handle)
        
        return {
            "gpu_temp": temp,
            "gpu_utilization": utilization.gpu,
            "gpu_memory_utilization": (memory.used / memory.total) * 100
        }
    except Exception as e:
        logging.error(f"Error getting GPU stats: {str(e)}")
        return {
            "gpu_temp": None,
            "gpu_utilization": None,
            "gpu_memory_utilization": None
        }

@app.get("/stats")
async def get_stats() -> Dict:
    try:
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        cpu_temp = get_cpu_temperature()
        
        # Memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        
        # Disk usage
        disk = psutil.disk_usage('/')
        disk_percent = disk.percent
        
        # Network speed (bytes/sec)
        net_io = psutil.net_io_counters()
        network_speed = (net_io.bytes_sent + net_io.bytes_recv) / 1024 / 1024  # Convert to MB
        
        # Get GPU stats
        gpu_stats = get_gpu_stats()
        
        return {
            "cpu_usage": round(cpu_percent, 1),
            "cpu_temp": round(cpu_temp, 1) if cpu_temp is not None else None,
            "memory_usage": round(memory_percent, 1),
            "disk_usage": round(disk_percent, 1),
            "network_speed": round(network_speed, 2),
            "gpu_temp": round(gpu_stats["gpu_temp"], 1) if gpu_stats["gpu_temp"] is not None else None,
            "gpu_utilization": round(gpu_stats["gpu_utilization"], 1) if gpu_stats["gpu_utilization"] is not None else None,
            "gpu_memory_utilization": round(gpu_stats["gpu_memory_utilization"], 1) if gpu_stats["gpu_memory_utilization"] is not None else None
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8082))
    uvicorn.run(app, host="0.0.0.0", port=port) 