--------------------------------------------------------
--  DDL for Package Body PN_VAR_RENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_RENTS_PKG" as
/* $Header: PNVRENTB.pls 120.4 2007/01/30 04:17:53 lbala noship $ */
-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_RENTS with _ALL table.
-------------------------------------------------------------------------------
procedure INSERT_ROW (
   X_ROWID                 in out NOCOPY VARCHAR2,
   X_VAR_RENT_ID           in out NOCOPY NUMBER,
   X_RENT_NUM              in out NOCOPY VARCHAR2,
   X_LEASE_ID              in NUMBER,
   X_LOCATION_ID           in NUMBER,
   X_PRORATION_DAYS        in NUMBER,
   X_PURPOSE_CODE          in VARCHAR2,
   X_TYPE_CODE             in VARCHAR2,
   X_COMMENCEMENT_DATE     in DATE,
   X_TERMINATION_DATE      in DATE,
   X_ABSTRACTED_BY_USER    in NUMBER,
   X_CUMULATIVE_VOL        in VARCHAR2,
   X_ACCRUAL               in VARCHAR2,
   X_UOM_CODE              in VARCHAR2,
   --X_ROUNDING            in VARCHAR2,
   X_INVOICE_ON            in VARCHAR2,
   X_NEGATIVE_RENT         in VARCHAR2,
   X_TERM_TEMPLATE_ID      in NUMBER,
  -- codev  X_ABATEMENT_AMOUNT      in NUMBER,
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
   X_CURRENCY_CODE         in VARCHAR2,
   X_AGREEMENT_TEMPLATE_ID in NUMBER,
   X_PRORATION_RULE        in VARCHAR2,
   X_CHG_CAL_VAR_RENT_ID   in NUMBER
   )
