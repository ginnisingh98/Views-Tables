--------------------------------------------------------
--  DDL for Package PA_FP_ROLLUP_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_ROLLUP_TMP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPRLTS.pls 120.1 2005/08/19 16:29:53 mwasowic noship $*/
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
                    , x_msg_data                     OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

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
                   , x_msg_data                     OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

END PA_FP_ROLLUP_TMP_PKG;
 

/
