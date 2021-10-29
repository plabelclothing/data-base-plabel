/*!50003 DROP PROCEDURE IF EXISTS `grant__app_api_transaction` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `root`@`localhost` PROCEDURE `grant__app_api_transaction`()
    MODIFIES SQL DATA
BEGIN

    GRANT EXECUTE ON FUNCTION `random_string` TO 'internal'@'localhost';
    GRANT EXECUTE ON FUNCTION `uuid_v4` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__notification_email__update` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__notification_email__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__notification_ipn__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__payment_method_auth__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__transaction__get_by_external_id` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__transaction__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__transaction__update` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__transaction_log__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__user_order__get_email_send` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__user_order__update` TO 'internal'@'localhost';

    GRANT EXECUTE ON PROCEDURE `app_transaction__notification_email__update` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__notification_email__insert` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__notification_ipn__insert` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__payment_method_auth__get` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__transaction__get_by_external_id` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__transaction__insert` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__transaction__update` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__transaction_log__insert` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__user_order__get_email_send` TO 'app_api_transaction'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_transaction__user_order__update` TO 'app_api_transaction'@'localhost';

END */$$

DELIMITER ;
