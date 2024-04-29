--------------------------------------------------------
--  DDL for Package PA_PACINTAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PACINTAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PACINTARS.pls 120.0 2008/01/02 10:55:06 krreddy noship $ */
	P_PERIODS	varchar2(40);
	P_from_proj_num	varchar2(40);
	p_to_proj_num	varchar2(40);
	P_USER_ID	number;
	P_CONC_REQUEST_ID	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PA_PACINTAR_XMLP_PKG;

/
