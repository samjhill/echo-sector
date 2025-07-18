#!/bin/bash

# Get short Git commit hash
GIT_HASH=$(git rev-parse --short HEAD)

# Get current date & time in human-readable format
BUILD_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Write to build_version.gd
cat <<EOF > build_version.gd
# Auto-generated during build
extends Node

var BUILD_VERSION := "$GIT_HASH"
var BUILD_TIMESTAMP := "$BUILD_TIME"
EOF

echo "Generated build_version.gd: $GIT_HASH at $BUILD_TIME"
