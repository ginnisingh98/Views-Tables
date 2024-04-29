--------------------------------------------------------
--  DDL for Package PO_POXRQUNI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQUNI_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQUNIS.pls 120.0.12010000.2 2010/06/04 11:25:04 dashah ship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_SUGGESTED_VENDOR_FROM	varchar2(240);
	P_SUGGESTED_VENDOR_TO	varchar2(240);
	P_NEEDBY_DATE_FROM	date;
	P_NEED_BY_DATE_TO	date;
	P_NEEDBY_DATE_FROM1 varchar2(20);
        P_NEED_BY_DATE_TO1 varchar2(20);
	P_LOCATION	varchar2(40);
	P_REQUESTOR	varchar2(240);
	P_REQ_NUM_FROM	varchar2(32767);
	P_REQ_NUM_TO	varchar2(32767);
	P_FLEX_CAT	varchar2(31000);
	P_FLEX_ITEM	varchar2(800);
	P_qty_precision	number;
	P_CATEGORY_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_PRINT_PRICE_HISTORY	varchar2(1);
	P_PRINT_PRICE_HISTORY_1	varchar2(1);
	P_WHERE_CAT	varchar2(2000);
	P_STRUCT_NUM	varchar2(40);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_BASE_CURRENCY	varchar2(40);
	P_PRINT_PRICE_HISTORY_DISP	varchar2(40);
	P_LOCATION_ID	number;
        FORMAT_MASK varchar2(50);
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function AfterReport return boolean  ;
	function get_p_struct_num return boolean  ;
	function AfterPForm return boolean  ;
	function locationformula(p_location_id in number) return char  ;
END PO_POXRQUNI_XMLP_PKG;


/
