--------------------------------------------------------
--  DDL for Package Body PNT_PAYMENT_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_PAYMENT_SCHEDULES_PKG" AS
  -- $Header: PNTPYSCB.pls 120.3 2005/12/01 09:56:48 appldev ship $

/*============================================================================+
--  NAME         : check_payment_schedule_date
--  DESCRIPTION  : Perform checks (mentioned below) on schedule_date of a
--                 Payment Schedule record FOR a given lease:
--                 o Disallow creation of a payment schedule record IF there
--                   exists a record in pn_payment_schedules FOR the same
--                   schedule_date
--                 o Disallow creation of a "DRAFT" payment schedule record IF
--                   a future payment schedule exists in status "APPROVED"
--                 o Disallow creation of an "APPROVED" payment schedule record
--                   IF a past payment schedule exists in status "DRAFT"
--  NOTES        : Used by PNTAUPMT form (Authorize Payments)
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : x_lease_id,x_schedule_date,x_rowid,
--                          x_payment_status_lookup_code.
--                 OUT    : NONE
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  14-JUL-98  ntandon   o Created.
--  21-AUG-03  ftanudja  o Modified 'exists' logic to include day. 3089171.
--  07-NOV-03  ftanudja  o Bug #3240284 - Added 'day' constraint for csr
--                         later_notin_draft.
--  21-JUN-05  piagrawa  o Bug 4284035 - Replaced pn_payment_schedules
--                         with _ALL table.
 +============================================================================*/
PROCEDURE check_payment_schedule_date (
                       x_lease_id                      IN     NUMBER,
                       x_schedule_date                 IN     DATE,
                       x_payment_status_lookup_code    IN     VARCHAR2,
                       x_rowid                         IN     VARCHAR2
                     )
IS

   CURSOR later_notin_draft IS
      SELECT 'x'
      FROM   pn_payment_schedules_all
      WHERE  lease_id = x_lease_id
      AND    payment_status_lookup_code <> 'DRAFT'
      AND    schedule_date > x_schedule_date
      AND    to_char(schedule_date,'DD') = to_char(x_schedule_date,'DD');

   CURSOR prior_in_draft IS
      SELECT 'x'
      FROM   pn_payment_schedules_all
      WHERE  lease_id = x_lease_id
      AND    payment_status_lookup_code  = 'DRAFT'
      AND    schedule_date < x_schedule_date;

   dummy NUMBER;

BEGIN

   -----------------------------------------------------------------------------
   -- Check IF a payment schedule already exists FOR a lease on the same date
   -----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Bug Fix FOR the Bug ID#1210779.
   -- WHEN creating a new schedule payment schedule the user should not be
   -- allowed to create an additional payment schedule in the same GL period.
   -----------------------------------------------------------------------------

   BEGIN

      SELECT 1
      INTO   dummy
      FROM   DUAL
      WHERE  NOT EXISTS (SELECT 1
                         FROM   pn_payment_schedules_all
                         WHERE  lease_id = x_lease_id
                         AND    TO_CHAR(schedule_date,'YYYY-MON-DD') = TO_CHAR(x_schedule_date,'YYYY-MON-DD')
                         AND    (( x_rowid IS NULL ) or (rowid <> x_rowid))
                       );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_message.set_name ('PN', 'PN_PMT_SCHEDULE_ALREADY_EXISTS');
         app_exception.Raise_Exception;

   END;

   IF x_payment_status_lookup_code = 'DRAFT' THEN

      FOR i IN later_notin_draft
      LOOP
         fnd_message.set_name ('PN', 'PN_LATER_SCHED_DATE_NOT_DRAFT');
         app_exception.Raise_Exception;
         EXIT;
      END LOOP;

   ELSE

      FOR i IN prior_in_draft
      LOOP
         fnd_message.set_name ('PN', 'PN_PRIOR_SCHED_DATE_IN_DRAFT');
         app_exception.Raise_Exception;
         EXIT;
      END LOOP;

   END IF;

END check_payment_schedule_date;

/*============================================================================+
--  NAME         : check_payment_status
--  DESCRIPTION  : Determine IF there exists a payment_item of type 'CASH' in
--                 pn_payment_items with actual_amount = 0. IF 'YES' THEN the
--                 payment schedule cannot be APPROVED
--                 The PROCEDURE passes back the error_flag to the calling
--                 routine to decide whether to RAISE a fatal error or not.
--  NOTES        : Used by PNTAUPMT form (Authorize Payments)
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : x_payment_schedule_id,x_payment_status_lookup_code,
--                          x_error_flag.
--                 OUT    : x_error_flag
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  14-JUL-98  Neeraj Tandon  o Created
--  21-JUN-05  piagrawa       o Bug 4284035 - Replaced pn_payment_items
--                              with _ALL table.
 +===========================================================================*/
PROCEDURE check_payment_status (
                       x_payment_schedule_id           IN     NUMBER,
                       x_payment_status_lookup_code    IN     VARCHAR,
                       x_error_flag                    IN OUT NOCOPY VARCHAR2
                     ) IS

   CURSOR is_actual_amount_NULL IS
      SELECT 'x'
      FROM   pn_payment_items_all
      WHERE  payment_item_type_lookup_code = 'CASH'
      AND    payment_schedule_id = x_payment_schedule_id
      AND    NVL(actual_amount,0) = 0;

