BEGIN{
FS="/";
 OFS="/"
}
{sub("^.", "")
text2="  XXXXXXXXXX"
if (NF > 2)
{
print $1, $2, $3,text2, $3 
}
else
{
test="docker.io"
print test,$1,$2,text2, $2 
}
}
END {
}
