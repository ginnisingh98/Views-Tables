--------------------------------------------------------
--  DDL for Package Body PJI_CURR_REP_PERIODS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_CURR_REP_PERIODS_UTIL" AS
/* $Header: PJIRX19B.pls 120.0 2005/07/11 07:36 mogupta noship $ */

g_debug_mode VARCHAR2(1) := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');
g_proc NUMBER :=5;

-- -----------------------------------------------------------------
-- Setup Current Reporting Periods
-- -----------------------------------------------------------------

PROCEDURE update_curr_rep_periods(
	p_pa_curr_rep_period 	VARCHAR2,
	p_gl_curr_rep_period 	VARCHAR2,
	p_ent_curr_rep_period	VARCHAR2,
	p_org_id NUMBER
) AS

-- ----------------------------------------------
-- declare statements --

l_org_id_count		NUMBER := 0;
l_ent_period_count	NUMBER := 0;
l_org_id NUMBER;

-- ----------------------------------------------

BEGIN
-- ----------------------------------------------
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'update_curr_rep_periods: begining', TRUE , g_proc);
	END IF;

-- check if pji_org_extr_info table has a record for p_org_id
-- Count funtion is introduced
SELECT 	COUNT(info.org_id)
INTO	l_org_id_count
FROM	pji_org_extr_info info
WHERE 	1=1
AND     info.org_id = p_org_id;


IF	l_org_id_count = 0
THEN

	-- insert p_org_id, pa_curr_rep_period and gl_curr_rep_period (everything else is null)

	INSERT
	INTO	pji_org_extr_info
		(
		 org_id,
		 pa_curr_rep_period,
		 gl_curr_rep_period
		)
	VALUES
		(
		--NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99),
		p_org_id,
		 p_pa_curr_rep_period,
		 p_gl_curr_rep_period
		);
ELSE

	-- update pa_curr_rep_period and gl_curr_rep_period

	UPDATE 	pji_org_extr_info
	SET	pa_curr_rep_period = p_pa_curr_rep_period,
	 	gl_curr_rep_period = p_gl_curr_rep_period
	--WHERE	org_id = NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99);
	WHERE org_id = p_org_id;
END IF;

-- ----------------------------------------------
--Count funtion is introduced
SELECT 	COUNT(params.name)
INTO	l_ent_period_count
FROM	pji_system_parameters params
WHERE 	1=1
AND 	params.name = 'PJI_PJP_ENT_CURR_REP_PERIOD';

IF	l_ent_period_count = 0
THEN

	INSERT
	INTO	pji_system_parameters
		(
		 name,
		 value
		)
	VALUES
		(
		 'PJI_PJP_ENT_CURR_REP_PERIOD',
		 p_ent_curr_rep_period
		);
ELSE

	UPDATE 	pji_system_parameters
	SET 	value = p_ent_curr_rep_period
	WHERE 	name = 'PJI_PJP_ENT_CURR_REP_PERIOD';



END IF;


-- ----------------------------------------------

COMMIT;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'update_curr_rep_periods: finishing', TRUE , g_proc);
	END IF;


END update_curr_rep_periods;

-- -----------------------------------------------------------------

END Pji_Curr_Rep_Periods_Util;

/
