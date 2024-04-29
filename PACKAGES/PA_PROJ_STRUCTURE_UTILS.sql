--------------------------------------------------------
--  DDL for Package PA_PROJ_STRUCTURE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_STRUCTURE_UTILS" AUTHID CURRENT_USER as
/* $Header: PAXSTRUS.pls 120.3 2007/02/06 10:23:59 dthakker ship $ */

-- Bug Fix 5611909. Creating global variables to cache the project id and budget version id.
-- These will be used in the program unit Get_All_Wbs_Rejns and these will be set by using
-- the set_budget_version_id_global procedure.
-- NOTE: PLEASE DO NOT MODIFY THESE ANYWHERE ELSE OR USING ANY OTHER MEANS.

G_PROJECT_ID NUMBER := NULL;
G_BUDGET_VERSION_ID  NUMBER := NULL;

procedure CHECK_LOOPED_PROJECT(
	p_api_version				IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit						IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode				IN		VARCHAR2	:= 'N',
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER,
	x_return_status			OUT		NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count					OUT		NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data					OUT		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

procedure CHECK_MERGED_PROJECT(
	p_api_version				IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit						IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode				IN		VARCHAR2	:= 'N',
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER,
	x_return_status			OUT		NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count					OUT		NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data					OUT		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

function CHECK_PROJECT_CONTRACT_EXISTS(
	p_project_id				IN		NUMBER
)
return VARCHAR2;

function CHECK_TASK_CONTRACT_EXISTS(
	p_task_id						IN		NUMBER
)
return VARCHAR2;

function IS_WF_ENABLED_FOR_STRUCTURE(
	p_project_id			IN		NUMBER
    ,p_structure_type		IN		VARCHAR2
)
return VARCHAR2;

function Get_All_Wbs_Rejns(
p_project_id                   IN Number,
p_calling_mode                 IN Varchar2 Default 'PROJ_STR_VER',
p_proj_str_version_id          IN Number,
p_Task_str_version_id          IN Number   Default Null,
p_start_date                   IN Date     Default Null,
p_end_date                     IN Date     Default Null
)
return VARCHAR2;

function CHECK_STR_TEMP_TAB_POPULATED(p_project_id NUMBER) RETURN VARCHAR2;
function CHECK_PJI_TEMP_TAB_POPULATED(p_project_id NUMBER) RETURN VARCHAR2;

-- Bug Fix 5611909
-- Added a new procedure to set the globals in order to cache the budget
-- version id.

PROCEDURE set_budget_version_id_global(p_project_id IN NUMBER,
                                       p_budget_version_id IN NUMBER);

end PA_PROJ_STRUCTURE_UTILS;

/
