--------------------------------------------------------
--  DDL for Package Body PN_VAR_RENT_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_RENT_INV_PKG" AS
/* $Header: PNVRINVB.pls 120.8 2007/04/24 07:52:19 lbala noship $ */


--------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_RENT_INV with _ALL table
-- 28-NOV-05  pikhar   o fetched org_id using cursor
-- 18-AUG-06  Pikhar   o Added credit_flag,true_up_amount,true_up_status
--                       and true_up_exp_code
--------------------------------------------------------------------------------


procedure INSERT_ROW (
    X_ROWID                  IN OUT NOCOPY VARCHAR2,
    X_VAR_RENT_INV_ID        IN OUT NOCOPY NUMBER,
    X_ADJUST_NUM             IN NUMBER,
    X_INVOICE_DATE           IN DATE,
    X_FOR_PER_RENT           IN NUMBER,
    X_TOT_ACT_VOL            IN NUMBER,
    X_ACT_PER_RENT           IN NUMBER,
    X_CONSTR_ACTUAL_RENT     IN NUMBER,
    X_ABATEMENT_APPL         IN NUMBER,
    X_REC_ABATEMENT          IN NUMBER,
    X_REC_ABATEMENT_OVERRIDE IN NUMBER,
    X_NEGATIVE_RENT          IN NUMBER,
    X_ACTUAL_INVOICED_AMOUNT IN NUMBER,
    X_PERIOD_ID              IN NUMBER,
    X_VAR_RENT_ID            IN NUMBER,
    X_FORECASTED_TERM_STATUS IN VARCHAR2,
    X_VARIANCE_TERM_STATUS   IN VARCHAR2,
    X_ACTUAL_TERM_STATUS     IN VARCHAR2,
    X_FORECASTED_EXP_CODE    IN VARCHAR2,
    X_VARIANCE_EXP_CODE      IN VARCHAR2,
    X_ACTUAL_EXP_CODE        IN VARCHAR2,
    X_COMMENTS               IN VARCHAR2,
    X_ATTRIBUTE_CATEGORY     IN VARCHAR2,
    X_ATTRIBUTE1             IN VARCHAR2,
    X_ATTRIBUTE2             IN VARCHAR2,
    X_ATTRIBUTE3             IN VARCHAR2,
    X_ATTRIBUTE4             IN VARCHAR2,
    X_ATTRIBUTE5             IN VARCHAR2,
    X_ATTRIBUTE6             IN VARCHAR2,
    X_ATTRIBUTE7             IN VARCHAR2,
    X_ATTRIBUTE8             IN VARCHAR2,
    X_ATTRIBUTE9             IN VARCHAR2,
    X_ATTRIBUTE10            IN VARCHAR2,
    X_ATTRIBUTE11            IN VARCHAR2,
    X_ATTRIBUTE12            IN VARCHAR2,
    X_ATTRIBUTE13            IN VARCHAR2,
    X_ATTRIBUTE14            IN VARCHAR2,
    X_ATTRIBUTE15            IN VARCHAR2,
    X_CREATION_DATE          IN DATE,
    X_CREATED_BY             IN NUMBER,
    X_LAST_UPDATE_DATE       IN DATE,
    X_LAST_UPDATED_BY        IN NUMBER,
    X_LAST_UPDATE_LOGIN      IN NUMBER,
    X_ORG_ID                 IN NUMBER,
    X_CREDIT_FLAG            IN VARCHAR2,
    X_TRUE_UP_AMOUNT         IN NUMBER,
    X_TRUE_UP_STATUS         IN VARCHAR2,
    X_TRUE_UP_EXP_CODE       IN VARCHAR2
) IS
  CURSOR C IS
    SELECT ROWID
    FROM PN_VAR_RENT_INV_ALL
    WHERE VAR_RENT_INV_ID = X_VAR_RENT_INV_ID;

  CURSOR org_cur IS
    SELECT org_id
    FROM PN_VAR_RENTS_ALL
    WHERE VAR_RENT_ID = X_VAR_RENT_ID;

  l_org_id      NUMBER;
  l_precision   NUMBER;

