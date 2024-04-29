--------------------------------------------------------
--  DDL for Package Body PN_VARIABLE_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VARIABLE_AMOUNT_PKG" AS
-- $Header: PNVRAMTB.pls 120.13.12010000.2 2009/05/28 07:20:29 jsundara ship $

/* Declare all the appropriate cursors to get actual/forecasted volume
   history  */

/* cursor for picking up the group dates AND their VH , for 'CALCULATION',
   if invoicing is on 'ACTUAL' */

CURSOR csr_actual_vol (p_line_item_id number,
                       p_period_id number,
               p_period_date DATE) IS
SELECT SUM(vh.actual_amount) actual_amt,
       vh.grp_date_id
FROM   pn_var_vol_hist_all vh,
       pn_var_grp_dates_all gd
WHERE vh.line_item_id = p_line_item_id
AND vh.grp_date_id = gd.grp_date_id
AND vh.period_id = gd.period_id
AND NVL(gd.actual_exp_code,'N') = 'N'
AND gd.period_id = p_period_id
AND vh.actual_amount is not null
AND gd.grp_end_date <= p_period_date
GROUP BY vh.grp_date_id, vh.group_date
ORDER BY vh.group_date;

/* cursor for picking up the group dates AND their VH , for 'CALCULATION',  if invoicing is on
   'FORECASTED' */

CURSOR csr_forecast_vol (p_line_item_id number,
                         p_period_id number,
                         p_period_date DATE) IS
SELECT  SUM(vh.forecasted_amount) forecasted_amt,
        vh.grp_date_id
FROM pn_var_vol_hist_all vh,
     pn_var_grp_dates_all gd
WHERE vh.line_item_id = p_line_item_id
AND vh.grp_date_id = gd.grp_date_id
AND vh.period_id = gd.period_id
AND NVL(gd.forecasted_exp_code,'N') = 'N'
AND gd.period_id = p_period_id
AND vh.forecasted_amount is not  null
AND gd.grp_end_date <= p_period_date
GROUP BY vh.grp_date_id, vh.group_date
ORDER BY vh.group_date;

/* cursor for picking up the group dates AND their VH , for 'RECONCILIATION',
   if invoicing is on 'FORECASTED'.Here we are asSUMing that the UI will
   validate the invoice date of a given period to ensure that the forecasted rent
   has been transferred for all of TYPE group dates belonging to the invoice date,
   prior to calling this routine to do the reconciliation for a given invoice date
   NOTE:
   dont reconcile if act-for rent has been exported,do an adjustment */
CURSOR csr_reconcile_vol (p_invoice_date DATE,
                          p_period_id NUMBER,
                          p_line_item_id NUMBER,
                          p_period_date DATE) IS
SELECT SUM(vh.actual_amount) actual_amt,
       vh.grp_date_id,
       vh.line_item_id
FROM pn_var_vol_hist_all vh,
     pn_var_grp_dates_all gd
WHERE vh.grp_date_id = gd.grp_date_id
AND vh.period_id = gd.period_id
AND gd.period_id = p_period_id
AND vh.line_item_id = p_line_item_id
AND gd.invoice_date = p_invoice_date
AND NVL(gd.variance_exp_code,'N') = 'N'
AND NVL(gd.forecasted_exp_code,'N') = 'Y'
AND vh.actual_amount is not null
AND gd.grp_end_date <= p_period_date
GROUP BY vh.line_item_id, vh.grp_date_id, vh.group_date
ORDER BY vh.line_item_id, vh.group_date;

/* cursor for picking up the group dates AND their VH , for 'ADJUSTMENT' */

CURSOR csr_adjust_vol (p_period_id number,
                       p_line_item_id number,
                       p_invoice_on varchar2,
                       p_min_group_date date) IS
SELECT SUM(vh.actual_amount) actual_amt,
       vh.grp_date_id,
       vh.line_item_id
FROM pn_var_vol_hist_all vh,
     pn_var_grp_dates_all gd
WHERE vh.grp_date_id = gd.grp_date_id
AND   vh.period_id = gd.period_id
AND   DECODE(p_invoice_on,'ACTUAL',NVL(gd.actual_exp_code,'N'),
                          'FORECASTED',NVL(gd.variance_exp_code,'N')) = 'Y'
AND   gd.period_id = p_period_id
AND   vh.line_item_id = p_line_item_id
AND   gd.group_date >= p_min_group_date
GROUP BY vh.line_item_id, vh.grp_date_id, vh.group_date
ORDER BY vh.line_item_id, vh.group_date;

/* Get the break point range details */

CURSOR csr_bkpt_range(p_line_item_id NUMBER)IS
SELECT det.period_bkpt_vol_start,
       det.period_bkpt_vol_end,
       det.group_bkpt_vol_start,
       det.group_bkpt_vol_end,
       det.bkpt_rate,
       head.breakpoint_TYPE,
       head.line_item_id
FROM pn_var_bkpts_head_all head,
     pn_var_bkpts_det_all det
WHERE det.bkpt_header_id = head.bkpt_header_id
AND head.line_item_id = p_line_item_id
ORDER BY det.period_bkpt_vol_start;


/* Get the cumulative volume for all the group dates in a
   line item */

CURSOR csr_cumulative_vol(p_line_item_id NUMBER)
IS
SELECT SUM(actual_amount) cum_actual_vol,
       SUM(forecasted_amount) cum_for_vol,
       line_item_id,
       grp_date_id,
       group_date
FROM pn_var_vol_hist_all
WHERE line_item_id = p_line_item_id
GROUP BY line_item_id,grp_date_id,group_date
ORDER BY line_item_id,group_date;

/* Get the percent days open for all the group dates in a line
   item. Required when prorating breakpoints */

Cursor csr_get_gd(p_period_id NUMBER) is
SELECT grp_date_id,
       proration_factor,
       invoice_date,
       group_date,
       grp_start_date,
       grp_end_date
FROM pn_var_grp_dates_all
WHERE period_id = p_period_id;

/* Get the deductions for all the group dates */

Cursor csr_get_ded (p_line_item_id NUMBER) is
SELECT line_item_id,
       grp_date_id,
       SUM(deduction_amount) deduction_amt
FROM pn_var_deductions_all
WHERE line_item_id = p_line_item_id
GROUP BY line_item_id,grp_date_id;


TYPE bkpt_range_TYPE IS
TABLE OF csr_bkpt_range%ROWTYPE
INDEX BY BINARY_INTEGER;

TYPE cumulative_vol_rec IS
RECORD (cum_actual_vol pn_var_vol_hist.actual_amount%TYPE,
        cum_for_vol    pn_var_vol_hist.forecasted_amount%TYPE,
        line_item_id   pn_var_vol_hist.line_item_id%TYPE,
        grp_date_id    pn_var_vol_hist.grp_date_id%TYPE,
        cum_ded        pn_var_deductions.deduction_amount%TYPE);

TYPE cumulative_vol_TYPE IS
TABLE OF cumulative_vol_rec
INDEX BY BINARY_INTEGER;

TYPE grd_date_TYPE IS
TABLE OF csr_get_gd%ROWTYPE
INDEX BY BINARY_INTEGER;

TYPE deduction_TYPE IS
TABLE OF csr_get_ded%ROWTYPE
INDEX BY BINARY_INTEGER;

TYPE invoice_TYPE IS
TABLE OF pn_var_rent_inv%ROWTYPE
INDEX BY BINARY_INTEGER;

/* PL/SQL table to store the breakpoint details */
bkpt_range_tbl bkpt_range_TYPE;

/* PLSQL table cumulative volumes details */
cum_vol_tbl cumulative_vol_TYPE;

/* PL/SQL table percent days open */
grd_date_tbl  grd_date_TYPE;

/* PL/SQL table deduction_tbl to store deductions for all the group dates */
deduction_tbl deduction_TYPE;

/* PL/SQL table to store the invoice details */
invoice_tbl invoice_TYPE;


/* global variables */
g_breakpoint_TYPE pn_var_bkpts_head.breakpoint_TYPE%TYPE;
g_var_rent_id     pn_var_rents.var_rent_id%TYPE;
g_period_id       pn_var_periods.period_id%TYPE;
g_invoice_date    pn_var_grp_dates.invoice_date%TYPE;
g_group_date      pn_var_grp_dates.group_date%TYPE;
g_invoice_on      pn_var_rents.invoice_on%TYPE;
g_cumulative      pn_var_rents.cumulative_vol%TYPE;
g_rent_TYPE       varchar2(20);
g_set_of_books_id gl_sets_of_books.set_of_books_id%TYPE;
g_currency_code   gl_sets_of_books.currency_code%TYPE;
g_precision       number;
g_org_id          pn_leases.org_id%TYPE;
g_period_date     pn_var_periods.start_date%TYPE;

/* Uncomment for multi-org support */
/*l_gt              pn_mo_cache_utils.GlobalsTable; */


-------------------------------------------------------------------------------
--  PROCEDURE  : process_variable_rent
--
--
--  Main procedure to be called during adjustment(p_calc_TYPE='ADJUST'),
--  calculation(p_calc_TYPE='CALCULATE') or reconciliation(p_calc_TYPE='RECONCILE')
--
--  Parameters:
--   p_var_rent_id     Variable rent id
--   p_period_id       Period id
--   p_line_item_id    Line item id
--   p_calc_TYPE       The calcuation TYPE ('CALCULATE','ADJUST' or 'RECONCILE')
--   p_invoice_on      Invoice on ('ACTUAL' or 'FORECASTED')
--   p_cumulative      Cumulative Flag ('Y' or 'N')
--   p_invoice_date    During Adjustment has a value.
-------------------------------------------------------------------------------

PROCEDURE process_variable_rent (p_var_rent_id  IN NUMBER,
                                 p_period_id    IN NUMBER,
                                 p_line_item_id IN NUMBER,
                                 p_cumulative   IN VARCHAR2,
                                 p_invoice_on   IN VARCHAR2,
                                 p_calc_TYPE    IN VARCHAR2,
                                 p_invoice_date IN DATE )
IS

CURSOR csr_get_lines(ip_line_item_id NUMBER) IS
SELECT lines.line_item_num,
       lines.period_id,
       lines.line_item_id
FROM pn_var_periods_all per,
     pn_var_lines_all lines
WHERE lines.period_id= per.period_id
AND per.var_rent_id = p_var_rent_id
AND per.period_id = p_period_id
AND lines.line_item_id = NVL(ip_line_item_id,lines.line_item_id);

BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.process_variable_rent (+) ');

pnp_debug_pkg.log('process_variable_rent - Cumulative  : '||p_cumulative);
pnp_debug_pkg.log('process_variable_rent - Invoice On  : '||p_invoice_on);

/* intialize the global variables for later use when inserting/updating into
   pn_var_rent_SUMm */

   g_var_rent_id := p_var_rent_id;
   g_period_id   := p_period_id;
   g_invoice_on  := p_invoice_on;
   g_cumulative  := p_cumulative;


/* Initialize pl/sql table */

invoice_tbl.delete;


/* get all the line items for the period  */

FOR rec_get_lines in csr_get_lines(p_line_item_id)
  LOOP
      fnd_message.set_name ('PN','PN_VRAM_LN_NO');
      fnd_message.set_token ('NUM',rec_get_lines.line_item_num);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      pnp_debug_pkg.log('process_variable_rent - Period id    :'||rec_get_lines.period_id);
      pnp_debug_pkg.log('process_variable_rent - Line item id : '||rec_get_lines.line_item_id);

      process_calculate_TYPE(p_line_item_id    => rec_get_lines.line_item_id,
                             p_cumulative      => p_cumulative,
                             p_calc_TYPE       => p_calc_TYPE,
                             p_period_id       => rec_get_lines.period_id,
                             p_invoice_date    => p_invoice_date);
  END LOOP;

/* Insert/Update the invoices for the period */

Insert_invoice(p_calc_TYPE   => p_calc_TYPE,
               p_period_id   => p_period_id,
               p_var_rent_id => p_var_rent_id);


pnp_debug_pkg.log('pn_variable_amount_pkg.process_variable_rent (-) ');

END process_variable_rent;


-------------------------------------------------------------------------------
-- PROCEDURE  : process_calculate_TYPE
-- PARAMETERS :
--
-- Based up on if there is an adjustment, reconcilation or calculation of
-- variable rent, open the appropriate cursors AND make a call to
-- calculate_var_rent to calculate variable for each line_item_id.
--
-- HISTORY
-- 22-Feb-04  Kiran Hegde    o Added new cursor to get the min group date in a
--                             period which needs an adjustment.
--                             The min group date is used to get all the group
--                             dates in a period that need adjustment.
--                             Bug # 3237575
-------------------------------------------------------------------------------

PROCEDURE process_calculate_TYPE (p_line_item_id IN NUMBER,
                                  p_cumulative IN  VARCHAR2,
                                  p_calc_TYPE IN VARCHAR2,
                                  p_period_id IN NUMBER,
                                  p_invoice_date IN DATE)
IS
l_act_cum_vol NUMBER;
l_for_cum_vol NUMBER;
l_cum_ded     NUMBER;

-- Get the min group_date for adjustment
CURSOR csr_min_group_date_adj (p_period_id number,
                               p_line_item_id number,
                               p_invoice_on varchar2) IS
SELECT MIN(gd.group_date) min_group_date
FROM pn_var_vol_hist_all vh,
     pn_var_grp_dates_all gd
WHERE vh.grp_date_id = gd.grp_date_id
AND vh.period_id = gd.period_id
AND DECODE(p_invoice_on,'ACTUAL',NVL(gd.actual_exp_code,'N'),
                        'FORECASTED',NVL(gd.variance_exp_code,'N')) = 'Y'
AND gd.period_id = p_period_id
AND vh.line_item_id = p_line_item_id
AND exists (SELECT null
            FROM pn_var_vol_hist_all vh1
            WHERE vh1.period_id = gd.period_id
            AND vh1.grp_date_id = gd.grp_date_id
            AND DECODE(p_invoice_on,'ACTUAL'    ,NVL( vh1.actual_exp_code,'N'),
                                    'FORECASTED',NVL( vh1.variance_exp_code,'N')
                       ) = 'N'
            AND vh1.line_item_id = vh.line_item_id
            AND vh1.actual_amount is not null);

l_min_grp_date DATE;

BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.process_calculate_TYPE (+) ');


/* get the Breakpoint info. For the line item */

get_bkp_details(p_line_item_id   => p_line_item_id);


/* get deduction if invoicing is on actual AND store the information
   in a PL/SQL table deductions_tbl */

get_deductions(p_line_item_id => p_line_item_id);

/* get Cumulative Volume for each line item id AND store the
   information in pl/sql table cum_vol_tbl */

IF p_cumulative = 'Y' THEN
   get_cumulative_volume(p_line_item_id => p_line_item_id);
