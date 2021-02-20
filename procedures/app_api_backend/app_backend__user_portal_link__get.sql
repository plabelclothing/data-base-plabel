/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_portal_link__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_portal_link__get`(IN user_portal_link__uuid CHAR(36),
                                                                                    IN user_portal_link__type ENUM ('registration','recovery','remember'),
                                                                                    IN user_portal_link__active_to INT(10) UNSIGNED)
BEGIN

    SELECT `user_portal_link`.`uuid` AS `user_portal_link__uuid`,
           `user_portal_link`.`type` AS `user_portal_link__type`
    FROM `user_portal_link`
    WHERE `user_portal_link`.`uuid` = user_portal_link__uuid
      AND `user_portal_link`.`type` = user_portal_link__type
      AND `user_portal_link`.`active_to` > user_portal_link__active_to
      AND `user_portal_link`.`is_active` = 1;

END */$$
DELIMITER ;
