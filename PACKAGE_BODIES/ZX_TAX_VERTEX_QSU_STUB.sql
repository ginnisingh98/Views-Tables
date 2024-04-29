--------------------------------------------------------
--  DDL for Package Body ZX_TAX_VERTEX_QSU_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_VERTEX_QSU_STUB" AS
/* $Header: zxvtxqsb.pls 120.1 2005/09/22 13:09:04 vchallur noship $ */
    /* ********************** Procedure Specifications ********************* */

    /* Calculate taxes for a given invoice. */
PROCEDURE QSUCalculateTaxes (pContextRec        IN OUT NOCOPY tQSUContextRecord,
                             pInvoiceRecIn      IN     tQSUInvoiceRecord,
                             pLineItemTblIn     IN     tQSULineItemTable,
                             pInvoiceRecOut     IN OUT NOCOPY tQSUInvoiceRecord,
                             pLineItemTblOut    IN OUT NOCOPY tQSULineItemTable,
                             pWriteToPreReturns IN     BOOLEAN) IS
BEGIN
null;
END;

    /* Retrieve version information for the Quantum for Sales */
    /* and Use Tax Oracle PL/SQL Tax Calculation API. */
PROCEDURE QSUGetVersionInfo (pContextRec IN OUT NOCOPY tQSUContextRecord,
                             pVersionRec OUT NOCOPY   tQSUVersionRecord) IS
BEGIN
null;
END;

    /* Initialize invoice data structures. */
PROCEDURE QSUInitializeInvoice (pContextRec    IN OUT NOCOPY tQSUContextRecord,
                                pInvoiceRecIn  IN OUT NOCOPY tQSUInvoiceRecord,
                                pLineItemTblIn IN OUT NOCOPY tQSULineItemTable) IS
BEGIN
   -- RAISE ARP_TAX_VERTEX.QSU_NOT_FOUND;
   Null;
END;

    /* Write invoice output information to the Quantum for Sales */
    /* and Use Tax pre-returns register table. */
PROCEDURE QSUWritePreReturnsData (pContextRec     IN OUT NOCOPY tQSUContextRecord,
                                  pInvoiceRecOut  IN     tQSUInvoiceRecord,
                                  pLineItemTblOut IN     tQSULineItemTable) IS
BEGIN
null;
END;

END ZX_TAX_VERTEX_QSU_STUB;

/
