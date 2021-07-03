# 011_migration

CREATE TABLE `transaction_customer`
(
    `id`              INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `transaction_id`  INT(10) UNSIGNED NOT NULL,
    `dict_country_id` INT(10) UNSIGNED NOT NULL,
    `locale`          CHAR(3)          NOT NULL,
    `modified`        INT(10) UNSIGNED NOT NULL,
    `created`         INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`transaction_id`),
    FOREIGN KEY (`transaction_id`) REFERENCES `transaction` (`id`)
);

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction__insert`(IN _transaction__uuid CHAR(36),
                                                                                  IN _user_order__uuid CHAR(36),
                                                                                  IN _payment_method__code VARCHAR(255),
                                                                                  IN _dict_currency__iso4217 CHAR(3),
                                                                                  IN _transaction__amount INT(10) UNSIGNED,
                                                                                  IN _transaction__status ENUM ('pending','settled','canceled','error', 'new'),
                                                                                  IN _transaction_customer__locale CHAR(3),
                                                                                  IN _dict_country__iso CHAR(3))
BEGIN

    DECLARE __user_order__id INT(10) UNSIGNED;
    DECLARE __payment_method__id INT(10) UNSIGNED;
    DECLARE __dict_currency__id INT(10) UNSIGNED;
    DECLARE __dict_country__id INT(10) UNSIGNED;
    DECLARE __transaction__id INT(10) UNSIGNED;

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
    INTO __user_order__id
    FROM `user_order`
    WHERE `user_order`.`uuid` = _user_order__uuid;

    IF __user_order__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user order id', MYSQL_ERRNO = 1000;
    END IF;

    SELECT `payment_method`.`id`
    INTO __payment_method__id
    FROM `payment_method`
    WHERE `payment_method`.`code` = _payment_method__code;

    IF __payment_method__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No payment method id', MYSQL_ERRNO = 1001;
    END IF;

    SELECT `dict_currency`.`id`
    INTO __dict_currency__id
    FROM `dict_currency`
    WHERE `dict_currency`.`iso4217` = _dict_currency__iso4217;

    IF __dict_currency__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No dict currency id', MYSQL_ERRNO = 1002;
    END IF;

    SELECT `dict_country`.`id`
    INTO __dict_country__id
    FROM `dict_country`
    WHERE `dict_country`.`iso` = _dict_country__iso;

    IF __dict_country__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No dict country id', MYSQL_ERRNO = 1002;
    END IF;

    INSERT
    INTO `transaction`
    (`uuid`, `user_order_id`, `payment_method_id`, `dict_currency_id`, `amount`, `status`, `created`, `modified`)
    VALUES (_transaction__uuid,
            __user_order__id,
            __payment_method__id,
            __dict_currency__id,
            _transaction__amount,
            _transaction__status,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

    SELECT LAST_INSERT_ID()
    INTO __transaction__id;

    INSERT
    INTO `transaction_customer`
        (`transaction_id`, `dict_country_id`, `locale`, `modified`, `created`)
    VALUES (__transaction__id,
            __dict_country__id,
            _transaction_customer__locale,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());
    COMMIT;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_order__get_email_send` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_order__get_email_send`(IN _transaction__uuid CHAR(36))
BEGIN

    SELECT `user_order`.`external_id`      AS `user_order__external_id`,
           `user_order`.`address`          AS `user_order__address`,
           `user_order`.`created`          AS `user_order__created`,
           `user_order`.`status`           AS `user_order__status`,

           COUNT(`products`.`id`)          AS `products__count`,

           `user`.`uuid`                   AS `user__uuid`,

           `list_product`.`name`           AS `list_product__name`,
           `list_product`.`images`         AS `list_product__images`,

           `user_cart_items`.`amount`      AS `user_cart_items__amount`,

           `dict_currency`.`iso4217`       AS `dict_currency__iso4217`,

           `transaction`.`amount`          AS `transaction__amount`,
           `transaction`.`status`          AS `transaction__status`,

           `dict_color`.`code`             AS `dict_color__code`,

           `dict_size`.`name`              AS `dict_size__name`,

           `payment_method`.`name`         AS `payment_method__name`,

           `transaction_customer`.`locale` AS `transaction_customer__locale`

    FROM `user_cart`
             INNER JOIN `user_order`
                        ON `user_order`.`user_cart_id` = `user_cart`.`id`
             INNER JOIN `transaction`
                        ON `transaction`.`user_order_id` = `user_order`.`id`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
             INNER JOIN `payment_method`
                        ON `payment_method`.`id` = `transaction`.`payment_method_id`
             INNER JOIN `transaction_customer`
                        ON `transaction_customer`.`transaction_id` = `transaction`.`id`
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
             INNER JOIN `dict_size`
                        ON `dict_size`.`id` = `products`.`dict_size_id`
    WHERE `products`.`is_active` = 1
      AND `transaction`.`uuid` = _transaction__uuid
    GROUP BY `list_product`.`name`, `list_product`.`images`,
             `dict_color`.`code`, `dict_size`.`name`;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__products__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__products__get`(IN _params JSON,
                                                                            IN _dict_country__iso CHAR(3))
