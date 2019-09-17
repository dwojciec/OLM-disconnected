#!/bin/bash
source ./env.sh
echo "list of operators from redhat-operators"
curl https://quay.io/cnr/api/v1/packages?namespace=redhat-operators > packages.txt
echo "list of operators from community-operators"
curl https://quay.io/cnr/api/v1/packages?namespace=community-operators >> packages.txt
echo "list of operators from certified-operators"
curl https://quay.io/cnr/api/v1/packages?namespace=certified-operators >> packages.txt
echo "package.txt file created with all operators"
