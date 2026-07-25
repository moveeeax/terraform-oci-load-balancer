# Run with: terraform test
#
# These tests use `mock_provider`, which requires Terraform >= 1.7. That is a
# test-only requirement -- the module itself still supports Terraform >= 1.5, so
# do not raise required_version in versions.tf on account of this file.

mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaexampleuniqueid"
  display_name   = "test-lb"
  subnet_ids     = ["ocid1.subnet.oc1..aaaaaaaaexampleuniqueid"]
}

run "defaults_use_flexible_shape_with_shape_details" {
  assert {
    condition     = oci_load_balancer_load_balancer.this.shape == "flexible"
    error_message = "Default shape should be flexible."
  }

  assert {
    condition     = length(oci_load_balancer_load_balancer.this.shape_details) == 1
    error_message = "The flexible shape must emit exactly one shape_details block."
  }

  assert {
    condition     = one(oci_load_balancer_load_balancer.this.shape_details).minimum_bandwidth_in_mbps == 10
    error_message = "Default minimum bandwidth should be 10 Mbps."
  }

  assert {
    condition     = one(oci_load_balancer_load_balancer.this.shape_details).maximum_bandwidth_in_mbps == 100
    error_message = "Default maximum bandwidth should be 100 Mbps."
  }
}

run "fixed_shape_omits_shape_details" {
  variables {
    shape = "400Mbps"
  }

  assert {
    condition     = length(oci_load_balancer_load_balancer.this.shape_details) == 0
    error_message = "shape_details must not be emitted for a fixed shape."
  }
}

# A typo such as "Flexible" used to be accepted at plan time. The dynamic block
# compares against the exact string "flexible", so shape_details was silently
# dropped and the apply failed against the OCI API instead.
run "rejects_misspelled_shape" {
  command = plan

  variables {
    shape = "Flexible"
  }

  expect_failures = [var.shape]
}

run "rejects_unknown_shape" {
  command = plan

  variables {
    shape = "1000Mbps"
  }

  expect_failures = [var.shape]
}

run "rejects_inverted_bandwidth_range" {
  command = plan

  variables {
    shape_details = {
      minimum_bandwidth_in_mbps = 400
      maximum_bandwidth_in_mbps = 100
    }
  }

  expect_failures = [var.shape_details]
}

run "rejects_bandwidth_below_floor" {
  command = plan

  variables {
    shape_details = {
      minimum_bandwidth_in_mbps = 5
      maximum_bandwidth_in_mbps = 100
    }
  }

  expect_failures = [var.shape_details]
}

run "rejects_bandwidth_above_ceiling" {
  command = plan

  variables {
    shape_details = {
      minimum_bandwidth_in_mbps = 10
      maximum_bandwidth_in_mbps = 10000
    }
  }

  expect_failures = [var.shape_details]
}

run "rejects_empty_subnet_list" {
  command = plan

  variables {
    subnet_ids = []
  }

  expect_failures = [var.subnet_ids]
}

run "rejects_more_than_two_subnets" {
  command = plan

  variables {
    subnet_ids = [
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid1",
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid2",
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid3",
    ]
  }

  expect_failures = [var.subnet_ids]
}

run "rejects_duplicate_subnets" {
  command = plan

  variables {
    subnet_ids = [
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid1",
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid1",
    ]
  }

  expect_failures = [var.subnet_ids]
}

# OCI rejects a private load balancer that spans two subnets. Without the
# precondition this only surfaced at apply time.
run "rejects_private_load_balancer_with_two_subnets" {
  command = plan

  variables {
    is_private = true
    subnet_ids = [
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid1",
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid2",
    ]
  }

  expect_failures = [oci_load_balancer_load_balancer.this]
}

run "accepts_private_load_balancer_with_one_subnet" {
  variables {
    is_private = true
  }

  assert {
    condition     = oci_load_balancer_load_balancer.this.is_private
    error_message = "is_private should be propagated to the load balancer."
  }
}

run "accepts_public_load_balancer_with_two_subnets" {
  variables {
    subnet_ids = [
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid1",
      "ocid1.subnet.oc1..aaaaaaaaexampleuniqueid2",
    ]
  }

  assert {
    condition     = length(oci_load_balancer_load_balancer.this.subnet_ids) == 2
    error_message = "A public load balancer should accept two subnets."
  }
}

run "propagates_tags_and_network_security_groups" {
  variables {
    network_security_group_ids = ["ocid1.networksecuritygroup.oc1..aaaaaaaaexampleuniqueid"]
    freeform_tags              = { Environment = "test" }
  }

  assert {
    condition     = length(oci_load_balancer_load_balancer.this.network_security_group_ids) == 1
    error_message = "network_security_group_ids should be propagated to the load balancer."
  }

  assert {
    condition     = oci_load_balancer_load_balancer.this.freeform_tags["Environment"] == "test"
    error_message = "freeform_tags should be propagated to the load balancer."
  }
}
