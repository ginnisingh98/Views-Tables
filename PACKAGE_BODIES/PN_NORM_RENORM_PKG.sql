--------------------------------------------------------
--  DDL for Package Body PN_NORM_RENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_NORM_RENORM_PKG" AS
  -- $Header: PNRENRMB.pls 120.5.12010000.8 2010/01/19 07:26:45 jsundara ship $

/* procedure spec for the private procedures */
PROCEDURE RENORMALIZE_ACROSS_ALL_DRAFT
          (p_lease_context      IN  VARCHAR2,
           p_lease_id           IN  NUMBER,
           p_term_id            IN  NUMBER,
           p_vendor_id          IN  NUMBER,
           p_cust_id            IN  NUMBER,
           p_vendor_site_id     IN  NUMBER,
           p_cust_site_use_id   IN  NUMBER,
           p_cust_ship_site_id  IN  NUMBER,
           p_sob_id             IN  NUMBER,
           p_curr_code          IN  VARCHAR2,
           p_sch_day            IN  NUMBER,
           p_norm_str_dt        IN  DATE,
           p_norm_end_dt        IN  DATE,
           p_rate               IN  NUMBER);

PROCEDURE RENORMALIZE_IN_FIRST_DRAFT
          (p_lease_context      IN  VARCHAR2,
           p_lease_id           IN  NUMBER,
           p_term_id            IN  NUMBER,
           p_vendor_id          IN  NUMBER,
           p_cust_id            IN  NUMBER,
           p_vendor_site_id     IN  NUMBER,
           p_cust_site_use_id   IN  NUMBER,
           p_cust_ship_site_id  IN  NUMBER,
           p_sob_id             IN  NUMBER,
           p_curr_code          IN  VARCHAR2,
           p_sch_day            IN  NUMBER,
           p_norm_str_dt        IN  DATE,
           p_norm_end_dt        IN  DATE,
           p_rate               IN  NUMBER);


                /* all procedure body */

/*------------------------------------------------------------------------------
NAME         : RENORMALIZE_ACROSS_ALL_DRAFT
DESCRIPTION  : Procedure to handle renormalization when the profile option for
               'Renormalization across all draft schedules' is Y.
               The renormalization is done across all original draft schedules.
HISTORY      :
  20-OCT-04   atuppad   o Created
  15-JUL-05  SatyaDeep  o Replaced base views with their _ALL tables
------------------------------------------------------------------------------*/
PROCEDURE RENORMALIZE_ACROSS_ALL_DRAFT
          (p_lease_context      IN  VARCHAR2,
           p_lease_id           IN  NUMBER,
           p_term_id            IN  NUMBER,
           p_vendor_id          IN  NUMBER,
           p_cust_id            IN  NUMBER,
           p_vendor_site_id     IN  NUMBER,
           p_cust_site_use_id   IN  NUMBER,
           p_cust_ship_site_id  IN  NUMBER,
           p_sob_id             IN  NUMBER,
           p_curr_code          IN  VARCHAR2,
           p_sch_day            IN  NUMBER,
           p_norm_str_dt        IN  DATE,
           p_norm_end_dt        IN  DATE,
           p_rate               IN  NUMBER)
IS

  /* get total cash amount */
  CURSOR GET_CASH_TOTAL IS
    SELECT NVL(SUM(actual_amount), 0) total_cash_amount
    FROM   pn_payment_items_all
    WHERE  payment_term_id = p_term_id
    AND    payment_item_type_lookup_code = 'CASH';

  /* get total approved norm amount */
  CURSOR GET_NORM_TOTAL IS
    SELECT NVL(SUM(actual_amount), 0) total_norm_amount
    FROM   pn_payment_items_all item,
           pn_payment_schedules_all schedule
    WHERE  schedule.lease_id = p_lease_id
    AND    item.payment_schedule_id = schedule.payment_schedule_id
    AND    item.payment_term_id = p_term_id
    AND    item.payment_item_type_lookup_code = 'NORMALIZED'
    AND    schedule.payment_status_lookup_code IN  ('APPROVED','ON_HOLD');

  l_cash_total               NUMBER;
  l_norm_apprv_total         NUMBER;
  l_total_schedules          NUMBER;
  l_norm_months              NUMBER;
  l_rounding_err             NUMBER;
  l_new_normalized_amount    NUMBER;
  l_day_of_norm_start_dt     VARCHAR2(2);
  l_day_of_norm_end_dt       VARCHAR2(2);
  l_partial_start_flag       BOOLEAN;
  l_partial_start_fraction   NUMBER;
  l_partial_end_flag         BOOLEAN;
  l_partial_end_fraction     NUMBER;
  l_precision                NUMBER;
  l_ext_precision            NUMBER;
  l_min_acct_unit            NUMBER;
  l_norm_start_sch_date      DATE;
  l_norm_end_sch_date        DATE;
  l_end_fraction_amt         NUMBER;
  l_start_fraction_amt       NUMBER;
  l_norm_amt                 NUMBER;  /* 6838211 */
 	l_amd_comn_date            DATE;  /* 6838211 */
 	l_sch_date_1               DATE;    /* 6838211 */
 	l_act_amt                  NUMBER := 0;  /* 6893609 */
  l_app_amt                  NUMBER;  /* 6893609 */
  l_term_amt		             NUMBER:= 0; /* 8491119 */
  l_plr_amt		               NUMBER:= 0; /* 8491119 */
  l_amd_comn_date_tmp	       DATE;     /* 8491119 */


CURSOR org_cur IS
SELECT org_id
FROM pn_payment_terms_all
WHERE payment_term_id = p_term_id;

/*Bug4956314 */
CURSOR check_cash_item (b_schedule_id NUMBER,b_term_id NUMBER)
IS
SELECT 1 FROM dual
WHERE  exists
       (SELECT 1
        FROM   pn_payment_items_all ppi
        WHERE  ppi.payment_schedule_id = b_schedule_id
        AND    ppi.payment_item_type_lookup_code = 'CASH'
        AND    ppi.payment_term_id = b_term_id
       );

l_cash_item NUMBER;

/*Bug4956314 */


  l_org_id NUMBER;

