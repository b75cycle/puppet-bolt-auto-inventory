#bcinven.awk
# creating an inventory for puppet connect
BEGIN {RS= ""; FS=" "}
{
     print "     - name:",$3 
     print "       uri:",$2 
}

