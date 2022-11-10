kubectl cluster-info &>/dev/null
if [ $? -eq 1 ] #protect this script from running without an active kubernetes cluster
then
	osascript -e 'display notification "Argo-CD launched without a kubernetes cluster" with title "App Error"'; say "App Error"
  echo "An error occurred. No kuberneted cluster is running for Argo-CD to be launched."
  read -p 'Do you want us to first create the cluster? (y/n): ' input
	if [ $input = 'y' ]; then
		./setup.sh
	fi
	exit 1
fi

if [ -z "$1" ]; then
  echo "\033[0;32m======== Argo CD setup - Allow the creation of a CI/CD pipeline around kubernetes application ========\033[0m"
fi
echo "WAITING FOR ARGO-CD PODS TO RUN..."
if [ "$1" ]; then
  sleep 10 #This is necessary as we cannot check the argo-cd pods instantly after applying them
fi
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
argocd app create will --repo 'https://github.com/Aglorios17/Inception_Of_Things_19.git' --path 'p3/app/app' --dest-namespace 'dev' --dest-server 'https://kubernetes.default.svc'
if [ $? -eq 20 ] #protect this script from running while will app already exists
then
  echo "An error occurred when creating argo-cd app 'will'."
  echo "Probably because the argo-cd app 'will' already exists."
  read -p 'Do you want us to delete and recreate the app? (y/n): ' input
	if [ $input = 'y' ]; then
		echo "We will delete the app for you."
		yes | argocd app delete will &>/dev/null
		echo "Now we will relaunch argo-cd for you."
		./launch.sh
	fi
	exit 1
fi
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
if [ "$1" ]; then
  osascript -e 'display notification "Argo-CD configuration is finished" with title "App Ready"'; say "App Ready"
fi
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
