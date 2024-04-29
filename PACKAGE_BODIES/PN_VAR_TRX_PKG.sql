--------------------------------------------------------
--  DDL for Package Body PN_VAR_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_TRX_PKG" AS
-- $Header: PNVRTRXB.pls 120.0.12010000.2 2009/06/25 06:17:38 jsundara ship $
/*
   need to fix the following in PNVRFUNB - replace existing code with the
   code below

   need to add this code to PNVRFUNS/B.pls in the mainline code
*/

/* -------------------------------------------------------------------------
   ------------------------- COMMON DATA STRUCTURES ------------------------
   ------------------------------------------------------------------------- */
TYPE NUM_T IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/* -------------------------------------------------------------------------
   ------------------------- GLOBAL VARIABLES ------------------------------
   ------------------------------------------------------------------------- */
g_precision       NUMBER;

/* -------------------------------------------------------------------------
   -------------------------- CURSORS FOR LOCKING --------------------------
   ------------------------------------------------------------------------- */

/* get all line items for a period */
CURSOR line_items_lock4bkpt_c(p_vr_id IN NUMBER) IS
  SELECT
  line.line_item_id
  FROM
  pn_var_lines_all line
  WHERE
  line.var_rent_id = p_vr_id AND
  line.bkpt_update_flag = 'Y'
  /*FOR UPDATE NOWAIT*/;

/* get all line items for a period */
CURSOR line_items_lock4salesvol_c(p_vr_id IN NUMBER) IS
  SELECT
  line.line_item_id
  FROM
  pn_var_lines_all line
  WHERE
  line.var_rent_id = p_vr_id AND
  line.sales_vol_update_flag = 'Y'
  /*FOR UPDATE NOWAIT*/;

/* get all line items for a periods, and dont lock them */
CURSOR line_items_c(p_vr_id IN NUMBER) IS
  SELECT
  line.line_item_id
  FROM
  pn_var_lines_all line
  WHERE
  line.var_rent_id = p_vr_id
  /*FOR UPDATE NOWAIT*/;

/* -------------------------------------------------------------------------
   ----------------------- PROCEDURES AND FUNCTIONS  -----------------------
   ------------------------------------------------------------------------- */


--------------------------------------------------------------------------------
--  NAME         : get_proration_rule
--  DESCRIPTION  : gets proration rule frm the VR table given VR ID or period ID
--  INVOKED FROM : utility fn - used from several places
--                 PN_VAR_POP_TRX_PKG
--  ARGUMENTS    : p_var_rent_id - VR ID
--                 p_period_id   - Period ID
--  REFERENCE    :
--  HISTORY
--
--  27-Mar-06  Kiran      o Created
--------------------------------------------------------------------------------
FUNCTION get_proration_rule(p_var_rent_id IN NUMBER DEFAULT NULL,
                            p_period_id   IN NUMBER DEFAULT NULL)
RETURN VARCHAR2 IS

  CURSOR proration_rule_vr_c IS
    SELECT proration_rule
      FROM pn_var_rents_all
     WHERE var_rent_id = p_var_rent_id;

  CURSOR proration_rule_prd_c IS
    SELECT proration_rule
      FROM pn_var_rents_all vr
          ,pn_var_periods_all prd
     WHERE vr.var_rent_id = prd.var_rent_id
       AND prd.period_id = p_period_id;

  l_proration_rule VARCHAR2(30);

BEGIN

  l_proration_rule := NULL;

  IF p_var_rent_id IS NOT NULL THEN

    FOR rec IN proration_rule_vr_c LOOP
      l_proration_rule := rec.proration_rule;
    END LOOP;

  ELSIF p_period_id IS NOT NULL THEN

    FOR rec IN proration_rule_prd_c LOOP
      l_proration_rule := rec.proration_rule;
    END LOOP;

  END IF;

  RETURN l_proration_rule;

END get_proration_rule;

--------------------------------------------------------------------------------
--  NAME         : exists_trx_hdr
--  DESCRIPTION  : returns trx hdr ID if found else returns NULL
--  INVOKED FROM : exists_trx_hdr
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION exists_trx_hdr( p_vr_id           IN NUMBER
                        ,p_period_id       IN NUMBER
                        ,p_line_item_id    IN NUMBER
                        ,p_grp_date_id     IN NUMBER
                        ,p_calc_prd_st_dt  IN DATE
                        ,p_calc_prd_end_dt IN DATE)
RETURN NUMBER IS

CURSOR trx_header_exists_c IS
  SELECT
  trx_header_id
  FROM
  pn_var_trx_headers_all
  WHERE
  var_rent_id = p_vr_id AND
  period_id = p_period_id AND
  line_item_id = p_line_item_id AND
  grp_date_id = p_grp_date_id AND
  calc_prd_start_date = p_calc_prd_st_dt AND
  calc_prd_end_date = p_calc_prd_end_dt;

l_trx_hdr_ID NUMBER;

BEGIN

  l_trx_hdr_ID := NULL;

  FOR rec IN trx_header_exists_c LOOP
    l_trx_hdr_ID := rec.trx_header_id;
  END LOOP;

  RETURN l_trx_hdr_ID;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END exists_trx_hdr;

--------------------------------------------------------------------------------
--  NAME         : exists_trx_dtl
--  DESCRIPTION  : returns trx dtl ID if found else returns NULL
--  INVOKED FROM : exists_trx_dtl
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION exists_trx_dtl( p_trx_hdr_id  IN NUMBER
                        ,p_bkpt_dtl_id IN NUMBER)
RETURN NUMBER IS

CURSOR trx_detail_exists_c IS
  SELECT
  trx_detail_id
  FROM
  pn_var_trx_details_all
  WHERE
  trx_header_id = p_trx_hdr_id AND
  bkpt_detail_id = p_bkpt_dtl_id;

l_trx_dtl_ID NUMBER;

BEGIN

  l_trx_dtl_ID := NULL;

  FOR rec IN trx_detail_exists_c LOOP
    l_trx_dtl_ID := rec.trx_detail_id;
  END LOOP;

  RETURN l_trx_dtl_ID;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END exists_trx_dtl;

--------------------------------------------------------------------------------
--  NAME         : insert_trx_hdr
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--  23-MAY-2007  Lokesh   o Added rounding off for Bug # 6031202
--------------------------------------------------------------------------------
PROCEDURE insert_trx_hdr(p_trx_header_id          IN OUT NOCOPY NUMBER
                        ,p_var_rent_id            IN NUMBER
                        ,p_period_id              IN NUMBER
                        ,p_line_item_id           IN NUMBER
                        ,p_grp_date_id            IN NUMBER
                        ,p_calc_prd_start_date    IN DATE
                        ,p_calc_prd_end_date      IN DATE
                        ,p_var_rent_summ_id       IN NUMBER
                        ,p_line_item_group_id     IN NUMBER
                        ,p_reset_group_id         IN NUMBER
                        ,p_proration_factor       IN NUMBER
                        ,p_reporting_group_sales  IN NUMBER
                        ,p_prorated_group_sales   IN NUMBER
                        ,p_ytd_sales              IN NUMBER
                        ,p_fy_proration_sales     IN NUMBER
                        ,p_ly_proration_sales     IN NUMBER
                        ,p_percent_rent_due       IN NUMBER
                        ,p_ytd_percent_rent       IN NUMBER
                        ,p_calculated_rent        IN NUMBER
                        ,p_prorated_rent_due      IN NUMBER
                        ,p_invoice_flag           IN VARCHAR2
                        ,p_org_id                 IN NUMBER
                        ,p_last_update_date       IN DATE
                        ,p_last_updated_by        IN NUMBER
                        ,p_creation_date          IN DATE
                        ,p_created_by             IN NUMBER
                        ,p_last_update_login      IN NUMBER) IS

BEGIN

  INSERT INTO pn_var_trx_headers_all
  (trx_header_id
  ,var_rent_id
  ,period_id
  ,line_item_id
  ,grp_date_id
  ,calc_prd_start_date
  ,calc_prd_end_date
  ,var_rent_summ_id
  ,line_item_group_id
  ,reset_group_id
  ,proration_factor
  ,reporting_group_sales
  ,prorated_group_sales
  ,ytd_sales
  ,fy_proration_sales
  ,ly_proration_sales
  ,percent_rent_due
  ,ytd_percent_rent
  ,calculated_rent
  ,prorated_rent_due
  ,invoice_flag
  ,org_id
  ,last_update_date
  ,last_updated_by
  ,creation_date
  ,created_by
  ,last_update_login)
  VALUES
  (pn_var_trx_headers_S.NEXTVAL
  ,p_var_rent_id
  ,p_period_id
  ,p_line_item_id
  ,p_grp_date_id
  ,p_calc_prd_start_date
  ,p_calc_prd_end_date
  ,p_var_rent_summ_id
  ,p_line_item_group_id
  ,p_reset_group_id
  ,round(p_proration_factor,10)
  ,p_reporting_group_sales
  ,p_prorated_group_sales
  ,p_ytd_sales
  ,p_fy_proration_sales
  ,p_ly_proration_sales
  ,round(p_percent_rent_due,g_precision)  /*Bug # 6031202*/
  ,round(p_ytd_percent_rent,g_precision)
  ,round(p_calculated_rent,g_precision)
  ,round(p_prorated_rent_due,g_precision)
  ,p_invoice_flag
  ,p_org_id
  ,SYSDATE
  ,NVL(fnd_global.user_id,0)
  ,SYSDATE
  ,NVL(fnd_global.user_id,0)
  ,NVL(fnd_global.login_id,0))
  RETURNING trx_header_id INTO p_trx_header_id;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END insert_trx_hdr;

--------------------------------------------------------------------------------
--  NAME         : insert_trx_dtl
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE insert_trx_dtl(p_trx_detail_id            IN OUT NOCOPY NUMBER
                        ,p_trx_header_id            IN NUMBER
                        ,p_bkpt_detail_id           IN NUMBER
                        ,p_bkpt_rate                IN NUMBER
                        ,p_prorated_grp_vol_start   IN NUMBER
                        ,p_prorated_grp_vol_end     IN NUMBER
                        ,p_fy_pr_grp_vol_start      IN NUMBER
                        ,p_fy_pr_grp_vol_end        IN NUMBER
                        ,p_ly_pr_grp_vol_start      IN NUMBER
                        ,p_ly_pr_grp_vol_end        IN NUMBER
                        ,p_pr_grp_blended_vol_start IN NUMBER
                        ,p_pr_grp_blended_vol_end   IN NUMBER
                        ,p_ytd_group_vol_start      IN NUMBER
                        ,p_ytd_group_vol_end        IN NUMBER
                        ,p_blended_period_vol_start IN NUMBER
                        ,p_blended_period_vol_end   IN NUMBER
                        ,p_org_id                   IN NUMBER
                        ,p_last_update_date         IN DATE
                        ,p_last_updated_by          IN NUMBER
                        ,p_creation_date            IN DATE
                        ,p_created_by               IN NUMBER
                        ,p_last_update_login        IN NUMBER) IS

BEGIN

  INSERT INTO pn_var_trx_details_all
  (trx_detail_id
  ,trx_header_id
  ,bkpt_detail_id
  ,bkpt_rate
  ,prorated_grp_vol_start
  ,prorated_grp_vol_end
  ,fy_pr_grp_vol_start
  ,fy_pr_grp_vol_end
  ,ly_pr_grp_vol_start
  ,ly_pr_grp_vol_end
  ,pr_grp_blended_vol_start
  ,pr_grp_blended_vol_end
  ,ytd_group_vol_start
  ,ytd_group_vol_end
  ,blended_period_vol_start
  ,blended_period_vol_end
  ,org_id
  ,last_update_date
  ,last_updated_by
  ,creation_date
  ,created_by
  ,last_update_login)
  VALUES
  (pn_var_trx_details_S.NEXTVAL
  ,p_trx_header_id
  ,p_bkpt_detail_id
  ,p_bkpt_rate
  ,p_prorated_grp_vol_start
  ,p_prorated_grp_vol_end
  ,p_fy_pr_grp_vol_start
  ,p_fy_pr_grp_vol_end
  ,p_ly_pr_grp_vol_start
  ,p_ly_pr_grp_vol_end
  ,p_pr_grp_blended_vol_start
  ,p_pr_grp_blended_vol_end
  ,p_ytd_group_vol_start
  ,p_ytd_group_vol_end
  ,p_blended_period_vol_start
  ,p_blended_period_vol_end
  ,p_org_id
  ,SYSDATE
  ,NVL(fnd_global.user_id,0)
  ,SYSDATE
  ,NVL(fnd_global.user_id,0)
  ,NVL(fnd_global.login_id,0))
  RETURNING trx_detail_id INTO p_trx_detail_id;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END insert_trx_dtl;


/* ----------------------------------------------------------------------
   ----- PROCEDURES TO CREATE TRX HEADERS, DETAILS, POPULATE BKPTS  -----
   ---------------------------------------------------------------------- */


--------------------------------------------------------------------------------
--  NAME         : populate_line_grp_id
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_line_grp_id(p_var_rent_id IN NUMBER) IS

  l_proration_rule VARCHAR2(30);

  /* check if line group ID is already populated */
  CURSOR check_line_grp(p_vr_id IN NUMBER) IS
    SELECT 1
    FROM   dual
    WHERE  EXISTS
           (SELECT
            trx_header_id
            FROM
            pn_var_trx_headers_all
            WHERE
            var_rent_id = p_vr_id AND
            line_item_group_id IS NULL
	    AND rownum = 1);

  l_populate_line_grp BOOLEAN;

  /* get distinct line type-category */
  CURSOR line_type_cat_c(p_vr_id IN NUMBER) IS
    SELECT
     NVL(line.sales_type_code, 'NULL') AS sales_type_code
    ,NVL(line.item_category_code, 'NULL') AS item_category_code
    FROM
    pn_var_lines_all line
    WHERE
    line.var_rent_id = p_vr_id
    GROUP BY
     NVL(line.sales_type_code, 'NULL')
    ,NVL(line.item_category_code, 'NULL');

  l_line_grp_id NUMBER;

BEGIN

  l_populate_line_grp := FALSE;

  FOR rec IN check_line_grp(p_vr_id => p_var_rent_id) LOOP
    l_populate_line_grp := TRUE;
  END LOOP;

  IF l_populate_line_grp THEN

    l_line_grp_id := 1;

    FOR line_typ_rec IN line_type_cat_c(p_vr_id => p_var_rent_id) LOOP

      UPDATE
      pn_var_trx_headers_all
      SET
      line_item_group_id = l_line_grp_id
      WHERE
      line_item_id IN
        ( SELECT
          line.line_item_id
          FROM
          pn_var_lines_all line
          WHERE
          line.var_rent_id = p_var_rent_id AND
          NVL(line.sales_type_code, 'NULL')
            = NVL(line_typ_rec.sales_type_code, 'NULL') AND
          NVL(line.item_category_code, 'NULL')
            = NVL(line_typ_rec.item_category_code, 'NULL')
        );

      l_line_grp_id := l_line_grp_id + 1;

    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_line_grp_id;

--------------------------------------------------------------------------------
--  NAME         : populate_reset_grp_id
--  DESCRIPTION  : populates reset grp ID and proration reset grp ID in the
--                 trx table.
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_reset_grp_id( p_var_rent_id IN NUMBER) IS

  /* get all the trx headers */
  CURSOR trx_hdrs_c(p_vr_id IN NUMBER) IS
    SELECT
     trx_header_id
    ,calc_prd_start_date
    ,line_item_group_id
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
     line_item_group_id
    ,calc_prd_start_date;

  l_line_item_group_id NUMBER;

  /* get rates for a trx header */
  CURSOR bkpt_rates_c(p_trx_hrd_id IN NUMBER) IS
    SELECT
    bkpt_rate
    FROM
    pn_var_trx_details_all
    WHERE
    trx_header_id = p_trx_hrd_id
    ORDER BY
    prorated_grp_vol_start;

  l_hdr_counter   NUMBER;
  l_reset_counter NUMBER;

  rate_tbl_1 NUM_T;
  rate_tbl_2 NUM_T;

  trx_hdr_tbl   NUM_T;
  reset_ctr_tbl NUM_T;

  l_bkpt_changed BOOLEAN;

BEGIN

  /* init counters and tables */
  l_hdr_counter := 0;
  l_reset_counter := 0;

  trx_hdr_tbl.DELETE;
  reset_ctr_tbl.DELETE;

  rate_tbl_1.DELETE;
  rate_tbl_2.DELETE;

  /* loop for all trx headers */
  FOR hdr_rec IN trx_hdrs_c(p_vr_id => p_var_rent_id) LOOP

    l_hdr_counter := l_hdr_counter + 1;

    /* copy current rates to the prev */
    rate_tbl_1.DELETE;

    FOR i IN 1..rate_tbl_2.COUNT LOOP
      rate_tbl_1(i) := rate_tbl_2(i);
    END LOOP;

    /* get new rates */
    rate_tbl_2.DELETE;

    OPEN bkpt_rates_c(hdr_rec.trx_header_id);
    FETCH bkpt_rates_c BULK COLLECT INTO rate_tbl_2;
    CLOSE bkpt_rates_c;

    l_bkpt_changed := FALSE;

    /* check if bkpts changed */
    IF rate_tbl_1.COUNT <> rate_tbl_2.COUNT THEN

      /* bkpts changed if number of bkpt details changed */
      l_bkpt_changed := TRUE;

    ELSE

      FOR i IN 1..rate_tbl_2.COUNT LOOP
        IF rate_tbl_1(i) <> rate_tbl_2(i) THEN
          /* bkpts changed if rate in bkpt details changed */
          l_bkpt_changed := TRUE;
          EXIT;
        END IF;
      END LOOP;

    END IF;

    /* if bkpts changed */
    IF l_bkpt_changed THEN

      /* then, increment reset ctr; init line item grp ID */
      l_reset_counter := l_reset_counter + 1;
      l_line_item_group_id := hdr_rec.line_item_group_id;

    ELSE

      /* else, if line item grp changed */
      IF l_line_item_group_id <> hdr_rec.line_item_group_id THEN

        /* then, increment reset ctr; init line item grp ID */
        l_reset_counter := l_reset_counter + 1;
        l_line_item_group_id := hdr_rec.line_item_group_id;

      END IF;

    END IF;

    /* cache trx hdr ID, reset grp ID */
    trx_hdr_tbl(l_hdr_counter) := hdr_rec.trx_header_id;
    reset_ctr_tbl(l_hdr_counter) := l_reset_counter;

  END LOOP;

  /* update trx hdr, set reset grp ID */
  FORALL hdr_rec IN 1..trx_hdr_tbl.COUNT
    UPDATE
    pn_var_trx_headers_all
    SET
    reset_group_id = reset_ctr_tbl(hdr_rec)
    WHERE
    trx_header_id = trx_hdr_tbl(hdr_rec);

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_reset_grp_id;

--------------------------------------------------------------------------------
--  NAME         : populate_ly_pro_vol
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_ly_pro_vol ( p_var_rent_id        IN NUMBER
                               ,p_proration_rule     IN VARCHAR2
                               ,p_vr_commencement_dt IN DATE
                               ,p_vr_termination_dt  IN DATE) IS

  /* get VR details */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  /* trx header containing LY start date */
  CURSOR trx_ly_c( p_vr_id IN NUMBER
                  ,p_date  IN DATE) IS
    SELECT
     hdr.trx_header_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    p_date BETWEEN (hdr.calc_prd_start_date + 1) AND hdr.calc_prd_end_date;

  l_vr_commencement_date DATE;
  l_vr_termination_date  DATE;
  l_vr_proration_rule    VARCHAR2(30);
  l_ly_start_date        DATE;

  l_proration_factor NUMBER;

  /* get the last partial period */
  CURSOR last_period_c( p_vr_id     IN NUMBER
                       ,p_term_date IN DATE) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd
    WHERE
    prd.var_rent_id = p_var_rent_id AND
    prd.end_date = p_term_date;

  l_last_period_id NUMBER;
  l_partial_period VARCHAR2(1);

