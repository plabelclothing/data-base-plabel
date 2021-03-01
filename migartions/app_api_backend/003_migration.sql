# 003_migration

CREATE TABLE `user`
(
    `id`        INT(10) UNSIGNED    NOT NULL AUTO_INCREMENT,
    `uuid`      CHAR(36)            NOT NULL,
    `is_active` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
    `email`     CHAR(255)           NOT NULL,
    `password`  VARCHAR(128),
    `created`   INT(10) UNSIGNED    NOT NULL,
    `modified`  INT(10) UNSIGNED    NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`),
    UNIQUE INDEX (`email`)
);

CREATE TABLE `user_details`
(
    `id`              INT(10) UNSIGNED              NOT NULL AUTO_INCREMENT,
    `user_id`         INT(10) UNSIGNED              NOT NULL,
    `first_name`      VARCHAR(64)                   NULL,
    `last_name`       VARCHAR(64)                   NULL,
    `birthday`        DATE,
    `phone`           VARCHAR(64),
    `street`          VARCHAR(200)                  NULL,
    `zip`             VARCHAR(30)                   NULL,
    `city`            VARCHAR(100)                  NULL,
    `dict_country_id` INT(10) UNSIGNED              NULL,
    `policies`        TINYINT(1) UNSIGNED DEFAULT 1 NOT NULL,
    `newsletter`      TINYINT(1) UNSIGNED DEFAULT 1 NOT NULL,
    `created`         INT(10) UNSIGNED              NOT NULL,
    `modified`        INT(10) UNSIGNED              NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    FOREIGN KEY (`dict_country_id`) REFERENCES `dict_country` (`id`)
);

CREATE TABLE `user_cart`
(
    `id`        INT(10) UNSIGNED              NOT NULL AUTO_INCREMENT,
    `uuid`      CHAR(36)                      NOT NULL,
    `user_id`   INT(10) UNSIGNED,
    `is_active` TINYINT(1) UNSIGNED DEFAULT 1 NOT NULL,
    `created`   INT(10) UNSIGNED              NOT NULL,
    `modified`  INT(10) UNSIGNED              NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`),
    UNIQUE INDEX (`user_id`, `is_active`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
);

CREATE TABLE `user_cart_items`
(
    `id`           INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_cart_id` INT(10) UNSIGNED NOT NULL,
    `products_id`  INT(10) UNSIGNED NOT NULL,
    `created`      INT(10) UNSIGNED NOT NULL,
    `modified`     INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_cart_id`) REFERENCES `user_cart` (`id`),
    FOREIGN KEY (`products_id`) REFERENCES `products` (`id`)
);

CREATE TABLE `user_order`
(
    `id`                     INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`                   CHAR(36)         NOT NULL,
    `user_cart_id`           INT(10) UNSIGNED NOT NULL,
    `user_id`                INT(10) UNSIGNED,
    `additional_information` JSON,
    `another_address`        JSON,
    `tracking_number`        VARCHAR(255),
    `created`                INT(10) UNSIGNED NOT NULL,
    `modified`               INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`),
    FOREIGN KEY (`user_cart_id`) REFERENCES `user_cart` (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
);

CREATE TABLE `notification_email`
(
    `id`       INT(10) UNSIGNED                      NOT NULL AUTO_INCREMENT,
    `user_id`  INT(10) UNSIGNED                      NULL,
    `uuid`     CHAR(36)                              NOT NULL,
    `template` VARCHAR(155)                          NOT NULL,
    `to`       VARCHAR(155)                          NOT NULL,
    `status`   ENUM ('new','pending','sent','error') NOT NULL,
    `body`     JSON,
    `created`  INT(10) UNSIGNED                      NOT NULL,
    `modified` INT(10) UNSIGNED                      NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    UNIQUE INDEX (`uuid`)
);


CREATE TABLE `user_portal_link`
(
    `id`        INT(10) UNSIGNED                            NOT NULL AUTO_INCREMENT,
    `user_id`   INT(10) UNSIGNED                            NOT NULL,
    `uuid`      CHAR(36)                                    NOT NULL,
    `type`      ENUM ('registration','recovery','remember') NOT NULL,
    `is_active` TINYINT(1) UNSIGNED DEFAULT 1               NOT NULL,
    `active_to` INT(10) UNSIGNED,
    `modified`  INT(10) UNSIGNED                            NOT NULL,
    `created`   INT(10) UNSIGNED                            NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    UNIQUE INDEX (`uuid`)
);

