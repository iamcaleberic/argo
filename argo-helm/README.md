
helm dependecy update 
helm install <release-name> . --debug --dry-run

helm install <relase-name> .  -n <namespace> --create-namespace

helm uninstall argo-cd-test . -n argo-cd

helm repo add argocd https://argoproj.github.io/argo-helm
helm search repo https://argoproj.github.io/argo-helm --versions
helm dependency update