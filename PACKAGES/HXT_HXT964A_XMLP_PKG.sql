--------------------------------------------------------
--  DDL for Package HXT_HXT964A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT964A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT964AS.pls 120.0 2007/12/03 11:46:55 amakrish noship $ */
	P_TIME_PERIOD_ID	number;
	P_PAYROLL_ID	number;
	P_CONC_REQUEST_ID	number;
	function CF_PeriodFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT964A_XMLP_PKG;

/
