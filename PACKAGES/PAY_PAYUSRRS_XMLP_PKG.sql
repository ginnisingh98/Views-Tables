--------------------------------------------------------
--  DDL for Package PAY_PAYUSRRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYUSRRS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYUSRRSS.pls 120.0 2007/12/28 06:47:47 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_PERSON_ID	varchar2(40);
	P_REPORT_SUBTITLE	varchar2(100);
	P_TAX_UNIT_ID	varchar2(40);
	P_ASSIGNMENT_NUMBER	varchar2(40);
	P_START_DATE	date;
	LP_START_DATE date;
	P_END_DATE	date;
	LP_END_DATE date;
	P_CLASSIFICATION_ID	varchar2(40);
	P_where_clause	varchar2(2000);
	P_asg_set_id	varchar2(40);
	P_from_clause	varchar2(2000);
	p_hint_clause	varchar2(2000);
	P_selection_criteria	varchar2(32767);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_PERSON_NAME	varchar2(240);
	C_CLASSIFICATION_NAME	varchar2(80);
	CP_GRE_NAME	varchar2(240);
	CP_asg_set_name	varchar2(240);
	function BeforeReport return boolean  ;
	function element_categoryformula(element_information_category in varchar2, element_information1 in varchar2) return varchar2  ;
	FUNCTION GET_BUSINESS_GROUP_NAME(fp_business_group_id IN NUMBER) RETURN VARCHAR2  ;
	function gre_nameformula(TAX_UNIT_ID in number) return varchar2 ;
	function CF_con_dateFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_PERSON_NAME_p return varchar2;
	Function C_CLASSIFICATION_NAME_p return varchar2;
	Function CP_GRE_NAME_p return varchar2;
	Function CP_asg_set_name_p return varchar2;
	/*Added as a fix*/
	function RVALUEFormula(RESULT_VALUE VARCHAR2) return Number;
END PAY_PAYUSRRS_XMLP_PKG;

/
