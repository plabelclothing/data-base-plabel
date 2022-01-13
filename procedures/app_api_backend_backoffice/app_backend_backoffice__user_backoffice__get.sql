/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_backoffice__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_backoffice__get`(IN `_user_backoffice__uuid` CHAR(36))
BEGIN

    SELECT `user_backoffice`.`email` AS `user_backoffice__email`
    FROM `user_backoffice`
    WHERE `user_backoffice`.`uuid` = `_user_backoffice__uuid`;

END */$$
DELIMITER ;
