--------------------------------------------------------
--  DDL for Package Body PNT_PAYMENT_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_PAYMENT_ITEMS_PKG" AS
  -- $Header: PNTPYITB.pls 120.4 2005/11/27 09:30:45 appldev ship $

-------------------------------------------------------------------------------
-- PROCEDURE    : Insert_Row
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  hrodda  o Bug 4284035 - Replaced pn_payment_items
--                      with _ALL table.
-- 19-OCT-05  pikhar  o get ORG_ID based on if we are in R12 or 11i
-- 24-NOV-05  Kiran   o round amounts before insert
-------------------------------------------------------------------------------
PROCEDURE Insert_Row (
              X_ROWID                          IN OUT NOCOPY VARCHAR2,
              X_PAYMENT_ITEM_ID                IN OUT NOCOPY NUMBER,
              X_DUE_DATE                       IN     DATE,
              X_SET_OF_BOOKS_ID                IN     NUMBER,
              X_CURRENCY_CODE                  IN     VARCHAR2,
              X_EXPORT_CURRENCY_CODE           IN     VARCHAR2,
              X_RATE                           IN     NUMBER,
              X_PMT_ITEM_TYPE_LOOKUP_CODE      IN     VARCHAR2,
              X_PAYMENT_SCHEDULE_ID            IN     NUMBER,
              X_PAYMENT_TERM_ID                IN OUT NOCOPY NUMBER,
              X_VENDOR_ID                      IN     NUMBER,
              X_CUSTOMER_ID                    IN     NUMBER,
              X_VENDOR_SITE_ID                 IN     NUMBER,
              X_CUSTOMER_SITE_USE_ID           IN     NUMBER,
              X_ACTUAL_AMOUNT                  IN     NUMBER,
              X_ACCOUNTED_AMOUNT               IN     NUMBER,
              X_ACCOUNTED_DATE                 IN     DATE,
              X_EXPORT_CURRENCY_AMOUNT         IN     NUMBER,
              X_ESTIMATED_AMOUNT               IN     NUMBER,
              X_CREATION_DATE                  IN     DATE,
              X_CREATED_BY                     IN     NUMBER,
              X_LAST_UPDATE_DATE               IN     DATE,
              X_LAST_UPDATED_BY                IN     NUMBER,
              X_LAST_UPDATE_LOGIN              IN     NUMBER,
              X_ENTERED_BY_LEASE               IN     VARCHAR2,
              X_EXPORT_TO_AP_FLAG              IN     VARCHAR2,
              X_EXPORT_TO_AR_FLAG              IN     VARCHAR2,
              X_CUST_SHIP_SITE_ID              IN     NUMBER,
              x_org_id                         IN     NUMBER,
              x_comments                       IN     VARCHAR2,
              x_AP_INVOICE_NUM                 IN     VARCHAR2,
              x_GROUPING_RULE_ID               IN     NUMBER,
              x_adj_start_date                 IN     DATE,
              x_ADJ_END_DATE                   IN     DATE,
              x_LAST_ADJUSTMENT_TYPE_CODE      IN     VARCHAR2,
              x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
              x_ATTRIBUTE1                     IN     VARCHAR2,
              x_ATTRIBUTE2                     IN     VARCHAR2,
              x_ATTRIBUTE3                     IN     VARCHAR2,
              x_ATTRIBUTE4                     IN     VARCHAR2,
              x_ATTRIBUTE5                     IN     VARCHAR2,
              x_ATTRIBUTE6                     IN     VARCHAR2,
              x_ATTRIBUTE7                     IN     VARCHAR2,
              x_ATTRIBUTE8                     IN     VARCHAR2,
              x_ATTRIBUTE9                     IN     VARCHAR2,
              x_ATTRIBUTE10                    IN     VARCHAR2,
              x_ATTRIBUTE11                    IN     VARCHAR2,
              x_ATTRIBUTE12                    IN     VARCHAR2,
              x_ATTRIBUTE13                    IN     VARCHAR2,
              x_ATTRIBUTE14                    IN     VARCHAR2,
              x_ATTRIBUTE15                    IN     VARCHAR2
                     )
