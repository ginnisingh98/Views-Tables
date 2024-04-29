--------------------------------------------------------
--  DDL for Package PO_POXAGLST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXAGLST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXAGLSTS.pls 120.2 2008/01/05 12:52:03 dwkrishn noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_ACTIVE_INACTIVE	varchar2(8);
	P_LOCATION	varchar2(40);
	P_FLEX_CAT	varchar2(31000);
	P_CATEGORY_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_WHERE_CAT	varchar2(2000);
	P_STRUCT_NUM	varchar2(15);
	P_ORDERBY	varchar2(8);
	P_ORDERBY_CAT	varchar2(298);
	P_orderby_displayed	varchar2(80);
	LP_ORDERBY_DISPLAYED varchar2(80);
	P_active_inactive_disp	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
END PO_POXAGLST_XMLP_PKG;


/
