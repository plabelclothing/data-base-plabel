/*!50003 DROP PROCEDURE IF EXISTS `grant__internal` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `plabel`@`localhost` PROCEDURE `grant__internal`()
    MODIFIES SQL DATA
BEGIN
    GRANT Alter, Create, Delete, Execute, Insert, Select, Show Databases, Update ON *.* TO `internal`@`localhost`;

    GRANT EXECUTE ON FUNCTION `uuid_v4` TO 'internal'@'localhost';
END */$$

DELIMITER ;
