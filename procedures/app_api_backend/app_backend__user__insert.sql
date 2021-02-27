/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__insert`(IN user__uuid CHAR(36),
                                                                           IN user__email CHAR(255),
                                                                           IN user__password VARCHAR(128),
                                                                           IN user_details__birthday DATE,
                                                                           IN user_details__newsletter TINYINT(1) UNSIGNED)
BEGIN

    DECLARE `_user__id` INT(10) UNSIGNED;

    INSERT
    INTO `user`
        (`uuid`, `email`, `password`, `created`, `modified`)
    VALUES (user__uuid, user__email, user__password, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

    SELECT `user`.`id`
    INTO `_user__id`
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

    IF `_user__id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user id', MYSQL_ERRNO = 1000;
    END IF;

    INSERT
    INTO `user_details`
        (`user_id`, `birthday`, `newsletter`, `created`, `modified`)
    VALUES (`_user__id`,
            user_details__birthday,
            user_details__newsletter,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;
