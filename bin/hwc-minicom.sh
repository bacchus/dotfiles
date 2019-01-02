#!/bin/bash

echo "$(tput setab 3) --- start minicom on ttyUSB0 --- $(tput sgr0)"
sudo minicom -b 115200 -D /dev/ttyUSB0 -c on
