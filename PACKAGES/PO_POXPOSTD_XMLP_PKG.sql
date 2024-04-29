--------------------------------------------------------
--  DDL for Package PO_POXPOSTD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOSTD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOSTDS.pls 120.0 2008/01/02 07:49:30 dwkrishn noship $ */
	P_title	varchar2(50);
	P_STATUS	varchar2(40);
	P_BUYER	varchar2(40);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_PO_NUM_FROM	varchar2(40);
	P_PO_NUM_TO	varchar2(40);
	P_FLEX_CAT	varchar2(31000);
	P_FLEX_ITEM	varchar2(800);
	P_CONC_REQUEST_ID	number;
	P_WHERE_CAT	varchar2(2000);
	P_CATEGORY_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_STRUCT_NUM	varchar2(15);
	P_qty_precision	number;
	P_WHERE_ITEM	varchar2(2000);
	P_item_from	varchar2(900);
	P_item_to	varchar2(900);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_PO_NUM_TYPE	varchar2(32767);
	P_SINGLE_PO_PRINT	number:=0;
	WHERE_PERFORMANCE	varchar2(2000):='and 1=2';
        FORMAT_MASK varchar2(100);
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	FUNCTION GET_P_STRUCT_NUM RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	function c_amount_agr_round(C_AMOUNT_AGR in number, C_FND_PRECISION in number) return number  ;
	function AfterPForm return boolean  ;
END PO_POXPOSTD_XMLP_PKG;


/
