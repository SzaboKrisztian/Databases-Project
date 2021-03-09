CREATE DATABASE `webshop_platform`;
USE `webshop_platform`;

CREATE TABLE `address` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `text` VARCHAR(512) NOT NULL,
  `street` VARCHAR(255) NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `floor` VARCHAR(4),
  `door` VARCHAR(8),
  `zip_code` VARCHAR(4) NOT NULL,
  `city` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

CREATE TABLE `personal_data` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `phone_number` VARCHAR(8),
  `date_of_birth` TIMESTAMP NOT NULL,
  `address_id` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `personal_data`
ADD FOREIGN KEY (`address_id`) REFERENCES `address`(`id`) ON DELETE SET NULL;


CREATE TABLE `user` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('user', 'manager', 'admin') NOT NULL,
  `verified` TINYINT NOT NULL DEFAULT(0),
  `personal_data_id` INT,
  `deleted` TINYINT NOT NULL DEFAULT(0),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE (`email`)
);

ALTER TABLE `user`
ADD FOREIGN KEY (`personal_data_id`) REFERENCES `personal_data`(`id`) ON DELETE SET NULL;

CREATE TABLE `seller` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `legal_name` VARCHAR(255) NOT NULL,
  `cvr` VARCHAR(8) NOT NULL,
  `phone_number` VARCHAR(8) NOT NULL,
  `address_id` INT NOT NULL,
  `owner_id` INT NOT NULL,
  `deleted` TINYINT NOT NULL DEFAULT(0),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE (`name`),
  UNIQUE (`legal_name`),
  UNIQUE (`cvr`)
);

ALTER TABLE `seller`
ADD FOREIGN KEY (`address_id`) REFERENCES `address`(`id`),
ADD FOREIGN KEY (`owner_id`) REFERENCES `user`(`id`); 

CREATE TABLE `manufacturer` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE (`name`)
);

CREATE TABLE `product_description` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `description` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

CREATE TABLE `category` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `parent_id` INT,
  `name` VARCHAR(255) NOT NULL,
  `deleted` TINYINT DEFAULT(0),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE(`name`)
);

ALTER TABLE `category`
ADD FOREIGN KEY (`parent_id`) REFERENCES `category`(`id`);

CREATE TABLE `product` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(1024) NOT NULL,
  `code` VARCHAR(255) NOT NULL,
  `manufacturer_id` INT NOT NULL,
  `description_id` INT,
  `category_id` INT NOT NULL,
  `approved` TINYINT NOT NULL DEFAULT(0),
  `deleted` TINYINT NOT NULL DEFAULT(0),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE (`code`)
);

ALTER TABLE `product`
ADD FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturer`(`id`),
ADD FOREIGN KEY (`description_id`) REFERENCES `product_description`(`id`) ON DELETE SET NULL,
ADD FOREIGN KEY (`category_id`) REFERENCES `category`(`id`);

CREATE TABLE `product_group` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

CREATE TABLE `products_groups` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `product_id` INT NOT NULL,
  `product_group_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `products_groups`
ADD FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE,
ADD FOREIGN KEY (`product_group_id`) REFERENCES `product_group`(`id`) ON DELETE CASCADE;

CREATE TABLE `product_image` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `product_id` INT NOT NULL,
  `url` VARCHAR(2048) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);
ALTER TABLE `product_image`
ADD FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE;

CREATE TABLE `property` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `type` ENUM('boolean', 'number', 'string') NOT NULL,
  `unit` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

CREATE TABLE `products_properties` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `product_id` INT NOT NULL,
  `property_id` INT NOT NULL,
  `value` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `products_properties`
ADD FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE,
ADD FOREIGN KEY (`property_id`) REFERENCES `property`(`id`);

CREATE TABLE `product_rating` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `product_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `rating` INT UNSIGNED NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
  `review` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `product_rating`
ADD FOREIGN KEY (`product_id`) REFERENCES `product`(`id`),
ADD FOREIGN KEY (`user_id`) REFERENCES `user`(`id`);

CREATE TABLE `sellers_products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `seller_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `original_price` INT UNSIGNED NOT NULL,
  `sale_price` INT UNSIGNED,
  `stock_qty` INT UNSIGNED NOT NULL,
  `deleted` TINYINT NOT NULL DEFAULT(0),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `sellers_products`
ADD FOREIGN KEY (`seller_id`) REFERENCES `seller`(`id`),
ADD FOREIGN KEY (`product_id`) REFERENCES `product`(`id`);

CREATE TABLE `order` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `seller_id` INT NOT NULL,
  `order_status` ENUM('pending','confirmed','sent','delivered','cancelled') NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `order`
ADD FOREIGN KEY (`user_id`) REFERENCES `user`(`id`),
ADD FOREIGN KEY (`seller_id`) REFERENCES `seller`(`id`);

CREATE TABLE `order_item` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `sellers_product_id` INT NOT NULL,
  `quantity` INT UNSIGNED NOT NULL CHECK (`quantity` > 0),
  `price_paid` INT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `order_item`
ADD FOREIGN KEY (`order_id`) REFERENCES `order`(`id`),
ADD FOREIGN KEY (`sellers_product_id`) REFERENCES `sellers_products`(`id`);


CREATE TABLE `audit` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `action` VARCHAR(255) NOT NULL,
  `resource_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `audit`
ADD FOREIGN KEY (`user_id`) REFERENCES `user`(`id`);