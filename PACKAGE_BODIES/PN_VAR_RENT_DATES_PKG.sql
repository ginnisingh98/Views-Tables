--------------------------------------------------------
--  DDL for Package Body PN_VAR_RENT_DATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_RENT_DATES_PKG" as
/* $Header: PNVRDATB.pls 120.3 2006/12/20 09:27:23 pseeram noship $ */
-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_RENT_DATES with _ALL
--                       table.
-------------------------------------------------------------------------------
procedure INSERT_ROW (
                        X_ROWID                 in out NOCOPY VARCHAR2,
                        X_VAR_RENT_DATE_ID      in out NOCOPY NUMBER,
                        X_VAR_RENT_ID           in NUMBER,
                        X_GL_PERIOD_SET_NAME    in VARCHAR2,
                        X_PERIOD_FREQ_CODE      in VARCHAR2,
                        X_REPTG_FREQ_CODE       in VARCHAR2,
                        X_REPTG_DAY_OF_MONTH    in NUMBER,
                        X_REPTG_DAYS_AFTER      in NUMBER,
                        X_INVG_FREQ_CODE        in VARCHAR2,
                        X_INVG_DAY_OF_MONTH     in NUMBER,
                        X_INVG_DAYS_AFTER       in NUMBER,
                        X_INVG_SPREAD_CODE      in VARCHAR2,
                        X_INVG_TERM             in NUMBER,
                        X_AUDIT_FREQ_CODE       in VARCHAR2,
                        X_AUDIT_DAY_OF_MONTH    in NUMBER,
                        X_AUDIT_DAYS_AFTER      in NUMBER,
                        X_RECON_FREQ_CODE       in VARCHAR2,
                        X_RECON_DAY_OF_MONTH    in NUMBER,
                        X_RECON_DAYS_AFTER      in NUMBER,
                        X_ATTRIBUTE_CATEGORY    in VARCHAR2,
                        X_ATTRIBUTE1            in VARCHAR2,
                        X_ATTRIBUTE2            in VARCHAR2,
                        X_ATTRIBUTE3            in VARCHAR2,
                        X_ATTRIBUTE4            in VARCHAR2,
                        X_ATTRIBUTE5            in VARCHAR2,
                        X_ATTRIBUTE6            in VARCHAR2,
                        X_ATTRIBUTE7            in VARCHAR2,
                        X_ATTRIBUTE8            in VARCHAR2,
                        X_ATTRIBUTE9            in VARCHAR2,
                        X_ATTRIBUTE10           in VARCHAR2,
                        X_ATTRIBUTE11           in VARCHAR2,
                        X_ATTRIBUTE12           in VARCHAR2,
                        X_ATTRIBUTE13           in VARCHAR2,
                        X_ATTRIBUTE14           in VARCHAR2,
                        X_ATTRIBUTE15           in VARCHAR2,
                        X_ORG_ID                in NUMBER,
                        X_CREATION_DATE         in DATE,
                        X_CREATED_BY            in NUMBER,
                        X_LAST_UPDATE_DATE      in DATE,
                        X_LAST_UPDATED_BY       in NUMBER,
                        X_LAST_UPDATE_LOGIN     in NUMBER,
                        X_USE_GL_CALENDAR       in VARCHAR2,
                        X_PERIOD_TYPE           in VARCHAR2,
                        X_YEAR_START_DATE       in DATE,
                        X_COMMENTS              in VARCHAR2,
                        X_VRG_REPTG_FREQ_CODE   in VARCHAR2
                        )
