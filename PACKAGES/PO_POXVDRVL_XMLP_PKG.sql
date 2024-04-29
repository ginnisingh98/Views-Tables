--------------------------------------------------------
--  DDL for Package PO_POXVDRVL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXVDRVL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXVDRVLS.pls 120.1 2007/12/25 12:40:24 krreddy noship $ */
	P_title	varchar2(50);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_CREATE_DATE_FROM	varchar2(40);
	P_CREATE_DATE_TO	varchar2(40);
	P_SITE	varchar2(40);
	P_VENDOR_TYPE	varchar2(40);
	P_ACTIVE_INACTIVE	varchar2(40);
	P_ORDERBY	varchar2(40);
	P_vendor_type_displayed	varchar2(40);
	P_active_inactive_disp	varchar2(40);
	P_orderby_displayed	varchar2(40);
	P_CONC_REQUEST_ID	number;
	function orderby_clauseFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PO_POXVDRVL_XMLP_PKG;


/
