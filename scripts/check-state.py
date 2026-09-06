"""Fail on drift: status commands may report missing resources with exit code 0."""
import json
import subprocess
import sys

kind = sys.argv[1]
result = subprocess.run(
    ['mise', 'bootstrap', kind, 'status', '--json'],
    check=True, capture_output=True, text=True,
)
data = json.loads(result.stdout)
failures = []
if kind == 'dotfiles':
    for item in data['files']:
        if item['state'] != 'applied':
            failures.append(f"{item['target']}: {item['state']}")
elif kind == 'packages':
    for manager, info in data.items():
        if not info.get('available', False):
            failures.append(f'{manager}: unavailable')
        for item in info.get('packages', []):
            if item['state'] != 'installed':
                failures.append(f"{manager}:{item['package']}: {item['state']}")
else:
    raise SystemExit('Expected dotfiles or packages')
if failures:
    print('\n'.join(failures), file=sys.stderr)
    raise SystemExit(1)
print(f'{kind}: all declared resources match')
