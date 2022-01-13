/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_backoffice__signin` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_backoffice__signin`(IN `_user_backoffice__email` CHAR(255),
                                                                                                 IN `_user_backoffice__password` VARCHAR(128))
BEGIN

    SELECT `user_backoffice`.`uuid`  AS `user_backoffice__uuid`,
           `user_backoffice`.`email` AS `user_backoffice__email`
    FROM `user_backoffice`
    WHERE `user_backoffice`.`email` = `_user_backoffice__email`
      AND `user_backoffice`.`is_active` = 1
      AND `user_backoffice`.`password` = _user_backoffice__password;

END */$$
DELIMITER ;
