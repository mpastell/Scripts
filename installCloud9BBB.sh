#!/bin/sh -e

network_down () {
  echo "Network Down"
  exit
}

if ! id | grep -q root; then
  echo "must be run as root"
	exit
fi

ping -c1 www.google.com | grep ttl > /dev/null 2>&1 || network_down

unset deb_pkgs
dpkg -l | grep build-essential >/dev/null || deb_pkgs="${deb_pkgs}build-essential "
dpkg -l | grep libxml2-dev >/dev/null || deb_pkgs="${deb_pkgs}libxml2-dev "
if [ "${deb_pkgs}" ] ; then
  echo "Installing: ${deb_pkgs}"
	sudo apt-get update
	sudo apt-get -y install ${deb_pkgs}
fi

cd ${HOME}
if [ ! -f /usr/local/bin/node ] ; then
echo "Node Doesn't Exist Installing Node"
wget http://nodejs.org/dist/v0.8.22/node-v0.8.22.tar.gz
tar -xvzf node-v0.8.22.tar.gz
cd node-v0.8.22
./configure --without-snapshot
make
sudo make install
cd ${HOME}
sudo rm node-v08.22*
elif ! node --version |grep -Fxq v0.8.22 ; then
echo "Node Not right version, Stopping Script"
exit
else 
echo "Node Installed and Right Version"
fi

if  ! npm -g ls |grep -Fxq libxml@0.0.7 ; then
echo "Installing npm libxml" 
cd  ${HOME}
sudo git clone https://github.com/ajaxorg/node-libxml.git
cd node-libxml
git checkout v0.0.7
sudo rm .gitmodules
cd support
sudo git clone https://github.com/NathanGillis/o3.git
cd ..
sudo npm install -g
cd ~
sudo rm node-libxml
fi

if [ ! -f /etc/cloud9 ] ; then
echo "Starting Cloud9 Install"
cd /etc
sudo git clone https://github.com/ajaxorg/cloud9.git
cd cloud9
sudo npm install
sudo npm ls 2>&1 | grep -o "missing:\s.*,\s" | awk '{gsub(",","",$2); print "npm install " $2 | "/bin/sh"}'
npm install asyncjs@0.0.8
echo "Changing Workplace Location to ~/workplace"
sudo sed -i '19s/workspace/home\/ubuntu\/workplace/' configs/default.js
sudo sed -i '23s/localhost/0.0.0.0/' default.js
cd /etc/init
sudo wget https://raw.github.com/NathanGillis/Scripts/master/cloud9.sh.conf
echo "Cloud9 Added to beagle bone, Workplace exist at  ~/workspace"
echo "To move workpace run sudo sed -i '19s/\/home\/ubuntu\/workspace/my_workspace_location/' default.js"
echo "Adding Start on boot script"
cd /etc/init
wget https://raw.github.com/NathanGillis/Scripts/master/cloud9.sh.conf
else 
echo "Cloud9 Folder Exists, Attempting reinstall";
#cd /etc/cloud9
#sudo npm install
#sudo npm update
echo "Check workspace location, ip that are able to connect and startup script"
fi
echo "Script Finished"
