--------------------------------------------------------
--  DDL for Package Body PN_VAR_TRUEUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_TRUEUP_PKG" AS
-- $Header: PNVRTRPB.pls 120.0.12010000.2 2009/12/22 11:11:37 jsundara ship $

TYPE two_nums_rec IS RECORD(
    period_id NUMBER,
    amount NUMBER);
TYPE NUM_T IS TABLE OF TWO_NUMS_REC INDEX BY BINARY_INTEGER;
G_ABATEMENT_APPLIED NUM_T;
G_ALLOWANCE_APPLIED NUM_T;
G_UNABATED_RENT NUM_T;
G_ABATED_RENT NUM_T;
G_TOT_ABATEMENT NUM_T;
G_IS_TU_CONC_FLAG VARCHAR2(1) := 'T'; /*Is this called as a result of calculate or of true up?*/
g_precision       NUMBER;

--------------------------------------------------------------------------------
--  NAME         : can_do_trueup
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION can_do_trueup( p_var_rent_id IN NUMBER
                       ,p_period_id   IN NUMBER)
RETURN BOOLEAN IS

  l_exists_trx            BOOLEAN;
  l_exists_approved_sales BOOLEAN;

  /* check if trx exists */
  CURSOR trx_exists_c( p_vr_id IN NUMBER
                      ,p_prd_id IN NUMBER) IS
    SELECT 1 FROM DUAL WHERE EXISTS
     (SELECT
      trx_header_id
      FROM
      pn_var_trx_headers_all
      WHERE
      var_rent_id = p_vr_id AND
      period_id = p_prd_id AND
      reporting_group_sales IS NOT NULL);

  /* exists approved sales? */
  CURSOR approved_sales_c( p_vr_id IN NUMBER
                          ,p_prd_id IN NUMBER) IS
    SELECT
    invoice_date
    FROM
    pn_var_grp_dates_all g,
    pn_var_periods_all   p
    WHERE
    g.var_rent_id = p_vr_id AND
    g.period_id   = p_prd_id AND
    g.period_id   = p.period_id AND
    g.grp_end_date <= p.end_date
    MINUS
    SELECT
    g.invoice_date
    FROM
    pn_var_trx_headers_all t,
    pn_var_grp_dates_all g,
    pn_var_periods_all   p
    WHERE
    t.grp_date_id = g.grp_date_id AND
    t.var_rent_id = p_vr_id AND
    t.period_id = p_prd_id AND
    t.period_id = p.period_id AND
    g.grp_end_date <= p.end_date AND
    t.reporting_group_sales IS NOT NULL;

BEGIN

  l_exists_approved_sales := FALSE;
  l_exists_trx            := FALSE;

  FOR rec IN trx_exists_c( p_vr_id  => p_var_rent_id
                          ,p_prd_id => p_period_id) LOOP

    l_exists_approved_sales := TRUE;
    l_exists_trx            := TRUE;

    EXIT;

  END LOOP;

  IF l_exists_trx THEN

    FOR rec IN approved_sales_c( p_vr_id  => p_var_rent_id
                                ,p_prd_id => p_period_id) LOOP

      l_exists_approved_sales := FALSE;
      EXIT;

    END LOOP;

  END IF;

  RETURN l_exists_approved_sales;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END can_do_trueup;

--------------------------------------------------------------------------------
--  NAME         : post_summary_trueup - global procedure
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--  23-MAY-2007  Lokesh   o Added rounding off for Bug # 6031202 for
--                          trueup_var_rent
--------------------------------------------------------------------------------
PROCEDURE post_summary_trueup ( p_var_rent_id IN NUMBER
                               ,p_period_id   IN NUMBER
                               ,p_proration_rule IN VARCHAR2)
IS

  /* get all lines to post summary for */
  CURSOR trueup_rent_c( p_vr_id  IN NUMBER
                       ,p_prd_id IN NUMBER) IS
    SELECT
     NVL(SUM(percent_rent_due),0)  AS billed_rent
    ,NVL(SUM(trueup_rent_due),0)   AS trueup_rent
    ,MAX(calc_prd_end_date)        AS trueup_date
    ,line_item_id
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id
    GROUP BY
    line_item_id
    ORDER BY
    line_item_id;

  /* get the billed rent for first partial period */
  CURSOR first_period_c( p_vr_id     IN NUMBER) IS
    SELECT
     NVL(SUM(percent_rent_due),0)  AS billed_rent
    ,line_item_id
    FROM
    pn_var_periods_all prd,
    pn_var_rents_all   var,
    pn_var_trx_headers_all trx
    WHERE
    prd.var_rent_id = p_vr_id AND
    prd.var_rent_id = var.var_rent_id AND
    prd.start_date =  var.commencement_date AND
    trx.var_rent_id = prd.var_rent_id AND
    trx.period_id = prd.period_id
    GROUP BY
    trx.line_item_id
    ORDER BY
    trx.line_item_id;

  /* Fetch the second year period id */
  CURSOR second_yr_cur (p_vr_id     IN NUMBER) IS
    SELECT
    period_id
    FROM
    pn_var_periods_all prd
    WHERE
    prd.var_rent_id = p_vr_id AND
    prd.period_num = 2;


  l_vr_summ_id NUMBER;
  l_billed_rent_fst_yr NUMBER := 0;
  l_billed_rent        NUMBER := 0;
  l_second_yr_id       NUMBER;

BEGIN

  pnp_debug_pkg.log('post_summary_trueup (+) .... ');

  FOR trueup_rec IN trueup_rent_c( p_vr_id  => p_var_rent_id
                                  ,p_prd_id => p_period_id)
  LOOP

    l_billed_rent := trueup_rec.billed_rent;
    pnp_debug_pkg.log('l_billed_rent:'||l_billed_rent);
    /* Note:
       Handling to take the rent for first year in account
       while calculating the true up for second year in CYNP
       and CYP */
    IF  p_proration_rule IN  (pn_var_rent_calc_pkg.G_PRORUL_CYP
                            ,pn_var_rent_calc_pkg.G_PRORUL_CYNP) THEN


       /* Fetch the details for the first partial year */
      FOR first_period_rec IN  first_period_c(p_vr_id  => p_var_rent_id) LOOP
        l_billed_rent_fst_yr := first_period_rec.billed_rent;
      END LOOP;

      /* Fetch the period id for second period */
      FOR second_yr_rec IN second_yr_cur(p_vr_id  => p_var_rent_id) LOOP
        l_second_yr_id := second_yr_rec.period_id;
      END LOOP;

      IF l_second_yr_id = p_period_id THEN
        l_billed_rent := l_billed_rent + l_billed_rent_fst_yr;
      END IF;

    END IF;

    pnp_debug_pkg.log('l_billed_rent:'||l_billed_rent);
    pnp_debug_pkg.log('trup_rent:'||trueup_rec.trueup_rent);

    UPDATE
    pn_var_rent_summ_all
    SET
    trueup_var_rent = 0
    WHERE
    var_rent_id  = p_var_rent_id AND
    period_id    = p_period_id AND
    line_item_id = trueup_rec.line_item_id;

    UPDATE
    pn_var_rent_summ_all
    SET
    trueup_var_rent = round((trueup_rec.trueup_rent - l_billed_rent), g_precision)
    WHERE
    var_rent_id  = p_var_rent_id AND
    period_id    = p_period_id AND
    line_item_id = trueup_rec.line_item_id AND
    grp_date_id  = (SELECT
                    grp_date_id
                    FROM
                    pn_var_grp_dates_all
                    WHERE
                    period_id = p_period_id AND
                    grp_end_date = trueup_rec.trueup_date)
    RETURNING
    var_rent_summ_id
    INTO
    l_vr_summ_id;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END post_summary_trueup;

--------------------------------------------------------------------------------
--  NAME         : insert_invoice_trueup
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE insert_invoice_trueup( p_var_rent_id IN NUMBER
                                ,p_period_id   IN NUMBER) IS

  /* get invoice dates for a period */
  CURSOR trueup_inv_dates_c( p_vr_id  IN NUMBER
                            ,p_prd_id IN NUMBER
                            ,p_new_termn_date DATE) IS
    SELECT
     MAX(invoice_date)            AS trueup_invoice_date
    ,NVL(SUM(tot_act_vol), 0)     AS total_actual_sales
    ,NVL(SUM(trueup_var_rent), 0) AS total_trueup_rent
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id  AND
    invoice_date <= p_new_termn_date;

  /* get latest invoice */
  CURSOR trueup_invoice2upd_c( p_vr_id  IN NUMBER
                              ,p_prd_id IN NUMBER
                              ,p_inv_dt IN DATE) IS
    SELECT
     var_rent_inv_id
    ,var_rent_id
    ,period_id
    ,invoice_date
    ,adjust_num
    ,true_up_status
    ,true_up_exp_code
    ,true_up_amt
    ,tot_act_vol
    ,act_per_rent
    ,actual_invoiced_amount
    ,rec_abatement_override
    FROM
    pn_var_rent_inv_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    invoice_date = p_inv_dt AND
    /*true_up_amt <> 0 AND*/
    true_up_status IS NOT NULL AND
    true_up_exp_code IS NOT NULL
    ORDER BY adjust_num DESC;

  /* get the period rent */
  CURSOR period_rent_c ( p_vr_id  IN NUMBER
                        ,p_prd_id IN NUMBER) IS
    SELECT
     NVL(SUM(act_var_rent), 0)    AS total_period_rent
    ,NVL(SUM(trueup_var_rent), 0) AS total_trueup_rent
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id;

  l_total_period_rent NUMBER;
  l_total_period_unabt_rent NUMBER;

  /* get latest invoice */
  CURSOR prev_invoiced_c( p_vr_id  IN NUMBER
                         ,p_prd_id IN NUMBER) IS
    SELECT
    NVL(SUM(actual_invoiced_amount), 0) AS prev_inv_trueup_amt
    FROM
    pn_var_rent_inv_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    (true_up_amt IS NULL OR true_up_exp_code = 'Y');

  l_invoice_on           VARCHAR2(30);
  l_row_id               ROWID;
  l_var_rent_inv_id      NUMBER;
  l_max_adjust_num       NUMBER;
  l_prev_inv_trueup_rent NUMBER;
  l_curr_inv_trueup_rent NUMBER;
  l_rec_abatement_override NUMBER;
  /* get ORG ID */
  CURSOR org_c(p_vr_id IN NUMBER) IS
    SELECT org_id, termination_date
      FROM pn_var_rents_all
     WHERE var_rent_id = p_vr_id;

  l_org_id NUMBER;



  l_exists_invoice BOOLEAN;
  l_abated_rent    NUMBER;
  l_tot_abatement  NUMBER;
  l_allowance      NUMBER;
  l_precision      NUMBER;
  l_tot_period_rent NUMBER := NULL;
  l_vr_termination_date DATE;

BEGIN
  pnp_debug_pkg.log('+++++++Insert_invoice_trueup++++++++');
  FOR vr_rec IN org_c(p_vr_id => p_var_rent_id) LOOP
    l_org_id := vr_rec.org_id;
    l_vr_termination_date := vr_rec.termination_date;
  END LOOP;

  l_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(l_org_id),4);
  pnp_debug_pkg.log('l_precision:'||l_precision);
  FOR i IN 1..G_ABATED_RENT.COUNT LOOP
     IF G_ABATED_RENT(i).period_id = p_period_id THEN
        l_total_period_rent := G_ABATED_RENT(i).AMOUNT;
        EXIT;
     END IF;

  END LOOP;

  FOR i IN 1..G_UNABATED_RENT.COUNT LOOP
     IF G_UNABATED_RENT(i).period_id = p_period_id THEN
        l_total_period_unabt_rent := G_UNABATED_RENT(i).AMOUNT;
        EXIT;
     END IF;
  END LOOP;

  --
  FOR i IN 1..G_TOT_ABATEMENT.COUNT  LOOP
     IF G_TOT_ABATEMENT(i).period_id = p_period_id THEN
        l_tot_abatement := G_TOT_ABATEMENT(i).AMOUNT;
        EXIT;
     END IF;
  END LOOP;

  FOR i IN 1..G_ALLOWANCE_APPLIED.COUNT  LOOP
     IF G_ALLOWANCE_APPLIED(i).period_id = p_period_id THEN
        l_allowance := G_ALLOWANCE_APPLIED(i).AMOUNT;
        EXIT;
     END IF;
  END LOOP;

  pnp_debug_pkg.log('s** l_total_period_rent'||l_total_period_rent);
