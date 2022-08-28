vpc = {
  name            = "vpc-workshop"
  ipv4_cidr_block = "10.0.0.0/16"

  public_subnets = [
    {
      name        = "sbn-workshop-public"
      zone        = "KR-1"
      subnet      = "10.0.0.0/24"
      network_acl = "default"
    }
  ]
  private_subnets = [
    {
      name        = "sbn-workshop-private"
      zone        = "KR-1"
      subnet      = "10.0.1.0/24"
      network_acl = "default"
    }
  ]

  access_control_groups = [
    {
      name        = "acg-workshop-public"
      description = "ACG for public servers"
      inbound_rules = [
        ["TCP", "0.0.0.0/0", 22, "SSH allow form any"]
      ]
      outbound_rules = [
        ["TCP", "0.0.0.0/0", "1-65535", "All allow to any"],
        ["UDP", "0.0.0.0/0", "1-65535", "All allow to any"]
      ]
    },
    {
      name        = "acg-workshop-private"
      description = "ACG for private servers"
      inbound_rules = [
        ["TCP", "acg-workshop-public", 22, "SSH allow form acg-workshop-public"]
      ]
      outbound_rules = [
        ["TCP", "0.0.0.0/0", "1-65535", "All allow to any"],
        ["UDP", "0.0.0.0/0", "1-65535", "All allow to any"]
      ]
    }
  ]
}


################################

servers = [
  {
    count       = 1
    start_index = 1

    name_prefix    = "svr-workshop-bastion"
    description    = "bastion server"
    vpc_name       = "vpc-workshop"
    subnet_name    = "sbn-workshop-public"
    login_key_name = "key-workshop"

    server_image_name  = "CentOS 7.8 (64-bit)"
    product_generation = "G2"
    product_type       = "High CPU"
    product_name       = "vCPU 2EA, Memory 4GB, [SSD]Disk 50GB"

    is_associate_public_ip = true

    default_network_interface = {
      name_prefix           = "nic-workshop-bastion"
      name_postfix          = "def"
      description           = "default nic for bastion server"
      access_control_groups = ["acg-workshop-public"]
    }
  },
  {
    count       = 3
    start_index = 1

    name_prefix    = "svr-workshop-worker"
    description    = "worker servers"
    vpc_name       = "vpc-workshop"
    subnet_name    = "sbn-workshop-private"
    login_key_name = "key-workshop"

    server_image_name  = "CentOS 7.8 (64-bit)"
    product_generation = "G2"
    product_type       = "High CPU"
    product_name       = "vCPU 2EA, Memory 4GB, [SSD]Disk 50GB"

    is_associate_public_ip = false

    default_network_interface = {
      name_prefix           = "nic-workshop-worker"
      name_postfix          = "def"
      description           = "default nic for worker servers"
      access_control_groups = ["acg-workshop-private"]
    }
  }
]
