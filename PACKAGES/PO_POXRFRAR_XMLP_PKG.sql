--------------------------------------------------------
--  DDL for Package PO_POXRFRAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRFRAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRFRARS.pls 120.2 2008/01/05 17:09:33 dwkrishn noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_DATE_FROM	varchar2(40);
	P_DATE_TO	varchar2(40);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_BUYER	varchar2(240);
	P_FLEX_CAT	varchar2(3100);
	P_WHERE_CAT	varchar2(2000);
	P_STRUCT_NUM	varchar2(15);
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_ORDERBY	varchar2(40);
	P_ORDERBY_DISP	varchar2(80);
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function get_p_struct_num return boolean  ;
END PO_POXRFRAR_XMLP_PKG;


/