IS

   CURSOR var_rents IS
      SELECT ROWID
      FROM   PN_VAR_RENTS_ALL
      WHERE  VAR_RENT_ID = X_VAR_RENT_ID ;

   CURSOR org_cur IS
     SELECT org_id FROM pn_leases_all WHERE lease_id = x_lease_id;
   l_org_ID NUMBER;


   l_return_status         VARCHAR2(30)    := NULL;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.INSERT_ROW (+)');

   -------------------------------------------------------
   -- Select the nextval for var rent id
   -------------------------------------------------------
   IF ( X_VAR_RENT_ID IS NULL) THEN
      SELECT  pn_var_rents_s.nextval
      INTO    X_VAR_RENT_ID
      FROM    dual;
   END IF;

   -- If rent_num is null then copy var_rent_id into rent_num.
   IF (X_RENT_NUM IS NULL) THEN
      X_RENT_NUM := X_VAR_RENT_ID;
   END IF;

   -- Check if rent number is unique
   l_return_status     := NULL;
   PN_VAR_RENTS_PKG.CHECK_UNIQUE_RENT_NUMBER
     (
         l_return_status,
         x_var_rent_id,
         x_rent_num,
         x_org_id
     );
   IF (l_return_status IS NOT NULL) THEN
      APP_EXCEPTION.Raise_Exception;
   END IF;

   IF x_org_id IS NULL THEN
      FOR rec IN org_cur LOOP
         l_org_id := rec.org_id;
      END LOOP;
   ELSE
      l_org_id := x_org_id;
   END IF;

   INSERT INTO PN_VAR_RENTS_ALL
   (
      VAR_RENT_ID,
      RENT_NUM,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      LEASE_ID,
      LOCATION_ID,
      PRORATION_DAYS,
      PURPOSE_CODE,
      TYPE_CODE,
      COMMENCEMENT_DATE,
      TERMINATION_DATE,
      ABSTRACTED_BY_USER,
      CUMULATIVE_VOL,
      ACCRUAL,
      UOM_CODE,
      --ROUNDING,
      INVOICE_ON,
      NEGATIVE_RENT,
      TERM_TEMPLATE_ID,
     -- codev  ABATEMENT_AMOUNT,
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
      CURRENCY_CODE,
      AGREEMENT_TEMPLATE_ID,
      PRORATION_RULE,
      CHG_CAL_VAR_RENT_ID
   )
   VALUES
   (
      X_VAR_RENT_ID,
      X_RENT_NUM,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_LEASE_ID,
      X_LOCATION_ID,
      X_PRORATION_DAYS,
      X_PURPOSE_CODE,
      X_TYPE_CODE,
      X_COMMENCEMENT_DATE,
      X_TERMINATION_DATE,
      X_ABSTRACTED_BY_USER,
      X_CUMULATIVE_VOL,
      X_ACCRUAL,
      X_UOM_CODE,
      --X_ROUNDING,
      X_INVOICE_ON,
      X_NEGATIVE_RENT,
      X_TERM_TEMPLATE_ID,
    -- codev  X_ABATEMENT_AMOUNT,
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
      X_CURRENCY_CODE,
      X_AGREEMENT_TEMPLATE_ID,
      X_PRORATION_RULE,
      X_CHG_CAL_VAR_RENT_ID
   );

   OPEN var_rents;
   FETCH var_rents INTO X_ROWID;
   IF (var_rents%notfound) THEN
      CLOSE var_rents;
      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE var_rents;

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_RENTS with _ALL table.
-------------------------------------------------------------------------------
procedure LOCK_ROW
(
   X_VAR_RENT_ID              in NUMBER,
   X_RENT_NUM                 in VARCHAR2,
   X_LEASE_ID                 in NUMBER,
   X_LOCATION_ID              in NUMBER,
   X_PRORATION_DAYS           in NUMBER,
   X_PURPOSE_CODE             in VARCHAR2,
   X_TYPE_CODE                in VARCHAR2,
   X_COMMENCEMENT_DATE        in DATE,
   X_TERMINATION_DATE         in DATE,
   X_ABSTRACTED_BY_USER       in NUMBER,
   X_CUMULATIVE_VOL           in VARCHAR2,
   X_ACCRUAL                  in VARCHAR2,
   X_UOM_CODE                 in VARCHAR2,
   X_INVOICE_ON               in VARCHAR2,
   X_NEGATIVE_RENT            in VARCHAR2,
   X_TERM_TEMPLATE_ID         in NUMBER,
 -- codev  X_ABATEMENT_AMOUNT         in NUMBER,
   X_ATTRIBUTE_CATEGORY       in VARCHAR2,
   X_ATTRIBUTE1               in VARCHAR2,
   X_ATTRIBUTE2               in VARCHAR2,
   X_ATTRIBUTE3               in VARCHAR2,
   X_ATTRIBUTE4               in VARCHAR2,
   X_ATTRIBUTE5               in VARCHAR2,
   X_ATTRIBUTE6               in VARCHAR2,
   X_ATTRIBUTE7               in VARCHAR2,
   X_ATTRIBUTE8               in VARCHAR2,
   X_ATTRIBUTE9               in VARCHAR2,
   X_ATTRIBUTE10              in VARCHAR2,
   X_ATTRIBUTE11              in VARCHAR2,
   X_ATTRIBUTE12              in VARCHAR2,
   X_ATTRIBUTE13              in VARCHAR2,
   X_ATTRIBUTE14              in VARCHAR2,
   X_ATTRIBUTE15              in VARCHAR2,
   X_CURRENCY_CODE            in VARCHAR2,
   X_AGREEMENT_TEMPLATE_ID    in NUMBER,
   X_PRORATION_RULE           in VARCHAR2,
   X_CHG_CAL_VAR_RENT_ID      in NUMBER
   )
