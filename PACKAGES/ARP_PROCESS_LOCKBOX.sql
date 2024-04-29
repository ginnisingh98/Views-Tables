--------------------------------------------------------
--  DDL for Package ARP_PROCESS_LOCKBOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_LOCKBOX" AUTHID CURRENT_USER AS
/*$Header: ARRPRLBS.pls 120.6.12010000.4 2009/12/08 05:53:31 amitshuk ship $ */
--
PROCEDURE auto_associate(
                          p_transmission_id IN VARCHAR2,
                          p_payment_rec_type IN VARCHAR2,
                          p_overflow_rec_type IN VARCHAR2,
                          p_item_num IN ar_payments_interface.item_number%type,
                          p_batch_name IN ar_payments_interface.batch_name%type,
                          p_lockbox_number IN ar_payments_interface.lockbox_number%type,
                          p_batches IN VARCHAR2,
                          p_only_one_lb IN VARCHAR2,
                          p_use_matching_date IN ar_lockboxes.use_matching_date%type,
                          p_lockbox_matching_option IN ar_lockboxes.lockbox_matching_option%type,
                          p_pay_unrelated_invoices IN VARCHAR2,
                          p_out_customer_id OUT NOCOPY NUMBER,
                          p_out_customer_identified OUT NOCOPY NUMBER
                          );
--
PROCEDURE populate_resolved_columns(
                          p_transmission_id IN VARCHAR2,
                          p_payment_rec_type IN VARCHAR2,
                          p_overflow_rec_type IN VARCHAR2,
                          p_item_num IN ar_payments_interface.item_number%type,
                          p_batch_name IN ar_payments_interface.batch_name%type,
                          p_lockbox_number IN ar_payments_interface.lockbox_number%type,
                          p_batches IN VARCHAR2,
                          p_only_one_lb IN VARCHAR2,
                          p_use_matching_date IN ar_lockboxes.use_matching_date%type,
                          p_lockbox_matching_option IN ar_lockboxes.lockbox_matching_option%type,
                          p_pay_unrelated_invoices IN VARCHAR2
                          );
--
PROCEDURE
  find_cust_and_trx_num(
      p_transmission_id         IN VARCHAR2,
      p_payment_rec_type        IN VARCHAR2,
      p_overflow_rec_type       IN VARCHAR2,
      p_item_num                IN ar_payments_interface.item_number%type,
      p_batch_name              IN ar_payments_interface.batch_name%type,
      p_lockbox_number          IN ar_payments_interface.lockbox_number%type,
	  p_receipt_date            IN ar_payments_interface.receipt_date%type,
      p_batches                 IN VARCHAR2,
      p_only_one_lb             IN VARCHAR2,
      p_use_matching_date       IN ar_lockboxes.use_matching_date%type,
      p_lockbox_matching_option IN ar_lockboxes.lockbox_matching_option%type,
      p_pay_unrelated_invoices  IN VARCHAR2,
      p_matching_number1        IN OUT NOCOPY ar_payments_interface.invoice1%type,
      p_matching1_date          IN OUT NOCOPY ar_payments_interface.matching1_date%type,
      p_matching1_installment   IN OUT NOCOPY ar_payments_interface.invoice1_installment%type,
      p_matching_number2        IN OUT NOCOPY ar_payments_interface.invoice2%type,
      p_matching2_date          IN OUT NOCOPY ar_payments_interface.matching2_date%type,
      p_matching2_installment   IN OUT NOCOPY ar_payments_interface.invoice2_installment%type,
      p_matching_number3        IN OUT NOCOPY ar_payments_interface.invoice3%type,
      p_matching3_date          IN OUT NOCOPY ar_payments_interface.matching3_date%type,
      p_matching3_installment   IN OUT NOCOPY ar_payments_interface.invoice3_installment%type,
      p_matching_number4        IN OUT NOCOPY ar_payments_interface.invoice4%type,
      p_matching4_date          IN OUT NOCOPY ar_payments_interface.matching4_date%type,
      p_matching4_installment   IN OUT NOCOPY ar_payments_interface.invoice4_installment%type,
      p_matching_number5        IN OUT NOCOPY ar_payments_interface.invoice5%type,
      p_matching5_date          IN OUT NOCOPY ar_payments_interface.matching5_date%type,
      p_matching5_installment   IN OUT NOCOPY ar_payments_interface.invoice5_installment%type,
      p_matching_number6        IN OUT NOCOPY ar_payments_interface.invoice6%type,
      p_matching6_date          IN OUT NOCOPY ar_payments_interface.matching6_date%type,
      p_matching6_installment   IN OUT NOCOPY ar_payments_interface.invoice6_installment%type,
      p_matching_number7        IN OUT NOCOPY ar_payments_interface.invoice7%type,
      p_matching7_date          IN OUT NOCOPY ar_payments_interface.matching7_date%type,
      p_matching7_installment   IN OUT NOCOPY ar_payments_interface.invoice7_installment%type,
      p_matching_number8        IN OUT NOCOPY ar_payments_interface.invoice8%type,
      p_matching8_date          IN OUT NOCOPY ar_payments_interface.matching8_date%type,
      p_matching8_installment   IN OUT NOCOPY ar_payments_interface.invoice8_installment%type,
      p_matched_flag            OUT NOCOPY VARCHAR2,
      p_customer_id             IN OUT NOCOPY NUMBER,
      p_matching_option         IN OUT NOCOPY ar_lookups.lookup_code%type,
      p_match1_status           OUT NOCOPY ar_payments_interface.invoice1_status%type,
      p_match2_status           OUT NOCOPY ar_payments_interface.invoice2_status%type,
      p_match3_status           OUT NOCOPY ar_payments_interface.invoice3_status%type,
      p_match4_status           OUT NOCOPY ar_payments_interface.invoice4_status%type,
      p_match5_status           OUT NOCOPY ar_payments_interface.invoice5_status%type,
      p_match6_status           OUT NOCOPY ar_payments_interface.invoice6_status%type,
      p_match7_status           OUT NOCOPY ar_payments_interface.invoice7_status%type,
      p_match8_status           OUT NOCOPY ar_payments_interface.invoice8_status%type
    );
--
PROCEDURE
  get_cursor_name(
      p_matching_option         IN      ar_lookups.lookup_code%type,
      p_cursor_name             OUT NOCOPY     INTEGER,
      p_match_successful        OUT NOCOPY     BOOLEAN
    );
--
PROCEDURE
  validate_llca_interface_data(
	p_trans_request_id   IN   varchar2,
	p_allow_invalid_trx_num IN varchar2,
	p_format_amount IN varchar2,
	p_return_status OUT NOCOPY varchar2
);
--
PROCEDURE
  insert_interim_line_details(
	p_customer_trx_id IN  ra_customer_trx.customer_trx_id%type,
	p_cash_receipt_id IN  ar_cash_receipts.cash_receipt_id%type,
	p_cash_receipt_line_id IN  NUMBER,
	p_trans_req_id    IN  ar_payments_interface.transmission_request_id%type,
        p_batch_name      IN  ar_payments_interface.batch_name%type,
        p_item_num        IN  ar_payments_interface.item_number%type,
	p_return_status   OUT NOCOPY varchar2
);
--
PROCEDURE
  close_cursors;
--
PROCEDURE
  debug1(str IN VARCHAR2);
--
FUNCTION get_format_amount(
	p_trans_req_id IN NUMBER,
        p_trans_rec_id IN NUMBER,
        p_column_type  IN varchar2
)
RETURN VARCHAR2;
--
END arp_process_lockbox;

/
