/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_portal_link__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_portal_link__insert`(IN user_portal_link__uuid CHAR(36),
                                                                                       IN user__uuid CHAR(36),
                                                                                       IN user_portal_link__type ENUM ('registration','recovery','remember'),
                                                                                       IN user_portal_link__active_to INT(10) UNSIGNED)
BEGIN

    INSERT
    INTO `user_portal_link`
        (`user_id`, `uuid`, `type`, `active_to`, `created`, `modified`)
    SELECT `user`.`id`,
           user_portal_link__uuid,
           user_portal_link__type,
           user_portal_link__active_to,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;
