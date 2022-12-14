# Microsoft SQL migration to Amazon RDS SQL via Database Migration Service

## Executive Summary
Migrating dabases can be a complex, multi-step process that involves pre-migration assessments, conversion of database schema and code, data migration, functional testing, performance tuning, and many other steps. The two fundamental steps in this process that require the most effort are the conversion of the schema and database code objects, and the migration of the data itself.

This step-by-step guide demonstrates how you can use [AWS Database Migration Service (DMS)](https://aws.amazon.com/dms/) to migrate data from a [Microsoft SQL](https://www.microsoft.com/en-us/sql-server/sql-server-2019) database to another Microsoft SQL Server databse running on an [AWS RDS](https://aws.amazon.com/rds/?p=ft&c=db&z=30). Additionally, you will use AWS DMS to continually replicate database changes from the source database to the target database in preparation for cutover to AWS.

## Prerequsites
- Check for existing AWS Network Infrastucture
- Source Database connectivity
- Source Database authentication

## Procedure

### Terraform Lookup Function 
*To check if existing network is already in place in the AWS account you are working in*  

*Example:* `lookup(map, key, default)`  

`
*codeblock here
`

 #### Discovery Question 1:  
 *Does the target network infrastructure exist in AWS Account you are working in? If so, go to [DMS BuildOut](#DMS-BuildOut)*  
 
 #### Discovery Question 2:  
 *If no network infastrucutre exists in AWS Account working in, go to [Infrastucture BuildOut](#Infastructure-BuildOut)*
 
### DMS-BuildOut
- RDS Target Creation (RDS)  
`*codeblock here
`
- DMS Replication Instance Creation  
 `*codeblock here
`
- DMS Source Endpoint Creation   
 `*codeblock here
`
- DMS Target Enpoint Creation  
  `*codeblock here
`
=======
*Example:* `lookup(map, key, default)`    

**Note:** *After discussing with team, we dertermined this to not be a effient method of discovery due to the fact of differnences between customers network configurations. Customers may have an existing network toplogy configured, however there are several reasons why automation of this task would make this not a viable process.*
- Current network toplogy may not meet the needs for the migration
- VPC may not contain the necessary configuraion to meet the needs of migration
- Not enough subnets
- Security Groups and NACLs may not meet the needs for the migration

*The time it would take to create the terraform to do this correctly would still not be generic enough to distribute with consistency is not an effient use of time. In a real world scenario, a consultant could spend 15 - 30 mins looking at the console and absorb everything needed to move forward.*

### Network Discovery (Manual)    

*Blah, Blah, Blah*


 #### Discovery Question 1:  
 *Does the target network infrastructure exist in AWS Account you are working in? If so, go to [DMS BuildOut](#DMS-BuildOut)*  
 
 #### Discovery Question 2:  
 *If no network infastrucutre exists in AWS Account working in, go to [Infrastucture BuildOut](#Infastructure-BuildOut)*
 
### DMS-BuildOut
- RDS Target Creation (RDS)  
`*codeblock here
`
- DMS Replication Instance Creation  
 `*codeblock here
`
- DMS Source Endpoint Creation   
 `*codeblock here
`
- DMS Target Enpoint Creation  
  `*codeblock here
`
- DMS Task Creation  
 `*codeblock here
`
  1.   Monitor TasK Execution (Table Statistics)
  - *Click on your task (**YOUR MIGRATION TASK**) and scroll to the Table statistics section to view the table statistics to see how many rows have been moved.*
  3.   Validate Data Integrity on Target
  4.   Make small non-destructive change to data and validate sync is running as expected


### Infastructure-BuildOut
- Build VPC
- Build 1 Public and 2 Private Subnets
- Build Required Securty Groups
- Build IGW
- Build NGW
- Attach NGW to Private Subnets
- Test connectivity to On Prem SQL instance
- Go to [DMS Buildout](#DMS-BuildOut)

## References 
[AWS Database Migration Service (DMS)](https://aws.amazon.com/dms/)

[AWS RDS](https://aws.amazon.com/rds/?p=ft&c=db&z=30)

[Microsoft SQL](https://www.microsoft.com/en-us/sql-server/sql-server-2019)


