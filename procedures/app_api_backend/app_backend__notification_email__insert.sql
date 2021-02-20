/*!50003 DROP PROCEDURE IF EXISTS `app_backend__notification_email__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__notification_email__insert`(IN notification_email__uuid CHAR(36),
                                                                                         IN user__uuid CHAR(36),
                                                                                         IN notification_email__template VARCHAR(155),
                                                                                         IN notification_email__status ENUM ('new','pending','sent','error'),
                                                                                         IN notification_email__body JSON)
BEGIN

    INSERT
    INTO `notification_email`
    (`user_id`, `uuid`, `template`, `status`, `body`, `created`, `modified`)
    SELECT `user`.`id`,
           notification_email__uuid,
           notification_email__template,
           notification_email__status,
           notification_email__body,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;
