--------------------------------------------------------
--  DDL for Package Body PA_FP_MAINTAIN_ACTUAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_MAINTAIN_ACTUAL_PUB" as
/* $Header: PAFPMAPB.pls 120.16 2007/04/13 16:17:29 rthumma noship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/**MAINTAIN_ACTUAL_AMT_WRP will get value from PA_PROG_ACT_BY_PERIOD_TEMP view*
  *Populate init columns in PA_BUDGET_LINES. *
  *Valid values for parameter P_CALLING_CONTEXT are:*
  *     WP_PROGRESS -- Work plan progress *
  *     WP_SUMMARIZED_ACTUAL -- Work plan summarized actual transactions *
  *     WP_APPLY_PROGRESS_TO_WORKING *
  *Valid values for parameter P_EXTRACTION_TYPE are:*
  *     FULL -- DEFAULT, indicates full update of existing period *
  *     INCREMENTAL -- indicates increment the passed value of existing period *
**/
PROCEDURE MAINTAIN_ACTUAL_AMT_WRP
     (P_PROJECT_ID_TAB         IN          SYSTEM.PA_NUM_TBL_TYPE,
      P_WP_STR_VERSION_ID_TAB  IN          SYSTEM.PA_NUM_TBL_TYPE,
      P_ACTUALS_THRU_DATE      IN          SYSTEM.PA_DATE_TBL_TYPE,
      P_CALLING_CONTEXT        IN          VARCHAR2,
      P_COMMIT_FLAG            IN          VARCHAR2,
      P_INIT_MSG_FLAG          IN          VARCHAR2,
      P_CALLING_MODE           IN          VARCHAR2,
      P_EXTRACTION_TYPE        IN          VARCHAR2,
      X_RETURN_STATUS          OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT              OUT NOCOPY  NUMBER,
      X_MSG_DATA               OUT NOCOPY  VARCHAR2)
IS
l_module_name               VARCHAR2(200) := 'pa.plsql.pa_fp_maintain_actual_pub.maintain_actual_amt_wrp';
l_count                     NUMBER;
l_msg_count                 NUMBER;
l_cnt                       NUMBER;
l_data                      VARCHAR2(2000);
l_msg_data                  VARCHAR2(2000);
l_msg_index_out             NUMBER;

/* hidden res asg id recs are for the task level numbers
   without resources. */
CURSOR distinct_ra_curr_cursor(c_project_id number,
         c_STRUCTURE_VERSION_ID number ) IS
    SELECT distinct vw.project_id,
                bv.budget_version_id,
                vw.STRUCTURE_VERSION_ID,
                vw.RESOURCE_ASSIGNMENT_ID,
                vw.TXN_CURRENCY_CODE
    FROM  PA_PROG_ACT_BY_PERIOD_TEMP vw,
      PA_BUDGET_VERSIONS bv,
      PA_RESOURCE_ASSIGNMENTS ra
    WHERE bv.project_structure_version_id = vw.structure_version_id
      AND nvl(bv.wp_version_flag,'N')  = 'Y' AND
      vw.RESOURCE_ASSIGNMENT_ID IS NOT NULL AND
      ra.resource_assignment_id = vw.resource_assignment_id AND
      ra.budget_version_id = bv.budget_version_id AND
      vw.project_id = c_project_id AND
      vw.structure_version_id = c_STRUCTURE_VERSION_ID
    UNION
    SELECT distinct vw.project_id,
                    bv.budget_version_id,
                    vw.STRUCTURE_VERSION_ID,
                    vw.HIDDEN_RES_ASSGN_ID,
                    vw.TXN_CURRENCY_CODE
    FROM  PA_PROG_ACT_BY_PERIOD_TEMP vw,
          PA_BUDGET_VERSIONS bv,
          PA_RESOURCE_ASSIGNMENTS ra
    WHERE bv.project_structure_version_id = vw.structure_version_id
          AND nvl(bv.wp_version_flag,'N')  = 'Y' AND
          vw.HIDDEN_RES_ASSGN_ID IS NOT NULL AND
          ra.resource_assignment_id = vw.HIDDEN_RES_ASSGN_ID AND
          ra.budget_version_id = bv.budget_version_id AND
          vw.project_id = c_project_id AND
          vw.structure_version_id = c_STRUCTURE_VERSION_ID;

/* Added start date and finish date in the SELECT stmt for bug 4408930 */

CURSOR budget_line_cursor(p_struct_ver_id NUMBER,
                          p_res_asg_id NUMBER,
                          p_txn_currency_code VARCHAR2) IS
    SELECT period_name,
        actual_effort,
        actual_cost,
        actual_cost_pc,
        actual_cost_fc,
        actual_rawcost,
        actual_rawcost_pc,
        actual_rawcost_fc,
        start_date,
        finish_date
    FROM  PA_PROG_ACT_BY_PERIOD_TEMP
    WHERE structure_version_id = p_struct_ver_id
       AND nvl(resource_assignment_id,HIDDEN_RES_ASSGN_ID) = p_res_asg_id
       AND txn_currency_code = p_txn_currency_code;

l_project_id_tab                    pa_plsql_datatypes.IdTabTyp;
l_struct_ver_id_tab                 pa_plsql_datatypes.IdTabTyp;
l_budget_ver_id_tab                 pa_plsql_datatypes.IdTabTyp;
l_res_asg_id_tab                    pa_plsql_datatypes.IdTabTyp;
l_txn_currency_code_tab             pa_plsql_datatypes.Char30TabTyp;

l_fp_cols_rec                       PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_time_phase                        VARCHAR2(10);
l_period_name_tab                   pa_plsql_datatypes.Char30TabTyp;
l_quantity_tab                      pa_plsql_datatypes.NumTabTyp;
l_txn_raw_cost_tab                  pa_plsql_datatypes.NumTabTyp;
--l_txn_brdn_cost_tab                       pa_plsql_datatypes.NumTabTyp;
--l_txn_revenue_tab                 pa_plsql_datatypes.NumTabTyp;
l_proj_raw_cost_tab                 pa_plsql_datatypes.NumTabTyp;
--l_proj_brdn_cost_tab              pa_plsql_datatypes.NumTabTyp;
--l_proj_revenue_tab                        pa_plsql_datatypes.NumTabTyp;
l_pou_raw_cost_tab                  pa_plsql_datatypes.NumTabTyp;
--l_pou_brdn_cost_tab                       pa_plsql_datatypes.NumTabTyp;
--l_pou_revenue_tab                 pa_plsql_datatypes.NumTabTyp;
l_start_date_tab                    pa_plsql_datatypes.DateTabTyp;
l_end_date_tab                      pa_plsql_datatypes.DateTabTyp;
l_start_date                        Date;
l_end_date                          Date;

l_amt_dtls_tbl                      pa_fp_maintain_actual_pub.l_amt_dtls_tbl_typ;

l_txn_bd_cost_tab                   pa_plsql_datatypes.NumTabTyp;
l_proj_bd_cost_tab                  pa_plsql_datatypes.NumTabTyp;
l_pou_bd_cost_tab                   pa_plsql_datatypes.NumTabTyp;

l_bv_id                             pa_budget_versions.budget_version_id%type;
l_bv_id_tab                         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_ra_id_upd_reprt_tab               pa_plsql_datatypes.IdTabTyp;

/* Additional parameters for MAINTAIN_ACTUAL_AMT_RA */
l_open_pd_plan_amt_flag             VARCHAR2(1);
-- End Date of P_ACTUALS_THRU_DATE period
l_open_pd_end_date                  DATE;

l_last_updated_by                 NUMBER := FND_GLOBAL.user_id;
l_last_update_login               NUMBER := FND_GLOBAL.login_id;
l_sysdate                         DATE   := SYSDATE;

-- IPM: Added table to store Distinct ra_ids for workplan resources
l_display_qty_ra_id_tab           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