BEGIN

   select change_commencement_date
 	 INTO l_amd_comn_date
 	 from pn_lease_changes_all
 	 where lease_id =  p_lease_id
 	 and lease_change_id = (
 	 select lease_change_id from pn_lease_details_all
 	 where lease_id =  p_lease_id);   /*  6838211 */

 	   pnp_debug_pkg.log('    l_amd_comn_date     : ' || l_amd_comn_date );
 	   pnp_debug_pkg.log('    p_norm_str_dt     : ' || p_norm_str_dt );

 	IF l_amd_comn_date > p_norm_str_dt THEN     /* 6893609 */
          l_amd_comn_date_tmp := p_norm_str_dt;
  ELSE
          l_amd_comn_date_tmp :=  l_amd_comn_date;
  END IF;

 	  SELECT NVL(SUM(ppi.actual_amount),0)   /* 6893609 */
       INTO l_app_amt
       FROM   pn_payment_items_all ppi,
               pn_payment_schedules_all pps
       WHERE  ppi.payment_term_id =  p_term_id
       AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
       AND    pps.payment_schedule_id = ppi.payment_schedule_id
       AND    pps.payment_status_lookup_code <> 'DRAFT'
      and schedule_date >=  pn_schedules_items.FIRST_DAY(l_amd_comn_date_tmp) /* 8491119 */
       and    schedule_date <=  (SELECT lease_termination_date from
       pn_lease_details_all where lease_id = p_lease_id );

Select NVL(SUM(ppi.actual_amount),0)
into l_term_amt
FROM   pn_payment_items_all ppi,
       pn_payment_schedules_all pps
WHERE  ppi.payment_term_id =  p_term_id
AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
AND    pps.payment_schedule_id = ppi.payment_schedule_id
AND    pps.payment_status_lookup_code <> 'DRAFT'
AND    to_char(schedule_date,'MON-YY')  =  to_char(l_amd_comn_date,'MON-YY'); /* 8491119 */

  pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_ACROSS_ALL_DRAFT (+) ');
  pnp_debug_pkg.log('    Procedure called with Parameters... ');
  pnp_debug_pkg.log('    p_lease_context     : ' || p_lease_context );
  pnp_debug_pkg.log('    p_lease_id          : ' || p_lease_id );
  pnp_debug_pkg.log('    p_term_id           : ' || p_term_id );
  pnp_debug_pkg.log('    p_vendor_id         : ' || p_vendor_id );
  pnp_debug_pkg.log('    p_cust_id           : ' || p_cust_id );
  pnp_debug_pkg.log('    p_vendor_site_id    : ' || p_vendor_site_id );
  pnp_debug_pkg.log('    p_cust_site_use_id  : ' || p_cust_site_use_id );
  pnp_debug_pkg.log('    p_cust_ship_site_id : ' || p_cust_ship_site_id );
  pnp_debug_pkg.log('    p_sob_id            : ' || p_sob_id );
  pnp_debug_pkg.log('    p_curr_code         : ' || p_curr_code );
  pnp_debug_pkg.log('    p_sch_day           : ' || p_sch_day );
  pnp_debug_pkg.log('    p_norm_str_dt       : ' || p_norm_str_dt );
  pnp_debug_pkg.log('    p_norm_end_dt       : ' || p_norm_end_dt );
  pnp_debug_pkg.log('    p_rate              : ' || p_rate );

  /* initilizations*/
  l_partial_start_flag := FALSE;
  l_partial_end_flag   := FALSE;
  l_total_schedules    := g_norm_item_tbl.COUNT;
  l_norm_months        := l_total_schedules;
  l_start_fraction_amt := 0;
  l_end_fraction_amt   := 0;
  fnd_currency.get_info(p_curr_code, l_precision, l_ext_precision, l_min_acct_unit);

  FOR get_cash_rec IN get_cash_total LOOP
    l_cash_total := get_cash_rec.total_cash_amount;
  END LOOP;

  pnp_debug_pkg.log('l_cash_total     : '||TO_CHAR(l_cash_total));

  FOR get_norm_rec IN get_norm_total LOOP
    l_norm_apprv_total := get_norm_rec.total_norm_amount;
  END LOOP;
 pnp_debug_pkg.log(' l_norm_apprv_total     : '||TO_CHAR( l_norm_apprv_total));

 l_norm_apprv_total := l_norm_apprv_total - NVL(l_app_amt,0);  /* 6893609 */

 pnp_debug_pkg.log(' leave alone amount     : '||TO_CHAR( l_norm_apprv_total));

  /* find which day of month the lease starts.*/
  l_day_of_norm_start_dt := TO_CHAR(p_norm_str_dt,'DD');

  /* find which day of month the lease ends. */
  l_day_of_norm_end_dt := TO_CHAR(p_norm_end_dt,'DD');

  /* get the first norm schedule date */
  l_norm_start_sch_date := TO_DATE(
                           TO_CHAR(
                           p_sch_day)||'/'||TO_CHAR(p_norm_str_dt,'MM/YYYY'),'DD/MM/YYYY');

  /* get the last norm schedule date */
  l_norm_end_sch_date   := TO_DATE(
                           TO_CHAR(
                           p_sch_day)||'/'||TO_CHAR(p_norm_end_dt,'MM/YYYY'),'DD/MM/YYYY');

  /* partial start month */
  IF l_day_of_norm_start_dt <> '01' AND
     l_norm_start_sch_date = g_norm_item_tbl(0).schedule_date THEN

    l_partial_start_flag := TRUE;
    IF g_pr_rule = 999 THEN
       l_partial_start_fraction := ((LAST_DAY(p_norm_str_dt) - p_norm_str_dt)+1)/
                                   TO_NUMBER(TO_CHAR(LAST_DAY(p_norm_str_dt),'DD'));
    ELSE
       l_partial_start_fraction := ((LAST_DAY(p_norm_str_dt) - p_norm_str_dt)+1)*12/g_pr_rule;
    END IF;
    l_norm_months := (l_norm_months - 1) + NVL(l_partial_start_fraction,0);

    pnp_debug_pkg.log('create_normalize_items - l_partial_start_fraction - 1  : '
                        ||TO_CHAR(l_partial_start_fraction));  /* 8491119 */

    l_plr_amt := l_term_amt - (l_partial_start_fraction * l_term_amt);


       pnp_debug_pkg.log('create_normalize_items - l_partial_amount to be left before calc remaining amt for renorm   : '
                           ||TO_CHAR(l_plr_amt));


  END IF; /* 6893609 */

  /* partial end month */
  IF l_day_of_norm_end_dt <> TO_CHAR(LAST_DAY(p_norm_end_dt),'DD') AND
     l_norm_end_sch_date = g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).schedule_date THEN

    l_partial_end_flag := TRUE;
    IF  g_pr_rule = 999 THEN
       l_partial_end_fraction := TO_NUMBER(TO_CHAR(p_norm_end_dt,'DD'))/
                                 TO_NUMBER(TO_CHAR(LAST_DAY(p_norm_end_dt),'DD'));

       pnp_debug_pkg.log('create_normalize_items - l_partial_end_fraction - 1  : '
                        ||TO_CHAR(l_partial_end_fraction));  /* 6893609 */
    ELSE
       l_partial_end_fraction := TO_NUMBER(TO_CHAR(p_norm_end_dt,'DD'))*12/g_pr_rule;

       pnp_debug_pkg.log('create_normalize_items - l_partial_end_fraction - 2  : '
                        ||TO_CHAR(l_partial_end_fraction));  /* 6893609 */
    END IF;
    l_norm_months := (l_norm_months - 1) + NVL(l_partial_end_fraction,0);
  END IF;

  pnp_debug_pkg.log('l_norm_months    : '||TO_CHAR(l_norm_months));

  /* calculate new normalized amount */
  IF l_norm_months <= 1 THEN
      l_new_normalized_amount := l_cash_total - l_norm_apprv_total - l_plr_amt; /* 8491119 */
     l_partial_start_flag := FALSE;
     l_partial_end_flag := FALSE;
  ELSE
     l_new_normalized_amount  := (l_cash_total - l_norm_apprv_total - l_plr_amt )/l_norm_months; /* 8491119 */
  END IF;

  pnp_debug_pkg.log('l_new_normalized_amount    : '||TO_CHAR(l_new_normalized_amount));

