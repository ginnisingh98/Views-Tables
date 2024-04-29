--------------------------------------------------------
--  DDL for Package PER_PERRPADD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERRPADD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERRPADDS.pls 120.1 2007/12/06 11:27:50 amakrish noship $ */
	INPUT_START_DATE	date;
	INPUT_END_DATE	date;
	LP_INPUT_START_DATE date;
	LP_INPUT_END_DATE date;
	BUSINESS_ID	varchar2(40);
	P_install	varchar2(32767);
	GRE_ID	number;
	P_CONC_REQUEST_ID	number;
	ADDITIONAL_VERIFICATION	varchar2(30);
	LINE_LENGTH	number;
	CP_print_gre	number;
	CP_missing_flag	number := 0 ;
	CP_old_address_id	number;
	CP_prev_person_id	number;
	CP_prev_name	varchar2(240);
	CP_temp_id	number;
	CP_prev_gre_name	varchar2(240);
	CP_addr_count	number;
	CP_missing_st	date;
	CP_missing_end	date;
	CP_reason	varchar2(100);
	CP_reason1	varchar2(100);
	CP_missing_st1	date;
	CP_missing_end1	date;
	CP_keep_count	number;
	CP_prev_date_to	date;
	function cf_addr_chkformula(gre_name in varchar2, person_id in number, CS_no_of_addr in number, address_id in number, add_date_to in date, effective_start_date in date, effective_end_date in date,
	date_from in date, address_line1 in varchar2, location_address in varchar2, town_or_city in varchar2, address_line2 in varchar2, address_line3 in varchar2) return number  ;
	function INPUT_END_DATEValidTrigger return boolean  ;
	function INPUT_START_DATEValidTrigger return boolean  ;
	function AfterPForm return boolean
 ;
	function CF_gre_nameFormula return VARCHAR2
 ;
	function CF_bus_grpFormula return VARCHAR2
 ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function CF_header_notesFormula return Char  ;
	function ADDITIONAL_VERIFICATIONValidTr return boolean  ;
	function LINE_LENGTHValidTrigger return boolean  ;
	Function CP_print_gre_p return number;
	Function CP_missing_flag_p return number;
	Function CP_old_address_id_p return number;
	Function CP_prev_person_id_p return number;
	Function CP_prev_name_p return varchar2;
	Function CP_temp_id_p return number;
	Function CP_prev_gre_name_p return varchar2;
	Function CP_addr_count_p return number;
	Function CP_missing_st_p return date;
	Function CP_missing_end_p return date;
	Function CP_reason_p return varchar2;
	Function CP_reason1_p return varchar2;
	Function CP_missing_st1_p return date;
	Function CP_missing_end1_p return date;
	Function CP_keep_count_p return number;
	Function CP_prev_date_to_p return date;
END PER_PERRPADD_XMLP_PKG;

/
