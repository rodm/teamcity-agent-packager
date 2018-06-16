
domain = 'localdomain'

nodes = [
  { :hostname => 'trusty',   :ip => '192.168.80.10', :port => 9090, :box => 'ubuntu/trusty64', :url => '' },
  { :hostname => 'xenial',   :ip => '192.168.80.11', :port => 9091, :box => 'ubuntu/xenial64', :url => '' },
  { :hostname => 'centos69', :ip => '192.168.80.12', :port => 9092, :box => 'centos69', :url => '' },
  { :hostname => 'centos74', :ip => '192.168.80.13', :port => 9093, :box => 'centos74', :url => '' },
  { :hostname => 'osx1010',  :ip => '192.168.80.14', :port => 9094, :ram => '2048', :box => 'osx1010', :url => '' },
  { :hostname => 'solaris',  :ip => '192.168.80.15', :port => 9095, :ram => '1536', :box => 'solaris', :url => '' },
  { :hostname => 'bionic',   :ip => '192.168.80.16', :port => 9091, :box => 'ubuntu/bionic64', :url => '' }
]

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.insert_key = false

  nodes.each do | node |
    config.vm.define node[:hostname] do | node_config |
      node_config.vm.box = node[:box]
      node_config.vm.box_url = node[:url]

      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]
      node_config.vm.network :forwarded_port, guest: node[:port], host: node[:port]

      memory = node[:ram] ? node[:ram] : 512

      node_config.vm.provider :virtualbox do | vbox |
        vbox.gui = false
        vbox.customize ['modifyvm', :id, '--name', node[:hostname]]
        vbox.customize ['modifyvm', :id, '--memory', memory.to_s]
      end

      node_config.vm.provider 'vmware_fusion' do | vmware |
        vmware.gui = false
        vmware.vmx['memsize'] = memory.to_s
      end

      node_config.vm.provider 'vmware_workstation' do | vmware |
        vmware.gui = false
        vmware.vmx['memsize'] = memory.to_s
      end

      node_config.vm.provision :shell do | shell |
        shell.path = 'scripts/setup.sh'
      end
    end
  end
end
