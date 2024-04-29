--------------------------------------------------------
--  DDL for Package PAY_PAYHKSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYHKSOE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYHKSOES.pls 120.0 2007/12/13 11:59:14 amakrish noship $ */
	P_SORT_ORDER_1	varchar2(60);
	P_SORT_ORDER_4	varchar2(60);
	P_SORT_ORDER_3	varchar2(60);
	P_SORT_ORDER_2	varchar2(60);
	P_Consolidation_Set	varchar2(32767);
	P_Payroll	varchar2(32767);
	P_Payments_From_Date	date;
	P_Payments_To_Date	date;
	P_Date_MPF_Paid_to_Trustee	date;
	P_CONC_REQUEST_ID	number;
	P_BUSINESS_GROUP_ID	number;
	Print_MPF_Flag	number;
	CP_Total_Earnings_This_Pay	number;
	CP_Total_Deductions_This_Pay	number;
	CP_Net_Pay_This_Pay	number;
	CP_Direct_Payments_This_Pay	number;
	CP_Total_Payment_This_Pay	number;
	CP_Total_Earnings_YTD	number;
	CP_Total_Deductions_YTD	number;
	CP_Net_Pay_YTD	number;
	CP_Direct_Payments_YTD	number;
	CP_Total_Payment_YTD	number;
	CP_Count	number;
	CP_start_date	date;
	CP_End_Date	date;
	CP_accrual_end_date	date;
	CP_accrual	number;
	CP_net_entitlement	number;
	cp_order_by	varchar2(240);
	CP_sort_by	varchar2(4);
	CP_where_clause	varchar2(240);
	/*ADDED AS FIX*/
	      P_PAYMENTS_FROM_DATE_DISP   VARCHAR2(40);
	      P_PAYMENTS_TO_DATE_DISP VARCHAR2(40);
	function BeforeReport return boolean  ;
	PROCEDURE construct_order_by  ;
	PROCEDURE construct_where_clause  ;
	function cf_get_balances_totalsformula(assignment_action_id4 in number, tax_unit_id1 in number) return number  ;
	function AfterReport return boolean  ;
	function CF_currency_format_maskFormula return VARCHAR2  ;
	function CF_MPF_Flag1Formula return Number  ;
	function cf_mpf_flag2formula(CS_Count in number, element_name_sort1 in number) return number  ;
	function cf_net_accrualformula(assignment_id3 in number, accrual_plan_id1 in number, payroll_id in number, business_group_id in number, end_date1 in date) return number  ;
	Function CP_Total_Earnings_This_Pay_p return number;
	Function CP_Total_Deductions_This_Pay_p return number;
	Function CP_Net_Pay_This_Pay_p return number;
	Function CP_Direct_Payments_This_Pay_p return number;
	Function CP_Total_Payment_This_Pay_p return number;
	Function CP_Total_Earnings_YTD_p return number;
	Function CP_Total_Deductions_YTD_p return number;
	Function CP_Net_Pay_YTD_p return number;
	Function CP_Direct_Payments_YTD_p return number;
	Function CP_Total_Payment_YTD_p return number;
	Function CP_Count_p return number;
	Function CP_start_date_p return date;
	Function CP_End_Date_p return date;
	Function CP_accrual_end_date_p return date;
	Function CP_accrual_p return number;
	Function CP_net_entitlement_p return number;
	Function cp_order_by_p return varchar2;
	Function CP_sort_by_p return varchar2;
	Function CP_where_clause_p return varchar2;
	Function PRINT_MPF_FLAG_p return number;
END PAY_PAYHKSOE_XMLP_PKG;

/