/*  FOR summ_rec IN period_rent_c ( p_vr_id  => p_var_rent_id
                                 ,p_prd_id => p_period_id)
  LOOP
    l_total_period_rent
      := summ_rec.total_period_rent + summ_rec.total_trueup_rent;
  END LOOP;
*/



  /* loop for all invoice dates in the period */
  FOR inv_rec IN trueup_inv_dates_c( p_vr_id  => p_var_rent_id
                                    ,p_prd_id => p_period_id
                                    ,p_new_termn_date => l_vr_termination_date)
  LOOP

    l_row_id               := NULL;
    l_var_rent_inv_id      := NULL;
    l_max_adjust_num       := 0;
    l_prev_inv_trueup_rent := 0;
    l_curr_inv_trueup_rent := 0;
    l_exists_invoice       := FALSE;


    /* check if there exists an invoice for this invoice date */
    FOR inv2upd_rec IN trueup_invoice2upd_c ( p_vr_id  => p_var_rent_id
                                             ,p_prd_id => p_period_id
                                             ,p_inv_dt => inv_rec.trueup_invoice_date)
    LOOP

      /* invoice exists - we only look at the last invoice */
      l_exists_invoice := TRUE;
      l_rec_abatement_override := inv2upd_rec.rec_abatement_override;
      /* invoice updateable? */
      IF NVL(inv2upd_rec.true_up_exp_code, 'N') <> 'Y' THEN

        /* updateable */
        l_var_rent_inv_id      := inv2upd_rec.var_rent_inv_id;
        l_max_adjust_num       := inv2upd_rec.adjust_num;
        l_curr_inv_trueup_rent := inv2upd_rec.actual_invoiced_amount;
      ELSIF NVL(inv2upd_rec.true_up_exp_code, 'N') = 'Y' THEN

        /* NON - updateable */
        l_var_rent_inv_id      := NULL;
        l_max_adjust_num       := inv2upd_rec.adjust_num + 1;
        l_curr_inv_trueup_rent := 0;
        l_tot_period_rent := inv2upd_rec.act_per_rent;

      END IF; /* invoice updateable? */

      /* we only look at the last invoice - important to exit here */
      EXIT;

    END LOOP; /* check if there exists an invoice for this invoice date */


    /* get the previously billed amount from approved invoices */
    FOR prev_inv_rec IN prev_invoiced_c( p_vr_id  => p_var_rent_id
                                        ,p_prd_id => p_period_id)
    LOOP
      l_prev_inv_trueup_rent := prev_inv_rec.prev_inv_trueup_amt;
    END LOOP;

    /* atleast one invoice exists? */
    IF NOT l_exists_invoice AND
       (round(l_total_period_rent, l_precision)- round(l_prev_inv_trueup_rent, l_precision)) <> 0  THEN

      /* first time for this invoice date - create invoice */
      pn_var_rent_inv_pkg.insert_row
      ( x_rowid                   => l_row_id
       ,x_var_rent_inv_id         => l_var_rent_inv_id
       ,x_adjust_num              => l_max_adjust_num
       ,x_invoice_date            => inv_rec.trueup_invoice_date
       ,x_for_per_rent            => NULL
       ,x_tot_act_vol             => inv_rec.total_actual_sales
       ,x_act_per_rent            => l_total_period_unabt_rent
       ,x_constr_actual_rent      => l_total_period_unabt_rent
       ,x_abatement_appl          => l_allowance
       ,x_rec_abatement           => l_tot_abatement
       ,x_rec_abatement_override  => l_rec_abatement_override
       ,x_negative_rent           => 0
       ,x_actual_invoiced_amount  => l_total_period_rent - l_prev_inv_trueup_rent
       ,x_period_id               => p_period_id
       ,x_var_rent_id             => p_var_rent_id
       ,x_forecasted_term_status  => 'N'
       ,x_variance_term_status    => 'N'
       ,x_actual_term_status      => 'N'
       ,x_forecasted_exp_code     => 'N'
       ,x_variance_exp_code       => 'N'
       ,x_actual_exp_code         => 'N'
       ,x_comments                => 'created invoice'
       ,x_attribute_category      => NULL
       ,x_attribute1              => NULL
       ,x_attribute2              => NULL
       ,x_attribute3              => NULL
       ,x_attribute4              => NULL
       ,x_attribute5              => NULL
       ,x_attribute6              => NULL
       ,x_attribute7              => NULL
       ,x_attribute8              => NULL
       ,x_attribute9              => NULL
       ,x_attribute10             => NULL
       ,x_attribute11             => NULL
       ,x_attribute12             => NULL
       ,x_attribute13             => NULL
       ,x_attribute14             => NULL
       ,x_attribute15             => NULL
       ,x_creation_date           => SYSDATE
       ,x_created_by              => NVL(fnd_global.user_id,0)
       ,x_last_update_date        => SYSDATE
       ,x_last_updated_by         => NVL(fnd_global.user_id,0)
       ,x_last_update_login       => NVL(fnd_global.login_id,0)
       ,x_true_up_amount          => l_total_period_rent - l_prev_inv_trueup_rent
       ,x_true_up_status          => 'N'
       ,x_true_up_exp_code        => 'N'
       ,x_org_id                  => l_org_id );

    ELSIF l_exists_invoice THEN

      /* no invoice to update - create a new one */
      IF l_var_rent_inv_id IS NULL THEN

        /* if there a change in rent */
        IF ((round(l_total_period_rent, l_precision) - round(l_prev_inv_trueup_rent, l_precision)) <> 0
            OR round(l_total_period_rent, l_precision) <> round(l_tot_period_rent, l_precision)) THEN

          /* create new invoice for difference amt */
          pn_var_rent_inv_pkg.insert_row
          ( x_rowid                   => l_row_id
           ,x_var_rent_inv_id         => l_var_rent_inv_id
           ,x_adjust_num              => l_max_adjust_num
           ,x_invoice_date            => inv_rec.trueup_invoice_date
           ,x_for_per_rent            => NULL
           ,x_tot_act_vol             => inv_rec.total_actual_sales
           ,x_act_per_rent            => l_total_period_unabt_rent
           ,x_constr_actual_rent      => l_total_period_unabt_rent
           ,x_abatement_appl          => l_allowance
           ,x_rec_abatement           => l_tot_abatement
           ,x_rec_abatement_override  => l_rec_abatement_override
           ,x_negative_rent           => 0
           ,x_actual_invoiced_amount  => (l_total_period_rent - l_prev_inv_trueup_rent)
           ,x_period_id               => p_period_id
           ,x_var_rent_id             => p_var_rent_id
           ,x_forecasted_term_status  => 'N'
           ,x_variance_term_status    => 'N'
           ,x_actual_term_status      => 'N'
           ,x_forecasted_exp_code     => 'N'
           ,x_variance_exp_code       => 'N'
           ,x_actual_exp_code         => 'N'
           ,x_comments                => 'created invoice'
           ,x_attribute_category      => NULL
           ,x_attribute1              => NULL
           ,x_attribute2              => NULL
           ,x_attribute3              => NULL
           ,x_attribute4              => NULL
           ,x_attribute5              => NULL
           ,x_attribute6              => NULL
           ,x_attribute7              => NULL
           ,x_attribute8              => NULL
           ,x_attribute9              => NULL
           ,x_attribute10             => NULL
           ,x_attribute11             => NULL
           ,x_attribute12             => NULL
           ,x_attribute13             => NULL
           ,x_attribute14             => NULL
           ,x_attribute15             => NULL
           ,x_creation_date           => SYSDATE
           ,x_created_by              => NVL(fnd_global.user_id,0)
           ,x_last_update_date        => SYSDATE
           ,x_last_updated_by         => NVL(fnd_global.user_id,0)
           ,x_last_update_login       => NVL(fnd_global.login_id,0)
           ,x_true_up_amount          => (l_total_period_rent - l_prev_inv_trueup_rent)
           ,x_true_up_status          => 'N'
           ,x_true_up_exp_code        => 'N'
           ,x_org_id                  => l_org_id );

        END IF; /* IF inv_rec.total_actual_rent <> l_prev_inv_trueup_rent THEN */

      ELSIF l_var_rent_inv_id IS NOT NULL THEN

        /* if there a change in rent */
        IF (round(l_total_period_rent, l_precision) - round(l_prev_inv_trueup_rent, l_precision)) <> round(l_curr_inv_trueup_rent, l_precision)
        THEN

          DELETE
          pn_payment_terms_all
          WHERE
          var_rent_inv_id = l_var_rent_inv_id AND
          status <> pn_var_rent_calc_pkg.G_TERM_STATUS_APPROVED;

          /* update the invoice */
          UPDATE
          pn_var_rent_inv_all
          SET
           act_per_rent           = l_total_period_unabt_rent
          ,constr_actual_rent     = l_total_period_unabt_rent
          ,actual_invoiced_amount = (l_total_period_rent - l_prev_inv_trueup_rent)
          ,true_up_amt            = (l_total_period_rent - l_prev_inv_trueup_rent)
          ,tot_act_vol            = ROUND(inv_rec.total_actual_sales, l_precision)  -- bug # 6007571
          ,actual_term_status     = 'N'
          ,abatement_appl         = l_allowance
          ,rec_abatement          = l_tot_abatement
          ,last_update_date       = SYSDATE
          ,last_updated_by        = NVL(fnd_global.user_id,0)
          ,last_update_login      = NVL(fnd_global.login_id,0)
          WHERE
          var_rent_inv_id = l_var_rent_inv_id;

        END IF; /* if there a change in rent */

      END IF; /* IF l_var_rent_inv_id IS NULL THEN */

    END IF; /* IF NOT l_exists_invoice THEN */

  END LOOP; /* loop for all invoice dates in the period */

EXCEPTION
  WHEN OTHERS THEN RAISE;

END insert_invoice_trueup;

/*Procedures to calculate true_up abatements.*/

--------------------------------------------------------------------------------
--  NAME         : apply_abatements
--  DESCRIPTION  : Applies abatements to given periods of a specific VR
--  PURPOSE      : Applies abatements.
--  INVOKED FROM : calculate_trueup
--  ARGUMENTS    : p_var_rent_id: Vr to apply abatements for.
--                 p_period_id: Period to calculate for.
--                 p_flag: If calculate then actual_invoiced amount is
--                 updated.
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  25/Nov/06    Shabda Created
--  4/Nov/07     o Shabda fix for bug 5724597. Modified so we now get the true up
--                 rent based on constr_actual_rent and subtrach the non cumulative
--                 values to get the TU amount.
--------------------------------------------------------------------------------
PROCEDURE apply_abatements(p_var_rent_id IN NUMBER,
                 p_period_id IN NUMBER,
                 p_flag IN VARCHAR2)
IS
  -- Allowances first ot abatements?
  CURSOR order_c(ip_var_rent_id NUMBER) IS
  SELECT ORDER_OF_APPL_CODE, termination_date, org_id
  FROM PN_VAR_RENTS_ALL abat
  WHERE abat.var_rent_id = ip_var_rent_id;

  -- Get the details of
  CURSOR inv_c( ip_var_rent_id NUMBER,
                ip_period_id NUMBER,
                p_new_termn_date DATE
            ) IS
    SELECT * FROM
    (SELECT var_rent_inv_id, constr_actual_rent, true_up_amt,
           true_up_exp_code, invoice_date
    FROM pn_var_rent_inv_all inv1
    WHERE inv1.var_rent_id = ip_var_rent_id
    AND inv1.period_id = ip_period_id
    AND inv1.invoice_date <= p_new_termn_date
    AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      WHERE inv1.var_rent_id = inv2.var_rent_id
      AND   inv1.period_id = inv2.period_id
      AND inv1.invoice_date = inv2.invoice_date)
    AND TRUE_UP_AMT IS NULL
    ORDER BY INVOICE_DATE)

    UNION ALL
    SELECT
     NULL as var_rent_inv_id
    ,(SELECT NVL((SUM(act_var_rent) + NVL(SUM(trueup_var_rent), 0) -  NVL(SUM(first_yr_rent), 0)), 0)
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = ip_var_rent_id AND
    period_id = ip_period_id
    )   AS constr_actual_rent
 ,(SELECT NVL((SUM(act_var_rent) + NVL(SUM(trueup_var_rent), 0) -  NVL(SUM(first_yr_rent), 0)), 0)
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = ip_var_rent_id AND
    period_id = ip_period_id
    ) AS true_up_amt
    ,'N'  true_up_exp_code
    , invoice_date
    FROM
    pn_var_rent_summ_all summ,
    pn_var_periods_all per,
    pn_var_rents_all  vr
    WHERE
    summ.period_id = per.period_id AND
    vr.var_rent_id = per.var_rent_id AND
    (per.period_num <> 1 OR
    vr.proration_rule NOT IN ('FY', 'FLY')) AND
    summ.var_rent_id = ip_var_rent_id AND
    summ.period_id = ip_period_id
    AND summ.group_date = (select max(group_date) from pn_var_rent_summ_all
    where period_id = ip_period_id)
    AND G_IS_TU_CONC_FLAG = 'T'

    UNION ALL
     SELECT
     NULL as var_rent_inv_id
    ,(SELECT NVL(SUM(first_yr_rent), 0)
    FROM
    pn_var_rent_summ_all summ,
    pn_var_periods_all per
    WHERE
    per.period_id = summ.period_id AND
    summ.var_rent_id = ip_var_rent_id AND
    per.period_num = 2
    )
    +
    (SELECT NVL(SUM(trueup_var_rent), 0)
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = ip_var_rent_id AND
    period_id = ip_period_id
    )
    as const_t
 ,(SELECT NVL(SUM(first_yr_rent), 0)
    FROM
    pn_var_rent_summ_all summ,
    pn_var_periods_all per
    WHERE
    per.period_id = summ.period_id AND
    summ.var_rent_id = ip_var_rent_id AND
    per.period_num = 2
    )
    +
    (SELECT NVL(SUM(trueup_var_rent), 0)
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = ip_var_rent_id AND
    period_id = ip_period_id
    )
    AS true_up_amt
    ,'N'  true_up_exp_code
    , invoice_date
    FROM
    pn_var_rent_summ_all summ,
    pn_var_periods_all per,
    pn_var_rents_all  vr
    WHERE
    summ.period_id = per.period_id AND
    vr.var_rent_id = per.var_rent_id AND
    vr.proration_rule IN ('FY', 'FLY') AND
    per.period_num = 1 AND
    summ.var_rent_id = ip_var_rent_id AND
    summ.period_id = ip_period_id
    AND summ.group_date = (select max(group_date) from pn_var_rent_summ_all
    where period_id = ip_period_id)
    AND G_IS_TU_CONC_FLAG = 'T';

  /* get prev invoiced amount. */
  CURSOR prev_invoiced_c( p_vr_id  IN NUMBER
                         ,p_prd_id IN NUMBER
                         ,p_inv_dt IN DATE) IS
    SELECT
    NVL(SUM(actual_invoiced_amount), 0) AS prev_invoiced_amt
    FROM
    pn_var_rent_inv_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    invoice_date = p_inv_dt AND
    (actual_exp_code = 'Y'
    OR variance_exp_code = 'Y')
    AND
    (NVL(true_up_amt, 0) = 0 AND
    true_up_status IS NULL AND
    true_up_exp_code IS NULL);

    --Previously invoiced true up rent.
    CURSOR prev_invoiced_tu_c( p_vr_id  IN NUMBER
                         ,p_prd_id IN NUMBER
                         ,p_inv_dt IN DATE) IS
    SELECT
    NVL(SUM(actual_invoiced_amount), 0) AS prev_inv_trueup_amt
    FROM
    pn_var_rent_inv_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    invoice_date = p_inv_dt AND
    (actual_exp_code = 'Y' OR true_up_exp_code = 'Y' OR variance_exp_code = 'Y') AND
    /*true_up_amt <> 0 AND */
    true_up_status IS NOT NULL AND
    true_up_exp_code IS NOT NULL;

    -- Get the details of rolling allowance
   CURSOR rolling_allow_c(ip_var_rent_id NUMBER) IS
    SELECT NVL(amount, 0) rolling_allow
            ,allowance_applied allow_applied
            ,start_date
            ,end_date
            ,abatement_id
    FROM PN_VAR_ABAT_DEFAULTS_ALL
    WHERE var_rent_id = ip_var_rent_id
    AND type_code = pn_var_rent_calc_pkg.G_ABAT_TYPE_CODE_ALLO
    ORDER BY start_date;

      -- Get the details of exported status
    CURSOR is_act_or_rec_exp_c(ip_var_rent_inv_id NUMBER) IS
      SELECT DECODE(invoice_on,
        pn_var_rent_calc_pkg.G_INV_ON_ACTUAL, actual_exp_code,
        pn_var_rent_calc_pkg.G_INV_ON_FORECASTED, variance_exp_code) AS
        exp_code,
        inv.actual_invoiced_amount
        FROM pn_var_rents_all vr,
             pn_var_rent_inv_all inv
       WHERE vr.var_rent_id = inv.var_rent_id
         AND inv.var_rent_inv_id = ip_var_rent_inv_id;

    -- sum of non cumulative rents of a specific period
    CURSOR non_cumm_rent_c(ip_var_rent_id NUMBER,
                         ip_period_id   NUMBER
              ) IS
    SELECT SUM(actual_invoiced_amount) tot_nc_rent
    FROM pn_var_rent_inv_all
    WHERE var_rent_id = ip_var_rent_id
    AND period_id = ip_period_id
    AND true_up_amt IS NULL
    AND true_up_status IS NULL
    AND true_up_exp_code IS NULL;


    -- Get all the details of a specific invoice.
    CURSOR inv_all_c(ip_vr_inv_id NUMBER
            ) IS
    SELECT *
    FROM pn_var_rent_inv_all
    WHERE var_rent_inv_id = ip_vr_inv_id;


  l_abat_order   VARCHAR(30);
  l_prev_inv_exp NUMBER;
  l_abated_rent  NUMBER;
  l_allow_t      ALLOW_TBL;--Table to keep track of allowance for non-cumm inv
  l_allow_tu_t   ALLOW_TBL;--Table to keep track of allowance for TU invoices
  l_diff_amt     NUMBER;
  l_is_inv_exp   VARCHAR2(30);
  l_row_id       ROWID;
  l_var_rent_inv_id NUMBER;
  l_vr_termination_date DATE;
  l_actual_invoiced_amount NUMBER;
  l_org_id       NUMBER;
  l_precision    NUMBER;