BEGIN

  IF p_proration_rule IS NULL OR
     p_vr_commencement_dt IS NULL OR
     p_vr_termination_dt IS NULL
  THEN
    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_vr_commencement_date := vr_rec.commencement_date;
      l_vr_termination_date  := vr_rec.termination_date;
      l_vr_proration_rule    := vr_rec.proration_rule;
    END LOOP;
  ELSE
    l_vr_commencement_date := p_vr_commencement_dt;
    l_vr_termination_date  := p_vr_termination_dt;
    l_vr_proration_rule    := p_proration_rule;
  END IF;

  l_ly_start_date := ADD_MONTHS(l_vr_termination_date, -12) + 1;

  IF l_vr_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_LY
                             ,pn_var_trx_pkg.G_PRORUL_FLY) THEN

    /* -- POPULATE INVOICE FLAG - START -- */
    FOR prd_rec IN last_period_c( p_vr_id     => p_var_rent_id
                                 ,p_term_date => l_vr_termination_date)
    LOOP
      l_last_period_id := prd_rec.period_id;
      l_partial_period := NVL(prd_rec.partial_period, 'N');
    END LOOP;

    /* init invoice flag */
    UPDATE
    pn_var_trx_headers_all
    SET
    invoice_flag = NULL
    WHERE
    var_rent_id = p_var_rent_id AND
    invoice_flag IN ('N', 'I');

    IF l_partial_period = 'Y' THEN

      /* populate invoice flag = N */
      UPDATE
      pn_var_trx_headers_all
      SET
      invoice_flag = 'N'
      WHERE
      var_rent_id = p_var_rent_id AND
      period_id = l_last_period_id;

      /* populate invoice flag = I */
      UPDATE
      pn_var_trx_headers_all
      SET
      invoice_flag = 'I'
      WHERE
      var_rent_id = p_var_rent_id AND
      calc_prd_end_date = l_vr_termination_date;

    END IF;
    /* -- POPULATE INVOICE FLAG - END -- */

    /* -- POPULATE ly_pr_grp_vol_start - ly_pr_grp_vol_end - START -- */

    /* init ly_pr_grp_vol_start - ly_pr_grp_vol_end */
    UPDATE
    pn_var_trx_details_all
    SET
     ly_pr_grp_vol_start = NULL
    ,ly_pr_grp_vol_end   = NULL
    WHERE
    trx_header_id IN (SELECT
                      trx_header_id
                      FROM
                      pn_var_trx_headers_all
                      WHERE
                      var_rent_id = p_var_rent_id);

    IF l_partial_period = 'Y' THEN

      /* populate ly_pr_grp_vol_start - ly_pr_grp_vol_end */
      UPDATE
      pn_var_trx_details_all
      SET
       ly_pr_grp_vol_start = prorated_grp_vol_start
      ,ly_pr_grp_vol_end   = prorated_grp_vol_end
      WHERE
      trx_header_id IN (SELECT
                        trx_header_id
                        FROM
                        pn_var_trx_headers_all
                        WHERE
                        var_rent_id = p_var_rent_id AND
                        calc_prd_start_date >= l_ly_start_date);

      FOR trx_rec IN trx_ly_c( p_vr_id => p_var_rent_id
                              ,p_date  => l_ly_start_date) LOOP

        /* ly proration factor */
        l_proration_factor
          := ((trx_rec.calc_prd_end_date - l_ly_start_date) + 1)
              / ((trx_rec.calc_prd_end_date - trx_rec.calc_prd_start_date) + 1);

        UPDATE
        pn_var_trx_details_all
        SET
         ly_pr_grp_vol_start = prorated_grp_vol_start * l_proration_factor
        ,ly_pr_grp_vol_end   = prorated_grp_vol_end * l_proration_factor
        WHERE
        trx_header_id = trx_rec.trx_header_id;

      END LOOP;

    END IF;

    /* -- POPULATE ly_pr_grp_vol_start - ly_pr_grp_vol_end - START -- */

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_ly_pro_vol;

--------------------------------------------------------------------------------
--  NAME         : populate_fy_pro_vol
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_fy_pro_vol( p_var_rent_id        IN NUMBER
                              ,p_proration_rule     IN VARCHAR2
                              ,p_vr_commencement_dt IN DATE
                              ,p_vr_termination_dt  IN DATE) IS

  /* get VR details */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  /* get rates for trx header containing FY end date */
  CURSOR trx_fy_c( p_vr_id IN NUMBER
                  ,p_date  IN DATE) IS
    SELECT
     hdr.trx_header_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    p_date BETWEEN hdr.calc_prd_start_date AND (hdr.calc_prd_end_date - 1);

  l_vr_commencement_date DATE;
  l_vr_termination_date  DATE;
  l_vr_proration_rule    VARCHAR2(30);
  l_fy_end_date          DATE;

  l_proration_factor NUMBER;

  /* get the first partial period */
  CURSOR first_period_c( p_vr_id     IN NUMBER
                       ,p_comm_date IN DATE) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd
    WHERE
    prd.var_rent_id = p_var_rent_id AND
    prd.start_date = p_comm_date;

  l_first_period_id NUMBER;
  l_partial_period VARCHAR2(1);

BEGIN

  IF p_proration_rule IS NULL OR
     p_vr_commencement_dt IS NULL OR
     p_vr_termination_dt IS NULL
  THEN
    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_vr_commencement_date := vr_rec.commencement_date;
      l_vr_termination_date  := vr_rec.termination_date;
      l_vr_proration_rule    := vr_rec.proration_rule;
    END LOOP;
  ELSE
    l_vr_commencement_date := p_vr_commencement_dt;
    l_vr_termination_date  := p_vr_termination_dt;
    l_vr_proration_rule    := p_proration_rule;
  END IF;

  l_fy_end_date := ADD_MONTHS(l_vr_commencement_date, 12) - 1;

  IF l_vr_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_FY
                             ,pn_var_trx_pkg.G_PRORUL_FLY) THEN

    FOR prd_rec IN first_period_c( p_vr_id     => p_var_rent_id
                                 ,p_comm_date => l_vr_commencement_date)
    LOOP
      l_first_period_id := prd_rec.period_id;
      l_partial_period := NVL(prd_rec.partial_period, 'N');
    END LOOP;

    /* -- POPULATE INVOICE FLAG - START -- */
    IF l_vr_proration_rule = pn_var_trx_pkg.G_PRORUL_FY THEN

      /* init invoice flag */
      UPDATE
      pn_var_trx_headers_all
      SET
      invoice_flag = NULL
      WHERE
      var_rent_id = p_var_rent_id AND
      invoice_flag IN ('N', 'I');

    END IF;

    IF l_partial_period = 'Y' THEN

       /* populate invoice flag = N */
       UPDATE
       pn_var_trx_headers_all
       SET
       invoice_flag = 'N'
       WHERE
       var_rent_id = p_var_rent_id AND
       period_id = (SELECT
                    prd.period_id
                    FROM
                    pn_var_periods_all prd
                    WHERE
                    prd.var_rent_id = p_var_rent_id AND
                    prd.start_date = l_vr_commencement_date AND
                    prd.partial_period = 'Y');

       /* populate invoice flag = I */
       UPDATE
       pn_var_trx_headers_all
       SET
       invoice_flag = 'I'
       WHERE
       var_rent_id = p_var_rent_id AND
       l_fy_end_date BETWEEN calc_prd_start_date AND calc_prd_end_date;

    END IF;

    /* init fy_pr_grp_vol_start - fy_pr_grp_vol_end */
    UPDATE
    pn_var_trx_details_all
    SET
     fy_pr_grp_vol_start = NULL
    ,fy_pr_grp_vol_end   = NULL
    WHERE
    trx_header_id IN (SELECT
                      trx_header_id
                      FROM
                      pn_var_trx_headers_all
                      WHERE
                      var_rent_id = p_var_rent_id);

    IF l_partial_period = 'Y' THEN
       /* populate fy_pr_grp_vol_start - fy_pr_grp_vol_end */
       UPDATE
       pn_var_trx_details_all
       SET
        fy_pr_grp_vol_start = prorated_grp_vol_start
       ,fy_pr_grp_vol_end   = prorated_grp_vol_end
       WHERE
       trx_header_id IN (SELECT
                         trx_header_id
                         FROM
                         pn_var_trx_headers_all
                         WHERE
                         var_rent_id = p_var_rent_id AND
                         calc_prd_end_date <= l_fy_end_date);


       FOR trx_rec IN trx_fy_c( p_vr_id => p_var_rent_id
                               ,p_date  => l_fy_end_date) LOOP

         /* fy proration factor */
         l_proration_factor
           := ((l_fy_end_date - trx_rec.calc_prd_start_date) + 1)
               / ((trx_rec.calc_prd_end_date - trx_rec.calc_prd_start_date) + 1);

         /* populate fy_pr_grp_vol_start - fy_pr_grp_vol_end */
         UPDATE
         pn_var_trx_details_all
         SET
          fy_pr_grp_vol_start = prorated_grp_vol_start * l_proration_factor
         ,fy_pr_grp_vol_end   = prorated_grp_vol_end * l_proration_factor
         WHERE
         trx_header_id = trx_rec.trx_header_id;

       END LOOP;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_fy_pro_vol;

--------------------------------------------------------------------------------
--  NAME         : populate_blended_grp_vol
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_blended_grp_vol( p_var_rent_id    IN NUMBER
                                   ,p_proration_rule IN VARCHAR2) IS

  /* get VR details */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  /* VR info */
  l_vr_commencement_date DATE;
  l_vr_termination_date  DATE;
  l_vr_proration_rule    VARCHAR2(30);

  /* get the period details - we use the first 2 periods */
  CURSOR periods_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,start_date
    ,end_date
    ,partial_period
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
    start_date;

  /* period info */
  l_part_prd_id           NUMBER;
  l_part_prd_start_dt     DATE;
  l_part_prd_end_dt       DATE;
  l_part_prd_partial_flag VARCHAR2(1);

  l_full_prd_id           NUMBER;
  l_full_prd_start_dt     DATE;
  l_full_prd_end_dt       DATE;
  l_full_prd_partial_flag VARCHAR2(1);

  /* sum the proration factor in groups - OLD */
  /*
  CURSOR grp_pro_factor_sum_c(p_prd_id IN NUMBER) IS
    SELECT
    SUM(grp.proration_factor) proration_factor_sum
    FROM
    pn_var_grp_dates_all grp
    WHERE
    prd.period_id = p_prd_id
    GROUP BY
    grp.period_id;
  */

  /* sum the proration factor in groups */
  CURSOR grp_pro_factor_sum_c(p_prd_id IN NUMBER) IS
    SELECT
    SUM(grp.proration_factor) proration_factor_sum
    FROM
     pn_var_grp_dates_all grp
    ,pn_var_periods_all   prd
    WHERE
    prd.period_id = p_prd_id AND
    grp.period_id = prd.period_id AND
    grp.grp_end_date <= prd.end_date
    GROUP BY
    grp.period_id;

  /* period length in calc period units */
  l_part_prd_length NUMBER;
  l_full_prd_length NUMBER;

  /* blended period volumes for CYP and CYNP for combined period */
  CURSOR blended_prd_vol_cs( p_vr_id       IN NUMBER
                            ,p_part_prd_ID IN NUMBER
                            ,p_full_prd_ID IN NUMBER) IS
    SELECT /*+ LEADING(hdr) */
     hdr.line_item_group_id
    ,dtl.bkpt_rate
    ,SUM(dtl.prorated_grp_vol_start) AS blended_period_vol_start
    ,SUM(dtl.prorated_grp_vol_end)   AS blended_period_vol_end
    FROM
     pn_var_trx_headers_all hdr
    ,pn_var_trx_details_all dtl
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id IN (p_part_prd_ID, p_full_prd_ID) AND
    dtl.trx_header_id = hdr.trx_header_id
    GROUP BY
     hdr.line_item_group_id
    ,dtl.bkpt_rate;

  /* handle first partial calculation period */
  CURSOR first_partial_cs_c( p_vr_id     IN NUMBER
                            ,p_prd_id    IN NUMBER
                            ,p_prd_st_dt IN DATE) IS
    SELECT
     hdr.trx_header_id
    ,grp.grp_date_id
    ,grp.proration_factor AS grp_prorat_factor
    ,hdr.proration_factor AS calc_prd_prorat_factor
    FROM
     pn_var_trx_headers_all hdr
    ,pn_var_grp_dates_all grp
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_id /*AND
    hdr.calc_prd_start_date = p_prd_st_dt*/ AND
    grp.grp_date_id = hdr.grp_date_id;

  /* handle last partial calculation period */
  CURSOR last_partial_cs_c( p_vr_id      IN NUMBER
                           ,p_prd_id     IN NUMBER
                           ,p_prd_end_dt IN DATE) IS
    SELECT
     hdr.trx_header_id
    ,grp.grp_date_id
    ,grp.proration_factor AS grp_prorat_factor
    ,hdr.proration_factor AS calc_prd_prorat_factor
    FROM
     pn_var_trx_headers_all hdr
    ,pn_var_grp_dates_all grp
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_id /*AND
    hdr.calc_prd_end_date = p_prd_end_dt*/ AND
    grp.grp_date_id = hdr.grp_date_id;

  /* counters */
  l_counter1 NUMBER;

  l_context VARCHAR2(255);

BEGIN

  pnp_debug_pkg.log('');
  pnp_debug_pkg.log('--- pn_var_trx_pkg.populate_blended_grp_vol START ---');
  pnp_debug_pkg.log('');

  /* get proration RULE */
  IF p_proration_rule IS NULL THEN

    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_vr_proration_rule    := vr_rec.proration_rule;
    END LOOP;

  ELSE

    l_vr_proration_rule := p_proration_rule;

  END IF;

  pnp_debug_pkg.log('VR ID: '||p_var_rent_id||
                    '   Proration Rule: '||l_vr_proration_rule);
  pnp_debug_pkg.log('');

  l_counter1 := 1;

  /* fetch partial and full period details */
  l_context := 'Get first 2 period details';

  FOR prd_rec IN periods_c(p_vr_id => p_var_rent_id) LOOP

    IF l_counter1 = 1 THEN
      l_part_prd_id           := prd_rec.period_id;
      l_part_prd_start_dt     := prd_rec.start_date;
      l_part_prd_end_dt       := prd_rec.end_date;
      l_part_prd_partial_flag := prd_rec.partial_period;

      FOR rec IN grp_pro_factor_sum_c(p_prd_id => l_part_prd_id) LOOP
        l_part_prd_length := rec.proration_factor_sum;
      END LOOP;

    ELSIF l_counter1 = 2 THEN
      l_full_prd_id           := prd_rec.period_id;
      l_full_prd_start_dt     := prd_rec.start_date;
      l_full_prd_end_dt       := prd_rec.end_date;
      l_full_prd_partial_flag := prd_rec.partial_period;

      FOR rec IN grp_pro_factor_sum_c(p_prd_id => l_full_prd_id) LOOP
        l_full_prd_length := rec.proration_factor_sum;
      END LOOP;

    ELSE
      EXIT;

    END IF;

    l_counter1 := l_counter1 + 1;

  END LOOP;

  pnp_debug_pkg.log(l_context||' COMPLETE');
  pnp_debug_pkg.log('Part period Start Date: '||l_part_prd_start_dt);
  pnp_debug_pkg.log('Part period Length: '||l_part_prd_length);
  pnp_debug_pkg.log('Full period Start Date: '||l_full_prd_start_dt);
  pnp_debug_pkg.log('Full period Length: '||l_part_prd_start_dt);
  pnp_debug_pkg.log('');

  IF l_vr_proration_rule = pn_var_trx_pkg.G_PRORUL_CYP THEN

    l_context := 'CYP - update invoice_flag';
    /* reset the invoice flag */
    UPDATE
    pn_var_trx_headers_all
    SET
    invoice_flag = NULL
    WHERE
    var_rent_id = p_var_rent_id AND
    invoice_flag = 'P';

    /* populate invoice_flag */
    UPDATE
    pn_var_trx_headers_all
    SET
    invoice_flag = 'P'
    WHERE
    trx_header_id IN (SELECT
                      trx_header_id
                      FROM
                      pn_var_trx_headers_all
                      WHERE
                      var_rent_id = p_var_rent_id AND
                      period_id IN (l_part_prd_id, l_full_prd_id)
                     );

    pnp_debug_pkg.log(l_context||' COMPLETE');
    pnp_debug_pkg.log('');


    l_context := 'CYP - update pr_grp_blended_vol_start - end';
    /* reset pr_grp_blended_vol_start - pr_grp_blended_vol_end */
    UPDATE
    pn_var_trx_details_all
    SET
     pr_grp_blended_vol_start = NULL
    ,pr_grp_blended_vol_end   = NULL
    WHERE
    trx_header_id IN (SELECT
                      trx_header_id
                      FROM
                      pn_var_trx_headers_all
                      WHERE
                      var_rent_id = p_var_rent_id);

    /* populate pr_grp_blended_vol_start - pr_grp_blended_vol_end */
    UPDATE
    pn_var_trx_details_all
    SET
     pr_grp_blended_vol_start = prorated_grp_vol_start
    ,pr_grp_blended_vol_end   = prorated_grp_vol_end
    WHERE
    trx_header_id IN (SELECT
                      trx_header_id
                      FROM
                      pn_var_trx_headers_all
                      WHERE
                      var_rent_id = p_var_rent_id AND
                      period_id IN (l_part_prd_id, l_full_prd_id)
                     );

    pnp_debug_pkg.log(l_context||' COMPLETE');
    pnp_debug_pkg.log('');

    /* populate blended_period_vol_start - blended_period_vol_end */
    l_context := 'CYP - update blended_period_vol_start - end';

    FOR cyp_rec IN blended_prd_vol_cs( p_vr_id       => p_var_rent_id
                                      ,p_part_prd_ID => l_part_prd_id
                                      ,p_full_prd_ID => l_full_prd_id)
    LOOP

      UPDATE
      pn_var_trx_details_all
      SET
       blended_period_vol_start = cyp_rec.blended_period_vol_start
      ,blended_period_vol_end   = cyp_rec.blended_period_vol_end
      WHERE
      trx_header_id IN (SELECT
                        trx_header_id
                        FROM
                        pn_var_trx_headers_all
                        WHERE
                        var_rent_id = p_var_rent_id AND
                        period_id IN (l_part_prd_id, l_full_prd_id) AND
                        line_item_group_id = cyp_rec.line_item_group_id
                       ) AND
      bkpt_rate = cyp_rec.bkpt_rate;

    END LOOP;

    pnp_debug_pkg.log(l_context||' COMPLETE');
    pnp_debug_pkg.log('');

  ELSIF l_vr_proration_rule = pn_var_trx_pkg.G_PRORUL_CYNP THEN

    l_context := 'CYNP - update invoice_flag';

    /* reset the invoice flag */
    UPDATE
    pn_var_trx_headers_all
    SET
    invoice_flag = NULL
    WHERE
    var_rent_id = p_var_rent_id AND
    invoice_flag = 'P';

    /* populate fy_pr_grp_vol_start - fy_pr_grp_vol_end */
    UPDATE
    pn_var_trx_headers_all
    SET
    invoice_flag = 'P'
    WHERE
    trx_header_id IN (SELECT
                      trx_header_id
                      FROM
                      pn_var_trx_headers_all
                      WHERE
                      var_rent_id = p_var_rent_id AND
                      period_id IN (l_part_prd_id, l_full_prd_id)
                     );

    pnp_debug_pkg.log(l_context||' COMPLETE');
    pnp_debug_pkg.log('');

    l_context
    := 'CYNP - update pr_grp_blended_vol_start - end, blended_period_vol_start - end';
    /* reset pr_grp_blended_vol_start - pr_grp_blended_vol_end */
    UPDATE
    pn_var_trx_details_all
    SET
     pr_grp_blended_vol_start = NULL
    ,pr_grp_blended_vol_end   = NULL
    WHERE
    trx_header_id IN (SELECT
                      trx_header_id
                      FROM
                      pn_var_trx_headers_all
                      WHERE
                      var_rent_id = p_var_rent_id);

    FOR cynp_rec IN blended_prd_vol_cs( p_vr_id       => p_var_rent_id
                                       ,p_part_prd_ID => l_part_prd_id
                                       ,p_full_prd_ID => l_full_prd_id)
    LOOP

      UPDATE
      pn_var_trx_details_all
      SET
       blended_period_vol_start
        = (cynp_rec.blended_period_vol_start / (l_part_prd_length + l_full_prd_length))
           * l_full_prd_length
      ,blended_period_vol_end
        = (cynp_rec.blended_period_vol_end /(l_part_prd_length + l_full_prd_length))
           * l_full_prd_length
      ,pr_grp_blended_vol_start
        = (cynp_rec.blended_period_vol_start /(l_part_prd_length + l_full_prd_length))
           * (l_full_prd_length / (l_part_prd_length + l_full_prd_length))
      ,pr_grp_blended_vol_end
        = (cynp_rec.blended_period_vol_end /(l_part_prd_length + l_full_prd_length))
           * (l_full_prd_length / (l_part_prd_length + l_full_prd_length))
      WHERE
      trx_header_id IN (SELECT
                        trx_header_id
                        FROM
                        pn_var_trx_headers_all
                        WHERE
                        var_rent_id = p_var_rent_id AND
                        period_id IN (l_part_prd_id, l_full_prd_id)AND
                        line_item_group_id = cynp_rec.line_item_group_id
                       ) AND
      bkpt_rate = cynp_rec.bkpt_rate;

    END LOOP;

    pnp_debug_pkg.log(l_context||' COMPLETE');
    pnp_debug_pkg.log('');

    l_context
    := 'CYNP - update pr_grp_blended_vol_start - end for first/last partial';

    /* update first partial calc sub period pr_grp_blended_vol_start - end */
    FOR first_part_rec IN first_partial_cs_c( p_vr_id     => p_var_rent_id
                                             ,p_prd_id    => l_part_prd_id
                                             ,p_prd_st_dt => l_part_prd_start_dt)
    LOOP

      UPDATE
      pn_var_trx_details_all
      SET
       pr_grp_blended_vol_start
        = pr_grp_blended_vol_start
          * first_part_rec.grp_prorat_factor
          * first_part_rec.calc_prd_prorat_factor
      ,pr_grp_blended_vol_end
        = pr_grp_blended_vol_end
          * first_part_rec.grp_prorat_factor
          * first_part_rec.calc_prd_prorat_factor
      WHERE
      trx_header_id = first_part_rec.trx_header_id;

    END LOOP;

    /* update last partial calc sub period pr_grp_blended_vol_start - end */
    FOR last_part_rec IN last_partial_cs_c( p_vr_id      => p_var_rent_id
                                           ,p_prd_id     => l_full_prd_id
                                           ,p_prd_end_dt => l_full_prd_end_dt)
    LOOP

      UPDATE
      pn_var_trx_details_all
      SET
       pr_grp_blended_vol_start
        = pr_grp_blended_vol_start
          * last_part_rec.grp_prorat_factor
          * last_part_rec.calc_prd_prorat_factor
      ,pr_grp_blended_vol_end
        = pr_grp_blended_vol_end
          * last_part_rec.grp_prorat_factor
          * last_part_rec.calc_prd_prorat_factor
      WHERE
      trx_header_id = last_part_rec.trx_header_id;

    END LOOP;

    pnp_debug_pkg.log(l_context||' COMPLETE');
    pnp_debug_pkg.log('');

  END IF;

  pnp_debug_pkg.log('');
  pnp_debug_pkg.log('--- pn_var_trx_pkg.populate_blended_grp_vol START ---');
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

