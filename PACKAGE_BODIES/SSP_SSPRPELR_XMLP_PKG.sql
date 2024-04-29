--------------------------------------------------------
--  DDL for Package Body SSP_SSPRPELR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_SSPRPELR_XMLP_PKG" AS
/* $Header: SSPRPELRB.pls 120.1 2007/12/24 14:05:21 amakrish noship $ */

function BeforeReport return boolean is
begin
DECLARE
  P_SORT boolean;
 BEGIN
  /*srw.user_exit('FND SRWINIT');*/null;
 P_SORT := P_SORT_OPTIONValidTrigger;
  C_SORT_OPTION := P_SORT_OPTION;

  select payroll_name
  into c_payroll_name
  from pay_payrolls_x
  where payroll_id = p_payroll_id;

  c_business_group_name :=
     hr_reports.get_business_group(p_business_group_id);

	select ptp.period_name
	into c_time_period_name
	from per_time_periods ptp
	where ptp.time_period_id = p_time_period_id;

  select pcs.consolidation_set_name
  into c_consolidation_set_name
  from pay_consolidation_sets pcs
  where pcs.consolidation_set_id = p_consolidation_set;

 EXCEPTION WHEN NO_DATA_FOUND THEN null;
 END;
return (TRUE);
end;

function P_SORT_OPTIONValidTrigger return boolean is
begin

P_SORT_OPTION_1 := Derive_sort_criteria;  return (TRUE);
end;
function Derive_sort_criteria return varchar2 is
begin
 if P_SORT_OPTION = 'Assignment Number' then
    return( 'Order By assignment_number');
 elsif  P_SORT_OPTION = 'Employee Name' then
    return( 'Order By  employee_name,assignment_number');
 else
     return( 'Order By assignment_number');
 end if;

RETURN NULL; end Derive_sort_criteria;

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
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_PAYROLL_NAME_p return varchar2 is
	Begin
	 return C_PAYROLL_NAME;
	 END;
 Function C_CONSOLIDATION_SET_NAME_p return varchar2 is
	Begin
	 return C_CONSOLIDATION_SET_NAME;
	 END;
 Function C_TIME_PERIOD_NAME_p return varchar2 is
	Begin
	 return C_TIME_PERIOD_NAME;
	 END;
 Function C_SORT_OPTION_p return varchar2 is
	Begin
	 return C_SORT_OPTION;
	 END;
END SSP_SSPRPELR_XMLP_PKG ;

/
