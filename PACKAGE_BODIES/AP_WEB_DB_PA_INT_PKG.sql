--------------------------------------------------------
--  DDL for Package Body AP_WEB_DB_PA_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DB_PA_INT_PKG" AS
/* $Header: apwdbpab.pls 120.6 2005/11/04 19:16:36 skoukunt noship $ */

/* PA Integration */
-------------------------------------------------------------------
FUNCTION GetProjectNumber(
	p_project_id		IN		proj_projID,
	p_project_number  	OUT NOCOPY	proj_projNum
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
   select PROJECT_NUMBER
   into   p_project_number
   from   PA_PROJECTS_EXPEND_V
   where  PROJECT_ID = p_project_id;

   RETURN TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetProjectNumber' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetProjectNumber;

-------------------------------------------------------------------
FUNCTION GetProjectInfo(
	p_project_number	IN		proj_projNum,
	p_project_id 		OUT NOCOPY	proj_projID,
	p_project_name  	OUT NOCOPY	proj_projName
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  select PROJECT_ID, PROJECT_NAME
  into   p_project_id, p_project_name
  from   PA_PROJECTS_EXPEND_V
  where  PROJECT_NUMBER = p_project_number;

  RETURN TRUE;
EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetProjectInfo' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetProjectInfo;

-------------------------------------------------------------------
FUNCTION GetTaskInfo(
	p_task_num	IN		tasks_taskNum,
	p_proj_id	IN		tasks_projID,
	p_task_id	OUT NOCOPY	tasks_taskID,
	p_task_name     OUT NOCOPY	tasks_taskName
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
	SELECT	task_id, task_name
	INTO	p_task_id, p_task_name
	FROM	pa_tasks_expend_v
	WHERE	project_id = p_proj_id
	AND	task_number = p_task_num;

	return TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTaskInfo' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetTaskInfo;

-------------------------------------------------------------------
FUNCTION GetTaskIDByProjID(
	p_project_id  	IN  		tasks_projID,
	p_task_id  	OUT NOCOPY	tasks_taskID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  select TASK_ID
  into   p_task_id
  from   PA_TASKS_EXPEND_V
  where  PROJECT_ID = p_project_id;

  return TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTaskIDByProjID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetTaskIDByProjID;


--------------------------------------------------------------------------------
FUNCTION GetTaskId(
	p_task_num	IN		tasks_taskNum,
	p_proj_id	IN		tasks_projID,
	p_task_id	OUT NOCOPY	tasks_taskID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
	SELECT	task_id
	INTO	p_task_id
	FROM	pa_tasks_expend_v
	WHERE	project_id = p_proj_id
	AND	task_number = p_task_num;

	return TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetTaskId' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetTaskId;


-------------------------------------------------------------------
FUNCTION GetProjectID(
	p_project_number	IN		proj_projNum,
	p_project_id 		OUT NOCOPY	proj_projID
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  select PROJECT_ID
  into   p_project_id
  from   PA_PROJECTS_EXPEND_V
  where  PROJECT_NUMBER = p_project_number;

  RETURN TRUE;
EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetProjectID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetProjectID;

-------------------------------------------------------------------
FUNCTION GetProjectNumber(
	p_project_id 		IN 	proj_projID
) RETURN VARCHAR2 IS
-------------------------------------------------------------------
 l_project_number  PA_PROJECTS_ALL.segment1%type;
BEGIN
  select segment1 --project number
  into   l_project_number
  from   PA_PROJECTS_ALL
  where  project_id = p_project_id;

  RETURN l_project_number;
EXCEPTION

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetProjectNumber' );
    		APP_EXCEPTION.RAISE_EXCEPTION;

END GetProjectNumber;

-------------------------------------------------------------------
FUNCTION GetProjectInfo(
	p_project_id 		IN 		proj_projID,
	p_project_number	OUT NOCOPY	proj_projNum,
	p_project_name  	OUT NOCOPY	proj_projName
) RETURN BOOLEAN IS
-------------------------------------------------------------------
BEGIN
  select segment1, name
  into   p_project_number, p_project_name
  from   pa_projects_all
  where  project_id = p_project_id;

  RETURN TRUE;
EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		AP_WEB_DB_UTIL_PKG.RaiseException( 'GetProjectInfo' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetProjectInfo;

END AP_WEB_DB_PA_INT_PKG;

/
