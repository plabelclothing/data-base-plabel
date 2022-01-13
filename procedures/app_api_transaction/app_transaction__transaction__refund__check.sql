/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__refund__check` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__refund__check`(IN _user_cart_items__data JSON)
BEGIN

    DECLARE __user_cart__item CHAR(36);
    DECLARE __iteration INT(10) DEFAULT 0;

    SET @__query = 'SELECT `user_cart_items`.`uuid` AS `user_cart_items__uuid`
    FROM `user_cart_items`
             INNER JOIN `user_cart_items` AS `user_cart_items_refund`
                        ON `user_cart_items_refund`.`related_user_cart_items_id` = `user_cart_items`.`id`';

    WHILE __iteration < JSON_LENGTH(_user_cart_items__data)
        DO
            SELECT JSON_UNQUOTE(JSON_EXTRACT(_user_cart_items__data, CONCAT('$[', __iteration, ']')))
            INTO __user_cart__item;

            IF (__iteration = 0)
            THEN
                SET @__query = CONCAT(@__query, '
                WHERE `user_cart_items`.`uuid` = "', __user_cart__item, '"');
            ELSE
                SET @__query = CONCAT(@__query, '
                OR `user_cart_items`.`uuid` = "', __user_cart__item, '"');
            END IF;

            SET __user_cart__item = NULL;
            SET __iteration = __iteration + 1;
        END WHILE;

    SET @__query = CONCAT(@__query, ';');

    PREPARE `stmt` FROM @__query;
    EXECUTE `stmt`;

END */$$
DELIMITER ;
