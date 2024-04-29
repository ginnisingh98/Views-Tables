--------------------------------------------------------
--  DDL for Package AR_ARXCCP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXCCP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXCCPS.pls 120.0 2007/12/27 13:38:27 abraghun noship $ */
	CUST_DEFAULT	varchar2(40);
	P_SET_OF_BOOKS_ID	varchar2(40);
	P_LOW_CUST_NUM	varchar2(40);
	P_HIGH_CUST_NUM	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_SORT1	varchar2(30);
	SORT_BY_PHONETICS	varchar2(1);
	P_SORT2	varchar2(30);
	NLS_YES	varchar2(80);
	NLS_NO	varchar2(80);
	RP_REPORT_NAME	varchar2(240);
	function NLS_YES1Formula return VARCHAR2  ;
	function NLS_YESFormula return VARCHAR2  ;
	function NLS_NO1Formula return VARCHAR2  ;
	function NLS_NOFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Report_NameFormula return VARCHAR2  ;
	Function NLS_YES_p return varchar2;
	Function NLS_NO_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	PROCEDURE Set_Sort_Order;
END AR_ARXCCP_XMLP_PKG;


/