BEGIN
  /*To apply abatements we need to
  1. Apply deffered negative rents.
  2. Apply allowances/Abatements.
  3. Apply/Allowances/Abatements.
  */
  pnp_debug_pkg.log('*apply_abatements start(+)*');
  pnp_debug_pkg.log('p_flag:'||p_flag);
  FOR rec IN order_c(p_var_rent_id) LOOP
    l_abat_order := rec.ORDER_OF_APPL_CODE;
    l_vr_termination_date := rec.termination_date;
    l_org_id := rec.org_id;
    --Since each record has same value for ORDER_OF_APPL_CODE exit after one looping.
    EXIT;
  END LOOP;

  OPEN rolling_allow_c(p_var_rent_id);
  FETCH rolling_allow_c BULK COLLECT INTO l_allow_t;
  CLOSE rolling_allow_c;

  OPEN rolling_allow_c(p_var_rent_id);
  FETCH rolling_allow_c BULK COLLECT INTO l_allow_tu_t;
  CLOSE rolling_allow_c;


  l_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(l_org_id),4);

  FOR inv_rec IN inv_c(p_var_rent_id, p_period_id, l_vr_termination_date) LOOP

     --If this is a non cummulative apply_defered_neg_rent
     --Do not apply def_neg_rent in TU invoices
     IF (inv_rec.true_up_amt IS NULL) THEN
       PN_VAR_TRUEUP_PKG.apply_def_neg_rent(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_abated_rent);
     ELSE
       l_abated_rent := inv_rec.constr_actual_rent;
       G_UNABATED_RENT(G_UNABATED_RENT.COUNT+1).period_id := p_period_id;
       G_UNABATED_RENT(G_UNABATED_RENT.COUNT).amount := l_abated_rent;
     END IF;

   IF (l_abat_order = pn_var_rent_calc_pkg.G_ALLOWANCE_FIRST) THEN
    pnp_debug_pkg.log('call pnp_debug_pkg.log');
    PN_VAR_TRUEUP_PKG.apply_allow(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_allow_t, l_allow_tu_t, l_abated_rent);
    pnp_debug_pkg.log('complete');
   END IF;--Apply allowance.


   pnp_debug_pkg.log('call populate_abat');
   PN_VAR_TRUEUP_PKG.populate_abat(p_var_rent_id , p_period_id, inv_rec.var_rent_inv_id);
   pnp_debug_pkg.log('complete');


   pnp_debug_pkg.log('call apply_abat');
   PN_VAR_TRUEUP_PKG.apply_abat(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_abated_rent);
   pnp_debug_pkg.log('complete');


   IF(l_abat_order <> pn_var_rent_calc_pkg.G_ALLOWANCE_FIRST) THEN
     pnp_debug_pkg.log('call pnp_debug_pkg.log');
     PN_VAR_TRUEUP_PKG.apply_allow(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_allow_t, l_allow_tu_t, l_abated_rent);
     pnp_debug_pkg.log('complete');
   END IF;--Apply allowance


   pnp_debug_pkg.log('called populate_neg_rent');
   IF (inv_rec.true_up_amt IS NULL) THEN
      PN_VAR_TRUEUP_PKG.populate_neg_rent(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_abated_rent);
   END IF;
   pnp_debug_pkg.log('complete');


   /* update the invoice */
   IF (p_flag = 'CALCULATE') THEN
     IF (inv_rec.true_up_amt IS NULL) THEN
       --Non true up invoice
       FOR exp_rec IN is_act_or_rec_exp_c(inv_rec.var_rent_inv_id) LOOP
         l_is_inv_exp := exp_rec.exp_code;
         l_actual_invoiced_amount := exp_rec.actual_invoiced_amount;
       END LOOP;
       FOR rec IN prev_invoiced_c(p_var_rent_id, p_period_id, inv_rec.invoice_date) LOOP
         l_prev_inv_exp := rec.prev_invoiced_amt;
       END LOOP;

       IF (l_is_inv_exp = 'N' ) AND
        (round(l_abated_rent,l_precision) - round(l_prev_inv_exp,l_precision))<> NVL(l_actual_invoiced_amount, 0) THEN

           DELETE
           pn_payment_terms_all
           WHERE
           var_rent_inv_id = inv_rec.var_rent_inv_id AND
           status <> pn_var_rent_calc_pkg.G_TERM_STATUS_APPROVED AND
           var_rent_type = pn_var_rent_calc_pkg.G_INV_ON_ACTUAL;

           -- Update the current invoice
           pnp_debug_pkg.log('Abatements - updating');
           UPDATE
           pn_var_rent_inv_all
           SET
           actual_invoiced_amount = (round(l_abated_rent,l_precision) - round(l_prev_inv_exp,l_precision))
           ,actual_term_status    = 'N'
           ,last_update_date       = SYSDATE
           ,last_updated_by        = NVL(fnd_global.user_id,0)
           ,last_update_login      = NVL(fnd_global.login_id,0)
           WHERE
           var_rent_inv_id = inv_rec.var_rent_inv_id;
       ELSIF ((l_abated_rent - l_prev_inv_exp)<>0) AND (l_is_inv_exp = 'Y') THEN
        -- Insert a new invoice. This happens only if your rents changes as a result of
        -- applied allowance/abat when you add them after some calc have been done.
        FOR inv_all_rec IN inv_all_c(inv_rec.var_rent_inv_id) LOOP
          --This can loop only once
          pnp_debug_pkg.log('l_prev_inv_exp:'||l_prev_inv_exp);
          pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
          pnp_debug_pkg.log('Abatements - inserting');
          l_row_id := NULL;
          l_var_rent_inv_id := NULL;
          pn_var_rent_inv_pkg.insert_row
             ( x_rowid                   => l_row_id,
               x_var_rent_inv_id         => l_var_rent_inv_id,
               x_adjust_num              => inv_all_rec.adjust_num+1,
               x_invoice_date            => inv_all_rec.invoice_date,
               x_for_per_rent            => inv_all_rec.for_per_rent,
               x_tot_act_vol             => inv_all_rec.tot_act_vol,
               x_act_per_rent            => round(inv_all_rec.act_per_rent,l_precision),
               x_constr_actual_rent      => round(inv_all_rec.constr_actual_rent,l_precision),
               x_abatement_appl          => inv_all_rec.abatement_appl,
               x_rec_abatement           => inv_all_rec.rec_abatement,
               x_rec_abatement_override  => inv_all_rec.rec_abatement_override,
               x_negative_rent           => inv_all_rec.negative_rent,
               x_actual_invoiced_amount  => (round(l_abated_rent,l_precision) - round(l_prev_inv_exp,l_precision)),
               x_period_id               => inv_all_rec.period_id,
               x_var_rent_id             => inv_all_rec.var_rent_id,
               x_forecasted_term_status  => 'N',
               x_variance_term_status    => 'N',
               x_actual_term_status      => 'N',
               x_forecasted_exp_code     => 'N',
               x_variance_exp_code       => 'N',
               x_actual_exp_code         => 'N',
               x_comments                => 'created invoice',
               x_attribute_category      => NULL,
               x_attribute1              => NULL,
               x_attribute2              => NULL,
               x_attribute3              => NULL,
               x_attribute4              => NULL,
               x_attribute5              => NULL,
               x_attribute6              => NULL,
               x_attribute7              => NULL,
               x_attribute8              => NULL,
               x_attribute9              => NULL,
               x_attribute10             => NULL,
               x_attribute11             => NULL,
               x_attribute12             => NULL,
               x_attribute13             => NULL,
               x_attribute14             => NULL,
               x_attribute15             => NULL,
               x_creation_date           => SYSDATE,
               x_created_by              => NVL(fnd_global.user_id,0),
               x_last_update_date        => SYSDATE,
               x_last_updated_by         => NVL(fnd_global.user_id,0),
               x_last_update_login       => NVL(fnd_global.login_id,0),
               x_org_id                  => inv_all_rec.org_id );
         END LOOP;
       END IF;
     ELSE
       -- True up invoice
       --
       /*FOR nc_rent_rec IN non_cumm_rent_c(p_var_rent_id, p_period_id) LOOP
         l_diff_amt := nc_rent_rec.tot_nc_rent;
       END LOOP;

       l_abated_rent := l_abated_rent - l_diff_amt;

       FOR rec IN prev_invoiced_tu_c(p_var_rent_id, p_period_id, inv_rec.invoice_date) LOOP
         l_prev_inv_exp := rec.prev_inv_trueup_amt;
       END LOOP;

       IF (inv_rec.true_up_exp_code = 'N') THEN
         --Last invoice is not exported
         UPDATE
         pn_var_rent_inv_all
         SET
         actual_invoiced_amount = (l_abated_rent - l_prev_inv_exp)
         ,actual_term_status    = 'N'
         ,last_update_date       = SYSDATE
         ,last_updated_by        = NVL(fnd_global.user_id,0)
         ,last_update_login      = NVL(fnd_global.login_id,0)
          WHERE
          var_rent_inv_id = inv_rec.var_rent_inv_id;
       ELSIF ((l_abated_rent - l_prev_inv_exp)<>0) THEN
         -- Last invoice has been exported and an non zero adjustment terms needs to be created
          FOR inv_all_rec IN inv_all_c(inv_rec.var_rent_inv_id) LOOP
          --This can loop only once
          pnp_debug_pkg.log('l_prev_inv_exp:'||l_prev_inv_exp);
          pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
          pnp_debug_pkg.log('Abatements - inserting');
          l_row_id := NULL;
          l_var_rent_inv_id := NULL;
          pn_var_rent_inv_pkg.insert_row
             ( x_rowid                   => l_row_id,
               x_var_rent_inv_id         => l_var_rent_inv_id,
               x_adjust_num              => inv_all_rec.adjust_num+1,
               x_invoice_date            => inv_all_rec.invoice_date,
               x_for_per_rent            => inv_all_rec.for_per_rent,
               x_tot_act_vol             => inv_all_rec.tot_act_vol,
               x_act_per_rent            => inv_all_rec.act_per_rent,
               x_constr_actual_rent      => inv_all_rec.constr_actual_rent,
               x_abatement_appl          => inv_all_rec.abatement_appl,
               x_rec_abatement           => inv_all_rec.rec_abatement,
               x_rec_abatement_override  => inv_all_rec.rec_abatement_override,
               x_negative_rent           => inv_all_rec.negative_rent,
               x_actual_invoiced_amount  => (l_abated_rent - l_prev_inv_exp),
               x_period_id               => inv_all_rec.period_id,
               x_var_rent_id             => inv_all_rec.var_rent_id,
               x_forecasted_term_status  => 'N',
               x_variance_term_status    => 'N',
               x_actual_term_status      => 'N',
               x_forecasted_exp_code     => 'N',
               x_variance_exp_code       => 'N',
               x_actual_exp_code         => 'N',
               x_comments                => 'created invoice',
               x_attribute_category      => NULL,
               x_attribute1              => NULL,
               x_attribute2              => NULL,
               x_attribute3              => NULL,
               x_attribute4              => NULL,
               x_attribute5              => NULL,
               x_attribute6              => NULL,
               x_attribute7              => NULL,
               x_attribute8              => NULL,
               x_attribute9              => NULL,
               x_attribute10             => NULL,
               x_attribute11             => NULL,
               x_attribute12             => NULL,
               x_attribute13             => NULL,
               x_attribute14             => NULL,
               x_attribute15             => NULL,
               x_creation_date           => SYSDATE,
               x_created_by              => NVL(fnd_global.user_id,0),
               x_last_update_date        => SYSDATE,
               x_last_updated_by         => NVL(fnd_global.user_id,0),
               x_last_update_login       => NVL(fnd_global.login_id,0),
               x_org_id                  => inv_all_rec.org_id );
         END LOOP;
       END IF;*/
       G_ABATED_RENT(G_ABATED_RENT.COUNT+1).period_id := p_period_id;
       G_ABATED_RENT(G_ABATED_RENT.COUNT).amount := l_abated_rent;
     END IF;

   END IF;
  END LOOP;--Loop for all required invoices.
  pnp_debug_pkg.log('apply_abatements end(-)');

EXCEPTION
   WHEN others THEN
   pnp_debug_pkg.log('Raised exception');
   RAISE;
END;



--------------------------------------------------------------------------------
--  NAME         : get_dated_allow
--  DESCRIPTION  : Gets allowances between specific dates.
--  PURPOSE      : Gets allowances between specific dates.
--  INVOKED FROM : apply_allow()
--  ARGUMENTS    : p_allow_t- table constaining all the allowances
--                 p_start_date -
--                 p_end_date - Dates between which to select the allowances.
--  REFERENCE    :
--  HISTORY      :
--  22/Dec/06 Shabda o Found while fixing bug 5724597.If no allowances exist,
--                     return a not null value.
--
--  25/Nov/2006      Shabda     o Created
--------------------------------------------------------------------------------
FUNCTION get_dated_allow(p_allow_t ALLOW_TBL,
                         p_start_date DATE,
                         p_end_date DATE) RETURN ALLOW_TBL IS
   l_allow_t ALLOW_TBL;
   l_count   NUMBER := 1;
   empty_rec       ALLOW_REC;
