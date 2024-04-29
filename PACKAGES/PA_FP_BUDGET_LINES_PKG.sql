--------------------------------------------------------
--  DDL for Package PA_FP_BUDGET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_BUDGET_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPBLTS.pls 120.2 2005/09/23 14:53:09 rnamburi noship $ */
-- Start of Comments
-- Package name     : PA_FP_BUDGET_LINES_PKG
-- Purpose          :
-- History          :
-- 26-OCT-2002 Vejayara  Included columns to be in table for FP.K
-- 05-DEC-2002 Rravipat  Added new column p_mrc_flag to insert_row
-- 10-DEC-2002           Added new column p_mrc_flag to update_row
--                       Modified Delte_row signature for B4 changes
--
--  23-SEP-2005 Ram Namburi
--                       Bug Fix: 4569365. Removed MRC code.
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row
( p_resource_assignment_id   IN pa_budget_lines.resource_assignment_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_start_date               IN pa_budget_lines.start_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_end_date                 IN pa_budget_lines.end_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_period_name              IN pa_budget_lines.period_name%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_quantity                 IN pa_budget_lines.quantity%TYPE
                                := FND_API.G_MISS_NUM
 ,p_raw_cost                 IN pa_budget_lines.raw_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_burdened_cost            IN pa_budget_lines.burdened_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue                  IN pa_budget_lines.revenue%TYPE
                                := FND_API.G_MISS_NUM
 ,p_change_reason_code       IN pa_budget_lines.change_reason_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_description              IN pa_budget_lines.description%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute_category       IN pa_budget_lines.attribute_category%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute1               IN pa_budget_lines.attribute1%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute2               IN pa_budget_lines.attribute2%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute3               IN pa_budget_lines.attribute3%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute4               IN pa_budget_lines.attribute4%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute5               IN pa_budget_lines.attribute5%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute6               IN pa_budget_lines.attribute6%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute7               IN pa_budget_lines.attribute7%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute8               IN pa_budget_lines.attribute8%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute9               IN pa_budget_lines.attribute9%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute10              IN pa_budget_lines.attribute10%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute11              IN pa_budget_lines.attribute11%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute12              IN pa_budget_lines.attribute12%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute13              IN pa_budget_lines.attribute13%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute14              IN pa_budget_lines.attribute14%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute15              IN pa_budget_lines.attribute15%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_raw_cost_source          IN pa_budget_lines.raw_cost_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_burdened_cost_source     IN pa_budget_lines.burdened_cost_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_quantity_source          IN pa_budget_lines.quantity_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_revenue_source           IN pa_budget_lines.revenue_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_pm_product_code          IN pa_budget_lines.pm_product_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_pm_budget_line_reference IN pa_budget_lines.pm_budget_line_reference%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_cost_rejection_code      IN pa_budget_lines.cost_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_revenue_rejection_code   IN pa_budget_lines.revenue_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_burden_rejection_code    IN pa_budget_lines.burden_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_other_rejection_code     IN pa_budget_lines.other_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_code_combination_id      IN pa_budget_lines.code_combination_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_ccid_gen_status_code     IN pa_budget_lines.ccid_gen_status_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_ccid_gen_rej_message     IN pa_budget_lines.ccid_gen_rej_message%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_request_id               IN pa_budget_lines.request_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_borrowed_revenue         IN pa_budget_lines.borrowed_revenue%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_revenue_in            IN pa_budget_lines.tp_revenue_in%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_revenue_out           IN pa_budget_lines.tp_revenue_out%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue_adj              IN pa_budget_lines.revenue_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_lent_resource_cost       IN pa_budget_lines.lent_resource_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_cost_in               IN pa_budget_lines.tp_cost_in%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_cost_out              IN pa_budget_lines.tp_cost_out%TYPE
                                := FND_API.G_MISS_NUM
 ,p_cost_adj                 IN pa_budget_lines.cost_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_unassigned_time_cost     IN pa_budget_lines.unassigned_time_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_percent      IN pa_budget_lines.utilization_percent%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_hours        IN pa_budget_lines.utilization_hours%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_adj          IN pa_budget_lines.utilization_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_capacity                 IN pa_budget_lines.capacity%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count               IN pa_budget_lines.head_count%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count_adj           IN pa_budget_lines.head_count_adj%TYPE
                                := FND_API.G_MISS_NUM,
p_projfunc_currency_code        in pa_budget_lines.projfunc_currency_code%type       := FND_API.G_MISS_CHAR,
p_projfunc_cost_rate_type       in pa_budget_lines.projfunc_cost_rate_type%type      := FND_API.G_MISS_CHAR,
p_projfunc_cost_exchange_rate   in pa_budget_lines.projfunc_cost_exchange_rate%type  := FND_API.G_MISS_NUM,
p_projfunc_cost_rate_date_type  in pa_budget_lines.projfunc_cost_rate_date_type%type := FND_API.G_MISS_CHAR,
p_projfunc_cost_rate_date       in pa_budget_lines.projfunc_cost_rate_date%type      := FND_API.G_MISS_DATE,
p_projfunc_rev_rate_type        in pa_budget_lines.projfunc_rev_rate_type%type       := FND_API.G_MISS_CHAR,
p_projfunc_rev_rate_date_type   in pa_budget_lines.projfunc_rev_rate_date_type%type  := FND_API.G_MISS_CHAR,
p_projfunc_rev_exchange_rate    in pa_budget_lines.projfunc_rev_exchange_rate%type   := FND_API.G_MISS_NUM,
p_projfunc_rev_rate_date        in pa_budget_lines.projfunc_rev_rate_date%type       := FND_API.G_MISS_DATE,
p_project_currency_code         in pa_budget_lines.project_currency_code%type        := FND_API.G_MISS_CHAR,
p_project_cost_rate_type        in pa_budget_lines.project_cost_rate_type%type       := FND_API.G_MISS_CHAR,
p_project_cost_exchange_rate    in pa_budget_lines.project_cost_exchange_rate%type   := FND_API.G_MISS_NUM,
p_project_cost_rate_date_type   in pa_budget_lines.project_cost_rate_date_type%type  := FND_API.G_MISS_CHAR,
p_project_cost_rate_date        in pa_budget_lines.project_cost_rate_date%type       := FND_API.G_MISS_DATE,
p_project_raw_cost              in pa_budget_lines.project_raw_cost%type             := FND_API.G_MISS_NUM,
p_project_burdened_cost         in pa_budget_lines.project_burdened_cost%type        := FND_API.G_MISS_NUM,
p_project_revenue               in pa_budget_lines.project_revenue%type              := FND_API.G_MISS_NUM,
p_txn_raw_cost                  in pa_budget_lines.txn_raw_cost%type                 := FND_API.G_MISS_NUM,
p_txn_burdened_cost             in pa_budget_lines.txn_burdened_cost%type            := FND_API.G_MISS_NUM,
p_txn_revenue                   in pa_budget_lines.txn_revenue%type                  := FND_API.G_MISS_NUM,
p_txn_currency_code             in pa_budget_lines.txn_currency_code%type            := FND_API.G_MISS_CHAR,
p_bucketing_period_code         in pa_budget_lines.bucketing_period_code%type        := FND_API.G_MISS_CHAR,
p_project_rev_rate_type         in pa_budget_lines.project_rev_rate_type%type        := FND_API.G_MISS_CHAR,
p_project_rev_exchange_rate     in pa_budget_lines.project_rev_exchange_rate%type    := FND_API.G_MISS_NUM,
p_project_rev_rate_date_type    in pa_budget_lines.project_rev_rate_date_type%type   := FND_API.G_MISS_CHAR,
p_project_rev_rate_date         in pa_budget_lines.project_rev_rate_date%type        := FND_API.G_MISS_DATE,
px_budget_line_id           in out NOCOPY pa_budget_lines.budget_line_id%type, --File.Sql.39 bug 4440895
p_budget_version_id             in pa_budget_lines.budget_version_id%type            := FND_API.G_MISS_NUM,
-- Bug Fix: 4569365. Removed MRC code.
-- p_mrc_flag                      in  VARCHAR2  DEFAULT 'N'
  x_row_id                  OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
( p_resource_assignment_id   IN pa_budget_lines.resource_assignment_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_start_date               IN pa_budget_lines.start_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_end_date                 IN pa_budget_lines.end_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_period_name              IN pa_budget_lines.period_name%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_quantity                 IN pa_budget_lines.quantity%TYPE
                                := FND_API.G_MISS_NUM
 ,p_raw_cost                 IN pa_budget_lines.raw_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_burdened_cost            IN pa_budget_lines.burdened_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue                  IN pa_budget_lines.revenue%TYPE
                                := FND_API.G_MISS_NUM
 ,p_change_reason_code       IN pa_budget_lines.change_reason_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_description              IN pa_budget_lines.description%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute_category       IN pa_budget_lines.attribute_category%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute1               IN pa_budget_lines.attribute1%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute2               IN pa_budget_lines.attribute2%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute3               IN pa_budget_lines.attribute3%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute4               IN pa_budget_lines.attribute4%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute5               IN pa_budget_lines.attribute5%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute6               IN pa_budget_lines.attribute6%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute7               IN pa_budget_lines.attribute7%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute8               IN pa_budget_lines.attribute8%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute9               IN pa_budget_lines.attribute9%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute10              IN pa_budget_lines.attribute10%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute11              IN pa_budget_lines.attribute11%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute12              IN pa_budget_lines.attribute12%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute13              IN pa_budget_lines.attribute13%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute14              IN pa_budget_lines.attribute14%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_attribute15              IN pa_budget_lines.attribute15%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_raw_cost_source          IN pa_budget_lines.raw_cost_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_burdened_cost_source     IN pa_budget_lines.burdened_cost_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_quantity_source          IN pa_budget_lines.quantity_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_revenue_source           IN pa_budget_lines.revenue_source%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_pm_product_code          IN pa_budget_lines.pm_product_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_pm_budget_line_reference IN pa_budget_lines.pm_budget_line_reference%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_cost_rejection_code      IN pa_budget_lines.cost_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_revenue_rejection_code   IN pa_budget_lines.revenue_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_burden_rejection_code    IN pa_budget_lines.burden_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_other_rejection_code     IN pa_budget_lines.other_rejection_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_code_combination_id      IN pa_budget_lines.code_combination_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_ccid_gen_status_code     IN pa_budget_lines.ccid_gen_status_code%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_ccid_gen_rej_message     IN pa_budget_lines.ccid_gen_rej_message%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_request_id               IN pa_budget_lines.request_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_borrowed_revenue         IN pa_budget_lines.borrowed_revenue%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_revenue_in            IN pa_budget_lines.tp_revenue_in%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_revenue_out           IN pa_budget_lines.tp_revenue_out%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue_adj              IN pa_budget_lines.revenue_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_lent_resource_cost       IN pa_budget_lines.lent_resource_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_cost_in               IN pa_budget_lines.tp_cost_in%TYPE
                                := FND_API.G_MISS_NUM
 ,p_tp_cost_out              IN pa_budget_lines.tp_cost_out%TYPE
                                := FND_API.G_MISS_NUM
 ,p_cost_adj                 IN pa_budget_lines.cost_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_unassigned_time_cost     IN pa_budget_lines.unassigned_time_cost%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_percent      IN pa_budget_lines.utilization_percent%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_hours        IN pa_budget_lines.utilization_hours%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_adj          IN pa_budget_lines.utilization_adj%TYPE
                                := FND_API.G_MISS_NUM
 ,p_capacity                 IN pa_budget_lines.capacity%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count               IN pa_budget_lines.head_count%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count_adj           IN pa_budget_lines.head_count_adj%TYPE
                                := FND_API.G_MISS_NUM,
p_projfunc_currency_code        in pa_budget_lines.projfunc_currency_code%type       := FND_API.G_MISS_CHAR,
p_projfunc_cost_rate_type       in pa_budget_lines.projfunc_cost_rate_type%type      := FND_API.G_MISS_CHAR,
p_projfunc_cost_exchange_rate   in pa_budget_lines.projfunc_cost_exchange_rate%type  := FND_API.G_MISS_NUM,
p_projfunc_cost_rate_date_type  in pa_budget_lines.projfunc_cost_rate_date_type%type := FND_API.G_MISS_CHAR,
p_projfunc_cost_rate_date       in pa_budget_lines.projfunc_cost_rate_date%type      := FND_API.G_MISS_DATE,
p_projfunc_rev_rate_type        in pa_budget_lines.projfunc_rev_rate_type%type       := FND_API.G_MISS_CHAR,
p_projfunc_rev_rate_date_type   in pa_budget_lines.projfunc_rev_rate_date_type%type  := FND_API.G_MISS_CHAR,
p_projfunc_rev_exchange_rate    in pa_budget_lines.projfunc_rev_exchange_rate%type   := FND_API.G_MISS_NUM,
p_projfunc_rev_rate_date        in pa_budget_lines.projfunc_rev_rate_date%type       := FND_API.G_MISS_DATE,
p_project_currency_code         in pa_budget_lines.project_currency_code%type        := FND_API.G_MISS_CHAR,
p_project_cost_rate_type        in pa_budget_lines.project_cost_rate_type%type       := FND_API.G_MISS_CHAR,
p_project_cost_exchange_rate    in pa_budget_lines.project_cost_exchange_rate%type   := FND_API.G_MISS_NUM,
p_project_cost_rate_date_type   in pa_budget_lines.project_cost_rate_date_type%type  := FND_API.G_MISS_CHAR,
p_project_cost_rate_date        in pa_budget_lines.project_cost_rate_date%type       := FND_API.G_MISS_DATE,
p_project_raw_cost              in pa_budget_lines.project_raw_cost%type             := FND_API.G_MISS_NUM,
p_project_burdened_cost         in pa_budget_lines.project_burdened_cost%type        := FND_API.G_MISS_NUM,
p_project_revenue               in pa_budget_lines.project_revenue%type              := FND_API.G_MISS_NUM,
p_txn_raw_cost                  in pa_budget_lines.txn_raw_cost%type                 := FND_API.G_MISS_NUM,
p_txn_burdened_cost             in pa_budget_lines.txn_burdened_cost%type            := FND_API.G_MISS_NUM,
p_txn_revenue                   in pa_budget_lines.txn_revenue%type                  := FND_API.G_MISS_NUM,
p_txn_currency_code             in pa_budget_lines.txn_currency_code%type            := FND_API.G_MISS_CHAR,
p_bucketing_period_code         in pa_budget_lines.bucketing_period_code%type        := FND_API.G_MISS_CHAR,
p_project_rev_rate_type         in pa_budget_lines.project_rev_rate_type%type        := FND_API.G_MISS_CHAR,
p_project_rev_exchange_rate     in pa_budget_lines.project_rev_exchange_rate%type    := FND_API.G_MISS_NUM,
p_project_rev_rate_date_type    in pa_budget_lines.project_rev_rate_date_type%type   := FND_API.G_MISS_CHAR,
p_project_rev_rate_date         in pa_budget_lines.project_rev_rate_date%type        := FND_API.G_MISS_DATE,
p_budget_line_id                in pa_budget_lines.budget_line_id%type               := FND_API.G_MISS_NUM,
p_budget_version_id             in pa_budget_lines.budget_version_id%type            := FND_API.G_MISS_NUM,
-- Bug Fix: 4569365. Removed MRC code.
-- p_mrc_flag                      in  VARCHAR2  DEFAULT 'N'
  p_row_id                   IN ROWID
                                := NULL
 ,x_return_status           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Lock_Row
( p_resource_assignment_id   IN pa_budget_lines.resource_assignment_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_start_date               IN pa_budget_lines.start_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_row_id                   IN ROWID
                                := NULL
 ,x_return_status           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_budget_line_id        IN   pa_budget_lines.budget_line_id%TYPE := NULL
 ,p_row_id                IN   ROWID   := NULL
 -- Bug Fix: 4569365. Removed MRC code.
 -- ,p_mrc_flag              IN   VARCHAR2  DEFAULT 'N'
 ,x_return_status         OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_fp_budget_lines_pkg;
 

/
