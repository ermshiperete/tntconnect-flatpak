VERSION=3.5.10
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

all: build

build: TntConnect.tar.gz
	flatpak-builder --repo=tntconnect-repo --force-clean --ccache build-dir com.tntware.TntConnect.json

run:
	flatpak-builder --verbose --run build-dir com.tntware.TntConnect.json tntconnect.sh

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
