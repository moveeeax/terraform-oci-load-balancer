variable "compartment_id" {
  description = "OCID of the compartment in which to create the load balancer."
  type        = string
}

variable "display_name" {
  description = "Human-readable name for the load balancer."
  type        = string
}

variable "subnet_ids" {
  description = <<-EOT
    List of subnet OCIDs the load balancer is attached to. A private load balancer
    takes exactly one subnet. A public load balancer takes one regional subnet, or
    two availability-domain-specific subnets in different availability domains.
  EOT
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet OCID must be provided."
  }

  validation {
    condition     = length(var.subnet_ids) <= 2
    error_message = "A load balancer can be attached to at most two subnets."
  }

  validation {
    condition     = length(distinct(var.subnet_ids)) == length(var.subnet_ids)
    error_message = "subnet_ids must not contain duplicate OCIDs."
  }
}

variable "shape" {
  description = "Shape of the load balancer. Use flexible for auto-scaling bandwidth."
  type        = string
  default     = "flexible"

  # The shape_details block in main.tf is emitted only when this is exactly
  # "flexible". Without this check a typo such as "Flexible" is accepted at plan
  # time, silently drops shape_details, and then fails at apply with an opaque
  # API error.
  validation {
    condition = contains(
      ["flexible", "10Mbps", "10Mbps-Micro", "100Mbps", "400Mbps", "8000Mbps"],
      var.shape
    )
    error_message = "shape must be one of: flexible, 10Mbps, 10Mbps-Micro, 100Mbps, 400Mbps, 8000Mbps (values are case-sensitive)."
  }
}

variable "shape_details" {
  description = "Minimum and maximum bandwidth in Mbps for the flexible shape. Ignored unless shape is \"flexible\"."
  type = object({
    minimum_bandwidth_in_mbps = number
    maximum_bandwidth_in_mbps = number
  })
  default = {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }

  validation {
    condition = (
      var.shape_details.minimum_bandwidth_in_mbps >= 10 &&
      var.shape_details.maximum_bandwidth_in_mbps <= 8000
    )
    error_message = "Flexible shape bandwidth must be between 10 and 8000 Mbps."
  }

  validation {
    condition     = var.shape_details.minimum_bandwidth_in_mbps <= var.shape_details.maximum_bandwidth_in_mbps
    error_message = "minimum_bandwidth_in_mbps must be less than or equal to maximum_bandwidth_in_mbps."
  }
}

variable "is_private" {
  description = "Whether the load balancer is private (no public IP)."
  type        = bool
  default     = false
}

variable "network_security_group_ids" {
  description = "List of NSG OCIDs to associate with the load balancer."
  type        = list(string)
  default     = []
}

variable "freeform_tags" {
  description = "Free-form tags applied to the load balancer."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags applied to the load balancer, keyed as \"namespace.key\"."
  type        = map(string)
  default     = {}
}
