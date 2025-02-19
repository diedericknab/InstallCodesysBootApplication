# Explanation of the Bash Script for IPK Creation, Upload, and Installation

## **1. Script Overview**
This Bash script automates the **creation, transfer, and installation** of an IPK package for deploying a **CODESYS boot application** on a **WAGO PLC**. It consists of two main parts:
1. **Creating the IPK package**
2. **Uploading and installing the IPK package on the remote PLC**

---

## **2. Breaking Down the Script**

### **Part 1: Creating the IPK Package**
This section generates an IPK package by assembling the necessary files.

### **Define Variables**
```bash
# Set the name of the IPK file
IPK_FILE="InstallCodesysBootApplication.ipk"

# Set the name of the remote WAGO device
REMOTE_USER="root"
REMOTE_HOST="192.168.178.105"
APPLICATION="opkg install --force-reinstall /tmp/InstallCodesysBootApplication.ipk"
```
- `IPK_FILE`: Name of the package to be created.
- `REMOTE_USER`: SSH login username (default: `root`).
- `REMOTE_HOST`: IP address of the target WAGO PLC.
- `APPLICATION`: Command to install the IPK file on the PLC using `opkg`.

### **Create the Control File (`CONTROL/control`)**
```bash
cat <<EOF > CONTROL/control
Package: InstallCodesysBootApplication
Version: 1.0
Architecture: all
Maintainer: Diederick Nab <diederick.nab@wago.com>
Description: Install CODESYS boot application
EOF
```
- The `control` file provides **metadata** about the package.

### **Package the Files into `.tar.gz` Archives**
```bash
tar -czf data.tar.gz -C DATA .
tar -czf control.tar.gz -C CONTROL .
```
- `data.tar.gz`: Contains the actual application files.
- `control.tar.gz`: Contains the **control file**, which holds metadata.

### **Define the Debian Package Version**
```bash
echo "2.0" > debian-binary
```
- Specifies the **Debian package format version** (`2.0`).

### **Assemble the IPK Package**
```bash
ar r "$IPK_FILE" debian-binary control.tar.gz data.tar.gz
echo "IPK file created: $IPK_FILE"
```
- Uses the `ar` command to create an **IPK file**.

### **Clean Up Temporary Files**
```bash
rm debian-binary
rm control.tar.gz
rm data.tar.gz
```
- Removes temporary files after packaging.

---

### **Part 2: Uploading and Installing the IPK Package**
This section prompts the user for confirmation, then transfers and installs the package.

### **Ask the User for Upload Confirmation**
```bash
echo "Do you want to upload the ipk to the controller? (yes/no)"
read -r response
```
- Prompts the user to confirm uploading the IPK file.

### **Normalize Input to Lowercase**
```bash
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
```
- Converts user input to lowercase for consistency.

### **Upload the IPK File to the PLC**
```bash
if [[ "$response" == "yes" || "$response" == "y" ]]; then
    scp InstallCodesysBootApplication.ipk root@192.168.178.105:/tmp
    rm InstallCodesysBootApplication.ipk
    echo "IPK file uploaded to controller."
```
- Uses `scp` to copy the IPK file to the **WAGO PLC** at `/tmp/`.

### **Ask for Installation Confirmation**
```bash
    echo "Do you want to start the ipk installation on the controller? (yes/no)"
    read -r response
```
- Prompts the user before proceeding with installation.

### **Install the IPK on the PLC**
```bash
    if [[ "$response" == "yes" || "$response" == "y" ]]; then
        ssh ${REMOTE_USER}@${REMOTE_HOST} "${APPLICATION} &> /dev/null &"
        echo "IPK installation started on remote device."
```
- Uses SSH to run `opkg install` on the WAGO PLC.

### **Cancel the Process If the User Declines**
```bash
        else
        echo "action canceled."
        exit 1
    fi
else
    echo "action canceled."
    exit 1
fi
```
- If the user declines, the script exits with error code `1`.

---

## **3. How to Modify the Script for Your Needs**
| **What You Want to Change** | **What to Modify** |
|----------------------------|--------------------|
| Change the package name | Modify `IPK_FILE` and `Package:` in the control file. |
| Update the target PLC's IP address | Change `REMOTE_HOST="your_ip_address"` |
| Change installation location on PLC | Modify `/tmp/` in `scp` and `opkg` commands. |
| Add more files to the IPK | Place them in the `DATA/` directory before packaging. |
| Adjust installation options | Modify the `opkg` command parameters. |

---

## **4. Summary**
This script:
1. **Creates an IPK package** with necessary metadata and application files.
2. **Uploads the IPK to a remote WAGO PLC** via `scp`.
3. **Installs the IPK package** on the PLC using `opkg`.
4. **Uses prompts for user confirmation**, allowing manual control over execution.

With these explanations, you can **easily modify the script** to fit your specific WAGO PLC deployment needs. 🚀