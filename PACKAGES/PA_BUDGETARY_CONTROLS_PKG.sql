--------------------------------------------------------
--  DDL for Package PA_BUDGETARY_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGETARY_CONTROLS_PKG" AUTHID CURRENT_USER AS
-- $Header: PAXBCCRS.pls 120.1 2006/04/01 19:46:20 appldev noship $

/* S.N. Bug 4219400 */
G_Budget_Version_ID  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%type  := NULL;
G_Budget_Status_Code PA_BUDGET_VERSIONS.BUDGET_STATUS_CODE%type := NULL;
/* S.N. Bug 4219400 */

PROCEDURE insert_rows
                        (x_project_id                   IN      PA_PROJECTS_ALL.PROJECT_ID%type
                        ,x_budget_type_code             IN      PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type
                        ,x_funds_control_level_code     IN      PA_BUDGETARY_CONTROLS.FUNDS_CONTROL_LEVEL_CODE%type
                        ,x_top_task_id                  IN      PA_TASKS.TASK_ID%type
                        ,x_task_id                      IN      PA_TASKS.TASK_ID%type
                        ,x_parent_member_id             IN      PA_RESOURCE_LIST_MEMBERS.PARENT_MEMBER_ID%type
                        ,x_resource_list_member_id      IN      PA_RESOURCE_LIST_MEMBERS.resource_list_member_id%type
                        ,x_return_status                OUT NOCOPY     VARCHAR2
                        ,x_msg_count                    OUT NOCOPY     NUMBER
                        ,x_msg_data                     OUT NOCOPY     VARCHAR2
			);


PROCEDURE create_bc_levels
                        (x_project_id             	IN    PA_PROJECTS_ALL.PROJECT_ID%type
                        ,x_budget_type_code      	IN    PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type
                        ,x_entry_level_code       	IN    PA_BUDGET_ENTRY_METHODS.ENTRY_LEVEL_CODE%type
                        ,x_resource_list_id       	IN    PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_ID%type
                        ,x_group_resource_type_id 	IN    PA_RESOURCE_LISTS_ALL_BG.GROUP_RESOURCE_TYPE_ID%type
                        ,x_calling_mode           	IN    VARCHAR2
                        ,x_return_status                OUT NOCOPY     VARCHAR2
                        ,x_msg_count                    OUT NOCOPY     NUMBER
                        ,x_msg_data                     OUT NOCOPY     VARCHAR2 );


PROCEDURE bud_ctrl_create
                        (x_budget_version_id    	IN      PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%type
                        ,x_calling_mode         	IN      VARCHAR2
                        ,x_return_status                OUT NOCOPY     VARCHAR2
                        ,x_msg_count                    OUT NOCOPY     NUMBER
                        ,x_msg_data             	OUT NOCOPY     VARCHAR2 ) ;

PROCEDURE budg_control_reset
			(x_project_id             IN	PA_PROJECTS_ALL.PROJECT_ID%type
			,x_budget_type_code       IN	PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type
			,x_entry_level_code       IN	PA_BUDGET_ENTRY_METHODS.ENTRY_LEVEL_CODE%type
			,x_resource_list_id       IN	PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_ID%type
			,x_group_resource_type_id IN	PA_RESOURCE_LISTS_ALL_BG.GROUP_RESOURCE_TYPE_ID%type
			,x_calling_mode	          IN	VARCHAR2
                        ,x_return_status          OUT NOCOPY   VARCHAR2
                        ,x_msg_count              OUT NOCOPY   NUMBER
                        ,x_msg_data               OUT NOCOPY   VARCHAR2 );


FUNCTION budget_ctrl_exists
			(x_project_id 			IN 	PA_PROJECTS_ALL.PROJECT_ID%type
			,x_budget_type_code 		IN 	PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type)
            return varchar2;

FUNCTION budg_control_enabled
            		(x_budget_version_id 		IN	PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%type)
            return varchar2;

FUNCTION get_budget_status
			(p_budget_version_id		IN	PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%type)
	    return varchar2;
end; -- end of Package

 

/
