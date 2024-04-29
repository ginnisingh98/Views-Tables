--------------------------------------------------------
--  DDL for Package Body PA_BILLING_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_VALUES" AS
/* $Header: PAXIVALB.pls 120.2 2005/08/19 17:15:12 mwasowic noship $ */

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


FUNCTION funding_level(X2_project_id NUMBER)
	RETURN VARCHAR2 IS
	funding	VARCHAR2(12) := 'NO FUNDING';
BEGIN
	SELECT decode(project_level_funding_flag,
			'Y', 'PROJECT',
			'N','TASK',
			'NO FUNDING')
	INTO	funding
	FROM	pa_projects
	WHERE	project_id = X2_project_id;

	return funding;
END funding_level;

FUNCTION get_dflt_org(X2_project_id NUMBER, X2_top_task_id NUMBER)
	RETURN NUMBER IS
	XO_organization_id	NUMBER(15);
BEGIN
	IF (X2_top_task_id IS NULL) THEN
		SELECT 	p.carrying_out_organization_id
		INTO	XO_organization_id
		FROM	pa_projects p
		WHERE	p.project_id = X2_project_id;
	ELSE
		SELECT 	t.carrying_out_organization_id
		INTO	XO_organization_id
		FROM	pa_tasks t
		WHERE	t.task_id = X2_top_task_id;
	END IF;

	return XO_organization_id;
EXCEPTION
	WHEN OTHERS THEN
		/* DBMS_OUTPUT.PUT(SQLERRM); */
		RAISE;
END get_dflt_org;


PROCEDURE get_dflt_desc(X2_billing_assignment_id NUMBER,
			X2_event_type  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X2_event_description  OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895

XO_event_description 	VARCHAR2(240);
XO_event_type		VARCHAR2(30);
BEGIN
	SELECT  be.default_event_description, be.default_event_type
	INTO	XO_event_description, XO_event_type
	FROM	pa_billing_extensions be,
		pa_billing_assignments bea
	WHERE	bea.billing_assignment_id = X2_billing_assignment_id
	AND	bea.billing_extension_id = be.billing_extension_id;

X2_event_description := XO_event_description;
X2_event_type := XO_event_type;

END get_dflt_desc;

FUNCTION get_message(X2_message_code VARCHAR2)
	RETURN VARCHAR2 IS

message	VARCHAR2(240);

BEGIN
	SELECT meaning
	INTO   message
	FROM   pa_lookups
	WHERE  lookup_type = 'BILLING EXTENSION MESSAGES'
	AND    lookup_code = X2_message_code;

	RETURN message;

EXCEPTION WHEN OTHERS THEN
	  /* DBMS_OUTPUT.PUT(SQLERRM); */
	  RAISE;
END get_message;


END pa_billing_values;

/
