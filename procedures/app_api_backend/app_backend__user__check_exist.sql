/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__check_exist` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__check_exist`(IN user__email CHAR(255)
)
BEGIN

    SELECT `user`.`uuid` AS `user__uuid`
    FROM `user`
    WHERE `user`.`email` = user__email;

END */$$
DELIMITER ;
