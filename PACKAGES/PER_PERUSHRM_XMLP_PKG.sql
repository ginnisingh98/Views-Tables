--------------------------------------------------------
--  DDL for Package PER_PERUSHRM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERUSHRM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERUSHRMS.pls 120.0 2007/12/28 07:02:09 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_TAX_UNIT_ID	number;
	P_REPORT_DATE	varchar2(32767);
	P_STATE_CODE	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_AUDIT_REPORT	varchar2(32767);
	P_MULTI_STATE	varchar2(32767);
	P_MULTI_STATE_1	varchar2(32767);
	P_REPORT_MODE	varchar2(1);
	CP_pre_tax_unit_id	number;
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_TAX_UNIT	varchar2(240);
	C_STATE_NAME	varchar2(60);
	C_MEDICAL_AVAIL	varchar2(4);
	C_END_OF_TIME	date;
	C_STATE_COUNT	number;
	C_OLD_STATE	varchar2(20);
	C_no_of_newhire	number;
	C_no_of_gre	number;
	C_no_of_multi_state	number;
	C_Fatal_error_flag	number;
	C_a03_header_flag	number;
	function BeforeReport return boolean ;
	function c_employee_addressformula(person_id in number) return varchar2  ;
	function c_salaryformula(assignment_id in number) return number  ;
	function AfterReport (CS_NO_OF_NEW_HIRE in number)return boolean ;
	function G_new_hiresGroupFilter return boolean  ;
	function BetweenPage return boolean  ;
	function CF_new_hireFormula (SUI_COMPANY_STATE_ID in varchar2,DATE_START in date,FEDERAL_ID in varchar2
	,NATIONAL_IDENTIFIER in varchar2,MIDDLE_NAME in varchar2,gre_location_id in number,HIRE_STATE in varchar2
	,person_id in number,LAST_NAME in varchar2,FIRST_NAME in varchar2,DATE_OF_BIRTH in date,
	TAX_UNIT_NAME in varchar2,FULL_MIDDLE_NAME in varchar2,SIT_COMPANY_STATE_ID in varchar2,
	c_contact_name in varchar2,c_contact_phone in varchar2)return Number ;
	PROCEDURE char_set_init
(
                p_character_set in varchar2
) ;
	--procedure new_hire_record  ;
	 procedure   new_hire_record(person_id in number,NATIONAL_IDENTIFIER in varchar2,FIRST_NAME in varchar2,
	 MIDDLE_NAME in varchar2,LAST_NAME in varchar2,DATE_START in date,FULL_MIDDLE_NAME in varchar2,
	 gre_location_id in number,DATE_OF_BIRTH in date,HIRE_STATE in varchar2,FEDERAL_ID in number,
	 SUI_COMPANY_STATE_ID in varchar2,TAX_UNIT_NAME in varchar2,c_contact_phone in number,
	 c_contact_name in varchar2,SIT_COMPANY_STATE_ID in varchar2) ;
	PROCEDURE TOTAL_RECORD  ;
	procedure a01_header_record(TAX_UNIT_ID in number,federal_id in varchar2) ;
	--procedure a01_header_record  ;
	--procedure a01_total_record  ;
	procedure a01_total_record(CS_NO_OF_NEW_HIRE in number);
	PROCEDURE A03_HEADER_RECORD  ;
	PROCEDURE P_MAG_UPDATE_STATUS  ;
	function CF_GREFormula (FEDERAL_ID in varchar2,gre_location_id in number,TAX_UNIT_ID in number,
	TAX_UNIT_NAME in varchar2,SIT_COMPANY_STATE_ID in varchar2)return Number ;
	function c_contact_nameformula(new_hire_contact_id in varchar2) return varchar2  ;
	function c_contact_phoneformula(new_hire_contact_id in varchar2) return varchar2  ;
	function c_contact_titleformula(new_hire_contact_id in varchar2) return varchar2  ;
	function c_tax_unit_addressformula(location_id in number) return varchar2  ;
	--procedure gre_record(federal_id in varchar2,TAX_UNIT_ID in number) ;
	procedure gre_record(gre_location_id in number, federal_id in varchar2,TAX_UNIT_ID in number,
	SIT_COMPANY_STATE_ID in varchar2, TAX_UNIT_NAME in varchar2) ;
	PROCEDURE P_OUTPUT_NEW_HIRE_NULL  ;
	Function CP_pre_tax_unit_id_p return number;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_TAX_UNIT_p return varchar2;
	Function C_STATE_NAME_p return varchar2;
	Function C_MEDICAL_AVAIL_p return varchar2;
	Function C_END_OF_TIME_p return date;
	Function C_STATE_COUNT_p return number;
	Function C_OLD_STATE_p return varchar2;
	Function C_no_of_newhire_p return number;
	Function C_no_of_gre_p return number;
	Function C_no_of_multi_state_p return number;
	Function C_Fatal_error_flag_p return number;
	Function C_a03_header_flag_p return number;
END PER_PERUSHRM_XMLP_PKG;

/
