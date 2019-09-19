#!/bin/bash
# set -xeu
if [ $# -lt 2 ]; then
    echo "Usage: $0 PKG_NAMESPACE PACKAGE"
    exit 1
fi

if [ -z "$QUAY_AUTH_TOKEN" ]; then
    echo "Must set \$QUAY_AUTH_TOKEN"
    exit 1
fi

export PKG_NAMESPACE=$1
export PKG_NAME=$2

# jq --arg prj "$toto" '.[] | select(.name == $prj) ' file1.txt
export concat1=$PKG_NAMESPACE"/"$PKG_NAME
echo "namespace/name: "$concat1
RELEASE="$(curl -s -H "Authorization: ${QUAY_AUTH_TOKEN}" "https://quay.io/cnr/api/v1/packages?namespace=$PKG_NAMESPACE" | jq --arg pkgconcat "$concat1" '.[] | select(.name == $pkgconcat) | .default' -r)"

echo "RELEASE: " $RELEASE


DIGEST="$(curl -s -H "Authorization: ${QUAY_AUTH_TOKEN}" "https://quay.io/cnr/api/v1/packages/$PKG_NAMESPACE/$PKG_NAME/$RELEASE" | jq '.[0].content.digest' -r)"

echo "DIGEST : " $DIGEST
OUT="${PKG_NAMESPACE}-${PKG_NAME}-${RELEASE}.tar.gz"
mkdir -p tarball
OUT1="tarball/$OUT"
echo $OUT1
curl -s -H "Authorization: ${QUAY_AUTH_TOKEN}" "https://quay.io/cnr/api/v1/packages/$PKG_NAMESPACE/$PKG_NAME/blobs/sha256/$DIGEST" -o "$OUT1"
echo "Stored package into $OUT"

mkdir -p ./tarball/manifests/${PKG_NAMESPACE}-${PKG_NAME}-${RELEASE}
cp $OUT1 ./tarball/manifests/${PKG_NAMESPACE}-${PKG_NAME}-${RELEASE}/
echo "cp $OUT1 ./tarball/manifests/${PKG_NAMESPACE}-${PKG_NAME}-${RELEASE}/"
cd ./tarball/manifests/${PKG_NAMESPACE}-${PKG_NAME}-${RELEASE}
echo "cd ./tarball/manifests/${PKG_NAMESPACE}-${PKG_NAME}-${RELEASE}"
tar xvzf  $OUT 
rm $OUT
