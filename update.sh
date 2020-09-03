#!/bin/bash

source scripts/common.sh

info "Updating system cache..."
update_package_cache
info "Upgrading packages..."
upgrade_packages