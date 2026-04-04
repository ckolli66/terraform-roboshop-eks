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
  values     = [file("prometheus-scrapeValues.yml")]

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

resource "helm_release" "nginx-ingress" {

  depends_on = [null_resource.update-kubeconfig]

  name       = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

}
## With the help of this external dns tool whenever I create nginx ingress it automatically creates route 53 record in aws

resource "helm_release" "external-dns" {

  depends_on = [null_resource.update-kubeconfig]

  name       = "external-dns-routing"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
}