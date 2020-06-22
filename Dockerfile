FROM debian:bullseye

# Setup
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -qq install build-essential cmake cmake-data curl git libomxil-bellagio-dev libx264-dev pkg-config sudo xz-utils

# Build rpi userland
WORKDIR "/root"
RUN git clone https://github.com/raspberrypi/userland.git
WORKDIR "/root/userland"
RUN git checkout f74ea7fdef9911904e269127443cd8a608abeacc
# https://github.com/raspberrypi/userland/issues/582
RUN sed -i 's/__bitwise/FDT_BITWISE/' opensrc/helpers/libfdt/libfdt_env.h
RUN sed -i 's/__force/FDT_FORCE/' opensrc/helpers/libfdt/libfdt_env.h
RUN ./buildme

# Required to link deps
RUN echo "/opt/vc/lib" > /etc/ld.so.conf.d/00-vmcs.conf
RUN ldconfig

# Install gstreamer deps
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -qq install gstreamer1.0-plugins-*
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -qq install libgstreamer-plugins-base1.0-dev

ARG GST_OMX_VERSION=1.15.90
RUN echo "Building gst-omx (${GST_OMX_VERSION})"

RUN curl -o gst-omx.tar.xz https://gstreamer.freedesktop.org/src/gst-omx/gst-omx-${GST_OMX_VERSION}.tar.xz
RUN tar xf gst-omx.tar.xz
WORKDIR gst-omx-${GST_OMX_VERSION}
RUN ./configure --with-omx-target=rpi CFLAGS="-I/opt/vc/include/IL -I/opt/vc/include" LDFLAGS="-L/opt/vc/lib"
RUN make

# Manual install
# Note that certain versions use gnueabihf and some use gnueabi
RUN make install
RUN cp ./omx/.libs/libgstomx.so /usr/lib/arm-linux-gnueabihf/gstreamer-1.0/ \
	|| cp ./omx/.libs/libgstomx.so /usr/lib/arm-linux-gnueabi/gstreamer-1.0/
