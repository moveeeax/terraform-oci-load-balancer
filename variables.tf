variable "compartment_id" {
  description = "OCID of the compartment in which to create the load balancer."
  type        = string
}

variable "display_name" {
  description = "Human-readable name for the load balancer."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet OCIDs the load balancer is attached to."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet OCID must be provided."
  }
}

variable "shape" {
  description = "Shape of the load balancer. Use flexible for auto-scaling bandwidth."
  type        = string
  default     = "flexible"
}

variable "shape_details" {
  description = "Minimum and maximum bandwidth in Mbps for the flexible shape."
  type = object({
    minimum_bandwidth_in_mbps = number
    maximum_bandwidth_in_mbps = number
  })
  default = {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
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
