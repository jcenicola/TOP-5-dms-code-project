# TOP-5 DMS SQL to RDS Week 9

## Executive Summary
*Blah Blah Blah*

## Prerequsites
- Check for existing AWS Network Infrastucture
- Source Database connectivity
- Source Database authentication

## Procedure
 *If network exists in AWS Account you are working in*

### Terraform Lookup Function 
*To check if existing network is already in place in the AWS account you are working in*  
*Example:*.   
`lookup(map, key, default)`  
 
### DMS Buildout
- RDS Target Creation (RDS)
- DMS Replication Instance Creation
- DMS Source Endpoint Creation
- DMS Target Enpoint Creation
- DMS Task Creation
  1.   Monitor TasK Execution (Table Statistics)
  2.   Validate Data Integrity on Target
  3.   Make small non-destructive change to data and validate sync is running as expected

*If network infastrucutre does not exist in AWS Account working in*
### Infastructure Buildout
- Build VPC
- Build 1 Public and 2 Private Subnets
- Build Required Securty Groups
- Build IGW
- Build NGW
- Attach NGW to Private Subnets
- Test connectivity to On Prem SQL instance
- Go to **DMS Buildout**

## References 
