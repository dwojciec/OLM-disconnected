BEGIN{
FS="/";
 OFS="/"
}
{sub("^.", "")
if (NF > 2)
{
print $0
}
else
{
test="docker.io"
print test,$0 
}
}
END {
}
