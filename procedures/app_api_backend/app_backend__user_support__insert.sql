/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_support__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_support__insert`(IN _user__uuid CHAR(36),
                                                                                   IN _user_order__external_id VARCHAR(20),
                                                                                   IN _user_support__uuid CHAR(36),
                                                                                   IN _user_support_respond_to CHAR(255),
                                                                                   IN _body JSON)
BEGIN

    DECLARE __user__id INT(10) UNSIGNED;
    DECLARE __user_order__id INT(10) UNSIGNED;

    SELECT `user`.`id`
    INTO __user__id
    FROM `user`
    WHERE `user`.`uuid` = _user__uuid;

    SELECT `user_order`.`id`
    INTO __user_order__id
    FROM `user_order`
    WHERE `user_order`.`external_id` = _user_order__external_id;

    INSERT
    INTO `user_support`
    (`uuid`, `user_id`, `user_order_id`, `body`, `respond_to`, `modified`, `created`)
    VALUES (_user_support__uuid,
            __user__id,
            __user_order__id,
            _body,
            _user_support_respond_to,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;
