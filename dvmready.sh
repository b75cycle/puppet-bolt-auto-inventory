#!/bin/bash
# This program is free to use.  Nothing script is nothing more than editing files using linux commands
# In this script we are creating individual Puppet Bolt group_name.yaml files to be referenced
# from inventory.yaml via a yaml plugin reference.
#
# Created by:  Brian K Obendorfer
#
#
#
#NEED TO SET THE PATH BELOW SO THAT WE CAN CALL THIS SCRIPT IN CRON
# YOU WILL NEED TO SET FULL FILE PATHS TO THE FILE AS WELL IN EACH STEP OF THE SCRIPT IF YOU ARE USING IT IN CRON
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/ec2-user/.local/bin:/home/ec2-user/bin: ##plus add directory of bolt project

# EXTRACTING THE FILE FROM FMG diag dvm list
# PUTTING IT INTO A TXT FILE AND SETTING THE CASE OF ALL TEXT FROM UPPER CASE TO LOWERCASE
# THE FILE IS CREATED BY RUNNING AN EXTRACT IN BOLT FROM THE FMG
# DIAG DVM DEVICE LIST
cat fortigates.txt |tr '[:upper:]' '[:lower:]' | grep fmg > siteinfo.txt

#READING THE TXT FILE JUST CREATED AND PRINTING INT INTO A CSV FILE THAT IS A MASTER LIST
awk '{ print systime(),$5,$6,$7,$12,substr($3, 1,length($3)-11)}' siteinfo.txt > siteinfo2.csv

#REPLACING ALL (###) CODES WHICH REPRESENT FORTINET CODE REVISIONS IN SITEINFO2.CSV
sed -i -e 's/(303)/6.0.8/g' -e 's/(231)/6.0.4/g' -e 's/(272)/6.0.6/g' -e 's/(268)/6.0.5/g' -e 's/(1010)/6.2.2/g' -e 's/(1142)/6.2.5/g' -e 's/(1112)/6.2.4/g'  -e 's/(163)/6.0.2/g' -e 's/(6325)/6.0.6/g' -e 's/(6664)/6.0.9/g' -e 's/(1803)/6.4.4/g' -e 's/(335)/6.0.9/g' -e 's/(6187)/unknown/g' -e 's/(387)/unknown/g' siteinfo2.csv

#TAKING A FREAKING BREAK
sleep 1

##HERE WE ARE READING THE MASTER FILE CREATED ABOVE VIA AWK SEARCHING FOR EACH ADOM.
##NEXT WITH INVEN.AWK WHICH IS COPIED BELOW AS WELL WE ARE NOW PUTTING THE ROWS IF INFORMATION INTO A FORMAT THAT BOLT CAN USE WITHIN AN INVENTORY FILE
## The completion of the below steps create adom.yaml (for Fortinet reference) but in Puppet Bolt terms it is (group_name.yaml)
awk '$4 ~ /root/ {print $1,$2,$3,$4,$5,$6,"\n"}' siteinfo2.csv > root.csv
awk -f inven.awk root.csv > root.yaml
awk '$4 ~ /corp/ {print $1,$2,$3,$4,$5,$6,"\n"}' siteinfo2.csv > corp.csv
awk -f inven.awk corp.csv > corp.yaml
awk '$4 ~ /field/ {print $1,$2,$3,$4,$5,$6,"\n"}' siteinfo2.csv > field.csv
awk -f inven.awk field.csv > field.yaml