END IF;


 /* for calculate get the volume history for forecasted AND/or actual.
    open the appropriate cursors to get the volume history */

IF g_invoice_on = 'ACTUAL' AND p_calc_TYPE = 'CALCULATE' THEN

  FOR rec_actual_vol in csr_actual_vol(p_line_item_id => p_line_item_id,
                                       p_period_id    => p_period_id,
                                       p_period_date  => g_period_date)
  LOOP
    IF  p_cumulative = 'Y'  THEN

      get_cum_vol_by_grpdt(p_grp_date_id    => rec_actual_vol.grp_date_id,
                           p_cum_actual_vol => l_act_cum_vol ,
                           p_cum_for_vol    => l_for_cum_vol,
                           p_cum_ded        => l_cum_ded);
    END IF;

    g_rent_TYPE := 'ACTUAL';

    calculate_var_rent(p_grp_date_id      => rec_actual_vol.grp_date_id,
                       p_line_item_id     => p_line_item_id,
                       p_cum_volume       => l_act_cum_vol,
                       p_volume           => rec_actual_vol.actual_amt,
                       p_cum_ded          => l_cum_ded,
                       p_cumulative       => p_cumulative,
                       p_calc_TYPE        => p_calc_TYPE);

  END LOOP;

ELSIF g_invoice_on = 'FORECASTED' AND p_calc_TYPE = 'CALCULATE' THEN

  FOR rec_forecast_vol in csr_forecast_vol(p_line_item_id => p_line_item_id,
                                           p_period_id    => p_period_id,
                                           p_period_date  => g_period_date)
  LOOP

    IF  p_cumulative = 'Y'  THEN

       get_cum_vol_by_grpdt(p_grp_date_id    => rec_forecast_vol.grp_date_id,
                            p_cum_actual_vol => l_act_cum_vol ,
                            p_cum_for_vol    => l_for_cum_vol,
                            p_cum_ded        => l_cum_ded);
    END IF;

    g_rent_TYPE := 'FORECASTED';

    /* Calculate the forecasted rent */


    calculate_var_rent(p_grp_date_id     => rec_forecast_vol.grp_date_id,
                       p_line_item_id    => p_line_item_id,
                       p_volume          => rec_forecast_vol.forecasted_amt,
                       p_cum_volume      => l_for_cum_vol,
                       p_cum_ded         => l_cum_ded,
                       p_cumulative      => p_cumulative,
                       p_calc_TYPE       => p_calc_TYPE);

  END LOOP;

ELSIF p_calc_TYPE = 'RECONCILE' AND g_invoice_on = 'FORECASTED'  THEN

  FOR rec_reconcile_vol in csr_reconcile_vol(p_invoice_date => p_invoice_date,
                                             p_period_id    => p_period_id,
                                             p_line_item_id => p_line_item_id,
                                             p_period_date  => g_period_date)
  LOOP
    IF  p_cumulative = 'Y'  THEN

        get_cum_vol_by_grpdt(p_grp_date_id    => rec_reconcile_vol.grp_date_id,
                             p_cum_actual_vol => l_act_cum_vol ,
                             p_cum_for_vol    => l_for_cum_vol,
                             p_cum_ded        => l_cum_ded);
    END IF;

    g_rent_TYPE := 'ACTUAL';

    /* calculate actual rent */

    calculate_var_rent(p_grp_date_id     => rec_reconcile_vol.grp_date_id,
                       p_line_item_id    => rec_reconcile_vol.line_item_id,
                       p_volume          => rec_reconcile_vol.actual_amt ,
                       p_cum_volume      => l_act_cum_vol,
                       p_cum_ded         => l_cum_ded,
                       p_cumulative      => p_cumulative,
                       p_calc_TYPE       => p_calc_TYPE);
  END LOOP;

ELSIF p_calc_TYPE = 'ADJUST' THEN

  -- get the min group date
  FOR min_date in csr_min_group_date_adj (p_period_id    => p_period_id,
                                          p_invoice_on   => g_invoice_on,
                                          p_line_item_id => p_line_item_id)
  LOOP
    l_min_grp_date := min_date.min_group_date;
  END LOOP;

  FOR rec_adjust_vol in csr_adjust_vol(p_period_id      => p_period_id,
                                       p_invoice_on     => g_invoice_on,
                                       p_line_item_id   => p_line_item_id,
                                       p_min_group_date => l_min_grp_date)
  LOOP
     IF  p_cumulative = 'Y'  THEN

        get_cum_vol_by_grpdt(p_grp_date_id    => rec_adjust_vol.grp_date_id,
                             p_cum_actual_vol => l_act_cum_vol ,
                             p_cum_for_vol    => l_for_cum_vol,
                             p_cum_ded        => l_cum_ded);

     END IF;

     g_rent_TYPE := 'ACTUAL';

     /* calculate actual rent */

     calculate_var_rent(p_grp_date_id     => rec_adjust_vol.grp_date_id,
                        p_line_item_id    => rec_adjust_vol.line_item_id,
                        p_volume          => rec_adjust_vol.actual_amt,
                        p_cum_volume      => l_act_cum_vol,
                        p_cum_ded         => l_cum_ded,
                        p_cumulative      => p_cumulative,
                        p_calc_TYPE       => p_calc_TYPE);

  END LOOP;

END IF;


pnp_debug_pkg.log('pn_variable_amount_pkg.process_calculate_TYPE (-) ');

END process_calculate_TYPE;


------------------------------------------------------------------------
-- PROCEDURE : calculate_var_rent
--
-- Calculate variable rent for each group date AND line item id
-- called for when calculating variable rent for each group date
------------------------------------------------------------------------

PROCEDURE calculate_var_rent (p_grp_date_id     IN NUMBER,
                              p_line_item_id    IN NUMBER,
                              p_volume          IN NUMBER,
                              p_cum_volume      IN NUMBER,
                              p_cum_ded         IN NUMBER,
                              p_cumulative      IN VARCHAR2,
                              p_calc_TYPE       IN VARCHAR2)
IS
l_proration_factor  NUMBER;
l_variable_rent     NUMBER := 0;
l_tot_ded           NUMBER;
l_net_volume        NUMBER := 0;
l_volume            NUMBER := 0;
l_group_date        DATE;
l_COUNT             NUMBER := 0;
i                   NUMBER := 0;
j                   NUMBER := 0;

BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.calculate_var_rent (+) ');


         /* Get the percent days open for the group date*/

          FOR l_COUNT in 1 .. grd_date_tbl.COUNT
          LOOP
                i := i + 1;

                IF grd_date_tbl(i).grp_date_id = p_grp_date_id  THEN
                    l_proration_factor  := grd_date_tbl(i).proration_factor;
                    g_invoice_date      := null;
                    g_invoice_date      := grd_date_tbl(i).invoice_date;
                    l_group_date        := grd_date_tbl(i).group_date;
                    exit;
                END IF;

           END LOOP;


      pnp_debug_pkg.put_log_msg('===============================================================================');
      fnd_message.set_name ('PN','PN_SOI_INV_DT');
      fnd_message.set_token ('DATE',g_invoice_date);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      fnd_message.set_name ('PN','PN_VRAM_GRP_DATE');
      fnd_message.set_token ('DATE',l_group_date);
      pnp_debug_pkg.put_log_msg(fnd_message.get);
      pnp_debug_pkg.put_log_msg('===============================================================================');

          /* Initialize variables with total volume AND deduction*/

           IF  p_cumulative = 'N'  THEN

                l_volume  := p_volume;

                IF g_rent_TYPE = 'ACTUAL' THEN

                    /*Get the deductions to be applied on non cumulative volume*/
                    FOR l_ded_COUNT in 1 .. deduction_tbl.COUNT
                    LOOP
                        j := j + 1;
                        IF deduction_tbl(j).grp_date_id = p_grp_date_id THEN
                           l_tot_ded:= deduction_tbl(j).deduction_amt;
                           exit;
                        END IF;
                    END LOOP;

                   /*If no deductions have been entered for the group date but we are calculating
                     the net volume AND also the actual rent then default the deduction to 0*/

                   IF l_volume is not null THEN
                       l_tot_ded := NVL(l_tot_ded,0);
                   END IF;

                END IF;

           ELSIF p_cumulative = 'Y' THEN

              l_volume  := p_cum_volume;
              l_tot_ded := p_cum_ded;

           END IF;

           IF g_rent_TYPE = 'ACTUAL' THEN

              /* Apply the deduction on the volume history to get the volume applicable if
                 actual rent is being calculated */

                l_net_volume := l_volume - NVL(l_tot_ded,0);
           ELSE
                l_net_volume := l_volume;
           END IF;


          /* Apply the break points on the volume history AND get the rent applicable */

           pnp_debug_pkg.log('calculate_var_rent : p_cumulative '|| p_cumulative);
           pnp_debug_pkg.log('calculate_var_rent : p_net_volume '|| l_net_volume);
           pnp_debug_pkg.log('calculate_var_rent : p_percent_days_open '|| l_proration_factor);

           l_variable_rent := get_rent_applicable(
                                                  p_cumulative        => p_cumulative,
                                                  p_net_volume        => l_net_volume,
                                                  p_percent_days_open  => l_proration_factor);



           /* Insert/Update pn_var_rent_SUM_all */
            process_rent(P_VAR_RENT_ID   => g_var_rent_id,
                         P_PERIOD_ID     => g_period_id  ,
                         P_LINE_ITEM_ID  => p_line_item_id,
                         P_INVOICE_DATE  => g_invoice_date,
                         P_GROUP_DATE    => l_group_date,
                         P_TOT_VOL       => l_volume ,
                         P_TOT_DED       => l_tot_ded,
                         P_VAR_RENT      => ROUND(l_variable_rent,g_precision),
                         P_GRP_DATE_ID   => p_grp_date_id,
                         P_CALC_TYPE     => p_calc_TYPE,
                         P_CUMULATIVE    => p_cumulative);



pnp_debug_pkg.log('pn_variable_amount_pkg.calculate_var_rent (-) ');

END calculate_var_rent;



-------------------------------------------------------------------------------
--  FUNCTION     : get_rent_applicable
--  DESCRIPTION  : Apply breakpoints to volume amount applicable
--  INVOKED FROM :
--  ARGUMENTS    : IN : p_cumulative, p_net_volume, p_percent_days_open
--  RETURNS      : variable rent
--  HISTORY      :
--  28-dec-05  piagrawa  o Bug#3800523 - Added handling to calculate negative
--                         rent if sales volume does not trip the breakpoint
--                         in case of non-cumulative volume.Also commented
--                         the code.
-------------------------------------------------------------------------------


FUNCTION get_rent_applicable (p_cumulative IN VARCHAR2,
                              p_net_volume IN NUMBER,
                              p_percent_days_open IN NUMBER)
RETURN NUMBER
IS
l_bkpt_vol_start NUMBER;
l_bkpt_vol_end   NUMBER;
l_volume         NUMBER := 0;
l_rent           NUMBER := 0;
i                NUMBER := 0;
BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.get_rent_applicable (+) ');


IF p_cumulative = 'N' AND
   p_net_volume < (bkpt_range_tbl(1).group_bkpt_vol_start * p_percent_days_open)
THEN

  l_rent := ( p_net_volume -
              (bkpt_range_tbl(1).group_bkpt_vol_start * p_percent_days_open) )
            * bkpt_range_tbl(1).bkpt_rate;

ELSE

   IF g_breakpoint_TYPE in ('STRATIFIED') THEN

       i := 1;

       FOR i in 1 .. bkpt_range_tbl.COUNT
       LOOP

           l_bkpt_vol_start := null;
           l_bkpt_vol_end   := null;


           IF  p_cumulative = 'N' THEN
               l_bkpt_vol_start := bkpt_range_tbl(i).group_bkpt_vol_start;
               l_bkpt_vol_end   := bkpt_range_tbl(i).group_bkpt_vol_end;
           ELSIF p_cumulative = 'Y' THEN
               l_bkpt_vol_start := bkpt_range_tbl(i).period_bkpt_vol_start;
               l_bkpt_vol_end   := bkpt_range_tbl(i).period_bkpt_vol_end;
           END IF;


           IF (l_bkpt_vol_start * p_percent_days_open)  <= p_net_volume THEN

                IF p_net_volume <= NVL((l_bkpt_vol_end * p_percent_days_open),
                                        p_net_volume)       THEN

                    l_rent := l_rent + (p_net_volume - (l_bkpt_vol_start *
                                                        p_percent_days_open)
                                        ) * bkpt_range_tbl(i).bkpt_rate;

                    pnp_debug_pkg.log('get_rent_applicable - Breakpoint TYPE   :'||g_breakpoint_TYPE);
                    pnp_debug_pkg.log('p_net_volume <= l_bkpt_vol_end');
                    pnp_debug_pkg.log('get_rent_applicable - Net Volume :'|| p_net_volume);
                    pnp_debug_pkg.log('get_rent_applicable - Volume Applicable :'|| (p_net_volume - (l_bkpt_vol_start *
                                                         p_percent_days_open)));
                    pnp_debug_pkg.log('get_rent_applicable - bkpt rate :'||bkpt_range_tbl(i).bkpt_rate);
                    pnp_debug_pkg.log('get_rent_applicable - rent      :'||l_rent);


                ELSE
                    l_rent := l_rent + ((l_bkpt_vol_end * p_percent_days_open)-
                                        (l_bkpt_vol_start * p_percent_days_open)
                                        ) * bkpt_range_tbl(i).bkpt_rate;

                    pnp_debug_pkg.log('get_rent_applicable - Breakpoint TYPE :'||g_breakpoint_TYPE);
                    pnp_debug_pkg.log('p_net_volume > l_bkpt_vol_end ');
                    pnp_debug_pkg.log('get_rent_applicable - Net Volume :'|| p_net_volume);
                    pnp_debug_pkg.log('get_rent_applicable - Volume Applicable :'|| ((l_bkpt_vol_end *
                                 p_percent_days_open)- (l_bkpt_vol_start * p_percent_days_open)));
                    pnp_debug_pkg.log('get_rent_applicable - bkpt rate :'||bkpt_range_tbl(i).bkpt_rate);
                    pnp_debug_pkg.log('get_rent_applicable - rent      :'||l_rent);


                END IF;
           ELSE
                exit; -- get out NOCOPY of the loop;
           END IF;

       END LOOP;

   ELSIF  g_breakpoint_TYPE in ('SLIDING', 'FLAT') THEN
       i := 1;

       FOR i in 1 .. bkpt_range_tbl.COUNT
       LOOP

           l_bkpt_vol_start := null;
           l_bkpt_vol_end   := null;

           IF  p_cumulative = 'N' THEN
               l_bkpt_vol_start := bkpt_range_tbl(i).group_bkpt_vol_start;
               l_bkpt_vol_end   := bkpt_range_tbl(i).group_bkpt_vol_end;
           ELSIF p_cumulative = 'Y' THEN
               l_bkpt_vol_start := bkpt_range_tbl(i).period_bkpt_vol_start;
               l_bkpt_vol_end   := bkpt_range_tbl(i).period_bkpt_vol_end;
           END IF;


           IF (l_bkpt_vol_start * p_percent_days_open) <= p_net_volume AND
               p_net_volume <= NVL((l_bkpt_vol_end * p_percent_days_open), p_net_volume) THEN

                IF g_breakpoint_TYPE = 'SLIDING' THEN

                        l_rent := p_net_volume * bkpt_range_tbl(i).bkpt_rate;

                        pnp_debug_pkg.log('get_rent_applicable - Breakpoint TYPE :'||g_breakpoint_TYPE);
                        pnp_debug_pkg.log('get_rent_applicable - Net Volume      :'|| p_net_volume);
                        pnp_debug_pkg.log('get_rent_applicable - Volume Applicable :'|| p_net_volume);
                        pnp_debug_pkg.log('get_rent_applicable - bkpt rate     :'||bkpt_range_tbl(i).bkpt_rate);
                        pnp_debug_pkg.log('get_rent_applicable - rent          :'||l_rent);


                ELSIF g_breakpoint_TYPE = 'FLAT' THEN

                        l_rent := (p_net_volume - (l_bkpt_vol_start * p_percent_days_open)) *
                                                        bkpt_range_tbl(i).bkpt_rate;

                        pnp_debug_pkg.log('get_rent_applicable - Breakpoint TYPE  :'||g_breakpoint_TYPE);
                        pnp_debug_pkg.log('get_rent_applicable - Net Volume    :'|| p_net_volume);
                        pnp_debug_pkg.log('get_rent_applicable - Volume Applicable :'||
                                (p_net_volume - (l_bkpt_vol_start *  p_percent_days_open)));
                        pnp_debug_pkg.log('get_rent_applicable - bkpt rate    :'||bkpt_range_tbl(i).bkpt_rate);
                        pnp_debug_pkg.log('get_rent_applicable - Rent         :'||l_rent);



                END IF;
                exit;  -- get out NOCOPY of the loop
           END IF;

       END LOOP;

   END IF;
