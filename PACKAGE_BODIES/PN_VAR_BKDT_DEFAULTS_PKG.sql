--------------------------------------------------------
--  DDL for Package Body PN_VAR_BKDT_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_BKDT_DEFAULTS_PKG" AS
/* $Header: PNVRBDDB.pls 120.0 2007/10/03 14:27:41 rthumma noship $ */

-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID                      in out NOCOPY VARCHAR2,
  X_BKDT_DEFAULT_ID            in out NOCOPY NUMBER,
  X_BKDT_DETAIL_NUM            in out NOCOPY NUMBER,
  X_BKHD_DEFAULT_ID            in NUMBER,
  X_BKDT_START_DATE            in DATE,
  X_BKDT_END_DATE              in DATE,
  X_PERIOD_BKPT_VOL_START      in NUMBER,
  X_PERIOD_BKPT_VOL_END        in NUMBER,
  X_GROUP_BKPT_VOL_START       in NUMBER,
  X_GROUP_BKPT_VOL_END         in NUMBER,
  X_BKPT_RATE                  in NUMBER,
  X_PROCESSED_FLAG             in NUMBER,
  X_VAR_RENT_ID                in NUMBER,
  X_CREATION_DATE              in DATE,
  X_CREATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE           in DATE,
  X_LAST_UPDATED_BY            in NUMBER,
  X_LAST_UPDATE_LOGIN          in NUMBER,
  X_ORG_ID                     in NUMBER,
  X_ANNUAL_BASIS_AMOUNT        in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY         in VARCHAR2,
  X_ATTRIBUTE1                 in VARCHAR2,
  X_ATTRIBUTE2                 in VARCHAR2,
  X_ATTRIBUTE3                 in VARCHAR2,
  X_ATTRIBUTE4                 in VARCHAR2,
  X_ATTRIBUTE5                 in VARCHAR2,
  X_ATTRIBUTE6                 in VARCHAR2,
  X_ATTRIBUTE7                 in VARCHAR2,
  X_ATTRIBUTE8                 in VARCHAR2,
  X_ATTRIBUTE9                 in VARCHAR2,
  X_ATTRIBUTE10                in VARCHAR2,
  X_ATTRIBUTE11                in VARCHAR2,
  X_ATTRIBUTE12                in VARCHAR2,
  X_ATTRIBUTE13                in VARCHAR2,
  X_ATTRIBUTE14                in VARCHAR2,
  X_ATTRIBUTE15                in VARCHAR2
) is

   CURSOR C IS
      SELECT ROWID
      FROM PN_VAR_BKDT_DEFAULTS_ALL
      WHERE BKDT_DEFAULT_ID = X_BKDT_DEFAULT_ID;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- We need to generate the line number
   -------------------------------------------------------
   SELECT  nvl(max(bkdt.BKDT_DETAIL_NUM),0)
   INTO    X_BKDT_DETAIL_NUM
   FROM    PN_VAR_BKDT_DEFAULTS_ALL bkdt
   WHERE   bkdt.BKHD_DEFAULT_ID = X_BKHD_DEFAULT_ID;

   X_BKDT_DETAIL_NUM    := X_BKDT_DETAIL_NUM + 1;

   -------------------------------------------------------
   -- Select the nextval for bkpt detail default id
   -------------------------------------------------------
   IF ( X_BKDT_DEFAULT_ID IS NULL) THEN
      SELECT  PN_VAR_BKDT_DEFAULTS_S.nextval
      INTO    X_BKDT_DEFAULT_ID
      FROM    dual;
   END IF;

   INSERT INTO PN_VAR_BKDT_DEFAULTS_ALL
   (
      BKDT_DETAIL_NUM,
      BKHD_DEFAULT_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      BKDT_START_DATE,
      BKDT_END_DATE,
      PERIOD_BKPT_VOL_START,
      PERIOD_BKPT_VOL_END,
      GROUP_BKPT_VOL_START,
      GROUP_BKPT_VOL_END,
      BKPT_RATE,
      BKDT_DEFAULT_ID,
      PROCESSED_FLAG,
      VAR_RENT_ID,
      ORG_ID,
      ANNUAL_BASIS_AMOUNT
   )
   values
   (
      X_BKDT_DETAIL_NUM,
      X_BKHD_DEFAULT_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_BKDT_START_DATE,
      X_BKDT_END_DATE,
      X_PERIOD_BKPT_VOL_START,
      X_PERIOD_BKPT_VOL_END,
      X_GROUP_BKPT_VOL_START,
      X_GROUP_BKPT_VOL_END,
      X_BKPT_RATE,
      X_BKDT_DEFAULT_ID,
      X_PROCESSED_FLAG,
      X_VAR_RENT_ID,
      X_ORG_ID,
      X_ANNUAL_BASIS_AMOUNT
   );

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   UPDATE pn_var_bkhd_defaults_all
   SET bkpt_update_flag = 'Y'
   WHERE bkhd_default_id = x_bkhd_default_id;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.INSERT_ROW (-)');

