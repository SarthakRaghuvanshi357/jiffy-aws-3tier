# 🛒 JIFFY – Quick Commerce Grocery Application on AWS

<p align="center">
  <b>AWS 3-Tier Architecture | React.js | Node.js | Express.js | MySQL | Nginx</b>
</p>

---

## 📌 Project Overview

JIFFY is a Quick Commerce Grocery Application developed using a 3-Tier Architecture on Amazon Web Services (AWS).

The main purpose of this project is to deploy a scalable, secure, and highly available web application using AWS cloud infrastructure.

The application allows users to browse grocery products, view product prices, and place orders through a web interface.

The project separates the application into three different layers:

1. Web Tier – Handles the frontend and user requests.
2. Application Tier – Handles backend logic and API requests.
3. Database Tier – Stores application data.

The three tiers communicate with each other through AWS networking components and load balancers.

---

## 🎯 Project Objectives

- To understand AWS Cloud Infrastructure.
- To implement a 3-Tier Architecture.
- To create and configure a Virtual Private Cloud (VPC).
- To configure public and private subnets.
- To implement Internet Gateway and NAT Gateway.
- To configure Route Tables and Security Groups.
- To deploy EC2 instances in different network layers.
- To configure Amazon RDS for database management.
- To deploy frontend and backend applications.
- To configure Nginx as a web server.
- To implement Application Load Balancers.
- To understand Auto Scaling and high availability.
- To establish secure communication between application layers.

---

## 🏗️ Architecture Overview

The project follows a three-tier architecture.

### 1. Web Tier

The Web Tier is the presentation layer of the application.

Technologies:
- React.js
- HTML
- CSS
- JavaScript
- Nginx
- Amazon EC2

Responsibilities:
- Displays the user interface.
- Provides the frontend of the grocery application.
- Sends API requests to the Application Tier.
- Communicates with the Internal Load Balancer.

### 2. Application Tier

The Application Tier handles the backend functionality.

Technologies:
- Node.js
- Express.js
- Amazon EC2
- PM2
- Internal Application Load Balancer

Responsibilities:
- Processes API requests.
- Handles application logic.
- Communicates with the database.
- Performs database operations.
- Sends responses to the Web Tier.

### 3. Database Tier

The Database Tier stores application information.

Technologies:
- Amazon RDS
- MySQL

Responsibilities:
- Stores product information.
- Stores customer order information.
- Stores order details.
- Provides database access to the Application Tier.

### Application Request Flow

```text
User / Browser
      |
      v
Public Application Load Balancer
      |
      v
Web Tier (EC2 + Nginx + React)
      |
      v
Internal Application Load Balancer
      |
      v
Application Tier (EC2 + Node.js)
      |
      v
Database Tier (Amazon RDS + MySQL)
