variable "net_cidr" {
  type        = string
  description = "Network CIDR"
  default     = "172.31.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public Subnet CIDR"
  default     = "172.31.0.0/20"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDRs"
  default     = ["172.31.64.0/20", "172.31.96.0/20"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}

locals {
  master = {
    ami           = data.aws_ami.this.id
    instance_type = "t2.large"
  }
  interfaces = {
    worker1_eth0 = {
      subnet_id = aws_subnet.private[0].id
      ip_list   = [for i in range(1, 5) : "172.31.65.${i}"]
    }
    worker1_eth1 = {
      subnet_id = aws_subnet.private[1].id
      ip_list   = [for i in range(1, 5) : "172.31.97.${i}"]
    }
    worker2_eth0 = {
      subnet_id = aws_subnet.private[0].id
      ip_list   = [for i in range(1, 5) : "172.31.66.${i}"]
    }
    worker2_eth1 = {
      subnet_id = aws_subnet.private[1].id
      ip_list   = [for i in range(1, 5) : "172.31.98.${i}"]
    }
    worker3_eth0 = {
      subnet_id = aws_subnet.private[0].id
      ip_list   = [for i in range(1, 5) : "172.31.67.${i}"]
    }
    worker3_eth1 = {
      subnet_id = aws_subnet.private[1].id
      ip_list   = [for i in range(1, 5) : "172.31.99.${i}"]
    }
    worker4_eth0 = {
      subnet_id = aws_subnet.private[0].id
      ip_list   = [for i in range(1, 5) : "172.31.68.${i}"]
    }
    worker4_eth1 = {
      subnet_id = aws_subnet.private[1].id
      ip_list   = [for i in range(1, 5) : "172.31.100.${i}"]
    }
  }
  workers = {
    worker1 = {
      ami           = data.aws_ami.this.id
      instance_type = "t2.large"
      interfaces = [
        aws_network_interface.this["worker1_eth0"].id,
        aws_network_interface.this["worker1_eth1"].id
      ]
    }
    worker2 = {
      ami           = data.aws_ami.this.id
      instance_type = "t2.large"
      interfaces = [
        aws_network_interface.this["worker2_eth0"].id,
        aws_network_interface.this["worker2_eth1"].id
      ]
    }
    worker3 = {
      ami           = data.aws_ami.this.id
      instance_type = "t2.large"
      interfaces = [
        aws_network_interface.this["worker3_eth0"].id,
        aws_network_interface.this["worker3_eth1"].id
      ]
    }
    worker4 = {
      ami           = data.aws_ami.this.id
      instance_type = "t2.large"
      interfaces = [
        aws_network_interface.this["worker4_eth0"].id,
        aws_network_interface.this["worker4_eth1"].id
      ]
    }
  }
}
