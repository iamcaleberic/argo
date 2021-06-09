# Add apps and projects (incl. argocd)
helm template ../apps/ | kubectl apply -n argocd -f -