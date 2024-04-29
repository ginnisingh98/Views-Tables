--------------------------------------------------------
--  DDL for Package PA_ORG_FCST_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ORG_FCST_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPFETS.pls 120.1 2005/08/19 16:26:37 mwasowic noship $ */
-- Start of Comments
-- Package name     : pa_org_fcst_elements_pkg
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

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
 ,x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
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
 ,x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Lock_Row
( p_forecast_element_id    IN pa_org_fcst_elements.forecast_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_record_version_number  IN NUMBER
                              := NULL
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_forecast_element_id    IN pa_org_fcst_elements.forecast_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_record_version_number  IN NUMBER
                              := NULL
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
End pa_org_fcst_elements_pkg;
 

/
