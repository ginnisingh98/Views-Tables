--------------------------------------------------------
--  DDL for Package PSP_PSPENASG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSPENASG_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPENASGS.pls 120.4 2007/10/29 07:21:47 amakrish noship $ */
	P_REQUEST_ID	number;
	P_conc_request_id	number;
	function cf_change_sourceformula(change_type in varchar2) return char  ;
	function cf_org_nameformula(reference_id in number, assignment_id in number, action_type in varchar2, change_type in varchar2) return char  ;
	function cf_element_nameformula(reference_id in number, action_type in varchar2, change_type in varchar2) return char  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PSP_PSPENASG_XMLP_PKG;

/
