/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__notification_ipn__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__notification_ipn__insert`(IN _transaction__uuid CHAR(36),
                                                                                           IN _notification_ipn__data JSON)
BEGIN

    DECLARE `_transaction_id` INT(10) UNSIGNED;

    IF (_transaction__uuid IS NOT NULL)
    THEN
        SELECT `transaction`.`id`
        INTO `_transaction_id`
        FROM `transaction`
        WHERE `transaction`.`uuid` = _transaction__uuid;
    END IF;

    INSERT
    INTO `notification_ipn`
        (`uuid`, `transaction_id`, `data`, `created`, `modified`)
    VALUES (`uuid_v4`(),
            _transaction_id,
            _notification_ipn__data,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;