END IF;
RETURN l_rent;

pnp_debug_pkg.log('pn_variable_amount_pkg.get_rent_applicable (-) ');

END get_rent_applicable;


-----------------------------------------------------------------------------
-- PROCEDURE : process_rent
--
-- insert/update pn_var_rent_SUMm with the new variable rent
--
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_rent_SUMm with _ALL table.
-- 21-MAY-07    Lokesh o Added rounding off for bug # 6031202 in
--                       pn_var_rent_summ_all
-----------------------------------------------------------------------------

PROCEDURE process_rent (p_var_rent_id         IN NUMBER,
                        p_period_id           IN NUMBER,
                        p_line_item_id        IN NUMBER,
                        p_grp_date_id         IN NUMBER,
                        p_invoice_date        IN DATE,
                        p_group_date          IN DATE,
                        p_tot_vol             IN NUMBER,
                        p_tot_ded             IN NUMBER,
                        p_var_rent            IN NUMBER,
                        p_calc_TYPE           IN VARCHAR2,
                        p_cumulative          IN VARCHAR2
                       )
IS
l_varrent_exists   VARCHAR2(1) := 'N';
l_tot_act_vol      NUMBER := NULL;
l_act_var_rent     NUMBER := NULL;
l_tot_for_vol      NUMBER := NULL;
l_for_var_rent     NUMBER := NULL;
l_var_rent         NUMBER := 0;
l_cum_rent         NUMBER := 0;
l_adjust_num       NUMBER := 0;
l_var_rent_SUMm_id NUMBER := NULL;
l_invoice_date     DATE   := NULL;
l_period_id        NUMBER := NULL;
l_COUNT            NUMBER := 0;

CURSOR csr_cum_rent(p_line_item_id NUMBER,
                    p_group_date DATE) IS
SELECT NVL(decode(g_rent_TYPE,'FORECASTED',SUM(for_var_rent),SUM(act_var_rent)),0)
FROM pn_var_rent_summ_all
WHERE line_item_id = p_line_item_id
AND group_date < p_group_date;

BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.process_rent (+) ');

      /* insert into PL/SQL table invoice_tbl all the invoices dates
         for the period for which rent has been calculated. Info
         needed to update pn_var_Rent_inv table for the new amounts */

         FOR i in 1 .. invoice_tbl.COUNT
         LOOP
             if invoice_tbl(i).invoice_date = p_invoice_date AND
                invoice_tbl(i).period_id = p_period_id then
                l_invoice_date := invoice_tbl(i).invoice_date;
                l_period_id := invoice_tbl(i).period_id;
                exit;
             end if;

         END LOOP;

         IF l_invoice_date is null AND l_period_id is null THEN
            l_COUNT := invoice_tbl.COUNT + 1;
            invoice_tbl(l_COUNT).invoice_date := p_invoice_date;
            invoice_tbl(l_COUNT).period_id := p_period_id;
         END IF;


      /* if invoicing is on cumulative volume then subtract the SUM of the rent of
         of group dates less than the current group date from the rent of the
         current group date */

         l_var_rent := p_var_rent;

         IF p_cumulative ='Y' THEN

            OPEN csr_cum_rent(p_line_item_id,p_group_date);
            FETCH csr_cum_rent INTO l_cum_rent;
            CLOSE csr_cum_rent;

            l_var_rent := l_var_rent - l_cum_rent;
         END IF;

      /* find if a record exists in pn_var_rent_SUMm for the combination
         of line_item_id AND grp_date_id */

         l_varrent_exists :=  find_varrent_exists(
                                 p_line_item_id   => p_line_item_id,
                                 p_grp_date_id    => p_grp_date_id);
     fnd_message.set_name ('PN','PN_VRAM_RENT');
     fnd_message.set_token ('TYPE',INITCAP(g_rent_TYPE));
     fnd_message.set_token ('AMT',l_var_rent);
     pnp_debug_pkg.put_log_msg(fnd_message.get);

          IF NVL(l_varrent_exists,'N') = 'N' THEN

                  select pn_var_rent_SUMm_s.nextval
                  into l_var_rent_SUMm_id
                  from dual;

                  IF g_rent_TYPE = 'FORECASTED' THEN
                     l_tot_for_vol  := p_tot_vol;
                     l_for_var_rent := l_var_rent;
                  ELSIF g_rent_TYPE = 'ACTUAL' THEN
                     l_tot_act_vol  := p_tot_vol;
                     l_act_var_rent := l_var_rent;
                  END IF;


                  INSERT INTO pn_var_rent_summ_all
                          (VAR_RENT_SUMM_ID
                          ,VAR_RENT_ID
                          ,PERIOD_ID
                          ,LINE_ITEM_ID
                          ,INVOICE_DATE
                          ,TOT_ACT_VOL
                          ,TOT_FOR_VOL
                          ,TOT_DED
                          ,ACT_VAR_RENT
                          ,FOR_VAR_RENT
                          ,GRP_DATE_ID
                          ,GROUP_DATE
                          ,LAST_UPDATE_DATE
                          ,LAST_UPDATED_BY
                          ,CREATION_DATE
                          ,CREATED_BY
                          ,LAST_UPDATE_LOGIN
                          ,ORG_ID)
                  VALUES
                          (L_VAR_RENT_SUMM_ID
                          ,P_VAR_RENT_ID
                          ,P_PERIOD_ID
                          ,P_LINE_ITEM_ID
                          ,P_INVOICE_DATE
                          ,L_TOT_ACT_VOL
                          ,L_TOT_FOR_VOL
                          ,P_TOT_DED
                          ,round(L_ACT_VAR_RENT,g_precision)
                          ,round(L_FOR_VAR_RENT,g_precision)
                          ,P_GRP_DATE_ID
                          ,P_GROUP_DATE
                          ,SYSDATE
                          ,NVL(fnd_profile.value('USER_ID'),0)
                          ,SYSDATE
                          ,NVL(fnd_profile.value('USER_ID'),0)
                          ,NVL(fnd_profile.value('LOGIN_ID'),0)
                          ,g_org_id);

          ELSE

             /* update pn_var_rent_SUMm for the combination of line_item_id AND grp_date_id*/

               UPDATE pn_var_rent_SUMm_all
               SET tot_act_vol   = decode(g_rent_TYPE,'ACTUAL',p_tot_vol,tot_act_vol),
                   tot_ded       = decode(g_rent_TYPE,'ACTUAL',p_tot_ded,tot_ded),
                   act_var_rent  = decode(g_rent_TYPE,'ACTUAL',round(l_var_rent,g_precision),
                                          round(act_var_rent,g_precision)),
                   tot_for_vol   = decode(g_rent_TYPE,'FORECASTED',p_tot_vol,tot_for_vol),
                   for_var_rent  = decode(g_rent_TYPE,'FORECASTED',round(l_var_rent,g_precision),
                                          round(act_var_rent,g_precision)),
                   last_update_date = SYSDATE,
                   last_updated_by = NVL(fnd_profile.value('USER_ID'),0),
                   last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
               WHERE line_item_id = p_line_item_id
               AND   grp_date_id = p_grp_date_id;

          END IF;



   pnp_debug_pkg.log('pn_variable_amount_pkg.process_rent (-) ');

   EXCEPTION
   when others then
   pnp_debug_pkg.log('Error in pn_variable_amount_pkg.process_rent :'||TO_CHAR(sqlcode)||' : '||sqlerrm);
   raise;

END process_rent;


----------------------------------------------------------------------------
-- PROCEDURE  : Insert_invoice
--
--
-----------------------------------------------------------------------------
PROCEDURE Insert_invoice(p_calc_TYPE    IN VARCHAR2,
                         p_period_id    IN NUMBER,
                         p_var_rent_id  IN NUMBER)
IS
CURSOR csr_get_rent(ip_period_id NUMBER,
                    ip_invoice_date DATE) is
SELECT ROUND(SUM(act_var_rent),g_precision)  actual_rent,
       ROUND(SUM(for_var_rent),g_precision)  for_rent,
       ROUND( decode( SUM(act_var_rent),null,SUM(act_var_rent),
                      apply_constraints(ip_period_id,SUM(act_var_rent))
                    ),g_precision
            )constr_act_rent,
       (SUM(tot_act_vol) - SUM(tot_ded)) actual_volume
FROM pn_var_rent_summ_all
WHERE period_id= ip_period_id
AND invoice_date = ip_invoice_date;

CURSOR csr_get_invoice(ip_period_id NUMBER,
                       ip_invoice_date DATE)IS
SELECT inv_rent.rowid,
       inv_rent.var_rent_inv_id,
       inv_rent.adjust_num,
       inv_rent.for_per_rent,
       inv_rent.abatement_appl,
       inv_rent.negative_rent,
       inv_rent.rec_abatement,
       inv_rent.rec_abatement_override,
       inv_rent.forecasted_term_status,
       inv_rent.forecasted_exp_code,
       inv_rent.actual_exp_code,
       inv_rent.variance_exp_code
FROM pn_var_rent_inv_all inv_rent
WHERE inv_rent.period_id = ip_period_id
AND inv_rent.invoice_date = ip_invoice_date
AND inv_rent.adjust_num = (SELECT MAX(inv.adjust_num)
                           FROM pn_var_rent_inv_all inv
                           WHERE inv.invoice_date = inv_rent.invoice_date
                           AND inv.period_id = inv_rent.period_id);

CURSOR csr_cum_vol (ip_period_id NUMBER,
                    ip_invoice_date DATE) IS
SELECT (summ.tot_act_vol - NVL(summ.tot_ded,0)) cum_act_vol
FROM pn_var_rent_summ_all summ
WHERE summ.group_date = (SELECT MAX(summ1.group_date)
                         FROM pn_var_rent_summ_all summ1
                         WHERE summ1.invoice_date = ip_invoice_date
                         AND summ1.period_id = ip_period_id)
AND summ.period_id = ip_period_id;

l_actual_rent          NUMBER;
l_forecast_rent        NUMBER;
l_constr_act_rent      NUMBER;
l_rowid                ROWID := null;
l_adjust_num           NUMBER := 0;
l_for_rent             NUMBER;
l_abt_appl             NUMBER := 0;
l_negative_rent        NUMBER := 0;
l_for_term_status      pn_var_rent_inv.forecasted_term_status%TYPE:= 'N';
l_for_exp_code         pn_var_rent_inv.forecasted_exp_code%TYPE:= 'N';
l_actual_exp_code      pn_var_rent_inv.actual_exp_code%TYPE :='N';
l_variance_exp_code    pn_var_rent_inv.variance_exp_code%TYPE :='N';
l_var_rent_inv_id      NUMBER := null;
l_rent_TYPE            VARCHAR2(30);
l_rent_inv_id          NUMBER := null;
l_rowid_out            ROWID ;
l_insert               BOOLEAN := FALSE;
l_actual_invoiced_amt  pn_var_rent_inv.actual_invoiced_amount%TYPE := 0;
l_actual_volume        pn_var_rent_inv.tot_act_vol%TYPE;
l_rec_abatement        pn_var_rent_inv.rec_abatement%TYPE;
l_rec_abatement_override pn_var_rent_inv.rec_abatement_override%TYPE;