EXCEPTION

   WHEN OTHERS THEN
   pnp_debug_pkg.debug(sqlerrm);
   RAISE;
END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure LOCK_ROW (
  X_BKDT_DEFAULT_ID            in NUMBER,
  X_BKDT_DETAIL_NUM            in NUMBER,
  X_BKHD_DEFAULT_ID            in NUMBER,
  X_BKDT_START_DATE            in DATE,
  X_BKDT_END_DATE              in DATE,
  X_PERIOD_BKPT_VOL_START      in NUMBER,
  X_PERIOD_BKPT_VOL_END        in NUMBER,
  X_GROUP_BKPT_VOL_START       in NUMBER,
  X_GROUP_BKPT_VOL_END         in NUMBER,
  X_BKPT_RATE                  in NUMBER,
  X_VAR_RENT_ID                in NUMBER,
  X_ANNUAL_BASIS_AMOUNT        in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY         in VARCHAR2,
  X_ATTRIBUTE1                 in VARCHAR2,
  X_ATTRIBUTE2                 in VARCHAR2,
  X_ATTRIBUTE3                 in VARCHAR2,
  X_ATTRIBUTE4                 in VARCHAR2,
  X_ATTRIBUTE5                 in VARCHAR2,
  X_ATTRIBUTE6                 in VARCHAR2,
  X_ATTRIBUTE7                 in VARCHAR2,
  X_ATTRIBUTE8                 in VARCHAR2,
  X_ATTRIBUTE9                 in VARCHAR2,
  X_ATTRIBUTE10                in VARCHAR2,
  X_ATTRIBUTE11                in VARCHAR2,
  X_ATTRIBUTE12                in VARCHAR2,
  X_ATTRIBUTE13                in VARCHAR2,
  X_ATTRIBUTE14                in VARCHAR2,
  X_ATTRIBUTE15                in VARCHAR2
) is

  cursor c1 is select
      *
    from PN_VAR_BKDT_DEFAULTS_ALL
    where BKDT_DEFAULT_ID = X_BKDT_DEFAULT_ID
    for update of BKDT_DEFAULT_ID nowait;
