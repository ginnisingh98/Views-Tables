--------------------------------------------------------
--  DDL for Package Body FII_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_MSG" AS
/* $Header: FIIGLC3B.pls 120.20 2005/06/22 09:22:32 hpoddar noship $ */

  -- Function
  --   get_msg
  --
  -- Purpose
  -- 	Returns string "XTD"
  --
  -- History
  --   22-JUN-02  M Bedekar 	Created
  --

FUNCTION get_msg (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2 IS

   stmt                VARCHAR2(240);
BEGIN

IF fii_gl_util_pkg.g_mgr_id = -99999 THEN


	IF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
        stmt := 'YTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR' THEN
        stmt := 'QTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
        stmt := 'MTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_WEEK' THEN
        stmt := 'WTD';
	END IF;

ELSE

stmt := BIS_PMV_PORTAL_UTIL_PUB.getTimeLevelLabel(p_page_id, p_user_id, p_session_id, p_function_name);

END IF;

RETURN stmt;

END get_msg;

FUNCTION get_msg1 (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2 IS

   stmt                VARCHAR2(240);
BEGIN

IF fii_gl_util_pkg.g_mgr_id = -99999 THEN


	IF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' YTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' QTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' MTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_WEEK' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' WTD';
	END IF;

ELSE

stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' ' ||BIS_PMV_PORTAL_UTIL_PUB.getTimeLevelLabel(p_page_id, p_user_id, p_session_id, p_function_name);
END IF;

RETURN stmt;

END get_msg1;

FUNCTION get_msg2 (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2 IS


   stmt                VARCHAR2(240);
BEGIN

IF fii_gl_util_pkg.g_time_comp = 'BUDGET' THEN
stmt := fnd_message.get_string('FII', 'FII_GL_BUDGET');
ELSIF  fii_gl_util_pkg.g_mgr_id = -99999 THEN


	IF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' YTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' QTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' MTD';
	ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_WEEK' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' WTD';
	END IF;

ELSE
    stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' ' ||BIS_PMV_PORTAL_UTIL_PUB.getTimeLevelLabel(p_page_id, p_user_id, p_session_id, p_function_name);
END IF;

RETURN stmt;

END get_msg2;


FUNCTION get_curr_label RETURN VARCHAR2 IS
stmt VARCHAR2(240);
	BEGIN

	stmt := get_msg3('Y');
	Return stmt;

END get_curr_label;

FUNCTION get_prior_label RETURN VARCHAR2 IS
stmt VARCHAR2(240);
	BEGIN

	stmt := get_msg3('N');
	Return stmt;

END get_prior_label;


FUNCTION get_msg3 ( p_current IN VARCHAR2
)RETURN VARCHAR2 IS
   stmt                VARCHAR2(240);
   l_asof_date         DATE;
   l_week              VARCHAR2(10);
   l_year              VARCHAR2(10);
BEGIN
    IF (p_current = 'Y') THEN
			l_asof_date:=fii_gl_util_pkg.g_as_of_date;
    ELSE
			l_asof_date:=fii_gl_util_pkg.g_previous_asof_date;
    END IF;

IF (fii_gl_util_pkg.g_time_comp = 'BUDGET' AND p_current = 'N') THEN
stmt := fnd_message.get_string('FII', 'FII_GL_BUDGET');
ELSE
    IF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
        select name into stmt
        from fii_time_ent_year
        where l_asof_date between start_date and end_date;
    ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR' THEN
        select name into stmt
        from fii_time_ent_qtr
        where l_asof_date between start_date and end_date;
    ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
        select name into stmt
        from fii_time_ent_period
        where l_asof_date between start_date and end_date;
    ELSIF fii_gl_util_pkg.g_page_period_type = 'FII_TIME_WEEK' THEN
        select to_char(sequence) into l_week
        from fii_time_week
        where l_asof_date between start_date and end_date;

	select substr(week_id,3,2) into l_year
	from fii_time_week
	where l_asof_date between start_date and end_date;

	stmt := fnd_message.get_string('FII', 'FII_AR_WEEK')||' '||l_week||' '||l_year;
    END IF;
END IF;
RETURN stmt;

END get_msg3;


FUNCTION get_curr RETURN VARCHAR2 IS

   stmt                VARCHAR2(240);

BEGIN

select id into stmt from fii_currencies_v where id = 'FII_GLOBAL1';

RETURN stmt;

END get_curr;

FUNCTION get_manager RETURN NUMBER IS

   stmt                NUMBER;

BEGIN

stmt := fnd_global.employee_id;

RETURN stmt;

END get_manager;

FUNCTION get_dbi_params(region_id IN VARCHAR2) RETURN VARCHAR2 IS
     employee_id    NUMBER(10);
     employee_name  VARCHAR2(240);
     currency       FII_CURRENCIES_V.ID%TYPE;
     qtr_id         NUMBER;
  BEGIN
     employee_id := fnd_global.employee_id;
     currency    := 'FII_GLOBAL1';
     qtr_id   := -1;

     IF    (region_id = 'FII_PMV_MGR_PARAMETER_PORTLET') THEN
            RETURN '&'||'AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY')||
                   '&'||'BIS_MANAGER='||employee_id||
                   '&'||'CURRENCY='||currency||
		   '&'||'YEARLY=TIME_COMPARISON_TYPE+YEARLY&PERIOD_QUARTER_FROM='||qtr_id||'&PERIOD_QUARTER_TO='||qtr_id;
     ELSE
            RETURN NULL;
     END IF;

END get_dbi_params;

FUNCTION get_margin_label RETURN VARCHAR2 IS

   stmt                VARCHAR2(240);
BEGIN

IF (fii_gl_util_pkg.g_time_comp = 'BUDGET') THEN
stmt := fnd_message.get_string('FII', 'FII_GL_BUDGET');
ELSE
stmt := fnd_message.get_string('FII', 'FII_GL_PRIOR_MARGIN');
END IF;

RETURN stmt;

END get_margin_label;

END fii_msg;


/
