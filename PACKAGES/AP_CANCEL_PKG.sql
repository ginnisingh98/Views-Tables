--------------------------------------------------------
--  DDL for Package AP_CANCEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CANCEL_PKG" AUTHID CURRENT_USER AS
/* $Header: apicancs.pls 120.5 2006/06/17 00:09:49 bghose noship $ */

TYPE Inv_Line_Tab_Type IS TABLE OF ap_invoice_lines%ROWTYPE;

Function Is_Invoice_Cancellable(
             P_invoice_id        IN NUMBER,
             P_error_code           OUT NOCOPY VARCHAR2,   /* Bug 5300712 */
             P_debug_info        IN OUT NOCOPY VARCHAR2,
             P_calling_sequence  IN            VARCHAR2) RETURN BOOLEAN;

FUNCTION Ap_Cancel_Single_Invoice(
             P_invoice_id                 IN NUMBER,
             P_last_updated_by            IN NUMBER,
             P_last_update_login          IN NUMBER,
             P_accounting_date            IN DATE,
             P_message_name                  OUT NOCOPY VARCHAR2,
             P_invoice_amount                OUT NOCOPY NUMBER,
             P_base_amount                   OUT NOCOPY NUMBER,
             P_temp_cancelled_amount         OUT NOCOPY NUMBER,
             P_cancelled_by                  OUT NOCOPY NUMBER,
             P_cancelled_amount              OUT NOCOPY NUMBER,
             P_cancelled_date                OUT NOCOPY DATE,
             P_last_update_date              OUT NOCOPY DATE,
             P_original_prepayment_amount    OUT NOCOPY NUMBER,
             P_pay_curr_invoice_amount       OUT NOCOPY NUMBER,
	     P_token			     OUT NOCOPY VARCHAR2,
             P_calling_sequence           IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE Ap_Cancel_Invoices(
              P_check_id          IN NUMBER,
              P_last_updated_by   IN NUMBER,
              P_last_update_login IN NUMBER,
              P_accounting_date   IN DATE,
              P_num_cancelled        OUT NOCOPY NUMBER,
              P_num_not_cancelled    OUT NOCOPY NUMBER,
              P_calling_sequence  IN VARCHAR2);

END AP_CANCEL_PKG;

 

/
