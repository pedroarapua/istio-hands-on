#!/bin/bash
# Reference https://kubernetes.io/docs/reference/kubectl/cheatsheet/
# permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context --current --namespace=$1