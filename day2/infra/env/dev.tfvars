project       = "tftrain"
environment   = "dev"
location      = "westeurope"
address_space = ["10.10.0.0/16"]

subnets = [
  { name = "snet-app", cidr = "10.10.1.0/24" },
  { name = "snet-db", cidr = "10.10.2.0/24" }
]

nsg_rules = {
  "allow-ssh"  = { priority = 100, port = 22, source = "10.0.0.0/24" }
  "allow-web"  = { priority = 110, port = 443, source = "*" }
  "allow-api"  = { priority = 120, port = 8080, source = "10.10.1.0/24" }
  "allow-ardp" = { priority = 121, port = 3389, source = "10.10.1.0/24" }
}