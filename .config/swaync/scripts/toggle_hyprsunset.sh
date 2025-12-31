#!/bin/bash

set +e

if [[ $SWAYNC_TOGGLE_STATE == true ]]; then
    hyprsunset -t 3500
else
    killall -9 hyprsunset
fi

exit 0

# yo make sure you update the config.json for the toggle to be active true