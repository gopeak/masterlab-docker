#!/bin/bash

echo ""

echo -e "\nbuild masterlab_db image\n"
sudo docker build -t gopeak/masterlab_db:dev .


echo ""