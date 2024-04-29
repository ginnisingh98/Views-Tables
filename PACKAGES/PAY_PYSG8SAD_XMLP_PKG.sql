--------------------------------------------------------
--  DDL for Package PAY_PYSG8SAD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYSG8SAD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYSG8SADS.pls 120.0 2007/12/13 12:13:39 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_BASIS_YEAR	number;
	P_PERSON_ID	number;
	P_PAYROLL_ACTION_ID	number;
	P_ASSIGNMENT_SET_ID	number;
	P_LEGAL_ENTITY	number;
	P_BASIS_START	date;
	P_BASIS_END	date;
	P_CONC_REQUEST_ID	number;
	CP_OW	number;
	CP_OW_CPF_ER	number;
	CP_OW_CPF_EE	number;
	CP_OW_APR_FUND	number;
	CP_AW	number;
	CP_AW_CPF_ER	number;
	CP_AW_CPF_EE	number;
	CP_AW_APR_FUND	number;
	CP_AW_AMT	number;
	CP_AW_FR_DATE	varchar2(20);
	CP_AW_TO_DATE	varchar2(20);
	CP_REFUND_DATE	varchar2(20);
	CP_ER_CONTRIB	number;
	CP_ER_INTR	number;
	CP_ER_DATE	varchar2(20);
	CP_EE_CONTRIB	number;
	CP_EE_INTR	number;
	CP_EE_DATE	varchar2(20);
	CP_CPF_CAP_YES	varchar2(1);
	CP_ASG_SET_NAME	varchar2(25);
	CP_EMP_NO	varchar2(20);
	CP_CPF_CAP_NO	varchar2(1);
	CP_SYS_DATE	varchar2(20);
	CP_BASIS_END	varchar2(20);
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	function cf_monthly_detailsformula(assignment_action_id in number, date_earned in varchar2) return number  ;
	function cf_refund_detailsformula(ASSIGNMENT_ACTION_ID2 in number, ASS_EXTRA_ID in varchar2) return number  ;
	function delete_archive_data(t_payroll_action_id in number)return number  ;
	Function CP_OW_p return number;
	Function CP_OW_CPF_ER_p return number;
	Function CP_OW_CPF_EE_p return number;
	Function CP_OW_APR_FUND_p return number;
	Function CP_AW_p return number;
	Function CP_AW_CPF_ER_p return number;
	Function CP_AW_CPF_EE_p return number;
	Function CP_AW_APR_FUND_p return number;
	Function CP_AW_AMT_p return number;
	Function CP_AW_FR_DATE_p return varchar2;
	Function CP_AW_TO_DATE_p return varchar2;
	Function CP_REFUND_DATE_p return varchar2;
	Function CP_ER_CONTRIB_p return number;
	Function CP_ER_INTR_p return number;
	Function CP_ER_DATE_p return varchar2;
	Function CP_EE_CONTRIB_p return number;
	Function CP_EE_INTR_p return number;
	Function CP_EE_DATE_p return varchar2;
	Function CP_CPF_CAP_YES_p return varchar2;
	Function CP_ASG_SET_NAME_p return varchar2;
	Function CP_EMP_NO_p return varchar2;
	Function CP_CPF_CAP_NO_p return varchar2;
	Function CP_SYS_DATE_p return varchar2;
	Function CP_BASIS_END_p return varchar2;
END PAY_PYSG8SAD_XMLP_PKG;

/
