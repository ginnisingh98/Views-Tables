--------------------------------------------------------
--  DDL for Package Body PA_PARALLEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PARALLEL" AS
-- $Header: PACPAIUB.pls 115.1 99/08/19 17:41:36 porting ship  $

PROCEDURE PA_PARALLEL_AI_RESTART
(script_name	IN	VARCHAR2,
 worker_number  IN      NUMBER,
 total_workers  IN	NUMBER,
 action		IN      VARCHAR2,
 min_id		IN OUT  NUMBER,
 max_id         IN      NUMBER)
IS

BEGIN

IF ACTION = 'INSERT' THEN

	INSERT INTO PA_PARALLEL_AUTOINSTALL
	(	TABLE_NAME,
		TABLE_MIN_ID,
		TABLE_MAX_ID,
		CREATION_DATE,
		LAST_UPDATE_DATE
	)
	SELECT script_name||'.'||worker_number||'.'||total_workers,
	       min_id,
	       max_id,
	       sysdate,
	       sysdate
	FROM   DUAL
	WHERE  NOT EXISTS
		(SELECT 'row already exists'
		 FROM  PA_PARALLEL_AUTOINSTALL
   		 WHERE TABLE_NAME =
			script_name||'.'||worker_number||'.'||total_workers);

	SELECT 	NVL(TABLE_MIN_ID , 0)
	INTO	min_id
	FROM	PA_PARALLEL_AUTOINSTALL
	WHERE	TABLE_NAME =
			script_name||'.'||worker_number||'.'||total_workers;


ELSIF ACTION = 'UPDATE' THEN

	UPDATE PA_PARALLEL_AUTOINSTALL
	SET
		last_update_date = sysdate,
		TABLE_MIN_ID = least(min_id,max_id)
	WHERE TABLE_NAME =
		script_name||'.'||worker_number||'.'||total_workers;

ELSE
	RAISE_APPLICATION_ERROR (-20000,'Incorrect ACTION argument to
		procedure PA_PARALLEL_AUTOINSTALL_RESTART');

END IF;

END PA_PARALLEL_AI_RESTART;

FUNCTION get_currency( P_org_id IN pa_implementations_all.org_id%TYPE)
   RETURN VARCHAR2
IS

BEGIN

   return( G_Curr_Tab(P_org_id));

EXCEPTION WHEN others THEN
   raise;
END get_currency;
END PA_PARALLEL;

/
