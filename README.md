# Dockerfile for working GStreamer w/OMX

Based on `debian:buster` image. Builds a copy of `gst-omx` and integrates it into the system GStreamer.

Example usage:

```
docker run -it --rm --device=/dev/vchiq mmastrac/gst-omx-rpi-docker
:latest \
    gst-launch-1.0 rtspsrc location="rtsp://username:password@ip-of-source:554/cam/realmonitor?channel=1&subtype=0" latency=0 ! rtph264depay ! h264parse ! omxh264dec ! omxh264enc target-bitrate=500000 control-rate=1 ! video/x-h264, profile=baseline ! h264parse ! rtph264pay name=pay0 config-interval=1 pt=96 ! udpsink host=ip-of-sink port=8004 sync=false
```

