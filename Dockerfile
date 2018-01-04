# Docker image for react native.

FROM node:8.5

MAINTAINER Maxime Demolin <akbarova.armia@gmail.com>


# Setup environment variables
ENV PATH $PATH:node_modules/.bin


# Install Java
RUN apt-get update -q && \
	apt-get install -qy --no-install-recommends python-dev default-jdk


# Install Android SDK

## Set correct environment variables.
ENV ANDROID_SDK_FILE android-sdk_r24.4.1-linux.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/$ANDROID_SDK_FILE

## Install 32bit support for Android SDK
RUN dpkg --add-architecture i386 && \
    apt-get update -q && \
    apt-get install -qy --no-install-recommends libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386


## Install SDK
ENV ANDROID_HOME /usr/local/android-sdk-linux
RUN cd /usr/local && \
    wget $ANDROID_SDK_URL && \
    tar -xzf $ANDROID_SDK_FILE && \
    export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools && \
    chgrp -R users $ANDROID_HOME && \
    chmod -R 0775 $ANDROID_HOME && \
    rm $ANDROID_SDK_FILE

# Install android tools and system-image.
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/23.0.1
RUN (while true ; do sleep 5; echo y; done) | android update sdk --no-ui --force --all --filter platform-tools,android-23,build-tools-23.0.1,extra-android-support,extra-android-m2repository,sys-img-x86_64-android-23,extra-google-m2repository


# Install node modules

## Install yarn
RUN npm install -g yarn

## Install react native
RUN npm install -g react-native-cli@1.0.0

## Clean up when done
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install watchman
RUN git clone https://github.com/facebook/watchman.git
RUN cd watchman && git checkout v4.7.0 && ./autogen.sh && ./configure && make && make install
RUN rm -rf watchman

# Default react-native web server port
EXPOSE 8081


# User creation
ENV USERNAME dev

RUN adduser --disabled-password --gecos '' $USERNAME


# Add Tini
ENV TINI_VERSION v0.10.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
RUN apt-get update && apt-get install vim -y
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
  tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
  tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN (while true ; do sleep 5; echo y; done) | apt-get install oracle-java8-installer -y
RUN (while true ; do sleep 5; echo y; done) | android update sdk --no-ui --force --all --filter android-26,build-tools-26.0.1
RUN (while true ; do sleep 5; echo y; done) | android update sdk --no-ui --force --all --filter android-25,build-tools-25.0.2
USER $USERNAME
# Set workdir
# You'll need to run this image with a volume mapped to /home/dev (i.e. -v $(pwd):/home/dev) or override this value
WORKDIR /home/$USERNAME/app

# Tell gradle to store dependencies in a sub directory of the android project
# this persists the dependencies between builds
ENV GRADLE_USER_HOME /home/$USERNAME/app/android/gradle_deps

ENTRYPOINT ["/tini", "--"]
