--------------------------------------------------------
--  DDL for Package Body PN_VAR_RENT_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_RENT_CALC_PKG" AS
-- $Header: PNVRCALB.pls 120.0.12010000.4 2009/08/10 14:18:07 acprakas ship $
/* -------------------------------------------------------------------------
   ------------------------- COMMON DATA STRUCTURES ------------------------
   ------------------------------------------------------------------------- */
TYPE NUM_T IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE inv_date_rec IS RECORD(
      inv_date             pn_var_grp_dates_all.invoice_date%TYPE,
      period_id            pn_var_periods_all.period_id%TYPE,
      inv_flag             VARCHAR2(1));

TYPE inv_date_type IS
      TABLE OF inv_date_rec
      INDEX BY BINARY_INTEGER;

 /* -------------------------------------------------------------------------
   ------------------------- GLOBAL VARIABLES ------------------------------
   ------------------------------------------------------------------------- */
   g_calc_type       VARCHAR2(30);
   g_invoice_on      VARCHAR2(30);
   inv_date_tab      inv_date_type;
   g_precision       NUMBER;
   g_partial_prd_flag     VARCHAR2(1); ---- roll forward flag for 1st partial period

/* -------------------------------------------------------------------------
   ------------------------ PROCEDURES AND FUNCTIONS -----------------------
   ------------------------------------------------------------------------- */

--------------------------------------------------------------------------------
--  NAME         : cache_vr_details
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE cache_vr_details(p_var_rent_id IN NUMBER) IS

BEGIN

  /* get the VR details */
  FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP

    g_org_id               := vr_rec.org_id;
    g_vr_commencement_date := vr_rec.commencement_date;
    g_vr_termination_date  := vr_rec.termination_date;
    g_proration_rule       := vr_rec.proration_rule;
    g_calculation_method   := vr_rec.cumulative_vol;
    g_negative_rent        := vr_rec.negative_rent;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END cache_vr_details;

--------------------------------------------------------------------------------
--  NAME         : get_fy_proration_factor
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION get_fy_proration_factor(p_var_rent_id IN NUMBER)
RETURN NUMBER IS

  /* get VR start date */
  CURSOR vr_start_date_c(p_vr_id IN NUMBER) IS
    SELECT
    commencement_date
    FROM
    pn_var_rents_all
    WHERE
    var_rent_id = p_vr_id;

  /* get first period details */
  CURSOR first_period_c( p_vr_id IN NUMBER
                        ,p_st_dt IN DATE) IS
    SELECT
     period_id
    ,start_date
    ,end_date
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    start_date = p_st_dt AND
    partial_period = 'Y';

  l_fy_proration_factor NUMBER;

BEGIN

  l_fy_proration_factor := 0;

  FOR vr_rec IN vr_start_date_c(p_vr_id => p_var_rent_id) LOOP

    FOR prd_rec IN first_period_c( p_vr_id => p_var_rent_id
                                  ,p_st_dt => vr_rec.commencement_date) LOOP

      l_fy_proration_factor
      := ((prd_rec.end_date - prd_rec.start_date) + 1)
          / (ADD_MONTHS(vr_rec.commencement_date, 12)
             - vr_rec.commencement_date);

    END LOOP;

  END LOOP;

  RETURN l_fy_proration_factor;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_fy_proration_factor;

--------------------------------------------------------------------------------
--  NAME         : get_ly_proration_factor
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION get_ly_proration_factor(p_var_rent_id IN NUMBER)
RETURN NUMBER IS

  /* get VR end date */
  CURSOR vr_end_date_c(p_vr_id IN NUMBER) IS
    SELECT
    termination_date
    FROM
    pn_var_rents_all
    WHERE
    var_rent_id = p_vr_id;

  /* get last period details */
  CURSOR last_period_c( p_vr_id  IN NUMBER
                       ,p_end_dt IN DATE) IS
    SELECT
     period_id
    ,start_date
    ,end_date
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    end_date = p_end_dt AND
    partial_period = 'Y';

  l_ly_proration_factor NUMBER;

BEGIN

  l_ly_proration_factor := 0;

  FOR vr_rec IN vr_end_date_c(p_vr_id => p_var_rent_id) LOOP

    FOR prd_rec IN last_period_c( p_vr_id => p_var_rent_id
                                 ,p_end_dt => vr_rec.termination_date) LOOP

      l_ly_proration_factor
      := ((prd_rec.end_date - prd_rec.start_date) + 1)
          / (vr_rec.termination_date
            - ADD_MONTHS(vr_rec.termination_date, -12));

    END LOOP;

  END LOOP;

  RETURN l_ly_proration_factor;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_ly_proration_factor;

--------------------------------------------------------------------------------
--  NAME         : exists_approved_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION exists_approved_sales( p_line_item_id IN NUMBER
                               ,p_grp_date_id  IN NUMBER)
RETURN BOOLEAN IS

  l_exists_approved_sales BOOLEAN;

  /* exists approved sales? */
  CURSOR approved_sales_c( p_line_id IN NUMBER
                          ,p_grp_id  IN NUMBER) IS
    SELECT
    1
    FROM dual
    WHERE
    EXISTS
     (SELECT
      vol_hist_id
      FROM
      pn_var_vol_hist_all
      WHERE
      line_item_id = p_line_id AND
      grp_date_id  = p_grp_id AND
      vol_hist_status_code = pn_var_rent_calc_pkg.G_SALESVOL_STATUS_APPROVED);

BEGIN

  l_exists_approved_sales := FALSE;

  FOR rec IN approved_sales_c( p_line_id => p_line_item_id
                              ,p_grp_id  => p_grp_date_id) LOOP

    l_exists_approved_sales := TRUE;
    EXIT;

  END LOOP;

  RETURN l_exists_approved_sales;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END exists_approved_sales;

--------------------------------------------------------------------------------
--  NAME         : find_prev_billed - regular
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION find_prev_billed( p_var_rent_id      IN NUMBER
                          ,p_period_id        IN NUMBER
                          ,p_line_item_id     IN NUMBER
                          ,p_calc_prd_st_dt   IN DATE
                          ,p_calc_prd_end_dt  IN DATE
                          ,p_reset_grp_id     IN NUMBER)
RETURN NUMBER IS

  /* get previous billed */
  CURSOR prev_billed_c( p_vr_id      IN NUMBER
                       ,p_prd_id     IN NUMBER
                       ,p_line_id    IN NUMBER
                       ,p_rst_grp_id IN NUMBER
                       ,p_date       IN DATE) IS
    SELECT NVL(SUM(percent_rent_due), 0) AS prev_billed_amt
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    line_item_id = p_line_id AND
    reset_group_id = p_rst_grp_id AND
    calc_prd_start_date < p_date;

  l_prev_billed_rent NUMBER;

BEGIN

  l_prev_billed_rent := 0;

  FOR rec IN prev_billed_c( p_vr_id      => p_var_rent_id
                           ,p_prd_id     => p_period_id
                           ,p_line_id    => p_line_item_id
                           ,p_rst_grp_id => p_reset_grp_id
                           ,p_date       => p_calc_prd_st_dt) LOOP

    l_prev_billed_rent := rec.prev_billed_amt;

  END LOOP;

  RETURN l_prev_billed_rent;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END find_prev_billed;

--------------------------------------------------------------------------------
--  NAME         : find_prev_billed - invoice_flag = P
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION find_prev_billed( p_var_rent_id      IN NUMBER
                          ,p_line_item_grp_id IN NUMBER
                          ,p_calc_prd_st_dt   IN DATE
                          ,p_calc_prd_end_dt  IN DATE
                          ,p_reset_grp_id     IN NUMBER)
RETURN NUMBER IS

  /* get previous billed */
  CURSOR prev_billed_c( p_vr_id       IN NUMBER
                       ,p_part_prd_id IN NUMBER
                       ,p_full_prd_id IN NUMBER
                       ,p_line_grp_id IN NUMBER
                       ,p_rst_grp_id  IN NUMBER
                       ,p_date        IN DATE) IS
    SELECT NVL(SUM(percent_rent_due), 0) AS prev_billed_amt
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id IN (p_part_prd_id, p_full_prd_id) AND
    line_item_group_id = p_line_grp_id AND
    reset_group_id = p_rst_grp_id AND
    calc_prd_start_date < p_date;

  l_prev_billed_rent NUMBER;

  /* get the period details - we use the first 2 periods */
  CURSOR periods_c(p_vr_id IN NUMBER) IS
    SELECT
    period_id
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
    start_date;

  /* period info */
  l_part_prd_id NUMBER;
  l_full_prd_id NUMBER;
  l_counter1    NUMBER;

BEGIN

  l_counter1 := 0;

  FOR rec IN periods_c(p_vr_id => p_var_rent_id) LOOP

    l_counter1 := l_counter1 + 1;

    IF l_counter1 = 1 THEN
      l_part_prd_id := rec.period_id;

    ELSIF l_counter1 = 2 THEN
      l_full_prd_id := rec.period_id;

    END IF;

  END LOOP;

  l_prev_billed_rent := 0;

  FOR rec IN prev_billed_c( p_vr_id       => p_var_rent_id
                           ,p_part_prd_id => l_part_prd_id
                           ,p_full_prd_id => l_full_prd_id
                           ,p_line_grp_id => p_line_item_grp_id
                           ,p_rst_grp_id  => p_reset_grp_id
                           ,p_date        => p_calc_prd_st_dt) LOOP

    l_prev_billed_rent := rec.prev_billed_amt;

  END LOOP;

  RETURN l_prev_billed_rent;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END find_prev_billed;

--------------------------------------------------------------------------------
--  NAME         : get_rent_applicable
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE get_rent_applicable
(p_trx_hdr_rec IN OUT NOCOPY pn_var_rent_calc_pkg.trx_hdr_c%ROWTYPE)
IS

  /* cache trx hdr passed */
  l_trx_hdr_rec pn_var_rent_calc_pkg.trx_hdr_c%ROWTYPE;

  /* get bkpt type */
  CURSOR bkpt_type_c(p_bkdt_id IN NUMBER) IS
    SELECT
     bkhd.bkpt_header_id
    ,bkhd.breakpoint_type
    FROM
     pn_var_bkpts_head_all bkhd
    ,pn_var_bkpts_det_all  bkdt
     WHERE
    bkdt.bkpt_detail_id = p_bkdt_id AND
    bkdt.bkpt_header_id = bkhd.bkpt_header_id;

  l_bkpt_type VARCHAR2(30);

  l_bkpts_t TRX_DTL_TBL;

  l_net_volume NUMBER;
  l_bkpt_start NUMBER;
  l_bkpt_end   NUMBER;
  l_calc_rent  NUMBER;

  /* get FY sales */
  CURSOR fy_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(fy_proration_sales - NVL(fy_proration_deductions,0) ),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1) ;

  /* get FY breakpoints */
  CURSOR fy_bkpts_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
     NVL(SUM(fy_pr_grp_vol_start),0) AS bkpt_start
    ,NVL(SUM(fy_pr_grp_vol_end),0)   AS bkpt_end
    ,bkpt_rate
    FROM
    pn_var_trx_details_all
    WHERE
    trx_header_id IN
     (SELECT
      trx_header_id
      FROM
      pn_var_trx_headers_all
      WHERE
      var_rent_id = p_vr_id AND
      line_item_group_id = p_line_item_grp_id AND
      calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1))
    GROUP BY
    bkpt_rate
    ORDER BY
    bkpt_start;

  /* sum the proration factor in groups - FY */
  CURSOR grp_pro_factor_sum_fy_c( p_vr_id        IN NUMBER
                                 ,p_vr_comm_date IN DATE) IS
    SELECT
    NVL(SUM(proration_factor),0) proration_factor_sum
    FROM
    pn_var_grp_dates_all
    WHERE
    period_id IN (SELECT
                  period_id
                  FROM
                  pn_var_periods_all
                  WHERE
                  var_rent_id = p_vr_id AND
                  start_date = p_vr_comm_date);

  /* get LY sales */
  CURSOR ly_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_term_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(ly_proration_sales - NVL(ly_proration_deductions,0) ),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_end_date >= (ADD_MONTHS(p_vr_term_date, -12) + 1);

  /* get LY breakpoints */
  CURSOR ly_bkpts_c( p_vr_id            IN NUMBER
                    ,p_vr_term_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
     NVL(SUM(ly_pr_grp_vol_start),0) AS bkpt_start
    ,NVL(SUM(ly_pr_grp_vol_end),0)   AS bkpt_end
    ,bkpt_rate
    FROM
    pn_var_trx_details_all
    WHERE
    trx_header_id IN
     (SELECT
      trx_header_id
      FROM
      pn_var_trx_headers_all
      WHERE
      var_rent_id = p_vr_id AND
      line_item_group_id = p_line_item_grp_id AND
      calc_prd_end_date >= (ADD_MONTHS(p_vr_term_date, -12) + 1))
    GROUP BY
    bkpt_rate
    ORDER BY
    bkpt_start;

  /* sum the proration factor in groups - LY */
  CURSOR grp_pro_factor_sum_ly_c( p_vr_id        IN NUMBER
                                 ,p_vr_term_date IN DATE) IS
    SELECT
    NVL(SUM(proration_factor),0) proration_factor_sum
    FROM
    pn_var_grp_dates_all
    WHERE
    period_id IN (SELECT
                  period_id
                  FROM
                  pn_var_periods_all
                  WHERE
                  var_rent_id = p_vr_id AND
                  end_date = p_vr_term_date);

  /* get calc freq */
  CURSOR calc_freq_c(p_vr_id IN NUMBER) IS
    SELECT
    reptg_freq_code AS report_freq_code
    FROM
    pn_var_rent_dates_all
    WHERE
    var_rent_id = p_vr_id;

  /* get the number of periods */
  CURSOR period_num_c ( p_vr_id IN NUMBER) IS
    SELECT
    count(period_id) perion_num
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    NVL(status, 'A') <> pn_var_rent_calc_pkg.G_PERIOD_REVERSED_STATUS;

  /* get the last partial period */
  CURSOR last_period_c( p_vr_id     IN NUMBER) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd,
    pn_var_rents_all   var
    WHERE
    prd.var_rent_id = p_vr_id AND
    prd.var_rent_id = var.var_rent_id AND
    prd.end_date = var.termination_date;

  /* get the first partial period */
  CURSOR first_period_c( p_vr_id     IN NUMBER) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd,
    pn_var_rents_all   var
    WHERE
    prd.var_rent_id = p_vr_id AND
    prd.var_rent_id = var.var_rent_id AND
    prd.start_date = var.commencement_date;

  CURSOR freq_cur(p_vr_id     IN NUMBER) IS
    SELECT var_rent_id
    FROM  pn_var_rent_dates_all
    WHERE reptg_freq_code = 'YR'
    AND   invg_freq_code = 'YR'
    AND   var_rent_id = p_vr_id;

  l_prorat_factor_sum NUMBER;

  l_prev_billed NUMBER;

  l_context VARCHAR2(255);

  l_first_partial VARCHAR2(1);
  l_last_partial  VARCHAR2(1);
  l_period_num    NUMBER  := 0;

BEGIN

  pnp_debug_pkg.log('++++ get_rent_applicable - START ++++');

  IF NVL(p_trx_hdr_rec.invoice_flag, 'Y') = 'N' THEN
    RETURN;
  END IF;

  /* cache the trx header rec passed in */
  l_trx_hdr_rec := p_trx_hdr_rec;

  /* if VR details are not availabe at the package level, cache it */
  IF g_proration_rule IS NULL OR
     g_calculation_method IS NULL OR
     g_negative_rent IS NULL
  THEN

    /* cache VR details */
    pn_var_rent_calc_pkg.cache_vr_details
      (p_var_rent_id => l_trx_hdr_rec.var_rent_id);

  END IF;

  l_context := ' Cache volume and bkpts ';

  /* cache bkpt details */
  l_bkpts_t.DELETE;

  OPEN pn_var_rent_calc_pkg.trx_dtl_c(p_hdr_id => p_trx_hdr_rec.trx_header_id);
  FETCH pn_var_rent_calc_pkg.trx_dtl_c BULK COLLECT INTO l_bkpts_t;
  CLOSE pn_var_rent_calc_pkg.trx_dtl_c;

  /* get the breakpoint type - flat, sliding, stratified */
  FOR rec IN bkpt_type_c(p_bkdt_id => l_bkpts_t(1).bkpt_detail_id)
  LOOP
    l_bkpt_type := rec.breakpoint_type;
  END LOOP;

  IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                              ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
  THEN
    l_net_volume := (l_trx_hdr_rec.prorated_group_sales - NVL(l_trx_hdr_rec.prorated_group_deductions,0));

  ELSIF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_CUMULATIVE
                                 ,pn_var_rent_calc_pkg.G_CALC_YTD)
  THEN
    l_net_volume := (l_trx_hdr_rec.ytd_sales - NVL(l_trx_hdr_rec.ytd_deductions,0));

  END IF;

  pnp_debug_pkg.log(l_context||' COMPLETE  - net Volume: '||l_net_volume);


  /* --------------------- GET calculated_rent START --------------------- */
  /* handling the case of volume not tripping any bkpts */
  l_context := ' Get calculated rent ';

  /* init the calculated rent to 0 - it will be re-calculated */
  l_trx_hdr_rec.calculated_rent := 0;

  IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                              ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
     AND
     ((g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_NP
                            ,pn_var_rent_calc_pkg.G_PRORUL_STD
                            ,pn_var_rent_calc_pkg.G_PRORUL_FY
                            ,pn_var_rent_calc_pkg.G_PRORUL_LY
                            ,pn_var_rent_calc_pkg.G_PRORUL_FLY
                            ,pn_var_rent_calc_pkg.G_PRORUL_CYP) AND
       l_net_volume < l_bkpts_t(1).prorated_grp_vol_start)
      OR
      (g_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_CYNP AND
       l_net_volume < l_bkpts_t(1).pr_grp_blended_vol_start))
  THEN

     pnp_debug_pkg.log('No volumes tripped.');
     pnp_debug_pkg.log('l_net_volume:'||l_net_volume);
     pnp_debug_pkg.log
     ('l_bkpts_t(1).prorated_grp_vol_start:'||l_bkpts_t(1).prorated_grp_vol_start);
    /* Once no breakpoints are tripped, Macerich consider the rent to be = 0 */
    IF (g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_NP
                            ,pn_var_rent_calc_pkg.G_PRORUL_STD
                            ,pn_var_rent_calc_pkg.G_PRORUL_FY
                            ,pn_var_rent_calc_pkg.G_PRORUL_LY
                            ,pn_var_rent_calc_pkg.G_PRORUL_FLY
                            ,pn_var_rent_calc_pkg.G_PRORUL_CYP))  THEN

        l_trx_hdr_rec.calculated_rent
          := (l_net_volume - l_bkpts_t(1).prorated_grp_vol_start)
          * l_bkpts_t(1).bkpt_rate;

    ELSE
      l_trx_hdr_rec.calculated_rent
          := (l_net_volume - l_bkpts_t(1).pr_grp_blended_vol_start)
          * l_bkpts_t(1).bkpt_rate;

    END IF;
    pnp_debug_pkg.log('l_trx_hdr_rec.calculated_rent'||l_trx_hdr_rec.calculated_rent);


  ELSE

    /* get l_trx_hdr_rec.calculated_rent - CALCULATED RENT */
    IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_STRATIFIED
    THEN

      l_trx_hdr_rec.calculated_rent := 0;

      /* loop for all bkpt details */
      FOR i IN l_bkpts_t.FIRST..l_bkpts_t.LAST LOOP

        IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                                    ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
        THEN

          IF g_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_CYNP THEN

            l_bkpt_start := NVL(l_bkpts_t(i).pr_grp_blended_vol_start
                                ,l_bkpts_t(i).prorated_grp_vol_start);
            l_bkpt_end   := NVL(l_bkpts_t(i).pr_grp_blended_vol_end
                                ,l_bkpts_t(i).prorated_grp_vol_end);

          ELSE

            l_bkpt_start := l_bkpts_t(i).prorated_grp_vol_start;
            l_bkpt_end   := l_bkpts_t(i).prorated_grp_vol_end;

          END IF; /* g_proration_rule */

        ELSIF g_calculation_method = pn_var_rent_calc_pkg.G_CALC_CUMULATIVE
        THEN

          IF g_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_NP THEN

            l_bkpt_start := l_bkpts_t(i).prorated_grp_vol_start;
            l_bkpt_end   := l_bkpts_t(i).prorated_grp_vol_end;

          ELSE

            l_bkpt_start := l_bkpts_t(i).blended_period_vol_start;
            l_bkpt_end   := l_bkpts_t(i).blended_period_vol_end;

          END IF;

        ELSIF g_calculation_method = pn_var_rent_calc_pkg.G_CALC_YTD
        THEN

          l_bkpt_start := l_bkpts_t(i).ytd_group_vol_start;
          l_bkpt_end   := l_bkpts_t(i).ytd_group_vol_end;

        END IF; /* g_calculation_method */

        IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
          l_bkpt_end := NULL;
        END IF;

        IF l_net_volume >= l_bkpt_start THEN

          IF l_net_volume <= NVL(l_bkpt_end, l_net_volume) THEN

            l_trx_hdr_rec.calculated_rent
            := l_trx_hdr_rec.calculated_rent
               + (l_net_volume - l_bkpt_start) * l_bkpts_t(i).bkpt_rate;

          ELSIF l_net_volume > l_bkpt_end THEN

            l_trx_hdr_rec.calculated_rent
            := l_trx_hdr_rec.calculated_rent
               + (l_bkpt_end - l_bkpt_start) * l_bkpts_t(i).bkpt_rate;

          END IF;

        ELSE

          EXIT;

        END IF; /* net vol > bkpt start */

      END LOOP; /* loop for all bkpt details */

    ELSIF l_bkpt_type IN ( pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT
                          ,pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING)
    THEN

      FOR i IN l_bkpts_t.FIRST..l_bkpts_t.LAST LOOP

        IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                                    ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
        THEN

          IF g_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_CYNP THEN

            l_bkpt_start := NVL(l_bkpts_t(i).pr_grp_blended_vol_start
                                ,l_bkpts_t(i).prorated_grp_vol_start);
            l_bkpt_end   := NVL(l_bkpts_t(i).pr_grp_blended_vol_end
                                ,l_bkpts_t(i).prorated_grp_vol_end);

          ELSE

            l_bkpt_start := l_bkpts_t(i).prorated_grp_vol_start;
            l_bkpt_end   := l_bkpts_t(i).prorated_grp_vol_end;

          END IF; /* g_proration_rule */

        ELSIF g_calculation_method = pn_var_rent_calc_pkg.G_CALC_CUMULATIVE
        THEN

          IF g_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_NP THEN

            l_bkpt_start := l_bkpts_t(i).prorated_grp_vol_start;
            l_bkpt_end   := l_bkpts_t(i).prorated_grp_vol_end;

          ELSE

            l_bkpt_start := l_bkpts_t(i).blended_period_vol_start;
            l_bkpt_end   := l_bkpts_t(i).blended_period_vol_end;

          END IF;

        ELSIF g_calculation_method = pn_var_rent_calc_pkg.G_CALC_YTD
        THEN

          l_bkpt_start := l_bkpts_t(i).ytd_group_vol_start;
          l_bkpt_end   := l_bkpts_t(i).ytd_group_vol_end;

        END IF; /* g_calculation_method */

        IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
          l_bkpt_end := NULL;
        END IF;

        IF l_net_volume >= l_bkpt_start AND
           l_net_volume <= NVL(l_bkpt_end, l_net_volume)
        THEN

          IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING THEN

            l_trx_hdr_rec.calculated_rent
            := l_net_volume * l_bkpts_t(i).bkpt_rate;

          ELSIF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT THEN

            l_trx_hdr_rec.calculated_rent
            := (l_net_volume - l_bkpt_start) * l_bkpts_t(i).bkpt_rate;

          END IF;

          EXIT;

        END IF;

      END LOOP;

    END IF; /* breakpoint type */

  END IF; /* volume trips breakpoint?? */

  pnp_debug_pkg.log(l_context||' COMPLETE ');

  /* ---------------------- GET calculated_rent END ---------------------- */

  /* at this point, we have the calculated rent
     need to find
     - percent rent due
     - ytd percent rent
     - prorated rent due (if necessary) */

  /* -------------------- GET prorated_rent_due START --------------------- */
  /* if we need to find the prorated_rent_due */
  l_context := ' Get prorated rent ';

  /* init the prorated rent to 0 - it will be re-calculated */
  l_trx_hdr_rec.prorated_rent_due := 0;

  IF NVL(l_trx_hdr_rec.invoice_flag, 'Y') = 'I' THEN

    pnp_debug_pkg.log('+++ Get Prorated Rent - START +++');
    pnp_debug_pkg.log('Invoice Flag: '||l_trx_hdr_rec.invoice_flag);

    IF g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_FY
                            ,pn_var_rent_calc_pkg.G_PRORUL_FLY) AND
       ((ADD_MONTHS(g_vr_commencement_date, 12) - 1) BETWEEN
        l_trx_hdr_rec.calc_prd_start_date AND l_trx_hdr_rec.calc_prd_end_date)
    THEN

      pnp_debug_pkg.log('Get Prorated Rent - FY');

      /* calculate FY prorated rent due */
      FOR rec IN fy_sales_c
                  ( p_vr_id            => l_trx_hdr_rec.var_rent_id
                   ,p_vr_comm_date     => g_vr_commencement_date
                   ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id)
      LOOP
        l_net_volume := rec.sales;
      END LOOP;

      /* get l_trx_hdr_rec.calculated_rent - CALCULATED RENT */
      IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_STRATIFIED
      THEN

        l_trx_hdr_rec.prorated_rent_due := 0;

        /* loop for all bkpt details */
        FOR bkpt_rec IN fy_bkpts_c
                        ( p_vr_id            => l_trx_hdr_rec.var_rent_id
                         ,p_vr_comm_date     => g_vr_commencement_date
                         ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id)
        LOOP

          l_bkpt_start := bkpt_rec.bkpt_start;
          l_bkpt_end   := bkpt_rec.bkpt_end;

          IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
            l_bkpt_end := NULL;
          END IF;

          IF l_net_volume >= l_bkpt_start THEN

            IF l_net_volume <= NVL(l_bkpt_end, l_net_volume) THEN

              l_trx_hdr_rec.prorated_rent_due
              := l_trx_hdr_rec.prorated_rent_due
                 + (l_net_volume - l_bkpt_start) * bkpt_rec.bkpt_rate;

            ELSIF l_net_volume > l_bkpt_end THEN

              l_trx_hdr_rec.prorated_rent_due
              := l_trx_hdr_rec.prorated_rent_due
                 + (l_bkpt_end - l_bkpt_start) * bkpt_rec.bkpt_rate;

            END IF;

          ELSE

            EXIT;

          END IF; /* net vol > bkpt start */

        END LOOP; /* loop for all bkpt details */

      ELSIF l_bkpt_type IN ( pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT
                            ,pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING)
      THEN

        /* loop for all bkpt details */
        FOR bkpt_rec IN fy_bkpts_c
                        ( p_vr_id            => l_trx_hdr_rec.var_rent_id
                         ,p_vr_comm_date     => g_vr_commencement_date
                         ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id)
        LOOP

          l_bkpt_start := bkpt_rec.bkpt_start;
          l_bkpt_end   := bkpt_rec.bkpt_end;

          IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
            l_bkpt_end := NULL;
          END IF;

          IF l_net_volume >= l_bkpt_start AND
             l_net_volume <= NVL(l_bkpt_end, l_net_volume)
          THEN

            IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING THEN

              l_trx_hdr_rec.prorated_rent_due
              := l_net_volume * bkpt_rec.bkpt_rate;

            ELSIF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT THEN

              l_trx_hdr_rec.prorated_rent_due
              := (l_net_volume - l_bkpt_start) * bkpt_rec.bkpt_rate;

            END IF;

            EXIT;

          END IF;

        END LOOP;

      END IF; /* breakpoint type */

      /*Handle the case of volumes not tripping any breakpoints*/
      FOR bkpt_rec IN fy_bkpts_c
                        ( p_vr_id            => l_trx_hdr_rec.var_rent_id
                         ,p_vr_comm_date     => g_vr_commencement_date
                         ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id)
                         LOOP
         IF (l_net_volume < bkpt_rec.bkpt_start)  THEN
           -- The volumes did not trip any breakpoints
                l_trx_hdr_rec.prorated_rent_due
                 := l_trx_hdr_rec.prorated_rent_due
                    + (l_net_volume - l_bkpt_start) * bkpt_rec.bkpt_rate;
         END IF;

         EXIT; -- LOOP only once


      END LOOP;


      /* calculate prorated rent due based on sum of proration factors */

      /* Macerich way of calculating */

      l_trx_hdr_rec.prorated_rent_due
        := l_trx_hdr_rec.prorated_rent_due
           * pn_var_rent_calc_pkg.
             get_fy_proration_factor(l_trx_hdr_rec.var_rent_id);


      l_trx_hdr_rec.first_yr_rent := l_trx_hdr_rec.prorated_rent_due;

      /* Ideal way of calculating */
      /*
      FOR freq_rec IN calc_freq_c(p_vr_id => l_trx_hdr_rec.var_rent_id) LOOP

        FOR rec IN grp_pro_factor_sum_fy_c
                    ( p_vr_id        => l_trx_hdr_rec.var_rent_id
                     ,p_vr_comm_date => g_vr_commencement_date)
        LOOP
          l_prorat_factor_sum := rec.proration_factor_sum;
        END LOOP;

        IF freq_rec.report_freq_code = pn_var_rent_calc_pkg.G_FREQ_MON THEN
          l_trx_hdr_rec.prorated_rent_due
          := l_trx_hdr_rec.prorated_rent_due
             * l_prorat_factor_sum
             / pn_var_rent_calc_pkg.G_CALC_PRD_IN_FREQ_MON;

        ELSIF freq_rec.report_freq_code = pn_var_rent_calc_pkg.G_FREQ_QTR THEN
          l_trx_hdr_rec.prorated_rent_due
          := l_trx_hdr_rec.prorated_rent_due
             * l_prorat_factor_sum
             / pn_var_rent_calc_pkg.G_CALC_PRD_IN_FREQ_QTR;

        ELSIF freq_rec.report_freq_code = pn_var_rent_calc_pkg.G_FREQ_SA THEN
          l_trx_hdr_rec.prorated_rent_due
          := l_trx_hdr_rec.prorated_rent_due
             * l_prorat_factor_sum
             / pn_var_rent_calc_pkg.G_CALC_PRD_IN_FREQ_SA;

        ELSIF freq_rec.report_freq_code = pn_var_rent_calc_pkg.G_FREQ_YR THEN
          l_trx_hdr_rec.prorated_rent_due
          := l_trx_hdr_rec.prorated_rent_due
             * l_prorat_factor_sum /
             pn_var_rent_calc_pkg.G_CALC_PRD_IN_FREQ_YR;

        END IF;

      END LOOP;
      */

    END IF;

    IF g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_LY
                               ,pn_var_rent_calc_pkg.G_PRORUL_FLY) AND
       g_vr_termination_date = l_trx_hdr_rec.calc_prd_end_date
    THEN

      pnp_debug_pkg.log('Get Prorated Rent - LY');

      /* calculate LY prorated rent due */
      /* set the calculated rent to 0 */
      l_trx_hdr_rec.calculated_rent := 0;

      FOR rec IN ly_sales_c
                  ( p_vr_id            => l_trx_hdr_rec.var_rent_id
                   ,p_vr_term_date     => g_vr_termination_date
                   ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id)
      LOOP
        l_net_volume := rec.sales;
      END LOOP;

      pnp_debug_pkg.log('Sales volume for LY: '||l_net_volume);



      /* get l_trx_hdr_rec.prorated_rent_due - PRORATED RENT */
      IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_STRATIFIED
      THEN

        l_trx_hdr_rec.prorated_rent_due := 0;

        pnp_debug_pkg.log('Get bkpt trips for');
        pnp_debug_pkg.log('    VR ID: '||l_trx_hdr_rec.var_rent_id);
        pnp_debug_pkg.log('    VR End Date: '|| g_vr_termination_date);
        pnp_debug_pkg.log('    Line Grp: '||l_trx_hdr_rec.line_item_group_id);

        /* loop for all bkpt details */
        FOR bkpt_rec IN ly_bkpts_c
                        ( p_vr_id            => l_trx_hdr_rec.var_rent_id
                         ,p_vr_term_date     => g_vr_termination_date
                         ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id)
        LOOP

          l_bkpt_start := bkpt_rec.bkpt_start;
          l_bkpt_end   := bkpt_rec.bkpt_end;

          IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
            l_bkpt_end := NULL;
          END IF;

          pnp_debug_pkg.log('Bkpt trips - Start: '||l_bkpt_start||'  End: '||l_bkpt_end);

          IF l_net_volume >= l_bkpt_start THEN

            IF l_net_volume <= NVL(l_bkpt_end, l_net_volume) THEN

              l_trx_hdr_rec.prorated_rent_due
              := l_trx_hdr_rec.prorated_rent_due
                 + (l_net_volume - l_bkpt_start) * bkpt_rec.bkpt_rate;

            ELSIF l_net_volume > l_bkpt_end THEN

              l_trx_hdr_rec.prorated_rent_due
              := l_trx_hdr_rec.prorated_rent_due
                 + (l_bkpt_end - l_bkpt_start) * bkpt_rec.bkpt_rate;

            END IF;

            pnp_debug_pkg.log('Prorated Rent Due: '||l_trx_hdr_rec.prorated_rent_due);

          ELSE

            EXIT;

          END IF; /* net vol > bkpt start */

        END LOOP; /* loop for all bkpt details */


      ELSIF l_bkpt_type IN ( pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT
                            ,pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING)
      THEN
        pnp_debug_pkg.log('l_bkpt_type:'||l_bkpt_type);
        /* loop for all bkpt details */
        FOR bkpt_rec IN ly_bkpts_c
                        ( p_vr_id            => l_trx_hdr_rec.var_rent_id
                         ,p_vr_term_date     => g_vr_termination_date
                         ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id)
        LOOP

          l_bkpt_start := bkpt_rec.bkpt_start;
          l_bkpt_end   := bkpt_rec.bkpt_end;
          pnp_debug_pkg.log('1:'||bkpt_rec.bkpt_start);
          pnp_debug_pkg.log('2:'||bkpt_rec.bkpt_end);

          IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
            l_bkpt_end := NULL;
          END IF;

          IF l_net_volume >= l_bkpt_start AND
             l_net_volume <= NVL(l_bkpt_end, l_net_volume)
          THEN

            IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING THEN

              l_trx_hdr_rec.prorated_rent_due
              := l_net_volume * bkpt_rec.bkpt_rate;

            ELSIF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT THEN

              l_trx_hdr_rec.prorated_rent_due
              := (l_net_volume - l_bkpt_start) * bkpt_rec.bkpt_rate;

            END IF;

            EXIT;

          END IF;

        END LOOP;

      END IF; /* breakpoint type */

      /*Handle the case of volumes not tripping any breakpoints*/
      FOR bkpt_rec IN ly_bkpts_c
                        ( p_vr_id            => l_trx_hdr_rec.var_rent_id
                         ,p_vr_term_date     => g_vr_termination_date
                         ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id) --
                         LOOP
         IF (l_net_volume < bkpt_rec.bkpt_start)  THEN
           -- The volumes did not trip any breakpoints
                l_trx_hdr_rec.prorated_rent_due
                 := l_trx_hdr_rec.prorated_rent_due
                    + (l_net_volume - l_bkpt_start) * bkpt_rec.bkpt_rate;
         END IF;

         EXIT; -- LOOP only once


      END LOOP;


      /* calculate prorated rent due based on sum of proration factors */

      /* Macerich way of calculating */

      l_trx_hdr_rec.prorated_rent_due
        := l_trx_hdr_rec.prorated_rent_due
           * pn_var_rent_calc_pkg.
             get_ly_proration_factor(l_trx_hdr_rec.var_rent_id);

      /* Ideal way of calculating */
      /*
      FOR freq_rec IN calc_freq_c(p_vr_id => l_trx_hdr_rec.var_rent_id) LOOP

        FOR rec IN grp_pro_factor_sum_ly_c
                    ( p_vr_id        => l_trx_hdr_rec.var_rent_id
                     ,p_vr_term_date => g_vr_termination_date)
        LOOP
          l_prorat_factor_sum := rec.proration_factor_sum;
        END LOOP;

        IF freq_rec.report_freq_code = pn_var_rent_calc_pkg.G_FREQ_MON THEN
          l_trx_hdr_rec.prorated_rent_due
          := l_trx_hdr_rec.prorated_rent_due
             * l_prorat_factor_sum
             / pn_var_rent_calc_pkg.G_CALC_PRD_IN_FREQ_MON;

        ELSIF freq_rec.report_freq_code = pn_var_rent_calc_pkg.G_FREQ_QTR THEN
          l_trx_hdr_rec.prorated_rent_due
          := l_trx_hdr_rec.prorated_rent_due
             * l_prorat_factor_sum
             / pn_var_rent_calc_pkg.G_CALC_PRD_IN_FREQ_QTR;

        ELSIF freq_rec.report_freq_code = pn_var_rent_calc_pkg.G_FREQ_SA THEN
          l_trx_hdr_rec.prorated_rent_due
          := l_trx_hdr_rec.prorated_rent_due
             * l_prorat_factor_sum
             / pn_var_rent_calc_pkg.G_CALC_PRD_IN_FREQ_SA;

        ELSIF freq_rec.report_freq_code = pn_var_rent_calc_pkg.G_FREQ_YR THEN
          l_trx_hdr_rec.prorated_rent_due
          := l_trx_hdr_rec.prorated_rent_due
             * l_prorat_factor_sum
             / pn_var_rent_calc_pkg.G_CALC_PRD_IN_FREQ_YR;

        END IF;

      END LOOP;
      */
    END IF; /* calculate FY rent OR LY rent? */

    pnp_debug_pkg.log('+++ Get Prorated Rent - END +++');

  END IF; /* invoice flag = I - means calculate prorated_rent_due */

  pnp_debug_pkg.log(l_context||' COMPLETE ');

  /* --------------------- GET prorated_rent_due END ---------------------- */

  /* ------------ GET percent_rent_due, ytd_percent_rent START ------------ */

  l_context := ' Get percent_rent_due AND ytd_percent_rent ';

  IF NVL(l_trx_hdr_rec.invoice_flag, 'Y') = 'P' THEN

    l_prev_billed
      := pn_var_rent_calc_pkg.find_prev_billed
          ( p_var_rent_id      => l_trx_hdr_rec.var_rent_id
           ,p_line_item_grp_id => l_trx_hdr_rec.line_item_group_id
           ,p_calc_prd_st_dt   => l_trx_hdr_rec.calc_prd_start_date
           ,p_calc_prd_end_dt  => l_trx_hdr_rec.calc_prd_end_date
           ,p_reset_grp_id     => l_trx_hdr_rec.reset_group_id);

  ELSE

    l_prev_billed
      := pn_var_rent_calc_pkg.find_prev_billed
          ( p_var_rent_id      => l_trx_hdr_rec.var_rent_id
           ,p_period_id        => l_trx_hdr_rec.period_id
           ,p_line_item_id     => l_trx_hdr_rec.line_item_id
           ,p_calc_prd_st_dt   => l_trx_hdr_rec.calc_prd_start_date
           ,p_calc_prd_end_dt  => l_trx_hdr_rec.calc_prd_end_date
           ,p_reset_grp_id     => l_trx_hdr_rec.reset_group_id);

  END IF;

  pnp_debug_pkg.log(' get previously billed complete - l_prev_billed: '||l_prev_billed);

  IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                              ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
  THEN

    l_trx_hdr_rec.percent_rent_due := l_trx_hdr_rec.calculated_rent;
    l_trx_hdr_rec.ytd_percent_rent := l_prev_billed
                                      + l_trx_hdr_rec.percent_rent_due;

  ELSIF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_CUMULATIVE
                                 ,pn_var_rent_calc_pkg.G_CALC_YTD)
  THEN

    l_trx_hdr_rec.percent_rent_due
      := l_trx_hdr_rec.calculated_rent - l_prev_billed;

    /* need to
       - apply constraints on l_trx_hdr_rec.percent_rent_due
       - update l_trx_hdr_rec.percent_rent_due
       - then get the YTD
    */
    l_trx_hdr_rec.ytd_percent_rent
      := l_prev_billed + l_trx_hdr_rec.percent_rent_due;

  END IF; /* IF g_calculation_method IN */

  FOR period_num_rec IN period_num_c (p_vr_id => l_trx_hdr_rec.var_rent_id)
  LOOP

    l_period_num := period_num_rec.perion_num;

  END LOOP;

  FOR last_period_rec IN last_period_c (p_vr_id => l_trx_hdr_rec.var_rent_id)
  LOOP

    l_last_partial := last_period_rec.partial_period;

  END LOOP;

  FOR first_period_rec IN first_period_c (p_vr_id => l_trx_hdr_rec.var_rent_id)
  LOOP

    l_first_partial := first_period_rec.partial_period;

  END LOOP;

  /* IMP: This condition is to nullify the rents for a special case.
     The case is for First-LAst year, when we have just 2 periods and
     first year and last year period is partial, in such a case we dont
     want to calculate the rent. */
  IF g_proration_rule IN (pn_var_rent_calc_pkg.G_PRORUL_FLY) AND
     l_period_num = 2 AND l_first_partial = 'Y' AND
     l_last_partial = 'Y'
  THEN
    l_trx_hdr_rec.percent_rent_due := 0;
    l_trx_hdr_rec.ytd_percent_rent := 0;
    l_trx_hdr_rec.calculated_rent  := 0;

    FOR rec IN  freq_cur(p_vr_id => l_trx_hdr_rec.var_rent_id) LOOP
      l_trx_hdr_rec.prorated_rent_due := l_trx_hdr_rec.prorated_rent_due + l_trx_hdr_rec.first_yr_rent;
    END LOOP;

  END IF;


  pnp_debug_pkg.log(' ');
  pnp_debug_pkg.log(' calculation_method: '||g_calculation_method);
  pnp_debug_pkg.log(' percent_rent_due_for: '||l_trx_hdr_rec.percent_rent_due);
  pnp_debug_pkg.log(' ytd_percent_rent_for: '||l_trx_hdr_rec.ytd_percent_rent);
  pnp_debug_pkg.log(' ');

  pnp_debug_pkg.log(l_context||' COMPLETE ');

  /* ------------- GET percent_rent_due, ytd_percent_rent END ------------- */

  l_trx_hdr_rec.update_flag := 'Y';

  p_trx_hdr_rec := l_trx_hdr_rec;

  pnp_debug_pkg.log('++++ get_rent_applicable - END ++++');

EXCEPTION
  WHEN OTHERS THEN
    pnp_debug_pkg.log
    ('**********************************************************************');
    pnp_debug_pkg.log('*** ERROR IN get_rent_applicable ***');
    pnp_debug_pkg.log('*** ERROR WHEN: '||l_context||' ***');
    pnp_debug_pkg.log
    ('**********************************************************************');
    RAISE;

END get_rent_applicable;

--------------------------------------------------------------------------------
--  NAME         : post_summary - global procedure
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      : 5/Dec/2006 Shabda Populate deductions in var_rent_summ_all
--                 fix for bug 5679847
--               : Warning! This is not the procedure which is called from
--                calculate_rent. It is other overloaded post_summary.
--  dd-mon-yyyy  name     o Created
--  21-MAY-07    Lokesh   o Added rounding off for bug # 6031202 in
--                          pn_var_rent_summ_all
--------------------------------------------------------------------------------
PROCEDURE post_summary ( p_var_rent_id  IN NUMBER
                        ,p_period_id    IN NUMBER
                        ,p_line_item_id IN NUMBER
                        ,p_grp_date_id  IN NUMBER)
IS

  /* get grp date */
  CURSOR grp_date_c( p_vr_id  IN NUMBER
                    ,p_prd_id IN NUMBER
                    ,p_grp_id IN NUMBER) IS
    SELECT
     grp.grp_date_id
    ,grp.group_date
    ,grp.invoice_date
    ,grp.org_id
    FROM
    pn_var_grp_dates_all grp
    WHERE
    grp.var_rent_id = p_vr_id  AND
    grp.period_id   = p_prd_id AND
    grp.grp_date_id = p_grp_id;

  /* Get rent and volume to store in pn_var_rent_summ_all */
  CURSOR summ_c( p_vr_id   IN NUMBER
                ,p_prd_id  IN NUMBER
                ,p_line_id IN NUMBER
                ,p_grp_id  IN NUMBER) IS
    SELECT
     NVL(SUM(hdr.percent_rent_due),0)
     + NVL(SUM(DECODE(hdr.invoice_flag
                      ,'I',hdr.prorated_rent_due
                          ,0
                     )
              ), 0) AS rent
    ,NVL(SUM(hdr.prorated_group_sales)
         , 0) AS sales
    ,NVL(SUM(hdr.prorated_group_deductions)
         , 0) AS ded
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id  = p_vr_id AND
    hdr.period_id    = p_prd_id AND
    hdr.line_item_id = p_line_id AND
    hdr.grp_date_id  = p_grp_id;

  /* exists VR summ record */
  CURSOR vr_summ_c ( p_vr_id  IN NUMBER
                    ,p_prd_id IN NUMBER
                    ,p_line_id IN NUMBER
                    ,p_grp_id IN NUMBER) IS
    SELECT
    var_rent_summ_id
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    line_item_id = p_line_id AND
    grp_date_id = p_grp_id;

  l_vr_summ_id NUMBER;

BEGIN

  pnp_debug_pkg.log('post_summary .....(+)');
  /* get the invoice date for the group
     loops only once
  */
  FOR grp_rec IN grp_date_c( p_vr_id  => p_var_rent_id
                            ,p_prd_id => p_period_id
                            ,p_grp_id => p_grp_date_id)
  LOOP
      pnp_debug_pkg.log('grp_rec.invoice_date...'||grp_rec.invoice_date);
    /* get the sum of rents and sales for
       vr -> period -> line item -> group combination
       from the trx tables
       loops only once
    */
    FOR summ_rec IN summ_c( p_vr_id   => p_var_rent_id
                           ,p_prd_id  => p_period_id
                           ,p_line_id => p_line_item_id
                           ,p_grp_id  => p_grp_date_id)
    LOOP

      pnp_debug_pkg.log('summ_rec.rent...'||summ_rec.rent);
      pnp_debug_pkg.log('summ_rec.sales...'||summ_rec.sales);
      l_vr_summ_id := NULL;

      /* chk if VR SUMM record exists for this
         vr -> period -> line item -> group combination */
      FOR vr_summ_rec IN vr_summ_c( p_vr_id   => p_var_rent_id
                                   ,p_prd_id  => p_period_id
                                   ,p_line_id => p_line_item_id
                                   ,p_grp_id  => p_grp_date_id)
      LOOP
        l_vr_summ_id := vr_summ_rec.var_rent_summ_id;
      END LOOP;

      pnp_debug_pkg.log('l_vr_summ_id...'||l_vr_summ_id);

      IF l_vr_summ_id IS NULL THEN

        pnp_debug_pkg.log('inserting ...');
        /* to insert a new summary record */
        INSERT INTO
        pn_var_rent_summ_all
          (var_rent_summ_id
          ,var_rent_id
          ,period_id
          ,line_item_id
          ,invoice_date
          ,tot_act_vol
          ,tot_ded
          ,act_var_rent
          ,grp_date_id
          ,group_date
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,org_id)
        VALUES
          (pn_var_rent_summ_s.NEXTVAL
          ,p_var_rent_id
          ,p_period_id
          ,p_line_item_id
          ,grp_rec.invoice_date
          ,summ_rec.sales
          ,summ_rec.ded
          ,round(summ_rec.rent,g_precision)
          ,grp_rec.grp_date_id
          ,grp_rec.group_date
          ,SYSDATE
          ,NVL(fnd_global.user_id, 0)
          ,SYSDATE
          ,NVL(fnd_global.user_id, 0)
          ,NVL(fnd_global.login_id, 0)
          ,NVL(grp_rec.org_id, g_org_id))
        RETURNING
        var_rent_summ_id
        INTO
        l_vr_summ_id;

      ELSIF l_vr_summ_id IS NOT NULL THEN
        /* update the summary record */

        pnp_debug_pkg.log('updating ...');
        UPDATE
        pn_var_rent_summ_all
        SET
         tot_act_vol  = summ_rec.sales
        ,tot_ded = summ_rec.ded
        ,act_var_rent = round(summ_rec.rent,g_precision)
        ,last_update_date  = SYSDATE
        ,last_updated_by   = NVL(fnd_global.user_id, 0)
        ,last_update_login = NVL(fnd_global.login_id, 0)
        WHERE
        var_rent_summ_id = l_vr_summ_id;

      END IF;

      UPDATE
      pn_var_trx_headers_all hdr
      SET
      hdr.var_rent_summ_id = l_vr_summ_id
      WHERE
      hdr.var_rent_id  = p_var_rent_id AND
      hdr.period_id    = p_period_id AND
      hdr.line_item_id = p_line_item_id AND
      hdr.grp_date_id  = p_grp_date_id;

      EXIT;

    END LOOP;

    EXIT;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END post_summary;

--------------------------------------------------------------------------------
--  NAME         : post_summary_firstyr - global procedure
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--  21-MAY-07    Lokesh   o Added rounding off for bug # 6031202 in
--                          pn_var_rent_summ_all
--------------------------------------------------------------------------------
PROCEDURE post_summary_firstyr ( p_var_rent_id  IN NUMBER)
IS

  /* exists VR summ record */
  CURSOR vr_summ_fy_c IS
    SELECT *
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_var_rent_id AND
    NVL(first_yr_rent, 0) <> 0;

  /* exists VR summ record */
  CURSOR vr_summ_c ( p_period_id NUMBER,
                     p_line_item_id  NUMBER) IS
    SELECT  var_rent_summ_id
           ,tot_act_vol
           ,act_var_rent
           ,tot_ded
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_var_rent_id AND
    period_id   = p_period_id AND
    line_item_id = p_line_item_id;


  -- Get the details of
  CURSOR  line_item_cur ( p_period_id NUMBER,
                          p_line_item_id  NUMBER) IS
    SELECT trx.line_item_id
    FROM pn_var_trx_headers_all trx
    WHERE trx.period_id = p_period_id
    AND trx.line_item_group_id IN (SELECT line_item_group_id
                                   FROM pn_var_trx_headers_all
                                                       WHERE line_item_id = p_line_item_id);

    -- Get the details of
  CURSOR  first_period_cur IS
    SELECT period_id
    FROM pn_var_periods_all
    WHERE var_rent_id = p_var_rent_id
    AND   period_num = 1;

  l_period_id NUMBER;
  l_vr_summ_id NUMBER;
  l_line_item_id NUMBER;

BEGIN

   pnp_debug_pkg.log('+++++++++ post_summary_firstyr START +++++++++++');


   FOR first_period_rec IN first_period_cur LOOP
     l_period_id := first_period_rec.period_id;
   END LOOP;

   pnp_debug_pkg.log('first year period id... '||l_period_id);
   /* get the first year rent for this vr agreement */
   FOR vr_summ_fy_rec IN vr_summ_fy_c LOOP

      l_vr_summ_id := NULL;

      FOR line_item_rec IN line_item_cur(l_period_id, vr_summ_fy_rec.line_item_id) LOOP
         l_line_item_id := line_item_rec.line_item_id;
      END LOOP;

      /* Check if for first period a sumamry record already exists */
      FOR vr_summ_rec IN vr_summ_c(l_period_id, l_line_item_id) LOOP
         l_vr_summ_id  := vr_summ_rec.var_rent_summ_id;

         IF vr_summ_fy_rec.tot_act_vol <> NVL(vr_summ_rec.tot_act_vol, 0) OR
            vr_summ_fy_rec.tot_ded <> NVL(vr_summ_rec.tot_ded, 0) OR
            vr_summ_fy_rec.first_yr_rent  <> NVL(vr_summ_rec.act_var_rent, 0)
         THEN

           UPDATE
           pn_var_rent_summ_all
           SET
            tot_act_vol  = vr_summ_fy_rec.tot_act_vol
           ,tot_ded      = vr_summ_fy_rec.tot_ded
           ,act_var_rent = round(vr_summ_fy_rec.first_yr_rent,g_precision)
           ,last_update_date  = SYSDATE
           ,last_updated_by   = NVL(fnd_global.user_id, 0)
           ,last_update_login = NVL(fnd_global.login_id, 0)
           WHERE
           var_rent_summ_id = l_vr_summ_id;

         END IF;
      END LOOP;

      IF l_vr_summ_id IS NULL THEN


          /* to insert a new summary record */
         INSERT INTO
         pn_var_rent_summ_all
           (var_rent_summ_id
           ,var_rent_id
           ,period_id
           ,line_item_id
           ,invoice_date
           ,tot_act_vol
           ,tot_ded
           ,act_var_rent
           ,grp_date_id
           ,group_date
           ,last_update_date
           ,last_updated_by
           ,creation_date
           ,created_by
           ,last_update_login
           ,org_id
           ,first_yr_rent)
         VALUES
           (pn_var_rent_summ_s.NEXTVAL
           ,p_var_rent_id
           ,l_period_id
           ,l_line_item_id
           ,vr_summ_fy_rec.invoice_date
           ,vr_summ_fy_rec.tot_act_vol
           ,vr_summ_fy_rec.tot_ded
           ,round(vr_summ_fy_rec.first_yr_rent,g_precision)
           ,vr_summ_fy_rec.grp_date_id
           ,vr_summ_fy_rec.group_date
           ,SYSDATE
           ,NVL(fnd_global.user_id, 0)
           ,SYSDATE
           ,NVL(fnd_global.user_id, 0)
           ,NVL(fnd_global.login_id, 0)
           ,vr_summ_fy_rec.org_id
           ,NULL)
         RETURNING
         var_rent_summ_id
         INTO
         l_vr_summ_id;
      END IF;

      UPDATE
      pn_var_trx_headers_all hdr
      SET
      hdr.var_rent_summ_id = l_vr_summ_id
      WHERE
      hdr.var_rent_id  = p_var_rent_id AND
      hdr.period_id    = l_period_id AND
      hdr.line_item_id = l_line_item_id;

      EXIT;

   END LOOP;

   pnp_debug_pkg.log('+++++++++ post_summary_firstyr END +++++++++++');

END post_summary_firstyr;

--------------------------------------------------------------------------------
--  NAME         : insert_invoice_firstyr
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      : 16/OCT/06 Shabda Bug# 5533253, Modified to apply constraints
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE insert_invoice_firstyr( p_var_rent_id IN NUMBER) IS

  /* get invoice dates for a period */
  CURSOR invoice_dates_c( p_vr_id  IN NUMBER) IS
    SELECT
     invoice_date
    ,NVL(SUM(first_yr_rent), 0) AS total_actual_rent
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    first_yr_rent IS NOT NULL
    GROUP BY
    invoice_date
    ORDER BY
    invoice_date;

  /* get latest invoice */
  CURSOR invoice2upd_c( p_vr_id  IN NUMBER
                       ,p_prd_id IN NUMBER
                       ,p_inv_dt IN DATE) IS
    SELECT
     var_rent_inv_id
    ,var_rent_id
    ,period_id
    ,invoice_date
    ,actual_term_status
    ,actual_exp_code
    ,adjust_num
    ,tot_act_vol
    ,act_per_rent
    ,actual_invoiced_amount
    ,constr_actual_rent
    ,rec_abatement_override
    FROM
    pn_var_rent_inv_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    invoice_date = p_inv_dt AND
    NVL(true_up_amt, 0) = 0 AND
    true_up_status IS NULL AND
    true_up_exp_code IS NULL
    ORDER BY adjust_num DESC;

  /* get latest invoice */
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
    actual_exp_code = 'Y' AND
    NVL(true_up_amt, 0) = 0 AND
    true_up_status IS NULL AND
    true_up_exp_code IS NULL;

  l_invoice_on      VARCHAR2(30);
  l_row_id          ROWID;
  l_var_rent_inv_id NUMBER;
  l_max_adjust_num  NUMBER;
  l_prev_inv_rent   NUMBER;
  l_prev_inv_exp_rent NUMBER;
  l_constr_rent     NUMBER;
  l_constr_prev_rent  NUMBER;
  l_vr_commencement_date DATE;
  l_rec_abatement_override NUMBER;

  /* get ORG ID */
  CURSOR org_c(p_vr_id IN NUMBER) IS
    SELECT org_id, commencement_date
      FROM pn_var_rents_all
     WHERE var_rent_id = p_vr_id;


  /* get FY sales */
  CURSOR fy_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE) IS
    SELECT
    NVL(SUM(fy_proration_sales - NVL(fy_proration_deductions,0) ),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1) ;

  -- Get the details of
  CURSOR  first_period_cur(p_vr_id IN NUMBER) IS
    SELECT period_id
    FROM pn_var_periods_all
    WHERE var_rent_id = p_vr_id
    AND   period_num = 1;

  l_org_id NUMBER;
  l_period_id NUMBER;
  l_exists_invoice BOOLEAN := FALSE;
  l_tot_act_vol    NUMBER := 0;
  l_precision      NUMBER;
BEGIN

  pnp_debug_pkg.log('+++++++++ insert_invoice_firstyr START +++++++++++');

  FOR vr_rec IN org_c(p_vr_id => p_var_rent_id) LOOP
    l_org_id := vr_rec.org_id;
    l_vr_commencement_date := vr_rec.commencement_date;
  END LOOP;
  l_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(l_org_id),4);
  pnp_debug_pkg.log('l_precision:'||l_precision);
  FOR first_period_rec IN first_period_cur(p_vr_id => p_var_rent_id) LOOP
    l_period_id := first_period_rec.period_id;
  END LOOP;

  pnp_debug_pkg.log('first year period id... '||l_period_id);

  /* loop for all invoice dates in the period */
  FOR inv_rec IN invoice_dates_c( p_vr_id  => p_var_rent_id)
  LOOP

    l_row_id          := NULL;
    l_var_rent_inv_id := NULL;
    l_max_adjust_num  := 0;
    l_prev_inv_rent   := 0;
    l_exists_invoice  := FALSE;

    FOR rec IN fy_sales_c (p_var_rent_id, l_vr_commencement_date) LOOP
       l_tot_act_vol := rec.sales;
    END LOOP;

    /* check if there exists an invoice for this invoice date */
    FOR inv2upd_rec IN invoice2upd_c( p_vr_id  => p_var_rent_id
                                     ,p_prd_id => l_period_id
                                     ,p_inv_dt => inv_rec.invoice_date)
    LOOP

      /* invoice exists - we only look at the last invoice */
      l_exists_invoice := TRUE;
      l_constr_prev_rent := inv2upd_rec.constr_actual_rent;
      l_prev_inv_rent := inv2upd_rec.act_per_rent;
      l_rec_abatement_override := inv2upd_rec.rec_abatement_override;
      /* invoice updateable? */
      IF NVL(inv2upd_rec.actual_exp_code, 'N') <> 'Y' THEN

        /* updateable */
        l_var_rent_inv_id := inv2upd_rec.var_rent_inv_id;
        l_max_adjust_num  := inv2upd_rec.adjust_num;

      ELSIF NVL(inv2upd_rec.actual_exp_code, 'N') = 'Y' THEN

        /* NON - updateable */
        l_var_rent_inv_id := NULL;
        l_max_adjust_num  := inv2upd_rec.adjust_num + 1;

      END IF; /* invoice updateable? */

      /* we only look at the last invoice */
      EXIT;

    END LOOP; /* check if there exists an invoice for this invoice date */

      pnp_debug_pkg.log('l_exists_invoice...');
    /* atleast one invoice exists? */
    IF NOT l_exists_invoice
       AND round(inv_rec.total_actual_rent, l_precision) <> 0 THEN

      /* not sure abt this part
         uncomment the AND inv_rec.total_actual_rent <> 0
         part if we do not want to create $0 invoices
      */
     l_constr_rent := pn_var_rent_calc_pkg.apply_constraints_fy(
                                            p_period_id => l_period_id,
                                            p_invoice_date => inv_rec.invoice_date,
                                            p_actual_rent => inv_rec.total_actual_rent);

      pnp_debug_pkg.log('inserting the row ...');
      /* first time for this invoice date - create invoice */
      pn_var_rent_inv_pkg.insert_row
      ( x_rowid                   => l_row_id,
        x_var_rent_inv_id         => l_var_rent_inv_id,
        x_adjust_num              => l_max_adjust_num,
        x_invoice_date            => inv_rec.invoice_date,
        x_for_per_rent            => NULL,
        x_tot_act_vol             => l_tot_act_vol,
        x_act_per_rent            => inv_rec.total_actual_rent,
        x_constr_actual_rent      => l_constr_rent,
        x_abatement_appl          => 0,
        x_rec_abatement           => NULL,
        x_rec_abatement_override  => l_rec_abatement_override,
        x_negative_rent           => 0,
        x_actual_invoiced_amount  => l_constr_rent,
        x_period_id               => l_period_id,
        x_var_rent_id             => p_var_rent_id,
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
        x_org_id                  => l_org_id );

    ELSIF l_exists_invoice THEN

      /* invoice has been created here in the past */

      /* get the previously billed amount from approved invoices */
      FOR prev_inv_rec IN prev_invoiced_c( p_vr_id  => p_var_rent_id
                                          ,p_prd_id => l_period_id
                                          ,p_inv_dt => inv_rec.invoice_date)
      LOOP
        l_prev_inv_exp_rent := prev_inv_rec.prev_invoiced_amt;
      END LOOP;
      l_constr_rent := pn_var_rent_calc_pkg.apply_constraints_fy(
                                 p_period_id => l_period_id,
                                 p_invoice_date => inv_rec.invoice_date,
                                 p_actual_rent => inv_rec.total_actual_rent);
      /* no invoice to update - create a new one */
      IF l_var_rent_inv_id IS NULL THEN
        pnp_debug_pkg.log('l_constr_rent:'||l_constr_rent);
        pnp_debug_pkg.log('l_constr_rent:'||l_constr_prev_rent);
        /* if there a change in rent */
        IF round(inv_rec.total_actual_rent, l_precision) <> round(l_prev_inv_rent, l_precision)
        OR round(l_constr_rent, l_precision) <> round(l_constr_prev_rent, l_precision)
        THEN

          /* create new invoice for difference amt */
          pn_var_rent_inv_pkg.insert_row
          ( x_rowid                   => l_row_id,
            x_var_rent_inv_id         => l_var_rent_inv_id,
            x_adjust_num              => l_max_adjust_num,
            x_invoice_date            => inv_rec.invoice_date,
            x_for_per_rent            => NULL,
            x_tot_act_vol             => l_tot_act_vol,
            x_act_per_rent            => inv_rec.total_actual_rent,
            x_constr_actual_rent      => l_constr_rent,
            x_abatement_appl          => 0,
            x_rec_abatement           => NULL,
            x_rec_abatement_override  => l_rec_abatement_override,
            x_negative_rent           => 0,
            x_actual_invoiced_amount  => (l_constr_rent - l_prev_inv_exp_rent),
            x_period_id               => l_period_id,
            x_var_rent_id             => p_var_rent_id,
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
            x_org_id                  => l_org_id );

        END IF; /* IF inv_rec.total_actual_rent <> l_prev_inv_rent THEN */

      ELSIF l_var_rent_inv_id IS NOT NULL THEN
        /* if there a change in rent */
        IF round(inv_rec.total_actual_rent, l_precision) <> round(l_prev_inv_rent, l_precision)
        OR round(l_constr_rent, l_precision) <> round(l_constr_prev_rent, l_precision)
        THEN

          DELETE
          pn_payment_terms_all
          WHERE
          var_rent_inv_id = l_var_rent_inv_id AND
          status <> pn_var_rent_calc_pkg.G_TERM_STATUS_APPROVED AND
          var_rent_type = pn_var_rent_calc_pkg.G_INV_ON_ACTUAL;

          /* update the invoice */
          UPDATE
          pn_var_rent_inv_all
          SET
           act_per_rent           = ROUND(inv_rec.total_actual_rent, g_precision)
          ,constr_actual_rent     = ROUND(l_constr_rent, g_precision)
          ,actual_invoiced_amount = ROUND((l_constr_rent - l_prev_inv_exp_rent), g_precision)
          ,tot_act_vol            = ROUND(l_tot_act_vol,g_precision)   -- bug # 6007571
          ,credit_flag            = 'N'      -- bug # 5937807
          ,actual_term_status     = 'N'
          ,last_update_date       = SYSDATE
          ,last_updated_by        = NVL(fnd_global.user_id,0)
          ,last_update_login      = NVL(fnd_global.login_id,0)
          WHERE
          var_rent_inv_id = l_var_rent_inv_id;

       END IF; /* if there a change in rent */

      END IF; /* IF l_var_rent_inv_id IS NULL THEN */

    END IF; /* IF NOT l_exists_invoice THEN */

  END LOOP; /* loop for all invoice dates in the period */

  pnp_debug_pkg.log('+++++++++ insert_invoice END +++++++++++');

EXCEPTION
  WHEN OTHERS THEN RAISE;

END insert_invoice_firstyr;

--------------------------------------------------------------------------------
--  NAME         :
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      : 16/OCT/06 Shabda Bug# 5533253, Modified to apply constraints
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE insert_invoice( p_var_rent_id IN NUMBER
                         ,p_period_id   IN NUMBER) IS

  /* get invoice dates for a period */
  CURSOR invoice_dates_c( p_vr_id  IN NUMBER
                         ,p_prd_id IN NUMBER
                         ,p_new_termn_date DATE) IS
    SELECT
     invoice_date
    ,NVL(SUM(tot_act_vol), 0)  AS total_actual_sales
    ,NVL((SUM(act_var_rent) - NVL(SUM(first_yr_rent), 0)), 0) AS total_actual_rent
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    invoice_date <= p_new_termn_date
    GROUP BY
    invoice_date
    ORDER BY
    invoice_date;

  /* get latest invoice */
  CURSOR invoice2upd_c( p_vr_id  IN NUMBER
                       ,p_prd_id IN NUMBER
                       ,p_inv_dt IN DATE) IS
    SELECT
     var_rent_inv_id
    ,var_rent_id
    ,period_id
    ,invoice_date
    ,actual_term_status
    ,actual_exp_code
    ,adjust_num
    ,tot_act_vol
    ,act_per_rent
    ,actual_invoiced_amount
    ,constr_actual_rent
    ,rec_abatement_override
    FROM
    pn_var_rent_inv_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    invoice_date = p_inv_dt AND
    NVL(true_up_amt, 0) = 0 AND
    true_up_status IS NULL AND
    true_up_exp_code IS NULL
    ORDER BY adjust_num DESC;

  /* get latest invoice */
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
    actual_exp_code = 'Y' AND
    NVL(true_up_amt, 0) = 0 AND
    true_up_status IS NULL AND
    true_up_exp_code IS NULL;

    -- Does any volume exists for this invoice date?
  CURSOR vol_exists_c(ip_var_rent_id NUMBER,
                      ip_invoice_date DATE
            ) IS
      SELECT 1 as vol_exists
      FROM DUAL
      WHERE exists(
      SELECT vol_hist_id
      FROM pn_var_vol_hist_all
      WHERE grp_date_id in(
      SELECT grp_date_id
      FROM pn_var_grp_dates_all
      WHERE var_rent_id = ip_var_rent_id
      AND invoice_date = ip_invoice_date)
      AND vol_hist_status_code = pn_var_rent_calc_pkg.G_SALESVOL_STATUS_APPROVED);

  l_invoice_on      VARCHAR2(30);
  l_row_id          ROWID;
  l_var_rent_inv_id NUMBER;
  l_max_adjust_num  NUMBER;
  l_prev_inv_rent   NUMBER;
  l_prev_inv_exp_rent NUMBER;
  l_constr_rent     NUMBER;
  l_constr_prev_rent  NUMBER;
  l_rec_abatement_override NUMBER;

  /* get ORG ID */
  CURSOR org_c(p_vr_id IN NUMBER) IS
    SELECT org_id, termination_date
      FROM pn_var_rents_all
     WHERE var_rent_id = p_vr_id;

  /* get LY sales */
  CURSOR ly_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_term_date     IN DATE) IS
    SELECT
    NVL(SUM(ly_proration_sales - NVL(ly_proration_deductions,0) ),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    calc_prd_end_date >= (ADD_MONTHS(p_vr_term_date, -12) + 1);

  CURSOR  last_period_cur(p_vr_id IN NUMBER, p_termination_date DATE) IS
    SELECT period_id
    FROM pn_var_periods_all
    WHERE var_rent_id = p_vr_id
    AND   end_date = p_termination_date
    AND   partial_period='Y';    --  bug # 5937807

  l_org_id NUMBER;
  l_tot_act_vol    NUMBER := 0;
  l_vr_termination_date DATE;
  l_exists_invoice BOOLEAN;
  l_period_id NUMBER;
  l_precision NUMBER;
BEGIN

  pnp_debug_pkg.log('+++++++++ insert_invoice START (+) +++++++++++');

  FOR vr_rec IN org_c(p_vr_id => p_var_rent_id) LOOP
    l_org_id := vr_rec.org_id;
    l_vr_termination_date := vr_rec.termination_date;
  END LOOP;

  l_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(l_org_id),4);
  pnp_debug_pkg.log('l_precision:'||l_precision);

  /* loop for all invoice dates in the period */
  FOR inv_rec IN invoice_dates_c( p_vr_id  => p_var_rent_id
                                 ,p_prd_id => p_period_id
                                 ,p_new_termn_date => l_vr_termination_date)
  LOOP
      pnp_debug_pkg.log('inv_rec.invoice_date ...'||inv_rec.invoice_date);
      pnp_debug_pkg.log('inv_rec.total_actual_rent ...'||inv_rec.total_actual_rent);

    l_row_id          := NULL;
    l_var_rent_inv_id := NULL;
    l_max_adjust_num  := 0;
    l_prev_inv_rent   := 0;
    l_exists_invoice  := FALSE;
    l_tot_act_vol     := inv_rec.total_actual_sales;

    /* check if there exists an invoice for this invoice date */
    FOR inv2upd_rec IN invoice2upd_c( p_vr_id  => p_var_rent_id
                                     ,p_prd_id => p_period_id
                                     ,p_inv_dt => inv_rec.invoice_date)
    LOOP

      /* invoice exists - we only look at the last invoice */
      l_exists_invoice := TRUE;
      l_constr_prev_rent := inv2upd_rec.constr_actual_rent;
      l_prev_inv_rent := inv2upd_rec.act_per_rent;
      l_rec_abatement_override := inv2upd_rec.rec_abatement_override;
      /* invoice updateable? */
      IF NVL(inv2upd_rec.actual_exp_code, 'N') <> 'Y' THEN

        /* updateable */
        l_var_rent_inv_id := inv2upd_rec.var_rent_inv_id;
        l_max_adjust_num  := inv2upd_rec.adjust_num;

      ELSIF NVL(inv2upd_rec.actual_exp_code, 'N') = 'Y' THEN

        /* NON - updateable */
        l_var_rent_inv_id := NULL;
        l_max_adjust_num  := inv2upd_rec.adjust_num + 1;

      END IF; /* invoice updateable? */

      /* we only look at the last invoice */
      EXIT;

    END LOOP; /* check if there exists an invoice for this invoice date */


    /* Create the invoice for first partial year separately */
    IF g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_LY
                         ,pn_var_rent_calc_pkg.G_PRORUL_FLY)
        AND g_invoice_on = G_INV_ON_ACTUAL
    THEN

      FOR rec IN last_period_cur(p_var_rent_id,l_vr_termination_date ) LOOP
         l_period_id := rec.period_id;
      END LOOP;

      IF p_period_id = l_period_id THEN

         FOR ly_sales_rec IN ly_sales_c (p_var_rent_id,l_vr_termination_date)LOOP
            l_tot_act_vol := ly_sales_rec.sales;
         END LOOP;

      END IF;

    END IF;

    /* atleast one invoice exists? */
    IF NOT l_exists_invoice
       /*AND inv_rec.total_actual_rent <> 0*/ THEN

      /* not sure abt this part
         uncomment the AND inv_rec.total_actual_rent <> 0
         part if we do not want to create $0 invoices
      */
            /*We donot want to create invoices if no volumes exist for this
      invoice date. However once we have create invoices, and you delete volumes
      for that we need to update/adfjust them.
      */

      -- check if vol exists. This can't loop more than once.
      FOR vol_exists_rec IN vol_exists_c( p_var_rent_id,
                                          inv_rec.invoice_date
                                          ) --
                                          LOOP

      l_constr_rent := pn_var_rent_calc_pkg.apply_constraints(
                                            p_period_id => p_period_id,
                                            p_invoice_date => inv_rec.invoice_date,
                                            p_actual_rent => inv_rec.total_actual_rent);

      /* first time for this invoice date - create invoice */
      pn_var_rent_inv_pkg.insert_row
      ( x_rowid                   => l_row_id,
        x_var_rent_inv_id         => l_var_rent_inv_id,
        x_adjust_num              => l_max_adjust_num,
        x_invoice_date            => inv_rec.invoice_date,
        x_for_per_rent            => NULL,
        x_tot_act_vol             => l_tot_act_vol,
        x_act_per_rent            => inv_rec.total_actual_rent,
        x_constr_actual_rent      => l_constr_rent,
        x_abatement_appl          => 0,
        x_rec_abatement           => NULL,
        x_rec_abatement_override  => l_rec_abatement_override,
        x_negative_rent           => 0,
        x_actual_invoiced_amount  => l_constr_rent,
        x_period_id               => p_period_id,
        x_var_rent_id             => p_var_rent_id,
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
        x_org_id                  => l_org_id );
      END LOOP;




    ELSIF l_exists_invoice THEN

      /* invoice has been created here in the past */

      /* get the previously billed amount from approved invoices */
      FOR prev_inv_rec IN prev_invoiced_c( p_vr_id  => p_var_rent_id
                                          ,p_prd_id => p_period_id
                                          ,p_inv_dt => inv_rec.invoice_date)
      LOOP
        l_prev_inv_exp_rent := prev_inv_rec.prev_invoiced_amt;
      END LOOP;
      l_constr_rent := pn_var_rent_calc_pkg.apply_constraints(
                                 p_period_id => p_period_id,
                                 p_invoice_date => inv_rec.invoice_date,
                                 p_actual_rent => inv_rec.total_actual_rent);

      /* no invoice to update - create a new one */
      IF l_var_rent_inv_id IS NULL THEN
        pnp_debug_pkg.log('l_constr_rent:'||l_constr_rent);
        pnp_debug_pkg.log('l_constr_rent:'||l_constr_prev_rent);
        /* if there a change in rent */
        IF round(inv_rec.total_actual_rent, l_precision) <> round(l_prev_inv_rent, l_precision)
        OR round(l_constr_rent, l_precision) <> round(l_constr_prev_rent, l_precision)
        THEN

          /* create new invoice for difference amt */
          pn_var_rent_inv_pkg.insert_row
          ( x_rowid                   => l_row_id,
            x_var_rent_inv_id         => l_var_rent_inv_id,
            x_adjust_num              => l_max_adjust_num,
            x_invoice_date            => inv_rec.invoice_date,
            x_for_per_rent            => NULL,
            x_tot_act_vol             => l_tot_act_vol,
            x_act_per_rent            => inv_rec.total_actual_rent,
            x_constr_actual_rent      => l_constr_rent,
            x_abatement_appl          => 0,
            x_rec_abatement           => NULL,
            x_rec_abatement_override  => l_rec_abatement_override,
            x_negative_rent           => 0,
            x_actual_invoiced_amount  => (l_constr_rent - l_prev_inv_exp_rent),
            x_period_id               => p_period_id,
            x_var_rent_id             => p_var_rent_id,
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
            x_org_id                  => l_org_id );

        END IF; /* IF inv_rec.total_actual_rent <> l_prev_inv_rent THEN */


      ELSIF l_var_rent_inv_id IS NOT NULL THEN
        /* if there a change in rent */
        IF round(inv_rec.total_actual_rent, l_precision) <> round(l_prev_inv_rent, l_precision)
        OR round(l_constr_rent, l_precision) <> round(l_constr_prev_rent, l_precision)
        THEN

          DELETE
          pn_payment_terms_all
          WHERE
          var_rent_inv_id = l_var_rent_inv_id AND
          status <> pn_var_rent_calc_pkg.G_TERM_STATUS_APPROVED AND
          var_rent_type = pn_var_rent_calc_pkg.G_INV_ON_ACTUAL;

          /* update the invoice */
          UPDATE
          pn_var_rent_inv_all
          SET
           act_per_rent           = ROUND(inv_rec.total_actual_rent, g_precision)
          ,constr_actual_rent     = ROUND(l_constr_rent, g_precision)
          ,actual_invoiced_amount = ROUND((l_constr_rent - l_prev_inv_exp_rent), g_precision)
          ,tot_act_vol            = ROUND(l_tot_act_vol, g_precision)  -- bug # 6007571
          ,credit_flag            = 'N'  --  bug # 5937807
          ,actual_term_status     = 'N'
          ,last_update_date       = SYSDATE
          ,last_updated_by        = NVL(fnd_global.user_id,0)
          ,last_update_login      = NVL(fnd_global.login_id,0)
          WHERE
          var_rent_inv_id = l_var_rent_inv_id;

       END IF; /* if there a change in rent */

      END IF; /* IF l_var_rent_inv_id IS NULL THEN */

    END IF; /* IF NOT l_exists_invoice THEN */
    pnp_debug_pkg.log('l_prev_inv_exp_rent:'||l_prev_inv_exp_rent);

  END LOOP; /* loop for all invoice dates in the period */

  pnp_debug_pkg.log('+++++++++ insert_invoice END +++++++++++');

EXCEPTION
  WHEN OTHERS THEN RAISE;

END insert_invoice;


--------------------------------------------------------------------------------
--  NAME         : apply_constraints
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  9/10/06      Shabda     o Created
--------------------------------------------------------------------------------
FUNCTION apply_constraints(p_period_id IN NUMBER,
                           p_invoice_date IN DATE,
                           p_actual_rent IN NUMBER)
RETURN NUMBER
IS
Cursor csr_get_constr(p_period_id NUMBER) is
SELECT TYPE_code,
       amount,
       cons.constr_start_date const,
       grp.inv_start_date grpst
FROM pn_var_constraints_all cons,
     pn_var_grp_dates_all grp
WHERE cons.period_id = p_period_id
AND cons.period_id = grp.period_id
AND cons.constr_start_date <= grp.inv_start_date
AND cons.constr_end_date >= grp.inv_end_date
AND grp.invoice_date = p_invoice_date
AND NVL(constr_cat_code, 'VARENT')= 'VARENT';

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

--------------------------------------------------------------------------------
--  NAME         : apply_constraints_fy
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : Insert_invoice_firstYr
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  9/11/06      Shabda     o Created
--------------------------------------------------------------------------------
FUNCTION apply_constraints_fy(p_period_id IN NUMBER,
                           p_invoice_date IN DATE,
                           p_actual_rent IN NUMBER)
RETURN NUMBER
IS
Cursor csr_get_constr(p_period_id NUMBER) is
    SELECT TYPE_code,
           amount,
           cons.constr_start_date const
    FROM pn_var_periods_all per, pn_var_constraints_all cons
    WHERE per.var_rent_id = (select var_rent_id from pn_var_periods_all where period_id=p_period_id)
    AND per.period_id = cons.period_id
    AND cons.constr_start_date=(select
    MAX(const1.constr_start_date) from pn_var_constraints_all const1
    where const1.period_id = cons.period_id)
    AND   period_num = 1;

l_lower_bound NUMBER;
l_upper_bound NUMBER;
l_constr_act_rent NUMBER;

BEGIN
    pnp_debug_pkg.log( 'pn_variable_amount_pkg.apply_constraints_fy  : (+) ');
    pnp_debug_pkg.log('p_period_id'||p_period_id);
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
END apply_constraints_fy;


/***************Procedures to apply abatements***********/

--------------------------------------------------------------------------------
--  NAME         : apply_abatements
--  DESCRIPTION  : Applies abatements to given periods of a specific VR
--  PURPOSE      : Applies abatements.
--  INVOKED FROM : calculate_rent
--  ARGUMENTS    : p_var_rent_id: Vr to apply abatements for.
--                 p_period_id: Period to calculate for.
--                 p_flag: If calculate then actual_invoiced amount is
--                 updated.
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  25/Nov/06    Shabda Created
--------------------------------------------------------------------------------
PROCEDURE apply_abatements(p_var_rent_id IN NUMBER,
                 p_period_id IN NUMBER,
                 p_flag IN VARCHAR2)
IS
  -- Allowances first ot abatements?
  CURSOR order_c(ip_var_rent_id NUMBER) IS
  SELECT ORDER_OF_APPL_CODE, invoice_on, termination_date
  FROM PN_VAR_RENTS_ALL abat
  WHERE abat.var_rent_id = ip_var_rent_id;

  -- Get the details of
  CURSOR inv_c( ip_var_rent_id NUMBER,
                ip_period_id NUMBER,
                p_new_termn_date DATE
            ) IS
    SELECT var_rent_inv_id, invoice_date, variance_exp_code,
           actual_exp_code, constr_actual_rent
    FROM pn_var_rent_inv_all inv1
    WHERE inv1.var_rent_id = ip_var_rent_id
    AND inv1.period_id = ip_period_id
    AND inv1.invoice_date <= p_new_termn_date
    AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
      AND inv1.invoice_date = inv2.invoice_date)
    ORDER BY invoice_date;

  -- Get all the details of a specific invoice.
  CURSOR inv_all_c(ip_vr_inv_id NUMBER
            ) IS
    SELECT *
      FROM pn_var_rent_inv_all
     WHERE var_rent_inv_id = ip_vr_inv_id;


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
    OR variance_exp_code = 'Y')--Both can not be Y at the same time
    AND
    NVL(true_up_amt, 0) = 0 AND
    true_up_status IS NULL AND
    true_up_exp_code IS NULL;

    -- Get the details of
    CURSOR is_act_or_rec_exp_c(ip_var_rent_inv_id NUMBER) IS
      SELECT DECODE(invoice_on,
        G_INV_ON_ACTUAL, actual_exp_code,
        G_INV_ON_FORECASTED, variance_exp_code) AS
        exp_code,
        inv.actual_invoiced_amount
        FROM pn_var_rents_all vr,
             pn_var_rent_inv_all inv
       WHERE vr.var_rent_id = inv.var_rent_id
         AND inv.var_rent_inv_id = ip_var_rent_inv_id;

  l_is_inv_exp VARCHAR(30);
  l_abat_order VARCHAR(30);
  l_prev_inv_exp NUMBER;
  l_abated_rent NUMBER;
  l_row_id ROWID := NULL;
  l_var_rent_inv_id NUMBER := NULL;
  l_actual_invoiced_amount NUMBER;
  l_vr_termination_date DATE;

BEGIN
  /*To apply abatements we need to
  1. Apply deffered negative rents.
  2. Apply allowances/Abatements.
  3. Apply/Allowances/Abatements.
  */
  --
  pnp_debug_pkg.log('apply_abatements start(+)');
  pnp_debug_pkg.log('p_flag:'||p_flag);
  FOR rec IN order_c(p_var_rent_id) LOOP
    l_abat_order := rec.ORDER_OF_APPL_CODE;
    l_vr_termination_date := rec.termination_date;
  END LOOP;
  --
  FOR inv_rec IN inv_c(p_var_rent_id, p_period_id, l_vr_termination_date) LOOP
    pnp_debug_pkg.log('called apply_def_neg_rent');
    pn_var_rent_calc_pkg.apply_def_neg_rent(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_abated_rent);
    pnp_debug_pkg.log('complete');
   IF (l_abat_order = pn_var_rent_calc_pkg.G_ALLOWANCE_FIRST) THEN
    pnp_debug_pkg.log('call pnp_debug_pkg.log');
    pn_var_rent_calc_pkg.apply_allow(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_abated_rent);
    pnp_debug_pkg.log('complete');
   END IF;--Apply allowance.

   pnp_debug_pkg.log('call populate_abat');
   pn_var_rent_calc_pkg.populate_abat(p_var_rent_id , p_period_id, inv_rec.var_rent_inv_id);
   pnp_debug_pkg.log('complete');

   pnp_debug_pkg.log('call apply_abat');
   pn_var_rent_calc_pkg.apply_abat(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_abated_rent);
   pnp_debug_pkg.log('complete');

   IF(l_abat_order <> pn_var_rent_calc_pkg.G_ALLOWANCE_FIRST) THEN
     pnp_debug_pkg.log('call pnp_debug_pkg.log');
     pn_var_rent_calc_pkg.apply_allow(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_abated_rent);
     pnp_debug_pkg.log('complete');
   END IF;--Apply allowance
   pnp_debug_pkg.log('called populate_neg_rent');
   pn_var_rent_calc_pkg.populate_neg_rent(p_var_rent_id, p_period_id, inv_rec.var_rent_inv_id, l_abated_rent);
   pnp_debug_pkg.log('complete');


   --
   FOR rec IN prev_invoiced_c(p_var_rent_id, p_period_id, inv_rec.invoice_date) LOOP
     l_prev_inv_exp := rec.prev_invoiced_amt;
   END LOOP;

   /* update the invoice */
   IF (p_flag = 'CALCULATE') THEN

       FOR exp_rec IN is_act_or_rec_exp_c(inv_rec.var_rent_inv_id) LOOP
         l_is_inv_exp := exp_rec.exp_code;
         l_actual_invoiced_amount := exp_rec.actual_invoiced_amount;
       END LOOP;

     IF (l_is_inv_exp = 'N' ) AND
        ((l_abated_rent - l_prev_inv_exp)<> NVL(l_actual_invoiced_amount, 0)) THEN

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
       actual_invoiced_amount  = ROUND((l_abated_rent - l_prev_inv_exp), g_precision)
       ,actual_term_status     = 'N'
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
     END IF;

   END IF;



  END LOOP;--Loop for all required invoices.
  pnp_debug_pkg.log('apply_abatements end1(-)');
  pnp_debug_pkg.log('l_prev_inv_exp:'||l_prev_inv_exp);


EXCEPTION
   WHEN others THEN
   pnp_debug_pkg.log('Raised exception');
   RAISE;
END;


/*
This is the way deffered negative rents were applied in old calc engine.
Basically in old cal engine we decided what to do with neg rent before abatements were
applied. This would work if the excess abatement was always set to ignore,
as was the case previously.
Now we need to apply def neg rent at begining of abatement alication and make
other decisions at the end.
PROCEDURE apply_neg_rent(p_var_rent_id IN NUMBER,
               p_period_id IN NUMBER,
               p_inv_id IN NUMBER) IS
  -- Get the details of all invoices
  CURSOR invoices_c(ip_var_rent_id NUMBER, ip_period_id NUMBER, ip_inv_id NUMBER
            ) IS
    SELECT  constr_actual_rent
            ,actual_invoiced_amount
            ,negative_rent
            ,invoice_date
            ,var_rent_inv_id
     FROM pn_var_rent_inv_all inv1
     WHERE inv1.var_rent_id = ip_var_rent_id
     AND inv1.period_id = ip_period_id
     AND var_rent_inv_id = ip_inv_id
     AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
      AND inv1.invoice_date = inv2.invoice_date);

  CURSOR csr_last_inv(p_var_rent_id NUMBER)
     IS
     SELECT MAX(invoice_date) inv_date
     FROM pn_var_grp_dates_all
     WHERE var_rent_id = p_var_rent_id;

  CURSOR csr_neg_avail (ip_var_rent_id  NUMBER,
                        ip_invoice_date DATE) IS
     SELECT ABS(NVL(SUM(constr_actual_rent),0)) negative_available
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
     SELECT NVL(SUM(negative_rent),0) negative_applied
     FROM pn_var_rent_inv_all inv
     WHERE inv.var_rent_id = ip_var_rent_id
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
   -- Get the details of
   CURSOR temp_c(ip_var_rent_inv_id NUMBER
             ) IS
     SELECT abated_rent,
            negative_rent
       FROM pn_var_rent_inv_all
      WHERE var_rent_inv_id = ip_var_rent_inv_id;


   l_negative_rent        pn_var_rent_inv.negative_rent%TYPE := 0;
   l_negative_available   NUMBER := 0;
   l_negative_applied     NUMBER := 0;
   l_negative_remaining   NUMBER;
   l_abated_rent          NUMBER;
   l_negative_rent_flag   pn_var_rents.negative_rent%TYPE;
   l_last_invoice_dt      pn_var_grp_dates.invoice_date%TYPE;
BEGIN
  pnp_debug_pkg.log('apply_neg_rent start(+)');
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
     pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);
     l_negative_rent := 0;
     l_negative_available := 0;
     l_negative_applied := 0;
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
     IF (l_negative_rent_flag = pn_var_rent_calc_pkg.G_NEG_RENT_IGNORE) THEN
       l_abated_rent := GREATEST(0, inv_rec.constr_actual_rent);
     ELSIF(l_negative_rent_flag = pn_var_rent_calc_pkg.G_NEG_RENT_CREDIT)  THEN
       l_abated_rent := inv_rec.constr_actual_rent;
     ELSE
       -- negative rent is deffred
       IF (l_last_invoice_dt <> inv_rec.invoice_date) THEN
         --This invoice is not the last invoice
         l_abated_rent := GREATEST(0, inv_rec.constr_actual_rent - l_negative_remaining);
         IF (inv_rec.constr_actual_rent > l_abated_rent) THEN
           l_negative_rent := inv_rec.constr_actual_rent - l_abated_rent;

         ELSE
           l_negative_rent := 0;

         END IF;


       ELSE
         --This is the last invoice. All deffered negative rent needs to be added
         l_abated_rent := inv_rec.constr_actual_rent - l_negative_remaining;
         l_negative_rent := inv_rec.constr_actual_rent - l_abated_rent;
       END IF;
     END IF;
     pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
     pnp_debug_pkg.log('l_negative_rent:'||l_negative_rent);
     pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);

     UPDATE pn_var_rent_inv_all
     SET abated_rent = l_abated_rent,
         negative_rent = L_negative_rent
     WHERE var_rent_inv_id = inv_rec.var_rent_inv_id;
  END LOOP;
  pnp_debug_pkg.log('apply_neg_rent end(-)');

EXCEPTION
  --
  WHEN others THEN
  pnp_debug_pkg.log('Raised exception');
    RAISE;
END;
*/


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
            ,negative_rent
            ,invoice_date
            ,var_rent_inv_id
     FROM pn_var_rent_inv_all inv1
     WHERE inv1.var_rent_id = ip_var_rent_id
     AND inv1.period_id = ip_period_id
     AND var_rent_inv_id = ip_inv_id
     AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
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
  -- Loop for all invoices.
  FOR inv_rec IN invoices_c(p_var_rent_id, p_period_id, p_inv_id) LOOP
     pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);
     l_negative_rent := 0;
     l_negative_available := 0;
     l_negative_applied := 0;
     l_abated_rent :=inv_rec.constr_actual_rent;
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
     SET negative_rent = ROUND(l_negative_rent, g_precision)
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
      where inv1.var_rent_id = inv2.var_rent_id
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
    SET def_neg_rent = ROUND(l_neg_rent_def, g_precision)
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
--  HISTORY      : Shabda BUG 5726758. Modified to set the abatement
--                 to actual abatement applied, not just the rec abatement
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
            ,var_rent_inv_id
     FROM pn_var_rent_inv_all inv1
     WHERE inv1.var_rent_id = ip_var_rent_id
     AND inv1.period_id = ip_period_id
     AND inv1.var_rent_inv_id = ip_inv_id
     AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
      AND inv1.invoice_date = inv2.invoice_date);
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
                                WHERE var_rent_id = ip_var_rent_id);

  -- Get the details of negative_rent
  CURSOR neg_rent_c(ip_var_rent_id NUMBER
            ) IS
    SELECT negative_rent
    FROM pn_var_rents_all
    WHERE var_rent_id = ip_var_rent_id;
  -- Get the proration type
  CURSOR proration_type_c(ip_var_rent_id NUMBER
            ) IS
    SELECT proration_rule
    FROM pn_var_rents_all
    WHERE var_rent_id = ip_var_rent_id;

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

  l_fixed_abat NUMBER := 0;
  l_rec_abat   NUMBER := 0;
  l_total_abat NUMBER;
  l_excess_abat VARCHAR2(30);
  l_abated_rent NUMBER;
  l_unabated_rent NUMBER; --Need this to find out how much abatement
                         -- has been applied. Bug 5726758.
  l_inv_start_date DATE;
  l_inv_end_date   DATE;
  l_neg_rent   VARCHAR2(30);
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
  --The special cases this needs to handle are
  -- FY: The FY invoice would have invoice_date of next period.
  --
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

  --
  FOR neg_rec IN neg_rent_c(p_var_rent_id) LOOP
    l_neg_rent := neg_rec.negative_rent;
  END LOOP;

  --
  FOR fy_rec IN get_fy_inv_c(p_var_rent_id) LOOP
     l_first_inv_id := fy_rec.var_rent_inv_id;
  END LOOP;

  --
  FOR ly_rec IN get_ly_inv_c(p_var_rent_id) LOOP
     l_last_inv_id := ly_rec.var_rent_inv_id;
  END LOOP;

  FOR inv_rec IN invoices_c(p_var_rent_id , p_period_id, p_inv_id) LOOP
    -- update rec abatements.
    FOR inv_dates_rec IN invoice_dates_c(p_var_rent_id, inv_rec.invoice_date) LOOP
      l_inv_start_date := inv_dates_rec.inv_start_date;
      l_inv_end_date := inv_dates_rec.inv_end_date;
    END LOOP;
    --If this invoice is FY/FLY and the first year
    --Or proration is LY/FLY and the last invoice
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
    l_rec_abat := inv_rec.rec_abatement;
    l_abat_override := inv_rec.rec_abatement_override;
    pnp_debug_pkg.log('l_abat_override:'||l_abat_override);
    l_abated_rent := x_abated_rent;
    l_unabated_rent := x_abated_rent;
    pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
    pnp_debug_pkg.log('l_rec_abat:'||l_rec_abat);

    IF (l_abat_override IS NOT NULL) THEN
      l_total_abat := l_abat_override;
    ELSE
      FOR rec IN fixed_abat_c(p_var_rent_id, l_inv_start_date, l_inv_end_date) LOOP
        l_fixed_abat := rec.fixed_abat * l_num_inv;
        pnp_debug_pkg.log('l_fixed_abat:'||l_fixed_abat);
      END LOOP;
      l_total_abat := l_fixed_abat + l_rec_abat;
    END IF;

    pnp_debug_pkg.log('l_total_abat:'||l_total_abat);
    IF (l_excess_abat = pn_var_rent_calc_pkg.G_EXC_ABAT_IGNORE
        AND x_abated_rent>0 )  THEN
      l_abated_rent := GREATEST(0, x_abated_rent - l_total_abat);
    ELSIF (l_excess_abat = pn_var_rent_calc_pkg.G_EXC_ABAT_NEG_RENT ) THEN
      l_abated_rent := x_abated_rent - l_total_abat;
    END IF;

    pnp_debug_pkg.log('l_abated_rent:'||l_abated_rent);
    x_abated_rent := l_abated_rent;
    l_total_abat := l_unabated_rent - l_abated_rent;
    pnp_debug_pkg.log('total_abat_applied:'||l_total_abat);
    UPDATE pn_var_rent_inv_all
    SET rec_abatement = ROUND(l_total_abat, g_precision)
    WHERE var_rent_inv_id = inv_rec.var_rent_inv_id;

  END LOOP;
  pnp_debug_pkg.log('apply_abat end(-)');

EXCEPTION
  --
  WHEN others THEN
  pnp_debug_pkg.log('Exception in apply_abat');
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
                      x_abated_rent IN OUT NOCOPY NUMBER
          ) IS
  -- Get the details of

  CURSOR  invoices_c(ip_var_rent_id NUMBER,
                     ip_period_id   NUMBER,
                     ip_inv_id      NUMBER
            ) IS
    SELECT inv1.abatement_appl
           ,inv1.invoice_date
           ,inv1.var_rent_inv_id
    FROM pn_var_rent_inv_all inv1
    WHERE var_rent_id = ip_var_rent_id
    AND period_id = ip_period_id
    AND var_rent_inv_id = ip_inv_id
    AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
      AND inv1.invoice_date = inv2.invoice_date);
   -- Get the details of rolling allowance
  CURSOR rolling_allow_c(ip_var_rent_id NUMBER,
            ip_inv_start_date DATE,
            ip_inv_end_date DATE) IS
    SELECT NVL(amount, 0) rolling_allow
           ,allowance_applied allow_applied
           ,abatement_id
    FROM PN_VAR_ABAT_DEFAULTS_ALL
    WHERE var_rent_id = ip_var_rent_id
    AND start_date <= ip_inv_end_date
    AND NVL(end_date, ip_inv_end_date) >= ip_inv_start_date
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
      --Allowances can olny be applied if rent is >0
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
    SET abatement_appl = ROUND(l_allow_applied_inv, g_precision)
    WHERE var_rent_inv_id = inv_rec.var_rent_inv_id;
    x_abated_rent := l_cur_abt_rent;
    pnp_debug_pkg.log('inv_rec.var_rent_inv_id:'||inv_rec.var_rent_inv_id);
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
--------------------------------------------------------------------------------
PROCEDURE populate_abat(p_var_rent_id IN NUMBER,
           p_period_id IN NUMBER,
           p_inv_id IN NUMBER) IS

     -- Get the details of all invoices
  CURSOR invoices_c(ip_var_rent_id NUMBER, ip_period_id NUMBER,
                     ip_inv_id NUMBER
            ) IS
    SELECT   invoice_date
            ,var_rent_inv_id
     FROM pn_var_rent_inv_all inv1
     WHERE inv1.var_rent_id = ip_var_rent_id
     AND inv1.period_id = ip_period_id
     AND var_rent_inv_id = ip_inv_id
     AND inv1.adjust_num= (
      SELECT MAX(adjust_num) from pn_var_rent_inv_all inv2
      where inv1.var_rent_id = inv2.var_rent_id
      AND inv1.invoice_date = inv2.invoice_date);
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
                             WHERE var_rent_id = ip_var_rent_id);
  -- Get the proration type
  CURSOR proration_type_c(ip_var_rent_id NUMBER
            ) IS
    SELECT proration_rule
      FROM pn_var_rents_all
      WHERE var_rent_id = ip_var_rent_id;


      l_min_grp_date DATE;
      l_max_grp_date DATE;
      l_rec_abatement NUMBER;
      l_first_inv_id NUMBER;
      l_last_inv_id  NUMBER;
      l_proration_type VARCHAR2(30);
      l_ly_min_inv_id  NUMBER;

BEGIN
  -- Special cases which need to be handled are
  -- FY/FLY first invoice AND LY/FLY last invoice.
  --get first inv
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


  FOR inv_rec IN invoices_c(p_var_rent_id , p_period_id, p_inv_id) LOOP
    l_min_grp_date := pn_var_abatement_amount_pkg.get_group_dt(
                inv_rec.invoice_date,
                p_period_id,
                'MIN');
    l_max_grp_date := pn_var_abatement_amount_pkg.get_group_dt(
                inv_rec.invoice_date,
                p_period_id,
                'MAX');
    --Special FY/LY/FLY handling
    --If this invoice is FY/FLY and the first year
    --Or proration is LY/FLY and the last invoice
    IF ((l_proration_type IN (pn_var_rent_calc_pkg.G_PRORUL_FY, pn_var_rent_calc_pkg.G_PRORUL_FLY) AND p_inv_id = l_first_inv_id)
        OR (l_proration_type IN (pn_var_rent_calc_pkg.G_PRORUL_LY, pn_var_rent_calc_pkg.G_PRORUL_FLY) AND p_inv_id = l_last_inv_id) ) THEN
       --
       FOR inv_rec IN invoice_dates_fyly_c(p_inv_id) LOOP
         l_min_grp_date := inv_rec.start_date;
         l_max_grp_date := inv_rec.end_date;
       END LOOP;
    END IF;
    l_rec_abatement := pn_var_abatement_amount_pkg.calc_abatement(
                        inv_rec.var_rent_inv_id
                       ,l_min_grp_date
                       ,l_max_grp_date);
    g_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(g_org_id),4);
    UPDATE pn_var_rent_inv_all
    SET rec_abatement = ROUND(l_rec_abatement, g_precision)
    WHERE var_rent_inv_id = inv_rec.var_rent_inv_id;

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
--  NAME         : calculate_rent
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      : 20-SEP-06 Shabda o Populate data for actuals or forecasted
--                 depending on g_invoice_on and g_calc_type
--               : 8-Nov-2006 Shabda Modified to update rents each time, trx
--                 records are created. Not doing this cause wrong true_up
--
--  dd-mon-yyyy  name     o Created
--  23/05/07     Lokesh   o Added rounding off for bug # 6031202 in
--                          pn_var_trx_headers_all
--  21-AUG-2008  acprakas o Bug#6849764. Modified cursor periods_c to get details
--                          for only the period id passed as paramater.
--------------------------------------------------------------------------------
PROCEDURE calculate_rent( p_var_rent_id IN NUMBER
                         ,p_period_id   IN NUMBER)
IS

  /* get all periods for VR */
  CURSOR periods_vr_c( p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,start_date
    ,end_date
    ,partial_period
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    NVL(status, pn_var_rent_calc_pkg.G_PERIOD_ACTIVE_STATUS)
      <> pn_var_rent_calc_pkg.G_PERIOD_REVERSED_STATUS
    ORDER BY
    start_date;

  /* get all periods for VR */
  CURSOR periods_c( p_vr_id  IN NUMBER
                   ,p_prd_id IN NUMBER) IS
    SELECT
     period_id
    ,start_date
    ,end_date
    ,partial_period
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id =  p_prd_id
/*Bug#6849764
start_date >= (SELECT start_date
                   FROM pn_var_periods_all
                   WHERE period_id = p_prd_id)
Bug#6849764*/
    ORDER BY
    start_date;

    -- Get the periods ouside the current periods
    CURSOR periods_out_c(p_vr_id  IN NUMBER
                   ,p_prd_id IN NUMBER) IS
     SELECT
     period_id
    ,start_date
    ,end_date
    ,partial_period
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    NVL(status, pn_var_rent_calc_pkg.G_PERIOD_ACTIVE_STATUS)
      <> pn_var_rent_calc_pkg.G_PERIOD_REVERSED_STATUS AND
    start_date < (SELECT start_date
                   FROM pn_var_periods_all
                   WHERE period_id = p_prd_id)
    ORDER BY
    start_date;



  -- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER) IS
    SELECT pvp.period_id, pvp.partial_period
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.var_rent_id = pvr.var_rent_id
     AND   pvp.start_date = pvr.commencement_date;

  -- Get first partial period id
 CURSOR check_fst_partial_prd(p_var_rent_id IN NUMBER) IS
  SELECT period_id
    FROM pn_var_periods_all
   WHERE var_rent_id=p_var_rent_id
     AND period_num=1
     AND partial_period='Y';

  TYPE PERIOD_TBL IS TABLE OF periods_vr_c%ROWTYPE INDEX BY BINARY_INTEGER;
  l_periods_t PERIOD_TBL;
  l_periods_out_t PERIOD_TBL;

  l_prev_grp_date_id NUMBER;
  l_first_period_id  NUMBER := 0;

  l_trx_hrd_r pn_var_rent_calc_pkg.trx_hdr_c%ROWTYPE;
  l_trx_hrd_for_r pn_var_rent_calc_pkg.trx_hdr_for_c%ROWTYPE;
  l_trx_hrd_t pn_var_rent_calc_pkg.TRX_HDR_TBL;
  l_trx_hrd_for_t pn_var_rent_calc_pkg.TRX_HEADER_TBL;

  l_context VARCHAR2(255);
  l_first_inv_dt DATE ;
  l_partial_prd_id NUMBER:=NULL;
  l_partial_period VARCHAR2(1) := 'N';

BEGIN
  pnp_debug_pkg.log('+++++++++ calculate_rent START +++++++++++');
  pnp_debug_pkg.log('');
  /* -------------------------------------------------------------------------- */
  /* ------------------------------- CODE BEGIN ------------------------------- */
  /* -------------------------------------------------------------------------- */

  /* cache VR details */
  l_context := 'Call pn_var_rent_calc_pkg.cache_vr_details';

  pn_var_rent_calc_pkg.cache_vr_details(p_var_rent_id => p_var_rent_id);

  pnp_debug_pkg.log(l_context||' COMPLETE');

  /* check if trx tables need to be updated for change in bkts */
  l_context := 'Call pn_var_trx_pkg.populate_transactions';

  pn_var_trx_pkg.populate_transactions(p_var_rent_id => p_var_rent_id);

  pnp_debug_pkg.log(l_context||' COMPLETE');

  /*Do we need to populate actual sales or forecasted sales?*/

  IF(g_invoice_on=G_INV_ON_ACTUAL) THEN
     /* check if trx tables need to be updated for change in sales volume */
     l_context := 'Call pn_var_trx_pkg.populate_sales';
     pn_var_trx_pkg.populate_sales(p_var_rent_id => p_var_rent_id);
     pnp_debug_pkg.log(l_context||' COMPLETE');
  ELSIF (g_invoice_on = G_INV_ON_FORECASTED AND g_calc_type = G_CALC_TYPE_CALCULATE) THEN
     /* check if trx tables need to be updated for change in forecasted sales volume */
     l_context := 'Call pn_var_trx_pkg.populate_sales_for';
     pn_var_trx_pkg.populate_sales_for(p_var_rent_id => p_var_rent_id);
     pnp_debug_pkg.log(l_context||' COMPLETE');
  ELSIF (g_invoice_on = G_INV_ON_FORECASTED AND g_calc_type = G_CALC_TYPE_RECONCILE) THEN
     /* check if trx tables need to be updated for change in sales volume */
     l_context := 'Call pn_var_trx_pkg.populate_sales';
     pn_var_trx_pkg.populate_sales(p_var_rent_id => p_var_rent_id);
     pnp_debug_pkg.log(l_context||' COMPLETE');

  END IF;

  /* Populate deductions - Only need to do this when actuals are being calculated */
  IF(g_invoice_on=G_INV_ON_ACTUAL)
     OR (g_invoice_on = G_INV_ON_FORECASTED AND g_calc_type = G_CALC_TYPE_RECONCILE) THEN
     pnp_debug_pkg.log('');
     l_context := 'Call pn_var_trx_pkg.populate_deductions';

     pn_var_trx_pkg.populate_deductions(p_var_rent_id => p_var_rent_id);

      pnp_debug_pkg.log(l_context||' COMPLETE');

  END IF;

  pnp_debug_pkg.log('');

  /* populate the trx tables with calculated rents */
  l_context := 'Get periods to calculate rent for';

  l_periods_t.DELETE;


  /* cache the periods to calculate rent for */
  IF p_var_rent_id IS NOT NULL AND
     p_period_id IS NULL
  THEN

    OPEN periods_vr_c( p_vr_id => p_var_rent_id);
    FETCH periods_vr_c BULK COLLECT INTO l_periods_t;
    CLOSE periods_vr_c;


  ELSIF p_var_rent_id IS NOT NULL AND
        p_period_id   IS NOT NULL
  THEN

    OPEN periods_c( p_vr_id  => p_var_rent_id
                   ,p_prd_id => p_period_id);
    FETCH periods_c BULK COLLECT INTO l_periods_t;
    CLOSE periods_c;

  END IF;

  pnp_debug_pkg.log(l_context||' COMPLETE');
  pnp_debug_pkg.log('');

  l_context := 'Loop for all cached periods. Number of periods: '||l_periods_t.COUNT;
  pnp_debug_pkg.log(l_context);
  pnp_debug_pkg.log('');

  /* loop for all periods cached and calculate rent */
  IF l_periods_t.COUNT > 0 THEN

    FOR p IN l_periods_t.FIRST..l_periods_t.LAST LOOP

      l_context
      := '=== Looping for Period - Start Date: '||l_periods_t(p).start_date||
                              ' -- End Date: '||l_periods_t(p).end_date||
                              ' === ';

      pnp_debug_pkg.log(l_context);
      pnp_debug_pkg.log('');

      l_context := 'Fetch all trx data for period';

      /*Do we need to populate actual or forecasted rents?*/
      IF(g_invoice_on=G_INV_ON_ACTUAL)
      OR (g_invoice_on = G_INV_ON_FORECASTED AND g_calc_type = G_CALC_TYPE_RECONCILE)
      THEN

              l_trx_hrd_t.DELETE;

              /* loop for all trx in the period,
               order by line item, calc (sub) period start*/
              /*Populate actual rents in trx tables.*/
              OPEN pn_var_rent_calc_pkg.trx_hdr_c
                    ( p_vr_id  => p_var_rent_id
                     ,p_prd_id => l_periods_t(p).period_id);
              FETCH pn_var_rent_calc_pkg.trx_hdr_c BULK COLLECT INTO l_trx_hrd_t;
              CLOSE pn_var_rent_calc_pkg.trx_hdr_c;

              pnp_debug_pkg.log(l_context||' COMPLETE');
              pnp_debug_pkg.log('');

              IF l_trx_hrd_t.COUNT > 0 THEN

                l_context := 'Loop for all cached transactions. '||
                             'Number of trx: '||l_trx_hrd_t.COUNT;
                pnp_debug_pkg.log(l_context);

                FOR t IN l_trx_hrd_t.FIRST..l_trx_hrd_t.LAST LOOP

                  l_context
                  := '=== Looping for TRX - Start Date: '||
                       l_trx_hrd_t(t).calc_prd_start_date||
                                         ' -- End Date: '||
                         l_trx_hrd_t(t).calc_prd_end_date||
                                          ' === ';
                  pnp_debug_pkg.log(l_context);
                  pnp_debug_pkg.log('');

                  /* if we need to create an invoice for this calc (sub) period
                     AND if approved sales exist
                  */
                  IF NVL(l_trx_hrd_t(t).invoice_flag, 'Y') <> 'N' AND
                     pn_var_rent_calc_pkg.exists_approved_sales
                       ( p_line_item_id => l_trx_hrd_t(t).line_item_id
                        ,p_grp_date_id  => l_trx_hrd_t(t).grp_date_id)
                  THEN

                    l_trx_hrd_r := l_trx_hrd_t(t);

                    l_context := 'Call pn_var_rent_calc_pkg.get_rent_applicable';
                    pn_var_rent_calc_pkg.get_rent_applicable(l_trx_hrd_r);
                    pnp_debug_pkg.log(l_context||' COMPLETE');
                    pnp_debug_pkg.log('');

                    /* if rent changed */
                    IF NVL(l_trx_hrd_t(t).calculated_rent, 0)
                       <> NVL(l_trx_hrd_r.calculated_rent, 0) OR
                       NVL(l_trx_hrd_t(t).prorated_rent_due, 0)
                       <> NVL(l_trx_hrd_r.prorated_rent_due, 0) OR
                       NVL(l_trx_hrd_t(t).percent_rent_due, 0)
                       <> NVL(l_trx_hrd_r.percent_rent_due, 0) OR
                       NVL(l_trx_hrd_t(t).ytd_percent_rent, 0)
                       <> NVL(l_trx_hrd_r.ytd_percent_rent, 0)OR
                       NVL(l_trx_hrd_t(t).first_yr_rent, 0)
                       <> NVL(l_trx_hrd_r.first_yr_rent, 0)
                    THEN

                      UPDATE
                      pn_var_trx_headers_all
                      SET
                       calculated_rent   = round(l_trx_hrd_r.calculated_rent,g_precision)
                      ,prorated_rent_due = round(l_trx_hrd_r.prorated_rent_due,g_precision)
                      ,percent_rent_due  = round(l_trx_hrd_r.percent_rent_due,g_precision)
                      ,ytd_percent_rent  = round(l_trx_hrd_r.ytd_percent_rent,g_precision)
                      ,first_yr_rent     = round(l_trx_hrd_r.first_yr_rent,g_precision)
                      WHERE
                      trx_header_id = l_trx_hrd_r.trx_header_id;

                      l_trx_hrd_t(t) := l_trx_hrd_r;

                    END IF; /* if rent changed */

                  ELSE

                    l_context := 'No calculation necessary';
                    pnp_debug_pkg.log(l_context);
                    pnp_debug_pkg.log('');

                  END IF; /* need to create inv 4 this calc (sub) prd AND appr sales exist */

                END LOOP; /* loop for all trx in the period */

                l_context := 'Loop for all cached transactions.';
                pnp_debug_pkg.log(l_context||' COMPLETE');
                pnp_debug_pkg.log('');

              END IF;

      ELSIF (g_invoice_on = G_INV_ON_FORECASTED AND g_calc_type = G_CALC_TYPE_CALCULATE) THEN
             l_trx_hrd_for_t.DELETE;

              /* loop for all trx in the period,
               order by line item, calc (sub) period start*/
              /*Populate actual rents in trx tables.*/
              /*Populate forecasted rents in the trx tables.*/
             OPEN pn_var_rent_calc_pkg.trx_hdr_for_c
                    ( p_vr_id  => p_var_rent_id
                     ,p_prd_id => l_periods_t(p).period_id);
              FETCH pn_var_rent_calc_pkg.trx_hdr_for_c BULK COLLECT INTO l_trx_hrd_for_t;
              CLOSE pn_var_rent_calc_pkg.trx_hdr_for_c;

              pnp_debug_pkg.log(l_context||' COMPLETE');
              pnp_debug_pkg.log('');

              IF l_trx_hrd_for_t.COUNT > 0 THEN

                l_context := 'Loop for all cached transactions. '||
                             'Number of trx: '||l_trx_hrd_for_t.COUNT;
                pnp_debug_pkg.log(l_context);

                FOR t IN l_trx_hrd_for_t.FIRST..l_trx_hrd_for_t.LAST LOOP

                  l_context
                  := '=== Looping for TRX - Start Date: '||
                       l_trx_hrd_for_t(t).calc_prd_start_date||
                                         ' -- End Date: '||
                         l_trx_hrd_for_t(t).calc_prd_end_date||
                                          ' === ';
                  pnp_debug_pkg.log(l_context);
                  pnp_debug_pkg.log('');

                  /* if we need to create an invoice for this calc (sub) period
                  */
                  IF NVL(l_trx_hrd_for_t(t).invoice_flag, 'Y') <> 'N'
                  /*This will not be needed when invoicing on forecasted
                  AND
                     pn_var_rent_calc_pkg.exists_approved_sales
                       ( p_line_item_id => l_trx_hrd_for_t(t).line_item_id
                        ,p_grp_date_id  => l_trx_hrd_for_t(t).grp_date_id)*/
                  THEN

                    l_trx_hrd_for_r := l_trx_hrd_for_t(t);

                    l_context := 'Call pn_var_rent_calc_pkg.get_rent_applicable_for';
                    pn_var_rent_calc_pkg.get_rent_applicable_for(l_trx_hrd_for_r);
                    pnp_debug_pkg.log(l_context||' COMPLETE');
                    pnp_debug_pkg.log('');

                    /* if rent changed */
                    IF NVL(l_trx_hrd_for_t(t).calculated_rent_for, 0)
                       <> NVL(l_trx_hrd_for_r.calculated_rent_for, 0) OR
                       NVL(l_trx_hrd_for_t(t).percent_rent_due_for, 0)
                       <> NVL(l_trx_hrd_for_r.percent_rent_due_for, 0) OR
                       NVL(l_trx_hrd_for_t(t).ytd_percent_rent_for, 0)
                       <> NVL(l_trx_hrd_for_r.ytd_percent_rent_for, 0)
                    THEN
                    pnp_debug_pkg.log('updating the trx');
                    pnp_debug_pkg.log('l_trx_hrd_for_t(t).calculated_rent_for'||l_trx_hrd_for_t(t).calculated_rent_for);
                    pnp_debug_pkg.log('l_trx_hrd_for_r.calculated_rent_for'||l_trx_hrd_for_r.calculated_rent_for);
                    pnp_debug_pkg.log('l_trx_hrd_for_r.trx_header_id'||l_trx_hrd_for_r.trx_header_id);

                      UPDATE
                      pn_var_trx_headers_all
                      SET
                       calculated_rent_for   = round(l_trx_hrd_for_r.calculated_rent_for,g_precision)
                      ,percent_rent_due_for  = round(l_trx_hrd_for_r.percent_rent_due_for,g_precision)
                      ,ytd_percent_rent_for  = round(l_trx_hrd_for_r.ytd_percent_rent_for,g_precision)
                      WHERE
                      trx_header_id = l_trx_hrd_for_r.trx_header_id;

                      l_trx_hrd_t(t) := l_trx_hrd_r;

                    END IF; /* if rent changed */

                  ELSE

                    l_context := 'No calculation necessary';
                    pnp_debug_pkg.log(l_context);
                    pnp_debug_pkg.log('');

                  END IF; /* need to create inv 4 this calc (sub) prd AND appr sales exist */

                END LOOP; /* loop for all trx in the period */

                l_context := 'Loop for all cached transactions.';
                pnp_debug_pkg.log(l_context||' COMPLETE');
                pnp_debug_pkg.log('');

              END IF;

      END IF;/*end g_invoice and g_calc_type*/

    END LOOP; /* loop for all periods cached and calculate rent */
  END IF; /* if > 0 periods cached */

  l_periods_t.DELETE;
  /*Insert Invoice/post summary*/
  /* cache the periods*/
  IF p_var_rent_id IS NOT NULL AND
     p_period_id IS NULL
  THEN

    OPEN periods_vr_c( p_vr_id => p_var_rent_id);
    FETCH periods_vr_c BULK COLLECT INTO l_periods_t;
    CLOSE periods_vr_c;


  ELSIF p_var_rent_id IS NOT NULL AND
        p_period_id   IS NOT NULL
  THEN

    OPEN periods_c( p_vr_id  => p_var_rent_id
                   ,p_prd_id => p_period_id);
    FETCH periods_c BULK COLLECT INTO l_periods_t;
    CLOSE periods_c;

    OPEN periods_out_c( p_vr_id  => p_var_rent_id
                   ,p_prd_id => p_period_id);
    FETCH periods_out_c BULK COLLECT INTO l_periods_out_t;
    CLOSE periods_out_c;

  END IF;

   pnp_debug_pkg.log('set partial flag');
  -- Set l_partial_prd_id if 1st partial period exists and proration rule is FY/FLY
  IF g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_FY
                          ,pn_var_rent_calc_pkg.G_PRORUL_FLY) THEN
     FOR fst_rec IN check_fst_partial_prd(p_var_rent_id) LOOP
         l_partial_prd_id:= fst_rec.period_id;
     END LOOP;
  END IF;

  g_partial_prd_flag := NULL;
  pnp_debug_pkg.log('prior to pop inv date tab');
  -- call to populate inv_date_tab for roll fwd
  -- IF 1st partial period exists then call pop_inv_date_tab_firstyr ,to populate
  -- invoice dates from 2nd annual period
  -- ELSE call pop_inv_date_tab
  IF l_partial_prd_id IS NOT NULL THEN
       pn_var_rent_calc_pkg.pop_inv_date_tab_firstyr(p_var_rent_id => p_var_rent_id ,
                                                     p_status => 'APPROVED');
  ELSE
       pn_var_rent_calc_pkg.pop_inv_date_tab(p_var_rent_id => p_var_rent_id ,
                                             p_status => 'APPROVED');
  END IF;

  /*pnp_debug_pkg.log('data in inv_date_tab');
  FOR i IN 1..inv_date_tab.COUNT LOOP
    pnp_debug_pkg.log(inv_date_tab(i).inv_date||' '||
                      inv_date_tab(i).period_id||' '||
                      inv_date_tab(i).inv_flag||'!!');
  END LOOP;*/


  FOR first_period_rec IN first_period_cur (p_var_rent_id)  LOOP
     l_first_period_id := first_period_rec.period_id;
     l_partial_period  := first_period_rec.partial_period;
  END LOOP;

  /* loop for all periods cached and calculate rent */
  IF l_periods_t.COUNT > 0 THEN
    FOR p IN l_periods_t.FIRST..l_periods_t.LAST --
    LOOP
       IF(g_invoice_on=G_INV_ON_ACTUAL) OR (g_invoice_on=G_INV_ON_FORECASTED
                                         AND g_calc_type= G_CALC_TYPE_RECONCILE)
       THEN
          l_context := 'Call pn_var_rent_calc_pkg.post_summary';

         /* IF NOT ( g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_FY
                  ,pn_var_rent_calc_pkg.G_PRORUL_FLY)
             AND (l_first_period_id = l_periods_t(p).period_id)
             AND l_partial_period = 'Y')
          THEN*/
             pn_var_rent_calc_pkg.post_summary
                   ( p_var_rent_id   => p_var_rent_id
                   ,p_period_id     => l_periods_t(p).period_id);
             pnp_debug_pkg.log(l_context||' COMPLETE');
             pnp_debug_pkg.log('');
          /*END IF; */

       ELSIF (g_invoice_on=G_INV_ON_FORECASTED AND g_calc_type= G_CALC_TYPE_CALCULATE)
       THEN
          l_context := 'Call pn_var_rent_calc_pkg.post_summary_for';
          pn_var_rent_calc_pkg.post_summary_for
                  ( p_var_rent_id   => p_var_rent_id
                   ,p_period_id     => l_periods_t(p).period_id);
          pnp_debug_pkg.log(l_context||' COMPLETE');
          pnp_debug_pkg.log('');

       END IF;/*End invoice type and calc_type*/

       l_context := 'Call pn_var_rent_calc_pkg.insert_invoice';
       IF g_invoice_on = G_INV_ON_ACTUAL THEN

          IF NOT ( g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_FY
                  ,pn_var_rent_calc_pkg.G_PRORUL_FLY)
             AND (l_first_period_id = l_periods_t(p).period_id)
             AND l_partial_period = 'Y')
          THEN
             pn_var_rent_calc_pkg.insert_invoice
                    ( p_var_rent_id   => p_var_rent_id
                     ,p_period_id     => l_periods_t(p).period_id);
          END IF;

       ELSIF g_invoice_on = G_INV_ON_FORECASTED  THEN
          pn_var_rent_calc_pkg.insert_invoice_for
                 ( p_var_rent_id   => p_var_rent_id
                  ,p_period_id     => l_periods_t(p).period_id);

       END IF;

       pnp_debug_pkg.log(l_context||' COMPLETE');
       pnp_debug_pkg.log('');

    END LOOP;/*End loop for all periods*/

    /* Create the invoice for first partial year separately */
    IF g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_FY
                        ,pn_var_rent_calc_pkg.G_PRORUL_FLY)
       AND g_invoice_on = G_INV_ON_ACTUAL AND l_partial_period = 'Y'
    THEN

        /*post_summary_firstyr (p_var_rent_id => p_var_rent_id);*/

        /*pn_var_rent_calc_pkg.*/insert_invoice_firstyr( p_var_rent_id   => p_var_rent_id );
    END IF;

  END IF;/*End insert invoice/post summary*/

  --call to roll fwd selections
 -- IF partial_prd flag is NOT NULL i.e. there exists a 1st partial period then
  -- call ROLL_FWD_PARTIAL_PRD ,INCLUDE_INCREASES_FIRSTYR
  -- ELSE call ROLL_FWD_SELECNS

  IF l_partial_prd_id IS NOT NULL THEN
    pn_var_rent_calc_pkg.ROLL_FWD_PARTIAL_PRD(p_var_rent_id => p_var_rent_id);
    pn_var_rent_calc_pkg.INCLUDE_INCREASES_FIRSTYR(p_var_rent_id => p_var_rent_id);
  ELSE
    pn_var_rent_calc_pkg.ROLL_FWD_SELECNS(p_var_rent_id => p_var_rent_id);
  END IF;

  -- If proration rule = LY,FLY then call separate roll forward for last partial period
  IF g_proration_rule IN ( pn_var_rent_calc_pkg.G_PRORUL_LY
                          ,pn_var_rent_calc_pkg.G_PRORUL_FLY) THEN
    pn_var_rent_calc_pkg.ROLL_FWD_LST_PARTIAL_PRD(p_var_rent_id => p_var_rent_id);
  END IF;

  -- Roll forward for including rent increase terms
  pn_var_rent_calc_pkg.INCLUDE_INCREASES(p_var_rent_id => p_var_rent_id);
  inv_date_tab.delete;
  g_partial_prd_flag := NULL; -- clearing the roll fwd flag of 1st partial prd

  --Reset abatements for the periods for which we donot re-calculate
  pn_var_rent_calc_pkg.reset_abatements(p_var_rent_id);
  pnp_debug_pkg.log('g_calculation_method3:'||g_calculation_method);
   IF l_periods_out_t.COUNT > 0 THEN
    FOR p IN l_periods_out_t.FIRST..l_periods_out_t.LAST --
    --
    LOOP
      IF (g_calculation_method = 'T') THEN
        --Take true up invoices into account
        pnp_debug_pkg.log('True up');
        pn_var_trueup_pkg.set_trueup_flag('C');
        pn_var_trueup_pkg.apply_abatements
                    ( p_var_rent_id   => p_var_rent_id
                     ,p_period_id     => l_periods_out_t(p).period_id
                     ,p_flag => 'RESET');
      ELSE
        --No need to take trueup invoices into account.
        pnp_debug_pkg.log('Not true up');
        pn_var_rent_calc_pkg.apply_abatements
                    ( p_var_rent_id   => p_var_rent_id
                     ,p_period_id     => l_periods_out_t(p).period_id
                     ,p_flag => 'RESET');

      END IF;
    END LOOP;
   END IF;

   --Apply abatements
   IF l_periods_t.COUNT > 0 THEN
    FOR p IN l_periods_t.FIRST..l_periods_t.LAST --
    --
    LOOP
      IF (g_calculation_method = 'T') THEN
        pnp_debug_pkg.log('True up');
        NULL;
        --Take true up invoices into account
        pn_var_trueup_pkg.set_trueup_flag('C');
        pn_var_trueup_pkg.apply_abatements
                    ( p_var_rent_id   => p_var_rent_id
                     ,p_period_id     => l_periods_t(p).period_id
                     ,p_flag => 'CALCULATE');
      ELSE
        pnp_debug_pkg.log('Not true up');
        --No need to take trueup invoices into account.
        pn_var_rent_calc_pkg.apply_abatements
                    ( p_var_rent_id   => p_var_rent_id
                     ,p_period_id     => l_periods_t(p).period_id
                     ,p_flag => 'CALCULATE');

      END IF;
    END LOOP;
   END IF;

  /* deletes the draft term for which invoice_date or term template has changed.*/
  pn_var_rent_calc_pkg.delete_draft_terms( p_var_rent_id => p_var_rent_id);

  l_context := 'Loop for all cached periods';
  pnp_debug_pkg.log(l_context||' COMPLETE');
  pnp_debug_pkg.log('');

  /* -------------------------------------------------------------------------- */
  /* -------------------------------- CODE END -------------------------------- */
  /* -------------------------------------------------------------------------- */

  pnp_debug_pkg.log('+++++++++ calculate_rent END +++++++++++');
  pnp_debug_pkg.log('');

EXCEPTION
  WHEN OTHERS THEN
    pnp_debug_pkg.log
    ('**********************************************************************');
    pnp_debug_pkg.log('*** ERROR IN calculate_rent ***');
    pnp_debug_pkg.log('*** ERROR WHEN: '||l_context||' ***');
    pnp_debug_pkg.log
    ('**********************************************************************');
    RAISE;

END calculate_rent;
-------------------------------------------------------------------------------
-----------------------------Procedures for forecasted data--------------------
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  NAME         : insert_invoice_for
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  22.Sep.06  Shabda     o Created
--  5-Mar-07   Shabda     o Bug 5922493. Create invoices only when volumes exist.
--------------------------------------------------------------------------------
/*
This method can only be called when g_invoice_on = Forecasted
There are two options. g_calc_type = CALCULATE/RECONCILE.
If g_calc_type is CALCULATE, we only insert/update the forecasted.
If g_calc_type is RECONCILE, we insert/update both.
*/
PROCEDURE insert_invoice_for( p_var_rent_id IN NUMBER
                         ,p_period_id   IN NUMBER) IS

  /* get invoice dates for a period */
  CURSOR invoice_dates_c( p_vr_id  IN NUMBER
                         ,p_prd_id IN NUMBER) IS
    SELECT
     invoice_date
    ,NVL(SUM(tot_act_vol), 0)  AS total_actual_sales
    ,NVL(SUM(act_var_rent), 0) AS total_actual_rent
    ,NVL(SUM(for_var_rent), 0) AS total_forecasted_rent
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id
    GROUP BY
    invoice_date
    ORDER BY
    invoice_date;

  /* get latest invoice */
  CURSOR invoice2upd_c( p_vr_id  IN NUMBER
                       ,p_prd_id IN NUMBER
                       ,p_inv_dt IN DATE) IS
    SELECT
     var_rent_inv_id
    ,var_rent_id
    ,period_id
    ,invoice_date
    ,forecasted_term_status
    ,variance_term_status
    ,variance_exp_code
    ,forecasted_exp_code
    ,adjust_num
    ,tot_act_vol
    ,act_per_rent
    ,for_per_rent
    ,actual_invoiced_amount
    ,constr_actual_rent
    ,rec_abatement_override
    FROM
    pn_var_rent_inv_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    invoice_date = p_inv_dt
    AND
    NVL(true_up_amt, 0) = 0 AND
    true_up_status IS NULL AND
    true_up_exp_code IS NULL
    ORDER BY adjust_num DESC;

  /* get latest invoice */
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
    variance_exp_code = 'Y'
    AND
    NVL(true_up_amt, 0) = 0 AND
    true_up_status IS NULL AND
    true_up_exp_code IS NULL;

   CURSOR vol_exists_c(ip_var_rent_id NUMBER,
                      ip_invoice_date DATE
            ) IS
      SELECT 1 as vol_exists
      FROM DUAL
      WHERE exists(
      SELECT vol_hist_id
      FROM pn_var_vol_hist_all
      WHERE grp_date_id in(
      SELECT grp_date_id
      FROM pn_var_grp_dates_all
      WHERE var_rent_id = ip_var_rent_id
      AND invoice_date = ip_invoice_date));

  l_invoice_on          VARCHAR2(30);
  l_calc_type           VARCHAR2(30);
  l_row_id              ROWID;
  l_var_rent_inv_id     NUMBER;
  l_max_adjust_num      NUMBER;
  l_prev_inv_rent       NUMBER;
  l_curr_inv_rent       NUMBER;
  l_curr_inv_rent_for       NUMBER;
  l_actual_invoiced_amount  NUMBER;
  l_constr_rent         NUMBER;
  l_prev_inv_exp_rent   NUMBER;
  l_constr_prev_rent    NUMBER;
  l_rec_abatement_override NUMBER;

  /* get ORG ID */
  CURSOR org_c(p_vr_id IN NUMBER) IS
    SELECT org_id
      FROM pn_var_rents_all
     WHERE var_rent_id = p_vr_id;

  l_org_id NUMBER;
  l_precision NUMBER;
  l_exists_invoice BOOLEAN;

BEGIN

  pnp_debug_pkg.log('+++++++++ insert_invoice_for START +++++++++++');

  FOR vr_rec IN org_c(p_vr_id => p_var_rent_id) LOOP
    l_org_id := vr_rec.org_id;
  END LOOP;

  l_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(l_org_id),4);
  pnp_debug_pkg.log('l_precision:'||l_precision);

  l_calc_type := g_calc_type;
  pnp_debug_pkg.log('calc_type:'|| l_calc_type);

  /* loop for all invoice dates in the period */
  FOR inv_rec IN invoice_dates_c( p_vr_id  => p_var_rent_id
                                 ,p_prd_id => p_period_id)
  LOOP
  IF l_calc_type = G_CALC_TYPE_CALCULATE  THEN
    /*Three cases exist here.
    1. No invoice exist. We insert a invoice with forecasted rents.
    2. Invoice exists and has not been exported. Update the forecasted calculated rent.
    3. Invoice exists and has been exported. Do not update anything.
    */
    l_row_id              := NULL;
    l_var_rent_inv_id     := NULL;
    l_curr_inv_rent_for   := 0;
    l_exists_invoice      := FALSE;

    /* check if there exists an invoice for this invoice date */
    FOR inv2upd_rec IN invoice2upd_c( p_vr_id  => p_var_rent_id
                                     ,p_prd_id => p_period_id
                                     ,p_inv_dt => inv_rec.invoice_date)
    LOOP

      /* invoice exists - we only look at the last invoice */
      l_exists_invoice := TRUE;
      l_rec_abatement_override := inv2upd_rec.rec_abatement_override;
      /* invoice updateable? */
      IF NVL(inv2upd_rec.forecasted_exp_code, 'N') <> 'Y' THEN

        /* updateable */
        l_var_rent_inv_id := inv2upd_rec.var_rent_inv_id;
        l_curr_inv_rent_for   := inv2upd_rec.for_per_rent;

      ELSIF NVL(inv2upd_rec.forecasted_exp_code, 'N') = 'Y' THEN

        /* NON - updateable */
        l_var_rent_inv_id := NULL;

      END IF; /* invoice updateable? */

      /* we only look at the last invoice */
      EXIT;

    END LOOP; /* check if there exists an invoice for this invoice date */
    pnp_debug_pkg.log('l_var_rent_inv_id:' || l_var_rent_inv_id);

    /* atleast one invoice exists? */
    IF NOT l_exists_invoice
       /*AND inv_rec.total_actual_rent <> 0*/ THEN

      /* not sure abt this part
         uncomment the AND inv_rec.total_actual_rent <> 0
         part if we do not want to create $0 invoices
      */

      /* first time for this invoice date - create invoice */
      /*We are invoicing on forecasted, so when first time invoice is created, all actuals must be null*/


      /*We only want to create invoices if volumes exist for these invoices.*/
      FOR vol_exists_rec IN vol_exists_c( p_var_rent_id,
                                          inv_rec.invoice_date
                                          )  LOOP

         pnp_debug_pkg.log('inv_rec.total_forecasted_rent'||inv_rec.total_forecasted_rent);
         pn_var_rent_inv_pkg.insert_row
         ( x_rowid                   => l_row_id,
           x_var_rent_inv_id         => l_var_rent_inv_id,
           x_adjust_num              => 0,
           x_invoice_date            => inv_rec.invoice_date,
           x_for_per_rent            => inv_rec.total_forecasted_rent,
           x_tot_act_vol             => NULL,
           x_act_per_rent            => NULL,
           x_constr_actual_rent      => NULL,
           x_abatement_appl          => 0,
           x_rec_abatement           => NULL,
           x_rec_abatement_override  => l_rec_abatement_override,
           x_negative_rent           => 0,
           x_actual_invoiced_amount  => NULL,
           x_period_id               => p_period_id,
           x_var_rent_id             => p_var_rent_id,
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
           x_org_id                  => l_org_id );

      END LOOP;


    ELSIF l_exists_invoice THEN

      /* invoice has been created here in the past */

      /* no invoice to update - We have already created a forcasted invoice and exported it. */
      IF l_var_rent_inv_id IS NULL THEN
        NULL;

      ELSIF l_var_rent_inv_id IS NOT NULL THEN

        /* if there a change in rent */
        IF (inv_rec.total_forecasted_rent) <> l_curr_inv_rent_for
        THEN

          DELETE
          pn_payment_terms_all
          WHERE
          var_rent_inv_id = l_var_rent_inv_id AND
          status <> pn_var_rent_calc_pkg.G_TERM_STATUS_APPROVED AND
          var_rent_type = pn_var_rent_calc_pkg.G_INV_ON_FORECASTED;

          /* update the invoice */
          /*Since forcasted rents are not yet exported, we can update them.*/
          UPDATE
          pn_var_rent_inv_all
          SET
           for_per_rent           = ROUND(inv_rec.total_forecasted_rent, g_precision)
          ,forecasted_term_status = 'N'
          ,credit_flag            = 'N'  -- bug # 5937807
          ,last_update_date       = SYSDATE
          ,last_updated_by        = NVL(fnd_global.user_id,0)
          ,last_update_login      = NVL(fnd_global.login_id,0)
          WHERE
          var_rent_inv_id = l_var_rent_inv_id;

        END IF; /* if there a change in rent */

      END IF; /* IF l_var_rent_inv_id IS NULL THEN */

    END IF; /* IF NOT l_exists_invoice THEN */

    /*END l_calc_type = G_CALC_TYPE_CALCULATE*/

  ELSIF l_calc_type = G_CALC_TYPE_RECONCILE THEN
  /*We can only be reconciling if an invoice already exists*/
    l_row_id              := NULL;
    l_var_rent_inv_id     := -1;
    l_max_adjust_num      := 0;
    l_prev_inv_rent       := 0;
    l_curr_inv_rent       := 0;
    l_curr_inv_rent_for   := 0;

    pnp_debug_pkg.log('inv_rec.invoice_date'||inv_rec.invoice_date);
    pnp_debug_pkg.log('inv_rec.total_actual_rent:'||inv_rec.total_actual_rent);
    /* check if there exists an invoice for this invoice date */
    FOR inv2upd_rec IN invoice2upd_c( p_vr_id  => p_var_rent_id
                                     ,p_prd_id => p_period_id
                                     ,p_inv_dt => inv_rec.invoice_date)

    LOOP
       l_constr_prev_rent := inv2upd_rec.constr_actual_rent;
       l_prev_inv_rent := inv2upd_rec.act_per_rent;
      /* invoice updateable? */
      IF NVL(inv2upd_rec.variance_exp_code, 'N') <> 'Y' THEN

        /* updateable */
        l_var_rent_inv_id := inv2upd_rec.var_rent_inv_id;
        l_max_adjust_num  := inv2upd_rec.adjust_num;
        l_curr_inv_rent   := inv2upd_rec.actual_invoiced_amount;
        l_curr_inv_rent_for   := inv2upd_rec.for_per_rent;

      ELSIF NVL(inv2upd_rec.variance_exp_code, 'N') = 'Y' THEN

        /* NON - updateable */
        l_var_rent_inv_id := NULL;
        l_max_adjust_num  := inv2upd_rec.adjust_num + 1;
        l_curr_inv_rent   := 0;
        l_curr_inv_rent_for   := inv2upd_rec.for_per_rent;

      END IF; /* invoice updateable? */
      pnp_debug_pkg.log('inv2upd_rec.variance_exp_code:'||inv2upd_rec.variance_exp_code);
      pnp_debug_pkg.log('l_var_rent_inv_id:'||l_var_rent_inv_id);
      /* we only look at the last invoice */
      EXIT;

    END LOOP; /* check if there exists an invoice for this invoice date */

      /*Only if we are reconciling, do we need to update the last row or insert an adjustment.*/

      /* invoice has been created here in the past */


      /* get the previously billed amount from approved invoices */
      FOR prev_inv_rec IN prev_invoiced_c( p_vr_id  => p_var_rent_id
                                          ,p_prd_id => p_period_id
                                          ,p_inv_dt => inv_rec.invoice_date)
      LOOP
        l_prev_inv_exp_rent := prev_inv_rec.prev_invoiced_amt;
      END LOOP;

      l_constr_rent := pn_var_rent_calc_pkg.apply_constraints(
                                 p_period_id => p_period_id,
                                 p_invoice_date => inv_rec.invoice_date,
                                 p_actual_rent => inv_rec.total_actual_rent);
                                 --TODO.......

      /* no invoice to update - create a new one */
      IF l_var_rent_inv_id IS NULL THEN

        /* if there a change in rent */
        IF round(inv_rec.total_actual_rent, l_precision) <> round(l_prev_inv_rent, l_precision)
           OR round(l_constr_rent, l_precision) <> round(l_constr_prev_rent, l_precision)
        THEN

          /* create new invoice for difference amt */
          /* Forecasted rent is not updated in invoices. So always set it to prev invoiced forcasted ammount*/
          pn_var_rent_inv_pkg.insert_row
          ( x_rowid                   => l_row_id,
            x_var_rent_inv_id         => l_var_rent_inv_id,
            x_adjust_num              => l_max_adjust_num,
            x_invoice_date            => inv_rec.invoice_date,
            x_for_per_rent            => l_curr_inv_rent_for,
            x_tot_act_vol             => inv_rec.total_actual_sales,
            x_act_per_rent            => inv_rec.total_actual_rent,
            x_constr_actual_rent      => l_constr_rent,
            x_abatement_appl          => 0,
            x_rec_abatement           => NULL,
            x_rec_abatement_override  => l_rec_abatement_override,
            x_negative_rent           => 0,
            x_actual_invoiced_amount  => (l_constr_rent - l_prev_inv_exp_rent),
            x_period_id               => p_period_id,
            x_var_rent_id             => p_var_rent_id,
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
            x_org_id                  => l_org_id );

        END IF; /* IF inv_rec.total_actual_rent <> l_prev_inv_rent THEN */

      ELSIF l_var_rent_inv_id IS NOT NULL AND l_var_rent_inv_id <> -1 THEN

          DELETE
          pn_payment_terms_all
          WHERE
          var_rent_inv_id = l_var_rent_inv_id AND
          status <> pn_var_rent_calc_pkg.G_TERM_STATUS_APPROVED AND
          var_rent_type = pn_var_rent_calc_pkg.G_INV_ON_FORECASTED;

          /* update the invoice */
          UPDATE
          pn_var_rent_inv_all
          SET
           act_per_rent           = ROUND(inv_rec.total_actual_rent, g_precision)
          ,constr_actual_rent     = ROUND(l_constr_rent, g_precision)
          ,actual_invoiced_amount = ROUND((l_constr_rent - l_prev_inv_exp_rent), g_precision)
          ,tot_act_vol            = ROUND(inv_rec.total_actual_sales, g_precision)  -- bug # 6007571
          ,credit_flag            = 'N'     -- bug # 5937807
          ,variance_term_status   = 'N'
          ,last_update_date       = SYSDATE
          ,last_updated_by        = NVL(fnd_global.user_id,0)
          ,last_update_login      = NVL(fnd_global.login_id,0)
          WHERE
          var_rent_inv_id = l_var_rent_inv_id;


      END IF; /* IF l_var_rent_inv_id IS NULL THEN */
    /*END reconcile*/

  END IF;




  END LOOP; /* loop for all invoice dates in the period */

  pnp_debug_pkg.log('+++++++++ insert_invoice_for END +++++++++++');

EXCEPTION
  WHEN OTHERS THEN RAISE;

END insert_invoice_for;


--------------------------------------------------------------------------------
--  NAME         : get_rent_applicable_for
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  18.Sep.06  Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE get_rent_applicable_for
(p_trx_hdr_rec IN OUT NOCOPY pn_var_rent_calc_pkg.trx_hdr_for_c%ROWTYPE)
IS

  /* cache trx hdr passed */
  l_trx_hdr_rec pn_var_rent_calc_pkg.trx_hdr_for_c%ROWTYPE;

  /* get bkpt type */
  CURSOR bkpt_type_c(p_bkdt_id IN NUMBER) IS
    SELECT
     bkhd.bkpt_header_id
    ,bkhd.breakpoint_type
    FROM
     pn_var_bkpts_head_all bkhd
    ,pn_var_bkpts_det_all  bkdt
     WHERE
    bkdt.bkpt_detail_id = p_bkdt_id AND
    bkdt.bkpt_header_id = bkhd.bkpt_header_id;

  l_bkpt_type VARCHAR2(30);

  l_bkpts_t TRX_DTL_TBL;

  l_net_volume NUMBER;
  l_bkpt_start NUMBER;
  l_bkpt_end   NUMBER;
  l_calc_rent  NUMBER;


  /* get calc freq */
  CURSOR calc_freq_c(p_vr_id IN NUMBER) IS
    SELECT
    reptg_freq_code AS report_freq_code
    FROM
    pn_var_rent_dates_all
    WHERE
    var_rent_id = p_vr_id;

   /* get the number of periods */
  CURSOR period_num_c ( p_vr_id IN NUMBER) IS
    SELECT
    count(period_id) perion_num
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    NVL(status, 'A') <> pn_var_rent_calc_pkg.G_PERIOD_REVERSED_STATUS;

  /* get the last partial period */
  CURSOR last_period_c( p_vr_id     IN NUMBER) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd,
    pn_var_rents_all   var
    WHERE
    prd.var_rent_id = p_vr_id AND
    prd.var_rent_id = var.var_rent_id AND
    prd.end_date = var.termination_date;

  /* get the first partial period */
  CURSOR first_period_c( p_vr_id     IN NUMBER) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd,
    pn_var_rents_all   var
    WHERE
    prd.var_rent_id = p_vr_id AND
    prd.var_rent_id = var.var_rent_id AND
    prd.start_date = var.commencement_date;

  l_prorat_factor_sum NUMBER;

  l_prev_billed NUMBER;

  l_context VARCHAR2(255);

  l_first_partial VARCHAR2(1);
  l_last_partial  VARCHAR2(1);
  l_period_num    NUMBER  := 0;

BEGIN
  pnp_debug_pkg.log('++++++ Start get_rent_applicable ++++++');
  pnp_debug_pkg.log('p_trx_hdr_rec.invoice_flag:'||p_trx_hdr_rec.invoice_flag);
  IF NVL(p_trx_hdr_rec.invoice_flag, 'Y') = 'N' THEN
    RETURN;
  END IF;

  /* cache the trx header rec passed in */
  l_trx_hdr_rec := p_trx_hdr_rec;

  /* if VR details are not availabe at the package level, cache it */
  IF g_proration_rule IS NULL OR
     g_calculation_method IS NULL OR
     g_negative_rent IS NULL
  THEN

    /* cache VR details */
    pn_var_rent_calc_pkg.cache_vr_details
      (p_var_rent_id => l_trx_hdr_rec.var_rent_id);

  END IF;

  /* cache bkpt details */
  l_bkpts_t.DELETE;

  OPEN pn_var_rent_calc_pkg.trx_dtl_c(p_hdr_id => p_trx_hdr_rec.trx_header_id);
  FETCH pn_var_rent_calc_pkg.trx_dtl_c BULK COLLECT INTO l_bkpts_t;
  CLOSE pn_var_rent_calc_pkg.trx_dtl_c;

  /* get the breakpoint type - flat, sliding, stratified */
  FOR rec IN bkpt_type_c(p_bkdt_id => l_bkpts_t(1).bkpt_detail_id)
  LOOP
    pnp_debug_pkg.log('Breakpoint Type:'||rec.breakpoint_type);
    l_bkpt_type := rec.breakpoint_type;
  END LOOP;

  IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                              ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
  THEN
    l_net_volume := l_trx_hdr_rec.prorated_group_sales_for;

  ELSIF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_CUMULATIVE
                                 ,pn_var_rent_calc_pkg.G_CALC_YTD)
  THEN
    l_net_volume := l_trx_hdr_rec.ytd_sales_for;

  END IF;
  pnp_debug_pkg.log('l_net_volume'||l_net_volume);
  /* handling the case of volume not tripping any bkpts */
    /* init the calculated rent to 0 - it will be re-calculated */
  l_trx_hdr_rec.calculated_rent_for := 0;
  IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                              ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
     AND
     (l_net_volume < l_bkpts_t(1).prorated_grp_vol_start)

  THEN

    /* this is the functionality that exists today
       does not exist in Macerich code
       Once no breakpoints are tripped, Macerich consider the rent to be = 0 */
    /*
    l_trx_hdr_rec.calculated_rent
    := (l_net_volume - l_bkpts_t(1).pr_grp_blended_vol_start)
       * l_bkpts_t(1).bkpt_rate;
    */
    pnp_debug_pkg.log('Volume doesnot trip breakpoints');
    l_trx_hdr_rec.calculated_rent_for := 0;

  ELSE

    /* --------------------- GET calculated_rent START --------------------- */
    /* get l_trx_hdr_rec.calculated_rent - CALCULATED RENT */

    IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_STRATIFIED
    THEN

      l_trx_hdr_rec.calculated_rent_for := 0;

      /* loop for all bkpt details */
      FOR i IN l_bkpts_t.FIRST..l_bkpts_t.LAST LOOP

        IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                                    ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
        THEN

            l_bkpt_start := l_bkpts_t(i).prorated_grp_vol_start;
            l_bkpt_end   := l_bkpts_t(i).prorated_grp_vol_end;


        ELSIF g_calculation_method = pn_var_rent_calc_pkg.G_CALC_CUMULATIVE
        THEN
          IF g_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_NP THEN

            l_bkpt_start := l_bkpts_t(i).prorated_grp_vol_start;
            l_bkpt_end   := l_bkpts_t(i).prorated_grp_vol_end;

          ELSE

                l_bkpt_start := l_bkpts_t(i).blended_period_vol_start;
                l_bkpt_end   := l_bkpts_t(i).blended_period_vol_end;

          END IF;

        ELSIF g_calculation_method = pn_var_rent_calc_pkg.G_CALC_YTD
        THEN

          l_bkpt_start := l_bkpts_t(i).ytd_group_vol_start;
          l_bkpt_end   := l_bkpts_t(i).ytd_group_vol_end;

        END IF; /* g_calculation_method */

        IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
          l_bkpt_end := NULL;
        END IF;

        IF l_net_volume >= l_bkpt_start THEN

          IF l_net_volume <= NVL(l_bkpt_end, l_net_volume) THEN

            l_trx_hdr_rec.calculated_rent_for
            := l_trx_hdr_rec.calculated_rent_for
               + (l_net_volume - l_bkpt_start) * l_bkpts_t(i).bkpt_rate;

          ELSIF l_net_volume > l_bkpt_end THEN

            l_trx_hdr_rec.calculated_rent_for
            := l_trx_hdr_rec.calculated_rent_for
               + (l_bkpt_end - l_bkpt_start) * l_bkpts_t(i).bkpt_rate;
             pnp_debug_pkg.log('rent:'||l_trx_hdr_rec.calculated_rent_for);

          END IF;

        ELSE

          EXIT;

        END IF; /* net vol > bkpt start */

      END LOOP; /* loop for all bkpt details */

    ELSIF l_bkpt_type IN ( pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT
                          ,pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING)
    THEN

      FOR i IN l_bkpts_t.FIRST..l_bkpts_t.LAST LOOP

        IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                                    ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
        THEN

            l_bkpt_start := l_bkpts_t(i).prorated_grp_vol_start;
            l_bkpt_end   := l_bkpts_t(i).prorated_grp_vol_end;


        ELSIF g_calculation_method = pn_var_rent_calc_pkg.G_CALC_CUMULATIVE
        THEN

          IF g_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_NP THEN

            l_bkpt_start := l_bkpts_t(i).prorated_grp_vol_start;
            l_bkpt_end   := l_bkpts_t(i).prorated_grp_vol_end;

          ELSE

          l_bkpt_start := l_bkpts_t(i).blended_period_vol_start;
          l_bkpt_end   := l_bkpts_t(i).blended_period_vol_end;

          END IF;

        ELSIF g_calculation_method = pn_var_rent_calc_pkg.G_CALC_YTD
        THEN

          l_bkpt_start := l_bkpts_t(i).ytd_group_vol_start;
          l_bkpt_end   := l_bkpts_t(i).ytd_group_vol_end;

        END IF; /* g_calculation_method */

        IF l_bkpt_end IS NULL OR l_bkpt_end = 0 THEN
          l_bkpt_end := NULL;
        END IF;

        IF l_net_volume >= l_bkpt_start AND
           l_net_volume <= NVL(l_bkpt_end, l_net_volume)
        THEN

          IF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_SLIDING THEN

            l_trx_hdr_rec.calculated_rent_for
            := l_net_volume * l_bkpts_t(i).bkpt_rate;

          ELSIF l_bkpt_type = pn_var_rent_calc_pkg.G_BKPT_TYP_FLAT THEN

            l_trx_hdr_rec.calculated_rent_for
            := (l_net_volume - l_bkpt_start) * l_bkpts_t(i).bkpt_rate;
          pnp_debug_pkg.log('calculated_rent_for:'||l_trx_hdr_rec.calculated_rent_for);
          END IF;
          EXIT;

        END IF;

      END LOOP;

    END IF; /* breakpoint type */

    /* ---------------------- GET calculated_rent END ---------------------- */

    /* at this point, we have the calculated rent
       need to find
       - percent rent due for
       - ytd percent rent for */


    /* ------------ GET percent_rent_due for, ytd_percent_rent_for START ------------ */


    l_prev_billed
          := pn_var_rent_calc_pkg.find_prev_billed_for
              ( p_var_rent_id      => l_trx_hdr_rec.var_rent_id
               ,p_period_id        => l_trx_hdr_rec.period_id
               ,p_line_item_id     => l_trx_hdr_rec.line_item_id
               ,p_calc_prd_st_dt   => l_trx_hdr_rec.calc_prd_start_date
               ,p_calc_prd_end_dt  => l_trx_hdr_rec.calc_prd_end_date
               ,p_reset_grp_id     => l_trx_hdr_rec.reset_group_id);


    IF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_NON_CUMULATIVE
                                ,pn_var_rent_calc_pkg.G_CALC_TRUE_UP)
    THEN

      l_trx_hdr_rec.ytd_percent_rent_for := l_prev_billed + l_trx_hdr_rec.percent_rent_due_for;
      l_trx_hdr_rec.percent_rent_due_for := l_trx_hdr_rec.calculated_rent_for;

    ELSIF g_calculation_method IN ( pn_var_rent_calc_pkg.G_CALC_CUMULATIVE
                                   ,pn_var_rent_calc_pkg.G_CALC_YTD)
    THEN

        l_trx_hdr_rec.percent_rent_due_for
          := l_trx_hdr_rec.calculated_rent_for - l_prev_billed;

      /* need to
         - apply constraints on l_trx_hdr_rec.percent_rent_due
         - update l_trx_hdr_rec.percent_rent_due
         - then get the YTD
      */
      l_trx_hdr_rec.ytd_percent_rent_for
        := l_prev_billed + l_trx_hdr_rec.percent_rent_due_for;
    END IF;

      FOR period_num_rec IN period_num_c (p_vr_id => l_trx_hdr_rec.var_rent_id)
  LOOP

    l_period_num := period_num_rec.perion_num;

  END LOOP;

  FOR last_period_rec IN last_period_c (p_vr_id => l_trx_hdr_rec.var_rent_id)
  LOOP

    l_last_partial := last_period_rec.partial_period;

  END LOOP;

  FOR first_period_rec IN first_period_c (p_vr_id => l_trx_hdr_rec.var_rent_id)
  LOOP

    l_first_partial := first_period_rec.partial_period;

  END LOOP;

  /* IMP: This condition is to nullify the rents for a special case.
     The case is for First-LAst year, when we have just 2 periods and
     first year and last year period is partial, in such a case we dont
     want to calculate the rent.
  IF g_proration_rule IN (pn_var_rent_calc_pkg.G_PRORUL_FLY) AND
     l_period_num = 2 AND l_first_partial = 'Y' AND
     l_last_partial = 'Y'
  THEN
    l_trx_hdr_rec.percent_rent_due_for := 0;
    l_trx_hdr_rec.ytd_percent_rent_for := 0;
    l_trx_hdr_rec.calculated_rent_for  := 0;
  END IF;   */


  pnp_debug_pkg.log(' ');
  pnp_debug_pkg.log(' calculation_method: '||g_calculation_method);
  pnp_debug_pkg.log(' percent_rent_due: '||l_trx_hdr_rec.percent_rent_due_for);
  pnp_debug_pkg.log(' ytd_percent_rent: '||l_trx_hdr_rec.ytd_percent_rent_for);
  pnp_debug_pkg.log(' ');


    /* ------------- GET percent_rent_due, ytd_percent_rent END ------------- */

  END IF; /* volume trips breakpoint?? */
  pnp_debug_pkg.log('percent_rent_due_for:'||l_trx_hdr_rec.percent_rent_due_for);
  pnp_debug_pkg.log('ytd_rent_for:'||l_trx_hdr_rec.ytd_percent_rent_for);
  l_trx_hdr_rec.update_flag := 'Y';
  p_trx_hdr_rec := l_trx_hdr_rec;
  pnp_debug_pkg.log('------------end get_rent_applicable---------');

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_rent_applicable_for;

--------------------------------------------------------------------------------
--  NAME         : find_prev_billed_for
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  18.Sep.06  Shabda     o Created
--------------------------------------------------------------------------------
FUNCTION find_prev_billed_for( p_var_rent_id      IN NUMBER
                              ,p_period_id        IN NUMBER
                              ,p_line_item_id     IN NUMBER
                              ,p_calc_prd_st_dt   IN DATE
                              ,p_calc_prd_end_dt  IN DATE
                              ,p_reset_grp_id     IN NUMBER)
RETURN NUMBER IS

  /* get previous billed */
  CURSOR prev_billed_for_c( p_vr_id      IN NUMBER
                           ,p_prd_id     IN NUMBER
                           ,p_line_id    IN NUMBER
                           ,p_rst_grp_id IN NUMBER
                           ,p_date       IN DATE) IS
    SELECT NVL(SUM(percent_rent_due_for), 0) AS prev_billed_amt
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    line_item_id = p_line_id AND
    reset_group_id = p_rst_grp_id AND
    calc_prd_start_date < p_date;

  l_prev_billed_rent NUMBER;

BEGIN

  l_prev_billed_rent := 0;

  FOR rec IN prev_billed_for_c( p_vr_id      => p_var_rent_id
                           ,p_prd_id     => p_period_id
                           ,p_line_id    => p_line_item_id
                           ,p_rst_grp_id => p_reset_grp_id
                           ,p_date       => p_calc_prd_st_dt) LOOP

    l_prev_billed_rent := rec.prev_billed_amt;

  END LOOP;

  RETURN l_prev_billed_rent;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END find_prev_billed_for;

--------------------------------------------------------------------------------
--  NAME         : overage_cal_for
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  Ram Kumar     o Created
--------------------------------------------------------------------------------
FUNCTION overage_cal_for( p_proration_rule     IN VARCHAR2,
                          p_calculation_method IN VARCHAR2,
                          detail_id            IN NUMBER) RETURN NUMBER IS

l_bkpt_start                     NUMBER := 0;
l_bkpt_end                       NUMBER := 0;
overage                          NUMBER :=  0;
l_applicable_sales               NUMBER := 0;


CURSOR overage_cur IS
  SELECT  dtls.prorated_grp_vol_start,
          dtls.prorated_grp_vol_end,
          dtls.ytd_group_vol_start,
          dtls.ytd_group_vol_end,
          dtls.blended_period_vol_start,
          dtls.blended_period_vol_end,
          hdr.prorated_group_sales_for,
          hdr.ytd_sales_for
  FROM    pn_var_trx_headers_all hdr,
          pn_var_trx_details_all dtls
  WHERE   hdr.trx_header_id=dtls.trx_header_id
  AND dtls.trx_detail_id = detail_id;

BEGIN

  FOR overage_rec IN overage_cur LOOP

    IF  p_calculation_method IN ('N', 'T')
    THEN
      l_applicable_sales := (overage_rec.prorated_group_sales_for);

    ELSIF p_calculation_method IN ('Y', 'C')
    THEN
      l_applicable_sales := (overage_rec.ytd_sales_for);

    END IF;

    IF  p_calculation_method IN ('N', 'T')
    THEN

      l_bkpt_start := overage_rec.prorated_grp_vol_start;
      l_bkpt_end   := overage_rec.prorated_grp_vol_end;

    ELSIF p_calculation_method IN ('Y')
    THEN

      l_bkpt_start  :=   overage_rec.ytd_group_vol_start;
      l_bkpt_end    :=   overage_rec.ytd_group_vol_end;

    ELSIF p_calculation_method IN ('C')
    THEN

      IF p_proration_rule IN ('NP') THEN

        l_bkpt_start := overage_rec.prorated_grp_vol_start;
        l_bkpt_end   := overage_rec.prorated_grp_vol_end;

      ELSE

        l_bkpt_start := overage_rec.blended_period_vol_start;
        l_bkpt_end   := overage_rec.blended_period_vol_end;

      END IF;

    END IF;


    IF(l_bkpt_end = 0) THEN
       overage := greatest(l_applicable_sales - l_bkpt_start,0);
    ELSE
       IF((l_applicable_sales >= l_bkpt_start) AND (l_applicable_sales <= l_bkpt_end)) THEN
           overage :=  l_applicable_sales - l_bkpt_start;
       ELSIF(l_applicable_sales > l_bkpt_end) THEN
           overage := l_bkpt_end - l_bkpt_start;
       ELSIF(l_applicable_sales < l_bkpt_start) THEN
           overage := 0;
       END IF;
    END IF;

  END LOOP;

  return overage;

  EXCEPTION
  WHEN OTHERS THEN RAISE;
END overage_cal_for;

--------------------------------------------------------------------------------
--  NAME         : First_Day
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  Ram Kumar     o Created
--------------------------------------------------------------------------------

FUNCTION First_Day ( p_Date DATE ) RETURN DATE IS
BEGIN

  RETURN ADD_MONTHS(LAST_DAY(p_Date) + 1,  -1);

 EXCEPTION
  WHEN OTHERS THEN RAISE;

END First_Day;

--------------------------------------------------------------------------------
--  NAME         : inv_end_date
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  Ram Kumar     o Created
--------------------------------------------------------------------------------

FUNCTION inv_end_date( inv_start_date IN DATE
                     , vr_id IN NUMBER
                     , p_period_id NUMBER) RETURN DATE IS

inv_end_date                  DATE;
l_invg_freq_code              NUMBER;
l_vr_term_date                DATE;
l_proration_rule              VARCHAR2(30);
l_period_end_date             DATE;
l_reversed_status             VARCHAR2(30);

CURSOR inv_end_date_cur IS
   SELECT var.termination_date,
          DECODE(dates.invg_freq_code,'MON',1
                                     ,'QTR',3
                                     ,'SA' ,6
                                     ,'YR' ,12
                                     ,NULL) invg_freq_code,
          var.proration_rule
   FROM   PN_VAR_RENTS_ALL var, PN_VAR_RENT_DATES_ALL dates
   WHERE  var.var_rent_id  = vr_id
   AND    dates.var_rent_id = var.var_rent_id;


CURSOR inv_ed_dt_cur (p_inv_start_date DATE) IS
  SELECT DISTINCT inv_end_date
  FROM pn_var_grp_dates_all
  WHERE var_rent_id = vr_id
  AND inv_start_date = p_inv_start_date;

CURSOR period_cur IS
  SELECT period_id, end_date
  FROM pn_var_periods_all
  WHERE var_rent_id = vr_id
  AND partial_period = 'Y'
  AND period_num = 1;

CURSOR last_period_cur IS
  SELECT period_id,
         end_date,
         decode(status,'REVERSED','Y','N') status
  FROM pn_var_periods_all
  WHERE var_rent_id = vr_id
  AND period_id = p_period_id;

BEGIN

FOR rec IN inv_end_date_cur LOOP
   l_vr_term_date := rec.termination_date;
   l_invg_freq_code := rec.invg_freq_code;
   l_proration_rule := rec.proration_rule;
END LOOP;

IF l_proration_rule IN ('FY', 'FLY') THEN
   FOR rec IN period_cur LOOP
      IF(rec.period_id = p_period_id) THEN
         RETURN rec.end_date;
      END IF;
   END LOOP;
END IF;

inv_end_date := ADD_MONTHS(inv_start_date,l_invg_freq_code)-1;

FOR rec_period_csr IN last_period_cur LOOP
   l_period_end_date  := rec_period_csr.end_date;
   l_reversed_status  := rec_period_csr.status;
END LOOP;

/* Case 1 - When period is active and invoice lies within new termination date */
IF (inv_end_date > l_vr_term_date AND inv_start_date <= l_vr_term_date AND l_reversed_status = 'N') THEN
    inv_end_date := l_vr_term_date;
/* Case 2 - When period is reversed */
ELSIF (l_reversed_status = 'Y' AND inv_end_date >  l_period_end_date) THEN
    inv_end_date := l_period_end_date;
/* Case 3 - When period is active and invoice lies outside new termination date */
ELSIF (l_reversed_status = 'N' AND inv_start_date > l_vr_term_date) THEN

   FOR rec IN inv_ed_dt_cur(inv_start_date) LOOP
      inv_end_date := rec.inv_end_date;
   END LOOP;
END IF;

RETURN inv_end_date;

 EXCEPTION
  WHEN OTHERS THEN RAISE;

END inv_end_date;

--------------------------------------------------------------------------------
--  NAME         : inv_start_date
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  Ram Kumar     o Created
--------------------------------------------------------------------------------

FUNCTION inv_start_date( inv_start_date IN DATE
                       , vr_id IN NUMBER
                       , p_period_id NUMBER) RETURN DATE IS

inv_end_date                  DATE;
l_invg_freq_code              NUMBER;
l_vr_term_date                DATE;
l_proration_rule              VARCHAR2(30);
l_start_date                  DATE;

CURSOR inv_start_date_cur IS
   SELECT var.proration_rule,
          var.commencement_date,
          var.termination_date
   FROM   PN_VAR_RENTS_ALL var
   WHERE  var.var_rent_id  = vr_id;


CURSOR period_cur IS
  SELECT period_id, start_date
  FROM pn_var_periods_all
  WHERE var_rent_id = vr_id
  AND partial_period = 'Y'
  AND period_num = 1;

CURSOR period_last_cur IS
  SELECT period_id, start_date
  FROM pn_var_periods_all
  WHERE var_rent_id = vr_id
  AND partial_period = 'Y';


BEGIN

FOR rec IN inv_start_date_cur LOOP
   l_proration_rule := rec.proration_rule;
   l_vr_term_date   := rec.termination_date;
   l_start_date     := rec.commencement_date;
END LOOP;


IF l_proration_rule IN ('LY', 'FLY') THEN
   FOR rec IN period_last_cur LOOP
      IF(rec.period_id = p_period_id) THEN
         IF(pn_var_rent_calc_pkg.inv_end_date(inv_start_date,vr_id,p_period_id) = l_vr_term_date) THEN
            RETURN rec.start_date;
         END IF;
      END IF;
   END LOOP;
END IF;

IF l_proration_rule IN ('FY', 'FLY') THEN
   FOR rec IN period_cur LOOP
      IF(rec.period_id = p_period_id) THEN
         RETURN rec.start_date;
      END IF;
   END LOOP;
END IF;

IF l_start_date > inv_start_date THEN
   RETURN l_start_date;
ELSE
   RETURN inv_start_date;
END IF;

 EXCEPTION
  WHEN OTHERS THEN RAISE;

END inv_start_date;

--------------------------------------------------------------------------------
--  NAME         : INV_SCH_DATE
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  Ram Kumar     o Created
-- 02-APR-06  sdmahesh      o Bug # 5962894
--                            Used PN_VAR_RENT_CALC_PKG.INV_END_DATE to find
--                            INV_END_DATE
--------------------------------------------------------------------------------

FUNCTION inv_sch_date(inv_start_date IN DATE
                     ,vr_id IN NUMBER
                     ,p_period_id NUMBER) RETURN DATE IS


inv_end_date                  DATE := NULL;
inv_schedule_date             DATE := NULL;
l_invg_day_of_month           NUMBER;
l_invg_days_after             NUMBER;
l_invg_freq_code              NUMBER;
l_vr_term_date                DATE;
l_proration_rule              VARCHAR2(30);

 CURSOR inv_sch_date_cur IS
   SELECT dates.invg_day_of_month,
          dates.invg_days_after,
          var.termination_date,
          var.proration_rule,
          DECODE(dates.invg_freq_code,'MON',1
                                     ,'QTR',3
                                     ,'SA' ,6
                                     ,'YR' ,12
                                     ,NULL) invg_freq_code
   FROM   PN_VAR_RENTS_ALL var, PN_VAR_RENT_DATES_ALL dates
   WHERE  var.var_rent_id  = vr_id
   AND    dates.var_rent_id = var.var_rent_id;

CURSOR last_period_cur IS
  SELECT period_id,
         decode(status,'REVERSED','Y','N') status
  FROM pn_var_periods_all
  WHERE var_rent_id = vr_id
  AND period_id = p_period_id;

CURSOR period_cur IS
  SELECT period_id, start_date
  FROM pn_var_periods_all
  WHERE var_rent_id = vr_id
  AND partial_period = 'Y'
  AND period_num = 1;

CURSOR first_period_cur IS
  SELECT period_id
  FROM pn_var_rent_summ_all
  WHERE var_rent_id = vr_id
  AND nvl(first_yr_rent,0) <> 0
  AND rownum < 2;

BEGIN

FOR rec IN inv_sch_date_cur LOOP
   l_invg_day_of_month := rec.invg_day_of_month;
   l_invg_days_after := rec.invg_days_after;
   l_vr_term_date := rec.termination_date;
   l_invg_freq_code := rec.invg_freq_code;
   l_proration_rule := rec.proration_rule;
END LOOP;

FOR rec_period_csr IN last_period_cur LOOP

   inv_end_date := pn_var_rent_calc_pkg.inv_end_date(inv_start_date,
                                                     vr_id,
                                                     rec_period_csr.period_id);

END LOOP;

IF l_proration_rule IN ('FY', 'FLY') THEN
   FOR rec IN period_cur LOOP
      IF(rec.period_id = p_period_id) THEN
         --
         FOR rec_first_prd IN first_period_cur LOOP
            inv_end_date := pn_var_rent_calc_pkg.inv_end_date(inv_start_date,
                                                     vr_id,
                                                     rec_first_prd.period_id);
         END LOOP;
      END IF;
   END LOOP;
END IF;


  inv_schedule_date :=
    NVL( ((ADD_MONTHS(pn_var_rent_calc_pkg.First_Day(inv_end_date),1)-1) + l_invg_day_of_month),
            (inv_end_date + nvl(l_invg_days_after,0)) );

  ------------------------------------------------------------
  -- takes care of the only 28 days for the schedule day
  ------------------------------------------------------------
  IF TO_NUMBER(TO_CHAR(inv_schedule_date,'dd')) in (29,30,31) THEN
    inv_schedule_date := (pn_var_rent_calc_pkg.First_Day(inv_schedule_date)+27);
  END IF;
  ------------------------------------------------------------

RETURN inv_schedule_date;

 EXCEPTION
  WHEN OTHERS THEN RAISE;

END inv_sch_date;
--------------------------------------------------------------------------------
--  NAME         : Post_summary_for
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  18.Sep.06  Shabda     o Created
--  21-MAY-07  Lokesh     o Added rounding off for bug # 6031202 in
--                          pn_var_rent_summ_all
--------------------------------------------------------------------------------
PROCEDURE post_summary_for ( p_var_rent_id  IN NUMBER
                        ,p_period_id    IN NUMBER
                        ,p_line_item_id IN NUMBER
                        ,p_grp_date_id  IN NUMBER)
IS

  /* get grp date */
  CURSOR grp_date_c( p_vr_id  IN NUMBER
                    ,p_prd_id IN NUMBER
                    ,p_grp_id IN NUMBER) IS
    SELECT
     grp.grp_date_id
    ,grp.group_date
    ,grp.invoice_date
    ,grp.org_id
    FROM
    pn_var_grp_dates_all grp
    WHERE
    grp.var_rent_id = p_vr_id  AND
    grp.period_id   = p_prd_id AND
    grp.grp_date_id = p_grp_id;

  /* Get rent and volume to store in pn_var_rent_summ_all */
  CURSOR summ_c( p_vr_id   IN NUMBER
                ,p_prd_id  IN NUMBER
                ,p_line_id IN NUMBER
                ,p_grp_id  IN NUMBER) IS
    SELECT
     NVL(SUM(hdr.percent_rent_due_for)
         , 0) AS rent
    ,NVL(SUM(hdr.prorated_group_sales_for)
         , 0) AS sales
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id  = p_vr_id AND
    hdr.period_id    = p_prd_id AND
    hdr.line_item_id = p_line_id AND
    hdr.grp_date_id  = p_grp_id;

  /* exists VR summ record */
  CURSOR vr_summ_c ( p_vr_id  IN NUMBER
                    ,p_prd_id IN NUMBER
                    ,p_line_id IN NUMBER
                    ,p_grp_id IN NUMBER) IS
    SELECT
    var_rent_summ_id
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    line_item_id = p_line_id AND
    grp_date_id = p_grp_id;

  l_vr_summ_id NUMBER;

BEGIN

  /* get the invoice date for the group
     loops only once
  */
  FOR grp_rec IN grp_date_c( p_vr_id  => p_var_rent_id
                            ,p_prd_id => p_period_id
                            ,p_grp_id => p_grp_date_id)
  LOOP

    /* get the sum of rents and sales for
       vr -> period -> line item -> group combination
       from the trx tables
       loops only once
    */
    FOR summ_rec IN summ_c( p_vr_id   => p_var_rent_id
                           ,p_prd_id  => p_period_id
                           ,p_line_id => p_line_item_id
                           ,p_grp_id  => p_grp_date_id)
    LOOP

      l_vr_summ_id := NULL;

      /* chk if VR SUMM record exists for this
         vr -> period -> line item -> group combination */
      FOR vr_summ_rec IN vr_summ_c( p_vr_id   => p_var_rent_id
                                   ,p_prd_id  => p_period_id
                                   ,p_line_id => p_line_item_id
                                   ,p_grp_id  => p_grp_date_id)
      LOOP
        l_vr_summ_id := vr_summ_rec.var_rent_summ_id;
      END LOOP;

      IF l_vr_summ_id IS NULL THEN

        /* to insert a new summary record */
        INSERT INTO
        pn_var_rent_summ_all
          (var_rent_summ_id
          ,var_rent_id
          ,period_id
          ,line_item_id
          ,invoice_date
          ,tot_for_vol
          ,for_var_rent
          ,grp_date_id
          ,group_date
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,org_id)
        VALUES
          (pn_var_rent_summ_s.NEXTVAL
          ,p_var_rent_id
          ,p_period_id
          ,p_line_item_id
          ,grp_rec.invoice_date
          ,summ_rec.sales
          ,round(summ_rec.rent,g_precision)
          ,grp_rec.grp_date_id
          ,grp_rec.group_date
          ,SYSDATE
          ,NVL(fnd_global.user_id, 0)
          ,SYSDATE
          ,NVL(fnd_global.user_id, 0)
          ,NVL(fnd_global.login_id, 0)
          ,NVL(grp_rec.org_id, g_org_id))
        RETURNING
        var_rent_summ_id
        INTO
        l_vr_summ_id;

      ELSIF l_vr_summ_id IS NOT NULL THEN
        /* update the summary record */

        UPDATE
        pn_var_rent_summ_all
        SET
         tot_for_vol  = summ_rec.sales
        ,for_var_rent = round(summ_rec.rent,g_precision)
        ,last_update_date  = SYSDATE
        ,last_updated_by   = NVL(fnd_global.user_id, 0)
        ,last_update_login = NVL(fnd_global.login_id, 0)
        WHERE
        var_rent_summ_id = l_vr_summ_id;

      END IF;

      UPDATE
      pn_var_trx_headers_all hdr
      SET
      hdr.var_rent_summ_id = l_vr_summ_id
      WHERE
      hdr.var_rent_id  = p_var_rent_id AND
      hdr.period_id    = p_period_id AND
      hdr.line_item_id = p_line_item_id AND
      hdr.grp_date_id  = p_grp_date_id;

      EXIT;

    END LOOP;

    EXIT;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END post_summary_for;


--------------------------------------------------------------------------------
--  NAME         : post_summary_for
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  18.Sep.06  Shabda     o Created
--  21-MAY-07  Lokesh     o Added rounding off for bug # 6031202 in
--                          pn_var_rent_summ_all
--------------------------------------------------------------------------------
PROCEDURE post_summary_for ( p_var_rent_id  IN NUMBER
                        ,p_period_id    IN NUMBER)
IS

  /* get all lines */
  CURSOR lines_c( p_vr_id  IN NUMBER
                 ,p_prd_id IN NUMBER) IS
    SELECT
    line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id;

  /* get grp date */
  CURSOR grp_date_c( p_vr_id  IN NUMBER
                    ,p_prd_id IN NUMBER) IS
    SELECT
     grp.grp_date_id
    ,grp.group_date
    ,grp.invoice_date
    ,grp.org_id
    FROM
     pn_var_grp_dates_all grp
    ,pn_var_periods_all   prd
    WHERE
    prd.var_rent_id = p_vr_id  AND
    prd.period_id   = p_prd_id AND
    grp.period_id   = prd.period_id AND
    grp.grp_end_date <= prd.end_date;

  TYPE GRP_TBL IS TABLE OF grp_date_c%ROWTYPE INDEX BY BINARY_INTEGER;
  l_grp_t GRP_TBL;

  /* Get rent and volume to store in pn_var_rent_summ_all */
  CURSOR summ_c( p_vr_id   IN NUMBER
                ,p_prd_id  IN NUMBER
                ,p_line_id IN NUMBER
                ,p_grp_id  IN NUMBER) IS
    SELECT
     NVL(SUM(hdr.percent_rent_due_for)
         , 0) AS rent
    ,NVL(SUM(hdr.prorated_group_sales_for)
         , 0) AS sales
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id  = p_vr_id AND
    hdr.period_id    = p_prd_id AND
    hdr.line_item_id = p_line_id AND
    hdr.grp_date_id  = p_grp_id;

  /* exists VR summ record */
  CURSOR vr_summ_c ( p_vr_id  IN NUMBER
                    ,p_prd_id IN NUMBER
                    ,p_line_id IN NUMBER
                    ,p_grp_id IN NUMBER) IS
    SELECT
     var_rent_summ_id
    ,tot_for_vol
    ,for_var_rent
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    line_item_id = p_line_id AND
    grp_date_id = p_grp_id;

  l_vr_summ_id NUMBER;

BEGIN

  l_grp_t.DELETE;

  OPEN grp_date_c( p_vr_id  => p_var_rent_id
                  ,p_prd_id => p_period_id);
  FETCH grp_date_c BULK COLLECT INTO l_grp_t;
  CLOSE grp_date_c;
  pnp_debug_pkg.log('total groups:'||l_grp_t.COUNT);
  /* loop for all lines in the annual period */
  FOR line_rec IN lines_c( p_vr_id  => p_var_rent_id
                          ,p_prd_id => p_period_id)
  LOOP
    pnp_debug_pkg.log('looping for line:'||line_rec.line_item_id);
    /* loop for all calc periods in the annual period */
    FOR g IN 1..l_grp_t.COUNT LOOP
      pnp_debug_pkg.log('looping for group:'||l_grp_t(g).grp_date_id);
      /* get the sum of rents and sales for
         vr -> period -> line item -> group combination
         from the trx tables
         -- loops only once --
      */
      FOR summ_rec IN summ_c( p_vr_id   => p_var_rent_id
                             ,p_prd_id  => p_period_id
                             ,p_line_id => line_rec.line_item_id
                             ,p_grp_id  => l_grp_t(g).grp_date_id)
      LOOP

        l_vr_summ_id := NULL;
        pnp_debug_pkg.log('rent'||summ_rec.rent);
        /* chk if VR SUMM record exists for this
           vr -> period -> line item -> group combination */
        FOR vr_summ_rec IN vr_summ_c( p_vr_id   => p_var_rent_id
                                     ,p_prd_id  => p_period_id
                                     ,p_line_id => line_rec.line_item_id
                                     ,p_grp_id  => l_grp_t(g).grp_date_id)
        LOOP

          l_vr_summ_id := vr_summ_rec.var_rent_summ_id;

          IF NVL(summ_rec.sales,0) <> NVL(vr_summ_rec.tot_for_vol,0) OR
             NVL(summ_rec.rent,0)  <> NVL(vr_summ_rec.for_var_rent,0)
          THEN
            pnp_debug_pkg.log('sales:'||summ_rec.sales);
            pnp_debug_pkg.log('rent: '||summ_rec.rent);
            UPDATE
            pn_var_rent_summ_all
            SET
             tot_for_vol  = summ_rec.sales
            ,for_var_rent = round(summ_rec.rent,g_precision)
            ,last_update_date  = SYSDATE
            ,last_updated_by   = NVL(fnd_global.user_id, 0)
            ,last_update_login = NVL(fnd_global.login_id, 0)
            WHERE
            var_rent_summ_id = l_vr_summ_id;

          END IF;

        END LOOP; /* chk if VR SUMM exists vr -> prd -> line -> grp combo */

        IF l_vr_summ_id IS NULL THEN

          /* to insert a new summary record */
          pnp_debug_pkg.log('Inserting a new record for var_rent_summ table');
          INSERT INTO
          pn_var_rent_summ_all
            (var_rent_summ_id
            ,var_rent_id
            ,period_id
            ,line_item_id
            ,invoice_date
            ,tot_for_vol
            ,for_var_rent
            ,grp_date_id
            ,group_date
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,org_id)
          VALUES
            (pn_var_rent_summ_s.NEXTVAL
            ,p_var_rent_id
            ,p_period_id
            ,line_rec.line_item_id
            ,l_grp_t(g).invoice_date
            ,summ_rec.sales
            ,round(summ_rec.rent,g_precision)
            ,l_grp_t(g).grp_date_id
            ,l_grp_t(g).group_date
            ,SYSDATE
            ,NVL(fnd_global.user_id, 0)
            ,SYSDATE
            ,NVL(fnd_global.user_id, 0)
            ,NVL(fnd_global.login_id, 0)
            ,NVL(l_grp_t(g).org_id, g_org_id))
          RETURNING
          var_rent_summ_id
          INTO
          l_vr_summ_id;
          pnp_debug_pkg.log('Inserted rent summ with id: '||l_vr_summ_id);
        END IF;
        UPDATE
        pn_var_trx_headers_all hdr
        SET
        hdr.var_rent_summ_id = l_vr_summ_id
        WHERE
        hdr.var_rent_id  = p_var_rent_id AND
        hdr.period_id    = p_period_id AND
        hdr.line_item_id = line_rec.line_item_id AND
        hdr.grp_date_id  = l_grp_t(g).grp_date_id;

        EXIT;

      END LOOP; /* get the sum of rents and sales for
                   vr -> period -> line item -> group combination */

    END LOOP; /* loop for all calc periods in the annual period */

  END LOOP; /* loop for all lines in the annual period */

EXCEPTION
  WHEN OTHERS THEN RAISE;

END post_summary_for;
/*end forecasted data procedures*/


--------------------------------------------------------------------------------
--
--  NAME         :
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      : Shabda. Set global variables g_calc_type and g_invoice_on.
--
--  dd-mon-yyyy  name     o Created
--  21-AUG-2008  acprakas o Bug#6849764. Modified to pass rec_get_per.period_id for period id while calling
--                          pn_var_rent_calc_pkg.calculate_rent.
--  15-JUN-2009  jsundara o Bug#6691869. Modified to skip the calculation of VRs having calculation method "Manual".
--------------------------------------------------------------------------------
PROCEDURE process_rent_batch ( errbuf                OUT NOCOPY  VARCHAR2,
                               retcode               OUT NOCOPY  VARCHAR2,
                               p_property_code       IN  VARCHAR2,
                               p_property_name       IN  VARCHAR2,
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
                               p_calc_type           IN  VARCHAR2,
                               p_period_date         IN  VARCHAR2,
                               p_org_id              IN  NUMBER )
IS

CURSOR csr_get_vrent_wprop IS
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
AND    ploc.location_id IN (SELECT location_id
                             FROM  pn_locations_all
                           START WITH location_id
                                              IN
                                                (SELECT location_id
                                                   FROM pn_locations_all
                                                  WHERE property_id IN(SELECT property_id
                                                                       FROM pn_properties_all
                                                                      WHERE property_code=NVL(p_property_code,property_code)
                                                                         OR property_name=NVL(p_property_name,property_name))
                                                )
                          CONNECT BY PRIOR location_id=parent_location_id)
AND    pl.lease_num >= NVL(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= NVL(p_lease_num_to, pl.lease_num)
AND    ploc.location_code >= NVL(p_location_code_from, ploc.location_code)
AND    ploc.location_code <= NVL(p_location_code_to, ploc.location_code)
AND    pvr.rent_num >= NVL(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= NVL(p_vrent_num_to,pvr.rent_num)
AND    pld.responsible_user = NVL(p_responsible_user, pld.responsible_user)
AND    pvr.invoice_on = NVL(p_invoice_on,pvr.invoice_on)
AND    pl.org_id = NVL(p_org_id,pl.org_id)
ORDER BY pl.lease_id, pvr.var_rent_id;

CURSOR csr_get_vrent_wloc IS
SELECT pvr.var_rent_id,
       pvr.invoice_on,
       pvr.cumulative_vol,
       pvr.rent_num,
       pl.org_id
FROM   pn_leases           pl,
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
AND    pl.org_id = NVL(p_org_id,pl.org_id)
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
AND    pl.org_id = NVL(p_org_id,pl.org_id)
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


l_var_rent_id  pn_var_rents.var_rent_id%TYPE;
l_invoice_on   pn_var_rents.invoice_on%TYPE;
l_cumulative   pn_var_rents.cumulative_vol%TYPE;
l_rent_num     pn_var_rents.rent_num%TYPE;
l_errbuf       VARCHAR2(2000);
l_retcode      VARCHAR2(2000);
l_ext_precision NUMBER;
l_min_acct_unit NUMBER;
v_var_id_details_exists NUMBER;


BEGIN

  pnp_debug_pkg.log
  ('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  pnp_debug_pkg.log('+++++++++ process_rent_batch START +++++++++++');
  pnp_debug_pkg.log(' ');
  pnp_debug_pkg.log('Setting invoice_on and calc_type');
 -- g_invoice_on := p_invoice_on;
  g_calc_type  := p_calc_type;
  pnp_debug_pkg.log('g_invoice_on:'||g_invoice_on);
  pnp_debug_pkg.log('g_calc_type'||g_calc_type);

    pnp_debug_pkg.log('pn_var_rent_calc_pkg.process_rent_batch (+)' );


    fnd_message.set_name ('PN','PN_VRAM_PRM');
    fnd_message.set_token ('PT_NAME', p_property_name);
    fnd_message.set_token ('PT_CODE', p_property_code);
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

    IF p_property_code IS NOT NULL OR p_property_name IS NOT NULL THEN

        OPEN csr_get_vrent_wprop;


    ELSIF p_location_code_from IS NOT NULL or p_location_code_to IS NOT NULL THEN
        -----------------------------------------------------------------------------
        -- Checking Location Code From, Location Code To to open appropriate cursor.
        -----------------------------------------------------------------------------
        OPEN csr_get_vrent_wloc;

    ELSE

        OPEN csr_get_vrent_woloc;

    END IF;


    LOOP

         IF csr_get_vrent_wprop%ISOPEN THEN

           FETCH csr_get_vrent_wprop INTO l_var_rent_id,l_invoice_on,l_cumulative,l_rent_num,g_org_id;
           EXIT WHEN csr_get_vrent_wprop%NOTFOUND;
           pnp_debug_pkg.log   ('process_rent_batch - Inside cur : ' );
         ELSIF csr_get_vrent_wloc%ISOPEN THEN

           FETCH csr_get_vrent_wloc INTO l_var_rent_id,l_invoice_on,l_cumulative,l_rent_num,g_org_id;
           EXIT WHEN csr_get_vrent_wloc%NOTFOUND;

         ELSIF csr_get_vrent_woloc%ISOPEN THEN

           FETCH csr_get_vrent_woloc INTO l_var_rent_id,l_invoice_on,l_cumulative,l_rent_num,g_org_id;
           EXIT WHEN csr_get_vrent_woloc%NOTFOUND;

         END IF;

       IF  l_cumulative = 'M' THEN
	  fnd_message.set_name ('PN','PN_VAR_MANUAL_NOCALC');
          fnd_message.set_token ('VR_NUM',l_rent_num);
          pnp_debug_pkg.put_log_msg(fnd_message.get);
      ELSE
       g_invoice_on := NVL(p_invoice_on,l_invoice_on);
       g_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(g_org_id),4);

       fnd_message.set_name ('PN','PN_VRAM_VRN_PROC');
       fnd_message.set_token ('NUM',l_rent_num);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

       pnp_debug_pkg.log   ('process_rent_batch - Variable Rent id     :'||l_var_rent_id);
       pnp_debug_pkg.log   ('process_rent_batch - org_id               :'||g_org_id);

        v_var_id_details_exists :=PN_VAR_RENT_PKG.find_if_volhist_bkpts_exist
                                     ( l_var_rent_id,
                                       'VAR_RENT_ID' );

       IF v_var_id_details_exists = 1 THEN

         FOR rec_get_per in csr_get_per(l_var_rent_id)
         LOOP

             fnd_message.set_name ('PN','PN_VRAM_PRD_PROC');
                  fnd_message.set_token ('NUM',rec_get_per.period_num);
                  pnp_debug_pkg.put_log_msg(fnd_message.get);

             pnp_debug_pkg.log   ('process_rent_batch - period st date : '||rec_get_per.start_date);
             pnp_debug_pkg.log   ('process_rent_batch - period end date: '||rec_get_per.end_date);



            pn_var_rent_calc_pkg.calculate_rent
                         (p_var_rent_id => l_var_rent_id
                          ,p_period_id  => rec_get_per.period_id);	   --Bug#6849764

           END LOOP;


          END IF;
	  END IF;
       END LOOP;

        IF csr_get_vrent_wloc%ISOPEN THEN
           CLOSE csr_get_vrent_wloc;
        ELSIF csr_get_vrent_woloc%ISOPEN THEN
           CLOSE csr_get_vrent_woloc;
        ELSIF csr_get_vrent_wprop%ISOPEN THEN
           CLOSE csr_get_vrent_wprop;
        END IF;



    pnp_debug_pkg.log(' ');
    pnp_debug_pkg.log('+++++++++ process_rent_batch END +++++++++++');
    pnp_debug_pkg.log('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

EXCEPTION
  WHEN OTHERS THEN
   pnp_debug_pkg.log('Error in pn_var_rent_calc_pkg.process_rent_batch :'||TO_CHAR(sqlcode)||' : '||sqlerrm);
   Errbuf  := SQLERRM;
   Retcode := 2;
   rollback;
   raise;
   pnp_debug_pkg.log('pn_var_rent_calc_pkg.process_rent_batch  (-) ');

END process_rent_batch;

FUNCTION END_BREAKPOINT(bkpt_start IN NUMBER, bkpt_end IN  NUMBER) RETURN NUMBER IS
l_num  NUMBER;
BEGIN
 IF (bkpt_end = 0) THEN
     l_num := NULL;
 ELSE
     l_num := bkpt_end ;
 END IF;

 RETURN l_num;
END;

--------------------------------------------------------------------------------
--
--  NAME         : prev_invoiced_amt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN  : p_var_rent_inv_id, p_period_id
--
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  10-NOV-2006  piagrawa     o Created
--------------------------------------------------------------------------------
FUNCTION prev_invoiced_amt(p_var_rent_inv_id NUMBER, p_period_id NUMBER, p_invoice_date DATE)
RETURN NUMBER IS

CURSOR inv_cur IS
  SELECT true_up_amt, actual_invoiced_amount, act_per_rent, for_per_rent, adjust_num
  FROM pn_var_rent_inv_all
  WHERE var_rent_inv_id = p_var_rent_inv_id;

CURSOR inv_actual IS
 SELECT SUM(actual_invoiced_amount) actual
 FROM pn_var_rent_inv_all
 WHERE invoice_date = p_invoice_date
 AND period_id = p_period_id
 AND var_rent_inv_id <= p_var_rent_inv_id;

CURSOR prev_inv_amt_cur(p_adjust_num NUMBER) IS
  SELECT sum(actual_invoiced_amount) prev_amt
  FROM pn_var_rent_inv_all rent_inv
  WHERE var_rent_inv_id < p_var_rent_inv_id
  AND   (true_up_amt IS NULL
     OR (true_up_amt IS NOT NULL))
  AND period_id = p_period_id;

l_prev_invoiced_amt NUMBER := 0;
l_actual_amt        NUMBER := 0;

BEGIN

  FOR rec_actual IN inv_actual LOOP
    l_actual_amt := rec_actual.actual;
  END LOOP;

  FOR rec IN inv_cur LOOP
    IF rec.true_up_amt IS NULL THEN

       IF rec.adjust_num = 0 THEN
         l_prev_invoiced_amt := l_actual_amt - rec.actual_invoiced_amount + nvl(rec.for_per_rent,0);
       ELSIF rec.adjust_num = 1 THEN
         l_prev_invoiced_amt := l_actual_amt - rec.actual_invoiced_amount - nvl(rec.for_per_rent,0);
       ELSE
         l_prev_invoiced_amt := l_actual_amt - rec.actual_invoiced_amount;
       END IF;
    ELSE

       FOR prev_inv_rec IN prev_inv_amt_cur(rec.adjust_num) LOOP
         l_prev_invoiced_amt := prev_inv_rec.prev_amt;
       END LOOP;

    END IF;

  END LOOP;

  return l_prev_invoiced_amt;

END prev_invoiced_amt;

--------------------------------------------------------------------------------
--  NAME         : last_year_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
PROCEDURE last_year_bkpt( p_vr_id           IN NUMBER
                          ,p_vr_comm_date     IN DATE
                          ,p_line_item_grp_id IN NUMBER
                          ,p_bkpt_rate        IN NUMBER
                          ,p_start_bkpt       OUT NOCOPY NUMBER
                          ,p_end_bkpt         OUT NOCOPY NUMBER)
IS

  /* get LY breakpoints */
  CURSOR ly_bkpts_c( p_vr_id            IN NUMBER
                    ,p_vr_term_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER
          ,p_bkpt_rate        IN NUMBER) IS
    SELECT
     NVL(SUM(ly_pr_grp_vol_start),0) AS bkpt_start
    ,NVL(SUM(ly_pr_grp_vol_end),0)   AS bkpt_end
    ,bkpt_rate
    FROM
    pn_var_trx_details_all
    WHERE
    trx_header_id IN
     (SELECT
      trx_header_id
      FROM
      pn_var_trx_headers_all
      WHERE
      var_rent_id = p_vr_id AND
      line_item_group_id = p_line_item_grp_id AND
      calc_prd_end_date >= (ADD_MONTHS(p_vr_term_date, -12) + 1))
    AND bkpt_rate = p_bkpt_rate
    GROUP BY
    bkpt_rate
    ORDER BY
    bkpt_start;

BEGIN
   FOR ly_bkpts_rec IN ly_bkpts_c( p_vr_id
                                  ,p_vr_comm_date
                                  ,p_line_item_grp_id
                                  ,p_bkpt_rate)
   LOOP
      p_start_bkpt := ly_bkpts_rec.bkpt_start ;
      p_end_bkpt   := ly_bkpts_rec.bkpt_end ;
   END LOOP;

END last_year_bkpt;

--------------------------------------------------------------------------------
--  NAME         : first_year_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
PROCEDURE first_year_bkpt( p_vr_id           IN NUMBER
                          ,p_vr_comm_date     IN DATE
                          ,p_line_item_grp_id IN NUMBER
                          ,p_bkpt_rate        IN NUMBER
                          ,p_start_bkpt       OUT NOCOPY NUMBER
                          ,p_end_bkpt         OUT NOCOPY NUMBER)
IS
  /* get FY breakpoints */
  CURSOR fy_bkpts_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER
          ,p_bkpt_rate        IN NUMBER) IS
    SELECT
     NVL(SUM(fy_pr_grp_vol_start),0) AS bkpt_start
    ,NVL(SUM(fy_pr_grp_vol_end),0)   AS bkpt_end
    ,bkpt_rate
    FROM
    pn_var_trx_details_all
    WHERE
    trx_header_id IN
     (SELECT
      trx_header_id
      FROM
      pn_var_trx_headers_all
      WHERE
      var_rent_id = p_vr_id AND
      line_item_group_id = p_line_item_grp_id AND
      calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1))
    AND bkpt_rate = p_bkpt_rate
    GROUP BY
    bkpt_rate
    ORDER BY
    bkpt_start;

BEGIN
   FOR fy_bkpts_rec IN fy_bkpts_c( p_vr_id
                                  ,p_vr_comm_date
                                  ,p_line_item_grp_id
                                  ,p_bkpt_rate)
   LOOP
      p_start_bkpt := fy_bkpts_rec.bkpt_start ;
      p_end_bkpt   := fy_bkpts_rec.bkpt_end ;
   END LOOP;
END first_year_bkpt;

--------------------------------------------------------------------------------
--  NAME         : ytd_start_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION ytd_start_bkpt( p_proration_rule IN VARCHAR2
                        ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER IS

  l_first_period                   VARCHAR2(1) := 'N';
  l_last_period                    VARCHAR2(1) := 'N';
  l_bkpt_start                     NUMBER := 0;
  l_bkpt_end                       NUMBER := 0;
  l_termination_date               DATE := NULL;
  l_commencement_date              DATE := NULL;

  -- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR bkpts_cur IS
     SELECT dtls.ytd_group_vol_start,
            dtls.pr_grp_blended_vol_start,
            dtls.fy_pr_grp_vol_start,
            dtls.ly_pr_grp_vol_start,
          dtls.bkpt_rate,
            hdr.var_rent_id,
            hdr.period_id,
            hdr.line_item_group_id
       FROM pn_var_trx_details_all dtls, pn_var_trx_headers_all hdr
      WHERE dtls.trx_detail_id = p_trx_detail_id
      AND   hdr.trx_header_id =  dtls.trx_header_id;

BEGIN

    FOR bkpts_rec IN bkpts_cur LOOP

      FOR first_period_rec IN first_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_first_period := 'Y';
          l_commencement_date := first_period_rec.commencement_date;
      END LOOP;

      FOR last_period_rec IN last_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_last_period := 'Y';
          l_termination_date := last_period_rec.termination_date;
      END LOOP;

      IF (p_proration_rule IN('CYP','CYNP'))
      THEN
         l_bkpt_start  :=   nvl(bkpts_rec.ytd_group_vol_start,bkpts_rec.pr_grp_blended_vol_start);

      ELSIF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.first_year_bkpt(bkpts_rec.var_rent_id,
                                              l_commencement_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.last_year_bkpt( bkpts_rec.var_rent_id,
                                              l_termination_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSE
         l_bkpt_start  :=   bkpts_rec.ytd_group_vol_start;

      END IF;

    END LOOP;

    RETURN l_bkpt_start;

END ytd_start_bkpt;

--------------------------------------------------------------------------------
--  NAME         : ytd_end_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION ytd_end_bkpt( p_proration_rule IN VARCHAR2
                        ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER IS

  l_first_period                   VARCHAR2(1) := 'N';
  l_last_period                    VARCHAR2(1) := 'N';
  l_bkpt_start                     NUMBER := 0;
  l_bkpt_end                       NUMBER := 0;
  l_termination_date               DATE := NULL;
  l_commencement_date              DATE := NULL;

  -- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR bkpts_cur IS
     SELECT dtls.ytd_group_vol_start,
            dtls.pr_grp_blended_vol_start,
            dtls.fy_pr_grp_vol_start,
            dtls.ly_pr_grp_vol_start,
            dtls.ytd_group_vol_end,
            dtls.pr_grp_blended_vol_end,
            dtls.fy_pr_grp_vol_end,
            dtls.ly_pr_grp_vol_end,
       dtls.bkpt_rate,
            hdr.var_rent_id,
            hdr.period_id,
       hdr.line_item_group_id
       FROM pn_var_trx_details_all dtls, pn_var_trx_headers_all hdr
      WHERE dtls.trx_detail_id = p_trx_detail_id
      AND   hdr.trx_header_id =  dtls.trx_header_id;

BEGIN

    FOR bkpts_rec IN bkpts_cur LOOP

      FOR first_period_rec IN first_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_first_period := 'Y';
          l_commencement_date := first_period_rec.commencement_date;
      END LOOP;

      FOR last_period_rec IN last_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_last_period := 'Y';
          l_termination_date := last_period_rec.termination_date;
      END LOOP;

      IF (p_proration_rule IN('CYP','CYNP'))
      THEN
         l_bkpt_start  :=   nvl(bkpts_rec.ytd_group_vol_start,bkpts_rec.pr_grp_blended_vol_start);
         l_bkpt_end    :=   nvl(bkpts_rec.ytd_group_vol_end,bkpts_rec.pr_grp_blended_vol_end);

      ELSIF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.first_year_bkpt(bkpts_rec.var_rent_id,
                                              l_commencement_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.last_year_bkpt( bkpts_rec.var_rent_id,
                                              l_termination_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSE
         l_bkpt_start  :=   bkpts_rec.ytd_group_vol_start;
         l_bkpt_end    :=   bkpts_rec.ytd_group_vol_end;

      END IF;

      l_bkpt_end := pn_var_rent_calc_pkg.end_breakpoint(l_bkpt_start, l_bkpt_end);

    END LOOP;

    RETURN l_bkpt_end;

END ytd_end_bkpt;

--------------------------------------------------------------------------------
--  NAME         : overage_cal
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  Ram Kumar     o Created
--------------------------------------------------------------------------------
FUNCTION overage_cal(p_proration_rule IN VARCHAR2,
                     p_calculation_method IN VARCHAR2,
                     detail_id IN NUMBER) RETURN NUMBER IS

l_group_sales                    NUMBER := 0;
l_group_deductions               NUMBER := 0;
l_bkpt_start                     NUMBER := 0;
l_bkpt_end                       NUMBER := 0;
overage                          NUMBER :=  0;
l_applicable_sales               NUMBER := 0;
l_first_period                   VARCHAR2(1) := 'N';
l_last_period                    VARCHAR2(1) := 'N';
l_termination_date               DATE := NULL;
l_commencement_date              DATE := NULL;

/* This cursor fetches applicable sales for cumulative */
CURSOR total_sales_C (p_trx_header_id NUMBER) IS
  SELECT (NVL(ytd_sales, 0) - NVL(ytd_deductions, 0)) applicable_sales
  FROM  pn_var_trx_headers_all
  WHERE trx_header_id = p_trx_header_id;

  -- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

CURSOR overage_cur IS
  SELECT  hdr.trx_header_id,
          hdr.calc_prd_start_date,
          hdr.period_id,
          hdr.var_rent_id,
          hdr.line_item_group_id,
          dtls.bkpt_rate,
          dtls.prorated_grp_vol_start,
          dtls.prorated_grp_vol_end,
          dtls.ytd_group_vol_start,
          dtls.ytd_group_vol_end,
          dtls.blended_period_vol_start,
          dtls.blended_period_vol_end,
          dtls.FY_PR_GRP_VOL_START,
          dtls.FY_PR_GRP_VOL_END,
          dtls.LY_PR_GRP_VOL_START,
          dtls.LY_PR_GRP_VOL_END,
          dtls.PR_GRP_BLENDED_VOL_START,
          dtls.PR_GRP_BLENDED_VOL_END,
          hdr.prorated_group_sales,
          hdr.ytd_sales,
          hdr.prorated_group_deductions,
          hdr.ytd_deductions
  FROM    pn_var_trx_headers_all hdr,
          pn_var_trx_details_all dtls
  WHERE   hdr.trx_header_id=dtls.trx_header_id
  AND dtls.trx_detail_id = detail_id;

BEGIN

  FOR overage_rec IN overage_cur LOOP

    FOR first_period_rec IN first_period_cur (overage_rec.var_rent_id, overage_rec.period_id) LOOP
        l_first_period := 'Y';
        l_commencement_date := first_period_rec.commencement_date;
    END LOOP;

    FOR last_period_rec IN last_period_cur (overage_rec.var_rent_id, overage_rec.period_id) LOOP
        l_last_period := 'Y';
        l_termination_date := last_period_rec.termination_date;
    END LOOP;

    IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
    THEN

       pn_var_rent_calc_pkg.first_year_bkpt(overage_rec.var_rent_id, l_commencement_date,
                                            overage_rec.line_item_group_id, overage_rec.bkpt_rate,
                                            l_bkpt_start, l_bkpt_end);

       l_applicable_sales := pn_var_rent_calc_pkg.first_year_sales( overage_rec.var_rent_id
                                                                  ,l_commencement_date
                                                                  ,overage_rec.line_item_group_id);

    ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
    THEN

       pn_var_rent_calc_pkg.last_year_bkpt( overage_rec.var_rent_id, l_termination_date,
                                            overage_rec.line_item_group_id, overage_rec.bkpt_rate,
                                            l_bkpt_start, l_bkpt_end);

       l_applicable_sales := pn_var_rent_calc_pkg.last_year_sales( overage_rec.var_rent_id
                                                                  ,l_termination_date
                                                                  ,overage_rec.line_item_group_id);
    ELSE
       FOR rec IN total_sales_C(overage_rec.trx_header_id)  LOOP
         l_applicable_sales := rec.applicable_sales;
       END LOOP;

       IF  p_calculation_method IN ('N', 'T')
       THEN
          l_applicable_sales := (overage_rec.prorated_group_sales - NVL(overage_rec.prorated_group_deductions,0));

       ELSIF p_calculation_method IN ('Y', 'C')
       THEN
          l_applicable_sales := (overage_rec.ytd_sales - NVL(overage_rec.ytd_deductions,0));

       END IF;

       IF  p_calculation_method IN ('N', 'T')
       THEN
          IF p_proration_rule IN ('CYNP') THEN

            l_bkpt_start := NVL(overage_rec.pr_grp_blended_vol_start
                                ,overage_rec.prorated_grp_vol_start);
            l_bkpt_end   := NVL(overage_rec.pr_grp_blended_vol_end
                                ,overage_rec.prorated_grp_vol_end);

          ELSE

            l_bkpt_start := overage_rec.prorated_grp_vol_start;
            l_bkpt_end   := overage_rec.prorated_grp_vol_end;

          END IF;

       ELSIF p_calculation_method IN ('Y')
       THEN

         l_bkpt_start  :=   overage_rec.ytd_group_vol_start;
         l_bkpt_end    :=   overage_rec.ytd_group_vol_end;

       ELSIF p_calculation_method IN ('C')
       THEN

          IF p_proration_rule IN ('NP') THEN

            l_bkpt_start := overage_rec.prorated_grp_vol_start;
            l_bkpt_end   := overage_rec.prorated_grp_vol_end;

          ELSE

            l_bkpt_start := overage_rec.blended_period_vol_start;
            l_bkpt_end   := overage_rec.blended_period_vol_end;

          END IF;

       END IF;

    END IF;

    IF(l_bkpt_end = 0) THEN
       overage := greatest(l_applicable_sales - l_bkpt_start,0);
    ELSE
       IF((l_applicable_sales >= l_bkpt_start) AND (l_applicable_sales <= l_bkpt_end)) THEN
           overage :=  l_applicable_sales - l_bkpt_start;
       ELSIF(l_applicable_sales > l_bkpt_end) THEN
           overage := l_bkpt_end - l_bkpt_start;
       ELSIF(l_applicable_sales < l_bkpt_start) THEN
           overage := 0;
       END IF;
    END IF;

  END LOOP;

  return overage;

  EXCEPTION
  WHEN OTHERS THEN RAISE;
END overage_cal;

--------------------------------------------------------------------------------
--  NAME         : first_year_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION first_year_sales( p_vr_id            IN NUMBER
                           ,p_vr_comm_date     IN DATE
                           ,p_line_item_grp_id IN NUMBER)
RETURN NUMBER IS

  /* get FY sales */
  CURSOR fy_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(fy_proration_sales - NVL(fy_proration_deductions,0) ),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1) ;

  l_sales NUMBER := 0;

BEGIN
   FOR fy_sales_rec IN fy_sales_c( p_vr_id
                                  ,p_vr_comm_date
                                  ,p_line_item_grp_id)
   LOOP
      l_sales := fy_sales_rec.sales ;
   END LOOP;

   RETURN l_sales;

END first_year_sales;

--------------------------------------------------------------------------------
--  NAME         : last_year_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION last_year_sales( p_vr_id            IN NUMBER
                           ,p_vr_comm_date     IN DATE
                           ,p_line_item_grp_id IN NUMBER)
RETURN NUMBER IS

  /* get LY sales */
  CURSOR ly_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_term_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(ly_proration_sales - NVL(ly_proration_deductions,0) ),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_end_date >= (ADD_MONTHS(p_vr_term_date, -12) + 1);

  l_sales NUMBER := 0;

BEGIN
   FOR ly_sales_rec IN ly_sales_c( p_vr_id
                                  ,p_vr_comm_date
                                  ,p_line_item_grp_id)
   LOOP
      l_sales := ly_sales_rec.sales ;
   END LOOP;

   RETURN l_sales;

END last_year_sales;


--------------------------------------------------------------------------------
--  NAME         : group_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION group_sales( p_proration_rule   IN VARCHAR2,
                                  p_trx_detail_id    IN NUMBER,
                                  p_calculation_type IN VARCHAR2)
RETURN NUMBER IS

-- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

  /* get FY sales */
  CURSOR fy_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(fy_proration_sales),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1) ;

  /* get LY sales */
  CURSOR ly_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_term_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(ly_proration_sales),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_end_date >= (ADD_MONTHS(p_vr_term_date, -12) + 1);

   -- Get the details of
   CURSOR sales_cur IS
     SELECT hdr.ytd_sales,
            hdr.reporting_group_sales,
            hdr.prorated_group_sales,
            hdr.line_item_group_id,
                  hdr.period_id,
                  hdr.var_rent_id
      FROM pn_var_trx_headers_all hdr,
           pn_var_trx_details_all dtls
      WHERE hdr.trx_header_id = dtls.trx_header_id
      AND   dtls.trx_detail_id  = p_trx_detail_id;

l_sales                          NUMBER := 0;
l_first_period                   VARCHAR2(1) := 'N';
l_last_period                    VARCHAR2(1) := 'N';
l_termination_date               DATE := NULL;
l_commencement_date              DATE := NULL;
l_applicable_sales               NUMBER := 0;

BEGIN

 FOR sales_rec IN sales_cur LOOP

    FOR first_period_rec IN first_period_cur (sales_rec.var_rent_id, sales_rec.period_id) LOOP
        l_first_period := 'Y';
        l_commencement_date := first_period_rec.commencement_date;
    END LOOP;

    FOR last_period_rec IN last_period_cur (sales_rec.var_rent_id, sales_rec.period_id) LOOP
        l_last_period := 'Y';
        l_termination_date := last_period_rec.termination_date;
    END LOOP;

    IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
    THEN

      FOR fy_sales_rec IN fy_sales_c(  sales_rec.var_rent_id
                                     , l_commencement_date
                                     , sales_rec.line_item_group_id)
      LOOP
        l_applicable_sales := fy_sales_rec.sales ;
      END LOOP;

    ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
    THEN

      FOR ly_sales_rec IN ly_sales_c( sales_rec.var_rent_id
                                     ,l_termination_date
                                     ,sales_rec.line_item_group_id)
      LOOP
        l_applicable_sales := ly_sales_rec.sales ;
      END LOOP;

    ELSE

      l_applicable_sales := sales_rec.prorated_group_sales;
      /* IF p_calculation_type = 'Y' THEN
        l_applicable_sales := sales_rec.ytd_sales;
      ELSIF p_calculation_type = 'T' THEN
        l_applicable_sales := sales_rec.prorated_group_sales;
      ELSIF p_calculation_type = 'C' THEN
        l_applicable_sales := sales_rec.reporting_group_sales;
      END IF; */

    END IF;

  END LOOP;

  return NVL(l_applicable_sales, 0);

END group_sales;

--------------------------------------------------------------------------------
--  NAME         : net_volume
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION net_volume( p_proration_rule   IN VARCHAR2,
           p_trx_detail_id    IN NUMBER,
           p_calculation_type IN VARCHAR2)
RETURN NUMBER IS

-- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR sales_cur IS
     SELECT hdr.ytd_sales,
            hdr.reporting_group_sales,
            hdr.prorated_group_sales,
            hdr.line_item_group_id,
            hdr.prorated_group_deductions,
            hdr.reporting_group_deductions,
            hdr.ytd_deductions,
            hdr.period_id,
            hdr.var_rent_id
      FROM pn_var_trx_headers_all hdr,
           pn_var_trx_details_all dtls
      WHERE hdr.trx_header_id = dtls.trx_header_id
      AND   dtls.trx_detail_id  = p_trx_detail_id;

l_sales                          NUMBER := 0;
l_first_period                   VARCHAR2(1) := 'N';
l_last_period                    VARCHAR2(1) := 'N';
l_termination_date               DATE := NULL;
l_commencement_date              DATE := NULL;
l_applicable_sales               NUMBER := 0;

BEGIN

 FOR sales_rec IN sales_cur LOOP

    FOR first_period_rec IN first_period_cur (sales_rec.var_rent_id, sales_rec.period_id) LOOP
        l_first_period := 'Y';
        l_commencement_date := first_period_rec.commencement_date;
    END LOOP;

    FOR last_period_rec IN last_period_cur (sales_rec.var_rent_id, sales_rec.period_id) LOOP
        l_last_period := 'Y';
        l_termination_date := last_period_rec.termination_date;
    END LOOP;

    IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
    THEN

        l_applicable_sales := pn_var_rent_calc_pkg.first_year_sales( sales_rec.var_rent_id
                                                                    ,l_commencement_date
                                                                    ,sales_rec.line_item_group_id);

    ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
    THEN

         l_applicable_sales := pn_var_rent_calc_pkg.last_year_sales( sales_rec.var_rent_id
                                                                    ,l_termination_date
                                                                    ,sales_rec.line_item_group_id);

    ELSE

      l_applicable_sales :=  NVL(sales_rec.prorated_group_sales, 0)
                             - NVL(sales_rec.prorated_group_deductions, 0);
      /* IF p_calculation_type = 'Y' THEN
        l_applicable_sales :=  NVL(sales_rec.ytd_sales, 0)
                             - NVL(sales_rec.ytd_deductions, 0);
      ELSIF p_calculation_type = 'T' THEN
        l_applicable_sales :=  NVL(sales_rec.prorated_group_sales, 0)
                             - NVL(sales_rec.prorated_group_deductions, 0);
      ELSIF p_calculation_type = 'C' THEN
        l_applicable_sales :=  NVL(sales_rec.reporting_group_sales, 0)
                             - NVL(sales_rec.reporting_group_deductions, 0);
      END IF; */

    END IF;

  END LOOP;

  return l_applicable_sales;

END net_volume;

--------------------------------------------------------------------------------
--  NAME         : group_deductions
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION group_deductions( p_proration_rule   IN VARCHAR2,
                                  p_trx_detail_id    IN NUMBER,
                                  p_calculation_type IN VARCHAR2)
RETURN NUMBER IS

-- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

  /* get FY sales */
  CURSOR fy_deductions_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(fy_proration_deductions),0) AS deductions
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1) ;

  /* get LY sales */
  CURSOR ly_deductions_c( p_vr_id            IN NUMBER
                    ,p_vr_term_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(ly_proration_deductions),0) AS deductions
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_end_date >= (ADD_MONTHS(p_vr_term_date, -12) + 1);

   -- Get the details of
   CURSOR deductions_cur IS
     SELECT hdr.prorated_group_deductions,
            hdr.reporting_group_deductions,
            hdr.ytd_deductions,
            hdr.line_item_group_id,
                  hdr.period_id,
                  hdr.var_rent_id
      FROM pn_var_trx_headers_all hdr,
           pn_var_trx_details_all dtls
      WHERE hdr.trx_header_id = dtls.trx_header_id
      AND   dtls.trx_detail_id  = p_trx_detail_id;

l_first_period                   VARCHAR2(1) := 'N';
l_last_period                    VARCHAR2(1) := 'N';
l_termination_date               DATE := NULL;
l_commencement_date              DATE := NULL;
l_applicable_deductions          NUMBER := 0;

BEGIN

 FOR deductions_rec IN deductions_cur LOOP

    FOR first_period_rec IN first_period_cur (deductions_rec.var_rent_id, deductions_rec.period_id) LOOP
        l_first_period := 'Y';
        l_commencement_date := first_period_rec.commencement_date;
    END LOOP;

    FOR last_period_rec IN last_period_cur (deductions_rec.var_rent_id, deductions_rec.period_id) LOOP
        l_last_period := 'Y';
        l_termination_date := last_period_rec.termination_date;
    END LOOP;

    IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
    THEN

      FOR fy_deductions_rec IN fy_deductions_c(  deductions_rec.var_rent_id
                                     , l_commencement_date
                                     , deductions_rec.line_item_group_id)
      LOOP
        l_applicable_deductions := fy_deductions_rec.deductions ;
      END LOOP;

    ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
    THEN

      FOR ly_deductions_rec IN ly_deductions_c( deductions_rec.var_rent_id
                                     ,l_termination_date
                                     ,deductions_rec.line_item_group_id)
      LOOP
        l_applicable_deductions := ly_deductions_rec.deductions ;
      END LOOP;

    ELSE

      l_applicable_deductions := deductions_rec.prorated_group_deductions;
      /* IF p_calculation_type = 'Y' THEN
        l_applicable_deductions := deductions_rec.ytd_deductions;
      ELSIF p_calculation_type = 'T' THEN
        l_applicable_deductions := deductions_rec.prorated_group_deductions;
      ELSIF p_calculation_type = 'C' THEN
        l_applicable_deductions := deductions_rec.reporting_group_deductions;
      END IF; */

    END IF;

  END LOOP;

  return NVL(l_applicable_deductions, 0);

END group_deductions;

--------------------------------------------------------------------------------
--  NAME         : net_volume
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION cumulative_volume( p_proration_rule   IN VARCHAR2,
           p_trx_detail_id    IN NUMBER,
           p_calculation_type IN VARCHAR2)
RETURN NUMBER IS

-- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR sales_cur IS
     SELECT hdr.ytd_sales,
            hdr.ytd_deductions,
            hdr.line_item_group_id,
            hdr.period_id,
            hdr.var_rent_id,
            hdr.trx_header_id,
            hdr.calc_prd_start_date,
            hdr.line_item_id
      FROM pn_var_trx_headers_all hdr,
           pn_var_trx_details_all dtls
      WHERE hdr.trx_header_id = dtls.trx_header_id
      AND   dtls.trx_detail_id  = p_trx_detail_id;

   -- Get the details of
   /*CURSOR cum_sales_cur (p_period_id NUMBER,
                         p_line_item_id NUMBER,
                         p_calc_period_start_date DATE) IS
     SELECT NVL(SUM(hdr.prorated_group_sales), 0) - NVL(SUM(hdr.prorated_group_deductions), 0) sales
     FROM pn_var_trx_headers_all hdr
     WHERE hdr.period_id = p_period_id
     AND   hdr.line_item_id = p_line_item_id
     AND   hdr.calc_prd_start_date <= p_calc_period_start_date
     ORDER BY calc_prd_start_date;*/


l_sales                          NUMBER := 0;
l_first_period                   VARCHAR2(1) := 'N';
l_last_period                    VARCHAR2(1) := 'N';
l_termination_date               DATE := NULL;
l_commencement_date              DATE := NULL;
l_applicable_sales               NUMBER := 0;

BEGIN

 FOR sales_rec IN sales_cur LOOP

    FOR first_period_rec IN first_period_cur (sales_rec.var_rent_id, sales_rec.period_id) LOOP
        l_first_period := 'Y';
        l_commencement_date := first_period_rec.commencement_date;
    END LOOP;

    FOR last_period_rec IN last_period_cur (sales_rec.var_rent_id, sales_rec.period_id) LOOP
        l_last_period := 'Y';
        l_termination_date := last_period_rec.termination_date;
    END LOOP;

    IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
    THEN

        l_applicable_sales := pn_var_rent_calc_pkg.first_year_sales( sales_rec.var_rent_id
                                                                    ,l_commencement_date
                                                                    ,sales_rec.line_item_group_id);

    ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
    THEN

         l_applicable_sales := pn_var_rent_calc_pkg.last_year_sales( sales_rec.var_rent_id
                                                                    ,l_termination_date
                                                                    ,sales_rec.line_item_group_id);

    ELSE
       /*FOR cum_sales_rec IN cum_sales_cur(sales_rec.period_id,
                                          sales_rec.line_item_id,
                                          sales_rec.calc_prd_start_date)
       LOOP*/
       l_applicable_sales := NVL(sales_rec.ytd_sales, 0) - NVL(sales_rec.ytd_deductions, 0);
          /*l_applicable_sales := cum_sales_rec.sales;
       END LOOP;*/

    END IF;

  END LOOP;

  return l_applicable_sales;

END cumulative_volume;

--------------------------------------------------------------------------------
--  NAME         : ytd_start_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION annual_start_bkpt( p_proration_rule IN VARCHAR2
                           ,p_cumulative_vol IN VARCHAR2
                           ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER IS

  l_first_period                   VARCHAR2(1) := 'N';
  l_last_period                    VARCHAR2(1) := 'N';
  l_bkpt_start                     NUMBER := 0;
  l_bkpt_end                       NUMBER := 0;
  l_termination_date               DATE := NULL;
  l_commencement_date              DATE := NULL;
  l_annual_bkpt_start              NUMBER;
  l_bkpt_vol_start                 NUMBER;
  l_bkpt_vol_end                   NUMBER;

  -- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR bkpts_cur IS
     SELECT dtls.prorated_grp_vol_start,
            dtls.pr_grp_blended_vol_start,
            dtls.blended_period_vol_start,
            dtls.bkpt_rate,
            hdr.var_rent_id,
            hdr.period_id,
            hdr.line_item_group_id
       FROM pn_var_trx_details_all dtls, pn_var_trx_headers_all hdr
      WHERE dtls.trx_detail_id = p_trx_detail_id
      AND   hdr.trx_header_id =  dtls.trx_header_id;

    CURSOR blended_prd_csr (p_period_id IN NUMBER, p_bkpt_rate IN NUMBER) IS
     SELECT sum(dtls.prorated_grp_vol_start)  bkpt_start
     FROM pn_var_trx_details_all dtls,
          pn_var_trx_headers_all hdr
     WHERE hdr.trx_header_id = dtls.trx_header_id
     AND hdr.period_id = p_period_id
     AND dtls.bkpt_rate = p_bkpt_rate;

BEGIN

    FOR bkpts_rec IN bkpts_cur LOOP

      FOR blended_prd_rec IN blended_prd_csr(bkpts_rec.period_id, bkpts_rec.bkpt_rate) LOOP
          l_annual_bkpt_start := blended_prd_rec.bkpt_start;
      END LOOP;

      FOR first_period_rec IN first_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_first_period := 'Y';
          l_commencement_date := first_period_rec.commencement_date;
      END LOOP;

      FOR last_period_rec IN last_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_last_period := 'Y';
          l_termination_date := last_period_rec.termination_date;
      END LOOP;

      IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.first_year_bkpt(bkpts_rec.var_rent_id,
                                              l_commencement_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.last_year_bkpt( bkpts_rec.var_rent_id,
                                              l_termination_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSE

         IF (p_cumulative_vol = 'T')
         THEN
            IF p_proration_rule IN ('CYP','CYNP')
            THEN

               true_up_bkpt ( bkpts_rec.period_id,
                              bkpts_rec.bkpt_rate,
                              l_bkpt_vol_start,
                              l_bkpt_vol_end);
               l_bkpt_start := NVL(l_bkpt_vol_start,l_annual_bkpt_start);

            ELSE
               l_bkpt_start := l_annual_bkpt_start;
            END IF;

         ELSIF (p_cumulative_vol = 'C')
         THEN

            IF p_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_NP
            THEN
               l_bkpt_start := bkpts_rec.prorated_grp_vol_start;
            ELSE
               l_bkpt_start := bkpts_rec.blended_period_vol_start;
            END IF;

         END IF;

      END IF;

    END LOOP;

    RETURN NVL(l_bkpt_start, 0);

END annual_start_bkpt;

--------------------------------------------------------------------------------
--  NAME         : annual_end_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION annual_end_bkpt( p_proration_rule IN VARCHAR2
                         ,p_cumulative_vol IN VARCHAR2
                         ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER IS

  l_first_period                   VARCHAR2(1) := 'N';
  l_last_period                    VARCHAR2(1) := 'N';
  l_bkpt_start                     NUMBER := 0;
  l_bkpt_end                       NUMBER := 0;
  l_termination_date               DATE := NULL;
  l_commencement_date              DATE := NULL;
  l_annual_bkpt_start              NUMBER;
  l_annual_bkpt_end                NUMBER;
  l_bkpt_vol_start                 NUMBER;
  l_bkpt_vol_end                   NUMBER;


  -- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR bkpts_cur IS
     SELECT dtls.prorated_grp_vol_start,
            dtls.pr_grp_blended_vol_start,
            dtls.blended_period_vol_start,
            dtls.prorated_grp_vol_end,
            dtls.pr_grp_blended_vol_end,
            dtls.blended_period_vol_end,
            dtls.bkpt_rate,
            hdr.var_rent_id,
            hdr.period_id,
            hdr.line_item_group_id
       FROM pn_var_trx_details_all dtls, pn_var_trx_headers_all hdr
       WHERE dtls.trx_detail_id = p_trx_detail_id
       AND   hdr.trx_header_id =  dtls.trx_header_id;

    CURSOR blended_prd_csr (p_period_id IN NUMBER, p_bkpt_rate IN NUMBER) IS
     SELECT sum(prorated_grp_vol_start)  bkpt_start,
            sum(prorated_grp_vol_end)  bkpt_end
     FROM pn_var_trx_details_all dtls,
          pn_var_trx_headers_all hdr
     WHERE hdr.trx_header_id = dtls.trx_header_id
     AND hdr.period_id = p_period_id
     AND dtls.bkpt_rate = p_bkpt_rate;

BEGIN

    FOR bkpts_rec IN bkpts_cur LOOP
      FOR blended_prd_rec IN blended_prd_csr(bkpts_rec.period_id,bkpts_rec.bkpt_rate) LOOP
          l_annual_bkpt_start := blended_prd_rec.bkpt_start;
          l_annual_bkpt_end := blended_prd_rec.bkpt_end;
      END LOOP;

      FOR first_period_rec IN first_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_first_period := 'Y';
          l_commencement_date := first_period_rec.commencement_date;
      END LOOP;

      FOR last_period_rec IN last_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_last_period := 'Y';
          l_termination_date := last_period_rec.termination_date;
      END LOOP;

      IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.first_year_bkpt(bkpts_rec.var_rent_id,
                                              l_commencement_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.last_year_bkpt( bkpts_rec.var_rent_id,
                                              l_termination_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSE
         IF (p_cumulative_vol = 'T')
         THEN
            IF p_proration_rule IN ('CYP','CYNP')
            THEN

               true_up_bkpt ( bkpts_rec.period_id,
                              bkpts_rec.bkpt_rate,
                              l_bkpt_vol_start,
                              l_bkpt_vol_end);

               l_bkpt_start := NVL(l_bkpt_vol_start,l_annual_bkpt_start);
               l_bkpt_end   := NVL(l_bkpt_vol_end,l_annual_bkpt_end);

            ELSE
               l_bkpt_start := l_annual_bkpt_start;
               l_bkpt_end := l_annual_bkpt_end;
            END IF;

         ELSIF (p_cumulative_vol = 'C')
         THEN

            IF p_proration_rule = pn_var_rent_calc_pkg.G_PRORUL_NP
            THEN
               l_bkpt_start := bkpts_rec.prorated_grp_vol_start;
               l_bkpt_end := bkpts_rec.prorated_grp_vol_end;
            ELSE
               l_bkpt_start := bkpts_rec.blended_period_vol_start;
               l_bkpt_end   := bkpts_rec.blended_period_vol_end;
            END IF;

         END IF;
      END IF;

      l_bkpt_end := pn_var_rent_calc_pkg.end_breakpoint(l_bkpt_start, l_bkpt_end);

    END LOOP;

    RETURN l_bkpt_end;

END annual_end_bkpt;

--------------------------------------------------------------------------------
--  NAME         : prorated_start_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION prorated_start_bkpt( p_proration_rule IN VARCHAR2
                             ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER IS

  l_first_period                   VARCHAR2(1) := 'N';
  l_last_period                    VARCHAR2(1) := 'N';
  l_bkpt_start                     NUMBER := 0;
  l_bkpt_end                       NUMBER := 0;
  l_termination_date               DATE := NULL;
  l_commencement_date              DATE := NULL;

  -- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR bkpts_cur IS
     SELECT dtls.prorated_grp_vol_start,
            dtls.pr_grp_blended_vol_start,
            dtls.bkpt_rate,
            bkpts.group_bkpt_vol_start,
            hdr.var_rent_id,
            hdr.period_id,
            hdr.line_item_group_id
       FROM pn_var_trx_details_all dtls, pn_var_trx_headers_all hdr,
            pn_var_bkpts_det_all bkpts
      WHERE dtls.trx_detail_id = p_trx_detail_id
      AND   hdr.trx_header_id =  dtls.trx_header_id
      AND   bkpts.bkpt_detail_id = dtls.bkpt_detail_id;

BEGIN

    FOR bkpts_rec IN bkpts_cur LOOP

      FOR first_period_rec IN first_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_first_period := 'Y';
          l_commencement_date := first_period_rec.commencement_date;
      END LOOP;

      FOR last_period_rec IN last_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_last_period := 'Y';
          l_termination_date := last_period_rec.termination_date;
      END LOOP;

      IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.first_year_bkpt(bkpts_rec.var_rent_id,
                                              l_commencement_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.last_year_bkpt( bkpts_rec.var_rent_id,
                                              l_termination_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSIF p_proration_rule IN('CYNP', 'CYP')
      THEN
         l_bkpt_start := NVL(bkpts_rec.pr_grp_blended_vol_start, bkpts_rec.prorated_grp_vol_start);

      ELSIF p_proration_rule IN('NP')
      THEN
         l_bkpt_start := bkpts_rec.group_bkpt_vol_start;
      ELSE
         l_bkpt_start := bkpts_rec.prorated_grp_vol_start;

      END IF;

    END LOOP;

    RETURN NVL(l_bkpt_start, 0);

END prorated_start_bkpt;

--------------------------------------------------------------------------------
--  NAME         : prorated_end_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION prorated_end_bkpt( p_proration_rule IN VARCHAR2
                           ,p_trx_detail_id  IN NUMBER)
RETURN NUMBER IS

  l_first_period                   VARCHAR2(1) := 'N';
  l_last_period                    VARCHAR2(1) := 'N';
  l_bkpt_start                     NUMBER := 0;
  l_bkpt_end                       NUMBER := 0;
  l_termination_date               DATE := NULL;
  l_commencement_date              DATE := NULL;

  -- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;


  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR bkpts_cur IS
     SELECT dtls.prorated_grp_vol_start,
            dtls.prorated_grp_vol_end,
            dtls.pr_grp_blended_vol_start,
            dtls.pr_grp_blended_vol_end,
            dtls.bkpt_rate,
            bkpts.group_bkpt_vol_start,
            bkpts.group_bkpt_vol_end,
            hdr.var_rent_id,
            hdr.period_id,
            hdr.line_item_group_id
       FROM pn_var_trx_details_all dtls, pn_var_trx_headers_all hdr,
            pn_var_bkpts_det_all bkpts
       WHERE dtls.trx_detail_id = p_trx_detail_id
       AND   hdr.trx_header_id =  dtls.trx_header_id
       AND   bkpts.bkpt_detail_id = dtls.bkpt_detail_id;

BEGIN

    FOR bkpts_rec IN bkpts_cur LOOP

      FOR first_period_rec IN first_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_first_period := 'Y';
          l_commencement_date := first_period_rec.commencement_date;
      END LOOP;

      FOR last_period_rec IN last_period_cur (bkpts_rec.var_rent_id, bkpts_rec.period_id) LOOP
          l_last_period := 'Y';
          l_termination_date := last_period_rec.termination_date;
      END LOOP;

      IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.first_year_bkpt(bkpts_rec.var_rent_id,
                                              l_commencement_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
      THEN

         pn_var_rent_calc_pkg.last_year_bkpt( bkpts_rec.var_rent_id,
                                              l_termination_date,
                                              bkpts_rec.line_item_group_id,
                                              bkpts_rec.bkpt_rate,
                                              l_bkpt_start,
                                              l_bkpt_end);

      ELSIF p_proration_rule IN('CYNP', 'CYP')
      THEN
         l_bkpt_start := NVL(bkpts_rec.pr_grp_blended_vol_start, bkpts_rec.prorated_grp_vol_start);
         l_bkpt_end   := NVL(bkpts_rec.pr_grp_blended_vol_end, bkpts_rec.prorated_grp_vol_end);

      ELSIF p_proration_rule IN('NP')
      THEN
         l_bkpt_start := bkpts_rec.group_bkpt_vol_start;
         l_bkpt_end := bkpts_rec.group_bkpt_vol_end;
      ELSE
         l_bkpt_start := bkpts_rec.prorated_grp_vol_start;
         l_bkpt_end := bkpts_rec.prorated_grp_vol_end;
      END IF;

      l_bkpt_end := pn_var_rent_calc_pkg.end_breakpoint(l_bkpt_start, l_bkpt_end);

    END LOOP;

    RETURN l_bkpt_end;

END prorated_end_bkpt;

--------------------------------------------------------------------------------
--  NAME         : current_gross_vr
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION current_gross_vr( p_proration_rule   IN VARCHAR2,
                           p_trx_detail_id    IN NUMBER)
RETURN NUMBER IS

-- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;

  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR rent_cur IS
     SELECT hdr.percent_rent_due,
            hdr.first_yr_rent,
            hdr.period_id,
            hdr.var_rent_id
      FROM pn_var_trx_headers_all hdr,
           pn_var_trx_details_all dtls
      WHERE hdr.trx_header_id = dtls.trx_header_id
      AND   dtls.trx_detail_id  = p_trx_detail_id;

   -- Get the details of
   CURSOR first_yr_rent (p_var_rent_id NUMBER) IS
     SELECT SUM(first_yr_rent) first_yr_rent
     FROM pn_var_trx_headers_all
     WHERE var_rent_id = p_var_rent_id;

   -- Get the details of
   CURSOR last_yr_rent (p_period_id NUMBER) IS
     SELECT (SUM(NVL(prorated_rent_due, 0)) - SUM(NVL(first_yr_rent, 0))) last_yr_rent
     FROM pn_var_trx_headers_all
     WHERE period_id = p_period_id;



l_rent                           NUMBER := 0;
l_first_period                   VARCHAR2(1) := 'N';
l_last_period                    VARCHAR2(1) := 'N';

BEGIN

 FOR rent_rec IN rent_cur LOOP

    FOR first_period_rec IN first_period_cur (rent_rec.var_rent_id, rent_rec.period_id) LOOP
        l_first_period := 'Y';
    END LOOP;

    FOR last_period_rec IN last_period_cur (rent_rec.var_rent_id, rent_rec.period_id) LOOP
        l_last_period := 'Y';
    END LOOP;

    IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
    THEN

      FOR first_yr_rec IN first_yr_rent(rent_rec.var_rent_id) LOOP
              l_rent := NVL(first_yr_rec.first_yr_rent, 0);
      END LOOP;

    ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
    THEN

      FOR last_yr_rec IN last_yr_rent(rent_rec.period_id) LOOP
              l_rent := NVL(last_yr_rec.last_yr_rent, 0);
      END LOOP;

    ELSE

        l_rent := NVL(rent_rec.percent_rent_due, 0);

    END IF;

  END LOOP;

  return l_rent;

END current_gross_vr;

--------------------------------------------------------------------------------
--  NAME         : cumulative_gross_vr
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION cumulative_gross_vr( p_proration_rule   IN VARCHAR2,
                              p_trx_detail_id    IN NUMBER)
RETURN NUMBER IS

-- Get the details of
  CURSOR first_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.commencement_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.start_date = pvr.commencement_date;

  -- Get the details of
  CURSOR last_period_cur (p_var_rent_id NUMBER, p_period_id NUMBER) IS
    SELECT pvp.period_id, pvr.termination_date
      FROM pn_var_periods_all pvp, pn_var_rents_all pvr
     WHERE pvr.var_rent_id = p_var_rent_id
     AND   pvp.period_id = p_period_id
     AND   pvp.partial_period = 'Y'
     AND   pvp.end_date   = pvr.termination_date;

   -- Get the details of
   CURSOR rent_cur IS
     SELECT hdr.ytd_percent_rent,
            hdr.first_yr_rent,
            hdr.period_id,
            hdr.var_rent_id
      FROM pn_var_trx_headers_all hdr,
           pn_var_trx_details_all dtls
      WHERE hdr.trx_header_id = dtls.trx_header_id
      AND   dtls.trx_detail_id  = p_trx_detail_id;

   -- Get the details of
   CURSOR first_yr_rent (p_var_rent_id NUMBER) IS
     SELECT SUM(first_yr_rent) first_yr_rent
     FROM pn_var_trx_headers_all
     WHERE var_rent_id = p_var_rent_id;

   -- Get the details of
   CURSOR last_yr_rent (p_period_id NUMBER) IS
     SELECT (SUM(NVL(prorated_rent_due, 0)) - SUM(NVL(first_yr_rent, 0))) last_yr_rent
     FROM pn_var_trx_headers_all
     WHERE period_id = p_period_id;

l_rent                           NUMBER := 0;
l_first_period                   VARCHAR2(1) := 'N';
l_last_period                    VARCHAR2(1) := 'N';

BEGIN

 FOR rent_rec IN rent_cur LOOP

    FOR first_period_rec IN first_period_cur (rent_rec.var_rent_id, rent_rec.period_id) LOOP
        l_first_period := 'Y';
    END LOOP;

    FOR last_period_rec IN last_period_cur (rent_rec.var_rent_id, rent_rec.period_id) LOOP
        l_last_period := 'Y';
    END LOOP;

    IF p_proration_rule IN('FY','FLY') AND l_first_period = 'Y'
    THEN

      FOR first_yr_rec IN first_yr_rent(rent_rec.var_rent_id) LOOP
              l_rent := NVL(first_yr_rec.first_yr_rent, 0);
      END LOOP;

    ELSIF p_proration_rule IN('LY','FLY') AND l_last_period = 'Y'
    THEN

      FOR last_yr_rec IN last_yr_rent(rent_rec.period_id) LOOP
              l_rent := NVL(last_yr_rec.last_yr_rent, 0);
      END LOOP;

    ELSE

        l_rent := NVL(rent_rec.ytd_percent_rent, 0);

    END IF;

  END LOOP;

  return l_rent;

END cumulative_gross_vr;

--------------------------------------------------------------------------------
--  NAME         : fy_net_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION fy_net_sales(  p_var_rent_id       IN NUMBER
                       ,p_line_item_id      IN NUMBER)
RETURN NUMBER IS

  /* get FY sales */
  CURSOR fy_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(fy_proration_sales - NVL(fy_proration_deductions,0) ),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1) ;

  CURSOR line_item_cur IS
    SELECT trx.line_item_group_id, pvr.commencement_date
     FROM  pn_var_trx_headers_all trx,
           pn_var_rents_all pvr
     WHERE trx.var_rent_id = p_var_rent_id
     AND   trx.var_rent_id = pvr.var_rent_id
     AND   trx.line_item_id = p_line_item_id;

  l_sales NUMBER := 0;

BEGIN

   FOR rec IN line_item_cur LOOP

      FOR fy_sales_rec IN fy_sales_c( p_var_rent_id
                                     ,rec.commencement_date
                                     ,rec.line_item_group_id)
      LOOP
         l_sales := fy_sales_rec.sales ;
      END LOOP;

   END LOOP;

   RETURN l_sales;

END fy_net_sales;

--------------------------------------------------------------------------------
--  NAME         : first_yr_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION first_yr_sales(  p_var_rent_id       IN NUMBER
                       ,p_line_item_id      IN NUMBER)
RETURN NUMBER IS

  /* get FY sales */
  CURSOR fy_sales_c( p_vr_id            IN NUMBER
                    ,p_vr_comm_date     IN DATE
                    ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(fy_proration_sales),0) AS sales
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1) ;

  CURSOR line_item_cur IS
    SELECT trx.line_item_group_id, pvr.commencement_date
     FROM  pn_var_trx_headers_all trx,
           pn_var_rents_all pvr
     WHERE trx.var_rent_id = p_var_rent_id
     AND   trx.var_rent_id = pvr.var_rent_id
     AND   trx.line_item_id = p_line_item_id;

  l_sales NUMBER := 0;

BEGIN

   FOR rec IN line_item_cur LOOP

      FOR fy_sales_rec IN fy_sales_c( p_var_rent_id
                                     ,rec.commencement_date
                                     ,rec.line_item_group_id)
      LOOP
         l_sales := fy_sales_rec.sales ;
      END LOOP;

   END LOOP;

   RETURN l_sales;

END first_yr_sales;

--------------------------------------------------------------------------------
--  NAME         : first_yr_deductions
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
FUNCTION first_yr_deductions(  p_var_rent_id       IN NUMBER
                              ,p_line_item_id      IN NUMBER)
RETURN NUMBER IS

  /* get FY sales */
  CURSOR fy_deduction_c( p_vr_id            IN NUMBER
                        ,p_vr_comm_date     IN DATE
                        ,p_line_item_grp_id IN NUMBER) IS
    SELECT
    NVL(SUM(fy_proration_deductions),0) AS deductions
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    line_item_group_id = p_line_item_grp_id AND
    calc_prd_start_date <= (ADD_MONTHS(p_vr_comm_date, 12) - 1) ;

  CURSOR line_item_cur IS
    SELECT trx.line_item_group_id, pvr.commencement_date
     FROM  pn_var_trx_headers_all trx,
           pn_var_rents_all pvr
     WHERE trx.var_rent_id = p_var_rent_id
     AND   trx.var_rent_id = pvr.var_rent_id
     AND   trx.line_item_id = p_line_item_id;

  l_deductions NUMBER := 0;

BEGIN

   FOR rec IN line_item_cur LOOP

      FOR fy_deduction_rec IN fy_deduction_c( p_var_rent_id
                                             ,rec.commencement_date
                                             ,rec.line_item_group_id)
      LOOP
         l_deductions := fy_deduction_rec.deductions ;
      END LOOP;

   END LOOP;

   RETURN l_deductions;

END first_yr_deductions;

--------------------------------------------------------------------------------
--  NAME         : true_up_details
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
PROCEDURE true_up_details ( p_var_rent_id        IN NUMBER
                           ,p_trx_detail_id      IN NUMBER
                           ,p_rate               IN NUMBER
                           ,p_trueup_bkpt_vol_start OUT NOCOPY  NUMBER
                           ,p_trueup_bkpt_vol_end   OUT NOCOPY  NUMBER
                           ,p_trueup_volume         OUT NOCOPY  NUMBER
                           ,p_deductions            OUT NOCOPY  NUMBER
                           ,p_overage               OUT NOCOPY  NUMBER)
IS

  /* get FY sales */
CURSOR true_up_cur IS
  SELECT  dtls.ytd_group_vol_start AS trueup_bkpt_vol_start
         ,dtls.ytd_group_vol_end   AS trueup_bkpt_vol_end
         ,hdr.ytd_sales            AS trueup_volume
         ,hdr.ytd_deductions       AS deductions
  FROM   pn_var_trx_headers_all hdr,
         pn_var_trx_details_all dtls
  WHERE  dtls.trx_detail_id = p_trx_detail_id
  AND    dtls.bkpt_rate = p_rate
  AND    dtls.trx_header_id = hdr.trx_header_id;

  l_applicable_sales NUMBER := 0;

BEGIN

   FOR true_up_rec IN true_up_cur LOOP
      p_trueup_bkpt_vol_start := NVL(true_up_rec.trueup_bkpt_vol_start, 0);
      p_trueup_bkpt_vol_end   := NVL(true_up_rec.trueup_bkpt_vol_end, 0);
      p_trueup_volume         := NVL(true_up_rec.trueup_volume, 0);
      p_deductions            := NVL(true_up_rec.deductions, 0);

      l_applicable_sales := NVl(p_trueup_volume, 0) - NVL(p_deductions, 0);

      IF(p_trueup_bkpt_vol_end = 0) THEN
         p_overage := greatest(l_applicable_sales - p_trueup_bkpt_vol_start,0);
      ELSE
         IF((l_applicable_sales >= p_trueup_bkpt_vol_start) AND (l_applicable_sales <= p_trueup_bkpt_vol_end)) THEN
           p_overage :=  l_applicable_sales - p_trueup_bkpt_vol_start;
         ELSIF(l_applicable_sales > p_trueup_bkpt_vol_end) THEN
           p_overage := p_trueup_bkpt_vol_end - p_trueup_bkpt_vol_start;
         ELSIF(l_applicable_sales < p_trueup_bkpt_vol_start) THEN
           p_overage := 0;
         END IF;
      END IF;

      p_trueup_bkpt_vol_end := pn_var_rent_calc_pkg.end_breakpoint(p_trueup_bkpt_vol_start, p_trueup_bkpt_vol_end);

      p_trueup_bkpt_vol_start  := round(p_trueup_bkpt_vol_start,2);
      p_trueup_bkpt_vol_end    := round(p_trueup_bkpt_vol_end,2);
      p_trueup_volume          := round(p_trueup_volume,2);
      p_deductions             := round(p_deductions,2);
      p_overage                := round(p_overage,2);

   END LOOP;

END true_up_details;


--------------------------------------------------------------------------------
--  NAME         : true_up_summary
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Nov.06  piagrawa    o Created
--------------------------------------------------------------------------------
PROCEDURE true_up_summary ( p_period_id        IN NUMBER
                           ,p_true_up_rent     OUT NOCOPY  NUMBER
                           ,p_trueup_volume    OUT NOCOPY  NUMBER
                           ,p_deductions       OUT NOCOPY  NUMBER)
IS

  /* get FY sales */
CURSOR true_up_cur IS
  SELECT  sum(NVL(act_var_rent, 0)) + sum(NVL(trueup_var_rent, 0)) - sum(NVL(first_yr_rent,0)) true_up_rent,
          sum(NVL(tot_act_vol, 0)) true_up_vol,
          sum(NVL(tot_ded, 0)) true_up_deductions
  FROM   pn_var_rent_summ_all
  WHERE  period_id = p_period_id;

BEGIN

   FOR true_up_rec IN true_up_cur LOOP
      p_true_up_rent          := true_up_rec.true_up_rent;
      p_trueup_volume         := true_up_rec.true_up_vol;
      p_deductions            := true_up_rec.true_up_deductions;

   END LOOP;

END true_up_summary;

--------------------------------------------------------------------------------
--  NAME         : pop_inv_date_tab
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Dec.06  lbala    o Created
--------------------------------------------------------------------------------

PROCEDURE pop_inv_date_tab(p_var_rent_id IN NUMBER,
                           p_status IN VARCHAR2 )
IS
-- Get the all invoice_dates
CURSOR get_inv_dates_cur(p_vrent_id IN NUMBER,p_status IN VARCHAR2)
   IS
SELECT distinct gd1.invoice_date,gd1.period_id,decode(temp.inv_dt,NULL,'N','Y')
FROM pn_var_grp_dates_all gd1,
(SELECT gd.invoice_date inv_dt
 FROM pn_var_grp_dates_all gd
 WHERE EXISTS (SELECT NULL from pn_var_vol_hist_all vol
                WHERE vol_hist_status_code = p_status
                  AND vol.period_id = gd.period_id
                  AND vol.invoicing_date= gd.invoice_date
               )
AND
NOT EXISTS   (SELECT NULL from pn_var_rent_inv_all vinv
               WHERE vinv.invoice_date=gd.invoice_date
                 AND vinv.period_id=gd.period_id
             )
AND gd.var_rent_id=p_vrent_id
)temp
WHERE gd1.var_rent_id=p_vrent_id
AND gd1.invoice_date=temp.inv_dt(+)
ORDER BY gd1.invoice_date;

BEGIN
pnp_debug_pkg.log('+++++++++ POP_INV_DATE_TAB START +++++++++++');

OPEN get_inv_dates_cur(p_var_rent_id,p_status) ;
FETCH get_inv_dates_cur BULK COLLECT INTO inv_date_tab;
CLOSE get_inv_dates_cur;

pnp_debug_pkg.log('+++++++++ POP_INV_DATE_TAB END +++++++++++');
END pop_inv_date_tab;
--------------------------------------------------------------------------------
--  NAME         : POP_INV_DATE_TAB_FIRSTYR
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Dec.06  lbala    o Created
--------------------------------------------------------------------------------

PROCEDURE POP_INV_DATE_TAB_FIRSTYR(p_var_rent_id IN NUMBER,
                                   p_status IN VARCHAR2)
IS
-- Get roll fwd flag for 1st partial period
CURSOR get_fst_prd_flag(p_vrent_id IN NUMBER,p_status IN VARCHAR2) IS
  SELECT 'Y' fst_prd_flag
    FROM dual
   WHERE EXISTS
         (SELECT period_id FROM pn_var_periods_all vp
          WHERE period_num=1
          AND var_rent_id=p_vrent_id
          AND partial_period='Y'
          AND EXISTS (select NULL from pn_var_vol_hist_all vol
                      where vol_hist_status_code = p_status
                      and vol.period_id = vp.period_id
                      and var_rent_id=p_vrent_id
                      )
          AND NOT EXISTS (select NULL from pn_var_rent_inv_all vinv
                          where vinv.var_rent_id = p_vrent_id
                          and vinv.period_id = vp.period_id
                          )
         );

-- Get invoice dates from 2nd annual period for FY/FLY proration rules
CURSOR get_partial_prd_inv_dates(p_vrent_id IN NUMBER,p_status IN VARCHAR2)
IS
SELECT distinct gd1.invoice_date ,gd1.period_id, decode(temp.inv_dt,NULL,'N','Y')
FROM pn_var_grp_dates_all gd1,
     pn_var_periods_all vp,
(SELECT gd.invoice_date inv_dt
 FROM pn_var_grp_dates_all gd
 WHERE EXISTS(select NULL from pn_var_vol_hist_all vol
               where vol_hist_status_code = p_status
                 and vol.period_id = gd.period_id
                 and vol.invoicing_date= gd.invoice_date
             )
 AND NOT EXISTS (select NULL from pn_var_rent_inv_all vinv
                  where vinv.invoice_date=gd.invoice_date
                    and vinv.period_id=gd.period_id
                )
 AND gd.var_rent_id=p_vrent_id
)temp
where gd1.var_rent_id=p_vrent_id
and gd1.period_id=vp.period_id
and vp.period_num>1
and gd1.invoice_date=temp.inv_dt(+)
order by gd1.invoice_date;

BEGIN
pnp_debug_pkg.log('+++++++++ POP_INV_DATE_TAB_FIRSTYR START +++++++++++');

FOR fst_prd_cur IN get_fst_prd_flag(p_var_rent_id ,p_status) LOOP
  g_partial_prd_flag := fst_prd_cur.fst_prd_flag;
END LOOP;

--pnp_debug_pkg.log('g_partial_prd_flag='||g_partial_prd_flag);

OPEN get_partial_prd_inv_dates(p_var_rent_id,p_status) ;
FETCH get_partial_prd_inv_dates BULK COLLECT INTO inv_date_tab;
CLOSE get_partial_prd_inv_dates;

pnp_debug_pkg.log('+++++++++ POP_INV_DATE_TAB_FIRSTYR END +++++++++++');
END POP_INV_DATE_TAB_FIRSTYR;

--------------------------------------------------------------------------------
--  NAME         : ROLL_FWD_PARTIAL_PRD
--  DESCRIPTION  : Rolls forward the abatement selections when an invoice is
--                 calculated the 1st time for FY/FLY prorationmethod
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Dec.06  lbala    o Created
--------------------------------------------------------------------------------
PROCEDURE ROLL_FWD_PARTIAL_PRD(p_var_rent_id IN NUMBER)
IS

l_pmt_term_id       NUMBER :=NULL;
l_abtmt_term_id     NUMBER :=NULL;
l_min_pmt_term_id   NUMBER :=NULL;
l_row_id            VARCHAR2(18):=NULL;
l_var_abmt_id       NUMBER :=NULL;
l_min_var_abt_id    NUMBER :=NULL;
l_fst_inv_dt        DATE := NULL;
l_inv_id            NUMBER :=NULL;
l_prev_inv_id       NUMBER := NULL;
l_prev_dt           DATE := NULL;
l_org_id            NUMBER;
l_fst_inv_id        NUMBER := NULL;

CURSOR org_cur(p_var_rent_id IN NUMBER) IS
  SELECT org_id
  FROM   pn_var_rents_all
  WHERE  var_rent_id =p_var_rent_id;

/*Cursor to get all pmt terms for a particular invoice*/
CURSOR get_all_pmt_terms(p_inv_id IN NUMBER) IS
  SELECT  distinct pterm.payment_term_id payment_term_id
  FROM pn_payment_terms_all pterm,
     pn_var_rents_all vrent,
     pn_var_rent_inv_all vinv
  WHERE vrent.lease_id = pterm.lease_id
  AND vrent.var_rent_id = vinv.var_rent_id
  AND pterm.start_date <=
  (SELECT MAX(gd.grp_end_date)
   FROM pn_var_grp_dates_all gd
   WHERE gd.period_id = vinv.period_id
   AND gd.invoice_date = vinv.invoice_date
  )
  AND pterm.end_date >=
  (SELECT MIN(gd1.grp_start_date)
   FROM pn_var_grp_dates_all gd1
   WHERE gd1.period_id = vinv.period_id
   AND gd1.invoice_date = vinv.invoice_date
  )
  AND pterm.var_rent_inv_id IS NULL
  AND pterm.index_period_id IS NULL
  AND vinv.adjust_num = 0
  AND vinv.var_rent_inv_id=p_inv_id;

/*Cursor to get all abtmt terms for a particular invoice*/
CURSOR get_abtmt_terms_inv(p_inv_id IN NUMBER) IS
  select * from pn_var_abatements_all
  where var_rent_inv_id=p_inv_id;

/*Cursor to get abtmt terms for 1st invoice from setup*/
CURSOR get_var_abtmt_id(p_vrent_id IN NUMBER) IS
  SELECT var_abatement_id,payment_term_id
  FROM pn_var_abatements_all
  WHERE var_rent_inv_id = -1
  AND var_rent_id=p_vrent_id;


-- Get the invoice id for a given period_id and invoice_date
CURSOR check_inv_exists(p_var_rent_id IN NUMBER,p_inv_dt IN DATE,p_prd_id IN NUMBER) IS
  SELECT var_rent_inv_id inv_id
  FROM pn_var_rent_inv_all
  WHERE invoice_date= p_inv_dt
  AND   var_rent_id = p_var_rent_id
  AND   period_id   = p_prd_id
  AND   adjust_num  = 0;

-- Get the details of invoice for 1st partial period
CURSOR get_fst_inv_id(p_var_rent_id IN NUMBER) IS
  SELECT var_rent_inv_id
    FROM pn_var_rent_inv_all
   WHERE var_rent_id=p_var_rent_id
     AND period_id IN (SELECT period_id
                       FROM pn_var_periods_all
                       WHERE period_num=1
                       AND var_rent_id=p_var_rent_id
                       AND partial_period='Y'
                       )
     AND adjust_num=0;


BEGIN
pnp_debug_pkg.log('+++++++++ ROLL_FWD_PARTIAL_PRD START +++++++++++');

FOR rec IN org_cur(p_var_rent_id) LOOP
        l_org_id := rec.org_id;
END LOOP;
-- Get invoice id of 1st partial period
FOR fst_inv IN get_fst_inv_id(p_var_rent_id) LOOP
   l_fst_inv_id := fst_inv.var_rent_inv_id;
END LOOP;

IF g_partial_prd_flag='Y' AND l_fst_inv_id IS NOT NULL THEN
   /* updation for 1st invoice */
   l_min_var_abt_id:=NULL;
   l_min_pmt_term_id:=NULL;

   FOR abtmt_exists_rec IN  get_var_abtmt_id(p_var_rent_id) LOOP
    l_min_var_abt_id  := abtmt_exists_rec.var_abatement_id;
    l_min_pmt_term_id := abtmt_exists_rec.payment_term_id;

    --pnp_debug_pkg.log('prior to update');
    PN_VAR_ABATEMENTS_PKG.LOCK_ROW(p_var_rent_id,-1,l_min_pmt_term_id);
    update pn_var_abatements_all
    set var_rent_inv_id = l_fst_inv_id
    where var_abatement_id = l_min_var_abt_id;

   END LOOP;
  /* updation for 1st invoice over*/

END IF;

FOR i IN 1..inv_date_tab.COUNT LOOP

 l_inv_id:=NULL;
 l_prev_inv_id :=NULL;
 IF  (inv_date_tab(i).inv_flag ='Y') THEN
   pnp_debug_pkg.log('invoice '||inv_date_tab(i).inv_flag||inv_date_tab(i).inv_date||inv_date_tab(i).period_id);

   FOR rec IN check_inv_exists(p_var_rent_id ,inv_date_tab(i).inv_date,inv_date_tab(i).period_id) LOOP
      l_inv_id:= rec.inv_id;
   END LOOP;
   pnp_debug_pkg.log('invoice id= '||l_inv_id);

   IF i=1 THEN
      l_prev_inv_id:=l_fst_inv_id;
   ELSE
     FOR rec1 IN check_inv_exists(p_var_rent_id ,inv_date_tab(i-1).inv_date,inv_date_tab(i-1).period_id) LOOP
      l_prev_inv_id:= rec1.inv_id;
     END LOOP;
   END IF;

   IF l_prev_inv_id IS NOT NULL THEN

        FOR pmt_term_rec IN get_all_pmt_terms(l_inv_id) LOOP
          l_pmt_term_id:= pmt_term_rec.payment_term_id;

          FOR abtmt_inv_rec IN get_abtmt_terms_inv(l_prev_inv_id) LOOP
           l_abtmt_term_id := abtmt_inv_rec.payment_term_id;

           IF (l_pmt_term_id = l_abtmt_term_id) THEN

            l_row_id := NULL;
            l_var_abmt_id :=NULL;

            PN_VAR_ABATEMENTS_PKG.INSERT_ROW(
                   X_ROWID             => l_row_id,
                   X_VAR_ABATEMENT_ID  => l_var_abmt_id,
                   X_VAR_RENT_ID       => p_var_rent_id,
                   X_VAR_RENT_INV_ID   => l_inv_id,
                   X_PAYMENT_TERM_ID   => l_pmt_term_id,
                   X_INCLUDE_TERM      => abtmt_inv_rec.include_term,
                   X_INCLUDE_INCREASES => abtmt_inv_rec.include_increases,
                   X_UPDATE_FLAG       => NULL,
                   X_CREATION_DATE     => sysdate,
                   X_CREATED_BY        => NVL(fnd_profile.value('USER_ID'),-1),
                   X_LAST_UPDATE_DATE  => sysdate,
                   X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
                   X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1),
                   X_ORG_ID            => l_org_id  );
           END IF;

         END LOOP;

       END LOOP;

   ELSE
        EXIT ;

   END IF;
 END IF;
END LOOP;
pnp_debug_pkg.log('+++++++++ ROLL_FWD_PARTIAL_PRD END +++++++++++');
END ROLL_FWD_PARTIAL_PRD;
--------------------------------------------------------------------------------
--  NAME         : ROLL_FWD_LST_PARTIAL_PRD
--  DESCRIPTION  : Rolls forward the abatement selections when the last partial
--                 period invoice is calculated the 1st time
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Dec.06  lbala    o Created
--------------------------------------------------------------------------------
PROCEDURE ROLL_FWD_LST_PARTIAL_PRD(p_var_rent_id IN NUMBER)
IS
--- Get org_id
CURSOR org_cur(p_var_rent_id IN NUMBER) IS
  SELECT org_id
  FROM   pn_var_rents_all
  WHERE  var_rent_id =p_var_rent_id;

-- Get the last partial period id
CURSOR get_last_partial_prd(p_var_rent_id IN NUMBER) IS
 SELECT prd.period_id
   FROM pn_var_periods_all prd ,pn_var_rents_all vrent
  WHERE prd.var_rent_id=p_var_rent_id
    AND vrent.var_rent_id = prd.var_rent_id
    AND prd.end_date = vrent.termination_date
    AND partial_period='Y';

-- Get the invoice id
CURSOR get_last_invoice_id(p_var_rent_id IN NUMBER
                          ,p_prd_id IN NUMBER
                          ,p_inv_dt IN DATE
                          )
  IS
  SELECT var_rent_inv_id
    FROM pn_var_rent_inv_all
   WHERE var_rent_id=p_var_rent_id
     AND period_id=p_prd_id
     AND invoice_date=p_inv_dt
     AND adjust_num=0;

-- Get all invoices for a given period
CURSOR get_last_prd_inv(p_var_rent_id IN NUMBER
                       ,p_prd_id IN NUMBER
                       ,p_inv_id IN NUMBER)
  IS
  SELECT var_rent_inv_id
    FROM pn_var_rent_inv_all
   WHERE var_rent_id=p_var_rent_id
     AND period_id=p_prd_id
     AND var_rent_inv_id <> p_inv_id
     AND adjust_num=0;

/*Cursor to get all abtmt terms for a particular invoice*/
CURSOR get_abtmt_terms_inv(p_inv_id IN NUMBER) IS
  SELECT * FROM pn_var_abatements_all
  WHERE var_rent_inv_id=p_inv_id;

-- Check whether a given combination of (payment_term_id,var_rent_inv_id)
--       exists in pn_var_abatements_all
CURSOR check_abtmt_exists(p_inv_id IN NUMBER,p_pmt_id IN NUMBER)
IS
  SELECT 'Y' abt_exists
    FROM dual
   WHERE EXISTS ( SELECT NULL
                  FROM pn_var_abatements_all
                  WHERE var_rent_inv_id=p_inv_id
                  AND payment_term_id = p_pmt_id );
-- Get the invoice_date for an invoice with a given grp_end_dt
CURSOR get_inv_date(p_var_rent_id IN NUMBER,p_prd_id IN NUMBER,p_end_dt IN DATE)
IS
SELECT invoice_date
FROM pn_var_grp_dates_all
WHERE var_rent_id = p_var_rent_id
AND period_id = p_prd_id
AND grp_end_date = p_end_dt;

l_org_id      NUMBER :=NULL;
l_last_prd_id NUMBER :=NULL;
l_last_inv_id NUMBER :=NULL;
l_inv_id      NUMBER :=NULL;
l_pmt_term_id NUMBER :=NULL;
l_abt_exists  VARCHAR2(1):=NULL;
l_row_id      ROWID ;
l_var_abmt_id NUMBER :=NULL;
l_last_inv_dt DATE   :=NULL;
j             NUMBER :=NULL;
BEGIN
pnp_debug_pkg.log('+++++++++ ROLL_FWD_LST_PARTIAL_PRD START +++++++++++');

--1. Get last partial period id
--2. Get invoice date for the last invoice of this partial period whose grp end date is
--   Variable Rent Agreement's termination date
--3. Get the index of the corresponding record from inv_date_tab for combination of the above
--   invoice date and last partial period id and determine the corresponding invoice id
--4. If roll fwd flag='Y' , then roll forward the UNION of selecns from other invoices of the
--   last partial period to this invoice id

FOR rec IN org_cur(p_var_rent_id) LOOP
  l_org_id := rec.org_id;
END LOOP;

-- Get last partial period id
FOR last_prd_rec IN get_last_partial_prd(p_var_rent_id) LOOP
   l_last_prd_id := last_prd_rec.period_id;
END LOOP;

--pnp_debug_pkg.log('last period id= '||l_last_prd_id);

IF l_last_prd_id IS NOT NULL THEN

 FOR rec IN get_inv_date(p_var_rent_id,l_last_prd_id,g_vr_termination_date) LOOP
  l_last_inv_dt := rec.invoice_date;
 END LOOP;

 FOR i IN 1..inv_date_tab.COUNT LOOP
     IF inv_date_tab(i).period_id=l_last_prd_id AND
        inv_date_tab(i).inv_date= l_last_inv_dt THEN
        j:=i;
        EXIT;
     END IF;
 END LOOP;

 IF ((j IS NOT NULL) AND inv_date_tab(j).inv_flag ='Y') THEN

  FOR last_inv_rec IN get_last_invoice_id(p_var_rent_id,l_last_prd_id,inv_date_tab(j).inv_date) LOOP
   l_last_inv_id := last_inv_rec.var_rent_inv_id;
  END LOOP;
  --pnp_debug_pkg.log('last invoice id= '||l_last_inv_id);

  FOR inv_rec IN get_last_prd_inv(p_var_rent_id,l_last_prd_id,l_last_inv_id) LOOP
   l_inv_id := inv_rec.var_rent_inv_id;
   --pnp_debug_pkg.log('invoice id = '||l_inv_id);

   FOR abtmt_inv_rec IN get_abtmt_terms_inv(l_inv_id) LOOP
     l_pmt_term_id := abtmt_inv_rec.payment_term_id;

     FOR rec1 IN check_abtmt_exists(l_last_inv_id,l_pmt_term_id) LOOP
       l_abt_exists := rec1.abt_exists;
     END LOOP;

     IF l_abt_exists <> 'Y' THEN
       l_row_id := NULL;
       l_var_abmt_id :=NULL;

       PN_VAR_ABATEMENTS_PKG.INSERT_ROW(
                   X_ROWID             => l_row_id,
                   X_VAR_ABATEMENT_ID  => l_var_abmt_id,
                   X_VAR_RENT_ID       => p_var_rent_id,
                   X_VAR_RENT_INV_ID   => l_last_inv_id,
                   X_PAYMENT_TERM_ID   => l_pmt_term_id,
                   X_INCLUDE_TERM      => abtmt_inv_rec.include_term,
                   X_INCLUDE_INCREASES => abtmt_inv_rec.include_increases,
                   X_UPDATE_FLAG       => NULL,
                   X_CREATION_DATE     => sysdate,
                   X_CREATED_BY        => NVL(fnd_profile.value('USER_ID'),-1),
                   X_LAST_UPDATE_DATE  => sysdate,
                   X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
                   X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1),
                   X_ORG_ID            => l_org_id  );

     END IF;

   END LOOP;

  END LOOP;

 END IF;

END IF;
pnp_debug_pkg.log('+++++++++ ROLL_FWD_LST_PARTIAL_PRD END +++++++++++');
END ROLL_FWD_LST_PARTIAL_PRD;

--------------------------------------------------------------------------------
--  NAME         : ROLL_FWD_SELECNS
--  DESCRIPTION  : Rolls forward the abatement selections when an invoice is
--                 calculated the 1st time
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Dec.06  lbala    o Created
--------------------------------------------------------------------------------

PROCEDURE ROLL_FWD_SELECNS(p_var_rent_id IN NUMBER)
IS

l_pmt_term_id       NUMBER :=NULL;
l_abtmt_term_id     NUMBER :=NULL;
l_min_pmt_term_id   NUMBER :=NULL;
l_row_id            VARCHAR2(18):=NULL;
l_var_abmt_id       NUMBER :=NULL;
l_min_var_abt_id    NUMBER :=NULL;
l_fst_inv_dt        DATE := NULL;
l_inv_id            NUMBER :=NULL;
l_prev_inv_id       NUMBER := NULL;
l_prev_dt           DATE := NULL;
l_org_id            NUMBER;


/* Cursor to get 1st invoice date*/
CURSOR get_min_inv(p_var_rent_id IN NUMBER) IS
   SELECT min(invoice_date) fst_inv_dt
   FROM pn_var_grp_dates_all
   WHERE var_rent_id= p_var_rent_id ;


/*Cursor to get all pmt terms for a particular invoice*/
CURSOR get_all_pmt_terms(p_inv_id IN NUMBER) IS
  SELECT distinct pterm.payment_term_id payment_term_id
  FROM pn_payment_terms_all pterm,
       pn_var_rents_all     vrent,
       pn_var_rent_inv_all  vinv
  WHERE vrent.lease_id = pterm.lease_id
  AND vrent.var_rent_id = vinv.var_rent_id
  AND pterm.start_date <=
  (SELECT MAX(gd.grp_end_date)
   FROM pn_var_grp_dates_all gd
   WHERE gd.period_id = vinv.period_id
   AND gd.invoice_date = vinv.invoice_date
  )
  AND pterm.end_date >=
  (SELECT MIN(gd1.grp_start_date)
   FROM pn_var_grp_dates_all gd1
   WHERE gd1.period_id = vinv.period_id
   AND gd1.invoice_date = vinv.invoice_date
  )
  AND pterm.var_rent_inv_id IS NULL
  AND pterm.index_period_id IS NULL
  AND vinv.adjust_num = 0
  AND vinv.var_rent_inv_id=p_inv_id;

/*Cursor to get all abtmt terms for a particular invoice*/
CURSOR get_abtmt_terms_inv(p_inv_id IN NUMBER) IS
  select * from pn_var_abatements_all
  where var_rent_inv_id=p_inv_id;

/*Cursor to get abtmt terms for 1st invoice from setup*/
CURSOR get_var_abtmt_id(p_var_rent_id IN NUMBER) IS
  SELECT var_abatement_id , payment_term_id
  FROM pn_var_abatements_all
  WHERE var_rent_inv_id = -1
  AND var_rent_id=p_var_rent_id;

-- Get the invoice id for combination of a given invoice_date and period_id
CURSOR check_inv_exists(p_var_rent_id IN NUMBER,p_inv_dt IN DATE,p_prd_id IN NUMBER) IS
  SELECT var_rent_inv_id inv_id
  FROM pn_var_rent_inv_all
  WHERE invoice_date=p_inv_dt
  AND   var_rent_id =p_var_rent_id
  AND   period_id  =p_prd_id
  AND   adjust_num=0;

CURSOR org_cur(p_var_rent_id IN NUMBER) IS
  SELECT org_id
  FROM   pn_var_rents_all
  WHERE  var_rent_id =p_var_rent_id;

BEGIN
/* Get 1st invoice */
pnp_debug_pkg.log('+++++++++ ROLL_FWD_SELECNS START +++++++++++');

FOR rec IN org_cur(p_var_rent_id) LOOP
  l_org_id := rec.org_id;
END LOOP;

FOR min_inv_rec IN get_min_inv(p_var_rent_id) LOOP
  l_fst_inv_dt := min_inv_rec.fst_inv_dt;
END LOOP;
--pnp_debug_pkg.log('1st invoice date= '||l_fst_inv_dt);

FOR i IN 1..inv_date_tab.COUNT LOOP

 l_inv_id:=NULL;
 l_prev_inv_id :=NULL;

 IF  (inv_date_tab(i).inv_flag ='Y') THEN
   --pnp_debug_pkg.log('invoice '||inv_date_tab(i).inv_flag||inv_date_tab(i).inv_date||p_var_rent_id);

   FOR rec IN check_inv_exists(p_var_rent_id ,inv_date_tab(i).inv_date,inv_date_tab(i).period_id) LOOP
       l_inv_id:= rec.inv_id;
   END LOOP;
       --pnp_debug_pkg.log('invoice id= '||l_inv_id);

       IF  (inv_date_tab(i).inv_date=l_fst_inv_dt) THEN
          /* updation for 1st invoice */

           IF l_inv_id IS NOT NULL THEN
                l_min_pmt_term_id:=NULL;
                l_min_var_abt_id:=NULL;
                FOR abtmt_exists_rec IN get_var_abtmt_id(p_var_rent_id) LOOP

                  l_min_var_abt_id:= abtmt_exists_rec.var_abatement_id;
                  l_min_pmt_term_id:= abtmt_exists_rec.payment_term_id;
                  --pnp_debug_pkg.log('prior to update');

                  PN_VAR_ABATEMENTS_PKG.LOCK_ROW(p_var_rent_id,-1,l_min_pmt_term_id);
                  UPDATE pn_var_abatements_all
                  SET var_rent_inv_id=l_inv_id
                  WHERE var_abatement_id = l_min_var_abt_id;

                END LOOP;
           END IF;
           /* updation for 1st invoice over*/
       ELSE

          l_prev_dt:= inv_date_tab(i-1).inv_date;
          FOR rec1 IN check_inv_exists(p_var_rent_id ,l_prev_dt,inv_date_tab(i-1).period_id) LOOP
            l_prev_inv_id:= rec1.inv_id;
          END LOOP;

          IF l_prev_inv_id IS NOT NULL THEN

              FOR pmt_term_rec IN get_all_pmt_terms(l_inv_id) LOOP
               l_pmt_term_id:= pmt_term_rec.payment_term_id;

               FOR abtmt_inv_rec IN get_abtmt_terms_inv(l_prev_inv_id) LOOP
                l_abtmt_term_id := abtmt_inv_rec.payment_term_id;

                IF (l_pmt_term_id = l_abtmt_term_id) THEN
                 l_row_id := NULL;
                 l_var_abmt_id :=NULL;

                 PN_VAR_ABATEMENTS_PKG.INSERT_ROW(
                        X_ROWID             => l_row_id,
                        X_VAR_ABATEMENT_ID  => l_var_abmt_id,
                        X_VAR_RENT_ID       => p_var_rent_id,
                        X_VAR_RENT_INV_ID   => l_inv_id,
                        X_PAYMENT_TERM_ID   => l_pmt_term_id,
                        X_INCLUDE_TERM      => abtmt_inv_rec.include_term,
                        X_INCLUDE_INCREASES => abtmt_inv_rec.include_increases,
                        X_UPDATE_FLAG       => NULL,
                        X_CREATION_DATE     => sysdate,
                        X_CREATED_BY        => NVL(fnd_profile.value('USER_ID'),-1),
                        X_LAST_UPDATE_DATE  => sysdate,
                        X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
                        X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1),
                        X_ORG_ID            => l_org_id  );
                END IF;

              END LOOP;

            END LOOP;

          ELSE
             EXIT ;

          END IF;

      END IF;
END IF;

END LOOP;
pnp_debug_pkg.log('+++++++++ ROLL_FWD_SELECNS END +++++++++++');
END ROLL_FWD_SELECNS;
--------------------------------------------------------------------------------
--  NAME         : include_increases_firstyr
--  DESCRIPTION  : Includes Rent Increase terms to be abated for 1st partial period
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Dec.06  lbala    o Created
--------------------------------------------------------------------------------
PROCEDURE include_increases_firstyr(p_var_rent_id IN NUMBER) IS

/*Cursor to get all abtmt terms with include_incr='Y' for a particular invoice*/
CURSOR get_abtmt_terms_inv(p_inv_id IN NUMBER,p_var_rent_id IN NUMBER) IS
  SELECT * from pn_var_abatements_all
   WHERE var_rent_inv_id = p_inv_id
    AND  var_rent_id = p_var_rent_id
    AND  include_increases = 'Y';

-- Get the rent increase terms for a payment term of a particular invoice
CURSOR get_rent_incr_cur(p_term_id IN NUMBER,p_inv_id IN NUMBER) IS

SELECT ppt.payment_term_id rent_incr_term_id
 FROM  pn_index_lease_terms_all pilt,
       pn_payment_terms_all ppt ,
       pn_index_leases_all pil,
       pn_var_rent_inv_all vinv
WHERE pilt.index_lease_id = pil.index_lease_id
AND pil.lease_id = ppt.lease_id
AND pilt.index_period_id = ppt.index_period_id
AND pilt.rent_increase_term_id = ppt.payment_term_id
AND ppt.start_date <= (SELECT MAX(gd.grp_end_date)
                       FROM pn_var_grp_dates_all gd
                       WHERE gd.period_id = vinv.period_id
                      )
AND ppt.end_date >=  (SELECT MIN(gd1.grp_start_date)
                      FROM pn_var_grp_dates_all gd1
                      WHERE gd1.period_id = vinv.period_id
                     )
AND pilt.lease_term_id = p_term_id
AND ppt.status='APPROVED'
AND vinv.adjust_num = 0
AND vinv.var_rent_inv_id=p_inv_id;

-- Check if abatement exists for this pmt term and invoice id combination
CURSOR check_abtmt_exists(pmt_term_id IN NUMBER,invoice_id IN NUMBER) IS
  SELECT 'N'
    FROM dual
   WHERE NOT EXISTS ( SELECT NULL FROM pn_var_abatements_all
                       WHERE payment_term_id=pmt_term_id
                        AND  var_rent_inv_id=invoice_id);

CURSOR org_cur(p_var_rent_id IN NUMBER) IS
  SELECT org_id
  FROM   pn_var_rents_all
  WHERE  var_rent_id =p_var_rent_id;
--Get invoice id of the 1st partial period
CURSOR get_fst_inv_id(p_var_rent_id IN NUMBER) IS
  SELECT var_rent_inv_id
    FROM pn_var_rent_inv_all
   WHERE var_rent_id=p_var_rent_id
     AND period_id IN (SELECT period_id
                       FROM pn_var_periods_all
                       WHERE period_num=1
                       AND var_rent_id=p_var_rent_id
                       AND partial_period='Y')
     AND adjust_num=0;

l_abtmt_exists VARCHAR2(1) := NULL;
l_inv_id       NUMBER      := NULL;
l_row_id       VARCHAR2(18):= NULL;
l_var_abmt_id  NUMBER      := NULL;
l_org_id       NUMBER;

BEGIN
pnp_debug_pkg.log('+++++++++ include_increases_firstyr START +++++++++++');
FOR rec IN org_cur(p_var_rent_id) LOOP
    l_org_id := rec.org_id;
END LOOP;
IF g_partial_prd_flag='Y' THEN

   FOR fst_inv_rec IN get_fst_inv_id(p_var_rent_id) LOOP
     l_inv_id := fst_inv_rec.var_rent_inv_id;
   END LOOP;

   --pnp_debug_pkg.log('invoice_id =  '||l_inv_id);
   FOR parent_rec IN get_abtmt_terms_inv(l_inv_id ,p_var_rent_id ) LOOP

        --pnp_debug_pkg.log('parent term = '||parent_rec.payment_term_id);
        FOR rent_incr IN  get_rent_incr_cur(parent_rec.payment_term_id ,l_inv_id ) LOOP

             --pnp_debug_pkg.log('child_term = '||rent_incr.rent_incr_term_id);
             l_abtmt_exists := NULL;

             OPEN check_abtmt_exists(rent_incr.rent_incr_term_id,l_inv_id);
             FETCH check_abtmt_exists INTO l_abtmt_exists ;
             CLOSE check_abtmt_exists;

             IF  l_abtmt_exists  = 'N' THEN

                 l_row_id := NULL;
                 l_var_abmt_id :=NULL;
                 PN_VAR_ABATEMENTS_PKG.INSERT_ROW(
                        X_ROWID             => l_row_id,
                        X_VAR_ABATEMENT_ID  => l_var_abmt_id,
                        X_VAR_RENT_ID       => p_var_rent_id,
                        X_VAR_RENT_INV_ID   => l_inv_id,
                        X_PAYMENT_TERM_ID   => rent_incr.rent_incr_term_id,
                        X_INCLUDE_TERM      => 'Y',
                        X_INCLUDE_INCREASES => 'Y',
                        X_UPDATE_FLAG       => NULL,
                        X_CREATION_DATE     => sysdate,
                        X_CREATED_BY        => NVL(fnd_profile.value('USER_ID'),-1),
                        X_LAST_UPDATE_DATE  => sysdate,
                        X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
                        X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1),
                        X_ORG_ID            => l_org_id  );
             END IF;

        END LOOP;

   END LOOP;
END IF;
pnp_debug_pkg.log('+++++++++ include_increases_firstyr END +++++++++++');
END include_increases_firstyr;
--------------------------------------------------------------------------------
--  NAME         : include_increases
--  DESCRIPTION  : Includes Rent Increase terms to be abated
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Dec.06  lbala    o Created
--------------------------------------------------------------------------------
PROCEDURE include_increases(p_var_rent_id IN NUMBER) IS

/*Cursor to get all abtmt terms with include_incr='Y' for a particular invoice*/
CURSOR get_abtmt_terms_inv(p_inv_id IN NUMBER,p_var_rent_id IN NUMBER) IS
  SELECT * from pn_var_abatements_all
   WHERE var_rent_inv_id = p_inv_id AND
         var_rent_id = p_var_rent_id AND
         include_increases = 'Y';


-- Get the rent increase terms for a payment term of a particular invoice
CURSOR get_rent_incr_cur(p_term_id IN NUMBER,p_inv_id IN NUMBER) IS

SELECT ppt.payment_term_id rent_incr_term_id
 FROM  pn_index_lease_terms_all pilt,
       pn_payment_terms_all ppt ,
       pn_index_leases_all pil,
       pn_var_rent_inv_all vinv
WHERE pilt.index_lease_id = pil.index_lease_id
AND pil.lease_id = ppt.lease_id
AND pilt.index_period_id = ppt.index_period_id
AND pilt.rent_increase_term_id = ppt.payment_term_id
AND ppt.start_date <= (SELECT MAX(gd.grp_end_date)
                       FROM pn_var_grp_dates_all gd
                       WHERE gd.period_id = vinv.period_id
                       AND gd.invoice_date = vinv.invoice_date
                       )
AND ppt.end_date >=  (SELECT MIN(gd1.grp_start_date)
                        FROM pn_var_grp_dates_all gd1
                        WHERE gd1.period_id = vinv.period_id
                        AND gd1.invoice_date = vinv.invoice_date
                     )
AND pilt.lease_term_id = p_term_id
AND ppt.status='APPROVED'
AND vinv.adjust_num = 0
AND vinv.var_rent_inv_id=p_inv_id;

-- Get the details of
CURSOR check_abtmt_exists(pmt_term_id IN NUMBER,invoice_id IN NUMBER) IS
  SELECT 'N'
    FROM dual
   WHERE NOT EXISTS ( SELECT NULL FROM pn_var_abatements_all
                      WHERE payment_term_id=pmt_term_id
                      AND var_rent_inv_id=invoice_id);

CURSOR check_inv_exists(p_var_rent_id IN NUMBER,p_inv_dt IN DATE,p_prd_id IN NUMBER) IS
  SELECT var_rent_inv_id inv_id
  FROM pn_var_rent_inv_all
  WHERE invoice_date=p_inv_dt
  AND   period_id= p_prd_id
  AND  var_rent_id= p_var_rent_id
  AND  adjust_num=0;

CURSOR org_cur(p_var_rent_id IN NUMBER) IS
  SELECT org_id
  FROM   pn_var_rents_all
  WHERE  var_rent_id =p_var_rent_id;

l_abtmt_exists VARCHAR2(1) := NULL;
l_inv_id       NUMBER      := NULL;
l_row_id       VARCHAR2(18):= NULL;
l_var_abmt_id  NUMBER      := NULL;
l_org_id       NUMBER;
BEGIN

pnp_debug_pkg.log('+++++++++ include_increases START +++++++++++');
FOR rec IN org_cur(p_var_rent_id) LOOP
        l_org_id := rec.org_id;
END LOOP;

FOR i IN 1..inv_date_tab.COUNT LOOP

  IF  (inv_date_tab(i).inv_flag ='Y') THEN
     FOR rec IN check_inv_exists(p_var_rent_id ,inv_date_tab(i).inv_date,inv_date_tab(i).period_id) LOOP
                l_inv_id:= rec.inv_id;
     END LOOP;
     --pnp_debug_pkg.log('invoice_id =  '||l_inv_id);

     FOR parent_rec IN get_abtmt_terms_inv(l_inv_id ,p_var_rent_id ) LOOP

          --pnp_debug_pkg.log('parent term = '||parent_rec.payment_term_id);

          FOR rent_incr IN  get_rent_incr_cur(parent_rec.payment_term_id ,l_inv_id ) LOOP

             --pnp_debug_pkg.log('child_term = '||rent_incr.rent_incr_term_id);

             l_abtmt_exists := NULL;
             OPEN check_abtmt_exists(rent_incr.rent_incr_term_id,l_inv_id);
             FETCH check_abtmt_exists INTO l_abtmt_exists ;
             CLOSE check_abtmt_exists;

             IF  l_abtmt_exists  = 'N' THEN

                 l_row_id := NULL;
                 l_var_abmt_id :=NULL;

                 PN_VAR_ABATEMENTS_PKG.INSERT_ROW(
                        X_ROWID             => l_row_id,
                        X_VAR_ABATEMENT_ID  => l_var_abmt_id,
                        X_VAR_RENT_ID       => p_var_rent_id,
                        X_VAR_RENT_INV_ID   => l_inv_id,
                        X_PAYMENT_TERM_ID   => rent_incr.rent_incr_term_id,
                        X_INCLUDE_TERM      => 'Y',
                        X_INCLUDE_INCREASES => 'Y',
                        X_UPDATE_FLAG       => NULL,
                        X_CREATION_DATE     => sysdate,
                        X_CREATED_BY        => NVL(fnd_profile.value('USER_ID'),-1),
                        X_LAST_UPDATE_DATE  => sysdate,
                        X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
                        X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1),
                        X_ORG_ID            => l_org_id  );

             END IF;

          END LOOP;

     END LOOP;
  END IF;
END LOOP;
pnp_debug_pkg.log('+++++++++ include_increases END +++++++++++');
END include_increases;

--------------------------------------------------------------------------------
--  NAME         : post_summary - global procedure
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      : 5/Dec/2006 Shabda Populate deductions in var_rent_summ_all
--                 fix for bug 5679847
--
--  dd-mon-yyyy  name     o Created
--  21-MAY-07    Lokesh   o Added rounding off for bug # 6031202 in
--                          pn_var_rent_summ_all
--------------------------------------------------------------------------------
PROCEDURE post_summary ( p_var_rent_id  IN NUMBER
                        ,p_period_id    IN NUMBER)
IS

  /* get all lines */
  CURSOR lines_c( p_vr_id  IN NUMBER
                 ,p_prd_id IN NUMBER) IS
    SELECT
    line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id;

  /* get grp date */
  CURSOR grp_date_c( p_vr_id  IN NUMBER
                    ,p_prd_id IN NUMBER) IS
    SELECT
     grp.grp_date_id
    ,grp.group_date
    ,grp.invoice_date
    ,grp.org_id
    FROM
     pn_var_grp_dates_all grp
    ,pn_var_periods_all   prd
    WHERE
    prd.var_rent_id = p_vr_id  AND
    prd.period_id   = p_prd_id AND
    grp.period_id   = prd.period_id AND
    grp.grp_end_date <= prd.end_date;

  TYPE GRP_TBL IS TABLE OF grp_date_c%ROWTYPE INDEX BY BINARY_INTEGER;
  l_grp_t GRP_TBL;

  /* Get rent and volume to store in pn_var_rent_summ_all */
  CURSOR summ_c( p_vr_id   IN NUMBER
                ,p_prd_id  IN NUMBER
                ,p_line_id IN NUMBER
                ,p_grp_id  IN NUMBER) IS
    SELECT
     NVL(SUM(hdr.percent_rent_due),0)
     + NVL(SUM(DECODE(hdr.invoice_flag
                      ,'I',hdr.prorated_rent_due
                          ,0
                     )
              ), 0) AS rent
    ,NVL(SUM(hdr.prorated_group_sales)
         , 0) AS sales
    ,NVL(SUM(hdr.prorated_group_deductions)
         , 0) AS ded
    ,NVL(SUM(hdr.first_yr_rent), 0) AS first_yr_rent
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id  = p_vr_id AND
    hdr.period_id    = p_prd_id AND
    hdr.line_item_id = p_line_id AND
    hdr.grp_date_id  = p_grp_id;

  /* exists VR summ record */
  CURSOR vr_summ_c ( p_vr_id  IN NUMBER
                    ,p_prd_id IN NUMBER
                    ,p_line_id IN NUMBER
                    ,p_grp_id IN NUMBER) IS
    SELECT
     var_rent_summ_id
    ,tot_act_vol
    ,tot_ded
    ,act_var_rent
    ,first_yr_rent
    FROM
    pn_var_rent_summ_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    line_item_id = p_line_id AND
    grp_date_id = p_grp_id;

  l_vr_summ_id NUMBER;

BEGIN

  pnp_debug_pkg.log('+++++++++ post_summary START +++++++++++');

  l_grp_t.DELETE;

  OPEN grp_date_c( p_vr_id  => p_var_rent_id
                  ,p_prd_id => p_period_id);
  FETCH grp_date_c BULK COLLECT INTO l_grp_t;
  CLOSE grp_date_c;

  /* loop for all lines in the annual period */
  FOR line_rec IN lines_c( p_vr_id  => p_var_rent_id
                          ,p_prd_id => p_period_id)
  LOOP

    pnp_debug_pkg.log('line_rec.line_item_id...'||line_rec.line_item_id);
    /* loop for all calc periods in the annual period */
    FOR g IN 1..l_grp_t.COUNT LOOP

      /* get the sum of rents and sales for
         vr -> period -> line item -> group combination
         from the trx tables
         -- loops only once --
      */
      pnp_debug_pkg.log('g..'||g);
      FOR summ_rec IN summ_c( p_vr_id   => p_var_rent_id
                             ,p_prd_id  => p_period_id
                             ,p_line_id => line_rec.line_item_id
                             ,p_grp_id  => l_grp_t(g).grp_date_id)
      LOOP

        pnp_debug_pkg.log('summ_rec.sales..'||summ_rec.sales);
        pnp_debug_pkg.log('summ_rec.rent..'||summ_rec.rent);
        pnp_debug_pkg.log('summ_rec.first_yr_rent..'||summ_rec.first_yr_rent);
        l_vr_summ_id := NULL;

        /* chk if VR SUMM record exists for this
           vr -> period -> line item -> group combination */
        FOR vr_summ_rec IN vr_summ_c( p_vr_id   => p_var_rent_id
                                     ,p_prd_id  => p_period_id
                                     ,p_line_id => line_rec.line_item_id
                                     ,p_grp_id  => l_grp_t(g).grp_date_id)
        LOOP

          l_vr_summ_id := vr_summ_rec.var_rent_summ_id;

        pnp_debug_pkg.log('l_vr_summ_id..'||l_vr_summ_id);

          IF summ_rec.sales <> NVL(vr_summ_rec.tot_act_vol, 0) OR
             summ_rec.rent  <> NVL(vr_summ_rec.act_var_rent, 0) OR
             summ_rec.first_yr_rent  <> NVL(vr_summ_rec.first_yr_rent, 0) OR
             NVL(summ_rec.ded, 0)  <> NVL(vr_summ_rec.tot_ded, 0)
          THEN

           pnp_debug_pkg.log('before updation ...');
            UPDATE
            pn_var_rent_summ_all
            SET
             tot_act_vol  = summ_rec.sales
            ,tot_ded      = summ_rec.ded
            ,act_var_rent = round(summ_rec.rent,g_precision)
            ,first_yr_rent = round(summ_rec.first_yr_rent,g_precision)
            ,last_update_date  = SYSDATE
            ,last_updated_by   = NVL(fnd_global.user_id, 0)
            ,last_update_login = NVL(fnd_global.login_id, 0)
            WHERE
            var_rent_summ_id = l_vr_summ_id;

          END IF;

        END LOOP; /* chk if VR SUMM exists vr -> prd -> line -> grp combo */

        IF l_vr_summ_id IS NULL THEN

       pnp_debug_pkg.log('before insertion ...');

          /* to insert a new summary record */
          INSERT INTO
          pn_var_rent_summ_all
            (var_rent_summ_id
            ,var_rent_id
            ,period_id
            ,line_item_id
            ,invoice_date
            ,tot_act_vol
            ,tot_ded
            ,act_var_rent
            ,grp_date_id
            ,group_date
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,org_id
            ,first_yr_rent)
          VALUES
            (pn_var_rent_summ_s.NEXTVAL
            ,p_var_rent_id
            ,p_period_id
            ,line_rec.line_item_id
            ,l_grp_t(g).invoice_date
            ,summ_rec.sales
            ,summ_rec.ded
            ,round(summ_rec.rent,g_precision)
            ,l_grp_t(g).grp_date_id
            ,l_grp_t(g).group_date
            ,SYSDATE
            ,NVL(fnd_global.user_id, 0)
            ,SYSDATE
            ,NVL(fnd_global.user_id, 0)
            ,NVL(fnd_global.login_id, 0)
            ,NVL(l_grp_t(g).org_id, g_org_id)
            ,round(summ_rec.first_yr_rent,g_precision))
          RETURNING
          var_rent_summ_id
          INTO
          l_vr_summ_id;

        END IF;

        UPDATE
        pn_var_trx_headers_all hdr
        SET
        hdr.var_rent_summ_id = l_vr_summ_id
        WHERE
        hdr.var_rent_id  = p_var_rent_id AND
        hdr.period_id    = p_period_id AND
        hdr.line_item_id = line_rec.line_item_id AND
        hdr.grp_date_id  = l_grp_t(g).grp_date_id;

        EXIT;

      END LOOP; /* get the sum of rents and sales for
                   vr -> period -> line item -> group combination */

    END LOOP; /* loop for all calc periods in the annual period */

  END LOOP; /* loop for all lines in the annual period */

  pnp_debug_pkg.log('+++++++++ post_summary END +++++++++++');

EXCEPTION
  WHEN OTHERS THEN RAISE;

END post_summary;

--------------------------------------------------------------------------------
--  NAME         : forecasted_var_rent
--  DESCRIPTION  : Returns the Forecasted rent for a particular period
--  PURPOSE      :
--  INVOKED FROM : Form view of Annual periods  Tab
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  3.Dec.06  rdonthul    o Created
--------------------------------------------------------------------------------
FUNCTION forecasted_var_rent ( p_var_rent_id IN NUMBER
                            , p_period_id  IN NUMBER )
RETURN NUMBER IS

  CURSOR var_rent_type ( l_var_rent_id  IN NUMBER ) IS
    SELECT invoice_on
    FROM pn_var_rents_all
    WHERE var_rent_id = l_var_rent_id
    AND invoice_on = 'FORECASTED';


  CURSOR var_for_rent ( l_period_id IN NUMBER ) IS
    SELECT sum(decode(adjust_num,0,
                      FOR_PER_RENT,0)) for_var_rent
      FROM pn_var_rent_inv_all
      WHERE period_id = l_period_id;

  l_for_rent       NUMBER := NULL;

BEGIN
   FOR rec_var_rent_type IN var_rent_type( p_var_rent_id )
   LOOP

     FOR rec_var_for_rent IN var_for_rent( p_period_id )
     LOOP
         l_for_rent := rec_var_for_rent.for_var_rent;
     END LOOP;

   END LOOP;

   RETURN l_for_rent;

END forecasted_var_rent;

--------------------------------------------------------------------------------
--  NAME         : get_currency_precision
--  DESCRIPTION  : Returns the Currency precision to be followed bsed on the
--                 org_id
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  1.Mar.07  rdonthul    o Created
--------------------------------------------------------------------------------
FUNCTION get_currency_precision (p_org_id NUMBER)
RETURN NUMBER IS

CURSOR csr_currency_code(p_org_id IN NUMBER) is
  SELECT currency_code
  FROM  gl_sets_of_books
  WHERE set_of_books_id = pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',p_org_ID);

l_org_id               NUMBER := pn_mo_cache_utils.get_current_org_id;
l_currency_code        gl_sets_of_books.currency_code%TYPE;
l_precision            NUMBER := NULL;
l_ext_precision        NUMBER;
l_min_acct_unit        NUMBER;


BEGIN
   IF p_org_id IS NOT NULL THEN
       l_org_id := p_org_id;
   END IF;

   FOR rec_currency_code IN csr_currency_code( l_org_id )
   LOOP
        l_currency_code    := rec_currency_code.currency_code;
   END LOOP;

   fnd_currency.get_info(l_currency_code, l_precision,l_ext_precision, l_min_acct_unit);

   RETURN l_precision;

END get_currency_precision;
--------------------------------------------------------------------------------
--  NAME         : check_last_calc_prd
--  DESCRIPTION  : Determines the last calculation period for an invoice
--  PURPOSE      :
--  INVOKED FROM : VR summary and detail report
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  7-MAR-07  lbala    o Created
--------------------------------------------------------------------------------
FUNCTION check_last_calc_prd(p_trx_hdr_id IN NUMBER,
                             p_prorul     IN VARCHAR2
                             )
RETURN NUMBER
IS
-- Get the details of
CURSOR trx_cur
IS
SELECT var_rent_id,period_id,grp_date_id,calc_prd_start_date
FROM pn_var_trx_headers_All
WHERE trx_header_id=p_trx_hdr_id;

-- Get the details of
CURSOR grp_date_cur(p_prd_id IN NUMBER,
                    p_grp_dt_id IN NUMBER
                   ) IS
SELECT inv_start_date
  FROM pn_var_grp_dates_all gd
 WHERE gd.period_id = p_prd_id
   AND gd.grp_date_id = p_grp_dt_id;

-- Get the details of
CURSOR calc_prd_cur(p_prd_id IN NUMBER,
                    p_inv_end_dt IN DATE
                   ) IS
  SELECT max(calc_prd_start_date) calc_prd_st_dt
    FROM pn_var_trx_headers_all trx
   WHERE trx.calc_prd_end_date <= p_inv_end_dt
     AND trx.period_id = p_prd_id;

l_vr_id  NUMBER :=NULL;
l_prd_id NUMBER :=NULL;
l_gd_id  NUMBER :=NULL;
l_st_dt  DATE   :=NULL;
l_inv_end_dt DATE :=NULL;
l_inv_st_dt DATE :=NULL;
l_max_calc_prd_dt DATE :=NULL;

BEGIN

 FOR trx_rec IN trx_cur LOOP
  l_vr_id  := trx_rec.var_rent_id;
  l_prd_id := trx_rec.period_id;
  l_gd_id  := trx_rec.grp_date_id;
  l_st_dt  := trx_rec.calc_prd_start_date;
 END LOOP;

 FOR gd_rec IN grp_date_cur(l_prd_id,l_gd_id)LOOP
    l_inv_st_dt  := gd_rec.inv_start_date;
 END LOOP;

 l_inv_end_dt := pn_var_rent_calc_pkg.inv_end_date(l_inv_st_dt
                                                  ,l_vr_id
                                                  ,l_prd_id
                                                  );

 FOR calc_prd_rec IN calc_prd_cur(l_prd_id,l_inv_end_dt) LOOP
  l_max_calc_prd_dt := calc_prd_rec.calc_prd_st_dt;
 END LOOP;

 IF l_st_dt = l_max_calc_prd_dt THEN
    RETURN 1;
 ELSE RETURN 0;
 END IF;

END check_last_calc_prd;

--------------------------------------------------------------------------------
--  NAME         : get_cum_rent_due
--  DESCRIPTION  : Gets the rent due for each transaction detail record
--  PURPOSE      :
--  INVOKED FROM : VR detail and summary report
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  7-MAR-07  lbala    o Created
--------------------------------------------------------------------------------
FUNCTION get_rent_due(p_trx_hdr_id IN NUMBER,
                      p_prorul     IN VARCHAR2
                      )
RETURN NUMBER
IS
-- Get the details of
CURSOR trx_cur
IS
SELECT var_rent_id,period_id,grp_date_id,calc_prd_start_date
FROM pn_var_trx_headers_All
WHERE trx_header_id=p_trx_hdr_id;

-- Get the details of
CURSOR grp_date_cur(p_prd_id IN NUMBER,
                    p_grp_dt_id IN NUMBER
                   )
IS
SELECT invoice_date
  FROM pn_var_grp_dates_all gd
 WHERE gd.period_id = p_prd_id
   AND gd.grp_date_id = p_grp_dt_id;

CURSOR period_cur(vr_id IN NUMBER) IS
  SELECT period_id, start_date
  FROM pn_var_periods_all
  WHERE var_rent_id = vr_id
  AND partial_period = 'Y'
  AND period_num = 1;

CURSOR get_act_inv_amt(p_prd_id IN NUMBER,
                       p_inv_dt IN DATE
                       )
IS
SELECT SUM(rent_inv.ACTUAL_INVOICED_AMOUNT) act_inv_amt
FROM pn_var_rent_inv_all rent_inv
WHERE rent_inv.period_id = p_prd_id
AND (rent_inv.invoice_date = p_inv_dt OR p_inv_dt IS NULL);

l_vr_id  NUMBER :=NULL;
l_prd_id NUMBER :=NULL;
l_gd_id  NUMBER :=NULL;
l_st_dt  DATE   :=NULL;
l_inv_dt DATE :=NULL;
l_max_calc_prd_dt DATE :=NULL;
l_rent_due NUMBER:=NULL;

BEGIN

 FOR trx_rec IN trx_cur LOOP
  l_vr_id  := trx_rec.var_rent_id;
  l_prd_id := trx_rec.period_id;
  l_gd_id  := trx_rec.grp_date_id;
 END LOOP;

 FOR gd_rec IN grp_date_cur(l_prd_id,l_gd_id)LOOP
  l_inv_dt  := gd_rec.invoice_date;
 END LOOP;

 IF p_prorul IN ('FY','FLY') THEN
   FOR rec IN period_cur(l_vr_id) LOOP
      IF(rec.period_id = l_prd_id) THEN

        FOR rec1 IN get_act_inv_amt(l_prd_id,NULL) LOOP
          l_rent_due := rec1.act_inv_amt;
        END LOOP;
        RETURN l_rent_due;

      END IF;
   END LOOP;

 END IF;

 FOR rec1 IN get_act_inv_amt(l_prd_id,l_inv_dt) LOOP
     l_rent_due := rec1.act_inv_amt;
 END LOOP;
 RETURN l_rent_due;

END get_rent_due;

--------------------------------------------------------------------------------
--  NAME         : get_cum_rent_due
--  DESCRIPTION  : Gets the cumulative rent for each transaction detail record
--  PURPOSE      :
--  INVOKED FROM : VR detail and summary report
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  7-MAR-07  lbala    o Created
--------------------------------------------------------------------------------
FUNCTION get_cum_rent_due(p_trx_hdr_id IN NUMBER,
                          p_prorul     IN VARCHAR2
                         )
RETURN NUMBER
IS
-- Get the details of
CURSOR trx_cur
IS
SELECT var_rent_id,period_id,grp_date_id,calc_prd_start_date
FROM pn_var_trx_headers_All
WHERE trx_header_id=p_trx_hdr_id;

-- Get the details of
CURSOR grp_date_cur(p_prd_id IN NUMBER,
                    p_grp_dt_id IN NUMBER
                   )
IS
SELECT invoice_date
FROM pn_var_grp_dates_all gd
WHERE gd.period_id = p_prd_id
AND gd.grp_date_id = p_grp_dt_id;

CURSOR period_cur(vr_id IN NUMBER)
IS
SELECT period_id, start_date
FROM pn_var_periods_all
WHERE var_rent_id = vr_id
AND partial_period = 'Y'
AND period_num = 1;

CURSOR get_act_inv_amt(p_prd_id IN NUMBER,
                       p_inv_dt IN DATE
                       )
IS
SELECT SUM(rent_inv.ACTUAL_INVOICED_AMOUNT) act_inv_amt
FROM pn_var_rent_inv_all rent_inv
WHERE rent_inv.period_id = p_prd_id
AND (rent_inv.invoice_date <= p_inv_dt OR p_inv_dt IS NULL);

l_vr_id  NUMBER :=NULL;
l_prd_id NUMBER :=NULL;
l_gd_id  NUMBER :=NULL;
l_st_dt  DATE   :=NULL;
l_inv_dt DATE :=NULL;
l_max_calc_prd_dt DATE :=NULL;
l_cum_rent_due NUMBER:=NULL;

BEGIN

 FOR trx_rec IN trx_cur LOOP
  l_vr_id  := trx_rec.var_rent_id;
  l_prd_id := trx_rec.period_id;
  l_gd_id  := trx_rec.grp_date_id;
 END LOOP;

 FOR gd_rec IN grp_date_cur(l_prd_id,l_gd_id)LOOP
  l_inv_dt  := gd_rec.invoice_date;
 END LOOP;

 IF p_prorul IN ('FY','FLY') THEN
   FOR rec IN period_cur(l_vr_id) LOOP
      IF(rec.period_id = l_prd_id) THEN

        FOR rec1 IN get_act_inv_amt(l_prd_id,NULL) LOOP
          l_cum_rent_due := rec1.act_inv_amt;
        END LOOP;
        RETURN l_cum_rent_due;

      END IF;
   END LOOP;

 END IF;

 FOR rec1 IN get_act_inv_amt(l_prd_id,l_inv_dt) LOOP
     l_cum_rent_due := rec1.act_inv_amt;
 END LOOP;
 RETURN l_cum_rent_due;

END get_cum_rent_due;

--------------------------------------------------------------------------------
--  NAME         : INCLUDE_PRD_NO_TERM
--  DESCRIPTION  : Determines whether the period has all 0 rent invoices
--  PURPOSE      :
--  INVOKED FROM : VR detail and summary report
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  7-MAR-07  lbala    o Created
--------------------------------------------------------------------------------
FUNCTION include_prd_no_term(p_prd_id IN NUMBER
                           )
RETURN VARCHAR2 IS
-- Get the details of
CURSOR incl_prd(p_prd_id IN NUMBER)
IS
SELECT 'y' AS include_flag
FROM DUAL
WHERE NOT EXISTS (SELECT NULL
                  FROM pn_var_rent_inv_all vinv
                  WHERE vinv.ACTUAL_INVOICED_AMOUNT <> 0
                  AND vinv.period_id = p_prd_id
                 );
l_include VARCHAR2(1):= 'n';
BEGIN

FOR rec IN incl_prd(p_prd_id) LOOP
 l_include := rec.include_flag;
END LOOP;

RETURN l_include;
END include_prd_no_term;


--------------------------------------------------------------------------------
--  NAME         : delete_draft_terms
--  DESCRIPTION  : deletes the draft term for which invoice_date or term
--                 template has changed.
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  8.Mar.07  piagrawa    o Created
--------------------------------------------------------------------------------
PROCEDURE delete_draft_terms( p_var_rent_id IN NUMBER) IS

   /* get term template id for variable rent */
   CURSOR template_cur IS
      SELECT term_template_id
      FROM pn_var_rents_all
      WHERE var_rent_id = p_var_rent_id;

   /* get invoice dates for variable rent */
   CURSOR invoice_cur( p_vr_id  IN NUMBER) IS
      SELECT
      invoice_date, period_id
      FROM
      pn_var_rent_summ_all
      WHERE
      var_rent_id = p_vr_id
      GROUP BY
      invoice_date, period_id
      ORDER BY
      invoice_date;

  /* get latest invoice */
  CURSOR invoice2upd_c( p_vr_id  IN NUMBER
                       ,p_prd_id IN NUMBER
                       ,p_inv_dt IN DATE
                       ,p_inv_sch_date DATE
                       ,p_term_template_id NUMBER) IS
    SELECT inv.var_rent_inv_id
    FROM
    pn_var_rent_inv_all inv
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id AND
    invoice_date = p_inv_dt AND
    EXISTS (SELECT term.payment_term_id
            FROM pn_payment_terms_all term
            WHERE term.var_rent_inv_id = inv.var_rent_inv_id
            AND status = 'DRAFT'
            AND (start_date <> p_inv_sch_date OR
                 term_template_id <> p_term_template_id));

  /* get invoice dates for a period */
   /*CURSOR payment_cur (p_inv_sch_date DATE,
                       p_term_template_id NUMBER) IS
      SELECT payment_term_id, var_rent_inv_id
      FROM pn_payment_terms_all
      WHERE var_rent_inv_id IN (SELECT var_rent_inv_id
                                FROM pn_var_rent_inv_all
                                WHERE var_rent_id = p_var_rent_id)
      AND status = 'DRAFT'
      AND (start_date <> p_inv_sch_date OR
           term_template_id <> p_term_template_id);*/

   l_inv_start_date           DATE;
   l_payment_start_date       DATE;
   l_term_template_id         NUMBER;

BEGIN

   FOR term_temp_rec IN template_cur LOOP
      l_term_template_id := term_temp_rec.term_template_id;
   END LOOP;

   FOR inv_rec IN invoice_cur (p_var_rent_id)
   LOOP

      /*l_inv_start_date := pn_var_rent_calc_pkg.inv_start_date(inv_start_date => inv_rec.invoice_date
                                                               ,vr_id => p_var_rent_id
                                                               ,approved_status => 'N'); */

      l_payment_start_date := pn_var_rent_calc_pkg.inv_sch_date(inv_start_date => inv_rec.invoice_date
                                                               ,vr_id => p_var_rent_id
                                                               ,p_period_id => inv_rec.period_id);

      FOR rec IN invoice2upd_c ( p_var_rent_id
                               , inv_rec.period_id
                               , inv_rec.invoice_date
                               , l_payment_start_date
                               , l_term_template_id) LOOP

         DELETE
         pn_payment_terms_all
         WHERE
         var_rent_inv_id = rec.var_rent_inv_id
         AND status = 'DRAFT'
         AND (start_date <> l_payment_start_date OR
             term_template_id <> l_term_template_id);

         IF(g_invoice_on=G_INV_ON_ACTUAL) THEN

            /* update the invoice */
            /*Since forcasted rents are not yet exported, we can update them.*/
            UPDATE
            pn_var_rent_inv_all
            SET
            actual_term_status      = 'N'
            ,last_update_date       = SYSDATE
            ,last_updated_by        = NVL(fnd_global.user_id,0)
            ,last_update_login      = NVL(fnd_global.login_id,0)
            WHERE
            var_rent_inv_id = rec.var_rent_inv_id;

         ELSIF (g_invoice_on = G_INV_ON_FORECASTED AND g_calc_type = G_CALC_TYPE_CALCULATE) THEN

            /* update the invoice */
            /*Since forcasted rents are not yet exported, we can update them.*/
            UPDATE
            pn_var_rent_inv_all
            SET
            forecasted_term_status  = 'N'
            ,last_update_date       = SYSDATE
            ,last_updated_by        = NVL(fnd_global.user_id,0)
            ,last_update_login      = NVL(fnd_global.login_id,0)
            WHERE
            var_rent_inv_id = rec.var_rent_inv_id;

         ELSIF (g_invoice_on = G_INV_ON_FORECASTED AND g_calc_type = G_CALC_TYPE_RECONCILE) THEN

            /* update the invoice */
            /*Since forcasted rents are not yet exported, we can update them.*/
            UPDATE
            pn_var_rent_inv_all
            SET
            actual_term_status      = 'N'
            ,last_update_date       = SYSDATE
            ,last_updated_by        = NVL(fnd_global.user_id,0)
            ,last_update_login      = NVL(fnd_global.login_id,0)
            WHERE
            var_rent_inv_id = rec.var_rent_inv_id;

         END IF;

      END LOOP;
   END LOOP;

END delete_draft_terms;

--------------------------------------------------------------------------------
--  NAME         : actual_rent
--  DESCRIPTION  : returns the actual rent for the given invoice period.
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
-- 21.Mar.07  Ram kumar    o Created
--------------------------------------------------------------------------------
FUNCTION actual_rent ( p_period_id IN NUMBER, p_invoice_date IN DATE, p_true_up_amt IN NUMBER, p_var_rent_inv_id IN NUMBER)
RETURN NUMBER IS

CURSOR csr_get_inv IS
 SELECT sum(actual_invoiced_amount) AS actual_rent
 FROM pn_var_rent_inv_all
 WHERE period_id = p_period_id
 AND invoice_date = p_invoice_date
 AND var_rent_inv_id <= p_var_rent_inv_id
 AND true_up_amt IS NULL;

CURSOR csr_get_true IS
 SELECT constr_actual_rent
 FROM pn_var_rent_inv_all
 WHERE invoice_date = p_invoice_date
 AND true_up_amt IS NOT NULL
 AND var_rent_inv_id = p_var_rent_inv_id;

l_actual_rent  NUMBER;

BEGIN

   IF p_true_up_amt IS NULL THEN
     FOR rec_get_inv IN csr_get_inv LOOP
       l_actual_rent := rec_get_inv.actual_rent;
     END LOOP;
   ELSE
     FOR rec_get_true IN csr_get_true LOOP
       l_actual_rent := rec_get_true.constr_actual_rent;
     END LOOP;
   END IF;

   RETURN l_actual_rent;

END actual_rent;

--------------------------------------------------------------------------------
--
--  NAME         : VALIDATE_LY_CALC()
--  DESCRIPTION  : Validates if a period is last period for an an agreement
--                 which is less than 24 months long, has a proration rule of
--                 FLY, has 2 periods both of which are partial
--
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--   27-FEB-07 piagrawa   o Created
--------------------------------------------------------------------------------
FUNCTION VALIDATE_LY_CALC (p_varRentId NUMBER, p_periodId  IN NUMBER)
RETURN NUMBER
IS

  /* verifying if agreement's length is less than 24 */
  CURSOR vr_length IS
      SELECT var_rent_id, proration_rule, termination_date
      FROM pn_var_rents_all
      WHERE var_rent_id = p_varRentId
      AND proration_rule = 'FLY'
      AND MONTHS_BETWEEN(commencement_date, termination_date) < 24;

  /* get the number of periods */
  CURSOR period_num_c ( p_vr_id IN NUMBER, term_date DATE) IS
      SELECT count(*) period_num
      FROM pn_var_periods_all
      WHERE var_rent_id = p_vr_id
      AND term_date > start_date;

  /* verify if last period for variable rent agreement is partial */
  CURSOR last_period_c (p_vr_id NUMBER, p_new_term_date DATE) IS
    SELECT period_id
    FROM pn_var_periods_all
    WHERE var_rent_id = p_vr_id
    AND p_new_term_date BETWEEN start_date AND end_date
    AND partial_period = 'Y';

  /* get the first partial period */
  CURSOR first_period_c( p_vr_id     IN NUMBER) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd,
    pn_var_rents_all   var
    WHERE
    prd.var_rent_id = p_vr_id AND
    prd.var_rent_id = var.var_rent_id AND
    prd.start_date = var.commencement_date AND
    prd.partial_period = 'Y';

   l_first_partial VARCHAR2(1);
   l_last_partial  VARCHAR2(1);
   l_last_periodId NUMBER;
   l_period_num    NUMBER  := 0;
   l_ly_calc       NUMBER := NULL;
   l_new_term_date DATE;

BEGIN
   pnp_debug_pkg.log('+++++++++ VALIDATE_LY_CALC START +++++++++++');

   FOR vr_length_rec IN vr_length
   LOOP

      FOR period_num_rec IN period_num_c (p_varRentId, vr_length_rec.termination_date)
      LOOP
         l_period_num := period_num_rec.period_num;
      END LOOP;

      FOR first_period_rec IN first_period_c (p_varRentId)
      LOOP
         l_first_partial := first_period_rec.partial_period;
      END LOOP;

      FOR last_period_rec IN last_period_c (p_varRentId, vr_length_rec.termination_date )
      LOOP
         l_last_partial := 'Y';
         l_last_periodId := last_period_rec.period_id;
      END LOOP;

     /* IMP: when we have just 2 periods and first year and last year period is
        partial, in such a case we would not be calculating last year rent. */
      IF l_period_num = 2 AND l_first_partial = 'Y' AND
        l_last_partial = 'Y' AND l_last_periodId = p_periodId
      THEN
         l_ly_calc := p_periodId;
      END IF;


   END LOOP;

   return l_ly_calc;

   pnp_debug_pkg.log('+++++++++ VALIDATE_LY_CALC END +++++++++++');

END VALIDATE_LY_CALC;
--------------------------------------------------------------------------------
--  NAME         : full_yr_summary
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
-- 16.Apr.07  Ram kumar    o Created
--------------------------------------------------------------------------------
PROCEDURE full_yr_summary ( p_line_item_id      IN NUMBER
                           ,p_yr_volume         OUT NOCOPY  NUMBER
                           ,p_deductions        OUT NOCOPY  NUMBER)
IS

CURSOR full_yr_cur IS
  SELECT  sum(NVL(tot_act_vol, 0)) yr_vol,
          sum(NVL(tot_ded, 0)) yr_deductions
  FROM   pn_var_rent_summ_all
  WHERE  line_item_id = p_line_item_id;

BEGIN

   FOR yr_rec IN full_yr_cur LOOP
      p_yr_volume     := yr_rec.yr_vol;
      p_deductions    := yr_rec.yr_deductions;
   END LOOP;

END full_yr_summary;

--------------------------------------------------------------------------------
--  NAME         : trueup_rent
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
-- 19.Apr.07  Ram kumar    o Created
--------------------------------------------------------------------------------
FUNCTION trueup_rent ( p_var_rent_id IN NUMBER
                      ,p_period_id   IN NUMBER
                      ,p_grp_date_id IN NUMBER)
RETURN NUMBER
IS

  CURSOR trueup_rent_c IS
    SELECT
     SUM(trueup_rent_due)         AS trueup_rent
    ,MAX(calc_prd_end_date)       AS trueup_date
    ,line_item_id
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_var_rent_id AND
    period_id = p_period_id
    GROUP BY
    line_item_id
    ORDER BY
    line_item_id;

  -- Get the details of
  CURSOR trueup_end_date_c  IS
    SELECT grp_end_date
      FROM pn_var_grp_dates_all
     WHERE grp_date_id = p_grp_date_id;

  l_trueup_rent        NUMBER := 0;
  l_trueup_date        DATE;
  l_grp_end_date       DATE;

BEGIN

  FOR trueup_rec IN trueup_rent_c  LOOP
    l_trueup_rent := trueup_rec.trueup_rent;
    l_trueup_date := trueup_rec.trueup_date;
  END LOOP;

  FOR trueup_date_rec IN trueup_end_date_c  LOOP
    l_grp_end_date := trueup_date_rec.grp_end_date;
  END LOOP;


  IF l_grp_end_date = l_trueup_date THEN
    RETURN l_trueup_rent;
  ELSE
    RETURN NULL;
  END IF;

END trueup_rent;
--------------------------------------------------------------------------------
--  NAME         : true_up_bkpt
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
-- 25.Apr.07  Ram kumar    o Created
--------------------------------------------------------------------------------
PROCEDURE true_up_bkpt ( p_period_id      IN NUMBER
                        ,p_bkpt_rate      IN NUMBER
                        ,p_bkpt_vol_start OUT NOCOPY  NUMBER
                        ,p_bkpt_vol_end   OUT NOCOPY  NUMBER)
IS

CURSOR get_period_dtls_csr IS
  SELECT  period_num,var_rent_id
  FROM pn_var_periods_all
  WHERE period_id = p_period_id;

CURSOR get_blended_bkpt_csr(p_var_rent_id IN NUMBER) IS
  SELECT sum(pr_grp_blended_vol_start) bkpt_start,
         sum(pr_grp_blended_vol_end) bkpt_end
  FROM pn_var_trx_details_all dtls,
       pn_var_trx_headers_all hdr
  WHERE var_rent_id = p_var_rent_id
  AND hdr.trx_header_id = dtls.trx_header_id
  AND dtls.bkpt_rate = p_bkpt_rate
  GROUP BY dtls.bkpt_rate;

l_var_rent_id  NUMBER;
l_period_num   NUMBER;
l_bkpt_start   NUMBER;
l_bkpt_end     NUMBER;

BEGIN

--
FOR rec_prd_details IN get_period_dtls_csr LOOP
  l_period_num := rec_prd_details.period_num;
  l_var_rent_id := rec_prd_details.var_rent_id;
END LOOP;

FOR rec_blended_bkpt IN get_blended_bkpt_csr(l_var_rent_id) LOOP
  p_bkpt_vol_start  := rec_blended_bkpt.bkpt_start;
  p_bkpt_vol_end    := rec_blended_bkpt.bkpt_end;
END LOOP;

IF l_period_num NOT IN (1,2) THEN
  p_bkpt_vol_start := NULL;
  p_bkpt_vol_end := NULL;
END IF;

END true_up_bkpt;

--------------------------------------------------------------------------------
--  NAME         : new_term_amount
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
-- 30.May.07  Ram kumar    o Created
--------------------------------------------------------------------------------
FUNCTION new_term_amount ( p_invoice_date IN DATE
                          ,p_period_id   IN NUMBER
                          ,p_var_rent_inv_id IN NUMBER)
RETURN NUMBER
IS

CURSOR inv_details_cur IS
  SELECT variance_exp_code, actual_exp_code, adjust_num, actual_invoiced_amount, for_per_rent
    FROM pn_var_rent_inv_all
   WHERE period_id = p_period_id
     AND var_rent_inv_id = p_var_rent_inv_id;

BEGIN

FOR rec IN inv_details_cur LOOP

  IF rec.variance_exp_code = 'Y' THEN
    RETURN 0;
  ELSIF rec.actual_exp_code = 'Y' THEN
    RETURN 0;
  ELSIF rec.adjust_num = 0 THEN
    RETURN (rec.actual_invoiced_amount -nvl(rec.for_per_rent,0));
  ELSE
    RETURN rec.actual_invoiced_amount;
  END IF;

END LOOP;

END new_term_amount;

--------------------------------------------------------------------------------
--  NAME         : true_up_header
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
-- 10.July.07  Ram kumar    o Created
--------------------------------------------------------------------------------
FUNCTION true_up_header ( p_period_id           IN NUMBER
                         ,p_trx_hdr_id          IN NUMBER
								 ,p_calc_prd_end_date   IN DATE)
RETURN VARCHAR2
IS

CURSOR trx_header_cur IS
  SELECT max(calc_prd_end_date) end_date
    FROM pn_var_trx_headers_all
   WHERE period_id = p_period_id
   GROUP BY reset_group_id;

CURSOR true_up_cur IS
  SELECT trueup_rent_due
    FROM pn_var_trx_headers_all
   WHERE trx_header_id = p_trx_hdr_id;

l_true_up   VARCHAR2(30)   :=  'N';

BEGIN

FOR rec_true_up IN true_up_cur LOOP
	FOR rec IN trx_header_cur LOOP
	   IF rec.end_date = p_calc_prd_end_date AND rec_true_up.trueup_rent_due IS NOT NULL THEN
			l_true_up := 'Y';
		END IF;
	END LOOP;
END LOOP;

RETURN l_true_up;

END true_up_header;

END pn_var_rent_calc_pkg;


/
