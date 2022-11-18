# Deploying HA Infrastructure

The first step in this project will be deploying infrastructure that you can run Prometheus and Grafana on. You will then use the servers you deployed to create an SLO/SLI dashboard. Next, you will modify existing infrastructure templates and deploy a highly-available infrastructure to AWS in multiple zones using Terrafrom. With this you will also deploy a RDS database cluster that has a replica in the alternate zone.

## Getting Started

Clone the appropriate git repo with the starter code. There will be 2 folders. Zone1 and zone2. This is where you will run the code from in your AWS Cloudshell terminal.

### Dependencies

```
- helm
- Terraform
- Postman
- kubectl
- Prometheus and Grafana
```

### Installation

1. Open your AWS console and ensure it is set for region `us-east-1`. Open the CloudShell by clicking the little shell icon in the toolbar at the top near the search box.

2. Copy the AMI to your account
**Restore image**

``` shell
aws ec2 create-restore-image-task --object-key ami-0ec6fdfb365e5fc00.bin --bucket udacity-srend --name "udacity-<your_name>"
```

* Take note of that AMI ID the script just output. Copy the AMI to `us-east-2` and `us-west-1`:
        * `aws ec2 copy-image --source-image-id <your-ami-id-from-above> --source-region us-east-1 --region us-east-2 --name "udacity-<your_name>"`
        * `aws ec2 copy-image --source-image-id <your-ami-id-from-above> --source-region us-east-1 --region us-west-1 --name "udacity-<your_name>"`
    * Make note of the ami output from the above 2 commands. You'll need to put this in the `ec2.tf` file for `zone1` for `us-east-2` and in `ec2.tf` file for `zone2` for `us-west-1` respectively
3. Close your CloudShell. Change your region to `us-east-2`. From the AWS console create an S3 bucket in `us-east-2` called `udacity-tf-<your_name>` e.g `udacity-tf-tscotto`
    * click next until created.
    * Update `_config.tf` in the `zone1` folder with your S3 bucket name where you will replace `<your_name>` with your name
    * **NOTE**: S3 bucket names MUST be globally unique!
4. Change your region to `us-west-1`. From the AWS console create an S3 bucket in `us-west-1` called `udacity-tf-<your_name>-west` e.g `udacity-tf-tscotto`
    * click next until created.
    * Update `_config.tf` in the `zone2` folder with your S3 bucket name where you will replace `<your_name>` with your name
    * **NOTE**: S3 bucket names MUST be globally unique!
5. Create a private key pair for your EC2 instances
    * Do this in **BOTH** `us-east-2` and `us-west-1`
    * Name the key `udacity`
6. Setup your CloudShell. Open CloudShell in the `us-east-2` region. Install the following:

* helm
    * `export VERIFY_CHECKSUM=false`
    * `curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash`
* terraform
    * `wget https://releases.hashicorp.com/terraform/1.0.7/terraform_1.0.7_linux_amd64.zip`
    * `unzip terraform_1.0.7_linux_amd64.zip`
    * `mkdir ~/bin`
    * `mv terraform ~/bin`
    * `export TF_PLUGIN_CACHE_DIR="/tmp"`
* kubectl
    * `curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl`
    * `chmod +x ./kubectl`
    * `mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin`
    * `echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc`

7. Deploy Terraform infrastructure
    * Clone the starter code from the git repo to a folder CloudShell
    * `cd` into the `zone1` folder
    * `terraform init`
    * `terraform apply`

**NOTE** The first time you run `terraform apply` you may see errors about the Kubernetes namespace or an RDS error. Running it again AND performing the step below should clear up those errors.

8. Setup Kubernetes config so you can ping the EKS cluster
    * `aws eks --region us-east-2 update-kubeconfig --name udacity-cluster`
    * Change kubernetes context to the new AWS cluster
        * `kubectl config use-context <cluster_name>`
            * e.g ` arn:aws:eks:us-east-2:139802095464:cluster/udacity-cluster`
    * Confirm with: `kubectl get pods --all-namespaces`
    * Then run `kubectl create namespace monitoring`

9. Login to the AWS console and copy the public IP address of your Ubuntu-Web EC2 instance. Ensure you are in the us-east-2 region.
10. Edit the `prometheus-additional.yaml` file and replace the `<public_ip>` entries with the public IP of your Ubuntu Web. Save the file.
11. Install Prometheus and Grafana
Change directories to your project directory `cd ../..`
`kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --namespace monitoring`
`helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`
`helm install prometheus prometheus-community/kube-prometheus-stack -f "values.yaml" --namespace monitoring`

Get the DNS of your load balancer provisioned to access Grafana. You can find this by opening your AWS console and going to EC2 -> Load Balancers and selecting the load balancer provisioned. The DNS name of it will be listed below that you can copy and paste into your browser. Type that into your web browser to access Grafana.

