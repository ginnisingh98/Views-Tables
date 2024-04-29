--------------------------------------------------------
--  DDL for Package PO_POXRQCRQ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQCRQ_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQCRQS.pls 120.2 2007/12/25 11:47:41 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_PREPARER_FROM	varchar2(40);
	P_PREPARER_TO	varchar2(40);
	P_CREATION_DATE_FROM	varchar2(40);
	P_CREATION_DATE_TO	varchar2(40);
	P_REQUESTOR_FROM	varchar2(40);
	P_REQUESTOR_TO	varchar2(40);
	P_qty_precision	varchar2(40);
	QTY_PRECISION  varchar2(100);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_ORDERBY	varchar2(40);
	P_orderby_displayed	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
END PO_POXRQCRQ_XMLP_PKG;


/
