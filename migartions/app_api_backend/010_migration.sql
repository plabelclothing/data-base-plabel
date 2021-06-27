# 010_migration

# region procedures

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_order__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_order__insert`(IN user_order__uuid CHAR(36),
                                                                                 IN user_cart__uuid CHAR(36),
                                                                                 IN user__uuid CHAR(36),
                                                                                 IN user_cart__additional_information JSON,
                                                                                 IN user_cart__address JSON,
                                                                                 IN user_cart__tracking_number VARCHAR(255))
BEGIN

    DECLARE `_user__id` INT(10) UNSIGNED;
    DECLARE `_user_cart__id` INT(10) UNSIGNED;

    IF (user__uuid IS NOT NULL)
    THEN

        SELECT `user`.`id`
        INTO _user__id
        FROM `user`
        WHERE `user`.`uuid` = user__uuid;

        IF `_user__id` IS NULL
        THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user id', MYSQL_ERRNO = 1000;
        END IF;

    END IF;

    SELECT `user_cart`.`id`
    INTO _user_cart__id
    FROM `user_cart`
    WHERE `user_cart`.`uuid` = user_cart__uuid;

    IF `_user_cart__id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user cart id', MYSQL_ERRNO = 1001;
    END IF;

    INSERT
    INTO `user_order`
    (`uuid`, `external_id`, `user_cart_id`, `user_id`, `status`, `additional_information`, `address`, `tracking_number`,
     `created`,
     `modified`)
    VALUES (user_order__uuid,
            `random_string`(20, '{"underscore": false,"upper":true}'),
            _user_cart__id,
            _user__id,
            'new',
            user_cart__additional_information,
            user_cart__address,
            user_cart__tracking_number,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_order__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_order__get`(IN _user__uuid CHAR(36),
                                                                              IN _user_order__id INT(10) UNSIGNED,
                                                                              IN _is_prev TINYINT(1) UNSIGNED,
                                                                              IN _limit INT(10) UNSIGNED)
BEGIN

    DECLARE `__user_order__id_max` INT(10) UNSIGNED;
    DECLARE `__user_order__id_min` INT(10) UNSIGNED;

    SELECT `user_order`.`id`
    INTO `__user_order__id_max`
    FROM `user_order`
             INNER JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
    WHERE `user`.`uuid` = _user__uuid
    ORDER BY `user_order`.`created` DESC
    LIMIT 1;

    SELECT `user_order`.`id`
    INTO `__user_order__id_min`
    FROM `user_order`
             INNER JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
    WHERE `user`.`uuid` = _user__uuid
    ORDER BY `user_order`.`created`
    LIMIT 1;

    SET @__query = '
SELECT     `user_order`.`uuid`                                AS `user_order__uuid`,
           `user_order`.`id`                                  AS `user_order__id`,
           `user_order`.`external_id`                         AS `user_order__external_id`,
           `user_order`.`order_status`                        AS `user_order__order_status`,
           `user_order`.`created`                             AS `user_order__created`,
           `transaction`.`amount`                             AS `transaction__amount`,
           `dict_currency`.`iso4217`                          AS `dict_currency__iso4217`,
           `dict_currency`.`symbol`                           AS `dict_currency__symbol`,
           UPPER(SUBSTRING(`user_order`.`external_id`, 1, 2)) AS `icon__text`,
            ?                                                 AS `user_order__id_max`,
            ?                                                 AS `user_order__id_min`
    FROM `user_order`
             INNER JOIN `transaction`
                        ON `transaction`.`user_order_id` = `user_order`.`id`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
             INNER JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
    WHERE `user`.`uuid` = ?';

    IF (_is_prev = 0 AND _user_order__id IS NOT NULL)
    THEN
        SET @__query = CONCAT(@__query, ' AND  `user_order`.`id` < ?');
    END IF;

    IF (_is_prev = 1 AND _user_order__id IS NOT NULL)
    THEN
        SET @__query = CONCAT(@__query, ' AND  `user_order`.`id` > ?');
    END IF;

    SET @__query = CONCAT(@__query, ' ORDER BY `user_order`.`created` ', IF(_is_prev = 0, 'DESC', 'ASC'));
    SET @__query = CONCAT(@__query, ' LIMIT ?;');

    SET @__user__uuid = _user__uuid;
    SET @__user_order__id = _user_order__id;
    SET @__limit = _limit;
    SET @__user_order__id_max = __user_order__id_max;
    SET @__user_order__id_min = __user_order__id_min;

    PREPARE `stmt` FROM @__query;

    IF (_user_order__id IS NOT NULL)
    THEN
        EXECUTE `stmt` USING @__user_order__id_max, @__user_order__id_min, @__user__uuid, @__user_order__id, @__limit;
    ELSE
        EXECUTE `stmt` USING @__user_order__id_max, @__user_order__id_min, @__user__uuid, @__limit;
    END IF;

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

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `created`, `modified`)
VALUES ('010_migration',
        `uuid_v4`(),
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