BEGIN


   PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.INSERT_ROW (+)');

    -------------------------------------------------------
    -- We need to generate the var_rent_INv_id
    -------------------------------------------------------

     IF x_org_id IS NULL THEN
       FOR rec IN org_cur LOOP
        l_org_id := rec.org_id;
       END LOOP;
     ELSE
       l_org_id := x_org_id;
     END IF;

     IF (X_VAR_RENT_INV_ID IS NULL)  THEN
         SELECT PN_VAR_RENT_INV_S.nextval
         INTO X_VAR_RENT_INV_ID
         FROM dual;
     END IF;

     l_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(l_org_id),4);

  INSERT INTO PN_VAR_RENT_INV_ALL (
    VAR_RENT_INV_ID,
    ADJUST_NUM,
    INVOICE_DATE,
    FOR_PER_RENT,
    TOT_ACT_VOL,
    ACT_PER_RENT,
    CONSTR_ACTUAL_RENT,
    ABATEMENT_APPL,
    REC_ABATEMENT,
    REC_ABATEMENT_OVERRIDE,
    NEGATIVE_RENT,
    ACTUAL_INVOICED_AMOUNT,
    PERIOD_ID,
    VAR_RENT_ID,
    FORECASTED_TERM_STATUS,
    VARIANCE_TERM_STATUS,
    ACTUAL_TERM_STATUS,
    FORECASTED_EXP_CODE,
    VARIANCE_EXP_CODE,
    ACTUAL_EXP_CODE,
    COMMENTS,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
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
    CREDIT_FLAG,
    TRUE_UP_AMT,
    TRUE_UP_STATUS,
    TRUE_UP_EXP_CODE
  ) VALUES
  ( X_VAR_RENT_INV_ID,
    X_ADJUST_NUM,
    X_INVOICE_DATE,
    ROUND(X_FOR_PER_RENT, l_precision),
    ROUND(X_TOT_ACT_VOL, l_precision),   -- bug # 6007571
    ROUND(X_ACT_PER_RENT, l_precision),
    ROUND(X_CONSTR_ACTUAL_RENT, l_precision),
    X_ABATEMENT_APPL,
    X_REC_ABATEMENT,
    X_REC_ABATEMENT_OVERRIDE,
    X_NEGATIVE_RENT,
    ROUND(X_ACTUAL_INVOICED_AMOUNT, l_precision),
    X_PERIOD_ID,
    X_VAR_RENT_ID,
    X_FORECASTED_TERM_STATUS,
    X_VARIANCE_TERM_STATUS,
    X_ACTUAL_TERM_STATUS,
    X_FORECASTED_EXP_CODE,
    X_VARIANCE_EXP_CODE,
    X_ACTUAL_EXP_CODE,
    X_COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
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
    l_ORG_ID,
    X_CREDIT_FLAG,
    X_TRUE_UP_AMOUNT,
    X_TRUE_UP_STATUS,
    X_TRUE_UP_EXP_CODE);

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

  PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-----------------------------------------------------------------------
---- PROCEDURE : LOCK_ROW_EXCEPTION
-----------------------------------------------------------------------

procedure lock_row_exception (p_column_name IN varchar2,
                              p_new_value   IN varchar2)
IS
BEGIN
       PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.LOCK_ROW_EXCEPTION (+)');

       fnd_message.set_name ('PN','PN_RECORD_CHANGED');
       fnd_message.set_token ('COLUMN_NAME',p_column_name);
       fnd_message.set_token ('NEW_VALUE',p_new_value);
       app_exception.RAISE_exception;

       PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.LOCK_ROW_EXCEPTION (-)');
END lock_row_exception;


-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_RENT_INV with _ALL table.
-------------------------------------------------------------------------------



