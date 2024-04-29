--------------------------------------------------------
--  DDL for Package PO_POXSURUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXSURUM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXSURUMS.pls 120.1 2007/12/25 12:37:18 krreddy noship $ */
 P_title varchar2(50);
 P_ACTIVE_INACTIVE varchar2(40);
 P_qty_precision varchar2(40);
 P_active_inactive_disp varchar2(80);
 P_CONC_REQUEST_ID number;
 procedure get_precision  ;
 function BeforeReport return boolean  ;
 function AfterReport return boolean  ;
END PO_POXSURUM_XMLP_PKG;


/
