# Dockerfile to create an image capable of synthesizing vivado projects
# created by J. Witzenrath

# use phusion/baseimage as base because it takes care of handling services
from phusion/baseimage:latest

# copy setup script into the image
COPY setup.sh /tmp/

# run the setup script to customize the image
RUN /bin/sh /tmp/setup.sh

# Open port 22 for ssh
EXPOSE 22

# Use the custom init script from the phusion image
CMD ["/sbin/my_init"]
