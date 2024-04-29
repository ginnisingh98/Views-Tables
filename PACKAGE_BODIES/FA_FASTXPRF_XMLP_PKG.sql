--------------------------------------------------------
--  DDL for Package Body FA_FASTXPRF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASTXPRF_XMLP_PKG" AS
/* $Header: FASTXPRFB.pls 120.0.12010000.1 2008/07/28 13:17:44 appldev ship $ */

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
    RP_Report_Name := ':Tax Preference Report:';
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

 begin

    rollback;
    /*SRW.USER_EXIT('FND SRWEXIT');*/null;

 end;
 return (TRUE);
end;

function period1_pcformula(DISTRIBUTION_SOURCE_BOOK in varchar2) return number is
begin

DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
  l_corp_end_pc	NUMBER(15);
BEGIN
  SELECT DP_FED.period_counter,
         DP_FED.period_open_date,
         nvl(DP_FED.period_close_date, sysdate),
         DP_FED.fiscal_year,
         DP_CORP.Period_Counter
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY,
         l_corp_end_pc
  FROM   FA_DEPRN_PERIODS DP_CORP,
	 FA_DEPRN_PERIODS DP_FED
  WHERE  DP_FED.book_type_code = P_BOOK
  AND    DP_FED.period_name    = P_PERIOD1
  AND    DP_CORP.BOOK_TYPE_CODE = DISTRIBUTION_SOURCE_BOOK
  AND    DP_CORP.PERIOD_COUNTER = (SELECT MAX(DP.PERIOD_COUNTER)
				FROM FA_DEPRN_PERIODS DP
				WHERE DP.BOOK_TYPE_CODE =
					DISTRIBUTION_SOURCE_BOOK AND
				DP.CALENDAR_PERIOD_CLOSE_DATE <=
					DP_FED.CALENDAR_PERIOD_CLOSE_DATE);

  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  CORP_END_PC := l_corp_end_pc;
  return(l_period_PC);
END;
RETURN NULL; end;

function c_do_insertformula(period1_pc in number, DISTRIBUTION_SOURCE_BOOK in varchar2, acct_flex_bal_seg in varchar2) return number is
--Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix
begin
  declare

  l_fed_min_pc	NUMBER(15);
  l_fed_max_pc	NUMBER(15);
  l_corp_min_pc	NUMBER(15);
  l_temp	number(15);
  l_sql_str	VARCHAR2(32767);

begin

    SELECT	min(fp1.period_counter),
		max(fp1.period_counter),
		min(fp2.period_counter)
    INTO 	l_fed_min_pc, l_fed_max_pc,
		l_corp_min_pc
    FROM	fa_deprn_periods fp1, fa_deprn_periods fp2
    WHERE	fp1.book_type_code = P_BOOK
    and		fp1.period_close_date is not NULL
    and		fp1.period_counter <= period1_pc
    and		fp1.fiscal_year = period1_FY
    and		fp2.book_type_code = DISTRIBUTION_SOURCE_BOOK
    and		fp2.period_close_date is NOT NULL
    and		fp2.period_counter <= corp_end_pc
    and		fp2.fiscal_year = period1_FY;

    min_fed_pc := l_fed_min_pc;
    max_fed_pc := l_fed_max_pc;
    min_corp_pc := l_corp_min_pc;


