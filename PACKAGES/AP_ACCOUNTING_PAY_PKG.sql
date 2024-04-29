--------------------------------------------------------
--  DDL for Package AP_ACCOUNTING_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ACCOUNTING_PAY_PKG" AUTHID CURRENT_USER AS
/* $Header: apacpays.pls 120.6.12010000.2 2010/03/14 17:08:37 vasvenka ship $ */


  -- Public Variables declared here

  G_Base_Currency_Code      AP_SYSTEM_PARAMETERS.Base_Currency_Code%TYPE;

  G_Pay_Pmt_History_ID      AP_PAYMENT_HISTORY.Payment_History_ID%TYPE;
  G_Pmt_To_Base_XRate_Type  AP_PAYMENT_HISTORY.Pmt_To_Base_XRate_Type%TYPE;
  G_Pmt_To_Base_XRate_Date  AP_PAYMENT_HISTORY.Pmt_To_Base_XRate_Date%TYPE;
  G_Pmt_To_Base_XRate       AP_PAYMENT_HISTORY.Pmt_To_Base_XRate%TYPE;

  G_Mat_Pmt_History_ID      AP_PAYMENT_HISTORY.Payment_History_ID%TYPE;
  G_Mat_To_Base_XRate_Type  AP_PAYMENT_HISTORY.Pmt_To_Base_XRate_Type%TYPE;
  G_Mat_To_Base_XRate_Date  AP_PAYMENT_HISTORY.Pmt_To_Base_XRate_Date%TYPE;
  G_Mat_To_Base_XRate       AP_PAYMENT_HISTORY.Pmt_To_Base_XRate%TYPE;

  G_Clr_Pmt_History_ID      AP_PAYMENT_HISTORY.Payment_History_ID%TYPE;
  G_Clr_To_Base_XRate_Type  AP_PAYMENT_HISTORY.Pmt_To_Base_XRate_Type%TYPE;
  G_Clr_To_Base_XRate_Date  AP_PAYMENT_HISTORY.Pmt_To_Base_XRate_Date%TYPE;
  G_Clr_To_Base_XRate       AP_PAYMENT_HISTORY.Pmt_To_Base_XRate%TYPE;


  -- Record for cursor xla_events_cur
  TYPE r_xla_event_info IS RECORD
       (event_id              XLA_EVENTS_GT.event_id%TYPE
       ,event_type_code       XLA_EVENTS_GT.event_type_code%TYPE
       ,event_date            XLA_EVENTS_GT.event_date%TYPE
       ,event_number          XLA_EVENTS_GT.event_number%TYPE
       ,event_status_code     XLA_EVENTS_GT.event_status_code%TYPE
       ,entity_code           XLA_EVENTS_GT.entity_code%TYPE
       ,source_id_int_1       XLA_EVENTS_GT.source_id_int_1%TYPE
       );


  -- Record for cursor payment_history
  TYPE r_pay_hist_info IS RECORD
      (Payment_History_ID          AP_Payment_History.Payment_History_ID%TYPE
      ,Pmt_Currency_Code           AP_Payment_History.Pmt_Currency_Code%TYPE
      ,Pmt_To_Base_XRate_Type      AP_Payment_History.Pmt_To_Base_XRate_Type%TYPE
      ,Pmt_To_Base_XRate_Date      AP_Payment_History.Pmt_To_Base_XRate_Date%TYPE
      ,Pmt_To_Base_XRate           AP_Payment_History.Pmt_To_Base_XRate%TYPE
      ,Bank_Currency_Code          AP_Payment_History.Bank_Currency_Code%TYPE
      ,Bank_To_Base_XRate_Type     AP_Payment_History.Bank_To_Base_XRate_Type%TYPE
      ,Bank_To_Base_XRate_Date     AP_Payment_History.Bank_To_Base_XRate_Date%TYPE
      ,Bank_To_Base_XRate          AP_Payment_History.Bank_To_Base_XRate%TYPE
      ,Errors_Bank_Amount          AP_Payment_History.Errors_Bank_Amount%TYPE
      ,Charges_Bank_Amount         AP_Payment_History.Charges_Bank_Amount%TYPE
      ,Rev_Pmt_Hist_ID             AP_Payment_History.Rev_Pmt_Hist_ID%TYPE
      ,Related_Event_ID            AP_Payment_History.Related_Event_ID%TYPE
      ,Invoice_Adjustment_Event_ID AP_Payment_History.Invoice_Adjustment_Event_ID%TYPE
      );


  -- Record for cursor invoice_header
  TYPE r_invoices_info IS RECORD
      (Invoice_ID                    AP_Invoices.Invoice_ID%TYPE
      ,Invoice_Amount                AP_Invoices.Invoice_Amount%TYPE
      ,Invoice_Currency_Code         AP_Invoices.Invoice_Currency_Code%TYPE
      ,Payment_Currency_Code         AP_Invoices.Payment_Currency_Code%TYPE
      ,Base_Currency_Code            AP_System_Parameters.Base_Currency_Code%TYPE
      ,Pay_Curr_Invoice_Amount       AP_Invoices.Pay_Curr_Invoice_Amount%TYPE
      ,Payment_Cross_Rate_Type       AP_Invoices.Payment_Cross_Rate_Type%TYPE
      ,Payment_Cross_Rate_Date       AP_Invoices.Payment_Cross_Rate_Date%TYPE
      ,Payment_Cross_Rate            AP_Invoices.Payment_Cross_Rate%TYPE
      ,Exchange_Rate_Type            AP_Invoices.Exchange_Rate_Type%TYPE
      ,Exchange_Date                 AP_Invoices.Exchange_Date%TYPE
      ,Exchange_Rate                 AP_Invoices.Exchange_Rate%TYPE
      ,Disc_Is_Inv_Less_Tax_Flag     AP_Invoices.Disc_Is_Inv_Less_Tax_Flag%TYPE
      ,Exclude_Freight_From_Discount AP_Invoices.Exclude_Freight_From_Discount%TYPE
      );


  -- Record for cursor invoice_dists
  TYPE r_inv_dist_info IS RECORD
      (Invoice_Distribution_ID   AP_Invoice_Distributions.Invoice_Distribution_ID%TYPE
      ,Line_Type_Lookup_Code     AP_Invoice_Distributions.Line_Type_Lookup_Code%TYPE
      ,Amount                    AP_Invoice_Distributions.Amount%TYPE
      ,Base_Amount               AP_Invoice_Distributions.Base_Amount%TYPE
      ,PO_Distribution_ID        AP_Invoice_Distributions.PO_Distribution_ID%TYPE
      ,RCV_Transaction_ID        AP_Invoice_Distributions.RCV_Transaction_ID%TYPE
      ,Reversal_Flag             AP_Invoice_Distributions.Reversal_Flag%TYPE
      ,Parent_Reversal_ID        AP_Invoice_Distributions.Parent_Reversal_ID%TYPE
      ,AWT_Related_ID            AP_Invoice_Distributions.AWT_Related_ID%TYPE
      ,AWT_Invoice_Payment_ID    AP_Invoice_Distributions.AWT_Invoice_Payment_ID%TYPE
      ,Quantity_Variance         AP_Invoice_Distributions.Quantity_Variance%TYPE
      ,Base_Quantity_Variance    AP_Invoice_Distributions.Base_Quantity_Variance%TYPE
      ,Amount_Variance           AP_Invoice_Distributions.Amount_Variance%TYPE
      ,Base_Amount_Variance      AP_Invoice_Distributions.Base_Amount_Variance%TYPE
      ,Historical_Flag           AP_Invoice_Distributions.Historical_Flag%TYPE
      ,Accounting_Event_Id       AP_Invoice_Distributions.Accounting_Event_id%TYPE
      );

  -- Main procedure to create payment hist dists and prepay appl payment dists
  PROCEDURE Do_Pay_Accounting
       (P_Calling_Sequence           IN    VARCHAR2
       );

  PROCEDURE Delete_Hist_Dists
       (P_Calling_Sequence           IN    VARCHAR2
       );

  FUNCTION Get_Casc_Pay_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Related_Event_ID           IN    NUMBER
       ,P_Invoice_Payment_ID         IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;


  FUNCTION Get_Casc_Inv_Dist_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Related_Event_ID           IN    NUMBER
       ,P_Invoice_Payment_ID         IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;


  FUNCTION Get_Casc_Bank_Curr_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Related_Event_ID           IN    NUMBER
       ,P_Invoice_Payment_ID         IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;


  FUNCTION Get_Casc_Prepay_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Prepay_App_Dist_ID         IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;


  FUNCTION Get_Casc_Tax_Diff_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Prepay_App_Dist_ID         IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;


  FUNCTION Get_Casc_Discount_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Related_Event_ID           IN    NUMBER
       ,P_Invoice_Payment_ID         IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;


  FUNCTION Get_Casc_Inv_Dist_Disc_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Related_Event_ID           IN    NUMBER
       ,P_Invoice_Payment_ID         IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;


  FUNCTION Get_Casc_Bank_Curr_Disc_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Related_Event_ID           IN    NUMBER
       ,P_Invoice_Payment_ID         IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;


  PROCEDURE Get_Pay_Sum
       (P_Invoice_Distribution_ID    IN          NUMBER
       ,P_Transaction_Type           IN          VARCHAR2
       ,P_Payment_Sum                OUT NOCOPY  NUMBER
       ,P_Inv_Dist_Sum               OUT NOCOPY  NUMBER
       ,P_Bank_Curr_Sum              OUT NOCOPY  NUMBER
       ,P_Calling_Sequence           IN          VARCHAR2
       );
