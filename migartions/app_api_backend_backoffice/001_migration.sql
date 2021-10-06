# 001_migration

ALTER TABLE `migrations`
    ADD COLUMN `code` VARCHAR(255) NOT NULL AFTER `uuid`;

UPDATE `migrations`
SET `migrations`.`code` = 'API_BACKEND_PORTAL';

CREATE TABLE `user_backoffice`
(
    `id`        INT(10) UNSIGNED    NOT NULL AUTO_INCREMENT,
    `uuid`      CHAR(36)            NOT NULL,
    `is_active` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
    `email`     CHAR(255)           NOT NULL,
    `password`  VARCHAR(128)        NOT NULL,
    `created`   INT(10) UNSIGNED    NOT NULL,
    `modified`  INT(10) UNSIGNED    NOT NULL,
    PRIMARY KEY (`id`)
);

/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_backoffice__check_exist` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_backoffice__check_exist`(IN `_user_backoffice__email` CHAR(255))
BEGIN

    SELECT `user_backoffice`.`uuid` AS `user_backoffice__uuid`
    FROM `user_backoffice`
    WHERE `user_backoffice`.`email` = `_user_backoffice__email`;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_backoffice__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_backoffice__get`(IN `_user_backoffice__uuid` CHAR(36))
BEGIN

    SELECT `user_backoffice`.`email` AS `user_backoffice__email`
    FROM `user_backoffice`
    WHERE `user_backoffice`.`uuid` = `_user_backoffice__uuid`;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_backoffice__signin` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_backoffice__signin`(IN `_user_backoffice__email` CHAR(255),
                                                                                                 IN `_user_backoffice__password` VARCHAR(128))
BEGIN

    SELECT `user_backoffice`.`uuid`  AS `user_backoffice__uuid`,
           `user_backoffice`.`email` AS `user_backoffice__email`
    FROM `user_backoffice`
    WHERE `user_backoffice`.`email` = `_user_backoffice__email`
      AND `user_backoffice`.`is_active` = 1
      AND `user_backoffice`.`password` = _user_backoffice__password;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_backoffice__signup` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_backoffice__signup`(IN `_user_backoffice__email` CHAR(255),
                                                                                                 IN `_user_backoffice__password` VARCHAR(128))
BEGIN

    INSERT
    INTO `user_backoffice`
    (`uuid`, `email`, `password`, `created`, `modified`)
    VALUES (`uuid_v4`(),
            _user_backoffice__email,
            _user_backoffice__password,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_order__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_order__get`(IN `_date_from` INT(10) UNSIGNED,
                                                                                         IN `_data_to` INT(10) UNSIGNED,
                                                                                         IN `_conditions` JSON)
