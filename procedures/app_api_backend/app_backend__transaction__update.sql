/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction__update`(IN transaction__uuid CHAR(36),
                                                                                  IN transaction_external_id VARCHAR(255),
                                                                                  IN transaction__status ENUM ('new','pending','settled','canceled','error'),
                                                                                  IN transaction__settled_at INT(10) UNSIGNED)
BEGIN

    UPDATE `transaction`
    SET `transaction`.`external_id` = IFNULL(transaction_external_id, `transaction`.`external_id`),
        `transaction`.`status`      = IFNULL(transaction__status, `transaction`.`status`),
        `transaction`.`settled_at`  = IFNULL(transaction__settled_at, `transaction`.`settled_at`),
        `transaction`.`modified`    = UNIX_TIMESTAMP()
    WHERE `transaction`.`uuid` = transaction__uuid;

END */$$
DELIMITER ;
