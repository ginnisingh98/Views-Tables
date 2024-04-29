--------------------------------------------------------
--  DDL for Package GL_GLXRDRTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLXRDRTS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLXRDRTSS.pls 120.0 2007/12/27 15:09:05 vijranga noship $ */
	P_PERIOD	varchar2(15);
	P_FROM_CURRENCY	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_TO_CURRENCY	varchar2(15);
	P_PERIOD_SET_NAME	varchar2(15);
	P_CONVERSION_TYPE	varchar2(30);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END GL_GLXRDRTS_XMLP_PKG;


/
