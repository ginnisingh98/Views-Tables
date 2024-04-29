--------------------------------------------------------
--  DDL for Package PER_PERFRMMO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERFRMMO_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERFRMMOS.pls 120.1 2008/03/06 10:34:11 amakrish noship $ */
	P_BUSINESS_GROUP_ID	varchar2(25);
	P_SESSION_DATE	date := to_date('31-03-2000','DD-MM-YYYY');
	P_ESTABLISHMENT_ID	number;
	P_PERIOD_START_DATE	date :=  to_date('31-01-2000','DD-MM-YYYY');
	P_PERIOD_END_DATE	date :=  to_date('31-03-2000','DD-MM-YYYY');
	P_INCLUDE_SUSPENDED	varchar2(1);
	P_CONC_REQUEST_ID	number;
	C_COUNT_PREVIOUS_PERIOD	number;
	C_COUNT_PERIOD	number;
	C_COUNT_MEN	number;
	C_COUNT_WOMEN	number;
	C_TEMPORARY	number;
	C_JOB	varchar2(40);
	C_JOB_PCS	varchar2(32767);
	C_START_REASON	varchar2(2);
	C_END_REASON	varchar2(2);
	C_CHECK_STARTED	number;
	C_CHECK_LEFT	number;
	C_EFFECTIVE_START_DATE	date;
	P_FORMULA_ID	number;
	function CF_GET_HEADERFormula return Number  ;
	function BeforeReport return boolean  ;
	function c_get_nationalityformula(NATIONALITY in varchar2) return varchar2  ;
	function c_get_asgformula(PERSON_ID1 in number, START_DATE in date, END_DATE in date) return number  ;
	function AfterReport return boolean  ;
	Function C_COUNT_PREVIOUS_PERIOD_p return number;
	Function C_COUNT_PERIOD_p return number;
	Function C_COUNT_MEN_p return number;
	Function C_COUNT_WOMEN_p return number;
	Function C_TEMPORARY_p return number;
	Function C_JOB_p return varchar2;
	Function C_JOB_PCS_p return varchar2;
	Function C_START_REASON_p return varchar2;
	Function C_END_REASON_p return varchar2;
	Function C_CHECK_STARTED_p return number;
	Function C_CHECK_LEFT_p return number;
	Function C_EFFECTIVE_START_DATE_p return date;
	Function P_FORMULA_ID_p return number;
END PER_PERFRMMO_XMLP_PKG;

/