/*populate the pl/sql table */
  FOR i IN 0 .. g_norm_item_tbl.COUNT - 1 LOOP
       g_norm_item_tbl(i).normalized_amount := l_new_normalized_amount;
  END LOOP;

  IF g_norm_item_tbl.COUNT > 1 THEN
    /* prorate - partial start  */
    IF l_partial_start_flag THEN
    g_norm_item_tbl(0).normalized_amount /* 8599816 */
      := ROUND((l_new_normalized_amount * l_partial_start_fraction) + l_plr_amt, l_precision); /* 8491119 */
    END IF;

    /* prorate - partial end */
    IF l_partial_end_flag THEN
      g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).normalized_amount
        := ROUND(l_new_normalized_amount * l_partial_end_fraction, l_precision);
    END IF;

  ELSIF g_norm_item_tbl.COUNT = 1 THEN
    /* prorate - partial start */
    IF l_partial_start_flag THEN
      l_start_fraction_amt
        := ROUND(l_new_normalized_amount * l_partial_start_fraction, l_precision);
    END IF;

    /* prorate - partial start */
    IF l_partial_end_flag THEN
      l_end_fraction_amt
        := ROUND(l_new_normalized_amount * l_partial_end_fraction, l_precision);
    END IF;

    IF l_partial_start_flag AND l_partial_end_flag THEN
      g_norm_item_tbl(0).normalized_amount := l_start_fraction_amt + l_end_fraction_amt - l_new_normalized_amount;
    ELSIF l_partial_start_flag THEN
      g_norm_item_tbl(0).normalized_amount := l_start_fraction_amt;
    ELSIF l_partial_end_flag THEN
      g_norm_item_tbl(0).normalized_amount := l_end_fraction_amt;
    ELSE
      g_norm_item_tbl(0).normalized_amount := l_new_normalized_amount;
    END IF;

  END IF; /* end for g_norm_item_tbl.COUNT > 1 */

