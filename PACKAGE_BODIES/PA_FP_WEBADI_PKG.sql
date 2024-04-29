--------------------------------------------------------
--  DDL for Package Body PA_FP_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_WEBADI_PKG" as
/* $Header: PAFPWAPB.pls 120.47.12010000.6 2009/12/24 22:05:38 snizam ship $ */

Validation_Failed_Exc Exception ;
BV_Validation_Failed_Exc Exception; -- Exception to be used if the validation fails at version level

g_module_name  VARCHAR2(100) := 'pa.plsql.pa_fp_webadi_pkg';
--wlog           varchar2(1):='Y';

-- Bug 3986129: FP.M Web ADI Dev changes. Added the following exceptions
Bv_Period_Mask_Changed_Exc     EXCEPTION;
No_Bv_Maint_Previlege_Exc      EXCEPTION;
Bv_Non_Editable_Exc            EXCEPTION;
Co_Ver_Non_Editable_Exc        EXCEPTION;
Bv_Not_Curr_Working_Exc        EXCEPTION;
Ci_Ver_Sumbit_Flag_Exc         EXCEPTION;
Fp_Webadi_Skip_Dup_Rec_Exc     EXCEPTION;
Fp_Webadi_Skip_Rec_Proc_Exc    EXCEPTION;
Fp_Webadi_Skip_Next_Rec_Exc    EXCEPTION;
No_Bv_Dtls_Found_Exc           EXCEPTION; --Bug 4584865.


TYPE varchar_70_indexed_num_tbl_typ IS TABLE OF NUMBER INDEX BY VARCHAR2(70);
TYPE varchar_32_indexed_num_tbl_typ IS TABLE OF NUMBER INDEX BY VARCHAR2(32);

-- local variables to simulate fnd_api.g_miss_xxx
      l_fnd_miss_char                    CONSTANT      VARCHAR(1) := FND_API.G_MISS_CHAR;
      l_fnd_miss_num                     CONSTANT      NUMBER     := FND_API.G_MISS_NUM;
      l_fnd_miss_date                    CONSTANT      DATE       := FND_API.G_MISS_DATE;

      --These variables will contain the values that will be inserted into the interface table when the
      --corresponding columns in the layout are hidden. These values are default values given in table
      --creation script
      g_hidden_col_num                   CONSTANT      NUMBER     := 9.99E125;
      g_hidden_col_date                  CONSTANT      DATE       := TO_DATE('1','j');
      g_hidden_col_char                  CONSTANT      VARCHAR2(1):= chr(0);

      /* Bug 5144013: Made changes to the cursor to refer override rates from the interface table and
         made changes in change_reason derivation. This is done as part of merging the MRUP3 changes
         done in 11i into R12.
      */
      CURSOR inf_tbl_data_csr
      (c_run_id                         pa_fp_webadi_upload_inf.run_id%TYPE,
       c_allow_qty_flag                 VARCHAR2,
       c_allow_raw_cost_flag            VARCHAR2,
       c_allow_burd_cost_flag           VARCHAR2,
       c_allow_revenue_flag             VARCHAR2,
       c_allow_raw_cost_rate_flag       VARCHAR2,
       c_allow_burd_cost_rate_flag      VARCHAR2,
       c_allow_bill_rate_flag           VARCHAR2,
       c_project_id                     pa_projects_all.project_id%TYPE,
       c_fin_plan_type_id               pa_fin_plan_types_b.fin_plan_type_id%TYPE,
       c_version_type                   pa_budget_versions.version_type%TYPE,
       c_request_id                     pa_budget_versions.request_id%TYPE
      )
      IS
      SELECT  inf.budget_version_id budget_version_id,
              inf.resource_list_member_id resource_list_member_id,
              inf.task_id task_id,
              inf.amount_type_code amount_type_code,
              inf.txn_currency_code txn_currency_code,
              DECODE (inf.delete_flag, g_hidden_col_char, 'N', DECODE(inf.delete_flag, 'Y', 'Y', 'N')) delete_flag,
              DECODE (inf.planning_start_date, g_hidden_col_date, TO_DATE(NULL), inf.planning_start_date) planning_start_date,
              DECODE (inf.planning_end_date, g_hidden_col_date, TO_DATE(NULL), inf.planning_end_date) planning_end_date,
              '-99' unit_of_measure,
              DECODE (inf.description, g_hidden_col_char, NULL, DECODE(inf.description, NULL, l_fnd_miss_char, inf.description)) description,
              DECODE (inf.change_reason_code, g_hidden_col_char, NULL,
                                              'MULTIPLE', NULL,
                                               NULL,l_fnd_miss_char,
                                               inf.change_reason_code) change_reason,
              DECODE (c_allow_qty_flag,'N',NULL,
                     DECODE (inf.quantity, g_hidden_col_num, NULL, DECODE(inf.quantity, NULL, l_fnd_miss_num, inf.quantity))) quantity,
              DECODE (c_allow_qty_flag,'N',NULL,
                     DECODE (inf.etc_quantity, g_hidden_col_num, NULL, DECODE(inf.etc_quantity, NULL, l_fnd_miss_num, inf.etc_quantity))) etc_quantity,
              DECODE (c_allow_raw_cost_flag,'N',NULL,
                     DECODE (inf.raw_cost, g_hidden_col_num, NULL, DECODE(inf.raw_cost, NULL, l_fnd_miss_num, inf.raw_cost))) raw_cost,
              DECODE (c_allow_raw_cost_flag,'N',NULL,
                     DECODE (inf.etc_raw_cost, g_hidden_col_num, NULL, DECODE(inf.etc_raw_cost, NULL, l_fnd_miss_num, inf.etc_raw_cost))) etc_raw_cost,
              DECODE (c_allow_raw_cost_rate_flag,'N',NULL,
                     DECODE (inf.raw_cost_over_rate, g_hidden_col_num, NULL, DECODE(inf.raw_cost_over_rate, NULL, l_fnd_miss_num, inf.raw_cost_over_rate))) raw_cost_rate,
              DECODE (c_allow_burd_cost_flag,'N',NULL,
                     DECODE (inf.burdened_cost, g_hidden_col_num, NULL, DECODE(inf.burdened_cost, NULL, l_fnd_miss_num, inf.burdened_cost))) burdened_cost,
              DECODE (c_allow_burd_cost_flag,'N',NULL,
                     DECODE (inf.etc_burdened_cost, g_hidden_col_num, NULL, DECODE(inf.etc_burdened_cost, NULL, l_fnd_miss_num, inf.etc_burdened_cost))) etc_burdened_cost,
              DECODE (c_allow_burd_cost_rate_flag,'N',NULL,
                     DECODE (inf.burdened_cost_over_rate, g_hidden_col_num, NULL, DECODE(inf.burdened_cost_over_rate, NULL, l_fnd_miss_num, inf.burdened_cost_over_rate))) burdened_cost_rate,
              DECODE (c_allow_revenue_flag,'N',NULL,
                     DECODE (inf.revenue, g_hidden_col_num, NULL, DECODE(inf.revenue, NULL, l_fnd_miss_num, inf.revenue))) revenue,
              DECODE (c_allow_revenue_flag,'N',NULL,
                     DECODE (inf.etc_revenue, g_hidden_col_num, NULL, DECODE(inf.etc_revenue, NULL, l_fnd_miss_num, inf.etc_revenue))) etc_revenue,
              DECODE (c_allow_bill_rate_flag,'N',NULL,
                  DECODE (inf.bill_over_rate, g_hidden_col_num, NULL, DECODE(inf.bill_over_rate, NULL, l_fnd_miss_num, inf.bill_over_rate))) bill_rate,
              DECODE (c_version_type, 'REVENUE', NULL,
                      DECODE(inf.projfunc_cost_rate_type, g_hidden_col_char, NULL, DECODE(inf.projfunc_cost_rate_type, NULL, l_fnd_miss_char, inf.projfunc_cost_rate_type))) projfunc_cost_rate_type,
              DECODE (c_version_type, 'REVENUE', NULL,
                      DECODE(inf.projfunc_cost_rate_date_type, g_hidden_col_char, NULL, DECODE(inf.projfunc_cost_rate_date_type, NULL, l_fnd_miss_char, inf.projfunc_cost_rate_date_type))) projfunc_cost_rate_date_type,
              DECODE (c_version_type, 'REVENUE', NULL,
                      DECODE(inf.projfunc_cost_exchange_rate, g_hidden_col_num, NULL, DECODE(inf.projfunc_cost_exchange_rate, NULL, l_fnd_miss_num, inf.projfunc_cost_exchange_rate))) projfunc_cost_exchange_rate,
              DECODE (c_version_type, 'REVENUE', TO_DATE(NULL),
                      DECODE(inf.projfunc_cost_rate_date, g_hidden_col_date, TO_DATE(NULL), DECODE(inf.projfunc_cost_rate_date, NULL, l_fnd_miss_date, inf.projfunc_cost_rate_date))) projfunc_cost_rate_date,
              DECODE (c_version_type, 'REVENUE', NULL,
                      DECODE(inf.project_cost_rate_type, g_hidden_col_char, NULL, DECODE(inf.project_cost_rate_type, NULL, l_fnd_miss_char, inf.project_cost_rate_type))) project_cost_rate_type,
              DECODE (c_version_type, 'REVENUE', NULL,
                      DECODE(inf.project_cost_rate_date_type, g_hidden_col_char, NULL, DECODE(inf.project_cost_rate_date_type, NULL, l_fnd_miss_char, inf.project_cost_rate_date_type))) project_cost_rate_date_type,
              DECODE (c_version_type, 'REVENUE', NULL,
                      DECODE(inf.project_cost_exchange_rate, g_hidden_col_num, NULL, DECODE(inf.project_cost_exchange_rate, NULL, l_fnd_miss_num, inf.project_cost_exchange_rate))) project_cost_exchange_rate,
              DECODE (c_version_type, 'REVENUE', TO_DATE(NULL),
                      DECODE(inf.project_cost_rate_date, g_hidden_col_date, TO_DATE(NULL), DECODE(inf.project_cost_rate_date, NULL, l_fnd_miss_date, inf.project_cost_rate_date))) project_cost_rate_date,
              DECODE (c_version_type, 'COST', NULL,
                      DECODE(inf.projfunc_rev_rate_type, g_hidden_col_char, NULL, DECODE(inf.projfunc_rev_rate_type, NULL, l_fnd_miss_char, inf.projfunc_rev_rate_type))) projfunc_rev_rate_type,
              DECODE (c_version_type, 'COST', NULL,
                      DECODE(inf.projfunc_rev_rate_date_type, g_hidden_col_char, NULL, DECODE(inf.projfunc_rev_rate_date_type, NULL, l_fnd_miss_char, inf.projfunc_rev_rate_date_type))) projfunc_rev_rate_date_type,
              DECODE (c_version_type, 'COST', NULL,
                      DECODE(inf.projfunc_rev_exchange_rate, g_hidden_col_num, NULL, DECODE(inf.projfunc_rev_exchange_rate, NULL, l_fnd_miss_num, inf.projfunc_rev_exchange_rate))) projfunc_rev_exchange_rate,
              DECODE (c_version_type, 'COST', TO_DATE(NULL),
                      DECODE(inf.projfunc_rev_rate_date, g_hidden_col_date, TO_DATE(NULL), DECODE(inf.projfunc_rev_rate_date, NULL, l_fnd_miss_date, inf.projfunc_rev_rate_date))) projfunc_rev_rate_date,
              DECODE (c_version_type, 'COST', NULL,
                      DECODE(inf.project_rev_rate_type, g_hidden_col_char, NULL, DECODE(inf.project_rev_rate_type, NULL, l_fnd_miss_char, inf.project_rev_rate_type))) project_rev_rate_type,
              DECODE (c_version_type, 'COST', NULL,
                      DECODE(inf.project_rev_rate_date_type, g_hidden_col_char, NULL, DECODE(inf.project_rev_rate_date_type, NULL, l_fnd_miss_char, inf.project_rev_rate_date_type))) project_rev_rate_date_type,
              DECODE (c_version_type, 'COST', NULL,
                      DECODE(inf.project_rev_exchange_rate, g_hidden_col_num, NULL, DECODE(inf.project_rev_exchange_rate, NULL, l_fnd_miss_num, inf.project_rev_exchange_rate))) project_rev_exchange_rate,
              DECODE (c_version_type, 'COST', TO_DATE(NULL),
                      DECODE(inf.project_rev_rate_date, g_hidden_col_date, TO_DATE(NULL), DECODE(inf.project_rev_rate_date, NULL, l_fnd_miss_date, inf.project_rev_rate_date))) project_rev_rate_date,
              DECODE (inf.projfunc_rate_type, g_hidden_col_char, NULL, DECODE(inf.projfunc_rate_type, NULL, l_fnd_miss_char, inf.projfunc_rate_type)) projfunc_rate_type,
              DECODE (inf.projfunc_rate_date_type, g_hidden_col_char, NULL, DECODE(inf.projfunc_rate_date_type, NULL, l_fnd_miss_char, inf.projfunc_rate_date_type)) projfunc_rate_date_type,
              DECODE (inf.projfunc_exchange_rate, g_hidden_col_num, NULL, DECODE(inf.projfunc_exchange_rate, NULL, l_fnd_miss_num, inf.projfunc_exchange_rate)) projfunc_exchange_rate,
              DECODE (inf.projfunc_rate_date, g_hidden_col_date, TO_DATE(NULL), DECODE(inf.projfunc_rate_date, NULL, l_fnd_miss_date, inf.projfunc_rate_date)) projfunc_rate_date,
              DECODE (inf.project_rate_type, g_hidden_col_char, NULL, DECODE(inf.project_rate_type, NULL, l_fnd_miss_char, inf.project_rate_type)) project_rate_type,
              DECODE (inf.project_rate_date_type, g_hidden_col_char, NULL, DECODE(inf.project_rate_date_type, NULL, l_fnd_miss_char, inf.project_rate_date_type)) project_rate_date_type,
              DECODE (inf.project_exchange_rate, g_hidden_col_num, NULL, DECODE(inf.project_exchange_rate, NULL, l_fnd_miss_num, inf.project_exchange_rate)) project_exchange_rate,
              DECODE (inf.project_rate_date, g_hidden_col_date, TO_DATE(NULL), DECODE(inf.project_rate_date, NULL, l_fnd_miss_date, inf.project_rate_date)) project_rate_date,
              --DECODE (inf.spread_curve_id, g_hidden_col_char, NULL, DECODE(inf.spread_curve_name, NULL, l_fnd_miss_char, inf.spread_curve_name))
              '-99' spread_curve_name,
              --DECODE (inf.etc_method_name, g_hidden_col_char, NULL, DECODE(inf.etc_method_name, NULL, l_fnd_miss_char, inf.etc_method_name))
              '-99' etc_method_name,
              --DECODE (inf.mfc_cost_type_name, g_hidden_col_char, NULL, DECODE(inf.mfc_cost_type_name, NULL, l_fnd_miss_char, inf.mfc_cost_type_name))
              '-99' mfc_cost_type_name,
              DECODE (inf.pd_prd, g_hidden_col_num, NULL, DECODE(inf.pd_prd, NULL, l_fnd_miss_num, inf.pd_prd)) pd_prd,
              DECODE (inf.prd1, g_hidden_col_num, NULL, DECODE(inf.prd1, NULL, l_fnd_miss_num, inf.prd1)) prd1,
              DECODE (inf.prd2, g_hidden_col_num, NULL, DECODE(inf.prd2, NULL, l_fnd_miss_num, inf.prd2)) prd2,
              DECODE (inf.prd3, g_hidden_col_num, NULL, DECODE(inf.prd3, NULL, l_fnd_miss_num, inf.prd3)) prd3,
              DECODE (inf.prd4, g_hidden_col_num, NULL, DECODE(inf.prd4, NULL, l_fnd_miss_num, inf.prd4)) prd4,
              DECODE (inf.prd5, g_hidden_col_num, NULL, DECODE(inf.prd5, NULL, l_fnd_miss_num, inf.prd5)) prd5,
              DECODE (inf.prd6, g_hidden_col_num, NULL, DECODE(inf.prd6, NULL, l_fnd_miss_num, inf.prd6)) prd6,
              DECODE (inf.prd7, g_hidden_col_num, NULL, DECODE(inf.prd7, NULL, l_fnd_miss_num, inf.prd7)) prd7,
              DECODE (inf.prd8, g_hidden_col_num, NULL, DECODE(inf.prd8, NULL, l_fnd_miss_num, inf.prd8)) prd8,
              DECODE (inf.prd9, g_hidden_col_num, NULL, DECODE(inf.prd9, NULL, l_fnd_miss_num, inf.prd9)) prd9,
              DECODE (inf.prd10, g_hidden_col_num, NULL, DECODE(inf.prd10, NULL, l_fnd_miss_num, inf.prd10)) prd10,
              DECODE (inf.prd11, g_hidden_col_num, NULL, DECODE(inf.prd11, NULL, l_fnd_miss_num, inf.prd11)) prd11,
              DECODE (inf.prd12, g_hidden_col_num, NULL, DECODE(inf.prd12, NULL, l_fnd_miss_num, inf.prd12)) prd12,
              DECODE (inf.prd13, g_hidden_col_num, NULL, DECODE(inf.prd13, NULL, l_fnd_miss_num, inf.prd13)) prd13,
              DECODE (inf.prd14, g_hidden_col_num, NULL, DECODE(inf.prd14, NULL, l_fnd_miss_num, inf.prd14)) prd14,
              DECODE (inf.prd15, g_hidden_col_num, NULL, DECODE(inf.prd15, NULL, l_fnd_miss_num, inf.prd15)) prd15,
              DECODE (inf.prd16, g_hidden_col_num, NULL, DECODE(inf.prd16, NULL, l_fnd_miss_num, inf.prd16)) prd16,
              DECODE (inf.prd17, g_hidden_col_num, NULL, DECODE(inf.prd17, NULL, l_fnd_miss_num, inf.prd17)) prd17,
              DECODE (inf.prd18, g_hidden_col_num, NULL, DECODE(inf.prd18, NULL, l_fnd_miss_num, inf.prd18)) prd18,
              DECODE (inf.prd19, g_hidden_col_num, NULL, DECODE(inf.prd19, NULL, l_fnd_miss_num, inf.prd19)) prd19,
              DECODE (inf.prd20, g_hidden_col_num, NULL, DECODE(inf.prd20, NULL, l_fnd_miss_num, inf.prd20)) prd20,
              DECODE (inf.prd21, g_hidden_col_num, NULL, DECODE(inf.prd21, NULL, l_fnd_miss_num, inf.prd21)) prd21,
              DECODE (inf.prd22, g_hidden_col_num, NULL, DECODE(inf.prd22, NULL, l_fnd_miss_num, inf.prd22)) prd22,
              DECODE (inf.prd23, g_hidden_col_num, NULL, DECODE(inf.prd23, NULL, l_fnd_miss_num, inf.prd23)) prd23,
              DECODE (inf.prd24, g_hidden_col_num, NULL, DECODE(inf.prd24, NULL, l_fnd_miss_num, inf.prd24)) prd24,
              DECODE (inf.prd25, g_hidden_col_num, NULL, DECODE(inf.prd25, NULL, l_fnd_miss_num, inf.prd25)) prd25,
              DECODE (inf.prd26, g_hidden_col_num, NULL, DECODE(inf.prd26, NULL, l_fnd_miss_num, inf.prd26)) prd26,
              DECODE (inf.prd27, g_hidden_col_num, NULL, DECODE(inf.prd27, NULL, l_fnd_miss_num, inf.prd27)) prd27,
              DECODE (inf.prd28, g_hidden_col_num, NULL, DECODE(inf.prd28, NULL, l_fnd_miss_num, inf.prd28)) prd28,
              DECODE (inf.prd29, g_hidden_col_num, NULL, DECODE(inf.prd29, NULL, l_fnd_miss_num, inf.prd29)) prd29,
              DECODE (inf.prd30, g_hidden_col_num, NULL, DECODE(inf.prd30, NULL, l_fnd_miss_num, inf.prd30)) prd30,
              DECODE (inf.prd31, g_hidden_col_num, NULL, DECODE(inf.prd31, NULL, l_fnd_miss_num, inf.prd31)) prd31,
              DECODE (inf.prd32, g_hidden_col_num, NULL, DECODE(inf.prd32, NULL, l_fnd_miss_num, inf.prd32)) prd32,
              DECODE (inf.prd33, g_hidden_col_num, NULL, DECODE(inf.prd33, NULL, l_fnd_miss_num, inf.prd33)) prd33,
              DECODE (inf.prd34, g_hidden_col_num, NULL, DECODE(inf.prd34, NULL, l_fnd_miss_num, inf.prd34)) prd34,
              DECODE (inf.prd35, g_hidden_col_num, NULL, DECODE(inf.prd35, NULL, l_fnd_miss_num, inf.prd35)) prd35,
              DECODE (inf.prd36, g_hidden_col_num, NULL, DECODE(inf.prd36, NULL, l_fnd_miss_num, inf.prd36)) prd36,
              DECODE (inf.prd37, g_hidden_col_num, NULL, DECODE(inf.prd37, NULL, l_fnd_miss_num, inf.prd37)) prd37,
              DECODE (inf.prd38, g_hidden_col_num, NULL, DECODE(inf.prd38, NULL, l_fnd_miss_num, inf.prd38)) prd38,
              DECODE (inf.prd39, g_hidden_col_num, NULL, DECODE(inf.prd39, NULL, l_fnd_miss_num, inf.prd39)) prd39,
              DECODE (inf.prd40, g_hidden_col_num, NULL, DECODE(inf.prd40, NULL, l_fnd_miss_num, inf.prd40)) prd40,
              DECODE (inf.prd41, g_hidden_col_num, NULL, DECODE(inf.prd41, NULL, l_fnd_miss_num, inf.prd41)) prd41,
              DECODE (inf.prd42, g_hidden_col_num, NULL, DECODE(inf.prd42, NULL, l_fnd_miss_num, inf.prd42)) prd42,
              DECODE (inf.prd43, g_hidden_col_num, NULL, DECODE(inf.prd43, NULL, l_fnd_miss_num, inf.prd43)) prd43,
              DECODE (inf.prd44, g_hidden_col_num, NULL, DECODE(inf.prd44, NULL, l_fnd_miss_num, inf.prd44)) prd44,
              DECODE (inf.prd45, g_hidden_col_num, NULL, DECODE(inf.prd45, NULL, l_fnd_miss_num, inf.prd45)) prd45,
              DECODE (inf.prd46, g_hidden_col_num, NULL, DECODE(inf.prd46, NULL, l_fnd_miss_num, inf.prd46)) prd46,
              DECODE (inf.prd47, g_hidden_col_num, NULL, DECODE(inf.prd47, NULL, l_fnd_miss_num, inf.prd47)) prd47,
              DECODE (inf.prd48, g_hidden_col_num, NULL, DECODE(inf.prd48, NULL, l_fnd_miss_num, inf.prd48)) prd48,
              DECODE (inf.prd49, g_hidden_col_num, NULL, DECODE(inf.prd49, NULL, l_fnd_miss_num, inf.prd49)) prd49,
              DECODE (inf.prd50, g_hidden_col_num, NULL, DECODE(inf.prd50, NULL, l_fnd_miss_num, inf.prd50)) prd50,
              DECODE (inf.prd51, g_hidden_col_num, NULL, DECODE(inf.prd51, NULL, l_fnd_miss_num, inf.prd51)) prd51,
              DECODE (inf.prd52, g_hidden_col_num, NULL, DECODE(inf.prd52, NULL, l_fnd_miss_num, inf.prd52)) prd52,
              DECODE (inf.sd_prd, g_hidden_col_num, NULL, DECODE(inf.sd_prd, NULL, l_fnd_miss_num, inf.sd_prd)) sd_prd
      FROM    pa_fp_webadi_upload_inf inf
      WHERE   inf.run_id=c_run_id
      AND     Nvl(inf.val_error_flag, 'N') <> 'Y'
      AND     inf.val_error_code IS NULL
      AND     (inf.amount_type_name IS NULL      OR
               (inf.amount_type_code IN ('TOTAL_QTY','FCST_QTY','ETC_QTY') AND
                c_allow_qty_flag='Y')            OR
               (inf.amount_type_code IN ('TOTAL_RAW_COST','FCST_RAW_COST','ETC_RAW_COST') AND
                c_allow_raw_cost_flag='Y')       OR
               (inf.amount_type_code IN ('TOTAL_BURDENED_COST','FCST_BURDENED_COST','ETC_BURDENED_COST') AND
                c_allow_burd_cost_flag='Y')      OR
               (inf.amount_type_code IN ('TOTAL_REV','FCST_REVENUE','ETC_REVENUE') AND
                c_allow_revenue_flag='Y')        OR
               (inf.amount_type_code IN ('RAW_COST_RATE','ETC_RAW_COST_RATE') AND
                c_allow_raw_cost_rate_flag='Y')  OR
               (inf.amount_type_code IN ('BURDENED_COST_RATE','ETC_BURDENED_COST_RATE') AND
                c_allow_burd_cost_rate_flag='Y') OR
               (inf.amount_type_code IN ('BILL_RATE','ETC_BILL_RATE') AND
                c_allow_bill_rate_flag='Y') )
      AND     Nvl(c_request_id, -99) = Nvl(inf.request_id, -99)
      ORDER BY inf.task_id, inf.resource_list_member_id, Nvl(inf.txn_currency_code, '-99'),
               DECODE (inf.amount_type_code, 'TOTAL_BURDENED_COST',   1,
                                             'TOTAL_RAW_COST',        2,
                                             'TOTAL_REV',             3,
                                             'TOTAL_QTY',             4,
                                             'BURDENED_COST_RATE',    5,
                                             'RAW_COST_RATE',         6,
                                             'BILL_RATE',             7,
                                             'FCST_BURDENED_COST',    10,
                                             'ETC_BURDENED_COST',     11,
                                             'FCST_RAW_COST',         12,
                                             'ETC_RAW_COST',          13,
                                             'FCST_REVENUE',          14,
                                             'ETC_REVENUE',           15,
                                             'FCST_QTY',              16,
                                             'ETC_QTY',               17,
                                             'ETC_BURDENED_COST_RATE',18,
                                             'ETC_RAW_COST_RATE',     19,
                                             'ETC_BILL_RATE',         20, 0);

TYPE inf_cur_tbl_typ IS TABLE OF inf_tbl_data_csr%ROWTYPE INDEX BY BINARY_INTEGER;

/* Start of changes done for Bug : 4584865 */

/*This Record is used to store the Start Date and End Date of each Period based on the Period Mask associated
  with the budget version.
*/
TYPE periods_rec IS RECORD(sequence_number   NUMBER,
                          period_name   VARCHAR2(50),--gl_periods.period_name%TYPE,
                          start_date   gl_periods.start_date%TYPE,
                          end_date   gl_periods.end_date%TYPE);
--PL/SQL table created based on Record periods_rec.
TYPE periods_tbl IS TABLE OF periods_rec;

/* End of Changes done for Bug : 4584865*/

PROCEDURE write_log(
                    p_module_name          IN  VARCHAR2,
                    p_err_msg              IN  VARCHAR2,
                    p_debug_level          IN  NUMBER
                   )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  INSERT INTO FND_LOG_MESSAGES
  (module
  ,log_level
  ,message_text
  ,session_id
  ,user_id
  ,timestamp
  ,log_sequence)
  values
  (p_module_name
  ,p_debug_level
  ,p_err_msg
  ,-1
  ,fnd_global.user_id
  ,sysdate
  ,fnd_log_messages_s.nextval
  );

commit;

EXCEPTION
    WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END write_log;

/*PROCEDURE log1(p_err_msg              IN  VARCHAR2
               )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
if wlog='N' then
  return;
  end if;
  INSERT INTO t1
  (c1,
   c2)
  values
  (pa_fp_elements_s.nextval,
   p_err_msg
  );

commit;

EXCEPTION
    WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END log1;
*/

PROCEDURE delete_xface
                  ( p_run_id               IN   pa_fp_webadi_upload_inf.run_id%TYPE
                   ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                   ,x_msg_data             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   ,p_calling_module       IN   VARCHAR2  DEFAULT NULL
                  )
IS
  l_debug_mode                    VARCHAR2(1) ;
  l_msg_count                     NUMBER := 0;
  l_data                          VARCHAR2(2000);
  l_msg_data                      VARCHAR2(2000);
  l_msg_index_out                 NUMBER;
  l_del_record_count              NUMBER;
  l_budget_version_id             pa_budget_versions.budget_version_id%TYPE;
  l_bv_request_id                 pa_budget_versions.request_id%TYPE;
  l_inf_request_id                pa_budget_versions.request_id%TYPE;
  l_preserve_rows_flag            VARCHAR2(1);
  l_nothing_delete_flag           VARCHAR2(1);

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'Y');

    IF l_debug_mode = 'Y' THEN
         pa_debug.set_curr_function( p_function   => 'DELETE_XFACE'
                                    ,p_debug_mode => l_debug_mode );
         pa_debug.g_err_stage := ':In pa_fp_webadi_pkg.DELETE_XFACE' ;
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    l_preserve_rows_flag   := 'N';
    l_nothing_delete_flag  := 'N';

    -- validating input parameter
    IF p_run_id IS NULL THEN
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'p_run_id is passed as null';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
           END IF;
           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                p_token1         => 'PROCEDURENAME',
                                p_value1         => g_module_name);
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- checking, if this api is called from web adi directly and if yes, if there is a pending
    -- concurrent request for processing, then the rows in the interface table should not be deleted
    IF p_calling_module = 'XL_UPLOAD' THEN
        BEGIN
            SELECT 'Y'
            INTO   l_preserve_rows_flag
            FROM   DUAL
            WHERE  EXISTS (SELECT 'X'
                           FROM   pa_fp_webadi_upload_inf inf,
                                  pa_budget_versions bv
                           WHERE  inf.run_id = p_run_id
                           AND    inf.budget_version_id = bv.budget_version_id
                           AND    Nvl(inf.request_id, -99) = Nvl(bv.request_id, -99)
                           AND    bv.plan_processing_code IN ('XLUP', 'XLUE'));
            -- there is a pending concurrent request, which is yet to be processed
            -- inf table data should not be deleted
            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Concurrent Request pending, returning';
               pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'This has been called for online mode';
                   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
               END IF;
               -- do nothing
               l_preserve_rows_flag := 'N';
--               l_nothing_delete_flag := 'Y';
        END;
    END IF;

    IF l_preserve_rows_flag <> 'Y' THEN
        DELETE FROM PA_FP_WEBADI_UPLOAD_INF
        WHERE  run_id = p_run_id;

        IF l_debug_mode = 'Y' THEN
             l_del_record_count := SQL%ROWCOUNT;
             pa_debug.g_err_stage := ':Deleted '||l_del_record_count||' records from PA_FP_WEBADI_UPLOAD_INF';
             pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
             pa_debug.reset_curr_function;
        END IF;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
         l_msg_count := FND_MSG_PUB.count_msg;

         IF l_msg_count = 1 and x_msg_data IS NULL THEN
               PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                 ,p_msg_index      => 1
                 ,p_msg_count      => l_msg_count
                 ,p_msg_data       => l_msg_data
                 ,p_data           => l_data
                 ,p_msg_index_out  => l_msg_index_out);
              x_msg_data := l_data;
              x_msg_count := l_msg_count;
         ELSE
              x_msg_count := l_msg_count;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
         END IF;
         RETURN;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'pa_fp_webadi_pkg'
              ,p_procedure_name => 'DELETE_XFACE' );
          IF l_debug_mode = 'Y' THEN
             pa_debug.write('DELETE_XFACE' || g_module_name,SQLERRM,4);
             pa_debug.write('DELETE_XFACE' || g_module_name,pa_debug.G_Err_Stack,4);
             pa_debug.reset_curr_function;
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END DELETE_XFACE;

  -- Bug 3986129: FP.M Web ADI Dev changes. Added the followings:

  PROCEDURE validate_header_info
     ( p_calling_mode              IN           VARCHAR2,
       p_run_id                    IN           pa_fp_webadi_upload_inf.run_id%TYPE,
       p_budget_version_id         IN           pa_budget_versions.budget_version_id%TYPE,
       p_record_version_number     IN           pa_budget_versions.record_version_number%TYPE,
       p_pm_rec_version_number     IN           pa_period_masks_b.record_version_number%TYPE,
       p_submit_flag               IN           VARCHAR2,
       p_request_id                IN           pa_budget_versions.request_id%TYPE,
       x_return_status             OUT          NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_data                  OUT          NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count                 OUT          NOCOPY NUMBER) --File.Sql.39 bug 4440895

  IS

      CURSOR l_version_info_csr (c_budget_version_id      pa_budget_versions.budget_version_id%TYPE)
      IS
      SELECT  bv.record_version_number,
              bv.period_mask_id,
              bv.project_id,
              bv.fin_plan_type_id,
              Nvl(bv.ci_id, -1),
              bv.version_type,
              Nvl(bv.approved_cost_plan_type_flag, 'N'),
              Nvl(bv.approved_rev_plan_type_flag, 'N'),
              Nvl(bv.primary_cost_forecast_flag, 'N'),
              Nvl(bv.primary_rev_forecast_flag, 'N'),
              Nvl(bv.current_working_flag, 'N'),
              fpt.plan_class_code,
              Decode(bv.version_type, 'COST', fpo.cost_time_phased_code,
                     'REVENUE', fpo.revenue_time_phased_code, 'ALL', fpo.all_time_phased_code) time_phased_code
       FROM   pa_budget_versions bv,
              pa_fin_plan_types_b fpt,
              pa_proj_fp_options fpo
       WHERE  bv.budget_version_id = c_budget_version_id
       AND    bv.budget_version_id = fpo.fin_plan_version_id
       AND    bv.project_id = fpo.project_id
       AND    bv.fin_plan_type_id = fpt.fin_plan_type_id;

       l_record_version_number              pa_budget_versions.record_version_number%TYPE;
       l_period_mask_id                     pa_period_masks_b.period_mask_id%TYPE;
       l_project_id                         pa_projects_all.project_id%TYPE;
       l_fin_plan_type_id                   pa_fin_plan_types_b.fin_plan_type_id%TYPE;
       l_ci_id                              pa_control_items.ci_id%TYPE;
       l_version_type                       pa_budget_versions.version_type%TYPE;
       l_app_cost_plan_type_flag            pa_budget_versions.approved_cost_plan_type_flag%TYPE;
       l_rev_plan_type_flag                 pa_budget_versions.approved_rev_plan_type_flag%TYPE;
       l_prime_cost_fcst_flag               pa_budget_versions.primary_cost_forecast_flag%TYPE;
       l_prime_rev_fcst_flag                pa_budget_versions.primary_rev_forecast_flag%TYPE;
       l_current_working_flag               pa_budget_versions.current_working_flag%TYPE;
       l_plan_class_code                    pa_fin_plan_types_b.plan_class_code%TYPE;
       l_time_phase_code                    pa_proj_fp_options.all_time_phased_code%TYPE;
       l_pm_rec_version_number              pa_period_masks_b.record_version_number%TYPE;

       is_periodic_layout                   VARCHAR2(1) := 'N';

       l_sec_ret_code                       VARCHAR2(30);
       l_locked_by_persion_id               pa_budget_versions.locked_by_person_id%TYPE;
       l_val_err_code                       VARCHAR2(30);
       l_ci_status_code                     pa_control_items.status_code%TYPE;

       l_return_status                      VARCHAR2(1);
       l_msg_data                           VARCHAR2(2000);
       l_msg_count                          NUMBER;

       l_debug_mode                         VARCHAR2(1);
       l_module_name                        VARCHAR2(100) := 'pa_fp_webadi_pkg.validate_header_info';
       l_debug_level3                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
       l_debug_level5                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;
       l_data                               VARCHAR2(2000);
       l_msg_index_out                      NUMBER;


       BEGIN

               fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
               x_msg_count := 0;
               x_return_status := FND_API.G_RET_STS_SUCCESS;
               IF l_debug_mode = 'Y' THEN
                     PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                                 p_debug_mode => l_debug_mode );
               END IF;
               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Entering into pa_fp_webadi_pkg.validate_header_info';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;

               --log1('----- Entering into validate_header_info-------');

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Opening l_version_info_csr';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;

               -- since there would be check for null budget_version_id in the
               -- calling place, no check is made here for the same
               OPEN l_version_info_csr(p_budget_version_id);
               FETCH l_version_info_csr INTO
                     l_record_version_number,
                     l_period_mask_id,
                     l_project_id,
                     l_fin_plan_type_id,
                     l_ci_id,
                     l_version_type,
                     l_app_cost_plan_type_flag,
                     l_rev_plan_type_flag,
                     l_prime_cost_fcst_flag,
                     l_prime_rev_fcst_flag,
                     l_current_working_flag,
                     l_plan_class_code,
                     l_time_phase_code;

                     IF l_version_info_csr%NOTFOUND THEN
                           IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage := 'Cursor l_version_info_csr failed to fetch data';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;
               CLOSE l_version_info_csr;

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Data fetched from l_version_info_csr';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;

               --log1('----- STAGE 1-------');
               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Validating record version number';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;
               IF l_record_version_number <> p_record_version_number THEN
                      IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Record version number has changed';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;
                      RAISE BV_validation_failed_exc;
               END IF;
               --Update the interface table with error_code 'PA_FP_WEBADI_VER_MODIFIED'

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Checking for periodic layout';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;

               BEGIN
                     SELECT  'Y'
                     INTO    is_periodic_layout
                     FROM    DUAL
                     WHERE EXISTS(SELECT  'X'
                                  FROM    pa_fp_webadi_upload_inf
                                  WHERE   run_id = p_run_id
                                  AND     amount_type_name IS NOT NULL
                                  AND     Nvl(p_request_id, -99) = Nvl(request_id, -99));
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          is_periodic_layout := 'N';
               END;

               --log1('----- STAGE 2-------');
               IF is_periodic_layout = 'Y' THEN
                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Validating period mask';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                    END IF;

                    IF l_time_phase_code <> 'N' THEN
                         BEGIN
                            SELECT record_version_number
                            INTO   l_pm_rec_version_number
                            FROM   pa_period_masks_b
                            WHERE  period_mask_id = l_period_mask_id;
                         EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                                  IF l_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage := 'No data found for period mask';
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                  END IF;
                                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END;
                         -- the following validation is only for timephased budgets downloaded in
                         -- periodic layouts
                         IF l_pm_rec_version_number <> p_pm_rec_version_number THEN
                            IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage := 'period mask has changed';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;
                            RAISE Bv_period_mask_changed_Exc;
                            --Update the interface table with error_code 'PA_FP_WEBADI_TP_MODIFIED'
                         END IF;
                    END IF;
               END IF;

               --log1('----- STAGE 3-------');
               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Checking for function security';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;

               IF l_ci_id = -1 THEN
                     -- budget version
                     PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY
                        (p_api_version_number => PA_BUDGET_PUB.G_API_VERSION_NUMBER,
                         p_project_id         => l_project_id,
                         p_fin_plan_type_id   => l_fin_plan_type_id,
                         p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
                         p_function_name      => 'PA_PM_UPDATE_BUDGET',
                         p_version_type       => l_version_type,
                         x_return_status      => l_return_status,
                         x_ret_code           => l_sec_ret_code);
               ELSE
                     -- change order version
                     PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY
                        (p_api_version_number => PA_BUDGET_PUB.G_API_VERSION_NUMBER,
                         p_project_id         => l_project_id,
                         p_fin_plan_type_id   => l_fin_plan_type_id,
                         p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
                         p_function_name      => 'PA_PM_UPDATE_CHG_DOC',
                         p_version_type       => l_version_type,
                         x_return_status      => l_return_status,
                         x_ret_code           => l_sec_ret_code);
               END IF;

               IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                   IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'Function security not present';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                   END IF;
                   RAISE No_Bv_Maint_Previlege_Exc;
                   --Update the interface table with error_code 'PA_FP_WEBADI_NO_BV_MAINT_PVLG'
               END IF;

               --log1('----- STAGE 4-------');
               -- Checking, if the budget version can be edited or not
               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Checking if the version can be edited';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;

               IF l_ci_id = -1 THEN
                   pa_fin_plan_utils.validate_editable_bv
                       (p_budget_version_id     => p_budget_version_id,
                        p_user_id               => fnd_global.user_id,
                        p_context               => 'WEBADI',
                        p_excel_calling_mode    => p_calling_mode,
                        x_locked_by_person_id   => l_locked_by_persion_id,
                        x_err_code              => l_val_err_code,
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_msg_data);

                   IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                      IF l_val_err_code IS NOT NULL THEN
                            IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage := 'The version can not be edited';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;
                            RAISE Bv_Non_Editable_Exc;
                            --update the interface table with the error_code;
                      END IF;
                   END IF;

                   --log1('----- STAGE 5-------');
               ELSE
                     -- Check if the ci is not editable
                     IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Checking if the CO can be updated';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     END IF;
                     BEGIN
                             SELECT pjs.project_system_status_code
                             INTO   l_ci_status_code
                             FROM   pa_control_items pci,
                                    pa_project_statuses pjs
                             WHERE  pci.ci_id = l_ci_id
                             and    pci.status_code = pjs.project_status_code;
                     EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                               IF l_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage := 'Status code not found';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                               END IF;
                               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END;

                     IF l_ci_status_code NOT IN ('CI_DRAFT', 'CI_WORKING') THEN
                           IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'CO version cannot be updated';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;
                           RAISE Co_Ver_Non_Editable_Exc;
                           --update the interface table with error_code 'PA_FP_WA_CI_VER_NON_EDITABLE'
                     END IF;

                     --log1('----- STAGE 6-------');
               END IF;
               /* check if the p_submit flag is passed as 'Y', if yes then
                * check if the version is current working version or not,
                * if the user has the submit privilege or not
                * throw an error, if the version is CI
                */

               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Checking for submit previlege';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;
               IF p_submit_flag = 'Y' THEN
                       -- call to check if the version is current working
                       IF l_ci_id = -1 THEN
                           IF l_current_working_flag = 'N' THEN
                              IF l_debug_mode = 'Y' THEN
                                 pa_debug.g_err_stage := 'Submittin while not current working';
                                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                              END IF;
                              RAISE Bv_Not_Curr_Working_Exc;
                              --Update the interface table with error_code 'PA_FP_WA_BV_NOT_CURR_WORKING';
                           END IF;
                       ELSE -- for CI version the p_submit_flag = 'Y'
                          IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Submitting CO version';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                          END IF;
                          RAISE Ci_Ver_Sumbit_Flag_Exc;
                          --Update the interface table with error_code 'PA_FP_WA_CI_VER_SUBMIT_FLAG';
                       END IF;

                       PA_PM_FUNCTION_SECURITY_PUB.CHECK_BUDGET_SECURITY
                       (p_api_version_number => PA_BUDGET_PUB.G_API_VERSION_NUMBER,
                        p_project_id         => l_project_id,
                        p_fin_plan_type_id   => l_fin_plan_type_id,
                        p_calling_context    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
                        p_function_name      => 'PA_PM_SUBMIT_BUDGET',
                        p_version_type       => l_version_type,
                        x_return_status      => l_return_status,
                        x_ret_code           => l_sec_ret_code);

                       IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                            IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage := 'No submit previlege';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            END IF;
                            RAISE No_Bv_Maint_Previlege_Exc;
                            --Update the interface table with error_code 'PA_FP_WEBADI_NO_BV_MAINT_PVLG'
                       END IF;

                       --log1('----- STAGE 7-------');
               END IF; -- p_submit_flag = 'Y'

               IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Leaving into pa_fp_webadi_pkg.validate_header_info';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;
               IF l_debug_mode = 'Y' THEN
                  pa_debug.reset_curr_function;
               END IF;

               --log1('----- Leaving validate_header_info-------');

      EXCEPTION
           -- handling all the pre defined exceptions
           WHEN BV_validation_failed_exc THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Updating tmp table with error code: PA_FP_WEBADI_VER_MODIFIED';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  UPDATE pa_fp_webadi_upload_inf
                  SET    val_error_flag       = 'Y',
                         val_error_code       = 'PA_FP_WEBADI_VER_MODIFIED',
                         err_task_name        = nvl(task_name,'-98'),
                         err_task_number      = nvl(task_number,'-98'),
                         err_alias            = nvl(resource_alias,'-98'),
                         err_amount_type_code = nvl(amount_type_code,'-98')
                  WHERE  run_id=p_run_id
                  AND     Nvl(p_request_id, -99) = Nvl(request_id, -99);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                  END IF;

                  RETURN;
           WHEN Bv_period_mask_changed_Exc THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Updating tmp table with error code: PA_FP_WEBADI_TP_MODIFIED';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  UPDATE pa_fp_webadi_upload_inf
                  SET    val_error_flag = 'Y',
                         val_error_code = 'PA_FP_WEBADI_TP_MODIFIED',
                         err_task_name        = nvl(task_name,'-98'),
                         err_task_number      = nvl(task_number,'-98'),
                         err_alias            = nvl(resource_alias,'-98'),
                         err_amount_type_code = nvl(amount_type_code,'-98')
                  WHERE  run_id=p_run_id
                  AND     Nvl(p_request_id, -99) = Nvl(request_id, -99);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                  END IF;

                  RETURN;
           WHEN No_Bv_Maint_Previlege_Exc THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Updating tmp table with error code: PA_FP_WEBADI_NO_BV_MAINT_PVLG';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  UPDATE pa_fp_webadi_upload_inf
                  SET    val_error_flag = 'Y',
                         val_error_code = 'PA_FP_WEBADI_NO_BV_MAINT_PVLG',
                         err_task_name        = nvl(task_name,'-98'),
                         err_task_number      = nvl(task_number,'-98'),
                         err_alias            = nvl(resource_alias,'-98'),
                         err_amount_type_code = nvl(amount_type_code,'-98')
                  WHERE  run_id=p_run_id
                  AND     Nvl(p_request_id, -99) = Nvl(request_id, -99);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                  END IF;

                  RETURN;
           WHEN Bv_Non_Editable_Exc THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Updating tmp table with error code: ' || l_val_err_code;
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  UPDATE pa_fp_webadi_upload_inf
                  SET    val_error_flag = 'Y',
                         val_error_code = l_val_err_code,
                         err_task_name        = nvl(task_name,'-98'),
                         err_task_number      = nvl(task_number,'-98'),
                         err_alias            = nvl(resource_alias,'-98'),
                         err_amount_type_code = nvl(amount_type_code,'-98')
                  WHERE  run_id=p_run_id
                  AND     Nvl(p_request_id, -99) = Nvl(request_id, -99);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                  END IF;

                  RETURN;
           WHEN Co_Ver_Non_Editable_Exc THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Updating tmp table with error code: FP_WEBADI_CI_VER_NON_EDITABLE';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  UPDATE pa_fp_webadi_upload_inf
                  SET    val_error_flag = 'Y',
                         val_error_code = 'PA_FP_WA_CI_VER_NON_EDITABLE',
                         err_task_name        = nvl(task_name,'-98'),
                         err_task_number      = nvl(task_number,'-98'),
                         err_alias            = nvl(resource_alias,'-98'),
                         err_amount_type_code = nvl(amount_type_code,'-98')
                  WHERE  run_id=p_run_id
                  AND     Nvl(p_request_id, -99) = Nvl(request_id, -99);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                  END IF;

                  RETURN;
           WHEN Bv_Not_Curr_Working_Exc THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Updating tmp table with error code: FP_WEBADI_BV_NOT_CURR_WORKING';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  UPDATE pa_fp_webadi_upload_inf
                  SET    val_error_flag = 'Y',
                         val_error_code = 'PA_FP_WA_BV_NOT_CURR_WORKING',
                         err_task_name        = nvl(task_name,'-98'),
                         err_task_number      = nvl(task_number,'-98'),
                         err_alias            = nvl(resource_alias,'-98'),
                         err_amount_type_code = nvl(amount_type_code,'-98')
                  WHERE  run_id=p_run_id
                  AND     Nvl(p_request_id, -99) = Nvl(request_id, -99);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                  END IF;

                  RETURN;
           WHEN Ci_Ver_Sumbit_Flag_Exc THEN
                  IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Updating tmp table with error code: FP_WEBADI_CI_VER_SUBMIT_FLAG';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  UPDATE pa_fp_webadi_upload_inf
                  SET    val_error_flag = 'Y',
                         val_error_code = 'PA_FP_WA_CI_VER_SUBMIT_FLAG',
                         err_task_name        = nvl(task_name,'-98'),
                         err_task_number      = nvl(task_number,'-98'),
                         err_alias            = nvl(resource_alias,'-98'),
                         err_amount_type_code = nvl(amount_type_code,'-98')
                  WHERE  run_id=p_run_id
                  AND     Nvl(p_request_id, -99) = Nvl(request_id, -99);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

           WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
               l_msg_count := FND_MSG_PUB.count_msg;

               IF l_msg_count = 1 and x_msg_data IS NULL THEN
                     PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_TRUE
                       ,p_msg_index      => 1
                       ,p_msg_count      => l_msg_count
                       ,p_msg_data       => l_msg_data
                       ,p_data           => l_data
                       ,p_msg_index_out  => l_msg_index_out);
                    x_msg_data := l_data;
                    x_msg_count := l_msg_count;
               ELSE
                    x_msg_count := l_msg_count;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;

               IF l_debug_mode = 'Y' THEN
                   pa_debug.reset_curr_function;
               END IF;
               RETURN;

           WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               x_msg_count     := 1;
               x_msg_data      := SQLERRM;

               FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                                       ,p_procedure_name  => 'prepare_val_input');
               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;

               IF l_debug_mode = 'Y' THEN
                  pa_debug.reset_curr_function;
               END IF;
               RAISE;

      END validate_header_info; -- of validate_header_info

  /* The input parameter p_context would only be passed if the task id can not be derived
   * from the task number/ task name provided i.e task_id is returned as null from the select
   * in prepare_val_input api. The valid value of this is 'INV_TASK.
   * For other validation errors, the corresponding error code would be passed to the api
   * along with other informations like task_id, resource_alias, amount_type_code
   */

   -- Making this procedure an autonomous transition block as the errors reported
   -- on the interface table have to be retained even after rolling back all the
   -- other DML performed in the course of validation processing till the point
   -- a validation failure occurs.

  PROCEDURE process_errors
                 ( p_run_id             IN           pa_fp_webadi_upload_inf.run_id%TYPE,
                   p_context            IN           VARCHAR2,
                   p_periodic_flag      IN           VARCHAR2,
                   p_error_code_tbl     IN           SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
                   p_task_id_tbl        IN           SYSTEM.PA_NUM_TBL_TYPE,
                   p_rlm_id_tbl         IN           SYSTEM.PA_NUM_TBL_TYPE,
                   p_txn_curr_tbl       IN           SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
                   p_amount_type_tbl    IN           SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
                   p_request_id         IN           pa_budget_versions.request_id%TYPE,
                   x_return_status      OUT          NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                   x_msg_data           OUT          NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                   x_msg_count          OUT          NOCOPY NUMBER) --File.Sql.39 bug 4440895
  IS
--  PRAGMA AUTONOMOUS_TRANSACTION;

       l_return_status                      VARCHAR2(1);
       l_msg_data                           VARCHAR2(2000);
       l_msg_count                          NUMBER;

       l_debug_mode                         VARCHAR2(1);
       l_module_name                        VARCHAR2(100) := 'pa_fp_webadi_pkg.process_errors';
       l_debug_level3                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
       l_debug_level5                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;
       l_msg_index_out                      NUMBER;
       l_data                               VARCHAR2(2000);
       l_periodic_flag                      VARCHAR2(1);

  BEGIN
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       IF l_debug_mode = 'Y' THEN
             PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                         p_debug_mode => l_debug_mode );
       END IF;
       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Entering into pa_fp_webadi_pkg.process_errors';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;

       --log1('PE 1'||p_error_code_tbl.COUNT);
       --log1('PE 2'||p_periodic_flag);
       --log1('PE 3'||p_task_id_tbl.COUNT);
       --log1('PE 4'||p_rlm_id_tbl.COUNT);
       --log1('PE 5'||p_txn_curr_tbl.COUNT);
       --log1('PE 6'||p_run_id);
       --log1('PE 7'||p_context);
       /*FOR  k IN 1..p_error_code_tbl.COUNT LOOP

            log1('p_error_code_tbl('||k||') is '||p_error_code_tbl(k));
            log1('p_task_id_tbl('||k||') is '||p_task_id_tbl(k));
            log1('p_rlm_id_tbl('||k||') is '||p_rlm_id_tbl(k));
            log1('p_txn_curr_tbl('||k||') is '||p_txn_curr_tbl(k));
            IF p_amount_type_tbl.EXISTS(k) THEN
                log1('p_amount_type_tbl('||k||') is '||p_amount_type_tbl(k));

            ELSE

                log1('p_amount_type_tbl('||k||') is NULL5');
            END IF;
      end loop;*/

      l_periodic_flag := p_periodic_flag;

      -- 4497322.Perf Fix:A condition is added in the WHERE clause.
      IF l_periodic_flag IS NULL THEN

        BEGIN
            SELECT 'Y'
            INTO   l_periodic_flag
            FROM   DUAL
            WHERE  EXISTS (SELECT 1
                           FROM   pa_fp_webadi_upload_inf
                           WHERE  run_id=p_run_id
                           AND    amount_type_name IS NOT NULL
                           AND    Nvl(p_request_id, -99) = Nvl(request_id, -99));

        EXCEPTION
        WHEN NO_DATA_FOUND THEN

            l_periodic_flag := 'N';

        END;

      END IF;



       IF p_context IS NOT NULL THEN
           IF p_context = 'INV_TASK' THEN
               UPDATE pa_fp_webadi_upload_inf
               SET    val_error_flag       = 'Y',
                      val_error_code       = 'INVALID_TASK_INFO',
                      err_task_name        = nvl(task_name,'-98'),
                      err_task_number      = nvl(task_number,'-98'),
                      err_alias            = nvl(resource_alias,'-98'),
                      err_amount_type_code = nvl(amount_type_code,'-98')
               WHERE  run_id = p_run_id
               AND    task_id IS NULL
               AND    val_error_flag IS NULL
               AND    Nvl(p_request_id, -99) = Nvl(request_id, -99);
           ELSIF p_context = 'INV_RESOURCE' THEN
               UPDATE pa_fp_webadi_upload_inf
               SET    val_error_flag       = 'Y',
                      val_error_code       = 'INVALID_RESOURCE_INFO',
                      err_task_name        = nvl(task_name,'-98'),
                      err_task_number      = nvl(task_number,'-98'),
                      err_alias            = nvl(resource_alias,'-98'),
                      err_amount_type_code = nvl(amount_type_code,'-98')
               WHERE  run_id = p_run_id
               AND    resource_list_member_id IS NULL
               AND    val_error_flag IS NULL
               AND    Nvl(p_request_id, -99) = Nvl(request_id, -99);
           ELSE -- no other valid not null context
               IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Not a valid calling context passed';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

       ELSE  -- when p_context is not passed
           IF p_error_code_tbl.count > 0 THEN

               IF p_periodic_flag = 'Y' THEN

                  IF p_error_code_tbl.COUNT = p_task_id_tbl.COUNT AND
                     p_error_code_tbl.COUNT = p_rlm_id_tbl.COUNT AND
                     p_error_code_tbl.COUNT = p_amount_type_tbl.COUNT AND
                     p_error_code_tbl.COUNT = p_txn_curr_tbl.COUNT THEN
                        FORALL i IN p_task_id_tbl.FIRST .. p_task_id_tbl.LAST
                             UPDATE pa_fp_webadi_upload_inf
                             SET    val_error_flag       = 'Y',
                                    val_error_code       = p_error_code_tbl(i),
                                    err_task_name        = nvl(task_name,'-98'),
                                    err_task_number      = nvl(task_number,'-98'),
                                    err_alias            = nvl(resource_alias,'-98'),
                                    err_amount_type_code = nvl(amount_type_code,'-98')
                             WHERE  run_id = p_run_id
                             AND    task_id = p_task_id_tbl(i)
                             AND    resource_list_member_id = p_rlm_id_tbl(i)
                             AND    Nvl(txn_currency_code, '-11') = Nvl(p_txn_curr_tbl(i), '-11')
                             AND    amount_type_code = p_amount_type_tbl(i)
                             AND    Nvl(p_request_id, -99) = Nvl(request_id, -99)
                             AND    ROWNUM=1;

                  ELSE -- input table length not same
                      IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Information mismatch to process: periodic';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      END IF;
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

               ELSE -- non periodic

                  IF p_error_code_tbl.COUNT = p_task_id_tbl.COUNT AND
                     p_error_code_tbl.COUNT = p_rlm_id_tbl.COUNT AND
                     p_error_code_tbl.COUNT = p_txn_curr_tbl.COUNT THEN
                           FORALL i IN p_task_id_tbl.FIRST .. p_task_id_tbl.LAST
                                UPDATE pa_fp_webadi_upload_inf inf
                                SET    inf.val_error_flag       = 'Y',
                                       inf.val_error_code       = p_error_code_tbl(i),
                                       inf.err_task_name        = nvl(inf.task_name,'-98'),
                                       inf.err_task_number      = nvl(inf.task_number,'-98'),
                                       inf.err_alias            = nvl(inf.resource_alias,'-98'),
                                       inf.err_amount_type_code = nvl(inf.amount_type_code,'-98')
                                WHERE  inf.run_id = p_run_id
                                AND    inf.task_id = p_task_id_tbl(i)
                                AND    inf.resource_list_member_id = p_rlm_id_tbl(i)
                                AND    Nvl(inf.txn_currency_code, '-11') = Nvl(p_txn_curr_tbl(i), '-11')
                                AND    Nvl(p_request_id, -99) = Nvl(inf.request_id, -99)
                                AND    ROWNUM=1;

                                IF l_debug_mode = 'Y' THEN
                                     pa_debug.g_err_stage := 'SQL%COUNT' || SQL%ROWCOUNT;
                                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                               END IF;
                  ELSE
                        IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Information mismatch to process: non periodic';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
               END IF;

           ELSE -- lenght of error code table is 0 when context is not passed
               IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'No error code passed, returning';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;
               IF l_debug_mode = 'Y' THEN
                   pa_debug.reset_curr_function;
               END IF;
               RETURN;
           END IF;
       END IF;  -- p_context

       -- placing a commit here to retain all the error codes stamped.
--       COMMIT;

       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Leaving into pa_fp_webadi_pkg.process_errors';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;
       IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
       END IF;

  EXCEPTION
       WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
           l_msg_count := FND_MSG_PUB.count_msg;

           IF l_msg_count = 1 and x_msg_data IS NULL THEN
                 PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                   ,p_msg_index      => 1
                   ,p_msg_count      => l_msg_count
                   ,p_msg_data       => l_msg_data
                   ,p_data           => l_data
                   ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
           ELSE
                x_msg_count := l_msg_count;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;

           IF l_debug_mode = 'Y' THEN
               pa_debug.reset_curr_function;
           END IF;
           RETURN;

       WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := SQLERRM;

           FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                                   ,p_procedure_name  => 'process_errors');
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;

           IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
           END IF;
           RAISE;
  END process_errors;


  /* Bug 4431269: Added the following private api to read the global table of
   * rec type returned from calculate api and then to call process_errors api
   * to report the errors in interface table.
   */
  PROCEDURE read_global_var_to_report_err
      (    p_run_id                   IN         pa_fp_webadi_upload_inf.run_id%TYPE,
           x_return_status            OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
           x_msg_count                OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_msg_data                 OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      )

  IS
     l_return_status                      VARCHAR2(1);
     l_msg_data                           VARCHAR2(2000);
     l_msg_count                          NUMBER;

     l_debug_mode                         VARCHAR2(1);
     l_module_name                        VARCHAR2(100) := 'pa_fp_webadi_pkg.read_global_var_to_report_err';
     l_debug_level3                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
     l_debug_level5                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;
     l_msg_index_out                      NUMBER;
     l_data                               VARCHAR2(2000);

     l_err_val_code_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
     l_err_task_id_tbl                  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
     l_err_rlm_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
     l_err_txn_curr_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

  BEGIN
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       IF l_debug_mode = 'Y' THEN
             PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                         p_debug_mode => l_debug_mode );
       END IF;
       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Entering into pa_fp_webadi_pkg.read_global_var_to_report_err';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;

       -- checking if there is some value in the global table
       IF g_fp_webadi_rec_tbl.COUNT > 0 THEN
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'There are some values in the global table';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;

           -- processing starts
           FOR i IN g_fp_webadi_rec_tbl.FIRST .. g_fp_webadi_rec_tbl.LAST LOOP
               l_err_val_code_tbl.EXTEND(1);
               l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := g_fp_webadi_rec_tbl(i).error_code;
               l_err_task_id_tbl.EXTEND(1);
               l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := g_fp_webadi_rec_tbl(i).task_id;
               l_err_rlm_id_tbl.EXTEND(1);
               l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := g_fp_webadi_rec_tbl(i).rlm_id;
               l_err_txn_curr_tbl.EXTEND(1);
               l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := g_fp_webadi_rec_tbl(i).txn_currency;
           END LOOP;

           pa_fp_webadi_pkg.process_errors
                  ( p_run_id          => p_run_id,
                    p_error_code_tbl  => l_err_val_code_tbl,
                    p_task_id_tbl     => l_err_task_id_tbl,
                    p_rlm_id_tbl      => l_err_rlm_id_tbl,
                    p_txn_curr_tbl    => l_err_txn_curr_tbl,
                    x_return_status   => l_return_status,
                    x_msg_data        => l_msg_data,
                    x_msg_count       => l_msg_count);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

           -- clearing the table of rec type
           IF g_fp_webadi_rec_tbl.COUNT > 0 THEN
               g_fp_webadi_rec_tbl.DELETE;
           END IF;
       ELSE
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'There is no value stored in the global table, returning';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
       END IF;
       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Leaving into pa_fp_webadi_pkg.read_global_var_to_report_err';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;
       IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
       END IF;
  EXCEPTION
       WHEN PA_FP_CONSTANTS_PKG.Just_Ret_Exc THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
            END IF;
            RETURN;
       WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           -- clearing the table of rec type
           IF g_fp_webadi_rec_tbl.COUNT > 0 THEN
               g_fp_webadi_rec_tbl.DELETE;
           END IF;

           l_msg_count := FND_MSG_PUB.count_msg;

           IF l_msg_count = 1 and x_msg_data IS NULL THEN
                 PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                   ,p_msg_index      => 1
                   ,p_msg_count      => l_msg_count
                   ,p_msg_data       => l_msg_data
                   ,p_data           => l_data
                   ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
           ELSE
                x_msg_count := l_msg_count;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;

           IF l_debug_mode = 'Y' THEN
               pa_debug.reset_curr_function;
           END IF;
           RETURN;

       WHEN OTHERS THEN
           -- clearing the table of rec type
           IF g_fp_webadi_rec_tbl.COUNT > 0 THEN
               g_fp_webadi_rec_tbl.DELETE;
           END IF;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := SQLERRM;

           FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                                   ,p_procedure_name  => 'read_global_var_to_report_err');
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;

           IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
           END IF;
           RAISE;
  END read_global_var_to_report_err;

  -- bug 4428112: introduced this private api to stamp the valid txn curr codes
  -- in the respective lines in the table of records of the interface table,
  -- for a non MC enabled version
  -- if the txn curr code was not populated earlier by the user, this is required
  -- as the cursor on the interface table would be opened again in prepare_pbl_input
  -- to prepare the input tables to process_budget_lines.

  PROCEDURE check_and_update_txn_curr_code
               (p_budget_line_tbl   IN         PA_BUDGET_PUB.G_budget_lines_in_tbl%TYPE,
                px_inf_cur_rec_tbl  IN   OUT   NOCOPY inf_cur_tbl_typ, --File.Sql.39 bug 4440895
                x_return_status     OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                x_msg_count         OUT        NOCOPY NUMBER,   --File.Sql.39 bug 4440895
                x_msg_data          OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

  IS
       l_return_status                      VARCHAR2(1);
       l_msg_data                           VARCHAR2(2000);
       l_msg_count                          NUMBER;

       l_debug_mode                         VARCHAR2(1);
       l_module_name                        VARCHAR2(100) := 'PAFPWAPB.check_and_update_txn_curr_code';
       l_debug_level3                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
       l_debug_level5                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;
       l_msg_index_out                      NUMBER;
       l_data                               VARCHAR2(2000);

       l_task_id_tbl                        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
       l_rlm_id_tbl                         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

  BEGIN
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       IF l_debug_mode = 'Y' THEN
             PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                         p_debug_mode => l_debug_mode );
       END IF;
       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Entering into pa_fp_webadi_pkg.check_and_update_txn_curr_code';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;

       -- validating input params.
       IF p_budget_line_tbl.COUNT < 1 THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:=' Nothing to be updated, returning';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
       ELSE
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:=' Values passed, checking for null txn curr recs.';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;

           FOR i IN p_budget_line_tbl.FIRST .. p_budget_line_tbl.LAST LOOP
                -- looping through both the table types
                FOR j IN px_inf_cur_rec_tbl.FIRST .. px_inf_cur_rec_tbl.LAST LOOP
                    IF p_budget_line_tbl(i).pa_task_id = px_inf_cur_rec_tbl(j).task_id AND
                       p_budget_line_tbl(i).resource_list_member_id = px_inf_cur_rec_tbl(j).resource_list_member_id AND
                       px_inf_cur_rec_tbl(j).txn_currency_code IS NULL THEN
                            px_inf_cur_rec_tbl(j).txn_currency_code := p_budget_line_tbl(i).txn_currency_code;
                    END IF;
                END LOOP;
           END LOOP;
       END IF;

       IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Leaving into pa_fp_webadi_pkg.check_and_update_txn_curr_code';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;
       IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
       END IF;
  EXCEPTION
       WHEN PA_FP_CONSTANTS_PKG.Just_Ret_Exc THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
            END IF;
            RETURN;
       WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
           l_msg_count := FND_MSG_PUB.count_msg;

           IF l_msg_count = 1 and x_msg_data IS NULL THEN
                 PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                   ,p_msg_index      => 1
                   ,p_msg_count      => l_msg_count
                   ,p_msg_data       => l_msg_data
                   ,p_data           => l_data
                   ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
           ELSE
                x_msg_count := l_msg_count;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;

           IF l_debug_mode = 'Y' THEN
               pa_debug.reset_curr_function;
           END IF;
           RETURN;

       WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := SQLERRM;

           FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                                   ,p_procedure_name  => 'check_and_update_txn_curr_code');
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;

           IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
           END IF;
           RAISE;
  END check_and_update_txn_curr_code;

  -- bug 4479036: a private function to check if the conversion
  -- attribute columns are displayed in the layout used, so that
  -- these attribute can be defaulted to null values or version
  -- level attributes accordingly.

  FUNCTION conv_attributes_displayed
            (p_run_id       IN       pa_fp_webadi_upload_inf.run_id%TYPE)
  RETURN VARCHAR2
  IS

    l_debug_mode                         VARCHAR2(1);
    l_module_name                        VARCHAR2(100) := 'PAFPWAPB.check_and_update_txn_curr_code';
    l_debug_level3                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
    l_debug_level5                       CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;

    conv_attrb_displayed                 VARCHAR2(1);

    l_projfunc_rate_type                 pa_fp_webadi_upload_inf.projfunc_rate_type%TYPE;
    l_projfunc_rate_date_type            pa_fp_webadi_upload_inf.projfunc_rate_date_type%TYPE;
    l_projfunc_rate_date                 pa_fp_webadi_upload_inf.projfunc_rate_date%TYPE;
    l_project_rate_type                  pa_fp_webadi_upload_inf.project_rate_type%TYPE;
    l_project_rate_date_type             pa_fp_webadi_upload_inf.project_rate_date_type%TYPE;
    l_project_rate_date                  pa_fp_webadi_upload_inf.project_rate_date%TYPE;


  BEGIN
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

    IF l_debug_mode = 'Y' THEN
          PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                      p_debug_mode => l_debug_mode );
    END IF;
    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Entering into pa_fp_webadi_pkg.conv_attributes_displayed';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    conv_attrb_displayed := 'N';

    IF p_run_id IS NULL THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'p_run_id is passed as null';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Checking for the values in conv attrb cols';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    BEGIN
        SELECT projfunc_rate_type,
               projfunc_rate_date_type,
               projfunc_rate_date,
               project_rate_type,
               project_rate_date_type,
               project_rate_date
        INTO   l_projfunc_rate_type,
               l_projfunc_rate_date_type,
               l_projfunc_rate_date,
               l_project_rate_type,
               l_project_rate_date_type,
               l_project_rate_date
        FROM   pa_fp_webadi_upload_inf
        WHERE  run_id = p_run_id
        AND    ROWNUM = 1;

        IF l_projfunc_rate_type <> g_hidden_col_char OR
           l_projfunc_rate_date_type <> g_hidden_col_char OR
           l_projfunc_rate_date <> g_hidden_col_date OR
           l_project_rate_type <> g_hidden_col_char OR
           l_project_rate_date_type <> g_hidden_col_char OR
           l_project_rate_date <> g_hidden_col_date THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Conv attrb cols displayed in layout';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;
            conv_attrb_displayed := 'Y';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'No rows in the interface table';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;
            conv_attrb_displayed := 'N';
    END;


    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Leaving into pa_fp_webadi_pkg.conv_attributes_displayed';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage := 'conv_attrb_displayed: ' || conv_attrb_displayed;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;
    IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
    END IF;

    -- returning
    RETURN conv_attrb_displayed;

  EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Invalid_Arg_Exc raised in conv_attributes_displayed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;
           IF l_debug_mode = 'Y' THEN
               pa_debug.reset_curr_function;
           END IF;
           RAISE;

       WHEN OTHERS THEN
           FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                                   ,p_procedure_name  => 'conv_attributes_displayed');
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
           END IF;

           IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
           END IF;
           RAISE;
  END conv_attributes_displayed;

  PROCEDURE prepare_val_input
      ( p_run_id                   IN         pa_fp_webadi_upload_inf.run_id%TYPE,
        p_request_id               IN         pa_budget_versions.request_id%TYPE    DEFAULT  NULL,
        p_version_info_rec         IN         pa_fp_gen_amount_utils.fp_cols,
        p_prd_start_date_tbl       IN         SYSTEM.PA_DATE_TBL_TYPE,
        p_prd_end_date_tbl         IN         SYSTEM.PA_DATE_TBL_TYPE,
        p_org_id                   IN         pa_projects_all.org_id%TYPE,
        x_budget_lines             OUT        NOCOPY PA_BUDGET_PUB.G_budget_lines_in_tbl%TYPE, --File.Sql.39 bug 4440895
        x_etc_quantity_tbl         OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_etc_raw_cost_tbl         OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_etc_burdened_cost_tbl    OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_etc_revenue_tbl          OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_raw_cost_rate_tbl        OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_burd_cost_rate_tbl       OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_bill_rate_tbl            OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_planning_start_date_tbl  OUT        NOCOPY SYSTEM.PA_DATE_TBL_TYPE, --File.Sql.39 bug 4440895
        x_planning_end_date_tbl    OUT        NOCOPY SYSTEM.PA_DATE_TBL_TYPE, --File.Sql.39 bug 4440895
        x_uom_tbl                  OUT        NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE, --File.Sql.39 bug 4440895
        x_mfc_cost_type_tbl        OUT        NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE, --File.Sql.39 bug 4440895
        x_spread_curve_name_tbl    OUT        NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE, --File.Sql.39 bug 4440895
        x_sp_fixed_date_tbl        OUT        NOCOPY SYSTEM.PA_DATE_TBL_TYPE, --File.Sql.39 bug 4440895
        x_etc_method_name_tbl      OUT        NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE, --File.Sql.39 bug 4440895
        x_spread_curve_id_tbl      OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_delete_flag_tbl          OUT        NOCOPY SYSTEM.PA_VARCHAR2_1_TBL_TYPE, --File.Sql.39 bug 4440895
        x_ra_id_tbl                OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_res_class_code_tbl       OUT        NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE, --File.Sql.39 bug 4440895
        x_rate_based_flag_tbl      OUT        NOCOPY SYSTEM.PA_VARCHAR2_1_TBL_TYPE, --File.Sql.39 bug 4440895
        x_rbs_elem_id_tbl          OUT        NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --File.Sql.39 bug 4440895
        x_amt_type_tbl             OUT        NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE, --File.Sql.39 bug 4440895
        x_first_pd_bf_pm_en_dt     OUT        NOCOPY DATE, --File.Sql.39 bug 4440895
        x_last_pd_af_pm_st_dt      OUT        NOCOPY DATE, --File.Sql.39 bug 4440895
        x_inf_tbl_rec_tbl          OUT        NOCOPY inf_cur_tbl_typ, --File.Sql.39 bug 4440895
        x_num_of_rec_processed     OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_return_status            OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count                OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_msg_data                 OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS

      l_return_status                     VARCHAR2(30);
      l_msg_data                          VARCHAR2(2000);
      l_msg_count                         NUMBER;

      l_debug_mode                        VARCHAR2(1);
      l_module_name                       VARCHAR2(100) := 'pa_fp_webadi_pkg.prepare_val_input';
      l_debug_level3                      CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
      l_debug_level5                      CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;
      l_msg_index_out                     NUMBER;
      l_data                              VARCHAR2(2000);

      -- variable to held the start_date and end_date of individual periods
      l_prd_start_date_tbl                SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
      l_prd_end_date_tbl                  SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();

      l_inf_tbl_data_prev_rec             inf_tbl_data_csr%ROWTYPE;
      l_inf_tbl_data_curr_rec             inf_tbl_data_csr%ROWTYPE;
      l_inf_tbl_data_next_rec             inf_tbl_data_csr%ROWTYPE;
      -- record type used to skip the duplicate records
      l_inf_tbl_data_skip_rec             inf_tbl_data_csr%ROWTYPE;
      l_loop_exit_flag                    VARCHAR2(1) := 'N';

      i                                   INTEGER := 0;
      l_uncategorized_flag                pa_resource_lists_all_bg.uncategorized_flag%TYPE;
      l_prc_error_code                    VARCHAR2(30);

      l_unct_rlm_id                      pa_resource_list_members.resource_list_member_id%TYPE;
      l_etc_start_date                   pa_budget_versions.etc_start_date%TYPE;

      l_plan_trans_attr_copied_flag      VARCHAR2(1);
      l_cost_conv_attr_copied_flag       VARCHAR2(1);
      l_rev_conv_attr_copied_flag        VARCHAR2(1);
      l_plan_start_date                  DATE;
      l_plan_end_date                    DATE;
      l_prcd_pd_start_date               DATE;
      l_prcd_pd_end_date                 DATE;
      l_original_prd_count               INTEGER;
      l_int_new_prd_count                INTEGER;
      l_scd_pd_start_date                DATE;
      l_scd_pd_end_date                  DATE;
      l_first_pd_bf_pm_st_dt             DATE;   /* variable to hold the start date of the first period that falls before first period in the period mask */
      l_first_pd_bf_pm_en_dt             DATE;   /* variable to hold the end date of the first period that falls before first period in the period mask */
      l_last_pd_af_pm_st_dt              DATE;   /* variable to hold the start date of the last period that falls before last period in the period mask */
      l_last_pd_af_pm_en_dt              DATE;   /* variable to hold the end date of the last period that falls before last period in the period mask */
      is_forecast_version                VARCHAR2(1) := 'N';
      is_periodic_setup                  VARCHAR2(1) := 'N';
      l_bdgt_line_start_date             DATE;
      l_bdgt_line_end_date               DATE;
      l_min_bdgt_line_start_date         DATE;
      l_max_bdgt_line_end_date           DATE;
      l_sysdate                          CONSTANT DATE:= SYSDATE;

      l_tmp_sum_amt                      NUMBER;
      l_raw_cost                         NUMBER;
      l_etc_raw_cost                     NUMBER;
      l_burdened_cost                    NUMBER;
      l_etc_burdened_cost                NUMBER;
      l_revenue                          NUMBER;
      l_etc_revenue                      NUMBER;
      l_quantity                         NUMBER;
      l_etc_quantity                     NUMBER;

      l_projfunc_cost_rate               pa_budget_lines.projfunc_cost_exchange_rate%TYPE;
      l_projfunc_rev_rate                pa_budget_lines.projfunc_rev_exchange_rate%TYPE;
      l_project_cost_rate                pa_budget_lines.project_cost_exchange_rate%TYPE;
      l_project_rev_rate                 pa_budget_lines.project_rev_exchange_rate%TYPE;


      -- variable to keep track of number of records inserted to the budget line record type
      bl_count                           INTEGER := 1;

      -- variables to be used to pass data to validate_budget_line
      l_budget_line_in_out_tbl           PA_BUDGET_PUB.G_budget_lines_in_tbl%TYPE;
      l_budget_line_out_tbl              PA_BUDGET_PUB.G_budget_lines_in_tbl%TYPE;

      l_amount_set_id                    pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
      l_allow_qty_flag                   VARCHAR2(1);

      l_bdgt_ln_tbl_description          VARCHAR2(255);
      l_pfunc_cost_rate_type_mning          pa_conversion_types_v.user_conversion_type%TYPE;
      l_pfunc_cost_rate_dt_typ_mning        pa_lookups.meaning%TYPE;
      l_pfunc_rev_rate_type_mning           pa_conversion_types_v.user_conversion_type%TYPE;
      l_pfunc_rev_rate_dt_typ_mning         pa_lookups.meaning%TYPE;
      l_prj_cost_rate_type_mning            pa_conversion_types_v.user_conversion_type%TYPE;
      l_prj_cost_rate_dt_typ_mning          pa_lookups.meaning%TYPE;
      l_prj_rev_rate_type_mning             pa_conversion_types_v.user_conversion_type%TYPE;
      l_prj_rev_rate_date_type_mning        pa_lookups.meaning%TYPE;

      d_projfunc_cost_rate_type          pa_proj_fp_options.projfunc_cost_rate_type%TYPE     ;
      d_projfunc_cost_rate_date_type     pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE;
      d_projfunc_cost_rate_date          pa_proj_fp_options.projfunc_cost_rate_date%TYPE     ;
      d_projfunc_rev_rate_type           pa_proj_fp_options.projfunc_rev_rate_type%TYPE      ;
      d_projfunc_rev_rate_date_type      pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE ;
      d_projfunc_rev_rate_date           pa_proj_fp_options.projfunc_rev_rate_date%TYPE      ;
      d_project_cost_rate_type           pa_proj_fp_options.project_cost_rate_type%TYPE      ;
      d_project_cost_rate_date_type      pa_proj_fp_options.project_cost_rate_date_type%TYPE ;
      d_project_cost_rate_date           pa_proj_fp_options.project_cost_rate_date%TYPE      ;
      d_project_rev_rate_type            pa_proj_fp_options.project_rev_rate_type%TYPE       ;
      d_project_rev_rate_date_type       pa_proj_fp_options.project_rev_rate_date_type%TYPE  ;
      d_project_rev_rate_date            pa_proj_fp_options.project_rev_rate_date%TYPE       ;
      d_projfunc_cost_exc_rate_tab       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      d_projfunc_rev_exc_rate_tab        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      d_project_cost_exc_rate_tab        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      d_project_rev_exc_rate_tab         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      d_txn_curr_tab                     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

      l_projfunc_cost_rate_type          pa_proj_fp_options.projfunc_cost_rate_type%TYPE     ;
      l_projfunc_cost_rate_date_type     pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE;
      l_projfunc_cost_rate_date          pa_proj_fp_options.projfunc_cost_rate_date%TYPE     ;
      l_projfunc_cost_exchange_rate      pa_budget_lines.projfunc_cost_exchange_rate%TYPE    ;
      l_projfunc_rev_rate_type           pa_proj_fp_options.projfunc_rev_rate_type%TYPE      ;
      l_projfunc_rev_rate_date_type      pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE ;
      l_projfunc_rev_rate_date           pa_proj_fp_options.projfunc_rev_rate_date%TYPE      ;
      l_projfunc_rev_exchange_rate       pa_budget_lines.projfunc_rev_exchange_rate%TYPE     ;
      l_project_cost_rate_type           pa_proj_fp_options.project_cost_rate_type%TYPE      ;
      l_project_cost_rate_date_type      pa_proj_fp_options.project_cost_rate_date_type%TYPE ;
      l_project_cost_rate_date           pa_proj_fp_options.project_cost_rate_date%TYPE      ;
      l_project_cost_exchange_rate       pa_budget_lines.project_cost_exchange_rate%TYPE     ;
      l_project_rev_rate_type            pa_proj_fp_options.project_rev_rate_type%TYPE       ;
      l_project_rev_rate_date_type       pa_proj_fp_options.project_rev_rate_date_type%TYPE  ;
      l_project_rev_rate_date            pa_proj_fp_options.project_rev_rate_date%TYPE       ;
      l_project_rev_exchange_rate        pa_budget_lines.project_rev_exchange_rate%TYPE      ;
      l_change_reason_code               pa_budget_lines.change_reason_code%TYPE             ;

      l_rc_rate                          NUMBER;
      l_bc_rate                          NUMBER;
      l_bill_rate                        NUMBER;

      l_etc_quantity_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_etc_raw_cost_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_etc_burdened_cost_tbl            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_etc_revenue_tbl                  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_rc_rate_tbl                      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bc_rate_tbl                      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bill_rate_tbl                    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_uom_tbl                          SYSTEM.pa_varchar2_80_tbl_type := SYSTEM.pa_varchar2_80_tbl_type();
      l_plan_start_date_tbl              SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_delete_flag                      VARCHAR2(1);
      l_plan_end_date_tbl                SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_delete_flag_tbl                  SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_spread_curve_name_tbl            SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
      l_etc_method_code_tbl              SYSTEM.pa_varchar2_80_tbl_type := SYSTEM.pa_varchar2_80_tbl_type();
      l_mfc_cost_type_name_tbl           SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
      l_sp_fixed_date_tbl                SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_spread_curve_id_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

      -- variables to be used to call process_errors
      l_err_val_code_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_err_task_id_tbl                  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_err_rlm_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
      l_err_txn_curr_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_err_amt_type_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

      l_fixed_spread_curve_id            pa_spread_curves_b.spread_curve_id%TYPE;
      l_fixed_spread_curve_name          pa_spread_curves_tl.name%TYPE;
      l_spread_curve_id                  pa_spread_curves_b.spread_curve_id%TYPE;
      l_sp_fixed_date                    pa_resource_assignments.sp_fixed_date%TYPE;
      l_not_null_period_cnt              NUMBER;
      l_fix_sc_amt_pd_curr_index         NUMBER; /* to get the period index for which amount is present if the spread curve */
      l_fix_sc_amt_pd_next_index         NUMBER; /* associated with the resource is fixed date type */

      /* Bug 5144013: The following variable declarations are made to refer the new entity
         pa_resource_asgn_curr columns. This is done as part of merging MRUP3 changes done
         in 11i into R12.
      */
      l_ratxn_total_quantity             pa_resource_asgn_curr.total_quantity%TYPE;
      l_ratxn_total_raw_cost             pa_resource_asgn_curr.total_txn_raw_cost%TYPE;
      l_ratxn_total_burdened_cost        pa_resource_asgn_curr.total_txn_burdened_cost%TYPE;
      l_ratxn_total_revenue              pa_resource_asgn_curr.total_txn_revenue%TYPE;
      l_ratxn_raw_cost_over_rate         pa_resource_asgn_curr.txn_raw_cost_rate_override%TYPE;
      l_ratxn_burden_cost_over_rate      pa_resource_asgn_curr.txn_burden_cost_rate_override%TYPE;
      l_ratxn_bill_over_rate             pa_resource_asgn_curr.txn_bill_rate_override%TYPE;
      l_ratxn_etc_quantity               pa_resource_asgn_curr.total_quantity%TYPE;
      l_ratxn_etc_raw_cost               pa_resource_asgn_curr.total_txn_raw_cost%TYPE;
      l_ratxn_etc_burdened_cost          pa_resource_asgn_curr.total_txn_burdened_cost%TYPE;
      l_ratxn_etc_revenue                pa_resource_asgn_curr.total_txn_revenue%TYPE;
      l_ra_rate_based_flag               pa_resource_assignments.rate_based_flag%TYPE; -- Bug 5068203.


      -- cursor to get the start/end date of the first period before the first period displayed in the period mask
      CURSOR l_first_pd_st_en_dt_csr (c_org_id   pa_projects_all.org_id%TYPE,
                                      c_first_prd_st_dt   DATE,
                                      c_time_phased_code  pa_proj_fp_options.cost_time_phased_code%TYPE)
      IS
      SELECT gl.start_date start_date,
             gl.end_date end_date,
             gl.period_name period_name
      FROM   gl_periods gl,
             pa_implementations_all pim,
             gl_sets_of_books gsb
      WHERE  gl.end_date < c_first_prd_st_dt
      AND    gl.period_set_name = DECODE(c_time_phased_code,'P',pim.period_set_name,'G',gsb.period_set_name)
      AND    gl.period_type = DECODE(c_time_phased_code,'P',pim.pa_period_type,'G',gsb.accounted_period_type)
      AND    gl.adjustment_period_flag='N'
      AND    pim.org_id = c_org_id
      AND    gsb.set_of_books_id = pim.set_of_books_id
      ORDER BY gl.start_date DESC;

      l_first_pd_st_en_dt_rec        l_first_pd_st_en_dt_csr%ROWTYPE;

      -- cursor to get the start/end date of the last period before the last period displayed in the period mask
      CURSOR l_last_pd_st_en_dt_csr (c_org_id   pa_projects_all.org_id%TYPE,
                                     c_last_prd_en_dt   DATE,
                                     c_time_phased_code  pa_proj_fp_options.cost_time_phased_code%TYPE)
      IS
      SELECT gl.start_date start_date,
             gl.end_date end_date,
             gl.period_name period_name
      FROM   gl_periods gl,
             pa_implementations_all pim,
             gl_sets_of_books gsb
      WHERE  gl.end_date > c_last_prd_en_dt
      AND    gl.period_set_name = DECODE(c_time_phased_code,'P',pim.period_set_name,'G',gsb.period_set_name)
      AND    gl.period_type = DECODE(c_time_phased_code,'P',pim.pa_period_type,'G',gsb.accounted_period_type)
      AND    gl.adjustment_period_flag='N'
      AND    pim.org_id = c_org_id
      AND    gsb.set_of_books_id = pim.set_of_books_id
      ORDER BY gl.start_date ;

      l_last_pd_st_en_dt_rec         l_last_pd_st_en_dt_csr%ROWTYPE;

      /* Bug 5144013: Made changes in the query of the cursor non_prd_lyt_null_val_cur to refer to the
         new entity pa_resource_asgn_curr. This is done as part of merging MRUP3 changes done in 11i
         into R12.
      */
      CURSOR non_prd_lyt_null_val_cur(c_budget_version_id IN pa_budget_versions.budget_version_id%TYPE,
                                      c_task_id IN pa_resource_assignments.task_id%TYPE,
                                      c_resource_list_member_id IN pa_resource_assignments.resource_list_member_id%TYPE,
                                      c_txn_currency_code IN pa_resource_asgn_curr.txn_currency_code%TYPE)
      IS
      SELECT rac.total_display_quantity,
             rac.total_txn_raw_cost,
             rac.total_txn_burdened_cost,
             rac.total_txn_revenue,
             rac.total_display_quantity-NVL(rac.total_init_quantity,0),
             rac.total_txn_raw_cost-NVL(rac.total_txn_init_raw_cost,0),
             rac.total_txn_burdened_cost-NVL(rac.total_txn_init_burdened_cost,0),
             rac.total_txn_revenue-NVL(rac.total_txn_init_revenue,0),
             rac.txn_raw_cost_rate_override,
             rac.txn_burden_cost_rate_override,
             rac.txn_bill_rate_override,
             pra.rate_based_flag
      FROM   pa_resource_asgn_curr rac,
             pa_resource_assignments pra
      WHERE rac.budget_version_id = c_budget_version_id
      AND   rac.budget_version_id = pra.budget_version_id
      AND   rac.resource_assignment_id = pra.resource_assignment_id
      AND   pra.task_id = c_task_id
      AND   pra.resource_list_member_id = c_resource_list_member_id
      AND   rac.txn_currency_code = c_txn_currency_code;

      TYPE l_cached_ra_id_info IS TABLE OF NUMBER INDEX BY VARCHAR2(32);

      l_cached_ra_id_tbl       l_cached_ra_id_info;
      l_cached_ra_index        VARCHAR2(32);
      l_ra_id                  pa_resource_assignments.resource_assignment_id%TYPE;
      l_start_ra_index         NUMBER :=1;
      l_end_ra_index           NUMBER :=1;
      l_sp_fix_prd_st_dt       DATE;
      l_sp_fix_prd_en_dt       DATE;

      l_res_class_code         pa_resource_assignments.resource_class_code%TYPE;
      l_rate_based_flag        pa_resource_assignments.rate_based_flag%TYPE;
      l_rbs_elem_id            pa_resource_assignments.rbs_element_id%TYPE;

      l_ra_id_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_res_class_code_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_rate_based_flag_tbl    SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_rbs_elem_id_tbl        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

      l_min_ra_plan_start_date DATE;
      l_max_ra_plan_end_date   DATE;

      l_amount_type_tbl        SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_lookup_type            pa_lookups.lookup_type%TYPE;
      l_amount                 NUMBER;
      --l_temp                   DATE;

     -- Added for the bug 4414062
      l_period_time_phased_code  VARCHAR(1);
      l_period_plan_start_date   DATE;
      l_period_plan_end_date     DATE;
      l_rl_control_flag          pa_resource_lists_all_bg.control_flag%TYPE;
      l_fin_struct_id            NUMBER; -- Bug 4929163.

      -- bug 4479036
      l_conv_attrb_displayed     VARCHAR(1);

      --Added thses date tables for bug#4488926.
      TYPE date_tbl_type IS TABLE OF DATE INDEX BY VARCHAR2(20);
      l_period_plan_start_date_tbl    date_tbl_type;
      l_period_plan_end_date_tbl      date_tbl_type;
BEGIN

      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                  p_debug_mode => l_debug_mode );

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Entering into pa_fp_webadi_pkg.prepare_val_input';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      --log1('----- Entering into prepare_val_input-------');
      -- deriving all the required version level info
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'validating input';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
      l_fin_struct_id := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUCTURE_ID(p_version_info_rec.x_project_id);    /* Bug 4929163 */
      IF p_version_info_rec.x_project_id IS NULL THEN
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'project_id not passed';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           pa_utils.add_message
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                 p_token1          => 'PROCEDURENAME',
                 p_value1          => l_module_name);
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- checking is org_id is passed as null for periodic layouts
      IF (p_prd_start_date_tbl.COUNT > 0 OR
          p_prd_end_date_tbl.COUNT > 0 ) AND
         p_org_id IS NULL THEN
            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'org_id not passed for periodic layouts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           pa_utils.add_message
                (p_app_short_name  => 'PA',
                 p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                 p_token1          => 'PROCEDURENAME',
                 p_value1          => l_module_name);
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- initializing the out parameter for number of records processed
      x_num_of_rec_processed := 0;

      l_conv_attrb_displayed := 'N';

      -- updating the temp table with the task_id for the task name/ task number
      -- given in the excel after deriving the same. if not a valid task, leaving
      -- task_id column null
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Updating task_id for the task name/number given';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      --log1('----- STAGE 1-------');
      BEGIN
            -- Bug 4464838: Perf Fix: Selecting the control_flag for the
            -- resource list and depending upon the value returned, executing
            -- one of the update statments to improve the performance by avoiding
            -- the select for control flag for each record and as well, removing
            -- the OR cluase from the where clause.
            SELECT  control_flag,
                    uncategorized_flag
            INTO    l_rl_control_flag,
                    l_uncategorized_flag
            FROM    pa_resource_lists_all_bg
            WHERE   resource_list_id = p_version_info_rec.x_resource_list_id;

            --log1('----- STAGE 3.2------- '||l_uncategorized_flag);
            IF l_uncategorized_flag = 'N' THEN
                 IF l_rl_control_flag = 'N' THEN
                      -- updating the rlm ids for categorized resource lists with control_fl as N
                     UPDATE  pa_fp_webadi_upload_inf inf
                     SET     inf.task_id = (SELECT  pt.task_id
                                            FROM    (SELECT  pt.name task_name,   /* Bug 4929163. Modified the select statement to refer to pa_proj_elements instead of pa_tasks*/
                                                             pt.element_number task_number,
                                                             pt.proj_element_id task_id
                                                     FROM    pa_proj_elements pt
                                                     WHERE   pt.project_id = p_version_info_rec.x_project_id
                                                     AND     object_type = 'PA_TASKS'
                                                     AND     parent_structure_id = l_fin_struct_id
                                                     UNION ALL
                                                     SELECT  p.long_name task_name,  /* Bug 5345336 */
                                                             p.segment1 task_number,
                                                             0 task_id
                                                     FROM    pa_projects_all p
                                                     WHERE   p.project_id = p_version_info_rec.x_project_id) pt
                                            WHERE    (inf.task_name IS NOT NULL
                                                      AND inf.task_number IS NULL
                                                      AND inf.task_name = pt.task_name) OR
                                                     (inf.task_name IS NULL
                                                      AND inf.task_number IS NOT NULL
                                                      AND inf.task_number = pt.task_number) OR
                                                     (inf.task_name IS NOT NULL
                                                      AND inf.task_number IS NOT NULL
                                                      AND inf.task_name = pt.task_name
                                                      AND inf.task_number = pt.task_number)),

                              inf.change_reason_code           = DECODE(inf.delete_flag,'Y',NULL,inf.change_reason_code),
                              inf.quantity                     = DECODE(inf.delete_flag,'Y',NULL,inf.quantity),
                              inf.raw_cost                     = DECODE(inf.delete_flag,'Y',NULL,inf.raw_cost),
                              inf.raw_cost_over_rate           = DECODE(inf.delete_flag,'Y',NULL,inf.raw_cost_over_rate),
                              inf.burdened_cost                = DECODE(inf.delete_flag,'Y',NULL,inf.burdened_cost),
                              inf.burdened_cost_over_rate      = DECODE(inf.delete_flag,'Y',NULL,inf.burdened_cost_over_rate),
                              inf.revenue                      = DECODE(inf.delete_flag,'Y',NULL,inf.revenue),
                              inf.bill_over_rate               = DECODE(inf.delete_flag,'Y',NULL,inf.bill_over_rate ),
                              inf.projfunc_cost_rate_type      = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_rate_type),
                              inf.projfunc_cost_rate_date_type = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_rate_date_type),
                              inf.projfunc_cost_exchange_rate  = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_exchange_rate ),
                              inf.projfunc_cost_rate_date      = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.projfunc_cost_rate_date),
                              inf.project_cost_rate_type       = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_rate_type),
                              inf.project_cost_rate_date_type  = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_rate_date_type),
                              inf.project_cost_exchange_rate   = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_exchange_rate),
                              inf.project_cost_rate_date       = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.project_cost_rate_date),
                              inf.projfunc_rev_rate_type       = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_rate_type      ),
                              inf.projfunc_rev_rate_date_type  = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_rate_date_type ),
                              inf.projfunc_rev_exchange_rate   = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_exchange_rate  ),
                              inf.projfunc_rev_rate_date       = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.projfunc_rev_rate_date),
                              inf.project_rev_rate_type        = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_rate_type       ),
                              inf.project_rev_rate_date_type   = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_rate_date_type  ),
                              inf.project_rev_exchange_rate    = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_exchange_rate   ),
                              inf.project_rev_rate_date        = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.project_rev_rate_date),
                              inf.projfunc_rate_type           = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rate_type          ),
                              inf.projfunc_rate_date_type      = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rate_date_type     ),
                              inf.projfunc_exchange_rate       = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_exchange_rate      ),
                              inf.projfunc_rate_date           = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.projfunc_rate_date),
                              inf.project_rate_type            = DECODE(inf.delete_flag,'Y',NULL,inf.project_rate_type           ),
                              inf.project_rate_date_type       = DECODE(inf.delete_flag,'Y',NULL,inf.project_rate_date_type      ),
                              inf.project_exchange_rate        = DECODE(inf.delete_flag,'Y',NULL,inf.project_exchange_rate       ),
                              inf.project_rate_date            = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.project_rate_date),
                              inf.pd_prd                       = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.pd_prd),
                              inf.prd1                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd1  ),
                              inf.prd2                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd2  ),
                              inf.prd3                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd3  ),
                              inf.prd4                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd4  ),
                              inf.prd5                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd5  ),
                              inf.prd6                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd6  ),
                              inf.prd7                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd7  ),
                              inf.prd8                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd8  ),
                              inf.prd9                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd9  ),
                              inf.prd10                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd10 ),
                              inf.prd11                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd11 ),
                              inf.prd12                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd12 ),
                              inf.prd13                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd13 ),
                              inf.prd14                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd14 ),
                              inf.prd15                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd15 ),
                              inf.prd16                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd16 ),
                              inf.prd17                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd17 ),
                              inf.prd18                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd18 ),
                              inf.prd19                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd19 ),
                              inf.prd20                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd20 ),
                              inf.prd21                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd21 ),
                              inf.prd22                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd22 ),
                              inf.prd23                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd23 ),
                              inf.prd24                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd24 ),
                              inf.prd25                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd25 ),
                              inf.prd26                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd26 ),
                              inf.prd27                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd27 ),
                              inf.prd28                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd28 ),
                              inf.prd29                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd29 ),
                              inf.prd30                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd30 ),
                              inf.prd31                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd31 ),
                              inf.prd32                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd32 ),
                              inf.prd33                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd33 ),
                              inf.prd34                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd34 ),
                              inf.prd35                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd35 ),
                              inf.prd36                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd36 ),
                              inf.prd37                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd37 ),
                              inf.prd38                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd38 ),
                              inf.prd39                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd39 ),
                              inf.prd40                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd40 ),
                              inf.prd41                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd41 ),
                              inf.prd42                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd42 ),
                              inf.prd43                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd43 ),
                              inf.prd44                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd44 ),
                              inf.prd45                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd45 ),
                              inf.prd46                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd46 ),
                              inf.prd47                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd47 ),
                              inf.prd48                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd48 ),
                              inf.prd49                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd49 ),
                              inf.prd50                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd50 ),
                              inf.prd51                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd51 ),
                              inf.prd52                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd52 ),
                              inf.sd_prd                       = DECODE(inf.delete_flag,'Y',l_fnd_miss_num , inf.sd_prd),
                              inf.resource_list_member_id      = (SELECT rlm.resource_list_member_id
                                                                  FROM   pa_resource_list_members rlm
                                                                  WHERE  inf.resource_alias = rlm.alias
                                                                  AND    rlm.resource_list_id = p_version_info_rec.x_resource_list_id
                                                                  AND    rlm.object_type = 'PROJECT'
                                                                  AND    rlm.object_id = p_version_info_rec.x_project_id)
                     WHERE    inf.run_id= p_run_id
                     AND      Nvl(p_request_id, -99) = Nvl(inf.request_id, -99);

                 ELSE -- control_flag = Y
                      -- updating the rlm ids for categorized resource lists with control_fl as Y
                     UPDATE  pa_fp_webadi_upload_inf inf
                     SET     inf.task_id = (SELECT  pt.task_id
                                            FROM    (SELECT  pt.name task_name, /* Bug 4929163. Modified the select statement to refer to pa_proj_elements instead of pa_tasks*/
                                                             pt.element_number task_number,
                                                             pt.proj_element_id task_id
                                                     FROM    pa_proj_elements pt
                                                     WHERE   pt.project_id = p_version_info_rec.x_project_id
                                                     AND     object_type = 'PA_TASKS'
                                                     AND     parent_structure_id = l_fin_struct_id
                                                     UNION ALL
                                                     SELECT  p.long_name task_name,  /* Bug 5345336 */
                                                             p.segment1 task_number,
                                                             0 task_id
                                                     FROM    pa_projects_all p
                                                     WHERE   p.project_id = p_version_info_rec.x_project_id) pt
                                            WHERE    (inf.task_name IS NOT NULL
                                                      AND inf.task_number IS NULL
                                                      AND inf.task_name = pt.task_name) OR
                                                     (inf.task_name IS NULL
                                                      AND inf.task_number IS NOT NULL
                                                      AND inf.task_number = pt.task_number) OR
                                                     (inf.task_name IS NOT NULL
                                                      AND inf.task_number IS NOT NULL
                                                      AND inf.task_name = pt.task_name
                                                      AND inf.task_number = pt.task_number)),

                              inf.change_reason_code           = DECODE(inf.delete_flag,'Y',NULL,inf.change_reason_code),
                              inf.quantity                     = DECODE(inf.delete_flag,'Y',NULL,inf.quantity),
                              inf.raw_cost                     = DECODE(inf.delete_flag,'Y',NULL,inf.raw_cost),
                              inf.raw_cost_over_rate           = DECODE(inf.delete_flag,'Y',NULL,inf.raw_cost_over_rate),
                              inf.burdened_cost                = DECODE(inf.delete_flag,'Y',NULL,inf.burdened_cost),
                              inf.burdened_cost_over_rate      = DECODE(inf.delete_flag,'Y',NULL,inf.burdened_cost_over_rate),
                              inf.revenue                      = DECODE(inf.delete_flag,'Y',NULL,inf.revenue),
                              inf.bill_over_rate               = DECODE(inf.delete_flag,'Y',NULL,inf.bill_over_rate ),
                              inf.projfunc_cost_rate_type      = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_rate_type),
                              inf.projfunc_cost_rate_date_type = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_rate_date_type),
                              inf.projfunc_cost_exchange_rate  = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_exchange_rate ),
                              inf.projfunc_cost_rate_date      = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.projfunc_cost_rate_date),
                              inf.project_cost_rate_type       = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_rate_type),
                              inf.project_cost_rate_date_type  = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_rate_date_type),
                              inf.project_cost_exchange_rate   = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_exchange_rate),
                              inf.project_cost_rate_date       = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.project_cost_rate_date),
                              inf.projfunc_rev_rate_type       = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_rate_type      ),
                              inf.projfunc_rev_rate_date_type  = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_rate_date_type ),
                              inf.projfunc_rev_exchange_rate   = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_exchange_rate  ),
                              inf.projfunc_rev_rate_date       = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.projfunc_rev_rate_date),
                              inf.project_rev_rate_type        = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_rate_type       ),
                              inf.project_rev_rate_date_type   = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_rate_date_type  ),
                              inf.project_rev_exchange_rate    = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_exchange_rate   ),
                              inf.project_rev_rate_date        = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.project_rev_rate_date),
                              inf.projfunc_rate_type           = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rate_type          ),
                              inf.projfunc_rate_date_type      = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rate_date_type     ),
                              inf.projfunc_exchange_rate       = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_exchange_rate      ),
                              inf.projfunc_rate_date           = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.projfunc_rate_date),
                              inf.project_rate_type            = DECODE(inf.delete_flag,'Y',NULL,inf.project_rate_type           ),
                              inf.project_rate_date_type       = DECODE(inf.delete_flag,'Y',NULL,inf.project_rate_date_type      ),
                              inf.project_exchange_rate        = DECODE(inf.delete_flag,'Y',NULL,inf.project_exchange_rate       ),
                              inf.project_rate_date            = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.project_rate_date),
                              inf.pd_prd                       = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.pd_prd),
                              inf.prd1                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd1  ),
                              inf.prd2                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd2  ),
                              inf.prd3                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd3  ),
                              inf.prd4                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd4  ),
                              inf.prd5                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd5  ),
                              inf.prd6                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd6  ),
                              inf.prd7                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd7  ),
                              inf.prd8                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd8  ),
                              inf.prd9                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd9  ),
                              inf.prd10                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd10 ),
                              inf.prd11                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd11 ),
                              inf.prd12                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd12 ),
                              inf.prd13                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd13 ),
                              inf.prd14                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd14 ),
                              inf.prd15                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd15 ),
                              inf.prd16                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd16 ),
                              inf.prd17                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd17 ),
                              inf.prd18                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd18 ),
                              inf.prd19                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd19 ),
                              inf.prd20                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd20 ),
                              inf.prd21                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd21 ),
                              inf.prd22                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd22 ),
                              inf.prd23                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd23 ),
                              inf.prd24                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd24 ),
                              inf.prd25                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd25 ),
                              inf.prd26                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd26 ),
                              inf.prd27                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd27 ),
                              inf.prd28                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd28 ),
                              inf.prd29                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd29 ),
                              inf.prd30                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd30 ),
                              inf.prd31                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd31 ),
                              inf.prd32                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd32 ),
                              inf.prd33                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd33 ),
                              inf.prd34                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd34 ),
                              inf.prd35                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd35 ),
                              inf.prd36                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd36 ),
                              inf.prd37                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd37 ),
                              inf.prd38                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd38 ),
                              inf.prd39                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd39 ),
                              inf.prd40                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd40 ),
                              inf.prd41                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd41 ),
                              inf.prd42                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd42 ),
                              inf.prd43                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd43 ),
                              inf.prd44                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd44 ),
                              inf.prd45                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd45 ),
                              inf.prd46                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd46 ),
                              inf.prd47                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd47 ),
                              inf.prd48                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd48 ),
                              inf.prd49                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd49 ),
                              inf.prd50                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd50 ),
                              inf.prd51                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd51 ),
                              inf.prd52                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd52 ),
                              inf.sd_prd                       = DECODE(inf.delete_flag,'Y',l_fnd_miss_num , inf.sd_prd),
                              inf.resource_list_member_id      = (SELECT rlm.resource_list_member_id
                                                                  FROM   pa_resource_list_members rlm
                                                                  WHERE  inf.resource_alias = rlm.alias
                                                                  AND    rlm.resource_list_id = p_version_info_rec.x_resource_list_id
                                                                  AND    rlm.object_type = 'RESOURCE_LIST'
                                                                  AND    rlm.object_id = p_version_info_rec.x_resource_list_id)
                     WHERE    inf.run_id= p_run_id
                     AND      Nvl(p_request_id, -99) = Nvl(inf.request_id, -99);
                 END IF; -- control_flag = N

            ELSE -- Resource list is not categorized
                  --log1('----- STAGE 3.3------- '||l_unct_rlm_id);
                  -- update the rlm id columns with rlm id of FINANCIAL_ELEMENTS, if the resource list
                  -- is uncategorized one

                  -- 4497319.Perf Fix:Added two AND conditions in the WHERE clause in order to improve the performance.
                  SELECT resource_list_member_id
                  INTO   l_unct_rlm_id
                  FROM   pa_resource_list_members
                  WHERE  resource_list_id = p_version_info_rec.x_resource_list_id
                  AND    resource_class_flag = 'Y'
                  AND    resource_class_code = 'FINANCIAL_ELEMENTS'
                  AND    object_type = 'RESOURCE_LIST'
                  AND    object_id = p_version_info_rec.x_resource_list_id;

                  --log1('----- STAGE 3.4------- '||l_unct_rlm_id);
                 UPDATE  pa_fp_webadi_upload_inf inf
                 SET     inf.task_id = (SELECT  pt.task_id
                                        FROM    (SELECT  pt.name task_name, /* Bug 4929163. Modidfied the select statement to refer to pa_proj_elements instead of pa_tasks*/
                                                         pt.element_number task_number,
                                                         pt.proj_element_id task_id
                                                 FROM    pa_proj_elements pt
                                                 WHERE   pt.project_id = p_version_info_rec.x_project_id
                                                 AND     object_type = 'PA_TASKS'
                                                 AND     parent_structure_id = l_fin_struct_id
                                                 UNION ALL
                                                 SELECT  p.long_name task_name,  /* Bug 5345336 */
                                                         p.segment1 task_number,
                                                         0 task_id
                                                 FROM    pa_projects_all p
                                                 WHERE   p.project_id = p_version_info_rec.x_project_id) pt
                                        WHERE    (inf.task_name IS NOT NULL
                                                  AND inf.task_number IS NULL
                                                  AND inf.task_name = pt.task_name) OR
                                                 (inf.task_name IS NULL
                                                  AND inf.task_number IS NOT NULL
                                                  AND inf.task_number = pt.task_number) OR
                                                 (inf.task_name IS NOT NULL
                                                  AND inf.task_number IS NOT NULL
                                                  AND inf.task_name = pt.task_name
                                                  AND inf.task_number = pt.task_number)),

                          inf.change_reason_code           = DECODE(inf.delete_flag,'Y',NULL,inf.change_reason_code),
                          inf.quantity                     = DECODE(inf.delete_flag,'Y',NULL,inf.quantity),
                          inf.raw_cost                     = DECODE(inf.delete_flag,'Y',NULL,inf.raw_cost),
                          inf.raw_cost_over_rate           = DECODE(inf.delete_flag,'Y',NULL,inf.raw_cost_over_rate),
                          inf.burdened_cost                = DECODE(inf.delete_flag,'Y',NULL,inf.burdened_cost),
                          inf.burdened_cost_over_rate      = DECODE(inf.delete_flag,'Y',NULL,inf.burdened_cost_over_rate),
                          inf.revenue                      = DECODE(inf.delete_flag,'Y',NULL,inf.revenue),
                          inf.bill_over_rate               = DECODE(inf.delete_flag,'Y',NULL,inf.bill_over_rate ),
                          inf.projfunc_cost_rate_type      = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_rate_type),
                          inf.projfunc_cost_rate_date_type = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_rate_date_type),
                          inf.projfunc_cost_exchange_rate  = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_cost_exchange_rate ),
                          inf.projfunc_cost_rate_date      = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.projfunc_cost_rate_date),
                          inf.project_cost_rate_type       = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_rate_type),
                          inf.project_cost_rate_date_type  = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_rate_date_type),
                          inf.project_cost_exchange_rate   = DECODE(inf.delete_flag,'Y',NULL,inf.project_cost_exchange_rate),
                          inf.project_cost_rate_date       = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.project_cost_rate_date),
                          inf.projfunc_rev_rate_type       = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_rate_type      ),
                          inf.projfunc_rev_rate_date_type  = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_rate_date_type ),
                          inf.projfunc_rev_exchange_rate   = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rev_exchange_rate  ),
                          inf.projfunc_rev_rate_date       = DECODE(inf.delete_flag,'Y',TO_DATE(NULL),inf.projfunc_rev_rate_date),
                          inf.project_rev_rate_type        = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_rate_type       ),
                          inf.project_rev_rate_date_type   = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_rate_date_type  ),
                          inf.project_rev_exchange_rate    = DECODE(inf.delete_flag,'Y',NULL,inf.project_rev_exchange_rate   ),
                          inf.project_rev_rate_date        = DECODE(inf.delete_flag,'Y',TO_DATE(NULL), inf.project_rev_rate_date),
                          inf.projfunc_rate_type           = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rate_type          ),
                          inf.projfunc_rate_date_type      = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_rate_date_type     ),
                          inf.projfunc_exchange_rate       = DECODE(inf.delete_flag,'Y',NULL,inf.projfunc_exchange_rate      ),
                          inf.projfunc_rate_date           = DECODE(inf.delete_flag,'Y',TO_DATE(NULL), inf.projfunc_rate_date),
                          inf.project_rate_type            = DECODE(inf.delete_flag,'Y',NULL,inf.project_rate_type           ),
                          inf.project_rate_date_type       = DECODE(inf.delete_flag,'Y',NULL,inf.project_rate_date_type      ),
                          inf.project_exchange_rate        = DECODE(inf.delete_flag,'Y',NULL,inf.project_exchange_rate       ),
                          inf.project_rate_date            = DECODE(inf.delete_flag,'Y',TO_DATE(NULL), inf.project_rate_date),
                          inf.pd_prd                       = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.pd_prd),
                          inf.prd1                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd1  ),
                          inf.prd2                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd2  ),
                          inf.prd3                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd3  ),
                          inf.prd4                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd4  ),
                          inf.prd5                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd5  ),
                          inf.prd6                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd6  ),
                          inf.prd7                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd7  ),
                          inf.prd8                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd8  ),
                          inf.prd9                         = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd9  ),
                          inf.prd10                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd10 ),
                          inf.prd11                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd11 ),
                          inf.prd12                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd12 ),
                          inf.prd13                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd13 ),
                          inf.prd14                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd14 ),
                          inf.prd15                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd15 ),
                          inf.prd16                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd16 ),
                          inf.prd17                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd17 ),
                          inf.prd18                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd18 ),
                          inf.prd19                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd19 ),
                          inf.prd20                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd20 ),
                          inf.prd21                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd21 ),
                          inf.prd22                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd22 ),
                          inf.prd23                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd23 ),
                          inf.prd24                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd24 ),
                          inf.prd25                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd25 ),
                          inf.prd26                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd26 ),
                          inf.prd27                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd27 ),
                          inf.prd28                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd28 ),
                          inf.prd29                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd29 ),
                          inf.prd30                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd30 ),
                          inf.prd31                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd31 ),
                          inf.prd32                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd32 ),
                          inf.prd33                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd33 ),
                          inf.prd34                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd34 ),
                          inf.prd35                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd35 ),
                          inf.prd36                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd36 ),
                          inf.prd37                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd37 ),
                          inf.prd38                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd38 ),
                          inf.prd39                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd39 ),
                          inf.prd40                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd40 ),
                          inf.prd41                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd41 ),
                          inf.prd42                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd42 ),
                          inf.prd43                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd43 ),
                          inf.prd44                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd44 ),
                          inf.prd45                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd45 ),
                          inf.prd46                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd46 ),
                          inf.prd47                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd47 ),
                          inf.prd48                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd48 ),
                          inf.prd49                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd49 ),
                          inf.prd50                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd50 ),
                          inf.prd51                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd51 ),
                          inf.prd52                        = DECODE(inf.delete_flag,'Y',l_fnd_miss_num,inf.prd52 ),
                          inf.sd_prd                       = DECODE(inf.delete_flag,'Y',l_fnd_miss_num , inf.sd_prd),
                          inf.resource_list_member_id      = l_unct_rlm_id
                 WHERE    inf.run_id= p_run_id
                 AND      Nvl(p_request_id, -99) = Nvl(inf.request_id, -99);
            END IF; -- uncategorized flag
      EXCEPTION
           WHEN OTHERS THEN
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Unexpected Error - ' || SQLERRM;
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                 END IF;

                 RAISE;
      END;
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Task ids updated';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      --log1('----- STAGE 2-------');
      -- checking, if the layout is periodic one
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Checking for periodic setup';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      BEGIN
            SELECT  'Y'
            INTO    is_periodic_setup
            FROM    DUAL
            WHERE EXISTS(SELECT  'X'
                         FROM    pa_fp_webadi_upload_inf
                         WHERE   amount_type_name IS NOT NULL
                         AND     run_id = p_run_id
                         AND    Nvl(p_request_id, -99) = Nvl(request_id, -99));
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 is_periodic_setup := 'N';
      END;

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'is_periodic_setup: =' || is_periodic_setup;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage := 'Getting the fixed date spread curve id/name';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
      --The following update  on the interface will be used for
      ----Updating the error codes where task/resource info is missing
      ----Updating the amount type codes for the corresponding amount type names in case of periodic layout
      IF is_periodic_setup='Y' THEN

          IF p_version_info_rec.x_plan_class_code='BUDGET' THEN

              l_lookup_type := 'PA_FP_XL_ALL_BDGT_AMT_TYPES';

          ELSE

              l_lookup_type := 'PA_FP_XL_ALL_FCST_AMT_TYPES';

          END IF;


          UPDATE pa_fp_webadi_upload_inf inf
          SET    amount_type_code     = (SELECT pl.lookup_code
                                         FROM   pa_lookups pl,pa_fp_proj_xl_amt_types xlt
                                         WHERE  lookup_type=l_lookup_type
                                         AND    meaning=inf.amount_type_name
                                         AND    xlt.project_id=p_version_info_rec.x_project_id
                                         AND    xlt.fin_plan_type_id=p_version_info_rec.x_fin_plan_type_id
                                         AND    xlt.option_type=p_version_info_rec.x_version_type
                                         AND    xlt.amount_type_code=pl.lookup_code),
                 val_error_flag       = NVL(val_error_flag,
                                            DECODE(task_id,
                                                   NULL,'Y',
                                                   DECODE(resource_list_member_id,
                                                          NULL,'Y',
                                                          NULL))),
                 val_error_code       = NVL(val_error_code,
                                            DECODE(task_id,
                                                   NULL,'INVALID_TASK_INFO',
                                                   DECODE(resource_list_member_id,
                                                          NULL,'INVALID_RESOURCE_INFO',
                                                          NULL))),
                 err_task_name        = nvl(task_name,'-98'),
                 err_task_number      = nvl(task_number,'-98'),
                 err_alias            = nvl(resource_alias,'-98'),
                 err_amount_type_code = nvl(amount_type_code,'-98')
          WHERE  run_id=p_run_id
          AND    Nvl(p_request_id, -99) = Nvl(request_id, -99);

      ELSE --Non Periodic layout

          UPDATE pa_fp_webadi_upload_inf inf
          SET    val_error_flag       = NVL(val_error_flag,
                                            DECODE(task_id,
                                                   NULL,'Y',
                                                   DECODE(resource_list_member_id,
                                                          NULL,'Y',
                                                          NULL))),
                val_error_code       = NVL(val_error_code,
                                            DECODE(task_id,
                                                   NULL,'INVALID_TASK_INFO',
                                                   DECODE(resource_list_member_id,
                                                          NULL,'INVALID_RESOURCE_INFO',
                                                          NULL))),
                 err_task_name        = nvl(task_name,'-98'),
                 err_task_number      = nvl(task_number,'-98'),
                 err_alias            = nvl(resource_alias,'-98'),
                 err_amount_type_code = nvl(amount_type_code,'-98')
          WHERE  run_id=p_run_id
          AND    Nvl(p_request_id, -99) = Nvl(request_id, -99);

      END IF;

      --log1('----- STAGE 5-------');
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'plan class code of the version: ' || p_version_info_rec.x_plan_class_code;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;


      IF p_version_info_rec.x_plan_class_code = PA_FP_CONSTANTS_PKG.G_PLAN_CLASS_FORECAST THEN
           is_forecast_version := 'Y';

           -- calling an api to derive the etc_start_date
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Calling pa_fp_gen_amount_utils.get_etc_start_date';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;

           l_etc_start_date := pa_fp_gen_amount_utils.get_etc_start_date(p_version_info_rec.x_budget_version_id);
      END IF;

      --log1('----- STAGE 6-------');
      BEGIN
            SELECT t.name,
                   a.spread_curve_id
            INTO   l_fixed_spread_curve_name,
                   l_fixed_spread_curve_id
            FROM   pa_spread_curves_b a,
                   pa_spread_curves_tl t
            WHERE  a.spread_curve_id = t.spread_curve_id
            AND    a.spread_curve_code = 'FIXED_DATE'
            AND    t.language = userenv('LANG');
      EXCEPTION
            WHEN OTHERS THEN
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Unexpected Error - ' || SQLERRM;
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                 END IF;

                 RAISE;
      END;
      --log1('----- STAGE 7-------');
      IF is_periodic_setup = 'Y' THEN
            /* The structure of the both tables for start date and end date table would be as follows:
             * - If the number of flexible periods shown on the layout is n, then the first n elements
             *   in each of the tables would contain corresponding start date/end date of a period whose
             *   number would be specified by the index.
             */

             l_prd_start_date_tbl := p_prd_start_date_tbl;
             l_prd_end_date_tbl   := p_prd_end_date_tbl;

             --log1('--p_prd_start_date_tbl.COUNT-- ' || p_prd_start_date_tbl.COUNT);
             l_original_prd_count := p_prd_start_date_tbl.COUNT;
             l_int_new_prd_count  := 52 - (l_original_prd_count);
             IF l_int_new_prd_count > 0 THEN
                   -- extending the period start/end date tables to have total 52 periods
                   l_prd_start_date_tbl.EXTEND(l_int_new_prd_count);
                   l_prd_end_date_tbl.EXTEND(l_int_new_prd_count);
             END IF;
       END IF;

      -- initializing the conversion attributes for ALL version
      -- and for periodic layouts

      IF is_periodic_setup = 'Y' THEN
          IF p_version_info_rec.x_version_type = 'ALL' AND
             p_version_info_rec.x_plan_in_multi_curr_flag = 'Y' THEN

                l_conv_attrb_displayed := conv_attributes_displayed(p_run_id => p_run_id);

                BEGIN
                    SELECT project_cost_rate_type,
                           project_cost_rate_date_type,
                           project_cost_rate_date,
                           projfunc_cost_rate_type,
                           projfunc_cost_rate_date_type,
                           projfunc_cost_rate_date,
                           project_rev_rate_type,
                           project_rev_rate_date_type,
                           project_rev_rate_date,
                           projfunc_rev_rate_type,
                           projfunc_rev_rate_date_type,
                           projfunc_rev_rate_date
                    INTO   d_project_cost_rate_type,
                           d_project_cost_rate_date_type,
                           d_project_cost_rate_date,
                           d_projfunc_cost_rate_type,
                           d_projfunc_cost_rate_date_type,
                           d_projfunc_cost_rate_date,
                           d_project_rev_rate_type,
                           d_project_rev_rate_date_type,
                           d_project_rev_rate_date,
                           d_projfunc_rev_rate_type,
                           d_projfunc_rev_rate_date_type,
                           d_projfunc_rev_rate_date
                    FROM   pa_proj_fp_options
                    WHERE  fin_plan_version_id = p_version_info_rec.x_budget_version_id
                    AND    fin_plan_preference_code = 'COST_AND_REV_SAME';
                EXCEPTION
                    WHEN OTHERS THEN
                         IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Unexpected Error - ' || SQLERRM;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                         END IF;

                         RAISE;
                END;

                -- selecting the exchange rates for all the transaction currencies available
                -- for the version
                BEGIN
                    SELECT txn_currency_code,
                           project_cost_exchange_rate,
                           project_rev_exchange_rate,
                           projfunc_cost_exchange_rate,
                           projfunc_rev_exchange_rate
                    BULK COLLECT INTO
                           d_txn_curr_tab,
                           d_project_cost_exc_rate_tab,
                           d_project_rev_exc_rate_tab,
                           d_projfunc_cost_exc_rate_tab,
                           d_projfunc_rev_exc_rate_tab
                    FROM   pa_fp_txn_currencies
                    WHERE  proj_fp_options_id = p_version_info_rec.x_proj_fp_options_id;
                EXCEPTION
                    WHEN OTHERS THEN
                         IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Unexpected Error - ' || SQLERRM;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                         END IF;

                         RAISE;
                END;
          END IF;
      END IF;
      -- initializing l_plan_trans_attr_copied_flag to N
      l_plan_trans_attr_copied_flag := 'N';
      l_cost_conv_attr_copied_flag := 'N';
      l_rev_conv_attr_copied_flag := 'N';
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'l_plan_trans_attr_copied_flag initialized to N';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage := 'Opening cursor inf_tbl_data_csr';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      --Initialize the OUT variables
      x_etc_quantity_tbl := SYSTEM.pa_num_tbl_type();
      x_etc_raw_cost_tbl := SYSTEM.pa_num_tbl_type();
      x_etc_burdened_cost_tbl := SYSTEM.pa_num_tbl_type();
      x_etc_revenue_tbl := SYSTEM.pa_num_tbl_type();

      --log1('----- STAGE 8-------');
      IF p_version_info_rec.x_version_type = 'COST' THEN
          l_allow_qty_flag := p_version_info_rec.x_cost_quantity_flag;
      ELSIF p_version_info_rec.x_version_type = 'REVENUE' THEN
          l_allow_qty_flag := p_version_info_rec.x_rev_quantity_flag;
      ELSIF p_version_info_rec.x_version_type = 'ALL' THEN
          l_allow_qty_flag := p_version_info_rec.x_all_quantity_flag;
      END IF;

      IF is_periodic_setup = 'Y' THEN

          -- deriving the start/end date of the first period that falls before the first period
          -- displayed in the period mask
          --log1('----- STAGE 8.0.1------- '||1);
          --log1('----- STAGE 8.0.2------- '||p_prd_start_date_tbl(1));
          OPEN l_first_pd_st_en_dt_csr(p_org_id,
                                       p_prd_start_date_tbl(1),
                                       p_version_info_rec.x_time_phased_code);
                FETCH l_first_pd_st_en_dt_csr
                INTO  l_first_pd_st_en_dt_rec;
                l_first_pd_bf_pm_st_dt := l_first_pd_st_en_dt_rec.start_date;
                l_first_pd_bf_pm_en_dt := l_first_pd_st_en_dt_rec.end_date;
          CLOSE l_first_pd_st_en_dt_csr;

          -- deriving the start/end date of the last period that falls after the last period
          -- displayed in the period mask
          --log1('----- STAGE 8.1.1------- '||l_original_prd_count);
          --log1('----- STAGE 8.1.2------- '||p_prd_end_date_tbl(l_original_prd_count));
          OPEN l_last_pd_st_en_dt_csr(p_org_id,
                                      p_prd_end_date_tbl(l_original_prd_count),
                                      p_version_info_rec.x_time_phased_code);
                FETCH l_last_pd_st_en_dt_csr
                INTO l_last_pd_st_en_dt_rec;
                l_last_pd_af_pm_st_dt := l_last_pd_st_en_dt_rec.start_date;
                l_last_pd_af_pm_en_dt := l_last_pd_st_en_dt_rec.end_date;
          CLOSE l_last_pd_st_en_dt_csr;

          x_first_pd_bf_pm_en_dt := l_first_pd_bf_pm_en_dt;
          x_last_pd_af_pm_st_dt := l_last_pd_af_pm_st_dt;

      END IF;

      -- initializing the conversion attributes for the firsr record for a periodic layout
      -- for a ALL version, these values would be overwritten
      IF is_periodic_setup = 'Y' THEN
          IF p_version_info_rec.x_version_type = 'ALL' AND
             p_version_info_rec.x_plan_in_multi_curr_flag = 'Y' THEN

                  -- bug 4479036: need to assign these default values only if the
                  -- conversion attribute columns are selected in the layout.
                  -- otherwise keep them as null.
                  IF l_conv_attrb_displayed = 'Y' THEN
                      l_project_cost_rate_type      := d_project_cost_rate_type      ;
                      l_project_cost_rate_date_type := d_project_cost_rate_date_type ;
                      l_project_cost_rate_date      := d_project_cost_rate_date      ;
                      l_projfunc_cost_rate_type     := d_projfunc_cost_rate_type     ;
                      l_projfunc_cost_rate_date_type:= d_projfunc_cost_rate_date_type;
                      l_projfunc_cost_rate_date     := d_projfunc_cost_rate_date     ;

                      l_project_rev_rate_type       := d_project_rev_rate_type       ;
                      l_project_rev_rate_date_type  := d_project_rev_rate_date_type  ;
                      l_project_rev_rate_date       := d_project_rev_rate_date       ;
                      l_projfunc_rev_rate_type      := d_projfunc_rev_rate_type      ;
                      l_projfunc_rev_rate_date_type := d_projfunc_rev_rate_date_type ;
                      l_projfunc_rev_rate_date      := d_projfunc_rev_rate_date      ;

                      IF l_inf_tbl_data_curr_rec.txn_currency_code IS NOT NULL THEN
                          IF d_txn_curr_tab.COUNT > 0 THEN
                              FOR i IN d_txn_curr_tab.FIRST .. d_txn_curr_tab.LAST LOOP
                                  IF d_txn_curr_tab(i) = l_inf_tbl_data_curr_rec.txn_currency_code THEN
                                      l_project_cost_exchange_rate  := d_project_cost_exc_rate_tab(i);
                                      l_projfunc_cost_exchange_rate := d_projfunc_cost_exc_rate_tab(i);
                                      l_project_rev_exchange_rate   := d_project_rev_exc_rate_tab(i);
                                      l_projfunc_rev_exchange_rate  := d_projfunc_rev_exc_rate_tab(i);

                                      EXIT;
                                  END IF;
                              END LOOP;
                          END IF;
                      END IF;
                  END IF;
          END IF;
      END IF;
      --log1('----- STAGE 8.2.0------- ');

      l_inf_tbl_data_prev_rec := NULL;
      IF inf_tbl_data_csr%ISOPEN THEN

          CLOSE inf_tbl_data_csr;

      END IF;

      OPEN inf_tbl_data_csr
      (c_run_id                    => p_run_id,
       c_allow_qty_flag            => l_allow_qty_flag,
       c_allow_raw_cost_flag       => p_version_info_rec.x_raw_cost_flag,
       c_allow_burd_cost_flag      => p_version_info_rec.x_burdened_flag,
       c_allow_revenue_flag        => p_version_info_rec.x_revenue_flag,
       c_allow_raw_cost_rate_flag  => p_version_info_rec.x_cost_rate_flag,
       c_allow_burd_cost_rate_flag => p_version_info_rec.x_burden_rate_flag,
       c_allow_bill_rate_flag      => p_version_info_rec.x_bill_rate_flag,
       c_project_id                => p_version_info_rec.x_project_id,
       c_fin_plan_type_id          => p_version_info_rec.x_fin_plan_type_id,
       c_version_type              => p_version_info_rec.x_version_type,
       c_request_id                => p_request_id);
      --log1('----- STAGE 8.2.1------- ');

      --Added for bug#4488926
      IF(p_version_info_rec.x_time_phased_code is null)
      THEN
          l_period_time_phased_code := PA_FIN_PLAN_UTILS.Get_Time_Phased_code(p_version_info_rec.x_budget_version_id);
      ELSE
         l_period_time_phased_code := p_version_info_rec.x_time_phased_code;
      END IF;

      FETCH inf_tbl_data_csr INTO l_inf_tbl_data_curr_rec;
      --log1('----- STAGE 8.2.2------- ');
      LOOP
            --log1('----- STAGE 8.2.3------- l_inf_tbl_data_curr_rec.task_id '||l_inf_tbl_data_curr_rec.task_id);
            --log1('----- STAGE 8.2.4-------');
            -- resetting budget line start date/ end date varibales
            l_bdgt_line_start_date := null;
            l_bdgt_line_end_date := null;

            --log1('----- STAGE 8.2.4.0.1-------');
            --Initialize the variables used for processing
            IF l_inf_tbl_data_curr_rec.task_id IS NULL OR
               (l_inf_tbl_data_prev_rec.task_id IS NOT NULL AND
                (l_inf_tbl_data_prev_rec.task_id <>  l_inf_tbl_data_curr_rec.task_id OR
                 l_inf_tbl_data_prev_rec.resource_list_member_id <>  l_inf_tbl_data_curr_rec.resource_list_member_id OR
                 Nvl(l_inf_tbl_data_prev_rec.txn_currency_code, '-99') <>  Nvl(l_inf_tbl_data_curr_rec.txn_currency_code, '-99') OR
                 NVL(l_inf_tbl_data_prev_rec.amount_type_code,'-99') <>  NVL(l_inf_tbl_data_curr_rec.amount_type_code,'-99'))) THEN

                --log1('----- STAGE 8.2.4.0.2-------');
                --Reset Planning Transaction Level Variables
                IF l_inf_tbl_data_curr_rec.task_id IS NULL OR
                   l_inf_tbl_data_prev_rec.task_id <>  l_inf_tbl_data_curr_rec.task_id OR
                   l_inf_tbl_data_prev_rec.resource_list_member_id <>  l_inf_tbl_data_curr_rec.resource_list_member_id OR
                   Nvl(l_inf_tbl_data_prev_rec.txn_currency_code, '-99') <>  Nvl(l_inf_tbl_data_curr_rec.txn_currency_code, '-99') THEN

                    l_plan_trans_attr_copied_flag := 'N';
                    l_min_bdgt_line_start_date := NULL;
                    l_max_bdgt_line_end_date   := NULL;

                    l_project_cost_rate_type      := NULL;
                    l_project_cost_rate_date_type := NULL;
                    l_project_cost_rate_date      := NULL;
                    l_project_cost_exchange_rate  := NULL;
                    l_projfunc_cost_rate_type     := NULL;
                    l_projfunc_cost_rate_date_type:= NULL;
                    l_projfunc_cost_rate_date     := NULL;
                    l_projfunc_cost_exchange_rate := NULL;

                    l_project_rev_rate_type      := NULL;
                    l_project_rev_rate_date_type := NULL;
                    l_project_rev_rate_date      := NULL;
                    l_project_rev_exchange_rate  := NULL;
                    l_projfunc_rev_rate_type     := NULL;
                    l_projfunc_rev_rate_date_type:= NULL;
                    l_projfunc_rev_rate_date     := NULL;
                    l_projfunc_rev_exchange_rate := NULL;

                    l_cost_conv_attr_copied_flag := 'N';
                    l_rev_conv_attr_copied_flag  := 'N';
                    --log1('----- STAGE 8.2.4.0.3-------');

                    -- initializing the conversion attributes for subsequent reords for periodic layout
                    -- for a ALL version, these values would be overwritten
                    IF is_periodic_setup = 'Y' THEN
                        IF p_version_info_rec.x_version_type = 'ALL' AND
                           p_version_info_rec.x_plan_in_multi_curr_flag = 'Y' THEN
                               -- bug 4479036: need to assign these default values only if the
                               -- conversion attribute columns are selected in the layout.
                               -- otherwise keep them as null.
                               IF l_conv_attrb_displayed = 'Y' THEN
                                   l_project_cost_rate_type      := d_project_cost_rate_type      ;
                                   l_project_cost_rate_date_type := d_project_cost_rate_date_type ;
                                   l_project_cost_rate_date      := d_project_cost_rate_date      ;
                                   l_projfunc_cost_rate_type     := d_projfunc_cost_rate_type     ;
                                   l_projfunc_cost_rate_date_type:= d_projfunc_cost_rate_date_type;
                                   l_projfunc_cost_rate_date     := d_projfunc_cost_rate_date     ;

                                   l_project_rev_rate_type       := d_project_rev_rate_type       ;
                                   l_project_rev_rate_date_type  := d_project_rev_rate_date_type  ;
                                   l_project_rev_rate_date       := d_project_rev_rate_date       ;
                                   l_projfunc_rev_rate_type      := d_projfunc_rev_rate_type      ;
                                   l_projfunc_rev_rate_date_type := d_projfunc_rev_rate_date_type ;
                                   l_projfunc_rev_rate_date      := d_projfunc_rev_rate_date      ;

                                   IF Nvl(l_inf_tbl_data_prev_rec.txn_currency_code, '-99') <>
                                      Nvl(l_inf_tbl_data_curr_rec.txn_currency_code, '-99') THEN
                                       IF d_txn_curr_tab.COUNT > 0 THEN
                                           FOR i IN d_txn_curr_tab.FIRST .. d_txn_curr_tab.LAST LOOP
                                               IF d_txn_curr_tab(i) = l_inf_tbl_data_curr_rec.txn_currency_code THEN
                                                  l_project_cost_exchange_rate  := d_project_cost_exc_rate_tab(i);
                                                  l_projfunc_cost_exchange_rate := d_projfunc_cost_exc_rate_tab(i);
                                                  l_project_rev_exchange_rate   := d_project_rev_exc_rate_tab(i);
                                                  l_projfunc_rev_exchange_rate  := d_projfunc_rev_exc_rate_tab(i);

                                                  EXIT;
                                               END IF;
                                           END LOOP;
                                       END IF;
                                   END IF;
                               END IF;
                        END IF;
                    END IF;
                END IF;

                --log1('----- STAGE 8.2.4.0.4-------');
                --Reset the Resource assignment level Variables
                IF l_inf_tbl_data_curr_rec.task_id IS NULL OR
                   l_inf_tbl_data_curr_rec.task_id <> l_inf_tbl_data_prev_rec.task_id OR
                   l_inf_tbl_data_curr_rec.resource_list_member_id <> l_inf_tbl_data_prev_rec.resource_list_member_id THEN
                    -- nulling out the fixed spread curve period counter
                    l_fix_sc_amt_pd_curr_index := null;

                    l_end_ra_index := bl_count -1;
                    --log1('----- STAGE 8.2.4.0.5-------'||l_start_ra_index);
                    --log1('----- STAGE 8.2.4.0.6-------'||l_end_ra_index);
                    --log1('----- STAGE 8.2.4.0.7-------'||l_min_ra_plan_start_date);
                    --log1('----- STAGE 8.2.4.0.8-------'||l_max_ra_plan_end_date);

                    IF l_cached_ra_id_tbl.EXISTS(l_cached_ra_index) AND
                       l_cached_ra_id_tbl(l_cached_ra_index) = -1 THEN
                          FOR kk IN l_start_ra_index..l_end_ra_index LOOP
                            l_plan_start_date_tbl(kk) := l_min_ra_plan_start_date;
                            l_plan_end_date_tbl(kk)   := l_max_ra_plan_end_date;
                          END LOOP;
                    END IF;
                    l_start_ra_index := bl_count;
                    l_min_ra_plan_start_date := null;
                    l_max_ra_plan_end_date   := null;
                END IF;

            END IF;--IF l_inf_tbl_data_prev_rec.task_id IS NOT NULL AND

            EXIT WHEN l_inf_tbl_data_curr_rec.task_id IS NULL;
            x_inf_tbl_rec_tbl (x_inf_tbl_rec_tbl.COUNT + 1):= l_inf_tbl_data_curr_rec;
            BEGIN
                 --log1('----- STAGE 9-------');
                 -- preparing the index to be used for cached RA id table
                 l_cached_ra_index := 'T' || l_inf_tbl_data_curr_rec.task_id || 'R' || l_inf_tbl_data_curr_rec.resource_list_member_id;

                 -- checking if the RA is an existing one or a new one
                 IF NOT l_cached_ra_id_tbl.EXISTS(l_cached_ra_index) THEN
                       -- deriving planning dates and spread curve information from pa_resource_assignments for existing RAs
                       -- or from pa_resource_list_members for new RAs.
                       BEGIN
                              SELECT resource_assignment_id,
                                     planning_start_date,
                                     planning_end_date,
                                     spread_curve_id,
                                     sp_fixed_date,
                                     rbs_element_id,
                                     resource_class_code,
                                     rate_based_flag
                              INTO   l_ra_id,
                                     l_plan_start_date,
                                     l_plan_end_date,
                                     l_spread_curve_id,
                                     l_sp_fixed_date,
                                     l_rbs_elem_id,
                                     l_res_class_code,
                                     l_rate_based_flag
                              FROM   pa_resource_assignments
                              WHERE  project_id = p_version_info_rec.x_project_id
                              AND    budget_version_id = p_version_info_rec.x_budget_version_id
                              AND    task_id = l_inf_tbl_data_curr_rec.task_id
                              AND    resource_list_member_id = l_inf_tbl_data_curr_rec.resource_list_member_id
                              AND    project_assignment_id = -1;

                              l_cached_ra_id_tbl(l_cached_ra_index) := l_ra_id;
                       EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                    --log1('----- STAGE 10-------');
                                    BEGIN
                                          SELECT spread_curve_id
                                          INTO   l_spread_curve_id
                                          FROM   pa_resource_list_members
                                          WHERE  resource_list_member_id = l_inf_tbl_data_curr_rec.resource_list_member_id;
                                    EXCEPTION
                                          WHEN OTHERS THEN
                                               IF l_debug_mode = 'Y' THEN
                                                    pa_debug.g_err_stage:= 'Unexpected Error - ' || SQLERRM;
                                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                                               END IF;

                                               RAISE;
                                    END;
                                    l_ra_id           := NULL;
                                    l_plan_start_date := NULL;
                                    l_plan_end_date   := NULL;
                                    l_sp_fixed_date   := NULL;
                                    l_rbs_elem_id     := NULL;
                                    l_res_class_code  := NULL;
                                    l_rate_based_flag := NULL;
                                    -- storing -1 for the index of corresoponding task/resource to indicate new RA
                                    l_cached_ra_id_tbl(l_cached_ra_index) := -1;
                       END;
                       --log1('----- STAGE 11-------');
                 END IF;

                 -- initializing the local temp variables
                 l_raw_cost             := NULL;
                 l_burdened_cost        := NULL;
                 l_revenue              := NULL;
                 l_quantity             := NULL;
                 l_etc_quantity         := NULL;
                 l_etc_raw_cost         := NULL;
                 l_etc_burdened_cost    := NULL;
                 l_etc_revenue          := NULL;
                 l_tmp_sum_amt          := NULL;
                 l_not_null_period_cnt  := NULL;

                 -- budget line dates processing starts
                 IF l_inf_tbl_data_curr_rec.delete_flag = 'Y' THEN
                        l_bdgt_line_start_date := l_plan_start_date;
                        l_bdgt_line_end_date := l_plan_end_date;
                 ELSE
                     IF is_periodic_setup = 'Y' THEN
                          IF is_forecast_version = 'Y' THEN
                              IF l_prd_start_date_tbl(1) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(1) - 1)) AND
                                 l_inf_tbl_data_curr_rec.prd1 IS NOT NULL AND
                                 l_inf_tbl_data_curr_rec.prd1 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(1);
                              ELSIF l_prd_start_date_tbl(2) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(2) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd2 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd2 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(2);
                              ELSIF l_prd_start_date_tbl(3) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(3) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd3 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd3 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(3);
                              ELSIF l_prd_start_date_tbl(4) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(4) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd4 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd4 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(4);
                              ELSIF l_prd_start_date_tbl(5) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(5) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd5 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd5 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(5);
                              ELSIF l_prd_start_date_tbl(6) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(6) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd6 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd6 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(6);
                              ELSIF l_prd_start_date_tbl(7) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(7) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd7 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd7 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(7);
                              ELSIF l_prd_start_date_tbl(8) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(8) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd8 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd8 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(8);
                              ELSIF l_prd_start_date_tbl(9) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(9) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd9 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd9 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(9);
                              ELSIF l_prd_start_date_tbl(10) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(10) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd10 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd10 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(10);
                              ELSIF l_prd_start_date_tbl(11) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(11) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd11 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd11 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(11);
                              ELSIF l_prd_start_date_tbl(12) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(12) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd12 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd12 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(12);
                              ELSIF l_prd_start_date_tbl(13) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(13) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd13 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd13 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(13);
                              ELSIF l_prd_start_date_tbl(14) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(14) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd14 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd14 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(14);
                              ELSIF l_prd_start_date_tbl(15) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(15) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd15 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd15 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(15);
                              ELSIF l_prd_start_date_tbl(16) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(16) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd16 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd16 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(16);
                              ELSIF l_prd_start_date_tbl(17) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(17) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd17 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd17 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(17);
                              ELSIF l_prd_start_date_tbl(18) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(18) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd18 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd18 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(18);
                              ELSIF l_prd_start_date_tbl(19) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(19) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd19 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd19 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(19);
                              ELSIF l_prd_start_date_tbl(20) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(20) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd20 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd20 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(20);
                              ELSIF l_prd_start_date_tbl(21) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(21) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd21 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd21 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(21);
                              ELSIF l_prd_start_date_tbl(22) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(22) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd22 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd22 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(22);
                              ELSIF l_prd_start_date_tbl(23) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(23) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd23 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd23 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(23);
                              ELSIF l_prd_start_date_tbl(24) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(24) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd24 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd24 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(24);
                              ELSIF l_prd_start_date_tbl(25) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(25) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd25 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd25 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(25);
                              ELSIF l_prd_start_date_tbl(26) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(26) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd26 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd26 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(26);
                              ELSIF l_prd_start_date_tbl(27) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(27) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd27 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd27 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(27);
                              ELSIF l_prd_start_date_tbl(28) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(28) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd28 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd28 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(28);
                              ELSIF l_prd_start_date_tbl(29) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(29) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd29 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd29 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(29);
                              ELSIF l_prd_start_date_tbl(30) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(30) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd30 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd30 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(30);
                              ELSIF l_prd_start_date_tbl(31) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(31) - 0)) AND
                                    l_inf_tbl_data_curr_rec.prd31 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd31 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(31);
                              ELSIF l_prd_start_date_tbl(32) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(32) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd32 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd32 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(32);
                              ELSIF l_prd_start_date_tbl(33) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(33) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd33 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd33 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(33);
                              ELSIF l_prd_start_date_tbl(34) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(34) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd34 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd34 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(34);
                              ELSIF l_prd_start_date_tbl(35) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(35) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd35 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd35 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(35);
                              ELSIF l_prd_start_date_tbl(36) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(36) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd36 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd36 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(36);
                              ELSIF l_prd_start_date_tbl(37) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(37) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd37 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd37 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(37);
                              ELSIF l_prd_start_date_tbl(38) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(38) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd38 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd38 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(38);
                              ELSIF l_prd_start_date_tbl(39) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(39) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd39 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd39 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(39);
                              ELSIF l_prd_start_date_tbl(40) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(40) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd40 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd40 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(40);
                              ELSIF l_prd_start_date_tbl(41) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(41) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd41 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd41 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(41);
                              ELSIF l_prd_start_date_tbl(42) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(42) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd42 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd42 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(42);
                              ELSIF l_prd_start_date_tbl(43) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(43) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd43 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd43 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(43);
                              ELSIF l_prd_start_date_tbl(44) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(44) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd44 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd44 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(44);
                              ELSIF l_prd_start_date_tbl(45) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(45) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd45 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd45 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(45);
                              ELSIF l_prd_start_date_tbl(46) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(46) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd46 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd46 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(46);
                              ELSIF l_prd_start_date_tbl(47) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(47) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd47 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd47 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(47);
                              ELSIF l_prd_start_date_tbl(48) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(48) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd48 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd48 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(48);
                              ELSIF l_prd_start_date_tbl(49) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(49) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd49 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd49 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(49);
                              ELSIF l_prd_start_date_tbl(50) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(50) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd50 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd50 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(50);
                              ELSIF l_prd_start_date_tbl(51) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(51) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd51 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd51 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(51);
                              ELSIF l_prd_start_date_tbl(52) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(52) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd52 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd52 <> l_fnd_miss_num THEN
                                      l_bdgt_line_start_date := l_prd_start_date_tbl(52);
                              END IF;
                          ELSE  -- budget version
                              IF l_inf_tbl_data_curr_rec.prd1 IS NOT NULL AND
                                 l_inf_tbl_data_curr_rec.prd1 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(1);
                              ELSIF l_inf_tbl_data_curr_rec.prd2 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd2 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(2);
                              ELSIF l_inf_tbl_data_curr_rec.prd3 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd3 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(3);
                              ELSIF l_inf_tbl_data_curr_rec.prd4 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd4 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(4);
                              ELSIF l_inf_tbl_data_curr_rec.prd5 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd5 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(5);
                              ELSIF l_inf_tbl_data_curr_rec.prd6 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd6 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(6);
                              ELSIF l_inf_tbl_data_curr_rec.prd7 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd7 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(7);
                              ELSIF l_inf_tbl_data_curr_rec.prd8 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd8 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(8);
                              ELSIF l_inf_tbl_data_curr_rec.prd9 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd9 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(9);
                              ELSIF l_inf_tbl_data_curr_rec.prd10 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd10 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(10);
                              ELSIF l_inf_tbl_data_curr_rec.prd11 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd11 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(11);
                              ELSIF l_inf_tbl_data_curr_rec.prd12 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd12 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(12);
                              ELSIF l_inf_tbl_data_curr_rec.prd13 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd13 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(13);
                              ELSIF l_inf_tbl_data_curr_rec.prd14 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd14 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(14);
                              ELSIF l_inf_tbl_data_curr_rec.prd15 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd15 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(15);
                              ELSIF l_inf_tbl_data_curr_rec.prd16 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd16 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(16);
                              ELSIF l_inf_tbl_data_curr_rec.prd17 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd17 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(17);
                              ELSIF l_inf_tbl_data_curr_rec.prd18 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd18 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(18);
                              ELSIF l_inf_tbl_data_curr_rec.prd19 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd19 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(19);
                              ELSIF l_inf_tbl_data_curr_rec.prd20 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd20 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(20);
                              ELSIF l_inf_tbl_data_curr_rec.prd21 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd21 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(21);
                              ELSIF l_inf_tbl_data_curr_rec.prd22 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd22 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(22);
                              ELSIF l_inf_tbl_data_curr_rec.prd23 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd23 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(23);
                              ELSIF l_inf_tbl_data_curr_rec.prd24 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd24 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(24);
                              ELSIF l_inf_tbl_data_curr_rec.prd25 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd25 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(25);
                              ELSIF l_inf_tbl_data_curr_rec.prd26 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd26 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(26);
                              ELSIF l_inf_tbl_data_curr_rec.prd27 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd27 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(27);
                              ELSIF l_inf_tbl_data_curr_rec.prd28 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd28 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(28);
                              ELSIF l_inf_tbl_data_curr_rec.prd29 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd29 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(29);
                              ELSIF l_inf_tbl_data_curr_rec.prd30 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd30 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(30);
                              ELSIF l_inf_tbl_data_curr_rec.prd31 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd31 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(31);
                              ELSIF l_inf_tbl_data_curr_rec.prd32 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd32 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(32);
                              ELSIF l_inf_tbl_data_curr_rec.prd33 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd33 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(33);
                              ELSIF l_inf_tbl_data_curr_rec.prd34 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd34 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(34);
                              ELSIF l_inf_tbl_data_curr_rec.prd35 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd35 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(35);
                              ELSIF l_inf_tbl_data_curr_rec.prd36 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd36 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(36);
                              ELSIF l_inf_tbl_data_curr_rec.prd37 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd37 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(37);
                              ELSIF l_inf_tbl_data_curr_rec.prd38 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd38 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(38);
                              ELSIF l_inf_tbl_data_curr_rec.prd39 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd39 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(39);
                              ELSIF l_inf_tbl_data_curr_rec.prd40 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd40 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(40);
                              ELSIF l_inf_tbl_data_curr_rec.prd41 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd41 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(41);
                              ELSIF l_inf_tbl_data_curr_rec.prd42 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd42 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(42);
                              ELSIF l_inf_tbl_data_curr_rec.prd43 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd43 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(43);
                              ELSIF l_inf_tbl_data_curr_rec.prd44 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd44 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(44);
                              ELSIF l_inf_tbl_data_curr_rec.prd45 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd45 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(45);
                              ELSIF l_inf_tbl_data_curr_rec.prd46 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd46 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(46);
                              ELSIF l_inf_tbl_data_curr_rec.prd47 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd47 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(47);
                              ELSIF l_inf_tbl_data_curr_rec.prd48 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd48 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(48);
                              ELSIF l_inf_tbl_data_curr_rec.prd49 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd49 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(49);
                              ELSIF l_inf_tbl_data_curr_rec.prd50 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd50 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(50);
                              ELSIF l_inf_tbl_data_curr_rec.prd51 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd51 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(51);
                              ELSIF l_inf_tbl_data_curr_rec.prd52 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd52 <> l_fnd_miss_num THEN
                                     l_bdgt_line_start_date := l_prd_start_date_tbl(52);
                              END IF;
                          END IF;

                          -- for budget line end dates
                          IF is_forecast_version = 'Y' THEN
                              IF l_prd_start_date_tbl(52) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(52) - 1)) AND
                                 l_inf_tbl_data_curr_rec.prd52 IS NOT NULL AND
                                 l_inf_tbl_data_curr_rec.prd52 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(52);
                              ELSIF l_prd_start_date_tbl(51) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(51) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd51 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd51 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(51);
                              ELSIF l_prd_start_date_tbl(50) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(50) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd50 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd50 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(50);
                              ELSIF l_prd_start_date_tbl(49) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(49) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd49 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd49 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(49);
                              ELSIF l_prd_start_date_tbl(48) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(48) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd48 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd48 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(48);
                              ELSIF l_prd_start_date_tbl(47) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(47) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd47 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd47 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(47);
                              ELSIF l_prd_start_date_tbl(46) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(46) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd46 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd46 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(46);
                              ELSIF l_prd_start_date_tbl(45) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(45) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd45 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd45 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(45);
                              ELSIF l_prd_start_date_tbl(44) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(44) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd44 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd44 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(44);
                              ELSIF l_prd_start_date_tbl(43) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(43) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd43 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd43 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(43);
                              ELSIF l_prd_start_date_tbl(42) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(42) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd42 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd42 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(42);
                              ELSIF l_prd_start_date_tbl(41) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(41) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd41 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd41 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(41);
                              ELSIF l_prd_start_date_tbl(40) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(40) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd40 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd40 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(40);
                              ELSIF l_prd_start_date_tbl(39) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(39) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd39 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd39 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(39);
                              ELSIF l_prd_start_date_tbl(38) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(38) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd38 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd38 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(38);
                              ELSIF l_prd_start_date_tbl(37) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(37) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd37 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd37 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(37);
                              ELSIF l_prd_start_date_tbl(36) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(36) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd36 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd36 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(36);
                              ELSIF l_prd_start_date_tbl(35) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(35) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd35 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd35 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(35);
                              ELSIF l_prd_start_date_tbl(34) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(34) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd34 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd34 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(34);
                              ELSIF l_prd_start_date_tbl(33) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(33) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd33 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd33 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(33);
                              ELSIF l_prd_start_date_tbl(32) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(32) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd32 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd32 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(32);
                              ELSIF l_prd_start_date_tbl(31) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(31) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd31 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd31 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(31);
                              ELSIF l_prd_start_date_tbl(30) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(30) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd30 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd30 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(30);
                              ELSIF l_prd_start_date_tbl(29) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(29) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd29 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd29 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(29);
                              ELSIF l_prd_start_date_tbl(28) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(28) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd28 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd28 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(28);
                              ELSIF l_prd_start_date_tbl(27) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(27) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd27 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd27 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(27);
                              ELSIF l_prd_start_date_tbl(26) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(26) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd26 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd26 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(26);
                              ELSIF l_prd_start_date_tbl(25) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(25) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd25 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd25 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(25);
                              ELSIF l_prd_start_date_tbl(24) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(24) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd24 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd24 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(24);
                              ELSIF l_prd_start_date_tbl(23) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(23) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd23 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd23 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(23);
                              ELSIF l_prd_start_date_tbl(22) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(22) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd22 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd22 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(22);
                              ELSIF l_prd_start_date_tbl(21) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(21) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd21 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd21 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(21);
                              ELSIF l_prd_start_date_tbl(20) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(20) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd20 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd20 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(20);
                              ELSIF l_prd_start_date_tbl(19) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(19) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd19 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd19 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(19);
                              ELSIF l_prd_start_date_tbl(18) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(18) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd18 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd18 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(18);
                              ELSIF l_prd_start_date_tbl(17) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(17) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd17 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd17 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(17);
                              ELSIF l_prd_start_date_tbl(16) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(16) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd16 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd16 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(16);
                              ELSIF l_prd_start_date_tbl(15) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(15) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd15 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd15 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(15);
                              ELSIF l_prd_start_date_tbl(14) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(14) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd14 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd14 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(14);
                              ELSIF l_prd_start_date_tbl(13) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(13) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd13 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd13 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(13);
                              ELSIF l_prd_start_date_tbl(12) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(12) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd12 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd12 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(12);
                              ELSIF l_prd_start_date_tbl(11) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(11) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd11 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd11 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(11);
                              ELSIF l_prd_start_date_tbl(10) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(10) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd10 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd10 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(10);
                              ELSIF l_prd_start_date_tbl(9) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(9) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd9 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd9 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(9);
                              ELSIF l_prd_start_date_tbl(8) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(8) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd8 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd8 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(8);
                              ELSIF l_prd_start_date_tbl(7) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(7) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd7 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd7 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(7);
                              ELSIF l_prd_start_date_tbl(6) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(6) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd6 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd6 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(6);
                              ELSIF l_prd_start_date_tbl(5) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(5) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd5 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd5 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(5);
                              ELSIF l_prd_start_date_tbl(4) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(4) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd4 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd4 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(4);
                              ELSIF l_prd_start_date_tbl(3) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(3) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd3 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd3 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(3);
                              ELSIF l_prd_start_date_tbl(2) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(2) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd2 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd2 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(2);
                              ELSIF l_prd_start_date_tbl(1) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(1) - 1)) AND
                                    l_inf_tbl_data_curr_rec.prd1 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd1 <> l_fnd_miss_num THEN
                                      l_bdgt_line_end_date := l_prd_end_date_tbl(1);
                              END IF;
                          ELSE  -- budget version
                              IF l_inf_tbl_data_curr_rec.prd52 IS NOT NULL AND
                                 l_inf_tbl_data_curr_rec.prd52 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(52);
                              ELSIF l_inf_tbl_data_curr_rec.prd51 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd51 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(51);
                              ELSIF l_inf_tbl_data_curr_rec.prd50 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd50 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(50);
                              ELSIF l_inf_tbl_data_curr_rec.prd49 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd49 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(49);
                              ELSIF l_inf_tbl_data_curr_rec.prd48 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd48 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(48);
                              ELSIF l_inf_tbl_data_curr_rec.prd47 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd47 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(47);
                              ELSIF l_inf_tbl_data_curr_rec.prd46 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd46 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(46);
                              ELSIF l_inf_tbl_data_curr_rec.prd45 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd45 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(45);
                              ELSIF l_inf_tbl_data_curr_rec.prd44 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd44 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(44);
                              ELSIF l_inf_tbl_data_curr_rec.prd43 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd43 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(43);
                              ELSIF l_inf_tbl_data_curr_rec.prd42 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd42 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(42);
                              ELSIF l_inf_tbl_data_curr_rec.prd41 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd41 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(41);
                              ELSIF l_inf_tbl_data_curr_rec.prd40 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd40 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(40);
                              ELSIF l_inf_tbl_data_curr_rec.prd39 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd39 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(39);
                              ELSIF l_inf_tbl_data_curr_rec.prd38 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd38 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(38);
                              ELSIF l_inf_tbl_data_curr_rec.prd37 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd37 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(37);
                              ELSIF l_inf_tbl_data_curr_rec.prd36 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd36 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(36);
                              ELSIF l_inf_tbl_data_curr_rec.prd35 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd35 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(35);
                              ELSIF l_inf_tbl_data_curr_rec.prd34 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd34 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(34);
                              ELSIF l_inf_tbl_data_curr_rec.prd33 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd33 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(33);
                              ELSIF l_inf_tbl_data_curr_rec.prd32 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd32 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(32);
                              ELSIF l_inf_tbl_data_curr_rec.prd31 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd31 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(31);
                              ELSIF l_inf_tbl_data_curr_rec.prd30 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd30 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(30);
                              ELSIF l_inf_tbl_data_curr_rec.prd29 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd29 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(29);
                              ELSIF l_inf_tbl_data_curr_rec.prd28 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd28 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(28);
                              ELSIF l_inf_tbl_data_curr_rec.prd27 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd27 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(27);
                              ELSIF l_inf_tbl_data_curr_rec.prd26 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd26 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(26);
                              ELSIF l_inf_tbl_data_curr_rec.prd25 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd25 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(25);
                              ELSIF l_inf_tbl_data_curr_rec.prd24 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd24 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(24);
                              ELSIF l_inf_tbl_data_curr_rec.prd23 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd23 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(23);
                              ELSIF l_inf_tbl_data_curr_rec.prd22 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd22 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(22);
                              ELSIF l_inf_tbl_data_curr_rec.prd21 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd21 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(21);
                              ELSIF l_inf_tbl_data_curr_rec.prd20 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd20 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(20);
                              ELSIF l_inf_tbl_data_curr_rec.prd19 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd19 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(19);
                              ELSIF l_inf_tbl_data_curr_rec.prd18 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd18 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(18);
                              ELSIF l_inf_tbl_data_curr_rec.prd17 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd17 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(17);
                              ELSIF l_inf_tbl_data_curr_rec.prd16 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd16 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(16);
                              ELSIF l_inf_tbl_data_curr_rec.prd15 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd15 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(15);
                              ELSIF l_inf_tbl_data_curr_rec.prd14 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd14 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(14);
                              ELSIF l_inf_tbl_data_curr_rec.prd13 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd13 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(13);
                              ELSIF l_inf_tbl_data_curr_rec.prd12 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd12 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(12);
                              ELSIF l_inf_tbl_data_curr_rec.prd11 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd11 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(11);
                              ELSIF l_inf_tbl_data_curr_rec.prd10 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd10 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(10);
                              ELSIF l_inf_tbl_data_curr_rec.prd9 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd9 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(9);
                              ELSIF l_inf_tbl_data_curr_rec.prd8 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd8 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(8);
                              ELSIF l_inf_tbl_data_curr_rec.prd7 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd7 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(7);
                              ELSIF l_inf_tbl_data_curr_rec.prd6 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd6 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(6);
                              ELSIF l_inf_tbl_data_curr_rec.prd5 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd5 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(5);
                              ELSIF l_inf_tbl_data_curr_rec.prd4 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd4 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(4);
                              ELSIF l_inf_tbl_data_curr_rec.prd3 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd3 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(3);
                              ELSIF l_inf_tbl_data_curr_rec.prd2 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd2 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(2);
                              ELSIF l_inf_tbl_data_curr_rec.prd1 IS NOT NULL AND
                                    l_inf_tbl_data_curr_rec.prd1 <> l_fnd_miss_num THEN
                                     l_bdgt_line_end_date := l_prd_end_date_tbl(1);
                              END IF;
                          END IF;

                     ELSE  -- non periodic
                          IF l_cached_ra_id_tbl.EXISTS(l_cached_ra_index) AND
                             l_cached_ra_id_tbl(l_cached_ra_index) = -1 THEN
                              -- populating the planning start/end dates as the budget line start/end dates
                              l_bdgt_line_start_date := l_inf_tbl_data_curr_rec.planning_start_date;
                              l_bdgt_line_end_date := l_inf_tbl_data_curr_rec.planning_end_date;
                          ELSE
                              l_bdgt_line_start_date := l_plan_start_date;
                              l_bdgt_line_end_date := l_plan_end_date;
                          END IF;

                     END IF;
                END IF;
                -- budget line dates processing ends

                -- derivation of amounts i.e. raw cost, burdened cost, revenue,
                -- quantity, raw cost rate, burdened cost, bill rate
                IF l_inf_tbl_data_curr_rec.delete_flag = 'Y' THEN
                     IF is_periodic_setup = 'Y' THEN
                         IF l_inf_tbl_data_curr_rec.amount_type_code = 'TOTAL_RAW_COST' THEN
                             l_raw_cost := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'FCST_RAW_COST' THEN
                             l_raw_cost := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'ETC_RAW_COST' THEN
                             l_etc_raw_cost := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'TOTAL_BURDENED_COST' THEN
                             l_burdened_cost := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'FCST_BURDENED_COST' THEN
                             l_burdened_cost := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'ETC_BURDENED_COST' THEN
                             l_etc_burdened_cost := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'TOTAL_REV' THEN
                             l_revenue := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'FCST_REVENUE' THEN
                             l_revenue := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'ETC_REVENUE' THEN
                             l_etc_revenue := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'TOTAL_QTY' THEN
                             l_quantity := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'FCST_QTY' THEN
                             l_quantity := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'ETC_QTY' THEN
                             l_etc_quantity := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code IN ('RAW_COST_RATE','ETC_RAW_COST_RATE') THEN
                             l_rc_rate := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code IN ('BURDENED_COST_RATE','ETC_BURDENED_COST_RATE') THEN
                             l_bc_rate := l_fnd_miss_num;
                         ELSIF l_inf_tbl_data_curr_rec.amount_type_code IN ('BILL_RATE','ETC_BILL_RATE') THEN
                             l_bill_rate := l_fnd_miss_num;
                         END IF;

                     ELSE
                         l_raw_cost          := l_fnd_miss_num;
                         l_burdened_cost     := l_fnd_miss_num;
                         l_revenue           := l_fnd_miss_num;
                         l_quantity          := l_fnd_miss_num;
                         l_etc_quantity      := l_fnd_miss_num;
                         l_etc_raw_cost      := l_fnd_miss_num;
                         l_etc_burdened_cost := l_fnd_miss_num;
                         l_etc_revenue       := l_fnd_miss_num;

                         l_rc_rate := l_fnd_miss_num;
                         l_bc_rate := l_fnd_miss_num;
                         l_bill_rate := l_fnd_miss_num;
                     END IF;

                ELSE
                     IF is_periodic_setup = 'Y' THEN
                           -- summing up periods for for particular amount type
                           l_amount:=0;
                           l_tmp_sum_amt:=0;
                           l_not_null_period_cnt:=0;
                           FOR tt IN 1..52 LOOP

                                l_amount:=0;
                                IF tt =1 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd1;
                                ELSIF tt =2 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd2;
                                ELSIF tt =3 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd3;
                                ELSIF tt =4 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd4;
                                ELSIF tt =5 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd5;
                                ELSIF tt =6 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd6;
                                ELSIF tt =7 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd7;
                                ELSIF tt =8 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd8;
                                ELSIF tt =9 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd9;
                                ELSIF tt =10 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd10;
                                ELSIF tt =11 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd11;
                                ELSIF tt =12 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd12;
                                ELSIF tt =13 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd13;
                                ELSIF tt =14 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd14;
                                ELSIF tt =15 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd15;
                                ELSIF tt =16 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd16;
                                ELSIF tt =17 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd17;
                                ELSIF tt =18 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd18;
                                ELSIF tt =19 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd19;
                                ELSIF tt =20 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd20;
                                ELSIF tt =21 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd21;
                                ELSIF tt =22 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd22;
                                ELSIF tt =23 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd23;
                                ELSIF tt =24 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd24;
                                ELSIF tt =25 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd25;
                                ELSIF tt =26 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd26;
                                ELSIF tt =27 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd27;
                                ELSIF tt =28 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd28;
                                ELSIF tt =29 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd29;
                                ELSIF tt =30 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd30;
                                ELSIF tt =31 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd31;
                                ELSIF tt =32 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd32;
                                ELSIF tt =33 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd33;
                                ELSIF tt =34 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd34;
                                ELSIF tt =35 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd35;
                                ELSIF tt =36 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd36;
                                ELSIF tt =37 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd37;
                                ELSIF tt =38 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd38;
                                ELSIF tt =39 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd39;
                                ELSIF tt =40 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd40;
                                ELSIF tt =41 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd41;
                                ELSIF tt =42 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd42;
                                ELSIF tt =43 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd43;
                                ELSIF tt =44 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd44;
                                ELSIF tt =45 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd45;
                                ELSIF tt =46 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd46;
                                ELSIF tt =47 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd47;
                                ELSIF tt =48 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd48;
                                ELSIF tt =49 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd49;
                                ELSIF tt =50 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd50;
                                ELSIF tt =51 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd51;
                                ELSIF tt =52 THEN
                                    l_amount := l_inf_tbl_data_curr_rec.prd52;
                                END IF;

                                IF l_amount = l_fnd_miss_num THEN

                                    l_amount:= 0;

                                ELSIF l_amount IS NULL THEN

                                    l_amount := 0;

                                END IF;

                                IF l_amount <> 0 THEN

                                    l_not_null_period_cnt := l_not_null_period_cnt+1;
                                    l_tmp_sum_amt := l_tmp_sum_amt+l_amount;

                                END IF;

                           END LOOP;--FOR tt IN 1..52 LOOP
                     END IF;
                END IF;

                --log1('----- STAGE 12-------');
                --log1('----- STAGE 12.1------- '||l_cached_ra_index);
                --log1('----- STAGE 12.2------- '||l_cached_ra_id_tbl(l_cached_ra_index));
                IF l_cached_ra_id_tbl.EXISTS(l_cached_ra_index) AND
                   l_cached_ra_id_tbl(l_cached_ra_index) <> -1 THEN
                       -- for existing RAs
                      -- for periodic layouts getting the start/end date of the preceeding and succeeding periods
                      IF is_periodic_setup = 'Y' THEN
                             --log1('----- STAGE 13-------');
                             IF l_inf_tbl_data_curr_rec.pd_prd IS NOT NULL AND
                                l_inf_tbl_data_curr_rec.pd_prd <> l_fnd_miss_num THEN
                                    IF l_plan_start_date >= p_prd_start_date_tbl(1) THEN
                                          l_bdgt_line_start_date := l_first_pd_bf_pm_st_dt;
                                    ELSE
                                          l_bdgt_line_start_date := l_plan_start_date;
                                    END IF;
                             END IF;

                             IF l_inf_tbl_data_curr_rec.sd_prd IS NOT NULL AND
                                l_inf_tbl_data_curr_rec.sd_prd <> l_fnd_miss_num THEN
                                    IF l_plan_end_date <= p_prd_end_date_tbl(l_original_prd_count) THEN
                                          l_bdgt_line_end_date := l_last_pd_af_pm_en_dt;
                                    ELSE
                                          l_bdgt_line_end_date := l_plan_end_date;
                                    END IF;
                             END IF;
                             --log1('----- STAGE 13.1------- '||l_bdgt_line_start_date);
                             --log1('----- STAGE 13.2------- '||l_bdgt_line_end_date);
                             --log1('----- STAGE 13.3------- '||l_plan_start_date);
                             --log1('----- STAGE 13.4------- '||l_plan_end_date);
                             -- checking if the budget line start/end dates are outside the planning date range


                            ---Added this code for bug#4488926. Caching the values of l_period_plan_start_date and
                            --l_period_plan_end_date
                             IF ( NOT(l_period_plan_start_date_tbl.exists(to_char(l_plan_start_date))
                                  AND l_period_plan_end_date_tbl.exists(to_char(l_plan_end_date))))
                             THEN
                                --For periodic case get the start and end dates.
                                l_period_plan_start_date := PA_FIN_PLAN_UTILS.get_period_start_date(l_plan_start_date,l_period_time_phased_code);
                                l_period_plan_end_date :=  PA_FIN_PLAN_UTILS.get_period_end_date (l_plan_end_date ,  l_period_time_phased_code);
                                l_period_plan_start_date_tbl(to_char(l_plan_start_date)) := l_period_plan_start_date;
                                l_period_plan_end_date_tbl(to_char(l_plan_end_date)) := l_period_plan_end_date;
                             ELSE
                                l_period_plan_start_date := l_period_plan_start_date_tbl(to_char(l_plan_start_date));
                                l_period_plan_end_date := l_period_plan_end_date_tbl(to_char(l_plan_end_date));
                             END IF;

                             IF l_bdgt_line_start_date < l_period_plan_start_date OR
                                l_bdgt_line_end_date > l_period_plan_end_date THEN
                                    l_err_val_code_tbl.extend(1);
                                    l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_BL_OUT_OF_PLAN_RANGE';
                                    l_err_task_id_tbl.extend(1);
                                    l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                    l_err_rlm_id_tbl.extend(1);
                                    l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                    l_err_txn_curr_tbl.extend(1);
                                    l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                    l_err_amt_type_tbl.extend(1);
                                    l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                    -- raising an exception to skip processing for the dulpicate record
                                    RAISE Fp_Webadi_Skip_Rec_Proc_Exc;
                             END IF;
                      END IF; -- if periodic setup
                ELSE
                      -- for new RAs
                      --log1('----- STAGE 12.3------- '||is_periodic_setup);
                      IF is_periodic_setup = 'Y' THEN
                             -- for new RAs, amounts in preceding and succeeding periods cann't be entered
                             --log1('----- STAGE 12.4------- '|| l_inf_tbl_data_curr_rec.pd_prd);
                             IF l_inf_tbl_data_curr_rec.pd_prd IS NOT NULL AND
                                l_inf_tbl_data_curr_rec.pd_prd <> l_fnd_miss_num THEN
                                    l_err_val_code_tbl.extend(1);
                                    l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_NW_RA_PCD_PRD_AMT_ERR';
                                    l_err_task_id_tbl.extend(1);
                                    l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                    l_err_rlm_id_tbl.extend(1);
                                    l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                    l_err_txn_curr_tbl.extend(1);
                                    l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                    l_err_amt_type_tbl.extend(1);
                                    l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                    -- raising an exception to skip processing for the dulpicate record
                                    RAISE Fp_Webadi_Skip_Rec_Proc_Exc;
                             END IF;
                             --log1('----- STAGE 12.5------- '|| l_inf_tbl_data_curr_rec.sd_prd);
                             IF l_inf_tbl_data_curr_rec.sd_prd IS NOT NULL AND
                                l_inf_tbl_data_curr_rec.sd_prd <> l_fnd_miss_num THEN
                                    l_err_val_code_tbl.extend(1);
                                    l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_NW_RA_PCD_PRD_AMT_ERR';
                                    l_err_task_id_tbl.extend(1);
                                    l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                    l_err_rlm_id_tbl.extend(1);
                                    l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                    l_err_txn_curr_tbl.extend(1);
                                    l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                    l_err_amt_type_tbl.extend(1);
                                    l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                    -- raising an exception to skip processing for the dulpicate record
                                    RAISE Fp_Webadi_Skip_Rec_Proc_Exc;
                             END IF;
                      END IF;
                END IF; -- if existing RA check
                --log1('----- STAGE 15-------');

                --log1('----- STAGE 16-------');
                -- copying the following attributes from the first record
                IF l_inf_tbl_data_curr_rec.delete_flag = 'N' THEN
                    IF l_plan_trans_attr_copied_flag = 'N' THEN

                        l_bdgt_ln_tbl_description := l_inf_tbl_data_curr_rec.description;
                        l_change_reason_code := l_inf_tbl_data_curr_rec.change_reason;
                        -- flipping the value of l_plan_trans_attr_copied_flag
                        l_plan_trans_attr_copied_flag := 'Y';

                    END IF;

                    IF l_cost_conv_attr_copied_flag ='N' OR
                       l_rev_conv_attr_copied_flag ='N' THEN

                        IF p_version_info_rec.x_plan_in_multi_curr_flag = 'Y' THEN

                            IF is_periodic_setup = 'N' THEN

                                l_project_cost_rate_type      := l_inf_tbl_data_curr_rec.project_cost_rate_type;
                                l_project_cost_rate_date_type := l_inf_tbl_data_curr_rec.project_cost_rate_date_type;
                                l_project_cost_rate_date      := l_inf_tbl_data_curr_rec.project_cost_rate_date;
                                l_project_cost_exchange_rate  := l_inf_tbl_data_curr_rec.project_cost_exchange_rate;
                                l_projfunc_cost_rate_type     := l_inf_tbl_data_curr_rec.projfunc_cost_rate_type;
                                l_projfunc_cost_rate_date_type:= l_inf_tbl_data_curr_rec.projfunc_cost_rate_date_type;
                                l_projfunc_cost_rate_date     := l_inf_tbl_data_curr_rec.projfunc_cost_rate_date;
                                l_projfunc_cost_exchange_rate := l_inf_tbl_data_curr_rec.projfunc_cost_exchange_rate;

                                l_project_rev_rate_type       := l_inf_tbl_data_curr_rec.project_rev_rate_type;
                                l_project_rev_rate_date_type  := l_inf_tbl_data_curr_rec.project_rev_rate_date_type;
                                l_project_rev_rate_date       := l_inf_tbl_data_curr_rec.project_rev_rate_date;
                                l_project_rev_exchange_rate   := l_inf_tbl_data_curr_rec.project_rev_exchange_rate;
                                l_projfunc_rev_rate_type      := l_inf_tbl_data_curr_rec.projfunc_rev_rate_type;
                                l_projfunc_rev_rate_date_type := l_inf_tbl_data_curr_rec.projfunc_rev_rate_date_type;
                                l_projfunc_rev_rate_date      := l_inf_tbl_data_curr_rec.projfunc_rev_rate_date;
                                l_projfunc_rev_exchange_rate  := l_inf_tbl_data_curr_rec.projfunc_rev_exchange_rate;

                                l_cost_conv_attr_copied_flag :='Y';
                                l_rev_conv_attr_copied_flag := 'Y';

                            ELSE--Periodic Setup

                                IF l_cost_conv_attr_copied_flag ='N' AND
                                   l_inf_tbl_data_curr_rec.amount_type_code IN ('TOTAL_BURDENED_COST',
                                                                                'TOTAL_RAW_COST',
                                                                                'BURDENED_COST_RATE',
                                                                                'RAW_COST_RATE',
                                                                                'FCST_BURDENED_COST',
                                                                                'ETC_BURDENED_COST',
                                                                                'FCST_RAW_COST',
                                                                                'ETC_RAW_COST',
                                                                                'ETC_BURDENED_COST_RATE',
                                                                                'ETC_RAW_COST_RATE')  THEN

                                    l_cost_conv_attr_copied_flag  := 'Y';
                                    l_project_cost_rate_type       := l_inf_tbl_data_curr_rec.project_rate_type;
                                    l_project_cost_rate_date_type  := l_inf_tbl_data_curr_rec.project_rate_date_type;
                                    l_project_cost_rate_date       := l_inf_tbl_data_curr_rec.project_rate_date;
                                    l_project_cost_exchange_rate   := l_inf_tbl_data_curr_rec.project_exchange_rate;
                                    l_projfunc_cost_rate_type      := l_inf_tbl_data_curr_rec.projfunc_rate_type;
                                    l_projfunc_cost_rate_date_type := l_inf_tbl_data_curr_rec.projfunc_rate_date_type;
                                    l_projfunc_cost_rate_date      := l_inf_tbl_data_curr_rec.projfunc_rate_date;
                                    l_projfunc_cost_exchange_rate  := l_inf_tbl_data_curr_rec.projfunc_exchange_rate;

                                ELSIF l_rev_conv_attr_copied_flag ='N' AND
                                      l_inf_tbl_data_curr_rec.amount_type_code IN ('TOTAL_REV',
                                                                                   'BILL_RATE',
                                                                                   'FCST_REVENUE',
                                                                                   'ETC_REVENUE',
                                                                                   'ETC_BILL_RATE')  THEN

                                    l_rev_conv_attr_copied_flag  := 'Y';
                                    l_project_rev_rate_type      := l_inf_tbl_data_curr_rec.project_rate_type;
                                    l_project_rev_rate_date_type := l_inf_tbl_data_curr_rec.project_rate_date_type;
                                    l_project_rev_rate_date      := l_inf_tbl_data_curr_rec.project_rate_date;
                                    l_project_rev_exchange_rate  := l_inf_tbl_data_curr_rec.project_exchange_rate;
                                    l_projfunc_rev_rate_type     := l_inf_tbl_data_curr_rec.projfunc_rate_type;
                                    l_projfunc_rev_rate_date_type:= l_inf_tbl_data_curr_rec.projfunc_rate_date_type;
                                    l_projfunc_rev_rate_date     := l_inf_tbl_data_curr_rec.projfunc_rate_date;
                                    l_projfunc_rev_exchange_rate := l_inf_tbl_data_curr_rec.projfunc_exchange_rate;

                                END IF;

                            END IF;--IF is_periodic_setup = 'N' THEN

                            --log1('l_project_cost_rate_type = ' || l_project_cost_rate_type);
                            --log1('l_project_cost_rate_date_type = ' || l_project_cost_rate_date_type);
                            --log1('-- to_char(l_project_cost_rate_date)-1-- ' || to_char(l_project_cost_rate_date, 'dd-mm-yyyy hh24:mi:ss'));
                            --log1('-- to_char(l_project_cost_rate_date)-2-- ' || to_char(l_project_cost_rate_date, 'dd-mm-rrrr hh24:mi:ss'));
                            --log1('l_projfunc_cost_rate_type = ' || l_projfunc_cost_rate_type);
                            --log1('l_projfunc_cost_rate_date_type = ' || l_projfunc_cost_rate_date_type);
                            --log1('-- to_char(l_projfunc_cost_rate_date)--1- ' || to_char(l_projfunc_cost_rate_date, 'dd-mm-yyyy hh24:mi:ss'));
                            --log1('-- to_char(l_projfunc_cost_rate_date)--2- ' || to_char(l_projfunc_cost_rate_date, 'dd-mm-rrrr hh24:mi:ss'));
                            --log1('l_project_rev_rate_type = ' || l_project_rev_rate_type);
                            --log1('l_project_rev_rate_date_type = ' || l_project_rev_rate_date_type);
                            --log1('-- to_char(l_project_rev_rate_date)-1-- ' || to_char(l_project_rev_rate_date, 'dd-mm-yyyy hh24:mi:ss'));
                            --log1('-- to_char(l_project_rev_rate_date)-2-- ' || to_char(l_project_rev_rate_date, 'dd-mm-rrrr hh24:mi:ss'));
                            --log1('l_projfunc_rev_rate_type = ' || l_projfunc_rev_rate_type);
                            --log1('l_projfunc_rev_rate_date_type = ' || l_projfunc_rev_rate_date_type);
                            --log1('-- to_char(l_projfunc_rev_rate_date)-1-- ' || to_char(l_projfunc_rev_rate_date, 'dd-mm-yyyy hh24:mi:ss'));
                            --log1('-- to_char(l_projfunc_rev_rate_date)-2-- ' || to_char(l_projfunc_rev_rate_date, 'dd-mm-rrrr hh24:mi:ss'));

                        END IF;--IF p_version_info_rec.x_plan_in_multi_curr_flag = 'Y' THEN

                    END IF;--IF l_cost_conv_attr_copied_flag ='N' OR
                END IF;
                -- nulling out the next record
               l_inf_tbl_data_next_rec := NULL;
               -- fetching the next record
               FETCH inf_tbl_data_csr INTO l_inf_tbl_data_next_rec;
               --log1('----- STAGE 19-------');
               IF l_inf_tbl_data_next_rec.task_id IS NOT NULL AND
                  l_inf_tbl_data_curr_rec.task_id = l_inf_tbl_data_next_rec.task_id AND
                  l_inf_tbl_data_curr_rec.resource_list_member_id = l_inf_tbl_data_next_rec.resource_list_member_id AND
                  Nvl(l_inf_tbl_data_curr_rec.txn_currency_code, '-99') = Nvl(l_inf_tbl_data_next_rec.txn_currency_code, '-99') THEN

                      IF is_periodic_setup = 'Y' THEN
                           IF l_inf_tbl_data_curr_rec.amount_type_code = l_inf_tbl_data_next_rec.amount_type_code THEN
                                 -- populating the error codes to call process_errors at the end
                                 IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'Duplicate record found';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                 END IF;

                                 l_err_val_code_tbl.extend(1);
                                 l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_DUPL_REC_PASSED';
                                 l_err_task_id_tbl.extend(1);
                                 l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                 l_err_rlm_id_tbl.extend(1);
                                 l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                 l_err_txn_curr_tbl.extend(1);
                                 l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                 l_err_amt_type_tbl.extend(1);
                                 l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                 -- raising an exception to skip processing for the dulpicate record
                                 RAISE Fp_Webadi_Skip_Dup_Rec_Exc;
                           END IF;
                      ELSE
                           -- populating the error codes to call process_errors at the end
                           IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Duplicate record found';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           END IF;

                           l_err_val_code_tbl.extend(1);
                           l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_DUPL_REC_PASSED';
                           l_err_task_id_tbl.extend(1);
                           l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                           l_err_rlm_id_tbl.extend(1);
                           l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                           l_err_txn_curr_tbl.extend(1);
                           l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;

                           -- raising an exception to skip processing for the dulpicate record
                           RAISE Fp_Webadi_Skip_Dup_Rec_Exc;
                      END IF;
               END IF;

               --log1('----- STAGE 19.1-------');
               --Throw an error if planning start/end dates are not entered for a planning transaction at all.
               IF l_inf_tbl_data_next_rec.task_id IS NULL OR
                  l_inf_tbl_data_curr_rec.task_id <> l_inf_tbl_data_next_rec.task_id OR
                  l_inf_tbl_data_curr_rec.resource_list_member_id <> l_inf_tbl_data_next_rec.resource_list_member_id OR
                  Nvl(l_inf_tbl_data_curr_rec.txn_currency_code, '-99') <> Nvl(l_inf_tbl_data_next_rec.txn_currency_code, '-99') OR
                  is_periodic_setup = 'Y' THEN
                     IF is_periodic_setup = 'Y' THEN
                        -- Checking if the spread curve is of fixed date type
                        IF (l_inf_tbl_data_curr_rec.spread_curve_name IS NOT NULL AND
                            l_inf_tbl_data_curr_rec.spread_curve_name = l_fixed_spread_curve_name) OR
                            l_fixed_spread_curve_id = l_spread_curve_id THEN
                                    -- spread curve specified is of fixed date type
                                    IF l_not_null_period_cnt > 1 THEN
                                          -- there are valid amounts entered in more than 1 period
                                          l_err_val_code_tbl.extend(1);
                                          l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_FX_SC_MUL_AMT_ERR';
                                          l_err_task_id_tbl.extend(1);
                                          l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                          l_err_rlm_id_tbl.extend(1);
                                          l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                          l_err_txn_curr_tbl.extend(1);
                                          l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                          l_err_amt_type_tbl.extend(1);
                                          l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;
                                       RAISE Fp_Webadi_Skip_Rec_Proc_Exc; /* to skip processing for the current record */
                                    ELSIF l_not_null_period_cnt = 1 THEN
                                          IF l_fix_sc_amt_pd_curr_index IS NULL THEN
                                                -- finding out the period index for which amount is present

                                                IF is_forecast_version = 'Y' THEN
                                                      IF l_inf_tbl_data_curr_rec.prd1 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd1 <> l_fnd_miss_num AND
                                                         l_prd_start_date_tbl(1) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(1) - 1)) THEN
                                                            l_fix_sc_amt_pd_curr_index := 1;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd2 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd2 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(2) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(2) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 2;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd3 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd3 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(3) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(3) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 3;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd4 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd4 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(4) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(4) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 4;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd5 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd5 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(5) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(5) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 5;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd6 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd6 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(6) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(6) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 6;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd7 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd7 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(7) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(7) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 7;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd8 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd8 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(8) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(8) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 8;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd9 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd9 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(9) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(9) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 9;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd10 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd10 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(10) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(10) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 10;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd11 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd11 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(11) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(11) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 11;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd12 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd12 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(12) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(12) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 12;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd13 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd13 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(13) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(13) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 13;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd14 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd14 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(14) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(14) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 14;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd15 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd15 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(15) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(15) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 15;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd16 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd16 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(16) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(16) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 16;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd17 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd17 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(17) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(17) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 17;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd18 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd18 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(18) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(18) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 18;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd19 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd19 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(19) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(19) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 19;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd20 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd20 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(20) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(20) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 20;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd21 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd21 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(21) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(21) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 21;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd22 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd22 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(22) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(22) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 22;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd23 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd23 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(23) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(23) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 23;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd24 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd24 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(24) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(24) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 24;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd25 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd25 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(25) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(25) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 25;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd26 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd26 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(26) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(26) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 26;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd27 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd27 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(27) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(27) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 27;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd28 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd28 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(28) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(28) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 28;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd29 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd29 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(29) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(29) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 29;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd30 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd30 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(30) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(30) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 30;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd31 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd31 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(31) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(31) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 31;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd32 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd32 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(32) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(32) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 32;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd33 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd33 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(33) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(33) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 33;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd34 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd34 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(34) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(34) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 34;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd35 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd35 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(35) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(35) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 35;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd36 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd36 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(36) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(36) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 36;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd37 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd37 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(37) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(37) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 37;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd38 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd38 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(38) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(38) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 38;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd39 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd39 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(39) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(39) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 39;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd40 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd40 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(40) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(40) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 40;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd41 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd41 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(41) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(41) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 41;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd42 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd42 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(42) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(42) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 42;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd43 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd43 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(43) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(43) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 43;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd44 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd44 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(44) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(44) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 44;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd45 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd45 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(45) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(45) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 45;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd46 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd46 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(46) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(46) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 46;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd47 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd47 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(47) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(47) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 47;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd48 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd48 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(48) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(48) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 48;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd49 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd49 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(49) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(49) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 49;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd50 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd50 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(50) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(50) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 50;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd51 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd51 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(51) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(51) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 51;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd52 IS NOT NULL AND
                                                            l_inf_tbl_data_curr_rec.prd52 <> l_fnd_miss_num AND
                                                            l_prd_start_date_tbl(52) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(52) - 1)) THEN
                                                                l_fix_sc_amt_pd_curr_index := 52;
                                                      END IF;
                                                ELSE
                                                      -- budget version
                                                      IF l_inf_tbl_data_curr_rec.prd1 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd1 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 1;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd2 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd2 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 2;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd3 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd3 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 3;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd4 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd4 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 4;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd5 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd5 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 5;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd6 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd6 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 6;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd7 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd7 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 7;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd8 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd8 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 8;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd9 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd9 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 9;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd10 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd10 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 10;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd11 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd11 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 11;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd12 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd12 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 12;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd13 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd13 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 13;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd14 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd14 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 14;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd15 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd15 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 15;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd16 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd16 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 16;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd17 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd17 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 17;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd18 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd18 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 18;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd19 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd19 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 19;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd20 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd20 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 20;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd21 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd21 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 21;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd22 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd22 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 22;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd23 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd23 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 23;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd24 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd24 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 24;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd25 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd25 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 25;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd26 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd26 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 26;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd27 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd27 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 27;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd28 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd28 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 28;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd29 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd29 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 29;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd30 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd30 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 30;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd31 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd31 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 31;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd32 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd32 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 32;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd33 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd33 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 33;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd34 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd34 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 34;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd35 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd35 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 35;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd36 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd36 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 36;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd37 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd37 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 37;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd38 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd38 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 38;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd39 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd39 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 39;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd40 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd40 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 40;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd41 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd41 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 41;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd42 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd42 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 42;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd43 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd43 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 43;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd44 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd44 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 44;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd45 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd45 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 45;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd46 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd46 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 46;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd47 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd47 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 47;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd48 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd48 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 48;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd49 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd49 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 49;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd50 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd50 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 50;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd51 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd51 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 51;
                                                      ELSIF l_inf_tbl_data_curr_rec.prd52 IS NOT NULL AND
                                                         l_inf_tbl_data_curr_rec.prd52 <> l_fnd_miss_num THEN
                                                            l_fix_sc_amt_pd_curr_index := 52;
                                                      END IF;
                                                END IF;
                                          END IF; -- cur index null

                                          --log1('C l_cached_ra_index '||l_cached_ra_index);
                                          --log1('C l_fix_sc_amt_pd_curr_index '||l_fix_sc_amt_pd_curr_index);
                                          --log1('C l_sp_fix_prd_st_dt '||l_sp_fix_prd_st_dt);
                                          --log1('C l_sp_fix_prd_en_dt '||l_sp_fix_prd_en_dt);
                                          --log1('C l_sp_fixed_date '||l_sp_fixed_date);
                                          --log1('C amount type '||l_inf_tbl_data_curr_rec.amount_type_code);
                                          --log1('C txn curr '||l_inf_tbl_data_curr_rec.txn_currency_code);

                                          -- checking for existing RAs, the sp_fixed_date lies in the correct
                                          -- period where amounts have been entered
                                          IF l_cached_ra_id_tbl.EXISTS(l_cached_ra_index) AND
                                             l_cached_ra_id_tbl(l_cached_ra_index) <> -1 AND
                                             l_fix_sc_amt_pd_curr_index IS NOT NULL THEN
                                                 l_sp_fix_prd_st_dt := p_prd_start_date_tbl(l_fix_sc_amt_pd_curr_index);
                                                 l_sp_fix_prd_en_dt := p_prd_end_date_tbl(l_fix_sc_amt_pd_curr_index);

                                                 IF NOT (l_sp_fixed_date >= l_sp_fix_prd_st_dt AND
                                                         l_sp_fix_prd_st_dt <= l_sp_fix_prd_en_dt) THEN
                                                         l_err_val_code_tbl.extend(1);
                                                         l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_FX_SC_MUL_AMT_ERR';
                                                         l_err_task_id_tbl.extend(1);
                                                         l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                                         l_err_rlm_id_tbl.extend(1);
                                                         l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                                         l_err_txn_curr_tbl.extend(1);
                                                         l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                                         l_err_amt_type_tbl.extend(1);
                                                         l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                                         RAISE Fp_Webadi_Skip_Rec_Proc_Exc; /* to skip processing for the current record */
                                                 END IF;
                                          END IF;
                                    END IF; -- period not null

                                    --If the next record too belongs to the same RA as that of the current record
                                    --Find out the period for which amounts are entered in that record
                                    IF l_inf_tbl_data_next_rec.task_id IS NOT NULL AND
                                       l_inf_tbl_data_curr_rec.task_id = l_inf_tbl_data_next_rec.task_id AND
                                       l_inf_tbl_data_curr_rec.resource_list_member_id = l_inf_tbl_data_next_rec.resource_list_member_id THEN
                                              -- checkin for fixed date spread curve
                                              -- if the same resource appears in the next record too
                                              -- finding out the period index for which amount is present
                                              l_fix_sc_amt_pd_next_index := NULL;
                                              IF is_forecast_version = 'Y' THEN
                                                     IF l_inf_tbl_data_next_rec.prd1 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd1 <> l_fnd_miss_num AND
                                                        l_prd_start_date_tbl(1) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(1) - 1)) THEN
                                                           l_fix_sc_amt_pd_next_index := 1;
                                                     ELSIF l_inf_tbl_data_next_rec.prd2 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd2 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(2) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(2) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 2;
                                                     ELSIF l_inf_tbl_data_next_rec.prd3 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd3 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(3) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(3) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 3;
                                                     ELSIF l_inf_tbl_data_next_rec.prd4 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd4 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(4) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(4) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 4;
                                                     ELSIF l_inf_tbl_data_next_rec.prd5 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd5 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(5) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(5) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 5;
                                                     ELSIF l_inf_tbl_data_next_rec.prd6 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd6 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(6) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(6) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 6;
                                                     ELSIF l_inf_tbl_data_next_rec.prd7 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd7 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(7) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(7) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 7;
                                                     ELSIF l_inf_tbl_data_next_rec.prd8 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd8 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(8) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(8) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 8;
                                                     ELSIF l_inf_tbl_data_next_rec.prd9 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd9 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(9) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(9) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 9;
                                                     ELSIF l_inf_tbl_data_next_rec.prd10 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd10 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(10) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(10) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 10;
                                                     ELSIF l_inf_tbl_data_next_rec.prd11 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd11 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(11) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(11) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 11;
                                                     ELSIF l_inf_tbl_data_next_rec.prd12 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd12 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(12) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(12) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 12;
                                                     ELSIF l_inf_tbl_data_next_rec.prd13 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd13 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(13) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(13) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 13;
                                                     ELSIF l_inf_tbl_data_next_rec.prd14 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd14 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(14) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(14) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 14;
                                                     ELSIF l_inf_tbl_data_next_rec.prd15 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd15 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(15) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(15) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 15;
                                                     ELSIF l_inf_tbl_data_next_rec.prd16 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd16 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(16) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(16) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 16;
                                                     ELSIF l_inf_tbl_data_next_rec.prd17 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd17 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(17) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(17) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 17;
                                                     ELSIF l_inf_tbl_data_next_rec.prd18 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd18 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(18) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(18) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 18;
                                                     ELSIF l_inf_tbl_data_next_rec.prd19 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd19 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(19) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(19) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 19;
                                                     ELSIF l_inf_tbl_data_next_rec.prd20 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd20 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(20) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(20) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 20;
                                                     ELSIF l_inf_tbl_data_next_rec.prd21 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd21 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(21) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(21) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 21;
                                                     ELSIF l_inf_tbl_data_next_rec.prd22 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd22 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(22) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(22) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 22;
                                                     ELSIF l_inf_tbl_data_next_rec.prd23 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd23 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(23) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(23) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 23;
                                                     ELSIF l_inf_tbl_data_next_rec.prd24 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd24 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(24) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(34) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 24;
                                                     ELSIF l_inf_tbl_data_next_rec.prd25 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd25 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(25) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(25) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 25;
                                                     ELSIF l_inf_tbl_data_next_rec.prd26 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd26 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(26) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(26) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 26;
                                                     ELSIF l_inf_tbl_data_next_rec.prd27 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd27 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(27) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(27) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 27;
                                                     ELSIF l_inf_tbl_data_next_rec.prd28 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd28 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(28) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(28) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 28;
                                                     ELSIF l_inf_tbl_data_next_rec.prd29 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd29 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(29) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(29) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 29;
                                                     ELSIF l_inf_tbl_data_next_rec.prd30 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd30 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(30) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(30) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 30;
                                                     ELSIF l_inf_tbl_data_next_rec.prd31 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd31 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(31) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(31) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 31;
                                                     ELSIF l_inf_tbl_data_next_rec.prd32 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd32 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(32) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(32) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 32;
                                                     ELSIF l_inf_tbl_data_next_rec.prd33 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd33 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(33) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(33) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 33;
                                                     ELSIF l_inf_tbl_data_next_rec.prd34 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd34 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(34) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(34) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 34;
                                                     ELSIF l_inf_tbl_data_next_rec.prd35 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd35 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(35) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(35) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 35;
                                                     ELSIF l_inf_tbl_data_next_rec.prd36 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd36 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(36) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(36) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 36;
                                                     ELSIF l_inf_tbl_data_next_rec.prd37 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd37 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(37) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(37) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 37;
                                                     ELSIF l_inf_tbl_data_next_rec.prd38 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd38 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(38) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(38) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 38;
                                                     ELSIF l_inf_tbl_data_next_rec.prd39 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd39 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(39) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(39) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 39;
                                                     ELSIF l_inf_tbl_data_next_rec.prd40 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd40 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(40) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(40) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 40;
                                                     ELSIF l_inf_tbl_data_next_rec.prd41 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd41 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(41) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(41) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 41;
                                                     ELSIF l_inf_tbl_data_next_rec.prd42 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd42 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(42) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(42) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 42;
                                                     ELSIF l_inf_tbl_data_next_rec.prd43 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd43 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(43) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(43) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 43;
                                                     ELSIF l_inf_tbl_data_next_rec.prd44 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd44 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(44) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(44) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 44;
                                                     ELSIF l_inf_tbl_data_next_rec.prd45 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd45 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(45) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(45) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 45;
                                                     ELSIF l_inf_tbl_data_next_rec.prd46 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd46 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(46) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(46) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 46;
                                                     ELSIF l_inf_tbl_data_next_rec.prd47 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd47 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(47) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(47) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 47;
                                                     ELSIF l_inf_tbl_data_next_rec.prd48 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd48 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(48) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(48) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 48;
                                                     ELSIF l_inf_tbl_data_next_rec.prd49 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd49 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(49) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(49) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 49;
                                                     ELSIF l_inf_tbl_data_next_rec.prd50 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd50 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(50) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(50) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 50;
                                                     ELSIF l_inf_tbl_data_next_rec.prd51 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd51 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(51) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(51) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 51;
                                                     ELSIF l_inf_tbl_data_next_rec.prd52 IS NOT NULL AND
                                                           l_inf_tbl_data_next_rec.prd52 <> l_fnd_miss_num AND
                                                           l_prd_start_date_tbl(52) >= Nvl(l_etc_start_date, (l_prd_start_date_tbl(52) - 1)) THEN
                                                                l_fix_sc_amt_pd_next_index := 52;
                                                     END IF; -- period not null
                                              ELSE
                                                     -- budget versions
                                                     IF l_inf_tbl_data_next_rec.prd1 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd1 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 1;
                                                     ELSIF l_inf_tbl_data_next_rec.prd2 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd2 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 2;
                                                     ELSIF l_inf_tbl_data_next_rec.prd3 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd3 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 3;
                                                     ELSIF l_inf_tbl_data_next_rec.prd4 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd4 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 4;
                                                     ELSIF l_inf_tbl_data_next_rec.prd5 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd5 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 5;
                                                     ELSIF l_inf_tbl_data_next_rec.prd6 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd6 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 6;
                                                     ELSIF l_inf_tbl_data_next_rec.prd7 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd7 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 7;
                                                     ELSIF l_inf_tbl_data_next_rec.prd8 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd8 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 8;
                                                     ELSIF l_inf_tbl_data_next_rec.prd9 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd9 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 9;
                                                     ELSIF l_inf_tbl_data_next_rec.prd10 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd10 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 10;
                                                     ELSIF l_inf_tbl_data_next_rec.prd11 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd11 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 11;
                                                     ELSIF l_inf_tbl_data_next_rec.prd12 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd12 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 12;
                                                     ELSIF l_inf_tbl_data_next_rec.prd13 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd13 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 13;
                                                     ELSIF l_inf_tbl_data_next_rec.prd14 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd14 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 14;
                                                     ELSIF l_inf_tbl_data_next_rec.prd15 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd15 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 15;
                                                     ELSIF l_inf_tbl_data_next_rec.prd16 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd16 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 16;
                                                     ELSIF l_inf_tbl_data_next_rec.prd17 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd17 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 17;
                                                     ELSIF l_inf_tbl_data_next_rec.prd18 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd18 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 18;
                                                     ELSIF l_inf_tbl_data_next_rec.prd19 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd19 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 19;
                                                     ELSIF l_inf_tbl_data_next_rec.prd20 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd20 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 20;
                                                     ELSIF l_inf_tbl_data_next_rec.prd21 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd21 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 21;
                                                     ELSIF l_inf_tbl_data_next_rec.prd22 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd22 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 22;
                                                     ELSIF l_inf_tbl_data_next_rec.prd23 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd23 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 23;
                                                     ELSIF l_inf_tbl_data_next_rec.prd24 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd24 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 24;
                                                     ELSIF l_inf_tbl_data_next_rec.prd25 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd25 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 25;
                                                     ELSIF l_inf_tbl_data_next_rec.prd26 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd26 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 26;
                                                     ELSIF l_inf_tbl_data_next_rec.prd27 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd27 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 27;
                                                     ELSIF l_inf_tbl_data_next_rec.prd28 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd28 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 28;
                                                     ELSIF l_inf_tbl_data_next_rec.prd29 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd29 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 29;
                                                     ELSIF l_inf_tbl_data_next_rec.prd30 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd30 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 30;
                                                     ELSIF l_inf_tbl_data_next_rec.prd31 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd31 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 31;
                                                     ELSIF l_inf_tbl_data_next_rec.prd32 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd32 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 32;
                                                     ELSIF l_inf_tbl_data_next_rec.prd33 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd33 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 33;
                                                     ELSIF l_inf_tbl_data_next_rec.prd34 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd34 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 34;
                                                     ELSIF l_inf_tbl_data_next_rec.prd35 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd35 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 35;
                                                     ELSIF l_inf_tbl_data_next_rec.prd36 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd36 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 36;
                                                     ELSIF l_inf_tbl_data_next_rec.prd37 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd37 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 37;
                                                     ELSIF l_inf_tbl_data_next_rec.prd38 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd38 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 38;
                                                     ELSIF l_inf_tbl_data_next_rec.prd39 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd39 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 39;
                                                     ELSIF l_inf_tbl_data_next_rec.prd40 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd40 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 40;
                                                     ELSIF l_inf_tbl_data_next_rec.prd41 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd41 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 41;
                                                     ELSIF l_inf_tbl_data_next_rec.prd42 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd42 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 42;
                                                     ELSIF l_inf_tbl_data_next_rec.prd43 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd43 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 43;
                                                     ELSIF l_inf_tbl_data_next_rec.prd44 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd44 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 44;
                                                     ELSIF l_inf_tbl_data_next_rec.prd45 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd45 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 45;
                                                     ELSIF l_inf_tbl_data_next_rec.prd46 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd46 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 46;
                                                     ELSIF l_inf_tbl_data_next_rec.prd47 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd47 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 47;
                                                     ELSIF l_inf_tbl_data_next_rec.prd48 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd48 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 48;
                                                     ELSIF l_inf_tbl_data_next_rec.prd49 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd49 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 49;
                                                     ELSIF l_inf_tbl_data_next_rec.prd50 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd50 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 50;
                                                     ELSIF l_inf_tbl_data_next_rec.prd51 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd51 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 51;
                                                     ELSIF l_inf_tbl_data_next_rec.prd52 IS NOT NULL AND
                                                        l_inf_tbl_data_next_rec.prd52 <> l_fnd_miss_num THEN
                                                           l_fix_sc_amt_pd_next_index := 52;
                                                     END IF; -- period not null
                                              END IF;
                                              --log1('l_cached_ra_index is '||l_cached_ra_index);
                                              --log1('l_cached_ra_id_tbl(l_cached_ra_index) is '||l_cached_ra_id_tbl(l_cached_ra_index));

                                              --log1('l_fix_sc_amt_pd_next_index is '||l_fix_sc_amt_pd_next_index);
                                              --log1('l_fix_sc_amt_pd_curr_index is '||l_fix_sc_amt_pd_curr_index);
                                              -- checking for existing RAs, the sp_fixed_date lies in the correct
                                              -- period where amounts have been entered
                                              IF l_cached_ra_id_tbl.EXISTS(l_cached_ra_index) AND
                                                 l_cached_ra_id_tbl(l_cached_ra_index) <> -1 AND
                                                 l_fix_sc_amt_pd_next_index IS NOT NULL THEN
                                                     l_sp_fix_prd_st_dt := p_prd_start_date_tbl(l_fix_sc_amt_pd_next_index);
                                                     l_sp_fix_prd_en_dt := p_prd_end_date_tbl(l_fix_sc_amt_pd_next_index);

                                                     --log1('l_sp_fix_prd_st_dt is '||l_sp_fix_prd_st_dt);
                                                     --log1('l_sp_fix_prd_en_dt is '||l_sp_fix_prd_en_dt);

                                                     IF NOT (l_sp_fixed_date >= l_sp_fix_prd_st_dt AND
                                                             l_sp_fix_prd_st_dt <= l_sp_fix_prd_en_dt) THEN
                                                             l_err_val_code_tbl.extend(1);
                                                             l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_FX_SC_MUL_AMT_ERR';
                                                             l_err_task_id_tbl.extend(1);
                                                             l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_next_rec.task_id;
                                                             l_err_rlm_id_tbl.extend(1);
                                                             l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_next_rec.resource_list_member_id;
                                                             l_err_txn_curr_tbl.extend(1);
                                                             l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_next_rec.txn_currency_code;
                                                             l_err_amt_type_tbl.extend(1);
                                                             l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_next_rec.amount_type_code;

                                                             RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                                     END IF;
                                              END IF;

                                              IF l_fix_sc_amt_pd_curr_index <> l_fix_sc_amt_pd_next_index THEN
                                                    -- amount has been entred in a different period from the previous record
                                                    l_err_val_code_tbl.extend(1);
                                                    l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_FX_SC_MUL_AMT_ERR';
                                                    l_err_task_id_tbl.extend(1);
                                                    l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_next_rec.task_id;
                                                    l_err_rlm_id_tbl.extend(1);
                                                    l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_next_rec.resource_list_member_id;
                                                    l_err_txn_curr_tbl.extend(1);
                                                    l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_next_rec.txn_currency_code;
                                                    l_err_amt_type_tbl.extend(1);
                                                    l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_next_rec.amount_type_code;

                                                    RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                              END IF;
                                              -- assigning the index of not null period of the next record to the current one
                                              l_fix_sc_amt_pd_curr_index := NVL(l_fix_sc_amt_pd_next_index,l_fix_sc_amt_pd_curr_index);

                                    END IF;

                        END IF;

                        -- validation for UOM and other resource attributes, to check if they are same for all the rows,
                        -- if the RA is same as well checking for planning start date/end date
                        IF l_inf_tbl_data_next_rec.task_id IS NOT NULL AND
                           l_inf_tbl_data_curr_rec.task_id = l_inf_tbl_data_next_rec.task_id AND
                           l_inf_tbl_data_curr_rec.resource_list_member_id = l_inf_tbl_data_next_rec.resource_list_member_id THEN


                                  -- checking for UOM
                                  IF l_inf_tbl_data_curr_rec.unit_of_measure <> l_inf_tbl_data_next_rec.unit_of_measure THEN
                                       l_err_val_code_tbl.extend(1);
                                       l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_UOM_MISS_MATCH_ERR';
                                       l_err_task_id_tbl.extend(1);
                                       l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                       l_err_rlm_id_tbl.extend(1);
                                       l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                       l_err_txn_curr_tbl.extend(1);
                                       l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                       l_err_amt_type_tbl.extend(1);
                                       l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                       RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                  END IF;
                                  -- checking for spread curve
                                  IF l_inf_tbl_data_curr_rec.spread_curve_name <> l_inf_tbl_data_next_rec.spread_curve_name THEN
                                       l_err_val_code_tbl.extend(1);
                                       l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_SC_MISS_MATCH_ERR';
                                       l_err_task_id_tbl.extend(1);
                                       l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                       l_err_rlm_id_tbl.extend(1);
                                       l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                       l_err_txn_curr_tbl.extend(1);
                                       l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                       l_err_amt_type_tbl.extend(1);
                                       l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                       RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                  END IF;
                                  -- checking for etc method
                                  IF l_inf_tbl_data_curr_rec.etc_method_name <> l_inf_tbl_data_next_rec.etc_method_name THEN
                                       l_err_val_code_tbl.extend(1);
                                       l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_ETC_MISS_MATCH_ERR';
                                       l_err_task_id_tbl.extend(1);
                                       l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                       l_err_rlm_id_tbl.extend(1);
                                       l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                       l_err_txn_curr_tbl.extend(1);
                                       l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                       l_err_amt_type_tbl.extend(1);
                                       l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                       RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                  END IF;
                                  -- checking for mfc cost type
                                  IF l_inf_tbl_data_curr_rec.mfc_cost_type_name <> l_inf_tbl_data_next_rec.mfc_cost_type_name THEN
                                       l_err_val_code_tbl.extend(1);
                                       l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_MFC_MISS_MATCH_ERR';
                                       l_err_task_id_tbl.extend(1);
                                       l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                       l_err_rlm_id_tbl.extend(1);
                                       l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                       l_err_txn_curr_tbl.extend(1);
                                       l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                       l_err_amt_type_tbl.extend(1);
                                       l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                       RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                  END IF;
/* commenting out this code block as its not required to check now

                                  -- checking if the planning start date and end dates are same across same RA
                                  IF l_inf_tbl_data_curr_rec.planning_start_date <> l_inf_tbl_data_next_rec.planning_start_date THEN
                                        l_err_val_code_tbl.extend(1);
                                        l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_PLAN_ST_DT_MISS_MATCH';
                                        l_err_task_id_tbl.extend(1);
                                        l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                        l_err_rlm_id_tbl.extend(1);
                                        l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                        l_err_txn_curr_tbl.extend(1);
                                        l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                        l_err_amt_type_tbl.extend(1);
                                        l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                        RAISE Fp_Webadi_Skip_Rec_Proc_Exc; -- to skip processing for the current record
                                  END IF;
                                  IF l_inf_tbl_data_curr_rec.planning_end_date <> l_inf_tbl_data_next_rec.planning_end_date THEN
                                        l_err_val_code_tbl.extend(1);
                                        l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_PLAN_EN_DT_MISS_MATCH';
                                        l_err_task_id_tbl.extend(1);
                                        l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                        l_err_rlm_id_tbl.extend(1);
                                        l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                        l_err_txn_curr_tbl.extend(1);
                                        l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                        l_err_amt_type_tbl.extend(1);
                                        l_err_amt_type_tbl(l_err_amt_type_tbl.COUNT) := l_inf_tbl_data_curr_rec.amount_type_code;

                                        RAISE Fp_Webadi_Skip_Rec_Proc_Exc; -- to skip processing for the current record
                                  END IF;
*/
                        END IF;  -- same task and resource

                     ELSE  -- non periodic
                          --log1('----- STAGE 19.2-------');
                          IF l_cached_ra_id_tbl.EXISTS(l_cached_ra_index) AND
                             l_cached_ra_id_tbl(l_cached_ra_index) = -1 THEN
                                IF l_plan_start_date IS NULL AND
                                   l_plan_end_date IS NOT NULL THEN
                                         l_err_val_code_tbl.extend(1);
                                         l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_PLAN_ST_DT_MISS_ERR';
                                         l_err_task_id_tbl.extend(1);
                                         l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                         l_err_rlm_id_tbl.extend(1);
                                         l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                         l_err_txn_curr_tbl.extend(1);
                                         l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                         RAISE Fp_Webadi_Skip_Rec_Proc_Exc; /* to skip processing for the current record */
                                ELSIF l_plan_start_date IS NOT NULL AND
                                      l_plan_end_date IS NULL THEN
                                         l_err_val_code_tbl.extend(1);
                                         l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_PLAN_END_DT_MISS_ERR';
                                         l_err_task_id_tbl.extend(1);
                                         l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                         l_err_rlm_id_tbl.extend(1);
                                         l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                         l_err_txn_curr_tbl.extend(1);
                                         l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                         RAISE Fp_Webadi_Skip_Rec_Proc_Exc; /* to skip processing for the current record */
                                END IF;  -- planning dates null
                          END IF;

                          --log1('----- STAGE 19.3-------');
                          -- checking if the sp fixed date is within planning start/end date
                          IF (l_plan_start_date > Nvl(l_sp_fixed_date, (l_plan_start_date + 1)))OR
                             (l_plan_end_date < Nvl(l_sp_fixed_date, (l_plan_end_date - 1))) THEN
                                l_err_val_code_tbl.extend(1);
                                l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_SP_FX_DT_OUT_RANGE';
                                l_err_task_id_tbl.extend(1);
                                l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                l_err_rlm_id_tbl.extend(1);
                                l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                l_err_txn_curr_tbl.extend(1);
                                l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;
                                RAISE Fp_Webadi_Skip_Rec_Proc_Exc; /* to skip processing for the current record */
                          END IF;

                          --log1('----- STAGE 19.4-------');
                          -- validation for UOM and other resource attributes, to check if they are same for all the rows,
                          -- if the RA is same
                          IF l_inf_tbl_data_next_rec.task_id IS NOT NULL AND
                             l_inf_tbl_data_curr_rec.task_id = l_inf_tbl_data_next_rec.task_id AND
                             l_inf_tbl_data_curr_rec.resource_list_member_id = l_inf_tbl_data_next_rec.resource_list_member_id THEN
                                    -- checking for UOM
                                    IF l_inf_tbl_data_curr_rec.unit_of_measure <> l_inf_tbl_data_next_rec.unit_of_measure THEN
                                         l_err_val_code_tbl.extend(1);
                                         l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_UOM_MISS_MATCH_ERR';
                                         l_err_task_id_tbl.extend(1);
                                         l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                         l_err_rlm_id_tbl.extend(1);
                                         l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                         l_err_txn_curr_tbl.extend(1);
                                         l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;

                                         RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                    END IF;
                                    -- checking for spread curve name
                                    IF l_inf_tbl_data_curr_rec.spread_curve_name <> l_inf_tbl_data_next_rec.spread_curve_name THEN
                                         l_err_val_code_tbl.extend(1);
                                         l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_SC_MISS_MATCH_ERR';
                                         l_err_task_id_tbl.extend(1);
                                         l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                         l_err_rlm_id_tbl.extend(1);
                                         l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                         l_err_txn_curr_tbl.extend(1);
                                         l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;

                                         RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                    END IF;
                                    -- checking for etc method name
                                    IF l_inf_tbl_data_curr_rec.etc_method_name <> l_inf_tbl_data_next_rec.etc_method_name THEN
                                         l_err_val_code_tbl.extend(1);
                                         l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_ETC_MISS_MATCH_ERR';
                                         l_err_task_id_tbl.extend(1);
                                         l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                         l_err_rlm_id_tbl.extend(1);
                                         l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                         l_err_txn_curr_tbl.extend(1);
                                         l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;

                                         RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                    END IF;
                                    -- checking for mfc cost type name
                                    IF l_inf_tbl_data_curr_rec.mfc_cost_type_name <> l_inf_tbl_data_next_rec.mfc_cost_type_name THEN
                                         l_err_val_code_tbl.extend(1);
                                         l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_MFC_MISS_MATCH_ERR';
                                         l_err_task_id_tbl.extend(1);
                                         l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                         l_err_rlm_id_tbl.extend(1);
                                         l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                         l_err_txn_curr_tbl.extend(1);
                                         l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;

                                         RAISE Fp_Webadi_Skip_Next_Rec_Exc; /* to skip processing for the current record */
                                    END IF;

/* commenting out this code block as its not required to check now
                                    -- checking if the planning start date and end dates are same across same RA
                                    IF l_inf_tbl_data_curr_rec.planning_start_date <> l_inf_tbl_data_next_rec.planning_start_date THEN
                                          l_err_val_code_tbl.extend(1);
                                          l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_PLAN_ST_DT_MISS_MATCH';
                                          l_err_task_id_tbl.extend(1);
                                          l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                          l_err_rlm_id_tbl.extend(1);
                                          l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                          l_err_txn_curr_tbl.extend(1);
                                          l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;

                                          RAISE Fp_Webadi_Skip_Rec_Proc_Exc; -- to skip processing for the current record
                                    END IF;
                                    IF l_inf_tbl_data_curr_rec.planning_end_date <> l_inf_tbl_data_next_rec.planning_end_date THEN
                                          l_err_val_code_tbl.extend(1);
                                          l_err_val_code_tbl(l_err_val_code_tbl.COUNT) := 'PA_FP_WA_PLAN_EN_DT_MISS_MATCH';
                                          l_err_task_id_tbl.extend(1);
                                          l_err_task_id_tbl(l_err_task_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.task_id;
                                          l_err_rlm_id_tbl.extend(1);
                                          l_err_rlm_id_tbl(l_err_rlm_id_tbl.COUNT) := l_inf_tbl_data_curr_rec.resource_list_member_id;
                                          l_err_txn_curr_tbl.extend(1);
                                          l_err_txn_curr_tbl(l_err_txn_curr_tbl.COUNT) := l_inf_tbl_data_curr_rec.txn_currency_code;

                                          RAISE Fp_Webadi_Skip_Rec_Proc_Exc; -- to skip processing for the current record
                                    END IF;
*/
                          END IF;  -- same task and resource
                          --log1('----- STAGE 19.5-------');

                     END IF;  -- non periodic

                     IF l_plan_trans_attr_copied_flag = 'N' THEN
                          --log1('----- STAGE 101-------');
                          -- populating an indicator to be passed to validate_budget_lines for the record
                          l_delete_flag := 'Y';
                     ELSE
                          --log1('----- STAGE 102-------');
                          l_delete_flag := 'N';
                     END IF;

                     IF is_periodic_setup = 'Y' THEN
                          --log1('----- STAGE 103-------');
                          IF l_inf_tbl_data_curr_rec.amount_type_code = 'TOTAL_RAW_COST' THEN
                             l_raw_cost := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'FCST_RAW_COST' THEN
                                l_raw_cost := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'ETC_RAW_COST' THEN
                                l_etc_raw_cost := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'TOTAL_BURDENED_COST' THEN
                                l_burdened_cost := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'FCST_BURDENED_COST' THEN
                                l_burdened_cost := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'ETC_BURDENED_COST' THEN
                                l_etc_burdened_cost := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'TOTAL_REV' THEN
                                l_revenue := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'FCST_REVENUE' THEN
                                l_revenue := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'ETC_REVENUE' THEN
                                l_etc_revenue := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'TOTAL_QTY' THEN
                                l_quantity := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'FCST_QTY' THEN
                                l_quantity := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code = 'ETC_QTY' THEN
                                l_etc_quantity := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code IN ('RAW_COST_RATE','ETC_RAW_COST_RATE') THEN
                                   l_rc_rate := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code IN ('ETC_BURDENED_COST_RATE','BURDENED_COST_RATE') THEN
                                   l_bc_rate := l_tmp_sum_amt;
                          ELSIF l_inf_tbl_data_curr_rec.amount_type_code IN ('BILL_RATE','ETC_BILL_RATE') THEN
                                   l_bill_rate := l_tmp_sum_amt;
                          END IF;
                     ELSE
                           --log1('----- STAGE 104-------');
                       IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Opening Cursor non_prd_lyt_null_val_cur';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;
                           OPEN non_prd_lyt_null_val_cur( l_inf_tbl_data_curr_rec.budget_version_id,
                                                          l_inf_tbl_data_curr_rec.task_id,
                                                          l_inf_tbl_data_curr_rec.resource_list_member_id,
                                                          l_inf_tbl_data_curr_rec.txn_currency_code);
                           FETCH non_prd_lyt_null_val_cur INTO
                                                              l_ratxn_total_quantity,
                                                              l_ratxn_total_raw_cost,
                                                              l_ratxn_total_burdened_cost,
                                                              l_ratxn_total_revenue,
                                                              l_ratxn_etc_quantity,
                                                              l_ratxn_etc_raw_cost,
                                                              l_ratxn_etc_burdened_cost,
                                                              l_ratxn_etc_revenue,
                                                              l_ratxn_raw_cost_over_rate,
                                                              l_ratxn_burden_cost_over_rate,
                                                              l_ratxn_bill_over_rate,
                                                              l_ra_rate_based_flag;
                           CLOSE non_prd_lyt_null_val_cur;
                       IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'l_ratxn_total_quantity' || l_ratxn_total_quantity;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ratxn_total_raw_cost' || l_ratxn_total_raw_cost;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ratxn_total_burdened_cost' || l_ratxn_total_burdened_cost;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ratxn_etc_quantity' || l_ratxn_etc_quantity;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ratxn_etc_raw_cost' || l_ratxn_etc_raw_cost;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ratxn_etc_burdened_cost' || l_ratxn_etc_burdened_cost;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ratxn_etc_revenue' || l_ratxn_etc_revenue;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ratxn_etc_revenue' || l_ratxn_etc_revenue;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ratxn_bill_over_rate' || l_ratxn_bill_over_rate;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.g_err_stage := 'l_ra_rate_based_flag' || l_ra_rate_based_flag;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;


                           IF l_ratxn_total_quantity IS NULL AND (l_inf_tbl_data_curr_rec.quantity = l_fnd_miss_num) THEN
                              l_quantity := NULL;
                           ELSE
                              l_quantity := l_inf_tbl_data_curr_rec.quantity;
                           END IF;
                           IF l_ratxn_total_raw_cost IS NULL AND (l_inf_tbl_data_curr_rec.raw_cost = l_fnd_miss_num) THEN
                              l_raw_cost := NULL;
                           ELSE
                              l_raw_cost := l_inf_tbl_data_curr_rec.raw_cost;
                           END IF;
                           IF l_ratxn_total_burdened_cost IS NULL AND (l_inf_tbl_data_curr_rec.burdened_cost = l_fnd_miss_num) THEN
                              l_burdened_cost := NULL;
                           ELSE
                              l_burdened_cost := l_inf_tbl_data_curr_rec.burdened_cost;
                           END IF;
                           IF l_ratxn_total_revenue IS NULL AND (l_inf_tbl_data_curr_rec.revenue = l_fnd_miss_num) THEN
                              l_revenue := NULL;
                           ELSE
                              l_revenue := l_inf_tbl_data_curr_rec.revenue;
                           END IF;
                           IF l_ratxn_etc_quantity IS NULL AND (l_inf_tbl_data_curr_rec.etc_quantity = l_fnd_miss_num) THEN
                              l_etc_quantity := NULL;
                           ELSE
                              l_etc_quantity := l_inf_tbl_data_curr_rec.etc_quantity;
                           END IF;
                           IF l_ratxn_etc_raw_cost IS NULL AND (l_inf_tbl_data_curr_rec.etc_raw_cost = l_fnd_miss_num) THEN
                              l_etc_raw_cost := NULL;
                           ELSE
                              l_etc_raw_cost := l_inf_tbl_data_curr_rec.etc_raw_cost;
                           END IF;
                           IF l_ratxn_etc_burdened_cost IS NULL AND (l_inf_tbl_data_curr_rec.etc_burdened_cost = l_fnd_miss_num) THEN
                              l_etc_burdened_cost := NULL;
                           ELSE
                              l_etc_burdened_cost := l_inf_tbl_data_curr_rec.etc_burdened_cost;
                           END IF;
                           IF l_ratxn_etc_revenue IS NULL AND (l_inf_tbl_data_curr_rec.etc_revenue = l_fnd_miss_num) THEN
                              l_etc_revenue := NULL;
                           ELSE
                              l_etc_revenue := l_inf_tbl_data_curr_rec.etc_revenue;
                           END IF;
                           /* Bug 5068203 : Changes are made to the override rates so that the override rates
                              will be calculated as NULL instead of g_miss_num for a resource assignment
                              with rate_based_flag as 'N' and has value for override rates in new entity
                              and has no changes in Excel while uploaded from Excel with Non-Periodic layout.
                           */
                           IF l_ra_rate_based_flag = 'Y' THEN
                              IF l_ratxn_raw_cost_over_rate IS NULL AND (l_inf_tbl_data_curr_rec.raw_cost_rate = l_fnd_miss_num) THEN
                                 l_rc_rate := NULL;
                              ELSE
                                 l_rc_rate := l_inf_tbl_data_curr_rec.raw_cost_rate;
                              END IF;
                           ELSE
                              IF l_inf_tbl_data_curr_rec.quantity = l_fnd_miss_num AND (l_inf_tbl_data_curr_rec.etc_quantity IS NULL OR l_inf_tbl_data_curr_rec.etc_quantity = l_fnd_miss_num) THEN
                                 l_rc_rate := NULL;
                              ELSIF l_inf_tbl_data_curr_rec.raw_cost_rate = l_fnd_miss_num THEN
                                 l_rc_rate := NULL;
                              ELSE
                                 l_rc_rate := l_inf_tbl_data_curr_rec.raw_cost_rate;
                              END IF;
                           END IF;

                           IF l_ra_rate_based_flag = 'Y' THEN
                              IF l_ratxn_burden_cost_over_rate IS NULL AND (l_inf_tbl_data_curr_rec.burdened_cost_rate = l_fnd_miss_num) THEN
                                 l_bc_rate := NULL;
                              ELSE
                                 l_bc_rate := l_inf_tbl_data_curr_rec.burdened_cost_rate;
                              END IF;
                           ELSE
                              IF l_inf_tbl_data_curr_rec.quantity = l_fnd_miss_num AND (l_inf_tbl_data_curr_rec.etc_quantity IS NULL OR l_inf_tbl_data_curr_rec.etc_quantity = l_fnd_miss_num) THEN
                                 l_bc_rate := NULL;
                              ELSIF l_inf_tbl_data_curr_rec.burdened_cost_rate = l_fnd_miss_num THEN
                                 l_bc_rate := NULL;
                              ELSE
                                 l_bc_rate := l_inf_tbl_data_curr_rec.burdened_cost_rate;
                              END IF;
                           END IF;

                           IF l_ra_rate_based_flag = 'Y' THEN
                              IF l_ratxn_bill_over_rate IS NULL AND (l_inf_tbl_data_curr_rec.bill_rate = l_fnd_miss_num) THEN
                                 l_bill_rate := NULL;
                              ELSE
                                 l_bill_rate := l_inf_tbl_data_curr_rec.bill_rate;
                              END IF;
                           ELSE
                              IF l_inf_tbl_data_curr_rec.quantity = l_fnd_miss_num AND (l_inf_tbl_data_curr_rec.etc_quantity IS NULL OR l_inf_tbl_data_curr_rec.etc_quantity = l_fnd_miss_num) THEN
                                 l_bill_rate := NULL;
                              ELSIF l_inf_tbl_data_curr_rec.bill_rate = l_fnd_miss_num THEN
                                 l_bill_rate := NULL;
                              ELSE
                                 l_bill_rate := l_inf_tbl_data_curr_rec.bill_rate;
                              END IF;
                           END IF;

           /*                l_raw_cost          := l_inf_tbl_data_curr_rec.raw_cost;
                           l_burdened_cost     := l_inf_tbl_data_curr_rec.burdened_cost;
                           l_revenue           := l_inf_tbl_data_curr_rec.revenue;
                           l_quantity          := l_inf_tbl_data_curr_rec.quantity;
                           l_etc_quantity      := l_inf_tbl_data_curr_rec.etc_quantity;
                           l_etc_raw_cost      := l_inf_tbl_data_curr_rec.etc_raw_cost;
                           l_etc_burdened_cost := l_inf_tbl_data_curr_rec.etc_burdened_cost;
                           l_etc_revenue       := l_inf_tbl_data_curr_rec.etc_revenue;

                           l_rc_rate := l_inf_tbl_data_curr_rec.raw_cost_rate;
                           l_bc_rate := l_inf_tbl_data_curr_rec.burdened_cost_rate;
                           l_bill_rate := l_inf_tbl_data_curr_rec.bill_rate;   */
                     END IF;

                     -- initializing the min and max budget line dates
                     IF l_min_bdgt_line_start_date IS NULL THEN
                         l_min_bdgt_line_start_date:=l_bdgt_line_start_date;
                     ELSIF l_bdgt_line_start_date IS NOT NULL AND l_bdgt_line_start_date < l_min_bdgt_line_start_date THEN
                         l_min_bdgt_line_start_date:=l_bdgt_line_start_date;
                     END IF;

                     IF l_max_bdgt_line_end_date IS NULL THEN
                         l_max_bdgt_line_end_date:=l_bdgt_line_end_date;
                     ELSIF l_bdgt_line_end_date IS NOT NULL AND l_bdgt_line_end_date > l_max_bdgt_line_end_date THEN
                         l_max_bdgt_line_end_date:=l_bdgt_line_end_date;
                     END IF;

                     --log1('----- STAGE 105-------');
                     --Prepare the pl/sql tbls to be passed to validate_budget_lines API for each
                     --planning transaction
                     IF l_inf_tbl_data_next_rec.task_id IS NULL OR
                        Nvl(l_inf_tbl_data_next_rec.txn_currency_code, '-99') <> Nvl(l_inf_tbl_data_curr_rec.txn_currency_code, '-99') OR
                        l_inf_tbl_data_next_rec.task_id <> l_inf_tbl_data_curr_rec.task_id OR
                        l_inf_tbl_data_next_rec.resource_list_member_id <> l_inf_tbl_data_curr_rec.resource_list_member_id THEN

                        l_budget_line_in_out_tbl(bl_count).pa_task_id        := l_inf_tbl_data_curr_rec.task_id;
                        l_budget_line_in_out_tbl(bl_count).resource_list_member_id := l_inf_tbl_data_curr_rec.resource_list_member_id;

                        l_budget_line_in_out_tbl(bl_count).budget_start_date := l_min_bdgt_line_start_date;
                        l_budget_line_in_out_tbl(bl_count).budget_end_date   := l_max_bdgt_line_end_date;

                        l_budget_line_in_out_tbl(bl_count).raw_cost          := l_raw_cost;
                        l_budget_line_in_out_tbl(bl_count).burdened_cost     := l_burdened_cost;
                        l_budget_line_in_out_tbl(bl_count).revenue           := l_revenue;
                        l_budget_line_in_out_tbl(bl_count).quantity          := l_quantity;

                        x_etc_quantity_tbl.extend;
                        x_etc_raw_cost_tbl.extend;
                        x_etc_burdened_cost_tbl.extend;
                        x_etc_revenue_tbl.extend;
                        x_etc_quantity_tbl(x_etc_quantity_tbl.COUNT):=l_etc_quantity;
                        x_etc_raw_cost_tbl(x_etc_raw_cost_tbl.COUNT):=l_etc_raw_cost;
                        x_etc_burdened_cost_tbl(x_etc_burdened_cost_tbl.COUNT):=l_etc_burdened_cost;
                        x_etc_revenue_tbl(x_etc_revenue_tbl.COUNT):=l_etc_revenue;

                        --log1('--txn_currency_code-----' || l_inf_tbl_data_curr_rec.txn_currency_code);
                        l_budget_line_in_out_tbl(bl_count).txn_currency_code := l_inf_tbl_data_curr_rec.txn_currency_code;

                        l_budget_line_in_out_tbl(bl_count).description := l_bdgt_ln_tbl_description;

                        l_delete_flag_tbl.EXTEND(1);
                        l_delete_flag_tbl(bl_count) := l_delete_flag;

                        --log1('----- STAGE 113-------');
                        IF p_version_info_rec.x_plan_in_multi_curr_flag = 'Y' THEN
                            --log1('----- STAGE 114-------');
                            l_budget_line_in_out_tbl(bl_count).projfunc_cost_rate_type      := l_projfunc_cost_rate_type;
                            l_budget_line_in_out_tbl(bl_count).projfunc_cost_rate_date_type := l_projfunc_cost_rate_date_type;
                            l_budget_line_in_out_tbl(bl_count).projfunc_cost_rate_date      := l_projfunc_cost_rate_date;
                            l_budget_line_in_out_tbl(bl_count).projfunc_cost_exchange_rate  := l_projfunc_cost_exchange_rate;
                            l_budget_line_in_out_tbl(bl_count).projfunc_rev_rate_type       := l_projfunc_rev_rate_type;
                            l_budget_line_in_out_tbl(bl_count).projfunc_rev_rate_date_type  := l_projfunc_rev_rate_date_type;
                            l_budget_line_in_out_tbl(bl_count).projfunc_rev_rate_date       := l_projfunc_rev_rate_date;
                            l_budget_line_in_out_tbl(bl_count).projfunc_rev_exchange_rate   := l_projfunc_rev_exchange_rate;
                            l_budget_line_in_out_tbl(bl_count).project_cost_rate_type       := l_project_cost_rate_type;
                            l_budget_line_in_out_tbl(bl_count).project_cost_rate_date_type  := l_project_cost_rate_date_type;
                            l_budget_line_in_out_tbl(bl_count).project_cost_rate_date       := l_project_cost_rate_date;
                            l_budget_line_in_out_tbl(bl_count).project_cost_exchange_rate   := l_project_cost_exchange_rate;
                            l_budget_line_in_out_tbl(bl_count).project_rev_rate_type        := l_project_rev_rate_type;
                            l_budget_line_in_out_tbl(bl_count).project_rev_rate_date_type   := l_project_rev_rate_date_type;
                            l_budget_line_in_out_tbl(bl_count).project_rev_rate_date        := l_project_rev_rate_date;
                            l_budget_line_in_out_tbl(bl_count).project_rev_exchange_rate    := l_project_rev_exchange_rate;
                        ELSE
                            l_budget_line_in_out_tbl(bl_count).projfunc_cost_rate_type      := null;
                            l_budget_line_in_out_tbl(bl_count).projfunc_cost_rate_date_type := null;
                            l_budget_line_in_out_tbl(bl_count).projfunc_cost_rate_date      := null;
                            l_budget_line_in_out_tbl(bl_count).projfunc_cost_exchange_rate  := null;
                            l_budget_line_in_out_tbl(bl_count).projfunc_rev_rate_type       := null;
                            l_budget_line_in_out_tbl(bl_count).projfunc_rev_rate_date_type  := null;
                            l_budget_line_in_out_tbl(bl_count).projfunc_rev_rate_date       := null;
                            l_budget_line_in_out_tbl(bl_count).projfunc_rev_exchange_rate   := null;
                            l_budget_line_in_out_tbl(bl_count).project_cost_rate_type       := null;
                            l_budget_line_in_out_tbl(bl_count).project_cost_rate_date_type  := null;
                            l_budget_line_in_out_tbl(bl_count).project_cost_rate_date       := null;
                            l_budget_line_in_out_tbl(bl_count).project_cost_exchange_rate   := null;
                            l_budget_line_in_out_tbl(bl_count).project_rev_rate_type        := null;
                            l_budget_line_in_out_tbl(bl_count).project_rev_rate_date_type   := null;
                            l_budget_line_in_out_tbl(bl_count).project_rev_rate_date        := null;
                            l_budget_line_in_out_tbl(bl_count).project_rev_exchange_rate    := null;
                        END IF;

                        l_budget_line_in_out_tbl(bl_count).change_reason_code := l_change_reason_code;

                        -- populating other parameters to be passed to validate_budget_lines
                        l_rc_rate_tbl.EXTEND(1);
                        l_rc_rate_tbl(bl_count) := l_rc_rate;
                        l_bc_rate_tbl.EXTEND(1);
                        l_bc_rate_tbl(bl_count) := l_bc_rate;
                        l_bill_rate_tbl.EXTEND(1);
                        l_bill_rate_tbl(bl_count) := l_bill_rate;

                        l_plan_start_date_tbl.extend(1);
                        l_plan_start_date_tbl(bl_count) := l_plan_start_date;
                        l_plan_end_date_tbl.extend(1);
                        l_plan_end_date_tbl(bl_count) := l_plan_end_date;

                        -- passing null for all the resource attributes as they are meant to be read-only
                        l_uom_tbl.extend(1);
                        l_uom_tbl(bl_count) := null;
                        l_spread_curve_name_tbl.extend(1);
                        l_spread_curve_name_tbl(bl_count) := null;
                        l_etc_method_code_tbl.extend(1);
                        l_etc_method_code_tbl(bl_count) := null;
                        l_mfc_cost_type_name_tbl.extend(1);
                        l_mfc_cost_type_name_tbl(bl_count) := null;

                        l_sp_fixed_date_tbl.extend(1);
                        l_sp_fixed_date_tbl(bl_count) := l_sp_fixed_date;

                        -- populating the spread curve id obtained in the out table
                        l_spread_curve_id_tbl.EXTEND(1);
                        l_spread_curve_id_tbl(bl_count) := l_spread_curve_id;

                        -- deriving the min and max of the budget line start/end dates
                        IF l_min_ra_plan_start_date IS NULL THEN

                            l_min_ra_plan_start_date := l_min_bdgt_line_start_date;

                        ELSIF l_min_bdgt_line_start_date IS NOT NULL AND
                              l_min_bdgt_line_start_date < l_min_ra_plan_start_date THEN

                            l_min_ra_plan_start_date := l_min_bdgt_line_start_date;

                        END IF;

                        IF l_max_ra_plan_end_date IS NULL THEN

                            l_max_ra_plan_end_date := l_max_bdgt_line_end_date;

                        ELSIF l_max_bdgt_line_end_date IS NOT NULL AND
                              l_max_bdgt_line_end_date > l_max_ra_plan_end_date THEN

                            l_max_ra_plan_end_date := l_max_bdgt_line_end_date;

                        END IF;

                        -- populating other out variables
                        l_ra_id_tbl.EXTEND(1);
                        l_ra_id_tbl(bl_count) := l_ra_id;
                        l_res_class_code_tbl.EXTEND(1);
                        l_res_class_code_tbl(bl_count) := l_res_class_code;
                        l_rate_based_flag_tbl.EXTEND(1);
                        l_rate_based_flag_tbl(bl_count) := l_rate_based_flag;
                        l_rbs_elem_id_tbl.EXTEND(1);
                        l_rbs_elem_id_tbl(bl_count) := l_rbs_elem_id;

                        l_amount_type_tbl.EXTEND(1);
                        l_amount_type_tbl(bl_count) := l_inf_tbl_data_curr_rec.amount_type_code;

                        -- incrementing the bl_count
                        bl_count := bl_count + 1;

                     END IF;

                     --log1('----- STAGE 107-------');

               END IF; -- for a distinct current record

               --log1('----- STAGE 115-------');
            EXCEPTION -- inside the loop to catch skip_ra_exc
                 WHEN Fp_Webadi_Skip_Dup_Rec_Exc THEN
                       -- exception to skip processing of the duplicate records entered
                       IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Fp_Webadi_Skip_Dup_Rec_Exc Raised';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;
                       LOOP
                             l_inf_tbl_data_skip_rec:=NULL;
                             FETCH inf_tbl_data_csr INTO l_inf_tbl_data_skip_rec;
                             EXIT WHEN l_loop_exit_flag = 'Y' OR l_inf_tbl_data_skip_rec.task_id IS NULL;

                             IF l_inf_tbl_data_skip_rec.task_id <> l_inf_tbl_data_next_rec.task_id OR
                                l_inf_tbl_data_skip_rec.resource_list_member_id <> l_inf_tbl_data_next_rec.resource_list_member_id OR
                                Nvl(l_inf_tbl_data_skip_rec.txn_currency_code, '-99') <> Nvl(l_inf_tbl_data_next_rec.txn_currency_code, '-99') OR
                                NVL(l_inf_tbl_data_skip_rec.amount_type_code,'-99') <> NVL(l_inf_tbl_data_next_rec.amount_type_code,'-99') THEN

                                 -- assigning the next distinct planning txn to the next_rec record
                                 l_inf_tbl_data_next_rec := l_inf_tbl_data_skip_rec;
                                 l_loop_exit_flag := 'Y';

                             END IF;
                       END LOOP;
                 WHEN Fp_Webadi_Skip_Rec_Proc_Exc THEN
                       -- exception to skip processing of the record, if any validation
                       -- failure occurs in the current record, so that there would be
                       -- at max one error code populated for any particular record.
                       IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Fp_Webadi_Skip_Rec_Proc_Exc Raised';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;
                       IF l_inf_tbl_data_next_rec.task_id IS NULL THEN
                           FETCH inf_tbl_data_csr INTO l_inf_tbl_data_next_rec;
                       END IF;

                 WHEN Fp_Webadi_Skip_Next_Rec_Exc THEN
                       -- exception to skip processing of the next record, if any validation
                       -- failure occurs in that record, so that there would be
                       -- at max one error code populated for any particular record.
                       IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage := 'Fp_Webadi_Skip_Next_Rec_Exc Raised';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       END IF;
                       l_inf_tbl_data_skip_rec:=NULL;
                       FETCH inf_tbl_data_csr INTO l_inf_tbl_data_skip_rec;
                       l_inf_tbl_data_next_rec := l_inf_tbl_data_skip_rec;


                       /* Do nothing just skip the current record and proceed with the next one */
            END; -- end of the processing block inside the loop

            -- making the next_rec as the current_rec
            l_inf_tbl_data_prev_rec := l_inf_tbl_data_curr_rec;
            l_inf_tbl_data_curr_rec := l_inf_tbl_data_next_rec;
            l_inf_tbl_data_next_rec := NULL;

            x_num_of_rec_processed := x_num_of_rec_processed + 1;
      END LOOP; -- end of main loop

      CLOSE inf_tbl_data_csr;

      --log1('----- STAGE 115-------'||l_err_val_code_tbl.COUNT);

      --  calling process_errors
      IF l_err_val_code_tbl.COUNT > 0 THEN
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Error Code Exists.Calling process_errors';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           process_errors ( p_run_id          => p_run_id,
                            p_periodic_flag   => is_periodic_setup,
                            p_error_code_tbl  => l_err_val_code_tbl,
                            p_task_id_tbl     => l_err_task_id_tbl,
                            p_rlm_id_tbl      => l_err_rlm_id_tbl,
                            p_txn_curr_tbl    => l_err_txn_curr_tbl,
                            p_amount_type_tbl => l_err_amt_type_tbl,
                            p_request_id      => p_request_id,
                            x_return_status   => l_return_status,
                            x_msg_data        => l_msg_data,
                            x_msg_count       => l_msg_count);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Call to process_errors returned with error';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                    END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;
      END IF;

      --log1('----- STAGE 116-------'||l_err_val_code_tbl.COUNT);

/*      FOR zz IN 1..l_budget_line_in_out_tbl.COUNT LOOP

          log1('-l_budget_line_in_out_tbl('||zz||').pa_task_id- ' || l_budget_line_in_out_tbl(zz).pa_task_id);
          log1('-l_budget_line_in_out_tbl('||zz||').resource_list_member_id- ' || l_budget_line_in_out_tbl(zz).resource_list_member_id);
          log1('-l_budget_line_in_out_tbl('||zz||').txn_currency_code- ' || l_budget_line_in_out_tbl(zz).txn_currency_code);
          log1('-l_budget_line_in_out_tbl('||zz||').quantity- ' || l_budget_line_in_out_tbl(zz).quantity);
          log1('-l_budget_line_in_out_tbl('||zz||').raw_cost- ' || l_budget_line_in_out_tbl(zz).raw_cost);
          log1('-l_budget_line_in_out_tbl('||zz||').burdened_cost- ' || l_budget_line_in_out_tbl(zz).burdened_cost);
          log1('-l_budget_line_in_out_tbl('||zz||').revenue- ' || l_budget_line_in_out_tbl(zz).revenue);

      END LOOP;*/

      -- populating the out variables
      x_budget_lines             := l_budget_line_in_out_tbl;
      x_raw_cost_rate_tbl        := l_rc_rate_tbl;
      x_burd_cost_rate_tbl       := l_bc_rate_tbl;
      x_bill_rate_tbl            := l_bill_rate_tbl;
      x_planning_start_date_tbl  := l_plan_start_date_tbl;
      x_planning_end_date_tbl    := l_plan_end_date_tbl;
      x_uom_tbl                  := l_uom_tbl;
      x_mfc_cost_type_tbl        := l_mfc_cost_type_name_tbl;
      x_spread_curve_name_tbl    := l_spread_curve_name_tbl;
      x_sp_fixed_date_tbl        := l_sp_fixed_date_tbl;
      x_etc_method_name_tbl      := l_etc_method_code_tbl;
      x_delete_flag_tbl          := l_delete_flag_tbl;
      -- additional parameter to validate_budget_lines
      x_spread_curve_id_tbl      := l_spread_curve_id_tbl;

      x_ra_id_tbl := l_ra_id_tbl;
      x_res_class_code_tbl := l_res_class_code_tbl;
      x_rate_based_flag_tbl := l_rate_based_flag_tbl;
      x_rbs_elem_id_tbl := l_rbs_elem_id_tbl;
      x_amt_type_tbl := l_amount_type_tbl;

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Leaving pa_fp_webadi_pkg.prepare_val_input';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      pa_debug.reset_curr_function;

      --log1('----- Leaving prepare_val_input-------');

EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count = 1 and x_msg_data IS NULL THEN
               PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
              x_msg_count := l_msg_count;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;

          pa_debug.reset_curr_function;

          RETURN;

     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                                  ,p_procedure_name  => 'prepare_val_input');
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;

          pa_debug.reset_curr_function;

          RAISE;

END prepare_val_input;

--This is a private function used by prepare_pbl_input. This function expects p_rec, record in pa_fp_webadi_upload_inf
--and p_prd that indicates the period in p_rec from which the amount should be returned.
--valid values for prd are ('SD,'PD', '1'..'52')

FUNCTION get_amount_in_prd_x
(p_rec      IN  inf_tbl_data_csr%ROWTYPE,
 p_prd      IN  VARCHAR2
)
RETURN NUMBER
IS
-- variables used for debugging
l_module_name               VARCHAR2(100) := 'pa_fp_webadi_pkg.get_amount_in_prd_x';
l_debug_mode                VARCHAR2(1) := 'N';
l_amount                    NUMBER;
BEGIN
    fnd_profile.get('PA_DEBUG_MODE', l_debug_mode);


    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Entering into get_amount_in_prd_x';
          pa_debug.write(l_module_name, pa_debug.g_err_stage, 3);
          pa_debug.g_err_stage := 'Validating input parameters';
          pa_debug.write(l_module_name, pa_debug.g_err_stage, 3);
    END IF;

    IF l_debug_mode = 'Y' THEN
          pa_debug.Set_Curr_Function
                      (p_function   => l_module_name,
                       p_debug_mode => l_debug_mode);
    END IF;

    IF p_prd IS NULL THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage := 'p_rec is null';
            pa_debug.write(l_module_name, pa_debug.g_err_stage, 3);
            pa_debug.g_err_stage := 'p_prd is null';
            pa_debug.write(l_module_name, pa_debug.g_err_stage, 3);
            pa_debug.reset_curr_function;

        END IF;
        RETURN NULL;

    END IF;

    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'p_prd is '||p_prd;
          pa_debug.write(l_module_name, pa_debug.g_err_stage, 3);
    END IF;

    IF p_prd ='PD' THEN
       l_amount := p_rec.pd_prd;
    ELSIF p_prd ='SD' THEN
        l_amount := p_rec.sd_prd;
    ELSIF p_prd ='1' THEN
        l_amount := p_rec.prd1;
    ELSIF p_prd ='2' THEN
        l_amount := p_rec.prd2;
    ELSIF p_prd ='3' THEN
        l_amount := p_rec.prd3;
    ELSIF p_prd ='4' THEN
        l_amount := p_rec.prd4;
    ELSIF p_prd ='5' THEN
        l_amount := p_rec.prd5;
    ELSIF p_prd ='6' THEN
        l_amount := p_rec.prd6;
    ELSIF p_prd ='7' THEN
        l_amount := p_rec.prd7;
    ELSIF p_prd ='8' THEN
        l_amount := p_rec.prd8;
    ELSIF p_prd ='9' THEN
        l_amount := p_rec.prd9;
    ELSIF p_prd ='10' THEN
        l_amount := p_rec.prd10;
    ELSIF p_prd ='11' THEN
        l_amount := p_rec.prd11;
    ELSIF p_prd ='12' THEN
        l_amount := p_rec.prd12;
    ELSIF p_prd ='13' THEN
        l_amount := p_rec.prd13;
    ELSIF p_prd ='14' THEN
        l_amount := p_rec.prd14;
    ELSIF p_prd ='15' THEN
        l_amount := p_rec.prd15;
    ELSIF p_prd ='16' THEN
        l_amount := p_rec.prd16;
    ELSIF p_prd ='17' THEN
        l_amount := p_rec.prd17;
    ELSIF p_prd ='18' THEN
        l_amount := p_rec.prd18;
    ELSIF p_prd ='19' THEN
        l_amount := p_rec.prd19;
    ELSIF p_prd ='20' THEN
        l_amount := p_rec.prd20;
    ELSIF p_prd ='21' THEN
        l_amount := p_rec.prd21;
    ELSIF p_prd ='22' THEN
        l_amount := p_rec.prd22;
    ELSIF p_prd ='23' THEN
        l_amount := p_rec.prd23;
    ELSIF p_prd ='24' THEN
        l_amount := p_rec.prd24;
    ELSIF p_prd ='25' THEN
        l_amount := p_rec.prd25;
    ELSIF p_prd ='26' THEN
        l_amount := p_rec.prd26;
    ELSIF p_prd ='27' THEN
        l_amount := p_rec.prd27;
    ELSIF p_prd ='28' THEN
        l_amount := p_rec.prd28;
    ELSIF p_prd ='29' THEN
        l_amount := p_rec.prd29;
    ELSIF p_prd ='30' THEN
        l_amount := p_rec.prd30;
    ELSIF p_prd ='31' THEN
        l_amount := p_rec.prd31;
    ELSIF p_prd ='32' THEN
        l_amount := p_rec.prd32;
    ELSIF p_prd ='33' THEN
        l_amount := p_rec.prd33;
    ELSIF p_prd ='34' THEN
        l_amount := p_rec.prd34;
    ELSIF p_prd ='35' THEN
        l_amount := p_rec.prd35;
    ELSIF p_prd ='36' THEN
        l_amount := p_rec.prd36;
    ELSIF p_prd ='37' THEN
        l_amount := p_rec.prd37;
    ELSIF p_prd ='38' THEN
        l_amount := p_rec.prd38;
    ELSIF p_prd ='39' THEN
        l_amount := p_rec.prd39;
    ELSIF p_prd ='40' THEN
        l_amount := p_rec.prd40;
    ELSIF p_prd ='41' THEN
        l_amount := p_rec.prd41;
    ELSIF p_prd ='42' THEN
        l_amount := p_rec.prd42;
    ELSIF p_prd ='43' THEN
        l_amount := p_rec.prd43;
    ELSIF p_prd ='44' THEN
        l_amount := p_rec.prd44;
    ELSIF p_prd ='45' THEN
        l_amount := p_rec.prd45;
    ELSIF p_prd ='46' THEN
        l_amount := p_rec.prd46;
    ELSIF p_prd ='47' THEN
        l_amount := p_rec.prd47;
    ELSIF p_prd ='48' THEN
        l_amount := p_rec.prd48;
    ELSIF p_prd ='49' THEN
        l_amount := p_rec.prd49;
    ELSIF p_prd ='50' THEN
        l_amount := p_rec.prd50;
    ELSIF p_prd ='51' THEN
        l_amount := p_rec.prd51;
    ELSIF p_prd ='52' THEN
        l_amount := p_rec.prd52;
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.reset_curr_function;
    END IF;

    RETURN l_amount;

EXCEPTION
    WHEN OTHERS THEN

        FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                              ,p_procedure_name  => 'get_amount_in_prd_x');
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;

        IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
        END IF;
        RAISE;
END get_amount_in_prd_x;

--This API is internally called from prepare_pbl_input
PROCEDURE get_total_fcst_amounts
(p_project_id                 IN      pa_projects_all.project_id%TYPE,
 p_budget_version_id          IN      pa_budget_versions.budget_version_id%TYPE,
 p_task_id                    IN      pa_tasks.task_id%TYPE,
 p_resource_list_member_id    IN      pa_resource_list_members.resource_list_member_id%TYPE,
 p_txn_currency_code          IN      pa_budget_lines.txn_currency_code%TYPE,
 p_line_start_date            IN      DATE,
 p_line_end_date              IN      DATE,
 p_prd_mask_st_date_tbl       IN      SYSTEM.pa_date_tbl_type,
 p_prd_mask_end_date_tbl      IN      SYSTEM.pa_date_tbl_type,
 p_st_index_in_prd_mask       IN      NUMBER,
 p_end_index_in_prd_mask      IN      NUMBER,
 p_etc_start_date             IN      DATE,
 p_etc_quantity               IN      NUMBER,
 p_fcst_quantity              IN      NUMBER,
 p_etc_raw_cost               IN      NUMBER,
 p_fcst_raw_cost              IN      NUMBER,
 p_etc_burd_cost              IN      NUMBER,
 p_fcst_burd_cost             IN      NUMBER,
 p_etc_revenue                IN      NUMBER,
 p_fcst_revenue               IN      NUMBER,
 px_cached_fcst_qty_tbl       IN  OUT NOCOPY varchar_70_indexed_num_tbl_typ, --File.Sql.39 bug 4440895
 px_cached_fcst_raw_cost_tbl  IN  OUT NOCOPY varchar_70_indexed_num_tbl_typ, --File.Sql.39 bug 4440895
 px_cached_fcst_burd_cost_tbl IN  OUT NOCOPY varchar_70_indexed_num_tbl_typ, --File.Sql.39 bug 4440895
 px_cached_fcst_revenue_tbl   IN  OUT NOCOPY varchar_70_indexed_num_tbl_typ, --File.Sql.39 bug 4440895
 px_cached_etc_qty_tbl        IN  OUT NOCOPY varchar_70_indexed_num_tbl_typ, --File.Sql.39 bug 4440895
 px_cached_etc_raw_cost_tbl   IN  OUT NOCOPY varchar_70_indexed_num_tbl_typ, --File.Sql.39 bug 4440895
 px_cached_etc_burd_cost_tbl  IN  OUT NOCOPY varchar_70_indexed_num_tbl_typ, --File.Sql.39 bug 4440895
 px_cached_etc_revenue_tbl    IN  OUT NOCOPY varchar_70_indexed_num_tbl_typ, --File.Sql.39 bug 4440895
 x_total_quantity                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_total_raw_cost                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_total_burd_cost                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_total_revenue                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status                  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
 IS
--Start of variables used for debugging
l_return_status                       VARCHAR2(1);
l_msg_count                           NUMBER := 0;
l_msg_data                            VARCHAR2(2000);
l_data                                VARCHAR2(2000);
l_msg_index_out                       NUMBER;
l_debug_mode                          VARCHAR2(30);
l_module_name                         VARCHAR2(100):='PAFPWAPB.get_total_fcst_amounts';

--End of variables used for debugging
l_varchar_index                       VARCHAR2(50);
l_amt_typs_to_be_populated_tbl        pa_plsql_datatypes.char30TabTyp;
l_amt_typ_index                       NUMBER;
l_amt_exists_flag                     VARCHAR2(1);
l_existing_fcst_amount                NUMBER;
l_existing_etc_amount                 NUMBER;
l_entered_fcst_amount                 NUMBER;
l_entered_etc_amount                  NUMBER;
l_total_amount                        NUMBER;
l_index                               NUMBER;
l_fcst_qty_tbl                        pa_plsql_datatypes.numTabTyp;
l_etc_qty_tbl                         pa_plsql_datatypes.numTabTyp;
l_fcst_raw_cost_tbl                   pa_plsql_datatypes.numTabTyp;
l_etc_raw_cost_tbl                    pa_plsql_datatypes.numTabTyp;
l_fcst_burd_cost_tbl                  pa_plsql_datatypes.numTabTyp;
l_etc_burd_cost_tbl                   pa_plsql_datatypes.numTabTyp;
l_fcst_revenue_tbl                    pa_plsql_datatypes.numTabTyp;
l_etc_revenue_tbl                     pa_plsql_datatypes.numTabTyp;
l_txn_currency_code_tbl               pa_plsql_datatypes.char15TabTyp;
l_start_date_tbl                      pa_plsql_datatypes.dateTabTyp;
l_end_date_tbl                        pa_plsql_datatypes.dateTabTyp;
BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
    IF l_debug_mode='Y' THEN

        pa_debug.set_curr_function(
                    p_function   =>'PAFPWAPB.get_total_fcst_amounts'
                   ,p_debug_mode => l_debug_mode );
    END IF;

    IF p_task_id                  IS NULL OR
       p_resource_list_member_id  IS NULL OR
       p_txn_currency_code        IS NULL THEN

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:='p_task_id is'|| p_task_id;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_resource_list_member_id is'|| p_resource_list_member_id ;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_txn_currency_code is'|| p_txn_currency_code;
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);


        END IF;

                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                        p_token1         => 'PROCEDURENAME',
                                        p_value1         => 'PAFPWAPB.get_total_fcst_amount',
                                        p_token2         => 'STAGE',
                                        p_value2         => '[Task, Rlm,Txn]'||'['||p_task_id||','||p_resource_list_member_id||','||p_txn_currency_code||']');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF p_line_start_date IS NOT NULL THEN

        IF p_line_end_date IS NULL OR
           p_prd_mask_st_date_tbl.COUNT <> p_prd_mask_end_date_tbl.COUNT OR
           p_st_index_in_prd_mask IS NULL OR
           p_end_index_in_prd_mask IS NULL THEN

           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                p_token1         => 'PROCEDURENAME',
                                p_value1         => 'PAFPWAPB.get_total_fcst_amount',
                                p_token2         => 'STAGE',
                                p_value2         => 'Invalid Budget Level parameters');

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

    END IF;

    l_amt_typ_index:=0;
    IF p_etc_quantity  IS NULL AND
       p_fcst_quantity IS NULL THEN

        x_total_quantity := NULL;

    ELSIF p_etc_quantity  IS NULL AND
          p_fcst_quantity IS NOT NULL THEN

        x_total_quantity := p_fcst_quantity;

    ELSE
        l_amt_typ_index:=l_amt_typ_index+1;
        l_amt_typs_to_be_populated_tbl(l_amt_typ_index):='QUANTITY';
    END IF;

    IF p_etc_raw_cost  IS NULL AND
       p_fcst_raw_cost IS NULL THEN

        x_total_raw_cost := NULL;

    ELSIF p_etc_raw_cost  IS NULL AND
          p_fcst_raw_cost IS NOT NULL THEN

        x_total_raw_cost := p_fcst_raw_cost;

    ELSE
        l_amt_typ_index:=l_amt_typ_index+1;
        l_amt_typs_to_be_populated_tbl(l_amt_typ_index):='RAW_COST';
    END IF;


    IF  p_etc_burd_cost  IS NULL AND
        p_fcst_burd_cost IS NULL THEN

        x_total_burd_cost := NULL;

    ELSIF p_etc_burd_cost IS NULL AND
          p_fcst_burd_cost IS NOT NULL THEN

        x_total_burd_cost := p_fcst_burd_cost;

    ELSE

        l_amt_typ_index:=l_amt_typ_index+1;
        l_amt_typs_to_be_populated_tbl(l_amt_typ_index):='BURDENED_COST';

    END IF;


    IF p_etc_revenue  IS NULL AND
       p_fcst_revenue IS NULL THEN

        x_total_revenue := NULL;

    ELSIF p_etc_revenue  IS NULL AND
          p_fcst_revenue IS NOT NULL THEN

        x_total_revenue := p_fcst_revenue;

    ELSE
        l_amt_typ_index:=l_amt_typ_index+1;
        l_amt_typs_to_be_populated_tbl(l_amt_typ_index):='REVENUE';
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='l_amt_typs_to_be_populated_tbl.COUNT '||l_amt_typs_to_be_populated_tbl.COUNT;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF l_amt_typs_to_be_populated_tbl.COUNT>0 THEN

        --Check if the details of the planning transactions for this resource assignment are already fetched or not.
        --If the details are already fetched then the RA index of px_cached_fcst_qty_tbl will contain the no. of
        --planning transactions/periodic lines for the RA.
        l_varchar_index:= 'T' || TO_CHAR(p_task_id) || 'R' || TO_CHAR(p_resource_list_member_id) ;
        IF NOT px_cached_fcst_qty_tbl.EXISTS(l_varchar_index) THEN

            IF p_line_start_date IS NULL THEN

                SELECT SUM(NVL(pbl.quantity,0)),
                       SUM(NVL(pbl.quantity,0)-NVL(pbl.init_quantity,0)),
                       SUM(NVL(pbl.txn_raw_cost,0)),
                       SUM(NVL(pbl.txn_raw_cost,0)-NVL(pbl.txn_init_raw_cost,0)),
                       SUM(NVL(pbl.txn_burdened_cost,0)),
                       SUM(NVL(pbl.txn_burdened_cost,0)-NVL(pbl.txn_init_burdened_cost,0)),
                       SUM(NVL(pbl.txn_revenue,0)),
                       SUM(NVL(pbl.txn_revenue,0)-NVL(txn_init_revenue,0)),
                       pbl.txn_currency_code
                BULK COLLECT INTO
                       l_fcst_qty_tbl,
                       l_etc_qty_tbl,
                       l_fcst_raw_cost_tbl,
                       l_etc_raw_cost_tbl,
                       l_fcst_burd_cost_tbl,
                       l_etc_burd_cost_tbl,
                       l_fcst_revenue_tbl,
                       l_etc_revenue_tbl,
                       l_txn_currency_code_tbl
                FROM   pa_budget_lines pbl,
                       pa_resource_assignments pra
                WHERE  pra.budget_version_id=p_budget_version_id
                AND    pra.project_id=p_project_id
                AND    pra.task_id=p_task_id
                AND    pra.resource_list_member_id=p_resource_list_member_id
                AND    pra.project_assignment_id=-1
                AND    pbl.resource_assignment_id=pra.resource_assignment_id
                GROUP BY pbl.txn_currency_code;

                FOR i IN 1..l_txn_currency_code_tbl.COUNT LOOP

                    l_varchar_index:= 'T' || TO_CHAR(p_task_id) || 'R' || TO_CHAR(p_resource_list_member_id) || 'C' || l_txn_currency_code_tbl(i);

                    px_cached_fcst_qty_tbl(l_varchar_index)       := l_fcst_qty_tbl(i);
                    px_cached_etc_qty_tbl(l_varchar_index)        := l_etc_qty_tbl(i);
                    px_cached_fcst_raw_cost_tbl(l_varchar_index)  := l_fcst_raw_cost_tbl(i);
                    px_cached_etc_raw_cost_tbl(l_varchar_index)   := l_etc_raw_cost_tbl(i);
                    px_cached_fcst_burd_cost_tbl(l_varchar_index) := l_fcst_burd_cost_tbl(i);
                    px_cached_etc_burd_cost_tbl(l_varchar_index)  := l_etc_burd_cost_tbl(i);
                    px_cached_fcst_revenue_tbl(l_varchar_index)   := l_fcst_revenue_tbl(i);
                    px_cached_etc_revenue_tbl(l_varchar_index)    := l_etc_revenue_tbl(i);

                END LOOP;

                l_varchar_index:= 'T' || TO_CHAR(p_task_id) || 'R' || TO_CHAR(p_resource_list_member_id) ;
                px_cached_fcst_qty_tbl(l_varchar_index):=l_txn_currency_code_tbl.COUNT;

            ELSE--The layout is a periodic layout

                SELECT NVL(pbl.quantity,0),
                       NVL(pbl.quantity,0)-NVL(pbl.init_quantity,0),
                       NVL(pbl.txn_raw_cost,0),
                       NVL(pbl.txn_raw_cost,0)-NVL(pbl.txn_init_raw_cost,0),
                       NVL(pbl.txn_burdened_cost,0),
                       NVL(pbl.txn_burdened_cost,0)-NVL(pbl.txn_init_burdened_cost,0),
                       NVL(pbl.txn_revenue,0),
                       NVL(pbl.txn_revenue,0)-NVL(txn_init_revenue,0),
                       pbl.txn_currency_code,
                       pbl.start_date,
                       pbl.end_date
                BULK COLLECT INTO
                       l_fcst_qty_tbl,
                       l_etc_qty_tbl,
                       l_fcst_raw_cost_tbl,
                       l_etc_raw_cost_tbl,
                       l_fcst_burd_cost_tbl,
                       l_etc_burd_cost_tbl,
                       l_fcst_revenue_tbl,
                       l_etc_revenue_tbl,
                       l_txn_currency_code_tbl,
                       l_start_date_tbl,
                       l_end_date_tbl
                FROM   pa_budget_lines pbl,
                       pa_resource_assignments pra
                WHERE  pra.budget_version_id=p_budget_version_id
                AND    pra.project_id=p_project_id
                AND    pra.task_id=p_task_id
                AND    pra.resource_list_member_id=p_resource_list_member_id
                AND    pra.project_assignment_id=-1
                AND    pbl.resource_assignment_id=pra.resource_assignment_id
                ORDER BY pbl.start_date,pbl.end_date,pbl.txn_currency_code;


                l_index:=1;
                FOR i IN p_st_index_in_prd_mask..p_end_index_in_prd_mask LOOP

                    IF l_start_date_tbl.COUNT < l_index THEN

                        EXIT;

                    END IF;

                    LOOP

                        EXIT WHEN l_start_date_tbl.COUNT < l_index OR
                                  l_start_date_tbl(l_index) NOT BETWEEN p_prd_mask_st_date_tbl(i) AND p_prd_mask_end_date_tbL(i);

                        l_varchar_index:=  'T' || TO_CHAR(p_task_id) || 'R' || TO_CHAR(p_resource_list_member_id)
                                         ||'C' || l_txn_currency_code_tbl(l_index)
                                         ||'S' || TO_CHAR(p_prd_mask_st_date_tbl(i),'DD-MM-YYYY')
                                         ||'E' || TO_CHAR(p_prd_mask_end_date_tbl(i),'DD-MM-YYYY');

                        IF NOT px_cached_fcst_qty_tbl.EXISTS(l_varchar_index) THEN

                            px_cached_fcst_qty_tbl(l_varchar_index)       := l_fcst_qty_tbl(l_index);
                            px_cached_etc_qty_tbl(l_varchar_index)        := l_etc_qty_tbl(l_index);
                            px_cached_fcst_raw_cost_tbl(l_varchar_index)  := l_fcst_raw_cost_tbl(l_index);
                            px_cached_etc_raw_cost_tbl(l_varchar_index)   := l_etc_raw_cost_tbl(l_index);
                            px_cached_fcst_burd_cost_tbl(l_varchar_index) := l_fcst_burd_cost_tbl(l_index);
                            px_cached_etc_burd_cost_tbl(l_varchar_index)  := l_etc_burd_cost_tbl(l_index);
                            px_cached_fcst_revenue_tbl(l_varchar_index)   := l_fcst_revenue_tbl(l_index);
                            px_cached_etc_revenue_tbl(l_varchar_index)    := l_etc_revenue_tbl(l_index);

                        ELSE

                            px_cached_fcst_qty_tbl(l_varchar_index)       := px_cached_fcst_qty_tbl(l_varchar_index) + l_fcst_qty_tbl(l_index);
                            px_cached_etc_qty_tbl(l_varchar_index)        := px_cached_etc_qty_tbl(l_varchar_index) + l_etc_qty_tbl(l_index);
                            px_cached_fcst_raw_cost_tbl(l_varchar_index)  := px_cached_fcst_raw_cost_tbl(l_varchar_index)+l_fcst_raw_cost_tbl(l_index);
                            px_cached_etc_raw_cost_tbl(l_varchar_index)   := px_cached_etc_raw_cost_tbl(l_varchar_index)+l_etc_raw_cost_tbl(l_index);
                            px_cached_fcst_burd_cost_tbl(l_varchar_index) := px_cached_fcst_burd_cost_tbl(l_varchar_index)+l_fcst_burd_cost_tbl(l_index);
                            px_cached_etc_burd_cost_tbl(l_varchar_index)  := px_cached_etc_burd_cost_tbl(l_varchar_index)+l_etc_burd_cost_tbl(l_index);
                            px_cached_fcst_revenue_tbl(l_varchar_index)   := px_cached_fcst_revenue_tbl(l_varchar_index)+l_fcst_revenue_tbl(l_index);
                            px_cached_etc_revenue_tbl(l_varchar_index)    := px_cached_etc_revenue_tbl(l_varchar_index)+l_etc_revenue_tbl(l_index);

                        END IF;

                        l_index:=l_index+1;

                    END LOOP;--For the budget lines


                END LOOP;--FOR i IN p_st_index_in_prd_mask..p_end_index_in_prd_mask LOOP

                l_varchar_index:= 'T' || TO_CHAR(p_task_id) || 'R' || TO_CHAR(p_resource_list_member_id) ;
                px_cached_fcst_qty_tbl(l_varchar_index):=px_cached_fcst_qty_tbl.COUNT;


            END IF;----The layout is a periodic layout


        END IF;--IF NOT px_cached_fcst_qty_tbl.EXISTS(l_varchar_index) THEN

        IF p_line_start_date IS NULL THEN
            l_varchar_index:= 'T' || TO_CHAR(p_task_id) || 'R' || TO_CHAR(p_resource_list_member_id) || 'C' || p_txn_currency_code;
        ELSE
            l_varchar_index:=  'T' || TO_CHAR(p_task_id) || 'R' || TO_CHAR(p_resource_list_member_id)
                             ||'C' || p_txn_currency_code
                             ||'S' || TO_CHAR(p_line_start_date,'DD-MM-YYYY')
                             ||'E' || TO_CHAR(p_line_end_date,'DD-MM-YYYY');
        END IF;
        --log1('1 l_varchar_index '||l_varchar_index);
        --log1('2 p_fcst_quantity '||p_fcst_quantity);
        --log1('3 p_etc_quantity '||p_etc_quantity);
        --log1('4 p_line_start_date '||p_line_start_date);
        --log1('5 p_line_end_date '||p_line_end_date);

        FOR i IN 1..l_amt_typs_to_be_populated_tbl.COUNT LOOP

            l_entered_fcst_amount:=NULL;
            l_entered_etc_amount:=NULL;
            l_existing_fcst_amount:=NULL;
            l_existing_etc_amount:=NULL;
            l_amt_exists_flag:='N';
            l_total_amount:=NULL;

            IF l_amt_typs_to_be_populated_tbl(i)='QUANTITY' THEN

                l_entered_fcst_amount:=p_fcst_quantity;
                l_entered_etc_amount :=p_etc_quantity;

                --Budget lines for the planning transaction do not exist
                IF NOT px_cached_fcst_qty_tbl.EXISTS(l_varchar_index) THEN

                    l_amt_exists_flag:='N';

                ELSE

                    l_amt_exists_flag:='Y';
                    l_existing_fcst_amount:=px_cached_fcst_qty_tbl(l_varchar_index);
                    l_existing_etc_amount:=px_cached_etc_qty_tbl(l_varchar_index);

                END IF;

            ELSIF l_amt_typs_to_be_populated_tbl(i)='RAW_COST' THEN

                l_entered_fcst_amount:=p_fcst_raw_cost;
                l_entered_etc_amount :=p_etc_raw_cost;

                --Budget lines for the planning transaction do not exist
                IF NOT px_cached_fcst_qty_tbl.EXISTS(l_varchar_index) THEN

                    l_amt_exists_flag:='N';

                ELSE

                    l_amt_exists_flag:='Y';
                    l_existing_fcst_amount:=px_cached_fcst_raw_cost_tbl(l_varchar_index);
                    l_existing_etc_amount:=px_cached_etc_raw_cost_tbl(l_varchar_index);

                END IF;

            ELSIF l_amt_typs_to_be_populated_tbl(i)='BURDENED_COST' THEN

                l_entered_fcst_amount:=p_fcst_burd_cost;
                l_entered_etc_amount :=p_etc_burd_cost;

                --Budget lines for the planning transaction do not exist
                IF NOT px_cached_fcst_qty_tbl.EXISTS(l_varchar_index) THEN

                    l_amt_exists_flag:='N';

                ELSE

                    l_amt_exists_flag:='Y';
                    l_existing_fcst_amount:=px_cached_fcst_burd_cost_tbl(l_varchar_index);
                    l_existing_etc_amount:=px_cached_etc_burd_cost_tbl(l_varchar_index);

                END IF;

            ELSIF l_amt_typs_to_be_populated_tbl(i)='REVENUE' THEN

                l_entered_fcst_amount:=p_fcst_revenue;
                l_entered_etc_amount :=p_etc_revenue;

                --Budget lines for the planning transaction do not exist
                IF NOT px_cached_fcst_qty_tbl.EXISTS(l_varchar_index) THEN

                    l_amt_exists_flag:='N';

                ELSE

                    l_amt_exists_flag:='Y';
                    l_existing_fcst_amount:=px_cached_fcst_revenue_tbl(l_varchar_index);
                    l_existing_etc_amount:=px_cached_etc_revenue_tbl(l_varchar_index);

                END IF;

            END IF;
            --log1('6 l_amt_exists_flag '||l_amt_exists_flag);
            --log1('7 l_entered_fcst_amount '||l_entered_fcst_amount);
            --log1('8 l_entered_etc_amount '||l_entered_etc_amount);

            IF l_amt_exists_flag='N' THEN

                --IF forecast is not g miss num then it should be considered. Note that g miss num
                --will be there if NULL is entered in the layout.
                IF l_entered_fcst_amount IS NOT NULL  AND
                   l_entered_fcst_amount <> l_fnd_miss_num THEN

                    l_total_amount:=l_entered_fcst_amount;

                --IF ETC is not g miss num then it should be considered. Note that g miss num
                --will be there if NULL is entered in the layout.
                ELSIF l_entered_etc_amount IS NOT NULL  AND
                      l_entered_etc_amount <> l_fnd_miss_num THEN

                    l_total_amount:=l_entered_etc_amount;

                ELSE

                    l_total_amount:=NULL;

                END IF;

            --Budget lines for the planning transaction  exist
            ELSE

                IF l_existing_fcst_amount IS NULL AND
                   l_entered_fcst_amount  IS NOT NULL AND
                   l_entered_fcst_amount <> l_fnd_miss_num  THEN

                    l_total_amount:=l_entered_fcst_amount;

                ELSIF l_existing_fcst_amount IS NOT NULL AND
                      l_entered_fcst_amount  IS NOT NULL AND
                      l_entered_fcst_amount <> l_existing_fcst_amount  THEN

                    l_total_amount:=l_entered_fcst_amount;

                ELSIF l_existing_etc_amount IS NULL AND
                      l_entered_etc_amount IS NOT NULL AND
                      l_entered_etc_amount <> l_fnd_miss_num  THEN

                    l_total_amount:=l_entered_etc_amount + NVL(l_existing_fcst_amount,0) - NVL(l_existing_etc_amount,0);

                ELSIF l_existing_etc_amount IS NOT NULL AND
                      l_entered_etc_amount IS NOT NULL AND
                      l_entered_etc_amount <> l_existing_etc_amount  THEN

                    l_total_amount:=l_entered_etc_amount + NVL(l_existing_fcst_amount,0) - NVL(l_existing_etc_amount,0);

                ELSE

                    l_total_amount:=NULL;

                END IF;

            END IF;--IF l_amt_exists_flag='N' THEN

            --Assign the above derived total amount to the appropriate OUT variable
            IF l_amt_typs_to_be_populated_tbl(i)='QUANTITY' THEN

                x_total_quantity:=l_total_amount;

            ELSIF l_amt_typs_to_be_populated_tbl(i)='RAW_COST' THEN

                x_total_raw_cost:=l_total_amount;

            ELSIF l_amt_typs_to_be_populated_tbl(i)='BURDENED_COST' THEN

                x_total_burd_cost:=l_total_amount;

            ELSIF l_amt_typs_to_be_populated_tbl(i)='REVENUE' THEN

                x_total_revenue:=l_total_amount;

            END IF;

        END LOOP;--FOR i IN 1..l_amt_typs_to_be_populated_tbl.COUNT LOOP

    END IF;--IF l_amt_typs_to_be_populated_tbl.COUNT>0 THEN

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Leaving get_total_fcst_amounts';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        pa_debug.reset_curr_function;
    END IF;

EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);

           x_msg_data := l_data;
           x_msg_count := l_msg_count;
       ELSE
           x_msg_count := l_msg_count;
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
           -- reset curr function
           pa_debug.reset_curr_function();

       END IF;

       RETURN;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_webadi_pkg'
                               ,p_procedure_name  => 'get_total_fcst_amounts');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
          -- reset curr function
           pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;

END get_total_fcst_amounts;

--This is a private API called from Switcher API. This API assumes that the data exists
--in pa_fp_webadi_upload_inf table and this data has been already validated.

--Note: p_budget_lines_tbl contains records ordered by task id, resource alias and curr. This
--API assumes that there exists only one record for an RA/TXN Currency Code in p_budget_lines_tbl

--p_prd_mask_st/end_date_tbl contains the start/end dates of flexible periods in the period mask. If period mask contains
--10 elements then elements between 1 t0 10 will contain start/end dates of the flexible periods in the mask.
--p_first_pd_bf_pm_en_dt contains the end date of the period that immediately preceeds the first period in the period mask
--and it will be used as the end date if the amounts are entered in preceeding bucket
--p_last_pd_af_pm_st_dt contains the start date of the period that immediately succeeds the last period in the period mask
--and it will be used as the start date if the amounts are entered in preceeding bucket

PROCEDURE prepare_pbl_input
(p_context                         IN    VARCHAR2,
 p_run_id                          IN    pa_fp_webadi_upload_inf.run_id%TYPE,
 p_request_id                      IN    pa_budget_versions.request_id%TYPE    DEFAULT  NULL,
 p_inf_tbl_rec_tbl                 IN    inf_cur_tbl_typ,
 p_version_info_rec                IN    pa_fp_gen_amount_utils.fp_cols,
 p_project_id                      IN    pa_projects_all.project_id%TYPE,
 p_budget_version_id               IN    pa_budget_versions.budget_version_id%TYPE,
 p_budget_lines_tbl                IN    PA_BUDGET_PUB.G_budget_lines_in_tbl%TYPE,
 p_ra_id_tbl                       IN    SYSTEM.pa_num_tbl_type,
 p_etc_start_date                  IN    pa_budget_versions.etc_start_date%TYPE,
 p_plan_class_code                 IN    pa_fin_plan_types_b.plan_class_code%TYPE,
 p_first_pd_bf_pm_en_dt            IN    DATE,
 p_last_pd_af_pm_st_dt             IN    DATE,
 p_prd_mask_st_date_tbl            IN    SYSTEM.pa_date_tbl_type,
 p_prd_mask_end_date_tbl           IN    SYSTEM.pa_date_tbl_type,
 p_planning_start_date_tbl         IN    SYSTEM.pa_date_tbl_type,
 p_planning_end_date_tbl           IN    SYSTEM.pa_date_tbl_type,
 p_etc_quantity_tbl                IN    SYSTEM.pa_num_tbl_type,
 p_etc_raw_cost_tbl                IN    SYSTEM.pa_num_tbl_type,
 p_etc_burdened_cost_tbl           IN    SYSTEM.pa_num_tbl_type,
 p_etc_revenue_tbl                 IN    SYSTEM.pa_num_tbl_type,
 p_raw_cost_rate_tbl               IN    SYSTEM.pa_num_tbl_type,
 p_burd_cost_rate_tbl              IN    SYSTEM.pa_num_tbl_type,
 p_bill_rate_tbl                   IN    SYSTEM.pa_num_tbl_type,
 p_spread_curve_id_tbl             IN    SYSTEM.pa_num_tbl_type,
 p_mfc_cost_type_id_tbl            IN    SYSTEM.pa_num_tbl_type,
 p_etc_method_code_tbl             IN    SYSTEM.pa_varchar2_30_tbl_type ,
 p_sp_fixed_date_tbl               IN    SYSTEM.pa_date_tbl_type,
 p_res_class_code_tbl              IN    SYSTEM.pa_varchar2_30_tbl_type ,
 p_rate_based_flag_tbl             IN    SYSTEM.pa_varchar2_1_tbl_type ,
 p_rbs_elem_id_tbl                 IN    SYSTEM.pa_num_tbl_type,
 p_delete_flag_tbl                 IN    SYSTEM.pa_varchar2_1_tbl_type ,
 x_task_id_tbl                     OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_rlm_id_tbl                      OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_ra_id_tbl                       OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_txn_currency_code_tbl           OUT   NOCOPY SYSTEM.pa_varchar2_15_tbl_type , --File.Sql.39 bug 4440895
 x_planning_start_date_tbl         OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_planning_end_date_tbl           OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_total_qty_tbl                   OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_total_raw_cost_tbl              OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_total_burdened_cost_tbl         OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_total_revenue_tbl               OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_raw_cost_rate_tbl               OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_burdened_cost_rate_tbl          OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_bill_rate_tbl                   OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_line_start_date_tbl             OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_line_end_date_tbl               OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_proj_cost_rate_type_tbl         OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_proj_cost_rate_date_type_tbl    OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_proj_cost_rate_tbl              OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_proj_cost_rate_date_tbl         OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_proj_rev_rate_type_tbl          OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_proj_rev_rate_date_type_tbl     OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_proj_rev_rate_tbl               OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_proj_rev_rate_date_tbl          OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_pfunc_cost_rate_type_tbl        OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_pfunc_cost_rate_date_typ_tbl    OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_pfunc_cost_rate_tbl             OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_pfunc_cost_rate_date_tbl        OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_pfunc_rev_rate_type_tbl         OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_pfunc_rev_rate_date_type_tbl    OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_pfunc_rev_rate_tbl              OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_pfunc_rev_rate_date_tbl         OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_delete_flag_tbl                 OUT   NOCOPY SYSTEM.pa_varchar2_1_tbl_type, --File.Sql.39 bug 4440895
 x_spread_curve_id_tbl             OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_mfc_cost_type_id_tbl            OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_etc_method_code_tbl             OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_sp_fixed_date_tbl               OUT   NOCOPY SYSTEM.pa_date_tbl_type, --File.Sql.39 bug 4440895
 x_res_class_code_tbl              OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type , --File.Sql.39 bug 4440895
 x_rate_based_flag_tbl             OUT   NOCOPY SYSTEM.pa_varchar2_1_tbl_type , --File.Sql.39 bug 4440895
 x_rbs_elem_id_tbl                 OUT   NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
 x_change_reason_code_tbl          OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type, --File.Sql.39 bug 4440895
 x_description_tbl                 OUT   NOCOPY SYSTEM.pa_varchar2_2000_tbl_type, --File.Sql.39 bug 4440895
 x_return_status                   OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                       OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
-- variables used for debugging
l_module_name                   VARCHAR2(100) := 'pa_fp_webadi_pkg.prepare_pbl_input';
l_debug_mode                    VARCHAR2(1) := 'N';
l_debug_level3                  CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
l_debug_level5                  CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;

l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_data                          VARCHAR2(2000);
l_msg_index_out                 NUMBER;

--Variable used in processing
l_prev_task_id                  NUMBER;
l_prev_rlm_id                   NUMBER;
l_prev_txn_curr_code            pa_budget_lines.txn_currency_code%TYPE;
l_bl_index                      NUMBER;
l_st_index_in_prd_mask          NUMBER;
l_end_index_in_prd_mask         NUMBER;
l_sd_prd_exists_flag            VARCHAR2(1);
l_pd_prd_exists_flag            VARCHAR2(1);
l_num_of_prds_for_plan_txn      NUMBER;
l_extend_pbl_out_tbls_flag      VARCHAR2(1);
l_prev_pbl_tbl_count            NUMBER;
l_amount                        NUMBER;
l_prd_index                     VARCHAR2(2);
l_tmp_index                     NUMBER;
l_plan_txn_attrs_copied_flag    VARCHAR2(1);

kk                              NUMBER;
l_g_miss_char   CONSTANT        VARCHAR(1)  := FND_API.G_MISS_CHAR;
l_g_miss_num    CONSTANT        NUMBER      := FND_API.G_MISS_NUM;
l_g_miss_date   CONSTANT        DATE        := FND_API.G_MISS_DATE;

l_curr_rec                      inf_tbl_data_csr%ROWTYPE;

l_cached_fcst_qty_tbl           varchar_70_indexed_num_tbl_typ;
l_cached_fcst_raw_cost_tbl      varchar_70_indexed_num_tbl_typ;
l_cached_fcst_burd_cost_tbl     varchar_70_indexed_num_tbl_typ;
l_cached_fcst_revenue_tbl       varchar_70_indexed_num_tbl_typ;
l_cached_etc_qty_tbl            varchar_70_indexed_num_tbl_typ;
l_cached_etc_raw_cost_tbl       varchar_70_indexed_num_tbl_typ;
l_cached_etc_burd_cost_tbl      varchar_70_indexed_num_tbl_typ;
l_cached_etc_revenue_tbl        varchar_70_indexed_num_tbl_typ;
l_tmp_quantity                  NUMBER;
l_tmp_raw_cost                  NUMBER;
l_tmp_burd_cost                 NUMBER;
l_tmp_revenue                   NUMBER;
l_allow_qty_flag                VARCHAR2(1);
l_skip_ra_flag                  VARCHAR2(1);
l_skip_task_id                  pa_resource_assignments.task_id%TYPE;
l_skip_rlm_id                   pa_resource_assignments.resource_list_member_id%TYPE;


--These tbls will be prepared in this manner
----First element is for the proceeding bucket . Next p_prd_mask_st_date_tbl.COUNT buckets will contain
----start/end dates of the periods in the period mask. Last element will be for the succeeding bucket.
l_prd_mask_st_date_tbl          SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_prd_mask_end_date_tbl         SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();

tt                              NUMBER;

BEGIN
    fnd_profile.get('PA_DEBUG_MODE', l_debug_mode);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF l_debug_mode = 'Y' THEN
          pa_debug.Set_Curr_Function
                      (p_function   => l_module_name,
                       p_debug_mode => l_debug_mode);
    END IF;

    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Entering into prepare_pbl_input';
          pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
          pa_debug.g_err_stage := 'Validating input parameters';
          pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
    END IF;


    -- valid p_context are WEBADI_PERIODIC and WEBADI_NON_PERIODIC
    IF p_context IS NULL THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'p_context is passed as null';
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
        END IF;
        pa_utils.add_message(p_app_short_name => 'PA',
                           p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                           p_token1           => 'PROCEDURENAME',
                           p_value1           => l_module_name);

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    --If there are no records to process return
    IF p_budget_lines_tbl.COUNT=0 THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'p_budget_lines_tbl is empty';
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);
           pa_debug.reset_curr_function;
        END IF;
        RETURN;

    END IF;

    --log1('-p_planning_start_date_tbl.COUNT- ' || p_planning_start_date_tbl.COUNT);
    --log1('-p_planning_end_date_tbl.COUNT- ' || p_planning_end_date_tbl.COUNT);
    --log1('-p_budget_lines_tbl.COUNT- ' || p_budget_lines_tbl.COUNT);
    --log1('-p_raw_cost_rate_tbl.COUNT- ' || p_raw_cost_rate_tbl.COUNT);
    --log1('-p_burd_cost_rate_tbl.COUNT- ' || p_burd_cost_rate_tbl.COUNT);
    --log1('-p_bill_rate_tbl.COUNT- ' || p_bill_rate_tbl.COUNT);
    --log1('-p_spread_curve_id_tbl.COUNT- ' || p_spread_curve_id_tbl.COUNT);
    --log1('-p_etc_method_code_tbl.COUNT- ' || p_etc_method_code_tbl.COUNT);
    --log1('-p_sp_fixed_date_tbl.COUNT- ' || p_sp_fixed_date_tbl.COUNT);
    --log1('-p_delete_flag_tbl.COUNT- ' || p_delete_flag_tbl.COUNT);
    --log1('-p_mfc_cost_type_id_tbl.COUNT- ' || p_mfc_cost_type_id_tbl.COUNT);

    --log1('-p_budget_lines_tbl(1).quantity- ' || p_budget_lines_tbl(1).quantity);
    --log1('-p_budget_lines_tbl(1).raw_cost- ' || p_budget_lines_tbl(1).raw_cost);
    --log1('-p_budget_lines_tbl(1).burdened_cost- ' || p_budget_lines_tbl(1).burdened_cost);
    --log1('-p_budget_lines_tbl(1).revenue- ' || p_budget_lines_tbl(1).revenue);

    IF p_planning_start_date_tbl.COUNT <> p_planning_end_date_tbl.COUNT OR
       p_planning_start_date_tbl.COUNT <> p_budget_lines_tbl.COUNT      OR
       p_planning_start_date_tbl.COUNT <> p_raw_cost_rate_tbl.COUNT     OR
       p_planning_start_date_tbl.COUNT <> p_burd_cost_rate_tbl.COUNT    OR
       p_planning_start_date_tbl.COUNT <> p_bill_rate_tbl.COUNT         OR
       p_planning_start_date_tbl.COUNT <> p_spread_curve_id_tbl.COUNT   OR
       p_planning_start_date_tbl.COUNT <> p_mfc_cost_type_id_tbl.COUNT  OR
       p_planning_start_date_tbl.COUNT <> p_etc_method_code_tbl.COUNT   OR
       p_planning_start_date_tbl.COUNT <> p_sp_fixed_date_tbl.COUNT     OR
       p_planning_start_date_tbl.COUNT <> p_delete_flag_tbl.COUNT       OR
       p_planning_start_date_tbl.COUNT <> p_ra_id_tbl.COUNT             OR
       p_planning_start_date_tbl.COUNT <> p_res_class_code_tbl.COUNT    OR
       p_planning_start_date_tbl.COUNT <> p_rate_based_flag_tbl.COUNT   OR
       p_planning_start_date_tbl.COUNT <> p_rbs_elem_id_tbl.COUNT       THEN


        IF l_debug_mode = 'Y' THEN

           pa_debug.g_err_stage := ' p_planning_start_date_tbl.COUNT '|| p_planning_start_date_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_planning_end_date_tbl.COUNT '|| p_planning_end_date_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_budget_lines_tbl.COUNT '|| p_budget_lines_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_raw_cost_rate_tbl.COUNT '|| p_raw_cost_rate_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_burd_cost_rate_tbl.COUNT '|| p_burd_cost_rate_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_bill_rate_tbl.COUNT '|| p_bill_rate_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_spread_curve_id_tbl.COUNT '|| p_spread_curve_id_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_mfc_cost_type_id_tbl.COUNT '|| p_mfc_cost_type_id_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_etc_method_code_tbl.COUNT '|| p_etc_method_code_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_sp_fixed_date_tbl.COUNT '|| p_sp_fixed_date_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_delete_flag_tbl.COUNT '|| p_delete_flag_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_ra_id_tbl.COUNT '|| p_ra_id_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_res_class_code_tbl.COUNT '|| p_res_class_code_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_rate_based_flag_tbl.COUNT '|| p_rate_based_flag_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

           pa_debug.g_err_stage := ' p_rbs_elem_id_tbl.COUNT '|| p_rbs_elem_id_tbl.COUNT;
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level5);

        END IF;
        pa_utils.add_message(p_app_short_name => 'PA',
                           p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                           p_token1           => 'PROCEDURENAME',
                           p_value1           => l_module_name);

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;
    --log1('----- STAGE 1-------');
    l_prev_pbl_tbl_count :=0;
    l_skip_ra_flag:='N';


    x_task_id_tbl                     :=   SYSTEM.pa_num_tbl_type();
    x_rlm_id_tbl                      :=   SYSTEM.pa_num_tbl_type();
    x_ra_id_tbl                       :=   SYSTEM.pa_num_tbl_type();
    x_txn_currency_code_tbl           :=   SYSTEM.pa_varchar2_15_tbl_type();
    x_planning_start_date_tbl         :=   SYSTEM.pa_date_tbl_type();
    x_planning_end_date_tbl           :=   SYSTEM.pa_date_tbl_type();
    x_total_qty_tbl                   :=   SYSTEM.pa_num_tbl_type();
    x_total_raw_cost_tbl              :=   SYSTEM.pa_num_tbl_type();
    x_total_burdened_cost_tbl         :=   SYSTEM.pa_num_tbl_type();
    x_total_revenue_tbl               :=   SYSTEM.pa_num_tbl_type();
    x_raw_cost_rate_tbl               :=   SYSTEM.pa_num_tbl_type();
    x_burdened_cost_rate_tbl          :=   SYSTEM.pa_num_tbl_type();
    x_bill_rate_tbl                   :=   SYSTEM.pa_num_tbl_type();
    x_line_start_date_tbl             :=   SYSTEM.pa_date_tbl_type();
    x_line_end_date_tbl               :=   SYSTEM.pa_date_tbl_type();
    x_proj_cost_rate_type_tbl         :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_proj_cost_rate_date_type_tbl    :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_proj_cost_rate_tbl              :=   SYSTEM.pa_num_tbl_type();
    x_proj_cost_rate_date_tbl         :=   SYSTEM.pa_date_tbl_type();
    x_proj_rev_rate_type_tbl          :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_proj_rev_rate_date_type_tbl     :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_proj_rev_rate_tbl               :=   SYSTEM.pa_num_tbl_type();
    x_proj_rev_rate_date_tbl          :=   SYSTEM.pa_date_tbl_type();
    x_pfunc_cost_rate_type_tbl        :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_pfunc_cost_rate_date_typ_tbl    :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_pfunc_cost_rate_tbl             :=   SYSTEM.pa_num_tbl_type();
    x_pfunc_cost_rate_date_tbl        :=   SYSTEM.pa_date_tbl_type();
    x_pfunc_rev_rate_type_tbl         :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_pfunc_rev_rate_date_type_tbl    :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_pfunc_rev_rate_tbl              :=   SYSTEM.pa_num_tbl_type();
    x_pfunc_rev_rate_date_tbl         :=   SYSTEM.pa_date_tbl_type();
    x_delete_flag_tbl                 :=   SYSTEM.pa_varchar2_1_tbl_type();
    x_spread_curve_id_tbl             :=   SYSTEM.pa_num_tbl_type();
    x_mfc_cost_type_id_tbl            :=   SYSTEM.pa_num_tbl_type();
    x_etc_method_code_tbl             :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_sp_fixed_date_tbl               :=   SYSTEM.pa_date_tbl_type();
    x_res_class_code_tbl              :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_rate_based_flag_tbl             :=   SYSTEM.pa_varchar2_1_tbl_type();
    x_rbs_elem_id_tbl                 :=   SYSTEM.pa_num_tbl_type();
    x_change_reason_code_tbl          :=   SYSTEM.pa_varchar2_30_tbl_type();
    x_description_tbl                 :=   SYSTEM.pa_varchar2_2000_tbl_type();

    --log1('----- STAGE 2-------');
    IF p_context = 'WEBADI_PERIODIC' THEN
       --log1('----- STAGE 2P-------');
        --These variables will be used to store the values corresponding to the previous
        --row while looping thru the rows in the interface table.
        l_prev_task_id          := -1;
        l_prev_rlm_id           := l_g_miss_num;
        l_prev_txn_curr_code    := l_g_miss_char;
        l_bl_index              := 1;

        --Initialize the OUT variables l_prd_mask_st_date_tbl/l_prd_mask_end_date_tbl
        --First element is reserved for preceeding bucket which will be set for each resource assignment later
        l_prd_mask_st_date_tbl.extend;
        l_prd_mask_end_date_tbl.extend;
        l_prd_mask_end_date_tbl(1):=p_first_pd_bf_pm_en_dt;
        FOR i IN 1..p_prd_mask_st_date_tbl.COUNT LOOP
            l_prd_mask_st_date_tbl.extend;
            l_prd_mask_st_date_tbl(l_prd_mask_st_date_tbl.COUNT):=p_prd_mask_st_date_tbl(i);
            l_prd_mask_end_date_tbl.extend;
            l_prd_mask_end_date_tbl(l_prd_mask_end_date_tbl.COUNT):=p_prd_mask_end_date_tbl(i);
        END LOOP;
        --Reserve the last element for succeding bucket which will be set for each resource assignment later
        l_prd_mask_st_date_tbl.extend;
        l_prd_mask_st_date_tbl(l_prd_mask_st_date_tbl.COUNT):=p_last_pd_af_pm_st_dt;
        l_prd_mask_end_date_tbl.extend;

        --log1('----- STAGE 3P-------');
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'About to loop thru inf_tbl_data_csr';
           pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
        END IF;
        IF p_version_info_rec.x_version_type = 'COST' THEN
          l_allow_qty_flag := p_version_info_rec.x_cost_quantity_flag;
        ELSIF p_version_info_rec.x_version_type = 'REVENUE' THEN
          l_allow_qty_flag := p_version_info_rec.x_rev_quantity_flag;
        ELSIF p_version_info_rec.x_version_type = 'ALL' THEN
          l_allow_qty_flag := p_version_info_rec.x_all_quantity_flag;
        END IF;

        /*FOR l_curr_rec IN inf_tbl_data_csr LOOP*/
        -- Changing the for loop to a while loop so that the variable can be incremented inside
        -- This is for bug 4477397
        tt := 0;
        while tt <= p_inf_tbl_rec_tbl.COUNT
        LOOP
            tt := tt + 1;

            IF tt > p_inf_tbl_rec_tbl.COUNT THEN
                EXIT;
            END IF;

            l_curr_rec:=NULL;
            IF l_skip_ra_flag ='N' THEN

--                FETCH inf_tbl_data_csr INTO l_curr_rec;
                l_curr_rec := p_inf_tbl_rec_tbl(tt);

            ELSE

                LOOP

                    IF tt <= p_inf_tbl_rec_tbl.COUNT THEN
                        l_curr_rec := p_inf_tbl_rec_tbl(tt);
                    ELSE
                        l_curr_rec := NULL;
                    END IF;

                    EXIT WHEN l_curr_rec.task_id IS NULL OR
                              l_curr_rec.task_id <> l_skip_task_id OR
                              l_curr_rec.resource_list_member_id <> l_skip_rlm_id;
                    l_curr_rec:=NULL;
                    tt := tt + 1;
--                    FETCH inf_tbl_data_csr INTO l_curr_rec;

                END LOOP;

            END IF;

            IF tt > p_inf_tbl_rec_tbl.COUNT THEN
                EXIT;
            END IF;

            l_skip_ra_flag := 'N';
            l_skip_task_id := NULL;
            l_skip_rlm_id := NULL;
            --EXIT WHEN l_curr_rec.task_id IS NULL;
            --log1('----- STAGE X1-------');
            --Reset l_extend_pbl_out_tbls_flag. This flag will be set to Y for each planning
            --TXN so that the OUT tbls for process_budget_lines are correctly increased in length
            l_extend_pbl_out_tbls_flag := 'N';

            --Loop thru the p_budget_lines_tbl to find the record with RA/Curr same as
            --l_curr_rec
            LOOP
                --log1('----- STAGE X2-------');
                EXIT WHEN p_budget_lines_tbl(l_bl_index).pa_task_id = l_curr_rec.task_id AND
                          p_budget_lines_tbl(l_bl_index).resource_list_member_id = l_curr_rec.resource_list_member_id AND
                          p_budget_lines_tbl(l_bl_index).txn_currency_code = l_curr_rec.txn_currency_code;

                l_bl_index:=l_bl_index+1;
                --log1('----- STAGE X3-------');
            END LOOP;

            IF p_planning_start_date_tbl(l_bl_index) IS NOT NULL AND
               p_planning_end_date_tbl(l_bl_index) IS NOT NULL
              AND (p_etc_start_date IS NULL OR ( p_etc_start_date < p_planning_end_date_tbl(l_bl_index) ) ) THEN

                --For each resource assignment find out the no. of periods in the period mask
                --that would fall between the planning start/end dates. If n such periods exist,
                --then n rows in the OUT tbls for each RA/currency/amount type should be prepared
                IF l_curr_rec.task_id <> l_prev_task_id OR
                   NVL(l_curr_rec.resource_list_member_id,'-99') <> l_prev_rlm_id THEN

                    IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'Finding out no. of periods for RA with task_id '||l_curr_rec.task_id||' Res '||l_curr_rec.resource_list_member_id;
                       pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
                    END IF;

                    /*IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'p_version_info_rec.x_org_id: ' || p_version_info_rec.x_org_id;
                       pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
                       pa_debug.g_err_stage := 'l_bl_index: ' || l_bl_index;
                       pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
                       pa_debug.g_err_stage := 'p_planning_start_date_tbl(l_bl_index): ' || p_planning_start_date_tbl(l_bl_index);
                       pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
                       pa_debug.g_err_stage := 'p_version_info_rec.x_time_phased_code: ' || p_version_info_rec.x_time_phased_code;
                       pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
                       pa_debug.g_err_stage := 'p_planning_end_date_tbl(l_bl_index): ' || p_planning_end_date_tbl(l_bl_index);
                       pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
                    END IF;*/
                    --Populate the preceeding and succeeding buckets in the period mask table
                    --log1('----- STAGE X3.1------- '||p_version_info_rec.x_org_id);
                    --log1('----- STAGE X3.2------- '||l_bl_index);
                    --log1('----- STAGE X3.3------- '||p_planning_start_date_tbl(l_bl_index));
                    --log1('----- STAGE X3.4------- '|| p_version_info_rec.x_org_id);
                    --log1('----- STAGE X3.5------- '|| p_version_info_rec.x_time_phased_code);
                    --log1('----- STAGE X3.6------- '|| p_planning_end_date_tbl(l_bl_index));
                    SELECT gl.start_date
                    INTO   l_prd_mask_st_date_tbl(1)
                    FROM   gl_periods gl,
                           pa_implementations_all pim,
                           gl_sets_of_books gsb
                    WHERE  pim.org_id = p_version_info_rec.x_org_id
                    AND    gsb.set_of_books_id = pim.set_of_books_id
                    AND    gl.period_set_name= DECODE(p_version_info_rec.x_time_phased_code,'P',pim.period_set_name,'G',gsb.period_set_name)
                    AND    gl.period_type = DECODE(p_version_info_rec.x_time_phased_code,
                                                   'P',pim.pa_period_type,
                                                   'G',gsb.accounted_period_type)
                    AND    gl.adjustment_period_flag='N'
                    AND    gl.start_date <= p_planning_start_date_tbl(l_bl_index)
                    AND    gl.end_date >=p_planning_start_date_tbl(l_bl_index);

                    SELECT gl.end_date
                    INTO   l_prd_mask_end_date_tbl(l_prd_mask_end_date_tbl.COUNT)
                    FROM   gl_periods gl,
                           pa_implementations_all pim,
                           gl_sets_of_books gsb
                    WHERE  pim.org_id = p_version_info_rec.x_org_id
                    AND    gsb.set_of_books_id = pim.set_of_books_id
                    AND    gl.period_set_name= DECODE(p_version_info_rec.x_time_phased_code,'P',pim.period_set_name,'G',gsb.period_set_name)
                    AND    gl.period_type = DECODE(p_version_info_rec.x_time_phased_code,
                                                   'P',pim.pa_period_type,
                                                   'G',gsb.accounted_period_type)
                    AND    gl.adjustment_period_flag='N'
                    AND    gl.start_date <= p_planning_end_date_tbl(l_bl_index)
                    AND    gl.end_date >=p_planning_end_date_tbl(l_bl_index);

                    l_extend_pbl_out_tbls_flag:= 'Y';
                    l_plan_txn_attrs_copied_flag := 'N';
                    l_prev_task_id:=l_curr_rec.task_id;
                    l_prev_rlm_id:=l_curr_rec.resource_list_member_id;
                    l_prev_txn_curr_code:=l_curr_rec.txn_currency_code;

                    --Find out the flexible periods in the period mask that should be considered
                    --based on RA's planning start/end dates
                    l_st_index_in_prd_mask      := NULL;
                    l_end_index_in_prd_mask     := NULL;
                    l_sd_prd_exists_flag        := NULL;
                    l_pd_prd_exists_flag        := NULL;
                    l_num_of_prds_for_plan_txn  :=0;

                    --log1('----- STAGE X4-------');
                    IF NVL(p_etc_start_date,p_planning_start_date_tbl(l_bl_index)) < p_prd_mask_st_date_tbl(1) THEN
                        --log1('----- STAGE X5-------');
                        l_st_index_in_prd_mask:=1;
                        l_pd_prd_exists_flag :='Y';

                    END IF;

                    --log1('----- STAGE X5.1------- '||l_bl_index);
                    --log1('----- STAGE X5.2------- '||p_planning_end_date_tbl(l_bl_index) );
                    --log1('----- STAGE X5.3------- '||p_prd_mask_end_date_tbl(p_prd_mask_end_date_tbl.COUNT));
                    IF p_planning_end_date_tbl(l_bl_index) > p_prd_mask_end_date_tbl(p_prd_mask_end_date_tbl.COUNT) THEN

                        l_end_index_in_prd_mask:=l_prd_mask_end_date_tbl.COUNT;
                        l_sd_prd_exists_flag :='Y';

                    END IF;

                    --log1('----- STAGE X5.4------- '||l_st_index_in_prd_mask);
                    --log1('----- STAGE X5.5------- '||l_end_index_in_prd_mask);
                    IF l_st_index_in_prd_mask IS NULL OR
                       l_end_index_in_prd_mask IS NULL THEN

                        --Find out the flexbile period in which the planning start/end dates fall
                        FOR kk IN 2..l_prd_mask_st_date_tbl.LAST-1 LOOP

                            IF l_st_index_in_prd_mask IS NULL THEN

                                --log1('----- STAGE X5.6------- '||l_bl_index);
                                --log1('----- STAGE X5.7------- '||p_planning_start_date_tbl(l_bl_index));
                                --log1('----- STAGE X5.8------- '||kk);
                                --log1('----- STAGE X5.9------- '|| l_prd_mask_st_date_tbl(kk));
                                --log1('----- STAGE X5.10------- '|| l_prd_mask_end_date_tbl(kk));
                                IF NVL(p_etc_start_date,p_planning_start_date_tbl(l_bl_index)) >= l_prd_mask_st_date_tbl(kk) AND
                                   NVL(p_etc_start_date,p_planning_start_date_tbl(l_bl_index)) <= l_prd_mask_end_date_tbl(kk)  THEN

                                    l_st_index_in_prd_mask:= kk;

                                END IF;

                            END IF;

                            IF l_end_index_in_prd_mask IS NULL THEN

                                --log1('----- STAGE X5.10------- '||l_bl_index);
                                --log1('----- STAGE X5.11------- '||p_planning_end_date_tbl(l_bl_index));
                                --log1('----- STAGE X5.12------- '||kk);
                                --log1('----- STAGE X5.13------- '|| l_prd_mask_st_date_tbl(kk));
                                --log1('----- STAGE X5.14------- '|| l_prd_mask_end_date_tbl(kk));
                                IF p_planning_end_date_tbl(l_bl_index) >= l_prd_mask_st_date_tbl(kk) AND
                                   p_planning_end_date_tbl(l_bl_index) <= l_prd_mask_end_date_tbl(kk) THEN

                                    l_end_index_in_prd_mask:= kk;

                                END IF;

                            END IF;

                            IF l_st_index_in_prd_mask IS NOT NULL AND
                               l_end_index_in_prd_mask IS NOT NULL THEN

                                EXIT;

                            END IF;

                        END LOOP;--FOR kk IN 2..l_prd_mask_st_date_tbl LOOP

                    END IF;--IF l_st_index_in_prd_mask IS NULL OR

                    IF l_st_index_in_prd_mask IS NULL AND
                       l_end_index_in_prd_mask IS NOT NULL THEN

                        l_st_index_in_prd_mask :=l_end_index_in_prd_mask;

                    END IF;

                    IF l_st_index_in_prd_mask IS NOT NULL AND
                       l_end_index_in_prd_mask IS  NULL THEN

                        l_end_index_in_prd_mask := l_st_index_in_prd_mask;

                    END IF;

                    l_num_of_prds_for_plan_txn := l_end_index_in_prd_mask -  l_st_index_in_prd_mask +1;

                    l_extend_pbl_out_tbls_flag := 'Y';

                END IF;--IF l_curr_rec.task_id <> l_prev_task_id OR

                --Currency /amount type of this record is different from one that of previous record.
                IF l_prev_txn_curr_code <> l_curr_rec.txn_currency_code  THEN

                    l_extend_pbl_out_tbls_flag:= 'Y';
                    l_plan_txn_attrs_copied_flag := 'N';
                    l_prev_txn_curr_code:=l_curr_rec.txn_currency_code;

                END IF;

                --Extend the OUT tbls and populate the Line start/end tbls. Header level tbls such as
                --task/rlm etc will also be populated.
                IF l_extend_pbl_out_tbls_flag ='Y' THEN

                    l_extend_pbl_out_tbls_flag := 'N';
                    --This variable will be used to store the index till which the OUT tbls for prepare_pbl_input are
                    --populated.
                    l_prev_pbl_tbl_count := x_task_id_tbl.COUNT;
                    x_task_id_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_rlm_id_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_ra_id_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_spread_curve_id_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_mfc_cost_type_id_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_etc_method_code_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_sp_fixed_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_res_class_code_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_rate_based_flag_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_rbs_elem_id_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_txn_currency_code_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_planning_start_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_planning_end_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_total_qty_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_total_raw_cost_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_total_burdened_cost_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_total_revenue_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_raw_cost_rate_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_burdened_cost_rate_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_bill_rate_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_line_start_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_line_end_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_proj_cost_rate_type_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_proj_cost_rate_date_type_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_proj_cost_rate_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_proj_cost_rate_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_proj_rev_rate_type_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_proj_rev_rate_date_type_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_proj_rev_rate_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_proj_rev_rate_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_pfunc_cost_rate_type_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_pfunc_cost_rate_date_typ_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_pfunc_cost_rate_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_pfunc_cost_rate_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_pfunc_rev_rate_type_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_pfunc_rev_rate_date_type_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_pfunc_rev_rate_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_pfunc_rev_rate_date_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_delete_flag_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_change_reason_code_tbl.extend(l_num_of_prds_for_plan_txn);
                    x_description_tbl.extend(l_num_of_prds_for_plan_txn);

                    --log1('----- STAGE X5.15.0------- '||l_st_index_in_prd_mask);
                    --log1('----- STAGE X5.15.0.1------- '||l_end_index_in_prd_mask);

                    IF l_st_index_in_prd_mask IS NOT NULL THEN

                        FOR kk IN l_st_index_in_prd_mask..l_end_index_in_prd_mask LOOP

                            l_tmp_index := l_prev_pbl_tbl_count + kk - l_st_index_in_prd_mask + 1;
                            --log1('----- STAGE X5.15.1 ------- '||l_tmp_index);

                             x_line_start_date_tbl(l_tmp_index):=l_prd_mask_st_date_tbl(kk);

                            --log1('----- STAGE X5.15.2 ------- ');

                            x_line_end_date_tbl(l_tmp_index):=l_prd_mask_end_date_tbl(kk);

                            --log1('----- STAGE X5.15.3 ------- ');
                            x_task_id_tbl(l_tmp_index)            := l_curr_rec.task_id;
                            x_rlm_id_tbl(l_tmp_index)             := p_budget_lines_tbl(l_bl_index).resource_list_member_id;
                            x_ra_id_tbl(l_tmp_index)              := p_ra_id_tbl(l_bl_index);
                            x_txn_currency_code_tbl(l_tmp_index)  := l_curr_rec.txn_currency_code;
                            --log1('----- STAGE X5.15.4 ------- ');
                            x_planning_start_date_tbl(l_tmp_index):= p_planning_start_date_tbl(l_bl_index);
                            x_planning_end_date_tbl(l_tmp_index)  := p_planning_end_date_tbl(l_bl_index);
                            x_spread_curve_id_tbl(l_tmp_index)    := p_spread_curve_id_tbl(l_bl_index);
                            --log1('----- STAGE X5.15.5 ------- ');
                            x_mfc_cost_type_id_tbl(l_tmp_index)   := p_mfc_cost_type_id_tbl(l_bl_index);
                            x_etc_method_code_tbl(l_tmp_index)    := p_etc_method_code_tbl(l_bl_index);
                            x_sp_fixed_date_tbl(l_tmp_index)      := p_sp_fixed_date_tbl(l_bl_index);
                            --log1('----- STAGE X5.15.6 ------- ');
                            x_res_class_code_tbl(l_tmp_index)     := p_res_class_code_tbl(l_bl_index);
                            x_rate_based_flag_tbl(l_tmp_index)    := p_rate_based_flag_tbl(l_bl_index);
                            x_rbs_elem_id_tbl(l_tmp_index)        := p_rbs_elem_id_tbl(l_bl_index);
                            --Assigning N since for periodic layouts, amounts a  type with delete flag as N would be NULLED
                            --out
                            x_delete_flag_tbl(l_tmp_index)        :='N';



                        END LOOP;--FOR kk IN l_st_index_in_prd_mask..l_end_index_in_prd_mask LOOP

                    END IF;--IF l_st_index_in_prd_mask IS NOT NULL THEN

                END IF;--IF l_extend_pbl_out_tbls_flag ='Y' THEN

                --log1('----- STAGE X5.16------- ');
                IF l_st_index_in_prd_mask IS NOT NULL THEN

                    --For the current record, populate amounts for appropriate amount types
                    FOR kk IN l_st_index_in_prd_mask..l_end_index_in_prd_mask LOOP

                        IF l_curr_rec.delete_flag ='Y' THEN

                            l_amount := l_g_miss_num;

                        ELSE

                            IF kk = 1 THEN
                            --Indicates that the flex period corresponds to FIRST period before the first flexible period in
                            --the period mask. This period stands for PD period
                                l_prd_index := 'PD';

                            ELSIF kk = l_prd_mask_st_date_tbl.COUNT THEN
                            --Indicates that the flex period corresponds to FIRST period AFTER the LAST flexible period in
                            --the period mask. This period stands for SD period
                                l_prd_index := 'SD';

                            ELSE

                                --kk-1 should be used since the periods in the period mask are
                                --stored staring from the second bucket of l_prd_mask_st_date_tbl
                                l_prd_index := to_char(kk-1);

                            END IF;

                            l_amount := get_amount_in_prd_x(p_rec => l_curr_rec,
                                                            p_prd => l_prd_index);

                        END IF;

                        l_tmp_index := l_prev_pbl_tbl_count + kk - l_st_index_in_prd_mask + 1;

                        --In the below block amounts that should be passed to the calculate API will be derived
                        --In case of Budgets, only one column per amount type is editable
                        --In case of Forecasts two columns (Forecast and ETC) are editable.
                        ---->If both are hidden in the layout NULL will be passed
                        ---->If ETC is hidden and Forecast is displayed in the layout then Forecast entered will be passed
                        ---->If Forecast is hidden and ETC is displayed in the layout then ETC entered + Actuals will be passed
                        ---->If both Forecast and ETC are displayed in the layout then
                        ------>If Forecast is entered is different from the existing value then it will be passed
                        ------>Else If ETC entered is different from existing value then ETC + actuals will be passed
                        ------>Else NULL will be passed
                        ---->Note that amount columns in budget lines tbl will contain the forecast values and ETC values
                        ---->are passed as input to this API
                        IF  l_curr_rec.amount_type_code = 'TOTAL_BURDENED_COST' THEN

                            x_total_burdened_cost_tbl(l_tmp_index) := l_amount;

                        ELSIF  l_curr_rec.amount_type_code = 'FCST_BURDENED_COST' THEN

                            x_total_burdened_cost_tbl(l_tmp_index) := l_amount;

                        ELSIF  l_curr_rec.amount_type_code = 'ETC_BURDENED_COST' THEN

                            get_total_fcst_amounts
                           (p_project_id                    =>p_project_id,
                            p_budget_version_id             =>p_budget_version_id,
                            p_task_id                       =>l_curr_rec.task_id,
                            p_resource_list_member_id       =>p_budget_lines_tbl(l_bl_index).resource_list_member_id,
                            p_txn_currency_code             =>l_curr_rec.txn_currency_code,
                            p_line_start_date               =>l_prd_mask_st_date_tbl(kk),
                            p_line_end_date                 =>l_prd_mask_end_date_tbl(kk),
                            p_prd_mask_st_date_tbl          =>l_prd_mask_st_date_tbl,
                            p_prd_mask_end_date_tbl         =>l_prd_mask_end_date_tbl,
                            p_st_index_in_prd_mask          =>l_st_index_in_prd_mask,
                            p_end_index_in_prd_mask         =>l_end_index_in_prd_mask,
                            p_etc_start_date                =>p_etc_start_date,
                            p_etc_quantity                  =>NULL,
                            p_fcst_quantity                 =>NULL,
                            p_etc_raw_cost                  =>NULL,
                            p_fcst_raw_cost                 =>NULL,
                            p_etc_burd_cost                 =>l_amount,
                            p_fcst_burd_cost                =>x_total_burdened_cost_tbl(l_tmp_index),
                            p_etc_revenue                   =>NULL,
                            p_fcst_revenue                  =>NULL,
                            px_cached_fcst_qty_tbl          =>l_cached_fcst_qty_tbl,
                            px_cached_fcst_raw_cost_tbl     =>l_cached_fcst_raw_cost_tbl,
                            px_cached_fcst_burd_cost_tbl    =>l_cached_fcst_burd_cost_tbl,
                            px_cached_fcst_revenue_tbl      =>l_cached_fcst_revenue_tbl,
                            px_cached_etc_qty_tbl           =>l_cached_etc_qty_tbl,
                            px_cached_etc_raw_cost_tbl      =>l_cached_etc_raw_cost_tbl,
                            px_cached_etc_burd_cost_tbl     =>l_cached_etc_burd_cost_tbl,
                            px_cached_etc_revenue_tbl       =>l_cached_etc_revenue_tbl,
                            x_total_quantity                =>l_tmp_quantity,
                            x_total_raw_cost                =>l_tmp_raw_cost,
                            x_total_burd_cost               =>x_total_burdened_cost_tbl(l_tmp_index),
                            x_total_revenue                 =>l_tmp_revenue,
                            x_return_status                 =>x_return_status,
                            x_msg_count                     =>x_msg_count,
                            x_msg_data                      =>x_msg_data    );

                            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 IF l_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage := 'Call to get_total_fcst_amounts returned with error';
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                                 END IF;
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;


                        ELSIF l_curr_rec.amount_type_code = 'TOTAL_RAW_COST' THEN

                            x_total_raw_cost_tbl(l_tmp_index) := l_amount;

                        ELSIF l_curr_rec.amount_type_code = 'FCST_RAW_COST' THEN

                            x_total_raw_cost_tbl(l_tmp_index) := l_amount;

                        ELSIF  l_curr_rec.amount_type_code = 'ETC_RAW_COST' THEN

                            get_total_fcst_amounts
                           (p_project_id                    =>p_project_id,
                            p_budget_version_id             =>p_budget_version_id,
                            p_task_id                       =>l_curr_rec.task_id,
                            p_resource_list_member_id       =>p_budget_lines_tbl(l_bl_index).resource_list_member_id,
                            p_txn_currency_code             =>l_curr_rec.txn_currency_code,
                            p_line_start_date               =>l_prd_mask_st_date_tbl(kk),
                            p_line_end_date                 =>l_prd_mask_end_date_tbl(kk),
                            p_prd_mask_st_date_tbl          =>l_prd_mask_st_date_tbl,
                            p_prd_mask_end_date_tbl         =>l_prd_mask_end_date_tbl,
                            p_st_index_in_prd_mask          =>l_st_index_in_prd_mask,
                            p_end_index_in_prd_mask         =>l_end_index_in_prd_mask,
                            p_etc_start_date                =>p_etc_start_date,
                            p_etc_quantity                  =>NULL,
                            p_fcst_quantity                 =>NULL,
                            p_etc_raw_cost                  =>l_amount,
                            p_fcst_raw_cost                 =>x_total_raw_cost_tbl(l_tmp_index),
                            p_etc_burd_cost                 =>NULL,
                            p_fcst_burd_cost                =>NULL,
                            p_etc_revenue                   =>NULL,
                            p_fcst_revenue                  =>NULL,
                            px_cached_fcst_qty_tbl          =>l_cached_fcst_qty_tbl,
                            px_cached_fcst_raw_cost_tbl     =>l_cached_fcst_raw_cost_tbl,
                            px_cached_fcst_burd_cost_tbl    =>l_cached_fcst_burd_cost_tbl,
                            px_cached_fcst_revenue_tbl      =>l_cached_fcst_revenue_tbl,
                            px_cached_etc_qty_tbl           =>l_cached_etc_qty_tbl,
                            px_cached_etc_raw_cost_tbl      =>l_cached_etc_raw_cost_tbl,
                            px_cached_etc_burd_cost_tbl     =>l_cached_etc_burd_cost_tbl,
                            px_cached_etc_revenue_tbl       =>l_cached_etc_revenue_tbl,
                            x_total_quantity                =>l_tmp_quantity,
                            x_total_raw_cost                =>x_total_raw_cost_tbl(l_tmp_index),
                            x_total_burd_cost               =>l_tmp_burd_cost,
                            x_total_revenue                 =>l_tmp_revenue,
                            x_return_status                 =>x_return_status,
                            x_msg_count                     =>x_msg_count,
                            x_msg_data                      =>x_msg_data    );

                            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 IF l_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage := 'Call to get_total_fcst_amounts returned with error';
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                                 END IF;
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;


                        ELSIF l_curr_rec.amount_type_code = 'TOTAL_REV' THEN

                            x_total_revenue_tbl(l_tmp_index) := l_amount;

                        ELSIF l_curr_rec.amount_type_code = 'FCST_REVENUE' THEN

                            x_total_revenue_tbl(l_tmp_index) := l_amount;

                        ELSIF l_curr_rec.amount_type_code = 'ETC_REVENUE' THEN

                            get_total_fcst_amounts
                           (p_project_id                    =>p_project_id,
                            p_budget_version_id             =>p_budget_version_id,
                            p_task_id                       =>l_curr_rec.task_id,
                            p_resource_list_member_id       =>p_budget_lines_tbl(l_bl_index).resource_list_member_id,
                            p_txn_currency_code             =>l_curr_rec.txn_currency_code,
                            p_line_start_date               =>l_prd_mask_st_date_tbl(kk),
                            p_line_end_date                 =>l_prd_mask_end_date_tbl(kk),
                            p_prd_mask_st_date_tbl          =>l_prd_mask_st_date_tbl,
                            p_prd_mask_end_date_tbl         =>l_prd_mask_end_date_tbl,
                            p_st_index_in_prd_mask          =>l_st_index_in_prd_mask,
                            p_end_index_in_prd_mask         =>l_end_index_in_prd_mask,
                            p_etc_start_date                =>p_etc_start_date,
                            p_etc_quantity                  =>NULL,
                            p_fcst_quantity                 =>NULL,
                            p_etc_raw_cost                  =>NULL,
                            p_fcst_raw_cost                 =>NULL,
                            p_etc_burd_cost                 =>NULL,
                            p_fcst_burd_cost                =>NULL,
                            p_etc_revenue                   =>l_amount,
                            p_fcst_revenue                  =>x_total_revenue_tbl(l_tmp_index),
                            px_cached_fcst_qty_tbl          =>l_cached_fcst_qty_tbl,
                            px_cached_fcst_raw_cost_tbl     =>l_cached_fcst_raw_cost_tbl,
                            px_cached_fcst_burd_cost_tbl    =>l_cached_fcst_burd_cost_tbl,
                            px_cached_fcst_revenue_tbl      =>l_cached_fcst_revenue_tbl,
                            px_cached_etc_qty_tbl           =>l_cached_etc_qty_tbl,
                            px_cached_etc_raw_cost_tbl      =>l_cached_etc_raw_cost_tbl,
                            px_cached_etc_burd_cost_tbl     =>l_cached_etc_burd_cost_tbl,
                            px_cached_etc_revenue_tbl       =>l_cached_etc_revenue_tbl,
                            x_total_quantity                =>l_tmp_quantity,
                            x_total_raw_cost                =>l_tmp_raw_cost,
                            x_total_burd_cost               =>l_tmp_burd_cost,
                            x_total_revenue                 =>x_total_revenue_tbl(l_tmp_index),
                            x_return_status                 =>x_return_status,
                            x_msg_count                     =>x_msg_count,
                            x_msg_data                      =>x_msg_data    );

                            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 IF l_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage := 'Call to get_total_fcst_amounts returned with error';
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                                 END IF;
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;


                        ELSIF l_curr_rec.amount_type_code = 'TOTAL_QTY' THEN

                            x_total_qty_tbl(l_tmp_index) := l_amount;

                        ELSIF l_curr_rec.amount_type_code = 'FCST_QTY' THEN

                            x_total_qty_tbl(l_tmp_index) := l_amount;

                        ELSIF l_curr_rec.amount_type_code = 'ETC_QTY' THEN

                            get_total_fcst_amounts
                           (p_project_id                    =>p_project_id,
                            p_budget_version_id             =>p_budget_version_id,
                            p_task_id                       =>l_curr_rec.task_id,
                            p_resource_list_member_id       =>p_budget_lines_tbl(l_bl_index).resource_list_member_id,
                            p_txn_currency_code             =>l_curr_rec.txn_currency_code,
                            p_line_start_date               =>l_prd_mask_st_date_tbl(kk),
                            p_line_end_date                 =>l_prd_mask_end_date_tbl(kk),
                            p_prd_mask_st_date_tbl          =>l_prd_mask_st_date_tbl,
                            p_prd_mask_end_date_tbl         =>l_prd_mask_end_date_tbl,
                            p_st_index_in_prd_mask          =>l_st_index_in_prd_mask,
                            p_end_index_in_prd_mask         =>l_end_index_in_prd_mask,
                            p_etc_start_date                =>p_etc_start_date,
                            p_etc_quantity                  =>l_amount,
                            p_fcst_quantity                 =>x_total_qty_tbl(l_tmp_index),
                            p_etc_raw_cost                  =>NULL,
                            p_fcst_raw_cost                 =>NULL,
                            p_etc_burd_cost                 =>NULL,
                            p_fcst_burd_cost                =>NULL,
                            p_etc_revenue                   =>NULL,
                            p_fcst_revenue                  =>NULL,
                            px_cached_fcst_qty_tbl          =>l_cached_fcst_qty_tbl,
                            px_cached_fcst_raw_cost_tbl     =>l_cached_fcst_raw_cost_tbl,
                            px_cached_fcst_burd_cost_tbl    =>l_cached_fcst_burd_cost_tbl,
                            px_cached_fcst_revenue_tbl      =>l_cached_fcst_revenue_tbl,
                            px_cached_etc_qty_tbl           =>l_cached_etc_qty_tbl,
                            px_cached_etc_raw_cost_tbl      =>l_cached_etc_raw_cost_tbl,
                            px_cached_etc_burd_cost_tbl     =>l_cached_etc_burd_cost_tbl,
                            px_cached_etc_revenue_tbl       =>l_cached_etc_revenue_tbl,
                            x_total_quantity                =>x_total_qty_tbl(l_tmp_index),
                            x_total_raw_cost                =>l_tmp_raw_cost,
                            x_total_burd_cost               =>l_tmp_burd_cost,
                            x_total_revenue                 =>l_tmp_revenue,
                            x_return_status                 =>x_return_status,
                            x_msg_count                     =>x_msg_count,
                            x_msg_data                      =>x_msg_data    );

                            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 IF l_debug_mode = 'Y' THEN
                                      pa_debug.g_err_stage := 'Call to get_total_fcst_amounts returned with error';
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                                 END IF;
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;

                        ELSIF l_curr_rec.amount_type_code IN ('ETC_BURDENED_COST_RATE','BURDENED_COST_RATE') THEN

                            x_burdened_cost_rate_tbl(l_tmp_index) := l_amount;

                        ELSIF l_curr_rec.amount_type_code IN ('RAW_COST_RATE','ETC_RAW_COST_RATE') THEN

                            x_raw_cost_rate_tbl(l_tmp_index) := l_amount;

                        ELSIF l_curr_rec.amount_type_code IN ('BILL_RATE','ETC_BILL_RATE') THEN

                            x_bill_rate_tbl(l_tmp_index) := l_amount;

                        END IF;

                    END LOOP;--FOR kk IN l_st_index_in_prd_mask..l_end_index_in_prd_mask LOOP

                    --log1('----- STAGE X5.17------- ');

                    IF nvl(l_curr_rec.delete_flag,'N') <> 'Y' AND
                           l_plan_txn_attrs_copied_flag ='N' THEN

                        FOR kk IN l_st_index_in_prd_mask..l_end_index_in_prd_mask LOOP

                            l_tmp_index := l_prev_pbl_tbl_count + kk - l_st_index_in_prd_mask + 1;

                            --log1('----- STAGE X5.17.1------- '||l_tmp_index);

                            x_proj_cost_rate_type_tbl(l_tmp_index)      := p_budget_lines_tbl(l_bl_index).project_cost_rate_type;
                            x_proj_cost_rate_date_type_tbl(l_tmp_index) := p_budget_lines_tbl(l_bl_index).project_cost_rate_date_type;
                            x_proj_cost_rate_tbl(l_tmp_index)           := p_budget_lines_tbl(l_bl_index).project_cost_exchange_rate;
                            x_proj_cost_rate_date_tbl(l_tmp_index)      := p_budget_lines_tbl(l_bl_index).project_cost_rate_date;
                            --log1('----- STAGE X5.17.2------- ');
                            x_proj_rev_rate_type_tbl(l_tmp_index)       := p_budget_lines_tbl(l_bl_index).project_rev_rate_type;
                            x_proj_rev_rate_date_type_tbl(l_tmp_index)  := p_budget_lines_tbl(l_bl_index).project_rev_rate_date_type;
                            x_proj_rev_rate_tbl(l_tmp_index)            := p_budget_lines_tbl(l_bl_index).project_rev_exchange_rate;
                            x_proj_rev_rate_date_tbl(l_tmp_index)       := p_budget_lines_tbl(l_bl_index).project_rev_rate_date;
                            --log1('----- STAGE X5.17.3------- ');
                            x_pfunc_cost_rate_type_tbl(l_tmp_index)     := p_budget_lines_tbl(l_bl_index).projfunc_cost_rate_type;
                            x_pfunc_cost_rate_date_typ_tbl(l_tmp_index) := p_budget_lines_tbl(l_bl_index).projfunc_cost_rate_date_type;
                            x_pfunc_cost_rate_tbl(l_tmp_index)          := p_budget_lines_tbl(l_bl_index).projfunc_cost_exchange_rate;
                            x_pfunc_cost_rate_date_tbl(l_tmp_index)     := p_budget_lines_tbl(l_bl_index).projfunc_cost_rate_date;
                            --log1('----- STAGE X5.17.4------- ');
                            x_pfunc_rev_rate_type_tbl(l_tmp_index)      := p_budget_lines_tbl(l_bl_index).projfunc_rev_rate_type;
                            x_pfunc_rev_rate_date_type_tbl(l_tmp_index) := p_budget_lines_tbl(l_bl_index).projfunc_rev_rate_date_type;
                            x_pfunc_rev_rate_tbl(l_tmp_index)           := p_budget_lines_tbl(l_bl_index).projfunc_rev_exchange_rate;
                            x_pfunc_rev_rate_date_tbl(l_tmp_index)      := p_budget_lines_tbl(l_bl_index).projfunc_rev_rate_date;

                            -- stamping null for change reason and description
                            x_change_reason_code_tbl(l_tmp_index)       := NULL;
                            x_description_tbl(l_tmp_index)              := NULL;

                        END LOOP;--IF nvl(l_curr_rec.delete_flag,'N') <> 'Y' AND

                        l_plan_txn_attrs_copied_flag :='Y';

                    END IF;

                END IF;--IF l_st_index_in_prd_mask IS NOT NULL THEN

             --Bug 6877488 : The below code should be executed only when the planning dates are null. Added that
             --condition to remove the case where planning dates are not null but etc start date is >= planning end date
             ELSIF p_planning_start_date_tbl(l_bl_index) IS  NULL AND
                   p_planning_end_date_tbl(l_bl_index) IS  NULL THEN

                 --Planning Start/End Dates both are null. This can happen only for new resource assignments when

                 ----1.Delete flag is Y or
                 ----2.Amounts are not entered at all.
                 --In the first case RA will be ignored and in the second case RA with no amounts would be created
                IF l_curr_rec.delete_flag='N' THEN

                    x_task_id_tbl.extend(1);
                    x_rlm_id_tbl.extend(1);
                    x_ra_id_tbl.extend(1);
                    x_spread_curve_id_tbl.extend(1);
                    x_mfc_cost_type_id_tbl.extend(1);
                    x_etc_method_code_tbl.extend(1);
                    x_sp_fixed_date_tbl.extend(1);
                    x_res_class_code_tbl.extend(1);
                    x_rate_based_flag_tbl.extend(1);
                    x_rbs_elem_id_tbl.extend(1);
                    x_txn_currency_code_tbl.extend(1);
                    x_planning_start_date_tbl.extend(1);
                    x_planning_end_date_tbl.extend(1);
                    x_total_qty_tbl.extend(1);
                    x_total_raw_cost_tbl.extend(1);
                    x_total_burdened_cost_tbl.extend(1);
                    x_total_revenue_tbl.extend(1);
                    x_raw_cost_rate_tbl.extend(1);
                    x_burdened_cost_rate_tbl.extend(1);
                    x_bill_rate_tbl.extend(1);
                    x_line_start_date_tbl.extend(1);
                    x_line_end_date_tbl.extend(1);
                    x_proj_cost_rate_type_tbl.extend(1);
                    x_proj_cost_rate_date_type_tbl.extend(1);
                    x_proj_cost_rate_tbl.extend(1);
                    x_proj_cost_rate_date_tbl.extend(1);
                    x_proj_rev_rate_type_tbl.extend(1);
                    x_proj_rev_rate_date_type_tbl.extend(1);
                    x_proj_rev_rate_tbl.extend(1);
                    x_proj_rev_rate_date_tbl.extend(1);
                    x_pfunc_cost_rate_type_tbl.extend(1);
                    x_pfunc_cost_rate_date_typ_tbl.extend(1);
                    x_pfunc_cost_rate_tbl.extend(1);
                    x_pfunc_cost_rate_date_tbl.extend(1);
                    x_pfunc_rev_rate_type_tbl.extend(1);
                    x_pfunc_rev_rate_date_type_tbl.extend(1);
                    x_pfunc_rev_rate_tbl.extend(1);
                    x_pfunc_rev_rate_date_tbl.extend(1);
                    x_delete_flag_tbl.extend(1);
                    x_change_reason_code_tbl.extend(1);
                    x_description_tbl.extend(1);
                    x_task_id_tbl(x_task_id_tbl.COUNT)                    := l_curr_rec.task_id;
                    x_rlm_id_tbl(x_rlm_id_tbl.COUNT)                      := p_budget_lines_tbl(l_bl_index).resource_list_member_id;
                    x_ra_id_tbl(x_ra_id_tbl.COUNT)                        := p_ra_id_tbl(l_bl_index);
                    x_txn_currency_code_tbl(x_txn_currency_code_tbl.COUNT):= l_curr_rec.txn_currency_code;
                    --Assigning N since for periodic layouts, amounts a  type with delete flag as N would be NULLED
                    --out
                    x_delete_flag_tbl(x_delete_flag_tbl.COUNT)            :='N';

                END IF;
                --Skip the processing of all the records pertaining to this ra id
                l_skip_ra_flag:='Y';
                l_skip_task_id:=l_curr_rec.task_id;
                l_skip_rlm_id:=p_budget_lines_tbl(l_bl_index).resource_list_member_id;

            END IF;--            IF p_planning_start_date_tbl(l_bl_index) IS NOT NULL AND


        END LOOP;

    ELSE --p_context is WEBADI_NON_PERIODIC
        --log1('----- STAGE X6-------');
        FOR kk IN 1..p_budget_lines_tbl.COUNT LOOP
            --log1('----- STAGE X7-------');
            x_task_id_tbl.EXTEND(1);
            x_task_id_tbl(kk)                  := p_budget_lines_tbl(kk).pa_task_id;
            x_rlm_id_tbl.EXTEND(1);
            x_rlm_id_tbl(kk)                   := p_budget_lines_tbl(kk).resource_list_member_id;
            x_ra_id_tbl.EXTEND(1);
            x_ra_id_tbl(kk)                    := p_ra_id_tbl(kk);
            x_txn_currency_code_tbl.EXTEND(1);
            x_txn_currency_code_tbl(kk)        := p_budget_lines_tbl(kk).txn_currency_code;
            --log1('----- STAGE X71-------');
            x_planning_start_date_tbl.EXTEND(1);
            x_planning_start_date_tbl(kk)      := p_planning_start_date_tbl(kk);
            x_planning_end_date_tbl.EXTEND(1);
            x_planning_end_date_tbl(kk)        := p_planning_end_date_tbl(kk);
            --log1('----- STAGE X72-------');
            x_total_qty_tbl.EXTEND(1);
            x_total_qty_tbl(kk)                := p_budget_lines_tbl(kk).quantity;
            x_total_raw_cost_tbl.EXTEND(1);
            x_total_raw_cost_tbl(kk)           := p_budget_lines_tbl(kk).raw_cost;
            x_total_burdened_cost_tbl.EXTEND(1);
            x_total_burdened_cost_tbl(kk)      := p_budget_lines_tbl(kk).burdened_cost;
            x_total_revenue_tbl.EXTEND(1);
            x_total_revenue_tbl(kk)            := p_budget_lines_tbl(kk).revenue;
            --log1('----- STAGE X73-------');
            x_raw_cost_rate_tbl.EXTEND(1);
            x_raw_cost_rate_tbl(kk)            := p_raw_cost_rate_tbl(kk);
            x_burdened_cost_rate_tbl.EXTEND(1);
            x_burdened_cost_rate_tbl(kk)       := p_burd_cost_rate_tbl(kk);
            x_bill_rate_tbl.EXTEND(1);
            x_bill_rate_tbl(kk)                := p_bill_rate_tbl(kk);
            --log1('----- STAGE X74-------');

            x_line_start_date_tbl.EXTEND(1);
            x_line_start_date_tbl(kk)          := NULL;
            x_line_end_date_tbl.EXTEND(1);
            x_line_end_date_tbl(kk)            := NULL;
            --log1('----- STAGE X75-------');
            x_proj_cost_rate_type_tbl.EXTEND(1);
            x_proj_cost_rate_type_tbl(kk)      := p_budget_lines_tbl(kk).project_cost_rate_type;
            x_proj_cost_rate_date_type_tbl.EXTEND(1);
            x_proj_cost_rate_date_type_tbl(kk) := p_budget_lines_tbl(kk).project_cost_rate_date_type;
            x_proj_cost_rate_tbl.EXTEND(1);
            x_proj_cost_rate_tbl(kk)           := p_budget_lines_tbl(kk).project_cost_exchange_rate;
            x_proj_cost_rate_date_tbl.EXTEND(1);
            x_proj_cost_rate_date_tbl(kk)      := p_budget_lines_tbl(kk).project_cost_rate_date;
            x_proj_rev_rate_type_tbl.EXTEND(1);
            x_proj_rev_rate_type_tbl(kk)       := p_budget_lines_tbl(kk).project_rev_rate_type;
            x_proj_rev_rate_date_type_tbl.EXTEND(1);
            x_proj_rev_rate_date_type_tbl(kk)  := p_budget_lines_tbl(kk).project_rev_rate_date_type;
            x_proj_rev_rate_tbl.EXTEND(1);
            x_proj_rev_rate_tbl(kk)            := p_budget_lines_tbl(kk).project_rev_exchange_rate;
            x_proj_rev_rate_date_tbl.EXTEND(1);
            x_proj_rev_rate_date_tbl(kk)       := p_budget_lines_tbl(kk).project_rev_rate_date;
            x_pfunc_cost_rate_type_tbl.EXTEND(1);
            x_pfunc_cost_rate_type_tbl(kk)     := p_budget_lines_tbl(kk).projfunc_cost_rate_type;
            x_pfunc_cost_rate_date_typ_tbl.EXTEND(1);
            x_pfunc_cost_rate_date_typ_tbl(kk) := p_budget_lines_tbl(kk).projfunc_cost_rate_date_type;
            x_pfunc_cost_rate_tbl.EXTEND(1);
            x_pfunc_cost_rate_tbl(kk)          := p_budget_lines_tbl(kk).projfunc_cost_exchange_rate;
            x_pfunc_cost_rate_date_tbl.EXTEND(1);
            x_pfunc_cost_rate_date_tbl(kk)     := p_budget_lines_tbl(kk).projfunc_cost_rate_date;
            x_pfunc_rev_rate_type_tbl.EXTEND(1);
            x_pfunc_rev_rate_type_tbl(kk)      := p_budget_lines_tbl(kk).projfunc_rev_rate_type;
            x_pfunc_rev_rate_date_type_tbl.EXTEND(1);
            x_pfunc_rev_rate_date_type_tbl(kk) := p_budget_lines_tbl(kk).projfunc_rev_rate_date_type;
            x_pfunc_rev_rate_tbl.EXTEND(1);
            x_pfunc_rev_rate_tbl(kk)           := p_budget_lines_tbl(kk).projfunc_rev_exchange_rate;
            x_pfunc_rev_rate_date_tbl.EXTEND(1);
            x_pfunc_rev_rate_date_tbl(kk)      := p_budget_lines_tbl(kk).projfunc_rev_rate_date;
            --log1('----- STAGE X76-------');
            x_delete_flag_tbl.EXTEND(1);
            x_delete_flag_tbl(kk)              := p_delete_flag_tbl(kk);
            x_spread_curve_id_tbl.EXTEND(1);
            x_spread_curve_id_tbl(kk)          := p_spread_curve_id_tbl(kk);
            x_mfc_cost_type_id_tbl.EXTEND(1);
            x_mfc_cost_type_id_tbl(kk)         := p_mfc_cost_type_id_tbl(kk);
            x_etc_method_code_tbl.EXTEND(1);
            x_etc_method_code_tbl(kk)          := p_etc_method_code_tbl(kk);
            x_sp_fixed_date_tbl.EXTEND(1);
            x_sp_fixed_date_tbl(kk)            := p_sp_fixed_date_tbl(kk);
            x_res_class_code_tbl.EXTEND(1);
            x_res_class_code_tbl(kk)           := p_res_class_code_tbl(kk);
            x_rate_based_flag_tbl.EXTEND(1);
            x_rate_based_flag_tbl(kk)          := p_rate_based_flag_tbl(kk);
            x_rbs_elem_id_tbl.EXTEND(1);
            x_rbs_elem_id_tbl(kk)              := p_rbs_elem_id_tbl(kk);
            x_change_reason_code_tbl.EXTEND(1);
            x_change_reason_code_tbl(kk)       := p_budget_lines_tbl(kk).change_reason_code;
            x_description_tbl.EXTEND(1);
            x_description_tbl(kk)              := p_budget_lines_tbl(kk).description;
            --log1('----- STAGE X8-------');

            --For forecast version, The above amount tbls contain the Forecast amounts, The below
            --API is called to modify the Forecast amounts entered based on the ETC amounts entered.
            IF p_plan_class_code='FORECAST' THEN

                    get_total_fcst_amounts
                   (p_project_id                    =>p_project_id,
                    p_budget_version_id             =>p_budget_version_id,
                    p_task_id                       =>p_budget_lines_tbl(kk).pa_task_id,
                    p_resource_list_member_id       =>p_budget_lines_tbl(kk).resource_list_member_id,
                    p_txn_currency_code             =>p_budget_lines_tbl(kk).txn_currency_code,
                    p_line_start_date               =>NULL,
                    p_line_end_date                 =>NULL,
                    p_prd_mask_st_date_tbl          =>SYSTEM.pa_date_tbl_type(),
                    p_prd_mask_end_date_tbl         =>SYSTEM.pa_date_tbl_type(),
                    p_st_index_in_prd_mask          =>NULL,
                    p_end_index_in_prd_mask         =>NULL,
                    p_etc_start_date                =>p_etc_start_date,
                    p_etc_quantity                  =>p_etc_quantity_tbl(kk),
                    p_fcst_quantity                 =>p_budget_lines_tbl(kk).quantity,
                    p_etc_raw_cost                  =>p_etc_raw_cost_tbl(kk),
                    p_fcst_raw_cost                 =>p_budget_lines_tbl(kk).raw_cost,
                    p_etc_burd_cost                 =>p_etc_burdened_cost_tbl(kk),
                    p_fcst_burd_cost                =>p_budget_lines_tbl(kk).burdened_cost,
                    p_etc_revenue                   =>p_etc_revenue_tbl(kk),
                    p_fcst_revenue                  =>p_budget_lines_tbl(kk).revenue,
                    px_cached_fcst_qty_tbl          =>l_cached_fcst_qty_tbl,
                    px_cached_fcst_raw_cost_tbl     =>l_cached_fcst_raw_cost_tbl,
                    px_cached_fcst_burd_cost_tbl    =>l_cached_fcst_burd_cost_tbl,
                    px_cached_fcst_revenue_tbl      =>l_cached_fcst_revenue_tbl,
                    px_cached_etc_qty_tbl           =>l_cached_etc_qty_tbl,
                    px_cached_etc_raw_cost_tbl      =>l_cached_etc_raw_cost_tbl,
                    px_cached_etc_burd_cost_tbl     =>l_cached_etc_burd_cost_tbl,
                    px_cached_etc_revenue_tbl       =>l_cached_etc_revenue_tbl,
                    x_total_quantity                =>x_total_qty_tbl(kk),
                    x_total_raw_cost                =>x_total_raw_cost_tbl(kk),
                    x_total_burd_cost               =>x_total_burdened_cost_tbl(kk),
                    x_total_revenue                 =>x_total_revenue_tbl(kk),
                    x_return_status                 =>x_return_status,
                    x_msg_count                     =>x_msg_count,
                    x_msg_data                      =>x_msg_data    );

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Call to get_total_fcst_amounts returned with error';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                         END IF;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                END IF;

        END LOOP;--FOR kk IN 1..p_budget_lines_tbl.COUNT LOOP
        --log1('----- STAGE X9-------');
    END IF; --p_context


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Leaving pa_fp_webadi_pkg.prepare_pbl_input';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.reset_curr_function;
    END IF;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 and x_msg_data IS NULL THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
           x_msg_count := l_msg_count;
        ELSE
           x_msg_count := l_msg_count;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
        END IF;
        RETURN;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                              ,p_procedure_name  => 'prepare_pbl_input');
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
        END IF;

        IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
        END IF;
        RAISE;

END prepare_pbl_input;

PROCEDURE process_budget_lines
( p_context                         IN              VARCHAR2,
  p_budget_version_id               IN              pa_budget_versions.budget_version_id%TYPE,
  p_version_info_rec                IN              pa_fp_gen_amount_utils.fp_cols,
  p_task_id_tbl                     IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_rlm_id_tbl                      IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_ra_id_tbl                       IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_spread_curve_id_tbl             IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_mfc_cost_type_id_tbl            IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_etc_method_code_tbl             IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_sp_fixed_date_tbl               IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_res_class_code_tbl              IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_rate_based_flag_tbl             IN              SYSTEM.pa_varchar2_1_tbl_type    := SYSTEM.pa_varchar2_1_tbl_type(),
  p_rbs_elem_id_tbl                 IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_txn_currency_code_tbl           IN              SYSTEM.pa_varchar2_15_tbl_type   := SYSTEM.pa_varchar2_15_tbl_type(),
  p_planning_start_date_tbl         IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_planning_end_date_tbl           IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_total_qty_tbl                   IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_total_raw_cost_tbl              IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_total_burdened_cost_tbl         IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_total_revenue_tbl               IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_raw_cost_rate_tbl               IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_burdened_cost_rate_tbl          IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_bill_rate_tbl                   IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_line_start_date_tbl             IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_line_end_date_tbl               IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_proj_cost_rate_type_tbl         IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_proj_cost_rate_date_type_tbl    IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_proj_cost_rate_tbl              IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_proj_cost_rate_date_tbl         IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_proj_rev_rate_type_tbl          IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_proj_rev_rate_date_type_tbl     IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_proj_rev_rate_tbl               IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_proj_rev_rate_date_tbl          IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_pfunc_cost_rate_type_tbl        IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_pfunc_cost_rate_date_typ_tbl    IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_pfunc_cost_rate_tbl             IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_pfunc_cost_rate_date_tbl        IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_pfunc_rev_rate_type_tbl         IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_pfunc_rev_rate_date_type_tbl    IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_pfunc_rev_rate_tbl              IN              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type(),
  p_pfunc_rev_rate_date_tbl         IN              SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type(),
  p_change_reason_code_tbl          IN              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type(),
  p_description_tbl                 IN              SYSTEM.pa_varchar2_2000_tbl_type := SYSTEM.pa_varchar2_2000_tbl_type(),
  p_delete_flag_tbl                 IN              SYSTEM.pa_varchar2_1_tbl_type    := SYSTEM.pa_varchar2_1_tbl_type(),
  x_return_status                   OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                       OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                        OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )

IS
      -- variables used for debugging
      l_module_name             VARCHAR2(100) := 'pa_fp_webadi_pkg.process_budget_lines';
      l_debug_mode              VARCHAR2(1) := 'N';
      l_debug_level3            CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
      l_debug_level5            CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;

      l_return_status           VARCHAR2(1);
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2(2000);
      l_data                    VARCHAR2(2000);
      l_msg_index_out           NUMBER;

      -- variables used to copy the inputs and to be used inside the api
      l_task_id_tbl                            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_rlm_id_tbl                             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_ra_id_tbl                              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_spread_curve_id_tbl                    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_mfc_cost_type_id_tbl                   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_etc_method_code_tbl                    SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_sp_fixed_date_tbl                      SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_res_class_code_tbl                     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_rate_based_flag_tbl                    SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_rbs_elem_id_tbl                        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_txn_currency_code_tbl                  SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
      l_planning_start_date_tbl                SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_planning_end_date_tbl                  SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_total_qty_tbl                          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_total_raw_cost_tbl                     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_total_burdened_cost_tbl                SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_total_revenue_tbl                      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_raw_cost_rate_tbl                      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_burdened_cost_rate_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bill_rate_tbl                          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_line_start_date_tbl                    SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_line_end_date_tbl                      SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_proj_cost_rate_type_tbl                SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_proj_cost_rate_date_type_tbl           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_proj_cost_rate_tbl                     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_proj_cost_rate_date_tbl                SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_proj_rev_rate_type_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_proj_rev_rate_date_type_tbl            SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_proj_rev_rate_tbl                      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_proj_rev_rate_date_tbl                 SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_pfunc_cost_rate_type_tbl               SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_pfunc_cost_rate_date_typ_tbl           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_pfunc_cost_rate_tbl                    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_pfunc_cost_rate_date_tbl               SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_pfunc_rev_rate_type_tbl                SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_pfunc_rev_rate_date_type_tbl           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_pfunc_rev_rate_tbl                     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_pfunc_rev_rate_date_tbl                SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_change_reason_code_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_description_tbl                        SYSTEM.pa_varchar2_2000_tbl_type := SYSTEM.pa_varchar2_2000_tbl_type();


      -- variables to copy the records with delete_flag = Y
      l_df_task_id_tbl                         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_rlm_id_tbl                          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_ra_id_tbl                           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_spread_curve_id_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_mfc_cost_type_id_tbl                SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_etc_method_code                     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_sp_fixed_date_tbl                   SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_res_class_code_tbl                  SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_rate_based_flag_tbl                 SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
      l_df_rbs_elem_id_tbl                     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_txn_currency_code_tbl               SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
      l_df_planning_start_date_tbl             SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_planning_end_date_tbl               SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_total_qty_tbl                       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_total_raw_cost_tbl                  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_total_burdened_cost_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_total_revenue_tbl                   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_raw_cost_rate_tbl                   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_burdened_cost_rate_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_bill_rate_tbl                       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_line_start_date_tbl                 SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_line_end_date_tbl                   SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_pj_cost_rate_typ_tbl                SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_pj_cost_rate_date_typ_tbl           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_pj_cost_rate_tbl                    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_pj_cost_rate_date_tbl               SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_pj_rev_rate_typ_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_pj_rev_rate_date_typ_tbl            SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_pj_rev_rate_tbl                     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_pj_rev_rate_date_tbl                SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_pf_cost_rate_typ_tbl                SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_pf_cost_rate_date_typ_tbl           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_pf_cost_rate_tbl                    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_pf_cost_rate_date_tbl               SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_pf_rev_rate_typ_tbl                 SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_pf_rev_rate_date_typ_tbl            SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_pf_rev_rate_tbl                     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_df_pf_rev_rate_date_tbl                SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_df_change_reason_code_tbl              SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_df_description_tbl                     SYSTEM.pa_varchar2_2000_tbl_type := SYSTEM.pa_varchar2_2000_tbl_type();

      l_total_rec_passed        INTEGER := 0;
      l_curr_ra_id_seq          NUMBER;

      -- counter variables
      i                         INTEGER;

      -- variables used to call add_planning_transactions
      l_new_elem_ver_id             pa_proj_element_versions.element_version_id%TYPE;
      l_new_elem_ver_id_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_new_rlm_id_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_new_planning_start_date_tbl SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_new_planning_end_date_tbl   SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();

      -- variables used to insert into pa_fp_rollup_tmp
      -- with delete flag = Y
      l_bl_del_flag_ra_id_tbl            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_st_dt_tbl            SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_bl_del_flag_en_dt_tbl            SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_bl_del_flag_txn_curr_tbl         SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
      l_bl_del_flag_txn_rc_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_txn_bc_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_txn_rev_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_pf_curr_tbl          SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
      l_bl_del_flag_pf_cr_typ_tbl        SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pf_cr_dt_typ_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pf_cexc_rate_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_pf_cr_date_tbl       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_bl_del_flag_pf_rr_typ_tbl        SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pf_rr_dt_typ_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pf_rexc_rate_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_pf_rr_date_tbl       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_bl_del_flag_pj_curr_tbl          SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
      l_bl_del_flag_pj_cr_typ_tbl        SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pj_cr_dt_typ_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pj_cexc_rate_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_pj_cr_date_tbl       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_bl_del_flag_pj_rr_typ_tbl        SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pj_rr_dt_typ_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pj_rexc_rate_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_pj_rr_date_tbl       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
      l_bl_del_flag_bl_id_tbl            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_per_name_tbl         SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_pj_raw_cost_tbl      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_pj_burd_cost_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_pj_rev_tbl           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_raw_cost_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_burd_cost_tbl        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_rev_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_qty_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_bl_del_flag_c_rej_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_b_rej_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_r_rej_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_flag_o_rej_code_tbl       SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_fg_pc_cnv_rej_cd_tbl      SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
      l_bl_del_fg_pf_cnv_rej_cd_tbl      SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();


          -- for budget line context to spread the amounts
      l_new_ra_id                           pa_resource_assignments.resource_assignment_id%TYPE;
      l_calc_calling_context                VARCHAR2(30);

      -- variables used to call update_reporting_lines
      l_pji_res_ass_id_tbl                 SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_period_name_tbl                SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_pji_start_date_tbl                 SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type();
      l_pji_end_date_tbl                   SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type();
      l_pji_txn_curr_code_tbl              SYSTEM.pa_varchar2_15_tbl_type   := SYSTEM.pa_varchar2_15_tbl_type();
      l_pji_txn_raw_cost_tbl               SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_txn_burd_cost_tbl              SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_txn_revenue_tbl                SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_project_raw_cost_tbl           SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_project_burd_cost_tbl          SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_project_revenue_tbl            SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_raw_cost_tbl                   SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_burd_cost_tbl                  SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_revenue_tbl                    SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_pji_cost_rej_code_tbl              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_pji_revenue_rej_code_tbl           SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_pji_burden_rej_code_tbl            SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_pji_other_rej_code                 SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_pji_pc_cur_conv_rej_code_tbl       SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_pji_pf_cur_conv_rej_code_tbl       SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_pji_quantity_tbl                   SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();

      --This table will hold the distinct NEW resource assignments passed to this API for processing (excluding delete flag = Y recs)
      --Index will be in the following format : 'T' || <Task Id> || 'R' || <Rlm Id>
      l_distinct_new_ra_tbl                varchar_32_indexed_num_tbl_typ;
      l_distinct_new_ra_index              VARCHAR2(32);


      l_new_res_asg_rbs_elem_id         pa_resource_assignments.rbs_element_id%TYPE;
      l_new_res_asg_res_class_code      pa_resource_assignments.resource_class_code%TYPE;
      l_new_res_asg_rate_based_flag     pa_resource_assignments.rate_based_flag%TYPE;

      l_g_miss_char   CONSTANT      VARCHAR(1)  := FND_API.G_MISS_CHAR;
      l_g_miss_num    CONSTANT      NUMBER      := FND_API.G_MISS_NUM;
      l_g_miss_date   CONSTANT      DATE        := FND_API.G_MISS_DATE;

      l_debug_st_dt  DATE;
      l_debug_en_dt  DATE;
      l_debug_st_dt_tbl      SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type();
      l_debug_en_dt_tbl      SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type();

      l_debug_quantity           NUMBER;
      l_debug_quantity_tbl       SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_debug_raw_cost           NUMBER;
      l_debug_raw_cost_tbl       SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_debug_burdened_cost      NUMBER;
      l_debug_burdened_cost_tbl  SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_debug_revenue            NUMBER;
      l_debug_revenue_tbl        SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_temp                     VARCHAR2(100);
      l_upd_init_quantity_tbl            SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_init_raw_cost_tbl            SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_init_burdened_cost_tbl       SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_init_revenue_tbl             SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_proj_init_raw_cost_tbl       SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_proj_init_burd_cost_tbl      SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_proj_init_revenue_tbl        SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_txn_init_raw_cost_tbl        SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_txn_init_burd_cost_tbl       SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_txn_init_revenue_tbl         SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_budget_line_id_tbl           SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_delete_flag_tbl              SYSTEM.pa_varchar2_1_tbl_type    := SYSTEM.pa_varchar2_1_tbl_type();
      l_upd_pj_cost_rate_typ_tbl         SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_upd_pj_cost_exc_rate_tbl         SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_pj_cost_rate_dt_typ_tbl      SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_upd_pj_cost_rate_date_tbl        SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type();
      l_upd_pj_rev_rate_typ_tbl          SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_upd_pj_rev_exc_rate_tbl          SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_pj_rev_rate_dt_typ_tbl       SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_upd_pj_rev_rate_date_tbl         SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type();
      l_upd_pf_cost_rate_typ_tbl         SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_upd_pf_cost_exc_rate_tbl         SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_pf_cost_rate_dt_typ_tbl      SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_upd_pf_cost_rate_date_tbl        SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type();
      l_upd_pf_rev_rate_typ_tbl          SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_upd_pf_rev_exc_rate_tbl          SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_upd_pf_rev_rate_dt_typ_tbl       SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_upd_pf_rev_rate_date_tbl         SYSTEM.pa_date_tbl_type          := SYSTEM.pa_date_tbl_type();
      --Bug 4424457
      l_bl_count_tbl                     SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_bls_proccessed_flag              VARCHAR2(1);
      l_error_msg_code                   VARCHAR2(2000);
      l_dest_ver_id_tbl                  SYSTEM.pa_num_tbl_type           := SYSTEM.pa_num_tbl_type();
      l_chg_reason_code_tbl              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_desc_tbl                         SYSTEM.pa_varchar2_2000_tbl_type := SYSTEM.pa_varchar2_2000_tbl_type();

      --bug 5962744
      l_extra_bl_flag_tbl                SYSTEM.pa_varchar2_1_tbl_type    := SYSTEM.pa_varchar2_1_tbl_type();
      l_ex_chg_rsn_code_tbl              SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
      l_ex_desc_tbl                      SYSTEM.pa_varchar2_2000_tbl_type := SYSTEM.pa_varchar2_2000_tbl_type();
      l_ra_exists                        VARCHAR2(1);
      l_extra_bls_exists                 VARCHAR2(1);
      j                                  INTEGER;
BEGIN
        --log1('PBL Begin '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        fnd_profile.get('PA_DEBUG_MODE', l_debug_mode);

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        --log1('----- STAGE PBL1.0-------');

        IF l_debug_mode = 'Y' THEN
              pa_debug.Set_Curr_Function
                          (p_function   => l_module_name,
                           p_debug_mode => l_debug_mode);
        END IF;

        IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Entering into process_budget_lines';
              pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
              pa_debug.g_err_stage := 'Validating input parameters';
              pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
        END IF;

        -- validate the mandatory input parameters

        -- valid p_context are WEBADI_PERIODIC and WEBADI_NON_PERIODIC
        IF p_context IS NULL THEN
              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'p_context is passed as null';
                   pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
              END IF;
              pa_utils.add_message(p_app_short_name   => 'PA',
                                   p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                                   p_token1           => 'PROCEDURENAME',
                                   p_value1           => l_module_name);

              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- budget_version_id is not passed
        IF p_budget_version_id IS NULL THEN
              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'p_budget_version_id is passed as null';
                   pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
              END IF;
              pa_utils.add_message(p_app_short_name   => 'PA',
                                   p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                                   p_token1           => 'PROCEDURENAME',
                                   p_value1           => l_module_name);

              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        -- version_info_rec type is null
        IF p_version_info_rec.x_project_id IS NULL THEN
              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'p_version_info_rec is passed as null';
                   pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
              END IF;
              pa_utils.add_message(p_app_short_name   => 'PA',
                                   p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                                   p_token1           => 'PROCEDURENAME',
                                   p_value1           => l_module_name);

              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- if no data is present in the task id table
        IF NOT p_task_id_tbl.EXISTS(1) THEN
              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'task id table is passed as null';
                   pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
              END IF;
              RETURN;
        END IF;

        --log1('----- STAGE PBL1.1-------');
        /*FOR zz IN 1..p_ra_id_tbl.COUNT LOOP

            log1('p_ra_id_tbl ('||zz||') is '||p_ra_id_tbl(zz));
            log1('p_planning_start_date_tbl ('||zz||') is '||p_planning_start_date_tbl(zz));
            log1('p_planning_end_date_tbl ('||zz||') is '||p_planning_end_date_tbl(zz));

        end loop;*/

        -- the length of all the input tables should be same
        IF p_task_id_tbl.COUNT <> p_rlm_id_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_ra_id_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_txn_currency_code_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_planning_start_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_planning_end_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_line_start_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_line_end_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_spread_curve_id_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_mfc_cost_type_id_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_etc_method_code_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_sp_fixed_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_res_class_code_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_rate_based_flag_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_rbs_elem_id_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_total_qty_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_total_raw_cost_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_total_burdened_cost_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_total_revenue_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_raw_cost_rate_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_burdened_cost_rate_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_bill_rate_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_line_start_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_line_end_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_proj_cost_rate_type_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_proj_cost_rate_date_type_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_proj_cost_rate_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_proj_cost_rate_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_proj_rev_rate_type_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_proj_rev_rate_date_type_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_proj_rev_rate_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_proj_rev_rate_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_pfunc_cost_rate_type_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_pfunc_cost_rate_date_typ_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_pfunc_cost_rate_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_pfunc_cost_rate_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_pfunc_rev_rate_type_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_pfunc_rev_rate_date_type_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_pfunc_rev_rate_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_pfunc_rev_rate_date_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_change_reason_code_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_description_tbl.COUNT OR
           p_task_id_tbl.COUNT <> p_delete_flag_tbl.COUNT THEN

            --log1(' 1 '||p_rlm_id_tbl.COUNT);
            --log1(' 2 '||p_ra_id_tbl.COUNT);
            --log1(' 3 '||p_txn_currency_code_tbl.COUNT);
            --log1(' 4 '||p_planning_start_date_tbl.COUNT);
            --log1(' 5 '||p_planning_end_date_tbl.COUNT);
            --log1(' 6 '||p_line_start_date_tbl.COUNT);
            --log1(' 7 '||p_line_end_date_tbl.COUNT);
            --log1(' 8 '||p_spread_curve_id_tbl.COUNT);
            --log1(' 9 '||p_mfc_cost_type_id_tbl.COUNT);
            --log1(' 10 '||p_etc_method_code_tbl.COUNT);
            --log1(' 11 '||p_sp_fixed_date_tbl.COUNT);
            --log1(' 12 '||p_total_qty_tbl.COUNT);
            --log1(' 13 '||p_total_raw_cost_tbl.COUNT);
            --log1(' 14 '||p_total_burdened_cost_tbl.COUNT);
            --log1(' 15 '||p_total_revenue_tbl.COUNT);
            --log1(' 16 '||p_raw_cost_rate_tbl.COUNT);
            --log1(' 17 '||p_burdened_cost_rate_tbl.COUNT);
            --log1(' 18 '||p_bill_rate_tbl.COUNT);
            --log1(' 19 '||p_line_start_date_tbl.COUNT);
            --log1(' 20 '||p_line_end_date_tbl.COUNT);
            --log1(' 21 '||p_proj_cost_rate_type_tbl.COUNT);
            --log1(' 22 '||p_proj_cost_rate_date_type_tbl.COUNT);
            --log1(' 23 '||p_proj_cost_rate_tbl.COUNT);
            --log1(' 24 '||p_proj_cost_rate_date_tbl.COUNT);
            --log1(' 25 '||p_proj_rev_rate_type_tbl.COUNT);
            --log1(' 26 '||p_proj_rev_rate_date_type_tbl.COUNT);
            --log1(' 27 '||p_proj_rev_rate_tbl.COUNT);
            --log1(' 28 '||p_proj_rev_rate_date_tbl.COUNT);
            --log1(' 29 '||p_pfunc_cost_rate_type_tbl.COUNT);
            --log1(' 30 '||p_pfunc_cost_rate_date_typ_tbl.COUNT);
            --log1(' 31 '||p_pfunc_cost_rate_tbl.COUNT);
            --log1(' 32 '||p_pfunc_cost_rate_date_tbl.COUNT);
            --log1(' 33 '||p_pfunc_rev_rate_type_tbl.COUNT);
            --log1(' 34 '||p_pfunc_rev_rate_date_type_tbl.COUNT);
            --log1(' 35 '||p_pfunc_rev_rate_tbl.COUNT);
            --log1(' 36 '||p_pfunc_rev_rate_date_tbl.COUNT);
            --log1(' 37 '||p_change_reason_code_tbl.COUNT);
            --log1(' 38 '||p_description_tbl.COUNT);
            --log1(' 39 '||p_delete_flag_tbl.COUNT );

              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Required input tables are not equal in length';
                   pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
              END IF;
              pa_utils.add_message(p_app_short_name   => 'PA',
                                   p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                                   p_token1           => 'PROCEDURENAME',
                                   p_value1           => l_module_name);

              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        --log1('----- STAGE PBL1.2-------');

        -- input parameters validation done

        -- checking for the context and if its non periodic context, then
        -- filtering out the records with delete flag <> Y
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'p_context is: ' || p_context;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        --log1('PBL 1 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        IF p_context = 'WEBADI_NON_PERIODIC' THEN
            FOR i IN p_task_id_tbl.FIRST .. p_task_id_tbl.LAST LOOP
                  IF Nvl(p_delete_flag_tbl(i), 'N') <> 'Y' THEN
                        l_ra_id_tbl.extend(1);
                        l_ra_id_tbl(l_ra_id_tbl.COUNT)                                        := p_ra_id_tbl(i);
                        l_task_id_tbl.EXTEND(1);
                        l_task_id_tbl(l_task_id_tbl.COUNT)                                    := p_task_id_tbl(i);
                        l_rlm_id_tbl.EXTEND(1);
                        l_rlm_id_tbl(l_rlm_id_tbl.COUNT)                                      := p_rlm_id_tbl(i);
                        l_spread_curve_id_tbl.EXTEND(1);
                        l_spread_curve_id_tbl(l_spread_curve_id_tbl.COUNT)                    := p_spread_curve_id_tbl(i);
                        l_mfc_cost_type_id_tbl.EXTEND(1);
                        l_mfc_cost_type_id_tbl(l_mfc_cost_type_id_tbl.COUNT)                  := p_mfc_cost_type_id_tbl(i);
                        l_etc_method_code_tbl.EXTEND(1);
                        l_etc_method_code_tbl(l_etc_method_code_tbl.COUNT)                    := p_etc_method_code_tbl(i);
                        l_sp_fixed_date_tbl.EXTEND(1);
                        l_sp_fixed_date_tbl(l_sp_fixed_date_tbl.COUNT)                        := p_sp_fixed_date_tbl(i);
                        l_res_class_code_tbl.EXTEND(1);
                        l_res_class_code_tbl(l_res_class_code_tbl.COUNT)                      := p_res_class_code_tbl(i);
                        l_rate_based_flag_tbl.EXTEND(1);
                        l_rate_based_flag_tbl(l_rate_based_flag_tbl.COUNT)                    := p_rate_based_flag_tbl(i);
                        l_rbs_elem_id_tbl.EXTEND(1);
                        l_rbs_elem_id_tbl(l_rbs_elem_id_tbl.COUNT)                            := p_rbs_elem_id_tbl(i);
                        l_txn_currency_code_tbl.EXTEND(1);
                        l_txn_currency_code_tbl(l_txn_currency_code_tbl.COUNT)                := p_txn_currency_code_tbl(i);
                        l_planning_start_date_tbl.EXTEND(1);
                        l_planning_start_date_tbl(l_planning_start_date_tbl.COUNT)            := p_planning_start_date_tbl(i);
                        l_planning_end_date_tbl.EXTEND(1);
                        l_planning_end_date_tbl(l_planning_end_date_tbl.COUNT)                := p_planning_end_date_tbl(i);
                        l_total_qty_tbl.EXTEND(1);
                        l_total_qty_tbl(l_total_qty_tbl.COUNT)                                := p_total_qty_tbl(i);
                        l_total_raw_cost_tbl.EXTEND(1);
                        l_total_raw_cost_tbl(l_total_raw_cost_tbl.COUNT)                      := p_total_raw_cost_tbl(i);
                        l_total_burdened_cost_tbl.EXTEND(1);
                        l_total_burdened_cost_tbl(l_total_burdened_cost_tbl.COUNT)            := p_total_burdened_cost_tbl(i);
                        l_total_revenue_tbl.EXTEND(1);
                        l_total_revenue_tbl(l_total_revenue_tbl.COUNT)                        := p_total_revenue_tbl(i);
                        l_raw_cost_rate_tbl.EXTEND(1);
                        l_raw_cost_rate_tbl(l_raw_cost_rate_tbl.COUNT)                        := p_raw_cost_rate_tbl(i);
                        l_burdened_cost_rate_tbl.EXTEND(1);
                        l_burdened_cost_rate_tbl(l_burdened_cost_rate_tbl.COUNT)              := p_burdened_cost_rate_tbl(i);
                        l_bill_rate_tbl.EXTEND(1);
                        l_bill_rate_tbl(l_bill_rate_tbl.COUNT)                                := p_bill_rate_tbl(i);
                        l_proj_cost_rate_type_tbl.EXTEND(1);
                        l_proj_cost_rate_type_tbl(l_proj_cost_rate_type_tbl.COUNT)            := p_proj_cost_rate_type_tbl(i);
                        l_proj_cost_rate_date_type_tbl.EXTEND(1);
                        l_proj_cost_rate_date_type_tbl(l_proj_cost_rate_date_type_tbl.COUNT)  := p_proj_cost_rate_date_type_tbl(i);
                        l_proj_cost_rate_tbl.EXTEND(1);
                        l_proj_cost_rate_tbl(l_proj_cost_rate_tbl.COUNT)                      := p_proj_cost_rate_tbl(i);
                        l_proj_cost_rate_date_tbl.EXTEND(1);
                        l_proj_cost_rate_date_tbl(l_proj_cost_rate_date_tbl.COUNT)            := p_proj_cost_rate_date_tbl(i);
                        l_proj_rev_rate_type_tbl.EXTEND(1);
                        l_proj_rev_rate_type_tbl(l_proj_rev_rate_type_tbl.COUNT)              := p_proj_rev_rate_type_tbl(i);
                        l_proj_rev_rate_date_type_tbl.EXTEND(1);
                        l_proj_rev_rate_date_type_tbl(l_proj_rev_rate_date_type_tbl.COUNT)    := p_proj_rev_rate_date_type_tbl(i);
                        l_proj_rev_rate_tbl.EXTEND(1);
                        l_proj_rev_rate_tbl(l_proj_rev_rate_tbl.COUNT)                        := p_proj_rev_rate_tbl(i);
                        l_proj_rev_rate_date_tbl.EXTEND(1);
                        l_proj_rev_rate_date_tbl(l_proj_rev_rate_date_tbl.COUNT)              := p_proj_rev_rate_date_tbl(i);
                        l_pfunc_cost_rate_type_tbl.EXTEND(1);
                        l_pfunc_cost_rate_type_tbl(l_pfunc_cost_rate_type_tbl.COUNT)          := p_pfunc_cost_rate_type_tbl(i);
                        l_pfunc_cost_rate_date_typ_tbl.EXTEND(1);
                        l_pfunc_cost_rate_date_typ_tbl(l_pfunc_cost_rate_date_typ_tbl.COUNT)  := p_pfunc_cost_rate_date_typ_tbl(i);
                        l_pfunc_cost_rate_tbl.EXTEND(1);
                        l_pfunc_cost_rate_tbl(l_pfunc_cost_rate_tbl.COUNT)                    := p_pfunc_cost_rate_tbl(i);
                        l_pfunc_cost_rate_date_tbl.EXTEND(1);
                        l_pfunc_cost_rate_date_tbl(l_pfunc_cost_rate_date_tbl.COUNT)          := p_pfunc_cost_rate_date_tbl(i);
                        l_pfunc_rev_rate_type_tbl.EXTEND(1);
                        l_pfunc_rev_rate_type_tbl(l_pfunc_rev_rate_type_tbl.COUNT)            := p_pfunc_rev_rate_type_tbl(i);
                        l_pfunc_rev_rate_date_type_tbl.EXTEND(1);
                        l_pfunc_rev_rate_date_type_tbl(l_pfunc_rev_rate_date_type_tbl.COUNT)  := p_pfunc_rev_rate_date_type_tbl(i);
                        l_pfunc_rev_rate_tbl.EXTEND(1);
                        l_pfunc_rev_rate_tbl(l_pfunc_rev_rate_tbl.COUNT)                      := p_pfunc_rev_rate_tbl(i);
                        l_pfunc_rev_rate_date_tbl.EXTEND(1);
                        l_pfunc_rev_rate_date_tbl(l_pfunc_rev_rate_date_tbl.COUNT)            := p_pfunc_rev_rate_date_tbl(i);
                        l_change_reason_code_tbl.EXTEND(1);
                        l_change_reason_code_tbl(l_change_reason_code_tbl.COUNT)              := p_change_reason_code_tbl(i);
                        l_description_tbl.EXTEND(1);
                        l_description_tbl(l_description_tbl.COUNT)                            := p_description_tbl(i);

                  ELSIF Nvl(p_delete_flag_tbl(i), 'N') = 'Y' THEN
                        -- if the delete flag is Y then collecting them separately
                        l_df_ra_id_tbl.EXTEND(1);
                        l_df_ra_id_tbl(l_df_ra_id_tbl.COUNT)                                  := p_ra_id_tbl(i);
                        l_df_task_id_tbl.EXTEND(1);
                        l_df_task_id_tbl(l_df_task_id_tbl.COUNT)                              := p_task_id_tbl(i);
                        l_df_rlm_id_tbl.EXTEND(1);
                        l_df_rlm_id_tbl(l_df_rlm_id_tbl.COUNT)                                := p_rlm_id_tbl(i);
                        l_df_spread_curve_id_tbl.EXTEND(1);
                        l_df_spread_curve_id_tbl(l_df_spread_curve_id_tbl.COUNT)              := p_spread_curve_id_tbl(i);
                        l_df_mfc_cost_type_id_tbl.EXTEND(1);
                        l_df_mfc_cost_type_id_tbl(l_df_mfc_cost_type_id_tbl.COUNT)            := p_mfc_cost_type_id_tbl(i);
                        l_df_etc_method_code.EXTEND(1);
                        l_df_etc_method_code(l_df_etc_method_code.COUNT)                      := p_etc_method_code_tbl(i);
                        l_df_sp_fixed_date_tbl.EXTEND(1);
                        l_df_sp_fixed_date_tbl(l_df_sp_fixed_date_tbl.COUNT)                  := p_sp_fixed_date_tbl(i);
                        l_df_res_class_code_tbl.EXTEND(1);
                        l_df_res_class_code_tbl(l_df_res_class_code_tbl.COUNT)                := p_res_class_code_tbl(i);
                        l_df_rate_based_flag_tbl.EXTEND(1);
                        l_df_rate_based_flag_tbl(l_df_rate_based_flag_tbl.COUNT)              := p_rate_based_flag_tbl(i);
                        l_df_rbs_elem_id_tbl.EXTEND(1);
                        l_df_rbs_elem_id_tbl(l_df_rbs_elem_id_tbl.COUNT)                      := p_rbs_elem_id_tbl(i);
                        l_df_txn_currency_code_tbl.EXTEND(1);
                        l_df_txn_currency_code_tbl(l_df_txn_currency_code_tbl.COUNT)          := p_txn_currency_code_tbl(i);
                        l_df_planning_start_date_tbl.EXTEND(1);
                        l_df_planning_start_date_tbl(l_df_planning_start_date_tbl.COUNT)      := p_planning_start_date_tbl(i);
                        l_df_planning_end_date_tbl.EXTEND(1);
                        l_df_planning_end_date_tbl(l_df_planning_end_date_tbl.COUNT)          := p_planning_end_date_tbl(i);
                        l_df_total_qty_tbl.EXTEND(1);
                        l_df_total_qty_tbl(l_df_total_qty_tbl.COUNT)                          := p_total_qty_tbl(i);
                        l_df_total_raw_cost_tbl.EXTEND(1);
                        l_df_total_raw_cost_tbl(l_df_total_raw_cost_tbl.COUNT)                := p_total_raw_cost_tbl(i);
                        l_df_total_burdened_cost_tbl.EXTEND(1);
                        l_df_total_burdened_cost_tbl(l_df_total_burdened_cost_tbl.COUNT)      := p_total_burdened_cost_tbl(i);
                        l_df_total_revenue_tbl.EXTEND(1);
                        l_df_total_revenue_tbl(l_df_total_revenue_tbl.COUNT)                  := p_total_revenue_tbl(i);
                        l_df_raw_cost_rate_tbl.EXTEND(1);
                        l_df_raw_cost_rate_tbl(l_df_raw_cost_rate_tbl.COUNT)                  := p_raw_cost_rate_tbl(i);
                        l_df_burdened_cost_rate_tbl.EXTEND(1);
                        l_df_burdened_cost_rate_tbl(l_df_burdened_cost_rate_tbl.COUNT)        := p_burdened_cost_rate_tbl(i);
                        l_df_bill_rate_tbl.EXTEND(1);
                        l_df_bill_rate_tbl(l_df_bill_rate_tbl.COUNT)                          := p_bill_rate_tbl(i);
                        l_df_line_start_date_tbl.EXTEND(1);
                        l_df_line_start_date_tbl(l_df_line_start_date_tbl.COUNT)              := p_line_start_date_tbl(i);
                        l_df_line_end_date_tbl.EXTEND(1);
                        l_df_line_end_date_tbl(l_df_line_end_date_tbl.COUNT)                  := p_line_end_date_tbl(i);
                        l_df_pj_cost_rate_typ_tbl.EXTEND(1);
                        l_df_pj_cost_rate_typ_tbl(l_df_pj_cost_rate_typ_tbl.COUNT)            := p_proj_cost_rate_type_tbl(i);
                        l_df_pj_cost_rate_date_typ_tbl.EXTEND(1);
                        l_df_pj_cost_rate_date_typ_tbl(l_df_pj_cost_rate_date_typ_tbl.COUNT)  := p_proj_cost_rate_date_type_tbl(i);
                        l_df_pj_cost_rate_tbl.EXTEND(1);
                        l_df_pj_cost_rate_tbl(l_df_pj_cost_rate_tbl.COUNT)                    := p_proj_cost_rate_tbl(i);
                        l_df_pj_cost_rate_date_tbl.EXTEND(1);
                        l_df_pj_cost_rate_date_tbl(l_df_pj_cost_rate_date_tbl.COUNT)          := p_proj_cost_rate_date_tbl(i);
                        l_df_pj_rev_rate_typ_tbl.EXTEND(1);
                        l_df_pj_rev_rate_typ_tbl(l_df_pj_rev_rate_typ_tbl.COUNT)              := p_proj_rev_rate_type_tbl(i);
                        l_df_pj_rev_rate_date_typ_tbl.EXTEND(1);
                        l_df_pj_rev_rate_date_typ_tbl(l_df_pj_rev_rate_date_typ_tbl.COUNT)    := p_proj_rev_rate_date_type_tbl(i);
                        l_df_pj_rev_rate_tbl.EXTEND(1);
                        l_df_pj_rev_rate_tbl(l_df_pj_rev_rate_tbl.COUNT)                      := p_proj_rev_rate_tbl(i);
                        l_df_pj_rev_rate_date_tbl.EXTEND(1);
                        l_df_pj_rev_rate_date_tbl(l_df_pj_rev_rate_date_tbl.COUNT)            := p_proj_rev_rate_date_tbl(i);
                        l_df_pf_cost_rate_typ_tbl.EXTEND(1);
                        l_df_pf_cost_rate_typ_tbl(l_df_pf_cost_rate_typ_tbl.COUNT)            := p_pfunc_cost_rate_type_tbl(i);
                        l_df_pf_cost_rate_date_typ_tbl.EXTEND(1);
                        l_df_pf_cost_rate_date_typ_tbl(l_df_pf_cost_rate_date_typ_tbl.COUNT)  := p_pfunc_cost_rate_date_typ_tbl(i);
                        l_df_pf_cost_rate_tbl.EXTEND(1);
                        l_df_pf_cost_rate_tbl(l_df_pf_cost_rate_tbl.COUNT)                    := p_pfunc_cost_rate_tbl(i);
                        l_df_pf_cost_rate_date_tbl.EXTEND(1);
                        l_df_pf_cost_rate_date_tbl(l_df_pf_cost_rate_date_tbl.COUNT)          := p_pfunc_cost_rate_date_tbl(i);
                        l_df_pf_rev_rate_typ_tbl.EXTEND(1);
                        l_df_pf_rev_rate_typ_tbl(l_df_pf_rev_rate_typ_tbl.COUNT)              := p_pfunc_rev_rate_type_tbl(i);
                        l_df_pf_rev_rate_date_typ_tbl.EXTEND(1);
                        l_df_pf_rev_rate_date_typ_tbl(l_df_pf_rev_rate_date_typ_tbl.COUNT)    := p_pfunc_rev_rate_date_type_tbl(i);
                        l_df_pf_rev_rate_tbl.EXTEND(1);
                        l_df_pf_rev_rate_tbl(l_df_pf_rev_rate_tbl.COUNT)                      := p_pfunc_rev_rate_tbl(i);
                        l_df_pf_rev_rate_date_tbl.EXTEND(1);
                        l_df_pf_rev_rate_date_tbl(l_df_pf_rev_rate_date_tbl.COUNT)            := p_pfunc_rev_rate_date_tbl(i);
                        l_df_change_reason_code_tbl.EXTEND(1);
                        l_df_change_reason_code_tbl(l_df_change_reason_code_tbl.COUNT)        := p_change_reason_code_tbl(i);
                        l_df_description_tbl.EXTEND(1);
                        l_df_description_tbl(l_df_description_tbl.COUNT)                      := p_description_tbl(i);
                  END IF; -- delete_flag
            END LOOP;
        ELSE  -- periodic, considering all the records passed
              l_task_id_tbl                      := p_task_id_tbl;
              l_rlm_id_tbl                       := p_rlm_id_tbl;
              l_ra_id_tbl                        := p_ra_id_tbl;
              l_txn_currency_code_tbl            := p_txn_currency_code_tbl;
              l_planning_start_date_tbl          := p_planning_start_date_tbl;
              l_planning_end_date_tbl            := p_planning_end_date_tbl;
              l_spread_curve_id_tbl              := p_spread_curve_id_tbl;
              l_mfc_cost_type_id_tbl             := p_mfc_cost_type_id_tbl;
              l_etc_method_code_tbl              := p_etc_method_code_tbl;
              l_sp_fixed_date_tbl                := p_sp_fixed_date_tbl;
              l_res_class_code_tbl               := p_res_class_code_tbl;
              l_rate_based_flag_tbl              := p_rate_based_flag_tbl;
              l_rbs_elem_id_tbl                  := p_rbs_elem_id_tbl;
              l_total_qty_tbl                    := p_total_qty_tbl;
              l_total_raw_cost_tbl               := p_total_raw_cost_tbl;
              l_total_burdened_cost_tbl          := p_total_burdened_cost_tbl;
              l_total_revenue_tbl                := p_total_revenue_tbl;
              l_raw_cost_rate_tbl                := p_raw_cost_rate_tbl;
              l_burdened_cost_rate_tbl           := p_burdened_cost_rate_tbl;
              l_bill_rate_tbl                    := p_bill_rate_tbl;
              l_line_start_date_tbl              := p_line_start_date_tbl;
              l_line_end_date_tbl                := p_line_end_date_tbl;
              l_proj_cost_rate_type_tbl          := p_proj_cost_rate_type_tbl;
              l_proj_cost_rate_date_type_tbl     := p_proj_cost_rate_date_type_tbl;
              l_proj_cost_rate_tbl               := p_proj_cost_rate_tbl;
              l_proj_cost_rate_date_tbl          := p_proj_cost_rate_date_tbl;
              l_proj_rev_rate_type_tbl           := p_proj_rev_rate_type_tbl;
              l_proj_rev_rate_date_type_tbl      := p_proj_rev_rate_date_type_tbl;
              l_proj_rev_rate_tbl                := p_proj_rev_rate_tbl;
              l_proj_rev_rate_date_tbl           := p_proj_rev_rate_date_tbl;
              l_pfunc_cost_rate_type_tbl         := p_pfunc_cost_rate_type_tbl;
              l_pfunc_cost_rate_date_typ_tbl     := p_pfunc_cost_rate_date_typ_tbl;
              l_pfunc_cost_rate_tbl              := p_pfunc_cost_rate_tbl;
              l_pfunc_cost_rate_date_tbl         := p_pfunc_cost_rate_date_tbl;
              l_pfunc_rev_rate_type_tbl          := p_pfunc_rev_rate_type_tbl;
              l_pfunc_rev_rate_date_type_tbl     := p_pfunc_rev_rate_date_type_tbl;
              l_pfunc_rev_rate_tbl               := p_pfunc_rev_rate_tbl;
              l_pfunc_rev_rate_date_tbl          := p_pfunc_rev_rate_date_tbl;
              l_change_reason_code_tbl           := p_change_reason_code_tbl;
              l_description_tbl                  := p_description_tbl;
        END IF; -- p_context
        --log1('PBL 2 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

        --log1('----- STAGE PBL1.3-------');
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Input parameters are copied to local variables';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             pa_debug.g_err_stage := 'Checking for existing RAs';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        --log1('PBL 3 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        -- noting down the number of records passed
        l_total_rec_passed := p_task_id_tbl.COUNT;
        --log1('----- STAGE PBL1.4-------');
        FOR i IN 1..l_ra_id_tbl.COUNT LOOP
             -- checking for existing RAs
             -- firing the select only if it has not been done for the task-resource combination
             l_distinct_new_ra_index:= 'T'||l_task_id_tbl(i)||'R'||l_rlm_id_tbl(i);
             IF l_ra_id_tbl(i) IS NULL AND
                (NOT l_distinct_new_ra_tbl.EXISTS(l_distinct_new_ra_index)) THEN

                   --log1('----- STAGE PBL2-------');
                   --Populate the l_distinct_new_ra_tbl for the index corresponding to the Task/Rlm
                   --with the value 0 to indicate the Task/Rlm has already been selected as input
                   --for insertion
                   l_distinct_new_ra_tbl(l_distinct_new_ra_index):=0;
                   IF l_task_id_tbl(i) <> 0 THEN
                           --Copy input params for add i.e derive the element version id,rlm id
                           -- selecting element_version_id
                           BEGIN
                                 SELECT  pev.element_version_id
                                 INTO    l_new_elem_ver_id
                                 FROM    pa_proj_element_versions pev
                                 WHERE   pev.proj_element_id = l_task_id_tbl(i)
                                 AND     pev.parent_structure_version_id = p_version_info_rec.x_project_structure_version_id;
                                 --log1('----- STAGE PBL5-------');
                           EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                       --log1('----- STAGE PBL6-------');
                                       IF l_debug_mode = 'Y' THEN
                                            pa_debug.g_err_stage := 'No Elem Version Id found for the task id passed';
                                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                       END IF;
                                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                           END;
                   ELSE
                        -- for project level plannings
                        l_new_elem_ver_id := 0;
                   END IF;
                   --log1('----- STAGE PBL7-------');
                   -- populating the other required inputs for add_plan_txn
                   l_new_elem_ver_id_tbl.EXTEND(1);
                   l_new_elem_ver_id_tbl(l_new_elem_ver_id_tbl.COUNT) := l_new_elem_ver_id;
                   l_new_rlm_id_tbl.EXTEND(1);
                   l_new_rlm_id_tbl(l_new_rlm_id_tbl.COUNT) := l_rlm_id_tbl(i);
                   l_new_planning_start_date_tbl.EXTEND(1);
                   l_new_planning_start_date_tbl(l_new_planning_start_date_tbl.COUNT) := l_planning_start_date_tbl(i);
                   l_new_planning_end_date_tbl.EXTEND(1);
                   l_new_planning_end_date_tbl(l_new_planning_end_date_tbl.COUNT) := l_planning_end_date_tbl(i);

                   --log1('----- STAGE PBL9-------');
             END IF; /* if RA is null at index */
             --log1('----- STAGE PBL11-------');
        END LOOP;
        --log1('PBL 4 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        --log1('PBL 4.1 '||l_new_elem_ver_id_tbl.COUNT );
        --log1('----- STAGE PBL11.7------- || '||l_new_elem_ver_id_tbl.COUNT);
        IF l_new_elem_ver_id_tbl.COUNT > 0 THEN
              -- there are new task-resource records to be inserted
              IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Inputs prepared for add_plan_txn and calling';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;
              -- Calling add_planning_transaction for those records for which RA doesnot exists

              --Note down the current value of pa_resource_assignments_s.nextval
              BEGIN
                    --log1('----- STAGE PBL15-------');
                    SELECT  pa_resource_assignments_s.nextval
                    INTO    l_curr_ra_id_seq
                    FROM    DUAL
                    WHERE   1 = 1;
                    --log1('----- STAGE PBL16-------');
              EXCEPTION
                    WHEN OTHERS THEN
                          IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while getting RA Id sequence';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                          END IF;
                          RAISE;
              END;
              --log1('----- STAGE PBL17-------');
              --log1('----- STAGE PBL17.1------- '||l_new_elem_ver_id_tbl.count);
              --log1('----- STAGE PBL17.2------- '||l_new_rlm_id_tbl.count);
              --log1('----- STAGE PBL17.3------- '||p_version_info_rec.x_plan_class_code);
              -- calling  add_planning_transaction
              PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions
                      (p_context                      => p_version_info_rec.x_plan_class_code
                      ,p_one_to_one_mapping_flag      => 'Y'
                      ,p_calling_module               => 'WEBADI'
                      ,p_project_id                   => p_version_info_rec.x_project_id
                      ,p_budget_version_id            => p_budget_version_id
                      ,p_task_elem_version_id_tbl     => l_new_elem_ver_id_tbl
                      ,p_resource_list_member_id_tbl  => l_new_rlm_id_tbl
                      ,p_planning_start_date_tbl      => l_new_planning_start_date_tbl
                      ,p_planning_end_date_tbl        => l_new_planning_end_date_tbl
                      ,x_return_status                => x_return_status
                      ,x_msg_data                     => l_msg_data
                      ,x_msg_count                    => l_msg_count);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:='Called API pa_fp_planning_transaction_pub.add_planning_transaction api returned error';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;
              IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Add_planning_transaction called';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;
        END IF; -- new RAs
        --log1('PBL 5 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

        --log1('----- STAGE PBL11.8------- || '||l_ra_id_tbl.COUNT);

        FOR i IN 1 .. l_ra_id_tbl.COUNT LOOP
            IF l_ra_id_tbl(i) IS NULL THEN
                  -- collect all the new RA ids for that task-resource
                  BEGIN
                        SELECT pra.resource_assignment_id,
                               pra.rbs_element_id,
                               pra.resource_class_code,
                               pra.rate_based_flag
                        INTO   l_new_ra_id,
                               l_new_res_asg_rbs_elem_id,
                               l_new_res_asg_res_class_code,
                               l_new_res_asg_rate_based_flag
                        FROM   pa_resource_assignments pra
                        WHERE  pra.budget_version_id = p_budget_version_id
                        AND    pra.project_id = p_version_info_rec.x_project_id
                        AND    pra.task_id = l_task_id_tbl(i)
                        AND    pra.resource_list_member_id = l_rlm_id_tbl(i)
                        AND    pra.project_assignment_id = -1;

                        -- stamping the value of new RA id over null in p_ra_id_tbl
                        l_ra_id_tbl(i) := l_new_ra_id;

                  EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END;
            END IF;
        END LOOP;
        --log1('PBL 6 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        --log1('PBL 7 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

        -- Deleting records from pa_budget_lines, for the records with delete_flag as Y
        -- and if it is non periodic layout
        -- Bug 4424457.  Moved the delete statement before calculate. This is done for the following reason
        ----Consider a case where RA has currencies C1 and C2 and delete flag is marked for C1. If calculate API
        ----changes C2 to C1 and if delete is executed for RA and C1 after call to calculate API then amounts
        ----entered against C2 by customer will not be honoured and this is not intended.
        IF p_context = 'WEBADI_NON_PERIODIC' THEN
            -- checking if there is any reord with delete_flag = Y
            IF l_df_ra_id_tbl.COUNT > 0 THEN
                     IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Deleting from pa_budget_lines for the records with delete_flag = Y';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     END IF;
                      --log1('PBL 11 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

                     /* Bug 5144013 : Modified the logic so that the attributes of the transaction
                     for which delete flag is set as 'Y' in Excel will be populated in pa_fp_rollup_tmp as
                     deletion of those planning transactions are taken care by delete_planning_transaction api.
                     This is done as part of merging the MRUP3 changes done in 11i into R12.
                     */
                     FOR i IN 1..l_df_ra_id_tbl.COUNT LOOP
                          l_bl_del_flag_ra_id_tbl.extend();
                          l_bl_del_flag_st_dt_tbl.extend();
                          l_bl_del_flag_en_dt_tbl.extend();
                          l_bl_del_flag_txn_curr_tbl.extend();
                          l_bl_del_flag_txn_rc_tbl.extend();
                          l_bl_del_flag_txn_bc_tbl.extend();
                          l_bl_del_flag_txn_rev_tbl.extend();
                          l_bl_del_flag_pf_curr_tbl.extend();
                          l_bl_del_flag_pf_cr_typ_tbl.extend();
                          l_bl_del_flag_pf_cr_dt_typ_tbl.extend();
                          l_bl_del_flag_pf_cexc_rate_tbl.extend();
                          l_bl_del_flag_pf_cr_date_tbl.extend();
                          l_bl_del_flag_pf_rr_typ_tbl.extend();
                          l_bl_del_flag_pf_rr_dt_typ_tbl.extend();
                          l_bl_del_flag_pf_rexc_rate_tbl.extend();
                          l_bl_del_flag_pf_rr_date_tbl.extend();
                          l_bl_del_flag_pj_curr_tbl.extend();
                          l_bl_del_flag_pj_cr_typ_tbl.extend();
                          l_bl_del_flag_pj_cr_dt_typ_tbl.extend();
                          l_bl_del_flag_pj_cexc_rate_tbl.extend();
                          l_bl_del_flag_pj_cr_date_tbl.extend();
                          l_bl_del_flag_pj_rr_typ_tbl.extend();
                          l_bl_del_flag_pj_rr_dt_typ_tbl.extend();
                          l_bl_del_flag_pj_rexc_rate_tbl.extend();
                          l_bl_del_flag_pj_rr_date_tbl.extend();
                          l_bl_del_flag_bl_id_tbl.extend();
                          l_bl_del_flag_per_name_tbl.extend();
                          l_bl_del_flag_pj_raw_cost_tbl.extend();
                          l_bl_del_flag_pj_burd_cost_tbl.extend();
                          l_bl_del_flag_pj_rev_tbl.extend();
                          l_bl_del_flag_raw_cost_tbl.extend();
                          l_bl_del_flag_burd_cost_tbl.extend();
                          l_bl_del_flag_rev_tbl.extend();
                          l_bl_del_flag_qty_tbl.extend();
                          l_bl_del_flag_c_rej_code_tbl.extend();
                          l_bl_del_flag_b_rej_code_tbl.extend();
                          l_bl_del_flag_r_rej_code_tbl.extend();
                          l_bl_del_flag_o_rej_code_tbl.extend();
                          l_bl_del_fg_pc_cnv_rej_cd_tbl.extend();
                          l_bl_del_fg_pf_cnv_rej_cd_tbl.extend();
                          SELECT
                                 pbl.resource_assignment_id,
                                 pbl.start_date,
                                 pbl.end_date,
                                 pbl.txn_currency_code,
                                 pbl.txn_raw_cost,
                                 pbl.txn_burdened_cost,
                                 pbl.txn_revenue,
                                 pbl.projfunc_currency_code,
                                 pbl.projfunc_cost_rate_type,
                                 pbl.projfunc_cost_rate_date_type,
                                 pbl.projfunc_cost_exchange_rate,
                                 pbl.projfunc_cost_rate_date,
                                 pbl.projfunc_rev_rate_type,
                                 pbl.projfunc_rev_rate_date_type,
                                 pbl.projfunc_rev_exchange_rate,
                                 pbl.projfunc_rev_rate_date,
                                 pbl.project_currency_code,
                                 pbl.project_cost_rate_type,
                                 pbl.project_cost_rate_date_type,
                                 pbl.project_cost_exchange_rate,
                                 pbl.project_cost_rate_date,
                                 pbl.project_rev_rate_type,
                                 pbl.project_rev_rate_date_type,
                                 pbl.project_rev_exchange_rate,
                                 pbl.project_rev_rate_date,
                                 pbl.budget_line_id,
                                 pbl.period_name,
                                 pbl.project_raw_cost,
                                 pbl.project_burdened_cost,
                                 pbl.project_revenue,
                                 pbl.raw_cost,
                                 pbl.burdened_cost,
                                 pbl.revenue,
                                 pbl.quantity,
                                 pbl.cost_rejection_code,
                                 pbl.burden_rejection_code,
                                 pbl.revenue_rejection_code,
                                 pbl.other_rejection_code,
                                 pbl.pc_cur_conv_rejection_code,
                                 pbl.pfc_cur_conv_rejection_code
                          INTO
                                 l_bl_del_flag_ra_id_tbl(i),
                                 l_bl_del_flag_st_dt_tbl(i),
                                 l_bl_del_flag_en_dt_tbl(i),
                                 l_bl_del_flag_txn_curr_tbl(i),
                                 l_bl_del_flag_txn_rc_tbl(i),
                                 l_bl_del_flag_txn_bc_tbl(i),
                                 l_bl_del_flag_txn_rev_tbl(i),
                                 l_bl_del_flag_pf_curr_tbl(i),
                                 l_bl_del_flag_pf_cr_typ_tbl(i),
                                 l_bl_del_flag_pf_cr_dt_typ_tbl(i),
                                 l_bl_del_flag_pf_cexc_rate_tbl(i),
                                 l_bl_del_flag_pf_cr_date_tbl(i),
                                 l_bl_del_flag_pf_rr_typ_tbl(i),
                                 l_bl_del_flag_pf_rr_dt_typ_tbl(i),
                                 l_bl_del_flag_pf_rexc_rate_tbl(i),
                                 l_bl_del_flag_pf_rr_date_tbl(i),
                                 l_bl_del_flag_pj_curr_tbl(i),
                                 l_bl_del_flag_pj_cr_typ_tbl(i),
                                 l_bl_del_flag_pj_cr_dt_typ_tbl(i),
                                 l_bl_del_flag_pj_cexc_rate_tbl(i),
                                 l_bl_del_flag_pj_cr_date_tbl(i),
                                 l_bl_del_flag_pj_rr_typ_tbl(i),
                                 l_bl_del_flag_pj_rr_dt_typ_tbl(i),
                                 l_bl_del_flag_pj_rexc_rate_tbl(i),
                                 l_bl_del_flag_pj_rr_date_tbl(i),
                                 l_bl_del_flag_bl_id_tbl(i),
                                 l_bl_del_flag_per_name_tbl(i),
                                 l_bl_del_flag_pj_raw_cost_tbl(i),
                                 l_bl_del_flag_pj_burd_cost_tbl(i),
                                 l_bl_del_flag_pj_rev_tbl(i),
                                 l_bl_del_flag_raw_cost_tbl(i),
                                 l_bl_del_flag_burd_cost_tbl(i),
                                 l_bl_del_flag_rev_tbl(i),
                                 l_bl_del_flag_qty_tbl(i),
                                 l_bl_del_flag_c_rej_code_tbl(i),
                                 l_bl_del_flag_b_rej_code_tbl(i),
                                 l_bl_del_flag_r_rej_code_tbl(i),
                                 l_bl_del_flag_o_rej_code_tbl(i),
                                 l_bl_del_fg_pc_cnv_rej_cd_tbl(i),
                                 l_bl_del_fg_pf_cnv_rej_cd_tbl(i)
                          FROM   pa_budget_lines pbl
                          WHERE  pbl.resource_assignment_id = l_df_ra_id_tbl(i)
                          AND    pbl.txn_currency_code = l_df_txn_currency_code_tbl(i);
                     END LOOP;

                     /*Bug 5144013: Calling delete_planning_transactions api to delete the planning transaction
                      from pa_budget_lines and from new entity when delete flag is set as 'Y' in Excel for a
                      planning transaction. This is done as part of merging the MRUP3 changes done in 11i into R12.
                      */
                     IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Before Calling pa_fp_planning_transaction_pub.delete_planning_transactions';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     END IF;
                         pa_fp_planning_transaction_pub.delete_planning_transactions(
                                                        p_context                  => 'BUDGET'
                                                       ,p_task_or_res              => 'ASSIGNMENT'
                                                       ,p_resource_assignment_tbl  => l_df_ra_id_tbl
                                                       ,p_currency_code_tbl        => l_df_txn_currency_code_tbl
                                                       ,x_return_status            => x_return_status
                                                       ,x_msg_count                => l_msg_count
                                                       ,x_msg_data                 => l_msg_data);
                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:='Called API pa_fp_planning_transactions_pub.delete_planning_transactions returned error';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                     END IF;
                     IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'After Calling pa_fp_planning_transaction_pub.delete_planning_transactions';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     END IF;

                     IF l_bl_del_flag_ra_id_tbl.COUNT > 0 THEN
                        IF l_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage := l_bl_del_flag_ra_id_tbl.COUNT || ' records deleted from pa_budget_lines';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                            pa_debug.g_err_stage := 'Inserting these records into pa_fp_rollup_tmp';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        END IF;

                        --log1('Preparing ra attr tbls for rollup tmp ins');

                     END IF;

            END IF;--IF l_df_ra_id_tbl.COUNT > 0 THEN

        END IF;--IF p_context = 'WEBADI_NON_PERIODIC' THEN


        -- calling calculate api for budget line context for all the elligible records
        IF l_ra_id_tbl.COUNT > 0 THEN
              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Calling calculate to spread amount';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;
              IF p_context = 'WEBADI_PERIODIC' THEN
                    l_calc_calling_context := PA_FP_CONSTANTS_PKG.G_CALC_API_BUDGET_LINE;
              ELSIF p_context = 'WEBADI_NON_PERIODIC' THEN
                         l_line_start_date_tbl := SYSTEM.pa_date_tbl_type();
                         l_line_end_date_tbl   := SYSTEM.pa_date_tbl_type();
                         l_calc_calling_context := PA_FP_CONSTANTS_PKG.G_CALC_API_RESOURCE_CONTEXT;
              END IF;

              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Calling context' || l_calc_calling_context;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;

              --log1('PBL 8 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
              --log1('Before callling calc in pbl');
             /* log1('l_calc_calling_context '||l_calc_calling_context);
              FOR zz IN 1..l_ra_id_tbl.COUNT LOOP

                  log1('l_ra_id_tbl('||zz||') is '||l_ra_id_tbl(zz));
                  log1('l_txn_currency_code_tbl('||zz||') is '||l_txn_currency_code_tbl(zz));
                  IF l_total_qty_tbl.COUNT >0 THEN
                      log1('l_total_qty_tbl('||zz||') is '||l_total_qty_tbl(zz));
                  END IF;
                  IF l_total_raw_cost_tbl.COUNT >0 THEN
                      log1('l_total_raw_cost_tbl('||zz||') is '||l_total_raw_cost_tbl(zz));
                  END IF;
                  IF l_total_burdened_cost_tbl.COUNT > 0 THEN
                      log1('l_total_burdened_cost_tbl('||zz||') is '||l_total_burdened_cost_tbl(zz));
                  END IF;
                  IF l_total_revenue_tbl.COUNT>0 THEN
                      log1('l_total_revenue_tbl('||zz||') is '||l_total_revenue_tbl(zz));
                  END IF;
                  IF l_raw_cost_rate_tbl.COUNT>0 THEN
                      log1('l_raw_cost_rate_tbl('||zz||') is '||l_raw_cost_rate_tbl(zz));
                  END IF;
                  IF l_burdened_cost_rate_tbl.COUNT>0 THEN
                      log1('l_burdened_cost_rate_tbl('||zz||') is '||l_burdened_cost_rate_tbl(zz));
                  END IF;
                  IF l_bill_rate_tbl.COUNT>0 THEN
                      log1('l_bill_rate_tbl('||zz||') is '||l_bill_rate_tbl(zz));
                  END IF;
                  IF l_line_start_date_tbl.COUNT>0 THEN
                      log1('l_line_start_date_tbl('||zz||') is '||l_line_start_date_tbl(zz));
                  END IF;
                  IF l_line_end_date_tbl.COUNT>0 THEN
                      log1('l_line_end_date_tbl('||zz||') is '||l_line_end_date_tbl(zz));
                  END IF;

              END LOOP;*/
              --log1('PBL 9 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
              PA_FP_CALC_PLAN_PKG.calculate(
                  p_project_id                 =>   p_version_info_rec.x_project_id
                 ,p_budget_version_id          =>   p_budget_version_id
                 ,p_rollup_required_flag       =>   'N'
                 ,p_source_context             =>   l_calc_calling_context
                 ,p_conv_rates_required_flag   =>   'N'
                 ,p_resource_assignment_tab    =>   l_ra_id_tbl
                 ,p_txn_currency_code_tab      =>   l_txn_currency_code_tbl
                 ,p_total_qty_tab              =>   l_total_qty_tbl
                 ,p_total_raw_cost_tab         =>   l_total_raw_cost_tbl
                 ,p_total_burdened_cost_tab    =>   l_total_burdened_cost_tbl
                 ,p_total_revenue_tab          =>   l_total_revenue_tbl
                 ,p_rw_cost_rate_override_tab  =>   l_raw_cost_rate_tbl
                 ,p_b_cost_rate_override_tab   =>   l_burdened_cost_rate_tbl
                 ,p_bill_rate_override_tab     =>   l_bill_rate_tbl
                 ,p_line_start_date_tab        =>   l_line_start_date_tbl
                 ,p_line_end_date_tab          =>   l_line_end_date_tbl
                 ,p_raTxn_rollup_api_call_flag =>   'N'
                 ,x_return_status              =>   x_return_status
                 ,x_msg_count                  =>   l_msg_count
                 ,x_msg_data                   =>   l_msg_data);
              --log1('PBL 10 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                     IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='Called API PA_FP_CALC_PLAN_PKG.calculate returned error';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;

                 --Bug 4424457. Find out if there are budget lines that are processed by calculate API
                 BEGIN
                    SELECT 'Y'
                    INTO   l_bls_proccessed_flag
                    FROM    DUAL
                    WHERE   EXISTS (SELECT 1
                                    FROM   pa_fp_rollup_tmp);
                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    l_bls_proccessed_flag:='N';
                 END;

        END IF;  -- if there are data in input tables prepared

        -- Deleting records from pa_budget_lines, for the records with delete_flag as Y
        -- and if it is non periodic layout
        IF p_context = 'WEBADI_NON_PERIODIC' THEN
            -- checking if there is any reord with delete_flag = Y
            IF l_df_ra_id_tbl.COUNT > 0 THEN
                          --log1('PBL 12 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
                          IF l_bl_del_flag_ra_id_tbl.COUNT > 0 THEN
                               IF l_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage := l_bl_del_flag_ra_id_tbl.COUNT || ' records deleted from pa_budget_lines';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                   pa_debug.g_err_stage := 'Inserting these records into pa_fp_rollup_tmp';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                               END IF;

                               --log1('Preparing ra attr tbls for rollup tmp ins');

                               -- inserting these deleted records into pa_fp_rollup_tmp with delete flag as Y
                               FORALL i IN l_bl_del_flag_ra_id_tbl.FIRST .. l_bl_del_flag_ra_id_tbl.LAST
                                       INSERT INTO
                                       pa_fp_rollup_tmp
                                           (resource_assignment_id,
                                            start_date,
                                            end_date,
                                            txn_currency_code,
                                            txn_raw_cost,
                                            txn_burdened_cost,
                                            txn_revenue,
                                            projfunc_currency_code,
                                            projfunc_cost_rate_type,
                                            projfunc_cost_rate_date_type,
                                            projfunc_cost_exchange_rate,
                                            projfunc_cost_rate_date,
                                            projfunc_rev_rate_type,
                                            projfunc_rev_rate_date_type,
                                            projfunc_rev_exchange_rate,
                                            projfunc_rev_rate_date,
                                            project_currency_code,
                                            project_cost_rate_type,
                                            project_cost_rate_date_type,
                                            project_cost_exchange_rate,
                                            project_cost_rate_date,
                                            project_rev_rate_type,
                                            project_rev_rate_date_type,
                                            project_rev_exchange_rate,
                                            project_rev_rate_date,
                                            budget_line_id,
                                            delete_flag,
                                            period_name,
                                            project_raw_cost,
                                            project_burdened_cost,
                                            project_revenue,
                                            projfunc_raw_cost,
                                            projfunc_burdened_cost,
                                            projfunc_revenue,
                                            quantity,
                                            cost_rejection_code,
                                            burden_rejection_code,
                                            revenue_rejection_code,
                                            pc_cur_conv_rejection_code,
                                            pfc_cur_conv_rejection_code,
                                            system_reference4) -- for other_rejection_code
                                       VALUES
                                           (l_bl_del_flag_ra_id_tbl(i),
                                            l_bl_del_flag_st_dt_tbl(i),
                                            l_bl_del_flag_en_dt_tbl(i),
                                            l_bl_del_flag_txn_curr_tbl(i),
                                            l_bl_del_flag_txn_rc_tbl(i),
                                            l_bl_del_flag_txn_bc_tbl(i),
                                            l_bl_del_flag_txn_rev_tbl(i),
                                            l_bl_del_flag_pf_curr_tbl(i),
                                            l_bl_del_flag_pf_cr_typ_tbl(i),
                                            l_bl_del_flag_pf_cr_dt_typ_tbl(i),
                                            l_bl_del_flag_pf_cexc_rate_tbl(i),
                                            l_bl_del_flag_pf_cr_date_tbl(i),
                                            l_bl_del_flag_pf_rr_typ_tbl(i),
                                            l_bl_del_flag_pf_rr_dt_typ_tbl(i),
                                            l_bl_del_flag_pf_rexc_rate_tbl(i),
                                            l_bl_del_flag_pf_rr_date_tbl(i),
                                            l_bl_del_flag_pj_curr_tbl(i),
                                            l_bl_del_flag_pj_cr_typ_tbl(i),
                                            l_bl_del_flag_pj_cr_dt_typ_tbl(i),
                                            l_bl_del_flag_pj_cexc_rate_tbl(i),
                                            l_bl_del_flag_pj_cr_date_tbl(i),
                                            l_bl_del_flag_pj_rr_typ_tbl(i),
                                            l_bl_del_flag_pj_rr_dt_typ_tbl(i),
                                            l_bl_del_flag_pj_rexc_rate_tbl(i),
                                            l_bl_del_flag_pj_rr_date_tbl(i),
                                            l_bl_del_flag_bl_id_tbl(i),
                                            'Y',  -- delete_flag
                                            l_bl_del_flag_per_name_tbl(i),
                                            l_bl_del_flag_pj_raw_cost_tbl(i),
                                            l_bl_del_flag_pj_burd_cost_tbl(i),
                                            l_bl_del_flag_pj_rev_tbl(i),
                                            l_bl_del_flag_raw_cost_tbl(i),
                                            l_bl_del_flag_burd_cost_tbl(i),
                                            l_bl_del_flag_rev_tbl(i),
                                            l_bl_del_flag_qty_tbl(i),
                                            l_bl_del_flag_c_rej_code_tbl(i),
                                            l_bl_del_flag_b_rej_code_tbl(i),
                                            l_bl_del_flag_r_rej_code_tbl(i),
                                            l_bl_del_fg_pc_cnv_rej_cd_tbl(i),
                                            l_bl_del_fg_pf_cnv_rej_cd_tbl(i),
                                            l_bl_del_flag_o_rej_code_tbl(i));
                               --log1('PBL 14 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
                               IF l_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage := 'records inserted into pa_fp_rollup_tmp';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                               END IF;
                          ELSE
                               -- no records deleted from pa_budget_lines
                               IF l_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage := 'No records deleted from pa_budget_lines';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                               END IF;
                          END IF;
            END IF;  -- records with delete_flag

            -- releasing the memory occupied by deleting the temporary pl/sql table types
            l_df_task_id_tbl.DELETE;
            l_df_rlm_id_tbl.DELETE;
            l_df_spread_curve_id_tbl.DELETE;
            l_df_mfc_cost_type_id_tbl.DELETE;
            l_df_etc_method_code.DELETE;
            l_df_sp_fixed_date_tbl.DELETE;
            l_df_txn_currency_code_tbl.DELETE;
            l_df_planning_start_date_tbl.DELETE;
            l_df_planning_end_date_tbl.DELETE;
            l_df_total_qty_tbl.DELETE;
            l_df_total_raw_cost_tbl.DELETE;
            l_df_total_burdened_cost_tbl.DELETE;
            l_df_total_revenue_tbl.DELETE;
            l_df_raw_cost_rate_tbl.DELETE;
            l_df_burdened_cost_rate_tbl.DELETE;
            l_df_bill_rate_tbl.DELETE;
            l_df_line_start_date_tbl.DELETE;
            l_df_line_end_date_tbl.DELETE;
            l_df_pj_cost_rate_typ_tbl.DELETE;
            l_df_pj_cost_rate_date_typ_tbl.DELETE;
            l_df_pj_cost_rate_tbl.DELETE;
            l_df_pj_cost_rate_date_tbl.DELETE;
            l_df_pj_rev_rate_typ_tbl.DELETE;
            l_df_pj_rev_rate_date_typ_tbl.DELETE;
            l_df_pj_rev_rate_tbl.DELETE;
            l_df_pj_rev_rate_date_tbl.DELETE;
            l_df_pf_cost_rate_typ_tbl.DELETE;
            l_df_pf_cost_rate_date_typ_tbl.DELETE;
            l_df_pf_cost_rate_tbl.DELETE;
            l_df_pf_cost_rate_date_tbl.DELETE;
            l_df_pf_rev_rate_typ_tbl.DELETE;
            l_df_pf_rev_rate_date_typ_tbl.DELETE;
            l_df_pf_rev_rate_tbl.DELETE;
            l_df_pf_rev_rate_date_tbl.DELETE;
            l_df_change_reason_code_tbl.DELETE;
            l_df_description_tbl.DELETE;

            l_bl_del_flag_st_dt_tbl.DELETE;
            l_bl_del_flag_en_dt_tbl.DELETE;
            l_bl_del_flag_txn_curr_tbl.DELETE;
            l_bl_del_flag_txn_rc_tbl.DELETE;
            l_bl_del_flag_txn_bc_tbl.DELETE;
            l_bl_del_flag_txn_rev_tbl.DELETE;
            l_bl_del_flag_pf_curr_tbl.DELETE;
            l_bl_del_flag_pf_cr_typ_tbl.DELETE;
            l_bl_del_flag_pf_cr_dt_typ_tbl.DELETE;
            l_bl_del_flag_pf_cexc_rate_tbl.DELETE;
            l_bl_del_flag_pf_cr_date_tbl.DELETE;
            l_bl_del_flag_pf_rr_typ_tbl.DELETE;
            l_bl_del_flag_pf_rr_dt_typ_tbl.DELETE;
            l_bl_del_flag_pf_rexc_rate_tbl.DELETE;
            l_bl_del_flag_pf_rr_date_tbl.DELETE;
            l_bl_del_flag_pj_curr_tbl.DELETE;
            l_bl_del_flag_pj_cr_typ_tbl.DELETE;
            l_bl_del_flag_pj_cr_dt_typ_tbl.DELETE;
            l_bl_del_flag_pj_cexc_rate_tbl.DELETE;
            l_bl_del_flag_pj_cr_date_tbl.DELETE;
            l_bl_del_flag_pj_rr_typ_tbl.DELETE;
            l_bl_del_flag_pj_rr_dt_typ_tbl.DELETE;
            l_bl_del_flag_pj_rexc_rate_tbl.DELETE;
            l_bl_del_flag_pj_rr_date_tbl.DELETE;
            l_bl_del_flag_bl_id_tbl.DELETE;
            l_bl_del_flag_per_name_tbl.DELETE;
            l_bl_del_flag_pj_raw_cost_tbl.DELETE;
            l_bl_del_flag_pj_burd_cost_tbl.DELETE;
            l_bl_del_flag_pj_rev_tbl.DELETE;
            l_bl_del_flag_raw_cost_tbl.DELETE;
            l_bl_del_flag_burd_cost_tbl.DELETE;
            l_bl_del_flag_rev_tbl.DELETE;
            l_bl_del_flag_qty_tbl.DELETE;
            l_bl_del_flag_c_rej_code_tbl.DELETE;
            l_bl_del_flag_b_rej_code_tbl.DELETE;
            l_bl_del_flag_r_rej_code_tbl.DELETE;
            l_bl_del_flag_o_rej_code_tbl.DELETE;
            l_bl_del_fg_pc_cnv_rej_cd_tbl.DELETE;
            l_bl_del_fg_pf_cnv_rej_cd_tbl.DELETE;

        END IF;  -- p_context = WEBADI_NON_PERIODIC

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Updating pa_budget_lines with change reason code, desc and conv attr';
            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
        END IF;

        -- updating conversion attributes if the version is enabled for multi currency
        -- Bug  4424457 : In all the below updates replaced pa_budget_lines with pa_fp_rollup_tmp. These
        -- attributes will be finally stamped back in pa_budget_lines after MC conversion
        IF p_version_info_rec.x_plan_in_multi_curr_flag = 'Y' AND
           p_context = 'WEBADI_PERIODIC' THEN
            IF l_ra_id_tbl.COUNT > 0 AND
               l_bls_proccessed_flag ='Y' THEN
                 --log1('----- STAGE CRC1-------');
                 --log1('PBL 15 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
                 FORALL i IN l_ra_id_tbl.FIRST .. l_ra_id_tbl.LAST
                       UPDATE  pa_fp_rollup_tmp   pbl
                       SET     pbl.projfunc_cost_rate_type = DECODE (l_pfunc_cost_rate_type_tbl(i), NULL, pbl.projfunc_cost_rate_type,
                                                                     DECODE(l_pfunc_cost_rate_type_tbl(i), l_g_miss_char, NULL, l_pfunc_cost_rate_type_tbl(i))),
                               pbl.projfunc_cost_rate_date_type = DECODE (l_pfunc_cost_rate_date_typ_tbl(i), NULL, pbl.projfunc_cost_rate_date_type,
                                                                          DECODE(l_pfunc_cost_rate_date_typ_tbl(i), l_g_miss_char, NULL, l_pfunc_cost_rate_date_typ_tbl(i))),
                               pbl.projfunc_cost_exchange_rate = DECODE (l_pfunc_cost_rate_tbl(i), NULL, pbl.projfunc_cost_exchange_rate,
                                                                         DECODE(l_pfunc_cost_rate_tbl(i), l_g_miss_num, NULL, l_pfunc_cost_rate_tbl(i))),
                               pbl.projfunc_cost_rate_date = DECODE (l_pfunc_cost_rate_date_tbl(i), NULL, pbl.projfunc_cost_rate_date,
                                                                     DECODE(l_pfunc_cost_rate_date_tbl(i), l_g_miss_date, NULL, l_pfunc_cost_rate_date_tbl(i))),
                               pbl.projfunc_rev_rate_type = DECODE (l_pfunc_rev_rate_type_tbl(i), NULL, pbl.projfunc_rev_rate_type,
                                                                    DECODE(l_pfunc_rev_rate_type_tbl(i), l_g_miss_char, NULL, l_pfunc_rev_rate_type_tbl(i))),
                               pbl.projfunc_rev_rate_date_type = DECODE (l_pfunc_rev_rate_date_type_tbl(i), NULL, pbl.projfunc_rev_rate_date_type,
                                                                         DECODE(l_pfunc_rev_rate_date_type_tbl(i), l_g_miss_char, NULL, l_pfunc_rev_rate_date_type_tbl(i))),
                               pbl.projfunc_rev_exchange_rate = DECODE (l_pfunc_rev_rate_tbl(i), NULL, pbl.projfunc_rev_exchange_rate,
                                                                        DECODE(l_pfunc_rev_rate_tbl(i), l_g_miss_num, NULL, l_pfunc_rev_rate_tbl(i))),
                               pbl.projfunc_rev_rate_date = DECODE (l_pfunc_rev_rate_date_tbl(i), NULL, pbl.projfunc_rev_rate_date,
                                                                    DECODE(l_pfunc_rev_rate_date_tbl(i), l_g_miss_date, NULL, l_pfunc_rev_rate_date_tbl(i))),
                               pbl.project_cost_rate_type = DECODE (l_proj_cost_rate_type_tbl(i), NULL, pbl.project_cost_rate_type,
                                                                    DECODE(l_proj_cost_rate_type_tbl(i), l_g_miss_char, NULL, l_proj_cost_rate_type_tbl(i))),
                               pbl.project_cost_rate_date_type = DECODE (l_proj_cost_rate_date_type_tbl(i), NULL, pbl.project_cost_rate_date_type,
                                                                         DECODE(l_proj_cost_rate_date_type_tbl(i), l_g_miss_char, NULL, l_proj_cost_rate_date_type_tbl(i))),
                               pbl.project_cost_exchange_rate = DECODE (l_proj_cost_rate_tbl(i), NULL, pbl.project_cost_exchange_rate,
                                                                        DECODE(l_proj_cost_rate_tbl(i), l_g_miss_num, NULL, l_proj_cost_rate_tbl(i))),
                               pbl.project_cost_rate_date = DECODE (l_proj_cost_rate_date_tbl(i), NULL, pbl.project_cost_rate_date,
                                                                    DECODE(l_proj_cost_rate_date_tbl(i), l_g_miss_date, NULL, l_proj_cost_rate_date_tbl(i))),
                               pbl.project_rev_rate_type = DECODE (l_proj_rev_rate_type_tbl(i), NULL, pbl.project_rev_rate_type,
                                                                   DECODE(l_proj_rev_rate_type_tbl(i), l_g_miss_char, NULL, l_proj_rev_rate_type_tbl(i))),
                               pbl.project_rev_rate_date_type = DECODE (l_proj_rev_rate_date_type_tbl(i), NULL, pbl.project_rev_rate_date_type,
                                                                        DECODE(l_proj_rev_rate_date_type_tbl(i), l_g_miss_char, NULL, l_proj_rev_rate_date_type_tbl(i))),
                               pbl.project_rev_exchange_rate = DECODE (l_proj_rev_rate_tbl(i), NULL, pbl.project_rev_exchange_rate,
                                                                       DECODE(l_proj_rev_rate_tbl(i), l_g_miss_num, NULL, l_proj_rev_rate_tbl(i))),
                               pbl.project_rev_rate_date = DECODE (l_proj_rev_rate_date_tbl(i), NULL, pbl.project_rev_rate_date,
                                                                   DECODE(l_proj_rev_rate_date_tbl(i), l_g_miss_date, NULL, l_proj_rev_rate_date_tbl(i)))
                       WHERE   pbl.resource_assignment_id = l_ra_id_tbl(i)
                       AND     pbl.txn_currency_code = l_txn_currency_code_tbl(i)
                       AND     pbl.start_date >= l_line_start_date_tbl(i)
                       AND     pbl.end_date <= l_line_end_date_tbl(i);
                               --log1('PBL 16 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
            END IF;  -- there are records in local ra tbl
        --END IF;  -- mc flag = Y

        -- updating change reason code and description if the version is non time phased
        ELSIF p_version_info_rec.x_plan_in_multi_curr_flag <> 'Y' AND
              p_context = 'WEBADI_NON_PERIODIC' THEN
            IF l_ra_id_tbl.COUNT > 0 AND
               l_bls_proccessed_flag ='Y' THEN
                 --log1('----- STAGE CRC2-------');
                 --log1('PBL 17 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
                 FORALL i IN l_ra_id_tbl.FIRST .. l_ra_id_tbl.LAST
                       UPDATE  pa_fp_rollup_tmp pbl
                       SET     pbl.change_reason_code = l_change_reason_code_tbl(i),
                               pbl.description        = l_description_tbl(i)
                       WHERE   pbl.resource_assignment_id = l_ra_id_tbl(i)
                       AND     pbl.txn_currency_code = l_txn_currency_code_tbl(i);
                    --log1('PBL 18 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
            END IF;  -- there are records in local ra tbl
        --END IF;  -- time phase  = N
        ELSIF p_version_info_rec.x_plan_in_multi_curr_flag = 'Y' AND
              p_context = 'WEBADI_NON_PERIODIC' THEN
                  --log1('----- STAGE PBL18-------');
                  IF l_ra_id_tbl.COUNT > 0 AND
                     l_bls_proccessed_flag ='Y' THEN
                     --log1('PBL 19 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
                     FORALL i IN l_ra_id_tbl.FIRST .. l_ra_id_tbl.LAST
                           UPDATE  pa_fp_rollup_tmp   pbl
                           SET     pbl.change_reason_code = l_change_reason_code_tbl(i),
                                   pbl.description        = DECODE(l_description_tbl(i), NULL, pbl.description,
                                                                   DECODE(l_description_tbl(i), l_g_miss_char, NULL, l_description_tbl(i))),
                                   pbl.projfunc_cost_rate_type = DECODE (l_pfunc_cost_rate_type_tbl(i), NULL, pbl.projfunc_cost_rate_type,
                                                                         DECODE(l_pfunc_cost_rate_type_tbl(i), l_g_miss_char, NULL, l_pfunc_cost_rate_type_tbl(i))),
                                   pbl.projfunc_cost_rate_date_type = DECODE (l_pfunc_cost_rate_date_typ_tbl(i), NULL, pbl.projfunc_cost_rate_date_type,
                                                                              DECODE(l_pfunc_cost_rate_date_typ_tbl(i), l_g_miss_char, NULL, l_pfunc_cost_rate_date_typ_tbl(i))),
                                   pbl.projfunc_cost_exchange_rate = DECODE (l_pfunc_cost_rate_tbl(i), NULL, pbl.projfunc_cost_exchange_rate,
                                                                             DECODE(l_pfunc_cost_rate_tbl(i), l_g_miss_num, NULL, l_pfunc_cost_rate_tbl(i))),
                                   pbl.projfunc_cost_rate_date = DECODE (l_pfunc_cost_rate_date_tbl(i), NULL, pbl.projfunc_cost_rate_date,
                                                                         DECODE(l_pfunc_cost_rate_date_tbl(i), l_g_miss_date, NULL, l_pfunc_cost_rate_date_tbl(i))),
                                   pbl.projfunc_rev_rate_type = DECODE (l_pfunc_rev_rate_type_tbl(i), NULL, pbl.projfunc_rev_rate_type,
                                                                        DECODE(l_pfunc_rev_rate_type_tbl(i), l_g_miss_char, NULL, l_pfunc_rev_rate_type_tbl(i))),
                                   pbl.projfunc_rev_rate_date_type = DECODE (l_pfunc_rev_rate_date_type_tbl(i), NULL, pbl.projfunc_rev_rate_date_type,
                                                                             DECODE(l_pfunc_rev_rate_date_type_tbl(i), l_g_miss_char, NULL, l_pfunc_rev_rate_date_type_tbl(i))),
                                   pbl.projfunc_rev_exchange_rate = DECODE (l_pfunc_rev_rate_tbl(i), NULL, pbl.projfunc_rev_exchange_rate,
                                                                            DECODE(l_pfunc_rev_rate_tbl(i), l_g_miss_num, NULL, l_pfunc_rev_rate_tbl(i))),
                                   pbl.projfunc_rev_rate_date = DECODE (l_pfunc_rev_rate_date_tbl(i), NULL, pbl.projfunc_rev_rate_date,
                                                                        DECODE(l_pfunc_rev_rate_date_tbl(i), l_g_miss_date, NULL, l_pfunc_rev_rate_date_tbl(i))),
                                   pbl.project_cost_rate_type = DECODE (l_proj_cost_rate_type_tbl(i), NULL, pbl.project_cost_rate_type,
                                                                        DECODE(l_proj_cost_rate_type_tbl(i), l_g_miss_char, NULL, l_proj_cost_rate_type_tbl(i))),
                                   pbl.project_cost_rate_date_type = DECODE (l_proj_cost_rate_date_type_tbl(i), NULL, pbl.project_cost_rate_date_type,
                                                                             DECODE(l_proj_cost_rate_date_type_tbl(i), l_g_miss_char, NULL, l_proj_cost_rate_date_type_tbl(i))),
                                   pbl.project_cost_exchange_rate = DECODE (l_proj_cost_rate_tbl(i), NULL, pbl.project_cost_exchange_rate,
                                                                            DECODE(l_proj_cost_rate_tbl(i), l_g_miss_num, NULL, l_proj_cost_rate_tbl(i))),
                                   pbl.project_cost_rate_date = DECODE (l_proj_cost_rate_date_tbl(i), NULL, pbl.project_cost_rate_date,
                                                                        DECODE(l_proj_cost_rate_date_tbl(i), l_g_miss_date, NULL, l_proj_cost_rate_date_tbl(i))),
                                   pbl.project_rev_rate_type = DECODE (l_proj_rev_rate_type_tbl(i), NULL, pbl.project_rev_rate_type,
                                                                       DECODE(l_proj_rev_rate_type_tbl(i), l_g_miss_char, NULL, l_proj_rev_rate_type_tbl(i))),
                                   pbl.project_rev_rate_date_type = DECODE (l_proj_rev_rate_date_type_tbl(i), NULL, pbl.project_rev_rate_date_type,
                                                                            DECODE(l_proj_rev_rate_date_type_tbl(i), l_g_miss_char, NULL, l_proj_rev_rate_date_type_tbl(i))),
                                   pbl.project_rev_exchange_rate = DECODE (l_proj_rev_rate_tbl(i), NULL, pbl.project_rev_exchange_rate,
                                                                           DECODE(l_proj_rev_rate_tbl(i), l_g_miss_num, NULL, l_proj_rev_rate_tbl(i))),
                                   pbl.project_rev_rate_date = DECODE (l_proj_rev_rate_date_tbl(i), NULL, pbl.project_rev_rate_date,
                                                                       DECODE(l_proj_rev_rate_date_tbl(i), l_g_miss_date, NULL, l_proj_rev_rate_date_tbl(i)))
                           WHERE   pbl.resource_assignment_id = l_ra_id_tbl(i)
                           AND     pbl.txn_currency_code = l_txn_currency_code_tbl(i);
                        --log1('PBL 20 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
                END IF;  -- there are records in local ra tbl
        END IF; -- end of update

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='pa_budget_lines updated with change reason code, desc and conv attr';
            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
        END IF;


        --log1('----- STAGE PBL18.3------- ');
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Calling multi currency pkg';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        --log1('PBL 26 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        -- Bug  4424457. Call MC API only if there are some budget lines that are processed by calculate API
        IF  l_bls_proccessed_flag ='Y' THEN

            PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency
                     (p_budget_version_id   => p_budget_version_id
                     ,p_entire_version     => 'N'
                     ,x_return_status      => x_return_status
                     ,x_msg_count          => l_msg_count
                     ,x_msg_data           => l_msg_data );
        --log1('PBL 27 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='convert_txn_currency returned error';
                    pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
            END IF;

        END IF;

       IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Preparing data for the call to PJI api';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       END IF;

               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'About to select data for updating the budget lines '||l_bls_proccessed_flag;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;

                --bug 5962744 moved below bulk select out of if condition
                --Bug 4424457. Rollup tmp can contain multiple records for the same budget line id. This will happen when
                --for a budget line passed as input, the txn currency code is converted to some other currency which
                --already exiss for the same RA. This might get resolved with the MRC API changes. Till then this should
                --be taken care
                --Previously PJI plan_update was called and hence the required input was collected in _pji_ tbls. Now
                --plan_delete  and plan_create are called. But the _pji_ tbls are still retained for update on
                --pa_budget_lines

                    SELECT  rlp.resource_assignment_id,
                            max(rlp.period_name),
                            rlp.start_date,
                            max(rlp.end_date),
                            rlp.txn_currency_code,
                            max(rlp.budget_line_id),
                            sum(rlp.txn_raw_cost),
                            sum(rlp.txn_burdened_cost),
                            sum(rlp.txn_revenue),
                            sum(rlp.project_raw_cost),
                            sum(rlp.project_burdened_cost),
                            sum(rlp.project_revenue),
                            sum(rlp.projfunc_raw_cost),
                            sum(rlp.projfunc_burdened_cost),
                            sum(rlp.projfunc_revenue),
                            sum(rlp.init_quantity),
                            sum(rlp.init_raw_cost),
                            sum(rlp.init_burdened_cost),
                            sum(rlp.init_revenue),
                            sum(rlp.project_init_raw_cost),
                            sum(rlp.project_init_burdened_cost),
                            sum(rlp.project_init_revenue),
                            sum(rlp.txn_init_raw_cost),
                            sum(rlp.txn_init_burdened_cost),
                            sum(rlp.txn_init_revenue),
                            max(rlp.cost_rejection_code),
                            max(rlp.revenue_rejection_code),
                            max(rlp.burden_rejection_code),
                            max(rlp.system_reference4),  -- for other_rejection_code
                            max(rlp.pc_cur_conv_rejection_code),
                            max(rlp.pfc_cur_conv_rejection_code),
                            max(rlp.delete_flag),
                            sum(rlp.quantity),
                            max(rlp.project_cost_rate_type),
                            avg(rlp.project_cost_exchange_rate),
                            max(rlp.project_cost_rate_date_type),
                            max(rlp.project_cost_rate_date),
                            max(rlp.project_rev_rate_type),
                            avg(rlp.project_rev_exchange_rate),
                            max(rlp.project_rev_rate_date_type),
                            max(rlp.project_rev_rate_date),
                            max(rlp.projfunc_cost_rate_type),
                            avg(rlp.projfunc_cost_exchange_rate),
                            max(rlp.projfunc_cost_rate_date_type),
                            max(rlp.projfunc_cost_rate_date),
                            max(rlp.projfunc_rev_rate_type),
                            avg(rlp.projfunc_rev_exchange_rate),
                            max(rlp.projfunc_rev_rate_date_type),
                            max(rlp.projfunc_rev_rate_date),
                            count(*),
                            max(change_reason_code),
                            max(description)
                    BULK COLLECT INTO
                            l_pji_res_ass_id_tbl,
                            l_pji_period_name_tbl,
                            l_pji_start_date_tbl,
                            l_pji_end_date_tbl,
                            l_pji_txn_curr_code_tbl,
                            l_upd_budget_line_id_tbl,
                            l_pji_txn_raw_cost_tbl,
                            l_pji_txn_burd_cost_tbl,
                            l_pji_txn_revenue_tbl,
                            l_pji_project_raw_cost_tbl,
                            l_pji_project_burd_cost_tbl,
                            l_pji_project_revenue_tbl,
                            l_pji_raw_cost_tbl,
                            l_pji_burd_cost_tbl,
                            l_pji_revenue_tbl,
                            l_upd_init_quantity_tbl,
                            l_upd_init_raw_cost_tbl,
                            l_upd_init_burdened_cost_tbl,
                            l_upd_init_revenue_tbl,
                            l_upd_proj_init_raw_cost_tbl,
                            l_upd_proj_init_burd_cost_tbl,
                            l_upd_proj_init_revenue_tbl,
                            l_upd_txn_init_raw_cost_tbl,
                            l_upd_txn_init_burd_cost_tbl,
                            l_upd_txn_init_revenue_tbl,
                            l_pji_cost_rej_code_tbl,
                            l_pji_revenue_rej_code_tbl,
                            l_pji_burden_rej_code_tbl,
                            l_pji_other_rej_code,
                            l_pji_pc_cur_conv_rej_code_tbl,
                            l_pji_pf_cur_conv_rej_code_tbl,
                            l_upd_delete_flag_tbl,
                            l_pji_quantity_tbl,
                            l_upd_pj_cost_rate_typ_tbl,
                            l_upd_pj_cost_exc_rate_tbl,
                            l_upd_pj_cost_rate_dt_typ_tbl,
                            l_upd_pj_cost_rate_date_tbl,
                            l_upd_pj_rev_rate_typ_tbl,
                            l_upd_pj_rev_exc_rate_tbl,
                            l_upd_pj_rev_rate_dt_typ_tbl,
                            l_upd_pj_rev_rate_date_tbl,
                            l_upd_pf_cost_rate_typ_tbl,
                            l_upd_pf_cost_exc_rate_tbl,
                            l_upd_pf_cost_rate_dt_typ_tbl,
                            l_upd_pf_cost_rate_date_tbl,
                            l_upd_pf_rev_rate_typ_tbl,
                            l_upd_pf_rev_exc_rate_tbl,
                            l_upd_pf_rev_rate_dt_typ_tbl,
                            l_upd_pf_rev_rate_date_tbl,
                            l_bl_count_tbl,
                            l_chg_reason_code_tbl,
                            l_desc_tbl
                    FROM    pa_fp_rollup_tmp rlp
                    WHERE   delete_flag IS NULL OR delete_flag <> 'Y'
                    GROUP BY rlp.resource_assignment_id,rlp.txn_currency_code,rlp.start_date;

            --log1('PBL 28 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
            --bug 5962744
       -- Bug 7184576 The below code should be run for non time phased budget/forecast. It is
       -- possible to process time phased budget/forecast using non time phased period layout.
       -- So if condition should be based on time phase code rathen than p_context it wont be
       -- updating the correclty.
       --IF p_context = 'WEBADI_NON_PERIODIC' THEN
       IF p_version_info_rec.x_time_phased_code = 'N' THEN
            l_extra_bl_flag_tbl.extend(l_upd_budget_line_id_tbl.COUNT);
            l_ex_chg_rsn_code_tbl.extend(l_upd_budget_line_id_tbl.COUNT);
            l_ex_desc_tbl.extend(l_upd_budget_line_id_tbl.COUNT);

            if l_upd_budget_line_id_tbl.count > 0 then
                for i in l_upd_budget_line_id_tbl.first .. l_upd_budget_line_id_tbl.last loop

                    l_extra_bl_flag_tbl(i):='N';
                    l_ex_chg_rsn_code_tbl(i):=null;
                    l_ex_desc_tbl(i):=null;
                end loop;
            end if;

            if l_ra_id_tbl.count > 0 then
                for i in l_ra_id_tbl.first .. l_ra_id_tbl.last loop

                    l_ra_exists:='N';
                    if l_pji_res_ass_id_tbl.count > 0 then
                        for j in l_pji_res_ass_id_tbl.first .. l_pji_res_ass_id_tbl.last loop
                            if (l_pji_res_ass_id_tbl(j) = l_ra_id_tbl(i) and
                                   l_pji_txn_curr_code_tbl(j) =  l_txn_currency_code_tbl(i)) then
                                   l_ra_exists:='Y';
                            end if;
                        end loop;
                    end if;

                    if l_ra_exists ='N' then
                        l_extra_bl_flag_tbl.extend(1);
                        l_extra_bl_flag_tbl(l_extra_bl_flag_tbl.count):='Y';
                        l_pji_res_ass_id_tbl.extend(1);
                        l_pji_res_ass_id_tbl(l_pji_res_ass_id_tbl.count):=l_ra_id_tbl(i);
                        l_pji_txn_curr_code_tbl.extend(1);
                        l_pji_txn_curr_code_tbl(l_pji_txn_curr_code_tbl.count):=l_txn_currency_code_tbl(i);
                        l_ex_chg_rsn_code_tbl.extend(1);
                        l_ex_chg_rsn_code_tbl(l_ex_chg_rsn_code_tbl.count):=l_change_reason_code_tbl(i);
                        l_ex_desc_tbl.extend(1);
                        l_ex_desc_tbl(l_ex_desc_tbl.count):=l_description_tbl(i);


                        l_pji_project_raw_cost_tbl.extend(1);
                        l_pji_project_burd_cost_tbl.extend(1);
                        l_pji_project_revenue_tbl.extend(1);
                        l_pji_raw_cost_tbl.extend(1);
                        l_pji_burd_cost_tbl.extend(1);
                        l_pji_revenue_tbl.extend(1);
                        l_pji_quantity_tbl.extend(1);
                        l_pji_pc_cur_conv_rej_code_tbl.extend(1);
                        l_pji_pf_cur_conv_rej_code_tbl.extend(1);
                        l_upd_init_quantity_tbl.extend(1);
                        l_upd_init_raw_cost_tbl.extend(1);
                        l_upd_init_burdened_cost_tbl.extend(1);
                        l_upd_init_revenue_tbl.extend(1);
                        l_upd_proj_init_raw_cost_tbl.extend(1);
                        l_upd_proj_init_burd_cost_tbl.extend(1);
                        l_upd_proj_init_revenue_tbl.extend(1);
                        l_upd_txn_init_raw_cost_tbl.extend(1);
                        l_upd_txn_init_burd_cost_tbl.extend(1);
                        l_upd_txn_init_revenue_tbl.extend(1);
                        l_upd_pj_cost_rate_typ_tbl.extend(1);
                        l_upd_pj_cost_exc_rate_tbl.extend(1);
                        l_upd_pj_cost_rate_dt_typ_tbl.extend(1);
                        l_upd_pj_cost_rate_date_tbl.extend(1);
                        l_upd_pj_rev_rate_typ_tbl.extend(1);
                        l_upd_pj_rev_exc_rate_tbl.extend(1);
                        l_upd_pj_rev_rate_dt_typ_tbl.extend(1);
                        l_upd_pj_rev_rate_date_tbl.extend(1);
                        l_upd_pf_cost_rate_typ_tbl.extend(1);
                        l_upd_pf_cost_exc_rate_tbl.extend(1);
                        l_upd_pf_cost_rate_dt_typ_tbl.extend(1);
                        l_upd_pf_cost_rate_date_tbl.extend(1);
                        l_upd_pf_rev_rate_typ_tbl.extend(1);
                        l_upd_pf_rev_exc_rate_tbl.extend(1);
                        l_upd_pf_rev_rate_dt_typ_tbl.extend(1);
                        l_upd_pf_rev_rate_date_tbl.extend(1);
                        l_chg_reason_code_tbl.extend(1);
                        l_desc_tbl.extend(1);
                        l_upd_delete_flag_tbl.extend(1);
                        l_upd_delete_flag_tbl(l_upd_delete_flag_tbl.count) := null;
                        l_bl_count_tbl.extend(1);
                        l_bl_count_tbl(l_bl_count_tbl.count) := 1;
                    end if;
                end loop;
            end if;




            FORALL i IN l_pji_res_ass_id_tbl.FIRST .. l_pji_res_ass_id_tbl.LAST
                   UPDATE  pa_budget_lines pbl
                   SET     pbl.project_raw_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_raw_cost,'N',l_pji_project_raw_cost_tbl(i)),
                           pbl.project_burdened_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_burdened_cost,'N',l_pji_project_burd_cost_tbl(i)),
                           pbl.project_revenue = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_revenue,'N',l_pji_project_revenue_tbl(i)),
                           pbl.raw_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.raw_cost,'N',l_pji_raw_cost_tbl(i)),
                           pbl.burdened_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.burdened_cost,'N',l_pji_burd_cost_tbl(i)),
                           pbl.revenue = decode(l_extra_bl_flag_tbl(i),'Y',pbl.revenue,'N',l_pji_revenue_tbl(i)),
                           pbl.quantity = decode(l_extra_bl_flag_tbl(i),'Y',pbl.quantity,'N',l_pji_quantity_tbl(i)),
                           pbl.pc_cur_conv_rejection_code = decode(l_extra_bl_flag_tbl(i),'Y',pbl.pc_cur_conv_rejection_code,'N',l_pji_pc_cur_conv_rej_code_tbl(i)),
                           pbl.pfc_cur_conv_rejection_code = decode(l_extra_bl_flag_tbl(i),'Y',pbl.pfc_cur_conv_rejection_code,'N',l_pji_pf_cur_conv_rej_code_tbl(i)),
                           pbl.init_quantity = decode(l_extra_bl_flag_tbl(i),'Y',pbl.init_quantity,'N',l_upd_init_quantity_tbl(i)),
                           pbl.init_raw_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.init_raw_cost,'N',l_upd_init_raw_cost_tbl(i)),
                           pbl.init_burdened_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.init_burdened_cost,'N',l_upd_init_burdened_cost_tbl(i)),
                           pbl.init_revenue = decode(l_extra_bl_flag_tbl(i),'Y',pbl.init_revenue,'N',l_upd_init_revenue_tbl(i)),
                           pbl.project_init_raw_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_init_raw_cost,'N',l_upd_proj_init_raw_cost_tbl(i)),
                           pbl.project_init_burdened_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_init_burdened_cost,'N',l_upd_proj_init_burd_cost_tbl(i)),
                           pbl.project_init_revenue = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_init_revenue,'N',l_upd_proj_init_revenue_tbl(i)),
                           pbl.txn_init_raw_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.txn_init_raw_cost,'N',l_upd_txn_init_raw_cost_tbl(i)),
                           pbl.txn_init_burdened_cost = decode(l_extra_bl_flag_tbl(i),'Y',pbl.txn_init_burdened_cost,'N',l_upd_txn_init_burd_cost_tbl(i)),
                           pbl.txn_init_revenue = decode(l_extra_bl_flag_tbl(i),'Y',pbl.txn_init_revenue,'N',l_upd_txn_init_revenue_tbl(i)),
                           pbl.project_cost_rate_type = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_cost_rate_type,'N',l_upd_pj_cost_rate_typ_tbl(i)),
                           pbl.project_cost_exchange_rate = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_cost_exchange_rate,'N',l_upd_pj_cost_exc_rate_tbl(i)),
                           pbl.project_cost_rate_date_type = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_cost_rate_date_type,'N',l_upd_pj_cost_rate_dt_typ_tbl(i)),
                           pbl.project_cost_rate_date = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_cost_rate_date,'N',l_upd_pj_cost_rate_date_tbl(i)),
                           pbl.project_rev_rate_type = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_rev_rate_type,'N',l_upd_pj_rev_rate_typ_tbl(i)),
                           pbl.project_rev_exchange_rate = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_rev_exchange_rate,'N',l_upd_pj_rev_exc_rate_tbl(i)),
                           pbl.project_rev_rate_date_type = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_rev_rate_date_type,'N',l_upd_pj_rev_rate_dt_typ_tbl(i)),
                           pbl.project_rev_rate_date = decode(l_extra_bl_flag_tbl(i),'Y',pbl.project_rev_rate_date,'N',l_upd_pj_rev_rate_date_tbl(i)),
                           pbl.projfunc_cost_rate_type = decode(l_extra_bl_flag_tbl(i),'Y',pbl.projfunc_cost_rate_type,'N',l_upd_pf_cost_rate_typ_tbl(i)),
                           pbl.projfunc_cost_exchange_rate = decode(l_extra_bl_flag_tbl(i),'Y',pbl.projfunc_cost_exchange_rate,'N',l_upd_pf_cost_exc_rate_tbl(i)),
                           pbl.projfunc_cost_rate_date_type = decode(l_extra_bl_flag_tbl(i),'Y',pbl.projfunc_cost_rate_date_type,'N',l_upd_pf_cost_rate_dt_typ_tbl(i)),
                           pbl.projfunc_cost_rate_date = decode(l_extra_bl_flag_tbl(i),'Y',pbl.projfunc_cost_rate_date,'N',l_upd_pf_cost_rate_date_tbl(i)),
                           pbl.projfunc_rev_rate_type = decode(l_extra_bl_flag_tbl(i),'Y',pbl.projfunc_rev_rate_type,'N',l_upd_pf_rev_rate_typ_tbl(i)),
                           pbl.projfunc_rev_exchange_rate = decode(l_extra_bl_flag_tbl(i),'Y',pbl.projfunc_rev_exchange_rate,'N',l_upd_pf_rev_exc_rate_tbl(i)),
                           pbl.projfunc_rev_rate_date_type = decode(l_extra_bl_flag_tbl(i),'Y',pbl.projfunc_rev_rate_date_type,'N',l_upd_pf_rev_rate_dt_typ_tbl(i)),
                           pbl.projfunc_rev_rate_date = decode(l_extra_bl_flag_tbl(i),'Y',pbl.projfunc_rev_rate_date,'N',l_upd_pf_rev_rate_date_tbl(i)),
                           pbl.change_reason_code = decode(l_extra_bl_flag_tbl(i),'Y',l_ex_chg_rsn_code_tbl(i),'N',DECODE(l_chg_reason_code_tbl(i), NULL, pbl.change_reason_code,
                                                                                    l_fnd_miss_char, NULL,
                                                                                    l_chg_reason_code_tbl(i))), -- Bug 5014538.
                           pbl.description=decode(l_extra_bl_flag_tbl(i),'Y',l_ex_desc_tbl(i),'N',l_desc_tbl(i)),
                           pbl.last_updated_by = fnd_global.user_id,
                           pbl.last_update_date = SYSDATE,
                           pbl.last_update_login =  fnd_global.login_id
                   WHERE   pbl.budget_version_id = p_budget_version_id
                   AND     pbl.resource_assignment_id = l_pji_res_ass_id_tbl(i)
                   AND     pbl.txn_currency_code = l_pji_txn_curr_code_tbl(i)
                   AND     l_bl_count_tbl(i)=1
                   AND    (l_upd_delete_flag_tbl(i) IS  NULL OR
                           l_upd_delete_flag_tbl(i) <> 'Y');
       END IF; --if p_version_info_rec.x_time_phased_code = 'N'
       --bug 5962744
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Stampping Amounts and rejection codes in budget lines';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;

           -- Bug 	4424457. If there are budget lines that either got deleted or updated/created then
       -- stamp the derived pc/pfc amounts back on budget lines and call PJI API
        IF l_bls_proccessed_flag ='Y' OR
           l_bl_del_flag_ra_id_tbl.COUNT > 0 THEN
           --Bug 4424457. Update only those budget lines for which duplicates do not exist in rollup tmp. Budget lines
           --with duplicates are already taken care of in calculate API
       --    IF l_pji_res_ass_id_tbl.COUNT > 0 THEN
         -- Changes done for bug 7184576
          -- IF p_context <> 'WEBADI_NON_PERIODIC' THEN
            IF p_version_info_rec.x_time_phased_code <> 'N' THEN
                FORALL i IN l_upd_budget_line_id_tbl.FIRST .. l_upd_budget_line_id_tbl.LAST
                       UPDATE  pa_budget_lines pbl
                       SET     pbl.project_raw_cost = l_pji_project_raw_cost_tbl(i),
                               pbl.project_burdened_cost = l_pji_project_burd_cost_tbl(i),
                               pbl.project_revenue = l_pji_project_revenue_tbl(i),
                               pbl.raw_cost = l_pji_raw_cost_tbl(i),
                               pbl.burdened_cost = l_pji_burd_cost_tbl(i),
                               pbl.revenue = l_pji_revenue_tbl(i),
                               pbl.quantity = l_pji_quantity_tbl(i),
                               pbl.pc_cur_conv_rejection_code = l_pji_pc_cur_conv_rej_code_tbl(i),
                               pbl.pfc_cur_conv_rejection_code = l_pji_pf_cur_conv_rej_code_tbl(i),
                               pbl.init_quantity = l_upd_init_quantity_tbl(i),
                               pbl.init_raw_cost = l_upd_init_raw_cost_tbl(i),
                               pbl.init_burdened_cost = l_upd_init_burdened_cost_tbl(i),
                               pbl.init_revenue = l_upd_init_revenue_tbl(i),
                               pbl.project_init_raw_cost = l_upd_proj_init_raw_cost_tbl(i),
                               pbl.project_init_burdened_cost = l_upd_proj_init_burd_cost_tbl(i),
                               pbl.project_init_revenue = l_upd_proj_init_revenue_tbl(i),
                               pbl.txn_init_raw_cost = l_upd_txn_init_raw_cost_tbl(i),
                               pbl.txn_init_burdened_cost = l_upd_txn_init_burd_cost_tbl(i),
                               pbl.txn_init_revenue = l_upd_txn_init_revenue_tbl(i),
                               pbl.project_cost_rate_type = l_upd_pj_cost_rate_typ_tbl(i),
                               pbl.project_cost_exchange_rate = l_upd_pj_cost_exc_rate_tbl(i),
                               pbl.project_cost_rate_date_type = l_upd_pj_cost_rate_dt_typ_tbl(i),
                               pbl.project_cost_rate_date = l_upd_pj_cost_rate_date_tbl(i),
                               pbl.project_rev_rate_type = l_upd_pj_rev_rate_typ_tbl(i),
                               pbl.project_rev_exchange_rate = l_upd_pj_rev_exc_rate_tbl(i),
                               pbl.project_rev_rate_date_type = l_upd_pj_rev_rate_dt_typ_tbl(i),
                               pbl.project_rev_rate_date = l_upd_pj_rev_rate_date_tbl(i),
                               pbl.projfunc_cost_rate_type = l_upd_pf_cost_rate_typ_tbl(i),
                               pbl.projfunc_cost_exchange_rate = l_upd_pf_cost_exc_rate_tbl(i),
                               pbl.projfunc_cost_rate_date_type = l_upd_pf_cost_rate_dt_typ_tbl(i),
                               pbl.projfunc_cost_rate_date = l_upd_pf_cost_rate_date_tbl(i),
                               pbl.projfunc_rev_rate_type = l_upd_pf_rev_rate_typ_tbl(i),
                               pbl.projfunc_rev_exchange_rate = l_upd_pf_rev_exc_rate_tbl(i),
                               pbl.projfunc_rev_rate_date_type = l_upd_pf_rev_rate_dt_typ_tbl(i),
                               pbl.projfunc_rev_rate_date = l_upd_pf_rev_rate_date_tbl(i),
                               pbl.change_reason_code = DECODE(l_chg_reason_code_tbl(i), NULL, pbl.change_reason_code,
                                                                                        l_fnd_miss_char, NULL,
                                                                                        l_chg_reason_code_tbl(i)), --Bug 5144013.
                               pbl.description=l_desc_tbl(i),
                               pbl.last_updated_by = fnd_global.user_id,
                               pbl.last_update_date = SYSDATE,
                               pbl.last_update_login =  fnd_global.login_id
                       WHERE   pbl.budget_version_id = p_budget_version_id
                       AND     pbl.resource_assignment_id = l_pji_res_ass_id_tbl(i)
                       AND     pbl.txn_currency_code = l_pji_txn_curr_code_tbl(i)
                       AND     pbl.start_date =l_pji_start_date_tbl(i)
                       AND     l_bl_count_tbl(i)=1
                       AND    (l_upd_delete_flag_tbl(i) IS  NULL OR
                               l_upd_delete_flag_tbl(i) <> 'Y');
           END IF;

           /* Start of fix for Bug : 5144013.Call is made to the api PA_BUDGET_LINES_UTILS.populate_display_qty
              to populate the display_quantity in pa_budget_lines. This is done as part of merging the MRUP3
              changes done in 11i into R12.
           */
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Before calling Populate Display Qty api';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           PA_BUDGET_LINES_UTILS.populate_display_qty
                 ( p_budget_version_id     => p_budget_version_id
                  ,p_context               => 'FINANCIAL'
                  ,x_return_status         => x_return_status);
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'The API PA_BUDGET_LINES_UTILS.populate_display_qty returned error';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'After calling Populate Display Qty api';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           -- Call is made to maintain_data api to rollup the data in new entity.
           IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Before calling maintanance api maintain_data';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           PA_RES_ASG_CURRENCY_PUB.maintain_data(
                                                p_fp_cols_rec           => p_version_info_rec
                                               ,p_calling_module        => 'WEBADI'
                                               ,p_rollup_flag           => 'Y'
                                               ,p_version_level_flag    => 'Y'
                                               ,x_return_status         => x_return_status
                                               ,x_msg_count             => l_msg_count
                                               ,x_msg_data              => l_msg_data);
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'The API PA_RES_ASG_CURRENCY_PUB.maintain_data returned error';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
           IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'After calling maintanance api maintain_data';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           /* End of fix for Bug : 5144013*/

            --log1('PBL 29 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Calling rollup budget version api';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           --log1('----- STAGE PBL18.3------- ');
           --log1('PBL 30 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION
                 ( p_budget_version_id     => p_budget_version_id
                  ,p_entire_version        => 'Y'
                  ,x_return_status         => x_return_status
                  ,x_msg_count             => l_msg_count
                  ,x_msg_data              => l_msg_data);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:='The API PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION returned error';
                         pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
           --log1('PBL 31 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage := 'Checking whether MRC api needs to be called';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           --log1('----- STAGE PBL18.4------- ');

    /**************MRC ELIMINATION CHANGES: ********************************
     ** The following api calls are used for populating the mrc data which is not required
     ** as the mrc schema and entity are scrapped from R12
           PA_MRC_FINPLAN.check_mrc_install
                  (x_return_status        => x_return_status,
                   x_msg_count            => l_msg_count,
                   x_msg_data             => l_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='The API PA_MRC_FINPLAN.check_mrc_installed returned error';
                   pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

           --log1('PBL 32 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           -- checking for valid requiered parameter values to call the MRC api
           IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
               PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
                  IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'Calling MRC api ';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;
                          --log1('PBL 33 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
                  PA_MRC_FINPLAN.maintain_all_mc_budget_lines
                      (p_fin_plan_version_id  => p_budget_version_id,
                       p_entire_version       => 'N',
                       x_return_status        => x_return_status,
                       x_msg_count            => l_msg_count,
                       x_msg_data             => l_msg_data);
                       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            IF l_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:='The API PA_MRC_FINPLAN.maintain_all_mc_budget_lines returned error';
                                pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
                            END IF;
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END IF;
                    --log1('PBL 34 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           ELSE
                  IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'MRC api need not be called';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;
           END IF;
    ***************End of MRC ELIMINATION CHANGES: ***********************/

           --log1('----- STAGE PBL18.5------- ');
           IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage := 'Data prepared for the call to PJI api';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 pa_debug.Reset_Curr_Function;
           END IF;
           --log1('----- STAGE PBL18.6------- ');
           --log1('PBL 37'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
           --Bug 4424457. Replaced the call to plan_update with plan_delete and plan_create
           l_dest_ver_id_tbl.EXTEND;
           l_dest_ver_id_tbl(1):=p_budget_version_id;
           PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE (
              p_fp_version_ids   => l_dest_ver_id_tbl,
              x_return_status    => x_return_status,
              x_msg_code         => l_error_msg_code);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
               IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'API PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE returned ERROR 1 '|| l_error_msg_code;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
               END IF;

               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;


            PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE(p_fp_version_ids => l_dest_ver_id_tbl
                                              ,x_return_status  => l_return_status
                                              ,x_msg_code       => l_error_msg_code);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            --log1('PBL 38 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
            -- deleting contents from pl/sql tables to be used to call pji api
            l_pji_res_ass_id_tbl.DELETE;
            l_pji_period_name_tbl.DELETE;
            l_pji_start_date_tbl.DELETE;
            l_pji_end_date_tbl.DELETE;
            l_pji_txn_curr_code_tbl.DELETE;
            l_pji_txn_raw_cost_tbl.DELETE;
            l_pji_txn_burd_cost_tbl.DELETE;
            l_pji_txn_revenue_tbl.DELETE;
            l_pji_project_raw_cost_tbl.DELETE;
            l_pji_project_burd_cost_tbl.DELETE;
            l_pji_project_revenue_tbl.DELETE;
            l_pji_raw_cost_tbl.DELETE;
            l_pji_burd_cost_tbl.DELETE;
            l_pji_revenue_tbl.DELETE;
            l_pji_cost_rej_code_tbl.DELETE;
            l_pji_revenue_rej_code_tbl.DELETE;
            l_pji_burden_rej_code_tbl.DELETE;
            l_pji_other_rej_code.DELETE;
            l_pji_pc_cur_conv_rej_code_tbl.DELETE;
            l_pji_pf_cur_conv_rej_code_tbl.DELETE;
            l_pji_quantity_tbl.DELETE;
            l_upd_pj_cost_rate_typ_tbl.DELETE;
            l_upd_pj_cost_exc_rate_tbl.DELETE;
            l_upd_pj_cost_rate_dt_typ_tbl.DELETE;
            l_upd_pj_cost_rate_date_tbl.DELETE;
            l_upd_pj_rev_rate_typ_tbl.DELETE;
            l_upd_pj_rev_exc_rate_tbl.DELETE;
            l_upd_pj_rev_rate_dt_typ_tbl.DELETE;
            l_upd_pj_rev_rate_date_tbl.DELETE;
            l_upd_pf_cost_rate_typ_tbl.DELETE;
            l_upd_pf_cost_exc_rate_tbl.DELETE;
            l_upd_pf_cost_rate_dt_typ_tbl.DELETE;
            l_upd_pf_cost_rate_date_tbl.DELETE;
            l_upd_pf_rev_rate_typ_tbl.DELETE;
            l_upd_pf_rev_exc_rate_tbl.DELETE;
            l_upd_pf_rev_rate_dt_typ_tbl.DELETE;
            l_upd_pf_rev_rate_date_tbl.DELETE;
            l_upd_budget_line_id_tbl.DELETE;
            l_upd_init_quantity_tbl.DELETE;
            l_upd_init_raw_cost_tbl.DELETE;
            l_upd_init_burdened_cost_tbl.DELETE;
            l_upd_init_revenue_tbl.DELETE;
            l_upd_proj_init_raw_cost_tbl.DELETE;
            l_upd_proj_init_burd_cost_tbl.DELETE;
            l_upd_proj_init_revenue_tbl.DELETE;
            l_upd_txn_init_raw_cost_tbl.DELETE;
            l_upd_txn_init_burd_cost_tbl.DELETE;
            l_upd_txn_init_revenue_tbl.DELETE;
            l_upd_delete_flag_tbl.DELETE;

        END IF;--       IF l_bls_proccessed_flag ='Y' OR
               --      l_bl_del_flag_ra_id_tbl.COUNT > 0 THEN

        --log1('PBL 39 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Leaving process_budget_lines';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             pa_debug.Reset_Curr_Function;
        END IF;
EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Just_Ret_Exc THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
            END IF;
            RETURN;
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count = 1 and x_msg_data IS NULL THEN
                   PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                     ,p_msg_index      => 1
                     ,p_msg_count      => l_msg_count
                     ,p_msg_data       => l_msg_data
                     ,p_data           => l_data
                     ,p_msg_index_out  => l_msg_index_out);
                   x_msg_data := l_data;
                   x_msg_count := l_msg_count;
            ELSE
                  x_msg_count := l_msg_count;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
            END IF;
            RETURN;

      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                                  ,p_procedure_name  => 'process_budget_lines');
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;

          IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
          END IF;
          RAISE;

END process_budget_lines;

--This procedure will update the budget version and its corresponding data in the interface table with
--the latest request id and plan processing code(XLUP/XLUE).
PROCEDURE update_xl_data_for_new_req
(p_request_id              IN    pa_budget_versions.request_id%TYPE,
 p_run_id                  IN    pa_fp_webadi_upload_inf.run_id%TYPE,
 p_plan_processing_code    IN    pa_budget_versions.plan_processing_code%TYPE,
 p_budget_version_id       IN    pa_budget_versions.budget_version_id%TYPE,
 p_null_out_cols           IN    VARCHAR2)
IS
BEGIN

    --Record Version Number is not updated since the web ADI code checks the record Version Number at downloand
    --with the record version number at upload and throws an error if they dont match.
    UPDATE pa_budget_versions
    SET    request_id = p_request_id,
           plan_processing_code=p_plan_processing_code
    WHERE  budget_version_id = p_budget_version_id;

    --NULL out the IDS and values derived in the previous call to Switcher API do that all the validations
    --are done again
    UPDATE pa_fp_webadi_upload_inf
    SET    task_id                =DECODE(p_null_out_cols,'Y',NULL,task_id),
           resource_list_member_id=DECODE(p_null_out_cols,'Y',NULL,resource_list_member_id),
           val_error_flag         =DECODE(p_null_out_cols,'Y',NULL,val_error_flag),
           val_error_code         =DECODE(p_null_out_cols,'Y',NULL,val_error_code),
           err_task_name          =DECODE(p_null_out_cols,'Y',NULL,err_task_name),
           err_task_number        =DECODE(p_null_out_cols,'Y',NULL,err_task_number),
           err_alias              =DECODE(p_null_out_cols,'Y',NULL,err_alias),
           err_amount_type_code   =DECODE(p_null_out_cols,'Y',NULL,err_amount_type_code),
           request_id=p_request_id
   WHERE   run_id=p_run_id
   AND     request_id IS NULL;

END;

PROCEDURE switcher
(x_return_status                OUT                NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                    OUT                NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                     OUT                NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_submit_budget_flag           IN                 VARCHAR2,
 p_run_id                       IN                 pa_fp_webadi_upload_inf.run_id%TYPE,
 x_success_msg                  OUT                NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_submit_forecast_flag         IN                 VARCHAR2,
 p_request_id                   IN                 pa_budget_versions.request_id%TYPE,
 p_calling_mode                 IN                 VARCHAR2)

 IS
  -- variables used for debugging
  l_module_name                   VARCHAR2(100) := 'pa_fp_webadi_pkg.switcher';
  l_debug_mode                    VARCHAR2(1) := 'N';
  l_debug_level3                  CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
  l_debug_level5                  CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;

  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  l_data                          VARCHAR2(2000);
  l_msg_index_out                 NUMBER;

  l_budget_version_id             pa_budget_versions.budget_version_id%TYPE;
  l_rec_version_number            pa_budget_versions.record_version_number%TYPE;
  l_pm_rec_version_number         pa_period_masks_b.record_version_number%TYPE;
  l_project_id                    pa_projects_all.project_id%TYPE;
  l_org_id                        pa_projects_all.org_id%TYPE;
  l_version_info_rec              pa_fp_gen_amount_utils.fp_cols;

  -- variable to held the start_date and end_date of individual periods
  l_prd_start_date_tbl            SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
  l_prd_end_date_tbl              SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();

  l_budget_line_in_tbl            PA_BUDGET_PUB.G_budget_lines_in_tbl%TYPE;
  l_bl_raw_cost_rate_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_bl_burd_cost_rate_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_bl_bill_rate_tbl              SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_bl_plan_start_date_tbl        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
  l_bl_plan_end_date_tbl          SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
  l_bl_uom_tbl                    SYSTEM.pa_varchar2_80_tbl_type  := SYSTEM.pa_varchar2_80_tbl_type();
  l_mfc_cost_type_tbl             SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
  l_spread_curve_name_tbl         SYSTEM.PA_VARCHAR2_240_TBL_TYPE :=  SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
  l_sp_fixed_date_tbl             SYSTEM.PA_DATE_TBL_TYPE         := SYSTEM.PA_DATE_TBL_TYPE();
  l_sp_fixed_date_tbl_1             SYSTEM.PA_DATE_TBL_TYPE         := SYSTEM.PA_DATE_TBL_TYPE();
  l_etc_method_name_tbl           SYSTEM.PA_VARCHAR2_80_TBL_TYPE  := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  l_spread_curve_id_tbl           SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
  l_spread_curve_id_tbl_1           SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();

  l_amount_set_id                 pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
  l_allow_qty_flag                VARCHAR2(1);

  l_set_ppc_flag_on_err           VARCHAR2(1);

  l_budget_line_out_tbl           PA_BUDGET_PUB.G_budget_lines_out_tbl%TYPE;
  l_delete_flag_tbl               SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
  l_delete_flag_tbl_1               SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();

  i                               INTEGER;
  l_error_indicator_flag          VARCHAR2(1);

  l_mfc_cost_type_id_tbl          SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_mfc_cost_type_id_tbl_1          SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type();
  l_etc_method_code_tbl           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
  l_etc_method_code_tbl_1           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

  is_periodic_setup               VARCHAR2(1) := 'N';
  l_prep_pbl_calling_context      VARCHAR2(30);
  l_plan_class_code               pa_fin_plan_types_b.plan_class_code%TYPE;

  l_ra_id_tbl                        SYSTEM.pa_num_tbl_type;
  l_task_id_tbl                      SYSTEM.pa_num_tbl_type;
  l_rlm_id_tbl                       SYSTEM.pa_num_tbl_type;
  l_txn_currency_code_tbl            SYSTEM.pa_varchar2_15_tbl_type;
  l_planning_start_date_tbl          SYSTEM.pa_date_tbl_type;
  l_planning_end_date_tbl            SYSTEM.pa_date_tbl_type;
  l_total_qty_tbl                    SYSTEM.pa_num_tbl_type;
  l_total_raw_cost_tbl               SYSTEM.pa_num_tbl_type;
  l_total_burdened_cost_tbl          SYSTEM.pa_num_tbl_type;
  l_total_revenue_tbl                SYSTEM.pa_num_tbl_type;
  l_raw_cost_rate_tbl                SYSTEM.pa_num_tbl_type;
  l_burdened_cost_rate_tbl           SYSTEM.pa_num_tbl_type;
  l_bill_rate_tbl                    SYSTEM.pa_num_tbl_type;
  l_line_start_date_tbl              SYSTEM.pa_date_tbl_type;
  l_line_end_date_tbl                SYSTEM.pa_date_tbl_type;
  l_proj_cost_rate_type_tbl          SYSTEM.pa_varchar2_30_tbl_type;
  l_proj_cost_rate_date_type_tbl     SYSTEM.pa_varchar2_30_tbl_type;
  l_proj_cost_rate_tbl               SYSTEM.pa_num_tbl_type;
  l_proj_cost_rate_date_tbl          SYSTEM.pa_date_tbl_type;
  l_proj_rev_rate_type_tbl           SYSTEM.pa_varchar2_30_tbl_type;
  l_proj_rev_rate_date_type_tbl      SYSTEM.pa_varchar2_30_tbl_type;
  l_proj_rev_rate_tbl                SYSTEM.pa_num_tbl_type;
  l_proj_rev_rate_date_tbl           SYSTEM.pa_date_tbl_type;
  l_pfunc_cost_rate_type_tbl         SYSTEM.pa_varchar2_30_tbl_type;
  l_pfunc_cost_rate_date_typ_tbl     SYSTEM.pa_varchar2_30_tbl_type;
  l_pfunc_cost_rate_tbl              SYSTEM.pa_num_tbl_type;
  l_pfunc_cost_rate_date_tbl         SYSTEM.pa_date_tbl_type;
  l_pfunc_rev_rate_type_tbl          SYSTEM.pa_varchar2_30_tbl_type;
  l_pfunc_rev_rate_date_type_tbl     SYSTEM.pa_varchar2_30_tbl_type;
  l_pfunc_rev_rate_tbl               SYSTEM.pa_num_tbl_type;
  l_pfunc_rev_rate_date_tbl          SYSTEM.pa_date_tbl_type;
  l_change_reason_code_tbl           SYSTEM.pa_varchar2_30_tbl_type;
  l_description_tbl                  SYSTEM.pa_varchar2_2000_tbl_type;
  l_etc_quantity_tbl                 SYSTEM.pa_num_tbl_type;
  l_etc_raw_cost_tbl                 SYSTEM.pa_num_tbl_type;
  l_etc_burdened_cost_tbl            SYSTEM.pa_num_tbl_type;
  l_etc_revenue_tbl                  SYSTEM.pa_num_tbl_type;
  l_res_class_code_tbl               SYSTEM.pa_varchar2_30_tbl_type;
  l_rate_based_flag_tbl              SYSTEM.pa_varchar2_1_tbl_type;
  l_rbs_elem_id_tbl                  SYSTEM.pa_num_tbl_type;
  l_amt_type_tbl                     SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_prc_ra_id_tbl                    SYSTEM.pa_num_tbl_type;
  l_prc_res_class_code_tbl           SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_prc_rate_based_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
  l_prc_rbs_elem_id_tbl              SYSTEM.pa_num_tbl_type;

  CURSOR l_prd_start_end_date_csr (c_org_id                  pa_projects_all.org_id%TYPE,
                                   c_prd_mask_id             pa_proj_fp_options.cost_period_mask_id%TYPE,
                                   c_time_phased_code        pa_proj_fp_options.cost_time_phased_code%TYPE,
                                   c_current_planning_period pa_proj_fp_options.cost_current_planning_period%TYPE)
  IS
  SELECT glsd.start_date start_date,
         gled.end_date end_date
  FROM   (SELECT ROW_NUMBER() OVER(PARTITION BY gl.period_set_name,gl.period_type
                 ORDER BY gl.start_date) rn,
                 gl.start_date start_date,
                 gl.end_Date  end_date,
                 gl.period_name period_name,
                 gl.period_set_name period_set_name,
                 gl.period_type period_type
          FROM   gl_periods gl,
                 pa_implementations_all pim,
                 gl_sets_of_books gsb
          WHERE  gl.period_set_name = DECODE(c_time_phased_code,'P',pim.period_set_name,'G',gsb.period_set_name)
          AND    gl.period_type = DECODE(c_time_phased_code,'P',pim.pa_period_type,'G',gsb.accounted_period_type)
          AND    gl.adjustment_period_flag='N'
          AND    pim.org_id = c_org_id
          AND    gsb.set_of_books_id = pim.set_of_books_id) glsd,
         (SELECT ROW_NUMBER() OVER(PARTITION BY gl.period_set_name,gl.period_type
                 ORDER BY gl.start_date) rn,
                 gl.start_date start_date,
                 gl.end_Date  end_date,
                 gl.period_name period_name,
                 gl.period_set_name period_set_name,
                 gl.period_type period_type
          FROM   gl_periods gl,
                 pa_implementations_all pim,
                 gl_sets_of_books gsb
          WHERE  gl.period_set_name = DECODE(c_time_phased_code,'P',pim.period_set_name,'G',gsb.period_set_name)
          AND    gl.period_type = DECODE(c_time_phased_code,'P',pim.pa_period_type,'G',gsb.accounted_period_type)
          AND    gl.adjustment_period_flag='N'
          AND    pim.org_id = c_org_id
          AND    gsb.set_of_books_id = pim.set_of_books_id) gled,
         (SELECT ROW_NUMBER() OVER(PARTITION BY gl.period_set_name,gl.period_type
                 ORDER BY gl.start_date) rn,
                 gl.start_date start_date,
                 gl.end_Date  end_date,
                 gl.period_name period_name,
                 gl.period_set_name period_set_name,
                 gl.period_type period_type
          FROM   gl_periods gl,
                 pa_implementations_all pim,
                 gl_sets_of_books gsb
          WHERE  gl.period_set_name = DECODE(c_time_phased_code,'P',pim.period_set_name,'G',gsb.period_set_name)
          AND    gl.period_type = DECODE(c_time_phased_code,'P',pim.pa_period_type,'G',gsb.accounted_period_type)
          AND    gl.adjustment_period_flag='N'
          AND    pim.org_id = c_org_id
          AND    gsb.set_of_books_id = pim.set_of_books_id)glcp,
          pa_period_mask_details pmd
  WHERE  pmd.period_mask_id = c_prd_mask_id
  AND    glcp.period_name = c_current_planning_period
  AND    glsd.rn = pmd.from_anchor_start + glcp.rn
  AND    gled.rn = pmd.from_anchor_end + glcp.rn
  AND    pmd.from_anchor_position NOT IN (99999,-99999)
  ORDER BY pmd.from_anchor_position;

  l_prd_date_rec            l_prd_start_end_date_csr%ROWTYPE;
  l_submit_flag             VARCHAR2(1);
  l_profile_val             VARCHAR2(30);
  l_profile_thsld_val       NUMBER;
  l_profile_thsld_num       NUMBER;
  l_etc_start_date          pa_budget_versions.etc_start_date%TYPE;
  l_request_id              NUMBER;
  l_rollback_flag           VARCHAR2(1);
  l_first_pd_bf_pm_en_dt    DATE;
  l_last_pd_af_pm_st_dt     DATE;
  l_inf_tbl_rec_tbl         inf_cur_tbl_typ;
  l_record_counter          NUMBER;


BEGIN
    --log1('Begin '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    l_rollback_flag := 'N';
    COMMIT;  /*  Added this for bug 3736220

             Reason: To display budget client extension error messages customized by the Customers
             we need to stamp the val_error_code and val_error_flag of PA_FP_WEBADI_UPLOAD_INF table
             Only then these error messages will appear in Excel Sheet itself when any failure happens
             during upload.

             Code flow is designed as follows:
             1. When user clicks on Oracle Upload Toolbar Menu item in Excel
                the WEB ADI related procedures will populate PA_FP_WEBADI_UPLOAD_INF table and does not commit

             2. Switcher API will be invoked after WEB ADI related code flow is completed.

             3. Swicher API internally invokes PA_FP_CALC_PLAN_PKG.CALCULATE which inturn
                invokes the actual budget client extension

             4. In client extension, as part of bug fix 3736220 added code to Stamp client extension errors
                in xface table (we stamp the val_error_code and val_error_flag of
                PA_FP_WEBADI_UPLOAD_INF table)

             5. But the client extension is designed in such a way that when any error occurs in
                client extension we roll back to the calling API PA_FP_CALC_PLAN_PKG. So the stamped data
                gets rolled back. Ulimately the customers customized errors cannot be displayed in excel
                due to this rollback.

              6. Hence in order to preserve the stamped  val_error_code and val_error_flag
                 of PA_FP_WEBADI_UPLOAD_INF table,introduced an autonomous procedure Stamp_Client_Extn_Errors

              7. As a result if we dont commit in the beginning when SWITCHER API is called, then when
                 Stamp_Client_Extn_Errors APi is invoked there will be no records in PA_FP_WEBADI_UPLOAD_INF.
            */

  fnd_profile.get('PA_DEBUG_MODE', l_debug_mode);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

  -- initializing the translated out message string
  x_success_msg := FND_MESSAGE.GET_STRING
                        (APPIN   => 'PA',
                         NAMEIN  => 'PA_FP_UPL_ONLINE_SUCC_MSG');

  IF l_debug_mode = 'Y' THEN
        pa_debug.Set_Curr_Function
                    (p_function   => l_module_name,
                     p_debug_mode => l_debug_mode);
  END IF;

  --log1('----- Entering Switcher api -------');

  -- validating input parameter
  IF p_run_id IS NULL THEN
       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'p_run_id is passed as null';
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Entering into switcher';
        pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
        pa_debug.g_err_stage := 'Fetching the header level info from tmp tbl';
        pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
  END IF;

  l_submit_flag:='N';
  IF p_submit_forecast_flag='Y' OR p_submit_budget_flag ='Y' THEN

       l_submit_flag:='Y';

  END IF;


  BEGIN
        SELECT  budget_version_id,
                record_version_number,
                prd_mask_rec_ver_number
        INTO    l_budget_version_id,
                l_rec_version_number,
                l_pm_rec_version_number
        FROM    pa_fp_webadi_upload_inf
        WHERE   run_id = p_run_id
        AND    Nvl(p_request_id, -99) = Nvl(request_id, -99)
        AND     rownum = 1;
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
             IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage := 'No data found while reading header info';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
  END;


  --Find out whether the layout is a periodic layout or not. This can be done by looking at the amount type column
  --in the table since it will be populated only for periodic layouts.
  BEGIN
        SELECT  'Y'
        INTO    is_periodic_setup
        FROM    DUAL
        WHERE EXISTS(SELECT  'X'
                     FROM    pa_fp_webadi_upload_inf
                     WHERE   amount_type_name IS NOT NULL
                     AND     run_id = p_run_id
                     AND    Nvl(p_request_id, -99) = Nvl(request_id, -99));
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
             is_periodic_setup := 'N';
  END;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'is_periodic_setup: =' || is_periodic_setup;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  -- throwing error if the header level info is missing
  IF l_budget_version_id IS NULL OR
     l_rec_version_number IS NULL  OR
     (is_periodic_setup='Y' AND l_pm_rec_version_number IS NULL) THEN
        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Header level values are null in interface table';
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => l_module_name);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
  END IF;


  --log1('----- STAGE 1-------');

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Deriving project id';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  BEGIN
       SELECT  bv.project_id,
               Nvl(pl.org_id, -99),
               etc_start_date
       INTO    l_project_id,
               l_org_id,
               l_etc_start_date
       FROM    pa_budget_versions bv,
               pa_projects_all pl
       WHERE   bv.budget_version_id = l_budget_version_id
       AND     bv.project_id = pl.project_id;
  EXCEPTION
       WHEN NO_DATA_FOUND THEN
             IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage := 'No data found while reading project id ..';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             END IF;
            UPDATE pa_fp_webadi_upload_inf
            SET    val_error_flag       = 'Y',
                   val_error_code       = 'PA_FP_WEBADI_VER_MODIFIED',
                   err_task_name        = nvl(task_name,'-98'),
                   err_task_number      = nvl(task_number,'-98'),
                   err_alias            = nvl(resource_alias,'-98'),
                   err_amount_type_code = nvl(amount_type_code,'-98')
            WHERE  run_id=p_run_id
            AND     Nvl(p_request_id, -99) = Nvl(request_id, -99);

            x_return_status := FND_API.G_RET_STS_ERROR;
            IF l_debug_mode = 'Y' THEN
               pa_debug.reset_curr_function;
            END IF;

             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
  END;

  --log1('----- STAGE 2-------');

  MO_GLOBAL.SET_POLICY_CONTEXT('S',l_org_id);

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Calling pa_fp_gen_amount_utils.get_plan_version_dtls';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;
  --log1('----- STAGE 2.1-------'||l_project_id);
    --log1('----- STAGE 2.2-------'||l_budget_version_id);
  pa_fp_gen_amount_utils.get_plan_version_dtls
        (p_project_id          => l_project_id,
         p_budget_version_id   => l_budget_version_id,
         x_fp_cols_rec         => l_version_info_rec,
         x_return_status       => x_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Call to get_plan_version_dtls returned with error';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
  --log1('----- STAGE 2.3-------'||x_return_status);
    --log1('----- STAGE 2.4-------'||l_budget_version_id);

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Calling validate_header_info';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  --log1('----- STAGE 3-------');
    --log1('1 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
  validate_header_info
     ( p_calling_mode           => p_calling_mode,
       p_run_id                 => p_run_id,
       p_budget_version_id      => l_budget_version_id,
       p_record_version_number  => l_rec_version_number,
       p_pm_rec_version_number  => l_pm_rec_version_number,
       p_submit_flag            => l_submit_flag,
       p_request_id             => p_request_id,
       x_return_status          => x_return_status,
       x_msg_data               => l_msg_count,
       x_msg_count              => l_msg_data);
    --log1('2 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Call to validate_header_info returned with error';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

  -- checking, if the layout is periodic one
  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Checking for periodic setup';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  --log1('----- STAGE 4-------');

  --log1('----- STAGE 5-------');
  --dbms_output.put_line('--------l_org_id ---------' || l_org_id);
  --dbms_output.put_line('--------l_version_info_rec.x_period_mask_id---------' || l_version_info_rec.x_period_mask_id);
  --dbms_output.put_line('--------l_version_info_rec.x_time_phased_code ---------' || l_version_info_rec.x_time_phased_code);
  --dbms_output.put_line('--------l_version_info_rec.x_current_planning_period ---------' ||l_version_info_rec.x_current_planning_period);
  -- populating the tables for period start/end date to be passed to prepare_val_input
  -- if the version is time phased and the layout is periodic
  IF l_version_info_rec.x_time_phased_code <> 'N' AND
     is_periodic_setup = 'Y' THEN
        OPEN l_prd_start_end_date_csr(l_org_id,
                                      l_version_info_rec.x_period_mask_id,
                                      l_version_info_rec.x_time_phased_code,
                                      l_version_info_rec.x_current_planning_period);
        /*LOOP*/
              FETCH l_prd_start_end_date_csr
              BULK COLLECT INTO  /*l_prd_date_rec;*/
              l_prd_start_date_tbl,
              l_prd_end_date_tbl;
              /*EXIT WHEN l_prd_date_rec.start_date IS NULL;

              l_prd_start_date_tbl.EXTEND(1);
              l_prd_start_date_tbl(l_prd_start_date_tbl.COUNT) := l_prd_date_rec.start_date;
              l_prd_end_date_tbl.EXTEND(1);
              l_prd_end_date_tbl(l_prd_end_date_tbl.COUNT) := l_prd_date_rec.end_date;
        END LOOP;*/
        CLOSE l_prd_start_end_date_csr;

  END IF; -- if periodic

  --dbms_output.put_line('--------l_prd_start_date_tbl.COUNT ---------' || l_prd_start_date_tbl.COUNT);
  --dbms_output.put_line('--------l_prd_end_date_tbl.COUNT ---------' || l_prd_end_date_tbl.COUNT);

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Calling prepare_val_input';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  --log1('----- STAGE 6-------');
 --log1('3 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

  IF is_periodic_setup = 'Y' THEN
        prepare_val_input
           ( p_run_id                   => p_run_id,
             p_request_id               => p_request_id,
             p_version_info_rec         => l_version_info_rec,
             p_prd_start_date_tbl       => l_prd_start_date_tbl,
             p_prd_end_date_tbl         => l_prd_end_date_tbl,
             p_org_id                   => l_org_id,
             x_budget_lines             => l_budget_line_in_tbl,
             x_etc_quantity_tbl         => l_etc_quantity_tbl,
             x_etc_raw_cost_tbl         => l_etc_raw_cost_tbl,
             x_etc_burdened_cost_tbl    => l_etc_burdened_cost_tbl,
             x_etc_revenue_tbl          => l_etc_revenue_tbl,
             x_raw_cost_rate_tbl        => l_bl_raw_cost_rate_tbl,
             x_burd_cost_rate_tbl       => l_bl_burd_cost_rate_tbl,
             x_bill_rate_tbl            => l_bl_bill_rate_tbl,
             x_planning_start_date_tbl  => l_bl_plan_start_date_tbl,
             x_planning_end_date_tbl    => l_bl_plan_end_date_tbl,
             x_uom_tbl                  => l_bl_uom_tbl,
             x_mfc_cost_type_tbl        => l_mfc_cost_type_tbl,
             x_spread_curve_name_tbl    => l_spread_curve_name_tbl,
             x_sp_fixed_date_tbl        => l_sp_fixed_date_tbl,
             x_etc_method_name_tbl      => l_etc_method_name_tbl,
             x_spread_curve_id_tbl      => l_spread_curve_id_tbl,
             x_delete_flag_tbl          => l_delete_flag_tbl,
             x_ra_id_tbl                => l_ra_id_tbl,
             x_res_class_code_tbl       => l_res_class_code_tbl,
             x_rate_based_flag_tbl      => l_rate_based_flag_tbl,
             x_rbs_elem_id_tbl          => l_rbs_elem_id_tbl,
             x_amt_type_tbl             => l_amt_type_tbl,
             x_first_pd_bf_pm_en_dt     => l_first_pd_bf_pm_en_dt,
             x_last_pd_af_pm_st_dt      => l_last_pd_af_pm_st_dt,
             x_inf_tbl_rec_tbl          => l_inf_tbl_rec_tbl,
             x_num_of_rec_processed     => l_record_counter,
             x_return_status            => x_return_status,
             x_msg_count                => l_msg_count,
             x_msg_data                 => l_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Call to prepare_val_input returned with error';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
  ELSE
        prepare_val_input
           ( p_run_id                   => p_run_id,
             p_request_id               => p_request_id,
             p_version_info_rec         => l_version_info_rec,
             p_prd_start_date_tbl       => l_prd_start_date_tbl,
             p_prd_end_date_tbl         => l_prd_end_date_tbl,
             p_org_id                   => l_org_id,
             x_budget_lines             => l_budget_line_in_tbl,
             x_etc_quantity_tbl         => l_etc_quantity_tbl,
             x_etc_raw_cost_tbl         => l_etc_raw_cost_tbl,
             x_etc_burdened_cost_tbl    => l_etc_burdened_cost_tbl,
             x_etc_revenue_tbl          => l_etc_revenue_tbl,
             x_raw_cost_rate_tbl        => l_bl_raw_cost_rate_tbl,
             x_burd_cost_rate_tbl       => l_bl_burd_cost_rate_tbl,
             x_bill_rate_tbl            => l_bl_bill_rate_tbl,
             x_planning_start_date_tbl  => l_bl_plan_start_date_tbl,
             x_planning_end_date_tbl    => l_bl_plan_end_date_tbl,
             x_uom_tbl                  => l_bl_uom_tbl,
             x_mfc_cost_type_tbl        => l_mfc_cost_type_tbl,
             x_spread_curve_name_tbl    => l_spread_curve_name_tbl,
             x_sp_fixed_date_tbl        => l_sp_fixed_date_tbl,
             x_etc_method_name_tbl      => l_etc_method_name_tbl,
             x_spread_curve_id_tbl      => l_spread_curve_id_tbl,
             x_delete_flag_tbl          => l_delete_flag_tbl,
             x_ra_id_tbl                => l_ra_id_tbl,
             x_res_class_code_tbl       => l_res_class_code_tbl,
             x_rate_based_flag_tbl      => l_rate_based_flag_tbl,
             x_rbs_elem_id_tbl          => l_rbs_elem_id_tbl,
             x_amt_type_tbl             => l_amt_type_tbl,
             x_first_pd_bf_pm_en_dt     => l_first_pd_bf_pm_en_dt,
             x_last_pd_af_pm_st_dt      => l_last_pd_af_pm_st_dt,
             x_inf_tbl_rec_tbl          => l_inf_tbl_rec_tbl,
             x_num_of_rec_processed     => l_record_counter,
             x_return_status            => x_return_status,
             x_msg_count                => l_msg_count,
             x_msg_data                 => l_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'Call to prepare_val_input returned with error';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
  END IF; -- periodic check
    --log1('3 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    --log1('3.1 '||l_inf_tbl_rec_tbl.count);
  --log1('----- STAGE 7------- l_budget_line_in_tbl.count '||l_budget_line_in_tbl.count);
  -- getting other required information to call validate_budget_lines

  IF l_version_info_rec.x_version_type = 'COST' THEN
          l_allow_qty_flag := l_version_info_rec.x_cost_quantity_flag;
  ELSIF l_version_info_rec.x_version_type = 'REVENUE' THEN
          l_allow_qty_flag := l_version_info_rec.x_rev_quantity_flag;
  ELSIF l_version_info_rec.x_version_type = 'ALL' THEN
          l_allow_qty_flag := l_version_info_rec.x_all_quantity_flag;
  END IF;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Calling validate_budget_lines';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;
    --log1('4 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

  l_spread_curve_id_tbl_1 := l_spread_curve_id_tbl;
  pa_budget_pvt.validate_budget_lines
     (p_run_id                          => p_run_id
     ,p_calling_context                 => 'WEBADI'
     ,p_pa_project_id                   => l_version_info_rec.x_project_id
     ,p_budget_type_code                => null     -- pass null
     ,p_fin_plan_type_id                => l_version_info_rec.x_fin_plan_type_id
     ,p_version_type                    => l_version_info_rec.x_version_type
     ,p_resource_list_id                => l_version_info_rec.x_resource_list_id
     ,p_time_phased_code                => l_version_info_rec.x_time_phased_code
     ,p_budget_entry_method_code        => null -- pass null
     ,p_entry_level_code                => l_version_info_rec.x_fin_plan_level_code
     ,p_allow_qty_flag                  => l_allow_qty_flag
     ,p_allow_raw_cost_flag             => l_version_info_rec.x_raw_cost_flag
     ,p_allow_burdened_cost_flag        => l_version_info_rec.x_burdened_flag
     ,p_allow_revenue_flag              => l_version_info_rec.x_revenue_flag
     ,p_multi_currency_flag             => l_version_info_rec.x_plan_in_multi_curr_flag
     ,p_project_cost_rate_type          => null
     ,p_project_cost_rate_date_typ      => null
     ,p_project_cost_rate_date          => null
     ,p_project_cost_exchange_rate      => null
     ,p_projfunc_cost_rate_type         => null
     ,p_projfunc_cost_rate_date_typ     => null
     ,p_projfunc_cost_rate_date         => null
     ,p_projfunc_cost_exchange_rate     => null
     ,p_project_rev_rate_type           => null
     ,p_project_rev_rate_date_typ       => null
     ,p_project_rev_rate_date           => null
     ,p_project_rev_exchange_rate       => null
     ,p_projfunc_rev_rate_type          => null
     ,p_projfunc_rev_rate_date_typ      => null
     ,p_projfunc_rev_rate_date          => null
     ,p_projfunc_rev_exchange_rate      => null
     ,p_version_info_rec                => l_version_info_rec
     ,p_allow_raw_cost_rate_flag        => l_version_info_rec.x_cost_rate_flag
     ,p_allow_burd_cost_rate_flag       => l_version_info_rec.x_burden_rate_flag
     ,p_allow_bill_rate_flag            => l_version_info_rec.x_bill_rate_flag
     ,p_raw_cost_rate_tbl               => l_bl_raw_cost_rate_tbl
     ,p_burd_cost_rate_tbl              => l_bl_burd_cost_rate_tbl
     ,p_bill_rate_tbl                   => l_bl_bill_rate_tbl
     ,p_uom_tbl                         => l_bl_uom_tbl
     ,p_planning_start_date_tbl         => l_bl_plan_start_date_tbl
     ,p_planning_end_date_tbl           => l_bl_plan_end_date_tbl
     ,p_delete_flag_tbl                 => l_delete_flag_tbl
     ,p_mfc_cost_type_tbl               => l_mfc_cost_type_tbl
     ,p_spread_curve_name_tbl           => l_spread_curve_name_tbl
     ,p_sp_fixed_date_tbl               => l_sp_fixed_date_tbl
     ,p_etc_method_name_tbl             => l_etc_method_name_tbl
     ,p_spread_curve_id_tbl             => l_spread_curve_id_tbl_1
     ,p_amount_type_tbl                 => l_amt_type_tbl
     ,px_budget_lines_in                => l_budget_line_in_tbl
     ,x_budget_lines_out                => l_budget_line_out_tbl
     ,x_mfc_cost_type_id_tbl            => l_mfc_cost_type_id_tbl
     ,x_etc_method_code_tbl             => l_etc_method_code_tbl
     ,x_spread_curve_id_tbl             => l_spread_curve_id_tbl
     ,x_msg_count                       => l_msg_count
     ,x_msg_data                        => l_msg_data
     ,x_return_status                   => x_return_status);
    --log1('5 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Call to validate_budget_lines returned with error';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
  --log1('----- STAGE 9------- l_budget_line_in_tbl.count '||l_budget_line_in_tbl.count);

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Call to  validate_budget_lines is complete';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      pa_debug.g_err_stage := 'Checking for errors';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  BEGIN
        SELECT 'X'
        INTO   l_error_indicator_flag
        FROM   DUAL
        WHERE  EXISTS (SELECT  'Y'
                       FROM    pa_fp_webadi_upload_inf inf
                       WHERE   run_id = p_run_id
                       AND     Nvl(p_request_id, -99) = Nvl(request_id, -99)
                       AND     (inf.val_error_flag = 'Y'
                       OR       inf.val_error_code IS NOT NULL));
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_error_indicator_flag := 'N';
  END;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'l_error_indicator_flag: ' || l_error_indicator_flag;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  --log1('----- STAGE 10-------');
  IF l_error_indicator_flag = 'X' THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Errors reported in the tmp tbl';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
  END IF;

  -- bug 4428112: add the following procedure to update the txn currency code
  -- if it was not passed earlier, for a non MC enabled version with the validated
  -- currency code as returned from the validate_budget_lines.
  IF l_version_info_rec.x_plan_in_multi_curr_flag = 'N' THEN
        check_and_update_txn_curr_code
            (p_budget_line_tbl  => l_budget_line_in_tbl,
             px_inf_cur_rec_tbl => l_inf_tbl_rec_tbl,
             x_return_status    => x_return_status,
             x_msg_count        => l_msg_count,
             x_msg_data         => l_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Call to check_and_update_txn_curr_code returned with error';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
  END IF;


  -- no errors reported in validate_budget_lines. Check if the processing can happen online or
  --a concurrent request has to be submitted
  IF p_calling_mode = 'STANDARD' THEN
      --log1('----- STAGE 10.1-------');
      -- For values other than site level
      l_profile_val := fnd_profile.value_specific
                     (name              => 'PA_FP_WEBADI_DATA_PRC_MODE',
                      user_id           => fnd_global.user_id,
                      responsibility_id => fnd_global.resp_id,
                      application_id    => 275);
      --log1('----- STAGE 10.2-------');
      IF l_profile_val IS NULL THEN
          -- For values at site level
          --log1('----- STAGE 10.3-------');
          l_profile_val := fnd_profile.value
                           (name => 'PA_FP_WEBADI_DATA_PRC_MODE');
          --log1('----- STAGE 10.4-------');
      END IF;

      IF l_profile_val = 'STANDARD' THEN
          --log1('----- STAGE 10.5-------');
          l_profile_thsld_val := fnd_profile.value_specific
                                 (name              => 'PA_FP_WEBADI_DATA_PRC_THSLD',
                                  user_id           => fnd_global.user_id,
                                  responsibility_id => fnd_global.resp_id,
                                  application_id    => 275);
          --log1('----- STAGE 10.6-------');
          IF l_profile_thsld_val IS NULL THEN
              --log1('----- STAGE 10.7-------');
              l_profile_thsld_val := fnd_profile.value
                                     (name => 'PA_FP_WEBADI_DATA_PRC_THSLD');
          --log1('----- STAGE 10.8-------');
          END IF;

          BEGIN

            SELECT to_number(l_profile_thsld_val)
            INTO   l_profile_thsld_num
            FROM   dual;
            --log1('----- STAGE 10.9-------');
          EXCEPTION
          WHEN INVALID_NUMBER THEN
             --log1('----- STAGE 10.10-------');
             l_profile_thsld_num := 0;
          END;

          IF l_profile_thsld_num < l_record_counter THEN
              --log1('----- STAGE 10.11-------');
              l_set_ppc_flag_on_err :='Y';

              -- bug 5657334: setting the conc program to refer only a single org as the same in the
              -- project context before submitting the request
              fnd_request.set_org_id(l_org_id);
              -- end bug 5657334

              l_request_id := FND_REQUEST.submit_request
                             (application   =>   'PA',
                              program       =>   'PAFPWACP',
                              argument1     =>   l_submit_flag, -- p_submit_ver_flag
                              argument2     =>   p_run_id );    -- p_run_id
              --log1('----- STAGE 10.12-------');
              IF l_request_id =0 THEN
                  --log1('----- STAGE 10.13-------');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

              ELSE
                  --log1('----- STAGE 10.14-------');

                  -- updating the budget version with the request_id
                  UPDATE  pa_budget_versions
                  SET     plan_processing_code = 'XLUP',
                          request_id = l_request_id
                  WHERE   budget_version_id = l_budget_version_id;

                  UPDATE  pa_fp_webadi_upload_inf
                  SET     request_id = l_request_id
                  WHERE   run_id = p_run_id
                  AND     request_id IS NULL;

                  COMMIT; -- is required to query the interface table from conc prog.
                  --log1('----- STAGE 10.15-------');

                  -- If the concurrent request is submitted during upload then the request id should
                  -- be displayed to the user. Hence change the x_success_msg value
                  IF l_request_id IS NOT NULL AND
                     (l_request_id <> -99 OR
                      l_request_id <> -1) THEN
                          FND_MESSAGE.SET_NAME( APPLICATION =>'PA',
                                                NAME        => 'PA_FP_WA_CONC_PRC_RESUB_INFO');

                          FND_MESSAGE.SET_TOKEN(TOKEN     => 'REQUEST_ID',
                                                VALUE     => '' || l_request_id);

                          x_success_msg := FND_MESSAGE.GET;
                  END IF;

                  IF l_debug_mode = 'Y' THEN
                      pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

              END IF;--IF l_request_id =0 THEN

          END IF;--IF l_profile_thsld_num < l_budget_line_in_tbl.COUNT

      END IF;--IF l_profile_val = 'STANDARD' THEN

  END IF;--IF p_calling_mode = 'STANDARD' TEHN
  -- preparing the inputs for preapre_pbl_input

  --log1('----- STAGE 11------- l_budget_line_in_tbl.count'||l_budget_line_in_tbl.count);
  IF is_periodic_setup = 'Y' THEN
        l_prep_pbl_calling_context := 'WEBADI_PERIODIC';
  ELSE
        l_prep_pbl_calling_context := 'WEBADI_NON_PERIODIC';
  END IF;

  -- calling prepare_pbl_input to prepare inputs for the process_budget_lines api from data passed
  -- back from validate_budget_lines
  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Calling prepare_pbl_input';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;
  --log1('6 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

  l_spread_curve_id_tbl_1 := l_spread_curve_id_tbl;
  l_mfc_cost_type_id_tbl_1 := l_mfc_cost_type_id_tbl;
  l_delete_flag_tbl_1 := l_delete_flag_tbl;
  l_etc_method_code_tbl_1 := l_etc_method_code_tbl;
  l_sp_fixed_date_tbl_1 := l_sp_fixed_date_tbl;

  prepare_pbl_input
        (p_context                         => l_prep_pbl_calling_context,
         p_run_id                          => p_run_id,
         p_version_info_rec                => l_version_info_rec,
         p_inf_tbl_rec_tbl                 => l_inf_tbl_rec_tbl,
         p_project_id                      => l_project_id,
         p_budget_version_id               => l_budget_version_id,
         p_etc_start_date                  => l_etc_start_date,
         p_plan_class_code                 => l_version_info_rec.x_plan_class_code,
         p_first_pd_bf_pm_en_dt            => l_first_pd_bf_pm_en_dt,
         p_last_pd_af_pm_st_dt             => l_last_pd_af_pm_st_dt,
         p_budget_lines_tbl                => l_budget_line_in_tbl,
         p_ra_id_tbl                       => l_ra_id_tbl,
         p_prd_mask_st_date_tbl            => l_prd_start_date_tbl,
         p_prd_mask_end_date_tbl           => l_prd_end_date_tbl,
         p_planning_start_date_tbl         => l_bl_plan_start_date_tbl,
         p_planning_end_date_tbl           => l_bl_plan_end_date_tbl,
         p_etc_quantity_tbl                => l_etc_quantity_tbl,
         p_etc_raw_cost_tbl                => l_etc_raw_cost_tbl,
         p_etc_burdened_cost_tbl           => l_etc_burdened_cost_tbl,
         p_etc_revenue_tbl                 => l_etc_revenue_tbl,
         p_raw_cost_rate_tbl               => l_bl_raw_cost_rate_tbl,
         p_burd_cost_rate_tbl              => l_bl_burd_cost_rate_tbl,
         p_bill_rate_tbl                   => l_bl_bill_rate_tbl,
         p_spread_curve_id_tbl             => l_spread_curve_id_tbl_1,
         p_mfc_cost_type_id_tbl            => l_mfc_cost_type_id_tbl_1,
         p_etc_method_code_tbl             => l_etc_method_code_tbl_1,
         p_sp_fixed_date_tbl               => l_sp_fixed_date_tbl_1,
         p_res_class_code_tbl              => l_res_class_code_tbl,
         p_rate_based_flag_tbl             => l_rate_based_flag_tbl,
         p_rbs_elem_id_tbl                 => l_rbs_elem_id_tbl,
         p_delete_flag_tbl                 => l_delete_flag_tbl_1,
         p_request_id                      => p_request_id,
         x_task_id_tbl                     => l_task_id_tbl,
         x_rlm_id_tbl                      => l_rlm_id_tbl,
         x_ra_id_tbl                       => l_prc_ra_id_tbl,
         x_txn_currency_code_tbl           => l_txn_currency_code_tbl,
         x_planning_start_date_tbl         => l_planning_start_date_tbl,
         x_planning_end_date_tbl           => l_planning_end_date_tbl,
         x_total_qty_tbl                   => l_total_qty_tbl,
         x_total_raw_cost_tbl              => l_total_raw_cost_tbl,
         x_total_burdened_cost_tbl         => l_total_burdened_cost_tbl,
         x_total_revenue_tbl               => l_total_revenue_tbl,
         x_raw_cost_rate_tbl               => l_raw_cost_rate_tbl,
         x_burdened_cost_rate_tbl          => l_burdened_cost_rate_tbl,
         x_bill_rate_tbl                   => l_bill_rate_tbl,
         x_line_start_date_tbl             => l_line_start_date_tbl,
         x_line_end_date_tbl               => l_line_end_date_tbl,
         x_proj_cost_rate_type_tbl         => l_proj_cost_rate_type_tbl,
         x_proj_cost_rate_date_type_tbl    => l_proj_cost_rate_date_type_tbl,
         x_proj_cost_rate_tbl              => l_proj_cost_rate_tbl,
         x_proj_cost_rate_date_tbl         => l_proj_cost_rate_date_tbl,
         x_proj_rev_rate_type_tbl          => l_proj_rev_rate_type_tbl,
         x_proj_rev_rate_date_type_tbl     => l_proj_rev_rate_date_type_tbl,
         x_proj_rev_rate_tbl               => l_proj_rev_rate_tbl,
         x_proj_rev_rate_date_tbl          => l_proj_rev_rate_date_tbl,
         x_pfunc_cost_rate_type_tbl        => l_pfunc_cost_rate_type_tbl,
         x_pfunc_cost_rate_date_typ_tbl    => l_pfunc_cost_rate_date_typ_tbl,
         x_pfunc_cost_rate_tbl             => l_pfunc_cost_rate_tbl,
         x_pfunc_cost_rate_date_tbl        => l_pfunc_cost_rate_date_tbl,
         x_pfunc_rev_rate_type_tbl         => l_pfunc_rev_rate_type_tbl,
         x_pfunc_rev_rate_date_type_tbl    => l_pfunc_rev_rate_date_type_tbl,
         x_pfunc_rev_rate_tbl              => l_pfunc_rev_rate_tbl,
         x_pfunc_rev_rate_date_tbl         => l_pfunc_rev_rate_date_tbl,
         x_delete_flag_tbl                 => l_delete_flag_tbl,
         x_spread_curve_id_tbl             => l_spread_curve_id_tbl,
         x_mfc_cost_type_id_tbl            => l_mfc_cost_type_id_tbl,
         x_etc_method_code_tbl             => l_etc_method_code_tbl,
         x_sp_fixed_date_tbl               => l_sp_fixed_date_tbl,
         x_res_class_code_tbl              => l_prc_res_class_code_tbl,
         x_rate_based_flag_tbl             => l_prc_rate_based_flag_tbl,
         x_rbs_elem_id_tbl                 => l_prc_rbs_elem_id_tbl,
         x_change_reason_code_tbl          => l_change_reason_code_tbl,
         x_description_tbl                 => l_description_tbl,
         x_return_status                   => x_return_status,
         x_msg_count                       => l_msg_count,
         x_msg_data                        => l_msg_data);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Call to prepare_pbl_input returned with error';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Call to prepare_pbl_input done';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;
    --log1('7 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
 --log1('----- STAGE 12-------');
  -- calling process_budget_lines to commit the validated data in DB
  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Calling process_budget_lines';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  --Till this point all the DMLs would have been executed on PA_FP_WEBADI_UPLOAD_INF. In case of any error
  --those changes need not be rolled back. process_budget_lines API will update the core B/F tables and hence
  --those updates should be reverted in case of any error. Hence establishing a savepoint now.
  SAVEPOINT SWITCHER;
  l_rollback_flag := 'Y';
      --log1('8 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

  -- Bug 4431269: Populating the global variables to be used in calculate api
  -- for error reporting purpose
  G_FP_WA_CALC_CALLING_CONTEXT := 'WEBADI_CALCULATE';

  process_budget_lines
      ( p_context                         => l_prep_pbl_calling_context,
        p_budget_version_id               => l_budget_version_id,
        p_version_info_rec                => l_version_info_rec,
        p_task_id_tbl                     => l_task_id_tbl,
        p_rlm_id_tbl                      => l_rlm_id_tbl,
        p_ra_id_tbl                       => l_prc_ra_id_tbl,
        p_spread_curve_id_tbl             => l_spread_curve_id_tbl,
        p_mfc_cost_type_id_tbl            => l_mfc_cost_type_id_tbl,
        p_etc_method_code_tbl             => l_etc_method_code_tbl,
        p_sp_fixed_date_tbl               => l_sp_fixed_date_tbl,
        p_res_class_code_tbl              => l_prc_res_class_code_tbl,
        p_rate_based_flag_tbl             => l_prc_rate_based_flag_tbl,
        p_rbs_elem_id_tbl                 => l_prc_rbs_elem_id_tbl,
        p_txn_currency_code_tbl           => l_txn_currency_code_tbl,
        p_planning_start_date_tbl         => l_planning_start_date_tbl,
        p_planning_end_date_tbl           => l_planning_end_date_tbl,
        p_total_qty_tbl                   => l_total_qty_tbl,
        p_total_raw_cost_tbl              => l_total_raw_cost_tbl,
        p_total_burdened_cost_tbl         => l_total_burdened_cost_tbl,
        p_total_revenue_tbl               => l_total_revenue_tbl,
        p_raw_cost_rate_tbl               => l_raw_cost_rate_tbl,
        p_burdened_cost_rate_tbl          => l_burdened_cost_rate_tbl,
        p_bill_rate_tbl                   => l_bill_rate_tbl,
        p_line_start_date_tbl             => l_line_start_date_tbl,
        p_line_end_date_tbl               => l_line_end_date_tbl,
        p_proj_cost_rate_type_tbl         => l_proj_cost_rate_type_tbl,
        p_proj_cost_rate_date_type_tbl    => l_proj_cost_rate_date_type_tbl,
        p_proj_cost_rate_tbl              => l_proj_cost_rate_tbl,
        p_proj_cost_rate_date_tbl         => l_proj_cost_rate_date_tbl,
        p_proj_rev_rate_type_tbl          => l_proj_rev_rate_type_tbl,
        p_proj_rev_rate_date_type_tbl     => l_proj_rev_rate_date_type_tbl,
        p_proj_rev_rate_tbl               => l_proj_rev_rate_tbl,
        p_proj_rev_rate_date_tbl          => l_proj_rev_rate_date_tbl,
        p_pfunc_cost_rate_type_tbl        => l_pfunc_cost_rate_type_tbl,
        p_pfunc_cost_rate_date_typ_tbl    => l_pfunc_cost_rate_date_typ_tbl,
        p_pfunc_cost_rate_tbl             => l_pfunc_cost_rate_tbl,
        p_pfunc_cost_rate_date_tbl        => l_pfunc_cost_rate_date_tbl,
        p_pfunc_rev_rate_type_tbl         => l_pfunc_rev_rate_type_tbl,
        p_pfunc_rev_rate_date_type_tbl    => l_pfunc_rev_rate_date_type_tbl,
        p_pfunc_rev_rate_tbl              => l_pfunc_rev_rate_tbl,
        p_pfunc_rev_rate_date_tbl         => l_pfunc_rev_rate_date_tbl,
        p_change_reason_code_tbl          => l_change_reason_code_tbl,
        p_description_tbl                 => l_description_tbl,
        p_delete_flag_tbl                 => l_delete_flag_tbl,
        x_return_status                   => x_return_status,
        x_msg_count                       => l_msg_count,
        x_msg_data                        => l_msg_data);
    --log1('9 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Call to process_budget_lines returned with error';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
  -- Bug 4431269: Clearing the global variables used in calculate api
  -- for error reporting purpose
  G_FP_WA_CALC_CALLING_CONTEXT := null;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Call to process_budget_lines done';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;
      --log1('10 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
  -- if the submit flag is passed as Y, then calling api to submit the version
  IF p_submit_budget_flag   = 'Y' OR
     p_submit_forecast_flag = 'Y' THEN
           IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Calling pa_fin_plan_pub.Submit_Current_Working';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           END IF;
           pa_fin_plan_pub.Submit_Current_Working
                 (p_project_id              => l_version_info_rec.x_project_id,
                  p_budget_version_id       => l_budget_version_id,
                  p_record_version_number   => l_rec_version_number,
                  x_return_status           => x_return_status,
                  x_msg_count               => l_msg_count,
                  x_msg_data                => l_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Call to pa_fin_plan_pub.Submit_Current_Working returned with error';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
  END IF;
      --log1('11 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
  --log1('----- STAGE 13-------');
  -- If upload is successful then delete all the records
  -- from interface table
  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'deleting from upload temp table';
      pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
  END IF;
    --log1('12 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

  pa_fp_webadi_pkg.DELETE_XFACE
          ( p_run_id          =>  p_run_id
           ,x_return_status   =>  x_return_status
           ,x_msg_count       =>  x_msg_count
           ,x_msg_data        =>  l_msg_data     --x_msg_data  Bug 2764950
          ) ;
    --log1('13 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
  COMMIT; /* to commit the data in DB after successful processing */
    --log1('14 '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
  --log1('----- STAGE 14-------');
  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Leaving pa_fp_webadi_pkg.switcher';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      pa_debug.reset_curr_function;
  END IF;

  --log1('----- Leaving Switcher api ------- '||x_return_status);
    --log1('End '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage := 'Invalid Arg Exception Raised in Switcher';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      pa_debug.g_err_stage := 'Checking for errors';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  -- Bug 4431269: Clearing the global variables used in calculate api
  -- for error reporting purpose
  G_FP_WA_CALC_CALLING_CONTEXT := null;
  IF l_rollback_flag='Y' THEN
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Rolling back to switcher';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
      ROLLBACK TO SWITCHER;
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Roll back to switcher done';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
  END IF;

  -- checking if calculate has populated any errors in the global table
  IF g_fp_webadi_rec_tbl.COUNT > 0 THEN
      -- calling an api to process the errors passed
      read_global_var_to_report_err
           (p_run_id          => p_run_id,
            x_return_status   => x_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data);
  END IF;

  IF l_set_ppc_flag_on_err ='Y' THEN
      update_xl_data_for_new_req
       (p_request_id           => l_request_id,
        p_run_id               => p_run_id,
        p_plan_processing_code => 'XLUE',
        p_budget_version_id    => l_budget_version_id,
        p_null_out_cols        => 'N');

  END IF;

  COMMIT;

  l_msg_count := FND_MSG_PUB.count_msg;

  IF l_msg_count = 1 and x_msg_data IS NULL THEN
      PA_INTERFACE_UTILS_PUB.get_messages
          (p_encoded        => FND_API.G_TRUE
           ,p_msg_index      => 1
           ,p_msg_count      => l_msg_count
           ,p_msg_data       => l_msg_data
           ,p_data           => l_data
           ,p_msg_index_out  => l_msg_index_out);
      x_msg_data := l_data;
      x_msg_count := l_msg_count;
      x_success_msg:=l_data;
  ELSE
      x_msg_count := l_msg_count;
      x_success_msg :='Error In Upload';
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;

  IF l_debug_mode = 'Y' THEN
      pa_debug.reset_curr_function;
  END IF;
  RETURN;

WHEN OTHERS THEN
  -- Bug 4431269: Clearing the global variables used in calculate api
  -- for error reporting purpose
  G_FP_WA_CALC_CALLING_CONTEXT := null;

  IF l_rollback_flag='Y' THEN
      ROLLBACK TO SWITCHER;
  END IF;
  x_success_msg :='Error In Upload';

  -- checking if calculate has populated any errors in the global table
  IF g_fp_webadi_rec_tbl.COUNT > 0 THEN
      -- calling an api to process the errors passed
      read_global_var_to_report_err
           (p_run_id          => p_run_id,
            x_return_status   => x_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data);
  END IF;

  IF l_set_ppc_flag_on_err ='Y' THEN
      update_xl_data_for_new_req
       (p_request_id           => l_request_id,
        p_run_id               => p_run_id,
        p_plan_processing_code => 'XLUE',
        p_budget_version_id    => l_budget_version_id,
        p_null_out_cols        => 'N');

  END IF;
  COMMIT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  x_msg_count     := 1;
  x_msg_data      := SQLERRM;

  FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'pa_fp_webadi_pkg'
                          ,p_procedure_name  => 'switcher');
  IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
  END IF;

  IF l_debug_mode = 'Y' THEN
      pa_debug.reset_curr_function;
  END IF;
  RAISE;

END switcher;

--This API will be called when thru the concurrent request that will be used to upload MS excel data to
--Oracle Applications.
PROCEDURE process_MSExcel_data
(errbuf                      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 retcode                     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_submit_ver_flag           IN     VARCHAR2,
 p_run_id                    IN     pa_fp_webadi_upload_inf.run_id%TYPE)
 IS
--Start of variables used for debugging
l_return_status                            VARCHAR2(1);
l_msg_count                                NUMBER := 0;
l_msg_data                                 VARCHAR2(2000);
l_data                                     VARCHAR2(2000);
l_msg_index_out                            NUMBER;
l_debug_mode                               VARCHAR2(30);
l_module_name                              VARCHAR2(100):='PAFPWAPB.process_MSExcel_data';

--End of variables used for debugging
 l_budget_version_id         pa_budget_versions.budget_version_id%TYPE;
 l_plan_class_code           pa_fin_plan_types_b.plan_class_code%TYPE;
 l_request_id                pa_budget_versions.request_id%TYPE;
 l_submit_bdgt_flag          VARCHAR2(1);
 l_submit_fcst_flag          VARCHAR2(1);
 l_version_type              pa_budget_versions.version_type%TYPE;
 l_success_msg               VARCHAR2(1000);

-- the following cursor would query the interface table for any validation failure
 -- error messages present in the interface table corresponding to a set of run_id
 -- for the upload session.

 CURSOR l_get_error_msg_to_report_csr (c_run_id        pa_fp_webadi_upload_inf.run_id%TYPE,
                                       c_plan_class    pa_fin_plan_types_b.plan_class_code%TYPE,
                                       c_version_type  pa_budget_versions.version_type%TYPE,
                                       c_request_id    pa_budget_versions.request_id%TYPE)
 IS
 -- 4497321.Perf Fix:Modified SELECT query inorder to improve the performance.
 SELECT  inf.task_number || '/' || inf.task_name task_info,
         inf.resource_alias resource_info,
         inf.txn_currency_code currency,
         plu1.meaning amount_type,
         plu2.meaning error
 FROM    pa_fp_webadi_upload_inf inf,
         pa_lookups plu1,
         pa_lookups plu2
 WHERE   inf.run_id = c_run_id
 AND     Nvl(inf.val_error_flag, 'N') = 'Y'
 AND     inf.val_error_code IS NOT NULL
 AND     plu1.lookup_type = DECODE (c_plan_class, 'BUDGET',
                                                   DECODE(c_version_type,
                                                         'COST', 'PA_FP_XL_COST_BDGT_AMT_TYPES',
                                                         'REVENUE', 'PA_FP_XL_REV_BDGT_AMT_TYPES',
                                                         'PA_FP_XL_ALL_BDGT_AMT_TYPES'),
                                                 'FORECAST', DECODE(c_version_type,
                                                 'COST', 'PA_FP_XL_COST_FCST_AMT_TYPES',
                                                 'REVENUE', 'PA_FP_XL_REV_FCST_AMT_TYPES',
                                                 'PA_FP_XL_ALL_FCST_AMT_TYPES'))
 AND     (inf.amount_type_code IS NULL OR plu1.lookup_code = Nvl(inf.amount_type_code, '-99'))
 AND     plu2.lookup_type = 'PA_FP_WEBADI_ERR_1'
 AND     inf.val_error_code = plu2.lookup_code
 AND     Nvl(c_request_id, -99) = Nvl(inf.request_id, -99);

 l_error_info_rec l_get_error_msg_to_report_csr%ROWTYPE;

 BEGIN
    -- SAVEPOINT process_MSExcel_data;
    retcode:='0';
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    --log1('----- STAGE CR1-------');
    -- Set curr function
    IF l_debug_mode='Y' THEN
        pa_debug.set_curr_function(
                    p_function   =>'PAFPWAPB.process_MSExcel_data'
                   ,p_debug_mode => l_debug_mode );
    END IF;

    l_request_id:=fnd_global.conc_request_id;
    --log1('----- STAGE CR2-------');
    --log1('----- p_run_id------' || p_run_id);
    --log1('----- p_submit_ver_flag------' || p_submit_ver_flag);
    --Get the budget version id from the interface table to find out whether the budget version belongs to a
    --BUDGET plan type or FORECAST plan type

    -- 4497323.Perf Fix:The SELECT query is splitted into two queries in order to improve performance.
    SELECT budget_version_id
    INTO   l_budget_version_id
    FROM   pa_fp_webadi_upload_inf inf
    WHERE  inf.run_id = p_run_id
    AND    Nvl(l_request_id,-99) = Nvl(request_id,-99)
    AND    rownum=1;

    SELECT fin.plan_class_code,
           pbv.version_type
    INTO   l_plan_class_code,
           l_version_type
    FROM   pa_budget_versions pbv,
           pa_fin_plan_types_b fin
    WHERE  pbv.budget_version_id = l_budget_version_id
    AND    fin.fin_plan_type_id = pbv.fin_plan_type_id;

        --log1('----- STAGE CR3-------');
    IF l_debug_mode='Y' THEN
        pa_debug.g_err_stage:='l_request_id '||l_request_id;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='Callng update_xl_data_for_new_req';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

    END IF;
    --log1('----- STAGE CR4-------');
    update_xl_data_for_new_req
    (p_request_id           => l_request_id,
     p_run_id               => p_run_id,
     p_plan_processing_code => 'XLUP',
     p_budget_version_id    => l_budget_version_id,
     p_null_out_cols        => 'Y');
    --log1('----- STAGE CR5-------');
    COMMIT;--This is done so that the users can find that the concurrent request is in progress from the other
           --interfaces.
    --log1('----- STAGE CR6-------');
    l_submit_bdgt_flag:='N';
    l_submit_fcst_flag:='N';
    IF l_plan_class_code='BUDGET' THEN

        l_submit_bdgt_flag:=p_submit_ver_flag;
    ELSE
        l_submit_fcst_flag:=p_submit_ver_flag;
    END IF;
    --log1('----- STAGE CR7-------');
    pa_fp_webadi_pkg.switcher
    (p_calling_mode         => 'ONLINE',
     p_run_id               => p_run_id,
     p_submit_budget_flag   => l_submit_bdgt_flag,
     p_submit_forecast_flag => l_submit_fcst_flag,
     p_request_id           => l_request_id,
     x_success_msg          => l_success_msg,
     x_return_status        => l_return_status,
     x_msg_count            => l_msg_count,
     x_msg_data             => l_msg_data);
    --log1('----- STAGE CR8-------');
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        --log1('----- STAGE CR9-------');
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='pa_fp_webadi_pkg.switcher returned error';
            pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- upon successful completion of the concurrent processing,
    -- stamp success code in pa_budget_versions and retain the request_id
    UPDATE  pa_budget_versions
    SET     plan_processing_code = 'XLUS',
            record_version_number = (record_version_number + 1)
    WHERE   budget_version_id = l_budget_version_id;

    COMMIT; -- is required to query the interface table from conc prog.
    --log1('----- STAGE 10-------');
    IF l_debug_mode = 'Y' THEN
        pa_debug.reset_curr_function;
    END IF;

EXCEPTION
WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
    -- ROLLBACK TO process_MSExcel_data;
    -- bug 4477397: doing a general rollback instead to savepoint
    ROLLBACK;
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
             (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);

       errbuf  := l_data;

    END IF;
    retcode := '2';  --Changed this to '2' for bug #4504482
    --log1('----- STAGE CR10-------');
    -- preparing an output error log to display all the validation failures, if any,
    -- corresponding to a particular record in the interface table
    IF l_debug_mode = 'Y' THEN
           --Before calling pa_debug.write_file we shd call pa_debug.set_process if we want write_file to write to the log file.
           pa_debug.set_process( x_process    => 'PLSQL'
                                ,x_write_file => 'LOG'
                                ,x_debug_mode => l_debug_mode
                               );
           pa_debug.g_err_stage := '- Task Number/Task Name, Resource, Currency, Amount Type, Error - ';
           pa_debug.write_file('LOG', pa_debug.g_err_stage);
           pa_debug.g_err_stage := '------------------------------------------------------------------';
           pa_debug.write_file('LOG', pa_debug.g_err_stage);

           OPEN l_get_error_msg_to_report_csr(p_run_id, l_plan_class_code, l_version_type, l_request_id);
           LOOP
                 FETCH l_get_error_msg_to_report_csr
                 INTO  l_error_info_rec;

                 --EXIT WHEN l_error_info_rec.task_info IS NULL;   --Bug 8839857
                 EXIT when l_get_error_msg_to_report_csr%NOTFOUND; --Bug 8839857

                 pa_debug.g_err_stage := l_error_info_rec.task_info || ', ' || l_error_info_rec.resource_info || ', ' ||
                                         l_error_info_rec.currency || ', ' || l_error_info_rec.amount_type || ', ' ||
                                         l_error_info_rec.error;
                 pa_debug.write_file('LOG', pa_debug.g_err_stage);
           END LOOP;
           CLOSE l_get_error_msg_to_report_csr;

           --Bug 4504482: Added code to read the msg stack and populate the concurrent
           --program log in addition to the interface table.
           pa_debug.g_err_stage := '-----------------Additional Errors--------------------------------';
           pa_debug.write_file('LOG', pa_debug.g_err_stage);
           FOR msg_count IN 1 ..  l_msg_count
           LOOP
               PA_UTILS.Get_Encoded_Msg(p_index    => msg_count,
                                        p_msg_out  => l_data);
           pa_debug.g_err_stage := l_data;
           pa_debug.write_file('LOG', pa_debug.g_err_stage);
           END LOOP;

    END IF;

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
       pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
        -- reset curr function
        pa_debug.reset_curr_function();
    END IF;
    --log1('----- STAGE CR11-------');
    update_xl_data_for_new_req
    (p_request_id           => l_request_id,
     p_run_id               => p_run_id,
     p_plan_processing_code => 'XLUE',
     p_budget_version_id    => l_budget_version_id,
     p_null_out_cols        => 'N');
    --log1('----- STAGE CR12-------');
    COMMIT;
    --log1('----- STAGE CR13-------');
    RETURN;
WHEN OTHERS THEN
    -- ROLLBACK TO process_MSExcel_data;
    -- bug 4477397: doing a general rollback instead to savepoint
    ROLLBACK;
    errbuf      := SQLERRM;

    FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'pa_fp_webadi_pkg'
                           ,p_procedure_name  => 'process_MSExcel_data');

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
       pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
        -- reset curr function
        pa_debug.Reset_Curr_Function();
    END IF;
    retcode := '2';

    update_xl_data_for_new_req
    (p_request_id           => l_request_id,
     p_run_id               => p_run_id,
     p_plan_processing_code => 'XLUE',
     p_budget_version_id    => l_budget_version_id,
     p_null_out_cols        => 'N');

    COMMIT;
    RAISE;
END process_MSExcel_data;


--Bug 4584865
/*This api is a private api which is called to calculate the Group Period information
  of the budget version based on the period mask of the budget version.The calculated
  Group Periods are stored in the OUT parameter x_periods_tbl.*/

PROCEDURE GET_PERIOD_INFORMATION(p_period_mask_id          IN pa_proj_fp_options.cost_period_mask_id%TYPE,
                                 p_time_phased_code        IN pa_proj_fp_options.cost_time_phased_code%TYPE,
                                 p_org_id                  IN pa_projects_all.org_id%TYPE,
                                 p_current_planning_period IN pa_proj_fp_options.cost_current_planning_period%TYPE,
                                 x_periods_tbl             OUT NOCOPY periods_tbl,
                                 x_return_status           OUT NOCOPY VARCHAR2,
                                 x_msg_count               OUT NOCOPY NUMBER,
                                 x_msg_data                OUT NOCOPY NUMBER)
IS
      --This Cursor is used to get Period Mask informations of the Period Mask associated with the budget version.
      CURSOR period_mask_cur(c_period_mask_id   pa_period_mask_details.period_mask_id%TYPE)
      IS
      SELECT pmd.period_mask_id,
             pmd.num_of_periods,
             pmd.anchor_period_flag,
             pmd.from_anchor_start,
             pmd.from_anchor_end,
             pmd.from_anchor_position
      FROM   pa_period_mask_details pmd
      WHERE  pmd.period_mask_id = c_period_mask_id
      AND    pmd.from_anchor_position not in(-99999,99999)
      ORDER BY pmd.from_anchor_position;
--PL/SQL table created based on Cursor period_mask_cur.
TYPE period_mask_tbl IS TABLE OF period_mask_cur%ROWTYPE;

      CURSOR pa_impl_cur(c_org_id   pa_implementations_all.org_id%TYPE)
      IS
      SELECT org_id,
             period_set_name,
             pa_period_type,
             set_of_books_id
      FROM   pa_implementations_all
      WHERE  org_id = c_org_id;

      --This Cursor is used to get period information based on the Time Phasing of the budget version.
      CURSOR period_grouping_cur(c_period_set_name   gl_periods.period_set_name%TYPE,
                                 c_set_of_books_id   gl_sets_of_books.set_of_books_id%TYPE,
                                 c_org_id            pa_implementations_all.org_id%TYPE,
                                 c_pa_period_type    pa_implementations_all.pa_period_type%TYPE,
                                 c_time_phased_code  pa_proj_fp_options.cost_time_phased_code%TYPE)
      IS
      SELECT ROW_NUMBER() OVER( PARTITION BY gl.period_set_name,gl.period_type ORDER BY gl.start_date ) row_num,
             gl.start_date start_date,
             gl.end_Date end_date,
             gl.period_name period_name,
             gl.period_type period_type,
             gl.period_set_name period_set_name,
             gsb.accounted_period_type accounted_period_type,
             c_org_id
      FROM   gl_periods gl,
             gl_sets_of_books gsb
      WHERE  gl.period_set_name=decode(c_time_phased_code,'P',c_period_set_name,'G',gsb.period_set_name)
      AND    gsb.set_of_books_id=c_set_of_books_id
      AND    gl.ADJUSTMENT_PERIOD_FLAG ='N'
      AND    gl.period_type = decode(c_time_phased_code,'P',c_pa_period_type,
                                                  'G',gsb.accounted_period_type);
--PL/SQL table created based on Cursor period_grouping_cur.
TYPE period_grouping_tbl IS TABLE OF period_grouping_cur%ROWTYPE
INDEX BY PLS_INTEGER;

    l_debug_mode       VARCHAR2(1);
    l_return_status    VARCHAR2(1);
    l_data             VARCHAR2(2000);
    l_msg_count        NUMBER := 0;
    l_msg_data         VARCHAR2(2000);
    l_msg_index_out    NUMBER;
    l_module_name      VARCHAR2(100) := 'pa_fp_webadi_pkg.get_period_information';
    l_period_mask_tbl   period_mask_tbl;
    l_pa_impl_rec   pa_impl_cur%ROWTYPE;
    l_period_grouping_tbl   period_grouping_tbl;
    l_periods_rec   periods_rec;
    glcp_rownum   NUMBER;
    glsd_rownum   NUMBER;
    gled_rownum   NUMBER;
    period_name   VARCHAR2(50); --gl_periods.period_name%TYPE;
    start_date   gl_periods.start_date%TYPE;
    end_date   gl_periods.end_date%TYPE;
    x   NUMBER := 1;
BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'Y');

    IF l_debug_mode = 'Y' THEN
        pa_debug.set_curr_function(p_function   => 'GET_PERIOD_INFORMATION',
                                   p_debug_mode => l_debug_mode);
        pa_debug.g_err_stage := ':In pa_fp_webadi_pkg.GET_PERIOD_INFORMATION';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    --Validation is done for the input parameters.
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage := 'Validating Input parameters';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    IF p_period_mask_id IS NULL THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'p_period_mask_id is passed as null';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_time_phased_code IS NULL THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'p_time_phased_code is passed as null';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_org_id IS NULL THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'p_org_id is passed as null';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_current_planning_period IS NULL THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'p_current_planning_period is passed as null';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    --Initializing the out parameter which is pl/sql table.
    x_periods_tbl := periods_tbl();

    --Getting the Period Mask details of the period mask associated with the budget version.
    OPEN period_mask_cur(p_period_mask_id);
    FETCH period_mask_cur BULK COLLECT INTO l_period_mask_tbl;
    CLOSE period_mask_cur;
    IF l_period_mask_tbl.count = 0 THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Period Mask Details not found for the budget version';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    --Information are got from pa_implentations_all table for the project org_id and stored in a pl/sql record.
    OPEN pa_impl_cur(p_org_id);
    FETCH pa_impl_cur INTO l_pa_impl_rec;
    CLOSE pa_impl_cur;

    --Period Informations are got from gl_periods table and stored in a pl/sql table.
    FOR rec in period_grouping_cur(l_pa_impl_rec.period_set_name,
                                   l_pa_impl_rec.set_of_books_id,
                                   l_pa_impl_rec.org_id,
                                   l_pa_impl_rec.pa_period_type,
                                   p_time_phased_code)
    LOOP
        l_period_grouping_tbl(rec.row_num) := rec;
    END LOOP;

    --Getting the row number of the Current Planning period from the pl/sql table l_period_grouping_tbl.
    IF l_period_grouping_tbl.count >0 THEN
       FOR n IN l_period_grouping_tbl.first..l_period_grouping_tbl.last
       LOOP
          IF l_period_grouping_tbl(n).period_name = p_current_planning_period THEN
             glcp_rownum := l_period_grouping_tbl(n).row_num;
             EXIT;
          END IF;
       END LOOP;
    ELSE
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Period information not found for the budget version';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    --The Group Period informations are got and stored in a pl/sql table based on the Period Mask.
    FOR i IN l_period_mask_tbl.first..l_period_mask_tbl.last
    LOOP
       glsd_rownum := l_period_mask_tbl(i).from_anchor_start+glcp_rownum;
       gled_rownum := l_period_mask_tbl(i).from_anchor_end+glcp_rownum;
       IF glsd_rownum >= l_period_grouping_tbl.first AND gled_rownum <= l_period_grouping_tbl.last THEN
         IF glsd_rownum = gled_rownum THEN
             period_name := l_period_grouping_tbl(glsd_rownum).period_name;
         ELSE
             period_name := l_period_grouping_tbl(glsd_rownum).period_name||' To '||l_period_grouping_tbl(gled_rownum).period_name;
         END IF;
          start_date := l_period_grouping_tbl(glsd_rownum).start_date;
          end_date := l_period_grouping_tbl(gled_rownum).end_date;
          l_periods_rec.sequence_number := x;
          l_periods_rec.period_name := period_name;
          l_periods_rec.start_date := start_date;
          l_periods_rec.end_date := end_date;
          x_periods_tbl.extend();
          x_periods_tbl(x) := l_periods_rec;
          x := x+1;
      ELSE
          NULL;
      END IF;
    END LOOP;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count = 1 AND x_msg_data IS NULL THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                   ,p_msg_index      => 1
                   ,p_msg_count      => l_msg_count
                   ,p_msg_data       => l_msg_data
                   ,p_data           => l_data
                   ,p_msg_index_out  => l_msg_index_out);
                   x_msg_data := l_data;
                   x_msg_count := l_msg_count;
         ELSE
            x_msg_count := l_msg_count;
         END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
         IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
         END IF;
    RETURN;

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SQLERRM;
         FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_webadi_pkg'
                                 ,p_procedure_name  => 'get_period_information');
         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             pa_debug.reset_curr_function;
         END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_PERIOD_INFORMATION;

--Bug 4584865.
--This API is called to insert records into pa_fp_webadi_xface_tmp
--during downloading budget line details into excel spreadsheet.

PROCEDURE insert_periodic_tmp_table
          (p_budget_version_id IN pa_budget_versions.budget_version_id%TYPE
          ,x_return_status     OUT NOCOPY VARCHAR2
          ,x_msg_count         OUT NOCOPY NUMBER
          ,x_msg_data          OUT NOCOPY VARCHAR2 )
IS
      /* Bug 5144013: Changes are made in the cursor to make use of the new entity pa_resource_asgn_curr
         which is introduced in MRUP3 of 11i. The changes are done as part of merging the MRUP3 changes
         done in 11i into R12.
      */
      --This Cursor is used to get Resource Assignment information associated with the budget version.
      CURSOR res_ass_cur(c_budget_version_id   pa_budget_versions.budget_version_id%TYPE,
                         c_project_id   pa_projects_all.project_id%TYPE,
                         c_parent_structure_version_id   pa_proj_element_versions.parent_structure_version_id%TYPE,
                         c_proj_fp_options_id   pa_proj_fp_options.proj_fp_options_id%TYPE)
      IS
      SELECT pra.resource_assignment_id resource_assignment_id,
             nvl(pe.name,ppa.long_name) task_name,
             nvl(pe.element_number,ppa.segment1) task_number,
             nvl(pev.display_sequence,-1) task_display_sequence,
             prlm.alias resource_name,
             pra.resource_list_member_id,
             uom.meaning unit_of_measure,
             pra.spread_curve_id spread_curve_id,
             psc.name spread_curve,
             pra.planning_start_date,
             pra.planning_end_date,
             pra.mfc_cost_type_id mfc_cost_type_id,
             cct.cost_type mfc_cost_type,
             pra.etc_method_code etc_method_code,
             etc.meaning etc_method,
             pev.proj_element_id project_element_id,
             decode(pra.transaction_source_code,NULL,NULL,
                    (SELECT meaning
                     FROM PA_LOOKUPS
                     WHERE LOOKUP_TYPE='PA_FP_FCST_GEN_SRC_ALL'
                     AND LOOKUP_CODE= nvl(pra.transaction_source_code, (
                                                                        SELECT lookup_code
                                                                        FROM pa_lookups
                                                                        WHERE lookup_type='PA_FP_FCST_GEN_SRC_ALL'
                                                                        AND rownum=1)))) etc_source,
             pftc.txn_currency_code txn_currency_code,
             pftc.project_cost_exchange_rate project_cost_exchange_rate,
             pftc.project_rev_exchange_rate project_rev_exchange_rate,
             pftc.projfunc_cost_exchange_rate projfunc_cost_exchange_rate,
             pftc.projfunc_rev_exchange_rate projfunc_rev_exchange_rate
      FROM   pa_resource_assignments pra,
             pa_resource_asgn_curr prac,
             pa_fp_txn_currencies pftc,
             pa_proj_elements pe,
             pa_proj_element_versions pev,
             pa_resource_list_members prlm,
             pa_lookups uom,
             pa_spread_curves_tl psc,
             cst_cost_types cct,
             pa_lookups etc,
             pa_projects_all ppa
      WHERE pra.budget_version_id = c_budget_version_id
      AND prac.budget_version_id = pra.budget_version_id
      AND prac.resource_assignment_id = pra.resource_assignment_id
      AND pftc.fin_plan_version_id = prac.budget_version_id
      AND pftc.txn_currency_code = prac.txn_currency_code
      AND pftc.proj_fp_options_id = c_proj_fp_options_id
      AND pra.resource_list_member_id = prlm.resource_list_member_id
      AND decode(pra.task_id,0,pev.proj_element_id,pra.task_id)=pev.proj_element_id
      AND decode(pra.task_id,0,pev.parent_structure_version_id,pev.element_version_id)=pev.element_version_id
      AND pev.proj_element_id = pe.proj_element_id(+)
      AND pe.object_type(+)='PA_TASKS'
      AND pev.parent_structure_version_id = c_parent_structure_version_id
      AND nvl(pra.spread_curve_id,1) = psc.spread_curve_id
      AND etc.lookup_type = 'PA_FP_ETC_METHOD'
      AND etc.lookup_code(+) = pra.etc_method_code
      AND cct.cost_type_id(+) = pra.mfc_cost_type_id
      AND uom.lookup_type = 'UNIT'
      AND uom.LOOKUP_CODE = nvl(prlm.UNIT_OF_MEASURE,'HOURS')
      AND psc.language = userenv('LANG')
      AND ppa.project_id = c_project_id
      ORDER BY task_display_sequence;
--PL/SQL table created based on Cursor res_ass_cur.
TYPE res_ass_tbl IS TABLE OF res_ass_cur%ROWTYPE; --Bug 5641300: Converted the index by pl/sql table to ordinary pl/sql table.
-- INDEX BY PLS_INTEGER;

--This Record is used to store the Plan Settings level information of the budget version.
Type proj_fp_options_rec  is record(fin_plan_preference_code   pa_proj_fp_options.fin_plan_preference_code%TYPE,
                                    projfunc_cost_rate_type   pa_proj_fp_options.projfunc_cost_rate_type%TYPE,
                                    projfunc_cost_rate_date_type   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE,
                                    projfunc_cost_rate_date   pa_proj_fp_options.projfunc_cost_rate_date%TYPE,
                                    project_cost_rate_type   pa_proj_fp_options.project_cost_rate_type%TYPE,
                                    project_cost_rate_date_type   pa_proj_fp_options.project_cost_rate_date_type%TYPE,
                                    project_cost_rate_date   pa_proj_fp_options.project_cost_rate_date%TYPE,
                                    projfunc_rev_rate_type   pa_proj_fp_options.projfunc_rev_rate_type%TYPE,
                                    projfunc_rev_rate_date_type   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE,
                                    projfunc_rev_rate_date   pa_proj_fp_options.projfunc_rev_rate_date%TYPE,
                                    project_rev_rate_type   pa_proj_fp_options.project_rev_rate_type%TYPE,
                                    project_rev_rate_date_type   pa_proj_fp_options.project_rev_rate_date_type%TYPE,
                                    project_rev_rate_date   pa_proj_fp_options.project_rev_rate_date%TYPE);
l_proj_fp_options_rec   proj_fp_options_rec;

       --This Cursor is used to get the Amount Type and Conversion Attribute information of the budget version.
       CURSOR amt_type_cur(c_project_id   pa_fp_proj_xl_amt_types.project_id%TYPE,
                           c_fin_plan_type_id   pa_fp_proj_xl_amt_types.fin_plan_type_id%TYPE,
                           c_option_type   pa_fp_proj_xl_amt_types.option_type%TYPE,
                           c_plan_class_code   pa_fin_plan_types_b.plan_class_code%TYPE)
       IS
       SELECT  amt.amount_type_code,
               amt_lu.meaning amount_type_name,
               decode(decode(amt.amount_type_code,'TOTAL_REV',l_proj_fp_options_rec.projfunc_rev_rate_type,l_proj_fp_options_rec.projfunc_cost_rate_type),null,null,
               (SELECT pctv1.USER_CONVERSION_TYPE
                FROM   GL_DAILY_CONVERSION_TYPES pctv1
                WHERE  pctv1.CONVERSION_TYPE= nvl(decode(amt.amount_type_code,'TOTAL_REV',l_proj_fp_options_rec.projfunc_rev_rate_type,l_proj_fp_options_rec.projfunc_cost_rate_type),'Corporate'))) projfunc_rate_type,

               decode(decode(amt.amount_type_code,'TOTAL_REV',decode(l_proj_fp_options_rec.projfunc_rev_rate_type,'User',null,l_proj_fp_options_rec.projfunc_rev_rate_date_type),
               decode(l_proj_fp_options_rec.projfunc_cost_rate_type,'User',null,l_proj_fp_options_rec.projfunc_cost_rate_date_type)),null,null,
               (SELECT plk_d1.meaning
                FROM   pa_lookups plk_d1
                WHERE  plk_d1.lookup_type='PA_FP_RATE_DATE_TYPE'
                AND    plk_d1.lookup_code=NVL(decode(amt.amount_type_code,'TOTAL_REV',
               decode(l_proj_fp_options_rec.projfunc_rev_rate_type,'User',null,l_proj_fp_options_rec.projfunc_rev_rate_date_type),
               decode(l_proj_fp_options_rec.projfunc_cost_rate_type,'User',null,l_proj_fp_options_rec.projfunc_cost_rate_date_type)),'FIXED_DATE'))) projfunc_rate_date_type,

               decode(amt.amount_type_code,'TOTAL_REV',decode(l_proj_fp_options_rec.projfunc_rev_rate_date_type,'FIXED_DATE',l_proj_fp_options_rec.projfunc_rev_rate_date,TO_DATE(null)),
               decode(l_proj_fp_options_rec.projfunc_cost_rate_date_type,'FIXED_DATE',l_proj_fp_options_rec.projfunc_cost_rate_date,TO_DATE(null))) projfunc_rate_date,

               decode(decode(amt.amount_type_code,'TOTAL_REV',l_proj_fp_options_rec.project_rev_rate_type,l_proj_fp_options_rec.project_cost_rate_type),null,null,
               (SELECT pctv2.USER_CONVERSION_TYPE
                FROM   GL_DAILY_CONVERSION_TYPES pctv2
                WHERE  pctv2.CONVERSION_TYPE= nvl(decode(amt.amount_type_code,'TOTAL_REV',l_proj_fp_options_rec.project_rev_rate_type,l_proj_fp_options_rec.project_cost_rate_type),'Corporate'))) project_rate_type,

               decode(decode(amt.amount_type_code,'TOTAL_REV',decode(l_proj_fp_options_rec.project_rev_rate_type,'User',null,l_proj_fp_options_rec.PROJECT_REV_RATE_DATE_TYPE),
               decode(l_proj_fp_options_rec.project_cost_rate_type,'User',null,l_proj_fp_options_rec.project_cost_rate_date_type)),null,null,
               (SELECT plk_d2.meaning
                FROM   pa_lookups plk_d2
                WHERE  plk_d2.lookup_type='PA_FP_RATE_DATE_TYPE'
                AND    plk_d2.lookup_code=NVL(decode(amt.amount_type_code,'TOTAL_REV',
               decode(l_proj_fp_options_rec.project_rev_rate_type,'User',null,l_proj_fp_options_rec.project_rev_rate_date_type),
               decode(l_proj_fp_options_rec.project_cost_rate_type,'User',null,l_proj_fp_options_rec.project_cost_rate_date_type)),'FIXED_DATE'))) project_rate_date_type,

               decode(amt.amount_type_code,'TOTAL_REV',decode(l_proj_fp_options_rec.project_rev_rate_date_type,'FIXED_DATE',l_proj_fp_options_rec.project_rev_rate_date,TO_DATE(null)),
               decode(l_proj_fp_options_rec.project_cost_rate_date_type,'FIXED_DATE',l_proj_fp_options_rec.project_cost_rate_date,TO_DATE(null))) project_rate_date
      FROM     pa_fp_proj_xl_amt_types amt,
               pa_lookups amt_lu
      WHERE    amt.project_id = c_project_id
      AND      amt.fin_plan_type_id = c_fin_plan_type_id
      AND      amt.option_type = c_option_type
      AND      amt_lu.lookup_type = decode(c_plan_class_code,'BUDGET', decode(c_option_type,'COST','PA_FP_XL_COST_BDGT_AMT_TYPES','REVENUE','PA_FP_XL_REV_BDGT_AMT_TYPES','ALL','PA_FP_XL_ALL_BDGT_AMT_TYPES'),
                                                                            'FORECAST',decode(c_option_type,'COST','PA_FP_XL_COST_FCST_AMT_TYPES','REVENUE','PA_FP_XL_REV_FCST_AMT_TYPES','ALL','PA_FP_XL_ALL_FCST_AMT_TYPES'))
      AND      amt_lu.lookup_code = amt.amount_type_code
      ORDER BY amount_type_name;
--PL/SQL table created based on amt_type_cur.
TYPE amt_type_tbl IS TABLE OF amt_type_cur%ROWTYPE;

--Commented out the below for bug 5330532
/*
--This Record is used to store the Transaction Currencies Associated with the budget version.
TYPE txn_curr_rec IS RECORD(txn_currency_code            pa_fp_txn_currencies.txn_currency_code%TYPE,
                            project_cost_exchange_rate   pa_fp_txn_currencies.project_cost_exchange_rate%TYPE,
                            project_rev_exchange_rate    pa_fp_txn_currencies.project_rev_exchange_rate%TYPE,
                            projfunc_cost_exchange_rate  pa_fp_txn_currencies.projfunc_cost_exchange_rate%TYPE,
                            projfunc_rev_exchange_rate   pa_fp_txn_currencies.projfunc_rev_exchange_rate%TYPE);
--PL/SQL table created based on txn_curr_rec.
TYPE txn_curr_tbl IS TABLE OF txn_curr_rec;
*/

/* Bug 5144013: Commented out the below cursors txn_curr_cur and txn_curr_rate_cur
   as the transaction currencies and the exchange rates of those currencies can be got
   from the cursor res_ass_cur. This is done as part of merging the MRUP3 changes done
   in 11i into R12.
*/
/* Start of code changes for bug 5330532*/
--Cursor created for fetching transaction currencies.
/* --Bug 5144013.
CURSOR txn_curr_cur(c_budget_version_id pa_budget_lines.budget_version_id%TYPE,
                    c_ra_id             pa_budget_lines.resource_assignment_id%TYPE)
IS
SELECT DISTINCT(txn_currency_code)
FROM   pa_budget_lines pbl
WHERE  pbl.budget_version_id = c_budget_version_id
AND    pbl.resource_assignment_id = c_ra_id;
--PL/SQL table created based on txn_curr_cur.
TYPE txn_curr_tbl IS TABLE OF txn_curr_cur%ROWTYPE;

--Cursor created for fetching transaction currency rates.
CURSOR txn_curr_rate_cur(c_budget_version_id   pa_fp_txn_currencies.fin_plan_version_id%TYPE,
                         c_proj_fp_options_id  pa_fp_txn_currencies.proj_fp_options_id%TYPE)
IS
SELECT  pftc.txn_currency_code,
        pftc.project_cost_exchange_rate,
        pftc.project_rev_exchange_rate,
        pftc.projfunc_cost_exchange_rate,
        pftc.projfunc_rev_exchange_rate
FROM pa_fp_txn_currencies pftc
WHERE pftc.fin_plan_version_id = c_budget_version_id
AND   pftc.proj_fp_options_id = c_proj_fp_options_id;
--PL/SQL table created based on txn_curr_rate_cur.
TYPE txn_curr_rate_tbl IS TABLE OF txn_curr_rate_cur%ROWTYPE INDEX BY VARCHAR2(15);
*/ --Bug 5144013.
/* End of code changes for bug 5330532*/

l_global_tmp_rec   pa_fp_webadi_xface_tmp%ROWTYPE; --Bug 5284640.
NO_RA_EXC   EXCEPTION; --Bug 5360205.

    l_debug_mode             VARCHAR2(1);
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER := 0;
    l_data                   VARCHAR2(2000);
    l_msg_data               VARCHAR2(2000);
    l_msg_index_out          NUMBER;
    l_module_name            VARCHAR2(100) := 'pa_fp_webadi_pkg.insert_periodic_tmp_table';
    l_project_id             pa_budget_versions.project_id%TYPE;
    l_budget_version_id      pa_budget_versions.budget_version_id%TYPE;
    l_version_info_rec       PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_project_structure_version_id   pa_budget_versions.project_structure_version_id%TYPE;
    l_struct_status_flag   VARCHAR2(1);
    l_ci_id   pa_budget_versions.ci_id%TYPE;
    l_AR_flag   pa_budget_versions.approved_rev_plan_type_flag%TYPE;
    l_agr_curr_code   pa_agreements_all.agreement_currency_code%TYPE;
    l_agr_conv_reqd_flag   VARCHAR2(1);
    l_fin_plan_type_id   pa_proj_fp_options.fin_plan_type_id%TYPE;
    l_proj_fp_options_id   pa_proj_fp_options.proj_fp_options_id%TYPE;
    l_version_type   pa_budget_versions.version_type%TYPE;
    l_period_mask_id   pa_proj_fp_options.cost_period_mask_id%TYPE;
    l_time_phased_code   pa_proj_fp_options.cost_time_phased_code%TYPE;
    l_org_id   pa_projects_all.org_id%TYPE;
    l_current_planning_period   pa_proj_fp_options.cost_current_planning_period%TYPE;
    l_fin_plan_preference_code   pa_proj_fp_options.fin_plan_preference_code%TYPE;
    l_plan_class_code   pa_fin_plan_types_b.plan_class_code%TYPE;
    l_project_name   pa_projects_all.name%TYPE;
    l_project_number   pa_projects_all.segment1%TYPE;
    l_txn_currency_code   pa_fp_txn_currencies.txn_currency_code%TYPE;
    l_projfunc_currency_code   pa_projects_all.projfunc_currency_code%TYPE;
    l_project_currency_code   pa_projects_all.project_currency_code%TYPE;
    l_multi_curr_flag   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
    l_start_date   DATE;
    l_end_date   DATE;
    l_preceding_date   DATE;
    l_succeeding_date   DATE;
    cnt   NUMBER := 1;
    l_res_ass_tbl   res_ass_tbl;
    l_periods_tbl   periods_tbl;
    l_amt_type_tbl   amt_type_tbl;
    -- Bug 5144013: Commenting out the declaration of l_txn_curr_tbl and l_txn_curr_rate_tbl.
    --l_txn_curr_tbl   txn_curr_tbl := txn_curr_tbl(); --Bug 5330532.
    --l_txn_curr_rate_tbl   txn_curr_rate_tbl; --Bug 5330532.
    projfunc_exchange_rate   pa_fp_txn_currencies.projfunc_cost_exchange_rate%TYPE;
    project_exchange_rate   pa_fp_txn_currencies.project_cost_exchange_rate%TYPE;
    l_position NUMBER := 0; -- Bug 5284640.
    l_return NUMBER := 0; -- Bug 5284640.

    l_rec_version_number  NUMBER :=0; --Bug 7863205

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'Y');


    IF l_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'INSERT_PERIODIC_TMP_TABLE'
                                   ,p_debug_mode => l_debug_mode );
        pa_debug.g_err_stage := ':In pa_fp_webadi_pkg.INSERT_PERIODIC_TMP_TABLE' ;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

     l_budget_version_id := p_budget_version_id;

    --Validating Input Parameters.
    IF p_budget_version_id IS NULL THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'p_budget_version_id is passed as null';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => l_module_name);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    ELSE
        IF l_debug_mode = 'Y'  THEN
            pa_debug.g_err_stage := 'Fetching Project Information of the Budget Version';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

        --Fetching Project Information of the budget version and storing them in local variables.
        BEGIN
            SELECT ppa.project_id,
                   ppa.name,
                   ppa.segment1,
                   pbv.record_version_number --Bug 7863205
            INTO   l_project_id,
                   l_project_name,
                   l_project_number,
                   l_rec_version_number --Bug 7863205
            FROM   pa_budget_versions pbv,
                   pa_projects_all ppa
            WHERE  pbv.budget_version_id = l_budget_version_id
            AND    pbv.project_id = ppa.project_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y'  THEN
                     pa_debug.g_err_stage := 'Error getting Project Information for the budget version';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 END IF;
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                      p_token1         => 'PROCEDURENAME',
                                      p_value1         => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END;
    END IF;
    IF l_debug_mode = 'Y'  THEN
        pa_debug.g_err_stage := '-----Project Id : '||l_project_id||'-----';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        pa_debug.g_err_stage := 'Getting Budget Version Details';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

    /*Getting Budget Version Details by calling the GET_PLAN_VERSION_DTLS api.
      The returned PL/SQL record l_version_info will contain the budget version details
    */
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS( p_project_id         => l_project_id,
                                                  p_budget_version_id  => l_budget_version_id,
                                                  x_fp_cols_rec        => l_version_info_rec,
                                                  x_return_status      => l_return_status,
                                                  x_msg_count          => l_msg_count,
                                                  x_msg_data           => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Budget Version Details not found';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    --Getting Structure Version Details and storing them in local variables.
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Getting the Structure version information of the budget version';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
       l_project_structure_version_id := l_version_info_rec.x_project_structure_version_id;
       l_struct_status_flag := PA_PROJECT_STRUCTURE_UTILS.check_struc_ver_published(l_project_id,
                                                                                 l_project_structure_version_id);

    /* Bug 5144013: Commenting out the below code by which we are getting the agreement currency of the plan
       version if the plan version is a change order version and the approved_rev_plan_type_flag of the plan
       version is 'Y'. This is done as we can get the the currencies from the cursor res_ass_cur by making use
       of the new entity pa_resource_asgn_curr. This is done as part of merging the MRUP3 changes done in 11i
       into R12
    */
    /* --Bug 5144013.
    --Getting CI Id and Approved Revenue Flag of the budget version and storing them in local variables.
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Getting CI id and Approved Revenue flag of the budget version';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
     BEGIN
         SELECT ci_id,
                approved_rev_plan_type_flag
         INTO   l_ci_id,
                l_AR_flag
         FROM   pa_budget_versions
         WHERE  budget_version_id = l_budget_version_id;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y'  THEN
                     pa_debug.g_err_stage := 'Error getting CI Id and Approved Revenue flag for the budget version';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 END IF;
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                      p_token1         => 'PROCEDURENAME',
                                      p_value1         => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END;
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := '-----CI Id : '||l_ci_id||' , Approved Revenue Flag : '||l_AR_flag||'-----';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    */ --Bug 5144013.

    /*Getting the Agreement Details of the budget version if the budget version is CI version and and of
      Approved Revenue Plan Type.
    */
    /* --Bug 5144013.
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Getting Agreement details if the budget versions is CI version and of Approved Revenue plan type';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    IF l_ci_id is not null AND L_AR_FLAG = 'Y' THEN
        PA_FIN_PLAN_UTILS2.get_agreement_details(
                                                 p_budget_version_id  => l_budget_version_id,
                                                 p_calling_mode       => 'WA_DOWNLOAD',
                                                 x_agr_curr_code      => l_agr_curr_code,
                                                 x_agr_conv_reqd_flag => l_agr_conv_reqd_flag,
                                                 x_return_status      => l_return_status);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Error in Getting Agreement Details of the budget version';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                  p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                  p_token1         => 'PROCEDURENAME',
                                  p_value1         => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
    END IF;
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage := '-----Agreement Currency Code : '||l_agr_curr_code||'-----';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
    */ --Bug 5144013.

    /*Getting Plan Settings level information of the budget version and storing them in a PL/SQL record.
      The record l_proj_fp_options_rec will contain Plan Settings level information
    */
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Getting Plan Settings level information of the budget version';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
     l_fin_plan_type_id := l_version_info_rec.x_fin_plan_type_id;
     l_version_type := l_version_info_rec.x_version_type;
     l_proj_fp_options_id := l_version_info_rec.x_proj_fp_options_id;
     BEGIN
         SELECT  fin_plan_preference_code,
                 projfunc_cost_rate_type,
                 projfunc_cost_rate_date_type,
                 projfunc_cost_rate_date,
                 project_cost_rate_type,
                 project_cost_rate_date_type,
                 project_cost_rate_date,
                 projfunc_rev_rate_type,
                 projfunc_rev_rate_date_type,
                 projfunc_rev_rate_date,
                 project_rev_rate_type,
                 project_rev_rate_date_type,
                 project_rev_rate_date
         INTO    l_proj_fp_options_rec
         FROM    pa_proj_fp_options
         WHERE   proj_fp_options_id = l_proj_fp_options_id;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
                 IF l_debug_mode = 'Y'  THEN
                     pa_debug.g_err_stage := 'error getting Plan Settings level information of the budget version';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 END IF;
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                      p_token1         => 'PROCEDURENAME',
                                      p_value1         => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END;

    /*Getting Amount Type Codes associated with the budget version.and storing them in a PL/SQL table.
      The PL/SQL table l_amt_type_tbl will contain the Amount Type codes and Conversion Attributes
      associated with the budget version.
    */
    l_plan_class_code := l_version_info_rec.x_plan_class_code;
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Getting Amount Types associated with the budget version';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
     BEGIN
         OPEN   amt_type_cur(l_project_id,l_fin_plan_type_id,l_version_type,l_plan_class_code);
         FETCH   amt_type_cur
         BULK COLLECT INTO   l_amt_type_tbl;
         CLOSE   amt_type_cur;
         IF l_amt_type_tbl.count = 0 THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'No Amount Types found for the budget version';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                 p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                                 p_token1          => 'PROCEDURENAME',
                                 p_value1          => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
     END;

    /*Calling GET_PERIOD_INFORMATION api to get the Group Period Information and Start/End dates of the Periods.
      The returned PL/SQL table l_periods_tbl will contain all the periods and Start and End dates of the periods
      associated with the budget version based on the period mask.
    */
    l_period_mask_id := l_version_info_rec.x_period_mask_id;
    l_time_phased_code := l_version_info_rec.x_time_phased_code;
    l_org_id := l_version_info_rec.x_org_id;
    l_current_planning_period := l_version_info_rec.x_current_planning_period;
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Getting Group Period Information and Start/End dates of the periods';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;
     GET_PERIOD_INFORMATION(p_period_mask_id => l_period_mask_id,
                            p_time_phased_code => l_time_phased_code,
                            p_org_id => l_org_id,
                            p_current_planning_period => l_current_planning_period,
                            x_periods_tbl => l_periods_tbl,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data => l_msg_data);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Error in getting Group Period information of the budget version';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                  p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                  p_token1         => 'PROCEDURENAME',
                                  p_value1         => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF l_periods_tbl.count = 0 THEN
       IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Period Informations not found for the budget version';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                            p_token1         => 'PROCEDURENAME',
                            p_value1         => l_module_name);
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Start of code changes for Bug 5144013.
       Commenting out the below code by which we are getting the exchange rates of the
       transaction currencies of the plan version. This is done as we can get the exchange rates of
       the transaction currencies from the cursor res_ass_cur. This is done as part of merging the
       MRUP3 changes done in 11i into R12.
    */
    /*Getting Transaction Currency rates associated with the budget version.
      The PL/SQL table l_txn_curr_rate_tbl will contain all the Transaction Currency rates
      associated with the budget version.
    */
    /* --Bug 5144013.
    l_projfunc_currency_code := l_version_info_rec.x_projfunc_currency_code;
    l_project_currency_code := l_version_info_rec.x_project_currency_code;
    l_multi_curr_flag := l_version_info_rec.x_plan_in_multi_curr_flag;
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage := 'Getting Transaction Currency rates associated with the budget version';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
    END IF;

     BEGIN
    */ --Bug 5144013.
         /* Start of code changes for bug 5330532. */
         /* --Bug 5144013.
         FOR rat IN txn_curr_rate_cur(l_budget_version_id, l_proj_fp_options_id) LOOP
            l_txn_curr_rate_tbl(rat.txn_currency_code).txn_currency_code := rat.txn_currency_code;
            l_txn_curr_rate_tbl(rat.txn_currency_code).project_cost_exchange_rate  := rat.project_cost_exchange_rate;
            l_txn_curr_rate_tbl(rat.txn_currency_code).project_rev_exchange_rate   := rat.project_rev_exchange_rate;
            l_txn_curr_rate_tbl(rat.txn_currency_code).projfunc_cost_exchange_rate := rat.projfunc_cost_exchange_rate;
            l_txn_curr_rate_tbl(rat.txn_currency_code).projfunc_rev_exchange_rate  := rat.projfunc_rev_exchange_rate;
         END LOOP;
         */ --Bug 5144013.
        /* End of code changes for bug 5330532. */

         -- Commented out the below for bug 5330532.
          /*
          SELECT DISTINCT(nvl(pbl.txn_currency_code,DECODE(l_ci_id,
                                                  null, DECODE(l_AR_flag,
                                                  'Y', l_projfunc_currency_code,
                                                       l_project_currency_code),
                                                        DECODE(l_version_type,
                                                               'ALL', l_agr_curr_code,
                                                               'REVENUE', l_agr_curr_code,
                                                               DECODE(l_AR_flag,
                                                                      'Y', l_projfunc_currency_code,
                                                                           l_project_currency_code))))) as txn_currency_code,
                  pftc.project_cost_exchange_rate,
                  pftc.project_rev_exchange_rate,
                  pftc.projfunc_cost_exchange_rate,
                  pftc.projfunc_rev_exchange_rate
          BULK COLLECT INTO l_txn_curr_tbl
          FROM pa_budget_lines pbl,
               pa_fp_txn_currencies pftc
          WHERE pbl.budget_version_id = l_budget_version_id
          AND   pftc.fin_plan_version_id = l_budget_version_id
          AND   pftc.proj_fp_options_id = l_proj_fp_options_id
          and   pbl.txn_currency_code = pftc.txn_currency_code;

         IF l_txn_curr_tbl.count = 0 THEN
            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'No transaction currency found for the budget version';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                 p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                                 p_token1          => 'PROCEDURENAME',
                                 p_value1          => l_module_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
         */
     --END;
     /* End of code changes done for Bug 5144013.*/

    /*Getting Resource Assignment details of the budget version
      The PL/SQL table l_res_ass_tbl will contain all the Resource Assignment
      information associated with the budget version.
    */
     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Getting the Resource Assignment details of the budget version';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;
     BEGIN
          /* Start of coding done for bug 5641300: Using the bulk collect logic instead of for loop
             as res_ass_tbl is converted to ordinary pl/sql table from index by pl/sql table.
          */
          /*
          FOR rec in res_ass_cur(l_budget_version_id,l_project_id,l_project_structure_version_id)
          LOOP
             l_res_ass_tbl(rec.resource_assignment_id) := rec;
          END LOOP;
          */
          -- Bug 5144013: Made changes to pass proj_fp_options_id as a parameter to the cursor res_ass_cur.
          OPEN res_ass_cur(l_budget_version_id,l_project_id,l_project_structure_version_id,l_proj_fp_options_id);
          FETCH res_ass_cur BULK COLLECT INTO l_res_ass_tbl;
          CLOSE res_ass_cur;
          /* End of coding done for bug 5641300.*/
          IF l_res_ass_tbl.count = 0 THEN
             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'No Resource Assignments found for the budget version';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             END IF;
             -- Bug 5360205: Commented out the following and raised NO_RA_EXC.
             /*
             PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                  p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                                  p_token1          => 'PROCEDURENAME',
                                  p_value1          => l_module_name);
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             */
             RAISE NO_RA_EXC;
         END IF;
     END;

     l_fin_plan_preference_code := l_proj_fp_options_rec.fin_plan_preference_code;
    /*Getting the values of all the Amount Types for each Resource Assignment and Transaction
      Currency combination for all the periods associated with the budget version
    */
     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Getting Amounts of all the Periods associated with the budget version';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
     END IF;
      BEGIN
          l_global_tmp_tbl := global_tmp_tbl();
          l_global_tmp_rec.budget_version_id := l_budget_version_id;
          l_global_tmp_rec.fin_plan_preference_code := l_fin_plan_preference_code;
          l_global_tmp_rec.plan_class_code := l_plan_class_code;
          l_global_tmp_rec.project_name := l_project_name;
          l_global_tmp_rec.record_version_number := l_rec_version_number; --Bug 7863205
          l_global_tmp_rec.project_number := l_project_number;
          l_global_tmp_rec.project_id := l_project_id;
          l_global_tmp_rec.delete_flag := null;
          FOR res IN l_res_ass_tbl.first..l_res_ass_tbl.last LOOP
             l_global_tmp_rec.resource_assignment_id := l_res_ass_tbl(res).resource_assignment_id;
             l_global_tmp_rec.task_number := l_res_ass_tbl(res).task_number;
             l_global_tmp_rec.task_name := l_res_ass_tbl(res).task_name;
             l_global_tmp_rec.task_display_sequence := l_res_ass_tbl(res).task_display_sequence;
             l_global_tmp_rec.resource_alias := l_res_ass_tbl(res).resource_name;
             l_global_tmp_rec.unit_of_measure := l_res_ass_tbl(res).unit_of_measure;
             l_global_tmp_rec.resource_list_member_id := l_res_ass_tbl(res).resource_list_member_id;
             l_global_tmp_rec.spread_curve_id := l_res_ass_tbl(res).spread_curve_id;
             l_global_tmp_rec.spread_curve := l_res_ass_tbl(res).spread_curve;
             l_global_tmp_rec.start_date := l_res_ass_tbl(res).planning_start_date;
             l_global_tmp_rec.end_date := l_res_ass_tbl(res).planning_end_date;
             l_global_tmp_rec.mfc_cost_type_id := l_res_ass_tbl(res).mfc_cost_type_id;
             l_global_tmp_rec.mfc_cost_type := l_res_ass_tbl(res).mfc_cost_type;
             l_global_tmp_rec.etc_method_code := l_res_ass_tbl(res).etc_method_code;
             l_global_tmp_rec.etc_method := l_res_ass_tbl(res).etc_method;
             l_global_tmp_rec.etc_source := l_res_ass_tbl(res).etc_source;
             l_global_tmp_rec.physical_percent_complete := PA_FIN_PLAN_UTILS.get_physical_pc_complete
                                                            (p_project_id => l_project_id,
                                                             p_proj_element_id => l_res_ass_tbl(res).project_element_id);

             /* Bug 5144013: Commenting out the below code by which we get the transaction currencies of the
                resource assignment. This is done as we can get the resource assignment and transaction currency
                combination from the cursor res_ass_cur. This is done as part of merging the MRUP3 changes done
                in 11i into R12.
             */
             /* Start of code changes for bug 5330532 */
             /* --Bug 5144013.
             BEGIN
                 l_txn_curr_tbl.DELETE;
                 OPEN txn_curr_cur(l_budget_version_id, l_res_ass_tbl(res).resource_assignment_id);
                 FETCH txn_curr_cur BULK COLLECT INTO l_txn_curr_tbl;
                 CLOSE txn_curr_cur;
                 IF l_txn_curr_tbl.COUNT = 0 THEN
                    l_txn_curr_tbl.extend(1);
                    SELECT    (DECODE(l_ci_id,
                                       null, DECODE(l_AR_flag,
                                       'Y', l_projfunc_currency_code,
                                            l_project_currency_code),
                                             DECODE(l_version_type,
                                                    'ALL', l_agr_curr_code,
                                                    'REVENUE', l_agr_curr_code,
                                                               l_project_currency_code)))
                    INTO l_txn_curr_tbl(1).txn_currency_code
                    FROM dual;
                 END IF;
             END;
             */ --Bug 5144013.
            /* End of code changes for bug 5330532 */
             --FOR txn IN l_txn_curr_tbl.first..l_txn_curr_tbl.last LOOP   Bug 5144013.
             l_global_tmp_rec.txn_currency_code := l_res_ass_tbl(res).txn_currency_code; --Bug 5144013.
                FOR amt IN l_amt_type_tbl.first..l_amt_type_tbl.last LOOP
                    l_global_tmp_rec.amount_type_code := l_amt_type_tbl(amt).amount_type_code;
                    l_global_tmp_rec.amount_type_name := l_amt_type_tbl(amt).amount_type_name;
                    l_global_tmp_rec.projfunc_rate_type := l_amt_type_tbl(amt).projfunc_rate_type;
                    l_global_tmp_rec.projfunc_rate_date_type := l_amt_type_tbl(amt).projfunc_rate_date_type;
                    l_global_tmp_rec.projfunc_rate_date := l_amt_type_tbl(amt).projfunc_rate_date;
                    l_global_tmp_rec.project_rate_type := l_amt_type_tbl(amt).project_rate_type;
                    l_global_tmp_rec.project_rate_date_type := l_amt_type_tbl(amt).project_rate_date_type;
                    l_global_tmp_rec.project_rate_date := l_amt_type_tbl(amt).project_rate_date;
                    /* Bug 5144013. Made changes in the below select to get the exchange rates of the transaction
                       currencies from pl/sql table l_res_ass_tbl.
                    */
                    -- Bug 5330532. Used newly introduced rate table l_txn_curr_rate_tbl in the following select statement.
                    SELECT
                          decode(l_amt_type_tbl(amt).amount_type_code,'TOTAL_REV',decode(l_proj_fp_options_rec.projfunc_rev_rate_type,'User',l_res_ass_tbl(res).projfunc_rev_exchange_rate,TO_NUMBER(null)),
                          decode(l_proj_fp_options_rec.projfunc_cost_rate_type,'User',null,l_res_ass_tbl(res).projfunc_cost_exchange_rate,TO_NUMBER(null))),

                          decode(l_amt_type_tbl(amt).amount_type_code,'TOTAL_REV',decode(l_proj_fp_options_rec.project_rev_rate_type,'User',l_res_ass_tbl(res).project_rev_exchange_rate,TO_NUMBER(null)),
                          decode(l_proj_fp_options_rec.project_cost_rate_type,'User',null,l_res_ass_tbl(res).project_cost_exchange_rate,TO_NUMBER(null)))
                    INTO projfunc_exchange_rate,
                         project_exchange_rate
                    FROM dual;
                    l_global_tmp_rec.projfunc_exchange_rate := projfunc_exchange_rate;
                    l_global_tmp_rec.project_exchange_rate := project_exchange_rate;
                    FOR prd in l_periods_tbl.first-1..l_periods_tbl.last+1 LOOP
                        IF prd <> l_periods_tbl.first-1 and prd <> l_periods_tbl.last+1 THEN
                           l_position := l_periods_tbl(prd).sequence_number;
                           l_start_date := l_periods_tbl(prd).start_date;
                           l_end_date := l_periods_tbl(prd).end_date;
                           l_preceding_date := to_date(null);
                           l_succeeding_date := to_date(null);
                        ELSIF prd = l_periods_tbl.first-1 THEN
                           l_start_date := to_date(null);
                           l_end_date := to_date(null);
                           l_preceding_date := l_periods_tbl(l_periods_tbl.first).start_date;
                           l_succeeding_date := to_date(null);
                        ELSIF prd = l_periods_tbl.last+1 THEN
                           l_start_date := to_date(null);
                           l_end_date := to_date(null);
                           l_preceding_date := to_date(null);
                           l_succeeding_date := l_periods_tbl(l_periods_tbl.last).end_date;
                        END IF;
                        --Calling get_period_amounts api to get the value of the Amount Type for a period.
                        l_return := pa_fp_webadi_utils.get_period_amounts(
                                            p_budget_version_id => l_budget_version_id,
                                            p_amount_code => l_amt_type_tbl(amt).amount_type_code,
                                            p_resource_assignment_id => l_res_ass_tbl(res).resource_assignment_id,
                                            p_txn_currency_code => l_res_ass_tbl(res).txn_currency_code, --Bug 5144013.
                                            p_prd_start_date => l_start_date,
                                            p_prd_end_date => l_end_date,
                                            preceding_date => l_preceding_date,
                                            succedeing_date => l_succeeding_date);
                        IF prd = l_periods_tbl.first-1 THEN
                           l_global_tmp_rec.preceding_period_amount := l_return;
                        ELSIF prd = l_periods_tbl.last+1 THEN
                           l_global_tmp_rec.succeeding_period_amount := l_return;
                        ELSE
                        -- Bug 5284640: Commented out the below Dynamic SQL and added PL/SQL code for improving performance.
                        /*
                           --Dynamic SQL used to insert the Amount Type value in the corresponding period column.
                           EXECUTE IMMEDIATE
                                  'BEGIN '||
                                  'pa_fp_webadi_pkg.l_global_tmp_rec.prd'||pa_fp_webadi_pkg.l_position||' := pa_fp_webadi_pkg.l_return; '||
                                  'END;';
                        */
                           IF l_position = 1 THEN
                              l_global_tmp_rec.prd1 := l_return;
                           ELSIF l_position = 2 THEN
                              l_global_tmp_rec.prd2 := l_return;
                           ELSIF l_position = 3 THEN
                              l_global_tmp_rec.prd3 := l_return;
                           ELSIF l_position = 4 THEN
                              l_global_tmp_rec.prd4 := l_return;
                           ELSIF l_position = 5 THEN
                              l_global_tmp_rec.prd5 := l_return;
                           ELSIF l_position = 6 THEN
                              l_global_tmp_rec.prd6 := l_return;
                           ELSIF l_position =7 THEN
                              l_global_tmp_rec.prd7 := l_return;
                           ELSIF l_position = 8 THEN
                              l_global_tmp_rec.prd8 := l_return;
                           ELSIF l_position = 9 THEN
                              l_global_tmp_rec.prd9 := l_return;
                           ELSIF l_position = 10 THEN
                              l_global_tmp_rec.prd10 := l_return;
                           ELSIF l_position = 11 THEN
                              l_global_tmp_rec.prd11 := l_return;
                           ELSIF l_position = 12 THEN
                              l_global_tmp_rec.prd12 := l_return;
                           ELSIF l_position = 13 THEN
                              l_global_tmp_rec.prd13 := l_return;
                           ELSIF l_position = 14 THEN
                              l_global_tmp_rec.prd14 := l_return;
                           ELSIF l_position = 15 THEN
                              l_global_tmp_rec.prd15 := l_return;
                           ELSIF l_position = 16 THEN
                              l_global_tmp_rec.prd16 := l_return;
                           ELSIF l_position = 17 THEN
                              l_global_tmp_rec.prd17 := l_return;
                           ELSIF l_position = 18 THEN
                              l_global_tmp_rec.prd18 := l_return;
                           ELSIF l_position = 19 THEN
                              l_global_tmp_rec.prd19 := l_return;
                           ELSIF l_position = 20 THEN
                              l_global_tmp_rec.prd20 := l_return;
                           ELSIF l_position = 21 THEN
                              l_global_tmp_rec.prd21 := l_return;
                           ELSIF l_position = 22 THEN
                              l_global_tmp_rec.prd22 := l_return;
                           ELSIF l_position = 23 THEN
                              l_global_tmp_rec.prd23 := l_return;
                           ELSIF l_position = 24 THEN
                              l_global_tmp_rec.prd24 := l_return;
                           ELSIF l_position = 25 THEN
                              l_global_tmp_rec.prd25 := l_return;
                           ELSIF l_position = 26 THEN
                              l_global_tmp_rec.prd26 := l_return;
                           ELSIF l_position = 27 THEN
                              l_global_tmp_rec.prd27 := l_return;
                           ELSIF l_position = 28 THEN
                              l_global_tmp_rec.prd28 := l_return;
                           ELSIF l_position = 29 THEN
                              l_global_tmp_rec.prd29 := l_return;
                           ELSIF l_position = 30 THEN
                              l_global_tmp_rec.prd30 := l_return;
                           ELSIF l_position = 31 THEN
                              l_global_tmp_rec.prd31 := l_return;
                           ELSIF l_position = 32 THEN
                              l_global_tmp_rec.prd32 := l_return;
                           ELSIF l_position = 33 THEN
                              l_global_tmp_rec.prd33 := l_return;
                           ELSIF l_position = 34 THEN
                              l_global_tmp_rec.prd34 := l_return;
                           ELSIF l_position = 35 THEN
                              l_global_tmp_rec.prd35 := l_return;
                           ELSIF l_position = 36 THEN
                              l_global_tmp_rec.prd36 := l_return;
                           ELSIF l_position = 37 THEN
                              l_global_tmp_rec.prd37 := l_return;
                           ELSIF l_position = 38 THEN
                              l_global_tmp_rec.prd38 := l_return;
                           ELSIF l_position = 39 THEN
                              l_global_tmp_rec.prd39 := l_return;
                           ELSIF l_position = 40 THEN
                              l_global_tmp_rec.prd40 := l_return;
                           ELSIF l_position = 41 THEN
                              l_global_tmp_rec.prd41 := l_return;
                           ELSIF l_position = 42 THEN
                              l_global_tmp_rec.prd42 := l_return;
                           ELSIF l_position = 43 THEN
                              l_global_tmp_rec.prd43 := l_return;
                           ELSIF l_position = 44 THEN
                              l_global_tmp_rec.prd44 := l_return;
                           ELSIF l_position = 45 THEN
                              l_global_tmp_rec.prd45 := l_return;
                           ELSIF l_position = 46 THEN
                              l_global_tmp_rec.prd46 := l_return;
                           ELSIF l_position = 47 THEN
                              l_global_tmp_rec.prd47 := l_return;
                           ELSIF l_position = 48 THEN
                              l_global_tmp_rec.prd48 := l_return;
                           ELSIF l_position = 49 THEN
                              l_global_tmp_rec.prd49 := l_return;
                           ELSIF l_position = 50 THEN
                              l_global_tmp_rec.prd50 := l_return;
                           ELSIF l_position = 51 THEN
                              l_global_tmp_rec.prd51 := l_return;
                           ELSIF l_position = 52 THEN
                              l_global_tmp_rec.prd52 := l_return;
                           END IF;
                        END IF;
                    END LOOP;
                    --Inserting the record containig the budget line information into the PL/SQL table.
                    l_global_tmp_tbl.extend();
                    l_global_tmp_tbl(cnt) := l_global_tmp_rec;
                    cnt := cnt+1;
                END LOOP;
             --END LOOP; Bug 5144013.
          END LOOP;
          --Resetting the value of all the global variables.
          l_position := 0;
          l_global_tmp_rec := null;
          l_return := 0;
      END;
       /*Populating Global Temparory Table pa_fp_webadi_xface_tmp using the PL/SQL
         table l_global_tmp_tbl which contains all the budget line details.
       */
       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Before inerting into Global Temporary Table';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
         BEGIN
/*               FOR tmp IN l_global_tmp_tbl.first..l_global_tmp_tbl.last
               LOOP
                 INSERT INTO pa_fp_webadi_xface_tmp
                 VALUES l_global_tmp_tbl(tmp);
               END LOOP;
               commit;*/
             FORALL tmp IN l_global_tmp_tbl.first..l_global_tmp_tbl.last
               INSERT INTO pa_fp_webadi_xface_tmp
               VALUES l_global_tmp_tbl(tmp);
         EXCEPTION
             WHEN OTHERS THEN
                RAISE;
         END;
       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Finished inserting into Global temparory table';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       --Resetting the value of the Global PL/SQL table to NULL.
       l_global_tmp_tbl := null;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count = 1 and x_msg_data IS NULL THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                   ,p_msg_index      => 1
                   ,p_msg_count      => l_msg_count
                   ,p_msg_data       => l_msg_data
                   ,p_data           => l_data
                   ,p_msg_index_out  => l_msg_index_out);
                   x_msg_data := l_data;
                   x_msg_count := l_msg_count;
         ELSE
            x_msg_count := l_msg_count;
         END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
         IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
         END IF;
    RETURN;

    -- Bug 5360205: Added NO_RA_EXC block.
    WHEN NO_RA_EXC THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         IF l_debug_mode = 'Y' THEN
             pa_debug.reset_curr_function;
         END IF;
    RETURN;

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SQLERRM;
         FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fp_webadi_pkg'
                                 ,p_procedure_name  => 'insert_periodic_tmp_table');
         IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             pa_debug.reset_curr_function;
         END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END insert_periodic_tmp_table;


END pa_fp_webadi_pkg;

/
