--------------------------------------------------------
--  DDL for Package PAY_PAYCNSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYCNSOE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYCNSOES.pls 120.1 2008/01/07 13:13:51 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_PAYROLL_ID	varchar2(40);
	P_CONSOLIDATION_SET_ID	varchar2(40);
	P_PAYOUT_LOCATION	varchar2(40);
	/*P_START_DATE	date;
	P_END_DATE	date;*/
	P_START_DATE	varchar2(40);
	P_END_DATE	varchar2(40);
	/* ADDED as fix:*/
	P_START_DATE_t	date;
	P_END_DATE_t	date;
	P_START_DATE_DISP varchar2(40);
	P_END_DATE_DISP varchar2(40);
	P_SORT_ORDER_1	varchar2(40);
	P_SORT_ORDER_2	varchar2(40);
	P_SORT_ORDER_3	varchar2(40);
	P_SORT_ORDER_4	varchar2(40);
	CP_Taxable_This_Pay	number;
	CP_Taxable_YTD	number;
	CP_Non_Taxable_This_Pay	number;
	CP_Non_Taxable_YTD	number;
	CP_Voluntary_This_Pay	number;
	CP_Voluntary_YTD	number;
	CP_Statutory_This_Pay	number;
	CP_Statutory_YTD	number;
	CP_ORDER_BY	varchar2(200);
	CP_Payroll_name	varchar2(100);
	CP_Consolidation_Set_name	varchar2(100);
	CP_Payroll_Location	varchar2(100);
	CP_Business_Group_name	varchar2(100);
	CP_Start_Date	date;
	CP_End_date	date;
	CP_Sort_Order_1	varchar2(40);
	CP_Sort_Order_2	varchar2(40);
	CP_Sort_Order_3	varchar2(40);
	CP_Sort_Order_4	varchar2(40);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	PROCEDURE set_currency_format_mask  ;
	function P_BUSINESS_GROUP_IDValidTrigge return boolean  ;
	function CF_Net_This_PayFormula return Number  ;
	function CF_Net_YTDFormula return Number  ;
	function cf_balancesformula(balance_org_name in varchar2, balances_this_Pay in number, balances_YTD in number) return number  ;
	PROCEDURE construct_order_by  ;
	PROCEDURE get_parameters_name  ;
	Function CP_Taxable_This_Pay_p return number;
	Function CP_Taxable_YTD_p return number;
	Function CP_Non_Taxable_This_Pay_p return number;
	Function CP_Non_Taxable_YTD_p return number;
	Function CP_Voluntary_This_Pay_p return number;
	Function CP_Voluntary_YTD_p return number;
	Function CP_Statutory_This_Pay_p return number;
	Function CP_Statutory_YTD_p return number;
	Function CP_ORDER_BY_p return varchar2;
	Function CP_Payroll_name_p return varchar2;
	Function CP_Consolidation_Set_name_p return varchar2;
	Function CP_Payroll_Location_p return varchar2;
	Function CP_Business_Group_name_p return varchar2;
	Function CP_Start_Date_p return date;
	Function CP_End_date_p return date;
	Function CP_Sort_Order_1_p return varchar2;
	Function CP_Sort_Order_2_p return varchar2;
	Function CP_Sort_Order_3_p return varchar2;
	Function CP_Sort_Order_4_p return varchar2;
END PAY_PAYCNSOE_XMLP_PKG;

/
