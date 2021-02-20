/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__insert`(IN user__email CHAR(255),
                                                                           IN user__password VARCHAR(128))
BEGIN

    INSERT
    INTO `user`
        (`uuid`, `email`, `password`, `created`, `modified`)
    VALUES (`uuid_v4`(), user__email, user__password, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

END */$$
DELIMITER ;
