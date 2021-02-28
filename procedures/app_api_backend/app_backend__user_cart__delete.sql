/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__delete` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__delete`(IN user_cart__uuid CHAR(36),
                                                                                IN product__uuid CHAR(36))
BEGIN

    DELETE `user_cart_items`
    FROM `user_cart_items`
             INNER JOIN `user_cart`
                        ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
             INNER JOIN `products`
                        ON `products`.`id` = `user_cart_items`.`products_id`
    WHERE `products`.`uuid` = product__uuid
      AND `user_cart`.`uuid` = user_cart__uuid;

END */$$
DELIMITER ;
