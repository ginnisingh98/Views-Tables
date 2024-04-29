--------------------------------------------------------
--  DDL for Package AR_ARXRWS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ARXRWS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ARXRWSS.pls 120.0 2007/12/27 14:07:54 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	P_COMPANY_NAME	varchar2(80);
	P_NO_DATA_FOUND	varchar2(2000);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END AR_ARXRWS_XMLP_PKG;


/
