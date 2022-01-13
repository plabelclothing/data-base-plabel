/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_backoffice__check_exist` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_backoffice__check_exist`(IN `_user_backoffice__email` CHAR(255))
BEGIN

    SELECT `user_backoffice`.`uuid` AS `user_backoffice__uuid`
    FROM `user_backoffice`
    WHERE `user_backoffice`.`email` = `_user_backoffice__email`;

END */$$
DELIMITER ;
