--------------------------------------------------------
--  DDL for Package AR_ARXCHR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXCHR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXCHRS.pls 120.0 2007/12/27 13:40:48 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_CUSTOMER_NUMBER_LOW	varchar2(30);
	P_CUSTOMER_NUMBER_HIGH	varchar2(30);
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_ORDER_BY	varchar2(50);
	P_SET_OF_BOOKS_ID	number;
	P_COLLECTOR_LOW	varchar2(40);
	P_COLLECTOR_HIGH	varchar2(40);
	P_CURRENCY_CODE	varchar2(32767);
	lp_collector_low	varchar2(800):=' ';
	lp_collector_high	varchar2(800):=' ';
	lp_customer_number_low	varchar2(800):=' ';
	lp_customer_number_high	varchar2(800):=' ';
	lp_customer_name_low	varchar2(800):=' ';
	lp_customer_name_high	varchar2(800):=' ';
	lp_currency_code	varchar2(800):=' ';
	lp_status_low	varchar2(800):=' ';
	lp_status_high	varchar2(800):=' ';
	P_STATUS_LOW	varchar2(80);
	P_STATUS_HIGH	varchar2(80);
	P_REPORTING_ENTITY_ID	number;
	P_REPORTING_ENTITY_NAME	varchar2(60);
	P_REPORTING_LEVEL	varchar2(30);
	P_REPORTING_LEVEL_NAME	varchar2(80);
	P_ORG_WHERE_PS	varchar2(2000);
	P_ORG_WHERE_SITE	varchar2(2000):=' ';
	P_ORG_WHERE_ADDR	varchar2(2000):=' ';
	c_phone_number	varchar2(100);
	c_contact_id	number;
	c_contact_name	varchar2(60);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_DATE_RANGE	varchar2(100);
	RP_message	varchar2(2000);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function AfterPForm return boolean  ;
	function c_get_phone_numberformula(address_id in number, customer_id in number) return number  ;
	function C_PRIMARY_CONTACTFormula(p_address_id in varchar2) return Number  ;
	function c_no_data_foundformula(Currency_Main in varchar2) return number  ;
	Function c_phone_number_p return varchar2;
	Function c_contact_id_p return number;
	Function c_contact_name_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_DATE_RANGE_p return varchar2;
	Function RP_message_p return varchar2;
END AR_ARXCHR_XMLP_PKG;


/