BEGIN
  --
  pnp_debug_pkg.log('get_dated_allow start (+)');
  IF (p_allow_t.COUNT > 0) THEN
    --
    FOR i IN  1..p_allow_t.COUNT LOOP
    pnp_debug_pkg.log('get_dated_allow 1');
    IF(p_allow_t(i).start_date <= p_end_date
    AND NVL(p_allow_t(i).end_date, p_end_date) >= p_start_date) THEN
       l_allow_t(l_count) := p_allow_t(i);
       l_count := l_count + 1;
    END IF;
    pnp_debug_pkg.log('get_dated_allow 2');
    END LOOP;
  END IF;
  pnp_debug_pkg.log('get_dated_allow 3');
  IF (l_allow_t.COUNT >0) THEN
      RETURN l_allow_t;
  ELSE
    --
    l_allow_t(1) := NULL;
    RETURN l_allow_t;
  END IF;
EXCEPTION
  WHEN others THEN
    pnp_debug_pkg.log('get_dated_allow raised exception');
    RAISE;
END;

--------------------------------------------------------------------------------
--  NAME         : apply_def_neg_rent
--  DESCRIPTION  : Applies deffered negative rent.
--  PURPOSE      : Applies deffered negative rent.
--  INVOKED FROM : apply_abatements()
--  ARGUMENTS    : p_var_rent_id: Vr to apply abatements for.
--                 p_period_id: Period to calculate for.
--                 p_inv_id: Invoice to calculate for.
--  REFERENCE    :
--  HISTORY      :
--
--  25/Nov/2006      Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE apply_def_neg_rent(p_var_rent_id IN NUMBER,
               p_period_id IN NUMBER,
               p_inv_id IN NUMBER,
               x_abated_rent IN OUT NOCOPY NUMBER) IS

  -- Get the details of all invoices
  CURSOR invoices_c(ip_var_rent_id NUMBER, ip_period_id NUMBER, ip_inv_id NUMBER
            ) IS
    SELECT  constr_actual_rent
            ,actual_invoiced_amount
            ,true_up_amt
            ,negative_rent
            ,invoice_date
            ,var_rent_inv_id
     FROM pn_var_rent_inv_all inv1
     WHERE inv1.var_rent_id = ip_var_rent_id
     AND inv1.period_id = ip_period_id
     AND var_rent_inv_id = ip_inv_id
     AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      WHERE inv1.var_rent_id = inv2.var_rent_id
      AND   inv1.period_id = inv2.period_id
      AND inv1.invoice_date = inv2.invoice_date);

  CURSOR csr_last_inv(p_var_rent_id NUMBER)
     IS
     SELECT MAX(invoice_date) inv_date
     FROM pn_var_grp_dates_all
     WHERE var_rent_id = p_var_rent_id
     AND period_id = (SELECT max(period_id)
                      FROM pn_var_periods_all
                      WHERE var_rent_id = p_var_rent_id
                      AND   NVL(status, pn_var_rent_calc_pkg.G_PERIOD_ACTIVE_STATUS)
                            <> pn_var_rent_calc_pkg.G_PERIOD_REVERSED_STATUS);

  CURSOR csr_neg_avail (ip_var_rent_id  NUMBER,
                        ip_invoice_date DATE) IS
     SELECT ABS(NVL(SUM(def_neg_rent),0)) negative_available
     FROM pn_var_rent_inv_all inv
     WHERE inv.var_rent_id = ip_var_rent_id
     --AND period_id = p_period_id
     AND   inv.invoice_date < ip_invoice_date
     AND   inv.adjust_num = (select MAX(inv1.adjust_num)
                             from pn_var_rent_inv_all inv1
                             where inv1.var_rent_id = inv.var_rent_id
                             AND   inv1.invoice_date = inv.invoice_date);

  CURSOR csr_neg_appl (ip_var_rent_id  NUMBER,
                       ip_invoice_date DATE) IS
     SELECT NVL(SUM(negative_rent),0) negative_applied
     FROM pn_var_rent_inv_all inv
     WHERE inv.var_rent_id = ip_var_rent_id
     --AND period_id = p_period_id
     AND   inv.invoice_date < ip_invoice_date
     AND   inv.adjust_num = (select MAX(inv1.adjust_num)
                             from pn_var_rent_inv_all inv1
                             where inv1.var_rent_id = inv.var_rent_id
                             AND   inv1.invoice_date = inv.invoice_date);
   CURSOR csr_get_abt(ip_var_rent_id NUMBER)
        IS
        SELECT negative_rent
        FROM pn_var_rents_all
        WHERE var_rent_id = ip_var_rent_id;


   l_negative_rent        pn_var_rent_inv.negative_rent%TYPE := 0;
   l_negative_available   NUMBER := 0;
   l_negative_applied     NUMBER := 0;
   l_negative_remaining   NUMBER;
   l_abated_rent          NUMBER;
   l_negative_rent_flag   pn_var_rents.negative_rent%TYPE;
   l_last_invoice_dt      pn_var_grp_dates.invoice_date%TYPE;
BEGIN
  pnp_debug_pkg.log('apply_def_neg_rent start(+)');
  -- Get the negative rent flag
  FOR rec IN csr_get_abt(p_var_rent_id) LOOP
      l_negative_rent_flag := rec.negative_rent;
      pnp_debug_pkg.log('l_negative_rent_flag:'||l_negative_rent_flag);
  END LOOP;
    -- Get the last invoice_date
  FOR rec IN csr_last_inv(p_var_rent_id) LOOP
     l_last_invoice_dt := rec.inv_date;
     pnp_debug_pkg.log('l_last_invoice_dt:'||l_last_invoice_dt);
  END LOOP;

  PNP_DEBUG_PKg.log('p_period_id:'||p_period_id);
  PNP_DEBUG_PKG.log('p_var_rent_id:'||p_var_rent_id);

  -- Loop for all invoices.
  FOR inv_rec IN invoices_c(p_var_rent_id, p_period_id, p_inv_id) LOOP
     pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);
     l_negative_rent := 0;
     l_negative_available := 0;
     l_negative_applied := 0;
     l_abated_rent :=inv_rec.constr_actual_rent;


     PNP_DEBUG_PKG.log('inv_rec.invoice_date:'||inv_rec.invoice_date);
     -- Get available negative rent.
     FOR rec IN csr_neg_avail(p_var_rent_id, inv_rec.invoice_date) LOOP
        l_negative_available :=rec.negative_available;
        pnp_debug_pkg.log('l_negative_available'||l_negative_available);
     END LOOP;

     -- Get applied negative rent
     FOR rec IN csr_neg_appl (p_var_rent_id, inv_rec.invoice_date) LOOP
        l_negative_applied := rec.negative_applied;
        pnp_debug_pkg.log('l_negative_applied:'||l_negative_applied);
     END LOOP;

     l_negative_remaining := ABS(l_negative_available - l_negative_applied);
     pnp_debug_pkg.log('l_negative_remaining:'||l_negative_remaining);
     IF (l_negative_rent_flag = pn_var_rent_calc_pkg.G_NEG_RENT_DEFER) THEN
       -- Deffered negative rent can be applied only when consT-rent >0
       IF (l_last_invoice_dt <> inv_rec.invoice_date AND inv_rec.constr_actual_rent > 0) THEN
         --This invoice is not the last invoice
         l_abated_rent := GREATEST(0, inv_rec.constr_actual_rent - l_negative_remaining);
         pnp_debug_pkg.log('l_abated_rent1:'||l_abated_rent);
         IF (inv_rec.constr_actual_rent > l_abated_rent) THEN
           l_negative_rent := inv_rec.constr_actual_rent - l_abated_rent;
         ELSE
           l_negative_rent := 0;
         END IF;


       ELSIF (l_last_invoice_dt = inv_rec.invoice_date) THEN
         --This is the last invoice. All deffered negative rent needs to be added
         l_abated_rent := inv_rec.constr_actual_rent - l_negative_remaining;
         pnp_debug_pkg.log('l_abated_rent2:'||l_abated_rent);
         l_negative_rent := inv_rec.constr_actual_rent - l_abated_rent;
       END IF;
     END IF;
     pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
     pnp_debug_pkg.log('l_negative_rent:'||l_negative_rent);
     pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);

     UPDATE pn_var_rent_inv_all
     SET negative_rent = l_negative_rent
     WHERE var_rent_inv_id = inv_rec.var_rent_inv_id;
     x_abated_rent := l_abated_rent;
  END LOOP;
  pnp_debug_pkg.log('apply_def_neg_rent end(-)');

EXCEPTION
  --
  WHEN others THEN
  pnp_debug_pkg.log('Raised exception');
    RAISE;
END;


--------------------------------------------------------------------------------
--  NAME         : populate_neg_rent
--  DESCRIPTION  : Populates the negative rent which needs to be deffered.
--  PURPOSE      : Populates the negative rent which needs to be deffered.
--  INVOKED FROM : apply_abatements()
--  ARGUMENTS    : p_var_rent_id: Vr to apply abatements for.
--                 p_period_id: Period to calculate for.
--                 p_inv_id: Invoice to calculate for.
--  REFERENCE    :
--  HISTORY      :
--
--  25/Nov/2006      Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_neg_rent(p_var_rent_id IN NUMBER,
               p_period_id IN NUMBER,
               p_inv_id IN NUMBER,
               x_abated_rent IN OUT NOCOPY NUMBER) IS

  -- Get the details of all invoices
  CURSOR invoices_c(ip_var_rent_id NUMBER, ip_period_id NUMBER, ip_inv_id NUMBER
            ) IS
    SELECT  invoice_date
            ,var_rent_inv_id
     FROM pn_var_rent_inv_all inv1
     WHERE inv1.var_rent_id = ip_var_rent_id
     AND inv1.period_id = ip_period_id
     AND var_rent_inv_id = ip_inv_id
     AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      WHERE inv1.var_rent_id = inv2.var_rent_id
      AND   inv1.period_id = inv2.period_id
      AND inv1.invoice_date = inv2.invoice_date);

  CURSOR csr_last_inv(p_var_rent_id NUMBER)
     IS
     SELECT MAX(invoice_date) inv_date
     FROM pn_var_grp_dates_all
     WHERE var_rent_id = p_var_rent_id
     AND period_id = (SELECT max(period_id)
                      FROM pn_var_periods_all
                      WHERE var_rent_id = p_var_rent_id
                      AND   NVL(status, pn_var_rent_calc_pkg.G_PERIOD_ACTIVE_STATUS)
                            <> pn_var_rent_calc_pkg.G_PERIOD_REVERSED_STATUS);


   CURSOR csr_get_abt(ip_var_rent_id NUMBER)
        IS
        SELECT negative_rent
        FROM pn_var_rents_all
        WHERE var_rent_id = ip_var_rent_id;

   l_neg_rent_def         NUMBER;
   l_negative_rent        pn_var_rent_inv.negative_rent%TYPE := 0;
   l_negative_available   NUMBER := 0;
   l_negative_applied     NUMBER := 0;
   l_negative_remaining   NUMBER;
   l_abated_rent          NUMBER;
   l_negative_rent_flag   pn_var_rents.negative_rent%TYPE;
   l_last_invoice_dt      pn_var_grp_dates.invoice_date%TYPE;
BEGIN
  pnp_debug_pkg.log('populate_neg_rent start(+)');
  -- Get the negative rent flag
  FOR rec IN csr_get_abt(p_var_rent_id) LOOP
      l_negative_rent_flag := rec.negative_rent;
      pnp_debug_pkg.log('l_negative_rent_flag:'||l_negative_rent_flag);
  END LOOP;
  -- Get the last invoice_date
  FOR rec IN csr_last_inv(p_var_rent_id) LOOP
     l_last_invoice_dt := rec.inv_date;
     pnp_debug_pkg.log('l_last_invoice_dt:'||l_last_invoice_dt);
  END LOOP;
  -- Loop for all invoices.
  FOR inv_rec IN invoices_c(p_var_rent_id, p_period_id, p_inv_id) LOOP
    IF (l_negative_rent_flag = pn_var_rent_calc_pkg.G_NEG_RENT_IGNORE) THEN
      --We are ignoring negative rents. Set abated rent =0, if <0.
      l_abated_rent := GREATEST(0, x_abated_rent);

    ELSIF (l_negative_rent_flag = pn_var_rent_calc_pkg.G_NEG_RENT_CREDIT) THEN
      l_abated_rent := x_abated_rent;
    ELSIF (l_negative_rent_flag = pn_var_rent_calc_pkg.G_NEG_RENT_DEFER
           AND inv_rec.invoice_date <> l_last_invoice_dt) THEN
      l_abated_rent := GREATEST(0,x_abated_rent);
      l_neg_rent_def := ABS(x_abated_rent - l_abated_rent);
    ELSIF (l_negative_rent_flag = pn_var_rent_calc_pkg.G_NEG_RENT_DEFER
           AND inv_rec.invoice_date = l_last_invoice_dt) THEN
      l_abated_rent := x_abated_rent;
    END IF;
    pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
    pnp_debug_pkg.log('l_neg_rent_def*:'||l_neg_rent_def);
    UPDATE pn_var_rent_inv_all
    SET def_neg_rent = l_neg_rent_def
    WHERE var_rent_inv_id = inv_rec.var_rent_inv_id;
    x_abated_rent := l_abated_rent;
  END LOOP;
  pnp_debug_pkg.log('populate_neg_rent end(-)');

EXCEPTION
  --
  WHEN others THEN
  pnp_debug_pkg.log('Raised exception');
    RAISE;
