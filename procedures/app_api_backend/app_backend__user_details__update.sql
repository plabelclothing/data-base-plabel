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
    SET `user_details`.`first_name`      = IFNULL(user_details__firstname, `user_details`.`first_name`),
        `user_details`.`last_name`       = IFNULL(user_details__lastname, `user_details`.`last_name`),
        `user_details`.`birthday`        = IFNULL(user_details__birthday, `user_details`.`birthday`),
        `user_details`.`phone`           = IFNULL(user_details__phone, `user_details`.`phone`),
        `user_details`.`street`          = IFNULL(user_details__street, `user_details`.`street`),
        `user_details`.`zip`             = IFNULL(user_details__zip, `user_details`.`zip`),
        `user_details`.`city`            = IFNULL(user_details__city, `user_details`.`city`),
        `user_details`.`dict_country_id` = IFNULL(_dict_country__id, `user_details`.`dict_country_id`),
        `user_details`.`modified`        = UNIX_TIMESTAMP()
    WHERE `user`.`uuid` = user__uuid;


END */$$
DELIMITER ;
