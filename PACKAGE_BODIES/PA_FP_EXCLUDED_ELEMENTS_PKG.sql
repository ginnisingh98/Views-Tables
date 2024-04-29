--------------------------------------------------------
--  DDL for Package Body PA_FP_EXCLUDED_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_EXCLUDED_ELEMENTS_PKG" as
/* $Header: PAFPXELB.pls 120.1 2005/08/19 16:32:06 mwasowic noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PA_FP_EXCLUDED_ELEMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'PAFPEXLB.pls';

PROCEDURE Insert_Row
(
 p_proj_fp_options_id           IN pa_fp_excluded_elements.proj_fp_options_id%TYPE
,p_project_id                   IN pa_fp_excluded_elements.project_id%TYPE
,p_fin_plan_type_id             IN pa_fp_excluded_elements.fin_plan_type_id%TYPE
,p_element_type                 IN pa_fp_excluded_elements.element_type%TYPE
,p_fin_plan_version_id          IN pa_fp_excluded_elements.fin_plan_version_id%TYPE
,p_task_id                      IN pa_fp_excluded_elements.task_id%TYPE
,x_row_id                       OUT NOCOPY ROWID --File.Sql.39 bug 4440895
,x_return_status                OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   INSERT INTO pa_fp_excluded_elements(
    proj_fp_options_id
   ,project_id
   ,fin_plan_type_id
   ,element_type
   ,fin_plan_version_id
   ,task_id
   ,record_version_number
   ,last_update_date
   ,last_updated_by
   ,creation_date
   ,created_by
   ,last_update_login
    ) VALUES (
    p_proj_fp_options_id
   ,p_project_id
   ,p_fin_plan_type_id
   ,p_element_type
   ,p_fin_plan_version_id
   ,p_task_id
   ,1
   ,sysdate
   ,fnd_global.user_id
   ,sysdate
   ,fnd_global.user_id
   ,fnd_global.login_id)
   RETURNING rowid INTO x_row_id;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_EXCLUDED_ELEMENTS_PKG'
                               ,p_procedure_name
                                => 'Insert_Row');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Insert_Row;

PROCEDURE Update_Row
(
 p_proj_fp_options_id           IN pa_fp_excluded_elements.proj_fp_options_id%TYPE
,p_project_id                   IN pa_fp_excluded_elements.project_id%TYPE
,p_fin_plan_type_id             IN pa_fp_excluded_elements.fin_plan_type_id%TYPE
,p_element_type                 IN pa_fp_excluded_elements.element_type%TYPE
,p_fin_plan_version_id          IN pa_fp_excluded_elements.fin_plan_version_id%TYPE
,p_task_id                      IN pa_fp_excluded_elements.task_id%TYPE
,p_record_version_number        IN pa_fp_excluded_elements.record_version_number%TYPE
,p_row_id                       IN ROWID
,x_return_status                OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   UPDATE pa_fp_excluded_elements
   SET    proj_fp_options_id  = DECODE(p_proj_fp_options_id,
                                        FND_API.G_MISS_NUM, Null,
                                        nvl(p_proj_fp_options_id,proj_fp_options_id))
   ,project_id                = DECODE(p_project_id,
                                        FND_API.G_MISS_NUM, Null,
                                        nvl(p_project_id, project_id))
   ,fin_plan_type_id          = DECODE(p_fin_plan_type_id,
                                        FND_API.G_MISS_NUM, Null,
                                        nvl(p_fin_plan_type_id,fin_plan_type_id))
   ,element_type              = DECODE(p_element_type,
                                        FND_API.G_MISS_CHAR,Null,
                                        nvl(p_element_type,element_type))
   ,fin_plan_version_id       = DECODE(p_fin_plan_version_id,
                                        FND_API.G_MISS_NUM, Null,
                                        nvl(p_fin_plan_version_id, fin_plan_version_id))
   ,task_id                   = DECODE(p_task_id,
                                        FND_API.G_MISS_NUM, Null,
                                        nvl(p_task_id,task_id))
   ,record_version_number     = DECODE(p_record_version_number,
                                        FND_API.G_MISS_NUM, Null,
                                        nvl(p_record_version_number,nvl(record_version_number,0)) + 1)
   ,last_update_date          = SYSDATE
   ,last_updated_by           = FND_GLOBAL.USER_ID
   ,last_update_login         = FND_GLOBAL.LOGIN_ID
   WHERE rowid = p_row_id
   AND   nvl(record_version_number,0) = nvl(p_record_version_number, nvl(record_version_number,0));

    IF (SQL%NOTFOUND) THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_EXCLUDED_ELEMENTS_PKG'
                               ,p_procedure_name
                                => 'Update_Row');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Update_Row;

PROCEDURE Delete_Row
( p_proj_fp_options_id          IN pa_fp_excluded_elements.proj_fp_options_id%TYPE    := Null
 ,p_element_type                IN pa_fp_excluded_elements.element_type%TYPE          := Null
 ,p_task_id                     IN pa_fp_excluded_elements.task_id%TYPE               := Null
 ,p_row_id                      IN ROWID
 ,p_record_version_number       IN NUMBER                                             := Null
 ,x_return_status               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_row_id IS NOT NULL THEN

         DELETE FROM pa_fp_excluded_elements
         WHERE  rowid = p_row_id
         AND    nvl(record_version_number,0) = nvl(p_record_version_number, nvl(record_version_number,0));

    ELSE

         DELETE FROM pa_fp_excluded_elements
         WHERE  proj_fp_options_id = p_proj_fp_options_id
         AND    element_type       = p_element_type
         AND    task_id            = p_task_id
         AND    nvl(record_version_number,0) = nvl(p_record_version_number, nvl(record_version_number,0));

    END IF;

    IF (SQL%NOTFOUND) THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_EXCLUDED_ELEMENTS_PKG'
                               ,p_procedure_name
                                    => 'Delete_Row');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Delete_Row;

PROCEDURE Lock_Row
( p_row_id                         IN ROWID
 ,p_record_version_number          IN NUMBER
 ,x_return_status                  OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_row_id ROWID;
BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       SELECT  rowid
       INTO    l_row_id
       FROM    pa_fp_excluded_elements
       WHERE   rowid = p_row_id
       AND     nvl(record_version_number,0) = nvl(p_record_version_number, nvl(record_version_number,0))
       FOR     UPDATE NOWAIT;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_EXCLUDED_ELEMENTS_PKG'
                               ,p_procedure_name
                                    => 'Lock_Row');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Lock_Row;

END pa_fp_excluded_elements_pkg;

/
