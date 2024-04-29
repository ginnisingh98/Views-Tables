--------------------------------------------------------
--  DDL for Package Body FA_FAS828_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS828_XMLP_PKG" AS
/* $Header: FAS828B.pls 120.0.12010000.1 2008/07/28 13:15:48 appldev ship $ */
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
BEGIN
--Added during DT Fix
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
  RP_Company_Name := Company_Name;
  SELECT cp.user_concurrent_program_name
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp,
         FND_CONCURRENT_REQUESTS cr
  WHERE  cr.request_id = P_CONC_REQUEST_ID
  AND    cp.application_id = cr.program_application_id
  AND    cp.concurrent_program_id=cr.concurrent_program_id;
  RP_Report_Name := l_report_name;
  RP_REPORT_NAME := substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := 'DELETE MASS ADDITIONS PREVIEW REPORT';
    RETURN('DELETE MASS ADDITIONS PREVIEW REPORT');
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
function currency_codeformula(BOOK in varchar2) return varchar2 is
begin
DECLARE
  l_currency_code VARCHAR2(15);
  l_precision NUMBER(15);
BEGIN
/*srw.message(1,BOOK);*/null;
  SELECT sob.currency_code,
         cur.precision
  INTO   l_currency_code,
         l_precision
  FROM   FA_BOOK_CONTROLS bc,
	 GL_SETS_OF_BOOKS sob,
         FND_CURRENCIES cur
  WHERE  bc.book_type_code = BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id
  AND    sob.currency_code    = cur.currency_code;
  P_Min_Precision := l_precision;
  return(l_currency_code);
END;
RETURN NULL; end;
--Added the below function during DT Fix
 Function D_COSTFormula(FEEDER_SYSTEM in varchar2) return varchar2 is
        Begin
         RP_FEEDER_SYSTEM := FEEDER_SYSTEM;
	 return null;
        END;
--End of DT Fix
--Functions to refer Oracle report placeholders--
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_FEEDER_SYSTEM_p return varchar2 is
	Begin
	 return RP_FEEDER_SYSTEM;
	 END;
END FA_FAS828_XMLP_PKG ;


/
