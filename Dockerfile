# Start with ros kinetic image
FROM osrf/ros:kinetic-desktop-full


# Get VREP
# TODO figure out a way to make this go faster
#ADD http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_4_0_Linux.tar.gz /root/downloads
ADD /pkgs/V-REP_PRO_EDU_V3_4_0_Linux.tar.gz /root/downloads
RUN mv /root/downloads/V-REP_PRO_EDU_V3_4_0_Linux /root/vrep


# Add utilities
RUN apt-get update && apt-get install -y \
    tmux \
    ssh \
    vim


# Configure git
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs
COPY .gitconfig /root/.gitconfig


# Configure ssh
ADD /.ssh /root/.ssh
RUN eval "$(ssh-agent -s)" && \
    ssh-add /root/.ssh/id_rsa


# Configure clion
ADD /pkgs/clion-settings.tar.gz /root
ADD /pkgs/clion-java-settings.tar.gz /root

# Clone scripts directory (contains clion formatting settings)
RUN cd /root && \
    git clone git@github.com:jacobhuesman/scripts.git

# Install gmock
RUN apt-get update && apt-get install -y google-mock

# Build gmock
RUN cd /usr/src/gmock && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make

# Install clang
RUN apt-get update && apt-get install -y clang-format-3.6

# Clone NRMC repo, install dependencies, make it, and link custom vrep library to vrep
RUN cd /root && \
    git clone git@github.com:BisonRobotics/NRMC2018.git && \
    cd NRMC2018 && \
    git checkout vrep && \
    git submodule update --init --recursive

RUN . /opt/ros/kinetic/setup.sh && \
    cd /root/NRMC2018 && \
    rosdep update && \
    rosdep install --from-paths . --ignore-src --rosdistro=kinetic --default-yes; exit 0


RUN . /opt/ros/kinetic/setup.sh && \
    cd /root/NRMC2018 && \
    catkin_make

RUN ln -s /root/NRMC2018/devel/lib/libv_repExtRosInterface.so /root/vrep/


# Configure display
ENV DISPLAY ":0"
ENV QT_X11_NO_MITSHM 1


# Add helpful shortcuts
RUN echo "alias vrep='/root/vrep/vrep.sh'"                    >> /root/.bashrc && \
    echo "alias clion='/root/clion/bin/clion.sh'"             >> /root/.bashrc && \
    echo "alias ws='cd /root/NRMC2018'"                       >> /root/.bashrc && \
    echo "alias wss='source /root/NRMC2018/devel/setup.bash'" >> /root/.bashrc 


WORKDIR /root


