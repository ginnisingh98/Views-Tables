--------------------------------------------------------
--  DDL for Package PA_FP_MULTI_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_MULTI_CURRENCY_PKG" AUTHID CURRENT_USER AS
--$Header: PAFPMCPS.pls 120.2 2006/07/26 10:22:43 prachand noship $


   -- Package Variables.

  g_project_id pa_projects_all.project_id%TYPE;
  g_project_number pa_projects_all.segment1%TYPE;
  g_fin_plan_type_id pa_proj_fp_options.fin_plan_type_id%TYPE;

  g_projfunc_currency_code varchar2(30);
  g_projfunc_cost_rate_type varchar2(30);
  g_projfunc_cost_exchange_rate number;
  g_projfunc_cost_rate_date_type varchar2(30);
  g_projfunc_cost_rate_date date;
  g_projfunc_rev_rate_type varchar2(30);
  g_projfunc_rev_exchange_rate number;
  g_projfunc_rev_rate_date_type varchar2(30);
  g_projfunc_rev_rate_date date;

  g_proj_currency_code varchar2(30);
  g_proj_cost_rate_type varchar2(30);
  g_proj_cost_exchange_rate number;
  g_proj_cost_rate_date_type varchar2(30);
  g_proj_cost_rate_date date;
  g_proj_rev_rate_type varchar2(30);
  g_proj_rev_exchange_rate number;
  g_proj_rev_rate_date_type varchar2(30);
  g_proj_rev_rate_date date;

  TYPE cached_row IS RECORD (
       from_currency      VARCHAR2(30),
       to_currency        VARCHAR2(30),
       numerator          NUMBER,
       denominator        NUMBER,
       rate               NUMBER,
       rate_date          DATE,
       rate_type          VARCHAR2(30),
       line_type          VARCHAR2(30));  -- will store Cost/Revenue

  TYPE cached_row_tab is TABLE of cached_row INDEX BY BINARY_INTEGER;

     TYPE number_type_tab IS TABLE OF NUMBER
          INDEX BY BINARY_INTEGER;

     TYPE date_type_tab IS TABLE OF DATE
          INDEX BY BINARY_INTEGER;

     TYPE char30_type_tab IS TABLE OF VARCHAR2(30)
          INDEX BY BINARY_INTEGER;

     TYPE char240_type_tab IS TABLE OF VARCHAR2(240)
          INDEX BY BINARY_INTEGER;

     TYPE rowid_type_tab IS TABLE OF ROWID
          INDEX BY BINARY_INTEGER;

  PROCEDURE conv_mc_bulk ( p_resource_assignment_id_tab  IN pa_fp_multi_currency_pkg.number_type_tab
                          ,p_start_date_tab              IN pa_fp_multi_currency_pkg.date_type_tab
                          ,p_end_date_tab                IN pa_fp_multi_currency_pkg.date_type_tab
                          ,p_txn_currency_code_tab       IN pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_txn_raw_cost_tab            IN pa_fp_multi_currency_pkg.number_type_tab
                          ,p_txn_burdened_cost_tab       IN pa_fp_multi_currency_pkg.number_type_tab
                          ,p_txn_revenue_tab             IN pa_fp_multi_currency_pkg.number_type_tab
                          ,p_projfunc_currency_code_tab  IN pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_projfunc_cost_rate_type_tab IN pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_projfunc_cost_rate_tab      IN OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,p_projfunc_cost_rate_date_tab IN pa_fp_multi_currency_pkg.date_type_tab
                          ,p_projfunc_rev_rate_type_tab  IN pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_projfunc_rev_rate_tab       IN OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,p_projfunc_rev_rate_date_tab  IN pa_fp_multi_currency_pkg.date_type_tab
                          ,x_projfunc_raw_cost_tab       OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,x_projfunc_burdened_cost_tab  OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,x_projfunc_revenue_tab        OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,x_projfunc_rejection_tab      OUT NOCOPY pa_fp_multi_currency_pkg.char30_type_tab
                          ,p_proj_currency_code_tab      IN pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_proj_cost_rate_type_tab     IN pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_proj_cost_rate_tab          IN OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,p_proj_cost_rate_date_tab     IN pa_fp_multi_currency_pkg.date_type_tab
                          ,p_proj_rev_rate_type_tab      IN pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_proj_rev_rate_tab           IN OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,p_proj_rev_rate_date_tab      IN pa_fp_multi_currency_pkg.date_type_tab
                          ,x_proj_raw_cost_tab           OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,x_proj_burdened_cost_tab      OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,x_proj_revenue_tab            OUT NOCOPY pa_fp_multi_currency_pkg.number_type_tab
                          ,x_proj_rejection_tab          OUT NOCOPY pa_fp_multi_currency_pkg.char30_type_tab
                          ,p_user_validate_flag_tab      IN pa_fp_multi_currency_pkg.char240_type_tab
                          ,p_calling_module              IN  VARCHAR2  DEFAULT   'UPDATE_PLAN_TRANSACTION' -- Added for bug#5395732
                          ,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                          ,x_msg_data                    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* added two new params source context and budget line id
 * so that this api can be called from calculate for each budget line
 * while updating the budget lines to derive pc and pfc attribs
 */
  PROCEDURE convert_txn_currency
            ( p_budget_version_id      IN pa_budget_versions.budget_version_id%TYPE
             ,p_entire_version         IN VARCHAR2 DEFAULT 'N'
	     ,p_budget_line_id         IN NUMBER   DEFAULT NULL
	     ,p_source_context         IN VARCHAR2 DEFAULT 'BUDGET_VERSION'
         ,p_calling_module               IN VARCHAR2 DEFAULT 'UPDATE_PLAN_TRANSACTION'-- Added for Bug#5395732
             ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*=============================================================================
 This api is used to Round budget line amounts as per the currency precision/
 MAU (Minimum Accountable Unit). Quantity would be rounded to 5 decimal points.
 The api would be called from Copy Version Amounts flow with non-zero adj %
 The api is also called Change Order Revenue amount partial implementation.

 p_calling_context -> COPY_VERSION, CHANGE_ORDER_MERGE
 The parameters p_bls_inserted_after_id  will be used only
 when p_calling_context is CHANGE_ORDER_MERGE
 p_bls_inserted_after_id : This value will be used to find out the budget lines that
                           got inserted in this flow. All the budget lines with
                           1. budget line id > p_bls_inserted_after_id AND
                           2. budget_Version_id = p_budget_version_id
                           will be considered as inserted in this flow.

 Tracking bug No: 4035856  Rravipat  Initial creation
==============================================================================*/

PROCEDURE Round_Budget_Line_Amounts(
           p_budget_version_id      IN   pa_budget_versions.budget_version_id%TYPE
          ,p_bls_inserted_after_id  IN   pa_budget_lines.budget_line_id%TYPE        DEFAULT NULL
          ,p_calling_context        IN   VARCHAR2
          ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data               OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Perf Bug :3683132 The outer join with pa_fp_currencies causing FTS exceeds 10
 * in order to avoid this, a function created to cache the values
 * and remove the outer joins from the where clause
 * After this change the explain plan is
 * Shared memory(M) = 62831, Parse Time(S) = 0 , Total Cost = 51, Nof. FTS =  0
 1:SELECT STATEMENT   :(cost=51,rows=1)
  2:SORT ORDER BY  :(cost=51,rows=1)
    3:FILTER   :(cost=,rows=)
      4:TABLE ACCESS BY INDEX ROWID PA_BUDGET_LINES :(cost=49,rows=1)
        5:INDEX RANGE SCAN PA_BUDGET_LINES_N3 :(cost=2,rows=1)
      4:TABLE ACCESS BY INDEX ROWID PA_RESOURCE_ASSIGNMENTS :(cost=2,rows=1)
        5:INDEX UNIQUE SCAN PA_RESOURCE_ASSIGNMENTS_U1 :(cost=1,rows=1)
 * Refer to bug for more details
 */
FUNCTION get_fp_cur_details( p_budget_version_id   Number
                        ,p_txn_currency_code       Varchar2
                        ,p_context                 Varchar2 default 'COST'
                        ,p_mode                    Varchar2 default 'PROJECT' ) RETURN NUMBER ;

-->This API is written as part of rounding changes. This API will be called from PAFPCIMB.implement_ci_into_single_ver
-->API when partial implementation happens.
---->p_agr_currency_code,p_project_currency_code and p_projfunc_currency_code should be valid and not null
---->All the p_...tbl input parameters should have same no. of elemeents
---->p_txn...tbls will be rounded based on p_agr_currency_code, p_project_...tbls will be rounded based on
     --p_project_currency_code and p_projfunc_...tbls will be rounded based on p_projfunc_currency_code
---->px_quantity_tbl will be rounded to have max 5 digits after decimal point
PROCEDURE round_amounts
( px_quantity_tbl               IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,p_agr_currency_code           IN OUT         NOCOPY pa_budget_lines.txn_currency_code%TYPE          --File.Sql.39 bug 4440895
 ,px_txn_raw_cost_tbl           IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_txn_burdened_cost_tbl      IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_txn_revenue_tbl            IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,p_project_currency_code       IN OUT         NOCOPY pa_budget_lines.project_currency_code%TYPE      --File.Sql.39 bug 4440895
 ,px_project_raw_cost_tbl       IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_project_burdened_cost_tbl  IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_project_revenue_tbl        IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,p_projfunc_currency_code      IN OUT         NOCOPY pa_budget_lines.projfunc_currency_code%TYPE     --File.Sql.39 bug 4440895
 ,px_projfunc_raw_cost_tbl      IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_projfunc_burdened_cost_tbl IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,px_projfunc_revenue_tbl       IN OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,x_return_status                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
END PA_FP_MULTI_CURRENCY_PKG;

 

/
