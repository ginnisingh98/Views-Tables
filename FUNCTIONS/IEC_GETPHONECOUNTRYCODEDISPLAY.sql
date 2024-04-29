--------------------------------------------------------
--  DDL for Function IEC_GETPHONECOUNTRYCODEDISPLAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."IEC_GETPHONECOUNTRYCODEDISPLAY" (p_phone_country_code IN NUMBER)
                  RETURN VARCHAR2
               IS
                  l_display_str     VARCHAR2(4000);
                  l_country_col     SYSTEM.varchar_tbl_type;
               BEGIN

                  IF p_phone_country_code = 1 THEN

                     SELECT TERRITORY_SHORT_NAME
                     BULK COLLECT INTO l_country_col
                     FROM FND_TERRITORIES_VL
                     WHERE TERRITORY_CODE IN ('US', 'CA')
                     ORDER BY TERRITORY_SHORT_NAME;

                     l_display_str :=   '1 - (North American Numbering Plan - '
                                      || l_country_col(1)
                                      || ', ' || l_country_col(2) || ')';
                     RETURN l_display_str;
                  END IF;

                  SELECT TERRITORY_SHORT_NAME
                  BULK COLLECT INTO l_country_col
                  FROM FND_TERRITORIES_VL A, HZ_PHONE_COUNTRY_CODES B
                  WHERE A.TERRITORY_CODE = B.TERRITORY_CODE
                  AND B.PHONE_COUNTRY_CODE = p_phone_country_code
                  ORDER BY TERRITORY_SHORT_NAME;

                  l_display_str := p_phone_country_code;
                  IF l_country_col IS NOT NULL AND l_country_col.COUNT > 0 THEN
                     l_display_str := l_display_str || ' - (' || l_country_col(1);
                     FOR i IN 2..l_country_col.LAST LOOP
                        l_display_str := l_display_str || ', ' || l_country_col(i);
                     END LOOP;
                     l_display_str := l_display_str || ')';
                  END IF;

                  RETURN l_display_str;
               END;
 

/
