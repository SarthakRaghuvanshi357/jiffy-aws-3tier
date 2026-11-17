# Jiffy – Quick-Commerce Grocery Application on AWS 3-Tier Architecture

## Project Overview

Jiffy is a quick-commerce grocery web application deployed using a 3-Tier AWS Cloud Architecture. The project demonstrates how a modern web application can be hosted using separate web, application, and database layers to improve scalability, security, and maintainability.

The application allows users to browse grocery products, view product details, and place orders through a web interface.

## Architecture

The project follows a 3-Tier Architecture:

1. **Web Tier:** Nginx hosted on EC2 instances in public subnets.
2. **Application Tier:** Node.js and Express backend running on port 4000 in private subnets.
3. **Database Tier:** Amazon RDS MySQL database hosted in private subnets.

### Architecture Flow

User / Browser
    |
    v
Public Application Load Balancer
    |
    v
Web Tier (Nginx)
    |
    v
Internal Application Load Balancer
    |
    v
Application Tier (Node.js / Express)
    |
    v
Amazon RDS (MySQL)

## AWS Services Used

| AWS Service | Purpose |
|---|---|
| Amazon EC2 | Hosting web and application servers |
| Amazon S3 | Storing application files and product images |
| Amazon RDS | Managed MySQL database |
| Application Load Balancer | Distributing application traffic |
| VPC | Network isolation |
| Public Subnets | Hosting public-facing web components |
| Private Subnets | Hosting application and database components |
| AWS Systems Manager (SSM) | Secure instance access |

## Technology Stack

- Frontend: HTML, CSS, JavaScript
- Backend: Node.js, Express.js
- Web Server: Nginx
- Database: MySQL
- Cloud Platform: Amazon Web Services (AWS)
- Process Manager: PM2
- Storage: Amazon S3
- Version Control: Git and GitHub

## Project Features

- Grocery product listing
- Product categories
- Product pricing and MRP
- Product images with emoji fallback
- Shopping cart and order workflow
- Backend API using Node.js and Express
- MySQL database integration
- Three-tier cloud deployment architecture
- Load balancer-based traffic routing
- Separation of public and private infrastructure

Note: Features should be retained here only if they are implemented in the current project.

## Project Structure

```
Jiffy/
│
├── app-tier/
│   ├── index.js
│   └── package.json
│
├── web-tier/
│   ├── index.html
│   └── nginx.conf
│
├── database/
│   └── schema.sql
│
└── README.md
```

## Deployment Guide

### 1. Database Setup

Connect to the application-tier EC2 instance using AWS Systems Manager (SSM).

Run:

```bash
mysql -h <rds-endpoint> -u admin -p < database/schema.sql
```

Replace <rds-endpoint> with your actual RDS endpoint.

### 2. Application Tier Setup

Upload the application files to an S3 bucket.

Download them on the application EC2 instance:

```bash
aws s3 cp s3://<bucket>/app-tier . --recursive
```

Install dependencies:

```bash
npm install
```

Start the Node.js application:

```bash
DB_HOST=<rds-endpoint> DB_USER=admin DB_PASS=<password> pm2 start index.js --name jiffy
```

Application port: 4000

Health check endpoint:

```
/health
```

### 3. Web Tier Setup

Install Nginx:

```bash
sudo dnf install nginx -y
```

Copy the frontend file:

```bash
sudo cp index.html /usr/share/nginx/html/
```

Configure Nginx using the project nginx.conf file in:

```
/etc/nginx/conf.d/
```

Configure the internal Application Load Balancer DNS in the Nginx configuration.

Start Nginx:

```bash
sudo systemctl enable --now nginx
```

### 4. Access the Application

Open the public Application Load Balancer DNS name in your browser to access the Jiffy application.

## Database

The project uses Amazon RDS MySQL.

Main database tables:

- products
- orders
- order_items

The products table stores product information such as:

- Product ID
- Product name
- Unit
- Price
- MRP
- Category
- Emoji
- Tint
- Image URL

## Product Images Using Amazon S3

Product images can be uploaded to an S3 bucket.

Update the image URL in the products table:

```sql
UPDATE products
SET image_url = 'https://your-image-url'
WHERE name = 'Sunflower Oil';
```

The application displays the product image and uses an emoji tile as a fallback when an image is unavailable.

## Security and Networking

The architecture separates public-facing and backend infrastructure.

- Web tier is deployed in public subnets.
- Application tier is deployed in private subnets.
- Database tier is deployed in private subnets.
- Application traffic is routed through an internal load balancer.
- AWS Systems Manager can be used for secure instance access.

Security groups should allow only the required traffic between tiers. Database credentials should be stored securely rather than hardcoded.

## Future Enhancements

Planned improvements include:

- HTTPS using AWS Certificate Manager (ACM) and Route 53.
- Auto Scaling Groups for improved scalability.
- AWS Secrets Manager for database credentials.
- Terraform for Infrastructure as Code.
- GitHub Actions for CI/CD automation.
- User authentication and authorization.
- User login and registration.
- Order history and tracking.
- Improved monitoring and logging.

## Learning Outcomes

Through this project, I gained practical experience in:

- AWS cloud infrastructure deployment.
- Designing a 3-Tier Architecture.
- Configuring EC2 instances and security groups.
- Working with public and private subnets.
- Configuring Application Load Balancers.
- Deploying Node.js applications.
- Configuring Nginx as a web server and reverse proxy.
- Integrating Amazon RDS MySQL.
- Using Amazon S3 for application file storage.
- Managing application processes using PM2.

## Author

**Sarthak Raghuvanshi**

Cloud Computing | AWS | DevOps | Web Development

## Disclaimer

This project is developed for educational and practical cloud computing purposes. AWS resources may incur charges. Always review and clean up unused resources after testing.