/* start for 7149537
  adjust rounding error for last item
  IF g_norm_item_tbl.COUNT > 2 THEN
    l_rounding_err := l_cash_total - ((l_new_normalized_amount * ((g_norm_item_tbl.COUNT)-2))
                                      + g_norm_item_tbl(0).normalized_amount
                                      + g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).normalized_amount
                                      + l_norm_apprv_total
                                     );
  ELSIF g_norm_item_tbl.COUNT = 2 THEN
    l_rounding_err := l_cash_total - (g_norm_item_tbl(0).normalized_amount
                                      + g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).normalized_amount
                                      + l_norm_apprv_total
                                     );
  ELSIF g_norm_item_tbl.COUNT = 1 THEN
    l_rounding_err := l_cash_total - (g_norm_item_tbl(0).normalized_amount
                                      + l_norm_apprv_total
                                     );
  END IF;

  IF l_rounding_err <> 0 THEN
    g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).normalized_amount
      := g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).normalized_amount + l_rounding_err;
  END IF;
 end 7149537  */

  /* start to create/update normalized items */
  FOR i IN 0 .. g_norm_item_tbl.COUNT - 1 LOOP

      begin -- ver6
    	    SELECT SUM(actual_amount) /* Bug 6893609*/
    	    into   l_act_amt
            FROM   pn_payment_items_all ppi,
                   pn_payment_schedules_all pps
            WHERE ppi.payment_item_type_lookup_code = 'NORMALIZED'
            AND   pps.payment_schedule_id = ppi.payment_schedule_id
            AND   ppi.payment_term_id =  p_term_id
            AND   pps.payment_status_lookup_code <>  'DRAFT'
            AND   due_date = g_norm_item_tbl(i).schedule_date;

	   if l_act_amt <> 0 then
            g_norm_item_tbl(i).normalized_amount := ((-1 * l_act_amt) + g_norm_item_tbl(i).normalized_amount);
       END IF;
      exception -- ver6
          when no_data_found then
            l_act_amt := 0;
      end;

    /* first try to update */
    UPDATE pn_payment_items_all ppi
    SET    ppi.actual_amount = g_norm_item_tbl(i).normalized_amount,
           ppi.export_currency_amount = g_norm_item_tbl(i).normalized_amount,
           ppi.last_update_date = SYSDATE,
           ppi.last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
           ppi.last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
    WHERE  ppi.payment_schedule_id = g_norm_item_tbl(i).schedule_id
    AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
    AND    ppi.payment_term_id = p_term_id;

    IF NVL(SQL%ROWCOUNT, 0) = 0 THEN

      FOR rec IN org_cur LOOP
        l_org_id := rec.org_id;
      END LOOP;

      INSERT INTO pn_payment_items_all
      (
       payment_item_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       actual_amount,
       estimated_amount,
       due_date,
       payment_item_type_lookup_code,
       payment_term_id,
       payment_schedule_id,
       period_fraction,
       vendor_id,
       customer_id,
       vendor_site_id,
       customer_site_use_id,
       cust_ship_site_id,
       set_of_books_id,
       currency_code,
       export_currency_code,
       export_currency_amount,
       rate,
       org_id
       )
        VALUES
       (
       PN_PAYMENT_ITEMS_S.NEXTVAL,
       SYSDATE,
       NVL(fnd_profile.value('USER_ID'),0),
       SYSDATE,
       NVL(fnd_profile.value('USER_ID'),0),
       NVL(fnd_profile.value('LOGIN_ID'),0),
       g_norm_item_tbl(i).normalized_amount,
       NULL,
       g_norm_item_tbl(i).schedule_date,
       'NORMALIZED',
       p_term_id,
       g_norm_item_tbl(i).schedule_id,
       1,
       p_vendor_id,
       p_cust_id,
       p_vendor_site_id,
       p_cust_site_use_id,
       p_cust_ship_site_id,
       p_sob_id,
       p_curr_code,
       p_curr_code,
       g_norm_item_tbl(i).normalized_amount,
       p_rate,
       l_org_id
       );
    END IF;

    /*S.N. Bug 4956314 */

    l_cash_item:=0;

    FOR r_rec IN check_cash_item(g_norm_item_tbl(i).schedule_id,p_term_id)
    LOOP
        l_cash_item:=1;
    END LOOP;

    IF l_cash_item = 0 THEN
       pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_ACROSS_ALL_DRAFT -> create $ 0 cash items(+)');
       pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_ACROSS_ALL_DRAFT -> for schedule id : '||g_norm_item_tbl(i).schedule_id);
       pn_schedules_items.create_cash_items
                          (p_est_amt           => 0,
                           p_act_amt           => 0,
                           p_sch_dt            => g_norm_item_tbl(i).schedule_date,
                           p_sch_id            => g_norm_item_tbl(i).schedule_id,
                           p_term_id           => p_term_id,
                           p_vendor_id         => p_vendor_id,
                           p_cust_id           => p_cust_id,
                           p_vendor_site_id    => p_vendor_site_id,
                           p_cust_site_use_id  => p_cust_site_use_id,
                           p_cust_ship_site_id => p_cust_ship_site_id,
                           p_sob_id            => p_sob_id,
                           p_curr_code         => p_curr_code,
                           p_rate              => p_rate);
      pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_ACROSS_ALL_DRAFT -> $ 0 cash item created(-) ');
    END IF;

   /*E.N. Bug 4956314 */

  END LOOP;

  /* update the table */
  UPDATE pn_payment_terms_all
  SET    event_type_code = p_lease_context,
         norm_start_date = p_norm_str_dt,
         norm_end_date   = p_norm_end_dt
  WHERE  normalize ='Y'
  AND    payment_term_id = p_term_id;

  pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_ACROSS_ALL_DRAFT (-) ');
EXCEPTION
  WHEN OTHERS THEN
    pnp_debug_pkg.log('  RENORMALIZE_ACROSS_ALL_DRAFT - OTHERS ERROR ... ' || sqlerrm);

END RENORMALIZE_ACROSS_ALL_DRAFT;


/*------------------------------------------------------------------------------
NAME         : RENORMALIZE_IN_FIRST_DRAFT
DESCRIPTION  : Procedure to handle renormalization when the profile option for
               'Renormalization across all draft schedules' is N.
               The adjustment amount of renormalization is tied to the first
               draft schedule.
HISTORY      :
  20-OCT-04   atuppad   o Created
------------------------------------------------------------------------------*/
PROCEDURE RENORMALIZE_IN_FIRST_DRAFT
          (p_lease_context      IN  VARCHAR2,
           p_lease_id           IN  NUMBER,
           p_term_id            IN  NUMBER,
           p_vendor_id          IN  NUMBER,
           p_cust_id            IN  NUMBER,
           p_vendor_site_id     IN  NUMBER,
           p_cust_site_use_id   IN  NUMBER,
           p_cust_ship_site_id  IN  NUMBER,
           p_sob_id             IN  NUMBER,
           p_curr_code          IN  VARCHAR2,
           p_sch_day            IN  NUMBER,
           p_norm_str_dt        IN  DATE,
           p_norm_end_dt        IN  DATE,
           p_rate               IN  NUMBER)
