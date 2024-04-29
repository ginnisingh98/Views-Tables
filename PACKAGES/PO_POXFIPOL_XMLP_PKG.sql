--------------------------------------------------------
--  DDL for Package PO_POXFIPOL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXFIPOL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXFIPOLS.pls 120.2 2007/12/25 10:58:51 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ACC	varchar2(31000);
	P_OE_STATUS	varchar2(1);
	function select_rev(revision_sort_ordering in varchar2) return character  ;
	function from_rev(revision_sort_ordering in varchar2) return character  ;
	function where_rev(revision_sort_ordering in varchar2) return character  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function C_select_order_typeFormula return VARCHAR2  ;
	function C_select_order_sourceFormula return VARCHAR2  ;
	function C_select_oe_tablesFormula return VARCHAR2  ;
	function C_from_oe_clauseFormula return VARCHAR2  ;
END PO_POXFIPOL_XMLP_PKG;


/
