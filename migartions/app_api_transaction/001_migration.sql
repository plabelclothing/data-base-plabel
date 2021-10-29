# 001_migration

DROP PROCEDURE IF EXISTS `app_backend__transaction__insert`;
DROP PROCEDURE IF EXISTS `app_backend__payment_method_auth__get`;
DROP PROCEDURE IF EXISTS `app_backend__transaction_log__insert`;
DROP PROCEDURE IF EXISTS `app_backend__transaction__get_by_external_id`;
DROP PROCEDURE IF EXISTS `app_backend__notification_ipn__insert`;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__notification_ipn__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__notification_ipn__insert`(IN _transaction__uuid CHAR(36),
                                                                                           IN _notification_ipn__data JSON)
BEGIN

    DECLARE `_transaction_id` INT(10) UNSIGNED;

    IF (_transaction__uuid IS NOT NULL)
    THEN
        SELECT `transaction`.`id`
        INTO `_transaction_id`
        FROM `transaction`
        WHERE `transaction`.`uuid` = _transaction__uuid;
    END IF;

    INSERT
    INTO `notification_ipn`
        (`uuid`, `transaction_id`, `data`, `created`, `modified`)
    VALUES (`uuid_v4`(),
            _transaction_id,
            _notification_ipn__data,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;


/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__payment_method_auth__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__payment_method_auth__get`(
    IN _payment_method_code VARCHAR(255))
BEGIN

    SELECT `payment_method_auth`.`data` AS `payment_method_auth__data`
    FROM `payment_method_auth`
             INNER JOIN `payment_method`
                        ON `payment_method`.`id` = `payment_method_auth`.`payment_method_id`
    WHERE `payment_method`.`code` = _payment_method_code;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__get_by_external_id` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__get_by_external_id`(IN transaction_external_id VARCHAR(255)
)
BEGIN

    SELECT `transaction`.`uuid` AS `transaction__uuid`
    FROM `transaction`
    WHERE `transaction`.`external_id` = transaction_external_id;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__insert`(IN _transaction__uuid CHAR(36),
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

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__update`(IN _transaction__uuid CHAR(36),
                                                                                      IN _transaction_external_id VARCHAR(255),
                                                                                      IN _transaction__status ENUM ('new','pending','settled','canceled','error'),
                                                                                      IN _transaction__settled_at INT(10) UNSIGNED)
BEGIN

    UPDATE `transaction`
    SET `transaction`.`external_id` = IFNULL(_transaction_external_id, `transaction`.`external_id`),
        `transaction`.`status`      = IFNULL(_transaction__status, `transaction`.`status`),
        `transaction`.`settled_at`  = IFNULL(_transaction__settled_at, `transaction`.`settled_at`),
        `transaction`.`modified`    = UNIX_TIMESTAMP()
    WHERE `transaction`.`uuid` = _transaction__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction_log__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction_log__insert`(IN _transaction__uuid CHAR(36),
                                                                                          IN _transaction_log__data JSON)
BEGIN

    INSERT
    INTO `transaction_log`
        (`uuid`, `transaction_id`, `data`, `created`, `modified`)
    SELECT `uuid_v4`(),
           `transaction`.`id`,
           _transaction_log__data,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `transaction`
    WHERE `transaction`.`uuid` = _transaction__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__user_order__get_email_send` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__user_order__get_email_send`(IN _transaction__uuid CHAR(36))
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

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__user_order__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__user_order__update`(IN _transaction__uuid CHAR(36),
                                                                                     IN _user_order__address JSON,
                                                                                     IN _status ENUM ('new','approved','canceled'),
                                                                                     IN _order_status ENUM ('new','pending','shipped', 'delivered'))
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

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__notification_email__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__notification_email__update`(IN _notification_email__uuid CHAR(36),
                                                                                             IN _notification_email__status ENUM ('new','pending','sent','error'))
BEGIN

    UPDATE `notification_email`
    SET `notification_email`.`status`   = _notification_email__status,
        `notification_email`.`modified` = UNIX_TIMESTAMP()
    WHERE `notification_email`.`uuid` = _notification_email__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__notification_email__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__notification_email__insert`(IN _notification_email__uuid CHAR(36),
                                                                                             IN _user__uuid CHAR(36),
                                                                                             IN _notification_email__to VARCHAR(155),
                                                                                             IN _notification_email__template VARCHAR(155),
                                                                                             IN _notification_email__status ENUM ('new','pending','sent','error'),
                                                                                             IN _notification_email__body JSON)
BEGIN

    DECLARE `_user__id` INT(10) UNSIGNED;

    SELECT `user`.`id`
    INTO `_user__id`
    FROM `user`
    WHERE `user`.`uuid` = _user__uuid;

    INSERT
    INTO `notification_email`
    (`user_id`, `uuid`, `to`, `template`, `status`, `body`, `created`, `modified`)
    VALUES (_user__id,
            _notification_email__uuid,
            _notification_email__to,
            _notification_email__template,
            _notification_email__status,
            _notification_email__body,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `code`, `created`, `modified`)
VALUES ('001_migration',
        `uuid_v4`(),
        'API_TRANSACTION',
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
