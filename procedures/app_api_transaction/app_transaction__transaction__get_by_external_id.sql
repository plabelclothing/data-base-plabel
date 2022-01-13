/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__get_by_external_id` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__get_by_external_id`(IN transaction_external_id VARCHAR(255)
)
BEGIN

    SELECT `transaction`.`uuid` AS `transaction__uuid`
    FROM `transaction`
    WHERE `transaction`.`external_id` = transaction_external_id;

END */$$
DELIMITER ;
