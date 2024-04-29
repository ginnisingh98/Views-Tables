--------------------------------------------------------
--  DDL for Package Body OPI_PMI_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_PMI_COST" AS
/* $Header: OPIMCSTB.pls 115.3 2004/05/11 18:35:15 pdong ship $ */

PROCEDURE get_cost IS

    CURSOR cm_cldr IS
    SELECT /*+ ALL_ROWS */
        hdr.co_code,
        hdr.cost_mthd_code,
        dtl.calendar_code,
        dtl.period_code,
        dtl.start_date,
        dtl.end_date,
        dtl.period_status
    FROM
        cm_cldr_dtl dtl,
        cm_cldr_hdr hdr
    WHERE
        hdr.calendar_code = dtl.calendar_code
    AND hdr.delete_mark = 0
    AND dtl.delete_mark = 0
    ORDER BY
        hdr.cost_mthd_code, hdr.co_code, dtl.end_date;

    pv_prior_cost_mthd_code cm_cldr_hdr.cost_mthd_code%TYPE;
    pv_prior_co_code cm_cldr_hdr.co_code%TYPE;
    pv_prior_calendar_code cm_cldr_hdr.calendar_code%TYPE;
    pv_prior_period_code cm_cldr_dtl.period_code%TYPE;
    pv_prior_period_status cm_cldr_dtl.period_status%TYPE;
    pv_sql varchar2(10000);
