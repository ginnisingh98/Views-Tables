--------------------------------------------------------
--  DDL for Package PO_POXRQEXP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQEXP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQEXPS.pls 120.1 2007/12/25 11:51:40 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_CAT	varchar2(31000);
	P_EXPRESS_NAME	varchar2(40);
	P_STRUCT_NUM	varchar2(40);
	P_ITEM_STRUCT_NUM	varchar2(40);
	function BeforeReport return boolean  ;
	function get_p_struct_num return boolean  ;
	function AfterReport return boolean  ;
END PO_POXRQEXP_XMLP_PKG;


/
