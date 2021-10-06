/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_order__get_by_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_order__get_by_uuid`(IN `_user_order__uuid` CHAR(36))
BEGIN

    SELECT `user_order`.`external_id`                                                  AS `user_order__external_id`,
           COUNT(`products`.`id`)                                                      AS `products__count`,
           `user_order`.`uuid`                                                         AS `user_order__uuid`,
           `user_order`.`order_status`                                                 AS `user_order__order_status`,
           `user_order`.`status`                                                       AS `user_order__status`,
           IF(JSON_UNQUOTE(
                      JSON_EXTRACT(`user_order`.`additional_information`, '$.value')) = 'null', '', JSON_UNQUOTE(
                      JSON_EXTRACT(`user_order`.`additional_information`, '$.value'))) AS `user_order__additional_information`,
           `user_order`.`address`                                                      AS `user_order__address`,

           `transaction`.`amount`                                                      AS `transaction__amount`,

           `dict_currency`.`iso4217`                                                   AS `dict_currency__iso4217`,

           IFNULL(`user`.`email`, '')                                                  AS `user__email`,

           `products`.`uuid`                                                           AS `products__uuid`,

           `list_product`.`name`                                                       AS `list_product__name`,

           `dict_color`.`name`                                                         AS `dict_color__name`,

           `dict_size`.`name`                                                          AS `dict_size__name`,

           `user_cart_items`.`amount`                                                  AS `user_cart_items__amount`,

           `dict_currency_user_cart`.`iso4217`                                         AS `dict_currency_user_cart__iso4217`

    FROM `user_order`
             LEFT JOIN `user`
                       ON `user`.`id` = `user_order`.`user_id`
             INNER JOIN `transaction`
                        ON `transaction`.`user_order_id` = `user_order`.`id`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
             INNER JOIN `user_cart`
                        ON `user_cart`.`id` = `user_order`.`user_cart_id`
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
             INNER JOIN `dict_currency` AS `dict_currency_user_cart`
                        ON `dict_currency_user_cart`.`id` = `user_cart_items`.`dict_currency_id`
    WHERE `user_order`.`uuid` = _user_order__uuid
    GROUP BY `products`.`uuid`;

END */$$
DELIMITER ;
