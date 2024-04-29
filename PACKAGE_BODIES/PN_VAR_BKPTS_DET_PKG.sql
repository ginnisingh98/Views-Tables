--------------------------------------------------------
--  DDL for Package Body PN_VAR_BKPTS_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_BKPTS_DET_PKG" as
/* $Header: PNVRBKDB.pls 120.2 2006/12/20 09:21:26 pseeram noship $ */
-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_DET with _ALL table.
-- 29-SEP-06  pikhar   o Bug 5573913 - Commented call to
--                       PN_VAR_BKPTS_DET_PKG.CHECK_VOL_START
-------------------------------------------------------------------------------
procedure INSERT_ROW (
                     X_ROWID                 in out NOCOPY VARCHAR2,
                     X_BKPT_DETAIL_ID        in out NOCOPY NUMBER,
                     X_BKPT_DETAIL_NUM       in out NOCOPY NUMBER,
                     X_BKPT_HEADER_ID        in NUMBER,
                     X_BKPT_START_DATE       in DATE,
                     X_BKPT_END_DATE         in DATE,
                     X_PERIOD_BKPT_VOL_START in NUMBER,
                     X_PERIOD_BKPT_VOL_END   in NUMBER,
                     X_GROUP_BKPT_VOL_START  in NUMBER,
                     X_GROUP_BKPT_VOL_END    in NUMBER,
                     X_BKPT_RATE             in NUMBER,
                     X_BKDT_DEFAULT_ID       in NUMBER,
                     X_VAR_RENT_ID           in NUMBER,
                     X_COMMENTS              in VARCHAR2,
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
                     X_ANNUAL_BASIS_AMOUNT   in NUMBER DEFAULT NULL  --03-NOV-2003
                   )
IS

   CURSOR C IS
        SELECT ROWID
        FROM   PN_VAR_BKPTS_DET_ALL
        WHERE  BKPT_DETAIL_ID = X_BKPT_DETAIL_ID
        ;

   l_return_status         VARCHAR2(30)    := NULL;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_DET_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- We need to generate the breakpoints details number
   -------------------------------------------------------
   SELECT  nvl(max(bkdetails.BKPT_DETAIL_NUM),0)
   INTO    X_BKPT_DETAIL_NUM
   FROM    PN_VAR_BKPTS_DET_ALL      bkdetails
   WHERE   bkdetails.BKPT_HEADER_ID    =  X_BKPT_HEADER_ID;

   X_BKPT_DETAIL_NUM    := X_BKPT_DETAIL_NUM + 1;

   -------------------------------------------------------
   -- Select the nextval for breakpoints details id
   -------------------------------------------------------
   IF ( X_BKPT_DETAIL_ID IS NULL) THEN
      SELECT  pn_var_bkpts_det_s.nextval
      INTO    X_BKPT_DETAIL_ID
      FROM    dual;
   END IF;

   -- Check for breakpoint volume ranges