IS

   CURSOR var_rent_dates IS
      SELECT ROWID
      FROM   PN_VAR_RENT_DATES_ALL
      WHERE  VAR_RENT_DATE_ID = X_VAR_RENT_DATE_ID;

   CURSOR org_cur IS
     SELECT org_id FROM PN_VAR_RENTS_ALL WHERE VAR_RENT_ID = X_VAR_RENT_ID;
   l_org_ID NUMBER;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_DATES_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- Select the nextval for var rent date id
   -------------------------------------------------------
   IF ( X_VAR_RENT_DATE_ID IS NULL) THEN
      SELECT  pn_var_rent_dates_s.nextval
      INTO    X_VAR_RENT_DATE_ID
      FROM    dual;
   END IF;

   IF x_org_id IS NULL THEN
      FOR rec IN org_cur LOOP
         l_org_id := rec.org_id;
      END LOOP;
   ELSE
      l_org_id := x_org_id;
   END IF;

   INSERT INTO PN_VAR_RENT_DATES_ALL
   (
      VAR_RENT_DATE_ID,
      VAR_RENT_ID,
      GL_PERIOD_SET_NAME,
      PERIOD_FREQ_CODE,
      REPTG_FREQ_CODE,
      REPTG_DAY_OF_MONTH,
      REPTG_DAYS_AFTER,
      INVG_FREQ_CODE,
      INVG_DAY_OF_MONTH,
      INVG_DAYS_AFTER,
      INVG_SPREAD_CODE,
      INVG_TERM,
      AUDIT_FREQ_CODE,
      AUDIT_DAY_OF_MONTH,
      AUDIT_DAYS_AFTER,
      RECON_FREQ_CODE,
      RECON_DAY_OF_MONTH,
      RECON_DAYS_AFTER,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ORG_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      USE_GL_CALENDAR,
      PERIOD_TYPE,
      YEAR_START_DATE,
      COMMENTS,
      VRG_REPTG_FREQ_CODE
   )
   VALUES
   (
      X_VAR_RENT_DATE_ID,
      X_VAR_RENT_ID,
      X_GL_PERIOD_SET_NAME,
      X_PERIOD_FREQ_CODE,
      X_REPTG_FREQ_CODE,
      X_REPTG_DAY_OF_MONTH,
      X_REPTG_DAYS_AFTER,
      X_INVG_FREQ_CODE,
      X_INVG_DAY_OF_MONTH,
      X_INVG_DAYS_AFTER,
      X_INVG_SPREAD_CODE,
      X_INVG_TERM,
      X_AUDIT_FREQ_CODE,
      X_AUDIT_DAY_OF_MONTH,
      X_AUDIT_DAYS_AFTER,
      X_RECON_FREQ_CODE,
      X_RECON_DAY_OF_MONTH,
      X_RECON_DAYS_AFTER,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15,
      l_org_id,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_USE_GL_CALENDAR,
      X_PERIOD_TYPE,
      X_YEAR_START_DATE,
      X_COMMENTS,
      X_VRG_REPTG_FREQ_CODE
   );

   OPEN var_rent_dates;
   FETCH var_rent_dates INTO X_ROWID;
   IF (var_rent_dates%notfound) THEN
      CLOSE var_rent_dates;
      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE var_rent_dates;

   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_DATES_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 Replaced PN_VAR_RENT_DATES with _ALL
