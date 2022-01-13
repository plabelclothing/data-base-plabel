/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__refund__get_data` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__refund__get_data`(IN _user_cart_items__data JSON)
BEGIN

    DECLARE __user_cart__item CHAR(36);
    DECLARE __iteration INT(10) DEFAULT 0;

    SET @__query = 'SELECT `user`.`uuid` AS `user__uuid`,
                           `user_order`.`uuid` AS `user_order__uuid`,
                           `user_order`.`external_id` AS `user_order__external_id`,
                           `transaction`.`uuid` AS `transaction__uuid`,
                           `transaction`.`external_id` AS `transaction__external_id`,
                           `transaction`.`status` AS `transaction__status`,
                           `transaction`.`capture_id` AS `transaction__capture_id`,
                           `payment_method`.`code` AS `payment_method__code`,
                           `dict_currency`.`iso4217` AS `dict_currency__iso4217`
    FROM `user_cart_items`
             INNER JOIN `user_cart`
                        ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
             INNER JOIN `user_order`
                        ON `user_order`.`user_cart_id` = `user_cart`.`id`
             LEFT JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
             INNER JOIN `transaction`
                        ON `transaction`.`user_order_id` = `user_order`.`id`
             INNER JOIN `payment_method`
                        ON `payment_method`.`id` = `transaction`.`payment_method_id`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `transaction`.`dict_currency_id`';

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

    SET @__query = CONCAT(@__query, '
    GROUP BY `user`.`uuid`, `user_order`.`uuid`, `transaction`.`uuid`, `payment_method`.`code`;');

    PREPARE `stmt` FROM @__query;
    EXECUTE `stmt`;

END */$$
DELIMITER ;
