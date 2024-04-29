--------------------------------------------------------
--  DDL for Package Body PN_VAR_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_LINES_PKG" as
/* $Header: PNVRLINB.pls 120.2 2006/12/20 07:33:41 rdonthul noship $ */
-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_LINES with _ALL table.
-------------------------------------------------------------------------------
procedure INSERT_ROW (
   X_ROWID                 in out NOCOPY VARCHAR2,
   X_LINE_ITEM_ID          in out NOCOPY NUMBER,
   X_LINE_ITEM_NUM         in out NOCOPY NUMBER,
   X_PERIOD_ID             in NUMBER,
   X_SALES_TYPE_CODE       in VARCHAR2,
   X_ITEM_CATEGORY_CODE    in VARCHAR2,
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
   X_LINE_TEMPLATE_ID      in NUMBER,
   X_AGREEMENT_TEMPLATE_ID in NUMBER,
   X_LINE_DEFAULT_ID       in NUMBER,
   X_VAR_RENT_ID           in NUMBER
   )
IS
   CURSOR C IS
      SELECT ROWID
      FROM   PN_VAR_LINES_ALL
      WHERE  LINE_ITEM_ID = X_LINE_ITEM_ID;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- We need to generate the line number
   -------------------------------------------------------
   SELECT  nvl(max(lines.LINE_ITEM_NUM),0)
   INTO    X_LINE_ITEM_NUM
   FROM    PN_VAR_LINES_ALL      lines
   WHERE   lines.PERIOD_ID    =  X_PERIOD_ID;

   X_LINE_ITEM_NUM    := X_LINE_ITEM_NUM + 1;

   -------------------------------------------------------
   -- Select the nextval for line item id
   -------------------------------------------------------
   IF ( X_LINE_ITEM_ID IS NULL) THEN
      SELECT  pn_var_lines_s.nextval
      INTO    X_LINE_ITEM_ID
      FROM    dual;
   END IF;

   INSERT INTO PN_VAR_LINES_ALL
   (
      LINE_ITEM_ID,
      LINE_ITEM_NUM,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      PERIOD_ID,
      SALES_TYPE_CODE,
      ITEM_CATEGORY_CODE,
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
      LINE_TEMPLATE_ID ,
      AGREEMENT_TEMPLATE_ID,
      LINE_DEFAULT_ID,
      VAR_RENT_ID,
      BKPT_UPDATE_FLAG
   )
   VALUES
   (
      X_LINE_ITEM_ID,
      X_LINE_ITEM_NUM,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_PERIOD_ID,
      X_SALES_TYPE_CODE,
      X_ITEM_CATEGORY_CODE,
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
      X_LINE_TEMPLATE_ID ,
      X_AGREEMENT_TEMPLATE_ID,
      X_LINE_DEFAULT_ID,
      X_VAR_RENT_ID,
      'Y'
   ) ;

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%notfound) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_LINES with _ALL table.
-------------------------------------------------------------------------------
procedure LOCK_ROW (
   X_LINE_ITEM_ID          in NUMBER,
   X_LINE_ITEM_NUM         in NUMBER,
   X_PERIOD_ID             in NUMBER,
   X_SALES_TYPE_CODE       in VARCHAR2,
   X_ITEM_CATEGORY_CODE    in VARCHAR2,
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
   X_LINE_TEMPLATE_ID      in NUMBER,
   X_AGREEMENT_TEMPLATE_ID in NUMBER,
   X_LINE_DEFAULT_ID       in NUMBER,
   X_VAR_RENT_ID           in NUMBER
)
IS
   CURSOR c1 IS
      SELECT *
      FROM PN_VAR_LINES_ALL
      WHERE LINE_ITEM_ID = X_LINE_ITEM_ID
      FOR UPDATE OF LINE_ITEM_ID NOWAIT;

   tlinfo c1%rowtype;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.LOCK_ROW (+)');

   OPEN c1;
   FETCH c1 INTO tlinfo;
   IF (c1%notfound) THEN
      CLOSE c1;
      RETURN;
   END IF;
   CLOSE c1;

   if (tlinfo.LINE_ITEM_ID = X_LINE_ITEM_ID) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LINE_ITEM_ID', to_char(tlinfo.LINE_ITEM_ID));
   end if;
   if (tlinfo.LINE_ITEM_NUM = X_LINE_ITEM_NUM) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LINE_ITEM_NUM', to_char(tlinfo.LINE_ITEM_NUM));
   end if;
   if ((tlinfo.PERIOD_ID = X_PERIOD_ID)
        OR ((tlinfo.PERIOD_ID is null) AND (X_PERIOD_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_ID', to_char(tlinfo.PERIOD_ID));
   end if;
   if ((tlinfo.SALES_TYPE_CODE = X_SALES_TYPE_CODE)
        OR ((tlinfo.SALES_TYPE_CODE is null) AND (X_SALES_TYPE_CODE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('SALES_TYPE_CODE',tlinfo.SALES_TYPE_CODE);
   end if;
   if ((tlinfo.ITEM_CATEGORY_CODE = X_ITEM_CATEGORY_CODE)
        OR ((tlinfo.ITEM_CATEGORY_CODE is null) AND (X_ITEM_CATEGORY_CODE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ITEM_CATEGORY_CODE',tlinfo.ITEM_CATEGORY_CODE);
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

   if ((tlinfo.LINE_TEMPLATE_ID  = X_LINE_TEMPLATE_ID )
        OR ((tlinfo.LINE_TEMPLATE_ID  is null) AND (X_LINE_TEMPLATE_ID  is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LINE_TEMPLATE_ID ',tlinfo.LINE_TEMPLATE_ID );
   end if;
   if ((tlinfo.AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID)
        OR ((tlinfo.AGREEMENT_TEMPLATE_ID is null) AND (X_AGREEMENT_TEMPLATE_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AGREEMENT_TEMPLATE_ID',tlinfo.AGREEMENT_TEMPLATE_ID);
   end if;
   if ((tlinfo.LINE_DEFAULT_ID = X_LINE_DEFAULT_ID)
        OR ((tlinfo.LINE_DEFAULT_ID is null) AND (X_LINE_DEFAULT_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LINE_DEFAULT_ID',tlinfo.LINE_DEFAULT_ID);
   end if;
   if ((tlinfo.VAR_RENT_ID = X_VAR_RENT_ID)
        OR ((tlinfo.VAR_RENT_ID is null) AND (X_VAR_RENT_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_ID',tlinfo.VAR_RENT_ID);
   end if;
   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_LINES with _ALL table.
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
   X_LINE_ITEM_ID          in NUMBER,
   X_LINE_ITEM_NUM         in NUMBER,
   X_PERIOD_ID             in NUMBER,
   X_SALES_TYPE_CODE       in VARCHAR2,
   X_ITEM_CATEGORY_CODE    in VARCHAR2,
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
   X_LINE_TEMPLATE_ID      in NUMBER,
   X_AGREEMENT_TEMPLATE_ID in NUMBER,
   X_LINE_DEFAULT_ID       in NUMBER,
   X_VAR_RENT_ID           in NUMBER
)
IS
BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.UPDATE_ROW (+)');

   UPDATE PN_VAR_LINES_ALL
   SET
      LINE_ITEM_NUM         = X_LINE_ITEM_NUM,
      PERIOD_ID             = X_PERIOD_ID,
      SALES_TYPE_CODE       = X_SALES_TYPE_CODE,
      ITEM_CATEGORY_CODE    = X_ITEM_CATEGORY_CODE,
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
      LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN,
      LINE_TEMPLATE_ID      = X_LINE_TEMPLATE_ID ,
      AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID,
      LINE_DEFAULT_ID       = X_LINE_DEFAULT_ID,
      VAR_RENT_ID           = X_VAR_RENT_ID
   WHERE LINE_ITEM_ID   = X_LINE_ITEM_ID;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_LINES with _ALL table.
-------------------------------------------------------------------------------
procedure DELETE_ROW ( X_LINE_ITEM_ID in NUMBER)
IS
   -- Get the details of
   CURSOR line_info_cur IS
     SELECT period_id, var_rent_id
       FROM pn_var_lines_all
      WHERE line_item_id = x_line_item_id;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.DELETE_ROW (+)');

   /* Delete the transaction records for this line item */
   FOR rec IN line_info_cur LOOP
      NULL;
      --pn_var_trx_pkg.delete_transactions (var_rent_id, period_id, x_line_item_id);
   END LOOP;

   DELETE from PN_VAR_LINES_ALL
   WHERE LINE_ITEM_ID = X_LINE_ITEM_ID;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_LINES_PKG.DELETE_ROW (-)');

END DELETE_ROW;

END PN_VAR_LINES_PKG;

/
