--------------------------------------------------------
--  DDL for Package Body FA_FASINDX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASINDX_XMLP_PKG" AS
/* $Header: FASINDXB.pls 120.0.12010000.1 2008/07/28 13:16:43 appldev ship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
--Added during DT Fix
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
  RP_Company_Name := Company_Name;

  SELECT cr.concurrent_program_id
  INTO l_conc_program_id
  FROM FND_CONCURRENT_REQUESTS cr
  WHERE cr.program_application_id = 140
  AND   cr.request_id = P_CONC_REQUEST_ID;

  SELECT cp.user_concurrent_program_name
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp
  WHERE
      cp.concurrent_program_id= l_conc_program_id
  and cp.application_id = 140;

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

--Functions to refer Oracle report placeholders--

 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_Company_Name_p return varchar2 is
	Begin
	 return RP_Company_Name;
	 END;
END FA_FASINDX_XMLP_PKG ;


/