procedure LOCK_ROW (
   X_VAR_RENT_INV_ID        IN NUMBER,
   X_ADJUST_NUM             IN NUMBER,
   X_INVOICE_DATE           IN DATE,
   X_FOR_PER_RENT           IN NUMBER,
   X_TOT_ACT_VOL            IN NUMBER,
   X_ACT_PER_RENT           IN NUMBER,
   X_CONSTR_ACTUAL_RENT     IN NUMBER,
   X_ABATEMENT_APPL         IN NUMBER,
   X_REC_ABATEMENT          IN NUMBER,
   X_REC_ABATEMENT_OVERRIDE IN NUMBER,
   X_NEGATIVE_RENT          IN NUMBER,
   X_ACTUAL_INVOICED_AMOUNT IN NUMBER,
   X_PERIOD_ID              IN NUMBER,
   X_VAR_RENT_ID            IN NUMBER,
   X_FORECASTED_TERM_STATUS IN VARCHAR2,
   X_VARIANCE_TERM_STATUS   IN VARCHAR2,
   X_ACTUAL_TERM_STATUS     IN VARCHAR2,
   X_FORECASTED_EXP_CODE    IN VARCHAR2,
   X_VARIANCE_EXP_CODE      IN VARCHAR2,
   X_ACTUAL_EXP_CODE        IN VARCHAR2,
   X_COMMENTS               IN VARCHAR2,
   X_ATTRIBUTE_CATEGORY     IN VARCHAR2,
   X_ATTRIBUTE1             IN VARCHAR2,
   X_ATTRIBUTE2             IN VARCHAR2,
   X_ATTRIBUTE3             IN VARCHAR2,
   X_ATTRIBUTE4             IN VARCHAR2,
   X_ATTRIBUTE5             IN VARCHAR2,
   X_ATTRIBUTE6             IN VARCHAR2,
   X_ATTRIBUTE7             IN VARCHAR2,
   X_ATTRIBUTE8             IN VARCHAR2,
   X_ATTRIBUTE9             IN VARCHAR2,
   X_ATTRIBUTE10            IN VARCHAR2,
   X_ATTRIBUTE11            IN VARCHAR2,
   X_ATTRIBUTE12            IN VARCHAR2,
   X_ATTRIBUTE13            IN VARCHAR2,
   X_ATTRIBUTE14            IN VARCHAR2,
   X_ATTRIBUTE15            IN VARCHAR2
) IS
  CURSOR c1 IS
  SELECT *
  FROM PN_VAR_RENT_INV_ALL
  WHERE VAR_RENT_INV_ID = X_VAR_RENT_INV_ID
  FOR UPDATE OF VAR_RENT_INV_ID nowait;

  tlINfo   c1%ROWTYPE;