CREATE TABLE `payment_method`
(
    `id`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`     CHAR(36)         NOT NULL,
    `name`     VARCHAR(255)     NOT NULL,
    `code`     VARCHAR(255)     NOT NULL,
    `modified` INT(10) UNSIGNED NOT NULL,
    `created`  INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`)
);

CREATE TABLE `transaction`
(
    `id`                INT(10) UNSIGNED                              NOT NULL AUTO_INCREMENT,
    `uuid`              CHAR(36)                                      NOT NULL,
    `external_id`       VARCHAR(255),
    `user_order_id`     INT(10) UNSIGNED                              NOT NULL,
    `payment_method_id` INT(10) UNSIGNED                              NOT NULL,
    `dict_currency_id`  INT(10) UNSIGNED                              NOT NULL,
    `amount`            INT(10) UNSIGNED                              NOT NULL,
    `status`            ENUM ('pending','settled','canceled','error') NOT NULL,
    `settled_at`        INT(10) UNSIGNED                              NOT NULL,
    `created`           INT(10) UNSIGNED                              NOT NULL,
    `modified`          INT(10) UNSIGNED                              NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`),
    FOREIGN KEY (`user_order_id`) REFERENCES `user_order` (`id`),
    FOREIGN KEY (`payment_method_id`) REFERENCES `payment_method` (`id`),
    FOREIGN KEY (`dict_currency_id`) REFERENCES `dict_currency` (`id`)
);

CREATE TABLE `transaction_log`
(
    `id`             INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`           CHAR(36)         NOT NULL,
    `transaction_id` INT(10) UNSIGNED NOT NULL,
    `data`           JSON             NOT NULL,
    `created`        INT(10) UNSIGNED NOT NULL,
    `modified`       INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`),
    FOREIGN KEY (`transaction_id`) REFERENCES `transaction` (`id`)
);

CREATE TABLE `notification_ipn`
(
    `id`             INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid`           CHAR(36)         NOT NULL,
    `transaction_id` INT(10) UNSIGNED,
    `data`           JSON             NOT NULL,
    `created`        INT(10) UNSIGNED NOT NULL,
    `modified`       INT(10) UNSIGNED NOT NULL,
    UNIQUE INDEX (`id`),
    INDEX (`uuid`),
    FOREIGN KEY (`transaction_id`) REFERENCES `transaction` (`id`)
);


# region procedures

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__notification_email__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__notification_email__insert`(IN notification_email__uuid CHAR(36),
                                                                                         IN user__uuid CHAR(36),
                                                                                         IN notification_email__to VARCHAR(155),
                                                                                         IN notification_email__template VARCHAR(155),
                                                                                         IN notification_email__status ENUM ('new','pending','sent','error'),
                                                                                         IN notification_email__body JSON)
BEGIN

    DECLARE `_user__id` INT(10) UNSIGNED;

    SELECT `user`.`id`
    INTO `_user__id`
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

    INSERT
    INTO `notification_email`
    (`user_id`, `uuid`, `to`, `template`, `status`, `body`, `created`, `modified`)
    VALUES (_user__id,
            notification_email__uuid,
            notification_email__to,
            notification_email__template,
            notification_email__status,
            notification_email__body,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;


/*!50003 DROP PROCEDURE IF EXISTS `app_backend__notification_email__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__notification_email__update`(IN notification_email__uuid CHAR(36),
                                                                                         IN notification_email__status ENUM ('new','pending','sent','error'))
BEGIN

    UPDATE `notification_email`
    SET `notification_email`.`status`   = notification_email__status,
        `notification_email`.`modified` = UNIX_TIMESTAMP()
    WHERE `notification_email`.`uuid` = notification_email__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__check_exist` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__check_exist`(IN user__uuid CHAR(36)
)
BEGIN

    SELECT `user`.`email`    AS `user__email`,
           `user`.`password` AS `user__password`
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;

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


/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__update`(IN user__uuid CHAR(36),
                                                                           IN user__password VARCHAR(128),
                                                                           IN user__is_active TINYINT(1) UNSIGNED)