BEGIN
    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.initialize;
    END IF;

    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
        PA_DEBUG.init_err_stack('PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_WRP');
    ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
        pa_debug.set_curr_function( p_function     => 'MAINTAIN_ACTUAL_AMT_WRP'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    IF p_project_id_tab.count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_called_mode => p_calling_mode,
                  p_msg         => 'Returning because P_PROJECT_ID_TAB has count = 0',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;

        RETURN;
    END IF;

    FOR ss1  IN 1 ..  P_PROJECT_ID_TAB.COUNT LOOP
        BEGIN
            SELECT budget_version_id into l_bv_id
            FROM PA_BUDGET_VERSIONS
            WHERE project_id = P_PROJECT_ID_tab(ss1)
              AND project_structure_version_id = P_WP_STR_VERSION_ID_TAB(ss1)
              AND nvl(wp_version_flag,'N')  = 'Y';
        EXCEPTION
            -- Bug 5336341: NO_DATA_FOUND can be encountered when there are
            -- orphaned workplan structures in the system. In this case, raise
            -- an informative error message.
            -- Orphaned workplan structures are those for which workplan
            -- publishing has failed. A workplan structure is created but a
            -- corresponding budget version does not exist in the system in such case.
            WHEN no_data_found THEN
                PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_ORPHANED_STRUCT_ERR',
                      p_token1         => 'PROJECT_NUMBER',
                      p_value1         => P_PROJECT_ID_tab(ss1) );
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END;

        --Bug 4091264
        l_bv_id_tab.extend;
        l_bv_id_tab(l_bv_id_tab.COUNT):=l_bv_id;

        -- In the following case, we need to Null out the budget line INIT columns:
        -- Calling context = 'WP_SUMMARIZED_ACTUAL'  and extraction_type = 'FULL'

        IF (P_EXTRACTION_TYPE = 'FULL' AND
            P_CALLING_CONTEXT = 'WP_SUMMARIZED_ACTUAL') THEN
            UPDATE pa_budget_lines
               SET TXN_INIT_RAW_COST          = decode(TXN_INIT_RAW_COST,null,null,0),
                   TXN_INIT_BURDENED_COST     = decode(TXN_INIT_BURDENED_COST,null,null,0),
                   ---TXN_INIT_REVENUE        = decode(TXN_INIT_REVENUE,null,null,0),
                   PROJECT_INIT_RAW_COST      = decode(PROJECT_INIT_RAW_COST,null,null,0),
                   PROJECT_INIT_BURDENED_COST = decode(PROJECT_INIT_BURDENED_COST,null,null,0),
                   ---PROJECT_INIT_REVENUE    = decode(PROJECT_INIT_REVENUE,null,null,0),
                   INIT_RAW_COST              = decode(INIT_RAW_COST,null,null,0),
                   INIT_BURDENED_COST         = decode(INIT_BURDENED_COST,null,null,0),
                   ---INIT_REVENUE            = decode(INIT_REVENUE,null,null,0),
                   INIT_QUANTITY              = decode(INIT_QUANTITY,null,null,0),
                   LAST_UPDATE_DATE           = l_sysdate,
                   LAST_UPDATED_BY            = l_last_updated_by,
                   LAST_UPDATE_LOGIN          = l_last_update_login
             WHERE budget_version_id = l_bv_id;
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Before calling
                                       pa_fp_gen_amount_utils.get_plan_version_dtls',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
        END IF;
        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS(
            P_PROJECT_ID                 => p_project_id_tab(ss1),
            P_BUDGET_VERSION_ID          => l_bv_id,
            X_FP_COLS_REC                => l_fp_cols_rec,
            X_RETURN_STATUS              => x_return_status,
            X_MSG_COUNT                  => x_msg_count,
            X_MSG_DATA                   => x_msg_data);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Status after calling
                                       pa_fp_gen_amount_utils.get_plan_version_dtls'
                                      ||x_return_status,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
        END IF;

        l_time_phase := l_fp_cols_rec.x_time_phased_code;

        l_ra_id_upd_reprt_tab.DELETE;

        SELECT DISTINCT NVL(resource_assignment_id, hidden_res_assgn_id)
        BULK COLLECT
        INTO l_ra_id_upd_reprt_tab
        FROM  PA_PROG_ACT_BY_PERIOD_TEMP
        WHERE project_id = P_PROJECT_ID_TAB(ss1)
          AND structure_version_id = P_WP_STR_VERSION_ID_TAB(ss1)
          AND NVL(resource_assignment_id, hidden_res_assgn_id) IS NOT NULL;

        IF ( l_ra_id_upd_reprt_tab.count <> 0 )
        THEN

        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Before calling PA_FP_MAINTAIN_ACTUAL_PUB.'
                                      ||'BLK_UPD_REPORTING_LINES_WRP',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
        END IF;
        /*============================================================================+
         | Bug 4141131: Calling PA_FP_MAINTAIN_ACTUAL_PUB.BLK_UPD_REPORTING_LINES_WRP |
         |              only if P_EXTRACTION_TYPE is 'INCREMENTAL'.                   |
         | Bug 4164532: Calling PA_FP_MAINTAIN_ACTUAL_PUB.BLK_UPD_REPORTING_LINES_WRP |
         |              only if NOT (P_CALLING_CONTEXT = 'WP_SUMMARIZED_ACTUAL'       |
         |                              AND P_EXTRACTION_TYPE = 'INCREMENTAL')        |
         +============================================================================*/
	IF NOT ( P_CALLING_CONTEXT = 'WP_SUMMARIZED_ACTUAL' AND P_EXTRACTION_TYPE = 'FULL' )
        THEN
            PA_FP_MAINTAIN_ACTUAL_PUB.BLK_UPD_REPORTING_LINES_WRP (
                P_BUDGET_VERSION_ID     => l_bv_id,
                P_ENTIRE_VERSION_FLAG   => 'N',
                P_RES_ASG_ID_TAB        => l_ra_id_upd_reprt_tab,
                P_ACTIVITY_CODE         => 'DELETE',
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data);
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_mode,
                         p_msg         => 'Status after calling PA_FP_MAINTAIN_ACTUAL_PUB.'
                                          ||'BLK_UPD_REPORTING_LINES_WRP:'||x_return_status,
                         p_module_name => l_module_name,
                         p_log_level   => 5);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
	END IF; --P_CALLING_CONTEXT = 'WP_SUMMARIZED_ACTUAL' AND P_EXTRACTION_TYPE = 'INCREMENTAL'


        OPEN distinct_ra_curr_cursor(P_PROJECT_ID_TAB(ss1),
                                     P_WP_STR_VERSION_ID_TAB(ss1));
        FETCH distinct_ra_curr_cursor BULK COLLECT
        INTO l_project_id_tab,
             l_budget_ver_id_tab,
             l_struct_ver_id_tab,
             l_res_asg_id_tab,
             l_txn_currency_code_tab;
        CLOSE distinct_ra_curr_cursor;

        /* Initialize open period variables */
        l_open_pd_plan_amt_flag := 'N';
        l_open_pd_end_date := NULL;

        IF l_struct_ver_id_tab.count > 0 THEN
            IF (l_time_phase = 'P') THEN
                SELECT pd.end_date INTO l_open_pd_end_date
                FROM   pa_periods_all pd
                WHERE  pd.org_id = l_fp_cols_rec.x_org_id -- R12 MOAC 4447573: NVL(pd.org_id,-99)
                AND    p_actuals_thru_date(ss1) BETWEEN pd.start_date AND pd.end_date;
            ELSIF ( l_time_phase = 'G') THEN
                SELECT gl.end_date INTO l_open_pd_end_date
                FROM   gl_period_statuses gl,
                       pa_implementations_all imp
                WHERE  gl.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
                AND    gl.set_of_books_id   = imp.set_of_books_id
                AND    gl.adjustment_period_flag = 'N'
                AND    imp.org_id = l_fp_cols_rec.x_org_id -- R12 MOAC 4447573: NVL(imp.org_id,-99)
                AND    p_actuals_thru_date(ss1) BETWEEN gl.start_date AND gl.end_date;
            END IF;

            IF p_actuals_thru_date(ss1) < l_open_pd_end_date THEN
                l_open_pd_plan_amt_flag := 'Y';
            END IF;
        END IF;

        FOR i IN 1..l_struct_ver_id_tab.count LOOP
            OPEN budget_line_cursor(l_struct_ver_id_tab(i),
                                    l_res_asg_id_tab(i),
                                    l_txn_currency_code_tab(i));
            l_period_name_tab.delete;
            l_quantity_tab.delete;
            l_txn_raw_cost_tab.delete;
            l_proj_raw_cost_tab.delete;
            l_pou_raw_cost_tab.delete;
            l_txn_bd_cost_tab.delete;
            l_proj_bd_cost_tab.delete;
            l_pou_bd_cost_tab.delete;
            l_start_date_tab.delete;
            l_end_date_tab.delete;

            FETCH budget_line_cursor
            BULK COLLECT
            INTO l_period_name_tab,
                 l_quantity_tab,
                 l_txn_bd_cost_tab,
                 l_proj_bd_cost_tab,
                 l_pou_bd_cost_tab,
                 l_txn_raw_cost_tab,
                 l_proj_raw_cost_tab,
                 l_pou_raw_cost_tab,
                 l_start_date_tab,
                 l_end_date_tab;
            CLOSE budget_line_cursor;

            l_amt_dtls_tbl.DELETE;

            IF l_period_name_tab.count > 0 THEN
                FOR j IN 1..l_period_name_tab.count LOOP
                      l_amt_dtls_tbl(j).period_name           := l_period_name_tab(j);
                      l_amt_dtls_tbl(j).txn_raw_cost          := l_txn_raw_cost_tab(j);
                      l_amt_dtls_tbl(j).project_raw_cost      := l_proj_raw_cost_tab(j);
                      l_amt_dtls_tbl(j).project_func_raw_cost := l_pou_raw_cost_tab(j);
                      l_amt_dtls_tbl(j).txn_burdened_cost     := l_txn_bd_cost_tab(j);
                      l_amt_dtls_tbl(j).project_burdened_cost := l_proj_bd_cost_tab(j);
                      l_amt_dtls_tbl(j).project_func_burdened_cost := l_pou_bd_cost_tab(j);
                      l_amt_dtls_tbl(j).txn_revenue           := null;
                      l_amt_dtls_tbl(j).project_revenue       := null;
                      l_amt_dtls_tbl(j).project_func_revenue  := null;
                      l_amt_dtls_tbl(j).quantity              := l_quantity_tab(j);

                  /* bug 4408930 */
                      l_amt_dtls_tbl(j).start_date            := l_start_date_tab(j);
                      l_amt_dtls_tbl(j).end_date              := l_end_date_tab(j);
                  /* bug 4408930 */

                END LOOP;

                IF (l_time_phase = 'P') THEN
                    FOR m IN 1..l_period_name_tab.count LOOP
                        SELECT pd.start_date ,pd.end_date into l_start_date, l_end_date
                        FROM  pa_periods_all pd
                        WHERE pd.org_id = l_fp_cols_rec.x_org_id -- R12 MOAC 4447573: nvl(pd.org_id,-99)
                          AND pd.period_name = l_period_name_tab(m);
                        l_amt_dtls_tbl(m).start_date := l_start_date;
                        l_amt_dtls_tbl(m).end_date := l_end_date;
                    END LOOP;
                ELSIF ( l_time_phase = 'G') THEN
                    FOR n IN l_period_name_tab.FIRST..l_period_name_tab.LAST LOOP
                        SELECT  gl.start_date, gl.end_date INTO l_start_date,l_end_date
                        FROM  gl_period_statuses gl,
                              pa_implementations_all imp
                        WHERE gl.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
                          AND gl.SET_OF_BOOKS_ID   = imp.SET_OF_BOOKS_ID
                          AND gl.ADJUSTMENT_PERIOD_FLAG = 'N'
                          AND imp.org_id = l_fp_cols_rec.x_org_id -- R12 MOAC 4447573: nvl(imp.org_id,-99)
                          AND gl.period_name = l_period_name_tab(n);
                        l_amt_dtls_tbl(n).start_date := l_start_date;
                        l_amt_dtls_tbl(n).end_date := l_end_date;
                    END LOOP;
                /* commented for bug 4408930
                ELSIF ( l_time_phase = 'N') THEN
                    FOR m IN 1..l_period_name_tab.count LOOP
                         res asg id should be a valid id.
                        SELECT NVL(planning_start_date,trunc(sysdate)),
                               NVL(planning_end_date,trunc(sysdate) ) INTO
                               l_start_date,l_end_date
                        FROM pa_resource_assignments
                        WHERE resource_assignment_id = l_res_asg_id_tab(i);
                        l_amt_dtls_tbl(m).start_date := l_start_date;
                        l_amt_dtls_tbl(m).end_date := l_end_date;
                    END LOOP;       */
                END IF; /* end if for l_time_phase */
            END IF;  /* end if for l_period_name_tab.count > 0 */

            IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Before calling
                                      pa_fp_maintain_actual_pub.maintain_actual_amt_ra',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
            PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA (
                P_PROJECT_ID                => l_project_id_tab(i),
                P_BUDGET_VERSION_ID         => l_budget_ver_id_tab(i),
                P_RESOURCE_ASSIGNMENT_ID    => l_res_asg_id_tab(i),
                P_TXN_CURRENCY_CODE         => l_txn_currency_code_tab(i),
                P_AMT_DTLS_REC_TAB          => l_amt_dtls_tbl,
                P_CALLING_CONTEXT           => p_calling_context,
                P_EXTRACTION_TYPE           => p_extraction_type,
                P_OPEN_PD_PLAN_AMT_FLAG     => l_open_pd_plan_amt_flag,
                P_OPEN_PD_END_DATE          => l_open_pd_end_date,
                X_RETURN_STATUS             => x_return_Status,
                X_MSG_COUNT                 => x_msg_count,
                X_MSG_DATA                  => x_msg_data );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Status after calling
                                         pa_fp_maintain_actual_pub.maintain_actual_amt_ra'
                                        ||x_return_status,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
        END LOOP; /* end loop for l_struct_ver_id_tab.count */


        -- IPM: New Entity and Display Quantity ERs --------------------

        DELETE pa_resource_asgn_curr_tmp;

        FORALL i IN 1..l_res_asg_id_tab.count
            INSERT INTO pa_resource_asgn_curr_tmp (
                resource_assignment_id,
                txn_currency_code )
            VALUES (
                l_res_asg_id_tab(i),
                l_txn_currency_code_tab(i) );

        -- Bug 5042399: Copy any existing override rates to the tmp table
        -- so that they will be carried over during the rollup.
        UPDATE pa_resource_asgn_curr_tmp tmp
        SET ( TXN_RAW_COST_RATE_OVERRIDE,
              TXN_BURDEN_COST_RATE_OVERRIDE,
              TXN_BILL_RATE_OVERRIDE ) =
        ( SELECT rbc.TXN_RAW_COST_RATE_OVERRIDE,
                 rbc.TXN_BURDEN_COST_RATE_OVERRIDE,
                 rbc.TXN_BILL_RATE_OVERRIDE
          FROM   pa_resource_asgn_curr rbc
          WHERE  rbc.resource_assignment_id = tmp.resource_assignment_id
          AND    rbc.txn_currency_code = tmp.txn_currency_code );

        -- Get distinct workplan ra_ids for later processing.
        SELECT DISTINCT
               resource_assignment_id
        BULK COLLECT
        INTO   l_display_qty_ra_id_tab
        FROM   pa_resource_asgn_curr_tmp;

        -- Populate the display quantity for processed workplan resources

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_BUDGET_LINES_UTILS.' ||
                                           'POPULATE_DISPLAY_QTY',
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_BUDGET_LINES_UTILS.POPULATE_DISPLAY_QTY
              ( P_BUDGET_VERSION_ID           => l_bv_id,
                P_CONTEXT                     => 'WORKPLAN',
                p_resource_assignment_id_tab  => l_display_qty_ra_id_tab,
                X_RETURN_STATUS         => x_return_status );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_BUDGET_LINES_UTILS.' ||
                                           'POPULATE_DISPLAY_QTY: '||x_return_status,
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- Call the maintenance api in ROLLUP mode
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'MAINTAIN_DATA',
                P_CALLED_MODE           => p_calling_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
              ( P_FP_COLS_REC           => l_fp_cols_rec,
                P_CALLING_MODULE        => 'WORKPLAN',
                P_ROLLUP_FLAG           => 'Y',
                P_VERSION_LEVEL_FLAG    => 'N',
                P_CALLED_MODE           => p_calling_mode,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'MAINTAIN_DATA: '||x_return_status,
                P_CALLED_MODE           => p_calling_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- END OF IPM: New Entity and Display Quantity ERs --------------------


        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Before calling PA_FP_MAINTAIN_ACTUAL_PUB.'
                                      ||'BLK_UPD_REPORTING_LINES_WRP',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
        END IF;
        /*============================================================================+
         | Bug 4141131: Calling PA_FP_MAINTAIN_ACTUAL_PUB.BLK_UPD_REPORTING_LINES_WRP |
         |              only if P_EXTRACTION_TYPE is 'INCREMENTAL'.                   |
         | Bug 4164532: Calling PA_FP_MAINTAIN_ACTUAL_PUB.BLK_UPD_REPORTING_LINES_WRP |
         |              only if NOT (P_CALLING_CONTEXT = 'WP_SUMMARIZED_ACTUAL'       |
         |                              AND P_EXTRACTION_TYPE = 'INCREMENTAL')        |
         +============================================================================*/
	IF NOT ( P_CALLING_CONTEXT = 'WP_SUMMARIZED_ACTUAL' AND P_EXTRACTION_TYPE = 'FULL' )
        THEN
            PA_FP_MAINTAIN_ACTUAL_PUB.BLK_UPD_REPORTING_LINES_WRP (
                P_BUDGET_VERSION_ID     => l_bv_id,
                P_ENTIRE_VERSION_FLAG   => 'N',
                P_RES_ASG_ID_TAB        => l_ra_id_upd_reprt_tab,
                P_ACTIVITY_CODE         => 'UPDATE',
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data);
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                        (p_called_mode => p_calling_mode,
                         p_msg         => 'Status after calling PA_FP_MAINTAIN_ACTUAL_PUB.'
                                          ||'BLK_UPD_REPORTING_LINES_WRP:'||x_return_status,
                         p_module_name => l_module_name,
                         p_log_level   => 5);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
	END IF; --P_CALLING_CONTEXT = 'WP_SUMMARIZED_ACTUAL' AND P_EXTRACTION_TYPE = 'INCREMENTAL'

        END IF; /*end check for l_ra_id_upd_reprt_tab.count <> 0 */

    END LOOP; /* end loop for p_project_id_tab.count */

    FORALL kk IN 1..P_ACTUALS_THRU_DATE.count
        UPDATE  pa_budget_versions
        SET     etc_start_date = p_actuals_thru_date(kk)+1
        WHERE   budget_version_id = l_bv_id_tab(kk);

    IF p_calling_context = 'WP_APPLY_PROGRESS_TO_WORKING' THEN
        FORALL m IN 1..l_res_asg_id_tab.count
            UPDATE pa_resource_assignments
            SET    unplanned_flag = 'N'
            WHERE  resource_assignment_id = l_res_asg_id_tab(m)
              AND    nvl(unplanned_flag,'N') = 'Y';
    END IF;

    FOR jj in 1..l_bv_id_tab.count LOOP
        /*  Calling the pa_fp_maintain_actual_pub.sync_up_planning_dates  api */
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                (p_called_mode => p_calling_mode,
                 p_msg         => 'Before calling
                                  pa_fp_maintain_actual_pub.sync_up_planning_dates',
                 p_module_name => l_module_name,
                 p_log_level   => 5);
        END IF;
        PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES
           (P_BUDGET_VERSION_ID => l_bv_id_tab(jj),
            P_CALLING_CONTEXT   => 'SYNC_VERSION_LEVEL',
            X_RETURN_STATUS     => x_return_Status,
            X_MSG_COUNT         => x_msg_count,
            X_MSG_DATA          => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                (p_called_mode => p_calling_mode,
                 p_msg         => 'Status after calling
                                     pa_fp_maintain_actual_pub.sync_up_planning_dates'
                                    ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
        END IF;
    END LOOP;

-- 5294838 : Added beloe code to delete temp table
   FOR ss1  IN 1 ..  P_PROJECT_ID_TAB.COUNT LOOP
delete from PA_PROG_ACT_BY_PERIOD_TEMP where project_id = P_PROJECT_ID_TAB(ss1) and  structure_version_id = P_WP_STR_VERSION_ID_TAB(ss1);
 end loop;

    IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
        PA_DEBUG.reset_err_stack;
    ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
        PA_DEBUG.Reset_Curr_Function;
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
        -- Bug 4621171: Removed ROLLBACK statement.

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Invalid Arguments Passed',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            IF p_init_msg_flag = 'Y' THEN
                PA_DEBUG.reset_err_stack;
            ELSIF p_init_msg_flag = 'N' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;
        END IF;
        -- Bug 4621171: Removed RAISE statement.
    WHEN OTHERS THEN
        -- Bug 4621171: Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_MAINTAIN_ACTUAL_PUB',
                     p_procedure_name  => 'MAINTAIN_ACTUAL_AMT_WRP',
                     p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            IF p_init_msg_flag = 'Y' THEN
                PA_DEBUG.reset_err_stack;
            ELSIF p_init_msg_flag = 'N' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END MAINTAIN_ACTUAL_AMT_WRP;


PROCEDURE UPD_REPORTING_LINES_WRP
               (p_calling_module           IN         Varchar2
               ,p_activity_code            IN         Varchar2
               ,p_budget_version_id        IN         Number
               ,p_resource_assignment_id   IN         Number
               ,p_budget_line_id_tab       IN         pa_plsql_datatypes.IdTabTyp
               ,p_calling_mode             IN         varchar2
               ,x_msg_data                 OUT NOCOPY Varchar2
               ,x_msg_count                OUT NOCOPY Number
               ,x_return_status            OUT NOCOPY Varchar2)  IS
l_module_name               VARCHAR2(200) :=
    'pa.plsql.pa_fp_maintain_actual_pub.upd_reporting_lines_wrp';
l_count                     NUMBER;
l_msg_count                 NUMBER;
l_cnt                       NUMBER;
l_data                      VARCHAR2(2000);
l_msg_data                  VARCHAR2(2000);
l_msg_index_out             NUMBER;
BEGIN
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'UPD_REPORTING_LINES_WRP'
                                   ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    IF p_budget_line_id_tab.count = 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    FOR jj IN 1..p_budget_line_id_tab.count LOOP
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Before calling
                                   pa_fp_pji_intg_pkg.update_reporting_lines_frombl',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Value of budget_line_id b4
                                       calling update_reporting_lines_frombl: '
                                       ||p_budget_line_id_tab(jj),
                     p_module_name => l_module_name,
                     p_log_level   => 5);
        END IF;
        PA_FP_PJI_INTG_PKG.UPDATE_REPORTING_LINES_FROMBL
                     (p_calling_module         => p_calling_module
                      ,p_activity_code          => p_activity_code
                      ,p_budget_version_id      => p_budget_version_id
                      ,p_resource_assignment_id => p_resource_assignment_id
                      ,p_budget_line_id         => p_budget_line_id_tab(jj)
                      ,x_msg_data               => x_msg_data
                      ,x_msg_count              => x_msg_count
                      ,x_return_status          => x_return_status);
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Status after calling
                                       pa_fp_pji_intg_pkg.update_reporting_lines_frombl'
                                      ||x_return_status,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
        END IF;
    END LOOP;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
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
        -- Bug 4621171: Removed ROLLBACK statement.

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Invalid Arguments Passed',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
        END IF;
        -- Bug 4621171: Removed RAISE statement.
    WHEN OTHERS THEN
        -- Bug 4621171: Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_MAINTAIN_ACTUAL_PUB',
                     p_procedure_name  => 'UPD_REPORTING_LINES_WRP',
                     p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                     p_module_name => l_module_name,
                     p_log_level   => 5);
             PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPD_REPORTING_LINES_WRP;


/**Valid parameters*****
  *P_CALLING_CONTEXT:   WP_PROGRESS -- Work plan progress
  *                     WP_SUMMARIZED_ACTUAL -- Work plan summarized actual transactions
  *                     FP_GEN_FCST_COPY_ACTUAL -- For Budgeting & Forecasting module.
  *                     WP_APPLY_PROGRESS_TO_WORKING
  *P_TXN_AMT_TYPE_CODE: ACTUAL_TXN (default value) -- Populate Actual Amt to Init columns.
  *                     PLANNING_TXN               -- Populate Planning Amt to plan columns
  *P_EXTRACTION_TYPE:   FULL -- DEFAULT, indicates full update of existing period
  *                     INCREMENTAL -- indicates increment the passed value of existing period
  *P_OPEN_PD_PLAN_AMT_FLAG: Y -- Leave existing plan qty/amounts as-is for period with end date of
  *                              P_OPEN_PD_END_DATE when Context is WP_APPLY_PROGRESS_TO_WORKING.
  *                         N (default value) -- Set plan = actual.
  *                         NOTE: If Target time phasing is None, the API will override this
  *                               parameter with N.
  *
  *We currently expect the following Scenarios from the Workplan side:
  *1. P_CALLING_CONTEXT = WP_APPLY_PROGRESS_TO_WORKING:
  *   -- P_EXTRACTION_TYPE always equals FULL
  *   -- No restriction on structure sharing type.
  *   -- IMPORTANT NOTE: If we start supporting extraction type of INCREMENT in this
  *   --                 case, we will need to extend fixes made for Bug 4142150.
  *2. P_CALLING_CONTEXT = WP_PROGRESS:
  *   -- P_EXTRACTION_TYPE always equals INCREMENTAL
  *   -- The structure cannot be fully shared in this case.
  *3. P_CALLING_CONTEXT = WP_SUMMARIZED_ACTUAL:
  *   -- P_EXTRACTION_TYPE = FULL the 1st time this API is called (or after a refresh)
  *   -- P_EXTRACTION_TYPE = INCREMENTAL for subsequent calls
  *   -- The structure must be fully shared in this case.
  *
  **/
PROCEDURE MAINTAIN_ACTUAL_AMT_RA
     (P_PROJECT_ID              IN          PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
      P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
      P_RESOURCE_ASSIGNMENT_ID  IN          PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
      P_TXN_CURRENCY_CODE       IN          PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
      P_AMT_DTLS_REC_TAB        IN          PA_FP_MAINTAIN_ACTUAL_PUB.l_amt_dtls_tbl_typ,
      P_CALLING_CONTEXT         IN          VARCHAR2,
      P_TXN_AMT_TYPE_CODE       IN          VARCHAR2,
      P_CALLING_MODE            IN          VARCHAR2,
      P_EXTRACTION_TYPE         IN          VARCHAR2,
      P_OPEN_PD_PLAN_AMT_FLAG   IN          VARCHAR2,
      P_OPEN_PD_END_DATE        IN          DATE,
      X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY  NUMBER,
      X_MSG_DATA                OUT NOCOPY  VARCHAR2) IS

l_module_name                     VARCHAR2(200) := 'pa.plsql.pa_fp_maintain_actual_pub.maintain_actual_amt_ra';
l_period_name_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
l_start_date_tab                  PA_PLSQL_DATATYPES.DateTabTyp;
l_end_date_tab                    PA_PLSQL_DATATYPES.DateTabTyp;
l_txn_raw_cost_tab                PA_PLSQL_DATATYPES.NumTabTyp;
l_qty_tab                         PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_burdened_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_revenue_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
l_project_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_project_burdened_cost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_project_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_raw_cost_tab                PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_burdened_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_revenue_tab                 PA_PLSQL_DATATYPES.NumTabTyp;

l_ins_period_name_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
l_ins_start_date_tab                  PA_PLSQL_DATATYPES.DateTabTyp;
l_ins_end_date_tab                    PA_PLSQL_DATATYPES.DateTabTyp;
l_ins_txn_raw_cost_tab                PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_txn_burdened_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_txn_revenue_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_project_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_proj_burdened_cost_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_project_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_pfc_raw_cost_tab                PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_pfc_burdened_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_pfc_revenue_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_qty_tab                         PA_PLSQL_DATATYPES.NumTabTyp;

l_upd_period_name_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_start_date_tab                  PA_PLSQL_DATATYPES.DateTabTyp;
l_upd_end_date_tab                    PA_PLSQL_DATATYPES.DateTabTyp;
l_upd_txn_raw_cost_tab                PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_txn_burdened_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_txn_revenue_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_project_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_proj_burdened_cost_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_project_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_pfc_raw_cost_tab                PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_pfc_burdened_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_pfc_revenue_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_qty_tab                         PA_PLSQL_DATATYPES.NumTabTyp;

l_version_type                        PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
l_projfunc_cost_rate_type_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_projfunc_rev_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
l_project_cost_rate_type_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
l_project_rev_rate_type_tab           PA_PLSQL_DATATYPES.Char30TabTyp;

/* PL/SQL tables for rate overrides (Added for Bug 4162449) */
l_cost_rate_override_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_bcost_rate_override_tab      PA_PLSQL_DATATYPES.NumTabTyp;
l_bill_rate_override_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_cost_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_bcost_rate_override_tab  PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_bill_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_cost_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bcost_rate_override_tab  PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bill_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;

l_last_updated_by                 NUMBER := FND_GLOBAL.user_id;
l_last_update_login               NUMBER := FND_GLOBAL.login_id;
l_sysdate                         DATE   := SYSDATE;

l_bdgt_line_id                    PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;
l_bdgt_line_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;

l_upd_ind                        NUMBER := 1;
l_ins_ind                        NUMBER := 1;

l_ins_flag                       VARCHAR2(1);

l_unplanned_res_flag             PA_RESOURCE_ASSIGNMENTS.UNPLANNED_FLAG%TYPE;

l_pc_code  pa_projects_all.PROJECT_CURRENCY_CODE%TYPE;
l_pfc_code pa_projects_all.PROJFUNC_CURRENCY_CODE%TYPE;

l_spread_curve_id                PA_RESOURCE_ASSIGNMENTS.SPREAD_CURVE_ID%TYPE;
l_multi_bdgt_lines               NUMBER;

-- Bug 4699248: Replaced l_spread_curve_name with l_spread_curve_code
-- throughout this procedure. Also, updated the type accordingly.
l_spread_curve_code              PA_SPREAD_CURVES_B.SPREAD_CURVE_CODE%TYPE;

l_bl_id_tab                      PA_PLSQL_DATATYPES.IdTabTyp;

l_time_phased_code               PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE;

/* Variables for Bug 4142150 */

l_open_pd_plan_amt_flag          VARCHAR2(1);

-- Scalar variables to store planned amounts
l_txn_raw_cost                 NUMBER;
l_txn_burdened_cost            NUMBER;
l_txn_revenue                  NUMBER;
l_project_raw_cost             NUMBER;
l_project_burdened_cost        NUMBER;
l_project_revenue              NUMBER;
l_raw_cost                     NUMBER;
l_burdened_cost                NUMBER;
l_revenue                      NUMBER;
l_quantity                     NUMBER;
l_txn_cost_rate_override       NUMBER;
l_burden_cost_rate_override    NUMBER;
l_txn_bill_rate_override       NUMBER;

-- PL/SQL tables to stored planned amounts from existing lines
l_upd_plan_txn_raw_cost_tab    PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_txn_brdn_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_txn_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_proj_raw_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_proj_brdn_cost_tab  PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_proj_revenue_tab    PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_pfc_raw_cost_tab    PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_pfc_brdn_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_pfc_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_plan_qty_tab             PA_PLSQL_DATATYPES.NumTabTyp;

l_ret_manual_line_flag        PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE;

BEGIN
    --Setting initial values
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'MAINTAIN_ACTUAL_AMT_RA'
                                     ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    SELECT  NVL(UNPLANNED_FLAG,'N')
    INTO    l_unplanned_res_flag
    FROM    pa_resource_assignments
    WHERE   resource_assignment_id = p_resource_assignment_id;

    SELECT project_currency_code,
           projfunc_currency_code INTO
           l_pc_code, l_pfc_code
    FROM pa_projects_all
    WHERE project_id = p_project_id;

    IF P_CALLING_CONTEXT = 'FP_GEN_FCST_COPY_ACTUAL' THEN

        -- ER 4376722: Reverted NVL around dtls_rec amounts for Generation context.
        -- This change avoids inserting 0 when NULL was intended. In particular,
        -- for non-billable tasks, revenue should be NULL instead of 0. The original
        -- reason for adding the NVL around dtls_rec amounts was to avoid nulling
        -- out amounts when updating a budget line with the sum of an existing amount
        -- and a NULL amount that is passed to this API. We will ensure that existing
        -- amounts are not nulled out during updates by adding logic to the UPDATE
        -- statements themselves when required.

        FOR i in 1..p_amt_dtls_rec_tab.count LOOP
            l_period_name_tab(i)           := p_amt_dtls_rec_tab(i).period_name;
            l_start_date_tab(i)            := p_amt_dtls_rec_tab(i).start_date;
            l_end_date_tab(i)              := p_amt_dtls_rec_tab(i).end_date;
            l_txn_raw_cost_tab(i)          := p_amt_dtls_rec_tab(i).txn_raw_cost;
            l_txn_burdened_cost_tab(i)     := p_amt_dtls_rec_tab(i).txn_burdened_cost;
            l_txn_revenue_tab(i)           := p_amt_dtls_rec_tab(i).txn_revenue;
            l_project_raw_cost_tab(i)      := p_amt_dtls_rec_tab(i).project_raw_cost;
            l_project_burdened_cost_tab(i) := p_amt_dtls_rec_tab(i).project_burdened_cost;
            l_project_revenue_tab(i)       := p_amt_dtls_rec_tab(i).project_revenue;
            l_pfc_raw_cost_tab(i)          := p_amt_dtls_rec_tab(i).project_func_raw_cost;
            l_pfc_burdened_cost_tab(i)     := p_amt_dtls_rec_tab(i).project_func_burdened_cost;
            l_pfc_revenue_tab(i)           := p_amt_dtls_rec_tab(i).project_func_revenue;
            l_qty_tab(i) := p_amt_dtls_rec_tab(i).quantity;
        END LOOP;
    ELSE -- p_calling_context is a Workplan context
        -- Added NVL around dtls_rec amounts during changes for Bug 4292083.
        FOR i in 1..p_amt_dtls_rec_tab.count LOOP
            l_period_name_tab(i)           := p_amt_dtls_rec_tab(i).period_name;
            l_start_date_tab(i)            := p_amt_dtls_rec_tab(i).start_date;
            l_end_date_tab(i)              := p_amt_dtls_rec_tab(i).end_date;
            l_txn_raw_cost_tab(i)          := nvl(p_amt_dtls_rec_tab(i).txn_raw_cost,0);
            l_txn_burdened_cost_tab(i)     := nvl(p_amt_dtls_rec_tab(i).txn_burdened_cost,0);
            l_txn_revenue_tab(i)           := nvl(p_amt_dtls_rec_tab(i).txn_revenue,0);
            l_project_raw_cost_tab(i)      := nvl(p_amt_dtls_rec_tab(i).project_raw_cost,0);
            l_project_burdened_cost_tab(i) := nvl(p_amt_dtls_rec_tab(i).project_burdened_cost,0);
            l_project_revenue_tab(i)       := nvl(p_amt_dtls_rec_tab(i).project_revenue,0);
            l_pfc_raw_cost_tab(i)          := nvl(p_amt_dtls_rec_tab(i).project_func_raw_cost,0);
            l_pfc_burdened_cost_tab(i)     := nvl(p_amt_dtls_rec_tab(i).project_func_burdened_cost,0);
            l_pfc_revenue_tab(i)           := nvl(p_amt_dtls_rec_tab(i).project_func_revenue,0);
            l_qty_tab(i) := nvl(p_amt_dtls_rec_tab(i).quantity,0);
        END LOOP;
    END IF;

    SELECT version_type INTO l_version_type
    FROM PA_BUDGET_VERSIONS
    WHERE budget_version_id = P_BUDGET_VERSION_ID;

    SELECT decode(l_version_type,
                  'COST', opt.cost_time_phased_code,
                  'REVENUE',opt.revenue_time_phased_code,
                  'ALL',opt.all_time_phased_code),
	   decode(l_version_type,
	          'COST',    opt.gen_cost_ret_manual_line_flag,
	          'REVENUE', opt.gen_rev_ret_manual_line_flag,
	          'ALL',     opt.gen_all_ret_manual_line_flag)
    INTO   l_time_phased_code,
           l_ret_manual_line_flag
    FROM   pa_proj_fp_options opt
    WHERE  opt.fin_plan_version_id = p_budget_version_id;

    /* Initialize l_open_pd_plan_amt_flag */
    IF l_time_phased_code IN ('P','G') THEN
        l_open_pd_plan_amt_flag := P_OPEN_PD_PLAN_AMT_FLAG;
    ELSE
        l_open_pd_plan_amt_flag := 'N';
    END IF;

    -- Bug 4162449: When p_txn_amt_type_code = PLANNING_TXN (i.e. the
    -- context is Average of Actuals), we compute the appropriate
    -- override rates and populate them in the budget lines. We perform
    -- the computations once and assign the values to the insert and
    -- update pl/sql tables as needed.

    FOR i in 1..l_period_name_tab.count LOOP
        l_cost_rate_override_tab(i)  := NULL;
        l_bcost_rate_override_tab(i) := NULL;
        l_bill_rate_override_tab(i)  := NULL;
    END LOOP;

    IF l_version_type = 'COST' THEN
        FOR i in 1..l_period_name_tab.count LOOP
            l_projfunc_cost_rate_type_tab(i) := NULL ; --'User' /* Bug 4034089 */
            l_projfunc_rev_rate_type_tab(i) := NULL;
            l_project_cost_rate_type_tab(i) := NULL ; --'User' /* Bug 4034089 */
            l_project_rev_rate_type_tab(i) := NULL;
            IF l_qty_tab(i) <> 0 THEN
                l_cost_rate_override_tab(i)  := l_txn_raw_cost_tab(i) / l_qty_tab(i);
                l_bcost_rate_override_tab(i) := l_txn_burdened_cost_tab(i) / l_qty_tab(i);
            END IF;
        END LOOP;
    ELSIF l_version_type = 'REVENUE' THEN
        FOR i in 1..l_period_name_tab.count LOOP
            l_projfunc_cost_rate_type_tab(i) := NULL;
            l_projfunc_rev_rate_type_tab(i) := NULL ; --'User' /* Bug 4034089 */
            l_project_cost_rate_type_tab(i) := NULL;
            l_project_rev_rate_type_tab(i) := NULL ; --'User' /* Bug 4034089 */
            IF l_qty_tab(i) <> 0 THEN
                l_bill_rate_override_tab(i)  := l_txn_revenue_tab(i) / l_qty_tab(i);
            END IF;
        END LOOP;
    ELSIF l_version_type = 'ALL' THEN
        FOR i in 1..l_period_name_tab.count LOOP
            l_projfunc_cost_rate_type_tab(i) := NULL ; --'User' /* Bug 4034089 */
            l_projfunc_rev_rate_type_tab(i) := NULL ; --'User' /* Bug 4034089 */
            l_project_cost_rate_type_tab(i) := NULL ; --'User' /* Bug 4034089 */
            l_project_rev_rate_type_tab(i) := NULL ; --'User' /* Bug 4034089 */
            IF l_qty_tab(i) <> 0 THEN
                l_cost_rate_override_tab(i)  := l_txn_raw_cost_tab(i) / l_qty_tab(i);
                l_bcost_rate_override_tab(i) := l_txn_burdened_cost_tab(i) / l_qty_tab(i);
                l_bill_rate_override_tab(i)  := l_txn_revenue_tab(i) / l_qty_tab(i);
            END IF;
        END LOOP;
    END IF;

    BEGIN
        SELECT   'N'
        INTO     l_ins_flag
        FROM     pa_budget_lines
        WHERE    resource_assignment_id = p_resource_assignment_id
        AND      txn_currency_code      = p_txn_currency_code
        AND      rownum < 2;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_ins_flag := 'Y';
    END;

    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            (p_called_mode => p_calling_mode,
             p_msg         => 'Value of l_ins_flag after sleecting from pa_budget_line: '||l_ins_flag,
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;

    /* Bulk Insert in PA_BUDGET_LINES table */

    -- Bug 4071198: When p_txn_amt_type_code = ACTUAL_TXN (i.e. the
    -- context is FP_GEN_FCST_COPY_ACTUAL ), we populate the appropriate
    -- override rates  in the budget lines.  Code changes are tagged with bug# 4071198

    IF l_ins_flag = 'Y' THEN
        IF (p_txn_amt_type_code = 'ACTUAL_TXN' AND
           (p_calling_context = 'WP_APPLY_PROGRESS_TO_WORKING'
           OR p_calling_context = 'FP_GEN_FCST_COPY_ACTUAL')) THEN
           /* no matter unplanned res flag is Y or N,
              the actual values (init cols ) should be copied to
              the plan columns. */
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Before inserting into pa_bdgt_lines when l_ins_flag is Y,
                                       p_txn_amt_type_code is ACTUAL_TXN and l_unplanned_res_flag is Y',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
            l_bl_id_tab.delete;

            -- Bug 4398799: Split original INSERT statement into 2 separate INSERT
            -- statements based on p_calling_context. When p_calling_context is
            -- 'FP_GEN_FCST_COPY_ACTUAL', we continue populating the rate override
            -- columns. In the ELSE case, the context is 'WP_APPLY_PROGRESS_TO_WORKING'
            -- so we populate the standard rate columns instead. Everything else about
            -- the INSERT statements is unchanged.

            IF p_calling_context = 'FP_GEN_FCST_COPY_ACTUAL' THEN
                FORALL j in 1..l_period_name_tab.count
                    INSERT  INTO
                        PA_BUDGET_LINES(BUDGET_VERSION_ID,
                            RESOURCE_ASSIGNMENT_ID,
                            PERIOD_NAME,
                            START_DATE,
                            END_DATE,
                            TXN_CURRENCY_CODE,
                            TXN_INIT_RAW_COST,
                            TXN_INIT_BURDENED_COST,
                            TXN_INIT_REVENUE,
                            PROJECT_INIT_RAW_COST,
                            PROJECT_INIT_BURDENED_COST,
                            PROJECT_INIT_REVENUE,
                            INIT_RAW_COST,
                            INIT_BURDENED_COST,
                            INIT_REVENUE,
                            TXN_RAW_COST,
                            TXN_BURDENED_COST,
                            TXN_REVENUE,
                            PROJECT_RAW_COST,
                            PROJECT_BURDENED_COST,
                            PROJECT_REVENUE,
                            RAW_COST,
                            BURDENED_COST,
                            REVENUE,
                            BUDGET_LINE_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            QUANTITY,
                            INIT_QUANTITY,
                            project_currency_code,
                            projfunc_currency_code,
    			TXN_COST_RATE_OVERRIDE, /* Bug 4071198 start */
    			BURDEN_COST_RATE_OVERRIDE,
    			TXN_BILL_RATE_OVERRIDE ) /* Bug 4071198 start */
                        VALUES(p_budget_version_id,
                            p_resource_assignment_id,
                            l_period_name_tab(j),
                            l_start_date_tab(j),
                            l_end_date_tab(j),
                            p_txn_currency_code,
                            l_txn_raw_cost_tab(j),
                            l_txn_burdened_cost_tab(j),
                            l_txn_revenue_tab(j),
                            l_project_raw_cost_tab(j),
                            l_project_burdened_cost_tab(j),
                            l_project_revenue_tab(j),
                            l_pfc_raw_cost_tab(j),
                            l_pfc_burdened_cost_tab(j),
                            l_pfc_revenue_tab(j),
                            l_txn_raw_cost_tab(j),
                            l_txn_burdened_cost_tab(j),
                            l_txn_revenue_tab(j),
                            l_project_raw_cost_tab(j),
                            l_project_burdened_cost_tab(j),
                            l_project_revenue_tab(j),
                            l_pfc_raw_cost_tab(j),
                            l_pfc_burdened_cost_tab(j),
                            l_pfc_revenue_tab(j),
                            PA_BUDGET_LINES_S.nextval,
                            l_sysdate,
                            l_last_updated_by,
                            l_sysdate,
                            l_last_updated_by,
                            l_last_update_login,
                            l_qty_tab(j),
                            l_qty_tab(j),
                            l_pc_code,
                            l_pfc_code ,
                            l_cost_rate_override_tab(j), /* bug 4071198 */
                            l_bcost_rate_override_tab(j),
                            l_bill_rate_override_tab(j)) /* bug 4071198 */
                            RETURNING budget_line_id BULK COLLECT INTO l_bl_id_tab;
            ELSE -- 'WP_APPLY_PROGRESS_TO_WORKING'
                FORALL j in 1..l_period_name_tab.count
                    INSERT  INTO
                        PA_BUDGET_LINES(BUDGET_VERSION_ID,
                            RESOURCE_ASSIGNMENT_ID,
                            PERIOD_NAME,
                            START_DATE,
                            END_DATE,
                            TXN_CURRENCY_CODE,
                            TXN_INIT_RAW_COST,
                            TXN_INIT_BURDENED_COST,
                            TXN_INIT_REVENUE,
                            PROJECT_INIT_RAW_COST,
                            PROJECT_INIT_BURDENED_COST,
                            PROJECT_INIT_REVENUE,
                            INIT_RAW_COST,
                            INIT_BURDENED_COST,
                            INIT_REVENUE,
                            TXN_RAW_COST,
                            TXN_BURDENED_COST,
                            TXN_REVENUE,
                            PROJECT_RAW_COST,
                            PROJECT_BURDENED_COST,
                            PROJECT_REVENUE,
                            RAW_COST,
                            BURDENED_COST,
                            REVENUE,
                            BUDGET_LINE_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            QUANTITY,
                            INIT_QUANTITY,
                            project_currency_code,
                            projfunc_currency_code,
                            TXN_STANDARD_COST_RATE,  /* Bug 4398799, 4071198 start */
                            BURDEN_COST_RATE,        /* Bug 4398799, 4071198 start */
                            TXN_STANDARD_BILL_RATE ) /* Bug 4398799, 4071198 start */
                        VALUES(p_budget_version_id,
                            p_resource_assignment_id,
                            l_period_name_tab(j),
                            l_start_date_tab(j),
                            l_end_date_tab(j),
                            p_txn_currency_code,
                            l_txn_raw_cost_tab(j),
                            l_txn_burdened_cost_tab(j),
                            l_txn_revenue_tab(j),
                            l_project_raw_cost_tab(j),
                            l_project_burdened_cost_tab(j),
                            l_project_revenue_tab(j),
                            l_pfc_raw_cost_tab(j),
                            l_pfc_burdened_cost_tab(j),
                            l_pfc_revenue_tab(j),
                            l_txn_raw_cost_tab(j),
                            l_txn_burdened_cost_tab(j),
                            l_txn_revenue_tab(j),
                            l_project_raw_cost_tab(j),
                            l_project_burdened_cost_tab(j),
                            l_project_revenue_tab(j),
                            l_pfc_raw_cost_tab(j),
                            l_pfc_burdened_cost_tab(j),
                            l_pfc_revenue_tab(j),
                            PA_BUDGET_LINES_S.nextval,
                            l_sysdate,
                            l_last_updated_by,
                            l_sysdate,
                            l_last_updated_by,
                            l_last_update_login,
                            l_qty_tab(j),
                            l_qty_tab(j),
                            l_pc_code,
                            l_pfc_code ,
                            l_cost_rate_override_tab(j), /* bug 4071198 */
                            l_bcost_rate_override_tab(j),
                            l_bill_rate_override_tab(j)) /* bug 4071198 */
                            RETURNING budget_line_id BULK COLLECT INTO l_bl_id_tab;
            END IF; -- calling context check (End Bug 4398799)

            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'After inserting into pa_bdgt_lines when l_ins_flag is Y,
                                       p_txn_amt_type_code is ACTUAL_TXN and l_unplanned_res_flag is Y',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
        ELSIF (p_calling_context = 'WP_PROGRESS' OR
               p_calling_context = 'WP_SUMMARIZED_ACTUAL') THEN
            --if unplanned res flag is N then
            --only the actual values (init cols ) should be populated.
            IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Before inserting into pa_bdgt_lines when l_ins_flag is Y,
                                       p_txn_amt_type_code is ACTUAL_TXN and l_unplanned_res_flag is N',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;

            l_bl_id_tab.delete;
            FORALL j in 1..l_period_name_tab.count
                INSERT  INTO
                    PA_BUDGET_LINES(BUDGET_VERSION_ID,
                        RESOURCE_ASSIGNMENT_ID,
                        PERIOD_NAME,
                        START_DATE,
                        END_DATE,
                        TXN_CURRENCY_CODE,
                        TXN_INIT_RAW_COST,
                        TXN_INIT_BURDENED_COST,
                        TXN_INIT_REVENUE,
                        PROJECT_INIT_RAW_COST,
                        PROJECT_INIT_BURDENED_COST,
                        PROJECT_INIT_REVENUE,
                        INIT_RAW_COST,
                        INIT_BURDENED_COST,
                        INIT_REVENUE,
                        BUDGET_LINE_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        INIT_QUANTITY,
                        project_currency_code,
                        projfunc_currency_code)
                VALUES(p_budget_version_id,
                        p_resource_assignment_id,
                        l_period_name_tab(j),
                        l_start_date_tab(j),
                        l_end_date_tab(j),
                        p_txn_currency_code,
                        l_txn_raw_cost_tab(j),
                        l_txn_burdened_cost_tab(j),
                        l_txn_revenue_tab(j),
                        l_project_raw_cost_tab(j),
                        l_project_burdened_cost_tab(j),
                        l_project_revenue_tab(j),
                        l_pfc_raw_cost_tab(j),
                        l_pfc_burdened_cost_tab(j),
                        l_pfc_revenue_tab(j),
                        PA_BUDGET_LINES_S.nextval,
                        l_sysdate,
                        l_last_updated_by,
                        l_sysdate,
                        l_last_updated_by,
                        l_last_update_login,
                        l_qty_tab(j),
                        l_pc_code,
                        l_pfc_code );
        ELSIF (p_txn_amt_type_code = 'PLANNING_TXN') THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Before inserting into pa_bdgt_lines when l_ins_flag is Y,
                                       p_txn_amt_type_code is PLANNING_TXN and
                                       l_version_type is COST or REVENUE or ALL',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            END IF;
            l_bl_id_tab.delete;
            FORALL j2 in 1..l_period_name_tab.count
                INSERT  INTO
                    PA_BUDGET_LINES(BUDGET_VERSION_ID,
                        RESOURCE_ASSIGNMENT_ID,
                        PERIOD_NAME,
                        START_DATE,
                        END_DATE,
                        TXN_CURRENCY_CODE,
                        TXN_RAW_COST,
                        TXN_BURDENED_COST,
                        TXN_REVENUE,
                        PROJECT_RAW_COST,
                        PROJECT_BURDENED_COST,
                        PROJECT_REVENUE,
                        RAW_COST,
                        BURDENED_COST,
                        REVENUE,
                        BUDGET_LINE_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        QUANTITY,
                        project_currency_code,
                        projfunc_currency_code,
                        PROJFUNC_COST_RATE_TYPE,
                        PROJFUNC_REV_RATE_TYPE,
                        PROJECT_COST_RATE_TYPE,
                        PROJECT_REV_RATE_TYPE,
			TXN_COST_RATE_OVERRIDE,
			BURDEN_COST_RATE_OVERRIDE,
			TXN_BILL_RATE_OVERRIDE )
                VALUES(p_budget_version_id,
                        p_resource_assignment_id,
                        l_period_name_tab(j2),
                        l_start_date_tab(j2),
                        l_end_date_tab(j2),
                        p_txn_currency_code,
                        l_txn_raw_cost_tab(j2),
                        l_txn_burdened_cost_tab(j2),
                        l_txn_revenue_tab(j2),
                        l_project_raw_cost_tab(j2),
                        l_project_burdened_cost_tab(j2),
                        l_project_revenue_tab(j2),
                        l_pfc_raw_cost_tab(j2),
                        l_pfc_burdened_cost_tab(j2),
                        l_pfc_revenue_tab(j2),
                        PA_BUDGET_LINES_S.nextval,
                        l_sysdate,
                        l_last_updated_by,
                        l_sysdate,
                        l_last_updated_by,
                        l_last_update_login,
                        l_qty_tab(j2),
                        l_pc_code,
                        l_pfc_code,
                        l_projfunc_cost_rate_type_tab(j2),
                        l_projfunc_rev_rate_type_tab(j2),
                        l_project_cost_rate_type_tab(j2),
                        l_project_rev_rate_type_tab(j2),
                        l_cost_rate_override_tab(j2),
                        l_bcost_rate_override_tab(j2),
                        l_bill_rate_override_tab(j2))
                        RETURNING budget_line_id
                        BULK COLLECT INTO l_bl_id_tab;
        END IF;
        /* dbms_output.put_line('No. of rows inserted in
         bl table: '||sql%rowcount); */
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    ELSIF   l_ins_flag = 'N' THEN
        FOR k in 1..l_period_name_tab.count LOOP
            -- Initialize local variables for this loop iteration
            l_bdgt_line_id := null;
            l_txn_raw_cost := null;
            l_txn_burdened_cost := null;
            l_txn_revenue := null;
            l_project_raw_cost := null;
            l_project_burdened_cost := null;
            l_project_revenue := null;
            l_raw_cost := null;
            l_burdened_cost := null;
            l_revenue := null;
            l_quantity := null;
            l_txn_cost_rate_override := null;
            l_burden_cost_rate_override := null;
            l_txn_bill_rate_override := null;

            BEGIN
                IF l_time_phased_code IN ('P','G') THEN
                    IF l_open_pd_plan_amt_flag = 'Y' AND
                       l_end_date_tab(k) = p_open_pd_end_date AND
                       p_extraction_type = 'FULL' AND
                       p_calling_context = 'WP_APPLY_PROGRESS_TO_WORKING' THEN

                        -- Bug 4398799: For Workplan flow, modified code to populate
                        -- standard rate columns instead of rate override columns.

                        SELECT  budget_line_id,
                                TXN_RAW_COST,
                                TXN_BURDENED_COST,
                                TXN_REVENUE,
                                PROJECT_RAW_COST,
                                PROJECT_BURDENED_COST,
                                PROJECT_REVENUE,
                                RAW_COST,
                                BURDENED_COST,
                                REVENUE,
                                QUANTITY,
                                TXN_STANDARD_COST_RATE, /* Bug 4398799 */
                                BURDEN_COST_RATE,       /* Bug 4398799 */
                                TXN_STANDARD_BILL_RATE  /* Bug 4398799 */
                        INTO    l_bdgt_line_id,
                                l_txn_raw_cost,
                                l_txn_burdened_cost,
                                l_txn_revenue,
                                l_project_raw_cost,
                                l_project_burdened_cost,
                                l_project_revenue,
                                l_raw_cost,
                                l_burdened_cost,
                                l_revenue,
                                l_quantity,
                                l_txn_cost_rate_override,
                                l_burden_cost_rate_override,
                                l_txn_bill_rate_override
                        FROM    pa_budget_lines
                        WHERE   resource_assignment_id = p_resource_assignment_id
                        AND     start_date = l_start_date_tab(k)
                        AND     txn_currency_code = p_txn_currency_code;
                    ELSE
                        SELECT  budget_line_id
                        INTO    l_bdgt_line_id
                        FROM    pa_budget_lines
                        WHERE   resource_assignment_id = p_resource_assignment_id
                        AND     start_date = l_start_date_tab(k)
                        AND     txn_currency_code = p_txn_currency_code;
                    END IF;
                ELSIF l_time_phased_code = 'N' THEN
                      SELECT  budget_line_id
                      INTO    l_bdgt_line_id
                      FROM    pa_budget_lines
                      WHERE   resource_assignment_id = p_resource_assignment_id
                      AND     txn_currency_code      = p_txn_currency_code;
                END IF;

                l_bdgt_line_id_tab(l_upd_ind)             := l_bdgt_line_id;

                l_upd_period_name_tab(l_upd_ind)          := l_period_name_tab(k);
                l_upd_start_date_tab(l_upd_ind)           := l_start_date_tab(k);
                l_upd_end_date_tab(l_upd_ind)             := l_end_date_tab(k);
                l_upd_txn_raw_cost_tab(l_upd_ind)         := l_txn_raw_cost_tab(k);
                l_upd_txn_burdened_cost_tab(l_upd_ind)    := l_txn_burdened_cost_tab(k);
                l_upd_txn_revenue_tab(l_upd_ind)          := l_txn_revenue_tab(k);
                l_upd_project_raw_cost_tab(l_upd_ind)     := l_project_raw_cost_tab(k);
                l_upd_proj_burdened_cost_tab(l_upd_ind)   := l_project_burdened_cost_tab(k);
                l_upd_project_revenue_tab(l_upd_ind)      := l_project_revenue_tab(k);
                l_upd_pfc_raw_cost_tab(l_upd_ind)         := l_pfc_raw_cost_tab(k);
                l_upd_pfc_burdened_cost_tab(l_upd_ind)    := l_pfc_burdened_cost_tab(k);
                l_upd_pfc_revenue_tab(l_upd_ind)          := l_pfc_revenue_tab(k);
                l_upd_qty_tab(l_upd_ind) := l_qty_tab(k);

                -- Bug 4142150: If the following conditions are met, we apply the actuals
                -- but leave the Plan amounts as-is for the given period:
                --     1. Calling Context is WP_APPLY_PROGRESS_TO_WORKING,
                --     2. Extraction Type is FULL
                --     3. Actual Through Date falls prior to the End Date of its period
                --     4. Target time phase is PA or GL
                --     5. Actual Quantity <= Plan Quantity
                --     6. Given period = Actuals Through Date period (p_open_pd_end_date)
                -- NOTE: Currently, Condition 1 implies Condition 2. However, if the
                -- Workplan team starts to use Extraction Type = Incremental in conjunction
                -- with Condition 1, this bug fix will need to be extended to cover that case.

                IF l_open_pd_plan_amt_flag = 'Y' AND
                   p_extraction_type = 'FULL' AND
                   p_calling_context = 'WP_APPLY_PROGRESS_TO_WORKING' THEN
                    -- If Actual <= Plan, then we will update Actual amounts and leave
                    -- the Plan amounts alone. If Actual > Plan, then we will update
                    -- Actual amounts and set Plan = Actual.
                    IF l_qty_tab(k) <= l_quantity AND
                       l_open_pd_plan_amt_flag = 'Y' AND
                       l_end_date_tab(k) = p_open_pd_end_date THEN

                        l_upd_plan_txn_raw_cost_tab(l_upd_ind)   := l_txn_raw_cost;
                        l_upd_plan_txn_brdn_cost_tab(l_upd_ind)  := l_txn_burdened_cost;
                        l_upd_plan_txn_revenue_tab(l_upd_ind)    := l_txn_revenue;
                        l_upd_plan_proj_raw_cost_tab(l_upd_ind)  := l_project_raw_cost;
                        l_upd_plan_proj_brdn_cost_tab(l_upd_ind) := l_project_burdened_cost;
                        l_upd_plan_proj_revenue_tab(l_upd_ind)   := l_project_revenue;
                        l_upd_plan_pfc_raw_cost_tab(l_upd_ind)   := l_raw_cost;
                        l_upd_plan_pfc_brdn_cost_tab(l_upd_ind)  := l_burdened_cost;
                        l_upd_plan_pfc_revenue_tab(l_upd_ind)    := l_revenue;
                        l_upd_plan_qty_tab(l_upd_ind)            := l_quantity;

                        l_upd_cost_rate_override_tab(l_upd_ind)   := l_txn_cost_rate_override;
                        l_upd_bcost_rate_override_tab(l_upd_ind)  := l_burden_cost_rate_override;
                        l_upd_bill_rate_override_tab(l_upd_ind)   := l_txn_bill_rate_override;
                    ELSE
                        l_upd_plan_txn_raw_cost_tab(l_upd_ind)   := l_txn_raw_cost_tab(k);
                        l_upd_plan_txn_brdn_cost_tab(l_upd_ind)  := l_txn_burdened_cost_tab(k);
                        l_upd_plan_txn_revenue_tab(l_upd_ind)    := l_txn_revenue_tab(k);
                        l_upd_plan_proj_raw_cost_tab(l_upd_ind)  := l_project_raw_cost_tab(k);
                        l_upd_plan_proj_brdn_cost_tab(l_upd_ind) := l_project_burdened_cost_tab(k);
                        l_upd_plan_proj_revenue_tab(l_upd_ind)   := l_project_revenue_tab(k);
                        l_upd_plan_pfc_raw_cost_tab(l_upd_ind)   := l_pfc_raw_cost_tab(k);
                        l_upd_plan_pfc_brdn_cost_tab(l_upd_ind)  := l_pfc_burdened_cost_tab(k);
                        l_upd_plan_pfc_revenue_tab(l_upd_ind)    := l_pfc_revenue_tab(k);
                        l_upd_plan_qty_tab(l_upd_ind)            := l_qty_tab(k);

                        -- Assign pre-computed override rates to pl/sql update tables.
                        l_upd_cost_rate_override_tab(l_upd_ind)   := l_cost_rate_override_tab(k);
                        l_upd_bcost_rate_override_tab(l_upd_ind)  := l_bcost_rate_override_tab(k);
                        l_upd_bill_rate_override_tab(l_upd_ind)   := l_bill_rate_override_tab(k);
                    END IF;
                ELSE
                    -- Assign pre-computed override rates to pl/sql update tables.
                    l_upd_cost_rate_override_tab(l_upd_ind)   := l_cost_rate_override_tab(k);
                    l_upd_bcost_rate_override_tab(l_upd_ind)  := l_bcost_rate_override_tab(k);
                    l_upd_bill_rate_override_tab(l_upd_ind)   := l_bill_rate_override_tab(k);
                END IF;

                l_upd_ind := l_upd_ind + 1;
            EXCEPTION
                WHEN  no_data_found THEN
                    l_ins_period_name_tab(l_ins_ind)          := l_period_name_tab(k);
                    l_ins_start_date_tab(l_ins_ind)           := l_start_date_tab(k);
                    l_ins_end_date_tab(l_ins_ind)             := l_end_date_tab(k);
                    l_ins_txn_raw_cost_tab(l_ins_ind)         := l_txn_raw_cost_tab(k);
                    l_ins_txn_burdened_cost_tab(l_ins_ind)    := l_txn_burdened_cost_tab(k);
                    l_ins_txn_revenue_tab(l_ins_ind)          := l_txn_revenue_tab(k);
                    l_ins_project_raw_cost_tab(l_ins_ind)     := l_project_raw_cost_tab(k);
                    l_ins_proj_burdened_cost_tab(l_ins_ind)   := l_project_burdened_cost_tab(k);
                    l_ins_project_revenue_tab(l_ins_ind)      := l_project_revenue_tab(k);
                    l_ins_pfc_raw_cost_tab(l_ins_ind)         := l_pfc_raw_cost_tab(k);
                    l_ins_pfc_burdened_cost_tab(l_ins_ind)    := l_pfc_burdened_cost_tab(k);
                    l_ins_pfc_revenue_tab(l_ins_ind)          := l_pfc_revenue_tab(k);
                    l_ins_qty_tab(l_ins_ind) := l_qty_tab(k);

                    -- Assign pre-computed override rates to pl/sql insert tables.
                    l_ins_cost_rate_override_tab(l_ins_ind)   := l_cost_rate_override_tab(k);
                    l_ins_bcost_rate_override_tab(l_ins_ind)  := l_bcost_rate_override_tab(k);
                    l_ins_bill_rate_override_tab(l_ins_ind)   := l_bill_rate_override_tab(k);

                    l_ins_ind := l_ins_ind + 1;
            END;

            l_bdgt_line_id := null;

        END LOOP;

        /* dbms_output.put_line('Update count when the ins_flag is null:
        '|| l_upd_period_name_tab.count);*/

        /* Bulk Update in PA_BUDGET_LINES table */
        IF   l_upd_period_name_tab.count > 0 THEN
            IF (p_txn_amt_type_code = 'ACTUAL_TXN' AND
               (p_calling_context = 'WP_APPLY_PROGRESS_TO_WORKING'
               OR p_calling_context = 'FP_GEN_FCST_COPY_ACTUAL')) THEN

                IF p_calling_context = 'WP_APPLY_PROGRESS_TO_WORKING'
                   AND P_EXTRACTION_TYPE  = 'INCREMENTAL' THEN
                    FORALL m in 1..l_upd_period_name_tab.count
                        UPDATE pa_budget_lines
                            SET
                                TXN_INIT_RAW_COST          = NVL(TXN_INIT_RAW_COST,0) + l_upd_txn_raw_cost_tab(m),
                                TXN_INIT_BURDENED_COST     = NVL(TXN_INIT_BURDENED_COST,0) + l_upd_txn_burdened_cost_tab(m),
                                TXN_INIT_REVENUE           = NVL(TXN_INIT_REVENUE,0) + l_upd_txn_revenue_tab(m),
                                PROJECT_INIT_RAW_COST      = NVL(PROJECT_INIT_RAW_COST,0) + l_upd_project_raw_cost_tab(m),
                                PROJECT_INIT_BURDENED_COST = NVL(PROJECT_INIT_BURDENED_COST,0) + l_upd_proj_burdened_cost_tab(m),
                                PROJECT_INIT_REVENUE       = NVL(PROJECT_INIT_REVENUE,0) + l_upd_project_revenue_tab(m),
                                INIT_RAW_COST              = NVL(INIT_RAW_COST,0) + l_upd_pfc_raw_cost_tab(m),
                                INIT_BURDENED_COST         = NVL(INIT_BURDENED_COST,0) + l_upd_pfc_burdened_cost_tab(m),
                                INIT_REVENUE               = NVL(INIT_REVENUE,0) + l_upd_pfc_revenue_tab(m),
                                TXN_RAW_COST               = NVL(TXN_RAW_COST,0) + l_upd_txn_raw_cost_tab(m),
                                TXN_BURDENED_COST          = NVL(TXN_BURDENED_COST,0) + l_upd_txn_burdened_cost_tab(m),
                                TXN_REVENUE                = NVL(TXN_REVENUE,0) + l_upd_txn_revenue_tab(m),
                                PROJECT_RAW_COST           = NVL(PROJECT_RAW_COST,0) + l_upd_project_raw_cost_tab(m),
                                PROJECT_BURDENED_COST      = NVL(PROJECT_BURDENED_COST,0) + l_upd_proj_burdened_cost_tab(m),
                                PROJECT_REVENUE            = NVL(PROJECT_REVENUE,0) + l_upd_project_revenue_tab(m),
                                RAW_COST                   = NVL(RAW_COST,0) + l_upd_pfc_raw_cost_tab(m),
                                BURDENED_COST              = NVL(BURDENED_COST,0) + l_upd_pfc_burdened_cost_tab(m),
                                REVENUE                    = NVL(REVENUE,0) + l_upd_pfc_revenue_tab(m),
                                LAST_UPDATE_DATE           = l_sysdate,
                                LAST_UPDATED_BY            = l_last_updated_by,
                                CREATION_DATE              = l_sysdate,
                                CREATED_BY                 = l_last_updated_by,
                                LAST_UPDATE_LOGIN          = l_last_update_login,
                                QUANTITY                   = NVL(QUANTITY,0) + l_upd_qty_tab(m),
                                INIT_QUANTITY              = NVL(INIT_QUANTITY,0) + l_upd_qty_tab(m)
                            WHERE   budget_line_id         = l_bdgt_line_id_tab(m);

                    -- Bug 4398799: For Workplan flow, modified code to populate
                    -- standard rate columns instead of rate override columns.

/* bug 4071198  start */
/* bug 4398799  start */
                    IF l_version_type = 'COST' THEN

                       FORALL m in 1..l_upd_period_name_tab.count
                              UPDATE pa_budget_lines SET
			           TXN_STANDARD_COST_RATE  = decode (nvl(quantity,0), 0, NULL, txn_raw_cost / quantity),
			           BURDEN_COST_RATE        = decode (nvl(quantity,0), 0, NULL, txn_burdened_cost/quantity)
                              WHERE   budget_line_id       = l_bdgt_line_id_tab(m);

                    ELSIF l_version_type = 'REVENUE' THEN

                       FORALL m in 1..l_upd_period_name_tab.count
                              UPDATE pa_budget_lines SET
			           TXN_STANDARD_BILL_RATE  = decode (nvl(quantity,0), 0, NULL, txn_revenue/quantity)
                              WHERE   budget_line_id       = l_bdgt_line_id_tab(m);

                    ELSIF l_version_type = 'ALL' THEN

                       FORALL m in 1..l_upd_period_name_tab.count
                              UPDATE pa_budget_lines SET
			           TXN_STANDARD_COST_RATE  = decode (nvl(quantity,0), 0, NULL, txn_raw_cost / quantity),
			           BURDEN_COST_RATE        = decode (nvl(quantity,0), 0, NULL, txn_burdened_cost/quantity),
			           TXN_STANDARD_BILL_RATE  = decode (nvl(quantity,0), 0, NULL, txn_revenue/quantity)
                              WHERE   budget_line_id       = l_bdgt_line_id_tab(m);

                    END IF;
/* bug 4398799  end */
/* bug 4071198  end */

                -- Added this condition and Update as part of fix for Bug 4142150.
                -- Note that we do not need to check the Manual lines flag and
                -- time phase here, since l_open_pd_plan_amt_flag = 'Y' implies
                -- that time phase is PA or GL.
                ELSIF l_open_pd_plan_amt_flag = 'Y' AND
                      p_calling_context = 'WP_APPLY_PROGRESS_TO_WORKING' AND
                      P_EXTRACTION_TYPE = 'FULL' THEN
                    FORALL m in 1..l_upd_period_name_tab.count
                        UPDATE pa_budget_lines
                            SET
                                TXN_INIT_RAW_COST          = l_upd_txn_raw_cost_tab(m),
                                TXN_INIT_BURDENED_COST     = l_upd_txn_burdened_cost_tab(m),
                                TXN_INIT_REVENUE           = l_upd_txn_revenue_tab(m),
                                PROJECT_INIT_RAW_COST      = l_upd_project_raw_cost_tab(m),
                                PROJECT_INIT_BURDENED_COST = l_upd_proj_burdened_cost_tab(m),
                                PROJECT_INIT_REVENUE       = l_upd_project_revenue_tab(m),
                                INIT_RAW_COST              = l_upd_pfc_raw_cost_tab(m),
                                INIT_BURDENED_COST         = l_upd_pfc_burdened_cost_tab(m),
                                INIT_REVENUE               = l_upd_pfc_revenue_tab(m),
                                TXN_RAW_COST               = l_upd_plan_txn_raw_cost_tab(m),
                                TXN_BURDENED_COST          = l_upd_plan_txn_brdn_cost_tab(m),
                                TXN_REVENUE                = l_upd_plan_txn_revenue_tab(m),
                                PROJECT_RAW_COST           = l_upd_plan_proj_raw_cost_tab(m),
                                PROJECT_BURDENED_COST      = l_upd_plan_proj_brdn_cost_tab(m),
                                PROJECT_REVENUE            = l_upd_plan_proj_revenue_tab(m),
                                RAW_COST                   = l_upd_plan_pfc_raw_cost_tab(m),
                                BURDENED_COST              = l_upd_plan_pfc_brdn_cost_tab(m),
                                REVENUE                    = l_upd_plan_pfc_revenue_tab(m),
                                LAST_UPDATE_DATE           = l_sysdate,
                                LAST_UPDATED_BY            = l_last_updated_by,
                                CREATION_DATE              = l_sysdate,
                                CREATED_BY                 = l_last_updated_by,
                                LAST_UPDATE_LOGIN          = l_last_update_login,
                                QUANTITY                   = l_upd_plan_qty_tab(m),
                                INIT_QUANTITY              = l_upd_qty_tab(m),
			        TXN_STANDARD_COST_RATE     = l_upd_cost_rate_override_tab(m), /* Bug 4398799, 4071198 start */
			        BURDEN_COST_RATE           = l_upd_bcost_rate_override_tab(m),
			        TXN_STANDARD_BILL_RATE     = l_upd_bill_rate_override_tab(m) /* Bug 4398799, 4071198 end */
                            WHERE   budget_line_id             = l_bdgt_line_id_tab(m);
                ELSE
                    -- Bug 4232253 : Rev. forecast incorrect for NTP with retain Manually ordered line.
                    If l_ret_manual_line_flag = 'Y' AND l_time_phased_code = 'N' then

	                -- Bug 4292083: When the Target timephase is None, update the plan
	                -- columns with total amounts (Actual + Planning_Txn). Since we no
                        -- longer call the UPDATE_TOTAL_PLAN_AMTS API in the Forecast Gen
                        -- wrapper, we need to modify the update logic here.

                        -- ER 4376722: Split original UPDATE statement into 2 separate UPDATE
	                -- statements based on p_calling_context. When p_calling_context is
	                -- 'FP_GEN_FCST_COPY_ACTUAL', changed the update logic as follows:
                        -- Before: Set amount = NVL(existing amount,0) + update amount.
                        -- After:  If existing amount is null, then set amount = update amount.
                        --         If existing amount is not null, then
                        --            set amount = existing amount + NVL(update amount, 0)
                        --         The new logic preserves the non-null existing amounts.
                        -- This change is necessary in case update revenue is Null. Using the
                        -- old logic, we would set revenue to NVL(existing revenue,0) + Null,
                        -- which is just Null. In other words, the existing revenue would be lost.
                        -- Using the new logic, we would set revenue to existing revenue +
                        -- NVL(NULL,0) = existing revenue. In this case, the existing amounts
                        -- are manually added.
                        -- In the ELSE case, the context is 'WP_APPLY_PROGRESS_TO_WORKING'
	                -- so we use the same UPDATE statement as before to avoid changing
                        -- Workplan behavior.

	                IF p_calling_context = 'FP_GEN_FCST_COPY_ACTUAL' THEN
                            FORALL m in 1..l_upd_period_name_tab.count
                                UPDATE pa_budget_lines
                                    SET -- Begin 4376722, 4292083 changes --
                                        TXN_RAW_COST               =
                                            DECODE(TXN_RAW_COST, null, l_upd_txn_raw_cost_tab(m),
                                                   TXN_RAW_COST + NVL(l_upd_txn_raw_cost_tab(m),0)),
                                        TXN_BURDENED_COST          =
                                            DECODE(TXN_BURDENED_COST, null, l_upd_txn_burdened_cost_tab(m),
                                                   TXN_BURDENED_COST + NVL(l_upd_txn_burdened_cost_tab(m),0)),
                                        TXN_REVENUE                =
                                            DECODE(TXN_REVENUE, null, l_upd_txn_revenue_tab(m),
                                                   TXN_REVENUE + NVL(l_upd_txn_revenue_tab(m),0)),
                                        PROJECT_RAW_COST           =
                                            DECODE(PROJECT_RAW_COST, null, l_upd_project_raw_cost_tab(m),
                                                   PROJECT_RAW_COST + NVL(l_upd_project_raw_cost_tab(m),0)),
                                        PROJECT_BURDENED_COST      =
                                            DECODE(PROJECT_BURDENED_COST, null, l_upd_proj_burdened_cost_tab(m),
                                                   PROJECT_BURDENED_COST + NVL(l_upd_proj_burdened_cost_tab(m),0)),
                                        PROJECT_REVENUE            =
                                            DECODE(PROJECT_REVENUE, null, l_upd_project_revenue_tab(m),
                                                   PROJECT_REVENUE + NVL(l_upd_project_revenue_tab(m),0)),
                                        RAW_COST                   =
                                            DECODE(RAW_COST, null, l_upd_pfc_raw_cost_tab(m),
                                                   RAW_COST + NVL(l_upd_pfc_raw_cost_tab(m),0)),
                                        BURDENED_COST              =
                                            DECODE(BURDENED_COST, null, l_upd_pfc_burdened_cost_tab(m),
                                                   BURDENED_COST + NVL(l_upd_pfc_burdened_cost_tab(m),0)),
                                        REVENUE                    =
                                            DECODE(REVENUE, null, l_upd_pfc_revenue_tab(m),
                                                   REVENUE + NVL(l_upd_pfc_revenue_tab(m),0)),
                                        QUANTITY                   =
                                            DECODE(QUANTITY, null, l_upd_qty_tab(m),
                                                   QUANTITY + NVL(l_upd_qty_tab(m),0)),
                                        -- End 4376722, 4292083 changes --
                                        TXN_INIT_RAW_COST          = l_upd_txn_raw_cost_tab(m),
                                        TXN_INIT_BURDENED_COST     = l_upd_txn_burdened_cost_tab(m),
                                        TXN_INIT_REVENUE           = l_upd_txn_revenue_tab(m),
                                        PROJECT_INIT_RAW_COST      = l_upd_project_raw_cost_tab(m),
                                        PROJECT_INIT_BURDENED_COST = l_upd_proj_burdened_cost_tab(m),
                                        PROJECT_INIT_REVENUE       = l_upd_project_revenue_tab(m),
                                        INIT_RAW_COST              = l_upd_pfc_raw_cost_tab(m),
                                        INIT_BURDENED_COST         = l_upd_pfc_burdened_cost_tab(m),
                                        INIT_REVENUE               = l_upd_pfc_revenue_tab(m),
                                        LAST_UPDATE_DATE           = l_sysdate,
                                        LAST_UPDATED_BY            = l_last_updated_by,
                                        CREATION_DATE              = l_sysdate,
                                        CREATED_BY                 = l_last_updated_by,
                                        LAST_UPDATE_LOGIN          = l_last_update_login,
                                        INIT_QUANTITY              = l_upd_qty_tab(m)
                                    WHERE   budget_line_id         = l_bdgt_line_id_tab(m);
	                ELSE -- 'WP_APPLY_PROGRESS_TO_WORKING'
                            FORALL m in 1..l_upd_period_name_tab.count
                                UPDATE pa_budget_lines
                                    SET -- Begin 4292083 changes --
                                        TXN_RAW_COST               = NVL(TXN_RAW_COST,0)
                                                                     + l_upd_txn_raw_cost_tab(m),
                                        TXN_BURDENED_COST          = NVL(TXN_BURDENED_COST,0)
                                                                     + l_upd_txn_burdened_cost_tab(m),
                                        TXN_REVENUE                = NVL(TXN_REVENUE,0)
                                                                     + l_upd_txn_revenue_tab(m),
                                        PROJECT_RAW_COST           = NVL(PROJECT_RAW_COST,0)
                                                                     + l_upd_project_raw_cost_tab(m),
                                        PROJECT_BURDENED_COST      = NVL(PROJECT_BURDENED_COST,0)
                                                                     + l_upd_proj_burdened_cost_tab(m),
                                        PROJECT_REVENUE            = NVL(PROJECT_REVENUE,0)
                                                                     + l_upd_project_revenue_tab(m),
                                        RAW_COST                   = NVL(RAW_COST,0)
                                                                     + l_upd_pfc_raw_cost_tab(m),
                                        BURDENED_COST              = NVL(BURDENED_COST,0)
                                                                     + l_upd_pfc_burdened_cost_tab(m),
                                        REVENUE                    = NVL(REVENUE,0)
                                                                     +  l_upd_pfc_revenue_tab(m),
                                        QUANTITY                   = NVL(QUANTITY,0) + l_upd_qty_tab(m),
                                        -- End 4292083 changes --
                                        TXN_INIT_RAW_COST          = l_upd_txn_raw_cost_tab(m),
                                        TXN_INIT_BURDENED_COST     = l_upd_txn_burdened_cost_tab(m),
                                        TXN_INIT_REVENUE           = l_upd_txn_revenue_tab(m),
                                        PROJECT_INIT_RAW_COST      = l_upd_project_raw_cost_tab(m),
                                        PROJECT_INIT_BURDENED_COST = l_upd_proj_burdened_cost_tab(m),
                                        PROJECT_INIT_REVENUE       = l_upd_project_revenue_tab(m),
                                        INIT_RAW_COST              = l_upd_pfc_raw_cost_tab(m),
                                        INIT_BURDENED_COST         = l_upd_pfc_burdened_cost_tab(m),
                                        INIT_REVENUE               = l_upd_pfc_revenue_tab(m),
                                        LAST_UPDATE_DATE           = l_sysdate,
                                        LAST_UPDATED_BY            = l_last_updated_by,
                                        CREATION_DATE              = l_sysdate,
                                        CREATED_BY                 = l_last_updated_by,
                                        LAST_UPDATE_LOGIN          = l_last_update_login,
                                        INIT_QUANTITY              = l_upd_qty_tab(m)
                                    WHERE   budget_line_id         = l_bdgt_line_id_tab(m);
	                END IF; -- p_calling_context check for ER 4376722

                    ELSE -- l_ret_manual_line_flag <> 'Y' OR l_time_phased_code <> 'N'

	                -- Bug 4398799: Split original UPDATE statement into 2 separate UPDATE
	                -- statements based on p_calling_context. When p_calling_context is
	                -- 'FP_GEN_FCST_COPY_ACTUAL', we continue populating the rate override
	                -- columns. In the ELSE case, the context is 'WP_APPLY_PROGRESS_TO_WORKING'
	                -- so we populate the standard rate columns instead. Everything else about
	                -- the UPDATE statements is unchanged.

	                IF p_calling_context = 'FP_GEN_FCST_COPY_ACTUAL' THEN
                            FORALL m in 1..l_upd_period_name_tab.count
                                UPDATE pa_budget_lines
                                    SET
                                        TXN_INIT_RAW_COST          = l_upd_txn_raw_cost_tab(m),
                                        TXN_INIT_BURDENED_COST     = l_upd_txn_burdened_cost_tab(m),
                                        TXN_INIT_REVENUE           = l_upd_txn_revenue_tab(m),
                                        PROJECT_INIT_RAW_COST      = l_upd_project_raw_cost_tab(m),
                                        PROJECT_INIT_BURDENED_COST = l_upd_proj_burdened_cost_tab(m),
                                        PROJECT_INIT_REVENUE       = l_upd_project_revenue_tab(m),
                                        INIT_RAW_COST              = l_upd_pfc_raw_cost_tab(m),
                                        INIT_BURDENED_COST         = l_upd_pfc_burdened_cost_tab(m),
                                        INIT_REVENUE               = l_upd_pfc_revenue_tab(m),
                                        TXN_RAW_COST               = l_upd_txn_raw_cost_tab(m),
                                        TXN_BURDENED_COST          = l_upd_txn_burdened_cost_tab(m),
                                        TXN_REVENUE                = l_upd_txn_revenue_tab(m),
                                        PROJECT_RAW_COST           = l_upd_project_raw_cost_tab(m),
                                        PROJECT_BURDENED_COST      = l_upd_proj_burdened_cost_tab(m),
                                        PROJECT_REVENUE            = l_upd_project_revenue_tab(m),
                                        RAW_COST                   = l_upd_pfc_raw_cost_tab(m),
                                        BURDENED_COST              = l_upd_pfc_burdened_cost_tab(m),
                                        REVENUE                    = l_upd_pfc_revenue_tab(m),
                                        LAST_UPDATE_DATE           = l_sysdate,
                                        LAST_UPDATED_BY            = l_last_updated_by,
                                        CREATION_DATE              = l_sysdate,
                                        CREATED_BY                 = l_last_updated_by,
                                        LAST_UPDATE_LOGIN          = l_last_update_login,
                                        QUANTITY                   = l_upd_qty_tab(m),
                                        INIT_QUANTITY              = l_upd_qty_tab(m),
        			        TXN_COST_RATE_OVERRIDE     = l_upd_cost_rate_override_tab(m), /* Bug 4071198 start */
        			        BURDEN_COST_RATE_OVERRIDE  = l_upd_bcost_rate_override_tab(m),
        			        TXN_BILL_RATE_OVERRIDE     = l_upd_bill_rate_override_tab(m) /* Bug 4071198 end */
                                    WHERE   budget_line_id             = l_bdgt_line_id_tab(m);
	                ELSE -- 'WP_APPLY_PROGRESS_TO_WORKING'
                            FORALL m in 1..l_upd_period_name_tab.count
                                UPDATE pa_budget_lines
                                    SET
                                        TXN_INIT_RAW_COST          = l_upd_txn_raw_cost_tab(m),
                                        TXN_INIT_BURDENED_COST     = l_upd_txn_burdened_cost_tab(m),
                                        TXN_INIT_REVENUE           = l_upd_txn_revenue_tab(m),
                                        PROJECT_INIT_RAW_COST      = l_upd_project_raw_cost_tab(m),
                                        PROJECT_INIT_BURDENED_COST = l_upd_proj_burdened_cost_tab(m),
                                        PROJECT_INIT_REVENUE       = l_upd_project_revenue_tab(m),
                                        INIT_RAW_COST              = l_upd_pfc_raw_cost_tab(m),
                                        INIT_BURDENED_COST         = l_upd_pfc_burdened_cost_tab(m),
                                        INIT_REVENUE               = l_upd_pfc_revenue_tab(m),
                                        TXN_RAW_COST               = l_upd_txn_raw_cost_tab(m),
                                        TXN_BURDENED_COST          = l_upd_txn_burdened_cost_tab(m),
                                        TXN_REVENUE                = l_upd_txn_revenue_tab(m),
                                        PROJECT_RAW_COST           = l_upd_project_raw_cost_tab(m),
                                        PROJECT_BURDENED_COST      = l_upd_proj_burdened_cost_tab(m),
                                        PROJECT_REVENUE            = l_upd_project_revenue_tab(m),
                                        RAW_COST                   = l_upd_pfc_raw_cost_tab(m),
                                        BURDENED_COST              = l_upd_pfc_burdened_cost_tab(m),
                                        REVENUE                    = l_upd_pfc_revenue_tab(m),
                                        LAST_UPDATE_DATE           = l_sysdate,
                                        LAST_UPDATED_BY            = l_last_updated_by,
                                        CREATION_DATE              = l_sysdate,
                                        CREATED_BY                 = l_last_updated_by,
                                        LAST_UPDATE_LOGIN          = l_last_update_login,
                                        QUANTITY                   = l_upd_qty_tab(m),
                                        INIT_QUANTITY              = l_upd_qty_tab(m),
				        TXN_STANDARD_COST_RATE     = l_upd_cost_rate_override_tab(m), /* Bug 4398799, 4071198 start */
				        BURDEN_COST_RATE           = l_upd_bcost_rate_override_tab(m),
				        TXN_STANDARD_BILL_RATE     = l_upd_bill_rate_override_tab(m) /* Bug 4398799, 4071198 end */
                                    WHERE   budget_line_id             = l_bdgt_line_id_tab(m);
	                END IF; -- calling context check (End Bug 4398799)

                    End If;  -- If l_time_phased_code = 'N'
                END IF;

            ELSIF (p_calling_context = 'WP_PROGRESS' OR
                   p_calling_context = 'WP_SUMMARIZED_ACTUAL') THEN

                IF P_EXTRACTION_TYPE  = 'INCREMENTAL' THEN
                    FORALL m in 1..l_upd_period_name_tab.count
                        UPDATE pa_budget_lines
                        SET
                            TXN_INIT_RAW_COST          = NVL(TXN_INIT_RAW_COST,0) + l_upd_txn_raw_cost_tab(m),
                            TXN_INIT_BURDENED_COST     = NVL(TXN_INIT_BURDENED_COST,0) + l_upd_txn_burdened_cost_tab(m),
                            TXN_INIT_REVENUE           = NVL(TXN_INIT_REVENUE,0) + l_upd_txn_revenue_tab(m),
                            PROJECT_INIT_RAW_COST      = NVL(PROJECT_INIT_RAW_COST,0) + l_upd_project_raw_cost_tab(m),
                            PROJECT_INIT_BURDENED_COST = NVL(PROJECT_INIT_BURDENED_COST,0) + l_upd_proj_burdened_cost_tab(m),
                            PROJECT_INIT_REVENUE       = NVL(PROJECT_INIT_REVENUE,0) + l_upd_project_revenue_tab(m),
                            INIT_RAW_COST              = NVL(INIT_RAW_COST,0) + l_upd_pfc_raw_cost_tab(m),
                            INIT_BURDENED_COST         = NVL(INIT_BURDENED_COST,0) + l_upd_pfc_burdened_cost_tab(m),
                            INIT_REVENUE               = NVL(INIT_REVENUE,0) + l_upd_pfc_revenue_tab(m),
                            LAST_UPDATE_DATE           = l_sysdate,
                            LAST_UPDATED_BY            = l_last_updated_by,
                            CREATION_DATE              = l_sysdate,
                            CREATED_BY                 = l_last_updated_by,
                            LAST_UPDATE_LOGIN          = l_last_update_login,
                            INIT_QUANTITY              = NVL(INIT_QUANTITY,0) + l_upd_qty_tab(m)
                        WHERE   budget_line_id         = l_bdgt_line_id_tab(m);
                ELSE
                    FORALL m in 1..l_upd_period_name_tab.count
                        UPDATE pa_budget_lines
                        SET
                            TXN_INIT_RAW_COST          = l_upd_txn_raw_cost_tab(m),
                            TXN_INIT_BURDENED_COST     = l_upd_txn_burdened_cost_tab(m),
                            TXN_INIT_REVENUE           = l_upd_txn_revenue_tab(m),
                            PROJECT_INIT_RAW_COST      = l_upd_project_raw_cost_tab(m),
                            PROJECT_INIT_BURDENED_COST = l_upd_proj_burdened_cost_tab(m),
                            PROJECT_INIT_REVENUE       = l_upd_project_revenue_tab(m),
                            INIT_RAW_COST              = l_upd_pfc_raw_cost_tab(m),
                            INIT_BURDENED_COST         = l_upd_pfc_burdened_cost_tab(m),
                            INIT_REVENUE               = l_upd_pfc_revenue_tab(m),
                            LAST_UPDATE_DATE           = l_sysdate,
                            LAST_UPDATED_BY            = l_last_updated_by,
                            CREATION_DATE              = l_sysdate,
                            CREATED_BY                 = l_last_updated_by,
                            LAST_UPDATE_LOGIN          = l_last_update_login,
                            INIT_QUANTITY              = l_upd_qty_tab(m)
                        WHERE   budget_line_id         = l_bdgt_line_id_tab(m);
                END IF;
            ELSIF p_txn_amt_type_code = 'PLANNING_TXN' THEN

                -- Bug 4292083: When the Target timephase is None, update the plan
                -- columns with total amounts (Actual + Planning_Txn).
                -- Assumptions:
                --   1) MAINTAIN_ACTUAL_AMT_RA is only called in the context of
                --      Forecast Generation
                --   2) When the Retain Manually Added Plan Lines option is enabled,
                --      this API is called with p_txn_amt_type_code = 'PLANNING_TXN'
                --      only for resources that are not manually added.

                IF l_time_phased_code = 'N' AND
                   p_calling_context  = 'FP_GEN_FCST_COPY_ACTUAL' THEN

                    -- ER 4376722: Changed the update logic as follows:
                    -- Before: Set amount = NVL(actual amount,0) + update amount.
                    -- After:  If actual amount is null, then set amount = update amount.
                    --         If actual amount is not null, then
                    --            set amount = actual amount + NVL(update amount, 0)
                    --         The new logic preserves the non-null actual amounts.
                    -- This change is necessary in case update revenue is Null. Using the
                    -- old logic, we would set revenue to NVL(actual revenue,0) + Null,
                    -- which is just Null. In other words, the actual revenue would be lost.
                    -- Using the new logic, we would set revenue to actual revenue +
                    -- NVL(NULL,0) = actual revenue.

                    FORALL m2 in 1..l_upd_period_name_tab.count
                        UPDATE pa_budget_lines
                        SET
                            TXN_RAW_COST               =
                                DECODE(TXN_INIT_RAW_COST, null, l_upd_txn_raw_cost_tab(m2),
                                       TXN_INIT_RAW_COST + NVL(l_upd_txn_raw_cost_tab(m2),0)),
                            TXN_BURDENED_COST          =
                                DECODE(TXN_INIT_BURDENED_COST, null, l_upd_txn_burdened_cost_tab(m2),
                                       TXN_INIT_BURDENED_COST + NVL(l_upd_txn_burdened_cost_tab(m2),0)),
                            TXN_REVENUE                =
                                DECODE(TXN_INIT_REVENUE, null, l_upd_txn_revenue_tab(m2),
                                       TXN_INIT_REVENUE + NVL(l_upd_txn_revenue_tab(m2),0)),
                            PROJECT_RAW_COST           =
                                DECODE(PROJECT_INIT_RAW_COST, null, l_upd_project_raw_cost_tab(m2),
                                       PROJECT_INIT_RAW_COST + NVL(l_upd_project_raw_cost_tab(m2),0)),
                            PROJECT_BURDENED_COST      =
                                DECODE(PROJECT_INIT_BURDENED_COST, null, l_upd_proj_burdened_cost_tab(m2),
                                       PROJECT_INIT_BURDENED_COST + NVL(l_upd_proj_burdened_cost_tab(m2),0)),
                            PROJECT_REVENUE            =
                                DECODE(PROJECT_INIT_REVENUE, null, l_upd_project_revenue_tab(m2),
                                       PROJECT_INIT_REVENUE + NVL(l_upd_project_revenue_tab(m2),0)),
                            RAW_COST                   =
                                DECODE(INIT_RAW_COST, null, l_upd_pfc_raw_cost_tab(m2),
                                       INIT_RAW_COST + NVL(l_upd_pfc_raw_cost_tab(m2),0)),
                            BURDENED_COST              =
                                DECODE(INIT_BURDENED_COST, null, l_upd_pfc_burdened_cost_tab(m2),
                                       INIT_BURDENED_COST + NVL(l_upd_pfc_burdened_cost_tab(m2),0)),
                            REVENUE                    =
                                DECODE(INIT_REVENUE, null, l_upd_pfc_revenue_tab(m2),
                                       INIT_REVENUE + NVL(l_upd_pfc_revenue_tab(m2),0)),
                            LAST_UPDATE_DATE           = l_sysdate,
                            LAST_UPDATED_BY            = l_last_updated_by,
                            CREATION_DATE              = l_sysdate,
                            CREATED_BY                 = l_last_updated_by,
                            LAST_UPDATE_LOGIN          = l_last_update_login,
                            QUANTITY                   =
                                DECODE(INIT_QUANTITY, null, l_upd_qty_tab(m2),
                                       INIT_QUANTITY + NVL(l_upd_qty_tab(m2),0)),
                            PROJFUNC_COST_RATE_TYPE    = l_projfunc_cost_rate_type_tab(m2),
                            PROJFUNC_REV_RATE_TYPE     = l_projfunc_rev_rate_type_tab(m2),
                            PROJECT_COST_RATE_TYPE     = l_project_cost_rate_type_tab(m2),
                            PROJECT_REV_RATE_TYPE      = l_project_rev_rate_type_tab(m2),
                            TXN_COST_RATE_OVERRIDE     = l_upd_cost_rate_override_tab(m2),
                            BURDEN_COST_RATE_OVERRIDE  = l_upd_bcost_rate_override_tab(m2),
                            TXN_BILL_RATE_OVERRIDE     = l_upd_bill_rate_override_tab(m2)
                            WHERE   budget_line_id     = l_bdgt_line_id_tab(m2);
                ELSE
                    FORALL m2 in 1..l_upd_period_name_tab.count
                        UPDATE pa_budget_lines
                        SET
                            TXN_RAW_COST               = l_upd_txn_raw_cost_tab(m2),
                            TXN_BURDENED_COST          = l_upd_txn_burdened_cost_tab(m2),
                            TXN_REVENUE                = l_upd_txn_revenue_tab(m2),
                            PROJECT_RAW_COST           = l_upd_project_raw_cost_tab(m2),
                            PROJECT_BURDENED_COST      = l_upd_proj_burdened_cost_tab(m2),
                            PROJECT_REVENUE            = l_upd_project_revenue_tab(m2),
                            RAW_COST                   = l_upd_pfc_raw_cost_tab(m2),
                            BURDENED_COST              = l_upd_pfc_burdened_cost_tab(m2),
                            REVENUE                    = l_upd_pfc_revenue_tab(m2),
                            LAST_UPDATE_DATE           = l_sysdate,
                            LAST_UPDATED_BY            = l_last_updated_by,
                            CREATION_DATE              = l_sysdate,
                            CREATED_BY                 = l_last_updated_by,
                            LAST_UPDATE_LOGIN          = l_last_update_login,
                            QUANTITY                   = l_upd_qty_tab(m2),
                            PROJFUNC_COST_RATE_TYPE    = l_projfunc_cost_rate_type_tab(m2),
                            PROJFUNC_REV_RATE_TYPE     = l_projfunc_rev_rate_type_tab(m2),
                            PROJECT_COST_RATE_TYPE     = l_project_cost_rate_type_tab(m2),
                            PROJECT_REV_RATE_TYPE      = l_project_rev_rate_type_tab(m2),
                            TXN_COST_RATE_OVERRIDE     = l_upd_cost_rate_override_tab(m2),
                            BURDEN_COST_RATE_OVERRIDE  = l_upd_bcost_rate_override_tab(m2),
                            TXN_BILL_RATE_OVERRIDE     = l_upd_bill_rate_override_tab(m2)
                            WHERE   budget_line_id     = l_bdgt_line_id_tab(m2);
                END IF; -- None timephase check

            END IF;
        END IF;

        /* dbms_output.put_line('Insert count when the ins_flag is null:
         '|| l_ins_period_name_tab.count);*/
        --Bulk Insert in PA_BUDGET_LINES table

        IF   l_ins_period_name_tab.count > 0 THEN
            IF (p_txn_amt_type_code = 'ACTUAL_TXN' AND
               (p_calling_context = 'WP_APPLY_PROGRESS_TO_WORKING'
               OR p_calling_context = 'FP_GEN_FCST_COPY_ACTUAL')) THEN

                l_bl_id_tab.delete;

                -- Bug 4398799: Split original INSERT statement into 2 separate INSERT
                -- statements based on p_calling_context. When p_calling_context is
                -- 'FP_GEN_FCST_COPY_ACTUAL', we continue populating the rate override
                -- columns. In the ELSE case, the context is 'WP_APPLY_PROGRESS_TO_WORKING'
                -- so we populate the standard rate columns instead. Everything else about
                -- the INSERT statements is unchanged.

                IF p_calling_context = 'FP_GEN_FCST_COPY_ACTUAL' THEN
                    FORALL n in 1..l_ins_period_name_tab.count
                    INSERT  INTO
                        PA_BUDGET_LINES(BUDGET_VERSION_ID,
                            RESOURCE_ASSIGNMENT_ID,
                            PERIOD_NAME,
                            START_DATE,
                            END_DATE,
                            TXN_CURRENCY_CODE,
                            TXN_INIT_RAW_COST,
                            TXN_INIT_BURDENED_COST,
                            TXN_INIT_REVENUE,
                            PROJECT_INIT_RAW_COST,
                            PROJECT_INIT_BURDENED_COST,
                            PROJECT_INIT_REVENUE,
                            INIT_RAW_COST,
                            INIT_BURDENED_COST,
                            INIT_REVENUE,
                            TXN_RAW_COST,
                            TXN_BURDENED_COST,
                            TXN_REVENUE,
                            PROJECT_RAW_COST,
                            PROJECT_BURDENED_COST,
                            PROJECT_REVENUE,
                            RAW_COST,
                            BURDENED_COST,
                            REVENUE,
                            BUDGET_LINE_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            INIT_QUANTITY,
                            project_currency_code,
                            projfunc_currency_code,
                            QUANTITY,
                            TXN_COST_RATE_OVERRIDE, /* Bug 4071198 */
                            BURDEN_COST_RATE_OVERRIDE,
                            TXN_BILL_RATE_OVERRIDE ) /* Bug 4071198 */
                    VALUES(p_budget_version_id,
                            p_resource_assignment_id,
                            l_ins_period_name_tab(n),
                            l_ins_start_date_tab(n),
                            l_ins_end_date_tab(n),
                            p_txn_currency_code,
                            l_ins_txn_raw_cost_tab(n),
                            l_ins_txn_burdened_cost_tab(n),
                            l_ins_txn_revenue_tab(n),
                            l_ins_project_raw_cost_tab(n),
                            l_ins_proj_burdened_cost_tab(n),
                            l_ins_project_revenue_tab(n),
                            l_ins_pfc_raw_cost_tab(n),
                            l_ins_pfc_burdened_cost_tab(n),
                            l_ins_pfc_revenue_tab(n),
                            l_ins_txn_raw_cost_tab(n),
                            l_ins_txn_burdened_cost_tab(n),
                            l_ins_txn_revenue_tab(n),
                            l_ins_project_raw_cost_tab(n),
                            l_ins_proj_burdened_cost_tab(n),
                            l_ins_project_revenue_tab(n),
                            l_ins_pfc_raw_cost_tab(n),
                            l_ins_pfc_burdened_cost_tab(n),
                            l_ins_pfc_revenue_tab(n),
                            PA_BUDGET_LINES_S.nextval,
                            l_sysdate,
                            l_last_updated_by,
                            l_sysdate,
                            l_last_updated_by,
                            l_last_update_login,
                            l_ins_qty_tab(n),
                            l_pc_code,
                            l_pfc_code,
                            l_ins_qty_tab(n) ,
                            l_ins_cost_rate_override_tab(n), /* Bug 4071198 */
                            l_ins_bcost_rate_override_tab(n), /* Bug 4071198 */
                            l_ins_bill_rate_override_tab(n))   /* Bug 4071198 */
                            RETURNING budget_line_id
                            BULK COLLECT INTO l_bl_id_tab;
                ELSE -- 'WP_APPLY_PROGRESS_TO_WORKING'
                    FORALL n in 1..l_ins_period_name_tab.count
                    INSERT  INTO
                        PA_BUDGET_LINES(BUDGET_VERSION_ID,
                            RESOURCE_ASSIGNMENT_ID,
                            PERIOD_NAME,
                            START_DATE,
                            END_DATE,
                            TXN_CURRENCY_CODE,
                            TXN_INIT_RAW_COST,
                            TXN_INIT_BURDENED_COST,
                            TXN_INIT_REVENUE,
                            PROJECT_INIT_RAW_COST,
                            PROJECT_INIT_BURDENED_COST,
                            PROJECT_INIT_REVENUE,
                            INIT_RAW_COST,
                            INIT_BURDENED_COST,
                            INIT_REVENUE,
                            TXN_RAW_COST,
                            TXN_BURDENED_COST,
                            TXN_REVENUE,
                            PROJECT_RAW_COST,
                            PROJECT_BURDENED_COST,
                            PROJECT_REVENUE,
                            RAW_COST,
                            BURDENED_COST,
                            REVENUE,
                            BUDGET_LINE_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            INIT_QUANTITY,
                            project_currency_code,
                            projfunc_currency_code,
                            QUANTITY,
                            TXN_STANDARD_COST_RATE,  /* Bug 4398799, 4071198 */
                            BURDEN_COST_RATE,        /* Bug 4398799, 4071198 */
                            TXN_STANDARD_BILL_RATE ) /* Bug 4398799, 4071198 */
                    VALUES(p_budget_version_id,
                            p_resource_assignment_id,
                            l_ins_period_name_tab(n),
                            l_ins_start_date_tab(n),
                            l_ins_end_date_tab(n),
                            p_txn_currency_code,
                            l_ins_txn_raw_cost_tab(n),
                            l_ins_txn_burdened_cost_tab(n),
                            l_ins_txn_revenue_tab(n),
                            l_ins_project_raw_cost_tab(n),
                            l_ins_proj_burdened_cost_tab(n),
                            l_ins_project_revenue_tab(n),
                            l_ins_pfc_raw_cost_tab(n),
                            l_ins_pfc_burdened_cost_tab(n),
                            l_ins_pfc_revenue_tab(n),
                            l_ins_txn_raw_cost_tab(n),
                            l_ins_txn_burdened_cost_tab(n),
                            l_ins_txn_revenue_tab(n),
                            l_ins_project_raw_cost_tab(n),
                            l_ins_proj_burdened_cost_tab(n),
                            l_ins_project_revenue_tab(n),
                            l_ins_pfc_raw_cost_tab(n),
                            l_ins_pfc_burdened_cost_tab(n),
                            l_ins_pfc_revenue_tab(n),
                            PA_BUDGET_LINES_S.nextval,
                            l_sysdate,
                            l_last_updated_by,
                            l_sysdate,
                            l_last_updated_by,
                            l_last_update_login,
                            l_ins_qty_tab(n),
                            l_pc_code,
                            l_pfc_code,
                            l_ins_qty_tab(n) ,
                            l_ins_cost_rate_override_tab(n), /* Bug 4071198 */
                            l_ins_bcost_rate_override_tab(n), /* Bug 4071198 */
                            l_ins_bill_rate_override_tab(n))   /* Bug 4071198 */
                            RETURNING budget_line_id
                            BULK COLLECT INTO l_bl_id_tab;
                END IF; -- calling context check (End Bug 4398799)

            ELSIF (p_calling_context = 'WP_PROGRESS' OR
                   p_calling_context = 'WP_SUMMARIZED_ACTUAL') THEN
                l_bl_id_tab.delete;
                FORALL n in 1..l_ins_period_name_tab.count
                    INSERT  INTO
                        PA_BUDGET_LINES(BUDGET_VERSION_ID,
                            RESOURCE_ASSIGNMENT_ID,
                            PERIOD_NAME,
                            START_DATE,
                            END_DATE,
                            TXN_CURRENCY_CODE,
                            TXN_INIT_RAW_COST,
                            TXN_INIT_BURDENED_COST,
                            TXN_INIT_REVENUE,
                            PROJECT_INIT_RAW_COST,
                            PROJECT_INIT_BURDENED_COST,
                            PROJECT_INIT_REVENUE,
                            INIT_RAW_COST,
                            INIT_BURDENED_COST,
                            INIT_REVENUE,
                            BUDGET_LINE_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            INIT_QUANTITY,
                            project_currency_code,
                            projfunc_currency_code)
                     VALUES(p_budget_version_id,
                            p_resource_assignment_id,
                            l_ins_period_name_tab(n),
                            l_ins_start_date_tab(n),
                            l_ins_end_date_tab(n),
                            p_txn_currency_code,
                            l_ins_txn_raw_cost_tab(n),
                            l_ins_txn_burdened_cost_tab(n),
                            l_ins_txn_revenue_tab(n),
                            l_ins_project_raw_cost_tab(n),
                            l_ins_proj_burdened_cost_tab(n),
                            l_ins_project_revenue_tab(n),
                            l_ins_pfc_raw_cost_tab(n),
                            l_ins_pfc_burdened_cost_tab(n),
                            l_ins_pfc_revenue_tab(n),
                            PA_BUDGET_LINES_S.nextval,
                            l_sysdate,
                            l_last_updated_by,
                            l_sysdate,
                            l_last_updated_by,
                            l_last_update_login,
                            l_ins_qty_tab(n),
                            l_pc_code,
                            l_pfc_code );
            ELSIF p_txn_amt_type_code = 'PLANNING_TXN' THEN
                l_bl_id_tab.delete;
                FORALL n2 in 1..l_ins_period_name_tab.count
                    INSERT  INTO
                        PA_BUDGET_LINES(BUDGET_VERSION_ID,
                            RESOURCE_ASSIGNMENT_ID,
                            PERIOD_NAME,
                            START_DATE,
                            END_DATE,
                            TXN_CURRENCY_CODE,
                            TXN_RAW_COST,
                            TXN_BURDENED_COST,
                            TXN_REVENUE,
                            PROJECT_RAW_COST,
                            PROJECT_BURDENED_COST,
                            PROJECT_REVENUE,
                            RAW_COST,
                            BURDENED_COST,
                            REVENUE,
                            BUDGET_LINE_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            QUANTITY,
                            project_currency_code,
                            projfunc_currency_code,
                            PROJFUNC_COST_RATE_TYPE,
                            PROJFUNC_REV_RATE_TYPE,
                            PROJECT_COST_RATE_TYPE,
                            PROJECT_REV_RATE_TYPE,
                            TXN_COST_RATE_OVERRIDE,
                            BURDEN_COST_RATE_OVERRIDE,
                            TXN_BILL_RATE_OVERRIDE )
                    VALUES(p_budget_version_id,
                            p_resource_assignment_id,
                            l_ins_period_name_tab(n2),
                            l_ins_start_date_tab(n2),
                            l_ins_end_date_tab(n2),
                            p_txn_currency_code,
                            l_ins_txn_raw_cost_tab(n2),
                            l_ins_txn_burdened_cost_tab(n2),
                            l_ins_txn_revenue_tab(n2),
                            l_ins_project_raw_cost_tab(n2),
                            l_ins_proj_burdened_cost_tab(n2),
                            l_ins_project_revenue_tab(n2),
                            l_ins_pfc_raw_cost_tab(n2),
                            l_ins_pfc_burdened_cost_tab(n2),
                            l_ins_pfc_revenue_tab(n2),
                            PA_BUDGET_LINES_S.nextval,
                            l_sysdate,
                            l_last_updated_by,
                            l_sysdate,
                            l_last_updated_by,
                            l_last_update_login,
                            l_ins_qty_tab(n2),
                            l_pc_code,
                            l_pfc_code,
                            l_projfunc_cost_rate_type_tab(n2),
                            l_projfunc_rev_rate_type_tab(n2),
                            l_project_cost_rate_type_tab(n2),
                            l_project_rev_rate_type_tab(n2),
                            l_ins_cost_rate_override_tab(n2),
                            l_ins_bcost_rate_override_tab(n2),
                            l_ins_bill_rate_override_tab(n2))
                            RETURNING budget_line_id
                            BULK COLLECT INTO l_bl_id_tab;
            END IF;
        END IF;
    END IF;

    /* if the spread curve is Fixed Date then there should be only one
      budget line for the planning resource for the txn currency and
      period name combination. If we are going to collect actuals for
      more than one period then the spread curve and the SP_fixed_date
      column should be nulled out. - msoundra  */
    l_spread_curve_code := 'dummy';
    /* If the spread curve is Even then spread_curve_id
       and sp_fixed_date are nullified in res asg table */
    BEGIN
        -- Bug 4699248: Modified the SELECT statement below to use the
        -- 'pa_spread_curves_b' table instead of 'pa_spread_curves_tl'.
        -- As a result, the query fetches the spread curve code instead
        -- of the spread curve name for the given resource.

        SELECT   ra.spread_curve_id,t.spread_curve_code
        INTO     l_spread_curve_id,l_spread_curve_code
        FROM     pa_resource_assignments ra,pa_spread_curves_b t
        WHERE    ra.resource_assignment_id = p_resource_assignment_id
        AND      ra.spread_curve_id = t.spread_curve_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_spread_curve_code := 'dummy';
    END;

    -- Bug 4699248: Modified the IF statement below to check for
    -- the value 'FIXED_DATE' instead of 'Fixed Date'.

    IF  l_spread_curve_code = 'FIXED_DATE' THEN
        --Getting the number of budget lines for the given res_asg_id and txn_curr_code
        SELECT   count(*)
        INTO     l_multi_bdgt_lines
        FROM     pa_budget_lines
        WHERE    resource_assignment_id = p_resource_assignment_id
        AND      txn_currency_code = p_txn_currency_code;

        --Need to update res asg table if there are multiple budget lines
        IF   l_multi_bdgt_lines > 1 THEN
            UPDATE  pa_resource_assignments
            SET     spread_curve_id = NULL,
                    sp_fixed_date   = NULL
            WHERE   resource_assignment_id = p_resource_assignment_id;
        END IF;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Bug 4621171: Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_MAINTAIN_ACTUAL_PUB',
                     p_procedure_name  => 'MAINTAIN_ACTUAL_AMT_RA',
                     p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_called_mode => p_calling_mode,
                     p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                     p_module_name => l_module_name,
                     p_log_level   => 5);
             PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END MAINTAIN_ACTUAL_AMT_RA;


