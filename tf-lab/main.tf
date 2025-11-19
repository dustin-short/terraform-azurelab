module "network" {
  source = "./modules/network"

  rg_name           = "rg-lab"
  location          = "eastus"
  vnet_name         = "vnet-lab"
  vnet_address_space = ["10.50.0.0/16"]

  subnets = {
    cloudflare = {
      address_prefixes = ["10.50.1.0/24"]
    }
    aks = {
      address_prefixes = ["10.50.2.0/23"]
    }
  }
}

output "subnets" {
  value = module.network.subnet_ids
}