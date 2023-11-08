#!/bin/bash
sudo apt-get update -y 
sudo apt-get install unzip -y
sudo apt-get install libwww-perl libdatetime-perl -y
cd /home/ubuntu/
sudo curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
sudo unzip CloudWatchMonitoringScripts-1.2.1.zip
sudo rm CloudWatchMonitoringScripts-1.2.1.zip
sudo /home/ubuntu/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --disk-space-util --disk-path=/
echo "*/1 * * * * /home/ubuntu/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron" | crontab -