IS

  CURSOR c IS
  SELECT ROWID
  FROM   PN_PAYMENT_ITEMS_ALL
  WHERE  PAYMENT_ITEM_ID = X_PAYMENT_ITEM_ID;

  l_org_id NUMBER;

  CURSOR org_cur IS
    SELECT org_id FROM pn_payment_terms_all WHERE payment_term_ID = X_PAYMENT_TERM_ID ;

  l_precision     NUMBER;
  l_ext_precision NUMBER;
  l_min_acct_unit NUMBER;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_PAYMENT_ITEMS_PKG.insert_row (+)');

   /* get currency info for rounding */
   fnd_currency.get_info( currency_code => x_currency_code
                         ,precision     => l_precision
                         ,ext_precision => l_ext_precision
                         ,min_acct_unit => l_min_acct_unit);

   IF x_payment_item_id IS NULL THEN

      SELECT pn_payment_items_s.NEXTVAL
      INTO   x_payment_item_id
      FROM   DUAL;

   END IF;

   IF NOT(pn_mo_cache_utils.is_MOAC_enabled) THEN
     l_org_ID := fnd_profile.value('ORG_ID');
   ELSE
     IF x_org_ID IS NULL THEN
       FOR rec IN org_cur LOOP
         l_org_id := rec.org_id;
       END LOOP;
     ELSE
       l_org_ID := x_org_ID;
     END IF;
   END IF;

   INSERT INTO pn_payment_items_all (
                                 PAYMENT_ITEM_ID,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 DUE_DATE,
                                 SET_OF_BOOKS_ID,
                                 CURRENCY_CODE,
                                 EXPORT_CURRENCY_CODE,
                                 RATE,
                                 PAYMENT_ITEM_TYPE_LOOKUP_CODE,
                                 PAYMENT_SCHEDULE_ID,
                                 PAYMENT_TERM_ID,
                                 VENDOR_ID,
                                 CUSTOMER_ID,
                                 VENDOR_SITE_ID,
                                 CUSTOMER_SITE_USE_ID,
                                 ACTUAL_AMOUNT,
                                 ACCOUNTED_AMOUNT,
                                 ACCOUNTED_DATE,
                                 EXPORT_CURRENCY_AMOUNT,
                                 ESTIMATED_AMOUNT,
                                 ENTERED_BY_LEASE,
                                 EXPORT_TO_AP_FLAG ,
                                 EXPORT_TO_AR_FLAG,
                                 CUST_SHIP_SITE_ID,
                                 org_id,
                                 COMMENTS,
                                 AP_INVOICE_NUM,
                                 GROUPING_RULE_ID,
                                 ADJ_START_DATE,
                                 ADJ_END_DATE,
                                 LAST_ADJUSTMENT_TYPE_CODE,
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
                                 ATTRIBUTE15
                               )
   VALUES                       (
                                 X_PAYMENT_ITEM_ID,
                                 X_LAST_UPDATE_DATE,
                                 X_LAST_UPDATED_BY,
                                 X_CREATION_DATE,
                                 X_CREATED_BY,
                                 X_LAST_UPDATE_LOGIN,
                                 X_DUE_DATE,
                                 X_SET_OF_BOOKS_ID,
                                 X_CURRENCY_CODE,
                                 X_EXPORT_CURRENCY_CODE,
                                 X_RATE,
                                 X_PMT_ITEM_TYPE_LOOKUP_CODE,
                                 X_PAYMENT_SCHEDULE_ID,
                                 X_PAYMENT_TERM_ID,
                                 X_VENDOR_ID,
                                 X_CUSTOMER_ID,
                                 X_VENDOR_SITE_ID,
                                 X_CUSTOMER_SITE_USE_ID,
                                 ROUND(X_ACTUAL_AMOUNT,l_precision),
                                 ROUND(X_ACCOUNTED_AMOUNT,l_precision),
                                 trunc(X_ACCOUNTED_DATE),
                                 ROUND(X_EXPORT_CURRENCY_AMOUNT,l_precision),
                                 ROUND(X_ESTIMATED_AMOUNT,l_precision),
                                 X_ENTERED_BY_LEASE,
                                 X_EXPORT_TO_AP_FLAG,
                                 X_EXPORT_TO_AR_FLAG,
                                 X_CUST_SHIP_SITE_ID,
                                 l_org_id,
                                 X_COMMENTS,
                                 X_AP_INVOICE_NUM,
                                 X_GROUPING_RULE_ID,
                                 X_ADJ_START_DATE,
                                 X_ADJ_END_DATE,
                                 X_LAST_ADJUSTMENT_TYPE_CODE,
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
                                 X_ATTRIBUTE15

                               );
   OPEN C;
      FETCH C INTO X_ROWID;
      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE C;

   PNP_DEBUG_PKG.debug ('PN_PAYMENT_ITEMS_PKG.insert_row (-)');

