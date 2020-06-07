#!/bin/bash

set -e

function System()
{
    base=$FUNCNAME
    this=$1

    # Declare methods.
    for method in $(compgen -A function)
    do
        export ${method/#$base\_/$this\_}="${method} ${this}"
    done

    # Properties list.
    ACTION="$ACTION"
    PROXY="$PROXY"

    SYSTEM_USERS_PASSWORD="password"
}

# ##################################################################################################################################################
# Public 
# ##################################################################################################################################################

#
# Void System_run().
#
function System_run()
{
    if [ "$ACTION" == "install" ]; then
        if System_checkEnvironment; then
            System_rootPasswordConfig "$SYSTEM_USERS_PASSWORD"
            System_sshConfig
            System_proxySet "$PROXY"
            System_installDependencies

            System_installQemu
            System_prepareFiles
            System_makeUp

            echo "System installation complete."
        else
            echo "A Debian Buster operating system is required for the installation. Aborting."
            exit 1
        fi
    else
        exit 1
    fi
}

# ##################################################################################################################################################
# Private static
# ##################################################################################################################################################

function System_checkEnvironment()
{
    if [ -f /etc/os-release ]; then
        if ! grep -q 'Debian GNU/Linux 10 (buster)' /etc/os-release; then
            return 1
        fi
    else
        return 1
    fi

    return 0
}



function System_rootPasswordConfig()
{
    printf "\n* Setting a password for root...\n"

    printf "$1\n$1" | passwd 
}



function System_sshConfig()
{
    printf "\n* Enabling direct SSH with password auth for root...\n"
 
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config	
    systemctl restart ssh
}



function System_proxySet()
{
    printf "\n* Setting up system proxy...\n"

    if ! grep -qi "http_proxy" /etc/environment; then
        echo "http_proxy=$1" >> /etc/environment
        echo "https_proxy=$1" >> /etc/environment
    else
        sed -i "s|http_proxy=.*|http_proxy=$1|g" /etc/environment
        sed -i "s|https_proxy=.*|https_proxy=$1|g" /etc/environment
    fi

    export http_proxy=$1
    export https_proxy=$1
}



function System_installDependencies()
{
    printf "\n* Preparing the environment..."

    sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list
    sed -i 's/main$/main contrib non-free/g' /etc/apt/sources.list	
    apt update

    printf "\n* Installing system dependencies...\n"
    DEBIAN_FRONTEND=noninteractive apt install -y dos2unix git locales locales-all openssh-server unzip wget xorriso # base.
    DEBIAN_FRONTEND=noninteractive apt install -y gdm3 gnome-menus gnome-session gnome-shell gnome-terminal # gnome minimal.

    apt clean
}



function System_installQemu()
{
    printf "\n* Installing qemu from Bullseye (pinning)...\n"

    cat >/etc/apt/preferences.d/qemu.pref<<EOF
Package: *
Pin: release n=buster
Pin-Priority: 900

Package: qemu* gcc-10-base libgcc* libcrypt* libc-l10n locales* libc* libffi* libnettle* libhogweed* libtasn* p11-kit-modules libp11-kit* libgnutls* ibverbs-providers libibverbs* libbrlapi* libepoxy* libfdt* libpmem* libslirp* libspice-server* liburing* libvirglrenderer*
Pin: release n=bullseye
Pin-Priority: 1000
EOF

    cat >/etc/apt/sources.list.d/bullseye.list<<EOF
deb http://deb.debian.org/debian/ bullseye main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye main contrib non-free
EOF

    apt update
    DEBIAN_FRONTEND=noninteractive apt install -y qemu-system-aarch64
}



function System_prepareFiles()
{
    printf "\n* Finalizing qemu environment...\n"

    cd /tmp
	
	# qemu.
    if [ -f hda.zip ]; then
        mkdir /home/vagrant/qemu

        unzip hda.zip && mv hda.img /home/vagrant/qemu
        rm -f hda.zip
    else
        exit 1
    fi

    if [ -f QEMU_EFI.fd ]; then
        mv QEMU_EFI.fd /home/vagrant/qemu
    else
        exit 1
    fi

    cat >/home/vagrant/qemu/run.sh<<EOF
if [ -f hda.img ] && [ -f QEMU_EFI.fd ]; then
    qemu-system-aarch64 -m 2048 -M virt -cpu cortex-a72 -smp 2 -serial stdio -bios QEMU_EFI.fd -hda hda.img -netdev user,id=net0,hostfwd=tcp::10022-:22 -device virtio-net-device,netdev=net0
else
    exit 1
fi
EOF

	# live-build.
	git clone --branch 2020-06 https://github.com/marco-buratto/lamponepi.live-build.git
    if [ -d lamponepi.live-build ]; then
	    tar -cf lamponepi.live-build.tar lamponepi.live-build
        mv lamponepi.live-build.tar /home/vagrant/
		rm -R lamponepi.live-build 
		
		chown vagrant:vagrant /home/vagrant/lamponepi.live-build.tar
    else
        exit 1
    fi

	# installer.
	git clone --branch 2020-06 https://github.com/marco-buratto/lamponepi.installer.git 
    if [ -d lamponepi.installer ]; then
        mv lamponepi.installer /sbin/lamponepi-installer
        chmod +x /sbin/lamponepi-installer/lamponepi-install.sh
        ln -s /sbin/lamponepi-installer/lamponepi-install.sh /sbin/lamponepi-install.sh
    else
        exit 1
    fi

    chown vagrant:vagrant /home/vagrant/qemu/*
    chmod +x /home/vagrant/qemu/run.sh
}



function System_makeUp()
{
    printf "\n* Some makeup...\n"

    # Gnome autologin for user vagrant.
    sed -i 's/^#  AutomaticLoginEnable.*/AutomaticLoginEnable = true/g' /etc/gdm3/daemon.conf
    sed -i 's/^#  AutomaticLogin.*/AutomaticLogin = vagrant/g' /etc/gdm3/daemon.conf

    systemctl restart gdm3
}

# ##################################################################################################################################################
# Main
# ##################################################################################################################################################

ACTION=""
PROXY=""

# Must be run as root (sudo).
ID=$(id -u)
if [ $ID -ne 0 ]; then
    echo "This script needs super cow powers."
    exit 1
fi

# Parse user input.
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --action)
            ACTION="$2"
            shift
            shift
            ;;

        --proxy)
            PROXY="$2"
            shift
            shift
            ;;

        *)
            shift
            ;;
    esac
done

if [ -z "$ACTION" ]; then
    echo "Missing parameters. Use --action install for installation."
else
    System "system"
    $system_run
fi

exit 0