END;
--------------------------------------------------------------------------------
--  NAME         : apply_abat
--  DESCRIPTION  : applies the fixed and recurring abatements.
--  PURPOSE      : applies the fixed and recurring abatements.
--  INVOKED FROM : apply_abatements()
--  ARGUMENTS    : p_var_rent_id: Vr to apply abatements for.
--                 p_period_id: Period to calculate for.
--                 p_inv_id: Invoice to calculate for.
--  REFERENCE    :
--  HISTORY      :
--
--  25/Nov/2006      Shabda     o Created
--  6/Jan/2007       Shabda     o Bug 5731479. Use rec_override field.
--------------------------------------------------------------------------------
PROCEDURE apply_abat(p_var_rent_id IN NUMBER,
           p_period_id IN NUMBER,
           p_inv_id IN NUMBER,
           x_abated_rent IN OUT NOCOPY NUMBER) IS

  -- Get the details of all invoices
  CURSOR invoices_c(ip_var_rent_id NUMBER, ip_period_id NUMBER,
                    ip_inv_id NUMBER
            ) IS
    SELECT   actual_invoiced_amount
            ,invoice_date
            ,NVL(rec_abatement,0) rec_abatement
            ,rec_abatement_override
            ,true_up_amt
            ,var_rent_inv_id
     FROM pn_var_rent_inv_all inv1
     WHERE inv1.var_rent_id = ip_var_rent_id
     AND inv1.period_id = ip_period_id
     AND inv1.var_rent_inv_id = ip_inv_id
     AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
      AND   inv1.period_id = inv2.period_id
      AND inv1.invoice_date = inv2.invoice_date)
         AND TRUE_UP_AMT IS NULL
     UNION ALL
      SELECT
    (SELECT NVL(SUM(act_var_rent), 0)
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = ip_var_rent_id AND
    period_id = ip_period_id
    )   AS actual_invoiced_amount
    , invoice_date
    , null rec_abatement
    , null rec_abatement_override
    ,(SELECT NVL(SUM(act_var_rent), 0)
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = ip_var_rent_id AND
    period_id = ip_period_id
    )   AS true_up_amt
    ,NULL AS VAR_RENT_INV_ID
    FROM PN_VAR_RENT_SUMM_ALL
    WHERE ip_inv_id IS NULL
    AND var_rent_id = ip_var_rent_id
    AND period_id = ip_period_id
    AND group_date = (select max(group_date) from pn_var_rent_summ_all
    where period_id = ip_period_id)
    AND G_IS_TU_CONC_FLAG = 'T';


  -- Get the details of fixed abatements
  CURSOR fixed_abat_c(ip_var_rent_id NUMBER,
            ip_inv_start_date DATE,
            ip_inv_end_date DATE) IS
    SELECT NVL(SUM(amount),0) fixed_abat
    FROM PN_VAR_ABAT_DEFAULTS_ALL
    WHERE var_rent_id = ip_var_rent_id
    AND start_date <= ip_inv_end_date
    AND NVL(end_date, ip_inv_end_date) >= ip_inv_start_date
    AND type_code = pn_var_rent_calc_pkg.G_ABAT_TYPE_CODE_ABAT;
  -- Get the details of
  CURSOR EXCESS_ABAT_C(ip_var_rent_id NUMBER) IS
    SELECT EXCESS_ABAT_CODE
    FROM PN_VAR_RENTS_ALL ABAT
    WHERE abat.var_rent_id = ip_var_rent_id;
   -- Get the details of inv_start, end_date
  CURSOR invoice_dates_c(ip_var_rent_id NUMBER,
                         ip_invoice_date DATE
            ) IS
    SELECT inv_start_date, inv_end_date
    FROM pn_var_grp_dates_all
    WHERE var_rent_id = ip_var_rent_id
    AND invoice_date = ip_invoice_date;
  -- Get the details of actual start and end date for FY/LY/FLY
  CURSOR invoice_dates_fyly_c(ip_var_rent_inv_id NUMBER
            ) IS
    SELECT per.start_date, per.end_date
      FROM pn_var_rent_inv_all inv, pn_var_periods_all per
     WHERE per.period_id = inv.period_id
       AND inv.var_rent_inv_id = ip_var_rent_inv_id;

  -- Get the id of invoice created for first year.
  -- This has meaning only if proration is FY/FLY
  CURSOR get_fy_inv_c(ip_var_rent_id NUMBER
            ) IS
    SELECT inv.var_rent_inv_id
      FROM pn_var_rent_inv_all inv, pn_var_periods_all per
     WHERE per.period_id = inv.period_id
       AND inv.var_rent_id = ip_var_rent_id
       AND per.start_date = (SELECT MIN(start_date) from pn_var_periods_all
                             WHERE var_rent_id = ip_var_rent_id);
  -- Get the id of last invoice created.
  -- This has meaning only if proration is LY/FLY
  CURSOR get_ly_inv_c(ip_var_rent_id NUMBER
            ) IS
    SELECT inv.var_rent_inv_id
      FROM pn_var_rent_inv_all inv, pn_var_periods_all per
     WHERE per.period_id = inv.period_id
       AND inv.var_rent_id = ip_var_rent_id
       AND per.start_date = (SELECT MAX(start_date) from pn_var_periods_all
                             WHERE var_rent_id = ip_var_rent_id)
        AND inv.invoice_date = (SELECT MAX(invoice_date) FROM pn_var_rent_inv_all
                                WHERE var_rent_id = ip_var_rent_id)
        AND inv.true_up_amt is NULL;



    --Get the details of inv_start, end_date for TU
    CURSOR invoice_dates_tu_c(ip_var_rent_id NUMBER,
                         ip_period_id NUMBER
            ) IS
    SELECT MIN(inv_start_date)inv_start_date,
    MAX(inv_end_date) inv_end_date
    FROM pn_var_grp_dates_all
    WHERE var_rent_id = ip_var_rent_id
    AND period_id = ip_period_id;

    -- Get the details of negative_rent
    CURSOR neg_rent_c(ip_var_rent_id NUMBER
            ) IS
    SELECT negative_rent
    FROM pn_var_rents_all
    WHERE var_rent_id = ip_var_rent_id;

    -- Get the details of negative_rent
    CURSOR calc_freq_c(ip_var_rent_id NUMBER
            ) IS
    SELECT REPTG_FREQ_CODE
    FROM pn_var_rent_dates_all
    WHERE var_rent_id = ip_var_rent_id;

     -- Get the details of
     CURSOR inv_in_prd_c(ip_var_rent_id NUMBER,
                      ip_period_id   NUMBER
              ) IS
      SELECT  COUNT(UNIQUE(invoice_date)) num_inv
      FROM  pn_var_rent_inv_all
      WHERE  var_rent_id = ip_var_rent_id
      AND  period_id = ip_period_id;

      -- Get the number of inv which should exist for a period
      CURSOR num_inv_c(ip_var_rent_inv_id NUMBER
            ) IS
      SELECT ceil(months_between(per.end_date, per.start_date)/decode(vrd.invg_freq_code,'YR', 12, 'SA', 6, 'QTR', 3, 'MON', 1, 1)) num_inv
      FROM pn_var_rent_inv_all inv, pn_var_periods_all per, pn_var_rents_all vr, pn_var_rent_dates_all vrd
      WHERE per.period_id = inv.period_id
       AND inv.var_rent_inv_id = ip_var_rent_inv_id
       AND per.var_rent_id = vr.var_rent_id
       AND vrd.var_rent_id = vr.var_rent_id;

      --Get the last invoice of the last year
      CURSOR ly_min_inv_c(ip_vr_id NUMBER
            ) IS
       SELECT inv.invoice_date,
              inv.var_rent_inv_id,
              inv.period_id
       FROM pn_var_rents_all vr,
            pn_var_periods_all per,
            pn_var_rent_inv_all inv
       WHERE per.var_rent_id = vr.var_rent_id
       AND   inv.period_id = per.period_id
       AND per.start_date = (select max(start_date) from pn_var_periods_all per1
                               where per1.var_rent_id = vr.var_rent_id)
       AND inv.invoice_date = (select max(invoice_date) from pn_var_rent_inv_all inv1
                                where inv1.period_id = per.period_id)
       AND vr.var_rent_id = ip_vr_id;

       -- Get the proration type
       CURSOR proration_type_c(ip_var_rent_id NUMBER
            ) IS
       SELECT proration_rule
       FROM pn_var_rents_all
       WHERE var_rent_id = ip_var_rent_id;

     -- Get the details of
     CURSOR rec_abatement_c(ip_period_id NUMBER
               ) IS
       SELECT SUM(rec_abatement) AS AMOUNT
         FROM pn_var_rent_inv_all inv1
        WHERE period_id = ip_period_id
       AND inv1.adjust_num= (
        SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
              where inv1.var_rent_id = inv2.var_rent_id
              AND inv1.invoice_date = inv2.invoice_date
              AND true_up_amt IS NULL)
        AND true_up_amt IS NULL;

     -- Get the details of
     CURSOR get_rec_abat_over_tu_c(p_period_id NUMBER
               ) IS
       SELECT rec_abatement_override
         FROM pn_var_rent_inv_all
        WHERE period_id = p_period_id
          AND true_up_amt is NOT NULL
          AND adjust_num = (SELECT max(adjust_num)
                            FROM PN_VAR_RENT_INV_ALL
                            WHERE period_id = p_period_id
                            AND TRUE_UP_AMT IS NOT NULL);





  l_fixed_abat NUMBER := 0;
  l_rec_abat   NUMBER := 0;
  l_total_abat NUMBER;
  l_excess_abat VARCHAR2(30);
  l_abated_rent NUMBER;
  l_inv_start_date DATE;
  l_inv_end_date   DATE;
  l_neg_rent   VARCHAR2(30);
  l_grp_in_prd NUMBER; --Number of groups in this period
  l_unabated_rent NUMBER;
  l_abat_override NUMBER;
  l_proration_type VARCHAR2(30);
  l_first_inv_id   NUMBER;--inv_id of the first inv created
  l_last_inv_id    NUMBER;--inv_id of the last inv created
  l_months_in_inv NUMBER;
  l_num_inv       NUMBER := 1;
  l_ly_max_inv_id NUMBER;
  l_ly_max_prd_id NUMBER;

BEGIN
  --
  pnp_debug_pkg.log('apply_abat start(+)');
    --The special cases this needs to handle are
  -- FY: The FY invoice would have invoice_date of next period.
  -- LY: Non last invoices are dummy, last invoice corresponds to the whole period.
  -- FLY: Both LY and FLY
  -- Get the proration type
  FOR proration_rec IN proration_type_c(p_var_rent_id)  LOOP
    l_proration_type := proration_rec.proration_rule;
  END LOOP;
  pnp_debug_pkg.log('apply_abat start(+)');
  -- is this in ly first inv? No abatements should be applied to this invoice
  FOR ly_inv_rec IN ly_min_inv_c(p_var_rent_id) LOOP
    l_ly_max_inv_id := ly_inv_rec.var_rent_inv_id;
    l_ly_max_prd_id := ly_inv_rec.period_id;
  END LOOP;
  pnp_debug_pkg.log('l_ly_max_inv_id:'||l_ly_max_inv_id);
  pnp_debug_pkg.log('l_ly_max_prd_id:'||l_ly_max_prd_id);



  --For LY/FLY, if last period and not last invoice,
  -- Invoices are dummy. Return immdiately.
  IF (p_period_id = l_ly_max_prd_id AND NOT(p_inv_id = l_ly_max_inv_id) AND l_proration_type IN (pn_var_rent_calc_pkg.G_PRORUL_FLY, pn_var_rent_calc_pkg.G_PRORUL_LY) ) THEN
    pnp_debug_pkg.log('Ly invoice, not last - return immedietly');
    RETURN;
  END IF;
  FOR abat_rec IN EXCESS_ABAT_C(p_var_rent_id) LOOP
    l_excess_abat := abat_rec.excess_abat_code;
    pnp_debug_pkg.log('l_excess_abat:'||l_excess_abat);
    EXIT;
  END LOOP;

  -- Get the number of invoices in this period
  FOR inv_in_prd_rec IN inv_in_prd_c(p_var_rent_id, p_period_id) LOOP
    l_grp_in_prd := inv_in_prd_rec.num_inv;
    pnp_debug_pkg.log('l_grp_in_prd:'||l_grp_in_prd);
  END LOOP;
  --
  FOR neg_rec IN neg_rent_c(p_var_rent_id) LOOP
    l_neg_rent := neg_rec.negative_rent;
    pnp_debug_pkg.log('l_neg_rent:'||l_neg_rent);
  END LOOP;

  --
  FOR fy_rec IN get_fy_inv_c(p_var_rent_id) LOOP
     l_first_inv_id := fy_rec.var_rent_inv_id;
  END LOOP;

  --
  FOR ly_rec IN get_ly_inv_c(p_var_rent_id) LOOP
     l_last_inv_id := ly_rec.var_rent_inv_id;
    pnp_debug_pkg.log('l_last_inv_id:'||l_last_inv_id);
  END LOOP;

  FOR inv_rec IN invoices_c(p_var_rent_id , p_period_id, p_inv_id) LOOP
    -- update rec abatements.
    IF (inv_rec.true_up_amt IS NULL) THEN
      FOR inv_dates_rec IN invoice_dates_c(p_var_rent_id, inv_rec.invoice_date) LOOP
      l_inv_start_date := inv_dates_rec.inv_start_date;
      l_inv_end_date := inv_dates_rec.inv_end_date;
      END LOOP;


    pnp_debug_pkg.log('l_inv_end_date:'||l_inv_end_date);

     -- The special handling is if this is FL/LY special invoice and non true up.
     IF ((l_proration_type IN (pn_var_rent_calc_pkg.G_PRORUL_FY, pn_var_rent_calc_pkg.G_PRORUL_FLY) AND p_inv_id = l_first_inv_id)
        OR (l_proration_type IN (pn_var_rent_calc_pkg.G_PRORUL_LY, pn_var_rent_calc_pkg.G_PRORUL_FLY) AND p_inv_id = l_last_inv_id) ) THEN
       --
       FOR inv_rec IN invoice_dates_fyly_c(p_inv_id) LOOP
         l_inv_start_date := inv_rec.start_date;
         l_inv_end_date := inv_rec.end_date;
       END LOOP;
       --
       pnp_debug_pkg.log('FY/LY modified dates');
       pnp_debug_pkg.log('l_inv_start_date:'||l_inv_start_date);
       pnp_debug_pkg.log('l_inv_end_date:'||l_inv_end_date);
       FOR num_rec IN num_inv_c(p_inv_id) LOOP
          l_num_inv := num_rec.num_inv;
       END LOOP;
       pnp_debug_pkg.log('l_num_inv:'||l_num_inv);

    END IF;
    ELSIF (inv_rec.true_up_amt IS NOT NULL) THEN
      --
      FOR inv_dates_rec IN invoice_dates_tu_c(p_var_rent_id, p_period_id) LOOP
      l_inv_start_date := inv_dates_rec.inv_start_date;
      l_inv_end_date := inv_dates_rec.inv_end_date;
      END LOOP;
    END IF;

    l_rec_abat := inv_rec.rec_abatement;
    pnp_debug_pkg.log('l_rec_abat:'||l_rec_abat);

  IF (inv_rec.true_up_amt IS NOT NULL) THEN
    pnp_debug_pkg.log('zxc:');
    --
    FOR i IN 1..G_ABATEMENT_APPLIED.COUNT LOOP
        IF G_ABATEMENT_APPLIED(i).PERIOD_ID = p_period_id THEN
            l_rec_abat := NVL(G_ABATEMENT_APPLIED(i).AMOUNT, 0);
            pnp_debug_pkg.log('l_rec_abat:'||l_rec_abat);
        END IF;

    END LOOP;


  END IF;




    l_abat_override := inv_rec.rec_abatement_override;
    IF inv_rec.true_up_amt IS NOT NULL THEN
       --
       FOR rec_over_rec IN get_rec_abat_over_tu_c(p_period_id) LOOP
           l_abat_override := rec_over_rec.rec_abatement_override;
       END LOOP;

    END IF;

    pnp_debug_pkg.log('l_abat_override:'||l_abat_override);
    l_abated_rent := x_abated_rent;
    l_unabated_rent := x_abated_rent;
    pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
    pnp_debug_pkg.log('l_rec_abat:'||l_rec_abat);
    FOR rec IN fixed_abat_c(p_var_rent_id, l_inv_start_date, l_inv_end_date) LOOP
      IF (inv_rec.true_up_amt IS NULL) THEN
        --Fixed abatement is same sum of fixed abatement.
        l_fixed_abat := rec.fixed_abat * l_num_inv;
      ELSIF (inv_rec.true_up_amt IS NOT NULL) THEN
        --Fixed abatement is total * number of invoices
        l_fixed_abat := rec.fixed_abat * l_grp_in_prd;

      END IF;
      pnp_debug_pkg.log('l_fixed_abat:'||l_fixed_abat);
    END LOOP;
    l_total_abat := l_fixed_abat + l_rec_abat;
    IF (l_abat_override IS NOT NULL) THEN
      l_total_abat := l_abat_override;
    END IF;

    pnp_debug_pkg.log('l_total_abat:'||l_total_abat);
    IF (l_excess_abat = pn_var_rent_calc_pkg.G_EXC_ABAT_IGNORE
        AND x_abated_rent>0 )  THEN
      l_abated_rent := GREATEST(0, x_abated_rent - l_total_abat);
    ELSIF (l_excess_abat = pn_var_rent_calc_pkg.G_EXC_ABAT_NEG_RENT ) THEN
      l_abated_rent := x_abated_rent - l_total_abat;
    END IF;
    l_total_abat := l_unabated_rent - l_abated_rent;
    pnp_debug_pkg.log('total_abat_applied:'||l_total_abat);
    UPDATE pn_var_rent_inv_all
    SET rec_abatement = l_total_abat
    WHERE var_rent_inv_id = inv_rec.var_rent_inv_id;
    pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
    x_abated_rent := l_abated_rent;
    IF inv_rec.var_rent_inv_id IS NULL  THEN
       G_TOT_ABATEMENT(G_TOT_ABATEMENT.COUNT+1).period_id := p_period_id;
       G_TOT_ABATEMENT(G_TOT_ABATEMENT.COUNT).amount := l_total_abat;

    END IF;

  END LOOP;
  pnp_debug_pkg.log('apply_abat end(-)');

