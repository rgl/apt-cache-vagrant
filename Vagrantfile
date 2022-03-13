# make sure the nodes are created by their declared order.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

$cache_ip_address = '10.10.10.3'
$ubuntu_ip_address = '10.10.10.4'
$apt_proxy_url = "http://#{$cache_ip_address}:3142"

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu-20.04-amd64'

  config.vm.provider 'libvirt' do |lv, config|
    lv.memory = 512
    lv.cpus = 2
    lv.cpu_mode = 'host-passthrough'
    lv.keymap = 'pt'
    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
  end

  config.vm.provider :virtualbox do |vb|
    vb.linked_clone = true
    vb.memory = 512
    vb.cpus = 2
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
  end

  config.vm.define :cache do |config|
    config.vm.hostname = 'cache'
    config.vm.network :private_network, ip: $cache_ip_address, libvirt__forward_mode: 'route', libvirt__dhcp_enabled: false
    config.vm.provision :shell, path: 'cache.sh'
  end

  config.vm.define :ubuntu do |config|
    config.vm.hostname = 'ubuntu'
    config.vm.network :private_network, ip: $ubuntu_ip_address, libvirt__forward_mode: 'route', libvirt__dhcp_enabled: false
    config.vm.provision :shell, path: 'ubuntu.sh', args: [$apt_proxy_url]
  end
end