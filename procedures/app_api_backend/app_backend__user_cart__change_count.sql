/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__change_count` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__change_count`(IN user_cart__uuid CHAR(36),
                                                                                      IN product__uuid CHAR(36),
                                                                                      IN type ENUM ('subtract', 'add'))
BEGIN

    DECLARE _user_cart_items__id INT(10) UNSIGNED;

    IF (type = 'add')
    THEN

        INSERT
        INTO `user_cart_items`
            (`user_cart_id`, `products_id`, `created`, `modified`)
        SELECT `user_cart_items`.`user_cart_id`,
               `user_cart_items`.`products_id`,
               UNIX_TIMESTAMP(),
               UNIX_TIMESTAMP()
        FROM `user_cart_items`
                 INNER JOIN `user_cart`
                            ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
                 INNER JOIN `products`
                            ON `products`.`id` = `user_cart_items`.`products_id`
        WHERE `products`.`uuid` = product__uuid
          AND `user_cart`.`uuid` = user_cart__uuid;

    END IF;

    IF (type = 'subtract')
    THEN

        SELECT `user_cart_items`.`id`
        INTO _user_cart_items__id
        FROM `user_cart_items`
                 INNER JOIN `user_cart`
                            ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
                 INNER JOIN `products`
                            ON `products`.`id` = `user_cart_items`.`products_id`
        WHERE `products`.`uuid` = product__uuid
          AND `user_cart`.`uuid` = user_cart__uuid
        LIMIT 1;

        DELETE
        FROM `user_cart_items`
        WHERE `user_cart_items`.`id` = `_user_cart_items__id`;

    END IF;

END */$$
DELIMITER ;