EXCEPTION
  --
  WHEN others THEN
  pnp_debug_pkg.log('apply_abat end(-)');
  RAISE;
END;
--------------------------------------------------------------------------------
--  NAME         : apply_allow
--  DESCRIPTION  : Applies the rolling allowance.
--  PURPOSE      : Applies the rolling allowance.
--  INVOKED FROM : apply_abatements()
--  ARGUMENTS    : p_var_rent_id: Vr to apply abatements for.
--                 p_period_id: Period to calculate for.
--                 p_inv_id: Invoice to calculate for.
--  REFERENCE    :
--  HISTORY      :
--
--  25/Nov/2006      Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE apply_allow(p_var_rent_id IN NUMBER,
                      p_period_id   IN NUMBER,
                      p_inv_id IN NUMBER,
                      p_allow_t IN ALLOW_TBL,
                      p_allow_tu_t IN ALLOW_TBL,
                      x_abated_rent IN OUT NOCOPY NUMBER
          ) IS
  -- Get the details of
  CURSOR  invoices_c(ip_var_rent_id NUMBER,
                     ip_period_id   NUMBER,
                     ip_inv_id      NUMBER
            ) IS
    SELECT  inv1.abatement_appl
           ,inv1.invoice_date
           ,inv1.var_rent_inv_id
           ,inv1.true_up_amt
    FROM pn_var_rent_inv_all inv1
    WHERE var_rent_id = ip_var_rent_id
    AND period_id = ip_period_id
    AND var_rent_inv_id = ip_inv_id
    AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
      AND   inv1.period_id = inv2.period_id
      AND inv1.invoice_date = inv2.invoice_date)
    AND TRUE_UP_AMT IS NULL
    UNION ALL
    SELECT
     0 abatement_appl
    , invoice_date
    , null var_rent_inv_id
    ,(SELECT NVL(SUM(act_var_rent), 0)
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = ip_var_rent_id AND
    period_id = ip_period_id
    )   AS true_up_amt
    FROM PN_VAR_RENT_SUMM_ALL
    WHERE ip_inv_id IS NULL
    AND var_rent_id = ip_var_rent_id
    AND period_id = ip_period_id
    AND group_date = (select max(group_date) from pn_var_rent_summ_all
    where period_id = ip_period_id)
    AND G_IS_TU_CONC_FLAG = 'T';

   -- Get the details of rolling allowance
  CURSOR rolling_allow_c(ip_var_rent_id NUMBER,
            ip_inv_start_date DATE,
            ip_inv_end_date DATE) IS
    SELECT NVL(amount, 0) rolling_allow
           ,allowance_applied allow_applied
           ,abatement_id
    FROM PN_VAR_ABAT_DEFAULTS_ALL
    WHERE var_rent_id = ip_var_rent_id
    AND start_date <= ip_inv_start_date
    AND NVL(end_date, ip_inv_end_date) >= ip_inv_end_date
    AND type_code = pn_var_rent_calc_pkg.G_ABAT_TYPE_CODE_ALLO
    ORDER BY start_date;
  -- Get the details of inv_start, end_date
  CURSOR invoice_dates_c(ip_var_rent_id NUMBER,
                         ip_invoice_date DATE
            ) IS
    SELECT inv_start_date, inv_end_date
    FROM pn_var_grp_dates_all
    WHERE var_rent_id = ip_var_rent_id
    AND invoice_date = ip_invoice_date;
  --Get the details of inv_start, end_date for TU
  CURSOR invoice_dates_tu_c(ip_var_rent_id NUMBER,
                         ip_period_id NUMBER
            ) IS
    SELECT MIN(inv_start_date)inv_start_date,
    MAX(inv_end_date) inv_end_date
    FROM pn_var_grp_dates_all
    WHERE var_rent_id = ip_var_rent_id
    AND period_id = ip_period_id;

  -- Get the details of actual start and end date for FY/LY/FLY
  CURSOR invoice_dates_fyly_c(ip_var_rent_inv_id NUMBER
            ) IS
    SELECT per.start_date, per.end_date
      FROM pn_var_rent_inv_all inv, pn_var_periods_all per
     WHERE per.period_id = inv.period_id
       AND inv.var_rent_inv_id = ip_var_rent_inv_id;
  -- Get the id of invoice created for first year.
  -- This has meaning only if proration is FY/FLY
  CURSOR get_fy_inv_c(ip_var_rent_id NUMBER
            ) IS
    SELECT inv.var_rent_inv_id
      FROM pn_var_rent_inv_all inv, pn_var_periods_all per
     WHERE per.period_id = inv.period_id
       AND inv.var_rent_id = ip_var_rent_id
       AND per.start_date = (SELECT MIN(start_date) from pn_var_periods_all
                             WHERE var_rent_id = ip_var_rent_id);
  -- Get the id of last invoice created.
  -- This has meaning only if proration is LY/FLY
  CURSOR get_ly_inv_c(ip_var_rent_id NUMBER
            ) IS
    SELECT inv.var_rent_inv_id
      FROM pn_var_rent_inv_all inv, pn_var_periods_all per
     WHERE per.period_id = inv.period_id
       AND inv.var_rent_id = ip_var_rent_id
       AND per.start_date = (SELECT MAX(start_date) from pn_var_periods_all
                             WHERE var_rent_id = ip_var_rent_id)
       AND inv.invoice_date = (SELECT MAX(invoice_date) from pn_var_rent_inv_all
                               WHERE var_rent_id = ip_var_rent_id);

  -- Get the proration type
  CURSOR proration_type_c(ip_var_rent_id NUMBER
            ) IS
    SELECT proration_rule
      FROM pn_var_rents_all
      WHERE var_rent_id = ip_var_rent_id;



  l_allow_remain        NUMBER;
  l_allow_applied       NUMBER;--Allowance applied from a specific allow
  l_allow_applied_inv   NUMBER;--Allowance applied for a invoice
  l_cur_abt_rent        NUMBER;--Keeps track of abt rent between allowances
  l_prev_abt_rent       NUMBER;--Keeps track of abt rent between allowances
  l_unabated_rent       NUMBER;
  l_inv_start_date      DATE;
  l_inv_end_date        DATE;
  l_allow_tu_t          ALLOW_TBL;
  l_allow_rec           ALLOW_REC;
  l_proration_type      VARCHAR2(30);
  l_first_inv_id        NUMBER;
  l_last_inv_id         NUMBER;


BEGIN
  pnp_debug_pkg.log('apply_allow start(+)');

  -- Special cases which need to be handled are
  -- FY/FLY first invoice AND LY/FLY last invoice.
  -- get first inv
  --
  FOR first_inv_rec IN get_fy_inv_c(p_var_rent_id) LOOP
    l_first_inv_id := first_inv_rec.var_rent_inv_id;
  END LOOP;

  FOR last_inv_rec IN get_ly_inv_c(p_var_rent_id) LOOP
    l_last_inv_id := last_inv_rec.var_rent_inv_id;
  END LOOP;

  --
  FOR vr_rec IN proration_type_c(p_var_rent_id) LOOP
    l_proration_type := vr_rec.proration_rule;
  END LOOP;

  FOR inv_rec IN invoices_c(p_var_rent_id, p_period_id, p_inv_id)  LOOP
    pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);
    l_allow_applied_inv := inv_rec.abatement_appl;
    pnp_debug_pkg.log('l_allow_applied_inv:'||l_allow_applied_inv);
    --
    IF (inv_rec.true_up_amt IS NULL) THEN
      -- Apply allowance to non cumm rents
      pnp_debug_pkg.log('Non true up invoice');
      FOR inv_dates_rec IN invoice_dates_c(p_var_rent_id, inv_rec.invoice_date) LOOP
      l_inv_start_date := inv_dates_rec.inv_start_date;
      l_inv_end_date := inv_dates_rec.inv_end_date;
      END LOOP;
      --Special FY/LY/FLY handling
      --If this invoice is FY/FLY and the first year
      --Or proration is LY/FLY and the last invoice
      IF ((l_proration_type IN (pn_var_rent_calc_pkg.G_PRORUL_FY, pn_var_rent_calc_pkg.G_PRORUL_FLY) AND p_inv_id = l_first_inv_id)
        OR (l_proration_type IN (pn_var_rent_calc_pkg.G_PRORUL_LY, pn_var_rent_calc_pkg.G_PRORUL_FLY) AND p_inv_id = l_last_inv_id) ) THEN
       --
        FOR inv_rec IN invoice_dates_fyly_c(p_inv_id) LOOP
          l_inv_start_date := inv_rec.start_date;
          l_inv_end_date := inv_rec.end_date;
        END LOOP;
      END IF;
      l_cur_abt_rent := x_abated_rent;
      l_prev_abt_rent := x_abated_rent;
      FOR allow_rec  IN rolling_allow_c(p_var_rent_id, l_inv_start_date, l_inv_end_date) LOOP
        --Allowances can only be applied if rent is >0
        IF (l_cur_abt_rent > 0) THEN
           pnp_debug_pkg.log('allow_rec.abatement_id'||allow_rec.abatement_id);
           l_allow_remain := allow_rec.rolling_allow -NVL(allow_rec.allow_applied,0);
           pnp_debug_pkg.log('l_allow_remain:'||l_allow_remain);
           l_cur_abt_rent := GREATEST(0,l_prev_abt_rent - l_allow_remain);
           pnp_debug_pkg.log('l_cur_abated_rent:'||l_cur_abt_rent);
           l_allow_applied := l_prev_abt_rent - l_cur_abt_rent;
           pnp_debug_pkg.log('l_allow_applied'||l_allow_applied);
           l_prev_abt_rent := l_cur_abt_rent;
           pnp_debug_pkg.log('l_prev_abt_rent:'||l_prev_abt_rent);
           l_allow_applied_inv := l_allow_applied_inv + l_allow_applied;
           pnp_debug_pkg.log('l_allow_applied_inv:'||l_allow_applied_inv);
           UPDATE pn_var_abat_defaults_all
           SET allowance_applied = NVL(allowance_applied,0)+l_allow_applied
           WHERE abatement_id = allow_rec.abatement_id;
        END IF;
      END LOOP;
      pnp_debug_pkg.log('l_cur_abt_rent:'||l_cur_abt_rent);
      UPDATE pn_var_rent_inv_all
      SET abatement_appl = l_allow_applied_inv
      WHERE var_rent_inv_id = inv_rec.var_rent_inv_id;
      x_abated_rent := l_cur_abt_rent;
      pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);

    ELSIF (inv_rec.true_up_amt IS NOT NULL)  THEN
      pnp_debug_pkg.log('true up invoice');
      -- Apply allowance to true up rents
      FOR inv_dates_rec IN invoice_dates_tu_c(p_var_rent_id, p_period_id) LOOP
        l_inv_start_date := inv_dates_rec.inv_start_date;
        l_inv_end_date := inv_dates_rec.inv_end_date;
      END LOOP;
      l_cur_abt_rent := x_abated_rent;
      l_prev_abt_rent := x_abated_rent;
      l_allow_tu_t := get_dated_allow(p_allow_tu_t, l_inv_start_date, l_inv_end_date);
      IF (l_allow_tu_t(1).abatement_id IS NULL) THEN
        --This will happen when there are now allowances. In this case we can skip
        --processing for this invoice.
        pnp_debug_pkg.log('No allowances for this invoice. Exit');
        RETURN;
      END IF;

      FOR  i IN l_allow_tu_t.FIRST..l_allow_tu_t.LAST LOOP
        --Allowances can only be applied if rent is >0
        l_allow_rec := l_allow_tu_t(i);
        IF (l_cur_abt_rent > 0) THEN
           pnp_debug_pkg.log('l_allow_rec.abatement_id'||l_allow_rec.abatement_id);
           l_allow_remain := l_allow_rec.rolling_allow -NVL(l_allow_rec.allow_applied,0);
           pnp_debug_pkg.log('l_allow_remain:'||l_allow_remain);
           l_cur_abt_rent := GREATEST(0,l_prev_abt_rent - l_allow_remain);
           pnp_debug_pkg.log('l_cur_abated_rent:'||l_cur_abt_rent);
           l_allow_applied := l_prev_abt_rent - l_cur_abt_rent;
           pnp_debug_pkg.log('l_allow_applied'||l_allow_applied);
           l_prev_abt_rent := l_cur_abt_rent;
           pnp_debug_pkg.log('l_prev_abt_rent:'||l_prev_abt_rent);
           l_allow_applied_inv := l_allow_applied_inv + l_allow_applied;
           pnp_debug_pkg.log('l_allow_applied_inv:'||l_allow_applied_inv);
           l_allow_tu_t(i).allow_applied := NVL(l_allow_tu_t(i).allow_applied,0)+l_allow_applied;
        END IF;
      END LOOP;
    pnp_debug_pkg.log('l_cur_abt_rent:'||l_cur_abt_rent);
    G_ALLOWANCE_APPLIED(G_ALLOWANCE_APPLIED.COUNT+1).period_id := p_period_id;
    G_ALLOWANCE_APPLIED(G_ALLOWANCE_APPLIED.COUNT).amount := l_allow_applied_inv;
    pnp_debug_pkg.log('***l_allow_applied_inv:'||l_allow_applied_inv);


    x_abated_rent := l_cur_abt_rent;
    --Whenever we have true up invoice, we need to reset allowances.
    --
    FOR i IN l_allow_tu_t.FIRST..l_allow_tu_t.LAST LOOP
      UPDATE pn_var_abat_defaults_all
      SET allowance_applied = l_allow_tu_t(i).allow_applied
      WHERE abatement_id = l_allow_tu_t(i).abatement_id;
    END LOOP;

    pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);
    END IF;

  END LOOP;
  pnp_debug_pkg.log('apply_allow end(-)');
