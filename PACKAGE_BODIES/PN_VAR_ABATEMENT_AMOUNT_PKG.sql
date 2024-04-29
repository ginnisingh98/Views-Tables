--------------------------------------------------------
--  DDL for Package Body PN_VAR_ABATEMENT_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_ABATEMENT_AMOUNT_PKG" AS
-- $Header: PNVRCABB.pls 120.8 2007/05/31 11:40:21 sraaj noship $

-------------------------------------------------------------------------------
-- FUNCTION  : calc_abatement
--
-- Description : Function to calculate recurring abatement amount for
--               an invoice DATE and period_id.
--
-- 08-Mar-2002  Pooja Sidhu  o Created.
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_rent_inv,pn_var_rents with _ALL table.
-- 30-jan-2006 Shabda  o Bug 5729157 - Instead of checking for inv_id passed,
-- check for invoice_id for given date and period
------------------------------------------------------------------------------

FUNCTION calc_abatement(p_var_rent_inv_id IN NUMBER,
                        p_min_grp_dt IN DATE,
                        p_max_grp_dt IN DATE)
RETURN NUMBER IS
CURSOR csr_get_amt IS
SELECT NVL(SUM(ppi.actual_amount),0)
FROM pn_payment_items_all  ppi,
     pn_var_rent_inv_all inv,    --BUG#2452909   /* hrodda_MOAC -changed to tablename_all*/
     pn_var_rents_all var ,      --BUG#2452909   /* hrodda_MOAC -changed to tablename_all*/
     pn_payment_schedules_all pps,
     pn_var_abatements_all abt
WHERE ppi.payment_term_id = abt.payment_term_id
AND   abt.var_rent_inv_id = (SELECT inv2.var_rent_inv_id FROM pn_var_rent_inv_all inv1, pn_var_rent_inv_all inv2
                             WHERE inv1.var_rent_id = inv2.var_rent_id
                             AND   inv1.period_id = inv2.period_id
                             AND   inv1.invoice_date = inv2.invoice_date
                             AND   inv1.var_rent_inv_id = p_var_rent_inv_id
			     AND   inv2.true_up_amt IS NULL
			     AND   inv2.adjust_num =0)
AND   abt.include_term = pn_var_abatement_amount_pkg.G_INCLUDE_TERM_YES
AND   inv.var_rent_inv_id = p_var_rent_inv_id  --BUG#2452909,
AND   var.var_rent_id = inv.var_rent_id      --BUG#2452909
AND   ppi.currency_code = var.currency_code    --BUG#2452909
AND   ppi.payment_schedule_id = pps.payment_schedule_id
AND   ppi.payment_item_type_lookup_code = 'CASH'
AND   TRUNC(pps.schedule_date,'MM') BETWEEN
      TRUNC(p_min_grp_dt,'MM') AND TRUNC(p_max_grp_dt,'MM');

CURSOR csr_get_tu_amt IS
SELECT NVL(SUM(ppi.actual_amount),0)
FROM pn_payment_items_all  ppi,
     pn_var_rent_inv_all inv,    --BUG#2452909   /* hrodda_MOAC -changed to tablename_all*/
     pn_var_rents_all var ,      --BUG#2452909   /* hrodda_MOAC -changed to tablename_all*/
     pn_payment_schedules_all pps,
     pn_var_abatements_all abt
WHERE ppi.payment_term_id = abt.payment_term_id
AND   abt.var_rent_inv_id = (SELECT inv2.var_rent_inv_id FROM pn_var_rent_inv_all inv1, pn_var_rent_inv_all inv2
                             WHERE inv1.var_rent_id = inv2.var_rent_id
                             AND   inv1.period_id = inv2.period_id
                             AND   inv1.invoice_date = inv2.invoice_date
                             AND   inv1.var_rent_inv_id = p_var_rent_inv_id
			     AND   inv2.true_up_amt IS NOT NULL
			     AND   inv2.adjust_num =0)
AND   abt.include_term = pn_var_abatement_amount_pkg.G_INCLUDE_TERM_YES
AND   inv.var_rent_inv_id = p_var_rent_inv_id  --BUG#2452909,
AND   var.var_rent_id = inv.var_rent_id      --BUG#2452909
AND   ppi.currency_code = var.currency_code    --BUG#2452909
AND   ppi.payment_schedule_id = pps.payment_schedule_id
AND   ppi.payment_item_type_lookup_code = 'CASH'
AND   TRUNC(pps.schedule_date,'MM') BETWEEN
      TRUNC(p_min_grp_dt,'MM') AND TRUNC(p_max_grp_dt,'MM');

