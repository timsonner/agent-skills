---
name: mcp-server
description: Specification for building Model Context Protocol servers using Python
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: server-development
  language: python
---

# MCP Server Specification

Based on the Model Context Protocol documentation for building servers.

## Overview

MCP (Model Context Protocol) servers expose capabilities to LLM clients through three main types:

1. **Resources** - File-like data that can be read by clients
2. **Tools** - Functions that can be called by the LLM (with user approval)
3. **Prompts** - Pre-written templates that help users accomplish specific tasks

This specification focuses on building MCP servers using Python.

## Core Concepts

### Logging in MCP Servers

**Important**: For STDIO-based servers (most common), never write to stdout as it corrupts JSON-RPC messages.

```python
# ❌ Bad (STDIO)
print("Processing request")

# ✅ Good (STDIO)
print("Processing request", file=sys.stderr)

# ✅ Good (STDIO)
logging.info("Processing request")
```

## Python Implementation

### Prerequisites

- Python 3.10 or higher
- MCP SDK 1.2.0 or higher
- `uv` package manager recommended

### Project Setup

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create project
uv init mcp-server
cd mcp-server

# Create virtual environment
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
uv add "mcp[cli]" httpx

# Create server file
touch server.py
```

### Server Implementation

#### Basic Structure

```python
from typing import Any
import httpx
import logging
import sys
from mcp.server.fastmcp import FastMCP

# Initialize FastMCP server
mcp = FastMCP("server-name")

# Constants (example for weather API)
API_BASE = "https://api.example.com"
USER_AGENT = "mcp-server/1.0"

# Setup logging (write to stderr for STDIO servers)
logging.basicConfig(level=logging.INFO, stream=sys.stderr)
logger = logging.getLogger(__name__)
```

#### Helper Functions

```python
async def make_api_request(url: str) -> dict[str, Any] | None:
    """Make an API request with proper error handling."""
    headers = {
        "User-Agent": USER_AGENT,
        "Accept": "application/json"
    }
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=headers, timeout=30.0)
            response.raise_for_status()
            return response.json()
    except Exception as e:
        logger.error(f"Error making API request to {url}: {e}")
        return None
```

#### Tool Implementation

```python
@mcp.tool()
async def example_tool(param: str) -> str:
    """Example tool description.
    
    Args:
        param: Description of the parameter
    """
    url = f"{API_BASE}/endpoint/{param}"
    data = await make_api_request(url)
    
    if not data:
        return "Unable to fetch data."
    
    # Process and format the data as needed
    return f"Processed result: {data}"
```

#### Running the Server

```python
def main():
    """Initialize and run the server."""
    mcp.run(transport="stdio")

if __name__ == "__main__":
    main()
```

### Complete Example: Weather Server

Here's a complete implementation based on the MCP documentation:

```python
from typing import Any
import httpx
import sys
from mcp.server.fastmcp import FastMCP

# Initialize FastMCP server
mcp = FastMCP("weather")

# Constants
NWS_API_BASE = "https://api.weather.gov"
USER_AGENT = "weather-app/1.0"

async def make_nws_request(url: str) -> dict[str, Any] | None:
    """Make a request to the NWS API with proper error handling."""
    headers = {"User-Agent": USER_AGENT, "Accept": "application/geo+json"}
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, headers=headers, timeout=30.0)
            response.raise_for_status()
            return response.json()
        except Exception:
            return None


def format_alert(feature: dict) -> str:
    """Format an alert feature into a readable string."""
    props = feature["properties"]
    return f"""
Event: {props.get("event", "Unknown")}
Area: {props.get("areaDesc", "Unknown")}
Severity: {props.get("severity", "Unknown")}
Description: {props.get("description", "No description available")}
Instructions: {props.get("instruction", "No specific instructions provided")}
"""


@mcp.tool()
async def get_alerts(state: str) -> str:
    """Get weather alerts for a US state.

    Args:
        state: Two-letter US state code (e.g. CA, NY)
    """
    url = f"{NWS_API_BASE}/alerts/active/area/{state}"
    data = await make_nws_request(url)

    if not data or "features" not in data:
        return "Unable to fetch alerts or no alerts found."

    if not data["features"]:
        return "No active alerts for this state."

    alerts = [format_alert(feature) for feature in data["features"]]
    return "\n---\n".join(alerts)


@mcp.tool()
async def get_forecast(latitude: float, longitude: float) -> str:
    """Get weather forecast for a location.

    Args:
        latitude: Latitude of the location
        longitude: Longitude of the location
    """
    # First get the forecast grid endpoint
    points_url = f"{NWS_API_BASE}/points/{latitude},{longitude}"
    points_data = await make_nws_request(points_url)

    if not points_data:
        return "Unable to fetch forecast data for this location."

    # Get the forecast URL from the points response
    forecast_url = points_data["properties"]["forecast"]
    forecast_data = await make_nws_request(forecast_url)

    if not forecast_data:
        return "Unable to fetch detailed forecast."

    # Format the periods into a readable forecast
    periods = forecast_data["properties"]["periods"]
    forecasts = []
    for period in periods[:5]:  # Only show next 5 periods
        forecast = f"""
{period["name"]}:
Temperature: {period["temperature"]}°{period["temperatureUnit"]}
Wind: {period["windSpeed"]} {period["windDirection"]}
Forecast: {period["detailedForecast"]}
"""
        forecasts.append(forecast)

    return "\n---\n".join(forecasts)


def main():
    # Initialize and run the server
    mcp.run(transport="stdio")


if __name__ == "__main__":
    main()
```

## Running and Testing

### Start the Server

```bash
uv run server.py
```

### Connecting to OpenCode

1. Add the MCP server to `opencode.json` in your project root (or `~/.config/opencode/opencode.json` for global config):
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "mcp": {
       "your-server-name": {
         "type": "local",
         "command": ["python3", "path/to/server.py"],
         "enabled": true
       }
     }
   }
   ```
2. Restart OpenCode to load the MCP server

## Best Practices

1. **Logging**: Always log to stderr or files for STDIO servers
2. **Error Handling**: Handle exceptions gracefully and return meaningful error messages
3. **Type Hints**: Use Python type hints for better code quality and automatic schema generation
4. **Async/Await**: Use async functions for I/O operations
5. **Documentation**: Provide clear docstrings for tools (they become tool descriptions)
6. **Constants**: Keep API endpoints and configuration as constants at the top
7. **Testing**: Test your server independently before connecting to clients

## Additional Capabilities

Beyond tools, MCP servers can also provide:

### Resources
```python
@mcp.resource("resource://{type}/{id}")
def get_resource(type: str, id: str) -> str:
    """Access resource data."""
    # Implementation
```

### Prompts
```python
@mcp.prompt()
def analyze_data_prompt(data: str) -> str:
    """Analyze the provided data."""
    return f"Please analyze this data and provide insights: {data}"
```

## Dependencies

Specify these in your `pyproject.toml`:

```toml
[project]
name = "mcp-server"
dependencies = [
    "mcp[cli]>=1.2.0",
    "httpx>=0.25.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "ruff>=0.1.0",
]
```