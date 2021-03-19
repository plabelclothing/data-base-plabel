/*!50003 DROP PROCEDURE IF EXISTS `app_backend__payment_method_auth__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__payment_method_auth__get`(
    IN _payment_method_code VARCHAR(255))
BEGIN

    SELECT `payment_method_auth`.`data` AS `payment_method_auth__data`
    FROM `payment_method_auth`
             INNER JOIN `payment_method`
                        ON `payment_method`.`id` = `payment_method_auth`.`payment_method_id`
    WHERE `payment_method`.`code` = _payment_method_code;

END */$$
DELIMITER ;
