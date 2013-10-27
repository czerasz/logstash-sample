# Project Info

This project is a sample logstash architecture which is visualised on the diagram below:

![logstash architecture](https://raw.github.com/czerasz/logstash-sample/master/documentation/architecture-diagram.png "logstash architecture")

# Requirements:

- [Virtualbox](http://www.virtualbox.org/)
- [Vagrant](http://www.vagrantup.com/)

# Setup:

- Create both machines with Vagrant

        vagrant up central-server
        vagrant up log-server

- Login to each via ssh:

        vagrant ssh central-server
        vagrant ssh log-server