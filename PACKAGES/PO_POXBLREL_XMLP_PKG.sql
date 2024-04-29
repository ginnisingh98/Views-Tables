--------------------------------------------------------
--  DDL for Package PO_POXBLREL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXBLREL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXBLRELS.pls 120.1 2007/12/25 10:47:10 krreddy noship $ */
	P_title	varchar2(50);
	P_BUYER	varchar2(40);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_PO_NUM_FROM	varchar2(40);
	P_PO_NUM_TO	varchar2(40);
	P_FLEX_CAT	varchar2(31000);
	P_FLEX_ITEM	varchar2(800);
	P_CONC_REQUEST_ID	number;
	P_WHERE_CAT	varchar2(2000);
	P_STRUCT_NUM	varchar2(15);
	P_CATEGORY_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_qty_precision	varchar2(40);
	QTY_PRECISION  varchar2(100);
	P_ITEM_FROM	varchar2(900);
	P_ITEM_TO	varchar2(900);
	P_WHERE_ITEM	varchar2(2000);
	P_ORDERBY	varchar2(40);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_ORDERBY_DISPLAYED	varchar2(80);
	P_PO_Num_Type	varchar2(32767);
	P_SINGLE_PO_PRINT	number;
	P_Where_Query	varchar2(2000);
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
END PO_POXBLREL_XMLP_PKG;


/
