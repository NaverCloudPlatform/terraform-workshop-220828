module "vpc" {
  source = "terraform-ncloud-modules/vpc/ncloud"

  name            = var.vpc.name
  ipv4_cidr_block = var.vpc.ipv4_cidr_block

  public_subnets       = lookup(var.vpc, "public_subnets", [])
  private_subnets      = lookup(var.vpc, "private_subnets", [])
  loadbalancer_subnets = lookup(var.vpc, "loadbalancer_subnets", [])

  network_acls      = lookup(var.vpc, "network_acls", [])
  deny_allow_groups = lookup(var.vpc, "deny_allow_groups", [])

  access_control_groups = lookup(var.vpc, "access_control_groups", [])

  public_route_tables  = lookup(var.vpc, "public_route_tables", [])
  private_route_tables = lookup(var.vpc, "private_route_tables", [])

  nat_gateways = lookup(var.vpc, "nat_gateways", [])
}

locals {
  servers = flatten([for server in var.servers : [
    for index in range(server.count) : merge(
      { name = format("%s-%03d", server.name_prefix, index + server.start_index) },
      { for k, v in server : k => v if(k != "count" && k != "name_prefix" && k != "start_index" && k != "default_network_interface" && k != "additional_block_storages") },
      { default_network_interface = merge(
        { name = format("%s-%03d-%s", server.default_network_interface.name_prefix, index + server.start_index, server.default_network_interface.name_postfix) },
        { for k, v in server.default_network_interface : k => v if(k != "name_prefix" && k != "name_postfix") }
      ) },
      { additional_block_storages = [for vol in lookup(server, "additional_block_storages", []) : merge(
        { name = format("%s-%03d-%s", vol.name_prefix, index + server.start_index, vol.name_postfix) },
        { for k, v in vol : k => v if(k != "name_prefix" && k != "name_postfix") }
      )] }
  )]])
}

module "servers" {
  source = "terraform-ncloud-modules/server/ncloud"

  for_each = { for server in local.servers : server.name => server }

  name           = each.value.name
  description    = each.value.description
  subnet_id      = module.vpc.all_subnets[each.value.subnet_name].id
  login_key_name = ncloud_login_key.loginkey.key_name

  server_image_name  = each.value.server_image_name
  product_generation = each.value.product_generation
  product_type       = each.value.product_type
  product_name       = each.value.product_name

  fee_system_type_code = lookup(each.value, "fee_system_type_code", null)
  # init_script_id       = ncloud_init_script.init_script.id

  is_associate_public_ip                 = lookup(each.value, "is_associate_public_ip", false)
  is_protect_server_termination          = lookup(each.value, "is_protect_server_termination", false)
  is_encrypted_base_block_storage_volume = lookup(each.value, "is_encrypted_base_block_storage_volume", false)

  default_network_interface = {
    name        = each.value.default_network_interface.name
    description = lookup(each.value.default_network_interface, "description", null)
    private_ip  = lookup(each.value.default_network_interface, "private_ip", null)
    access_control_group_ids = [for acg_name in each.value.default_network_interface.access_control_groups :
      acg_name == "default" ? module.vpc.vpc.default_access_control_group_no : module.vpc.access_control_groups[acg_name].id
    ]
  }

  additional_block_storages = [for vol in lookup(each.value, "additional_block_storages", []) :
    {
      name        = vol.name
      description = lookup(vol, "description", null)
      disk_type   = lookup(vol, "disk_type", null)
      size        = vol.size
    }
  ]
}