l_sql_str :=    'INSERT INTO FA_TAX_REPORT(
	REQUEST_ID,
	COMP_CODE,
	DEPRN_METHOD,
	ASSET_ACCOUNT,
	ASSET_ID,
	FED_YTD_DEPRN,
	CORP_YTD_DEPRN)
    SELECT  ' || to_char(p_conc_request_id) || ' REQUEST_ID, ' ||
	acct_flex_bal_seg || 			      ' COMP_CODE,
        BK_FED.DEPRN_METHOD_CODE                        FED_METHOD,
        CB_CORP.ASSET_COST_ACCT                         ASSET_ACCOUNT,
        DD_FED.ASSET_ID                                 ASSET_ID,
        SUM(DD_FED.deprn_amount)                        FED_YTD_DEPRN,
        0
    FROM
        FA_DEPRN_PERIODS                                DP,
        FA_DEPRN_DETAIL                                 DD_FED,
        FA_ASSET_HISTORY				AH,
        FA_BOOKS                                        BK_FED,
        FA_CATEGORY_BOOKS                               CB_CORP,
        FA_CATEGORIES                                   CAT,
	FA_DISTRIBUTION_HISTORY				DH,
	GL_CODE_COMBINATIONS				DHCC
    WHERE
        DD_FED.BOOK_TYPE_CODE           = ''' || P_BOOK	||	''' AND
        DD_FED.PERIOD_COUNTER           between ' || to_char(l_fed_min_pc) ||
                      '  and ' || to_char(l_fed_max_pc) ||              ' AND
        DD_FED.DEPRN_SOURCE_CODE        <> ''B''                          AND
        BK_FED.BOOK_TYPE_CODE           = DD_FED.BOOK_TYPE_CODE         AND
        BK_FED.ASSET_ID                 = DD_FED.ASSET_ID               AND
	BK_FED.DATE_EFFECTIVE		<= DP.PERIOD_CLOSE_DATE         AND
	NVL(BK_FED.DATE_INEFFECTIVE, DP.PERIOD_CLOSE_DATE) >= DP.PERIOD_CLOSE_DATE AND
        DP.BOOK_TYPE_CODE               = DD_FED.BOOK_TYPE_CODE         AND
        DP.PERIOD_COUNTER               = DD_FED.PERIOD_COUNTER         AND
        CB_CORP.BOOK_TYPE_CODE          = ''' || DISTRIBUTION_SOURCE_BOOK  ||  ''' AND
        CB_CORP.ASSET_COST_ACCT BETWEEN
                NVL(''' || p_from_acct || ''', CB_CORP.ASSET_COST_ACCT)
                AND NVL(''' || p_to_acct || ''', CB_CORP.ASSET_COST_ACCT) AND
	CB_CORP.CATEGORY_ID             = CAT.CATEGORY_ID               AND
        AH.ASSET_ID			= DD_FED.ASSET_ID		AND
	AH.DATE_EFFECTIVE		<= DP.PERIOD_CLOSE_DATE 	AND
	NVL(AH.DATE_INEFFECTIVE, DP.PERIOD_CLOSE_DATE + 1) > DP.PERIOD_CLOSE_DATE AND
	DH.BOOK_TYPE_CODE		= ''' || DISTRIBUTION_SOURCE_BOOK || ''' AND
	CB_CORP.CATEGORY_ID		= AH.CATEGORY_ID		AND
	DH.ASSET_ID			= DD_FED.ASSET_ID		AND
	DH.DISTRIBUTION_ID		= DD_FED.DISTRIBUTION_ID	AND
	DH.DATE_EFFECTIVE		<= DP.PERIOD_CLOSE_DATE AND
	NVL(DH.DATE_INEFFECTIVE, DP.PERIOD_CLOSE_DATE) >=  DP.PERIOD_CLOSE_DATE AND
	DH.CODE_COMBINATION_ID          = DHCC.CODE_COMBINATION_ID(+)
    GROUP BY ' ||
	acct_flex_bal_seg || ',
        BK_FED.DEPRN_METHOD_CODE,
        CB_CORP.ASSET_COST_ACCT,
	3,
        DD_FED.ASSET_ID';

/*srw.do_sql(l_sql_str);*/null;

execute immediate(l_sql_str);
--Added during DT Fix
commit;
--End of DT Fix
return(1);
end;
end;

--Functions to refer Oracle report placeholders--

 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function CAT_MAJ_RPROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_RPROMPT;
	 END;
 Function CORP_END_PC_p return number is
	Begin
	 return CORP_END_PC;
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
 Function min_fed_pc_p return number is
	Begin
	 return min_fed_pc;
	 END;
 Function max_fed_pc_p return number is
	Begin
	 return max_fed_pc;
	 END;
 Function min_corp_pc_p return number is
	Begin
	 return min_corp_pc;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_BAL_LPROMPT_p return varchar2 is
	Begin
	 return RP_BAL_LPROMPT;
	 END;
END FA_FASTXPRF_XMLP_PKG ;


/
