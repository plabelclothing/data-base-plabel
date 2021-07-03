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
