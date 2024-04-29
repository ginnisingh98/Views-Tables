--------------------------------------------------------
--  DDL for Package AR_ARXCOBLX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXCOBLX_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXCOBLXS.pls 120.0 2007/12/27 13:42:18 abraghun noship $ */
	P_MIN_CUSTOMER_BALANCE	number;
	P_INCLUDE_ON_ACCOUNT_CREDITS	varchar2(32767);
	P_INCLUDE_ON_ACCOUNT_RECEIPTS	varchar2(30);
	P_INCLUDE_UNAPPLIED_RECEIPTS	varchar2(32767);
	P_INCLUDE_UNCLEARED_RECEIPTS	varchar2(30);
	P_DEBUG_FLAG	varchar2(1);
	P_TRACE_FLAG	varchar2(1);
	P_REFERENCE_NUMBER	varchar2(30);
	P_AS_OF_DATE	date;
	P_CUSTOMER_NAME_FROM	varchar2(360);
	P_CUSTOMER_NAME_TO	varchar2(360);
	P_CURRENCY	varchar2(32767);
	P_MIN_INVOICE_BALANCE	number;
	P_SET_OF_BOOKS_ID	number;
	P_CONC_REQUEST_ID	number;
	P_CUSTOMER_NUMBER_LOW	varchar2(30);
	P_CUSTOMER_NUMBER_HIGH	varchar2(30);
	function cf_totalformula(c_inv_open_balance in number, cf_credits_and_receipts in number) return number  ;
	function cf_credits_and_receiptsformula(c_unapplied_receipts in number, c_on_account_receipts in number, c_on_account_credits in number) return number  ;
	function BeforeReport return boolean  ;
	function C_as_of_date_displayFormula return char  ;
	function AfterReport return boolean  ;
END AR_ARXCOBLX_XMLP_PKG;


/
