resource "shoreline_notebook" "istio_high_request_latency" {
  name       = "istio_high_request_latency"
  data       = file("${path.module}/data/istio_high_request_latency.json")
  depends_on = [shoreline_action.invoke_get_pods_and_services,shoreline_action.invoke_get_vs_dr_gw,shoreline_action.invoke_top_pods_describe_pod,shoreline_action.invoke_cpu_memory_check,shoreline_action.invoke_update_deployment_resource_limits]
}

resource "shoreline_file" "get_pods_and_services" {
  name             = "get_pods_and_services"
  input_file       = "${path.module}/data/get_pods_and_services.sh"
  md5              = filemd5("${path.module}/data/get_pods_and_services.sh")
  description      = "Check the status of the Istio pods and services"
  destination_path = "/agent/scripts/get_pods_and_services.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "get_vs_dr_gw" {
  name             = "get_vs_dr_gw"
  input_file       = "${path.module}/data/get_vs_dr_gw.sh"
  md5              = filemd5("${path.module}/data/get_vs_dr_gw.sh")
  description      = "Check the Istio configuration for the affected service"
  destination_path = "/agent/scripts/get_vs_dr_gw.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "top_pods_describe_pod" {
  name             = "top_pods_describe_pod"
  input_file       = "${path.module}/data/top_pods_describe_pod.sh"
  md5              = filemd5("${path.module}/data/top_pods_describe_pod.sh")
  description      = "Check if there are any CPU or memory issues affecting the service"
  destination_path = "/agent/scripts/top_pods_describe_pod.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "cpu_memory_check" {
  name             = "cpu_memory_check"
  input_file       = "${path.module}/data/cpu_memory_check.sh"
  md5              = filemd5("${path.module}/data/cpu_memory_check.sh")
  description      = "Resource constraints: The service may be under-resourced, leading to a slower response time for requests."
  destination_path = "/agent/scripts/cpu_memory_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_deployment_resource_limits" {
  name             = "update_deployment_resource_limits"
  input_file       = "${path.module}/data/update_deployment_resource_limits.sh"
  md5              = filemd5("${path.module}/data/update_deployment_resource_limits.sh")
  description      = "If the issue is related to hardware resource constraints, consider increasing the resources allocated to the affected service or adding more nodes to the cluster."
  destination_path = "/agent/scripts/update_deployment_resource_limits.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_pods_and_services" {
  name        = "invoke_get_pods_and_services"
  description = "Check the status of the Istio pods and services"
  command     = "`chmod +x /agent/scripts/get_pods_and_services.sh && /agent/scripts/get_pods_and_services.sh`"
  params      = []
  file_deps   = ["get_pods_and_services"]
  enabled     = true
  depends_on  = [shoreline_file.get_pods_and_services]
}

resource "shoreline_action" "invoke_get_vs_dr_gw" {
  name        = "invoke_get_vs_dr_gw"
  description = "Check the Istio configuration for the affected service"
  command     = "`chmod +x /agent/scripts/get_vs_dr_gw.sh && /agent/scripts/get_vs_dr_gw.sh`"
  params      = ["NAMESPACE"]
  file_deps   = ["get_vs_dr_gw"]
  enabled     = true
  depends_on  = [shoreline_file.get_vs_dr_gw]
}

resource "shoreline_action" "invoke_top_pods_describe_pod" {
  name        = "invoke_top_pods_describe_pod"
  description = "Check if there are any CPU or memory issues affecting the service"
  command     = "`chmod +x /agent/scripts/top_pods_describe_pod.sh && /agent/scripts/top_pods_describe_pod.sh`"
  params      = ["NAMESPACE","POD_NAME"]
  file_deps   = ["top_pods_describe_pod"]
  enabled     = true
  depends_on  = [shoreline_file.top_pods_describe_pod]
}

resource "shoreline_action" "invoke_cpu_memory_check" {
  name        = "invoke_cpu_memory_check"
  description = "Resource constraints: The service may be under-resourced, leading to a slower response time for requests."
  command     = "`chmod +x /agent/scripts/cpu_memory_check.sh && /agent/scripts/cpu_memory_check.sh`"
  params      = ["POD_NAME"]
  file_deps   = ["cpu_memory_check"]
  enabled     = true
  depends_on  = [shoreline_file.cpu_memory_check]
}

resource "shoreline_action" "invoke_update_deployment_resource_limits" {
  name        = "invoke_update_deployment_resource_limits"
  description = "If the issue is related to hardware resource constraints, consider increasing the resources allocated to the affected service or adding more nodes to the cluster."
  command     = "`chmod +x /agent/scripts/update_deployment_resource_limits.sh && /agent/scripts/update_deployment_resource_limits.sh`"
  params      = ["RESOURCE_NAME","RESOURCE_VALUE","DEPLOYMENT_NAME"]
  file_deps   = ["update_deployment_resource_limits"]
  enabled     = true
  depends_on  = [shoreline_file.update_deployment_resource_limits]
}

