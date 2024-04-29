--------------------------------------------------------
--  DDL for Package PO_POXCORSL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXCORSL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXCORSLS.pls 120.1 2007/12/25 10:53:52 krreddy noship $ */
	P_CONC_REQUEST_ID	number;
	P_COUNTRY_OF_ORIGIN_CODE	varchar2(2);
	P_QUERY_WHERE_COUNTRY_CODE	varchar2(1000);
	P_VENDOR_FROM	varchar2(50);
	P_VENDOR_TO	varchar2(32767);
	P_VENDOR_SITE	varchar2(50);
	P_ITEM_STRUCT_NUM	number;
	P_TITLE	varchar2(60);
	P_SHIP_TO	varchar2(60);
	P_FLEX_ITEM	varchar2(800);
	P_SHIP_TO_ORG_NAME	varchar2(60);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PO_POXCORSL_XMLP_PKG;


/