-- Get the details of
CURSOR is_inv_tu_c(ip_var_rent_inv_id NUMBER
          ) IS
  SELECT  true_up_amt
    FROM  pn_var_rent_inv_all inv
   WHERE  inv.var_rent_inv_id = ip_var_rent_inv_id;

l_abt_amt NUMBER;
l_true_up_amt NUMBER;

BEGIN
    pnp_debug_pkg.log('pn_var_abatement_amount_pkg.calc_abatement  (+) :');
    --
    FOR tu_rec IN is_inv_tu_c(p_var_rent_inv_id) LOOP
        l_true_up_amt := tu_rec.true_up_amt;
        pnp_debug_pkg.log('l_true_up_amt'||l_true_up_amt);
    END LOOP;

    IF l_true_up_amt IS NULL THEN
      -- This is non true up amt
          pnp_debug_pkg.log('Non true up inv');
          OPEN csr_get_amt;
          FETCH csr_get_amt INTO l_abt_amt;
          CLOSE csr_get_amt;
    ELSE
      -- This is true up amt
          pnp_debug_pkg.log('true up inv');
          OPEN csr_get_tu_amt;
          FETCH csr_get_tu_amt INTO l_abt_amt;
          CLOSE csr_get_tu_amt;
    END IF;
    pnp_debug_pkg.log('Amount:'||l_abt_amt);
    pnp_debug_pkg.log('pn_var_abatement_amount_pkg.calc_abatement  (-) :');
    RETURN l_abt_amt;
EXCEPTION
WHEN no_data_found THEN
return 0;
WHEN others THEN
pnp_debug_pkg.log('Error IN pn_var_abatement_amount_pkg.calc_abatement -'||TO_CHAR(sqlcode)||' - '||sqlerrm);
RAISE;

END calc_abatement;

-------------------------------------------------------------------------------
-- FUNCTION  : calc_abatement
--
-- Description : Function to calculate recurring abatement amount for
--               an invoice DATE and period_id.
--
-- Shabda  29-5-07 o Created. _ bug 6041521.
------------------------------------------------------------------------------

FUNCTION calc_abatement(p_var_rent_id IN NUMBER,
                        p_period_id IN NUMBER,
                        p_var_rent_inv_id IN NUMBER,
                        p_min_grp_dt IN DATE,
                        p_max_grp_dt IN DATE,
			p_trp_flag IN VARCHAR2)
RETURN NUMBER IS
CURSOR csr_get_amt(ip_var_rent_inv_id NUMBER,
                   ip_min_grp_dt DATE,
		   ip_max_grp_dt DATE) IS
SELECT NVL(SUM(ppi.actual_amount),0) amount
FROM pn_payment_items_all  ppi,
     pn_var_rent_inv_all inv,    --BUG#2452909   /* hrodda_MOAC -changed to tablename_all*/
     pn_var_rents_all var ,      --BUG#2452909   /* hrodda_MOAC -changed to tablename_all*/
     pn_payment_schedules_all pps,
     pn_var_abatements_all abt
WHERE ppi.payment_term_id = abt.payment_term_id
AND   abt.var_rent_inv_id = (SELECT inv2.var_rent_inv_id FROM pn_var_rent_inv_all inv1, pn_var_rent_inv_all inv2
                             WHERE inv1.var_rent_id = inv2.var_rent_id
                             AND   inv1.period_id = inv2.period_id
                             AND   inv1.invoice_date = inv2.invoice_date
                             AND   inv1.var_rent_inv_id = ip_var_rent_inv_id
			     AND   inv2.true_up_amt IS NULL
			     AND   inv2.adjust_num =0)
AND   abt.include_term = pn_var_abatement_amount_pkg.G_INCLUDE_TERM_YES
AND   inv.var_rent_inv_id = ip_var_rent_inv_id  --BUG#2452909,
AND   var.var_rent_id = inv.var_rent_id      --BUG#2452909
AND   ppi.currency_code = var.currency_code    --BUG#2452909
AND   ppi.payment_schedule_id = pps.payment_schedule_id
AND   ppi.payment_item_type_lookup_code = 'CASH'
AND   TRUNC(pps.schedule_date,'MM') BETWEEN
      TRUNC(ip_min_grp_dt,'MM') AND TRUNC(ip_max_grp_dt,'MM');

