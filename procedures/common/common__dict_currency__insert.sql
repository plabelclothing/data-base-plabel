/*!50003 DROP PROCEDURE IF EXISTS `common__dict_currency__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `common__dict_currency__insert`()
BEGIN

    DECLARE __iteration INT(10) UNSIGNED DEFAULT 0;
    DECLARE __oneCurrency JSON;
    DECLARE __data JSON;
    SET __data = '[
      {
        "iso4217": "USD",
        "symbol": "$",
        "name": "US Dollar"
      },
      {
        "iso4217": "EUR",
        "symbol": "€",
        "name": "Euro"
      },
      {
        "iso4217": "RUB",
        "symbol": "₽",
        "name": "Russian ruble"
      }
    ]';
    WHILE __iteration < JSON_LENGTH(__data)
        DO

            SELECT JSON_EXTRACT(__data, CONCAT('$[', __iteration, ']'))
            INTO __oneCurrency;

            INSERT INTO `dict_currency`
                (`iso4217`, `symbol`, `name`, `created`, `modified`)
            VALUES (JSON_UNQUOTE(JSON_EXTRACT(__oneCurrency, '$.iso4217')),
                    JSON_UNQUOTE(JSON_EXTRACT(__oneCurrency, '$.symbol')),
                    JSON_UNQUOTE(JSON_EXTRACT(__oneCurrency, '$.name')),
                    UNIX_TIMESTAMP(),
                    UNIX_TIMESTAMP());

            SET __iteration = __iteration + 1;
            SET __oneCurrency = NULL;

        END WHILE;

END */$$
DELIMITER ;