begin

        PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.LOCK_ROW (+)');

  for tlinfo in c1 loop
     /*
      if (    (tlinfo.BKDT_DEFAULT_ID = X_BKDT_DEFAULT_ID)
          AND (tlinfo.BKDT_DETAIL_NUM = X_BKDT_DETAIL_NUM)
          AND (tlinfo.BKHD_DEFAULT_ID = X_BKHD_DEFAULT_ID)
          AND ((tlinfo.BKDT_START_DATE = X_BKDT_START_DATE)
               OR ((tlinfo.BKDT_START_DATE is null) AND (X_BKDT_START_DATE is null)))
          AND ((tlinfo.BKDT_END_DATE = X_BKDT_END_DATE)
               OR ((tlinfo.BKDT_END_DATE is null) AND (X_BKDT_END_DATE is null)))
          AND ((tlinfo.PERIOD_BKPT_VOL_START = X_PERIOD_BKPT_VOL_START)
               OR ((tlinfo.PERIOD_BKPT_VOL_START is null) AND (X_PERIOD_BKPT_VOL_START is null)))
          AND ((tlinfo.PERIOD_BKPT_VOL_END = X_PERIOD_BKPT_VOL_END)
               OR ((tlinfo.PERIOD_BKPT_VOL_END is null) AND (X_PERIOD_BKPT_VOL_END is null)))
          AND ((tlinfo.GROUP_BKPT_VOL_START = X_GROUP_BKPT_VOL_START)
               OR ((tlinfo.GROUP_BKPT_VOL_START is null) AND (X_GROUP_BKPT_VOL_START is null)))
          AND ((tlinfo.GROUP_BKPT_VOL_END = X_GROUP_BKPT_VOL_END)
               OR ((tlinfo.GROUP_BKPT_VOL_END is null) AND (X_GROUP_BKPT_VOL_END is null)))
          AND ((tlinfo.BKPT_RATE = X_BKPT_RATE)
               OR ((tlinfo.BKPT_RATE is null) AND (X_BKPT_RATE is null)))
          AND ((tlinfo.VAR_RENT_ID = X_VAR_RENT_ID)
               OR ((tlinfo.VAR_RENT_ID is null) AND (X_VAR_RENT_ID is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;

    */
   IF NOT (tlinfo.BKDT_START_DATE = X_BKDT_START_DATE) THEN
      pn_var_rent_pkg.lock_row_exception('BKDT_START_DATE',tlinfo.BKDT_START_DATE);
   END IF;
   IF NOT (tlinfo.BKDT_END_DATE = X_BKDT_END_DATE) THEN
      pn_var_rent_pkg.lock_row_exception('BKDT_END_DATE',tlinfo.BKDT_END_DATE);
   END IF;
   IF NOT (tlinfo.PERIOD_BKPT_VOL_START = X_PERIOD_BKPT_VOL_START) THEN
      pn_var_rent_pkg.lock_row_exception('PERIOD_BKPT_VOL_START',tlinfo.PERIOD_BKPT_VOL_START);
   END IF;
   IF NOT (tlinfo.PERIOD_BKPT_VOL_END = X_PERIOD_BKPT_VOL_END) THEN
      pn_var_rent_pkg.lock_row_exception('PERIOD_BKPT_VOL_END',tlinfo.PERIOD_BKPT_VOL_END);
   END IF;
   IF NOT (tlinfo.GROUP_BKPT_VOL_START = X_GROUP_BKPT_VOL_START) THEN
      pn_var_rent_pkg.lock_row_exception('GROUP_BKPT_VOL_START',tlinfo.GROUP_BKPT_VOL_START);
   END IF;
   IF NOT (tlinfo.GROUP_BKPT_VOL_END = X_GROUP_BKPT_VOL_END) THEN
      pn_var_rent_pkg.lock_row_exception('GROUP_BKPT_VOL_END',tlinfo.GROUP_BKPT_VOL_END);
   END IF;
   IF NOT (tlinfo.BKPT_RATE = X_BKPT_RATE) THEN
      pn_var_rent_pkg.lock_row_exception('BKPT_RATE',tlinfo.BKPT_RATE);
   END IF;
   IF NOT (tlinfo.ANNUAL_BASIS_AMOUNT = X_ANNUAL_BASIS_AMOUNT) THEN
      pn_var_rent_pkg.lock_row_exception('ANNUAL_BASIS_AMOUNT',tlinfo.ANNUAL_BASIS_AMOUNT);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlinfo.ATTRIBUTE_CATEGORY);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlinfo.ATTRIBUTE2);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlinfo.ATTRIBUTE3);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlinfo.ATTRIBUTE4);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlinfo.ATTRIBUTE5);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlinfo.ATTRIBUTE6);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlinfo.ATTRIBUTE7);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlinfo.ATTRIBUTE8);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlinfo.ATTRIBUTE10);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlinfo.ATTRIBUTE11);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlinfo.ATTRIBUTE12);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlinfo.ATTRIBUTE13);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlinfo.ATTRIBUTE14);
   END IF;
   IF NOT (tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
   END IF;

  end loop;
  return;

        PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.LOCK_ROW (-)');

end LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_BKDT_DEFAULT_ID    in NUMBER,
  X_BKDT_DETAIL_NUM           in NUMBER,
  X_BKHD_DEFAULT_ID           in NUMBER,
  X_BKDT_START_DATE           in DATE,
  X_BKDT_END_DATE             in DATE,
  X_PERIOD_BKPT_VOL_START     in NUMBER,
  X_PERIOD_BKPT_VOL_END       in NUMBER,
  X_GROUP_BKPT_VOL_START      in NUMBER,
  X_GROUP_BKPT_VOL_END        in NUMBER,
  X_BKPT_RATE                 in NUMBER,
  X_PROCESSED_FLAG            in NUMBER,
  X_VAR_RENT_ID               in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER,
  X_ANNUAL_BASIS_AMOUNT       in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2
) IS

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.UPDATE_ROW (+)');

   UPDATE PN_VAR_BKDT_DEFAULTS_ALL SET
      BKDT_DETAIL_NUM         = X_BKDT_DETAIL_NUM,
      BKHD_DEFAULT_ID         = X_BKHD_DEFAULT_ID,
      BKDT_START_DATE         = X_BKDT_START_DATE,
      BKDT_END_DATE           = X_BKDT_END_DATE,
      PERIOD_BKPT_VOL_START   = X_PERIOD_BKPT_VOL_START,
      PERIOD_BKPT_VOL_END     = X_PERIOD_BKPT_VOL_END,
      GROUP_BKPT_VOL_START    = X_GROUP_BKPT_VOL_START,
      GROUP_BKPT_VOL_END      = X_GROUP_BKPT_VOL_END,
      BKPT_RATE               = X_BKPT_RATE,
      PROCESSED_FLAG          = X_PROCESSED_FLAG,
      VAR_RENT_ID             = X_VAR_RENT_ID,
      BKDT_DEFAULT_ID         = X_BKDT_DEFAULT_ID,
      LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY         = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN,
      ANNUAL_BASIS_AMOUNT     = X_ANNUAL_BASIS_AMOUNT,
      ATTRIBUTE_CATEGORY      = X_ATTRIBUTE_CATEGORY,
      ATTRIBUTE1              = X_ATTRIBUTE1,
      ATTRIBUTE2              = X_ATTRIBUTE2,
      ATTRIBUTE3              = X_ATTRIBUTE3,
      ATTRIBUTE4              = X_ATTRIBUTE4,
      ATTRIBUTE5              = X_ATTRIBUTE5,
      ATTRIBUTE6              = X_ATTRIBUTE6,
      ATTRIBUTE7              = X_ATTRIBUTE7,
      ATTRIBUTE8              = X_ATTRIBUTE8,
      ATTRIBUTE9              = X_ATTRIBUTE9,
      ATTRIBUTE10             = X_ATTRIBUTE10,
      ATTRIBUTE11             = X_ATTRIBUTE11,
      ATTRIBUTE12             = X_ATTRIBUTE12,
      ATTRIBUTE13             = X_ATTRIBUTE13,
      ATTRIBUTE14             = X_ATTRIBUTE14,
      ATTRIBUTE15             = X_ATTRIBUTE15
   WHERE BKDT_DEFAULT_ID = X_BKDT_DEFAULT_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   UPDATE pn_var_bkhd_defaults_all
   SET bkpt_update_flag = 'Y'
   WHERE bkhd_default_id = x_bkhd_default_id;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-----------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-----------------------------------------------------------------------
