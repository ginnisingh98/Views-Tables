--------------------------------------------------------
--  DDL for Package PO_CLM_PAY_INSTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CLM_PAY_INSTR_PKG" AUTHID CURRENT_USER AS
/* $Header: PO_CLM_PAY_INSTR_PKG.pls 120.0.12010000.1 2014/01/30 09:42:12 amalick noship $ */

  TYPE r_dist_info IS RECORD
    (po_distribution_id             PO_DISTRIBUTIONS.po_distribution_id%TYPE,
     quantity_invoiced              PO_DISTRIBUTIONS.quantity_billed%TYPE,
     amount_invoiced                PO_DISTRIBUTIONS.amount_billed%TYPE,
     po_dist_ccid                   PO_DISTRIBUTIONS.code_combination_id%TYPE,
     accrue_on_receipt_flag         PO_DISTRIBUTIONS.accrue_on_receipt_flag%TYPE,
     project_id                     PO_DISTRIBUTIONS.project_id%TYPE,
     task_id                        PO_DISTRIBUTIONS.task_id%TYPE,
     award_id                       PO_DISTRIBUTIONS.award_id%TYPE DEFAULT NULL,
     expenditure_type               PO_DISTRIBUTIONS.expenditure_type%TYPE,
     expenditure_item_date          PO_DISTRIBUTIONS.expenditure_item_date%TYPE,
     expenditure_organization_id    PO_DISTRIBUTIONS.expenditure_organization_id%TYPE,
     reference_1                    AP_INVOICE_LINES_ALL.reference_1%TYPE,
     reference_2                    AP_INVOICE_LINES_ALL.reference_2%TYPE
    );

  TYPE dist_tab_type IS TABLE OF r_dist_info INDEX BY BINARY_INTEGER;

  PROCEDURE GET_CLM_PAY_INSTR_PRORATION
  ( p_invoice_type         IN  VARCHAR2,
    p_match_mode           IN  VARCHAR2,
    p_match_type           IN  VARCHAR2,
    p_po_line_location_id  IN  NUMBER,
    p_match_quantity       IN  NUMBER,
    p_match_amount         IN  NUMBER,
    p_overbill_flag        IN  VARCHAR2,
    p_unit_price           IN  NUMBER,
    p_min_acct_unit        IN  NUMBER,
    p_precision            IN  NUMBER,
    x_dist_tab             OUT NOCOPY  dist_tab_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_return_msg    OUT NOCOPY VARCHAR2
  );

  FUNCTION IS_CLM_PAY_INSTRUCTION_ENABLED
  (  p_po_line_location_id  IN  NUMBER,
     p_invoice_type         IN  VARCHAR2
  ) RETURN BOOLEAN;

END PO_CLM_PAY_INSTR_PKG;

/