END populate_blended_grp_vol;

--------------------------------------------------------------------------------
--  NAME         : populate_ytd_pro_vol
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_ytd_pro_vol( p_var_rent_id    IN NUMBER
                               ,p_proration_rule IN VARCHAR2) IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.org_id
    ,vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    ,vr.cumulative_vol
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_proration_rule pn_var_rents_all.proration_rule%TYPE;

  /* get the period details - we use the first 2 periods */
  CURSOR periods_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,start_date
    ,end_date
    ,partial_period
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
    start_date;

  /* period info */
  l_part_prd_id           NUMBER;
  l_part_prd_start_dt     DATE;
  l_part_prd_end_dt       DATE;
  l_part_prd_partial_flag VARCHAR2(1);

  l_full_prd_id           NUMBER;
  l_full_prd_start_dt     DATE;
  l_full_prd_end_dt       DATE;
  l_full_prd_partial_flag VARCHAR2(1);

  /* get the line items to update */
  CURSOR lines_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    bkpt_update_flag = 'Y'
    ORDER BY
     period_id
    ,line_item_id;

  /* get the line items to update */
  CURSOR lines_cs_c ( p_vr_id       IN NUMBER
                     ,p_part_prd_id IN NUMBER
                     ,p_full_prd_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    bkpt_update_flag = 'Y' AND
    period_id NOT IN (p_part_prd_id, p_full_prd_id)
    ORDER BY
     period_id
    ,line_item_id;

  /* ytd for STD, NP, FY, LY, FLY */
  CURSOR ytd_group_vol_c( p_vr_ID   IN NUMBER
                         ,p_prd_ID  IN NUMBER
                         ,p_line_ID IN NUMBER) IS
   SELECT  /*+ LEADING(hdr) */
     dtl.trx_detail_id
    ,SUM(prorated_grp_vol_start) OVER
      (PARTITION BY
        hdr.period_id
       ,hdr.line_item_id
       ,hdr.reset_group_id
       ,pbd.group_bkpt_vol_start
       ,pbd.group_bkpt_vol_end
       ORDER BY
        hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_group_vol_start
    ,SUM(prorated_grp_vol_end) OVER
      (PARTITION BY
        hdr.period_id
       ,hdr.line_item_id
       ,hdr.reset_group_id
       ,pbd.group_bkpt_vol_start
       ,pbd.group_bkpt_vol_end
       ORDER BY
        hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_group_vol_end
    FROM
     pn_var_trx_headers_all hdr
    ,pn_var_trx_details_all dtl
    ,PN_VAR_BKPTS_DET_ALL pbd
    ,pn_var_bkpts_head_all pbh
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_ID AND
    hdr.line_item_id = p_line_ID AND
    dtl.trx_header_id = hdr.trx_header_id
    and pbd.var_rent_id = hdr.var_rent_id
    and pbd.bkpt_rate = dtl.bkpt_rate
    and pbd.bkpt_header_id = pbh.bkpt_header_id
    and pbd.bkpt_detail_id = dtl.bkpt_detail_id
    and pbh.line_item_id = hdr.line_item_id
    and pbh.period_id = hdr.period_id   /* 8616530 */
    ORDER BY
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.calc_prd_start_date;


  /* ytd for CYP, CYNP combined period */
  CURSOR ytd_group_vol_cs_c( p_vr_ID       IN NUMBER
                            ,p_part_prd_id IN NUMBER
                            ,p_full_prd_id IN NUMBER) IS
    SELECT  /*+ LEADING(hdr) */
     dtl.trx_detail_id
    ,SUM(pr_grp_blended_vol_start) OVER
      (PARTITION BY
        hdr.line_item_group_id
       ,dtl.bkpt_rate
       ORDER BY
        hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_group_vol_start
    ,SUM(pr_grp_blended_vol_end) OVER
      (PARTITION BY
        hdr.line_item_group_id
       ,dtl.bkpt_rate
       ORDER BY
        hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_group_vol_end
    FROM
     pn_var_trx_headers_all hdr
    ,pn_var_trx_details_all dtl
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id IN (p_part_prd_id, p_full_prd_id) AND
    dtl.trx_header_id = hdr.trx_header_id
    ORDER BY
     hdr.line_item_group_id
    ,hdr.calc_prd_start_date;

  /* counters */
  l_counter1 NUMBER;

  trx_detail_t        NUM_T;
  ytd_grp_vol_start_t NUM_T;
  ytd_grp_vol_end_t   NUM_T;

BEGIN

  IF p_proration_rule IS NULL THEN

    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_proration_rule       := vr_rec.proration_rule;
    END LOOP;

  ELSE

    l_proration_rule     := p_proration_rule;

  END IF;

  l_counter1 := 1;

  IF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_FY
                          ,pn_var_trx_pkg.G_PRORUL_LY
                          ,pn_var_trx_pkg.G_PRORUL_FLY
                          ,pn_var_trx_pkg.G_PRORUL_NP
                          ,pn_var_trx_pkg.G_PRORUL_STD) THEN

    FOR line_rec IN lines_c(p_vr_id => p_var_rent_id) LOOP

      trx_detail_t.DELETE;
      ytd_grp_vol_start_t.DELETE;
      ytd_grp_vol_end_t.DELETE;

      OPEN ytd_group_vol_c( p_vr_ID   => p_var_rent_id
                           ,p_prd_ID  => line_rec.period_id
                           ,p_line_ID => line_rec.line_item_id);

      FETCH ytd_group_vol_c BULK COLLECT INTO
       trx_detail_t
      ,ytd_grp_vol_start_t
      ,ytd_grp_vol_end_t;

      CLOSE ytd_group_vol_c;
      pnp_debug_pkg.log('line_rec.period_id - '||line_rec.period_id);
      pnp_debug_pkg.log('line_rec.line_item_id- '||line_rec.line_item_id);


      FORALL i IN 1..trx_detail_t.COUNT
        UPDATE
        pn_var_trx_details_all
        SET
         ytd_group_vol_start = ytd_grp_vol_start_t(i)
        ,ytd_group_vol_end   = ytd_grp_vol_end_t(i)
        WHERE
        trx_detail_id = trx_detail_t(i);

    END LOOP;

  ELSIF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_CYP
                             ,pn_var_trx_pkg.G_PRORUL_CYNP)  THEN

    /* fetch partial and full period details */
    FOR prd_rec IN periods_c(p_vr_id => p_var_rent_id) LOOP

      IF l_counter1 = 1 THEN
        l_part_prd_id           := prd_rec.period_id;
        l_part_prd_start_dt     := prd_rec.start_date;
        l_part_prd_end_dt       := prd_rec.end_date;
        l_part_prd_partial_flag := prd_rec.partial_period;

      ELSIF l_counter1 = 2 THEN
        l_full_prd_id           := prd_rec.period_id;
        l_full_prd_start_dt     := prd_rec.start_date;
        l_full_prd_end_dt       := prd_rec.end_date;
        l_full_prd_partial_flag := prd_rec.partial_period;

      ELSE
        EXIT;

      END IF;

      l_counter1 := l_counter1 + 1;

    END LOOP;

    trx_detail_t.DELETE;
    ytd_grp_vol_start_t.DELETE;
    ytd_grp_vol_end_t.DELETE;

    OPEN ytd_group_vol_cs_c ( p_vr_ID       => p_var_rent_id
                             ,p_part_prd_id => l_part_prd_id
                             ,p_full_prd_id => l_full_prd_id);

    FETCH ytd_group_vol_cs_c BULK COLLECT INTO
     trx_detail_t
    ,ytd_grp_vol_start_t
    ,ytd_grp_vol_end_t;

    CLOSE ytd_group_vol_cs_c;

    FORALL i IN 1..trx_detail_t.COUNT
      UPDATE
      pn_var_trx_details_all
      SET
       ytd_group_vol_start = ytd_grp_vol_start_t(i)
      ,ytd_group_vol_end   = ytd_grp_vol_end_t(i)
      WHERE
      trx_detail_id = trx_detail_t(i);

    FOR line_rec IN lines_cs_c( p_vr_id       => p_var_rent_id
                               ,p_part_prd_id => l_part_prd_id
                               ,p_full_prd_id => l_full_prd_id) LOOP

      trx_detail_t.DELETE;
      ytd_grp_vol_start_t.DELETE;
      ytd_grp_vol_end_t.DELETE;

      OPEN ytd_group_vol_c( p_vr_ID   => p_var_rent_id
                           ,p_prd_ID  => line_rec.period_id
                           ,p_line_ID => line_rec.line_item_id);

      FETCH ytd_group_vol_c BULK COLLECT INTO
       trx_detail_t
      ,ytd_grp_vol_start_t
      ,ytd_grp_vol_end_t;

      CLOSE ytd_group_vol_c;

      FORALL i IN 1..trx_detail_t.COUNT
        UPDATE
        pn_var_trx_details_all
        SET
         ytd_group_vol_start = ytd_grp_vol_start_t(i)
        ,ytd_group_vol_end   = ytd_grp_vol_end_t(i)
        WHERE
        trx_detail_id = trx_detail_t(i);

    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_ytd_pro_vol;

--------------------------------------------------------------------------------
--  NAME         : populate_blended_period_vol
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_blended_period_vol( p_var_rent_id    IN NUMBER
                                      ,p_proration_rule IN VARCHAR2
                                      ,p_calc_method    IN VARCHAR2)
IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.org_id
    ,vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    ,vr.cumulative_vol
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_proration_rule       pn_var_rents_all.proration_rule%TYPE;
  l_calculation_method   pn_var_rents_all.cumulative_vol%TYPE;

  /* get the period details - we use the first 2 periods for CYP, CYNP */
  CURSOR periods_c(p_vr_id IN NUMBER) IS
    SELECT
    period_id
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
    start_date;

  /* data structures */
  l_period_t NUM_T;

  /* counters */
  l_prd_counter NUMBER;

  /* user defined exceptions */
  DO_NOT_PROCESS EXCEPTION;

  /* blended period volumes */
  CURSOR blended_prd_vol_c( p_vr_id  IN NUMBER
                           ,p_prd_id IN NUMBER) IS
    SELECT  /*+ LEADING(hdr) */
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.reset_group_id
    ,dtl.bkpt_rate
    ,SUM(prorated_grp_vol_start) AS blended_period_vol_start
    ,SUM(prorated_grp_vol_end) AS blended_period_vol_end
    FROM
     pn_var_trx_headers_all hdr
    ,pn_var_trx_details_all dtl
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_id AND
    hdr.line_item_id IN (SELECT
                         line_item_id
                         FROM
                         pn_var_lines_all
                         WHERE
                         var_rent_id = p_vr_id AND
                         period_id = p_prd_id AND
                         bkpt_update_flag = 'Y') AND
    dtl.trx_header_id = hdr.trx_header_id
    GROUP BY
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.reset_group_id
    ,dtl.bkpt_rate;


       -- Get first partial period id
 CURSOR check_fst_partial_prd(p_period_id IN NUMBER) IS
  SELECT period_id
    FROM pn_var_periods_all
   WHERE period_id = p_period_id
     AND period_num=1
     AND partial_period='Y';

  /* get the last partial period */
  CURSOR last_period_c( p_period_id     IN NUMBER) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd,
    pn_var_rents_all   var
    WHERE
    prd.period_id = p_period_id AND
    prd.var_rent_id = var.var_rent_id AND
    prd.end_date = var.termination_date AND
    prd.partial_period='Y';

BEGIN

  IF p_proration_rule IS NULL OR
     p_calc_method IS NULL
  THEN
    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_proration_rule       := vr_rec.proration_rule;
      l_calculation_method   := vr_rec.cumulative_vol;
    END LOOP;

  ELSE
    l_proration_rule       := p_proration_rule;
    l_calculation_method   := p_calc_method;

  END IF;

  l_period_t.DELETE;

  OPEN periods_c(p_vr_id => p_var_rent_id);
  FETCH periods_c BULK COLLECT INTO l_period_t;
  CLOSE periods_c;

  FOR prd_rec IN 1..l_period_t.COUNT LOOP

    BEGIN

      IF prd_rec = 1 THEN
        IF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_CYP
                                ,pn_var_trx_pkg.G_PRORUL_CYNP)
        THEN
          RAISE DO_NOT_PROCESS;

        END IF;

        IF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_FY
                                ,pn_var_trx_pkg.G_PRORUL_FLY)
        THEN
           FOR fst_rec IN check_fst_partial_prd(l_period_t(prd_rec)) LOOP
              RAISE DO_NOT_PROCESS;
           END LOOP;
        END IF;

      ELSIF prd_rec = 2 THEN

        IF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_CYP
                                ,pn_var_trx_pkg.G_PRORUL_CYNP)
        THEN
          RAISE DO_NOT_PROCESS;

        END IF;

      ELSIF prd_rec = l_period_t.COUNT THEN

        IF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_LY
                                ,pn_var_trx_pkg.G_PRORUL_FLY)
        THEN
           FOR fst_rec IN last_period_c(l_period_t(prd_rec)) LOOP
              RAISE DO_NOT_PROCESS;
           END LOOP;

        END IF;
      END IF;

      FOR rec IN blended_prd_vol_c( p_vr_id  => p_var_rent_id
                                   ,p_prd_id => l_period_t(prd_rec)) LOOP

        UPDATE
        pn_var_trx_details_all
        SET
         blended_period_vol_start = rec.blended_period_vol_start
        ,blended_period_vol_end   = rec.blended_period_vol_end
        WHERE
        trx_header_id IN
          (SELECT
           trx_header_id
           FROM
           pn_var_trx_headers_all
           WHERE
           var_rent_id = p_var_rent_id AND
           period_id = rec.period_id AND
           line_item_id = rec.line_item_id AND
           reset_group_id = rec.reset_group_id) AND
        bkpt_rate = rec.bkpt_rate;

      END LOOP;

    EXCEPTION

      WHEN DO_NOT_PROCESS THEN NULL;
      WHEN OTHERS THEN RAISE;

    END;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END populate_blended_period_vol;

--------------------------------------------------------------------------------
--  NAME         : delete_transactions
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE delete_transactions( p_var_rent_id  IN NUMBER
                              ,p_period_id    IN NUMBER
                              ,p_line_item_id IN NUMBER) IS

BEGIN

  IF p_line_item_id IS NOT NULL AND
     p_period_id IS NOT NULL AND
     p_var_rent_id IS NOT NULL
  THEN
    pnp_debug_pkg.log('Deleting for lines');
    DELETE
    pn_var_trx_details_all
    WHERE
    trx_header_id IN
      ( SELECT
        trx_header_id
        FROM
        pn_var_trx_headers_all
        WHERE
        var_rent_id = p_var_rent_id AND
        period_id = p_period_id AND
        line_item_id = p_line_item_id );

    DELETE
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_var_rent_id AND
    period_id = p_period_id AND
    line_item_id = p_line_item_id;

  ELSIF p_line_item_id IS NULL AND
        p_period_id IS NOT NULL AND
        p_var_rent_id IS NOT NULL
  THEN
    pnp_debug_pkg.log('Deleting for periods');
    DELETE
    pn_var_trx_details_all
    WHERE
    trx_header_id IN
      ( SELECT
        trx_header_id
        FROM
        pn_var_trx_headers_all
        WHERE
        var_rent_id = p_var_rent_id AND
        period_id = p_period_id);

    DELETE
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_var_rent_id AND
    period_id = p_period_id;

  ELSIF p_line_item_id IS NULL AND
        p_period_id IS NULL AND
        p_var_rent_id IS NOT NULL
  THEN
    pnp_debug_pkg.log('Deleting for VR');
    DELETE
    pn_var_trx_details_all
    WHERE
    trx_header_id IN
      ( SELECT
        trx_header_id
        FROM
        pn_var_trx_headers_all
        WHERE
        var_rent_id = p_var_rent_id);

    DELETE
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_var_rent_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END delete_transactions;


