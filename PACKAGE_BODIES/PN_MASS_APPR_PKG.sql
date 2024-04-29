--------------------------------------------------------
--  DDL for Package Body PN_MASS_APPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_MASS_APPR_PKG" AS
-- $Header: PNMASAPB.pls 120.3 2006/12/08 07:08:50 acprakas ship $

/* ========================== NOTE TO PROGRAMMER ==========================
   1. Use the functions in pnp_debug_pkg for logging as follows:
        debug       - Display text message if in debug mode
        log         - To put in debug messages in the log file
        put_log_msg - To put in messages in both the out and the log file

   2. Retcode values
        0 - success
        1 - warning
        2 - error
   ========================== NOTE TO PROGRAMMER ========================== */

/* exceptions global to this package alone */
RATE_NOT_DEFINED   EXCEPTION;
CURR_CONV_FAILED   EXCEPTION;
INPUT_DATE_MISSING EXCEPTION;

--------------------------------------------------------------------------------
--  NAME         : update_accounted_amount
--  DESCRIPTION  : Updates the items in a schedule with the accounted amount.
--                 Called before APPROVing schedules.
--                 Rules followed for getting the accounted amount are:
--                   if the conversion type in the item is USER then
--                     accounted amount = actual amount * rate
--                    (all amount values gotten from/for the item)
--                   else
--                     accounted amount is gotten by call to
--                     pnp_util_func.export_curr_amount which in turn calls
--                     gl_currency_api.convert_amount catching exceptions
--                     gl_currency_api.no_rate, gl_currency_api.invalid_currency
--
--                 Note that this procedure is similar to
--                 PNT_PAYMENT_SCHEDULES_PKG.update_accounted_amount - but does
--                 not have as many validations. Exception handling is done
--                 differently too
--
--  PURPOSE      : To update the accounted amount in the items in a schedule.
--  INVOKED FROM : pn_mass_appr_pkg.update_accounted_amount
--  ARGUMENTS    :
--  p_schedule_id     - IN  - schedule ID the items in which need update
--  p_functional_curr - IN  - functional curreny
--  p_conversion_type - IN  - currency conversion type
--  p_item_currency   - OUT - returns the currency of the item in case of error
--  REFERENCE    : PN_COMMON.debug()
--                 PNP_UTIL_FUNC.export_curr_amount
--  HISTORY      :
--
--  30-SEP-04  kkhegde  o Created
--  11-OCT-05  pikhar   o ensure l_accounted_date does not have a timestamp.
--  28-NOV-05  pikhar   o replaced pn_payment_items with _all table
--  08-DEC-06  acprakas o Bug5389144. Added code to modify Record History columns of pn_payment_items
--                        and pn_payment_schedules with correct values.
--------------------------------------------------------------------------------
PROCEDURE update_accounted_amount (p_schedule_id     IN NUMBER,
                                   p_functional_curr IN VARCHAR2,
                                   p_conversion_type IN VARCHAR2,
                                   p_item_currency   OUT NOCOPY VARCHAR2)
IS

l_accounted_date        DATE;
l_accounted_amt         NUMBER;
l_accounted_amt_norm    NUMBER;

l_norm_payment_item_id  NUMBER;
l_norm_accounted_amount NUMBER;
l_norm_actual_amount    NUMBER;
l_norm_curr_code        VARCHAR2(15);

l_exists_norm           BOOLEAN;

/* cursors */
CURSOR payment_cursor IS
  SELECT payment_item_id
        ,payment_term_id
        ,accounted_amount
        ,actual_amount
        ,currency_code
        ,due_date
        ,rate
  FROM   pn_payment_items_all
  WHERE  payment_schedule_id = p_schedule_id
  AND    payment_item_type_lookup_code = 'CASH';

CURSOR norm_cursor( p_term_id IN NUMBER
                   ,p_item_id IN NUMBER) IS
  SELECT pi.payment_item_id
        ,pi.accounted_amount
        ,pi.actual_amount
        ,pi.currency_code
  FROM   pn_payment_items_all pi
        ,pn_payment_items_all pi1
  WHERE pi.payment_schedule_id = p_schedule_id
  AND   pi.payment_term_id = p_term_id
  AND   pi.payment_item_type_lookup_code = 'NORMALIZED'
  AND   pi1.payment_schedule_id = pi.payment_schedule_id
  AND   pi1.payment_term_id = pi.payment_term_id
  AND   pi1.payment_item_type_lookup_code = 'CASH'
  AND   pi1.payment_item_id = p_item_id ;

BEGIN

PNP_DEBUG_PKG.debug('pn_mass_appr_pkg.update_accounted_amount (+)');

