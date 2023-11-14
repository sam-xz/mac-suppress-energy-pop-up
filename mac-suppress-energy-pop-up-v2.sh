#!/bin/zsh

max_retries=15
attempt=0

while (( attempt < max_retries )); do
    # Increment the attempt counter
    ((attempt++))

    # Initialize currUser as an empty string
    currUser=""

    # Attempt to get the current user's name
    currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')

    # Check if currUser is 'loginwindow' or empty
    if [[ -z "$currUser" || "$currUser" == "loginwindow" ]]; then
    echo "[ERROR] - Valid current user not found (user is '$currUser'). Retrying..."
    sleep 1
    continue
    fi

    # If currUser is empty, retry the loop
    #if [[ -z "$currUser" ]]; then
    #    echo "[ERROR] - Current user not found. Retrying..."
    #    sleep 1
    #    continue
    #fi

    echo "whoami=$currUser"

    # Get uid logged in user
    uid=$(id -u "${currUser}")

    # Define the runasuser function
    runasuser() {
        launchctl asuser "$uid" sudo -u "$currUser" "$@"
    }

    # Write the new setting
    runasuser /usr/bin/defaults write com.apple.Home showHomeEnergy -bool false
    # AND as root
    /usr/bin/defaults write com.apple.Home showHomeEnergy -bool false
    # Read the new status
    new_shestatus=$(/usr/bin/defaults read com.apple.Home showHomeEnergy)

        echo "Debug: new_shestatus is '$new_shestatus'"

    #Compare the new status to the expected value
    if [[ "$new_shestatus" == "0" ]]; then
      echo "[SUCCESS] - Home Energy Location popup suppressed"
      echo "[EXIT] - Exiting script."
      sleep 5
      pkill WindowManager
      exit
    else
        echo "[FAIL] - Home Energy Location popup NOT suppressed"
        echo "Attempt $attempt of $max_retries."
       # add a sleep delay here if you want before the next iteration
       sleep 1
    fi

done

echo "Exiting script after $max_retries attempts with error code 1"
exit 1