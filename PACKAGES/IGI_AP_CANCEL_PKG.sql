--------------------------------------------------------
--  DDL for Package IGI_AP_CANCEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_AP_CANCEL_PKG" AUTHID CURRENT_USER AS
/* $Header: igicancs.pls 115.6 2002/11/18 06:01:11 panaraya ship $ */

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
				    P_last_update_date	     OUT NOCOPY DATE,
                                    P_original_prepayment_amount OUT NOCOPY NUMBER,
				    P_calling_sequence       IN  VARCHAR2)
    RETURN BOOLEAN;

  PROCEDURE Ap_Cancel_Invoices(P_check_id	   IN  NUMBER,
			       P_last_updated_by   IN  NUMBER,
			       P_last_update_login IN  NUMBER,
			       P_set_of_books_id   IN  NUMBER,
			       P_accounting_date   IN  DATE,
			       P_period_name       IN  VARCHAR2,
			       P_num_cancelled	   OUT NOCOPY NUMBER,
			       P_num_not_cancelled OUT NOCOPY NUMBER,
			       P_calling_sequence  IN  VARCHAR2);

END IGI_AP_CANCEL_PKG;

 

/
