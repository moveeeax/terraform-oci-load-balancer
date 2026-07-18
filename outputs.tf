output "id" {
  description = "OCID of the load balancer."
  value       = oci_load_balancer_load_balancer.this.id
}

output "ip_addresses" {
  description = "IP addresses assigned to the load balancer."
  value       = oci_load_balancer_load_balancer.this.ip_address_details
}

output "shape" {
  description = "Shape of the load balancer."
  value       = oci_load_balancer_load_balancer.this.shape
}

output "state" {
  description = "Lifecycle state of the load balancer."
  value       = oci_load_balancer_load_balancer.this.state
}
