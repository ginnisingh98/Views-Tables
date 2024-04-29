--------------------------------------------------------
--  DDL for Package Body AR_ARXPAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXPAR_XMLP_PKG" AS
/* $Header: ARXPARB.pls 120.0 2007/12/27 13:58:13 abraghun noship $ */
function BeforeReport return boolean is
begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
  /*SRW.USER_EXIT('FND SRWINIT');*/null;


  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function report_nameformula(Company_Name in varchar2) return varchar2 is
    l_report_name     VARCHAR2(240);
begin

    RP_Company_Name := Company_Name;
    SELECT substrb(cp.user_concurrent_program_name,1,80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cp.application_id = cr.program_application_id
    AND    cr.request_id = p_conc_request_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;

    RETURN(l_report_name);

RETURN NULL; EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'AutoCash Rules';
         RETURN('AutoCash Rules');

end;

function NLS_YESFormula return VARCHAR2 is
	nls_yes 	varchar(80);
begin

	select meaning
	into nls_yes
	from ar_lookups
	where lookup_type = 'YES/NO'
	and lookup_code = 'Y';

	return(nls_yes);

RETURN NULL; Exception
	When NO_DATA_FOUND Then
	     Return(' ');

end;

function NLS_NOFormula return VARCHAR2 is
	nls_no	varchar(80);
begin

	select meaning
	into   nls_no
	from   ar_lookups
	where  lookup_type = 'YES/NO'
	and    lookup_code = 'N';

	return(nls_no);

RETURN NULL; Exception
	When NO_DATA_FOUND Then
	   Return(' ');

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
END AR_ARXPAR_XMLP_PKG ;


/
