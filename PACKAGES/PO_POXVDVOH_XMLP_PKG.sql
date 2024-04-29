--------------------------------------------------------
--  DDL for Package PO_POXVDVOH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXVDVOH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXVDVOHS.pls 120.2 2007/12/25 12:42:25 krreddy noship $ */
	P_title	varchar2(50);
	P_conc_request_id	number;
	P_min_precision	number;
	P_PO_NUM_FROM	varchar2(40);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_ORDERBY	varchar2(40);
	P_PO_NUM_TO	varchar2(40);
	P_orderby_displayed	varchar2(40);
	function BeforeReport return boolean  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function AfterReport return boolean  ;
END PO_POXVDVOH_XMLP_PKG;


/
