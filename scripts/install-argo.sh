if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found"
    exit
fi

if ! command -v helm &> /dev/null
then
    echo "helm could not be found"
    exit
fi

if ! command -v htpasswd &> /dev/null
then
    echo "htpasswd could not be found"
    exit
fi

# fonts
bold=$(tput bold)
normal=$(tput sgr0)


unset namespace
unset release

usage() { echo -e "${bold} Usage: $0 [-n <namespace>] [-r <release>] [-p <password>  [-h <help>]" ${normal} 1>&2; exit 1; }

help() {
    echo -e "" \\n
    echo -e "${bold}Help" \\n

    echo -e "-n  sets a destination namespace for argo helm install"
    echo -e "-r  sets a helm release name for argo install"\\n
    echo -e "-p  sets a password for argo admin password"

    echo -e "-h  to show this help page"\\n
    echo -e "Example: install.sh -n namespace -r release-name  -p password${normal}"\\n
    exit 1
}



#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
  help
fi


options=":n:r:p:h"
while getopts $options opt
do
    case "${opt}" in
        n ) namespace=${OPTARG};;
        r ) release=${OPTARG};;
        p ) password=${OPTARG};;
        h ) help;; 
        # : ) usage;;
        ? ) usage;;
        * ) usage;;
    esac
done


: ${namespace:?Missing namespace -n} 
: ${release:?Missing release -r}
: ${password:?Missing password -r}

echo -e "Installing argocd to namespace: $namespace";
echo -e "Relese name: $release";


# https://stackoverflow.com/questions/15733196/where-2x-prefix-are-used-in-bcrypt/36225192#36225192
hashed_password=$(htpasswd -nbBC 10 "" ${password} | tr -d ':\n' | sed 's/$2y/$2a/')

# Initial argocd install with helm
helm dependency update ../argo-helm
helm install $release  ../argo-helm -n $namespace  --debug --dry-run 

helm install $release ../argo-helm  -n $namespace --create-namespace

# Add apps and projects (incl. argocd)
helm template ../apps/ | kubectl apply -n $namespace -f -

# https://github.com/helm/helm/issues/8127d
# delete release while keeping the resources 
# to allow argocd to manage itself
kubectl get secret -n $namespace -l owner=helm,name=$release 
kubectl delete secret -n $namespace  -l owner=helm,name=$release

#  alternative to change default argo password
# https://github.com/argoproj/argo-helm/issues/347
kubectl  get secret   -n $namespace argocd-secret 
kubectl  patch secret -n $namespace argocd-secret \
  -p '{"stringData": { "admin.password": "'${hashed_password}'"}}'