-- 21-SEP-06  pikhar   o Bug 5531068 Removed call to audit_freq_code,
--                       recon_freq_code and invg_spread_code
-------------------------------------------------------------------------------
procedure LOCK_ROW (
                       X_VAR_RENT_DATE_ID    IN NUMBER,
                       X_VAR_RENT_ID         IN NUMBER,
                       X_GL_PERIOD_SET_NAME  IN VARCHAR2,
                       X_PERIOD_FREQ_CODE    IN VARCHAR2,
                       X_REPTG_FREQ_CODE     IN VARCHAR2,
                       X_REPTG_DAY_OF_MONTH  IN NUMBER,
                       X_REPTG_DAYS_AFTER    IN NUMBER,
                       X_INVG_FREQ_CODE      IN VARCHAR2,
                       X_INVG_DAY_OF_MONTH   IN NUMBER,
                       X_INVG_DAYS_AFTER     IN NUMBER,
                       X_INVG_SPREAD_CODE    IN VARCHAR2,
                       X_INVG_TERM           IN NUMBER,
                       X_AUDIT_FREQ_CODE     IN VARCHAR2,
                       X_AUDIT_DAY_OF_MONTH  IN NUMBER,
                       X_AUDIT_DAYS_AFTER    IN NUMBER,
                       X_RECON_FREQ_CODE     IN VARCHAR2,
                       X_RECON_DAY_OF_MONTH  IN NUMBER,
                       X_RECON_DAYS_AFTER    IN NUMBER,
                       X_ATTRIBUTE_CATEGORY  IN VARCHAR2,
                       X_ATTRIBUTE1          IN VARCHAR2,
                       X_ATTRIBUTE2          IN VARCHAR2,
                       X_ATTRIBUTE3          IN VARCHAR2,
                       X_ATTRIBUTE4          IN VARCHAR2,
                       X_ATTRIBUTE5          IN VARCHAR2,
                       X_ATTRIBUTE6          IN VARCHAR2,
                       X_ATTRIBUTE7          IN VARCHAR2,
                       X_ATTRIBUTE8          IN VARCHAR2,
                       X_ATTRIBUTE9          IN VARCHAR2,
                       X_ATTRIBUTE10         IN VARCHAR2,
                       X_ATTRIBUTE11         IN VARCHAR2,
                       X_ATTRIBUTE12         IN VARCHAR2,
                       X_ATTRIBUTE13         IN VARCHAR2,
                       X_ATTRIBUTE14         IN VARCHAR2,
                       X_ATTRIBUTE15         IN VARCHAR2,
                       X_USE_GL_CALENDAR     IN VARCHAR2,
                       X_PERIOD_TYPE         IN VARCHAR2,
                       X_YEAR_START_DATE     IN DATE,
                       X_COMMENTS            IN VARCHAR2,
                       X_VRG_REPTG_FREQ_CODE IN VARCHAR2
                )
