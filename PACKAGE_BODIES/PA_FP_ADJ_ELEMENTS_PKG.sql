--------------------------------------------------------
--  DDL for Package Body PA_FP_ADJ_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_ADJ_ELEMENTS_PKG" as
/* $Header: PAFPAETB.pls 120.1 2005/08/19 16:23:48 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_ADJ_ELEMENTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_FP_ADJ_ELEMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pafpoetb.pls';

PROCEDURE Insert_Row
( px_adj_element_id   IN OUT NOCOPY pa_fp_adj_elements.adj_element_id%TYPE --File.Sql.39 bug 4440895
 ,p_resource_assignment_id IN pa_fp_adj_elements.RESOURCE_ASSIGNMENT_ID%TYPE
                              := FND_API.G_MISS_NUM
 ,p_budget_version_id      IN pa_fp_adj_elements.budget_version_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_project_id             IN pa_fp_adj_elements.project_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_task_id                IN pa_fp_adj_elements.task_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_adjustment_reason_code IN pa_fp_adj_elements.ADJUSTMENT_REASON_CODE%TYPE
                              := FND_API.G_MISS_CHAR
 ,p_adjustment_comments    IN pa_fp_adj_elements.ADJUSTMENT_COMMENTS%TYPE
                              := FND_API.G_MISS_CHAR
 ,x_row_id                OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
   CURSOR C2 IS SELECT pa_fp_adj_elements_s.nextval FROM sys.dual;
BEGIN
   IF (px_adj_element_id IS NULL) OR
      (px_adj_element_id = FND_API.G_MISS_NUM) THEN
       OPEN C2;
       FETCH C2 INTO px_adj_element_id;
       CLOSE C2;
   END IF;
   INSERT INTO pa_fp_adj_elements(
    adj_element_id
   ,creation_date
   ,created_by
   ,last_update_login
   ,last_updated_by
   ,last_update_date
   ,budget_version_id
   ,project_id
   ,task_id
   ,resource_assignment_id
   ,ADJUSTMENT_REASON_CODE
   ,ADJUSTMENT_COMMENTS
   ) values (
    px_adj_element_id
   ,sysdate
   ,fnd_global.user_id
   ,fnd_global.login_id
   ,fnd_global.user_id
   ,sysdate
   ,DECODE( p_budget_version_id, FND_API.G_MISS_NUM, NULL, p_budget_version_id)
   ,DECODE( p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id)
   ,DECODE( p_task_id, FND_API.G_MISS_NUM, NULL, p_task_id)
   ,DECODE( p_resource_assignment_id, FND_API.G_MISS_NUM, NULL, p_resource_assignment_id)
   ,DECODE( p_adjustment_reason_code, FND_API.G_MISS_CHAR, NULL, p_adjustment_reason_code)
   ,DECODE( p_adjustment_comments, FND_API.G_MISS_CHAR, NULL, p_adjustment_comments));
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_ADJ_ELEMENTS_PKG.Insert_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Insert_Row;

PROCEDURE update_row
( p_adj_element_id    IN   pa_fp_adj_elements.adj_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_resource_assignment_id IN pa_fp_adj_elements.RESOURCE_ASSIGNMENT_ID%TYPE
                              := FND_API.G_MISS_NUM
 ,p_budget_version_id      IN pa_fp_adj_elements.budget_version_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_project_id             IN pa_fp_adj_elements.project_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_task_id                IN pa_fp_adj_elements.task_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_adjustment_reason_code IN pa_fp_adj_elements.ADJUSTMENT_REASON_CODE%TYPE
                              := FND_API.G_MISS_CHAR
 ,p_adjustment_comments    IN pa_fp_adj_elements.ADJUSTMENT_COMMENTS%TYPE
                              := FND_API.G_MISS_CHAR
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
 UPDATE pa_fp_adj_elements
    SET
  last_update_login = fnd_global.login_id
 ,last_updated_by = fnd_global.user_id
 ,last_update_date = sysdate
 ,adj_element_id = DECODE( p_adj_element_id, FND_API.G_MISS_NUM,
                               adj_element_id, p_adj_element_id)
 ,budget_version_id = DECODE( p_budget_version_id, FND_API.G_MISS_NUM,
                              budget_version_id, p_budget_version_id)
 ,project_id = DECODE( p_project_id, FND_API.G_MISS_NUM, project_id,
                       p_project_id)
 ,task_id = DECODE( p_task_id, FND_API.G_MISS_NUM, task_id, p_task_id)
 ,resource_assignment_id = DECODE( p_resource_assignment_id,
                                    FND_API.G_MISS_NUM,
                                    resource_assignment_id,
                                    p_resource_assignment_id)
 ,adjustment_reason_code = DECODE( p_adjustment_reason_code,
                                    FND_API.G_MISS_CHAR,
                                    adjustment_reason_code,
                                    p_adjustment_reason_code)
 ,adjustment_comments = DECODE( p_adjustment_comments, FND_API.G_MISS_CHAR,
                                adjustment_comments, p_adjustment_comments)
 WHERE adj_element_id = p_adj_element_id;

    IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_ADJ_ELEMENTS_PKG.Update_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Update_Row;

PROCEDURE Delete_Row
( p_adj_element_id    IN pa_fp_adj_elements.adj_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    IF (p_adj_element_id IS NOT NULL OR
        p_adj_element_id <> FND_API.G_MISS_NUM) THEN

        DELETE FROM pa_fp_adj_elements
         WHERE adj_element_id = p_adj_element_id;

    ELSIF (p_row_id IS NOT NULL) THEN

        DELETE FROM pa_fp_adj_elements
         WHERE rowid = p_row_id;
    END IF;

    IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_ADJ_ELEMENTS_PKG.Delete_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Delete_Row;

PROCEDURE Lock_Row
( p_adj_element_id    	   IN pa_fp_adj_elements.adj_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
    l_row_id ROWID;
BEGIN
       SELECT rowid into l_row_id
       FROM pa_fp_adj_elements
       WHERE adj_element_id =  p_adj_element_id
          OR rowid = p_row_id
       FOR UPDATE NOWAIT;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_ADJ_ELEMENTS_PKG.Lock_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Lock_Row;

End pa_fp_adj_elements_pkg;

/