FOR payment_item_rec IN payment_cursor LOOP

  /* initialize */
  l_norm_payment_item_id  := NULL;
  l_norm_accounted_amount := NULL;
  l_norm_actual_amount    := NULL;
  l_norm_curr_code        := NULL;

  p_item_currency := payment_item_rec.currency_code;

  /* get data for normalized item corresponding to the cash item */
  FOR norm_item_rec IN norm_cursor( payment_item_rec.payment_term_id
                                   ,payment_item_rec.payment_item_id ) LOOP

    l_norm_payment_item_id  := norm_item_rec.payment_item_id;
    l_norm_accounted_amount := norm_item_rec.accounted_amount;
    l_norm_actual_amount    := norm_item_rec.actual_amount;
    l_norm_curr_code        := norm_item_rec.currency_code;

    l_exists_norm := TRUE;

  END LOOP;

  IF payment_item_rec.due_date > SYSDATE THEN
     l_accounted_date := TRUNC(SYSDATE);
  ELSE
     l_accounted_date := TRUNC(payment_item_rec.due_date);
  END IF;

  IF UPPER(p_conversion_type) = 'USER' THEN

    IF payment_item_rec.rate IS NULL THEN

      /* if conversion type is USER and rate NULL then
         raise RATE_NOT_DEFINED */
      RAISE RATE_NOT_DEFINED;

    ELSE

      l_accounted_amt
        := NVL(payment_item_rec.actual_amount,0) * NVL(payment_item_rec.rate,0);

      IF l_exists_norm THEN
        l_accounted_amt_norm
          := NVL(l_norm_actual_amount,0) * NVL(PAYMENT_item_rec.rate,0);
      END IF;

    END IF;

  ELSE

    BEGIN

      l_accounted_amt := pnp_util_func.export_curr_amount(
                    currency_code        => payment_item_rec.currency_code,
                    export_currency_code => p_functional_curr,
                    export_date          => l_accounted_date,
                    conversion_type      => p_conversion_type,
                    actual_amount        => NVL(payment_item_rec.actual_amount,0),
                    p_called_from        => 'NOTPNTAUPMT'
                 );

      IF l_exists_norm THEN
        l_accounted_amt_norm := pnp_util_func.export_curr_amount(
                      currency_code        => payment_item_rec.currency_code,
                      export_currency_code => p_functional_curr,
                      export_date          => l_accounted_date,
                      conversion_type      => p_conversion_type,
                      actual_amount        => NVL(l_norm_actual_amount,0),
                      p_called_from        => 'NOTPNTAUPMT'
                   );
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        /* if call to export_curr_amount raised exception then
           tell the user that the conversion failed */
        RAISE CURR_CONV_FAILED;

    END;

  END IF;

  IF (NVL(payment_item_rec.accounted_amount,0) <> NVL(l_accounted_amt,0)) THEN

    UPDATE pn_payment_items
    SET    accounted_amount = l_accounted_amt,
           accounted_date   = l_accounted_date,
           last_update_date = SYSDATE, --Bug#5389144
           last_updated_by  = NVL(fnd_profile.value('USER_ID'),0), --Bug#5389144
           last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0) --Bug#5389144
    WHERE  payment_item_id  = payment_item_rec.payment_item_id;

  END IF;

  IF l_exists_norm THEN

    IF (NVL(l_norm_accounted_amount,0) <> NVL(l_accounted_amt_norm,0)) THEN

      UPDATE pn_payment_items
      SET    accounted_amount = l_accounted_amt_norm,
             accounted_date   = l_accounted_date,
             RATE             = payment_item_rec.RATE,
             CURRENCY_CODE    = payment_item_rec.currency_code,
             last_update_date = SYSDATE, --Bug#5389144
             last_updated_by  = NVL(fnd_profile.value('USER_ID'),0), --Bug#5389144
             last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0) --Bug#5389144
      WHERE  payment_item_id  = l_norm_payment_item_id;

    END IF;

  END IF;

END LOOP;

PNP_DEBUG_PKG.debug('pn_mass_appr_pkg.update_accounted_amount (-)');

EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END update_accounted_amount;

--------------------------------------------------------------------------------
--  NAME         : approve
--  DESCRIPTION  : Approves the DRAFT schedules that meet the give filter
--                 criteria.
--  PURPOSE      : Approves the draft schedules
--  INVOKED FROM : pn_mass_appr_pkg.pn_mass_app
--  ARGUMENTS    : Same as that of appr_pkg.pn_mass_app() sans the dummy params
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  27-SEP-04  Kiran    o Created
--  11-JAN-05  Anand    o Removed on_hold = 'Y' condition in the cursors.
--                        Bug # 4109792
--  28-Nov-05  pikhar   o Passed org_id in pn_mo_chace_utils.get_profile_value
--  28-Nov-05  pikhar   o replaced tables with _ALL tables
--  01-DEC-05  pikhar   o passed org_id in pnp_util_func.get_default_gl_period
--                        and pnp_util_func.check_conversion_type
--  08-DEC-06  acprakas o Bug5389144. Added code to modify Record History columns of pn_payment_items
--                        and pn_payment_schedules with correct values.
--------------------------------------------------------------------------------
PROCEDURE approve( errbuf                 OUT NOCOPY  VARCHAR2
                  ,retcode                OUT NOCOPY  VARCHAR2
                  ,p_schedule_from_date   IN  DATE
                  ,p_schedule_to_date     IN  DATE
                  ,p_trx_from_date        IN  DATE
                  ,p_trx_to_date          IN  DATE
                  ,p_lease_class_code     IN  VARCHAR2
                  ,p_set_of_books         IN  VARCHAR2
                  ,p_payment_period       IN  VARCHAR2
                  ,p_billing_period       IN  VARCHAR2
                  ,p_lease_from_number    IN  VARCHAR2
                  ,p_lease_to_number      IN  VARCHAR2
                  ,p_location_from_code   IN  VARCHAR2
                  ,p_location_to_code     IN  VARCHAR2
                  ,p_responsible_user     IN  NUMBER) IS

/* main cursors */
-------------------------------------------------------------------------------
-- Cursor used when Location Code To, Location Code From are passed.
-------------------------------------------------------------------------------
CURSOR mass_appr_loc_cur IS
  SELECT DISTINCT
         pps.payment_schedule_id s_payment_schedule_id,
         pps.schedule_date       s_schedule_date,
         pps.period_name         s_period_name,
         pl.lease_class_code     s_lease_class_code,
         pl.lease_id             s_lease_id,
         pl.lease_num            s_lease_number,
         pl.name                 s_lease_name
  FROM   pn_payment_schedules_all pps,
         pn_leases                pl,
         pn_lease_details_all     pld,
         pn_tenancies_all         pt,
         pn_locations_all         ploc
  WHERE  pps.schedule_date BETWEEN NVL(p_schedule_from_date, pps.schedule_date)
                               AND NVL(p_schedule_to_date, pps.schedule_date)
  AND    pps.payment_status_lookup_code = 'DRAFT'
  AND    pl.lease_id = pps.lease_id
  AND    pl.lease_class_code = NVL(p_lease_class_code,pl.lease_class_code)
  AND    pl.lease_num >= NVL(p_lease_from_number, pl.lease_num)
  AND    pl.lease_num <= NVL(p_lease_to_number, pl.lease_num)
  AND    pld.lease_id = pps.lease_id
  AND    pld.responsible_user = NVL(p_responsible_user, pld.responsible_user)
  AND    pt.lease_id = pps.lease_id
  AND    ploc.location_id = pt.location_id
  AND    ploc.location_code >= NVL(p_location_from_code, ploc.location_code)
  AND    ploc.location_code <= NVL(p_location_to_code, ploc.location_code)
  AND    EXISTS
         (SELECT NULL
          FROM   pn_payment_items_all item
          WHERE  item.payment_schedule_id = pps.payment_schedule_id
          AND    item.due_date BETWEEN NVL(p_trx_from_date, item.due_date)
                                   AND NVL(p_trx_to_date, item.due_date)
         )
  ORDER BY pl.lease_id, pps.schedule_date;

