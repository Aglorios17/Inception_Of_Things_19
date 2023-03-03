#!/bin/bash

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh -

sleep 10

kubectl apply -f /vagrant/app1.yaml --validate=false
kubectl apply -f /vagrant/app2.yaml --validate=false
kubectl apply -f /vagrant/app3.yaml --validate=false
kubectl apply -f /vagrant/ingress.yaml --validate=false

