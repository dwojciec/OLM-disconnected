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
# Create list of images attached to operator to download
find . -name bundle.yaml -print > bundle-list.txt
find . -type f -name "bundle.yaml" -exec grep "image: " {} \; > images-list.txt 
# remove image: into the file generated
cat images-list.txt  | sed -e 's/^[ \t]*//' > image-full.txt
sed -i "s+image:++g" image-full.txt
# Pull images
awk -f transform-pull.awk image-full.txt > images1-list.txt
str1=$(echo "podman pull --authfile ${AIRGAP_SECRET_JSON} " | sed -e "s|[${s}&\]|\\\\&|g")
sed -e "s${s}^${s}${str1}${s}" images1-list.txt > images-pull.sh
chmod +x images-pull.sh
read -p "Do you want to download all containers images references in the operators catalog ? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  ./images-pull.sh
  rm images-pull.sh
fi
# Tag images
if [ $MIRROR_REGISTRY = "Y" ]
then
# Tag images
  awk -f transform-tag.awk image-full.txt > images1-tag.txt
  sed -i "s+/  XXXXX+  XXXXX+g" images1-tag.txt
  str1=$(echo "podman tag " | sed -e "s|[${s}&\]|\\\\&|g")
  sed -e "s${s}^${s}${str1}${s}" images1-tag.txt > images-tag.sh
  str3=$(echo "${AIRGAP_REG}")
  sed -i "s+XXXXXXXXXX+${str3}+g" images-tag.sh
  chmod +x images-tag.sh
  read -p "Do you want to tag all containers images downloaded ? <y/N> " prompt
  if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    ./images-tag.sh
    rm images-tag.sh
  fi
fi
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

if [ $MIRROR_REGISTRY = "Y" ]
then
  echo "podman tag ${CATALOG_OPERATOR_IMAGE}:latest ${AIRGAP_REG}/${AIRGAP_REPO}/${CATALOG_OPERATOR_IMAGE}:latest"
  podman tag ${CATALOG_OPERATOR_IMAGE}:latest ${AIRGAP_REG}/${AIRGAP_REPO}/${CATALOG_OPERATOR_IMAGE}:latest
fi
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
