<?php
   $redis = new Redis();
   $redis->connect('172.24.0.102', 6379);
   echo "Connection to server sucessfully";
   echo "Server is running: " . $redis->ping();