--------------------------------------------------------------------------------
--  NAME         : populate_transactions
--  DESCRIPTION  : inserts/updates the transactions table.
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--  23-MAY-2007  Lokesh   o Added rounding off for Bug # 6031202
--------------------------------------------------------------------------------
PROCEDURE  populate_transactions(p_var_rent_id IN NUMBER) IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.org_id
    ,vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    ,vr.cumulative_vol
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  /* variables for vr_c */
  l_org_id               pn_var_rents_all.org_id%TYPE;
  l_vr_commencement_date pn_var_rents_all.commencement_date%TYPE;
  l_vr_termination_date  pn_var_rents_all.termination_date%TYPE;
  l_proration_rule       pn_var_rents_all.proration_rule%TYPE;
  l_calculation_method   pn_var_rents_all.cumulative_vol%TYPE;

  /* get the periods that do not exist anymore */
  CURSOR chk_for_del_prd_c(p_vr_id IN NUMBER) IS
    SELECT
    period_id
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id
    MINUS
    SELECT
    period_id
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id AND
    status IS NULL;

  /* get all periods for the VR */
  CURSOR periods_c(p_vr_id IN NUMBER) IS
    SELECT
     prd.var_rent_id
    ,prd.period_id
    ,prd.start_date
    ,prd.end_date
    FROM
    pn_var_periods_all prd
    WHERE
    prd.var_rent_id = p_vr_id AND
    prd.status IS NULL
    ORDER BY
    prd.start_date;

  /* get the line items that do not exist anymore in a period */
  CURSOR chk_for_del_line_c( p_vr_id  IN NUMBER
                            ,p_prd_id IN NUMBER) IS
    SELECT
    line_item_id
    FROM
    pn_var_trx_headers_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id
    MINUS
    SELECT
    line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id = p_prd_id;

  -- Get the details of forecasted data
  CURSOR for_data_c(ip_vr_id IN NUMBER,
                     ip_prd_id IN NUMBER
            ) IS
    SELECT  *
      FROM  pn_var_trx_headers_all
     WHERE  var_rent_id = ip_vr_id
       AND  period_id   = ip_prd_id;

  TYPE for_data IS TABLE OF pn_var_trx_headers_all%ROWTYPE INDEX BY BINARY_INTEGER;
  for_data_t for_data;


  /* get all groups for a period */
  /*
  CURSOR groups_c(p_prd_id IN NUMBER) IS
    SELECT
     grp.grp_date_id
    ,grp.grp_start_date
    ,grp.grp_end_date
    ,grp.group_date
    ,grp.invoice_date
    ,grp.proration_factor
    FROM
    pn_var_grp_dates_all grp
    WHERE
    grp.period_id = p_prd_id
    ORDER BY
    grp.grp_start_date;
  */

  CURSOR groups_c(p_prd_id IN NUMBER) IS
    SELECT
     grp.grp_date_id
    ,grp.grp_start_date
    ,grp.grp_end_date
    ,grp.group_date
    ,grp.invoice_date
    ,grp.proration_factor
    FROM
     pn_var_grp_dates_all grp
    ,pn_var_periods_all   prd
    WHERE
    prd.period_id = p_prd_id AND
    grp.period_id = prd.period_id AND
    grp.grp_end_date <= prd.end_date
    ORDER BY
    grp.grp_start_date;

  /* data structures for groups_c */
  TYPE GROUPS_CUR_T IS TABLE OF groups_c%ROWTYPE INDEX BY BINARY_INTEGER;
  groups_cur_tbl GROUPS_CUR_T;

  /* get all line items for a period */
  /*CURSOR line_items_c(p_prd_id IN NUMBER) IS
    SELECT
     line.line_item_id
    ,line.line_default_id
    FROM
    pn_var_lines_all line
    WHERE
    line.period_id = p_prd_id AND
    line.bkpt_update_flag = 'Y' AND
    EXISTS (SELECT null
            FROM pn_var_bkpts_det_all
            WHERE bkpt_header_id IN ( SELECT bkpt_header_id
                                      FROM pn_var_bkpts_head_all
                                      WHERE line_item_id = line.line_item_id))
    ORDER BY
    line_item_id;*/

    CURSOR line_items_c(p_prd_id IN NUMBER) IS
     SELECT
     line.line_item_id
    ,line.line_default_id
    FROM
    pn_var_lines_all line,
    pn_var_bkpts_head_all bph
    WHERE
    line.period_id = p_prd_id AND
    line.bkpt_update_flag = 'Y' AND
    bph.period_id = line.period_id AND
    EXISTS (SELECT null
            FROM pn_var_bkpts_det_all bpd
            WHERE bpd.bkpt_header_id = bph.bkpt_header_id
	    AND rownum = 1)
    order BY line_item_id;

  /* get all breakpoints for a line item */
  CURSOR breakpoints_c(p_line_item_id IN NUMBER) IS
    SELECT
     bkpt.bkpt_detail_id
    ,bkpt.bkpt_start_date
    ,bkpt.bkpt_end_date
    ,bkpt.group_bkpt_vol_start
    ,bkpt.group_bkpt_vol_end
    ,bkpt.period_bkpt_vol_start
    ,bkpt.period_bkpt_vol_end
    ,bkpt.bkpt_rate
    FROM
     pn_var_bkpts_head_all head
    ,pn_var_bkpts_det_all bkpt
    WHERE
    head.line_item_id = p_line_item_id AND
    bkpt.bkpt_header_id = head.bkpt_header_id
    ORDER BY
     bkpt.bkpt_start_date
    ,bkpt.group_bkpt_vol_start;

  CURSOR trueup_cur (p_var_rent_id IN NUMBER) IS
    SELECT  /*+ LEADING(hdr) */
     hdr.line_item_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date
    ,hdr.period_id
    ,dtls.bkpt_rate
    ,hdr.reset_group_id
    ,hdr.trueup_rent_due
    FROM
     pn_var_trx_headers_all hdr
    ,pn_var_trx_details_all dtls
    WHERE
    hdr.trx_header_id = dtls.trx_header_id AND
    hdr.var_rent_id = p_var_rent_id
    ORDER BY
     hdr.line_item_id
    ,hdr.calc_prd_start_date
    ,dtls.bkpt_rate;


  /* data structures for breakpoints_c */
  TYPE BKPT_DTLS_T IS TABLE OF breakpoints_c%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE BKPTS_R IS RECORD
  ( bkpt_start_date DATE
   ,bkpt_end_date   DATE
   ,bkpt_dtls_tbl   BKPT_DTLS_T);

  TYPE BKPTS_T IS TABLE OF BKPTS_R INDEX BY BINARY_INTEGER;
  bkpts_tbl BKPTS_T;

  TYPE TRUEUP_DTLS_T IS TABLE OF trueup_cur%ROWTYPE INDEX BY BINARY_INTEGER;
  trueup_table TRUEUP_DTLS_T;

  TYPE PERIOD_DTLS_T IS TABLE OF periods_c%ROWTYPE INDEX BY BINARY_INTEGER;
  periods_table PERIOD_DTLS_T;

  /* counters */
  l_counter1      NUMBER;
  l_curr_bkpt_ctr NUMBER;

  l_bkpt_counter     NUMBER;
  l_bkpt_dtl_counter NUMBER;

  l_prd_counter       NUMBER;
  l_line_item_counter NUMBER;
  l_group_counter     NUMBER;

  /* other variables */
  l_trx_hdr_id NUMBER;
  l_trx_dtl_id NUMBER;

  l_calc_prd_start_dt DATE;
  l_calc_prd_end_dt   DATE;

  l_proration_factor NUMBER;

  l_prorated_grp_vol_start NUMBER;
  l_prorated_grp_vol_end NUMBER;

  /* flags */
  l_trx_create_upd_flag BOOLEAN;

  l_line_items_lock4bkpt_t NUM_T;
  l_max_end_date  DATE;

BEGIN

  pnp_debug_pkg.log
  ('+++++++++++++ pn_var_trx_pkg.populate_transactions START +++++++++++++');

  /* lock the line items */
  l_line_items_lock4bkpt_t.DELETE;

  OPEN line_items_lock4bkpt_c(p_vr_id => p_var_rent_id);
  FETCH line_items_lock4bkpt_c BULK COLLECT INTO l_line_items_lock4bkpt_t;
  CLOSE line_items_lock4bkpt_c;
  /* get the VR details */
  FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP

    l_org_id               := vr_rec.org_id;
    l_vr_commencement_date := vr_rec.commencement_date;
    l_vr_termination_date  := vr_rec.termination_date;
    l_proration_rule       := vr_rec.proration_rule;
    l_calculation_method   := vr_rec.cumulative_vol;
  END LOOP;

  g_precision := nvl(pn_var_rent_calc_pkg.get_currency_precision(l_org_id),4); /*Bug # 6031202*/

  for_data_t.DELETE;
  FOR period_rec IN periods_c(p_vr_id  => p_var_rent_id) LOOP

     FOR rec IN for_data_c(p_var_rent_id, period_rec.period_id) LOOP
        for_data_t (for_data_t.COUNT+1):= rec;
     END LOOP;
  END LOOP;

  trueup_table.DELETE;
  FOR rec_trueup IN trueup_cur(p_var_rent_id) LOOP
     trueup_table (trueup_table.COUNT+1):= rec_trueup;
  END LOOP;

  periods_table.DELETE;
  FOR rec_periods IN periods_c(p_var_rent_id) LOOP
     periods_table (periods_table.COUNT+1):= rec_periods;
  END LOOP;

  /* assume we will not create/update trx */
  l_trx_create_upd_flag := FALSE;
  /* delete trx records for periods that do not exist anymore */
  FOR del_rec IN chk_for_del_prd_c(p_vr_id => p_var_rent_id) LOOP

    l_trx_create_upd_flag := TRUE;

    pn_var_trx_pkg.delete_transactions
     ( p_var_rent_id  => p_var_rent_id
      ,p_period_id    => del_rec.period_id
      ,p_line_item_id => NULL);
  END LOOP;

  /* delete trx records for a contracted period */
  BEGIN

    DELETE FROM pn_var_trx_headers_all
    WHERE
    var_rent_id = p_var_rent_id AND
    calc_prd_end_date > l_vr_termination_date;

    IF SQL%ROWCOUNT > 0 THEN
      l_trx_create_upd_flag := TRUE;
    END IF;
  EXCEPTION

    WHEN OTHERS THEN RAISE;

  END;


  /* init the period counter */
  l_prd_counter := 1;
  /* loop for all periods,
     create TRX headres and details */
  FOR period_rec IN periods_c(p_vr_id  => p_var_rent_id) LOOP
    /* delete trx records for lines that do not exist anymore in this period */
    FOR del_rec IN chk_for_del_line_c( p_vr_id  => p_var_rent_id
                                      ,p_prd_id => period_rec.period_id) LOOP

      l_trx_create_upd_flag := TRUE;

      pn_var_trx_pkg.delete_transactions
       ( p_var_rent_id  => p_var_rent_id
        ,p_period_id    => period_rec.period_id
        ,p_line_item_id => del_rec.line_item_id);
    END LOOP;

    /* get all the groups for the period, cache */
    groups_cur_tbl.DELETE;

    OPEN groups_c(p_prd_id => period_rec.period_id);
    FETCH groups_c BULK COLLECT INTO groups_cur_tbl;
    CLOSE groups_c;
    l_line_item_counter := 1;

    /* create trx for all line items that have bkpts updated */
    FOR line_item_rec IN line_items_c(p_prd_id => period_rec.period_id) LOOP

      l_trx_create_upd_flag := TRUE;
      pn_var_trx_pkg.delete_transactions
       ( p_var_rent_id  => p_var_rent_id
        ,p_period_id    => period_rec.period_id
        ,p_line_item_id => line_item_rec.line_item_id);

      l_counter1 := 1;
      l_bkpt_counter := 1;
      l_bkpt_dtl_counter := 1;
      bkpts_tbl.DELETE;

      /* get bkpts */
      FOR bkpt_rec IN breakpoints_c(p_line_item_id => line_item_rec.line_item_id)
      LOOP

        IF l_counter1 = 1 THEN

          bkpts_tbl(l_bkpt_counter).bkpt_start_date := bkpt_rec.bkpt_start_date;
          bkpts_tbl(l_bkpt_counter).bkpt_end_date := bkpt_rec.bkpt_end_date;
          bkpts_tbl(l_bkpt_counter).bkpt_dtls_tbl(l_bkpt_dtl_counter) := bkpt_rec;

        ELSE /* l_counter1 > 1 */

          /* if we have stratified bkpt ranges */
          IF bkpt_rec.bkpt_start_date = bkpts_tbl(l_bkpt_counter).bkpt_start_date AND
             bkpt_rec.bkpt_end_date = bkpts_tbl(l_bkpt_counter).bkpt_end_date
          THEN

            /* add a bkpt detail */
            l_bkpt_dtl_counter := l_bkpt_dtl_counter + 1;
            bkpts_tbl(l_bkpt_counter).bkpt_dtls_tbl(l_bkpt_dtl_counter) := bkpt_rec;

          /* else if bkpt date range changed */
          ELSE

            /* reset the bkpt detail counter */
            l_bkpt_dtl_counter := 1;
            /* add a new bkpt header and a detail */
            l_bkpt_counter := l_bkpt_counter + 1;
            bkpts_tbl(l_bkpt_counter).bkpt_start_date := bkpt_rec.bkpt_start_date;
            bkpts_tbl(l_bkpt_counter).bkpt_end_date := bkpt_rec.bkpt_end_date;
            bkpts_tbl(l_bkpt_counter).bkpt_dtls_tbl(l_bkpt_dtl_counter) := bkpt_rec;

          END IF;

        END IF;

        l_counter1 := l_counter1 + 1;

      END LOOP; /* loop for all bkpts for a line item */
      /* we have the bkpt details */

      l_group_counter := 1;

      FOR grp_rec IN 1..groups_cur_tbl.COUNT LOOP

        l_calc_prd_start_dt := groups_cur_tbl(grp_rec).grp_start_date;
        l_calc_prd_end_dt := groups_cur_tbl(grp_rec).grp_end_date;

        l_curr_bkpt_ctr := 1;

        FOR bkpt_rec IN 1..bkpts_tbl.COUNT LOOP

          l_curr_bkpt_ctr := bkpt_rec;

          IF bkpts_tbl(bkpt_rec).bkpt_start_date > l_calc_prd_end_dt THEN
            /* exit the loop no more intersections possible
               - let us go to the next group */
            l_curr_bkpt_ctr := bkpt_rec - 1;
            EXIT;

          ELSIF bkpts_tbl(bkpt_rec).bkpt_start_date
                BETWEEN (l_calc_prd_start_dt + 1) AND l_calc_prd_end_dt
          THEN

            l_calc_prd_end_dt := bkpts_tbl(bkpt_rec - 1).bkpt_end_date;

            /* determine proration */
            l_proration_factor
            := ((l_calc_prd_end_dt - l_calc_prd_start_dt) + 1)
              /((groups_cur_tbl(grp_rec).grp_end_date
                 - groups_cur_tbl(grp_rec).grp_start_date) + 1);

            /* need to create TRX headers and details */

            /* create header */
            pn_var_trx_pkg.insert_trx_hdr
            (p_trx_header_id         => l_trx_hdr_id
            ,p_var_rent_id           => period_rec.var_rent_id
            ,p_period_id             => period_rec.period_id
            ,p_line_item_id          => line_item_rec.line_item_id
            ,p_grp_date_id           => groups_cur_tbl(grp_rec).grp_date_id
            ,p_calc_prd_start_date   => l_calc_prd_start_dt
            ,p_calc_prd_end_date     => l_calc_prd_end_dt
            ,p_var_rent_summ_id      => NULL
            ,p_line_item_group_id    => line_item_rec.line_default_id
            ,p_reset_group_id        => NULL
            ,p_proration_factor      => l_proration_factor
            ,p_reporting_group_sales => NULL
            ,p_prorated_group_sales  => NULL
            ,p_ytd_sales             => NULL
            ,p_fy_proration_sales    => NULL
            ,p_ly_proration_sales    => NULL
            ,p_percent_rent_due      => NULL
            ,p_ytd_percent_rent      => NULL
            ,p_calculated_rent       => NULL
            ,p_prorated_rent_due     => NULL
            ,p_invoice_flag          => NULL
            ,p_org_id                => l_org_id
            ,p_last_update_date      => NULL
            ,p_last_updated_by       => NULL
            ,p_creation_date         => NULL
            ,p_created_by            => NULL
            ,p_last_update_login     => NULL);

            /* create details */
            FOR bkpt_dtl_rec IN 1..bkpts_tbl(bkpt_rec - 1).bkpt_dtls_tbl.COUNT
            LOOP

              IF l_proration_rule = pn_var_trx_pkg.G_PRORUL_NP THEN
                 IF l_calculation_method = pn_var_trx_pkg.G_CALC_CUMULATIVE THEN
                     l_prorated_grp_vol_start
                        := bkpts_tbl(bkpt_rec - 1).bkpt_dtls_tbl(bkpt_dtl_rec).period_bkpt_vol_start;

                     l_prorated_grp_vol_end
                        := NVL(bkpts_tbl(bkpt_rec - 1).bkpt_dtls_tbl(bkpt_dtl_rec).period_bkpt_vol_end, 0);

                ELSE
                     l_prorated_grp_vol_start
                        := bkpts_tbl(bkpt_rec - 1).bkpt_dtls_tbl(bkpt_dtl_rec).group_bkpt_vol_start;

                    l_prorated_grp_vol_end
                        := NVL(bkpts_tbl(bkpt_rec - 1).bkpt_dtls_tbl(bkpt_dtl_rec).group_bkpt_vol_end, 0);

                END IF;

              ELSE

                l_prorated_grp_vol_start
                := bkpts_tbl(bkpt_rec - 1).bkpt_dtls_tbl(bkpt_dtl_rec).group_bkpt_vol_start
                   * groups_cur_tbl(grp_rec).proration_factor
                   * l_proration_factor;

                l_prorated_grp_vol_end
                := NVL(bkpts_tbl(bkpt_rec - 1).bkpt_dtls_tbl(bkpt_dtl_rec).group_bkpt_vol_end, 0)
                   * groups_cur_tbl(grp_rec).proration_factor
                   * l_proration_factor;

              END IF;

              pn_var_trx_pkg.insert_trx_dtl
              (p_trx_detail_id            => l_trx_dtl_id
              ,p_trx_header_id            => l_trx_hdr_id
              ,p_bkpt_detail_id           => bkpts_tbl(bkpt_rec - 1).
                                               bkpt_dtls_tbl(bkpt_dtl_rec).
                                                 bkpt_detail_id
              ,p_bkpt_rate                => bkpts_tbl(bkpt_rec - 1).
                                               bkpt_dtls_tbl(bkpt_dtl_rec).
                                                 bkpt_rate
              ,p_prorated_grp_vol_start   => l_prorated_grp_vol_start
              ,p_prorated_grp_vol_end     => l_prorated_grp_vol_end
              ,p_fy_pr_grp_vol_start      => NULL
              ,p_fy_pr_grp_vol_end        => NULL
              ,p_ly_pr_grp_vol_start      => NULL
              ,p_ly_pr_grp_vol_end        => NULL
              ,p_pr_grp_blended_vol_start => NULL
              ,p_pr_grp_blended_vol_end   => NULL
              ,p_ytd_group_vol_start      => NULL
              ,p_ytd_group_vol_end        => NULL
              ,p_blended_period_vol_start => NULL
              ,p_blended_period_vol_end   => NULL
              ,p_org_id                   => l_org_id
              ,p_last_update_date         => NULL
              ,p_last_updated_by          => NULL
              ,p_creation_date            => NULL
              ,p_created_by               => NULL
              ,p_last_update_login        => NULL);

            END LOOP; /* FOR bkpt_dtl_rec IN 0..bkpts_tbl(bkpt_rec).bkpt_dtls_tbl.COUNT */

            l_calc_prd_start_dt := bkpts_tbl(bkpt_rec).bkpt_start_date;
            l_calc_prd_end_dt := groups_cur_tbl(grp_rec).grp_end_date;

          END IF;

        END LOOP; /* loop for breakpoints */

        /* determine proration */
        l_proration_factor
          := ((l_calc_prd_end_dt - l_calc_prd_start_dt) + 1)
              /((groups_cur_tbl(grp_rec).grp_end_date
                 - groups_cur_tbl(grp_rec).grp_start_date) + 1);

        /* need to create TRX headers and details */

        /* create header */
        pn_var_trx_pkg.insert_trx_hdr
        (p_trx_header_id         => l_trx_hdr_id
        ,p_var_rent_id           => period_rec.var_rent_id
        ,p_period_id             => period_rec.period_id
        ,p_line_item_id          => line_item_rec.line_item_id
        ,p_grp_date_id           => groups_cur_tbl(grp_rec).grp_date_id
        ,p_calc_prd_start_date   => l_calc_prd_start_dt
        ,p_calc_prd_end_date     => l_calc_prd_end_dt
        ,p_var_rent_summ_id      => NULL
        ,p_line_item_group_id    => line_item_rec.line_default_id
        ,p_reset_group_id        => NULL
        ,p_proration_factor      => l_proration_factor
        ,p_reporting_group_sales => NULL
        ,p_prorated_group_sales  => NULL
        ,p_ytd_sales             => NULL
        ,p_fy_proration_sales    => NULL
        ,p_ly_proration_sales    => NULL
        ,p_percent_rent_due      => NULL
        ,p_ytd_percent_rent      => NULL
        ,p_calculated_rent       => NULL
        ,p_prorated_rent_due     => NULL
        ,p_invoice_flag          => NULL
        ,p_org_id                => l_org_id
        ,p_last_update_date      => NULL
        ,p_last_updated_by       => NULL
        ,p_creation_date         => NULL
        ,p_created_by            => NULL
        ,p_last_update_login     => NULL);

        /* create details */
        FOR bkpt_dtl_rec IN 1..bkpts_tbl(l_curr_bkpt_ctr).bkpt_dtls_tbl.COUNT LOOP

          IF l_proration_rule = pn_var_trx_pkg.G_PRORUL_NP THEN
            IF l_calculation_method = pn_var_trx_pkg.G_CALC_CUMULATIVE THEN
              l_prorated_grp_vol_start
                 := bkpts_tbl(l_curr_bkpt_ctr).bkpt_dtls_tbl(bkpt_dtl_rec).period_bkpt_vol_start;
              l_prorated_grp_vol_end
                 := NVL(bkpts_tbl(l_curr_bkpt_ctr).bkpt_dtls_tbl(bkpt_dtl_rec).period_bkpt_vol_end, 0);

            ELSE
              l_prorated_grp_vol_start
                 := bkpts_tbl(l_curr_bkpt_ctr).bkpt_dtls_tbl(bkpt_dtl_rec).group_bkpt_vol_start;
              l_prorated_grp_vol_end
                 := NVL(bkpts_tbl(l_curr_bkpt_ctr).bkpt_dtls_tbl(bkpt_dtl_rec).group_bkpt_vol_end, 0);
            END IF;


          ELSE

            l_prorated_grp_vol_start
              := bkpts_tbl(l_curr_bkpt_ctr).bkpt_dtls_tbl(bkpt_dtl_rec).group_bkpt_vol_start
                  * groups_cur_tbl(grp_rec).proration_factor
                  * l_proration_factor;

            l_prorated_grp_vol_end
              := NVL(bkpts_tbl(l_curr_bkpt_ctr).bkpt_dtls_tbl(bkpt_dtl_rec).group_bkpt_vol_end, 0)
                  * groups_cur_tbl(grp_rec).proration_factor
                  * l_proration_factor;

          END IF;

          pn_var_trx_pkg.insert_trx_dtl
          (p_trx_detail_id            => l_trx_dtl_id
          ,p_trx_header_id            => l_trx_hdr_id
          ,p_bkpt_detail_id           => bkpts_tbl(l_curr_bkpt_ctr).
                                           bkpt_dtls_tbl(bkpt_dtl_rec).
                                             bkpt_detail_id
          ,p_bkpt_rate                => bkpts_tbl(l_curr_bkpt_ctr).
                                           bkpt_dtls_tbl(bkpt_dtl_rec).
                                             bkpt_rate
          ,p_prorated_grp_vol_start   => l_prorated_grp_vol_start
          ,p_prorated_grp_vol_end     => l_prorated_grp_vol_end
          ,p_fy_pr_grp_vol_start      => NULL
          ,p_fy_pr_grp_vol_end        => NULL
          ,p_ly_pr_grp_vol_start      => NULL
          ,p_ly_pr_grp_vol_end        => NULL
          ,p_pr_grp_blended_vol_start => NULL
          ,p_pr_grp_blended_vol_end   => NULL
          ,p_ytd_group_vol_start      => NULL
          ,p_ytd_group_vol_end        => NULL
          ,p_blended_period_vol_start => NULL
          ,p_blended_period_vol_end   => NULL
          ,p_org_id                   => l_org_id
          ,p_last_update_date         => NULL
          ,p_last_updated_by          => NULL
          ,p_creation_date            => NULL
          ,p_created_by               => NULL
          ,p_last_update_login        => NULL);

        END LOOP; /* FOR bkpt_dtl_rec IN 0..bkpts_tbl(bkpt_rec).bkpt_dtls_tbl.COUNT */

        l_group_counter := l_group_counter + 1;

      END LOOP; /* loop for all groups */

      l_line_item_counter := l_line_item_counter + 1;

    END LOOP; /* loop for all line items in a period */

    l_prd_counter := l_prd_counter + 1;


  END LOOP; /* loop for all periods */

  /* get the grp IDs right if any trx was updated */
  IF l_trx_create_upd_flag THEN
     pnp_debug_pkg.log('Trx updated');
    /* groups the lines across the periods */
    pn_var_trx_pkg.populate_line_grp_id(p_var_rent_id => p_var_rent_id);

    /* populate the reset group IDs */
    pn_var_trx_pkg.populate_reset_grp_id(p_var_rent_id => p_var_rent_id);
    /* populate fy_pr_grp_vol_start - end,
                ly_pr_grp_vol_start - end,
                invoice_flag
       for FY, LY, FLY */
     FOR i in 1..for_data_t.COUNT LOOP
        pnp_debug_pkg.log('line_item_id:'||for_data_t(i).line_item_id);
        pnp_debug_pkg.log('grp_date_id:'||for_data_t(i).grp_date_id);
        pnp_debug_pkg.log('reset_group_id:'||for_data_t(i).reset_group_id);
        pnp_debug_pkg.log('var_rent_id:'||for_data_t(i).var_rent_id);
        pnp_debug_pkg.log('REPORTING_GROUP_SALES_FOR:'||for_data_t(i).REPORTING_GROUP_SALES_FOR);
        pnp_debug_pkg.log('CALCULATED_RENT_FOR:'||for_data_t(i).CALCULATED_RENT_FOR);

        UPDATE
        pn_var_trx_headers_all
        SET
           REPORTING_GROUP_SALES_FOR = for_data_t(i).REPORTING_GROUP_SALES_FOR
           ,PRORATED_GROUP_SALES_FOR  = for_data_t(i).PRORATED_GROUP_SALES_FOR
           ,YTD_SALES_FOR             = for_data_t(i).YTD_SALES_FOR
           ,CALCULATED_RENT_FOR = round(for_data_t(i).CALCULATED_RENT_FOR,g_precision)  /*Bug # 6031202*/
           ,PERCENT_RENT_DUE_FOR = round(for_data_t(i).PERCENT_RENT_DUE_FOR,g_precision)
           ,YTD_PERCENT_RENT_FOR = round(for_data_t(i).YTD_PERCENT_RENT_FOR,g_precision)
        WHERE var_rent_id = for_data_t(i).var_rent_id AND
              grp_date_id = for_data_t(i).grp_date_id AND
              line_item_id = for_data_t(i).line_item_id AND
              reset_group_id = for_data_t(i).reset_group_id;
     END LOOP;

    IF l_proration_rule = pn_var_trx_pkg.G_PRORUL_LY THEN

      /* populate ly_pr_grp_vol_start - end, invoice_flag */
      pn_var_trx_pkg.populate_ly_pro_vol
         ( p_var_rent_id        => p_var_rent_id
          ,p_proration_rule     => l_proration_rule
          ,p_vr_commencement_dt => l_vr_commencement_date
          ,p_vr_termination_dt  => l_vr_termination_date);

    ELSIF l_proration_rule = pn_var_trx_pkg.G_PRORUL_FY THEN

      /* populate fy_pr_grp_vol_start - end, invoice_flag */
      pn_var_trx_pkg.populate_fy_pro_vol
         ( p_var_rent_id        => p_var_rent_id
          ,p_proration_rule     => l_proration_rule
          ,p_vr_commencement_dt => l_vr_commencement_date
          ,p_vr_termination_dt  => l_vr_termination_date);

    ELSIF l_proration_rule = pn_var_trx_pkg.G_PRORUL_FLY THEN

      /* populate ly_pr_grp_vol_start - end, invoice_flag */
      pn_var_trx_pkg.populate_ly_pro_vol
         ( p_var_rent_id        => p_var_rent_id
          ,p_proration_rule     => l_proration_rule
          ,p_vr_commencement_dt => l_vr_commencement_date
          ,p_vr_termination_dt  => l_vr_termination_date);

      /* populate fy_pr_grp_vol_start - end, invoice_flag */
      pn_var_trx_pkg.populate_fy_pro_vol
         ( p_var_rent_id        => p_var_rent_id
          ,p_proration_rule     => l_proration_rule
          ,p_vr_commencement_dt => l_vr_commencement_date
          ,p_vr_termination_dt  => l_vr_termination_date);

    ELSIF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_CYP
                               ,pn_var_trx_pkg.G_PRORUL_CYNP) THEN

      /* populate blended_period/grp_vol_start - end */
      pn_var_trx_pkg.populate_blended_grp_vol
         ( p_var_rent_id    => p_var_rent_id
          ,p_proration_rule => l_proration_rule);

    END IF;

    pnp_debug_pkg.log(' call pn_var_trx_pkg.populate_ytd_pro_vol'); /* 8616530 */
    /* ALWAYS populate the ytd_group_vol_start - end - useful */
    pn_var_trx_pkg.populate_ytd_pro_vol
      ( p_var_rent_id    => p_var_rent_id
       ,p_proration_rule => l_proration_rule);

    IF l_calculation_method = pn_var_trx_pkg.G_CALC_CUMULATIVE THEN
      /* populate the blended_period_vol_start - end */
      pn_var_trx_pkg.populate_blended_period_vol
        ( p_var_rent_id    => p_var_rent_id
         ,p_proration_rule => l_proration_rule
         ,p_calc_method    => l_calculation_method);

    END IF;

  END IF;

  FOR j IN 1..periods_table.COUNT  LOOP

    l_max_end_date := periods_table(j).start_date;

    FOR i IN 1..trueup_table.COUNT  LOOP
      IF l_max_end_date < trueup_table(i).calc_prd_end_date AND
         trueup_table(i).period_id = periods_table(j).period_id THEN
         l_max_end_date := trueup_table(i).calc_prd_end_date;
      END IF;
    END LOOP;

    FOR i IN 1..trueup_table.COUNT  LOOP
      IF periods_table(j).end_date = l_max_end_date THEN
       /* Added var_rent_id filter to improve the performance */
        UPDATE
        pn_var_trx_headers_all
        SET
          trueup_rent_due = round(trueup_table(i).trueup_rent_due,g_precision)  /*Bug # 6031202*/
        WHERE
        var_rent_id = p_var_rent_id AND
        line_item_id = trueup_table(i).line_item_id AND
        calc_prd_start_date = trueup_table(i).calc_prd_start_date AND
        calc_prd_end_date = trueup_table(i).calc_prd_end_date AND
        reset_group_id = trueup_table(i).reset_group_id AND
        period_id = periods_table(j).period_id;
       END IF;
    END LOOP;

  END LOOP;

  /* reset the bkpt_update_flag */
  FORALL line_rec IN 1..l_line_items_lock4bkpt_t.COUNT
    UPDATE
    pn_var_lines_all
    SET
     bkpt_update_flag = NULL
    ,sales_vol_update_flag = 'Y'
    WHERE
    line_item_id = l_line_items_lock4bkpt_t(line_rec);

  /* UN-lock the line items */
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_transactions;