IS

  CURSOR GET_CASH_TOTAL IS
    SELECT NVL(SUM(actual_amount), 0) total_cash_amount
    FROM   pn_payment_items_all
    WHERE  payment_term_id = p_term_id
    AND    payment_item_type_lookup_code = 'CASH';

  CURSOR GET_NORM_TOTAL IS
    SELECT NVL(SUM(actual_amount), 0) total_norm_amount
    FROM   pn_payment_items_all item,
           pn_payment_schedules_all schedule
    WHERE  schedule.lease_id = p_lease_id
    AND    item.payment_schedule_id = schedule.payment_schedule_id
    AND    item.payment_term_id = p_term_id
    AND    item.payment_item_type_lookup_code = 'NORMALIZED'
    AND    schedule.payment_status_lookup_code  <> 'DRAFT'; /*= 'APPROVED'; for bug# 7149537*/

  CURSOR GET_LAST_APPRV_SCH IS
    SELECT MAX(schedule.schedule_date) last_apprv_sch
    FROM   pn_payment_schedules_all schedule,
           pn_payment_items_all item
    WHERE  schedule.lease_id = p_lease_id
    AND    item.payment_schedule_id = schedule.payment_schedule_id
    AND    schedule.payment_status_lookup_code = 'APPROVED'
    AND    item.payment_term_id = p_term_id;

  /* Get schedule ID of a draft schedule containing original payment item
     post the last approved schedule date */
  CURSOR GET_ORIG_SCH_AFTER(p_last_apprv_sch DATE) IS
    SELECT MIN(schedule.schedule_date) first_draft_sch
    FROM   pn_payment_schedules_all schedule,
           pn_payment_items_all item
    WHERE  schedule.lease_id = p_lease_id
    AND    item.payment_schedule_id = schedule.payment_schedule_id
    AND    schedule.payment_status_lookup_code = 'DRAFT'
    AND    item.payment_term_id = p_term_id
    AND    item.last_adjustment_type_code IS NULL
    AND    schedule.schedule_date > p_last_apprv_sch;

  /* Get schedule ID of a draft schedule containing original payment item */
  CURSOR GET_FIRST_DRAFT_ORIG_SCH IS
    SELECT MIN(schedule.schedule_date) first_draft_sch
    FROM   pn_payment_schedules_all schedule,
           pn_payment_items_all item
    WHERE  schedule.lease_id = p_lease_id
    AND    item.payment_schedule_id = schedule.payment_schedule_id
    AND    schedule.payment_status_lookup_code = 'DRAFT'
    AND    item.payment_term_id = p_term_id
    AND    item.last_adjustment_type_code IS NULL;

 /* Get schedule ID of a draft schedule - original or adjustment */
 CURSOR GET_FIRST_DRAFT_SCH IS
   SELECT MIN(schedule.schedule_date) first_draft_sch,
          schedule.payment_schedule_id pay_schd_id
   FROM   pn_payment_schedules_all schedule,
          pn_payment_items_all item
   WHERE  item.payment_schedule_id = schedule.payment_schedule_id
   AND    schedule.payment_status_lookup_code = 'DRAFT'
   AND    item.payment_term_id = p_term_id
   GROUP BY schedule.payment_schedule_id;

  l_cash_total               NUMBER;
  l_norm_apprv_total         NUMBER;
  l_partial_start_flag       BOOLEAN;
  l_partial_start_fraction   NUMBER;
  l_partial_end_flag         BOOLEAN;
  l_partial_end_fraction     NUMBER;
  l_precision                NUMBER;
  l_ext_precision            NUMBER;
  l_min_acct_unit            NUMBER;
  l_total_schedules          NUMBER;
  l_norm_months              NUMBER;
  l_day_of_norm_start_dt     VARCHAR2(2);
  l_day_of_norm_end_dt       VARCHAR2(2);
  l_norm_start_sch_date      DATE;
  l_norm_end_sch_date        DATE;
  l_last_apprv_sch_dt        DATE;
  l_adjustment_amount        NUMBER;
  l_adjustment_sch_dt        DATE;
  l_new_normalized_amount    NUMBER;
  l_start_fraction_amt       NUMBER;
  l_end_fraction_amt         NUMBER;

  CURSOR org_cur IS
    SELECT org_id
    FROM pn_payment_terms_all
    WHERE payment_term_id = p_term_id;

  /*Bug4956314 */
  CURSOR check_cash_item (b_schedule_id NUMBER,b_term_id NUMBER)
  IS
  SELECT 1 FROM dual
  WHERE  exists
         (SELECT 1
          FROM   pn_payment_items_all ppi
          WHERE  ppi.payment_schedule_id = b_schedule_id
          AND    ppi.payment_item_type_lookup_code = 'CASH'
          AND    ppi.payment_term_id = b_term_id
         );

  l_cash_item NUMBER;

  /*Bug4956314 */


  l_org_id NUMBER;

