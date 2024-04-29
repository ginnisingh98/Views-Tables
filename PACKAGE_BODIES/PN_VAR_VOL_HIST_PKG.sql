--------------------------------------------------------
--  DDL for Package Body PN_VAR_VOL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_VOL_HIST_PKG" as
/* $Header: PNVRHISB.pls 120.2 2006/12/20 07:28:41 rdonthul noship $ */

-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_VOL_HIST with _ALL table.
-------------------------------------------------------------------------------
procedure INSERT_ROW (
   X_ROWID                IN out NOCOPY VARCHAR2,
   X_VOL_HIST_ID          IN out NOCOPY NUMBER,
   X_VOL_HIST_NUM         IN out NOCOPY NUMBER,
   X_LINE_ITEM_ID         IN NUMBER,
   X_PERIOD_ID            IN NUMBER,
   X_START_DATE           IN DATE,
   X_END_DATE             IN DATE,
   X_GRP_DATE_ID          IN NUMBER,
   X_GROUP_DATE           IN DATE,
   X_REPORTING_DATE       IN DATE,
   X_DUE_DATE             IN DATE,
   X_INVOICING_DATE       IN DATE,
   X_ACTUAL_GL_ACCOUNT_ID IN NUMBER,
   X_ACTUAL_AMOUNT        IN NUMBER,
   X_DAILY_ACTUAL_AMOUNT  in NUMBER,
   X_VOL_HIST_STATUS_CODE IN VARCHAR2,
   X_REPORT_TYPE_CODE     IN VARCHAR2,
   X_CERTIFIED_BY         IN NUMBER,
   X_ACTUAL_EXP_CODE      IN VARCHAR2,
   X_FOR_GL_ACCOUNT_ID    IN NUMBER,
   X_FORECASTED_AMOUNT    IN NUMBER,
   X_FORECASTED_EXP_CODE  IN VARCHAR2,
   X_VARIANCE_EXP_CODE    IN VARCHAR2,
   X_COMMENTS             IN VARCHAR2,
   X_ATTRIBUTE_CATEGORY   IN VARCHAR2,
   X_ATTRIBUTE1           IN VARCHAR2,
   X_ATTRIBUTE2           IN VARCHAR2,
   X_ATTRIBUTE3           IN VARCHAR2,
   X_ATTRIBUTE4           IN VARCHAR2,
   X_ATTRIBUTE5           IN VARCHAR2,
   X_ATTRIBUTE6           IN VARCHAR2,
   X_ATTRIBUTE7           IN VARCHAR2,
   X_ATTRIBUTE8           IN VARCHAR2,
   X_ATTRIBUTE9           IN VARCHAR2,
   X_ATTRIBUTE10          IN VARCHAR2,
   X_ATTRIBUTE11          IN VARCHAR2,
   X_ATTRIBUTE12          IN VARCHAR2,
   X_ATTRIBUTE13          IN VARCHAR2,
   X_ATTRIBUTE14          IN VARCHAR2,
   X_ATTRIBUTE15          IN VARCHAR2,
   X_ORG_ID               IN NUMBER,
   X_CREATION_DATE        IN DATE,
   X_CREATED_BY           IN NUMBER,
   X_LAST_UPDATE_DATE     IN DATE,
   X_LAST_UPDATED_BY      IN NUMBER,
   X_LAST_UPDATE_LOGIN    IN NUMBER
)
IS
   CURSOR C IS
      SELECT ROWID
      FROM PN_VAR_VOL_HIST_ALL
      WHERE VOL_HIST_ID = X_VOL_HIST_ID;

   l_return_daily_amount   NUMBER := 0;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- We need to generate the volume history number
   -------------------------------------------------------
   SELECT  nvl(max(hist.VOL_HIST_NUM),0)
   INTO    X_VOL_HIST_NUM
   FROM    PN_VAR_VOL_HIST_ALL hist
   WHERE   hist.LINE_ITEM_ID    =  X_LINE_ITEM_ID;

   X_VOL_HIST_NUM    := X_VOL_HIST_NUM + 1;

   -------------------------------------------------------
   -- Select the nextval for volume history id
   -------------------------------------------------------
   IF ( X_VOL_HIST_ID IS NULL) THEN
      SELECT  pn_var_vol_hist_s.nextval
      INTO    X_VOL_HIST_ID
      FROM    dual;
   END IF;

   -------------------------------------------------------
   -- Calculate daily amount for change calendar function
   ------------------------------------------------------
   PN_VAR_VOL_HIST_PKG.CALCULATE_DAILY_AMOUNT( l_return_daily_amount,
                                               X_ACTUAL_AMOUNT,
                                               X_START_DATE,
                                               X_END_DATE
                                             );

   INSERT INTO PN_VAR_VOL_HIST_ALL
   (
      VOL_HIST_ID,
      VOL_HIST_NUM,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      LINE_ITEM_ID,
      PERIOD_ID,
      START_DATE,
      END_DATE,
      GRP_DATE_ID,
      GROUP_DATE,
      REPORTING_DATE,
      DUE_DATE,
      INVOICING_DATE,
      ACTUAL_GL_ACCOUNT_ID,
      ACTUAL_AMOUNT,
      DAILY_ACTUAL_AMOUNT,
      VOL_HIST_STATUS_CODE,
      REPORT_TYPE_CODE,
      CERTIFIED_BY,
      ACTUAL_EXP_CODE,
      FOR_GL_ACCOUNT_ID,
      FORECASTED_AMOUNT,
      FORECASTED_EXP_CODE,
      VARIANCE_EXP_CODE,
      COMMENTS,
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
      ORG_ID
   )
   VALUES
   (
      X_VOL_HIST_ID,
      X_VOL_HIST_NUM,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_LINE_ITEM_ID,
      X_PERIOD_ID,
      X_START_DATE,
      X_END_DATE,
      X_GRP_DATE_ID,
      X_GROUP_DATE,
      X_REPORTING_DATE,
      X_DUE_DATE,
      X_INVOICING_DATE,
      X_ACTUAL_GL_ACCOUNT_ID,
      X_ACTUAL_AMOUNT,
      l_return_daily_amount,
      X_VOL_HIST_STATUS_CODE,
      X_REPORT_TYPE_CODE,
      X_CERTIFIED_BY,
      X_ACTUAL_EXP_CODE,
      X_FOR_GL_ACCOUNT_ID,
      X_FORECASTED_AMOUNT,
      X_FORECASTED_EXP_CODE,
      X_VARIANCE_EXP_CODE,
      X_COMMENTS,
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
      X_ORG_ID
   ) ;

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%notfound) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   UPDATE pn_var_lines_all
   SET sales_vol_update_flag = 'Y'
   WHERE line_item_id = x_line_item_id;

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_VOL_HIST with _ALL table.
-------------------------------------------------------------------------------
procedure LOCK_ROW (
   X_VOL_HIST_ID          IN NUMBER,
   X_VOL_HIST_NUM         IN NUMBER,
   X_LINE_ITEM_ID         IN NUMBER,
   X_PERIOD_ID            IN NUMBER,
   X_START_DATE           IN DATE,
   X_END_DATE             IN DATE,
   X_GRP_DATE_ID          IN NUMBER,
   X_GROUP_DATE           IN DATE,
   X_REPORTING_DATE       IN DATE,
   X_DUE_DATE             IN DATE,
   X_INVOICING_DATE       IN DATE,
   X_ACTUAL_GL_ACCOUNT_ID IN NUMBER,
   X_ACTUAL_AMOUNT        IN NUMBER,
   X_VOL_HIST_STATUS_CODE IN VARCHAR2,
   X_REPORT_TYPE_CODE     IN VARCHAR2,
   X_CERTIFIED_BY         IN NUMBER,
   X_ACTUAL_EXP_CODE      IN VARCHAR2,
   X_FOR_GL_ACCOUNT_ID    IN NUMBER,
   X_FORECASTED_AMOUNT    IN NUMBER,
   X_FORECASTED_EXP_CODE  IN VARCHAR2,
   X_VARIANCE_EXP_CODE    IN VARCHAR2,
   X_COMMENTS             IN VARCHAR2,
   X_ATTRIBUTE_CATEGORY   IN VARCHAR2,
   X_ATTRIBUTE1           IN VARCHAR2,
   X_ATTRIBUTE2           IN VARCHAR2,
   X_ATTRIBUTE3           IN VARCHAR2,
   X_ATTRIBUTE4           IN VARCHAR2,
   X_ATTRIBUTE5           IN VARCHAR2,
   X_ATTRIBUTE6           IN VARCHAR2,
   X_ATTRIBUTE7           IN VARCHAR2,
   X_ATTRIBUTE8           IN VARCHAR2,
   X_ATTRIBUTE9           IN VARCHAR2,
   X_ATTRIBUTE10          IN VARCHAR2,
   X_ATTRIBUTE11          IN VARCHAR2,
   X_ATTRIBUTE12          IN VARCHAR2,
   X_ATTRIBUTE13          IN VARCHAR2,
   X_ATTRIBUTE14          IN VARCHAR2,
   X_ATTRIBUTE15          IN VARCHAR2
  )