BEGIN

   RETURN;  /*-- Fixing bug 783419 by making this a do-nothing PROCEDURE --*/

   FOR i IN is_actual_amount_NULL
   LOOP
      fnd_message.set_name ('PN', 'PN_ACTUAL_ITEM_AMOUNT_IS_NULL');
      x_error_flag := 'Y';
      EXIT;
   END LOOP;

END check_payment_status;


/*=============================================================================+
--  NAME         : get_next_payment_schedule
--  DESCRIPTION  : FETCH the next 'DRAFT' payment schedule FOR a given lease to
--                 allow DEFER payment item functionality. i.e. A payment item
--                 can only be defered IF a future payment schedule exists in
--                 status 'DRAFT'.
--  NOTES        : Used by PNTAUPMT form (Authorize Payments)
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : x_lease_id,x_schedule_date,
--                          x_next_payment_schedule_id.
--                 OUT    : x_next_payment_schedule_id
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  14-JUL-98  Neeraj Tandon  o Created
--  20-aug-01  achauhan       o Added a check in the cursor to get the next
--                              available schedule for the same schedule day.
--  15-JUN-04  Kiran          o Removed the previous check. We will now get
--                                the next available schedule. bug # 3644937
--  21-JUN-05  piagrawa       o Bug 4284035 - Replaced pn_payment_schedules
--                              with _ALL table.
+============================================================================*/
PROCEDURE get_next_payment_schedule (
                       x_lease_id                      IN     NUMBER,
                       x_schedule_date                 IN     DATE,
                       x_next_payment_schedule_id      IN OUT NOCOPY NUMBER
                     ) IS

   CURSOR next_schedule IS
      SELECT payment_schedule_id
      FROM   pn_payment_schedules_all
      WHERE  lease_id = x_lease_id
      AND    schedule_date > x_schedule_date
      AND    payment_status_lookup_code = 'DRAFT'
      ORDER  BY schedule_date;

BEGIN

   FOR i IN next_schedule
   LOOP
      x_next_payment_schedule_id := i.payment_schedule_id;
      EXIT;
   END LOOP;

END get_next_payment_schedule;


/*============================================================================+
--  NAME         : mark_pmt_items_exportable
--  DESCRIPTION  : UPDATE export_to_ap_flag in pn_payment_items(CASH items only)
--                 with 'Y' WHEN a payment schedule IS authorized (APPROVED).
--                 This will simplify the logic in Export to AP form which
--                 currently navigates to every row FOR marking (updating) the
--                 payment item FOR export.
--  NOTES        : Used by PNTAUPMT form (Authorize Payments) AND the
--                 Server  table handler (insert/update)
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : x_payment_schedule_id,x_payment_status_lookup_code,
--                          x_export_flag.
--                 OUT    : NONE
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  14-JUL-98  Neeraj Tandon  o Created
--  25-MAR-99  Neeraj Tandon  o Added filter FOR 'CASH' items
--  21-JUN-05  piagrawa       o Bug 4284035 - Replaced pn_payment_items
--                              with _ALL table.
+============================================================================*/
PROCEDURE MARK_PMT_ITEMS_EXPORTABLE (
                       x_payment_status_lookup_code    IN     VARCHAR2,
                       x_payment_schedule_id           IN     NUMBER,
                       x_export_flag                   IN     VARCHAR2
                     )

IS

BEGIN

   UPDATE pn_payment_items_all
   SET    export_to_ap_flag               = x_export_flag
   WHERE  payment_schedule_id             =  x_payment_schedule_id
   AND    payment_item_type_lookup_code   =  'CASH';

   IF (SQL%NOTFOUND) THEN
      NULL;
   END IF;

END mark_pmt_items_exportable;


/*============================================================================+
--  NAME         : mark_billing_items_exportable
--  DESCRIPTION  : UPDATE export_to_ar_flag in pn_payment_items (CASH items only)
--                 with 'Y' WHEN a payment schedule IS authorized (APPROVED).
--                 This will simplify the logic in Export to AR form which currently
--                 navigates to every row for marking (updating) the payment item
--                 for export.
--  NOTES        : Used by PNTAUPMT form (Authorize Payments) AND the
--                 Server  table handler (insert/update)
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : x_payment_schedule_id,x_payment_status_lookup_code,
--                          x_export_flag.
--                 OUT    : NONE
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  14-JUL-98  Neeraj Tandon  o Created
--  25-MAR-99  Neeraj Tandon  o Added filter FOR 'CASH' items
--  21-JUN-05  piagrawa       o Bug 4284035 - Replaced pn_payment_items
--                              with _ALL table.
+=============================================================================*/
PROCEDURE MARK_BILLING_ITEMS_EXPORTABLE (
                       x_payment_status_lookup_code    IN     VARCHAR2,
                       x_payment_schedule_id           IN     NUMBER,
                       x_export_flag                   IN     VARCHAR2
                     )

IS

BEGIN

   UPDATE pn_payment_items_all
   SET    export_to_ar_flag               = x_export_flag
   WHERE  payment_schedule_id             = x_payment_schedule_id
   AND    payment_item_type_lookup_code   = 'CASH';

   IF (SQL%NOTFOUND) THEN
      NULL;
   END IF;

