/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction_log__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction_log__insert`(IN _transaction__uuid CHAR(36),
                                                                                          IN _transaction_log__data JSON)
BEGIN

    INSERT
    INTO `transaction_log`
        (`uuid`, `transaction_id`, `data`, `created`, `modified`)
    SELECT `uuid_v4`(),
           `transaction`.`id`,
           _transaction_log__data,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `transaction`
    WHERE `transaction`.`uuid` = _transaction__uuid;

END */$$
DELIMITER ;
