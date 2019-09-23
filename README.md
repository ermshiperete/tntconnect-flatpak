# TntConnect Flatpak Package

This is an attempt to package TntConnect as flatpack package.

## Prerequisites

- Install flatpak and flatpak-builder
- Install the i386 version of the used runtime and sdk (currently `org.freedesktop.* 18.08`)

**NOTE:** runtime version 19.08 is not available for i386.

## Building

To build the flatpak, run the following command:

	flatpak-builder --force-clean --ccache --repo=tntconnect-repo build-dir com.tntware.TntConnect.json

To run the created flatpak:

	flatpak-builder --run build-dir com.tntware.TntConnect.json tntconnect.sh
