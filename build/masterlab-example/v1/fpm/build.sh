#!/bin/sh

echo ""

echo -e "\nbuild masterlab image\n"
sudo docker build -t masterlab:v1 .


echo ""