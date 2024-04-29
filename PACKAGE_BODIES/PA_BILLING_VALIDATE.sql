--------------------------------------------------------
--  DDL for Package Body PA_BILLING_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_VALIDATE" AS
/* $Header: PAXIVLDB.pls 115.0 99/07/16 15:27:22 porting ship $ */

---------------------
--  GLOBALS
--
status			VARCHAR2(240);     -- For error messages from subprogs
last_updated_by		NUMBER(15);	   --|
created_by   		NUMBER(15);        --|
last_update_login	NUMBER(15);        --|Standard Who Columns
request_id		NUMBER(15);        --|
program_application_id	NUMBER(15);        --|
program_id		NUMBER(15);        --|

------------------------
--  PROCEDURES AND FUNCTIONS
--
--

FUNCTION automatic_event (X2_event_type VARCHAR2)
	 RETURN BOOLEAN IS
	is_automatic 	BOOLEAN;
	classification  VARCHAR2(30);
BEGIN
	SELECT  event_type_classification
	INTO	classification
	FROM	pa_event_types
	WHERE	event_type = X2_event_type;

	IF (classification = 'AUTOMATIC') THEN
		is_automatic := TRUE;
	ELSE
		is_automatic := FALSE;
	END IF;

	return is_automatic;

	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		status := 'Not a valid event type';
		return FALSE;
	  WHEN OTHERS THEN
		status := 'Error in automatic_event function';
		return FALSE;
END automatic_event;


FUNCTION valid_proj_task_extn (X2_project_id NUMBER, X2_top_task_id NUMBER,
			X2_billing_assignment_id NUMBER)
	RETURN BOOLEAN IS
	dummy	VARCHAR2(30);
BEGIN
	SELECT 	'Valid Proj/Task/Assgn'
	INTO	dummy
	FROM	pa_tasks t, pa_projects p
	WHERE	t.project_id = X2_project_id
	AND	t.top_task_id = nvl(X2_top_task_id, t.top_task_id)
	AND	t.project_id = p.project_id
	AND	rownum = 1;

	return TRUE;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		return FALSE;
END valid_proj_task_extn;


FUNCTION valid_organization (X2_organization_id	NUMBER)
	RETURN BOOLEAN IS
	dummy	VARCHAR2(30);
BEGIN
	SELECT 	'Valid Org'
	INTO	dummy
	FROM	hr_organization_units
	WHERE	organization_id = X2_organization_id;

	return TRUE;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		return FALSE;
END valid_organization;

END pa_billing_validate;

/
