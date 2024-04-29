--------------------------------------------------------
--  DDL for Package Body PA_FP_FIN_PLAN_ADJ_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_FIN_PLAN_ADJ_LINES_PKG" as
/* $Header: PAFPALTB.pls 120.1 2005/08/19 16:23:57 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_FIN_PLAN_ADJ_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_FP_FIN_PLAN_ADJ_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pafpaltb.pls';

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
 ,x_return_status            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
   CURSOR C2 IS select pa_fin_plan_adj_lines_s.nextval FROM sys.dual;
BEGIN
   If (px_fin_plan_adj_line_id IS NULL) OR (px_fin_plan_adj_line_id = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_fin_plan_adj_line_id;
       CLOSE C2;
   End If;
   INSERT INTO PA_FIN_PLAN_ADJ_LINES(
           fin_plan_adj_line_id
          ,creation_date
          ,created_by
          ,last_update_login
          ,last_updated_by
          ,last_update_date
	  ,adj_element_id
          ,project_id
          ,task_id
          ,budget_version_id
          ,resource_assignment_id
          ,period_name
          ,start_date
          ,end_date
          ,raw_cost_adjustment
          ,burdened_cost_adjustment
          ,revenue_adjustment
          ,utilization_adjustment
          ,head_count_adjustment
          ) VALUES (
           px_fin_plan_adj_line_id
          ,sysdate
          ,fnd_global.user_id
          ,fnd_global.login_id
          ,fnd_global.user_id
          ,sysdate
          ,DECODE( p_adj_element_id, FND_API.G_MISS_NUM, NULL, p_adj_element_id)
	  ,DECODE( p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id)
          ,DECODE( p_task_id, FND_API.G_MISS_NUM, NULL, p_task_id)
          ,DECODE( p_budget_version_id, FND_API.G_MISS_NUM, NULL,
			    p_budget_version_id)
          ,DECODE( p_resource_assignment_id, FND_API.G_MISS_NUM, NULL,
			    p_resource_assignment_id)
          ,DECODE( p_period_name, FND_API.G_MISS_CHAR, NULL,
			    p_period_name)
          ,DECODE( p_start_date, FND_API.G_MISS_DATE, TO_DATE(NULL),
			    p_start_date)
          ,DECODE( p_end_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_end_date)
          ,DECODE( p_raw_cost_adjustment, FND_API.G_MISS_NUM, NULL,
			    p_raw_cost_adjustment)
          ,DECODE( p_burdened_cost_adjustment, FND_API.G_MISS_NUM, NULL,
			    p_burdened_cost_adjustment)
          ,DECODE( p_revenue_adjustment, FND_API.G_MISS_NUM, NULL,
			    p_revenue_adjustment)
          ,DECODE( p_utilization_adjustment, FND_API.G_MISS_NUM, NULL,
			    p_utilization_adjustment)
          ,DECODE( p_head_count_adjustment, FND_API.G_MISS_NUM, NULL,
			    p_head_count_adjustment));
EXCEPTION
  WHEN OTHERS THEN
	  FND_MSG_PUB.add_exc_msg( p_pkg_name
                                   => 'PA_FP_FIN_PLAN_ADJ_LINES_PKG.Insert_Row'
                                  ,p_procedure_name
                                   => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE;
END Insert_Row;

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
 ,x_return_status            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
 UPDATE pa_fin_plan_adj_lines
 SET
   last_update_login = fnd_global.login_id
  ,last_updated_by = fnd_global.user_id
  ,last_update_date = sysdate
  ,project_id = DECODE( p_project_id, FND_API.G_MISS_NUM, project_id,
                        p_project_id)
  ,adj_element_id = DECODE( p_adj_element_id, FND_API.G_MISS_NUM, adj_element_id, p_adj_element_id)
  ,task_id = DECODE( p_task_id, FND_API.G_MISS_NUM, task_id, p_task_id)
  ,budget_version_id = DECODE( p_budget_version_id, FND_API.G_MISS_NUM,
                               budget_version_id, p_budget_version_id)
  ,resource_assignment_id = DECODE( p_resource_assignment_id,
                                    FND_API.G_MISS_NUM,
                                    resource_assignment_id,
                                    p_resource_assignment_id)
  ,period_name = DECODE( p_period_name,
                         FND_API.G_MISS_CHAR,
                         period_name,
                         p_period_name)
  ,start_date = DECODE( p_start_date, FND_API.G_MISS_DATE, start_date,
                        p_start_date)
  ,end_date = DECODE( p_end_date, FND_API.G_MISS_DATE, end_date,
                      p_end_date)
  ,raw_cost_adjustment = DECODE( p_raw_cost_adjustment, FND_API.G_MISS_NUM,
                                 raw_cost_adjustment,
                                 p_raw_cost_adjustment)
  ,burdened_cost_adjustment = DECODE( p_burdened_cost_adjustment,
                                      FND_API.G_MISS_NUM,
                                      burdened_cost_adjustment,
                                      p_burdened_cost_adjustment)
  ,revenue_adjustment = DECODE( p_revenue_adjustment, FND_API.G_MISS_NUM,
                                revenue_adjustment,
                                p_revenue_adjustment)
  ,utilization_adjustment = DECODE( p_utilization_adjustment,
                                    FND_API.G_MISS_NUM,
                                    utilization_adjustment,
                                    p_utilization_adjustment)
  ,head_count_adjustment = DECODE( p_head_count_adjustment,
                                   FND_API.G_MISS_NUM,
                                   head_count_adjustment,
                                   p_head_count_adjustment)
WHERE fin_plan_adj_line_id = p_fin_plan_adj_line_id;

    IF (SQL%NOTFOUND) THEN
         PA_UTILS.Add_Message( p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_RECORD_CHANGED');

         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                    => 'PA_FP_FIN_PLAN_ADJ_LINES_PKG.Update_Row'
                               ,p_procedure_name
                                    => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Update_Row;

PROCEDURE Lock_Row
( p_fin_plan_adj_line_id     IN pa_fin_plan_adj_lines.fin_plan_adj_line_id%TYPE
                                := FND_API.G_MISS_NUM
 ,p_row_id                   IN ROWID
                                := NULL
 ,x_return_status            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS

  l_rowid ROWID;

BEGIN
       SELECT rowid into l_rowid
         FROM pa_fin_plan_adj_lines
        WHERE fin_plan_adj_line_id =  p_fin_plan_adj_line_id
		 OR rowid = p_row_id
        FOR UPDATE NOWAIT;

	   IF (SQL%NOTFOUND) THEN
               PA_UTILS.Add_message ( p_app_short_name => 'PA',
                                      p_msg_name => 'PA_XC_RECORD_CHANGED');

               x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
EXCEPTION
  WHEN OTHERS THEN
	  FND_MSG_PUB.add_exc_msg( p_pkg_name
                                      => 'PA_FP_FIN_PLAN_ADJ_LINES_PKG.Lock_Row'
                                  ,p_procedure_name
                                      => PA_DEBUG.G_Err_Stack);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE;
END Lock_Row;

PROCEDURE Delete_Row
( p_fin_plan_adj_line_id          IN pa_fin_plan_adj_lines.fin_plan_adj_line_id%TYPE
 ,p_row_id                   IN ROWID
                                := NULL
 ,x_return_status            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_fin_plan_adj_line_id IS NOT NULL AND
        p_fin_plan_adj_line_id <> FND_API.G_MISS_NUM) THEN

        DELETE FROM pa_fin_plan_adj_lines
         WHERE      fin_plan_adj_line_id = p_fin_plan_adj_line_id;
    ELSIF (p_row_id IS NOT NULL ) THEN
	   DELETE FROM pa_fin_plan_adj_lines
            WHERE      rowid = p_row_id;
    END IF;

    IF (SQL%NOTFOUND) THEN
	   PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_XC_RECORD_CHANGED');
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
	  FND_MSG_PUB.add_exc_msg( p_pkg_name
                                    => 'PA_FP_FIN_PLAN_ADJ_LINES_PKG.Delete_Row'
                                  ,p_procedure_name
                                    => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE;
END Delete_Row;

END pa_fp_fin_plan_adj_lines_pkg;

/
