--------------------------------------------------------
--  DDL for Package PAY_PAYGBRRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYGBRRS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYGBRRSS.pls 120.1 2007/12/24 12:44:19 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_CONC_REQUEST_ID	number;
	P_CONSOLIDATION_SET_ID	varchar2(40);
	P_TIME_PERIOD_ID	number;
	P_PAYROLL_ID	number;
	P_CONSOLIDATION_SET_LINE	varchar2(100);
	P_LEGISLATION_CODE	varchar2(150);
	P_BUSINESS_GROUP	varchar2(40);
	P_GROSS_PAY_ID	number;
	P_TOTAL_DEDUCTIONS_ID	varchar2(80);
	P_DIRECT_PAYMENT_ID	number;
	P_EMPLOYER_CHARGES_ID	number;
	P_Sort_Order	varchar2(30);
	P_CURRENCY_CODE	varchar2(15);
	CP_BUSINESS_GROUP_NAME	varchar2(240);
	CP_PAYROLL_NAME	varchar2(80);
	CP_Time_Period_Time	varchar2(35);
	CP_CONSOLIDATION_SET_NAME	varchar2(60);
	CP_NI_input_Value_ID	number;
	CP_Tax_Code_Input_Value_ID	number;
	CP_Tax_Basis_Input_Value_ID	number;
	--CP_Sort_Order	varchar2(30) := := 'Assignment_Number' ;
	CP_Sort_Order	varchar2(30) := 'Assignment_Number' ;
	CP_CURRENCY_TEXT	varchar2(12);
	----------------------
	--Additional package--
	----------------------
	Gross_Payment number(13,2) :=0;
	Net_Payment number(13,2)   :=0;
	Total_Payment number(13,2) :=0;
	Total_Cost number(13,2) :=0;
	Other_Deductions number(13,2) :=0;
	Calc_Amount number(13,2) :=0;

	PROCEDURE Initialise_Variables;
	----------------------
	function Before_Report_Trigger return boolean  ;
	function Before_Parameter_Form_Trigger return boolean  ;
	function cf_total_paymentformula(Gross in number, Total_Deductions in number, Direct_Payments in number) return number  ;
	function cf_other_deductionsformula(Total_Deductions in number, PAYE in number, NI_Employee in number) return number  ;
	function cf_total_payments_currencyform(currency_code in varchar2, date_earned in date, net in number) return number  ;
	function cf_total_payments_currency(currency_code in varchar2, date_earned in date, Gross in number, Total_Deductions in number, Direct_Payments in number) return number  ;
	function CP_CURRENCY_TEXTFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	Function CP_BUSINESS_GROUP_NAME_p return varchar2;
	Function CP_PAYROLL_NAME_p return varchar2;
	Function CP_Time_Period_Time_p return varchar2;
	Function CP_CONSOLIDATION_SET_NAME_p return varchar2;
	Function CP_NI_input_Value_ID_p return number;
	Function CP_Tax_Code_Input_Value_ID_p return number;
	Function CP_Tax_Basis_Input_Value_ID_p return number;
	Function CP_Sort_Order_p return varchar2;
	Function CP_CURRENCY_TEXT_p return varchar2;
END PAY_PAYGBRRS_XMLP_PKG;

/
