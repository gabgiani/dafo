#!/bin/bash

UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" != "22.04" ]]; then
    whiptail --title "Incompatible Version" --msgbox "This installer is compatible only with Ubuntu 22.04. Your version is $UBUNTU_VERSION. Installation may not work as expected." 10 50
    exit 1
fi

# Function to prompt for sudo password
ask_for_sudo() {
    while true; do
        SUDO_PASS=$(whiptail --title "Root Authentication required" --passwordbox "Enter your sudo password" 10 50 --cancel-button "Exit" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            echo "Installation cancelled by user."
            exit 1
        fi

        # Check if the entered password is correct
        echo $SUDO_PASS | sudo -Sv 2>/dev/null
        if [ $? -eq 0 ]; then
            break
        else
            whiptail --title "Authentication failed" --msgbox "Incorrect password, please try again." 10 50
        fi
    done
}

# Function to display progress updates
update_progress() {
    while read -r line; do
        IFS=':' read -r progress message <<< "$line"
        echo "XXX"
        echo "$progress"
        echo "$message"
        echo "DAFO AI. www.dafo.ai"
        echo "XXX"
    done | whiptail --gauge "Please wait while the installation is in progress..." 8 50 0 --title "DAFO AI - Visit our webpage: www.dafo.ai"
}

# Welcome message
whiptail --title "Installer" --msgbox "Welcome to the installation wizard for DAFO AI - The Guidance System for the Operators!" 10 50

# Ask for the sudo password
ask_for_sudo

# Ask for the virtual environment directory name
ENV_DIR=$(whiptail --inputbox "Enter the folder name to install the DAFO App: " 10 60 "dafo" 3>&1 1>&2 2>&3)

# Check if the user pressed cancel
if [ $? -ne 0 ]; then
    echo "Installation cancelled."
    exit 1
fi

# Ensure the system folder exists in the home directory
INSTALL_PATH="$HOME/$ENV_DIR"
SYSTEM_DIR="$INSTALL_PATH/system"
mkdir -p $SYSTEM_DIR

exec 3> >(update_progress)

# Download and process version.txt
echo "2:Downloading version file..." >&3
VERSION_URL="https://www.dafo.ai/download/2742/?tmstv=1730624898"
VERSION_FILE="$SYSTEM_DIR/version.txt"
curl -s -o $VERSION_FILE $VERSION_URL

if [ $? -ne 0 ]; then
    echo "Failed to download version.txt" >&3
    exit 1
fi

echo "5:Reading and downloading specified file..." >&3
DOWNLOAD_URL=$(cat $VERSION_FILE)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "No URL found in version.txt" >&3
    exit 1
fi

wget -q -P $SYSTEM_DIR $DOWNLOAD_URL >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to download the file from $DOWNLOAD_URL" >&3
    exit 1
fi

echo "10:Extracting downloaded file..." >&3
ZIP_FILE="$SYSTEM_DIR/$(basename $DOWNLOAD_URL)"
unzip -o $ZIP_FILE -d $SYSTEM_DIR >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Failed to unzip $ZIP_FILE" >&3
    exit 1
fi

echo "File downloaded and unzipped successfully from $DOWNLOAD_URL" >&3

# Create a .desktop file for launching the app
echo "60:Creating application launcher..." >&3
DESKTOP_FILE="$HOME/.local/share/applications/dafo.desktop"
cat > $DESKTOP_FILE <<EOL
[Desktop Entry]
Name=DAFO AI
Comment=Launch DAFO AI Application
Exec=/bin/bash -c "source $INSTALL_PATH/bin/activate && cd $SYSTEM_DIR && python dafo.py"
Icon=$SYSTEM_DIR/icons/icondafo.png
Terminal=false
Type=Application
Categories=Application;
EOL

# Set permissions for the .desktop file
chmod +x $DESKTOP_FILE

# Update desktop database
update-desktop-database $HOME/.local/share/applications/ >/dev/null 2>&1

# Update and upgrade system packages
echo "15:Updating system packages...." >&3
sudo apt-get update >/dev/null 2>&1

echo "18:Upgrading system packages...." >&3
sudo apt-get upgrade -y  >/dev/null 2>&1

echo "22:Installing dependencies..." >&3
sudo apt-get install -y python3-virtualenv sshfs python3-tk mpg321 >/dev/null 2>&1

echo "25:Initializing Virtual Environment..." >&3
virtualenv $INSTALL_PATH >/dev/null 2>&1
source $INSTALL_PATH/bin/activate

echo "28:Installing GUI...." >&3
pip install -U packaging ttkthemes customtkinter >/dev/null 2>&1
pip install -U reportlab qrcode >/dev/null 2>&1

echo "32:Installing Computer Vision Libraries.." >&3
pip install -U opencv-contrib-python pyrealsense2 >/dev/null 2>&1

echo "35:Installing tools..." >&3
pip install -U screeninfo netifaces cryptography pascal-voc-writer >/dev/null 2>&1
pip install -U boto3 >/dev/null 2>&1

echo "38:Installing Libraries.." >&3
pip install -U matplotlib numba >/dev/null 2>&1

echo "42:Installing Libraries...." >&3
pip install -U pygments requests >/dev/null 2>&1
pip install -U psycopg2-binary >/dev/null 2>&1

echo "45:Installing Libraries..." >&3
pip install -U protobuf==3.20.1 pdf2image psutil >/dev/null 2>&1
pip install -U typing_extensions pandas >/dev/null 2>&1

echo "48:Installing AI Libraries...." >&3
if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
   pip install -U tensorflow[and-cuda] >/dev/null 2>&1
else
    pip install -U tensorflow >/dev/null 2>&1
fi
pip install -U tensorflow_hub >/dev/null 2>&1

echo "52:Installing AI Libraries...." >&3
pip install -U tensorflowjs >/dev/null 2>&1
pip install -U torch==2.1.2 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121 >/dev/null 2>&1
pip install -U ultralytics >/dev/null 2>&1
pip install -U googletrans >/dev/null 2>&1
pip install -U shapely >/dev/null 2>&1

echo "55:Installing Interfaces..." >&3
pip install -U flask_dance flask_login flask[async] >/dev/null 2>&1
pip install -U sqlalchemy >/dev/null 2>&1

echo "58:Installing Human Machine Interface.." >&3
pip install -U mutagen gtts googletrans >/dev/null 2>&1

# Deactivate the virtual environment
deactivate
exec 3>&-

# Completion message
whiptail --title "Installation Complete" --msgbox "DAFO AI has been successfully installed in the virtual environment '$INSTALL_PATH'." 10 50
