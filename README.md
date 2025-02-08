# KDE Plasma Network Hardware Monitor

A KDE Plasma widget that allows you to monitor hardware statistics of Ubuntu machines over the local network.

## Features

- Real-time monitoring of:
  - CPU usage
  - Memory usage
  - Disk usage
  - Network speed
- Easy connection to remote machines
- Automatic data updates every second

## Installation

### Widget Installation

1. Create a new directory for the widget:

```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.networkhwmonitor
```

2. Copy all the widget files to the new directory:

```bash
cp -r * ~/.local/share/plasma/plasmoids/org.kde.plasma.networkhwmonitor/
```

3. Restart the Plasma shell:

```bash
plasmashell --replace &
```

### Server Installation

1. Navigate to the server directory:

```bash
cd server
```

2. Install the required Python packages:

```bash
pip install -r requirements.txt
```

3. Run the server:

```bash
python main.py
```

By default, the server runs on port 8082. You can change this by setting the PORT environment variable:

```bash
PORT=8081 python main.py
```

## Usage

1. Add the "Network Hardware Monitor" widget to your Plasma desktop/panel
2. Enter the address of your Ubuntu machine running the server (e.g., "192.168.1.100:8082")
3. Click "Connect" to start monitoring
4. The widget will automatically update with the latest statistics every second

## Security Considerations

- The server currently allows connections from any origin (CORS is set to "\*")
- For production use, you should:
  - Configure CORS to only allow specific origins
  - Add authentication
  - Use HTTPS
  - Configure firewall rules to restrict access

## License

GPL-2.0+
