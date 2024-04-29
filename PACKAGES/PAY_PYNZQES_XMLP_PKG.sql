--------------------------------------------------------
--  DDL for Package PAY_PYNZQES_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYNZQES_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYNZQESS.pls 120.0 2007/12/13 12:12:31 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_SURVEY_DATE	date;
	CP_report_name	varchar2(8);
	CP_statistics_balance_name	varchar2(30);
	CP_balance_dimension	varchar2(20);
	CP_hours_balance_name	varchar2(32767);
	CP_payout_balance_name	varchar2(32767);
	CP_application_id	number;
	CP_week_hours	number;
	CP_week_frequency	varchar2(20);
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function CF_legislation_codeFormula return VARCHAR2  ;
	function CP_report_nameFormula return VARCHAR2  ;
	function CP_statistics_balance_nameForm return VARCHAR2  ;
	function CP_balance_dimensionFormula return VARCHAR2  ;
	function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2  ;
	function CP_hours_balance_nameFormula return VARCHAR2  ;
	function CP_payout_balance_nameFormula return VARCHAR2  ;
	function CP_application_idFormula return Number  ;
	function CP_week_frequencyFormula return Char  ;
	function CP_week_hoursFormula return Number  ;
	Function CP_report_name_p return varchar2;
	Function CP_statistics_balance_name_p return varchar2;
	Function CP_balance_dimension_p return varchar2;
	Function CP_hours_balance_name_p return varchar2;
	Function CP_payout_balance_name_p return varchar2;
	Function CP_application_id_p return number;
	Function CP_week_hours_p return number;
	Function CP_week_frequency_p return varchar2;
END PAY_PYNZQES_XMLP_PKG;

/
