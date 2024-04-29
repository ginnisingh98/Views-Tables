--------------------------------------------------------
--  DDL for Package PO_POXSURUC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXSURUC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXSURUCS.pls 120.1 2007/12/25 12:35:01 krreddy noship $ */
 P_title varchar2(50);
 P_ACTIVE_INACTIVE varchar2(40);
 P_active_inactive_disp varchar2(80);
 P_CONC_REQUEST_ID number;
 function BeforeReport return boolean  ;
 function AfterReport return boolean  ;
END PO_POXSURUC_XMLP_PKG;


/
