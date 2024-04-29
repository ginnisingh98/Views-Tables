--------------------------------------------------------
--  DDL for Package PAY_PYNZSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYNZSOE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYNZSOES.pls 120.0 2007/12/13 12:12:54 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_Payroll_Id	number;
	P_Payroll_Action_Id	number;
	P_SORT_ORDER_1	varchar2(60);
	P_SORT_ORDER_2	varchar2(60);
	P_SORT_ORDER_3	varchar2(60);
	P_SORT_ORDER_4	varchar2(60);
	P_Location_Id	number;
	P_ORGANISATION_NAME	varchar2(60);
	P_Assignment_id	number;
	P_Address_Line_1	varchar2(28);
	P_Address_Line_2	varchar2(28);
	P_Address_Line_3	varchar2(28);
	P_Town_City	varchar2(28);
	P_PostCode	varchar2(28);
	P_Country	varchar2(28);
	P_Position_Name	varchar2(30);
	CP_non_tax_allow_this_pay	number;
	CP_non_tax_allow_ytd	number;
	CP_gross_ytd	number;
	CP_gross_this_pay	number;
	CP_other_deductions_ytd	number;
	CP_other_deductions_this_pay	number;
	CP_tax_deductions_ytd	number;
	CP_pre_tax_deductions_this_pay	number;
	CP_pre_tax_deductions_ytd	number;
	CP_tax_deductions_this_pay	number;
	P_Cumulative_Leave_Bal	number := 0 ;
	CP_Where_Clause	varchar2(2000);
	CP_Payroll_Name	varchar2(80);
	CP_Payment_Run	varchar2(80);
	CP_ORDER_BY	varchar2(2000);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	--function f_get_detailsformula(ass_number in varchar2, assignment_id in number, date_earned in date, home_office_ind in varchar2, person_id1 in number, location_id1 in number) return number  ;
	function f_get_detailsformula(ass_number in varchar2, v_assignment_id in number, date_earned in date, home_office_ind in varchar2, person_id1 in number, location_id1 in number) return number  ;
	function f_get_cumulative_leave_balform(leave_balance_absence_type in varchar2, leave_balance_assignment_id in number, leave_balance_payroll_id in number, leave_balance_bus_grp_id in number, leave_balance_accrual_plan_id in number,
	period_end_date in date) return number  ;
	function cf_amount_paidformula(classification_name in varchar2, earnings_element_value in number) return number  ;
	function cf_get_miscellaneous_valuesfor(assignment_id in number, run_ass_action_id_link_from_q1 in number, date_earned in date) return number  ;
	function CF_net_this_payFormula return Number  ;
	function CF_net_ytdFormula return Number  ;
	function CF_CURRENCY_FORMAT_MASKFormula return VARCHAR2  ;
	function G_Asg_Payments_Break_GGroupFil return boolean  ;
	Function P_Address_Line_1_p return varchar2;
	Function P_Address_Line_2_p return varchar2;
	Function P_Address_Line_3_p return varchar2;
	Function P_Town_City_p return varchar2;
	Function P_PostCode_p return varchar2;
	Function P_Country_p return varchar2;
	Function P_Position_Name_p return varchar2;
	Function CP_non_tax_allow_this_pay_p return number;
	Function CP_non_tax_allow_ytd_p return number;
	Function CP_gross_ytd_p return number;
	Function CP_gross_this_pay_p return number;
	Function CP_other_deductions_ytd_p return number;
	Function CP_other_deductions_this_pay_p return number;
	Function CP_tax_deductions_ytd_p return number;
	Function CP_pre_tax_deductions_this_pa return number;
	Function CP_pre_tax_deductions_ytd_p return number;
	Function CP_tax_deductions_this_pay_p return number;
	Function P_Cumulative_Leave_Bal_p return number;
	Function CP_Where_Clause_p return varchar2;
	Function CP_Payroll_Name_p return varchar2;
	Function CP_Payment_Run_p return varchar2;
	Function CP_ORDER_BY_p return varchar2;
END PAY_PYNZSOE_XMLP_PKG;

/