/*   l_return_status     := NULL;
   PN_VAR_BKPTS_DET_PKG.CHECK_VOL_START
   (
      l_return_status,
      x_bkpt_header_id,
      x_bkpt_detail_id,
      X_PERIOD_BKPT_VOL_START
   );

   IF (l_return_status IS NOT NULL) THEN
      APP_EXCEPTION.Raise_Exception;
   END IF;*/

   INSERT INTO PN_VAR_BKPTS_DET_ALL
   (
      BKPT_DETAIL_ID,
      BKPT_DETAIL_NUM,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      BKPT_HEADER_ID,
      BKPT_START_DATE,
      BKPT_END_DATE,
      PERIOD_BKPT_VOL_START,
      PERIOD_BKPT_VOL_END,
      GROUP_BKPT_VOL_START,
      GROUP_BKPT_VOL_END,
      BKPT_RATE,
      BKDT_DEFAULT_ID,
      VAR_RENT_ID,
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
      ORG_ID,
      ANNUAL_BASIS_AMOUNT --03-NOV-2003
   )
   VALUES
   (
      X_BKPT_DETAIL_ID,
      X_BKPT_DETAIL_NUM,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_BKPT_HEADER_ID,
      X_BKPT_START_DATE,
      X_BKPT_END_DATE,
      X_PERIOD_BKPT_VOL_START,
      X_PERIOD_BKPT_VOL_END,
      X_GROUP_BKPT_VOL_START,
      X_GROUP_BKPT_VOL_END,
      X_BKPT_RATE,
      X_BKDT_DEFAULT_ID,
      X_VAR_RENT_ID,
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
      X_ORG_ID,
      X_ANNUAL_BASIS_AMOUNT --03-NOV-2003
   );

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%notfound) THEN
      CLOSE c;
   RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   IF x_bkdt_default_id IS NULL THEN
      UPDATE pn_var_lines_all
      SET bkpt_update_flag = 'Y'
      WHERE line_item_id IN (SELECT line_item_id
                             FROM pn_var_bkpts_head_all
                             WHERE bkpt_header_id = x_bkpt_header_id);
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_DET_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_DET with _ALL table.
-------------------------------------------------------------------------------
procedure LOCK_ROW (
    X_BKPT_DETAIL_ID        in NUMBER,
    X_BKPT_DETAIL_NUM       in NUMBER,
    X_BKPT_HEADER_ID        in NUMBER,
    X_BKPT_START_DATE       in DATE,
    X_BKPT_END_DATE         in DATE,
    X_PERIOD_BKPT_VOL_START in NUMBER,
    X_PERIOD_BKPT_VOL_END   in NUMBER,
    X_GROUP_BKPT_VOL_START  in NUMBER,
    X_GROUP_BKPT_VOL_END    in NUMBER,
    X_BKPT_RATE             in NUMBER,
    X_BKDT_DEFAULT_ID       in NUMBER,
    X_VAR_RENT_ID           in NUMBER,
    X_COMMENTS              in VARCHAR2,
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
    X_ANNUAL_BASIS_AMOUNT   in NUMBER DEFAULT NULL  --03-NOV-2003
  )
