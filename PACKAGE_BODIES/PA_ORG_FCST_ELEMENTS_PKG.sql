--------------------------------------------------------
--  DDL for Package Body PA_ORG_FCST_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ORG_FCST_ELEMENTS_PKG" as
/* $Header: PAFPFETB.pls 120.1 2005/08/19 16:26:33 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_ORG_FCST_ELEMENTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_ORG_FCST_ELEMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pafpfetb.pls';

PROCEDURE Insert_Row
( px_forecast_element_id   IN OUT NOCOPY pa_org_fcst_elements.forecast_element_id%TYPE  --File.Sql.39 bug 4440895
 ,p_organization_id        IN pa_org_fcst_elements.organization_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_budget_version_id      IN pa_org_fcst_elements.budget_version_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_project_id             IN pa_org_fcst_elements.project_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_task_id                IN pa_org_fcst_elements.task_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_provider_receiver_code IN pa_org_fcst_elements.provider_receiver_code%TYPE
                              := FND_API.G_MISS_CHAR
 ,p_other_organization_id  IN pa_org_fcst_elements.other_organization_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_txn_project_id         IN pa_org_fcst_elements.txn_project_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_assignment_id          IN pa_org_fcst_elements.assignment_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_resource_id            IN pa_org_fcst_elements.resource_id%TYPE
                              := FND_API.G_MISS_NUM
 ,x_row_id                OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
   CURSOR C2 IS SELECT pa_org_fcst_elements_s.nextval FROM sys.dual;
BEGIN
   IF (px_forecast_element_id IS NULL) OR
      (px_forecast_element_id = FND_API.G_MISS_NUM) THEN
       OPEN C2;
       FETCH C2 INTO px_forecast_element_id;
       CLOSE C2;
   END IF;
   INSERT INTO pa_org_fcst_elements(
    forecast_element_id
   ,record_version_number
   ,creation_date
   ,created_by
   ,last_update_login
   ,last_updated_by
   ,last_update_date
   ,organization_id
   ,budget_version_id
   ,project_id
   ,task_id
   ,provider_receiver_code
   ,other_organization_id
   ,txn_project_id
   ,assignment_id
   ,resource_id
   ) values (
    px_forecast_element_id
   ,1
   ,sysdate
   ,fnd_global.user_id
   ,fnd_global.login_id
   ,fnd_global.user_id
   ,sysdate
   ,DECODE( p_organization_id, FND_API.G_MISS_NUM, NULL, p_organization_id)
   ,DECODE( p_budget_version_id, FND_API.G_MISS_NUM, NULL, p_budget_version_id)
   ,DECODE( p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id)
   ,DECODE( p_task_id, FND_API.G_MISS_NUM, NULL, p_task_id)
   ,DECODE( p_provider_receiver_code, FND_API.G_MISS_CHAR, NULL,
            p_provider_receiver_code)
   ,DECODE( p_other_organization_id, FND_API.G_MISS_NUM, NULL,
            p_other_organization_id)
   ,DECODE( p_txn_project_id, FND_API.G_MISS_NUM, NULL, p_txn_project_id)
   ,DECODE( p_assignment_id, FND_API.G_MISS_NUM, NULL, p_assignment_id)
   ,DECODE( p_resource_id, FND_API.G_MISS_NUM, NULL, p_resource_id));
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_ORG_FCST_ELEMENTS_PKG.Insert_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Insert_Row;

PROCEDURE update_row
( p_forecast_element_id    IN pa_org_fcst_elements.forecast_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_record_version_number  IN NUMBER
                              := NULL
 ,p_organization_id        IN pa_org_fcst_elements.organization_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_budget_version_id      IN pa_org_fcst_elements.budget_version_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_project_id             IN pa_org_fcst_elements.project_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_task_id                IN pa_org_fcst_elements.task_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_provider_receiver_code IN pa_org_fcst_elements.provider_receiver_code%TYPE
                              := FND_API.G_MISS_CHAR
 ,p_other_organization_id  IN pa_org_fcst_elements.other_organization_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_txn_project_id         IN pa_org_fcst_elements.txn_project_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_assignment_id          IN pa_org_fcst_elements.assignment_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_resource_id            IN pa_org_fcst_elements.resource_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
 UPDATE pa_org_fcst_elements
    SET
  record_version_number =   nvl(record_version_number,0) +1
 ,last_update_login = fnd_global.login_id
 ,last_updated_by = fnd_global.user_id
 ,last_update_date = sysdate
 ,forecast_element_id = DECODE( p_forecast_element_id, FND_API.G_MISS_NUM,
                                forecast_element_id, p_forecast_element_id)
 ,organization_id = DECODE( p_organization_id, FND_API.G_MISS_NUM,
                            organization_id, p_organization_id)
 ,budget_version_id = DECODE( p_budget_version_id, FND_API.G_MISS_NUM,
                              budget_version_id, p_budget_version_id)
 ,project_id = DECODE( p_project_id, FND_API.G_MISS_NUM, project_id,
                       p_project_id)
 ,task_id = DECODE( p_task_id, FND_API.G_MISS_NUM, task_id, p_task_id)
 ,provider_receiver_code = DECODE( p_provider_receiver_code,
                                   FND_API.G_MISS_CHAR,
                                   provider_receiver_code,
                                   p_provider_receiver_code)
 ,other_organization_id = DECODE( p_other_organization_id, FND_API.G_MISS_NUM,
                                  other_organization_id,
                                  p_other_organization_id)
 ,txn_project_id = DECODE( p_txn_project_id, FND_API.G_MISS_NUM, txn_project_id,
                           p_txn_project_id)
 ,assignment_id = DECODE( p_assignment_id, FND_API.G_MISS_NUM, assignment_id,
                          p_assignment_id)
 ,resource_id = DECODE( p_resource_id, FND_API.G_MISS_NUM, resource_id,
                        p_resource_id)
 WHERE forecast_element_id = p_forecast_element_id
   AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                    nvl(record_version_number,0);

    IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_ORG_FCST_ELEMENTS_PKG.Update_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Update_Row;

PROCEDURE Delete_Row
( p_forecast_element_id    IN pa_org_fcst_elements.forecast_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_record_version_number  IN NUMBER
                              := NULL
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    IF (p_forecast_element_id IS NOT NULL OR
        p_forecast_element_id <> FND_API.G_MISS_NUM) THEN

        DELETE FROM pa_org_fcst_elements
         WHERE forecast_element_id = p_forecast_element_id
           AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                            nvl(record_version_number,0);

    ELSIF (p_row_id IS NOT NULL) THEN

        DELETE FROM pa_org_fcst_elements
         WHERE rowid = p_row_id
           AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                            nvl(record_version_number,0);
    END IF;

    IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_ORG_FCST_ELEMENTS_PKG.Delete_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Delete_Row;

PROCEDURE Lock_Row
( p_forecast_element_id    IN pa_org_fcst_elements.forecast_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_record_version_number  IN NUMBER
                              := NULL
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
    l_row_id ROWID;
BEGIN
       SELECT rowid into l_row_id
       FROM pa_org_fcst_elements
       WHERE forecast_element_id =  p_forecast_element_id
          OR rowid = p_row_id
       FOR UPDATE NOWAIT;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_ORG_FCST_ELEMENTS_PKG.Lock_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Lock_Row;

End pa_org_fcst_elements_pkg;

/
