--------------------------------------------------------
--  DDL for Package Body SSP_SSPRPWKS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_SSPRPWKS_XMLP_PKG" AS
/* $Header: SSPRPWKSB.pls 120.1 2007/12/24 14:08:01 amakrish noship $ */

--Added during DT Fix

procedure Fetch_Payroll_name is

cursor payroll_name_cursor is

    select PAYROLL_NAME
    from pay_payrolls_x
    where PAYROLL_ID = P_PAYROLL;


begin
    open payroll_name_cursor;
    fetch payroll_name_cursor into C_PAYROLL_NAME;
    close payroll_name_cursor;
end Fetch_Payroll_name;

procedure Fetch_Business_group_name is
begin

    c_business_group_name :=
     hr_reports.get_business_group(p_business_group_id);
end Fetch_Business_group_name;

--End of DT Fix

function BeforeReport return boolean is
begin

begin

 /*srw.user_exit('FND SRWINIT');*/null;

/*
Below lines commented during DT Fixes
 ssprpelr.Fetch_Business_group_name;
ssprpelr.Fetch_Payroll_name;

End of commenting */

--Added below lines during DT Fix
Fetch_Business_group_name;
Fetch_Payroll_name;
--End of DT Fix

if P_PAYROLL is not null then
   L_PAYROLL_ID := 'and O_pas.PAYROLL_ID + 0 = '||to_char(P_PAYROLL);
else
   L_PAYROLL_ID :=null;
end if;
fnd_date.initialize('YYYY/MM/DD',null);

--Added below lines during DT Fix
if L_PAYROLL_ID is null then
L_PAYROLL_ID := ' ';
end if;
--End of DT Fix

LP_SESSION_DATE:=P_SESSION_DATE;
end;  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT') ;*/null;
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
END SSP_SSPRPWKS_XMLP_PKG ;

/
