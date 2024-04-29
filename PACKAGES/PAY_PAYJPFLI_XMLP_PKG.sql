--------------------------------------------------------
--  DDL for Package PAY_PAYJPFLI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYJPFLI_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYJPFLIS.pls 120.0 2007/12/13 11:59:48 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_FISCAL_YEAR	number;
	P_ORGANIZATION_ID	number;
	P_CONC_REQUEST_ID	number;
	CP_SALARY_CATEGORY	varchar2(8);
	CP_TARGET_YEAR	number;
	CP_TARGET_MONTH	number;
	CP_WAI_COUNT	number;
	CP_WAI_SAL_AMT	number;
	CP_UI_COUNT	number;
	CP_UI_SAL_AMT	number;
	CP_REPORT_TITLE	varchar2(255);
	CP_WAI_SAL_AMT_SUM	number;
	CP_UI_SAL_AMT_SUM	number;
	CP_UI_AGED_SAL_AMT_SUM	number;
	CP_UI_NET_SAL_AMT_SUM	number;
	CP_WAI_COUNT_SALARY_AVG	number;
	CP_UI_COUNT_SALARY_AVG	number;
	CP_UI_AGED_COUNT_SALARY_AVG	number;
	CP_WAI_COUNT_SALARY_SUM	number := 0 ;
	CP_UI_COUNT_SALARY_SUM	number := 0 ;
	CP_UI_AGED_COUNT_SALARY_SUM	number := 0 ;
	CP_NUM_OF_SALARY_MONTHS	number := 0 ;
	function cf_li_dummyformula(SALARY_CATEGORY in varchar2, TARGET_MONTH in varchar2, WAI_EE_COUNT in number, WAI_EX_COUNT in number, WAI_TW_COUNT in number,
	WAI_EE_SAL_AMT in number, WAI_EX_SAL_AMT in number, WAI_TW_SAL_AMT in number, UI_EE_COUNT in number, UI_EX_COUNT in number, UI_EE_SAL_AMT in number, UI_EX_SAL_AMT in number, UI_AGED_COUNT in number) return number  ;
	function BeforeReport return boolean  ;
	function cf_report_dummyformula(CS_CP_WAI_SAL_AMT_SUM in number, CS_CP_UI_SAL_AMT_SUM in number, CS_UI_AGED_SAL_AMT_SUM in number) return number  ;
	function AfterReport return boolean  ;
	Function CP_SALARY_CATEGORY_p return varchar2;
	Function CP_TARGET_YEAR_p return number;
	Function CP_TARGET_MONTH_p return number;
	Function CP_WAI_COUNT_p return number;
	Function CP_WAI_SAL_AMT_p return number;
	Function CP_UI_COUNT_p return number;
	Function CP_UI_SAL_AMT_p return number;
	Function CP_REPORT_TITLE_p return varchar2;
	Function CP_WAI_SAL_AMT_SUM_p return number;
	Function CP_UI_SAL_AMT_SUM_p return number;
	Function CP_UI_AGED_SAL_AMT_SUM_p return number;
	Function CP_UI_NET_SAL_AMT_SUM_p return number;
	Function CP_WAI_COUNT_SALARY_AVG_p return number;
	Function CP_UI_COUNT_SALARY_AVG_p return number;
	Function CP_UI_AGED_COUNT_SALARY_AVG_p return number;
	Function CP_WAI_COUNT_SALARY_SUM_p return number;
	Function CP_UI_COUNT_SALARY_SUM_p return number;
	Function CP_UI_AGED_COUNT_SALARY_SUM_p return number;
	Function CP_NUM_OF_SALARY_MONTHS_p return number;
END PAY_PAYJPFLI_XMLP_PKG;

/
