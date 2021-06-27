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
