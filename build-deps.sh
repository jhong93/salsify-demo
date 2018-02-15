#!/bin/bash

# Make mahimahi
cd mahimahi
./autogen.sh
./configure
make all
sudo chown root src/frontend/mm-link
sudo chmod 4755 src/frontend/mm-link
cd ..

# Make apprtc
cd apprtc
npm install
grunt build
# Run tests
grunt
cd ..
