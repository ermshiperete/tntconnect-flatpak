#!/bin/bash

export WINEPREFIX="${HOME}/.local/share/tntconnect"
export WINEARCH="win32"

VERSION_NUM="3.5.12"
VERSION_FILE="${WINEPREFIX}/com.tntware.tntconnect.version"

INSTALLER_NAME="SetupTntConnect.exe"
SETUP="${WINEPREFIX}/${INSTALLER_NAME}"
RUN_CMD="${WINEPREFIX}/drive_c/Program Files/TntWare/TntConnect/TntConnect.exe"
DOWNLOAD_URL=https://download.tntware.com/tntconnect/archive/${VERSION_NUM}/SetupTntConnect.exe

WINE="/app/bin/wine"

XORG_LOG="/var/log/Xorg.0.log"

declare -ra WINE_PACKAGES=(jet40 mdac28 msxml6 usp10 corefonts tahoma win7)
declare -ra WINE_SETTINGS=('csmt=on' 'glsl=disabled')

echo "###########################################"
echo "## TntConnect Unofficial Flatpak v${VERSION_NUM} ##"
echo "###########################################"
echo

set_wine_settings(){
	local my_documents="${WINEPREFIX}/drive_c/users/${USER}/My Documents"

	echo "Installing wine requirements."
	winetricks --unattended "${WINE_PACKAGES[@]}"

	echo "Setting wine settings."
	winetricks --unattended "${WINE_SETTINGS[@]}"

	# Symlink points to wrong location, fix it
	if [[ "$(readlink "${my_documents}")" != "${XDG_DOCUMENTS_DIR}" ]]; then
		echo "Setting game directory to ${XDG_DOCUMENTS_DIR}"
		mv "${my_documents}" "${my_documents}.bak.$(date +%F)"
		ln -s "${XDG_DOCUMENTS_DIR}" "${my_documents}"
	fi

	echo

	TMPFILE=$(mktemp)
	echo "REGEDIT4

[HKEY_CURRENT_USER\Control Panel\Desktop]
\"FontSmoothing\"=\"2\"
\"FontSmoothingOrientation\"=dword:00000001
\"FontSmoothingType\"=dword:00000002
\"FontSmoothingGamma\"=dword:00000578" > $TMPFILE

	echo -n "Updating configuration... "

	"${WINE}" regedit $TMPFILE 2> /dev/null
}

# Run only if TntConnect isn't installed
first_run()
{
	set_wine_settings

	echo "${VERSION_NUM}" > "${VERSION_FILE}"

	if [ ! -f "${SETUP}" ]; then
		echo "Downloading TntConnect installer."
		wget --output-document="${SETUP}" "${DOWNLOAD_URL}"
	fi
	echo "Running TntConnect installer."
	"${WINE}" "${SETUP}"
}

is_updated(){
	if [ -f "${VERSION_FILE}" ]; then
		last_version="$(cat ${VERSION_FILE})"
	else
		last_version="0"
	fi

	echo "${VERSION_NUM}" > "${VERSION_FILE}"

	if [[ "${VERSION_NUM}" == "${last_version}" ]]; then
		return 0
	else
		return 1
	fi
}

# Main function
startup()
{
	if [ ! -f "$RUN_CMD" ]; then
		echo "TntConnect not installed. Installing it now."
		first_run
	else
		if ! is_updated; then
			echo "Not up to date, re-run wine settings"
			set_wine_settings
		fi
	fi

	echo ; echo "Starting TntConnect..."
	"${WINE}" "${RUN_CMD}"
}

startup
