--------------------------------------------------------
--  DDL for Package PAY_PAYHKMPF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYHKMPF_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYHKMPFS.pls 120.0 2007/12/13 11:59:01 amakrish noship $ */
	P_CONC_REQUEST_ID	number;
	P_LEGAL_EMPLOYER_ID	number;
	P_SCHEME_ID	number;
	P_CONTRIBUTIONS_START_DATE	date;
	P_CONTRIBUTIONS_END_DATE	date;
	P_SURCHARGE_PARTI_MAND	number;
	P_SURCHARGE_PARTI_VOL	number;
	P_SURCHARGE_PARTII_MAND	number;
	P_SURCHARGE_PARTII_VOL	number;
	--P_GLOBAL_SEQUENCE_NO	number;
	P_GLOBAL_SEQUENCE_NO	number:= 0;
	P_BUSINESS_GROUP_ID	number;
	CP_display_sequence_1	number;
	CP_display_sequence_2	number;
	CP_where_current	varchar2(2000);
	CP_scheme_name	varchar2(156);
	CP_scheme_reg_number	varchar2(51);
	CP_employer_name	varchar2(96);
	CP_contact	varchar2(96);
	CP_address	varchar2(1500);
	CP_telephone_no	varchar2(96);
	CP_participation_no	varchar2(51);
	CP_CURRENCY_FORMAT_MASK_12	varchar2(100);
	CP_CURRENCY_FORMAT_MASK_14	varchar2(100);
	/*added as fix:*/
	P_SURCHARGE_PARTI_MAND_t number;
	P_SURCHARGE_PARTI_VOL_t number;
	P_SURCHARGE_PARTII_MAND_t number;
	P_SURCHARGE_PARTII_VOL_t number;
	   P_CONTRIBUTIONS_START_DATE_T varchar(25);
	   P_CONTRIBUTIONS_END_DATE_T varchar(25);
	   EFFECTIVE_DATE VARCHAR(25);
	/* fix ends */
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	PROCEDURE construct_where_clause  ;
	PROCEDURE construct_scheme_employer  ;
	function cf_total_mandatoryformula(er_mandatory in number, ee_mandatory in number) return number  ;
	function cf_total_voluntaryformula(er_voluntary in number, ee_voluntary in number) return number  ;
	function cf_part1_mandatoryformula(CS_er_mandatory in number, CS_ee_mandatory in number) return number  ;
	function cf_part1_voluntaryformula(CS_er_voluntary in number, CS_ee_voluntary in number) return number  ;
	function CF_sequence_noFormula return Number  ;
	function CF_CURRENCY_FORMAT_MASKFormula return Number  ;
	function cf_total_mandatory1formula(er_mandatory1 in number, ee_mandatory1 in number) return number  ;
	function cf_total_voluntary1formula(er_voluntary1 in number, ee_voluntary1 in number) return number  ;
	function cf_partii_mandatoryformula(CS_er_mandatory1 in number, CS_ee_mandatory1 in number) return number  ;
	function cf_partii_voluntaryformula(CS_er_voluntary1 in number, CS_ee_voluntary1 in number) return number  ;
	function cf_overall_mandatoryformula(CF_parti_mandatory in number, CF_partii_mandatory in number) return number  ;
	function cf_overall_voluntaryformula(CF_parti_voluntary in number, CF_partii_voluntary in number) return number  ;
	function CF_sequence_no1Formula return Number  ;
	Function CP_display_sequence_1_p return number;
	Function CP_display_sequence_2_p return number;
	Function CP_where_current_p return varchar2;
	Function CP_scheme_name_p return varchar2;
	Function CP_scheme_reg_number_p return varchar2;
	Function CP_employer_name_p return varchar2;
	Function CP_contact_p return varchar2;
	Function CP_address_p return varchar2;
	Function CP_telephone_no_p return varchar2;
	Function CP_participation_no_p return varchar2;
	Function CP_CURRENCY_FORMAT_MASK_12_p return varchar2;
	Function CP_CURRENCY_FORMAT_MASK_14_p return varchar2;
END PAY_PAYHKMPF_XMLP_PKG;

/
