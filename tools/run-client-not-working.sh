# This doesn't work yet. It connects and appears to work but nothing gets displayed.
# Then it basically locks up. Even if you shutdown all docker containers on the host
# and the client.
#
# This was my attempt at trying to run it from the container.
# and it was not successful. 

xhost +si:localuser:$(whoami)
docker run \
  -ti \
  -e DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v ~/.ssh/yantisec2.pem:/home/docker/.ssh/yantisec2.pem:ro \
  -u docker \
  --expose=1-65535 \
  yantis/virtualgl vglconnect -Y -i /home/docker/.ssh/yantisec2.pem -o StrictHostKeyChecking=no  docker@hermes -p 49154 vglrun gxlspheres64

  # use SSH for image stream.
  # yantis/virtualgl vglconnect -sY -i /home/docker/.ssh/yantisec2.pem -o StrictHostKeyChecking=no  docker@hermes -p 49154 vglrun gxlspheres64

  # this works.
  # yantis/virtualgl ssh -Y -i /home/docker/.ssh/yantisec2.pem -o StrictHostKeyChecking=no  docker@hermes -p 49154 -t xeyes
