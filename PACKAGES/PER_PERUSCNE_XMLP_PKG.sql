--------------------------------------------------------
--  DDL for Package PER_PERUSCNE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERUSCNE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERUSCNES.pls 120.0 2007/12/28 06:56:43 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	LP_SESSION_DATE	date;
	P_CONC_REQUEST_ID	number;
	P_PERSON_ID	varchar2(40);
	P_QUAL_DATE	date;
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_PERSON_NAME	varchar2(240);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_PERSON_NAME_p return varchar2;
END PER_PERUSCNE_XMLP_PKG;

/
