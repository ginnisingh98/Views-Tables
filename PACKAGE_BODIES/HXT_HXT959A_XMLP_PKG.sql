--------------------------------------------------------
--  DDL for Package Body HXT_HXT959A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT959A_XMLP_PKG" AS
/* $Header: HXT959AB.pls 120.0 2007/12/03 11:43:55 amakrish noship $ */

function cf_tot_varformula(STANDARD_START in number, TIME_IN in date) return varchar2 is


   CF_RET  VARCHAR2 (20);
   CF_DATE_WORKED_TIME  VARCHAR2(20);
   CF_DATE1  DATE;
   CF_DATE2  DATE;
   CF_DATE3  DATE;


begin


  IF (STANDARD_START is not null) AND (TIME_IN is not null) THEN
    CF_DATE1 := to_date('01-01-1900 '||to_char(TIME_IN, 'HH24MI'), 'DD-MM-YYYY HH24MI');
    CF_DATE2 := to_date('01-01-1900 '||to_char(STANDARD_START,'0009'),  'DD-MM-YYYY HH24MI');

    CF_RET := reset_hours(CF_DATE1, CF_DATE2);
    if (to_number(CF_RET) = 0) then
      return (NULL);
    else
      return (CF_RET);
    end if;
  else
    return (NULL);
  end if;

RETURN NULL; end;

function cf_l_vlformula(STANDARD_START in number, TIME_IN in date) return varchar2 is

   CF_RET  VARCHAR2 (20);
   CF_RET_NUM  NUMBER;
   CF_DATE_WORKED_TIME  VARCHAR2(20);
   CF_DATE1  DATE;
   CF_DATE2  DATE;
   CF_DATE3  DATE;


begin



  IF (STANDARD_START is not null) AND (TIME_IN is not null) THEN
    CF_DATE1 := to_date('01-01-1900 '||to_char(TIME_IN, 'HH24MI'), 'DD-MM-YYYY HH24MI');
    CF_DATE2 := to_date('01-01-1900 '||to_char(STANDARD_START,'0009'),  'DD-MM-YYYY HH24MI');

    CF_RET := reset_hours(CF_DATE1, CF_DATE2);
    CF_RET_NUM := to_number (CF_RET);
    if (CF_RET_NUM >= 0) then
      return (NULL);
    end if;
    if (CF_RET_NUM < 0) and (CF_RET_NUM > -.25) then
      return ('L');
    end if;
    if (CF_RET_NUM <= -.25) then
      return ('VL');
    end if;
  else
    return (NULL);
  end if;

RETURN NULL; end;

FUNCTION Reset_Hours ( p_in DATE, p_out DATE) RETURN VARCHAR2 IS

  l_diff	NUMBER;


BEGIN

    IF (p_in is not null) AND (p_out is not null) THEN

        l_diff := (p_out - p_in) * 24;
     return to_char(l_diff,'90.000');
  else
    return (NULL);

  END IF;

RETURN NULL; END;

function CF_Payroll_typeFormula return VARCHAR2 is
 payroll  VARCHAR2(80);

begin
 select  pay.payroll_name
 into    payroll
from pay_payrolls_f pay
where pay.payroll_id = p_payroll_id;
return payroll;
/*exception
when no_data_found then
payroll:=null;

 return payroll;
*/
end;

function BeforeReport return boolean is
begin
 /*SRW.USER_EXIT('FND SRWINIT');*/null;

  if start_date is null then
     start_date := hr_general.start_of_time;
  end if;
  if end_date is null then
     end_date := hr_general.end_of_time;
  end if;
  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT959A_XMLP_PKG ;

/
