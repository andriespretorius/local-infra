#!/bin/sh

minikube delete
minikube start

kubectx minikube

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Setting Argo admin password"
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$obc9mbI5QjcHVaDUfJU5vOnjiAZOPK2jSqoPmBo35rTVgbXsynuGW",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'


# helm install sealed-secrets
# helm repo update
# helm install --namespace kube-system sealed-secrets sealed-secrets/sealed-secrets

# kubectl create secret generic my-secret -n argocd --dry-run=client \
# --from-file=ssh-privatekey=/Users/shanebedggood/.ssh/id_rsa \
# --from-file=ssh-publickey=/Users/shanebedggood/.ssh/id_rsa.pub -o yaml | \
#  kubeseal \
#  --controller-name=selaed-secrets-sealed-secrets \
#  --controller-namespace=kube-system \
#  --format yaml > mysealedsecret.yaml

#  kubectl apply -f mysealedsecret.yaml



kubectl create namespace infra

# Login into ArgoCD via the argocd cli
argocd login localhost:8080 --username admin --password admin --insecure

# Create the infra project for apps like prometheus operator, gatekeeper
argocd proj create infra -d "*","infra" -s "*"
# Allow all resource kinds 
argocd proj allow-cluster-resource "infra" "*" "*" 
argocd proj add-source "infra" "*"
argocd proj add-destination "infra" "*" "*"

# Add a Git repository via SSH using a private key for authentication, ignoring the server's host key:
argocd repo add git@github.com:shanebedgie/local-infra.git --insecure-ignore-host-key --ssh-private-key-path ~/.ssh/id_rsa 

# Add the infra app-of-apps application
argocd app create -f infra_app.yaml






# kubectl create deploy whoami --image containous/whoami
# kubectl expose deploy whoami --port 80
# kubectl apply -f whoami_ingress.yaml









