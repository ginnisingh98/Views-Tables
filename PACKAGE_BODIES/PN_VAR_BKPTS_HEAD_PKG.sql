--------------------------------------------------------
--  DDL for Package Body PN_VAR_BKPTS_HEAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_BKPTS_HEAD_PKG" as
/* $Header: PNVRBKPB.pls 120.2 2006/12/20 09:24:10 pseeram noship $ */
-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_HEAD with _ALL table.
-------------------------------------------------------------------------------
procedure INSERT_ROW (
                     X_ROWID                in out NOCOPY VARCHAR2,
                     X_BKPT_HEADER_ID       in out NOCOPY NUMBER,
                     X_LINE_ITEM_ID         in NUMBER,
                     X_PERIOD_ID            in NUMBER,
                     X_BREAK_TYPE           in VARCHAR2,
                     X_BASE_RENT_TYPE       in VARCHAR2,
                     X_NATURAL_BREAK_RATE   in NUMBER,
                     X_BASE_RENT            in NUMBER,
                     X_BREAKPOINT_TYPE      in VARCHAR2,
                     X_BKHD_DEFAULT_ID      in NUMBER,
                     X_BKHD_START_DATE      in DATE DEFAULT NULL,
                     X_BKHD_END_DATE        in DATE DEFAULT NULL,
                     X_VAR_RENT_ID          in NUMBER,
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
                     X_ORG_ID               in NUMBER,
                     X_CREATION_DATE        in DATE,
                     X_CREATED_BY           in NUMBER,
                     X_LAST_UPDATE_DATE     in DATE,
                     X_LAST_UPDATED_BY      in NUMBER,
                     X_LAST_UPDATE_LOGIN    in NUMBER,
           X_BKPT_UPDATE_FLAG     in VARCHAR2)