END Insert_Row;

-------------------------------------------------------------------------------
-- PROCEDURE    : Lock_Row
-- INVOKED FROM : Lock_Row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  hrodda  o Bug 4284035 - Replaced pn_payment_items
--                      with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row (
              x_PAYMENT_ITEM_ID                IN     NUMBER,
              x_ESTIMATED_AMOUNT               IN     NUMBER,
              x_ACTUAL_AMOUNT                  IN     NUMBER,
              x_PAYMENT_SCHEDULE_ID            IN     NUMBER,
              x_DUE_DATE                       IN     DATE,
              x_RATE                           IN     NUMBER,
              x_COMMENTS                       IN     VARCHAR2,
              x_AP_INVOICE_NUM                 IN     VARCHAR2,
              x_GROUPING_RULE_ID               IN     NUMBER,
              x_ADJ_START_DATE                 IN     DATE,
              x_ADJ_END_DATE                   IN     DATE,
              x_LAST_ADJUSTMENT_TYPE_CODE      IN     VARCHAR2,
              x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
              x_ATTRIBUTE1                     IN     VARCHAR2,
              x_ATTRIBUTE2                     IN     VARCHAR2,
              x_ATTRIBUTE3                     IN     VARCHAR2,
              x_ATTRIBUTE4                     IN     VARCHAR2,
              x_ATTRIBUTE5                     IN     VARCHAR2,
              x_ATTRIBUTE6                     IN     VARCHAR2,
              x_ATTRIBUTE7                     IN     VARCHAR2,
              x_ATTRIBUTE8                     IN     VARCHAR2,
              x_ATTRIBUTE9                     IN     VARCHAR2,
              x_ATTRIBUTE10                    IN     VARCHAR2,
              x_ATTRIBUTE11                    IN     VARCHAR2,
              x_ATTRIBUTE12                    IN     VARCHAR2,
              x_ATTRIBUTE13                    IN     VARCHAR2,
              x_ATTRIBUTE14                    IN     VARCHAR2,
              x_ATTRIBUTE15                    IN     VARCHAR2
                   )
