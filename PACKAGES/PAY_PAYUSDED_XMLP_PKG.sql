--------------------------------------------------------
--  DDL for Package PAY_PAYUSDED_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYUSDED_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYUSDEDS.pls 120.0 2007/12/28 06:44:29 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_CONSOLIDATION_SET_ID	number;
	P_PAYROLL_ID	number;
	P_START_DATE	date;
	P_END_DATE	date;
	P_ELEMENT_TYPE_ID	number;
	P_SORT_OPTION1	varchar2(32767);
	P_SORT_OPTION2	varchar2(32767);
	P_SORT_OPTION3	varchar2(32767);
	P_TAX_UNIT_ID	number;
	P_LOCATION_ID	number;
	P_ORGANIZATION_ID	number;
	P_PERSON_ID	number;
	P_CLASSIFICATION_ID	number;
	P_ELEMENT_SET_ID	number;
	P_SELECTION_CRITERION	varchar2(30);
	P_where_clause	varchar2(4000) := ' ' ;
	P_hint	varchar2(1000);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_Consolidation_set	varchar2(60);
	C_Payroll	varchar2(80);
	C_Classification	varchar2(80);
	C_Element_name	varchar2(80);
	C_GRE	varchar2(240);
	C_Location	varchar2(60);
	C_Organization	varchar2(240);
	C_Person	varchar2(240);
	C_ELEMENT_SET	varchar2(50);
	function BeforeReport return boolean  ;
	function C_REPORT_SUBTITLEFormula return VARCHAR2  ;
	function scheduled_dednformula(primary_balance in number, not_taken_balance in number, arrears_taken in number) return number  ;
	function current_arrearsformula(arrears_balance in number) return number  ;
	function arrears_takenformula(arrears_balance in number) return number  ;
	function remainingformula(total_owed in number, CF_Accrued in number) return number  ;
	function element_total_textformula(element_name in varchar2) return varchar2  ;
	function classification_total_textformu(classification_name in varchar2) return varchar2  ;
	function s3_total_textformula(sort_option1_value in varchar2, sort_option2_value in varchar2, sort_option3_value in varchar2) return varchar2  ;
	function s2_total_textformula(sort_option1_value in varchar2, sort_option2_value in varchar2) return varchar2  ;
	function s1_total_textformula(sort_option1_value in varchar2) return varchar2  ;
	function person_total_textformula(full_name in varchar2) return varchar2  ;
	function cf_sort1formula(Sort_option1 in varchar2) return varchar2  ;
	function cf_sort2formula(Sort_option2 in varchar2) return varchar2  ;
	function cf_sort3formula(Sort_option3 in varchar2) return varchar2  ;
	function cf_sort1_valueformula(Sort_option1_value in varchar2) return varchar2  ;
	function cf_sort2_valueformula(Sort_option2_value in varchar2) return varchar2  ;
	function cf_sort3_valueformula(Sort_option3_value in varchar2) return varchar2  ;
	function cf_accruedformula(accrued_balance in varchar2, Primary_balance in number, Total_owed in number) return number  ;
	function s3_textformula(sort_option1_value in varchar2, Sort_option1 in varchar2, sort_option2_value in varchar2, Sort_option2 in varchar2, sort_option3_value in varchar2, Sort_option3 in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_Consolidation_set_p return varchar2;
	Function C_Payroll_p return varchar2;
	Function C_Classification_p return varchar2;
	Function C_Element_name_p return varchar2;
	Function C_GRE_p return varchar2;
	Function C_Location_p return varchar2;
	Function C_Organization_p return varchar2;
	Function C_Person_p return varchar2;
	Function C_ELEMENT_SET_p return varchar2;
END PAY_PAYUSDED_XMLP_PKG;

/
