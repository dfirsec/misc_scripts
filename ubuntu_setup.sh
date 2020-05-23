#!/bin/bash

# Credit: JohnHammond
# https://github.com/JohnHammond/ignition_key/blob/master/ignition_key.sh

# Define colors ]
RED=$(tput bold && tput setaf 1)
GREEN=$(tput bold && tput setaf 2)
YELLOW=$(tput bold && tput setaf 3)
BLUE=$(tput bold && tput setaf 4)
NC=$(tput sgr0)

update(){
    sudo apt update
}

function RED() {
	echo -e "\n${RED}${1}${NC}"
}
function GREEN() {
	echo -e "\n${GREEN}${1}${NC}"
}
function YELLOW() {
	echo -e "\n${YELLOW}${1}${NC}"
}
function BLUE() {
	echo -e "\n${BLUE}${1}${NC}"
}

# Testing if root ]
if [ $UID -ne 0 ]; then
	RED "You must run this script as root!" && echo
	exit
fi


BLUE "[ Updating repositories ]"
sudo apt update

BLUE "[ Installing Visual Studio Code ]"
sudo apt install software-properties-common apt-transport-https -y

BLUE "[ Importing the Microsoft GPG key ]"
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -

BLUE "[ Enabling the Visual Studio Code repository and install ]"
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install code -y

BLUE "[ Installing git ]"
sudo apt install git -y

BLUE "[ Installing Sublime Text ]" # according to https://www.sublimetext.com/docs/3/linux_repositories.html-
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt install -y apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt install sublime-text -y

BLUE "[ Installing terminator ]"
sudo apt install terminator -y

BLUE "[ Setting terminator as the default terminal emulator ]"
sed -i s/Exec=gnome-terminal/Exec=terminator/g /usr/share/applications/gnome-terminal.desktop

BLUE "[ Forcing a color prompt in ~/.bashrc ]"
grep "export PS1" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;11m\]\u\[$(tput sgr0)\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\][\w]\[$(tput sgr0)\]: \[$(tput sgr0)\]'" >>~/.bashrc
fi

BLUE "[ Installing SimpleScreenRecorder ]"
echo "" | sudo add-apt-repository ppa:maarten-baert/simplescreenrecorder
sudo apt update
sudo apt install simplescreenrecorder -y

BLUE "[ Installing task ]"
sudo apt install taskwarrior -y

BLUE "[ Installing pip3 ]"
sudo apt install python-pip3 -y

BLUE "Removing boilerplate home directories ]"
rmdir ~/Desktop ~/Documents ~/Downloads ~/Music ~/Pictures ~/Public ~/Templates ~/Videos

BLUE "[ Installing guake ]"
sudo apt install guake -y

BLUE "[ Installing openvpn ]"
sudo apt install openvpn -y

BLUE "[ Installing nmap ]"
sudo apt install nmap -y

BLUE "[ Installing docker ]"
sudo apt install -y docker.io
sudo groupadd docker
sudo usermod -aG docker "$(logname)"

BLUE "[ Installing curl ]"
sudo apt install curl -y

BLUE "[ Installing pinta ]"
sudo apt install pinta -y

BLUE "[ Installing exiftool ]"
sudo apt install exiftool -y

BLUE "[ Installing Python PIL ]"
sudo apt install python-pil -y

BLUE "[ Installing sqlitebrowser ]"
sudo apt install sqlitebrowser -y

BLUE "[ Installing Wireshark ]"
sudo apt install wireshark -y

BLUE "[ Installing pefile ]"
pip3 install pefile

BLUE "[ Downloading volatility3 ]"
git clone https://github.com/volatilityfoundation/volatility3.git

BLUE "[ Installing volatility ]"
sudo apt install volatility -y

BLUE "[ Install Real VNC Viewer ]"
wget "https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.17.1113-Linux-x64.deb" -O vnc_viewer.deb
dpkg -i vnc_viewer.deb
rm vnc_viewer.deb

BLUE "[ Install Real VNC Connect (Server) ]"
wget 'https://www.realvnc.com/download/file/vnc.files/VNC-Server-6.2.1-Linux-x64.deb' -O vnc_server.deb
dpkg -i vnc_server.deb
rm vnc_server.deb

BLUE "[ Adding VNC Connect (Server) service to the default startup /etc/rc.local ]"
grep "vncserver-x11-serviced.service" /etc/rc.local
if [ $? -eq 1 ]; then
	echo "systemctl start vncserver-x11-serviced.service" >>~/etc/rc.local
fi

BLUE "[ Installing Atom ]"
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt update
sudo apt install atom -y

BLUE "[ Installing python-requests ]"
pip3 install requests

BLUE "[ Installing idle ]"
sudo apt install -y idle