BEGIN
pnp_debug_pkg.log('pn_variable_amount_pkg.Insert_Invoice (+) ');

   if g_invoice_on = 'FORECASTED' AND g_rent_TYPE = 'ACTUAL' then
      l_rent_TYPE := 'VARIANCE';
   elsif g_invoice_on = 'FORECASTED' AND g_rent_TYPE = 'FORECASTED' then
      l_rent_TYPE := 'FORECASTED';
   elsif g_invoice_on = 'ACTUAL' AND g_rent_TYPE = 'ACTUAL' then
      l_rent_TYPE := 'ACTUAL';
   end if;


   /* Insert/Update pn_var_rent_inv only for those invoice dates for
      which calculation has been done by checking if that invoice
      date AND period id exists in invoice_tbl. This table has been populated
      in procedure process_rent */

   FOR i in 1.. invoice_tbl.COUNT
   LOOP

          open csr_get_rent (invoice_tbl(i).period_id, invoice_tbl(i).invoice_date);
          fetch csr_get_rent into l_actual_rent, l_forecast_rent, l_constr_act_rent,l_actual_volume;
          close csr_get_rent;

       /* If invoicing is on cumulative get the actual volume of the MAX group date from table
          pn_var_rent_SUMm because that will have the cumulative volume for the invoice date */

          IF g_cumulative = 'Y' THEN

             open csr_cum_vol(invoice_tbl(i).period_id, invoice_tbl(i).invoice_date);
             fetch csr_cum_vol into l_actual_volume;
             close csr_cum_vol;

          END IF;


        /* Get all the neccessary info from pn_var_rent_inv for invoice date AND period_id
           where adjust_num is MAXimum adjust num for that invoice date */

           l_rowid := null;

           open csr_get_invoice(invoice_tbl(i).period_id,invoice_tbl(i).invoice_date);
           fetch csr_get_invoice INTO l_rowid,l_var_rent_inv_id,l_adjust_num,l_for_rent,l_abt_appl,
                                      l_negative_rent,l_rec_abatement,l_rec_abatement_override,
                                      l_for_term_status,l_for_exp_code,l_actual_exp_code,l_variance_exp_code;

           IF csr_get_invoice%NOTFOUND THEN

            /*A record doesnt exist in pn_var_rent_inv for the combination of period_id AND invoice_date */

              l_insert := TRUE;
              l_adjust_num := 0;
              l_for_term_status := 'N';
              l_for_exp_code := 'N';
              l_rec_abatement := NULL;
              l_rec_abatement_override := NULL;

              IF l_rent_TYPE = 'FORECASTED' THEN
                l_abt_appl        := NULL;
                l_negative_rent   := NULL;
                l_actual_invoiced_amt := NULL;
              ELSE
                l_abt_appl        := 0;
                l_negative_rent   := 0;
              END IF;


           ELSE

              l_insert := FALSE;

              IF (g_invoice_on = 'ACTUAL' AND l_actual_exp_code = 'Y' ) OR
                 (g_invoice_on = 'FORECASTED' AND l_variance_exp_code = 'Y' ) THEN
                 l_insert := TRUE;
                 l_adjust_num := l_adjust_num + 1;
              ELSE
                 l_insert := FALSE;
              END IF;

           END IF;
           close csr_get_invoice;

          IF l_insert THEN

             pnp_debug_pkg.log('Insert_Invoice - inserting into pn_var_rent_inv');


             PN_VAR_RENT_INV_PKG.INSERT_ROW (
                  X_ROWID                   => l_rowid_out,
                  X_VAR_RENT_INV_ID         => l_rent_inv_id,
                  X_ADJUST_NUM              => l_adjust_num,
                  X_INVOICE_DATE            => invoice_tbl(i).invoice_date,
                  X_FOR_PER_RENT            => l_forecast_rent,
                  X_TOT_ACT_VOL             => l_actual_volume,
                  X_ACT_PER_RENT            => l_actual_rent,
                  X_CONSTR_ACTUAL_RENT      => l_constr_act_rent,
                  X_ABATEMENT_APPL          => l_abt_appl,
                  X_REC_ABATEMENT           => l_rec_abatement,
                  X_REC_ABATEMENT_OVERRIDE  => l_rec_abatement_override,
                  X_NEGATIVE_RENT           => l_negative_rent,
                  X_ACTUAL_INVOICED_AMOUNT  => l_actual_invoiced_amt,
                  X_PERIOD_ID               => invoice_tbl(i).period_id,
                  X_VAR_RENT_ID             => p_var_rent_id,
                  X_FORECASTED_TERM_STATUS  => l_for_term_status,
                  X_VARIANCE_TERM_STATUS    => 'N',
                  X_ACTUAL_TERM_STATUS      => 'N',
                  X_FORECASTED_EXP_CODE     => l_for_exp_code,
                  X_VARIANCE_EXP_CODE       => 'N',
                  X_ACTUAL_EXP_CODE         => 'N',
                  X_COMMENTS                => null,
                  X_ATTRIBUTE_CATEGORY      => null,
                  X_ATTRIBUTE1              => null,
                  X_ATTRIBUTE2              => null,
                  X_ATTRIBUTE3              => null,
                  X_ATTRIBUTE4              => null,
                  X_ATTRIBUTE5              => null,
                  X_ATTRIBUTE6              => null,
                  X_ATTRIBUTE7              => null,
                  X_ATTRIBUTE8              => null,
                  X_ATTRIBUTE9              => null,
                  X_ATTRIBUTE10             => null,
                  X_ATTRIBUTE11             => null,
                  X_ATTRIBUTE12             => null,
                  X_ATTRIBUTE13             => null,
                  X_ATTRIBUTE14             => null,
                  X_ATTRIBUTE15             => null,
                  X_CREATION_DATE           => SYSDATE,
                  X_CREATED_BY              => NVL(fnd_profile.value('USER_ID'),0),
                  X_LAST_UPDATE_DATE        => SYSDATE,
                  X_LAST_UPDATED_BY         => NVL(fnd_profile.value('USER_ID'),0),
                  X_LAST_UPDATE_LOGIN       => NVL(fnd_profile.value('LOGIN_ID'),0),
                  X_ORG_ID                  => g_org_id );

                  l_rent_inv_id := null;
                  l_rowid_out   := null;


          ELSE
                 pnp_debug_pkg.log('Insert_Invoice - Updating PN_VAR_RENT_INV ');

                    /* Delete payment terms from pn_payment_terms created
                       for the combination of var_rent_inv_id AND rent_TYPE
                       that are in the draft status since we are recalculating
                       AND updating the invoice for forecasted rent*/

                       DELETE from pn_payment_terms_all
                       WHERE var_rent_inv_id = l_var_rent_inv_id
                       AND status <> c_payment_term_status_approved
                       AND var_rent_TYPE = l_rent_TYPE;

                       UPDATE pn_var_rent_inv_all
                       SET for_per_rent = l_forecast_rent,
                           act_per_rent = l_actual_rent,
                           constr_actual_rent = l_constr_act_rent,
                           tot_act_vol = ROUND(l_actual_volume,g_precision), -- bug # 6007571
                           forecasted_term_status = decode(l_rent_TYPE,'FORECASTED','N',forecasted_term_status),
                           variance_term_status = decode(l_rent_TYPE,'VARIANCE','N',variance_term_status),
                           actual_term_status = decode(l_rent_TYPE,'ACTUAL','N',actual_term_status),
                           last_update_date = SYSDATE,
                           last_updated_by = NVL(fnd_profile.value('USER_ID'),0),
                           last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
                       WHERE rowid = l_rowid;

          END IF;


     END LOOP;  -- invoice_tbl

    pnp_debug_pkg.log('pn_variable_amount_pkg.Insert_Invoice (-)');

    EXCEPTION
    when others then
    pnp_debug_pkg.log('Error in pn_variable_amount_pkg.Insert_invoice :'||TO_CHAR(sqlcode)||' : '||sqlerrm);
    raise;

END Insert_invoice;

----------------------------------------------------------------------------
-- PROCEDURE  : apply_abatements
--
-- 30-Jan-2002  Pooja Sidhu    o Fix for bug# 2207343. Calculate negative rent available
--                               for every invoice date fetched from the cursor csr_get_inv.
--                               when applying negative rent.Removed condition to calculate
--                               negative rent available only for the first record fetched.
--
-- 11-Mar-2002  Pooja Sidhu    o Added logic for applying recurring abatements.
--
-----------------------------------------------------------------------------

PROCEDURE apply_abatements (p_var_rent_id IN NUMBER)
IS

/*get the invoices for all the periods from pn_var_rent_inv where the actual /actual-forecasted
  variable rent amount has not been transferred */

CURSOR csr_get_inv(p_var_rent_id NUMBER) is
SELECT inv.rowid,
       inv.adjust_num,
       inv.var_rent_inv_id,
       inv.constr_actual_rent,
       inv.actual_invoiced_amount,
       inv.abatement_appl,
       inv.negative_rent,
       inv.rec_abatement,
       inv.rec_abatement_override,
       inv.invoice_date
FROM pn_var_rent_inv_all inv
WHERE inv.var_rent_id = p_var_rent_id
AND inv.constr_actual_rent is not null
AND decode(g_invoice_on,'ACTUAL',inv.actual_exp_code,'FORECASTED',inv.variance_exp_code)='N'
ORDER BY inv.period_id,inv.invoice_date,inv.adjust_num;

/* Get the abatement amount defined in the agreements tab */

CURSOR csr_get_abt(ip_var_rent_id NUMBER)
IS
SELECT NVL(abatement_amount,0),
       negative_rent
FROM pn_var_rents_all
WHERE var_rent_id = ip_var_rent_id;

/* Get the abatement amount that has been applied to transferred invoices.
   Here we only consider those invoices where the adjust num is the MAXimum
   number for all the transferred invoices belonging to that invoice date */

CURSOR csr_get_abt_appl(ip_var_rent_id NUMBER)
IS
SELECT SUM(inv.abatement_appl)
FROM pn_var_rent_inv_all inv
WHERE inv.adjust_num =(SELECT MAX(inv1.adjust_num)
                       FROM pn_var_rent_inv_all inv1
                       WHERE inv1.invoice_date = inv.invoice_date
                       AND inv1.var_rent_id = inv.var_rent_id
                       AND decode(g_invoice_on,'ACTUAL',inv1.actual_exp_code,
                                               'FORECASTED',inv1.variance_exp_code)='Y')
AND inv.var_rent_id = ip_var_rent_id;

/* get the last invoice belonging to the variable rent.*/

CURSOR csr_last_inv(p_var_rent_id NUMBER)
IS
SELECT MAX(invoice_date)
FROM pn_var_grp_dates_all
WHERE var_rent_id = p_var_rent_id;

CURSOR csr_neg_avail (ip_var_rent_id  NUMBER,
                         ip_invoice_date DATE) IS
SELECT ABS(NVL(SUM(constr_actual_rent),0)) l_negative_avialable
FROM pn_var_rent_inv_all inv
WHERE inv.var_rent_id = ip_var_rent_id
AND   inv.invoice_date < ip_invoice_date
AND   inv.adjust_num = (select MAX(inv1.adjust_num)
                        from pn_var_rent_inv_all inv1
                        where inv1.var_rent_id = inv.var_rent_id
                        AND   inv1.invoice_date = inv.invoice_date)
AND   inv.constr_actual_rent < 0;

CURSOR csr_neg_appl (ip_var_rent_id  NUMBER,
                     ip_invoice_date DATE) IS
SELECT NVL(SUM(negative_rent),0)
FROM pn_var_rent_inv_all inv
WHERE inv.var_rent_id = ip_var_rent_id
AND   inv.invoice_date < ip_invoice_date
AND   inv.adjust_num = (select MAX(inv1.adjust_num)
                        from pn_var_rent_inv_all inv1
                        where inv1.var_rent_id = inv.var_rent_id
                        AND   inv1.invoice_date = inv.invoice_date);

CURSOR csr_prev_inv_amt (ip_var_rent_id NUMBER,
                         ip_invoice_date DATE,
                         ip_adjust_num   NUMBER) IS
SELECT NVL(SUM(actual_invoiced_amount),0)
FROM pn_var_rent_inv_all inv
WHERE inv.var_rent_id = ip_var_rent_id
AND   inv.invoice_date = ip_invoice_date
AND   inv.adjust_num < ip_adjust_num;


l_total_abatement      pn_var_rents.abatement_amount%TYPE := 0;
l_total_abt_appl       NUMBER := 0;
l_negative_rent        pn_var_rent_inv.negative_rent%TYPE := 0;
l_actual_invoice_amt   pn_var_rent_inv.actual_invoiced_amount%TYPE := 0;
l_negative_available   NUMBER := 0;
l_negative_applied     NUMBER := 0;
l_abatement_applied    NUMBER := 0;
l_negative_rent_flag   pn_var_rents.negative_rent%TYPE;
l_last_invoice_dt      pn_var_grp_dates.invoice_date%TYPE;
l_prev_invoiced_amt    NUMBER;
l_rec_abatement        NUMBER := 0;

