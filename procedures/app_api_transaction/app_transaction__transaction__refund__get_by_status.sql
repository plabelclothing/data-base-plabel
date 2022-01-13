/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__refund__get_by_status` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__refund__get_by_status`(IN _transaction__status ENUM ('pending','settled','canceled','error', 'new'),
                                                                                                     IN _transaction__type ENUM ('sale', 'refund'),
                                                                                                     IN _payment_method__code VARCHAR(255))
BEGIN

    SET @__query = 'SELECT
                           `transaction`.`uuid` AS `transaction__uuid`,
                           `transaction`.`external_id` AS `transaction__external_id`
    FROM `transaction`
             INNER JOIN `payment_method`
                        ON `payment_method`.`id` = `transaction`.`payment_method_id`
    WHERE `transaction`.`status` = ?
        AND `transaction`.`type` = ?';

    IF (_payment_method__code IS NOT NULL)
    THEN
        SET @__query = CONCAT(@__query, '
        AND `payment_method`.`code` = "', _payment_method__code, '"');
    END IF;

    SET @__query = CONCAT(@__query, ';');

    SET @__transaction__status = _transaction__status;
    SET @__transaction__type = _transaction__type;

    PREPARE `stmt` FROM @__query;
    EXECUTE `stmt` USING @__transaction__status, @__transaction__type;

END */$$
DELIMITER ;
