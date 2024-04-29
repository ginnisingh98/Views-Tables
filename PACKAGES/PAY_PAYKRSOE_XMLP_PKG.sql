--------------------------------------------------------
--  DDL for Package PAY_PAYKRSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYKRSOE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYKRSOES.pls 120.0 2007/12/13 12:11:40 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_PAYROLL_ID	number;
	P_ESTABLISHMENT_ID	varchar2(150);
	P_ASSIGNMENT_ID	varchar2(150);
	P_TIME_PERIOD_ID	number;
	P_SORT_ORDER_1	varchar2(50);
	P_SORT_ORDER_2	varchar2(50);
	LeaveBalance	number;
	CP_PERIOD	varchar2(100);
	CP_Payroll_Name	varchar2(100);
	CP_RunType_Period	varchar2(100);
	CP_BUS_PLACE	varchar2(100);
	CP_Assign_Num	varchar2(20);
	CP_Warning_Message	varchar2(200);
	CP_SORT_OPTION	varchar2(100);
	GlVar_Earnings number;
        GlVar_Deductions number;
        GlVar_Hours number;
        GlVar_Earnings_Frame_Count number ;
        GlVar_Deductions_Frame_Count number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	PROCEDURE set_currency_format_mask  ;
	function P_BUSINESS_GROUP_IDValidTrigge return boolean  ;
	function BetweenPage return boolean  ;
	function leavetakenformula(Leave_Taken_Dim_Bal in varchar2, End_Date_Bal in date, Assignment_Id_Bal in number, Accrual_Plan_Id_Bal in number,
	Start_Date_Bal in date, Payroll_Id_Bal in number, Business_Group_Id_Bal in number, Assignment_Action_Id_Bal in number) return number  ;
	function cf_miscearningsformula(Assignment_Action_Id in number) return number  ;
	function cf_mischoursformula(Assignment_Action_Id in number) return number  ;
	function cf_miscdeductionsformula(Assignment_Action_Id in number) return number  ;
	function AfterPForm return boolean  ;
	function CF_Effective_DateFormula return Date  ;
	function cf_messageflagformula(Payroll_Action_Id_Payroll in number) return number  ;
	Function LeaveBalance_p return number;
	Function CP_PERIOD_p return varchar2;
	Function CP_Payroll_Name_p return varchar2;
	Function CP_RunType_Period_p return varchar2;
	Function CP_BUS_PLACE_p return varchar2;
	Function CP_Assign_Num_p return varchar2;
	Function CP_Warning_Message_p return varchar2;
	Function CP_SORT_OPTION_p return varchar2;
END PAY_PAYKRSOE_XMLP_PKG;

/
