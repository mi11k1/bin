#!/bin/bash
export DISPLAY=:1
 Xvfb :1 -screen 0 1024x768x16 &
 fluxbox &
 x11vnc -display :1 -bg -nopw -listen localhost -xkb
