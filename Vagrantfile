# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("1") do |config|
  # run "VAGRANT_GUI=1 vagrant up" to get a display; default is headless mode
  if ENV['VAGRANT_GUI'] != nil
    config.vm.boot_mode = :gui
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "xgds_base"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "https://xgds.org/vagrant/xgds_base.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network "private_network", ip: "10.0.3.18"

  # fix a problem with vagrant's method of setting hostname
  $hosts_fix_script = <<EOF
grep 'geoRef.vagrant geoRef' /etc/hosts > /dev/null
if [ "$?" == "1" ]; then
  echo adding geoRef.vagrant entry to /etc/hosts
  sudo /bin/echo 127.0.0.1 geoRef.vagrant geoRef >> /etc/hosts
fi
EOF
  config.vm.provision :shell, :inline => $hosts_fix_script

  # need a hostname or puppet will complain
  config.vm.hostname = "geoRef.vagrant"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  # config.vm.forward_port 80, 8080

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.synced_folder "geoRef/", "/home/vagrant/geocamspace/geoRef", owner: "vagrant", group: "vagrant"

  # Enable provisioning with Puppet stand alone.
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file  = "site.pp"
    puppet.options = "--debug --verbose"
  end

end
