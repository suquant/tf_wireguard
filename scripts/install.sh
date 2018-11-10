#!/bin/sh


install_debian() {
    echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable

    apt update -y
    DEBIAN_FRONTEND=noninteractive apt install -y wireguard linux-headers-$(uname -r)
}

install_ubuntu() {
    DEBIAN_FRONTEND=noninteractive apt install -yq apt-transport-https ca-certificates software-properties-common
    add-apt-repository -y ppa:wireguard/wireguard
    apt update -y
    DEBIAN_FRONTEND=noninteractive apt install -y wireguard linux-headers-$(uname -r) linux-headers-virtual
}

os_id=$(lsb_release -s -i)
case $os_id in
    Ubuntu)
        install_ubuntu
        ;;
    Debian)
        install_debian
        ;;
    *)
        echo "Sorry, I do not have $os_id installation recipe"
        exit 1
esac