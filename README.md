# OLM disconnected

Based on the Disconnected (Air-gapped) UPI installation process described into [Experimental Developer Preview Builds](https://cloud.redhat.com/openshift/install/pre-release)

reference : [Preview of Disconnected (Air-gapped) Install & Update Guide](https://docs.google.com/document/d/1cCnER-IMDCfinO7DiSvATt8WE4-YBngKrSb2aeBToZA/edit)

## Install Instructions

### Automation of Operator Hub image creation

The work is based on this document 

```
$ git clone https://github.com/dwojciec/OLM-disconnected.git
```

### Define variables for your env.sh file 

Here is an example about env.sh file that contains information about quay access with your private quay account to push the image created or to access quay with your subscription account  

```
export QUAY_AUTH_TOKEN=b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2R3b2pjaWVjcmVkaGF0Y29tMWpjd2VyeGFnc29pbzZuanhid3ZkYXFxbGlqOllGQzNIQ1g4SjlJNlZXUklMVlNCT1U1RjRVVkFGVkM4MTYxMEZCMU5VSlBLVUlCxsxsx
export AIRGAP_SECRET_JSON='pull-secret-3.json'
export QUAY_PRIVATE_JSON='dwojciec-auth.json'
export QUAY_USER=dwojciec
export CATALOG_OPERATOR_IMAGE=example-registry
```

| variable | description  |
|---|---|
| QUAY_AUTH_TOKEN  | quay.io token you have in the Download pull secret button   |
| AIRGAP_SECRET_JSON  | Create a file with the pull secret content  |
| QUAY_PRIVATE_JSON  | quay token needed to push the image created. Account Setting -> CLI Password : Generate Encrypted Password -> Docker Configuration -> Download <user or Organisation> - auth.json file|
| QUAY_USER  | users or organisation on which you can decide to push the image created|
| CATALOG_OPERATOR_IMAGE | name of the image generated |



### Retrieve package lists
This script is creating the list of packages that are available for the default operators sources. This script is generating a json format file called *packages.txt*

```
$ sh retrieve-package-list.sh
```


### Operator Catalog Image
This script is creating a Operator Catalog Image with all operators list generated during the [Retrieve package lists](https://github.com/dwojciec/OLM-disconnected#Retrieve-package-lists) step. This script is running in 4 phases :

* Generate the list of operators into *namespaces.txt* file to include into the Operator Catalog Image.
* you can update the *namespaces.txt* file from another Terminal session if you want to remove some operators from the list.
* Build of the Operator Catalog image container.
* Push the image to your own Quay repository to share it with other people.

```
$ ./create-operator-catalog-img.sh 
```

During this process the yaml file **catalogsource.yaml** is generated.
exeample of this file 

```
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: example-manifests
  namespace: default
spec:
  sourceType: grpc
  image: <path to the the image>/example-registry:latest
```



