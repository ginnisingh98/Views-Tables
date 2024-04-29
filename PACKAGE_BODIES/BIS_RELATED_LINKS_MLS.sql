--------------------------------------------------------
--  DDL for Package Body BIS_RELATED_LINKS_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RELATED_LINKS_MLS" AS
/* $Header: BISPRLKB.pls 120.0 2005/10/14 13:18:29 slowe noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPRLKB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private for populating the table BIS_RELATED_LINKS_TL   |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 14-OCT-2005 Seema Rao  Created.                                      |
REM +=======================================================================+
*/

/*
  Private CRUD APIs
*/


-- procedure to add a language.
PROCEDURE Add_Language IS
BEGIN

    DELETE FROM BIS_RELATED_LINKS_TL T
    WHERE NOT EXISTS
    (
      SELECT NULL
      FROM   BIS_RELATED_LINKS B
      WHERE  B.RELATED_LINK_ID = T.RELATED_LINK_ID
    );

    UPDATE BIS_RELATED_LINKS_TL T SET (
        USER_LINK_NAME
    ) = (SELECT
            B.USER_LINK_NAME
         FROM  BIS_RELATED_LINKS_TL B
         WHERE B.RELATED_LINK_ID = T.RELATED_LINK_ID
         AND   B.LANGUAGE           = T.SOURCE_LANG)
         WHERE (
            T.RELATED_LINK_ID,
            T.LANGUAGE
         ) IN (SELECT
                SUBT.RELATED_LINK_ID,
                SUBT.LANGUAGE
                FROM  BIS_RELATED_LINKS_TL SUBB, BIS_RELATED_LINKS_TL SUBT
                WHERE SUBB.RELATED_LINK_ID = SUBT.RELATED_LINK_ID
                AND   SUBB.LANGUAGE           = SUBT.SOURCE_LANG
                AND (
                     SUBB.USER_LINK_NAME              <> SUBT.USER_LINK_NAME
                    )
                );

    INSERT INTO BIS_RELATED_LINKS_TL
    (
        RELATED_LINK_ID
      , USER_LINK_NAME
      , LANGUAGE
      , SOURCE_LANG
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
    )
    SELECT
        B.RELATED_LINK_ID
      , B.USER_LINK_NAME
      , L.LANGUAGE_CODE
      , B.SOURCE_LANG
      , B.CREATED_BY
      , B.CREATION_DATE
      , B.LAST_UPDATED_BY
      , B.LAST_UPDATE_DATE
      , B.LAST_UPDATE_LOGIN
   FROM  BIS_RELATED_LINKS_TL B, FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ('I', 'B')
   AND   B.LANGUAGE = USERENV('LANG')
   AND   NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_RELATED_LINKS_TL T
          WHERE  T.RELATED_LINK_ID = B.RELATED_LINK_ID
          AND    T.LANGUAGE           = L.LANGUAGE_CODE
        );

END Add_Language;

END BIS_RELATED_LINKS_MLS;

/
