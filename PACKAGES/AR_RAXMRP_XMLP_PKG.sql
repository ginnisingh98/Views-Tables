--------------------------------------------------------
--  DDL for Package AR_RAXMRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXMRP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXMRPS.pls 120.0 2007/12/27 14:29:58 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_CUSTOMER_NAME	varchar2(50);
	CP_CUSTOMER_NAME	varchar2(50);
	P_NUMBER_OF_CHAR	number;
	PH_CUST_NAME	varchar2(50);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_data_not_foundformula(Name in varchar2) return number  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
END AR_RAXMRP_XMLP_PKG;


/
