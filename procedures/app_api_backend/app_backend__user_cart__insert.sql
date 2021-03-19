/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__insert`(IN user__uuid CHAR(36),
                                                                                IN user_cart__uuid CHAR(36),
                                                                                IN user_cart_items__data JSON)
BEGIN

    DECLARE `_user__id` INT(10) UNSIGNED;
    DECLARE `_user_cart__id` INT(10) UNSIGNED;
    DECLARE `_user_cart__item` CHAR(36);
    DECLARE `_products_id` INT(10) UNSIGNED;
    DECLARE `_iteration` INT(10) DEFAULT 0;

    IF (user__uuid IS NOT NULL)
    THEN

        SELECT `user`.`id`
        INTO `_user__id`
        FROM `user`
        WHERE `user`.`uuid` = user__uuid;

        IF `_user__id` IS NULL
        THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user id', MYSQL_ERRNO = 1000;
        END IF;

    END IF;

    INSERT
    INTO `user_cart`
        (`uuid`, `user_id`, `created`, `modified`)
    VALUES (user_cart__uuid, _user__id, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

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
            SELECT JSON_UNQUOTE(JSON_EXTRACT(user_cart_items__data, CONCAT('$[', _iteration, ']')))
            INTO _user_cart__item;

            SELECT `products`.`id`
            INTO _products_id
            FROM `products`
            WHERE `products`.`uuid` = _user_cart__item;

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
