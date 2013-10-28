# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # Use this option if You can't connect to github
  config.ssh.forward_agent = true

  # Use the bootstrap script to update ubuntu
  config.vm.provision :shell, :path => "provision/shell/bootstrap.sh"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Configuration for VirtualBox:
  config.vm.provider :virtualbox do |vb|
    # Boot with headless mode
    vb.gui = false
  
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.define "central-server", primary: true do |config_1|
    # The hostname the machine should have
    config.vm.hostname = "central"

    # Use the basebox with the following name:
    config_1.vm.box    = "ubuntu_precise_64"

    # The url from where the 'config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system.
    config_1.vm.box_url = "http://files.vagrantup.com/precise64.box"

    # Get more boxes from:
    # - https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Boxes

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    config_1.vm.network :private_network, ip: "10.0.0.10"

    # Provision
    config_1.vm.provision :shell, :path => "provision/shell/central-setup.sh"
  end

  config.vm.define "log-server" do |config_2|
    # The hostname the machine should have
    config.vm.hostname  = "shipper"

    # Use the basebox with the following name:
    config_2.vm.box     = "ubuntu_precise_64"

    # The url from where the 'config.vm.box' box will be fetched if it
    # doesn't already exist on the user's system.
    config_2.vm.box_url = "http://files.vagrantup.com/precise64.box"

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    config_2.vm.network :private_network, ip: "10.0.0.11"

    # Provision
    config_2.vm.provision :shell, :path => "provision/shell/shipper-setup.sh"
  end
end
