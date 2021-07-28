#!/bin/bash
# This program is free to use.  We are doing nothing more than editing files using linux commands
# In this script we are creating individual Puppet Bolt group_name.yaml files but then inserting
# each of the files into a specific point in the Puppet Bolt inventory.yaml file
#
#
#
# Created by:  Brian K Obendorfer
#
#
#NEEDED TO SET THE PATH BELOW SO THAT WE CAN CALL THIS SCRIPT IN CRON
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/ec2-user/.local/bin:/home/ec2-user/bin:/home/ec2-user/files/fortinet/boltyaml:/home/ec2-user/fortinet

# EXTRACTING THE FILE FROM FMG AND PUTTING IT INTO A TXT FILE AND SETTING THE CASE OF ALL TEXT FROM UPPER CASE TO LOWERCASE
# THE FILE IS CREATED BY RUNNING AN EXTRACT IN BOLT FROM THE FMG
cat fortigates.txt |tr '[:upper:]' '[:lower:]' | grep fmg > siteinfo.txt

#READING THE FILE AND PRINTING INT INTO A CSV FILE THAT IS A MASTER LIST
awk '{ print systime(),$5,$6,$7,$12,substr($3, 1,length($3)-11)}' siteinfo.txt > siteinfo2.csv

#REPLACING ALL (###) CODES WHICH REPRESENT FORTINET CODE REVISIONS IN SITEINFO2.CSV
# You will need to access Fortinet Downloads to confirm the rev numbers within (###) to convert to the more common rev code of 6.x.x or 7.x.x
sed -i -e 's/(303)/6.0.8/g' -e 's/(231)/6.0.4/g' -e 's/(272)/6.0.6/g' -e 's/(268)/6.0.5/g' -e 's/(1010)/6.2.2/g' -e 's/(1142)/6.2.5/g' -e 's/(1112)/6.2.4/g'  -e 's/(163)/6.0.2/g' -e 's/(6325)/6.0.6/g' -e 's/(6664)/6.0.9/g' -e 's/(1803)/6.4.4/g' -e 's/(335)/6.0.9/g' -e 's/(6187)/unknown/g' -e 's/(387)/unknown/g' /siteinfo2.csv

#TAKING A FREAKING BREAK
sleep 1

##HERE WE ARE READING THE MASTER FILE CREATED ABOVE AND "GREPING" VIA AWK FOR EACH ADOM.
##NEXT WITH BCINVEN.AWK WHICH IS COPIED BELOW AS WELL WE ARE NOW PUTTING THE ROWS IF INFORMATION INTO A FORMAT THAT BOLT CAN USE WITHIN AN INVENTORY FILE
##  * NOTE THAT THE group_name.csv FILES IN NEXT SECTION WAS CREATED WITH DVMREADY.SH SCRIPT  **NEED TO CALL THIS OUT BECAUSE I HAVE 2 BOLT PROJECTS AND DIDN'T NEED
##  * TO DUPLICATE MULTIPLE FILES

awk -f bcinven.awk root.csv  > root.yaml
awk -f bcinven.awk corp.csv > corp.yaml
awk -f bcinven.awk field.csv > field.yaml


# adding targets: to the top of each of the awk'd files above
# this is needed because in the next step we will take the files and insert them into 
# an inventory.yaml file that will now not require someone to edit
sed -i '1s/^/    targets:\n/' root.yaml
sed -i '1s/^/    targets:\n/' corp.yaml
sed -i '1s/^/    targets:\n/' field.yaml



# This is what we are going to use to insert the awk'd files above and then generate an inventory.yaml from each of the files above
# First line takes the template for inventory and then creates the inventory.yamlfile
sed -e '0,/adom: root/{/adom: root/r root.yaml' -e '}' bcinv.yaml > inventory.yaml

# Remainder lines then replace the contents inline using -i at the front of the sed command
sed -i -e '0,/adom: corp/{/adom: corp/r corp.yaml' -e '}' inventory.yaml
sed -i -e '0,/adom: field/{/adom: field/r field.yaml' -e '}' inventory.yaml


# Copying the inventory.yaml file from this directory into boltconnect directory 
# After copying we will remove inventory.yaml so that the next automation doesn't
# create double entries of the inventory
cp inventory.yaml /myboltproject/inventory.yaml
rm -f inventory.yaml






# old version but keeping here for knowledge
#awk '$4 ~ /cng-scada/ {print $1,$2,$3,$4,$5,$6,"\n"}' /home/ec2-user/files/fortinet/boltyaml/siteinfo2.csv > /home/ec2-user/files/fortinet/boltyaml/cngscadainventory.csv
#awk -f /home/ec2-user/files/fortinet/boltyaml/inven.awk /home/ec2-user/files/fortinet/boltyaml/cngscadainventory.csv > /home/ec2-user/fortinet/adomyaml/cngscada.yaml
# awk '{print uri$2,"\n",gate$3,"\n",facts,"\n",model$6,"\n",os$5; uri="     - uri: "; gate="    alias: "; facts="          facts:"; os="        os: ";model="        hardware: " } END{print ""}' tier0.csv > tier0inventory.yaml



#bcinven.awk PUTS THE CSV FILE INTO THE FORMAT NEEDED FOR INVENTORY
# creating an inventory for bolt
#BEGIN {RS= ""; FS=" "}
#{
#    print "     - uri: ",$2 
#     print "       alias: ", $3 
#     print "       facts:", ""
#     print "         adom:",$4
#     print "         hardware: ", $6
#     print "         os: ", $5
#}
