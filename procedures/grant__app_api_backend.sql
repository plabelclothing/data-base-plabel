/*!50003 DROP PROCEDURE IF EXISTS `grant__app_api_backend` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `root`@`localhost` PROCEDURE `grant__app_api_backend`()
    MODIFIES SQL DATA
BEGIN

    GRANT EXECUTE ON FUNCTION `uuid_v4` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__product__get_by_uuid` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__products__get` TO 'internal'@'localhost';

    GRANT EXECUTE ON PROCEDURE `app_backend__product__get_by_uuid` TO 'app_api_backend'@'localhost';
    GRANT EXECUTE ON PROCEDURE `app_backend__products__get` TO 'app_api_backend'@'localhost';

END */$$

DELIMITER ;
