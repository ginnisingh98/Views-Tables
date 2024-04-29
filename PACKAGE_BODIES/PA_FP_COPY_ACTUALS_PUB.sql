--------------------------------------------------------
--  DDL for Package Body PA_FP_COPY_ACTUALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_COPY_ACTUALS_PUB" as
/* $Header: PAFPCAPB.pls 120.6.12010000.3 2009/06/15 10:17:43 gboomina ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/**This procedure is called to copy actuals to budget version lines**/
PROCEDURE COPY_ACTUALS
          (P_PROJECT_ID                     IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID              IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_END_DATE                       IN            DATE,
           P_INIT_MSG_FLAG                  IN            VARCHAR2 default 'Y',
           P_COMMIT_FLAG                    IN            VARCHAR2 default 'N',
           X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
           X_MSG_DATA                       OUT  NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.pa_fp_copy_actuals_pub.copy_actuals';
    l_project_id_tab               SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_resource_list_id_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_struct_ver_id_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_calendar_type_tab            SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
    l_end_date_pji_tab             SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
    l_calendar_type                VARCHAR2(15);
    l_record_type                  VARCHAR2(15);

    l_count                     NUMBER;
    l_msg_count                 NUMBER;
    l_data                      VARCHAR2(1000);
    l_msg_data                  VARCHAR2(1000);
    l_msg_index_out             NUMBER;

    CURSOR distinct_ra_curr_cursor (c_multi_currency_flag VARCHAR2,
                                    c_proj_currency_code VARCHAR2,
                                    c_projfunc_currency_code VARCHAR2) IS
    SELECT distinct pji_tmp.source_id,
           DECODE(c_multi_currency_flag,
                  'Y', pji_tmp.txn_currency_code,
                  'N', c_proj_currency_code,
                  'A', c_projfunc_currency_code)
    FROM pji_fm_xbs_accum_tmp1 pji_tmp;

/* Bug No.3858184
Cursors(budget_line_cursor_pa, budget_line_cursor_gl, budget_line_cursor_np)
modified to filter the records based on the VERSION_TYPE.
For COST versions, the records in the PJI_FM_XBS_ACCUM_TMP1 table
will be processed only if raw cost or the burdened cost is not equal to zero.
For Revenue versions, the records in the PJI_FM_XBS_ACCUM_TMP1 table
will be processed only if the revenue amt is not equal to zero. */

    CURSOR budget_line_cursor_pa(c_multi_currency_flag VARCHAR2,
                              c_res_asg_id NUMBER,
                              c_txn_currency_code VARCHAR2,
                              c_org_id  NUMBER,
                              c_version_type VARCHAR2) IS
    SELECT pji_tmp.period_name,
           pd.start_date,
           pd.end_date,
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,pa_periods_all pd
    WHERE  c_version_type = 'ALL'
           AND (   (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                   (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                   (NVL(pji_tmp.txn_revenue, 0)   <> 0) OR
                   (NVL(pji_tmp.quantity,0)       <> 0)
               )
           AND pd.org_id = c_org_id
           AND pd.period_name = pji_tmp.period_name
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
    GROUP BY pji_tmp.period_name,
             pd.start_date,
             pd.end_date
    UNION ALL
    SELECT pji_tmp.period_name,
           pd.start_date,
           pd.end_date,
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,pa_periods_all pd
    WHERE  c_version_type = 'COST'
           AND (   (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                   (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                   (NVL(pji_tmp.quantity,0)       <> 0)
               )
           AND pd.org_id = c_org_id
           AND pd.period_name = pji_tmp.period_name
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
    GROUP BY pji_tmp.period_name,
             pd.start_date,
             pd.end_date
    UNION ALL
    SELECT pji_tmp.period_name,
           pd.start_date,
           pd.end_date,
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,pa_periods_all pd
    WHERE  c_version_type = 'REVENUE'
           AND (
                    (NVL(pji_tmp.txn_revenue, 0) <> 0)  OR
                    (NVL(pji_tmp.quantity,0)     <> 0)
               )
           AND pd.org_id = c_org_id
           AND pd.period_name = pji_tmp.period_name
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
    GROUP BY pji_tmp.period_name,
             pd.start_date,
             pd.end_date;

    CURSOR budget_line_cursor_gl(c_multi_currency_flag VARCHAR2,
                              c_res_asg_id NUMBER,
                              c_txn_currency_code VARCHAR2,
                              c_set_of_books_id NUMBER,
                              c_version_type VARCHAR2) IS
    SELECT pji_tmp.period_name,
           gd.start_date,
           gd.end_date,
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,gl_period_statuses gd
    WHERE  c_version_type = 'ALL'
           AND (   (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                   (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                   (NVL(pji_tmp.txn_revenue, 0)   <> 0) OR
                   (NVL(pji_tmp.quantity,0)       <> 0)
               )
           AND gd.SET_OF_BOOKS_ID = c_set_of_books_id
           AND gd.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
           AND gd.ADJUSTMENT_PERIOD_FLAG = 'N'
           AND gd.period_name = pji_tmp.period_name
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
    GROUP BY pji_tmp.period_name,
             gd.start_date,
             gd.end_date
    UNION ALL
    SELECT pji_tmp.period_name,
           gd.start_date,
           gd.end_date,
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,gl_period_statuses gd
    WHERE  c_version_type = 'COST'
           AND (
                 (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                 (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                 (NVL(pji_tmp.quantity,0)       <> 0)
               )
           AND gd.SET_OF_BOOKS_ID = c_set_of_books_id
           AND gd.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
           AND gd.ADJUSTMENT_PERIOD_FLAG = 'N'
           AND gd.period_name = pji_tmp.period_name
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
    GROUP BY pji_tmp.period_name,
             gd.start_date,
             gd.end_date
    UNION ALL
    SELECT pji_tmp.period_name,
           gd.start_date,
           gd.end_date,
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,gl_period_statuses gd
    WHERE  c_version_type = 'REVENUE'
           AND (
                    (NVL(pji_tmp.txn_revenue, 0) <> 0)  OR
                    (NVL(pji_tmp.quantity,0)     <> 0)
               )
           AND gd.SET_OF_BOOKS_ID = c_set_of_books_id
           AND gd.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
           AND gd.ADJUSTMENT_PERIOD_FLAG = 'N'
           AND gd.period_name = pji_tmp.period_name
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
    GROUP BY pji_tmp.period_name,
             gd.start_date,
             gd.end_date;

    CURSOR budget_line_cursor_np(c_multi_currency_flag VARCHAR2,
                              c_res_asg_id NUMBER,
                              c_txn_currency_code VARCHAR2,
                              c_proj_id   NUMBER,
                              c_version_type VARCHAR2) IS
    SELECT pji_tmp.period_name,
           nvl(ra.planning_start_date, TRUNC(Sysdate)),
           nvl(ra.planning_end_date, TRUNC(Sysdate)),
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,
           pa_resource_assignments ra
    WHERE  c_version_type = 'ALL'
           AND (   (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                   (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                   (NVL(pji_tmp.txn_revenue, 0)   <> 0) OR
                   (NVL(pji_tmp.quantity,0)       <> 0)
               )
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
           AND ra.resource_assignment_id = c_res_asg_id
    GROUP BY pji_tmp.period_name,
             nvl(ra.planning_start_date, TRUNC(Sysdate)),
             nvl(ra.planning_end_date, TRUNC(Sysdate))
    UNION ALL
    SELECT pji_tmp.period_name,
           nvl(ra.planning_start_date, TRUNC(Sysdate)),
           nvl(ra.planning_end_date, TRUNC(Sysdate)),
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,
           pa_resource_assignments ra
    WHERE  c_version_type = 'COST'
           AND (
                 (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                 (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                 (NVL(pji_tmp.quantity,0)       <> 0)
               )
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
           AND ra.resource_assignment_id = c_res_asg_id
    GROUP BY pji_tmp.period_name,
             nvl(ra.planning_start_date, TRUNC(Sysdate)),
             nvl(ra.planning_end_date, TRUNC(Sysdate))
    UNION ALL
    SELECT pji_tmp.period_name,
           nvl(ra.planning_start_date, TRUNC(Sysdate)),
           nvl(ra.planning_end_date, TRUNC(Sysdate)),
           sum(pji_tmp.quantity),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue)),
           sum(pji_tmp.prj_raw_cost),
           sum(pji_tmp.prj_brdn_cost),
           sum(pji_tmp.prj_revenue),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_raw_cost,
                      'N', pji_tmp.prj_raw_cost,
                      'A', pji_tmp.pou_raw_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_brdn_cost,
                      'N', pji_tmp.prj_brdn_cost,
                      'A', pji_tmp.pou_brdn_cost)),
           sum(DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.pou_revenue,
                      'N', pji_tmp.prj_revenue,
                      'A', pji_tmp.pou_revenue))
    FROM   pji_fm_xbs_accum_tmp1 pji_tmp,
           pa_resource_assignments ra
    WHERE  c_version_type = 'REVENUE'
           AND (
                  (NVL(pji_tmp.txn_revenue, 0) <> 0) OR
                  (NVL(pji_tmp.quantity,0)     <> 0)
               )
           AND pji_tmp.source_id = c_res_asg_id
           AND DECODE(c_multi_currency_flag,'Y',
               pji_tmp.txn_currency_code,c_txn_currency_code)
               = c_txn_currency_code
           AND ra.resource_assignment_id = c_res_asg_id
    GROUP BY pji_tmp.period_name,
             nvl(ra.planning_start_date, TRUNC(Sysdate)),
             nvl(ra.planning_end_date, TRUNC(Sysdate));

    l_ra                                NUMBER;
    l_org_id                            NUMBER;
    l_set_of_books_id                   NUMBER;
    l_rlm_id                            pa_resource_list_members.resource_list_member_id%TYPE;
    l_res_asg_id_tab                    pa_plsql_datatypes.IdTabTyp;
    l_txn_currency_code_tab             pa_plsql_datatypes.Char30TabTyp;
    l_period_name_tab                   pa_plsql_datatypes.Char30TabTyp;
    l_quantity_tab                      pa_plsql_datatypes.NumTabTyp;
    l_txn_raw_cost_tab                  pa_plsql_datatypes.NumTabTyp;
    l_txn_brdn_cost_tab                 pa_plsql_datatypes.NumTabTyp;
    l_txn_revenue_tab                   pa_plsql_datatypes.NumTabTyp;
    l_proj_raw_cost_tab                 pa_plsql_datatypes.NumTabTyp;
    l_proj_brdn_cost_tab                pa_plsql_datatypes.NumTabTyp;
    l_proj_revenue_tab                  pa_plsql_datatypes.NumTabTyp;
    l_pou_raw_cost_tab                  pa_plsql_datatypes.NumTabTyp;
    l_pou_brdn_cost_tab                 pa_plsql_datatypes.NumTabTyp;
    l_pou_revenue_tab                   pa_plsql_datatypes.NumTabTyp;
    l_start_date_tab                    pa_plsql_datatypes.DateTabTyp;
    l_end_date_tab                      pa_plsql_datatypes.DateTabTyp;
    l_start_date                        Date;
    l_end_date                          Date;

    l_amt_dtls_tbl                      pa_fp_maintain_actual_pub.l_amt_dtls_tbl_typ;
    l_wp_version_flag                   VARCHAR2(1);
    l_count_no_rlm                      NUMBER;
    l_rate_based_flag                   VARCHAR2(1);
    l_uncategorized_flag                VARCHAR2(1);
    l_rev_gen_method                    VARCHAR2(3);
    l_res_asg_id_tmp_tab                pa_plsql_datatypes.IdTabTyp;

    l_plan_class_code              PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE;
    l_txn_currency_flag            VARCHAR2(1) := 'Y';
    l_fin_plan_type_id             PA_PROJ_FP_OPTIONS.fin_plan_type_id%TYPE;

    l_etc_start_date               DATE;
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'COPY_ACTUALS',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.initialize;
        x_msg_count := 0;
    END IF;

    IF P_PROJECT_ID is null or p_budget_version_id is null THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

   l_rev_gen_method := nvl(P_FP_COLS_REC.X_REVENUE_DERIVATION_METHOD,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); --Bug 5462471
    --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id);

    /* Set the currency flag as follows:
      l_txn_currency_flag is 'Y' means we use txn_currency_code
      l_txn_currency_flag is 'N' means we use proj_currency_code
      l_txn_currency_flag is 'A' means we use projfunc_currency_code
     */

     -- Bug 7302700 - Moved the condition on x_plan_in_multi_curr_flag before checking if the
 	     -- revenue forecast is generated from a forecast plan type with cost accrual method.
 	     IF p_fp_cols_rec.x_plan_in_multi_curr_flag = 'N' THEN
 	         l_txn_currency_flag := 'N';
 	     END IF;

    IF l_rev_gen_method = 'C' AND
       p_fp_cols_rec.x_version_type = 'REVENUE' AND
       p_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID IS NOT NULL THEN

        SELECT plan_class_code
          INTO l_plan_class_code
          FROM pa_fin_plan_types_b
         WHERE fin_plan_type_id = p_fp_cols_rec.X_GEN_SRC_PLAN_TYPE_ID;

        IF l_plan_class_code = 'FORECAST' THEN
            l_txn_currency_flag := 'A';
        END IF;

     END IF;

    l_calendar_type := p_fp_cols_rec.X_TIME_PHASED_CODE;

    l_project_id_tab.extend;
    l_resource_list_id_tab.extend;
    l_struct_ver_id_tab.extend;
    l_calendar_type_tab.extend;
    l_end_date_pji_tab.extend;

    l_project_id_tab(1) := p_project_id;
    l_resource_list_id_tab(1) := p_fp_cols_rec.X_RESOURCE_LIST_ID;
    l_calendar_type_tab(1) := l_calendar_type;
    l_end_date_pji_tab(1) := p_end_date;

    --Structure version id should be the structure version id of the current published version
    --for B/F.
    SELECT wp_version_flag
    INTO   l_wp_version_flag
    FROM   pa_budget_Versions
    WHERE  budget_version_id=P_BUDGET_VERSION_ID;

    IF l_wp_version_flag = 'Y' THEN
       l_struct_ver_id_tab(1) := p_fp_cols_rec.X_PROJECT_STRUCTURE_VERSION_ID;
    ELSE
       l_struct_ver_id_tab(1) := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id => p_project_id );
    END IF;

    /**l_record_type: XXXX
      *1st X: 'Y',data will be returned in periods;
      *       'N',ITD amounts will be returned;
      *2nd X: 'Y',data will be returned by planning resources at
      *        entered level(periodic/total);
      *3rd X:  'Y',data is returned by tasks;
      *        'N',data is returned by project level;
      *4th X:  'N',amt will be gotten at entered level, no rollup is done.**/
    IF (l_calendar_type = 'G' OR l_calendar_type = 'P') THEN
        l_record_type := 'Y';
    ELSE
        l_record_type := 'N';
    END IF;
    l_record_type := l_record_type||'Y';
    IF p_fp_cols_rec.X_FIN_PLAN_LEVEL_CODE IN ('L', 'T') THEN
        l_record_type := l_record_type||'Y';
    ELSE
        l_record_type := l_record_type||'N';
    END IF;
    l_record_type := l_record_type||'N';
    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         =>  'Before calling pji_fm_xbs_accum_tmp1',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    --dbms_output.put_line('Before calling pji api');
    --Calling PJI API to get table pji_fm_xbs_accum_tmp1 populated
    --hr_utility.trace_on(null,'mftest');
    --hr_utility.trace('before entering get_sum');
    --hr_utility.trace('l_project_id_tab:'||l_project_id_tab(1));
    --hr_utility.trace('l_resource_list_id_tab:'||l_resource_list_id_tab(1));
    --hr_utility.trace('l_struct_ver_id_tab:'||l_struct_ver_id_tab(1));
    --hr_utility.trace('p_end_date:'||p_end_date);
    --hr_utility.trace('l_calendar_type:'||l_calendar_type);
    --hr_utility.trace('l_record_type:'||l_record_type);
    PJI_FM_XBS_ACCUM_UTILS.get_summarized_data(
        p_project_ids           => l_project_id_tab,
        p_resource_list_ids     => l_resource_list_id_tab,
        p_struct_ver_ids        => l_struct_ver_id_tab,
        --p_start_date            => NULL,
        p_end_date              => l_end_date_pji_tab,
        --p_start_period_name     => NULL,
        --p_end_period_name       => NULL,
        p_calendar_type         => l_calendar_type_tab,
        p_record_type           => l_record_type,
        p_currency_type         => 6,
        x_return_status         => x_return_status,
        x_msg_code              => x_msg_data);
    --dbms_output.put_line('After calling pji api: '||x_return_status);
    select count(*) into l_count from pji_fm_xbs_accum_tmp1;


     --hr_utility.trace('after entering get_sum:'||x_return_status);
     --delete from get_sum_test;
     --insert into get_sum_test (select * from  pji_fm_xbs_accum_tmp1);
    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'After calling pji_fm_xbs_accum_tmp1,return status is: '||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    --dbms_output.put_line('After calling pji api: '||x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF l_count = 0 THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'no actual data as of '||
             to_char(p_end_date,'dd-mon-rrrr'),
             p_module_name => l_module_name,
             p_log_level   => 5);
                PA_DEBUG.RESET_CURR_FUNCTION;
       END IF;
       RETURN;
    END IF;

    select count(*) into l_count_no_rlm from pji_fm_xbs_accum_tmp1 WHERE
    res_list_member_id IS NULL;

    IF l_count_no_rlm > 0 THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name     => 'PA_FP_NO_RLM_ID_FOR_ACTUAL');
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Update rlm_id for all rows in pji_fm_xbs_accum_tmp1 if the resource list
     * (p_fp_cols_rec.X_RESOURCE_LIST_ID) is None - Uncategorized.
     * This logic is not handled by the PJI generic resource mapping API. */

    SELECT NVL(uncategorized_flag,'N')
      INTO l_uncategorized_flag
      FROM pa_resource_lists_all_bg
     WHERE resource_list_id = p_fp_cols_rec.X_RESOURCE_LIST_ID;

    IF l_uncategorized_flag = 'Y' THEN
        l_rlm_id := PA_FP_GEN_AMOUNT_UTILS.GET_RLM_ID (
                       p_project_id          => p_project_id,
                       p_resource_list_id    => p_fp_cols_rec.X_RESOURCE_LIST_ID,
                       p_resource_class_code => 'FINANCIAL_ELEMENTS' );
        UPDATE pji_fm_xbs_accum_tmp1
           SET res_list_member_id = l_rlm_id;
    END IF;

    /* updating the project element id ( task id ) to NULL
       when the value is <= 0 for addressing the P1 bug 3841480.
       Please note that we cannot resolve the issue by populating the NULL value
       into the tmp table PA_FP_PLANNING_RES_TMP1. Because, the task id value is referred
       in the pji_fm_xbs_accum_tmp1 table later in the code. */

    update pji_fm_xbs_accum_tmp1 set  project_element_id = null
        where NVL(project_element_id,0) <= 0;

    /**Populating PA_FP_PLANNING_RES_TMP1, call COPY_ACUTALS_PUB.CREATE_RES_ASG to create
      *missing resource assignment in pa_resource_assignment table. After that, resource_
      *assignment_id will be populated pa_fp_planning_res_tmp1.
      **/
    DELETE FROM PA_FP_PLANNING_RES_TMP1;
    INSERT INTO PA_FP_PLANNING_RES_TMP1 (
                TASK_ID,
                RESOURCE_LIST_MEMBER_ID,
                RESOURCE_ASSIGNMENT_ID )
    ( SELECT    DISTINCT PROJECT_ELEMENT_ID,
                RES_LIST_MEMBER_ID,
                NULL
    FROM PJI_FM_XBS_ACCUM_TMP1);
    -- select count(*) into l_count from pa_resource_assignments where
    -- budget_version_id = p_budget_version_id;
    --dbms_output.put_line('before calling cre res asg api: res_assign has: '||l_count);
    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling pa_fp_copy_actuals_pub.create_res_asg',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    PA_FP_COPY_ACTUALS_PUB.CREATE_RES_ASG (
                P_PROJECT_ID            => P_PROJECT_ID,
                P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
                P_FP_COLS_REC           => P_FP_COLS_REC,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
    --dbms_output.put_line('Status after calling cre res asg api: '||x_return_status);
    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'After calling create_res_asg,return status is: '||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /**Calling update_res_asg to populate the newly created resource_assignment_id back to
      *pa_fp_planning_res_tmp1. Then this value needs to populated back to pji_fm_xbs_accum_tmp1
      **/
    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling update_res_asg',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    PA_FP_COPY_ACTUALS_PUB.UPDATE_RES_ASG (
                               P_PROJECT_ID         => P_PROJECT_ID,
                               P_BUDGET_VERSION_ID  => P_BUDGET_VERSION_ID,
                               P_FP_COLS_REC        => P_FP_COLS_REC,
                               X_RETURN_STATUS      => x_return_status,
                               X_MSG_COUNT          => x_msg_count,
                               X_MSG_DATA           => x_msg_data);
    --dbms_output.put_line('Status after calling upd res asg api: '||x_return_status);
   IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'After calling update_res_asg,return status is: '||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    UPDATE PJI_FM_XBS_ACCUM_TMP1 tmp1
    SET source_id =
        (SELECT /*+ INDEX(ra,PA_FP_PLANNING_RES_TMP1_N2)*/ resource_assignment_id
         FROM PA_FP_PLANNING_RES_TMP1 ra
         WHERE nvl(ra.task_id,0) = nvl(tmp1.project_element_id,0)
               AND ra.resource_list_member_id = tmp1.res_list_member_id );
    --dbms_output.put_line('No.of rows updated in pji_fm_xbs_accum_tmp1 table: '||sql%rowcount);
    --dbms_output.put_line('Opening distinct_ra_curr_cursor');
    OPEN distinct_ra_curr_cursor(l_txn_currency_flag,
                                 P_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
                                 P_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE);
    FETCH distinct_ra_curr_cursor
    BULK COLLECT
    INTO l_res_asg_id_tab,
         l_txn_currency_code_tab;
    CLOSE distinct_ra_curr_cursor;
    --dbms_output.put_line('Closing distinct_ra_curr_cursor');
    IF l_res_asg_id_tab.count = 0 THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.RESET_CURR_FUNCTION;
       END IF;
       RETURN;
    END IF;

    IF l_rev_gen_method = 'C' AND
       p_fp_cols_rec.x_version_type = 'REVENUE' THEN

        SELECT DISTINCT source_id
        BULK   COLLECT
        INTO   l_res_asg_id_tmp_tab
        FROM   pji_fm_xbs_accum_tmp1;

        -- Bug 4170419: Start
        -- FORALL k IN 1..l_res_asg_id_tmp_tab.count
        --      UPDATE pa_resource_assignments ra
        --      SET    ra.unit_of_measure = 'DOLLARS',
        --             ra.rate_based_flag = 'N'
        --      WHERE  ra.resource_assignment_id = l_res_asg_id_tmp_tab(k);

        If p_fp_cols_rec.x_time_phased_code IN ('P','G') then
           l_etc_start_date := PA_FP_GEN_AMOUNT_UTILS.get_etc_start_date(p_fp_cols_rec.x_budget_version_id);

           FORALL k IN 1..l_res_asg_id_tmp_tab.count
              UPDATE pa_resource_assignments ra
              SET    ra.unit_of_measure = 'DOLLARS',
                     ra.rate_based_flag = 'N'
              WHERE  ra.resource_assignment_id = l_res_asg_id_tmp_tab(k)
              AND    ( ra.transaction_source_code is not null
                       OR
                      (ra.transaction_source_code is null and NOT exists
                        ( select 1
                          from pa_budget_lines pbl
                          where pbl.resource_assignment_id = ra.resource_assignment_id
                          and   pbl.start_date >= l_etc_start_date
                        )
                      )
                     );

         Else
            FORALL k IN 1..l_res_asg_id_tmp_tab.count
              UPDATE pa_resource_assignments ra
              SET    ra.unit_of_measure = 'DOLLARS',
                     ra.rate_based_flag = 'N'
              WHERE  ra.resource_assignment_id = l_res_asg_id_tmp_tab(k)
              AND    ( ra.transaction_source_code is not null
                       OR
                       (ra.transaction_source_code is null and NOT exists
                        ( select 1
                          from pa_budget_lines pbl
                          where pbl.resource_assignment_id = ra.resource_assignment_id
                        )
                       )
                     );
         End If;

        -- Bug 4170419: End

    END IF;

    l_org_id := P_FP_COLS_REC.x_org_id;
    l_set_of_books_id := P_FP_COLS_REC.x_set_of_books_id;
    --dbms_output.put_line('l_calendar_type: '||l_calendar_type);
    FOR i IN 1..l_res_asg_id_tab.count LOOP
        IF l_calendar_type = 'P' THEN
    --dbms_output.put_line('Opening budget_line_cursor_pa');
            OPEN budget_line_cursor_pa(
                l_txn_currency_flag,
                l_res_asg_id_tab(i),
                l_txn_currency_code_tab(i),
                l_org_id,
                P_FP_COLS_REC.X_VERSION_TYPE);
            FETCH budget_line_cursor_pa
            BULK COLLECT
            INTO l_period_name_tab,
                 l_start_date_tab,
                 l_end_date_tab,
                 l_quantity_tab,
                 l_txn_raw_cost_tab,
                 l_txn_brdn_cost_tab,
                 l_txn_revenue_tab,
                 l_proj_raw_cost_tab,
                 l_proj_brdn_cost_tab,
                 l_proj_revenue_tab,
                 l_pou_raw_cost_tab,
                 l_pou_brdn_cost_tab,
                 l_pou_revenue_tab;
            CLOSE budget_line_cursor_pa;
    --dbms_output.put_line('Closing budget_line_cursor_pa');
        ELSIF l_calendar_type = 'G' THEN
    --dbms_output.put_line('Opening budget_line_cursor_gl');
            OPEN budget_line_cursor_gl(
                l_txn_currency_flag,
                l_res_asg_id_tab(i),
                l_txn_currency_code_tab(i),
                l_set_of_books_id,
                P_FP_COLS_REC.X_VERSION_TYPE);
            FETCH budget_line_cursor_gl
            BULK COLLECT
            INTO l_period_name_tab,
                 l_start_date_tab,
                 l_end_date_tab,
                 l_quantity_tab,
                 l_txn_raw_cost_tab,
                 l_txn_brdn_cost_tab,
                 l_txn_revenue_tab,
                 l_proj_raw_cost_tab,
                 l_proj_brdn_cost_tab,
                 l_proj_revenue_tab,
                 l_pou_raw_cost_tab,
                 l_pou_brdn_cost_tab,
                 l_pou_revenue_tab;
            CLOSE budget_line_cursor_gl;
    --dbms_output.put_line('Closing budget_line_cursor_gl');
        ELSE
    --dbms_output.put_line('Opening budget_line_cursor_np');
            OPEN budget_line_cursor_np(
                l_txn_currency_flag,
                l_res_asg_id_tab(i),
                l_txn_currency_code_tab(i),
                P_PROJECT_ID,
                P_FP_COLS_REC.X_VERSION_TYPE);
            FETCH budget_line_cursor_np
            BULK COLLECT
            INTO l_period_name_tab,
                 l_start_date_tab,
                 l_end_date_tab,
                 l_quantity_tab,
                 l_txn_raw_cost_tab,
                 l_txn_brdn_cost_tab,
                 l_txn_revenue_tab,
                 l_proj_raw_cost_tab,
                 l_proj_brdn_cost_tab,
                 l_proj_revenue_tab,
                 l_pou_raw_cost_tab,
                 l_pou_brdn_cost_tab,
                 l_pou_revenue_tab;
            CLOSE budget_line_cursor_np;
    --dbms_output.put_line('Closing budget_line_cursor_np');
        END IF;

        SELECT rate_based_flag into l_rate_based_flag
        FROM pa_resource_assignments
        WHERE resource_assignment_id = l_res_asg_id_tab(i);
    --dbms_output.put_line('l_rate_based_flag: '||l_rate_based_flag);
        IF l_rate_based_flag = 'N' THEN
            IF P_FP_COLS_REC.x_version_type = 'REVENUE' THEN
                l_quantity_tab := l_txn_revenue_tab;
            ELSE
                l_quantity_tab := l_txn_raw_cost_tab;
            END IF;
        END IF;


        l_amt_dtls_tbl.delete;
        FOR j IN 1..l_period_name_tab.count LOOP
            l_amt_dtls_tbl(j).period_name := l_period_name_tab(j);
            l_amt_dtls_tbl(j).start_date := l_start_date_tab(j);
            l_amt_dtls_tbl(j).end_date := l_end_date_tab(j);
            l_amt_dtls_tbl(j).quantity := l_quantity_tab(j);
            l_amt_dtls_tbl(j).txn_raw_cost := l_txn_raw_cost_tab(j);
            l_amt_dtls_tbl(j).txn_burdened_cost := l_txn_brdn_cost_tab(j);
            l_amt_dtls_tbl(j).txn_revenue := l_txn_revenue_tab(j);
            l_amt_dtls_tbl(j).project_raw_cost := l_proj_raw_cost_tab(j);
            l_amt_dtls_tbl(j).project_burdened_cost := l_proj_brdn_cost_tab(j);
            l_amt_dtls_tbl(j).project_revenue := l_proj_revenue_tab(j);
            l_amt_dtls_tbl(j).project_func_raw_cost := l_pou_raw_cost_tab(j);
            l_amt_dtls_tbl(j).project_func_burdened_cost := l_pou_brdn_cost_tab(j);
            l_amt_dtls_tbl(j).project_func_revenue := l_pou_revenue_tab(j);
            /*For cost version, revenue amounts should be null
              For revenue version, cost amounts should be null */
            IF p_fp_cols_rec.x_version_type = 'COST' THEN
               l_amt_dtls_tbl(j).txn_revenue := null;
               l_amt_dtls_tbl(j).project_revenue := null;
               l_amt_dtls_tbl(j).project_func_revenue := null;
            ELSIF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
               l_amt_dtls_tbl(j).txn_raw_cost := null;
               l_amt_dtls_tbl(j).txn_burdened_cost := null;
               l_amt_dtls_tbl(j).project_raw_cost := null;
               l_amt_dtls_tbl(j).project_burdened_cost := null;
               l_amt_dtls_tbl(j).project_func_raw_cost := null;
               l_amt_dtls_tbl(j).project_func_burdened_cost := null;
            END IF;

            /*  The following logic needs to be handled in Calculate API.
                Currently, Calculate API does not handle the NULL qty logic. *.
            IF p_fp_cols_rec.x_version_type = 'REVENUE' AND
               l_rev_gen_method = 'C' THEN
               l_amt_dtls_tbl(j).quantity := null;
            END IF; */

        END LOOP;

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling  PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA',
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;
        /**Populating target budget lines by summing up the values.
          *P_AMT_DTLS_REC_TAB has the amt data for each specific resource_assignment_id
          *3.and txn_currency_code**/
    --dbms_output.put_line('b4 calling MAINTAIN_ACTUAL_AMT_RA');
        PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA (
            P_PROJECT_ID                => P_PROJECT_ID,
            P_BUDGET_VERSION_ID         => P_BUDGET_VERSION_ID,
            P_RESOURCE_ASSIGNMENT_ID    => l_res_asg_id_tab(i),
            P_TXN_CURRENCY_CODE         => l_txn_currency_code_tab(i),
            P_AMT_DTLS_REC_TAB          => l_amt_dtls_tbl,
            P_CALLING_CONTEXT           => 'FP_GEN_FCST_COPY_ACTUAL',
            X_RETURN_STATUS             => x_return_Status,
            X_MSG_COUNT                 => x_msg_count,
            X_MSG_DATA                  => x_msg_data );
    --dbms_output.put_line('Status after calling MAINTAIN_ACTUAL_AMT_RA api: '||x_return_status);
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'After calling  PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA,
                                return status is: '||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    END LOOP;

    /* the planning start date and end date in pa_resource assignments table
     * should be synched up with the budget lines after copying the actual
     * data for all the planning resources. */
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Before calling PA_FP_MAINTAIN_ACTUAL_PUB.' ||
                               'SYNC_UP_PLANNING_DATES',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    --dbms_output.put_line('b4 calling SYNC_UP_PLANNING_DATES');
    PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES
        ( P_BUDGET_VERSION_ID   => p_budget_version_id,
          P_CALLING_CONTEXT     => 'COPY_ACTUALS',
          X_RETURN_STATUS       => x_return_Status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA            => x_msg_data );
    --dbms_output.put_line('Status after calling SYNC_UP_PLANNING_DATES api: '||x_return_status);
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Aft calling PA_FP_MAINTAIN_ACTUAL_PUB.' ||
                               'SYNC_UP_PLANNING_DATES return status ' ||
                               x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- IPM: New Entity ER ------------------------------------------
    -- Actual amounts must be rolled up for non-timephased versions
    -- before the Calculate API is called since actuals and planned
    -- amounts exist in the same budget line in this case.
    IF p_fp_cols_rec.x_time_phased_code = 'N' THEN

        DELETE pa_resource_asgn_curr_tmp;

        FORALL i IN 1..l_res_asg_id_tab.count
            INSERT INTO pa_resource_asgn_curr_tmp (
                resource_assignment_id,
                txn_currency_code )
             VALUES (
                l_res_asg_id_tab(i),
                l_txn_currency_code_tab(i) );

        UPDATE pa_resource_asgn_curr_tmp tmp
        SET  ( txn_raw_cost_rate_override,
               txn_burden_cost_rate_override,
               txn_bill_rate_override ) =
             ( SELECT rbc.txn_raw_cost_rate_override,
                      rbc.txn_burden_cost_rate_override,
                      rbc.txn_bill_rate_override
               FROM   pa_resource_asgn_curr rbc
               WHERE  tmp.resource_assignment_id = rbc.resource_assignment_id
               AND    tmp.txn_currency_code = rbc.txn_currency_code );

        -- Call the maintenance api in ROLLUP mode
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'MAINTAIN_DATA',
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
              ( P_FP_COLS_REC           => p_fp_cols_rec,
                P_CALLING_MODULE        => 'FORECAST_GENERATION',
                P_VERSION_LEVEL_FLAG    => 'N',
                P_ROLLUP_FLAG           => 'Y',
              --P_CALLED_MODE           => p_called_mode,
                X_RETURN_STATUS         => x_return_status,

                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'MAINTAIN_DATA: '||x_return_status,
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    END IF; -- IF p_fp_cols_rec.x_time_phased_code = 'N' THEN
    -- END OF IPM: New Entity ER ------------------------------------------

    IF P_COMMIT_FLAG = 'Y' THEN
        COMMIT;
    END IF;
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Invalid Arguments Passed',
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        rollback;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_COPY_ACTUALS_PUB',
                     p_procedure_name  => 'COPY_ACTUALS',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END COPY_ACTUALS;


PROCEDURE  CREATE_RES_ASG (
           P_PROJECT_ID            IN  PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID     IN  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC           IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_CALLING_PROCESS       IN  VARCHAR2,
           X_RETURN_STATUS         OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT             OUT NOCOPY   NUMBER,
           X_MSG_DATA              OUT NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.pa_fp_copy_actuals_pub.create_res_asg';

    l_fp_cols_rec               PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_res_plan_level            VARCHAR2(15);

    CURSOR project_res_asg_cur
        ( p_proj_start_date DATE,
          p_proj_completion_date DATE,
          c_gen_etc_source_code VARCHAR2 ) IS
    SELECT distinct nvl(tmp1.task_id,0),
                    tmp1.resource_list_member_id,
                    DECODE(p_calling_process, 'COPY_ACTUALS',
                           p_proj_start_date,
                           tmp1.planning_start_date),
                    DECODE(p_calling_process, 'COPY_ACTUALS',
                           p_proj_completion_date,
                           tmp1.planning_end_date),
                    NVL(c_gen_etc_source_code, NULL)
    FROM   PA_FP_PLANNING_RES_TMP1 tmp1
    WHERE  nvl(tmp1.task_id,0) = 0
           AND NOT EXISTS (
           SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N2)*/ 1
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
                 AND NVL(ra.task_id,0) = 0
                 AND ra.resource_list_member_id = tmp1.resource_list_member_id);

    CURSOR lowestTask_res_asg_cur
        ( p_proj_start_date DATE,
          p_proj_completion_date DATE,
          c_gen_etc_source_code VARCHAR2 ) IS
    SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N1)*/
           distinct tmp1.task_id,
                    tmp1.resource_list_member_id,
                    DECODE(p_calling_process, 'COPY_ACTUALS',
                           NVL(task.start_date, p_proj_start_date),
                           tmp1.planning_start_date),
                    DECODE(p_calling_process, 'COPY_ACTUALS',
                           NVL(task.completion_date, p_proj_completion_date),
                           tmp1.planning_end_date),
                    NVL(c_gen_etc_source_code,
                        DECODE(p_calling_process, 'COPY_ACTUALS', NULL,task.GEN_ETC_SOURCE_CODE)) -- Bug 4193368 for staffing plan src should not be
                     -- based on task's etc source
    FROM   PA_FP_PLANNING_RES_TMP1 tmp1,
           pa_tasks task
    WHERE  nvl(tmp1.task_id,0) > 0
           AND tmp1.task_id = task.task_id
           AND NOT EXISTS (
           SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N2)*/ 1
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
                 AND nvl(ra.task_id,0) = nvl(tmp1.task_id,0)
                 AND ra.resource_list_member_id = tmp1.resource_list_member_id)
    UNION
    SELECT distinct nvl(tmp1.task_id,0),
                    tmp1.resource_list_member_id,
                    DECODE(p_calling_process, 'COPY_ACTUALS',
                           p_proj_start_date,
                           tmp1.planning_start_date),
                    DECODE(p_calling_process, 'COPY_ACTUALS',
                           p_proj_completion_date,
                           tmp1.planning_end_date),
                    NVL(c_gen_etc_source_code, NULL)
    FROM   PA_FP_PLANNING_RES_TMP1 tmp1
    WHERE  nvl(tmp1.task_id,0)  = 0
           AND NOT EXISTS (
           SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N2)*/ 1
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
                 AND NVL(ra.task_id,0) = 0
                 AND ra.resource_list_member_id = tmp1.resource_list_member_id);

    CURSOR topTask_res_asg_cur
        ( p_proj_start_date DATE,
          p_proj_completion_date DATE,
          c_gen_etc_source_code VARCHAR2 ) IS
    SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N1)*/
           task_t.task_id,
           tmp1.resource_list_member_id,
           MIN(DECODE(p_calling_process, 'COPY_ACTUALS',
                      NVL(task_t.start_date, p_proj_start_date),
                      tmp1.planning_start_date)),
           MAX(DECODE(p_calling_process, 'COPY_ACTUALS',
                      NVL(task_t.completion_date, p_proj_completion_date),
                      tmp1.planning_end_date)),
           NVL(c_gen_etc_source_code,
                        DECODE(p_calling_process, 'COPY_ACTUALS', NULL,task_t.GEN_ETC_SOURCE_CODE)) -- Bug 4193368 for staffing plan src should not be
                     -- based on task's etc source
    FROM   PA_FP_PLANNING_RES_TMP1 tmp1,
           pa_tasks task, pa_tasks task_t
    WHERE  nvl(tmp1.task_id,0)  > 0
           AND tmp1.task_id = task.task_id
           AND task.top_task_id = task_t.task_id
           AND NOT EXISTS (
           SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N2)*/ 1
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
                 AND nvl(ra.task_id,0) = task_t.task_id
                 AND ra.resource_list_member_id = tmp1.resource_list_member_id)
    GROUP BY task_t.task_id,
             tmp1.resource_list_member_id,
             NVL(c_gen_etc_source_code,
                        DECODE(p_calling_process, 'COPY_ACTUALS', NULL,task_t.GEN_ETC_SOURCE_CODE)) -- Bug 4193368 for staffing plan src should not be
                     -- based on task's etc source
    UNION
    SELECT nvl(tmp1.task_id,0),
           tmp1.resource_list_member_id,
           MIN(DECODE(p_calling_process, 'COPY_ACTUALS',
                      p_proj_start_date,
                      tmp1.planning_start_date)),
           MAX(DECODE(p_calling_process, 'COPY_ACTUALS',
                      p_proj_completion_date,
                      tmp1.planning_end_date)),
           NVL(c_gen_etc_source_code, NULL)
    FROM   PA_FP_PLANNING_RES_TMP1 tmp1
    WHERE  nvl(tmp1.task_id,0) = 0
           AND NOT EXISTS (
           SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N2)*/ 1
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
                 AND NVL(ra.task_id,0) = 0
                 AND ra.resource_list_member_id = tmp1.resource_list_member_id)
    GROUP BY nvl(tmp1.task_id,0),
             tmp1.resource_list_member_id,
             NVL(c_gen_etc_source_code, NULL);

    l_task_id_tab                  pa_plsql_datatypes.IdTabTyp;
    l_rlm_id_tab                   pa_plsql_datatypes.IdTabTyp;
    l_start_date_tab               pa_plsql_datatypes.DateTabTyp;
    l_completion_date_tab          pa_plsql_datatypes.DateTabTyp;
    l_etc_src_code_tab             pa_plsql_datatypes.Char30TabTyp;
    l_proj_start_date              DATE;
    l_proj_completion_date         DATE;

    l_gen_etc_source_code_override VARCHAR2(30);

    l_count                     NUMBER;
    l_msg_count                 NUMBER;
    l_data                      VARCHAR2(1000);
    l_msg_data                  VARCHAR2(1000);
    l_msg_index_out             NUMBER;
    l_spread_curve_id           pa_spread_curves_b.spread_curve_id%TYPE;

   /* Variables added to replace literals in INSERT stmts. */
   l_project_as_id_minus1             NUMBER:=-1;
   l_res_as_type_USER_ENTERED         VARCHAR2(30):='USER_ENTERED';
   l_rec_ver_number_1                         NUMBER:=1;

   l_proj_struct_sharing_code         PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'CREATE_RES_ASG',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF (P_FP_COLS_REC.X_BUDGET_VERSION_ID IS NULL) THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTL',
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;
        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS(
                P_PROJECT_ID            => P_PROJECT_ID,
                P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
                X_FP_COLS_REC           => l_fp_cols_rec,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data);
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'After calling PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS,
                            return status:'||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    ELSE
        l_fp_cols_rec := P_FP_COLS_REC;
    END IF;
    l_res_plan_level := l_fp_cols_rec.X_FIN_PLAN_LEVEL_CODE;

    SELECT NVL(start_date,trunc(sysdate)),
           NVL(completion_date,trunc(sysdate))
           INTO l_proj_start_date, l_proj_completion_date
    FROM pa_projects_all
    WHERE project_id = P_PROJECT_ID;

    /* When the Target is a Revenue-only version, we need to take the target
     * version's ETC source code instead of the task-level source code for
     * the target resources that we are processing. */
    IF l_fp_cols_rec.x_version_type = 'REVENUE' THEN
        l_gen_etc_source_code_override := l_fp_cols_rec.x_gen_etc_src_code;
    ELSE
        l_gen_etc_source_code_override := NULL;
    END IF;

    l_proj_struct_sharing_code := NVL(pa_project_structure_utils.
                     get_structure_sharing_code(P_PROJECT_ID), 'SHARE_FULL');

    -- Bug 4174997: If the calling process is COPY_ACTUALS then we should
    -- go with the Target version's planning level, since we always have
    -- financial tasks for actuals.

    -- Bug 4232094: When the structure is 'SPLIT_NO_MAPPING', the only
    -- scenario in which we need to use the project-level cursor is when
    -- the Target version is Revenue and the Source version is Workplan.
    -- In all other scenarios, we should go with the Target version's
    -- planning level. This change overrides Bug fix 4174997.

    IF (l_res_plan_level = 'P' OR
       (l_proj_struct_sharing_code = 'SPLIT_NO_MAPPING' AND
        l_fp_cols_rec.x_version_type = 'REVENUE' AND
        l_fp_cols_rec.x_gen_etc_src_code = 'WORKPLAN_RESOURCES')) THEN
        OPEN project_res_asg_cur
            ( l_proj_start_date,
              l_proj_completion_date,
              l_gen_etc_source_code_override );
        FETCH project_res_asg_cur
        BULK COLLECT
        INTO l_task_id_tab,
             l_rlm_id_tab,
             l_start_date_tab,
             l_completion_date_tab,
             l_etc_src_code_tab;
        CLOSE project_res_asg_cur;
    ELSIF (l_res_plan_level = 'L') THEN
    -- hr_utility.trace('in create res asg low  task fetch '||l_task_id_tab.count);
        OPEN lowestTask_res_asg_cur
            ( l_proj_start_date,
              l_proj_completion_date,
              l_gen_etc_source_code_override );
        FETCH lowestTask_res_asg_cur
        BULK COLLECT
        INTO l_task_id_tab,
             l_rlm_id_tab,
             l_start_date_tab,
             l_completion_date_tab,
             l_etc_src_code_tab;
        CLOSE lowestTask_res_asg_cur;
    ELSIF (l_res_plan_level = 'T') THEN
        OPEN topTask_res_asg_cur
            ( l_proj_start_date,
              l_proj_completion_date,
              l_gen_etc_source_code_override );
        FETCH topTask_res_asg_cur
        BULK COLLECT
        INTO l_task_id_tab,
             l_rlm_id_tab,
             l_start_date_tab,
             l_completion_date_tab,
             l_etc_src_code_tab;
        CLOSE topTask_res_asg_cur;
    END IF;
    -- hr_utility.trace('in create res asg tab count '||l_task_id_tab.count);
    IF (l_task_id_tab.count = 0 ) THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.RESET_CURR_FUNCTION;
       END IF;
       RETURN;
    END IF;

    FORALL i in l_task_id_tab.first .. l_task_id_tab.last
    INSERT INTO PA_RESOURCE_ASSIGNMENTS (
                RESOURCE_ASSIGNMENT_ID,
                BUDGET_VERSION_ID,
                PROJECT_ID,
                RESOURCE_LIST_MEMBER_ID,
                TASK_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                PROJECT_ASSIGNMENT_ID,
                PLANNING_START_DATE,
                PLANNING_END_DATE,
                RESOURCE_ASSIGNMENT_TYPE,
                RECORD_VERSION_NUMBER,
                TRANSACTION_SOURCE_CODE )
    VALUES (
                pa_resource_assignments_s.nextval,
                p_budget_version_id,
                p_project_id,
                l_rlm_id_tab(i),
                l_task_id_tab(i),
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                l_project_as_id_minus1,
                l_start_date_tab(i),
                l_completion_date_tab(i),
                l_res_as_type_USER_ENTERED,
                l_rec_ver_number_1,
                l_etc_src_code_tab(i)
    );
    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling update_res_defaults',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    PA_FP_GEN_PUB.UPDATE_RES_DEFAULTS
        (P_PROJECT_ID           => P_PROJECT_ID,
        P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
        X_RETURN_STATUS         => x_return_status,
        X_MSG_COUNT             => x_msg_count,
        X_MSG_DATA              => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling update_res_defaults',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    SELECT  spread_curve_id
    INTO    l_spread_curve_id
    FROM    pa_spread_curves_b
    WHERE   spread_curve_code = 'FIXED_DATE';

    UPDATE   PA_RESOURCE_ASSIGNMENTS
    SET      SP_FIXED_DATE = PLANNING_START_DATE
    WHERE    SP_FIXED_DATE IS NULL
    AND      SPREAD_CURVE_ID = l_spread_curve_id
    AND      BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Invalid Arguments Passed',
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        rollback;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_COPY_ACTUALS_PUB',
                     p_procedure_name  => 'CREATE_RES_ASG',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CREATE_RES_ASG;


PROCEDURE  UPDATE_RES_ASG (
           P_PROJECT_ID            IN  PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID     IN  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC           IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_CALLING_PROCESS       IN  VARCHAR2,
           X_RETURN_STATUS         OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT             OUT NOCOPY   NUMBER,
           X_MSG_DATA              OUT NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.pa_fp_copy_actuals_pub.update_res_asg';
    l_res_plan_level            VARCHAR2(15);

    l_count                     NUMBER;
    l_msg_count                 NUMBER;
    l_data                      VARCHAR2(1000);
    l_msg_data                  VARCHAR2(1000);
    l_msg_index_out             NUMBER;

    l_proj_struct_sharing_code  PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'UPDATE_RES_ASG',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    l_res_plan_level := p_fp_cols_rec.X_FIN_PLAN_LEVEL_CODE;

    l_proj_struct_sharing_code := NVL(pa_project_structure_utils.
                        get_structure_sharing_code(P_PROJECT_ID),'SHARE_FULL');

    -- Bug 4174997: If the calling process is COPY_ACTUALS then we should
    -- go with the Target version's planning level, since we always have
    -- financial tasks for actuals.

    -- Bug 4232094: When the structure is 'SPLIT_NO_MAPPING', the only
    -- scenario in which we need to use the project-level cursor is when
    -- the Target version is Revenue and the Source version is Workplan.
    -- In all other scenarios, we should go with the Target version's
    -- planning level. This change overrides Bug fix 4174997.

    IF (l_res_plan_level = 'P' OR
       (l_proj_struct_sharing_code = 'SPLIT_NO_MAPPING' AND
        p_fp_cols_rec.x_version_type = 'REVENUE' AND
        p_fp_cols_rec.x_gen_etc_src_code = 'WORKPLAN_RESOURCES')) THEN

        UPDATE PA_FP_PLANNING_RES_TMP1 tmp1
        SET resource_assignment_id =
          (SELECT resource_assignment_id
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
             AND ra.project_id = P_PROJECT_ID
               AND nvl(ra.task_id,0) = 0
               AND ra.resource_list_member_id = tmp1.resource_list_member_id);

    ELSIF l_res_plan_level = 'L' THEN

        UPDATE PA_FP_PLANNING_RES_TMP1 tmp1
        SET resource_assignment_id =
          (SELECT resource_assignment_id
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
             AND ra.project_id = P_PROJECT_ID
             AND ra.task_id = tmp1.task_id
             AND ra.resource_list_member_id = tmp1.resource_list_member_id)
        WHERE tmp1.task_id is NOT NULL
        AND   tmp1.task_id > 0;

        UPDATE PA_FP_PLANNING_RES_TMP1 tmp1
        SET resource_assignment_id =
          (SELECT resource_assignment_id
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
             AND ra.project_id = P_PROJECT_ID
             AND nvl(ra.task_id,0) = 0
             AND ra.resource_list_member_id = tmp1.resource_list_member_id)
         WHERE nvl(tmp1.task_id,0) = 0;

    ELSIF l_res_plan_level = 'T' THEN

        UPDATE PA_FP_PLANNING_RES_TMP1 tmp1
        SET resource_assignment_id =
          (SELECT resource_assignment_id
           FROM pa_resource_assignments ra,
                pa_tasks t
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
             AND ra.project_id = P_PROJECT_ID
             AND tmp1.task_id  = t.task_id
             AND t.top_task_id = ra.task_id
             AND ra.resource_list_member_id = tmp1.resource_list_member_id)
        WHERE tmp1.task_id is NOT NULL
        AND   tmp1.task_id > 0;

        UPDATE PA_FP_PLANNING_RES_TMP1 tmp1
        SET resource_assignment_id =
          (SELECT resource_assignment_id
           FROM pa_resource_assignments ra
           WHERE ra.budget_version_id = P_BUDGET_VERSION_ID
             AND ra.project_id = P_PROJECT_ID
               AND nvl(ra.task_id,0) = 0
               AND ra.resource_list_member_id = tmp1.resource_list_member_id)
        WHERE nvl(tmp1.task_id,0) = 0;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Invalid Arguments Passed',
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        rollback;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_COPY_ACTUALS_PUB',
                     p_procedure_name  => 'UPDATE_RES_ASG',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END UPDATE_RES_ASG;

/**
  * gboomina added this method for AAI requirement
  * This procedure is called to collect actuals for a selected resource assignments or
  * for a whole budget version given.
  **/
  PROCEDURE COLLECT_ACTUALS
            (P_PROJECT_ID           IN   PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
             P_BUDGET_VERSION_ID    IN   PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
             P_RESOURCE_ASSGN_IDS   IN   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
             P_INIT_MSG_FLAG        IN   VARCHAR2 default 'Y',
             P_COMMIT_FLAG          IN   VARCHAR2 default 'N',
             X_RETURN_STATUS        OUT  NOCOPY   VARCHAR2,
             X_MSG_COUNT            OUT  NOCOPY   NUMBER,
             X_MSG_DATA             OUT  NOCOPY   VARCHAR2)
    IS
      l_module_name VARCHAR2(100) := 'pa.plsql.pa_fp_copy_actuals_pub.collect_actuals';
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(2000);
      l_data                   VARCHAR2(2000);
      l_msg_index_out          NUMBER:=0;

      l_fp_cols_rec            PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

      l_actuals_through_date   DATE;
      l_resource_assgn_id_tab  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_txn_currency_code_tab  pa_plsql_datatypes.Char30TabTyp;
      l_del_resource_assgn_id_tab  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_project_id_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
      l_resource_list_id_tab   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
      l_struct_ver_id_tab      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
      l_calendar_type_tab      SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_end_date_pji_tab       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_calendar_type          VARCHAR2(15);
      l_record_type            VARCHAR2(15);
      l_uncategorized_flag     VARCHAR2(1);
      i                        NUMBER;
      l_count                  NUMBER := 1;
      l_found                  BOOLEAN := FALSE;
      l_count_no_rlm           NUMBER;
      l_txn_currency_flag      VARCHAR2(1) := 'Y';
      l_org_id                 NUMBER;
      l_rate_based_flag                   VARCHAR2(1);
      l_budget_line_exists     varchar2(1) := 'N';
      l_record_version_number  pa_budget_versions.record_version_number%type;
      l_wp_version_flag        pa_budget_versions.wp_version_flag%type;
      l_rlm_id                 pa_resource_list_members.resource_list_member_id%TYPE;

      l_last_updated_by        NUMBER := FND_GLOBAL.user_id;
      l_last_update_login      NUMBER := FND_GLOBAL.login_id;
      l_sysdate                DATE   := SYSDATE;

      l_period_name_tab        pa_plsql_datatypes.Char30TabTyp;
      l_quantity_tab           pa_plsql_datatypes.NumTabTyp;
      l_txn_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
      l_txn_brdn_cost_tab      pa_plsql_datatypes.NumTabTyp;
      l_txn_revenue_tab        pa_plsql_datatypes.NumTabTyp;
      l_proj_raw_cost_tab      pa_plsql_datatypes.NumTabTyp;
      l_proj_brdn_cost_tab     pa_plsql_datatypes.NumTabTyp;
      l_proj_revenue_tab       pa_plsql_datatypes.NumTabTyp;
      l_pou_raw_cost_tab       pa_plsql_datatypes.NumTabTyp;
      l_pou_brdn_cost_tab      pa_plsql_datatypes.NumTabTyp;
      l_pou_revenue_tab        pa_plsql_datatypes.NumTabTyp;
      l_start_date_tab         pa_plsql_datatypes.DateTabTyp;
      l_end_date_tab           pa_plsql_datatypes.DateTabTyp;

      l_amt_dtls_tbl           pa_fp_maintain_actual_pub.l_amt_dtls_tbl_typ;

      -- Cursor to get 'Copy ETC from Plan' flag
      CURSOR get_copy_etc_from_plan_csr
      IS
        SELECT COPY_ETC_FROM_PLAN_FLAG
        FROM PA_PROJ_FP_OPTIONS
        WHERE FIN_PLAN_VERSION_ID = P_BUDGET_VERSION_ID;
      l_copy_etc_from_plan_flag PA_PROJ_FP_OPTIONS.COPY_ETC_FROM_PLAN_FLAG%TYPE;

      -- Cursor to get resource assignment ids for a budget version
    CURSOR get_resource_assgn_ids_csr IS
      SELECT RESOURCE_ASSIGNMENT_ID
      FROM PA_RESOURCE_ASSIGNMENTS
      WHERE BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;
    get_resource_assgn_ids_rec get_resource_assgn_ids_csr%rowtype;

    -- Cursor to get budget line information for a resource assignment id
    cursor get_period_info_csr
      (p_resource_assignment_id pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%type)
      is
      select tmp.source_id
            ,tmp.txn_currency_code
            ,tmp.period_name
      FROM pji_fm_xbs_accum_tmp1 tmp
      WHERE tmp.source_id = p_resource_assignment_id;
      get_period_info_rec get_period_info_csr%rowtype;

      -- Get distinct resource assignment id and txn currency code from temp table
      CURSOR distinct_ra_curr_cursor (c_multi_currency_flag VARCHAR2,
                                      c_proj_currency_code VARCHAR2,
                                      c_projfunc_currency_code VARCHAR2) IS
      SELECT distinct pji_tmp.source_id,
             DECODE(c_multi_currency_flag,
                    'Y', pji_tmp.txn_currency_code,
                    'N', c_proj_currency_code,
                    'A', c_projfunc_currency_code)
      FROM pji_fm_xbs_accum_tmp1 pji_tmp
      WHERE pji_tmp.source_id is NOT NULL --bug#8485646
      order by 1,2;

      -- Cursor to check whether budget line already exists for the period
      cursor budget_line_info_csr
                  (p_resource_assignment_id pa_budget_lines.resource_assignment_id%type,
                   p_period_name pa_budget_lines.period_name%type,
                   p_txn_currency_code pa_budget_lines.txn_currency_code%type)
      is
      SELECT bl.budget_line_id
            ,bl.resource_assignment_id
            ,bl.txn_currency_code
            ,bl.start_date
            ,bl.end_date
            ,bl.period_name
            ,bl.quantity
            ,bl.txn_raw_cost
            ,bl.txn_burdened_cost
            ,bl.txn_revenue
            ,bl.project_raw_cost
            ,bl.project_burdened_cost
            ,bl.project_revenue
            ,bl.raw_cost  projfunc_raw_cost
            ,bl.burdened_cost projfunc_burdened_cost
            ,bl.revenue   projfunc_revenue
            ,bl.project_currency_code
            ,bl.projfunc_currency_code
            ,bl.cost_rejection_code
            ,bl.revenue_rejection_code
            ,bl.burden_rejection_code
            ,bl.pfc_cur_conv_rejection_code
            ,bl.pc_cur_conv_rejection_code
      FROM pa_budget_lines bl
      WHERE bl.resource_assignment_id = p_resource_assignment_id
      AND  bl.period_name = NVL(p_period_name,bl.period_name)
      AND  bl.txn_currency_code = p_txn_currency_code;

      budget_line_rec budget_line_info_csr%rowtype;

      -- Cursor to get budget line information if calender type is 'PA Period'
      CURSOR budget_line_cursor_pa(c_multi_currency_flag VARCHAR2,
                                c_res_asg_id NUMBER,
                                c_txn_currency_code VARCHAR2,
                                c_org_id  NUMBER,
                                c_version_type VARCHAR2) IS
      SELECT pji_tmp.period_name,
             pd.start_date,
             pd.end_date,
             sum(pji_tmp.quantity),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.txn_raw_cost,
                        'N', pji_tmp.prj_raw_cost,
                        'A', pji_tmp.pou_raw_cost)),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.txn_brdn_cost,
                        'N', pji_tmp.prj_brdn_cost,
                        'A', pji_tmp.pou_brdn_cost)),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.txn_revenue,
                        'N', pji_tmp.prj_revenue,
                        'A', pji_tmp.pou_revenue)),
             sum(pji_tmp.prj_raw_cost),
             sum(pji_tmp.prj_brdn_cost),
             sum(pji_tmp.prj_revenue),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.pou_raw_cost,
                        'N', pji_tmp.prj_raw_cost,
                        'A', pji_tmp.pou_raw_cost)),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.pou_brdn_cost,
                        'N', pji_tmp.prj_brdn_cost,
                        'A', pji_tmp.pou_brdn_cost)),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.pou_revenue,
                        'N', pji_tmp.prj_revenue,
                        'A', pji_tmp.pou_revenue))
      FROM   pji_fm_xbs_accum_tmp1 pji_tmp,pa_periods_all pd
      WHERE  c_version_type = 'ALL'
             AND (   (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                     (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                     (NVL(pji_tmp.txn_revenue, 0)   <> 0) OR
                     (NVL(pji_tmp.quantity,0)       <> 0)
                 )
             AND pd.org_id = c_org_id
             AND pd.period_name = pji_tmp.period_name
             AND pji_tmp.source_id = c_res_asg_id
             AND DECODE(c_multi_currency_flag,'Y',
                 pji_tmp.txn_currency_code,c_txn_currency_code)
                 = c_txn_currency_code
      GROUP BY pji_tmp.period_name,
               pd.start_date,
               pd.end_date
      UNION ALL
      SELECT pji_tmp.period_name,
             pd.start_date,
             pd.end_date,
             sum(pji_tmp.quantity),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.txn_raw_cost,
                        'N', pji_tmp.prj_raw_cost,
                        'A', pji_tmp.pou_raw_cost)),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.txn_brdn_cost,
                        'N', pji_tmp.prj_brdn_cost,
                        'A', pji_tmp.pou_brdn_cost)),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.txn_revenue,
                        'N', pji_tmp.prj_revenue,
                        'A', pji_tmp.pou_revenue)),
             sum(pji_tmp.prj_raw_cost),
             sum(pji_tmp.prj_brdn_cost),
             sum(pji_tmp.prj_revenue),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.pou_raw_cost,
                        'N', pji_tmp.prj_raw_cost,
                        'A', pji_tmp.pou_raw_cost)),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.pou_brdn_cost,
                        'N', pji_tmp.prj_brdn_cost,
                        'A', pji_tmp.pou_brdn_cost)),
             sum(DECODE(c_multi_currency_flag,
                        'Y', pji_tmp.pou_revenue,
                        'N', pji_tmp.prj_revenue,
                        'A', pji_tmp.pou_revenue))
      FROM   pji_fm_xbs_accum_tmp1 pji_tmp,pa_periods_all pd
      WHERE  c_version_type = 'COST'
             AND (   (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                     (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                     (NVL(pji_tmp.quantity,0)       <> 0)
                 )
             AND pd.org_id = c_org_id
             AND pd.period_name = pji_tmp.period_name
             AND pji_tmp.source_id = c_res_asg_id
             AND DECODE(c_multi_currency_flag,'Y',
                 pji_tmp.txn_currency_code,c_txn_currency_code)
                 = c_txn_currency_code
      GROUP BY pji_tmp.period_name,
               pd.start_date,
               pd.end_date;

      -- Cursor to get budget line information when the calender
      -- type is 'GL Period'
      CURSOR budget_line_cursor_gl(c_source_id NUMBER,
                                   c_multi_currency_flag VARCHAR2,
                                   c_set_of_books_id NUMBER,
                                   c_version_type VARCHAR2,
                                   c_proj_currency_code VARCHAR2,
                                   c_projfunc_currency_code VARCHAR2) IS
        select * from
        (SELECT pji_tmp.source_id,
                DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_currency_code,
                      'N', c_proj_currency_code,
                      'A', c_projfunc_currency_code) txn_currency_code,
               pji_tmp.period_name,
               gd.start_date,
               gd.end_date,
               sum(pji_tmp.quantity)quantity,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.txn_raw_cost,
                          'N', pji_tmp.prj_raw_cost,
                          'A', pji_tmp.pou_raw_cost)) txn_raw_cost,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.txn_brdn_cost,
                          'N', pji_tmp.prj_brdn_cost,
                          'A', pji_tmp.pou_brdn_cost)) txn_brdn_cost,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.txn_revenue,
                          'N', pji_tmp.prj_revenue,
                          'A', pji_tmp.pou_revenue)) txn_revenue,
               sum(pji_tmp.prj_raw_cost) prj_raw_cost,
               sum(pji_tmp.prj_brdn_cost)prj_brdn_cost,
               sum(pji_tmp.prj_revenue) prj_revenue,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.pou_raw_cost,
                          'N', pji_tmp.prj_raw_cost,
                          'A', pji_tmp.pou_raw_cost)) pou_raw_cost,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.pou_brdn_cost,
                          'N', pji_tmp.prj_brdn_cost,
                          'A', pji_tmp.pou_brdn_cost)) pou_brdn_cost,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.pou_revenue,
                          'N', pji_tmp.prj_revenue,
                          'A', pji_tmp.pou_revenue)) pou_revenue
        FROM   pji_fm_xbs_accum_tmp1 pji_tmp,gl_period_statuses gd
        WHERE  c_version_type = 'ALL'
               AND pji_tmp.source_id = c_source_id
               AND (   (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                       (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                       (NVL(pji_tmp.txn_revenue, 0)   <> 0) OR
                       (NVL(pji_tmp.quantity,0)       <> 0)
                   )
               AND gd.SET_OF_BOOKS_ID = c_set_of_books_id
               AND gd.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
               AND gd.ADJUSTMENT_PERIOD_FLAG = 'N'
               AND gd.period_name = pji_tmp.period_name
        GROUP BY pji_tmp.source_id,
                 DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_currency_code,
                      'N', c_proj_currency_code,
                      'A', c_projfunc_currency_code),
                 pji_tmp.period_name,
                 gd.start_date,
                 gd.end_date
        UNION ALL
        SELECT pji_tmp.source_id,
               DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_currency_code,
                      'N', c_proj_currency_code,
                      'A', c_projfunc_currency_code) txn_currency_code,
               pji_tmp.period_name,
               gd.start_date,
               gd.end_date,
               sum(pji_tmp.quantity) quantity,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.txn_raw_cost,
                          'N', pji_tmp.prj_raw_cost,
                          'A', pji_tmp.pou_raw_cost)) txn_raw_cost,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.txn_brdn_cost,
                          'N', pji_tmp.prj_brdn_cost,
                          'A', pji_tmp.pou_brdn_cost)) txn_brdn_cost,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.txn_revenue,
                          'N', pji_tmp.prj_revenue,
                          'A', pji_tmp.pou_revenue)) txn_revenue,
               sum(pji_tmp.prj_raw_cost) prj_raw_cost,
               sum(pji_tmp.prj_brdn_cost)prj_brdn_cost,
               sum(pji_tmp.prj_revenue) prj_revenue,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.pou_raw_cost,
                          'N', pji_tmp.prj_raw_cost,
                          'A', pji_tmp.pou_raw_cost)) pou_raw_cost,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.pou_brdn_cost,
                          'N', pji_tmp.prj_brdn_cost,
                          'A', pji_tmp.pou_brdn_cost)) pou_brdn_cost,
               sum(DECODE(c_multi_currency_flag,
                          'Y', pji_tmp.pou_revenue,
                          'N', pji_tmp.prj_revenue,
                          'A', pji_tmp.pou_revenue)) pou_revenue
        FROM   pji_fm_xbs_accum_tmp1 pji_tmp,gl_period_statuses gd
        WHERE  c_version_type = 'COST'
               AND pji_tmp.source_id = c_source_id
               AND (
                     (NVL(pji_tmp.txn_raw_cost, 0)  <> 0) OR
                     (NVL(pji_tmp.txn_brdn_cost, 0) <> 0) OR
                     (NVL(pji_tmp.quantity,0)       <> 0)
                   )
               AND gd.SET_OF_BOOKS_ID = c_set_of_books_id
               AND gd.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
               AND gd.ADJUSTMENT_PERIOD_FLAG = 'N'
               AND gd.period_name = pji_tmp.period_name
        GROUP BY pji_tmp.source_id,
                 DECODE(c_multi_currency_flag,
                      'Y', pji_tmp.txn_currency_code,
                      'N', c_proj_currency_code,
                      'A', c_projfunc_currency_code),
                 pji_tmp.period_name,
                 gd.start_date,
                 gd.end_date)
      order by source_id, txn_currency_code;

      l_budget_line_gl_rec       budget_line_cursor_gl%rowtype;

      -- Cursor to get GL period start date and end date
      cursor gl_period_start_end_dates_csr(
                         p_period_name gl_period_statuses.period_name%type,
                         p_set_of_books_id gl_period_statuses.set_of_books_id%type)
      is
        select start_date, end_date
        from gl_period_statuses
        where period_name = p_period_name
        and set_of_books_id = p_set_of_books_id;

      -- Cursor to get PA period start date and end date
      cursor pa_period_start_end_dates_csr(
                         p_period_name pa_periods_all.period_name%type,
                         p_ord_id pa_periods_all.org_id%type)
      is
        select start_date, end_date
        from pa_periods_all
        where period_name = p_period_name
        and org_id = p_ord_id;

      l_start_date   DATE;
      l_end_date     DATE;
    BEGIN
      /* Initialization */
      FND_MSG_PUB.initialize;
      X_MSG_COUNT := 0;
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'COLLECT_ACTUALS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
      END IF;

      /* Begining of acquiring lock */
      -- acquire version lock
      select record_version_number
             into l_record_version_number
      from pa_budget_versions
      where budget_version_id = p_budget_version_id;
      IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling pa_fin_plan_pvt.lock_unlock_version',
                p_module_name => l_module_name);
      END IF;
      pa_fin_plan_pvt.lock_unlock_version(
                p_budget_version_id       => p_budget_version_id,
                p_record_version_number => l_record_version_number,
                p_action                => 'L',
                p_user_id               => FND_GLOBAL.USER_ID,
                p_person_id             => NULL,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);
      IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Status after calling pa_fin_plan_pvt.lock_unlock_version:'
                                ||x_return_status,
                p_module_name => l_module_name);
      END IF;
      if x_return_status <> fnd_api.g_ret_sts_success then
          IF p_pa_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
        END IF;
           RETURN;
      END IF;

      /* we need to commit the changes so that the locked by person info
         will be available for other sessions. */
      COMMIT;

      --acquire lock for collect_actual
      -- using copy_actuals api to acquire lock for collect_acutuals
      -- as the underlying table are same in both cases.
      IF p_pa_debug_mode = 'Y' THEN
          PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
              P_MSG               => 'Before calling PA_FP_COPY_FROM_PKG.'
                                      ||'ACQUIRE_LOCKS_FOR_COPY_ACTUAL',
              P_MODULE_NAME       => l_module_name);
      END IF;

      PA_FP_COPY_FROM_PKG.ACQUIRE_LOCKS_FOR_COPY_ACTUAL
                          (P_PLAN_VERSION_ID   => P_BUDGET_VERSION_ID,
                   X_RETURN_STATUS     => X_RETURN_STATUS,
                   X_MSG_COUNT         => X_MSG_COUNT,
                   X_MSG_DATA          => X_MSG_DATA);
      IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          --If can't acquire lock, customized message is thrown from within
          -- the API, so we should suppress exception error
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
      END IF;

      IF p_pa_debug_mode = 'Y' THEN
               PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
              P_MSG               => 'After calling PA_FP_COPY_FROM_PKG.'
                                     ||'ACQUIRE_LOCKS_FOR_COPY_ACTUAL: '
                                                             ||x_return_status,
              P_MODULE_NAME       => l_module_name);
      END IF;

      --delete temp table used for reporting purpose
      delete from PJI_FM_EXTR_PLAN_LINES;
      /* End of acquiring lock */

      /* Validation - Begin */
      -- Validate Input parameters
      if P_PROJECT_ID is null or p_budget_version_id is null then
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      end if;
      /* Validation - End */

     /* Calling utility api to get plan version details - Begin */
      if p_pa_debug_mode = 'Y' then
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
              pa_fp_gen_amount_utils.get_plan_version_dtls(p_budget_version_id)',
              p_module_name => l_module_name,
              p_log_level   => 5);
      end if;
      pa_fp_gen_amount_utils.get_plan_version_dtls
                        (p_budget_version_id       => p_budget_version_id,
                         x_fp_cols_rec             => l_fp_cols_rec,
                         x_return_status           => x_return_status,
                         x_msg_count               => x_msg_count,
                         x_msg_data                => x_msg_data);
      if x_return_status <> fnd_api.g_ret_sts_success then
          raise pa_fp_constants_pkg.invalid_arg_exc;
      end if;
      if p_pa_debug_mode = 'Y' then
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_amount_utils.get_plan_version_dtls(p_budget_version_id): '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
      end if;
      /* Calling utility api to get plan version details - End */

      /*---------------------------------------------------------------
        Populate actual amounts in PJI_FM_XBS_ACCUM_TMP1 table - Begin
        ---------------------------------------------------------------*/
      -- get actual thru date
      l_actuals_through_date :=  to_date(PA_FP_GEN_FCST_PG_PKG.GET_ACTUALS_THRU_PERIOD_DTLS(p_budget_version_id, 'END_DATE'),'rrrrmmdd');
      l_calendar_type := l_fp_cols_rec.X_TIME_PHASED_CODE;

      IF l_fp_cols_rec.x_plan_in_multi_curr_flag = 'N' THEN
        l_txn_currency_flag := 'N';
      END IF;

      l_project_id_tab.extend;
      l_resource_list_id_tab.extend;
      l_struct_ver_id_tab.extend;
      l_calendar_type_tab.extend;
      l_end_date_pji_tab.extend;

      l_project_id_tab(1) := p_project_id;
      l_resource_list_id_tab(1) := l_fp_cols_rec.X_RESOURCE_LIST_ID;
      l_calendar_type_tab(1) := l_calendar_type;
      l_end_date_pji_tab(1) := l_actuals_through_date;

      --Structure version id should be the structure version id of the
      --current published version for B/F.
      select wp_version_flag
      into   l_wp_version_flag
      from   pa_budget_versions
      where  budget_version_id=p_budget_version_id;

      if l_wp_version_flag = 'Y' then
         l_struct_ver_id_tab(1) := l_fp_cols_rec.x_project_structure_version_id;
      else
         l_struct_ver_id_tab(1) := pa_project_structure_utils.get_fin_struc_ver_id(p_project_id => p_project_id );
      end if;

      /**l_record_type: XXXX
        *1st X: 'Y',data will be returned in periods;
        *       'N',ITD amounts will be returned;
        *2nd X: 'Y',data will be returned by planning resources at
        *        entered level(periodic/total);
        *3rd X:  'Y',data is returned by tasks;
        *        'N',data is returned by project level;
        *4th X:  'N',amt will be gotten at entered level, no rollup is done.**/
      IF (l_calendar_type = 'G' OR l_calendar_type = 'P') THEN
          l_record_type := 'Y';
      ELSE
          l_record_type := 'N';
      END IF;
      l_record_type := l_record_type||'Y';
      IF l_fp_cols_rec.X_FIN_PLAN_LEVEL_CODE IN ('L', 'T') THEN
          l_record_type := l_record_type||'Y';
      ELSE
          l_record_type := l_record_type||'N';
      END IF;
      l_record_type := l_record_type||'N';

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
              (p_msg         =>  'Before calling pji_fm_xbs_accum_tmp1',
               p_module_name => l_module_name,
               p_log_level   => 5);
      END IF;

      PJI_FM_XBS_ACCUM_UTILS.get_summarized_data(
          p_project_ids           => l_project_id_tab,
          p_resource_list_ids     => l_resource_list_id_tab,
          p_struct_ver_ids        => l_struct_ver_id_tab,
          p_end_date              => l_end_date_pji_tab,
          p_calendar_type         => l_calendar_type_tab,
          p_record_type           => l_record_type,
          p_currency_type         => 6,
          x_return_status         => x_return_status,
          x_msg_code              => x_msg_data);

      select count(*) into l_count from pji_fm_xbs_accum_tmp1;

      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'After calling pji_fm_xbs_accum_tmp1,return status is: '||x_return_status,
               p_module_name => l_module_name,
               p_log_level   => 5);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF l_count = 0 THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'no actual data ',
               p_module_name => l_module_name,
               p_log_level   => 5);
                  PA_DEBUG.RESET_CURR_FUNCTION;
         END IF;
         RETURN;
      END IF;

      select count(*) into l_count_no_rlm from pji_fm_xbs_accum_tmp1 WHERE
      res_list_member_id IS NULL;

      IF l_count_no_rlm > 0 THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name     => 'PA_FP_NO_RLM_ID_FOR_ACTUAL');
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      /* Update rlm_id for all rows in pji_fm_xbs_accum_tmp1 if the resource list
       * (l_fp_cols_rec.X_RESOURCE_LIST_ID) is None - Uncategorized.
       * This logic is not handled by the PJI generic resource mapping API. */

      SELECT NVL(uncategorized_flag,'N')
        INTO l_uncategorized_flag
        FROM pa_resource_lists_all_bg
       WHERE resource_list_id = l_fp_cols_rec.X_RESOURCE_LIST_ID;

      IF l_uncategorized_flag = 'Y' THEN
          l_rlm_id := PA_FP_GEN_AMOUNT_UTILS.GET_RLM_ID (
                         p_project_id          => p_project_id,
                         p_resource_list_id    => l_fp_cols_rec.X_RESOURCE_LIST_ID,
                         p_resource_class_code => 'FINANCIAL_ELEMENTS' );
          UPDATE pji_fm_xbs_accum_tmp1
             SET res_list_member_id = l_rlm_id;
      END IF;

      /* updating the project element id ( task id ) to NULL
         when the value is <= 0. */
      update pji_fm_xbs_accum_tmp1 set  project_element_id = null
          where NVL(project_element_id,0) <= 0;

      /* updating the resource assignment id in pji_fm_xbs_accum_tmp1 */
      UPDATE PJI_FM_XBS_ACCUM_TMP1 tmp1
      SET source_id =
          (SELECT resource_assignment_id
           FROM pa_resource_assignments ra
           WHERE nvl(ra.task_id,0) = nvl(tmp1.project_element_id,0)
                 AND ra.resource_list_member_id = tmp1.res_list_member_id
                 AND ra.budget_version_id = p_budget_version_id);

      /*---------------------------------------------------------------
        Populate actual amounts in PJI_FM_XBS_ACCUM_TMP1 table - End
      -----------------------------------------------------------------*/

      /*---------------------------------------------------------------
        Delete resource assignments which are not selected if resouce
        assignment id is passed to this api. Otherwise populate all the
        resource assignment ids present for the budget version in
        l_resource_assgn_id_tab pl/sql table. - Begin
      -----------------------------------------------------------------*/
      l_resource_assgn_id_tab := p_resource_assgn_ids;
      l_count := 1;
      if l_resource_assgn_id_tab is not null then
        for get_resource_assgn_ids_rec in get_resource_assgn_ids_csr loop
          l_found := false;
          for i in 1..l_resource_assgn_id_tab.count loop
            if ( get_resource_assgn_ids_rec.resource_assignment_id = l_resource_assgn_id_tab(i) ) then
              l_found := true;
              exit;
            end if;
            end loop;
            if not l_found then
              l_del_resource_assgn_id_tab.extend;
              l_del_resource_assgn_id_tab(l_count) := get_resource_assgn_ids_rec.resource_assignment_id;
              l_count := l_count + 1;
            end if;
        end loop;

        forall i in 1..l_del_resource_assgn_id_tab.count
          delete from pji_fm_xbs_accum_tmp1
            where source_id  = l_del_resource_assgn_id_tab(i);
      end if;
      -- populate the resource assignment id along with currency code
      -- that needs to be processed
      OPEN distinct_ra_curr_cursor(l_txn_currency_flag,
                                   l_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
                                   l_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE);
      FETCH distinct_ra_curr_cursor
      BULK COLLECT
      INTO l_resource_assgn_id_tab,
           l_txn_currency_code_tab;
      CLOSE distinct_ra_curr_cursor;
      /*---------------------------------------------------------------
        Getting relevant resource assignment ids - End
      -----------------------------------------------------------------*/

      /*---------------------------------------------------------------
        Check whether budget lines are available in pa_budget_lines for
        all period for each resource assignment present in
        PJI_FM_XBS_ACCUM_TMP1 temp table. If budget line is not present,
        create budget line.
      -----------------------------------------------------------------*/
      if l_resource_assgn_id_tab.count > 0 then
        for i in 1..l_resource_assgn_id_tab.count loop
          for period_info_rec in get_period_info_csr(l_resource_assgn_id_tab(i))
            loop
            -- Check whether budget line exists in PJI_FM_XBS_ACCUM_TMP1
            -- table for that period
            open budget_line_info_csr(l_resource_assgn_id_tab(i),
                                      period_info_rec.period_name,
                                      l_txn_currency_code_tab(i));
            fetch budget_line_info_csr into budget_line_rec;
            if budget_line_info_csr%found then
              l_budget_line_exists := 'Y';
            else
              l_budget_line_exists := 'N';
            end if;
            close budget_line_info_csr;
            -- if budget line doesn't exist, create a budget line
            if (l_budget_line_exists = 'N') then
              if(l_calendar_type = 'G') then
                open gl_period_start_end_dates_csr(period_info_rec.period_name,
                                                   l_fp_cols_rec.x_set_of_books_id);
                fetch gl_period_start_end_dates_csr into l_start_date, l_end_date;
                close gl_period_start_end_dates_csr;
              elsif (l_calendar_type = 'P') then
                open pa_period_start_end_dates_csr(period_info_rec.period_name,
                                                   l_fp_cols_rec.x_set_of_books_id);
                fetch pa_period_start_end_dates_csr into l_start_date, l_end_date;
                close pa_period_start_end_dates_csr;
              end if;
              INSERT INTO PA_BUDGET_LINES(BUDGET_VERSION_ID,
                              RESOURCE_ASSIGNMENT_ID,
                              START_DATE,
                              END_DATE,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN,
                              PERIOD_NAME,
                              BUDGET_LINE_ID,
                              TXN_CURRENCY_CODE,
                              RAW_COST_SOURCE,
                              BURDENED_COST_SOURCE,
                              QUANTITY_SOURCE,
                              REQUEST_ID,
                              PROJFUNC_CURRENCY_CODE,
                              PROJECT_CURRENCY_CODE
                              )
                          VALUES(p_budget_version_id,
                              l_resource_assgn_id_tab(i),
                              l_start_date,
                              l_end_date,
                              l_sysdate,
                              l_last_updated_by,
                              l_sysdate,
                              l_last_updated_by,
                              l_last_update_login,
                              period_info_rec.period_name,
                              PA_BUDGET_LINES_S.nextval,
                              period_info_rec.txn_currency_code,
                              PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,
                              PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,
                              PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_COPY_P,
                              fnd_global.conc_request_id,
                              l_fp_cols_rec.x_projfunc_currency_code,
                              l_fp_cols_rec.x_project_currency_code);
              end if;
            end loop;
          end loop;
        -- if no resource assignment to be processed, simply return
        else
          return;
        end if;

        /*-------------------------------------------------------------------
          Populate l_amt_dtls_tbl and call PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA
          API to update the budget lines with correct ETC, EAC values - Begin
        ---------------------------------------------------------------------*/
        FOR i IN 1..l_resource_assgn_id_tab.count LOOP
          IF l_calendar_type = 'P' THEN
            OPEN budget_line_cursor_pa(
                l_txn_currency_flag,
                l_resource_assgn_id_tab(i),
                l_txn_currency_code_tab(i),
                l_org_id,
                l_FP_COLS_REC.X_VERSION_TYPE);
            FETCH budget_line_cursor_pa
            BULK COLLECT
            INTO l_period_name_tab,
                 l_start_date_tab,
                 l_end_date_tab,
                 l_quantity_tab,
                 l_txn_raw_cost_tab,
                 l_txn_brdn_cost_tab,
                 l_txn_revenue_tab,
                 l_proj_raw_cost_tab,
                 l_proj_brdn_cost_tab,
                 l_proj_revenue_tab,
                 l_pou_raw_cost_tab,
                 l_pou_brdn_cost_tab,
                 l_pou_revenue_tab;
            CLOSE budget_line_cursor_pa;
          ELSIF l_calendar_type = 'G' THEN
                   l_count :=1;
            l_period_name_tab.delete;
            l_start_date_tab.delete;
            l_end_date_tab.delete;
            l_quantity_tab.delete;
            l_txn_raw_cost_tab.delete;
            l_txn_brdn_cost_tab.delete;
            l_txn_revenue_tab.delete;
            l_proj_raw_cost_tab.delete;
            l_proj_brdn_cost_tab.delete;
            l_proj_revenue_tab.delete;
            l_pou_raw_cost_tab.delete;
            l_pou_brdn_cost_tab.delete;
            l_pou_revenue_tab.delete;

            OPEN budget_line_cursor_gl(
                  l_resource_assgn_id_tab(i),
                  l_txn_currency_flag,
                  l_fp_cols_rec.x_set_of_books_id,
                  l_fp_cols_rec.x_version_type,
                  l_fp_cols_rec.x_project_currency_code,
                  l_fp_cols_rec.x_projfunc_currency_code);
                   FETCH budget_line_cursor_gl into        l_budget_line_gl_rec;
            Loop
              exit when budget_line_cursor_gl%notfound;
                          exit when l_budget_line_gl_rec.period_name is NULL;
              if l_budget_line_gl_rec.source_id is not null and
                 l_budget_line_gl_rec.source_id = l_resource_assgn_id_tab(i) and
                (l_txn_currency_flag <> 'Y'
                 or l_budget_line_gl_rec.txn_currency_code = l_txn_currency_code_tab(i))
              then
                l_period_name_tab(l_count) := l_budget_line_gl_rec.period_name;
                l_start_date_tab(l_count) := l_budget_line_gl_rec.start_date;
                l_end_date_tab(l_count) := l_budget_line_gl_rec.end_date;
                l_quantity_tab(l_count) := l_budget_line_gl_rec.quantity;
                l_txn_raw_cost_tab(l_count) := l_budget_line_gl_rec.txn_raw_cost;
                l_txn_brdn_cost_tab(l_count) := l_budget_line_gl_rec.txn_brdn_cost;
                l_txn_revenue_tab(l_count) := l_budget_line_gl_rec.txn_revenue;
                l_proj_raw_cost_tab(l_count) := l_budget_line_gl_rec.prj_raw_cost;
                l_proj_brdn_cost_tab(l_count) := l_budget_line_gl_rec.prj_brdn_cost;
                l_proj_revenue_tab(l_count) := l_budget_line_gl_rec.prj_revenue;
                l_pou_raw_cost_tab(l_count) := l_budget_line_gl_rec.pou_raw_cost;
                l_pou_brdn_cost_tab(l_count) := l_budget_line_gl_rec.pou_brdn_cost;
                l_pou_revenue_tab(l_count) := l_budget_line_gl_rec.pou_revenue;
                l_count := l_count+1;
                FETCH budget_line_cursor_gl into        l_budget_line_gl_rec;
              end if;
            end loop;
            close budget_line_cursor_gl;

          END IF;

          SELECT rate_based_flag into l_rate_based_flag
          FROM pa_resource_assignments
          WHERE resource_assignment_id = l_resource_assgn_id_tab(i);
          IF l_rate_based_flag = 'N' THEN
              IF l_FP_COLS_REC.x_version_type = 'REVENUE' THEN
                  l_quantity_tab := l_txn_revenue_tab;
              ELSE
                  l_quantity_tab := l_txn_raw_cost_tab;
              END IF;
          END IF;


          l_amt_dtls_tbl.delete;
          FOR j IN 1..l_period_name_tab.count LOOP
            l_amt_dtls_tbl(j).period_name := l_period_name_tab(j);
            l_amt_dtls_tbl(j).start_date := l_start_date_tab(j);
            l_amt_dtls_tbl(j).end_date := l_end_date_tab(j);
            l_amt_dtls_tbl(j).quantity := l_quantity_tab(j);
            l_amt_dtls_tbl(j).txn_raw_cost := l_txn_raw_cost_tab(j);
            l_amt_dtls_tbl(j).txn_burdened_cost := l_txn_brdn_cost_tab(j);
            l_amt_dtls_tbl(j).txn_revenue := l_txn_revenue_tab(j);
            l_amt_dtls_tbl(j).project_raw_cost := l_proj_raw_cost_tab(j);
            l_amt_dtls_tbl(j).project_burdened_cost := l_proj_brdn_cost_tab(j);
            l_amt_dtls_tbl(j).project_revenue := l_proj_revenue_tab(j);
            l_amt_dtls_tbl(j).project_func_raw_cost := l_pou_raw_cost_tab(j);
            l_amt_dtls_tbl(j).project_func_burdened_cost := l_pou_brdn_cost_tab(j);
            l_amt_dtls_tbl(j).project_func_revenue := l_pou_revenue_tab(j);
            /*For cost version, revenue amounts should be null
              For revenue version, cost amounts should be null */
            IF l_fp_cols_rec.x_version_type = 'COST' THEN
               l_amt_dtls_tbl(j).txn_revenue := null;
               l_amt_dtls_tbl(j).project_revenue := null;
               l_amt_dtls_tbl(j).project_func_revenue := null;
            ELSIF l_fp_cols_rec.x_version_type = 'REVENUE' THEN
               l_amt_dtls_tbl(j).txn_raw_cost := null;
               l_amt_dtls_tbl(j).txn_burdened_cost := null;
               l_amt_dtls_tbl(j).project_raw_cost := null;
               l_amt_dtls_tbl(j).project_burdened_cost := null;
               l_amt_dtls_tbl(j).project_func_raw_cost := null;
               l_amt_dtls_tbl(j).project_func_burdened_cost := null;
            END IF;
          END LOOP;

          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'Before calling  PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA',
               p_module_name => l_module_name,
               p_log_level   => 5);
          END IF;
          /**Populating target budget lines by summing up the values.
            *P_AMT_DTLS_REC_TAB has the amt data for each specific resource_assignment_id
            *3.and txn_currency_code**/
          PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA (
              P_PROJECT_ID                => P_PROJECT_ID,
              P_BUDGET_VERSION_ID         => P_BUDGET_VERSION_ID,
              P_RESOURCE_ASSIGNMENT_ID    => l_resource_assgn_id_tab(i),
              P_TXN_CURRENCY_CODE         => l_txn_currency_code_tab(i),
              P_AMT_DTLS_REC_TAB          => l_amt_dtls_tbl,
              P_CALLING_CONTEXT           => 'FP_GEN_FCST_COPY_ACTUAL',
              X_RETURN_STATUS             => x_return_Status,
              X_MSG_COUNT                 => x_msg_count,
              X_MSG_DATA                  => x_msg_data );
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'After calling  PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA,
                                  return status is: '||x_return_status,
               p_module_name => l_module_name,
               p_log_level   => 5);
          END IF;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
        END LOOP;
      /*---------------------------------------------------------------
        Populate l_amt_dtls_tbl - End
      -----------------------------------------------------------------*/

      /*---------------------------------------------------------------
        Rollup amounts - Begin
      -----------------------------------------------------------------*/
      --  ROLLUP PC and PFC numbers to pa_resource_assignments
      pa_fp_calc_plan_pkg.rollup_pf_pfc_to_ra
             ( p_budget_version_id          => p_budget_version_id
              ,p_calling_module             => 'COLLECT_ACTUALS'
              ,x_return_status              => x_return_status
              ,x_msg_count                  => x_msg_count
              ,x_msg_data                   => l_msg_data
             );

      IF p_pa_debug_mode = 'Y' THEN
          PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
              P_MSG                   => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.' ||
                                         'MAINTAIN_BUDGET_VERSION',
              P_MODULE_NAME           => l_module_name);
      END IF;
      PA_FP_GEN_FCST_AMT_PUB1.MAINTAIN_BUDGET_VERSION
                (P_PROJECT_ID              => P_PROJECT_ID,
                 P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
                 P_ETC_START_DATE          => l_ACTUALS_THROUGH_DATE + 1,
                 P_CALL_MAINTAIN_DATA_API  => 'Y',
                 X_RETURN_STATUS           => x_return_status,
                 X_MSG_COUNT               => x_msg_count,
                 X_MSG_DATA                => x_msg_data );

      IF p_pa_debug_mode = 'Y' THEN
          PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
              P_MSG                   => 'After calling PA_FP_GEN_FCST_AMT_PUB1.' ||
                                         'MAINTAIN_BUDGET_VERSION: '||x_return_status,
              P_MODULE_NAME           => l_module_name);
      END IF;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
      /*---------------------------------------------------------------
        Rollup amounts - End
      -----------------------------------------------------------------*/

      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.RESET_CURR_FUNCTION;
      END IF;
    EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count = 1 THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                  ( p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);
              x_msg_data := l_data;
              x_msg_count := l_msg_count;
          ELSE
              x_msg_count := l_msg_count;
          END IF;

          ROLLBACK;

          x_return_status := FND_API.G_RET_STS_ERROR;

          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'Invalid Arguments Passed',
               p_module_name => l_module_name,
               p_log_level   => 5);
              PA_DEBUG.RESET_CURR_FUNCTION;
          END IF;
          RAISE;
      WHEN OTHERS THEN
          rollback;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := substr(sqlerrm,1,240);
          FND_MSG_PUB.add_exc_msg
                     ( p_pkg_name        => 'PA_FP_COPY_ACTUALS_PUB',
                       p_procedure_name  => 'COLLECT_ACTUALS',
                       p_error_text      => substr(sqlerrm,1,240));

          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
               p_module_name => l_module_name,
               p_log_level   => 5);
              PA_DEBUG.RESET_CURR_FUNCTION;
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END COLLECT_ACTUALS;

END PA_FP_COPY_ACTUALS_PUB;

/
