--------------------------------------------------------
--  DDL for Package AR_PMT_PROCESS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_PMT_PROCESS_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: ARIPAYWS.pls 115.2 2004/06/15 18:58:14 jypandey noship $ */


/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

 /*--------------------------------------------------------------------------
  | This is the record to capture the generic information related to a receipt.
  | This can be useful for any customizations on this API.
  |-------------------------------------------------------------------------*/
  TYPE receipt_info_rec IS RECORD (
  cash_receipt_id          ar_cash_receipts.cash_receipt_id%TYPE,
  cr_amount                ar_cash_receipt_history.amount%TYPE,
  cr_acctd_amount          ar_cash_receipt_history.acctd_amount%TYPE,
  cust_bank_account_id     ar_cash_receipts.customer_bank_account_id%TYPE,
  cash_receipt_history_id  ar_cash_receipt_history.cash_receipt_history_id%TYPE,
  pay_from_customer        ar_cash_receipts.pay_from_customer%TYPE,
  site_use_id              ar_cash_receipts.customer_site_use_id%TYPE);

 /*--------------------------------------------------------------------------
  | This record contains all the parameters that are required to by iPayments
  | Authorize API IBY_Payment_Adapter_pub.OraPmtReq.
  |-------------------------------------------------------------------------*/
  TYPE authorize_input_rec IS RECORD (
  customer_bank_branch_id ap_bank_accounts.bank_branch_id%TYPE,
  merchant_ref            ar_receipt_methods.merchant_ref%TYPE,
  cus_bank_act_name       ap_bank_accounts.bank_account_name%TYPE,
  cus_bank_act_num        ap_bank_accounts.bank_account_num%TYPE,
  cus_bank_exp_date       ap_bank_accounts.inactive_date%TYPE,
  payment_server_order_num  ar_cash_receipts.payment_server_order_num%TYPE,
  receipt_amount          ar_cash_receipts.amount%TYPE,
  receipt_number          ar_cash_receipts.receipt_number%TYPE,
  currency_code           ar_cash_receipts.currency_code%TYPE,
  payment_mode            VARCHAR2(30) DEFAULT 'ONLINE' ,
  auth_TYPE               VARCHAR2(80)  DEFAULT 'AUTHONLY',
  unique_reference        ar_cash_receipts.unique_reference%type
 );

 /*--------------------------------------------------------------------------
  | This record contains the output record returned by iPayments
  |  Authorize API IBY_Payment_Adapter_pub.OraPmtReq.
  |-------------------------------------------------------------------------*/
  TYPE  authorize_output_rec IS RECORD (
  x_reqresp_rec    IBY_Payment_Adapter_pub.ReqResp_rec_type);

 /*--------------------------------------------------------------------------
  | This record contains all the parameters that are required to by iPayments
  |  Capture API IBY_Payment_Adapter_pub.OraPmtCapture.
  |-------------------------------------------------------------------------*/
  TYPE  capture_input_rec IS RECORD (
  payment_server_order_num  ar_cash_receipts.payment_server_order_num%TYPE,
  receipt_amount            ar_cash_receipts.amount%TYPE,
  currency_code             ar_cash_receipts.currency_code%TYPE,
  TrxnRef                   ar_cash_receipts.unique_reference%TYPE
  );

 /*--------------------------------------------------------------------------
  | This record contains the output record returned by iPayments
  | Capture API IBY_Payment_Adapter_pub.OraPmtCapture.
  |-------------------------------------------------------------------------*/
  TYPE  capture_output_rec IS RECORD (
  x_capresp_rec    IBY_Payment_Adapter_pub.CaptureResp_rec_type);

 /*========================================================================
 | PUBLIC PROCEDURE Authorize_Payment
 |
 | DESCRIPTION
 |      This procedure makes a  call to iPayment's API for Authorization
 |      IBY_Payment_Adapter_pub.OraPmtReq.
 |
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_receipt_info_rec IN
 |         This parameter is for capturing certain receipt related information
 |         that could be useful in customizations.
 |
 |      p_authorize_input_rec      IN
 |         This parameter is for capturing all the information that is required
 |         to send to iPayment for Authorizations.
 |
 |      x_authorize_output_rec     OUT
 |         This is the output record and comprises of the output record
 |         returned by iPayment API IBY_Payment_Adapter_pub.ReqResp_rec_type
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-MAR-2004           Jyoti Pandey      Created
 |
 *=======================================================================*/

   PROCEDURE Authorize_Payment (
   p_receipt_info_rec IN receipt_info_rec,
   p_authorize_input_rec IN authorize_input_rec,
   x_authorize_output_rec OUT NOCOPY authorize_output_rec,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2) ;



 /*========================================================================
 | PUBLIC PROCEDURE Capture_Payment
 |
 | DESCRIPTION
 |      This procedure makes a  call to iPayment's API for Capture
 |      IBY_Payment_Adapter_pub.OraPmtCapture
 |
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_receipt_info_rec IN
 |         This parameter is for capturing certain receipt related information
 |         that could be useful in customizations.
 |
 |      p_capture_input_rec      IN
 |         This parameter is for capturing all the information that is required
 |         to send to iPayment for Capture.
 |
 |      x_capture_output_rec     OUT
 |        This is the output record and comprises of the output record
 |        returned by iPayment API IBY_Payment_Adapter_pub.CaptureResp_rec_type
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 15-MAR-2004           Jyoti Pandey      Created
 |
 *=======================================================================*/

   PROCEDURE Capture_payment (
   p_receipt_info_rec IN receipt_info_rec,
   p_capture_input_rec        IN capture_input_rec,
   x_capture_output_rec       OUT NOCOPY capture_output_rec,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2);



END AR_PMT_PROCESS_WRAPPER;


 

/
