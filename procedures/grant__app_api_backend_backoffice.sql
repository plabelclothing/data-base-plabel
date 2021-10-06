/*!50003 DROP PROCEDURE IF EXISTS `grant__app_api_backend_backoffice` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `root`@`localhost` PROCEDURE `grant__app_api_backend_backoffice`()
    MODIFIES SQL DATA
BEGIN

    GRANT EXECUTE ON FUNCTION `random_string` TO 'internal'@'localhost';
    GRANT EXECUTE ON FUNCTION `uuid_v4` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_backoffice__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_backoffice__check_exist` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_backoffice__signin` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_backoffice__signup` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_order__get` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_order__get_by_uuid` TO 'internal'@'localhost';

    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_backoffice__get` TO 'app_api_backend_backoffice'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_backoffice__check_exist` TO 'app_api_backend_backoffice'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_backoffice__signin` TO 'app_api_backend_backoffice'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_backoffice__signup` TO 'app_api_backend_backoffice'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_order__get` TO 'app_api_backend_backoffice'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend_backoffice__user_order__get_by_uuid` TO 'app_api_backend_backoffice'@'localhost';

END */$$

DELIMITER ;
