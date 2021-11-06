#!/bin/bash

swift build --product agamotto -c release

PATH_TO_BIN="$(swift build --show-bin-path -c release)/agamotto"

sudo install "$PATH_TO_BIN" /usr/local/bin