--------------------------------------------------------
--  DDL for Package HXT_HXT956E_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT956E_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT956ES.pls 120.0 2007/12/03 11:11:59 amakrish noship $ */
	P_CONC_REQUEST_ID	number;
	function ppremformula(P_ELT_PRIOR_PREM_ID in number, P_EFFECTIVE_START_DATE in date, P_EFFECTIVE_END_DATE in date) return varchar2  ;
	function incexcformula(APPLY_PRIOR_PREM_YN in varchar2) return varchar2  ;
	function edateformula(EFFECTIVE_END_DATE in date) return date  ;
	function earn_premformula(P_ELT_EARNED_PREM_ID in number, P_EFFECTIVE_START_DATE in date, P_EFFECTIVE_END_DATE in date) return varchar2  ;
	function BeforePForm return boolean  ;
	function AfterPForm return boolean  ;
	function BeforeReport return boolean  ;
	function BetweenPage return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT956E_XMLP_PKG;

/