-------------------------------------------------------------------------------
-- Cursor used when Location Code To, Location Code From are NOT passed.
-------------------------------------------------------------------------------
CURSOR mass_appr_cur IS
  SELECT DISTINCT
         pps.payment_schedule_id s_payment_schedule_id,
         pps.schedule_date       s_schedule_date,
         pps.period_name         s_period_name,
         pl.lease_class_code     s_lease_class_code,
         pl.lease_id             s_lease_id,
         pl.lease_num            s_lease_number,
         pl.name                 s_lease_name
  FROM   pn_payment_schedules_all pps,
         pn_leases                pl,
         pn_lease_details_all     pld
  WHERE  pps.schedule_date BETWEEN NVL(p_schedule_from_date, pps.schedule_date)
                               AND NVL(p_schedule_to_date, pps.schedule_date)
  AND    pps.payment_status_lookup_code = 'DRAFT'
  AND    pl.lease_id = pps.lease_id
  AND    pl.lease_class_code = NVL(p_lease_class_code,pl.lease_class_code)
  AND    pl.lease_num >= NVL(p_lease_from_number, pl.lease_num)
  AND    pl.lease_num <= NVL(p_lease_to_number, pl.lease_num)
  AND    pld.lease_id = pps.lease_id
  AND    pld.responsible_user = NVL(p_responsible_user, pld.responsible_user)
  AND    EXISTS
         (SELECT NULL
          FROM   pn_payment_items_all item
          WHERE  item.payment_schedule_id = pps.payment_schedule_id
          AND    item.due_date BETWEEN NVL(p_trx_from_date, item.due_date)
                                   AND NVL(p_trx_to_date, item.due_date)
         )
  ORDER BY pl.lease_id, pps.schedule_date;

/* validation cursors */

-------------------------------------------------------------------------------
-- validate that the billing term has all the required info
-- Business Rules:
-- In a Billing Term
--   - customer and bill to site must be defined
--   - ship to site must be defined or shipping address rule must be defined
--   - Term Type must be defined
--   - Customer Transaction type must be defined
-------------------------------------------------------------------------------
CURSOR check_bill_term ( p_schedule_id       IN NUMBER
                        ,p_ship_address_rule IN VARCHAR) IS
  SELECT 'Y'
  FROM   DUAL
  WHERE  EXISTS (SELECT NULL
                 FROM   pn_payment_terms_all ppt,
                        pn_payment_items_all ppi
                 WHERE  ppi.payment_term_id = ppt.payment_term_id
                 AND    ppi.payment_schedule_id = p_schedule_id
                 AND    (ppt.customer_id IS NULL
                         OR ppt.customer_site_use_id IS NULL
                         OR (ppt.cust_ship_site_id IS NULL AND
                             p_ship_address_rule <> 'None'
                            )
                         OR ppt.ap_ar_term_id IS NULL
                         OR ppt.cust_trx_type_id IS NULL
                        )
                );

-------------------------------------------------------------------------------
-- validate that the payment term has all the required info
-- Business Rules:
-- In a Payment Term vendor and vendor site must be defined
-------------------------------------------------------------------------------
CURSOR check_pay_term (p_schedule_id IN NUMBER) IS
  SELECT 'Y'
  FROM   dual
  WHERE  EXISTS (SELECT NULL
                 FROM   pn_payment_terms_all ppt,
                        pn_payment_items_all ppi
                 WHERE  ppi.payment_term_id = ppt.payment_term_id
                 AND    ppi.payment_schedule_id = p_schedule_id
                 AND    (ppt.vendor_id IS NULL OR
                         ppt.vendor_site_id Is NULL
                        )
                );

-------------------------------------------------------------------------------
-- validate that the actual amount in the items is not null
-- Business Rules:
-- When a schedule is to be approved, all the items belonging to the schedule
-- should have a not null actual amount.
-------------------------------------------------------------------------------
CURSOR check_act_amt (p_schedule_id IN NUMBER) IS
  SELECT 'Y'
  FROM   dual
  WHERE EXISTS(SELECT NULL
               FROM   pn_payment_items_all ppi
               WHERE  ppi.payment_schedule_id = p_schedule_id
               AND    ppi.actual_amount IS NULL);

-------------------------------------------------------------------------------
-- get the functional currency
-------------------------------------------------------------------------------
CURSOR get_functional_currency IS
  SELECT currency_code
  FROM   gl_sets_of_books
  WHERE  set_of_books_id
         = TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID'
                                                          ,pn_mo_cache_utils.get_current_org_id));

-------------------------------------------------------------------------------
-- get the shipping address rule
-- this will be used in check_bill_term
-------------------------------------------------------------------------------
CURSOR csr_ship_address_rule IS
  SELECT NVL(ship_address_rule,'None') AS ship_address_rule
  FROM   RA_BATCH_SOURCES
  WHERE  batch_source_id = 24;

/* --- VARIABLES --- */
TYPE currency_tbl_type
IS TABLE OF PN_CURRENCIES.currency_code%TYPE
INDEX BY BINARY_INTEGER;

bad_currency_table currency_tbl_type;

/* counters */
l_sch_app NUMBER;
l_sch_rej NUMBER;
l_sch_tot NUMBER;

