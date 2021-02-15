# 003_migration

CREATE TABLE `user`
(
    `id`        INT(10) UNSIGNED    NOT NULL AUTO_INCREMENT,
    `uuid`      CHAR(36)            NOT NULL,
    `is_active` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
    `email`     CHAR(255)           NOT NULL,
    `password`  VARCHAR(128),
    `created`   INT(10) UNSIGNED    NOT NULL,
    `modified`  INT(10) UNSIGNED    NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`),
    UNIQUE INDEX (`email`)
);

CREATE TABLE `user_details`
(
    `id`              INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`         INT(10) UNSIGNED NOT NULL,
    `first_name`      VARCHAR(64)      NOT NULL,
    `last_name`       VARCHAR(64)      NOT NULL,
    `birthday`        DATE,
    `phone`           VARCHAR(64),
    `street`          VARCHAR(200)     NOT NULL,
    `zip`             VARCHAR(30)      NOT NULL,
    `city`            VARCHAR(100)     NOT NULL,
    `dict_country_id` INT(10) UNSIGNED NOT NULL,
    `newsletter`      TINYINT(1),
    `created`         INT(10) UNSIGNED NOT NULL,
    `modified`        INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
);

CREATE TABLE `user_cart`
(
    `id`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`     CHAR(36)         NOT NULL,
    `user_id`  INT(10) UNSIGNED,
    `created`  INT(10) UNSIGNED NOT NULL,
    `modified` INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`),
    UNIQUE INDEX (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
);

CREATE TABLE `user_cart_items`
(
    `id`           INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_cart_id` INT(10) UNSIGNED NOT NULL,
    `products_id`  INT(10) UNSIGNED NOT NULL,
    `quantity`     INT(10) UNSIGNED NOT NULL,
    `created`      INT(10) UNSIGNED NOT NULL,
    `modified`     INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`user_cart_id`, `products_id`),
    FOREIGN KEY (`user_cart_id`) REFERENCES `user_cart` (`id`),
    FOREIGN KEY (`products_id`) REFERENCES `products` (`id`)
);

CREATE TABLE `delivery_method`
(
    `id`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`     CHAR(36)         NOT NULL,
    `name`     VARCHAR(255)     NOT NULL,
    `code`     VARCHAR(128)     NOT NULL,
    `created`  INT(10) UNSIGNED NOT NULL,
    `modified` INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`)
);

CREATE TABLE `user_order`
(
    `id`                     INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`                   CHAR(36)         NOT NULL,
    `user_cart_id`           INT(10) UNSIGNED NOT NULL,
    `user_id`                INT(10) UNSIGNED,
    `delivery_method_id`     INT(10) UNSIGNED,
    `additional_information` JSON,
    `another_address`        JSON,
    `tracking_number`        VARCHAR(255),
    `created`                INT(10) UNSIGNED NOT NULL,
    `modified`               INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`),
    FOREIGN KEY (`user_cart_id`) REFERENCES `user_cart` (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    FOREIGN KEY (`delivery_method_id`) REFERENCES `delivery_method` (`id`)
);


# region procedures


# region procedures

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `created`, `modified`)
VALUES ('003_migration',
        `uuid_v4`(),
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
