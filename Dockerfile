FROM osrf/ros:kinetic-desktop-full

#ADD http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_4_0_Linux.tar.gz /root/downloads
ADD /pkgs/V-REP_PRO_EDU_V3_4_0_Linux.tar.gz /root/downloads
RUN mv /root/downloads/V-REP_PRO_EDU_V3_4_0_Linux /root/vrep

RUN apt-get update && apt-get install -y \
    tmux \
    ssh \
    vim

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs

COPY .gitconfig /root/.gitconfig

ADD /.ssh /root/.ssh
RUN eval "$(ssh-agent -s)" && \
    ssh-add /root/.ssh/id_rsa

RUN cd /root && \
    git clone git@github.com:BisonRobotics/NRMC2018.git

RUN . /opt/ros/kinetic/setup.sh && \
    cd /root/NRMC2018 && \
    git checkout vrep && \
    catkin_make

RUN ln -s /root/NRMC2018/devel/lib/libv_repExtRosSkeleton.so /root/vrep/

ENV DISPLAY ":0"
ENV QT_X11_NO_MITSHM 1

RUN echo "alias vrep='/root/vrep/vrep.sh'"                    >> /root/.bashrc && \
    echo "alias clion='/root/clion/bin/clion.sh'"             >> /root/.bashrc && \
    echo "alias ws='cd /root/NRMC2018'"                       >> /root/.bashrc && \
    echo "alias wss='source /root/NRMC2018/devel/setup.bash'" >> /root/.bashrc 

WORKDIR /root


