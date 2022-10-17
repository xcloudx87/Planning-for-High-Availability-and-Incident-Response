# Infrastructure

## AWS Zones

us-east-2, us-west-1

## Servers and Clusters

### Table 1.1 Summary

| Asset | Purpose | Size | Qty | DR |
| ----- | ------- | ---- | --- | --- |
| Asset name | Brief description | AWS size eg. t3.micro (if applicable, not all assets will have a size) | Number of nodes/replicas or just how many of a particular asset | Identify if this asset is deployed to DR, replicated, created in multiple locations or just stored elsewhere |
| EC2 | for VM | t3.micro | 3 | Yes |
| Kubernetes nodes | K8s to deploy application |  | 2 | Yes |
| VPC | To setup DR/HA on |  | 2 | Yes |
| ALB | Load balance traffic |  | 2 | Yes |
| SQL Cluster nodes | Store data |  | 2 | Yes |
|  |  |  |  |  |

### Descriptions

More detailed descriptions of each asset identified above.

## DR Plan

### Pre-Steps:

Prepare terraform scripts and check resource available in region and pricing. Run terraform script to provision and test again to ensure everything is deployed correctly.

## Steps:

You won't actually perform these steps, but write out what you would do to "fail-over" your application and database cluster to the other region. Think about all the pieces that were setup and how you would use those in the other region