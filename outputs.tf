output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public-subnets" {
  value = module.vpc.public_subnets
}

output "private-subnets" {
  value = module.vpc.private_subnets
}

output "database-subnets" {
  value = module.vpc.database_subnets
}