CURSOR csr_get_tu_amt IS
SELECT NVL(SUM(ppi.actual_amount),0)
FROM pn_payment_items_all  ppi,
     pn_var_rent_inv_all inv,    --BUG#2452909   /* hrodda_MOAC -changed to tablename_all*/
     pn_var_rents_all var ,      --BUG#2452909   /* hrodda_MOAC -changed to tablename_all*/
     pn_payment_schedules_all pps,
     pn_var_abatements_all abt
WHERE ppi.payment_term_id = abt.payment_term_id
AND   abt.var_rent_inv_id = (SELECT inv2.var_rent_inv_id FROM pn_var_rent_inv_all inv1, pn_var_rent_inv_all inv2
                             WHERE inv1.var_rent_id = inv2.var_rent_id
                             AND   inv1.period_id = inv2.period_id
                             AND   inv1.invoice_date = inv2.invoice_date
                             AND   inv1.var_rent_inv_id = p_var_rent_inv_id
			     AND   inv2.true_up_amt IS NOT NULL
			     AND   inv2.adjust_num =0)
AND   abt.include_term = pn_var_abatement_amount_pkg.G_INCLUDE_TERM_YES
AND   inv.var_rent_inv_id = p_var_rent_inv_id  --BUG#2452909,
AND   var.var_rent_id = inv.var_rent_id      --BUG#2452909
AND   ppi.currency_code = var.currency_code    --BUG#2452909
AND   ppi.payment_schedule_id = pps.payment_schedule_id
AND   ppi.payment_item_type_lookup_code = 'CASH'
AND   TRUNC(pps.schedule_date,'MM') BETWEEN
      TRUNC(p_min_grp_dt,'MM') AND TRUNC(p_max_grp_dt,'MM');

-- Get the details of
CURSOR is_inv_tu_c(ip_var_rent_inv_id NUMBER
          ) IS
  SELECT  true_up_amt
    FROM  pn_var_rent_inv_all inv
   WHERE  inv.var_rent_inv_id = ip_var_rent_inv_id;

-- Get the details of invoices in a specific period
CURSOR get_inv_in_prd(ip_period_id NUMBER
          ) IS
  SELECT var_rent_inv_id
    FROM pn_var_rent_inv_all
   WHERE period_id = ip_period_id;

-- Get the details of invoice date
CURSOR get_inv_date(ip_inv_id NUMBER
          ) IS
  SELECT invoice_date
    FROM pn_var_rent_inv_all
   WHERE var_rent_inv_id = ip_inv_id
   AND true_up_amt IS NULL
   AND adjust_num = 0;
  -- Get the proration type
  CURSOR proration_type_c(ip_var_rent_id NUMBER
            ) IS
    SELECT proration_rule
    FROM pn_var_rents_all
    WHERE var_rent_id = ip_var_rent_id;
  -- Get the first period
  CURSOR get_fy_prd_c(ip_var_rent_id NUMBER
            ) IS
    SELECT period_id
      FROM pn_var_periods_all
     WHERE start_date = (SELECT min(start_date) from pn_var_periods_all WHERE var_rent_id = ip_var_rent_id)
       AND var_rent_id = ip_var_rent_id;

  CURSOR invoice_dates_fy_c(ip_period_id NUMBER
            ) IS
    SELECT per.start_date, per.end_date
      FROM pn_var_periods_all per
     WHERE period_id = ip_period_id;


l_abt_amt NUMBER;
l_true_up_amt NUMBER;
l_inv_date DATE;
l_min_grp_date DATE;
l_max_grp_date DATE;
l_proration_type VARCHAR2(30);
l_min_prd_id NUMBER;

