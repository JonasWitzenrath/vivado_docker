#!/bin/sh
# setup the docker container for vivado synthesis

# vivado doesn't work with dash (the default /bin/sh of ubuntu and thereby phusion)
# therefore use bash
ln -sf /bin/bash /bin/sh

# enable SSH
rm -f /etc/service/sshd/down

# make all mounted vivado versions available in the container
echo 'for vivado_version in /opt/Xilinx/Vivado/20??.?; do\n\t[ -f "$vivado_version/settings64.sh" ] && ./$vivado_version/settings64.sh;\ndone' >> /root/.bashrc

# install X11 libraries (requiered by vivado even if run headless
apt update && apt install -y libx11-6

# clean up apt
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
