/*!50003 DROP PROCEDURE IF EXISTS `grant__app_api_backend` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `root`@`localhost` PROCEDURE `grant__app_api_backend`()
    MODIFIES SQL DATA
BEGIN

    GRANT EXECUTE ON FUNCTION `random_string` TO 'internal'@'localhost';
    GRANT EXECUTE ON FUNCTION `uuid_v4` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__dict_country__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__notification_email__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__notification_email__update` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__notification_ipn__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__payment_method_auth__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__product__cart_get_by_uuid` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__product__get_by_uuid` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__products__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction__get_by_external_id` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction__get_by_uuid` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction__update` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction_log__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__check_exist` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__check_exist_by_email` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__signin` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__update` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_cart__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_cart_items__get_by_uuid` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_details__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_details__update` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_order__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_order__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_order__update` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_portal_link__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_portal_link__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_portal_link__update` TO 'internal'@'localhost';

    GRANT EXECUTE ON PROCEDURE `app_backend__dict_country__get` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__notification_email__insert` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__notification_email__update` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__notification_ipn__insert` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__payment_method_auth__get` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__product__cart_get_by_uuid` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__product__get_by_uuid` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__products__get` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction__get_by_external_id` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction__get_by_uuid` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction__insert` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction__update` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__transaction_log__insert` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__check_exist` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__check_exist_by_email` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__insert` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__signin` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user__update` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_cart__insert` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_cart_items__get_by_uuid` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_details__get` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_details__update` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_order__get` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_order__insert` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_order__update` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_portal_link__get` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_portal_link__insert` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__user_portal_link__update` TO 'app_api_backend'@'localhost';

END */$$

DELIMITER ;
