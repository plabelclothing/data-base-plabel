/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction__get_by_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction__get_by_uuid`(IN transaction_uuid CHAR(36)
)
BEGIN

    SELECT `transaction`.`external_id` AS `transaction__external_id`
    FROM `transaction`
    WHERE `transaction`.`uuid` = transaction_uuid;

END */$$
DELIMITER ;
