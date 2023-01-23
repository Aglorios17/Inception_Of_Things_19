#!/usr/bin/env bash

echo "je suis icici!!!!!"

export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $1 --node-ip $1 --flannel-iface=eth1"
curl -sfL https://get.k3s.io |  sh -
echo "alias k='k3s kubectl'" >> /etc/profile.d/00-aliases.sh

# installation ifconfig
sudo yum install net-tools -y

echo "je suis icici!!!!!"
/usr/local/bin/kubectl create configmap app1-html --from-file /vagrant/confs/k3s/app1/index.html
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app1/app1.deployment.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app1/app1.service.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app1/app1.ingress.yaml

/usr/local/bin/kubectl create configmap app2-html --from-file /vagrant/confs/k3s/app2/index.html
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app2/app2.deployment.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app2/app2.service.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app2/app2.ingress.yaml

/usr/local/bin/kubectl create configmap app3-html --from-file /vagrant/confs/k3s/app3/index.html
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app3/app3.deployment.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app3/app3.service.yaml
/usr/local/bin/kubectl apply -f /vagrant/confs/k3s/app3/app3.ingress.yaml
