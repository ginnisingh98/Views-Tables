--------------------------------------------------------
--  DDL for Package PO_POXRVODS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRVODS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRVODSS.pls 120.1 2007/12/25 12:12:43 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_OVERDUE_DATE	date;
	P_OVERDUE_DATE_param date;
	P_SHIP_TO	varchar2(40);
	P_BUYER	varchar2(240);
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_CAT	varchar2(31000);
	P_WHERE_CAT	varchar2(2000);
	P_STRUCT_NUM	number;
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_QTY_PRECISION	number;
	P_ITEM_STRUCT_NUM	number;
	P_org_id	number;
	P_org_displayed	varchar2(60);
	PARENT_VENDOR	varchar2(40);
	P_where_vendor_from	varchar2(240);
	P_where_vendor_to	varchar2(240);
	P_where_buyer	varchar2(240);
        FORMAT_MASK varchar2(50);
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	function AfterPForm return boolean  ;
	--function c_item_flexformula(item_id in number, C_FLEX_ITEM in varchar2) return char  ;
	function c_item_flexformula(item_id in number,  C_ORGANISATION_ID in number) return char  ;
END PO_POXRVODS_XMLP_PKG;


/
