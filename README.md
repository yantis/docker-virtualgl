# docker-virtualgl
This is [VirtualGL](http://virtualgl.org) running on docker.
It includes all 32 bit & 64 bit libraries.

It should work out of the box with all Nvidia cards and Nvidia drivers and most other cards as well that use Mesa drivers.
It is setup to auto adapt to whatever drivers you may have installed as long as they are the most recent ones for your branch.

On Docker hub [virtualgl](https://registry.hub.docker.com/u/yantis/virtualgl/)
on Github [docker-virtualgl](https://github.com/yantis/docker-virtualgl/)


## Description
The goal of this was a layer between [dynamic-video](https://github.com/yantis/docker-dynamic-video) and graphical applications.
I tested this with Blender, Path of Exile on PlayOnLinux and a few other games and even Steam all on an Amazon EC2.

In local mode it should just work out of the box. All you should have to do is run [this](https://github.com/yantis/docker-virtualgl/blob/master/runme-local.sh) script

I have included a [demo script](https://github.com/yantis/docker-virtualgl/blob/master/tools/aws-virtualgl.sh) that will startup an Amazon EC2 Instance, install docker, run the container and 
then connect to your docker container and run glxspheres64 doing all the rendering on the AWS GPU and outputing it on your local display.

[Here](https://github.com/yantis/docker-virtualgl/blob/master/tools/remote-virtualgl.sh) is another demo script 
that launches a shell for another machine (ie: on your local network. To use that video card instead of your own 
for whatever application you are using).

Of course you can use this in local mode as well. I find that stuff just works better on my machine running it through vglrun
than without it. If you 


### Docker Images Structure

>[yantis/archlinux-tiny](https://github.com/yantis/docker-archlinux-tiny)
>>[yantis/archlinux-small](https://github.com/yantis/docker-archlinux-small)
>>>[yantis/archlinux-small-ssh-hpn](https://github.com/yantis/docker-archlinux-ssh-hpn)
>>>>[yantis/ssh-hpn-x](https://github.com/yantis/docker-ssh-hpn-x)
>>>>>[yantis/dynamic-video](https://github.com/yantis/docker-dynamic-video)
>>>>>>[yantis/virtualgl](https://github.com/yantis/docker-virtualgl)


## Usage (Local)

This example launches the container and initalizes the graphcs with your drivers and in this case
runs glxspheres64.

```bash
xhost +si:localuser:$(whoami) >/dev/null
docker run \
    --privileged \
    --rm \
    -ti \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -u docker \
    yantis/virtualgl /bin/bash -c "sudo initalize-graphics >/dev/null 2>/dev/null; vglrun glxspheres64;"
```

### Breakdown

```bash
$ xhost +si:localuser:yourusername
```

Allows your local user to access the xsocket. Change yourusername or use $(whoami) or $USER if your shell supports it.

```bash
docker run \
    --privileged \
    --rm \
    -ti \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -u docker \
    yantis/virtualgl /bin/bash -c "sudo initalize-graphics >/dev/null 2>/dev/null; vglrun glxspheres64;"
```

This follows these docker conventions:

* `-ti` will run an interactive session that can be terminated with CTRL+C.
* `--rm` will run a temporary session that will make sure to remove the container on exit.
* `-e DISPLAY` sets the host display to the local machines display.
* `-v /tmp/.X11-unix:/tmp/.X11-unix:ro` bind mounts the X11 socks on your local machine to the containers and makes it read only.
* `-u docker` sets the user to docker. (or you could do root as well)
* `yantis/virtualgl /bin/bash -c "sudo initalize-graphics >/dev/null 2>/dev/null; vglrun glxspheres64;"`
you need to initalize the graphics or otherwise it won't adapt to your graphics drivers and may not work.


## Usage (Remote)

### Server

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
     * --device=/dev/nvidia0:/dev/nvidia0 \
     * --device=/dev/nvidiactl:/dev/nvidiactl \
     * --device=/dev/nvidia-uvm:/dev/nvidia-uvm \

    OR (Local)
     * --device=/dev/dri/card0:/dev/dri/card0 \

* `-d` run in daemon mode
* `-h docker` sets the hostname to docker. (not really required but it is nice to see where you are.)
* `-v $HOME/.ssh/authorized_keys:/authorized_keys:ro` Optionaly share your public keys with the host.
    This is particularlly useful when you are running this on another server that already has SSH. Like an 
    Amazon EC2 instance. WARNING: If you don't use this then it will just default to the user pass of docker/docker
    (If you do specify authorized keys it will disable all password logins to keep it secure).

* `-p 49158:22` port that you will be connecting to.
* `yantis/virtualgl` the default mode is SSH server with the X-Server so no need to run any commands.


### Client

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


## Examples

This is glxspheres64 running on an Amazon GPU EC2 notice the 750+ frames a second.
![](http://yantis-scripts.s3.amazonaws.com/screenshot_20150413-074859.jpg)

You should be able to run it with many programs. As an example to use it with [Blender](http://www.blender.org/)

```bash
vglconnect -Y docker@hostname -p 49154
sudo pacman -Sy blender
vglrun blender -noaudio -nojoystick
```

![](http://yantis-scripts.s3.amazonaws.com/blender_4_13_2015.png)
