FROM ros:melodic

ENV ROS_DISTRO melodic

RUN apt -q -qq update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    software-properties-common \
    wget \
    apt-transport-https

RUN apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
RUN add-apt-repository -y "deb https://librealsense.intel.com/Debian/apt-repo xenial main"
RUN apt-get update -qq

RUN apt -q -qq update && \
  DEBIAN_FRONTEND=noninteractive apt install -y --allow-unauthenticated \
  python-rosinstall \
  python-catkin-tools

RUN apt install -y libeigen3-dev libpcl-dev ros-melodic-rviz vim git ros-melodic-pcl-ros ros-melodic-eigen-conversions

RUN apt install -y sudo

ARG USERNAME=user
ARG GROUPNAME=user
ARG UID=1000
ARG GID=1000
ARG PASSWORD=user
RUN groupadd -g $GID $GROUPNAME && \
    useradd -m -s /bin/bash -u $UID -g $GID -G sudo $USERNAME && \
    echo $USERNAME:$PASSWORD | chpasswd && \
    echo "$USERNAME   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME/


RUN git clone https://github.com/Livox-SDK/Livox-SDK.git
RUN cd Livox-SDK/build && cmake .. && make && sudo make install

RUN git clone https://github.com/Livox-SDK/livox_ros_driver.git ws_livox/src
RUN /bin/bash -c 'source /opt/ros/melodic/setup.bash && cd ws_livox && catkin_make'


RUN sudo apt install ros-melodic-cv-bridge ros-melodic-geodesy ros-melodic-nmea-msgs \
                      ros-melodic-tf-conversions ros-melodic-libg2o ros-melodic-xacro ros-melodic-robot-state-publisher \
                      ros-melodic-robot-localization

#RUN sudo add-apt-repository ppa:borglab/gtsam-release-4.0 && sudo apt update && \
#            sudo apt install libgtsam-dev libgtsam-unstable-dev

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN echo "source /home/user/ws_livox/devel/setup.bash" >> ~/.bashrc
RUN echo "export XDG_RUNTIME_DIR=/tmp/runtime-user" >> ~/.bashrc

#COPY ./ros_entrypoint.sh /
#ENTRYPOINT ["/ros_entrypoint.sh"]