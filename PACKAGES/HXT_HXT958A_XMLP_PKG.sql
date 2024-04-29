--------------------------------------------------------
--  DDL for Package HXT_HXT958A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT958A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT958AS.pls 120.1 2008/03/27 08:12:16 vjaganat noship $ */
	START_DATE	date;
	END_DATE	date;
	P_START_DATE	varchar2(25);
        P_END_DATE	varchar2(25);
	P_CONC_REQUEST_ID	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT958A_XMLP_PKG;

/
