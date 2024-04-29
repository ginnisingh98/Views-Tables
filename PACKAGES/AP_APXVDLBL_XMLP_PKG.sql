--------------------------------------------------------
--  DDL for Package AP_APXVDLBL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXVDLBL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXVDLBLS.pls 120.0 2007/12/27 08:46:49 vjaganat noship $ */
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_TRACE_SWITCH	varchar2(1);
	P_VENDOR_TYPE	varchar2(33);
	P_VENDOR_TYPE_1	varchar2(33);
	P_ORDER_COLUMN	varchar2(5);
	P_SITE	varchar2(7);
	P_SITE_1	varchar2(7);
	DEFAULT_COUNTRY_CODE	varchar2(5);
	DEFAULT_COUNTRY_CODE_1	varchar2(5);
	DEFAULT_COUNTRY_NAME	varchar2(80);
	P_PRINT_HOME_COUNTRY	varchar2(5);
	SORT_BY_ALTERNATE	varchar2(5);
	P_PRINT_STYLE	varchar2(32767);
	PAY_SITE	varchar2(5);
	ATTN_MESSAGE	varchar2(80);
	FUNCTION  custom_init         RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function C_ORDER_BYFormula return VARCHAR2  ;
	function c_address_concatenatedformula(address1 in varchar2, address2 in varchar2,
	address3 in varchar2, city in varchar2,
	state in varchar2, zip in varchar2, country_name in varchar2, country_code in varchar2,
	vendor_name in varchar2, attention in varchar2) return varchar2  ;
END AP_APXVDLBL_XMLP_PKG;



/
