/*!50003 DROP PROCEDURE IF EXISTS `app_transaction__transaction__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_transaction__transaction__insert`(IN _transaction__uuid CHAR(36),
                                                                                      IN _user_order__uuid CHAR(36),
                                                                                      IN _payment_method__code VARCHAR(255),
                                                                                      IN _dict_currency__iso4217 CHAR(3),
                                                                                      IN _transaction__amount INT(10) UNSIGNED,
                                                                                      IN _transaction__status ENUM ('pending','settled','canceled','error', 'new'),
                                                                                      IN _transaction_customer__locale CHAR(3),
                                                                                      IN _dict_country__iso CHAR(3))
BEGIN

    DECLARE __user_order__id INT(10) UNSIGNED;
    DECLARE __payment_method__id INT(10) UNSIGNED;
    DECLARE __dict_currency__id INT(10) UNSIGNED;
    DECLARE __dict_country__id INT(10) UNSIGNED;
    DECLARE __transaction__id INT(10) UNSIGNED;

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
    INTO __user_order__id
    FROM `user_order`
    WHERE `user_order`.`uuid` = _user_order__uuid;

    IF __user_order__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user order id', MYSQL_ERRNO = 1000;
    END IF;

    SELECT `payment_method`.`id`
    INTO __payment_method__id
    FROM `payment_method`
    WHERE `payment_method`.`code` = _payment_method__code;

    IF __payment_method__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No payment method id', MYSQL_ERRNO = 1001;
    END IF;

    SELECT `dict_currency`.`id`
    INTO __dict_currency__id
    FROM `dict_currency`
    WHERE `dict_currency`.`iso4217` = _dict_currency__iso4217;

    IF __dict_currency__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No dict currency id', MYSQL_ERRNO = 1002;
    END IF;

    SELECT `dict_country`.`id`
    INTO __dict_country__id
    FROM `dict_country`
    WHERE `dict_country`.`iso` = _dict_country__iso;

    IF __dict_country__id IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No dict country id', MYSQL_ERRNO = 1002;
    END IF;

    INSERT
    INTO `transaction`
    (`uuid`, `user_order_id`, `payment_method_id`, `dict_currency_id`, `amount`, `status`, `created`, `modified`)
    VALUES (_transaction__uuid,
            __user_order__id,
            __payment_method__id,
            __dict_currency__id,
            _transaction__amount,
            _transaction__status,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

    SELECT LAST_INSERT_ID()
    INTO __transaction__id;

    INSERT
    INTO `transaction_customer`
        (`transaction_id`, `dict_country_id`, `locale`, `modified`, `created`)
    VALUES (__transaction__id,
            __dict_country__id,
            _transaction_customer__locale,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());
    COMMIT;

END */$$
DELIMITER ;
