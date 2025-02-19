#!/bin/bash

# Set the name of the IPK file
IPK_FILE="InstallCodesysBootApplication.ipk"

# Set the name of the remote WAGO device
REMOTE_USER="root"
REMOTE_HOST="192.168.178.105"
APPLICATION="opkg install --force-reinstall /tmp/InstallCodesysBootApplication.ipk"


# Create the control file
cat <<EOF > CONTROL/control
Package: InstallCodesysBootApplication
Version: 1.0
Architecture: all
Maintainer: Diederick Nab <diederick.nab@wago.com>
Description: Install CODESYS boot application
EOF

# Create the data.tar.gz file
tar -czf data.tar.gz -C DATA .

# Create the control.tar.gz file
tar -czf control.tar.gz -C CONTROL .

# Create the debian-binary file
echo "2.0" > debian-binary

# Create the IPK file
ar r "$IPK_FILE" debian-binary control.tar.gz data.tar.gz

echo "IPK file created: $IPK_FILE"

# remove temporary files
rm debian-binary
rm control.tar.gz
rm data.tar.gz

#!/bin/bash

echo "Do you want to upload the ipk to the controller? (yes/no)"
read -r response

# Convert response to lowercase
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [[ "$response" == "yes" || "$response" == "y" ]]; then
    scp InstallCodesysBootApplication.ipk root@192.168.178.105:/tmp
    rm InstallCodesysBootApplication.ipk
    echo "IPK file uploaded to controller."

    echo "Do you want to start the ipk installation on the controller? (yes/no)"
    read -r response
    if [[ "$response" == "yes" || "$response" == "y" ]]; then
        ssh ${REMOTE_USER}@${REMOTE_HOST} "${APPLICATION} &> /dev/null &"
        echo "IPK installation started on remote device."
        else
        echo "action canceled."
        exit 1
    fi
else
    echo "action canceled."
    exit 1
fi

