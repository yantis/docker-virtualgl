############################################################
# Copyright (c) 2015 Jonathan Yantis
# Released under the MIT license
############################################################

# ├─yantis/archlinux-tiny
#    ├─yantis/archlinux-small
#       ├─yantis/archlinux-small-ssh-hpn
#          ├─yantis/ssh-hpn-x
#             ├─yantis/dynamic-video
#                ├─yantis/virtualgl

FROM yantis/dynamic-video
MAINTAINER Jonathan Yantis <yantis@yantis.net>

# Don't update
RUN pacman -Syy --noconfirm && \

    # Install remaining packages
    pacman --noconfirm -S \
                inetutils \
                libxv \
                virtualgl \
                lib32-virtualgl \
                mesa-demos \
                lib32-mesa-demos && \

    # Fix VirtualGL for this hardcoded directory otherwise we can not connect with SSH.
    mkdir /opt/VirtualGL && \
    ln -s /usr/bin /opt/VirtualGL && \

    # Force VirtualGL to be preloaded into setuid/setgid executables (do not do if security is an issue)
    # chmod u+s /usr/lib/librrfaker.so && chmod u+s /usr/lib64/librrfaker.so && \

    ##########################################################################
    # CLEAN UP SECTION - THIS GOES AT THE END                                #
    ##########################################################################
    localepurge && \

    # Remove man and docs
    rm -r /usr/share/man/* && \
    rm -r /usr/share/doc/* && \

    # Delete any backup files like /etc/pacman.d/gnupg/pubring.gpg~
    find /. -name "*~" -type f -delete && \

    bash -c "echo 'y' | pacman -Scc >/dev/null 2>&1" && \
    paccache -rk0 >/dev/null 2>&1 &&  \
    pacman-optimize && \
    rm -r /var/lib/pacman/sync/*
    #########################################################################

CMD /init
# ADD demos.sh /home/docker/demos.sh
