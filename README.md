# terraform-oci-load-balancer

Terraform module that manages an [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/)
Load Balancer. It defaults to the flexible shape with configurable minimum and maximum
bandwidth, supports public or private placement, and optional network security groups.

## Usage

```hcl
module "load_balancer" {
  source = "github.com/cybercapybara/terraform-oci-load-balancer"

  compartment_id = var.compartment_id
  display_name   = "prod-lb"
  subnet_ids     = [var.public_subnet_id]
  shape          = "flexible"

  shape_details = {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 400
  }

  freeform_tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| oci       | >= 5.0   |

## Inputs

| Name                         | Description                                                       | Type           | Default      | Required |
|------------------------------|-------------------------------------------------------------------|----------------|--------------|:--------:|
| `compartment_id`             | OCID of the compartment in which to create the load balancer.     | `string`       | n/a          |   yes    |
| `display_name`               | Human-readable name for the load balancer.                        | `string`       | n/a          |   yes    |
| `subnet_ids`                 | List of subnet OCIDs the load balancer is attached to.            | `list(string)` | n/a          |   yes    |
| `shape`                      | Shape of the load balancer.                                       | `string`       | `"flexible"` |    no    |
| `shape_details`              | Min/max bandwidth in Mbps for the flexible shape.                 | `object(...)`  | `10/100`     |    no    |
| `is_private`                 | Whether the load balancer is private (no public IP).              | `bool`         | `false`      |    no    |
| `network_security_group_ids` | NSG OCIDs to associate with the load balancer.                    | `list(string)` | `[]`         |    no    |
| `freeform_tags`              | Free-form tags applied to the load balancer.                      | `map(string)`  | `{}`         |    no    |
| `defined_tags`               | Defined tags applied to the load balancer, keyed `namespace.key`. | `map(string)`  | `{}`         |    no    |

## Outputs

| Name           | Description                                |
|----------------|--------------------------------------------|
| `id`           | OCID of the load balancer.                 |
| `ip_addresses` | IP addresses assigned to the load balancer.|
| `shape`        | Shape of the load balancer.                |
| `state`        | Lifecycle state of the load balancer.      |

## License

[MIT](LICENSE)
