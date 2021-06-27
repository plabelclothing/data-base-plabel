/*!50003 DROP PROCEDURE IF EXISTS `app_backend__currency_exchange_rate__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__currency_exchange_rate__insert`(IN _data JSON)
BEGIN

    DECLARE __iteration INT(10) DEFAULT 0;
    DECLARE __currency_exchange_rate__data JSON;

    WHILE __iteration < JSON_LENGTH(_data)
        DO

            SET __currency_exchange_rate__data = JSON_UNQUOTE(JSON_EXTRACT(_data, CONCAT('$[', __iteration, ']')));

            INSERT
            INTO `currency_exchange_rate`
                (`dict_currency_id`, `value`, `created`, `modified`)
            SELECT `dict_currency`.`id`,
                   JSON_UNQUOTE(JSON_EXTRACT(__currency_exchange_rate__data, '$.value')),
                   UNIX_TIMESTAMP(),
                   UNIX_TIMESTAMP()
            FROM `dict_currency`
            WHERE `dict_currency`.`iso4217` =
                  JSON_UNQUOTE(JSON_EXTRACT(__currency_exchange_rate__data, '$.dict_currency__iso4217'))
            ON DUPLICATE KEY UPDATE `currency_exchange_rate`.`value`    = JSON_UNQUOTE(
                    JSON_EXTRACT(__currency_exchange_rate__data, '$.value')),
                                    `currency_exchange_rate`.`modified` = UNIX_TIMESTAMP();

            SET __currency_exchange_rate__data = NULL;
            SET __iteration = __iteration + 1;
        END WHILE;

END */$$
DELIMITER ;