/* ----------------------------------------------------------------------
   -------------------- PROCEDURES TO POPULATE SALES --------------------
   ---------------------------------------------------------------------- */

--------------------------------------------------------------------------------
--  NAME         : get_calc_prd_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE get_calc_prd_sales( p_var_rent_id  IN NUMBER
                             ,p_period_id    IN NUMBER
                             ,p_line_item_id IN NUMBER
                             ,p_grp_date_id  IN NUMBER
                             ,p_start_date   IN DATE
                             ,p_end_date     IN DATE
                             ,x_pro_sales    OUT NOCOPY NUMBER
                             ,x_sales        OUT NOCOPY NUMBER) IS

  /* get volumes for a calculation period */
  CURSOR vol_hist_c1 ( p_prd_id   IN NUMBER
                      ,p_line_id  IN NUMBER
                      ,p_grp_id   IN NUMBER) IS
    SELECT
    SUM(actual_amount) AS calc_prd_actual_volume
    FROM
    pn_var_vol_hist_all sales
    WHERE
    sales.period_id = p_prd_id AND
    sales.line_item_id = p_line_id AND
    sales.grp_date_id = p_grp_id AND
    vol_hist_status_code = pn_var_trx_pkg.G_SALESVOL_STATUS_APPROVED;

  /* get volumes for a calculation sub-period */
  CURSOR vol_hist_c2 ( p_prd_id   IN NUMBER
                      ,p_line_id  IN NUMBER
                      ,p_grp_id   IN NUMBER
                      ,p_start_dt IN DATE
                      ,p_end_dt   IN DATE) IS
    SELECT
     sales.actual_amount
    ,sales.start_date
    ,sales.end_date
    FROM
    pn_var_vol_hist_all sales
    WHERE
    sales.period_id = p_prd_id AND
    sales.line_item_id = p_line_id AND
    sales.grp_date_id = p_grp_id AND
    sales.start_date <= p_end_dt AND
    sales.end_date >= p_start_dt AND
    vol_hist_status_code = pn_var_trx_pkg.G_SALESVOL_STATUS_APPROVED;

  /* get grp dates */
  CURSOR grp_dates_c(p_grp_id IN NUMBER) IS
  SELECT
   grp.grp_start_date
  ,grp.grp_end_date
  FROM
  pn_var_grp_dates_all grp
  WHERE
  grp.grp_date_id = p_grp_id;

  l_grp_start_date DATE;
  l_grp_end_date   DATE;

  l_calc_prd_sales     NUMBER;
  l_pro_calc_prd_sales NUMBER;

BEGIN

  /* get group / calc period dates */
  FOR grp_rec IN grp_dates_c(p_grp_id => p_grp_date_id) LOOP
    l_grp_start_date := grp_rec.grp_start_date;
    l_grp_end_date   := grp_rec.grp_end_date;
  END LOOP;

  l_calc_prd_sales := 0;
  l_pro_calc_prd_sales := 0;

  /* get all APPROVED sales for a group / calc period */
  FOR sales_rec IN vol_hist_c1 ( p_prd_id   => p_period_id
                                ,p_line_id  => p_line_item_id
                                ,p_grp_id   => p_grp_date_id)
  LOOP
    l_calc_prd_sales := l_calc_prd_sales + sales_rec.calc_prd_actual_volume;
  END LOOP;

  /* if calc sub period dates are same as grp / calc period start-end dates */
  IF l_grp_start_date = p_start_date AND
     l_grp_end_date = p_end_date
  THEN

    /* then prorated sales = total sales */
    l_pro_calc_prd_sales := l_calc_prd_sales;

  ELSE

    /* else, sum all sales to get the prorated sales */
    FOR sales_rec IN vol_hist_c2 ( p_prd_id   => p_period_id
                                  ,p_line_id  => p_line_item_id
                                  ,p_grp_id   => p_grp_date_id
                                  ,p_start_dt => p_start_date
                                  ,p_end_dt   => p_end_date)
    LOOP

      /* if sales volume dates between calc sub period dates */
      IF sales_rec.start_date >= p_start_date AND
         sales_rec.end_date <= p_end_date
      THEN
        /* consider full volume */
        l_pro_calc_prd_sales := l_pro_calc_prd_sales + sales_rec.actual_amount;

      /* else if sales volume dates overlap calc sub period dates */
      ELSIF sales_rec.start_date <= p_end_date AND
            sales_rec.end_date >= p_start_date
      THEN
        /* then consider prorated volume */
        l_pro_calc_prd_sales
        := l_pro_calc_prd_sales
           + sales_rec.actual_amount
             * ((LEAST(sales_rec.end_date, p_end_date)
                 - GREATEST(sales_rec.start_date, p_start_date)) + 1)
               / ((sales_rec.end_date - sales_rec.start_date) + 1);

      END IF;

    END LOOP;

  END IF;

  x_pro_sales := l_pro_calc_prd_sales;
  x_sales     := l_calc_prd_sales;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_calc_prd_sales;

--------------------------------------------------------------------------------
--  NAME         : get_calc_prd_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
FUNCTION get_calc_prd_sales( p_var_rent_id  IN NUMBER
                            ,p_period_id    IN NUMBER
                            ,p_line_item_id IN NUMBER
                            ,p_grp_date_id  IN NUMBER
                            ,p_start_date   IN DATE
                            ,p_end_date     IN DATE)
RETURN NUMBER IS

  /* get volumes for a calculation period */
  CURSOR vol_hist_c1 ( p_prd_id   IN NUMBER
                      ,p_line_id  IN NUMBER
                      ,p_grp_id   IN NUMBER) IS
    SELECT
    SUM(actual_amount) AS calc_prd_actual_volume
    FROM
    pn_var_vol_hist_all sales
    WHERE
    sales.period_id = p_prd_id AND
    sales.line_item_id = p_line_id AND
    sales.grp_date_id = p_grp_id AND
    vol_hist_status_code = pn_var_trx_pkg.G_SALESVOL_STATUS_APPROVED;

  /* get volumes for a calculation sub-period */
  CURSOR vol_hist_c2 ( p_prd_id   IN NUMBER
                      ,p_line_id  IN NUMBER
                      ,p_grp_id   IN NUMBER
                      ,p_start_dt IN DATE
                      ,p_end_dt   IN DATE) IS
    SELECT
     sales.actual_amount
    ,sales.start_date
    ,sales.end_date
    FROM
    pn_var_vol_hist_all sales
    WHERE
    sales.period_id = p_prd_id AND
    sales.line_item_id = p_line_id AND
    sales.grp_date_id = p_grp_id AND
    sales.start_date <= p_end_dt AND
    sales.end_date >= p_start_dt AND
    vol_hist_status_code = pn_var_trx_pkg.G_SALESVOL_STATUS_APPROVED;

  /* get grp dates */
  CURSOR grp_dates_c(p_grp_id IN NUMBER) IS
  SELECT
   grp.grp_start_date
  ,grp.grp_end_date
  FROM
  pn_var_grp_dates_all grp
  WHERE
  grp.grp_date_id = p_grp_id;

  l_grp_start_date DATE;
  l_grp_end_date   DATE;

  l_calc_prd_sales     NUMBER;
  l_pro_calc_prd_sales NUMBER;

BEGIN

  /* get group / calc period dates */
  FOR grp_rec IN grp_dates_c(p_grp_id => p_grp_date_id) LOOP
    l_grp_start_date := grp_rec.grp_start_date;
    l_grp_end_date   := grp_rec.grp_end_date;
  END LOOP;

  l_pro_calc_prd_sales := 0;

  /* if calc sub period dates are same as grp / calc period start-end dates */
  IF l_grp_start_date = p_start_date AND
     l_grp_end_date = p_end_date
  THEN

    /* get all APPROVED sales for a group / calc period
       prorated sales = total sales */
    FOR sales_rec IN vol_hist_c1 ( p_prd_id   => p_period_id
                                  ,p_line_id  => p_line_item_id
                                  ,p_grp_id   => p_grp_date_id)
    LOOP
      l_pro_calc_prd_sales := l_pro_calc_prd_sales + sales_rec.calc_prd_actual_volume;
    END LOOP;

  ELSE

    /* else, sum all sales to get the prorated sales */
    FOR sales_rec IN vol_hist_c2 ( p_prd_id   => p_period_id
                                  ,p_line_id  => p_line_item_id
                                  ,p_grp_id   => p_grp_date_id
                                  ,p_start_dt => p_start_date
                                  ,p_end_dt   => p_end_date)
    LOOP

      /* if sales volume dates between calc sub period dates */
      IF sales_rec.start_date >= p_start_date AND
         sales_rec.end_date <= p_end_date
      THEN
        /* consider full volume */
        l_pro_calc_prd_sales := l_pro_calc_prd_sales + sales_rec.actual_amount;

      /* else if sales volume dates overlap calc sub period dates */
      ELSIF sales_rec.start_date <= p_end_date AND
            sales_rec.end_date >= p_start_date
      THEN
        /* then consider prorated volume */
        l_pro_calc_prd_sales
        := l_pro_calc_prd_sales
           + sales_rec.actual_amount
             * ((LEAST(sales_rec.end_date, p_end_date)
                 - GREATEST(sales_rec.start_date, p_start_date)) + 1)
               / ((sales_rec.end_date - sales_rec.start_date) + 1);

      END IF;

    END LOOP;

  END IF;

  RETURN l_pro_calc_prd_sales;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_calc_prd_sales;

--------------------------------------------------------------------------------
--  NAME         : populate_ly_pro_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_ly_pro_sales( p_var_rent_id        IN NUMBER
                                ,p_proration_rule     IN VARCHAR2
                                ,p_vr_commencement_dt IN DATE
                                ,p_vr_termination_dt  IN DATE) IS

  /* get VR details */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_vr_commencement_date DATE;
  l_vr_termination_date  DATE;
  l_vr_proration_rule    VARCHAR2(30);
  l_ly_start_date        DATE;

  /* get the last partial period */
  CURSOR last_period_c( p_vr_id     IN NUMBER
                       ,p_term_date IN DATE) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd
    WHERE
    prd.var_rent_id = p_var_rent_id AND
    prd.end_date = p_term_date;

  l_last_period_id NUMBER;
  l_partial_period VARCHAR2(1);

BEGIN

  /* get VR details */
  IF p_proration_rule IS NULL OR
     p_vr_commencement_dt IS NULL OR
     p_vr_termination_dt IS NULL
  THEN
    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_vr_commencement_date := vr_rec.commencement_date;
      l_vr_termination_date  := vr_rec.termination_date;
      l_vr_proration_rule    := vr_rec.proration_rule;
    END LOOP;
  ELSE
    l_vr_commencement_date := p_vr_commencement_dt;
    l_vr_termination_date  := p_vr_termination_dt;
    l_vr_proration_rule    := p_proration_rule;
  END IF;

  l_ly_start_date := ADD_MONTHS(l_vr_termination_date, -12) + 1;

  IF l_vr_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_LY
                             ,pn_var_trx_pkg.G_PRORUL_FLY) THEN

    FOR prd_rec IN last_period_c( p_vr_id     => p_var_rent_id
                                 ,p_term_date => l_vr_termination_date)
    LOOP
      l_last_period_id := prd_rec.period_id;
      l_partial_period := NVL(prd_rec.partial_period, 'N');
    END LOOP;

    /* init ly_proration_sales */
    UPDATE
    pn_var_trx_headers_all
    SET
    ly_proration_sales = NULL
    WHERE
    var_rent_id = p_var_rent_id;

    IF l_partial_period = 'Y' THEN

      /* populate ly_proration_sales */
      UPDATE
      pn_var_trx_headers_all hdr
      SET
      hdr.ly_proration_sales = hdr.prorated_group_sales
      WHERE
      hdr.var_rent_id = p_var_rent_id AND
      hdr.calc_prd_start_date >= l_ly_start_date;

      /* populate ly_proration_sales if LY start date does not
         coincide with a calc prd start date */
      UPDATE
      pn_var_trx_headers_all
      SET
      ly_proration_sales
      = pn_var_trx_pkg.get_calc_prd_sales( var_rent_id
                                          ,period_id
                                          ,line_item_id
                                          ,grp_date_id
                                          ,l_ly_start_date
                                          ,calc_prd_end_date)
      WHERE
      var_rent_id = p_var_rent_id AND
      l_ly_start_date BETWEEN (calc_prd_start_date + 1)
                          AND calc_prd_end_date;

    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_ly_pro_sales;

