--------------------------------------------------------
--  DDL for Package PO_POXPIERR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPIERR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPIERRS.pls 120.1 2007/12/25 11:06:30 krreddy noship $ */
	P_SOURCE_PROGRAM	varchar2(40);
	P_PURGE_DATA	varchar2(32767);
	P_CONC_REQUEST_ID	number;
	function afterreport(c_count in number) return boolean  ;
	function m_header_grpfrformattrigger(c_count in number) return boolean  ;
	function AFTERREPORT0007 (c_count in number)return boolean ;
	function BeforeReport return boolean  ;
END PO_POXPIERR_XMLP_PKG;


/
