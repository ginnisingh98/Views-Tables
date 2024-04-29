--------------------------------------------------------
--  DDL for Package Body PN_APPROVE_VARENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_APPROVE_VARENT_PKG" AS
-- $Header: PNVRAPPB.pls 120.16.12010000.5 2009/01/21 10:23:29 jsundara ship $

--------------------------------------------------------------------------------
-- PROCEDURE : approve_payment_term
-- DESCRIPTION: This procedure is called by the variable rent payment term
--              approval concurrent program.
-- HISTORY:
-- 21-Feb-02 PSidhu   o Added check to approve payment terms only if
--                      main lease is in final status.Fix for bug# 2223128.
-- 28-Jun-02 Pidhu    o Added p_org_id parameter to procedure
--                      approve_payment_term_batch.
-- 15-Aug-02 DThota   o Added p_period_date parameter to procedure
--                      approve_payment_term_batch, CURSOR csr_get_inv for
--                      Mass Calculate Variable Rent
-- 09-Jan-03 DThota   o Changed p_period_date to VARCHAR2 from DATE in
--                      approve_payment_term_batch and put in
--                      fnd_date.canonical_to_date before p_period_date in
--                      the WHERE clause of CURSOR csr_get_inv. Bug#2733870
-- 14-JUL-05 HRodda   o Bug 4284035 - Replaced pn_leases with _ALL table.
-- 26-Oct-06 Shabda   o Modified cursor csr_get_inv to accomodate true_up invoices
-- 27-Oct-06 Shabda   o Modified cursor csr_get_inv to accomodate adjustment terms
--                      for variance, which may not have corresponding forecasted
--                      terms
-- 10-Apr-07 Lbala    o Removed call to pn_variable_amount_pkg.get_prior_transfer_flag
--                       for bug # 5965171
-- 31-MAy-07 Lokesh   o Bug # 6079479 Changed Cursor csr_get_inv

--------------------------------------------------------------------------------

PROCEDURE approve_payment_term_batch
(
  errbuf                OUT NOCOPY  VARCHAR2,
  retcode               OUT NOCOPY  VARCHAR2,
  p_lease_num_from      IN  VARCHAR2,
  p_lease_num_to        IN  VARCHAR2,
  p_location_code_from  IN  VARCHAR2,
  p_location_code_to    IN  VARCHAR2,
  p_vrent_num_from      IN  VARCHAR2,
  p_vrent_num_to        IN  VARCHAR2,
  p_period_num_from     IN  NUMBER,
  p_period_num_to       IN  NUMBER,
  p_responsible_user    IN  NUMBER,
  p_var_rent_inv_id     IN  NUMBER,
  p_var_rent_type       IN  VARCHAR2,
  p_var_rent_id         IN  NUMBER,
  p_org_id              IN  NUMBER,
  p_period_date         IN  VARCHAR2

) IS
CURSOR csr_get_vrent_wloc IS
SELECT pvr.var_rent_id,
       pvr.rent_num,
       pvr.invoice_on,
       pl.status
FROM   pn_leases             pl,
       pn_lease_details_all  pld,
       pn_var_rents_all      pvr,
       pn_locations_all      ploc
