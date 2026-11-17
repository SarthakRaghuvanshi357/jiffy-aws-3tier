CREATE DATABASE IF NOT EXISTS jiffy;
USE jiffy;
CREATE TABLE products (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(80), unit VARCHAR(30), price INT, mrp INT, category VARCHAR(30), emoji VARCHAR(8), tint VARCHAR(9), image_url VARCHAR(255) NULL);
CREATE TABLE orders (id INT AUTO_INCREMENT PRIMARY KEY, customer VARCHAR(80), phone VARCHAR(20), address VARCHAR(255), subtotal INT, delivery_fee INT, total INT, status VARCHAR(20) DEFAULT 'Placed', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE order_items (id INT AUTO_INCREMENT PRIMARY KEY, order_id INT, product_id INT, name VARCHAR(80), price INT, qty INT, FOREIGN KEY (order_id) REFERENCES orders(id));
INSERT INTO products (name,unit,price,mrp,category,emoji,tint) VALUES
('Classic Salted Potato Chips','52 g',20,20,'Snacks','🍟','#FFE9A8'),
('Masala Corn Puffs','60 g',20,25,'Snacks','🌽','#FFD9B0'),
('Salted Peanuts','200 g',45,50,'Snacks','🥜','#F3DFC1'),
('Chocolate Cream Biscuits','120 g',30,35,'Snacks','🍪','#E7D3F5'),
('Sunflower Oil','1 L',139,165,'Oil and Staples','🛢️','#FFF1A8'),
('Mustard Oil','500 ml',99,115,'Oil and Staples','🫗','#F9E27D'),
('Extra Virgin Olive Oil','250 ml',289,349,'Oil and Staples','🫒','#D8EBB5'),
('Whole Wheat Atta','5 kg',229,260,'Oil and Staples','🌾','#F5E6C8'),
('Basmati Rice','1 kg',119,140,'Oil and Staples','🍚','#EEF2F5'),
('Toor Dal','500 g',85,95,'Oil and Staples','🫘','#FBE3B0'),
('Toned Milk','500 ml',29,29,'Dairy and Bread','🥛','#DCEBFA'),
('Brown Eggs','6 pcs',54,60,'Dairy and Bread','🥚','#FCEBD5'),
('Sandwich Bread','400 g',45,50,'Dairy and Bread','🍞','#F7E0BC'),
('Salted Butter','100 g',58,62,'Dairy and Bread','🧈','#FFF3B8'),
('Paneer','200 g',89,99,'Dairy and Bread','🧀','#FFF6DA'),
('Cola','750 ml',40,45,'Drinks','🥤','#F9D3D3'),
('Mango Juice','1 L',99,115,'Drinks','🧃','#FFE08A'),
('Banana','6 pcs',42,48,'Fruits and Veg','🍌','#FFF2A6'),
('Tomato','500 g',28,35,'Fruits and Veg','🍅','#FAD0CC'),
('Onion','1 kg',39,48,'Fruits and Veg','🧅','#EFD9F0'),
('Potato','1 kg',34,40,'Fruits and Veg','🥔','#EBD9BF');