END mark_billing_items_exportable;

/*============================================================================+
--  NAME         : check_on_hold
--  DESCRIPTION  : Checks FOR any payment schedule On-Hold prior to the payment
--                 schedule, in question. if there is any, then the payment,
--                 schedule, in qustion, cannot be approved.
--  NOTES        : Used by PNTAUPMT form (Authorize Payments).
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : x_lease_id,x_schedule_date
--                 OUT    : NONE
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  28-DEC-00  Mrinal Misra  o Created
--  21-JUN-05  piagrawa       o Bug 4284035 - Replaced pn_payment_schedules
--                              with _ALL table.
=============================================================================*/
PROCEDURE check_on_hold (
                       x_lease_id                      IN     NUMBER,
                       x_schedule_date                 IN     DATE
                     ) IS

   l_check_cond          VARCHAR2(1) := NULL;

   CURSOR on_hold_cur IS
      SELECT 'A'
      FROM  DUAL
      WHERE EXISTS (SELECT NULL
                    FROM   pn_payment_schedules_all
                    WHERE  lease_id = x_lease_id
                    AND    schedule_date < x_schedule_date
                    AND    on_hold = 'Y');

BEGIN

   OPEN on_hold_cur;
      FETCH on_hold_cur INTO l_check_cond;
   CLOSE on_hold_cur;

   IF l_check_cond IS NOT NULL AND l_check_cond = 'A' THEN
      fnd_message.set_name ('PN', 'PN_APPR_REJ_MSG');
      app_exception.Raise_Exception;
   END IF;

END check_on_hold;


/*============================================================================+
--  NAME         : check_payment_items_acct_amt
--  DESCRIPTION  : checks to see IF any of the payment item under schedule_id
--                 has an accounted amount of NULL OR IF any of the payment item
--                 which has conversion type 'User' has a rate of NULL
--                 IF the former, THEN SET error flag to 'Y'
--                 IF the latter, THEN SET error flag to 'U'
--                 otherwise SET to 'N'.
--  NOTES        : Used by PNTAUPMT form (Authorize Payments).
--  SCOPE        : PUBLIC
--  INVOKED FROM :
--  ARGUMENTS    : IN     : l_payment_schedule_id,l_functional_currency
--                 OUT    : NOCOPY l_error_flag => look at description above
--  RETURNS      :
--  REFERENCE    :
--  HISTORY      :
--  25-APR-02  ftanudja  o Created
--  03-MAY-02  ftanudja  o check IF 'to_currency' type IS user
--                        (before it was checking 'from_currency')
--  06-MAY-02  ftanudja  o removed parameter p_def_conv_type
--  11-MAY-02  ftanudja  o cleaned up code
--  24-JUL-02  ftanudja  o added check for null conversion types
--  20-DEC-02  psidhu    o added check to set p_error_flag if conversion type is
--                         null and there exists atleast one item for schedule
--                         with currency_code <> functional currency. Added cursor
--                         chk_item_exists. Fix for bug#'s 2707128 and 2714333.
--  21-JUN-05  piagrawa  o Bug 4284035 - Replaced pn_payment_items
--                         with _ALL table.
--  01-DEC-05  pikhar    o passed org_id in pnp_util_func.check_conversion_type
=============================================================================*/

PROCEDURE check_payment_items_acct_amt (
                       p_payment_schedule_id           IN     NUMBER,
                       p_functional_currency           IN     VARCHAR2,
                       p_error_flag                       OUT NOCOPY VARCHAR2
                     )
IS
   l_dummy VARCHAR2(240);
   l_date  DATE;
   l_type  VARCHAR2(10);
   l_item_exists VARCHAR2(1):='N';

   CURSOR payment_cursor IS
      SELECT actual_amount, currency_code, rate, due_date
      FROM pn_payment_items_all
      WHERE payment_schedule_id = p_payment_schedule_id
      AND   payment_item_type_lookup_code = 'CASH';

  CURSOR chk_item_exists IS
     SELECT 'Y'
     FROM dual
     WHERE EXISTS (SELECT null
                   FROM pn_payment_items_all
                   WHERE payment_schedule_id = p_payment_schedule_id
                   AND payment_item_type_lookup_code = 'CASH'
                   AND currency_code <> p_functional_currency);

  CURSOR org_cur IS
    SELECT org_id
    FROM pn_payment_schedules_all
    WHERE payment_schedule_id = p_payment_schedule_id;

   l_org_id NUMBER;

BEGIN

   FOR rec IN org_cur LOOP
     l_org_id := rec.org_id;
   END LOOP;

   l_type := pnp_util_func.check_conversion_type(p_functional_currency,l_org_id );
   p_error_flag := 'N';

   IF l_type IS NULL THEN

      -- fix for bug# 2707128
      OPEN chk_item_exists;
      FETCH chk_item_exists into l_item_exists;
      CLOSE chk_item_exists;

      IF nvl(l_item_exists,'N') = 'Y' THEN
         p_error_flag := 'Y';
         RETURN;
      END IF;

      --
   END IF;

   FOR payment_record IN payment_cursor LOOP

      IF payment_record.due_date > SYSDATE THEN
         l_date := SYSDATE;
      ELSE
         l_date := payment_record.due_date;
      END IF;

      IF  UPPER(l_type) = 'USER' AND payment_record.rate IS NULL AND
         (payment_record.currency_code <> p_functional_currency) THEN
          p_error_flag := 'Y';
          EXIT;
      ELSIF UPPER(l_type) <> 'USER' THEN

         l_dummy := pnp_util_func.export_curr_amount(
                      currency_code        => payment_record.currency_code,
                      export_currency_code => p_functional_currency,
                      export_date          => l_date,
                      conversion_type      => l_type,
                      actual_amount        => payment_record.actual_amount,
                      p_called_from        => 'PNTAUPMT'
                           );
         IF l_dummy IS NULL THEN
            p_error_flag := 'Y';
            EXIT;
         END IF;
      END IF;
   END LOOP;

