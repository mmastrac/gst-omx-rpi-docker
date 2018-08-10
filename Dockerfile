FROM debian:buster
ARG FFMPEG_VERSION=4.0.2

RUN echo "Building FFMPEG (${FFMPEG_VERSION})"

# Setup
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -qq install build-essential cmake cmake-data curl git libomxil-bellagio-dev libx264-dev pkg-config sudo xz-utils

# Build rpi userland
WORKDIR "/root"
RUN git clone --depth 1 https://github.com/raspberrypi/userland.git
WORKDIR "/root/userland"
RUN ./buildme

# Required to link deps
RUN echo "/opt/vc/lib" > /etc/ld.so.conf.d/00-vmcs.conf
RUN ldconfig

# Install gstreamer deps
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -qq install gstreamer1.0-plugins-*
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -qq install libgstreamer-plugins-base1.0-dev

RUN curl -o gst-omx.tar.xz https://gstreamer.freedesktop.org/src/gst-omx/gst-omx-1.14.2.tar.xz
RUN tar xf gst-omx.tar.xz
WORKDIR gst-omx-1.14.2
RUN ./configure --with-omx-target=rpi CFLAGS="-I/opt/vc/include/IL -I/opt/vc/include" LDFLAGS="-L/opt/vc/lib"
RUN make

# Manual install
RUN make install
RUN cp ./omx/.libs/libgstomx.so /usr/lib/arm-linux-gnueabi/gstreamer-1.0/