/**
 * This procedure synchs up planning dates for target resources in the
 * pa_resource_assignments table based upon the p_calling_context parameter.
 *
 * Valid P_CALLING_CONTEXT values are
 *     'SYNC_VERSION_LEVEL'
 *     'COPY_ACTUALS'
 *     'GEN_COMMITMENTS'
 *     'GEN_BILLING_EVENTS'
 *
 * Following are descriptions for how this procedure behaves in each context.
 *
 * SYNC_VERSION_LEVEL : This is the Default context. All target resources are
 *                      included in this operation. For a given resource, if
 *                      the minimum budget line start date is prior to the
 *                      planning start date period, set the planning start date
 *                      to the minimum budget line start date. If the maximum
 *                      budget line end date is after the planning end date
 *                      period, set the planning end date to the maximum budget
 *                      line end date.When the target is None timpehased, then
 *                      compare the min/max budget line dates directly with the
 *                      planning start/end dates (instead of their periods).
 *
 * COPY_ACTUALS       : Has the same behavior as SYNC_VERSION_LEVEL, with the
 *                      exception that only target resources with actuals are
 *                      considered for synching. The pji_fm_xbs_accum_tmp1
 *                      table should be populated before calling this procedure.
 *
 * GEN_COMMITMENTS    : Target resources with commitments are considered.
 *                      The temp table pa_res_list_map_tmp4 must be populated.
 *                      Please see the Technical Design for details:
 *
 *                      http://files.oraclecorp.com/content/MySharedFolders/
 *                      Projects%20Development%20-%20Projects/30.Family%20Pack
 *                      %20M/Budgeting%20and%20Forecasting/3.0%20Design/
 *                      Functional%20Design/B%26F%20Code%20Changes%20After
 *                      %20Oct%2031st/
 *
 * GEN_BILLING_EVENTS : Has the same behavior as GEN_COMMITMENTS, with the
 *                      exception that only target resources with billing
 *                      events are considered for synching.
 */
