/*!50003 DROP PROCEDURE IF EXISTS `grant__internal` */;

DELIMITER $$

/*!50003
CREATE
	DEFINER = `root`@`localhost` PROCEDURE `grant__internal`()
	MODIFIES SQL DATA
BEGIN
	GRANT INSERT, SELECT, UPDATE ON * TO 'internal'@'localhost';

	GRANT EXECUTE ON FUNCTION `uuid_v4` TO 'internal'@'localhost';
END */$$
DELIMITER ;
