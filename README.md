# docker-virtualgl
This is [VirtualGL](http://virtualgl.org) running on docker.
It includes all 32 bit & 64 bit libraries.

It should work out of the box with all Nvidia cards and Nvidia drivers and most other cards as well that use Mesa drivers.
It is setup to auto adapt to whatever drivers you may have installed as long as they are the most recent ones for your branch.

On Docker hub [virtualgl](https://registry.hub.docker.com/u/yantis/virtualgl/)
on Github [docker-dynamic-nvidia](https://github.com/yantis/docker-virtualgl/)


# Description
The goal of this was a layer between [dynamic-video](https://github.com/yantis/docker-dynamic-video) and graphical applications.
I tested this with Blender, Path of Exile on PlayOnLinux and a few other games and even Steam all on an Amazon EC2.

I have included a [demo script](https://github.com/yantis/docker-virtualgl/blob/master/tools/aws-virtualgl.sh) that will startup an Amazon EC2 Instance, install docker, run the container and 
then connect to your docker container and run glxspheres64 doing all the rendering on the AWS GPU and outputing it on your local display.


# Usage (Server)

The recommended way to run this container looks like this. This example launches the container in the background.
Warning: Do not run this on your primary computer as it will take over your video cards and you will have to shutdown the container
to get them back.

```bash
docker run \
           --privileged \
           -d \
           -v /home/user/.ssh/authorized_keys:/authorized_keys:ro \
           -h docker \
           -p 49154:22 \
           yantis/virtualgl
```

This follows these docker conventions:

* `--privileged` run in privileged mode 
    If you do not want to run in privliged mode you can mess around with these:
    AWS
     ** --device=/dev/nvidia0:/dev/nvidia0 \
     ** --device=/dev/nvidiactl:/dev/nvidiactl \
     ** --device=/dev/nvidia-uvm:/dev/nvidia-uvm \
    OR (Local)
     ** --device=/dev/dri/card0:/dev/dri/card0 \
* `-d` run in daemon mode
* `-h docker` sets the hostname to docker. (not really required but it is nice to see where you are.)
* `-v $HOME/.ssh/authorized_keys:/authorized_keys:ro` Optionaly share your public keys with the host.
    This is particularlly useful when you are running this on another server that already has SSH. Like an 
    Amazon EC2 instance. WARNING: If you don't use this then it will just default to the user pass of docker/docker
    (If you do specify authorized keys it will disable all password logins to keep it secure).

* `-p 49158:22` port that you will be connecting to.
* `yantis/virtualgl` the default mode is SSH server with the X-Server so no need to run any commands.


# Usage (Client)

You will probably want to have VirtualGL installed on your client. On Arch Linux it is:

```bash
pacman -S virtualgl
```
It is basically two programs you need both of which I have included in the tools directory.

* SSH Authentication but data stream is unencrypted (recommended)

```bash
vglconnect -Y docker@hostname -p 49154 -t vglrun glxspheres64
```

* SSH Authentication AND data stream is unencrypted

```bash
vglconnect -Y -s docker@hostname -p 49154 -t vglrun glxspheres64
```

If you are running this remotely (ie: with an Amazon AWS server) You will want to open up port on your firewall
or router to get the best speed out of this.  Otherwise it will use SSH to encrypt the display which will slow it down a good amount.
(I have had varying degrees of success not opening the port when using the SSH method (Sometimes I have to open up the port period to get it to work.)

Check your ports as it doesn't always use 4242 sometimes it uses something else between 4200 and 4300.
If your screen is black or it isn't drawing then that is a good indication that the port is blocked.

![](http://yantis-scripts.s3.amazonaws.com/virtualgl_port_forwarding.png)

vglrun has a lot of tunable parameters. Make sure to check out the manual [here](http://www.virtualgl.org/vgldoc/2_1/)

You should be able to run it with many programs. As an example to use it with [Blender](http://www.blender.org/)

```bash
vglconnect -Y docker@hostname -p 49154
sudo pacman -Sy blender
vglrun blender -noaudio -nojoystick
```

# Screenshots

This is glxspheres64 running on an Amazon GPU EC2 notice the 750+ frames a second.
![](http://yantis-scripts.s3.amazonaws.com/screenshot_20150413-074859.jpg)
