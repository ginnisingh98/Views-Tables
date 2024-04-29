--------------------------------------------------------
--  DDL for Package Body SSP_SSPRPOAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_SSPRPOAR_XMLP_PKG" AS
/* $Header: SSPRPOARB.pls 120.1 2007/12/24 14:06:24 amakrish noship $ */

function BeforeReport return boolean is
begin

begin
   /*srw.user_exit('FND SRWINIT');*/null;

c_business_group_name := hr_reports.get_business_group(p_bus_grp);

  if P_payroll is not null then
     Select distinct payroll_name into c_payroll_name
     from Pay_payrolls_f
     where payroll_id = P_payroll  ;
  end if;
  fnd_date.initialize('YYYY/MM/DD', null);
Exception
When Others then
 null;
end;
  return (TRUE);
end;

function end_report(c_report_tot in number) return varchar2 is
a varchar2(25);
begin
If c_report_tot = 0 then
--   a := '*** No Data Found ***';
     a := 'No Data Found';
else
--   a := '*** End of Report ***';
     a := 'End of Report';
end if;
return(a);
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
 Function C_PAYROLL_NAME_p return varchar2 is
	Begin
	 return C_PAYROLL_NAME;
	 END;
END SSP_SSPRPOAR_XMLP_PKG ;

/
