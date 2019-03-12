#!/bin/bash
### This script sets up the tigervnc server and lxde.  It has to be run as root.
### The script takes 2 arguments: The user name and the user password.  Unfortunately, the 
### VNC version we are using does not seem to support multiple user names on the same instance.
### Also note that if we are setting this up to use with guacamole, that the username and password
### have to also be set in the user-mappings.xml file in /etc/guacamole.guacamole.

if (( $EUID != 0 )); then
    echo "This script must be run as the root user."
    exit
fi

# update the package lists
apt-get update

# We want to install the vncserver: We are using tigervnc
# for it's support of direct x rendering, which is required for 
# apps like the slicer.
apt-get install tigervnc-standalone-server

# We want some sort of desktop as well. We are using lxde at the moment.  I really don't 
# like gnome, as it is too heavyweight for what we need
apt-get install lxde lxshortcut

# we also need the mesa libs
apt-get install libglu1-mesa libxi-dev libxmu-dev libglu1-mesa-dev mesa-utils

# for shutting this thing up, but this was the only one that worked.
mv /usr/bin/lxpolkit /usr/bin/lxpolkit.bak

# change to the supplied user
su - $1

# set the vnc password.  This will also create a reasonable startup file
vncpasswd -f $2

# start the VNC server
vncserver -geometry 1920x1024 -depth 24 -SecurityTypes VncAuth
