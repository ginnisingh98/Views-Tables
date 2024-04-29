--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_PARAM_PKG" AS
/* $Header: ISCRGAGB.pls 120.0 2005/05/25 17:33:40 appldev noship $ */

---------------------
-- FUNCTION: get_plan
-- This function will return the plan snapshot id of the first row after 'NA'(None Plan). The view is already
-- sorted by plan run date and plan name.
---------------------

FUNCTION get_plan RETURN NUMBER IS

   stmt 	       NUMBER;

BEGIN
	select id into stmt from isc_plan_snapshot_v where id<>-1 and rownum<2;
	RETURN stmt;

END get_plan;


----------------------------
-- Function: get_plan_currency
-- This function returns the DBI Global currency code
----------------------------

FUNCTION get_plan_currency RETURN VARCHAR2 IS

   stmt 	       VARCHAR2(20);


BEGIN

	RETURN 'FII_GLOBAL1';

END get_plan_currency;

----------------------------
-- Function: get_plan_period
-- This function returns the current period
----------------------------

FUNCTION get_plan_period RETURN NUMBER IS

   stmt 	       NUMBER;


BEGIN

	select ent_period_id into stmt from fii_time_ent_period where sysdate between start_date and end_date;

	RETURN stmt;

END get_plan_period;

----------------------
-- Function: a
-- This function returns the earliest data start date of all plans.
---------------------

FUNCTION a RETURN DATE IS

  l_return_date date;

BEGIN

  	select min(data_start_date) into l_return_date from isc_dbi_plan_snapshots;

  	RETURN l_return_date;

END a;

-----------------
-- Function: b
-- This function returns the latest data end date of all plans.
------------------

FUNCTION b RETURN DATE IS

  l_return_date DATE;

BEGIN

  select max(cutoff_date) into l_return_date from isc_dbi_plan_snapshots;

  RETURN l_return_date;

END b;


--------------------------------
-- Function: get_page_params
-- This function returns all default parameter value for Plan
-- Mgmt page parameter portlet.
---------------------------------
FUNCTION get_page_params RETURN VARCHAR2 IS

  l_plan	NUMBER;
  l_currency	VARCHAR(20);
  l_cur_period  NUMBER;

  BEGIN
	l_plan:= ISC_DBI_PLAN_PARAM_PKG.get_plan;
	select ent_period_id into l_cur_period from fii_time_ent_period where trunc(sysdate) between start_date and end_date;

	RETURN '&PLAN_SNAPSHOT='||l_plan||
		'&PLAN_SNAPSHOT_2=-1'||
		'&TIME+FII_TIME_ENT_PERIOD_FROM='||l_cur_period||'&TIME+FII_TIME_ENT_PERIOD_TO='||l_cur_period||
		'&ORGANIZAT_D1=All'||
		'&FII_CURRENCIES=FII_GLOBAL1';


END get_page_params;



END ISC_DBI_PLAN_PARAM_PKG ;


/
