--------------------------------------------------------
--  DDL for Package Body AR_ARXDPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXDPR_XMLP_PKG" AS
/* $Header: ARXDPRB.pls 120.0 2007/12/27 13:48:57 abraghun noship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
  l_report_name VARCHAR2(80);
BEGIN
  RP_Company_Name := Company_Name;

  SELECT substr(cp.user_concurrent_program_name,1,80)
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp,
         FND_CONCURRENT_REQUESTS cr
  WHERE  cr.request_id = P_CONC_REQUEST_ID
  AND    cp.application_id = cr.program_application_id
  AND    cp.concurrent_program_id=cr.concurrent_program_id;

  RP_Report_Name := l_report_name;
  RETURN(l_report_name);

EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := 'Discount Projection Report';
    RETURN('Discount Projection Report');
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

function abs_discFormula return Number is
begin

/*srw.reference(out_disc_to_take);*/null;

return(nvl(out_earned_disc,0) + nvl(out_unearned_disc,0));
end;

function unearnd_disc_pctformula(unearned_discount in varchar2) return number is
begin

if(unearned_discount = 'N') THEN return(NULL);
else return(nvl(best_disc_pct,0) - nvl(earned_disc_pct,0));
end if;
RETURN NULL; end;

function cf_acc_messageformula(gl_date in date) return number is
  l_msg VARCHAR2(2000) ;
begin
  IF gl_date IS NOT NULL THEN

      FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');
      l_msg := FND_MESSAGE.get;
      cp_acc_message := l_msg;

  ELSE
      cp_acc_message := NULL;
  END IF;
return 0;
end;

--Functions to refer Oracle report placeholders--

 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function out_discount_date_p return varchar2 is
	Begin
	 return out_discount_date;
	 END;
 Function out_amt_to_apply_p return number is
	Begin
	 return out_amt_to_apply;
	 END;
 Function earned_disc_pct_p return number is
	Begin
	 return earned_disc_pct;
	 END;
 Function out_earned_disc_p return number is
	Begin
	 return out_earned_disc;
	 END;
 Function out_unearned_disc_p return number is
	Begin
	 return out_unearned_disc;
	 END;
 Function best_disc_pct_p return number is
	Begin
	 return best_disc_pct;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function CP_ACC_MESSAGE_p return varchar2 is
	Begin
	 return CP_ACC_MESSAGE;
	 END;
END AR_ARXDPR_XMLP_PKG ;


/
