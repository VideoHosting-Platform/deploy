resource "helm_release" "video-hosting" {
    name = "video-hosting"
    repository = "oci://ghcr.io/redblood-pixel/charts"
    chart = "video-hosting-stack"
    version = "0.1.8"
    namespace = "default"
    values = try(fileexists("${path.cwd}/values.yaml") ? [file("${path.cwd}/values.yaml")] : [], [])
}


output "yaml_values_used" {
  value = fileexists("${path.cwd}/values.yaml") ? "Custom values from file" : "Default values"
}