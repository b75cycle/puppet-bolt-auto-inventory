#inven.awk
# creating an inventory for bolt
BEGIN {RS= ""; FS=" "}
{
     print "     - uri:",$2 
     print "       alias:",$3 
     print "       facts:", ""
     print "         os:",$5
     print "         hardware:",$6
}

