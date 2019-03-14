#!/bin/bash -x
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
apt-get install tigervnc-standalone-server -y

# We want some sort of desktop as well. We are using lxde at the moment.  I really don't 
# like gnome, as it is too heavyweight for what we need
apt-get install lxde lxshortcut -y

# we also need the mesa libs
apt-get install libglu1-mesa libxi-dev libxmu-dev libglu1-mesa-dev mesa-utils -y

# for shutting this thing up, but this was the only one that worked.
mv /usr/bin/lxpolkit /usr/bin/lxpolkit.bak

# Get the user home directory
userName=$1
userDir=`eval echo "~$userName"`

# make the VNC directory
su - $1 -c "mkdir ${userDir}/.vnc"

# set the vnc password.  
su - $1 -c "echo -n $2 | vncpasswd -f > ${userDir}/.vnc/passwd"

# chmod the vnc password.  
su - $1 -c "chmod 600 ${userDir}/.vnc/passwd"

# create an xstartup file
cat << EOF > /tmp/xstartup
#!/bin/sh
xrdb $userDir/.Xresources
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
lxterminal &
/usr/bin/lxsession -s LXDE &
EOF

# copy the startup file as the user
su - $1 -c "cp /tmp/xstartup ${userDir}/.vnc/xstartup"

# cleanup the starup file
/bin/rm -f /tmp/xstartup

# start the VNC server
su - $1 -c "vncserver -geometry 1920x1024 -depth 24 -SecurityTypes VncAuth"
