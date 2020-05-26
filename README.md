# Lampone Pi

Live, readonly Debian arm64 port for the Raspberry Pi 3.


## qemu box

**Install the qemu box**

This procedure automates the installation of a VirtualBox environment (Debian Buster x86_64) in which a qemu installation of Debian Buster arm64 is present. The "qemu box" will be used to *build a live image of Debian Buster for arm64* and then write the image to a SD card in a way it is compatible with a Raspberry Pi.
The qemu box is not required if you can manage to set up a qemu installation and run the *lampone-install.sh* within a Linux box (see later on).

*Requirements* (you need to install the following prerequisites in your operating system before running the "qemu box" installation):
 - VirtualBox (with guest additions) 
 - Vagrant
 - from a terminal: *vagrant plugin install vagrant-reload*

*Run the installation:*

 - clone or download this GitHub repository 
 - *cd /path/to/lampone-pi*
 - *cd vbqemu.setup* 
 - *vagrant up*

*At the end of the setup, a VirtualBox machine is created:*
 - ssh host to guest: *ssh root@127.0.0.1 -p 2222* (password is: *password*)
 - VirtualBox user: *vagrant* | *vagrant*

You can use the VirtualBox GUI as you are used to, from now on.



**Use the qemu box: launch the Debian arm64 system on qemu**

Within VirtualBox, open a terminal and launch the qemu emulation (as vagrant user):

    cd qemu/
    ./run.sh 

![qemu box](vbqemu.setup/img/vnoxqemu.boot.png)

For booting the Debian arm64 system, on the qemu efi terminal give:

    FS0:
    cd EFI/debian
    grubaa64.efi

Log in as root (password: *password*) and you are ready to live-build.

![debian arm](vbqemu.setup/img/debian.arm.png)
