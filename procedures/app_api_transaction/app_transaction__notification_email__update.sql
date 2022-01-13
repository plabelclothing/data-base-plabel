/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__notification_email__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__notification_email__update`(IN _notification_email__uuid CHAR(36),
                                                                                             IN _notification_email__status ENUM ('new','pending','sent','error'))
BEGIN

    UPDATE `notification_email`
    SET `notification_email`.`status`   = _notification_email__status,
        `notification_email`.`modified` = UNIX_TIMESTAMP()
    WHERE `notification_email`.`uuid` = _notification_email__uuid;

END */$$
DELIMITER ;