BEGIN
pnp_debug_pkg.log('pn_variable_amount_pkg.apply_abatements  (+) :');


     OPEN  csr_get_abt(p_var_rent_id);
     FETCH csr_get_abt into l_total_abatement,l_negative_rent_flag;
     CLOSE csr_get_abt;
     OPEN  csr_get_abt_appl(p_var_rent_id);
     FETCH csr_get_abt_appl into l_total_abt_appl;
     CLOSE csr_get_abt_appl;


  /* Get the abatement avaiable as the difference of the total abatement avail to the
     variable rent AND the abatement that has already been applied to tranferred invoices*/

     l_total_abatement := l_total_abatement - NVL(l_total_abt_appl,0);

     /* Get the last invoice date belonging to the variable rent.*/

     OPEN csr_last_inv(p_var_rent_id);
     FETCH csr_last_inv into l_last_invoice_dt;
     CLOSE csr_last_inv;

     FOR rec_get_inv in csr_get_inv (p_var_rent_id => p_var_rent_id)
     LOOP
          l_negative_available := 0;
          l_negative_applied   := 0;
          l_negative_rent      :=0;
          l_abatement_applied  := 0;
          l_actual_invoice_amt := 0;
          l_prev_invoiced_amt  := 0;
          l_rec_abatement      := 0;

          IF l_negative_rent_flag = 'DEFER' AND (rec_get_inv.invoice_date = l_last_invoice_dt or
                                                 rec_get_inv.constr_actual_rent > 0)     THEN

              /* Get the negative rent avaiable */
              open csr_neg_avail(p_var_rent_id, rec_get_inv.invoice_date);
              fetch csr_neg_avail into l_negative_available;
              close csr_neg_avail;

              /* Get the negative rent applied */
              open csr_neg_appl(p_var_rent_id, rec_get_inv.invoice_date);
              fetch csr_neg_appl into l_negative_applied;
              close csr_neg_appl;

              pnp_debug_pkg.log('apply_abatements - Invoice Date           :'||rec_get_inv.invoice_date);
              pnp_debug_pkg.log('apply_abatements - Negative Rent Avaiable :'||l_negative_available);
              pnp_debug_pkg.log('apply_abatements - Negative Rent Applied  :'||l_negative_applied);

              l_negative_available := l_negative_available - l_negative_applied;

           END IF;


           /* Get the rent transferred for the invoice date */

           open csr_prev_inv_amt(p_var_rent_id,  rec_get_inv.invoice_date, rec_get_inv.adjust_num);
           fetch csr_prev_inv_amt into l_prev_invoiced_amt;
           close csr_prev_inv_amt;

           /* Apply negative rent */

           IF l_negative_rent_flag = 'DEFER' AND
              rec_get_inv.invoice_date = l_last_invoice_dt then

                    l_actual_invoice_amt := (rec_get_inv.constr_actual_rent - l_negative_available)
                                              - l_prev_invoiced_amt;
                    l_negative_rent := l_negative_available;

           ELSIF rec_get_inv.constr_actual_rent < 0 then

              l_negative_rent := 0;

              IF l_negative_rent_flag = 'IGNORE' THEN
                 l_actual_invoice_amt := 0 - l_prev_invoiced_amt;

              ELSIF l_negative_rent_flag = 'CREDIT' THEN

                 l_actual_invoice_amt := rec_get_inv.constr_actual_rent - l_prev_invoiced_amt;

              ELSIF l_negative_rent_flag = 'DEFER' THEN

                 l_actual_invoice_amt := 0 - l_prev_invoiced_amt;

              END IF;

            ELSE
                  l_negative_rent := LEAST(rec_get_inv.constr_actual_rent, l_negative_available);

                  l_actual_invoice_amt := (rec_get_inv.constr_actual_rent - l_prev_invoiced_amt) -
                                           l_negative_rent;
            END IF;


            /* Apply abatements */

            IF l_actual_invoice_amt > 0 THEN
                IF rec_get_inv.adjust_num = 0  AND l_total_abatement >= 0 THEN
                   l_abatement_applied := LEAST(l_actual_invoice_amt, l_total_abatement);
                   l_actual_invoice_amt:= l_actual_invoice_amt - LEAST(l_actual_invoice_amt, l_total_abatement);
                   l_total_abatement   := l_total_abatement - l_abatement_applied;
                ELSE
                   l_actual_invoice_amt:= l_actual_invoice_amt - NVL(rec_get_inv.abatement_appl,0);
                   l_abatement_applied := rec_get_inv.abatement_appl;
                END IF;
            END IF;

            /* Apply recurring Abatements */

            pnp_debug_pkg.log('apply_abatements - l_actual_invoice_amt :'||l_actual_invoice_amt);
            pnp_debug_pkg.log('applying recurring Abatements ... ');

            IF rec_get_inv.adjust_num > 0 THEN
               l_rec_abatement := NVL(rec_get_inv.rec_abatement_override,rec_get_inv.rec_abatement);
            ELSIF l_actual_invoice_amt > 0 THEN
               l_rec_abatement := NVL(rec_get_inv.rec_abatement_override,
                                      LEAST(l_actual_invoice_amt,rec_get_inv.rec_abatement));
            ELSIF l_actual_invoice_amt <= 0 THEN
               l_rec_abatement := rec_get_inv.rec_abatement_override;
            END IF;

            l_actual_invoice_amt := l_actual_invoice_amt -  NVL(l_rec_abatement,0) ;

            pnp_debug_pkg.log('apply_abatements - l_rec_abatement :  '||l_rec_abatement);
            pnp_debug_pkg.log('apply_abatements - l_actual_invoice_amt :'|| l_actual_invoice_amt);
            pnp_debug_pkg.log('apply_abatements - l_negative_rent :'||l_negative_rent);
            pnp_debug_pkg.log('apply_abatements - rec_get_inv.negative_rent :'||rec_get_inv.negative_rent);
            pnp_debug_pkg.log('apply_abatements - l_abatement_applied :'||l_abatement_applied);
            pnp_debug_pkg.log('apply_abatements - rec_get_inv.abatement_appl :'||rec_get_inv.abatement_appl);
            pnp_debug_pkg.log('apply_abatements - l_abatement_applied :'||l_abatement_applied);
            pnp_debug_pkg.log('recurring abt applied - l_rec_abatement:'||l_rec_abatement);
            pnp_debug_pkg.log('apply_abatements - l_actual_invoice_amt :'||l_actual_invoice_amt);
            pnp_debug_pkg.log('apply_abatements- rec_get_inv.actual_invoiced_amount :'||rec_get_inv. actual_invoiced_amount);

            IF l_negative_rent = rec_get_inv.negative_rent AND
               l_abatement_applied = rec_get_inv.abatement_appl AND
               l_actual_invoice_amt = rec_get_inv.actual_invoiced_amount or
               ((l_negative_rent is null AND rec_get_inv.negative_rent is null) AND
               (l_abatement_applied is null AND rec_get_inv.abatement_appl is null) AND
               (l_actual_invoice_amt is null AND rec_get_inv.actual_invoiced_amount is null)) THEN

                null;

            ELSE

                DELETE from pn_payment_terms_all
                WHERE status <> c_payment_term_status_approved
                AND var_rent_inv_id = rec_get_inv.var_rent_inv_id
                AND var_rent_TYPE = decode(g_invoice_on,'ACTUAL','ACTUAL','FORECASTED','VARIANCE');

                UPDATE pn_var_rent_inv_all
                SET abatement_appl = l_abatement_applied,
                    actual_invoiced_amount = l_actual_invoice_amt,
                    negative_rent = l_negative_rent,
                    actual_term_status = 'N',
                    variance_term_status = 'N',
                    last_update_date = SYSDATE,
                    last_updated_by = NVL(fnd_profile.value('USER_ID'),0),
                    last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0)
                WHERE rowid = rec_get_inv.rowid;

            END IF;


     END LOOP;

     pnp_debug_pkg.log('pn_variable_amount_pkg.apply_abatements  (-):');

     EXCEPTION
     when others then
     pnp_debug_pkg.log('Error in pn_variable_amount_pkg.apply_abatements :'||TO_CHAR(sqlcode)||' : '||sqlerrm);
     raise;

END apply_abatements;

-----------------------------------------------------------------------------
-- PROCEDURE : apply_constraints
--
-- Based upon the value passed for constr_cat_code get the constraints by period
--
-----------------------------------------------------------------------------
FUNCTION apply_constraints(p_period_id IN NUMBER,
                           p_actual_rent IN NUMBER)
RETURN NUMBER
IS
Cursor csr_get_constr(p_period_id NUMBER) is
SELECT TYPE_code,
       amount
FROM pn_var_constraints_all
WHERE period_id = p_period_id
AND constr_cat_code = 'VARENT';

l_lower_bound NUMBER;
l_upper_bound NUMBER;
l_constr_act_rent NUMBER;

BEGIN
    pnp_debug_pkg.log( 'pn_variable_amount_pkg.apply_constraints  : (+) ');

    FOR rec_get_constr in csr_get_constr(p_period_id)
    LOOP
       IF rec_get_constr.TYPE_code = 'MIN' THEN
           l_lower_bound := rec_get_constr.amount;
       ELSIF rec_get_constr.TYPE_code = 'MAX' THEN
           l_upper_bound := rec_get_constr.amount;
       END IF;
    END LOOP;

    /* Apply constraints to Actual variable rent */

   pnp_debug_pkg.log('apply_constraints - Lower bound :'|| l_lower_bound);
   pnp_debug_pkg.log('apply_constraints - Upper bound :'|| l_upper_bound);
   pnp_debug_pkg.log('apply_constraints - Actual Rent :'|| p_actual_rent);

   IF p_actual_rent < NVL(l_lower_bound,p_actual_rent) THEN
        l_constr_act_rent := l_lower_bound;
   ELSIF p_actual_rent > NVL(l_upper_bound,p_actual_rent) THEN
        l_constr_act_rent := l_upper_bound;
   ELSE
        l_constr_act_rent := p_actual_rent;
   END IF;

   pnp_debug_pkg.log('apply_constraints - Constrained Actual rent :'||l_constr_act_rent);

   RETURN l_constr_act_rent;
   pnp_debug_pkg.log( 'pn_variable_amount_pkg.apply_constraints  : (-) ');
END apply_constraints;

-----------------------------------------------------------------------------
-- FUNCTION : find_varrent_exists
--
-- find if row exists for line_item_id,grp_date_id combination
-- in table pn_var_rent_SUMm
--
-----------------------------------------------------------------------------
FUNCTION find_varrent_exists (p_line_item_id IN NUMBER,
                              p_grp_date_id IN NUMBER)
RETURN VARCHAR2
IS

l_varrent_exists VARCHAR2(1) := 'N';

BEGIN

     pnp_debug_pkg.log('pn_variable_amount_pkg.find_varrent_exists (+) ');

     SELECT 'Y'
     INTO l_varrent_exists
     FROM dual
     WHERE EXISTS (SELECT null
                   FROM pn_var_rent_summ_all
                   WHERE line_item_id = p_line_item_id
                   AND grp_date_id = p_grp_date_id);

    RETURN l_varrent_exists;

EXCEPTION
WHEN no_data_found
THEN RETURN 'N';

pnp_debug_pkg.log('pn_variable_amount_pkg.find_varrent_exists (-) ');

END find_varrent_exists;


----------------------------------------------------------------------------
-- PROCEDURE : get_transferred_flag
--
----------------------------------------------------------------------------

PROCEDURE get_transferred_flag(p_period_id IN NUMBER,
                               p_invoice_date IN DATE,
                               p_actual_flag  OUT NOCOPY VARCHAR2,
                               p_forecasted_flag OUT NOCOPY VARCHAR2,
                               p_variance_flag OUT NOCOPY VARCHAR2)
IS
BEGIN
pnp_debug_pkg.log('pn_variable_amount_pkg.get_transferred_flag  (+) ');

   SELECT distinct actual_exp_code,forecasted_exp_code,variance_exp_code
   INTO p_actual_flag,p_forecasted_flag,p_variance_flag
   FROM pn_var_grp_dates_all
   WHERE period_id = p_period_id
   AND invoice_date = p_invoice_date;

EXCEPTION
   WHEN no_data_found then null;
   WHEN others then pnp_debug_pkg.log ('Error in pn_variable_amount_pkg.get_transferred_flag :'||
                                      TO_CHAR(sqlcode)||': '||sqlerrm);

pnp_debug_pkg.log('pn_variable_amount_pkg.get_transferred_flag  (-) ');

END get_transferred_flag;


------------------------------------------------------------------------
-- PROCEDURE  : get_percent_open
-- PARAMETERS : p_var_rent_id
--
-- get the percent days open for each group date
------------------------------------------------------------------------


PROCEDURE get_percent_open (p_period_id  IN NUMBER,
                            p_cumulative IN VARCHAR2,
                            p_start_date IN DATE,
                            p_end_date   IN DATE )
IS
l_proration_factor NUMBER;
l_no_of_days       NUMBER;
i NUMBER :=0;

BEGIN
pnp_debug_pkg.log('pn_variable_amount_pkg.get_percent_open (+) ');

  /* Initialize the PL/SQL table */
    grd_date_tbl.delete;

 /* Get the group dates proration_factor */

    FOR rec_get_gd in csr_get_gd(p_period_id)
    LOOP
        i := i+1;

       /* While deriving the proration factor we are asSUMing the following :
          o If invoicing is on cumulative proration factor is the number of days in the period/
            the number of days in the in the gl calendar period. Proration factor should have a
            value of 1 if the period is not the first or last period.
          o if invoicing is on non cumulative proration factor is the number of days in the
            reporting period divided by the number of days specified in gl calendar period.
            Proration factor should have a value of 1 if the group date is not the first or last grp
            date of the  variable rent agreement.*/

        IF NVL(p_cumulative,'N') = 'Y' THEN
           l_no_of_days := (p_end_date - p_start_date) + 1;
        ELSE
           l_no_of_days := (rec_get_gd.grp_end_date - rec_get_gd.grp_start_date) + 1;
        END IF;

        l_proration_factor := l_no_of_days / rec_get_gd.proration_factor;

        grd_date_tbl(i).grp_date_id  := rec_get_gd.grp_date_id;
        grd_date_tbl(i).proration_factor := l_proration_factor;
        grd_date_tbl(i).invoice_date := rec_get_gd.invoice_date;
        grd_date_tbl(i).group_date   := rec_get_gd.group_date;

        pnp_debug_pkg.log('get_percent_open - group date          : '||rec_get_gd.group_date);
        pnp_debug_pkg.log('get_percent_open - l_no_of_days        : '||l_no_of_days);
        pnp_debug_pkg.log('get_percent_open - l_proration_factor  : '||l_proration_factor);

    END LOOP;

pnp_debug_pkg.log('pn_variable_amount_pkg.get_percent_open (-) ');

EXCEPTION
when others then
pnp_debug_pkg.log('Error in pn_variable_amount_pkg.get_percent_open :'||TO_CHAR(sqlcode)||' : '||sqlerrm);

END get_percent_open;


-------------------------------------------
-- Function : get_deductions
--
-- Get the deductions applicable for all the group dates in a line_item_id
--
-------------------------------------------

PROCEDURE get_deductions(p_line_item_id  IN NUMBER)
IS
i NUMBER :=0;

BEGIN

   pnp_debug_pkg.log('pn_variable_amount_pkg.get_deductions (+) ');

   /* Initialize the PL/SQL table */
    deduction_tbl.delete;

   /* store the deductions in PL/SQL table */
   FOR rec_get_ded in csr_get_ded(p_line_item_id => p_line_item_id)
      LOOP

      i := i + 1;

      deduction_tbl(i).grp_date_id   := rec_get_ded.grp_date_id;
      deduction_tbl(i).deduction_amt := rec_get_ded.deduction_amt;

      END LOOP;

   pnp_debug_pkg.log('pn_variable_amount_pkg.get_deductions (-) ');

END get_deductions;



-------------------------------------------------------------------------------
-- Procedure :  get_bkp_details
-- Parameter :  p_line_item_id
--
-- Store the period breakpoint details AND group breakpoint details for a line
-- item id in a PL/SQL table.
-------------------------------------------------------------------------------

PROCEDURE get_bkp_details (p_line_item_id IN NUMBER)
IS

i NUMBER :=0;

BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.get_bkp_details (+) ');

/* Initialize the PL/SQL table */
bkpt_range_tbl.delete;

/* store the break point range in PL/SQL table */
FOR rec_bkpt_range in csr_bkpt_range(p_line_item_id => p_line_item_id)
   LOOP

   i := i + 1;

   bkpt_range_tbl(i).period_bkpt_vol_start := rec_bkpt_range.period_bkpt_vol_start;
   bkpt_range_tbl(i).period_bkpt_vol_end   := rec_bkpt_range.period_bkpt_vol_end;
   bkpt_range_tbl(i).group_bkpt_vol_start  := rec_bkpt_range.group_bkpt_vol_start;
   bkpt_range_tbl(i).group_bkpt_vol_end    := rec_bkpt_range.group_bkpt_vol_end;
   bkpt_range_tbl(i).bkpt_rate             := rec_bkpt_range.bkpt_rate;
   g_breakpoint_TYPE                       := rec_bkpt_range.breakpoint_TYPE;


   END LOOP;

pnp_debug_pkg.log('pn_variable_amount_pkg.get_bkp_details (-) ');

END get_bkp_details;


------------------------------------------------------------------------
-- PROCEDURE : get_cum_vol_by_grpdt
--
-- Get the cumulative volume from the PL/SQL table cum_vol_tbl
--
------------------------------------------------------------------------
PROCEDURE get_cum_vol_by_grpdt(p_grp_date_id IN NUMBER,
                               p_cum_actual_vol OUT NOCOPY NUMBER,
                               p_cum_for_vol OUT NOCOPY NUMBER,
                               p_cum_ded OUT NOCOPY NUMBER)
IS
i NUMBER := 1;
BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.get_cum_vol_by_grpdt (+) ');

   /* Get the existing cumulative actual AND forecasted  volume for all the
      group date prior to this group date AND put them in the
      p_act_cum_vol  AND p_for_cum_vol */

     FOR i in 1.. cum_vol_tbl.COUNT
        LOOP
           IF cum_vol_tbl(i).grp_date_id = p_grp_date_id THEN

               p_cum_actual_vol := cum_vol_tbl(i).cum_actual_vol;
               p_cum_for_vol := cum_vol_tbl(i).cum_for_vol;
               p_cum_ded := cum_vol_tbl(i).cum_ded;
               exit;

           END IF;
        END LOOP;

