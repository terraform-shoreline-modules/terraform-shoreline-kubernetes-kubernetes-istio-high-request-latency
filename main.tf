terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "istio_high_request_latency" {
  source    = "./modules/istio_high_request_latency"

  providers = {
    shoreline = shoreline
  }
}