/* variables to hold validation values */
l_ship_cust_rule      RA_BATCH_SOURCES.ship_address_rule%TYPE;
l_func_curr           PN_CURRENCIES.currency_code%TYPE;
l_item_curr           PN_CURRENCIES.currency_code%TYPE;
l_curr_conv_type      PN_CURRENCIES.conversion_type%TYPE;

/* flags */
l_exist_item_null_amt BOOLEAN;
l_exist_bad_bill_term BOOLEAN;
l_exist_bad_pay_term  BOOLEAN;
l_rate_err            BOOLEAN;
l_curr_exists         BOOLEAN;
l_sched_failed        BOOLEAN;

/* variables to store the values selected in the main cursor */
l_payment_item_id       PN_PAYMENT_ITEMS_ALL.payment_item_id%TYPE;
l_payment_schedule_id   PN_PAYMENT_SCHEDULES_ALL.payment_schedule_id%TYPE;
l_payment_schedule_date PN_PAYMENT_SCHEDULES_ALL.schedule_date%TYPE;
l_lease_class_code      PN_LEASES_ALL.lease_class_code%TYPE;
l_period_name           GL_PERIOD_STATUSES.period_name%TYPE;
l_lease_id              PN_LEASES_ALL.lease_id%TYPE;
l_lease_number          PN_LEASES_ALL.lease_num%TYPE;
l_lease_name            PN_LEASES_ALL.name%TYPE;

/* variables to handle updation and related processes */
l_application_id    NUMBER;
l_applicable_period GL_PERIOD_STATUSES.period_name%TYPE;

BEGIN

PNP_DEBUG_PKG.debug ('PN_MASS_APPR_PKG.approve  (+)');

/* init the counters */
l_sch_app := 0;
l_sch_rej := 0;
l_sch_tot := 0;

/* Get the Ship address rule from ra_batch_sources */
FOR rec IN csr_ship_address_rule LOOP
  l_ship_cust_rule := rec.ship_address_rule;
END LOOP;

/* Get functional currency and its converstion type */
FOR curr_code_rec IN get_functional_currency LOOP
  l_func_curr := curr_code_rec.currency_code;
END LOOP;

IF l_func_curr IS NULL THEN
  /* need to tell the user functional currency is not defined */
  fnd_message.set_name('PN', 'PN_FUNC_CURR_NOT_FOUND');
  pnp_debug_pkg.put_log_msg
  ('+------------------------------------------------------------------------------+');
  pnp_debug_pkg.put_log_msg(fnd_message.get);
  pnp_debug_pkg.put_log_msg
  ('+------------------------------------------------------------------------------+');

  RAISE NO_DATA_FOUND;
END IF;

l_curr_conv_type
  := pnp_util_func.check_conversion_type(l_func_curr,pn_mo_cache_utils.get_current_org_id);

/* Initialize pl/sql problem currency table */
bad_currency_table.DELETE;

/* open the appropriate cursor based on whether
   location code has been passed as a parameter or not
*/
IF p_location_from_code IS NOT NULL OR
   p_location_to_code IS NOT NULL THEN

  OPEN mass_appr_loc_cur;

ELSE

  OPEN mass_appr_cur;

END IF;

