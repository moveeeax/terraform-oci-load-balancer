resource "oci_load_balancer_load_balancer" "this" {
  compartment_id = var.compartment_id
  display_name   = var.display_name
  shape          = var.shape
  subnet_ids     = var.subnet_ids
  is_private     = var.is_private

  network_security_group_ids = var.network_security_group_ids

  dynamic "shape_details" {
    for_each = var.shape == "flexible" ? [var.shape_details] : []
    content {
      minimum_bandwidth_in_mbps = shape_details.value.minimum_bandwidth_in_mbps
      maximum_bandwidth_in_mbps = shape_details.value.maximum_bandwidth_in_mbps
    }
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}
