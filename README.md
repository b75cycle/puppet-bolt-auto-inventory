# puppet-bolt-auto-inventory
The scripts within this repo will allow you to generate targets for a Puppet Bolt inventory in two methods.  One option is to use a yaml plugin and the second is to directly insert targets into the inventory.yaml file for Puppet Bolt

WARNING- I am a network engineer and not a full time developer.  Yes, you probably can do this in other languages, make it cleaner, but you are welcome for the leg work completed to auto populate your Puppet Bolt inventory files. 

If you use another languange to generate the file based off of this set of scripts please share it

OVERVIEW:
The main goal of this project is to demonstrate how to populate an inventory.yaml in puppet bolt using an extract from Fortinet’s FortiManager(FMG) to create an inventory file for Puppet Bolt.  The initial tasks in the bash scripts are focused on FMG “diag dvm device list”  but once the data from that extract is massaged the results are manipulated into the creation of files to use a yaml plugin or direct entry into Puppet Bolt inventory.yaml file. 

LANGUAGE:  BASH, AWK, SED

Common Files:
fmgdevicelist.sh - I was tired of typing out an entire bolt string to extract the Fortigates from FMG

fortigates.txt - Raw extract from FMG “ diagnose dvm device list”

siteinfo.txt -  File created by dvmready.sh script that is one of the first steps to filter fortigates.txt

siteinfo2.csv - This is the list that is utilized to populate the target information directly in inventory.yaml or referenced using a Bolt yaml plugin in inventory.yaml.  
                Space separated file in the following format of: epoch ip_address host_name adom code_rev hardware_type

OPTION 1:
Reference files using a yaml plugin from the Puppet Bolt inventory.yaml file.

Files
dvmready.sh - Bash script that does all of the work to create yaml files that are referenced via a yaml plugin in inventory.yaml
                        This bash script will generate a few files as well.
                        
inventoryplugin.yaml - Sample inventory with yaml plugin


OPTION 2:  (Requires Option1 to be run first)
Insert files (yaml) that contain the necessary components of Puppet Bolt “targets:”

Files
bcdvm.sh - Bash script that does all of the work to insert targets directly into an inventory.yaml file
                   This script is dependent upon Option 1 completing first because there are files generated in dvmready.sh that are referenced in this script.
                   
bcinven.awk - Awk format that places hosts in the appropriate yaml format of a specific inventory.yaml file

bcinv.yaml - Template file that is referenced to first  place one group into the file and then create inventory.yaml file