PROCEDURE SYNC_UP_PLANNING_DATES
     (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
      P_CALLING_CONTEXT         IN          VARCHAR2,
      X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY  NUMBER,
      X_MSG_DATA                OUT NOCOPY  VARCHAR2) IS

l_module_name  VARCHAR2(200) := 'pa.plsql.pa_fp_maintain_actual_pub.sync_up_planning_dates';

l_fp_cols_rec                  PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

/* Cursors for Version Level sync by target time phase */

CURSOR all_tgt_res_dates_pa_cursor IS
    SELECT  bl.resource_assignment_id,
            ra.planning_start_date,
            ra.planning_end_date,
            start_pd.start_date,
            end_pd.end_date,
            min(bl.start_date),
            max(bl.end_date)
    FROM    pa_resource_assignments ra,
            pa_budget_versions bv,                       -- Added for Perf Bug 4469690
            pa_budget_lines bl,
            pa_periods_all start_pd,
            pa_periods_all end_pd
    WHERE   ra.resource_assignment_id = bl.resource_assignment_id
    AND     ra.budget_version_id = bv.budget_version_id  -- Added for Perf Bug 4469690
    AND     ra.project_id = bv.project_id                -- Added for Perf Bug 4469690
    AND     bv.budget_version_id = p_budget_version_id   -- Added for Perf Bug 4469690
    AND     start_pd.org_id = l_fp_cols_rec.x_org_id
    AND     end_pd.org_id = l_fp_cols_rec.x_org_id
    AND     ra.planning_start_date between start_pd.start_date and start_pd.end_date
    AND     ra.planning_end_date between end_pd.start_date and end_pd.end_date
    GROUP BY bl.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date,
             start_pd.start_date,
             end_pd.end_date;