--------------------------------------------------------------------------------
--  NAME         : populate_fy_pro_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_fy_pro_sales( p_var_rent_id        IN NUMBER
                                ,p_proration_rule     IN VARCHAR2
                                ,p_vr_commencement_dt IN DATE
                                ,p_vr_termination_dt  IN DATE) IS

  /* get VR details */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_vr_commencement_date DATE;
  l_vr_termination_date  DATE;
  l_vr_proration_rule    VARCHAR2(30);
  l_fy_end_date          DATE;

  /* get the first partial period */
  CURSOR first_period_c( p_vr_id     IN NUMBER
                        ,p_comm_date IN DATE) IS
    SELECT
     prd.period_id
    ,prd.partial_period
    FROM
    pn_var_periods_all prd
    WHERE
    prd.var_rent_id = p_var_rent_id AND
    prd.start_date = p_comm_date;

  l_first_period_id NUMBER;
  l_partial_period VARCHAR2(1);

BEGIN

  /* get VR details */
  IF p_proration_rule IS NULL OR
     p_vr_commencement_dt IS NULL OR
     p_vr_termination_dt IS NULL
  THEN
    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_vr_commencement_date := vr_rec.commencement_date;
      l_vr_termination_date  := vr_rec.termination_date;
      l_vr_proration_rule    := vr_rec.proration_rule;
    END LOOP;
  ELSE
    l_vr_commencement_date := p_vr_commencement_dt;
    l_vr_termination_date  := p_vr_termination_dt;
    l_vr_proration_rule    := p_proration_rule;
  END IF;

  l_fy_end_date := ADD_MONTHS(l_vr_commencement_date, 12) - 1;

  IF l_vr_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_FY
                             ,pn_var_trx_pkg.G_PRORUL_FLY) THEN

    FOR prd_rec IN first_period_c( p_vr_id     => p_var_rent_id
                                 ,p_comm_date  => l_vr_commencement_date)
    LOOP
      l_first_period_id := prd_rec.period_id;
      l_partial_period  := NVL(prd_rec.partial_period, 'N');
    END LOOP;

    /* init ly_proration_sales */
    UPDATE
    pn_var_trx_headers_all
    SET
    fy_proration_sales = NULL
    WHERE
    var_rent_id = p_var_rent_id;

    IF l_partial_period = 'Y' THEN
       /* populate ly_proration_sales */
       UPDATE
       pn_var_trx_headers_all hdr
       SET
       hdr.fy_proration_sales = hdr.prorated_group_sales
       WHERE
       hdr.var_rent_id = p_var_rent_id AND
       hdr.calc_prd_end_date <= l_fy_end_date;

       /* populate fy_proration_sales if FY end date does not
          coincide with a calc prd end date */
       UPDATE
       pn_var_trx_headers_all
       SET
       fy_proration_sales
       = pn_var_trx_pkg.get_calc_prd_sales( var_rent_id
                                           ,period_id
                                           ,line_item_id
                                           ,grp_date_id
                                           ,calc_prd_start_date
                                           ,l_fy_end_date)
       WHERE
       var_rent_id = p_var_rent_id AND
       l_fy_end_date BETWEEN calc_prd_start_date
                         AND (calc_prd_end_date - 1);
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_fy_pro_sales;

