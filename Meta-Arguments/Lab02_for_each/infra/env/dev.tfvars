project     = "tftrain" # change to your own unique value
environment = "dev"
location    = "westeurope"

vnets = {
  shared = { address_space = "10.0.0.0/16", tier = "shared" }
  #dev    = { address_space = "10.1.0.0/16", tier = "workload" }
  prod = { address_space = "10.2.0.0/16", tier = "workload" }
}

extra_locations = ["northeurope"]
