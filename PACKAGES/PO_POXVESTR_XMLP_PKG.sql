--------------------------------------------------------
--  DDL for Package PO_POXVESTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXVESTR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXVESTRS.pls 120.1 2007/12/25 12:43:57 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_VENDOR_NAME_FROM	varchar2(240);
	P_VENDOR_NAME_TO	varchar2(240);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PO_POXVESTR_XMLP_PKG;


/
