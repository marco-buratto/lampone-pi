# Lampone Pi

Live, readonly Debian arm64 port for the Raspberry Pi

**Install the qemu box**

This procedure automates the installation of a Virtualbox environment (Debian Buster x86_64) in which a qemu installation of Debian Buster arm64 is present. The "qemu box" will be used to *build a live image of Debian Buster for arm64*.

*Requirements* (you need to install the following prerequisites in your operating system before running the "qemu box" installation):
 - VirtualBox (with guest additions) 
 - Vagrant
 - from a terminal: vagrant plugin install vagrant-reload

*Run the installation:*

 - clone or download this GitHub repository 
 - cd /path/to/lampone-pi 
 - cd vbqemu.setup 
 - vagrant up

*At the end of the setup, a VirtualBox machine is created:*
 - network host to guest: 127.0.0.1:2222 for SSH --> root | password
 - VirtualBox user: vagrant | vagrant

*Vagrant commands:*
 - vagrant halt 
 - vagrant up 
 - vagrant suspend
 - vagrant resume
 - destroy everything: vagrant destroy -f