WHERE  pl.lease_id = pvr.lease_id
AND    pld.lease_id = pvr.lease_id
AND    ploc.location_id = pvr.location_id
AND    pl.lease_num >= NVL(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= NVL(p_lease_num_to, pl.lease_num)
AND    ploc.location_code >= NVL(p_location_code_from, ploc.location_code)
AND    ploc.location_code <= NVL(p_location_code_to, ploc.location_code)
AND    pvr.rent_num >= NVL(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= NVL(p_vrent_num_to,pvr.rent_num)
AND    pld.responsible_user = NVL(p_responsible_user, pld.responsible_user)
AND   (pl.org_id = p_org_id or p_org_id is null)
ORDER BY pl.lease_id, pvr.var_rent_id;

CURSOR csr_get_vrent_woloc IS
SELECT pvr.var_rent_id,
       pvr.rent_num,
       pvr.invoice_on,
       pl.status
FROM   pn_leases             pl,
       pn_var_rents_all      pvr,
       pn_lease_details_all  pld
WHERE  pl.lease_id = pvr.lease_id
AND    pld.lease_id = pvr.lease_id
AND    pl.lease_num >= NVL(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= NVL(p_lease_num_to, pl.lease_num)
AND    pvr.rent_num >= NVL(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= NVL(p_vrent_num_to,pvr.rent_num)
AND    pld.responsible_user = NVL(p_responsible_user, pld.responsible_user)
AND    pvr.var_rent_id = NVL(p_var_rent_id,pvr.var_rent_id)
AND    (pl.org_id = p_org_id or p_org_id is null)
ORDER BY pl.lease_id,pvr.var_rent_id;

CURSOR csr_get_inv(ip_var_rent_id NUMBER,
                   ip_rent_type VARCHAR2,
                   ip_var_rent_type VARCHAR2) IS
SELECT * FROM
(SELECT per.period_num,
       inv.var_rent_inv_id,
       inv.adjust_num,
       inv.period_id,
       inv.var_rent_id,
       inv.invoice_date,
       inv.for_per_rent,
       inv.actual_invoiced_amount,
       decode(ip_rent_type,'FORECASTED',inv.forecasted_term_status,'ACTUAL',inv.actual_term_status,
                           'VARIANCE',inv.variance_term_status) term_status
FROM   pn_var_rent_inv_all inv,
       pn_var_periods_all per
WHERE  per.var_rent_id = inv.var_rent_id
AND per.period_id = inv.period_id
AND inv.var_rent_id = ip_var_rent_id
AND per.period_num >= NVL(p_period_num_from,per.period_num)
AND per.period_num <= NVL(p_period_num_to,period_num)
AND (inv.forecasted_exp_code = decode(inv.adjust_num
                                       ,0,decode(ip_rent_type,'FORECASTED','N','VARIANCE','Y',inv.forecasted_exp_code)
                                      ,inv.forecasted_exp_code)
     OR inv.true_up_exp_code = 'N')
AND inv.actual_exp_code = decode(ip_rent_type,'ACTUAL','N',inv.actual_exp_code)
AND inv.variance_exp_code = decode(ip_rent_type,'VARIANCE','N',inv.variance_exp_code)
AND inv.var_rent_inv_id = NVL(p_var_rent_inv_id,inv.var_rent_inv_id)
AND ip_rent_type = NVL(ip_var_rent_type,ip_rent_type)
AND invoice_date <= NVL(fnd_date.canonical_to_date(p_period_date),TO_DATE('12/31/4712','mm/dd/yyyy'))
UNION
SELECT per.period_num,
       inv.var_rent_inv_id,
       inv.adjust_num,
       inv.period_id,
       inv.var_rent_id,
       inv.invoice_date,
       inv.for_per_rent,
       inv.actual_invoiced_amount,
       decode(ip_rent_type,'FORECASTED',inv.forecasted_term_status,'ACTUAL',inv.actual_term_status,
                           'VARIANCE',inv.variance_term_status) term_status
FROM   pn_var_rent_inv_all inv,
       pn_var_periods_all per,
       pn_payment_terms_all pmt
WHERE per.var_rent_id = inv.var_rent_id
AND per.period_id = inv.period_id
AND inv.var_rent_id = ip_var_rent_id
AND per.period_num >= NVL(p_period_num_from,per.period_num)
AND per.period_num <= NVL(p_period_num_to,period_num)
AND (inv.forecasted_exp_code = decode(inv.adjust_num
                                       ,0,decode(ip_rent_type,'FORECASTED','N','VARIANCE','Y',inv.forecasted_exp_code)
                                      ,inv.forecasted_exp_code)
     OR inv.true_up_exp_code = 'N')
AND inv.actual_exp_code = decode(ip_rent_type,'ACTUAL','N',inv.actual_exp_code)
AND inv.variance_exp_code = decode(ip_rent_type,'VARIANCE','N',inv.variance_exp_code)
AND pmt.var_rent_inv_id = inv.var_rent_inv_id
AND pmt.status = 'APPROVED'
AND ip_rent_type = NVL(ip_var_rent_type,ip_rent_type)
AND invoice_date <= NVL(fnd_date.canonical_to_date(p_period_date),TO_DATE('12/31/4712','mm/dd/yyyy'))
)temp
ORDER BY period_num,invoice_date;


l_var_rent_id     pn_var_rents.var_rent_id%type;
l_rent_num        pn_var_rents.rent_num%type;
l_invoice_on      pn_var_rents.invoice_on%type;
l_lease_status    pn_leases.status%type;
l_rent_type       pn_payment_terms.var_rent_type%type;
l_rent_amt        NUMBER;
l_exists          VARCHAR2(1) := 'N';
l_errmsg          VARCHAR2(2000);
l_errmsg1         VARCHAR2(2000);
l_counter         NUMBER := 0;
l_context         VARCHAR2(2000);
l_var_rent_type   VARCHAR2(30);
l_inv_sch_date    DATE;
l_inv_start_date  DATE;


BEGIN


pn_variable_amount_pkg.put_log('pn_approve_varent_pkg.approve_payment_term (+)' );

fnd_message.set_name ('PN','PN_VRAP_PRM');
fnd_message.set_token ('LSNO_FRM',p_lease_num_from);
fnd_message.set_token ('LSNO_TO',p_lease_num_to);
fnd_message.set_token ('LOC_CODE_FRM',p_location_code_from);
fnd_message.set_token ('LOC_CODE_TO',p_location_code_to);
fnd_message.set_token ('VR_FRM',p_vrent_num_from);
fnd_message.set_token ('VR_TO',p_vrent_num_to);
fnd_message.set_token ('PRD_FRM',p_period_num_from);
fnd_message.set_token ('PRD_TO',p_period_num_to);
fnd_message.set_token ('RESP_USR',p_responsible_user);
pnp_debug_pkg.put_log_msg(fnd_message.get);


/*  Checking Location Code From, Location Code To to open appropriate cursor */

IF p_location_code_from IS NOT NULL or p_location_code_to IS NOT NULL THEN
  OPEN csr_get_vrent_wloc;
ELSE
  OPEN csr_get_vrent_woloc;
END IF;

LOOP
  IF csr_get_vrent_wloc%ISOPEN THEN
    FETCH csr_get_vrent_wloc
    INTO  l_var_rent_id
         ,l_rent_num
         ,l_invoice_on
         ,l_lease_status;
    EXIT WHEN csr_get_vrent_wloc%NOTFOUND;
  ELSIF csr_get_vrent_woloc%ISOPEN THEN
    FETCH csr_get_vrent_woloc
    INTO  l_var_rent_id
         ,l_rent_num
         ,l_invoice_on
         ,l_lease_status;
    EXIT WHEN csr_get_vrent_woloc%NOTFOUND;
  END IF;



  fnd_message.set_name ('PN','PN_LEASE_STATUS');
  fnd_message.set_token ('STATUS',l_lease_status);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_SOI_VRN');
  fnd_message.set_token ('NUM',l_rent_num);
  pnp_debug_pkg.put_log_msg(fnd_message.get);


  IF NVL(l_lease_status,'D') = 'D' THEN

    /* If main lease is in draft status do not approve any payment term */
    fnd_message.set_name('PN','PN_NO_APPR_TERM');
    l_errmsg1 := fnd_message.get;
    pn_variable_amount_pkg.put_output
      ('+----------------------------------------------------------+');
    pn_variable_amount_pkg.put_output(l_errmsg1);
    pn_variable_amount_pkg.put_output
      ('+----------------------------------------------------------+');



  ELSE

    IF l_invoice_on = 'FORECASTED' THEN
      l_rent_type := 'VARIANCE';
    ELSIF l_invoice_on = 'ACTUAL' THEN
      l_rent_type := 'ACTUAL';
    END IF;

    IF  p_var_rent_type = 'ADJUSTMENT' THEN
      IF l_invoice_on = 'FORECASTED' THEN
        l_var_rent_type := 'VARIANCE';
      ELSIF l_invoice_on = 'ACTUAL' THEN
        l_var_rent_type := 'ACTUAL';
      END IF;
    ELSE
      l_var_rent_type := p_var_rent_type;
    END IF;

    IF l_invoice_on = 'FORECASTED' THEN

      pn_variable_amount_pkg.put_output
          ('+-----------------------------------------------------------+');
      fnd_message.set_name ('PN','PN_VTERM_FORC_TRM');
      pnp_debug_pkg.put_log_msg(fnd_message.get||' ...');

      --l_var_rent_type := 'FORECASTED';

      FOR rec_get_inv in csr_get_inv (l_var_rent_id,'FORECASTED','FORECASTED')
      LOOP

        fnd_message.set_name ('PN','PN_VTERM_PRD_NUM');
        fnd_message.set_token ('NUM',rec_get_inv.period_num);
        pnp_debug_pkg.put_log_msg(fnd_message.get);


        /*l_inv_start_date := pn_var_rent_calc_pkg.inv_start_date(inv_start_date => rec_get_inv.invoice_date
                                                                  ,vr_id => l_var_rent_id
                                                                  ,approved_status => 'N');  */

        l_inv_sch_date := pn_var_rent_calc_pkg.inv_sch_date(inv_start_date => rec_get_inv.invoice_date
                                                                  ,vr_id => l_var_rent_id
                                                                  ,p_period_id => rec_get_inv.period_id );
        fnd_message.set_name ('PN','PN_SOI_INV_DT');
        fnd_message.set_token ('DATE',l_inv_sch_date);
        pnp_debug_pkg.put_log_msg(fnd_message.get);


       IF rec_get_inv.term_status = 'Y' OR
              NVL(rec_get_inv.for_per_rent,-1)= 0 THEN

          set_transferred_code
            ( p_var_rent_inv_id => rec_get_inv.var_rent_inv_id
             ,p_rent_type       => 'FORECASTED'
             ,p_term_status     => rec_get_inv.term_status
             ,p_rent_amt        => rec_get_inv.for_per_rent
             ,p_period_id       => rec_get_inv.period_id
             ,p_var_rent_id     => rec_get_inv.var_rent_id
             ,p_invoice_date    => rec_get_inv.invoice_date
             ,p_counter         => l_counter);


        END IF;  --NVL(l_exists,'N') = 'Y'

      END LOOP;

      fnd_message.set_name ('PN','PN_VTERM_AFORC_TRM');
      fnd_message.set_token ('DATE',l_counter);
      pnp_debug_pkg.put_log_msg(fnd_message.get);


    END IF;  --l_invoice_on = 'FORECASTED'

    l_counter := 0;
    pn_variable_amount_pkg.put_log
      ('+-----------------------------------------------------------+');
    pn_variable_amount_pkg.put_log
      ('Processing '||INITCAP(l_rent_type)||' terms.... ');


    FOR rec_get_inv in csr_get_inv(l_var_rent_id,l_rent_type, l_var_rent_type)
    LOOP

      fnd_message.set_name ('PN','PN_VTERM_PRD_NUM');
      fnd_message.set_token ('NUM',rec_get_inv.period_num);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      /*l_inv_start_date := pn_var_rent_calc_pkg.inv_start_date(inv_start_date => rec_get_inv.invoice_date
                                                                  ,vr_id => l_var_rent_id
                                                                  ,approved_status => 'N'); */

      l_inv_sch_date := pn_var_rent_calc_pkg.inv_sch_date(inv_start_date => rec_get_inv.invoice_date
                                                                  ,vr_id => l_var_rent_id
                                                                  ,p_period_id => rec_get_inv.period_id );
      fnd_message.set_name ('PN','PN_SOI_INV_DT');
      fnd_message.set_token ('DATE',l_inv_sch_date);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      l_rent_amt := NULL;

      IF l_rent_type ='VARIANCE' and rec_get_inv.adjust_num = 0 THEN
        l_rent_amt
          := rec_get_inv.actual_invoiced_amount - rec_get_inv.for_per_rent;
      ELSE
        l_rent_amt := rec_get_inv.actual_invoiced_amount;
      END IF;

      IF rec_get_inv.term_status = 'Y' or NVL(l_rent_amt,-1) = 0 THEN

        set_transferred_code
          ( p_var_rent_inv_id => rec_get_inv.var_rent_inv_id
           ,p_rent_type       => l_rent_type
           ,p_term_status     => rec_get_inv.term_status
           ,p_rent_amt        => l_rent_amt
           ,p_period_id       => rec_get_inv.period_id
           ,p_var_rent_id     => rec_get_inv.var_rent_id
           ,p_invoice_date    => rec_get_inv.invoice_date
           ,p_counter         => l_counter);

      END IF;   --NVL(l_exists,'N') = 'Y'

    END LOOP;

    fnd_message.set_name ('PN','PN_VRAP_PROC');
    fnd_message.set_token ('STATUS',INITCAP(l_rent_type));
    fnd_message.set_token ('NUM',l_counter);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

  END IF;  --NVL(l_lease_status,'DRAFT') = 'DRAFT'

END LOOP;

pn_variable_amount_pkg.put_log('pn_approve_varent_pkg.approve_payment_term  (-) : ');

EXCEPTION

  WHEN OTHERS THEN
    pn_variable_amount_pkg.put_log
      (SUBSTRB('Error in pn_approve_varent_pkg.approved_payment_term_batch : '||
                TO_CHAR(sqlcode)||
                ' - '||
                sqlerrm ||
                ' : '||
                l_context,1,244));
    Errbuf  := SQLERRM;
    Retcode := 2;
    ROLLBACK;
    RAISE;

END approve_payment_term_batch;

--------------------------------------------------------------------------------
-- PROCEDURE :  set_transferred_code
-- DESCRIPTION: This procedure sets the exported codes in pn_var_grp_dates and
--              pn_var_vol_hist to 'Y' and exported code in pn_var_deductions
--              to 'Y' if variable rent term type is  'ACTUAL' or 'VARIANCE'.
--              Also creates schedules and items if a terms exists for the
--              variable rent amount.
-- 21-Feb-02 Psidhu  o Added call to pnt_payment_terms_pkg.
--                     check_approved_schedule_exists. Approve a payment
--                     term if period of payment term does not overlap
--                     with an existing approved schedule. Bug # 2235148.
-- 22-NOV-04 Kiran   o Bug 3751438 - rewrote to ensure the term details and
--                     distributions are validated.
-- 23-NOV-05 pikhar  o Passed org_id in pn_mo_cache_utils.get_profile_value
-- 09-JAN-07 lbala   o Removed call to check_approved_schedule_exists for
--                     M28 item# 11
-- 12-Mar-07 Shabda  o 5911819 - Modified vol_hist_all update stamements.
-- 30-NOV-07 rkartha o Bug#7652214 Correcting the forward port of Bug#6412170.
--                     Added parameters customer_id and CUSTOMER_SITE_USE_ID to
--                     cursor csr_get_term and E_NO_CUST EXCEPTION to check if
--                     the term has customer info and bill-to-site.
--                     If the terms doesnt have, then it cant be approved.
--------------------------------------------------------------------------------
PROCEDURE set_transferred_code
(
  p_var_rent_inv_id NUMBER,
  p_rent_type VARCHAR2,
  p_term_status VARCHAR2,
  p_rent_amt NUMBER,
  p_period_id NUMBER,
  p_var_rent_id NUMBER,
  p_invoice_date DATE,
  p_counter IN OUT NOCOPY NUMBER
) IS

/* -- CURSORS -- */

/* get all the term info */
CURSOR csr_get_term(ip_var_rent_inv_id NUMBER,
                    ip_rent_type VARCHAR2) IS
  SELECT  payment_term_id
         ,lease_id
         ,actual_amount
         ,schedule_day
         ,start_date
         ,end_date
         ,normalize
         ,project_id
         ,task_id
         ,organization_id
         ,expenditure_type
         ,expenditure_item_date
         ,distribution_set_id
         ,org_id
         ,customer_id
         ,CUSTOMER_SITE_USE_ID
  FROM   pn_payment_terms_all
  WHERE  var_rent_inv_id = ip_var_rent_inv_id
  /*AND    var_rent_type = ip_rent_type*/;

/* get the distributions for a term */
CURSOR get_distributions_c (p_term_ID IN NUMBER) IS
  SELECT pd.account_class
        ,pd.percentage
    FROM pn_distributions_all pd
   WHERE pd.payment_term_ID = p_term_ID;

/* get the account class meaning from lookups */
CURSOR get_acc_class_c (p_acc_class_code IN VARCHAR2) is
  SELECT meaning
    FROM fnd_lookups
   WHERE lookup_code = p_acc_class_code
     AND lookup_type in ('PN_PAY_ACCOUNT_TYPE','PN_REC_ACCOUNT_TYPE');

/* get lease class code */
CURSOR get_lease_class(p_lease_ID IN NUMBER) IS
  SELECT lease_class_code
    FROM pn_leases_all
   WHERE lease_ID = p_lease_ID;


-- Get the details of
CURSOR period_FY_cur(p_period_id NUMBER,
                     p_var_rent_id NUMBER) IS
  SELECT period_id
    FROM pn_var_periods_all pvp, pn_var_rents_all pvr
   WHERE pvr.var_rent_id = pvp.var_rent_id
     AND pvp.period_id = p_period_id
     AND pvr.var_rent_id = p_var_rent_id
     AND pvr.proration_rule IN ('FLY', 'FY')
     AND pvp.period_num = 1;


l_payment_term_id       pn_payment_terms.payment_term_id%TYPE           := NULL;
l_lease_id              pn_payment_terms.lease_id%TYPE                  := NULL;
l_actual_amt            pn_payment_terms.actual_amount%TYPE             := NULL;
l_schedule_day          pn_payment_terms.schedule_day%TYPE              := NULL;
l_start_date            pn_payment_terms.start_date%TYPE                := NULL;
l_end_date              pn_payment_terms.end_date%TYPE                  := NULL;
l_normalize             pn_payment_terms_all.normalize%TYPE             := NULL;
l_project_id            pn_payment_terms_all.project_id%TYPE            := NULL;
l_task_id               pn_payment_terms_all.task_id%TYPE               := NULL;
l_organization_id       pn_payment_terms_all.organization_id%TYPE       := NULL;
l_expenditure_type      pn_payment_terms_all.expenditure_type%TYPE      := NULL;
l_expenditure_item_date pn_payment_terms_all.expenditure_item_date%TYPE := NULL;
l_distribution_set_id   pn_payment_terms_all.distribution_set_id%TYPE   := NULL;
l_org_id                pn_payment_terms_all.org_id%TYPE;
l_cust_id               pn_payment_terms_all.customer_id%type;
l_cust_site_id          pn_payment_terms_all.CUSTOMER_SITE_USE_ID%type;
l_errmsg1               VARCHAR2(2000);


E_NO_CUST EXCEPTION;  /*Exception added for bug#6412170 */


l_return_status VARCHAR2 (2)   := NULL;
l_errbuf        VARCHAR2(2000) := NULL;
l_retcode       VARCHAR2(2000) := NULL;
l_errmsg        VARCHAR2(2000) := NULL;
l_error         BOOLEAN;

/* -- variables for validating the term distributions -- */

/* accounting option */
l_acc_optn VARCHAR2(30);
/* account flags to indicate existance of accounts */
l_exp_rev_exists    BOOLEAN;
l_lia_rec_exists    BOOLEAN;
l_acc_unearn_exists BOOLEAN;
/* account percent allocations */
l_exp_rev_dist_pct    NUMBER;
l_lia_rec_dist_pct    NUMBER;
l_acc_unearn_dist_pct NUMBER;
/* account class count */
l_rec_count      NUMBER;
l_lia_count      NUMBER;
l_acc_count      NUMBER;
l_unearn_count   NUMBER;
l_acc_class      VARCHAR2(90);
l_acc_class_code VARCHAR2(30);
/* total number of dist */
l_dist_count NUMBER;

/* exception */
TERM_DIST_INVALID EXCEPTION;

l_lease_class_code VARCHAR2(30);

/* -- variables to verify project info -- */
l_status              VARCHAR2(2000);
l_bill_flag           VARCHAR2(10);
l_msg_app             VARCHAR2(30);
l_msg_type            VARCHAR2(30);
l_msg_token1          VARCHAR2(30);
l_msg_token2          VARCHAR2(30);
l_msg_token3          VARCHAR2(30);
l_msg_count           NUMBER;

/* -- variables for validating the term distributions -- */

BEGIN

pnp_debug_pkg.log('p_rent_type:'||p_rent_type);
pn_variable_amount_pkg.put_log('pn_approve_varent_pkg.set_transferred_code  (+) : ');

l_error := FALSE;

IF p_term_status = 'Y' THEN

  FOR rec IN csr_get_term(p_var_rent_inv_id,p_rent_type) LOOP

    l_payment_term_id := rec.payment_term_id;
    l_lease_id        := rec.lease_id;
    l_actual_amt      := rec.actual_amount;
    l_schedule_day    := rec.schedule_day;
    l_start_date      := rec.start_date;
    l_end_date        := rec.end_date;
    l_normalize       := rec.normalize;
    l_project_id      := rec.project_id;
    l_task_id         := rec.task_id;
    l_organization_id := rec.organization_id;
    l_expenditure_type := rec.expenditure_type;
    l_expenditure_item_date :=  rec.expenditure_item_date;
    l_distribution_set_id := rec.distribution_set_id;
    l_org_id := rec.org_id;
    l_cust_id := rec.customer_id;
    l_cust_site_id  := rec.CUSTOMER_SITE_USE_ID;


    fnd_message.set_name ('PN','PN_VRAP_VAL');
    fnd_message.set_token ('DATE',l_start_date);
    fnd_message.set_token ('DAY',l_schedule_day);
    fnd_message.set_token ('AMT',l_actual_amt);
    fnd_message.set_token ('ID',l_payment_term_id);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    /* check if term distributions are correct */
    /* check if an approved schedule exists overlapping the period of the term */
    BEGIN

      /* init variables */
      /* init the exists flags and counters */
      l_acc_optn := NVL( pn_mo_cache_utils.get_profile_value
                                    ('PN_ACCOUNTING_OPTION',l_org_id),'Y');

      l_exp_rev_exists    := FALSE;
      l_lia_rec_exists    := FALSE;
      l_acc_unearn_exists := FALSE;

      l_exp_rev_dist_pct := 0;
      l_lia_rec_dist_pct := 0;
      l_acc_unearn_dist_pct := 0;

      l_rec_count    := 0;
      l_lia_count    := 0;
      l_acc_count    := 0;
      l_unearn_count := 0;
      l_acc_class    := NULL;

      l_dist_count := 0;


      FOR lease_rec IN get_lease_class(l_lease_id) LOOP
        l_lease_class_code := lease_rec.lease_class_code;
      END LOOP;


     IF l_lease_class_code not in ('DIRECT') THEN
     /* If Customer info is not present, do not approve the terms   bug#6412170*/
     IF (l_cust_id  is null) THEN
      fnd_message.set_name('PN','PN_APPR_NO_CUST');
      l_errmsg1 :=  fnd_message.get;
      RAISE E_NO_CUST;

     /* If bill-to-Site is not present, do not approve the terms   bug#6412170*/
     ELSIF (l_cust_site_id is null) THEN
      fnd_message.set_name('PN','PN_APPR_NO_SITE');
      l_errmsg1 :=  fnd_message.get;
     RAISE E_NO_CUST;

     END IF;
     END IF; /* 7712952 */

      FOR dist_rec IN get_distributions_c(l_payment_term_id) LOOP

        IF dist_rec.account_class IN ('EXP','REV') THEN
          l_exp_rev_exists := TRUE;
          l_exp_rev_dist_pct := l_exp_rev_dist_pct + NVL(dist_rec.percentage,0);

        ELSIF dist_rec.account_class IN ('LIA','REC') THEN
          l_lia_rec_exists := TRUE;
          l_lia_rec_dist_pct := l_lia_rec_dist_pct + NVL(dist_rec.percentage,0);

          IF dist_rec.account_class = 'LIA' THEN
            l_lia_count := l_lia_count + 1;
          ELSE
            l_rec_count := l_rec_count + 1;
          END IF;

        ELSIF dist_rec.account_class IN ('ACC','UNEARN') THEN
          l_acc_unearn_exists := TRUE;
          l_acc_unearn_dist_pct := l_acc_unearn_dist_pct + NVL(dist_rec.percentage,0);

          IF dist_rec.account_class = 'ACC' THEN
            l_acc_count := l_acc_count + 1;
          ELSE
            l_unearn_count := l_unearn_count + 1;
          END IF;

        END IF;

        l_dist_count := l_dist_count + 1;

      END LOOP; /* get_distributions_c */

      IF l_dist_count > 0 AND
         (l_project_id            IS NULL AND
          l_task_id               IS NULL AND
          l_organization_id       IS NULL AND
          l_expenditure_type      IS NULL AND
          l_expenditure_item_date IS NULL) AND
          l_distribution_set_id   IS NULL
      THEN
      /* distributions exist, NO project info, NO distribution sets */

        /* REC, LIA, ACC, UNEARN cannot be split */
        IF l_lia_count > 1 OR
           l_rec_count > 1 OR
           l_acc_count > 1 OR
           l_unearn_count > 1
        THEN

          IF l_lia_count > 1 THEN
            FOR cls_rec IN get_acc_class_c('LIA') LOOP
              l_acc_class := cls_rec.meaning;
            END LOOP;

          ELSIF l_rec_count > 1 THEN
            FOR cls_rec IN get_acc_class_c('REC') LOOP
              l_acc_class := cls_rec.meaning;
            END LOOP;

          ELSIF l_acc_count > 1 THEN
            FOR cls_rec IN get_acc_class_c('ACC') LOOP
              l_acc_class := cls_rec.meaning;
            END LOOP;

          ELSIF l_unearn_count > 1 THEN
            FOR cls_rec IN get_acc_class_c('UNEARN') LOOP
              l_acc_class := cls_rec.meaning;
            END LOOP;

          END IF;

          fnd_message.set_name('PN', 'PN_DUP_ACCOUNT_IN_DIST');
          fnd_message.set_token('ACCOUNT_CLASS', l_acc_class);
          fnd_message.set_token('ACCOUNT_CLASS_A', l_acc_class);
          RAISE TERM_DIST_INVALID;

        END IF;

        /* percentages for all account classes must add upto 100 */
        IF (l_exp_rev_exists AND l_exp_rev_dist_pct <> 100) OR
           (l_lia_rec_exists AND l_lia_rec_dist_pct <> 100) OR
           (l_acc_unearn_exists AND l_acc_unearn_dist_pct <> 100)
        THEN

          fnd_message.set_name('PN', 'PN_DIST_PRCNT_TTL_MSG');
          RAISE TERM_DIST_INVALID;

        END IF;

      END IF; /* distributions exist, NO project info, NO distribution sets */

      IF l_lease_class_code = 'DIRECT' THEN

        IF NVL(l_normalize, 'N') = 'Y' THEN

          IF NOT (l_exp_rev_exists AND
                  l_acc_unearn_exists) THEN

            fnd_message.set_name('PN', 'PN_ACC_NORMALISED');
            RAISE TERM_DIST_INVALID;

          END IF; /* all dist does not exist */

        ELSE

          IF (l_project_id            IS NULL AND
              l_task_id               IS NULL AND
              l_organization_id       IS NULL AND
              l_expenditure_type      IS NULL AND
              l_expenditure_item_date IS NULL) AND
              l_distribution_set_id   IS NULL
          THEN
            /* DO NOT REMOVE THIS CONDITION */
            IF NOT l_exp_rev_exists THEN

              IF l_dist_count > 0 THEN
                fnd_message.set_name('PN', 'PN_EXP_DIST_MSG');
              ELSE
                fnd_message.set_name('PN', 'PN_ACC_UNNORMALISED');
              END IF;
              RAISE TERM_DIST_INVALID;

            END IF; /* exp acc does not exist */

          ELSE

            IF l_distribution_set_id IS NULL THEN

              IF (l_project_id            IS NULL OR
                  l_task_id               IS NULL OR
                  l_organization_id       IS NULL OR
                  l_expenditure_type      IS NULL OR
                  l_expenditure_item_date IS NULL) THEN

                fnd_message.set_name('PN', 'PN_ACC_UNNORMALISED');
                RAISE TERM_DIST_INVALID;

              ELSE

                /* all project information is here - so validate */
                PATC.get_status
                  ( x_project_id         => l_project_id
                  , x_task_id            => l_task_id
                  , x_ei_date            => l_expenditure_item_date
                  , x_expenditure_type   => l_expenditure_type
                  , x_non_labor_resource => NULL
                  , x_person_id          => NULL
                  , x_incurred_by_org_id => l_organization_id
                  , x_msg_application    => l_msg_app
                  , x_msg_type           => l_msg_type
                  , x_msg_token1         => l_msg_token1
                  , x_msg_token2         => l_msg_token2
                  , x_msg_token3         => l_msg_token3
                  , x_msg_count          => l_msg_count
                  , x_status             => l_status
                  , x_billable_flag      => l_bill_flag);

                IF l_status IS NOT NULL THEN

                  fnd_message.set_name('PA', l_status);
                  RAISE TERM_DIST_INVALID;

                END IF;

              END IF; /* incomplete project info */

            END IF; /* no distribution set */

          END IF; /* existance of project info or distribution set */

        END IF; /* normalize */

      ELSIF l_lease_class_code IN ('SUB_LEASE', 'THIRD_PARTY') THEN

        IF NVL(l_normalize, 'N') = 'Y' THEN

          /* for normalized terms, we need not look at the accounting
             option. After revenue recognition, all accounts needed */
          IF NOT (l_exp_rev_exists AND
                  l_lia_rec_exists AND
                  l_acc_unearn_exists)
          THEN

            fnd_message.set_name('PN', 'PN_ALL_ACNT_DIST_MSG');
            RAISE TERM_DIST_INVALID;

          END IF;

        ELSE
          /* The business rule is
             - If Accounting Option = Y (All Terms) then we need REC and REV
             - If Accounting Option = M or N (Normalized Terms or None) then,
                                      either no dist OR both REC and REV
             Since we know that distributions exist, we just check if
             _BOTH_ REV and REC exist
          */
          IF l_acc_optn = 'Y' THEN

            IF NOT (l_exp_rev_exists AND l_lia_rec_exists) THEN

              fnd_message.set_name('PN', 'PN_REVREC_DIST_MSG');
              RAISE TERM_DIST_INVALID;

            END IF;

          ELSIF l_acc_optn IN ('M', 'N') THEN

            IF l_dist_count > 0 AND
               NOT (l_exp_rev_exists AND l_lia_rec_exists)  THEN

              fnd_message.set_name('PN', 'PN_REVREC_DIST_MSG');
              RAISE TERM_DIST_INVALID;

            END IF;

          END IF; /* accounting option */

        END IF; /* normalize */

      END IF; /* l_lease_class_code */

    EXCEPTION
      WHEN TERM_DIST_INVALID THEN
        l_error := TRUE;
        l_errmsg := fnd_message.get;
        pn_variable_amount_pkg.put_output
          ('+----------------------------------------------------------+');
        pn_variable_amount_pkg.put_output(l_errmsg);
        pn_variable_amount_pkg.put_output
          ('+----------------------------------------------------------+');

    END;

    IF NOT l_error THEN
      pn_schedules_items.schedules_items
        ( errbuf          => l_errbuf
         ,retcode         => l_retcode
         ,p_lease_id      => l_lease_id
         ,p_lease_context => 'ADD'
         ,p_called_from   => 'VAR'
         ,p_term_id       => l_payment_term_id
         ,p_term_end_dt   => NULL);

      IF NVL(l_retcode,-1) <> 2 THEN
        UPDATE pn_payment_terms_all
        SET status = 'APPROVED',
            last_update_date = SYSDATE,
            last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0),
            last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0),
            approved_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
        WHERE payment_term_id = l_payment_term_id;
      END IF;
    END IF;

  END LOOP;

END IF;  --p_term_status = 'Y'

IF (p_term_status = 'Y' AND NVL(l_retcode,-1) <> 2 AND NOT l_error) OR
   NVL(p_rent_amt,-1) = 0 THEN

  p_counter := p_counter + 1;

  /* Set the variance exp code to 'Y' if p_rent_type is 'FORECASTED',
     actual_exp_code to 'Y' if p_rent_type is 'ACTUAL' and variance_exp_code to
     'Y' if p_rent_type is 'VARIANCE' in pn_var_grp_dates and pn_var_vol_hist
     to 'Y'
  */
  UPDATE pn_var_rent_inv_all
  SET forecasted_exp_code = DECODE(p_rent_type,'FORECASTED','Y',forecasted_exp_code),
      actual_exp_code = DECODE(p_rent_type,'ACTUAL','Y',actual_exp_code),
      variance_exp_code = DECODE(p_rent_type,'VARIANCE','Y',variance_exp_code),
      last_update_date = SYSDATE,
      last_updated_by = NVL(fnd_profile.VALUE ('USER_ID'), 0),
      last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
  WHERE var_rent_inv_id = p_var_rent_inv_id;

  /* pinky */
  UPDATE pn_var_rent_inv_all
  SET true_up_exp_code = 'Y'
  WHERE var_rent_inv_id = p_var_rent_inv_id
  AND   true_up_exp_code IS NOT NULL;
  /* pinky */

  UPDATE pn_var_grp_dates_all
  SET forecasted_exp_code = decode(p_rent_type,'FORECASTED','Y',forecasted_exp_code),
      actual_exp_code = decode(p_rent_type,'ACTUAL','Y',actual_exp_code),
      variance_exp_code = decode(p_rent_type,'VARIANCE','Y',variance_exp_code),
      last_update_date = SYSDATE,
      last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0),
      last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
  WHERE period_id = p_period_id
  AND invoice_date = p_invoice_date
  AND var_rent_id = p_var_rent_id;

  UPDATE pn_var_vol_hist_all
  SET forecasted_exp_code = decode(p_rent_type,'FORECASTED','Y',forecasted_exp_code),
      last_update_date = SYSDATE,
      last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0),
      last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
  WHERE period_id = p_period_id
  AND   p_rent_type = 'FORECASTED'
  AND grp_date_id IN
      (SELECT grp_date_id
       FROM pn_var_grp_dates_all
       WHERE period_id = p_period_id
       AND invoice_date = p_invoice_date
       AND var_rent_id = p_var_rent_id);



  UPDATE pn_var_vol_hist_all
  SET actual_exp_code = decode(p_rent_type,'ACTUAL','Y',actual_exp_code),
      variance_exp_code = decode(p_rent_type,'VARIANCE','Y',variance_exp_code),
      last_update_date = SYSDATE,
      last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0),
      last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
  WHERE period_id = p_period_id
  AND vol_hist_status_code = 'APPROVED'
  AND p_rent_type <> 'FORECASTED'
  AND grp_date_id IN
      (SELECT grp_date_id
       FROM pn_var_grp_dates_all
       WHERE period_id = p_period_id
       AND invoice_date = p_invoice_date
       AND var_rent_id = p_var_rent_id);

  /* update the transferred flag in pn_var_deductions to 'Y' for all the group
     dates that have been transferred only if variable rent term type is actual
     or variance */

  IF p_rent_type in ('ACTUAL','VARIANCE') THEN
    UPDATE pn_var_deductions_all
    SET exported_code = 'Y',
        last_update_date = SYSDATE,
        last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0),
        last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
    WHERE period_id = p_period_id
    AND grp_date_id IN
         (SELECT grp_date_id
          FROM pn_var_grp_dates_all
          WHERE period_id = p_period_id
          AND invoice_date = p_invoice_date
          AND var_rent_id = p_var_rent_id);
  END IF;

  /* Special handling for period number 1 for FLY or FY agreement */
  FOR rec IN period_FY_cur(p_period_id,p_var_rent_id)
  LOOP

    UPDATE pn_var_grp_dates_all
    SET forecasted_exp_code = decode(p_rent_type,'FORECASTED','Y',forecasted_exp_code),
        actual_exp_code = decode(p_rent_type,'ACTUAL','Y',actual_exp_code),
        variance_exp_code = decode(p_rent_type,'VARIANCE','Y',variance_exp_code),
        last_update_date = SYSDATE,
        last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0),
        last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
    WHERE period_id = p_period_id
    AND var_rent_id = p_var_rent_id;

    UPDATE pn_var_vol_hist_all
    SET actual_exp_code = decode(p_rent_type,'ACTUAL','Y',actual_exp_code),
        variance_exp_code = decode(p_rent_type,'VARIANCE','Y',variance_exp_code),
        last_update_date = SYSDATE,
        last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0),
        last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
    WHERE period_id = p_period_id
    AND vol_hist_status_code = 'APPROVED'
    AND p_rent_type <> 'FORECASTED'
    AND grp_date_id IN
        (SELECT grp_date_id
         FROM pn_var_grp_dates_all
         WHERE period_id = p_period_id);

    UPDATE pn_var_deductions_all
    SET exported_code = 'Y',
        last_update_date = SYSDATE,
        last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0),
        last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
    WHERE period_id = p_period_id
    AND p_rent_type <> 'FORECASTED'
    AND grp_date_id IN
         (SELECT grp_date_id
          FROM pn_var_grp_dates_all
          WHERE period_id = p_period_id);


  END LOOP;

END IF;

pn_variable_amount_pkg.put_log('pn_approve_varent_pkg.set_transferred_code  (-) : ');

EXCEPTION

  WHEN E_NO_CUST THEN
   pn_variable_amount_pkg.put_output
      ('+----------------------------------------------------------+');
      pn_variable_amount_pkg.put_output(l_errmsg1);
      pn_variable_amount_pkg.put_output('+----------------------------------------------------------+');

  WHEN OTHERS THEN
    pn_variable_amount_pkg.put_log
      ('Error in pn_approve_varent_pkg.set_transferred_code - '||sqlerrm);

END set_transferred_code;

END pn_approve_varent_pkg;

/
