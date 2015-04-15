docker build -t yantis/virtualgl .

docker run \
  --privileged \
  -ti \
  --rm \
  -v /home/user/.ssh/authorized_keys:/authorized_keys:ro \
  -h docker \
  -p 49154:22 \
  yantis/virtualgl

# You can mess with these if you do not want to use privileged.
# AWS
#  --device=/dev/nvidia0:/dev/nvidia0 \
#  --device=/dev/nvidiactl:/dev/nvidiactl \
#  --device=/dev/nvidia-uvm:/dev/nvidia-uvm \
# OR
# --device=/dev/dri/card0:/dev/dri/card0 \
