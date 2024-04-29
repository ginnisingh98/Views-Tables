--------------------------------------------------------
--  DDL for Package PO_POXRQDDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQDDR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQDDRS.pls 120.2 2007/12/25 11:49:29 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_DATE_FROM	varchar2(40);
	P_DATE_TO	varchar2(40);
	P_REQ_NUM_FROM	varchar2(40);
	P_REQ_NUM_TO	varchar2(40);
	P_PREPARER	varchar2(240);
	P_QTY_PRECISION	number;
	QTY_PRECISION  varchar2(100);
	P_failed_funds	varchar2(1);
	P_failed_funds_lp	varchar2(1);
	P_FLEX_ACC	varchar2(31000);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_CHART_OF_ACCOUNTS_ID	varchar2(40);
	P_FAILED_FUNDS_DISP	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function select_failed_f return character  ;
	function from_failed_f return character  ;
	function where_failed_f return character  ;
	function get_p_chart_of_accounts_id return boolean  ;
	function C_WHERE_REQ_NUMFormula return Char  ;
END PO_POXRQDDR_XMLP_PKG;


/
