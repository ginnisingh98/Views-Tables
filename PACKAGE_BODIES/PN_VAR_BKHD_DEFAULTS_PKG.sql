--------------------------------------------------------
--  DDL for Package Body PN_VAR_BKHD_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_BKHD_DEFAULTS_PKG" AS
/* $Header: PNVRBHDB.pls 120.0 2007/10/03 14:28:00 rthumma noship $ */

-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID                 in out NOCOPY VARCHAR2,
  X_BKHD_DEFAULT_ID       in out NOCOPY NUMBER,
  X_BKHD_DETAIL_NUM       in out NOCOPY NUMBER,
  X_LINE_DEFAULT_ID       in NUMBER,
  X_BKPT_HEAD_TEMPLATE_ID in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_BKHD_START_DATE       in DATE,
  X_BKHD_END_DATE         in DATE,
  X_BREAK_TYPE            in VARCHAR2,
  X_BASE_RENT_TYPE        in VARCHAR2,
  X_NATURAL_BREAK_RATE    in NUMBER,
  X_BASE_RENT             in NUMBER,
  X_BREAKPOINT_TYPE       in VARCHAR2,
  X_BREAKPOINT_LEVEL      in VARCHAR2,
  X_PROCESSED_FLAG        in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_CREATION_DATE         in DATE,
  X_CREATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_ORG_ID                in NUMBER,
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
  X_ATTRIBUTE15           in VARCHAR2
) is

  CURSOR C IS
     SELECT ROWID
     FROM pn_var_bkhd_defaults_all
     WHERE bkhd_default_id = x_bkhd_default_id ;

BEGIN


   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.INSERT_ROW (+)');
   -------------------------------------------------------
   -- We need t generate the line number
   -------------------------------------------------------
   SELECT nvl(max(bkhd.bkhd_detail_num),0)
   INTO   X_BKHD_DETAIL_NUM
   FROM   pn_var_bkhd_defaults_all  bkhd
   WHERE  bkhd.bkhd_default_id = X_BKHD_DEFAULT_ID;

   X_BKHD_DETAIL_NUM := X_BKHD_DETAIL_NUM + 1;
   -------------------------------------------------------
   -- Select the nextval for line_bkpt default id
   -------------------------------------------------------
   IF ( X_BKHD_DEFAULT_ID IS NULL) THEN
      SELECT  PN_VAR_BKHD_DEFAULTS_S.nextval
      INTO    X_BKHD_DEFAULT_ID
      FROM    dual;
   END IF;

   insert into PN_VAR_BKHD_DEFAULTS_ALL
   (
      BKHD_DEFAULT_ID,
      BKHD_DETAIL_NUM,
      LINE_DEFAULT_ID,
      BKPT_HEAD_TEMPLATE_ID,
      AGREEMENT_TEMPLATE_ID,
      BKHD_START_DATE,
      BKHD_END_DATE,
      BREAK_TYPE,
      BASE_RENT_TYPE,
      NATURAL_BREAK_RATE,
      BASE_RENT,
      BREAKPOINT_TYPE,
      BREAKPOINT_LEVEL,
      PROCESSED_FLAG,
      VAR_RENT_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      ORG_ID,
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
      BKPT_UPDATE_FLAG
   )
   values
   (
      X_BKHD_DEFAULT_ID,
      X_BKHD_DETAIL_NUM,
      X_LINE_DEFAULT_ID,
      X_BKPT_HEAD_TEMPLATE_ID,
      X_AGREEMENT_TEMPLATE_ID,
      X_BKHD_START_DATE,
      X_BKHD_END_DATE,
      X_BREAK_TYPE,
      X_BASE_RENT_TYPE,
      X_NATURAL_BREAK_RATE,
      X_BASE_RENT,
      X_BREAKPOINT_TYPE,
      X_BREAKPOINT_LEVEL,
      X_PROCESSED_FLAG,
      X_VAR_RENT_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_ORG_ID,
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
      'Y'
   );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%notfound) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure LOCK_ROW (
  X_BKHD_DEFAULT_ID       in NUMBER,
  X_BKHD_DETAIL_NUM       in NUMBER,
  X_LINE_DEFAULT_ID       in NUMBER,
  X_BKPT_HEAD_TEMPLATE_ID in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_BKHD_START_DATE       in DATE,
  X_BKHD_END_DATE         in DATE,
  X_BREAK_TYPE            in VARCHAR2,
  X_BASE_RENT_TYPE        in VARCHAR2,
  X_NATURAL_BREAK_RATE    in NUMBER,
  X_BASE_RENT             in NUMBER,
  X_BREAKPOINT_TYPE       in VARCHAR2,
  X_BREAKPOINT_LEVEL      in VARCHAR2,
  X_VAR_RENT_ID           in NUMBER,
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
  X_ATTRIBUTE15           in VARCHAR2
) is

  cursor c1 is select
      *
    from PN_VAR_BKHD_DEFAULTS_ALL
    where BKHD_DEFAULT_ID = X_BKHD_DEFAULT_ID
    for update of BKHD_DEFAULT_ID nowait;

