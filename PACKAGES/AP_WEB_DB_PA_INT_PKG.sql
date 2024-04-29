--------------------------------------------------------
--  DDL for Package AP_WEB_DB_PA_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_PA_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbpas.pls 120.6 2005/11/04 19:16:11 skoukunt noship $ */

/*PA Projects */
---------------------------------------------------------------------------------------------------
SUBTYPE proj_projNum				IS PA_PROJECTS_EXPEND_V.project_number%TYPE;
SUBTYPE proj_projID				IS PA_PROJECTS_EXPEND_V.project_id%TYPE;
SUBTYPE proj_projName				IS PA_PROJECTS_EXPEND_V.project_name%TYPE;
---------------------------------------------------------------------------------------------------

/*PA Tasks */
---------------------------------------------------------------------------------------------------
SUBTYPE tasks_projID				IS PA_TASKS_EXPEND_V.project_id%TYPE;
SUBTYPE tasks_taskID				IS PA_TASKS_EXPEND_V.task_id%TYPE;
SUBTYPE tasks_taskNum				IS PA_TASKS_EXPEND_V.task_number%TYPE;
SUBTYPE tasks_taskName				IS PA_TASKS_EXPEND_V.task_name%TYPE;
---------------------------------------------------------------------------------------------------

-------------------------------------------------------------------
FUNCTION GetProjectInfo(
	p_project_number	IN		proj_projNum,
	p_project_id 		OUT NOCOPY	proj_projID,
	p_project_name  	OUT NOCOPY	proj_projName
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetTaskInfo(
	p_task_num	IN		tasks_taskNum,
	p_proj_id	IN		tasks_projID,
	p_task_id	OUT NOCOPY	tasks_taskID,
	p_task_name     OUT NOCOPY	tasks_taskName
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetProjectNumber(
	p_project_id		IN		proj_projID,
	p_project_number  	OUT NOCOPY	proj_projNum
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetTaskIDByProjID(
	p_project_id  	IN  		tasks_projID,
	p_task_id  	OUT NOCOPY	tasks_taskID
) RETURN BOOLEAN;

--------------------------------------------------------------------------------
FUNCTION GetTaskId(
	p_task_num	IN		tasks_taskNum,
	p_proj_id	IN		tasks_projID,
	p_task_id	OUT NOCOPY	tasks_taskID
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetProjectID(
	p_project_number	IN		proj_projNum,
	p_project_id 		OUT NOCOPY	proj_projID
) RETURN BOOLEAN;

-------------------------------------------------------------------
FUNCTION GetProjectNumber(
	p_project_id 		IN 	proj_projID
) RETURN VARCHAR2;

-------------------------------------------------------------------
FUNCTION GetProjectInfo(
	p_project_id 		IN 		proj_projID,
	p_project_number	OUT NOCOPY	proj_projNum,
	p_project_name  	OUT NOCOPY	proj_projName
) RETURN BOOLEAN;

-------------------------------------------------------------------

END AP_WEB_DB_PA_INT_PKG;


 

/
