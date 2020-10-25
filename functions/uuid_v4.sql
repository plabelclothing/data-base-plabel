/*!50003 DROP FUNCTION IF EXISTS `uuid_v4` */;
DELIMITER $$

/*!50003 CREATE DEFINER =`internal`@`localhost` FUNCTION `uuid_v4`() RETURNS char(36) CHARSET utf8 COLLATE utf8_unicode_ci
	BEGIN
		DECLARE h1 CHAR(4);
		DECLARE h2 CHAR(4);
		DECLARE h3 CHAR(4);
		DECLARE h4 CHAR(4);
		DECLARE h5 CHAR(12);
		DECLARE h6 CHAR(4);
		DECLARE h7 CHAR(4);
		DECLARE h8 CHAR(4);

		-- Generate 8 2-byte strings that we will combine into a UUIDv4
		SET h1 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
		SET h2 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
		SET h3 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
		SET h6 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
		SET h7 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
		SET h8 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');

		-- 4th section will start with a 4 indicating the version
		SET h4 = CONCAT('4', LPAD(HEX(FLOOR(RAND() * 0x0fff)), 3, '0'));

		-- 5th section first half-byte can only be 8, 9 A or B
		SET h5 = CONCAT(HEX(FLOOR(RAND() * 4 + 8)),
		                LPAD(HEX(FLOOR(RAND() * 0x0fff)), 3, '0'));

		-- Build the complete UUID
		RETURN LOWER(CONCAT(
			             h1, h2, '-', h3, '-', h4, '-', h5, '-', h6, h7, h8
		             ));
	END */$$
DELIMITER ;