--------------------------------------------------------
--  DDL for Package PO_POXPOCAN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOCAN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOCANS.pls 120.1 2007/12/25 11:11:40 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_CANCELLED_DATE_FROM	varchar2(40);
	P_VENDOR_NAME_FROM	varchar2(240);
	P_VENDOR_NAME_TO	varchar2(240);
	P_BUYER	varchar2(80);
	P_CANCELLED_DATE_TO	varchar2(40);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END PO_POXPOCAN_XMLP_PKG;


/
