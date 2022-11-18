# 1Infrastructure

## AWS Zones

* Zone 1: us-east-2a, us-east-2b, us-east-2c
* Zone 2: us-west-1b, us-west-1c

## Servers and Clusters

### Table 1.1 Summary

| Asset | Purpose | Size | Qty | DR |
| ----- | ------- | ---- | --- | --- |
| Asset name | Brief description | AWS size eg. t3.micro (if applicable, not all assets will have a size) | Number of nodes/replicas or just how many of a particular asset | Identify if this asset is deployed to DR, replicated, created in multiple locations or just stored elsewhere |
| EC2 | for VM | t3.micro | 3 | Deployed to DR |
| EKS Nodes | K8s node to deploy application | t3.medium | 2 | Deployed to DR |
| VPC | To setup DR/HA on |  | multiple each az | Deployed to DR |
| ALB | Load balance traffic |  | 1 | Deployed to DR |
| RDS | Store data | db.t2.small | 2 (1 read, 1 write) | Deployed to DR |
|  |  |  |  |  |

### Descriptions

More detailed descriptions of each asset identified above.

* EC2 instane: It is a virtual machine running on AWS infrastructure. We will use it to host application on.
* VPC: enables us to launch AWS resources into a virtual network that you've defined. This virtual network closely resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS.
* EKS Nodes: Amazon EKS nodes run in our AWS account and connect to the control plane of our cluster through the cluster API server endpoint. We deploy one or more nodes into a node group. Microservices will be deployed as pod on those nodes.
* ALB: an application load balancer automatically distributes your incoming traffic across multiple targets, such as EC2 instances, containers, and IP addresses, in one or more Availability Zones. It monitors the health of its registered targets, and routes traffic only to the healthy targets.
* RDS: is a collection of managed services that makes it simple to set up, operate, and scale databases in the cloud. We will use it to configure a databse cluster to keep database high availability.

## DR Plan

### Pre-Steps:

Prepare terraform scripts and check resource available in region and pricing. Run terraform script to provision redundancy architecture for every resource in DC site and test again to ensure everything is deployed correctly.

1\. Planning infrastructure in zone1 and zone2 to be the same
2\. Deploy infrastructure using terraform
3\. Verify infrastructure in zone2 to make sure it deployed successfully and be the same as zone 1

## Steps:

You won't actually perform these steps, but write out what you would do to "fail-over" your application and database cluster to the other region. Think about all the pieces that were setup and how you would use those in the other region

1\. Create a load balancer in zone2 and point a domain to it\. If we got issue in zone1 we will just need to re\-point DNS entry at DNS provider to load balancer in zone2\.

2\. Setup database replication between zone1 and zone2\. If we got issue in zone1 we just need to perform database fail\-over then application will continue to work properly with new writer instance\.