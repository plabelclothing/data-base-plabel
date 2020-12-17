/*!50003 DROP PROCEDURE IF EXISTS `common__country__insert` */;

DELIMITER $$

/*!50003
CREATE
    DEFINER = `internal`@`localhost` PROCEDURE `common__country__insert`()
BEGIN

    DECLARE __iteration INT(10) UNSIGNED DEFAULT 0;
    DECLARE __iteration_country INT(10) UNSIGNED DEFAULT 0;
    DECLARE __oneCountry JSON;
    DECLARE __one_part LONGTEXT;
    DECLARE __data_part_of_world JSON;
    DECLARE __data JSON;
    SET __data_part_of_world = '[
      "EUROPE",
      "MIDDLE_EAST",
      "ASIA",
      "AMERICAS",
      "OCEANIA"
    ]';
    SET __data = '[
      {
        "name": "Albania",
        "nativeName": "Shqipëria",
        "language": [
          "sq"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "AL"
      },
      {
        "name": "Armenia",
        "nativeName": "Հայաստան",
        "language": [
          "hy",
          "ru"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "AM"
      },
      {
        "name": "Austria",
        "nativeName": "Österreich",
        "language": [
          "de"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "AT"
      },
      {
        "name": "Bosnia and Herzegovina",
        "nativeName": "Bosna i Hercegovina",
        "language": [
          "bs",
          "hr",
          "sr"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "BA"
      },
      {
        "name": "Belgium",
        "nativeName": "België",
        "language": [
          "de"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "BE"
      },
      {
        "name": "Belarus",
        "nativeName": "Белару́сь",
        "language": [
          "ru"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "BY"
      },
      {
        "name": "Switzerland",
        "nativeName": "Schweiz",
        "language": [
          "de"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "CH"
      },
      {
        "name": "Cyprus",
        "nativeName": "Κύπρος",
        "language": [
          "el",
          "tr",
          "hy"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "CY"
      },
      {
        "name": "Czech Republic",
        "nativeName": "Česká republika",
        "language": [
          "cs",
          "sk"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "CZ"
      },
      {
        "name": "Germany",
        "nativeName": "Deutschland",
        "language": [
          "de"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "DE"
      },
      {
        "name": "Denmark",
        "nativeName": "Danmark",
        "language": [
          "da"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "DK"
      },
      {
        "name": "Estonia",
        "nativeName": "Eesti",
        "language": [
          "et"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "EE"
      },
      {
        "name": "Spain",
        "nativeName": "España",
        "language": [
          "es"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "ES"
      },
      {
        "name": "Finland",
        "nativeName": "Suomi",
        "language": [
          "fi",
          "sv"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "FI"
      },
      {
        "name": "France",
        "nativeName": "France",
        "language": [
          "fr"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "FR"
      },
      {
        "name": "United Kingdom",
        "nativeName": "United Kingdom",
        "language": [
          "en"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "GB"
      },
      {
        "name": "Georgia",
        "nativeName": "საქართველო",
        "language": [
          "ka"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "GE"
      },
      {
        "name": "Greece",
        "nativeName": "Ελλάδα",
        "language": [
          "el"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "GR"
      },
      {
        "name": "Hungary",
        "nativeName": "Magyarország",
        "language": [
          "hu"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "HU"
      },
      {
        "name": "Republic of Ireland",
        "nativeName": "Éire",
        "language": [
          "ga",
          "en"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "IE"
      },
      {
        "name": "Iceland",
        "nativeName": "Ísland",
        "language": [
          "is"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "IS"
      },
      {
        "name": "Italy",
        "nativeName": "Italia",
        "language": [
          "it"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "IT"
      },
      {
        "name": "Liechtenstein",
        "nativeName": "Liechtenstein",
        "language": [
          "de"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "LI"
      },
      {
        "name": "Lithuania",
        "nativeName": "Lietuva",
        "language": [
          "lt"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "LT"
      },
      {
        "name": "Luxembourg",
        "nativeName": "Luxembourg",
        "language": [
          "de"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "LU"
      },
      {
        "name": "Latvia",
        "nativeName": "Latvija",
        "language": [
          "lv"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "LV"
      },
      {
        "name": "Monaco",
        "nativeName": "Monaco",
        "language": [
          "fr"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "MC"
      },
      {
        "name": "Moldova",
        "nativeName": "Moldova",
        "language": [
          "ro"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "MD"
      },
      {
        "name": "Republic of Macedonia",
        "nativeName": "Македонија",
        "language": [
          "mk"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "MK"
      },
      {
        "name": "Malta",
        "nativeName": "Malta",
        "language": [
          "en"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "MT"
      },
      {
        "name": "Netherlands",
        "nativeName": "Nederland",
        "language": [
          "nl"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "NL"
      },
      {
        "name": "Norway",
        "nativeName": "Norge",
        "language": [
          "no",
          "nb",
          "nn"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "NO"
      },
      {
        "name": "Poland",
        "nativeName": "Polska",
        "language": [
          "pl"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "PL"
      },
      {
        "name": "Portugal",
        "nativeName": "Portugal",
        "language": [
          "pt"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "PT"
      },
      {
        "name": "Romania",
        "nativeName": "România",
        "language": [
          "ro"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "RO"
      },
      {
        "name": "Russia",
        "nativeName": "Россия",
        "language": [
          "ru"
        ],
        "currencies": "RUB",
        "partOfWorld": "EUROPE",
        "iso": "RU"
      },
      {
        "name": "Sweden",
        "nativeName": "Sverige",
        "language": [
          "sv"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "SE"
      },
      {
        "name": "Slovenia",
        "nativeName": "Slovenija",
        "language": [
          "sl"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "SI"
      },
      {
        "name": "Slovakia",
        "nativeName": "Slovensko",
        "language": [
          "sk"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "SK"
      },
      {
        "name": "San Marino",
        "nativeName": "San Marino",
        "language": [
          "it"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "SM"
      },
      {
        "name": "Turkey",
        "nativeName": "Türkiye",
        "language": [
          "tr"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "TR"
      },
      {
        "name": "Ukraine",
        "nativeName": "Україна",
        "language": [
          "uk"
        ],
        "currencies": "EUR",
        "partOfWorld": "EUROPE",
        "iso": "UA"
      },
      {
        "name": "United Arab Emirates",
        "nativeName": "دولة الإمارات العربية المتحدة",
        "language": [
          "ar"
        ],
        "currencies": "USD",
        "partOfWorld": "MIDDLE_EAST",
        "iso": "AE"
      },
      {
        "name": "Bahrain",
        "nativeName": "البحرين",
        "language": [
          "ar"
        ],
        "currencies": "USD",
        "partOfWorld": "MIDDLE_EAST",
        "iso": "BH"
      },
      {
        "name": "Israel",
        "nativeName": "יִשְׂרָאֵל",
        "language": [
          "he"
        ],
        "currencies": "USD",
        "partOfWorld": "MIDDLE_EAST",
        "iso": "IL"
      },
      {
        "name": "Jordan",
        "nativeName": "الأردن",
        "language": [
          "ar"
        ],
        "currencies": "USD",
        "partOfWorld": "MIDDLE_EAST",
        "iso": "JO"
      },
      {
        "name": "Kuwait",
        "nativeName": "الكويت",
        "language": [
          "ar"
        ],
        "currencies": "USD",
        "partOfWorld": "MIDDLE_EAST",
        "iso": "KW"
      },
      {
        "name": "Oman",
        "nativeName": "عمان",
        "language": [
          "ar"
        ],
        "currencies": "USD",
        "partOfWorld": "MIDDLE_EAST",
        "iso": "OM"
      },
      {
        "name": "Qatar",
        "nativeName": "قطر",
        "language": [
          "ar"
        ],
        "currencies": "USD",
        "partOfWorld": "MIDDLE_EAST",
        "iso": "QA"
      },
      {
        "name": "Saudi Arabia",
        "nativeName": "العربية السعودية",
        "language": [
          "ar"
        ],
        "currencies": "USD",
        "partOfWorld": "MIDDLE_EAST",
        "iso": "SA"
      },
      {
        "name": "China",
        "nativeName": "中国",
        "language": [
          "zh"
        ],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "CN"
      },
      {
        "name": "Hong Kong",
        "nativeName": "香港",
        "language": [
          "en",
          "zh"
        ],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "HK"
      },
      {
        "name": "Japan",
        "nativeName": "日本",
        "language": [
          "ja"
        ],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "JP"
      },
      {
        "name": "South Korea",
        "nativeName": "대한민국",
        "language": [
          "ko"
        ],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "KR"
      },
      {
        "name": "Kazakhstan",
        "nativeName": "Қазақстан",
        "language": [
          "ru"
        ],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "KZ"
      },
      {
        "name": "Malaysia",
        "nativeName": "Malaysia",
        "language": [],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "MY"
      },
      {
        "name": "Singapore",
        "nativeName": "Singapore",
        "language": [
          "en"
        ],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "SG"
      },
      {
        "name": "Thailand",
        "nativeName": "ประเทศไทย",
        "language": [
          "th"
        ],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "TH"
      },
      {
        "name": "Taiwan",
        "nativeName": "臺灣",
        "language": [
          "zh"
        ],
        "currencies": "USD",
        "partOfWorld": "ASIA",
        "iso": "TW"
      },
      {
        "name": "Australia",
        "nativeName": "Australia",
        "language": [
          "en"
        ],
        "currencies": "USD",
        "partOfWorld": "OCEANIA",
        "iso": "AU"
      },
      {
        "name": "New Zealand",
        "nativeName": "New Zealand",
        "language": [
          "en",
          "mi"
        ],
        "currencies": "USD",
        "partOfWorld": "OCEANIA",
        "iso": "NZ"
      },
      {
        "name": "Argentina",
        "nativeName": "Argentina",
        "language": [
          "es",
          "gn"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "AR"
      },
      {
        "name": "Bolivia",
        "nativeName": "Bolivia",
        "language": [
          "es",
          "ay",
          "qu"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "BO"
      },
      {
        "name": "Brazil",
        "nativeName": "Brasil",
        "language": [
          "pt"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "BR"
      },
      {
        "name": "Canada",
        "nativeName": "Canada",
        "language": [
          "en"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "CA"
      },
      {
        "name": "Chile",
        "nativeName": "Chile",
        "language": [
          "es"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "CL"
      },
      {
        "name": "Colombia",
        "nativeName": "Colombia",
        "language": [
          "es"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "CO"
      },
      {
        "name": "Ecuador",
        "nativeName": "Ecuador",
        "language": [
          "es"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "EC"
      },
      {
        "name": "Peru",
        "nativeName": "Perú",
        "language": [
          "es"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "PE"
      },
      {
        "name": "Paraguay",
        "nativeName": "Paraguay",
        "language": [
          "es",
          "gn"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "PY"
      },
      {
        "name": "United States",
        "nativeName": "United States",
        "language": [
          "en"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "US"
      },
      {
        "name": "Uruguay",
        "nativeName": "Uruguay",
        "language": [
          "es"
        ],
        "currencies": "USD",
        "partOfWorld": "AMERICAS",
        "iso": "UY"
      }
    ]';

    WHILE __iteration < JSON_LENGTH(__data_part_of_world)
        DO

            SELECT JSON_UNQUOTE(JSON_EXTRACT(__data_part_of_world, CONCAT('$[', __iteration, ']')))
            INTO __one_part;

            INSERT INTO `dict_part_of_world`
                (`code`, `created`, `modified`)
            VALUES (__one_part,
                    UNIX_TIMESTAMP(),
                    UNIX_TIMESTAMP());

            SET __iteration = __iteration + 1;
            SET __one_part = NULL;

        END WHILE;

    WHILE __iteration_country < JSON_LENGTH(__data)
        DO

            SELECT JSON_EXTRACT(__data, CONCAT('$[', __iteration_country, ']'))
            INTO __oneCountry;

            INSERT INTO `dict_country`
            (`dict_currency_id`, `dict_part_of_world_id`, `is_active`, `name`, `iso`, `nativeName`, `created`,
             `modified`)
            VALUES ((SELECT `dict_currency`.`id`
                     FROM `dict_currency`
                     WHERE `dict_currency`.`iso4217` = JSON_UNQUOTE(JSON_EXTRACT(__oneCountry, '$.currencies'))),
                    (SELECT `dict_part_of_world`.`id`
                     FROM `dict_part_of_world`
                     WHERE `dict_part_of_world`.`code` = JSON_UNQUOTE(JSON_EXTRACT(__oneCountry, '$.partOfWorld'))),
                    1,
                    JSON_UNQUOTE(JSON_EXTRACT(__oneCountry, '$.name')),
                    JSON_UNQUOTE(JSON_EXTRACT(__oneCountry, '$.iso')),
                    JSON_UNQUOTE(JSON_EXTRACT(__oneCountry, '$.nativeName')),
                    UNIX_TIMESTAMP(),
                    UNIX_TIMESTAMP());

            SET __iteration_country = __iteration_country + 1;
            SET __oneCountry = NULL;

        END WHILE;

END */$$
DELIMITER ;