CURSOR all_tgt_res_dates_gl_cursor IS
    SELECT  bl.resource_assignment_id,
            ra.planning_start_date,
            ra.planning_end_date,
            start_pd.start_date,
            end_pd.end_date,
            min(bl.start_date),
            max(bl.end_date)
    FROM    pa_resource_assignments ra,
            pa_budget_versions bv,                       -- Added for Perf Bug 4469690
            pa_budget_lines bl,
            gl_period_statuses start_pd,
            gl_period_statuses end_pd
    WHERE   ra.resource_assignment_id = bl.resource_assignment_id
    AND     ra.budget_version_id = bv.budget_version_id  -- Added for Perf Bug 4469690
    AND     ra.project_id = bv.project_id                -- Added for Perf Bug 4469690
    AND     bv.budget_version_id = p_budget_version_id   -- Added for Perf Bug 4469690
    AND     start_pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
    AND     start_pd.set_of_books_id = l_fp_cols_rec.x_set_of_books_id
    AND     start_pd.adjustment_period_flag = 'N'
    AND     end_pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
    AND     end_pd.set_of_books_id = l_fp_cols_rec.x_set_of_books_id
    AND     end_pd.adjustment_period_flag = 'N'
    AND     ra.planning_start_date between start_pd.start_date and start_pd.end_date
    AND     ra.planning_end_date between end_pd.start_date and end_pd.end_date
    GROUP BY bl.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date,
             start_pd.start_date,
             end_pd.end_date;

CURSOR all_tgt_res_dates_none_cursor IS
    SELECT  bl.resource_assignment_id,
            ra.planning_start_date,
            ra.planning_end_date,
            ra.planning_start_date,
            ra.planning_end_date,
            min(bl.start_date),
            max(bl.end_date)
    FROM    pa_resource_assignments ra,
            pa_budget_versions bv,                       -- Added for Perf Bug 4469690
            pa_budget_lines bl
    WHERE   ra.resource_assignment_id = bl.resource_assignment_id
    AND     ra.budget_version_id = bv.budget_version_id  -- Added for Perf Bug 4469690
    AND     ra.project_id = bv.project_id                -- Added for Perf Bug 4469690
    AND     bv.budget_version_id = p_budget_version_id   -- Added for Perf Bug 4469690
    GROUP BY bl.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date;

/* Added new cursor for work plan non time phased version
   planning dates sync up -  bug 4408930 */

CURSOR all_tgt_res_dates_none_wp IS
    SELECT  ra.resource_assignment_id,
            ra.planning_start_date,
            ra.planning_end_date,
            ra.planning_start_date,
            ra.planning_end_date,
            min(t.start_date),
            max(t.finish_date)
    FROM    pa_resource_assignments ra,
            PA_PROG_ACT_BY_PERIOD_TEMP t
    WHERE   ra.resource_assignment_id =
            nvl(t.resource_assignment_id,t.HIDDEN_RES_ASSGN_ID)
    AND     ra.budget_version_id = p_budget_version_id
    GROUP BY ra.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date;


