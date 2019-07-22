#!/usr/bin/env bash
###############################################################
# This automatically balances hours between heroku instances  #
# For questions: paperbenni@gmail.com                         #
###############################################################

cd ~/

source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
pb heroku/login
pb heroku

rm link.txt &>/dev/null
touch link.txt
echo "generating link.txt"

for i in $(seq 20); do

    # example ## mail1@mymail.com:  pass1//appname1,mail1@mymail.com:pass1  //appname
    #         ##
    # example ## $EMAIL1_1       :PASS1_1//APP1_1,EMAIL2_1          :PASS2_1//APP2_1

    CEMAIL1=$(eval 'echo $EMAIL1_'"$i")
    CPASS1=$(eval 'echo $PASS1_'"$i")
    CAPP1=$(eval 'echo $APP1_'"$i")

    CEMAIL2=$(eval 'echo $EMAIL2_'"$i")
    CPASS2=$(eval 'echo $PASS2_'"$i")
    CAPP2=$(eval 'echo $APP2_'"$i")

    echo "doing $i"
    if [ -z "$CEMAIL1" ]; then
        echo "stopped at MAIL $i"
        break
    fi

    echo "$CEMAIL1:$CPASS1//$CAPP1,$CEMAIL2:$CPASS2//$CAPP2" >>link.txt
done

cat link.txt

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
    echo "$PART1"
    echo "$HMAIL1"
    echo "$HPASS1"
    echo "$HAPP1"

    PART2=$(echo "$p" | egrep -o ',.*' | egrep -o '[^,]*')
    HMAIL2=$(echo "$PART2" | egrep -o '.*@.*\..*:' | egrep -o '[^:]*')
    HPASS2=$(echo "$PART2" | egrep -o ':.*//' | egrep -o '[^:/]*')
    HAPP2=$(echo "$PART2" | egrep -o '//.*' | egrep -o '[^/]*')
    echo "$PART2"
    echo "$HMAIL2"
    echo "$HPASS2"
    echo "$HAPP2"

    echo "starting login processes"

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
