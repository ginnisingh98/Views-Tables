--------------------------------------------------------
--  DDL for Package HXT_HXT957H_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT957H_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT957HS.pls 120.0 2007/12/03 11:30:35 amakrish noship $ */
	P_CONC_REQUEST_ID	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT957H_XMLP_PKG;

/
