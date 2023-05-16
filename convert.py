#!/usr/bin/env python3

import sys
import yaml
import json

doc = yaml.safe_load(sys.stdin)

if 'steps' in doc:
    results = {}
    for step in doc['steps']:
        if 'if' not in step:
            continue

        condition = step['if']
        if condition in results:
            result = results[condition]
        elif not condition:
            result = results[condition] = False
        else:
            import subprocess
            result = subprocess.run(['bash', '-c', f'[[ {condition} ]]']).returncode == 0
            results[condition] = result

    if results:
        for step in doc['steps']:
            if 'if' not in step:
                continue

            condition = step.pop('if')
            if not results[condition]:
                doc['steps'].remove(step)

json.dump(doc, sys.stdout, indent=2)