BEGIN
  pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_IN_FIRST_DRAFT (+) ');
  pnp_debug_pkg.log('    Procedure called with Parameters... ');
  pnp_debug_pkg.log('    p_lease_context     : ' || p_lease_context );
  pnp_debug_pkg.log('    p_lease_id          : ' || p_lease_id );
  pnp_debug_pkg.log('    p_term_id           : ' || p_term_id );
  pnp_debug_pkg.log('    p_vendor_id         : ' || p_vendor_id );
  pnp_debug_pkg.log('    p_cust_id           : ' || p_cust_id );
  pnp_debug_pkg.log('    p_vendor_site_id    : ' || p_vendor_site_id );
  pnp_debug_pkg.log('    p_cust_site_use_id  : ' || p_cust_site_use_id );
  pnp_debug_pkg.log('    p_cust_ship_site_id : ' || p_cust_ship_site_id );
  pnp_debug_pkg.log('    p_sob_id            : ' || p_sob_id );
  pnp_debug_pkg.log('    p_curr_code         : ' || p_curr_code );
  pnp_debug_pkg.log('    p_sch_day           : ' || p_sch_day );
  pnp_debug_pkg.log('    p_norm_str_dt       : ' || p_norm_str_dt );
  pnp_debug_pkg.log('    p_norm_end_dt       : ' || p_norm_end_dt );
  pnp_debug_pkg.log('    p_rate              : ' || p_rate );

  /* initilizations*/
  l_partial_start_flag     := FALSE;
  l_partial_end_flag       := FALSE;
  l_total_schedules        := g_norm_item_tbl.COUNT;
  l_start_fraction_amt     := 0;
  l_end_fraction_amt       := 0;
  l_partial_start_fraction := 0;
  l_partial_end_fraction   := 0;
  l_adjustment_amount      := 0;
  l_norm_months            := CEIL(MONTHS_BETWEEN(LAST_DAY(p_norm_end_dt),
                                                  PN_SCHEDULES_ITEMS.FIRST_DAY(p_norm_str_dt)));
  fnd_currency.get_info(p_curr_code, l_precision, l_ext_precision, l_min_acct_unit);

  FOR get_cash_rec IN get_cash_total LOOP
    l_cash_total := get_cash_rec.total_cash_amount;
  END LOOP;

  FOR get_norm_rec IN get_norm_total LOOP
    l_norm_apprv_total := get_norm_rec.total_norm_amount;
  END LOOP;

  /* Find which day of month the lease starts.*/
  l_day_of_norm_start_dt := TO_CHAR(p_norm_str_dt,'DD');

  /* Find which day of month the lease ends. */
  l_day_of_norm_end_dt := TO_CHAR(p_norm_end_dt,'DD');

  /* get the first norm schedule date */
  l_norm_start_sch_date := TO_DATE(
                           TO_CHAR(
                           p_sch_day)||'/'||TO_CHAR(p_norm_str_dt,'MM/YYYY'),'DD/MM/YYYY');

  /* get the last norm schedule date */
  l_norm_end_sch_date   := TO_DATE(
                           TO_CHAR(
                           p_sch_day)||'/'||TO_CHAR(p_norm_end_dt,'MM/YYYY'),'DD/MM/YYYY');

  /* partial start month */
  IF l_day_of_norm_start_dt <> '01' AND
     l_norm_start_sch_date = g_norm_item_tbl(0).schedule_date THEN

    l_partial_start_flag := TRUE;
    IF g_pr_rule = 999 THEN
       l_partial_start_fraction := ((LAST_DAY(p_norm_str_dt) - p_norm_str_dt)+1)/
                                   TO_NUMBER(TO_CHAR(LAST_DAY(p_norm_str_dt),'DD'));
    ELSE
       l_partial_start_fraction := ((LAST_DAY(p_norm_str_dt) - p_norm_str_dt)+1)*12/g_pr_rule;
    END IF;
    l_norm_months := (l_norm_months - 1) + NVL(l_partial_start_fraction,0);

  END IF;

  /* partial end month */
  IF l_day_of_norm_end_dt <> TO_CHAR(LAST_DAY(p_norm_end_dt),'DD') AND
     l_norm_end_sch_date = g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).schedule_date THEN

    l_partial_end_flag := TRUE;
    IF  g_pr_rule = 999 THEN
       l_partial_end_fraction := TO_NUMBER(TO_CHAR(p_norm_end_dt,'DD'))/
                                 TO_NUMBER(TO_CHAR(LAST_DAY(p_norm_end_dt),'DD'));
    ELSE
       l_partial_end_fraction := TO_NUMBER(TO_CHAR(p_norm_end_dt,'DD'))*12/g_pr_rule;
    END IF;
    l_norm_months := (l_norm_months - 1) + NVL(l_partial_end_fraction,0);

  END IF;

  /* calculate new normalized amount */
  IF l_norm_months <= 1 THEN
     l_new_normalized_amount := ROUND(l_cash_total - l_norm_apprv_total,
                                      l_precision);
     l_partial_start_flag := FALSE;
     l_partial_end_flag := FALSE;
  ELSE
     l_new_normalized_amount  := ROUND(l_cash_total/l_norm_months,
                                        l_precision);
  END IF;

  /*populate the pl/sql table */
  FOR i IN 0 .. g_norm_item_tbl.COUNT - 1 LOOP
       g_norm_item_tbl(i).normalized_amount := l_new_normalized_amount;
  END LOOP;

  IF g_norm_item_tbl.COUNT >= 1  THEN
    IF g_norm_item_tbl.COUNT > 1 THEN

      /* prorate - partial start */
      IF l_partial_start_flag THEN
        g_norm_item_tbl(0).normalized_amount
          := ROUND(l_new_normalized_amount * l_partial_start_fraction, l_precision);
      END IF;

      /* prorate - partial start */
      IF l_partial_end_flag THEN
        g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).normalized_amount
          := ROUND(l_new_normalized_amount * l_partial_end_fraction, l_precision);
      END IF;

    ELSIF g_norm_item_tbl.COUNT = 1 THEN

      /* prorate - partial start */
      IF l_partial_start_flag THEN
        l_start_fraction_amt
          := ROUND(l_new_normalized_amount * l_partial_start_fraction, l_precision);
      END IF;

      /* prorate - partial start */
      IF l_partial_end_flag THEN
        l_end_fraction_amt
          := ROUND(l_new_normalized_amount * l_partial_end_fraction, l_precision);
      END IF;

      IF l_partial_start_flag AND l_partial_end_flag THEN
        g_norm_item_tbl(0).normalized_amount := l_start_fraction_amt + l_end_fraction_amt - l_new_normalized_amount;
      ELSIF l_partial_start_flag THEN
        g_norm_item_tbl(0).normalized_amount := l_start_fraction_amt;
      ELSIF l_partial_end_flag THEN
        g_norm_item_tbl(0).normalized_amount := l_end_fraction_amt;
      ELSE
        g_norm_item_tbl(0).normalized_amount := l_new_normalized_amount;
      END IF;

    END IF; /* end for g_norm_item_tbl.COUNT > 1 */

  END IF;  /* end for g_norm_item_tbl.COUNT >= 1 */

  /* calculate adj amount to be added to first draft schedule */
  IF g_norm_item_tbl.COUNT > 2  THEN
    l_adjustment_amount := l_cash_total - ((l_new_normalized_amount * ((g_norm_item_tbl.COUNT)-2))
                                           + g_norm_item_tbl(0).normalized_amount
                                           + g_norm_item_tbl(g_norm_item_tbl.COUNT - 1).normalized_amount
                                           + l_norm_apprv_total
                                          );
  ELSIF g_norm_item_tbl.COUNT = 2 THEN
    l_adjustment_amount := l_cash_total - (g_norm_item_tbl(0).normalized_amount
                                           + g_norm_item_tbl(1).normalized_amount
                                           + l_norm_apprv_total
                                          );
  ELSIF g_norm_item_tbl.COUNT = 1 THEN
    l_adjustment_amount := l_cash_total - (g_norm_item_tbl(0).normalized_amount
                                           + l_norm_apprv_total
                                          );
  ELSIF g_norm_item_tbl.COUNT = 0 THEN
    l_adjustment_amount := l_cash_total - l_norm_apprv_total;
  END IF;

  /* Find date of last approved schedule, with default value set to the first schedule */
  l_last_apprv_sch_dt := l_norm_start_sch_date;

  /* Find first available draft schedule and get its ID */
  FOR sch_rec IN get_last_apprv_sch  LOOP
    l_last_apprv_sch_dt := sch_rec.last_apprv_sch;
  END LOOP;

  FOR sch_rec IN get_orig_sch_after (l_last_apprv_sch_dt) LOOP
     l_adjustment_sch_dt := sch_rec.first_draft_sch;
  END LOOP;

  IF l_adjustment_sch_dt IS NULL THEN
    FOR sch_rec IN get_first_draft_orig_sch LOOP
        l_adjustment_sch_dt := sch_rec.first_draft_sch;
    END LOOP;
  END IF;

  IF l_adjustment_sch_dt IS NULL THEN
    FOR sch_rec IN get_first_draft_sch LOOP
        l_adjustment_sch_dt                  := sch_rec.first_draft_sch;
        g_norm_item_tbl(0).schedule_date     := l_adjustment_sch_dt;
        g_norm_item_tbl(0).schedule_id       := sch_rec.pay_schd_id;
        g_norm_item_tbl(0).normalized_amount := 0;
    END LOOP;
  END IF;

  /* adjust the amount - if we find a draft schedule */
  IF l_adjustment_sch_dt IS NOT NULL THEN
    FOR i IN 0 .. g_norm_item_tbl.COUNT - 1 LOOP
      IF g_norm_item_tbl(i).schedule_date =  l_adjustment_sch_dt THEN
        g_norm_item_tbl(i).normalized_amount := g_norm_item_tbl(i).normalized_amount
                                                + l_adjustment_amount;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  /* start to create/update normalized items */
  FOR i IN 0 .. g_norm_item_tbl.COUNT - 1 LOOP

    /* first try to update */
    UPDATE pn_payment_items_all ppi
    SET    ppi.actual_amount = g_norm_item_tbl(i).normalized_amount,
           ppi.export_currency_amount = g_norm_item_tbl(i).normalized_amount,
           ppi.last_update_date = SYSDATE,
           ppi.last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
           ppi.last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
    WHERE  ppi.payment_schedule_id = g_norm_item_tbl(i).schedule_id
    AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
    AND    ppi.payment_term_id = p_term_id;

    IF NVL(SQL%ROWCOUNT, 0) = 0 THEN

      FOR rec IN org_cur LOOP
        l_org_id := rec.org_id;
      END LOOP;

      INSERT INTO pn_payment_items_all
        (payment_item_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         actual_amount,
         estimated_amount,
         due_date,
         payment_item_type_lookup_code,
         payment_term_id,
         payment_schedule_id,
         period_fraction,
         vendor_id,
         customer_id,
         vendor_site_id,
         customer_site_use_id,
         cust_ship_site_id,
         set_of_books_id,
         currency_code,
         export_currency_code,
         export_currency_amount,
         rate,
         org_id)
      VALUES
        (PN_PAYMENT_ITEMS_S.NEXTVAL,
         SYSDATE,
         NVL(fnd_profile.value('USER_ID'),0),
         SYSDATE,
         NVL(fnd_profile.value('USER_ID'),0),
         NVL(fnd_profile.value('LOGIN_ID'),0),
         g_norm_item_tbl(i).normalized_amount,
         NULL,
         g_norm_item_tbl(i).schedule_date,
         'NORMALIZED',
         p_term_id,
         g_norm_item_tbl(i).schedule_id,
         1,
         p_vendor_id,
         p_cust_id,
         p_vendor_site_id,
         p_cust_site_use_id,
         p_cust_ship_site_id,
         p_sob_id,
         p_curr_code,
         p_curr_code,
         g_norm_item_tbl(i).normalized_amount,
         p_rate,
         l_org_id
         );
    END IF;


    /*S.N. Bug 4956314 */

    l_cash_item:=0;

    FOR t_rec IN check_cash_item(g_norm_item_tbl(i).schedule_id,p_term_id)
    LOOP
        l_cash_item:=1;
    END LOOP;

    IF l_cash_item = 0 THEN
       pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_ACROSS_ALL_DRAFT -> create $ 0 cash items(+)');
       pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_ACROSS_ALL_DRAFT -> for schedule id : '||g_norm_item_tbl(i).schedule_id);
       pn_schedules_items.create_cash_items
                          (p_est_amt           => 0,
                           p_act_amt           => 0,
                           p_sch_dt            => g_norm_item_tbl(i).schedule_date,
                           p_sch_id            => g_norm_item_tbl(i).schedule_id,
                           p_term_id           => p_term_id,
                           p_vendor_id         => p_vendor_id,
                           p_cust_id           => p_cust_id,
                           p_vendor_site_id    => p_vendor_site_id,
                           p_cust_site_use_id  => p_cust_site_use_id,
                           p_cust_ship_site_id => p_cust_ship_site_id,
                           p_sob_id            => p_sob_id,
                           p_curr_code         => p_curr_code,
                           p_rate              => p_rate);
      pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_ACROSS_ALL_DRAFT -> $ 0 cash item created(-) ');
    END IF;

   /*E.N. Bug 4956314 */

  END LOOP;

  /* update the table */
  UPDATE pn_payment_terms_all
  SET    event_type_code = p_lease_context,
         norm_start_date = p_norm_str_dt,
         norm_end_date   = p_norm_end_dt
  WHERE  normalize ='Y'
  AND    payment_term_id = p_term_id;

  pnp_debug_pkg.log('  PN_NORM_RENORM_PKG.RENORMALIZE_IN_FIRST_DRAFT (-) ');
