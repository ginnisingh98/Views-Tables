--------------------------------------------------------
--  DDL for Package Body BIS_COLOR_TRIGGERS_SET_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_COLOR_TRIGGERS_SET_MLS" AS
/* $Header: BISCMLSB.pls 120.1 2005/11/03 12:53:42 serao noship $ */

-- procedure to add a language.	 Bug.Fix.4700227
PROCEDURE Add_Language IS
BEGIN

/*    DELETE FROM BIS_COLOR_TRIGGERS_SET_TL T
    WHERE NOT EXISTS
    (
      SELECT NULL
      FROM   BIS_COLOR_TRIGGERS_SET B
      WHERE  B.PORTLET_SHORT_NAME = T.PORTLET_SHORT_NAME
    );*/

    UPDATE BIS_COLOR_TRIGGERS_SET_TL T SET (
        NAME
    ) = (SELECT
            B.NAME
         FROM  BIS_COLOR_TRIGGERS_SET_TL B
         WHERE B.COLOR_SET_ID = T.COLOR_SET_ID
         AND   B.LANGUAGE     = T.SOURCE_LANG)
         WHERE (
            T.COLOR_SET_ID,
            T.LANGUAGE
         ) IN (SELECT
                SUBT.COLOR_SET_ID,
                SUBT.LANGUAGE
                FROM  BIS_COLOR_TRIGGERS_SET_TL SUBB, BIS_COLOR_TRIGGERS_SET_TL SUBT
                WHERE SUBB.COLOR_SET_ID = SUBT.COLOR_SET_ID
                AND   SUBB.LANGUAGE     = SUBT.SOURCE_LANG
                AND (SUBB.NAME <> SUBT.NAME
                ));

    INSERT INTO BIS_COLOR_TRIGGERS_SET_TL
    (
      COLOR_SET_ID,
      LANGUAGE,
      SOURCE_LANG,
      NAME
    )
    SELECT
       B.COLOR_SET_ID,
       L.LANGUAGE_CODE,
       B.SOURCE_LANG,
       B.NAME
   FROM  BIS_COLOR_TRIGGERS_SET_TL B, FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ('I', 'B')
   AND   B.LANGUAGE = USERENV('LANG')
   AND   NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_COLOR_TRIGGERS_SET_TL T
          WHERE  T.COLOR_SET_ID = B.COLOR_SET_ID
          AND    T.LANGUAGE     = L.LANGUAGE_CODE
        );

END Add_Language;

end BIS_COLOR_TRIGGERS_SET_MLS;

/
