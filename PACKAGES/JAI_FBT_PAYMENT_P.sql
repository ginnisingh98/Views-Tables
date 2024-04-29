--------------------------------------------------------
--  DDL for Package JAI_FBT_PAYMENT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_FBT_PAYMENT_P" AUTHID CURRENT_USER AS
--$Header: jainfbtpay.pls 120.0.12010000.1 2008/11/27 07:29:48 huhuliu noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     jainfbtpay.pls                                                     |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     To be called by the concurrent program for inserting the          |
--|      data into jai_fbt_payment table and  ap interface tables         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Fbt_Payment                                            |
--|                                                                       |
--| HISTORY                                                               |
--|     2008/10/18 Eric Ma       Created                                  |
--|                                                                       |
--+======================================================================*/

-- Declare global variable for package name
GV_MODULE_PREFIX       VARCHAR2(50) :='jai.plsql.JAINFBTPAY';

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
--    Fbt_Payment                        Public
--
--  DESCRIPTION:
--
--    This is the main procedure which will be called by the concurrent
--    program  for inserting the data into jai_fbt_payment table and
--    ap interface tables
--
--  PARAMETERS:
--     In:   pn_legal_entity_id        Identifier of legal entity
--           pn_fbt_year               Fbt year
--           pn_fbt_amount             Total fbt tax amount
--           pn_supplier_id            Identifier of supplier
--           pn_supplier_site_id       Identifier of supplier site
--           pn_ou_id                  Identifier of Operating unit
--           pn_fbt_tax_amount         The amount of fbt tax
--           pn_fbt_surcharge_amount   The amount of surcharge tax
--           pn_fbt_edu_cess_amount    The amount of edu cess tax
--           pn_FBT_sh_cess_AMOUNT     The amount of sh cess tax
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
--           21-OCT-2008   Eric Ma  created

PROCEDURE Fbt_Payment
( pv_errbuf                OUT NOCOPY VARCHAR2
, pv_retcode               OUT NOCOPY VARCHAR2
, pn_legal_entity_id       IN  jai_fbt_payment.legal_entity_id%TYPE
, pn_fbt_year              IN  jai_fbt_payment.fbt_year%TYPE
, pn_fbt_amount            IN  NUMBER
, pn_supplier_id           IN  jai_fbt_payment.inv_supplier_id%TYPE
, pn_supplier_site_id      IN  jai_fbt_payment.inv_supplier_site_id%TYPE
, pn_ou_id                 IN  jai_fbt_payment.inv_ou_id%TYPE
, pn_fbt_tax_amount        IN  jai_fbt_payment.fbt_tax_amount%TYPE
, pn_fbt_surcharge_amount  IN  jai_fbt_payment.fbt_surcharge_amount%TYPE
, pn_fbt_edu_cess_amount   IN  jai_fbt_payment.fbt_edu_cess_amount%TYPE
, pn_fbt_sh_cess_amount    IN  jai_fbt_payment.fbt_sh_cess_amount%TYPE
, pv_status_date           IN  VARCHAR2
);

END JAI_FBT_PAYMENT_P;

/
