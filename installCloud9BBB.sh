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
	echo "Node Doesn't Exist Installing Node v0.10.15"
	wget http://nodejs.org/dist/v0.10.15/node-v0.10.15.tar.gz
	tar -xvzf node-v0.10.15.tar.gz
	cd node-v0.10.15
	./configure --without-snapshot
	make
	make install
	cd ${HOME}
	rm -R node-v0.10.15*
fi
if [ ! -d /etc/node_cloud9 ] ; then
	cd /etc
	mkdir node_cloud9
	if ! node --version |grep -Fxq v0.8.22 ; then
		echo "Node v0.8.22 Doesn't Exist , Installing"
		cd node_cloud9
		wget http://nodejs.org/dist/v0.8.22/node-v0.8.22.tar.gz
		tar -xvzf node-v0.8.22.tar.gz
		cd node-v0.8.22
		./configure --without-snapshot
		make
	fi
	cd `dirname $0`
	tar -xvzf cloud9.tar.gz
	mv cloud9 /etc/node_cloud9/
	if ! node --version |grep -Fxq v0.8.22 ; then
		mv cloud9.sh.conf /ect/init
	else 
	   echo "Node v0.8.22 is installed globally on device. Please Create conf File"
	fi
	echo "Creationg Workspace a /home/ubuntu"	
	cd /home/ubuntu/
	mkdir workspace
fi

echo "Script Finished"
