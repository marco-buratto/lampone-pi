# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

# The most common configuration options are documented and commented below.
# For a complete reference, please see the online documentation at
# https://docs.vagrantup.com.

Vagrant.configure("2") do |config|
  config.vm.define :vm do |vm|
    vm.vm.provider "virtualbox" do |vb|
      vb.gui = true
      vb.memory = "3072"
      vb.cpus = 2
    end

    # OS.

    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://vagrantcloud.com/search.	  
 
    vm.vm.box = "marcoburatto/debian-buster-official-vbox-guest-additions"
    vm.vm.box_version = "1.0"

    # Network.

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # NOTE: This will enable public access to the opened port

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine and only allow access
    # via 127.0.0.1 to disable public access
    # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"	

    # vm.vm.network "forwarded_port", guest: 22, host: 10022

    # Provision.

    # Copy the virtual hard drive where Debian for arm64 has been previously instelled to via qemu
    # with the following procedure:
    #    wget http://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_EFI.fd && mv QEMU_EFI.fd /usr/share
    #    wget https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-10.4.0-arm64-netinst.iso # @todo...
    #
    #    # Create hard disk.
    #    qemu-img create -f qcow2 hda.img 10G
    #
    #    # Install.
    #    qemu-system-aarch64 -m 2048 -M virt -cpu cortex-a72 -smp 2 -hda hda.img -serial stdio -bios /usr/share/QEMU_EFI.fd -drive file=debian-10.4.0-arm64-netinst.iso,id=cdrom,if=none,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom

    vm.vm.provision "file", source: "hda.zip", destination: "/tmp/"
    vm.vm.provision "file", source: "QEMU_EFI.fd", destination: "/tmp/"

    vm.vm.provision "shell" do |s|
      s.path = "bootstrap.sh"
      s.args = ["--action", "install"]
    end

    vm.vm.provision "reload" # reboot the machine.
  end
end
