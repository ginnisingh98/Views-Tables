--------------------------------------------------------
--  DDL for Package Body AP_WEB_OA_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_OA_DETAIL_PKG" AS
/* $Header: apwodtlb.pls 120.6 2006/02/24 11:21:28 sbalaji noship $ */

PROCEDURE GetEuroCode (p_euro_code OUT NOCOPY FND_CURRENCIES_VL.currency_code%TYPE)
IS
BEGIN
    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DETAIL_PKG', 'start GetEuroCode');
    p_euro_code := GL_CURRENCY_API.get_euro_code();
    AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DETAIL_PKG', 'end GetEuroCode');
EXCEPTION
  WHEN OTHERS THEN
    p_euro_code := 'EUR';
END GetEuroCode;


PROCEDURE GetTaxPseudoSegmentDefaults(
             P_ExpTypeID                IN  AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE,
             P_ExpTypeTaxCodeUpdateable IN  OUT NOCOPY VARCHAR2,
             P_ExpTypeDefaultTaxCode    IN  OUT NOCOPY AP_TAX_CODES.name%TYPE,
             p_orgId                    IN  NUMBER)

IS
BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DETAIL_PKG', 'start GetTaxPseudoSegmentDefaults');
  AP_WEB_DFLEX_PKG.GetTaxPseudoSegmentDefaults(p_ExpTypeId,
                              P_ExpTypeTaxCodeUpdateable,
                              P_ExpTypeDefaultTaxCode,
                              p_orgId);
  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_OA_DETAIL_PKG', 'end GetTaxPseudoSegmentDefaults');

END GetTaxPseudoSegmentDefaults;


END AP_WEB_OA_DETAIL_PKG;

/
