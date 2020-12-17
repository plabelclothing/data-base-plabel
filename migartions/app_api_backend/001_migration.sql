# 001_migration

SET GLOBAL log_bin_trust_function_creators = 1;

CREATE TABLE `dict_currency`
(
    `id`        int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `iso4217`   char(3)          NOT NULL,
    `symbol`    char(3)          NOT NULL,
    `name`      varchar(30)      NOT NULL,
    `is_active` tinyint(1)       NOT NULL DEFAULT 1,
    `created`   int(10) UNSIGNED NOT NULL,
    `modified`  int(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `dict_part_of_world`
(
    `id`       int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `code`     varchar(255)     NOT NULL,
    `created`  int(10) UNSIGNED NOT NULL,
    `modified` int(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `dict_country`
(
    `id`                    int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `dict_currency_id`      int(10) UNSIGNED NOT NULL,
    `dict_part_of_world_id` int(10) UNSIGNED NOT NULL,
    `is_active`             tinyint(1)       NOT NULL DEFAULT 1,
    `name`                  varchar(255)     NOT NULL,
    `iso`                   char(3)          NOT NULL,
    `nativeName`            varchar(255)     NOT NULL,
    `created`               int(10) UNSIGNED NOT NULL,
    `modified`              int(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`dict_part_of_world_id`) REFERENCES `dict_part_of_world` (`id`),
    FOREIGN KEY (`dict_currency_id`) REFERENCES `dict_currency` (`id`)
);

CREATE TABLE `migrations`
(
    `id`       int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`     char(36)         NOT NULL,
    `name`     varchar(255)     NOT NULL,
    `created`  int(10) UNSIGNED NOT NULL,
    `modified` int(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

# region insert functions
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
# end region insert functions

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `created`, `modified`)
VALUES ('001_migration',
        `uuid_v4`(),
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
