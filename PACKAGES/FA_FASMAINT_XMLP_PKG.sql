--------------------------------------------------------
--  DDL for Package FA_FASMAINT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASMAINT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASMAINTS.pls 120.0.12010000.1 2008/07/28 13:16:59 appldev ship $ */
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_MAINT_DATE_FROM	date;
	P_MAINT_DATE_TO	date;
	P_BOOK	varchar2(15);
	P_EVENT_NAME	varchar2(50);
	P_ASSET_NUMBER_FROM	varchar2(15);
	P_ASSET_NUMBER_TO	varchar2(15);
	P_DPIS_FROM	date;
	P_DPIS_TO	date;
	P_CATEGORY_ID	varchar2(32767);
	P_CAT_STRUCT_ID	number;
	C_currency_code	varchar2(15);
	C_request_id	number := 919;
	procedure get_currency_code(book varchar2)  ;
	procedure raise_ora_err(errno in varchar2)  ;
	function AfterReport return boolean  ;
	function RP_COMPANY_NAMEFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	Function C_currency_code_p return varchar2;
	Function C_request_id_p return number;
	--added
	function Do_InsertFormula return number ;
END FA_FASMAINT_XMLP_PKG;


/
