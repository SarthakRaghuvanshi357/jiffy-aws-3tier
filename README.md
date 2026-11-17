# Jiffy: Quick-Commerce Grocery App on a 3-Tier AWS Architecture

Web tier (Nginx, public subnets) → Internal ALB → App tier (Node.js/Express :4000, private subnets) → Database tier (RDS MySQL, private subnets)

## Deploy
1. **Database:** from an app-tier instance (via SSM): `mysql -h <rds-endpoint> -u admin -p < database/schema.sql`
2. **App tier:** upload `app-tier/` to S3; on the instance run `aws s3 cp s3://<bucket>/app-tier . --recursive`, `npm install`, then
   `DB_HOST=<rds-endpoint> DB_USER=admin DB_PASS=<password> pm2 start index.js --name jiffy`. Target group health check: `/health` on port 4000.
3. **Web tier:** `sudo dnf install nginx -y`; copy `web-tier/index.html` to `/usr/share/nginx/html/`; put `web-tier/nginx.conf` in `/etc/nginx/conf.d/` (set your internal ALB DNS); `sudo systemctl enable --now nginx`.
4. Open the public ALB DNS name in a browser.

## Real product photos
Upload images to S3 and set `image_url` in the `products` table (e.g. `UPDATE products SET image_url='https://...' WHERE name='Sunflower Oil';`). The site shows the photo automatically and falls back to the emoji tile.

## Next upgrades
HTTPS (ACM + Route 53), Auto Scaling Groups, Secrets Manager, Terraform, GitHub Actions CI/CD, login and order history.
