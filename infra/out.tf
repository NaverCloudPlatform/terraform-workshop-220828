output "servers" {
  value = { for k, v in module.servers :
    k => {
      name       = v.server.name
      id         = v.server.id
      private_ip = v.server.network_interface[0].private_ip
      public_ip  = v.server.public_ip
    }
  }
}

data "ncloud_root_password" "all" {
  for_each = module.servers

  server_instance_no = each.value.server.id
  private_key        = ncloud_login_key.loginkey.private_key
}

output "server_rootpws" {
  value     = { for k, v in data.ncloud_root_password.all : k => v.root_password }
  sensitive = true
}


