--------------------------------------------------------
--  DDL for Package PA_PROJECT_PARTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_PARTIES_PUB" AUTHID CURRENT_USER as
/* $Header: PARPPPMS.pls 120.3.12000000.1 2007/01/17 11:02:10 appldev ship $ */

-- Standard who
--   last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
--   created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
--   last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;


PROCEDURE CREATE_PROJECT_PARTY( p_api_version           IN NUMBER := 1.0,
                                p_init_msg_list         IN VARCHAR2 := FND_API.G_TRUE,
                                p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_role_id       IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_role_type     IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_type_id      IN NUMBER := 101, --EMPLOYEE
                                p_resource_source_id    IN NUMBER := FND_API.G_MISS_NUM,
                                p_resource_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_start_date_active     IN DATE := FND_API.G_MISS_DATE,/*Added for bug2774759*/
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_calling_module        IN VARCHAR2,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE := FND_API.G_MISS_DATE,
				p_mgr_validation_type   IN VARCHAR2 default 'FORM',/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_project_party_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_resource_id           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_assignment_id         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_wf_type               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_item_type          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_process            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE UPDATE_PROJECT_PARTY( p_api_version           IN NUMBER := 1.0,
                                p_init_msg_list         IN VARCHAR2 := FND_API.G_TRUE,
                                p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_role_id       IN NUMBER,
                                p_project_role_type     IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_type_id      IN NUMBER := 101, --EMPLOYEE
                                p_resource_source_id    IN NUMBER,
                                p_resource_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_id           IN NUMBER := FND_API.G_MISS_NUM,
                                p_start_date_active     IN DATE,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
                                p_calling_module        IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE :=  FND_API.G_MISS_DATE,
                                p_project_party_id      IN NUMBER,
                                p_assignment_id         IN NUMBER := 0,
                                p_assign_record_version_number IN NUMBER := 0,
                                p_mgr_validation_type   IN VARCHAR2 default 'FORM',/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_assignment_id         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_wf_type               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_item_type          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_process            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE DELETE_PROJECT_PARTY( p_api_version           IN NUMBER := 1.0,
                                p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE,
                                p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
                                p_calling_module        IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_party_id      IN NUMBER := FND_API.G_MISS_NUM,
                                p_scheduled_flag        IN VARCHAR2 default 'N',
                                p_assignment_id         IN NUMBER := 0,
                                p_assign_record_version_number IN NUMBER := 0,
				p_mgr_validation_type   IN VARCHAR2 default 'FORM',/*Added for bug 2111806*/
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- API name		: get_key_member_start_date
-- Type			: Public
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id        IN NUMBER     REQUIRED
--
--  History
--
--           28-MAY-2002    anlee     Created
--
--
--  Purpose
--  This API is used to calculate the key member start date
--  based on the project start date.
--  It is called in CREATE_PROJECT_PARTY, and is used to
--  default key member start dates when a project is created.
--  The implemented functionality is as follows:
--
--  IF project_start date <= sysdate
--  return project start date
--
--  IF project start date > sysdate
--  return sysdate
--
--  This function may be modified if the logic for defaulting
--  key member start date at project creation time needs to
--  be changed.
FUNCTION GET_KEY_MEMBER_START_DATE (p_project_id IN NUMBER)
return DATE;

/*=============================================================================
 This api is used as a wrapper API to CREATE_PROJECT_PARTY
==============================================================================*/

PROCEDURE CREATE_PROJECT_PARTY_WRP( p_api_version       IN NUMBER := 1.0,
                                p_init_msg_list         IN VARCHAR2 := FND_API.G_TRUE,
                                p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_role_id       IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_role_type     IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_type_id      IN NUMBER := 101, --EMPLOYEE
                                p_resource_source_id    IN NUMBER := FND_API.G_MISS_NUM,
                                p_resource_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_start_date_active     IN DATE := FND_API.G_MISS_DATE,/*Added for bug2774759*/
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_calling_module        IN VARCHAR2,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE := FND_API.G_MISS_DATE,
				p_mgr_validation_type   IN VARCHAR2 default 'FORM',/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE,
                                x_project_party_id      OUT NOCOPY NUMBER,
                                x_resource_id           OUT NOCOPY NUMBER,
                                x_assignment_id         OUT NOCOPY NUMBER,
                                x_wf_type               OUT NOCOPY VARCHAR2,
                                x_wf_item_type          OUT NOCOPY VARCHAR2,
                                x_wf_process            OUT NOCOPY VARCHAR2,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2);
end;


 

/