BLUE "[ Installing xclip ]"
sudo apt install -y xclip
grep "alias xclip" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "alias xclip='xclip -selection clipboard'" >>~/.bashrc
fi

BLUE "[ Installing Python flask ]"
sudo pip3 install flask

BLUE "[ Installing Python flask-login ]"
sudo pip3 install flask-login

BLUE "[ Installing Python colorama ]"
sudo pip3 install colorama

BLUE "[ Installing Python passlib ]"
sudo pip3 install passlib

BLUE "[ Installing Spotify ]"
sudo snap install spotify

BLUE "[ Installing Binwalk ]"
sudo apt install binwalk -y

BLUE "[ Installing Tesseract ]"
sudo apt install tesseract-ocr -y

BLUE "[ Installing foremost ]"
sudo apt install foremost -y

BLUE "[ Installing rot13 ]"
sudo apt install bsdgames -y

BLUE "[ Installing hexedit ]"
sudo apt install hexedit -y

BLUE "[ Installing Python pwntools ]"
sudo pip3 install pwntools

BLUE "[ Installing Go ]"
sudo apt install golang-go -y
sudo apt install gccgo-go -y
BLUE "Adding GOPATH and GOBIN to .bashrc, so future installs are easy.."
grep "export GOPATH" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "export GOPATH=\$HOME/.go/" >>~/.bashrc
fi
grep "export GOBIN" ~/.bashrc
if [ $? -eq 1 ]; then
	echo "export GOBIN=\$HOME/.go/bin" >>~/.bashrc
	echo "export PATH=\$PATH:\$GOBIN" >>~/.bashrc
fi

BLUE "[ Installing gobuster ]"
go get github.com/OJ/gobuster

BLUE "[ Installing sqlite ]"
sudo apt install sqlite -y

BLUE "[ Installing nikto ]"
sudo apt install nikto -y

BLUE "[ Installing zbarimg ]"
sudo apt install zbar-tools -y

BLUE "[ Installing qrencode ]"
sudo apt install qrencode -y

BLUE "[ Installing pdfcrack ]"
sudo apt install pdfcrack -y

BLUE "[ Installing Virtualbox ]"
sudo apt install virtualbox-qt -y

BLUE "[ Installing Vagrant ]"
sudo apt install vagrant -y

# BLUE "[ Installing Hopper ]"
# wget "https://d2ap6ypl1xbe4k.cloudfront.net/Hopper-v4-4.5.28-Linux.deb"
# dpkg -i Hopper-v4-4.5.28-Linux.deb
# rm Hopper-v4-4.5.28-Linux.deb

BLUE "[ Installing Oracle Java 8 ]"
echo "" | sudo add-apt-repository ppa:webupd8team/java
sudo apt update
sudo apt install oracle-java8-installer -y

BLUE "[ Downloading stegsolve.jar ]"
wget "http://www.caesum.com/handbook/Stegsolve.jar" -O "stegsolve.jar"
chmod +x "stegsolve.jar"

BLUE "[ Installing fcrackzip ]"
sudo apt install fcrackzip -y

BLUE "[ Installing unrar ]"
sudo apt install unrar -y

BLUE "[ Installing 7zip ]"
sudo apt install p7zip -y

BLUE "[ Installing steghide ]"
sudo apt install steghide -y

BLUE "[ Installing hashcat ]"
wget https://hashcat.net/files/hashcat-5.1.0.7z
p7zip -d hashcat-5.1.0.7z
cd hashcat-5.1.0 || exit
cp hashcat64.bin /usr/bin/
ln -s /usr/bin/hashcat64.bin /usr/bin/hashcat

BLUE "[ Installing ffmpeg ]"
sudo apt install ffmpeg -y

BLUE "[ Installing Python library netifaces ]"
sudo pip3 install netifaces

BLUE "[ Installing Python library iptools ]"
sudo pip3 install iptools

BLUE "[ Installing Python library OpenSSL ]"
sudo pip3 install pyopenssl

BLUE "[ Installing Python library pydispatch ]"
sudo pip3 install pydispatch

BLUE "[ Installing GIMP ]"
sudo apt install gimp -y

BLUE "[ Installing cmake ]"
sudo apt install cmake -y

BLUE "[ Installing mplayer ]"
sudo apt install mplayer -y

BLUE "[ Installing sshpass ]"
sudo apt install sshpass -y

BLUE "[ Installing tcpflow ]"
sudo apt install tcpflow -y

BLUE "[ Installing Python scapy ]"
sudo pip3 install scapy

BLUE "[ Installing the thing that 7z2john.pl needs ]"
sudo apt install libcompress-raw-lzma-perl

BLUE "[ Installing dos2unix ]"
sudo apt install libcompress-raw-lzma-perl
