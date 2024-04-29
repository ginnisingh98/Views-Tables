--------------------------------------------------------
--  DDL for Package Body AR_ARXBDP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXBDP_XMLP_PKG" AS
/* $Header: ARXBDPB.pls 120.0 2007/12/27 13:34:13 abraghun noship $ */

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
    WHERE
      cp.application_id = cr.program_application_id
    AND    cr.request_id = p_conc_request_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;

    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'Bad Debt Provision Report';
         RETURN('Bad Debt Provision Report');
END;
RETURN NULL; end;

function AfterPForm return boolean is
begin

begin

IF p_start_customer_number IS NOT NULL THEN
	lp_start_customer_number := ' and c.account_number >=  :p_start_customer_number  ';
END IF;

IF p_end_customer_number IS NOT NULL THEN
	lp_end_customer_number := ' and c.account_number <=  :p_end_customer_number  ';
END IF;

IF p_start_customer_name IS NOT NULL THEN
	lp_start_customer_name := ' and party.party_name >= :p_start_customer_name  ' ;
END IF;

IF p_end_customer_name IS NOT NULL THEN
	lp_end_customer_name := ' and party.party_name <= :p_end_customer_name  ';
END IF;


IF p_start_account_status IS NOT NULL THEN
	lp_start_account_status := ' and nvl(status.meaning,''^!'') >=  :p_start_account_status  ';
END IF;

IF p_end_account_status IS NOT NULL THEN
	lp_end_account_status := ' and nvl(status.meaning,''^!'') <=  :p_end_account_status  ';
END IF;

end;  return (TRUE);
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
 Function RP_DATA_FOUND_p return varchar2 is
	Begin

	 return RP_DATA_FOUND;
	 END;
 Function Ref_Curr_Code_p return varchar2 is
	Begin
	 return Ref_Curr_Code;
	 END;
 Function GSum_Amt_Due_Remaining_Dsp_p return varchar2 is
	Begin
	 return GSum_Amt_Due_Remaining_Dsp;
	 END;
 Function GSum_Provision_Dsp_p return varchar2 is
	Begin
	 return GSum_Provision_Dsp;
	 END;

/*  Added as fix */
function D_Amount_Due_OriginalFormula(Amount_Due_Original in number) return VARCHAR2 is
begin

/*srw.reference(:Amount_Due_Original);
srw.reference(:Functional_Currency_Code);*/
RP_DATA_FOUND := Amount_Due_Original;
/*srw.user_exit('FND FORMAT_CURRENCY
		CODE=":Functional_Currency_Code"
		DISPLAY_WIDTH="18"
		AMOUNT=":Amount_Due_Original"
		DISPLAY=":D_Amount_Due_Original"
 		MINIMUM_PRECISION=":P_MIN_PRECISION"');

IF :D_Amount_Due_Original IS NOT NULL THEN
	RETURN(:D_Amount_Due_Original);
ELSE
	RETURN('*');
END IF;*/
return null;
end;
END AR_ARXBDP_XMLP_PKG ;


/
