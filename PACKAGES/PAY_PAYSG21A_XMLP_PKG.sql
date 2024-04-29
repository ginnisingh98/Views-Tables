--------------------------------------------------------
--  DDL for Package PAY_PAYSG21A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYSG21A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYSG21AS.pls 120.0 2007/12/13 12:13:05 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_PERSON_ID	varchar2(40);
	P_BASIS_YEAR	number;
	P_IR21_MODE	varchar2(32767);
	P_CR_YEAR_AMOUNT	number;
	P_RUN	number;
	P_PR_YEAR_AMOUNT	number;
	CP_1	number;
	CP_2	number;
	CP_3	number;
	CP_4	number;
	CP_5	number;
	CP_6	number;
	CP_7	number;
	function BeforeReport return boolean  ;
	--function afterreport(CS_1 in number, CS_2 in number) return boolean  ;
	function afterreport(CS_1 in number, CS_2 in number,CS_3 in number) return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	PROCEDURE set_currency_format_mask  ;
	function P_BUSINESS_GROUP_IDValidTrigge return boolean  ;
	function cf_gross_amt_not_tax_exemptfor(stock_option in number, market_value_exercise in varchar2, exercise_price in varchar2, no_of_shares_acq in varchar2, market_value_grant in varchar2) return number  ;
	function cf_2formula(CS_1 in number, CS_2 in number, CS_3 in number) return number  ;
	function submit_request(t_business_group_id in number,t_person_id in number,t_basis_year in number,
                        t_ir21_mode in varchar2,t_cu_amt in number,t_pr_amt in number,t_run in number,
                        t_report_short_name in varchar2) return number  ;
	Function CP_1_p return number;
	Function CP_2_p return number;
	Function CP_3_p return number;
	Function CP_4_p return number;
	Function CP_5_p return number;
	Function CP_6_p return number;
	Function CP_7_p return number;
END PAY_PAYSG21A_XMLP_PKG;

/
