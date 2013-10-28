# Basic tools
sudo apt-get -y install vim curl git screen

# oh-my-zsh
sudo apt-get -y install zsh
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
sudo chsh -s /bin/zsh

# Java
sudo apt-get -y install openjdk-7-jdk

# Logstash

sudo mkdir /opt/logstash
cd /opt/logstash
sudo wget https://logstash.objects.dreamhost.com/release/logstash-1.2.1-flatjar.jar -O logstash.jar

sudo mkdir /etc/logstash
sudo mkdir /var/log/logstash

DATE_FILE=/vagrant/config/shipper.conf
sudo cp $DATE_FILE /etc/logstash/shipper.conf

sudo /usr/bin/java -jar /opt/logstash/logstash.jar agent -v -f /etc/logstash/shipper.conf --log /var/log/logstash/shipper.log