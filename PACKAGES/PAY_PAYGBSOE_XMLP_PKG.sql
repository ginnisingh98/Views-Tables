--------------------------------------------------------
--  DDL for Package PAY_PAYGBSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYGBSOE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYGBSOES.pls 120.1 2007/12/24 12:44:49 amakrish noship $ */
	P_SESSION_DATE	date;
	P_PAYROLL_EXISTS	varchar2(32767);
	P_PAYROLL_ID	number;
	P_TIME_PERIOD_ID	number;
	P_PAY_ADVICE_DATE	varchar2(32767);
	P_conc_request_id	number;
	P_ASSIGNMENT_ID	number;
	P_SORT_ORDER1	varchar2(60);
	P_SORT_ORDER1_dup varchar2(60);
	P_SORT_ORDER2	varchar2(60);
	P_SORT_ORDER2_dup varchar2(60);
	P_SORT_ORDER3	varchar2(60);
	P_SORT_ORDER3_dup varchar2(60);
	P_SORT_ORDER4	varchar2(60);
	P_SORT_ORDER4_dup varchar2(60);
	P_SORT_ORDER5	varchar2(60);
	P_SORT_ORDER5_dup varchar2(60);
	P_SORT_ORDER6	varchar2(60);
	P_SORT_ORDER6_dup varchar2(60);
	P_SORT_ORDER7	varchar2(32767);
	P_BUS_GRP_ID	number;
	C_ADDRESS1	varchar2(28);
	C_ADDRESS2	varchar2(28);
	C_ADDRESS3	varchar2(28);
	C_REGION1	varchar2(28);
	C_REGION2	varchar2(28);
	C_REGION3	varchar2(28);
	C_ACCOUNT_NO	number;
	C_TOWN	varchar2(28);
	C_ANNUAL_SALARY	number;
	C_PAY_DATE	date;
	C_TAX_PERIOD	varchar2(30);
	C_TAX_REFERENCE_NO	varchar2(30);
	C_TAX_CODE	varchar2(15);
	C_TAX_BASIS	varchar2(30);
	C_NI_CATEGORY	varchar2(30);
	C_TAX_TEL_NO	varchar2(20);
	C_BALANCE_R1_TXT	varchar2(20);
	C_BALANCE_R1_VAL	number;
	C_BALANCE_R2_TXT	varchar2(20);
	C_BALANCE_R2_VAL	number;
	C_BALANCE_R3_TXT	varchar2(20);
	C_BALANCE_R3_VAL	number;
	C_BALANCE_R4_TXT	varchar2(20);
	C_BALANCE_R4_VAL	number;
	C_BALANCE_R5_TXT	varchar2(20);
	C_BALANCE_R5_VAL	number;
	C_BALANCE_R6_TXT	varchar2(20);
	C_BALANCE_R6_VAL	number;
	C_BALANCE_R7_TXT	varchar2(20);
	C_BALANCE_R7_VAL	number;
	C_BALANCE_R8_TXT	varchar2(20);
	C_BALANCE_R8_VAL	number;
	C_BALANCE_R9_TXT	varchar2(20);
	C_BALANCE_R9_VAL	number;
	C_BALANCE_R10_TXT	varchar2(20);
	C_BALANCE_R10_VAL	number;
	C_BALANCE_R11_TXT	varchar2(20);
	C_BALANCE_R11_VAL	number;
	C_BALANCE_R12_TXT	varchar2(20);
	C_BALANCE_R12_VAL	number;
	C_OUTPUT2	number;
	C_OUTPUT	number;
	C_2	number;
	C_FORMULA_ID	number;
	C_DATE_EARNED	varchar2(11);
	C_FORMULA_ID2	number;
	C_OUTPUT3	varchar2(32767);
	function c_amount_paidformula(C_PAYMENT_TOTAL in number, C_DEDUCTION_TOTAL in number) return number  ;
	function BeforeReport return boolean  ;
	function P_SORT_ORDER3ValidTrigger return boolean  ;
	function P_SORT_ORDER4ValidTrigger return boolean  ;
	function P_SORT_ORDER5ValidTrigger return boolean  ;
	function P_SORT_ORDER6ValidTrigger return boolean  ;
	function c_nameformula(TITLE in varchar2, INITIALS in varchar2, LAST_NAME in varchar2) return varchar2  ;
	Function Segment1 return varchar2 ;
	Procedure Seg_name(a in varchar2 , b out NOCOPY varchar2)  ;
	Function Segment2 return varchar2 ;
	Function Segment3 return varchar2 ;
	Function Segment4 return varchar2 ;
	Function Segment5 return varchar2 ;
	Function Segment6 return varchar2 ;
	function P_SORT_ORDER1ValidTrigger return boolean  ;
	function P_SORT_ORDER2ValidTrigger return boolean  ;
	function AfterPForm return boolean  ;
	function BeforePForm return boolean  ;
	function cf_euro_amountformula(c_amount_paid in number) return number  ;
	function AfterReport return boolean  ;
	Function C_ADDRESS1_p return varchar2;
	Function C_ADDRESS2_p return varchar2;
	Function C_ADDRESS3_p return varchar2;
	Function C_REGION1_p return varchar2;
	Function C_REGION2_p return varchar2;
	Function C_REGION3_p return varchar2;
	Function C_ACCOUNT_NO_p return number;
	Function C_TOWN_p return varchar2;
	Function C_ANNUAL_SALARY_p return number;
	Function C_PAY_DATE_p return date;
	Function C_TAX_PERIOD_p return varchar2;
	Function C_TAX_REFERENCE_NO_p return varchar2;
	Function C_TAX_CODE_p return varchar2;
	Function C_TAX_BASIS_p return varchar2;
	Function C_NI_CATEGORY_p return varchar2;
	Function C_TAX_TEL_NO_p return varchar2;
	Function C_BALANCE_R1_TXT_p return varchar2;
	Function C_BALANCE_R1_VAL_p return number;
	Function C_BALANCE_R2_TXT_p return varchar2;
	Function C_BALANCE_R2_VAL_p return number;
	Function C_BALANCE_R3_TXT_p return varchar2;
	Function C_BALANCE_R3_VAL_p return number;
	Function C_BALANCE_R4_TXT_p return varchar2;
	Function C_BALANCE_R4_VAL_p return number;
	Function C_BALANCE_R5_TXT_p return varchar2;
	Function C_BALANCE_R5_VAL_p return number;
	Function C_BALANCE_R6_TXT_p return varchar2;
	Function C_BALANCE_R6_VAL_p return number;
	Function C_BALANCE_R7_TXT_p return varchar2;
	Function C_BALANCE_R7_VAL_p return number;
	Function C_BALANCE_R8_TXT_p return varchar2;
	Function C_BALANCE_R8_VAL_p return number;
	Function C_BALANCE_R9_TXT_p return varchar2;
	Function C_BALANCE_R9_VAL_p return number;
	Function C_BALANCE_R10_TXT_p return varchar2;
	Function C_BALANCE_R10_VAL_p return number;
	Function C_BALANCE_R11_TXT_p return varchar2;
	Function C_BALANCE_R11_VAL_p return number;
	Function C_BALANCE_R12_TXT_p return varchar2;
	Function C_BALANCE_R12_VAL_p return number;
	Function C_OUTPUT2_p return number;
	Function C_OUTPUT_p return number;
	Function C_2_p return number;
	Function C_FORMULA_ID_p return number;
	Function C_DATE_EARNED_p return varchar2;
	Function C_FORMULA_ID2_p return number;
	Function C_OUTPUT3_p return varchar2;

	--ADDED BY VALLI--
	function populate_fields(expense_check_send_to_address IN  VARCHAR2,
person_id IN NUMBER,segment1c IN VARCHAR2,segment2c IN VARCHAR2,segment3c IN VARCHAR2,segment4c IN VARCHAR2,segment5c IN VARCHAR2,segment6c IN VARCHAR2) return number;

function get_ff_data(run_effective_date IN DATE ,date_earned IN DATE,assignment_id IN NUMBER
,run_assignment_action_id IN NUMBER,payroll_action_id IN NUMBER,p_bus_grp_id IN NUMBER)
return number ;

END PAY_PAYGBSOE_XMLP_PKG;

/
