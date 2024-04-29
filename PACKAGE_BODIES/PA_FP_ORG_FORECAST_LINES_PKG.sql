--------------------------------------------------------
--  DDL for Package Body PA_FP_ORG_FORECAST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_ORG_FORECAST_LINES_PKG" as
/* $Header: PAFPFLTB.pls 120.1 2005/08/19 16:26:41 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_ORG_FORECAST_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_FP_ORG_FORECAST_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pafpfltb.pls';

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
 ,x_return_status        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
   CURSOR C2 IS SELECT pa_org_forecast_lines_s.nextval FROM sys.dual;
BEGIN
   IF (px_forecast_line_id IS NULL) OR
      (px_forecast_line_id = FND_API.G_MISS_NUM) THEN
       OPEN C2;
       FETCH C2 INTO px_forecast_line_id;
       CLOSE C2;
   END IF;
   insert into pa_org_forecast_lines(
    forecast_line_id
   ,record_version_number
   ,creation_date
   ,created_by
   ,last_update_login
   ,last_updated_by
   ,last_update_date
   ,forecast_element_id
   ,budget_version_id
   ,project_id
   ,task_id
   ,period_name
   ,start_date
   ,end_date
   ,quantity
   ,raw_cost
   ,burdened_cost
   ,tp_cost_in
   ,tp_cost_out
   ,revenue
   ,tp_revenue_in
   ,tp_revenue_out
   ,borrowed_revenue
   ,lent_resource_cost
   ,unassigned_time_cost
   ) values (
    px_forecast_line_id
   ,1
   ,sysdate
   ,fnd_global.user_id
   ,fnd_global.login_id
   ,fnd_global.user_id
   ,sysdate
   ,DECODE( p_forecast_element_id, FND_API.G_MISS_NUM, NULL,
            p_forecast_element_id)
   ,DECODE( p_budget_version_id, FND_API.G_MISS_NUM, NULL,
            p_budget_version_id)
   ,DECODE( p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id)
   ,DECODE( p_task_id, FND_API.G_MISS_NUM, NULL, p_task_id)
   ,DECODE( p_period_name, FND_API.G_MISS_CHAR, NULL, p_period_name)
   ,DECODE( p_start_date, FND_API.G_MISS_DATE, to_date(null), p_start_date)
   ,DECODE( p_end_date, FND_API.G_MISS_DATE, to_date(null), p_end_date)
   ,DECODE( p_quantity, FND_API.G_MISS_NUM, NULL, p_quantity)
   ,DECODE( p_raw_cost, FND_API.G_MISS_NUM, NULL, p_raw_cost)
   ,DECODE( p_burdened_cost, FND_API.G_MISS_NUM, NULL, p_burdened_cost)
   ,DECODE( p_tp_cost_in, FND_API.G_MISS_NUM, NULL, p_tp_cost_in)
   ,DECODE( p_tp_cost_out, FND_API.G_MISS_NUM, NULL, p_tp_cost_out)
   ,DECODE( p_revenue, FND_API.G_MISS_NUM, NULL, p_revenue)
   ,DECODE( p_tp_revenue_in, FND_API.G_MISS_NUM, NULL, p_tp_revenue_in)
   ,DECODE( p_tp_revenue_out, FND_API.G_MISS_NUM, NULL, p_tp_revenue_out)
   ,DECODE( p_borrowed_revenue, FND_API.G_MISS_NUM, NULL, p_borrowed_revenue)
   ,DECODE( p_lent_resource_cost, FND_API.G_MISS_NUM, NULL, p_lent_resource_cost)
   ,DECODE( p_unassigned_time_cost, FND_API.G_MISS_NUM, NULL, p_unassigned_time_cost));
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_ORG_FORECAST_LINES_PKG.Update_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Insert_Row;

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
 ,x_return_status        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
 UPDATE pa_org_forecast_lines
 SET
  record_version_number = nvl(record_version_number,0) +1
 ,last_update_login = fnd_global.login_id
 ,last_updated_by = fnd_global.user_id
 ,last_update_date = sysdate
 ,forecast_element_id = DECODE( p_forecast_element_id, FND_API.G_MISS_NUM,
                                forecast_element_id, p_forecast_element_id)
 ,budget_version_id   = DECODE( p_budget_version_id, FND_API.G_MISS_NUM,
                                budget_version_id, p_budget_version_id)
 ,project_id = DECODE( p_project_id, FND_API.G_MISS_NUM, project_id,
                       p_project_id)
 ,task_id = DECODE( p_task_id, FND_API.G_MISS_NUM, task_id, p_task_id)
 ,period_name = DECODE( p_period_name, FND_API.G_MISS_CHAR, period_name,
                        p_period_name)
 ,start_date = DECODE( p_start_date, FND_API.G_MISS_DATE, start_date,
                       p_start_date)
 ,end_date = DECODE( p_end_date, FND_API.G_MISS_DATE, end_date, p_end_date)
 ,quantity = DECODE( p_quantity, FND_API.G_MISS_NUM, quantity, p_quantity)
 ,raw_cost = DECODE( p_raw_cost, FND_API.G_MISS_NUM, raw_cost, p_raw_cost)
 ,burdened_cost = DECODE( p_burdened_cost, FND_API.G_MISS_NUM, burdened_cost,
                          p_burdened_cost)
 ,tp_cost_in = DECODE( p_tp_cost_in, FND_API.G_MISS_NUM, tp_cost_in,
                       p_tp_cost_in)
 ,tp_cost_out = DECODE( p_tp_cost_out, FND_API.G_MISS_NUM, tp_cost_out,
                        p_tp_cost_out)
 ,revenue = DECODE( p_revenue, FND_API.G_MISS_NUM, revenue, p_revenue)
 ,tp_revenue_in = DECODE( p_tp_revenue_in, FND_API.G_MISS_NUM, tp_revenue_in,
                          p_tp_revenue_in)
 ,tp_revenue_out = DECODE( p_tp_revenue_out, FND_API.G_MISS_NUM, tp_revenue_out,
                           p_tp_revenue_out)
 ,borrowed_revenue = DECODE( p_borrowed_revenue, FND_API.G_MISS_NUM,
                             borrowed_revenue, p_borrowed_revenue)
 ,lent_resource_cost = DECODE( p_lent_resource_cost, FND_API.G_MISS_NUM,
                               lent_resource_cost, p_lent_resource_cost)
 ,unassigned_time_cost = DECODE( p_unassigned_time_cost, FND_API.G_MISS_NUM,
                                 unassigned_time_cost, p_unassigned_time_cost)
 WHERE forecast_line_id = p_forecast_line_id
   AND nvl(p_record_version_number, nvl(record_version_number,0))
                        = nvl(record_version_number,0);

    IF (SQL%NOTFOUND) THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_ORG_FORECAST_LINES_PKG.Update_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Update_Row;

PROCEDURE Lock_Row
( p_forecast_line_id      IN pa_org_forecast_lines.forecast_line_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_record_version_number IN NUMBER
                             := NULL
 ,p_row_id                IN ROWID
                             := NULL
 ,x_return_status        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
  l_row_id ROWID;
BEGIN
       SELECT rowid into l_row_id
         FROM pa_org_forecast_lines
        WHERE forecast_line_id =  p_forecast_line_id
           OR rowid = p_row_id
          FOR UPDATE NOWAIT;
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_ORG_FORECAST_LINES_PKG.Update_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Lock_Row;

PROCEDURE Delete_Row
( p_forecast_line_id      IN pa_org_forecast_lines.forecast_line_id%TYPE
                             := FND_API.G_MISS_NUM
 ,p_record_version_number IN NUMBER
                             := NULL
 ,p_row_id                IN ROWID
                             := NULL
 ,x_return_status        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    IF (p_forecast_line_id IS NOT NULL AND p_forecast_line_id <>
        FND_API.G_MISS_NUM) THEN

        DELETE FROM pa_org_forecast_lines
         WHERE forecast_line_id = p_forecast_line_id
           AND nvl(p_record_version_number, nvl(record_version_number,0))
                                = nvl(record_version_number,0);
    ELSIF (p_row_id IS NOT NULL) THEN
        DELETE FROM pa_org_forecast_lines
         WHERE rowid = p_row_id
           AND nvl(p_record_version_number, nvl(record_version_number,0))
                                = nvl(record_version_number,0);
    END IF;
    IF (SQL%NOTFOUND) THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_ORG_FORECAST_LINES_PKG.Delete_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Delete_Row;

End pa_fp_org_forecast_lines_pkg;

/
