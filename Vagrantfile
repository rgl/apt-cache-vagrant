Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu-16.04-amd64'

  config.vm.provider :virtualbox do |vb|
    vb.linked_clone = true
    vb.memory = 256
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
  end

  config.vm.define :cache do |config|
    config.vm.hostname = 'cache'
    config.vm.network :private_network, ip: '10.10.10.3'
    config.vm.provision :shell, path: 'cache.sh'
  end

  config.vm.define :ubuntu do |config|
    config.vm.hostname = 'ubuntu'
    config.vm.network :private_network, ip: '10.10.10.4'
    config.vm.provision :shell, path: 'ubuntu.sh'
  end
end