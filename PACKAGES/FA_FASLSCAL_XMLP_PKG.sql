--------------------------------------------------------
--  DDL for Package FA_FASLSCAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASLSCAL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASLSCALS.pls 120.0.12010000.1 2008/07/28 13:16:52 appldev ship $ */
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	P_FISCAL_YEAR_NAME	varchar2(40);
	P_FISCAL_YEAR	varchar2(40);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function RP_REPORT_NAMEFormula return VARCHAR2  ;
	function RP_COMPANY_NAMEFormula return VARCHAR2  ;
END FA_FASLSCAL_XMLP_PKG;


/
