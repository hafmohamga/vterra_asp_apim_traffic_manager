module "west_webapp" {
  source                = "./modules/app_services"
  rg_name               = "EIS-${var.environment}TEST-INT-SOUTHWEST-VEIS-RG"
  location              = "eastus"
  app_service_plan_name = "WestServicePlan-${var.environment}"
  app_service_name      = "EIS-${var.environment}TEST-INT-SOUTWEST-ASP1"
  repo_url              = "https://github.com/hafmohamga/WebApplication_West.git"
  branch                = "master"
}

module "east_webapp" {
  source                = "./modules/app_services"
  rg_name               = "EIS-${var.environment}TEST-INT-SOUTHWEST-VEIS-RG"
  location              = "East US"
  app_service_plan_name = "EastServicePlan-${var.environment}"
  app_service_name      = "EIS-${var.environment}TEST-INT-SOUTWEST-ASP2"
  repo_url              = "https://github.com/hafmohamga/WebApplication_East.git"
  branch                = "master"
}

module "west_network" {
  source         = "./modules/network"
  rg_name        = "EIS-${var.environment}TEST-INT-SOUTHWEST-VEIS-RG"
  location       = "eastus"
  vnet_name      = "vnet-westus-${var.environment}"
  public_ip_name = "ip-westus-${var.environment}"
  # domain_name    = "ipwestus$lower({var.environment})"
  domain_name = "ipwestuspreprod"
}

module "east_network" {
  source         = "./modules/network"
  rg_name        = "EIS-${var.environment}TEST-INT-SOUTHWEST-VEIS-RG"
  location       = "East US"
  vnet_name      = "vnet-eastus-${var.environment}"
  public_ip_name = "ip-eastus-${var.environment}"
  # domain_name    = "ipeastus$lower({var.environment})"
  domain_name = "ipeastuspreprod"
}
module "west_app_gateway" {
  source           = "./modules/app_gateway"
  name             = "app-gateway-westus-${var.environment}"
  rg_name          = "EIS-${var.environment}TEST-INT-SOUTHWEST-VEIS-RG"
  location         = "eastus"
  vnet_subnet_id   = module.west_network.subnet_id
  public_ip_id     = module.west_network.public_ip_id
  app_service_fqdn = module.west_webapp.webapp_name
}

module "east_app_gateway" {
  source           = "./modules/app_gateway"
  name             = "app-gateway-eastus-${var.environment}"
  rg_name          = "EIS-${var.environment}TEST-INT-SOUTHWEST-VEIS-RG"
  location         = "East US"
  vnet_subnet_id   = module.east_network.subnet_id
  public_ip_id     = module.east_network.public_ip_id
  app_service_fqdn = module.east_webapp.webapp_name
}
module "traffic_manager" {
  source                       = "./modules/traffic_manager"
  name                         = "traffic-profile1937-${var.environment}"
  location                     = "Central US"
  rg_name                      = "traffic_manager_rg-${var.environment}"
  profile_name                 = "traffic-profile1937-${var.environment}"
  ttl                          = 100
  monitor_protocol             = "HTTPS"
  monitor_port                 = 443
  monitor_path                 = "/"
  monitor_interval             = 30
  monitor_timeout              = 10
  monitor_failures             = 2
  primary_target_resource_id   = module.east_network.public_ip_id
  secondary_target_resource_id = module.west_network.public_ip_id
}