BEGIN

    DECLARE `__user_order__external_id` JSON;
    DECLARE `__user__email` JSON;
    DECLARE `__user_order__status` JSON;
    DECLARE `__user_order__order_status` JSON;

    SET __user_order__external_id = JSON_EXTRACT(`_conditions`, '$.user_order__external_id');
    SET __user__email = JSON_EXTRACT(`_conditions`, '$.user__email');
    SET __user_order__status = JSON_EXTRACT(`_conditions`, '$.user_order__status');
    SET __user_order__order_status = JSON_EXTRACT(`_conditions`, '$.user_order__order_status');

    SET @__query = CONCAT('
    SELECT `user_order`.`external_id` AS `user_order__external_id`,
           `user_order`.`uuid` AS `user_order__uuid`,
           `transaction`.`amount` AS `transaction__amount`,
           `dict_currency`.`iso4217` AS `dict_currency__iso4217`,
           `user_order`.`order_status` AS `user_order__order_status`,
           `user_order`.`status` AS `user_order__status`,
           `user_order`.`created` AS `user_order__created`,
           `user_order`.`modified` AS `user_order__modified`
           FROM `user_order`
               LEFT JOIN `user`
                   ON `user`.`id` = `user_order`.`user_id`
               INNER JOIN `transaction`
                    ON `transaction`.`user_order_id` = `user_order`.`id`
               INNER JOIN `dict_currency`
                    ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
    WHERE `user_order`.`created` BETWEEN ? AND ?',
                          IF(IFNULL(JSON_LENGTH(__user_order__external_id), 0) = 0, '',
                             CONCAT(' AND `user_order`.`external_id` IN (',
                                    TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __user_order__external_id)), ')')),
                          IF(IFNULL(JSON_LENGTH(__user__email), 0) = 0, '',
                             CONCAT(' AND `user`.`email` IN (',
                                    TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __user__email)), ')')),
                          IF(IFNULL(JSON_LENGTH(__user_order__status), 0) = 0, '',
                             CONCAT(' AND `user_order`.`status` IN (',
                                    TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __user_order__status)), ')')),
                          IF(IFNULL(JSON_LENGTH(__user_order__order_status), 0) = 0, '',
                             CONCAT(' AND `user_order`.`order_status` IN (',
                                    TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __user_order__order_status)), ')')),
                          ' ORDER BY `user_order`.`created` DESC;'
        );

    SET @__date_from = _date_from;
    SET @__date_to = _data_to;

    PREPARE `stmt` FROM @__query;
    EXECUTE `stmt` USING @__date_from, @__date_to;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_order__get_by_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_order__get_by_uuid`(IN `_user_order__uuid` CHAR(36))
BEGIN

    SELECT `user_order`.`external_id`                                                  AS `user_order__external_id`,
           COUNT(`products`.`id`)                                                      AS `products__count`,
           `user_order`.`uuid`                                                         AS `user_order__uuid`,
           `user_order`.`order_status`                                                 AS `user_order__order_status`,
           `user_order`.`status`                                                       AS `user_order__status`,
           IF(JSON_UNQUOTE(
                      JSON_EXTRACT(`user_order`.`additional_information`, '$.value')) = 'null', '', JSON_UNQUOTE(
                      JSON_EXTRACT(`user_order`.`additional_information`, '$.value'))) AS `user_order__additional_information`,
           `user_order`.`address`                                                      AS `user_order__address`,

           `transaction`.`amount`                                                      AS `transaction__amount`,

           `dict_currency`.`iso4217`                                                   AS `dict_currency__iso4217`,

           IFNULL(`user`.`email`, '')                                                  AS `user__email`,

           `products`.`uuid`                                                           AS `products__uuid`,

           `list_product`.`name`                                                       AS `list_product__name`,

           `dict_color`.`name`                                                         AS `dict_color__name`,

           `dict_size`.`name`                                                          AS `dict_size__name`,

           `user_cart_items`.`amount`                                                  AS `user_cart_items__amount`,

           `dict_currency_user_cart`.`iso4217`                                         AS `dict_currency_user_cart__iso4217`

    FROM `user_order`
             LEFT JOIN `user`
                       ON `user`.`id` = `user_order`.`user_id`
             INNER JOIN `transaction`
                        ON `transaction`.`user_order_id` = `user_order`.`id`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
             INNER JOIN `user_cart`
                        ON `user_cart`.`id` = `user_order`.`user_cart_id`
             INNER JOIN `user_cart_items`
                        ON `user_cart_items`.`user_cart_id` = `user_cart`.`id`
             INNER JOIN `products`
                        ON `products`.`id` = `user_cart_items`.`products_id`
             INNER JOIN `list_product`
                        ON `list_product`.`id` = `products`.`list_product_id`
             INNER JOIN `dict_color`
                        ON `dict_color`.`id` = `products`.`dict_color_id`
             INNER JOIN `dict_size`
                        ON `dict_size`.`id` = `products`.`dict_size_id`
             INNER JOIN `dict_currency` AS `dict_currency_user_cart`
                        ON `dict_currency_user_cart`.`id` = `user_cart_items`.`dict_currency_id`
    WHERE `user_order`.`uuid` = _user_order__uuid
    GROUP BY `products`.`uuid`;

END */$$
DELIMITER ;

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `code`, `created`, `modified`)
VALUES ('001_migration',
        `uuid_v4`(),
        'API_BACKEND_BACKOFFICE',
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
