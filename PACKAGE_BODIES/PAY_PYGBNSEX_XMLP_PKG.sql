--------------------------------------------------------
--  DDL for Package Body PAY_PYGBNSEX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYGBNSEX_XMLP_PKG" AS
/* $Header: PYGBNSEXB.pls 120.3 2007/12/27 11:26:43 srikrish noship $ */

function BeforeReport return boolean is
begin

/* added as fix */

P_EFFECTIVE_DATE_T := P_EFFECTIVE_DATE;
/* fix ends */
declare

begin
 /*srw.user_exit('FND SRWINIT');*/null;

 insert into fnd_sessions (session_id, effective_date)
 select userenv('sessionid'),trunc(sysdate)
 from dual
 where not exists
     (select 1
      from fnd_sessions fs
      where fs.session_id = userenv('sessionid'));
 /*if p_effective_date is null then
 p_effective_date := sysdate;
 end if;*/
 /* replaced the above code with this code */
 if p_effective_date_t is null then
  p_effective_date_t := sysdate;
 end if;
 c_business_group_name := hr_reports.get_business_group(p_business_group_id);
  if p_payroll_id is not null then
  --c_payroll_name := hr_reports.get_payroll_name(p_effective_date,p_payroll_id);
  c_payroll_name := hr_reports.get_payroll_name(p_effective_date_t,p_payroll_id);
  else
  c_payroll_name:= 'All Payrolls';
  end if;


  /*added as fix */
  CP_EFFECTIVE_DATE_T := to_date(P_EFFECTIVE_DATE_T,'DD-MM-YYYY');
  CP_STARTERS_FROM := to_date(P_STARTERS_FROM,'DD-MM-YYYY');
end;  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;
   return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_ORDER_BY_p return varchar2 is
	Begin
	 return C_ORDER_BY;
	 END;
 Function C_HEAD_ORDER_BY_p return varchar2 is
	Begin
	 return C_HEAD_ORDER_BY;
	 END;
 Function C_PAYROLL_NAME_p return varchar2 is
	Begin
	 return C_PAYROLL_NAME;
	 END;
END PAY_PYGBNSEX_XMLP_PKG ;

/
