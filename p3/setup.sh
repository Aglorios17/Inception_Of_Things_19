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
kubectl cluster-info

echo "\033[0;32m======== Kubernetes namespaces setup ========\033[0m"
kubectl create namespace argocd
kubectl create namespace dev
kubectl get namespace

echo "\033[0;32m======== Argo CD setup - Allow the creation of a CI/CD pipeline around kubernetes application ========\033[0m"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "WAITING FOR PODS TO RUN..."
sleep 10
kubectl wait pods -n argocd --all --for condition=Ready --timeout=600s
if [ $? -eq 1 ]
then
    echo "An error occured. The creation of argocd's pods timed out."
	exit 1
fi
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure
