--------------------------------------------------------
--  DDL for Package Body IGI_AP_CANCEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_AP_CANCEL_PKG" AS
/* $Header: igicancb.pls 115.10 2003/08/09 11:36:03 rgopalan ship $ */

  ---------------------------------------------------------------------
  -- Procedure Insert_Hold creates a CANCEL hold on the invoice using
  -- the translated message string as the hold reason.
  --
  PROCEDURE Insert_Hold(P_invoice_id	   IN  VARCHAR2,
		        P_message_name	   IN  VARCHAR2,
		        P_last_updated_by  IN  NUMBER,
		        P_calling_sequence IN  VARCHAR2)
  IS
  BEGIN
   NULL;
  END Insert_Hold;

  ---------------------------------------------------------------------
  -- Function Ap_Cancel_Single_Invoice cancels one invoice by executing
  -- the following sequence of steps, returning TRUE if successful and
  -- FALSE otherwise:
  --
  --  1. If invoice has an effective payment, return FALSE
  --  2. If invoice is selected for payment, return FALSE
  --  3. If invoice is already cancelled, return FALSE
  --  4. If invoices have been applied against this invoice (prepayment),
  --     return FALSE
  --  5. If invoice is matched to Finally Closed PO's, return FALSE
  --  5a If project related invoices have pending adjustments, return FALSE
  --  6. If invoice is matched, reverse matching
  --  6a.If invoice tax calculation level is line, calculate tax
  --  6b.If invoice has had tax withheld, undo withholding
  --  7. Clear out NOCOPY payment schedules
  --  7a.Create allocations for existing charges if needed
  --  8. Create reversing distribution lines
  --  8a.Fetch the maximum distribution line number
  --  8b.Set encumbered flags to 'N'
  --  8c.Insert distribution reversals based on existing lines
  --  9. Zero out NOCOPY the Invoice
  -- 10. Run AutoApproval for this invoice
  -- 11. If no posting holds remain then cancel the invoice
  -- 12. Commit
  --
  FUNCTION Ap_Cancel_Single_Invoice(P_invoice_id             IN  NUMBER,
			            P_last_updated_by        IN  NUMBER,
				    P_last_update_login      IN  NUMBER,
			            P_set_of_books_id        IN  NUMBER,
			            P_accounting_date        IN  DATE,
			            P_period_name            IN  VARCHAR2,
				    P_message_name	     OUT NOCOPY VARCHAR2,
				    P_invoice_amount	     OUT NOCOPY NUMBER,
				    P_base_amount	     OUT NOCOPY NUMBER,
				    P_tax_amount	     OUT NOCOPY NUMBER,
				    P_temp_cancelled_amount  OUT NOCOPY NUMBER,
				    P_cancelled_by	     OUT NOCOPY NUMBER,
				    P_cancelled_amount	     OUT NOCOPY NUMBER,
				    P_cancelled_date         OUT NOCOPY DATE,
				    P_last_update_date       OUT NOCOPY DATE,
				    P_original_prepayment_amount OUT NOCOPY NUMBER,
				    P_calling_sequence       IN  VARCHAR2)
    RETURN BOOLEAN
  IS
  BEGIN
   NULL;
  END Ap_Cancel_Single_Invoice;



  ---------------------------------------------------------------------
  -- Procedure Ap_Cancel_Invoices cancels all invoices associated with
  -- the payment given by P_check_id
  --
  -- Invoices that are not eligible for cancellation:
  --   1. invoices associated with an effective payment,
  --   2. invoices that are selected for payment,
  --   3. invoices that are already cancelled
  --   4. invoices (prepayments) that have been used by other invoices
  --   5. invoices that are matched to Finally Closed PO's)
  --   6. invoices which were paid originally by check but whose payment
  --      was removed prior to the voiding of the check i.e. through
  --      an invoice adjustment.
  -- are left unaffected.
  --
  -- AutoApproval is run for each invoice.  If the invoice has posting
  -- holds, it is zeroed out NOCOPY by reversing all invoice distributions and
  -- PO matching, but the invoice is not cancelled.
  --
  --
  PROCEDURE Ap_Cancel_Invoices(P_check_id	   IN  NUMBER,
			       P_last_updated_by   IN  NUMBER,
			       P_last_update_login IN  NUMBER,
			       P_set_of_books_id   IN  NUMBER,
			       P_accounting_date   IN  DATE,
			       P_period_name       IN  VARCHAR2,
			       P_num_cancelled	   OUT NOCOPY NUMBER,
			       P_num_not_cancelled OUT NOCOPY NUMBER,
			       P_calling_sequence  IN  VARCHAR2)
  IS
  BEGIN
   NULL;
  END Ap_Cancel_Invoices;


END IGI_AP_CANCEL_PKG;

/
