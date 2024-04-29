--------------------------------------------------------
--  DDL for Package PA_FP_RESOURCE_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_RESOURCE_ASSIGNMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPRATS.pls 120.1 2005/08/19 16:29:20 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_RESOURCE_ASSIGNMENTS_PKG
-- Purpose          :
-- History          :
-- 31-OCT-02       rravipat   Modified the insert row and update row
--                            apis to include newly added columns
--                            for Bug:- 2634900
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row
( px_resource_assignment_id IN OUT NOCOPY pa_resource_assignments.resource_assignment_id%TYPE  --File.Sql.39 bug 4440895
 ,p_budget_version_id           IN pa_resource_assignments.budget_version_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_project_id                  IN pa_resource_assignments.project_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_task_id                     IN pa_resource_assignments.task_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_resource_list_member_id     IN pa_resource_assignments.resource_list_member_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_unit_of_measure             IN pa_resource_assignments.unit_of_measure%TYPE
                                   := FND_API.G_MISS_CHAR
 ,p_track_as_labor_flag         IN pa_resource_assignments.track_as_labor_flag%TYPE
                                   := FND_API.G_MISS_CHAR
 ,p_standard_bill_rate          IN pa_resource_assignments.standard_bill_rate%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_average_bill_rate           IN pa_resource_assignments.average_bill_rate%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_average_cost_rate           IN pa_resource_assignments.average_cost_rate%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_project_assignment_id       IN pa_resource_assignments.project_assignment_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_plan_error_code             IN pa_resource_assignments.plan_error_code%TYPE
                                   := FND_API.G_MISS_CHAR
 ,p_total_plan_revenue          IN pa_resource_assignments.total_plan_revenue%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_plan_raw_cost         IN pa_resource_assignments.total_plan_raw_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_plan_burdened_cost    IN pa_resource_assignments.total_plan_burdened_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_plan_quantity         IN pa_resource_assignments.total_plan_quantity%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_average_discount_percentage IN pa_resource_assignments.average_discount_percentage%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_borrowed_revenue      IN pa_resource_assignments.total_borrowed_revenue%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_tp_revenue_in         IN pa_resource_assignments.total_tp_revenue_in%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_tp_revenue_out        IN pa_resource_assignments.total_tp_revenue_out%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_revenue_adj           IN pa_resource_assignments.total_revenue_adj%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_lent_resource_cost    IN pa_resource_assignments.total_lent_resource_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_tp_cost_in            IN pa_resource_assignments.total_tp_cost_in%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_tp_cost_out           IN pa_resource_assignments.total_tp_cost_out%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_cost_adj              IN pa_resource_assignments.total_cost_adj%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_unassigned_time_cost  IN pa_resource_assignments.total_unassigned_time_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_utilization_percent   IN pa_resource_assignments.total_utilization_percent%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_utilization_hours     IN pa_resource_assignments.total_utilization_hours%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_utilization_adj       IN pa_resource_assignments.total_utilization_adj%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_capacity              IN pa_resource_assignments.total_capacity%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_head_count            IN pa_resource_assignments.total_head_count%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_head_count_adj        IN pa_resource_assignments.total_head_count_adj%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_resource_assignment_type    IN pa_resource_assignments.resource_assignment_type%TYPE
                                   := FND_API.G_MISS_CHAR
 -- start of changes of Bug:- 2634900
 ,p_total_project_raw_cost      IN pa_resource_assignments.total_project_raw_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_project_burdened_cost IN pa_resource_assignments.total_project_burdened_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_project_revenue       IN pa_resource_assignments.total_project_revenue%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_parent_assignment_id        IN pa_resource_assignments.parent_assignment_id%TYPE
                                   := FND_API.G_MISS_NUM
 -- end of changes of Bug :- 2634900
 ,x_row_id                      OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
( p_resource_assignment_id      IN pa_resource_assignments.resource_assignment_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_budget_version_id           IN pa_resource_assignments.budget_version_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_project_id                  IN pa_resource_assignments.project_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_task_id                     IN pa_resource_assignments.task_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_resource_list_member_id     IN pa_resource_assignments.resource_list_member_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_unit_of_measure             IN pa_resource_assignments.unit_of_measure%TYPE
                                   := FND_API.G_MISS_CHAR
 ,p_track_as_labor_flag         IN pa_resource_assignments.track_as_labor_flag%TYPE
                                   := FND_API.G_MISS_CHAR
 ,p_standard_bill_rate          IN pa_resource_assignments.standard_bill_rate%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_average_bill_rate           IN pa_resource_assignments.average_bill_rate%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_average_cost_rate           IN pa_resource_assignments.average_cost_rate%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_project_assignment_id       IN pa_resource_assignments.project_assignment_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_plan_error_code             IN pa_resource_assignments.plan_error_code%TYPE
                                   := FND_API.G_MISS_CHAR
 ,p_total_plan_revenue          IN pa_resource_assignments.total_plan_revenue%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_plan_raw_cost         IN pa_resource_assignments.total_plan_raw_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_plan_burdened_cost    IN pa_resource_assignments.total_plan_burdened_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_plan_quantity         IN pa_resource_assignments.total_plan_quantity%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_average_discount_percentage IN pa_resource_assignments.average_discount_percentage%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_borrowed_revenue      IN pa_resource_assignments.total_borrowed_revenue%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_tp_revenue_in         IN pa_resource_assignments.total_tp_revenue_in%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_tp_revenue_out        IN pa_resource_assignments.total_tp_revenue_out%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_revenue_adj           IN pa_resource_assignments.total_revenue_adj%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_lent_resource_cost    IN pa_resource_assignments.total_lent_resource_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_tp_cost_in            IN pa_resource_assignments.total_tp_cost_in%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_tp_cost_out           IN pa_resource_assignments.total_tp_cost_out%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_cost_adj              IN pa_resource_assignments.total_cost_adj%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_unassigned_time_cost  IN pa_resource_assignments.total_unassigned_time_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_utilization_percent   IN pa_resource_assignments.total_utilization_percent%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_utilization_hours     IN pa_resource_assignments.total_utilization_hours%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_utilization_adj       IN pa_resource_assignments.total_utilization_adj%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_capacity              IN pa_resource_assignments.total_capacity%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_head_count            IN pa_resource_assignments.total_head_count%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_head_count_adj        IN pa_resource_assignments.total_head_count_adj%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_resource_assignment_type    IN pa_resource_assignments.resource_assignment_type%TYPE
                                   := FND_API.G_MISS_CHAR
-- start of changes of Bug:- 2634900
 ,p_total_project_raw_cost      IN pa_resource_assignments.total_project_raw_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_project_burdened_cost IN pa_resource_assignments.total_project_burdened_cost%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_total_project_revenue       IN pa_resource_assignments.total_project_revenue%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_parent_assignment_id        IN pa_resource_assignments.parent_assignment_id%TYPE
                                   := FND_API.G_MISS_NUM
-- end of changes of Bug:- 2634900
 ,p_row_id                      IN ROWID
                                   := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Lock_Row
( p_resource_assignment_id      IN pa_resource_assignments.resource_assignment_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_row_id                      IN ROWID
                                   := NULL
 ,x_return_status              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_resource_assignment_id      IN pa_resource_assignments.resource_assignment_id%TYPE
                                   := FND_API.G_MISS_NUM
 ,p_row_id                      IN ROWID
                                   := NULL
 ,x_return_status              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_fp_resource_assignments_pkg;
 

/
