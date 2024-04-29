--------------------------------------------------------
--  DDL for Package AR_CC_LOCKBOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CC_LOCKBOX" AUTHID CURRENT_USER AS
/* $Header: ARCCLOCS.pls 115.3 2002/11/15 02:04:42 anukumar ship $ */
--
--
PROCEDURE calc_cross_rate (
      p_amount_applied IN ar_payments_interface.amount_applied1%TYPE,
      p_amount_applied_from IN ar_payments_interface.amount_applied_from1%TYPE,
      p_inv_curr_code IN ar_payments_interface.invoice_currency_code1%TYPE,
      p_rec_curr_code IN ar_payments_interface.currency_code%TYPE,
      p_cross_rate OUT NOCOPY NUMBER
          );

PROCEDURE populate_add_inv_details(
       p_transmission_id IN VARCHAR2,
       p_payment_rec_type IN VARCHAR2,
       p_overflow_rec_type IN VARCHAR2,
       p_item_num IN ar_payments_interface.item_number%type,
       p_batch_name IN ar_payments_interface.batch_name%type,
       p_lockbox_number IN ar_payments_interface.lockbox_number%type,
       p_batches IN VARCHAR2,
       p_only_one_lb IN VARCHAR2,
       p_pay_unrelated_invoices IN VARCHAR2,
       p_default_exchange_rate_type IN VARCHAR2,
       enable_cross_currency IN VARCHAR2,
       p_format_amount1  IN VARCHAR,
       p_format_amount2  IN VARCHAR,
       p_format_amount3  IN VARCHAR,
       p_format_amount4  IN VARCHAR,
       p_format_amount5  IN VARCHAR,
       p_format_amount6  IN VARCHAR,
       p_format_amount7  IN VARCHAR,
       p_format_amount8  IN VARCHAR,
       p_format_amount_applied_from1  IN VARCHAR,
       p_format_amount_applied_from2  IN VARCHAR,
       p_format_amount_applied_from3  IN VARCHAR,
       p_format_amount_applied_from4  IN VARCHAR,
       p_format_amount_applied_from5  IN VARCHAR,
       p_format_amount_applied_from6  IN VARCHAR,
       p_format_amount_applied_from7  IN VARCHAR,
       p_format_amount_applied_from8  IN VARCHAR
        );
--
PROCEDURE calc_amt_applied_from (
  p_currency_code IN VARCHAR2,
  p_amount_applied IN ar_payments_interface.amount_applied1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied_from OUT NOCOPY ar_payments_interface.amount_applied_from1%type
        );
--
PROCEDURE calc_amt_applied(
  p_invoice_currency_code IN VARCHAR2,
  p_amount_applied_from IN ar_payments_interface.amount_applied_from1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied OUT NOCOPY ar_payments_interface.amount_applied1%type
                           );
--
PROCEDURE
  debug1(str IN VARCHAR2);

--
PROCEDURE
  pop_temp_columns;
--
PROCEDURE
  restore_orig_values;
--
PROCEDURE are_values_valid (
   p_invoice_currency_code IN VARCHAR2,
   p_amount_applied_from IN ar_payments_interface.amount_applied_from1%type,
   p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
   p_amount_applied IN ar_payments_interface.amount_applied1%type,
   p_currency_code IN VARCHAR2,
   valid OUT NOCOPY VARCHAR2 );

END AR_CC_LOCKBOX;

 

/
