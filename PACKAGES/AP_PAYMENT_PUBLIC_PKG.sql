--------------------------------------------------------
--  DDL for Package AP_PAYMENT_PUBLIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PAYMENT_PUBLIC_PKG" AUTHID CURRENT_USER AS
/* $Header: appaypks.pls 120.0.12010000.3 2009/03/20 04:16:29 njakkula ship $ */

  TYPE Invoice_Payment_Info_Rec IS RECORD
       (
        Invoice_ID                  NUMBER(15),
        Payment_Schedule_Num        NUMBER,
        Amount_To_Pay               NUMBER,
	Discount_Taken              NUMBER);

  TYPE Invoice_Payment_Info_Tab IS TABLE OF
       AP_PAYMENT_PUBLIC_PKG.Invoice_Payment_Info_Rec
       INDEX BY BINARY_INTEGER;

  PROCEDURE Create_Netting_Payment(
            P_Check_Rec                 IN
            AP_CHECKS_ALL%ROWTYPE,
            P_Invoice_Payment_Info_Tab  IN
            AP_PAYMENT_PUBLIC_PKG.Invoice_Payment_Info_Tab,
            P_Check_ID                  OUT NOCOPY   NUMBER,
            P_Curr_Calling_Sequence     IN  VARCHAR2,
            p_gl_date                   IN  DATE DEFAULT NULL/* p_gl_date Added for bug#7663371 */);

  PROCEDURE Create_Netting_Inv_Payment
            (P_Invoice_Payment_Info_Tab  IN
             AP_PAYMENT_PUBLIC_PKG.Invoice_Payment_Info_Tab,
             P_check_id                  IN  NUMBER,
             P_payment_type_flag         IN  VARCHAR2,
             P_payment_method            IN  VARCHAR2,
             P_ce_bank_acct_use_id       IN  NUMBER,
             P_bank_account_num          IN  VARCHAR2,
             P_bank_account_type         IN  VARCHAR2,
             P_bank_num                  IN  VARCHAR2,
             P_check_date                IN  DATE,
             P_period_name               IN  VARCHAR2,
             P_currency_code             IN  VARCHAR2,
             P_base_currency_code        IN  VARCHAR2,
             P_checkrun_id               IN  NUMBER,
             P_exchange_rate             IN  NUMBER,
             P_exchange_rate_type        IN  VARCHAR2,
             P_exchange_date             IN  DATE,
             P_set_of_books_id           IN  NUMBER,
             P_last_updated_by           IN  NUMBER,
             P_last_update_login         IN  NUMBER,
             P_accounting_event_id       IN  NUMBER,
             P_org_id                    IN  NUMBER,
             P_calling_sequence          IN  VARCHAR2
             );

  FUNCTION Get_Disc_For_Pmt_Schedule
           (p_invoice_id                 IN NUMBER,
	    p_payment_num                IN NUMBER,
	    p_date                       IN DATE)
  RETURN NUMBER;

  FUNCTION Get_Disc_For_Netted_Amt
           (p_invoice_id                 IN NUMBER,
	    p_payment_num                IN NUMBER,
	    p_date                       IN DATE,
	    P_Netted_Amt                 IN NUMBER)
  RETURN NUMBER;

END AP_PAYMENT_PUBLIC_PKG;

/