procedure DELETE_ROW ( X_BKDT_DEFAULT_ID in NUMBER)
IS
   CURSOR bkhd_default IS
      SELECT bkhd_default_id
      FROM pn_var_bkdt_defaults_all
      WHERE bkdt_default_id = x_bkdt_default_id;
BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.DELETE_ROW (+)');

   FOR rec IN bkhd_default LOOP
      UPDATE pn_var_bkhd_defaults_all
      SET bkpt_update_flag = 'Y'
      WHERE bkhd_default_id = rec.bkhd_default_id;
   END LOOP;

   DELETE FROM pn_var_bkdt_defaults_all
   WHERE bkdt_default_id = x_bkdt_default_id;

   IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.DELETE_ROW (-)');
END DELETE_ROW;


-------------------------------------------------------------------------------
-- PROCDURE     : MODIFY_ROW
-- INVOKED FROM : MODIFY_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :

-------------------------------------------------------------------------------
procedure MODIFY_ROW (
  X_BKDT_DEFAULT_ID           in NUMBER,
  X_BKDT_DETAIL_NUM           in NUMBER,
  X_BKHD_DEFAULT_ID           in NUMBER,
  X_BKDT_START_DATE           in DATE,
  X_BKDT_END_DATE             in DATE,
  X_PERIOD_BKPT_VOL_START     in NUMBER,
  X_PERIOD_BKPT_VOL_END       in NUMBER,
  X_GROUP_BKPT_VOL_START      in NUMBER,
  X_GROUP_BKPT_VOL_END        in NUMBER,
  X_BKPT_RATE                 in NUMBER,
  X_PROCESSED_FLAG            in NUMBER,
  X_VAR_RENT_ID               in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER,
  X_ANNUAL_BASIS_AMOUNT       in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2
) IS