BEGIN
     PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.LOCK_ROW (+)');

     OPEN c1;
       FETCH c1 INTO tlINfo;
       IF (c1%NOTFOUND) THEN
      CLOSE c1;
      RETURN;
       END IF;
     CLOSE c1;

     IF (tlINfo.VAR_RENT_INV_ID = X_VAR_RENT_INV_ID) THEN
            NULL;
     ELSE
            lock_row_exception('VAR_RENT_INV_ID',TO_CHAR(tlINfo.VAR_RENT_INV_ID));
     END IF;

     IF (tlINfo.ADJUST_NUM = X_ADJUST_NUM) THEN
            NULL;
     ELSE
            lock_row_exception('ADJUST_NUM',TO_CHAR(tlINfo.ADJUST_NUM));
     END IF;

     IF (tlINfo.INVOICE_DATE = X_INVOICE_DATE) THEN
       NULL;
     ELSE
       lock_row_exception('INVOICE_DATE',TO_CHAR(tlINfo.INVOICE_DATE));
     END IF;


     IF ((tlINfo.FOR_PER_RENT = X_FOR_PER_RENT)
           OR ((tlINfo.FOR_PER_RENT IS NULL) AND (X_FOR_PER_RENT IS NULL))) THEN
            NULL;
     ELSE
            lock_row_exception('FOR_PER_RENT',TO_CHAR(tlINfo.FOR_PER_RENT));
     END IF;

     IF ((tlINfo.TOT_ACT_VOL = X_TOT_ACT_VOL)
           OR ((tlINfo.TOT_ACT_VOL IS NULL) AND (X_TOT_ACT_VOL IS NULL))) THEN
            NULL;
     ELSE
            lock_row_exception('TOT_ACT_VOL',TO_CHAR(tlINfo.TOT_ACT_VOL));
     END IF;

     IF ((tlINfo.ACT_PER_RENT = X_ACT_PER_RENT)
          OR ((tlINfo.ACT_PER_RENT IS NULL) AND (X_ACT_PER_RENT IS NULL))) THEN
            NULL;
     ELSE
       lock_row_exception('ACT_PER_RENT',TO_CHAR(tlINfo.ACT_PER_RENT));
     END IF;

     IF ((tlINfo.CONSTR_ACTUAL_RENT = X_CONSTR_ACTUAL_RENT)
          OR ((tlINfo.CONSTR_ACTUAL_RENT IS NULL) AND (X_CONSTR_ACTUAL_RENT IS NULL))) THEN
            NULL;
     ELSE
          lock_row_exception('CONSTR_ACTUAL_RENT',TO_CHAR(tlINfo.CONSTR_ACTUAL_RENT));
     END IF;


     IF ((tlINfo.ABATEMENT_APPL = X_ABATEMENT_APPL)
         OR ((tlINfo.ABATEMENT_APPL IS NULL) AND (X_ABATEMENT_APPL IS NULL))) THEN
           NULL;
     ELSE
            lock_row_exception('ABATEMENT_APPL',TO_CHAR(tlINfo.ABATEMENT_APPL));
     END IF;

     IF ((tlINfo.REC_ABATEMENT = X_REC_ABATEMENT)
         OR ((tlINfo.REC_ABATEMENT IS NULL) AND (X_REC_ABATEMENT IS NULL))) THEN
           NULL;
     ELSE
           lock_row_exception('REC_ABATEMENT',TO_CHAR(tlINfo.REC_ABATEMENT));
     END IF;

     IF ((tlINfo.REC_ABATEMENT_OVERRIDE = X_REC_ABATEMENT_OVERRIDE)
         OR ((tlINfo.REC_ABATEMENT_OVERRIDE IS NULL) AND (X_REC_ABATEMENT_OVERRIDE IS NULL))) THEN
           NULL;
     ELSE
           lock_row_exception('REC_ABATEMENT_OVERRIDE',TO_CHAR(tlINfo.REC_ABATEMENT_OVERRIDE));
     END IF;

     IF ((tlINfo.NEGATIVE_RENT = X_NEGATIVE_RENT)
         OR ((tlINfo.NEGATIVE_RENT IS NULL) AND (X_NEGATIVE_RENT IS NULL))) THEN
           NULL;
     ELSE
           lock_row_exception('NEGATIVE_RENT',TO_CHAR(tlINfo.NEGATIVE_RENT));
     END IF;


     IF ((tlINfo.ACTUAL_INVOICED_AMOUNT = X_ACTUAL_INVOICED_AMOUNT)
         OR ((tlINfo.ACTUAL_INVOICED_AMOUNT IS NULL) AND (X_ACTUAL_INVOICED_AMOUNT IS NULL))) THEN
           NULL;
     ELSE
      lock_row_exception('ACTUAL_INVOICED_AMOUNT',TO_CHAR(tlINfo.ACTUAL_INVOICED_AMOUNT));
     END IF;

     IF (tlINfo.PERIOD_ID = X_PERIOD_ID) THEN
           NULL;
     ELSE
      lock_row_exception('PERIOD_ID',TO_CHAR(tlINfo.PERIOD_ID));
     END IF;

     IF (tlINfo.VAR_RENT_ID = X_VAR_RENT_ID) THEN
           NULL;
     ELSE
      lock_row_exception('VAR_RENT_ID',TO_CHAR(tlINfo.VAR_RENT_ID));
     END IF;

     IF (tlINfo.FORECASTED_TERM_STATUS = X_FORECASTED_TERM_STATUS) THEN
           NULL;
     ELSE
           lock_row_exception('FORECASTED_TERM_STATUS',tlINfo.FORECASTED_TERM_STATUS);
     END IF;


     IF (tlINfo.VARIANCE_TERM_STATUS = X_VARIANCE_TERM_STATUS) THEN
           NULL;
     ELSE
         lock_row_exception('VARIANCE_TERM_STATUS',tlINfo.VARIANCE_TERM_STATUS);
     END IF;


     IF (tlINfo.ACTUAL_TERM_STATUS = X_ACTUAL_TERM_STATUS) THEN
           NULL;
     ELSE
            lock_row_exception('ACTUAL_TERM_STATUS',tlINfo.ACTUAL_TERM_STATUS);
     END IF;


     IF (tlINfo.FORECASTED_EXP_CODE = X_FORECASTED_EXP_CODE) THEN
           NULL;
     ELSE
           lock_row_exception('FORECASTED_EXP_CODE',tlINfo.FORECASTED_EXP_CODE);
     END IF;


     IF (tlINfo.VARIANCE_EXP_CODE = X_VARIANCE_EXP_CODE) THEN
           NULL;
     ELSE
           lock_row_exception('VARIANCE_EXP_CODE',tlINfo.VARIANCE_EXP_CODE);
     END IF;


     IF (tlINfo.ACTUAL_EXP_CODE = X_ACTUAL_EXP_CODE) THEN
           NULL;
     ELSE
           lock_row_exception('ACTUAL_EXP_CODE',tlINfo.ACTUAL_EXP_CODE);
     END IF;


     IF ((tlINfo.COMMENTS = X_COMMENTS)
         OR ((tlINfo.COMMENTS IS NULL) AND (X_COMMENTS IS NULL))) THEN
           NULL;
     ELSE
           lock_row_exception('COMMENTS',tlINfo.COMMENTS);
     END IF;

     IF ((tlINfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
         OR ((tlINfo.ATTRIBUTE_CATEGORY IS NULL) AND (X_ATTRIBUTE_CATEGORY IS NULL))) THEN
           NULL;
     ELSE
      lock_row_exception('ATTRIBUTE_CATEGORY',tlINfo.ATTRIBUTE_CATEGORY);
     END IF;

     IF ((tlINfo.ATTRIBUTE1 = X_ATTRIBUTE1)
         OR ((tlINfo.ATTRIBUTE1 IS NULL) AND (X_ATTRIBUTE1 IS NULL))) THEN
            NULL;
     ELSE
       lock_row_exception('ATTRIBUTE1',tlINfo.ATTRIBUTE1);
     END IF;

     IF ((tlINfo.ATTRIBUTE2 = X_ATTRIBUTE2)
         OR ((tlINfo.ATTRIBUTE2 IS NULL) AND (X_ATTRIBUTE2 IS NULL))) THEN
            NULL;
     ELSE
       lock_row_exception('ATTRIBUTE2',tlINfo.ATTRIBUTE2);
     END IF;

     IF ((tlINfo.ATTRIBUTE3 = X_ATTRIBUTE3)
         OR ((tlINfo.ATTRIBUTE3 IS NULL) AND (X_ATTRIBUTE3 IS NULL))) THEN
            NULL;
     ELSE
       lock_row_exception('ATTRIBUTE3',tlINfo.ATTRIBUTE3);
     END IF;


     IF ((tlINfo.ATTRIBUTE4 = X_ATTRIBUTE4)
         OR ((tlINfo.ATTRIBUTE4 IS NULL) AND (X_ATTRIBUTE4 IS NULL))) THEN
            NULL;
     ELSE
       lock_row_exception('ATTRIBUTE4',tlINfo.ATTRIBUTE4);
     END IF;


     IF ((tlINfo.ATTRIBUTE5 = X_ATTRIBUTE5)
         OR ((tlINfo.ATTRIBUTE5 IS NULL) AND (X_ATTRIBUTE5 IS NULL))) THEN
            NULL;
     ELSE
       lock_row_exception('ATTRIBUTE5',tlINfo.ATTRIBUTE5);
     END IF;


     IF ((tlINfo.ATTRIBUTE6 = X_ATTRIBUTE6)
         OR ((tlINfo.ATTRIBUTE6 IS NULL) AND (X_ATTRIBUTE6 IS NULL))) THEN
            NULL;
     ELSE
          lock_row_exception('ATTRIBUTE6',tlINfo.ATTRIBUTE6);
     END IF;


     IF ((tlINfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlINfo.ATTRIBUTE7 IS NULL) AND (X_ATTRIBUTE7 IS NULL))) THEN
           NULL;
     ELSE
          lock_row_exception('ATTRIBUTE7',tlINfo.ATTRIBUTE7);
     END IF;

     IF ((tlINfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlINfo.ATTRIBUTE8 IS NULL) AND (X_ATTRIBUTE8 IS NULL))) THEN
           NULL;
     ELSE
          lock_row_exception('ATTRIBUTE8',tlINfo.ATTRIBUTE8);
     END IF;

     IF ((tlINfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlINfo.ATTRIBUTE9 IS NULL) AND (X_ATTRIBUTE9 IS NULL))) THEN
           NULL;
     ELSE
      lock_row_exception('ATTRIBUTE9',tlINfo.ATTRIBUTE9);
     END IF;


     IF ((tlINfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlINfo.ATTRIBUTE10 IS NULL) AND (X_ATTRIBUTE10 IS NULL))) THEN
           NULL;
     ELSE
     lock_row_exception('ATTRIBUTE10',tlINfo.ATTRIBUTE10);
     END IF;


     IF ((tlINfo.ATTRIBUTE11 = X_ATTRIBUTE11)
         OR ((tlINfo.ATTRIBUTE11 IS NULL) AND (X_ATTRIBUTE11 IS NULL))) THEN
           NULL;
     ELSE
      lock_row_exception('ATTRIBUTE11',tlINfo.ATTRIBUTE11);
     END IF;


     IF ((tlINfo.ATTRIBUTE12 = X_ATTRIBUTE12)
         OR ((tlINfo.ATTRIBUTE12 IS NULL) AND (X_ATTRIBUTE12 IS NULL))) THEN
           NULL;
     ELSE
         lock_row_exception('ATTRIBUTE12',tlINfo.ATTRIBUTE12);
     END IF;


     IF ((tlINfo.ATTRIBUTE13 = X_ATTRIBUTE13)
         OR ((tlINfo.ATTRIBUTE13 IS NULL) AND (X_ATTRIBUTE13 IS NULL))) THEN
           NULL;
     ELSE
      lock_row_exception('ATTRIBUTE13',tlINfo.ATTRIBUTE13);
     END IF;


     IF ((tlINfo.ATTRIBUTE14 = X_ATTRIBUTE14)
         OR ((tlINfo.ATTRIBUTE14 IS NULL) AND (X_ATTRIBUTE14 IS NULL))) THEN
           NULL;
     ELSE
      lock_row_exception('ATTRIBUTE14',tlINfo.ATTRIBUTE14);
     END IF;


     IF ((tlINfo.ATTRIBUTE15 = X_ATTRIBUTE15)
         OR ((tlINfo.ATTRIBUTE15 IS NULL) AND (X_ATTRIBUTE15 IS NULL))) THEN
           NULL;
     ELSE
      lock_row_exception('ATTRIBUTE15',tlINfo.ATTRIBUTE15);
     END IF;



    PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.LOCK_ROW (-)');

