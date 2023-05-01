# Script Name: k8s-exporter.sh

## Description:

This bash script exports the YAML definitions for Kubernetes resources (Ingress, Service, Deployment, HPA, StatefulSet) in all namespaces of a Kubernetes cluster. 

The script works by looping through each namespace and retrieving the names of all relevant resources in that namespace. For each resource, it then retrieves the corresponding YAML definition, removes unwanted fields, and formats it for easy reading. 

The resulting YAML definitions can be used for backup, version control, or migration purposes. 

## Usage:

To use this script, simply run it on a machine with `kubectl` installed and configured to point to the Kubernetes cluster you wish to export resources from. 

```
bash k8s-exporter.sh
```

## Output:

The script will output the formatted YAML definitions for each relevant Kubernetes resource in all namespaces of the cluster. 

The output can be redirected to a file for further processing or stored in a version control system for backup and migration purposes. 

## Note:

This script only exports the YAML definitions for the specified Kubernetes resources. It does not export any associated data or stateful information. 

It is also important to note that the exported YAML definitions may not be compatible with different versions of Kubernetes or with different configurations. Therefore, it is recommended to test the exported YAML definitions thoroughly before using them for backup or migration purposes.
