--------------------------------------------------------
--  DDL for Package PAY_PYCAROEP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYCAROEP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PYCAROEPS.pls 120.0 2007/12/28 06:48:56 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_START_DATE	varchar2(21);
	P_END_DATE	varchar2(21);
	LP_DATE_OR_PERSON	varchar2(2000);
	P_PERSON_ID	varchar2(32767);
	P_ASSIGNMENT_SET	varchar2(32767);
	LP_ASSIGNMENT_SET	varchar2(50);
	P_SELECTION_TYPE	varchar2(50);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	CP_PERSON	varchar2(240);
	CP_Effective_date	date;
	CP_Assignment_set_name	varchar2(50);
	CP_selection_type	varchar2(80);
	CP_start_date	date;
	CP_end_date	date;
	function BeforeReport return boolean  ;
	function AfterPForm return boolean  ;
	function cf_languageformula(ROE_PER_CORRESPONDENCE_LANG1 in varchar2, ROE_FINAL_PAY_PERIOD_END_DATE in varchar2) return char  ;
	function cf_roe_pay_period_typeformula(ROE_PAY_PERIOD_TYPE1 in varchar2) return char  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function CP_PERSON_p return varchar2;
	Function CP_Effective_date_p return date;
	Function CP_Assignment_set_name_p return varchar2;
	Function CP_selection_type_p return varchar2;
	Function CP_start_date_p return date;
	Function CP_end_date_p return date;
END PAY_PYCAROEP_XMLP_PKG;

/
