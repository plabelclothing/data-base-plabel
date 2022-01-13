/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_order__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_order__get`(IN `_date_from` INT(10) UNSIGNED,
                                                                                         IN `_data_to` INT(10) UNSIGNED,
                                                                                         IN `_conditions` JSON)
BEGIN

    DECLARE `__user_order__external_id` JSON;
    DECLARE `__user__email` JSON;
    DECLARE `__user_order__status` JSON;
    DECLARE `__user_order__order_status` JSON;

    SET __user_order__external_id = JSON_EXTRACT(`_conditions`, '$.user_order__external_id');
    SET __user__email = JSON_EXTRACT(`_conditions`, '$.user__email');
    SET __user_order__status = JSON_EXTRACT(`_conditions`, '$.user_order__status');
    SET __user_order__order_status = JSON_EXTRACT(`_conditions`, '$.user_order__order_status');

    SET @__query = CONCAT('
    SELECT `user_order`.`external_id` AS `user_order__external_id`,
           `user_order`.`uuid` AS `user_order__uuid`,
           `transaction`.`amount` AS `transaction__amount`,
           `dict_currency`.`iso4217` AS `dict_currency__iso4217`,
           `user_order`.`order_status` AS `user_order__order_status`,
           `user_order`.`status` AS `user_order__status`,
           `user_order`.`created` AS `user_order__created`,
           `user_order`.`modified` AS `user_order__modified`
           FROM `user_order`
               LEFT JOIN `user`
                   ON `user`.`id` = `user_order`.`user_id`
               INNER JOIN `transaction`
                    ON `transaction`.`user_order_id` = `user_order`.`id`
               INNER JOIN `dict_currency`
                    ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
    WHERE `user_order`.`created` BETWEEN ? AND ?',
                          IF(IFNULL(JSON_LENGTH(__user_order__external_id), 0) = 0, '',
                             CONCAT(' AND `user_order`.`external_id` IN (',
                                    TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __user_order__external_id)), ')')),
                          IF(IFNULL(JSON_LENGTH(__user__email), 0) = 0, '',
                             CONCAT(' AND `user`.`email` IN (',
                                    TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __user__email)), ')')),
                          IF(IFNULL(JSON_LENGTH(__user_order__status), 0) = 0, '',
                             CONCAT(' AND `user_order`.`status` IN (',
                                    TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __user_order__status)), ')')),
                          IF(IFNULL(JSON_LENGTH(__user_order__order_status), 0) = 0, '',
                             CONCAT(' AND `user_order`.`order_status` IN (',
                                    TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __user_order__order_status)), ')')),
                          ' ORDER BY `user_order`.`created` DESC;'
        );

    SET @__date_from = _date_from;
    SET @__date_to = _data_to;

    PREPARE `stmt` FROM @__query;
    EXECUTE `stmt` USING @__date_from, @__date_to;

END */$$
DELIMITER ;
