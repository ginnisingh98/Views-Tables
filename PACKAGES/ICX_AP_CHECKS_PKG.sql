--------------------------------------------------------
--  DDL for Package ICX_AP_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_AP_CHECKS_PKG" AUTHID CURRENT_USER AS
/* $Header: ICXAPCKS.pls 115.0 99/08/09 17:21:44 porting ship $ */

  FUNCTION get_invoices_paid(l_check_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(get_invoices_paid, WNDS, WNPS, RNPS);
END ICX_AP_CHECKS_PKG;

 

/
