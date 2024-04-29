--------------------------------------------------------
--  DDL for Package PSA_AP_BC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_AP_BC_PVT" AUTHID CURRENT_USER AS
--$Header: psavapbs.pls 120.12.12010000.3 2009/12/08 16:48:56 cjain ship $

   ---------------------------------------------------------------------------

   g_debug_mode                     VARCHAR2(1):= 'N';

   TYPE Funds_Dist_Rec IS RECORD
   (
    invoice_id          AP_INVOICES.invoice_id%TYPE,
    invoice_num         AP_INVOICES.invoice_num%TYPE,
    legal_entity_id     AP_INVOICES.legal_entity_id%TYPE,
    invoice_type_code   AP_INVOICES.invoice_type_lookup_code%TYPE,
    inv_line_num        AP_INVOICE_DISTRIBUTIONS.invoice_line_number%TYPE,
    inv_distribution_id AP_INVOICE_DISTRIBUTIONS.invoice_distribution_id%TYPE,
    accounting_date     AP_INVOICE_DISTRIBUTIONS.accounting_date%TYPE,
    distribution_type   AP_INVOICE_DISTRIBUTIONS_ALL.LINE_TYPE_LOOKUP_CODE%TYPE,
    distribution_amount AP_INVOICE_DISTRIBUTIONS_ALL.AMOUNT%TYPE,
    set_of_books_id     AP_INVOICE_DISTRIBUTIONS.set_of_books_id%TYPE,
    bc_event_id         AP_INVOICE_DISTRIBUTIONS.bc_event_id%TYPE,
    org_id              AP_INVOICE_DISTRIBUTIONS.org_id%TYPE,
    result_code         GL_BC_PACKETS.result_code%TYPE,
    status_code         GL_BC_PACKETS.status_code%TYPE,
     SELF_ASSESSED_FLAG  ap_self_assessed_tax_dist_all.SELF_ASSESSED_FLAG%TYPE);
   TYPE Funds_Dist_Tab_Type IS TABLE OF Funds_Dist_Rec INDEX BY BINARY_INTEGER;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Events
   (
      p_init_msg_list    IN VARCHAR2,
      p_tab_fc_dist      IN Funds_Dist_Tab_Type,
      p_calling_mode     IN VARCHAR2,
      p_bc_mode          IN VARCHAR2,
      p_calling_sequence IN VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Events
   (
      p_init_msg_list    IN VARCHAR2,
      p_ledger_id        IN NUMBER,
      p_start_date       IN DATE,
      p_end_date         IN DATE,
      p_calling_sequence IN VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

  PROCEDURE delete_processed_orphan_events(
      p_init_msg_list    IN VARCHAR2,
      p_ledger_id        IN NUMBER,
      p_calling_sequence IN VARCHAR2,
      p_return_status    OUT NOCOPY VARCHAR2,
      p_msg_count        OUT NOCOPY NUMBER,
      p_msg_data         OUT NOCOPY VARCHAR2
      );
   ---------------------------------------------------------------------------

   PROCEDURE Get_Detailed_Results
   (
      p_init_msg_list    IN  VARCHAR2,
      p_tab_fc_dist      IN OUT NOCOPY Funds_Dist_Tab_Type,
      p_calling_sequence IN VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Get_GL_FundsChk_Result_Code
   (
      p_fc_result_code IN OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Process_Fundschk_Failure_Code
   (
      p_invoice_id          IN NUMBER,
      p_inv_line_num        IN NUMBER,
      p_dist_line_num       IN NUMBER,
      p_return_message_name IN OUT NOCOPY VARCHAR2,
      p_calling_sequence    IN VARCHAR2
   );

   ---------------------------------------------------------------------------

  PROCEDURE Reinstate_PO_Encumbrance
  (
      p_calling_mode     IN VARCHAR2,
      p_tab_fc_dist      IN Funds_Dist_Tab_Type,
      p_calling_sequence IN VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2
  );

  -----------------------------------------------------------------------------

  FUNCTION Get_PO_Reversed_Encumb_Amount
  (
              P_po_distribution_id   IN            NUMBER,
              P_start_gl_date        IN            DATE,
              P_end_gl_date          IN            DATE,
              P_calling_sequence     IN            VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

-----------------------------------------------------------------------------
FUNCTION isprepaydist
( p_inv_dist_id       IN NUMBER,
  p_inv_id            IN NUMBER,
  p_dist_type         IN VARCHAR2
) RETURN VARCHAR2;
-------------------------------------------------------------------

END PSA_AP_BC_PVT;

/
