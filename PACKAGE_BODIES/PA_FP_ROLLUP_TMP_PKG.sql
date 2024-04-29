--------------------------------------------------------
--  DDL for Package Body PA_FP_ROLLUP_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_ROLLUP_TMP_PKG" AS
/* $Header: PAFPRLTB.pls 120.1.12010000.2 2009/06/17 22:00:08 djanaswa ship $*/

g_module_name  VARCHAR2(100) := 'pa.plsql.pa_fp_rollup_tmp_pkg';

PROCEDURE POPULATE_IN_BULK
                   (  p_res_assignment_id_tbl        IN pa_fp_webadi_pkg.l_res_assignment_id_tbl_typ
                    , p_parent_assignment_id_tbl     IN pa_fp_webadi_pkg.l_parent_assign_id_tbl_typ
                    , p_start_date_tbl               IN pa_fp_webadi_pkg.l_start_date_tbl_typ
                    , p_end_date_tbl                 IN pa_fp_webadi_pkg.l_end_date_tbl_typ
                    , p_txn_currency_code_tbl        IN pa_fp_webadi_pkg.l_txn_currency_code_tbl_typ
                    , p_proj_currency_code_tbl       IN pa_fp_webadi_pkg.l_proj_currency_code_tbl_typ
                    , p_pf_currency_code_tbl         IN pa_fp_webadi_pkg.l_pf_currency_code_tbl_typ
                    , p_proj_cost_rate_type_tbl      IN pa_fp_webadi_pkg.l_proj_cost_rate_type_tbl_typ
                    , p_proj_cost_rt_dt_type_tbl     IN pa_fp_webadi_pkg.l_proj_cost_rt_dt_type_tbl_typ
                    , p_proj_cost_exc_rate_tbl       IN pa_fp_webadi_pkg.l_proj_cost_exc_rate_tbl_typ
                    , p_proj_cost_rate_date_tbl      IN pa_fp_webadi_pkg.l_proj_cost_rate_date_tbl_typ
                    , p_proj_rev_rate_type_tbl       IN pa_fp_webadi_pkg.l_proj_rev_rate_type_tbl_typ
                    , p_proj_rev_rt_dt_type_tbl      IN pa_fp_webadi_pkg.l_proj_rev_rt_dt_type_tbl_typ
                    , p_proj_rev_exc_rate_tbl        IN pa_fp_webadi_pkg.l_proj_rev_exc_rate_tbl_typ
                    , p_proj_rev_rate_date_tbl       IN pa_fp_webadi_pkg.l_proj_rev_rate_date_tbl_typ
                    , p_pf_cost_rate_type_tbl        IN pa_fp_webadi_pkg.l_pf_cost_rate_type_tbl_typ
                    , p_pf_cost_rt_dt_type_tbl       IN pa_fp_webadi_pkg.l_pf_cost_rt_dt_type_tbl_typ
                    , p_pf_cost_exc_rate_tbl         IN pa_fp_webadi_pkg.l_pf_cost_exc_rate_tbl_typ
                    , p_pf_cost_rate_date_tbl        IN pa_fp_webadi_pkg.l_pf_cost_rate_date_tbl_typ
                    , p_pf_rev_rate_type_tbl         IN pa_fp_webadi_pkg.l_pf_rev_rate_type_tbl_typ
                    , p_pf_rev_rt_dt_type_tbl        IN pa_fp_webadi_pkg.l_pf_rev_rt_dt_type_tbl_typ
                    , p_pf_rev_exc_rate_tbl          IN pa_fp_webadi_pkg.l_pf_rev_exc_rate_tbl_typ
                    , p_pf_rev_rate_date_tbl         IN pa_fp_webadi_pkg.l_pf_rev_rate_date_tbl_typ
                    , p_old_proj_raw_cost_tbl        IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_proj_burdened_cost_tbl   IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_proj_revenue_tbl         IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_pf_raw_cost_tbl          IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_pf_burdened_cost_tbl     IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_pf_revenue_tbl           IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_quantity_tbl             IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_txn_raw_cost_tbl         IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_txn_burdened_cost_tbl    IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_old_txn_revenue_tbl          IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_txn_raw_cost_tbl             IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_txn_burdened_cost_tbl        IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_txn_revenue_tbl              IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_quantity_tbl                 IN pa_fp_webadi_pkg.l_amount_tbl_typ
                    , p_delete_flag_tbl              IN pa_fp_webadi_pkg.l_delete_flag_tbl_typ
                    , p_period_name_tbl              IN pa_fp_webadi_pkg.l_period_name_tbl_typ
                    , p_change_reason_code_tbl       IN pa_fp_webadi_pkg.l_change_reason_code_tbl_typ
                    , p_description_tbl              IN pa_fp_webadi_pkg.l_description_tbl_typ
                    , p_pm_product_code_tbl          IN pa_fp_webadi_pkg.l_pm_product_code_tbl_typ
                    , p_attribute_category_tbl       IN pa_fp_webadi_pkg.l_attribute_category_tbl_typ
                    , p_attribute1_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute2_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute3_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute4_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute5_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute6_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute7_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute8_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute9_tbl               IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute10_tbl              IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute11_tbl              IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute12_tbl              IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute13_tbl              IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute14_tbl              IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_attribute15_tbl              IN pa_fp_webadi_pkg.l_attribute_tbl_typ
                    , p_budget_line_id_tbl           IN pa_fp_webadi_pkg.l_budget_line_id_tbl_typ
                    , x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    , x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                    , x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_debug_mode                   VARCHAR2(1) ;
  l_msg_count                     NUMBER := 0;
  l_data                          VARCHAR2(2000);
  l_msg_data                      VARCHAR2(2000);
  l_msg_index_out                 NUMBER;
  l_count                         NUMBER;
BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    IF l_debug_mode = 'Y' THEN

       pa_debug.set_err_stack('PA_FP_ROLLUP_TMP_PKG.POPULATE_IN_BULK');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);

     END IF;

     IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := ':In PA_FP_ROLLUP_TMP_PKG.POPULATE_IN_BULK p_res_assignment_id_tbl.last = ' || p_res_assignment_id_tbl.last;
           pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF nvl(p_res_assignment_id_tbl.LAST,0) > 0 THEN

            FORALL i in p_res_assignment_id_tbl.first..p_res_assignment_id_tbl.last

                      INSERT INTO PA_FP_ROLLUP_TMP(
                                   ROLLUP_ID
                                 , RESOURCE_ASSIGNMENT_ID
                                 , PARENT_ASSIGNMENT_ID
                                 , START_DATE
                                 , END_DATE
                                 , TXN_CURRENCY_CODE
                                 , PROJECT_CURRENCY_CODE
                                 , PROJFUNC_CURRENCY_CODE
                                 , PROJECT_COST_RATE_TYPE
                                 , PROJECT_COST_RATE_DATE_TYPE
                                 , PROJECT_COST_EXCHANGE_RATE
                                 , PROJECT_COST_RATE_DATE
                                 , PROJECT_REV_RATE_TYPE
                                 , PROJECT_REV_RATE_DATE_TYPE
                                 , PROJECT_REV_EXCHANGE_RATE
                                 , PROJECT_REV_RATE_DATE
                                 , PROJFUNC_COST_RATE_TYPE
                                 , PROJFUNC_COST_RATE_DATE_TYPE
                                 , PROJFUNC_COST_EXCHANGE_RATE
                                 , PROJFUNC_COST_RATE_DATE
                                 , PROJFUNC_REV_RATE_TYPE
                                 , PROJFUNC_REV_RATE_DATE_TYPE
                                 , PROJFUNC_REV_EXCHANGE_RATE
                                 , PROJFUNC_REV_RATE_DATE
                                 , OLD_PROJ_RAW_COST
                                 , OLD_PROJ_BURDENED_COST
                                 , OLD_PROJ_REVENUE
                                 , OLD_PROJFUNC_RAW_COST
                                 , OLD_PROJFUNC_BURDENED_COST
                                 , OLD_PROJFUNC_REVENUE
                                 , OLD_QUANTITY
                                 , OLD_TXN_RAW_COST
                                 , OLD_TXN_BURDENED_COST
                                 , OLD_TXN_REVENUE
                                 , TXN_RAW_COST
                                 , TXN_BURDENED_COST
                                 , TXN_REVENUE
                                 , QUANTITY
                                 , DELETE_FLAG
                                 , PERIOD_NAME
                                 , CHANGE_REASON_CODE
                                 , DESCRIPTION
                                 , PM_PRODUCT_CODE
                                 , ATTRIBUTE_CATEGORY
                                 , ATTRIBUTE1
                                 , ATTRIBUTE2
                                 , ATTRIBUTE3
                                 , ATTRIBUTE4
                                 , ATTRIBUTE5
                                 , ATTRIBUTE6
                                 , ATTRIBUTE7
                                 , ATTRIBUTE8
                                 , ATTRIBUTE9
                                 , ATTRIBUTE10
                                 , ATTRIBUTE11
                                 , ATTRIBUTE12
                                 , ATTRIBUTE13
                                 , ATTRIBUTE14
                                 , ATTRIBUTE15
                                 , BUDGET_LINE_ID
                                 , RAW_COST_SOURCE
                                 , BURDENED_COST_SOURCE
                                 , QUANTITY_SOURCE
                                 , REVENUE_SOURCE
                                  )
                          VALUES (
                                   pa_fp_rollup_tmp_s.nextval
                                 , p_res_assignment_id_tbl(i)
                                 , p_parent_assignment_id_tbl(i)
                                 , p_start_date_tbl(i)
                                 , p_end_date_tbl(i)
                                 , p_txn_currency_code_tbl(i)
                                 , p_proj_currency_code_tbl(i)
                                 , p_pf_currency_code_tbl(i)
                                 , p_proj_cost_rate_type_tbl(i)
                                 , p_proj_cost_rt_dt_type_tbl(i)
                                 , p_proj_cost_exc_rate_tbl(i)
                                 , p_proj_cost_rate_date_tbl(i)
                                 , p_proj_rev_rate_type_tbl(i)
                                 , p_proj_rev_rt_dt_type_tbl(i)
                                 , p_proj_rev_exc_rate_tbl(i)
                                 , p_proj_rev_rate_date_tbl(i)
                                 , p_pf_cost_rate_type_tbl(i)
                                 , p_pf_cost_rt_dt_type_tbl(i)
                                 , p_pf_cost_exc_rate_tbl(i)
                                 , p_pf_cost_rate_date_tbl(i)
                                 , p_pf_rev_rate_type_tbl(i)
                                 , p_pf_rev_rt_dt_type_tbl(i)
                                 , p_pf_rev_exc_rate_tbl(i)
                                 , p_pf_rev_rate_date_tbl(i)
                                 , p_old_proj_raw_cost_tbl(i)
                                 , p_old_proj_burdened_cost_tbl(i)
                                 , p_old_proj_revenue_tbl(i)
                                 , p_old_pf_raw_cost_tbl(i)
                                 , p_old_pf_burdened_cost_tbl(i)
                                 , p_old_pf_revenue_tbl(i)
                                 , p_old_quantity_tbl(i)
                                 , p_old_txn_raw_cost_tbl(i)
                                 , p_old_txn_burdened_cost_tbl(i)
                                 , p_old_txn_revenue_tbl(i)
                                 , p_txn_raw_cost_tbl(i)
                                 , p_txn_burdened_cost_tbl(i)
                                 , p_txn_revenue_tbl(i)
                                 , p_quantity_tbl(i)
                                 , p_delete_flag_tbl(i)
                                 , p_period_name_tbl(i)
                                 , p_change_reason_code_tbl(i)
                                 , p_description_tbl(i)
                                 , p_pm_product_code_tbl(i)
                                 , p_attribute_category_tbl(i)
                                 , p_attribute1_tbl(i)
                                 , p_attribute2_tbl(i)
                                 , p_attribute3_tbl(i)
                                 , p_attribute4_tbl(i)
                                 , p_attribute5_tbl(i)
                                 , p_attribute6_tbl(i)
                                 , p_attribute7_tbl(i)
                                 , p_attribute8_tbl(i)
                                 , p_attribute9_tbl(i)
                                 , p_attribute10_tbl(i)
                                 , p_attribute11_tbl(i)
                                 , p_attribute12_tbl(i)
                                 , p_attribute13_tbl(i)
                                 , p_attribute14_tbl(i)
                                 , p_attribute15_tbl(i)
                                 , p_budget_line_id_tbl(i)
                                 , PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M
                                 , PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M
                                 , PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M
                                 , PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M
                                 );
     END IF;
     IF l_debug_mode = 'Y' THEN
         l_count := sql%rowcount;
         pa_debug.g_err_stage:= 'inserted records l_count = ' || l_count;
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Exiting POPULATE_IN_BULK';
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
         pa_debug.reset_err_stack;
     END IF;

