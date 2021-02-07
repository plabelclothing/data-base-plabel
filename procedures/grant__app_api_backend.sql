/*!50003 DROP PROCEDURE IF EXISTS `grant__app_api_backend` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `plabel`@`localhost` PROCEDURE `grant__app_api_backend`()
    MODIFIES SQL DATA
BEGIN

    GRANT EXECUTE ON FUNCTION `uuid_v4` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__product__get_by_uuid` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__products__get` TO 'internal'@'localhost';

    GRANT EXECUTE ON FUNCTION `uuid_v4` TO 'app_api_backend'@'';
    GRANT EXECUTE ON PROCEDURE `app_backend__product__get_by_uuid` TO 'app_api_backend'@'';
    GRANT EXECUTE ON PROCEDURE `app_backend__products__get` TO 'app_api_backend'@'';

END */$$

DELIMITER ;
