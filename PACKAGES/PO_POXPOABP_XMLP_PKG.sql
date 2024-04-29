--------------------------------------------------------
--  DDL for Package PO_POXPOABP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOABP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOABPS.pls 120.1 2007/12/25 11:07:56 krreddy noship $ */
	P_ITEM_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_CREATION_DATE_FROM	varchar2(40);
	P_CREATION_DATE_TO	varchar2(40);
	P_BLANKET_PO_NUM_FROM	varchar2(40);
	P_BLANKET_PO_NUM_TO	varchar2(40);
	P_BUYER	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_FLEX_CAT	varchar2(3100);
	P_FLEX_ITEM	varchar2(800);
	P_title	varchar2(50);
	P_qty_precision	number;
	P_ORDERBY	varchar2(40);
	P_ORDERBY_CAT	varchar2(298);
	P_ORDERBY_ITEM	varchar2(298);
	P_WHERE_ITEM	varchar2(2000);
	P_WHERE_CAT	varchar2(2000);
	P_ITEM_TO	varchar2(900);
	P_CATEGORY_FROM	varchar2(900);
	P_STRUCT_NUM	number;
	P_BASE_CURRENCY	varchar2(40);
	P_ORDERBY_DISPLAYED	varchar2(80);
	P_ITEMS_WHERE	varchar2(1000):='1=1';
        FORMAT_MASK varchar2(100);
	function BeforeReport return boolean  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
END PO_POXPOABP_XMLP_PKG;


/
