# Central Server Setup

## Install Java - required for Logstash and Elasticsearch

    apt-get -y install openjdk-7-jdk

## Setup Redis

Install Redis server:

    sudo apt-get install redis-server -y

Change the server bind option in `/etc/redis/redis.conf`:

    # bind 127.0.0.1
    bind 10.0.0.10

Restart the Redis server, so config changes can be applied:

    sudo /etc/init.d/redis-server restart

Test the Redis instance.
Type `ping` in the `redis-cli`:

    redis-cli -h 10.0.0.10

Redis should respond with `PONG`.

Check if the firewall configuration doesn't block Redis.
Type `ping` after the connections was stablished with `telnet`.

    telnet 10.0.0.10 6379

Redis should respond with `PONG`.
(Exit with `Ctrl+^` + `↩`, then type `quit`)

### Manualy setup Redis

For a manual instalation please follow this [link](http://redis.io/topics/quickstart)


## Setup Elasticsearch

    mkdir ~/elasticsearch; cd ~/elasticsearch
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.5.tar.gz -O elasticsearch-0.90.5.tar.gz
    tar -xzvf elasticsearch-0.90.5.tar.gz
    rm elasticsearch-0.90.5.tar.gz

Adjust the Elasticsearch configuration file `config/elasticsearch.yml`:

    cluster.name: logstash
    node.name: "central"

Start Elasticsearch:

    bin/elasticsearch

Check if Elasticsearch is running:

    curl 'http://localhost:9200'

### Alternative Elasticsearch install solution:

Download and start Elasticsearch:

    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.deb
    export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386/
    sudo dpkg -i elasticsearch-0.90.3.deb
    sudo /etc/init.d/elasticsearch start

Adjust the Elasticsearch configuration file `config/elasticsearch.yml`:

    cluster.name: logstash
    node.name: "central"

Restart Elasticsearch:

    sudo /etc/init.d/elasticsearch restart

Add mapping for logstash indexes:

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


## Setup Elasticsearch HQ

    bin/plugin -install royrusso/elasticsearch-HQ

Check if Elasticsearch HQ is working

    http://10.0.0.10:9200/_plugin/HQ/

## Setup Logstash on the `central` server

    sudo mkdir /opt/logstash
    cd /opt/logstash
    sudo wget https://logstash.objects.dreamhost.com/release/logstash-1.2.1-flatjar.jar -O logstash.jar
    
    sudo mkdir /etc/logstash
    sudo mkdir /var/log/logstash

Add the central logstash configuration (`/etc/logstash/central.conf`):

# Central configuration

    input {
      redis {
        host => "10.0.0.10"
        type => "redis-input"
        data_type => "list"
        key => "logstash"
      }
    }

    output {
      stdout { }
      
      elasticsearch {
        cluster => "logstash"
      }
    }

Start Logstash central:

    /usr/bin/java -jar /opt/logstash/logstash.jar agent -v -f /etc/logstash/central.conf --log /var/log/logstash/central.log


Create logstash-central init script

    cd ~
    wget http://logstashbook.com/code/3/logstash-central-init -O logstash-central-init
    sudo mv logstash-central-init /etc/init.d/logstash-central
    sudo chmod 0755 /etc/init.d/logstash-central
    sudo chown root:root /etc/init.d/logstash-central
    sudo update-rc.d logstash-central enable
    sudo /etc/init.d/logstash-central start

## Setup Redis Commander 

Alternative software solution can be found [here](http://steelthread.github.io/redmon/)

### Prerequirements: install node over nvm

    sudo apt-get install git curl -y
    wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
    source ~/.profile
    nvm install v0.10.20

### Install Redis Commander

    mkdir ~/redis-commander
    cd ~/redis-commander
    npm install redis-commander
    node node_modules/redis-commander/bin/redis-commander.js --redis-host '10.0.0.10' --port 8200 &

The web ui can be found under [http://10.0.0.10:8200/](http://10.0.0.10:8200/)


## Setup Kibana

    cd ~
    wget https://download.elasticsearch.org/kibana/kibana/kibana-latest.tar.gz -O - | tar -xzvf -
    mv kibana-latest kibana
    cd kibana
    python -m SimpleHTTPServer 8201


# Shipper Server Setup

## Install Java - required for Logstash

    apt-get -y install openjdk-7-jdk

## Setup Logstash on the `shipper` server

    sudo mkdir /opt/logstash
    cd /opt/logstash
    sudo wget https://logstash.objects.dreamhost.com/release/logstash-1.2.1-flatjar.jar -O logstash.jar
    
    sudo mkdir /etc/logstash
    sudo mkdir /var/log/logstash

Add the shipper logstash configuration (`/etc/logstash/shipper.conf`):

    input {
      file {
        type => "apache"
        path => ["/vagrant/sample-logs/insert.log"]
        start_position => "beginning"
      }
    }

    filter {
      if ( [type] == "apache" ) {
        grok {
          match => { "message" => "%{COMBINEDAPACHELOG}" }
        }

        date {
          match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
        }

        mutate {
          remove_field => [ "timestamp", "path" ]
        }
      }
    }

    output {
      stdout { 
        debug => true
      }

      redis {
        host => "10.0.0.10"
        data_type => "list"
        key => "logstash"
      }
    }

Start Logstash shipper:

    /usr/bin/java -jar /opt/logstash/logstash.jar agent -v -f /etc/logstash/shipper.conf --log /var/log/logstash/shipper.log


# Resources:
- [The logstash Book](http://logstashbook.com/)
- [Logging with Logstash, ElasticSearch, Kibana and Redis](https://medium.com/what-i-learned-building/e855bc08975d)