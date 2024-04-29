--------------------------------------------------------
--  DDL for Package Body AMS_DCF_DEFAULT_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DCF_DEFAULT_VALUES" AS
/* $Header: amsvdohb.pls 115.14 2002/04/30 18:08:12 pkm ship        $ */

def_period varchar2(80) := fnd_profile.VALUE('AMS_CAMPAIGN_DEFAULT_CALENDER');
def_quarter varchar2(80) := fnd_profile.VALUE('BIM_IO_QUARTER');
def_year varchar2(80) := fnd_profile.VALUE('BIM_IO_YEAR');

-----------------------------------------------------------
-- PROCEDURE
--    get_events_default_aggregate
--
-- HISTORY
--
------------------------------------------------------------

FUNCTION get_events_aggregate(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
--        SELECT aggregate_by
--	INTO x_return_value
--	FROM BIM_R_EVEN_DIM_SUM_MV
-- 	WHERE rownum < 2;

       x_return_value :='QTR';

        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_events_aggregate;


FUNCTION get_campaigns_aggregate(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
--        SELECT aggregate_by
--	INTO   x_return_value
--	FROM   BIM_R_CAMP_DIM_SUM_MV
--	WHERE  rownum < 2;

        x_return_value:='QTR';

        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_campaigns_aggregate;


FUNCTION get_funds_aggregate(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
--        SELECT aggregate_by
--	INTO   x_return_value
--	FROM   BIM_R_FUND_DIM_SUM_MV
-- 	WHERE  rownum < 2;

       x_return_value :='QTR';

        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_funds_aggregate;


FUNCTION get_campaigns_year(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
        SELECT year
	INTO   x_return_value
	FROM   BIM_R_CAMP_DIM_SUM_MV
 	WHERE  rownum < 2;

        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_campaigns_year;


FUNCTION get_campaigns_quarter(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
        SELECT qtr
	INTO   x_return_value
	FROM   BIM_R_CAMP_DIM_SUM_MV
 	WHERE  rownum < 2;

        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_campaigns_quarter;

FUNCTION get_events_year(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
        SELECT year
	INTO   x_return_value
	FROM   BIM_R_EVEN_DIM_SUM_MV
 	WHERE  rownum < 2;

        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_events_year;



FUNCTION get_events_quarter(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
        SELECT qtr
	INTO   x_return_value
	FROM   BIM_R_EVEN_DIM_SUM_MV
 	WHERE  rownum < 2;

        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_events_quarter;


FUNCTION get_funds_year(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
        --SELECT year
	--INTO   x_return_value
	--FROM   BIM_R_FUND_DIM_SUM_MV
 	--WHERE  rownum < 2;
        x_return_value := 'YEAR';
        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_funds_year;

FUNCTION get_funds_quarter(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN
        --SELECT qtr
	--INTO   x_return_value
	--FROM   BIM_R_FUND_DIM_SUM_MV
 	--WHERE  rownum < 2;

        x_return_value := 'QTR';
        RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_funds_quarter;




FUNCTION get_default_period(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_year varchar2(80);
  x_return_qtr varchar2(80);

BEGIN

      select period_name into x_return_year from gl_periods_v g
       where trunc(SYSDATE) BETWEEN g.start_date AND g.end_date
         AND g.period_set_name = def_period
         AND g.period_type = def_year;

      select period_name into x_return_qtr from gl_periods_v g
       where trunc(SYSDATE) BETWEEN g.start_date AND g.end_date
         AND g.period_set_name = def_period
         AND g.period_type = def_quarter;

        RETURN (x_return_year||'-'||x_return_qtr||'-N');

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_default_period;

FUNCTION get_default_period_inc(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_year varchar2(80);
  x_return_qtr varchar2(80);

BEGIN

      select period_name into x_return_year from gl_periods_v g
       where trunc(SYSDATE) BETWEEN g.start_date AND g.end_date
         AND g.period_set_name = def_period
         AND g.period_type = def_year;

      select period_name into x_return_qtr from gl_periods_v g
       where trunc(SYSDATE) BETWEEN g.start_date AND g.end_date
         AND g.period_set_name = def_period
         AND g.period_type = def_quarter;

        RETURN (x_return_year||'-'||x_return_qtr||'-N-Z');

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_default_period_inc;



FUNCTION get_default_quarter(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN

select period_name into x_return_value from gl_periods_v g
where trunc(SYSDATE) BETWEEN g.start_date AND g.end_date
   AND g.period_set_name = def_period
   AND g.period_type = def_quarter;

   RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_default_quarter;

FUNCTION get_default_year(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN

select period_name into x_return_value from gl_periods_v g
where trunc(SYSDATE) BETWEEN g.start_date AND g.end_date
   AND g.period_set_name = def_period
   AND g.period_type = def_year;

   RETURN (x_return_value);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_default_year;

FUNCTION get_default_period_hom(parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
  x_return_value varchar2(80) ;

BEGIN

select period_name into x_return_value from gl_periods_v g
where trunc(SYSDATE) BETWEEN g.start_date AND g.end_date
   AND g.period_set_name = def_period
   AND g.period_type = def_quarter;

   RETURN (x_return_value||'|QTR');

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;

END get_default_period_hom;



END AMS_DCF_DEFAULT_VALUES;

/
