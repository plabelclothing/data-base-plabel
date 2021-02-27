/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__signin` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__signin`(IN user__email CHAR(36),
                                                                           IN user__password VARCHAR(128))
BEGIN

    SELECT `user`.`uuid`  AS `user__uuid`,
           `user`.`email` AS `user__email`
    FROM `user`
    WHERE `user`.`email` = user__email
      AND `user`.`is_active` = 1
      AND `user`.`password` = user__password;

END */$$
DELIMITER ;
