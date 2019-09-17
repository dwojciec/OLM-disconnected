#!/bin/bash

operator-package() 
{
chaineAajouter="./get-operator-package.sh "	
s='/'	
str=$(echo "${chaineAajouter}" | sed -e "s|[${s}&\]|\\\\&|g")
sed -e "s${s}^${s}${str}${s}" namespaces.txt > namespaces1.sh
chmod +x namespaces1.sh
./namespaces1.sh
rm namespaces1.sh
cp Dockerfile ./tarball/.
cp build-catalog-registry.sh ./tarball/.
cd ./tarball
echo "Creation of Operator Catalog Image "
./build-catalog-registry.sh
# generate CataloSource yaml file 
cd ..
echo "Generation of the CatalogSource.yaml file into results directory" 
echo "image name : ${CATALOG_OPERATOR_IMAGE} " 
mkdir -p results
str=$(echo "${CATALOG_OPERATOR_IMAGE}" | sed -e "s|[${s}&\]|\\\\&|g")
sed -e "s${s}{image_name}${s}${str}${s}" catalogsource-template.yaml > ./results/catalogsource.yaml
rm namespaces.txt
}

push_image()
{
echo "push image to quay.io :quay.io/${QUAY_USER}/${CATALOG_OPERATOR_IMAGE}:latest"
echo "podman push --authfile ${QUAY_PRIVATE_JSON} ${CATALOG_OPERATOR_IMAGE}:latest quay.io/${QUAY_USER}/${CATALOG_OPERATOR_IMAGE}:latest"
podman push --authfile ${QUAY_PRIVATE_JSON} ${CATALOG_OPERATOR_IMAGE}:latest quay.io/${QUAY_USER}/${CATALOG_OPERATOR_IMAGE}:latest
}
 
source ./env.sh
echo "Creation of the list of Operators"
jq '.[] | .name' packages.txt > namespaces.txt
sed -i 's/"//g' namespaces.txt 
sed -i 's:/: :' namespaces.txt 
echo "Check the content of the namespaces.txt file from another Terminal windows before the creation of the package"
read -p "Are you sure you want to continue? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  operator-package
else
  exit 0
fi
echo "Do you want to push the image created to your own quay.io account ?"
read -p "Are you sure you want to continue? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  push_image
else
  exit 0
fi
