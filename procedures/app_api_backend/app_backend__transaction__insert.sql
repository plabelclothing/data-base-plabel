/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction__insert`(IN transaction__uuid CHAR(36),
                                                                                  IN user_order__uuid CHAR(36),
                                                                                  IN payment_method__code VARCHAR(255),
                                                                                  IN dict_currency__iso4217 CHAR(3),
                                                                                  IN transaction__amount INT(10) UNSIGNED,
                                                                                  IN transaction__status ENUM ('pending','settled','canceled','error', 'new'))
BEGIN

    DECLARE `_user_order_id` INT(10) UNSIGNED;
    DECLARE `_payment_method_id` INT(10) UNSIGNED;
    DECLARE `_dict_currency_id` INT(10) UNSIGNED;

    # Error handlers
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;
    DECLARE EXIT HANDLER FOR SQLWARNING
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;

    SELECT `user_order`.`id`
    INTO `_user_order_id`
    FROM `user_order`
    WHERE `user_order`.`uuid` = user_order__uuid;

    IF `_user_order_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user order id', MYSQL_ERRNO = 1000;
    END IF;

    SELECT `payment_method`.`id`
    INTO `_payment_method_id`
    FROM `payment_method`
    WHERE `payment_method`.`code` = payment_method__code;

    IF `_payment_method_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No payment method id', MYSQL_ERRNO = 1001;
    END IF;

    SELECT `dict_currency`.`id`
    INTO `_dict_currency_id`
    FROM `dict_currency`
    WHERE `dict_currency`.`iso4217` = dict_currency__iso4217;

    IF `_dict_currency_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No dict currency id', MYSQL_ERRNO = 1002;
    END IF;

    INSERT
    INTO `transaction`
    (`uuid`, `user_order_id`, `payment_method_id`, `dict_currency_id`, `amount`, `status`, `created`, `modified`)
    VALUES (transaction__uuid,
            _user_order_id,
            _payment_method_id,
            _dict_currency_id,
            transaction__amount,
            transaction__status,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());
    COMMIT;

END */$$
DELIMITER ;