Login to Grafana with `admin` for the username and `prom-operator` for the password.

12. Install Postman from [here](https://www.postman.com/downloads/). See additional instructions for [importing the collection, and enviroment files](https://learning.postman.com/docs/getting-started/importing-and-exporting-data/#importing-postman-data)
13. Open Postman and load the files `SRE-Project-postman-collection.json` and `SRE-Project.postman_environment.json`
    1. At the top level of the project in Postman, create the `public-ip`, `email` and `token` variable in the Postman file with the public IP you gathered from above and click Save. You can choose whatever you like for the email and see the next step for the token.
    2. Run the `Initialize the Database` and `Register a User` tasks in Postman by clicking the "Send" button on top. In the register tasks, you will output a token. Use this token to create a token variable.
    3. Run `Create Event` for 100 iterations by clicking the top level `SRE Project` folder in the left-hand side and select just `Create Event` and click the Run icon in the toolbar.
    4. Run `Get all events` for 100 iterations by clicking the top level `SRE Project` folder in the left-hand side and select just `Get All Events` and click the Run icon in the toolbar.

## Project Instructions

1. Create an SLO/SLI document such as the template [here](slo_sli_template.md). You will fill in the **SLI** column with a description of what the combination category and SLO represent. You'll implement these 4 categories in 4 panels in Grafana using Prometheus queries later on. This is a good tool for creating tables in Markdown https://tableconvert.com. I recommend using that tool for MD tables since they can get hard to read in a pure text editor.
2. Create a document that details the infrastructure. This is an exercise to identity assets for failover. You will also define basic DR steps for your infrastructure. Your orgnization has provided you a [requirement document](requirements.md) for the infrastructure. Please see [this document](dr_template.md) for a template to use.
3. Open Grafana in your web browser
    1. Create a new dashboard with 4 panels. The Prometheus datasource should already be added that you can pull data from. The Flask exporter exports metrics for your EC2 instances provisioned during the install. Please note, while making the panel display the information in a way that makes sense (percentage, milliseconds, etc.) is also good, it is not necessarily a requirement. The backend query and data representation is more important. Same goes for colors and type of graph displayed.
    2. Create the 4 SLO/SLI panels as defined in the SLO/SLI document. The 4 panel categories will be availability (availability), remaining error budget (error budget), successful requests per second (throughput), and 90th percentile requests finish in this time (latency). See the following for more information on potential metrics to use https://github.com/rycus86/prometheus\_flask\_exporter
        * **NOTE**: You will not see the goal SLO numbers in your dashboard and that is fine. The application doesn't have enough traffic or time to generate a 99% availabiliy or have an error budget that works.
    3. Please submit your Prometheus queries you use for you dashboards in the `prometheus_queries.md` file [linked here](prometheus_queries.md).
    4. Please take a screenshot of your created dashboard and include that as part of your submission for the project.
    
    Screenshot

       Error budget
       Query: 1 - ((1 - (sum(increase(flask_http_request_total{instance="18.221.65.230:80", status="200"}[7d])) by (verb)) / sum(increase(flask_http_request_total{instance="18.221.65.230:80"}[7d])) by (verb)) / (1 - .80))
    <img width="717" alt="image" src="https://user-images.githubusercontent.com/71874570/202640959-ff4dfb45-9ce8-418c-beaa-a23a13fbc846.png">
    
       Latency
       Query: histogram_quantile(0.9, sum by(le, verb) (rate(flask_http_request_duration_seconds_bucket{instance="18.221.65.230:80"}[5m])))
    <img width="717" alt="image" src="https://user-images.githubusercontent.com/71874570/202641041-577dc2f3-322f-46a0-b8cd-4632d16acb60.png">
    
       Throughput
       Query: rate(flask_http_request_duration_seconds_count{instance="18.221.65.230:80"}[1m])
    <img width="714" alt="image" src="https://user-images.githubusercontent.com/71874570/202641102-5dac9bed-9fca-482b-93c3-922fa7ba3c67.png">
    
       Availability
       Query: sum(rate(flask_http_request_total{instance="18.221.65.230:80", status="200"}[5m])) / sum(rate(flask_http_request_total{instance="18.221.65.230:80"}[5m]))
    <img width="715" alt="image" src="https://user-images.githubusercontent.com/71874570/202641145-f6891f9e-e1e5-4d3b-b60f-2fe64b849d1d.png">

4. Deploy the infrastructure to zone1
    1. You will need to make sure the infrastructure is highly available. Please see the `requirements.md` document [here](requirements.md) for details on the requirements for making the infrastructure HA. You will modify your code to meet those requirements.
    **Note for availability zones** that not all regions have the same number of availability zones. You will need to lookup the AZs for `us-east-2`. You will get errors when first running the code you will have to fix!
        * For the application load balancer, please note the technical requirements:
            * This will attach to the Ubuntu VMs on port 80.
            * It should listen on port 80
    2. Make the appropriate changes to your code
        * `cd` into your `zone1` folder
        * `terraform init`
        * `terraform apply`
    3. Please take a screenshot of a successful Terraform run and include that as part of your submission for the project.
    ![telegram-cloud-photo-size-5-6316455995768943456-y](https://user-images.githubusercontent.com/71874570/202408833-b3c0161e-e76a-4d8f-af28-e48a7bc16045.jpg)
5. Deploy the infrastructure to zone2 (DR)
    3. Please take a screenshot of a successful Terraform run and include that as part of your submission for the project.
    ![telegram-cloud-photo-size-5-6318632925712724275-y](https://user-images.githubusercontent.com/71874570/202408908-f54a1400-4e48-4d6e-9c57-bcf1c8be46b1.jpg)
    * `cd` into your `zone2` folder
    * `terraform init`
    * `terraform apply`
    1. You will need to make sure the infrastructure is highly available. Please see the `requirements.md` document [here](requirements.md) for details on the requirements for making the infrastructure HA. You will modify your code to meet those requirements. **Note for availability zones** that not all regions have the same number of availability zones. You will need to lookup the AZs for `us-west-1`. You will get errors when first running the code you will have to fix in the `zone1` `main.tf` file
        * You will need to update the bucket name in the `_data.tf` file under the `zone2` folder to reflect the name of the bucket you provisioned in `us-east-2` earlier
        * For the application load balancer, please note the technical requirements:

        ```
        subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids
vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
        ```

            * This will attach to the Ubuntu VMs on port 80.
            * It should listen on port 80
            * **HINT**: we actually provisioned the VPC for us-west-1 in the `zone1` folder, so you'll need to reference the subnet and vpc ID from that module output. Here is the code block you'll need to utilize for the ALB:
    2. Make the appropriate changes to your code
6. Implement basic SQL replication and establish backups
**NOTE:** The RDS configuration is completed under the `zone1` folder. Due to the way it was implemented in Terraform BOTH region RDS instances are completed under the same Terraform project.
    1. You will need to make sure the cluster is highly available. Please see the `requirements.md` document [here](requirements.md) for details on the requirements for making the cluster HA. You will modify your code to meet those requirements. Additionally, you will need to set the following for the RDS instnaces:
        * Setup the source name and region for your RDS instance in your secondary zone
        * You will need to add multiple availability zones for the RDS module. The starter code only contains 1 zone for each RDS instance in each region.
    2. The code for the `rds-s` cluster is commented out in the `rds.tf` file under the `zone-1` folder. You will need to fix the `rds-s` module and then uncomment this code for it to work
    3. Please take a screenshot of a successful Terraform run and include that as part of your submission for the project.
    ![telegram-cloud-photo-size-5-6318632925712724417-y](https://user-images.githubusercontent.com/71874570/202408975-1787b6c8-b427-49b6-92a6-5538bf0ca3e3.jpg)
7. Destroy it all. Zone1 first, then zone2 using `terraform destroy`
    1. Please take a screenshot of the final output from Terraform showing the destroyed resources
        1. Destroy Zone2
        ![telegram-cloud-photo-size-5-6318632925712724421-y](https://user-images.githubusercontent.com/71874570/202409041-68d9e52a-2444-4c4d-b1e2-2810a41e65be.jpg)
        2. Destroy Zone1 ![telegram-cloud-photo-size-5-6318632925712724523-y](https://user-images.githubusercontent.com/71874570/202409072-6ff6ca3c-588c-4e84-8f60-d763823faf7d.jpg)
    2. There was some issues with zone1 and zone2 when destroy resources then I have deleted them manually so the screenshots don't have enough number of resources which are actually be deleted.
    **NOTE:**
8. You will need to delete the zone1 and zone2 RDS cluster manually as it will not allow you to delete the last read-replica via the Terraform code.
    * Please take a screenshot of the final Terraform run and include that as part of your submission for the project.
9. You may see errors in `terraform destroy`. In this case, we would suggest you go through [this](https://knowledge.udacity.com/questions/793669) thread on knowledge hub.

## Standout Suggestions

If you want to take your project even further going above and beyond, here are 3 standout suggestions:

1. Perform a failover of their application load balancer to their secondary region using route 53 DNS
2. Fail over the RDS instance to the secondary region so it becomes the primary target and the first region becomes the replica
3. Create an additional AWS module to provision another piece of infrastructure not discussed in the project

## License

[License](../LICENSE.md)
