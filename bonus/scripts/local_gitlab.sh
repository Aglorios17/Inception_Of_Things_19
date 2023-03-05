sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl
echo "During the following Postfix installation a configuration screen may appear. Select 'Internet Site' and press enter. Use your server's external DNS for 'mail name' and press enter. If additional screens appear, continue to press enter to accept the defaults."
sudo apt-get install -y postfix
echo "Make sure you have correctly set up your DNS, and change https://gitlab.example.com to the URL at which you want to access your GitLab instance. Installation will automatically configure and start GitLab at that URL."
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo os=ubuntu dist=jammy bash
sudo GITLAB_ROOT_PASSWORD="user4242" EXTERNAL_URL="http://192.168.55.113" apt install gitlab-ee

sudo PASS=$(cat ~/etc/gitlab/initial_root_password)

echo "Gitlab UI: http://gitlab.iot.com"
echo "Login: root"
echo "Password: $PASS (we pasted it on clipboard)"
if [ "$(uname)" = "Darwin" ]; then
   echo $PASS | pbcopy
else
  echo $PASS | xsel --clipboard --input
fi

read -p "Enter to coninue..."
