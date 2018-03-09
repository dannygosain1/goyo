#!/usr/bin/env python3
import sys
import csv
import plistlib
import os

csv_file = sys.argv[1]
with open(csv_file, 'r', encoding='utf-8') as f:
    result = list(csv.DictReader(f))

plist_file = os.path.splitext(csv_file)[0] + '.plist'
plistlib.writePlist(result, plist_file)
