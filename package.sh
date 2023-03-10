#!/bin/bash

# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

# Exit on error.
set -e

#STG_DIR, RELEASE_NUMBER and SOURCE_DIR will be taken as env var.
pkg_name="aznfs"
pkg_dir="${pkg_name}_${RELEASE_NUMBER}_amd64"
opt_dir="/opt/microsoft/${pkg_name}"
system_dir="/lib/systemd/system"

# Create the directory to hold the package control and data files.
mkdir -p ${STG_DIR}/${pkg_dir}

# Copy the debian control file(s) and maintainer scripts.
cp -avf ${SOURCE_DIR}/packaging/${pkg_name}/* ${STG_DIR}/${pkg_dir}/
chmod +x ${STG_DIR}/${pkg_dir}/DEBIAN/*

# Insert current release number.
sed -i -e "s/Version: x.y.z/Version: ${RELEASE_NUMBER}/g" ${STG_DIR}/${pkg_dir}/DEBIAN/control
sed -i -e "s/RELEASE_NUMBER=x.y.z/RELEASE_NUMBER=${RELEASE_NUMBER}/g" ${SOURCE_DIR}/scripts/aznfs_install.sh

# Copy other static package file(s).
mkdir -p ${STG_DIR}/${pkg_dir}/usr/sbin
cp -avf ${SOURCE_DIR}/src/aznfswatchdog ${STG_DIR}/${pkg_dir}/usr/sbin/

# Compile mount.aznfs.c and put the executable into ${STG_DIR}/${pkg_dir}/sbin.
mkdir -p ${STG_DIR}/${pkg_dir}/sbin
gcc -static ${SOURCE_DIR}/src/mount.aznfs.c -o ${STG_DIR}/${pkg_dir}/sbin/mount.aznfs

mkdir -p ${STG_DIR}/${pkg_dir}${opt_dir}
cp -avf ${SOURCE_DIR}/lib/common.sh ${STG_DIR}/${pkg_dir}${opt_dir}/
cp -avf ${SOURCE_DIR}/src/mountscript.sh ${STG_DIR}/${pkg_dir}${opt_dir}/

mkdir -p ${STG_DIR}/${pkg_dir}${system_dir}
cp -avf ${SOURCE_DIR}/src/aznfswatchdog.service ${STG_DIR}/${pkg_dir}${system_dir}

cd $STG_DIR

# Create the package.
dpkg-deb --root-owner-group --build $pkg_dir