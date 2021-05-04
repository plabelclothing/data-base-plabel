/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_details__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_details__get`(IN user__uuid CHAR(36)
)
BEGIN

    SELECT `user_details`.`first_name`         AS `user_details__first_name`,
           `user_details`.`last_name`          AS `user_details__last_name`,
           `user_details`.`street`             AS `user_details__street`,
           `user_details`.`building_apt_suite` AS `user_details__building_apt_suite`,
           `user_details`.`zip`                AS `user_details__zip`,
           `user_details`.`city`               AS `user_details__city`,
           `dict_country`.`iso`                AS `dict_country__iso`,
           `user_details`.`phone`              AS `user_details__phone`,
           `user`.`email`                      AS `user__email`
    FROM `user`
             INNER JOIN `user_details`
                        ON `user_details`.`user_id` = `user`.`id`
             LEFT JOIN `dict_country`
                       ON `dict_country`.`id` = `user_details`.`dict_country_id`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;
