--------------------------------------------------------
--  DDL for Package AP_WEB_OA_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_OA_DETAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: apwodtls.pls 120.5 2006/02/24 11:21:45 sbalaji noship $ */

PROCEDURE GetEuroCode (p_euro_code OUT NOCOPY FND_CURRENCIES_VL.currency_code%TYPE);


PROCEDURE GetTaxPseudoSegmentDefaults(
             P_ExpTypeID                IN  AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE,
             P_ExpTypeTaxCodeUpdateable IN  OUT NOCOPY VARCHAR2,
             P_ExpTypeDefaultTaxCode    IN  OUT NOCOPY AP_TAX_CODES.name%TYPE,
             p_orgId                    IN  NUMBER);

END AP_WEB_OA_DETAIL_PKG;

 

/
