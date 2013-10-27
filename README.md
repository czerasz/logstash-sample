# Project Info

This project is a sample logstash architecture.

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