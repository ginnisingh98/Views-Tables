--------------------------------------------------------
--  DDL for Package PER_PERFREMD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERFREMD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERFREMDS.pls 120.0 2007/12/24 13:19:03 amakrish noship $ */
	P_BUSINESS_GROUP_ID	varchar2(32767);
	P_SESSION_DATE	date;
	P_CONC_REQUEST_ID	number;
	CP_BUSINESS_GROUP_NAME	varchar2(240);
	function BeforeReport return boolean  ;
	function BeforePForm return boolean  ;
	function AfterReport return boolean  ;
	Function CP_BUSINESS_GROUP_NAME_p return varchar2;
END PER_PERFREMD_XMLP_PKG;

/