--------------------------------------------------------------------------------
--  NAME         : populate_ytd_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_ytd_sales( p_var_rent_id    IN NUMBER
                             ,p_proration_rule IN VARCHAR2) IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_proration_rule       pn_var_rents_all.proration_rule%TYPE;

  /* get the line items with updated sales for FY, LY, FLY, STD, NP */
  CURSOR lines_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    sales_vol_update_flag = 'Y'
    ORDER BY
     period_id
    ,line_item_id;

  /* get the line items with updated sales for CYP, CYNP */
  CURSOR lines_cs_c( p_vr_id       IN NUMBER
                    ,p_part_prd_id IN NUMBER
                    ,p_full_prd_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    sales_vol_update_flag = 'Y' AND
    period_id NOT IN (p_part_prd_id, p_full_prd_id)
    ORDER BY
     period_id
    ,line_item_id;

  /* get the period details - we use the first 2 periods */
  CURSOR periods_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,start_date
    ,end_date
    ,partial_period
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
    start_date;

  /* period info */
  l_part_prd_id           NUMBER;
  l_part_prd_start_dt     DATE;
  l_part_prd_end_dt       DATE;
  l_part_prd_partial_flag VARCHAR2(1);

  l_full_prd_id           NUMBER;
  l_full_prd_start_dt     DATE;
  l_full_prd_end_dt       DATE;
  l_full_prd_partial_flag VARCHAR2(1);

  /* ytd for STD, NP, FY, LY, FLY */
  CURSOR ytd_sales_c( p_vr_ID   IN NUMBER
                     ,p_prd_ID  IN NUMBER
                     ,p_line_ID IN NUMBER) IS
    SELECT
     hdr.trx_header_id
    ,SUM(hdr.prorated_group_sales) OVER
      (PARTITION BY
        hdr.period_id
       ,hdr.line_item_id
       ,hdr.reset_group_id
       ORDER BY
       hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_sales
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_ID AND
    hdr.line_item_id = p_line_ID
    ORDER BY
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.calc_prd_start_date;

  /* ytd for CYP, CYNP combined period */
  CURSOR ytd_sales_cs_c( p_vr_ID       IN NUMBER
                        ,p_part_prd_id IN NUMBER
                        ,p_full_prd_id IN NUMBER) IS
    SELECT
     hdr.trx_header_id
    ,SUM(hdr.prorated_group_sales) OVER
      (PARTITION BY
        hdr.line_item_group_id
       ORDER BY
        hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_sales
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id IN (p_part_prd_id, p_full_prd_id)
    ORDER BY
     hdr.line_item_group_id
    ,hdr.calc_prd_start_date;

  /* counters */
  l_counter1 NUMBER;

  /* plsql tables for ytd dates and trx hdr */
  trx_hdr_t   NUM_T;
  ytd_sales_t NUM_T;

BEGIN

  pnp_debug_pkg.log('++++ pn_var_trx_pkg.populate_ytd_sales START ++++');

  /* get VR details */
  IF p_proration_rule IS NULL THEN

    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP

      l_proration_rule     := vr_rec.proration_rule;

    END LOOP;

  ELSE

    l_proration_rule     := p_proration_rule;

  END IF;

  pnp_debug_pkg.log('Called with: ');
  pnp_debug_pkg.log('    p_var_rent_id:        '||p_var_rent_id);
  pnp_debug_pkg.log('    l_proration_rule:     '||l_proration_rule);

  /* l_proration_rule based decisions */
  IF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_FY
                          ,pn_var_trx_pkg.G_PRORUL_LY
                          ,pn_var_trx_pkg.G_PRORUL_FLY
                          ,pn_var_trx_pkg.G_PRORUL_NP
                          ,pn_var_trx_pkg.G_PRORUL_STD) THEN

    FOR line_rec IN lines_c(p_vr_id => p_var_rent_id) LOOP

      trx_hdr_t.DELETE;
      ytd_sales_t.DELETE;

      OPEN ytd_sales_c( p_vr_ID   => p_var_rent_id
                       ,p_prd_ID  => line_rec.period_id
                       ,p_line_ID => line_rec.line_item_id);

      FETCH ytd_sales_c BULK COLLECT INTO
       trx_hdr_t
      ,ytd_sales_t;

      CLOSE ytd_sales_c;

      FORALL i IN 1..trx_hdr_t.COUNT
        UPDATE
        pn_var_trx_headers_all
        SET
        ytd_sales = ytd_sales_t(i)
        WHERE
        trx_header_id = trx_hdr_t(i);

    END LOOP;

  ELSIF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_CYP
                             ,pn_var_trx_pkg.G_PRORUL_CYNP) THEN

    /* fetch partial and full period details */
    l_counter1 := 0;
    FOR prd_rec IN periods_c(p_vr_id => p_var_rent_id) LOOP

      l_counter1 := l_counter1 + 1;

      IF l_counter1 = 1 THEN
        l_part_prd_id           := prd_rec.period_id;
        l_part_prd_start_dt     := prd_rec.start_date;
        l_part_prd_end_dt       := prd_rec.end_date;
        l_part_prd_partial_flag := prd_rec.partial_period;

      ELSIF l_counter1 = 2 THEN
        l_full_prd_id           := prd_rec.period_id;
        l_full_prd_start_dt     := prd_rec.start_date;
        l_full_prd_end_dt       := prd_rec.end_date;
        l_full_prd_partial_flag := prd_rec.partial_period;

      ELSE
        EXIT;

      END IF;

    END LOOP; /* fetch partial and full period details */

    trx_hdr_t.DELETE;
    ytd_sales_t.DELETE;

    OPEN ytd_sales_cs_c( p_vr_ID       => p_var_rent_id
                        ,p_part_prd_id => l_part_prd_id
                        ,p_full_prd_id => l_full_prd_id);

    FETCH ytd_sales_cs_c BULK COLLECT INTO
     trx_hdr_t
    ,ytd_sales_t;

    CLOSE ytd_sales_cs_c;

    FORALL i IN 1..trx_hdr_t.COUNT
      UPDATE
      pn_var_trx_headers_all
      SET
      ytd_sales = ytd_sales_t(i)
      WHERE
      trx_header_id = trx_hdr_t(i);

    /* loop for all lines */
    FOR line_rec IN lines_cs_c ( p_vr_id       => p_var_rent_id
                                ,p_part_prd_id => l_part_prd_id
                                ,p_full_prd_id => l_full_prd_id)
    LOOP

      trx_hdr_t.DELETE;
      ytd_sales_t.DELETE;

      OPEN ytd_sales_c( p_vr_ID   => p_var_rent_id
                       ,p_prd_ID  => line_rec.period_id
                       ,p_line_ID => line_rec.line_item_id);

      FETCH ytd_sales_c BULK COLLECT INTO
       trx_hdr_t
      ,ytd_sales_t;

      CLOSE ytd_sales_c;

      FORALL i IN 1..trx_hdr_t.COUNT
        UPDATE
        pn_var_trx_headers_all
        SET
        ytd_sales = ytd_sales_t(i)
        WHERE
        trx_header_id = trx_hdr_t(i);

    END LOOP; /* loop for all lines */

  END IF; /* l_proration_rule based decisions */

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_ytd_sales;

--------------------------------------------------------------------------------
--  NAME         : populate_sales
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  dd-mon-yyyy  name     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_sales(p_var_rent_id IN NUMBER) IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.org_id
    ,vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    ,vr.cumulative_vol
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_org_id               pn_var_rents_all.org_id%TYPE;
  l_vr_commencement_date pn_var_rents_all.commencement_date%TYPE;
  l_vr_termination_date  pn_var_rents_all.termination_date%TYPE;
  l_proration_rule       pn_var_rents_all.proration_rule%TYPE;
  l_calculation_method   pn_var_rents_all.cumulative_vol%TYPE;

  /* get the line items with updated sales */
  CURSOR lines_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    sales_vol_update_flag = 'Y'
    ORDER BY
     period_id
    ,line_item_id;

  /* get the calc periods to update sales data */
  CURSOR calc_periods_c( p_vr_id   IN NUMBER
                        ,p_prd_id  IN NUMBER
                        ,p_line_id IN NUMBER) IS
    SELECT
     hdr.trx_header_id
    ,hdr.var_rent_id
    ,hdr.period_id
    ,hdr.line_item_id
    ,hdr.grp_date_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_id AND
    hdr.line_item_id = p_line_id
    ORDER BY
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date;

  /* data structures */
  trx_hdr_t             NUM_T;
  reporting_grp_sales_t NUM_T;
  prorate_grp_sales_t   NUM_T;

  l_counter NUMBER;

  /* flags */
  l_sales_create_upd_flag BOOLEAN;

  l_line_items_lock4salesvol_t NUM_T;

BEGIN

  /* lock the lines with updated sales */
  l_line_items_lock4salesvol_t.DELETE;

  OPEN line_items_lock4salesvol_c(p_vr_id => p_var_rent_id);
  FETCH line_items_lock4salesvol_c BULK COLLECT INTO l_line_items_lock4salesvol_t;
  CLOSE line_items_lock4salesvol_c;

  /* get the VR details */
  FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP

    l_org_id               := vr_rec.org_id;
    l_vr_commencement_date := vr_rec.commencement_date;
    l_vr_termination_date  := vr_rec.termination_date;
    l_proration_rule       := vr_rec.proration_rule;
    l_calculation_method   := vr_rec.cumulative_vol;

  END LOOP;

  l_sales_create_upd_flag := FALSE;

  l_counter := 0;

  /* for all line items with changed sales volume */
  FOR line_rec IN lines_c(p_vr_id => p_var_rent_id)
  LOOP

    l_sales_create_upd_flag := TRUE;

    trx_hdr_t.DELETE;
    reporting_grp_sales_t.DELETE;
    prorate_grp_sales_t.DELETE;

    /* for all calc sub periods for the line item, get the prorated sales */
    FOR trx_rec IN calc_periods_c( p_vr_id   => p_var_rent_id
                                  ,p_prd_id  => line_rec.period_id
                                  ,p_line_id => line_rec.line_item_id)
    LOOP

      l_counter := l_counter + 1;

      trx_hdr_t(l_counter) := trx_rec.trx_header_id;

      pn_var_trx_pkg.get_calc_prd_sales
        ( p_var_rent_id  => trx_rec.var_rent_id
         ,p_period_id    => trx_rec.period_id
         ,p_line_item_id => trx_rec.line_item_id
         ,p_grp_date_id  => trx_rec.grp_date_id
         ,p_start_date   => trx_rec.calc_prd_start_date
         ,p_end_date     => trx_rec.calc_prd_end_date
         ,x_pro_sales    => prorate_grp_sales_t(l_counter)
         ,x_sales        => reporting_grp_sales_t(l_counter));

    END LOOP;

    /* for all calc sub periods for the line item,
       update the trx headers with the sales */
    IF trx_hdr_t.COUNT > 0 THEN

      FORALL i IN trx_hdr_t.FIRST..trx_hdr_t.LAST
        UPDATE
        pn_var_trx_headers_all
        SET
         reporting_group_sales = reporting_grp_sales_t(i)
        ,prorated_group_sales = prorate_grp_sales_t(i)
        WHERE
        trx_header_id = trx_hdr_t(i);

    END IF;

  END LOOP;

  IF l_sales_create_upd_flag THEN

    IF l_proration_rule = pn_var_trx_pkg.G_PRORUL_LY THEN

      pn_var_trx_pkg.populate_ly_pro_sales
       ( p_var_rent_id        => p_var_rent_id
        ,p_proration_rule     => l_proration_rule
        ,p_vr_commencement_dt => l_vr_commencement_date
        ,p_vr_termination_dt  => l_vr_termination_date);

    ELSIF l_proration_rule = pn_var_trx_pkg.G_PRORUL_FY THEN

      pn_var_trx_pkg.populate_fy_pro_sales
        (  p_var_rent_id        => p_var_rent_id
          ,p_proration_rule     => l_proration_rule
          ,p_vr_commencement_dt => l_vr_commencement_date
          ,p_vr_termination_dt  => l_vr_termination_date);

    ELSIF l_proration_rule = pn_var_trx_pkg.G_PRORUL_FLY THEN

      pn_var_trx_pkg.populate_ly_pro_sales
       ( p_var_rent_id        => p_var_rent_id
        ,p_proration_rule     => l_proration_rule
        ,p_vr_commencement_dt => l_vr_commencement_date
        ,p_vr_termination_dt  => l_vr_termination_date);

      pn_var_trx_pkg.populate_fy_pro_sales
        (  p_var_rent_id        => p_var_rent_id
          ,p_proration_rule     => l_proration_rule
          ,p_vr_commencement_dt => l_vr_commencement_date
          ,p_vr_termination_dt  => l_vr_termination_date);

    END IF;

    /* always populate YTD sales - very useful */
    pn_var_trx_pkg.populate_ytd_sales
      ( p_var_rent_id    => p_var_rent_id
       ,p_proration_rule => l_proration_rule);

  END IF;

  FORALL line_rec IN 1..l_line_items_lock4salesvol_t.COUNT
    UPDATE
    pn_var_lines_all
    SET
    sales_vol_update_flag = NULL
    WHERE
    line_item_id = l_line_items_lock4salesvol_t(line_rec);

  /* UN-lock the lines with updated sales */
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_sales;

--------------------------------------------------------------------------------
--------------- PROCEDURES TO POPULATE PRORATED FORECASTED SALES ---------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--  NAME         : get_calc_prd_sales_for
--  DESCRIPTION  : get forecasted volumes for a calculation period, sub period
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  13-SEP-06     Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE get_calc_prd_sales_for( p_var_rent_id  IN NUMBER
                                 ,p_period_id    IN NUMBER
                                 ,p_line_item_id IN NUMBER
                                 ,p_grp_date_id  IN NUMBER
                                 ,p_start_date   IN DATE
                                 ,p_end_date     IN DATE
                                 ,x_pro_sales    OUT NOCOPY NUMBER
                                 ,x_sales        OUT NOCOPY NUMBER) IS

  /* get forecasted volumes for a calculation period */
  CURSOR vol_hist_sum_c( p_prd_id   IN NUMBER
                        ,p_line_id  IN NUMBER
                        ,p_grp_id   IN NUMBER) IS
    SELECT
    SUM(forecasted_amount) AS calc_prd_forecasted_volume
    FROM
    pn_var_vol_hist_all sales
    WHERE
    sales.period_id = p_prd_id AND
    sales.line_item_id = p_line_id AND
    sales.grp_date_id = p_grp_id;

  /* get forecasted volumes for a calculation sub-period */
  CURSOR vol_hist_c( p_prd_id   IN NUMBER
                    ,p_line_id  IN NUMBER
                    ,p_grp_id   IN NUMBER
                    ,p_start_dt IN DATE
                    ,p_end_dt   IN DATE) IS
    SELECT
     sales.forecasted_amount
    ,sales.start_date
    ,sales.end_date
    FROM
    pn_var_vol_hist_all sales
    WHERE
    sales.period_id = p_prd_id AND
    sales.line_item_id = p_line_id AND
    sales.grp_date_id = p_grp_id AND
    sales.start_date <= p_end_dt AND
    sales.end_date >= p_start_dt;

  /* get grp dates */
  CURSOR grp_dates_c(p_grp_id IN NUMBER) IS
  SELECT
   grp.grp_start_date
  ,grp.grp_end_date
  FROM
  pn_var_grp_dates_all grp
  WHERE
  grp.grp_date_id = p_grp_id;

  l_grp_start_date DATE;
  l_grp_end_date   DATE;

  l_calc_prd_sales     NUMBER;
  l_pro_calc_prd_sales NUMBER;

BEGIN

  /* get group / calc period dates */
  FOR grp_rec IN grp_dates_c(p_grp_id => p_grp_date_id) LOOP
    l_grp_start_date := grp_rec.grp_start_date;
    l_grp_end_date   := grp_rec.grp_end_date;
  END LOOP;

  l_calc_prd_sales := 0;
  l_pro_calc_prd_sales := 0;

  /* get all APPROVED sales for a group / calc period */
  FOR sales_rec IN vol_hist_sum_c ( p_prd_id   => p_period_id
                                ,p_line_id  => p_line_item_id
                                ,p_grp_id   => p_grp_date_id)
  LOOP
    l_calc_prd_sales := l_calc_prd_sales + sales_rec.calc_prd_forecasted_volume;
  END LOOP;

  /* if calc sub period dates are same as grp / calc period start-end dates */
  IF l_grp_start_date = p_start_date AND
     l_grp_end_date = p_end_date
  THEN

    /* then prorated sales = total sales */
    l_pro_calc_prd_sales := l_calc_prd_sales;

  ELSE

    /* else, sum all sales to get the prorated sales */
    FOR sales_rec IN vol_hist_c ( p_prd_id   => p_period_id
                                  ,p_line_id  => p_line_item_id
                                  ,p_grp_id   => p_grp_date_id
                                  ,p_start_dt => p_start_date
                                  ,p_end_dt   => p_end_date)
    LOOP

      /* if sales volume dates between calc sub period dates */
      IF sales_rec.start_date >= p_start_date AND
         sales_rec.end_date <= p_end_date
      THEN
        /* consider full volume */
        l_pro_calc_prd_sales := l_pro_calc_prd_sales + sales_rec.forecasted_amount;

      /* else if sales volume dates overlap calc sub period dates */
      ELSIF sales_rec.start_date <= p_end_date AND
            sales_rec.end_date >= p_start_date
      THEN
        /* then consider prorated volume */
        l_pro_calc_prd_sales
        := l_pro_calc_prd_sales
           + sales_rec.forecasted_amount
             * ((LEAST(sales_rec.end_date, p_end_date)
                 - GREATEST(sales_rec.start_date, p_start_date)) + 1)
               / ((sales_rec.end_date - sales_rec.start_date) + 1);

      END IF;

    END LOOP;

  END IF;

  x_pro_sales := l_pro_calc_prd_sales;
  x_sales     := l_calc_prd_sales;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_calc_prd_sales_for;

--------------------------------------------------------------------------------
--  NAME         : get_calc_prd_sales_for
--  DESCRIPTION  :get volumes for a calculation period, sub period
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  13-SEP-06     Shabda     o Created
--------------------------------------------------------------------------------
FUNCTION get_calc_prd_sales_for( p_var_rent_id  IN NUMBER
                            ,p_period_id    IN NUMBER
                            ,p_line_item_id IN NUMBER
                            ,p_grp_date_id  IN NUMBER
                            ,p_start_date   IN DATE
                            ,p_end_date     IN DATE)
RETURN NUMBER IS

  /* get volumes for a calculation period */
  CURSOR vol_hist_sum_c ( p_prd_id   IN NUMBER
                      ,p_line_id  IN NUMBER
                      ,p_grp_id   IN NUMBER) IS
    SELECT
    SUM(forecasted_amount) AS calc_prd_forecasted_volume
    FROM
    pn_var_vol_hist_all sales
    WHERE
    sales.period_id = p_prd_id AND
    sales.line_item_id = p_line_id AND
    sales.grp_date_id = p_grp_id;

  /* get volumes for a calculation sub-period */
  CURSOR vol_hist_c ( p_prd_id   IN NUMBER
                      ,p_line_id  IN NUMBER
                      ,p_grp_id   IN NUMBER
                      ,p_start_dt IN DATE
                      ,p_end_dt   IN DATE) IS
    SELECT
     sales.forecasted_amount
    ,sales.start_date
    ,sales.end_date
    FROM
    pn_var_vol_hist_all sales
    WHERE
    sales.period_id = p_prd_id AND
    sales.line_item_id = p_line_id AND
    sales.grp_date_id = p_grp_id AND
    sales.start_date <= p_end_dt AND
    sales.end_date >= p_start_dt;

  /* get grp dates */
  CURSOR grp_dates_c(p_grp_id IN NUMBER) IS
  SELECT
   grp.grp_start_date
  ,grp.grp_end_date
  FROM
  pn_var_grp_dates_all grp
  WHERE
  grp.grp_date_id = p_grp_id;

  l_grp_start_date DATE;
  l_grp_end_date   DATE;

  l_calc_prd_sales     NUMBER;
  l_pro_calc_prd_sales NUMBER;

BEGIN

  /* get group / calc period dates */
  FOR grp_rec IN grp_dates_c(p_grp_id => p_grp_date_id) LOOP
    l_grp_start_date := grp_rec.grp_start_date;
    l_grp_end_date   := grp_rec.grp_end_date;
  END LOOP;

  l_pro_calc_prd_sales := 0;

  /* if calc sub period dates are same as grp / calc period start-end dates */
  IF l_grp_start_date = p_start_date AND
     l_grp_end_date = p_end_date
  THEN

    /* get all APPROVED sales for a group / calc period
       prorated sales = total sales */
    FOR sales_rec IN vol_hist_sum_c ( p_prd_id   => p_period_id
                                  ,p_line_id  => p_line_item_id
                                  ,p_grp_id   => p_grp_date_id)
    LOOP
      l_pro_calc_prd_sales := l_pro_calc_prd_sales + sales_rec.calc_prd_forecasted_volume;
    END LOOP;

  ELSE

    /* else, sum all sales to get the prorated sales */
    FOR sales_rec IN vol_hist_c ( p_prd_id   => p_period_id
                                  ,p_line_id  => p_line_item_id
                                  ,p_grp_id   => p_grp_date_id
                                  ,p_start_dt => p_start_date
                                  ,p_end_dt   => p_end_date)
    LOOP

      /* if sales volume dates between calc sub period dates */
      IF sales_rec.start_date >= p_start_date AND
         sales_rec.end_date <= p_end_date
      THEN
        /* consider full volume */
        l_pro_calc_prd_sales := l_pro_calc_prd_sales + sales_rec.forecasted_amount;

      /* else if sales volume dates overlap calc sub period dates */
      ELSIF sales_rec.start_date <= p_end_date AND
            sales_rec.end_date >= p_start_date
      THEN
        /* then consider prorated volume */
        l_pro_calc_prd_sales
        := l_pro_calc_prd_sales
           + sales_rec.forecasted_amount
             * ((LEAST(sales_rec.end_date, p_end_date)
                 - GREATEST(sales_rec.start_date, p_start_date)) + 1)
               / ((sales_rec.end_date - sales_rec.start_date) + 1);

      END IF;

    END LOOP;

  END IF;

  RETURN l_pro_calc_prd_sales;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_calc_prd_sales_for;



--------------------------------------------------------------------------------
--  NAME         : populate_ytd_sales_for
--  DESCRIPTION  : gets forecasted YTD sales
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  13-SEP-06     Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_ytd_sales_for( p_var_rent_id    IN NUMBER
                                 ,p_calc_method    IN VARCHAR2) IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.cumulative_vol
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_proration_rule       pn_var_rents_all.proration_rule%TYPE;
  l_calculation_method   pn_var_rents_all.cumulative_vol%TYPE;

  /* get the line items with updated sales for FY, LY, FLY, STD, NP */
  CURSOR lines_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    sales_vol_update_flag = 'Y'
    ORDER BY
     period_id
    ,line_item_id;

  /* ytd for STD, NP */
  CURSOR ytd_sales_c( p_vr_ID   IN NUMBER
                     ,p_prd_ID  IN NUMBER
                     ,p_line_ID IN NUMBER) IS
    SELECT
     hdr.trx_header_id
    ,SUM(hdr.prorated_group_sales_for) OVER
      (PARTITION BY
        hdr.period_id
       ,hdr.line_item_id
       ,hdr.reset_group_id
       ORDER BY
       hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_sales_for
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_ID AND
    hdr.line_item_id = p_line_ID
    ORDER BY
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.calc_prd_start_date;

  /* counters */
  l_counter1 NUMBER;

  /* plsql tables for ytd dates and trx hdr */
  trx_hdr_t       NUM_T;
  ytd_sales_for_t NUM_T;

BEGIN

  /* get VR details */
  IF p_calc_method IS NULL THEN
    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_calculation_method := vr_rec.cumulative_vol;
    END LOOP;
  ELSE
    l_calculation_method := p_calc_method;
  END IF;

  IF l_calculation_method IN ( pn_var_trx_pkg.G_CALC_YTD
                              ,pn_var_trx_pkg.G_CALC_CUMULATIVE) THEN

    FOR line_rec IN lines_c(p_vr_id => p_var_rent_id) LOOP

      trx_hdr_t.DELETE;
      ytd_sales_for_t.DELETE;

      OPEN ytd_sales_c( p_vr_ID   => p_var_rent_id
                       ,p_prd_ID  => line_rec.period_id
                       ,p_line_ID => line_rec.line_item_id);

      FETCH ytd_sales_c BULK COLLECT INTO
       trx_hdr_t
      ,ytd_sales_for_t;

      CLOSE ytd_sales_c;

      FORALL i IN 1..trx_hdr_t.COUNT
        UPDATE
        pn_var_trx_headers_all
        SET
        ytd_sales_for = ytd_sales_for_t(i)
        WHERE
        trx_header_id = trx_hdr_t(i);

    END LOOP;

  END IF; /* IF l_calculation_method IN */

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_ytd_sales_for;

--------------------------------------------------------------------------------
--  NAME         : populate_sales_for
--  DESCRIPTION  : populates forecasted sales in trx header tables
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  13-SEP-06     Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_sales_for(p_var_rent_id IN NUMBER) IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.org_id
    ,vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    ,vr.cumulative_vol
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_org_id               pn_var_rents_all.org_id%TYPE;
  l_vr_commencement_date pn_var_rents_all.commencement_date%TYPE;
  l_vr_termination_date  pn_var_rents_all.termination_date%TYPE;
  l_proration_rule       pn_var_rents_all.proration_rule%TYPE;
  l_calculation_method   pn_var_rents_all.cumulative_vol%TYPE;

  /* get the line items with updated sales */
  CURSOR lines_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    sales_vol_update_flag = 'Y'
    ORDER BY
     period_id
    ,line_item_id;

  /* get the calc periods to update sales data */
  CURSOR calc_periods_c( p_vr_id   IN NUMBER
                        ,p_prd_id  IN NUMBER
                        ,p_line_id IN NUMBER) IS
    SELECT
     hdr.trx_header_id
    ,hdr.var_rent_id
    ,hdr.period_id
    ,hdr.line_item_id
    ,hdr.grp_date_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_id AND
    hdr.line_item_id = p_line_id
    ORDER BY
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date;

  /* data structures */
  trx_hdr_t             NUM_T;
  reporting_grp_sales_t NUM_T;
  prorate_grp_sales_t   NUM_T;

  l_counter NUMBER;

  /* flags */
  l_sales_create_upd_flag BOOLEAN;

  l_line_items_lock4salesvol_t NUM_T;


BEGIN

  /* lock the lines with updated sales */
  l_line_items_lock4salesvol_t.DELETE;

  OPEN line_items_lock4salesvol_c(p_vr_id => p_var_rent_id);
  FETCH line_items_lock4salesvol_c BULK COLLECT INTO l_line_items_lock4salesvol_t;
  CLOSE line_items_lock4salesvol_c;

  /* get the VR details */
  FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP

    l_org_id               := vr_rec.org_id;
    l_vr_commencement_date := vr_rec.commencement_date;
    l_vr_termination_date  := vr_rec.termination_date;
    l_proration_rule       := vr_rec.proration_rule;
    l_calculation_method   := vr_rec.cumulative_vol;

  END LOOP;

  l_sales_create_upd_flag := FALSE;

  l_counter := 0;

  /* for all line items with changed sales volume */
  FOR line_rec IN lines_c(p_vr_id => p_var_rent_id)
  LOOP

    l_sales_create_upd_flag := TRUE;

    trx_hdr_t.DELETE;
    reporting_grp_sales_t.DELETE;
    prorate_grp_sales_t.DELETE;

    /* for all calc sub periods for the line item, get the prorated sales */
    FOR trx_rec IN calc_periods_c( p_vr_id   => p_var_rent_id
                                  ,p_prd_id  => line_rec.period_id
                                  ,p_line_id => line_rec.line_item_id)
    LOOP

      l_counter := l_counter + 1;

      trx_hdr_t(l_counter) := trx_rec.trx_header_id;

      pn_var_trx_pkg.get_calc_prd_sales_for
        ( p_var_rent_id  => trx_rec.var_rent_id
         ,p_period_id    => trx_rec.period_id
         ,p_line_item_id => trx_rec.line_item_id
         ,p_grp_date_id  => trx_rec.grp_date_id
         ,p_start_date   => trx_rec.calc_prd_start_date
         ,p_end_date     => trx_rec.calc_prd_end_date
         ,x_pro_sales    => prorate_grp_sales_t(l_counter)
         ,x_sales        => reporting_grp_sales_t(l_counter));

    END LOOP;
      /* for all calc sub periods for the line item,
     update the trx headers with the sales */
    IF trx_hdr_t.COUNT > 0 THEN

     FORALL i IN trx_hdr_t.FIRST..trx_hdr_t.LAST
      UPDATE
      pn_var_trx_headers_all
      SET
       reporting_group_sales_for = reporting_grp_sales_t(i)
      ,prorated_group_sales_for = prorate_grp_sales_t(i)
      WHERE
      trx_header_id = trx_hdr_t(i);

    END IF;

  END LOOP;

/*Similar to actuals - We always populate YTD sales*/

 pn_var_trx_pkg.populate_ytd_sales_for
        ( p_var_rent_id    => p_var_rent_id
         ,p_calc_method    => l_calculation_method);

  /*This would be needed in actual sales, but not for forecasted.
  FORALL line_rec IN 1..l_line_items_lock4salesvol_t.COUNT
    UPDATE
    pn_var_lines_all
    SET
    sales_vol_update_flag = NULL
    WHERE
    line_item_id = l_line_items_lock4salesvol_t(line_rec);*/

  /* UN-lock the lines with updated sales */
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_sales_for;
/*-----------------------------------------------------------------------------
----------------PROCEDURES TO POPULATE DEDUCTIONS------------------------------
-----------------------------------------------------------------------------*/
--------------------------------------------------------------------------------
--  NAME         : get_calc_prd_dedc
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  8/10/06      Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE get_calc_prd_dedc( p_var_rent_id  IN NUMBER
                             ,p_period_id    IN NUMBER
                             ,p_line_item_id IN NUMBER
                             ,p_grp_date_id  IN NUMBER
                             ,p_start_date   IN DATE
                             ,p_end_date     IN DATE
                             ,x_pro_dedc    OUT NOCOPY NUMBER
                             ,x_dedc        OUT NOCOPY NUMBER) IS


  /* get volumes for a calculation period */
  CURSOR dedc_c1 ( p_prd_id   IN NUMBER
                   ,p_line_id  IN NUMBER
                   ,p_grp_id   IN NUMBER) IS
    SELECT
    SUM(deduction_amount) AS calc_prd_dedc
    FROM
    pn_var_deductions_all dedc
    WHERE
    dedc.period_id = p_prd_id AND
    dedc.line_item_id = p_line_id AND
    dedc.grp_date_id = p_grp_id;

  /* get volumes for a calculation sub-period */
  CURSOR dedc_c2 ( p_prd_id   IN NUMBER
                      ,p_line_id  IN NUMBER
                      ,p_grp_id   IN NUMBER
                      ,p_start_dt IN DATE
                      ,p_end_dt   IN DATE) IS
    SELECT
     dedc.deduction_amount
    ,dedc.start_date
    ,dedc.end_date
    FROM
    pn_var_deductions_all dedc
    WHERE
    dedc.period_id = p_prd_id AND
    dedc.line_item_id = p_line_id AND
    dedc.grp_date_id = p_grp_id AND
    dedc.start_date <= p_end_dt AND
    dedc.end_date >= p_start_dt;

  /* get grp dates */
  CURSOR grp_dates_c(p_grp_id IN NUMBER) IS
  SELECT
   grp.grp_start_date
  ,grp.grp_end_date
  FROM
  pn_var_grp_dates_all grp
  WHERE
  grp.grp_date_id = p_grp_id;

  l_grp_start_date DATE;
  l_grp_end_date   DATE;

  l_calc_prd_dedc     NUMBER;
  l_pro_calc_prd_dedc NUMBER;

BEGIN
  /* get group / calc period dates */
  FOR grp_rec IN grp_dates_c(p_grp_id => p_grp_date_id) LOOP
    l_grp_start_date := grp_rec.grp_start_date;
    l_grp_end_date   := grp_rec.grp_end_date;
  END LOOP;

  l_calc_prd_dedc := 0;
  l_pro_calc_prd_dedc := 0;

  /* get all APPROVED deductions for a group / calc period */
  FOR dedc_rec IN dedc_c1 ( p_prd_id   => p_period_id
                           ,p_line_id  => p_line_item_id
                           ,p_grp_id   => p_grp_date_id)
  LOOP
    l_calc_prd_dedc := l_calc_prd_dedc + dedc_rec.calc_prd_dedc;
  END LOOP;

  /* if calc sub period dates are same as grp / calc period start-end dates */
  IF l_grp_start_date = p_start_date AND
     l_grp_end_date = p_end_date
  THEN

    /* then prorated deductions = total deductions */
    l_pro_calc_prd_dedc := l_calc_prd_dedc;

  ELSE

    /* else, sum all deductions to get the prorated deductions */
    FOR dedc_rec IN dedc_c2 ( p_prd_id   => p_period_id
                                  ,p_line_id  => p_line_item_id
                                  ,p_grp_id   => p_grp_date_id
                                  ,p_start_dt => p_start_date
                                  ,p_end_dt   => p_end_date)
    LOOP

      /* if deductions volume dates between calc sub period dates */
      IF dedc_rec.start_date >= p_start_date AND
         dedc_rec.end_date <= p_end_date
      THEN
        /* consider full volume */
        l_pro_calc_prd_dedc := l_pro_calc_prd_dedc + dedc_rec.deduction_amount;

      /* else if deductions volume dates overlap calc sub period dates */
      ELSIF dedc_rec.start_date <= p_end_date AND
            dedc_rec.end_date >= p_start_date
      THEN
        /* then consider prorated volume */
        l_pro_calc_prd_dedc
        := l_pro_calc_prd_dedc
           + dedc_rec.deduction_amount
             * ((LEAST(dedc_rec.end_date, p_end_date)
                 - GREATEST(dedc_rec.start_date, p_start_date)) + 1)
               / ((dedc_rec.end_date - dedc_rec.start_date) + 1);

      END IF;

    END LOOP;

  END IF;
  x_pro_dedc := l_pro_calc_prd_dedc;
  x_dedc     := l_calc_prd_dedc;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_calc_prd_dedc;

--------------------------------------------------------------------------------
--  NAME         : get_calc_prd_dedc
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  8/10/06      Shabda     o Created
--------------------------------------------------------------------------------
FUNCTION get_calc_prd_dedc( p_var_rent_id  IN NUMBER
                             ,p_period_id    IN NUMBER
                             ,p_line_item_id IN NUMBER
                             ,p_grp_date_id  IN NUMBER
                             ,p_start_date   IN DATE
                             ,p_end_date     IN DATE)

RETURN NUMBER IS


  /* get deductions for a calculation period */
  CURSOR dedc_c1 ( p_prd_id   IN NUMBER
                   ,p_line_id  IN NUMBER
                   ,p_grp_id   IN NUMBER) IS
    SELECT
    SUM(deduction_amount) AS calc_prd_dedc
    FROM
    pn_var_deductions_all dedc
    WHERE
    dedc.period_id = p_prd_id AND
    dedc.line_item_id = p_line_id AND
    dedc.grp_date_id = p_grp_id;

  /* get deductions for a calculation sub-period */
  CURSOR dedc_c2 ( p_prd_id   IN NUMBER
                      ,p_line_id  IN NUMBER
                      ,p_grp_id   IN NUMBER
                      ,p_start_dt IN DATE
                      ,p_end_dt   IN DATE) IS
    SELECT
     dedc.deduction_amount
    ,dedc.start_date
    ,dedc.end_date
    FROM
    pn_var_deductions_all dedc
    WHERE
    dedc.period_id = p_prd_id AND
    dedc.line_item_id = p_line_id AND
    dedc.grp_date_id = p_grp_id AND
    dedc.start_date <= p_end_dt AND
    dedc.end_date >= p_start_dt;

  /* get grp dates */
  CURSOR grp_dates_c(p_grp_id IN NUMBER) IS
  SELECT
   grp.grp_start_date
  ,grp.grp_end_date
  FROM
  pn_var_grp_dates_all grp
  WHERE
  grp.grp_date_id = p_grp_id;

  l_grp_start_date DATE;
  l_grp_end_date   DATE;

  l_calc_prd_dedc     NUMBER;
  l_pro_calc_prd_dedc NUMBER;

BEGIN
  /* get group / calc period dates */
  FOR grp_rec IN grp_dates_c(p_grp_id => p_grp_date_id) LOOP
    l_grp_start_date := grp_rec.grp_start_date;
    l_grp_end_date   := grp_rec.grp_end_date;
  END LOOP;

  l_calc_prd_dedc := 0;
  l_pro_calc_prd_dedc := 0;

  /* get all APPROVED deductions for a group / calc period */
  FOR dedc_rec IN dedc_c1 ( p_prd_id   => p_period_id
                           ,p_line_id  => p_line_item_id
                           ,p_grp_id   => p_grp_date_id)
  LOOP
    l_calc_prd_dedc := l_calc_prd_dedc + dedc_rec.calc_prd_dedc;
  END LOOP;

  /* if calc sub period dates are same as grp / calc period start-end dates */
  IF l_grp_start_date = p_start_date AND
     l_grp_end_date = p_end_date
  THEN

    /* then prorated deductions = total deductions */
    l_pro_calc_prd_dedc := l_calc_prd_dedc;

  ELSE

    /* else, sum all deductions to get the prorated deductions */
    FOR dedc_rec IN dedc_c2 ( p_prd_id   => p_period_id
                                  ,p_line_id  => p_line_item_id
                                  ,p_grp_id   => p_grp_date_id
                                  ,p_start_dt => p_start_date
                                  ,p_end_dt   => p_end_date)
    LOOP

      /* if deductions volume dates between calc sub period dates */
      IF dedc_rec.start_date >= p_start_date AND
         dedc_rec.end_date <= p_end_date
      THEN
        /* consider full volume */
        l_pro_calc_prd_dedc := l_pro_calc_prd_dedc + dedc_rec.deduction_amount;

      /* else if deductions volume dates overlap calc sub period dates */
      ELSIF dedc_rec.start_date <= p_end_date AND
            dedc_rec.end_date >= p_start_date
      THEN
        /* then consider prorated volume */
        l_pro_calc_prd_dedc
        := l_pro_calc_prd_dedc
           + dedc_rec.deduction_amount
             * ((LEAST(dedc_rec.end_date, p_end_date)
                 - GREATEST(dedc_rec.start_date, p_start_date)) + 1)
               / ((dedc_rec.end_date - dedc_rec.start_date) + 1);

      END IF;

    END LOOP;

  END IF;
  RETURN l_pro_calc_prd_dedc;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END get_calc_prd_dedc;
--------------------------------------------------------------------------------
--  NAME         : populate_ly_pro_dedc
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  12/10/06     Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_ly_pro_dedc( p_var_rent_id        IN NUMBER
                               ,p_proration_rule     IN VARCHAR2
                               ,p_vr_commencement_dt IN DATE
                               ,p_vr_termination_dt  IN DATE) IS

  /* get VR details */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_vr_commencement_date DATE;
  l_vr_termination_date  DATE;
  l_vr_proration_rule    VARCHAR2(30);
  l_ly_start_date        DATE;

BEGIN

  /* get VR details */
  IF p_proration_rule IS NULL OR
     p_vr_commencement_dt IS NULL OR
     p_vr_termination_dt IS NULL
  THEN
    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_vr_commencement_date := vr_rec.commencement_date;
      l_vr_termination_date  := vr_rec.termination_date;
      l_vr_proration_rule    := vr_rec.proration_rule;
    END LOOP;
  ELSE
    l_vr_commencement_date := p_vr_commencement_dt;
    l_vr_termination_date  := p_vr_termination_dt;
    l_vr_proration_rule    := p_proration_rule;
  END IF;

  l_ly_start_date := ADD_MONTHS(l_vr_termination_date, -12) + 1;

  IF l_vr_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_LY
                             ,pn_var_trx_pkg.G_PRORUL_FLY) THEN

    /* init ly_proration_sales */
    UPDATE
    pn_var_trx_headers_all
    SET
    ly_proration_deductions = NULL
    WHERE
    var_rent_id = p_var_rent_id;

    /* populate ly_proration_sales */
    UPDATE
    pn_var_trx_headers_all hdr
    SET
    hdr.ly_proration_deductions = hdr.prorated_group_deductions
    WHERE
    hdr.var_rent_id = p_var_rent_id AND
    hdr.calc_prd_start_date >= l_ly_start_date;

    /* populate ly_proration_sales if LY start date does not
       coincide with a calc prd start date */
    UPDATE
    pn_var_trx_headers_all
    SET
    ly_proration_deductions
    = pn_var_trx_pkg.get_calc_prd_dedc( var_rent_id
                                        ,period_id
                                        ,line_item_id
                                        ,grp_date_id
                                        ,l_ly_start_date
                                        ,calc_prd_end_date)
    WHERE
    var_rent_id = p_var_rent_id AND
    l_ly_start_date BETWEEN (calc_prd_start_date + 1)
                        AND calc_prd_end_date;

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_ly_pro_dedc;


--------------------------------------------------------------------------------
--  NAME         : populate_fy_pro_dedc
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  10/10/06     Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_fy_pro_dedc( p_var_rent_id        IN NUMBER
                                ,p_proration_rule     IN VARCHAR2
                                ,p_vr_commencement_dt IN DATE
                                ,p_vr_termination_dt  IN DATE) IS

  /* get VR details */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_vr_commencement_date DATE;
  l_vr_termination_date  DATE;
  l_vr_proration_rule    VARCHAR2(30);
  l_fy_end_date          DATE;

BEGIN

  /* get VR details */
  IF p_proration_rule IS NULL OR
     p_vr_commencement_dt IS NULL OR
     p_vr_termination_dt IS NULL
  THEN
    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP
      l_vr_commencement_date := vr_rec.commencement_date;
      l_vr_termination_date  := vr_rec.termination_date;
      l_vr_proration_rule    := vr_rec.proration_rule;
    END LOOP;
  ELSE
    l_vr_commencement_date := p_vr_commencement_dt;
    l_vr_termination_date  := p_vr_termination_dt;
    l_vr_proration_rule    := p_proration_rule;
  END IF;

  l_fy_end_date := ADD_MONTHS(l_vr_commencement_date, 12) - 1;

  IF l_vr_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_FY
                             ,pn_var_trx_pkg.G_PRORUL_FLY) THEN

    /* init ly_proration_deductions */
    UPDATE
    pn_var_trx_headers_all
    SET
    fy_proration_deductions = NULL
    WHERE
    var_rent_id = p_var_rent_id;

    /* populate ly_proration_deductions */
    UPDATE
    pn_var_trx_headers_all hdr
    SET
    hdr.fy_proration_deductions = hdr.prorated_group_deductions
    WHERE
    hdr.var_rent_id = p_var_rent_id AND
    hdr.calc_prd_end_date <= l_fy_end_date;

    /* populate fy_proration_deductions if FY end date does not
       coincide with a calc prd end date */
    UPDATE
    pn_var_trx_headers_all
    SET
    fy_proration_deductions
    = pn_var_trx_pkg.get_calc_prd_dedc( var_rent_id
                                        ,period_id
                                        ,line_item_id
                                        ,grp_date_id
                                        ,calc_prd_start_date
                                        ,l_fy_end_date)
    WHERE
    var_rent_id = p_var_rent_id AND
    l_fy_end_date BETWEEN calc_prd_start_date
                      AND (calc_prd_end_date - 1);

  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_fy_pro_dedc;

