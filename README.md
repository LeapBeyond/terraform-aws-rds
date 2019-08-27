# RDS Demonstration

This project sets up a VPC with several public subnets - one for each availability zone - into which a SQL Server RDS instance is set up.

This is _not_ for setting up an RDS instance for any purposes other than development and testing Transact SQL.

## Prequisites
It is assumed that:
 - appropriate AWS credentials are available
 - terraform is available (this was developed with 0.11.11 and provider.aws v2.22.0)

## Usage
 - update `backend.tf` to specify your own Terraform backend
 - check `variables.tf` to see if there are values you want to change
 - create `terraform.tfvars` from `terraform.tfvars.template`
 - apply `terraform init` then `terraform apply`

On successful completion, information is reported that you may need:

```
Outputs:

db_arn = arn:aws:rds:eu-west-2:410740436769:db:aws-rds20190827
db_endpoint = aws-rds20190827.ctix75zkhsex.eu-west-2.rds.amazonaws.com:1433
db_user = sa
```

*NOTE* creating the RDS instance is a slow operation, although all other components will be created quickly. You can anticipate it taking 15-20 minutes for completion.

## Implementation note
There are two things to note with this implementation. First, you may question why a VPC is created for the test. For me there are two reasons: I have locked down my default VPC to avoid accidental exposure of assets; and building a separate VPC is a good way for me to isolate assets for different projects.

Second, note that the database instance is publicly available (although locked down by security groups to specific CIDR ranges). This is _not_ recommended practice and under no circumstances should a production database ever be open to the public internet.

## Teardown

To teardown the infrastructure, execute `terraform destroy`. This may take several minutes to execute as tearing down the VPC can be slow. If the tear down fails, you may need to re-execute the destroy command - Terraform can be poor at destroying VPC dependencies in the expected order. If re-executing fails, I'm afraid you may have to remove the VPC dependencies by hand and do a final `terraform destroy` to clean up.
