#!/bin/bash

mkdir -p output/qemuarm64/build
KAS_BUILD_DIR=output/qemuarm64/build kas build kas/qemuarm64/kas-qemuarm64.yml:kas/qemuarm64/kas-qemuarm64-lock.yml
