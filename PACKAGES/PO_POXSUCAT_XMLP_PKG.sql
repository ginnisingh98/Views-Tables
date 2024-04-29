--------------------------------------------------------
--  DDL for Package PO_POXSUCAT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXSUCAT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXSUCATS.pls 120.1 2007/12/25 12:27:54 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_CAT	varchar2(31000);
	P_PO_CREATION_DATE_FROM	date;
	P_PO_CREATION_DATE_TO	date;
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_BUYER_FROM	varchar2(240);
	P_BUYER_TO	varchar2(240);
	P_CATEGORY_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_WHERE_CAT	varchar2(2000);
	P_STRUCT_NUM	varchar2(15);
	P_BASE_CURRENCY	varchar2(40);
	P_creation_date_from	date;
	P_creation_date_to	date;
	WHERE_PERFORMANCE	varchar2(2000);
	function BeforeReport return boolean  ;
	function get_p_struct_num return boolean  ;
	function AfterReport return boolean  ;
	function P_creation_date_toValidTrigger return boolean  ;
	function P_PO_CREATION_DATE_TOValidTrig return boolean  ;
	function P_PO_CREATION_DATE_FROM_p return date  ;
	function P_PO_CREATION_DATE_TO_p return date  ;

	function AfterPForm return boolean  ;
END PO_POXSUCAT_XMLP_PKG;


/
