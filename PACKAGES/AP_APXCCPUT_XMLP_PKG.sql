--------------------------------------------------------
--  DDL for Package AP_APXCCPUT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXCCPUT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXCCPUTS.pls 120.0 2007/12/27 07:33:38 vjaganat noship $ */
	P_ORG_ID	number;
	P_AMOUNT	number;
	P_START_DATE	date;
	P_END_DATE	date;
	LP_START_DATE	varchar2(11);
	LP_END_DATE	varchar2(11);
	P_CARD_NUMBER	varchar2(80);
	P_PROCESS	varchar2(40);
	P_TRACE_SWITCH	varchar2(1);
	P_DEBUG_SWITCH	varchar2(1);
	P_CONC_REQUEST_ID	number;
	P_SEND_NOTIFICATIONS	varchar2(2);
	CP_MASKED_CARD_NUMBER	varchar2(20);
	C_NLS_YES	varchar2(80);
	C_NLS_NO	varchar2(80);
	C_NLS_ALL	varchar2(80);
	C_NLS_NO_DATA_EXISTS	varchar2(80);
	C_NLS_END_OF_REPORT	varchar2(80);
	C_ORGANIZATION_NAME	varchar2(240);
	function cf_masked_card_numberformula(C_TRX_CARD_NUMBER in varchar2) return char  ;
	function BeforeReport return boolean ;
	FUNCTION  get_nls_strings     RETURN BOOLEAN  ;
	function c_trx_amount_fformula(C_TRX_AMOUNT_F in varchar2) return char  ;
	function AfterReport return boolean ;
	FUNCTION CUSTOM_INIT RETURN BOOLEAN ;
	PROCEDURE SendDeactivated  ;
	Function CP_MASKED_CARD_NUMBER_p return varchar2;
	Function C_NLS_YES_p return varchar2;
	Function C_NLS_NO_p return varchar2;
	Function C_NLS_ALL_p return varchar2;
	Function C_NLS_NO_DATA_EXISTS_p return varchar2;
	Function C_NLS_END_OF_REPORT_p return varchar2;
	Function C_ORGANIZATION_NAME_p return varchar2;
END AP_APXCCPUT_XMLP_PKG;


/
