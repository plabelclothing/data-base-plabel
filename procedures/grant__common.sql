/*!50003 DROP PROCEDURE IF EXISTS `grant__common` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `plabel`@`localhost` PROCEDURE `grant__common`()
    MODIFIES SQL DATA
BEGIN
    GRANT EXECUTE ON PROCEDURE `common__country__insert` TO 'internal'@'localhost';
    GRANT EXECUTE ON PROCEDURE `common__dict_currency__insert` TO 'internal'@'localhost';
END */$$
DELIMITER ;
