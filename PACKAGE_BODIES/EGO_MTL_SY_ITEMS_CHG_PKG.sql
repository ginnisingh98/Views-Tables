--------------------------------------------------------
--  DDL for Package Body EGO_MTL_SY_ITEMS_CHG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_MTL_SY_ITEMS_CHG_PKG" AS
/* $Header: EGOCMSIB.pls 120.0 2005/11/04 16:51:32 sshrikha noship $ */
G_PKG_NAME       CONSTANT   VARCHAR2(30)  :=  'EGO_MTL_SY_ITEMS_CHG_PKG';

-- =============================================================================
--                   Package variables, constants and cursors
-- =============================================================================


-- ------------------- ADD_LANGUAGE --------------------

PROCEDURE ADD_LANGUAGE IS
BEGIN

/*   DELETE FROM MTL_SYSTEM_ITEMS_TL T
   WHERE  NOT EXISTS ( SELECT NULL
                       FROM   MTL_SYSTEM_ITEMS_B  B
                       WHERE  B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
                       AND    B.ORGANIZATION_ID   = T.ORGANIZATION_ID);

   UPDATE MTL_SYSTEM_ITEMS_TL T
   SET(  DESCRIPTION
      ,  LONG_DESCRIPTION) = (SELECT  ltrim(rtrim(B.DESCRIPTION))
   			           ,  ltrim(rtrim(B.LONG_DESCRIPTION))
		              FROM  MTL_SYSTEM_ITEMS_TL  B
                              WHERE B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
                              AND   B.ORGANIZATION_ID   = T.ORGANIZATION_ID
                              AND   B.LANGUAGE          = T.SOURCE_LANG)
   WHERE(T.INVENTORY_ITEM_ID
      ,  T.ORGANIZATION_ID
      ,  T.LANGUAGE) IN (SELECT  SUBT.INVENTORY_ITEM_ID,
                                 SUBT.ORGANIZATION_ID,
                                 SUBT.LANGUAGE
                         FROM    MTL_SYSTEM_ITEMS_TL  SUBB,
                                 MTL_SYSTEM_ITEMS_TL  SUBT
                         WHERE   SUBB.INVENTORY_ITEM_ID = SUBT.INVENTORY_ITEM_ID
                         AND     SUBB.ORGANIZATION_ID = SUBT.ORGANIZATION_ID
                         AND     SUBB.LANGUAGE = SUBT.SOURCE_LANG
                         AND  (( SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                                or ( SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null )
                                or ( SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null ) )
                         OR   ( SUBB.LONG_DESCRIPTION <> SUBT.LONG_DESCRIPTION
                           or ( SUBB.LONG_DESCRIPTION is null and SUBT.LONG_DESCRIPTION is not null )
                           or ( SUBB.LONG_DESCRIPTION is not null and SUBT.LONG_DESCRIPTION is null ))));

*/
   INSERT INTO EGO_MTL_SY_ITEMS_CHG_TL  (
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    DESCRIPTION,
    LONG_DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    CHANGE_ID,
    CHANGE_LINE_ID,
    ACD_TYPE,
    IMPLEMENTATION_DATE)
   SELECT
    B.INVENTORY_ITEM_ID,
    B.ORGANIZATION_ID,
    ltrim(rtrim(B.DESCRIPTION)),
    ltrim(rtrim(B.LONG_DESCRIPTION)),
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.CHANGE_ID,
    B.CHANGE_LINE_ID,
    B.ACD_TYPE,
    B.IMPLEMENTATION_DATE
   FROM EGO_MTL_SY_ITEMS_CHG_TL  B,
        FND_LANGUAGES        L
   WHERE L.INSTALLED_FLAG in ('I', 'B')
   AND   B.LANGUAGE = userenv('LANG')
   AND   NOT EXISTS( SELECT NULL
                     FROM   EGO_MTL_SY_ITEMS_CHG_TL  T
                     WHERE  T.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
                     AND    T.ORGANIZATION_ID   = B.ORGANIZATION_ID
                     AND    T.LANGUAGE          = L.LANGUAGE_CODE);


   COMMIT;

END ADD_LANGUAGE;







END EGO_MTL_SY_ITEMS_CHG_PKG;

/