END check_payment_items_acct_amt;

-------------------------------------------------------------------------------
-- PROCEDURE    : Insert_Row
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05  piagrawa  o Bug 4284035 - Replaced pn_payment_schedules
--                        with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Insert_Row (
                       X_CONTEXT                    IN VARCHAR2,
                       X_ROWID                      IN OUT NOCOPY VARCHAR2,
                       X_PAYMENT_SCHEDULE_ID        IN OUT NOCOPY NUMBER,
                       X_SCHEDULE_DATE              IN DATE,
                       X_LEASE_CHANGE_ID            IN NUMBER,
                       X_LEASE_ID                   IN NUMBER,
                       X_APPROVED_BY_USER_ID        IN NUMBER,
                       X_TRANSFERRED_BY_USER_ID     IN NUMBER,
                       X_PAYMENT_STATUS_LOOKUP_CODE IN VARCHAR2,
                       X_APPROVAL_DATE              IN DATE,
                       X_TRANSFER_DATE              IN DATE,
                       X_PERIOD_NAME                IN VARCHAR2,
                       X_ATTRIBUTE_CATEGORY         IN VARCHAR2,
                       X_ATTRIBUTE1                 IN VARCHAR2,
                       X_ATTRIBUTE2                 IN VARCHAR2,
                       X_ATTRIBUTE3                 IN VARCHAR2,
                       X_ATTRIBUTE4                 IN VARCHAR2,
                       X_ATTRIBUTE5                 IN VARCHAR2,
                       X_ATTRIBUTE6                 IN VARCHAR2,
                       X_ATTRIBUTE7                 IN VARCHAR2,
                       X_ATTRIBUTE8                 IN VARCHAR2,
                       X_ATTRIBUTE9                 IN VARCHAR2,
                       X_ATTRIBUTE10                IN VARCHAR2,
                       X_ATTRIBUTE11                IN VARCHAR2,
                       X_ATTRIBUTE12                IN VARCHAR2,
                       X_ATTRIBUTE13                IN VARCHAR2,
                       X_ATTRIBUTE14                IN VARCHAR2,
                       X_ATTRIBUTE15                IN VARCHAR2,
                       X_CREATION_DATE              IN DATE,
                       X_CREATED_BY                 IN NUMBER,
                       X_LAST_UPDATE_DATE           IN DATE,
                       X_LAST_UPDATED_BY            IN NUMBER,
                       X_LAST_UPDATE_LOGIN          IN NUMBER,
                       x_org_id                     IN NUMBER
                     ) IS
   CURSOR c IS
      SELECT ROWID
      FROM   pn_payment_schedules_all
      WHERE  payment_schedule_id = x_payment_schedule_id;

   CURSOR org_cur IS
      SELECT org_id FROM pn_leases_all WHERE lease_id = x_lease_id;

   l_org_id NUMBER;

BEGIN

   IF x_payment_schedule_id IS NULL THEN

      SELECT pn_payment_schedules_s.NEXTVAL
      INTO   x_payment_schedule_id
      FROM   DUAL;

   END IF;

   IF x_org_id IS NULL THEN
      FOR rec IN org_cur LOOP
         l_org_id := rec.org_id;
      END LOOP;
   ELSE
      l_org_id := x_org_id;
   END IF;

   INSERT INTO pn_payment_schedules_all
   (
      PAYMENT_SCHEDULE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      SCHEDULE_DATE,
      LEASE_CHANGE_ID,
      LEASE_ID,
      APPROVED_BY_USER_ID,
      TRANSFERRED_BY_USER_ID,
      PAYMENT_STATUS_LOOKUP_CODE,
      APPROVAL_DATE,
      TRANSFER_DATE,
      PERIOD_NAME,
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
      ON_HOLD,
      org_id)
   VALUES (
      X_PAYMENT_SCHEDULE_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_SCHEDULE_DATE,
      X_LEASE_CHANGE_ID,
      X_LEASE_ID,
      X_APPROVED_BY_USER_ID,
      X_TRANSFERRED_BY_USER_ID,
      X_PAYMENT_STATUS_LOOKUP_CODE,
      X_APPROVAL_DATE,
      X_TRANSFER_DATE,
      X_PERIOD_NAME,
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
      NULL,
      l_org_id
   );

   OPEN c;
      FETCH c INTO X_ROWID;
      IF (c%notfound) THEN
         CLOSE c;
         RAISE no_data_found;
      END IF;
   CLOSE c;

   IF X_PAYMENT_STATUS_LOOKUP_CODE = 'APPROVED' THEN

      IF (X_CONTEXT = 'PAY') THEN
         mark_pmt_items_exportable ( x_payment_status_lookup_code,
                                     x_payment_schedule_id,
                                     'Y'
                                   );
      ELSE  -- REC
         mark_billing_items_exportable ( x_payment_status_lookup_code,
                                         x_payment_schedule_id,
                                         'Y'
                                      );
      END IF;

   END IF;

