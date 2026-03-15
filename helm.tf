provider "helm" {
  kubernetes = {
	config_path = "~/.kube/config"
  }
}

resource "helm_release" "argocd" {

  depends_on = [null_resource.update-kubeconfig]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set = [
	{
	  name  = "server.service.type"
	  value = "LoadBalancer"
	}
  ]
}