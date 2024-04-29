--------------------------------------------------------
--  DDL for Package JAI_FBT_SETTLEMENT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_FBT_SETTLEMENT_P" AUTHID CURRENT_USER AS
--$Header: jainfbtset.pls 120.0 2007/12/24 13:07:53 eaggarwa noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jai_fbt_settlement_p.pls                                          |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     To be called by the concurrent program for inserting the          |
--|      data into jai_fbt_settlement table and  ap interface tables      |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Fbt_Settlement                                         |
--|                                                                       |
--| HISTORY                                                               |
--|     2007/10/18 Jason Liu     Created                                  |
--|                                                                       |
--+======================================================================*/

-- Declare global variable for package name
GV_MODULE_PREFIX       VARCHAR2(50) :='jai.plsql.JAI_FBT_SETTLEMENT_P';
GV_DATE_MASK  CONSTANT VARCHAR2(25):= 'DD-MON-YYYY';
-- type for ap_invoices_interface
TYPE inv_interface_rec_type IS RECORD
( invoice_id                 ap_invoices_interface.invoice_id%TYPE
, invoice_num                ap_invoices_interface.invoice_num%TYPE
, invoice_date               ap_invoices_interface.invoice_date%TYPE
, vendor_id                  ap_invoices_interface.vendor_id%TYPE
, vendor_site_id             ap_invoices_interface.vendor_site_id%TYPE
, invoice_amount             ap_invoices_interface.invoice_amount%TYPE
, invoice_currency_code      ap_invoices_interface.invoice_currency_code%TYPE
, accts_pay_ccid             ap_invoices_interface.accts_pay_code_combination_id%TYPE
, source                     ap_invoices_interface.source%TYPE
, org_id                     ap_invoices_interface.org_id%TYPE
, legal_entity_id            ap_invoices_interface.legal_entity_id%TYPE
, payment_method_lookup_code ap_invoices_interface.payment_method_lookup_code%TYPE
, created_by                 ap_invoices_interface.created_by%TYPE
, creation_date              ap_invoices_interface.creation_date%TYPE
, last_updated_by            ap_invoices_interface.last_updated_by%TYPE
, last_update_date           ap_invoices_interface.last_update_date%TYPE
, last_update_login          ap_invoices_interface.last_update_login%TYPE
);

-- type for ap_invoice_lines_interface
TYPE inv_lines_interface_rec_type IS RECORD
( invoice_id               ap_invoice_lines_interface.invoice_id%TYPE
, invoice_line_id          ap_invoice_lines_interface.invoice_line_id%TYPE
, line_number              ap_invoice_lines_interface.line_number%TYPE
, line_type_lookup_code    ap_invoice_lines_interface.line_type_lookup_code%TYPE
, amount                   ap_invoice_lines_interface.amount%TYPE
, accounting_date          ap_invoice_lines_interface.accounting_date%TYPE
, description              ap_invoice_lines_interface.description%TYPE
, dist_code_combination_id ap_invoice_lines_interface.dist_code_combination_id%TYPE
, org_id                   ap_invoice_lines_interface.org_id%TYPE
, created_by               ap_invoice_lines_interface.created_by%TYPE
, creation_date            ap_invoice_lines_interface.creation_date%TYPE
, last_updated_by          ap_invoice_lines_interface.last_updated_by%TYPE
, last_update_date         ap_invoice_lines_interface.last_update_date%TYPE
, last_update_login        ap_invoice_lines_interface.last_update_login%TYPE
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Fbt_Settlement                        Public
--
--  DESCRIPTION:
--
--    This is the main procedure which will be called by the concurrent
--    program  for inserting the data into jai_fbt_settlement table and
--    ap interface tables
--
--  PARAMETERS:
--      In:  pn_legal_entity_id  Identifier of legal entity
--           pv_start_date       Identifier of period start date
--           pv_end_date         Identifier of period end date
--           pn_projected_amount Identifier of projected FBT amount
--           pn_supplier_id      Identifier of supplier id
--           pn_supplier_site_id Identifier of supplier site id
--
--      Out: pv_errbuf           Returns the error if concurrent program
--                               does not execute completely
--           pv_retcode          Returns success or failure
--
--  DESIGN REFERENCES:
--    FBT Technical Design Document 1.1.doc
--
--  CHANGE HISTORY:
--
--           18-OCT-2007   Jason Liu  created

PROCEDURE Fbt_Settlement
( pv_errbuf           OUT NOCOPY VARCHAR2
, pv_retcode          OUT NOCOPY VARCHAR2
, pn_legal_entity_id  IN  jai_fbt_settlement.legal_entity_id%TYPE
, pv_start_date       IN  VARCHAR2
, pv_end_date         IN  VARCHAR2
, pn_projected_amount IN  jai_fbt_settlement.Projected_Amount%TYPE
, pn_supplier_id      IN  jai_fbt_settlement.inv_supplier_id%TYPE
, pn_supplier_site_id IN jai_fbt_settlement.inv_supplier_site_id%TYPE
);

END JAI_FBT_SETTLEMENT_P;

/
