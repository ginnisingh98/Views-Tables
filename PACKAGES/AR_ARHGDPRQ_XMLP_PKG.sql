--------------------------------------------------------
--  DDL for Package AR_ARHGDPRQ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARHGDPRQ_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHGDPRQS.pls 120.0 2007/12/27 13:22:04 abraghun noship $ */
	P_FROM_DATE	varchar2(30);
	P_TO_DATE	varchar2(30);
	P_COMPANY_NAME	varchar2(30);
	P_DATE_FORMAT	varchar2(30);
	P_INT_FROM_DATE	date;
	P_INT_TO_DATE	date;
	P_CONC_REQUEST_ID	number;
	FUNCTION BeforeReport RETURN BOOLEAN  ;
	FUNCTION AfterReport RETURN BOOLEAN  ;
END AR_ARHGDPRQ_XMLP_PKG;


/