IS

   CURSOR c1 IS
      SELECT *
      FROM  PN_VAR_VOL_HIST_ALL
      WHERE VOL_HIST_ID = X_VOL_HIST_ID
      FOR UPDATE OF VOL_HIST_ID NOWAIT;

   tlinfo c1%rowtype;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.LOCK_ROW (+)');

   OPEN c1;
   FETCH c1 INTO tlinfo;
   IF (c1%notfound) THEN
      CLOSE c1;
      RETURN;
   END IF;
   CLOSE c1;

   if (tlinfo.VOL_HIST_ID = X_VOL_HIST_ID) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VOL_HIST_ID',tlinfo.VOL_HIST_ID);
   end if;
   if (tlinfo.VOL_HIST_NUM = X_VOL_HIST_NUM) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VOL_HIST_NUM',tlinfo.VOL_HIST_NUM);
   end if;
   if ((tlinfo.LINE_ITEM_ID = X_LINE_ITEM_ID)
        OR ((tlinfo.LINE_ITEM_ID is null) AND (X_LINE_ITEM_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LINE_ITEM_ID',tlinfo.LINE_ITEM_ID);
   end if;
   if ((tlinfo.PERIOD_ID = X_PERIOD_ID)
        OR ((tlinfo.PERIOD_ID is null) AND (X_PERIOD_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_ID',tlinfo.PERIOD_ID);
   end if;
   if (tlinfo.START_DATE = X_START_DATE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('START_DATE',tlinfo.START_DATE);
   end if;
   if (tlinfo.END_DATE = X_END_DATE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('END_DATE',tlinfo.END_DATE);
   end if;
   if ((tlinfo.GRP_DATE_ID = X_GRP_DATE_ID)
        OR ((tlinfo.GRP_DATE_ID is null) AND (X_GRP_DATE_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('GRP_DATE_ID',tlinfo.GRP_DATE_ID);
   end if;
   if (tlinfo.GROUP_DATE = X_GROUP_DATE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('GROUP_DATE',tlinfo.GROUP_DATE);
   end if;
   if ((tlinfo.REPORTING_DATE = X_REPORTING_DATE)
        OR ((tlinfo.REPORTING_DATE is null) AND (X_REPORTING_DATE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('REPORTING_DATE',tlinfo.REPORTING_DATE);
   end if;
   if ((tlinfo.DUE_DATE = X_DUE_DATE)
        OR ((tlinfo.DUE_DATE is null) AND (X_DUE_DATE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('DUE_DATE',tlinfo.DUE_DATE);
   end if;
   if (tlinfo.INVOICING_DATE = X_INVOICING_DATE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVOICING_DATE',tlinfo.INVOICING_DATE);
   end if;
   if ((tlinfo.ACTUAL_GL_ACCOUNT_ID = X_ACTUAL_GL_ACCOUNT_ID)
        OR ((tlinfo.ACTUAL_GL_ACCOUNT_ID is null) AND (X_ACTUAL_GL_ACCOUNT_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ACTUAL_GL_ACCOUNT_ID',tlinfo.ACTUAL_GL_ACCOUNT_ID);
   end if;
   if ((tlinfo.ACTUAL_AMOUNT = X_ACTUAL_AMOUNT)
        OR ((tlinfo.ACTUAL_AMOUNT is null) AND (X_ACTUAL_AMOUNT is null)))  then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ACTUAL_AMOUNT',tlinfo.ACTUAL_AMOUNT);
   end if;
   if (tlinfo.VOL_HIST_STATUS_CODE = X_VOL_HIST_STATUS_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VOL_HIST_STATUS_CODE',tlinfo.VOL_HIST_STATUS_CODE);
   end if;
   if ((tlinfo.REPORT_TYPE_CODE = X_REPORT_TYPE_CODE)
        OR ((tlinfo.REPORT_TYPE_CODE is null) AND (X_REPORT_TYPE_CODE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('REPORT_TYPE_CODE',tlinfo.REPORT_TYPE_CODE);
   end if;
   if ((tlinfo.CERTIFIED_BY = X_CERTIFIED_BY)
        OR ((tlinfo.CERTIFIED_BY is null) AND (X_CERTIFIED_BY is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CERTIFIED_BY',tlinfo.CERTIFIED_BY);
   end if;
   if (tlinfo.ACTUAL_EXP_CODE = X_ACTUAL_EXP_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ACTUAL_EXP_CODE',tlinfo.ACTUAL_EXP_CODE);
   end if;
   if ((tlinfo.FOR_GL_ACCOUNT_ID = X_FOR_GL_ACCOUNT_ID)
        OR ((tlinfo.FOR_GL_ACCOUNT_ID is null) AND (X_FOR_GL_ACCOUNT_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('FOR_GL_ACCOUNT_ID',tlinfo.FOR_GL_ACCOUNT_ID);
   end if;
   if ((tlinfo.FORECASTED_AMOUNT = X_FORECASTED_AMOUNT)
        OR ((tlinfo.FORECASTED_AMOUNT is null) AND (X_FORECASTED_AMOUNT is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('FORECASTED_AMOUNT',tlinfo.FORECASTED_AMOUNT);
   end if;
   if (tlinfo.FORECASTED_EXP_CODE = X_FORECASTED_EXP_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('FORECASTED_EXP_CODE',tlinfo.FORECASTED_EXP_CODE);
   end if;
   if (tlinfo.VARIANCE_EXP_CODE = X_VARIANCE_EXP_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VARIANCE_EXP_CODE',tlinfo.VARIANCE_EXP_CODE);
   end if;
   if ((tlinfo.COMMENTS = X_COMMENTS)
        OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('COMMENTS',tlinfo.COMMENTS);
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
   if  ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
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
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE10',tlinfo.ATTRIBUTE10);
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

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_VOL_HIST with _ALL table.
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
   X_VOL_HIST_ID          in NUMBER,
   X_VOL_HIST_NUM         in NUMBER,
   X_LINE_ITEM_ID         in NUMBER,
   X_PERIOD_ID            in NUMBER,
   X_START_DATE           in DATE,
   X_END_DATE             in DATE,
   X_GRP_DATE_ID          in NUMBER,
   X_GROUP_DATE           in DATE,
   X_REPORTING_DATE       in DATE,
   X_DUE_DATE             in DATE,
   X_INVOICING_DATE       in DATE,
   X_ACTUAL_GL_ACCOUNT_ID in NUMBER,
   X_ACTUAL_AMOUNT        in NUMBER,
   X_DAILY_ACTUAL_AMOUNT  in NUMBER,
   X_VOL_HIST_STATUS_CODE in VARCHAR2,
   X_REPORT_TYPE_CODE     in VARCHAR2,
   X_CERTIFIED_BY         in NUMBER,
   X_ACTUAL_EXP_CODE      in VARCHAR2,
   X_FOR_GL_ACCOUNT_ID    in NUMBER,
   X_FORECASTED_AMOUNT    in NUMBER,
   X_FORECASTED_EXP_CODE  in VARCHAR2,
   X_VARIANCE_EXP_CODE    in VARCHAR2,
   X_COMMENTS             in VARCHAR2,
   X_ATTRIBUTE_CATEGORY   in VARCHAR2,
   X_ATTRIBUTE1           in VARCHAR2,
   X_ATTRIBUTE2           in VARCHAR2,
   X_ATTRIBUTE3           in VARCHAR2,
   X_ATTRIBUTE4           in VARCHAR2,
   X_ATTRIBUTE5           in VARCHAR2,
   X_ATTRIBUTE6           in VARCHAR2,
   X_ATTRIBUTE7           in VARCHAR2,
   X_ATTRIBUTE8           in VARCHAR2,
   X_ATTRIBUTE9           in VARCHAR2,
   X_ATTRIBUTE10          in VARCHAR2,
   X_ATTRIBUTE11          in VARCHAR2,
   X_ATTRIBUTE12          in VARCHAR2,
   X_ATTRIBUTE13          in VARCHAR2,
   X_ATTRIBUTE14          in VARCHAR2,
   X_ATTRIBUTE15          in VARCHAR2,
   X_LAST_UPDATE_DATE     in DATE,
   X_LAST_UPDATED_BY      in NUMBER,
   X_LAST_UPDATE_LOGIN    in NUMBER
)
IS

   l_return_daily_amount   NUMBER := 0;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.UPDATE_ROW (+)');

   -------------------------------------------------------
   -- Calculate daily amount for change calendar function
   ------------------------------------------------------
   PN_VAR_VOL_HIST_PKG.CALCULATE_DAILY_AMOUNT( l_return_daily_amount,
                                               X_ACTUAL_AMOUNT,
                                               X_START_DATE,
                                               X_END_DATE
                                             );

   UPDATE PN_VAR_VOL_HIST_ALL
   SET
      VOL_HIST_NUM         = X_VOL_HIST_NUM,
      LINE_ITEM_ID         = X_LINE_ITEM_ID,
      PERIOD_ID            = X_PERIOD_ID,
      START_DATE           = X_START_DATE,
      END_DATE             = X_END_DATE,
      GRP_DATE_ID          = X_GRP_DATE_ID,
      GROUP_DATE           = X_GROUP_DATE,
      REPORTING_DATE       = X_REPORTING_DATE,
      DUE_DATE             = X_DUE_DATE,
      INVOICING_DATE       = X_INVOICING_DATE,
      ACTUAL_GL_ACCOUNT_ID = X_ACTUAL_GL_ACCOUNT_ID,
      ACTUAL_AMOUNT        = X_ACTUAL_AMOUNT,
      DAILY_ACTUAL_AMOUNT  = l_return_daily_amount,
      VOL_HIST_STATUS_CODE = X_VOL_HIST_STATUS_CODE,
      REPORT_TYPE_CODE     = X_REPORT_TYPE_CODE,
      CERTIFIED_BY         = X_CERTIFIED_BY,
      ACTUAL_EXP_CODE      = X_ACTUAL_EXP_CODE,
      FOR_GL_ACCOUNT_ID    = X_FOR_GL_ACCOUNT_ID,
      FORECASTED_AMOUNT    = X_FORECASTED_AMOUNT,
      FORECASTED_EXP_CODE  = X_FORECASTED_EXP_CODE,
      VARIANCE_EXP_CODE    = X_VARIANCE_EXP_CODE,
      COMMENTS             = X_COMMENTS,
      ATTRIBUTE_CATEGORY   = X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1           = X_ATTRIBUTE1,
      ATTRIBUTE2           = X_ATTRIBUTE2,
      ATTRIBUTE3           = X_ATTRIBUTE3,
      ATTRIBUTE4           = X_ATTRIBUTE4,
      ATTRIBUTE5           = X_ATTRIBUTE5,
      ATTRIBUTE6           = X_ATTRIBUTE6,
      ATTRIBUTE7           = X_ATTRIBUTE7,
      ATTRIBUTE8           = X_ATTRIBUTE8,
      ATTRIBUTE9           = X_ATTRIBUTE9,
      ATTRIBUTE10          = X_ATTRIBUTE10,
      ATTRIBUTE11          = X_ATTRIBUTE11,
      ATTRIBUTE12          = X_ATTRIBUTE12,
      ATTRIBUTE13          = X_ATTRIBUTE13,
      ATTRIBUTE14          = X_ATTRIBUTE14,
      ATTRIBUTE15          = X_ATTRIBUTE15,
      LAST_UPDATE_DATE     = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY      = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN    = X_LAST_UPDATE_LOGIN
   WHERE VOL_HIST_ID = X_VOL_HIST_ID
   ;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   UPDATE pn_var_lines_all
   SET sales_vol_update_flag = 'Y'
   WHERE line_item_id = x_line_item_id;

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_VOL_HIST with _ALL table.
-------------------------------------------------------------------------------
procedure DELETE_ROW (
  X_VOL_HIST_ID in NUMBER
) IS

   /* Get the details of line item id for thsi volume history */
   CURSOR line_item_cur IS
     SELECT line_item_id
       FROM pn_var_vol_hist_all
      WHERE vol_hist_id = x_vol_hist_id;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.DELETE_ROW (+)');

   /* Update the sales_vol_update_flag to 'Y' for line for which volume history
      is deleted */
   FOR rec IN line_item_cur LOOP

      UPDATE pn_var_lines_all
      SET sales_vol_update_flag = 'Y'
      WHERE line_item_id = rec.line_item_id;

   END LOOP;



   DELETE FROM PN_VAR_VOL_HIST_ALL
   WHERE VOL_HIST_ID = X_VOL_HIST_ID;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.DELETE_ROW (-)');

END DELETE_ROW;

-----------------------------------------------------------------------
-- PROCEDURE : CALCULATE_DAILY_AMOUNT
-----------------------------------------------------------------------
procedure CALCULATE_DAILY_AMOUNT (
  x_return_daily_amount out NOCOPY NUMBER,
  X_ACTUAL_AMOUNT       in NUMBER,
  X_START_DATE          in DATE,
  X_END_DATE            in DATE
) IS

  l_days number;
BEGIN

   l_days := x_end_date - x_start_date;
   IF l_days = 0 THEN
     l_days := 1;
   END IF;
   x_return_daily_amount := X_ACTUAL_AMOUNT/l_days;

END CALCULATE_DAILY_AMOUNT;


-------------------------------------------------------------------------------
-- PROCDURE : MODIFY_ROW
-- INVOKED FROM : MODIFY_ROW procedure
-- PURPOSE      : modifies the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_VOL_HIST with _ALL table.
-------------------------------------------------------------------------------
procedure MODIFY_ROW (
   X_VOL_HIST_ID          in NUMBER,
   X_VOL_HIST_NUM         in NUMBER,
   X_LINE_ITEM_ID         in NUMBER,
   X_PERIOD_ID            in NUMBER,
   X_START_DATE           in DATE,
   X_END_DATE             in DATE,
   X_GRP_DATE_ID          in NUMBER,
   X_GROUP_DATE           in DATE,
   X_REPORTING_DATE       in DATE,
   X_DUE_DATE             in DATE,
   X_INVOICING_DATE       in DATE,
   X_ACTUAL_GL_ACCOUNT_ID in NUMBER,
   X_ACTUAL_AMOUNT        in NUMBER,
   X_DAILY_ACTUAL_AMOUNT  in NUMBER,
   X_VOL_HIST_STATUS_CODE in VARCHAR2,
   X_REPORT_TYPE_CODE     in VARCHAR2,
   X_CERTIFIED_BY         in NUMBER,
   X_ACTUAL_EXP_CODE      in VARCHAR2,
   X_FOR_GL_ACCOUNT_ID    in NUMBER,
   X_FORECASTED_AMOUNT    in NUMBER,
   X_FORECASTED_EXP_CODE  in VARCHAR2,
   X_VARIANCE_EXP_CODE    in VARCHAR2,
   X_COMMENTS             in VARCHAR2,
   X_ATTRIBUTE_CATEGORY   in VARCHAR2,
   X_ATTRIBUTE1           in VARCHAR2,
   X_ATTRIBUTE2           in VARCHAR2,
   X_ATTRIBUTE3           in VARCHAR2,
   X_ATTRIBUTE4           in VARCHAR2,
   X_ATTRIBUTE5           in VARCHAR2,
   X_ATTRIBUTE6           in VARCHAR2,
   X_ATTRIBUTE7           in VARCHAR2,
   X_ATTRIBUTE8           in VARCHAR2,
   X_ATTRIBUTE9           in VARCHAR2,
   X_ATTRIBUTE10          in VARCHAR2,
   X_ATTRIBUTE11          in VARCHAR2,
   X_ATTRIBUTE12          in VARCHAR2,
   X_ATTRIBUTE13          in VARCHAR2,
   X_ATTRIBUTE14          in VARCHAR2,
   X_ATTRIBUTE15          in VARCHAR2,
   X_LAST_UPDATE_DATE     in DATE,
   X_LAST_UPDATED_BY      in NUMBER,
   X_LAST_UPDATE_LOGIN    in NUMBER
)
IS

   l_return_daily_amount   NUMBER := 0;

   /* Get the details of breakpoint details default */
   CURSOR vol_his_cur IS
     SELECT *
     FROM pn_var_vol_hist_all
     WHERE vol_hist_id = x_vol_hist_id;


BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.MODIFY_ROW (+)');

   FOR rec IN vol_his_cur LOOP
      -------------------------------------------------------
      -- Calculate daily amount for change calendar function
      ------------------------------------------------------
      PN_VAR_VOL_HIST_PKG.CALCULATE_DAILY_AMOUNT( l_return_daily_amount,
                                                  NVL(x_actual_amount, rec.actual_amount),
                                                  NVL(x_start_date, rec.start_date),
                                                  NVL(x_end_date, rec.end_date)
                                                );

      UPDATE PN_VAR_VOL_HIST_ALL
      SET
         vol_hist_num         = NVL( x_vol_hist_num, rec.vol_hist_num),
         line_item_id         = x_line_item_id,
         period_id            = NVL( x_period_id, rec.period_id),
         start_date           = NVL( x_start_date, rec.start_date),
         end_date             = NVL( x_end_date, rec.end_date),
         grp_date_id          = NVL( x_grp_date_id, rec.grp_date_id),
         group_date           = NVL( x_group_date, rec.group_date),
         reporting_date       = NVL( x_reporting_date, rec.reporting_date),
         due_date             = NVL( x_due_date, rec.due_date),
         invoicing_date       = NVL( x_invoicing_date, rec.invoicing_date),
         actual_gl_account_id = NVL( x_actual_gl_account_id, rec.actual_gl_account_id),
         actual_amount        = NVL( x_actual_amount, rec.actual_amount),
         daily_actual_amount  = NVL( l_return_daily_amount, rec.daily_actual_amount),
         vol_hist_status_code = NVL( x_vol_hist_status_code, rec.vol_hist_status_code),
         report_type_code     = NVL( x_report_type_code, rec.report_type_code),
         certified_by         = NVL( x_certified_by, rec.certified_by),
         actual_exp_code      = NVL( x_actual_exp_code, rec.actual_exp_code),
         for_gl_account_id    = NVL( x_for_gl_account_id, rec.for_gl_account_id),
         forecasted_amount    = NVL( x_forecasted_amount, rec.forecasted_amount),
         forecasted_exp_code  = NVL( x_forecasted_exp_code, rec.forecasted_exp_code),
         variance_exp_code    = NVL( x_variance_exp_code, rec.variance_exp_code),
         comments             = NVL( x_comments, rec.comments),
         attribute_category   = NVL( x_attribute_category, rec.attribute_category),
         attribute1           = NVL( x_attribute1, rec.attribute1),
         attribute2           = NVL( x_attribute2, rec.attribute2),
         attribute3           = NVL( x_attribute3, rec.attribute3),
         attribute4           = NVL( x_attribute4, rec.attribute4),
         attribute5           = NVL( x_attribute5, rec.attribute5),
         attribute6           = NVL( x_attribute6, rec.attribute6),
         attribute7           = NVL( x_attribute7, rec.attribute7),
         attribute8           = NVL( x_attribute8, rec.attribute8),
         attribute9           = NVL( x_attribute9, rec.attribute9),
         attribute10          = NVL( x_attribute10, rec.attribute10),
         attribute11          = NVL( x_attribute11, rec.attribute11),
         attribute12          = NVL( x_attribute12, rec.attribute12),
         attribute13          = NVL( x_attribute13, rec.attribute13),
         attribute14          = NVL( x_attribute14, rec.attribute14),
         attribute15          = NVL( x_attribute15, rec.attribute15),
         last_update_date     = NVL( x_last_update_date, rec.last_update_date),
         last_updated_by      = NVL( x_last_updated_by, rec.last_updated_by),
         last_update_login    = NVL( x_last_update_login, rec.last_update_login)
      WHERE vol_hist_id = x_vol_hist_id
      ;

      IF (sql%notfound) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE pn_var_lines_all
      SET sales_vol_update_flag = 'Y'
      WHERE line_item_id = x_line_item_id;

   END LOOP;

   PNP_DEBUG_PKG.debug ('PN_VAR_VOL_HIST_PKG.MODIFY_ROW (-)');

END MODIFY_ROW;

END PN_VAR_VOL_HIST_PKG;

/
