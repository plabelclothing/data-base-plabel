/*!50003 DROP PROCEDURE IF EXISTS `app_backend__product__cart_get_by_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__product__cart_get_by_uuid`(IN _product__uuid JSON,
                                                                                        IN _dict_country__iso CHAR(3))
BEGIN

    DECLARE __dict_currency__symbol CHAR(3);
    DECLARE __currency_exchange_rate__value DECIMAL(5, 3);
    DECLARE __product__uuid LONGTEXT;

    SET __product__uuid = TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM JSON_EXTRACT(_product__uuid, '$')));

    SELECT `dict_currency`.`symbol`,
           `currency_exchange_rate`.`value`
    INTO __dict_currency__symbol, __currency_exchange_rate__value
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

           "', __dict_currency__symbol, '"                    AS `dict_currency_symbol`,

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
