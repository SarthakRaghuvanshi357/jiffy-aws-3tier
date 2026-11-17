# Jiffy – Three-Tier Web Application Deployment on AWS

> A hands-on cloud deployment project demonstrating a segmented AWS network, private application and database layers, load balancing, scaling components, and deployment of a web application.

## Table of Contents

- [Project Overview](#project-overview)
- [Project Objectives](#project-objectives)
- [Architecture](#architecture)
- [AWS Services and Technologies](#aws-services-and-technologies)
- [Repository Structure](#repository-structure)
- [Implementation Report](#implementation-report)
  - [1. Source Code and S3 Bucket](#1-source-code-and-s3-bucket)
  - [2. IAM Role for EC2](#2-iam-role-for-ec2)
  - [3. VPC Creation](#3-vpc-creation)
  - [4. Subnet Design](#4-subnet-design)
  - [5. Internet Gateway](#5-internet-gateway)
  - [6. NAT Gateways](#6-nat-gateways)
  - [7. Route Tables and Routing](#7-route-tables-and-routing)
  - [8. Security Groups](#8-security-groups)
  - [9. RDS DB Subnet Group and Database](#9-rds-db-subnet-group-and-database)
  - [10. Application-Tier EC2 Instance](#10-application-tier-ec2-instance)
  - [11. Database Connectivity and Validation](#11-database-connectivity-and-validation)
  - [12. Application Deployment](#12-application-deployment)
  - [13. Application Health Checks](#13-application-health-checks)
  - [14. Application-Tier AMI, Target Group and Internal ALB](#14-application-tier-ami-target-group-and-internal-alb)
  - [15. Application-Tier Launch Template and Auto Scaling](#15-application-tier-launch-template-and-auto-scaling)
  - [16. Web-Tier EC2 Instance and Nginx](#16-web-tier-ec2-instance-and-nginx)
  - [17. Web-Tier Troubleshooting](#17-web-tier-troubleshooting)
  - [18. Web-Tier AMI, Target Group and Public ALB](#18-web-tier-ami-target-group-and-public-alb)
- [Request Flow](#request-flow)
- [Security Considerations](#security-considerations)
- [Testing and Validation](#testing-and-validation)
- [Challenges and Troubleshooting](#challenges-and-troubleshooting)
- [Screenshot Checklist](#screenshot-checklist)
- [Possible Improvements](#possible-improvements)
- [Learning Outcomes](#learning-outcomes)
- [Author](#author)

---

## Project Overview

Jiffy is a grocery quick-commerce web application deployed using a three-tier architecture on Amazon Web Services (AWS). The infrastructure separates the user-facing web layer, backend application layer, and relational database layer.

The network is designed with a VPC spanning two Availability Zones. Public subnets are used for internet-facing web components, while private subnets are used for application and database resources. An internet gateway provides internet connectivity to public resources, and NAT gateways provide outbound internet access for resources in private application subnets.

The web layer uses Nginx to serve the frontend and forward API requests to an internal Application Load Balancer (ALB). The internal ALB routes requests to the Node.js application tier on port `4000`. The application tier communicates with an Amazon RDS MySQL-compatible database in private subnets.

## Project Objectives

- Design an isolated AWS network using Amazon VPC.
- Create public and private subnets across two Availability Zones.
- Configure internet and outbound connectivity using an Internet Gateway and NAT Gateways.
- Control communication between tiers using security groups.
- Deploy a managed relational database in private subnets.
- Deploy a Node.js backend and connect it to the database.
- Serve the frontend using Nginx on an EC2 instance.
- Route requests through load balancers and configure scaling components.
- Validate network, application, and database connectivity.

## Architecture

### Three-tier design

1. **Web tier:** Nginx on EC2 in public subnets. It serves the frontend and proxies API requests to the internal ALB.
2. **Application tier:** Node.js/Express on EC2 in private application subnets. The application listens on port `4000`.
3. **Database tier:** Amazon RDS MySQL-compatible database in private database subnets.

### High-level request path

```text
                         Users / Web Browser
                                 |
                                 v
                 Internet-facing Application Load Balancer
                                 |
                                 v
                     Web Tier – EC2 / Nginx
                     Public Subnets (2 AZs)
                                 |
                                 v
                    Internal Application Load Balancer
                                 |
                                 v
                  Application Tier – EC2 / Node.js
                    Private App Subnets (2 AZs)
                                 |
                                 v
                       Amazon RDS Database
                    Private DB Subnets (2 AZs)
```

**Network connectivity:**

- Public subnet default route: `0.0.0.0/0` → Internet Gateway.
- Private application subnet default route: `0.0.0.0/0` → NAT Gateway in the corresponding Availability Zone.
- Database subnets remain private; database access is allowed from the application-tier security group on MySQL port `3306`.

> Add your final AWS architecture diagram here when ready. Suggested image path: `screenshots/00-aws-architecture.png`.

## AWS Services and Technologies

| Service / Technology | Role in the project |
|---|---|
| Amazon VPC | Isolated network for the application |
| Public and private subnets | Network segmentation across Availability Zones |
| Internet Gateway | Internet connectivity for public subnets |
| NAT Gateway and Elastic IP | Outbound internet access from private application subnets |
| Route Tables | Control traffic paths for subnet groups |
| Security Groups | Instance- and load-balancer-level traffic control |
| Amazon EC2 | Hosts web and application components |
| AWS IAM | Grants EC2 permissions to access required AWS services |
| AWS Systems Manager Session Manager | Secure instance administration without SSH key pairs |
| Amazon S3 | Stores deployment files and application assets |
| Elastic Load Balancing (ALB) | Distributes incoming requests to target groups |
| EC2 Auto Scaling | Maintains the configured application/web instance capacity |
| Amazon RDS | Managed relational database |
| MySQL | Relational database engine |
| Node.js and Express | Backend application runtime and framework |
| Nginx | Web server and reverse proxy |
| PM2 | Keeps the Node.js process running |
| Git and GitHub | Source-code version control |

## Repository Structure

The exact directory layout can vary depending on the version of the source code used. The project documentation refers to the following main components:

```text
Jiffy/
├── app-tier/
│   ├── index.js
│   ├── DbConfig.js
│   ├── TransactionService.js
│   ├── package.json
│   └── package-lock.json
├── web-tier/
│   ├── index.html
│   ├── nginx.conf
│   └── build/                 # Generated frontend build, if applicable
├── database/
│   └── schema.sql             # Include if this file exists in your repository
├── screenshots/
└── README.md
```

Update this tree if your committed repository has a different structure. Do not commit `node_modules`, passwords, private keys, or other secrets.

---

# Implementation Report

The following sections document the AWS setup and deployment workflow described in the supplied project material. Replace example names and placeholders with your actual resource names where needed.

## 1. Source Code and S3 Bucket

**Objective:** Prepare the application source code and create an S3 bucket for deployment files.

**Implementation:**

1. Download or clone the application source repository to the local environment.
2. Open the Amazon S3 service in the AWS Management Console.
3. Create a bucket with a globally unique name.
4. Select the same AWS Region that will be used for the project resources.
5. Keep the bucket private and use it to store the application deployment files.

**Purpose:** Amazon S3 provides a central location from which EC2 instances with appropriate IAM permissions can retrieve application files.

**Validation:** Confirm that the bucket is created in the intended Region and that the required project folders are uploaded.

**Screenshot:** `screenshots/01-s3-bucket.png`

## 2. IAM Role for EC2

**Objective:** Allow EC2 instances to retrieve files from S3 and connect through Systems Manager Session Manager.

**Implementation:**

1. Open IAM → Roles → Create role.
2. Select **AWS service** as the trusted entity and **EC2** as the use case.
3. Attach the policies documented for this lab:
   - `AmazonSSMManagedInstanceCore`
   - `AmazonS3ReadOnlyAccess`
4. Give the role a descriptive name and create it.
5. Attach this role as the instance profile when launching the EC2 instances.

**Purpose:** The role provides AWS permissions to the EC2 instance without storing long-lived AWS access keys on the server. Systems Manager enables browser-based administration without requiring an SSH key pair.

**Validation:** Confirm that the EC2 instance has the role attached and appears as a managed node in Systems Manager.

**Screenshot:** `screenshots/02-iam-ec2-role.png`

## 3. VPC Creation

**Objective:** Create an isolated virtual network for all project resources.

**Implementation:**

1. Open the Amazon VPC console and select **Your VPCs**.
2. Choose **Create VPC** and select the VPC-only option.
3. Enter a descriptive name and an IPv4 CIDR range large enough to accommodate the planned six subnets.
4. Create the VPC in the selected Region.

**Purpose:** The VPC provides a logically isolated network where web, application, and database resources can communicate according to the configured routing and security rules.

**Validation:** Confirm that the VPC is available and that its CIDR range covers the subnet address ranges.

**Screenshot:** `screenshots/03-vpc-created.png`

## 4. Subnet Design

**Objective:** Divide the VPC into public and private network segments across two Availability Zones.

**Implementation:**

Create six subnets in total:

| Layer | Availability Zone 1 | Availability Zone 2 |
|---|---|---|
| Web | Public Web Subnet AZ-1 | Public Web Subnet AZ-2 |
| Application | Private App Subnet AZ-1 | Private App Subnet AZ-2 |
| Database | Private DB Subnet AZ-1 | Private DB Subnet AZ-2 |

For each subnet:

1. Select the project VPC.
2. Provide a descriptive subnet name.
3. Select the required Availability Zone.
4. Assign a non-overlapping CIDR range that is contained within the VPC CIDR range.
5. Create the subnet.

**Purpose:** Separating tiers into different subnets improves network organization and allows different routing and security policies to be applied to each layer. Using two Availability Zones supports a multi-AZ design.

**Validation:** Confirm that all six subnets belong to the correct VPC and are distributed across two Availability Zones.

**Screenshots:**
- `screenshots/04a-public-web-subnets.png`
- `screenshots/04b-private-app-subnets.png`
- `screenshots/04c-private-db-subnets.png`

## 5. Internet Gateway

**Objective:** Provide internet connectivity to resources in the public subnets.

**Implementation:**

1. Open VPC → Internet Gateways.
2. Create an Internet Gateway with a descriptive name.
3. Select the newly created gateway.
4. Choose **Attach to a VPC**.
5. Select the project VPC and attach the gateway.

**Purpose:** An Internet Gateway enables communication between the VPC and the internet when the subnet route table directs internet-bound traffic to it and the resource has the required public addressing and security rules.

**Validation:** Confirm that the Internet Gateway is attached to the correct VPC.

**Screenshot:** `screenshots/05-internet-gateway.png`

## 6. NAT Gateways

**Objective:** Allow instances in private application subnets to initiate outbound internet connections without assigning them public IP addresses.

**Implementation:**

1. Open VPC → NAT Gateways and choose **Create NAT Gateway**.
2. Select a public subnet.
3. Allocate and associate an Elastic IP address.
4. Create the NAT Gateway.
5. Repeat for the public subnet in the second Availability Zone, as described in the project setup.

**Purpose:** Private application instances may need outbound access to download packages, updates, or dependencies. A NAT Gateway allows outbound connections while preventing unsolicited inbound internet connections from being initiated through the NAT Gateway.

**Validation:** Wait until each NAT Gateway is available and confirm that the private application route tables point to the intended NAT Gateway.

**Screenshot:** `screenshots/06-nat-gateways.png`

## 7. Route Tables and Routing

**Objective:** Define how traffic moves between the VPC, internet gateway, NAT gateways, and subnets.

**Implementation:**

### Public route table

1. Create a route table associated with the project VPC.
2. Add the default route `0.0.0.0/0` with the Internet Gateway as the target.
3. Associate the route table with both public web subnets.

### Private application route tables

1. Create a route table for the private application subnet in each Availability Zone.
2. Add the default route `0.0.0.0/0` to the NAT Gateway in the corresponding Availability Zone.
3. Associate each route table with its matching private application subnet.

### Database route table

The database subnets are intended to remain private. Their route table should not provide a direct route to an Internet Gateway or NAT Gateway unless a specific documented requirement calls for it.

**Purpose:** Route tables determine where subnet traffic is sent. Public web subnets use the Internet Gateway, while private application subnets use NAT for outbound internet access.

**Validation:** Review both the Routes and Subnet Associations tabs for each route table.

**Screenshot:** `screenshots/07-route-tables-and-associations.png`

## 8. Security Groups

**Objective:** Restrict traffic so that each tier accepts only the connections required for the architecture.

The supplied setup describes five security groups:

| Security group | Inbound traffic described in the project material |
|---|---|
| Public load balancer SG | HTTP (port 80) from the permitted client IP |
| Web tier SG | HTTP (port 80) from the public load balancer SG; an additional test rule from the client IP is described |
| Internal load balancer SG | HTTP (port 80) from the web tier SG |
| Private application instance SG | TCP (port 4000) from the internal load balancer SG |
| Database SG | MySQL (port 3306) from the private application instance SG |

**Implementation:**

1. Open VPC → Security Groups.
2. Create each security group in the project VPC.
3. Add the required inbound rules using the source security group or client CIDR described above.
4. Review outbound rules and keep only the traffic required by the application.
5. Attach the appropriate security group to each load balancer or EC2/RDS resource.

**Purpose:** Security groups act as virtual firewalls. Referencing another security group as a source helps restrict access to resources belonging to the intended tier.

**Security note:** A rule using `0.0.0.0/0` permits traffic from any IPv4 address. Use it only when required for a public-facing service, and restrict administrative or testing access to trusted IP ranges. Remove temporary testing rules after use.

**Validation:** Check the inbound rules and confirm that the application can reach the database on port `3306` and that the internal ALB can reach the application on port `4000`.

**Screenshot:** `screenshots/08-security-groups.png`

## 9. RDS DB Subnet Group and Database

**Objective:** Deploy the relational database in private subnets.

**Implementation:**

### Create a DB subnet group

1. Open Amazon RDS → Subnet Groups.
2. Create a DB subnet group and select the project VPC.
3. Add the database-layer subnets from both Availability Zones.
4. Create the subnet group.

### Create the database

1. Open RDS → Databases → Create database.
2. Select the MySQL-compatible engine option documented for the deployment.
3. Select the Dev/Test template for the lab environment.
4. Configure the database name/instance identifier and administrator credentials.
5. Select the project VPC and the DB subnet group.
6. Set **Public access** to **No**.
7. Attach the database security group.
8. Complete database creation and wait for the database to become available.
9. Record the writer endpoint securely for application configuration.

**Purpose:** RDS provides a managed relational database. Placing it in private subnets and disabling public access reduces direct exposure to the internet.

**Validation:** Confirm the database is available, is associated with the correct VPC/subnet group/security group, and has a writer endpoint.

**Important accuracy note:** The supplied workshop material refers to a MySQL-compatible Amazon Aurora deployment and describes writer and reader instances. If your actual console resource was standard Amazon RDS for MySQL rather than Aurora, change the engine wording here to match the resource you created.

**Screenshots:**
- `screenshots/09a-rds-db-subnet-group.png`
- `screenshots/09b-rds-database-configuration.png`
- `screenshots/09c-rds-available-endpoint.png`

## 10. Application-Tier EC2 Instance

**Objective:** Launch a backend server in a private application subnet.

**Implementation:**

1. Open EC2 → Instances → Launch instances.
2. Select the Amazon Linux AMI and instance type used in the lab (the supplied instructions use `t2.micro`).
3. Do not select a key pair if using Systems Manager Session Manager and the required IAM role is configured.
4. Under Network settings, select the project VPC and a private application subnet.
5. Disable auto-assignment of a public IP.
6. Attach the private application instance security group.
7. Under Advanced details, select the EC2 IAM instance profile.
8. Launch the instance.

**Purpose:** The backend server remains in a private subnet and is not directly exposed through a public IP address.

**Validation:** Confirm the instance is running in the correct private subnet, has no public IP, and has the intended security group and IAM role.

**Screenshot:** `screenshots/10-app-tier-ec2.png`

## 11. Database Connectivity and Validation

**Objective:** Confirm that the application-tier instance can connect to the private database.

**Implementation:**

1. Connect to the application instance using Systems Manager Session Manager.
2. Switch to the `ec2-user` account where required by the environment.
3. Install the MySQL command-line client.
4. Connect using the RDS writer endpoint and database username:

```bash
mysql -h <RDS-WRITER-ENDPOINT> -u <DB-USERNAME> -p
```

5. Enter the database password when prompted.
6. Create and select the database used by the workshop:

```sql
CREATE DATABASE webappdb;
SHOW DATABASES;
USE webappdb;
```

7. Create the sample transactions table:

```sql
CREATE TABLE IF NOT EXISTS transactions (
    id INT NOT NULL AUTO_INCREMENT,
    amount DECIMAL(10,2),
    description VARCHAR(100),
    PRIMARY KEY (id)
);
```

8. Insert a sample record and verify it:

```sql
INSERT INTO transactions (amount, description)
VALUES (400, 'groceries');

SELECT * FROM transactions;
```

**Purpose:** This validates private network connectivity from the application tier to the database and confirms that the database accepts SQL operations.

**Validation:** The project notes record a successful connection to the RDS endpoint, creation of `webappdb`, creation of the `transactions` table, and retrieval of the inserted `groceries` record.

**Screenshots:**
- `screenshots/11a-ssm-session-manager.png`
- `screenshots/11b-rds-mysql-connection.png`
- `screenshots/11c-database-table-and-test-record.png`

## 12. Application Deployment

**Objective:** Install and run the Node.js backend on the private application instance.

**Implementation described in the project material:**

1. Configure the application's database connection with the RDS endpoint, database username, password, and database name.
2. Upload the `app-tier` folder to the S3 bucket.
3. Connect to the application instance through Session Manager.
4. Install NVM and Node.js 16 as specified by the supplied workshop instructions.
5. Install PM2 globally.
6. Copy the application folder from S3:

```bash
aws s3 cp s3://<BUCKET-NAME>/app-tier/ app-tier --recursive
```

7. Install dependencies and start the backend:

```bash
cd ~/app-tier
npm install
pm2 start index.js
pm2 list
```

8. Configure PM2 startup as required and save the process list:

```bash
pm2 startup
pm2 save
```

**Purpose:** Node.js runs the backend API, while PM2 manages the process so it can continue running after the terminal session ends and can be configured to start after a reboot.

**Validation:** `pm2 list` should show the application process as `online`. Use `pm2 logs` to inspect application errors.

**Credential warning:** Do not put database passwords in source code, README files, screenshots, shell history, or GitHub commits. The supplied project document contains a database credential in an example/configuration transcript. Treat any real credential exposed there as compromised: rotate it in RDS, update the application securely, and remove it from repository history where applicable. Prefer AWS Secrets Manager or another secure secret-injection method.

**Screenshot:** `screenshots/12-node-app-pm2-online.png`

## 13. Application Health Checks

**Objective:** Verify that the backend is running and can read data from the database.

**Implementation and tests:**

Check the application health endpoint locally:

```bash
curl http://localhost:4000/health
```

The supplied workshop describes a successful response as:

```text
This is the health check
```

Test the database-backed endpoint:

```bash
curl http://localhost:4000/transaction
```

The expected response is JSON containing the transaction records inserted into the database. The source material records a successful response containing the `groceries` transaction.

**Purpose:** The health endpoint checks application availability, while the transaction endpoint verifies the backend-to-database integration.

**Validation:** Confirm both endpoints return the expected response before connecting the application tier to the internal load balancer.

**Screenshot:** `screenshots/13-app-health-and-api-test.png`

## 14. Application-Tier AMI, Target Group and Internal ALB

**Objective:** Prepare the application tier for load-balanced deployment across private subnets.

### Create an application-tier AMI

1. Select the configured application EC2 instance.
2. Choose Actions → Image and templates → Create image.
3. Provide an image name and description.
4. Wait for the AMI to become available.

### Create the application target group

1. Open EC2 → Target Groups → Create target group.
2. Select **Instances** as the target type.
3. Choose HTTP and port `4000`.
4. Select the project VPC.
5. Set the health check path to `/health`.
6. Create the target group.

### Create the internal Application Load Balancer

1. Open EC2 → Load Balancers → Create Load Balancer.
2. Select Application Load Balancer.
3. Choose **Internal** as the scheme.
4. Select the project VPC and private application subnets.
5. Attach the internal load balancer security group.
6. Configure an HTTP listener on port `80`.
7. Forward requests to the application target group.

**Purpose:** The internal ALB provides a private entry point for web-tier API traffic and distributes requests to healthy application instances.

**Validation:** Confirm the ALB is internal, uses the correct private subnets and security group, and forwards to the target group on port `4000` with `/health` checks.

**Screenshots:**
- `screenshots/14a-app-tier-ami.png`
- `screenshots/14b-app-target-group.png`
- `screenshots/14c-internal-alb.png`

## 15. Application-Tier Launch Template and Auto Scaling

**Objective:** Define a repeatable application-instance configuration and configure an Auto Scaling group.

**Implementation:**

1. Open EC2 → Launch Templates → Create launch template.
2. Select the application-tier AMI created earlier.
3. Select the instance type used by the project.
4. Configure the application-tier security group.
5. Attach the EC2 IAM instance profile.
6. Leave network placement to the Auto Scaling group configuration.
7. Create an Auto Scaling group using the launch template.
8. Select the project VPC and both private application subnets.
9. Attach the application target group.
10. Configure the minimum, desired, and maximum capacity as recorded in the supplied instructions (the workshop specifies `2` for each).

**Purpose:** The launch template standardizes new instances, while Auto Scaling maintains the configured number of application instances. The internal ALB distributes requests to registered healthy targets.

**Validation:** Confirm the Auto Scaling group uses both private application subnets and the correct target group. Check that the desired instances launch and become healthy. The workshop describes terminating a test instance to observe replacement by the Auto Scaling group.

**Screenshot:** `screenshots/15-app-tier-auto-scaling.png`

## 16. Web-Tier EC2 Instance and Nginx

**Objective:** Deploy the frontend web server in a public subnet and configure it to forward API requests to the internal ALB.

**Implementation:**

1. Update the Nginx configuration with the internal ALB DNS name.
2. Upload the web-tier files and Nginx configuration to the S3 bucket.
3. Launch an EC2 instance using the Amazon Linux AMI and instance type used in the lab.
4. Select the project VPC and a public web subnet.
5. Enable a public IP if direct public-instance testing is required.
6. Attach the web-tier security group and EC2 IAM role.
7. Connect through Systems Manager Session Manager.
8. Install the required Node.js tooling, retrieve the web-tier files from S3, and install frontend dependencies.
9. Build the frontend if the project uses a build step:

```bash
npm install
npm run build
```

10. Install and configure Nginx to serve the frontend on port `80`.
11. Configure the API proxy to send requests to the internal ALB.
12. Restart Nginx and verify the service.

**Purpose:** Nginx serves the frontend to users and acts as a reverse proxy for backend API requests. The browser does not need direct access to the private application instances.

**Validation:** Confirm Nginx is running, the frontend is served, and API requests are routed to the internal ALB.

**Screenshot:** `screenshots/16-web-tier-ec2-and-nginx.png`

## 17. Web-Tier Troubleshooting

**Objective:** Resolve the Nginx configuration issue recorded in the project notes.

The supplied document records a `403 Forbidden` issue associated with an incorrect document-root path and a missing semicolon in the Nginx index directive.

**Issue 1 – Incorrect root path**

The Nginx configuration pointed to:

```nginx
root /home/ec2-user/web-tier/build;
```

However, the project notes identify the actual build directory as:

```text
/aws-three-tier-web-architecture-workshop/application-code/web-tier/build
```

The root path must match the actual location of the generated frontend files on the instance. Use the path that exists on your own server; do not copy the example path unless it matches your deployment.

**Issue 2 – Missing semicolon**

Incorrect:

```nginx
index index.html index.htm
```

Correct:

```nginx
index index.html index.htm;
```

**Troubleshooting procedure:**

1. Edit the active Nginx configuration file.
2. Correct the `root` directive to the actual frontend build directory.
3. Ensure the `index` directive ends with a semicolon.
4. Ensure the Nginx worker user can read and traverse the application directory.
5. Test the configuration:

```bash
sudo nginx -t
```

6. Restart Nginx:

```bash
sudo systemctl restart nginx
```

7. Open the web server address and verify that the frontend loads.

**Result:** The project notes record the incorrect path and missing semicolon as the causes to address. Add a screenshot of the successful `nginx -t` output and working website after verifying them in your environment.

**Screenshots:**
- `screenshots/17a-nginx-error.png`
- `screenshots/17b-nginx-config-fixed.png`
- `screenshots/17c-nginx-test-success.png`
- `screenshots/17d-website-working.png`

## 18. Web-Tier AMI, Target Group and Public ALB

**Objective:** Prepare the web tier for load-balanced access through an internet-facing Application Load Balancer.

### Create a web-tier AMI

1. Select the configured web-tier EC2 instance.
2. Choose Actions → Image and templates → Create image.
3. Provide a name and description.
4. Wait for the AMI to become available.

### Create the web target group

1. Open EC2 → Target Groups → Create target group.
2. Select **Instances** as the target type.
3. Configure HTTP on port `80`.
4. Select the project VPC.
5. Configure the health check path as documented in the project setup.
6. Create the target group.

### Create the internet-facing Application Load Balancer

1. Open EC2 → Load Balancers → Create Load Balancer.
2. Select Application Load Balancer.
3. Choose **Internet-facing** as the scheme.
4. Select the project VPC and public web subnets in the two Availability Zones.
5. Attach the public load balancer security group.
6. Configure an HTTP listener on port `80`.
7. Forward traffic to the web target group.

**Purpose:** The public ALB provides a single internet-facing entry point and distributes incoming web requests across registered web-tier instances.

**Validation:** Confirm the ALB is internet-facing, spans the intended public subnets, and forwards traffic to the web target group. Confirm target health before treating the load-balanced deployment as complete.

**Screenshots:**
- `screenshots/18a-web-tier-ami.png`
- `screenshots/18b-web-target-group.png`
- `screenshots/18c-public-alb.png`
- `screenshots/18d-target-health.png`

> The supplied PDF describes the web-tier AMI, target group, and public ALB setup. It does not clearly establish in text that a web-tier Auto Scaling group was completed. Add a separate Web Tier Auto Scaling section only if you actually created and tested that group.

---

## Request Flow

When the application is accessed through the public ALB, the intended request flow is:

1. A user opens the public ALB DNS name in a browser.
2. The public ALB forwards HTTP traffic to a healthy web-tier target.
3. Nginx serves the frontend.
4. Frontend API requests are proxied by Nginx to the internal ALB.
5. The internal ALB forwards requests to a healthy application-tier instance on port `4000`.
6. The Node.js application queries the RDS database on port `3306`.
7. The application returns the result through the internal ALB and Nginx to the user's browser.

## Security Considerations

- Keep application and database instances in private subnets.
- Keep the RDS database non-public.
- Use security-group references to allow only required tier-to-tier traffic.
- Use IAM roles instead of static AWS access keys on EC2.
- Use Systems Manager Session Manager for administration where configured.
- Restrict public HTTP/HTTPS access according to the application requirements.
- Remove temporary test rules and unnecessary public access after testing.
- Never publish database passwords, access keys, private keys, or sensitive connection strings.
- Use AWS Secrets Manager or another secure secret-management solution for database credentials.
- Enable HTTPS using AWS Certificate Manager and an appropriate DNS configuration before production use.

## Testing and Validation

Use this checklist to record the tests you personally performed:

- [ ] VPC and six subnets created in two Availability Zones.
- [ ] Internet Gateway attached to the project VPC.
- [ ] NAT Gateway(s) available and private application routes configured.
- [ ] Public and private route-table associations verified.
- [ ] Security groups restrict traffic to the required ports and sources.
- [ ] EC2 instances can be accessed through Session Manager.
- [ ] Application-tier instance can reach the internet through NAT, if required.
- [ ] Application-tier instance can connect to RDS.
- [ ] Database and sample table created and queried successfully.
- [ ] Node.js backend is running under PM2.
- [ ] `/health` endpoint returns the expected response.
- [ ] Database-backed API endpoint returns data.
- [ ] Internal ALB forwards to healthy application targets.
- [ ] Nginx serves the frontend.
- [ ] Public ALB forwards to healthy web targets.
- [ ] End-to-end application flow tested in a browser.

Only tick the items that you personally verified.

## Challenges and Troubleshooting

### 1. Private instance connectivity

**Area checked:** NAT Gateway availability, private route-table default route, subnet association, and EC2 IAM permissions for Systems Manager.

**Learning:** A private instance needs correct routing for outbound internet access. Session Manager also requires the instance to be configured as a managed node with the necessary permissions and connectivity.

### 2. Database connection

**Area checked:** RDS endpoint, database credentials, database security group, and MySQL port `3306`.

**Learning:** A database connection requires both valid credentials and network permission from the application tier.

### 3. Nginx 403 Forbidden

**Area checked:** Nginx document-root path, index directive syntax, and file/directory permissions.

**Learning:** Nginx must point to the actual frontend build directory, the configuration must be syntactically valid, and its worker process must be able to read the files.

## Screenshot Checklist

Create a `screenshots/` folder in your GitHub repository and add your own AWS console screenshots using these suggested names.

| No. | Suggested screenshot filename | What to capture |
|---:|---|---|
| 00 | `00-aws-architecture.png` | Final three-tier architecture diagram |
| 01 | `01-s3-bucket.png` | S3 bucket overview |
| 02 | `02-iam-ec2-role.png` | EC2 IAM role and attached policies |
| 03 | `03-vpc-created.png` | VPC details and CIDR |
| 04 | `04a-public-web-subnets.png` | Public web subnets |
| 05 | `04b-private-app-subnets.png` | Private application subnets |
| 06 | `04c-private-db-subnets.png` | Private database subnets |
| 07 | `05-internet-gateway.png` | Internet Gateway attached to VPC |
| 08 | `06-nat-gateways.png` | NAT Gateways and Elastic IPs |
| 09 | `07-route-tables-and-associations.png` | Routes and subnet associations |
| 10 | `08-security-groups.png` | Security group inbound rules |
| 11 | `09a-rds-db-subnet-group.png` | RDS subnet group and selected subnets |
| 12 | `09b-rds-database-configuration.png` | RDS configuration (hide sensitive values) |
| 13 | `09c-rds-available-endpoint.png` | Available database and endpoint (hide sensitive values) |
| 14 | `10-app-tier-ec2.png` | Private application EC2 instance details |
| 15 | `11a-ssm-session-manager.png` | Successful Session Manager session |
| 16 | `11b-rds-mysql-connection.png` | Successful MySQL connection (hide credentials) |
| 17 | `11c-database-table-and-test-record.png` | Table and sample query result |
| 18 | `12-node-app-pm2-online.png` | PM2 process status |
| 19 | `13-app-health-and-api-test.png` | Health and API curl responses |
| 20 | `14a-app-tier-ami.png` | Application AMI |
| 21 | `14b-app-target-group.png` | Application target group and health |
| 22 | `14c-internal-alb.png` | Internal ALB details |
| 23 | `15-app-tier-auto-scaling.png` | Application Auto Scaling group and instances |
| 24 | `16-web-tier-ec2-and-nginx.png` | Web EC2 instance and Nginx status |
| 25 | `17a-nginx-error.png` | Original Nginx error, if retained |
| 26 | `17b-nginx-config-fixed.png` | Corrected Nginx configuration |
| 27 | `17c-nginx-test-success.png` | Successful `nginx -t` output |
| 28 | `17d-website-working.png` | Frontend successfully loaded |
| 29 | `18a-web-tier-ami.png` | Web-tier AMI |
| 30 | `18b-web-target-group.png` | Web target group and health |
| 31 | `18c-public-alb.png` | Internet-facing ALB details |
| 32 | `18d-target-health.png` | Healthy web-tier targets |
| 33 | `19-final-application.png` | Final application in browser |

To display a screenshot in this README, use:

```markdown
![VPC Created](screenshots/03-vpc-created.png)
```

Place the image directly below the section it supports. Make sure screenshots do not expose passwords, access keys, session tokens, or other sensitive information.

## Possible Improvements

The following are potential next steps, not claims that they have already been implemented:

- Enable HTTPS with AWS Certificate Manager and Route 53.
- Store database credentials in AWS Secrets Manager.
- Use Terraform to provision infrastructure as code.
- Add a GitHub Actions CI/CD pipeline.
- Configure monitoring, alarms, and centralized logging.
- Review Auto Scaling policies and health-check behavior.
- Add authentication, authorization, and order-history functionality where required.
- Review backup, recovery, and database availability settings.
- Consider a web-tier Auto Scaling group if high availability at the web layer is required.

## Learning Outcomes

This project provides practical experience with:

- AWS VPC networking and CIDR planning.
- Public and private subnet design across Availability Zones.
- Internet Gateway, NAT Gateway, Elastic IP, and route-table configuration.
- Security-group design and tier-to-tier connectivity.
- IAM roles and Systems Manager Session Manager.
- EC2 deployment and administration.
- Amazon S3 deployment-file storage.
- Amazon RDS and MySQL connectivity.
- Node.js application deployment and PM2 process management.
- Nginx web serving and reverse proxy configuration.
- Application Load Balancers, target groups, AMIs, and Auto Scaling concepts.
- Troubleshooting cloud networking, database, and web-server issues.

## Author

**Sarthak Raghuvanshi**

Cloud Computing | AWS | DevOps | Web Development

## Disclaimer

This project is intended for learning and demonstration. The architecture and configuration should be reviewed and hardened before production use. AWS resources may incur charges; delete resources that are no longer needed.