IS
   CURSOR C IS
      SELECT ROWID
      FROM   PN_VAR_BKPTS_HEAD_ALL
      WHERE  BKPT_HEADER_ID = X_BKPT_HEADER_ID;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_HEAD_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- Select the nextval for breakpoint header id
   -------------------------------------------------------

   IF ( X_BKPT_HEADER_ID IS NULL) THEN
      SELECT  pn_var_bkpts_head_s.nextval
      INTO    X_BKPT_HEADER_ID
      FROM    dual;
   END IF;

   INSERT INTO PN_VAR_BKPTS_HEAD_ALL
   (
      BKPT_HEADER_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      LINE_ITEM_ID,
      PERIOD_ID,
      BREAK_TYPE,
      BASE_RENT_TYPE,
      NATURAL_BREAK_RATE,
      BASE_RENT,
      BREAKPOINT_TYPE,
      BKHD_DEFAULT_ID,
      BKHD_START_DATE,
      BKHD_END_DATE,
      VAR_RENT_ID,
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
      X_BKPT_HEADER_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_LINE_ITEM_ID,
      X_PERIOD_ID,
      X_BREAK_TYPE,
      X_BASE_RENT_TYPE,
      X_NATURAL_BREAK_RATE,
      X_BASE_RENT,
      X_BREAKPOINT_TYPE,
      X_BKHD_DEFAULT_ID,
      X_BKHD_START_DATE,
      X_BKHD_END_DATE,
      X_VAR_RENT_ID,
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
   IF (c%NOTFOUND) THEN
   CLOSE c;
   RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   IF NVL(x_bkpt_update_flag, 'Y') = 'Y' THEN
      UPDATE pn_var_lines_all
      SET bkpt_update_flag = 'Y'
      WHERE line_item_id = x_line_item_id;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_HEAD_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_HEAD with _ALL table.
-------------------------------------------------------------------------------
procedure LOCK_ROW (
    X_BKPT_HEADER_ID     in NUMBER,
    X_LINE_ITEM_ID       in NUMBER,
    X_PERIOD_ID          in NUMBER,
    X_BREAK_TYPE         in VARCHAR2,
    X_BASE_RENT_TYPE     in VARCHAR2,
    X_NATURAL_BREAK_RATE in NUMBER,
    X_BASE_RENT          in NUMBER,
    X_BREAKPOINT_TYPE    in VARCHAR2,
    X_BKHD_DEFAULT_ID    in NUMBER,
    X_BKHD_START_DATE    in DATE DEFAULT NULL,
    X_BKHD_END_DATE      in DATE DEFAULT NULL,
    X_VAR_RENT_ID        in NUMBER,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1         in VARCHAR2,
    X_ATTRIBUTE2         in VARCHAR2,
    X_ATTRIBUTE3         in VARCHAR2,
    X_ATTRIBUTE4         in VARCHAR2,
    X_ATTRIBUTE5         in VARCHAR2,
    X_ATTRIBUTE6         in VARCHAR2,
    X_ATTRIBUTE7         in VARCHAR2,
    X_ATTRIBUTE8         in VARCHAR2,
    X_ATTRIBUTE9         in VARCHAR2,
    X_ATTRIBUTE10        in VARCHAR2,
    X_ATTRIBUTE11        in VARCHAR2,
    X_ATTRIBUTE12        in VARCHAR2,
    X_ATTRIBUTE13        in VARCHAR2,
    X_ATTRIBUTE14        in VARCHAR2,
    X_ATTRIBUTE15        in VARCHAR2
  )
IS

   CURSOR c1 IS
      SELECT *
      FROM PN_VAR_BKPTS_HEAD_ALL
      WHERE BKPT_HEADER_ID = X_BKPT_HEADER_ID
      FOR UPDATE OF BKPT_HEADER_ID NOWAIT;

    tlinfo c1%rowtype;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_HEAD_PKG.LOCK_ROW (+)');

   OPEN c1;
   FETCH c1 INTO tlinfo;
   IF (c1%notfound) THEN
      CLOSE c1;
      return;
   END IF;
   CLOSE c1;

   if (tlinfo.BKPT_HEADER_ID = X_BKPT_HEADER_ID) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKPT_HEADER_ID', to_char(tlinfo.BKPT_HEADER_ID));
   end if;
   if ((tlinfo.LINE_ITEM_ID = X_LINE_ITEM_ID)
        OR ((tlinfo.LINE_ITEM_ID is null) AND (X_LINE_ITEM_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LINE_ITEM_ID', to_char(tlinfo.LINE_ITEM_ID));
   end if;
   if ((tlinfo.PERIOD_ID = X_PERIOD_ID)
        OR ((tlinfo.PERIOD_ID is null) AND (X_PERIOD_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PERIOD_ID', to_char(tlinfo.PERIOD_ID));
   end if;
   if (tlinfo.BREAK_TYPE = X_BREAK_TYPE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BREAK_TYPE', tlinfo.BREAK_TYPE);
   end if;
   if ((tlinfo.BASE_RENT_TYPE = X_BASE_RENT_TYPE)
        OR ((tlinfo.BASE_RENT_TYPE is null) AND (X_BASE_RENT_TYPE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BASE_RENT_TYPE', tlinfo.BASE_RENT_TYPE);
   end if;
   if ((tlinfo.NATURAL_BREAK_RATE = X_NATURAL_BREAK_RATE)
        OR ((tlinfo.NATURAL_BREAK_RATE is null) AND (X_NATURAL_BREAK_RATE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('NATURAL_BREAK_RATE', to_char(tlinfo.NATURAL_BREAK_RATE));
   end if;
   if ((tlinfo.BASE_RENT = X_BASE_RENT)
        OR ((tlinfo.BASE_RENT is null) AND (X_BASE_RENT is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BASE_RENT', to_char(tlinfo.BASE_RENT));
   end if;
   if (tlinfo.BREAKPOINT_TYPE = X_BREAKPOINT_TYPE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BREAKPOINT_TYPE', tlinfo.BREAKPOINT_TYPE);
   end if;
   if ((tlinfo.BKHD_DEFAULT_ID = X_BKHD_DEFAULT_ID)
        OR ((tlinfo.BKHD_DEFAULT_ID is null) AND (X_BKHD_DEFAULT_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKHD_DEFAULT_ID', to_char(tlinfo.BKHD_DEFAULT_ID));
   end if;
   if ((tlinfo.VAR_RENT_ID = X_VAR_RENT_ID)
        OR ((tlinfo.VAR_RENT_ID is null) AND (X_VAR_RENT_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_ID', to_char(tlinfo.VAR_RENT_ID));
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

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_HEAD_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_HEAD with _ALL table.
-------------------------------------------------------------------------------
procedure UPDATE_ROW (
    X_BKPT_HEADER_ID     in NUMBER,
    X_LINE_ITEM_ID       in NUMBER,
    X_PERIOD_ID          in NUMBER,
    X_BREAK_TYPE         in VARCHAR2,
    X_BASE_RENT_TYPE     in VARCHAR2,
    X_NATURAL_BREAK_RATE in NUMBER,
    X_BASE_RENT          in NUMBER,
    X_BREAKPOINT_TYPE    in VARCHAR2,
    X_BKHD_DEFAULT_ID    in NUMBER,
    X_BKHD_START_DATE    in DATE,
    X_BKHD_END_DATE      in DATE,
    X_VAR_RENT_ID        in NUMBER,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1         in VARCHAR2,
    X_ATTRIBUTE2         in VARCHAR2,
    X_ATTRIBUTE3         in VARCHAR2,
    X_ATTRIBUTE4         in VARCHAR2,
    X_ATTRIBUTE5         in VARCHAR2,
    X_ATTRIBUTE6         in VARCHAR2,
    X_ATTRIBUTE7         in VARCHAR2,
    X_ATTRIBUTE8         in VARCHAR2,
    X_ATTRIBUTE9         in VARCHAR2,
    X_ATTRIBUTE10        in VARCHAR2,
    X_ATTRIBUTE11        in VARCHAR2,
    X_ATTRIBUTE12        in VARCHAR2,
    X_ATTRIBUTE13        in VARCHAR2,
    X_ATTRIBUTE14        in VARCHAR2,
    X_ATTRIBUTE15        in VARCHAR2,
    X_LAST_UPDATE_DATE   in DATE,
    X_LAST_UPDATED_BY    in NUMBER,
    X_LAST_UPDATE_LOGIN  in NUMBER
  )
IS
BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_HEAD_PKG.UPDATE_ROW (+)');

   UPDATE PN_VAR_BKPTS_HEAD_ALL SET
      LINE_ITEM_ID       = X_LINE_ITEM_ID,
      PERIOD_ID          = X_PERIOD_ID,
      BREAK_TYPE         = X_BREAK_TYPE,
      BASE_RENT_TYPE     = X_BASE_RENT_TYPE,
      NATURAL_BREAK_RATE = X_NATURAL_BREAK_RATE,
      BASE_RENT          = X_BASE_RENT,
      BREAKPOINT_TYPE    = X_BREAKPOINT_TYPE,
      BKHD_DEFAULT_ID    = X_BKHD_DEFAULT_ID,
      BKHD_START_DATE    = X_BKHD_START_DATE,
      BKHD_END_DATE      = X_BKHD_END_DATE,
      VAR_RENT_ID        = X_VAR_RENT_ID,
      ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1         = X_ATTRIBUTE1,
      ATTRIBUTE2         = X_ATTRIBUTE2,
      ATTRIBUTE3         = X_ATTRIBUTE3,
      ATTRIBUTE4         = X_ATTRIBUTE4,
      ATTRIBUTE5         = X_ATTRIBUTE5,
      ATTRIBUTE6         = X_ATTRIBUTE6,
      ATTRIBUTE7         = X_ATTRIBUTE7,
      ATTRIBUTE8         = X_ATTRIBUTE8,
      ATTRIBUTE9         = X_ATTRIBUTE9,
      ATTRIBUTE10        = X_ATTRIBUTE10,
      ATTRIBUTE11        = X_ATTRIBUTE11,
      ATTRIBUTE12        = X_ATTRIBUTE12,
      ATTRIBUTE13        = X_ATTRIBUTE13,
      ATTRIBUTE14        = X_ATTRIBUTE14,
      ATTRIBUTE15        = X_ATTRIBUTE15,
      LAST_UPDATE_DATE   = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY    = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN
   WHERE BKPT_HEADER_ID = X_BKPT_HEADER_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   UPDATE pn_var_lines_all
   SET bkpt_update_flag = 'Y'
   WHERE line_item_id = x_line_item_id;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_HEAD_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 04-JUL-05  piagrawa o Bug 4284035 - Replaced PN_VAR_BKPTS_HEAD,
--                       pn_var_bkpts_det with _ALL table.
-------------------------------------------------------------------------------
procedure DELETE_ROW ( X_BKPT_HEADER_ID in NUMBER)
IS
   CURSOR c IS
   SELECT  bkpt_detail_id
   FROM    pn_var_bkpts_det_all
   WHERE   bkpt_header_id = x_bkpt_header_id
   FOR UPDATE OF bkpt_detail_id NOWAIT;

   CURSOR line_item_cur IS
      SELECT line_item_id
      FROM pn_var_bkpts_head_all
      WHERE bkpt_header_id = x_bkpt_header_id;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_HEAD_PKG.DELETE_ROW (+)');

   -- first we need to delete the note detail rows.
   FOR i IN C LOOP
      PN_VAR_BKPTS_DET_PKG.DELETE_ROW ( X_BKPT_DETAIL_ID =>i.bkpt_detail_id );
   END LOOP;

   FOR rec IN line_item_cur LOOP
      UPDATE pn_var_lines_all
      SET bkpt_update_flag = 'Y'
      WHERE line_item_id =  rec.line_item_id;
   END LOOP;

   DELETE FROM PN_VAR_BKPTS_HEAD_ALL
   WHERE BKPT_HEADER_ID = X_BKPT_HEADER_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKPTS_HEAD_PKG.DELETE_ROW (-)');

END DELETE_ROW;

END PN_VAR_BKPTS_HEAD_PKG;

/
