/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction_log__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction_log__insert`(IN transaction__uuid CHAR(36),
                                                                                      IN transaction_log__data CHAR(36))
BEGIN

    INSERT
    INTO `transaction_log`
        (`uuid`, `transaction_id`, `data`, `created`, `modified`)
    SELECT `uuid_v4`(),
           `transaction`.`id`,
           transaction_log__data,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `transaction`
    WHERE `transaction`.`uuid` = transaction__uuid;

END */$$
DELIMITER ;
