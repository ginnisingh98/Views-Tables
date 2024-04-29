--------------------------------------------------------
--  DDL for Package PSP_PSPUPREP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSPUPREP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPUPREPS.pls 120.4 2007/10/29 07:28:05 amakrish noship $ */
	P_CONC_REQUEST_ID	number;
	P_INVALID_TABLES_QUERY4	varchar2(4000);
	P_INVALID_TABLES_QUERY1	varchar2(4000);
	P_INVALID_TABLES_QUERY2	varchar2(4000);
	P_INVALID_TABLES_QUERY3	varchar2(4000);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PSP_PSPUPREP_XMLP_PKG;

/
