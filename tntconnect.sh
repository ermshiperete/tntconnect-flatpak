#!/bin/bash

#export WINEPREFIX="${HOME}/.local/share/tntconnect"
#export WINEPREFIX="/app/extra/wineprefix"
export WINEPREFIX="/var/data/tntconnect"
export WINEARCH="win32"

VERSION_NUM="3.5.10"
VERSION_FILE="${WINEPREFIX}/com.tntware.TntConnect.version"

RUN_CMD="${WINEPREFIX}/drive_c/Program Files/TntWare/TntConnect/TntConnect.exe"
WINE="/app/bin/wine"

declare -ra WINE_PACKAGES=(jet40 mdac28 msxml6 usp10 corefonts tahoma win7)
declare -ra WINE_SETTINGS=('csmt=on' 'glsl=disabled')

set_wine_settings(){
#	echo "Installing wine requirements."
#	winetricks --unattended "${WINE_PACKAGES[@]}"

	echo "Setting wine settings."
	winetricks --unattended "${WINE_SETTINGS[@]}"

#	TMPFILE=$(mktemp)
#	echo "REGEDIT4
#
#[HKEY_CURRENT_USER\Control Panel\Desktop]
#\"FontSmoothing\"=\"2\"
#\"FontSmoothingOrientation\"=dword:00000001
#\"FontSmoothingType\"=dword:00000002
#\"FontSmoothingGamma\"=dword:00000578" > $TMPFILE
#
#	echo -n "Updating configuration... "
#
#	"${WINE}" regedit $TMPFILE 2> /dev/null
}

# Run only if TntConnect isn't installed
first_run()
{
	# TntConnect writes it's config files in the current directory
	# Running files in /app/extra wont work, instead make a copy to
	# /var/data a.k.a $XDG_DATA_HOME
	mkdir -p /var/data/tntconnect
	cp -a /app/extra/wineprefix/* /var/data/tntconnect/

	set_wine_settings

	echo "${VERSION_NUM}" > "${VERSION_FILE}"
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
		echo "First run of TntConnect."
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
