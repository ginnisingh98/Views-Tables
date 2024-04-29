--------------------------------------------------------
--  DDL for Package HXT_HXT957A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT957A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT957AS.pls 120.1 2008/04/03 07:38:05 amakrish noship $ */
	End_date	date;
	Start_date	date;
	AP_START_DATE  varchar2(15);
	AP_END_DATE   varchar2(15);
	P_CONC_REQUEST_ID	number;
	function ORG_NAMEFormula(ORGANIZATION_ID1 in number) return VARCHAR2  ;
	function earn_typeformula(P_ELEMENT_TYPE_ID in number, P_EFFECTIVE_START_DATE in date, P_EFFECTIVE_END_DATE in date) return varchar2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT957A_XMLP_PKG;

/