IS

  CURSOR c1 IS
  SELECT *
  FROM   pn_payment_items_all
  WHERE  payment_item_id = x_payment_item_id
  FOR    UPDATE OF payment_item_id NOWAIT;

  tlinfo c1%ROWTYPE;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_PAYMENT_ITEMS_PKG.lock_row (+)');
   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.PAYMENT_ITEM_ID = X_PAYMENT_ITEM_ID) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_ITEM_ID',tlinfo.PAYMENT_ITEM_ID);
   END IF;

   IF NOT ((tlinfo.ESTIMATED_AMOUNT = X_ESTIMATED_AMOUNT)
       OR ((tlinfo.ESTIMATED_AMOUNT IS NULL) AND (X_ESTIMATED_AMOUNT IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ESTIMATED_AMOUNT',tlinfo.ESTIMATED_AMOUNT);
   END IF;

   IF NOT ((tlinfo.ACTUAL_AMOUNT = X_ACTUAL_AMOUNT)
       OR ((tlinfo.ACTUAL_AMOUNT IS NULL) AND (X_ACTUAL_AMOUNT IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ACTUAL_AMOUNT',tlinfo.ACTUAL_AMOUNT);
   END IF;

   IF NOT ((tlinfo.PAYMENT_SCHEDULE_ID = X_PAYMENT_SCHEDULE_ID)
       OR ((tlinfo.PAYMENT_SCHEDULE_ID IS NULL) AND (X_PAYMENT_SCHEDULE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_SCHEDULE_ID',tlinfo.PAYMENT_SCHEDULE_ID);
   END IF;

   IF NOT ((tlinfo.DUE_DATE = X_DUE_DATE)
       OR ((tlinfo.DUE_DATE IS NULL) AND (X_DUE_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('DUE_DATE',tlinfo.DUE_DATE);
   END IF;

   IF NOT ((tlinfo.RATE = X_RATE)
       OR ((tlinfo.RATE IS NULL) AND (X_RATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RATE',tlinfo.RATE);
   END IF;

   IF NOT ((tlinfo.COMMENTS = X_COMMENTS)
       OR ((tlinfo.COMMENTS IS NULL) AND (X_COMMENTS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('COMMENTS',tlinfo.COMMENTS);
   END IF;

   IF NOT ((tlinfo.AP_INVOICE_NUM = X_AP_INVOICE_NUM)
       OR ((tlinfo.AP_INVOICE_NUM IS NULL) AND (X_AP_INVOICE_NUM IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AP_INVOICE_NUM',tlinfo.AP_INVOICE_NUM);
   END IF;

   IF NOT ((tlinfo.GROUPING_RULE_ID = X_GROUPING_RULE_ID)
       OR ((tlinfo.GROUPING_RULE_ID IS NULL) AND (X_GROUPING_RULE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('GROUPING_RULE_ID',tlinfo.GROUPING_RULE_ID);
   END IF;

   IF NOT ((tlinfo.ADJ_START_DATE = X_ADJ_START_DATE)
       OR ((tlinfo.ADJ_START_DATE IS NULL) AND (X_ADJ_START_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ADJ_START_DATE',tlinfo.ADJ_START_DATE);
   END IF;

   IF NOT ((tlinfo.ADJ_END_DATE = X_ADJ_END_DATE)
       OR ((tlinfo.ADJ_END_DATE IS NULL) AND (X_ADJ_END_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ADJ_END_DATE',tlinfo.ADJ_END_DATE);
   END IF;

   IF NOT ((tlinfo.LAST_ADJUSTMENT_TYPE_CODE = X_LAST_ADJUSTMENT_TYPE_CODE)
       OR ((tlinfo.LAST_ADJUSTMENT_TYPE_CODE IS NULL) AND (X_LAST_ADJUSTMENT_TYPE_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LAST_ADJUSTMENT_TYPE_CODE',tlinfo.LAST_ADJUSTMENT_TYPE_CODE);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
       OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL) AND (X_ATTRIBUTE_CATEGORY IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlinfo.ATTRIBUTE_CATEGORY);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
       OR ((tlinfo.ATTRIBUTE1 IS NULL) AND (X_ATTRIBUTE1 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
       OR ((tlinfo.ATTRIBUTE2 IS NULL) AND (X_ATTRIBUTE2 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlinfo.ATTRIBUTE2);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
       OR ((tlinfo.ATTRIBUTE3 IS NULL) AND (X_ATTRIBUTE3 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlinfo.ATTRIBUTE3);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
       OR ((tlinfo.ATTRIBUTE4 IS NULL) AND (X_ATTRIBUTE4 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlinfo.ATTRIBUTE4);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
       OR ((tlinfo.ATTRIBUTE5 IS NULL) AND (X_ATTRIBUTE5 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlinfo.ATTRIBUTE5);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
       OR ((tlinfo.ATTRIBUTE6 IS NULL) AND (X_ATTRIBUTE6 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlinfo.ATTRIBUTE6);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
       OR ((tlinfo.ATTRIBUTE7 IS NULL) AND (X_ATTRIBUTE7 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlinfo.ATTRIBUTE7);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
       OR ((tlinfo.ATTRIBUTE8 IS NULL) AND (X_ATTRIBUTE8 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlinfo.ATTRIBUTE8);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
       OR ((tlinfo.ATTRIBUTE9 IS NULL) AND (X_ATTRIBUTE9 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
       OR ((tlinfo.ATTRIBUTE10 IS NULL) AND (X_ATTRIBUTE10 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlinfo.ATTRIBUTE10);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
       OR ((tlinfo.ATTRIBUTE11 IS NULL) AND (X_ATTRIBUTE11 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlinfo.ATTRIBUTE11);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
       OR ((tlinfo.ATTRIBUTE12 IS NULL) AND (X_ATTRIBUTE12 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlinfo.ATTRIBUTE12);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
       OR ((tlinfo.ATTRIBUTE13 IS NULL) AND (X_ATTRIBUTE13 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlinfo.ATTRIBUTE13);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
       OR ((tlinfo.ATTRIBUTE14 IS NULL) AND (X_ATTRIBUTE14 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlinfo.ATTRIBUTE14);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
       OR ((tlinfo.ATTRIBUTE15 IS NULL) AND (X_ATTRIBUTE15 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
   END IF;

   RETURN;
   PNP_DEBUG_PKG.debug ('PN_PAYMENT_ITEMS_PKG.lock_row (-)');

END Lock_Row;

-------------------------------------------------------------------------------
-- PROCEDURE    : Update_Row
-- INVOKED FROM : Update_Row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  hrodda  o Bug 4284035 - Replaced pn_payment_items with _ALL table
-- 24-NOV-05  Kiran   o round amounts before update
-------------------------------------------------------------------------------
PROCEDURE Update_Row (
              X_PAYMENT_ITEM_ID                IN     NUMBER,
              X_DUE_DATE                       IN     DATE,
              X_VENDOR_ID                      IN     NUMBER,
              X_CUSTOMER_ID                    IN     NUMBER,
              X_VENDOR_SITE_ID                 IN     NUMBER,
              X_CUSTOMER_SITE_USE_ID           IN     NUMBER,
              X_ESTIMATED_AMOUNT               IN     NUMBER,
              X_ACTUAL_AMOUNT                  IN     NUMBER,
              X_ACCOUNTED_AMOUNT               IN     NUMBER,
              X_ACCOUNTED_DATE                 IN     DATE,
              X_EXPORT_CURRENCY_AMOUNT         IN     NUMBER,
              X_LAST_UPDATE_DATE               IN     DATE,
              X_LAST_UPDATED_BY                IN     NUMBER,
              X_LAST_UPDATE_LOGIN              IN     NUMBER,
              X_PAYMENT_SCHEDULE_ID            IN     NUMBER,
              X_ENTERED_BY_LEASE               IN     VARCHAR2,
              X_EXPORT_TO_AP_FLAG              IN     VARCHAR2,
              X_EXPORT_TO_AR_FLAG              IN     VARCHAR2,
              X_CUST_SHIP_SITE_ID              IN     NUMBER,
              X_RATE                           IN     NUMBER,
              x_comments                       IN     VARCHAR2,
              x_AP_INVOICE_NUM                 IN     VARCHAR2,
              x_GROUPING_RULE_ID               IN     NUMBER,
              x_ADJ_START_DATE                 IN     DATE,
              x_ADJ_END_DATE                   IN     DATE,
              x_LAST_ADJUSTMENT_TYPE_CODE      IN     VARCHAR2,
              x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
              x_ATTRIBUTE1                     IN     VARCHAR2,
              x_ATTRIBUTE2                     IN     VARCHAR2,
              x_ATTRIBUTE3                     IN     VARCHAR2,
              x_ATTRIBUTE4                     IN     VARCHAR2,
              x_ATTRIBUTE5                     IN     VARCHAR2,
              x_ATTRIBUTE6                     IN     VARCHAR2,
              x_ATTRIBUTE7                     IN     VARCHAR2,
              x_ATTRIBUTE8                     IN     VARCHAR2,
              x_ATTRIBUTE9                     IN     VARCHAR2,
              x_ATTRIBUTE10                    IN     VARCHAR2,
              x_ATTRIBUTE11                    IN     VARCHAR2,
              x_ATTRIBUTE12                    IN     VARCHAR2,
              x_ATTRIBUTE13                    IN     VARCHAR2,
              x_ATTRIBUTE14                    IN     VARCHAR2,
              x_ATTRIBUTE15                    IN     VARCHAR2
                     )
IS

  l_precision     NUMBER;
  l_ext_precision NUMBER;
  l_min_acct_unit NUMBER;

   CURSOR currency_cur IS
     SELECT currency_code FROM pn_payment_items_all WHERE payment_item_id = X_PAYMENT_ITEM_ID;
BEGIN

   PNP_DEBUG_PKG.debug ('PN_PAYMENT_ITEMS_PKG.update_row (+)');

   /* get currency info for rounding */
   FOR rec IN currency_cur LOOP
     fnd_currency.get_info( currency_code => rec.currency_code
                           ,precision     => l_precision
                           ,ext_precision => l_ext_precision
                           ,min_acct_unit => l_min_acct_unit);
   END LOOP;

   UPDATE pn_payment_items_all
   SET    VENDOR_ID                       = X_VENDOR_ID,
          DUE_DATE                        = X_DUE_DATE,
          CUSTOMER_ID                     = X_CUSTOMER_ID,
          VENDOR_SITE_ID                  = X_VENDOR_SITE_ID,
          CUSTOMER_SITE_USE_ID            = X_CUSTOMER_SITE_USE_ID,
          ESTIMATED_AMOUNT                = ROUND(X_ESTIMATED_AMOUNT,l_precision),
          ACTUAL_AMOUNT                   = ROUND(X_ACTUAL_AMOUNT,l_precision),
          ACCOUNTED_AMOUNT                = ROUND(X_ACCOUNTED_AMOUNT,l_precision),
          ACCOUNTED_DATE                  = trunc(X_ACCOUNTED_DATE),
          EXPORT_CURRENCY_AMOUNT          = ROUND(X_EXPORT_CURRENCY_AMOUNT,l_precision),
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
          PAYMENT_SCHEDULE_ID             = X_PAYMENT_SCHEDULE_ID,
          ENTERED_BY_LEASE                = X_ENTERED_BY_LEASE,
          EXPORT_TO_AP_FLAG               = X_EXPORT_TO_AP_FLAG,
          EXPORT_TO_AR_FLAG               = X_EXPORT_TO_AR_FLAG,
          CUST_SHIP_SITE_ID               = X_CUST_SHIP_SITE_ID,
          RATE                            = X_RATE,
          COMMENTS                        = X_COMMENTS,
          AP_INVOICE_NUM                  = x_AP_INVOICE_NUM,
          GROUPING_RULE_ID                = x_GROUPING_RULE_ID,
          ADJ_START_DATE                  = x_ADJ_START_DATE,
          ADJ_END_DATE                    = x_ADJ_END_DATE,
          LAST_ADJUSTMENT_TYPE_CODE       = x_LAST_ADJUSTMENT_TYPE_CODE,
          ATTRIBUTE_CATEGORY              = x_ATTRIBUTE_CATEGORY,
          ATTRIBUTE1                      = x_ATTRIBUTE1,
          ATTRIBUTE2                      = x_ATTRIBUTE2,
          ATTRIBUTE3                      = x_ATTRIBUTE3,
          ATTRIBUTE4                      = x_ATTRIBUTE4,
          ATTRIBUTE5                      = x_ATTRIBUTE5,
          ATTRIBUTE6                      = x_ATTRIBUTE6,
          ATTRIBUTE7                      = x_ATTRIBUTE7,
          ATTRIBUTE8                      = x_ATTRIBUTE8,
          ATTRIBUTE9                      = x_ATTRIBUTE9,
          ATTRIBUTE10                     = x_ATTRIBUTE10,
          ATTRIBUTE11                     = x_ATTRIBUTE11,
          ATTRIBUTE12                     = x_ATTRIBUTE12,
          ATTRIBUTE13                     = x_ATTRIBUTE13,
          ATTRIBUTE14                     = x_ATTRIBUTE14,
          ATTRIBUTE15                     = x_ATTRIBUTE15
   WHERE  PAYMENT_ITEM_ID                 = X_PAYMENT_ITEM_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   PNP_DEBUG_PKG.debug ('PN_PAYMENT_ITEMS_PKG.update_row (-)');

END Update_Row;

-------------------------------------------------------------------------------
-- PROCEDURE    : Delete_Row
-- INVOKED FROM : Delete_Row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  hrodda  o Bug 4284035 - Replaced pn_payment_items
--                      with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row (
                        X_PAYMENT_ITEM_ID               IN     NUMBER
                     )
IS
BEGIN

   DELETE FROM pn_payment_items_all
   WHERE payment_item_id = x_payment_item_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_Row;


END pnt_payment_items_pkg;

/
