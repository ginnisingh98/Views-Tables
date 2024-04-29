--------------------------------------------------------
--  DDL for Package Body GL_GLXCLVAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXCLVAL_XMLP_PKG" AS
/* $Header: GLXCLVALB.pls 120.0 2007/12/27 14:49:53 vijranga noship $ */
function first_period_numformula(periodset in varchar2, periodtype in varchar2, first_period_year in number) return number is
  first_period_num NUMBER;
  dummy NUMBER;
begin
  SELECT period_year, min(period_num)
  INTO   dummy, first_period_num
  FROM   gl_periods
  WHERE
         period_set_name = periodset
  AND    period_type = periodtype
  AND    period_year = first_period_year
  GROUP BY period_year;
  -- raise appplication error created by atul
  --R(first_period_num);
  return(first_period_num);
end;
function max_num_periodformula(periodtype1 in varchar2) return number is
--function max_num_periodformula(periodtype in varchar2) return number is
   max_period NUMBER;
--   user_period_type VARCHAR2(30);
   user_period_type1 VARCHAR2(30);
begin
  SELECT number_per_fiscal_year, user_period_type
  --INTO   max_period, user_period_type
  INTO   max_period, user_period_type1
  FROM   gl_period_types
  WHERE
         period_type = periodtype1;
-- user_period_type := user_period_type;
   user_period_type := user_period_type1;
  return(max_period);
end;
function last_cal_yearformula(periodset in varchar2, periodtype in varchar2) return number is
   max_year NUMBER;
begin
  SELECT max(period_year)
  INTO   max_year
  FROM   gl_periods
  WHERE
         period_set_name = periodset
  AND    period_type = periodtype;
  return(max_year);
end;
function date_lowformula(periodset in varchar2, periodtype in varchar2) return varchar2 is
   date_low date;
begin
   IF (P_start_year is NULL)  THEN
       date_low := to_date('1000/01/01','YYYY/MM/DD');
   ELSE
        SELECT
          max(end_date)
        INTO date_low
        FROM gl_periods
        WHERE  period_set_name = periodset
        AND    period_type     = periodtype
        AND    period_year < P_start_year
        ;
        IF (date_low is NULL) THEN
           SELECT min(start_date)
           INTO date_low
           FROM  gl_periods
           WHERE  period_set_name = periodset
           AND    period_type     = periodtype
           AND    period_year = P_start_year;
         END IF;
        IF (date_low is NULL) THEN
           date_low := to_date('1000/01/01','YYYY/MM/DD');
        END IF;
  END IF;
  return(to_char(date_low,'YYYY/MM/DD'));
end;
function date_highformula(periodset in varchar2, periodtype in varchar2) return varchar2 is
   date_high date;
begin
   IF (P_end_year is NULL)  THEN
       date_high := to_date('2999/12/31','YYYY/MM/DD');
   ELSE
        SELECT
             min(start_date)
        INTO date_high
        FROM gl_periods
        WHERE  period_set_name = periodset
        AND    period_type     = periodtype
        AND    period_year > P_end_year
        ;
        IF (date_high is NULL) THEN
           SELECT max(end_date)
           INTO date_high
           FROM  gl_periods
           WHERE  period_set_name = periodset
           AND    period_type     = periodtype
           AND    period_year = P_end_year;
         END IF;
        IF (date_high is NULL) THEN
            date_high := to_date('2999/12/31','YYYY/MM/DD');
        END IF;
  END IF;
  return(to_char(date_high,'YYYY/MM/DD'));
end;
function first_period_yearformula(periodset in varchar2, periodtype in varchar2, first_period_date in varchar2) return number is
  first_period_year NUMBER;
begin
  SELECT min(period_year)
  INTO   first_period_year
  FROM   gl_periods
  WHERE
         period_set_name = periodset
  AND    period_type = periodtype
  AND    start_date = to_date(first_period_date,'YYYY/MM/DD');
  return(first_period_year);
end;
function min_quarter2formula(first_period_year in number, periodset in varchar2, periodtype in varchar2, period_year_qg in number) return number is
   min_quarter  NUMBER(15);
begin
  SELECT min(decode(p.period_year,
                    first_period_year, p.quarter_num, 1))
  INTO   min_quarter
  FROM   gl_periods p
  WHERE  p.period_set_name = periodset
  AND    p.period_type     = periodtype
  AND    p.period_year     = period_year_qg;
  return(min_quarter);
end;
function max_quarter2formula(periodset in varchar2, periodtype in varchar2, period_year_qg in number) return number is
   max_quarter  NUMBER(15);
begin
  SELECT max(p.quarter_num)
  INTO   max_quarter
  FROM   gl_periods p
  WHERE  p.period_set_name = periodset
  AND    p.period_type     = periodtype
  AND    p.period_year     = period_year_qg;
  return(max_quarter);
end;
function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
    TOTAL_VIOLATIONS := 0;
  PREV_PS := '';
  PREV_PT := '';
  return (TRUE);
end;
function AfterReport return boolean is
  ExecVal BOOLEAN;
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  if (TOTAL_VIOLATIONS > 0) then
    ExecVal := FND_CONCURRENT.set_completion_status('WARNING', '');
  end if;
  return (TRUE);
end;
function count_violation_qgformula(Num_Miss_Quarter_qg in number, max_quarter_qg in number) return number is
    violation NUMBER(10);
begin
    IF (Num_Miss_Quarter_qg = 0
      AND max_quarter_qg IS NOT NULL) THEN
         violation := 0;
    ELSE
         violation := 1;
    END IF;
    return(violation);
end;
function user_period_typeFormula return VARCHAR2 is
begin
     return(user_period_type);
end;
--procedure gl_increment_violation_count (num number) is
procedure gl_increment_violation_count (num number , periodset varchar2) is
BEGIN
  TOTAL_VIOLATIONS := TOTAL_VIOLATIONS + num;
  PREV_PS := periodset;
  PREV_PT := user_period_type;
END;
--Functions to refer Oracle report placeholders--
 Function user_period_type_p return varchar2 is
	Begin
	 return user_period_type;
	 END;
 Function PREV_PS_p return varchar2 is
	Begin
	 return PREV_PS;
	 END;
 Function PREV_PT_p return varchar2 is
	Begin
	 return PREV_PT;
	 END;
 Function TOTAL_VIOLATIONS_p return number is
	Begin
	 return TOTAL_VIOLATIONS;
	 END;
END GL_GLXCLVAL_XMLP_PKG ;


/
