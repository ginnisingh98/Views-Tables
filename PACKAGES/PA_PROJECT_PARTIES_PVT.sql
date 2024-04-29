--------------------------------------------------------
--  DDL for Package PA_PROJECT_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_PARTIES_PVT" AUTHID CURRENT_USER as
/* $Header: PARPPUTS.pls 120.1 2005/08/19 16:58:45 mwasowic noship $ */

-- l_assignment_rec      PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
l_delete_proj_party   VARCHAR2(1) := 'Y';

PROCEDURE CREATE_PROJECT_PARTY( p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_OBJECT_TYPE           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_RESOURCE_TYPE_ID      IN NUMBER := 101,
                                p_project_role_id       IN NUMBER,
                                p_resource_source_id    IN NUMBER,
                                p_start_date_active     IN DATE,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_calling_module        IN VARCHAR2,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE,
				p_mgr_validation_type   IN VARCHAR2 := FND_API.G_MISS_CHAR,/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_project_party_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_resource_id           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_assignment_id         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_wf_type               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_item_type          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_process            OUT NOCOPY VARCHAR2,         --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE UPDATE_PROJECT_PARTY( p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_role_id       IN NUMBER,
                                p_resource_type_id      IN NUMBER := 101,
                                p_resource_source_id    IN NUMBER,
                                p_resource_id           IN NUMBER,
                                p_start_date_active     IN DATE,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
                                p_calling_module        IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE,
                                p_project_party_id      IN  NUMBER,
                                p_assignment_id         IN NUMBER,
                                p_assign_record_version_number IN NUMBER,
				p_mgr_validation_type   IN VARCHAR2 := FND_API.G_MISS_CHAR,/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_assignment_id         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_wf_type               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_item_type          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_process            OUT NOCOPY VARCHAR2,         --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE DELETE_PROJECT_PARTY( p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
                                p_calling_module        IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_party_id      IN NUMBER := FND_API.G_MISS_NUM,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_assignment_id         IN NUMBER := 0,
                                p_assign_record_version_number IN NUMBER := 0,
                                p_mgr_validation_type   IN VARCHAR2 := FND_API.G_MISS_CHAR,/*Added for bug 2111806*/
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end;


 

/
