--------------------------------------------------------
--  DDL for Package PAY_PAYUSTOT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYUSTOT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYUSTOTS.pls 120.0 2008/01/07 11:56:31 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_END_DATE	date;
	P_START_DATE	date;
	P_START_DATE_m	date;
	P_TAX_UNIT_ID	number;
	P_FLAG	varchar2(10);
	CP_FED_OTHERS	number;
	CP_FWT_SUPP_EARN_NWFIT	number;
	CP_FWT_SUPP_EARN_FIT	number;
	CP_PRE_TAX_DEDUCTIONS_FOR_FIT	number;
	CP_FIT_NON_W2_PRE_TAX_DEDNS	number;
	CP_FWT_REGULAR_EARNINGS	number;
	CP_PRE_TAX_DEDUCTIONS	number;
	CP_FIT_WITHHELD	number;
	CP_SS_EE_TAXABLE	number;
	CP_SS_EE_WITHHELD	number;
	CP_MEDICARE_EE_TAXABLE	number;
	CP_MEDICARE_EE_WITHHELD	number;
	CP_STATE_WAGES_TIPS_OTHER	number := 0.00 ;
	CP_SIT_EE_WITHHELD	number := 0.00 ;
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_TAX_UNIT_NAME	varchar2(60);
	CP_state_tax_unit	varchar2(20);
	CP_STATE_STATUS	varchar2(1);
	CP_FED_STATUS	varchar2(1);
	function BeforeReport return boolean  ;
	function cf_fed_gross_wagesformula(gre_id in number) return number  ;
	function cf_fed_wages_tips_otherformula(gre_id in number) return number  ;
	function cf_state_gross_wagesformula(gre_id in number, state_code in varchar2, State in varchar2) return number  ;
	FUNCTION GRE_TAX_BALANCE(P_BUSINESS_GROUP_ID IN NUMBER
                        ,P_GRE_ORG_ID IN NUMBER
                        ,P_DEF_BAL_ID IN NUMBER
                        ,P_START_DATE IN DATE
                        ,P_END_DATE IN DATE) RETURN NUMBER  ;
	function cf_1formula(gre_id in number, state in varchar2) return varchar2  ;
	function CP_FIT_WITHHELDFormula return Number  ;
	function CP_MEDICARE_EE_TAXABLEFormula return Number  ;
	function CP_MEDICARE_EE_WITHHELDFormula return Number  ;
	function CP_SS_EE_TAXABLEFormula return Number  ;
	function CP_SS_EE_WITHHELDFormula return Number  ;
	function CP_DEF_COMP_401KFormula return Number  ;
	function CP_REGULAR_EARNINGSFormula return Number  ;
	function CP_SECTION_125Formula return Number  ;
	function CP_FWT_SUPP_EARN_NWFITFormula return Number  ;
	function CP_FWT_SUPP_EARN_FITFormula return Number  ;
	function CP_DEF_COMP_401K_FOR_FITFormul return Number  ;
	function CP_STATE_WAGES_TIPS_OTHERFormu return Number  ;
	function CP_SIT_EE_WITHHELDFormula return Number  ;
	function cf_message_lineformula(CF_FED_GROSS_WAGES in number) return varchar2  ;
	function AfterReport return boolean  ;
	Function CP_FED_OTHERS_p return number;
	Function CP_FWT_SUPP_EARN_NWFIT_p return number;
	Function CP_FWT_SUPP_EARN_FIT_p return number;
	--Function CP_PRE_TAX_DEDUCTIONS_FOR_FIT return number;
	Function CP_PRE_TAX_DEDUCTIONS_FOR_p return number;
	Function CP_FIT_NON_W2_PRE_TAX_DEDNS_p return number;
	Function CP_FWT_REGULAR_EARNINGS_p return number;
	Function CP_PRE_TAX_DEDUCTIONS_p return number;
	Function CP_FIT_WITHHELD_p return number;
	Function CP_SS_EE_TAXABLE_p return number;
	Function CP_SS_EE_WITHHELD_p return number;
	Function CP_MEDICARE_EE_TAXABLE_p return number;
	Function CP_MEDICARE_EE_WITH_p return number;
	Function CP_STATE_WAGES_TIPS_OTHER_p return number;
	Function CP_SIT_EE_WITHHELD_p return number;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_TAX_UNIT_NAME_p return varchar2;
	Function CP_state_tax_unit_p return varchar2;
	Function CP_STATE_STATUS_p return varchar2;
	Function CP_FED_STATUS_p return varchar2;

END PAY_PAYUSTOT_XMLP_PKG;

/
