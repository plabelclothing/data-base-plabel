/*!50003 DROP PROCEDURE IF EXISTS `app_backend__dict_country__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__dict_country__get`()
BEGIN

    SELECT `dict_country`.`name`       AS `name`,
           `dict_country`.`nativeName` AS `nativeName`,
           `dict_currency`.`iso4217`   AS `currencies`,
           `dict_part_of_world`.`code` AS `partOfWorld`,
           `dict_country`.`iso`        AS `iso`
    FROM `dict_country`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `dict_country`.`dict_currency_id`
             INNER JOIN `dict_part_of_world`
                        ON `dict_part_of_world`.`id` = `dict_country`.`dict_part_of_world_id`
    WHERE `dict_country`.`is_active` = 1;

END */$$
DELIMITER ;
