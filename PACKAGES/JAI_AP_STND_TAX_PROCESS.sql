--------------------------------------------------------
--  DDL for Package JAI_AP_STND_TAX_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_STND_TAX_PROCESS" AUTHID CURRENT_USER AS
--$Header: jaiapprcs.pls 120.2.12010000.1 2008/11/18 04:33:05 sshinde ship $

--+=======================================================================+
--|               Copyright (c) 2007 Oracle Corporation
--|                       Redwood Shores, CA, USA
--|                         All rights reserved.
--+=======================================================================
--| FILENAME
--|     jai_ap_stnd_tax_process.pls
--|
--| DESCRIPTION
--|
--|     This package contains the following PL/SQL tables/procedures/functions
--|     to process and populate tax lines for the standard lone invoices
--|
--|
--|
--|
--|
--| TYPE LIEST
--|
--|
--| PROCEDURE LIST
--|   Populate_Stnd_Inv_Taxes
--|   Create_Tax_Lines
--|   Default_Calculate_Taxes
--|
--|
--| HISTORY
--|   23-Aug-2007    Eric  Ma Created
--|
--+======================================================================*/

GV_MODULE_PREFIX           VARCHAR2 (100) := 'jai.plsql.JAI_AP_STND_TAX_PROCESS';
GV_CONSTANT_MISCELLANEOUS  VARCHAR2 (20)  := 'MISCELLANEOUS';
GV_CONSTANT_ITEM           VARCHAR2 (20)  := 'ITEM';
GV_NOT_MATCH_TYPE          VARCHAR2 (20)  := 'NOT_MATCHED';
GV_JAI_AP_INVOICE_LINES    VARCHAR2 (100) := 'JAI_AP_INVOICE_LINES';
GV_LINES_CREATEED         VARCHAR2 (10)  := 'NO';
--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Stnd_Inv_Taxes               Public
--
--  DESCRIPTION:
--
--      This procedure is main entrance procedure used by form and invokes the
--      create_tax_line procedure
--
--  PARAMETERS:
--      In:  pn_invoice_id      NUMBER
--           pn_line_number     NUMBER
--           pn_vendor_site_id  NUMBER
--           pv_currency        VARCHAR2
--           pn_line_amount     NUMBER
--           pn_tax_category_id NUMBER
--           pv_tax_modified    VARCHAR2
--
--
--     Out:
--
--  PRE-COND  : invoice is valid
--
--  EXCEPTIONS: defualt tax are created
--
--===========================================================================

PROCEDURE Populate_Stnd_Inv_Taxes
( pn_invoice_id      IN  NUMBER
, pn_line_number     IN  NUMBER
, pn_vendor_site_id  IN  NUMBER
, pv_currency        IN  VARCHAR2
, pn_line_amount     IN  NUMBER   DEFAULT NULL
, pn_tax_category_id IN  NUMBER   DEFAULT NULL
, pv_tax_modified    IN  VARCHAR2
,pn_old_tax_category_id in VARCHAR2 DEFAULT NULL);

--==========================================================================
--  PROCEDURE NAME:
--
--    Create_Tax_Lines               Public
--
--  DESCRIPTION:
--
--      This procedure is to create tax invoice line and distribution line in
--      both standard tables of ap module and jai ap modules
--
--  PARAMETERS:
--      In:  pn_organization_id NUMBER    organization id
--           pv_currency        VARCHAR2  currency
--           pn_location_id     NUMBER    location id
--           pn_invoice_id      NUMBER    invoice id
--           pn_line_number     NUMBER    item line number
--           pv_action          VARCHAR2  normally it is DEFAULT_TAXES,it can
--                                        be jai_constants.recalculate_taxes
--           pn_tax_category_id NUMBER    tax category id
--
--
--     Out:
--
--
--  PRE-COND  : invoice is valid
--
--  EXCEPTIONS: defualt tax are created
--
--===========================================================================





PROCEDURE Create_Tax_Lines
(
  pn_organization_id  IN  NUMBER
, pv_currency         IN  VARCHAR2
, pn_location_id      IN  NUMBER
, pn_invoice_id       IN  NUMBER
, pn_line_number      IN  NUMBER   DEFAULT NULL
, pv_action           IN  VARCHAR2 DEFAULT jai_constants.default_taxes
, pn_tax_category_id  IN  NUMBER
, pv_tax_modified     IN  VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Default_Calculate_Taxes               Public
--
--  DESCRIPTION:
--
--      This procedure is to invoke standard procedure to insert item
--      information  into jai_cmn_document_taxes
--
--  PARAMETERS:
--    In:
--      pn_invoice_id        IN            NUMBER     invoice id
--      pn_line_number       IN            NUMBER     item line number
--      xn_tax_amount        IN OUT NOCOPY NUMBER     line tax amount
--      pn_vendor_id         IN            NUMBER     vendor/supplier id
--      pn_vendor_site_id    IN            NUMBER     vendor/supplier site id
--      pv_currency_code     IN            VARCHAR2   currency code
--      pn_tax_category_id   IN            NUMBER     tax category id
--      pv_tax_modified      IN            VARCHAR2   a flag indicating whether
--                                                   tax modified in line level
--
--
--    Out:
--
--
--
--  PRE-COND  : invoice is valid
--
--  EXCEPTIONS: defualt tax are created
--
--===========================================================================

PROCEDURE Default_Calculate_Taxes
( pn_invoice_id      IN            NUMBER
, pn_line_number     IN            NUMBER
, xn_tax_amount      IN OUT NOCOPY NUMBER
, pn_vendor_id       IN            NUMBER
, pn_vendor_site_id  IN            NUMBER
, pv_currency_code   IN            VARCHAR2
, pn_tax_category_id IN            NUMBER
, pv_tax_modified    IN            VARCHAR2
);

END JAI_AP_STND_TAX_PROCESS;

/