BEGIN
    l_true_up_amt := 0;
    pnp_debug_pkg.log('pn_var_abatement_amount_pkg.calc_abatement  (+) :');
    --
    FOR rec IN proration_type_c(p_var_rent_id) LOOP
      l_proration_type := rec.proration_rule;
    END LOOP;

    --
    FOR rec IN get_fy_prd_c(p_var_rent_id) LOOP
       l_min_prd_id := rec.period_id;
    END LOOP;


    --
    FOR tu_rec IN is_inv_tu_c(p_var_rent_inv_id) LOOP
        l_true_up_amt := tu_rec.true_up_amt;
        pnp_debug_pkg.log('l_true_up_amt'||l_true_up_amt);
    END LOOP;

    IF l_true_up_amt IS NULL THEN
      -- This is non true up amt
          pnp_debug_pkg.log('Non true up inv');
          OPEN csr_get_amt(p_var_rent_inv_id, p_min_grp_dt, p_max_grp_dt);
          FETCH csr_get_amt INTO l_abt_amt;
          CLOSE csr_get_amt;
    ELSE
      -- This is true up amt
          pnp_debug_pkg.log('true up inv');
	  --
          l_abt_amt := 0;
	  FOR inv_in_prd_rec IN get_inv_in_prd(p_period_id) LOOP
	     --
	     pnp_debug_pkg.log('inv_in_prd_rec.var_rent_inv_id:'||inv_in_prd_rec.var_rent_inv_id);
	     FOR inv_date_rec IN get_inv_date(inv_in_prd_rec.var_rent_inv_id) LOOP
	        l_inv_date := inv_date_rec.invoice_date;
	     END LOOP;
	     pnp_debug_pkg.log('l_inv_date:'||l_inv_date);
             l_min_grp_date := get_group_dt(l_inv_date, p_period_id, 'MIN');
	     l_max_grp_date := get_group_dt(l_inv_date, p_period_id, 'MAX');
	     IF (l_proration_type IN ('FY', 'FLY') AND p_period_id = l_min_prd_id)  THEN
	        --
	        FOR rec IN invoice_dates_fy_c(p_period_id) LOOP
	           l_min_grp_date := rec.start_date;
		   l_max_grp_date := rec.end_date;
	        END LOOP;


	     END IF;

	     pnp_debug_pkg.log('l_min_grp_date:'||l_min_grp_date);
	     pnp_debug_pkg.log('l_max_grp_date:'||l_max_grp_date);
	     --
	     FOR amt_rec IN csr_get_amt(inv_in_prd_rec.var_rent_inv_id, l_min_grp_date, l_max_grp_date) LOOP
	       l_abt_amt := l_abt_amt + amt_rec.amount;
	     END LOOP;
	     pnp_debug_pkg.log('l_abt_amt:'||l_abt_amt);

	  END LOOP;

    END IF;
    pnp_debug_pkg.log('Amount:'||l_abt_amt);
    pnp_debug_pkg.log('pn_var_abatement_amount_pkg.calc_abatement  (-) :');
    RETURN l_abt_amt;
EXCEPTION
WHEN no_data_found THEN
return 0;
WHEN others THEN
pnp_debug_pkg.log('Error IN pn_var_abatement_amount_pkg.calc_abatement -'||TO_CHAR(sqlcode)||' - '||sqlerrm);
RAISE;

END calc_abatement;



----------------------------------------------------------------------------
--  PROCEDURE  : process_abatement
--
--               Called FROM the View Variable Rent by Period window when
--               the user calculates abatement amount.
--
--  08-Mar-2002  Pooja Sidhu  o Created.
--  16-Jan-2003  Daniel Thota o Added parameter l_exported to check if an
--                              invoice has been transferred. Fix for bug # 2722191
---------------------------------------------------------------------------
PROCEDURE process_abatement(p_var_rent_inv_id IN NUMBER,
                            p_negative_rent_flag IN VARCHAR2,
                            p_term_exists IN VARCHAR2,
                            p_var_rent_type IN VARCHAR2,
                            p_min_grp_dt IN DATE,
                            p_max_grp_dt IN DATE)
