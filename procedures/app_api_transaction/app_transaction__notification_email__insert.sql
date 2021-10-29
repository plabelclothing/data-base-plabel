/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__notification_email__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__notification_email__insert`(IN _notification_email__uuid CHAR(36),
                                                                                             IN _user__uuid CHAR(36),
                                                                                             IN _notification_email__to VARCHAR(155),
                                                                                             IN _notification_email__template VARCHAR(155),
                                                                                             IN _notification_email__status ENUM ('new','pending','sent','error'),
                                                                                             IN _notification_email__body JSON)
BEGIN

    DECLARE `_user__id` INT(10) UNSIGNED;

    SELECT `user`.`id`
    INTO `_user__id`
    FROM `user`
    WHERE `user`.`uuid` = _user__uuid;

    INSERT
    INTO `notification_email`
    (`user_id`, `uuid`, `to`, `template`, `status`, `body`, `created`, `modified`)
    VALUES (_user__id,
            _notification_email__uuid,
            _notification_email__to,
            _notification_email__template,
            _notification_email__status,
            _notification_email__body,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;
