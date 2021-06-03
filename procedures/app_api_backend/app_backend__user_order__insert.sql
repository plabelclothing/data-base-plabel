/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_order__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_order__insert`(IN user_order__uuid CHAR(36),
                                                                                 IN user_cart__uuid CHAR(36),
                                                                                 IN user__uuid CHAR(36),
                                                                                 IN user_cart__additional_information JSON,
                                                                                 IN user_cart__address JSON,
                                                                                 IN user_cart__tracking_number VARCHAR(255))
BEGIN

    DECLARE `_user__id` INT(10) UNSIGNED;
    DECLARE `_user_cart__id` INT(10) UNSIGNED;

    IF (user__uuid IS NOT NULL)
    THEN

        SELECT `user`.`id`
        INTO _user__id
        FROM `user`
        WHERE `user`.`uuid` = user__uuid;

        IF `_user__id` IS NULL
        THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user id', MYSQL_ERRNO = 1000;
        END IF;

    END IF;

    SELECT `user_cart`.`id`
    INTO _user_cart__id
    FROM `user_cart`
    WHERE `user_cart`.`uuid` = user_cart__uuid;

    IF `_user_cart__id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user cart id', MYSQL_ERRNO = 1001;
    END IF;

    INSERT
    INTO `user_order`
    (`uuid`, `external_id`, `user_cart_id`, `user_id`, `status`, `additional_information`, `address`, `tracking_number`,
     `created`,
     `modified`)
    VALUES (user_order__uuid,
            `random_string`(20, '{"underscore": false,"upper":false}'),
            _user_cart__id,
            _user__id,
            'new',
            user_cart__additional_information,
            user_cart__address,
            user_cart__tracking_number,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;
