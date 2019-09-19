BEGIN{
FS="/";
# OFS="/"
}
{sub("^.", "")
text2="  XXXXXXXXXX/"
if (NF > 2)
{
print $0 text2 substr($0, index($0,$2))
#$1=""; $2=""; print
#print $0 text2, $3 
}
else
{
test="docker.io/"
#print test,$1,$2 text2, $2 
print test $1 $2 text2  substr($0, index($0,$2))
}
}
END {
}