BEGIN

    DECLARE __dict_collection__code JSON;
    DECLARE __dict_color__code JSON;
    DECLARE __dict_product__code JSON;
    DECLARE __dict_size__code JSON;
    DECLARE __dict_type_of_product__code JSON;
    DECLARE __dict_currency__iso4217 CHAR(3);
    DECLARE __dict_currency__symbol CHAR(3);
    DECLARE __currency_exchange_rate__value DECIMAL(5, 3);
    DECLARE __search_phrase LONGTEXT;

    SELECT `dict_currency`.`iso4217`,
           `dict_currency`.`symbol`,
           `currency_exchange_rate`.`value`
    INTO __dict_currency__iso4217, __dict_currency__symbol, __currency_exchange_rate__value
    FROM `dict_currency`
             LEFT JOIN `dict_country`
                       ON `dict_country`.`dict_currency_id` = `dict_currency`.`id`
             LEFT JOIN `currency_exchange_rate`
                       ON `currency_exchange_rate`.`dict_currency_id` = `dict_currency`.`id`
    WHERE `dict_country`.`iso` = _dict_country__iso;

    SET __dict_collection__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictCollectionCode') = 1,
                                     JSON_EXTRACT(`_params`, '$.dictCollectionCode'), '[]');
    SET __search_phrase = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.searchPhrase') = 1,
                             JSON_UNQUOTE(JSON_EXTRACT(`_params`, '$.searchPhrase')), '');
    SET __dict_color__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictColorCode') = 1,
                                JSON_EXTRACT(`_params`, '$.dictColorCode'), '[]');
    SET __dict_size__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictSizeCode') = 1,
                               JSON_EXTRACT(`_params`, '$.dictSizeCode'), '[]');
    SET __dict_type_of_product__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictTypeOfProductCode') = 1,
                                          JSON_EXTRACT(`_params`, '$.dictTypeOfProductCode'), '[]');
    SET __dict_product__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictProductCode') = 1,
                                  JSON_EXTRACT(`_params`, '$.dictProductCode'), '[]');

    SET @__products = CONCAT('SELECT
       `products`.`uuid` AS `products__uuid`,

       `list_product`.`name` AS `list_product__name`,
       CAST(IF(', __currency_exchange_rate__value, ' != 1, (`list_product`.`price` * ', __currency_exchange_rate__value, ' / 100 DIV 10) * 10 + 10, `list_product`.`price` / 100) AS UNSIGNED)  AS `list_product__price`,
       `list_product`.`uuid` AS `list_product__uuid`,
       `list_product`.`id`   AS `list_product__id`,
       `list_product`.`images` AS `list_product__images`,

       "', __dict_currency__iso4217, '" AS `dict_currency_iso4217`,
       "', __dict_currency__symbol, '" AS `dict_currency_symbol`,

       `dict_collection`.`name` AS `dict_collection__name`,
       `dict_collection`.`code` AS `dict_collection__code`,

       `dict_color`.`name` AS `dict_color__name`,
       `dict_color`.`code` AS `dict_color__code`,
       `dict_color`.`hex` AS `dict_color__hex`,

       `dict_product`.`name` AS `dict_product__name`,
       `dict_product`.`code` AS `dict_product__code`,

       `dict_size`.`name` AS `dict_size__name`,
       `dict_size`.`code` AS `dict_size__code`,

       `dict_type_of_product`.`name` AS `dict_type_of_product__name`,
       `dict_type_of_product`.`code` AS `dict_type_of_product__code`

       FROM `products`
           LEFT JOIN `list_product`
               ON `list_product`.`id` = `products`.`list_product_id`
           LEFT JOIN `dict_collection`
               ON `dict_collection`.`id` = `list_product`.`dict_collection_id`
           LEFT JOIN `dict_color`
                     ON `dict_color`.`id` = `products`.`dict_color_id`
           LEFT JOIN `dict_product`
                     ON `dict_product`.`id` = `list_product`.`dict_product_id`
           LEFT JOIN `dict_size`
                     ON `dict_size`.`id` = `products`.`dict_size_id`
           LEFT JOIN `dict_type_of_product`
                     ON `dict_type_of_product`.`id` = `list_product`.`dict_type_of_product_id`

    WHERE `products`.`is_active` = 1
    AND `list_product`.`is_active` = 1',
                             IF(__search_phrase = '', '',
                                CONCAT(' AND `list_product`.`name` LIKE "%', __search_phrase, '%"')),
                             IF(IFNULL(JSON_LENGTH(__dict_collection__code), 0) = 0, '',
                                CONCAT(' AND `dict_collection`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_collection__code)), ')')),
                             IF(IFNULL(JSON_LENGTH(__dict_color__code), 0) = 0, '',
                                CONCAT(' AND `dict_color`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_color__code)), ')')),
                             IF(IFNULL(JSON_LENGTH(__dict_product__code), 0) = 0, '',
                                CONCAT(' AND `dict_product`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_product__code)), ')')),
                             IF(IFNULL(JSON_LENGTH(__dict_size__code), 0) = 0, '',
                                CONCAT(' AND `dict_size`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_size__code)), ')')),
                             IF(IFNULL(JSON_LENGTH(__dict_type_of_product__code), 0) = 0, '',
                                CONCAT(' AND `dict_type_of_product`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_type_of_product__code)),
                                       ')')),
                             ' ORDER BY `list_product`.`created` DESC '
        );

    PREPARE `stmt` FROM @__products;
    EXECUTE `stmt`;

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
