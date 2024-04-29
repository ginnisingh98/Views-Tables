--------------------------------------------------------
--  DDL for Package PO_POXSURQC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXSURQC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXSURQCS.pls 120.1 2007/12/25 12:33:34 krreddy noship $ */
 P_title varchar2(50);
 P_ACTIVE_INACTIVE varchar2(40);
 P_ORDERBY varchar2(8);
 P_active_inactive_disp varchar2(80);
 P_orderby_displayed varchar2(80);
 P_CONC_REQUEST_ID number;
 function orderby_clauseFormula return VARCHAR2  ;
 function BeforeReport return boolean  ;
 function AfterReport return boolean  ;
END PO_POXSURQC_XMLP_PKG;


/
