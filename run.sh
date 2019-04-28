#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
pb dialog

docker run -e \
    HMAIL1="$(textbox mail1)" -e \
    HPASS1="$(textbox pass1)" -e \
    HAPP1="$(textbox app1)" -e \
    HMAIL2="$(textbox mail2)" -e \
    HPASS2="$(textbox pass2)" -e \
    HAPP2="$(textbox app2)" -e \
    -it paperbenni/heroku
