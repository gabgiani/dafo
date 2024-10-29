#!/bin/bash


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




exec 3> >(update_progress)


echo "2:Updating system packages...." >&3
# Update and upgrade system packages
sudo apt-get update >/dev/null 2>&1

echo "3:Upgrading system packages...." >&3

sudo apt-get upgrade -y  >/dev/null 2>&1

echo "7:Installing dependencies..." >&3
# Install dependencies
sudo apt-get install -y python3-virtualenv sshfs python3-tk mpg321 >/dev/null 2>&1

echo "9:Initializing Virtual Environment..." >&3

# Create the virtual environment
virtualenv $ENV_DIR   >/dev/null 2>&1
source $ENV_DIR/bin/activate

echo "12:Installing GUI...." >&3

# Install Python packages
pip install -U packaging ttkthemes customtkinter  >/dev/null 2>&1

echo "15:Installing Computer Vision Libraries.." >&3

pip install -U opencv-contrib-python pyrealsense2  >/dev/null 2>&1

echo "18:Installing tools..." >&3
pip install -U screeninfo netifaces cryptography pascal-voc-writer  >/dev/null 2>&1
pip install -U boto3 >/dev/null 2>&1
echo "20:Installing Libraries.." >&3

pip install -U matplotlib numba  >/dev/null 2>&1

echo "22:Installing Libraries...." >&3

pip install -U pygments requests  >/dev/null 2>&1
pip install -U psycopg2-binary    >/dev/null 2>&1

echo "25:Installing Libraries..." >&3

pip install -U protobuf==3.20.1 pdf2image psutil  >/dev/null 2>&1
pip install -U typing_extensions pandas >/dev/null 2>&1

echo "27:Installing AI Libraries...." >&3
if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null; then
   pip install -U tensorflow[and-cuda] >/dev/null 2>&1
else
    pip install -U tensorflow >/dev/null 2>&1
fi

pip install -U tensorflow_hub >/dev/null 2>&1

echo "30:Installing AI Libraries...." >&3

pip install -U tensorflowjs >/dev/null 2>&1
pip install -U torch==2.1.2 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121 > /dev/null 2>&1
pip install -U ultralytics
pip install -U googletrans
pip install -U shapely

echo "35:Installing Interfaces..." >&3

pip install -U flask_dance flask_login flask[async] >/dev/null 2>&1
pip install -U sqlalchemy > /dev/null 2>&1

echo "37:Installing Human Machine Interface.." >&3

pip install -U mutagen gtts googletrans >/dev/null 2>&1

# Deactivate the virtual environment
deactivate
exec 3>&-


# Completion message
whiptail --title "Installation Complete" --msgbox "DAFO AI  has been successfully installed in the virtual environment '$ENV_DIR'." 10 50

