--------------------------------------------------------
--  DDL for Package PO_POXRQRCO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQRCO_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQRCOS.pls 120.2 2007/12/25 11:54:01 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_CAT	varchar2(3100);
	P_REQUESTOR	varchar2(40);
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_STRUCT_NUM	varchar2(15);
	P_WHERE_CAT	varchar2(2000);
	P_item_from	varchar2(900);
	P_item_to	varchar2(900);
	P_WHERE_ITEM	varchar2(2000);
	P_QTY_PRECISION	number;
	QTY_PRECISION varchar2(100);
	P_OE_STATUS	varchar2(1);
	C_industry_code	varchar2(20);
	C_order_title	varchar2(20);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	procedure get_boiler_plates  ;
	procedure get_lookup_meaning(p_lookup_type	in varchar2,
			     p_lookup_code	in varchar2,
			     p_lookup_meaning  	in out nocopy varchar2)
			     ;
	function set_display_for_core return boolean  ;
	function set_display_for_gov return boolean  ;
	Function C_industry_code_p return varchar2;
	Function C_order_title_p return varchar2;
END PO_POXRQRCO_XMLP_PKG;


/
