/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__user_order__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__user_order__update`(IN _transaction__uuid CHAR(36),
                                                                                     IN _user_order__address JSON,
                                                                                     IN _status ENUM ('new','approved','canceled'),
                                                                                     IN _order_status ENUM ('new','pending','shipped', 'delivered'))
BEGIN

    UPDATE `user_order`
        INNER JOIN `transaction`
        ON `transaction`.`user_order_id` = `user_order`.`id`
    SET `user_order`.`status`       = IFNULL(_status, `user_order`.`status`),
        `user_order`.`order_status` = IFNULL(_order_status, `user_order`.`order_status`),
        `user_order`.`address`      = IFNULL(JSON_MERGE_PATCH(`user_order`.`address`, _user_order__address),
                                             `user_order`.`address`),
        `user_order`.`modified`     = UNIX_TIMESTAMP()
    WHERE `transaction`.`uuid` = _transaction__uuid;

END */$$
DELIMITER ;