EXCEPTION
  WHEN others THEN
    RAISE;
END;


--------------------------------------------------------------------------------
--  NAME         : populate_abat
--  DESCRIPTION  : Populates the recurring abatements to abte in
--                 pn_var_rent_inv_all.rec_abatement.
--  PURPOSE      :
--  INVOKED FROM : apply_abatements()
--  ARGUMENTS    : p_var_rent_id: Vr to apply abatements for.
--                 p_period_id: Period to calculate for.
--                 p_inv_id: Invoice to calculate for.
--  REFERENCE    :
--  HISTORY      :
--
--  25/Nov/2006      Shabda     o Created
--  29/may/07        Shabda     o Bug 6041521- call overloaded calc_abatement
--------------------------------------------------------------------------------
PROCEDURE populate_abat(p_var_rent_id IN NUMBER,
           p_period_id IN NUMBER,
           p_inv_id IN NUMBER) IS

     -- Get the details of all invoices
  CURSOR invoices_c(ip_var_rent_id NUMBER, ip_period_id NUMBER,
                     ip_inv_id NUMBER
            ) IS
    SELECT   invoice_date
            ,true_up_amt
            ,var_rent_inv_id
     FROM pn_var_rent_inv_all inv1
     WHERE inv1.var_rent_id = ip_var_rent_id
     AND inv1.period_id = ip_period_id
     AND var_rent_inv_id = ip_inv_id
     AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
      AND inv1.invoice_date = inv2.invoice_date)
    AND TRUE_UP_AMT IS NULL
    UNION ALL
    SELECT
    invoice_date
    ,(SELECT NVL(SUM(act_var_rent), 0)
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = ip_var_rent_id AND
    period_id = ip_period_id
    )   AS true_up_amt
    ,null var_rent_inv_id
    FROM PN_VAR_RENT_SUMM_ALL
    WHERE ip_inv_id IS NULL
    AND var_rent_id = ip_var_rent_id
    AND period_id = ip_period_id
    AND group_date = (select max(group_date) from pn_var_rent_summ_all
    where period_id = ip_period_id)
    AND G_IS_TU_CONC_FLAG = 'T';

      --Get the last and first invoice dates for this period.
      CURSOR csr_min_gd(ip_var_rent_id NUMBER, ip_period_id NUMBER) IS
      SELECT MIN(grp_start_date) min_date
      FROM pn_var_grp_dates_all
      WHERE period_id = ip_period_id
      AND var_rent_id = ip_var_rent_id;

      CURSOR csr_max_gd(ip_var_rent_id NUMBER, ip_period_id NUMBER) IS
      SELECT MAX(grp_end_date) max_date
      FROM pn_var_grp_dates_all
      WHERE period_id = ip_period_id
      AND var_rent_id = ip_var_rent_id;

   CURSOR get_first_tu_c(ip_period_id NUMBER
             ) IS
     SELECT  var_rent_inv_id
       FROM  pn_var_rent_inv_all
      WHERE  period_id = ip_period_id
        AND  true_up_amt is NOT NULL
        AND  adjust_num = 0;


      l_min_grp_date DATE;
      l_max_grp_date DATE;
      l_rec_abatement NUMBER;
      l_exists_period BOOLEAN := FALSE;
      l_tu_inv_id     NUMBER;

BEGIN

  FOR inv_rec IN invoices_c(p_var_rent_id , p_period_id, p_inv_id) LOOP
    -- get the first grp date for this period
    IF (inv_rec.true_up_amt IS NOT NULL) THEN

      --
      FOR rec IN get_first_tu_c(p_period_id) LOOP
         l_tu_inv_id := rec.var_rent_inv_id;
         pnp_debug_pkg.log('l_tu_inv_id:'||l_tu_inv_id);

      END LOOP;

      --Populate for TU
      FOR min_rec IN csr_min_gd(p_var_rent_id , p_period_id) LOOP
        l_min_grp_date := min_rec.min_date;
      END LOOP;

       FOR max_rec IN csr_max_gd(p_var_rent_id , p_period_id) LOOP
        l_max_grp_date := max_rec.max_date;
      END LOOP;
      l_rec_abatement := pn_var_abatement_amount_pkg.calc_abatement(
                         p_var_rent_id
			 ,p_period_id
                         ,l_tu_inv_id
                         ,l_min_grp_date
                         ,l_max_grp_date
			 ,'Y');
    G_ABATEMENT_APPLIED(G_ABATEMENT_APPLIED.COUNT+1).period_id := p_period_id;
    G_ABATEMENT_APPLIED(G_ABATEMENT_APPLIED.COUNT).amount := l_rec_abatement;
    pnp_debug_pkg.log('G_ABATEMENT_APPLIED(G_ABATEMENT_APPLIED.COUNT).period_id'||G_ABATEMENT_APPLIED(G_ABATEMENT_APPLIED.COUNT).period_id);
    pnp_debug_pkg.log('G_ABATEMENT_APPLIED(G_ABATEMENT_APPLIED.COUNT).amount'||G_ABATEMENT_APPLIED(G_ABATEMENT_APPLIED.COUNT).amount);

    --
/*    FOR i IN 1..G_REC_ABATEMENT.COUNT LOOP
       IF G_REC_ABATEMENT(i).PERIOD_ID = p_period_id THEN
          G_REC_ABATEMENT(i).AMOUNT = G_REC_ABATEMENT(i).AMOUNT +  l_rec_abatement;
          l_exists_period := TRUE:
       END IF;

    END LOOP;

    IF NOT l_exists_period  THEN
          G_REC_ABATEMENT(G_REC_ABATEMENT.COUNT+1).period_id := p_period_id;
          G_REC_ABATEMENT(G_REC_ABATEMENT.COUNT).AMOUNT := l_rec_abatement;
    END IF;*/


    ELSE
      --Populate for non cumulative. Just call the normal populate_abat
      pn_var_rent_calc_pkg.populate_abat(p_var_rent_id, p_period_id, p_inv_id);

    END IF;
  END LOOP;

EXCEPTION
  --
  WHEN others THEN
  RAISE;
END;

--------------------------------------------------------------------------------
--  NAME         : reset_abatements
--  DESCRIPTION  : Resets the allowance applied for each invoice, allowance.
--                 This needs to be called between subsequent calls
--                 to apply_abatements.
--  PURPOSE      : resets the allowances.
--  INVOKED FROM : apply_abatements()
--  ARGUMENTS    : p_var_rent_id: Vr to apply abatements for.
--                 p_period_id: Period to calculate for.
--                 p_inv_id: Invoice to calculate for.
--  REFERENCE    :
--  HISTORY      :
--
--  25/Nov/2006      Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE reset_abatements(p_var_rent_id IN NUMBER
          ) IS
BEGIN
  pnp_debug_pkg.log('Reset_abatement start(+)');
  UPDATE pn_var_abat_defaults_all
  SET allowance_applied =0
  WHERE var_rent_id = p_var_rent_id;
  UPDATE pn_var_rent_inv_all
  SET abatement_appl =0
  WHERE var_rent_id = p_var_rent_id;
  pnp_debug_pkg.log('Reset_abatement end(-)');

EXCEPTION
  WHEN others THEN
  RAISE;
END;



--------------------------------------------------------------------------------
--  NAME         : calculate_trueup
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--  23/05/07     Lokesh   o Modified for bug # 6031202, added rounding off for
--                          TRUEUP_RENT_DUE
--  22/12/2009   jsundara o Bug#9117652 Consider Deductions while calculating l_net_trueup_volume
--------------------------------------------------------------------------------
PROCEDURE calculate_trueup( p_var_rent_id IN NUMBER
                           ,p_prd_date    IN DATE)
IS

  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     proration_rule
    ,cumulative_vol
    ,negative_rent
    ,commencement_date
    ,termination_date
    ,org_id
    FROM
    pn_var_rents_all
    WHERE
    var_rent_id = p_vr_id;

  l_vr_start_date  DATE;
  l_vr_end_date    DATE;
  l_proration_rule VARCHAR2(30);
  l_calc_method    VARCHAR2(30);
  l_org_id         pn_var_rents_all.org_id%TYPE;

  CURSOR periods_c( p_vr_id IN NUMBER
                   ,p_date  IN DATE) IS
    SELECT
     org_id
    ,period_id
    ,start_date
    ,end_date
    ,partial_period
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    end_date <= p_prd_date
    AND    NVL(status, pn_var_rent_calc_pkg.G_PERIOD_ACTIVE_STATUS)
      <> pn_var_rent_calc_pkg.G_PERIOD_REVERSED_STATUS;

  -- Get the details of periods to calculate abatements for.
  -- We need to calculate abatements for all periods.
  -- The idea is that True up calc runs from start to a specific period
  -- So we need to run abatements till that period. Now the abatements after that
  -- periods might have changed so we need to apply_abatements to subsequent periods.
  CURSOR periods_abat_c(ip_var_rent_id NUMBER
          ) IS
   SELECT period_id
   FROM   pn_var_periods_all
   WHERE  var_rent_id = ip_var_rent_id
   AND    NVL(status, pn_var_rent_calc_pkg.G_PERIOD_ACTIVE_STATUS)
      <> pn_var_rent_calc_pkg.G_PERIOD_REVERSED_STATUS;



  l_prd_counter NUMBER;

  /* get line items for a period */
  CURSOR lines_c( p_vr_id IN NUMBER
                 ,p_prd_id IN NUMBER) IS
    SELECT
    line_item_id
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id
    GROUP BY
    line_item_id;

  /* get the dates when we need to create the trueup invoice */
  CURSOR trueup_trx_c( p_vr_id   IN NUMBER
                      ,p_prd_id  IN NUMBER
                      ,p_line_id IN NUMBER) IS
    SELECT
     MIN(calc_prd_start_date)  AS trueup_start_date
    ,MAX(calc_prd_end_date)    AS trueup_end_date
    ,reset_group_id
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    line_item_id = p_line_id
    GROUP BY
    reset_group_id
    ORDER BY
    trueup_start_date;

  /* get YTD sales for the gives calc prd end date */
  CURSOR ytd_sales_c( p_vr_id   IN NUMBER
                     ,p_prd_id  IN NUMBER
                     ,p_line_id IN NUMBER
                     ,p_end_dt  IN DATE) IS
    SELECT
    ytd_sales,
    ytd_deductions  -- Bug#9117652
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    line_item_id = p_line_id AND
    calc_prd_end_date = p_end_dt;

  l_net_trueup_volume NUMBER;
  l_tot_trueup_rent   NUMBER;
  l_line_trueup_rent  NUMBER;
  l_part_trueup_rent  NUMBER;

  /* get the bkpts for trueup */
  CURSOR trueup_bkpt_c( p_vr_id        IN NUMBER
                       ,p_prd_id       IN NUMBER
                       ,p_line_id      IN NUMBER
                       ,p_reset_grp_id IN NUMBER
                       ,p_end_dt       IN DATE) IS
    SELECT
     ytd_group_vol_start AS trueup_bkpt_vol_start
    ,ytd_group_vol_end   AS trueup_bkpt_vol_end
    ,bkpt_rate
    FROM
    pn_var_trx_details_all
    WHERE
    trx_header_id IN (SELECT
                      trx_header_id
                      FROM
                      pn_var_trx_headers_all
                      WHERE
                      var_rent_id = p_vr_id AND
                      period_id = p_prd_id AND
                      line_item_id = p_line_id AND
                      reset_group_id = p_reset_grp_id AND
                      calc_prd_end_date = p_end_dt)
    ORDER BY
    trueup_bkpt_vol_start;

  TYPE TRUEUP_BKPT_TBL IS TABLE OF trueup_bkpt_c%ROWTYPE INDEX BY BINARY_INTEGER;

  trueup_bkpt_t TRUEUP_BKPT_TBL;

  CURSOR bkpt_type_c( p_line_id  IN NUMBER
                     ,p_start_dt IN DATE
                     ,p_end_dt   IN DATE) IS
    SELECT
     bkhd.bkpt_header_id
    ,bkhd.breakpoint_type
    FROM
    pn_var_bkpts_head_all bkhd
    WHERE
    bkhd.line_item_id = p_line_id AND
    bkhd_start_date <= p_end_dt AND
    bkhd_end_date >= p_start_dt;


  l_bkpt_type  VARCHAR2(30);
  l_bkpt_start NUMBER;
  l_bkpt_end   NUMBER;
  l_neg_rent_flag VARCHAR2(30);

