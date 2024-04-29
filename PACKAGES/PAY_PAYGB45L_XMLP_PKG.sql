--------------------------------------------------------
--  DDL for Package PAY_PAYGB45L_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYGB45L_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYGB45LS.pls 120.1 2007/12/24 12:42:31 amakrish noship $ */
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_DATE_TODAY	date;
	P_ACTION_RESTRICTION	varchar2(100);
	P_ASSIGNMENT_ACTION_ID	number;
	P_PAYROLL_ACTION_ID	number;
	C_NI12	varchar2(2);
	C_NI34	varchar2(2);
	C_NI56	varchar2(2);
	C_NI78	varchar2(2);
	C_Ni9	varchar2(1);
	C_DATE_OF_LEAVING_DD	varchar2(2);
	C_DATE_OF_LEAVING_MM	varchar2(2);
	C_DATE_OF_LEAVING_YYYY	varchar2(4);
	C_WEEK_NO	number;
	C_MONTH_NO	number;
	C_TOTAL_TAX_TD	number;
	C_TOTAL_PAY_TD	number;
	C_PER_ADDRESS_LINE1	varchar2(60);
	C_PER_ADDRESS_LINE2	varchar2(60);
	C_PER_ADDRESS_LINE3	varchar2(60);
	C_PER_ADDRESS_LINE4	varchar2(38);
	C_PAY_IN_EMP_POUNDS	number := 0 ;
	C_PAY_IN_EMP_PENCE	number := 00 ;
	C_TAX_IN_EMP_POUNDS	number := 0 ;
	C_TAX_IN_EMP_PENCE	number := 00 ;
	C_PAY_TD_POUNDS	number := 0 ;
	C_PAY_TD_PENCE	number := 00 ;
	C_TAX_TD_POUNDS	number := 0 ;
	C_TAX_TD_PENCE	number := 00 ;
	C_BUSINESS_GROUP_NAME	varchar2(60);
	C_REPORT_SUBTITLE	varchar2(60);
	C_FORMULA_ID	number;
	C_MESSAGE	varchar2(80);
	C_NEW_PAGE	varchar2(1);
	C_ERS_ADDR_LINE1	varchar2(38);
	C_ERS_ADDR_LINE2	varchar2(38);
	C_ERS_ADDR_LINE3	varchar2(38);
	C_TAX_DIST_NO	varchar2(3);
	C_TAX_DIST_REF	varchar2(32767);
	C_ERS_NAME	varchar2(40);
	function BeforeReport return boolean  ;
	function c_format_dataformula(address_line1 in varchar2, address_line2 in varchar2,
	address_line3 in varchar2, town_or_city in varchar2, county in varchar2, post_code in varchar2,
	taxable_pay in number, previous_taxable_pay in number, tax_paid in number, previous_tax_paid in number,
	ni_number in varchar2, termination_date in date, c_3_part in varchar2, w1_m1_indicator in varchar2,
	month_number in number, week_number in number) return varchar2  ;
	procedure get_pounds_pence(p_total in number,
                           p_pounds in out NOCOPY number,
                           p_pence in out NOCOPY number)   ;
	procedure split_employer_address(p_employer_address in     varchar2,
                                 p_emp_addr_line_1  in out NOCOPY varchar2,
                                 p_emp_addr_line_2  in out NOCOPY varchar2,
                                 p_emp_addr_line_3  in out NOCOPY varchar2)  ;
	function C_3_PARTFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
	Function C_NI12_p return varchar2;
	Function C_NI34_p return varchar2;
	Function C_NI56_p return varchar2;
	Function C_NI78_p return varchar2;
	Function C_Ni9_p return varchar2;
	Function C_DATE_OF_LEAVING_DD_p return varchar2;
	Function C_DATE_OF_LEAVING_MM_p return varchar2;
	Function C_DATE_OF_LEAVING_YYYY_p return varchar2;
	Function C_WEEK_NO_p return number;
	Function C_MONTH_NO_p return number;
	Function C_TOTAL_TAX_TD_p return number;
	Function C_TOTAL_PAY_TD_p return number;
	Function C_PER_ADDRESS_LINE1_p return varchar2;
	Function C_PER_ADDRESS_LINE2_p return varchar2;
	Function C_PER_ADDRESS_LINE3_p return varchar2;
	Function C_PER_ADDRESS_LINE4_p return varchar2;
	Function C_PAY_IN_EMP_POUNDS_p return number;
	Function C_PAY_IN_EMP_PENCE_p return number;
	Function C_TAX_IN_EMP_POUNDS_p return number;
	Function C_TAX_IN_EMP_PENCE_p return number;
	Function C_PAY_TD_POUNDS_p return number;
	Function C_PAY_TD_PENCE_p return number;
	Function C_TAX_TD_POUNDS_p return number;
	Function C_TAX_TD_PENCE_p return number;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_FORMULA_ID_p return number;
	Function C_MESSAGE_p return varchar2;
	Function C_NEW_PAGE_p return varchar2;
	Function C_ERS_ADDR_LINE1_p return varchar2;
	Function C_ERS_ADDR_LINE2_p return varchar2;
	Function C_ERS_ADDR_LINE3_p return varchar2;
	Function C_TAX_DIST_NO_p return varchar2;
	Function C_TAX_DIST_REF_p return varchar2;
	Function C_ERS_NAME_p return varchar2;
END PAY_PAYGB45L_XMLP_PKG;

/