/* Cursors for synching Actuals by target time phase */

CURSOR actuals_dates_pa_cursor IS
    SELECT  bl.resource_assignment_id,
            ra.planning_start_date,
            ra.planning_end_date,
            start_pd.start_date,
            end_pd.end_date,
            min(bl.start_date),
            max(bl.end_date)
    FROM    pa_resource_assignments ra,
            pa_budget_versions bv,                       -- Added for Perf Bug 4469690
            pa_budget_lines bl,
            pji_fm_xbs_accum_tmp1 pji_tmp,
            pa_periods_all start_pd,
            pa_periods_all end_pd
    WHERE   ra.resource_assignment_id = bl.resource_assignment_id
    AND     ra.budget_version_id = bv.budget_version_id  -- Added for Perf Bug 4469690
    AND     ra.project_id = bv.project_id                -- Added for Perf Bug 4469690
    AND     bv.budget_version_id = p_budget_version_id   -- Added for Perf Bug 4469690
    AND     ra.resource_assignment_id = pji_tmp.source_id
    AND     start_pd.org_id = l_fp_cols_rec.x_org_id
    AND     end_pd.org_id = l_fp_cols_rec.x_org_id
    AND     ra.planning_start_date between start_pd.start_date and start_pd.end_date
    AND     ra.planning_end_date between end_pd.start_date and end_pd.end_date
    GROUP BY bl.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date,
             start_pd.start_date,
             end_pd.end_date;

CURSOR actuals_dates_gl_cursor IS
    SELECT  bl.resource_assignment_id,
            ra.planning_start_date,
            ra.planning_end_date,
            start_pd.start_date,
            end_pd.end_date,
            min(bl.start_date),
            max(bl.end_date)
    FROM    pa_resource_assignments ra,
            pa_budget_versions bv,                       -- Added for Perf Bug 4469690
            pa_budget_lines bl,
            pji_fm_xbs_accum_tmp1 pji_tmp,
            gl_period_statuses start_pd,
            gl_period_statuses end_pd
    WHERE   ra.resource_assignment_id = bl.resource_assignment_id
    AND     ra.budget_version_id = bv.budget_version_id  -- Added for Perf Bug 4469690
    AND     ra.project_id = bv.project_id                -- Added for Perf Bug 4469690
    AND     bv.budget_version_id = p_budget_version_id   -- Added for Perf Bug 4469690
    AND     ra.resource_assignment_id = pji_tmp.source_id
    AND     start_pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
    AND     start_pd.set_of_books_id = l_fp_cols_rec.x_set_of_books_id
    AND     start_pd.adjustment_period_flag = 'N'
    AND     end_pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
    AND     end_pd.set_of_books_id = l_fp_cols_rec.x_set_of_books_id
    AND     end_pd.adjustment_period_flag = 'N'
    AND     ra.planning_start_date between start_pd.start_date and start_pd.end_date
    AND     ra.planning_end_date between end_pd.start_date and end_pd.end_date
    GROUP BY bl.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date,
             start_pd.start_date,
             end_pd.end_date;

CURSOR actuals_dates_none_cursor IS
    SELECT  bl.resource_assignment_id,
            ra.planning_start_date,
            ra.planning_end_date,
            ra.planning_start_date,
            ra.planning_end_date,
            min(bl.start_date),
            max(bl.end_date)
    FROM    pa_resource_assignments ra,
            pa_budget_versions bv,                       -- Added for Perf Bug 4469690
            pa_budget_lines bl,
            pji_fm_xbs_accum_tmp1 pji_tmp
    WHERE   ra.resource_assignment_id = bl.resource_assignment_id
    AND     ra.budget_version_id = bv.budget_version_id  -- Added for Perf Bug 4469690
    AND     ra.project_id = bv.project_id                -- Added for Perf Bug 4469690
    AND     bv.budget_version_id = p_budget_version_id   -- Added for Perf Bug 4469690
    AND     ra.resource_assignment_id = pji_tmp.source_id
    GROUP BY bl.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date;

/* Cursor for synching Commitments and Billing Events */

CURSOR cmt_bill_event_dates_cursor IS
    SELECT   /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/
             ra.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date,
             MIN(tmp.txn_planning_start_date),
             MAX(tmp.txn_planning_end_date)
    FROM     pa_res_list_map_tmp4 tmp,
             pa_resource_assignments ra
    WHERE    ra.resource_assignment_id = tmp.txn_resource_assignment_id
    AND      ra.budget_version_id = p_budget_version_id
    GROUP BY ra.resource_assignment_id,
             ra.planning_start_date,
             ra.planning_end_date;

l_res_asg_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_plan_start_date_tab          PA_PLSQL_DATATYPES.DateTabTyp;
l_plan_end_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
l_plan_period_start_date_tab   PA_PLSQL_DATATYPES.DateTabTyp;
l_plan_period_end_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
l_min_start_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;
l_max_end_date_tab             PA_PLSQL_DATATYPES.DateTabTyp;

l_end_date_upd_val_tab         PA_PLSQL_DATATYPES.DateTabTyp;

l_upd_flag                     VARCHAR2(1);
l_start_date                   DATE;
l_end_date                     DATE;
l_count                        NUMBER := 1;

l_upd_res_asg_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;
l_upd_start_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;
l_upd_end_date_tab             PA_PLSQL_DATATYPES.DateTabTyp;

lc_SyncVersion        CONSTANT VARCHAR2(30) := 'SYNC_VERSION_LEVEL';
lc_CopyActuals        CONSTANT VARCHAR2(30) := 'COPY_ACTUALS';
lc_Commitments        CONSTANT VARCHAR2(30) := 'GEN_COMMITMENTS';
lc_BillingEvents      CONSTANT VARCHAR2(30) := 'GEN_BILLING_EVENTS';

l_plan_class_code              PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE;
l_etc_start_date               PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE;
l_etc_start_period_end_date    DATE;

l_wp_version_flag pa_budget_versions.wp_version_flag%TYPE;

BEGIN
    /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function     => 'SYNC_UP_PLANNING_DATES',
              p_debug_mode   =>  p_pa_debug_mode );
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Before calling ' ||
                               'PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    /* Calling UTIL API to get target financial plan info l_fp_cols_rec */
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
        ( P_BUDGET_VERSION_ID  => p_budget_version_id,
          X_FP_COLS_REC        => l_fp_cols_rec,
          X_RETURN_STATUS      => x_return_status,
          X_MSG_COUNT          => x_msg_count,
          X_MSG_DATA           => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Status after calling ' ||
                               'PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                               ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    SELECT NVL(wp_version_flag,'N') INTO l_wp_version_flag FROM
    pa_budget_versions WHERE budget_version_id = p_budget_version_id;


    /* Fetch the planning dates and min/max dates for planning resources
     * based on p_calling_context and target time phase. */

    IF p_calling_context = lc_SyncVersion THEN

        IF l_fp_cols_rec.x_time_phased_code = 'P' THEN
            OPEN all_tgt_res_dates_pa_cursor;
            FETCH all_tgt_res_dates_pa_cursor
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_plan_start_date_tab,
                 l_plan_end_date_tab,
                 l_plan_period_start_date_tab,
                 l_plan_period_end_date_tab,
                 l_min_start_date_tab,
                 l_max_end_date_tab;
            CLOSE all_tgt_res_dates_pa_cursor;
        ELSIF l_fp_cols_rec.x_time_phased_code = 'G' THEN
            OPEN all_tgt_res_dates_gl_cursor;
            FETCH all_tgt_res_dates_gl_cursor
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_plan_start_date_tab,
                 l_plan_end_date_tab,
                 l_plan_period_start_date_tab,
                 l_plan_period_end_date_tab,
                 l_min_start_date_tab,
                 l_max_end_date_tab;
            CLOSE all_tgt_res_dates_gl_cursor;
        ELSIF l_fp_cols_rec.x_time_phased_code = 'N' THEN
            IF l_wp_version_flag = 'N' THEN
               OPEN all_tgt_res_dates_none_cursor;
               FETCH all_tgt_res_dates_none_cursor
               BULK COLLECT
               INTO l_res_asg_id_tab,
                    l_plan_start_date_tab,
                    l_plan_end_date_tab,
                    l_plan_period_start_date_tab,
                    l_plan_period_end_date_tab,
                    l_min_start_date_tab,
                    l_max_end_date_tab;
               CLOSE all_tgt_res_dates_none_cursor;
            ELSE
               OPEN all_tgt_res_dates_none_wp;
               FETCH all_tgt_res_dates_none_wp
               BULK COLLECT
               INTO l_res_asg_id_tab,
                    l_plan_start_date_tab,
                    l_plan_end_date_tab,
                    l_plan_period_start_date_tab,
                    l_plan_period_end_date_tab,
                    l_min_start_date_tab,
                    l_max_end_date_tab;
               CLOSE all_tgt_res_dates_none_wp;
            END IF;
        END IF;

    ELSIF p_calling_context = lc_CopyActuals THEN

        IF l_fp_cols_rec.x_time_phased_code = 'P' THEN
            OPEN actuals_dates_pa_cursor;
            FETCH actuals_dates_pa_cursor
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_plan_start_date_tab,
                 l_plan_end_date_tab,
                 l_plan_period_start_date_tab,
                 l_plan_period_end_date_tab,
                 l_min_start_date_tab,
                 l_max_end_date_tab;
            CLOSE actuals_dates_pa_cursor;
        ELSIF l_fp_cols_rec.x_time_phased_code = 'G' THEN
            OPEN actuals_dates_gl_cursor;
            FETCH actuals_dates_gl_cursor
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_plan_start_date_tab,
                 l_plan_end_date_tab,
                 l_plan_period_start_date_tab,
                 l_plan_period_end_date_tab,
                 l_min_start_date_tab,
                 l_max_end_date_tab;
            CLOSE actuals_dates_gl_cursor;
        ELSIF l_fp_cols_rec.x_time_phased_code = 'N' THEN
            OPEN actuals_dates_none_cursor;
            FETCH actuals_dates_none_cursor
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_plan_start_date_tab,
                 l_plan_end_date_tab,
                 l_plan_period_start_date_tab,
                 l_plan_period_end_date_tab,
                 l_min_start_date_tab,
                 l_max_end_date_tab;
            CLOSE actuals_dates_none_cursor;
        END IF;

    ELSIF p_calling_context = lc_Commitments OR
          p_calling_context = lc_BillingEvents THEN

        OPEN cmt_bill_event_dates_cursor;
        FETCH cmt_bill_event_dates_cursor
        BULK COLLECT
        INTO l_res_asg_id_tab,
             l_plan_start_date_tab,
             l_plan_end_date_tab,
             l_min_start_date_tab,
             l_max_end_date_tab;
        CLOSE cmt_bill_event_dates_cursor;

    END IF; -- end of data fetching logic

    IF l_res_asg_id_tab.count = 0 THEN
       IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
       END IF;
       RETURN;
    END IF;

    /* The following block determines which resource assignment dates
     * need to be synched and what the new planning date should be. */

    IF p_calling_context = lc_SyncVersion OR
       p_calling_context = lc_CopyActuals THEN

        FOR i IN 1..l_res_asg_id_tab.count LOOP
            l_upd_flag  := 'N';
            l_start_date := l_plan_start_date_tab(i);
            l_end_date   := l_plan_end_date_tab(i);
            IF l_min_start_date_tab(i) < l_plan_period_start_date_tab(i) THEN
               l_upd_flag   := 'Y';
               l_start_date := l_min_start_date_tab(i);
	       --Bug 5672100. Added this block to make sure that the planning dates and budget line
               --dates are one and same for non-time phased workplan versions
               ELSIF l_fp_cols_rec.x_time_phased_code = 'N' AND
                  l_wp_version_flag = 'Y' AND
                  l_min_start_date_tab(i) > l_plan_period_start_date_tab(i) THEN
               l_upd_flag   := 'Y';
               l_start_date := l_plan_period_start_date_tab(i);
            END IF;
            IF l_max_end_date_tab(i) > l_plan_period_end_date_tab(i) THEN
               l_upd_flag  := 'Y';
               l_end_date  := l_max_end_date_tab(i);
	       --Bug 5672100. Added this block to make sure that the planning dates and budget line
               --dates are one and same for non-time phased workplan versions
               ELSIF l_fp_cols_rec.x_time_phased_code = 'N' AND
                  l_wp_version_flag = 'Y' AND
                  l_max_end_date_tab(i) < l_plan_period_end_date_tab(i) THEN
               l_upd_flag  := 'Y';
               l_end_date  := l_plan_period_end_date_tab(i);
            END IF;
            IF l_upd_flag  = 'Y' THEN
               l_upd_res_asg_id_tab(l_count) := l_res_asg_id_tab(i);
               l_upd_start_date_tab(l_count) := l_start_date;
               l_upd_end_date_tab(l_count)   := l_end_date;
               l_count := l_count + 1;
            END IF;
        END LOOP;

    ELSIF p_calling_context = lc_Commitments OR
          p_calling_context = lc_BillingEvents THEN

        /* Default the values for l_end_date_upd_val_tab so that values
         * will be correct when the target is not a Forecast or when
         * the target is a Forecast but the max end date is less than
         * the ETC start date. */
        FOR i IN 1..l_res_asg_id_tab.count LOOP
            l_end_date_upd_val_tab(i) := l_max_end_date_tab(i);
        END LOOP;

        l_plan_class_code := l_fp_cols_rec.x_plan_class_code;

        IF l_plan_class_code = 'FORECAST' THEN
            l_etc_start_date := PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE
                                    ( l_fp_cols_rec.x_budget_version_id );
        END IF;

        IF l_plan_class_code = 'FORECAST' AND l_etc_start_date IS NOT NULL THEN

            /* Get the periodic end date for the ETC start date period. */
            l_etc_start_period_end_date := l_etc_start_date;
            IF l_fp_cols_rec.x_time_phased_code = 'P' THEN
                SELECT pd.end_date
                INTO   l_etc_start_period_end_date
                FROM   pa_periods_all pd
                WHERE  pd.org_id = l_fp_cols_rec.x_org_id
                AND    l_etc_start_date between pd.start_date and pd.end_date;
            ELSIF l_fp_cols_rec.x_time_phased_code = 'G' THEN
                SELECT pd.end_date
                INTO   l_etc_start_period_end_date
                FROM   gl_period_statuses pd
                WHERE  pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
                AND    pd.set_of_books_id = l_fp_cols_rec.x_set_of_books_id
                AND    pd.adjustment_period_flag = 'N'
                AND    l_etc_start_date between pd.start_date and pd.end_date;
            END IF;

            FOR i IN 1..l_res_asg_id_tab.count LOOP
                IF l_min_start_date_tab(i) < l_etc_start_date THEN
                    l_min_start_date_tab(i) := l_etc_start_date;
                END IF;
                IF l_max_end_date_tab(i) < l_etc_start_date THEN
                    l_max_end_date_tab(i) := l_etc_start_date;
                    l_end_date_upd_val_tab(i) := l_etc_start_period_end_date;
                END IF;
            END LOOP;
        END IF;

        FOR i IN 1..l_res_asg_id_tab.count LOOP
            l_upd_flag  := 'N';
            l_start_date := l_plan_start_date_tab(i);
            l_end_date   := l_plan_end_date_tab(i);
            IF l_min_start_date_tab(i) < l_plan_start_date_tab(i) THEN
               l_upd_flag   := 'Y';
               l_start_date := l_min_start_date_tab(i);
            END IF;
            /* Although we compare using l_max_end_date_tab, we set the
             * end date based on the update value pl/sql table. This is done
             * to handle the Forecast case when both the planning end date
             * and max commitment / billing event date fall before the ETC
             * start date and we need to set the planning end date to the
             * last day of the ETC start date period. */
            IF l_max_end_date_tab(i) > l_plan_end_date_tab(i) THEN
               l_upd_flag  := 'Y';
               l_end_date  := l_end_date_upd_val_tab(i);
            END IF;
            IF l_upd_flag  = 'Y' THEN
               l_upd_res_asg_id_tab(l_count) := l_res_asg_id_tab(i);
               l_upd_start_date_tab(l_count) := l_start_date;
               l_upd_end_date_tab(l_count)   := l_end_date;
               l_count := l_count + 1;
            END IF;
        END LOOP;

    END IF; -- end populating update pl/sql tables

    /* Update synched planning dates in the db. */
    FORALL m IN 1..l_upd_res_asg_id_tab.count
        UPDATE pa_resource_assignments
        SET    planning_start_date    = l_upd_start_date_tab(m),
               planning_end_date      = l_upd_end_date_tab(m)
        WHERE  resource_assignment_id = l_upd_res_asg_id_tab(m);

    /* bug 4408930 */

    IF l_fp_cols_rec.x_time_phased_code = 'N' AND
       l_wp_version_flag = 'Y' THEN
       FORALL m IN 1..l_upd_res_asg_id_tab.count
       UPDATE pa_budget_lines
       SET    start_date    = l_upd_start_date_tab(m),
              end_date      = l_upd_end_date_tab(m)
       WHERE  resource_assignment_id = l_upd_res_asg_id_tab(m);
    END IF;

    /* bug 4408930 */

    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Bug 4621171: Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_MAINTAIN_ACTUAL_PUB',
                     p_procedure_name  => 'SYNC_UP_PLANNING_DATES',
                     p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                     p_module_name => l_module_name,
                     p_log_level   => 5);
             PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SYNC_UP_PLANNING_DATES;

