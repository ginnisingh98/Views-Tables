--------------------------------------------------------
--  DDL for Package AP_REPORTS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_REPORTS_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: aprptuts.pls 120.3 2004/10/29 18:55:25 pjena noship $ */

FUNCTION get_period_name(l_invoice_id IN NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_period_name, WNDS, RNPS, WNPS);

FUNCTION get_check_period_name(l_check_id IN NUMBER) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_check_period_name, WNDS, RNPS, WNPS);


END AP_REPORTS_UTILITY_PKG;

 

/
