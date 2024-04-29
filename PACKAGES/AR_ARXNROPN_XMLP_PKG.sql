--------------------------------------------------------
--  DDL for Package AR_ARXNROPN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXNROPN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXNROPNS.pls 120.0 2007/12/27 13:56:56 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_CUSTOMER_NAME_LOW	varchar2(50);
	P_CUSTOMER_NAME_HIGH	varchar2(50);
	P_END_DATE	date;
	P_START_DATE	date;
	P_END_DATE1	varchar2(30);
	P_START_DATE1	varchar2(30);
	P_SET_OF_BOOKS_ID	number;
	P_CUSTOMER_NUMBER_LOW	varchar2(30);
	P_CUSTOMER_NUMBER_HIGH	varchar2(30);
	P_CURRENCY_CODE	varchar2(32767);
	P_NOTE_STATUS	varchar2(30);
	LP_START_DATE	varchar2(200) := ' ';
	LP_END_DATE	varchar2(200) := ' ';
	LP_CUSTOMER_NAME_LOW	varchar2(200) := ' ';
	LP_CUSTOMER_NAME_HIGH	varchar2(200) := ' ';
	LP_CUSTOMER_NUMBER_LOW	varchar2(200) := ' ';
	LP_CUSTOMER_NUMBER_HIGH	varchar2(200) := ' ';
	LP_NOTE_STATUS	varchar2(200) := ' ';
	P_ORDER_BY	varchar2(30);
	P_REMITTANCE_BANK	varchar2(60);
	P_BANK_ACCOUNT_ID	number;
	LP_REMITTANCE_BANK	varchar2(200) := ' ';
	LP_BANK_ACCOUNT_ID	varchar2(200) := ' ';
	LP_CURRENCY_CODE	varchar2(200) := ' ';
	HP_ORDER_BY	varchar2(80);
	HP_BANK_ACCOUNT	varchar2(30);
	HP_NOTE_STATUS	varchar2(80);
	RP_DATA_FOUND	varchar2(100);
	RP_SORT_BY_PHONETICS	varchar2(5) := 'N' ;
	RP_FUNCTIONAL_CURR	varchar2(15);
	RP_FUNCTIONAL_CURR_PREC	number;
	RP_SET_OF_BOOKS_NAME	varchar2(30);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	function setupformula(set_of_books_name in varchar2, functional_curr in varchar2, functional_curr_prec in number) return varchar2  ;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_SORT_BY_PHONETICS_p return varchar2;
	Function RP_FUNCTIONAL_CURR_p return varchar2;
	Function RP_FUNCTIONAL_CURR_PREC_p return number;
	Function RP_SET_OF_BOOKS_NAME_p return varchar2;
END AR_ARXNROPN_XMLP_PKG;


/
