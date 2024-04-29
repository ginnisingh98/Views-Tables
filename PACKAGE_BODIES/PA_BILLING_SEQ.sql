--------------------------------------------------------
--  DDL for Package Body PA_BILLING_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_SEQ" AS
/* $Header: PAXISEQB.pls 115.0 99/07/16 15:26:38 porting ship $ */

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

FUNCTION next_eventnum(X2_project_id NUMBER, X2_task_id NUMBER)
	RETURN NUMBER IS
	eventnum NUMBER;
BEGIN
	SELECT max(event_num)
	INTO	eventnum
	FROM	pa_events
	WHERE	project_id = X2_project_id
	AND	nvl(task_id,-1) = nvl(X2_task_id,-1);

	IF (eventnum IS NULL) THEN return 1;
	ELSE return (eventnum + 1);
	END IF;

	EXCEPTION
          WHEN NO_DATA_FOUND THEN
                return 1;
	  WHEN OTHERS THEN
		status := 'Error in next_eventnum function';
                RAISE;
END next_eventnum;


FUNCTION session_id RETURN NUMBER IS

xo_sessionid NUMBER(10):=NULL;
BEGIN
	SELECT userenv('sessionid')
	INTO   xo_sessionid
	FROM	DUAL;

	RETURN xo_sessionid;

	EXCEPTION WHEN OTHERS THEN
		RAISE;
END session_id;

END pa_billing_seq;

/
