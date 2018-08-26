# Dockerfile for working GStreamer w/OMX

Based on `debian:buster` image. Builds a copy of `gst-omx` and integrates it into the system GStreamer.

Example usage:

```
docker run -it --rm --device=/dev/vchiq mmastrac/gst-omx-rpi:latest \
    gst-launch-1.0 rtspsrc location="rtsp://address-of-source" latency=0 !\
    rtph264depay ! h264parse ! omxh264dec !\
    omxh264enc target-bitrate=500000 control-rate=1 ! video/x-h264, profile=baseline !\
    h264parse ! rtph264pay name=pay0 config-interval=1 pt=96 ! udpsink host=ip-of-sink port=8004 sync=false
```

Embed some overlays on the decoded H264 stream:

```
docker run -it --rm --device=/dev/vchiq mmastrac/gst-omx-rpi:latest \
    gst-launch-1.0 rtspsrc location="rtsp://address-of-source" latency=0 !\
    rtph264depay ! h264parse ! omxh264dec ! videorate !\
    textoverlay text="Front" valignment=top halignment=left font-desc="Sans, 16" !\
    clockoverlay halignment=right valignment=bottom font-desc="Sans, 12" !\
    omxh264enc target-bitrate=500000 control-rate=1 ! video/x-h264, profile=baseline !\
    rtph264pay name=pay0 config-interval=1 pt=96 ! udpsink host=ip-of-sink port=8004
```