--------------------------------------------------------------------------------
--  NAME         : populate_ytd_deductions
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  10-10-06     Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_ytd_deductions( p_var_rent_id    IN NUMBER
                             ,p_proration_rule IN VARCHAR2) IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.var_rent_id
    ,vr.proration_rule
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_proration_rule       pn_var_rents_all.proration_rule%TYPE;

  /* get the line items with updated deductions for FY, LY, FLY, STD, NP */
  CURSOR lines_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
     period_id
    ,line_item_id;

  /* get the line items with updated deductions for CYP, CYNP */
  CURSOR lines_cs_c( p_vr_id       IN NUMBER
                    ,p_part_prd_id IN NUMBER
                    ,p_full_prd_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id AND
    period_id NOT IN (p_part_prd_id, p_full_prd_id)
    ORDER BY
     period_id
    ,line_item_id;

  /* get the period details - we use the first 2 periods */
  CURSOR periods_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,start_date
    ,end_date
    ,partial_period
    FROM
    pn_var_periods_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
    start_date;

  /* period info */
  l_part_prd_id           NUMBER;
  l_part_prd_start_dt     DATE;
  l_part_prd_end_dt       DATE;
  l_part_prd_partial_flag VARCHAR2(1);

  l_full_prd_id           NUMBER;
  l_full_prd_start_dt     DATE;
  l_full_prd_end_dt       DATE;
  l_full_prd_partial_flag VARCHAR2(1);

  /* ytd for STD, NP, FY, LY, FLY */
  CURSOR ytd_deductions_c( p_vr_ID   IN NUMBER
                     ,p_prd_ID  IN NUMBER
                     ,p_line_ID IN NUMBER) IS
    SELECT
     hdr.trx_header_id
    ,SUM(hdr.prorated_group_deductions) OVER
      (PARTITION BY
        hdr.period_id
       ,hdr.line_item_id
       ,hdr.reset_group_id
       ORDER BY
       hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_deductions
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_ID AND
    hdr.line_item_id = p_line_ID
    ORDER BY
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.calc_prd_start_date;

  /* ytd for CYP, CYNP combined period */
  CURSOR ytd_deductions_cs_c( p_vr_ID  IN NUMBER
                        ,p_part_prd_id IN NUMBER
                        ,p_full_prd_id IN NUMBER) IS
    SELECT
     hdr.trx_header_id
    ,SUM(hdr.prorated_group_deductions) OVER
      (PARTITION BY
        hdr.line_item_group_id
       ORDER BY
        hdr.calc_prd_start_date
       ROWS UNBOUNDED PRECEDING) AS ytd_deductions
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id IN (p_part_prd_id, p_full_prd_id)
    ORDER BY
     hdr.line_item_group_id
    ,hdr.calc_prd_start_date;

  /* counters */
  l_counter1 NUMBER;

  /* plsql tables for ytd dates and trx hdr */
  trx_hdr_t   NUM_T;
  ytd_deductions_t NUM_T;

BEGIN

  pnp_debug_pkg.log('++++ pn_var_trx_pkg.populate_ytd_deductions START ++++');

  /* get VR details */
  IF p_proration_rule IS NULL THEN

    FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP

      l_proration_rule     := vr_rec.proration_rule;

    END LOOP;

  ELSE

    l_proration_rule     := p_proration_rule;

  END IF;

  pnp_debug_pkg.log('Called with: ');
  pnp_debug_pkg.log('    p_var_rent_id:        '||p_var_rent_id);
  pnp_debug_pkg.log('    l_proration_rule:     '||l_proration_rule);

  /* l_proration_rule based decisions */
  IF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_FY
                          ,pn_var_trx_pkg.G_PRORUL_LY
                          ,pn_var_trx_pkg.G_PRORUL_FLY
                          ,pn_var_trx_pkg.G_PRORUL_NP
                          ,pn_var_trx_pkg.G_PRORUL_STD) THEN

    FOR line_rec IN lines_c(p_vr_id => p_var_rent_id) LOOP

      trx_hdr_t.DELETE;
      ytd_deductions_t.DELETE;

      OPEN ytd_deductions_c( p_vr_ID   => p_var_rent_id
                       ,p_prd_ID  => line_rec.period_id
                       ,p_line_ID => line_rec.line_item_id);

      FETCH ytd_deductions_c BULK COLLECT INTO
       trx_hdr_t
      ,ytd_deductions_t;

      CLOSE ytd_deductions_c;

      FORALL i IN 1..trx_hdr_t.COUNT
        UPDATE
        pn_var_trx_headers_all
        SET
        ytd_deductions = ytd_deductions_t(i)
        WHERE
        trx_header_id = trx_hdr_t(i);

    END LOOP;

  ELSIF l_proration_rule IN ( pn_var_trx_pkg.G_PRORUL_CYP
                             ,pn_var_trx_pkg.G_PRORUL_CYNP) THEN

    /* fetch partial and full period details */
    l_counter1 := 0;
    FOR prd_rec IN periods_c(p_vr_id => p_var_rent_id) LOOP

      l_counter1 := l_counter1 + 1;

      IF l_counter1 = 1 THEN
        l_part_prd_id           := prd_rec.period_id;
        l_part_prd_start_dt     := prd_rec.start_date;
        l_part_prd_end_dt       := prd_rec.end_date;
        l_part_prd_partial_flag := prd_rec.partial_period;

      ELSIF l_counter1 = 2 THEN
        l_full_prd_id           := prd_rec.period_id;
        l_full_prd_start_dt     := prd_rec.start_date;
        l_full_prd_end_dt       := prd_rec.end_date;
        l_full_prd_partial_flag := prd_rec.partial_period;

      ELSE
        EXIT;

      END IF;

    END LOOP; /* fetch partial and full period details */

    trx_hdr_t.DELETE;
    ytd_deductions_t.DELETE;

    OPEN ytd_deductions_cs_c( p_vr_ID       => p_var_rent_id
                        ,p_part_prd_id => l_part_prd_id
                        ,p_full_prd_id => l_full_prd_id);

    FETCH ytd_deductions_cs_c BULK COLLECT INTO
     trx_hdr_t
    ,ytd_deductions_t;

    CLOSE ytd_deductions_cs_c;

    FORALL i IN 1..trx_hdr_t.COUNT
      UPDATE
      pn_var_trx_headers_all
      SET
      ytd_deductions = ytd_deductions_t(i)
      WHERE
      trx_header_id = trx_hdr_t(i);

    /* loop for all lines */
    FOR line_rec IN lines_cs_c ( p_vr_id       => p_var_rent_id
                                ,p_part_prd_id => l_part_prd_id
                                ,p_full_prd_id => l_full_prd_id)
    LOOP

      trx_hdr_t.DELETE;
      ytd_deductions_t.DELETE;

      OPEN ytd_deductions_c( p_vr_ID   => p_var_rent_id
                       ,p_prd_ID  => line_rec.period_id
                       ,p_line_ID => line_rec.line_item_id);

      FETCH ytd_deductions_c BULK COLLECT INTO
       trx_hdr_t
      ,ytd_deductions_t;

      CLOSE ytd_deductions_c;

      FORALL i IN 1..trx_hdr_t.COUNT
        UPDATE
        pn_var_trx_headers_all
        SET
        ytd_deductions = ytd_deductions_t(i)
        WHERE
        trx_header_id = trx_hdr_t(i);

    END LOOP; /* loop for all lines */

  END IF; /* l_proration_rule based decisions */

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_ytd_deductions;

--------------------------------------------------------------------------------
--  NAME         : populate_deductions
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  10/10/06      Shabda     o Created
--------------------------------------------------------------------------------
PROCEDURE populate_deductions(p_var_rent_id IN NUMBER) IS

  /* get VR info */
  CURSOR vr_c(p_vr_id IN NUMBER) IS
    SELECT
     vr.org_id
    ,vr.var_rent_id
    ,vr.commencement_date
    ,vr.termination_date
    ,vr.proration_rule
    ,vr.cumulative_vol
    FROM
    pn_var_rents_all vr
    WHERE
    vr.var_rent_id = p_vr_id;

  l_org_id               pn_var_rents_all.org_id%TYPE;
  l_vr_commencement_date pn_var_rents_all.commencement_date%TYPE;
  l_vr_termination_date  pn_var_rents_all.termination_date%TYPE;
  l_proration_rule       pn_var_rents_all.proration_rule%TYPE;
  l_calculation_method   pn_var_rents_all.cumulative_vol%TYPE;

  /* get the line items*/
  CURSOR lines_c(p_vr_id IN NUMBER) IS
    SELECT
     period_id
    ,line_item_id
    FROM
    pn_var_lines_all
    WHERE
    var_rent_id = p_vr_id
    ORDER BY
     period_id
    ,line_item_id;

  /* get the calc periods to update deductions data */
  CURSOR calc_periods_c( p_vr_id   IN NUMBER
                        ,p_prd_id  IN NUMBER
                        ,p_line_id IN NUMBER) IS
    SELECT
     hdr.trx_header_id
    ,hdr.var_rent_id
    ,hdr.period_id
    ,hdr.line_item_id
    ,hdr.grp_date_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date
    FROM
    pn_var_trx_headers_all hdr
    WHERE
    hdr.var_rent_id = p_vr_id AND
    hdr.period_id = p_prd_id AND
    hdr.line_item_id = p_line_id
    ORDER BY
     hdr.period_id
    ,hdr.line_item_id
    ,hdr.calc_prd_start_date
    ,hdr.calc_prd_end_date;

  /* data structures */
  trx_hdr_t             NUM_T;
  reporting_grp_dedc_t NUM_T;
  prorate_grp_dedc_t   NUM_T;

  l_counter NUMBER;

  /* flags */

  l_line_items_t NUM_T;

BEGIN
  l_line_items_t.DELETE;

  OPEN line_items_c(p_vr_id => p_var_rent_id);
  FETCH line_items_c BULK COLLECT INTO l_line_items_t;
  CLOSE line_items_c;

  /* get the VR details */
  FOR vr_rec IN vr_c(p_vr_id => p_var_rent_id) LOOP

    l_org_id               := vr_rec.org_id;
    l_vr_commencement_date := vr_rec.commencement_date;
    l_vr_termination_date  := vr_rec.termination_date;
    l_proration_rule       := vr_rec.proration_rule;
    l_calculation_method   := vr_rec.cumulative_vol;

  END LOOP;

  /* for all line items */
  FOR line_rec IN lines_c(p_vr_id => p_var_rent_id)
  LOOP
    l_counter := 0;
    trx_hdr_t.DELETE;
    reporting_grp_dedc_t.DELETE;
    prorate_grp_dedc_t.DELETE;

    /* for all calc sub periods for the line item, get the prorated deductions */
    FOR trx_rec IN calc_periods_c( p_vr_id   => p_var_rent_id
                                  ,p_prd_id  => line_rec.period_id
                                  ,p_line_id => line_rec.line_item_id)
    LOOP

      l_counter := l_counter + 1;

      trx_hdr_t(l_counter) := trx_rec.trx_header_id;

      pn_var_trx_pkg.get_calc_prd_dedc
        ( p_var_rent_id  => trx_rec.var_rent_id
         ,p_period_id    => trx_rec.period_id
         ,p_line_item_id => trx_rec.line_item_id
         ,p_grp_date_id  => trx_rec.grp_date_id
         ,p_start_date   => trx_rec.calc_prd_start_date
         ,p_end_date     => trx_rec.calc_prd_end_date
         ,x_pro_dedc    => prorate_grp_dedc_t(l_counter)
         ,x_dedc        => reporting_grp_dedc_t(l_counter));

    END LOOP;

    /* for all calc sub periods for the line item,
       update the trx headers with the deductions */
    IF trx_hdr_t.COUNT > 0 THEN

      FORALL i IN trx_hdr_t.FIRST..trx_hdr_t.LAST
        UPDATE
        pn_var_trx_headers_all
        SET
         reporting_group_deductions = reporting_grp_dedc_t(i)
        ,prorated_group_deductions = prorate_grp_dedc_t(i)
        WHERE
        trx_header_id = trx_hdr_t(i);

    END IF;

  END LOOP;


    IF l_proration_rule = pn_var_trx_pkg.G_PRORUL_LY THEN

      pn_var_trx_pkg.populate_ly_pro_dedc
       ( p_var_rent_id        => p_var_rent_id
        ,p_proration_rule     => l_proration_rule
        ,p_vr_commencement_dt => l_vr_commencement_date
        ,p_vr_termination_dt  => l_vr_termination_date);

    ELSIF l_proration_rule = pn_var_trx_pkg.G_PRORUL_FY THEN

      pn_var_trx_pkg.populate_fy_pro_dedc
        (  p_var_rent_id        => p_var_rent_id
          ,p_proration_rule     => l_proration_rule
          ,p_vr_commencement_dt => l_vr_commencement_date
          ,p_vr_termination_dt  => l_vr_termination_date);

    ELSIF l_proration_rule = pn_var_trx_pkg.G_PRORUL_FLY THEN

      pn_var_trx_pkg.populate_ly_pro_dedc
       ( p_var_rent_id        => p_var_rent_id
        ,p_proration_rule     => l_proration_rule
        ,p_vr_commencement_dt => l_vr_commencement_date
        ,p_vr_termination_dt  => l_vr_termination_date);

      pn_var_trx_pkg.populate_fy_pro_dedc
        (  p_var_rent_id        => p_var_rent_id
          ,p_proration_rule     => l_proration_rule
          ,p_vr_commencement_dt => l_vr_commencement_date
          ,p_vr_termination_dt  => l_vr_termination_date);

    END IF;

    /* always populate YTD deductions - Because we always populate YTD sales */
    pn_var_trx_pkg.populate_ytd_deductions
      ( p_var_rent_id    => p_var_rent_id
       ,p_proration_rule => l_proration_rule);

EXCEPTION
  WHEN OTHERS THEN RAISE;

END populate_deductions;




END pn_var_trx_pkg;

/