/* loop through the appropriate cursor
   approve the schedules
*/
LOOP

  /* fetch from the appropriate cursor */
  IF mass_appr_loc_cur%ISOPEN THEN

    FETCH mass_appr_loc_cur
     INTO l_payment_schedule_id
         ,l_payment_schedule_date
         ,l_period_name
         ,l_lease_class_code
         ,l_lease_id
         ,l_lease_number
         ,l_lease_name;

    EXIT WHEN mass_appr_loc_cur%NOTFOUND;

  ELSIF mass_appr_cur%ISOPEN then

    FETCH mass_appr_cur
     INTO l_payment_schedule_id
         ,l_payment_schedule_date
         ,l_period_name
         ,l_lease_class_code
         ,l_lease_id
         ,l_lease_number
         ,l_lease_name;

    EXIT WHEN mass_appr_cur%NOTFOUND;

  END IF;

  /* if we are here, we have a schedule with us to process */

  /* Increment the schedules total */
  l_sch_tot := l_sch_tot + 1;

  /* init validation result holders/flags */
  l_exist_item_null_amt := FALSE;
  l_exist_bad_bill_term := FALSE;
  l_exist_bad_pay_term  := FALSE;
  l_sched_failed        := FALSE;

  /* verify that all the items in this schedule have an actual amount */
  FOR rec IN check_act_amt(l_payment_schedule_id) LOOP
    l_exist_item_null_amt := TRUE;
  END LOOP;

  IF l_exist_item_null_amt THEN

    fnd_message.set_name('PN','PN_SCHED_REJECT_MSG');
    fnd_message.set_token('L_LEASE_NUMBER',l_lease_number);
    fnd_message.set_token('L_LEASE_NAME',l_lease_name);

    pnp_debug_pkg.put_log_msg
    ('+------------------------------------------------------------------------------+');
    pnp_debug_pkg.put_log_msg(fnd_message.get);
    pnp_debug_pkg.put_log_msg
    ('+------------------------------------------------------------------------------+');

    l_sched_failed := TRUE;

  ELSE

    /* verify if there exists a bad term that
       is contributing to this schedule
    */
    IF l_lease_class_code IN ('THIRD_PARTY','SUB_LEASE') THEN

      /* set the value of application ID, applicable period
         - we will use this later to get period name */
      l_application_id := 222;
      l_applicable_period := p_billing_period;

      /* check if we have a bad term */
      FOR rec IN check_bill_term(l_payment_schedule_id,l_ship_cust_rule) LOOP
        l_exist_bad_bill_term := TRUE;
      END LOOP;

    ELSIF l_lease_class_code = 'DIRECT' THEN

      /* set the value of application ID, applicable period
         - we will use this later to get period name */
      l_application_id := 200;
      l_applicable_period := p_payment_period;

      /* check if we have a bad term */
      FOR rec IN check_pay_term(l_payment_schedule_id) LOOP
        l_exist_bad_pay_term := TRUE;
      END LOOP;

    END IF;

    IF l_exist_bad_bill_term THEN

      /* Set the schedule failed flag */
      l_sched_failed := TRUE;

      fnd_message.set_name('PN','PN_SCHED_BILL_REJ_MSG');
      fnd_message.set_token('L_LEASE_NUMBER',l_lease_number);
      fnd_message.set_token('L_LEASE_NAME',l_lease_name);

      pnp_debug_pkg.put_log_msg
      ('+------------------------------------------------------------------------------+');
      pnp_debug_pkg.put_log_msg(fnd_message.get);
      pnp_debug_pkg.put_log_msg
      ('+------------------------------------------------------------------------------+');

    ELSIF l_exist_bad_pay_term THEN

      /* Set the schedule failed flag */
      l_sched_failed := TRUE;

      fnd_message.set_name('PN','PN_SCHED_PAY_REJ_MSG');
      fnd_message.set_token('L_LEASE_NUMBER',l_lease_number);
      fnd_message.set_token('L_LEASE_NAME',l_lease_name);

      pnp_debug_pkg.put_log_msg
      ('+------------------------------------------------------------------------------+');
      pnp_debug_pkg.put_log_msg(fnd_message.get);
      pnp_debug_pkg.put_log_msg
      ('+------------------------------------------------------------------------------+');

    ELSE

      /* get the period name */
      l_period_name := NVL(l_applicable_period,
                          NVL(l_period_name,
                              PNP_UTIL_FUNC.get_default_gl_period
                                           (l_payment_schedule_date,
                                            l_application_id,
					    pn_mo_cache_utils.get_current_org_id)
                             )
                          );

      /* throw error of we cant get the period name */
      IF l_period_name IS NULL THEN

        /* Set the schedule failed flag */
        l_sched_failed := TRUE;

        fnd_message.set_name('PN','PN_GL_PRD_MSG');
        fnd_message.set_token('L_LEASE_NUMBER',l_lease_number);
        fnd_message.set_token('L_LEASE_NAME',l_lease_name);

        pnp_debug_pkg.put_log_msg
        ('+------------------------------------------------------------------------------+');
        pnp_debug_pkg.put_log_msg(fnd_message.get);
        pnp_debug_pkg.put_log_msg
        ('+------------------------------------------------------------------------------+');

      ELSE

        /* if we reached here, looks like we are good to go! */

        SAVEPOINT beforeupdate;

        l_rate_err := FALSE;

        BEGIN
          update_accounted_amount
           ( p_schedule_id     => l_payment_schedule_id
            ,p_functional_curr => l_func_curr
            ,p_conversion_type => l_curr_conv_type
            ,p_item_currency   => l_item_curr);

        EXCEPTION

          WHEN RATE_NOT_DEFINED THEN
            fnd_message.set_name('PN','PN_RATE_NOT_FOUND');
            fnd_message.set_token('CURRENCY', l_func_curr);
            pnp_debug_pkg.put_log_msg
            ('+------------------------------------------------------------------------------+');
            pnp_debug_pkg.put_log_msg(fnd_message.get);
            pnp_debug_pkg.put_log_msg
            ('+------------------------------------------------------------------------------+');

            l_rate_err := TRUE;
            ROLLBACK TO beforeupdate;

          WHEN CURR_CONV_FAILED THEN
            fnd_message.set_name('PN','PN_CONV_TYPE_NOT_FOUND');
            pnp_debug_pkg.put_log_msg
            ('+------------------------------------------------------------------------------+');
            pnp_debug_pkg.put_log_msg(fnd_message.get);
            pnp_debug_pkg.put_log_msg
            ('+------------------------------------------------------------------------------+');

            l_rate_err := TRUE;
            ROLLBACK TO beforeupdate;

          WHEN OTHERS THEN
            RAISE;

        END;

        IF l_rate_err THEN

          /** Record problem currency in plsql table **/
          l_curr_exists := FALSE;

          FOR i IN 0 .. (bad_currency_table.COUNT - 1) LOOP
            IF (bad_currency_table(i) = l_item_curr) THEN
              l_curr_exists := TRUE;
              EXIT;
            END IF;
          END LOOP;

          IF NOT l_curr_exists THEN
             bad_currency_table(bad_currency_table.COUNT) := l_item_curr;
          END IF;

          /* Set the schedule failed flag */
          l_sched_failed := TRUE;

        ELSE

          /* Update the export flags in the items */
          UPDATE PN_PAYMENT_ITEMS
            SET export_to_ap_flag = DECODE(l_lease_class_code,
                                           'DIRECT','Y',
                                                    NULL),
                export_to_ar_flag = DECODE(l_lease_class_code,
                                           'THIRD_PARTY','Y',
                                           'SUB_LEASE'  ,'Y',
                                                        NULL),
	        last_update_date = SYSDATE, --Bug#5389144
                last_updated_by  = NVL(fnd_profile.value('USER_ID'),0), --Bug#5389144
                last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0) --Bug#5389144
            WHERE payment_item_type_lookup_code = 'CASH'
            AND  payment_schedule_id = l_payment_schedule_id;

          /* Approve the schedule */
          UPDATE PN_PAYMENT_SCHEDULES
          SET    payment_status_lookup_code = 'APPROVED',
                 approved_by_user_id = fnd_profile.value('USER_ID'),
                 approval_date = SYSDATE,
                 period_name = l_period_name,
    	         last_update_date = SYSDATE, --Bug#5389144
                 last_updated_by  = NVL(fnd_profile.value('USER_ID'),0), --Bug#5389144
                 last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0) --Bug#5389144
          WHERE  payment_schedule_id = l_payment_schedule_id;

        END IF;

      END IF;

    END IF;

  END IF;

  /* print if approved or unapproved */
  IF l_sched_failed THEN

    fnd_message.set_name('PN', 'PN_APPR_SCHED_FAILED');
    fnd_message.set_token('SCHEDULE_DATE', l_payment_schedule_date);
    pnp_debug_pkg.put_log_msg(fnd_message.get);
    pnp_debug_pkg.put_log_msg(' ');

    /* increment the rejected counter */
    l_sch_rej := l_sch_rej + 1;


  ELSE

    fnd_message.set_name('PN', 'PN_APPR_SCHED_SUCCESS');
    fnd_message.set_token('SCHEDULE_DATE', l_payment_schedule_date);
    pnp_debug_pkg.put_log_msg(fnd_message.get);
    pnp_debug_pkg.put_log_msg(' ');

  END IF;

