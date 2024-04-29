--------------------------------------------------------
--  DDL for Package Body FA_FAS955_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS955_XMLP_PKG" AS
/* $Header: FAS955B.pls 120.0.12010000.1 2008/07/28 13:16:08 appldev ship $ */
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
    RP_Report_Name := ':Budget-To-Actual Report:';
    RETURN(RP_REPORT_NAME);
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
function period1_pcformula(Distribution_Source_Book in varchar2) return number is
begin
DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
  l_period_num	NUMBER(4);
  l_quarter_num	NUMBER(2);
BEGIN
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year,
	PERIOD_NUM,
	QUARTER
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY,
	 l_period_num,
	 l_quarter_num
  FROM   FA_DEPRN_PERIODS,
	FA_PERIOD_MAPS
  WHERE  book_type_code = Distribution_Source_Book
  AND    period_name    = P_PERIOD1
  AND	period_num	= qtr_last_period;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  PERIOD_NUM  := l_period_num;
  QUARTER_NUM := l_quarter_num;
  return(l_period_PC);
END;
RETURN NULL; end;
function cat_pdevformula(CAT_PB_COST in number, CAT_PA_COST in number, precision in number) return number is
begin
IF (CAT_PB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((CAT_PB_COST - CAT_PA_COST) / CAT_PB_COST * 100),precision));
END IF;
RETURN NULL; end;
function cat_qdevformula(CAT_QB_COST in number, CAT_QA_COST in number, precision in number) return number is
begin
IF (CAT_QB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((CAT_QB_COST - CAT_QA_COST) / CAT_QB_COST * 100),precision));
END IF;
RETURN NULL; end;
function cat_ydevformula(CAT_YB_COST in number, CAT_YA_COST in number, precision in number) return number is
begin
IF (CAT_YB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((CAT_YB_COST - CAT_YA_COST) / CAT_YB_COST * 100),precision));
END IF;
RETURN NULL; end;
function rp_ydevformula(RP_YB_COST in number, RP_YA_COST in number, prec_glob in varchar2) return number is
begin
IF (RP_YB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((RP_YB_COST - RP_YA_COST) / RP_YB_COST * 100),prec_glob));
END IF;
RETURN NULL; end;
function rp_qdevformula(RP_QB_COST in number, RP_QA_COST in number, prec_glob in varchar2) return number is
begin
IF (RP_QB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((RP_QB_COST - RP_QA_COST) / RP_QB_COST * 100),prec_glob));
END IF;
RETURN NULL; end;
function rp_pdevformula(RP_PB_COST in number, RP_PA_COST in number, prec_glob in varchar2) return number is
begin
IF (RP_PB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((RP_PB_COST - RP_PA_COST) / RP_PB_COST * 100),prec_glob));
END IF;
RETURN NULL; end;
function cc_pdevformula(CC_PB_COST in number, CC_PA_COST in number, precision in number) return number is
begin
IF (CC_PB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((CC_PB_COST - CC_PA_COST) / CC_PB_COST * 100),precision));
END IF;
RETURN NULL; end;
function cc_qdevformula(CC_QB_COST in number, CC_QA_COST in number, precision in number) return number is
begin
IF (CC_QB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((CC_QB_COST - CC_QA_COST) / CC_QB_COST * 100),precision));
END IF;
RETURN NULL; end;
function cc_ydevformula(CC_YB_COST in number, CC_YA_COST in number, precision in number) return number is
begin
IF (CC_YB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((CC_YB_COST - CC_YA_COST) / CC_YB_COST * 100),precision));
END IF;
RETURN NULL; end;
function bd_pdevformula(BD_PB_COST in number, BD_PA_COST in number, precision in number) return number is
begin
IF (BD_PB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((BD_PB_COST - BD_PA_COST) / BD_PB_COST * 100),precision));
END IF;
RETURN NULL; end;
function bd_qdevformula(BD_QB_COST in number, BD_QA_COST in number) return number is
begin
IF (BD_QB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN((BD_QB_COST - BD_QA_COST) / BD_QB_COST * 100);
END IF;
RETURN NULL; end;
function bd_ydevformula(BD_YB_COST in number, BD_YA_COST in number, precision in number) return number is
begin
IF (BD_YB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((BD_YB_COST - BD_YA_COST) / BD_YB_COST * 100),precision));
END IF;
RETURN NULL; end;
function bal_pdevformula(BAL_PB_COST in number, BAL_PA_COST in number, precision in number) return number is
begin
IF (BAL_PB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round(((BAL_PB_COST - BAL_PA_COST) / BAL_PB_COST * 100),precision));
END IF;
RETURN NULL; end;
function bal_ydevformula(BAL_YB_COST in number, BAL_YA_COST in number, precision in number) return number is
begin
IF (BAL_YB_COST = 0) THEN RETURN(NULL);
ELSE
RETURN(round((((BAL_YB_COST - BAL_YA_COST) / BAL_YB_COST) * 100),precision));
END IF;
RETURN NULL; end;
function bal_qdevformula(BAL_QB_COST in number, BAL_QA_COST in number, precision in number) return number is
begin
IF (BAL_QB_COST = 0 or BAL_QB_COST is null) THEN RETURN(NULL);
ELSE
return(round(((BAL_QB_COST - BAL_QA_COST) / BAL_QB_COST *100),precision));
END IF;
RETURN NULL; end;
--Functions to refer Oracle report placeholders--
 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function ACCT_CC_APROMPT_p return varchar2 is
	Begin
	 return ACCT_CC_APROMPT;
	 END;
 Function CAT_MAJ_RPROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_RPROMPT;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function Period1_PCD_p return date is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_FY_p return number is
	Begin
	 return Period1_FY;
	 END;
 Function PERIOD_NUM_p return number is
	Begin
	 return PERIOD_NUM;
	 END;
 Function QUARTER_NUM_p return number is
	Begin
	 return QUARTER_NUM;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
END FA_FAS955_XMLP_PKG ;


/
