--------------------------------------------------------
--  DDL for Package HXT_HXT957I_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT957I_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT957IS.pls 120.0 2007/12/03 11:33:48 amakrish noship $ */
	P_1	number;
	P_CONC_REQUEST_ID	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT957I_XMLP_PKG;

/
