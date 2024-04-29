--------------------------------------------------------
--  DDL for Package PO_POXQTQAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXQTQAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXQTQARS.pls 120.1 2007/12/25 11:35:32 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_BUYER	varchar2(40);
	P_DATE_FROM	date;
	P_DATE_TO	date;
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_CAT	varchar2(31000);
	P_WHERE_CAT	varchar2(2000);
	P_STRUCT_NUM	varchar2(40);
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_QTY_PRECISION	number;
        FORMAT_MASK varchar2(100);
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function get_p_struct_num return boolean  ;
END PO_POXQTQAR_XMLP_PKG;


/
