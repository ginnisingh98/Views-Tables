--------------------------------------------------------
--  DDL for Package HXT_HXT007A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT007A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT007AS.pls 120.0 2007/12/03 10:27:12 amakrish noship $ */
	P_PAYROLL_ID	number;
	P_DATE_EARNED	date;
	P_CONC_REQUEST_ID	number;
	C_REPORT_SUBTITLE	varchar2(60);
	FUNCTION CF_PAYROLLFormula return VARCHAR2  ;
	function cf_detail_hoursformula(P_BATCH_ID in number) return number  ;
	function cf_bee_line_hoursformula(ELEMENT_TYPE_ID in number, VALUE_1 in varchar2, VALUE_2 in varchar2, VALUE_3 in varchar2, VALUE_4 in varchar2, VALUE_5 in varchar2, VALUE_6 in varchar2,
        VALUE_7 in varchar2, VALUE_8 in varchar2, VALUE_9 in varchar2, VALUE_10 in varchar2, VALUE_11 in varchar2, VALUE_12 in varchar2, VALUE_13 in varchar2, VALUE_14 in varchar2, VALUE_15 in varchar2) return number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_REPORT_SUBTITLE_p return varchar2;
END HXT_HXT007A_XMLP_PKG;

/