END Insert_Row;


-------------------------------------------------------------------------------
-- PROCEDURE    : Lock_Row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  piagrawa  o Bug 4284035 - Replaced pn_payment_schedules
--                        with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Lock_Row (
                       X_PAYMENT_SCHEDULE_ID           IN     NUMBER,
                       X_APPROVED_BY_USER_ID           IN     NUMBER,
                       X_TRANSFERRED_BY_USER_ID        IN     NUMBER,
                       X_PAYMENT_STATUS_LOOKUP_CODE    IN     VARCHAR2,
                       X_APPROVAL_DATE                 IN     DATE,
                       X_TRANSFER_DATE                 IN     DATE,
                       X_PERIOD_NAME                   IN     VARCHAR2,
                       X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
                       X_ATTRIBUTE1                    IN     VARCHAR2,
                       X_ATTRIBUTE2                    IN     VARCHAR2,
                       X_ATTRIBUTE3                    IN     VARCHAR2,
                       X_ATTRIBUTE4                    IN     VARCHAR2,
                       X_ATTRIBUTE5                    IN     VARCHAR2,
                       X_ATTRIBUTE6                    IN     VARCHAR2,
                       X_ATTRIBUTE7                    IN     VARCHAR2,
                       X_ATTRIBUTE8                    IN     VARCHAR2,
                       X_ATTRIBUTE9                    IN     VARCHAR2,
                       X_ATTRIBUTE10                   IN     VARCHAR2,
                       X_ATTRIBUTE11                   IN     VARCHAR2,
                       X_ATTRIBUTE12                   IN     VARCHAR2,
                       X_ATTRIBUTE13                   IN     VARCHAR2,
                       X_ATTRIBUTE14                   IN     VARCHAR2,
                       X_ATTRIBUTE15                   IN     VARCHAR2
                     )
IS

   CURSOR c1 IS
      SELECT *
      FROM   pn_payment_schedules_all
      WHERE  payment_schedule_id = x_payment_schedule_id
      FOR    UPDATE OF payment_schedule_id NOWAIT;

   tlinfo c1%rowtype;

