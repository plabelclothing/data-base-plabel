/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart_items__get_by_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart_items__get_by_uuid`(IN _user_cart__uuid CHAR(36),
                                                                                           IN _dict_country__iso CHAR(3))
BEGIN

    DECLARE __dict_currency__iso4217 CHAR(3);
    DECLARE __dict_currency__symbol CHAR(3);
    DECLARE __currency_exchange_rate__value DECIMAL(5, 3);

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

    SELECT COUNT(`products`.`id`)                             AS `products__count`,
           `products`.`uuid`                                  AS `products__uuid`,

           `list_product`.`name`                              AS `list_product__name`,
           CAST(IF(__currency_exchange_rate__value != 1,
                   (`list_product`.`price` * __currency_exchange_rate__value / 100 DIV 10) * 10 + 10,
                   `list_product`.`price` / 100) AS UNSIGNED) AS `list_product__price`,
           `list_product`.`uuid`                              AS `list_product__uuid`,
           `list_product`.`images`                            AS `list_product__images`,

           __dict_currency__iso4217                           AS `dict_currency_iso4217`,
           __dict_currency__symbol                            AS `dict_currency_symbol`,

           `dict_color`.`name`                                AS `dict_color__name`,
           `dict_color`.`code`                                AS `dict_color__code`,
           `dict_color`.`hex`                                 AS `dict_color__hex`,

           `dict_product`.`name`                              AS `dict_product__name`,
           `dict_product`.`code`                              AS `dict_product__code`,

           `dict_size`.`name`                                 AS `dict_size__name`,
           `dict_size`.`code`                                 AS `dict_size__code`

    FROM `user_cart`
             LEFT JOIN `user_cart_items`
                       ON `user_cart_items`.`user_cart_id` = `user_cart`.`id`
             INNER JOIN `products`
                        ON `products`.`id` = `user_cart_items`.`products_id`
             LEFT JOIN `list_product`
                       ON `list_product`.`id` = `products`.`list_product_id`
             LEFT JOIN `dict_color`
                       ON `dict_color`.`id` = `products`.`dict_color_id`
             LEFT JOIN `dict_product`
                       ON `dict_product`.`id` = `list_product`.`dict_product_id`
             LEFT JOIN `dict_size`
                       ON `dict_size`.`id` = `products`.`dict_size_id`

    WHERE `products`.`is_active` = 1
      AND `user_cart`.`is_active` = 1
      AND `user_cart`.`uuid` = _user_cart__uuid

    GROUP BY `products`.`uuid`, `list_product`.`name`, `list_product`.`uuid`, `list_product`.`images`,
             `dict_color`.`name`, `dict_color`.`code`, `dict_color`.`hex`, `dict_product`.`name`, `dict_product`.`code`,
             `dict_size`.`name`, `dict_size`.`code`;


END */$$
DELIMITER ;
