#!/bin/bash

VIDEO_FILE='tmp.vp8'

HOSTNAME=$(hostname)
echo "HOSTNAME=$HOSTNAME"

# Enable IP forwarding for mahi-mahi
sudo sysctl -w net.ipv4.ip_forward=1

# Make 2 virtual webcams
sudo modprobe v4l2loopback exclusive_caps=1 devices=2

# Start ffmpeg
ffmpeg -re -i $VIDEO_FILE -f v4l2 /dev/video1 -f v4l2 /dev/video2 &

# Write mahimahi static file
python3 mahimahi/py/mm-static.py --mbps 12

# Start mahimahi interactive controller
MIDI_PORT=1
python3 mahimahi/py/mm-interactive.py -m $MIDI_PORT --max 3 --no-ui

# Start apprtc server
GCLOUD_SDK_ROOT=$(gcloud info --format="value(installation.sdk_root)")
echo "GCLOUD_SDK_ROOT=$GCLOUD_SDK_ROOT"
DEV_APP_SERVER="$GCLOUD_SDK_ROOT/bin/dev_appserver.py"
$DEV_APP_SERVER apprtc/out/app_engine &

# Start chrome (webrtc sender)
SENDER_TMP_DIR='/tmp/chrome-webrtc-sender'
rm -rf $SENDER_TMP_DIR
google-chrome "http://localhost:8080" --disable-gpu --user-data-dir=$SENDER_TMP_DIR

# Start chrome (webrtc receiver) behind mahimahi
RECEIVER_TMP_DIR='/tmp/chrome-webrtc-receiver'
rm -rf $RECEIVER_TMP_DIR
google-chrome "http://$HOSTNAME:8080" --disable-gpu --unsafely-treat-insecure-origin-as-secure="http://$HOSTNAME:8080" --user-data-dir=$RECEIVER_TMP_DIR

# Start salsify sender



# Start salsify receiver behind mahimahi
