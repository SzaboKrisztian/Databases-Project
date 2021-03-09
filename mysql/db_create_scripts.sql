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
  `role` ENUM('user', 'manager', 'admin') NOT NULL DEFAULT('user'),
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
  `order_status` ENUM('pending','confirmed','sent','delivered','cancelled') NOT NULL DEFAULT('pending'),
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

-- VIEW ALL USERS
DROP VIEW IF EXISTS user_data;
CREATE VIEW user_data AS
    SELECT 
        user.id,
        user.email,
        user.role,
        user.verified,
        user.created_at,
        personal_data.first_name,
        personal_data.last_name,
        personal_data.phone_number,
        personal_data.date_of_birth,
        address.text,
        address.street,
        address.number,
        address.floor,
        address.door,
        address.zip_code,
        address.city
    FROM user
	JOIN personal_data ON user.personal_data_id = personal_data.id
	JOIN address ON personal_data.address_id = address.id
    WHERE user.deleted = 0;
-- SELECT * FROM user_data;

-- VIEW A PRODUCT
DROP PROCEDURE IF EXISTS view_product;
DELIMITER \\
CREATE PROCEDURE view_product(
	in in_id int
)
BEGIN
	SELECT 
		p.id, p.name, p.code, pd.description, m.name as manufacturer, c.name as category
    FROM product p
    JOIN product_description pd on p.description_id = pd.id
    JOIN manufacturer m on p.manufacturer_id = m.id
    JOIN category c on p.category_id = c.id
    WHERE p.id = in_id AND p.deleted = 0 AND p.approved = 1;
END \\

DELIMITER ;
-- call view_product(1);

-- GET NUMBER OF PRODUCTS IN A CATEGORY
DROP FUNCTION IF EXISTS get_product_count_for_category;
DELIMITER \\
CREATE FUNCTION get_product_count_for_category(
	in_id int
)
RETURNS int
READS SQL DATA
BEGIN
	DECLARE count_no INT;
	SELECT COUNT(*) into count_no from product WHERE category_id = in_id;
    RETURN count_no;
END \\

DELIMITER ;
-- SELECT get_product_count_for_category(1);

-- VIEW ALL USERS
DROP VIEW IF EXISTS seller_product;
CREATE VIEW seller_product AS
SELECT 
	sellers_products.id, sellers_products.original_price, sellers_products.sale_price, sellers_products.stock_qty, seller.name, seller.legal_name, seller.cvr, seller.phone_number, product.name as product_name, product.code as product_code
FROM sellers_products
JOIN seller on sellers_products.seller_id = seller.id
JOIN product on sellers_products.product_id = product.id
WHERE sellers_products.deleted = 0;

-- CREATE NEW USER
DROP PROCEDURE IF EXISTS create_user;
DELIMITER //

CREATE PROCEDURE create_user(
	IN in_email VARCHAR(255), 
	IN in_password VARCHAR(255), 
	IN in_first_name VARCHAR(255), 
	IN in_last_name VARCHAR(255), 
	IN in_date_of_birth TIMESTAMP )
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			ROLLBACK;
			RESIGNAL;
		END;
	START TRANSACTION;
    INSERT INTO personal_data(first_name, last_name, date_of_birth) VALUES (in_first_name, in_last_name, in_date_of_birth);
    INSERT INTO user(email, password, personal_data_id) VALUES (in_email, in_password, (SELECT LAST_INSERT_ID()));
	COMMIT;
END //
DELIMITER ;

-- CALL create_user('radu@radu.com', 'dsadsadsadasda', 'radu', 'radu2', '1999-04-03 00:00:00');

-- GET PRODUCT IMAGES
DROP PROCEDURE IF EXISTS get_product_images;
DELIMITER //
CREATE PROCEDURE get_product_images(
    IN product_id INT
)
BEGIN
    SELECT i.id, i.url, i.created_at
    FROM product_image i
    WHERE i.product_id = product_id;
END //
DELIMITER ;

-- CALL get_product_images(1);

-- GET PRODUCT PROPERTIES
DROP PROCEDURE IF EXISTS get_product_properties;
DELIMITER //
CREATE PROCEDURE get_product_properties(
    IN product_id INT
)
BEGIN
    SELECT pp.property_id, p.name, pp.value, p.unit
    FROM products_properties pp
    JOIN property p on pp.property_id = p.id
    WHERE pp.product_id = product_id;
END //

DELIMITER ;

-- CALL get_product_properties(1)