EXCEPTION
  WHEN OTHERS THEN
    pnp_debug_pkg.log('  RENORMALIZE_IN_FIRST_DRAFT - OTHERS ERROR ... ' || sqlerrm);

END RENORMALIZE_IN_FIRST_DRAFT;

/*------------------------------------------------------------------------------
NAME         : NORMALIZE_RENORMALIZE
DESCRIPTION  : This is the main procedure for this package. This will handle the
               normalization/renormalization. Depending on the profile option
               the appropriate sub procedure is called.
HISTORY      :
20-OCT-04 atuppad  o Created
23-NOV-05 pikhar   o Passed org_id in pn_mo_cache_utils.get_profile_value
20-JAN-05 hkulkarn o Bug4956314 : Using Outer Join. Here DRAFT schedules were not
                                  picked up because there didn't exist any Items.
                                  Also creating $ 0 'CASH' Items, while  creating/adjusting,
                                  NORMALized items for New adjustmetn schedule, if 'CASH'
                                  items doesn't exists for this schedule initially.
24-AUG-08 rkartha o Bug#6829173 : Added code for handling the case where the term
                                  completely falls outside the new lease duration
                                  when early terminating.
------------------------------------------------------------------------------*/
PROCEDURE NORMALIZE_RENORMALIZE
          (p_lease_context      IN  VARCHAR2,
           p_lease_id           IN  NUMBER,
           p_term_id            IN  NUMBER,
           p_vendor_id          IN  NUMBER,
           p_cust_id            IN  NUMBER,
           p_vendor_site_id     IN  NUMBER,
           p_cust_site_use_id   IN  NUMBER,
           p_cust_ship_site_id  IN  NUMBER,
           p_sob_id             IN  NUMBER,
           p_curr_code          IN  VARCHAR2,
           p_sch_day            IN  NUMBER,
           p_norm_str_dt        IN  DATE,
           p_norm_end_dt        IN  DATE,
           p_rate               IN  NUMBER,
           p_lease_change_id    IN  NUMBER)
IS

