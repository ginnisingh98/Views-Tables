--------------------------------------------------------
--  DDL for Package PO_POXREQIM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXREQIM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXREQIMS.pls 120.1 2007/12/25 11:42:57 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_INTERFACE_SOURCE_CODE	varchar2(40);
	P_BATCH_ID	varchar2(40);
	P_DELETE_FLAG	varchar2(40);
	P_SORT	varchar2(40);
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
END PO_POXREQIM_XMLP_PKG;


/
