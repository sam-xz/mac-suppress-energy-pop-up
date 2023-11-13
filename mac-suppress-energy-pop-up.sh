#!/bin/zsh

# This script has a WTFPL License. For the greater good.
# Supress the home energy pop up setting up fresh Sonoma macs. Example https://imgur.com/a/ZcMruTp
# You need to run this script as root via your MDM of choice. 
# There was a version of the script floating around but isn't not always successful when running as local user.
# Samuel Marino 13.Nov.23

shestatus=$(/usr/bin/defaults read com.apple.Home showHomeEnergy)

/usr/bin/defaults write com.apple.Home showHomeEnergy -bool false
sleep 3

if [[ $shestatus == "0" ]]; then
    echo "[SUCCESS] - Home Energy Location popup suppressed"
    echo "[EXIT] - Exiting script."
    exit 0
else
    echo "[FAIL] - Home Energy Location popup NOT suppressed"
	echo "Exiting script with error code 1"
	exit 1
fi