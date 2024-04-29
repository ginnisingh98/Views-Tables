--------------------------------------------------------
--  DDL for Package Body AR_RAXPTL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXPTL_XMLP_PKG" AS
/* $Header: RAXPTLB.pls 120.0 2007/12/27 14:32:09 abraghun noship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
    l_report_name  VARCHAR2(80);

BEGIN

    RP_Company_Name := Company_Name;

    SELECT substr(cp.user_concurrent_program_name,1,80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;
    RETURN(l_report_name);

EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'Payment Terms Listing';
         RETURN('Payment Terms Listing');
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin

BEGIN
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
/*SRW.USER_EXIT('FND SRWINIT');*/null;





END;
  return (TRUE);
end;

function Sub_TitleFormula return VARCHAR2 is
begin

begin
RP_SUB_TITLE := ' ';
return(' ');
end;

RETURN NULL; end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_SUB_TITLE_p return varchar2 is
	Begin
	 return RP_SUB_TITLE;
	 END;
 function D_Relative_AmountFormula return VARCHAR2 is
	begin
	RP_DATA_FOUND := 'X';
	return null;
	end;
END AR_RAXPTL_XMLP_PKG ;


/
