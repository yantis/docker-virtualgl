#!/bin/bash

# Clean out our known hosts file since we discard output and won't know if a problem.
rm -f /home/user/.ssh/known_hosts

# Test Nvidia & Test 64 bit ones
nohup vglconnect -o StrictHostKeyChecking=no -Y docker@hermes -p 49154 -t vglrun glxgears > /dev/null 2>&1 &
nohup vglconnect -o StrictHostKeyChecking=no -Y docker@hermes -p 49154 -t vglrun glxspheres64 > /dev/null 2>&1 &
nohup vglconnect -o StrictHostKeyChecking=no -Y docker@hermes -p 49154 -t vglrun glxheads > /dev/null 2>&1 &

# Test Mesa & 32 bit ones
nohup vglconnect -o StrictHostKeyChecking=no -Y docker@loki -p 49154 -t vglrun glxgears32 > /dev/null 2>&1 &
nohup vglconnect -o StrictHostKeyChecking=no -Y docker@loki -p 49154 -t vglrun glxspheres32 > /dev/null 2>&1 &
nohup vglconnect -o StrictHostKeyChecking=no -Y docker@loki -p 49154 -t vglrun glxheads32 > /dev/null 2>&1 &
