/*!50003 DROP PROCEDURE IF EXISTS `app_backend__products__get_uuid` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `app_backend__products__get_uuid`(IN _params JSON,
                                                                                 IN _dict_country__iso CHAR(3),
                                                                                 IN _lastId INT(10) UNSIGNED,
                                                                                 IN _limit INT(10) UNSIGNED)
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
       `list_product`.`uuid` AS `list_product__uuid`
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
                             IF(_lastId IS NULL, '',
                                CONCAT(' AND `list_product`.`id` < ', _lastId)),
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
                                       ')')),
                             'GROUP BY `list_product`.`id`
                             ORDER BY `list_product`.`id` DESC',
                             ' LIMIT ', _limit
        );

    PREPARE `stmt` FROM @__products;
    EXECUTE `stmt`;

END */$$
DELIMITER;
