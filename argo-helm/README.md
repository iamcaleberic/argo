
helm dependecy update 
helm install <release-name> . --debug --dry-run

helm install <relase-name> .  -n <namespace> --create-namespace

helm uninstall argo-cd-test . -n argo-cd