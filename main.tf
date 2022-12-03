#####################################################
## Deployment's Root main.tf. The sub-modules are
## listed with module name and variables references
#####################################################

module "network" {
  source           = "./modules/network"
  namespace        = var.namespace
  vpc_cidr         = var.vpc_cidr
  region           = var.region
  azs              = var.azs
  public-subnets   = var.public-subnets
  app-subnets      = var.app-subnets
  database-subnets = var.database-subnets
  database-sg      = module.network.database-sg
}

module "sftp" {
  depends_on = [
    module.network
  ]
  source      = "./modules/sftp"
  namespace   = var.namespace
  region      = var.region
  environment = var.environment
}

module "iam" {
  depends_on = [
    module.sftp
  ]
  source           = "./modules/iam"
  namespace        = var.namespace
  region           = var.region
  sftp-bucket      = module.sftp.sftp-bucket
}

module "instances" {
  depends_on = [
    module.network
  ]
  source                 = "./modules/instances"
  namespace              = var.namespace
  region                 = var.region
  jump_instance_type     = var.jump_instance_type
  win_instance_type      = var.win_instance_type
  volume_size            = var.volume_size
  sql-database-server    = var.sql-database-server
  win-server-2019        = var.win-server-2019
  ec2-instance-profile   = module.iam.ec2-instance-profile
  public-sg              = module.network.public-sg
  app-sg                 = module.network.app-sg
  key_pair               = var.key_pair
  vpc_id                 = module.network.vpc_id
  public-subnets         = module.network.public-subnets
  app-subnets            = module.network.app-subnets
  azs                    = var.azs
}

module "ds" {
  depends_on = [
    module.network
  ]
  source      = "./modules/directoryservice"
  namespace   = var.namespace
  region      = var.region
  vpc_id      = module.network.vpc_id
  app-subnets = module.network.app-subnets
  # aws_secretsmanager_secret = module.ds.admin
}

module "rds" {
  depends_on = [
    module.ds
  ]
  source           = "./modules/rds"
  namespace        = var.namespace
  region           = var.region
  ds-id            = module.ds.ds-id
  rds-ad-role      = module.iam.rds-ad-role
  database-sg      = module.network.database-sg
  database-subnets = module.network.database-subnets
}

module "dms" {
  depends_on = [
    module.rds
  ]
  source           = "./modules/dms"
  namespace        = var.namespace
  region           = var.region
  # ds-id            = module.ds.ds-id
  # rds-ad-role      = module.iam.rds-ad-role
  database-sg      = module.network.database-sg
  # database-subnets = module.network.database-subnets
  target-endpoint  = module.rds.target-endpoint
  ec2instance-private_dns = module.instances.ec2instance-private_dns
}
