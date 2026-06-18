#!/bin/bash

rm -rf "$XDG_CONFIG_HOME/obs-studio/.sentinel" 2>/dev/null || true
exec obs "$@"