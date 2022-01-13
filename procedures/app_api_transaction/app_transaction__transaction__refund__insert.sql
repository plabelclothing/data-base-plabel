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
