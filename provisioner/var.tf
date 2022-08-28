
variable "access_key" {}
variable "secret_key" {}

locals {
  servers           = data.terraform_remote_state.infra.outputs.servers
  server_rootpws    = sensitive(data.terraform_remote_state.infra.outputs.server_rootpws)
  bastion_public_ip = local.servers["svr-workshop-bastion-001"].public_ip
  bastion_rootpw    = sensitive(local.server_rootpws["svr-workshop-bastion-001"])

  install_packages = {
    yum_packages  = []
    pip_packages  = ["setuptools_rust", "ansible"]
    snap_packages = []
  }
}


# output "bastion" {
#   value = nonsensitive("${local.bastion_public_ip} / ${local.bastion_rootpw}")
# }
