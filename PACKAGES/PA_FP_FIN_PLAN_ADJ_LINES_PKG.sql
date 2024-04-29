--------------------------------------------------------
--  DDL for Package PA_FP_FIN_PLAN_ADJ_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_FIN_PLAN_ADJ_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPALTS.pls 120.1 2005/08/19 16:24:02 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_FIN_PLAN_ADJ_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row
(px_fin_plan_adj_line_id IN OUT NOCOPY pa_fin_plan_adj_lines.fin_plan_adj_line_id%TYPE --File.Sql.39 bug 4440895
 ,p_adj_element_id           IN pa_fin_plan_adj_lines.adj_element_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_project_id               IN pa_fin_plan_adj_lines.project_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_task_id                  IN pa_fin_plan_adj_lines.task_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_budget_version_id        IN pa_fin_plan_adj_lines.budget_version_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_resource_assignment_id   IN
                             pa_fin_plan_adj_lines.resource_assignment_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_period_name              IN
                             pa_fin_plan_adj_lines.period_name%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_start_date               IN pa_fin_plan_adj_lines.start_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_end_date                 IN pa_fin_plan_adj_lines.end_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_raw_cost_adjustment      IN pa_fin_plan_adj_lines.raw_cost_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_burdened_cost_adjustment IN
                             pa_fin_plan_adj_lines.burdened_cost_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue_adjustment       IN pa_fin_plan_adj_lines.revenue_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_adjustment   IN
                             pa_fin_plan_adj_lines.utilization_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count_adjustment    IN pa_fin_plan_adj_lines.head_count_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,x_row_id                   OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
( p_fin_plan_adj_line_id     IN pa_fin_plan_adj_lines.fin_plan_adj_line_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_adj_element_id           IN pa_fin_plan_adj_lines.adj_element_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_project_id               IN pa_fin_plan_adj_lines.project_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_task_id                  IN pa_fin_plan_adj_lines.task_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_budget_version_id        IN pa_fin_plan_adj_lines.budget_version_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_resource_assignment_id   IN
                             pa_fin_plan_adj_lines.resource_assignment_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_period_name              IN
                             pa_fin_plan_adj_lines.period_name%TYPE
                                := FND_API.G_MISS_CHAR
 ,p_start_date               IN pa_fin_plan_adj_lines.start_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_end_date                 IN pa_fin_plan_adj_lines.end_date%TYPE
                                := FND_API.G_MISS_DATE
 ,p_raw_cost_adjustment      IN pa_fin_plan_adj_lines.raw_cost_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_burdened_cost_adjustment IN
                             pa_fin_plan_adj_lines.burdened_cost_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_revenue_adjustment       IN pa_fin_plan_adj_lines.revenue_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_utilization_adjustment   IN
                             pa_fin_plan_adj_lines.utilization_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_head_count_adjustment    IN pa_fin_plan_adj_lines.head_count_adjustment%TYPE
                                := FND_API.G_MISS_NUM
 ,p_row_id                   IN ROWID
                                := NULL
 ,x_return_status            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Lock_Row
( p_fin_plan_adj_line_id     IN pa_fin_plan_adj_lines.fin_plan_adj_line_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_row_id                   IN ROWID
                                := NULL
 ,x_return_status            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_fin_plan_adj_line_id          IN pa_fin_plan_adj_lines.fin_plan_adj_line_id%TYPE
 ,p_row_id                   IN ROWID
                                := NULL
 ,x_return_status            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
END pa_fp_fin_plan_adj_lines_pkg;
 

/
