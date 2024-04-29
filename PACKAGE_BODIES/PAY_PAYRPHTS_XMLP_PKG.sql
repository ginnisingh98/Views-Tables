--------------------------------------------------------
--  DDL for Package Body PAY_PAYRPHTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYRPHTS_XMLP_PKG" AS
/* $Header: PAYRPHTSB.pls 120.0 2008/01/11 07:08:06 srikrish noship $ */

function BeforeReport return boolean is
  l_trace_value varchar2(10);
begin

P_Status_1 := NVL(P_STATUS,'DISABLED');
P_Detail_1 := NVL(P_Detail,'Y');

--hr_standard.event('BEFORE REPORT');

 insert into fnd_sessions (session_id,
                          effective_date)
 select userenv('sessionid'),
              trunc(sysdate)
 from sys.dual
 where not exists
      (select 1
       from   fnd_sessions fs
       where  fs.session_id = userenv('sessionid'));
BEGIN
	SELECT parameter_value
	INTO l_trace_value
	FROM pay_action_parameters
	WHERE parameter_name = 'TRACE';

	IF l_trace_value = 'Y' THEN
		/*srw.do_sql('ALTER SESSION SET SQL_TRACE TRUE');*/null;

	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			null;
END;
  return (TRUE);
end;

function AfterReport return boolean is
begin
 -- hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

function cf_count_trigger_nameformula(CS_COUNT_TRIGGER_NAME in number) return number is
begin
  CP_COUNT_TRIGGER_NAME := CS_COUNT_TRIGGER_NAME;
  return 1;
end;

function CF_ENABLED_FLAGFormula return Char is
begin
declare
v_meaning VARCHAR2(80);
begin
select meaning
into v_meaning
from hr_lookups
where lookup_type = 'TRIGGER_STATUS'
and lookup_code = P_STATUS_1;

CP_STATUS := v_meaning;

return CP_STATUS;
end;
end;

--Functions to refer Oracle report placeholders--

 Function CP_COUNT_TRIGGER_NAME_p return number is
	Begin
	 return CP_COUNT_TRIGGER_NAME;
	 END;
 Function CP_STATUS_p return varchar2 is
	Begin
	 return CP_STATUS;
	 END;
END PAY_PAYRPHTS_XMLP_PKG ;

/
