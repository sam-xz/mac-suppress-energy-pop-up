#!/bin/zsh


# Initialize currUser as an empty string
currUser=""

# Loop until currUser is successfully retrieved
while [[ -z "$currUser" ]]; do
    # Attempt to get the current user's name
    currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')
    echo whoami=$currUser
    # Check if currUser is still empty
    if [[ -z "$currUser" ]]; then
        echo "[ERROR] - Current user not found. Retrying..."
        # Optionally, you can add a delay here before the next iteration
        sleep 1
    fi
done

# Get uid logged in user
uid=$(id -u "${currUser}")

# Define the runasuser function
runasuser() {
    launchctl asuser "$uid" sudo -u "$currUser" "$@"
}

runasuser /usr/bin/defaults write com.apple.Home showHomeEnergy -bool false

# Compare the new status to the expected value
new_shestatus=$(launchctl asuser "$uid" sudo -u "$currUser" "$@" /usr/bin/defaults read com.apple.Home showHomeEnergy)

echo "Debug: new_shestatus is '$new_shestatus'"
if [[ "$new_shestatus" == "0" ]]; then
    echo "[SUCCESS] - Home Energy Location popup suppressed"
    echo "[EXIT] - Exiting script."
    pkill WindowManager
    sleep 1
    exit 0
else
    echo "[FAIL] - Home Energy Location popup NOT suppressed"
    echo "Exiting script with error code 1"
    exit 1
fi