tlinfo c1%rowtype;

begin

   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.LOCK_ROW (+)');

   open c1;
    fetch c1 into tlinfo;
    if (c1%notfound) then
            close c1;
            return;
    end if;
   close c1;

    IF (tlinfo.BKHD_DEFAULT_ID = X_BKHD_DEFAULT_ID) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKHD_DEFAULT_ID',tlinfo.BKHD_DEFAULT_ID);
    END IF;

    IF (tlinfo.LINE_DEFAULT_ID = X_LINE_DEFAULT_ID) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LINE_DEFAULT_ID',tlinfo.LINE_DEFAULT_ID);
    END IF;
    IF ((tlinfo.AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID)
         OR ((tlinfo.AGREEMENT_TEMPLATE_ID is null) AND (X_AGREEMENT_TEMPLATE_ID is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AGREEMENT_TEMPLATE_ID',tlinfo.AGREEMENT_TEMPLATE_ID);
    END IF;

    IF ((tlinfo.BKHD_START_DATE = X_BKHD_START_DATE)
         OR ((tlinfo.BKHD_START_DATE is null) AND (X_BKHD_START_DATE is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKHD_START_DATE',tlinfo.BKHD_START_DATE);
    END IF;

    IF ((tlinfo.BKHD_END_DATE = X_BKHD_END_DATE)
         OR ((tlinfo.BKHD_END_DATE is null) AND (X_BKHD_END_DATE is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BKHD_END_DATE',tlinfo.BKHD_END_DATE);
    END IF;

    IF ((tlinfo.BREAK_TYPE = X_BREAK_TYPE)
         OR ((tlinfo.BREAK_TYPE is null) AND (X_BREAK_TYPE is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BREAK_TYPE',tlinfo.BREAK_TYPE);
    END IF;

    IF ((tlinfo.BASE_RENT_TYPE = X_BASE_RENT_TYPE)
         OR ((tlinfo.BASE_RENT_TYPE is null) AND (X_BASE_RENT_TYPE is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BASE_RENT_TYPE',tlinfo.BASE_RENT_TYPE);
    END IF;

    IF ((tlinfo.NATURAL_BREAK_RATE = X_NATURAL_BREAK_RATE)
         OR ((tlinfo.NATURAL_BREAK_RATE is null) AND (X_NATURAL_BREAK_RATE is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('NATURAL_BREAK_RATE',tlinfo.NATURAL_BREAK_RATE);
    END IF;

    IF ((tlinfo.BASE_RENT = X_BASE_RENT)
         OR ((tlinfo.BASE_RENT is null) AND (X_BASE_RENT is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BASE_RENT',tlinfo.BASE_RENT);
    END IF;

    IF ((tlinfo.BREAKPOINT_TYPE = X_BREAKPOINT_TYPE)
         OR ((tlinfo.BREAKPOINT_TYPE is null) AND (X_BREAKPOINT_TYPE is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BREAKPOINT_TYPE',tlinfo.BREAKPOINT_TYPE);
    END IF;

    IF ((tlinfo.BREAKPOINT_LEVEL = X_BREAKPOINT_LEVEL)
         OR ((tlinfo.BREAKPOINT_LEVEL is null) AND (X_BREAKPOINT_LEVEL is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('BREAKPOINT_LEVEL',tlinfo.BREAKPOINT_LEVEL);
    END IF;

    IF ((tlinfo.VAR_RENT_ID = X_VAR_RENT_ID)
         OR ((tlinfo.VAR_RENT_ID is null) AND (X_VAR_RENT_ID is null))) THEN
       null;
    ELSE
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_ID',tlinfo.VAR_RENT_ID);
    END IF;

   if ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
         OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE_CATEGORY', to_char(tlinfo.ATTRIBUTE_CATEGORY));
    end if;


    if ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
         OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1', to_char(tlinfo.ATTRIBUTE1));
    end if;

    if ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
         OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE2', to_char(tlinfo.ATTRIBUTE2));
    end if;

    if ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
         OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE3', to_char(tlinfo.ATTRIBUTE3));
    end if;

    if ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
         OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE4', to_char(tlinfo.ATTRIBUTE4));
    end if;

    if ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
         OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE5', to_char(tlinfo.ATTRIBUTE5));
    end if;

    if ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
         OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE6', to_char(tlinfo.ATTRIBUTE6));
    end if;

    if ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
         OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE7', to_char(tlinfo.ATTRIBUTE7));
    end if;

    if ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
         OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE8', to_char(tlinfo.ATTRIBUTE8));
    end if;

    if ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
         OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE9', to_char(tlinfo.ATTRIBUTE9));
    end if;

    if ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
         OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE10', to_char(tlinfo.ATTRIBUTE10));
    end if;

    if ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
         OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE11', to_char(tlinfo.ATTRIBUTE11));
    end if;

    if ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
         OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE12', to_char(tlinfo.ATTRIBUTE12));
    end if;

    if ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
         OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE13', to_char(tlinfo.ATTRIBUTE13));
    end if;

    if ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
         OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE14', to_char(tlinfo.ATTRIBUTE14));
    end if;

    if ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
         OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) then
       null;
    else
       PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE15', to_char(tlinfo.ATTRIBUTE15));
    end if;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.LOCK_ROW (-)');

end LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_BKHD_DEFAULT_ID       in NUMBER,
  X_BKHD_DETAIL_NUM       in NUMBER,
  X_LINE_DEFAULT_ID       in NUMBER,
  X_BKPT_HEAD_TEMPLATE_ID in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_BKHD_START_DATE       in DATE,
  X_BKHD_END_DATE         in DATE,
  X_BREAK_TYPE            in VARCHAR2,
  X_BASE_RENT_TYPE        in VARCHAR2,
  X_NATURAL_BREAK_RATE    in NUMBER,
  X_BASE_RENT             in NUMBER,
  X_BREAKPOINT_TYPE       in VARCHAR2,
  X_BREAKPOINT_LEVEL      in VARCHAR2,
  X_PROCESSED_FLAG        in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
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
  X_ATTRIBUTE15           in VARCHAR2
) IS

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.UPDATE_ROW (+)');

   UPDATE PN_VAR_BKHD_DEFAULTS_ALL SET
      LINE_DEFAULT_ID       = X_LINE_DEFAULT_ID,
      BKHD_DETAIL_NUM       = X_BKHD_DETAIL_NUM,
      BKPT_HEAD_TEMPLATE_ID = X_BKPT_HEAD_TEMPLATE_ID,
      AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID,
      BKHD_START_DATE       = X_BKHD_START_DATE,
      BKHD_END_DATE         = X_BKHD_END_DATE,
      BREAK_TYPE            = X_BREAK_TYPE,
      BASE_RENT_TYPE        = X_BASE_RENT_TYPE,
      NATURAL_BREAK_RATE    = X_NATURAL_BREAK_RATE,
      BASE_RENT             = X_BASE_RENT,
      BREAKPOINT_TYPE       = X_BREAKPOINT_TYPE,
      BREAKPOINT_LEVEL      = X_BREAKPOINT_LEVEL,
      BKHD_DEFAULT_ID       = X_BKHD_DEFAULT_ID,
      PROCESSED_FLAG        = X_PROCESSED_FLAG,
      VAR_RENT_ID           = X_VAR_RENT_ID,
      LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN,
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
      BKPT_UPDATE_FLAG      = 'Y'
   WHERE BKHD_DEFAULT_ID = X_BKHD_DEFAULT_ID;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-----------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-----------------------------------------------------------------------
procedure DELETE_ROW (  X_BKHD_DEFAULT_ID in NUMBER)
IS

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.DELETE_ROW (+)'||X_BKHD_DEFAULT_ID);

   DELETE FROM PN_VAR_BKHD_DEFAULTS_ALL
   WHERE BKHD_DEFAULT_ID = X_BKHD_DEFAULT_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.DELETE_ROW (-)');

END DELETE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : MODIFY_ROW
-- INVOKED FROM : MODIFY_ROW procedure
-- PURPOSE      : modifies the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure MODIFY_ROW (
  X_BKHD_DEFAULT_ID       in NUMBER,
  X_BKHD_DETAIL_NUM       in NUMBER,
  X_LINE_DEFAULT_ID       in NUMBER,
  X_BKPT_HEAD_TEMPLATE_ID in NUMBER,
  X_AGREEMENT_TEMPLATE_ID in NUMBER,
  X_BKHD_START_DATE       in DATE,
  X_BKHD_END_DATE         in DATE,
  X_BREAK_TYPE            in VARCHAR2,
  X_BASE_RENT_TYPE        in VARCHAR2,
  X_NATURAL_BREAK_RATE    in NUMBER,
  X_BASE_RENT             in NUMBER,
  X_BREAKPOINT_TYPE       in VARCHAR2,
  X_BREAKPOINT_LEVEL      in VARCHAR2,
  X_PROCESSED_FLAG        in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
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
  X_ATTRIBUTE15           in VARCHAR2
) IS

/* Get the details of breakpoint header default */
CURSOR bkhd_defaults_cur IS
  SELECT *
  FROM pn_var_bkhd_defaults_all
  WHERE bkhd_default_id = x_bkhd_default_id;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.MODIFY_ROW (+)');

   FOR rec IN bkhd_defaults_cur LOOP
      UPDATE pn_var_bkhd_defaults_all SET
         line_default_id       = NVL( x_line_default_id, rec.line_default_id),
         bkhd_detail_num       = NVL( x_bkhd_detail_num, rec.bkhd_detail_num ),
         bkpt_head_template_id = NVL( x_bkpt_head_template_id, rec.bkpt_head_template_id),
         agreement_template_id = NVL( x_agreement_template_id, rec.agreement_template_id ),
         bkhd_start_date       = NVL( x_bkhd_start_date, rec.bkhd_start_date),
         bkhd_end_date         = NVL( x_bkhd_end_date, rec.bkhd_end_date ),
         break_type            = NVL( x_break_type, rec.break_type),
         base_rent_type        = NVL( x_base_rent_type, rec.base_rent_type),
         natural_break_rate    = NVL( x_natural_break_rate, rec.natural_break_rate),
         base_rent             = NVL( x_base_rent, rec.base_rent),
         breakpoint_type       = NVL( x_breakpoint_type, rec.breakpoint_type),
         breakpoint_level      = NVL( x_breakpoint_level, rec.breakpoint_level),
         bkhd_default_id       = NVL( x_bkhd_default_id, rec.bkhd_default_id),
         processed_flag        = NVL( x_processed_flag, rec.processed_flag),
         var_rent_id           = NVL( x_var_rent_id, rec.var_rent_id),
         last_update_date      = NVL( x_last_update_date, rec.last_update_date),
         last_updated_by       = NVL( x_last_updated_by, rec.last_updated_by),
         last_update_login     = NVL( x_last_update_login, rec.last_update_login),
         attribute_category    = NVL( x_attribute_category, rec.attribute_category),
         attribute1            = NVL( x_attribute1, rec.attribute1),
         attribute2            = NVL( x_attribute2, rec.attribute2),
         attribute3            = NVL( x_attribute3, rec.attribute3),
         attribute4            = NVL( x_attribute4, rec.attribute4),
         attribute5            = NVL( x_attribute5, rec.attribute5),
         attribute6            = NVL( x_attribute6, rec.attribute6),
         attribute7            = NVL( x_attribute7, rec.attribute7),
         attribute8            = NVL( x_attribute8, rec.attribute8),
         attribute9            = NVL( x_attribute9, rec.attribute9),
         attribute10           = NVL( x_attribute10, rec.attribute10),
         attribute11           = NVL( x_attribute11, rec.attribute11),
         attribute12           = NVL( x_attribute12, rec.attribute12),
         attribute13           = NVL( x_attribute13, rec.attribute13),
         attribute14           = NVL( x_attribute14, rec.attribute14),
         attribute15           = NVL( x_attribute15, rec.attribute15),
         bkpt_update_flag      = 'Y'
      WHERE bkhd_default_id = x_bkhd_default_id;

      IF (sql%notfound) THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END LOOP;



   PNP_DEBUG_PKG.debug ('PN_VAR_BKHD_DEFAULTS_PKG.MODIFY_ROW (-)');

END MODIFY_ROW;

end PN_VAR_BKHD_DEFAULTS_PKG;

/