END LOCK_ROW;



-------------------------------------------------------------------------------
-- PROCDURE     : update_row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_RENT_INV with _ALL table
-------------------------------------------------------------------------------


procedure UPDATE_ROW (
   X_VAR_RENT_INV_ID        IN NUMBER,
   X_ADJUST_NUM             IN NUMBER,
   X_INVOICE_DATE           IN DATE,
   X_FOR_PER_RENT           IN NUMBER,
   X_TOT_ACT_VOL            IN NUMBER,
   X_ACT_PER_RENT           IN NUMBER,
   X_CONSTR_ACTUAL_RENT     IN NUMBER,
   X_ABATEMENT_APPL         IN NUMBER,
   X_REC_ABATEMENT          IN NUMBER,
   X_REC_ABATEMENT_OVERRIDE IN NUMBER,
   X_NEGATIVE_RENT          IN NUMBER,
   X_ACTUAL_INVOICED_AMOUNT IN NUMBER,
   X_PERIOD_ID              IN NUMBER,
   X_VAR_RENT_ID            IN NUMBER,
   X_FORECASTED_TERM_STATUS IN VARCHAR2,
   X_VARIANCE_TERM_STATUS   IN VARCHAR2,
   X_ACTUAL_TERM_STATUS     IN VARCHAR2,
   X_FORECASTED_EXP_CODE    IN VARCHAR2,
   X_VARIANCE_EXP_CODE      IN VARCHAR2,
   X_ACTUAL_EXP_CODE        IN VARCHAR2,
   X_COMMENTS               IN VARCHAR2,
   X_ATTRIBUTE_CATEGORY     IN VARCHAR2,
   X_ATTRIBUTE1             IN VARCHAR2,
   X_ATTRIBUTE2             IN VARCHAR2,
   X_ATTRIBUTE3             IN VARCHAR2,
   X_ATTRIBUTE4             IN VARCHAR2,
   X_ATTRIBUTE5             IN VARCHAR2,
   X_ATTRIBUTE6             IN VARCHAR2,
   X_ATTRIBUTE7             IN VARCHAR2,
   X_ATTRIBUTE8             IN VARCHAR2,
   X_ATTRIBUTE9             IN VARCHAR2,
   X_ATTRIBUTE10            IN VARCHAR2,
   X_ATTRIBUTE11            IN VARCHAR2,
   X_ATTRIBUTE12            IN VARCHAR2,
   X_ATTRIBUTE13            IN VARCHAR2,
   X_ATTRIBUTE14            IN VARCHAR2,
   X_ATTRIBUTE15            IN VARCHAR2,
   X_LAST_UPDATE_DATE       IN DATE,
   X_LAST_UPDATED_BY        IN NUMBER,
   X_LAST_UPDATE_LOGIN      IN NUMBER
) IS