END LOOP;

IF mass_appr_loc_cur%ISOPEN then
  CLOSE mass_appr_loc_cur;
END IF;

IF mass_appr_cur%ISOPEN then
  CLOSE mass_appr_cur;
END IF;

/* summary */
l_sch_app := l_sch_tot - l_sch_rej;

fnd_message.set_name('PN', 'PN_APPR_SCHED_SUMMARY');
fnd_message.set_token('APPROVED', l_sch_app);
fnd_message.set_token('FAILED', l_sch_rej);
fnd_message.set_token('TOTAL', l_sch_tot);

pnp_debug_pkg.put_log_msg(' ');
pnp_debug_pkg.put_log_msg
('+==============================================================================+');
pnp_debug_pkg.put_log_msg(fnd_message.get);
pnp_debug_pkg.put_log_msg
('+==============================================================================+');

IF bad_currency_table.COUNT > 0 THEN

  pnp_debug_pkg.put_log_msg
  ('+==============================================================================+');
  FOR i IN 0 .. (bad_currency_table.COUNT - 1) LOOP
    fnd_message.set_name('PN','PN_CURRENCY_CONV_FAIL');
    fnd_message.set_token('FROM_CURRENCY', bad_currency_table(i));
    fnd_message.set_token('TO_CURRENCY', l_func_curr);
    pnp_debug_pkg.put_log_msg(fnd_message.get);
  END LOOP;
  pnp_debug_pkg.put_log_msg
  ('+==============================================================================+');

END IF;

PNP_DEBUG_PKG.debug ('PN_MASS_APPR_PKG.approve  (-)');

EXCEPTION
  WHEN others THEN
    retcode := '2';
    RAISE;

END approve;


--------------------------------------------------------------------------------
--
--  NAME         : unapprove
--  DESCRIPTION  : Un-approves the APPROVED schedules that meet the filter
--                 criteria.
--  PURPOSE      : Un-Approves the APPROVED schedules
--  INVOKED FROM : pn_mass_appr_pkg.pn_mass_app
--  ARGUMENTS    : same as pn_mass_appr_pkg.approve() sans the period related
--                 params
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  27-SEP-04  Kiran    o Created
--  11-JAN-05  Anand    o Removed on_hold = 'Y' condition in the cursors.
--                        Bug # 4109792
--  28-NOV-05  pikhar   o Replaced tables with _ALL tables
--------------------------------------------------------------------------------
PROCEDURE unapprove( errbuf                 OUT NOCOPY  VARCHAR2
                    ,retcode                OUT NOCOPY  VARCHAR2
                    ,p_schedule_from_date   IN  DATE
                    ,p_schedule_to_date     IN  DATE
                    ,p_trx_from_date        IN  DATE
                    ,p_trx_to_date          IN  DATE
                    ,p_lease_class_code     IN  VARCHAR2
                    ,p_set_of_books         IN  VARCHAR2
                    ,p_lease_from_number    IN  VARCHAR2
                    ,p_lease_to_number      IN  VARCHAR2
                    ,p_location_from_code   IN  VARCHAR2
                    ,p_location_to_code     IN  VARCHAR2
                    ,p_responsible_user     IN  NUMBER) IS

/* main cursors */
CURSOR mass_unappr_loc_cur IS
  SELECT DISTINCT
         pps.payment_schedule_id s_payment_schedule_id,
         pps.schedule_date       s_schedule_date,
         pl.lease_id             s_lease_id
  FROM   pn_payment_schedules_all pps,
         pn_leases                pl,
         pn_lease_details_all     pld,
         pn_tenancies_all         pt,
         pn_locations_all         ploc
  WHERE  pps.schedule_date BETWEEN NVL(p_schedule_from_date, pps.schedule_date)
                               AND NVL(p_schedule_to_date, pps.schedule_date)
  AND    pps.payment_status_lookup_code = 'APPROVED'
  AND    pl.lease_id = pps.lease_id
  AND    pl.lease_class_code = NVL(p_lease_class_code,pl.lease_class_code)
  AND    pl.lease_num >= NVL(p_lease_from_number, pl.lease_num)
  AND    pl.lease_num <= NVL(p_lease_to_number, pl.lease_num)
  AND    pld.lease_id = pps.lease_id
  AND    pld.responsible_user = NVL(p_responsible_user, pld.responsible_user)
  AND    pt.lease_id = pps.lease_id
  AND    ploc.location_id = pt.location_id
  AND    ploc.location_code >= NVL(p_location_from_code, ploc.location_code)
  AND    ploc.location_code <= NVL(p_location_to_code, ploc.location_code)
  AND    EXISTS(SELECT NULL
                FROM   pn_payment_items_all item
                WHERE  item.payment_schedule_id = pps.payment_schedule_id
                AND    item.due_date BETWEEN NVL(p_trx_from_date,item.due_date)
                                         AND NVL(p_trx_to_date,item.due_date))
  AND   NOT EXISTS (SELECT NULL
                    FROM   pn_payment_items_all pi
                    WHERE  pi.payment_schedule_id = pps.payment_schedule_id
                    AND    (pi.TRANSFERRED_TO_AP_FLAG = 'Y' OR
                            pi.TRANSFERRED_TO_AR_FLAG = 'Y')
                   )
  ORDER BY pl.lease_id, pps.schedule_date;

