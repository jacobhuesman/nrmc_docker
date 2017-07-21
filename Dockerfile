FROM osrf/ros:indigo-desktop-full

#ADD http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_4_0_Linux.tar.gz /root/downloads
ADD /pkgs/V-REP_PRO_EDU_V3_4_0_Linux.tar.gz /root/downloads
RUN mv /root/downloads/V-REP_PRO_EDU_V3_4_0_Linux /root/vrep

RUN apt-get update && apt-get install -y \
    tmux \
    ssh 

ADD /.ssh /root/.ssh
RUN eval "$(ssh-agent -s)" && \
    ssh-add /root/.ssh/id_rsa

RUN cd /root && \
    git clone git@github.com:BisonRobotics/NRMC2018.git

ENV DISPLAY ":0"
ENV QT_X11_NO_MITSHM 1

RUN echo "alias vrep='/root/vrep/vrep.sh'" >> /root/.bashrc

WORKDIR /root


