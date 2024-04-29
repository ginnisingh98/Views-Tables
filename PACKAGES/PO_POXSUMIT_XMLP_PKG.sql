--------------------------------------------------------
--  DDL for Package PO_POXSUMIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXSUMIT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXSUMITS.pls 120.1 2007/12/25 12:29:22 krreddy noship $ */
	P_title	varchar2(50);
	P_ACTIVE_INACTIVE	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_STRUCT_NUM	varchar2(15);
	P_FLEX_ACC	varchar2(31000);
	P_FLEX_CAT	varchar2(31000);
	P_FLEX_ITEM	varchar2(800);
	P_SORT	varchar2(40);
	P_ITEM_STRUCT_NUM	varchar2(15);
	P_ORDERBY_CAT	varchar2(1500);
	P_ORDERBY_ITEM	varchar2(1500);
	P_chart_of_accounts_id	number;
	P_sort_displayed	varchar2(80);
	P_active_inactive_disp	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function get_p_struct_num return boolean  ;
END PO_POXSUMIT_XMLP_PKG;


/