pnp_debug_pkg.log('pn_variable_amount_pkg.get_cum_vol_by_grpdt (-) ');

END;

------------------------------------------------------------------------
-- PROCEDURE  : get_cumulative_volume
-- PARAMETERS :
--
-- Get cumulative actual amount AND cumulative forecasted amount
-- from volume history table for each group date AND store in the
-- PL/SQL table cum_vol_tbl per line.
------------------------------------------------------------------------
PROCEDURE get_cumulative_volume (p_line_item_id IN NUMBER)
IS

l_cum_actual_vol NUMBER := 0;
l_cum_for_vol    NUMBER := 0;
l_cum_ded        NUMBER := 0;
l_deduction      NUMBER := 0;
i                NUMBER := 0;
j                NUMBER := 0;


BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.get_cumulative_volume (+) ');

   /* Initialize the PL/SQL table */
   cum_vol_tbl.delete;

   FOR rec_cumulative_vol in csr_cumulative_vol(p_line_item_id => p_line_item_id)
     LOOP

        i := i + 1;
        j := 0;

        cum_vol_tbl(i).grp_date_id  := rec_cumulative_vol.grp_date_id;
        l_deduction := 0;

        FOR l_ded_COUNT in 1 .. deduction_tbl.COUNT
        LOOP
               j := j + 1;
              IF deduction_tbl(j).grp_date_id = rec_cumulative_vol.grp_date_id THEN
                 l_deduction := NVL(deduction_tbl(j).deduction_amt,0);
                 exit;
              END IF;

        END LOOP;

        /* if actual volume for that grp date is null then dont calculate cumulative vol */

        IF rec_cumulative_vol.cum_actual_vol is null THEN
            cum_vol_tbl(i).cum_actual_vol := null;
        ELSE
            l_cum_actual_vol := l_cum_actual_vol + rec_cumulative_vol.cum_actual_vol;
            cum_vol_tbl(i).cum_actual_vol := l_cum_actual_vol;
            l_cum_ded := l_cum_ded + NVL(l_deduction,0);
            cum_vol_tbl(i).cum_ded := l_cum_ded;
        END IF;

        /* if forecasted volume for that grp date is null then cumulative vol for that grp date is null also*/

        IF rec_cumulative_vol.cum_for_vol is null THEN
           cum_vol_tbl(i).cum_for_vol := null;
        ELSE
           l_cum_for_vol := l_cum_for_vol  + rec_cumulative_vol.cum_for_vol;
           cum_vol_tbl(i).cum_for_vol    := l_cum_for_vol;
        END IF;

     END LOOP;

pnp_debug_pkg.log('pn_variable_amount_pkg.get_cumulative_volume (-) ');

END get_cumulative_volume;


------------------------------------------------------------------------------------
-- PROCEDURE  : get_varrent_details
--
--
-----------------------------------------------------------------------------------

PROCEDURE get_varrent_details (p_var_rent_id IN NUMBER,
                               p_cumulative OUT NOCOPY VARCHAR2,
                               p_invoice_on OUT NOCOPY VARCHAR2,
                               p_negative_rent OUT NOCOPY VARCHAR2)
IS
BEGIN

   pnp_debug_pkg.log( 'pn_variable_amount_pkg.get_varrent_details  : (+) ');

   SELECT cumulative_vol,
          invoice_on,
          negative_rent
   INTO p_cumulative,
        p_invoice_on,
        p_negative_rent
   FROM pn_var_rents_all
   WHERE var_rent_id = p_var_rent_id;

   pnp_debug_pkg.log( 'pn_variable_amount_pkg.get_varrent_details  : (-) ');

END get_varrent_details;

------------------------------------------------------------------------------------
-- PROCEDURE  : find_if_term_exists
--
--
-----------------------------------------------------------------------------------

FUNCTION find_if_term_exists (p_var_rent_inv_id IN NUMBER,
                              p_var_rent_type IN VARCHAR2)
RETURN VARCHAR2
IS
l_term_exists   VARCHAR2(1) := 'N';
BEGIN

   put_log( 'pn_variable_amount_pkg.find_if_term_exists (+): ');

   /* pinky - codev */
   IF p_var_rent_type IN ('ADJUSTMENT') THEN

      SELECT 'Y'
      INTO l_term_exists
      FROM DUAL
      WHERE exists ( SELECT null
                     FROM pn_payment_terms_all
                     WHERE var_rent_inv_id = p_var_rent_inv_id
                     AND var_rent_TYPE IN ('ACTUAL', 'VARIANCE'));
   ELSE
      SELECT 'Y'
      INTO l_term_exists
      FROM DUAL
      WHERE exists ( SELECT null
                     FROM pn_payment_terms_all
                     WHERE var_rent_inv_id = p_var_rent_inv_id
                     AND var_rent_TYPE = p_var_rent_TYPE);
   END IF;



   /* pinky - codev */

RETURN l_term_exists;
EXCEPTION
WHEN no_data_found then
  RETURN 'N';

put_log( 'pn_variable_amount_pkg.find_if_term_exists  (-): ');

END find_if_term_exists;


------------------------------------------------------------------------------------
-- PROCEDURE  : find_volume_exists
--
-- Find if actual or forecasted volume history exists for all the group dates
-- AND line items in an invoice date
-- 04-OCT-2002  Ashish Kumar   --BUG#2643435 remove the outer join (+) in the select stmt.
-----------------------------------------------------------------------------------

FUNCTION find_volume_exists (p_period_id IN NUMBER,
                             p_invoice_date IN DATE,
                             p_var_rent_TYPE IN VARCHAR2)
RETURN VARCHAR2
IS
l_volume_exists VARCHAR2(1) := 'N';

BEGIN
    pnp_debug_pkg.log('pn_variable_amount_pkg.find_volume_exists (+) : ');

        SELECT 'Y'
        INTO l_volume_exists
        FROM dual
        WHERE not exists (SELECT null
                          FROM pn_var_rent_summ_all summ,
                               (SELECT gd.period_id,
                                       lines.line_item_id,
                                       gd.grp_date_id
                                FROM pn_var_lines_all lines,
                                     pn_var_grp_dates_all gd
                                WHERE gd.period_id = lines.period_id
                                AND gd.period_id= p_period_id
                                AND gd.invoice_date =p_invoice_date) itemp
                          WHERE  SUMm.grp_date_id  = itemp.grp_date_id
                          AND SUMm.line_item_id = itemp.line_item_id
                          GROUP by itemp.period_id,itemp.line_item_id,itemp.grp_date_id
                          HAVING ((SUM(SUMm.tot_act_vol) is null AND p_var_rent_TYPE = 'ACTUAL') OR
                                  (SUM(SUMm.tot_for_vol) is null AND p_var_rent_TYPE = 'FORECASTED'))
                          );


    RETURN l_volume_exists;

EXCEPTION
WHEN no_data_found then
    RETURN 'N';

    pnp_debug_pkg.log('pn_variable_amount_pkg.find_volume_exists (-) : ');
END find_volume_exists;

----------------------------------------------------------------------------
-- FUNCTION : get_prior_transfer_flag
-- Returns 'Y' if there exists a payment term belonging to an invoice date
-- prior to the p_invoice_date that has not been transferred
----------------------------------------------------------------------------

FUNCTION get_prior_transfer_flag(p_var_rent_inv_id NUMBER,
                                 p_var_rent_TYPE   VARCHAR2,
                                 p_var_rent_id     NUMBER)
RETURN VARCHAR2 IS

l_exists VARCHAR2(1) := 'N';

CURSOR get_inv_info(p_var_rent_inv_id NUMBER,
                    p_var_rent_TYPE   VARCHAR2,
                    p_var_rent_id     NUMBER,
                    p_period_id       NUMBER) IS
SELECT 'Y' term_exists
FROM dual
WHERE EXISTS (SELECT null
              FROM  pn_var_rent_inv_all inv
              WHERE inv.forecasted_exp_code = decode(p_var_rent_TYPE,'FORECASTED','N',inv.forecasted_exp_code)
              AND   inv.actual_exp_code = decode(p_var_rent_TYPE,'ACTUAL','N',inv.actual_exp_code)
              AND   inv.variance_exp_code = decode(p_var_rent_TYPE,'VARIANCE','N',inv.variance_exp_code)
              AND   inv.invoice_date < ( SELECT inv1.invoice_date
                                         FROM pn_var_rent_inv_all inv1
                                         WHERE inv1.var_rent_inv_id = p_var_rent_inv_id)
              AND   inv.period_id  = nvl(p_period_id,inv.period_id)
              AND   inv.var_rent_id = p_var_rent_id);


/* Cursor for adjustment invoices */
CURSOR get_inv_adj_info(p_var_rent_inv_id NUMBER,
                        p_var_rent_TYPE   VARCHAR2,
                        p_var_rent_id     NUMBER,
                        p_period_id       NUMBER) IS
SELECT 'Y' term_exists
FROM dual
WHERE EXISTS (SELECT null
              FROM  pn_var_rent_inv_all inv
              WHERE inv.actual_exp_code = 'N'
              AND   inv.forecasted_exp_code = 'N'
              AND   inv.variance_exp_code = 'N'
              AND   inv.invoice_date < ( SELECT inv1.invoice_date
                                         FROM pn_var_rent_inv_all inv1
                                         WHERE inv1.var_rent_inv_id = p_var_rent_inv_id)
              AND   inv.period_id  = nvl(p_period_id,inv.period_id)
              AND   inv.var_rent_id = p_var_rent_id);


CURSOR first_period_cur IS
  SELECT pvp.period_id
  FROM pn_var_rents_all pvr , pn_var_periods_all pvp
  WHERE pvr.var_rent_id = p_var_rent_id
  AND pvr.var_rent_id = pvp.var_rent_id
  AND proration_rule IN ('FY', 'FLY')
  AND pvp.start_date = pvr.commencement_date;


-- Get the details of
CURSOR period_cur IS
  SELECT period_id
    FROM pn_var_rent_inv_all
   WHERE var_rent_inv_id = p_var_rent_inv_id;

l_period_id  NUMBER;
l_cur_period_id NUMBER := NULL;

BEGIN
pnp_debug_pkg.log('pn_variable_amount_pkg.get_prior_transfer_flag (+) : ');


   FOR rec IN period_cur LOOP
     l_period_id := rec.period_id;
   END LOOP;

   /* This is a special handling done for FY/FLY as in these we create first year term with an
      invoice date lying in second year has period id of first year */
   FOR first_period_rec IN first_period_cur LOOP
     IF first_period_rec.period_id = l_period_id THEN
         l_cur_period_id := l_period_id;
     END IF;
   END LOOP;

   IF p_var_rent_TYPE IN ('FORECASTED', 'ACTUAL', 'VARIANCE') THEN

      FOR for_rec IN  get_inv_info (p_var_rent_inv_id, p_var_rent_TYPE, p_var_rent_id, l_cur_period_id ) LOOP
         l_exists := for_rec.term_exists;
      END LOOP;

   ELSIF p_var_rent_TYPE = 'ADJUSTMENT' THEN
      FOR adj_rec IN  get_inv_adj_info (p_var_rent_inv_id, p_var_rent_TYPE, p_var_rent_id, l_cur_period_id) LOOP
         l_exists := adj_rec.term_exists;
      END LOOP;

   END IF;

   RETURN l_exists;

pnp_debug_pkg.log('pn_variable_amount_pkg.get_prior_transfer_flag (-) : ');

END get_prior_transfer_flag;

----------------------------------------------------------------------------
-- FUNCTION : get_prev_inv_amt
--
----------------------------------------------------------------------------

FUNCTION get_prev_inv_amt (p_var_rent_id NUMBER,
                           p_invoice_date DATE,
                           p_adjust_num NUMBER)
RETURN NUMBER IS
CURSOR csr_prev_inv_amt (ip_var_rent_id NUMBER,
                         ip_invoice_date DATE,
                         ip_adjust_num   NUMBER) IS
SELECT SUM(actual_invoiced_amount)
FROM pn_var_rent_inv_all inv
WHERE inv.var_rent_id = ip_var_rent_id
AND   inv.invoice_date = ip_invoice_date
AND   inv.adjust_num < ip_adjust_num;

l_prev_inv_amt NUMBER := 0;

BEGIN

pnp_debug_pkg.log('pn_variable_amount_pkg.get_prev_inv_amt (+) : ');

OPEN csr_prev_inv_amt(p_var_rent_id,p_invoice_date,p_adjust_num);
FETCH csr_prev_inv_amt INTO l_prev_inv_amt;
CLOSE csr_prev_inv_amt;

RETURN l_prev_inv_amt;

pnp_debug_pkg.log('pn_variable_amount_pkg.get_prev_inv_amt (-) : ');

END get_prev_inv_amt;

-------------------------------------------------------------------------------------------------
---
--- FUNCTION get_vol_ded
---
-------------------------------------------------------------------------------------------------

FUNCTION get_vol_ded(p_line_item_id NUMBER,
                     p_group_date DATE,
                     p_TYPE VARCHAR2)
RETURN NUMBER IS
CURSOR csr_vol (p_line_item_id NUMBER,
                p_group_date DATE) IS
SELECT summ.tot_act_vol,
       summ.tot_for_vol,
       summ.tot_ded,
       decode(vrent.cumulative_vol ,'N','N','T','N','Y')
FROM pn_var_rent_summ_all summ,
     pn_var_rents_all vrent
WHERE summ.line_item_id = p_line_item_id
AND summ.group_date = p_group_date
AND summ.var_rent_id = vrent.var_rent_id;

CURSOR csr_prev_vol(p_line_item_id NUMBER,
                    p_group_date DATE) IS
SELECT nvl(summ.tot_act_vol,0),
       nvl(summ.tot_for_vol,0),
       nvl(summ.tot_ded,0)
FROM pn_var_rent_summ_all summ
WHERE summ.group_date =(SELECT max(summ1.group_date)
                        FROM pn_var_rent_summ_all summ1
                        WHERE summ1.group_date < p_group_date
                        AND summ1.line_item_id = p_line_item_id)
AND summ.line_item_id = p_line_item_id;

l_tot_act_vol    NUMBER :=0;
l_tot_for_vol    NUMBER :=0;
l_tot_ded        NUMBER :=0;
l_cumulative_vol pn_var_rents.cumulative_vol%type;
l_prev_act_vol   NUMBER := 0;
l_prev_for_vol   NUMBER := 0;
l_prev_ded       NUMBER := 0;
l_ret_val        NUMBER ;

