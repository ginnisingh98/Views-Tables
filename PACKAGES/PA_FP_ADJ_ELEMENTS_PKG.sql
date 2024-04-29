--------------------------------------------------------
--  DDL for Package PA_FP_ADJ_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_ADJ_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPAETS.pls 120.1 2005/08/19 16:23:53 mwasowic noship $*/
-- Start of Comments
-- Package name     : pa_fp_adj_elements_pkg
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row
( px_adj_element_id   IN OUT NOCOPY pa_fp_adj_elements.adj_element_id%TYPE  --File.Sql.39 bug 4440895
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
 ,x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
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
 ,x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Lock_Row
( p_adj_element_id    IN pa_fp_adj_elements.adj_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_adj_element_id    IN pa_fp_adj_elements.adj_element_id%TYPE
                              := FND_API.G_MISS_NUM
 ,p_row_id                 IN ROWID
                              := NULL
 ,x_return_status         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
End pa_fp_adj_elements_pkg;
 

/
