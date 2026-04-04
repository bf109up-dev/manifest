#!/bin/bash

mkdir -p output/qemuarm64/build
KAS_BUILD_DIR=output/qemuarm64/build taskset -c 0-9 kas build kas/qemuarm64/kas-qemuarm64-tag.yml
