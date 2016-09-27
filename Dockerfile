FROM ubuntu:14.04

RUN sudo apt-get update

# Install Java7
RUN apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer

# Install Deps
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --force-yes expect git wget unzip libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl && \
    apt-get clean

# Install Android SDK
ENV GRADLE_VERSION=2.14.1 \
    ANDROID_SDK_VERSION=r24.4.1 \
    ANDROID_BUILD_TOOLS_VERSION=24.0.2 \
    ANDROID_API_LEVELS=android-24

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip && \
    unzip gradle-${GRADLE_VERSION}-all.zip && \
    mv gradle-${GRADLE_VERSION} /opt/ && \
    rm gradle-${GRADLE_VERSION}-all.zip

ENV GRADLE_HOME /opt/gradle-${GRADLE_VERSION} 
ENV PATH ${PATH}:${GRADLE_HOME}/bin

RUN cd /opt && \
    wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_${ANDROID_SDK_VERSION}-linux.tgz && \
    tar xzf android-sdk.tgz && \ 
    rm -f android-sdk.tgz && \
    rm -rf /opt/android-sdk-linux/temp \
    chown -R root.root android-sdk-linux

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN echo y | android update sdk --no-ui -a --filter tools,platform-tools,${ANDROID_API_LEVELS},build-tools-${ANDROID_BUILD_TOOLS_VERSION},extra-android-support,extra-android-m2repository,extra-google-m2repository

