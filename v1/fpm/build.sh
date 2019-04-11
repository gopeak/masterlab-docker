#!/bin/sh

echo ""

echo -e "\nbuild masterlab:fpm image\n"
sudo docker build -t masterlab:fpm .


echo ""