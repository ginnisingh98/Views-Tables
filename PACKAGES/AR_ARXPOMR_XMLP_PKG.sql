--------------------------------------------------------
--  DDL for Package AR_ARXPOMR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXPOMR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXPOMRS.pls 120.0 2007/12/27 14:02:38 abraghun noship $ */
	l_po_id	number;
	L_PO_ID_V number;
	P_CONC_REQUEST_ID	number;
	FUNCTION ar_meaning (po_name in varchar2,
                     po_value in varchar2)
RETURN varchar2  ;
	function cf_1formula(po_name in varchar2, resposibility in varchar2) return varchar2  ;
	FUNCTION p_org_po_id RETURN number  ;
	function BeforeReport return boolean  ;
	function cf_appformula(po_name in varchar2, application in varchar2) return varchar2  ;
	function cf_siteformula(po_name in varchar2, site in varchar2) return varchar2  ;
	function cf_userformula(po_name in varchar2, us in varchar2) return varchar2  ;
	FUNCTION ar_profile_user_name (po_name in varchar2)

 RETURN varchar2  ;
 function CF_po_user_nameFormula(po_int_name in varchar2) return varchar2;

	function AfterReport return boolean  ;
END AR_ARXPOMR_XMLP_PKG;


/
