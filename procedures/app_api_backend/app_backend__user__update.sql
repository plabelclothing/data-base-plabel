/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__update`(IN user__uuid CHAR(36),
                                                                           IN user__password VARCHAR(128),
                                                                           IN user__is_active TINYINT(1) UNSIGNED)
BEGIN

    UPDATE `user`
    SET `user`.`password`  = IFNULL(user__password, `user`.`password`),
        `user`.`is_active` = IFNULL(user__is_active, `user`.`is_active`),
        `user`.`modified`  = UNIX_TIMESTAMP()
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;