IS
l_abt_amt       NUMBER := 0;
l_exported      NUMBER := null;
BEGIN
    pnp_debug_pkg.log('pn_var_abatement_amount_pkg.process_abatement  (+) :');

    /* Calculate the recurring abatement amount */

    --Fix for bug # 2722191
    l_exported:= PN_VAR_RENT_PKG.FIND_IF_EXPORTED(p_var_rent_inv_id,'PERIODS_INV_BLK');


    /*If an actual/variance term exists for the invoice DATE then
      DELETE the term FROM pn_payment_terms */

   IF l_exported IS NULL THEN --Fix for bug # 2722191

    l_abt_amt := NVL(calc_abatement(p_var_rent_inv_id,p_min_grp_dt,p_max_grp_dt),0);

    IF NVL(p_term_exists,'N') = 'Y' THEN
       DELETE FROM pn_payment_terms_all
       WHERE var_rent_inv_id=p_var_rent_inv_id
       and var_rent_type = p_var_rent_type
       and NVL(status,'DRAFT')='DRAFT';
    END IF;

    /* Update pn_var_rent_inv with the recurring abatement amount and also
       UPDATE the actual invoiced amount */

    UPDATE pn_var_rent_inv_all
    SET rec_abatement = l_abt_amt,
        actual_term_status = DECODE(p_var_rent_type,'ACTUAL','N',actual_term_status),
        variance_term_status = DECODE(p_var_rent_type,'VARIANCE','N',variance_term_status),
        actual_invoiced_amount = pn_variable_amount_pkg.derive_actual_invoiced_amt(
                                                 constr_actual_rent,
                                                 p_negative_rent_flag,
                                                 abatement_appl,
                                                 negative_rent,
                                                 l_abt_amt,
                                                 rec_abatement_override)
    WHERE var_rent_inv_id = p_var_rent_inv_id;

   END IF;


    pnp_debug_pkg.log('pn_var_abatement_amount_pkg.process_abatement  (-) :');

EXCEPTION
WHEN OTHERS THEN
pnp_debug_pkg.log('Error IN pn_var_abatement_amount_pkg.process_abatement -'||TO_CHAR(sqlcode)||' - '||sqlerrm);
raise;

END process_abatement;

-----------------------------------------------------------------------------------------------------
-- FUNCTION   : get_group_dt
--
-- Description : Function to get the minimum or maximum group_date
--               FROM pn_var_grp_dates table for an invoice DATE and period_id
--
-----------------------------------------------------------------------------------------------------

FUNCTION get_group_dt(
                p_invoice_date DATE,
                p_period_id NUMBER,
                p_date_type IN VARCHAR2)
RETURN DATE IS
CURSOR csr_min_gd IS
SELECT MIN(grp_start_date)
FROM pn_var_grp_dates_all
WHERE invoice_date = p_invoice_date
AND period_id = p_period_id;

CURSOR csr_max_gd IS
SELECT MAX(grp_end_date)
FROM pn_var_grp_dates_all
WHERE invoice_date = p_invoice_date
AND period_id = p_period_id;

l_grp_date DATE;

BEGIN

pnp_debug_pkg.log('pn_var_abatement_amount_pkg.get_group_dt  (-) :');

IF p_date_type ='MIN' THEN
    OPEN csr_min_gd;
    FETCH csr_min_gd INTO l_grp_date;
    CLOSE csr_min_gd;
ELSIF p_date_type = 'MAX' THEN
    OPEN csr_max_gd;
    FETCH csr_max_gd into l_grp_date;
    CLOSE csr_max_gd;
END IF;

RETURN l_grp_date;

pnp_debug_pkg.log('pn_var_abatement_amount_pkg.get_group_dt  (-) :');

END get_group_dt;

---------------------------------------------------------------------------------------------------------------
-- FUNCTION    : get_term_exists
--
-- Description : Return Y' if a record
--               exists IN pn_var_abatements table for the
--               combination of payment_term_id and var_rent_inv_id.
--
-- 08-Mar-2002   Pooja sidhu  o Created
-------------------------------------------------------------------------------------------------------------
FUNCTION get_term_exists (p_payment_term_id IN NUMBER,
                          p_var_rent_inv_id NUMBER)
RETURN VARCHAR2 IS
CURSOR csr_term_exists IS
SELECT 'Y'
FROM dual
WHERE EXISTS(SELECT null
             FROM pn_var_abatements_all
             WHERE payment_term_id = p_payment_term_id
             AND var_rent_inv_id = p_var_rent_inv_id);

l_term_exists VARCHAR2(1) := 'N';

BEGIN
    OPEN csr_term_exists;
    FETCH csr_term_exists into l_term_exists;
    if csr_term_exists%notfound then
        l_term_exists := 'N';
    end if;
    CLOSE csr_term_exists;

    return l_term_exists;

EXCEPTION
WHEN no_data_found THEN
RETURN 'N';

END get_term_exists;


END pn_var_abatement_amount_pkg;



/
