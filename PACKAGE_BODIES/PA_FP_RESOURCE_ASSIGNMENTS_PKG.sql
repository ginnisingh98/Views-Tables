--------------------------------------------------------
--  DDL for Package Body PA_FP_RESOURCE_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_RESOURCE_ASSIGNMENTS_PKG" as
/* $Header: PAFPRATB.pls 120.1 2005/08/19 16:29:15 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_RESOURCE_ASSIGNMENTS_PKG
-- Purpose          :
-- History          :
-- 31-OCT-02       rravipat   Modified the insert row and update row
--                            apis to include newly added columns for
--                            Bug :- 2634900
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_FP_RESOURCE_ASSIGNMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pafpratb.pls';

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
-- end of changes of Bug:- 2634900
 ,x_row_id                      OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
   CURSOR C2 IS SELECT pa_resource_assignments_s.nextval FROM sys.dual;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (px_resource_assignment_id IS NULL) OR
      (px_resource_assignment_id = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_resource_assignment_id;
       CLOSE C2;
   END IF;

   INSERT INTO pa_resource_assignments(
    resource_assignment_id
   ,budget_version_id
   ,project_id
   ,task_id
   ,resource_list_member_id
   ,last_update_date
   ,last_updated_by
   ,creation_date
   ,created_by
   ,last_update_login
   ,unit_of_measure
   ,track_as_labor_flag
   ,standard_bill_rate
   ,average_bill_rate
   ,average_cost_rate
   ,project_assignment_id
   ,plan_error_code
   ,total_plan_revenue
   ,total_plan_raw_cost
   ,total_plan_burdened_cost
   ,total_plan_quantity
   ,average_discount_percentage
   ,total_borrowed_revenue
   ,total_tp_revenue_in
   ,total_tp_revenue_out
   ,total_revenue_adj
   ,total_lent_resource_cost
   ,total_tp_cost_in
   ,total_tp_cost_out
   ,total_cost_adj
   ,total_unassigned_time_cost
   ,total_utilization_percent
   ,total_utilization_hours
   ,total_utilization_adj
   ,total_capacity
   ,total_head_count
   ,total_head_count_adj
   ,resource_assignment_type
-- start of changes of Bug:- 2634900
   ,total_project_raw_cost
   ,total_project_burdened_cost
   ,total_project_revenue
   ,parent_assignment_id
-- end of changes of Bug:- 2634900
   ) values (
    px_resource_assignment_id
   ,DECODE( p_budget_version_id, FND_API.G_MISS_NUM, NULL, p_budget_version_id)
   ,DECODE( p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id)
   ,DECODE( p_task_id, FND_API.G_MISS_NUM, NULL, p_task_id)
   ,DECODE( p_resource_list_member_id, FND_API.G_MISS_NUM, NULL,
            p_resource_list_member_id)
   ,sysdate
   ,fnd_global.user_id
   ,sysdate
   ,fnd_global.user_id
   ,fnd_global.login_id
   ,DECODE( p_unit_of_measure, FND_API.G_MISS_CHAR, NULL, p_unit_of_measure)
   ,DECODE( p_track_as_labor_flag, FND_API.G_MISS_CHAR, NULL,
            p_track_as_labor_flag)
   ,DECODE( p_standard_bill_rate, FND_API.G_MISS_NUM, NULL,
            p_standard_bill_rate)
   ,DECODE( p_average_bill_rate, FND_API.G_MISS_NUM, NULL, p_average_bill_rate)
   ,DECODE( p_average_cost_rate, FND_API.G_MISS_NUM, NULL, p_average_cost_rate)
   ,DECODE( p_project_assignment_id, FND_API.G_MISS_NUM, NULL,
            p_project_assignment_id)
   ,DECODE( p_plan_error_code, FND_API.G_MISS_CHAR, NULL, p_plan_error_code)
   ,DECODE( p_total_plan_revenue, FND_API.G_MISS_NUM, NULL,
            p_total_plan_revenue)
   ,DECODE( p_total_plan_raw_cost, FND_API.G_MISS_NUM, NULL,
            p_total_plan_raw_cost)
   ,DECODE( p_total_plan_burdened_cost, FND_API.G_MISS_NUM, NULL,
            p_total_plan_burdened_cost)
   ,DECODE( p_total_plan_quantity, FND_API.G_MISS_NUM, NULL,
            p_total_plan_quantity)
   ,DECODE( p_average_discount_percentage, FND_API.G_MISS_NUM, NULL,
            p_average_discount_percentage)
   ,DECODE( p_total_borrowed_revenue, FND_API.G_MISS_NUM, NULL,
            p_total_borrowed_revenue)
   ,DECODE( p_total_tp_revenue_in, FND_API.G_MISS_NUM, NULL,
            p_total_tp_revenue_in)
   ,DECODE( p_total_tp_revenue_out, FND_API.G_MISS_NUM, NULL,
            p_total_tp_revenue_out)
   ,DECODE( p_total_revenue_adj, FND_API.G_MISS_NUM, NULL, p_total_revenue_adj)
   ,DECODE( p_total_lent_resource_cost, FND_API.G_MISS_NUM, NULL,
            p_total_lent_resource_cost)
   ,DECODE( p_total_tp_cost_in, FND_API.G_MISS_NUM, NULL, p_total_tp_cost_in)
   ,DECODE( p_total_tp_cost_out, FND_API.G_MISS_NUM, NULL, p_total_tp_cost_out)
   ,DECODE( p_total_cost_adj, FND_API.G_MISS_NUM, NULL, p_total_cost_adj)
   ,DECODE( p_total_unassigned_time_cost, FND_API.G_MISS_NUM, NULL,
            p_total_unassigned_time_cost)
   ,DECODE( p_total_utilization_percent, FND_API.G_MISS_NUM, NULL,
            p_total_utilization_percent)
   ,DECODE( p_total_utilization_hours, FND_API.G_MISS_NUM, NULL,
            p_total_utilization_hours)
   ,DECODE( p_total_utilization_adj, FND_API.G_MISS_NUM, NULL,
            p_total_utilization_adj)
   ,DECODE( p_total_capacity, FND_API.G_MISS_NUM, NULL, p_total_capacity)
   ,DECODE( p_total_head_count, FND_API.G_MISS_NUM, NULL, p_total_head_count)
   ,DECODE( p_total_head_count_adj, FND_API.G_MISS_NUM, NULL,
            p_total_head_count_adj)
   ,DECODE( p_resource_assignment_type, FND_API.G_MISS_CHAR, NULL,
            p_resource_assignment_type)
-- start of changes of Bug:- 2634900
   ,DECODE( p_total_project_raw_cost, FND_API.G_MISS_NUM , NULL,
            p_total_project_raw_cost)
   ,DECODE( p_total_project_burdened_cost, FND_API.G_MISS_NUM , NULL,
            p_total_project_burdened_cost)
   ,DECODE( p_total_project_revenue, FND_API.G_MISS_NUM , NULL,
            p_total_project_revenue)
   ,DECODE( p_parent_assignment_id, FND_API.G_MISS_NUM , NULL,
            p_parent_assignment_id)
-- end of changes of Bug:- 2634900
            );

EXCEPTION
  WHEN OTHERS THEN
	  FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_RESOURCE_ASSIGNMENTS_PKG.Insert_Row',
                                p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE;
End Insert_Row;

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
 ,x_return_status               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    UPDATE pa_resource_assignments
    SET
     budget_version_id = DECODE( p_budget_version_id, FND_API.G_MISS_NUM,
                                 budget_version_id, p_budget_version_id)
    ,project_id = DECODE( p_project_id, FND_API.G_MISS_NUM, project_id,
                          p_project_id)
    ,task_id = DECODE( p_task_id, FND_API.G_MISS_NUM, task_id, p_task_id)
    ,resource_list_member_id = DECODE( p_resource_list_member_id,
                                       FND_API.G_MISS_NUM,
                                       resource_list_member_id,
                                       p_resource_list_member_id)
    ,last_update_date = sysdate
    ,last_updated_by = fnd_global.user_id
    ,last_update_login = fnd_global.login_id
    ,unit_of_measure = DECODE( p_unit_of_measure, FND_API.G_MISS_CHAR,
                               unit_of_measure, p_unit_of_measure)
    ,track_as_labor_flag = DECODE( p_track_as_labor_flag, FND_API.G_MISS_CHAR,
                                   track_as_labor_flag, p_track_as_labor_flag)
    ,standard_bill_rate = DECODE( p_standard_bill_rate, FND_API.G_MISS_NUM,
                                  standard_bill_rate, p_standard_bill_rate)
    ,average_bill_rate = DECODE( p_average_bill_rate, FND_API.G_MISS_NUM,
                                 average_bill_rate, p_average_bill_rate)
    ,average_cost_rate = DECODE( p_average_cost_rate, FND_API.G_MISS_NUM,
                                 average_cost_rate, p_average_cost_rate)
    ,project_assignment_id = DECODE( p_project_assignment_id,
                                     FND_API.G_MISS_NUM, project_assignment_id,
                                     p_project_assignment_id)
    ,plan_error_code = DECODE( p_plan_error_code, FND_API.G_MISS_CHAR,
                               plan_error_code, p_plan_error_code)
    ,total_plan_revenue = DECODE( p_total_plan_revenue, FND_API.G_MISS_NUM,
                                  total_plan_revenue, p_total_plan_revenue)
    ,total_plan_raw_cost = DECODE( p_total_plan_raw_cost, FND_API.G_MISS_NUM,
                                   total_plan_raw_cost, p_total_plan_raw_cost)
    ,total_plan_burdened_cost = DECODE( p_total_plan_burdened_cost,
                                        FND_API.G_MISS_NUM,
                                        total_plan_burdened_cost,
                                        p_total_plan_burdened_cost)
    ,total_plan_quantity = DECODE( p_total_plan_quantity, FND_API.G_MISS_NUM,
                                   total_plan_quantity, p_total_plan_quantity)
    ,average_discount_percentage = DECODE( p_average_discount_percentage,
                                           FND_API.G_MISS_NUM,
                                           average_discount_percentage,
                                           p_average_discount_percentage)
    ,total_borrowed_revenue = DECODE( p_total_borrowed_revenue,
                                      FND_API.G_MISS_NUM,
                                      total_borrowed_revenue,
                                      p_total_borrowed_revenue)
    ,total_tp_revenue_in = DECODE( p_total_tp_revenue_in, FND_API.G_MISS_NUM,
                                   total_tp_revenue_in, p_total_tp_revenue_in)
    ,total_tp_revenue_out = DECODE( p_total_tp_revenue_out, FND_API.G_MISS_NUM,
                                    total_tp_revenue_out,
                                    p_total_tp_revenue_out)
    ,total_revenue_adj = DECODE( p_total_revenue_adj, FND_API.G_MISS_NUM,
                                 total_revenue_adj, p_total_revenue_adj)
    ,total_lent_resource_cost = DECODE( p_total_lent_resource_cost,
                                        FND_API.G_MISS_NUM,
                                        total_lent_resource_cost,
                                        p_total_lent_resource_cost)
    ,total_tp_cost_in = DECODE( p_total_tp_cost_in, FND_API.G_MISS_NUM,
                                total_tp_cost_in, p_total_tp_cost_in)
    ,total_tp_cost_out = DECODE( p_total_tp_cost_out, FND_API.G_MISS_NUM,
                                 total_tp_cost_out, p_total_tp_cost_out)
    ,total_cost_adj = DECODE( p_total_cost_adj, FND_API.G_MISS_NUM,
                              total_cost_adj, p_total_cost_adj)
    ,total_unassigned_time_cost = DECODE( p_total_unassigned_time_cost,
                                          FND_API.G_MISS_NUM,
                                          total_unassigned_time_cost,
                                          p_total_unassigned_time_cost)
    ,total_utilization_percent = DECODE( p_total_utilization_percent,
                                         FND_API.G_MISS_NUM,
                                         total_utilization_percent,
                                         p_total_utilization_percent)
    ,total_utilization_hours = DECODE( p_total_utilization_hours,
                                       FND_API.G_MISS_NUM,
                                       total_utilization_hours,
                                       p_total_utilization_hours)
    ,total_utilization_adj = DECODE( p_total_utilization_adj,
                                     FND_API.G_MISS_NUM, total_utilization_adj,
                                     p_total_utilization_adj)
    ,total_capacity = DECODE( p_total_capacity, FND_API.G_MISS_NUM,
                              total_capacity, p_total_capacity)
    ,total_head_count = DECODE( p_total_head_count, FND_API.G_MISS_NUM,
                                total_head_count, p_total_head_count)
    ,total_head_count_adj = DECODE( p_total_head_count_adj, FND_API.G_MISS_NUM,
                                    total_head_count_adj,
                                    p_total_head_count_adj)
    ,resource_assignment_type = DECODE( p_resource_assignment_type,
                                        FND_API.G_MISS_CHAR,
                                        resource_assignment_type,
                                        p_resource_assignment_type)
-- start of changes of Bug:- 2634900
    ,total_project_raw_cost = DECODE( p_total_project_raw_cost,
                                        FND_API.G_MISS_NUM ,
                                        total_project_raw_cost,
                                        p_total_project_raw_cost)
    ,total_project_burdened_cost = DECODE( p_total_project_burdened_cost,
                                        FND_API.G_MISS_NUM ,
                                        total_project_burdened_cost,
                                        p_total_project_burdened_cost)
    ,total_project_revenue = DECODE( p_total_project_revenue,
                                        FND_API.G_MISS_NUM ,
                                        total_project_revenue,
                                        p_total_project_revenue)
    ,parent_assignment_id = DECODE( p_parent_assignment_id,
                                        FND_API.G_MISS_NUM ,
                                        parent_assignment_id,
                                        p_parent_assignment_id)
-- end of changes of Bug:- 2634900
    WHERE resource_assignment_id = p_resource_assignment_id;

    IF (SQL%NOTFOUND) THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;


EXCEPTION
  WHEN OTHERS THEN
	  FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_RESOURCE_ASSIGNMENTS_PKG.Update_Row',
                                p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE;
END Update_Row;

PROCEDURE Lock_Row
( p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

 IS
   l_row_id ROWID;

BEGIN

       SELECT rowid into l_row_id
       FROM pa_resource_assignments
       WHERE resource_assignment_id =  p_resource_assignment_id
		OR rowid = p_row_id
       FOR UPDATE NOWAIT;

EXCEPTION
  WHEN OTHERS THEN
	  FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_RESOURCE_ASSIGNMENTS_PKG.Lock_Row',
                                p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE;
END Lock_Row;

PROCEDURE Delete_Row
( p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    IF (p_resource_assignment_id IS NOT NULL AND p_resource_assignment_id <>
                                                 FND_API.G_MISS_NUM) THEN
        DELETE FROM pa_resource_assignments
         WHERE resource_assignment_id = p_resource_assignment_id;
    ELSIF (p_row_id IS NOT NULL) THEN
	   DELETE FROM pa_resource_assignments
         WHERE rowid = p_row_id;
    END IF;

        IF (SQL%NOTFOUND) THEN
            PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

EXCEPTION
  WHEN OTHERS THEN
	  FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_RESOURCE_ASSIGNMENTS_PKG.Delete_Row',
                                p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE;
END Delete_Row;

END pa_fp_resource_assignments_pkg;

/
