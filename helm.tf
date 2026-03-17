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

resource "helm_release" "prometheus" {

  depends_on = [null_resource.update-kubeconfig]

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  values     = [file("prometheus-scrapeValues")]

  set = [
	{
	  name  = "prometheus.service.type"
	  value = "LoadBalancer"
	},
	{
	  name  = "grafana.enabled"
	  value = false
	}
  ]
}