l_amd_comn_date       DATE; /* 6838211 */
  /* get the details of draft schedules between norm start and end dates*/
  -- Bug#6829173
  CURSOR GET_TERM_SCHEDULES(c_norm_str_dt pn_payment_terms_all.norm_start_date%TYPE) IS
    SELECT pps.schedule_date schedule_date,
           pps.payment_schedule_id payment_schedule_id
    FROM   pn_payment_schedules_all pps,
           pn_payment_items_all ppi
    WHERE  pps.lease_id = p_lease_id
    AND    pps.schedule_date BETWEEN
	NVL(l_amd_comn_date,PN_SCHEDULES_ITEMS.FIRST_DAY(c_norm_str_dt)) /*6838211 */
                                 AND LAST_DAY(g_new_lea_term_dt) --AND LAST_DAY(p_norm_end_dt) /*Bug4956314*/
    AND    pps.payment_status_lookup_code = 'DRAFT' /* bug 6737971 removed
ON_HOLD */
    AND    TO_CHAR(pps.schedule_date,'DD') = p_sch_day
    AND    ppi.PAYMENT_SCHEDULE_ID(+) = pps.PAYMENT_SCHEDULE_ID /*Bug4956314*/
    AND    ppi.PAYMENT_TERM_ID(+) = p_term_id                   /*Bug4956314*/
    AND    ppi.PAYMENT_ITEM_TYPE_LOOKUP_CODE(+) = 'CASH'        /*Bug4956314*/
    AND    ppi.LAST_ADJUSTMENT_TYPE_CODE IS NULL
    ORDER BY pps.schedule_date;

  CURSOR GET_LEASE_DETAILS IS
    SELECT pld.lease_commencement_date lease_commencement_date,
              pld.lease_termination_date new_lease_term_date,
           pl.payment_term_proration_rule pr_rule
    FROM   pn_leases_all pl,
           pn_lease_details_all pld
    WHERE  pl.lease_id = p_lease_id
    AND    pld.lease_id = pl.lease_id;

  l_counter          NUMBER;
  l_system_options   VARCHAR2(5);

  CURSOR org_cur IS
    SELECT org_id
    FROM pn_payment_terms_all
    WHERE payment_term_id = p_term_id;

  l_org_id NUMBER;

  -- Bug#6829173
  l_lease_comm_date     pn_lease_details_all.lease_commencement_date%TYPE;
  l_norm_str_dt         pn_payment_terms_all.norm_start_date%TYPE;


BEGIN
  pnp_debug_pkg.log('PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE (+) ');
 select change_commencement_date
 	    INTO l_amd_comn_date
 	    from pn_lease_changes_all
 	    where lease_id =  p_lease_id
 	    and lease_change_id = (
 	    select lease_change_id from pn_lease_details_all
 	    where lease_id =  p_lease_id);   /*  6838211 */


 	    IF l_amd_comn_date > p_norm_str_dt THEN     /* 6838211 */
 	       l_amd_comn_date := p_norm_str_dt;
 	    END IF;
  FOR rec IN org_cur LOOP
    l_org_id := rec.org_id;
  END LOOP;

  /* initialize variables */
  l_system_options := NVL(PN_MO_CACHE_UTILS.get_profile_value ('PN_RENORM_ACC_ALL_DRAFT_SCH',l_org_id),'Y');
  l_counter := 0;
  g_norm_item_tbl.DELETE;
  g_new_lea_term_dt := NULL;
  g_pr_rule := NULL;

/*S.N. Bug4956314*/
 /* get the lease detail values */
  FOR lease_details_rec IN get_lease_details LOOP
     -- Bug 6508394
     l_lease_comm_date := lease_details_rec.lease_commencement_date;

     g_new_lea_term_dt := lease_details_rec.new_lease_term_date;
     g_pr_rule         := lease_details_rec.pr_rule;
  END LOOP;
/*E.N. Bug4956314*/

     -- Bug 6829173
      l_norm_str_dt := NVL(l_amd_comn_date,p_norm_str_dt);  /* 6838211 */
     -- Early termination (Term falls outside the new lease duration)
     IF p_norm_str_dt > NVL(p_norm_end_dt, g_new_lea_term_dt) THEN
      l_norm_str_dt := NVL(l_amd_comn_date,l_lease_comm_date);  /* 6838211 */
     END IF;

     -- Bug 6829173
  FOR sch_rec IN get_term_schedules(l_norm_str_dt) LOOP
    g_norm_item_tbl(l_counter).schedule_date := sch_rec.schedule_date;
    g_norm_item_tbl(l_counter).schedule_id   := sch_rec.payment_schedule_id;
    l_counter := l_counter + 1;
  END LOOP;
pnp_debug_pkg.log('  N-RN COUNTER' || l_counter);
  /* donot renormalize if no original draft schedule is not found */
  IF (NVL(g_norm_item_tbl.COUNT, 0) <> 0) OR (l_system_options  = 'N') THEN

    /* call appropriate sub procedure depending upon the system option */
    IF l_system_options  = 'Y' THEN
       RENORMALIZE_ACROSS_ALL_DRAFT
          (p_lease_context      => p_lease_context,
           p_lease_id           => p_lease_id,
           p_term_id            => p_term_id,
           p_vendor_id          => p_vendor_id,
           p_cust_id            => p_cust_id,
           p_vendor_site_id     => p_vendor_site_id,
           p_cust_site_use_id   => p_cust_site_use_id,
           p_cust_ship_site_id  => p_cust_ship_site_id,
           p_sob_id             => p_sob_id,
           p_curr_code          => p_curr_code,
           p_sch_day            => p_sch_day,
           p_norm_str_dt        => p_norm_str_dt,
           p_norm_end_dt        => g_new_lea_term_dt,
           p_rate               => p_rate);

    ELSIF l_system_options = 'N' THEN
       RENORMALIZE_IN_FIRST_DRAFT
          (p_lease_context      => p_lease_context,
           p_lease_id           => p_lease_id,
           p_term_id            => p_term_id,
           p_vendor_id          => p_vendor_id,
           p_cust_id            => p_cust_id,
           p_vendor_site_id     => p_vendor_site_id,
           p_cust_site_use_id   => p_cust_site_use_id,
           p_cust_ship_site_id  => p_cust_ship_site_id,
           p_sob_id             => p_sob_id,
           p_curr_code          => p_curr_code,
           p_sch_day            => p_sch_day,
           p_norm_str_dt        => p_norm_str_dt,
           p_norm_end_dt        => g_new_lea_term_dt,
           p_rate               => p_rate);

    END IF;

  END IF;

  pnp_debug_pkg.log('PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE (-) ');
EXCEPTION
  WHEN OTHERS THEN
    pnp_debug_pkg.log('  NORMALIZE_RENORMALIZE - OTHERS ERROR ... ' || sqlerrm);

END NORMALIZE_RENORMALIZE;


END PN_NORM_RENORM_PKG;

/
