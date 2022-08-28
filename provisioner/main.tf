
resource "null_resource" "install_packages_on_bastion" {
  provisioner "file" {
    content     = templatefile("scripts/install-packages.sh", local.install_packages)
    destination = "/root/install-packages.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh install-packages.sh"
    ]
  }

  triggers = {
    variables = jsonencode(local.install_packages)
    files     = filesha1("scripts/install-packages.sh")
    # always_run = "${timestamp()}"
  }

  connection {
    type     = "ssh"
    host     = local.bastion_public_ip
    port     = "22"
    user     = "root"
    password = local.bastion_rootpw
  }
}

resource "null_resource" "ssh_copy_id_from_bastion_to_workers" {
  provisioner "file" {
    content     = templatefile("scripts/ssh-copy-id.sh", { servers = local.servers, rootpws = local.server_rootpws })
    destination = "/root/ssh-copy-id.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh ssh-copy-id.sh"
    ]
  }

  triggers = {
    variables = jsonencode(merge(local.servers, local.server_rootpws))
    files     = filesha1("scripts/ssh-copy-id.sh")
    # always_run = "${timestamp()}"
  }

  connection {
    type     = "ssh"
    host     = local.bastion_public_ip
    port     = "22"
    user     = "root"
    password = local.bastion_rootpw
  }
}

resource "null_resource" "set_ansible_inventory_on_bastion" {
  provisioner "file" {
    content     = templatefile("scripts/inventory.ini", { servers = local.servers })
    destination = "/root/inventory.ini"
  }

  triggers = {
    variables = jsonencode(local.servers)
    files     = filesha1("scripts/inventory.ini")
    # always_run = "${timestamp()}"
  }

  connection {
    type     = "ssh"
    host     = local.bastion_public_ip
    port     = "22"
    user     = "root"
    password = local.bastion_rootpw
  }
}


resource "null_resource" "set_etc_hosts_on_all_servers" {

  provisioner "file" {
    content     = templatefile("scripts/set-etc-hosts.yaml", { servers = local.servers })
    destination = "/root/set-etc-hosts.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -i inventory.ini set-etc-hosts.yaml"
    ]
  }

  triggers = {
    files     = sha1(join("", [filesha1("scripts/set-etc-hosts.yaml"), filesha1("scripts/inventory.ini")]))
    variables = jsonencode(local.servers)
    # always_run = "${timestamp()}"
  }

  connection {
    type     = "ssh"
    host     = local.bastion_public_ip
    port     = "22"
    user     = "root"
    password = local.bastion_rootpw
  }

  depends_on = [
    null_resource.install_packages_on_bastion,
    null_resource.ssh_copy_id_from_bastion_to_workers,
    null_resource.set_ansible_inventory_on_bastion
  ]
}

resource "null_resource" "configure_cla_for_all_servers" {

  provisioner "file" {
    content     = templatefile("scripts/configure-cla.sh", { access_key = var.access_key, secret_key = var.secret_key, servers = local.servers })
    destination = "/root/configure-cla.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh configure-cla.sh"
    ]
  }

  triggers = {
    files     = sha1(join("", [filesha1("scripts/configure-cla.sh"), filesha1("scripts/inventory.ini")]))
    variables = jsonencode(local.servers)
    # always_run = "${timestamp()}"
  }

  connection {
    type     = "ssh"
    host     = local.bastion_public_ip
    port     = "22"
    user     = "root"
    password = local.bastion_rootpw
  }

  depends_on = [
    null_resource.install_packages_on_bastion,
    null_resource.ssh_copy_id_from_bastion_to_workers,
    null_resource.set_ansible_inventory_on_bastion
  ]
}