--Bug 9282465
  PROCEDURE Get_Pay_Base_Sum
       (P_Invoice_Distribution_ID    IN          NUMBER
       ,P_Transaction_Type           IN          VARCHAR2
       ,P_Payment_Sum                OUT NOCOPY  NUMBER
       ,P_Inv_Dist_Sum               OUT NOCOPY  NUMBER
       ,P_Bank_Curr_Sum              OUT NOCOPY  NUMBER
       ,P_Calling_Sequence           IN          VARCHAR2
       );

  FUNCTION Get_Prepay_Sum
       (P_Invoice_Distribution_ID    IN    NUMBER
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN NUMBER;

--Bug 9282465
  PROCEDURE Get_Prepay_Base_Sum
       (P_Invoice_Distribution_ID    IN          NUMBER
       ,P_Paid_Base_Sum              OUT NOCOPY  NUMBER
       ,P_Inv_Dist_Base_Sum          OUT NOCOPY  NUMBER
       ,P_Clr_Base_Curr_Sum          OUT NOCOPY  NUMBER
       ,P_Calling_Sequence           IN          VARCHAR2
       );

  FUNCTION Is_Final_Payment
       (P_Inv_Rec                    IN    r_invoices_info
       ,P_Payment_Amount             IN    NUMBER
       ,P_Discount_Amount            IN    NUMBER
       ,P_Prepay_Amount              IN    NUMBER
       ,P_Transaction_Type           IN    VARCHAR2
       ,P_Calling_Sequence           IN    VARCHAR2
       ) RETURN BOOLEAN;



  FUNCTION Get_Base_Amount
       (P_amount              IN  NUMBER
       ,P_currency_code       IN  VARCHAR2
       ,P_base_currency_code  IN  VARCHAR2
       ,P_exchange_rate_type  IN  VARCHAR2
       ,P_exchange_rate_date  IN  DATE
       ,P_exchange_rate       IN  NUMBER
       ,P_calling_sequence    IN  VARCHAR2
       ) RETURN NUMBER;


END AP_ACCOUNTING_PAY_PKG;

/