/* Get the details of breakpoint details default */
CURSOR bkdt_defaults_cur IS
  SELECT *
  FROM pn_var_bkdt_defaults_all
  WHERE bkdt_default_id = x_bkdt_default_id;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.MODIFY_ROW (+)');

   FOR rec IN bkdt_defaults_cur LOOP
      UPDATE PN_VAR_BKDT_DEFAULTS_ALL SET
         BKDT_DETAIL_NUM         = NVL( x_bkdt_detail_num, rec.bkdt_detail_num),
         BKHD_DEFAULT_ID         = x_bkhd_default_id,
         BKDT_START_DATE         = NVL( x_bkdt_start_date, rec.bkdt_start_date),
         BKDT_END_DATE           = NVL( x_bkdt_end_date, rec.bkdt_end_date),
         PERIOD_BKPT_VOL_START   = NVL( x_period_bkpt_vol_start, rec.period_bkpt_vol_start),
         PERIOD_BKPT_VOL_END     = NVL( x_period_bkpt_vol_end, rec.period_bkpt_vol_end),
         GROUP_BKPT_VOL_START    = NVL( x_group_bkpt_vol_start, rec.group_bkpt_vol_start),
         GROUP_BKPT_VOL_END      = NVL( x_group_bkpt_vol_end, rec.group_bkpt_vol_end),
         BKPT_RATE               = NVL( x_bkpt_rate, rec.bkpt_rate),
         PROCESSED_FLAG          = NVL( x_processed_flag, rec.processed_flag),
         VAR_RENT_ID             = NVL( x_var_rent_id, rec.var_rent_id),
         BKDT_DEFAULT_ID         = NVL( x_bkdt_default_id, rec.bkdt_default_id),
         LAST_UPDATE_DATE        = NVL( x_last_update_date, rec.last_update_date),
         LAST_UPDATED_BY         = NVL( x_last_updated_by, rec.last_updated_by),
         LAST_UPDATE_LOGIN       = NVL( x_last_update_login, rec.last_update_login),
         ANNUAL_BASIS_AMOUNT     = NVL( x_annual_basis_amount, rec.annual_basis_amount),
         ATTRIBUTE_CATEGORY      = NVL( x_attribute_category, rec.attribute_category),
         ATTRIBUTE1              = NVL( x_attribute1, rec.attribute1),
         ATTRIBUTE2              = NVL( x_attribute2, rec.attribute2),
         ATTRIBUTE3              = NVL( x_attribute3, rec.attribute3),
         ATTRIBUTE4              = NVL( x_attribute4, rec.attribute4),
         ATTRIBUTE5              = NVL( x_attribute5, rec.attribute5),
         ATTRIBUTE6              = NVL( x_attribute6, rec.attribute6),
         ATTRIBUTE7              = NVL( x_attribute7, rec.attribute7),
         ATTRIBUTE8              = NVL( x_attribute8, rec.attribute8),
         ATTRIBUTE9              = NVL( x_attribute9, rec.attribute9),
         ATTRIBUTE10             = NVL( x_attribute10, rec.attribute10),
         ATTRIBUTE11             = NVL( x_attribute11, rec.attribute11),
         ATTRIBUTE12             = NVL( x_attribute12, rec.attribute12),
         ATTRIBUTE13             = NVL( x_attribute13, rec.attribute13),
         ATTRIBUTE14             = NVL( x_attribute14, rec.attribute14),
         ATTRIBUTE15             = NVL( x_attribute15, rec.attribute15)
      WHERE BKDT_DEFAULT_ID = X_BKDT_DEFAULT_ID;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      UPDATE pn_var_bkhd_defaults_all
      SET bkpt_update_flag = 'Y'
      WHERE bkhd_default_id = x_bkhd_default_id;

   END LOOP;

   PNP_DEBUG_PKG.debug ('PN_VAR_BKDT_DEFAULTS_PKG.MODIFY_ROW (-)');

END MODIFY_ROW;

end PN_VAR_BKDT_DEFAULTS_PKG;

/