CURSOR mass_unappr_cur IS
  SELECT DISTINCT
         pps.payment_schedule_id s_payment_schedule_id,
         pps.schedule_date       s_schedule_date,
         pl.lease_id             s_lease_id
  FROM   pn_payment_schedules_all pps,
         pn_leases                pl,
         pn_lease_details_all     pld
  WHERE  pps.schedule_date BETWEEN NVL(p_schedule_from_date, pps.schedule_date)
                               AND NVL(p_schedule_to_date, pps.schedule_date)
  AND    pps.payment_status_lookup_code = 'APPROVED'
  AND    pl.lease_id = pps.lease_id
  AND    pl.lease_class_code = NVL(p_lease_class_code,pl.lease_class_code)
  AND    pl.lease_num >= NVL(p_lease_from_number, pl.lease_num)
  AND    pl.lease_num <= NVL(p_lease_to_number, pl.lease_num)
  AND    pld.lease_id = pps.lease_id
  AND    pld.responsible_user = NVL(p_responsible_user, pld.responsible_user)
  AND    EXISTS (SELECT NULL
                 FROM   pn_payment_items_all item
                 WHERE  item.payment_schedule_id = pps.payment_schedule_id
                 AND    item.due_date BETWEEN NVL(p_trx_from_date,item.due_date)
                                          AND NVL(p_trx_to_date,item.due_date))
  AND   NOT EXISTS (SELECT NULL
                    FROM   pn_payment_items_all pi
                    WHERE  pi.payment_schedule_id = pps.payment_schedule_id
                    AND    (pi.TRANSFERRED_TO_AP_FLAG = 'Y' OR
                            pi.TRANSFERRED_TO_AR_FLAG = 'Y')
                   )
  ORDER BY pl.lease_id, pps.schedule_date;

/* counters */
l_sch_unapp NUMBER;

/* variables */
l_payment_schedule_id   PN_PAYMENT_SCHEDULES_ALL.payment_schedule_id%TYPE;
l_payment_schedule_date PN_PAYMENT_SCHEDULES_ALL.schedule_date%TYPE;
l_lease_id              PN_LEASES_ALL.lease_id%TYPE;

BEGIN

PNP_DEBUG_PKG.debug ('PN_MASS_APPR_PKG.unapprove  (+)');

/* init */
l_sch_unapp := 0;

/* open the appropriate cursor based on whether
   location code has been passed as a parameter or not
*/
IF p_location_from_code IS NOT NULL OR
   p_location_to_code IS NOT NULL THEN

  OPEN mass_unappr_loc_cur;

ELSE

  OPEN mass_unappr_cur;

END IF;

/* loop through the appropriate cursor
   unapprove the schedules
*/
LOOP

  /* fetch from the appropriate cursor */
  IF mass_unappr_loc_cur%ISOPEN THEN

    FETCH mass_unappr_loc_cur
     INTO l_payment_schedule_id
         ,l_payment_schedule_date
         ,l_lease_id;

    EXIT WHEN mass_unappr_loc_cur%NOTFOUND;

  ELSIF mass_unappr_cur%ISOPEN then

    FETCH mass_unappr_cur
     INTO l_payment_schedule_id
         ,l_payment_schedule_date
         ,l_lease_id;

    EXIT WHEN mass_unappr_cur%NOTFOUND;

  END IF;

  /* if we are here, we have a schedule with us to process */

  /* Increment the schedules total */
  l_sch_unapp := l_sch_unapp + 1;

  /* Update the export flags in the items to NULL */
  UPDATE PN_PAYMENT_ITEMS
  SET    export_to_ap_flag = NULL,
         export_to_ar_flag = NULL
  WHERE  payment_item_type_lookup_code = 'CASH'
  AND    payment_schedule_id = l_payment_schedule_id;

  /* Approve the schedule */
  UPDATE PN_PAYMENT_SCHEDULES
  SET    payment_status_lookup_code = 'DRAFT',
         approved_by_user_id = NULL,
         approval_date = NULL,
         period_name = NULL
  WHERE  payment_schedule_id = l_payment_schedule_id;

  fnd_message.set_name('PN', 'PN_UNAPPR_SCHED_SUCCESS');
  fnd_message.set_token('SCHEDULE_DATE', l_payment_schedule_date);
  pnp_debug_pkg.put_log_msg(fnd_message.get);
  pnp_debug_pkg.put_log_msg(' ');

END LOOP;

fnd_message.set_name('PN', 'PN_UNAPPR_SCHED_SUMMARY');
fnd_message.set_token('UNAPPROVED', l_sch_unapp);

pnp_debug_pkg.put_log_msg(' ');
pnp_debug_pkg.put_log_msg
('+==============================================================================+');
pnp_debug_pkg.put_log_msg(fnd_message.get);
pnp_debug_pkg.put_log_msg
('+==============================================================================+');

PNP_DEBUG_PKG.debug ('PN_MASS_APPR_PKG.unapprove  (-)');

EXCEPTION
  WHEN others THEN
    retcode := '2';
    RAISE;
END unapprove;


--------------------------------------------------------------------------------
--  NAME         : pn_mass_app
--  DESCRIPTION  : The main procedure called from the SRS form for Mass Approve
--                 /Un-Approve program. Delegates the task to approve() or
--                 unapprove() based on the action type.
--  PURPOSE      : approve/Un-Approve schedules.
--  INVOKED FROM : SRS screen.
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  30-SEP-04  Kiran     o Reorganized - now the procedure delegates the task to
--                         approve() and unapprove() - (has been promoted to a
--                         managerial post ;))
--------------------------------------------------------------------------------
PROCEDURE pn_mass_app( errbuf                 OUT NOCOPY  VARCHAR2
                      ,retcode                OUT NOCOPY  VARCHAR2
                      ,p_action_type          IN  VARCHAR2
                      ,p_schedule_from_date   IN  VARCHAR2
                      ,p_schedule_to_date     IN  VARCHAR2
                      ,p_trx_from_date        IN  VARCHAR2
                      ,p_trx_to_date          IN  VARCHAR2
                      ,p_lease_class_code     IN  VARCHAR2
                      ,p_set_of_books         IN  VARCHAR2
                      ,p_payment_period_dummy IN  VARCHAR2
                      ,p_billing_period_dummy IN  VARCHAR2
                      ,p_payment_period       IN  VARCHAR2
                      ,p_billing_period       IN  VARCHAR2
                      ,p_lease_from_number    IN  VARCHAR2
                      ,p_lease_to_number      IN  VARCHAR2
                      ,p_location_from_code   IN  VARCHAR2
                      ,p_location_to_code     IN  VARCHAR2
                      ,p_responsible_user     IN  NUMBER) IS

