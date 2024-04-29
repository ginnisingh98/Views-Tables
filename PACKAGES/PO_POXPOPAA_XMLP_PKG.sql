--------------------------------------------------------
--  DDL for Package PO_POXPOPAA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOPAA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOPAAS.pls 120.1 2007/12/25 11:17:35 krreddy noship $ */
	P_title	varchar2(50);
	P_FLEX_ITEM	varchar2(800);
	P_CONC_REQUEST_ID	number;
	P_BUYER	varchar2(240);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_FLEX_CAT	varchar2(3100);
	P_qty_precision	varchar2(40);
	QTY_PRECISION  varchar2(100);
	P_STRUCT_NUM	number;
	CP_BUYER	varchar2(240);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function get_p_struct_num return boolean  ;
	function cf_buyer_formulaformula(buyer in varchar2) return char  ;
	function CF_BUYERFormula return Char  ;
	function CP_BUYERFormula return Char  ;
	Function CP_BUYER_p return varchar2;
END PO_POXPOPAA_XMLP_PKG;


/
