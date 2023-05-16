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
            pass
        elif not condition:
            results[condition] = False
        else:
            import subprocess
            results[condition] = subprocess.run(['bash', '-c', f'[[ {condition} ]]']).returncode == 0

    if results:
        i = 0
        length = len(doc['steps'])
        while i < length:
            if 'if' not in doc['steps'][i]:
                i += 1
                continue

            condition = doc['steps'][i].pop('if')
            if not results[condition]:
                del doc['steps'][i]
                length = length - 1
                continue

            i += 1

json.dump(doc, sys.stdout, indent=2)
