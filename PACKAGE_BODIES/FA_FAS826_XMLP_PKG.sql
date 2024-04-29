--------------------------------------------------------
--  DDL for Package Body FA_FAS826_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS826_XMLP_PKG" AS
/* $Header: FAS826B.pls 120.0.12010000.1 2008/07/28 13:15:46 appldev ship $ */
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
    RP_Report_Name := ':Mass Additions Purge Report:';
    RETURN('Mass Additions Purge Report');
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
 P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
  return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
delete from fa_deleted_mass_additions
where create_batch_id = P_BATCH_ID;  return (TRUE);
end;
function d_statusformula(STATUS in varchar2) return varchar2 is
begin
RP_DATA_FOUND := 'YES';
IF STATUS = '  A'
   THEN
       RETURN(NULL);
    ELSE
       RETURN(STATUS);
END IF;
RETURN NULL; end;
--Functions to refer Oracle report placeholders--
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
END FA_FAS826_XMLP_PKG ;


/
