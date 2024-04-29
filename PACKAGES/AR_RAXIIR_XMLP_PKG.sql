--------------------------------------------------------
--  DDL for Package AR_RAXIIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXIIR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXIIRS.pls 120.0 2007/12/27 14:23:12 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_CUSTOMER_NUMBER_LOW	varchar2(30);
	P_CUSTOMER_NUMBER_HIGH	varchar2(30);
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_INVOICE_NUM_LOW	varchar2(32767);
	P_INVOICE_NUM_HIGH	varchar2(32767);
	P_ORDER_BY	varchar2(50);
	lp_customer_name_low	varchar2(500):=' ';
	lp_customer_name_high	varchar2(500):=' ';
	lp_customer_number_low	varchar2(500):=' ';
	lp_customer_number_high	varchar2(500):=' ';
	lp_item_number_low	varchar2(500):=' ';
	lp_item_number_high	varchar2(500):=' ';
	PD_MIN_CUSTOMER_NAME	varchar2(50);
	PD_MIN_CUSTOMER_NUMBER	varchar2(50);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function c_data_not_foundformula(Number_A in varchar2) return number  ;
	function AfterPForm return boolean  ;
	function CF_ORDER_BYFormula return Char  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
END AR_RAXIIR_XMLP_PKG;


/
