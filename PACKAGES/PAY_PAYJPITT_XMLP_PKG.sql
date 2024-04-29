--------------------------------------------------------
--  DDL for Package PAY_PAYJPITT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYJPITT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYJPITTS.pls 120.0 2007/12/13 12:00:56 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_YEAR	number;
	P_ITAX_ORGANIZATION_ID	number;
	P_CONC_REQUEST_ID	number;
	P_START_DATE	date;
	P_END_DATE	date;
	CP_A_OTHER_COUNT	number := 0 ;
	CP_A_OTHER_ZERO_ITAX_COUNT	number := 0 ;
	CP_A_OTHER_TAXABLE_INCOME	number := 0 ;
	CP_A_OTHER_ITAX	number := 0 ;
	CP_A_HEI_COUNT	number := 0 ;
	CP_A_HEI_ZERO_ITAX_COUNT	number := 0 ;
	CP_A_HEI_TAXABLE_INCOME	number := 0 ;
	CP_A_HEI_ITAX	number := 0 ;
	CP_A_COUNT	number := 0 ;
	CP_A_ZERO_ITAX_COUNT	number := 0 ;
	CP_A_TAXABLE_INCOME	number := 0 ;
	CP_A_ITAX	number := 0 ;
	CP_B_OTHER_COUNT	number := 0 ;
	CP_B_OTHER_TAXABLE_INCOME	number := 0 ;
	CP_B_OTHER_ITAX	number := 0 ;
	CP_B_HEI_COUNT	number := 0 ;
	CP_B_HEI_TAXABLE_INCOME	number := 0 ;
	CP_B_HEI_ITAX	number := 0 ;
	CP_B_COUNT	number := 0 ;
	CP_B_TAXABLE_INCOME	number := 0 ;
	CP_B_ITAX	number := 0 ;
	CP_TERM_COUNT	number := 0 ;
	CP_TERM_TAXABLE_INCOME	number := 0 ;
	CP_TERM_ITAX	number := 0 ;
	CP_REPORT_TITLE	varchar2(255);
	CP_B_DISASTERED_COUNT	number := 0 ;
	CP_B_DISASTER_TAX_REDUCTION	number := 0 ;
	CP_TAX_OFFICE_NAME	varchar2(150);
	CP_EMPLOYER_POSTAL_CODE	varchar2(150);
	CP_EMPLOYER_ADDRESS	varchar2(450);
	CP_EMPLOYER_NAME	varchar2(150);
	CP_EMPLOYER_TELEPHONE_NUMBER	varchar2(150);
	function BeforeReport return boolean  ;
	function to_jp_char(p_date		in date,
	p_date_format	in varchar2) return varchar2 ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function CP_A_OTHER_COUNT_p return number;
	Function CP_A_OTHER_ZERO_ITAX_COUNT_p return number;
	Function CP_A_OTHER_TAXABLE_INCOME_p return number;
	Function CP_A_OTHER_ITAX_p return number;
	Function CP_A_HEI_COUNT_p return number;
	Function CP_A_HEI_ZERO_ITAX_COUNT_p return number;
	Function CP_A_HEI_TAXABLE_INCOME_p return number;
	Function CP_A_HEI_ITAX_p return number;
	Function CP_A_COUNT_p return number;
	Function CP_A_ZERO_ITAX_COUNT_p return number;
	Function CP_A_TAXABLE_INCOME_p return number;
	Function CP_A_ITAX_p return number;
	Function CP_B_OTHER_COUNT_p return number;
	Function CP_B_OTHER_TAXABLE_INCOME_p return number;
	Function CP_B_OTHER_ITAX_p return number;
	Function CP_B_HEI_COUNT_p return number;
	Function CP_B_HEI_TAXABLE_INCOME_p return number;
	Function CP_B_HEI_ITAX_p return number;
	Function CP_B_COUNT_p return number;
	Function CP_B_TAXABLE_INCOME_p return number;
	Function CP_B_ITAX_p return number;
	Function CP_TERM_COUNT_p return number;
	Function CP_TERM_TAXABLE_INCOME_p return number;
	Function CP_TERM_ITAX_p return number;
	Function CP_REPORT_TITLE_p return varchar2;
	Function CP_B_DISASTERED_COUNT_p return number;
	Function CP_B_DISASTER_TAX_REDUCTION_p return number;
	Function CP_TAX_OFFICE_NAME_p return varchar2;
	Function CP_EMPLOYER_POSTAL_CODE_p return varchar2;
	Function CP_EMPLOYER_ADDRESS_p return varchar2;
	Function CP_EMPLOYER_NAME_p return varchar2;
	Function CP_EMPLOYER_TELEPHONE_NUMBER_p return varchar2;
END PAY_PAYJPITT_XMLP_PKG;

/
