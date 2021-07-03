# 011_migration

DROP PROCEDURE IF EXISTS `app_backend__user_cart_items__get_by_uuid`;

ALTER TABLE `user_cart_items`
    ADD COLUMN `dict_currency_id` INT(10) UNSIGNED NULL AFTER `products_id`,
    ADD COLUMN `amount`           INT(10) UNSIGNED NULL AFTER `dict_currency_id`,
    ADD FOREIGN KEY (`dict_currency_id`) REFERENCES `dict_currency` (`id`);

UPDATE `user_cart_items`
    INNER JOIN `user_cart`
    ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
    INNER JOIN `list_product`
    ON `list_product`.`id` = `user_cart_items`.`products_id`
    INNER JOIN `user_order`
    ON `user_order`.`user_cart_id` = `user_cart`.`id`
    INNER JOIN `transaction`
    ON `transaction`.`user_order_id` = `user_order`.`id`
    INNER JOIN `dict_currency`
    ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
    INNER JOIN `currency_exchange_rate`
    ON `currency_exchange_rate`.`dict_currency_id` = `dict_currency`.`id`
SET `user_cart_items`.`dict_currency_id` = `dict_currency`.`id`,
    `user_cart_items`.`amount`           = CAST(IF(`currency_exchange_rate`.`value` != 1,
                                                   (`list_product`.`price` * `currency_exchange_rate`.`value` / 100 DIV 10) *
                                                   10 + 10,
                                                   `list_product`.`price` / 100) AS UNSIGNED);

