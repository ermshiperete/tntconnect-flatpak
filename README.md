# TntConnect Flatpak Package

This is an attempt to package TntConnect as flatpack package.

## Building

To build the flatpak, run the following command:

	flatpak-builder --force-clean --repo=tntconnect-repo build-dir com.tntware.tntconnect.json

To run the created flatpak:

	flatpak-builder run com.tntware.tntconnect.json
