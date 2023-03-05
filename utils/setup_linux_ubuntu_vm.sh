echo "\n\n===============================\n"
echo "=== INSTALL DIFFERENT TOOLS ===\n"
echo "===============================\n\n"

echo "\n>> INSTALL MAKE\n"
sudo apt install make -y

echo "\n>> INSTALL CURL\n"
sudo apt install curl -y

echo "\n>> INSTALL VIM\n"
sudo apt install vim -y

echo "\n>> INSTALL XSEL\n"
sudo apt install xsel -y

echo "\n>> INSTALL GH\n"
sudo apt install gh -y

echo "\n>> INSTALL VIRTUALBOX\n"
sudo apt install virtualbox -y
sudo virtualbox --version

echo "\n>> INSTALL VAGRANT\n"
sudo wget https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
sudo chmod +x vagrant_2.2.19_x86_64.deb
sudo apt install ./vagrant_2.2.19_x86_64.deb
sudo rm vagrant_2.2.19_x86_64.deb
sudo vagrant --version

echo "\n>> INSTALL DOCKER\n"
sudo apt install docker.io -y
sudo docker --version

echo "\n>> INSTALL KUBECTL\n"
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

echo "\n>> INSTALL K3D\n"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "\n>> INSTALL ARGO-CD\n"
sudo curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
argocd version

echo "\n>> INSTALL GITLAB\n"
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl
echo "During the following Postfix installation a configuration screen may appear. Select 'Internet Site' and press enter. Use your server's external DNS for 'mail name' and press enter. If additional screens appear, continue to press enter to accept the defaults."
sudo apt-get install -y postfix
echo "Make sure you have correctly set up your DNS, and change https://gitlab.example.com to the URL at which you want to access your GitLab instance. Installation will automatically configure and start GitLab at that URL."
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo os=ubuntu dist=jammy bash
sudo EXTERNAL_URL="http://gitlab.local" apt-get install gitlab-ee
echo "Username : root\n"
sudo cat /etc/gitlab/initial_root_password
echo "sudo cat /etc/gitlab/initial_root_password | /!\ change for user4242 in gui for our script"


echo "\n>> ADD HOST IN /ETC/HOSTS\n"
echo "192.168.56.110 app1.com" | sudo tee -a /etc/hosts
echo "192.168.56.110 app2.com" | sudo tee -a /etc/hosts
echo "127.0.0.1 gitlab.local" | sudo tee -a /etc/hosts