EXCEPTION
   WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_WEBADI_PKG'
              ,p_procedure_name => 'POPULATE_IN_BULK' );
          IF l_debug_mode = 'Y' THEN
             pa_debug.write('POPULATE_IN_BULK' || g_module_name,SQLERRM,4);
             pa_debug.write('POPULATE_IN_BULK' || g_module_name,pa_debug.G_Err_Stack,4);
          END IF;

          pa_debug.reset_err_stack;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END POPULATE_IN_BULK ;

PROCEDURE POPULATE_IN_MATRIX
                   ( p_res_assignment_id            IN pa_resource_assignments.resource_assignment_id%TYPE
		         , p_parent_assignment_id         IN pa_resource_assignments.parent_assignment_id%TYPE
                   , p_txn_currency_code            IN pa_budget_lines.txn_currency_code%TYPE
                   , p_proj_currency_code           IN pa_budget_lines.project_currency_code%TYPE
                   , p_pf_currency_code             IN pa_budget_lines.projfunc_currency_code%TYPE
                   , p_proj_cost_rate_type          IN pa_budget_lines.project_cost_rate_type%TYPE
                   , p_proj_cost_rt_dt_type         IN pa_budget_lines.project_cost_rate_date_type%TYPE
                   , p_proj_cost_exc_rate           IN pa_budget_lines.project_cost_exchange_rate%TYPE
                   , p_proj_cost_rate_date          IN pa_budget_lines.project_cost_rate_date%TYPE
                   , p_proj_rev_rate_type           IN pa_budget_lines.project_rev_rate_type%TYPE
                   , p_proj_rev_rt_dt_type          IN pa_budget_lines.project_rev_rate_date_type%TYPE
                   , p_proj_rev_exc_rate            IN pa_budget_lines.project_rev_exchange_rate%TYPE
                   , p_proj_rev_rate_date           IN pa_budget_lines.project_rev_rate_date%TYPE
                   , p_pf_cost_rate_type            IN pa_budget_lines.projfunc_cost_rate_type%TYPE
                   , p_pf_cost_rt_dt_type           IN pa_budget_lines.projfunc_cost_rate_date_type%TYPE
                   , p_pf_cost_exc_rate             IN pa_budget_lines.projfunc_cost_exchange_rate%TYPE
                   , p_pf_cost_rate_date            IN pa_budget_lines.projfunc_cost_rate_date%TYPE
                   , p_pf_rev_rate_type             IN pa_budget_lines.projfunc_rev_rate_type%TYPE
                   , p_pf_rev_rt_dt_type            IN pa_budget_lines.projfunc_rev_rate_date_type%TYPE
                   , p_pf_rev_exc_rate              IN pa_budget_lines.projfunc_rev_exchange_rate%TYPE
                   , p_pf_rev_rate_date             IN pa_budget_lines.projfunc_rev_rate_date%TYPE
                   , p_delete_flag                  IN VARCHAR2
                   , p_change_reason_code           IN pa_budget_lines.change_reason_code%TYPE
                   , p_description                  IN pa_budget_lines.description%TYPE
                   , p_attribute_category           IN pa_budget_lines.attribute_category%TYPE
                   , p_attribute1                   IN pa_budget_lines.attribute1%TYPE
                   , p_attribute2                   IN pa_budget_lines.attribute2%TYPE
                   , p_attribute3                   IN pa_budget_lines.attribute3%TYPE
                   , p_attribute4                   IN pa_budget_lines.attribute4%TYPE
                   , p_attribute5                   IN pa_budget_lines.attribute5%TYPE
                   , p_attribute6                   IN pa_budget_lines.attribute6%TYPE
                   , p_attribute7                   IN pa_budget_lines.attribute7%TYPE
                   , p_attribute8                   IN pa_budget_lines.attribute8%TYPE
                   , p_attribute9                   IN pa_budget_lines.attribute9%TYPE
                   , p_attribute10                  IN pa_budget_lines.attribute10%TYPE
                   , p_attribute11                  IN pa_budget_lines.attribute11%TYPE
                   , p_attribute12                  IN pa_budget_lines.attribute12%TYPE
                   , p_attribute13                  IN pa_budget_lines.attribute13%TYPE
                   , p_attribute14                  IN pa_budget_lines.attribute14%TYPE
                   , p_attribute15                  IN pa_budget_lines.attribute15%TYPE
                   , p_raw_cost_source              IN pa_budget_lines.raw_cost_source%TYPE
                   , p_burdened_cost_source         IN pa_budget_lines.burdened_cost_source%TYPE
                   , p_quantity_source              IN pa_budget_lines.quantity_source%TYPE
                   , p_revenue_source               IN pa_budget_lines.revenue_source%TYPE
                   , p_start_date_tbl               IN pa_fp_webadi_pkg.l_start_date_tbl_typ
                   , p_end_date_tbl                 IN pa_fp_webadi_pkg.l_end_date_tbl_typ
                   , p_period_name_tbl              IN pa_fp_webadi_pkg.l_period_name_tbl_typ
                   , p_txn_raw_cost_tbl             IN pa_fp_webadi_pkg.l_amount_tbl_typ
                   , p_txn_burdened_cost_tbl        IN pa_fp_webadi_pkg.l_amount_tbl_typ
                   , p_txn_revenue_tbl              IN pa_fp_webadi_pkg.l_amount_tbl_typ
                   , p_quantity_tbl                 IN pa_fp_webadi_pkg.l_amount_tbl_typ
                   , p_bucketing_period_code_tbl    IN pa_fp_webadi_pkg.l_bucketing_pd_code_tbl_typ
                   , p_pm_product_code_tbl          IN pa_fp_webadi_pkg.l_pm_product_code_tbl_typ
                   , x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   , x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                   , x_msg_data                     OUT NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
IS
   l_debug_mode    VARCHAR2(1) ;
   l_msg_count     NUMBER := 0;
   l_data          VARCHAR2(2000);
   l_msg_data      VARCHAR2(2000);
   l_msg_index_out NUMBER;
   l_count         NUMBER;
BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    IF l_debug_mode = 'Y' THEN
       pa_debug.set_err_stack('PA_FP_ROLLUP_TMP_PKG.POPULATE_IN_MATRIX');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'in populate_in_matrix p_period_name_tbl.LAST = ' || p_period_name_tbl.LAST;
        pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF nvl(p_period_name_tbl.LAST,0) > 0 THEN

         FORALL i in p_period_name_tbl.FIRST..p_period_name_tbl.LAST

                       INSERT INTO PA_FP_ROLLUP_TMP(
                               ROLLUP_ID
                             , RESOURCE_ASSIGNMENT_ID
                             , PARENT_ASSIGNMENT_ID
                             , TXN_CURRENCY_CODE
                             , PROJECT_CURRENCY_CODE
                             , PROJFUNC_CURRENCY_CODE
                             , PROJECT_COST_RATE_TYPE
                             , PROJECT_COST_RATE_DATE_TYPE
                             , PROJECT_COST_EXCHANGE_RATE
                             , PROJECT_COST_RATE_DATE
                             , PROJECT_REV_RATE_TYPE
                             , PROJECT_REV_RATE_DATE_TYPE
                             , PROJECT_REV_EXCHANGE_RATE
                             , PROJECT_REV_RATE_DATE
                             , PROJFUNC_COST_RATE_TYPE
                             , PROJFUNC_COST_RATE_DATE_TYPE
                             , PROJFUNC_COST_EXCHANGE_RATE
                             , PROJFUNC_COST_RATE_DATE
                             , PROJFUNC_REV_RATE_TYPE
                             , PROJFUNC_REV_RATE_DATE_TYPE
                             , PROJFUNC_REV_EXCHANGE_RATE
                             , PROJFUNC_REV_RATE_DATE
                             , DELETE_FLAG
                             , CHANGE_REASON_CODE
                             , DESCRIPTION
                             , PM_PRODUCT_CODE
                             , ATTRIBUTE_CATEGORY
                             , ATTRIBUTE1
                             , ATTRIBUTE2
                             , ATTRIBUTE3
                             , ATTRIBUTE4
                             , ATTRIBUTE5
                             , ATTRIBUTE6
                             , ATTRIBUTE7
                             , ATTRIBUTE8
                             , ATTRIBUTE9
                             , ATTRIBUTE10
                             , ATTRIBUTE11
                             , ATTRIBUTE12
                             , ATTRIBUTE13
                             , ATTRIBUTE14
                             , ATTRIBUTE15
                             , RAW_COST_SOURCE
                             , BURDENED_COST_SOURCE
                             , QUANTITY_SOURCE
                             , REVENUE_SOURCE
                             , START_DATE
                             , END_DATE
                             , PERIOD_NAME
                             , TXN_RAW_COST
                             , TXN_BURDENED_COST
                             , TXN_REVENUE
                             , QUANTITY
                             , BUCKETING_PERIOD_CODE )
                        (SELECT
                               pa_fp_rollup_tmp_s.nextval
                             , p_res_assignment_id
                             , p_parent_assignment_id
                             , p_txn_currency_code
                             , p_proj_currency_code
                             , p_pf_currency_code
                             , p_proj_cost_rate_type
                             , p_proj_cost_rt_dt_type
                             , p_proj_cost_exc_rate
                             , p_proj_cost_rate_date
                             , p_proj_rev_rate_type
                             , p_proj_rev_rt_dt_type
                             , p_proj_rev_exc_rate
                             , p_proj_rev_rate_date
                             , p_pf_cost_rate_type
                             , p_pf_cost_rt_dt_type
                             , p_pf_cost_exc_rate
                             , p_pf_cost_rate_date
                             , p_pf_rev_rate_type
                             , p_pf_rev_rt_dt_type
                             , p_pf_rev_exc_rate
                             , p_pf_rev_rate_date
                             , p_delete_flag
                             , p_change_reason_code
                             , p_description
                             , p_pm_product_code_tbl(i)
                             , p_attribute_category
                             , p_attribute1
                             , p_attribute2
                             , p_attribute3
                             , p_attribute4
                             , p_attribute5
                             , p_attribute6
                             , p_attribute7
                             , p_attribute8
                             , p_attribute9
                             , p_attribute10
                             , p_attribute11
                             , p_attribute12
                             , p_attribute13
                             , p_attribute14
                             , p_attribute15
                             , p_raw_cost_source
                             , p_burdened_cost_source
                             , p_quantity_source
                             , p_revenue_source
                             , p_start_date_tbl(i)
                             , p_end_date_tbl(i)
                             , p_period_name_tbl(i)
                             , p_txn_raw_cost_tbl(i)
                             , p_txn_burdened_cost_tbl(i)
                             , p_txn_revenue_tbl(i)
                             , p_quantity_tbl(i)
                             , p_bucketing_period_code_tbl(i)
                         FROM  dual
                        WHERE  p_start_date_tbl(i) is not null );
    END IF;
     IF l_debug_mode = 'Y' THEN
         l_count := sql%rowcount;
         pa_debug.g_err_stage:= 'inserted records l_count = ' || l_count;
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:= 'Exiting POPULATE_IN_MATRIX';
         pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
         pa_debug.reset_err_stack;
     END IF;

EXCEPTION
   WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_ROLLUP_TMP_PKG'
              ,p_procedure_name => 'POPULATE_IN_MATRIX' );
          IF l_debug_mode = 'Y' THEN
             pa_debug.write('POPULATE_IN_MATRIX' || g_module_name,SQLERRM,4);
             pa_debug.write('POPULATE_IN_MATRIX' || g_module_name,pa_debug.G_Err_Stack,4);
          END IF;
          pa_debug.reset_err_stack;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END POPULATE_IN_MATRIX ;
END PA_FP_ROLLUP_TMP_PKG;

/
