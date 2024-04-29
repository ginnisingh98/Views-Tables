--------------------------------------------------------
--  DDL for Package Body PAY_PYGBNICV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYGBNICV_XMLP_PKG" AS
/* $Header: PYGBNICVB.pls 120.2 2007/12/27 05:27:24 amakrish noship $ */


function BeforeReport return boolean is
begin

  /*srw.user_exit('FND SRWINIT');*/null;


  c_payroll_name := hr_reports.get_payroll_name(sysdate,p_payroll_name);

  c_business_group_name :=
     hr_reports.get_business_group(p_business_group_id);

  p_sort := ' ORDER BY ' || p_sort_order;

  begin
    select consolidation_set_name
    into   c_consolidation_set
    from   pay_consolidation_sets
    where  consolidation_set_id = p_consolidation_set;
  exception
  when no_data_found then
    null;
  end;

  begin
    select assignment_set_name
    into   c_assignment_set
    from   hr_assignment_sets
    where  assignment_set_id = p_assignment_set;
  exception
  when no_data_found then
    null;
  end;
LP_EFFECTIVE_DATE := P_EFFECTIVE_DATE;
  return (TRUE);

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
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_PAYROLL_NAME_p return varchar2 is
	Begin
	 return C_PAYROLL_NAME;
	 END;
 Function C_CONSOLIDATION_SET_p return varchar2 is
	Begin
	 return C_CONSOLIDATION_SET;
	 END;
 Function C_ASSIGNMENT_SET_p return varchar2 is
	Begin
	 return C_ASSIGNMENT_SET;
	 END;
END PAY_PYGBNICV_XMLP_PKG ;

/