l_precision  NUMBER;

BEGIN

  PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.UPDATE_ROW (+)');

  l_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(),4);

 UPDATE PN_VAR_RENT_INV_ALL SET
   ADJUST_NUM             = X_ADJUST_NUM,
   INVOICE_DATE           = X_INVOICE_DATE,
   FOR_PER_RENT           = ROUND(X_FOR_PER_RENT, l_precision),
   TOT_ACT_VOL            = ROUND(X_TOT_ACT_VOL, l_precision),
   ACT_PER_RENT           = ROUND(X_ACT_PER_RENT, l_precision),
   CONSTR_ACTUAL_RENT     = ROUND(X_CONSTR_ACTUAL_RENT, l_precision),
   ABATEMENT_APPL         = X_ABATEMENT_APPL,
   REC_ABATEMENT          = X_REC_ABATEMENT,
   REC_ABATEMENT_OVERRIDE = X_REC_ABATEMENT_OVERRIDE,
   NEGATIVE_RENT          = X_NEGATIVE_RENT,
   ACTUAL_INVOICED_AMOUNT = ROUND(X_ACTUAL_INVOICED_AMOUNT, l_precision),
   PERIOD_ID              = X_PERIOD_ID,
   FORECASTED_TERM_STATUS = X_FORECASTED_TERM_STATUS,
   VARIANCE_TERM_STATUS   = X_VARIANCE_TERM_STATUS,
   ACTUAL_TERM_STATUS     = X_ACTUAL_TERM_STATUS,
   FORECASTED_EXP_CODE    = X_FORECASTED_EXP_CODE,
   VARIANCE_EXP_CODE      = X_VARIANCE_EXP_CODE,
   ACTUAL_EXP_CODE        = X_ACTUAL_EXP_CODE,
   COMMENTS               = X_COMMENTS,
   ATTRIBUTE_CATEGORY     = X_ATTRIBUTE_CATEGORY,
   ATTRIBUTE1             = X_ATTRIBUTE1,
   ATTRIBUTE2             = X_ATTRIBUTE2,
   ATTRIBUTE3             = X_ATTRIBUTE3,
   ATTRIBUTE4             = X_ATTRIBUTE4,
   ATTRIBUTE5             = X_ATTRIBUTE5,
   ATTRIBUTE6             = X_ATTRIBUTE6,
   ATTRIBUTE7             = X_ATTRIBUTE7,
   ATTRIBUTE8             = X_ATTRIBUTE8,
   ATTRIBUTE9             = X_ATTRIBUTE9,
   ATTRIBUTE10            = X_ATTRIBUTE10,
   ATTRIBUTE11            = X_ATTRIBUTE11,
   ATTRIBUTE12            = X_ATTRIBUTE12,
   ATTRIBUTE13            = X_ATTRIBUTE13,
   ATTRIBUTE14            = X_ATTRIBUTE14,
   ATTRIBUTE15            = X_ATTRIBUTE15,
   LAST_UPDATE_DATE       = X_LAST_UPDATE_DATE,
   LAST_UPDATED_BY        = X_LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN      = X_LAST_UPDATE_LOGIN
 WHERE VAR_RENT_INV_ID    = X_VAR_RENT_INV_ID;


  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;


-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_RENT_INV with _ALL table
-------------------------------------------------------------------------------
procedure DELETE_ROW (
  X_VAR_RENT_INV_ID IN NUMBER
) IS
BEGIN

  PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.DELETE_ROW (+)');

  DELETE FROM PN_VAR_RENT_INV_ALL
  WHERE VAR_RENT_INV_ID = X_VAR_RENT_INV_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  PNP_DEBUG_PKG.debug ('PN_VAR_RENT_INV_PKG.DELETE_ROW (-)');


END DELETE_ROW;

END PN_VAR_RENT_INV_PKG;


/
