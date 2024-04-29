--------------------------------------------------------
--  DDL for Package AR_RAXCUS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXCUS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXCUSS.pls 120.0 2007/12/27 14:18:49 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	PR_CUSTOMER_NAME_LOW	varchar2(50);
	PR_CUSTOMER_NAME_HIGH	varchar2(50);
	PR_CUSTOMER_NUMBER_LOW	varchar2(30);
	PR_CUSTOMER_NUMBER_HIGH	varchar2(30);
	P_STATUS_LOW	varchar2(15);
	PR_STATUS_LOW	varchar2(80);
	PR_STATUS_HIGH	varchar2(80);
	P_ORDER_BY	varchar2(32767);
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_CUSTOMER_NUMBER_HIGH	varchar2(30);
	P_CUSTOMER_NUMBER_LOW	varchar2(30);
	P_STATUS_HIGH	varchar2(15);
	P_CITY_LOW	varchar2(50);
	P_CITY_HIGH	varchar2(50);
	P_STATE_LOW	varchar2(50);
	P_STATE_HIGH	varchar2(50);
	P_ZIP_LOW	varchar2(30);
	P_ZIP_HIGH	varchar2(30);
	P_SITE_LOW	varchar2(32767);
	P_SITE_HIGH	varchar2(32767);
	lp_zip_low	varchar2(100):=' ';
	lp_zip_high	varchar2(100):=' ';
	lp_state_low	varchar2(100):=' ';
	lp_state_high	varchar2(100):=' ';
	lp_city_low	varchar2(100):=' ';
	lp_city_high	varchar2(100):=' ';
	lp_site_low	varchar2(100):=' ';
	lp_site_high	varchar2(100):=' ';
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_data_not_foundformula(Customer_Name in varchar2) return number  ;
	function CF_ORDER_BYFormula return Char  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
END AR_RAXCUS_XMLP_PKG;


/
