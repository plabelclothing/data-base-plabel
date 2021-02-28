/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__update`(IN user_cart__uuid CHAR(36),
                                                                                IN user_cart_items__data JSON)
BEGIN

    DECLARE `_user_cart__id` INT(10) UNSIGNED;
    DECLARE `_user_cart__item` JSON;
    DECLARE `_products_id` INT(10) UNSIGNED;
    DECLARE `_iteration` INT(10) DEFAULT 0;

    SELECT `user_cart`.`id`
    INTO `_user_cart__id`
    FROM `user_cart`
    WHERE `user_cart`.`uuid` = user_cart__uuid;

    IF `_user_cart__id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user cart id', MYSQL_ERRNO = 1001;
    END IF;

    WHILE _iteration < JSON_LENGTH(user_cart_items__data)
        DO
            SELECT JSON_EXTRACT(user_cart_items__data, CONCAT('$[', _iteration, ']'))
            INTO _user_cart__item;

            SELECT `products`.`id`
            INTO _products_id
            FROM `products`
            WHERE `products`.`uuid` = JSON_UNQUOTE(JSON_EXTRACT(_user_cart__item, '$.productUuid'));

            INSERT
            INTO `user_cart_items`
                (`user_cart_id`, `products_id`, `created`, `modified`)
            VALUES (`_user_cart__id`,
                    `_products_id`,
                    UNIX_TIMESTAMP(),
                    UNIX_TIMESTAMP());

            SET _user_cart__item = NULL;
            SET _products_id = NULL;
            SET _iteration = _iteration + 1;
        END WHILE;

END */$$
DELIMITER ;
