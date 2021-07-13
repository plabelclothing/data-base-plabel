# 013_migration

ALTER TABLE `transaction_customer`
    ADD FOREIGN KEY (`dict_country_id`) REFERENCES `dict_country` (`id`);

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
      AND `user_order`.`status` <> 'canceled'
    GROUP BY `products`.`uuid`, `list_product`.`name`, `list_product`.`uuid`, `list_product`.`images`,
             `dict_color`.`code`, `dict_color`.`hex`, `dict_product`.`code`,
             `dict_size`.`name`, `dict_size`.`code`;

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
      AND `user_order`.`status` <> "canceled"
    ORDER BY `user_order`.`created` DESC
    LIMIT 1;

    SELECT `user_order`.`id`
    INTO `__user_order__id_min`
    FROM `user_order`
             INNER JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
    WHERE `user`.`uuid` = _user__uuid
      AND `user_order`.`status` <> "canceled"
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
    WHERE `user`.`uuid` = ?
          AND `user_order`.`status` <> "canceled"';

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

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `created`, `modified`)
VALUES ('013_migration',
        `uuid_v4`(),
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
