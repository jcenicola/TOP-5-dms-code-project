# TOP-5 DMS SQL to RDS Week 9

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