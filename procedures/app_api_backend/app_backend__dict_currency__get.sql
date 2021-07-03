/*!50003 DROP PROCEDURE IF EXISTS `app_backend__dict_currency__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__dict_currency__get`()
BEGIN

    SELECT `dict_currency`.`iso4217` AS `dict_currency__iso4217`
    FROM `dict_currency`
    WHERE `dict_currency`.`is_active` = 1;

END */$$
DELIMITER ;
