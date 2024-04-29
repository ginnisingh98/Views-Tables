--------------------------------------------------------
--  DDL for Package PAY_PAYGBGTN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYGBGTN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYGBGTNS.pls 120.1 2007/12/24 12:43:19 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_CONC_REQUEST_ID	number;
	P_CONSOLIDATION_SET_ID	varchar2(40);
	P_TIME_PERIOD_ID	number;
	P_PAYROLL_ID	number;
	P_CONSOLIDATION_SET_LINE	varchar2(100) := ' ';
	P_LEGISLATION_CODE	varchar2(150);
	P_BUSINESS_GROUP	varchar2(40);
	P_GROSS_PAY_ID	number;
	P_TOTAL_DEDUCTIONS_ID	varchar2(80);
	P_DIRECT_PAYMENT_ID	number;
	P_EMPLOYER_CHARGES_ID	number;
	CP_BUSINESS_GROUP_NAME	varchar2(240);
	CP_PAYROLL_NAME	varchar2(80);
	CP_Time_Period_Time	varchar2(35);
	CP_CONSOLIDATION_SET_NAME	varchar2(60);
	----------------------
	--Additional package--
	----------------------
	Gross_Payment number(13,2) :=0;
	Net_Payment number(13,2)   :=0;
	Total_Payment number(13,2) :=0;
	Total_Cost number(13,2) :=0;
	PROCEDURE Initialise_Variables;
	----------------------
	function Before_Report_Trigger return boolean  ;
	function Before_Parameter_Form_Trigger return boolean  ;
	function cf_calculate_totals_formula(Balance_Order in number, CS_Balance_Total in number) return number  ;
	function AfterReport return boolean  ;
	Function CP_BUSINESS_GROUP_NAME_p return varchar2;
	Function CP_PAYROLL_NAME_p return varchar2;
	Function CP_Time_Period_Time_p return varchar2;
	Function CP_CONSOLIDATION_SET_NAME_p return varchar2;
END PAY_PAYGBGTN_XMLP_PKG;

/
