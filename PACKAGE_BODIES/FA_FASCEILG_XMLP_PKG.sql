--------------------------------------------------------
--  DDL for Package Body FA_FASCEILG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASCEILG_XMLP_PKG" AS
/* $Header: FASCEILGB.pls 120.0.12010000.1 2008/07/28 13:16:31 appldev ship $ */
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
BEGIN
  RP_Company_Name := Company_Name;
  SELECT cp.user_concurrent_program_name
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp,
         FND_CONCURRENT_REQUESTS cr
  WHERE  cr.request_id = P_CONC_REQUEST_ID
  AND    cp.application_id = cr.program_application_id
  AND    cp.concurrent_program_id=cr.concurrent_program_id;
l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
  RP_Report_Name := l_report_name;
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := ':Ceiling Listing:';
    RETURN(RP_Report_Name);
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
 P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
Return (true);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function ceiling_typeformula(Raw_Ceiling_Type in varchar2) return varchar2 is
begin
/*srw.reference(Raw_Ceiling_Type);*/null;
if (Raw_Ceiling_Type = 'DEPRN EXPENSE CEILING') then
  /*srw.user_exit('FND MESSAGE_NAME NAME="FA_CEILTYPE_EXPENSE"');*/null;
Ceiling_Type:='FA_CEILTYPE_EXPENSE';
elsif (Raw_Ceiling_Type = 'ITC CEILING') then
  /*srw.user_exit('FND MESSAGE_NAME NAME="FA_CEILTYPE_ITC"');*/null;
Ceiling_Type:='FA_CEILTYPE_ITC';
elsif (Raw_Ceiling_Type = 'RECOVERABLE COST CEILING') then
  /*srw.user_exit('FND MESSAGE_NAME NAME="FA_CEILTYPE_RECOVERABLE_COST"');*/null;
Ceiling_Type:='FA_CEILTYPE_RECOVERABLE_COST';
end if;
/*srw.user_exit('FND MESSAGE_GET OUTPUT_FIELD=":Ceiling_Type"');*/null;
return(Ceiling_Type);
end;
--Functions to refer Oracle report placeholders--
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
END FA_FASCEILG_XMLP_PKG ;


/
