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
	 apt-get update
	 apt-get -y install ${deb_pkgs}
fi

cd ${HOME}
if [ ! -f /usr/local/bin/node ] ; then
echo "Node Doesn't Exist Installing Node"
wget http://nodejs.org/dist/v0.8.22/node-v0.8.22.tar.gz
tar -xvzf node-v0.8.22.tar.gz
cd node-v0.8.22
./configure --without-snapshot
make
 make install
cd ${HOME}
 rm -R node-v0.8.22*
elif ! node --version |grep -Fxq v0.8.22 ; then
echo "Node Not right version, Stopping Script"
exit
else 
echo "Node Installed and Right Version"
fi

if ! npm -g ls |grep -Fq  libxml@0.0.7 ; then
echo "Installing npm libxml" 
cd  ${HOME}
 git clone https://github.com/ajaxorg/node-libxml.git
cd node-libxml
git checkout v0.0.7
 rm .gitmodules
cd support
 git clone https://github.com/NathanGillis/o3.git
cd ..
 npm install -g
cd ~
 rm -R node-libxml
fi

if [ ! -d /etc/cloud9 ] ; then
cd /etc
 git clone https://github.com/ajaxorg/cloud9.git
cd cloud9
 npm install || true
 echo "Installing Missing node modules for cloud9"
 npm ls 2>&1 | grep -o "missing:\s.*,\s" | awk '{gsub(",","",$2); print "npm install " $2 " || true"| "/bin/sh"}'
 echo "Installing Node Modules that always seem to fail"
 npm install asyncjs@0.0.8
 npm install asyncjs@0.0.8
 sed -i '19s/(argv.w && path.resolve(process.cwd(), argv.w)) || process.cwd()/"home\/ubuntu\/workspace"/' configs/default.js
 sed -i '22s/localhost/0.0.0.0/' configs/default.js
 echo "Adding Start on boot script"
cd /etc/init
 wget https://raw.github.com/NathanGillis/Scripts/master/cloud9.sh.conf
echo "Cloud9 Added to beagle bone, Workplace exist at  ~/workspace"
echo "To move workpace run sudo sed -i '19s/\/home\/ubuntu\/workspace/my_workspace_location/' default.js"

cd /home/ubuntu/
mkdir workspace
else 
echo "Cloud9 Folder Exists, Attempting reinstall";
#cd /etc/cloud9
#sudo npm install
#sudo npm update
echo "Check workspace location, ip that are able to connect and startup script"
fi

echo "Script Finished"
