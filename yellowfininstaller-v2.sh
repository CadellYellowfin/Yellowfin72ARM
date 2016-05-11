#!/bin/bash
date
echo "Start script"

#Setting DB user var
_dbuser=`echo $1 | base64 --decode`
if [ -z "$_dbuser" ]
	then
	_dbuser="yellowfindbuser"
fi
echo "db User is"
echo $_dbuser

#Setting DB user var
_dbpass=`echo $2 | base64 --decode`
if [ -z "$_dbpass" ]
	then
	_dbpass="Asz7js599!"
fi
echo "db pass is"
echo $_dbpass


#Force Hostname
date
echo "Set Hostname"
sudo hostname Yellowfin72
date
echo "Set Hosts record"
sudo sed -i '1 i\127.0.0.1 Yellowfin72' /etc/hosts

#Update installer package
date
echo "Update apt-get"
sudo apt-get update

#Install JRE and Postgres
date
echo "Install Default-jre"
sudo apt-get install --yes --force-yes default-jre
date
echo "Install Postgres"
sudo apt-get install --yes --force-yes postgresql postgresql-contrib

#Create Postgres User for YF
date
echo "Create Postgres DB User"
sudo -u postgres createuser $_dbuser --createdb --superuser
date
echo "Set Postgres DB User Pass"
sudo -u postgres psql -c "ALTER USER $_dbuser WITH PASSWORD '$_dbpass'"

#Get Yellowfin Installer
date
echo "Get Yellowfin Installer"
wget http://us1.hostedftp.com/~yellowfin/downloads/azure/jsontemplatedownloads/yellowfin-installer.jar -O /tmp/yellowfin.jar

#Get Yellowfin Licence
date
echo "Get Yellowfin Licence"
wget us1.hostedftp.com/~yellowfin/downloads/azure/jsontemplatedownloads/License-Yellowfin-FULLVERSION-Yellowfin72.lic -O /tmp/yellowfin72.lic

#Generate Silence Installer Properties
date
echo "Generate Silence Installer Properties"
echo "InstallPath=/opt/yellowfin" >> /tmp/install.properties
echo "InstallTutorialDatabase=true" >> /tmp/install.properties
echo "LicenceFilePath=/tmp/yellowfin72.lic" >> /tmp/install.properties
echo "ServicePort=80" >> /tmp/install.properties
#echo "InstallService=false" >> /tmp/install.properties
echo "DatabaseType=PostgreSQL" >> /tmp/install.properties
echo "CreateYellowfinDB=true" >> /tmp/install.properties
echo "CreateYellowfinDBUser=false" >> /tmp/install.properties
echo "DatabaseHostname=localhost" >> /tmp/install.properties
echo "DatabaseName=yellowfindb" >> /tmp/install.properties
echo "DatabaseDBAUser=$_dbuser" >> /tmp/install.properties
echo "DatabaseDBAPassword=$_dbpass" >> /tmp/install.properties
echo "DatabaseUser=$_dbuser" >> /tmp/install.properties
echo "DatabasePassword=$_dbpass" >> /tmp/install.properties

#Install Yellowfin
date
echo "Install Yellowfin"
sudo java -jar /tmp/yellowfin.jar -silent /tmp/install.properties

#Set Boot Params
date
echo "Set Boot Params"
sudo sed -i '$ihostname Yellowfin72' /etc/rc.local
sudo sed -i '$i/opt/yellowfin/startup.sh > /tmp/yellowfinstart.log 2>&1' /etc/rc.local

#Start Yellowfin
date
echo "Start Yellowfin"
sudo /opt/yellowfin/appserver/bin/startup.sh > /tmp/yellowfinstart.log 2>&1