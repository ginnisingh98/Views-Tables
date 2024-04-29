--------------------------------------------------------
--  DDL for Package PO_POXSURLC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXSURLC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXSURLCS.pls 120.1 2007/12/25 12:32:04 krreddy noship $ */
	P_title	varchar2(50);
	P_ACTIVE_INACTIVE	varchar2(40);
	P_SITE	varchar2(40);
	P_SORT	varchar2(40);
	P_active_inactive_disp	varchar2(80);
	P_sort_disp	varchar2(80);
	P_CONC_REQUEST_ID	number;
	P_site_disp	varchar2(80);
	function orderby_clauseFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PO_POXSURLC_XMLP_PKG;


/
