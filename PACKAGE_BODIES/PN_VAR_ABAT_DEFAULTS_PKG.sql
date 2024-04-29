--------------------------------------------------------
--  DDL for Package Body PN_VAR_ABAT_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_ABAT_DEFAULTS_PKG" as
/* $Header: PNVRABDB.pls 120.0 2007/10/03 14:27:20 rthumma noship $ */
-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 12-SEP-06  piagrawa o Created
-------------------------------------------------------------------------------
procedure INSERT_ROW (
    X_ROWID                  in out NOCOPY VARCHAR2
   ,X_ABATEMENT_ID           in out NOCOPY NUMBER
   ,X_VAR_RENT_ID            in NUMBER
   ,X_START_DATE             in DATE
   ,X_END_DATE               in DATE
   ,X_TYPE_CODE              in VARCHAR2
   ,X_AMOUNT                 in NUMBER
   ,X_DESCRIPTION            in VARCHAR2
   ,X_LAST_UPDATE_DATE       in DATE
   ,X_LAST_UPDATED_BY        in NUMBER
   ,X_CREATION_DATE          in DATE
   ,X_CREATED_BY             in NUMBER
   ,X_LAST_UPDATE_LOGIN      in NUMBER
   ,X_COMMENTS               in VARCHAR2
   ,X_ATTRIBUTE_CATEGORY     in VARCHAR2
   ,X_ATTRIBUTE1             in VARCHAR2
   ,X_ATTRIBUTE2             in VARCHAR2
   ,X_ATTRIBUTE3             in VARCHAR2
   ,X_ATTRIBUTE4             in VARCHAR2
   ,X_ATTRIBUTE5             in VARCHAR2
   ,X_ATTRIBUTE6             in VARCHAR2
   ,X_ATTRIBUTE7             in VARCHAR2
   ,X_ATTRIBUTE8             in VARCHAR2
   ,X_ATTRIBUTE9             in VARCHAR2
   ,X_ATTRIBUTE10            in VARCHAR2
   ,X_ATTRIBUTE11            in VARCHAR2
   ,X_ATTRIBUTE12            in VARCHAR2
   ,X_ATTRIBUTE13            in VARCHAR2
   ,X_ATTRIBUTE14            in VARCHAR2
   ,X_ATTRIBUTE15            in VARCHAR2
   ,X_ORG_ID                 in NUMBER )
