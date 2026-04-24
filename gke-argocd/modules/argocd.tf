resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "v3.3.2"

  values = [ 
    templatefile("${path.module}/values/argocd.yaml", {
      argocd_name_app    = var.argocd_app_name
      repo_url           = var.repo_url
      target_revision    = var.target_revision
      path               = var.app_path
      syncPolicy_prune   = var.sync_prune
      syncPolicy_selfHeal = var.sync_self_heal
      domaine_name       = var.domain_name
    })
  ]
}