IS

   CURSOR c1 IS
      SELECT *
      FROM PN_VAR_RENTS_ALL
      WHERE VAR_RENT_ID = X_VAR_RENT_ID
      FOR UPDATE OF VAR_RENT_ID NOWAIT;

   tlinfo c1%rowtype;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.LOCK_ROW (+)');

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%notfound) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;


   if (tlinfo.VAR_RENT_ID = X_VAR_RENT_ID) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_ID',tlinfo.VAR_RENT_ID);
   end if;
   if ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
            OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
   end if;
   if (tlinfo.LEASE_ID = X_LEASE_ID) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LEASE_ID',tlinfo.LEASE_ID);
   end if;
   if ((tlinfo.LOCATION_ID = X_LOCATION_ID)
            OR ((tlinfo.LOCATION_ID is null) AND (X_LOCATION_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LOCATION_ID',tlinfo.LOCATION_ID);
   end if;

   if ((tlinfo.PRORATION_DAYS = X_PRORATION_DAYS)
            OR ((tlinfo.PRORATION_DAYS is null) AND (X_PRORATION_DAYS is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PRORATION_DAYS',tlinfo.PRORATION_DAYS);
   end if;
   if (tlinfo.PURPOSE_CODE = X_PURPOSE_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PURPOSE_CODE',tlinfo.PURPOSE_CODE);
   end if;
   if (tlinfo.TYPE_CODE = X_TYPE_CODE) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('TYPE_CODE',tlinfo.TYPE_CODE);
   end if;
   if (trunc(tlinfo.COMMENCEMENT_DATE) = trunc(X_COMMENCEMENT_DATE)) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('COMMENCEMENT_DATE',tlinfo.COMMENCEMENT_DATE);
   end if;
   if (trunc(tlinfo.TERMINATION_DATE) = trunc(X_TERMINATION_DATE)) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('TERMINATION_DATE',tlinfo.TERMINATION_DATE);
   end if;
   if (tlinfo.ABSTRACTED_BY_USER = X_ABSTRACTED_BY_USER) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ABSTRACTED_BY_USER',tlinfo.ABSTRACTED_BY_USER);
   end if;
   if ((tlinfo.CUMULATIVE_VOL = X_CUMULATIVE_VOL)
            OR ((tlinfo.CUMULATIVE_VOL is null) AND (X_CUMULATIVE_VOL is null)))  then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CUMULATIVE_VOL',tlinfo.CUMULATIVE_VOL);
   end if;
   if ((tlinfo.ACCRUAL = X_ACCRUAL)
            OR ((tlinfo.ACCRUAL is null) AND (X_ACCRUAL is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ACCRUAL',tlinfo.ACCRUAL);
   end if;
   if ((tlinfo.UOM_CODE = X_UOM_CODE)
            OR ((tlinfo.UOM_CODE is null) AND (X_UOM_CODE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('UOM_CODE',tlinfo.UOM_CODE);
   end if;
   if (tlinfo.INVOICE_ON = X_INVOICE_ON) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('INVOICE_ON',tlinfo.INVOICE_ON);
   end if;
   if (tlinfo.NEGATIVE_RENT = X_NEGATIVE_RENT) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('NEGATIVE_RENT',tlinfo.NEGATIVE_RENT);
   end if;
   if ((tlinfo.TERM_TEMPLATE_ID = X_TERM_TEMPLATE_ID)
            OR ((tlinfo.TERM_TEMPLATE_ID is null) AND (X_TERM_TEMPLATE_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('TERM_TEMPLATE_ID',tlinfo.TERM_TEMPLATE_ID);
   end if;
   /* codev
   if ((tlinfo.ABATEMENT_AMOUNT = X_ABATEMENT_AMOUNT)
            OR ((tlinfo.ABATEMENT_AMOUNT is null) AND (X_ABATEMENT_AMOUNT is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ABATEMENT_AMOUNT',tlinfo.ABATEMENT_AMOUNT);
   end if; */
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
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   end if;
   if ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
            OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   end if;
   if ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
            OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   end if;
   if ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
            OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   end if;
   if ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
            OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   end if;
   if ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
            OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   end if;
   if ((tlinfo.RENT_NUM = X_RENT_NUM)
            OR ((tlinfo.RENT_NUM is null) AND (X_RENT_NUM is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
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
   if ((tlinfo.CURRENCY_CODE = X_CURRENCY_CODE)    --BUG#2452909
            OR ((tlinfo.CURRENCY_CODE is null) AND (X_CURRENCY_CODE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CURRENCY_CODE',tlinfo.CURRENCY_CODE);
   end if;
   if ((tlinfo.AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID)
            OR ((tlinfo.AGREEMENT_TEMPLATE_ID is null) AND (X_AGREEMENT_TEMPLATE_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AGREEMENT_TEMPLATE_ID',tlinfo.AGREEMENT_TEMPLATE_ID);
   end if;
   if ((tlinfo.PRORATION_RULE = X_PRORATION_RULE)
            OR ((tlinfo.PRORATION_RULE is null) AND (X_PRORATION_RULE is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PRORATION_RULE',tlinfo.PRORATION_RULE);
   end if;
   if ((tlinfo.CHG_CAL_VAR_RENT_ID = X_CHG_CAL_VAR_RENT_ID)
            OR ((tlinfo.CHG_CAL_VAR_RENT_ID is null) AND (X_CHG_CAL_VAR_RENT_ID is null))) then
      null;
   else
      PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('CHG_CAL_VAR_RENT_ID',tlinfo.CHG_CAL_VAR_RENT_ID);
   end if;

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug4284035- modified call to CHECK_UNIQUE_RENT_NUMBER
-------------------------------------------------------------------------------
procedure UPDATE_ROW
(
   X_VAR_RENT_ID              IN NUMBER,
   X_RENT_NUM                 IN VARCHAR2,
   X_LEASE_ID                 IN NUMBER,
   X_LOCATION_ID              IN NUMBER,
   X_PRORATION_DAYS           IN NUMBER,
   X_PURPOSE_CODE             IN VARCHAR2,
   X_TYPE_CODE                IN VARCHAR2,
   X_COMMENCEMENT_DATE        IN DATE,
   X_TERMINATION_DATE         IN DATE,
   X_ABSTRACTED_BY_USER       IN NUMBER,
   X_CUMULATIVE_VOL           IN VARCHAR2,
   X_ACCRUAL                  IN VARCHAR2,
   X_UOM_CODE                 IN VARCHAR2,
   --X_ROUNDING               IN VARCHAR2,
   X_INVOICE_ON               IN VARCHAR2,
   X_NEGATIVE_RENT            IN VARCHAR2,
   X_TERM_TEMPLATE_ID         IN NUMBER,
  -- codev  X_ABATEMENT_AMOUNT         IN NUMBER,
   X_ATTRIBUTE_CATEGORY       IN VARCHAR2,
   X_ATTRIBUTE1               IN VARCHAR2,
   X_ATTRIBUTE2               IN VARCHAR2,
   X_ATTRIBUTE3               IN VARCHAR2,
   X_ATTRIBUTE4               IN VARCHAR2,
   X_ATTRIBUTE5               IN VARCHAR2,
   X_ATTRIBUTE6               IN VARCHAR2,
   X_ATTRIBUTE7               IN VARCHAR2,
   X_ATTRIBUTE8               IN VARCHAR2,
   X_ATTRIBUTE9               IN VARCHAR2,
   X_ATTRIBUTE10              IN VARCHAR2,
   X_ATTRIBUTE11              IN VARCHAR2,
   X_ATTRIBUTE12              IN VARCHAR2,
   X_ATTRIBUTE13              IN VARCHAR2,
   X_ATTRIBUTE14              IN VARCHAR2,
   X_ATTRIBUTE15              IN VARCHAR2,
   X_LAST_UPDATE_DATE         IN DATE,
   X_LAST_UPDATED_BY          IN NUMBER,
   X_LAST_UPDATE_LOGIN        IN NUMBER,
   X_CURRENCY_CODE            IN VARCHAR2,
   X_AGREEMENT_TEMPLATE_ID    IN NUMBER,
   X_PRORATION_RULE           IN VARCHAR2,
   X_CHG_CAL_VAR_RENT_ID      in NUMBER
)
IS
   l_return_status         VARCHAR2(30)    := NULL;
   l_org_id                NUMBER;
BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.UPDATE_ROW (+)');

   -- Check if rent number is unique
   l_return_status     := NULL;

   SELECT  org_id
   INTO    l_org_id
   FROM    PN_VAR_RENTS_ALL      bkdetails
   WHERE VAR_RENT_ID    = X_VAR_RENT_ID;

   PN_VAR_RENTS_PKG.CHECK_UNIQUE_RENT_NUMBER
   (
      l_return_status,
      x_var_rent_id,
      x_rent_num,
      l_org_id
   );

   IF (l_return_status IS NOT NULL) THEN
      APP_EXCEPTION.Raise_Exception;
   END IF;

   UPDATE PN_VAR_RENTS_ALL
   SET
      VAR_RENT_ID             = X_VAR_RENT_ID,
      RENT_NUM                = X_RENT_NUM,
      LEASE_ID                = X_LEASE_ID,
      LOCATION_ID             = X_LOCATION_ID,
      PRORATION_DAYS          = X_PRORATION_DAYS,
      PURPOSE_CODE            = X_PURPOSE_CODE,
      TYPE_CODE               = X_TYPE_CODE,
      COMMENCEMENT_DATE       = X_COMMENCEMENT_DATE,
      TERMINATION_DATE        = X_TERMINATION_DATE,
      ABSTRACTED_BY_USER      = X_ABSTRACTED_BY_USER,
      CUMULATIVE_VOL          = X_CUMULATIVE_VOL,
      ACCRUAL                 = X_ACCRUAL,
      UOM_CODE                = X_UOM_CODE,
      --ROUNDING              = X_ROUNDING,
      INVOICE_ON              = X_INVOICE_ON,
      NEGATIVE_RENT           = X_NEGATIVE_RENT,
      TERM_TEMPLATE_ID        = X_TERM_TEMPLATE_ID,
   -- codev   ABATEMENT_AMOUNT        = X_ABATEMENT_AMOUNT,
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
      ATTRIBUTE15             = X_ATTRIBUTE15,
      LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY         = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN,
      CURRENCY_CODE           = X_CURRENCY_CODE,
      AGREEMENT_TEMPLATE_ID   = X_AGREEMENT_TEMPLATE_ID,
      PRORATION_RULE          = X_PRORATION_RULE,
      CHG_CAL_VAR_RENT_ID   = X_CHG_CAL_VAR_RENT_ID


   WHERE VAR_RENT_ID = X_VAR_RENT_ID
   ;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_RENTS with _ALL table.
-------------------------------------------------------------------------------

procedure DELETE_ROW
(
   X_VAR_RENT_ID in NUMBER
)
IS
BEGIN
   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.DELETE_ROW (+)');

   DELETE FROM PN_VAR_RENTS_ALL
   WHERE VAR_RENT_ID = X_VAR_RENT_ID;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.DELETE_ROW (-)');

END DELETE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : CHECK_UNIQUE_RENT_NUMBER
-- INVOKED FROM : UPDATE_ROW and INSERT_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Replaced PN_VAR_RENTS with _ALL table.
--                       Also removed the NVL around org id
-------------------------------------------------------------------------------
PROCEDURE CHECK_UNIQUE_RENT_NUMBER
(
   x_return_status     IN OUT NOCOPY  VARCHAR2,
   x_var_rent_id       IN             NUMBER,
   x_rent_num          IN             VARCHAR2,
   x_org_id            IN             NUMBER
)
IS
   l_dummy             NUMBER;
BEGIN
   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.check_UNIQUE_rent_number (+)');

   SELECT  1
   INTO    l_dummy
   FROM    dual
   WHERE   not exists
   (
      SELECT  1
      FROM    pn_var_rents_all   pnvr
      WHERE   pnvr.rent_num   = x_rent_num
      AND ((x_var_rent_id    is null) or
         (pnvr.var_rent_id  <> x_var_rent_id))
      AND  org_id = x_org_id
   );

   PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.check_UNIQUE_rent_number (-)');

   EXCEPTION
   WHEN NO_DATA_FOUND  THEN
   fnd_message.set_name ('PN','PN_DUP_LEASE_NUMBER');
   fnd_message.set_token('RENT_NUMBER', x_rent_num);
   x_return_status := 'E';
END CHECK_UNIQUE_RENT_NUMBER;



-------------------------------------------------------------------------------
-- PROCDURE     : CREATE_VAR_RENT_AGREEMENT
-- INVOKED FROM : INSERT_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 24-APR-06  pikhar o Added for Codev.
-------------------------------------------------------------------------------

PROCEDURE CREATE_VAR_RENT_AGREEMENT
( p_pn_var_rents_rec   IN pn_var_rents_all%rowtype DEFAULT NULL,
  p_var_rent_dates_rec IN pn_var_rent_dates_all%rowtype DEFAULT NULL,
  p_create_periods     IN VARCHAR2 DEFAULT 'N',
  x_var_rent_id        OUT NOCOPY NUMBER,
  x_var_rent_num       OUT NOCOPY VARCHAR2)

IS

   l_rowid VARCHAR2(500);
   l_var_rent_id NUMBER;
   l_var_rent_date_id NUMBER;
   l_var_rent_num  VARCHAR2(30);

BEGIN

   l_var_rent_num := p_pn_var_rents_rec.rent_num;

   pn_var_rents_pkg.insert_row (
      X_ROWID               => l_rowid,
      X_VAR_RENT_ID         => l_var_rent_id ,
      X_RENT_NUM            => l_var_rent_num,
      X_LEASE_ID            => p_pn_var_rents_Rec.lease_id,
      X_LOCATION_ID         => p_pn_var_rents_rec.location_id,
      X_CHG_CAL_VAR_RENT_ID => p_pn_var_rents_rec.chg_cal_var_rent_id,
      X_PRORATION_DAYS      => p_pn_var_rents_Rec.proration_days,
      X_PURPOSE_CODE        => p_pn_var_rents_rec.purpose_code,
      X_TYPE_CODE           => p_pn_var_rents_rec.type_code,
      X_COMMENCEMENT_DATE   => p_pn_var_rents_rec.commencement_date,
      X_TERMINATION_DATE    => p_pn_var_rents_rec.termination_date,
      X_ABSTRACTED_BY_USER  => p_pn_var_rents_rec.abstracted_by_user,
      X_CUMULATIVE_VOL      => p_pn_var_rents_rec.cumulative_vol,
      X_ACCRUAL             => p_pn_var_rents_rec.accrual,
      X_UOM_CODE            => p_pn_var_rents_rec.uom_code,
      X_INVOICE_ON          => p_pn_var_rents_rec.invoice_on,
      X_NEGATIVE_RENT       => p_pn_var_rents_rec.negative_rent,
      X_TERM_TEMPLATE_ID    => p_pn_var_rents_rec.term_template_id,
      --X_ABATEMENT_AMOUNT    => p_pn_var_rents_rec.abatement_amount,
      X_ATTRIBUTE_CATEGORY  => p_pn_var_rents_rec.attribute_category,
      X_ATTRIBUTE1          => p_pn_var_rents_rec.attribute1,
      X_ATTRIBUTE2          => p_pn_var_rents_rec.attribute2,
      X_ATTRIBUTE3          => p_pn_var_rents_rec.attribute3,
      X_ATTRIBUTE4          => p_pn_var_rents_rec.attribute4,
      X_ATTRIBUTE5          => p_pn_var_rents_rec.attribute5,
      X_ATTRIBUTE6          => p_pn_var_rents_rec.attribute6,
      X_ATTRIBUTE7          => p_pn_var_rents_rec.attribute7,
      X_ATTRIBUTE8          => p_pn_var_rents_rec.attribute8,
      X_ATTRIBUTE9          => p_pn_var_rents_rec.attribute9,
      X_ATTRIBUTE10         => p_pn_var_rents_rec.attribute10,
      X_ATTRIBUTE11         => p_pn_var_rents_rec.attribute11,
      X_ATTRIBUTE12         => p_pn_var_rents_rec.attribute12,
      X_ATTRIBUTE13         => p_pn_var_rents_rec.attribute13,
      X_ATTRIBUTE14         => p_pn_var_rents_rec.attribute14,
      X_ATTRIBUTE15         => p_pn_var_rents_rec.attribute15,
      X_ORG_ID              => p_pn_var_rents_rec.org_id,
      X_CREATION_DATE       => sysdate,
      X_CREATED_BY          => NVL(FND_PROFILE.VALUE('USER_ID'),1),
      X_LAST_UPDATE_DATE    => sysdate,
      X_LAST_UPDATED_BY     => NVL(FND_PROFILE.VALUE('USER_ID'),1),
      X_LAST_UPDATE_LOGIN   => NVL(FND_PROFILE.VALUE('LOGIN_ID'),1),
      X_CURRENCY_CODE       => p_pn_var_rents_rec.currency_code,
      X_PRORATION_RULE      => p_pn_var_rents_rec.proration_rule,
      X_AGREEMENT_TEMPLATE_ID => p_pn_var_rents_rec.agreement_template_id
      );

      l_rowid := NULL;
/*
   dbms_output.put_line('calling insert into pn_var_rent_dates_pkg.insert_row');
      pn_var_rent_dates_pkg.insert_row (
         X_ROWID              => l_rowid,
         X_VAR_RENT_DATE_ID   => l_var_rent_date_id,
         X_VAR_RENT_ID        => l_var_rent_id,
         X_GL_PERIOD_SET_NAME => p_var_rent_dates_rec.gl_period_set_name,
         X_PERIOD_FREQ_CODE   => p_var_rent_dates_rec.period_freq_code,
         X_REPTG_FREQ_CODE    => p_var_rent_dates_rec.reptg_freq_code,
         X_REPTG_DAY_OF_MONTH => p_var_rent_dates_rec.reptg_day_of_month,
         X_REPTG_DAYS_AFTER   => p_var_rent_dates_rec.reptg_days_after,
         X_INVG_FREQ_CODE     => p_var_rent_dates_rec.invg_freq_code,
         X_INVG_DAY_OF_MONTH  => p_var_rent_dates_rec.invg_day_of_month,
         X_INVG_DAYS_AFTER    => p_var_rent_dates_rec.invg_days_after,
         X_INVG_SPREAD_CODE   => p_var_rent_dates_rec.invg_spread_code,
         X_INVG_TERM          => p_var_rent_dates_rec.invg_term,
         X_AUDIT_FREQ_CODE    => p_var_rent_dates_rec.audit_freq_code,
         X_AUDIT_DAY_OF_MONTH => p_var_rent_dates_rec.audit_day_of_month,
         X_AUDIT_DAYS_AFTER   => p_var_rent_dates_rec.audit_days_after,
         X_RECON_FREQ_CODE    => p_var_rent_dates_rec.recon_Freq_code,
         X_RECON_DAY_OF_MONTH => p_var_rent_dates_rec.recon_day_of_month,
         X_RECON_DAYS_AFTER   => p_var_rent_dates_rec.recon_days_after,
         X_ATTRIBUTE_CATEGORY  => p_var_rent_dates_rec.attribute_category,
         X_ATTRIBUTE1          => p_var_rent_dates_rec.attribute1,
         X_ATTRIBUTE2          => p_var_rent_dates_rec.attribute2,
         X_ATTRIBUTE3          => p_var_rent_dates_rec.attribute3,
         X_ATTRIBUTE4          => p_var_rent_dates_rec.attribute4,
         X_ATTRIBUTE5          => p_var_rent_dates_rec.attribute5,
         X_ATTRIBUTE6          => p_var_rent_dates_rec.attribute6,
         X_ATTRIBUTE7          => p_var_rent_dates_rec.attribute7,
         X_ATTRIBUTE8          => p_var_rent_dates_rec.attribute8,
         X_ATTRIBUTE9          => p_var_rent_dates_rec.attribute9,
         X_ATTRIBUTE10         => p_var_rent_dates_rec.attribute10,
         X_ATTRIBUTE11         => p_var_rent_dates_rec.attribute11,
         X_ATTRIBUTE12         => p_var_rent_dates_rec.attribute12,
         X_ATTRIBUTE13         => p_var_rent_dates_rec.attribute13,
         X_ATTRIBUTE14         => p_var_rent_dates_rec.attribute14,
         X_ATTRIBUTE15         => p_var_rent_dates_rec.attribute15,
         X_ORG_ID              => p_var_rent_dates_rec.org_id,
         X_CREATION_DATE       => sysdate,
         X_CREATED_BY          => NVL(FND_PROFILE.VALUE('USER_ID'),1),
         X_LAST_UPDATE_DATE    => sysdate,
         X_LAST_UPDATED_BY     => NVL(FND_PROFILE.VALUE('USER_ID'),1),
         X_LAST_UPDATE_LOGIN   => NVL(FND_PROFILE.VALUE('LOGIN_ID'),1),
         X_USE_GL_CALENDAR      => p_var_rent_dates_rec.use_gl_calendar,
         X_PERIOD_TYPE          => p_var_rent_dates_rec.period_type,
         X_YEAR_START_DATE      => p_var_rent_dates_rec.year_start_date,
         X_COMMENTS            => p_var_rent_dates_rec.comments,
         X_EFFECTIVE_DATE      => p_var_rent_dates_rec.effective_date);
*/
   x_var_rent_id := l_var_rent_id ;
   x_var_rent_num := l_var_rent_num ;

   IF p_create_periods = 'Y' THEN
      pn_var_rent_pkg.create_var_rent_periods(
         p_var_rent_id => l_var_rent_id,
         p_cumulative_vol => p_pn_var_rents_rec.cumulative_vol,
         p_comm_date      => p_pn_var_rents_rec.commencement_date,
         p_term_date      => p_pn_var_rents_rec.termination_date);
   END IF;

EXCEPTION
  WHEN OTHERS THEN
  /*dbms_output.put_line(sqlerrm); */
  null;
END create_var_rent_agreement;
-------------------------------------------------------------------------------
-- PROCDURE     : MODIF_VAR_RENT
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : modifies the row to change excess_abat_code,order_of_appl_code
-- HISTORY      :
-- 03-DEC-06  lbala  o Created for codev .
-------------------------------------------------------------------------------
PROCEDURE MODIF_VAR_RENT(x_var_rent_id IN NUMBER,
                         x_excess_abat_code IN VARCHAR2,
                         x_order_of_appl_code IN VARCHAR2)
IS
BEGIN
PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.MODIF_VAR_RENT (+)');

   UPDATE pn_var_rents_all
   SET excess_abat_code = x_excess_abat_code,
       order_of_appl_code = x_order_of_appl_code,
       LAST_UPDATE_DATE  = sysdate,
       LAST_UPDATED_BY   = NVL(fnd_profile.value('USER_ID'),-1),
       LAST_UPDATE_LOGIN = NVL(fnd_profile.value('USER_ID'),-1)
   WHERE var_rent_id=x_var_rent_id ;

   IF (sql%notfound) THEN
      RAISE NO_DATA_FOUND;
   END IF;

PNP_DEBUG_PKG.debug ('PN_VAR_RENTS_PKG.MODIF_VAR_RENT (-)');

END MODIF_VAR_RENT;

-------------------------------------------------------------------------------------
--  NAME         : DELETE_VAR_RENT_AGREEMENT
--  DESCRIPTION  : This procedure deletes all VR agreements with commencement date
--                 after early termination date of the lease and no approved schedules
--  HISTORY      :
--  12/12/06   lbala  Created
--------------------------------------------------------------------------------------

PROCEDURE DELETE_VAR_RENT_AGREEMENT(p_lease_id IN NUMBER,
                                    p_termination_dt IN DATE)
IS
CURSOR get_var_rents(p1_lease_id IN NUMBER,p1_termination_dt IN DATE) IS
SELECT var_rent_id
FROM pn_var_rents_all vrent
WHERE lease_id = p1_lease_id
AND commencement_date > p1_termination_dt
AND NOT EXISTS ( SELECT NULL
                 FROM pn_payment_schedules_all ps,
                      pn_payment_items_all     pi,
                      pn_payment_terms_all     pterm
                 WHERE pi.PAYMENT_SCHEDULE_ID = ps.PAYMENT_SCHEDULE_ID
                   AND  pi.PAYMENT_TERM_ID    = pterm.PAYMENT_TERM_ID
                   AND  pterm.var_rent_inv_id IN (SELECT var_rent_inv_id FROM pn_var_rent_inv_all
                                                  WHERE var_rent_id= vrent.var_rent_id
                                                  )
                   AND  ps.PAYMENT_STATUS_LOOKUP_CODE='APPROVED'
               );

l_varent_id NUMBER :=NULL;
p_term_date DATE   :=NULL;

BEGIN

FOR var_rent_rec IN get_var_rents(p_lease_id,p_termination_dt) LOOP

   l_varent_id := var_rent_rec.var_rent_id;

   PN_VAR_RENT_PKG.delete_var_rent_periods(l_varent_id);

   PN_VAR_TRX_PKG.delete_transactions( p_var_rent_id => l_varent_id
                                      ,p_period_id  => NULL
                                      ,p_line_item_id => NULL);

   DELETE FROM pn_var_rent_dates_all
   WHERE var_rent_id=l_varent_id;

   DELETE FROM pn_var_rents_all
   WHERE var_rent_id=l_varent_id;

   IF SQL%NOTFOUND THEN
     NULL;
   END IF;

END LOOP;

END delete_var_rent_agreement;

END PN_VAR_RENTS_PKG;

/
