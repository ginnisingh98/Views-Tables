--------------------------------------------------------
--  DDL for Package IBY_AR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_AR_UTILS" AUTHID CURRENT_USER AS
/* $Header: ibyaruts.pls 120.3.12010000.5 2009/09/05 10:59:04 sgogula ship $ */


 -- Sales tax type
 G_TAX_TYPE_SALES CONSTANT VARCHAR2(30) := 'SALESTAX';
 -- VAT tax type
 G_TAX_TYPE_VAT CONSTANT VARCHAR2(30) := 'VAT';

 --
 -- This FUNCTION is obsolete in R12.
 -- The overloaded "extension-based" function is used instead.
 --
 -- Return: The document receivable for the given transaction
 -- Notes: Function is used to "short-circuit" joins to the documents
 --   receivable XML extract view so that transactions which do not
 --   need this sub-element (e.g. online authorizations) do not suffer
 --   unacceptable performance costs
 --
 FUNCTION get_document_receivable
 (p_tangibleid      IN iby_trxn_summaries_all.tangibleid%TYPE,
  p_trxntypeid      IN iby_trxn_summaries_all.trxntypeid%TYPE,
  p_card_data_level IN iby_trxn_core.card_data_level%TYPE,
  p_instrument_type IN iby_trxn_summaries_all.instrtype%TYPE
 )
 RETURN XMLType;

 --
 -- Overloaded form of the earlier API. This is transaction extension
 -- driven. This function would be used in R12. the previous one has
 -- been obsoleted.
 --
 -- Return: The document receivable for the given transaction
 -- Notes: Function is used to "short-circuit" joins to the documents
 --   receivable XML extract view so that transactions which do not
 --   need this sub-element (e.g. online authorizations) do not suffer
 --   unacceptable performance costs
 --
 FUNCTION get_document_receivable
 (p_extension_id    IN iby_trxn_summaries_all.initiator_extension_id%TYPE,
  p_trxntypeid      IN iby_trxn_summaries_all.trxntypeid%TYPE,
  p_card_data_level IN iby_trxn_core.card_data_level%TYPE,
  p_instrument_type IN iby_trxn_summaries_all.instrtype%TYPE,
  p_source_view     IN VARCHAR2
 )
 RETURN XMLType;

 --
 -- Overloaded form of the earlier API.This restricts the Invoice details
 -- based on the instrument type. The earlier function has been kept
 --  for backward compatibility.
 -- NOTE
 --   For performance reasons this function returns a concatenation
 --   of DocumentReceivable and DocumentReceivableCount
 --
 -- Bug # 8713025
 -- Added input parameter p_process_profile : process profile code of the transaction.
 --
 FUNCTION get_document_receivable
 (
 p_extension_id    IN iby_trxn_summaries_all.initiator_extension_id%TYPE,
 p_trxntypeid      IN iby_trxn_summaries_all.trxntypeid%TYPE,
 p_card_data_level IN iby_trxn_core.card_data_level%TYPE,
 p_instrument_type IN iby_trxn_summaries_all.instrtype%TYPE,
 p_process_profile IN iby_trxn_summaries_all.process_profile_code%TYPE,
 p_source_view     IN VARCHAR2
 )
 RETURN XMLType;


 -- Return: The Authorization Flag for the given Transaction Extension Id
 PROCEDURE get_authorization_status
 (p_trxn_extension_id  IN iby_fndcpt_tx_operations.trxn_extension_id%TYPE,
 x_auth_flag   OUT NOCOPY VARCHAR2);

 PROCEDURE call_get_payment_info(
               p_payment_server_order_num IN
                              ar_cash_receipts.payment_server_order_num%TYPE,
               x_customer_trx_id OUT
                              ar_receivable_applications.customer_trx_id%TYPE,
               x_return_status   OUT NOCOPY VARCHAR2,
               x_msg_count       OUT NOCOPY NUMBER,
               x_msg_data        OUT NOCOPY VARCHAR2
               );

 --
 -- Return: The customer trx id for the given order if, or NULL if none
 --         is found
 -- Notes: Inline function wrapper of the above procedure
 --
 FUNCTION call_get_payment_info
 (p_payment_server_order_num IN
   ar_cash_receipts.payment_server_order_num%TYPE)
 RETURN ar_receivable_applications.customer_trx_id%TYPE;

 --
 -- Return: The order-level (total) freight amount
 --
 FUNCTION get_order_freight_amount(p_customer_trx_id IN
   ar_invoice_header_v.customer_trx_id%TYPE)
 RETURN NUMBER;

 --
 -- Args:   p_tax_type => The tax type; use one of the enumerated
 --                       tax type constants from this package
 -- Return: The order-level (total) tax amount
 --
 FUNCTION get_order_tax_amount
  (p_customer_trx_id IN ar_invoice_header_v.customer_trx_id%TYPE,
   p_tax_type        IN VARCHAR2)
 RETURN NUMBER;

 FUNCTION get_order_amount
  (p_customer_trx_id IN ar_invoice_header_v.customer_trx_id%TYPE)
 RETURN NUMBER;

 FUNCTION get_line_tax_amount
  (p_customer_trx_id IN ar_invoice_header_v.customer_trx_id%TYPE,
   p_customer_trx_line_id IN ar_invoice_lines_v.customer_trx_line_id%TYPE,
   p_tax_type             IN VARCHAR2)
 RETURN NUMBER;

 FUNCTION get_line_tax_rate
  (p_customer_trx_id IN ar_invoice_header_v.customer_trx_id%TYPE,
   p_customer_trx_line_id IN ar_invoice_lines_v.customer_trx_line_id%TYPE,
   p_tax_type             IN VARCHAR2)
 RETURN NUMBER;

END IBY_AR_UTILS;

/
