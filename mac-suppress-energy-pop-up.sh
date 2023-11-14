#!/bin/zsh

# Initialize currUser as an empty string
currUser=""

# Loop until currUser is successfully retrieved
while [[ -z "$currUser" ]]; do
    # Attempt to get the current user's name
    currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')

    # Check if currUser is still empty
    if [[ -z "$currUser" ]]; then
        echo "[ERROR] - Current user not found. Retrying..."
        # Optionally, you can add a delay here before the next iteration
        sleep 1
    fi
done

# Now that we have currUser, get the UID
uid=$(id -u "$currUser")

# Check if uid is empty or not found
if [[ -z "$uid" ]]; then
    echo "[ERROR] - UID for user $currUser not found."
    exit 1
fi

# Define the runasuser function
runasuser() {
    launchctl asuser "$uid" sudo -u "$currUser" "$@"
}

# Write the new setting
runasuser /usr/bin/defaults write com.apple.Home showHomeEnergy -bool false

sleep 1

# Re-check the status of Home Energy
new_shestatus=$(runasuser /usr/bin/defaults read com.apple.Home showHomeEnergy)




# Compare the new status to the expected value
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