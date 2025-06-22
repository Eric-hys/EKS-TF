resource "helm_release" "static-web" {
  name       = "static-web"
  namespace  = "default"

  repository = "https://eric-hys.github.io/helm_Demo"
  chart      = "static-web"
  version    = "0.1.0"

}