IS
   CURSOR c1 IS
      SELECT *
      FROM PN_VAR_RENT_DATES_ALL
      WHERE VAR_RENT_DATE_ID = X_VAR_RENT_DATE_ID
      FOR UPDATE OF VAR_RENT_DATE_ID NOWAIT;

   tlinfo c1%rowtype;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_DATES_PKG.LOCK_ROW (+)');

   OPEN c1;
   FETCH c1 INTO tlinfo;
   IF (c1%notfound) THEN
      CLOSE c1;
      RETURN;
   END IF;
   CLOSE c1;

   if (tlinfo.VAR_RENT_DATE_ID = X_VAR_RENT_DATE_ID) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_DATE_ID', to_char(tlinfo.VAR_RENT_DATE_ID));
   end if;
   if (tlinfo.VAR_RENT_ID = X_VAR_RENT_ID) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_ID', to_char(tlinfo.VAR_RENT_ID));
   end if;
   if ((tlinfo.GL_PERIOD_SET_NAME = X_GL_PERIOD_SET_NAME)
       OR ((tlinfo.GL_PERIOD_SET_NAME is null) and (X_GL_PERIOD_SET_NAME is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('GL_PERIOD_SET_NAME', tlinfo.GL_PERIOD_SET_NAME);
   end if;
   if (tlinfo.PERIOD_FREQ_CODE = X_PERIOD_FREQ_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_FREQ_CODE', tlinfo.PERIOD_FREQ_CODE);
   end if;
   if (tlinfo.REPTG_FREQ_CODE = X_REPTG_FREQ_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('REPTG_FREQ_CODE', tlinfo.REPTG_FREQ_CODE);
   end if;
   if ((tlinfo.REPTG_DAY_OF_MONTH = X_REPTG_DAY_OF_MONTH)
        OR ((tlinfo.REPTG_DAY_OF_MONTH is null) AND (X_REPTG_DAY_OF_MONTH is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('REPTG_DAY_OF_MONTH', to_char(tlinfo.REPTG_DAY_OF_MONTH));
   end if;
   if ((tlinfo.REPTG_DAYS_AFTER = X_REPTG_DAYS_AFTER)
        OR ((tlinfo.REPTG_DAYS_AFTER is null) AND (X_REPTG_DAYS_AFTER is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('REPTG_DAYS_AFTER', to_char(tlinfo.REPTG_DAYS_AFTER));
   end if;
   if (tlinfo.INVG_FREQ_CODE = X_INVG_FREQ_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_FREQ_CODE', tlinfo.INVG_FREQ_CODE);
   end if;
   if ((tlinfo.INVG_DAY_OF_MONTH = X_INVG_DAY_OF_MONTH)
        OR ((tlinfo.INVG_DAY_OF_MONTH is null) AND (X_INVG_DAY_OF_MONTH is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_DAY_OF_MONTH', to_char(tlinfo.INVG_DAY_OF_MONTH));
   end if;
   if ((tlinfo.INVG_DAYS_AFTER = X_INVG_DAYS_AFTER)
        OR ((tlinfo.INVG_DAYS_AFTER is null) AND (X_INVG_DAYS_AFTER is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_DAYS_AFTER', to_char(tlinfo.INVG_DAYS_AFTER));
   end if;
   /*if (tlinfo.INVG_SPREAD_CODE = X_INVG_SPREAD_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_SPREAD_CODE', tlinfo.INVG_SPREAD_CODE);
   end if;*/
   if ((tlinfo.INVG_TERM = X_INVG_TERM)
        OR ((tlinfo.INVG_TERM is null) AND (X_INVG_TERM is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVG_TERM', tlinfo.INVG_TERM);
   end if;
   /*if (tlinfo.AUDIT_FREQ_CODE = X_AUDIT_FREQ_CODE)  then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AUDIT_FREQ_CODE', tlinfo.AUDIT_FREQ_CODE);
   end if;*/
   if ((tlinfo.AUDIT_DAY_OF_MONTH = X_AUDIT_DAY_OF_MONTH)
        OR ((tlinfo.AUDIT_DAY_OF_MONTH is null) AND (X_AUDIT_DAY_OF_MONTH is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AUDIT_DAY_OF_MONTH', to_char(tlinfo.AUDIT_DAY_OF_MONTH));
   end if;
   if ((tlinfo.AUDIT_DAYS_AFTER = X_AUDIT_DAYS_AFTER)
        OR ((tlinfo.AUDIT_DAYS_AFTER is null) AND (X_AUDIT_DAYS_AFTER is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AUDIT_DAYS_AFTER', to_char(tlinfo.AUDIT_DAYS_AFTER));
   end if;
   /*if (tlinfo.RECON_FREQ_CODE = X_RECON_FREQ_CODE)  then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('RECON_FREQ_CODE', tlinfo.RECON_FREQ_CODE);
   end if;*/
   if ((tlinfo.RECON_DAY_OF_MONTH = X_RECON_DAY_OF_MONTH)
        OR ((tlinfo.RECON_DAY_OF_MONTH is null) AND (X_RECON_DAY_OF_MONTH is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('RECON_DAY_OF_MONTH', to_char(tlinfo.RECON_DAY_OF_MONTH));
   end if;
   if ((tlinfo.RECON_DAYS_AFTER = X_RECON_DAYS_AFTER)
        OR ((tlinfo.RECON_DAYS_AFTER is null) AND (X_RECON_DAYS_AFTER is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('RECON_DAYS_AFTER', to_char(tlinfo.RECON_DAYS_AFTER));
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

   if ((tlinfo.USE_GL_CALENDAR = X_USE_GL_CALENDAR)
       OR ((tlinfo.USE_GL_CALENDAR is null) AND (X_USE_GL_CALENDAR is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('USE_GL_CALENDAR',tlinfo.USE_GL_CALENDAR);
   end if;

   if ((tlinfo.PERIOD_TYPE = X_PERIOD_TYPE)
       OR ((tlinfo.PERIOD_TYPE is null) AND (X_PERIOD_TYPE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_TYPE',tlinfo.PERIOD_TYPE);
   end if;

   if ((tlinfo.YEAR_START_DATE = X_YEAR_START_DATE)
       OR ((tlinfo.YEAR_START_DATE is null) AND (X_YEAR_START_DATE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('YEAR_START_DATE',tlinfo.YEAR_START_DATE);
   end if;

   if ((tlinfo.COMMENTS = X_COMMENTS)
       OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('COMMENTS',tlinfo.COMMENTS);
   end if;

   if ((tlinfo.VRG_REPTG_FREQ_CODE = X_VRG_REPTG_FREQ_CODE)
       OR ((tlinfo.VRG_REPTG_FREQ_CODE is null) AND (X_VRG_REPTG_FREQ_CODE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VRG_REPTG_FREQ_CODE',tlinfo.VRG_REPTG_FREQ_CODE);
   end if;

   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_DATES_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_RENT_DATES with _ALL
--                       table.
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
                        X_VAR_RENT_DATE_ID      in NUMBER,
                        X_VAR_RENT_ID           in NUMBER,
                        X_GL_PERIOD_SET_NAME    in VARCHAR2,
                        X_PERIOD_FREQ_CODE      in VARCHAR2,
                        X_REPTG_FREQ_CODE       in VARCHAR2,
                        X_REPTG_DAY_OF_MONTH    in NUMBER,
                        X_REPTG_DAYS_AFTER      in NUMBER,
                        X_INVG_FREQ_CODE        in VARCHAR2,
                        X_INVG_DAY_OF_MONTH     in NUMBER,
                        X_INVG_DAYS_AFTER       in NUMBER,
                        X_INVG_SPREAD_CODE      in VARCHAR2,
                        X_INVG_TERM             in NUMBER,
                        X_AUDIT_FREQ_CODE       in VARCHAR2,
                        X_AUDIT_DAY_OF_MONTH    in NUMBER,
                        X_AUDIT_DAYS_AFTER      in NUMBER,
                        X_RECON_FREQ_CODE       in VARCHAR2,
                        X_RECON_DAY_OF_MONTH    in NUMBER,
                        X_RECON_DAYS_AFTER      in NUMBER,
                        X_ATTRIBUTE_CATEGORY    in VARCHAR2,
                        X_ATTRIBUTE1            in VARCHAR2,
                        X_ATTRIBUTE2            in VARCHAR2,
                        X_ATTRIBUTE3            in VARCHAR2,
                        X_ATTRIBUTE4            in VARCHAR2,
                        X_ATTRIBUTE5            in VARCHAR2,
                        X_ATTRIBUTE6            in VARCHAR2,
                        X_ATTRIBUTE7            in VARCHAR2,
                        X_ATTRIBUTE8            in VARCHAR2,
                        X_ATTRIBUTE9            in VARCHAR2,
                        X_ATTRIBUTE10           in VARCHAR2,
                        X_ATTRIBUTE11           in VARCHAR2,
                        X_ATTRIBUTE12           in VARCHAR2,
                        X_ATTRIBUTE13           in VARCHAR2,
                        X_ATTRIBUTE14           in VARCHAR2,
                        X_ATTRIBUTE15           in VARCHAR2,
                        X_LAST_UPDATE_DATE      in DATE,
                        X_LAST_UPDATED_BY       in NUMBER,
                        X_LAST_UPDATE_LOGIN     in NUMBER,
                        X_USE_GL_CALENDAR       in VARCHAR2,
                        X_PERIOD_TYPE           in VARCHAR2,
                        X_YEAR_START_DATE       in DATE,
                        X_COMMENTS              in VARCHAR2,
                        X_VRG_REPTG_FREQ_CODE   in VARCHAR2
                )
IS
BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_DATES_PKG.UPDATE_ROW (+)');

   UPDATE PN_VAR_RENT_DATES_ALL
   SET
      VAR_RENT_DATE_ID          = X_VAR_RENT_DATE_ID,
      VAR_RENT_ID               = X_VAR_RENT_ID,
      GL_PERIOD_SET_NAME        = X_GL_PERIOD_SET_NAME,
      PERIOD_FREQ_CODE          = X_PERIOD_FREQ_CODE,
      REPTG_FREQ_CODE           = X_REPTG_FREQ_CODE,
      REPTG_DAY_OF_MONTH        = X_REPTG_DAY_OF_MONTH,
      REPTG_DAYS_AFTER          = X_REPTG_DAYS_AFTER,
      INVG_FREQ_CODE            = X_INVG_FREQ_CODE,
      INVG_DAY_OF_MONTH         = X_INVG_DAY_OF_MONTH,
      INVG_DAYS_AFTER           = X_INVG_DAYS_AFTER,
      INVG_SPREAD_CODE          = X_INVG_SPREAD_CODE,
      INVG_TERM                 = X_INVG_TERM,
      AUDIT_FREQ_CODE           = X_AUDIT_FREQ_CODE,
      AUDIT_DAY_OF_MONTH        = X_AUDIT_DAY_OF_MONTH,
      AUDIT_DAYS_AFTER          = X_AUDIT_DAYS_AFTER,
      RECON_FREQ_CODE           = X_RECON_FREQ_CODE,
      RECON_DAY_OF_MONTH        = X_RECON_DAY_OF_MONTH,
      RECON_DAYS_AFTER          = X_RECON_DAYS_AFTER,
      ATTRIBUTE_CATEGORY        = X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1                = X_ATTRIBUTE1,
      ATTRIBUTE2                = X_ATTRIBUTE2,
      ATTRIBUTE3                = X_ATTRIBUTE3,
      ATTRIBUTE4                = X_ATTRIBUTE4,
      ATTRIBUTE5                = X_ATTRIBUTE5,
      ATTRIBUTE6                = X_ATTRIBUTE6,
      ATTRIBUTE7                = X_ATTRIBUTE7,
      ATTRIBUTE8                = X_ATTRIBUTE8,
      ATTRIBUTE9                = X_ATTRIBUTE9,
      ATTRIBUTE10               = X_ATTRIBUTE10,
      ATTRIBUTE11               = X_ATTRIBUTE11,
      ATTRIBUTE12               = X_ATTRIBUTE12,
      ATTRIBUTE13               = X_ATTRIBUTE13,
      ATTRIBUTE14               = X_ATTRIBUTE14,
      ATTRIBUTE15               = X_ATTRIBUTE15,
      LAST_UPDATE_DATE          = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY           = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN         = X_LAST_UPDATE_LOGIN,
      USE_GL_CALENDAR           = X_USE_GL_CALENDAR,
      PERIOD_TYPE               = X_PERIOD_TYPE,
      YEAR_START_DATE           = X_YEAR_START_DATE,
      COMMENTS                  = X_COMMENTS,
      VRG_REPTG_FREQ_CODE       = X_VRG_REPTG_FREQ_CODE
   WHERE VAR_RENT_DATE_ID       = X_VAR_RENT_DATE_ID   ;

   IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_DATES_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_RENT_DATES with _ALL
--                       table.
-------------------------------------------------------------------------------

procedure DELETE_ROW
        (
            X_VAR_RENT_DATE_ID in NUMBER
        )
IS
BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_DATES_PKG.DELETE_ROW (+)');

   DELETE FROM PN_VAR_RENT_DATES_ALL
   WHERE VAR_RENT_DATE_ID = X_VAR_RENT_DATE_ID;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_DATES_PKG.DELETE_ROW (-)');

END DELETE_ROW;

END PN_VAR_RENT_DATES_PKG;

/
