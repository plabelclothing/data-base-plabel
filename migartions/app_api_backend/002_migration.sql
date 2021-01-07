# 002_migration

CREATE TABLE `dict_collection`
(
    `id`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `code`     VARCHAR(36)      NOT NULL,
    `name`     VARCHAR(255)     NOT NULL,
    `created`  INT(10) UNSIGNED NOT NULL,
    `modified` INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `dict_size`
(
    `id`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `code`     VARCHAR(36)      NOT NULL,
    `name`     VARCHAR(36)      NOT NULL,
    `modified` INT(10) UNSIGNED NOT NULL,
    `created`  INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `dict_type_of_product`
(
    `id`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `code`     VARCHAR(36)      NOT NULL,
    `name`     VARCHAR(36)      NOT NULL,
    `modified` INT(10) UNSIGNED NOT NULL,
    `created`  INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `dict_color`
(
    `id`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `code`     VARCHAR(36)      NOT NULL,
    `name`     VARCHAR(36)      NOT NULL,
    `hex`      VARCHAR(36)      NOT NULL,
    `modified` INT(10) UNSIGNED NOT NULL,
    `created`  INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `dict_product`
(
    `id`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `code`     VARCHAR(36)      NOT NULL,
    `name`     VARCHAR(36)      NOT NULL,
    `modified` INT(10) UNSIGNED NOT NULL,
    `created`  INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `list_product`
(
    `id`                      INT(10) UNSIGNED    NOT NULL AUTO_INCREMENT,
    `uuid`                    CHAR(36)            NOT NULL,
    `name`                    VARCHAR(255)        NOT NULL,
    `is_active`               TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
    `dict_product_id`         INT(10) UNSIGNED    NOT NULL,
    `dict_collection_id`      INT(10) UNSIGNED    NOT NULL,
    `dict_type_of_product_id` INT(10) UNSIGNED    NOT NULL,
    `images`                  JSON                NOT NULL,
    `price`                   INT(10) UNSIGNED    NOT NULL,
    `modified`                INT(10) UNSIGNED    NOT NULL,
    `created`                 INT(10) UNSIGNED    NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`dict_product_id`, `dict_collection_id`, `dict_type_of_product_id`, `price`),
    UNIQUE INDEX (`uuid`),
    FOREIGN KEY (`dict_product_id`) REFERENCES `dict_product` (`id`),
    FOREIGN KEY (`dict_collection_id`) REFERENCES `dict_collection` (`id`),
    FOREIGN KEY (`dict_type_of_product_id`) REFERENCES `dict_type_of_product` (`id`)
);


CREATE TABLE `products`
(
    `id`              INT(10) UNSIGNED    NOT NULL AUTO_INCREMENT,
    `uuid`            CHAR(36)            NOT NULL,
    `is_active`       TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
    `list_product_id` INT(10) UNSIGNED    NOT NULL,
    `dict_color_id`   INT(10) UNSIGNED    NOT NULL,
    `dict_size_id`    INT(10) UNSIGNED    NOT NULL,
    `created`         INT(10) UNSIGNED    NOT NULL,
    `modified`        INT(10) UNSIGNED    NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`uuid`, `list_product_id`, `dict_color_id`, `dict_size_id`),
    FOREIGN KEY (`list_product_id`) REFERENCES `list_product` (`id`),
    FOREIGN KEY (`dict_color_id`) REFERENCES `dict_color` (`id`),
    FOREIGN KEY (`dict_size_id`) REFERENCES `dict_size` (`id`)
);

CREATE TABLE `currency_exchange_rate`
(
    `id`               INT(10) UNSIGNED       NOT NULL AUTO_INCREMENT,
    `dict_currency_id` INT(10) UNSIGNED       NOT NULL,
    `value`            DECIMAL(5, 3) UNSIGNED NOT NULL,
    `modified`         INT(10) UNSIGNED       NOT NULL,
    `created`          INT(10) UNSIGNED       NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX (`dict_currency_id`),
    FOREIGN KEY (`dict_currency_id`) REFERENCES `dict_currency` (`id`)
);

# region procedures

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__products__get` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__products__get`(IN _params JSON,
                                                                            IN _dict_country__iso CHAR(3))
BEGIN

    DECLARE __dict_collection__code JSON;
    DECLARE __dict_color__code JSON;
    DECLARE __dict_product__code JSON;
    DECLARE __dict_size__code JSON;
    DECLARE __dict_type_of_product__code JSON;
    DECLARE __dict_currency__iso4217 CHAR(3);
    DECLARE __dict_currency__symbol CHAR(3);
    DECLARE __currency_exchange_rate__value DECIMAL(5, 3);
    DECLARE __search_phrase LONGTEXT;

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

    SET __dict_collection__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictCollectionCode') = 1,
                                     JSON_EXTRACT(`_params`, '$.dictCollectionCode'), '[]');
    SET __search_phrase = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.searchPhrase') = 1,
                             JSON_UNQUOTE(JSON_EXTRACT(`_params`, '$.searchPhrase')), '');
    SET __dict_color__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictColorCode') = 1,
                                JSON_EXTRACT(`_params`, '$.dictColorCode'), '[]');
    SET __dict_size__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictSizeCode') = 1,
                               JSON_EXTRACT(`_params`, '$.dictSizeCode'), '[]');
    SET __dict_type_of_product__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictTypeOfProductCode') = 1,
                                          JSON_EXTRACT(`_params`, '$.dictTypeOfProductCode'), '[]');
    SET __dict_product__code = IF(JSON_CONTAINS_PATH(`_params`, 'one', '$.dictProductCode') = 1,
                                  JSON_EXTRACT(`_params`, '$.dictProductCode'), '[]');

    SET @__products = CONCAT('SELECT
       `products`.`uuid` AS `products__uuid`,

       `list_product`.`name` AS `list_product__name`,
       CAST(IF(', __currency_exchange_rate__value, ' != 1, (`list_product`.`price` * ', __currency_exchange_rate__value, ' / 100 DIV 10) * 10 + 10, `list_product`.`price` / 100) AS UNSIGNED)  AS `list_product__price`,
       `list_product`.`uuid` AS `list_product__uuid`,
       `list_product`.`images` AS `list_product__images`,

       "', __dict_currency__iso4217, '" AS `dict_currency_iso4217`,
       "', __dict_currency__symbol, '" AS `dict_currency_symbol`,

       `dict_collection`.`name` AS `dict_collection__name`,
       `dict_collection`.`code` AS `dict_collection__code`,

       `dict_color`.`name` AS `dict_color__name`,
       `dict_color`.`code` AS `dict_color__code`,
       `dict_color`.`hex` AS `dict_color__hex`,

       `dict_product`.`name` AS `dict_product__name`,
       `dict_product`.`code` AS `dict_product__code`,

       `dict_size`.`name` AS `dict_size__name`,
       `dict_size`.`code` AS `dict_size__code`,

       `dict_type_of_product`.`name` AS `dict_type_of_product__name`,
       `dict_type_of_product`.`code` AS `dict_type_of_product__code`

       FROM `products`
           LEFT JOIN `list_product`
               ON `list_product`.`id` = `products`.`list_product_id`
           LEFT JOIN `dict_collection`
               ON `dict_collection`.`id` = `list_product`.`dict_collection_id`
           LEFT JOIN `dict_color`
                     ON `dict_color`.`id` = `products`.`dict_color_id`
           LEFT JOIN `dict_product`
                     ON `dict_product`.`id` = `list_product`.`dict_product_id`
           LEFT JOIN `dict_size`
                     ON `dict_size`.`id` = `products`.`dict_size_id`
           LEFT JOIN `dict_type_of_product`
                     ON `dict_type_of_product`.`id` = `list_product`.`dict_type_of_product_id`

    WHERE `products`.`is_active` = 1
    AND `list_product`.`is_active` = 1',
                             IF(__search_phrase = '', '',
                                CONCAT(' AND `list_product`.`name` LIKE "%', __search_phrase, '%"')),
                             IF(IFNULL(JSON_LENGTH(__dict_collection__code), 0) = 0, '',
                                CONCAT(' AND `dict_collection`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_collection__code)), ')')),
                             IF(IFNULL(JSON_LENGTH(__dict_color__code), 0) = 0, '',
                                CONCAT(' AND `dict_color`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_color__code)), ')')),
                             IF(IFNULL(JSON_LENGTH(__dict_product__code), 0) = 0, '',
                                CONCAT(' AND `dict_product`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_product__code)), ')')),
                             IF(IFNULL(JSON_LENGTH(__dict_size__code), 0) = 0, '',
                                CONCAT(' AND `dict_size`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_size__code)), ')')),
                             IF(IFNULL(JSON_LENGTH(__dict_type_of_product__code), 0) = 0, '',
                                CONCAT(' AND `dict_type_of_product`.`code` IN (',
                                       TRIM(TRAILING ']' FROM TRIM(LEADING '[' FROM __dict_type_of_product__code)),
                                       ')')));

    PREPARE `stmt` FROM @__products;
    EXECUTE `stmt`;

END */$$
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `app_backend__product__get_by_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__product__get_by_uuid`(IN _list_product__uuid CHAR(36),
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

    SELECT `products`.`uuid`                                  AS `products__uuid`,

           `list_product`.`name`                              AS `list_product__name`,
           CAST(IF(__currency_exchange_rate__value != 1,
                   (`list_product`.`price` * __currency_exchange_rate__value / 100 DIV 10) * 10 + 10,
                   `list_product`.`price` / 100) AS UNSIGNED) AS `list_product__price`,
           `list_product`.`uuid`                              AS `list_product__uuid`,
           `list_product`.`images`                            AS `list_product__images`,

           __dict_currency__iso4217                           AS `dict_currency_iso4217`,
           __dict_currency__symbol                            AS `dict_currency_symbol`,

           `dict_collection`.`name`                           AS `dict_collection__name`,
           `dict_collection`.`code`                           AS `dict_collection__code`,

           `dict_color`.`name`                                AS `dict_color__name`,
           `dict_color`.`code`                                AS `dict_color__code`,
           `dict_color`.`hex`                                 AS `dict_color__hex`,

           `dict_product`.`name`                              AS `dict_product__name`,
           `dict_product`.`code`                              AS `dict_product__code`,

           `dict_size`.`name`                                 AS `dict_size__name`,
           `dict_size`.`code`                                 AS `dict_size__code`,

           `dict_type_of_product`.`name`                      AS `dict_type_of_product__name`,
           `dict_type_of_product`.`code`                      AS `dict_type_of_product__code`

    FROM `products`
             LEFT JOIN `list_product`
                       ON `list_product`.`id` = `products`.`list_product_id`
             LEFT JOIN `dict_collection`
                       ON `dict_collection`.`id` = `list_product`.`dict_collection_id`
             LEFT JOIN `dict_color`
                       ON `dict_color`.`id` = `products`.`dict_color_id`
             LEFT JOIN `dict_product`
                       ON `dict_product`.`id` = `list_product`.`dict_product_id`
             LEFT JOIN `dict_size`
                       ON `dict_size`.`id` = `products`.`dict_size_id`
             LEFT JOIN `dict_type_of_product`
                       ON `dict_type_of_product`.`id` = `list_product`.`dict_type_of_product_id`

    WHERE `products`.`is_active` = 1
      AND `list_product`.`is_active` = 1
      AND `list_product`.`uuid` = _list_product__uuid;


END */$$
DELIMITER ;

# region procedures

# region update info about migration
INSERT
INTO `migrations`
    (`name`, `uuid`, `created`, `modified`)
VALUES ('002_migration',
        `uuid_v4`(),
        UNIX_TIMESTAMP(),
        UNIX_TIMESTAMP());
