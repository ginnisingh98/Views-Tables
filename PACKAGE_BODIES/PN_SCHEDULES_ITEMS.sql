--------------------------------------------------------
--  DDL for Package Body PN_SCHEDULES_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_SCHEDULES_ITEMS" AS
  -- $Header: PNSCHITB.pls 120.40.12010000.44 2010/05/17 18:10:18 asahoo ship $

-------------------------------------------------------------------------------
-- This is the MAIN procedure in this Package.
-- It's referenced in the Concurrent Program executable definition - PNSCHITM
-- It calls all the other procedures in this Package.
--
-- Args:
--   errbuf:           Needed for all PL/SQL Concurrent Programs
--   retcode:          Needed for all PL/SQL Concurrent Programs
--   p_lease_id:       The Lease Id
--   p_lease_context:  The Lease Context (one of - ABS, EXP, CON, ADD)
--   p_called_from:    Called from Main, Index or Variable Rent (MAIN,IND,VAR)
--   p_term_id:        Payment Term Id
--   p_term_end_dt:    Payment Term End Date
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--  CURSOR     : lease_con_cur_mini_retro
--  DESCRIPTION: This cursor fetches Payment Term related information for a lease when
--               the lease is contracted or expanded.
--  02-AUG-2005  piagrawa    o Created.
--  05-JAN-2007  Hareesha    o Bug 5742863 Removed index_period_id is null condition
--                             to consider RI terms too for contraction
--------------------------------------------------------------------------------------------
   CURSOR lease_con_cur_mini_retro (p_lease_id NUMBER, p_active_lease_change_id NUMBER) IS

      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.index_period_id,
             ppt.norm_start_date
      FROM   pn_payment_terms_all ppt
      WHERE  ppt.lease_id = p_lease_id
      AND    ppt.var_rent_inv_id IS NULL
      AND    ppt.period_billrec_id IS NULL
      AND    EXISTS (SELECT NULL
                     FROM   pn_payment_items_all ppi
                     WHERE  ppt.lease_id = p_lease_id
                     AND    ppi.payment_term_id = ppt.payment_term_id)
      UNION
      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.index_period_id,
             ppt.norm_start_date
      FROM   pn_payment_terms_all ppt
      WHERE  ppt.lease_id = p_lease_id
      AND    ppt.index_period_id IS NOT NULL
      AND    ppt.status = 'APPROVED'
      AND    ppt.index_term_indicator NOT IN ('BACKBILL','ATLEAST-BACKBILL')
      AND    EXISTS (SELECT NULL
                     FROM   pn_payment_items_all ppi
                     WHERE  ppt.lease_id = p_lease_id
                     AND    ppi.payment_term_id = ppt.payment_term_id);


--------------------------------------------------------------------------------------------
--  CURSOR     : payment_term_con_cur_retro
--  DESCRIPTION: This cursor fetches Payment Term related information for a lease when
--               when a Payment Term is contracted.
--  02-AUG-2005  piagrawa o Created.
--------------------------------------------------------------------------------------------
   CURSOR payment_term_con_cur_retro (p_lease_id NUMBER,
                                      p_payment_term_id NUMBER) IS

      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.norm_start_date,
             ppt.norm_end_date
      FROM   pn_payment_terms_all ppt
      WHERE  ppt.lease_id = p_lease_id
      AND    ppt.payment_term_id = p_payment_term_id
      AND    EXISTS (SELECT NULL
                     FROM   pn_payment_items_all ppi
                     WHERE  ppt.lease_id = p_lease_id
                     AND    ppi.payment_term_id = ppt.payment_term_id)
      FOR UPDATE;

--------------------------------------------------------------------------------------------
--  CURSOR     : TERM_CON_EXP_CUR
--  DESCRIPTION: This cursor fetches Payment Term related information for a lease when
--               the lease is contracted or expanded.
--  25-JUN-2001  Mrinal Misra    o Created.
--               Mrinal Misra    o Added ppt.var_rent_inv_id IS NULL  for Var. rent addn.
--  26-APR-2002  modified  ftanudja   o added ppt.rate
--  10-DEC-2002  graghuna        o Added parameter p_active_lease_change_id for Month-to-
--                                 Month Re-Normalization issue. --MTM-I
--  29-AUG-2003  Satish Tripathi o Fixed for BUG# 3116986, added period_billrec_id IS NULL
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Added lease_change_id in SELECT.
--  18-APR-07    sdmahesh          Bug # 5985779. Enhancement for new profile
--                                 option for lease early termination
--------------------------------------------------------------------------------------------
   CURSOR term_con_exp_cur (p_lease_id NUMBER, p_active_lease_change_id NUMBER) IS

      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.index_period_id,
             ppt.norm_start_date
      FROM   pn_payment_terms_all ppt
      WHERE  ppt.lease_id = p_lease_id
      AND    NVL(ppt.normalize,'N') = 'Y'
      AND    NVL(ppt.status,'APPROVED') = 'APPROVED'
      AND    EXISTS (SELECT NULL
                     FROM   pn_payment_items_all ppi
                     WHERE  ppt.lease_id = p_lease_id
                     AND    ppi.payment_term_id = ppt.payment_term_id);

--------------------------------------------------------------------------------------------
--  CURSOR     : TERM_EXP_CUR
--  DESCRIPTION: This cursor fetches Payment Term related information for a lease when
--               the lease is expanded.
--  17-JAN-06  piagrawa  o Bug#4931780 Created.
--  22-SEP-08  jsundara  o Bug#6699877 Modified the cursor TERM_EXP_CUR to add null
--                         handling for norm_end_date.
--------------------------------------------------------------------------------------------
   CURSOR TERM_EXP_CUR ( p_lease_id NUMBER
                       , p_active_lease_change_id NUMBER
                       , p_cutoff_date DATE) IS

      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.index_period_id,
             ppt.norm_start_date
      FROM   pn_payment_terms_all ppt
      WHERE  ppt.lease_id = p_lease_id
      AND    ppt.var_rent_inv_id IS NULL
      AND    ppt.period_billrec_id IS NULL
      AND    (NVL(ppt.normalize,'N') = 'Y' AND NVL(ppt.norm_end_date, ppt.end_date) > p_cutoff_date) /* 6699877 */
      AND    EXISTS (SELECT NULL
                     FROM   pn_payment_items_all ppi
                     WHERE  ppt.lease_id = p_lease_id
                     AND    ppi.payment_term_id = ppt.payment_term_id)
      UNION
      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.index_period_id,
             ppt.norm_start_date
      FROM   pn_payment_terms_all ppt
      WHERE  ppt.lease_id = p_lease_id
      AND    ppt.index_period_id IS NOT NULL
      AND    ppt.status = 'APPROVED'
      AND    ppt.index_term_indicator NOT IN ('BACKBILL','ATLEAST-BACKBILL')
      AND    (( ppt.normalize = 'Y' AND NVL(ppt.norm_end_date, ppt.end_date) > p_cutoff_date) OR
              ( NVL(ppt.normalize,'N') = 'N' AND ppt.end_date > p_cutoff_date))
      AND    EXISTS (SELECT NULL
                     FROM   pn_payment_items_all ppi
                     WHERE  ppt.lease_id = p_lease_id
                     AND    ppi.payment_term_id = ppt.payment_term_id);

--------------------------------------------------------------------------------------------
--  CURSOR     : TERM_ADD_MAIN_CUR
--  DESCRIPTION: This cursor fetches Payment Term related information for a lease when
--               the a payment Term is added from Main Lease.
--  25-JUN-2001  Mrinal Misra    o Created.
--               Mrinal Misra    o Added ppt.var_rent_inv_id IS NULL  for Var. rent addn.
--               Mrinal Misra    o Added ppt.index_period_id IS NULL  Check for Variable Rent.
--  26-APR-2002  modified  ftanudja  o added attribute ppt.rate
--  29-AUG-2003  Satish Tripathi o Fixed for BUG# 3116986, added period_billrec_id IS NULL
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Added lease_change_id in SELECT,
--                                 Joined with pn_lease_changes to get change_type_lookup_code
--                                 and change_commencement_date.
--  21-OCT-2004 vmmehta          o Bug# 3936944. Added condition chnage_type_lookup_code in edit/amend
--------------------------------------------------------------------------------------------
   CURSOR term_add_main_cur (p_lease_id NUMBER) IS

      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.norm_start_date,
             plc.change_type_lookup_code,
             plc.change_commencement_date
      FROM   pn_payment_terms_all ppt,
             pn_lease_changes_all plc
      WHERE  ppt.lease_id = p_lease_id
      AND    ppt.lease_change_id = plc.lease_change_id
      AND    ppt.index_period_id IS NULL
      AND    ppt.var_rent_inv_id IS NULL
      AND    ppt.period_billrec_id IS NULL
      AND   plc.change_type_lookup_code IN ('EDIT', 'AMEND')
      AND NOT EXISTS (SELECT NULL
                      FROM   pn_payment_items_all ppi
                      WHERE  ppt.lease_id = p_lease_id
                      AND    ppi.payment_term_id = ppt.payment_term_id);

--------------------------------------------------------------------------------------------
--  CURSOR     : TERM_ADD_IND_VAR_CUR
--  DESCRIPTION: This cursor fetches Payment Term related information for a lease when
--               the a payment Term is added from Index Rent.
--  25-JUN-2001  Mrinal Misra    o Created.
--  26-APR-2002  ftanudja        o added attribute ppt.rate
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Added lease_change_id in SELECT.
--------------------------------------------------------------------------------------------
   CURSOR term_add_ind_var_cur (p_lease_id NUMBER,
                                p_term_id  NUMBER)
   IS

      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.norm_start_date
      FROM   pn_payment_terms_all ppt
      WHERE  ppt.payment_term_id = p_term_id
      AND NOT EXISTS (SELECT NULL
                      FROM   pn_payment_items_all ppi
                      WHERE  ppt.lease_id = p_lease_id
                      AND    ppi.payment_term_id = p_term_id);

--------------------------------------------------------------------------------------------
--  CURSOR     : TERM_ABS_CUR
--  DESCRIPTION: This cursor fetches Payment Term related information for a lease when
--               the lease is abstracted.
--  25-JUN-2001  Mrinal Misra    o Created.
--               Mrinal Misra    o Added ppt.var_rent_inv_id IS NULL  for Var. rent addn.
--  25-APR-2002  ftanudja  modified   o added attribute ppt.rate
--  29-AUG-2003  Satish Tripathi o Fixed for BUG# 3116986, added period_billrec_id IS NULL
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Added lease_change_id in SELECT.
--------------------------------------------------------------------------------------------
   CURSOR term_abs_cur (p_lease_id NUMBER) IS

      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.norm_start_date
      FROM   pn_payment_terms_all ppt
      WHERE  lease_id = p_lease_id
      AND    ppt.index_period_id IS NULL
      AND    ppt.var_rent_inv_id IS NULL
      AND    ppt.period_billrec_id IS NULL
      AND    NOT EXISTS (SELECT NULL
                         FROM   pn_payment_items_all ppi
                         WHERE  ppt.lease_id = p_lease_id
                         AND    ppi.payment_term_id = ppt.payment_term_id);

--------------------------------------------------------------------------------------------
--  CURSOR     : PAYMENT_TERM_CON_CUR
--  DESCRIPTION: This cursor fetches Payment Term related information for a lease when
--               when a Payment Term is contracted.
--  01-FEB-2002  Satish Tripathi o Created.
--  26-APR-2002  modified   ftanudja   o added ppt.rate
--  10-DEC-2002  graghuna        o Added ppt.norm_end_date for Month-to-Month
--                                 Re-Normalization issue. --MTM-I
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Added lease_change_id in SELECT.
--------------------------------------------------------------------------------------------
   CURSOR payment_term_con_cur (p_lease_id NUMBER) IS

      SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.norm_start_date,
             ppt.norm_end_date
      FROM   pn_payment_terms_all ppt
      WHERE  ppt.lease_id = p_lease_id
      AND    ppt.changed_flag = 'Y'
      AND    EXISTS (SELECT NULL
                     FROM   pn_payment_items_all ppi
                     WHERE  ppt.lease_id = p_lease_id
                     AND    ppi.payment_term_id = ppt.payment_term_id)
      FOR UPDATE;

-- Retro Start
   TYPE tab_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   term_id_tab   tab_number;
   l_index       NUMBER;
-- Retro End

--------------------------------------------------------------------------------------------
--  FUNCTION   : FIRST_DAY
--  DESCRIPTION: This function returns Date with the First Day of the Month.
--  20-AUG-2001  Mrinal Misra    o Created.
--------------------------------------------------------------------------------------------
FUNCTION First_Day (p_Date DATE)
RETURN   DATE
IS
BEGIN

  RETURN TO_DATE(TO_CHAR(p_Date,'YYYY/MM'),'YYYY/MM');

END First_Day;

--------------------------------------------------------------------------------------------
--  FUNCTION   : GET_FREQUENCY
--  DESCRIPTION: This function returns numeric value of a given CHAR frequency code.
--               This numeric value is directly used in various calculations.
--  25-JUN-2001  Mrinal Misra    o Created.
--------------------------------------------------------------------------------------------
FUNCTION get_frequency (p_freq_code VARCHAR2)
RETURN   NUMBER
IS
BEGIN

      IF p_freq_code = 'MON' THEN

         RETURN 1;

      ELSIF p_freq_code = 'QTR' THEN

            RETURN 3;

      ELSIF p_freq_code = 'SA' THEN

            RETURN 6;

      ELSIF p_freq_code = 'YR' THEN

            RETURN 12;

      ELSIF p_freq_code = 'OT' THEN

            RETURN 1;

      END IF;

END get_frequency;

------------------------------------------------------------------------
--  FUNCTION  :- GET_FIRST_ITEM_DATE
--  DESCRIPTION: This function returns the due date if 1st cash item.
--  24-MAR-2004  Satish Tripathi o Created for BUG# 3295405.
------------------------------------------------------------------------
FUNCTION Get_First_Item_Date (p_payment_term_id IN NUMBER)
RETURN   DATE
IS

   l_first_due_date                DATE;
   l_due_date                      DATE;

   CURSOR first_item_cursor IS
      SELECT MIN(due_date)
      FROM   pn_payment_items_all
      WHERE  payment_term_id = p_payment_term_id
      AND    payment_item_type_lookup_code = 'CASH';

BEGIN
   pnp_debug_pkg.log('Get_First_Item_Date (+) - p_payment_term_id: ' || p_payment_term_id);

   OPEN first_item_cursor;
   FETCH first_item_cursor INTO l_first_due_date;
   CLOSE first_item_cursor;

   l_due_date := First_Day(l_first_due_date);

   pnp_debug_pkg.log('Get_First_Item_Date (-) - l_due_date: ' || l_due_date);

   RETURN l_due_date;

END Get_First_Item_Date;


------------------------------------------------------------------------
--  FUNCTION  :- GET_NORM_END_DATE
--  27-OCT-2003  Satish Tripathi o Created for BUG# 3178064.
------------------------------------------------------------------------
FUNCTION Get_Norm_End_Date (p_lease_id IN NUMBER)
RETURN   DATE
IS

   l_lease_termination_date        DATE;
   l_act_lease_found               BOOLEAN := FALSE;

   CURSOR lease_dt_hist_cursor IS
      SELECT lease_change_id, lease_termination_date, lease_status
      FROM   pn_lease_details_history
      WHERE  lease_id = p_lease_id
      ORDER BY 1 DESC;

BEGIN

    FOR lease_dt_hist_rec in lease_dt_hist_cursor
    LOOP

        IF lease_dt_hist_rec.lease_status = 'ACT' THEN
            l_lease_termination_date := lease_dt_hist_rec.lease_termination_date;
            EXIT;
        END IF;

    END LOOP;

    IF l_lease_termination_date IS NULL THEN
       l_lease_termination_date := g_new_lea_term_dt;
    END IF;

    RETURN l_lease_termination_date;

END Get_Norm_End_Date;

/* Added for Bug 7570052 */
procedure get_sch_start(p_yr_start_dt IN DATE,
                        p_freq_code IN VARCHAR2,
                        p_term_start_dt IN VARCHAR2,
                        p_sch_str_dt OUT NOCOPY DATE)
IS
TYPE cal_date IS TABLE of DATE INDEX BY BINARY_INTEGER;
cal_table cal_date;
months_counter NUMBER := -12;
indx NUMBER;
period_duration NUMBER;
BEGIN
     indx := 0;

     select DECODE(p_freq_code,'QTR',3,'SA',6,'YR',12)
     into period_duration from dual;

           while months_counter <= 12
           loop
               cal_table(indx) := add_months(p_yr_start_dt, months_counter);
               indx := indx + 1;
               months_counter := months_counter + period_duration;
           end loop;

      for i in 1..cal_table.count-1
      loop
         if p_term_start_dt >= cal_table(i-1) and p_term_start_dt < cal_table(i)
         then
             p_sch_str_dt := cal_table(i-1);
             exit;
         end if;
      end loop;

      If p_sch_str_dt IS NULL then
         p_sch_str_dt := cal_table(cal_table.count-1);
      end if;

END get_sch_start;

-------------------------------------------------------------------------------
--  PROCEDURE  : GET_SCH_INFO
--  DESCRIPTION: This procedure retrives schedule information of a particular
--               Payment Term like total no of schedules, 1st schedule date,
--               freq, no of schedules to skip (counter) in EXP and normalization
--               start date. These are the initial information used to process
--               the term.
--  25-JUN-01  MMisra    o Created.
--  07-FEB-02  STripathi o Added added parameter p_norm_str_dt. Added condition for
--                         Lease Context ADDAMD to set correct p_norm_str_dt.
--  26-MAR-02  STripathi o Added parameter p_sch_str_dt to correctly initialize the
--                         Schedule-Start-Date for NON MONTHLY Payment Term.
--  15-JAN-03  STripathi o Fix for BUG# 2733862. Modified calculation of l_mths_for_sch
--                         from MONTHS_BETWEEN(p_term_end_dt, p_term_start_dt)
--                         to   MONTHS_BETWEEN(p_term_end_dt+1, p_term_start_dt).
--  12-AUG-03  KkHegde   o Fix for bug#3009793. Changed the logic for determining
--                         p_sch_str_dt to avoid creating invalid dates.
--  16-OCT-03  STripathi o Fix for BUG# 3201091. Added parameter p_amd_comm_dt,
--                         to use instead of g_amd_comm_dt.
--  15-MAR-06  piagrawa  o Bug 5085901 - Modified to calculate l_sch_end_dt
--                         taking care if the schedule date is last date of
--                          month.
--  04-OCT-06  acprakas  o Bug#5489570 - Modified cursor csr_last_app_sch to ignore
--                         schedule day, while selecting last approved schedule.
--  19_dec-08 acprakas   o Bug#7626665. Reverted the fix done in bug#5489570
--------------------------------------------------------------------------------
PROCEDURE get_sch_info (p_lease_context        VARCHAR2,
                        p_normalize_flag       VARCHAR2,
                        p_mths                 NUMBER,
                        p_term_start_dt        DATE,
                        p_term_end_dt          DATE,
                        p_freq_code            VARCHAR2,
                        p_sch_day              NUMBER,
                        p_new_lea_comm_dt      DATE,
                        p_new_lea_term_dt      DATE,
                        p_old_lea_term_dt      DATE,
                        p_no_sch           OUT NOCOPY NUMBER,
                        p_freq             OUT NOCOPY NUMBER,
                        p_counter          OUT NOCOPY NUMBER,
                        p_sch_dt           OUT NOCOPY DATE,
                        p_pro_sch_dt       OUT NOCOPY DATE,
                        p_norm_str_dt   IN OUT NOCOPY DATE,
                        p_sch_str_dt       OUT NOCOPY DATE,
                        p_lease_id             NUMBER,
                        p_term_id              NUMBER,
                        p_amd_comm_dt          DATE DEFAULT NULL)
IS

   l_mths_for_sch                  NUMBER;
   l_no_sch                        NUMBER;
   l_lst_sch_dt                    DATE;
   l_counter                       NUMBER := 0;
   l_pay_status                    pn_payment_schedules.payment_status_lookup_code%TYPE;
   l_norm_str_dt                   DATE;
   l_first_draft_sch               DATE;
   l_last_app_sch                  DATE;
   l_comm_dt                       DATE;
   -- Bug 7570052
   l_cal_yr_st                     VARCHAR2(5); --Definition need to be changed to anchor on new column to be added in pn_leases_all
   l_yr_start_dt                   DATE;


   CURSOR lst_sch_dt_cur (p_term_id  NUMBER)
   IS
      SELECT MAX(pps.schedule_date), COUNT(pps.schedule_date)
      FROM   pn_payment_schedules_all pps,
             pn_payment_items_all ppi
      WHERE  ppi.payment_term_id = p_term_id
      AND    pps.payment_schedule_id = ppi.payment_schedule_id
      AND    ppi.actual_amount <> 0
      AND    ppi.payment_item_type_lookup_code = 'CASH';

   CURSOR csr_first_draft_sch (p_lease_id   NUMBER,
                               p_start_date DATE)
   IS

      SELECT First_Day(MIN(pps.schedule_date))
      FROM   pn_payment_schedules_all pps
      WHERE  pps.lease_id = p_lease_id
      AND    First_Day(pps.schedule_date) >= First_Day(p_start_date)
      AND    TO_CHAR(pps.schedule_date,'DD') = p_sch_day
      AND    pps.payment_status_lookup_code = 'DRAFT';

   CURSOR csr_last_app_sch (p_lease_id   NUMBER,
                            p_start_date DATE)
   IS

      SELECT ADD_MONTHS(First_Day(MAX(pps.schedule_date)) , 1)
      FROM   pn_payment_schedules_all pps
      WHERE  pps.lease_id = p_lease_id
      AND    First_Day(pps.schedule_date) >= First_Day(p_start_date)
    AND    TO_CHAR(pps.schedule_date,'DD') = p_sch_day
      AND    pps.payment_status_lookup_code = 'APPROVED';

BEGIN

   pnp_debug_pkg.log('get_sch_info +Start+ (+)');

   /* Get the frequency for a frequency code. */

   p_freq := get_frequency(p_freq_code => p_freq_code);

   -- Bug 7570052
   SELECT cal_start
   INTO l_cal_yr_st
   FROM pn_leases_all
   WHERE lease_id = p_lease_id;

   IF l_cal_yr_st IS NOT NULL then
      l_yr_start_dt := to_date(l_cal_yr_st || '-' || to_char(p_term_start_dt,'YYYY'),'DD-MM-YYYY');
   END IF;

   pnp_debug_pkg.log('get_sch_info - Start  ****************         ');
   pnp_debug_pkg.log('get_sch_info - IN: p_lease_context    : '||p_lease_context);
   pnp_debug_pkg.log('get_sch_info - IN: p_normalize_flag   : '||p_normalize_flag);
   pnp_debug_pkg.log('get_sch_info - IN: p_mths             : '||p_mths);
   pnp_debug_pkg.log('get_sch_info - IN: p_term_start_dt    : '||p_term_start_dt);
   pnp_debug_pkg.log('get_sch_info - IN: p_term_end_dt      : '||p_term_end_dt);
   pnp_debug_pkg.log('get_sch_info - IN: p_freq_code        : '||p_freq_code);
   pnp_debug_pkg.log('get_sch_info - IN: p_sch_day          : '||p_sch_day);
   pnp_debug_pkg.log('get_sch_info - IN: p_new_lea_comm_dt  : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('get_sch_info - IN: p_new_lea_term_dt  : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('get_sch_info - IN: p_old_lea_term_dt  : '||p_old_lea_term_dt);
   pnp_debug_pkg.log('get_sch_info - IN: p_norm_str_dt      : '||p_norm_str_dt);
   pnp_debug_pkg.log('get_sch_info - IN: p_lease_id         : '||p_lease_id);
   pnp_debug_pkg.log('get_sch_info - IN: p_term_id          : '||p_term_id);
   pnp_debug_pkg.log('get_sch_info - IN: p_amd_comm_dt      : '||p_amd_comm_dt);

   /* get the no. of schedules, first schedule date and the counter */

   IF p_lease_context = 'EXP' AND NVL(p_normalize_flag,'N') = 'Y' THEN

      /* Set the first schedule date for the cash item */

      p_sch_dt := TO_DATE(TO_CHAR(p_sch_day)||'/'
                                  ||TO_CHAR(ADD_MONTHS(p_old_lea_term_dt,1),'MM/YYYY'),
                          'DD/MM/YYYY');

      /* Schedule-Start-Date (p_sch_str_dt) should be the Term Start Day of the month of
         the schedule YYYYMM. (Used only for a Non Monthly Term) */

      /* 3009793 */

      IF p_freq_code IN ('MON', 'OT') THEN

        p_sch_str_dt := NULL;

      ELSE

        IF TO_NUMBER(TO_CHAR(p_term_start_dt,'DD')) >
           TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(p_old_lea_term_dt,1)),'DD')) THEN

          p_sch_str_dt := LAST_DAY(ADD_MONTHS(p_old_lea_term_dt,1));

        ELSE

          p_sch_str_dt := TO_DATE(TO_CHAR(p_term_start_dt,'DD')
                                ||'/'
                                ||TO_CHAR(ADD_MONTHS(p_old_lea_term_dt,1),'MM/YYYY'),
                          'DD/MM/YYYY');
        END IF;

      END IF;

      /* Store the term's normalization start date */

      l_norm_str_dt := p_norm_str_dt;

      pnp_debug_pkg.log('norm_st_dt_rec_tbl.COUNT : '||norm_st_dt_rec_tbl.COUNT); /* 9231686 */
      pnp_debug_pkg.log('p_sch_day : '||p_sch_day); /* 9231686 */

            IF  norm_st_dt_rec_tbl(p_sch_day) is not null   /* 9231686 */
            THEN
                   pnp_debug_pkg.log('pn_schedules_items.g_norm_dt_avl : '||pn_schedules_items.g_norm_dt_avl);
                   pn_schedules_items.g_norm_dt_avl := 'Y';
            ELSE
                   pn_schedules_items.g_norm_dt_avl := NULL;

            END IF;


         pnp_debug_pkg.log('gvbl : '||pn_schedules_items.g_norm_dt_avl);

	If pn_schedules_items.g_norm_dt_avl is NULL THEN

      /* If Retro is enabled - we need correct p_norm_start_date to be passed to
         PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE procedure. AMT-RETRO */
      IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
        OPEN csr_first_draft_sch(g_lease_id, p_norm_str_dt);
           FETCH csr_first_draft_sch INTO l_first_draft_sch;
        CLOSE csr_first_draft_sch;

        pnp_debug_pkg.log('l_first_draft_sch: '||l_first_draft_sch);

        IF l_first_draft_sch is NULL THEN
           p_norm_str_dt := FIRST_DAY(p_sch_dt);
        ELSE
           p_norm_str_dt := GREATEST(p_norm_str_dt, l_first_draft_sch);
        END IF;
      END IF;

      norm_st_dt_rec_tbl(p_sch_day) := p_norm_str_dt;

       else
         pnp_debug_pkg.log('pn_schedules_items.g_norm_dt_avl: '||pn_schedules_items.g_norm_dt_avl);
         p_norm_str_dt := norm_st_dt_rec_tbl(p_sch_day);
	       pnp_debug_pkg.log('l_first_draft_sch: '||p_norm_str_dt);

     END IF; /* 9231686 */

      /* Total No. of schedules is the no. of schedules between the payment term norm. start date
         and the new lease termination date */

         select norm_start_date /* 9231686 */
         into l_norm_str_dt
         from pn_payment_terms_all
         where payment_term_id = p_term_id;

         IF l_norm_str_dt IS NULL
         THEN
             l_norm_str_dt := Get_First_Item_Date(p_term_id);
         END If;

      p_no_sch := CEIL(MONTHS_BETWEEN(LAST_DAY(p_new_lea_term_dt),
                                      First_Day(l_norm_str_dt)));


      /* If lease is expanded l_counter variable should be initialized to the number of
         exisiting schedules so that only additional schedules are created. */

      p_counter := CEIL(MONTHS_BETWEEN(LAST_DAY(p_old_lea_term_dt), FIRST_DAY(l_norm_str_dt)));

      IF p_freq_code = 'MON' THEN

         p_pro_sch_dt := p_sch_dt;

      ELSIF p_freq_code = 'OT' THEN

         p_pro_sch_dt := l_norm_str_dt;

      ELSE

         OPEN lst_sch_dt_cur(p_term_id);
            FETCH lst_sch_dt_cur INTO l_lst_sch_dt, l_counter;
         CLOSE lst_sch_dt_cur;

         IF last_day(l_lst_sch_dt) = l_lst_sch_dt
         THEN
         /* last day of month */
            p_pro_sch_dt := ADD_MONTHS(l_lst_sch_dt - 1, p_freq) + 1;
         ELSE
            p_pro_sch_dt := ADD_MONTHS(l_lst_sch_dt,p_freq);
         END IF;

      END IF;

      pnp_debug_pkg.log('get_sch_info - EXP p_old_lea_term_dt: '||p_old_lea_term_dt);
      pnp_debug_pkg.log('get_sch_info - EXP p_sch_day        : '||TO_CHAR(p_sch_day));
      pnp_debug_pkg.log('get_sch_info - EXP p_no_sch         : '||TO_CHAR(p_no_sch));
      pnp_debug_pkg.log('get_sch_info - EXP p_counter        : '||TO_CHAR(p_counter));
      pnp_debug_pkg.log('get_sch_info - EXP p_sch_dt         : '||p_sch_dt);
      pnp_debug_pkg.log('get_sch_info - EXP p_sch_str_dt     : '||p_sch_str_dt);
      pnp_debug_pkg.log('get_sch_info - EXP p_norm_str_dt    : '||p_norm_str_dt);
      pnp_debug_pkg.log('get_sch_info - EXP p_pro_sch_dt     : '||p_pro_sch_dt);
      pnp_debug_pkg.log('get_sch_info - EXP l_lst_sch_dt     : '||l_lst_sch_dt);


   ELSIF (p_lease_context IN ('ABS', 'ADD', 'ADDEDT', 'ADDAMD') AND p_normalize_flag = 'Y') THEN

      IF p_lease_context = 'ADDAMD' THEN
         l_comm_dt := p_amd_comm_dt;
      ELSE
         l_comm_dt := p_new_lea_comm_dt;
      END IF;

      /* If the payment term is added through ABSTRACT or EDIT, Normalization
         should start from max(Lease Commencement Date, (first_day(last approved_schedule)+1 month)).
         If the payment term is added through AMENDMENT, Normalization
         should start from max(Amendment Commencement Date, (first_day(last approved_schedule)+1 month)).
      */

      /* If the payment term is added through AMEND, Normalization should start
         from Amendment Commencement Date, if all of the schedules after the amendment
         commencement date are in DRAFT mode.

         Lease            ->  |--------------------------------------------|
         Amend Comm Date  ->      ->|<-
         Schedule         ->      |-----|-----|-----|-----| ...
         Schedule Status  ->       DRAFT DRAFT DRAFT DRAFT
         Normalize Item   ->        |---|-----|-----|-----| ...

         If some of the schedule starting from the Amendment Commencement Date are approved ,
         Normalization should start from the 1st day of the month after the last APPROVED schedule.

         Lease            ->  |--------------------------------------------|
         Amend Comm Date  ->      ->|<-
         Schedule         ->      |-----|-----|-----|-----| ...
         Schedule Status  ->       DRAFT APPRV DRAFT DRAFT
         Normalize Item   ->                  |-----|-----| ...

      */

      /* AMT-RETRO */
      IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
        OPEN csr_last_app_sch (g_lease_id, l_comm_dt);
           FETCH csr_last_app_sch INTO l_last_app_sch;
        CLOSE csr_last_app_sch;

        IF l_last_app_sch IS NULL THEN
           p_norm_str_dt := l_comm_dt;
        ELSE
           p_norm_str_dt := GREATEST(l_comm_dt, l_last_app_sch);
        END IF;
      ELSE
        p_norm_str_dt := l_comm_dt;
      END IF;
	      /*--- Bug#7149537---*/
 	         IF p_lease_context = 'ADDAMD' THEN
 	           p_norm_str_dt := l_comm_dt;
 	         END IF;
 	         /*--- Bug#7149537---*/

      /* Set the first schedule date for the cash item */

      p_sch_dt := TO_DATE(p_sch_day||'/'||TO_CHAR(LEAST(p_norm_str_dt, p_term_start_dt),'MM/YYYY'),'DD/MM/YYYY');

      /* Schedule-Start-Date (p_sch_str_dt) should be the Term Start Day of the month of
         the schedule YYYYMM. (Used only for a Non Monthly Term) */

      /* 3009793 */

      IF p_freq_code IN ('MON', 'OT') THEN

        p_sch_str_dt := NULL;

      ELSE

        IF l_yr_start_dt IS NOT NULL THEN
           get_sch_start(p_yr_start_dt => l_yr_start_dt,
                         p_freq_code => p_freq_code,
                            p_term_start_dt => p_term_start_dt,
                         p_sch_str_dt => p_sch_str_dt);

        ELSE

          IF TO_NUMBER(TO_CHAR(p_term_start_dt,'DD')) >
             TO_NUMBER(TO_CHAR(LAST_DAY(LEAST(p_norm_str_dt, p_term_start_dt)),'DD')) THEN

            p_sch_str_dt := LAST_DAY(LEAST(p_norm_str_dt, p_term_start_dt));

          ELSE

            p_sch_str_dt := TO_DATE(TO_CHAR(p_term_start_dt,'DD')
                                ||'/'
                                ||TO_CHAR(LEAST(p_norm_str_dt, p_term_start_dt),'MM/YYYY'),
                          'DD/MM/YYYY');
          END IF;

        END IF;

      END IF;

     /* No. of months for which the cash items have to be created */

      p_no_sch := CEIL(MONTHS_BETWEEN(LAST_DAY(p_new_lea_term_dt),
                                      First_Day(p_sch_dt)));

      /* Counter for creation of the cash items */

      p_counter := 0;

      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_old_lea_term_dt: '
                     ||p_old_lea_term_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_day        : '
                     ||TO_CHAR(p_sch_day));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_no_sch         : '
                     ||TO_CHAR(p_no_sch));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_counter        : '
                     ||TO_CHAR(p_counter));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_dt         : '
                     ||p_sch_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_str_dt     : '
                     ||p_sch_str_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_norm_str_dt    : '
                     ||p_norm_str_dt);

   ELSIF p_lease_context IN ('ABS', 'ADD', 'ADDEDT', 'ADDAMD') AND (NVL(p_normalize_flag,'N') <> 'Y') THEN

      /* If payment term is not normalized then schedules are to be created depending
         upon the frequency of payment. */

      IF p_freq_code = 'MON' THEN

         l_mths_for_sch := MONTHS_BETWEEN(LAST_DAY(p_term_end_dt)+1, FIRST_DAY(p_term_start_dt));
         p_no_sch := l_mths_for_sch;

      ELSIF p_freq_code = 'OT' THEN

         p_no_sch := 1;

      ELSE

         l_mths_for_sch := CEIL(MONTHS_BETWEEN(p_term_end_dt+1, p_term_start_dt));
         p_no_sch := CEIL(l_mths_for_sch/p_freq);

      END IF;

      p_sch_dt := TO_DATE(p_sch_day||'/'||TO_CHAR(p_term_start_dt,'MM/YYYY'),'DD/MM/YYYY');

      /* Schedule-Start-Date (p_sch_str_dt) should be the Term Start Day of the month of
         the schedule YYYYMM. (Used only for a Non Monthly Term) */

      -- Bug 7570052
      IF l_yr_start_dt IS NOT NULL AND p_freq_code NOT IN ('MON','OT') THEN
        get_sch_start( p_yr_start_dt   => l_yr_start_dt,
                       p_freq_code     => p_freq_code,
                       p_term_start_dt => p_term_start_dt,
                       p_sch_str_dt    => p_sch_str_dt
                     );

        l_mths_for_sch := CEIL(MONTHS_BETWEEN(p_term_end_dt+1, p_sch_str_dt));
        p_no_sch := CEIL(l_mths_for_sch/p_freq);
      ELSE
        p_sch_str_dt := p_term_start_dt;
      END IF;

      p_counter := 0;

      /* For Not Normalized Terms, Normalize Start Date is NULL. */

      p_norm_str_dt := NULL;

      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  mths_for_sch     : '
                     ||TO_CHAR(l_mths_for_sch));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_old_lea_term_dt: '
                     ||p_old_lea_term_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_day        : '
                     ||TO_CHAR(p_sch_day));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_no_sch         : '
                     ||TO_CHAR(p_no_sch));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_counter        : '
                     ||TO_CHAR(p_counter));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_dt         : '
                     ||p_sch_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_str_dt     : '
                     ||p_sch_str_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_norm_str_dt    : '
                     ||p_norm_str_dt);

   ELSIF p_lease_context = 'EXP' AND (NVL(p_normalize_flag,'N') <> 'Y') THEN

      IF p_freq_code = 'MON' THEN

         l_mths_for_sch := MONTHS_BETWEEN(LAST_DAY(p_term_end_dt)+1, FIRST_DAY(p_term_start_dt));
         p_no_sch := l_mths_for_sch;

      ELSIF p_freq_code = 'OT' THEN

         p_no_sch := 1;

      ELSE

         l_mths_for_sch := CEIL(MONTHS_BETWEEN(p_term_end_dt+1, p_term_start_dt));
         p_no_sch := CEIL(l_mths_for_sch/p_freq);

      END IF;

      OPEN lst_sch_dt_cur(p_term_id);
         FETCH lst_sch_dt_cur INTO l_lst_sch_dt, l_counter;
      CLOSE lst_sch_dt_cur;

      p_sch_dt := TO_DATE(TO_CHAR(p_sch_day)||'/'
                                  ||TO_CHAR(ADD_MONTHS(l_lst_sch_dt,p_freq),'MM/YYYY'),
                          'DD/MM/YYYY');

      /* Schedule-Start-Date (p_sch_str_dt) should be the Term Start Day of the month of
         the schedule YYYYMM. (Used only for a Non Monthly Term) */

      /* 3009793 */

      IF p_freq_code IN ('MON', 'OT') THEN

        p_sch_str_dt := NULL;

      ELSE

        IF TO_NUMBER(TO_CHAR(p_term_start_dt,'DD')) >
           TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(l_lst_sch_dt,p_freq)),'DD')) THEN

          p_sch_str_dt := LAST_DAY(ADD_MONTHS(l_lst_sch_dt,p_freq));

        ELSE

          p_sch_str_dt := TO_DATE(TO_CHAR(p_term_start_dt,'DD')
                                ||'/'
                                ||TO_CHAR(ADD_MONTHS(l_lst_sch_dt,p_freq),'MM/YYYY')
                        ,'DD/MM/YYYY');
        END IF;

      END IF;

      p_counter := l_counter;

      /* For Not Normalized Terms, Normalize Start Date is NULL. */

      p_norm_str_dt := NULL;

      /* Get the first date for which a non-zero cash item has to inserted in case of
        normalized payment terms. */

      p_pro_sch_dt := p_sch_dt;

      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  mths_for_sch     : '
                     ||TO_CHAR(l_mths_for_sch));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_old_lea_term_dt: '
                     ||p_old_lea_term_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_day        : '
                     ||TO_CHAR(p_sch_day));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_no_sch         : '
                     ||TO_CHAR(p_no_sch));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_counter        : '
                     ||TO_CHAR(p_counter));
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_dt         : '
                     ||p_sch_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_sch_str_dt     : '
                     ||p_sch_str_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_norm_str_dt    : '
                     ||p_norm_str_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_pro_sch_dt     : '
                     ||p_pro_sch_dt);
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  l_lst_sch_dt     : '
                     ||l_lst_sch_dt);

   END IF;

   /* Get the first date for which a non-zero cash item has to inserted in case of
      normalized payment terms. */

   IF p_lease_context in ('ABS','ADD', 'ADDEDT','ADDAMD') THEN

      p_pro_sch_dt := TO_DATE(p_sch_day||'/'||TO_CHAR(p_term_start_dt,'MM/YYYY'),'DD/MM/YYYY');
      pnp_debug_pkg.log('get_sch_info - ' || p_lease_context || '  p_pro_sch_dt     : '||p_pro_sch_dt);

   END IF;

   /* p_sch_str_dt is used only for Non Monthly Payment Terms.
      For One Time and Monthly Payment Terms, set p_sch_str_dt to NULL. */

   pnp_debug_pkg.log('get_sch_info - OUT: p_pro_sch_dt      : '||p_pro_sch_dt);
   pnp_debug_pkg.log('get_sch_info - OUT: p_no_sch          : '||p_no_sch);
   pnp_debug_pkg.log('get_sch_info - OUT: p_freq            : '||p_freq);
   pnp_debug_pkg.log('get_sch_info - OUT: p_counter         : '||p_counter);
   pnp_debug_pkg.log('get_sch_info - OUT: p_sch_dt          : '||p_sch_dt);
   pnp_debug_pkg.log('get_sch_info - OUT: p_norm_str_dt     : '||p_norm_str_dt);
   pnp_debug_pkg.log('get_sch_info - OUT: p_sch_str_dt      : '||p_sch_str_dt);
   pnp_debug_pkg.log('get_sch_info -End- (-)');

END get_sch_info;


--------------------------------------------------------------------------------------------
--  FUNCTION   : GET_PRO_AMT
--  DESCRIPTION: This function returns the actual amount of a particular schedule. If the
--               partial start and/or partial end flags are true, the amount is prorated
--               accordingly depending on the given schedule and tern start and end dates.
--  25-JUN-2001  Mrinal Misra    o Created.
--  26-MAR-2002  Satish Tripathi o Simplified.
--  09-JAN-2003  Satish Tripathi o Modified to calculate pro amt with partial months logic
--                                 for Days-in-Month and Non-Monthly terms. BUG# 2733753.
--------------------------------------------------------------------------------------------
FUNCTION get_pro_amt (p_sch_str_dt    DATE,
                      p_sch_end_dt    DATE,
                      p_trm_str_dt    DATE,
                      p_trm_end_dt    DATE,
                      p_mth_amt       NUMBER,
                      p_pr_rule       VARCHAR2,
                      p_partial_start VARCHAR2,
                      p_partial_end   VARCHAR2)
RETURN   NUMBER
IS

   l_mths                          NUMBER;
   l_pr_mths                       NUMBER;
   l_pr_rule                       NUMBER;
   l_pr_days                       NUMBER;
   l_pr_amt                        NUMBER;
   l_partial_start_days            NUMBER;
   l_partial_end_days              NUMBER;
   l_freq                          NUMBER;
   l_partial_start_mths            NUMBER;
   l_partial_end_mths              NUMBER;
   l_full_start_mths               NUMBER;
   l_full_end_mths                 NUMBER;
   l_pro_type                      VARCHAR2(1000) := p_pr_rule;

BEGIN

   pnp_debug_pkg.log('get_pro_amt +Start+ (+) -In- p_pr_rule: '||p_pr_rule);
   pnp_debug_pkg.log('get_pro_amt IN: p_sch_str_dt     : '||p_sch_str_dt);
   pnp_debug_pkg.log('get_pro_amt IN: p_sch_end_dt     : '||p_sch_end_dt);
   pnp_debug_pkg.log('get_pro_amt IN: p_trm_str_dt     : '||p_trm_str_dt);
   pnp_debug_pkg.log('get_pro_amt IN: p_trm_end_dt     : '||p_trm_end_dt);
   pnp_debug_pkg.log('get_pro_amt IN: p_mth_amt        : '||p_mth_amt);
   pnp_debug_pkg.log('get_pro_amt IN: p_pr_rule        : '||p_pr_rule);
   pnp_debug_pkg.log('get_pro_amt IN: p_partial_start  : '||p_partial_start);
   pnp_debug_pkg.log('get_pro_amt IN: p_partial_end    : '||p_partial_end);

   l_mths := CEIL(MONTHS_BETWEEN(p_sch_end_dt, p_sch_str_dt));
   l_freq := l_mths;
   l_pr_days := ((p_sch_end_dt - p_sch_str_dt) + 1);

   IF p_pr_rule = 999 THEN

      l_pr_rule := TO_NUMBER(TO_CHAR(LAST_DAY(p_sch_str_dt),'DD'));

   ELSE

      l_pr_rule := p_pr_rule;

   END IF;

   IF p_partial_start = 'Y' THEN

      l_partial_start_days := ABS(p_sch_str_dt - p_trm_str_dt);
      l_full_start_mths    := FLOOR(ABS(MONTHS_BETWEEN(p_trm_str_dt, p_sch_str_dt)));

      l_partial_start_mths := l_full_start_mths +
                              ABS(p_trm_str_dt - ADD_MONTHS(p_sch_str_dt,l_full_start_mths))/TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(p_sch_str_dt, l_full_start_mths)),'DD'));
      pnp_debug_pkg.log('get_pro_amt -partial_start_days: '||l_partial_start_days||
                        ', l_partial_start_mths: '||l_partial_start_mths);

   END IF;

   IF p_partial_end = 'Y' THEN

      l_partial_end_days := ABS(p_sch_end_dt - p_trm_end_dt);
      l_full_end_mths    := FLOOR(ABS(MONTHS_BETWEEN(p_sch_end_dt, p_trm_end_dt)));

      l_partial_end_mths := l_full_end_mths +
                            ABS(ADD_MONTHS(p_sch_end_dt, -1 * l_full_end_mths) - p_trm_end_dt)/TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(p_sch_end_dt +1, -1 * (l_full_end_mths +1))),'DD'));
      pnp_debug_pkg.log('get_pro_amt -partial_end_days: '||l_partial_end_days||
                        ', l_partial_end_mths: '||l_partial_end_mths);

   END IF;

   IF p_partial_start = 'Y' OR p_partial_end = 'Y' THEN

      l_pr_days := l_pr_days - NVL(l_partial_start_days,0) - NVL(l_partial_end_days,0);
      l_pr_mths := l_mths - NVL(l_partial_start_mths,0) - NVL(l_partial_end_mths,0);
      pnp_debug_pkg.log('get_pro_amt -l_pr_days Final: '||l_pr_days||
                        ', l_pr_mths Final: '||l_pr_mths);

      IF p_pr_rule = 999 THEN
         IF l_freq = 1 THEN -- For Monthly Term, Use prorated days.
            l_pr_amt := ROUND((p_mth_amt / l_pr_rule) * l_pr_days, 2);
            l_pro_type := '999-MONTHLY';
         ELSE               -- For Non-Monthly Term, Use prorated months.
            l_pr_amt := ROUND(p_mth_amt  * l_pr_mths, 2);
            l_pro_type := '999-NON-MTH';
         END IF;
      ELSE
         l_pr_amt := ROUND((p_mth_amt * 12 / l_pr_rule) * l_pr_days, 2);
      END IF;

   ELSE

      l_pr_amt := ROUND(p_mth_amt * l_mths, 2);

   END IF;

   pnp_debug_pkg.log('get_pro_amt -End- (-) : Pro Type: '||l_pro_type||
                     ', l_pr_amt: '||l_pr_amt);

   RETURN l_pr_amt;

END get_pro_amt;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : GET_AMOUNT
--  DESCRIPTION: This procedure checks whether the given schedule lies within or out NOCOPY of given
--               term start and end date. It then sets the partial end flags accordingly and
--               calls the function GET_PRO_AMT to get and return the Cash Amount.
--  25-JUN-2001  Mrinal Misra    o Created.
--  09-JAN-2002  Francisco T     o Added NVL(g_pr_rule, p_pro_rule). The point in doing NVL
--                                 is so that p_pro_rule can substitute for g_pr_rule in the
--                                 case that it is not defined, in which case the default
--                                 will be null [refer to bug 1845607, and update_pnt_items()
--                                 procedure in PNTPYTRB.pls]
--  07-FEB-2002  Satish Tripathi o Added condition for Lease Context ADDAMD.
--------------------------------------------------------------------------------------------
PROCEDURE get_amount (p_sch_str_dt    IN  DATE,
                      p_sch_end_dt    IN  DATE,
                      p_trm_str_dt    IN  DATE,
                      p_trm_end_dt    IN  DATE,
                      p_act_amt       IN  NUMBER,
                      p_est_amt       IN  NUMBER,
                      p_freq          IN  NUMBER,
                      p_pro_rule      IN  VARCHAR2,
                      p_cash_act_amt  OUT NOCOPY NUMBER,
                      p_cash_est_amt  OUT NOCOPY NUMBER)
IS

   l_cash_act_amt                  pn_payment_items.actual_amount%TYPE;
   l_partial_start                 VARCHAR2(1);
   l_partial_end                   VARCHAR2(1);

BEGIN

   pnp_debug_pkg.log('get_amount +Start+ (+)');
   pnp_debug_pkg.log('get_amount IN: p_sch_str_dt : '||p_sch_str_dt);
   pnp_debug_pkg.log('get_amount IN: p_sch_end_dt : '||p_sch_end_dt);
   pnp_debug_pkg.log('get_amount IN: p_trm_str_dt : '||p_trm_str_dt);
   pnp_debug_pkg.log('get_amount IN: p_trm_end_dt : '||p_trm_end_dt);
   pnp_debug_pkg.log('get_amount IN: p_act_amt    : '||p_act_amt);
   pnp_debug_pkg.log('get_amount IN: p_est_amt    : '||p_est_amt);
   pnp_debug_pkg.log('get_amount IN: p_freq       : '||p_freq);
   pnp_debug_pkg.log('get_amount IN: p_pro_rule   : '||p_pro_rule);

   /* If the schedule lies completely outside the payment term range
      then the payment item amount will be equal to zero

      Payment Term ->        |------------|
      Schedule     ->  |---|

      Payment Term ->  |------------|
      Schedule     ->                  |---|

      Note : This condition will arise when the payment term is normalized and lies
             completely within the main lease commencement and termination date.
    */

      pnp_debug_pkg.log('get_amount -In- p_sch_str_dt:  '||TO_CHAR(p_sch_str_dt,'DD-MON-YYYY'));
      pnp_debug_pkg.log('get_amount -In- p_sch_end_dt:  '||TO_CHAR(p_sch_end_dt,'DD-MON-YYYY'));
      pnp_debug_pkg.log('get_amount -In- p_trm_str_dt:  '||TO_CHAR(p_trm_str_dt,'DD-MON-YYYY'));
      pnp_debug_pkg.log('get_amount -In- p_trm_end_dt:  '||TO_CHAR(p_trm_end_dt,'DD-MON-YYYY'));

      IF (p_sch_str_dt < p_trm_str_dt AND p_sch_end_dt < p_trm_str_dt) OR
         (p_sch_str_dt > p_trm_end_dt AND p_sch_end_dt > p_trm_end_dt) THEN

         p_cash_est_amt := NULL;
         p_cash_act_amt := 0;

   /* If the schedule lies completely within the payment term start
      date and payment term end date then the payment item amount
      will be equal to the amount specified in the payment term

      Payment Term ->  |--------------------------|
      Schedule     ->       |------|
    */

      ELSIF p_sch_str_dt > p_trm_str_dt AND p_sch_end_dt < p_trm_end_dt THEN
         p_cash_est_amt := p_est_amt;
         p_cash_act_amt := NVL(p_act_amt, p_est_amt);

      ELSE

         /* If the first day of the schedule date is earlier than the
            start date of the term and last day of the schedule is
            greater than the start date of the term

            Scenario 1 - partial start and partial end.

            Payment Term ->      |--|
            Schedule     ->    |------|

            Scenario 2 - partial start and full end.

            Payment Term ->      |--------------------------|
            Schedule     ->    |------|

            Scenario 3 - partial start and full end.

            Payment Term ->      |----|
            Schedule     ->    |------|
          */

          IF p_trm_str_dt > p_sch_str_dt  THEN

              /* If partial start and partial end set the flags apprioriately */

              IF (p_trm_end_dt > p_sch_str_dt AND p_trm_end_dt < p_sch_end_dt) THEN

                 pnp_debug_pkg.log('get amount - partial start partial end ');
                 l_partial_start := 'Y';
                 l_partial_end := 'Y';

              ELSE  /* partial start and full end */

                 pnp_debug_pkg.log('get amount - partial start full end ');
                 l_partial_start := 'Y';
                 l_partial_end := 'N';

              END IF;

          ELSIF p_trm_str_dt <= p_sch_str_dt THEN   /* full start */

             IF p_trm_end_dt >= p_sch_end_dt  THEN /* full start and full end */

                 pnp_debug_pkg.log('get amount - full start full end ');

                l_partial_start := 'N';
                l_partial_end := 'N';

             ELSE   /* full start and partial end */

                pnp_debug_pkg.log('get amount - full start partial end ');
                l_partial_start := 'N';
                l_partial_end := 'Y';

             END IF;

          END IF;

          /* We will always need the pro-rated actual amount irrespective of whether
             we derive it from the estimated or actual term amount */

             l_cash_act_amt := get_pro_amt(p_sch_str_dt    => p_sch_str_dt,
                                           p_sch_end_dt    => p_sch_end_dt,
                                           p_trm_str_dt    => p_trm_str_dt,
                                           p_trm_end_dt    => p_trm_end_dt,
                                           p_mth_amt       => NVL(p_act_amt, p_est_amt)/p_freq,
                                           p_pr_rule       => NVL(g_pr_rule,p_pro_rule),
                                           p_partial_start => l_partial_start,
                                           p_partial_end   => l_partial_end);

             p_cash_act_amt := l_cash_act_amt;

          /* Get the pro-rated estimated amount only if the estimated and actual amounts
             of the term are not null */

          IF p_act_amt IS NOT NULL AND p_est_amt IS NOT NULL THEN

             p_cash_est_amt := get_pro_amt(p_sch_str_dt    => p_sch_str_dt,
                                           p_sch_end_dt    => p_sch_end_dt,
                                           p_trm_str_dt    => p_trm_str_dt,
                                           p_trm_end_dt    => p_trm_end_dt,
                                           p_mth_amt       => p_est_amt/p_freq,
                                           p_pr_rule       => NVL(g_pr_rule,p_pro_rule),
                                           p_partial_start => l_partial_start,
                                           p_partial_end   => l_partial_end);

          ELSIF p_act_amt IS NULL AND p_est_amt IS NOT NULL THEN

             p_cash_est_amt := l_cash_act_amt;

          END IF;

   END IF;

   pnp_debug_pkg.log('get_amount -OUT- p_cash_act_amt:  '||TO_CHAR(p_cash_act_amt));
   pnp_debug_pkg.log('get_amount -OUT- p_cash_est_amt:  '||TO_CHAR(p_cash_est_amt));

   pnp_debug_pkg.log('get_amount -End- (+)');

END get_amount;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : CREATE_SCHEDULE
--  DESCRIPTION: This procedure checks whether a schedule exists for a given lease id and
--               given schedule date. If no schedule exists, create the schedule and
--               return back the schedule Id.
--  25-JUN-2001  Mrinal Misra    o Created.
-- 15-JUL-05  hareesha o Bug 4284035 - Replaced pn_payment_schedules with _ALL table.
-- 28-NOV-06  Hareesha o Added p_payent_term_id as parameter. IF there exist items and
--                       approved schedule due to LOF/SGN and then change to ACT and finalize,
--                       the schedules for other terms on the approved schedule date was not
--                       getting created.
-- 24-AUG-08  rkartha o Bug	6829173 - In cursor check_sch, pick the DRAFT schedule if the
--                      schedule date has both a draft and approved schedule.
--------------------------------------------------------------------------------------------
PROCEDURE create_schedule (p_lease_id            NUMBER,
                           p_lc_id               NUMBER,
                           p_sch_dt              DATE,
                           p_sch_id          OUT NOCOPY NUMBER,
                           p_pymnt_st_lkp_cd OUT NOCOPY VARCHAR2,
                           p_payment_term_id     NUMBER)
IS

   l_sch_id                        pn_payment_schedules.payment_schedule_id%TYPE;
   l_pymnt_st_lkp_cd               pn_payment_schedules.payment_status_lookup_code%TYPE;

   	    /*--- Bug#7149537---*/
 	    l_sch_id_1                      pn_payment_schedules.payment_schedule_id%TYPE;
 	    l_pymnt_st_lkp_cd_1             pn_payment_schedules.payment_status_lookup_code%TYPE;
 	    /*--- Bug#7149537---*/
   CURSOR check_sch IS
      SELECT payment_schedule_id,
             payment_status_lookup_code
      FROM   pn_payment_schedules_all
      WHERE  schedule_date = p_sch_dt
      AND    lease_id      = p_lease_id
      ORDER BY payment_status_lookup_code DESC;


   CURSOR org_cur IS
     SELECT org_id
     FROM pn_leases_all
     WHERE lease_id = p_lease_id;

   CURSOR sched_exists(p_payment_term_id NUMBER,p_sch_dt DATE) IS
       SELECT sched.payment_schedule_id, payment_status_lookup_code
      FROM pn_payment_items_all item,
           pn_payment_schedules_all sched
      WHERE item.payment_term_id = p_payment_term_id
      AND   item.payment_schedule_id = sched.payment_schedule_id
      AND   sched.schedule_date = p_sch_dt;

   l_org_id NUMBER;
   l_sched_exists VARCHAR2(1);
   l_schd_date          DATE;

BEGIN

   FOR rec IN org_cur LOOP
     l_org_id := rec.org_id;
   END LOOP;

   OPEN  check_sch;
      FETCH check_sch INTO l_sch_id, l_pymnt_st_lkp_cd;

      IF check_sch%NOTFOUND THEN

         SELECT pn_payment_schedules_s.NEXTVAL
         INTO   l_sch_id
         FROM   DUAL;

         l_pymnt_st_lkp_cd := 'DRAFT';

         INSERT INTO pn_payment_schedules_all

           (payment_schedule_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            schedule_date,
            lease_id,
            lease_change_id,
            payment_status_lookup_code,
            org_id)

         VALUES

           (l_sch_id,
            SYSDATE,
            NVL(fnd_profile.value('USER_ID'),0),
            SYSDATE,
            NVL(fnd_profile.value('USER_ID'),0),
            NVL(fnd_profile.value('LOGIN_ID'),0),
            p_sch_dt,
            p_lease_id,
            p_lc_id,
            l_pymnt_st_lkp_cd,
            l_org_id);

         pnp_debug_pkg.log('create_schedule - created schedule id: '||TO_CHAR(l_sch_id)
                           ||' - ('||p_sch_dt||')');

       ELSIF l_pymnt_st_lkp_cd <> 'DRAFT' THEN  /* 7149537 */

         l_pymnt_st_lkp_cd := 'DRAFT';
         l_schd_date :=   p_sch_dt;

         /* check to see  if the schedule date is already used by this payment term
            in the payment items table,in this case the calling procedure
            should not create the terms */

         l_sched_exists := 'N';
         IF p_payment_term_id IS NOT NULL THEN

            FOR rec IN sched_exists(p_payment_term_id, l_schd_date) LOOP
               l_sched_exists := 'Y';
			    /*---- Bug#7149537------------*/
 	                 l_sch_id_1           := rec.payment_schedule_id;
 	                 l_pymnt_st_lkp_cd_1  := rec.payment_status_lookup_code;
 	                 IF l_pymnt_st_lkp_cd_1 = 'DRAFT' THEN
 	                    l_sch_id := l_sch_id_1 ;
						else
						 l_sched_exists := 'N';   /* 7149537 */
 	                 END IF;
 	      /*---- Bug#7149537------------*/
            END LOOP;

            IF l_sched_exists = 'N' THEN
               BEGIN

                  SELECT  payment_schedule_id,
                          payment_status_lookup_code
                  INTO l_sch_id, l_pymnt_st_lkp_cd
                  FROM  pn_payment_schedules_all
                  WHERE lease_id = p_lease_id
                  AND   schedule_date = l_schd_date
                  AND  payment_status_lookup_code = l_pymnt_st_lkp_cd
                  AND ROWNUM = 1;

               EXCEPTION WHEN NO_DATA_FOUND THEN
                  SELECT pn_payment_schedules_s.NEXTVAL INTO l_sch_id
                  FROM DUAL;

                  INSERT INTO pn_payment_schedules_all(
                                  payment_schedule_id,
                                  last_update_date,
                                  last_updated_by,
                                  creation_date,
                                  created_by,
                                  last_update_login,
                                  schedule_date,
                                  lease_id,
                                  lease_change_id,
                                  payment_status_lookup_code,
                                  org_id)
                   VALUES        (l_sch_id,
                                  SYSDATE,
                                  NVL(fnd_profile.value('USER_ID'),0),
                                  SYSDATE,
                                  NVL(fnd_profile.value('USER_ID'),0),
                                  NVL(fnd_profile.value('LOGIN_ID'),0),
                                  l_schd_date,
                                  p_lease_id,
                                  p_lc_id,
                                  l_pymnt_st_lkp_cd,
                                  l_org_id);
               END;
            END IF;
         END IF;

      END IF;

      p_sch_id           := l_sch_id;
      p_pymnt_st_lkp_cd  := l_pymnt_st_lkp_cd;

   CLOSE check_sch;

END create_schedule;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : CREATE_CASH_ITEMS
--  DESCRIPTION: This procedure creates the cash items by inserting given amount, schedule Id
--               and date, term Id etc. in the table PN_PAYMENT_ITEMS.
--  25-JUN-2001  created    mmisra
--  26-APR-2002  modified   ftanudja   o added p_rate
-- 15-JUL-05  hareesha o Bug 4284035 - Replaced pn_payment_items with _ALL table.
-- 09-JAN-07  Hareesha o M28#16 for Recurring backbills, populate the due_date as
--                       calculation date into pn_payment_items_all
--  24-APR-07  Hareesha  o Bug #5899113 Default inv-grping rule set at term-level to
--                         items.
--------------------------------------------------------------------------------------------
PROCEDURE create_cash_items (p_est_amt           NUMBER,
                             p_act_amt           NUMBER,
                             p_sch_dt            DATE,
                             p_sch_id            NUMBER,
                             p_term_id           NUMBER,
                             p_vendor_id         NUMBER,
                             p_cust_id           NUMBER,
                             p_vendor_site_id    NUMBER,
                             p_cust_site_use_id  NUMBER,
                             p_cust_ship_site_id NUMBER,
                             p_sob_id            NUMBER,
                             p_curr_code         VARCHAR2,
                             p_rate              NUMBER)
IS

   l_precision                     NUMBER;
   l_ext_precision                 NUMBER;
   l_min_acct_unit                 NUMBER;
   l_payment_item_id               pn_payment_items.payment_item_id%TYPE;
   l_actual_amount                 pn_payment_items.actual_amount%TYPE;

   CURSOR org_cur IS
     SELECT org_id
     FROM pn_payment_terms_all
     WHERE payment_term_id = p_term_id;

   CURSOR get_calc_date_recur_bb ( p_term_id IN NUMBER) IS
      SELECT recur_bb_calc_date
      FROM pn_payment_terms_all
      WHERE payment_term_id = p_term_id
      AND recur_bb_calc_date IS NOT NULL;

   CURSOR get_inv_grp_rule IS
      SELECT grouping_rule_id
      FROM pn_payment_terms_all
      WHERE payment_term_id = p_term_id;

   l_org_id NUMBER;
   l_sch_dt DATE := p_sch_dt;
   l_inv_grp_rule NUMBER := NULL;

BEGIN

   /* Get the correct precision for the currency so that the amount can be rounded off
      before inserting */

   fnd_currency.get_info(p_curr_code, l_precision, l_ext_precision, l_min_acct_unit);

   FOR rec IN org_cur LOOP
     l_org_id := rec.org_id;
   END LOOP;

   IF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'RECUR' THEN

      FOR rec IN get_calc_date_recur_bb(p_term_id) LOOP
         l_sch_dt := rec.recur_bb_calc_date;
      END LOOP;

   END IF;

   FOR rec IN get_inv_grp_rule LOOP
      l_inv_grp_rule := rec.grouping_rule_id;
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
    org_id,
    grouping_rule_id)

   VALUES
   (PN_PAYMENT_ITEMS_S.NEXTVAL,
    SYSDATE,
    NVL(fnd_profile.value('USER_ID'),0),
    SYSDATE,
    NVL(fnd_profile.value('USER_ID'),0),
    NVL(fnd_profile.value('LOGIN_ID'),0),
    ROUND(p_act_amt,l_precision),
    ROUND(p_est_amt,l_precision),
    l_sch_dt,
    'CASH',
    p_term_id,
    p_sch_id,
    1,
    p_vendor_id,
    p_cust_id,
    p_vendor_site_id,
    p_cust_site_use_id,
    p_cust_ship_site_id,
    p_sob_id,
    p_curr_code,
    p_curr_code,
    ROUND(p_act_amt, l_precision),
    p_rate,
    l_org_id,
    l_inv_grp_rule)
    RETURNING payment_item_id, actual_amount INTO l_payment_item_id, l_actual_amount;

   pnp_debug_pkg.log('create_cash_items OUT: payment_item_id:  '||l_payment_item_id
                     ||', actual_amount: '||l_actual_amount);

EXCEPTION

   WHEN OTHERS THEN
      RAISE;

END create_cash_items;


------------------------------------------------------------------------------
--  PROCEDURE  : CREATE_NORMALIZE_ITEMS
--  DESCRIPTION:
--   This procedure sums up the Cash amount of a given term,
--   calculates the monthly normalize amount, prorated the first
--   and/or last month's amount if needed and finally creates Normalize
--   items by inserting row in table PN_PAYMENT_ITEMS.
-- 25-JUN-01  Mrinal   o Created.
-- 18-OCT-01  Mrinal   o Added parameter p_sch_day. Where ever using the
--                       ADD_MONTHS function, derived date by concatination
--                       of 'DD' component except for end dates.
-- 04-DEC-01  Satish   o Fixed the problem of proration calculation of
--                       normalized amount for partial-start and partial-end
--                       month.
-- 24-JAN-02  Satish   o Added parameters p_norm_str_dt, p_norm_end_dt.
--                       Normalized items will be created from p_norm_str_dt
--                       to p_norm_end_dt. The program calling
--                       create_normalize_items will now have to calculate
--                       and pass normalization start and end date paramaters
-- 26-APR-02  ftanudja o Added parameter p_rate
-- 07-OCT-02  Ashish   o BUG#2590872 $0 invoice enhancement
--                       update the PN_PAYMENT_TERMS SET EVENT_TYPE_CODE
--                                   = P_LEASE_CONTEXT
-- 18-NOV-02  Satish   o Fix for BUG# 2646928. Modified to adjust the rounding
--                       issue of Normalize amount. Adjust the difference
--                       in the last iteration so that sum of Cash and
--                       Normalize amounts are equal. Added variables
--                       l_prec_norm_amt, l_tot_cum_diff_amt etc.
-- 30-MAY-03  Satish   o Fix for BUG# 2957811. Modified SQL Select clause from
--                       LEAST(p_norm_end_dt, LAST_DAY(MAX(pps.schedule_date))) to
--                       LEAST(p_norm_end_dt,
--                        NVL(LAST_DAY(MAX(pps.schedule_date)), p_norm_end_dt))
--                       If there is no DRAFT schedule, don't return NULL
--                       and error out. Added IF l_norm_mths > 0 THEN
--                       to Exit create_normalize_items if l_norm_mths = 0.
-- 16-OCT-03  Satish   o Fix for BUG# 3201091. Added parameter
--                       p_lease_change_id, to use instead of g_lc_id.
-- 24-DEC-03  Satish   o Fix for BUG# 3306681. If l_norm_mths <= 1 month then
--                       l_monthly_norm_amt := l_total_cash_amt - l_la_amt.
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_payment_items with _ALL.
-- 24-NOV-05  Kiran    o Round amounts befor insert/uptdate into terms OR items.
-- 09-JAN-07  Hareesha o M28#16 for Recurring backbills, populate the due_date as
--                       calculation date into pn_payment_items_all
--  24-APR-07  Hareesha  o Bug #5899113 Default inv-grping rule set at term-level to
--                         items.
--  24-AUG-08 RKARTHA o Bug 6829173 - When finding the number of approved schedules,
--                      exclude those approved schedules for which on the same
--                      schedule date, there is also a draft schedule.
--  18-SEP-08 jsundara o Bug#6825797. Modified procedure to exclude amount that belong
--                       to schedules in APPROVED or ON_HOLD status while determining
--                       left alone amount.
--  18-MAR-10 acprakas o Bug#9457825. Modified code to take amendment comm date
--                       from latest record in pn_lease_changes_all.
--  08-APR-20 acprakas o Bug#9555190. Modified to consider the schedule for which
--                       normalized item need to be created to check for the existence of
--                       cash item
-------------------------------------------------------------------------------
PROCEDURE create_normalize_items (p_lease_context      VARCHAR2,
                                  p_lease_id           NUMBER,
                                  p_term_id            NUMBER,
                                  p_vendor_id          NUMBER,
                                  p_cust_id            NUMBER,
                                  p_vendor_site_id     NUMBER,
                                  p_cust_site_use_id   NUMBER,
                                  p_cust_ship_site_id  NUMBER,
                                  p_sob_id             NUMBER,
                                  p_curr_code          VARCHAR2,
                                  p_sch_day            NUMBER,
                                  p_norm_str_dt        DATE,
                                  p_norm_end_dt        DATE,
                                  p_rate               NUMBER,
                                  p_lease_change_id    NUMBER)
IS

   l_total_cash_amt                pn_payment_items_all.actual_amount%TYPE;
   l_la_amt                        NUMBER;
   l_norm_amt                      NUMBER;
   l_norm_sch_dt                   DATE;
   l_precision                     NUMBER;
   l_ext_precision                 NUMBER;
   l_min_acct_unit                 NUMBER;
   l_sch_id                        NUMBER;
   l_drft_mths                     NUMBER;
   l_norm_mths                     NUMBER;
   l_mths                          NUMBER;
   l_monthly_norm_amt              NUMBER;
   l_partial_start_fraction        NUMBER;
   l_partial_end_fraction          NUMBER;
   l_partial_start_flag            VARCHAR2(1) := 'N';
   l_partial_end_flag              VARCHAR2(1) := 'N';
   l_day_of_norm_start_dt          VARCHAR2(2) := NULL;
   l_day_of_norm_end_dt            VARCHAR2(2) := NULL;
   l_last_sch_dt                   DATE;
   l_pymnt_st_lkp_cd               pn_payment_schedules.payment_status_lookup_code%TYPE;
   l_counter                       NUMBER;
   l_app_sch                       NUMBER := 0;
   l_norm_end_dt                   DATE;
   l_prec_norm_amt                 NUMBER := 0;
   l_prec_norm_amt_upd             NUMBER := 0;
   l_rows_updated                  NUMBER := 0;
   l_tot_cum_norm_amt              NUMBER := 0;
   l_tot_cum_diff_amt              NUMBER := 0;
   l_org_id                        NUMBER;
   l_app_mths                      NUMBER;  /* 7149537 */
 	 l_amd_comn_date                 DATE;    /* 7149537 */
 	 l_app_amt                       NUMBER := 0;  /* 7149537 */
 	 l_act_amt                       NUMBER;  /* 7149537 */
 	 l_sch_date_1                    DATE;  /* 7149537 */
 	 l_sch_id_1                      NUMBER; /* 7149537 */
 	 l_draft_exist                   NUMBER := 0; /* 7149537 */
 	 l_term_amt        NUMBER:= 0; /* 9231686 */
   l_plr_amt         NUMBER:= 0; /* 9231686 */

   CURSOR get_org_id(l_term_id NUMBER) IS
     SELECT org_id
     FROM pn_payment_terms_all
     WHERE payment_term_id = l_term_id;

	 CURSOR get_drf_sch_date(p_term_id NUMBER) IS
 	    SELECT schedule_date
 	    FROM   pn_payment_items_all ppi,
 	            pn_payment_schedules_all pps
 	    WHERE  ppi.payment_term_id =  p_term_id
 	    AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
 	    AND    pps.payment_schedule_id = ppi.payment_schedule_id
 	    AND    pps.payment_status_lookup_code <>  'DRAFT'
 	    and schedule_date >= l_amd_comn_date
 	    and    schedule_date <=  (SELECT lease_termination_date from
 	     pn_lease_details_all where lease_id = p_lease_id );  /*  7149537 */

 	    CURSOR get_drf_sch(l_norm_sch_dt DATE) IS
 	    select distinct ppi.payment_schedule_id
 	           from pn_payment_items_all ppi
 	               ,pn_payment_schedules_all pps
 	           where exists
 	          (select 1
 	           from pn_payment_items_all ppi , pn_payment_schedules_all pps
 	           where ppi.payment_term_id = p_term_id
 	           and pps.payment_schedule_id = ppi.payment_schedule_id
 	           and payment_status_lookup_code <>  'DRAFT'
 	           and due_date = l_norm_sch_dt
 	           )
 	           and pps.payment_schedule_id = ppi.payment_schedule_id
 	           and ppi.payment_term_id = p_term_id
 	           AND ppi.payment_item_type_lookup_code = 'NORMALIZED'
 	           AND payment_status_lookup_code = 'DRAFT'
 	           and due_date = l_norm_sch_dt
 	           and rownum = 1;  /* 7149537 */
   l_due_date DATE;

   CURSOR get_calc_date_recur_bb ( p_term_id IN NUMBER) IS
      SELECT recur_bb_calc_date
      FROM pn_payment_terms_all
      WHERE payment_term_id = p_term_id
      AND recur_bb_calc_date IS NOT NULL ;

  CURSOR get_inv_grp_rule IS
      SELECT grouping_rule_id
      FROM pn_payment_terms_all
      WHERE payment_term_id = p_term_id;

   l_inv_grp_rule NUMBER := NULL;


BEGIN

/*
select NVL(change_commencement_date,lease_commencement_date )
INTO l_amd_comn_date
from pn_lease_changes_all pc, pn_lease_details_all pd
where pc.lease_id =  p_lease_id
and pd.lease_id = pc.lease_id
and pc.lease_change_id = pd.lease_change_id; */ /*  9231686 */

SELECT change_commencement_date
INTO l_amd_comn_date
FROM
  (SELECT *
   FROM pn_lease_changes_all
   WHERE lease_id = p_lease_id
   ORDER BY lease_change_id DESC)
WHERE rownum < 2;

IF l_amd_comn_date IS NULL
THEN
     SELECT lease_commencement_date
     INTO l_amd_comn_date
     FROM pn_lease_details_all
     WHERE lease_id = p_lease_id;
END IF;

Select NVL(SUM(ppi.actual_amount),0)
into l_term_amt
FROM   pn_payment_items_all ppi,
       pn_payment_schedules_all pps
WHERE  ppi.payment_term_id =  p_term_id
AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
AND    pps.payment_schedule_id = ppi.payment_schedule_id
AND    pps.payment_status_lookup_code <> 'DRAFT'
AND    to_char(schedule_date,'MON-YY')  =  to_char(l_amd_comn_date,'MON-YY'); /* 9231686 */



 	 pnp_debug_pkg.log('create_normalize_items - l_amd_comn_date :=: '||TO_CHAR(l_amd_comn_date));

 	    IF l_amd_comn_date > p_norm_str_dt THEN
 	       l_amd_comn_date := p_norm_str_dt;
 	    END IF;      /* 7149537 */

   pnp_debug_pkg.log('create_normalize_items - l_amd_comn_date1 :=: '||TO_CHAR(l_amd_comn_date));

 	    SELECT NVL(SUM(ppi.actual_amount),0)
 	    INTO l_app_amt
 	    FROM   pn_payment_items_all ppi,
 	            pn_payment_schedules_all pps
 	    WHERE  ppi.payment_term_id =  p_term_id
 	    AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
 	    AND    pps.payment_schedule_id = ppi.payment_schedule_id
 	    AND    pps.payment_status_lookup_code <> 'DRAFT'
 	    and schedule_date >=  FIRST_DAY(l_amd_comn_date)
 	    and    schedule_date <=  (SELECT lease_termination_date from
 	     pn_lease_details_all where lease_id = p_lease_id );          /* 7149537 */


 	    IF l_app_amt IS NOT NULL THEN
 	       pnp_debug_pkg.log('create_normalize_items - l_app_amt :=: '||TO_CHAR(l_app_amt));
 	    ELSE
 	       l_app_amt := 0;
 	    END IF;  /*  7149537  */

   pnp_debug_pkg.log('create_normalize_items +Start+ (+) - Lease Context: '||p_lease_context);
   pnp_debug_pkg.log('create_normalize_items IN: p_lease_id          : '||p_lease_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_term_id           : '||p_term_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_sch_day           : '||p_sch_day);
   pnp_debug_pkg.log('create_normalize_items IN: p_norm_str_dt       : '||p_norm_str_dt);
   pnp_debug_pkg.log('create_normalize_items IN: p_norm_end_dt       : '||p_norm_end_dt);
   pnp_debug_pkg.log('create_normalize_items IN: p_lease_change_id   : '||p_lease_change_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_vendor_id         : '||p_vendor_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_cust_id           : '||p_cust_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_vendor_site_id    : '||p_vendor_site_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_cust_site_use_id  : '||p_cust_site_use_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_cust_ship_site_id : '||p_cust_ship_site_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_sob_id            : '||p_sob_id);
   pnp_debug_pkg.log('create_normalize_items IN: p_rate              : '||p_rate);
   pnp_debug_pkg.log('create_normalize_items IN: p_curr_code         : '||p_curr_code);

   SELECT SUM(ppi.actual_amount)
   INTO   l_total_cash_amt
   FROM   pn_payment_items_all ppi
   WHERE  ppi.payment_term_id = p_term_id
   AND    ppi.payment_item_type_lookup_code = 'CASH';

   pnp_debug_pkg.log('create_normalize_items - total cash       : '||TO_CHAR(l_total_cash_amt));

    /*if (  p_norm_str_dt > l_amd_comn_date ) THEN  */
 	    l_app_mths := CEIL(MONTHS_BETWEEN(p_norm_str_dt,l_amd_comn_date));

 	    pnp_debug_pkg.log('create_normalize_items - l_app_mths :=: '||TO_CHAR(l_app_mths));
   IF p_lease_context IN ('ABS', 'ADD', 'ADDEDT', 'ADDAMD') THEN

      l_la_amt := 0;

   ELSIF p_lease_context IN ('CON','EXP','CONTERM') THEN

      SELECT NVL(SUM(ppi.actual_amount),0)
      INTO   l_la_amt
      FROM   pn_payment_items_all ppi,
             pn_payment_schedules_all pps
      WHERE  ppi.payment_term_id = p_term_id
      AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
      AND    pps.payment_schedule_id = ppi.payment_schedule_id
      AND    pps.payment_status_lookup_code <> 'DRAFT';  --Bug#6825797 'APPROVED';
l_la_amt := l_la_amt - l_app_amt;  /* 7149537 */
   END IF;

   pnp_debug_pkg.log('create_normalize_items - leave alone amt  : '||TO_CHAR(l_la_amt));

   /* Normalized Months required when Normalizing Partial Start,Partial end or both.*/

   l_mths      := CEIL(MONTHS_BETWEEN(LAST_DAY(p_norm_end_dt),
                                      First_Day(p_norm_str_dt)));

   l_mths      :=  l_mths + l_app_mths;  /* 9457938  */
   l_norm_mths := l_mths;

   /* Find the last Schedule date of the term. */

   IF p_lease_context IN ('CON','EXP','CONTERM') THEN
pnp_debug_pkg.log('create_normalize_items - l_sch_id_1 :=: '||TO_CHAR(l_sch_id_1));
 	    pnp_debug_pkg.log('create_normalize_items - p_norm_str_dt :=: '||TO_CHAR(p_norm_str_dt));

      SELECT LEAST(p_norm_end_dt, NVL(LAST_DAY(MAX(pps.schedule_date)), p_norm_end_dt))
      INTO   l_norm_end_dt
      FROM   pn_payment_items_all ppi,
             pn_payment_schedules_all pps
      WHERE  ppi.payment_term_id = p_term_id
      AND    pps.payment_schedule_id = ppi.payment_schedule_id
      AND    pps.payment_status_lookup_code = 'DRAFT';

      pnp_debug_pkg.log('l_norm_end_dt    : '||TO_CHAR(l_norm_end_dt));

      SELECT COUNT(*)
      INTO   l_app_sch
      FROM   pn_payment_items_all ppi,
             pn_payment_schedules_all pps
      WHERE  ppi.payment_term_id = p_term_id
      AND    pps.payment_schedule_id = ppi.payment_schedule_id
      AND    pps.payment_status_lookup_code = 'APPROVED'
      AND    ppi.payment_item_type_lookup_code = 'CASH'
      AND    pps.schedule_date between First_Day(p_norm_str_dt) and LAST_DAY(l_norm_end_dt)
      AND    NOT EXISTS (
                         SELECT 1
                         FROM  pn_payment_schedules_all ppsi,
                               pn_payment_items_all ppii
                         WHERE ppsi.schedule_date = pps.schedule_date
                         AND   ppii.payment_term_id = ppi.payment_term_id
                         AND   ppsi.payment_schedule_id = ppii.payment_schedule_id
                         AND   ppsi.payment_status_lookup_code = 'DRAFT'
                         );

      --l_norm_mths := l_norm_mths - l_app_sch;

   ELSE

      l_norm_end_dt := p_norm_end_dt;

   END IF;

   -- If l_norm_mths = 0 do not re-normalize, exit create_normalize_items.
   IF l_norm_mths > 0 THEN -- Exit create_normalize_items.

   pnp_debug_pkg.log('create_normalize_items - l_mths           : '||TO_CHAR(l_mths));

   l_last_sch_dt := TO_DATE(TO_CHAR(p_sch_day)||'/'||TO_CHAR(l_norm_end_dt,'MM/YYYY'),'DD/MM/YYYY');

   /* Find which day of month the lease starts.*/

   l_day_of_norm_start_dt := TO_CHAR(nvl(l_amd_comn_date,p_norm_str_dt),'DD');  /* 9457938  */

   /* Find which day of month the lease ends. */

   l_day_of_norm_end_dt := TO_CHAR(l_norm_end_dt,'DD');

   /* If partial start month, then calculate the partial fraction of the start month. */

   IF l_day_of_norm_start_dt <> '01' THEN

      l_partial_start_flag := 'Y';

      IF g_pr_rule = 999 THEN

         l_partial_start_fraction := ((LAST_DAY(l_amd_comn_date) - l_amd_comn_date)+1)/
                                     TO_NUMBER(TO_CHAR(LAST_DAY(l_amd_comn_date),'DD'));  /* 9457938  */

      ELSE

         l_partial_start_fraction := ((LAST_DAY(l_amd_comn_date) - l_amd_comn_date)+1)*12/g_pr_rule;

      END IF;

      l_norm_mths := (l_norm_mths - 1) + NVL(l_partial_start_fraction,0);

      pnp_debug_pkg.log('create_normalize_items - l_partial_start_fraction   : '
                        ||TO_CHAR(l_partial_start_fraction));

      l_plr_amt := l_term_amt - (l_partial_start_fraction * l_term_amt);


      pnp_debug_pkg.log('create_normalize_items - l_partial_amount to be left before calc remaining amt for renorm   : '
                           ||TO_CHAR(l_plr_amt)); /* 7561833 */


   END IF;

   /* If partial end month, then calculate the partial fraction of the end month.*/

   IF l_day_of_norm_end_dt <> TO_CHAR(LAST_DAY(l_norm_end_dt),'DD') THEN

      l_partial_end_flag := 'Y';

      IF  g_pr_rule = 999 THEN

         l_partial_end_fraction := TO_NUMBER(l_day_of_norm_end_dt)/
                                   TO_NUMBER(TO_CHAR(LAST_DAY(l_norm_end_dt),'DD'));

      ELSE

         l_partial_end_fraction := TO_NUMBER(l_day_of_norm_end_dt)*12/g_pr_rule;

      END IF;

      l_norm_mths := (l_norm_mths - 1) + NVL(l_partial_end_fraction,0);

      pnp_debug_pkg.log('create_normalize_items - l_partial_end_fraction     : '
                        ||TO_CHAR(l_partial_end_fraction));

   END IF;

   pnp_debug_pkg.log('create_normalize_items - l_norm_mths      : '||TO_CHAR(l_norm_mths));

   IF l_norm_mths <= 1 THEN
      l_monthly_norm_amt := l_total_cash_amt - l_la_amt - l_plr_amt; /* 9231686 */
      l_partial_end_flag := 'N';
      l_partial_start_flag := 'N';
   ELSE
          l_monthly_norm_amt := (l_total_cash_amt - l_la_amt - l_plr_amt )/l_norm_mths; /* 9231686 */
     END IF;
   l_norm_amt := l_monthly_norm_amt;

   pnp_debug_pkg.log('create_normalize_items - normalize amt    : '||TO_CHAR(l_norm_amt));

   fnd_currency.get_info(p_curr_code, l_precision, l_ext_precision, l_min_acct_unit);

   IF p_lease_context IN ('EXP', 'CONTERM') THEN

      DELETE pn_payment_items_all ppi
      WHERE  ppi.payment_schedule_id IN (SELECT pps.payment_schedule_id
                                         FROM   pn_payment_items_all ppi1,
                                                pn_payment_schedules_all pps
                                         WHERE  ppi1.payment_term_id = p_term_id
                                         AND    ppi1.payment_item_type_lookup_code = 'CASH'
                                         AND    pps.payment_schedule_id = ppi1.payment_schedule_id
                                         AND    pps.payment_status_lookup_code = 'DRAFT')
      AND ppi.payment_item_type_lookup_code = 'NORMALIZED'
      AND ppi.payment_term_id = p_term_id;

      pnp_debug_pkg.log('create_normalize_items - deleted normalized items for EXP');

   END IF;

   IF p_lease_context IN ('ABS', 'ADD','ADDEDT', 'ADDAMD', 'EXP', 'CONTERM') THEN

	l_norm_sch_dt := TO_DATE(TO_CHAR(p_sch_day)||'/'||TO_CHAR(l_amd_comn_date,'MM/YYYY'),'DD/MM/YYYY'); /* 8690792 */

      pnp_debug_pkg.log('create_normalize_items - 1st nor. sch.    : '
                        ||TO_CHAR(l_norm_sch_dt,'MM/DD/YYYY'));

      l_counter := 1;

      LOOP

      EXIT WHEN l_counter > l_mths;
 /*---- Bug#7149537-------*/
     -- create_schedule(g_lease_id, p_lease_change_id, l_norm_sch_dt, l_sch_id, l_pymnt_st_lkp_cd);
	 create_schedule(g_lease_id, p_lease_change_id, l_norm_sch_dt, l_sch_id, l_pymnt_st_lkp_cd, p_term_id);
 /*---- Bug#7149537-------*/
      IF (l_pymnt_st_lkp_cd = 'DRAFT' AND p_lease_context IN ('EXP', 'CONTERM')) OR
         p_lease_context in ('ABS', 'ADD', 'ADDEDT', 'ADDAMD') THEN
 pnp_debug_pkg.log('create_normalize_items - l_norm_sch_dt :=: '||TO_CHAR(l_norm_sch_dt));
 	 l_sch_id_1 := 0; -- Bug 7149537
 	          /* GET the schedule id if draft schedule already exist for the term */
 	          OPEN get_drf_sch (l_norm_sch_dt);
 	          FETCH get_drf_sch INTO l_sch_id_1;
 	          CLOSE get_drf_sch;

 	           if l_sch_id_1 <>0 THEN -- Bug 7149537
 	           pnp_debug_pkg.log('create_normalize_items - l_sch_id_1 :=: '||TO_CHAR(nvl(l_sch_id_1,0)));
 	           ELSE
 	           l_sch_id_1 := 0;
 	           END IF;

         /* If partial start or partial end month, then norm amt for that month is
            monthly norm amt * corresponding partial fraction.*/

         l_norm_amt := l_monthly_norm_amt;

         IF l_partial_start_flag = 'Y' AND l_counter = 1 THEN

            l_norm_amt := (l_monthly_norm_amt*l_partial_start_fraction) + l_plr_amt; /* 9231686 */

         END IF;

         IF l_partial_end_flag = 'Y' AND l_counter = l_mths THEN

            l_norm_amt := l_monthly_norm_amt*l_partial_end_fraction;

         END IF;

         -- For last Item, adjust difference of Total Cash and Normalize amount
         -- so that sum of Cash and Normalize amounts are equal. (BUG# 2646928).

         l_prec_norm_amt := ROUND(l_norm_amt,l_precision);
		  pnp_debug_pkg.log('create_normalize_items - l_prec_norm_amt    : '||TO_CHAR(l_prec_norm_amt));
         l_tot_cum_norm_amt := l_tot_cum_norm_amt + l_prec_norm_amt;
		  pnp_debug_pkg.log('create_normalize_items - l_tot_cum_norm_amt    : '||TO_CHAR(l_tot_cum_norm_amt));
         IF l_counter = l_mths THEN
            l_tot_cum_diff_amt := (l_total_cash_amt - l_la_amt) - l_tot_cum_norm_amt;
            l_prec_norm_amt := l_prec_norm_amt + l_tot_cum_diff_amt;
         END IF;

         FOR rec IN get_org_id(p_term_id) LOOP
            l_org_id := rec.org_id;
         END LOOP;

         l_due_date := l_norm_sch_dt;
         IF NVL(fnd_profile.value('PN_RI_BACKBILL_TYPE'),'OT') = 'RECUR' THEN

            FOR rec IN get_calc_date_recur_bb(p_term_id) LOOP
               l_due_date := rec.recur_bb_calc_date;
            END LOOP;

         END IF;

         FOR rec IN get_inv_grp_rule LOOP
            l_inv_grp_rule := rec.grouping_rule_id;
         END LOOP;
 if nvl(l_sch_id_1,0) = 0  THEN

 	          FOR rec IN get_drf_sch_date(p_term_id) LOOP
 	          l_sch_date_1 := rec.schedule_date;
 	          if l_norm_sch_dt = l_sch_date_1 THEN

 	             SELECT NVL(sum(actual_amount),0) /* 9457938  */
 	             into   l_act_amt
 	             FROM   pn_payment_items_all ppi,
 	                    pn_payment_schedules_all pps
 	             WHERE ppi.payment_item_type_lookup_code = 'NORMALIZED'
 	             AND   pps.payment_schedule_id = ppi.payment_schedule_id
 	             AND   ppi.payment_term_id =  p_term_id
 	             AND   pps.payment_status_lookup_code <>  'DRAFT'
 	             AND   due_date = l_sch_date_1;


 	             l_prec_norm_amt := ((-1 * l_act_amt) + l_prec_norm_amt);
 	          END IF;
 	          END LOOP;   /* 7149537  */


 	   pnp_debug_pkg.log('draft - l_norm_sch_dt    : '||TO_CHAR(l_norm_sch_dt));

 	   pnp_debug_pkg.log('draft - l_prec_norm_amt    : '||TO_CHAR(l_prec_norm_amt));

 	   l_draft_exist := 0;

 	          /* CASH */
 	 begin -- Bug 7149537
 	           select 1                    /* 7149537 */
 	           into l_draft_exist
 	           from dual
 	           where exists(select * from pn_payment_items_all
 	           where due_date = l_norm_sch_dt
 	           and payment_term_id = p_term_id
 	           and payment_item_type_lookup_code = 'CASH'
		   and payment_schedule_id = l_sch_id);
 	 exception  -- Bug 7149537
    when no_data_found then
         l_draft_exist :=0;
   end;
 	           /*IF NVL(SQL%ROWCOUNT, 0) = 0 THEN       */
 	           IF NVL(l_draft_exist,0) <> 0 THEN
 	           pnp_debug_pkg.log('draft - l_draft_exist    : '||TO_CHAR(l_draft_exist));
 	           ELSE
 	             l_draft_exist := 0;
 	           create_cash_items(p_est_amt          => 0,                 /* 7149537  */
 	                            p_act_amt           => 0,
 	                            p_sch_dt            => l_norm_sch_dt,
 	                            p_sch_id            => l_sch_id,
 	                            p_term_id           => p_term_id,
 	                            p_vendor_id         => p_vendor_id,
 	                            p_cust_id           => p_cust_id,
 	                            p_vendor_site_id    => p_vendor_site_id,
 	                            p_cust_site_use_id  => p_cust_site_use_id,
 	                            p_cust_ship_site_id => p_cust_ship_site_id,
 	                            p_sob_id            => p_sob_id,
 	                            p_curr_code         => p_curr_code,
 	                            p_rate              => p_rate);

 	           END IF;

 	         /*  NORMALIZED */
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
          org_id,
          grouping_rule_id)

         VALUES

         (PN_PAYMENT_ITEMS_S.NEXTVAL,
          SYSDATE,
          NVL(fnd_profile.value('USER_ID'),0),
          SYSDATE,
          NVL(fnd_profile.value('USER_ID'),0),
          NVL(fnd_profile.value('LOGIN_ID'),0),
          l_prec_norm_amt,
          NULL,
          l_norm_sch_dt,
          'NORMALIZED',
          p_term_id,
          l_sch_id,
          1,
          p_vendor_id,
          p_cust_id,
          p_vendor_site_id,
          p_cust_site_use_id,
          p_cust_ship_site_id,
          p_sob_id,
          p_curr_code,
          p_curr_code,
          l_prec_norm_amt,
          p_rate,
          l_org_id,
          l_inv_grp_rule);

		   pnp_debug_pkg.log('INSERTED');

 	       ELSIF  l_sch_id_1 <> 0 THEN       /* 7149537 */

 	       pnp_debug_pkg.log('create_normalize_items - l_sch_id_1    : '||TO_CHAR(l_sch_id_1));

 	       SELECT NVL(sum(actual_amount),0)
 	             into   l_act_amt
 	             FROM   pn_payment_items_all ppi,
 	                    pn_payment_schedules_all pps
 	             WHERE ppi.payment_item_type_lookup_code = 'NORMALIZED'
 	             AND   pps.payment_schedule_id = ppi.payment_schedule_id
 	             AND   ppi.payment_term_id =  p_term_id
 	             AND   pps.payment_status_lookup_code <>  'DRAFT'
 	             AND   due_date = l_norm_sch_dt;


 	             l_prec_norm_amt := ((-1 * nvl(l_act_amt,0)) + l_prec_norm_amt);

 	       UPDATE pn_payment_items_all ppi
 	       SET    ppi.actual_amount = l_prec_norm_amt,
 	              ppi.export_currency_amount = l_prec_norm_amt,
 	              ppi.last_update_date = SYSDATE,
 	              ppi.last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
 	              ppi.last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
 	       WHERE  ppi.payment_schedule_id = l_sch_id_1
 	       AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
 	       AND    ppi.payment_term_id = p_term_id;

 	       pnp_debug_pkg.log('UPDATED -l_prec_norm_amt    : '||TO_CHAR(l_prec_norm_amt));
 	       END IF;
 	       /* 7149537 */

      END IF;

      l_counter:= l_counter + 1;
      l_norm_sch_dt := TO_DATE(TO_CHAR(p_sch_day)||'/'||TO_CHAR(ADD_MONTHS(l_norm_sch_dt,1),'MM/YYYY')
                               ,'DD/MM/YYYY');

      END LOOP;

   ELSIF p_lease_context = 'CON' THEN

      l_norm_amt := l_monthly_norm_amt;
      l_prec_norm_amt := ROUND(l_norm_amt,l_precision);

      UPDATE pn_payment_items_all ppi
      SET    ppi.actual_amount = l_prec_norm_amt,
             ppi.export_currency_amount = l_prec_norm_amt,
             ppi.last_update_date = SYSDATE,
             ppi.last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
             ppi.last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
      WHERE  ppi.payment_schedule_id IN (SELECT pps.payment_schedule_id
                                         FROM   pn_payment_schedules_all pps,
                                                pn_payment_items_all ppi1
                                         WHERE  pps.payment_schedule_id = ppi1.payment_schedule_id
                                         AND    pps.payment_status_lookup_code = 'DRAFT'
                                         AND    ppi1.payment_term_id = p_term_id)
      AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
      AND    ppi.payment_term_id = p_term_id;

      -- Sum normalize amount for difference in Total Cash and Normalize amount. (BUG# 2646928).
      l_rows_updated := SQL%ROWCOUNT;
      l_prec_norm_amt_upd := l_prec_norm_amt;
      l_tot_cum_norm_amt := l_rows_updated * l_prec_norm_amt_upd;

      /* If partial start month, then norm amt for the 1st month schedule is
         monthly norm amt * partial start fraction.*/

      IF l_partial_start_flag = 'Y' THEN

         l_norm_amt := l_monthly_norm_amt*l_partial_start_fraction;
         l_prec_norm_amt := ROUND(l_norm_amt,l_precision);
         l_norm_sch_dt := TO_DATE(TO_CHAR(p_sch_day)||'/'||TO_CHAR(p_norm_str_dt,'MM/YYYY')
                                  ,'DD/MM/YYYY');
         l_tot_cum_norm_amt := l_tot_cum_norm_amt - l_prec_norm_amt_upd + l_prec_norm_amt;

         UPDATE pn_payment_items_all ppi
         SET    ppi.actual_amount = l_prec_norm_amt,
                ppi.export_currency_amount = l_prec_norm_amt,
                ppi.last_update_date = SYSDATE,
                ppi.last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
                ppi.last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
         WHERE  ppi.payment_schedule_id = (SELECT pps.payment_schedule_id
                                           FROM   pn_payment_schedules_all pps,
                                                  pn_payment_items_all ppi1
                                           WHERE  pps.payment_schedule_id = ppi1.payment_schedule_id
                                           AND    pps.payment_status_lookup_code = 'DRAFT'
                                           AND    ppi1.payment_term_id = p_term_id
                                           AND    ppi1.payment_item_type_lookup_code = 'NORMALIZED'
                                           AND    pps.schedule_date = l_norm_sch_dt)
         AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
         AND    ppi.payment_term_id = p_term_id;
      END IF;

      /* If partial end month, then norm amt for the last month schedule is
         monthly norm amt * partial end fraction. */

      IF l_partial_end_flag = 'Y' THEN
         l_norm_amt := l_monthly_norm_amt*l_partial_end_fraction;
         l_prec_norm_amt := ROUND(l_norm_amt,l_precision);
         l_tot_cum_norm_amt := l_tot_cum_norm_amt - l_prec_norm_amt_upd + l_prec_norm_amt;
      END IF;

      -- For last Item, adjust difference of Total Cash and Normalize amount
      -- so that sum of Cash and Normalize amounts are equal. (BUG# 2646928).

      l_tot_cum_diff_amt := (l_total_cash_amt - l_la_amt) - l_tot_cum_norm_amt;
      l_prec_norm_amt := ROUND(l_prec_norm_amt + l_tot_cum_diff_amt, l_precision);

      IF l_partial_end_flag = 'Y' OR l_tot_cum_diff_amt <> 0 THEN
         UPDATE pn_payment_items_all ppi
         SET    ppi.actual_amount = l_prec_norm_amt,
                ppi.export_currency_amount = l_prec_norm_amt,
                ppi.last_update_date = SYSDATE,
                ppi.last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
                ppi.last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
         WHERE  ppi.payment_schedule_id = (SELECT pps.payment_schedule_id
                                           FROM   pn_payment_schedules_all pps,
                                                  pn_payment_items_all ppi1
                                           WHERE  pps.payment_schedule_id = ppi1.payment_schedule_id
                                           AND    pps.payment_status_lookup_code = 'DRAFT'
                                           AND    ppi1.payment_term_id = p_term_id
                                           AND    ppi1.payment_item_type_lookup_code = 'NORMALIZED'
                                           AND    pps.schedule_date = l_last_sch_dt)
         AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
         AND    ppi.payment_term_id = p_term_id;
      END IF;

   END IF;

    -- Added for BUG#2590872
    UPDATE pn_payment_terms_all
    SET event_type_code = p_lease_context
    WHERE normalize ='Y'
    AND   payment_term_id = p_term_id;

   ELSE -- Exit create_normalize_items.
      pnp_debug_pkg.log('create_normalize_items - Exit, No need to Normalize... l_norm_mths : '
                        ||TO_CHAR(l_norm_mths));
   END IF; -- Exit create_normalize_items.

   pnp_debug_pkg.log('create_normalize_items -End- (-)');

END create_normalize_items;


-------------------------------------------------------------------------------
--  PROCEDURE  : PROCESS_TERM
--  DESCRIPTION: This procedure creates Schedules and Cash Items for a given Term.
--               It collects information for all schedules, get cash amount and
--               creates the cash item, if term is normalized, then create
--               Normalize Item as well.
--  25-JUN-01  MMisra    o Created.
--             MMisra    o For a payment term of type 'Pre payment' also create
--                         the payment item for the reversal entry.
--  30-JAN-02  STripathi o Added condition l_pre_pay_flag = 'N' to ensure
--                         that 'Pre Payment' item is created only once.
--  07-FEB-02  STripathi o Added added parameter p_norm_str_dt. Added condition
--                         for Lease Context ADDAMD to set correct normalize
--                         start date.
--  26-MAR-02  STripathi o Added parameter p_sch_str_dt to correctly point the
--                         Schedule-Start-Date for NON MONTHLY Payment Term.
--  26-APR-02  ftanudja  o Added parameter p_rate
--  08-Nov-02  Ashish      BUG#2657736 added the nvl(p_act_amt,p_est_amt for
--                         the condition where p_freq_code = 'OT'
--  16-OCT-03  STripathi o Fix for BUG# 3201091. Added parameter p_lease_change_id,
--                         to use instead of g_lc_id.
--  15-MAR-06  piagrawa  o Bug 5085901 - Modified to calculate l_sch_end_dt
--                         taking care if the schedule date is last date of
--                         month.
--  27-NOV-06  Hareesha  o Passed p_payment_term_id to call to create_schedules.
--  28-NOV-08  acprakas  o Bug#7585368. Modified not to create extra payment item
--                         for annual term.
--  20-FEB-2009 acprakas o Bug#8274729. Modified to set l_sch_start_dt to
--                                   first day of term start date in case of monthly term
--                                   also not to modify it unless one cash item has been
--                                   generated.
--  08-MAY-09  rthumma   o Bug 7570052 : Modified code to restrict schedule date to date
--                         on which a non-zero cash item is planned in case the next
--                         schedule day is greater than the date on which cash item is planned.
--  18-MAY-09  rthumma   o Bug 8474866 : Modified code so that l_sch_str_dt do change when
--                         normalization start date is before term start date.
--  01-JUL-09  jsundara  o Bug 8290117 : If Not one Time term, then the schedule
--			   start date is always set to first day of term start date.
--  19-Aug-09  jsundara  o Bug8786505 : For Non Normalized terms, schedule day for the
--			   next cash item is set.
--  21-Aug-09  jsundara  o Bug8980352 : set the next cash duration date.
-------------------------------------------------------------------------------------
PROCEDURE process_term (p_no_sch               NUMBER,
                        p_counter              NUMBER,
                        p_sch_dt               DATE,
                        p_pro_sch_dt           DATE,
                        p_new_lea_term_dt      DATE,
                        p_freq                 NUMBER,
                        p_freq_code            VARCHAR2,
                        p_payment_term_id      NUMBER,
                        p_pay_trm_typ_code     VARCHAR2,
                        p_trgt_dt              DATE,
                        p_normalize_flag       VARCHAR2,
                        p_lease_context        VARCHAR2,
                        p_mths                 NUMBER,
                        p_vendor_id            NUMBER,
                        p_customer_id          NUMBER,
                        p_vendor_site_id       NUMBER,
                        p_customer_site_use_id NUMBER,
                        p_cust_ship_site_id    NUMBER,
                        p_set_of_books_id      NUMBER,
                        p_currency_code        VARCHAR2,
                        p_rate                 NUMBER,
                        p_term_start_date      DATE,
                        p_term_end_date        DATE,
                        p_sch_str_dt           DATE,
                        p_act_amt              NUMBER,
                        p_est_amt              NUMBER,
                        p_index_prd_id         NUMBER,
                        p_norm_str_dt          DATE,
                        p_lease_change_id      NUMBER)
IS

   l_cash_act_amt                  pn_payment_items.actual_amount%TYPE := 0;
   l_cash_est_amt                  pn_payment_items.estimated_amount%TYPE := 0;
   l_sch_id                        pn_payment_schedules.payment_schedule_id%TYPE;
   l_sch_str_dt                    DATE := NULL;
   l_sch_end_dt                    DATE := NULL;
   l_sch_dt                        pn_payment_schedules.schedule_date%TYPE;
   l_pro_sch_dt                    pn_payment_schedules.schedule_date%TYPE;
   l_app_sch                       NUMBER;
   l_norm_mths                     NUMBER;
   l_sch_day                       VARCHAR2(240);
   l_pymnt_st_lkp_cd               pn_payment_schedules.payment_status_lookup_code%TYPE;
   l_pre_pay_flag                  VARCHAR2(1) := 'N';
   l_next_cash_duration_dt         DATE := NULL;
   l_prev_sch_str_dt               DATE := NULL;
   l_tmp_sch_str_dt                DATE := NULL;
   l_tmp_next_cash_duration_dt     DATE := null;
   l_perv_next_cash_duration_dt    DATE := null;

   /* Added for Bug 7570052 */
   l_cal_yr_st_dt                  PN_LEASES_ALL.cal_start%TYPE;
   l_non_zero_cash_sch_cnt         NUMBER := 0;

BEGIN

   pnp_debug_pkg.log('process_term +Start+ (+) - p_payment_term_id: '
                     ||TO_CHAR(p_payment_term_id)
                     ||', p_lease_context : '||p_lease_context);
   pnp_debug_pkg.log('process_term IN: p_no_sch                 : '||p_no_sch);
   pnp_debug_pkg.log('process_term IN: p_counter                : '||p_counter);
   pnp_debug_pkg.log('process_term IN: p_sch_dt                 : '||p_sch_dt);
   pnp_debug_pkg.log('process_term IN: p_pro_sch_dt             : '||p_pro_sch_dt);
   pnp_debug_pkg.log('process_term IN: p_new_lea_term_dt        : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('process_term IN: p_freq                   : '||p_freq);
   pnp_debug_pkg.log('process_term IN: p_freq_code              : '||p_freq_code);
   pnp_debug_pkg.log('process_term IN: p_payment_term_id        : '||p_payment_term_id);
   pnp_debug_pkg.log('process_term IN: p_pay_trm_typ_code       : '||p_pay_trm_typ_code);
   pnp_debug_pkg.log('process_term IN: p_trgt_dt                : '||p_trgt_dt);
   pnp_debug_pkg.log('process_term IN: p_normalize_flag         : '||p_normalize_flag);
   pnp_debug_pkg.log('process_term IN: p_lease_context          : '||p_lease_context);
   pnp_debug_pkg.log('process_term IN: p_mths                   : '||p_mths);
   pnp_debug_pkg.log('process_term IN: p_vendor_id              : '||p_vendor_id);
   pnp_debug_pkg.log('process_term IN: p_customer_id            : '||p_customer_id);
   pnp_debug_pkg.log('process_term IN: p_vendor_site_id         : '||p_vendor_site_id);
   pnp_debug_pkg.log('process_term IN: p_customer_site_use_id   : '||p_customer_site_use_id);
   pnp_debug_pkg.log('process_term IN: p_cust_ship_site_id      : '||p_cust_ship_site_id);
   pnp_debug_pkg.log('process_term IN: p_set_of_books_id        : '||p_set_of_books_id);
   pnp_debug_pkg.log('process_term IN: p_currency_code          : '||p_currency_code);
   pnp_debug_pkg.log('process_term IN: p_rate                   : '||p_rate);
   pnp_debug_pkg.log('process_term IN: p_term_start_date        : '||p_term_start_date);
   pnp_debug_pkg.log('process_term IN: p_term_end_date          : '||p_term_end_date);
   pnp_debug_pkg.log('process_term IN: p_sch_str_dt             : '||p_sch_str_dt);
   pnp_debug_pkg.log('process_term IN: p_act_amt                : '||p_act_amt);
   pnp_debug_pkg.log('process_term IN: p_est_amt                : '||p_est_amt);
   pnp_debug_pkg.log('process_term IN: p_index_prd_id           : '||p_index_prd_id);
   pnp_debug_pkg.log('process_term IN: p_norm_str_dt            : '||p_norm_str_dt);
   pnp_debug_pkg.log('process_term IN: p_lease_change_id        : '||p_lease_change_id);

   /* Initialize the schedule date */

   -- Bug 7570052
   SELECT cal_start
   INTO   l_cal_yr_st_dt
   FROM PN_LEASES_ALL
   WHERE LEASE_ID = (select distinct lease_id from pn_payment_terms_all where payment_term_id = p_payment_term_id);

   l_sch_dt := p_sch_dt;
   l_sch_day := TO_CHAR(l_sch_dt,'DD');

   l_pro_sch_dt := p_pro_sch_dt;


  IF p_freq_code IN ('MON', 'OT') THEN

      l_sch_str_dt := FIRST_DAY(l_sch_dt);
   ELSE
       l_sch_str_dt := p_sch_str_dt;
   END IF;


   pnp_debug_pkg.log('process_term (+) - l_sch_str_dt: '||l_sch_str_dt
                     ||', l_pro_sch_dt: '||l_pro_sch_dt);



     IF l_cal_yr_st_dt IS NULL
   THEN
       IF p_freq_code in ('MON', 'OT')
       THEN
           l_next_cash_duration_dt := first_day(p_term_start_date);
       ELSE
           l_next_cash_duration_dt := p_term_start_date;
       END IF;
   ELSE
       IF p_freq_code in ('MON', 'OT')
       THEN
           l_next_cash_duration_dt := first_day(p_term_start_date);
       ELSE
           l_next_cash_duration_dt := l_sch_str_dt;
       END IF;
   END IF; /* 8980352 */


   FOR i IN (p_counter + 1) .. p_no_sch
   LOOP

      /* AMT-RETRO */
      IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
        create_schedule(g_lease_id, p_lease_change_id, l_sch_dt, l_sch_id, l_pymnt_st_lkp_cd,p_payment_term_id);
      ELSE
        PN_RETRO_ADJUSTMENT_PKG.find_schedule(g_lease_id,
                                              p_lease_change_id,
                                              p_payment_term_id,
                                              l_sch_dt,
                                              l_sch_id);
        l_pymnt_st_lkp_cd := 'DRAFT';
      END IF;

      IF p_freq_code IN ('MON', 'OT') THEN
         l_sch_end_dt := LAST_DAY(l_sch_dt);
      ELSE
         IF last_day(l_sch_str_dt) = l_sch_str_dt
         THEN
         /* last day of month */
            l_sch_end_dt := ADD_MONTHS(l_sch_str_dt - 1, p_freq);
         ELSE
            l_sch_end_dt := ADD_MONTHS(l_sch_str_dt, p_freq) -1;
         END IF;
      END IF;

      IF p_lease_context = 'EXP' THEN

          /* If the context is 'EXP' i.e. expansion then the cash items should be
             created with zero amounts */

         IF p_index_prd_id IS NULL THEN

             l_cash_est_amt := NULL;
             l_cash_act_amt := 0;

         ELSE

          /*  IF l_sch_dt = l_pro_sch_dt and l_sch_str_dt = l_next_cash_duration_dt THEN  : 7679094 */

         IF (l_sch_dt = l_pro_sch_dt and (l_sch_str_dt = l_next_cash_duration_dt) AND p_freq_code <> 'OT') OR
            ((l_sch_dt = l_pro_sch_dt) and p_freq_code = 'OT') THEN


               get_amount(p_sch_str_dt    => l_sch_str_dt,
                          p_sch_end_dt    => l_sch_end_dt,
                          p_trm_str_dt    => p_term_start_date,
                          p_trm_end_dt    => p_term_end_date,
                          p_act_amt       => p_act_amt,
                          p_est_amt       => p_est_amt,
                          p_freq          => p_freq,
                          p_cash_act_amt  => l_cash_act_amt,
                          p_cash_est_amt  => l_cash_est_amt);

               /* Get the next schedule date which will have non zero amount */

               l_pro_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_pro_sch_dt,p_freq),
                                                               'MM/YYYY'),'DD/MM/YYYY');


          IF p_normalize_flag = 'Y' THEN
               FOR i in 1..p_freq
               LOOP
	          l_tmp_next_cash_duration_dt := l_next_cash_duration_dt;

		  IF to_char(l_next_cash_duration_dt,'MM') = '02' AND to_number(to_char(l_next_cash_duration_dt,'DD')) < to_number(to_char(l_perv_next_cash_duration_dt,'DD'))
                  THEN
                      l_next_cash_duration_dt := TO_DATE(to_char(l_perv_next_cash_duration_dt,'DD') || '/' ||TO_CHAR(ADD_MONTHS(l_next_cash_duration_dt, 1),
                                                     'MM/YYYY'),'DD/MM/YYYY');
                  ELSIF last_day(l_next_cash_duration_dt) = l_next_cash_duration_dt
                  THEN
                      l_next_cash_duration_dt := ADD_MONTHS(l_next_cash_duration_dt - 1, 1) + 1;
                  ELSE
                      l_next_cash_duration_dt := ADD_MONTHS(l_next_cash_duration_dt, 1);
                  END IF;
		  l_perv_next_cash_duration_dt := l_tmp_next_cash_duration_dt;
               END LOOP;

           ELSIF (NVL(p_normalize_flag,'N') <> 'Y') THEN

              IF last_day(l_next_cash_duration_dt) = l_next_cash_duration_dt
              THEN
                  l_next_cash_duration_dt := ADD_MONTHS(l_next_cash_duration_dt - 1, p_freq) + 1;
	      ELSE
                  l_next_cash_duration_dt := ADD_MONTHS(l_next_cash_duration_dt, p_freq);
              END IF;
           END IF;


            ELSE

               /* Set the amounts to zero */

               l_cash_act_amt := 0;
               l_cash_est_amt := NULL;

            END IF;

            pnp_debug_pkg.log('process_term - l_cash_act_amt: '||TO_CHAR(l_cash_act_amt));
            pnp_debug_pkg.log('process_term - l_cash_est_amt: '||TO_CHAR(l_cash_est_amt));
         END IF;

      ELSIF p_lease_context IN ('ADDEDT', 'ADDAMD', 'ADD', 'ABS') THEN
        pnp_debug_pkg.log('process_term (+) - l_next_cash_duration_dt: '||l_next_cash_duration_dt||' -l_sch_dt '||l_sch_dt||'-l_pro_sch_dt '
      ||l_pro_sch_dt||'-l_sch_str_dt '||l_sch_str_dt);


         /* If schedule date is equal to the schedule date which
            should have a non zero amount then get the amounts */

-- Bug 8270739         IF l_sch_dt = l_pro_sch_dt and l_sch_str_dt = l_next_cash_duration_dt THEN

         /* IF l_sch_dt = l_pro_sch_dt THEN : 7679094 */

        IF (l_sch_dt = l_pro_sch_dt and (l_sch_str_dt = l_next_cash_duration_dt) AND p_freq_code <> 'OT') OR
           ((l_sch_dt = l_pro_sch_dt) and p_freq_code = 'OT') THEN -- 7679094 : Added


            IF p_freq_code = 'OT' THEN

               /* For 'One Time' payment, the payment item amounts will
                  be same as the payment term amounts. */

               l_cash_est_amt := p_est_amt;
               l_cash_act_amt :=nvl(p_act_amt,p_est_amt);--Bug#2657736 added nvl

               pnp_debug_pkg.log('process_term - l_cash_act_amt: '||TO_CHAR(l_cash_act_amt));
               pnp_debug_pkg.log('process_term - l_cash_est_amt: '||TO_CHAR(l_cash_est_amt));

            ELSE
	     IF l_sch_str_dt = l_next_cash_duration_dt THEN
               pnp_debug_pkg.log('process_term - Calling get_amount, sch st dt    : '
                                  ||TO_CHAR(l_sch_str_dt,'MM/DD/YYYY'));
               pnp_debug_pkg.log('process_term - Calling get_amount, sch end dt   : '
                                  ||TO_CHAR(l_sch_end_dt,'MM/DD/YYYY'));
               pnp_debug_pkg.log('process_term - Calling get_amount, term st dt   : '
                                  ||TO_CHAR(p_term_start_date,'MM/DD/YYYY'));
               pnp_debug_pkg.log('process_term - Calling get_amount, term end dt  : '
                                  ||TO_CHAR(p_term_end_date,'MM/DD/YYYY'));
               pnp_debug_pkg.log('process_term - Calling get_amount, act amt      : '
                                  ||TO_CHAR(p_act_amt));
               pnp_debug_pkg.log('process_term - Calling get_amount, est amt      : '
                                  ||TO_CHAR(p_est_amt));
               pnp_debug_pkg.log('process_term - Calling get_amount, est amt      : '
                                  ||TO_CHAR(p_freq));

               get_amount(p_sch_str_dt    => l_sch_str_dt,
                          p_sch_end_dt    => l_sch_end_dt,
                          p_trm_str_dt    => p_term_start_date,
                          p_trm_end_dt    => p_term_end_date,
                          p_act_amt       => p_act_amt,
                          p_est_amt       => p_est_amt,
                          p_freq          => p_freq,
                          p_cash_act_amt  => l_cash_act_amt,
                          p_cash_est_amt  => l_cash_est_amt);

               l_non_zero_cash_sch_cnt := l_non_zero_cash_sch_cnt + 1;  -- Bug 7570052

               pnp_debug_pkg.log('process_term - Returned from get_amount, cash act amt: '
                                  ||TO_CHAR(l_cash_act_amt));
               pnp_debug_pkg.log('process_term - Returned from get_amount, cash est amt: '
                                  ||TO_CHAR(l_cash_est_amt));

               /* Get the next schedule date which will have non zero amount */

               -- Bug 7570052
               IF l_non_zero_cash_sch_cnt = 1 and l_cal_yr_st_dt IS NOT NULL THEN

                 l_pro_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_sch_str_dt,p_freq),
                                                               'MM/YYYY'),'DD/MM/YYYY');
               ELSE

                 l_pro_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_pro_sch_dt,p_freq),
                                                               'MM/YYYY'),'DD/MM/YYYY');
               END IF;

               -- Bug 8474866
               IF l_cal_yr_st_dt IS NOT NULL AND p_freq_code  NOT IN ('MON','OT') THEN
                 IF last_day(l_sch_str_dt) = l_sch_str_dt THEN
                   l_sch_str_dt := ADD_MONTHS(l_sch_str_dt - 1, p_freq) + 1;
                 ELSE
                   l_sch_str_dt := ADD_MONTHS(l_sch_str_dt, p_freq);
                 END IF;
               END IF;

              IF p_normalize_flag = 'Y' THEN
               FOR i in 1..p_freq
               LOOP
	          l_tmp_next_cash_duration_dt := l_next_cash_duration_dt;

		  IF to_char(l_next_cash_duration_dt,'MM') = '02' AND to_number(to_char(l_next_cash_duration_dt,'DD')) < to_number(to_char(l_perv_next_cash_duration_dt,'DD'))
                  THEN
                      l_next_cash_duration_dt := TO_DATE(to_char(l_perv_next_cash_duration_dt,'DD') || '/' ||TO_CHAR(ADD_MONTHS(l_next_cash_duration_dt, 1),
                                                     'MM/YYYY'),'DD/MM/YYYY');
                  ELSIF last_day(l_next_cash_duration_dt) = l_next_cash_duration_dt
                  THEN
                      l_next_cash_duration_dt := ADD_MONTHS(l_next_cash_duration_dt - 1, 1) + 1;
                  ELSE
                      l_next_cash_duration_dt := ADD_MONTHS(l_next_cash_duration_dt, 1);
                  END IF;
		  l_perv_next_cash_duration_dt := l_tmp_next_cash_duration_dt;
               END LOOP;

           ELSIF (NVL(p_normalize_flag,'N') <> 'Y') THEN

              IF last_day(l_next_cash_duration_dt) = l_next_cash_duration_dt
              THEN
                  l_next_cash_duration_dt := ADD_MONTHS(l_next_cash_duration_dt - 1, p_freq) + 1;
	      ELSE
                  l_next_cash_duration_dt := ADD_MONTHS(l_next_cash_duration_dt, p_freq);
              END IF;
           END IF;

            END IF; --Bug 8270739.
            END IF;

         ELSE

            /* Set the amounts to zero */

            l_cash_act_amt := 0;
            l_cash_est_amt := NULL;

            pnp_debug_pkg.log('process_term - l_cash_act_amt: '||TO_CHAR(l_cash_act_amt));
            pnp_debug_pkg.log('process_term - l_cash_est_amt: '||TO_CHAR(l_cash_est_amt));

         END IF;


      END IF;


      IF l_pymnt_st_lkp_cd = 'DRAFT' THEN

         create_cash_items(p_est_amt           => l_cash_est_amt,
                           p_act_amt           => l_cash_act_amt,
                           p_sch_dt            => l_sch_dt,
                           p_sch_id            => l_sch_id,
                           p_term_id           => p_payment_term_id,
                           p_vendor_id         => p_vendor_id,
                           p_cust_id           => p_customer_id,
                           p_vendor_site_id    => p_vendor_site_id,
                           p_cust_site_use_id  => p_customer_site_use_id,
                           p_cust_ship_site_id => p_cust_ship_site_id,
                           p_sob_id            => p_set_of_books_id,
                           p_curr_code         => p_currency_code,
                           p_rate              => p_rate);
      END IF;

      IF p_pay_trm_typ_code = 'PRE' AND l_pre_pay_flag = 'N'
         AND (l_sch_dt = l_pro_sch_dt) THEN

         /* AMT-RETRO */
         IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
           create_schedule(g_lease_id, p_lease_change_id, p_trgt_dt, l_sch_id, l_pymnt_st_lkp_cd);
         ELSE
           PN_RETRO_ADJUSTMENT_PKG.find_schedule(g_lease_id,
                                                 p_lease_change_id,
                                                 p_payment_term_id,
                                                 p_trgt_dt,
                                                 l_sch_id);
           l_pymnt_st_lkp_cd := 'DRAFT';
         END IF;

         /* Insert the Negation/Adjustment amount with different sign */

         IF l_pymnt_st_lkp_cd = 'DRAFT' THEN

            create_cash_items(p_est_amt           => (-1 * l_cash_est_amt),
                              p_act_amt           => (-1 * l_cash_act_amt),
                              p_sch_dt            => p_trgt_dt,
                              p_sch_id            => l_sch_id,
                              p_term_id           => p_payment_term_id,
                              p_vendor_id         => p_vendor_id,
                              p_cust_id           => p_customer_id,
                              p_vendor_site_id    => p_vendor_site_id,
                              p_cust_site_use_id  => p_customer_site_use_id,
                              p_cust_ship_site_id => p_cust_ship_site_id,
                              p_sob_id            => p_set_of_books_id,
                              p_curr_code         => p_currency_code,
                              p_rate              => p_rate);

            l_pre_pay_flag := 'Y';

         END IF;

      END IF;

      /*--------------------------------------------------------------
       Get the next schedule date. In case of normalized term, monthly
       schedules will be created and in case of terms that are not
       normalized schedules will be created depending upon the
       frequency of the term.
       --------------------------------------------------------------*/

      /* For Normalize Term, next Schedule-Start-Date is next month.
         For Not Normalize Term, next Schedule-Start-Date is after p_freq months. */

      IF p_normalize_flag = 'Y' THEN

         -- Bug 7570052
         IF l_cal_yr_st_dt IS NOT NULL AND
            p_freq_code  NOT IN ('MON','OT') AND
            TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_sch_dt, 1),'MM/YYYY'),'DD/MM/YYYY') > l_pro_sch_dt
         THEN
            l_sch_dt :=  l_pro_sch_dt;
         ELSE
            l_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_sch_dt, 1),'MM/YYYY'),'DD/MM/YYYY');
         END IF;


       IF  l_cal_yr_st_dt IS NULL OR
           (l_cal_yr_st_dt IS NOT NULL AND p_freq_code IN ('MON','OT')) THEN

	  l_tmp_sch_str_dt := l_sch_str_dt;

         IF to_char(l_sch_str_dt,'MM') = '02' AND to_number(to_char(l_sch_str_dt,'DD')) < to_number(to_char(l_prev_sch_str_dt,'DD'))
	 THEN
	     l_sch_str_dt := TO_DATE(to_char(l_prev_sch_str_dt,'DD') || '/' ||TO_CHAR(ADD_MONTHS(l_sch_str_dt, 1),
                                                     'MM/YYYY'),'DD/MM/YYYY');
         ELSIF last_day(l_sch_str_dt) = l_sch_str_dt
         THEN
            l_sch_str_dt := ADD_MONTHS(l_sch_str_dt - 1, 1) + 1;
         ELSE
            l_sch_str_dt := ADD_MONTHS(l_sch_str_dt, 1);
         END IF;

         l_prev_sch_str_dt := l_tmp_sch_str_dt;
      END IF;


      ELSIF (NVL(p_normalize_flag,'N') <> 'Y') THEN

         IF l_cal_yr_st_dt IS NULL THEN
            l_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_sch_dt, p_freq),'MM/YYYY'),'DD/MM/YYYY');
         ELSE
            l_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(l_sch_str_dt,'MM/YYYY'),'DD/MM/YYYY');
         END IF;

	  IF  l_cal_yr_st_dt IS NULL OR
              (l_cal_yr_st_dt IS NOT NULL AND p_freq_code IN ('MON','OT')) THEN
                   IF last_day(l_sch_str_dt) = l_sch_str_dt
                   THEN
                     l_sch_str_dt := ADD_MONTHS(l_sch_str_dt - 1, p_freq) + 1;
                   ELSE
                    l_sch_str_dt := ADD_MONTHS(l_sch_str_dt, p_freq);
                   END IF; /* 8786505 */
          END IF;


      END IF;

   END LOOP;

   pnp_debug_pkg.log('process_term - Cash Items Completed, Normalize = '
                      ||NVL(p_normalize_flag,'N')||', p_lease_context : '||p_lease_context);


   IF NVL(p_normalize_flag,'N') = 'Y' THEN

      /* AMT-RETRO */
      IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
        create_normalize_items(p_lease_context      => p_lease_context,
                               p_lease_id           => g_lease_id,
                               p_term_id            => p_payment_term_id,
                               p_vendor_id          => p_vendor_id,
                               p_cust_id            => p_customer_id,
                               p_vendor_site_id     => p_vendor_site_id,
                               p_cust_site_use_id   => p_customer_site_use_id,
                               p_cust_ship_site_id  => p_cust_ship_site_id,
                               p_sob_id             => p_set_of_books_id,
                               p_curr_code          => p_currency_code,
                               p_sch_day            => l_sch_day,
                               p_norm_str_dt        => p_norm_str_dt,
                               p_norm_end_dt        => g_new_lea_term_dt,
                               p_rate               => p_rate,
                               p_lease_change_id    => p_lease_change_id);
      ELSE
        PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE
                               (p_lease_context      => p_lease_context,
                                p_lease_id           => g_lease_id,
                                p_term_id            => p_payment_term_id,
                                p_vendor_id          => p_vendor_id,
                                p_cust_id            => p_customer_id,
                                p_vendor_site_id     => p_vendor_site_id,
                                p_cust_site_use_id   => p_customer_site_use_id,
                                p_cust_ship_site_id  => p_cust_ship_site_id,
                                p_sob_id             => p_set_of_books_id,
                                p_curr_code          => p_currency_code,
                                p_sch_day            => l_sch_day,
                                p_norm_str_dt        => p_norm_str_dt,
                                p_norm_end_dt        => g_new_lea_term_dt,
                                p_rate               => p_rate,
                                p_lease_change_id    => p_lease_change_id);
      END IF;

   END IF;

   pnp_debug_pkg.log('process_term -End- (-)');

END process_term;

--------------------------------------------------------------------------------------------
--  PROCEDURE  : UPDATE_CASH_ITEM
--  DESCRIPTION: This procedure is used in contracting last schedule of a given term/lease.
--               It updates last Cash Item by updating table PN_PAYMENT_ITEMS with the new
--               prorated amount calculated by procedure GET_AMOUNT..
-- 01-FEB-02  Satish Tripathi o Created.
-- 07-OCT-02  Satish Tripathi o Added payment_status_lookup_code = 'DRAFT' in Update Stmt.
--                                Fix for BUG# 2551423.
-- 24-NOV-05  Kiran           o Round amounts befor insert/uptdate into terms OR items.
-- 13-Jan-09  nkapling        o Bug 9150650 :- subtract the approved_amount from the prorated amount
--                              fetched by get_amount.
--------------------------------------------------------------------------------------------
PROCEDURE update_cash_item (p_term_id       NUMBER,
                            p_term_str_dt   DATE,
                            p_term_end_dt   DATE,
                            p_schedule_dt   DATE,
                            p_sch_str_dt    DATE,
                            p_sch_end_dt    DATE,
                            p_act_amt       NUMBER,
                            p_est_amt       NUMBER,
                            p_freq          NUMBER)
IS

   l_cash_act_amt                  NUMBER;
   l_cash_est_amt                  NUMBER;

   l_cash_act_amt_appr             NUMBER;
   l_cash_est_amt_appr             NUMBER;
   l_cash_exp_amt_appr             NUMBER;

   l_precision                    NUMBER; --Bug 9150650
   l_ext_precision                NUMBER;
   l_min_acct_unit                NUMBER;

   CURSOR currency_cur IS
     SELECT currency_code FROM pn_payment_terms_all WHERE payment_term_id = p_term_id;

BEGIN

   pnp_debug_pkg.log('update_cash_item +Start+ (+)');
   pnp_debug_pkg.log('update_cash_item IN: p_term_id     : '||p_term_id);
   pnp_debug_pkg.log('update_cash_item IN: p_term_str_dt : '||p_term_str_dt);
   pnp_debug_pkg.log('update_cash_item IN: p_term_end_dt : '||p_term_end_dt);
   pnp_debug_pkg.log('update_cash_item IN: p_schedule_dt : '||p_schedule_dt);
   pnp_debug_pkg.log('update_cash_item IN: p_sch_str_dt  : '||p_sch_str_dt);
   pnp_debug_pkg.log('update_cash_item IN: p_sch_end_dt  : '||p_sch_end_dt);
   pnp_debug_pkg.log('update_cash_item IN: p_act_amt     : '||p_act_amt);
   pnp_debug_pkg.log('update_cash_item IN: p_est_amt     : '||p_est_amt);
   pnp_debug_pkg.log('update_cash_item IN: p_freq        : '||p_freq);
   /* Get the new amount for the schedule */

   get_amount(p_sch_str_dt    => p_sch_str_dt,
              p_sch_end_dt    => p_sch_end_dt,
              p_trm_str_dt    => p_term_str_dt,
              p_trm_end_dt    => p_term_end_dt,
              p_act_amt       => p_act_amt,
              p_est_amt       => p_est_amt,
              p_freq          => p_freq,
              p_cash_act_amt  => l_cash_act_amt,
              p_cash_est_amt  => l_cash_est_amt);

   /* update the cash amount for the schedule */
   FOR rec IN currency_cur LOOP
      fnd_currency.get_info( currency_code => rec.currency_code
                            ,precision     => l_precision
                            ,ext_precision => l_ext_precision
                            ,min_acct_unit => l_min_acct_unit);
   END LOOP;
   l_cash_act_amt := ROUND(l_cash_act_amt, l_precision);
   l_cash_est_amt := ROUND(l_cash_est_amt, l_precision);

  --Bug 9150650
  select nvl(sum(actual_amount),0),
	  nvl(sum(estimated_amount),0),
	  nvl(sum(export_currency_amount),0)
	  into l_cash_act_amt_appr,
 	       l_cash_est_amt_appr,
               l_cash_exp_amt_appr
   from   pn_payment_items_all ppi,
          pn_payment_schedules_all pps
   where  pps.lease_id = g_lease_id
   and    pps.payment_status_lookup_code = 'APPROVED'
   and    pps.payment_schedule_id = ppi.payment_schedule_id
   and    ppi.payment_term_id = p_term_id
   and    ppi.payment_item_type_lookup_code = 'CASH'
   and    pps.schedule_date = p_schedule_dt;

   UPDATE pn_payment_items_all
   SET    estimated_amount = l_cash_est_amt - l_cash_est_amt_appr, --Bug 9150650
          actual_amount    = l_cash_act_amt - l_cash_act_amt_appr,
          export_currency_amount = l_cash_act_amt - l_cash_exp_amt_appr,
          last_update_date = SYSDATE,
          last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
          last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
   WHERE  payment_item_id  = (SELECT ppi1.payment_item_id
                              FROM   pn_payment_items_all ppi1,
                                     pn_payment_schedules_all pps
                              WHERE  ppi1.payment_term_id = p_term_id
                              AND    ppi1.payment_item_type_lookup_code = 'CASH'
                              AND    pps.payment_status_lookup_code = 'DRAFT'
                              AND    pps.payment_schedule_id = ppi1.payment_schedule_id
                              AND    pps.schedule_date = p_schedule_dt);

   pnp_debug_pkg.log('update_cash_item -End- (-)');

END update_cash_item;

-------------------------------------------------------------------------------
--  PROCEDURE  : RECALCULATE_CASH
--  DESCRIPTION: This procedure is used to contract a given lease. All payment
--               terms of the lease are contracted, Cash Items are deleted.
--               The last Cash Item is recalculated and updated by calling
--               procedure UPDATE_CASH_ITEM.
--  25-JUN-2001  Mrinal Misra    o Created.
--  07-JAN-2002  Mrinal Misra    o Added condition "IF l_schedule_date
--                                 IS NOT NULL", since l_schedule_date can be
--                                 null if no approved DRAFT schedules
--                                 are found, hence getting to the end of the
--                                 loop.
--  26-MAR-2002  Satish Tripathi o Added condition to correctly point the
--                                 l_sch_str_dt Schedule-Start-Date) for
--                                 NON MONTHLY Payment Term.
--  03-OCT-2005  pikhar          o Added frequency_code check to cursor
--                                 get_terms
--  13-Jan-2010  nkapling        o Bug 9150650 :- Commented the end_date condition
--                                 in get_terms cursor.
--                                 Passed p_new_lease_term_date as p_term_end_dt
--                                 to update_cash_item
-------------------------------------------------------------------------------
PROCEDURE recalculate_cash (p_new_lease_term_date DATE)
IS

   l_sch_str_dt                    DATE;
   l_sch_end_dt                    DATE;
   l_schedule_date                 DATE;
   l_cash_est_amt                  pn_payment_items.estimated_amount%TYPE;
   l_cash_act_amt                  pn_payment_items.actual_amount%TYPE;
   l_frequency                     NUMBER;

   -- Bug 7570052
   l_cal_yr_st                     pn_leases_all.cal_start%TYPE;

   CURSOR get_terms IS
      SELECT payment_term_id,
             start_date,
             end_date,
             actual_amount,
             estimated_amount,
             frequency_code
      FROM   pn_payment_terms_all
      WHERE  lease_id = g_lease_id
      --AND    end_date = p_new_lease_term_date Bug 9150650
      AND    frequency_code <> 'OT';

   CURSOR get_last_schedule (p_payment_term_id NUMBER) IS
      SELECT MAX(schedule_date)
      FROM   pn_payment_schedules_all pps,
             pn_payment_items_all     ppi
      WHERE  ppi.payment_term_id = p_payment_term_id
      AND    ppi.payment_item_type_lookup_code = 'CASH'
      AND    ppi.actual_amount <> 0
      AND    pps.payment_schedule_id = ppi.payment_schedule_id
      AND    pps.payment_status_lookup_code = 'DRAFT';

BEGIN

   pnp_debug_pkg.log('recalculate_cash +Start+ (+) IN: p_new_lease_term_date: '
                     ||p_new_lease_term_date);

   -- Bug 7570052
   SELECT cal_start
   INTO l_cal_yr_st
   FROM pn_leases_all
   WHERE lease_id = g_lease_id;

   FOR term IN get_terms
   LOOP

      pnp_debug_pkg.log('recalculate_cash - Term Id : '||term.payment_term_id);
      /* get the last schedule with non zero amount */

      OPEN get_last_schedule (term.payment_term_id);
         FETCH get_last_schedule INTO l_schedule_date;
      CLOSE get_last_schedule;

      IF l_schedule_date IS NOT NULL THEN

         pnp_debug_pkg.log('recalculate_cash - l_schedule_date'||l_schedule_date);

         /* get the frequency */

         l_frequency := get_frequency(p_freq_code => term.frequency_code);

         /* get the applicable dates for the schedule */

         /* For Monthly and OT Term, Schedule-Start-Date is
            the First Day of the month of Schedule-Date.
            For Non Monthly Term, Schedule-Start-Date is
            Term Start Day of the month of the Schedule-Date. */

         IF term.frequency_code = 'MON' THEN

            l_sch_str_dt := First_Day(l_schedule_date);
            l_sch_end_dt := LAST_DAY(l_schedule_date);

         ELSE

            l_sch_str_dt := TO_DATE(NVL(substr(l_cal_yr_st,1,2),TO_CHAR(term.start_date,'DD'))||'/'
                                            ||TO_CHAR(l_schedule_date,'MM/YYYY')
                                    ,'DD/MM/YYYY');
            l_sch_end_dt := ADD_MONTHS(l_sch_str_dt, l_frequency)-1;

         END IF;

         update_cash_item(p_term_id       => term.payment_term_id,
                          p_term_str_dt   => term.start_date,
                          p_term_end_dt   => p_new_lease_term_date,--Bug 9150650
                          p_schedule_dt   => l_schedule_date,
                          p_sch_str_dt    => l_sch_str_dt,
                          p_sch_end_dt    => l_sch_end_dt,
                          p_act_amt       => term.actual_amount,
                          p_est_amt       => term.estimated_amount,
                          p_freq          => l_frequency);

      END IF;

   END LOOP;
   pnp_debug_pkg.log('recalculate_cash -End- (-)');

END recalculate_cash;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : ADD_MAIN
--  DESCRIPTION: This procedure is used to add a payment term in a given lease when lease is
--               is added through EDIT or AMEND. GET_SCH_INFO gives information of the term,
--               PROCESS_TERM creates schedules if required and the Cash / Normalized items.
--  25-JUN-2001  Mrinal Misra    o Created.
--  15-AUG-2001  Mrinal Misra    o Added calls to routine
--                                 pn_index_rent_periods_pkg.process_payment_term_amendment.
--  24-JAN-2002  Satish Tripathi o Removed the hard coding of p_lease_context being passed to
--                                 GET_SCH_INFO and PROCESS_TERM.
--  07-FEB-2002  Satish Tripathi o Added variable l_norm_str_dt to capture Normalize Start
--                                 Date, if the term is added through AMEND.
--  26-MAR-2002  Satish Tripathi o Added variable l_sch_str_dt to correctly point the
--                                 Schedule-Start-Date for NON MONTHLY Payment Term.
--  10-DEC-2002  graghuna        o Modified to update pn_payment_terms_all.norm_end_date
--                                 for Month-to-Month Re-Normalization issue. --MTM-I
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Conditionally pass lease_context
--                                 depending on change_type_lookup_code of a particular term.
--                                 Pass new parameter p_amd_comm_dt to get_sch_info and
--                                 p_lease_change_id to process_term.
--------------------------------------------------------------------------------------------
PROCEDURE add_main (p_lease_id           NUMBER,
                    p_lease_context      VARCHAR2,
                    p_new_lea_term_dt    DATE,
                    p_new_lea_comm_dt    DATE,
                    p_mths               NUMBER)
IS

   l_pro_sch_dt                    pn_payment_schedules.schedule_date%TYPE;
   l_no_sch                        NUMBER;
   l_freq                          NUMBER;
   l_counter                       NUMBER;
   l_sch_dt                        pn_payment_schedules.schedule_date%TYPE;
   l_msg                           VARCHAR2(2000);
   l_norm_str_dt                   DATE;
   l_sch_str_dt                    DATE;
   l_lease_context                 VARCHAR2(100);

BEGIN

   pnp_debug_pkg.log('ADD_MAIN +Start+ (+)');
   pnp_debug_pkg.log('ADD_MAIN IN: p_lease_id           : '||p_lease_id);
   pnp_debug_pkg.log('ADD_MAIN IN: p_lease_context      : '||p_lease_context);
   pnp_debug_pkg.log('ADD_MAIN IN: p_new_lea_term_dt    : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('ADD_MAIN IN: p_new_lea_comm_dt    : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('ADD_MAIN IN: p_mths               : '||p_mths);
   FOR add_main_cur IN term_add_main_cur(p_lease_id)
   LOOP

      IF add_main_cur.change_type_lookup_code = 'AMEND' THEN
         l_lease_context := 'ADDAMD';
      ELSIF add_main_cur.change_type_lookup_code = 'EDIT' THEN
         l_lease_context := 'ADDEDT';
      END IF;

      pnp_debug_pkg.log('ADD_MAIN lease_change_id: '||add_main_cur.lease_change_id
                        ||', l_lease_context: '||l_lease_context
                        ||', amd_comm_dt: '||add_main_cur.change_commencement_date);

      get_sch_info(p_lease_context            => l_lease_context,
                   p_normalize_flag           => add_main_cur.normalize,
                   p_mths                     => p_mths,
                   p_term_start_dt            => add_main_cur.start_date,
                   p_term_end_dt              => add_main_cur.end_date,
                   p_freq_code                => add_main_cur.frequency_code,
                   p_sch_day                  => add_main_cur.schedule_day,
                   p_new_lea_comm_dt          => p_new_lea_comm_dt,
                   p_new_lea_term_dt          => p_new_lea_term_dt,
                   p_old_lea_term_dt          => NULL,
                   p_no_sch                   => l_no_sch,
                   p_freq                     => l_freq,
                   p_counter                  => l_counter,
                   p_sch_dt                   => l_sch_dt,
                   p_pro_sch_dt               => l_pro_sch_dt,
                   p_sch_str_dt               => l_sch_str_dt,
                   p_norm_str_dt              => l_norm_str_dt,
                   p_lease_id                 => p_lease_id,
                   p_term_id                  => add_main_cur.payment_term_id,
                   p_amd_comm_dt              => add_main_cur.change_commencement_date);

      process_term(p_no_sch                   => l_no_sch,
                   p_counter                  => l_counter,
                   p_sch_dt                   => l_sch_dt,
                   p_pro_sch_dt               => l_pro_sch_dt,
                   p_new_lea_term_dt          => p_new_lea_term_dt ,
                   p_freq                     => l_freq,
                   p_freq_code                => add_main_cur.frequency_code,
                   p_payment_term_id          => add_main_cur.payment_term_id,
                   p_pay_trm_typ_code         => add_main_cur.payment_term_type_code,
                   p_trgt_dt                  => add_main_cur.target_date,
                   p_normalize_flag           => add_main_cur.normalize,
                   p_lease_context            => l_lease_context,
                   p_mths                     => p_mths,
                   p_vendor_id                => add_main_cur.vendor_id,
                   p_customer_id              => add_main_cur.customer_id,
                   p_vendor_site_id           => add_main_cur.vendor_site_id,
                   p_customer_site_use_id     => add_main_cur.customer_site_use_id,
                   p_cust_ship_site_id        => add_main_cur.cust_ship_site_id,
                   p_set_of_books_id          => add_main_cur.set_of_books_id,
                   p_currency_code            => add_main_cur.currency_code,
                   p_rate                     => add_main_cur.rate,
                   p_term_start_date          => add_main_cur.start_date,
                   p_term_end_date            => add_main_cur.end_date,
                   p_sch_str_dt               => l_sch_str_dt,
                   p_act_amt                  => add_main_cur.actual_amount,
                   p_est_amt                  => add_main_cur.estimated_amount,
                   p_index_prd_id             => NULL,
                   p_norm_str_dt              => l_norm_str_dt,
                   p_lease_change_id          => add_main_cur.lease_change_id);

      -- OT terms are not used in Index Rent calculations, ignore it.
      IF add_main_cur.frequency_code <> 'OT' THEN

         pn_index_rent_periods_pkg.process_payment_term_amendment(
                                   p_lease_id           => p_lease_id,
                                   p_payment_type_code  => add_main_cur.payment_term_type_code,
                                   p_payment_start_date => add_main_cur.start_date,
                                   p_payment_end_date   => add_main_cur.end_date,
                                   p_msg                => l_msg);

      END IF;

      IF add_main_cur.normalize = 'Y' THEN
         UPDATE pn_payment_terms_all
         SET    norm_start_date = NVL(l_norm_str_dt, p_new_lea_comm_dt),
                norm_end_date   = g_new_lea_term_dt
         WHERE  payment_term_id = add_main_cur.payment_term_id;
      END IF;

   END LOOP;
   pnp_debug_pkg.log('ADD_MAIN -End- (-)');

END add_main;


--------------------------------------------------------------------------------------------
--  FUNCTION   : LOCKED_AREA_EXPENSE_CLASS
--  DESCRIPTION: This function checks if the area class of the associated area class with
--               tenancy space assignment is locked or not.
--  04-DEC-2003  Satish Tripathi o Created for BUG# 3284799.
--------------------------------------------------------------------------------------------
FUNCTION Locked_Area_Expense_Class (p_tenancy_id IN NUMBER,
                                    p_str_date   IN DATE,
                                    p_end_date   IN DATE)
RETURN BOOLEAN
IS
   l_exists                VARCHAR2(30) := 'N';
BEGIN
   pnp_debug_pkg.log('LOCKED_AREA_EXPENSE_CLASS -Start- (+)');

   IF g_lease_class_code <> 'SUB_LEASE' THEN

      BEGIN
         SELECT 'Y'
         INTO   l_exists
         FROM   DUAL
         WHERE  EXISTS (SELECT NULL
                        FROM  pn_space_assign_cust_all psa
                        WHERE psa.tenancy_id = p_tenancy_id
                        AND  (EXISTS (SELECT NULL
                                      FROM   pn_rec_arcl_dtl_all   mst,
                                             pn_rec_arcl_dtlln_all dtl
                                      WHERE  mst.area_class_dtl_id = dtl.area_class_dtl_id
                                      AND    mst.status = 'LOCKED'
                                      AND    dtl.cust_space_assign_id = psa.cust_space_assign_id) OR
                              EXISTS (SELECT NULL
                                      FROM   pn_rec_expcl_dtl_all   mst,
                                             pn_rec_expcl_dtlln_all dtl
                                      WHERE  mst.expense_class_dtl_id = dtl.expense_class_dtl_id
                                      AND    mst.status = 'LOCKED'
                                      AND    dtl.cust_space_assign_id = psa.cust_space_assign_id))
                       );
      EXCEPTION
         WHEN OTHERS THEN
            l_exists := 'N';
      END;

   END IF;

   pnp_debug_pkg.log('LOCKED_AREA_EXPENSE_CLASS -End- (-) Return: '||l_exists);
   IF l_exists = 'Y' THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

END Locked_Area_Expense_Class;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : CONTRACT_TENANCIES
--  DESCRIPTION: This procedure is used to early terminate tenancies with Contraction.
--               If these is associated area class with tenancy space assignment, Only that
--               tenancy will not be early terminated and message will be logged.
--  04-DEC-2003  Satish Tripathi o Created for BUG# 3284799.
--  05-DEC-2003  Satish Tripathi o Pass p_cust_assign_end_dt as p_new_lea_term_dt when
--                                 calling pn_tenancies_pkg.update_auto_space_assign.
--                                 Update fin_oblig_end_date of pn_tenancies to p_new_lea_term_dt.
--------------------------------------------------------------------------------------------
PROCEDURE contract_tenancies(
                                p_lease_id           NUMBER
                               ,p_new_lea_term_dt    DATE
                                )
IS

   l_tenancy_Id                    pn_tenancies_all.tenancy_id%TYPE;
   l_location_id                   pn_locations_all.location_id%TYPE;
   l_location_code                 pn_locations_all.location_code%TYPE;
   l_loc_type_code                 pn_locations_all.location_type_lookup_code%TYPE;
   l_action                        VARCHAR2(30) := NULL;
   l_message                       VARCHAR2(30) := NULL;
   l_tenancy_str_date              DATE;
   l_tenancy_end_date              DATE;


   CURSOR get_delete_tenancies_csr IS
      SELECT tenancy_id,
             location_id,
             occupancy_date,
             estimated_occupancy_date,
             expiration_date
      FROM   pn_tenancies_all pnt
      WHERE  pnt.lease_id = p_lease_id
      AND    NVL(pnt.occupancy_date, pnt.estimated_occupancy_date) > p_new_lea_term_dt;

   CURSOR get_update_tenancies_csr IS
      SELECT *
      FROM   pn_tenancies_all pnt
      WHERE  pnt.lease_id = p_lease_id
      AND    pnt.expiration_date > p_new_lea_term_dt;

   CURSOR get_location_type_csr (p_location_id NUMBER, p_start_date DATE) IS
      SELECT location_code,
             location_type_lookup_code
      FROM   pn_locations_all pnl
      WHERE  pnl.location_id = p_location_id
      AND    p_start_date BETWEEN pnl.active_start_date AND pnl.active_end_date;

BEGIN

   pnp_debug_pkg.log('CONTRACT_TENANCIES of MAIN Lease +Start+ (+)');
   pnp_debug_pkg.log('CONTRACT_TENANCIES IN: p_lease_id        : '||p_lease_id);
   pnp_debug_pkg.log('CONTRACT_TENANCIES IN: p_new_lea_term_dt : '||p_new_lea_term_dt);

   FOR get_delete_tenancies IN get_delete_tenancies_csr
   LOOP
      l_action           := NULL;
      l_location_code    := NULL;
      l_loc_type_code    := NULL;
      l_location_id      := get_delete_tenancies.location_id;
      l_tenancy_Id       := get_delete_tenancies.tenancy_Id;
      l_tenancy_str_date := NVL(get_delete_tenancies.occupancy_date,
                                get_delete_tenancies.estimated_occupancy_date);
      l_tenancy_end_date := get_delete_tenancies.expiration_date;

      pnp_debug_pkg.log('CON_TEN=>DEL : Deleting Tenancy_Id: '||l_tenancy_Id);

      OPEN get_location_type_csr(l_location_id, l_tenancy_str_date);
      FETCH get_location_type_csr INTO l_location_code, l_loc_type_code;
      CLOSE get_location_type_csr;

      IF Locked_Area_Expense_Class(l_tenancy_Id, l_tenancy_str_date, l_tenancy_end_date) THEN
         pnp_debug_pkg.put_log_msg('********************************************************************************');
         fnd_message.set_name ('PN','PN_SCHIT_LOCK_DEL');
         fnd_message.set_token ('LOC_CODE', l_location_code);
         fnd_message.set_token ('ODATE', l_tenancy_str_date);
         fnd_message.set_token ('EDATE', l_tenancy_end_date);
         pnp_debug_pkg.put_log_msg(fnd_message.get);
         pnp_debug_pkg.put_log_msg('********************************************************************************');
      ELSE

         pn_tenancies_pkg.delete_row(
                                x_tenancy_id                    =>  get_delete_tenancies.tenancy_id
                               );

         pn_tenancies_pkg.delete_auto_space_assign(
                                p_tenancy_id                    => get_delete_tenancies.tenancy_id
                               ,p_action                        => l_action
                               ,p_location_id                   => get_delete_tenancies.location_id
                               ,p_loc_type_code                 => l_loc_type_code
                               );

         pnp_debug_pkg.log('CON_TEN=>DEL : Tenancy and Space Assignments deleted. l_action:  '||l_action);

         IF l_action = 'R' THEN  --Regenerate

         pnp_debug_pkg.put_log_msg('********************************************************************************');
         fnd_message.set_name ('PN','PN_SCHIT_CUST');
         fnd_message.set_token ('LOC_CODE', l_location_code);
         fnd_message.set_token ('ODATE', l_tenancy_str_date);
         fnd_message.set_token ('EDATE', l_tenancy_end_date);
         pnp_debug_pkg.put_log_msg(fnd_message.get);
         pnp_debug_pkg.put_log_msg('********************************************************************************');

         END IF;
      END IF;
   END LOOP;

   pnp_debug_pkg.log('CON_TEN: Deleting Tenancies  complete. To Early Terminate Tenancies....');

   FOR get_update_tenancies IN get_update_tenancies_csr
   LOOP
      l_action           := NULL;
      l_message          := NULL;
      l_location_code    := NULL;
      l_loc_type_code    := NULL;
      l_location_id      := get_update_tenancies.location_id;
      l_tenancy_Id       := get_update_tenancies.tenancy_Id;
      l_tenancy_str_date := NVL(get_update_tenancies.occupancy_date,
                                get_update_tenancies.estimated_occupancy_date);
      l_tenancy_end_date := get_update_tenancies.expiration_date;

      pnp_debug_pkg.log('CON_TEN=>UPD : Early Terminating Tenancy_Id: '||l_tenancy_Id);

      pn_tenancies_pkg.update_auto_space_assign
      (
         p_location_id                   => get_update_tenancies.location_id
        ,p_lease_id                      => p_lease_id
        ,p_customer_id                   => get_update_tenancies.customer_id
        ,p_cust_site_use_id              => get_update_tenancies.customer_site_use_id
        ,p_cust_assign_start_dt          => l_tenancy_str_date
        ,p_cust_assign_end_dt            => p_new_lea_term_dt
        ,p_recovery_space_std_code       => get_update_tenancies.recovery_space_std_code
        ,p_recovery_type_code            => get_update_tenancies.recovery_type_code
        ,p_fin_oblig_end_date            => p_new_lea_term_dt
        ,p_allocated_pct                 => get_update_tenancies.allocated_area_pct
        ,p_tenancy_id                    => get_update_tenancies.tenancy_id
        ,p_org_id                        => get_update_tenancies.org_id
        ,p_location_id_old               => get_update_tenancies.location_id
        ,p_customer_id_old               => get_update_tenancies.customer_id
        ,p_cust_site_use_id_old          => get_update_tenancies.customer_site_use_id
        ,p_cust_assign_start_dt_old      => l_tenancy_str_date
        ,p_cust_assign_end_dt_old        => get_update_tenancies.expiration_date
        ,p_recovery_space_std_code_old   => get_update_tenancies.recovery_space_std_code
        ,p_recovery_type_code_old        => get_update_tenancies.recovery_type_code
        ,p_fin_oblig_end_date_old        => get_update_tenancies.fin_oblig_end_date
        ,p_allocated_pct_old             => get_update_tenancies.allocated_area_pct
        ,p_action                        => l_action
        ,p_msg                           => l_message
      );

      pnp_debug_pkg.log('CON_TEN=>UPD : Space Assignments deleted. l_action:  '||l_action);

      IF l_action = 'S' THEN
         OPEN get_location_type_csr(l_location_id, l_tenancy_str_date);
         FETCH get_location_type_csr INTO l_location_code, l_loc_type_code;
         CLOSE get_location_type_csr;

         pnp_debug_pkg.put_log_msg('********************************************************************************');
         fnd_message.set_name ('PN','PN_SCHIT_LOCK_UPD');
         fnd_message.set_token ('LOC_CODE', l_location_code);
         fnd_message.set_token ('ODATE', l_tenancy_str_date);
         fnd_message.set_token ('EDATE', l_tenancy_end_date);
         pnp_debug_pkg.put_log_msg(fnd_message.get);
         pnp_debug_pkg.put_log_msg('********************************************************************************');
      ELSE

         UPDATE pn_tenancies_all
         SET    expiration_date = p_new_lea_term_dt,
                fin_oblig_end_date = p_new_lea_term_dt,
                last_update_date = SYSDATE,
                last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
                last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
         WHERE  tenancy_id = l_tenancy_Id;

         pnp_debug_pkg.log('CON_TEN=>UPD : Tenancy Early Terminated...');

         IF l_action = 'R' THEN  --Regenerate
            OPEN get_location_type_csr(l_location_id, l_tenancy_str_date);
            FETCH get_location_type_csr INTO l_location_code, l_loc_type_code;
            CLOSE get_location_type_csr;

            pnp_debug_pkg.put_log_msg('********************************************************************************');
            fnd_message.set_name ('PN','PN_SCHIT_CUST');
            fnd_message.set_token ('LOC_CODE', l_location_code);
            fnd_message.set_token ('ODATE', l_tenancy_str_date);
            fnd_message.set_token ('EDATE', l_tenancy_end_date);
            pnp_debug_pkg.put_log_msg(fnd_message.get);
            pnp_debug_pkg.put_log_msg('********************************************************************************');
         END IF;
      END IF;
   END LOOP;

   pnp_debug_pkg.log('CONTRACT_TENANCIES of MAIN Lease +End+ (-)');

END contract_tenancies;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : CONTRACTION
--  DESCRIPTION: This procedure is used to contract a given lease. Extra schedules and Cash
--               Items of all terms are deleted and the cash for last item is recalculeted.
--               For Normalized term, items are re-Normalized.
--  25-JUN-2001  Mrinal Misra    o Created.
--  05-AUG-2001  Amita Singh     o Modified to take care of CON+ADD. Added call to ADD_MAIN.
--  15-AUG-2001  Mrinal Misra    o Added calls to routine
--                                 pn_index_rent_periods_pkg.process_main_lease_term_date.
--  05-SEP-2001  Mrinal Misra    o Added to check for payment_term_id in the update statement
--                                 of PN_PAYMENT_ITEMS.
--  24-JAN-2002  Satish Tripathi o Removed the hard coding of p_lease_context being passed to
--                                 CREATE_NORMALIZE_ITEMS.
--  07-FEB-2002  Satish Tripathi o Added variable l_norm_str_dt to capture Normalize Start
--                                 Date, if term was added through AMEND and pass it to
--                                 routine CREATE_NORMALIZE_ITEMS.
--  10-DEC-2002  graghuna        o Modified to get and pass p_active_lease_change_id to
--                                 cursor and update pn_payment_terms_all.norm_end_date
--                                 for Month-to-Month Re-Normalization issue. --MTM-I
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Pass new parameter p_lease_change_id
--                                 to create_normalize_items.
--  03-DEC-2003  Satish Tripathi o Call Contract_Tenancies to early terminate tenancies only
--                                 for Sub_Lease and Third_Party leases (BUG# 3284799).
--  24-MAR-2004  Satish Tripathi o Fixed for BUG# 3295405. If norm_start_date is null
--                                 (old data), use Get_First_Item_Date.
--  21-Oct-2004 vmmehta          o Bug# 3942294 Do not delete VR terms during contraction
--------------------------------------------------------------------------------------------
PROCEDURE contraction (p_lease_id           NUMBER,
                       p_lease_context      VARCHAR2,
                       p_new_lea_term_dt    DATE,
                       p_new_lea_comm_dt    DATE,
                       p_mths               NUMBER)
IS

   l_msg                           VARCHAR2(2000);
   l_old_lea_term_dt               DATE;
   l_norm_str_dt                   DATE;
   l_active_lease_change_id        pn_lease_details.lease_change_id%TYPE;

   CURSOR get_old_lea_term_dt IS
      SELECT plh.lease_termination_date
      FROM   pn_lease_details_history plh,
             pn_lease_details_all pld
      WHERE  pld.lease_change_id = plh.new_lease_change_id
      AND    pld.lease_id = p_lease_id;

BEGIN

   pnp_debug_pkg.log('CONTRACTION of MAIN Lease +Start+ (+)');
   pnp_debug_pkg.log('CONTRACTION IN: p_lease_id         : '||p_lease_id);
   pnp_debug_pkg.log('CONTRACTION IN: p_lease_context    : '||p_lease_context);
   pnp_debug_pkg.log('CONTRACTION IN: p_new_lea_term_dt  : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('CONTRACTION IN: p_new_lea_comm_dt  : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('CONTRACTION IN: p_mths             : '||p_mths);

   /* If lease is contracted from main lease form then delete payment
      items for the lease, for which payment schedules are in draft
      status and schedule date is greater than lease termination date. */

   OPEN get_old_lea_term_dt;
      FETCH get_old_lea_term_dt INTO l_old_lea_term_dt;
   CLOSE get_old_lea_term_dt;

   pnp_debug_pkg.log('CON - MAIN - Deleting Payment Items');

   DELETE pn_payment_items_all
   WHERE payment_schedule_id IN (SELECT payment_schedule_id
                                 FROM   pn_payment_schedules_all
                                 WHERE  lease_id = p_lease_id
                                 AND    schedule_date > p_new_lea_term_dt
                                 AND    payment_status_lookup_code = 'DRAFT')
   AND payment_term_id NOT IN (SELECT payment_term_id
                               FROM pn_payment_terms_all
                               WHERE lease_id = p_lease_id
                               AND var_rent_inv_id IS NOT NULL);

   /* Delete payment schedules for the lease which are in draft status
      and schedule date is greater than lease termination date. */

   pnp_debug_pkg.log('CON - MAIN - Deleting Payment Schedules');

   DELETE pn_payment_schedules_all psch
   WHERE lease_id = p_lease_id
   AND schedule_date > p_new_lea_term_dt
   AND payment_status_lookup_code = 'DRAFT'
   AND NOT EXISTS (SELECT null
                   FROM pn_payment_items_all pitm
                   WHERE pitm.payment_schedule_id = psch.payment_schedule_id);

   DELETE pn_payment_items_all
   WHERE  payment_term_id IN (SELECT payment_term_id
                              FROM   pn_payment_terms_all
                              WHERE  start_date > p_new_lea_term_dt
                              AND    lease_id = p_lease_id)
   AND payment_term_id NOT IN (SELECT payment_term_id
                               FROM pn_payment_terms_all
                               WHERE lease_id = p_lease_id
                               AND var_rent_inv_id IS NOT NULL);

   /* Delete payment terms for the lease which have term start date
      greater than lease termination date. */

   pnp_debug_pkg.log('CON - MAIN - Deleting Payment Terms');

   DELETE pn_payment_terms_all
   WHERE lease_id = p_lease_id
   AND start_date > p_new_lea_term_dt
   AND var_rent_inv_id IS NULL;

   /* Update end date of remaining payment terms for the lease to
      lease termination date. */

   pnp_debug_pkg.log('CON - MAIN - Updating end date of Payment Terms');

   UPDATE pn_payment_terms_all
   SET end_date = p_new_lea_term_dt,
       last_update_date = SYSDATE,
       last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
       last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
   WHERE lease_id = p_lease_id
   AND end_date > p_new_lea_term_dt
  AND frequency_code <> 'OT';

   /* Call the index rent contraction routine */

   pnp_debug_pkg.log('CON - MAIN - Contracting Index rent ');

   pn_index_rent_periods_pkg.process_main_lease_term_date(p_lease_id,
                                                          p_new_lea_term_dt,
                                                          l_old_lea_term_dt,
                                                          p_lease_context,
                                                          l_msg);

   /* Update the cash items with new amount, for the terms which have
      been contracted. */

   pnp_debug_pkg.log('CON - MAIN - Updating last non zero cash items with new pro. amt');

   recalculate_cash(p_new_lease_term_date => p_new_lea_term_dt);

   /*Get the normalized payment terms for which re-normalization needs
      to be done  */

   pnp_debug_pkg.log('CON - MAIN - Doing re-normalization');

   l_active_lease_change_id := Get_Lease_Change_Id(p_lease_id);
   FOR con_cur IN term_con_exp_cur(p_lease_id,l_active_lease_change_id)
   LOOP

      pnp_debug_pkg.log('CON - MAIN - Re-Normalization - Term Id : '||con_cur.payment_term_id);

      /* If the lease is Contracted, Normalization of term should start from
         the same date of normalization, when the term was Abstracted or Added. */

      l_norm_str_dt := NVL(con_cur.norm_start_date, Get_First_Item_Date(con_cur.payment_term_id));
pnp_debug_pkg.log('CON - MAIN - Re-Normalization - l_norm_str_dt : '||l_norm_str_dt);
      /* AMT-RETRO */
      IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
        create_normalize_items(p_lease_context      => p_lease_context,
                               p_lease_id           => p_lease_id,
                               p_term_id            => con_cur.payment_term_id,
                               p_vendor_id          => con_cur.vendor_id,
                               p_cust_id            => con_cur.customer_id,
                               p_vendor_site_id     => con_cur.vendor_site_id,
                               p_cust_site_use_id   => con_cur.customer_site_use_id,
                               p_cust_ship_site_id  => con_cur.cust_ship_site_id,
                               p_sob_id             => con_cur.set_of_books_id,
                               p_curr_code          => con_cur.currency_code,
                               p_sch_day            => con_cur.schedule_day,
                               p_norm_str_dt        => l_norm_str_dt,
                               p_norm_end_dt        => g_new_lea_term_dt,
                               p_rate               => con_cur.rate,
                               p_lease_change_id    => con_cur.lease_change_id);
      ELSE
        PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE
                              (p_lease_context      => p_lease_context,
                               p_lease_id           => p_lease_id,
                               p_term_id            => con_cur.payment_term_id,
                               p_vendor_id          => con_cur.vendor_id,
                               p_cust_id            => con_cur.customer_id,
                               p_vendor_site_id     => con_cur.vendor_site_id,
                               p_cust_site_use_id   => con_cur.customer_site_use_id,
                               p_cust_ship_site_id  => con_cur.cust_ship_site_id,
                               p_sob_id             => con_cur.set_of_books_id,
                               p_curr_code          => con_cur.currency_code,
                               p_sch_day            => con_cur.schedule_day,
                               p_norm_str_dt        => l_norm_str_dt,
                               p_norm_end_dt        => g_new_lea_term_dt,
                               p_rate               => con_cur.rate,
                               p_lease_change_id    => con_cur.lease_change_id);
      END IF;

      pnp_debug_pkg.log('CON - MAIN - Renormalization done for Term   : '
                         ||TO_CHAR(con_cur.payment_term_id));

      UPDATE pn_payment_terms_all
      SET    norm_end_date   = g_new_lea_term_dt
      WHERE  payment_term_id = con_cur.payment_term_id;

   END LOOP;

   /* Now create the schedules and items for the new terms that have been added along with
      the contraction of the main lease */

   add_main(p_lease_id            => p_lease_id,
            p_lease_context       => 'ADDAMD',
            p_new_lea_term_dt     => p_new_lea_term_dt,
            p_new_lea_comm_dt     => p_new_lea_comm_dt,
            p_mths                => p_mths);

   /* For Sub_Lease and Third_Party lease, contract tenancies and associated
       space assignments as well. */

   IF g_lease_class_code <> 'DIRECT' THEN
      contract_tenancies(
                                p_lease_id           => p_lease_id
                               ,p_new_lea_term_dt    => p_new_lea_term_dt
                                );
   END IF;

   pnp_debug_pkg.log('CONTRACTION of MAIN Lease -End- (-)');

END contraction;

--------------------------------------------------------------------------------------------
--  PROCEDURE  : CONTRACTION_BY_ITM_END_DT
--  DESCRIPTION: This procedure is used to contract a given lease. Extra schedules and Cash
--               Items of all terms are deleted and the cash for last item is recalculeted.
--               For Normalized term, items are re-Normalized.The contraction is done based
--               on item end dates of the terms
-- 18-APR-07 sdmahesh         Bug # 5985779. Enhancement for new profile
--                            option for lease early termination
-- 24-MAR-10 acprakas         Bug#9323699. Modified to use condition nvl(l_item_end_dt_tbl(i).item_end_dt,l_max_item_end_dt)
--                            so that l_item_end_dt_tbl(i).item_end_dt gets set to new lease termination date
--                            when l_item_end_dt_tbl(i).item_end_dt is null.
-- 17-MAY-10 asahoo           Bug#9214283 - Calling the API pn_retro_adjustment_pkg.find_schedule to create adjustment amount
--                            if there is no draft schedule available
--------------------------------------------------------------------------------------------
PROCEDURE contraction_by_itm_end_dt (p_lease_id           NUMBER,
                                     p_lease_context      VARCHAR2,
                                     p_new_lea_term_dt    DATE,
                                     p_new_lea_comm_dt    DATE,
                                     p_mths               NUMBER)
IS

   l_msg                           VARCHAR2(2000);
   l_old_lea_term_dt               DATE;
   l_norm_str_dt                   DATE;
   l_active_lease_change_id        pn_lease_details.lease_change_id%TYPE;
   l_norm_trm_exsts                BOOLEAN := FALSE;
   l_item_end_dt_tbl               pnp_util_func.item_end_dt_tbl_type;
   i                               NUMBER;
   l_max_item_end_dt               DATE := TO_DATE('01/01/0001', 'MM/DD/YYYY');
   l_ri_end_dt                     DATE := TO_DATE('01/01/0001', 'MM/DD/YYYY');
   l_term_end_dt                   DATE := NULL;
   l_sch_dt_1                      DATE;
   l_payment_schedule_id           pn_payment_items_all.payment_schedule_id%TYPE;
   CURSOR get_old_lea_term_dt IS
      SELECT plh.lease_termination_date
      FROM   pn_lease_details_history plh,
             pn_lease_details_all pld
      WHERE  pld.lease_change_id = plh.new_lease_change_id
      AND    pld.lease_id = p_lease_id;

   CURSOR get_drf_sch_date(p_payment_term_id NUMBER) IS
            SELECT distinct schedule_date
            FROM   pn_payment_items_all ppi,
                   pn_payment_schedules_all pps
            WHERE  ppi.payment_term_id =  p_payment_term_id
            AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
            AND    pps.payment_schedule_id = ppi.payment_schedule_id
            AND    pps.payment_status_lookup_code <>  'DRAFT'
            and    schedule_date >= pn_schedules_items.FIRST_DAY(l_norm_str_dt)
            and    schedule_date <=  (SELECT lease_termination_date
                                      FROM pn_lease_details_all
                                      WHERE lease_id = p_lease_id);

BEGIN

   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT of MAIN Lease +Start+ (+)');
   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT IN: p_lease_id         : '||p_lease_id);
   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT IN: p_lease_context    : '||p_lease_context);
   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT IN: p_new_lea_term_dt  : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT IN: p_new_lea_comm_dt  : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT IN: p_mths             : '||p_mths);

   /* If lease is contracted from main lease form then delete payment
      items for the lease, for which payment schedules are in draft
      status and schedule date is greater than lease termination date. */

   OPEN get_old_lea_term_dt;
      FETCH get_old_lea_term_dt INTO l_old_lea_term_dt;
   CLOSE get_old_lea_term_dt;

   l_item_end_dt_tbl := pnp_util_func.fetch_item_end_dates(p_lease_id);

   /* Call the index rent contraction routine */

   FOR i IN 1 .. l_item_end_dt_tbl.COUNT LOOP
      IF l_item_end_dt_tbl(i).index_period_id IS NOT NULL THEN
         pnp_debug_pkg.log('+++++++++++++For RI term:'||l_item_end_dt_tbl(i).term_id||' Item End Dt:'||l_item_end_dt_tbl(i).item_end_dt);
         IF l_ri_end_dt < l_item_end_dt_tbl(i).item_end_dt THEN
            l_ri_end_dt := l_item_end_dt_tbl(i).item_end_dt;
         pnp_debug_pkg.log('+++++++++++++Now l_ri_end_dt:'||l_ri_end_dt);
         END IF;
      END IF;
   END LOOP;

   IF  l_ri_end_dt < p_new_lea_term_dt THEN
      l_ri_end_dt := p_new_lea_term_dt;
   END IF;
   pnp_debug_pkg.log('+++++++++++++Now l_ri_end_dt:'||l_ri_end_dt);
   IF(NVL(fnd_profile.value('PN_RENT_INCREASE_TERM_END_DATE'),'END_LEASE') ='END_LEASE') THEN
      FOR i IN 1 .. l_item_end_dt_tbl.COUNT LOOP
         IF l_item_end_dt_tbl(i).index_period_id IS NOT NULL THEN
            IF nvl(l_item_end_dt_tbl(i).item_end_dt,l_max_item_end_dt) < p_new_lea_term_dt THEN
               l_item_end_dt_tbl(i).item_end_dt := p_new_lea_term_dt;
            END IF;
         END IF;
      END LOOP;
      l_term_end_dt := p_new_lea_term_dt;
   ELSE
      FOR i IN 1 .. l_item_end_dt_tbl.COUNT LOOP
         IF l_item_end_dt_tbl(i).index_period_id IS NOT NULL THEN
            l_item_end_dt_tbl(i).item_end_dt := l_ri_end_dt;
         END IF;
      END LOOP;
      l_term_end_dt := NULL;
   END IF;
   pn_index_rent_periods_pkg.process_main_lease_term_date( p_lease_id                   => p_lease_id
                                                          ,p_new_main_lease_term_date   => l_ri_end_dt
                                                          ,p_old_main_lease_term_date   => l_old_lea_term_dt
                                                          ,p_lease_context              => p_lease_context
                                                          ,p_msg                        => l_msg
                                                          ,p_cutoff_date                => NULL
                                                          ,p_term_end_dt                => l_term_end_dt);

   l_norm_trm_exsts := pnp_util_func.norm_trm_exsts(p_lease_id);
   IF l_norm_trm_exsts THEN
      FOR i IN 1 .. l_item_end_dt_tbl.COUNT LOOP
         IF l_item_end_dt_tbl(i).index_period_id IS NULL THEN
	    l_item_end_dt_tbl(i).item_end_dt := p_new_lea_term_dt;
         END IF;
      END LOOP;
   ELSE
      FOR i IN 1 .. l_item_end_dt_tbl.COUNT LOOP
         IF l_item_end_dt_tbl(i).index_period_id IS NULL THEN

            pnp_debug_pkg.log('+++++++++++++Non-RI Term:'||
                              '  Term ID:' || l_item_end_dt_tbl(i).term_id ||
                              '  Item End Dt:' || l_item_end_dt_tbl(i).item_end_dt ||
                              '  Lease End Dt:' ||p_new_lea_term_dt);
            IF nvl(l_item_end_dt_tbl(i).item_end_dt,l_max_item_end_dt) < p_new_lea_term_dt
	    THEN
               l_item_end_dt_tbl(i).item_end_dt := p_new_lea_term_dt;
            END IF;
         END IF;
      END LOOP;
   END IF;
   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Deleting Items');
   FOR i IN 1 .. l_item_end_dt_tbl.COUNT LOOP
   pnp_debug_pkg.log('+++++++++++Deleting All Items for term:'||l_item_end_dt_tbl(i).term_id||
                     '  with schedule_date > ' ||l_item_end_dt_tbl(i).item_end_dt);
      DELETE pn_payment_items_all
      WHERE payment_schedule_id IN (SELECT payment_schedule_id
                                    FROM   pn_payment_schedules_all
                                    WHERE  lease_id = p_lease_id
                                    AND    schedule_date > l_item_end_dt_tbl(i).item_end_dt
                                    AND    payment_status_lookup_code = 'DRAFT')
      AND payment_term_id = l_item_end_dt_tbl(i).term_id;
   END LOOP;

   /* Delete payment schedules for the lease which are in draft status
      and schedule date is greater than lease termination date. */

   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Deleting Payment Schedules');
   pnp_debug_pkg.log('+++++++++++Deleting Draft Empty Schedules for lease:'||p_lease_id||
                     '  with schedule_date > '||p_new_lea_term_dt);
   DELETE pn_payment_schedules_all psch
   WHERE lease_id = p_lease_id
   AND schedule_date > p_new_lea_term_dt
   AND payment_status_lookup_code = 'DRAFT'
   AND NOT EXISTS (SELECT 1
                   FROM pn_payment_items_all pitm
                   WHERE pitm.payment_schedule_id = psch.payment_schedule_id);

   /* Delete payment terms for the lease which have term start date
      greater than lease termination date. */

   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Deleting Payment Terms');

   DELETE pn_payment_terms_all term
   WHERE lease_id = p_lease_id
   AND start_date > p_new_lea_term_dt
   AND index_period_id IS NULL
   AND NOT EXISTS(SELECT 1
                  FROM pn_payment_items_all item,
                       pn_payment_schedules_all schd
                  WHERE item.payment_term_id = term.payment_term_id
                  AND item.payment_schedule_id = schd.payment_schedule_id
                  AND schd.payment_status_lookup_code = 'APPROVED');

   /* Update end date of remaining payment terms for the lease to
      lease termination date. */

   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Updating end date of Payment Terms');

   FOR i IN 1 .. l_item_end_dt_tbl.COUNT LOOP
      UPDATE pn_payment_terms_all
      SET end_date = l_item_end_dt_tbl(i).item_end_dt,
          last_update_date = SYSDATE,
          last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
          last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
      WHERE payment_term_id = l_item_end_dt_tbl(i).term_id
      AND end_date > l_item_end_dt_tbl(i).item_end_dt
      AND frequency_code <> 'OT';
   END LOOP;

   /* Update the cash items with new amount, for the terms which have
      been contracted. */

   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Updating last non zero cash items with new pro. amt');

   recalculate_cash(p_new_lease_term_date => p_new_lea_term_dt);

   /*Get the normalized payment terms for which re-normalization needs
      to be done  */

   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Doing re-normalization');

   l_active_lease_change_id := Get_Lease_Change_Id(p_lease_id);
   FOR con_cur IN term_con_exp_cur(p_lease_id,l_active_lease_change_id)
   LOOP

      pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Re-Normalization - Term Id : '||con_cur.payment_term_id);

      /* If the lease is Contracted, Normalization of term should start from
         the same date of normalization, when the term was Abstracted or Added. */

      l_norm_str_dt := NVL(con_cur.norm_start_date, Get_First_Item_Date(con_cur.payment_term_id));

     FOR rec in get_drf_sch_date(con_cur.payment_term_id)
     LOOP
         -- Fix for bug#9214283
         l_sch_dt_1 := rec.schedule_date;
         pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Calling find_schedule lease_change_id : '|| con_cur.lease_change_id);
         pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Calling find_schedule payment_term_id : '|| con_cur.payment_term_id);
         pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Calling l_sch_dt_1: '|| l_sch_dt_1);
         pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Calling l_payment_schedule_id : '|| l_payment_schedule_id);
         pn_retro_adjustment_pkg.find_schedule(p_lease_id
                                              ,con_cur.lease_change_id
                                              ,con_cur.payment_term_id
                                              ,l_sch_dt_1
                                              ,l_payment_schedule_id);
     END LOOP;

      /* AMT-RETRO */
     PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE
                           (p_lease_context      => p_lease_context,
                            p_lease_id           => p_lease_id,
                            p_term_id            => con_cur.payment_term_id,
                            p_vendor_id          => con_cur.vendor_id,
                            p_cust_id            => con_cur.customer_id,
                            p_vendor_site_id     => con_cur.vendor_site_id,
                            p_cust_site_use_id   => con_cur.customer_site_use_id,
                            p_cust_ship_site_id  => con_cur.cust_ship_site_id,
                            p_sob_id             => con_cur.set_of_books_id,
                            p_curr_code          => con_cur.currency_code,
                            p_sch_day            => con_cur.schedule_day,
                            p_norm_str_dt        => l_norm_str_dt,
                            p_norm_end_dt        => p_new_lea_term_dt,
                            p_rate               => con_cur.rate,
                            p_lease_change_id    => con_cur.lease_change_id);

      pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT - MAIN - Renormalization done for Term   : '
                         ||TO_CHAR(con_cur.payment_term_id));

      UPDATE pn_payment_terms_all
      SET    norm_end_date   = p_new_lea_term_dt
      WHERE  payment_term_id = con_cur.payment_term_id;

   END LOOP;

   /* Now create the schedules and items for the new terms that have been added along with
      the contraction of the main lease */

   add_main(p_lease_id            => p_lease_id,
            p_lease_context       => 'ADDAMD',
            p_new_lea_term_dt     => p_new_lea_term_dt,
            p_new_lea_comm_dt     => p_new_lea_comm_dt,
            p_mths                => p_mths);

   /* For Sub_Lease and Third_Party lease, contract tenancies and associated
       space assignments as well. */

   IF g_lease_class_code <> 'DIRECT' THEN
      contract_tenancies(
                                p_lease_id           => p_lease_id
                               ,p_new_lea_term_dt    => p_new_lea_term_dt
                                );
   END IF;

   pnp_debug_pkg.log('CONTRACTION_BY_ITM_END_DT of MAIN Lease -End- (-)');

END contraction_by_itm_end_dt;

--------------------------------------------------------------------------------------------
--  PROCEDURE  : EXPANSION
--  DESCRIPTION: This procedure is used to expand a given lease, all terms of the given lease
--               are expanded. GET_SCH_INFO gives information of the term, PROCESS_TERM
--               creates schedules if required and the Cash / Normalized items.
--  25-JUN-2001  Mrinal Misra    o Created.
--  05-AUG-2001  Amita Singh     o Modified to take care of EXP+ADD. Added call to ADD_MAIN.
--  15-AUG-2001  Mrinal Misra    o Added calls to routine
--                                 pn_index_rent_periods_pkg.process_main_lease_term_date.
--  25-SEP-2001  Mrinal Misra    o Changed for expanding Index Payment Terms.
--  24-JAN-2002  Satish Tripathi o Removed the hard coding of p_lease_context being passed to
--                                 GET_SCH_INFO and PROCESS_TERM.
--  07-FEB-2002  Satish Tripathi o Added variable l_norm_str_dt to capture Normalize Start
--                                 Date, if term was added through AMEND.
--  26-MAR-2002  Satish Tripathi o Added variable l_sch_str_dt to correctly point the
--                                 Schedule-Start-Date for NON MONTHLY Payment Term.
--  10-DEC-2002  graghuna        o Modified to get and pass p_active_lease_change_id to
--                                 cursor and update pn_payment_terms_all.norm_end_date
--                                 for Month-to-Month Re-Normalization issue. --MTM-I
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Pass new parameter p_lease_change_id
--                                 to process_term.
--  24-MAR-2004  Satish Tripathi o Fixed for BUG# 3295405. If norm_start_date is null
--                                 (old data), use Get_First_Item_Date.
--  19-jan-2006  piagrawa        o Bug#4931780 - Modified signature
--  20-NOV-2006  Hareesha        o MTM Uptake - Added parameter p_extend_ri to extend
--                                 RI agreement when lease moves from MTM/HLD to ACT.
--  02-APR-2007  Hareesha        o Bug # 5962831 Added parameter for terms expansion.
--------------------------------------------------------------------------------------------
PROCEDURE expansion (p_lease_id           NUMBER,
                     p_lease_context      VARCHAR2,
                     p_new_lea_term_dt    DATE,
                     p_new_lea_comm_dt    DATE,
                     p_mths               NUMBER,
                     p_term_id            NUMBER DEFAULT NULL,
                     p_cutoff_date        DATE,
                     p_extend_ri          VARCHAR2,
                     p_ten_trm_context    VARCHAR2 DEFAULT 'N')
IS

   l_old_lea_term_dt               pn_lease_details.lease_termination_date%TYPE;
   l_pro_sch_dt                    pn_payment_schedules.schedule_date%TYPE;
   l_no_sch                        NUMBER;
   l_freq                          NUMBER;
   l_counter                       NUMBER;
   l_sch_dt                        pn_payment_schedules.schedule_date%TYPE;
   l_msg                           VARCHAR2(2000);
   l_norm_str_dt                   DATE := NULL;
   l_sch_str_dt                    DATE;
   l_active_lease_change_id        pn_lease_details.lease_change_id%TYPE;
   l_cutoff_date                   DATE;
   l_ext_dt                        DATE;
   l_old_lease_end_date            DATE;
   l_payment_term_rec              pn_payment_terms_all%ROWTYPE;
   x_return_status                 VARCHAR2(100);
   x_return_message                VARCHAR2(100);
   l_lease_change_id               NUMBER;
   l_lease_status_old              VARCHAR2(30);
   l_lease_status_new              VARCHAR2(30);
   l_lease_comm_date               DATE;
   l_lease_term_date               DATE;
   l_lease_ext_end_date            DATE;
   l_amd_comm_date                 DATE;
   l_schd_date1                    DATE;
   l_schd_day                      NUMBER := NULL;
   l_first_draft_sch               DATE; -- Bug 7184211

   CURSOR get_old_lea_term_dt IS
      SELECT plh.lease_termination_date
      FROM   pn_lease_details_history plh,
             pn_lease_details_all pld
      WHERE  pld.lease_change_id = plh.new_lease_change_id
      AND    pld.lease_id = p_lease_id;

   CURSOR get_ext_dt IS
      SELECT NVL(plh.lease_extension_end_date,
                 plh.lease_termination_date) old_term_dt
      FROM   pn_lease_details_history plh,
             pn_lease_details_all pld
      WHERE  pld.lease_change_id = plh.new_lease_change_id
      AND    pld.lease_id = p_lease_id;


   CURSOR get_old_lease_end_date IS
      SELECT GREATEST( NVL(plh.lease_extension_end_date,
                           plh.lease_termination_date),
                       plh.lease_termination_date) old_lease_end_date
      FROM pn_lease_details_history plh,
           pn_lease_details_all pld
      WHERE pld.lease_change_id = plh.new_lease_change_id
      AND   pld.lease_id = p_lease_id;

   CURSOR get_main_lease_terms_to_expand( p_old_lease_end_date DATE) IS
      SELECT *
      FROM pn_payment_terms_all
      WHERE lease_id = p_lease_id
      AND end_date = p_old_lease_end_date
      AND index_period_id IS NULL
      AND var_rent_inv_id IS NULL
      AND period_billrec_id IS NULL
      AND frequency_code <>'OT';

   CURSOR get_lease_details IS
      SELECT details.lease_change_id              lease_change_id,
             det_history.lease_status             lease_status_old,
             lease.lease_status                   lease_status_new,
             details.lease_commencement_date      lease_comm_date,
             details.lease_termination_date       lease_term_date,
             det_history.lease_extension_end_date lease_ext_end_date,
             changes.change_commencement_date     amd_comm_date
      FROM pn_lease_details_all details,
           pn_lease_details_history det_history,
           pn_lease_changes_all changes,
           pn_leases_all        lease
      WHERE details.lease_id = p_lease_id
      AND   det_history.lease_id = p_lease_id
      AND   changes.lease_id = p_lease_id
      AND   lease.lease_id = p_lease_id
      AND   details.lease_change_id = det_history.new_lease_change_id
      AND   changes.lease_change_id = details.lease_change_id;

   CURSOR get_last_appr_schd_dt (p_lease_id NUMBER) IS
      SELECT MAX(pps.schedule_date) lst_schedule_date
      FROM pn_payment_schedules_all pps
      WHERE pps.payment_status_lookup_code = 'APPROVED'
      AND pps.lease_id = p_lease_id;

-- Bug 7184211
   CURSOR csr_first_draft_sch (p_lease_id   NUMBER,
                               p_start_date DATE)
   IS

      SELECT First_Day(MIN(pps.schedule_date))
      FROM   pn_payment_schedules_all pps
      WHERE  pps.lease_id = p_lease_id
      AND    First_Day(pps.schedule_date) >= First_Day(p_start_date)
      AND    TO_CHAR(pps.schedule_date,'DD') = l_schd_day
      AND    pps.payment_status_lookup_code = 'DRAFT';

BEGIN

   pnp_debug_pkg.log('EXPANSION +Start+ (+)');
   pnp_debug_pkg.log('EXPANSION IN: p_lease_id           : '||p_lease_id);
   pnp_debug_pkg.log('EXPANSION IN: p_lease_context      : '||p_lease_context);
   pnp_debug_pkg.log('EXPANSION IN: p_new_lea_term_dt    : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('EXPANSION IN: p_new_lea_comm_dt    : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('EXPANSION IN: p_mths               : '||p_mths);
   pnp_debug_pkg.log('EXPANSION IN: p_term_id            : '||p_term_id);
   /* Find out NOCOPY the old lease termination date. */

FOR i in 1..28 LOOP
    norm_st_dt_rec_tbl(i) := NULL;
END LOOP;

   OPEN get_old_lea_term_dt;
      FETCH get_old_lea_term_dt INTO l_old_lea_term_dt;
   CLOSE get_old_lea_term_dt;

   FOR trm_dt_cur IN get_ext_dt LOOP
      l_ext_dt := trm_dt_cur.old_term_dt;
   END LOOP;


   /* Call the index rent expansion routine */

   pnp_debug_pkg.log('EXP - MAIN - Expanding Index rent ');

   pn_index_rent_periods_pkg.process_main_lease_term_date (p_lease_id,
                                                           p_new_lea_term_dt,
                                                           l_ext_dt,
                                                           p_lease_context,
                                                           l_msg,
                                                           p_cutoff_date);

   pnp_debug_pkg.log('EXPANSION - l_old_lea_term_dt          : '||l_old_lea_term_dt);
   l_active_lease_change_id := Get_Lease_Change_Id(p_lease_id);
   pnp_debug_pkg.log(' lease change id = '|| l_active_lease_change_id);

   l_cutoff_date := to_date(to_char(p_cutoff_date, 'yyyy-mm-dd') , 'yyyy-mm-dd');
   pnp_debug_pkg.log(' l_cutoff_date '|| l_cutoff_date);

   FOR con_cur IN term_exp_cur(p_lease_id,l_active_lease_change_id, p_cutoff_date)
   LOOP
      pnp_debug_pkg.log('EXPANSION - getting sch info for  term : '
                        ||TO_CHAR(con_cur.payment_term_id));

      /* If the lease is Expanded, Normalization of term should start from
         the same date of normalization, when the term was Abstracted or Added. */

      l_norm_str_dt := NVL(con_cur.norm_start_date, Get_First_Item_Date(con_cur.payment_term_id));

      get_sch_info(p_lease_context            => p_lease_context,
                   p_normalize_flag           => NVL(con_cur.normalize,'N'),
                   p_mths                     => p_mths,
                   p_term_start_dt            => con_cur.start_date,
                   p_term_end_dt              => con_cur.end_date,
                   p_freq_code                => con_cur.frequency_code,
                   p_sch_day                  => con_cur.schedule_day,
                   p_new_lea_comm_dt          => p_new_lea_comm_dt,
                   p_old_lea_term_dt          => l_old_lea_term_dt,
                   p_new_lea_term_dt          => p_new_lea_term_dt,
                   p_no_sch                   => l_no_sch,
                   p_freq                     => l_freq,
                   p_counter                  => l_counter,
                   p_sch_dt                   => l_sch_dt,
                   p_pro_sch_dt               => l_pro_sch_dt,
                   p_sch_str_dt               => l_sch_str_dt,
                   p_lease_id                 => p_lease_id,
                   p_term_id                  => con_cur.payment_term_id,
                   p_norm_str_dt              => l_norm_str_dt);

      pnp_debug_pkg.log('EXPANSION - p_no_sch    : '||TO_CHAR(l_no_sch));
      pnp_debug_pkg.log('EXPANSION - p_freq      : '||TO_CHAR(l_freq));
      pnp_debug_pkg.log('EXPANSION - p_counter   : '||TO_CHAR(l_counter));
      pnp_debug_pkg.log('EXPANSION - p_sch_dt    : '||TO_CHAR(l_sch_dt));
      pnp_debug_pkg.log('EXPANSION - p_pro_sch_dt: '||TO_CHAR(l_pro_sch_dt));

      process_term(p_no_sch                   => l_no_sch,
                   p_counter                  => l_counter,
                   p_sch_dt                   => l_sch_dt,
                   p_pro_sch_dt               => l_pro_sch_dt,
                   p_new_lea_term_dt          => p_new_lea_term_dt ,
                   p_freq                     => l_freq,
                   p_freq_code                => con_cur.frequency_code,
                   p_payment_term_id          => con_cur.payment_term_id,
                   p_pay_trm_typ_code         => con_cur.payment_term_type_code,
                   p_trgt_dt                  => con_cur.target_date,
                   p_normalize_flag           => NVL(con_cur.normalize,'N'),
                   p_lease_context            => p_lease_context,
                   p_mths                     => p_mths,
                   p_vendor_id                => con_cur.vendor_id,
                   p_customer_id              => con_cur.customer_id,
                   p_vendor_site_id           => con_cur.vendor_site_id,
                   p_customer_site_use_id     => con_cur.customer_site_use_id,
                   p_cust_ship_site_id        => con_cur.cust_ship_site_id,
                   p_set_of_books_id          => con_cur.set_of_books_id,
                   p_currency_code            => con_cur.currency_code,
                   p_rate                     => con_cur.rate,
                   p_term_start_date          => con_cur.start_date,
                   p_term_end_date            => con_cur.end_date,
                   p_sch_str_dt               => l_sch_str_dt,
                   p_act_amt                  => con_cur.actual_amount,
                   p_est_amt                  => con_cur.estimated_amount,
                   p_index_prd_id             => con_cur.index_period_id,
                   p_norm_str_dt              => l_norm_str_dt,
                   p_lease_change_id          => con_cur.lease_change_id);

         UPDATE pn_payment_terms_all
         SET    norm_end_date   = g_new_lea_term_dt
         WHERE  payment_term_id = con_cur.payment_term_id;

      pnp_debug_pkg.log('EXPANSION - processed term '||TO_CHAR(con_cur.payment_term_id));

   END LOOP;

   IF NVL(p_ten_trm_context,'N') = 'Y' THEN

      FOR rec IN get_old_lease_end_date LOOP
         l_old_lease_end_date := rec.old_lease_end_date;
      END LOOP;

      FOR rec IN get_lease_details LOOP
         l_lease_change_id   := rec.lease_change_id;
         l_lease_status_old  := rec.lease_status_old;
         l_lease_status_new  := rec.lease_status_new;
         l_lease_comm_date   := rec.lease_comm_date;
         l_lease_term_date   := rec.lease_term_date;
         l_lease_ext_end_date :=rec.lease_ext_end_date;
         l_amd_comm_date     := rec.amd_comm_date;
      END LOOP;

      IF l_lease_status_new = 'ACT' AND ( l_lease_status_old = 'MTM' OR l_lease_status_old ='HLD')
      AND l_lease_term_date > l_lease_ext_end_date THEN

         FOR base_terms_to_extend_rec IN get_main_lease_terms_to_expand(l_old_lease_end_date) LOOP

            l_payment_term_rec := base_terms_to_extend_rec;

            l_schd_date1 := pn_schedules_items.get_schedule_date
                           ( p_lease_id   => p_lease_id,
                             p_day        => l_payment_term_rec.schedule_day,
                             p_start_date => l_lease_ext_end_date + 1,
                             p_end_date   => l_lease_term_date,
                             p_freq       => pn_schedules_items.get_frequency(l_payment_term_rec.frequency_code)
                           );
            l_schd_day  := TO_NUMBER(TO_CHAR(l_schd_date1,'DD'));

            IF  NVL(l_payment_term_rec.index_norm_flag,'N') = 'Y' AND l_payment_term_rec.parent_term_id IS NOT NULL
            THEN

               FOR lst_appr_sched IN get_last_appr_schd_dt ( p_lease_id) LOOP
                  l_payment_term_rec.norm_start_date := lst_appr_sched.lst_schedule_date;
               END LOOP;

               IF l_amd_comm_date > l_payment_term_rec.start_date THEN
                  l_payment_term_rec.norm_start_date := l_amd_comm_date;
               END IF;

               l_payment_term_rec.normalize  := 'Y';
               l_payment_term_rec.start_date := l_lease_ext_end_date + 1;
               l_payment_term_rec.end_date   := l_lease_term_date;
               l_payment_term_rec.norm_end_date   := l_lease_term_date;
               l_payment_term_rec.parent_term_id := NVL(l_payment_term_rec.parent_term_id,
                                                        l_payment_term_rec.payment_term_id);
               l_payment_term_rec.lease_status := l_lease_status_new;
               l_payment_term_rec.index_norm_flag := NULL;
               l_payment_term_rec.lease_change_id := l_lease_change_id;
               l_payment_term_rec.status := 'DRAFT';

               pn_schedules_items.Insert_Payment_Term
              (  p_payment_term_rec              => l_payment_term_rec,
                 x_return_status                 => x_return_status,
                 x_return_message                => x_return_message   );

            ELSE

               IF l_schd_day <> l_payment_term_rec.schedule_day THEN
                  l_payment_term_rec.start_date   := l_lease_ext_end_date + 1;
                  l_payment_term_rec.end_date     := l_lease_term_date;
                  l_payment_term_rec.lease_change_id := l_lease_change_id;
                  l_payment_term_rec.status := 'DRAFT';

                   pn_schedules_items.Insert_Payment_Term
                   (  p_payment_term_rec              => l_payment_term_rec,
                      x_return_status                 => x_return_status,
                      x_return_message                => x_return_message   );

               ELSE

                  UPDATE pn_payment_terms_all
                  SET end_date          = l_lease_term_date,
                      lease_change_id   = l_lease_change_id,
                      last_update_date  = SYSDATE,
                      last_updated_by   = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
                  WHERE payment_term_id = l_payment_term_rec.payment_term_id;

                  Extend_Payment_Term (
                                 p_payment_term_rec => l_payment_term_rec,
                                 p_new_lea_comm_dt   => p_new_lea_comm_dt,
                                 p_new_lea_term_dt   => g_new_lea_term_dt,
                                 p_mths              => p_mths,
                                 p_new_start_date    => l_payment_term_rec.end_date + 1,
                                 p_new_end_date      => g_new_lea_term_dt,
                                 x_return_status     => x_return_status,
                                 x_return_message    => x_return_message);
               END IF;
            END IF;
         END LOOP;

      ELSE

         FOR base_terms_to_extend_rec IN get_main_lease_terms_to_expand(l_old_lease_end_date) LOOP

            l_payment_term_rec := base_terms_to_extend_rec;

            Extend_Payment_Term (p_payment_term_rec => l_payment_term_rec,
                                 p_new_lea_comm_dt   => p_new_lea_comm_dt,
                                 p_new_lea_term_dt   => g_new_lea_term_dt,
                                 p_mths              => p_mths,
                                 p_new_start_date    => l_payment_term_rec.end_date + 1,
                                 p_new_end_date      => g_new_lea_term_dt,
                                 x_return_status     => x_return_status,
                                 x_return_message    => x_return_message);

            UPDATE pn_payment_terms_all
            SET end_date = g_new_lea_term_dt
            WHERE payment_term_id = l_payment_term_rec.payment_term_id;
-- Added For Bug#7184211
            IF NVL(l_payment_term_rec.normalize,'N') = 'Y' THEN

              l_norm_str_dt := NVL(l_payment_term_rec.norm_start_date, Get_First_Item_Date(l_payment_term_rec.payment_term_id));
              l_schd_day := l_payment_term_rec.schedule_day;
              l_sch_dt := TO_DATE(TO_CHAR(l_payment_term_rec.schedule_day)||'/'
                                          ||TO_CHAR(ADD_MONTHS(l_old_lea_term_dt,1),'MM/YYYY'),
                                  'DD/MM/YYYY');

              IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
                OPEN csr_first_draft_sch(g_lease_id, l_norm_str_dt);
                   FETCH csr_first_draft_sch INTO l_first_draft_sch;
                CLOSE csr_first_draft_sch;

                IF l_first_draft_sch is NULL THEN
                   l_norm_str_dt := FIRST_DAY(l_sch_dt);
                ELSE
                   l_norm_str_dt := GREATEST(l_norm_str_dt, l_first_draft_sch);
                END IF;
              END IF;

              /* AMT-RETRO */
              IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
                create_normalize_items(p_lease_context      => p_lease_context,
                                       p_lease_id           => g_lease_id,
                                       p_term_id            => l_payment_term_rec.payment_term_id,
                                       p_vendor_id          => l_payment_term_rec.vendor_id,
                                       p_cust_id            => l_payment_term_rec.customer_id,
                                       p_vendor_site_id     => l_payment_term_rec.vendor_site_id,
                                       p_cust_site_use_id   => l_payment_term_rec.customer_site_use_id,
                                       p_cust_ship_site_id  => l_payment_term_rec.cust_ship_site_id,
                                       p_sob_id             => l_payment_term_rec.set_of_books_id,
                                       p_curr_code          => l_payment_term_rec.currency_code,
                                       p_sch_day            => l_payment_term_rec.schedule_day,
                                       p_norm_str_dt        => l_norm_str_dt,
                                       p_norm_end_dt        => g_new_lea_term_dt,
                                       p_rate               => l_payment_term_rec.rate,
                                       p_lease_change_id    => l_payment_term_rec.lease_change_id);
              ELSE
                PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE
                                       (p_lease_context      => p_lease_context,
                                        p_lease_id           => g_lease_id,
                                        p_term_id            => l_payment_term_rec.payment_term_id,
                                        p_vendor_id          => l_payment_term_rec.vendor_id,
                                        p_cust_id            => l_payment_term_rec.customer_id,
                                        p_vendor_site_id     => l_payment_term_rec.vendor_site_id,
                                        p_cust_site_use_id   => l_payment_term_rec.customer_site_use_id,
                                        p_cust_ship_site_id  => l_payment_term_rec.cust_ship_site_id,
                                        p_sob_id             => l_payment_term_rec.set_of_books_id,
                                        p_curr_code          => l_payment_term_rec.currency_code,
                                        p_sch_day            => l_payment_term_rec.schedule_day,
                                        p_norm_str_dt        => l_norm_str_dt,
                                        p_norm_end_dt        => g_new_lea_term_dt,
                                        p_rate               => l_payment_term_rec.rate,
                                        p_lease_change_id    => l_payment_term_rec.lease_change_id);
              END IF;

            END IF;
-- End Bug#7184211

         END LOOP;

      END IF;
   END IF;

   /* Now create the schedules and items for the new terms that have been added along with
      the expansion of the main lease */

   pnp_debug_pkg.log('EXPANSION - adding terms - ... ');
   pnp_debug_pkg.log('EXPANSION - p_new_lea_term_dt: '||p_new_lea_term_dt);
   pnp_debug_pkg.log('EXPANSION - p_new_lea_comm_dt: '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('EXPANSION - p_mths           : '||TO_CHAR(p_mths));

   add_main(p_lease_id            => p_lease_id,
            p_lease_context       => 'ADDAMD',
            p_new_lea_term_dt     => p_new_lea_term_dt,
            p_new_lea_comm_dt     => p_new_lea_comm_dt,
            p_mths                => p_mths);

   /* Extend the RI agreement and create/expand the periods
      if lease is extended and status changed from MTM/HLD to ACT */
   IF p_extend_ri = 'Y' THEN

     pn_index_rent_periods_pkg.process_main_lease_term_date(
         p_lease_id                     => p_lease_id,
         p_new_main_lease_term_date     => p_new_lea_term_dt,
         p_old_main_lease_term_date     => l_ext_dt,
         p_lease_context                => 'EXP_RI',
         p_msg                          => l_msg);
   END IF;
   pn_schedules_items.g_norm_dt_avl :=  NULL; /* 9231686 */
   pnp_debug_pkg.log('EXPANSION -End- (-)');

END expansion;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : ABSTRACT
--  DESCRIPTION: This procedure is used to add a payment term in a given lease when lease is
--               abstracted for the 1st time. GET_SCH_INFO gives information of the term,
--               PROCESS_TERM creates schedules if required and the Cash / Normalized items.
--  25-JUN-2001  Mrinal Misra    o Created.
--  24-JAN-2002  Satish Tripathi o Removed the hard coding of p_lease_context being passed to
--                                 GET_SCH_INFO and PROCESS_TERM.
--  07-FEB-2002  Satish Tripathi o Added variable l_norm_str_dt to capture Normalize Start
--                                 Date, if term was added through AMEND.
--  26-MAR-2002  Satish Tripathi o Added variable l_sch_str_dt to correctly point the
--                                 Schedule-Start-Date for NON MONTHLY Payment Term.
--  10-DEC-2002  graghuna        o Modified to update pn_payment_terms_all.norm_end_date
--                                 for Month-to-Month Re-Normalization issue. --MTM-I
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Pass new parameter p_lease_change_id
--                                 to process_term.
--  20-NOV-2006  Hareesha        o MTM Uptake - Added handling for creating schedules and items
--                                 LOF/SGN.
--------------------------------------------------------------------------------------------
PROCEDURE abstract (p_lease_id           NUMBER,
                    p_lease_context      VARCHAR2,
                    p_new_lea_term_dt    DATE,
                    p_new_lea_comm_dt    DATE,
                    p_mths               NUMBER)
IS

   l_pro_sch_dt                    pn_payment_schedules.schedule_date%TYPE;
   l_no_sch                        NUMBER;
   l_freq                          NUMBER;
   l_counter                       NUMBER;
   l_sch_dt                        pn_payment_schedules.schedule_date%TYPE;
   l_norm_str_dt                   DATE;
   l_sch_str_dt                    DATE;

   CURSOR get_lease_status(p_lease_id NUMBER) IS
      SELECT lease_status
      FROM pn_leases_all
      WHERE lease_id = p_lease_id;

  CURSOR get_lof_terms(p_lease_id NUMBER) IS
     SELECT ppt.payment_term_id,
             ppt.lease_change_id,
             ppt.schedule_day,
             ppt.start_date,
             ppt.end_date,
             ppt.target_date,
             ppt.frequency_code,
             ppt.normalize,
             ppt.actual_amount,
             ppt.estimated_amount,
             ppt.payment_term_type_code,
             ppt.vendor_id,
             ppt.vendor_site_id,
             ppt.customer_id,
             ppt.customer_site_use_id,
             ppt.cust_ship_site_id,
             ppt.set_of_books_id,
             ppt.currency_code,
             ppt.rate,
             ppt.norm_start_date
      FROM   pn_payment_terms_all ppt
      WHERE  lease_id = p_lease_id
      AND    ppt.index_period_id IS NULL
      AND    ppt.var_rent_inv_id IS NULL
      AND    ppt.period_billrec_id IS NULL
      AND    NOT EXISTS (SELECT NULL
                         FROM   pn_payment_items_all ppi
                         WHERE  ppt.lease_id = p_lease_id
                         AND    ppi.payment_term_id = ppt.payment_term_id)
      AND    frequency_code = 'OT'
      AND    NVL(normalize,'N') = 'N';

   l_lease_status VARCHAR2(30) ;

BEGIN

   pnp_debug_pkg.log('ABSTRACT +Start+ (+)');
   pnp_debug_pkg.log('ABSTRACT IN: p_lease_id        : '||p_lease_id);
   pnp_debug_pkg.log('ABSTRACT IN: p_lease_context   : '||p_lease_context);
   pnp_debug_pkg.log('ABSTRACT IN: p_new_lea_term_dt : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('ABSTRACT IN: p_new_lea_comm_dt : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('ABSTRACT IN: p_mths            : '||p_mths);

   IF p_lease_context IN ('LOF','SGN') THEN

      FOR rec IN get_lease_status(p_lease_id) LOOP
         l_lease_status := rec.lease_status;
      END LOOP;

      IF l_lease_status IN ('LOF','SGN') THEN
         FOR abs_cur IN get_lof_terms(p_lease_id) LOOP
            get_sch_info(p_lease_context            => 'ABS',
                         p_normalize_flag           => abs_cur.normalize,
                         p_mths                     => p_mths,
                         p_term_start_dt            => abs_cur.start_date,
                         p_term_end_dt              => abs_cur.end_date,
                         p_freq_code                => abs_cur.frequency_code,
                         p_sch_day                  => abs_cur.schedule_day,
                         p_new_lea_comm_dt          => p_new_lea_comm_dt,
                         p_new_lea_term_dt          => p_new_lea_term_dt,
                         p_old_lea_term_dt          => NULL,
                         p_no_sch                   => l_no_sch,
                         p_freq                     => l_freq,
                         p_counter                  => l_counter,
                         p_sch_dt                   => l_sch_dt,
                         p_pro_sch_dt               => l_pro_sch_dt,
                         p_sch_str_dt               => l_sch_str_dt,
                         p_norm_str_dt              => l_norm_str_dt,
                         p_lease_id                 => p_lease_id,
                         p_term_id                  => abs_cur.payment_term_id);

            process_term(p_no_sch                   => l_no_sch,
                         p_counter                  => l_counter,
                         p_sch_dt                   => l_sch_dt,
                         p_pro_sch_dt               => l_pro_sch_dt,
                         p_new_lea_term_dt          => p_new_lea_term_dt ,
                         p_freq                     => l_freq,
                         p_freq_code                => abs_cur.frequency_code,
                         p_payment_term_id          => abs_cur.payment_term_id,
                         p_pay_trm_typ_code         => abs_cur.payment_term_type_code,
                         p_trgt_dt                  => abs_cur.target_date,
                         p_normalize_flag           => abs_cur.normalize,
                         p_lease_context            => 'ABS',
                         p_mths                     => p_mths,
                         p_vendor_id                => abs_cur.vendor_id,
                         p_customer_id              => abs_cur.customer_id,
                         p_vendor_site_id           => abs_cur.vendor_site_id,
                         p_customer_site_use_id     => abs_cur.customer_site_use_id,
                         p_cust_ship_site_id        => abs_cur.cust_ship_site_id,
                         p_set_of_books_id          => abs_cur.set_of_books_id,
                         p_currency_code            => abs_cur.currency_code,
                         p_rate                     => abs_cur.rate,
                         p_term_start_date          => abs_cur.start_date,
                         p_term_end_date            => abs_cur.end_date,
                         p_sch_str_dt               => l_sch_str_dt,
                         p_act_amt                  => abs_cur.actual_amount,
                         p_est_amt                  => abs_cur.estimated_amount,
                         p_index_prd_id             => NULL,
                         p_norm_str_dt              => l_norm_str_dt,
                         p_lease_change_id          => abs_cur.lease_change_id);

         END LOOP;
      END IF;

   ELSE

   FOR abs_cur IN term_abs_cur(p_lease_id)
   LOOP
      get_sch_info(p_lease_context            => p_lease_context,
                   p_normalize_flag           => abs_cur.normalize,
                   p_mths                     => p_mths,
                   p_term_start_dt            => abs_cur.start_date,
                   p_term_end_dt              => abs_cur.end_date,
                   p_freq_code                => abs_cur.frequency_code,
                   p_sch_day                  => abs_cur.schedule_day,
                   p_new_lea_comm_dt          => p_new_lea_comm_dt,
                   p_new_lea_term_dt          => p_new_lea_term_dt,
                   p_old_lea_term_dt          => NULL,
                   p_no_sch                   => l_no_sch,
                   p_freq                     => l_freq,
                   p_counter                  => l_counter,
                   p_sch_dt                   => l_sch_dt,
                   p_pro_sch_dt               => l_pro_sch_dt,
                   p_sch_str_dt               => l_sch_str_dt,
                   p_norm_str_dt              => l_norm_str_dt,
                   p_lease_id                 => p_lease_id,
                   p_term_id                  => abs_cur.payment_term_id);

      process_term(p_no_sch                   => l_no_sch,
                   p_counter                  => l_counter,
                   p_sch_dt                   => l_sch_dt,
                   p_pro_sch_dt               => l_pro_sch_dt,
                   p_new_lea_term_dt          => p_new_lea_term_dt ,
                   p_freq                     => l_freq,
                   p_freq_code                => abs_cur.frequency_code,
                   p_payment_term_id          => abs_cur.payment_term_id,
                   p_pay_trm_typ_code         => abs_cur.payment_term_type_code,
                   p_trgt_dt                  => abs_cur.target_date,
                   p_normalize_flag           => abs_cur.normalize,
                   p_lease_context            => p_lease_context,
                   p_mths                     => p_mths,
                   p_vendor_id                => abs_cur.vendor_id,
                   p_customer_id              => abs_cur.customer_id,
                   p_vendor_site_id           => abs_cur.vendor_site_id,
                   p_customer_site_use_id     => abs_cur.customer_site_use_id,
                   p_cust_ship_site_id        => abs_cur.cust_ship_site_id,
                   p_set_of_books_id          => abs_cur.set_of_books_id,
                   p_currency_code            => abs_cur.currency_code,
                   p_rate                     => abs_cur.rate,
                   p_term_start_date          => abs_cur.start_date,
                   p_term_end_date            => abs_cur.end_date,
                   p_sch_str_dt               => l_sch_str_dt,
                   p_act_amt                  => abs_cur.actual_amount,
                   p_est_amt                  => abs_cur.estimated_amount,
                   p_index_prd_id             => NULL,
                   p_norm_str_dt              => l_norm_str_dt,
                   p_lease_change_id          => abs_cur.lease_change_id);

      IF abs_cur.normalize = 'Y' THEN
         UPDATE pn_payment_terms_all
         SET    norm_start_date = NVL(l_norm_str_dt, p_new_lea_comm_dt),
                norm_end_date   = g_new_lea_term_dt
         WHERE  payment_term_id = abs_cur.payment_term_id;
      END IF;

   END LOOP;
   END IF;
   pnp_debug_pkg.log('ABSTRACT -End- (-)');

END abstract;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : ADD_IND_VAR
--  DESCRIPTION: This procedure is used to add a payment term in a given lease when lease is
--               added through INDEX RENT increase. GET_SCH_INFO gives information of the term,
--               PROCESS_TERM creates schedules if required and the Cash / Normalized items.
--  25-JUN-2001  Mrinal Misra    o Created.
--  24-JAN-2002  Satish Tripathi o Removed the hard coding of p_lease_context being passed to
--                                 GET_SCH_INFO and PROCESS_TERM.
--  07-FEB-2002  Satish Tripathi o Added variable l_norm_str_dt to capture Normalize Start
--                                 Date, if term was added through AMEND.
--  26-MAR-2002  Satish Tripathi o Added variable l_sch_str_dt to correctly point the
--                                 Schedule-Start-Date for NON MONTHLY Payment Term.
--  11-Jul-2002   Ashish Kumar      Fix for BUG#2445840 edit the  Procedure :add_ind_var
--                                  Add  the parameter in the call to procedure : get_sch_info
--                                  p_new_lea_term_dt          => p_new_lea_term_dt,
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Pass new parameter p_lease_change_id
--                                 to process_term.
--  17-JAN-2006  piagrawa        o Bug#4931780 - modified to update norm end date.
--  18-APR-2006  Hareesha        o Bug #5115291 - In case of RI term having the
--                                 norm_Start_date, pass norm_start_date to
--                                 get_sch_info
-------------------------------------------------------------------------------------------
PROCEDURE add_ind_var (p_lease_id           NUMBER,
                       p_lease_context      VARCHAR2,
                       p_term_id            NUMBER,
                       p_new_lea_term_dt    DATE,
                       p_new_lea_comm_dt    DATE,
                       p_mths               NUMBER)
IS

   l_pro_sch_dt                    pn_payment_schedules.schedule_date%TYPE;
   l_no_sch                        NUMBER;
   l_freq                          NUMBER;
   l_counter                       NUMBER;
   l_sch_dt                        pn_payment_schedules.schedule_date%TYPE;
   l_norm_str_dt                   DATE;
   l_sch_str_dt                    DATE;

 BEGIN

   pnp_debug_pkg.log('ADD_IND_VAR +Start+ (+)');
   pnp_debug_pkg.log('ADD_IND_VAR IN: p_lease_id         : '||p_lease_id);
   pnp_debug_pkg.log('ADD_IND_VAR IN: p_lease_context    : '||p_lease_context);
   pnp_debug_pkg.log('ADD_IND_VAR IN: p_term_id          : '||p_term_id);
   pnp_debug_pkg.log('ADD_IND_VAR IN: p_new_lea_term_dt  : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('ADD_IND_VAR IN: p_new_lea_comm_dt  : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('ADD_IND_VAR IN: p_mths             : '||p_mths);
   FOR add_ind_var_cur IN term_add_ind_var_cur(p_lease_id, p_term_id)
   LOOP

      l_norm_str_dt := add_ind_var_cur.norm_start_date;

      get_sch_info(p_lease_context            => p_lease_context,
                   p_normalize_flag           => add_ind_var_cur.normalize,
                   p_mths                     => p_mths,
                   p_term_start_dt            => add_ind_var_cur.start_date,
                   p_term_end_dt              => add_ind_var_cur.end_date,
                   p_freq_code                => add_ind_var_cur.frequency_code,
                   p_sch_day                  => add_ind_var_cur.schedule_day,
                   p_new_lea_comm_dt          => NVL(l_norm_str_dt,p_new_lea_comm_dt),
                   p_new_lea_term_dt          => p_new_lea_term_dt,      -- Added for BUG#2445840
                   p_old_lea_term_dt          => NULL,
                   p_no_sch                   => l_no_sch,
                   p_freq                     => l_freq,
                   p_counter                  => l_counter,
                   p_sch_dt                   => l_sch_dt,
                   p_pro_sch_dt               => l_pro_sch_dt,
                   p_sch_str_dt               => l_sch_str_dt,
                   p_norm_str_dt              => l_norm_str_dt,
                   p_lease_id                 => p_lease_id,
                   p_term_id                  => add_ind_var_cur.payment_term_id);

      process_term(p_no_sch                   => l_no_sch,
                   p_counter                  => l_counter,
                   p_sch_dt                   => l_sch_dt,
                   p_pro_sch_dt               => l_pro_sch_dt,
                   p_new_lea_term_dt          => p_new_lea_term_dt ,
                   p_freq                     => l_freq,
                   p_freq_code                => add_ind_var_cur.frequency_code,
                   p_payment_term_id          => add_ind_var_cur.payment_term_id,
                   p_pay_trm_typ_code         => add_ind_var_cur.payment_term_type_code,
                   p_trgt_dt                  => add_ind_var_cur.target_date,
                   p_normalize_flag           => add_ind_var_cur.normalize,
                   p_lease_context            => p_lease_context,
                   p_mths                     => p_mths,
                   p_vendor_id                => add_ind_var_cur.vendor_id,
                   p_customer_id              => add_ind_var_cur.customer_id,
                   p_vendor_site_id           => add_ind_var_cur.vendor_site_id,
                   p_customer_site_use_id     => add_ind_var_cur.customer_site_use_id,
                   p_cust_ship_site_id        => add_ind_var_cur.cust_ship_site_id,
                   p_set_of_books_id          => add_ind_var_cur.set_of_books_id,
                   p_currency_code            => add_ind_var_cur.currency_code,
                   p_rate                     => add_ind_var_cur.rate,
                   p_term_start_date          => add_ind_var_cur.start_date,
                   p_term_end_date            => add_ind_var_cur.end_date,
                   p_sch_str_dt               => l_sch_str_dt,
                   p_act_amt                  => add_ind_var_cur.actual_amount,
                   p_est_amt                  => add_ind_var_cur.estimated_amount,
                   p_index_prd_id             => NULL,
                   p_norm_str_dt              => l_norm_str_dt,
                   p_lease_change_id          => add_ind_var_cur.lease_change_id);

      IF add_ind_var_cur.normalize = 'Y' THEN
         UPDATE pn_payment_terms_all
         SET    norm_start_date = l_norm_str_dt,
                norm_end_date   = g_new_lea_term_dt
         WHERE  payment_term_id = add_ind_var_cur.payment_term_id;
      END IF;

   END LOOP;
   pnp_debug_pkg.log('ADD_IND_VAR -End- (-)');

END add_ind_var;


--------------------------------------------------------------------------------
--  PROCEDURE  : CONTRACT_PAY_TERM
--  DESCRIPTION: This procedure is used to contract a given term. Extra
--               schedules and Cash Items of all terms are deleted and the cash
--               for last item is recalculeted.
--               For Normalized term, items are re-Normalized.
-- 01-FEB-02  Satish    o Created.
-- 07-FEB-02  Satish    o Added l_norm_str_dt to capture Normalize Start Date,
--                        if term was added through AMEND and pass it to
--                        routine CREATE_NORMALIZE_ITEMS.
-- 26-MAR-02  Satish    o Added condition to correctly point the l_sch_str_dt
--                        (Schedule-Start-Date) for NON MONTHLY Payment Term.
-- 31-MAY-02  Satish    o Modified cursor contract_pay_term, Bug# 2370889
-- 07-OCT-02  Satish    o Removed payment_status_lookup_code = 'DRAFT' from
--                        cursor. BUG # 2551423 - if term is contracted to last
--                        day of last appr schedule, cursor was returning null.
-- 10-DEC-02  graghuna  o Pass p_norm_end_date to create_normalize_items
--                        for Month-to-Month Re-Normalization issue.
-- 16-OCT-03  Satish    o BUG # 3201091. Pass new parameter p_lease_change_id
--                        to create_normalize_items.
-- 27-OCT-03  Satish    o BUG # 3178064. For ACT lease use lease termination
--                        date for norm_end_date else use Get_Norm_End_Date.
-- 14-DEC-03  Satish    o BUG # 3316671. Call add_main at end to create the
--                        Schedules and items of of new terms added alongwith.
-- 24-MAR-04  Satish    o BUG # 3295405. If norm_start_date is null (old data),
--                        use Get_First_Item_Date.
-- 07-MAY-04  Satish    o BUG # 3401162. Do not update cash item amount in any
--                        ciscumstances for OT term.
-- 13-MAR-05  Kiran     o Bug # 4146964. We do not look for non-zero CASH item
--                        when contracting anymore. Changed cursor
--                        lst_cash_sch_dt_cur. Update the actual amount in CASH
--                        item only if the last period is partial.
--------------------------------------------------------------------------------
PROCEDURE contract_pay_term (p_lease_id           NUMBER,
                             p_lease_context      VARCHAR2,
                             p_new_lea_term_dt    DATE,
                             p_new_lea_comm_dt    DATE,
                             p_mths               NUMBER)
IS

   l_frequency                     NUMBER;
   l_sch_str_dt                    DATE;
   l_sch_end_dt                    DATE;
   l_lst_cash_sch_dt               DATE;
   l_norm_str_dt                   DATE;
   l_lease_termination_date        DATE;

   -- Bug 7570052
   l_cal_yr_st        pn_leases_all.cal_start%TYPE;

   CURSOR lst_cash_sch_dt_cur (p_term_id     NUMBER,
                               p_term_end_dt DATE)
   IS
      SELECT MAX(pps.schedule_date)
      FROM   pn_payment_schedules_all pps,
             pn_payment_items_all ppi
      WHERE  pps.payment_schedule_id = ppi.payment_schedule_id
      AND    ppi.payment_term_id = p_term_id
      AND    ppi.actual_amount IS NOT NULL
      AND    ppi.payment_item_type_lookup_code = 'CASH'
      AND    First_Day(pps.schedule_date) <= First_Day(p_term_end_dt);

BEGIN

   pnp_debug_pkg.log('CONTRACT_PAY_TERM - Contraction of Payment Term - CONTERM +Start+ (+)');
   pnp_debug_pkg.log('CONTRACT_PAY_TERM IN: p_lease_id        : '||p_lease_id);
   pnp_debug_pkg.log('CONTRACT_PAY_TERM IN: p_lease_context   : '||p_lease_context);
   pnp_debug_pkg.log('CONTRACT_PAY_TERM IN: p_new_lea_term_dt : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('CONTRACT_PAY_TERM IN: p_new_lea_comm_dt : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('CONTRACT_PAY_TERM IN: p_mths            : '||p_mths);

   -- Bug 7570052
   SELECT cal_start
   INTO l_cal_yr_st
   FROM pn_leases_all
   WHERE lease_id = p_lease_id;

   IF g_lease_status = 'ACT' THEN
      l_lease_termination_date := g_new_lea_term_dt;
   ELSE
      l_lease_termination_date := Get_Norm_End_Date(p_lease_id);
   END IF;

   FOR pay_term_con_cur IN payment_term_con_cur (p_lease_id)
   LOOP

      pnp_debug_pkg.log('CONTRACT_PAY_TERM - Term ID          : '
                         ||TO_CHAR(pay_term_con_cur.payment_term_id)
                         ||' , Term End Date: '||pay_term_con_cur.end_date);

      IF pay_term_con_cur.frequency_code = 'OT' THEN
         pnp_debug_pkg.log('CONTRACT_PAY_TERM - Cash Amount Updation not required for OT Term.');

      ELSE
         OPEN lst_cash_sch_dt_cur(pay_term_con_cur.payment_term_id, pay_term_con_cur.end_date);
            FETCH lst_cash_sch_dt_cur INTO l_lst_cash_sch_dt;
         CLOSE lst_cash_sch_dt_cur;

         pnp_debug_pkg.log('CONTRACT_PAY_TERM - Term Freq: '||pay_term_con_cur.frequency_code
                            ||' , Last Cash Sch Dt : '||l_lst_cash_sch_dt);

         l_frequency  := get_frequency(p_freq_code => pay_term_con_cur.frequency_code);

         /* get the applicable dates for the schedule */

         /* For Monthly Term, Schedule-Start-Date is the First Day of the month of Schedule-Date.
            For Non Monthly Term, Schedule-Start-Date is Term Start Day of the month of the Schedule-Date.
         */

         IF pay_term_con_cur.frequency_code IN ('MON') THEN

            l_sch_str_dt := First_Day(l_lst_cash_sch_dt);
            l_sch_end_dt := LAST_DAY(l_lst_cash_sch_dt);

         ELSE

            l_sch_str_dt := TO_DATE(nvl(substr(l_cal_yr_st,1,2),TO_CHAR(pay_term_con_cur.start_date,'DD'))||'/'||
                                            TO_CHAR(l_lst_cash_sch_dt,'MM/YYYY')
                                    ,'DD/MM/YYYY');
            l_sch_end_dt := ADD_MONTHS(l_sch_str_dt, l_frequency)-1;

         END IF;

         IF l_sch_end_dt <> pay_term_con_cur.end_date THEN

           pnp_debug_pkg.log('CONTRACT_PAY_TERM - last schedule is partial');
           pnp_debug_pkg.log(' Term End Date: '||pay_term_con_cur.end_date||
                             ' - '||
                             ' Schedule End Date: '||l_sch_end_dt);

           update_cash_item(p_term_id       => pay_term_con_cur.payment_term_id,
                            p_term_str_dt   => pay_term_con_cur.start_date,
                            p_term_end_dt   => pay_term_con_cur.end_date,
                            p_schedule_dt   => l_lst_cash_sch_dt,
                            p_sch_str_dt    => l_sch_str_dt,
                            p_sch_end_dt    => l_sch_end_dt,
                            p_act_amt       => pay_term_con_cur.actual_amount,
                            p_est_amt       => pay_term_con_cur.estimated_amount,
                            p_freq          => l_frequency);

         END IF;

         IF pay_term_con_cur.normalize = 'Y' THEN

            UPDATE pn_payment_items_all
            SET    estimated_amount = 0,
                   actual_amount    = 0,
                   export_currency_amount = 0,
                   last_update_date = SYSDATE,
                   last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
                   last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
            WHERE  payment_item_id IN (SELECT ppi1.payment_item_id
                                       FROM   pn_payment_items_all ppi1,
                                              pn_payment_schedules_all pps
                                       WHERE  ppi1.payment_term_id = pay_term_con_cur.payment_term_id
                                       AND    ppi1.payment_item_type_lookup_code = 'CASH'
                                       AND    pps.payment_status_lookup_code = 'DRAFT'
                                       AND    pps.payment_schedule_id = ppi1.payment_schedule_id
                                       AND    pps.schedule_date > l_lst_cash_sch_dt);

            pnp_debug_pkg.log('CONTRACT_PAY_TERM - Updated Cash Items Amt to 0. - Normalize');

         ELSE

            DELETE pn_payment_items_all ppi
            WHERE  ppi.payment_term_id = pay_term_con_cur.payment_term_id
            AND    ppi.payment_schedule_id IN (SELECT pps1.payment_schedule_id
                                               FROM   pn_payment_schedules_all pps1,
                                                      pn_payment_items_all ppi1
                                               WHERE  ppi1.payment_term_id = pay_term_con_cur.payment_term_id
                                               AND    pps1.payment_schedule_id = ppi1.payment_schedule_id
                                               AND    pps1.payment_status_lookup_code = 'DRAFT'
                                               AND    pps1.schedule_date > l_lst_cash_sch_dt);

            DELETE pn_payment_schedules_all pps
            WHERE  pps.lease_id = p_lease_id
            AND    pps.payment_schedule_id IN (SELECT pps1.payment_schedule_id
                                               FROM   pn_payment_schedules_all pps1
                                               WHERE  pps1.lease_id = p_lease_id
                                               AND    TO_NUMBER(TO_CHAR(pps1.schedule_date,'DD'))
                                                      = pay_term_con_cur.schedule_day
                                               AND    pps1.schedule_date > l_lst_cash_sch_dt
                                               AND NOT EXISTS (SELECT NULL
                                                               FROM   pn_payment_items_all ppi
                                                               WHERE  ppi.payment_schedule_id
                                                                      = pps1.payment_schedule_id
                                                              )
                                              );

            pnp_debug_pkg.log('CONTRACT_PAY_TERM - Deleted Cash Items.');

         END IF;
      END IF;


      IF pay_term_con_cur.normalize = 'Y' THEN

         /* If the Term is Contracted, its Normalization should start from
            the same date of normalization, when the term was Abstracted or Added. */

         l_norm_str_dt := NVL(pay_term_con_cur.norm_start_date,
                              Get_First_Item_Date(pay_term_con_cur.payment_term_id));

         /* AMT-RETRO */
         IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
           create_normalize_items(p_lease_context      => p_lease_context,
                                  p_lease_id           => p_lease_id,
                                  p_term_id            => pay_term_con_cur.payment_term_id,
                                  p_vendor_id          => pay_term_con_cur.vendor_id,
                                  p_cust_id            => pay_term_con_cur.customer_id,
                                  p_vendor_site_id     => pay_term_con_cur.vendor_site_id,
                                  p_cust_site_use_id   => pay_term_con_cur.customer_site_use_id,
                                  p_cust_ship_site_id  => pay_term_con_cur.cust_ship_site_id,
                                  p_sob_id             => pay_term_con_cur.set_of_books_id,
                                  p_curr_code          => pay_term_con_cur.currency_code,
                                  p_sch_day            => pay_term_con_cur.schedule_day,
                                  p_norm_str_dt        => l_norm_str_dt,
                                  p_norm_end_dt        => NVL(pay_term_con_cur.norm_end_date,
                                                              l_lease_termination_date),
                                  p_rate               => pay_term_con_cur.rate,
                                  p_lease_change_id    => pay_term_con_cur.lease_change_id);
         ELSE
           PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE
                                 (p_lease_context      => p_lease_context,
                                  p_lease_id           => p_lease_id,
                                  p_term_id            => pay_term_con_cur.payment_term_id,
                                  p_vendor_id          => pay_term_con_cur.vendor_id,
                                  p_cust_id            => pay_term_con_cur.customer_id,
                                  p_vendor_site_id     => pay_term_con_cur.vendor_site_id,
                                  p_cust_site_use_id   => pay_term_con_cur.customer_site_use_id,
                                  p_cust_ship_site_id  => pay_term_con_cur.cust_ship_site_id,
                                  p_sob_id             => pay_term_con_cur.set_of_books_id,
                                  p_curr_code          => pay_term_con_cur.currency_code,
                                  p_sch_day            => pay_term_con_cur.schedule_day,
                                  p_norm_str_dt        => l_norm_str_dt,
                                  p_norm_end_dt        => NVL(pay_term_con_cur.norm_end_date,
                                                              l_lease_termination_date),
                                  p_rate               => pay_term_con_cur.rate,
                                  p_lease_change_id    => pay_term_con_cur.lease_change_id);

         END IF;

      END IF;

      UPDATE pn_payment_terms_all
      SET    changed_flag = 'N'
      WHERE  payment_term_id = pay_term_con_cur.payment_term_id;

   END LOOP;

   /* Now create the schedules and items for the new terms that have been added along with
      the contraction of the main lease */

   add_main(p_lease_id            => p_lease_id,
            p_lease_context       => 'ADDEDT',
            p_new_lea_term_dt     => p_new_lea_term_dt,
            p_new_lea_comm_dt     => p_new_lea_comm_dt,
            p_mths                => p_mths);


   pnp_debug_pkg.log('CONTRACT_PAY_TERM - Contraction of Payment Term - CONTERM -End- (+)');

END contract_pay_term;
------------------------------------------------------------------------
--  FUNCTION  :- GET_LEASE_CHANGE_ID
--  23-SEP-2002  graghuna        o created
--  10-DEC-2002  graghuna        o Modified Cursor lease_dt_hist_cursor. Union to
--                                 tables pn_lease_details_all and pn_leases_all
--                                 for Month-to-Month Re-Normalization issue. --MTM-I
------------------------------------------------------------------------
FUNCTION Get_Lease_Change_Id (p_lease_id IN NUMBER)
RETURN   NUMBER
IS

   l_lease_change_id               NUMBER := 0;
   l_act_lease_found               BOOLEAN := FALSE;

   CURSOR lease_dt_hist_cursor IS
      SELECT lease_change_id, lease_status
      FROM   pn_lease_details_history
      WHERE  lease_id = p_lease_id
      UNION
      SELECT b.lease_change_id, a.lease_status
      FROM   pn_leases_all a, pn_lease_details_all b
      WHERE  a.lease_id = b.lease_id
      AND    a.lease_id = p_lease_id
      ORDER BY 1 DESC;

BEGIN

    FOR lease_dt_hist_rec in lease_dt_hist_cursor
    LOOP

        IF lease_dt_hist_rec.lease_status = 'ACT' THEN
            l_lease_change_id := lease_dt_hist_rec.lease_change_id;
            l_act_lease_found := TRUE;
        END IF;

        IF l_act_lease_found and lease_dt_hist_rec.lease_status not in ('ACT')  THEN
            EXIT;
        END IF;

    END LOOP;

    RETURN l_lease_change_id;

END Get_Lease_Change_Id;


------------------------------------------------------------------------
--  FUNCTION  :- GET_SCHEDULE_DATE
--  DESCRIPTION :- Given the schedule_day and the lease dates this function
--                 will return the schedule date for that period if there
--                 are no approved payments for that date, otherwise it
--                 will return the next day.
-- 23-SEP-2002  graghuna o created
-- 31-OCT-2002  Satish Tripathi o Changed TO_DATE format from MON-YYYY to MM/YYYY
--                                for GSCC error.
-- 18-DEC-2002  graghua         o modified to check for APRROVED status from the
--                                payment term start date until lease extension end date
-- 21-Oct-2004  vmmehta         o bug# 3934425 - Added parameter p_freq.
-- 31-Jul-2009  acprakas        o Bug# 8688477. Modified the logic to get next schedule date
--                                correctly from 28-feb-
------------------------------------------------------------------------
FUNCTION Get_Schedule_Date (p_lease_id   IN NUMBER,
                            p_day        IN NUMBER,
                            p_start_date IN DATE,
                            p_end_date   IN DATE,
                            p_freq       IN NUMBER)
RETURN   DATE
IS
   l_dummy                         NUMBER := NULL;
   l_sch_day                       NUMBER := NULL;
   l_schedule_date                 DATE := NULL;
   l_start_schedule_date           DATE := NULL;
   l_max_sch_date                  DATE := TO_DATE('28/'||TO_CHAR(p_start_date,'MM/YYYY'),'DD/MM/YYYY');
   l_found_apprvd_sch              BOOLEAN := FALSE;

   CURSOR check_sch_date (p_schedule_date DATE) IS
      SELECT payment_schedule_id
      FROM   pn_payment_schedules_all
      WHERE  lease_id = p_lease_id
      AND    schedule_date = p_schedule_date
      AND    payment_status_lookup_code = 'APPROVED';
BEGIN

   pnp_debug_pkg.log('GET_SCHEDULE_DATE (+) LeaseId: '||p_lease_id||' Day: '||p_day);

   l_start_schedule_date := TO_DATE(TO_CHAR(p_day)||'/'||TO_CHAR(p_start_date,'MM/YYYY'),'DD/MM/YYYY');

   -- Check if there is any approved scheule for that date
   -- If so we will add 1 to the schedule_date.Using date will take care
   -- of leap year complexity. While inserting day in the payment terms table
   -- just strip off the DAY part from the date returned by this function

    WHILE l_start_schedule_date <=  l_max_sch_date
    LOOP
       l_found_apprvd_sch := FALSE;
       l_schedule_date := l_start_schedule_date;
       WHILE l_schedule_date < p_end_date LOOP
          -- If there is nothing in approved status for that
          -- date then no_Data_found will be raised and this
          -- loop will exit;
          l_dummy := NULL;
          OPEN check_sch_date(l_schedule_date);
             FETCH check_sch_date
             INTO  l_dummy;
             IF check_sch_date%NOTFOUND THEN
                CLOSE check_sch_date;
             END IF;

             IF l_dummy IS NOT NULL THEN
                l_found_apprvd_sch := TRUE;
                CLOSE check_sch_date;
                l_start_schedule_date := l_start_schedule_date  + 1;
                IF l_start_schedule_date > l_max_sch_date THEN
                   -- This means that all days in the period
                   -- were used up.
                   l_schedule_date := NULL;
                END IF;
                EXIT;
             END IF;

		IF TO_CHAR(l_schedule_date,'DD') = 28 AND TO_CHAR(l_schedule_date,'MM') = '02'
	       THEN
	           l_schedule_date := ADD_MONTHS(l_schedule_date - 1,p_freq) + 1;
	       ELSE
	           l_schedule_date  := ADD_MONTHS(l_schedule_date, p_freq);
               END IF;

          IF check_sch_date%ISOPEN THEN
             CLOSE check_sch_date;
          END IF;
       END LOOP;
       -- end loop for l_start_date
       -- if l_Found_apprvd_sch is false it means that all the schedule_dates
       -- until the p_end_date are unapprvoed so we can use the schedule day
       -- of the schedule date
       IF NOT(l_found_apprvd_sch) THEN
          EXIT;
       END IF;
    END LOOP;

   pnp_debug_pkg.log('GET_SCHEDULE_DATE (-) Schedule Date: '||l_schedule_date);
   RETURN l_schedule_date;

EXCEPTION
   WHEN OTHERS THEN
       pnp_debug_pkg.log('GET_SCHEDULE_DATE - Others error ..' || sqlerrm);
       l_schedule_Date := NULL;
       RETURN l_schedule_date;

END Get_Schedule_Date;

-------------------------------------------------------------------------------
--  PROCEDURE :- INSERT_PAYMENT_TERM
--  DESCRIPTION :-  Procedure to create records in pn_payment_terms table
-- 23-SEP-2002  graghuna o created
-- 13-JAN-2002  psidhu   o Added logic to insert distribution information for new term
--                         being created. Added parameter x_term_template_id in call to
--                         pnt_payment_terms_pkg.insert_row. Fix for bug#2733889.
--  29-AUG-2003  Satish Tripathi o Fixed for BUG# 3116986, added x_rec_agr_line_id,
--                                 x_period_billrec_id and x_amount_type.
-- 15-JUL-05  hareesha o Bug 4284035 - Replaced pn_distributions with _ALL table.
-- 16-OCT-06  Hareesha o MTM - Populate parent_term_id and index_norm_flag
--                       while insertion.
-- 03-APR-07  Prabhakar o Bug #5958872. Added the two parameters area and
--                        area_type_code in the call to inser_row handler.
-------------------------------------------------------------------------------
PROCEDURE Insert_Payment_Term (p_payment_term_rec              IN OUT NOCOPY pn_payment_terms_all%ROWTYPE,
                               x_return_status                    OUT NOCOPY VARCHAR2,
                               x_return_message                   OUT NOCOPY VARCHAR2)
IS

   l_payment_term_id               NUMBER := NULL;
   l_rowid                         ROWID;
   l_distribution_id               NUMBER;
   l_dist_rowid                    ROWID;

 CURSOR csr_distributions (p_payment_term_id IN NUMBER)
   IS
   SELECT *
   FROM pn_distributions_all
   WHERE payment_term_id = p_payment_term_id;


BEGIN

   pnp_debug_pkg.log('INSERT_PAYMENT_TERM (+) ');

   pnt_payment_terms_pkg.Insert_Row
   (
        x_rowid                         => l_rowid,
        x_payment_term_id               => l_payment_term_id,
        x_payment_purpose_code          => p_payment_term_rec.payment_purpose_code,
        x_payment_term_type_code        => p_payment_term_rec.payment_term_type_code,
        x_frequency_code                => p_payment_term_rec.frequency_code,
        x_lease_id                      => p_payment_term_rec.lease_id,
        x_lease_change_id               => p_payment_term_rec.lease_change_id,
        x_start_date                    => p_payment_term_rec.start_date,
        x_end_date                      => p_payment_term_rec.end_date,
        x_vendor_id                     => p_payment_term_rec.vendor_id,
        x_vendor_site_id                => p_payment_term_rec.vendor_site_id,
        x_customer_id                   => p_payment_term_rec.customer_id,
        x_customer_site_use_id          => p_payment_term_rec.customer_site_use_id,
        x_target_date                   => p_payment_term_rec.target_date,
        x_actual_amount                 => p_payment_term_rec.actual_amount,
        x_estimated_amount              => p_payment_term_rec.estimated_amount,
        x_set_of_books_id               => p_payment_term_rec.set_of_books_id,
        x_currency_code                 => p_payment_term_rec.currency_code,
        x_rate                          => p_payment_term_rec.rate,
        x_normalize                     => p_payment_term_rec.normalize,
        x_location_id                   => p_payment_term_rec.location_id,
        x_schedule_day                  => p_payment_term_rec.schedule_day,
        x_cust_ship_site_id             => p_payment_term_rec.cust_ship_site_id,
        x_ap_ar_term_id                 => p_payment_term_rec.ap_ar_term_id,
        x_cust_trx_type_id              => p_payment_term_rec.cust_trx_type_id,
        x_project_id                    => p_payment_term_rec.project_id,
        x_task_id                       => p_payment_term_rec.task_id,
        x_organization_id               => p_payment_term_rec.organization_id,
        x_expenditure_type              => p_payment_term_rec.expenditure_type,
        x_expenditure_item_date         => p_payment_term_rec.expenditure_item_date,
        x_tax_group_id                  => p_payment_term_rec.tax_group_id,
        x_tax_code_id                   => p_payment_term_rec.tax_code_id,
        x_tax_included                  => p_payment_term_rec.tax_included,
        x_distribution_set_id           => p_payment_term_rec.distribution_set_id,
        x_inv_rule_id                   => p_payment_term_rec.inv_rule_id,
        x_account_rule_id               => p_payment_term_rec.account_rule_id,
        x_salesrep_id                   => p_payment_term_rec.salesrep_id,
        x_approved_by                   => p_payment_term_rec.approved_by,
        x_status                        => p_payment_term_rec.status,
        x_index_period_id               => p_payment_term_rec.index_period_id,
        x_index_term_indicator          => p_payment_term_rec.index_term_indicator,
        x_po_header_id                  => p_payment_term_rec.po_header_id,
        x_cust_po_number                => p_payment_term_rec.cust_po_number,
        x_receipt_method_id             => p_payment_term_rec.receipt_method_id,
        x_var_rent_inv_id               => p_payment_term_rec.var_rent_inv_id,
        x_var_rent_type                 => p_payment_term_rec.var_rent_type,
        x_changed_flag                  => p_payment_term_rec.changed_flag,
        x_term_template_id              => p_payment_term_rec.term_template_id,
        x_attribute_category            => p_payment_term_rec.attribute_category,
        x_attribute1                    => p_payment_term_rec.attribute1,
        x_attribute2                    => p_payment_term_rec.attribute2,
        x_attribute3                    => p_payment_term_rec.attribute3,
        x_attribute4                    => p_payment_term_rec.attribute4,
        x_attribute5                    => p_payment_term_rec.attribute5,
        x_attribute6                    => p_payment_term_rec.attribute6,
        x_attribute7                    => p_payment_term_rec.attribute7,
        x_attribute8                    => p_payment_term_rec.attribute8,
        x_attribute9                    => p_payment_term_rec.attribute9,
        x_attribute10                   => p_payment_term_rec.attribute10,
        x_attribute11                   => p_payment_term_rec.attribute11,
        x_attribute12                   => p_payment_term_rec.attribute12,
        x_attribute13                   => p_payment_term_rec.attribute13,
        x_attribute14                   => p_payment_term_rec.attribute14,
        x_attribute15                   => p_payment_term_rec.attribute15,
        x_project_attribute_category    => p_payment_term_rec.project_attribute_category,
        x_project_attribute1            => p_payment_term_rec.project_attribute1,
        x_project_attribute2            => p_payment_term_rec.project_attribute2,
        x_project_attribute3            => p_payment_term_rec.project_attribute3,
        x_project_attribute4            => p_payment_term_rec.project_attribute4,
        x_project_attribute5            => p_payment_term_rec.project_attribute5,
        x_project_attribute6            => p_payment_term_rec.project_attribute6,
        x_project_attribute7            => p_payment_term_rec.project_attribute7,
        x_project_attribute8            => p_payment_term_rec.project_attribute8,
        x_project_attribute9            => p_payment_term_rec.project_attribute9,
        x_project_attribute10           => p_payment_term_rec.project_attribute10,
        x_project_attribute11           => p_payment_term_rec.project_attribute11,
        x_project_attribute12           => p_payment_term_rec.project_attribute12,
        x_project_attribute13           => p_payment_term_rec.project_attribute13,
        x_project_attribute14           => p_payment_term_rec.project_attribute14,
        x_project_attribute15           => p_payment_term_rec.project_attribute15,
        x_creation_date                 => SYSDATE,
        x_created_by                    => fnd_global.user_id,
        x_last_update_date              => SYSDATE,
        x_last_updated_by               => fnd_global.user_id,
        x_last_update_login             => fnd_global.login_id,
        x_lease_status                  => p_payment_term_rec.lease_status,
        x_org_id                        => p_payment_term_rec.org_id,
        x_rec_agr_line_id               => p_payment_term_rec.rec_agr_line_id,
        x_period_billrec_id             => p_payment_term_rec.period_billrec_id,
        x_amount_type                   => p_payment_term_rec.amount_type,
        x_recoverable_flag              => p_payment_term_rec.recoverable_flag,
        x_parent_term_id                => p_payment_term_rec.parent_term_id,
        x_index_norm_flag               => p_payment_term_rec.index_norm_flag,
        x_area                          => p_payment_term_rec.area,
        x_area_type_code                => p_payment_term_rec.area_type_code
   );

   pnp_debug_pkg.log('INSERT_PAYMENT_TERM (-) Created Payment Term Id: '||l_payment_term_id);

   -- Fix for bug#2733889

   FOR rec_distributions in csr_distributions(p_payment_term_rec.payment_term_id) LOOP

      pn_distributions_pkg.insert_row (
        x_rowid                => l_dist_rowid
       ,x_distribution_id      => l_distribution_id
       ,x_account_id           => rec_distributions.account_id
       ,x_payment_term_id      => l_payment_term_id
       ,x_term_template_id     => rec_distributions.term_template_id
       ,x_account_class        => rec_distributions.account_class
       ,x_percentage           => rec_distributions.percentage
       ,x_line_number          => rec_distributions.line_number
       ,x_last_update_date     => sysdate
       ,x_last_updated_by      => NVL(fnd_profile.VALUE ('USER_ID'), 0)
       ,x_creation_date        => sysdate
       ,x_created_by           => NVL(fnd_profile.VALUE ('USER_ID'), 0)
       ,x_last_update_login    => NVL(fnd_profile.value('LOGIN_ID'),0)
       ,x_attribute_category   => rec_distributions.attribute_category
       ,x_attribute1           => rec_distributions.attribute1
       ,x_attribute2           => rec_distributions.attribute2
       ,x_attribute3           => rec_distributions.attribute3
       ,x_attribute4           => rec_distributions.attribute4
       ,x_attribute5           => rec_distributions.attribute5
       ,x_attribute6           => rec_distributions.attribute6
       ,x_attribute7           => rec_distributions.attribute7
       ,x_attribute8           => rec_distributions.attribute8
       ,x_attribute9           => rec_distributions.attribute9
       ,x_attribute10          => rec_distributions.attribute10
       ,x_attribute11          => rec_distributions.attribute11
       ,x_attribute12          => rec_distributions.attribute12
       ,x_attribute13          => rec_distributions.attribute13
       ,x_attribute14          => rec_distributions.attribute14
       ,x_attribute15          => rec_distributions.attribute15
       ,x_org_id               => rec_distributions.org_id);

       pnp_debug_pkg.log('INSERT_PAYMENT_TERM : Created Distribution Id: '||l_distribution_id||
                         ' for Payment term id :'||l_payment_term_id);

       l_dist_rowid := NULL;
       l_distribution_id := NULL;
   END LOOP;
   ---

   p_payment_term_rec.payment_term_id := l_payment_term_id;

   pnp_debug_pkg.log('INSERT_PAYMENT_TERM (-)');

END Insert_Payment_Term;

--------------------------------------------------------------------------------
--  PROCEDURE :- EXTEND_PAYMENT_TERM
--  DESCRIPTION :- This procedure will be called to extend the end date
--                 on a not normalized payment term. This procedure
--                 is called from ROLLOVER_LEASE
-- 13-DEC-02  graghuna o created  Month-2-Month enchancement.
-- 06-AUG-04  Mrinal   o While updating actual and estimated amount
--                       updated the export currency amount in items
--                       table. Bug # 3804548.
-- 10-JAN-05  Anand    o Code changes for Retro.
-- 24-NOV-05  Kiran    o Round amounts befor insert/uptdate into terms OR items
-- 27-NOV-06  Hareesha o MTM Uptake - Passed payment_term_id parameter to
--                       create_schedules.
-- 05-MAR-10  jsundara o Bug9297899 - In case of M2M lease changed the logic
 	 --                       to avoid duplicate schedules
-- 12-APR-2010 acprakas o Bug#9562795. Modified cursor exist_appr_item_amt
--                        to consider CASH amount only. Also added some
--                         debug messages.
--------------------------------------------------------------------------------

PROCEDURE Extend_Payment_Term (p_payment_term_rec              IN pn_payment_terms_all%ROWTYPE,
                               p_new_lea_comm_dt               IN DATE,
                               p_new_lea_term_dt               IN DATE,
                               p_mths                          IN NUMBER,
                               p_new_start_date                IN DATE ,
                               p_new_end_date                  IN DATE,
                               x_return_status                 OUT NOCOPY VARCHAR2,
                               x_return_message                OUT NOCOPY VARCHAR2
                              )

IS
   l_pro_sch_dt                    pn_payment_schedules.schedule_date%TYPE;
   l_no_sch                        NUMBER;
   l_freq                          NUMBER;
   l_counter                       NUMBER;
   l_sch_dt                        pn_payment_schedules.schedule_date%TYPE;
   l_sch_str_dt                    DATE;
   l_sch_end_dt                    DATE;
   l_norm_st_dt                    DATE;
   l_sch_id                        pn_payment_schedules.payment_schedule_id%TYPE;
   l_pymnt_st_lkp_cd               pn_payment_schedules.payment_status_lookup_code%TYPE;
   l_est_amt                       pn_payment_terms_all.estimated_amount%TYPE;
   l_act_amt                       pn_payment_terms_all.actual_amount%TYPE;
   l_cash_est_amt                  pn_payment_terms_all.estimated_amount%TYPE;
   l_cash_act_amt                  pn_payment_terms_all.actual_amount%TYPE;
   l_rec_found                     BOOLEAN := FALSE;
   l_sch_day                       VARCHAR2(240);
   l_exist_amount                  NUMBER;

   CURSOR existing_payment_item_cur (p_sch_id NUMBER) IS
      SELECT payment_item_id, actual_amount, estimated_amount
      FROM   pn_payment_items_all
      WHERE  payment_schedule_id = p_sch_id
      AND    payment_term_id = p_payment_term_rec.payment_term_id
      AND    payment_item_type_lookup_code = 'CASH';

   CURSOR exist_appr_item_amt IS
      SELECT NVL(SUM(pi.actual_amount),0) amount
      FROM   pn_payment_items_all pi,
             pn_payment_schedules_all ps
      WHERE  pi.payment_term_id = p_payment_term_rec.payment_term_id
      AND    pi.payment_schedule_id = ps.payment_schedule_id
      AND    ps.schedule_date = l_sch_dt
      AND    ps.payment_status_lookup_code = 'APPROVED'
      AND    pi.payment_item_type_lookup_code = 'CASH';

   l_precision                    NUMBER;
   l_ext_precision                NUMBER;
   l_min_acct_unit                NUMBER;

   -- Bug 7570052
   l_cal_yr_st_dt                 PN_LEASES_ALL.cal_start%TYPE;
   l_non_zero_cash_sch_cnt        NUMBER := 0;

BEGIN

   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM (+) '||
                     ' Term Id: '|| p_payment_term_rec.payment_term_id||
                     ' Term End Date: '|| p_new_end_date);
   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM IN: p_new_lea_comm_dt    : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM IN: p_new_lea_term_dt    : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM IN: p_mths               : '||p_mths);
   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM IN: p_new_start_date     : '||p_new_start_date);
   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM IN: p_new_end_date       : '||p_new_end_date);

   /* get currency info for rounding */
   fnd_currency.get_info( currency_code => p_payment_term_rec.currency_code
                         ,precision     => l_precision
                         ,ext_precision => l_ext_precision
                         ,min_acct_unit => l_min_acct_unit);

   -- Bug 7570052
   SELECT cal_start
   INTO   l_cal_yr_st_dt
   FROM PN_LEASES_ALL
   WHERE LEASE_ID = (select distinct lease_id from pn_payment_terms_all where payment_term_id = p_payment_term_rec.payment_term_id);

   get_sch_info(p_lease_context            => 'ABS',
                p_normalize_flag           => 'N',
                p_mths                     => p_mths,
                p_term_start_dt            => p_payment_term_rec.start_date,
                p_term_end_dt              => p_new_end_date,
                p_freq_code                => p_payment_term_rec.frequency_code,
                p_sch_day                  => p_payment_term_rec.schedule_day,
                p_new_lea_comm_dt          => p_new_lea_comm_dt,
                p_new_lea_term_dt          => p_new_lea_term_dt,
                p_old_lea_term_dt          => NULL,
                p_no_sch                   => l_no_sch,
                p_freq                     => l_freq,
                p_counter                  => l_counter,
                p_sch_dt                   => l_sch_dt,
                p_pro_sch_dt               => l_pro_sch_dt,
                p_sch_str_dt               => l_sch_str_dt,
                p_norm_str_dt              => l_norm_st_dt,
                p_lease_id                 => p_payment_term_rec.lease_id,
                p_term_id                  => p_payment_term_rec.payment_term_id);

   l_sch_day := TO_CHAR(l_sch_dt,'DD');

   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - l_sch dt: '||l_sch_dt||' l_sch day: '||l_sch_day);

   IF p_payment_term_rec.frequency_code IN ('MON', 'OT') THEN
      l_sch_str_dt := FIRST_DAY(l_sch_dt);
   END IF;

   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - l_sch_str dt: '||l_sch_str_dt||
                     ' l_counter: '||l_counter||
                     ' l_no_sch: '||l_no_sch);

   FOR i IN (l_counter + 1) .. l_no_sch
   LOOP
      pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Calling  create schedule ');
      /* AMT-RETRO */
      IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN
        create_schedule(p_payment_term_rec.lease_id,
                        p_payment_term_rec.lease_change_id,
                        l_sch_dt,
                        l_sch_id,
                        l_pymnt_st_lkp_cd,
                        p_payment_term_rec.payment_term_id);
      ELSE
        PN_RETRO_ADJUSTMENT_PKG.find_schedule(p_payment_term_rec.lease_id,
                                              p_payment_term_rec.lease_change_id,
                                              p_payment_term_rec.payment_term_id,
                                              l_sch_dt,
                                              l_sch_id);
        l_pymnt_st_lkp_cd := 'DRAFT';
      END IF;

      IF p_payment_term_rec.frequency_code IN ('MON', 'OT') THEN
         l_sch_end_dt := LAST_DAY(l_sch_dt);
      ELSE
         l_sch_end_dt := ADD_MONTHS(l_sch_str_dt, l_freq) -1;
      END IF;

      pnp_debug_pkg.log('EXTEND_PAYMENT_TERM: l_sch_enddate_ = '||l_sch_end_dt||
                        ' l_sch_dt: '|| l_sch_dt||
                        ' l_pro_sch_dt: '||l_pro_sch_dt);

      IF l_sch_dt = l_pro_sch_dt THEN
         IF p_payment_term_rec.frequency_code = 'OT' THEN

            -- For 'One Time' payment, the payment item amounts will
            --   be same as the payment term amounts.

            l_cash_est_amt := p_payment_term_rec.estimated_amount;
            l_cash_act_amt :=nvl(p_payment_term_rec.actual_amount,
                                 p_payment_term_rec.estimated_amount);
         ELSE

            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Calling get_amount, sch st dt    : '
                               ||TO_CHAR(l_sch_str_dt,'MM/DD/YYYY'));
            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Calling get_amount, sch end dt   : '
                               ||TO_CHAR(l_sch_end_dt,'MM/DD/YYYY'));
            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Calling get_amount, term st dt   : '
                               ||TO_CHAR(p_payment_term_rec.start_date,'MM/DD/YYYY'));
            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Calling get_amount, term end dt  : '
                               ||TO_CHAR(p_new_end_date,'MM/DD/YYYY'));
            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Calling get_amount, act amt      : '
                               ||TO_CHAR(l_act_amt));
            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Calling get_amount, est amt      : '
                               ||TO_CHAR(l_est_amt));
            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Calling get_amount, freq : '
                               ||TO_CHAR(l_freq));

            get_amount(p_sch_str_dt    => l_sch_str_dt,
                       p_sch_end_dt    => l_sch_end_dt,
                       p_trm_str_dt    => p_payment_term_rec.start_date,
                       p_trm_end_dt    => p_new_end_date,
                       p_act_amt       => p_payment_term_rec.actual_amount,
                       p_est_amt       => p_payment_term_rec.estimated_amount,
                       p_freq          => l_freq,
                       p_cash_act_amt  => l_cash_act_amt,
                       p_cash_est_amt  => l_cash_est_amt);

            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Returned from get_amount, cash act amt: '
                               ||TO_CHAR(l_cash_act_amt));
            pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - Returned from get_amount, cash est amt: '
                               ||TO_CHAR(l_cash_est_amt));

            -- Get the next schedule date which will have non zero amount

            l_non_zero_cash_sch_cnt := l_non_zero_cash_sch_cnt + 1;

            -- Bug 7570052
            IF l_non_zero_cash_sch_cnt = 1 and l_cal_yr_st_dt IS NOT NULL THEN

                   l_pro_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_sch_str_dt,l_freq),
                                                              'MM/YYYY'),'DD/MM/YYYY');
            ELSE
                   l_pro_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_pro_sch_dt,l_freq),
                                                             'MM/YYYY'),'DD/MM/YYYY');
            END IF;

         END IF;
         -- end if of  freq_Code  = OT

      ELSE
         -- Set the amounts to zero
         l_cash_act_amt := 0;
         l_cash_est_amt := NULL;
      END IF;

      l_rec_found := FALSE;
      IF NOT PNP_UTIL_FUNC.RETRO_ENABLED THEN

        pnp_debug_pkg.log('Retro not enabled... ');

	 l_exist_amount := 0;

        FOR amt_rec IN exist_appr_item_amt LOOP
 	    l_exist_amount := amt_rec.amount;
 	END LOOP;  /* 9322649 */

 pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - exist amount: ' || TO_CHAR(l_exist_amount));
 pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - cash amount: ' ||TO_CHAR(l_cash_act_amt));


        FOR existing_items_rec in existing_payment_item_cur(l_sch_id) LOOP
          l_rec_found := TRUE;

pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - rec found...');

pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - existing_items_rec.actual_amount: ' ||TO_CHAR(existing_items_rec.actual_amount));
pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - l_cash_act_amt: ' ||TO_CHAR(l_cash_act_amt));

          IF existing_items_rec.actual_amount <> l_cash_act_amt THEN
             UPDATE pn_payment_items_all
             SET    actual_amount = ROUND(l_cash_act_amt - l_exist_amount, l_precision),
                    export_currency_amount = ROUND(l_cash_act_amt - l_exist_amount, l_precision),
                    estimated_amount = ROUND(l_cash_est_amt,l_precision),
                    last_update_date = sysdate,
                    last_updated_by  = fnd_global.user_id
             WHERE  payment_item_id = existing_items_rec.payment_item_id;
          END IF;
          EXIT;
        END LOOP;

        IF NOT(l_rec_found) THEN

 pnp_debug_pkg.log('EXTEND_PAYMENT_TERM - rec not found...');

	 IF l_cash_act_amt - l_exist_amount <> 0 THEN
          create_cash_items(p_est_amt           => l_cash_est_amt,
                            p_act_amt           => l_cash_act_amt - l_exist_amount,
                            p_sch_dt            => l_sch_dt,
                            p_sch_id            => l_sch_id,
                            p_term_id           => p_payment_term_rec.payment_term_id,
                            p_vendor_id         => p_payment_term_rec.vendor_id,
                            p_cust_id           => p_payment_term_rec.customer_id,
                            p_vendor_site_id    => p_payment_term_rec.vendor_site_id,
                            p_cust_site_use_id  => p_payment_term_rec.customer_site_use_id,
                            p_cust_ship_site_id => p_payment_term_rec.cust_ship_site_id,
                            p_sob_id            => p_payment_term_rec.set_of_books_id,
                            p_curr_code         => p_payment_term_rec.currency_code,
                            p_rate              => p_payment_term_rec.rate);
   	         ELSE
 	             DELETE FROM PN_PAYMENT_SCHEDULES_ALL
 	             WHERE  payment_schedule_id = l_sch_id
                 AND NOT EXISTS (select 'Y'
                                 from pn_payment_items_all
                                 where payment_schedule_id = l_sch_id); /* Added Bug 9542483 */
        END IF;
	  END IF; /* NOT(l_rec_found) */

      ELSE /* retro is enabled */

        pnp_debug_pkg.log('Retro enabled... ');
        l_exist_amount := 0;
        FOR amt_rec IN exist_appr_item_amt LOOP
          l_exist_amount := amt_rec.amount;
        END LOOP;

        FOR existing_items_rec IN existing_payment_item_cur(l_sch_id) LOOP
           l_rec_found := TRUE;
           IF existing_items_rec.actual_amount <> l_cash_act_amt THEN
              UPDATE pn_payment_items_all
              SET    actual_amount = ROUND(l_cash_act_amt - l_exist_amount, l_precision),
                     export_currency_amount = ROUND(l_cash_act_amt - l_exist_amount, l_precision),
                     estimated_amount = ROUND(l_cash_est_amt, l_precision),
                     last_update_date = sysdate,
                     last_updated_by  = fnd_global.user_id
              WHERE  payment_item_id = existing_items_rec.payment_item_id;
           END IF;
           EXIT;
        END LOOP;
        IF NOT(l_rec_found) THEN
          IF l_cash_act_amt - l_exist_amount <> 0 THEN
            create_cash_items(p_est_amt           => l_cash_est_amt,
                              p_act_amt           => l_cash_act_amt - l_exist_amount,
                              p_sch_dt            => l_sch_dt,
                              p_sch_id            => l_sch_id,
                              p_term_id           => p_payment_term_rec.payment_term_id,
                              p_vendor_id         => p_payment_term_rec.vendor_id,
                              p_cust_id           => p_payment_term_rec.customer_id,
                              p_vendor_site_id    => p_payment_term_rec.vendor_site_id,
                              p_cust_site_use_id  => p_payment_term_rec.customer_site_use_id,
                              p_cust_ship_site_id => p_payment_term_rec.cust_ship_site_id,
                              p_sob_id            => p_payment_term_rec.set_of_books_id,
                              p_curr_code         => p_payment_term_rec.currency_code,
                              p_rate              => p_payment_term_rec.rate);
          ELSE
            DELETE FROM PN_PAYMENT_SCHEDULES_ALL
            WHERE  payment_schedule_id = l_sch_id
	     and not exists (select NULL
 	             from pn_payment_items_all
 	             where payment_schedule_id = l_sch_id); /* 9322649 */
          END IF;

        END IF; /* NOT(l_rec_found) */

      END IF; /* retro */

      -- Bug 7570052
      IF l_cal_yr_st_dt IS NULL THEN
        l_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_sch_dt, l_freq),'MM/YYYY'),'DD/MM/YYYY');
      ELSE
        l_sch_dt := TO_DATE(l_sch_day||'/'||TO_CHAR(ADD_MONTHS(l_sch_str_dt, l_freq),'MM/YYYY'),'DD/MM/YYYY');
      END IF;

      l_sch_str_dt := ADD_MONTHS(l_sch_str_dt, l_freq);
   END LOOP;

   pnp_debug_pkg.log('EXTEND_PAYMENT_TERM (-) ');
EXCEPTION

   WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;

END Extend_Payment_Term;


-------------------------------------------------------------------------------
--  PROCEDURE :- CREATE_PAYMENT_TERM
--  DESCRIPTION :- This procedure will be called to create a payment term
--  13-DEC-2002   graghuna o created
--  20-DEC-2002   graghuna o modified for Month-to-Month (MTM) Changes.
--  16-OCT-2003  Satish Tripathi o Fix for BUG# 3201091. Pass new parameter p_lease_change_id
--                                 to process_term.
--  16-OCT-06  Hareesha o Populate index_norm_flag and parent_term_id while
--                        creating not-normalized terms for rollover period.
-------------------------------------------------------------------------------
PROCEDURE Create_Payment_Term (p_payment_term_rec              IN pn_payment_terms_all%ROWTYPE,
                               p_lease_end_date                IN     DATE,
                               p_term_start_date               IN     DATE,
                               p_term_end_date                 IN     DATE,
                               p_new_lea_term_dt               IN     DATE,
                               p_new_lea_comm_dt               IN     DATE,
                               p_mths                          IN     NUMBER,
                               x_return_status                 OUT NOCOPY VARCHAR2,
                               x_return_message                OUT NOCOPY VARCHAR2)
IS

   l_rowid                         ROWID;
   Invalid_Schd_Date               EXCEPTION;
   l_new_term_start_date           DATE := NULL;
   l_schedule_date                 DATE := NULL;
   l_sch_id                        NUMBER := NULL;
   l_curr_payment_term_id          NUMBER := NULL;
   l_payment_term_rec              pn_payment_terms_all%ROWTYPE;
   l_pro_sch_dt                    pn_payment_schedules.schedule_date%TYPE;
   l_no_sch                        NUMBER;
   l_freq                          NUMBER;
   l_counter                       NUMBER;
   l_sch_dt                        pn_payment_schedules.schedule_date%TYPE;
   l_sch_str_dt                    DATE;
   l_norm_st_dt                    DATE;

BEGIN

   pnp_debug_pkg.log('CREATE_PAYMENT_TERM (+) Lease ID: '||p_payment_term_rec.lease_id||
                     ', p_lease_end_date: '||p_lease_end_date);
   pnp_debug_pkg.log('CREATE_PAYMENT_TERM IN: p_lease_end_date     : '||p_lease_end_date);
   pnp_debug_pkg.log('CREATE_PAYMENT_TERM IN: p_term_start_date    : '||p_term_start_date);
   pnp_debug_pkg.log('CREATE_PAYMENT_TERM IN: p_term_end_date      : '||p_term_end_date);
   pnp_debug_pkg.log('CREATE_PAYMENT_TERM IN: p_new_lea_term_dt    : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('CREATE_PAYMENT_TERM IN: p_new_lea_comm_dt    : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('CREATE_PAYMENT_TERM IN: p_mths               : '||p_mths);

   l_payment_term_rec := p_payment_term_rec;
   l_curr_payment_term_id := l_payment_term_rec.payment_term_id ;
   l_payment_term_rec.start_date :=  p_term_start_date;
   l_payment_term_rec.end_date   :=  p_term_end_date;
   l_payment_term_rec.normalize :=  'N' ;
   l_payment_term_rec.lease_status :=  'MTM' ;
   l_payment_term_rec.frequency_code :=  p_payment_term_rec.frequency_code;
   l_payment_term_rec.status := 'DRAFT';

   pnp_debug_pkg.log('CREATE_PAYMENT_TERM - payment term_id  '||l_payment_term_rec.payment_Term_id);

   pn_schedules_items.Insert_Payment_Term (
      p_payment_term_rec => l_payment_term_rec,
      x_return_status     => x_return_status,
      x_return_message    => x_return_message);

   pnp_debug_pkg.log('CREATE_PAYMENT_TERM - Calling get_sch_info ...');
   get_sch_info(p_lease_context            => 'ABS',
                p_normalize_flag           => 'N',
                p_mths                     => p_mths,
                p_term_start_dt            => p_term_start_date,
                p_term_end_dt              => p_term_end_date,
                p_freq_code                => l_payment_term_rec.frequency_code,
                p_sch_day                  => l_payment_term_rec.schedule_day,
                p_new_lea_comm_dt          => p_new_lea_comm_dt,
                p_new_lea_term_dt          => p_new_lea_term_dt,
                p_old_lea_term_dt          => NULL,
                p_no_sch                   => l_no_sch,
                p_freq                     => l_freq,
                p_counter                  => l_counter,
                p_sch_dt                   => l_sch_dt,
                p_pro_sch_dt               => l_pro_sch_dt,
                p_sch_str_dt               => l_sch_str_dt,
                p_norm_str_dt              => l_norm_st_dt,
               p_lease_id                  => l_payment_term_rec.lease_id,
                p_term_id                  => l_payment_term_rec.payment_term_id);

   pnp_debug_pkg.log('CREATE_PAYMENT_TERM - Calling process term...');
   process_term(p_no_sch                   => l_no_sch,
                p_counter                  => l_counter,
                p_sch_dt                   => l_sch_dt,
                p_pro_sch_dt               => l_pro_sch_dt,
                p_new_lea_term_dt          => p_new_lea_term_dt ,
                p_freq                     => l_freq,
                p_freq_code                => l_payment_term_rec.frequency_code,
                p_payment_term_id          => l_payment_term_rec.payment_term_id,
                p_pay_trm_typ_code         => l_payment_term_rec.payment_term_type_code,
                p_trgt_dt                  => l_payment_term_rec.target_date,
                p_normalize_flag           => 'N',
                p_lease_context            => 'ABS',
                p_mths                     => p_mths,
                p_vendor_id                => l_payment_term_rec.vendor_id,
                p_customer_id              => l_payment_term_rec.customer_id,
                p_vendor_site_id           => l_payment_term_rec.vendor_site_id,
                p_customer_site_use_id     => l_payment_term_rec.customer_site_use_id,
                p_cust_ship_site_id        => l_payment_term_rec.cust_ship_site_id,
                p_set_of_books_id          => l_payment_term_rec.set_of_books_id,
                p_currency_code            => l_payment_term_rec.currency_code,
                p_rate                     => l_payment_term_rec.rate,
                p_term_start_date          => p_term_start_date,
                p_term_end_date            => p_term_end_date,
                p_sch_str_dt               => l_sch_str_dt,
                p_act_amt                  => l_payment_term_rec.actual_amount,
                p_est_amt                  => l_payment_term_rec.estimated_amount,
                p_index_prd_id             => NULL,
                p_norm_str_dt              => NULL,
                p_lease_change_id          => l_payment_term_rec.lease_change_id);


   pnp_debug_pkg.log('CREATE_PAYMENT_TERM (-) ');

EXCEPTION
   WHEN Invalid_Schd_Date THEN
       x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       pnp_debug_pkg.log('CREATE_PAYMENT_TERM - Others error ..' || sqlerrm);
       fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');

END Create_Payment_Term;


-------------------------------------------------------------------------------
--  PROCEDURE :- ROLLOVER LEASE
--  DESCRIPTION :- This procedure will be called to create a MTM lease
--                 or while rollover of a MTM/ HLD lease. We will query
--                 all current payment terms whose end_Date was the same
--                 as the old lease_Termination_date that are not one time and
--                 create new records for normalized terms and extend the
--                 end date on payment terms .
-- 23-SEP-2002  graghuna o created
-- 13_NOV-2002  graghuna o Removed l_lease_term_date_old + 1 from log, instead
--                         use new variable l_new_term_start_date(BUG#2665720)
-- 22-OCT-2003  Satish   o Fix for BUG# 3201091. Use l_lease_change_id
--                         instead of g_lc_id.
-- 21-Oct-2004  vmmehta  o Bug# 3934425 - Fix for nonmonthly terms
-- 10-JAN-2005  Anand    o Code changes for Retro.
-- 09-OCT-06    Hareesha o Extend RI agreements upon lease extension
--                         due to MTM/HLD.
-- 09-Jan-07    lbala    o Removed code which changes schedule day to value returned
--                         by get_schedule_date
-- 02-APR-07    Hareesha o Bug # 5962831 Added handling for terms expansion,
--                         based on user's choice.
--------------------------------------------------------------------------------
PROCEDURE Rollover_lease (p_lease_id                      IN     NUMBER,
                          p_lease_end_date                IN     DATE,
                          p_new_lea_term_dt               IN     DATE,
                          p_new_lea_comm_dt               IN     DATE,
                          p_mths                          IN     NUMBER,
                          p_extend_ri                     IN     VARCHAR2,
                          p_ten_trm_context               IN     VARCHAR2,
                          x_return_status                 OUT NOCOPY VARCHAR2,
                          x_return_message                OUT NOCOPY VARCHAR2)
IS

CURSOR payment_terms_cursor (p_date DATE) IS
  SELECT *
  FROM   pn_payment_terms_all
  WHERE  lease_id = p_lease_id
  AND    frequency_code <> 'OT'
  AND    index_period_id IS NULL
  AND    end_date = p_date;

CURSOR last_sch_cur (p_term_id  NUMBER) IS
  SELECT MAX(sch.schedule_date)
  FROM   pn_payment_schedules_all sch,
         pn_payment_items_all itm
  WHERE  itm.payment_term_id = p_term_id
  AND    itm.payment_schedule_id = sch.payment_schedule_id
  AND    itm.payment_item_type_lookup_code = 'CASH';

CURSOR get_lease_details IS
  SELECT GREATEST(NVL(plh.lease_extension_end_date, plh.lease_termination_date),
                      plh.lease_termination_date) lease_term_date_old,
         pld.lease_change_id lease_change_id
  FROM   pn_lease_details_history plh,
         pn_lease_details_all pld
  WHERE  pld.lease_change_id = plh.new_lease_change_id
  AND    pld.lease_id = p_lease_id;

INVALID_SCHD_DATE          EXCEPTION;
l_lease_term_date_old      DATE := NULL;
l_payment_term_start_date  DATE := NULL;
l_schd_date                DATE := NULL;
l_schd_day                 NUMBER := NULL;
l_lease_change_id          pn_lease_details.lease_change_id%TYPE;
l_rollover_mode            VARCHAR2(30) := NULL;
l_freq_code                pn_payment_terms_all.frequency_code%TYPE;
l_freq                     NUMBER;
l_no_of_sch                NUMBER;
l_last_sch_date            DATE;
l_duration_in_months       NUMBER;
l_payment_status           pn_payment_schedules_all.payment_status_lookup_code%TYPE;
l_create_term_flag         VARCHAR2(1);

BEGIN

  pnp_debug_pkg.log('ROLLOVER_LEASE +Start+ (+)');
  pnp_debug_pkg.log('ROLLOVER_LEASE IN: p_lease_id           : '||p_lease_id);
  pnp_debug_pkg.log('ROLLOVER_LEASE IN: p_lease_end_date     : '||p_lease_end_date);
  pnp_debug_pkg.log('ROLLOVER_LEASE IN: p_new_lea_term_dt    : '||p_new_lea_term_dt);
  pnp_debug_pkg.log('ROLLOVER_LEASE IN: p_new_lea_comm_dt    : '||p_new_lea_comm_dt);
  pnp_debug_pkg.log('ROLLOVER_LEASE IN: p_mths               : '||p_mths);

  FOR lease IN get_lease_details LOOP
    l_lease_term_date_old := lease.lease_term_date_old;
    l_lease_change_id     := lease.lease_change_id;
  END LOOP;

  add_main(p_lease_id            => p_lease_id,
           p_lease_context       => 'ADDAMD',
           p_new_lea_term_dt     => p_lease_end_date,
           p_new_lea_comm_dt     => p_new_lea_comm_dt,
           p_mths                => p_mths);

   IF NVL(p_ten_trm_context,'N') ='Y' THEN

  FOR l_payment_term_rec IN payment_terms_cursor(l_lease_term_date_old)
  LOOP
    pnp_debug_pkg.log('ROLLOVER - Payment Term Id:  '||l_payment_term_rec.payment_Term_id||
                      ' Normalize: ' ||l_payment_term_rec.normalize);

    l_rollover_mode := NULL;
    l_schd_day      := NULL;
    l_schd_date     := NULL;
    l_payment_term_start_date := l_payment_term_rec.end_date + 1;
    IF PNP_UTIL_FUNC.RETRO_ENABLED THEN
      IF NVL(l_payment_term_rec.normalize,'N')= 'Y' THEN

        pnp_debug_pkg.log('ROLLOVER - Calling create payment term ..');
        l_payment_term_rec.lease_change_id := l_lease_change_id;
        Create_Payment_Term (p_payment_term_rec => l_payment_term_rec,
                             p_lease_end_date    => p_lease_end_date,
                             p_term_start_date   => l_payment_term_start_date,
                             p_term_end_date     => p_lease_end_date,
                             p_new_lea_term_dt   => l_lease_term_date_old,
                             p_new_lea_comm_dt   => p_new_lea_comm_dt,
                             p_mths              => p_mths,
                             x_return_status     => x_return_status,
                             x_return_message    => x_return_message);

      ELSE

        pnp_debug_pkg.log('ROLLOVER - Calling extend_payment_term ..');
        Extend_Payment_Term (p_payment_term_rec => l_payment_term_rec,
                             p_new_lea_comm_dt   => p_new_lea_comm_dt,
                             p_new_lea_term_dt   => l_lease_term_date_old,
                             p_mths              => p_mths,
                             p_new_start_date    => l_payment_term_start_date,
                             p_new_end_date      => p_lease_end_date,
                             x_return_status     => x_return_status,
                             x_return_message    => x_return_message);

        pnp_debug_pkg.log('ROLLOVER - Update end date of payment term..');

        UPDATE pn_payment_terms_all
        SET    end_date = p_lease_end_date,
               lease_status = 'MTM'
        WHERE  payment_term_id = l_payment_term_rec.payment_term_id;

      END IF;

    ELSE /* retro not enabled*/

      l_create_term_flag := 'N';
      l_freq_code := l_payment_term_rec.frequency_code;
      l_freq := get_frequency(p_freq_code => l_freq_code);

      IF l_freq_code <> 'MON' THEN
        pnp_debug_pkg.log('Non-monthly term...');
        -- Check if last period is partial and set start date accordingly
        l_duration_in_months := CEIL(MONTHS_BETWEEN(LAST_DAY(l_payment_term_rec.end_date), FIRST_DAY(l_payment_term_rec.start_date)));

        l_no_of_sch := l_duration_in_months/l_freq;

        /*IF TRUNC(l_no_of_sch) <> l_no_of_sch THEN
          -- Last period is partial, now check if last schedule is approved
          pnp_debug_pkg.log('last period is partial');
          OPEN last_sch_cur(l_payment_term_rec.payment_term_id);
            FETCH last_sch_cur INTO l_last_sch_date;

            select payment_status_lookup_code INTO l_payment_status
            from pn_payment_schedules_all
            where schedule_date = l_last_sch_date
            and lease_id = p_lease_id;

          CLOSE last_sch_cur;

          IF NVL(l_payment_status, 'DRAFT') = 'APPROVED' THEN
            l_create_term_flag := 'Y';
          ELSE
            -- last period is partial and last schedule is draft
            l_payment_term_start_date := l_last_sch_date;
          END IF;
        END IF;*/
      END IF;

      l_schd_date := Get_Schedule_Date (
                            p_lease_id   => l_payment_term_rec.lease_id,
                            p_day        => l_payment_term_rec.schedule_day,
                            p_start_date => l_payment_term_start_date,
                            p_end_date   => p_lease_end_date,
                            p_freq       => l_freq);
      l_schd_day  := TO_NUMBER(TO_CHAR(l_schd_date,'DD'));
      pnp_debug_pkg.log('ROLLOVER - Get_Schedule_Date:  '||l_schd_date||
                        ' l_schd_day: '||l_schd_day);

      IF ((NVL(l_payment_term_rec.normalize,'N')= 'Y') OR (l_create_term_flag = 'Y')) THEN
        l_rollover_mode := 'CREATE_NEW_TERM';
        l_payment_term_rec.parent_term_id := l_payment_term_rec.payment_term_id;
        l_payment_term_rec.index_norm_flag := 'Y';
      ELSE
        IF l_schd_day <> l_payment_term_rec.schedule_day THEN
          l_rollover_mode := 'CREATE_NEW_TERM';
        ELSE
          l_rollover_mode := 'EXTEND_TERM';
        END IF;
      END IF;

      l_payment_term_start_date := l_payment_term_rec.end_date + 1;

      IF l_rollover_mode = 'CREATE_NEW_TERM' THEN

        pnp_debug_pkg.log('ROLLOVER - Calling create payment term ..');
        l_payment_term_rec.lease_change_id := l_lease_change_id;
        Create_Payment_Term (p_payment_term_rec => l_payment_term_rec,
                             p_lease_end_date    => p_lease_end_date,
                             p_term_start_date   => l_payment_term_start_date,
                             p_term_end_date     => p_lease_end_date,
                             p_new_lea_term_dt   => l_lease_term_date_old,
                             p_new_lea_comm_dt   => p_new_lea_comm_dt,
                             p_mths              => p_mths,
                             x_return_status     => x_return_status,
                             x_return_message    => x_return_message);
      ELSIF l_rollover_mode = 'EXTEND_TERM' THEN

        pnp_debug_pkg.log('ROLLOVER - Calling extend_payment_term ..');
        Extend_Payment_Term (p_payment_term_rec => l_payment_term_rec,
                             p_new_lea_comm_dt   => p_new_lea_comm_dt,
                             p_new_lea_term_dt   => l_lease_term_date_old,
                             p_mths              => p_mths,
                             p_new_start_date    => l_payment_term_start_date,
                             p_new_end_date      => p_lease_end_date,
                             x_return_status     => x_return_status,
                             x_return_message    => x_return_message);

        pnp_debug_pkg.log('ROLLOVER - Update end date of payment term..');
        UPDATE pn_payment_terms_all
        SET    end_date = p_lease_end_date,
               lease_status = 'MTM'
        WHERE  payment_term_id = l_payment_term_rec.payment_term_id;
      END IF;

    END IF; /* retro */

  END LOOP; /* end of main loop */

  END IF;

  IF p_extend_ri = 'Y' THEN

     /* extend RI agreement and create/extend periods when lease extended due to MTM/HLD */
     pn_index_rent_periods_pkg.process_main_lease_term_date(
         p_lease_id                     => p_lease_id,
         p_new_main_lease_term_date     => p_lease_end_date,
         p_old_main_lease_term_date     => l_lease_term_date_old,
         p_lease_context                => 'ROLLOVER_RI',
         p_msg                          => x_return_message);
  ELSE
     pn_index_rent_periods_pkg.process_main_lease_term_date(
         p_lease_id                     => p_lease_id,
         p_new_main_lease_term_date     => p_lease_end_date,
         p_old_main_lease_term_date     => l_lease_term_date_old,
         p_lease_context                => 'ROLLOVER',
         p_msg                          => x_return_message);
  END IF;

  pnp_debug_pkg.log('ROLLOVER_LEASE +Start+ (-)');

EXCEPTION
  WHEN INVALID_SCHD_DATE THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

END rollover_lease;

-- Retro Start
--------------------------------------------------------------------------------------------
--  FUNCTION   : adjustment
--  DESCRIPTION: This procedure is being called from add_main when lease_context is 'ADJ'.
--               It creates adjustment entries for the adjustmented term and creates new
--               term and its schedules, items in case of term is 'updated'.
--
--  15-NOV-2004   Mrinal Misra   o Created.
--------------------------------------------------------------------------------------------
PROCEDURE adjustment(p_lease_id           NUMBER,
                     p_lease_context      VARCHAR2,
                     p_new_lea_term_dt    DATE,
                     p_new_lea_comm_dt    DATE,
                     p_mths               NUMBER)
IS

   l_term_hist_id      NUMBER;
   l_adj_type_code     pn_payment_terms_history.adjustment_type_code%TYPE;
   l_norm_str_dt       DATE;
   l_lease_trmn_date   DATE;

   CURSOR get_max_term_hist_cur(p_term_id IN NUMBER) IS
      SELECT term_history_id, adjustment_type_code
      FROM   pn_payment_terms_history
      WHERE  term_history_id = (SELECT max(pth.term_history_id)
                                FROM   pn_payment_terms_history pth
                                WHERE  pth.payment_term_id = p_term_id);

BEGIN

   pnp_debug_pkg.log('ADJUSTMENT - Adjustment of Term - ADJ - Start (+)');
   pnp_debug_pkg.log('ADJUSTMENT IN: p_lease_id          : '||p_lease_id);
   pnp_debug_pkg.log('ADJUSTMENT IN: p_lease_context     : '||p_lease_context);
   pnp_debug_pkg.log('ADJUSTMENT IN: p_new_lea_term_dt   : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('ADJUSTMENT IN: p_new_lea_comm_dt   : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('ADJUSTMENT IN: p_mths              : '||p_mths);

   FOR adj_term_rec IN payment_term_con_cur(p_lease_id)
   LOOP

   pnp_debug_pkg.log('adj_term_rec loop : payment_term_id   : '||adj_term_rec.payment_term_id);

      OPEN get_max_term_hist_cur(adj_term_rec.payment_term_id);
      FETCH get_max_term_hist_cur INTO l_term_hist_id, l_adj_type_code;
      CLOSE get_max_term_hist_cur;

   pnp_debug_pkg.log('adj_term_rec loop : l_term_hist_id   : '||l_term_hist_id);
   pnp_debug_pkg.log('adj_term_rec loop : l_adj_type_code  : '||l_adj_type_code);
   pnp_debug_pkg.log('adj_term_rec loop : lease_change_id  : '||adj_term_rec.lease_change_id);
   pnp_debug_pkg.log('adj_term_rec loop : start_date       : '||adj_term_rec.start_date);
   pnp_debug_pkg.log('adj_term_rec loop : end_date         : '||adj_term_rec.end_date);
   pnp_debug_pkg.log('adj_term_rec loop : schedule_day     : '||adj_term_rec.schedule_day);
   pnp_debug_pkg.log('adj_term_rec loop : actual_amount    : '||adj_term_rec.actual_amount);
   pnp_debug_pkg.log('adj_term_rec loop : frequency        : '||adj_term_rec.frequency_code);
   pnp_debug_pkg.log('Calling pn_retro_adjustment_pkg.create_retro_adjustments ...');

      pn_retro_adjustment_pkg.create_retro_adjustments
                             (p_lease_id      => p_lease_id,
                              p_lease_chg_id  => adj_term_rec.lease_change_id,
                              p_term_id       => adj_term_rec.payment_term_id,
                              p_term_start_dt => adj_term_rec.start_date,
                              p_term_end_dt   => adj_term_rec.end_date,
                              p_term_sch_day  => adj_term_rec.schedule_day,
                              p_term_act_amt  => adj_term_rec.actual_amount,
                              p_term_freq     => adj_term_rec.frequency_code,
                              p_term_hist_id  => l_term_hist_id,
                              p_adj_type_cd   => l_adj_type_code);

   pnp_debug_pkg.log('adj_term_rec loop : normalize            : '||adj_term_rec.normalize);

      IF NVL(adj_term_rec.normalize, 'N') = 'Y' THEN

         l_norm_str_dt := NVL(adj_term_rec.norm_start_date,
                              get_first_item_date(adj_term_rec.payment_term_id));

   pnp_debug_pkg.log('adj_term_rec loop : l_norm_str_dt        : '||l_norm_str_dt);
   pnp_debug_pkg.log('adj_term_rec loop : g_lease_status       : '||g_lease_status);

         IF g_lease_status = 'ACT' THEN
            l_lease_trmn_date := g_new_lea_term_dt;
         ELSE
            l_lease_trmn_date := get_norm_end_date(p_lease_id);
         END IF;

   pnp_debug_pkg.log('adj_term_rec loop : l_lease_trmn_date    : '||l_lease_trmn_date);
   pnp_debug_pkg.log('adj_term_rec loop : vendor_id            : '||adj_term_rec.vendor_id);
   pnp_debug_pkg.log('adj_term_rec loop : vendor_site_id       : '||adj_term_rec.vendor_site_id);
   pnp_debug_pkg.log('adj_term_rec loop : customer_id          : '||adj_term_rec.customer_id);
   pnp_debug_pkg.log('adj_term_rec loop : cust_ship_site_id    : '||adj_term_rec.cust_ship_site_id);
   pnp_debug_pkg.log('adj_term_rec loop : customer_site_use_id : '||adj_term_rec.customer_site_use_id);
   pnp_debug_pkg.log('adj_term_rec loop : set_of_books_id      : '||adj_term_rec.set_of_books_id);
   pnp_debug_pkg.log('adj_term_rec loop : currency_code        : '||adj_term_rec.currency_code);
   pnp_debug_pkg.log('adj_term_rec loop : schedule_day         : '||adj_term_rec.schedule_day);
   pnp_debug_pkg.log('adj_term_rec loop : norm_start_date      : '||adj_term_rec.norm_start_date);
   pnp_debug_pkg.log('adj_term_rec loop : norm_end_date        : '||adj_term_rec.norm_end_date);
   pnp_debug_pkg.log('adj_term_rec loop : rate                 : '||adj_term_rec.rate);
   pnp_debug_pkg.log('Calling pn_norm_renorm_pkg.normalize_renormalize ...');

         pn_norm_renorm_pkg.normalize_renormalize
                           (p_lease_context      => p_lease_context,
                            p_lease_id           => p_lease_id,
                            p_term_id            => adj_term_rec.payment_term_id,
                            p_vendor_id          => adj_term_rec.vendor_id,
                            p_cust_id            => adj_term_rec.customer_id,
                            p_vendor_site_id     => adj_term_rec.vendor_site_id,
                            p_cust_site_use_id   => adj_term_rec.customer_site_use_id,
                            p_cust_ship_site_id  => adj_term_rec.cust_ship_site_id,
                            p_sob_id             => adj_term_rec.set_of_books_id,
                            p_curr_code          => adj_term_rec.currency_code,
                            p_sch_day            => adj_term_rec.schedule_day,
                            p_norm_str_dt        => l_norm_str_dt,
                            p_norm_end_dt        => NVL(adj_term_rec.norm_end_date,
                                                        l_lease_trmn_date),
                            p_rate               => adj_term_rec.rate,
                            p_lease_change_id    => adj_term_rec.lease_change_id);
      END IF;

      l_index := NVL(l_index,0) + 1;
      term_id_tab(l_index) := adj_term_rec.payment_term_id;
   END LOOP;

   pnp_debug_pkg.log('Calling add_main ...');

   add_main(p_lease_id            => p_lease_id,
            p_lease_context       => p_lease_context,
            p_new_lea_term_dt     => g_new_lea_term_dt,
            p_new_lea_comm_dt     => g_new_lea_comm_dt,
            p_mths                => p_mths);

   pnp_debug_pkg.log('ADJUSTMENT - Adjustment of Term - ADJ - Start (-)');

END adjustment;

-- Retro End

--------------------------------------------------------------------------------------------
--  FUNCTION   : FORMAT_AMOUNT
--  DESCRIPTION: Formats Amounts for the Normalization Report shown in Concurrent Log/OutPut
--               Invoked from Schedules_Items above.
--               Args: p_Amount: Some/Any Amount that needs to be formatted
--  20-AUG-2001  Mrinal Misra    o Created.
--------------------------------------------------------------------------------------------
FUNCTION Format_Amount (p_Amount        NUMBER,
                        p_currency_code VARCHAR2)
RETURN   VARCHAR2
IS
BEGIN

   RETURN LPAD(TO_CHAR(p_Amount, Fnd_Currency.Get_Format_Mask(p_currency_code, 20)),12);

EXCEPTION

   WHEN OTHERS THEN
      RAISE;

END Format_Amount;

--------------------------------------------------------------------------------------------
--  PROCEDURE  : NORM_REPORT
--  DESCRIPTION: This procedure creates the Normalization Report in Concurrent Log/OutPut.
--               Args: # of Schedules ovr which the Normalization figures should spread.
--  25-JUN-2001  Mrinal Misra    o Created.
--  28-AUG-2002  ftanudja        o restructured code to use one cursor
--                               o removed variables and refer to cursor directly
--                               o added grouping for currency code, ref bug 2478166
--                               o new strategy for calculating differed liability
--                                 :> separate for each currency
--  21-JAN-2003  ftanudja        o replaced NULL with '0' in csr_get_schedules so that
--                                 the default amounts will be 0. Ref bug 2726862.
--  18-JUL-2003  Satish Tripathi o Fixed for BUG# 3005135. Print the Amount column
--                                 headings depending upon g_lease_class_code.
--  25-JAN-2005  vmmehta         o Fixed for BUG#4142299. Added missing variable l_message.
--  16-FEB-2005  ftanudja        o Made l_message from VARCHAR 30 to 5000. #4189972.
--  30-APR-2007  Prabhakar       o Modified to show the columns properly alligned in
--                                 output report. Bug #5902202.
--------------------------------------------------------------------------------------------
PROCEDURE Norm_Report(p_lease_context VARCHAR2) IS

   CURSOR csr_get_schedules IS
    SELECT MIN(ppi.currency_code) currency_code,
           MIN(pps.schedule_date) schedule_date,
           SUM(DECODE(ppi.payment_item_type_lookup_code, 'CASH',
                 NVL(ppi.actual_amount,0), 0)) cash_amt,
           SUM(DECODE(ppi.payment_item_type_lookup_code, 'CASH',
                 DECODE(ppt.normalize,'Y',NVL(ppi.actual_amount,0), 0), 0)) cash_norm_amt,
           SUM(DECODE(ppi.payment_item_type_lookup_code, 'NORMALIZED',
                 NVL(ppi.actual_amount,0), 0)) norm_amt
    FROM pn_payment_items_all ppi,
         pn_payment_schedules_all pps,
         pn_payment_terms_all ppt
    WHERE ppt.lease_id = g_lease_id
      AND ppt.lease_id = pps.lease_id
      AND pps.payment_schedule_id = ppi.payment_schedule_id
      AND ppt.payment_term_id = ppi.payment_term_id
    GROUP BY ppi.currency_code, pps.schedule_date
    ORDER BY ppi.currency_code, pps.schedule_date;

    l_currency_code                 VARCHAR2(10) := 'qwerty';
    l_def_amt                       NUMBER;
    l_message                       VARCHAR2(5000) := NULL;

BEGIN


   fnd_message.set_name ('PN','PN_SCHIT_DTLS');
   fnd_message.set_token ('ID', g_Lease_Id);
   fnd_message.set_token ('NUM', g_lease_num);
   fnd_message.set_token ('NAME', g_lease_name);
   fnd_message.set_token ('CONTXT', p_lease_context);
   pnp_debug_pkg.put_log_msg(fnd_message.get);
   pnp_debug_pkg.put_log_msg('');

   fnd_message.set_name ('PN','PN_SCHIT_CUR');
   l_message := '               '||fnd_message.get||'       ';
   fnd_message.set_name ('PN','PN_SCHIT_TOT');
   l_message := l_message||fnd_message.get||'       ';
   fnd_message.set_name ('PN','PN_SCHIT_NORM');
   l_message := l_message||fnd_message.get||' ';
   fnd_message.set_name ('PN','PN_SCHIT_ACC');
   l_message := l_message||fnd_message.get||'               ';
   fnd_message.set_name ('PN','PN_SCHIT_ACR');
   l_message := l_message||fnd_message.get;
   pnp_debug_pkg.put_log_msg(l_message);

   IF g_lease_class_code = 'DIRECT' THEN
      fnd_message.set_name ('PN','PN_RICAL_DATE');
      l_message := fnd_message.get||'           ';
      fnd_message.set_name ('PN','PN_SCHIT_CODE');
      l_message := l_message||fnd_message.get||'           ';
      fnd_message.set_name ('PN','PN_SCHIT_CASH');
      l_message := l_message||fnd_message.get||'        ';
      fnd_message.set_name ('PN','PN_SCHIT_CASH');
      l_message := l_message||fnd_message.get||'          ';
      fnd_message.set_name ('PN','PN_SCHIT_EXP');
      l_message := l_message||fnd_message.get||'   ';
      fnd_message.set_name ('PN','PN_SCHIT_ADJ');
      l_message := l_message||fnd_message.get||'  ';
      fnd_message.set_name ('PN','PN_SCHIT_LIA');
      l_message := l_message||fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_message);

   ELSE
      fnd_message.set_name ('PN','PN_RICAL_DATE');
      l_message := fnd_message.get||'           ';
      fnd_message.set_name ('PN','PN_SCHIT_CODE');
      l_message := l_message||fnd_message.get||'           ';
      fnd_message.set_name ('PN','PN_SCHIT_CASH');
      l_message := l_message||fnd_message.get||'        ';
      fnd_message.set_name ('PN','PN_SCHIT_CASH');
      l_message := l_message||fnd_message.get||'          ';
      fnd_message.set_name ('PN','PN_SCHIT_REV');
      l_message := l_message||fnd_message.get||'   ';
      fnd_message.set_name ('PN','PN_SCHIT_ADJ');
      l_message := l_message||fnd_message.get||'  ';
      fnd_message.set_name ('PN','PN_SCHIT_AST');
      l_message := l_message||fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_message);
   END IF;

   pnp_debug_pkg.put_log_msg
   ('============= '
     ||' ============= '
     ||' ========== '
     ||' ========== '
     ||' ========== '
     ||' ========== '
     ||' ========== '
   );

   FOR sch IN csr_get_schedules LOOP

       IF l_currency_code <> sch.currency_code THEN
          IF l_currency_code <> 'qwerty' THEN
             pnp_debug_pkg.put_log_msg('');
          END IF;
          l_currency_code := sch.currency_code;
          l_def_amt := 0;
       END IF;

       l_def_amt := l_def_amt + sch.norm_amt - sch.cash_norm_amt;

       pnp_debug_pkg.put_log_msg(TO_CHAR(sch.schedule_date)
                                ||lpad(sch.currency_code,19)
                                ||Format_Amount(sch.cash_amt, sch.currency_code)
                                ||Format_Amount(sch.cash_norm_amt, sch.currency_code)
                                ||Format_Amount(sch.norm_amt, sch.currency_code)
                                ||Format_Amount(sch.norm_amt - sch.cash_norm_amt, sch.currency_code)
                                ||Format_Amount(l_def_amt, sch.currency_code)
                               );
   END LOOP;
END;

-- Retro Start
--------------------------------------------------------------------------------
--
--  NAME         : retro_rec_impact_report
--  DESCRIPTION  : Prints a list of agreement name, number of the Recovery
--                 Agreements whose lines are affected by Retro
--  PURPOSE      : Inform the user of the possible impact of Retro on Recovery
--                 Agreements
--  INVOKED FROM : Schedules and items
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  12-NOV-2004   Kiran Hegde   o Created
-- 15-JUL-05  hareesha o Bug 4284035 - Replaced pn_rec_agr_lines with _ALL table.
--------------------------------------------------------------------------------
PROCEDURE retro_rec_impact_report IS

/* -- CURSORS -- */
/* Get all the possibly affected recovery agreements
   for term with changed dates */
CURSOR get_agreements_cur(p_term_id IN NUMBER) IS
  SELECT  agr.rec_agreement_name
         ,agr.rec_agreement_num
    FROM  pn_rec_agreements_all agr
         ,pn_rec_agr_lines_all  line
         ,pn_payment_terms_all  term
   WHERE  agr.lease_id = g_lease_id
     AND  agr.rec_agreement_id = line.rec_agreement_id
     AND  term.payment_term_id = p_term_id
     AND  line.purpose = term.payment_purpose_code
     AND  line.type = term.payment_term_type_code
     AND  line.start_date <= term.end_date
     AND  line.end_date >= term.start_date;

BEGIN
   pnp_debug_pkg.log('retro_rec_impact_report - (+)');

   IF term_id_tab.count > 0 THEN
      pnp_debug_pkg.put_log_msg
      ('===========================================================================');
      fnd_message.set_name('PN', 'PN_RETRO_RECAGR_REPORT');
      pnp_debug_pkg.put_log_msg(fnd_message.get);
      pnp_debug_pkg.put_log_msg('');

      FOR i in 1..term_id_tab.count LOOP
         FOR rec IN get_agreements_cur(term_id_tab(i)) LOOP

           fnd_message.set_name('PN', 'PN_RECAGR_NAME_NUM');
           fnd_message.set_token('REC_AGR_NAME', rec.rec_agreement_name);
           fnd_message.set_token('REC_AGR_NUM', rec.rec_agreement_num);

           pnp_debug_pkg.put_log_msg(fnd_message.get);
           pnp_debug_pkg.put_log_msg('');

         END LOOP;
      END LOOP;

      pnp_debug_pkg.put_log_msg
      ('===========================================================================');
   END IF;

   pnp_debug_pkg.log('retro_rec_impact_report - (-)');
EXCEPTION

  WHEN others THEN
    RAISE;

END retro_rec_impact_report;

--------------------------------------------------------------------------------
--
--  NAME         : retro_vr_impact_report
--  DESCRIPTION  : Prints a list of VR Numbers that have abatements which will
--                 be affected due to change in terms.
--  PURPOSE      : Inform the user of the possible impact of Retro on VR
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  12-NOV-2004   Kiran Hegde   o Created
--------------------------------------------------------------------------------
PROCEDURE retro_vr_impact_report IS

/* -- CURSORS -- */

CURSOR get_vr_cur(p_term_id IN NUMBER) IS
  SELECT  pvr.rent_num
    FROM  pn_var_rents_all      pvr
         ,pn_var_rent_inv_all   pvri
         ,pn_var_abatements_all pva
         ,pn_payment_terms_all  ppt
   WHERE  ppt.payment_term_id = p_term_id
     AND  pva.payment_term_id = ppt.payment_term_id
     AND  pvri.var_rent_inv_id = pva.var_rent_inv_id
     AND  pvri.invoice_date BETWEEN ppt.start_date
                                AND ppt.end_date
     AND  pvr.var_rent_id = pvri.var_rent_id;

BEGIN
   pnp_debug_pkg.log('retro_vr_impact_report - (+)');

   IF term_id_tab.count > 0 THEN
      pnp_debug_pkg.put_log_msg
      ('===========================================================================');
      fnd_message.set_name('PN', 'PN_RETRO_VARENT_REPORT');
      pnp_debug_pkg.put_log_msg(fnd_message.get);
      pnp_debug_pkg.put_log_msg('');

      FOR i in 1..term_id_tab.count LOOP
         FOR vr IN get_vr_cur(term_id_tab(i)) LOOP

           fnd_message.set_name('PN', 'PN_VARENT_NUM');
           fnd_message.set_token('VAR_RENT_NUM', vr.rent_num);

           pnp_debug_pkg.put_log_msg(fnd_message.get);
           pnp_debug_pkg.put_log_msg('');

         END LOOP;
      END LOOP;

      pnp_debug_pkg.put_log_msg
      ('===========================================================================');
   END IF;

   pnp_debug_pkg.log('retro_vr_impact_report - (-)');
EXCEPTION

  WHEN others THEN
    RAISE;

END retro_vr_impact_report;
-- Retro End


-------------------------------------------------------------------------------
--  PROCEDURE    : UPDATE_TERM_DATES
--  DESCRIPTION  : This procedure updates the term dates and amount for
--                 contracted terms
--  INVOKED FROM : mini_retro_contraction
--  ARGUMENTS    : IN : p_new_lea_term_start_dt, p_new_lea_term_end_dt,
--                      p_lease_id, p_payment_term_id, p_amount
--  HISTORY      :
-- 01-AUG-05  piagrawa  o Created for mini-retro
-- 24-NOV-05  Kiran     o Round amounts befor insert/uptdate into terms OR items
--------------------------------------------------------------------------------
PROCEDURE update_term_dates(p_new_lea_term_start_dt DATE DEFAULT NULL,
                            p_new_lea_term_end_dt   DATE,
                            p_lease_id              NUMBER,
                            p_payment_term_id       NUMBER,
                            p_amount                NUMBER DEFAULT NULL)
IS

   l_precision     NUMBER;
   l_ext_precision NUMBER;
   l_min_acct_unit NUMBER;
   l_act_amount    NUMBER;

   CURSOR currency_cur IS
      SELECT currency_code
      FROM pn_payment_terms_all
      WHERE payment_term_id = p_payment_term_id;

BEGIN
   pnp_debug_pkg.log('UPDATE TERMS +Start+ (+)');

   pnp_debug_pkg.log('MINI-RETRO - CON - MAIN - Updating start/end date of Payment Terms');

   FOR rec IN currency_cur LOOP
      fnd_currency.get_info (  currency_code  => rec.currency_code
                              ,precision     => l_precision
                              ,ext_precision => l_ext_precision
                              ,min_acct_unit => l_min_acct_unit);
   END LOOP;

   IF p_amount IS NOT NULL THEN
      l_act_amount := ROUND(p_amount, l_precision);
   ELSE
      l_act_amount := TO_NUMBER(NULL);
   END IF;

   /* Updates the term with new term start/end date */
   UPDATE pn_payment_terms_all
   SET start_date = NVL(p_new_lea_term_start_dt, start_date),
       end_date = p_new_lea_term_end_dt,
       actual_amount = NVL(l_act_amount, actual_amount),
       last_update_date = SYSDATE,
       last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
       last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
   WHERE payment_term_id = p_payment_term_id;

   pnp_debug_pkg.log('UPDATE TERMS +Start+ (-)');
END update_term_dates;


-------------------------------------------------------------------------------
--  PROCEDURE    : UPDATE_CASH_ITEM
--  DESCRIPTION  : It updates last Cash Item by updating table
--                 PN_PAYMENT_ITEMS_ALL with new adjustment amount
--  NOTE         : It is overloaded for mini retro.
--  INVOKED FROM : contract_pay_term_mini_retro
--  ARGUMENTS    : IN : p_term_id, p_schedule_dt, p_act_amt
--  HISTORY      :
-- 01-AUG-05  piagrawa  o Created for mini-retro
-- 24-NOV-05  Kiran     o Round amounts befor insert/uptdate into terms OR items.
-- 24-jan-06  piagrawa  o Bug#4890236 - Did handling to add the adjustment
--                        amount to the existing amount of the cash item.
--------------------------------------------------------------------------------
PROCEDURE  update_cash_item( p_item_id  NUMBER
                            ,p_term_id  NUMBER
                            ,p_sched_id NUMBER
                            ,p_act_amt  NUMBER)
IS

   l_precision      NUMBER;
   l_ext_precision  NUMBER;
   l_min_acct_unit  NUMBER;
   l_exist_amount   NUMBER;
   l_act_amount     NUMBER;
   l_est_amount     NUMBER;
   l_adj_amount     NUMBER;

   CURSOR currency_cur IS
      SELECT currency_code
      FROM pn_payment_terms_all
      WHERE payment_term_id = p_term_id;

BEGIN
   pnp_debug_pkg.log('update_cash_item +Start+ (-)');

   FOR rec IN currency_cur LOOP
      fnd_currency.get_info( currency_code => rec.currency_code
                            ,precision     => l_precision
                            ,ext_precision => l_ext_precision
                            ,min_acct_unit => l_min_acct_unit);
   END LOOP;

   IF p_item_id IS NOT NULL THEN

      UPDATE pn_payment_items_all
      SET    actual_amount = ROUND(actual_amount + NVL(p_act_amt,0), l_precision),
             export_currency_amount = ROUND(actual_amount + NVL(p_act_amt,0), l_precision),
             last_update_date = SYSDATE,
             last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
             last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
      WHERE  payment_item_id  = p_item_id;

   ELSE

      UPDATE pn_payment_items_all
      SET    actual_amount = ROUND(actual_amount + NVL(p_act_amt,0), l_precision),
             export_currency_amount = ROUND(actual_amount + NVL(p_act_amt,0), l_precision),
             last_update_date = SYSDATE,
             last_updated_by  = NVL(fnd_profile.value('USER_ID'),0),
             last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
      WHERE  payment_item_id  = (SELECT ppi.payment_item_id
                                 FROM   pn_payment_items_all ppi,
                                        pn_payment_schedules_all pps
                                 WHERE  ppi.payment_term_id = p_term_id
                                 AND    ppi.payment_item_type_lookup_code = 'CASH'
                                 AND    pps.payment_schedule_id = ppi.payment_schedule_id
                                 AND    pps.payment_status_lookup_code = 'DRAFT'
                                 AND    pps.payment_schedule_id = p_sched_id);

   END IF;

   pnp_debug_pkg.log('update_cash_item +End+ (-)');

EXCEPTION
   WHEN OTHERS THEN RAISE;

END update_cash_item;

--------------------------------------------------------------------------------
--  PROCEDURE    : calculate_cash_item
--  DESCRIPTION  : It calculates the new adjustment amount as
--                 adjustment_amount = amount_due_to_term - amount_approved
--  INVOKED FROM : contract_pay_term_mini_retro
--  ARGUMENTS    : IN : p_term_id, p_term_str_dt, p_term_end_dt, p_act_amt
--                      p_freq_code, p_schedule_day
--  HISTORY      :
--  01-AUG-05 piagrawa  o Created for mini-retro
--  24-jan-06 piagrawa  o Bug#4890236 - Did handling to calculate the adjustment
--                        amount as amount due to new term - amount due
--                        to old term
--------------------------------------------------------------------------------
FUNCTION calculate_cash_item (p_term_id   NUMBER,
                              p_sched_tbl pn_retro_adjustment_pkg.payment_item_tbl_type)
RETURN NUMBER
IS

   l_cash_act_amt         NUMBER;
   l_cash_est_amt         NUMBER;
   l_amt_due_to_term      NUMBER;
   l_amt_due_to_old_term  NUMBER;
   l_payment_item_id      pn_payment_items_all.payment_item_id%TYPE;

   CURSOR total_amt_old_term_cur IS
      SELECT SUM(ppi.actual_amount) AS total_amount
      FROM  pn_payment_items_all ppi
      WHERE ppi.payment_term_id = p_term_id
      AND   ppi.payment_item_type_lookup_code = 'CASH';

BEGIN

   pnp_debug_pkg.log('calculate_cash_item +Start+ (+)');

   /* update the cash amount for the schedule */
   l_amt_due_to_term := 0;

   /* iterating through table to calculate the total amount due to term */
   IF p_sched_tbl.COUNT > 0 THEN

      FOR i IN 0 .. p_sched_tbl.COUNT - 1 LOOP
         l_amt_due_to_term := l_amt_due_to_term + p_sched_tbl(i).amount ;
      END LOOP;

   END IF;

   /* Fetching the total amount approved for the term */
   l_amt_due_to_old_term := 0;

   FOR rec IN total_amt_old_term_cur LOOP
      l_amt_due_to_old_term := rec.total_amount;
   END LOOP;

   pnp_debug_pkg.log('amount due to new term .........' || l_amt_due_to_term);
   pnp_debug_pkg.log('amount due to old term .........' || l_amt_due_to_old_term);

   l_cash_act_amt := l_amt_due_to_term - NVL(l_amt_due_to_old_term, 0);

   pnp_debug_pkg.log('Returning amount .........' || l_cash_act_amt);

   pnp_debug_pkg.log('calculate_cash_item -End- (-)');

   RETURN l_cash_act_amt;

EXCEPTION
   WHEN OTHERS THEN
      RAISE ;

END calculate_cash_item;


-------------------------------------------------------------------------------
--  PROCEDURE    : DELETE_TERM
--  DESCRIPTION  : Deletes a term
--  INVOKED FROM : mini_retro_contraction
--  ARGUMENTS    : IN : p_payment_term_id
--  HISTORY      :
--  01-AUG-05   piagrawa  o Created for mini-retro
-------------------------------------------------------------------------------
PROCEDURE delete_term(p_payment_term_id   NUMBER)
AS
BEGIN
   pnp_debug_pkg.log('Delete term start (+)');

   pnp_debug_pkg.log('Deleting all items for term ....'||p_payment_term_id);
   DELETE pn_payment_items_all
   WHERE  payment_term_id = p_payment_term_id;

   pnp_debug_pkg.log('Deleting term ....'||p_payment_term_id);
   DELETE pn_payment_terms_all
   WHERE  payment_term_id = p_payment_term_id;


   pnp_debug_pkg.log('Delete term End (-)');

EXCEPTION
   WHEN OTHERS THEN
      RAISE ;
END delete_term;


--------------------------------------------------------------------------------
--  PROCEDURE    : contract_pay_term_mini_retro
--  DESCRIPTION  : This procedure is used to contract a given term. If term is
--                 contracted beyond approved schedules then adjustment is made
--                 else the last draft cash item is updated with the required
--                 amount. For normalized items , renormalization is done.
--  INVOKED FROM : schedules_items, MINI_RETRO_CONTRACTION
--  ARGUMENTS    : IN : p_lease_id, p_lease_context, p_new_lea_term_dt,
--                      p_new_lea_comm_dt, p_mths, p_normalize, p_adjustment,
--                      p_payment_term_id
--  HISTORY      :
--  01-AUG-05 piagrawa  o Created for mini-retro
--  24-JAN-06 hkulkarn  o Bug 4956314 : Create New Draft Schedule
--                        [in find_schedule]based on the Context Passed. If its
--                        'CON' Lease Contraction, use the lase schedule for new
--                         Lease  Termination Date, otherwise use last schedule
--                         for Term Termination.
--  19-jan-06 piagrawa  o Bug#4931780 - Modified signature and added a check
--                        before renormalizing the terms.
--  04-APR-06  piagrawa  o Bug#5107134 - modified delete statement to include
--                          status 'ON_HOLD'
--  02-JAN-09  acprakas o Bug#7016892. Modified code to update changed_flag
--                                 of pn_payment_terms_all only when lease context is
--                                 CONTERM.
--  15-JUL-09  jsundara  o Bug8608490 - if lease context is CONTERM,
--                         get last cash sched date as term end date.
--  14-OCT-09  amehrotr  o Bug#9019575. Modified to use the already determined
--                         normalization start date
--------------------------------------------------------------------------------

PROCEDURE contract_pay_term_mini_retro (p_lease_id           NUMBER,
                                        p_lease_context      VARCHAR2,
                                        p_new_lea_term_dt    DATE,
                                        p_new_lea_comm_dt    DATE,
                                        p_mths               NUMBER,
                                        p_normalize          VARCHAR2,
                                        p_adjustment         VARCHAR2,
                                        p_payment_term_id    NUMBER,
                                        p_cutoff_date        DATE,
                                        p_add_main           VARCHAR2)
IS

   l_frequency                  NUMBER;
   l_sch_str_dt                 DATE := NULL;
   l_sch_end_dt                 DATE;
   l_lst_cash_sch_dt            DATE;
   l_norm_str_dt                DATE;
   l_lease_termination_date     DATE;
   l_active_lease_change_id     pn_lease_details.lease_change_id%TYPE;
   l_payment_schedule_id        pn_payment_items_all.payment_schedule_id%TYPE;
   l_payment_item_id            pn_payment_items_all.payment_item_id%TYPE;
   l_payment_status_lookup_code pn_payment_schedules_all.payment_status_lookup_code%TYPE;
   l_adjustment                 VARCHAR2(1);
   l_adj_amount                 NUMBER;

   l_sched_tbl                  pn_retro_adjustment_pkg.payment_item_tbl_type;
   l_last_sched_draft           VARCHAR2(1);
   l_count                      NUMBER; -- Added for Bug 6154106.
   l_amd_comn_date              DATE; /* 7149537 */
 	 l_sch_dt_1                   DATE; /* 7149537 */
 	 l_nrm_st_dt                  DATE; /* 7149537 */
 	 l_sch_dy                     NUMBER; /* 9231686 */

   /* find id CASH item exists for a schedule */
   CURSOR cash_item_exist_cur(p_sched_id NUMBER) IS
      SELECT payment_item_id
      FROM   pn_payment_items_all
      WHERE  payment_item_type_lookup_code = 'CASH'
      AND    payment_schedule_id = p_sched_id
      AND    payment_term_id = p_payment_term_id;

   /* check if exists draft schedule for the given date for a lease */
   CURSOR draft_schedule_exists_cur (p_sched_date DATE) IS
      SELECT pps.payment_schedule_id
      FROM   pn_payment_schedules_all pps
      WHERE  pps.schedule_date = p_sched_date
      AND    pps.lease_id = p_lease_id
      AND    pps.payment_status_lookup_code = 'DRAFT';

	  CURSOR get_drf_sch_date(p_payment_term_id NUMBER) IS
 	    SELECT distinct schedule_date
 	    FROM   pn_payment_items_all ppi,
 	            pn_payment_schedules_all pps
 	    WHERE  ppi.payment_term_id =  p_payment_term_id
 	    AND    ppi.payment_item_type_lookup_code = 'NORMALIZED'
 	    AND    pps.payment_schedule_id = ppi.payment_schedule_id
 	    AND    pps.payment_status_lookup_code <>  'DRAFT'
 	    and schedule_date >= pn_schedules_items.FIRST_DAY(l_amd_comn_date)
   and    schedule_date <=  (SELECT lease_termination_date from
   pn_lease_details_all where lease_id = p_lease_id );   /*  7149537 */

BEGIN
select NVL(change_commencement_date,lease_commencement_date )
INTO l_amd_comn_date
from pn_lease_changes_all pc, pn_lease_details_all pd
where pc.lease_id =  p_lease_id
and pd.lease_id = pc.lease_id
and pc.lease_change_id = pd.lease_change_id; /*  9231686 */

      select schedule_day
      INTO   l_sch_dy
      from pn_payment_terms_all
      where payment_term_id = p_payment_term_id; /* 9231686 */


            IF  norm_st_dt_rec_tbl(l_sch_dy) is not null
            THEN
                   pnp_debug_pkg.log('pn_schedules_items.g_norm_dt_avl : '||pn_schedules_items.g_norm_dt_avl);
                   pn_schedules_items.g_norm_dt_avl := 'Y';
            ELSE
                   pn_schedules_items.g_norm_dt_avl := NULL;

            END IF;

    IF pn_schedules_items.g_norm_dt_avl IS NULL THEN  /* 9231686 */
    SELECT NVL(First_Day(MIN(pps.schedule_date)),l_amd_comn_date)
    into   l_nrm_st_dt
    FROM   pn_payment_schedules_all pps
    WHERE  pps.lease_id = p_lease_id
    AND    pps.payment_status_lookup_code = 'DRAFT'
    AND    TO_CHAR(pps.schedule_date,'DD') = l_sch_dy ;

        norm_st_dt_rec_tbl(l_sch_dy) := l_nrm_st_dt;
    ELSE
        l_nrm_st_dt :=  norm_st_dt_rec_tbl(l_sch_dy);
        pnp_debug_pkg.log('l_first_draft_sch: '||l_nrm_st_dt); /* 9231686 */
    END IF;



   pnp_debug_pkg.log('CONTRACT_PAY_TERM_MINI_RETRO IN: l_nrm_st_dt        : '||l_nrm_st_dt);
   IF l_amd_comn_date > l_nrm_st_dt THEN
       l_amd_comn_date := l_nrm_st_dt;
   END IF;


   pnp_debug_pkg.log('CONTRACT_PAY_TERM_MINI_RETRO - Contraction of Payment Term - CONTERM +Start+ (+)');
   pnp_debug_pkg.log('CONTRACT_PAY_TERM_MINI_RETRO IN: p_lease_id        : '||p_lease_id);
   pnp_debug_pkg.log('CONTRACT_PAY_TERM_MINI_RETRO IN: p_lease_context   : '||p_lease_context);
   pnp_debug_pkg.log('CONTRACT_PAY_TERM_MINI_RETRO IN: p_new_lea_term_dt : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('CONTRACT_PAY_TERM_MINI_RETRO IN: p_new_lea_comm_dt : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('CONTRACT_PAY_TERM_MINI_RETRO IN: p_mths            : '||p_mths);

   IF g_lease_status = 'ACT' THEN
      l_lease_termination_date := g_new_lea_term_dt;
   ELSE
      l_lease_termination_date := Get_Norm_End_Date(p_lease_id);
   END IF;

   l_active_lease_change_id := Get_Lease_Change_Id(p_lease_id);

   FOR pay_term_con_cur IN payment_term_con_cur_retro(p_lease_id, p_payment_term_id )
   LOOP

      pnp_debug_pkg.log('CONTRACT_PAY_TERM_MINI_RETRO - Term ID : '
                         ||TO_CHAR(pay_term_con_cur.payment_term_id)
                         ||' , Term End Date: '||pay_term_con_cur.end_date);

      IF p_adjustment = 'Y' THEN

         /* delete items beyond the end date */
         DELETE pn_payment_items_all
         WHERE payment_schedule_id IN
              (SELECT payment_schedule_id
               FROM   pn_payment_schedules_all
               WHERE  lease_id = p_lease_id
               AND    schedule_date > pay_term_con_cur.end_date
               AND    payment_status_lookup_code IN ('DRAFT', 'ON_HOLD'))
         AND payment_term_id = pay_term_con_cur.payment_term_id;

         l_sched_tbl.DELETE;

         pn_retro_adjustment_pkg.create_virtual_schedules
            (p_start_date => pay_term_con_cur.start_date,
             p_end_date   => pay_term_con_cur.end_date,
             p_sch_day    => pay_term_con_cur.schedule_day,
             p_amount     => nvl(pay_term_con_cur.actual_amount,pay_term_con_cur.estimated_amount), /*5259155*/
             p_term_freq  => pay_term_con_cur.frequency_code,
             p_payment_term_id => pay_term_con_cur.payment_term_id, -- Bug 7570052
             x_sched_tbl  => l_sched_tbl);

         l_adj_amount := calculate_cash_item
                           (p_term_id   => pay_term_con_cur.payment_term_id,
                            p_sched_tbl => l_sched_tbl);

         IF l_adj_amount <> 0 THEN

            l_last_sched_draft := 'N';

            IF p_lease_context = 'CON' THEN

               FOR rec IN draft_schedule_exists_cur(l_sched_tbl(l_sched_tbl.LAST).schedule_date)
               LOOP
                  l_last_sched_draft := 'Y';
                  l_payment_schedule_id := rec.payment_schedule_id;
                  l_lst_cash_sch_dt := l_sched_tbl(l_sched_tbl.LAST).schedule_date;
               END LOOP;

               IF l_last_sched_draft = 'N' THEN

                  l_lst_cash_sch_dt
                     := TO_DATE(TO_CHAR(pay_term_con_cur.schedule_day)
                                 ||'/'||TO_CHAR(pay_term_con_cur.end_date,'MM/YYYY')
                               ,'DD/MM/YYYY');

                  pn_retro_adjustment_pkg.find_schedule( p_lease_id
                                                        ,l_active_lease_change_id
                                                        ,p_payment_term_id
                                                        ,l_lst_cash_sch_dt
                                                        ,l_payment_schedule_id);
               END IF;

            ELSIF p_lease_context = 'CONTERM' THEN

               FOR rec IN draft_schedule_exists_cur(l_sched_tbl(l_sched_tbl.LAST).schedule_date)
               LOOP
                  l_last_sched_draft := 'Y';
                  l_payment_schedule_id := rec.payment_schedule_id;
                  l_lst_cash_sch_dt := l_sched_tbl(l_sched_tbl.LAST).schedule_date;
               END LOOP;

               IF l_last_sched_draft = 'N' THEN

                   l_lst_cash_sch_dt
                     := TO_DATE(TO_CHAR(pay_term_con_cur.schedule_day)
                                 ||'/'||TO_CHAR(pay_term_con_cur.end_date,'MM/YYYY')
                               ,'DD/MM/YYYY'); /* 8608490 */

                  pn_retro_adjustment_pkg.find_schedule( p_lease_id
                                                        ,l_active_lease_change_id
                                                        ,p_payment_term_id
                                                        ,l_lst_cash_sch_dt
                                                        ,l_payment_schedule_id);

               END IF; /* IF l_last_sched_draft = 'N' */

            END IF; /* IF p_lease_context */

            l_payment_item_id := NULL;
            FOR rec IN cash_item_exist_cur(l_payment_schedule_id) LOOP
               l_payment_item_id := rec.payment_item_id;
            END LOOP;

            IF l_payment_item_id IS NOT NULL THEN
               update_cash_item( p_item_id  => l_payment_item_id
                                ,p_term_id  => p_payment_term_id
                                ,p_sched_id => l_payment_schedule_id
                                ,p_act_amt  => l_adj_amount);

            ELSE
               create_cash_items(p_est_amt           => l_adj_amount,
                                 p_act_amt           => l_adj_amount,
                                 p_sch_dt            => l_lst_cash_sch_dt,
                                 p_sch_id            => l_payment_schedule_id,
                                 p_term_id           => p_payment_term_id,
                                 p_vendor_id         => pay_term_con_cur.vendor_id,
                                 p_cust_id           => pay_term_con_cur.customer_id,
                                 p_vendor_site_id    => pay_term_con_cur.vendor_site_id,
                                 p_cust_site_use_id  => pay_term_con_cur.customer_site_use_id,
                                 p_cust_ship_site_id => pay_term_con_cur.cust_ship_site_id,
                                 p_sob_id            => pay_term_con_cur.set_of_books_id,
                                 p_curr_code         => pay_term_con_cur.currency_code,
                                 p_rate              => pay_term_con_cur.rate);

            END IF; /* IF l_payment_item_id IS NOT NULL */

         END IF;

      END IF; /* p_adjustment = 'Y' */

      IF p_normalize = 'Y' THEN


IF  nvl (pay_term_con_cur.norm_end_Date, g_new_lea_term_dt) > p_cutoff_date  THEN

      IF  NVL(FIRST_DAY(pay_term_con_cur.norm_start_date), FIRST_DAY(p_new_lea_comm_dt)) = FIRST_DAY(p_new_lea_comm_dt) /* 9231686 */
      THEN
         pnp_debug_pkg.log('NORMALIZE_RENORMALIZE - j2');
         l_norm_str_dt := l_amd_comn_date; /* 7561833 */
      ELSE
         pnp_debug_pkg.log('NORMALIZE_RENORMALIZE - j1');
         l_norm_str_dt := norm_st_dt_rec_tbl(l_sch_dy); /* Bug 9019575 */
         --l_norm_str_dt := NVL(FIRST_DAY(pay_term_con_cur.norm_start_date),l_amd_comn_date); /* 9231686  */
      END iF;
      pnp_debug_pkg.log('NORMALIZE_RENORMALIZE - l_amd_comn_dt-1 :=: '||TO_CHAR(l_amd_comn_date));
      pnp_debug_pkg.log('NORMALIZE_RENORMALIZE - l_norm_str_dt-1 :=: '||TO_CHAR(l_norm_str_dt));

              IF l_amd_comn_date > l_norm_str_dt THEN  /* 9457938  */
                  l_amd_comn_date := l_norm_str_dt;
              END IF;

/* Added for Bug 6154106*/

 l_lst_cash_sch_dt := TO_DATE(TO_CHAR(pay_term_con_cur.schedule_day)
                               ||'/'||TO_CHAR(g_new_lea_term_dt,'MM/YYYY')
                             ,'DD/MM/YYYY');

            DELETE pn_payment_items_all
            WHERE payment_schedule_id IN
                 (SELECT payment_schedule_id
                  FROM   pn_payment_schedules_all
                  WHERE  lease_id = p_lease_id
                  AND    schedule_date > l_lst_cash_sch_dt
                  AND    payment_status_lookup_code IN ('DRAFT', 'ON_HOLD'))
            AND payment_term_id = pay_term_con_cur.payment_term_id;
            l_count := 0;
--  Copied from PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE
            SELECT count(*) into l_count
                FROM   pn_payment_schedules_all pps,
                       pn_payment_items_all ppi
                WHERE  pps.lease_id = p_lease_id
                AND    pps.schedule_date BETWEEN PN_SCHEDULES_ITEMS.FIRST_DAY(NVL(l_amd_comn_date,l_norm_str_dt))  /* 7149537 */
                                             AND LAST_DAY(g_new_lea_term_dt)
                AND    pps.payment_status_lookup_code in ( 'DRAFT', 'ON_HOLD' )
                AND    TO_CHAR(pps.schedule_date,'DD') = pay_term_con_cur.schedule_day
                AND    ppi.PAYMENT_SCHEDULE_ID(+) = pps.PAYMENT_SCHEDULE_ID
                AND    ppi.PAYMENT_TERM_ID(+) = pay_term_con_cur.payment_term_id
                AND    ppi.PAYMENT_ITEM_TYPE_LOOKUP_CODE(+) = 'CASH'
                AND    ppi.LAST_ADJUSTMENT_TYPE_CODE IS NULL
                ORDER BY pps.schedule_date;

            IF l_count = 0 THEN
                l_lst_cash_sch_dt
                   := TO_DATE(TO_CHAR(pay_term_con_cur.schedule_day)
                               ||'/'||TO_CHAR(g_new_lea_term_dt,'MM/YYYY')
                             ,'DD/MM/YYYY');

                pn_retro_adjustment_pkg.find_schedule( p_lease_id
                                                       ,l_active_lease_change_id
                                                       ,p_payment_term_id
                                                       ,l_lst_cash_sch_dt
                                                       ,l_payment_schedule_id);
            END IF;
/* End Bug 6154106 */

pnp_debug_pkg.log('NORMALIZE_RENORMALIZE - find draft schedule for '||p_payment_term_id||' with ACD '||l_amd_comn_date);

FOR rec in get_drf_sch_date(p_payment_term_id) LOOP
 	            l_sch_dt_1 := rec.schedule_date;
 	            pn_retro_adjustment_pkg.find_schedule( p_lease_id
 	                                                        ,l_active_lease_change_id
 	                                                        ,p_payment_term_id
 	                                                        ,l_sch_dt_1
 	                                                        ,l_payment_schedule_id);
 	            END LOOP;     /* 7149537 */
            PN_NORM_RENORM_PKG.NORMALIZE_RENORMALIZE
               (p_lease_context      => p_lease_context,
                p_lease_id           => p_lease_id,
                p_term_id            => pay_term_con_cur.payment_term_id,
                p_vendor_id          => pay_term_con_cur.vendor_id,
                p_cust_id            => pay_term_con_cur.customer_id,
                p_vendor_site_id     => pay_term_con_cur.vendor_site_id,
                p_cust_site_use_id   => pay_term_con_cur.customer_site_use_id,
                p_cust_ship_site_id  => pay_term_con_cur.cust_ship_site_id,
                p_sob_id             => pay_term_con_cur.set_of_books_id,
                p_curr_code          => pay_term_con_cur.currency_code,
                p_sch_day            => pay_term_con_cur.schedule_day,
                p_norm_str_dt        => l_amd_comn_date,     /* 7149537 */
                p_norm_end_dt        => l_lease_termination_date,
                p_rate               => pay_term_con_cur.rate,
                p_lease_change_id    => pay_term_con_cur.lease_change_id);

         END IF;

      END IF; /* IF p_normalize = 'Y' */

      IF p_lease_context = 'CONTERM' THEN
          UPDATE pn_payment_terms_all
          SET    changed_flag = 'N'
          WHERE  payment_term_id = pay_term_con_cur.payment_term_id;
      END IF;

   END LOOP;

   /* Now create the schedules and items for the new terms that have been added along with
      the contraction of the main lease */
   IF p_add_main = 'Y' THEN

     add_main(p_lease_id            => p_lease_id,
              p_lease_context       => 'ADDEDT',
              p_new_lea_term_dt     => p_new_lea_term_dt,
              p_new_lea_comm_dt     => p_new_lea_comm_dt,
              p_mths                => p_mths);

   END IF;

   pnp_debug_pkg.log('CONTRACT_PAY_TERM - Contraction of Payment Term - CONTERM -End- (+)');

EXCEPTION
   WHEN OTHERS THEN RAISE ;

END contract_pay_term_mini_retro;


-------------------------------------------------------------------------------
--  PROCEDURE    : MINI_RETRO_CONTRACTION
--  DESCRIPTION  : This procedure is used to contract a given lease.If lease is
--                 contracted beyond approved schedules then adjustment is made
--                 else the last draft cash item is updated with the required
--                 amount. For normalized items , renormalization is done.
--  INVOKED FROM : schedules_items
--  ARGUMENTS    : IN : p_lease_id, p_lease_context, p_new_lea_term_dt,
--                      p_new_lea_comm_dt, p_mths
--  HISTORY      :
--  01-AUG-05   piagrawa  o Created for mini-retro
--  19-jan-06   piagrawa  o Bug#4931780 - Modified signature
--  24-jan-06   piagrawa  o Bug#4890236 - Modified to delete the draft cash items
--                          before processing the terms if their schedule date
--                          is greater then lease end date.
-------------------------------------------------------------------------------
PROCEDURE mini_retro_contraction(p_lease_id           NUMBER,
                                 p_lease_context      VARCHAR2,
                                 p_new_lea_term_dt    DATE,
                                 p_new_lea_comm_dt    DATE,
                                 p_mths               NUMBER,
                                 p_cutoff_date        DATE)
IS

   l_msg                           VARCHAR2(2000);
   l_old_lea_term_dt               DATE;
   l_is_norm                       VARCHAR2(1);
   l_active_lease_change_id        pn_lease_details.lease_change_id%TYPE;
   l_schedule_exists               VARCHAR2(1) := 'N';

   CURSOR get_old_lea_term_dt IS
      SELECT NVL(plh.lease_extension_end_date,
                 plh.lease_termination_date) lease_termination_date
      FROM   pn_lease_details_history plh,
             pn_lease_details_all pld
      WHERE  pld.lease_change_id = plh.new_lease_change_id
      AND    pld.lease_id = p_lease_id;

   -- retrieves the approved schedule for a payment term for a lease
   CURSOR approved_sched_exist_cur(p_lease_ID IN NUMBER, p_payment_term_id IN NUMBER)
   IS
      SELECT payment_schedule_id
      FROM pn_payment_schedules_all
      WHERE lease_id = p_lease_ID
      AND payment_status_lookup_code = 'APPROVED'
      AND payment_schedule_id IN (SELECT payment_schedule_id
                                  FROM   pn_payment_items_all
                                  WHERE  payment_term_id = p_payment_term_id);


BEGIN
   pnp_debug_pkg.log('MINI RETRO CONTRACTION +Start+ (+)');
   pnp_debug_pkg.log('MINI RETRO CONTRACTION of MAIN Lease +Start+ (+)');
   pnp_debug_pkg.log('MINI RETRO CONTRACTION IN: p_lease_id         : '||p_lease_id);
   pnp_debug_pkg.log('MINI RETRO CONTRACTION IN: p_lease_context    : '||p_lease_context);
   pnp_debug_pkg.log('MINI RETRO CONTRACTION IN: p_new_lea_term_dt  : '||p_new_lea_term_dt);
   pnp_debug_pkg.log('MINI RETRO CONTRACTION IN: p_new_lea_comm_dt  : '||p_new_lea_comm_dt);
   pnp_debug_pkg.log('MINI RETRO CONTRACTION IN: p_mths             : '||p_mths);

   FOR rec IN get_old_lea_term_dt LOOP
      l_old_lea_term_dt := rec.lease_termination_date;
   END LOOP;

   pnp_debug_pkg.log('MINI RETRO CONTRACTION  - MAIN - Contracting Index rent ');

   FOR i in 1..28 LOOP
        norm_st_dt_rec_tbl(i) := NULL;
   END LOOP; /* 9231686 */

   pn_index_rent_periods_pkg.process_main_lease_term_date(p_lease_id,
                                                          p_new_lea_term_dt,
                                                          l_old_lea_term_dt,
                                                          p_lease_context,
                                                          l_msg,
                                                          p_cutoff_date);

   pnp_debug_pkg.log('MINI RETRO CONTRACTION - MAIN - Deleting Payment Items');

   /* Retrieve the active lease change id */
   l_active_lease_change_id := Get_Lease_Change_Id(p_lease_id);

   pnp_debug_pkg.log('MINI RETRO CONTRACTION IN: active lease change id : '||l_active_lease_change_id);

   /* Looping through all the terms associated with the lease. */
   FOR rec IN lease_con_cur_mini_retro(p_lease_id,l_active_lease_change_id)
   LOOP

      pnp_debug_pkg.log('TERM ID : term id        : '||rec.payment_term_id);

      l_is_norm := NVL(rec.normalize, 'N');
      l_schedule_exists := 'N';

      /* Check if the terms lie outside the new lease */
      IF rec.start_date > p_new_lea_term_dt AND
         rec.start_date <= l_old_lea_term_dt THEN

         FOR approved_sched_exist_rec IN approved_sched_exist_cur(p_lease_id, rec.payment_term_id) LOOP
            l_schedule_exists := 'Y';
         END LOOP;

         /* the start dates and end dates for a term will be updated if and only if
            there exists atleast one approved schedule for the term */

         IF (l_schedule_exists = 'Y') THEN

            /* The term start date lies outside the new lease */

            /* Update term with new term dates i.e. new lease end date and amount equal
               to 0 ,if the term lies outside the new lease and is a non-normalized term */

            update_term_dates(p_new_lea_term_start_dt => p_new_lea_term_dt,
                              p_new_lea_term_end_dt   => p_new_lea_term_dt,
                              p_lease_id              => p_lease_id,
                              p_payment_term_id       => rec.payment_term_id,
                              p_amount                => 0 );

            contract_pay_term_mini_retro (p_lease_id        => p_lease_id,
                                          p_lease_context   => p_lease_context,
                                          p_new_lea_term_dt => p_new_lea_term_dt,
                                          p_new_lea_comm_dt => p_new_lea_comm_dt,
                                          p_mths            => p_mths,
                                          p_normalize       => l_is_norm,
                                          p_adjustment      => 'Y',
                                          p_payment_term_id => rec.payment_term_id,
                                          p_cutoff_date     => p_cutoff_date,
                                          p_add_main        => 'N');

         ELSE

            delete_term(p_payment_term_id => rec.payment_term_id);

         END IF;

      ELSIF rec.start_date <= p_new_lea_term_dt THEN

         /* The term start date do not lie outside the new lease.
            Check if the term end date lies within new lease end date*/

         IF rec.end_date >= p_new_lea_term_dt THEN

            /* Update term with new term end date if the term lies partially outside the new
               lease is a normalized term   */

            update_term_dates(p_new_lea_term_end_dt => p_new_lea_term_dt,
                              p_lease_id            => p_lease_id,
                              p_payment_term_id     => rec.payment_term_id);

            contract_pay_term_mini_retro (p_lease_id        => p_lease_id,
                                          p_lease_context   => p_lease_context,
                                          p_new_lea_term_dt => p_new_lea_term_dt,
                                          p_new_lea_comm_dt => p_new_lea_comm_dt,
                                          p_mths            => p_mths,
                                          p_normalize       => l_is_norm,
                                          p_adjustment      => 'Y',
                                          p_payment_term_id => rec.payment_term_id,
                                          p_cutoff_date     => p_cutoff_date,
                                          p_add_main        => 'N');


         ELSE

            /* Renormalize the term if it is a normalized term  */
            IF l_is_norm = 'Y' THEN

               contract_pay_term_mini_retro (p_lease_id        => p_lease_id,
                                             p_lease_context   => p_lease_context,
                                             p_new_lea_term_dt => p_new_lea_term_dt,
                                             p_new_lea_comm_dt => p_new_lea_comm_dt,
                                             p_mths            => p_mths,
                                             p_normalize       => l_is_norm,
                                             p_adjustment      => 'N',
                                             p_payment_term_id => rec.payment_term_id,
                                             p_cutoff_date     => p_cutoff_date,
                                             p_add_main        => 'N');

            END IF; /* IF l_is_norm = 'Y' */

         END IF; /* IF  rec.end_date >= p_new_lea_term_dt */

      END IF; /* ELSIF rec.start_date <= p_new_lea_term_dt */

   END LOOP;

   /* Now create the schedules and items for the new terms that have been added along with
      the contraction of the main lease */

   add_main(p_lease_id        => p_lease_id,
            p_lease_context   => 'ADDAMD',
            p_new_lea_term_dt => p_new_lea_term_dt,
            p_new_lea_comm_dt => p_new_lea_comm_dt,
            p_mths            => p_mths);

   /* call clean up schedules to delete schedules which do not have any item or
      are draft and are outside the lease */

   pn_retro_adjustment_pkg.cleanup_schedules(p_lease_id);

   /* For Sub_Lease and Third_Party lease, contract tenancies and associated
       space assignments as well. */

   IF g_lease_class_code <> 'DIRECT' THEN
      contract_tenancies( p_lease_id           => p_lease_id
                         ,p_new_lea_term_dt    => p_new_lea_term_dt
                        );
   END IF;

   pn_schedules_items.g_norm_dt_avl := NULL; /* 9231686 */
   pnp_debug_pkg.log('MINI RETRO CONTRACTION of MAIN Lease -End- (-)');

EXCEPTION
   WHEN OTHERS THEN RAISE ;

END mini_retro_contraction;


--------------------------------------------------------------------------------------------
--  PROCEDURE  : SCHEDULES_ITEMS
--  DESCRIPTION: This is the main procedure called by pld with lease id and lease context.
--               Depending on the lease context, relevent routine is called for given ter,.
--
--  25-JUN-01  MMisra    o Created.
--  18-JUL-03  STripathi o Fixed for BUG# 3005135. Added lease_class_code in
--                         cursor get_lease_details.
--  16-OCT-03  STripathi o Fix for BUG# 3201091. Removed CURSOR get_max_lease_change_id
--                         and FETCH INTO global variables g_lc_id, g_amd_comm_dt.
--  27-OCT-03  STripathi o Fixed for BUG# 3178064. Populate g_lease_status.
--  21-OCT-04  VMmehta         o Bug# 3940200 - Added parameter p_calc_batch
--  15-OCT-04  MMisra    o Added code to call proc. adjustment when lease_context is 'ADJ'.
--  19-JAN-06  piagrawa  o Bug#4931780 - Modified signature
--  21-JUL-06  Pikhar    o Codev. Recalculate Natural Breakpoint if any changes in
--                         Lease Payment Terms
--  09-OCT-06  Hareesha  o Added extend_ri parameter for extending RI agreement on
--                         lease extension due to MTM/HLD.
--  05-APR-07  Hareesha  o Added handling for user's choice to expand terms and tenancies.
--  17-APR-07  Hareesha  o Bug # 5980300 Do not trigger PNCALNDX, if there exists no agreements
--                         with periods generated.
--  18-APR-07  sdmahesh  o Bug # 5985779. Enhancement for new profile
--                         option for lease early termination
--------------------------------------------------------------------------------------------
PROCEDURE schedules_items (errbuf            OUT NOCOPY VARCHAR2,
                           retcode           OUT NOCOPY VARCHAR2,
                           p_lease_id        IN  NUMBER,
                           p_lease_context   IN  VARCHAR2,
                           p_called_from     IN  VARCHAR2,
                           p_term_id         IN  NUMBER,
                           p_term_end_dt     IN  DATE,
                           p_calc_batch      IN  VARCHAR2,
                           p_cutoff_date     IN  VARCHAR2,
                           p_extend_ri       IN  VARCHAR2,
                           p_ten_trm_context IN  VARCHAR2)
IS

   l_mths                          NUMBER;
   l_return_status                 VARCHAR2(30) := NULL;
   l_return_message                VARCHAR2(32767) := NULL;
   l_requestId                     NUMBER := NULL;
   RETRO_NOT_ENABLED_EXCEPTION     EXCEPTION;
   l_cutoff_date                   DATE;

   l_process_nbp                   VARCHAR2(1);
   l_errbuf                        VARCHAR2(80);
   l_retcode                       VARCHAR2(80);
   l_update_nbp_flag               VARCHAR2(1);
   l_dummy                         VARCHAR2(1);
   l_var_rent_id                   NUMBER;
   l_calc_batch                    VARCHAR2(1);

   CURSOR get_lease_details IS
      SELECT pld.lease_commencement_date,
             pld.lease_termination_date,
             TRUNC(pld.lease_extension_end_date),
             pl.payment_term_proration_rule,
             pl.lease_status,
             pl.lease_class_code,
             pl.lease_num,
             pl.name
      FROM   pn_leases_all pl,
             pn_lease_details_all pld
      WHERE  pl.lease_id = p_lease_id
      AND    pld.lease_id = pl.lease_id;

   CURSOR var_cur(p1_lease_id IN NUMBER)
   IS
      SELECT var_rent_id
      FROM pn_var_rents_all
      WHERE lease_id = p1_lease_id;

   CURSOR terms_cur (p1_lease_id IN NUMBER)
   IS
      SELECT UPDATE_NBP_FLAG
      FROM PN_PAYMENT_TERMS_ALL
      WHERE lease_id = p1_lease_id
      FOR UPDATE NOWAIT;

   CURSOR bkhd_exists_cur
   IS
      select 'x'
      FROM DUAL
      where exists (select BKHD_DEFAULT_ID
                    from pn_var_bkpts_head_all
                    where period_id IN (select PERIOD_ID
                                        FROM pn_var_periods_all
                                        where VAR_RENT_ID = l_var_rent_id)
                    AND BKHD_DEFAULT_ID IS NOT NULL);

   CURSOR get_info IS
   SELECT    det_history.lease_status             lease_status_old,
             lease.lease_status                   lease_status_new,
             details.lease_termination_date       lease_term_date,
             det_history.lease_extension_end_date lease_ext_end_date
      FROM pn_lease_details_all details,
           pn_lease_details_history det_history,
           pn_leases_all        lease
      WHERE details.lease_id = p_lease_id
      AND   det_history.lease_id = p_lease_id
      AND   lease.lease_id = p_lease_id
      AND   details.lease_change_id = det_history.new_lease_change_id;

   CURSOR no_periods_exist_cur IS
      SELECT 'Y'
      FROM DUAL
      WHERE NOT EXISTS ( SELECT NULL
                         FROM pn_index_leases_all ilease, pn_index_lease_periods_all period
                         WHERE ilease.lease_id = p_lease_id
                         AND period.index_lease_id = ilease.index_lease_id);

   l_lease_status_old   VARCHAR2(30);
   l_lease_status_new   VARCHAR2(30);
   l_lease_term_date    DATE;
   l_lease_ext_end_date DATE;
   l_start_pos NUMBER := 1;     --Bug#7016892
   l_end_pos NUMBER;		--Bug#7016892
   l_lease_context VARCHAR2(30);  --Bug#7016892


BEGIN

   g_lease_id := p_lease_id;

    FOR i in 1..28 LOOP
        norm_st_dt_rec_tbl(i) := NULL;
    END LOOP;

   pnp_debug_pkg.log('pn_schedules_items.schedule_items +Start+ (+)');
   pnp_debug_pkg.log('Lease_ID     : '||TO_CHAR(g_lease_id));
   pnp_debug_pkg.log('Lease Context: '||p_lease_context
                      ||', Called From: '||p_called_from);

   l_calc_batch := p_calc_batch;
   FOR rec IN get_info LOOP
      l_lease_status_old  :=   rec.lease_status_old  ;
      l_lease_status_new  :=   rec.lease_status_new  ;
      l_lease_term_date   :=   rec.lease_term_date   ;
      l_lease_ext_end_date :=  rec.lease_ext_end_date;
   END LOOP;

   IF l_lease_status_new = 'ACT' AND ( l_lease_status_old = 'MTM' OR l_lease_status_old ='HLD')
      AND l_lease_term_date > l_lease_ext_end_date
   THEN
      l_calc_batch:= 'N';
   END IF;


   /* Get the Lease Details */

   OPEN get_lease_details;
      FETCH get_lease_details
      INTO  g_new_lea_comm_dt,
            g_new_lea_term_dt,
            g_new_ext_end_date,
            g_pr_rule,
            g_lease_status,
            g_lease_class_code,
            g_lease_num,
            g_lease_name;
   CLOSE get_lease_details;


   pnp_debug_pkg.log('Cut Off Date in varchar2     : '||p_cutoff_date);

   l_cutoff_date := fnd_date.canonical_to_date(p_cutoff_date);

   IF l_cutoff_date IS NULL THEN
      l_cutoff_date := g_new_lea_comm_dt ;
   END IF;

   pnp_debug_pkg.log('lease_termination_date   : '||g_new_lea_term_dt);
   pnp_debug_pkg.log('lease_commencement_date  : '||g_new_lea_comm_dt);
   pnp_debug_pkg.log('Cut Off Date     : '||l_cutoff_date);

   /* Calculate number of months between lease commenecement date and termination date.*/

   l_mths := ROUND(MONTHS_BETWEEN(First_Day(g_new_lea_term_dt),First_Day(g_new_lea_comm_dt)))+1;

   pnp_debug_pkg.log('No. of Months between Lease Commencement and Termination Date: '||l_mths);

  WHILE(l_start_pos <= length(p_lease_context))
  LOOP
    select decode(instr(p_lease_context,':',l_start_pos),0,length(p_lease_context),instr(p_lease_context,':',l_start_pos)-1)
    into l_end_pos from dual;
    l_lease_context := substr(p_lease_context,l_start_pos,l_end_pos - l_start_pos + 1);
    l_start_pos := l_end_pos + 2;

   IF l_lease_context = 'CON' AND p_called_from = 'MAIN' THEN

      pnp_debug_pkg.log('schedules_items - Contraction +Start+ (+)');
      IF NVL(fnd_profile.value('PN_ERLY_TMNT_B4_LST_APP_SCHD'),'N') = 'Y' THEN
         IF NOT pnp_util_func.mini_retro_enabled THEN
            contraction(p_lease_id           => p_lease_id,
                        p_lease_context      => l_lease_context,
                        p_new_lea_term_dt    => g_new_lea_term_dt,
                        p_new_lea_comm_dt    => g_new_lea_comm_dt,
                        p_mths               => l_mths);
         ELSE
            mini_retro_contraction(p_lease_id   => p_lease_id,
                           p_lease_context      => l_lease_context,
                           p_new_lea_term_dt    => g_new_lea_term_dt,
                           p_new_lea_comm_dt    => g_new_lea_comm_dt,
                           p_mths               => l_mths,
                           p_cutoff_date        => l_cutoff_date);
         END IF;
      ELSE
         contraction_by_itm_end_dt(p_lease_id           => p_lease_id,
                     p_lease_context      => l_lease_context,
                     p_new_lea_term_dt    => g_new_lea_term_dt,
                     p_new_lea_comm_dt    => g_new_lea_comm_dt,
                     p_mths               => l_mths);
      END IF;
      pnp_debug_pkg.log('schedules_items - Contraction -End- (-)');

   ELSIF l_lease_context = 'EXP' AND p_called_from = 'MAIN' THEN

      pnp_debug_pkg.log('expansion from main +Start+ (+)');

      expansion(p_lease_id            => p_lease_id,
                p_lease_context       => l_lease_context,
                p_new_lea_term_dt     => g_new_lea_term_dt,
                p_new_lea_comm_dt     => g_new_lea_comm_dt,
                p_mths                => l_mths,
                p_term_id             => p_term_id,
                p_cutoff_date         => l_cutoff_date,
                p_extend_ri           => p_extend_ri,
                p_ten_trm_context     => p_ten_trm_context);

      pnp_debug_pkg.log('expansion from main -End- (-)');

   ELSIF l_lease_context IN ('ABS','LOF','SGN') THEN

      pnp_debug_pkg.log('abstraction +Start+ (+)');

      abstract(p_lease_id            => p_lease_id,
               p_lease_context       => l_lease_context,
               p_new_lea_term_dt     => g_new_lea_term_dt,
               p_new_lea_comm_dt     => g_new_lea_comm_dt,
               p_mths                => l_mths);

      pnp_debug_pkg.log('abstraction -End- (-)');

   ELSIF l_lease_context IN ('ADDEDT', 'ADDAMD') AND p_called_from = 'MAIN' THEN

      pnp_debug_pkg.log('addition from main +Start+ (+)');

      add_main(p_lease_id            => p_lease_id,
               p_lease_context       => l_lease_context,
               p_new_lea_term_dt     => g_new_lea_term_dt,
               p_new_lea_comm_dt     => g_new_lea_comm_dt,
               p_mths                => l_mths);

      pnp_debug_pkg.log('addition from main -End- (-)');

   ELSIF l_lease_context = 'ADD' AND p_called_from IN ('IND','VAR') THEN

      pnp_debug_pkg.log('addition from index/variable +Start+ (+)');

      add_ind_var(p_lease_id            => p_lease_id,
                  p_lease_context       => l_lease_context,
                  p_term_id             => p_term_id,
                  p_new_lea_term_dt     => g_new_lea_term_dt,
                  p_new_lea_comm_dt     => g_new_lea_comm_dt,
                  p_mths                => l_mths);

      PN_REC_CALC_PKG.lock_area_exp_cls_dtl(p_term_id);


      pnp_debug_pkg.log('addition from index/variable -End- (-)');


   ELSIF l_lease_context = 'CONTERM' AND p_called_from = 'MAIN' THEN

      pnp_debug_pkg.log('schedules_items - Payment Term Contraction +Start+ (+)');
      IF NVL(fnd_profile.value('PN_ERLY_TMNT_B4_LST_APP_SCHD'),'N') = 'Y' THEN
         IF NOT pnp_util_func.mini_retro_enabled THEN
            contract_pay_term(p_lease_id           => p_lease_id,
                              p_lease_context      => l_lease_context,
                              p_new_lea_term_dt    => g_new_lea_term_dt,
                              p_new_lea_comm_dt    => g_new_lea_comm_dt,
                              p_mths               => l_mths);
         ELSE
            FOR pay_term_con_cur IN payment_term_con_cur (p_lease_id)
            LOOP
               contract_pay_term_mini_retro (p_lease_id           => p_lease_id,
                                             p_lease_context      => l_lease_context,
                                             p_new_lea_term_dt    => g_new_lea_term_dt,
                                             p_new_lea_comm_dt    => g_new_lea_comm_dt,
                                             p_mths               => l_mths,
                                             p_normalize          => pay_term_con_cur.normalize,
                                             p_adjustment         => 'Y',
                                             p_payment_term_id    => pay_term_con_cur.payment_term_id,
                                             p_cutoff_date        => l_cutoff_date,
                                             p_add_main           => 'Y');
            END LOOP;

            /* call clean up schedules to delete schedules which do not have any item or
            are draft and are outside the lease */

            pn_retro_adjustment_pkg.cleanup_schedules(p_lease_id);
         END IF;
      ELSE
         contract_pay_term(p_lease_id           => p_lease_id,
                           p_lease_context      => l_lease_context,
                           p_new_lea_term_dt    => g_new_lea_term_dt,
                           p_new_lea_comm_dt    => g_new_lea_comm_dt,
                           p_mths               => l_mths);
      END IF;
      pnp_debug_pkg.log('schedules_items - Payment Term Contraction -End- (-)');

   -- Retro Start
   ELSIF l_lease_context = 'ADJ' AND p_called_from = 'MAIN' THEN

      IF pnp_util_func.retro_enabled THEN

        pnp_debug_pkg.log('schedules_items - Term Adjustment +Start+ (+)');

        term_id_tab.delete;
        l_index := 0;

        adjustment(p_lease_id           => p_lease_id,
                   p_lease_context      => l_lease_context,
                   p_new_lea_term_dt    => g_new_lea_term_dt,
                   p_new_lea_comm_dt    => g_new_lea_comm_dt,
                   p_mths               => l_mths);

        pnp_debug_pkg.log('schedules_items - Term Adjustment -End- (-)');

      ELSE
        RAISE RETRO_NOT_ENABLED_EXCEPTION;
      END IF;
      -- Retro End

   ELSIF l_lease_context IN ('ROLLOVER') AND p_called_from = 'MAIN' THEN
      pnp_debug_pkg.log('schedules_items - Lease Rollover to MTM/HLD+Start+ (+)');

      rollover_lease(p_lease_id         => p_lease_id ,
                     p_lease_end_date   => g_new_ext_end_date,
                     p_new_lea_term_dt  => g_new_lea_term_dt,
                     p_new_lea_comm_dt  => g_new_lea_comm_dt,
                     p_mths             => l_mths,
                     p_extend_ri        => p_extend_ri,
                     p_ten_trm_context  => p_ten_trm_context,
                     x_return_status    => l_return_status,
                     x_return_message   => l_return_message );
      IF NOT( l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         Errbuf  := SQLERRM;
         Retcode := 2;
      END IF;

      pnp_debug_pkg.log('schedules_items - Lease Rollover to MTM/HLD+End+ (-)');

   END IF;
END loop;  --While

   /* Generate the rent normalization report */
   Norm_Report(l_lease_context);

   -- Retro Start
   IF pnp_util_func.retro_enabled = TRUE THEN
     retro_rec_impact_report;
     retro_vr_impact_report;
   END IF;
   -- Retro End



   --Recalculate Natural Breakpoint if any changes in Lease Payment Terms

   l_update_nbp_flag := NULL;
   FOR terms_rec IN terms_cur(p1_lease_id => p_lease_id)
   LOOP
      IF terms_rec.UPDATE_NBP_FLAG = 'Y' THEN
         l_update_nbp_flag := 'Y';
         EXIT;
      END IF;
   END LOOP;

   IF l_update_nbp_flag = 'Y' THEN
      FOR var_rec in var_cur(p1_lease_id => p_lease_id)
      LOOP

         l_var_rent_id := var_rec.var_rent_id;

         OPEN bkhd_exists_cur;
         FETCH bkhd_exists_cur INTO l_dummy;
         CLOSE bkhd_exists_cur;

         pn_var_natural_bp_pkg.build_bkpt_details_main(errbuf        => l_errbuf,
                                                       retcode       => l_retcode,
                                                       p_var_rent_id => var_rec.var_rent_id);

         IF l_dummy IS NOT NULL THEN
            pn_var_defaults_pkg.create_setup_data (x_var_rent_id => var_rec.var_rent_id);
         END IF;

         pnp_debug_pkg.log('Updated Natural Breakpoints for VR - '||var_rec.var_rent_id);


      END LOOP;

      UPDATE pn_payment_terms_all
      SET UPDATE_NBP_FLAG = NULL
      WHERE lease_id = p_lease_id;



   END IF;

   -- Finished Recalculating Natural Breakpoint if any changes in Lease Payment Terms

   FOR no_periods_exist_rec IN no_periods_exist_cur LOOP
      l_calc_batch := 'N';
   END LOOP;

   IF l_calc_batch  = 'Y' THEN
      l_requestId := fnd_request.submit_request ('PN',
                                                 'PNCALNDX',
                                                 NULL,
                                                 NULL,
                                                 FALSE,
            null,null,null,null, null,g_lease_num,null,null,'Y',
            chr(0),  '', '',  '',
            '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
            '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
            '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
            '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
            '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
            '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
            '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
            '',  '',  '',  '',  '',  '',  '',  '',  '',  '',
            '',  '',  '',  '',  '',  '',  ''
            );

      IF (l_requestId = 0 ) THEN
         pnp_debug_pkg.log(' ');
         pnp_debug_pkg.log('Could not submit Concurrent Request PNCALNDX'
                                   ||' (PN - Calculate Index Rent)');
         fnd_message.set_name('PN', 'PN_SCHIT_CONC_FAIL');
         pnp_debug_pkg.put_log_msg(fnd_message.get);

      ELSE                                        -- Got a request Id
         pnp_debug_pkg.log(' ');
         pnp_debug_pkg.log('Concurrent Request '||TO_CHAR(l_requestId)
                                   ||' has been submitted for: PN - Calculate Index Rent');
         fnd_message.set_name('PN', 'PN_SCHIT_CONC_SUCC');
         pnp_debug_pkg.put_log_msg(fnd_message.get);
      END IF;
   END IF;

   pnp_debug_pkg.log('');
   pnp_debug_pkg.log('');
   pnp_debug_pkg.log('pn_schedules_items.schedule_items -End- (-)');

EXCEPTION
  WHEN RETRO_NOT_ENABLED_EXCEPTION THEN
    fnd_message.set_name ('PN', 'PN_RETRO_NOT_ENABLED');
    errbuf := fnd_message.get;
    pnp_debug_pkg.put_log_msg(errbuf);
    retcode := 2;
    RAISE;

  WHEN OTHERS THEN
    Errbuf  := SQLERRM;
    Retcode := 2;
    ROLLBACK;
    RAISE;

END Schedules_Items;




END pn_schedules_items;

/
