/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_order__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_order__insert`(IN user_order__uuid CHAR(36),
                                                                                 IN user_cart__uuid CHAR(36),
                                                                                 IN user__uuid CHAR(36),
                                                                                 IN user_cart__additional_information JSON,
                                                                                 IN user_cart__another_address JSON,
                                                                                 IN user_cart__tracking_number VARCHAR(255))
BEGIN

    INSERT
    INTO `user_cart`
    (`uuid`, `user_cart_id`, `user_id`, `additional_information`, `another_address`, `tracking_number`, `created`,
     `modified`)
    SELECT user_order__uuid,
           user_cart__uuid,
           `user`.`id`,
           user_cart__additional_information,
           user_cart__another_address,
           user_cart__tracking_number,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;
