#!/bin/bash

killall -9 swaync
swaync -s /home/austin/.config/swaync/style.css -c /home/austin/.config/swaync/config.json &