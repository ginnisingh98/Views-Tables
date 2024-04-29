--------------------------------------------------------
--  DDL for Package Body FA_FASLSPRC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASLSPRC_XMLP_PKG" AS
/* $Header: FASLSPRCB.pls 120.0.12010000.1 2008/07/28 13:16:53 appldev ship $ */

function report_nameformula(Company_Name in varchar2, START_DATE in date, END_DATE in date) return varchar2 is
begin

DECLARE
  l_report_name VARCHAR2(80);
BEGIN
--Added during DT Fix
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
  RP_Company_Name := Company_Name;

  RP_START_DATE := START_DATE;
  RP_END_DATE := END_DATE;

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
    RP_Report_Name := 'REPORT TITLE';
    RETURN('REPORT TITLE');
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;
  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function G_PRO_CONVGroupFilter return boolean is
begin

RP_DATA_FOUND := 'YES';  return (TRUE);
end;

function G_PRO_DATESGroupFilter return boolean is
begin

RP_DATA_FOUND := 'YES';  return (TRUE);
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
 Function RP_START_DATE_p return date is
	Begin
	 return RP_START_DATE;
	 END;
 Function RP_END_DATE_p return date is
	Begin
	 return RP_END_DATE;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
END FA_FASLSPRC_XMLP_PKG ;


/
