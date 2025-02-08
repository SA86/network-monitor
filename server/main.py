from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import psutil
import uvicorn
from typing import Dict
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Hardware Monitor Server")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/stats")
async def get_stats() -> Dict:
    try:
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        
        # Disk usage
        disk = psutil.disk_usage('/')
        disk_percent = disk.percent
        
        # Network speed (bytes/sec)
        net_io = psutil.net_io_counters()
        network_speed = (net_io.bytes_sent + net_io.bytes_recv) / 1024 / 1024  # Convert to MB
        
        return {
            "cpu_usage": round(cpu_percent, 1),
            "memory_usage": round(memory_percent, 1),
            "disk_usage": round(disk_percent, 1),
            "network_speed": round(network_speed, 2)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8082))
    uvicorn.run(app, host="0.0.0.0", port=port) 