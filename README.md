# terraform-oci-load-balancer

Terraform module that manages an [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/)
Load Balancer. It defaults to the flexible shape with configurable minimum and maximum
bandwidth, supports public or private placement, and optional network security groups.

## Usage

```hcl
module "load_balancer" {
  source = "github.com/moveeeax/terraform-oci-load-balancer"

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

## Placement and exposure

`is_private` defaults to `false`, which is the OCI default and gives the load balancer a
public IP. Note that `is_private` forces replacement of the load balancer, so it is not a
setting you can flip in place on a live listener. Set it explicitly per environment, and
restrict inbound traffic with `network_security_group_ids` (or the subnet's security
lists) rather than relying on placement alone.

Subnet count is constrained by OCI and validated at plan time:

- a private load balancer takes **exactly one** subnet;
- a public load balancer takes **one** regional subnet, or **two** availability-domain-specific
  subnets in different availability domains.

## Validation

Inputs that OCI would otherwise reject at apply time are checked during `plan`:

| Input                       | Rule                                                                      |
|-----------------------------|---------------------------------------------------------------------------|
| `shape`                     | Must be one of `flexible`, `10Mbps`, `10Mbps-Micro`, `100Mbps`, `400Mbps`, `8000Mbps` (case-sensitive). |
| `shape_details`             | Bandwidth between 10 and 8000 Mbps, and minimum ≤ maximum.                |
| `subnet_ids`                | Between one and two entries, no duplicates.                               |
| `subnet_ids` + `is_private` | A private load balancer must have exactly one subnet.                     |

The `shape` check matters because `shape_details` is only emitted when `shape` is exactly
`"flexible"`. Before this validation existed, a value such as `"Flexible"` planned cleanly,
silently dropped `shape_details`, and then failed at apply against the OCI API.

## Testing

```sh
terraform init -backend=false
terraform test
```

The suite in [`tests/`](tests) uses `mock_provider`, so it needs no OCI credentials and
makes no API calls. `mock_provider` requires Terraform >= 1.7; that is a test-only
requirement and the module itself still supports Terraform >= 1.5.

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
| `subnet_ids`                 | Subnet OCIDs the load balancer is attached to (one or two).       | `list(string)` | n/a          |   yes    |
| `shape`                      | Shape of the load balancer (see Validation).                      | `string`       | `"flexible"` |    no    |
| `shape_details`              | Min/max bandwidth in Mbps; ignored unless `shape` is `flexible`.  | `object(...)`  | `10/100`     |    no    |
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
