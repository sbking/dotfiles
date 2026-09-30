import json
import pathlib
import re
import tomllib

root = pathlib.Path(__file__).resolve().parent.parent
config = tomllib.loads((root / "mise.toml").read_text())
global_config = tomllib.loads((root / "dotfiles/.config/mise/config.toml").read_text())
assert config["tools"] == global_config["tools"], "Global and provisioning tool pins differ"
for name, version in config["tools"].items():
    assert re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version), (name, version)
paths = (root / "config/managed-paths.txt").read_text().splitlines()
assert set(config["dotfiles"]) == {"~/" + path for path in paths}
for target, entry in config["dotfiles"].items():
    assert target.startswith("~/") and ".." not in pathlib.PurePosixPath(target).parts
    assert (root / entry["source"]).is_file(), entry
    assert not target.startswith("~/.ssh/"), "SSH credentials are machine-local"
    assert entry["mode"] == "copy", "Deployment must not depend on temporary symlinks"
for path in (root / "dotfiles").rglob("*.json"):
    json.loads(path.read_text())
lock = tomllib.loads((root / "mise.lock").read_text())
assert lock, "Lockfile must not be empty"
assert (root / "dotfiles/.config/mise/mise.lock").read_text() == (root / "mise.lock").read_text(), "Global and provisioning lockfiles differ"
assert global_config["settings"] == {"locked": True, "locked_scopes": ["global"]}, "Global tools must install from the lock"
hosts = [line for line in (root / "config/fleet-hosts.txt").read_text().splitlines() if not line.startswith("#")]
assert hosts and all(re.fullmatch(r"[a-z0-9-]+", host) for host in hosts), hosts
print("Pins, manifests, sources, JSON and lockfile validated")