IS

   CURSOR c1 IS
      SELECT *
      FROM PN_VAR_BKPTS_DET_ALL
      WHERE BKPT_DETAIL_ID = X_BKPT_DETAIL_ID
      FOR UPDATE OF BKPT_DETAIL_ID nowait;

   tlinfo c1%rowtype;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_DET_PKG.LOCK_ROW (+)');

   OPEN c1;
     FETCH c1 into tlinfo;
     IF (c1%notfound) then
             close c1;
             return;
     END IF;
   CLOSE c1;

   if (tlinfo.BKPT_DETAIL_ID = X_BKPT_DETAIL_ID) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKPT_DETAIL_ID',to_char(tlinfo.BKPT_DETAIL_ID));
   end if;
   if ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
        OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
   end if;
   if (tlinfo.BKPT_DETAIL_NUM = X_BKPT_DETAIL_NUM) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKPT_DETAIL_NUM',to_char(tlinfo.BKPT_DETAIL_NUM));
   end if;
   if ((tlinfo.BKPT_HEADER_ID = X_BKPT_HEADER_ID)
        OR ((tlinfo.BKPT_HEADER_ID is null) AND (X_BKPT_HEADER_ID is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKPT_HEADER_ID',to_char(tlinfo.BKPT_HEADER_ID));
   end if;
   if ((tlinfo.BKDT_DEFAULT_ID = X_BKDT_DEFAULT_ID)
        OR ((tlinfo.BKDT_DEFAULT_ID is null) AND (X_BKDT_DEFAULT_ID is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKPT_HEADER_ID',to_char(tlinfo.BKPT_HEADER_ID));
   end if;
   if ((tlinfo.VAR_RENT_ID = X_VAR_RENT_ID)
        OR ((tlinfo.VAR_RENT_ID is null) AND (X_VAR_RENT_ID is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_ID',to_char(tlinfo.VAR_RENT_ID));
   end if;
   if ((tlinfo.BKPT_START_DATE = X_BKPT_START_DATE)
        OR ((tlinfo.BKPT_START_DATE is null) AND (X_BKPT_START_DATE is null))) then
        null;
   else
     PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKPT_START_DATE',to_char(tlinfo.BKPT_START_DATE));
   end if;
   if ((tlinfo.BKPT_END_DATE = X_BKPT_END_DATE)
        OR ((tlinfo.BKPT_END_DATE is null) AND (X_BKPT_END_DATE is null))) then
        null;
   else
     PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKPT_END_DATE',to_char(tlinfo.BKPT_END_DATE));
   end if;
   if ((tlinfo.PERIOD_BKPT_VOL_START = X_PERIOD_BKPT_VOL_START)
        OR ((tlinfo.PERIOD_BKPT_VOL_START is null) AND (X_PERIOD_BKPT_VOL_START is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_BKPT_VOL_START',to_char(tlinfo.PERIOD_BKPT_VOL_START));
   end if;
   if ((tlinfo.PERIOD_BKPT_VOL_END = X_PERIOD_BKPT_VOL_END)
        OR ((tlinfo.PERIOD_BKPT_VOL_END is null) AND (X_PERIOD_BKPT_VOL_END is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_BKPT_VOL_END',to_char(tlinfo.PERIOD_BKPT_VOL_END));
   end if;
   if (tlinfo.GROUP_BKPT_VOL_START = X_GROUP_BKPT_VOL_START) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('GROUP_BKPT_VOL_START',to_char(tlinfo.GROUP_BKPT_VOL_START));
   end if;
   if ((tlinfo.GROUP_BKPT_VOL_END = X_GROUP_BKPT_VOL_END)
        OR ((tlinfo.GROUP_BKPT_VOL_END is null) AND (X_GROUP_BKPT_VOL_END is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('GROUP_BKPT_VOL_END',to_char(tlinfo.GROUP_BKPT_VOL_END));
   end if;
   if (tlinfo.BKPT_RATE = X_BKPT_RATE) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKPT_RATE',to_char(tlinfo.BKPT_RATE));
   end if;
   if ((tlinfo.COMMENTS = X_COMMENTS)
        OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('COMMENTS',tlinfo.COMMENTS);
   end if;
   if ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
        OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))  then
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
   --03-NOV-2003 Start
   if ((tlinfo.ANNUAL_BASIS_AMOUNT = X_ANNUAL_BASIS_AMOUNT)
        OR ((tlinfo.ANNUAL_BASIS_AMOUNT is null) AND (X_ANNUAL_BASIS_AMOUNT is null))) then
        null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ANNUAL_BASIS_AMOUNT',tlinfo.ANNUAL_BASIS_AMOUNT);
   end if;
   --03-NOV-2003 End

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_DET_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_DET with _ALL table.
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
    X_BKPT_DETAIL_ID        in NUMBER,
    X_BKPT_DETAIL_NUM       in NUMBER,
    X_BKPT_HEADER_ID        in NUMBER,
    X_BKPT_START_DATE       in DATE,
    X_BKPT_END_DATE         in DATE,
    X_PERIOD_BKPT_VOL_START in NUMBER,
    X_PERIOD_BKPT_VOL_END   in NUMBER,
    X_GROUP_BKPT_VOL_START  in NUMBER,
    X_GROUP_BKPT_VOL_END    in NUMBER,
    X_BKPT_RATE             in NUMBER,
    X_BKDT_DEFAULT_ID       in NUMBER,
    X_VAR_RENT_ID           in NUMBER,
    X_COMMENTS              in VARCHAR2,
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
    X_ANNUAL_BASIS_AMOUNT   in NUMBER DEFAULT NULL  --03-NOV-2003
  )
IS

   l_return_status         VARCHAR2(30)    := NULL;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_DET_PKG.UPDATE_ROW (+)');

   -- Check for breakpoint volume ranges
   l_return_status     := NULL;
   /*PN_VAR_BKPTS_DET_PKG.CHECK_VOL_START
     (
         l_return_status,
         x_bkpt_header_id,
         x_bkpt_detail_id,
         X_PERIOD_BKPT_VOL_START
     );
   IF (l_return_status IS NOT NULL) THEN
     APP_EXCEPTION.Raise_Exception;
   END IF;*/

   UPDATE PN_VAR_BKPTS_DET_ALL SET
      BKPT_DETAIL_NUM       = X_BKPT_DETAIL_NUM,
      BKPT_HEADER_ID        = X_BKPT_HEADER_ID,
      BKPT_START_DATE       = X_BKPT_START_DATE,
      BKPT_END_DATE         = X_BKPT_END_DATE,
      PERIOD_BKPT_VOL_START = X_PERIOD_BKPT_VOL_START,
      PERIOD_BKPT_VOL_END   = X_PERIOD_BKPT_VOL_END,
      GROUP_BKPT_VOL_START  = X_GROUP_BKPT_VOL_START,
      GROUP_BKPT_VOL_END    = X_GROUP_BKPT_VOL_END,
      BKPT_RATE             = X_BKPT_RATE,
      BKDT_DEFAULT_ID       = X_BKDT_DEFAULT_ID,
      VAR_RENT_ID           = X_VAR_RENT_ID,
      COMMENTS              = X_COMMENTS,
      ATTRIBUTE_CATEGORY    = X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1            = X_ATTRIBUTE1,
      ATTRIBUTE2            = X_ATTRIBUTE2,
      ATTRIBUTE3            = X_ATTRIBUTE3,
      ATTRIBUTE4            = X_ATTRIBUTE4,
      ATTRIBUTE5            = X_ATTRIBUTE5,
      ATTRIBUTE6            = X_ATTRIBUTE6,
      ATTRIBUTE7            = X_ATTRIBUTE7,
      ATTRIBUTE8            = X_ATTRIBUTE8,
      ATTRIBUTE9            = X_ATTRIBUTE9,
      ATTRIBUTE10           = X_ATTRIBUTE10,
      ATTRIBUTE11           = X_ATTRIBUTE11,
      ATTRIBUTE12           = X_ATTRIBUTE12,
      ATTRIBUTE13           = X_ATTRIBUTE13,
      ATTRIBUTE14           = X_ATTRIBUTE14,
      ATTRIBUTE15           = X_ATTRIBUTE15,
      BKPT_DETAIL_ID        = X_BKPT_DETAIL_ID,
      LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN,
      ANNUAL_BASIS_AMOUNT   = X_ANNUAL_BASIS_AMOUNT  --03-NOV-2003
   WHERE BKPT_DETAIL_ID = X_BKPT_DETAIL_ID ;

   IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
   END IF;

   UPDATE pn_var_lines_all
   SET bkpt_update_flag = 'Y'
   WHERE line_item_id IN (SELECT line_item_id
                          FROM pn_var_bkpts_head_all
                          WHERE bkpt_header_id = x_bkpt_header_id);

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_DET_PKG.UPDATE_ROW (+)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_DET with _ALL table.
-------------------------------------------------------------------------------
procedure DELETE_ROW ( X_BKPT_DETAIL_ID in NUMBER)
IS

   CURSOR line_item_cur IS
      SELECT line_item_id
      FROM pn_var_bkpts_head_all
      WHERE Bkpt_Header_id = (SELECT bkpt_header_id
                              FROM pn_var_bkpts_det_all
                              WHERE bkpt_detail_id = x_bkpt_detail_id);

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.DELETE_ROW (+)');

   FOR rec IN line_item_cur LOOP
      UPDATE pn_var_lines_all
      SET bkpt_update_flag = 'Y'
      WHERE line_item_id =  rec.line_item_id;
   END LOOP;

   DELETE FROM PN_VAR_BKPTS_DET_ALL
   WHERE BKPT_DETAIL_ID = X_BKPT_DETAIL_ID;

   IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.DELETE_ROW (-)');

END DELETE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : CHECK_VOL_START
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_DET with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE CHECK_VOL_START
        (
            x_return_status     in out NOCOPY  varchar2,
            x_bkpt_header_id    in      number,
            x_bkpt_detail_id    in      number,
            x_period_vol_start  in      number
        )
IS
    l_dummy             NUMBER;
BEGIN
   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.CHECK_VOL_START (+)');

   SELECT  1
   INTO    l_dummy
   FROM    dual
   WHERE   not exists
     (
         SELECT  1
         FROM    pn_var_bkpts_det_all   bkd
         WHERE   NVL(bkd.PERIOD_BKPT_VOL_END,(x_period_vol_start+1)) > (x_period_vol_start)
         AND     ((x_bkpt_detail_id    is null) or
                  (bkd.bkpt_detail_id  <> x_bkpt_detail_id))
         AND     bkd.bkpt_header_id  = x_bkpt_header_id
     );

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.CHECK_VOL_START (-)');

   EXCEPTION
     when NO_DATA_FOUND  then
         fnd_message.set_name ('PN','PN_VAR_WRONG_RANGE');
         --fnd_message.set_token('RENT_NUMBER',
                 --x_rent_num);
         x_return_status := 'E';
END CHECK_VOL_START;

END PN_VAR_BKPTS_DET_PKG;

/
