#!/bin/bash

killall -9 quickshell 2>/dev/null || true
sleep 0.15
quickshell --daemonize --path "$HOME/.config/quickshell/shell.qml"
