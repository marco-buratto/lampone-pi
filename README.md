# Lampone Pi

Live, readonly Debian arm64 port for the Raspberry Pi.

You can download the pre-built image from ...

Here are the instructions on how to build your own arm64 Debian-based live image and then write the resulting ISO file onto a SD card so that it's compliant to be booted by a Raspberry Pi. In order to simplify the building stage, a "qemu box" is used in this howto.


## qemu box

**Install the qemu box**

This procedure automates the installation of a VirtualBox environment (Debian Buster x86_64) in which a qemu installation of Debian Buster arm64 is present. The qemu box will be used to *build a live image of Debian Buster for arm64* and then *write the image* to a SD card in a way it is compatible with a Raspberry Pi.
The qemu box is not required if you can manage to set up a qemu installation and run the *lamponepi-install.sh* within a Linux box.

*Requirements* (you need to install the following prerequisites in your operating system before running the qemu box installation):
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



**\
\
Use the qemu box: launch the Debian arm64 system on qemu**

Within the vbox system, open a terminal and launch the qemu emulation (as vagrant user):

    cd qemu/
    ./run.sh 
    
Remember to enable the shared clipboard on VirtualBox to allow copy & pasting. 
A bind from port 22 of the qemu system and port 10022 of the vbox system is created, in order to be able to perform ssh and scp.

![qemu box](vbqemu.setup/img/vnoxqemu.boot.png)

For booting the Debian arm64 system, on the qemu efi terminal give:

    FS0:
    cd EFI/debian
    grubaa64.efi

Log in as root (password: *password*).

![debian arm](vbqemu.setup/img/debian.arm.png)

**\
\
Prepare the qemu system for the live building (setup once)**

A patched live-build program is needed for a correct live-building. The .deb package of live-build patched by our Team has been already copied onto the vbox system, so now we have to copy and install it onto the qemu system.

On the qemu system we "start the network" and modify the sshd config for root user to be able to accept direct connections:

    dhclient
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config 
    systemctl restart ssh
    
Now on the vbox system:

    scp -P 10022 /home/vagrant/live-build2019031131_all.deb root@127.0.0.1:/tmp

Finally, on the qemu host, install the package and its dependencies:

    dpkg -i /tmp/live-build2019031131_all.deb
    apt install -fy

**\
\
Live build: create a ISO for a generic live Debian arm64 system**

Live building a minimal test OS is now trivial; on the qemu system:

    mkdir live
    cd live/
    
    dhclient

    lb config --distribution buster 
    lb build
    
Finally, we move the live image from the qemu host to the vbox one; from the vbox host:

    scp -P 10022 root@127.0.0.1:/root/live/live-image-arm64.hybrid.iso .
    
**\
\
Writing the live image onto a SD card**

Connect the SD-to-USB dongle to the computer and attach it to the vbox system within VirtualBox: the vbox system will handle your dongle as a USB device.

Within the vbox system, open a terminal as root (*su -*) and use *fdisk -l* for locating the device file:

    # fdisk -l
    
    Disk /dev/sda: 50 GiB, 53687091200 bytes, 104857600 sectors
    Disk model: VBOX HARDDISK   
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xbce97a12

    Device     Boot    Start       End  Sectors Size Id Type
    /dev/sda1  *        2048  98568191 98566144  47G 83 Linux
    /dev/sda2       98570238 104855551  6285314   3G  5 Extended
    /dev/sda5       98570240 104855551  6285312   3G 82 Linux swap / Solaris


    Disk /dev/sdc: 7.4 GiB, 7969177600 bytes, 15564800 sectors
    Disk model: MicroSD/M2      
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x73dc7c47

*/dev/sdc* is the device file corresponding to the USB dongle.

Now we write the live image to the SD card in a way it is compatible with a Raspberry Pi's booting:

    lamponepi-install.sh --iso /home/vagrant/live-image-arm64.hybrid.iso --device /dev/sdc
    
Please note. Reboot the vbox system (and redo the write) in case of write failures or system written incorrectly: VirtualBox seems not so stable in handling USB devices.    
    
Please note. The resulting partitioning scheme is *liveng* compliant (https://liveng.readthedocs.io/en/latest/) - the same used by in Resilient Linux with the minimum possible modifications for the Pi porting. The liveng partitioning scheme allows programs and kernel updates with a readonly system partition. As of now the kernel update feature is not yet ported on the Pi, juststay tuned.
