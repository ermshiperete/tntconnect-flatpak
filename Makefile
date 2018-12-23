VERSION=3.5.10
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

all: package

build: TntConnect.tar.gz
	flatpak-builder --verbose --arch=i386 --repo=tntconnect-repo --force-clean --ccache build-dir com.tntware.TntConnect.json

wine:
	flatpak-builder --verbose --arch=i386 --repo=tntconnect-repo --force-clean --ccache build-dir-wine  com.ermshiperete.wine.BaseApp.yml

wine-package: wine
	flatpak build-bundle --arch=i386 tntconnect-repo wine.BaseApp.flatpak com.ermshiperete.wine.BaseApp

package: build
	flatpak build-bundle --arch=i386 tntconnect-repo tntconnect.flatpak com.tntware.TntConnect

run:
	flatpak-builder --arch=i386 --verbose --run build-dir com.tntware.TntConnect.json tntconnect.sh

download:
	mkdir -p $(current_dir)/tmp
	wget --continue -O $(current_dir)/tmp/TntConnect.dmg https://download.tntware.com/tntconnect/archive/$(VERSION)/TntConnect.$(VERSION).dmg

tmp/TntConnect.dmg: download
	cd $(current_dir)/tmp && \
	7z -y x TntConnect.dmg && \
	7z -y x 2.hfs || true

TntConnect.tar.gz: tmp/TntConnect.dmg
	cd $(current_dir)/tmp/TntConnect\ $(VERSION)/TntConnect.app/Contents/Resources && \
	tar cfz $(current_dir)/TntConnect.tar.gz wineprefix

updatejson: download
	export TntConnect_sha256=$(shell sha256sum $(current_dir)/TntConnect.tar.gz | cut -f 1 -d' ') && \
	export TntConnect_size=$(shell stat --printf="%s" TntConnect.tar.gz) && \
	envsubst < com.tntware.TntConnect.json > com.tntware.TntConnect.out.json
