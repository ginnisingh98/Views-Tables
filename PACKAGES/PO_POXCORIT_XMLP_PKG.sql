--------------------------------------------------------
--  DDL for Package PO_POXCORIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXCORIT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXCORITS.pls 120.1 2007/12/25 10:52:25 krreddy noship $ */
	P_CONC_REQUEST_ID	number;
	P_COUNTRY_OF_ORIGIN_CODE	varchar2(2);
	P_FLEX_ITEM	varchar2(1000);
	P_ORG_ID	number;
	P_ORGANIZATION_NAME	varchar2(80);
	P_QUERY_WHERE_COUNTRY_CODE	varchar2(1000);
	P_CAT_STRUCT_NUM	varchar2(40);
	P_FLEX_CAT	varchar2(1000);
	P_TITLE	varchar2(60);
	P_ITEM_FROM	varchar2(900);
	P_ITEM_TO	varchar2(900);
	P_CAT_FROM	varchar2(900);
	P_CAT_TO	varchar2(900);
	P_DATE_FROM	date;
	P_DATE_TO	date;
	P_QUERY_WHERE_CAT	varchar2(1000);
	P_QUERY_WHERE_ITEM	varchar2(1000);
	P_ITEM_STRUCT_NUM	varchar2(40);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function get_p_struct_num return boolean  ;
	function f_get_vendor_item_number (p_org_id number
             , p_vendor_id number
             , p_vendor_site_id number
             , p_item_id number)return varchar2  ;
	function cf_vendor_item_numberformula(C_USING_ORG_ID in number, C_VENDOR_ID in number, C_VENDOR_SITE_ID in number, C_ITEM_ID in number) return varchar2  ;
END PO_POXCORIT_XMLP_PKG;


/
