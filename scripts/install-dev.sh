if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found"
    exit
fi

# aws eks --region <region-code> update-kubeconfig --name <cluster_name>

kubectl config current-context

# Non HA install
# kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# HA install
# kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.0/manifests/ha/install.yaml

if ! command -v argocd &> /dev/null
then
    echo "Installing argocd client"
    VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
    chmod +x /usr/local/bin/argocd
fi

PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
NEW_PASSWORD=$(openssl rand -base64 30)

argocd login <ARGOCD_SERVER>  --password $PASSWORD
argocd account update-password --current-password $PASSWORD --new-password $NEW_PASSWORD

kubectl delete -n argocd secret argocd-initial-admin-secret