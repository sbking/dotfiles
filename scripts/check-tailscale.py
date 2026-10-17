"""Verify the installed macOS client and its connection, not just a package receipt."""
import json
import os
from pathlib import Path
import subprocess
import sys

def check():
    client = Path("/Applications/Tailscale.app/Contents/MacOS/Tailscale")
    if not client.is_file():
        return "Tailscale app is missing; repair the installation even if package status says installed."
    try:
        extensions = subprocess.run(
            ["/usr/bin/systemextensionsctl", "list"],
            capture_output=True, text=True, timeout=10, check=True,
        ).stdout
        if not any(
            "io.tailscale.ipn.macsys.network-extension" in line
            and "[activated enabled]" in line for line in extensions.splitlines()
        ):
            return "Approve Tailscale Network Extension in System Settings > General > Login Items & Extensions."
        result = subprocess.run(
            [str(client), "status", "--json"],
            env={**os.environ, "TAILSCALE_BE_CLI": "1"},
            capture_output=True, text=True, timeout=15, check=True,
        )
        try:
            status = json.loads(result.stdout)
        except ValueError:
            return "Tailscale returned invalid status; open its desktop app and finish setup, then retry."
        if not isinstance(status, dict):
            return "Tailscale returned an unexpected status format."
        if status.get("BackendState") != "Running":
            return "Tailscale is not running; open its desktop app and sign in or connect."
        own = status.get("Self")
        if not isinstance(own, dict) or own.get("Online") is not True or not status.get("TailscaleIPs"):
            return "Tailscale has not confirmed an online device with a tailnet address."
    except subprocess.TimeoutExpired:
        return "Tailscale check timed out; inspect its desktop app."
    except (OSError, subprocess.CalledProcessError):
        return "Cannot query Tailscale; inspect its desktop app and network extension."
    return None

if __name__ == "__main__":
    failure = check()
    if failure:
        print(failure, file=sys.stderr)
        raise SystemExit(1)
    print("Tailscale: installed, extension enabled, connected. Verify intended tailnet and peer reachability separately.")
