#!/bin/bash  
  
# Read the user input   
cd /home/mi11k1/Videos 
echo "Enter the URL:"  
read URL
echo  
youtube-dl --merge-output-format mkv $URL
