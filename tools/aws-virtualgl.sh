#!/bin/bash

############################################################
#         Copyright (c) 2015 Jonathan Yantis               #
#          Released under the MIT license                  #
############################################################
#                                                          #
# If you want to try this out just use this script to launch
# and connect on an AWS EC2 instance.
#
# IMPORTANT: make sure to change the userdefined variables
#
# You must have aws cli installed.
# https://github.com/aws/aws-cli
#
# If using Arch Linux it is on the AUR as aws-cli
#
# This uses one of the AMIs from
# https://www.uplinklabs.net/projects/arch-linux-on-ec2/
# Usage:
# aws-virtualgl.sh
#
# Example:
# aws-virtualgl.sh 
#                                                          #
############################################################

# WARNING: THESE INSTANCES ARE 65+ cents an hour.

############################################################

# USER DEFINABLE (NOT OPTIONAL)
KEYNAME=yantisec2 # Private key name
SUBNETID=subnet-d260adb7 # VPC Subnet ID

# USER DEFINABLE (OPTIONAL)
REGION=us-west-2
# IMAGEID=ami-71be9041
IMAGEID=ami-11718071

# Exit the script if any statements returns a non true (0) value.
# breaks the script on the various ssh commands.
# set -e

# Exit the script on any uninitialized variables.
set -u

# Create our new instance
ID=$(aws ec2 run-instances \
  --image-id ${IMAGEID} \
  --key-name ${KEYNAME} \
  --instance-type g2.2xlarge \
  --region ${REGION} \
  --subnet-id ${SUBNETID} | \
    grep InstanceId | awk -F\" '{print $4}')

# Sleep 10 seconds here. Just to give it time to be created.
sleep 10
echo "Instance ID: $ID"


# Query every second until we get our IP.
while [ 1 ]; do
  IP=$(aws ec2 describe-instances --instance-ids $ID | \
    grep PublicIpAddress | \
    awk -F\" '{print $4}')

  if [ -n "$IP" ]; then
    echo "IP Address: $IP"
    break
  fi

  sleep 1
done

# Connect to the server and update all the drivers and install docker
ssh -o ConnectionAttempts=255 \
    -o StrictHostKeyChecking=no \
    -i $HOME/.ssh/${KEYNAME}.pem \
    root@$IP -tt << EOF
    pacman -Syu --noconfirm
    pacman -S --noconfirm btrfs-progs arch-install-scripts
    pacman -S --noconfirm extra/nvidia extra/nvidia-utils extra/nvidia-libgl xf86-input-evdev
    mkfs.btrfs -L docker /dev/xvdb -f
    pacman -S docker --noconfirm
    mkdir /mnt/docker
    mount /dev/xvdb /mnt/docker
    sed -i "s/bin\/docker/bin\/docker -g \/mnt\/docker/" /usr/lib/systemd/system/docker.service
    systemctl enable docker.service
    useradd --create-home user
    mkdir -p /home/user/.ssh
    cp /root/.ssh/authorized_keys /home/user/.ssh/
    chown -R user:user /home/user/.ssh/
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    genfstab -p / >> /etc/fstab
    reboot
EOF

# Give us some time to have the server restart.
sleep 30

# Connect to the server launch the container 
ssh -o ConnectionAttempts=255 \
  -o StrictHostKeyChecking=no \
  -i $HOME/.ssh/${KEYNAME}.pem \
  user@$IP -tt << EOF
  sudo nvidia-smi
  sudo systemctl start docker.service
  sudo docker run \
    --privileged \
    -d \
    -v /home/user/.ssh/authorized_keys:/authorized_keys:ro \
    -h docker \
    -p 49154:22 \
    yantis/virtualgl
    sudo pkill -INT -u user
EOF


# Give us some time to have the container setup the proper drivers.
sleep 30

# Now that is is launched go ahead and connect to our new server
# We have to assume the user has not opened port 4244 on thier firewall
# So use SSH for both the graphics and the authentication even though its much slower.
vglconnect -sY \
  -o ConnectionAttempts=255 \
  -o StrictHostKeyChecking=no \
  docker@$IP -p 49154 \
  -t vglrun glxspheres64

# Now that we are done. Delete the instance.
# aws ec2 terminate-instances --instance-ids $ID