IS
   CURSOR C IS
      SELECT ROWID
      FROM   PN_VAR_ABAT_DEFAULTS_ALL
      WHERE  ABATEMENT_ID = X_ABATEMENT_ID;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_ABAT_DEFAULTS_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- Select the nextval for abatement/allowance id
   -------------------------------------------------------

   IF ( X_ABATEMENT_ID IS NULL) THEN
      SELECT  pn_var_abat_defaults_s.nextval
      INTO    X_ABATEMENT_ID
      FROM    dual;
   END IF;

   INSERT INTO PN_VAR_ABAT_DEFAULTS_ALL
   (
       ABATEMENT_ID
      ,VAR_RENT_ID
      ,START_DATE
      ,END_DATE
      ,TYPE_CODE
      ,AMOUNT
      ,DESCRIPTION
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,COMMENTS
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,ORG_ID
   )
   VALUES
   (
       X_ABATEMENT_ID
      ,X_VAR_RENT_ID
      ,X_START_DATE
      ,X_END_DATE
      ,X_TYPE_CODE
      ,X_AMOUNT
      ,X_DESCRIPTION
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_CREATION_DATE
      ,X_CREATED_BY
      ,X_LAST_UPDATE_LOGIN
      ,X_COMMENTS
      ,X_ATTRIBUTE_CATEGORY
      ,X_ATTRIBUTE1
      ,X_ATTRIBUTE2
      ,X_ATTRIBUTE3
      ,X_ATTRIBUTE4
      ,X_ATTRIBUTE5
      ,X_ATTRIBUTE6
      ,X_ATTRIBUTE7
      ,X_ATTRIBUTE8
      ,X_ATTRIBUTE9
      ,X_ATTRIBUTE10
      ,X_ATTRIBUTE11
      ,X_ATTRIBUTE12
      ,X_ATTRIBUTE13
      ,X_ATTRIBUTE14
      ,X_ATTRIBUTE15
      ,X_ORG_ID
   ) ;

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%NOTFOUND) THEN
   CLOSE c;
   RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   PNP_DEBUG_PKG.debug ('PN_VAR_ABAT_DEFAULTS_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 12-SEP-06  piagrawa o Created
-------------------------------------------------------------------------------
procedure LOCK_ROW (
    X_ABATEMENT_ID           in NUMBER
   ,X_VAR_RENT_ID            in NUMBER
   ,X_START_DATE             in DATE
   ,X_END_DATE               in DATE
   ,X_TYPE_CODE              in VARCHAR2
   ,X_AMOUNT                 in NUMBER
   ,X_DESCRIPTION            in VARCHAR2
   ,X_LAST_UPDATE_DATE       in DATE
   ,X_LAST_UPDATED_BY        in NUMBER
   ,X_CREATION_DATE          in DATE
   ,X_CREATED_BY             in NUMBER
   ,X_LAST_UPDATE_LOGIN      in NUMBER
   ,X_COMMENTS               in VARCHAR2
   ,X_ATTRIBUTE_CATEGORY     in VARCHAR2
   ,X_ATTRIBUTE1             in VARCHAR2
   ,X_ATTRIBUTE2             in VARCHAR2
   ,X_ATTRIBUTE3             in VARCHAR2
   ,X_ATTRIBUTE4             in VARCHAR2
   ,X_ATTRIBUTE5             in VARCHAR2
   ,X_ATTRIBUTE6             in VARCHAR2
   ,X_ATTRIBUTE7             in VARCHAR2
   ,X_ATTRIBUTE8             in VARCHAR2
   ,X_ATTRIBUTE9             in VARCHAR2
   ,X_ATTRIBUTE10            in VARCHAR2
   ,X_ATTRIBUTE11            in VARCHAR2
   ,X_ATTRIBUTE12            in VARCHAR2
   ,X_ATTRIBUTE13            in VARCHAR2
   ,X_ATTRIBUTE14            in VARCHAR2
   ,X_ATTRIBUTE15            in VARCHAR2
   ,X_ORG_ID                 in NUMBER)
IS

   CURSOR c1 IS
      SELECT *
      FROM PN_VAR_ABAT_DEFAULTS_ALL
      WHERE ABATEMENT_ID = X_ABATEMENT_ID
      FOR UPDATE OF ABATEMENT_ID NOWAIT;

    tlinfo c1%rowtype;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_ABAT_DEFAULTS_PKG.LOCK_ROW (+)');

   OPEN c1;
   FETCH c1 INTO tlinfo;
   IF (c1%notfound) THEN
      CLOSE c1;
      return;
   END IF;
   CLOSE c1;

   if (tlinfo.ABATEMENT_ID = X_ABATEMENT_ID) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ABATEMENT_ID', to_char(tlinfo.ABATEMENT_ID));
   end if;

   if ((tlinfo.VAR_RENT_ID = X_VAR_RENT_ID)
        OR ((tlinfo.VAR_RENT_ID is null) AND (X_VAR_RENT_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_ID', to_char(tlinfo.VAR_RENT_ID));
   end if;

   if ((tlinfo.START_DATE = X_START_DATE)
        OR ((tlinfo.START_DATE is null) AND (X_START_DATE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('START_DATE', to_char(tlinfo.START_DATE));
   end if;

   if ((tlinfo.END_DATE = X_END_DATE)
        OR ((tlinfo.END_DATE is null) AND (X_END_DATE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('END_DATE', to_char(tlinfo.END_DATE));
   end if;

   if ((tlinfo.TYPE_CODE = X_TYPE_CODE)
        OR ((tlinfo.TYPE_CODE is null) AND (X_TYPE_CODE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('TYPE_CODE', tlinfo.TYPE_CODE);
   end if;

   if ((tlinfo.AMOUNT = X_AMOUNT)
        OR ((tlinfo.AMOUNT is null) AND (X_AMOUNT is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AMOUNT', to_char(tlinfo.AMOUNT));
   end if;
   if ((tlinfo.DESCRIPTION = X_DESCRIPTION)
        OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('DESCRIPTION', to_char(tlinfo.DESCRIPTION));
   end if;

   if ((tlinfo.COMMENTS = X_COMMENTS)
        OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('COMMENTS', to_char(tlinfo.COMMENTS));
   end if;

   if ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
       OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE_CATEGORY',tlinfo.ATTRIBUTE_CATEGORY);
   end if;
   if ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
       OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   end if;
   if ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
       OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE2',tlinfo.ATTRIBUTE2);
   end if;
   if ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
       OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE3',tlinfo.ATTRIBUTE3);
   end if;
          if ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
       OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE4',tlinfo.ATTRIBUTE4);
   end if;
   if ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
       OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE5',tlinfo.ATTRIBUTE5);
   end if;
   if ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
       OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) then
      null;
          else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE6',tlinfo.ATTRIBUTE6);
   end if;
   if ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
       OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE7',tlinfo.ATTRIBUTE7);
   end if;
   if ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
       OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE8',tlinfo.ATTRIBUTE8);
   end if;
   if ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
       OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
   end if;
   if ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
       OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE10', tlinfo.ATTRIBUTE10);
   end if;
   if ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
       OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE11',tlinfo.ATTRIBUTE11);
   end if;
   if ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
       OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE12',tlinfo.ATTRIBUTE12);
   end if;
   if ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
       OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) then
      null;
   else
          PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE13',tlinfo.ATTRIBUTE13);
   end if;
   if ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
       OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE14',tlinfo.ATTRIBUTE14);
   end if;
   if ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
       OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
   end if;

   if ((tlinfo.ORG_ID = X_ORG_ID)
        OR ((tlinfo.ORG_ID is null) AND (X_ORG_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ORG_ID', to_char(tlinfo.ORG_ID));
   end if;

   PNP_DEBUG_PKG.debug ('PN_VAR_ABAT_DEFAULTS_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 12-SEP-06  piagrawa o Created
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
    X_ABATEMENT_ID           in NUMBER
   ,X_VAR_RENT_ID            in NUMBER
   ,X_START_DATE             in DATE
   ,X_END_DATE               in DATE
   ,X_TYPE_CODE              in VARCHAR2
   ,X_AMOUNT                 in NUMBER
   ,X_DESCRIPTION            in VARCHAR2
   ,X_LAST_UPDATE_DATE       in DATE
   ,X_LAST_UPDATED_BY        in NUMBER
   ,X_CREATION_DATE          in DATE
   ,X_CREATED_BY             in NUMBER
   ,X_LAST_UPDATE_LOGIN      in NUMBER
   ,X_COMMENTS               in VARCHAR2
   ,X_ATTRIBUTE_CATEGORY     in VARCHAR2
   ,X_ATTRIBUTE1             in VARCHAR2
   ,X_ATTRIBUTE2             in VARCHAR2
   ,X_ATTRIBUTE3             in VARCHAR2
   ,X_ATTRIBUTE4             in VARCHAR2
   ,X_ATTRIBUTE5             in VARCHAR2
   ,X_ATTRIBUTE6             in VARCHAR2
   ,X_ATTRIBUTE7             in VARCHAR2
   ,X_ATTRIBUTE8             in VARCHAR2
   ,X_ATTRIBUTE9             in VARCHAR2
   ,X_ATTRIBUTE10            in VARCHAR2
   ,X_ATTRIBUTE11            in VARCHAR2
   ,X_ATTRIBUTE12            in VARCHAR2
   ,X_ATTRIBUTE13            in VARCHAR2
   ,X_ATTRIBUTE14            in VARCHAR2
   ,X_ATTRIBUTE15            in VARCHAR2
   ,X_ORG_ID                 in NUMBER)
IS
BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_ABAT_DEFAULTS_PKG.UPDATE_ROW (+)');

   UPDATE PN_VAR_ABAT_DEFAULTS_ALL SET
       ABATEMENT_ID        = X_ABATEMENT_ID
      ,VAR_RENT_ID         = X_VAR_RENT_ID
      ,START_DATE          = X_START_DATE
      ,END_DATE            = X_END_DATE
      ,TYPE_CODE           = X_TYPE_CODE
      ,AMOUNT              = X_AMOUNT
      ,DESCRIPTION         = X_DESCRIPTION
      ,LAST_UPDATE_DATE    = X_LAST_UPDATE_DATE
      ,LAST_UPDATED_BY     = X_LAST_UPDATED_BY
      ,CREATION_DATE       = X_CREATION_DATE
      ,CREATED_BY          = X_CREATED_BY
      ,LAST_UPDATE_LOGIN   = X_LAST_UPDATE_LOGIN
      ,COMMENTS            = X_COMMENTS
      ,ATTRIBUTE_CATEGORY  = X_ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1          = X_ATTRIBUTE1
      ,ATTRIBUTE2          = X_ATTRIBUTE2
      ,ATTRIBUTE3          = X_ATTRIBUTE3
      ,ATTRIBUTE4          = X_ATTRIBUTE4
      ,ATTRIBUTE5          = X_ATTRIBUTE5
      ,ATTRIBUTE6          = X_ATTRIBUTE6
      ,ATTRIBUTE7          = X_ATTRIBUTE7
      ,ATTRIBUTE8          = X_ATTRIBUTE8
      ,ATTRIBUTE9          = X_ATTRIBUTE9
      ,ATTRIBUTE10         = X_ATTRIBUTE10
      ,ATTRIBUTE11         = X_ATTRIBUTE11
      ,ATTRIBUTE12         = X_ATTRIBUTE12
      ,ATTRIBUTE13         = X_ATTRIBUTE13
      ,ATTRIBUTE14         = X_ATTRIBUTE14
      ,ATTRIBUTE15         = X_ATTRIBUTE15
      ,ORG_ID              = X_ORG_ID
   WHERE ABATEMENT_ID = X_ABATEMENT_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_ABAT_DEFAULTS_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 12-SEP-06  piagrawa o Created
-------------------------------------------------------------------------------
procedure DELETE_ROW ( X_ABATEMENT_ID in NUMBER)
IS
BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_ABAT_DEFAULTS_PKG.DELETE_ROW (+)');

   DELETE FROM PN_VAR_ABAT_DEFAULTS_ALL
   WHERE  ABATEMENT_ID = X_ABATEMENT_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_ABAT_DEFAULTS_PKG.DELETE_ROW (-)');

END DELETE_ROW;

END PN_VAR_ABAT_DEFAULTS_PKG;

/
