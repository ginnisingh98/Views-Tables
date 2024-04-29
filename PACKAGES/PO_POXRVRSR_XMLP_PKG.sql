--------------------------------------------------------
--  DDL for Package PO_POXRVRSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRVRSR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRVRSRS.pls 120.1 2007/12/25 12:18:53 krreddy noship $ */
	P_title	varchar2(50);
	P_FLEX_ITEM_ORD	varchar2(800);
	P_FLEX_ITEM_SUB	varchar2(800);
	P_TRANS_DATE_FROM	varchar2(40);
	P_TRANS_DATE_TO	varchar2(40);
	P_CONC_REQUEST_ID	number;
	ORGANIZATION_ID	varchar2(40);
	FORMAT_MASK   VARCHAR2(50);
	P_qty_precision	varchar2(40);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_STRUCT_NUM	varchar2(40);
	P_org_id	number;
	P_org_displayed	varchar2(60);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
END PO_POXRVRSR_XMLP_PKG;


/
