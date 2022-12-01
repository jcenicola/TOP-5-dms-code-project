# TOP-5 DMS SQL to RDS Week 9

## Executive Summary
*Blah Blah Blah*

## Prerequsites
- Check for existing AWS Network Infrastucture
- Source Database

## Steps
*If network exists in AWS Account you are working in*
### DMS Buildout
- RDS Target Creation
- DMS Replication Instance Creation
- DMS Source Endpoint Creation
- DMS Target Enpoint Creation
- DMS Task Creation
&ensp;-   Monitor TasK Execution (Table Statistics)
-   Validate Data Integrity on Target
-   Make small non-destructive change to data and validate sync is running as expected

*If network infastrucutre does not exist in AWS Account working in*
### Infastructure Buildout
- Build VPC
- Build 1 Public and 2 Private Subnets
- Build Required Securty Groups
- Build IGW
- Build NGW
- Attach NGW to Private Subnets

## References 