BEGIN
    -- BUILD COST CALENDAR SUMMARY TABLE, adding PRIOR PERIOD

    pv_prior_cost_mthd_code := NULL;

    FOR cc IN cm_cldr
    LOOP
        IF cc.cost_mthd_code = pv_prior_cost_mthd_code
        AND cc.co_code = pv_prior_co_code
        THEN
            NULL; -- prior calendar and period code applies; keep them
        ELSE
            -- COST_MTHD IS CHANGED - RESET PRIOR PERIOD KEY

            pv_prior_calendar_code := NULL;
            pv_prior_period_code := NULL;
            pv_prior_period_status := NULL;
        END IF;

        INSERT INTO opi_pmi_cldr_sum_gtmp (
          co_code,
          cost_mthd,
          calendar_code,
          period_code,
          period_status,
          start_date,
          end_date,
          prior_calendar_code,
          prior_period_code,
          prior_period_status)
        VALUES (
          cc.co_code,
          cc.cost_mthd_code,
          cc.calendar_code,
          cc.period_code,
          cc.period_status,
          cc.start_date,
          cc.end_date,
          pv_prior_calendar_code,
          pv_prior_period_code,
          pv_prior_period_status);

        pv_prior_cost_mthd_code := cc.cost_mthd_code;
        pv_prior_co_code := cc.co_code;
        pv_prior_calendar_code := cc.calendar_code;
        pv_prior_period_code := cc.period_code;
        pv_prior_period_status := cc.period_status;

    END LOOP;


    -- EXTRACT DISTINCT WAREHOUSES AND DATES

    INSERT INTO opi_pmi_whse_date_gtmp(whse_code, trans_date)
    SELECT /*+ ALL_ROWS */ DISTINCT whse_code, trans_date
    FROM opi_pmi_cost_param_gtmp;


    -- GET EFFECTIVE COST WAREHOUSE

    INSERT INTO opi_pmi_cost_whse_eff_gtmp (whse_code, trans_date, cost_whse_code)
    SELECT /*+ ALL_ROWS */
	wd.whse_code, wd.trans_date, cwa.cost_whse_code
    FROM
	opi_pmi_whse_date_gtmp wd, cm_whse_asc cwa
    WHERE
        wd.whse_code = cwa.whse_code
    AND wd.trans_date BETWEEN cwa.eff_start_date AND cwa.eff_end_date
    AND cwa.delete_mark = 0;


    -- ADD SELF WAREHOUSE IF NO COST WAREHOUSE

    INSERT INTO opi_pmi_cost_whse_eff_gtmp (whse_code, trans_date, cost_whse_code)
    SELECT /*+ ALL_ROWS */
	wd.whse_code, wd.trans_date, wd.whse_code
    FROM
	opi_pmi_whse_date_gtmp wd, opi_pmi_cost_whse_eff_gtmp e
    WHERE
        wd.whse_code = e.whse_code(+)
    AND wd.trans_date = e.trans_date(+)
    AND e.cost_whse_code IS NULL;


    -- GET DISTINCT LIST OF ORGANIZATION.DATES (FOR FINDING EFFECTIVE PLCY)

    INSERT INTO opi_pmi_orgn_date_gtmp(orgn_code, trans_date)
    SELECT /*+ ALL_ROWS */ DISTINCT orgn_code, trans_date
    FROM opi_pmi_cost_param_gtmp;


    -- GET THE FISCAL POLICY FOR EACH ORGANIZATION.DATE

    INSERT INTO opi_pmi_orgn_plcy_gtmp
    (orgn_code, trans_date, co_code, cost_mthd, cost_basis)
    SELECT  /*+ ALL_ROWS */
        od.orgn_code, od.trans_date, o.co_code, g.gl_cost_mthd, g.cost_basis
    FROM
        opi_pmi_orgn_date_gtmp od, sy_orgn_mst o, gl_plcy_mst g
    WHERE
        o.orgn_code = od.orgn_code
    AND g.co_code = o.co_code;


    -- ASSOCIATE THE CORRECT CALENDAR PERIOD, DEPENDING ON COST_BASIS

    INSERT INTO opi_pmi_orgn_per_gtmp
    (orgn_code, trans_date, calendar_code, period_code, period_status)
    SELECT  /*+ ALL_ROWS */ o.orgn_code, o.trans_date,
           c.prior_calendar_code, c.prior_period_code, c.prior_period_status
    FROM opi_pmi_cldr_sum_gtmp c, opi_pmi_orgn_plcy_gtmp o
    WHERE o.cost_basis = 0
    AND c.co_code = o.co_code
    AND c.cost_mthd = o.cost_mthd
    AND o.trans_date BETWEEN c.start_date AND c.end_date;


    -- ASSOCIATE THE COST_BASIS=1 CALENDAR PERIOD

    INSERT INTO opi_pmi_orgn_per_gtmp
          (orgn_code, trans_date, co_code, cost_mthd, cost_basis,
           calendar_code, period_code, period_status)
    SELECT  /*+ ALL_ROWS */
           o.orgn_code, o.trans_date, o.co_code, o.cost_mthd, o.cost_basis,
           c.calendar_code, c.period_code, c.period_status
    FROM opi_pmi_cldr_sum_gtmp c, opi_pmi_orgn_plcy_gtmp o
    WHERE o.cost_basis = 1
    AND c.co_code = o.co_code
    AND c.cost_mthd = o.cost_mthd
    AND o.trans_date BETWEEN c.start_date AND c.end_date;


    --  ASSIGN GL POLICY, CALENDAR PERIOD, COST WAREHOUSE,
    --         AND WAREHOUSE-ORG TO EACH PARAMETER ROW

    INSERT INTO opi_pmi_cost_temp1_gtmp
    (
        item_id,
        whse_code,
        orgn_code,
        trans_date,
        cost_whse_code,
        cost_mthd,
        cost_basis,
        co_code,
        calendar_code,
        period_code,
        period_status,
        whse_orgn_code)
    SELECT /*+ ORDERED */
        param.item_id,
        param.whse_code,
        param.orgn_code,
        param.trans_date,
        cw.cost_whse_code,
        per.cost_mthd,
        per.cost_basis,
        per.co_code,
        per.calendar_code,
        per.period_code,
        per.period_status,
        w.orgn_code
    FROM
        opi_pmi_cost_whse_eff_gtmp cw,
        ic_whse_mst w,
        opi_pmi_cost_param_gtmp param,
        opi_pmi_orgn_per_gtmp per
    WHERE
        cw.whse_code = param.whse_code
    AND cw.trans_date = param.trans_date
    AND per.orgn_code(+) = param.orgn_code
    AND per.trans_date(+) = param.trans_date
    AND w.whse_code || '' = cw.cost_whse_code;


    --  GET COSTS USING PARAM ORGN_CODE

    pv_sql := '
    INSERT INTO opi_pmi_cost_temp2_gtmp
    (
        item_id,
        whse_code,
        orgn_code,
        trans_date,
        cost_whse_code,
        cost_mthd,
        cost_basis,
        co_code,
        calendar_code,
        period_code,
        period_status,
        whse_orgn_code,
        total_cost,
        last_update_date)
    SELECT /*+ ALL_ROWS */
        t1.item_id,
        t1.whse_code,
        t1.orgn_code,
        t1.trans_date,
        t1.cost_whse_code,
        t1.cost_mthd,
        t1.cost_basis,
        t1.co_code,
        t1.calendar_code,
        t1.period_code,
        t1.period_status,
        t1.whse_orgn_code,
        c.acctg_cost,
        c.last_update_date
    FROM
        opi_pmi_cost_temp1_gtmp t1,
        (select
             item_id, whse_code, orgn_code, cost_mthd_code,
             calendar_code, period_code, acctg_cost, last_update_date
         from
            (select
                  item_id, whse_code, orgn_code, cost_mthd_code,
                  calendar_code, period_code, acctg_cost, last_update_date,
                  first_value(last_update_date)
                      over (partition by item_id, whse_code, orgn_code, cost_mthd_code, calendar_code, period_code
                            order by last_update_date desc) final_update_date
              from gl_item_cst
              )
         where last_update_date = final_update_date
        )c
    WHERE
        c.item_id(+) = t1.item_id
    AND c.orgn_code(+) = t1.orgn_code
    AND c.whse_code(+) = t1.cost_whse_code
    AND c.cost_mthd_code(+) = t1.cost_mthd
    AND c.calendar_code(+) = t1.calendar_code
    AND c.period_code(+) = t1.period_code';

    EXECUTE IMMEDIATE pv_sql;


    --  IF COST WASN'T FOUND USING PARAM-ORG, GET COSTS USING *WAREHOUSE-ORG*

    pv_sql := '
    INSERT INTO opi_pmi_cost_temp3_gtmp
    (
        item_id,
        whse_code,
        orgn_code,
        trans_date,
        cost_whse_code,
        cost_mthd,
        cost_basis,
        co_code,
        calendar_code,
        period_code,
        period_status,
        whse_orgn_code,
        total_cost,
        last_update_date)
    SELECT /*+ ALL_ROWS */
        t2.item_id,
        t2.whse_code,
        t2.orgn_code,
        t2.trans_date,
        t2.cost_whse_code,
        t2.cost_mthd,
        t2.cost_basis,
        t2.co_code,
        t2.calendar_code,
        t2.period_code,
        t2.period_status,
        t2.whse_orgn_code,
        c.acctg_cost,
        c.last_update_date
    FROM
        opi_pmi_cost_temp2_gtmp t2,
        (select
             item_id, whse_code, orgn_code, cost_mthd_code,
             calendar_code, period_code, acctg_cost, last_update_date
         from
             (select
                  item_id, whse_code, orgn_code, cost_mthd_code,
                  calendar_code, period_code, acctg_cost, last_update_date,
                  first_value(last_update_date)
                      over (partition by item_id, whse_code, orgn_code, cost_mthd_code, calendar_code, period_code
                            order by last_update_date desc) final_update_date
              from gl_item_cst
              )
         where last_update_date = final_update_date
        )c
    WHERE
        t2.total_cost IS NULL
    AND c.item_id(+) = t2.item_id
    AND c.orgn_code(+) = t2.whse_orgn_code
    AND c.whse_code(+) = t2.cost_whse_code
    AND c.cost_mthd_code(+) = t2.cost_mthd
    AND c.calendar_code(+) = t2.calendar_code
    AND c.period_code(+) = t2.period_code';

    EXECUTE IMMEDIATE pv_sql;


    -- RETURN COSTS FOUND USING PARAM-ORG

    INSERT INTO opi_pmi_cost_result_gtmp (
      item_id, whse_code, orgn_code, trans_date, total_cost, status, last_update_date, period_status)
    SELECT
      item_id, whse_code, orgn_code, trans_date, total_cost, 1, last_update_date, period_status
    FROM
      opi_pmi_cost_temp2_gtmp
    WHERE
      total_cost IS NOT NULL;


    -- RETURN COSTS FOUND USING WHSE-ORG.

    INSERT INTO opi_pmi_cost_result_gtmp (
      item_id, whse_code, orgn_code, trans_date, total_cost,
      status, last_update_date, period_status)
    SELECT
      item_id, whse_code, orgn_code, trans_date, total_cost,
      1, last_update_date, period_status
    FROM
      opi_pmi_cost_temp3_gtmp
    WHERE total_cost IS NOT NULL;


    -- RETURN STATUS = -1 IF NO COSTS WAS FOUND

    INSERT INTO opi_pmi_cost_result_gtmp (
      item_id, whse_code, orgn_code, trans_date, total_cost,
      status, last_update_date, period_status)
    SELECT
      item_id, whse_code, orgn_code, trans_date, total_cost,
      -1, last_update_date, period_status
    FROM
      opi_pmi_cost_temp3_gtmp
    WHERE total_cost IS NULL
    AND cost_basis IS NOT NULL
    AND item_id    IS NOT NULL
    AND whse_code  IS NOT NULL
    AND orgn_code  IS NOT NULL
    AND trans_date IS NOT NULL;


   -- IF ANY PARAMETERS WERE MISSING, RETURN STATUS = -2 .

   INSERT INTO opi_pmi_cost_result_gtmp (
      item_id, whse_code, orgn_code, trans_date, total_cost, status)
    SELECT
      item_id, whse_code, orgn_code, trans_date, NULL, -2
    FROM
      opi_pmi_cost_temp1_gtmp
    WHERE item_id IS NULL
    OR whse_code IS NULL
    OR orgn_code IS NULL
    OR trans_date IS NULL;


    -- IF GL POLICY WAS NOT FOUND, RETURN STATUS = -3

    INSERT INTO opi_pmi_cost_result_gtmp (
      item_id, whse_code, orgn_code, trans_date, total_cost, status)
    SELECT
      item_id, whse_code, orgn_code, trans_date, NULL, -3
    FROM
      opi_pmi_cost_temp1_gtmp
    WHERE cost_basis IS NULL
    AND item_id IS NOT NULL
    AND whse_code IS NOT NULL
    AND orgn_code IS NOT NULL
    AND trans_date IS NOT NULL;

END get_cost;

END opi_pmi_cost;

/