BEGIN

   put_log('pn_variable_amount_pkg.get_vol_ded (+) : ');
   OPEN csr_vol(p_line_item_id,p_group_date);
   FETCH csr_vol into l_tot_act_vol,l_tot_for_vol,l_tot_ded,l_cumulative_vol;
   IF csr_vol%NOTFOUND THEN
      RETURN 0;
   END IF;
   CLOSE csr_vol;

   OPEN csr_prev_vol(p_line_item_id,p_group_date);
   FETCH csr_prev_vol into l_prev_act_vol,l_prev_for_vol,l_prev_ded;
   CLOSE csr_prev_vol;

   IF p_type = 'FOR' and l_cumulative_vol in('Y ','N') THEN

      l_ret_val := l_tot_for_vol - l_prev_for_vol;

   ELSIF p_type = 'ACT' and l_cumulative_vol = 'Y' THEN

      l_ret_val := NVL(l_tot_act_vol,0) - NVL(l_prev_act_vol,0);

   ELSIF p_type = 'DED' and l_cumulative_vol = 'Y' THEN

      l_ret_val := l_tot_ded - l_prev_ded;

   ELSIF p_type = 'FOR' and l_cumulative_vol = 'N' THEN

      l_ret_val := l_tot_for_vol;

   ELSIF p_type = 'ACT' and l_cumulative_vol = 'N' THEN

      l_ret_val := l_tot_act_vol;

   ELSIF p_type = 'DED' and l_cumulative_vol = 'N' THEN

      l_ret_val := l_tot_ded;

   END IF;

    RETURN NVL(l_ret_val,0);

put_log('pn_variable_amount_pkg.get_vol_ded (-) : ');

EXCEPTION
when others then
 put_log('Error in pn_variable_amount_pkg.get_vol_ded :'||to_char(sqlcode)||' : '||sqlerrm);

END get_vol_ded;

-------------------------------------------------------------------------------
-- PROCEDURE  : process_rent_batch
--
-- It's referenced in the Concurrent Program executable definition -
--
-- Main procedure to be called during calculation(p_calc_TYPE='CALCULATE') or
-- reconciliation(p_calc_TYPE='RECONCILE') from the SRS screen.
--
-- 15-Aug-02 DThota o Added p_period_date parameter to
--                    process_rent_batch, CURSOR csr_get_per for Mass
--                    Calculate Variable Rent.
-- 09-Jan-03 DThota  o Changed p_period_date parameter to VARCHAR2 from
--                     DATE in process_rent_batch, CURSOR csr_get_per.
--                     Added fnd_date.canonical_to_date before
--                     p_period_date in the WHERE clause.
--                     Fix for bug # 2733870
-- 23-Jan-03 DThota  o Removed comparison of pn_periods_all.end_date
--                     to p_period_date from the predicate of the
--                     cursor csr_get_per. Fix for bug # 2766223
-- 14-JUL-05 Hrodda  o Bug 4284035 - Replaced pn_leases with _ALL table.
-- 23-NOV-05 pikhar  o Passed org_id in pn_mo_cache_utils.get_profile_value
-------------------------------------------------------------------------------
PROCEDURE process_rent_batch (
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
                   p_invoice_on          IN  VARCHAR2 ,
                   p_var_rent_id         IN  NUMBER,
                   p_period_id           IN  NUMBER,
                   p_line_item_id        IN  NUMBER,
                   p_invoice_date        IN  DATE,
                   p_calc_TYPE           IN  VARCHAR2,
                   p_period_date         IN  VARCHAR2,
                   p_org_id              IN  NUMBER ) IS

CURSOR csr_get_vrent_wloc IS
SELECT pvr.var_rent_id,
       pvr.invoice_on,
       pvr.cumulative_vol,
       pvr.rent_num,
       pl.org_id
FROM   pn_leases            pl,
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
AND    pvr.invoice_on = NVL(p_invoice_on,pvr.invoice_on)
AND   (pl.org_id = p_org_id or p_org_id is null)
ORDER BY pl.lease_id, pvr.var_rent_id;

CURSOR csr_get_vrent_woloc IS
SELECT pvr.var_rent_id,
       pvr.invoice_on,
       pvr.cumulative_vol,
       pvr.rent_num,
       pl.org_id
FROM   pn_var_rents_all      pvr,
       pn_leases             pl,
       pn_lease_details_all  pld
