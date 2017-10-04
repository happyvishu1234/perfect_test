# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

config.vm.box = "thinktainer/centos-6_6-x64"


config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
config.vm.network "forwarded_port", guest: 443, host: 8443, host_ip: "127.0.0.1"

Vagrant::Config.run do |config|

config.vm.network :bridged
end

  # other config here
Vagrant.configure("2") do |config|
config.vm.synced_folder ".", "/srv" , disabled: true
end

config.vm.provision "shell" do |s|
      s.path = "bootstrap.sh"
end
config.vm.provision "shell" do |s|
      s.path = "csr.sh"

end

config.vm.provision "shell" do |s|
      s.path = "php_gen.sh"

end




end
