--------------------------------------------------------
--  DDL for Package AR_ARHDUNDP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARHDUNDP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHDUNDPS.pls 120.0 2007/12/27 13:20:46 abraghun noship $ */
	P_COMPANY_NAME	varchar2(30);
	P_DUNS_NUMBER	varchar2(15);
	P_CONC_REQUEST_ID	number;
	FUNCTION BeforeReport RETURN BOOLEAN  ;
	FUNCTION AfterReport RETURN BOOLEAN  ;
END AR_ARHDUNDP_XMLP_PKG;


/