BEGIN

  pnp_debug_pkg.log('+++++ calculate_trueup - START +++++');
  pnp_debug_pkg.log(' ');

  FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP

    l_proration_rule := vr_rec.proration_rule;
    l_calc_method    := vr_rec.cumulative_vol;
    l_vr_start_date  := vr_rec.commencement_date;
    l_vr_end_date    := vr_rec.termination_date;
    l_neg_rent_flag  := vr_rec.negative_rent;
    l_org_id         := vr_rec.org_id;

  END LOOP;

  g_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(l_org_id),4);

  l_prd_counter := 0;

  /* loop for all periods ending before p_prd_date */
  FOR prd_rec IN periods_c( p_vr_id => p_var_rent_id
                           ,p_date  => p_prd_date)
  LOOP

    l_prd_counter := l_prd_counter + 1;

    pnp_debug_pkg.log('Period Details: ');
    pnp_debug_pkg.log('      Period #    : '||l_prd_counter);
    pnp_debug_pkg.log('      Period Start: '||prd_rec.start_date);
    pnp_debug_pkg.log('      Period End  : '||prd_rec.end_date);
    pnp_debug_pkg.log(' ');

    /* init the trueup rent for the period */
    l_tot_trueup_rent := 0;
    --TODO
    G_ABATEMENT_APPLIED.DELETE;
    G_ALLOWANCE_APPLIED.DELETE;
    G_ABATED_RENT.DELETE;
    G_UNABATED_RENT.DELETE;
    G_TOT_ABATEMENT.DELETE;

    /* check if we need to calculate TRUE UP */
    IF prd_rec.start_date = l_vr_start_date AND
       l_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_FY
                            ,pn_var_rent_calc_pkg.G_PRORUL_FLY
                            ,pn_var_rent_calc_pkg.G_PRORUL_CYP
                            ,pn_var_rent_calc_pkg.G_PRORUL_CYNP) AND
       prd_rec.partial_period = 'Y'
    THEN

      /* no true up for the first partial in case of
         FY, FLY, CYP, CYNP
      */
      NULL;

    ELSIF prd_rec.end_date = l_vr_end_date AND
          l_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_LY
                               ,pn_var_rent_calc_pkg.G_PRORUL_FLY) AND
          prd_rec.partial_period = 'Y'
    THEN

      /* no true up for the last partial in case of
         LY, FLY
      */
      NULL;

    ELSIF pn_var_trueup_pkg.can_do_trueup
          ( p_var_rent_id => p_var_rent_id
           ,p_period_id   => prd_rec.period_id)
    THEN
      /* no true up if calculation not done for all invoiceing periods
         assuming all invoicing periods will have some sales populated
         - need to validate this
      */

      /* loop for all lines in the period */
      FOR line_rec IN lines_c ( p_vr_id  => p_var_rent_id
                               ,p_prd_id => prd_rec.period_id) LOOP

        /* re init the TRUEUP amount */
        UPDATE
        pn_var_trx_headers_all
        SET
        trueup_rent_due = 0
        WHERE
        var_rent_id = p_var_rent_id AND
        period_id = prd_rec.period_id AND
        line_item_id = line_rec.line_item_id;

        /* now start re-calculating the TRUEUP again */
        l_line_trueup_rent := 0;

        /* loop for all resets for a line */
        FOR trueup_rec IN trueup_trx_c( p_vr_id   => p_var_rent_id
                                       ,p_prd_id  => prd_rec.period_id
                                       ,p_line_id => line_rec.line_item_id)
        LOOP

          l_part_trueup_rent := 0;

          /* get YTD sales for trueup_rec.trueup_end_date */
          FOR sales_rec IN ytd_sales_c( p_vr_id   => p_var_rent_id
                                       ,p_prd_id  => prd_rec.period_id
                                       ,p_line_id => line_rec.line_item_id
                                       ,p_end_dt  => trueup_rec.trueup_end_date)
          LOOP
            l_net_trueup_volume := NVL(sales_rec.ytd_sales,0)-NVL(sales_rec.ytd_deductions,0); -- Bug#9117652
          END LOOP; /* get YTD sales for trueup_rec.trueup_end_date */

          IF l_net_trueup_volume <> 0 THEN

            /* get bkpts */
            trueup_bkpt_t.DELETE;

            OPEN trueup_bkpt_c( p_vr_id        => p_var_rent_id
                               ,p_prd_id       => prd_rec.period_id
                               ,p_line_id      => line_rec.line_item_id
                               ,p_reset_grp_id => trueup_rec.reset_group_id
                               ,p_end_dt       => trueup_rec.trueup_end_date);
            FETCH trueup_bkpt_c BULK COLLECT INTO trueup_bkpt_t;
            CLOSE trueup_bkpt_c; /* get bkpts */

            IF trueup_bkpt_t.COUNT > 0 THEN

              FOR bkpt_hdr_rec IN bkpt_type_c ( p_line_id  => line_rec.line_item_id
                                               ,p_start_dt => trueup_rec.trueup_start_date
                                               ,p_end_dt   => trueup_rec.trueup_end_date)
              LOOP
                l_bkpt_type := bkpt_hdr_rec.breakpoint_type;
              END LOOP;

              /* net volume trips any bkpt? */
              IF l_net_trueup_volume < trueup_bkpt_t(1).trueup_bkpt_vol_start THEN

                /* this is the functionality that exists today
                   does not exist in Macerich code
                   Once no breakpoints are tripped, Macerich consider the rent to be = 0 */
                /*Well no, because in case of true up the non cumulative calculations can be negative,
                but the true up calculations which are similar to cumulative can not be.
                They are not even deferred. - Shabda*/

                IF (l_neg_rent_flag = 'IGNORE')  THEN
                    l_part_trueup_rent := 0;
                ELSE
                    l_part_trueup_rent
                      := (l_net_trueup_volume - trueup_bkpt_t(1).trueup_bkpt_vol_start)
                      * trueup_bkpt_t(1).bkpt_rate;
                END IF;





              /* net volume trips any bkpt? - YES */
              ELSE

                /* get rent based on breakpoint type */
                IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_STRATIFIED
                THEN

                  l_part_trueup_rent := 0;

                  /* loop for all bkpt details */
                  FOR i IN trueup_bkpt_t.FIRST..trueup_bkpt_t.LAST LOOP

                    l_bkpt_start := trueup_bkpt_t(i).trueup_bkpt_vol_start;
                    l_bkpt_end   := trueup_bkpt_t(i).trueup_bkpt_vol_end;

                    IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
                      l_bkpt_end := NULL;
                    END IF;

                    /* net vol > bkpt start */
                    IF l_net_trueup_volume >= l_bkpt_start THEN

                      IF l_net_trueup_volume
                         <= NVL(l_bkpt_end, l_net_trueup_volume)
                      THEN

                        l_part_trueup_rent
                        := l_part_trueup_rent
                           + (l_net_trueup_volume - l_bkpt_start)
                              * trueup_bkpt_t(i).bkpt_rate;

                      ELSIF l_net_trueup_volume > l_bkpt_end THEN

                        l_part_trueup_rent
                        := l_part_trueup_rent
                           + (l_bkpt_end - l_bkpt_start)
                              * trueup_bkpt_t(i).bkpt_rate;

                      END IF;

                    ELSE

                      EXIT;

                    END IF; /* net vol > bkpt start */

                  END LOOP; /* loop for all bkpt details */

                ELSIF l_bkpt_type IN ( pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT
                                      ,pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING)
                THEN

                  /* loop for all bkpt details */
                  FOR i IN trueup_bkpt_t.FIRST..trueup_bkpt_t.LAST LOOP

                    l_bkpt_start := trueup_bkpt_t(i).trueup_bkpt_vol_start;
                    l_bkpt_end   := trueup_bkpt_t(i).trueup_bkpt_vol_end;

                    IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
                      l_bkpt_end := NULL;
                    END IF;

                    IF l_net_trueup_volume >= l_bkpt_start AND
                       l_net_trueup_volume <= NVL(l_bkpt_end, l_net_trueup_volume)
                    THEN

                      IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING THEN

                        l_part_trueup_rent
                        := l_net_trueup_volume * trueup_bkpt_t(i).bkpt_rate;

                      ELSIF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT THEN

                        l_part_trueup_rent
                        := (l_net_trueup_volume - l_bkpt_start)
                            * trueup_bkpt_t(i).bkpt_rate;

                      END IF;

                      EXIT;

                    END IF;

                  END LOOP; /* loop for all bkpt details */

                END IF; /* get rent based on breakpoint type */

              END IF; /* net volume trips any bkpt? */

            END IF; /* IF trueup_bkpt_t.COUNT > 0 THEN */

          END IF; /* IF l_net_trueup_volume <> 0 THEN */

          pnp_debug_pkg.log('');
          /* update the line trueup rent */
          l_line_trueup_rent := l_line_trueup_rent + l_part_trueup_rent;

          pnp_debug_pkg.log(' part_trueup_rent: '||l_part_trueup_rent);
          pnp_debug_pkg.log(' ');

        END LOOP; /* loop for all resets for a line */

        l_tot_trueup_rent := l_tot_trueup_rent + l_line_trueup_rent;

        UPDATE
        pn_var_trx_headers_all
        SET
        trueup_rent_due = round(l_line_trueup_rent,g_precision)
        WHERE
        var_rent_id = p_var_rent_id AND
        period_id = prd_rec.period_id AND
        line_item_id = line_rec.line_item_id AND
        calc_prd_end_date = prd_rec.end_date;

        pnp_debug_pkg.log(' line_trueup_rent: '||l_line_trueup_rent);
        pnp_debug_pkg.log(' ');

      END LOOP; /* loop for all lines in the period */

      pnp_debug_pkg.log(' tot_trueup_rent for Period : '||l_tot_trueup_rent);
      pnp_debug_pkg.log(' ');
      pn_var_trueup_pkg.post_summary_trueup
        ( p_var_rent_id    => p_var_rent_id
         ,p_period_id      => prd_rec.period_id
         ,p_proration_rule => l_proration_rule);

    END IF; /* check if we need to calculate TRUE UP */

  --Rest the abatements, and reapply them.
  pn_var_rent_calc_pkg.reset_abatements(p_var_rent_id);

  END LOOP;

 FOR period_rec IN periods_abat_c(p_var_rent_id) LOOP
    apply_abatements(p_var_rent_id,
                     period_rec.period_id,
                     'CALCULATE');
  END LOOP;

  FOR prd_rec IN periods_c( p_vr_id => p_var_rent_id
                           ,p_date  => p_prd_date) LOOP

    IF NOT ((prd_rec.start_date = l_vr_start_date AND
       l_proration_rule IN (pn_var_rent_calc_pkg.G_PRORUL_CYP
                           ,pn_var_rent_calc_pkg.G_PRORUL_CYNP
			   ,pn_var_rent_calc_pkg.G_PRORUL_FY
			   ,pn_var_rent_calc_pkg.G_PRORUL_FLY) AND
	     prd_rec.partial_period = 'Y')
       OR (prd_rec.end_date = l_vr_end_date AND
       l_proration_rule IN (pn_var_rent_calc_pkg.G_PRORUL_LY
			   ,pn_var_rent_calc_pkg.G_PRORUL_FLY) AND
          prd_rec.partial_period = 'Y'))
    THEN
       pn_var_trueup_pkg.insert_invoice_trueup
          ( p_var_rent_id => p_var_rent_id
           ,p_period_id   => prd_rec.period_id);
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END calculate_trueup;

--------------------------------------------------------------------------------
--  NAME         : trueup_batch_process
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE trueup_batch_process( errbuf           OUT NOCOPY VARCHAR2
                               ,retcode          OUT NOCOPY VARCHAR2
                               ,p_property_code  IN VARCHAR2
                               ,p_lease_num_low  IN VARCHAR2
                               ,p_lease_num_high IN VARCHAR2
                               ,p_vr_num_low     IN VARCHAR2
                               ,p_vr_num_high    IN VARCHAR2
                               ,p_date           IN VARCHAR2)
IS

  l_lease_num_low  VARCHAR2(30);
  l_lease_num_high VARCHAR2(30);
  l_vr_num_low     VARCHAR2(30);
  l_vr_num_high    VARCHAR2(30);
  l_date           DATE;

  /* get the VR to do trueup for */
  CURSOR get_vr_c IS
    SELECT
     vr.var_rent_id
    FROM
     pn_leases_all    lease
    ,pn_var_rents_all vr
    WHERE
    vr.cumulative_vol = 'T' AND
    vr.lease_id = lease.lease_id AND
    lease.lease_num BETWEEN l_lease_num_low AND l_lease_num_high AND
    vr.rent_num BETWEEN l_vr_num_low AND l_vr_num_high
    ORDER BY
    vr.rent_num;

  /* get the VR to do trueup for - used when property code is passed */
  CURSOR get_vr_prop_c(p_building_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    FROM
     pn_leases_all    lease
    ,pn_var_rents_all vr
    WHERE
    vr.cumulative_vol = pn_var_rent_calc_pkg.G_CALC_TRUE_UP AND
    vr.lease_id = lease.lease_id AND
    lease.lease_num BETWEEN l_lease_num_low AND l_lease_num_high AND
    vr.rent_num BETWEEN l_vr_num_low AND l_vr_num_high AND
    vr.location_id IN
      (SELECT
       location_id
       FROM
       pn_locations_all
       START WITH location_id = p_building_id
       CONNECT BY PRIOR location_id = parent_location_id)
    ORDER BY
    vr.rent_num;

  CURSOR get_buildings_c(p_prop_code IN VARCHAR2) IS
    SELECT DISTINCT
    loc.location_id
    FROM
     pn_locations_all loc
    ,pn_properties_all prop
    WHERE
    loc.property_id = prop.property_id AND
    prop.property_code = p_prop_code;

BEGIN
   pnp_debug_pkg.log('+++*process_trueup_batch*++++++');
  /* init */
  IF p_lease_num_low IS NOT NULL THEN
    l_lease_num_low := p_lease_num_low;
  ELSE
    l_lease_num_low := ' ';
  END IF;

  IF p_lease_num_high IS NOT NULL THEN
    l_lease_num_high := p_lease_num_high;
  ELSE
    BEGIN
      SELECT MAX(lease_num)
      INTO l_lease_num_high
      FROM pn_leases;
    EXCEPTION
      WHEN OTHERS THEN RAISE;
    END;
  END IF;

  IF p_vr_num_low IS NOT NULL THEN
    l_vr_num_low := p_vr_num_low;
  ELSE
    l_vr_num_low := ' ';
  END IF;

  IF p_vr_num_high IS NOT NULL THEN
    l_vr_num_high := p_vr_num_high;
  ELSE
    BEGIN
      SELECT MAX(rent_num)
      INTO l_vr_num_high
      FROM pn_var_rents;
    EXCEPTION
      WHEN OTHERS THEN RAISE;
    END;
  END IF;

  IF p_date IS NOT NULL THEN
    l_date := fnd_date.canonical_to_date(p_date);
  ELSIF p_date IS NULL THEN
    l_date := TO_DATE('31-12-4712', 'DD-MM-YYYY');
  END IF;

  IF p_property_code IS NOT NULL THEN

    FOR bld_rec IN get_buildings_c(p_prop_code => p_property_code)
    LOOP

      FOR vr_rec IN get_vr_prop_c(p_building_id => bld_rec.location_id)
      LOOP

        pn_var_trueup_pkg.calculate_trueup
         ( p_var_rent_id => vr_rec.var_rent_id
          ,p_prd_date    => l_date);

      END LOOP;

    END LOOP;

  ELSIF p_property_code IS NULL THEN

    FOR vr_rec IN get_vr_c LOOP

      pn_var_trueup_pkg.calculate_trueup
       ( p_var_rent_id => vr_rec.var_rent_id
        ,p_prd_date    => l_date);

    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END trueup_batch_process;


PROCEDURE set_trueup_flag(l_flag VARCHAR2
          ) IS
BEGIN
   --VALID VALUES ARE T AND C
   G_IS_TU_CONC_FLAG := l_flag;
EXCEPTION
  WHEN others THEN
    RAISE;
END;


END PN_VAR_TRUEUP_PKG;

/
