--------------------------------------------------------
--  DDL for Package PSP_PSPARREP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSPARREP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPARREPS.pls 120.4 2007/10/29 07:19:57 amakrish noship $ */
	P_PAYROLL_ID	number;
	P_BEGIN_PERIOD	number;
	P_END_PERIOD	number;
	P_SET_OF_BOOKS_ID	number;
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	function BeforeReport return boolean  ;
	function CF_Begin_period_nameFormula return Char  ;
	function CF_End_period_nameFormula return Char  ;
	function CF_No_data_foundFormula return Number  ;
	function BeforePForm return boolean  ;
	function AfterReport return boolean  ;
END PSP_PSPARREP_XMLP_PKG;

/
