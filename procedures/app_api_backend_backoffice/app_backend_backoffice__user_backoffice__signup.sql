/*!50003 DROP PROCEDURE IF EXISTS `app_backend_backoffice__user_backoffice__signup` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend_backoffice__user_backoffice__signup`(IN `_user_backoffice__email` CHAR(255),
                                                                                                 IN `_user_backoffice__password` VARCHAR(128))
BEGIN

    INSERT
    INTO `user_backoffice`
        (`uuid`, `email`, `password`, `created`, `modified`)
    VALUES (`uuid_v4`(),
            _user_backoffice__email,
            _user_backoffice__password,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;
