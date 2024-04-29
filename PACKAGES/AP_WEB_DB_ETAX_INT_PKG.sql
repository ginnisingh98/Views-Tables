--------------------------------------------------------
--  DDL for Package AP_WEB_DB_ETAX_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_ETAX_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbtxs.pls 120.0 2005/05/21 00:00:57 qle noship $ */

SUBTYPE taxClassification			IS fnd_lookups.lookup_code%TYPE;

-------------------------------------------------------------------
FUNCTION IsTaxCodeWebEnabled(
	P_ExpTypeDefaultTaxCode IN  taxClassification) RETURN BOOLEAN;


END AP_WEB_DB_ETAX_INT_PKG;

 

/
