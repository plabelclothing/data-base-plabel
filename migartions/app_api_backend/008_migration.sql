# 008_migration

ALTER TABLE `user_details`
    ADD COLUMN `building_apt_suite` VARCHAR(200) NULL AFTER `street`;


# region procedures

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__dict_country__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__dict_country__get`()
BEGIN

    SELECT `dict_country`.`name`       AS `name`,
           `dict_country`.`nativeName` AS `nativeName`,
           `dict_currency`.`iso4217`   AS `currencies`,
           `dict_part_of_world`.`code` AS `partOfWorld`,
           `dict_country`.`iso`        AS `iso`
    FROM `dict_country`
             INNER JOIN `dict_currency`
                        ON `dict_currency`.`id` = `dict_country`.`dict_currency_id`
             INNER JOIN `dict_part_of_world`
                        ON `dict_part_of_world`.`id` = `dict_country`.`dict_part_of_world_id`
    WHERE `dict_country`.`is_active` = 1;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_details__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_details__update`(IN user__uuid CHAR(36),
                                                                                   IN user_details__firstname VARCHAR(64),
                                                                                   IN user_details__lastname VARCHAR(64),
                                                                                   IN user_details__birthday DATE,
                                                                                   IN user_details__phone VARCHAR(64),
                                                                                   IN user_details__street VARCHAR(200),
                                                                                   IN user_details__building_apt_suite VARCHAR(200),
                                                                                   IN user_details__zip VARCHAR(30),
                                                                                   IN user_details__city VARCHAR(100),
                                                                                   IN dict_country__iso CHAR(3))
BEGIN

    DECLARE `_dict_country__id` INT(10) UNSIGNED;

    IF (dict_country__iso IS NOT NULL)
    THEN
        SELECT `dict_country`.`id`
        INTO `_dict_country__id`
        FROM `dict_country`
        WHERE `dict_country`.`iso` = dict_country__iso;

        IF `_dict_country__id` IS NULL
        THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No dict country id', MYSQL_ERRNO = 1000;
        END IF;

    END IF;

    UPDATE `user_details`
        INNER JOIN `user`
        ON `user`.`id` = `user_details`.`user_id`
    SET `user_details`.`first_name`         = IFNULL(user_details__firstname, `user_details`.`first_name`),
        `user_details`.`last_name`          = IFNULL(user_details__lastname, `user_details`.`last_name`),
        `user_details`.`birthday`           = IFNULL(user_details__birthday, `user_details`.`birthday`),
        `user_details`.`phone`              = IFNULL(user_details__phone, `user_details`.`phone`),
        `user_details`.`street`             = IFNULL(user_details__street, `user_details`.`street`),
        `user_details`.`building_apt_suite` = IFNULL(user_details__building_apt_suite,
                                                     `user_details`.`building_apt_suite`),
        `user_details`.`zip`                = IFNULL(user_details__zip, `user_details`.`zip`),
        `user_details`.`city`               = IFNULL(user_details__city, `user_details`.`city`),
        `user_details`.`dict_country_id`    = IFNULL(_dict_country__id, `user_details`.`dict_country_id`),
        `user_details`.`modified`           = UNIX_TIMESTAMP()
    WHERE `user`.`uuid` = user__uuid;


END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_details__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_details__get`(IN user__uuid CHAR(36)
)
BEGIN

    SELECT `user_details`.`first_name`         AS `user_details__first_name`,
           `user_details`.`last_name`          AS `user_details__last_name`,
           `user_details`.`street`             AS `user_details__street`,
           `user_details`.`building_apt_suite` AS `user_details__building_apt_suite`,
           `user_details`.`zip`                AS `user_details__zip`,
           `user_details`.`city`               AS `user_details__city`,
           `dict_country`.`iso`                AS `dict_country__iso`,
           `user_details`.`phone`              AS `user_details__phone`,
           `user`.`email`                      AS `user__email`
    FROM `user`
             INNER JOIN `user_details`
                        ON `user_details`.`user_id` = `user`.`id`
             LEFT JOIN `dict_country`
                       ON `dict_country`.`id` = `user_details`.`dict_country_id`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;


# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `created`, `modified`)
VALUES ('008_migration',
        `uuid_v4`(),
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
