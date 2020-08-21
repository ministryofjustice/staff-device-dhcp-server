#! /bin/bash
regex="(received packets: +[1-9])"
packet_output=$(perfdhcp -r 10 -n 10 172.1.0.3 | grep "received packets")

if [[ $packet_output =~ $regex ]]; then
    printf "\nSuccess! Packets where received\n\n"
else
    printf "\nFail - No packets sent\n\n"
fi