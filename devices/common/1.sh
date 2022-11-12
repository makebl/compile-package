#!/bin/bash

SCRIPT="./make-index.sh"

# Generates package manifest
$SCRIPT . 2>/dev/null > Packages.manifest
grep -vE '^(Maintainer|LicenseFiles|Source|SourceName|Require|SourceDateEpoch)' Packages.manifest > Packages
gzip -9nc Packages > Packages.gz