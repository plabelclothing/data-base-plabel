/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_portal_link__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_portal_link__update`(IN user_portal_link__uuid CHAR(36),
                                                                                       IN user_portal_link__type ENUM ('registration','recovery','remember'))
BEGIN

    UPDATE `user_portal_link`
    SET `user_portal_link`.`is_active` = 0,
        `user_portal_link`.`modified`  = UNIX_TIMESTAMP()
    WHERE `user_portal_link`.`uuid` = user_portal_link__uuid
      AND `user_portal_link`.`type` = user_portal_link__type;

END */$$
DELIMITER ;
