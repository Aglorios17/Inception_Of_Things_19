echo "\033[0;32m======== Install prerequisites ========\033[0m"
#do not forget to run docker desktop on mac
#install docker if docker does not exist or is outdated
brew outdated --cask docker || brew install --cask docker
#install kubernetes and its CLI
brew outdated kubectl || brew kubectl
#install k3d
brew outdated k3d || brew install k3d
#install argo-cd's CLI
brew outdated argocd || brew install argocd

echo "\033[0;32m======== K3D setup - Create kubernetes cluster on local machine ========\033[0m"
k3d cluster create p3
if [ $? -eq 1 ]
then
	osascript -e 'display notification "Cluster creation failed" with title "App Error"'; say "App Error"
    echo "An error occured when creating the cluster."
	echo "The cluster probably already exists."
	read -p 'Do you want us to delete and restart the cluster? (y/n): ' input
	if [ $input = 'y' ]; then
		echo "We will delete the cluster for you."
		k3d cluster delete p3
		echo "Now we will restart the cluster for you."
		./setup.sh
	fi
	exit 1
fi
kubectl cluster-info

echo "\033[0;32m======== Kubernetes namespaces setup ========\033[0m"
kubectl create namespace argocd
kubectl create namespace dev
kubectl get namespace

echo "\033[0;32m======== Argo CD setup - Allow the creation of a CI/CD pipeline around kubernetes application ========\033[0m"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "WAITING FOR ARGO-CD PODS TO RUN..."
sleep 10
kubectl wait pods -n argocd --all --for condition=Ready --timeout=600s
if [ $? -eq 1 ]
then
	osascript -e 'display notification "Argo-CD pods creation timeout" with title "App Error"'; say "App Error"
    echo "An error occurred. The creation of argocd's pods timed out."
	echo "We will delete the k3d cluster..."
	k3d cluster delete p3
	exit 1
fi
kubectl port-forward svc/argocd-server -n argocd 8080:443 &>/dev/null & #We run it in background and hide the output because benign error messages and other undesirable messages appear from it
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure
kubectl config set-context --current --namespace=argocd
argocd app create will --repo https://github.com/Aglorios17/Inception_Of_Things_19.git --path p3/app --dest-namespace dev --dest-server https://kubernetes.default.svc
echo "\033[0;36mView created app before sync and configuration\033[0m"
argocd app get will
echo "\033[0;36mSync the app and configure for automated synchronization\033[0m"
argocd app sync will
argocd app set will --sync-policy automated #Once git repo is changed with new push, our running will-app will mirror that.
argocd app set will --auto-prune --allow-empty #If resources are removed in git repo those resources will also be removed inside our running will-app, even if that means the app becomes empty.
argocd app set will --self-heal #If between git repo changes the running app changes (because you remove certain of its resources per accident or for other reasons...) the running app will be reverted to the lastest git repo's version.
echo "\033[0;36mView created app after sync and configuration\033[0m"
argocd app get will

echo "\033[0;32m======== Connect to Argo CD user-interface (UI) ========\033[0m"
osascript -e 'display notification "Argo-CD configuration is finished" with title "App Ready"'; say "App Ready"
read -p 'Do you want to be redirected to the argo-cd UI? (y/n): ' input
if [ $input = 'y' ]; then
	echo " ARGO CD USERNAME: admin"
	echo " ARGO CD PASSWORD: $ARGOCD_PASSWORD (we PASTED it on CLIPBOARD if you are on mac)"
	echo $ARGOCD_PASSWORD | pbcopy
	for i in {20..0}; do
        printf ' Remember those credentials. We will redirect you to https://localhost:8080 for the Argo CD UI in: \033[0;31m%d\033[0m \r' $i #An empty space must sit before \r else prior longer string end will be displayed
  		sleep 1
	done
	printf '\n'
	open 'https://localhost:8080'
fi
