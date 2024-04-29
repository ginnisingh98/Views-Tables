--------------------------------------------------------
--  DDL for Package PO_POXRQRSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQRSR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQRSRS.pls 120.1 2007/12/25 11:56:23 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_CAT	varchar2(31000);
	P_REQ_NUM_FROM	varchar2(240);
	P_REQ_NUM_TO	varchar2(240);
	P_DELIVER_TO	varchar2(40);
	P_REQUESTOR	varchar2(240);
	P_CREATION_DATE_FROM	varchar2(40);
	P_CREATION_DATE_TO	varchar2(40);
	P_qty_precision	varchar2(40);
	P_STRUCT_NUM	varchar2(15);
	P_ITEM_STRUCT_NUM	varchar2(40);
        FORMAT_MASK     varchar2(50);
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	function C_WHERE_REQ_NUMFormula return Char  ;
	function cf_locationsformula(deliver_to_location in varchar2, deliver_to_location_id in number) return char  ;
END PO_POXRQRSR_XMLP_PKG;


/