WHERE  pl.lease_id = pvr.lease_id
AND    pld.lease_id = pvr.lease_id
AND    pl.lease_num >= NVL(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= NVL(p_lease_num_to, pl.lease_num)
AND    pvr.rent_num >= NVL(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= NVL(p_vrent_num_to,pvr.rent_num)
AND    pld.responsible_user = NVL(p_responsible_user, pld.responsible_user)
AND    pvr.var_rent_id = NVL(p_var_rent_id,pvr.var_rent_id)
AND    pvr.invoice_on = NVL(p_invoice_on,pvr.invoice_on)
AND   (pl.org_id = p_org_id or p_org_id is null)
ORDER BY pl.lease_id, pvr.var_rent_id;

CURSOR csr_get_per(ip_var_rent_id NUMBER) IS
SELECT period_id,
       period_num,
       start_date,
       end_date
FROM pn_var_periods_all
WHERE var_rent_id = ip_var_rent_id
AND period_id = NVL(p_period_id,period_id)
AND start_date <= NVL(fnd_date.canonical_to_date(p_period_date),TO_DATE('12/31/4712','mm/dd/yyyy'))
AND period_num >= NVL(p_period_num_from,period_num)
AND period_num <= NVL(p_period_num_to,period_num);

/* Get all the invoice dates for a period when doing reconciliation */
CURSOR csr_get_invdt(ip_period_id NUMBER) IS
SELECT distinct invoice_date
FROM pn_var_grp_dates_all
WHERE period_id = ip_period_id
AND invoice_date = NVL(p_invoice_date,invoice_date)
ORDER BY invoice_date;

l_org_id NUMBER;


/* Get the currency code AND set of books */

/* Remove for multi-org support */

---- begin ---

CURSOR csr_currency_code(p_org_ID IN NUMBER) is
SELECT currency_code,
       set_of_books_id
FROM  gl_sets_of_books
WHERE set_of_books_id = pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',p_org_ID);

---- end ---

l_var_rent_id  pn_var_rents.var_rent_id%TYPE;
l_invoice_on   pn_var_rents.invoice_on%TYPE;
l_cumulative   pn_var_rents.cumulative_vol%TYPE;
l_rent_num     pn_var_rents.rent_num%TYPE;
l_errbuf       VARCHAR2(2000);
l_retcode      VARCHAR2(2000);
l_ext_precision NUMBER;
l_min_acct_unit NUMBER;

/* Uncomment for multi-org support */

/* l_global_rec    pn_mo_cache_utils.GlobalsRecord; */


BEGIN
    pnp_debug_pkg.log('pn_variable_amount_pkg.process_rent_batch (+)' );
    g_period_date := NVL(fnd_date.canonical_to_date(p_period_date),TO_DATE('12/31/4712','mm/dd/yyyy'));

    fnd_message.set_name ('PN','PN_VRAM_PRM');
    fnd_message.set_token ('LSNO_FRM', p_lease_num_from);
    fnd_message.set_token ('LSNO_TO', p_lease_num_to);
    fnd_message.set_token ('LOC_FRM', p_location_code_from);
    fnd_message.set_token ('LOC_TO', p_location_code_to);
    fnd_message.set_token ('VR_FRM', p_vrent_num_from);
    fnd_message.set_token ('VR_TO', p_vrent_num_to);
    fnd_message.set_token ('PRD_FRM', p_period_num_from);
    fnd_message.set_token ('PRD_TO', p_period_num_to);
    fnd_message.set_token ('USR', p_responsible_user);
    fnd_message.set_token ('DATE', p_period_date);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    pnp_debug_pkg.log   ('process_rent_batch - Calculation TYPE : ' || p_calc_TYPE);


    /* Retrieve operating unit attributes AND store them in the cache */

    /* Uncomment for multi-org support */

    ---- begin ----
    /* pn_mo_global_cache.populate; */

    ---- end ----



    /* Remove for multi-org support */

    ---- begin ----

    l_org_id := pn_mo_cache_utils.get_current_org_id;

    OPEN csr_currency_code(l_org_id);
    FETCH csr_currency_code into g_currency_code,g_set_of_books_id;
    CLOSE csr_currency_code;

    fnd_currency.get_info(g_currency_code, g_precision,l_ext_precision, l_min_acct_unit);

    pnp_debug_pkg.log('process_rent_batch  - currency_code   :'||g_currency_code);
    pnp_debug_pkg.log('process_rent_batch  - set_of_books_id :'||g_set_of_books_id);
    pnp_debug_pkg.log('process_rent_batch  - precision       :'||g_precision);

    ---- end ----

    IF p_location_code_from IS NOT NULL or p_location_code_to IS NOT NULL THEN
        -----------------------------------------------------------------------------
        -- Checking Location Code From, Location Code To to open appropriate cursor.
        -----------------------------------------------------------------------------
        OPEN csr_get_vrent_wloc;
    ELSE
        OPEN csr_get_vrent_woloc;
    END IF;

    LOOP

         IF csr_get_vrent_wloc%ISOPEN THEN
           FETCH csr_get_vrent_wloc INTO l_var_rent_id,l_invoice_on,l_cumulative,l_rent_num,g_org_id;
           EXIT WHEN csr_get_vrent_wloc%NOTFOUND;
         ELSIF csr_get_vrent_woloc%ISOPEN THEN
           FETCH csr_get_vrent_woloc INTO l_var_rent_id,l_invoice_on,l_cumulative,l_rent_num,g_org_id;
           EXIT WHEN csr_get_vrent_woloc%NOTFOUND;
         END IF;

    fnd_message.set_name ('PN','PN_VRAM_VRN_PROC');
    fnd_message.set_token ('NUM',l_rent_num);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

         pnp_debug_pkg.log   ('process_rent_batch - Variable Rent id     :'||l_var_rent_id);
         pnp_debug_pkg.log   ('process_rent_batch - org_id               :'||g_org_id);


         /* get the currency code, set of books id AND initialize global variable */

         /* Uncomment for multi-org support */

         ---- begin ----

         /*IF mo_utils.get_multi_org_flag = 'Y'  THEN
            l_global_rec := pn_mo_global_cache.get_org_attributes(g_org_id);
         ELSE
            l_global_rec := pn_mo_global_cache.get_org_attributes(-3115);
         END IF;


         g_currency_code   := l_global_rec.functional_currency_code;
         g_set_of_books_id := l_global_rec.set_of_books_id;

         fnd_currency.get_info(g_currency_code, g_precision,l_ext_precision, l_min_acct_unit);

         put_log('process_rent_batch  - currency_code   :'||g_currency_code);
         put_log('process_rent_batch  - set_of_books_id :'||g_set_of_books_id); */

         ---- end ----


         FOR rec_get_per in csr_get_per(l_var_rent_id)
         LOOP

            fnd_message.set_name ('PN','PN_VRAM_PRD_PROC');
       fnd_message.set_token ('NUM',rec_get_per.period_num);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

            pnp_debug_pkg.log   ('process_rent_batch - period st date : '||rec_get_per.start_date);
            pnp_debug_pkg.log   ('process_rent_batch - period end date: '||rec_get_per.end_date);

            /* get the group date ids AND proration factor for the group dates for the period */

            get_percent_open(p_period_id  => rec_get_per.period_id,
                             p_cumulative => l_cumulative,
                             p_start_date => rec_get_per.start_date,
                             p_end_date   => rec_get_per.end_date);


            IF p_calc_TYPE in('CALCULATE','ADJUST') THEN

               process_variable_rent (
                                   p_var_rent_id  => l_var_rent_id,
                                   p_period_id    => rec_get_per.period_id,
                                   p_line_item_id => p_line_item_id,
                                   p_cumulative   => l_cumulative,
                                   p_invoice_on   => l_invoice_on,
                                   p_calc_TYPE    => p_calc_TYPE);


           ELSIF p_calc_TYPE = 'RECONCILE' THEN
              FOR rec_get_invdt in csr_get_invdt(rec_get_per.period_id)
              LOOP
              process_variable_rent (
                                   p_var_rent_id  => l_var_rent_id,
                                   p_period_id    => rec_get_per.period_id,
                                   p_line_item_id => null,
                                   p_cumulative   => l_cumulative,
                                   p_invoice_on   => l_invoice_on,
                                   p_calc_TYPE    => p_calc_TYPE,
                                   p_invoice_date => rec_get_invdt.invoice_date);
             END LOOP;
           END IF;

         END LOOP;

        /* Recalculate abatements for all non transferred invoices belonging to the variable rent*/

         apply_abatements(p_var_rent_id => l_var_rent_id);


    END LOOP;

    IF csr_get_vrent_wloc%ISOPEN THEN
       CLOSE csr_get_vrent_wloc;
    ELSIF csr_get_vrent_woloc%ISOPEN THEN
       CLOSE csr_get_vrent_woloc;
    END IF;

EXCEPTION

When OTHERS Then
   pnp_debug_pkg.log('Error in pn_variable_amount_pkg.process_rent_batch :'||TO_CHAR(sqlcode)||' : '||sqlerrm);
   Errbuf  := SQLERRM;
   Retcode := 2;
   rollback;
   raise;

pnp_debug_pkg.log('pn_variable_amount_pkg.process_rent_batch  (-) ');
END process_rent_batch;


----------------------------------------------------------------------------
--  PROCEDURE  : process_vol_hist
--
--  Program to process rent when volume history is deleted. Checks to see
--  if any volume history exists for an invoice date AND period. If none
--  exists then the corresponding row in pn_var_rent_inv should be deleted.
--  Also if no volume history exists for a group date AND line item then
--  the corresponding record in pn_var_rent_SUMm should be deleted.
--
----------------------------------------------------------------------------
PROCEDURE process_vol_hist (
                   p_grp_date_id         IN   NUMBER,
                   p_invoice_date        IN   DATE,
                   p_period_id           IN   NUMBER,
                   p_line_item_id        IN   NUMBER,
                   p_invoice_on          IN   VARCHAR2,
                   p_calc_TYPE           OUT NOCOPY  VARCHAR2) IS

/* Cursor to chk if volume history exists for a line_item_id AND grp_date_id */
CURSOR csr_any_vol_exists (ip_line_item_id NUMBER,
                           ip_grp_date_id NUMBER) IS
SELECT 'Y'
FROM dual
WHERE exists (SELECT null
              FROM pn_var_vol_hist_all
              WHERE line_item_id = ip_line_item_id
              AND grp_date_id = ip_grp_date_id);

/* Cursor to chk if volume history exists for a period AND invoice date */
CURSOR csr_vol_exists(ip_period_id NUMBER,
                      ip_invoice_date DATE,
                      ip_rent_TYPE VARCHAR2) IS
SELECT 'Y'
FROM dual
WHERE exists (SELECT null
              FROM pn_var_vol_hist_all vh,
                   pn_var_grp_dates_all gd
              WHERE vh.period_id = gd.period_id
              AND vh.grp_date_id = gd.grp_date_id
              AND gd.period_id = ip_period_id
              AND gd.invoice_date = ip_invoice_date
              AND vh.variance_exp_code = decode(ip_rent_TYPE,'VARIANCE','N',vh.variance_exp_code)
              AND vh.forecasted_exp_code = decode(ip_rent_TYPE,'FORECASTED','N',vh.forecasted_exp_code)
              AND vh.actual_exp_code = decode(ip_rent_TYPE,'ACTUAL','N',vh.actual_exp_code)
              AND ((ip_rent_TYPE = 'VARIANCE' AND vh.actual_amount is not null) OR
                    ip_rent_TYPE in('FORECASTED','ACTUAL'))
               );

/* Cursor to get the last non transferred invoice belonging to a period_id AND invoice_date */
CURSOR csr_get_inv(ip_period_id NUMBER,
                   ip_invoice_date DATE) IS
SELECT inv.adjust_num,
       inv.forecasted_exp_code,
       inv.variance_exp_code,
       inv.rowid,
       inv.var_rent_inv_id
FROM pn_var_rent_inv_all  inv
WHERE inv.period_id = ip_period_id
AND   inv.invoice_date = ip_invoice_date
AND   inv.adjust_num =(Select MAX(inv1.adjust_num)
                       from pn_var_rent_inv_all inv1
                       where inv1.period_id = ip_period_id
                       AND inv1.invoice_date = ip_invoice_date);

l_any_vol_exists VARCHAR2(1) := 'N';
l_vol_exists     VARCHAR2(1) := 'N';
l_varrent_exists VARCHAR2(1) := 'N';
l_rent_TYPE      VARCHAR2(30):= null;
l_adjust_num     NUMBER := 0;
l_rowid          ROWID;
l_delete         BOOLEAN := FALSE;
l_for_exp_code   pn_var_rent_inv.forecasted_exp_code%TYPE := null;
l_var_exp_code   pn_var_rent_inv.variance_exp_code%TYPE := null;
l_var_rent_inv_id pn_var_rent_inv.var_rent_inv_id%TYPE;

BEGIN
pnp_debug_pkg.log('pn_variable_amount_pkg.process_vol_hist  (+) ');

       /* Does a row exist in pn_var_rent_SUMm for grp_date_id AND line_item_id */
        l_varrent_exists := find_varrent_exists(
                              p_line_item_id   => p_line_item_id,
                              p_grp_date_id    => p_grp_date_id);

      /* Does a row exist in pn_var_vol_hist for grp_date_id AND line_item_id */
        OPEN csr_any_vol_exists (p_line_item_id,p_grp_date_id);
        FETCH csr_any_vol_exists into l_any_vol_exists;
        CLOSE csr_any_vol_exists;

        /* Delete from pn_var_rent_SUMm */
        IF l_any_vol_exists = 'N' THEN
            DELETE from pn_var_rent_SUMm_all
            WHERE grp_date_id = p_grp_date_id
            AND line_item_id = p_line_item_id;
        END IF;

        OPEN csr_get_inv(p_period_id,p_invoice_date);
        FETCH csr_get_inv into l_adjust_num,l_for_exp_code,l_var_exp_code,l_rowid,l_var_rent_inv_id;
        CLOSE csr_get_inv;

        IF l_adjust_num = 0 AND p_invoice_on = 'FORECASTED' AND l_for_exp_code = 'Y' AND
                                                                l_var_exp_code='N' THEN
              l_delete := FALSE;
              p_calc_TYPE := 'RECONCILE';
        ELSIF l_adjust_num = 0 AND p_invoice_on = 'FORECASTED' AND l_for_exp_code = 'N' THEN
              l_rent_TYPE := 'FORECASTED';
              l_delete    := TRUE;
              p_calc_TYPE := 'CALCULATE';
        ELSIF l_adjust_num > 0 AND p_invoice_on = 'FORECASTED' THEN
              l_rent_TYPE := 'VARIANCE';
              l_delete    := TRUE;
              p_calc_TYPE := 'ADJUST';
        ELSIF l_adjust_num = 0 AND p_invoice_on = 'ACTUAL' THEN
              l_rent_TYPE := 'ACTUAL';
              l_delete    := TRUE;
              p_calc_TYPE := 'CALCULATE';
        ELSIF l_adjust_num > 0 AND p_invoice_on = 'ACTUAL' THEN
              l_rent_TYPE := 'ACTUAL';
              l_delete    := TRUE;
              p_calc_TYPE := 'ADJUST';
        END IF;

        IF NVL(l_varrent_exists,'N') = 'N' THEN
             p_calc_TYPE := null;
        END IF;

        IF l_delete THEN
            /* Does any volume history exist for the invoice date,period AND rent TYPE */
             OPEN csr_vol_exists(p_period_id,p_invoice_date,l_rent_TYPE);
             FETCH csr_vol_exists into l_vol_exists;
             CLOSE csr_vol_exists;

             IF l_vol_exists = 'N' THEN

                 /* Delete from pn_payment_terms if a payment term exists */
                 DELETE from pn_payment_terms_all
                 WHERE var_rent_inv_id = l_var_rent_inv_id
                 AND var_rent_TYPE = l_rent_TYPE
                 AND status <> c_payment_term_status_approved;

                 /* Delete from pn_var_rent_inv */
                 DELETE from pn_var_rent_inv_all
                 WHERE rowid = l_rowid;
             END IF;
        END IF;

EXCEPTION

When OTHERS Then
pnp_debug_pkg.log('Error in pn_variable_amount_pkg.process_vol_hist : '||TO_CHAR(sqlcode)||' : '||sqlerrm);
rollback;
raise;

pnp_debug_pkg.log('pn_variable_amount_pkg.process_vol_hist  (-) ');

END process_vol_hist;

----------------------------------------------------------------------------
-- FUNCTION : get_msg
--
----------------------------------------------------------------------------

FUNCTION get_msg (p_calc IN VARCHAR2,
                  p_adj IN VARCHAR2,
                  p_rec IN VARCHAR2)
RETURN varchar2 IS

l_msg varchar2(200) := null;

BEGIN
pnp_debug_pkg.log('pn_variable_amount_pkg.get_msg (+) ');

    IF p_calc is not null THEN
       IF p_adj is not null AND p_rec is not null THEN
          l_msg := p_calc||', '||p_adj||' AND '||p_rec||' processes';
       ELSIF p_adj is not null AND p_rec is null THEN
          l_msg := p_calc||' AND '||p_adj||' processes';
       ELSIF p_adj is null AND p_rec is not null THEN
          l_msg := p_calc||' AND '||p_rec||' processes';
       ELSE
          l_msg := p_calc||' process';
       END IF;
   ELSE
       IF p_adj is not null AND p_rec is not null THEN
          l_msg := p_adj||' AND '||p_rec||' processes';
       ELSIF p_adj is not null AND p_rec is null THEN
          l_msg :=p_adj||' process';
       ELSIF p_adj is null AND p_rec is not null THEN
          l_msg :=p_rec||' process';
       ELSE
          l_msg := null;
       END IF;
  END IF;

  RETURN l_msg;

pnp_debug_pkg.log('pn_variable_amount_pkg.get_msg (-) ');
END get_msg;

----------------------------------------------------------------------------
-- FUNCTION : get_prorated_bkpt
--
-- Description :
--
-- Function used by form views PN_ACT_RENT_DETAILS_V AND PN_FOR_RENT_DETAILS_V
-- to return prorated breakpoints based up on whether invoicing in on cumulative
-- volumes or non cumulative volume.

-- 25-Feb-2002  Pooja Sidhu o Created.
----------------------------------------------------------------------------
FUNCTION get_prorated_bkpt(p_cumulative IN VARCHAR2,
                           p_grp_st_dt  IN DATE,
                           p_grp_end_dt IN DATE,
                           p_per_st_dt  IN DATE,
                           p_per_end_dt IN DATE,
                           p_per_bkpt   IN NUMBER,
                           p_grp_bkpt   IN NUMBER,
                           p_pror_factor IN NUMBER)
RETURN NUMBER IS
l_pror_bkpt  NUMBER := null;
l_no_of_days NUMBER := null;
BEGIN
    pnp_debug_pkg.log('pn_variable_amount_pkg.get_prorated_bkpt  (+) :');
    IF NVL(p_cumulative,'N') = 'Y' THEN
       l_no_of_days := (p_per_end_dt - p_per_st_dt) + 1;
       l_pror_bkpt  := (l_no_of_days/p_pror_factor) * p_per_bkpt;
    ELSE
       l_no_of_days := (p_grp_end_dt - p_grp_st_dt) + 1;
       l_pror_bkpt := (l_no_of_days/p_pror_factor) *  p_grp_bkpt;
    END IF;
    pnp_debug_pkg.log('pn_variable_amount_pkg.get_prorated_bkpt  (-) :');
    RETURN l_pror_bkpt;

END get_prorated_bkpt;

----------------------------------------------------------------------------
-- FUNCTION : derive_actual_invoiced_amt
--
----------------------------------------------------------------------------
FUNCTION derive_actual_invoiced_amt(p_constr_actual_rent number,
                                    p_negative_rent_flag varchar2,
                                    p_abatement_appl number,
                                    p_negative_rent number,
                                    p_rec_abatement number,
                                    p_rec_abatement_override number)
RETURN NUMBER IS
l_constr_actual_rent     pn_var_rent_inv.constr_actual_rent%TYPE := 0 ;
l_actual_invoiced_amount pn_var_rent_inv.actual_invoiced_amount%TYPE := 0;
l_rec_abatement          pn_var_rent_inv.rec_abatement%TYPE := 0;

BEGIN
   pnp_debug_pkg.log('pn_variable_amount_pkg.derive_actual_invoiced_amt  (+) :');

   l_constr_actual_rent := p_constr_actual_rent;

   IF (p_constr_actual_rent < 0 AND p_negative_rent_flag in('DEFER','IGNORE')) THEN
      l_constr_actual_rent := 0;
   END IF;

   pnp_debug_pkg.log('pn_variable_amount_pkg - l_constr_actual_rent :'||l_constr_actual_rent);
   pnp_debug_pkg.log('pn_variable_amount_pkg - p_abatement_appl     :'||p_abatement_appl);
   pnp_debug_pkg.log('pn_variable_amount_pkg - p_negative_rent     :'||p_negative_rent);

   l_actual_invoiced_amount :=  l_constr_actual_rent - (p_abatement_appl + p_negative_rent);

   pnp_debug_pkg.log('pn_variable_amount_pkg - l_actual_invoiced_amount '||l_actual_invoiced_amount);

   IF l_actual_invoiced_amount > 0 THEN
      l_rec_abatement := NVL(p_rec_abatement_override,p_rec_abatement); /* 8285964 */
                             --LEAST(l_actual_invoiced_amount,p_rec_abatement));
   ELSE
      l_rec_abatement := p_rec_abatement_override;
   END IF;

   pnp_debug_pkg.log('pn_variable_amount_pkg - l_rec_abatement '||l_rec_abatement);

   l_actual_invoiced_amount := l_actual_invoiced_amount - NVL(l_rec_abatement,0) ;

   RETURN l_actual_invoiced_amount;

   pnp_debug_pkg.log('pn_variable_amount_pkg.derive_actual_invoiced_amt  (-) :');

END derive_actual_invoiced_amt;

----------------------------------------------------------------------------
-- PROCEDURE : put_log
--
----------------------------------------------------------------------------
PROCEDURE put_log(p_string VARCHAR2)
IS
BEGIN
  pnp_debug_pkg.log(p_string);
END put_log;

----------------------------------------------------------------------------
-- PROCEDURE : put_output
--
----------------------------------------------------------------------------
PROCEDURE put_output(p_string VARCHAR2)
IS
BEGIN
   pnp_debug_pkg.put_log_msg(p_string);
END put_output;

----------------------------------------------------------------------------
-- PROCEDURE : get_approved_flag
--
----------------------------------------------------------------------------

PROCEDURE get_approved_flag(p_period_id IN NUMBER,
                            p_invoice_date IN DATE,
                            p_true_up_flag IN VARCHAR2,
                            p_actual_flag  OUT NOCOPY VARCHAR2,
                            p_forecasted_flag OUT NOCOPY VARCHAR2,
                            p_variance_flag OUT NOCOPY VARCHAR2)
IS
 CURSOR get_aprvd_cur(ip_period_id NUMBER,ip_invoice_date DATE) IS
   SELECT actual_exp_code,forecasted_exp_code,variance_exp_code
   FROM pn_var_rent_inv_all
   WHERE period_id = ip_period_id
   AND invoice_date = ip_invoice_date
   AND true_up_amt IS NULL
   AND adjust_num = (select max(adjust_num) FROM pn_var_rent_inv_all
                     WHERE period_id = ip_period_id
                     AND invoice_date = ip_invoice_date
                     AND true_up_amt IS NULL            -- Bug # 5991106
                     );
 CURSOR get_aprvd_cur_tu(ip_period_id NUMBER,ip_invoice_date DATE) IS
   SELECT actual_exp_code,forecasted_exp_code,variance_exp_code
   FROM pn_var_rent_inv_all
   WHERE period_id = ip_period_id
   AND invoice_date = ip_invoice_date
   AND true_up_amt IS NOT NULL
   AND adjust_num = (select max(adjust_num) FROM pn_var_rent_inv_all
                     WHERE period_id = ip_period_id
                     AND invoice_date = ip_invoice_date
                     AND true_up_amt IS NOT NULL        -- Bug # 5991106
                     );

BEGIN
pnp_debug_pkg.log('pn_variable_amount_pkg.get_approved_flag  (+) ');
   IF p_true_up_flag = 'N' THEN
           FOR rec IN get_aprvd_cur(p_period_id, p_invoice_date )LOOP
              p_actual_flag     := rec.actual_exp_code;
              p_forecasted_flag := rec.forecasted_exp_code;
              p_variance_flag   := rec.variance_exp_code;
           END LOOP;
   ELSE
           FOR rec IN get_aprvd_cur_tu(p_period_id, p_invoice_date )LOOP
              p_actual_flag     := rec.actual_exp_code;
              p_forecasted_flag := rec.forecasted_exp_code;
              p_variance_flag   := rec.variance_exp_code;
           END LOOP;
   END IF;



EXCEPTION
   WHEN others then pnp_debug_pkg.log ('Error in pn_variable_amount_pkg.get_approved_flag :'||
                                      TO_CHAR(sqlcode)||': '||sqlerrm);

pnp_debug_pkg.log('pn_variable_amount_pkg.get_approved_flag  (-) ');

END get_approved_flag;


END pn_variable_amount_pkg;


/