CREATE TABLE `user_support`
(
    `id`            INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`          CHAR(36)         NOT NULL,
    `user_id`       INT(10) UNSIGNED,
    `user_order_id` INT(10) UNSIGNED,
    `body`          LONGTEXT         NOT NULL,
    `respond_to`    VARCHAR(255)     NOT NULL,
    `modified`      INT(10) UNSIGNED NOT NULL,
    `created`       INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    FOREIGN KEY (`user_order_id`) REFERENCES `user_order` (`id`)
);


# region procedures

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__insert`(IN _user__uuid CHAR(36),
                                                                                IN _user_cart__uuid CHAR(36),
                                                                                IN _dict_country__iso CHAR(3),
                                                                                IN _user_cart_items__data JSON)
BEGIN

    DECLARE __user__id INT(10) UNSIGNED;
    DECLARE __user_cart__id INT(10) UNSIGNED;
    DECLARE __user_cart__item CHAR(36);
    DECLARE __products_id INT(10) UNSIGNED;
    DECLARE __iteration INT(10) DEFAULT 0;
    DECLARE __dict_currency__id INT(10) UNSIGNED;
    DECLARE __dict_currency__iso4217 CHAR(3);
    DECLARE __currency_exchange_rate__value DECIMAL(5, 3);
    DECLARE __list_product__price INT(10) UNSIGNED;
    DECLARE __sum INT(10) UNSIGNED DEFAULT 0;

    # Error handlers
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
    DECLARE EXIT HANDLER FOR SQLWARNING
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT `dict_currency`.`id`,
           `dict_currency`.`iso4217`,
           `currency_exchange_rate`.`value`
    INTO __dict_currency__id, __dict_currency__iso4217, __currency_exchange_rate__value
    FROM `dict_currency`
             LEFT JOIN `dict_country`
                       ON `dict_country`.`dict_currency_id` = `dict_currency`.`id`
             LEFT JOIN `currency_exchange_rate`
                       ON `currency_exchange_rate`.`dict_currency_id` = `dict_currency`.`id`
    WHERE `dict_country`.`iso` = _dict_country__iso;

    IF (_user__uuid IS NOT NULL)
    THEN

        SELECT `user`.`id`
        INTO __user__id
        FROM `user`
        WHERE `user`.`uuid` = _user__uuid;

        IF __user__id IS NULL
        THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user id', MYSQL_ERRNO = 1000;
        END IF;

    END IF;

    INSERT
    INTO `user_cart`
        (`uuid`, `user_id`, `created`, `modified`)
    VALUES (_user_cart__uuid, __user__id, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

    SELECT `user_cart`.`id`
    INTO __user_cart__id
    FROM `user_cart`
    WHERE `user_cart`.`uuid` = _user_cart__uuid;

    IF __user_cart__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user cart id', MYSQL_ERRNO = 1001;
    END IF;

    WHILE __iteration < JSON_LENGTH(_user_cart_items__data)
        DO
            SELECT JSON_UNQUOTE(JSON_EXTRACT(_user_cart_items__data, CONCAT('$[', __iteration, ']')))
            INTO __user_cart__item;

            SELECT `products`.`id`
            INTO __products_id
            FROM `products`
            WHERE `products`.`uuid` = __user_cart__item;

            IF __products_id IS NULL
            THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No products id', MYSQL_ERRNO = 1002;
            END IF;

            SELECT CAST(IF(__currency_exchange_rate__value != 1,
                           (`list_product`.`price` * __currency_exchange_rate__value / 100 DIV 10) * 10 + 10,
                           `list_product`.`price` / 100) AS UNSIGNED)
            INTO __list_product__price
            FROM `list_product`
                     INNER JOIN `products`
                                ON `products`.`list_product_id` = `list_product`.`id`
            WHERE `products`.`id` = __products_id;

            SET __sum = __sum + __list_product__price;

            IF __products_id IS NULL
            THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No __list_product__price', MYSQL_ERRNO = 1003;
            END IF;

            INSERT
            INTO `user_cart_items`
            (`user_cart_id`, `products_id`, `dict_currency_id`, `amount`, `created`, `modified`)
            VALUES (__user_cart__id,
                    __products_id,
                    `__dict_currency__id`,
                    `__list_product__price`,
                    UNIX_TIMESTAMP(),
                    UNIX_TIMESTAMP());

            SET __user_cart__item = NULL;
            SET __products_id = NULL;
            SET __list_product__price = NULL;
            SET __iteration = __iteration + 1;
        END WHILE;

    SELECT `__sum`                    AS sum,
           `__dict_currency__iso4217` AS `dict_currency__iso4217`;
    COMMIT;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction__insert`(IN transaction__uuid CHAR(36),
                                                                                  IN user_order__uuid CHAR(36),
                                                                                  IN payment_method__code VARCHAR(255),
                                                                                  IN dict_currency__iso4217 CHAR(3),
                                                                                  IN transaction__amount INT(10) UNSIGNED,
                                                                                  IN transaction__status ENUM ('pending','settled','canceled','error', 'new'))
BEGIN

    DECLARE `_user_order_id` INT(10) UNSIGNED;
    DECLARE `_payment_method_id` INT(10) UNSIGNED;
    DECLARE `_dict_currency_id` INT(10) UNSIGNED;

    # Error handlers
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
    DECLARE EXIT HANDLER FOR SQLWARNING
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT `user_order`.`id`
    INTO `_user_order_id`
    FROM `user_order`
    WHERE `user_order`.`uuid` = user_order__uuid;

    IF `_user_order_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user order id', MYSQL_ERRNO = 1000;
    END IF;

    SELECT `payment_method`.`id`
    INTO `_payment_method_id`
    FROM `payment_method`
    WHERE `payment_method`.`code` = payment_method__code;

    IF `_payment_method_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No payment method id', MYSQL_ERRNO = 1001;
    END IF;

    SELECT `dict_currency`.`id`
    INTO `_dict_currency_id`
    FROM `dict_currency`
    WHERE `dict_currency`.`iso4217` = dict_currency__iso4217;

    IF `_dict_currency_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No dict currency id', MYSQL_ERRNO = 1002;
    END IF;

    INSERT
    INTO `transaction`
    (`uuid`, `user_order_id`, `payment_method_id`, `dict_currency_id`, `amount`, `status`, `created`, `modified`)
    VALUES (transaction__uuid,
            _user_order_id,
            _payment_method_id,
            _dict_currency_id,
            transaction__amount,
            transaction__status,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());
    COMMIT;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_order__get_products` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_order__get_products`(
    IN _user_order__external_id VARCHAR(20))
BEGIN

    SELECT `user_order`.`external_id`     AS `user_order__external_id`,
           `user_order`.`order_status`    AS `user_order__order_status`,
           `user_order`.`address`         AS `user_order__address`,
           `user_order`.`tracking_number` AS `user_order__tracking_number`,

           `user`.`uuid`                  AS `user__uuid`,

           COUNT(`products`.`id`)         AS `products__count`,
           `products`.`uuid`              AS `products__uuid`,

           `list_product`.`name`          AS `list_product__name`,
           `list_product`.`uuid`          AS `list_product__uuid`,
           `list_product`.`images`        AS `list_product__images`,

           `user_cart_items`.`amount`     AS `user_cart_items__amount`,

           `dict_currency`.`iso4217`      AS `dict_currency__iso4217`,

           `transaction`.`amount`         AS `transaction__amount`,

           `dict_color`.`code`            AS `dict_color__code`,
           `dict_color`.`hex`             AS `dict_color__hex`,

           `dict_product`.`code`          AS `dict_product__code`,

           `dict_size`.`name`             AS `dict_size__name`,
           `dict_size`.`code`             AS `dict_size__code`

    FROM `user_cart`
             INNER JOIN `user_order`
                        ON `user_order`.`user_cart_id` = `user_cart`.`id`
             INNER JOIN `transaction`
                        ON `transaction`.`user_order_id` = `user_order`.`id`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
             LEFT JOIN `user`
                       ON `user`.`id` = `user_order`.`user_id`
             INNER JOIN `user_cart_items`
                        ON `user_cart_items`.`user_cart_id` = `user_cart`.`id`
             INNER JOIN `products`
                        ON `products`.`id` = `user_cart_items`.`products_id`
             INNER JOIN `list_product`
                        ON `list_product`.`id` = `products`.`list_product_id`
             INNER JOIN `dict_color`
                        ON `dict_color`.`id` = `products`.`dict_color_id`
             INNER JOIN `dict_product`
                        ON `dict_product`.`id` = `list_product`.`dict_product_id`
             INNER JOIN `dict_size`
                        ON `dict_size`.`id` = `products`.`dict_size_id`
    WHERE `products`.`is_active` = 1
      AND `user_order`.`external_id` = _user_order__external_id
    GROUP BY `products`.`uuid`, `list_product`.`name`, `list_product`.`uuid`, `list_product`.`images`,
             `dict_color`.`code`, `dict_color`.`hex`, `dict_product`.`code`,
             `dict_size`.`name`, `dict_size`.`code`;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__product__cart_get_by_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__product__cart_get_by_uuid`(IN _product__uuid JSON,
                                                                                        IN _dict_country__iso CHAR(3))
BEGIN

    DECLARE __dict_currency__iso4217 CHAR(3);
    DECLARE __currency_exchange_rate__value DECIMAL(5, 3);
    DECLARE __product__uuid LONGTEXT;

    SET __product__uuid = TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM JSON_EXTRACT(_product__uuid, '$')));

    SELECT `dict_currency`.`iso4217`,
           `currency_exchange_rate`.`value`
    INTO __dict_currency__iso4217, __currency_exchange_rate__value
    FROM `dict_currency`
             LEFT JOIN `dict_country`
                       ON `dict_country`.`dict_currency_id` = `dict_currency`.`id`
             LEFT JOIN `currency_exchange_rate`
                       ON `currency_exchange_rate`.`dict_currency_id` = `dict_currency`.`id`
    WHERE `dict_country`.`iso` = _dict_country__iso;

    SET @__products = CONCAT('
    SELECT `products`.`uuid`                                  AS `products__uuid`,

           `list_product`.`name`                              AS `list_product__name`,
           CAST(IF(', __currency_exchange_rate__value, ' != 1,
                   (`list_product`.`price` * ', __currency_exchange_rate__value, ' / 100 DIV 10) * 10 + 10,
                   `list_product`.`price` / 100) AS UNSIGNED) AS `list_product__price`,
           `list_product`.`images`                            AS `list_product__images`,
           `list_product`.`uuid`                              AS `list_product__uuid`,

           "', __dict_currency__iso4217, '"                   AS `dict_currency__iso4217`,

           `dict_color`.`name`                                AS `dict_color__name`,
           `dict_color`.`code`                                AS `dict_color__code`,

           `dict_size`.`name`                                 AS `dict_size__name`

    FROM `products`
             LEFT JOIN `list_product`
                       ON `list_product`.`id` = `products`.`list_product_id`
             LEFT JOIN `dict_color`
                       ON `dict_color`.`id` = `products`.`dict_color_id`
             LEFT JOIN `dict_size`
                       ON `dict_size`.`id` = `products`.`dict_size_id`

    WHERE `products`.`is_active` = 1
      AND `list_product`.`is_active` = 1
      AND `products`.`uuid` IN (', __product__uuid, ');
');

    PREPARE `stmt` FROM @__products;
    EXECUTE `stmt`;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_support__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_support__insert`(IN _user__uuid CHAR(36),
                                                                                   IN _user_order__external_id VARCHAR(20),
                                                                                   IN _user_support__uuid CHAR(36),
                                                                                   IN _user_support_respond_to CHAR(255),
                                                                                   IN _body JSON)
BEGIN

    DECLARE __user__id INT(10) UNSIGNED;
    DECLARE __user_order__id INT(10) UNSIGNED;

    SELECT `user`.`id`
    INTO __user__id
    FROM `user`
    WHERE `user`.`uuid` = _user__uuid;

    SELECT `user_order`.`id`
    INTO __user_order__id
    FROM `user_order`
    WHERE `user_order`.`external_id` = _user_order__external_id;

    INSERT
    INTO `user_support`
    (`uuid`, `user_id`, `user_order_id`, `body`, `respond_to`, `modified`, `created`)
    VALUES (_user_support__uuid,
            __user__id,
            __user_order__id,
            _body,
            _user_support_respond_to,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__dict_currency__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__dict_currency__get`()
BEGIN

    SELECT `dict_currency`.`iso4217` AS `dict_currency__iso4217`
    FROM `dict_currency`
    WHERE `dict_currency`.`is_active` = 1;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__currency_exchange_rate__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__currency_exchange_rate__insert`(IN _data JSON)
BEGIN

    DECLARE __iteration INT(10) DEFAULT 0;
    DECLARE __currency_exchange_rate__data JSON;

    WHILE __iteration < JSON_LENGTH(_data)
        DO

            SET __currency_exchange_rate__data = JSON_UNQUOTE(JSON_EXTRACT(_data, CONCAT('$[', __iteration, ']')));

            INSERT
            INTO `currency_exchange_rate`
                (`dict_currency_id`, `value`, `created`, `modified`)
            SELECT `dict_currency`.`id`,
                   JSON_UNQUOTE(JSON_EXTRACT(__currency_exchange_rate__data, '$.value')),
                   UNIX_TIMESTAMP(),
                   UNIX_TIMESTAMP()
            FROM `dict_currency`
            WHERE `dict_currency`.`iso4217` =
                  JSON_UNQUOTE(JSON_EXTRACT(__currency_exchange_rate__data, '$.dict_currency__iso4217'))
            ON DUPLICATE KEY UPDATE `currency_exchange_rate`.`value`    = JSON_UNQUOTE(
                    JSON_EXTRACT(__currency_exchange_rate__data, '$.value')),
                                    `currency_exchange_rate`.`modified` = UNIX_TIMESTAMP();

            SET __currency_exchange_rate__data = NULL;
            SET __iteration = __iteration + 1;
        END WHILE;

END */$$
DELIMITER ;

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `created`, `modified`)
VALUES ('011_migration',
        `uuid_v4`(),
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
