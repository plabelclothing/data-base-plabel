# 002_migration

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__refund__check` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__refund__check`(IN _user_cart_items__data JSON)
BEGIN

    DECLARE __user_cart__item CHAR(36);
    DECLARE __iteration INT(10) DEFAULT 0;

    SET @__query = 'SELECT `user_cart_items`.`uuid` AS `user_cart_items__uuid`
    FROM `user_cart_items`
             INNER JOIN `user_cart_items` AS `user_cart_items_refund`
                        ON `user_cart_items_refund`.`related_user_cart_items_id` = `user_cart_items`.`id`';

    WHILE __iteration < JSON_LENGTH(_user_cart_items__data)
        DO
            SELECT JSON_UNQUOTE(JSON_EXTRACT(_user_cart_items__data, CONCAT('$[', __iteration, ']')))
            INTO __user_cart__item;

            IF (__iteration = 0)
            THEN
                SET @__query = CONCAT(@__query, '
                WHERE `user_cart_items`.`uuid` = "', __user_cart__item, '"');
            ELSE
                SET @__query = CONCAT(@__query, '
                OR `user_cart_items`.`uuid` = "', __user_cart__item, '"');
            END IF;

            SET __user_cart__item = NULL;
            SET __iteration = __iteration + 1;
        END WHILE;

    SET @__query = CONCAT(@__query, ';');

    PREPARE `stmt` FROM @__query;
    EXECUTE `stmt`;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__refund__get_by_status` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__refund__get_by_status`(IN _transaction__status ENUM ('pending','settled','canceled','error', 'new'),
                                                                                                     IN _transaction__type ENUM ('sale', 'refund'),
                                                                                                     IN _payment_method__code VARCHAR(255))
BEGIN

    SET @__query = 'SELECT
                           `transaction`.`uuid` AS `transaction__uuid`,
                           `transaction`.`external_id` AS `transaction__external_id`
    FROM `transaction`
             INNER JOIN `payment_method`
                        ON `payment_method`.`id` = `transaction`.`payment_method_id`
    WHERE `transaction`.`status` = ?
        AND `transaction`.`type` = ?';

    IF (_payment_method__code IS NOT NULL)
    THEN
        SET @__query = CONCAT(@__query, '
        AND `payment_method`.`code` = "', _payment_method__code, '"');
    END IF;

    SET @__query = CONCAT(@__query, ';');

    SET @__transaction__status = _transaction__status;
    SET @__transaction__type = _transaction__type;

    PREPARE `stmt` FROM @__query;
    EXECUTE `stmt` USING @__transaction__status, @__transaction__type;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__refund__get_data` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__refund__get_data`(IN _user_cart_items__data JSON)
BEGIN

    DECLARE __user_cart__item CHAR(36);
    DECLARE __iteration INT(10) DEFAULT 0;

    SET @__query = 'SELECT `user`.`uuid` AS `user__uuid`,
                           `user_order`.`uuid` AS `user_order__uuid`,
                           `user_order`.`external_id` AS `user_order__external_id`,
                           `transaction`.`uuid` AS `transaction__uuid`,
                           `transaction`.`external_id` AS `transaction__external_id`,
                           `transaction`.`status` AS `transaction__status`,
                           `transaction`.`capture_id` AS `transaction__capture_id`,
                           `payment_method`.`code` AS `payment_method__code`,
                           `dict_currency`.`iso4217` AS `dict_currency__iso4217`
    FROM `user_cart_items`
             INNER JOIN `user_cart`
                        ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
             INNER JOIN `user_order`
                        ON `user_order`.`user_cart_id` = `user_cart`.`id`
             LEFT JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
             INNER JOIN `transaction`
                        ON `transaction`.`user_order_id` = `user_order`.`id`
             INNER JOIN `payment_method`
                        ON `payment_method`.`id` = `transaction`.`payment_method_id`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `transaction`.`dict_currency_id`';

    WHILE __iteration < JSON_LENGTH(_user_cart_items__data)
        DO
            SELECT JSON_UNQUOTE(JSON_EXTRACT(_user_cart_items__data, CONCAT('$[', __iteration, ']')))
            INTO __user_cart__item;

            IF (__iteration = 0)
            THEN
                SET @__query = CONCAT(@__query, '
                WHERE `user_cart_items`.`uuid` = "', __user_cart__item, '"');
            ELSE
                SET @__query = CONCAT(@__query, '
                OR `user_cart_items`.`uuid` = "', __user_cart__item, '"');
            END IF;

            SET __user_cart__item = NULL;
            SET __iteration = __iteration + 1;
        END WHILE;

    SET @__query = CONCAT(@__query, '
    GROUP BY `user`.`uuid`, `user_order`.`uuid`, `transaction`.`uuid`, `payment_method`.`code`;');

    PREPARE `stmt` FROM @__query;
    EXECUTE `stmt`;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__refund__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__refund__insert`(IN _user__uuid CHAR(36),
                                                                                              IN _user_cart__uuid CHAR(36),
                                                                                              IN _user_cart_items__data JSON,
                                                                                              IN _user_order__uuid CHAR(36),
                                                                                              IN _user_order__uuid_sale CHAR(36),
                                                                                              IN _transaction__uuid CHAR(36),
                                                                                              IN _transaction__uuid_sale CHAR(36))
BEGIN

    DECLARE __user__id INT(10) UNSIGNED;
    DECLARE __user_cart__id INT(10) UNSIGNED;
    DECLARE __user_order__id INT(10) UNSIGNED;
    DECLARE __transaction__id INT(10) UNSIGNED;
    DECLARE __user_cart_items__id INT(10) UNSIGNED;
    DECLARE __user_cart__item CHAR(36);
    DECLARE __products_id INT(10) UNSIGNED;
    DECLARE __iteration INT(10) DEFAULT 0;
    DECLARE __dict_currency__id INT(10) UNSIGNED;
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

    # insert user cart and user cart items
    INSERT
    INTO `user_cart`
    (`uuid`, `user_id`, `created`, `modified`)
    VALUES (_user_cart__uuid, __user__id, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

    SELECT LAST_INSERT_ID()
    INTO __user_cart__id;

    WHILE __iteration < JSON_LENGTH(_user_cart_items__data)
        DO
            SELECT JSON_UNQUOTE(JSON_EXTRACT(_user_cart_items__data, CONCAT('$[', __iteration, ']')))
            INTO __user_cart__item;

            SELECT `user_cart_items`.`id`,
                   `user_cart_items`.`amount`,
                   `user_cart_items`.`products_id`,
                   `user_cart_items`.`dict_currency_id`
            INTO __user_cart_items__id, __list_product__price, __products_id, __dict_currency__id
            FROM `user_cart_items`
            WHERE `user_cart_items`.`uuid` = __user_cart__item;

            SET __sum = __sum + __list_product__price;

            INSERT
            INTO `user_cart_items`
            (`uuid`, `user_cart_id`, `products_id`, `dict_currency_id`, `related_user_cart_items_id`, `type`, `amount`,
             `created`, `modified`)
            VALUES (`uuid_v4`(),
                    `__user_cart__id`,
                    `__products_id`,
                    `__dict_currency__id`,
                    `__user_cart_items__id`,
                    'refund',
                    `__list_product__price`,
                    UNIX_TIMESTAMP(),
                    UNIX_TIMESTAMP());

            SET __user_cart__item = NULL;
            SET __products_id = NULL;
            SET __user_cart_items__id = NULL;
            SET __list_product__price = NULL;
            SET __iteration = __iteration + 1;
        END WHILE;

    # insert order
    INSERT
    INTO `user_order`
    (`uuid`, `external_id`, `user_cart_id`, `user_id`, `status`, `additional_information`, `address`, `tracking_number`,
     `created`, `modified`)
    SELECT _user_order__uuid,
           `random_string`(20, '{"underscore": false,"upper":false}'),
           __user_cart__id,
           `user_order`.`user_id`,
           'approved',
           `user_order`.`additional_information`,
           `user_order`.`address`,
           NULL,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `user_order`
    WHERE `user_order`.`uuid` = _user_order__uuid_sale;

    SELECT LAST_INSERT_ID()
    INTO __user_order__id;

    # insert refund transaction
    INSERT
    INTO `transaction`
    (`uuid`, `user_order_id`, `payment_method_id`, `dict_currency_id`, `amount`, `related_transaction_id`, `type`,
     `status`, `created`,
     `modified`)
    SELECT _transaction__uuid,
           __user_order__id,
           `transaction`.`payment_method_id`,
           `transaction`.`dict_currency_id`,
           __sum,
           `transaction`.`id`,
           'refund',
           'new',
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `transaction`
    WHERE `transaction`.`uuid` = _transaction__uuid_sale;

    SELECT LAST_INSERT_ID()
    INTO __transaction__id;

    # insert transaction customer
    INSERT
    INTO `transaction_customer`
    (`transaction_id`, `dict_country_id`, `locale`, `modified`, `created`)
    SELECT __transaction__id,
           `transaction_customer`.`dict_country_id`,
           `transaction_customer`.`locale`,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `transaction_customer`
             INNER JOIN `transaction`
                        ON `transaction`.`id` = `transaction_customer`.`transaction_id`
    WHERE `transaction`.`uuid` = _transaction__uuid_sale;

    SELECT __sum AS `amount`;
    COMMIT;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__update`(IN _transaction__uuid CHAR(36),
                                                                                      IN _transaction__external_id VARCHAR(255),
                                                                                      IN _transaction__status ENUM ('new','pending','settled','canceled','error'),
                                                                                      IN _transaction__settled_at INT(10) UNSIGNED,
                                                                                      IN _transaction__capture_id VARCHAR(255))
BEGIN

    UPDATE `transaction`
    SET `transaction`.`external_id` = IFNULL(_transaction__external_id, `transaction`.`external_id`),
        `transaction`.`status`      = IFNULL(_transaction__status, `transaction`.`status`),
        `transaction`.`settled_at`  = IFNULL(_transaction__settled_at, `transaction`.`settled_at`),
        `transaction`.`capture_id`  = IFNULL(_transaction__capture_id, `transaction`.`capture_id`),
        `transaction`.`modified`    = UNIX_TIMESTAMP()
    WHERE `transaction`.`uuid` = _transaction__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__user_order__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__user_order__update`(IN _transaction__uuid CHAR(36),
                                                                                     IN _user_order__address JSON,
                                                                                     IN _status ENUM ('new','approved','canceled'),
                                                                                     IN _order_status ENUM ('new','pending','shipped', 'delivered', 'refunded'))
BEGIN

    UPDATE `user_order`
        INNER JOIN `transaction`
        ON `transaction`.`user_order_id` = `user_order`.`id`
    SET `user_order`.`status`       = IFNULL(_status, `user_order`.`status`),
        `user_order`.`order_status` = IFNULL(_order_status, `user_order`.`order_status`),
        `user_order`.`address`      = IFNULL(JSON_MERGE_PATCH(`user_order`.`address`, _user_order__address),
                                             `user_order`.`address`),
        `user_order`.`modified`     = UNIX_TIMESTAMP()
    WHERE `transaction`.`uuid` = _transaction__uuid;

END */$$
DELIMITER ;

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `code`, `created`, `modified`)
VALUES ('002_migration',
        `uuid_v4`(),
        'API_TRANSACTION',
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
