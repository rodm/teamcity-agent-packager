
domain = 'localdomain'

nodes = [
  { :hostname => 'precise64', :ip => '192.168.80.10', :port => 9090, :box => 'precise64', :url => '' },
  { :hostname => 'centos67',  :ip => '192.168.80.11', :port => 9091, :box => 'centos67',  :url => '' }
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
