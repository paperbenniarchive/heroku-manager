#!/usr/bin/env bash

cd ~/

source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
pb heroku/login
pb heroku

if [ -z $HLINK ]; then
    echo "point \$HLINK to a valid text file"
    sleep 1m
    exit
fi

curl "$HLINK" >~/link.txt

while read p; do
    # example syntax:
    ## mail1@mymail.com:pass1//appname1,mail1@mymail.com:pass1//appname1
    if ! (echo "$p" | egrep '.*@.*\..*:.*//.*,.*@.*\..*:.*//.*'); then
        echo "$p has invalid syntax"
    fi

    #filter required vars out of the file
    PART1=$(echo "$p" | egrep -o '.*,' | egrep -o '[^,]*')
    HMAIL1=$(echo "$PART1" | egrep -o '.*@.*\..*:' | egrep -o '[^:]*')
    HPASS1=$(echo "$PART1" | egrep -o ':.*//' | egrep -o '[^:/]*')
    HAPP1=$(echo "$PART1" | egrep -o '//.*' | egrep -o '[^/]*')

    PART2=$(echo "$p" | egrep -o ',.*' | egrep -o '[^,]*')
    HMAIL2=$(echo "$PART2" | egrep -o '.*@.*\..*:' | egrep -o '[^:]*')
    HPASS2=$(echo "$PART2" | egrep -o ':.*//' | egrep -o '[^:/]*')
    HAPP2=$(echo "$PART2" | egrep -o '//.*' | egrep -o '[^/]*')

    hlogin "$HMAIL1" "$HPASS1"
    HTIME1=$(htime "$HAPP1")

    if echo "$HTIME1" | egrep '[0-9]{3}'; then
        echo "$HMAIL1 fully used, changing to $HMAIL2"
        sleep 5
        heroku ps:scale web=0 -a "$HAPP1"
        sleep 1
        hlogin "$HMAIL2" "$HPASS2"
        heroku ps:scale web=1 -a "$HAPP2"
    else
        echo "account 1 still going"
        heroku ps:scale web=1 -a "$HAPP1"
        sleep 2
        hlogin "$HMAIL2" "$HPASS2"
        heroku ps:scale web=0 -a "$HAPP2"
    fi

done <~/link.txt
