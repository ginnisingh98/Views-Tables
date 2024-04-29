--------------------------------------------------------
--  DDL for Package Body PN_EXP_PAYMENT_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_EXP_PAYMENT_ITEMS_PKG" AS
  -- $Header: PNTEXPIB.pls 120.3 2006/08/11 11:41:34 sdmahesh ship $

-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced PN_PAYMENT_ITEMS,PN_PAYMENT_SCHEDULES
--                                     with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE LOCK_ROW (
  X_PAYMENT_ITEM_ID      IN NUMBER,
  X_EXPORT_TO_AP_FLAG    IN VARCHAR2,
  X_EXPORT_TO_AR_FLAG    IN VARCHAR2,
  X_EXPORT_CURRENCY_CODE IN VARCHAR2,
  X_RATE                 IN NUMBER,
  X_PAYMENT_SCHEDULE_ID  IN NUMBER,
  X_PERIOD_NAME          IN VARCHAR2,
  X_DUE_DATE             IN DATE,
  X_AP_INVOICE_NUM       IN VARCHAR2,
  X_GROUPING_RULE_ID     IN NUMBER
) IS

  CURSOR c1 IS
    SELECT  EXPORT_TO_AP_FLAG,
            EXPORT_TO_AR_FLAG,
            EXPORT_CURRENCY_CODE,
            RATE,
            DUE_DATE,
            AP_INVOICE_NUM,
            GROUPING_RULE_ID
    FROM    PN_PAYMENT_ITEMS_ALL
    WHERE   PAYMENT_ITEM_ID = X_PAYMENT_ITEM_ID
    FOR UPDATE OF PAYMENT_ITEM_ID NOWAIT;

  CURSOR c2 IS
    SELECT  PERIOD_NAME
    FROM    PN_PAYMENT_SCHEDULES_ALL
    WHERE   PAYMENT_SCHEDULE_ID = X_PAYMENT_SCHEDULE_ID
    FOR UPDATE OF PAYMENT_SCHEDULE_ID NOWAIT;

  tlinfo c1%ROWTYPE;
  tlinfo2 c2%ROWTYPE;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    RETURN;
  END IF;
  CLOSE c1;

  OPEN c2;
  FETCH c2 INTO tlinfo2;
  IF (c2%NOTFOUND) THEN
    CLOSE c2;
    RETURN;
  END IF;
  CLOSE c2;

  IF (((tlinfo.EXPORT_TO_AP_FLAG = X_EXPORT_TO_AP_FLAG)
          OR ((tlinfo.EXPORT_TO_AP_FLAG IS NULL)
               AND (X_EXPORT_TO_AP_FLAG IS NULL)))
      AND ((tlinfo.EXPORT_TO_AR_FLAG = X_EXPORT_TO_AR_FLAG)
          OR ((tlinfo.EXPORT_TO_AR_FLAG IS NULL)
               AND (X_EXPORT_TO_AR_FLAG IS NULL)))
      AND ((tlinfo.EXPORT_CURRENCY_CODE = X_EXPORT_CURRENCY_CODE)
          OR ((tlinfo.EXPORT_CURRENCY_CODE IS NULL)
               AND (X_EXPORT_CURRENCY_CODE IS NULL)))
      AND ((tlinfo.RATE = X_RATE)
          OR ((tlinfo.RATE IS NULL)
               AND (X_RATE IS NULL)))
      AND ((tlinfo2.PERIOD_NAME = X_PERIOD_NAME)
          OR ((tlinfo2.PERIOD_NAME IS NULL)
               AND (X_PERIOD_NAME IS NULL)))
      AND ((tlinfo.DUE_DATE = X_DUE_DATE)
          OR ((tlinfo.DUE_DATE IS NULL)
               AND (X_DUE_DATE IS NULL)))
      AND ((tlinfo.AP_INVOICE_NUM = X_AP_INVOICE_NUM)
          OR ((tlinfo.AP_INVOICE_NUM IS NULL)
               AND (X_AP_INVOICE_NUM IS NULL)))
      AND ((tlinfo.GROUPING_RULE_ID = X_GROUPING_RULE_ID)
          OR ((tlinfo.GROUPING_RULE_ID IS NULL)
               AND (X_GROUPING_RULE_ID IS NULL)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raISe_exception;
  END IF;

  RETURN;
END LOCK_ROW;

--------------------------------------------------------------------------------
-- PROCEDURE: UPDATE ROW
-- PURPOSE: row handler for pn_payment_item from the export to AP/AR perspective
-- INVOKED: from table_handler program unit in PNTXPPMT.fmb
-- HISTORY:
-- 28-MAR-02  ftanudja  o added parameters x_norm_itm_id, x_norm_exp_amt,
--                        x_export_amount. updated table with new value for
--                        normalized items
-- 10-DEC-03  atuppad   o Added code for the updating of 3 columns: DUE_DATE,
--                        GROUPING_RULE_ID and AP_INVOICE_NUM
-- 15-JUL-05  hareesha o Bug 4284035 - Replaced PN_PAYMENT_ITEMS with _ALL table
-- 24-NOV-05  Kiran    o round amount before insert/update into term/item
-- 10-AUG-06  sdmahesh o Bug 5283912
--                       Updated accounted_amount in pn_payment_items_all as
--                       actual_amount * x_rate
--------------------------------------------------------------------------------

PROCEDURE UPDATE_ROW (
  X_PAYMENT_ITEM_ID      IN NUMBER,
  X_EXPORT_TO_AP_FLAG    IN VARCHAR2,
  X_EXPORT_TO_AR_FLAG    IN VARCHAR2,
  X_EXPORT_AMOUNT        IN NUMBER,
  X_NORM_ITM_ID          IN NUMBER,
  X_NORM_EXP_AMT         IN NUMBER,
  X_EXPORT_CURRENCY_CODE IN VARCHAR2,
  X_RATE                 IN NUMBER,
  X_LAST_UPDATE_DATE     IN DATE,
  X_LAST_UPDATED_BY      IN NUMBER,
  X_LAST_UPDATE_LOGIN    IN NUMBER,
  X_PAYMENT_SCHEDULE_ID  IN NUMBER,
  X_PERIOD_NAME          IN VARCHAR2,
  X_DUE_DATE             IN DATE,
  X_AP_INVOICE_NUM       IN VARCHAR2,
  X_GROUPING_RULE_ID     IN NUMBER
)
IS
   l_info_text VARCHAR2(100);
   l_precision       NUMBER;
   l_ext_precision   NUMBER;
   l_min_acct_unit   NUMBER;
   l_export_amt      NUMBER;
   l_norm_export_amt NUMBER;

BEGIN

   IF x_export_currency_code IS NOT NULL THEN
      fnd_currency.get_info( currency_code => x_export_currency_code
                            ,precision     => l_precision
                            ,ext_precision => l_ext_precision
                            ,min_acct_unit => l_min_acct_unit);
   END IF;

   IF l_precision IS NOT NULL THEN
      l_export_amt      := ROUND(x_export_amount, l_precision);
      l_norm_export_amt := ROUND(x_norm_exp_amt, l_precision);
   ELSE
      l_export_amt      := x_export_amount;
      l_norm_export_amt := x_norm_exp_amt;
   END IF;

  l_info_text := 'updating normalized item amount';
  IF X_NORM_ITM_ID IS NOT NULL THEN
     UPDATE PN_PAYMENT_ITEMS_ALL
     SET    export_currency_amount = l_norm_export_amt,
            export_currency_code = x_export_currency_code,
            rate = x_rate,
            accounted_amount = actual_amount * x_rate,
            last_update_date = x_last_update_date,
            last_updated_by = x_last_updated_by,
            last_update_login = x_last_update_login
     WHERE  payment_item_id = x_norm_itm_id;
  END IF;

  l_info_text := 'updating cash item data';
  UPDATE PN_PAYMENT_ITEMS_ALL
  SET    EXPORT_TO_AP_FLAG = X_EXPORT_TO_AP_FLAG,
         EXPORT_TO_AR_FLAG = X_EXPORT_TO_AR_FLAG,
         EXPORT_CURRENCY_AMOUNT = l_export_amt,
         EXPORT_CURRENCY_CODE = X_EXPORT_CURRENCY_CODE,
         RATE = X_RATE,
         ACCOUNTED_AMOUNT = ACTUAL_AMOUNT * X_RATE,
         DUE_DATE = X_DUE_DATE,
         AP_INVOICE_NUM = X_AP_INVOICE_NUM,
         GROUPING_RULE_ID = X_GROUPING_RULE_ID,
         LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = X_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE  PAYMENT_ITEM_ID = X_PAYMENT_ITEM_ID;

  l_info_text := 'updating associated payment schedule';
  UPDATE PN_PAYMENT_SCHEDULES_ALL
  SET    PERIOD_NAME = X_PERIOD_NAME
  WHERE  PAYMENT_SCHEDULE_ID = X_PAYMENT_SCHEDULE_ID;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      raISe_application_error(-20001,'Error while ' || l_info_text || to_char(sqlcode));
      app_exception.raISe_exception;
END update_row;

END pn_exp_payment_items_pkg;

/
