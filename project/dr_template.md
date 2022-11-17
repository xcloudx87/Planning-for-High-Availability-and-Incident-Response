# 1Infrastructure

## AWS Zones

* Zone 1: us-east-2a, us-east-2b
* Zone 2: us-west-1b, us-west-1c

## Servers and Clusters

### Table 1.1 Summary

| Asset | Purpose | Size | Qty | DR |
| ----- | ------- | ---- | --- | --- |
| Asset name | Brief description | AWS size eg. t3.micro (if applicable, not all assets will have a size) | Number of nodes/replicas or just how many of a particular asset | Identify if this asset is deployed to DR, replicated, created in multiple locations or just stored elsewhere |
| EC2 | for VM | t3.micro | 3 | Deployed to DR |
| EKS Nodes | K8s node to deploy application | t3.medium | 2 | Deployed to DR |
| VPC | To setup DR/HA on |  | multiple each az | Deployed to DR |
| ALB | Load balance traffic |  | 1 | It is regional then no need to have more |
| RDS | Store data | db.t2.small | 2 (1 read, 1 write) | Deployed to DR |
|  |  |  |  |  |

### Descriptions

More detailed descriptions of each asset identified above.

* EC2 instane: for application running on it
* VPC:to setup infrastructure on it
* EKS Nodes:equivalent to Kubernetes worker node, we will deploy application as pod on it
* ALB: an application load balancer support to share request between application instances behind.
* RDS: a relational database managed by AWS to host our data on it.

## DR Plan

### Pre-Steps:

Prepare terraform scripts and check resource available in region and pricing. Run terraform script to provision and test again to ensure everything is deployed correctly.

## Steps:

You won't actually perform these steps, but write out what you would do to "fail-over" your application and database cluster to the other region. Think about all the pieces that were setup and how you would use those in the other region