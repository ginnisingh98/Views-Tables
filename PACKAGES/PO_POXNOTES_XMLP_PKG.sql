--------------------------------------------------------
--  DDL for Package PO_POXNOTES_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXNOTES_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXNOTESS.pls 120.1 2007/12/25 11:04:12 krreddy noship $ */
	P_title	varchar2(2000);
	P_CONC_REQUEST_ID	number;
	P_USAGE_FROM	varchar2(40);
	P_USAGE_TO	varchar2(40);
	P_TITLE_FROM	varchar2(80);
	P_TITLE_TO	varchar2(80);
	P_SORT_BY	varchar2(40);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PO_POXNOTES_XMLP_PKG;


/
