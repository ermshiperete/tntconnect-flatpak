mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

all: build

build:
	flatpak-builder --verbose --arch=i386 --repo=tntconnect-repo --force-clean --ccache build-dir com.tntware.TntConnect.json

package: build
	flatpak build-bundle --arch=i386 tntconnect-repo tntconnect.flatpak com.tntware.TntConnect

run:
	flatpak-builder --arch=i386 --verbose --run build-dir com.tntware.TntConnect.json tntconnect.sh

wine:
	flatpak-builder --verbose --arch=i386 --repo=tntconnect-repo --force-clean --ccache build-dir-wine  de.ermshiperete.wine.BaseApp.yml

wine-package: wine
	flatpak build-bundle --verbose --arch=i386 tntconnect-repo wine.BaseApp.flatpak de.ermshiperete.wine.BaseApp 4.0

sign:
	flatpak build-sign --verbose --arch=i386 --gpg-sign=E9140597606020D3 tntconnect-repo  de.ermshiperete.wine.BaseApp 4.0
	flatpak build-sign --verbose --arch=i386 --gpg-sign=E9140597606020D3 tntconnect-repo  com.tntware.TntConnect

deltas:
	flatpak build-update-repo --generate-static-deltas --verbose --gpg-sign=E9140597606020D3  --prune tntconnect-repo

complete: wine-package package sign deltas