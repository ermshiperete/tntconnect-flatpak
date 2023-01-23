mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))
date_now := $(shell date +%F_%H:%M:%S)

all: build

build:
	flatpak-builder --verbose --repo=tntconnect-repo --force-clean --ccache build-dir --collection-id=com.tntware.tntconnect.repo --default-branch=stable com.tntware.TntConnect.yml

backup:
	cp -a tntconnect-repo tntconnect-repo-$(date_now).bak

package: build backup
	flatpak build-bundle --repo-url=https://beilharz-family.de/tntconnect-repo/ --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo --gpg-keys=key.gpg tntconnect-repo tntconnect.flatpak com.tntware.TntConnect stable

run:
	flatpak-builder --verbose --run build-dir --collection-id=com.tntware.tntconnect.repo --default-branch=stable com.tntware.TntConnect.yml tntconnect.sh

sign:
	flatpak build-sign --verbose --gpg-sign=E9140597606020D3 tntconnect-repo com.tntware.TntConnect stable

deltas:
	flatpak build-update-repo --generate-static-deltas --title="TntConnect Flatpak Repo" --default-branch=stable --verbose --gpg-sign=E9140597606020D3 --prune --prune-depth 2 --collection-id=com.tntware.tntconnect.repo tntconnect-repo

complete: package sign deltas

deploy:
	syncTntConnectRepo
