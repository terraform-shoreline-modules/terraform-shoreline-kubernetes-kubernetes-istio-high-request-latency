resource "shoreline_notebook" "istio_high_request_latency" {
  name       = "istio_high_request_latency"
  data       = file("${path.module}/data/istio_high_request_latency.json")
  depends_on = [shoreline_action.invoke_get_pods_and_services_istio_system,shoreline_action.invoke_get_resources_k8s,shoreline_action.invoke_top_pods_describe_pod,shoreline_action.invoke_check_pod_resources,shoreline_action.invoke_patch_deployment_resources]
}

resource "shoreline_file" "get_pods_and_services_istio_system" {
  name             = "get_pods_and_services_istio_system"
  input_file       = "${path.module}/data/get_pods_and_services_istio_system.sh"
  md5              = filemd5("${path.module}/data/get_pods_and_services_istio_system.sh")
  description      = "Check the status of the Istio pods and services"
  destination_path = "/agent/scripts/get_pods_and_services_istio_system.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "get_resources_k8s" {
  name             = "get_resources_k8s"
  input_file       = "${path.module}/data/get_resources_k8s.sh"
  md5              = filemd5("${path.module}/data/get_resources_k8s.sh")
  description      = "Check the Istio configuration for the affected service"
  destination_path = "/agent/scripts/get_resources_k8s.sh"
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

resource "shoreline_file" "check_pod_resources" {
  name             = "check_pod_resources"
  input_file       = "${path.module}/data/check_pod_resources.sh"
  md5              = filemd5("${path.module}/data/check_pod_resources.sh")
  description      = "Resource constraints: The service may be under-resourced, leading to a slower response time for requests."
  destination_path = "/agent/scripts/check_pod_resources.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "patch_deployment_resources" {
  name             = "patch_deployment_resources"
  input_file       = "${path.module}/data/patch_deployment_resources.sh"
  md5              = filemd5("${path.module}/data/patch_deployment_resources.sh")
  description      = "If the issue is related to hardware resource constraints, consider increasing the resources allocated to the affected service or adding more nodes to the cluster."
  destination_path = "/agent/scripts/patch_deployment_resources.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_pods_and_services_istio_system" {
  name        = "invoke_get_pods_and_services_istio_system"
  description = "Check the status of the Istio pods and services"
  command     = "`chmod +x /agent/scripts/get_pods_and_services_istio_system.sh && /agent/scripts/get_pods_and_services_istio_system.sh`"
  params      = []
  file_deps   = ["get_pods_and_services_istio_system"]
  enabled     = true
  depends_on  = [shoreline_file.get_pods_and_services_istio_system]
}

resource "shoreline_action" "invoke_get_resources_k8s" {
  name        = "invoke_get_resources_k8s"
  description = "Check the Istio configuration for the affected service"
  command     = "`chmod +x /agent/scripts/get_resources_k8s.sh && /agent/scripts/get_resources_k8s.sh`"
  params      = ["NAMESPACE"]
  file_deps   = ["get_resources_k8s"]
  enabled     = true
  depends_on  = [shoreline_file.get_resources_k8s]
}

resource "shoreline_action" "invoke_top_pods_describe_pod" {
  name        = "invoke_top_pods_describe_pod"
  description = "Check if there are any CPU or memory issues affecting the service"
  command     = "`chmod +x /agent/scripts/top_pods_describe_pod.sh && /agent/scripts/top_pods_describe_pod.sh`"
  params      = ["POD_NAME","NAMESPACE"]
  file_deps   = ["top_pods_describe_pod"]
  enabled     = true
  depends_on  = [shoreline_file.top_pods_describe_pod]
}

resource "shoreline_action" "invoke_check_pod_resources" {
  name        = "invoke_check_pod_resources"
  description = "Resource constraints: The service may be under-resourced, leading to a slower response time for requests."
  command     = "`chmod +x /agent/scripts/check_pod_resources.sh && /agent/scripts/check_pod_resources.sh`"
  params      = ["POD_NAME"]
  file_deps   = ["check_pod_resources"]
  enabled     = true
  depends_on  = [shoreline_file.check_pod_resources]
}

resource "shoreline_action" "invoke_patch_deployment_resources" {
  name        = "invoke_patch_deployment_resources"
  description = "If the issue is related to hardware resource constraints, consider increasing the resources allocated to the affected service or adding more nodes to the cluster."
  command     = "`chmod +x /agent/scripts/patch_deployment_resources.sh && /agent/scripts/patch_deployment_resources.sh`"
  params      = ["RESOURCE_VALUE","DEPLOYMENT_NAME","RESOURCE_NAME"]
  file_deps   = ["patch_deployment_resources"]
  enabled     = true
  depends_on  = [shoreline_file.patch_deployment_resources]
}