BEGIN

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%notfound) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.PAYMENT_SCHEDULE_ID = X_PAYMENT_SCHEDULE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_SCHEDULE_ID',tlinfo.PAYMENT_SCHEDULE_ID);
   END IF;

   IF NOT ((tlinfo.APPROVED_BY_USER_ID = X_APPROVED_BY_USER_ID)
           OR ((tlinfo.APPROVED_BY_USER_ID IS NULL) AND (X_APPROVED_BY_USER_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('APPROVED_BY_USER_ID',tlinfo.APPROVED_BY_USER_ID);
   END IF;

   IF NOT ((tlinfo.TRANSFERRED_BY_USER_ID = X_TRANSFERRED_BY_USER_ID)
           OR ((tlinfo.TRANSFERRED_BY_USER_ID IS NULL) AND (X_TRANSFERRED_BY_USER_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TRANSFERRED_BY_USER_ID',tlinfo.TRANSFERRED_BY_USER_ID);
   END IF;

   IF NOT ((tlinfo.PAYMENT_STATUS_LOOKUP_CODE = X_PAYMENT_STATUS_LOOKUP_CODE)
           OR ((tlinfo.PAYMENT_STATUS_LOOKUP_CODE IS NULL) AND (X_PAYMENT_STATUS_LOOKUP_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_STATUS_LOOKUP_CODE',tlinfo.PAYMENT_STATUS_LOOKUP_CODE);
   END IF;

   IF NOT ((trunc(tlinfo.APPROVAL_DATE) = trunc(X_APPROVAL_DATE))
           OR ((trunc(tlinfo.APPROVAL_DATE) IS NULL) AND (trunc(X_APPROVAL_DATE) IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('APPROVAL_DATE',tlinfo.APPROVAL_DATE);
   END IF;

   IF NOT ((trunc(tlinfo.TRANSFER_DATE) = trunc(X_TRANSFER_DATE))
           OR ((tlinfo.TRANSFER_DATE IS NULL) AND (X_TRANSFER_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TRANSFER_DATE',tlinfo.TRANSFER_DATE);
   END IF;

   IF NOT ((tlinfo.PERIOD_NAME = X_PERIOD_NAME)
           OR ((tlinfo.PERIOD_NAME IS NULL) AND (X_PERIOD_NAME IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PERIOD_NAME',tlinfo.PERIOD_NAME);
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
END Lock_Row;


-------------------------------------------------------------------------------
-- PROCEDURE    : Update_Row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : Updates the row
-- HISTORY      :
-- 21-JUN-05  piagrawa  o Bug 4284035 - Replaced pn_payment_schedules
--                        with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Update_Row (
                       X_CONTEXT                       IN     VARCHAR2,
                       X_PAYMENT_SCHEDULE_ID           IN     NUMBER,
                       X_SCHEDULE_DATE                 IN     DATE,
                       X_APPROVED_BY_USER_ID           IN     NUMBER,
                       X_TRANSFERRED_BY_USER_ID        IN     NUMBER,
                       X_PAYMENT_STATUS_LOOKUP_CODE    IN     VARCHAR2,
                       X_LEASE_FUNCTIONAL_CURRENCY     IN     VARCHAR2,
                       X_APPROVAL_DATE                 IN     DATE,
                       X_TRANSFER_DATE                 IN     DATE,
                       X_PERIOD_NAME                   IN     VARCHAR2,
                       X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
                       X_ATTRIBUTE1                    IN     VARCHAR2,
                       X_ATTRIBUTE2                    IN     VARCHAR2,
                       X_ATTRIBUTE3                    IN     VARCHAR2,
                       X_ATTRIBUTE4                    IN     VARCHAR2,
                       X_ATTRIBUTE5                    IN     VARCHAR2,
                       X_ATTRIBUTE6                    IN     VARCHAR2,
                       X_ATTRIBUTE7                    IN     VARCHAR2,
                       X_ATTRIBUTE8                    IN     VARCHAR2,
                       X_ATTRIBUTE9                    IN     VARCHAR2,
                       X_ATTRIBUTE10                   IN     VARCHAR2,
                       X_ATTRIBUTE11                   IN     VARCHAR2,
                       X_ATTRIBUTE12                   IN     VARCHAR2,
                       X_ATTRIBUTE13                   IN     VARCHAR2,
                       X_ATTRIBUTE14                   IN     VARCHAR2,
                       X_ATTRIBUTE15                   IN     VARCHAR2,
                       X_LAST_UPDATE_DATE              IN     DATE,
                       X_LAST_UPDATED_BY               IN     NUMBER,
                       X_LAST_UPDATE_LOGIN             IN     NUMBER
                     )
IS

BEGIN

   update_rate(p_pnt_sched_id               => x_payment_schedule_id,
               p_payment_status_lookup_code => x_payment_status_lookup_code,
               p_lease_functional_currency  => x_lease_functional_currency,
               p_last_updated_by            => x_last_updated_by,
               p_last_update_date           => x_last_update_date,
               p_last_update_login          => x_last_update_login);

   update_accounted_amount (X_PAYMENT_SCHEDULE_ID,
                            X_PAYMENT_STATUS_LOOKUP_CODE,
                            X_LEASE_FUNCTIONAL_CURRENCY,
                            X_LAST_UPDATED_BY,
                            X_LAST_UPDATE_DATE,
                            X_LAST_UPDATE_LOGIN );

   UPDATE PN_PAYMENT_SCHEDULES_ALL
   SET    SCHEDULE_DATE              = X_SCHEDULE_DATE,
          APPROVED_BY_USER_ID        = X_APPROVED_BY_USER_ID,
          TRANSFERRED_BY_USER_ID     = X_TRANSFERRED_BY_USER_ID,
          PAYMENT_STATUS_LOOKUP_CODE = X_PAYMENT_STATUS_LOOKUP_CODE,
          APPROVAL_DATE              = X_APPROVAL_DATE,
          TRANSFER_DATE              = X_TRANSFER_DATE,
          PERIOD_NAME                = X_PERIOD_NAME,
          ATTRIBUTE_CATEGORY         = X_ATTRIBUTE_CATEGORY,
          ATTRIBUTE1                 = X_ATTRIBUTE1,
          ATTRIBUTE2                 = X_ATTRIBUTE2,
          ATTRIBUTE3                 = X_ATTRIBUTE3,
          ATTRIBUTE4                 = X_ATTRIBUTE4,
          ATTRIBUTE5                 = X_ATTRIBUTE5,
          ATTRIBUTE6                 = X_ATTRIBUTE6,
          ATTRIBUTE7                 = X_ATTRIBUTE7,
          ATTRIBUTE8                 = X_ATTRIBUTE8,
          ATTRIBUTE9                 = X_ATTRIBUTE9,
          ATTRIBUTE10                = X_ATTRIBUTE10,
          ATTRIBUTE11                = X_ATTRIBUTE11,
          ATTRIBUTE12                = X_ATTRIBUTE12,
          ATTRIBUTE13                = X_ATTRIBUTE13,
          ATTRIBUTE14                = X_ATTRIBUTE14,
          ATTRIBUTE15                = X_ATTRIBUTE15,
          ON_HOLD                    = NULL,
          LAST_UPDATE_DATE           = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY            = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN          = X_LAST_UPDATE_LOGIN
   WHERE  PAYMENT_SCHEDULE_ID        = X_PAYMENT_SCHEDULE_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   IF X_PAYMENT_STATUS_LOOKUP_CODE = 'APPROVED' THEN

      IF (X_CONTEXT = 'PAY') THEN
         mark_pmt_items_exportable ( x_payment_status_lookup_code,
                                     x_payment_schedule_id,
                                     'Y'
                                   );
      ELSE  -- REC
         mark_billing_items_exportable ( x_payment_status_lookup_code,
                                         x_payment_schedule_id,
                                         'Y'
                                       );
      END IF;

   ELSIF X_PAYMENT_STATUS_LOOKUP_CODE = 'DRAFT' THEN

      IF (X_CONTEXT = 'PAY') THEN
         mark_pmt_items_exportable ( x_payment_status_lookup_code,
                                     x_payment_schedule_id,
                                     NULL
                                   );
      ELSE  -- REC
           mark_billing_items_exportable ( x_payment_status_lookup_code,
                                           x_payment_schedule_id,
                                           NULL
                                         );
      END IF;

   END IF;

END Update_Row;


-------------------------------------------------------------------------------
-- PROCEDURE    : Delete_Row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : Deletes the row for a schedule id
-- HISTORY      :
-- 21-JUN-05  piagrawa  o Bug 4284035 - Replaced pn_payment_schedules
--                        with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Delete_Row ( X_PAYMENT_SCHEDULE_ID           IN     NUMBER) IS
BEGIN

   DELETE FROM pn_payment_schedules_all
   WHERE  payment_schedule_id = x_payment_schedule_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_Row;


-------------------------------------------------------------------------------
-- PROCEDURE    : update_accounted_amount
-- INVOKED FROM : update_row procedure
-- PURPOSE      : UPDATE the accounted amount field
-- REFERENCE    : BUG ID 2137179
-- HISTORY      :
-- 11-MAR-02  ftanudja   o Created
-- 25-APR-02  ftanudja   o taken into account acct date.
-- 03-MAY-02  ftanudja   o FOR conv. type 'User', use 'rate'
-- 11-MAY-02  ftanudja   o cleaned up code
-- 07-OCT-02  Ashish     o BUG#2590872 update the normalized items
--                         along with the cash items.
-- 21-JUN-05  piagrawa   o Bug 4284035 - Replaced pn_payment_items
--                         with _ALL table.
-- 01-DEC-05  pikhar     o passed org_id in pnp_util_func.check_conversion_type
-------------------------------------------------------------------------------

PROCEDURE update_accounted_amount (
                       p_pnt_sched_id                  IN     NUMBER,
                       p_payment_status_lookup_code    IN     VARCHAR2,
                       p_lease_functional_currency     IN     VARCHAR2,
                       p_last_updated_by               IN     NUMBER,
                       p_last_update_date              IN     DATE,
                       p_last_update_login             IN     NUMBER
                     )
IS
   l_temp NUMBER;
   l_date DATE;
   l_type VARCHAR2(10);
   l_temp1 NUMBER;      --BUG#2590872

    V_PAYMENT_ITEM_ID    NUMBER ;
    V_ACCOUNTED_AMOUNT   NUMBER ;
    V_ACTUAL_AMOUNT    NUMBER   ;

   CURSOR payment_cursor IS
      SELECT  payment_item_id
            , accounted_amount
            , actual_amount
            , currency_code
            , due_date
            , rate
            , payment_term_id
      FROM   pn_payment_items_all
      WHERE  payment_schedule_id = p_pnt_sched_id
      AND    payment_item_type_lookup_code = 'CASH';

   --Added for BUG#2590872
   CURSOR norm_cursor(l_term_id NUMBER, l_item_id number) IS
      SELECT pi.payment_item_id
           , pi.accounted_amount
           , pi.actual_amount
      FROM   pn_payment_items_all pi,
             pn_payment_items_all pi1
      WHERE  pi.payment_schedule_id            = p_pnt_sched_id
      AND    pi.payment_TERM_id                = l_term_id
      AND    pi.payment_item_type_lookup_code  = 'NORMALIZED'
      AND    pi1.payment_schedule_id           = pi.payment_schedule_id
      AND    pi1.payment_term_id               = pi.payment_term_id
      AND    pi1.payment_item_type_lookup_code = 'CASH'
      AND    pi1.payment_item_id               = l_item_id ;

   CURSOR org_cur IS
    SELECT org_id
    FROM pn_payment_schedules_all
    WHERE payment_schedule_id = p_pnt_sched_id;

   l_org_id NUMBER;


BEGIN

   FOR rec IN org_cur LOOP
     l_org_id := rec.org_id;
   END LOOP;

   l_type := pnp_util_func.check_conversion_type(p_lease_functional_currency,l_org_id);

   FOR payment_item_rec IN payment_cursor LOOP

       /*---------ADDED FOR BUG#2590872---------*/
       OPEN NORM_cursor(payment_item_rec.payment_term_id,payment_item_rec.payment_item_id );
       FETCH NORM_CURSOR INTO  V_PAYMENT_ITEM_ID,V_ACCOUNTED_AMOUNT,V_ACTUAL_AMOUNT;
       IF NORM_CURSOR%NOTFOUND THEN
             NULL;
       END IF;
       CLOSE NORM_CURSOR;


      IF payment_item_rec.due_date > SYSDATE THEN
         l_date := SYSDATE;
      ELSE
         l_date := payment_item_rec.due_date;
      END IF;
      IF p_payment_status_lookup_code = 'APPROVED' THEN

         IF UPPER(l_type) = 'USER' THEN

            l_temp := NVL(payment_item_rec.actual_amount,0) * NVL(payment_item_rec.rate,0);
            l_temp1 := NVL(V_actual_amount,0) * NVL(PAYMENT_item_rec.rate,0);     --ADDED FOR BUG#2590872

         ELSE
            l_temp := pnp_util_func.export_curr_amount(
                          currency_code        => payment_item_rec.currency_code,
                          export_currency_code => p_lease_functional_currency,
                          export_date          => l_date,
                          conversion_type      => l_type,
                          actual_amount        => NVL(payment_item_rec.actual_amount,0),
                          p_called_from        => 'NOTPNTAUPMT'
                       );
            --ADDED FOR BUG#2590872
            l_temp1 := pnp_util_func.export_curr_amount(
                          currency_code        => payment_item_rec.currency_code,
                          export_currency_code => p_lease_functional_currency,
                          export_date          => l_date,
                          conversion_type      => l_type,
                          actual_amount        => NVL(V_actual_amount,0),
                          p_called_from        => 'NOTPNTAUPMT'
                       );

         END IF;

      ELSIF p_payment_status_lookup_code = 'DRAFT' THEN
         l_temp := NULL;
         l_temp1 := null;        --ADDED FOR BUG#2590872
         l_date := NULL;
      END IF;

     --ADDED FOR BUG#2590872
      IF (NVL(v_accounted_amount,0) <> NVL(l_temp1,0)) THEN
         UPDATE pn_payment_items_all
         SET    accounted_amount                = l_temp1,
                accounted_date                  = l_date,
                RATE                            = payment_item_rec.RATE,
                CURRENCY_CODE                   = payment_item_rec.currency_code,
                last_updated_by                 = p_last_updated_by,
                last_update_date                = p_last_update_date,
                last_update_login               = p_last_update_login
         WHERE  payment_item_id                 = v_PAYMENT_item_id;

            IF SQL%NOTFOUND THEN
                NULL;
            END IF;
      END IF;
      IF (NVL(payment_item_rec.accounted_amount,0) <> NVL(l_temp,0)) THEN
         UPDATE pn_payment_items_all
         SET    accounted_amount                = l_temp,
                accounted_date                  = l_date,
                last_updated_by                 = p_last_updated_by,
                last_update_date                = p_last_update_date,
                last_update_login               = p_last_update_login
         WHERE  payment_item_id                 = payment_item_rec.payment_item_id;
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END update_accounted_amount;


-------------------------------------------------------------------------------
-- PROCEDURE    : update_rate
-- INVOKED FROM : update_row procedure
-- PURPOSE      : UPDATE the rate field
-- REFERENCE    : BUG ID 2730034
-- HISTORY      :
-- 07-JAN-03  psidhu    o Created
-- 21-JUN-05  piagrawa  o Bug 4284035 - Replaced pn_payment_items
--                         with _ALL table.
-- 01-DEC-05  pikhar    o passed org_id in pnp_util_func.check_conversion_type
-------------------------------------------------------------------------------
PROCEDURE update_rate (
                       p_pnt_sched_id                  IN     NUMBER,
                       p_payment_status_lookup_code    IN     VARCHAR2,
                       p_lease_functional_currency     IN     VARCHAR2,
                       p_last_updated_by               IN     NUMBER,
                       p_last_update_date              IN     DATE,
                       p_last_update_login             IN     NUMBER
                     )
IS
l_rate NUMBER;
l_date DATE;
l_type VARCHAR2(30);

CURSOR payment_cursor IS
SELECT payment_item_id, currency_code, due_date, rate
FROM   pn_payment_items_all
WHERE  payment_schedule_id = p_pnt_sched_id
AND    payment_item_type_lookup_code = 'CASH';

CURSOR org_cur IS
  SELECT org_id
  FROM pn_payment_schedules_all
  WHERE payment_schedule_id = p_pnt_sched_id;

l_org_id NUMBER;

BEGIN

   FOR rec IN org_cur LOOP
     l_org_id := rec.org_id;
   END LOOP;

   l_type := pnp_util_func.check_conversion_type(p_lease_functional_currency,l_org_id);

   FOR payment_item_rec IN payment_cursor LOOP

      IF payment_item_rec.due_date > SYSDATE THEN
         l_date := SYSDATE;
      ELSE
         l_date := payment_item_rec.due_date;
      END IF;

      IF UPPER(l_type) = 'USER' AND
         payment_item_rec.currency_code <> p_lease_functional_currency  THEN

         l_rate := payment_item_rec.rate;

      ELSIF p_payment_status_lookup_code = 'APPROVED' THEN
         l_rate := gl_currency_api.get_rate_sql(
                        x_from_currency    =>  payment_item_rec.currency_code,
                        x_to_currency      =>  p_lease_functional_currency,
                        x_conversion_date  =>  l_date,
                        x_conversion_type  =>  l_type);

         /* gl_currency_api.get_rate_sql returns a -1 is no rate is found
            or -2 if the currency is invalid.*/
          if l_rate in (-1,-2) then
             l_rate := null;
          end if;
      ELSIF p_payment_status_lookup_code = 'DRAFT' THEN
         l_rate := NULL;
      END IF;

      IF (NVL(payment_item_rec.rate,0) <> NVL(l_rate,0)) THEN
         UPDATE pn_payment_items_all
         SET    rate                            = l_rate,
                last_updated_by                 = p_last_updated_by,
                last_update_date                = p_last_update_date,
                last_update_login               = p_last_update_login
         WHERE  payment_item_id                 = payment_item_rec.payment_item_id;
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END update_rate;


END pnt_payment_schedules_pkg;

/
