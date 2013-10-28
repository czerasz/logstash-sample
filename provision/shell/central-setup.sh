# Basic tools
sudo apt-get -y install vim curl git screen

# oh-my-zsh
sudo apt-get -y install zsh
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
sudo chsh -s /bin/zsh

# Java
sudo apt-get -y install openjdk-7-jdk

# Redis
sudo apt-get -y install redis-server

sudo sed -i 's/^bind 127.0.0.1$/bind 10.0.0.10/' /etc/redis/redis.conf

sudo /etc/init.d/redis-server restart

# Elasticsearch
mkdir ~/elasticsearch; cd ~/elasticsearch
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.5.tar.gz -O elasticsearch-0.90.5.tar.gz
tar -xzvf elasticsearch-0.90.5.tar.gz
rm elasticsearch-0.90.5.tar.gz

sed -i 's/^# cluster.name: elasticsearch$/cluster.name: logstash/' elasticsearch-0.90.5/config/elasticsearch.yml
sed -i 's/^# node.name: "Franz Kafka"$/node.name: "central"/' elasticsearch-0.90.5/config/elasticsearch.yml

elasticsearch-0.90.5/bin/plugin -install royrusso/elasticsearch-HQ

elasticsearch-0.90.5/bin/elasticsearch &

curl -XPUT http://10.0.0.10:9200/_template/logstash_per_index -d '
{
  "template": "logstash*",
  "settings": {
    "index.query.default_field": "message",
    "index.cache.field.type": "soft",
    "index.store.compress.stored": true
  },
  "mappings": {
    "_default_": {
      "_all": { "enabled": false },
      "properties": {
        "message": { "type": "string", "index": "not_analyzed" },
        "@version": { "type": "string", "index": "not_analyzed" },
        "@timestamp": { "type": "date", "index": "not_analyzed" },
        "type": { "type": "string", "index": "not_analyzed" },
        "bytes": { "type": "long", "index": "not_analyzed" },
        "host": { "type": "string", "index": "not_analyzed" },
        "clientip": { "type": "string", "index": "not_analyzed" },
        "agent": { "type": "string", "index": "analyzed" },
        "response": { "type": "integer", "index": "not_analyzed" },
        "httpversion": { "type": "string", "index": "not_analyzed" },
        "referrer": { "type": "string", "index": "analyzed" },
        "ident": { "type": "string", "index": "not_analyzed" },
        "verb": { "type": "string", "index": "not_analyzed" },
        "request": { "type": "string", "index": "analyzed" },
        "auth": { "type": "string", "index": "not_analyzed" }
      }
    }
  }
}'

# Logstash

sudo mkdir /opt/logstash
cd /opt/logstash
sudo wget https://logstash.objects.dreamhost.com/release/logstash-1.2.1-flatjar.jar -O logstash.jar

sudo mkdir /etc/logstash
sudo mkdir /var/log/logstash

DATE_FILE=/vagrant/config/central.conf
sudo cp $DATE_FILE /etc/logstash/central.conf

sudo /usr/bin/java -jar /opt/logstash/logstash.jar agent -v -f /etc/logstash/central.conf --log /var/log/logstash/central.log &

# Install node and nvm
cd ~
wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
source ~/.profile
nvm install v0.10.20

echo -e "\n" >>  ~/.zshrc
echo '# Initialize nvm' >>  ~/.zshrc
echo '[[ -s "$HOME/.nvm/nvm.sh" ]] && source "$HOME/.nvm/nvm.sh" # This loads NVM' >>  ~/.zshrc


# Redis Commander
mkdir ~/redis-commander
cd ~/redis-commander
npm install redis-commander
node node_modules/redis-commander/bin/redis-commander.js --redis-host '10.0.0.10' --port 8200 &

# Kibana
cd ~
wget https://download.elasticsearch.org/kibana/kibana/kibana-latest.tar.gz -O - | tar -xzvf -
mv kibana-latest kibana
cd kibana
python -m SimpleHTTPServer 8201 &