/* convert the dates cannonical to date */
l_sch_from_dt DATE := fnd_date.canonical_to_date(p_schedule_from_date);
l_sch_to_dt   DATE := fnd_date.canonical_to_date(p_schedule_to_date);
l_trx_from_dt DATE := fnd_date.canonical_to_date(p_trx_from_date);
l_trx_to_dt   DATE := fnd_date.canonical_to_date(p_trx_to_date);

BEGIN

PNP_DEBUG_PKG.debug('pn_mass_appr_pkg.pn_mass_app (+)');

/* --- MESSAGE NEEDED --- */
/* need to print the i/p params */
fnd_message.set_name('PN','PN_MASAPB_PARAMS');
fnd_message.set_token('P_ACTION_TYPE', p_action_type);
fnd_message.set_token('P_SCHEDULE_FROM_DATE', p_schedule_from_date);
fnd_message.set_token('P_SCHEDULE_TO_DATE', p_schedule_to_date);
fnd_message.set_token('P_TRX_FROM_DATE', p_trx_from_date);
fnd_message.set_token('P_TRX_TO_DATE', p_trx_to_date);
fnd_message.set_token('P_LEASE_CLASS_CODE', p_lease_class_code);
fnd_message.set_token('P_SET_OF_BOOKS', p_set_of_books);
fnd_message.set_token('P_PAYMENT_PERIOD', p_payment_period);
fnd_message.set_token('P_BILLING_PERIOD', p_billing_period);
fnd_message.set_token('P_LEASE_FROM_NUMBER', p_lease_from_number);
fnd_message.set_token('P_LEASE_TO_NUMBER', p_lease_to_number);
fnd_message.set_token('P_LOCATION_FROM_CODE', p_location_from_code);
fnd_message.set_token('P_LOCATION_TO_CODE', p_location_to_code);
fnd_message.set_token('P_RESPONSIBLE_USER', p_responsible_user);

pnp_debug_pkg.put_log_msg
('+------------------------------------------------------------------------------+');
pnp_debug_pkg.put_log_msg(fnd_message.get);
pnp_debug_pkg.put_log_msg
('+------------------------------------------------------------------------------+');


/* retcode values
   0 - success
   1 - warning
   2 - error
*/
retcode := '0';

/* validate the inputs */

/* if a from date is entered, to date must be entered
   holds good for schedule date and transaction date */

IF (p_schedule_from_date IS NOT NULL AND p_schedule_to_date IS NULL) OR
   (p_schedule_from_date IS NULL AND p_schedule_to_date IS NOT NULL) OR
   (p_trx_from_date IS NULL AND p_trx_to_date IS NOT NULL) OR
   (p_trx_from_date IS NOT NULL AND p_trx_to_date IS NULL)
THEN

  raise INPUT_DATE_MISSING;

END IF;

/* either schedule date range or transaction date range must be entered */
IF p_schedule_from_date IS NULL AND
   p_schedule_to_date IS NULL AND
   p_trx_from_date IS NULL AND
   p_trx_to_date IS NULL
THEN

  raise INPUT_DATE_MISSING;

END IF;

IF p_action_type = 'APPROVE' THEN

  approve( errbuf                 => errbuf
          ,retcode                => retcode
          ,p_schedule_from_date   => l_sch_from_dt
          ,p_schedule_to_date     => l_sch_to_dt
          ,p_trx_from_date        => l_trx_from_dt
          ,p_trx_to_date          => l_trx_to_dt
          ,p_lease_class_code     => p_lease_class_code
          ,p_set_of_books         => p_set_of_books
          ,p_payment_period       => p_payment_period
          ,p_billing_period       => p_billing_period
          ,p_lease_from_number    => p_lease_from_number
          ,p_lease_to_number      => p_lease_to_number
          ,p_location_from_code   => p_location_from_code
          ,p_location_to_code     => p_location_to_code
          ,p_responsible_user     => p_responsible_user
         );

ELSIF p_action_type = 'UNAPPROVE' THEN

  unapprove( errbuf                 => errbuf
            ,retcode                => retcode
            ,p_schedule_from_date   => l_sch_from_dt
            ,p_schedule_to_date     => l_sch_to_dt
            ,p_trx_from_date        => l_trx_from_dt
            ,p_trx_to_date          => l_trx_to_dt
            ,p_lease_class_code     => p_lease_class_code
            ,p_set_of_books         => p_set_of_books
            ,p_lease_from_number    => p_lease_from_number
            ,p_lease_to_number      => p_lease_to_number
            ,p_location_from_code   => p_location_from_code
            ,p_location_to_code     => p_location_to_code
            ,p_responsible_user     => p_responsible_user
           );

END IF;

PNP_DEBUG_PKG.debug('pn_mass_appr_pkg.pn_mass_app (-)');

EXCEPTION
  WHEN INPUT_DATE_MISSING THEN
    fnd_message.set_name('PN','PN_MASAPB_NO_DATE');
    pnp_debug_pkg.put_log_msg
    ('+------------------------------------------------------------------------------+');
    pnp_debug_pkg.put_log_msg(fnd_message.get);
    pnp_debug_pkg.put_log_msg
    ('+------------------------------------------------------------------------------+');
    retcode := '2';

  WHEN OTHERS THEN
    retcode := '2';
    RAISE;

END pn_mass_app;

END pn_mass_appr_pkg;

/