/** Valid values for parameter P_ENTIRE_VERSION_FLAG:
  *     'N': not for entire version, will update reporting lines only for the passes*
  *          resource assignments.                                                  *
  *     'Y': for entire version, will update reporting lines for all resource       *
  *          assignments for the passed budget version id without looking into      *
  *          p_res_asg_id_tab.                                                      *
  * Valid values for parameter  P_ACTIVITY_CODE:                                    *
  *     'UPDATE': update reporting lines                                            *
  *     'DELETE': delete reporting lines                                            *
 **/
PROCEDURE BLK_UPD_REPORTING_LINES_WRP
     (P_BUDGET_VERSION_ID      IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
      P_ENTIRE_VERSION_FLAG    IN          VARCHAR2,
      P_RES_ASG_ID_TAB         IN          PA_PLSQL_DATATYPES.IDTABTYP,
      P_ACTIVITY_CODE          IN          VARCHAR2,
      X_RETURN_STATUS          OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT              OUT NOCOPY  NUMBER,
      X_MSG_DATA               OUT NOCOPY  VARCHAR2) IS

l_module_name  VARCHAR2(200) := 'pa.plsql.pa_fp_maintain_actual_pub.blk_upd_reporting_lines_wrp';

l_rep_budget_line_id_tab        SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_res_assignment_id_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_start_date_tab            SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_rep_end_date_tab              SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_rep_period_name_tab           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_rep_txn_curr_code_tab         SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
l_rep_quantity_tab              SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_txn_raw_cost_tab          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_txn_burdened_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_txn_revenue_tab           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_project_curr_code_tab     SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
l_rep_project_raw_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_project_burden_cost_tab   SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_project_revenue_tab       SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_projfunc_curr_code_tab    SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
l_rep_projfunc_raw_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_projfunc_burden_cost_tab  SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_projfunc_revenue_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
/*
 * Following _act_ variables to hold Actual amounts.
 */
l_rep_act_quantity_tab          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_txn_act_raw_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_txn_act_burd_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_txn_act_rev_tab           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_prj_act_raw_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_prj_act_burd_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_prj_act_rev_tab           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_pf_act_raw_cost_tab       SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_pf_act_burd_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_rep_pf_act_rev_tab            SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();

l_msg_count                 NUMBER;
l_data                      VARCHAR2(2000);
l_msg_data                  VARCHAR2(2000);
l_msg_index_out             NUMBER;

BEGIN
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function     => 'BLK_UPD_REPORTING_LINES_WRP',
              p_debug_mode   =>  p_pa_debug_mode );
    END IF;

    l_rep_budget_line_id_tab.delete;
    l_rep_res_assignment_id_tab.delete;
    l_rep_start_date_tab.delete;
    l_rep_end_date_tab.delete;
    l_rep_period_name_tab.delete;
    l_rep_txn_curr_code_tab.delete;
    l_rep_quantity_tab.delete;
    l_rep_txn_raw_cost_tab.delete;
    l_rep_txn_burdened_cost_tab.delete;
    l_rep_txn_revenue_tab.delete;
    l_rep_project_curr_code_tab.delete;
    l_rep_project_raw_cost_tab.delete;
    l_rep_project_burden_cost_tab.delete;
    l_rep_project_revenue_tab.delete;
    l_rep_projfunc_curr_code_tab.delete;
    l_rep_projfunc_raw_cost_tab.delete;
    l_rep_projfunc_burden_cost_tab.delete;
    l_rep_projfunc_revenue_tab.delete;

    l_rep_act_quantity_tab.delete;
    l_rep_txn_act_raw_cost_tab.delete;
    l_rep_txn_act_burd_cost_tab.delete;
    l_rep_txn_act_rev_tab.delete;
    l_rep_prj_act_raw_cost_tab.delete;
    l_rep_prj_act_burd_cost_tab.delete;
    l_rep_prj_act_rev_tab.delete;
    l_rep_pf_act_raw_cost_tab.delete;
    l_rep_pf_act_burd_cost_tab.delete;
    l_rep_pf_act_rev_tab.delete;

    IF P_ENTIRE_VERSION_FLAG = 'Y' THEN
        SELECT  budget_line_id,
                resource_assignment_id,
                start_date,
                end_date,
                period_name,
                txn_currency_code,
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * quantity,
                       'UPDATE', quantity),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * txn_raw_cost,
                       'UPDATE', txn_raw_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * txn_burdened_cost,
                       'UPDATE', txn_burdened_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * txn_revenue,
                       'UPDATE', txn_revenue),
                project_currency_code,
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * project_raw_cost,
                       'UPDATE', project_raw_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * project_burdened_cost,
                       'UPDATE', project_burdened_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * project_revenue,
                       'UPDATE', project_revenue),
                projfunc_currency_code,
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * raw_cost,
                       'UPDATE', raw_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * burdened_cost,
                       'UPDATE', burdened_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * revenue,
                       'UPDATE', revenue)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * init_quantity,
                       'UPDATE', init_quantity)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * txn_init_raw_cost,
                       'UPDATE', txn_init_raw_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * txn_init_burdened_cost,
                       'UPDATE', txn_init_burdened_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * txn_init_revenue,
                       'UPDATE', txn_init_revenue)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * project_init_raw_cost,
                       'UPDATE', project_init_raw_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * project_init_burdened_cost,
                       'UPDATE', project_init_burdened_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * project_init_revenue,
                       'UPDATE', project_init_revenue)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * init_raw_cost,
                       'UPDATE', init_raw_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * init_burdened_cost,
                       'UPDATE', init_burdened_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * init_revenue,
                       'UPDATE', init_revenue)
        BULK COLLECT INTO
                l_rep_budget_line_id_tab,
                l_rep_res_assignment_id_tab,
                l_rep_start_date_tab,
                l_rep_end_date_tab,
                l_rep_period_name_tab,
                l_rep_txn_curr_code_tab,
                l_rep_quantity_tab,
                l_rep_txn_raw_cost_tab,
                l_rep_txn_burdened_cost_tab,
                l_rep_txn_revenue_tab,
                l_rep_project_curr_code_tab,
                l_rep_project_raw_cost_tab,
                l_rep_project_burden_cost_tab,
                l_rep_project_revenue_tab,
                l_rep_projfunc_curr_code_tab,
                l_rep_projfunc_raw_cost_tab,
                l_rep_projfunc_burden_cost_tab,
                l_rep_projfunc_revenue_tab
               ,l_rep_act_quantity_tab
               ,l_rep_txn_act_raw_cost_tab
               ,l_rep_txn_act_burd_cost_tab
               ,l_rep_txn_act_rev_tab
               ,l_rep_prj_act_raw_cost_tab
               ,l_rep_prj_act_burd_cost_tab
               ,l_rep_prj_act_rev_tab
               ,l_rep_pf_act_raw_cost_tab
               ,l_rep_pf_act_burd_cost_tab
               ,l_rep_pf_act_rev_tab
        FROM pa_budget_lines
        WHERE budget_version_id = P_BUDGET_VERSION_ID;
    ELSE
        DELETE FROM pa_fp_calc_amt_tmp1;
        FORALL i IN 1..p_res_asg_id_tab.count
            INSERT INTO pa_fp_calc_amt_tmp1 (resource_assignment_id)
            VALUES (p_res_asg_id_tab(i));

        SELECT  /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP1_N2)*/
                bl.budget_line_id,
                bl.resource_assignment_id,
                bl.start_date,
                bl.end_date,
                bl.period_name,
                bl.txn_currency_code,
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.quantity,
                       'UPDATE', bl.quantity),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.txn_raw_cost,
                       'UPDATE', bl.txn_raw_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.txn_burdened_cost,
                       'UPDATE', bl.txn_burdened_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.txn_revenue,
                       'UPDATE', bl.txn_revenue),
                project_currency_code,
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.project_raw_cost,
                       'UPDATE', bl.project_raw_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.project_burdened_cost,
                       'UPDATE', bl.project_burdened_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.project_revenue,
                       'UPDATE', bl.project_revenue),
                bl.projfunc_currency_code,
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.raw_cost,
                       'UPDATE', bl.raw_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.burdened_cost,
                       'UPDATE', bl.burdened_cost),
                DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.revenue,
                       'UPDATE', bl.revenue)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.init_quantity,
                       'UPDATE', bl.init_quantity)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.txn_init_raw_cost,
                       'UPDATE', bl.txn_init_raw_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.txn_init_burdened_cost,
                       'UPDATE', bl.txn_init_burdened_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.txn_init_revenue,
                       'UPDATE', bl.txn_init_revenue)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.project_init_raw_cost,
                       'UPDATE', bl.project_init_raw_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.project_init_burdened_cost,
                       'UPDATE', bl.project_init_burdened_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.project_init_revenue,
                       'UPDATE', bl.project_init_revenue)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.init_raw_cost,
                       'UPDATE', bl.init_raw_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.init_burdened_cost,
                       'UPDATE', bl.init_burdened_cost)
               ,DECODE(P_ACTIVITY_CODE,
                       'DELETE', (-1) * bl.init_revenue,
                       'UPDATE', bl.init_revenue)
        BULK COLLECT INTO
                l_rep_budget_line_id_tab,
                l_rep_res_assignment_id_tab,
                l_rep_start_date_tab,
                l_rep_end_date_tab,
                l_rep_period_name_tab,
                l_rep_txn_curr_code_tab,
                l_rep_quantity_tab,
                l_rep_txn_raw_cost_tab,
                l_rep_txn_burdened_cost_tab,
                l_rep_txn_revenue_tab,
                l_rep_project_curr_code_tab,
                l_rep_project_raw_cost_tab,
                l_rep_project_burden_cost_tab,
                l_rep_project_revenue_tab,
                l_rep_projfunc_curr_code_tab,
                l_rep_projfunc_raw_cost_tab,
                l_rep_projfunc_burden_cost_tab,
                l_rep_projfunc_revenue_tab
               ,l_rep_act_quantity_tab
               ,l_rep_txn_act_raw_cost_tab
               ,l_rep_txn_act_burd_cost_tab
               ,l_rep_txn_act_rev_tab
               ,l_rep_prj_act_raw_cost_tab
               ,l_rep_prj_act_burd_cost_tab
               ,l_rep_prj_act_rev_tab
               ,l_rep_pf_act_raw_cost_tab
               ,l_rep_pf_act_burd_cost_tab
               ,l_rep_pf_act_rev_tab
        FROM pa_budget_lines bl, pa_fp_calc_amt_tmp1 tmp
        WHERE bl.budget_version_id = P_BUDGET_VERSION_ID
          AND bl.resource_assignment_id = tmp.resource_assignment_id;
    END IF;

    IF l_rep_budget_line_id_tab.count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Before calling pa_fp_pji_intg_pkg.ublk_update_reporting_lines',
                 p_module_name => l_module_name,
                 p_log_level   => 5);
    END IF;
    PA_FP_PJI_INTG_PKG.BLK_UPDATE_REPORTING_LINES
        (p_calling_module                => 'MAINTAIN_ACTUAL_AMT_RA_API'
        ,p_activity_code                 => p_activity_code
        ,p_budget_version_id             => p_budget_version_id
        ,p_rep_budget_line_id_tab        => l_rep_budget_line_id_tab
        ,p_rep_res_assignment_id_tab     => l_rep_res_assignment_id_tab
        ,p_rep_start_date_tab            => l_rep_start_date_tab
        ,p_rep_end_date_tab              => l_rep_end_date_tab
        ,p_rep_period_name_tab           => l_rep_period_name_tab
        ,p_rep_txn_curr_code_tab         => l_rep_txn_curr_code_tab
        ,p_rep_quantity_tab              => l_rep_quantity_tab
        ,p_rep_txn_raw_cost_tab          => l_rep_txn_raw_cost_tab
        ,p_rep_txn_burdened_cost_tab     => l_rep_txn_burdened_cost_tab
        ,p_rep_txn_revenue_tab           => l_rep_txn_revenue_tab
        ,p_rep_project_curr_code_tab     => l_rep_project_curr_code_tab
        ,p_rep_project_raw_cost_tab      => l_rep_project_raw_cost_tab
        ,p_rep_project_burden_cost_tab   => l_rep_project_burden_cost_tab
        ,p_rep_project_revenue_tab       => l_rep_project_revenue_tab
        ,p_rep_projfunc_curr_code_tab    => l_rep_projfunc_curr_code_tab
        ,p_rep_projfunc_raw_cost_tab     => l_rep_projfunc_raw_cost_tab
        ,p_rep_projfunc_burden_cost_tab  => l_rep_projfunc_burden_cost_tab
        ,p_rep_projfunc_revenue_tab      => l_rep_projfunc_revenue_tab
        ,p_rep_act_quantity_tab          => l_rep_act_quantity_tab
        ,p_rep_txn_act_raw_cost_tab      => l_rep_txn_act_raw_cost_tab
        ,p_rep_txn_act_burd_cost_tab     => l_rep_txn_act_burd_cost_tab
        ,p_rep_txn_act_rev_tab           => l_rep_txn_act_rev_tab
        ,p_rep_prj_act_raw_cost_tab      => l_rep_prj_act_raw_cost_tab
        ,p_rep_prj_act_burd_cost_tab     => l_rep_prj_act_burd_cost_tab
        ,p_rep_prj_act_rev_tab           => l_rep_prj_act_rev_tab
        ,p_rep_pf_act_raw_cost_tab       => l_rep_pf_act_raw_cost_tab
        ,p_rep_pf_act_burd_cost_tab      => l_rep_pf_act_burd_cost_tab
        ,p_rep_pf_act_rev_tab            => l_rep_pf_act_rev_tab
        ,x_msg_data                      => x_msg_data
        ,x_msg_count                     => x_msg_count
        ,x_return_status                 => x_return_status );
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Status after calling
                                   pa_fp_pji_intg_pkg.blk_update_reporting_lines:'
                                  ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Curr_Function;
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
        -- Bug 4621171: Removed ROLLBACK statement.

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Invalid Arguments Passed',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        -- Bug 4621171: Removed RAISE statement.
    WHEN OTHERS THEN
        -- Bug 4621171: Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_MAINTAIN_ACTUAL_PUB',
                     p_procedure_name  => 'BLK_UPD_REPORTING_LINES_WRP',
                     p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                     p_module_name => l_module_name,
                     p_log_level   => 5);
             PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END BLK_UPD_REPORTING_LINES_WRP;

PROCEDURE SYNC_UP_PLANNING_DATES_NONE_TP
     (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
      P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
      X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT               OUT NOCOPY  NUMBER,
      X_MSG_DATA                OUT NOCOPY  VARCHAR2) IS

l_module_name  VARCHAR2(200) := 'pa.plsql.pa_fp_maintain_actual_pub.SYNC_UP_PLANNING_DATES_NONE_TP';

l_res_asg_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_planning_start_date_tab       pa_plsql_datatypes.DateTabTyp;
l_planning_end_date_tab         pa_plsql_datatypes.DateTabTyp;
l_budget_line_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_min_start_date                DATE ;
l_max_end_date                  DATE;

l_dummy                         NUMBER;

l_msg_count                     NUMBER;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;

l_etc_start_date                DATE;
l_sum_init_quantity             NUMBER;
l_sum_plan_quantity             NUMBER;
l_etc_quantity                  NUMBER;

l_upd_index                     NUMBER;
l_upd_res_asg_id_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_upd_planning_start_date_tab   pa_plsql_datatypes.DateTabTyp;
l_upd_planning_end_date_tab     pa_plsql_datatypes.DateTabTyp;
BEGIN
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function     => 'SYNC_UP_PLANNING_DATES_NONE_TP',
              p_debug_mode   =>  p_pa_debug_mode );
    END IF;

    SELECT resource_assignment_id,
           planning_start_date,
           planning_end_date
    BULK COLLECT INTO
           l_res_asg_id_tab,
           l_planning_start_date_tab,
           l_planning_end_date_tab
    FROM pa_resource_assignments
    WHERE budget_version_id = P_BUDGET_VERSION_ID;

    IF l_res_asg_id_tab.count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    IF p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
        l_etc_start_date :=
            PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE(p_budget_version_id);
    END IF;

    l_upd_index := 0;

    FOR i IN 1..l_res_asg_id_tab.count LOOP
        SELECT budget_line_id
        BULK COLLECT INTO
               l_budget_line_id_tab
        FROM pa_budget_lines
        WHERE resource_assignment_id = l_res_asg_id_tab(i);

        IF l_budget_line_id_tab.count = 0 THEN
            l_dummy := 0;
        ELSE
            SELECT MIN(start_date),
                   MAX(end_date),
                   SUM(NVL(init_quantity,0)),
                   SUM(NVL(quantity,0))
              INTO l_min_start_date,
                   l_max_end_date,
                   l_sum_init_quantity,
                   l_sum_plan_quantity
            FROM pa_budget_lines
            WHERE resource_assignment_id = l_res_asg_id_tab(i);

            -- Bug 4217917: If the Context is Forecast Generation and a resource
            -- has ETC but the Planning End Date falls prior to the ETC Start Date,
            -- then we should set the Planning End Date to the ETC Start Date.

            IF p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
                l_etc_quantity := l_sum_plan_quantity - l_sum_init_quantity;
                -- ER 5726773: Instead of requiring l_etc_quantity be positive,
 	        -- relax the condition to ensure it is non-zero.
 	        IF l_etc_quantity <> 0 AND l_max_end_date < l_etc_start_date THEN
                    l_max_end_date := l_etc_start_date;
                END IF;
            END IF;

            FORALL j IN 1..l_budget_line_id_tab.count
                UPDATE pa_budget_lines
                SET    start_date = l_min_start_date,
                       end_date = l_max_end_date
                WHERE budget_line_id = l_budget_line_id_tab(j);

            IF l_planning_start_date_tab(i) <> l_min_start_date OR
               l_planning_end_date_tab(i) <> l_max_end_date THEN
		l_upd_index := l_upd_index + 1;
		l_upd_res_asg_id_tab(l_upd_index) := l_res_asg_id_tab(i);
		l_upd_planning_start_date_tab(l_upd_index) := l_min_start_date;
		l_upd_planning_end_date_tab(l_upd_index) := l_max_end_date;
            END IF;
        END IF;
    END LOOP;

    FORALL i IN 1..l_upd_res_asg_id_tab.count
        UPDATE pa_resource_assignments
        SET    planning_start_date = l_upd_planning_start_date_tab(i),
               planning_end_date = l_upd_planning_end_date_tab(i)
        WHERE  resource_assignment_id = l_upd_res_asg_id_tab(i);

    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Curr_Function;
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
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        rollback;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_MAINTAIN_ACTUAL_PUB',
                     p_procedure_name  => 'SYNC_UP_PLANNING_DATES_NONE_TP',
                     p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                     p_module_name => l_module_name,
                     p_log_level   => 5);
             PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SYNC_UP_PLANNING_DATES_NONE_TP;


END PA_FP_MAINTAIN_ACTUAL_PUB;

/
