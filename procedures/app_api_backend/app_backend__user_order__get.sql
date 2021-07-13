/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_order__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_order__get`(IN _user__uuid CHAR(36),
                                                                              IN _user_order__id INT(10) UNSIGNED,
                                                                              IN _is_prev TINYINT(1) UNSIGNED,
                                                                              IN _limit INT(10) UNSIGNED)
BEGIN

    DECLARE `__user_order__id_max` INT(10) UNSIGNED;
    DECLARE `__user_order__id_min` INT(10) UNSIGNED;

    SELECT `user_order`.`id`
    INTO `__user_order__id_max`
    FROM `user_order`
             INNER JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
    WHERE `user`.`uuid` = _user__uuid
      AND `user_order`.`status` <> "canceled"
    ORDER BY `user_order`.`created` DESC
    LIMIT 1;

    SELECT `user_order`.`id`
    INTO `__user_order__id_min`
    FROM `user_order`
             INNER JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
    WHERE `user`.`uuid` = _user__uuid
      AND `user_order`.`status` <> "canceled"
    ORDER BY `user_order`.`created`
    LIMIT 1;

    SET @__query = '
SELECT     `user_order`.`uuid`                                AS `user_order__uuid`,
           `user_order`.`id`                                  AS `user_order__id`,
           `user_order`.`external_id`                         AS `user_order__external_id`,
           `user_order`.`order_status`                        AS `user_order__order_status`,
           `user_order`.`created`                             AS `user_order__created`,
           `transaction`.`amount`                             AS `transaction__amount`,
           `dict_currency`.`iso4217`                          AS `dict_currency__iso4217`,
           `dict_currency`.`symbol`                           AS `dict_currency__symbol`,
           UPPER(SUBSTRING(`user_order`.`external_id`, 1, 2)) AS `icon__text`,
            ?                                                 AS `user_order__id_max`,
            ?                                                 AS `user_order__id_min`
    FROM `user_order`
             INNER JOIN `transaction`
                        ON `transaction`.`user_order_id` = `user_order`.`id`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `transaction`.`dict_currency_id`
             INNER JOIN `user`
                        ON `user`.`id` = `user_order`.`user_id`
    WHERE `user`.`uuid` = ?
          AND `user_order`.`status` <> "canceled"';

    IF (_is_prev = 0 AND _user_order__id IS NOT NULL)
    THEN
        SET @__query = CONCAT(@__query, ' AND  `user_order`.`id` < ?');
    END IF;

    IF (_is_prev = 1 AND _user_order__id IS NOT NULL)
    THEN
        SET @__query = CONCAT(@__query, ' AND  `user_order`.`id` > ?');
    END IF;

    SET @__query = CONCAT(@__query, ' ORDER BY `user_order`.`created` ', IF(_is_prev = 0, 'DESC', 'ASC'));
    SET @__query = CONCAT(@__query, ' LIMIT ?;');

    SET @__user__uuid = _user__uuid;
    SET @__user_order__id = _user_order__id;
    SET @__limit = _limit;
    SET @__user_order__id_max = __user_order__id_max;
    SET @__user_order__id_min = __user_order__id_min;

    PREPARE `stmt` FROM @__query;

    IF (_user_order__id IS NOT NULL)
    THEN
        EXECUTE `stmt` USING @__user_order__id_max, @__user_order__id_min, @__user__uuid, @__user_order__id, @__limit;
    ELSE
        EXECUTE `stmt` USING @__user_order__id_max, @__user_order__id_min, @__user__uuid, @__limit;
    END IF;

END */$$
DELIMITER ;
