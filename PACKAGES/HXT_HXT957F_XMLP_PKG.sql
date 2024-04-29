--------------------------------------------------------
--  DDL for Package HXT_HXT957F_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT957F_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT957FS.pls 120.0 2007/12/03 11:26:50 amakrish noship $ */
	P_CONC_REQUEST_ID	number;
	function var_type_desformula(VAR_TYPE in varchar2) return varchar2  ;
	function Var_Type_NameFormula(VAR_TYPE in varchar2,VAR_TYPE_ID in number) return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT957F_XMLP_PKG;

/
