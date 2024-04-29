--------------------------------------------------------
--  DDL for Package PA_FP_ORG_FORECAST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_ORG_FORECAST_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPFLTS.pls 120.1 2005/08/19 16:26:45 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_ORG_FORECAST_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row
( px_forecast_line_id     IN OUT NOCOPY pa_org_forecast_lines.forecast_line_id%TYPE  --File.Sql.39 bug 4440895
 ,p_forecast_element_id   IN pa_org_forecast_lines.forecast_element_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_budget_version_id     IN pa_org_forecast_lines.budget_version_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_project_id            IN pa_org_forecast_lines.project_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_task_id               IN pa_org_forecast_lines.task_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_period_name           IN pa_org_forecast_lines.period_name%TYPE
                             := FND_API.G_MISS_CHAR
 ,p_start_date            IN pa_org_forecast_lines.start_date%TYPE
                             := FND_API.G_MISS_DATE
 ,p_end_date              IN pa_org_forecast_lines.end_date%TYPE
                             := FND_API.G_MISS_DATE
 ,p_quantity              IN pa_org_forecast_lines.quantity%TYPE
                             := FND_API.G_MISS_NUM
 ,p_raw_cost              IN pa_org_forecast_lines.raw_cost%TYPE
                             := FND_API.G_MISS_NUM
 ,p_burdened_cost         IN pa_org_forecast_lines.burdened_cost%TYPE
                             := FND_API.G_MISS_NUM
 ,p_tp_cost_in            IN pa_org_forecast_lines.tp_cost_in%TYPE
                             := FND_API.G_MISS_NUM
 ,p_tp_cost_out           IN pa_org_forecast_lines.tp_cost_out%TYPE
                             := FND_API.G_MISS_NUM
 ,p_revenue               IN pa_org_forecast_lines.revenue%TYPE
                             := FND_API.G_MISS_NUM
 ,p_tp_revenue_in         IN pa_org_forecast_lines.tp_revenue_in%TYPE
                             := FND_API.G_MISS_NUM
 ,p_tp_revenue_out        IN pa_org_forecast_lines.tp_revenue_out%TYPE
                             := FND_API.G_MISS_NUM
 ,p_borrowed_revenue      IN pa_org_forecast_lines.borrowed_revenue%TYPE
                             := FND_API.G_MISS_NUM
 ,p_lent_resource_cost    IN pa_org_forecast_lines.lent_resource_cost%TYPE
                             := FND_API.G_MISS_NUM
 ,p_unassigned_time_cost  IN pa_org_forecast_lines.unassigned_time_cost%TYPE
                             := FND_API.G_MISS_NUM
 ,x_row_id               OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
( p_forecast_line_id      IN pa_org_forecast_lines.forecast_line_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_record_version_number IN NUMBER
                             := NULL
 ,p_forecast_element_id   IN pa_org_forecast_lines.forecast_element_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_budget_version_id     IN pa_org_forecast_lines.budget_version_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_project_id            IN pa_org_forecast_lines.project_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_task_id               IN pa_org_forecast_lines.task_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_period_name           IN pa_org_forecast_lines.period_name%TYPE
                             := FND_API.G_MISS_CHAR
 ,p_start_date            IN pa_org_forecast_lines.start_date%TYPE
                             := FND_API.G_MISS_DATE
 ,p_end_date              IN pa_org_forecast_lines.end_date%TYPE
                             := FND_API.G_MISS_DATE
 ,p_quantity              IN pa_org_forecast_lines.quantity%TYPE
                             := FND_API.G_MISS_NUM
 ,p_raw_cost              IN pa_org_forecast_lines.raw_cost%TYPE
                             := FND_API.G_MISS_NUM
 ,p_burdened_cost         IN pa_org_forecast_lines.burdened_cost%TYPE
                             := FND_API.G_MISS_NUM
 ,p_tp_cost_in            IN pa_org_forecast_lines.tp_cost_in%TYPE
                             := FND_API.G_MISS_NUM
 ,p_tp_cost_out           IN pa_org_forecast_lines.tp_cost_out%TYPE
                             := FND_API.G_MISS_NUM
 ,p_revenue               IN pa_org_forecast_lines.revenue%TYPE
                             := FND_API.G_MISS_NUM
 ,p_tp_revenue_in         IN pa_org_forecast_lines.tp_revenue_in%TYPE
                             := FND_API.G_MISS_NUM
 ,p_tp_revenue_out        IN pa_org_forecast_lines.tp_revenue_out%TYPE
                             := FND_API.G_MISS_NUM
 ,p_borrowed_revenue      IN pa_org_forecast_lines.borrowed_revenue%TYPE
                             := FND_API.G_MISS_NUM
 ,p_lent_resource_cost    IN pa_org_forecast_lines.lent_resource_cost%TYPE
                             := FND_API.G_MISS_NUM
 ,p_unassigned_time_cost  IN pa_org_forecast_lines.unassigned_time_cost%TYPE
                             := FND_API.G_MISS_NUM
 ,p_row_id                IN ROWID
                             := NULL
 ,x_return_status        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Lock_Row
( p_forecast_line_id      IN pa_org_forecast_lines.forecast_line_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_record_version_number IN NUMBER
                             := NULL
 ,p_row_id                IN ROWID
                             := NULL
 ,x_return_status        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_forecast_line_id      IN pa_org_forecast_lines.forecast_line_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_record_version_number IN NUMBER
                             := NULL
 ,p_row_id                IN ROWID
                             := NULL
 ,x_return_status        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
END pa_fp_org_forecast_lines_pkg;
 

/
