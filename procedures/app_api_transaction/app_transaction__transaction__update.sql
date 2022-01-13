/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__update`(IN _transaction__uuid CHAR(36),
                                                                                      IN _transaction__external_id VARCHAR(255),
                                                                                      IN _transaction__status ENUM ('new','pending','settled','canceled','error'),
                                                                                      IN _transaction__settled_at INT(10) UNSIGNED,
                                                                                      IN _transaction__capture_id VARCHAR(255))
BEGIN

    UPDATE `transaction`
    SET `transaction`.`external_id` = IFNULL(_transaction__external_id, `transaction`.`external_id`),
        `transaction`.`status`      = IFNULL(_transaction__status, `transaction`.`status`),
        `transaction`.`settled_at`  = IFNULL(_transaction__settled_at, `transaction`.`settled_at`),
        `transaction`.`capture_id`  = IFNULL(_transaction__capture_id, `transaction`.`capture_id`),
        `transaction`.`modified`    = UNIX_TIMESTAMP()
    WHERE `transaction`.`uuid` = _transaction__uuid;

END */$$
DELIMITER ;