BEGIN

    UPDATE `user`
    SET `user`.`password`  = IFNULL(user__password, `user`.`password`),
        `user`.`is_active` = IFNULL(user__is_active, `user`.`is_active`),
        `user`.`modified`  = UNIX_TIMESTAMP()
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_portal_link__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_portal_link__get`(IN user_portal_link__uuid CHAR(36),
                                                                                    IN user_portal_link__type ENUM ('registration','recovery','remember'),
                                                                                    IN user_portal_link__active_to INT(10) UNSIGNED)
BEGIN

    SELECT `user_portal_link`.`uuid` AS `user_portal_link__uuid`,
           `user_portal_link`.`type` AS `user_portal_link__type`,

           `user`.`uuid`             AS `user__uuid`
    FROM `user_portal_link`
             LEFT JOIN `user`
                       ON `user`.`id` = `user_portal_link`.`user_id`
    WHERE `user_portal_link`.`uuid` = user_portal_link__uuid
      AND `user_portal_link`.`type` = user_portal_link__type
      AND `user_portal_link`.`active_to` > user_portal_link__active_to
      AND `user_portal_link`.`is_active` = 1;

END */$$
DELIMITER ;


/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_portal_link__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_portal_link__insert`(IN user_portal_link__uuid CHAR(36),
                                                                                       IN user__uuid CHAR(36),
                                                                                       IN user_portal_link__type ENUM ('registration','recovery','remember'),
                                                                                       IN user_portal_link__active_to INT(10) UNSIGNED)
BEGIN

    INSERT
    INTO `user_portal_link`
        (`user_id`, `uuid`, `type`, `active_to`, `created`, `modified`)
    SELECT `user`.`id`,
           user_portal_link__uuid,
           user_portal_link__type,
           user_portal_link__active_to,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;
/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_portal_link__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_portal_link__update`(IN user_portal_link__uuid CHAR(36),
                                                                                       IN user_portal_link__type ENUM ('registration','recovery','remember'))
BEGIN

    UPDATE `user_portal_link`
    SET `user_portal_link`.`is_active` = 0,
        `user_portal_link`.`modified`  = UNIX_TIMESTAMP()
    WHERE `user_portal_link`.`uuid` = user_portal_link__uuid
      AND `user_portal_link`.`type` = user_portal_link__type;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_order__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_order__insert`(IN user_order__uuid CHAR(36),
                                                                                 IN user_cart__uuid CHAR(36),
                                                                                 IN user__uuid CHAR(36),
                                                                                 IN user_cart__additional_information JSON,
                                                                                 IN user_cart__another_address JSON,
                                                                                 IN user_cart__tracking_number VARCHAR(255))
