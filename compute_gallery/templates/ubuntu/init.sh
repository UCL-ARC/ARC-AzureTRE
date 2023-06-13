#!/bin/sh

echo "Running init_vm.sh"
apt-get update

# Install xrdp
echo "Install xrdp"
apt-get install xrdp -y
usermod -a -G ssl-cert xrdp 

# Make sure xrdp service starts up with the system
echo "Enable xrdp"
systemctl enable xrdp

# Install desktop environment if image doesn't have one already
echo "Install XFCE"
apt-get install xorg xfce4 xfce4-goodies dbus-x11 x11-xserver-utils gdebi-core xfce4-screensaver- --yes
echo xfce4-session > ~/.xsession

# Fix for blank screen on DSVM (/sh -> /bash due to conflict with profile.d scripts)
sed -i 's|!/bin/sh|!/bin/bash|g' /etc/xrdp/startwm.sh

# Set the timezone to London
echo "Set Timezone"
timedatectl set-timezone Europe/London

# Fix Keyboard Layout
echo "Set Keyboard Layout"
sed -i 's/"us"/"gb"/' /etc/default/keyboard

## SMB Client
echo "Install SMB Client"
apt-get install smbclient -y

## VS Code
echo "Install VS Code"
apt-get install software-properties-common apt-transport-https wget -y
wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /usr/share/keyrings/vscode.gpg
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | tee /etc/apt/sources.list.d/vscode.list
apt update
apt install -y code

## Anaconda
echo "Install Anaconda"
apt -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh -P /tmp
chmod +x /tmp/Anaconda3-2022.10-Linux-x86_64.sh
bash /tmp/Anaconda3-2022.10-Linux-x86_64.sh -b -p /opt/anaconda
/opt/anaconda/bin/conda install -y -c anaconda anaconda-navigator

## R
echo "Install R"
wget -q https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc -O- | apt-key add -
add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
apt update
apt install -y r-base

## RStudio Desktop
echo "Install RStudio"
wget -q https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.03.0-386-amd64.deb -P /tmp
gdebi --non-interactive /tmp/rstudio-2023.03.0-386-amd64.deb

## Google Chrome
echo "Install Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
gdebi --non-interactive /tmp/google-chrome-stable_current_amd64.deb

## Docker CE
echo "Install Docker CE"
apt-get update &&  apt-get install -y ca-certificates curl gnupg lsb-release
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Grant access to Colord Policy file to avoid errors on RDP connections
echo "Install Colord policy"
cat <<EOT > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord All Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOT
  
## Install script to run at user login
echo "Add User Login Script"
cat <<EOT > /etc/profile.d/init_user_profile.sh

# Add anaconda to PATH
export PATH=/opt/anaconda/bin:\$PATH

# Add user to docker group
sudo usermod -aG docker \$USER

if [ ! -f ~/.xsession ]
then
  echo "Setup xsession"
  echo xfce4-session > ~/.xsession
fi

if [ -f ~/.xscreensaver ]
then  # turn off screensaver
  sed -i 's/random/blank/' ~/.xscreensaver
fi
EOT
