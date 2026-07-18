provider "oci" {}

module "load_balancer" {
  source = "../.."

  compartment_id = var.compartment_id
  display_name   = "example-lb"
  subnet_ids     = [var.subnet_id]
  shape          = "flexible"

  shape_details = {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }

  freeform_tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

variable "compartment_id" {
  description = "Compartment OCID to deploy the example load balancer into."
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet to attach the example load balancer to."
  type        = string
}

output "load_balancer_id" {
  value = module.load_balancer.id
}