BEGIN

    INSERT
    INTO `user_cart`
    (`uuid`, `user_cart_id`, `user_id`, `additional_information`, `another_address`, `tracking_number`, `created`,
     `modified`)
    SELECT user_order__uuid,
           user_cart__uuid,
           `user`.`id`,
           user_cart__additional_information,
           user_cart__another_address,
           user_cart__tracking_number,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `user`
    WHERE `user`.`uuid` = user__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction__insert`(IN transaction__uuid CHAR(36),
                                                                                  IN user_order__uuid CHAR(36),
                                                                                  IN payment_method__code VARCHAR(255),
                                                                                  IN dict_currency__iso4217 CHAR(3),
                                                                                  IN transaction__amount INT(10) UNSIGNED,
                                                                                  IN transaction__status ENUM ('pending','settled','canceled','error'))
BEGIN

    DECLARE `_user_order_id` INT(10) UNSIGNED;
    DECLARE `_payment_method_id` INT(10) UNSIGNED;
    DECLARE `_dict_currency_id` INT(10) UNSIGNED;

    SELECT `user_order`.`id`
    INTO `_user_order_id`
    FROM `user_order`
    WHERE `user_order`.`uuid` = user_order__uuid;

    IF `_user_order_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user order id', MYSQL_ERRNO = 1000;
    END IF;

    SELECT `payment_method`.`id`
    INTO `_payment_method_id`
    FROM `payment_method`
    WHERE `payment_method`.`code` = payment_method__code;

    IF `_payment_method_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No payment method id', MYSQL_ERRNO = 1001;
    END IF;

    SELECT `dict_currency`.`id`
    INTO `_dict_currency_id`
    FROM `dict_currency`
    WHERE `dict_currency`.`iso4217` = dict_currency__iso4217;

    IF `_dict_currency_id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No dict currency id', MYSQL_ERRNO = 1002;
    END IF;

    INSERT
    INTO `transaction`
    (`uuid`, `user_order_id`, `payment_method_id`, `dict_currency_id`, `amount`, `status`, `created`, `modified`)
    VALUES (transaction__uuid,
            _user_order_id,
            _payment_method_id,
            _dict_currency_id,
            transaction__amount,
            transaction__status,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction__update`(IN transaction__uuid CHAR(36),
                                                                                  IN transaction_external_id VARCHAR(255),
                                                                                  IN transaction__status ENUM ('pending','settled','canceled','error'),
                                                                                  IN transaction__settled_at INT(10) UNSIGNED)
BEGIN

    UPDATE `transaction`
    SET `transaction`.`external_id` = IFNULL(transaction_external_id, `transaction`.`external_id`),
        `transaction`.`status`      = IFNULL(transaction__status, `transaction`.`status`),
        `transaction`.`settled_at`  = IFNULL(transaction__settled_at, `transaction`.`settled_at`),
        `transaction`.`modified`    = UNIX_TIMESTAMP()
    WHERE `transaction`.`uuid` = transaction__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__transaction_log__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__transaction_log__insert`(IN transaction__uuid CHAR(36),
                                                                                      IN transaction_log__data CHAR(36))
BEGIN

    INSERT
    INTO `transaction_log`
        (`uuid`, `transaction_id`, `data`, `created`, `modified`)
    SELECT `uuid_v4`(),
           `transaction`.`id`,
           transaction_log__data,
           UNIX_TIMESTAMP(),
           UNIX_TIMESTAMP()
    FROM `transaction`
    WHERE `transaction`.`uuid` = transaction__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__notification_ipn__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__notification_ipn__insert`(IN transaction__uuid CHAR(36),
                                                                                       IN notification_ipn__data JSON)
BEGIN

    DECLARE `_transaction_id` INT(10) UNSIGNED;

    SELECT `transaction`.`id`
    INTO `_transaction_id`
    FROM `transaction`
    WHERE `transaction`.`uuid` = transaction__uuid;

    INSERT
    INTO `notification_ipn`
        (`uuid`, `transaction_id`, `data`, `created`, `modified`)
    VALUES (`uuid_v4`(),
            _transaction_id,
            notification_ipn__data,
            UNIX_TIMESTAMP(),
            UNIX_TIMESTAMP());

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__signin` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__signin`(IN user__email CHAR(36),
                                                                           IN user__password VARCHAR(128))
BEGIN

    SELECT `user`.`uuid`  AS `user__uuid`,
           `user`.`email` AS `user__email`
    FROM `user`
    WHERE `user`.`email` = user__email
      AND `user`.`is_active` = 1
      AND `user`.`password` = user__password;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user__check_exist_by_email` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user__check_exist_by_email`(IN user__email CHAR(255)
)
BEGIN

    SELECT `user`.`uuid` AS `user__uuid`
    FROM `user`
    WHERE `user`.`email` = user__email;

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

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__insert`(IN user__uuid CHAR(36),
                                                                                IN user_cart__uuid CHAR(36),
                                                                                IN user_cart_items__data JSON)
BEGIN

    DECLARE `_user__id` INT(10) UNSIGNED;
    DECLARE `_user_cart__id` INT(10) UNSIGNED;
    DECLARE `_user_cart__item` JSON;
    DECLARE `_products_id` INT(10) UNSIGNED;
    DECLARE `_iteration` INT(10) DEFAULT 0;

    IF (user__uuid IS NOT NULL)
    THEN

        SELECT `user`.`id`
        INTO `_user__id`
        FROM `user`
        WHERE `user`.`uuid` = user__uuid;

        IF `_user__id` IS NULL
        THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user id', MYSQL_ERRNO = 1000;
        END IF;

    END IF;

    INSERT
    INTO `user_cart`
        (`uuid`, `user_id`, `is_active`, `created`, `modified`)
    VALUES (user_cart__uuid, _user__id, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

    SELECT `user_cart`.`id`
    INTO `_user_cart__id`
    FROM `user_cart`
    WHERE `user_cart`.`uuid` = user_cart__uuid;

    IF `_user_cart__id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user cart id', MYSQL_ERRNO = 1001;
    END IF;

    WHILE _iteration < JSON_LENGTH(user_cart_items__data)
        DO
            SELECT JSON_EXTRACT(user_cart_items__data, CONCAT('$[', _iteration, ']'))
            INTO _user_cart__item;

            SELECT `products`.`id`
            INTO _products_id
            FROM `products`
            WHERE `products`.`uuid` = JSON_UNQUOTE(JSON_EXTRACT(_user_cart__item, '$.productUuid'));

            INSERT
            INTO `user_cart_items`
                (`user_cart_id`, `products_id`, `created`, `modified`)
            VALUES (`_user_cart__id`,
                    `_products_id`,
                    UNIX_TIMESTAMP(),
                    UNIX_TIMESTAMP());

            SET _user_cart__item = NULL;
            SET _products_id = NULL;
            SET _iteration = _iteration + 1;
        END WHILE;

END */$$
DELIMITER ;


/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__update` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__update`(IN user_cart__uuid CHAR(36),
                                                                                IN user_cart_items JSON)
BEGIN

    DECLARE `_user_cart__id` INT(10) UNSIGNED;
    DECLARE `_user_cart__item` JSON;
    DECLARE `_products_id` INT(10) UNSIGNED;
    DECLARE `_iteration` INT(10) DEFAULT 0;

    SELECT `user_cart`.`id`
    INTO `_user_cart__id`
    FROM `user_cart`
    WHERE `user_cart`.`uuid` = user_cart__uuid;

    IF `_user_cart__id` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user cart id', MYSQL_ERRNO = 1001;
    END IF;

    WHILE _iteration < JSON_LENGTH(user_cart_items)
        DO
            SELECT JSON_EXTRACT(user_cart_items, CONCAT('$[', _iteration, ']'))
            INTO _user_cart__item;

            SELECT `products`.`id`
            INTO _products_id
            FROM `products`
            WHERE `products`.`uuid` = JSON_UNQUOTE(JSON_EXTRACT(_user_cart__item, '$.productUuid'));

            INSERT
            INTO `user_cart_items`
                (`user_cart_id`, `products_id`, `created`, `modified`)
            VALUES (`_user_cart__id`,
                    `_products_id`,
                    UNIX_TIMESTAMP(),
                    UNIX_TIMESTAMP());

            SET _user_cart__item = NULL;
            SET _products_id = NULL;
            SET _iteration = _iteration + 1;
        END WHILE;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart_items__get_by_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart_items__get_by_uuid`(IN _user_cart__uuid CHAR(36),
                                                                                           IN _dict_country__iso CHAR(3))
BEGIN

    DECLARE __dict_currency__iso4217 CHAR(3);
    DECLARE __dict_currency__symbol CHAR(3);
    DECLARE __currency_exchange_rate__value DECIMAL(5, 3);

    SELECT `dict_currency`.`iso4217`,
           `dict_currency`.`symbol`,
           `currency_exchange_rate`.`value`
    INTO __dict_currency__iso4217, __dict_currency__symbol, __currency_exchange_rate__value
    FROM `dict_currency`
             LEFT JOIN `dict_country`
                       ON `dict_country`.`dict_currency_id` = `dict_currency`.`id`
             LEFT JOIN `currency_exchange_rate`
                       ON `currency_exchange_rate`.`dict_currency_id` = `dict_currency`.`id`
    WHERE `dict_country`.`iso` = _dict_country__iso;

    IF `__dict_currency__iso4217` IS NULL
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No user currency', MYSQL_ERRNO = 1000;
    END IF;

    SELECT COUNT(`products`.`id`)                             AS `products__count`,
           `products`.`uuid`                                  AS `products__uuid`,

           `list_product`.`name`                              AS `list_product__name`,
           CAST(IF(__currency_exchange_rate__value != 1,
                   (`list_product`.`price` * __currency_exchange_rate__value / 100 DIV 10) * 10 + 10,
                   `list_product`.`price` / 100) AS UNSIGNED) AS `list_product__price`,
           `list_product`.`uuid`                              AS `list_product__uuid`,
           `list_product`.`images`                            AS `list_product__images`,

           __dict_currency__iso4217                           AS `dict_currency_iso4217`,
           __dict_currency__symbol                            AS `dict_currency_symbol`,

           `dict_color`.`name`                                AS `dict_color__name`,
           `dict_color`.`code`                                AS `dict_color__code`,
           `dict_color`.`hex`                                 AS `dict_color__hex`,

           `dict_product`.`name`                              AS `dict_product__name`,
           `dict_product`.`code`                              AS `dict_product__code`,

           `dict_size`.`name`                                 AS `dict_size__name`,
           `dict_size`.`code`                                 AS `dict_size__code`

    FROM `user_cart`
             LEFT JOIN `user_cart_items`
                       ON `user_cart_items`.`user_cart_id` = `user_cart`.`id`
             INNER JOIN `products`
                        ON `products`.`id` = `user_cart_items`.`products_id`
             LEFT JOIN `list_product`
                       ON `list_product`.`id` = `products`.`list_product_id`
             LEFT JOIN `dict_color`
                       ON `dict_color`.`id` = `products`.`dict_color_id`
             LEFT JOIN `dict_product`
                       ON `dict_product`.`id` = `list_product`.`dict_product_id`
             LEFT JOIN `dict_size`
                       ON `dict_size`.`id` = `products`.`dict_size_id`

    WHERE `products`.`is_active` = 1
      AND `user_cart`.`is_active` = 1
      AND `user_cart`.`uuid` = _user_cart__uuid

    GROUP BY `products`.`uuid`, `list_product`.`name`, `list_product`.`uuid`, `list_product`.`images`,
             `dict_color`.`name`, `dict_color`.`code`, `dict_color`.`hex`, `dict_product`.`name`, `dict_product`.`code`,
             `dict_size`.`name`, `dict_size`.`code`;


END */$$
DELIMITER ;


/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__delete` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__delete`(IN user_cart__uuid CHAR(36),
                                                                                IN product__uuid CHAR(36))
BEGIN

    DELETE `user_cart_items`
    FROM `user_cart_items`
             INNER JOIN `user_cart`
                        ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
             INNER JOIN `products`
                        ON `products`.`id` = `user_cart_items`.`products_id`
    WHERE `products`.`uuid` = product__uuid
      AND `user_cart`.`uuid` = user_cart__uuid;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__user_cart__change_count` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__user_cart__change_count`(IN user_cart__uuid CHAR(36),
                                                                                      IN product__uuid CHAR(36),
                                                                                      IN type ENUM ('subtract', 'add'))
BEGIN

    DECLARE _user_cart_items__id INT(10) UNSIGNED;

    IF (type = 'add')
    THEN

        INSERT
        INTO `user_cart_items`
            (`user_cart_id`, `products_id`, `created`, `modified`)
        SELECT `user_cart_items`.`user_cart_id`,
               `user_cart_items`.`products_id`,
               UNIX_TIMESTAMP(),
               UNIX_TIMESTAMP()
        FROM `user_cart_items`
                 INNER JOIN `user_cart`
                            ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
                 INNER JOIN `products`
                            ON `products`.`id` = `user_cart_items`.`products_id`
        WHERE `products`.`uuid` = product__uuid
          AND `user_cart`.`uuid` = user_cart__uuid
        LIMIT 1;

    END IF;

    IF (type = 'subtract')
    THEN

        SELECT `user_cart_items`.`id`
        INTO _user_cart_items__id
        FROM `user_cart_items`
                 INNER JOIN `user_cart`
                            ON `user_cart`.`id` = `user_cart_items`.`user_cart_id`
                 INNER JOIN `products`
                            ON `products`.`id` = `user_cart_items`.`products_id`
        WHERE `products`.`uuid` = product__uuid
          AND `user_cart`.`uuid` = user_cart__uuid
        LIMIT 1;

        DELETE
        FROM `user_cart_items`
        WHERE `user_cart_items`.`id` = `_user_cart_items__id`;

    END IF;

END */$$
DELIMITER ;

# region procedures

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `created`, `modified`)
VALUES ('003_migration',
        `uuid_v4`(),
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
