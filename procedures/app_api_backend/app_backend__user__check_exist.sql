/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__check_exist` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__check_exist`(IN user__uuid CHAR(36)
)
BEGIN

    SELECT `user`.`email`    AS `user__email`,
           `user`.`password` AS `user__password`
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;
