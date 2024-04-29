--------------------------------------------------------
--  DDL for Package ARP_AUTOAPPLY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_AUTOAPPLY_API" AUTHID CURRENT_USER AS
/*$Header: ARATAPPS.pls 120.0.12010000.5 2009/05/06 03:55:42 aghoraka noship $*/
  /* Structure to hold a Record from the payments interface table */
  TYPE pmt_rec_record IS RECORD(
    customer_id ar_payments_interface.customer_id%TYPE,
    customer_site_use_id ar_payments_interface.customer_site_use_id%TYPE,
    customer_bank_account_id ar_payments_interface.customer_bank_account_id%TYPE,
    customer_number ar_payments_interface.customer_number%TYPE,
    transit_routing_number ar_payments_interface.transit_routing_number%TYPE,
    account ar_payments_interface.account%TYPE,
    invoice1 ar_payments_interface.invoice1%TYPE,
    matching1_date ar_payments_interface.matching1_date%TYPE,
    invoice1_installment ar_payments_interface.invoice1_installment%TYPE,
    resolved_matching_number1 ar_payments_interface.resolved_matching_number1%TYPE,
    amount_applied1 ar_payments_interface.amount_applied1%TYPE,
    amount_applied_from1 ar_payments_interface.amount_applied_from1%TYPE,
    resolved_matching1_installment ar_payments_interface.resolved_matching1_installment%TYPE,
    resolved_matching1_date ar_payments_interface.resolved_matching1_date%TYPE,
    trans_to_receipt_rate1 ar_payments_interface.trans_to_receipt_rate1%TYPE,
    invoice_currency_code1 ar_payments_interface.invoice_currency_code1%TYPE,
    ussgl_transaction_code1 ar_payments_interface.ussgl_transaction_code1%TYPE,
    invoice1_status ar_payments_interface.invoice1_status%TYPE,
    invoice2 ar_payments_interface.invoice2%TYPE,
    matching2_date ar_payments_interface.matching2_date%TYPE,
    invoice2_installment ar_payments_interface.invoice2_installment%TYPE,
    resolved_matching_number2 ar_payments_interface.resolved_matching_number2%TYPE,
    amount_applied2 ar_payments_interface.amount_applied2%TYPE,
    amount_applied_from2 ar_payments_interface.amount_applied_from2%TYPE,
    resolved_matching2_installment ar_payments_interface.resolved_matching2_installment%TYPE,
    resolved_matching2_date ar_payments_interface.resolved_matching2_date%TYPE,
    trans_to_receipt_rate2 ar_payments_interface.trans_to_receipt_rate2%TYPE,
    invoice_currency_code2 ar_payments_interface.invoice_currency_code2%TYPE,
    ussgl_transaction_code2 ar_payments_interface.ussgl_transaction_code2%TYPE,
    invoice2_status ar_payments_interface.invoice2_status%TYPE,
    invoice3 ar_payments_interface.invoice3%TYPE,
    matching3_date ar_payments_interface.matching3_date%TYPE,
    invoice3_installment ar_payments_interface.invoice3_installment%TYPE,
    resolved_matching_number3 ar_payments_interface.resolved_matching_number3%TYPE,
    amount_applied3 ar_payments_interface.amount_applied3%TYPE,
    amount_applied_from3 ar_payments_interface.amount_applied_from3%TYPE,
    resolved_matching3_installment ar_payments_interface.resolved_matching3_installment%TYPE,
    resolved_matching3_date ar_payments_interface.resolved_matching1_date%TYPE,
    trans_to_receipt_rate3 ar_payments_interface.trans_to_receipt_rate3%TYPE,
    invoice_currency_code3 ar_payments_interface.invoice_currency_code3%TYPE,
    ussgl_transaction_code3 ar_payments_interface.ussgl_transaction_code3%TYPE,
    invoice3_status ar_payments_interface.invoice3_status%TYPE,
    invoice4 ar_payments_interface.invoice4%TYPE,
    matching4_date ar_payments_interface.matching4_date%TYPE,
    invoice4_installment ar_payments_interface.invoice4_installment%TYPE,
    resolved_matching_number4 ar_payments_interface.resolved_matching_number4%TYPE,
    amount_applied4 ar_payments_interface.amount_applied4%TYPE,
    amount_applied_from4 ar_payments_interface.amount_applied_from4%TYPE,
    resolved_matching4_installment ar_payments_interface.resolved_matching4_installment%TYPE,
    resolved_matching4_date ar_payments_interface.resolved_matching4_date%TYPE,
    trans_to_receipt_rate4 ar_payments_interface.trans_to_receipt_rate4%TYPE,
    invoice_currency_code4 ar_payments_interface.invoice_currency_code4%TYPE,
    ussgl_transaction_code4 ar_payments_interface.ussgl_transaction_code4%TYPE,
    invoice4_status ar_payments_interface.invoice4_status%TYPE,
    invoice5 ar_payments_interface.invoice5%TYPE,
    matching5_date ar_payments_interface.matching5_date%TYPE,
    invoice5_installment ar_payments_interface.invoice5_installment%TYPE,
    resolved_matching_number5 ar_payments_interface.resolved_matching_number5%TYPE,
    amount_applied5 ar_payments_interface.amount_applied5%TYPE,
    amount_applied_from5 ar_payments_interface.amount_applied_from5%TYPE,
    resolved_matching5_installment ar_payments_interface.resolved_matching5_installment%TYPE,
    resolved_matching5_date ar_payments_interface.resolved_matching5_date%TYPE,
    trans_to_receipt_rate5 ar_payments_interface.trans_to_receipt_rate5%TYPE,
    invoice_currency_code5 ar_payments_interface.invoice_currency_code5%TYPE,
    ussgl_transaction_code5 ar_payments_interface.ussgl_transaction_code5%TYPE,
    invoice5_status ar_payments_interface.invoice5_status%TYPE,
    invoice6 ar_payments_interface.invoice6%TYPE,
    matching6_date ar_payments_interface.matching6_date%TYPE,
    invoice6_installment ar_payments_interface.invoice6_installment%TYPE,
    resolved_matching_number6 ar_payments_interface.resolved_matching_number6%TYPE,
    amount_applied6 ar_payments_interface.amount_applied6%TYPE,
    amount_applied_from6 ar_payments_interface.amount_applied_from6%TYPE,
    resolved_matching6_installment ar_payments_interface.resolved_matching6_installment%TYPE,
    resolved_matching6_date ar_payments_interface.resolved_matching6_date%TYPE,
    trans_to_receipt_rate6 ar_payments_interface.trans_to_receipt_rate6%TYPE,
    invoice_currency_code6 ar_payments_interface.invoice_currency_code6%TYPE,
    ussgl_transaction_code6 ar_payments_interface.ussgl_transaction_code6%TYPE,
    invoice6_status ar_payments_interface.invoice6_status%TYPE,
    invoice7 ar_payments_interface.invoice7%TYPE,
    matching7_date ar_payments_interface.matching7_date%TYPE,
    invoice7_installment ar_payments_interface.invoice7_installment%TYPE,
    resolved_matching_number7 ar_payments_interface.resolved_matching_number7%TYPE,
    amount_applied7 ar_payments_interface.amount_applied7%TYPE,
    amount_applied_from7 ar_payments_interface.amount_applied_from7%TYPE,
    resolved_matching7_installment ar_payments_interface.resolved_matching7_installment%TYPE,
    resolved_matching7_date ar_payments_interface.resolved_matching7_date%TYPE,
    trans_to_receipt_rate7 ar_payments_interface.trans_to_receipt_rate7%TYPE,
    invoice_currency_code7 ar_payments_interface.invoice_currency_code7%TYPE,
    ussgl_transaction_code7 ar_payments_interface.ussgl_transaction_code7%TYPE,
    invoice7_status ar_payments_interface.invoice7_status%TYPE,
    invoice8 ar_payments_interface.invoice8%TYPE,
    matching8_date ar_payments_interface.matching8_date%TYPE,
    invoice8_installment ar_payments_interface.invoice8_installment%TYPE,
    resolved_matching_number8 ar_payments_interface.resolved_matching_number8%TYPE,
    amount_applied8 ar_payments_interface.amount_applied8%TYPE,
    amount_applied_from8 ar_payments_interface.amount_applied_from8%TYPE,
    resolved_matching8_installment ar_payments_interface.resolved_matching8_installment%TYPE,
    resolved_matching8_date ar_payments_interface.resolved_matching8_date%TYPE,
    trans_to_receipt_rate8 ar_payments_interface.trans_to_receipt_rate8%TYPE,
    invoice_currency_code8 ar_payments_interface.invoice_currency_code8%TYPE,
    ussgl_transaction_code8 ar_payments_interface.ussgl_transaction_code8%TYPE,
    invoice8_status ar_payments_interface.invoice8_status%TYPE
  );
  TYPE pmt_rec_tab IS TABLE OF pmt_rec_record INDEX BY BINARY_INTEGER;

  TYPE selected_recos IS RECORD(
    remit_reference_id          AR_CASH_REMIT_REFS.remit_reference_id%TYPE,
    ref_amount_applied          AR_CASH_REMIT_REFS.amount_applied%TYPE,
    ref_amount_applied_from     AR_CASH_REMIT_REFS.amount_applied_from%TYPE,
    ref_trans_to_receipt_rate   AR_CASH_REMIT_REFS.trans_to_receipt_rate%TYPE,
    cash_receipt_id             AR_CASH_RECEIPTS.cash_receipt_id%TYPE,
    pay_from_customer           AR_CASH_RECEIPTS.pay_from_customer%TYPE,
    cr_customer_site_use_id     AR_CASH_RECEIPTS.customer_site_use_id%TYPE,
    customer_trx_id             AR_PAYMENT_SCHEDULES.customer_trx_id%TYPE,
    customer_id                 AR_PAYMENT_SCHEDULES.customer_id%TYPE,
    customer_site_use_id        AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE,
    resolved_matching_number    AR_PAYMENT_SCHEDULES.trx_number%TYPE,
    terms_sequence_number       AR_PAYMENT_SCHEDULES.terms_sequence_number%TYPE,
    resolved_matching_date      AR_PAYMENT_SCHEDULES.trx_date%TYPE,
    trx_date                    AR_PAYMENT_SCHEDULES.trx_date%TYPE,
    resolved_matching_class     AR_PAYMENT_SCHEDULES.class%TYPE,
    resolved_match_currency     AR_PAYMENT_SCHEDULES.invoice_currency_code%TYPE,
    amount_due_original         AR_PAYMENT_SCHEDULES.amount_due_original%TYPE,
    amount_due_remaining        AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
    discount_taken_earned       AR_PAYMENT_SCHEDULES.discount_taken_earned%TYPE,
    discount_taken_unearned     AR_PAYMENT_SCHEDULES.discount_taken_unearned%TYPE,
    amount_applied              AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
    trans_to_receipt_rate       AR_CASH_REMIT_REFS.trans_to_receipt_rate%TYPE,
    amount_applied_from         AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
    payment_schedule_id         AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE,
    cons_inv_id                 AR_CASH_RECOS.cons_inv_id%TYPE,
    match_score_value           AR_CASH_RECOS.match_score_value%TYPE,
    org_id                      AR_PAYMENT_SCHEDULES.org_id%TYPE,
    term_id                     AR_PAYMENT_SCHEDULES.term_id%TYPE,
    automatch_id                AR_CASH_AUTOMATCHES.automatch_id%TYPE,
    use_matching_date           AR_CASH_AUTOMATCHES.use_matching_date%TYPE,
    use_matching_amount         AR_CASH_AUTOMATCHES.use_matching_amount%TYPE,
    auto_match_threshold        AR_CASH_AUTOMATCHES.auto_match_threshold%TYPE,
    priority                    AR_CASH_RECOS.priority%TYPE,
    receipt_currency_code       AR_CASH_RECEIPTS.currency_code%TYPE,
    receipt_date                AR_CASH_RECEIPTS.receipt_date%TYPE,
    allow_overapplication_flag  RA_CUST_TRX_TYPES.allow_overapplication_flag%TYPE,
    partial_discount_flag       RA_TERMS.partial_discount_flag%TYPE,
    reco_num                    NUMBER
  );

  TYPE selected_recos_table IS TABLE OF selected_recos INDEX BY BINARY_INTEGER;

  TYPE reco_id_tab IS TABLE OF ar_cash_recos.recommendation_id%TYPE
                             INDEX BY BINARY_INTEGER;
  TYPE remit_ref_id_tab IS TABLE OF ar_cash_recos.remit_reference_id%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE customer_id_tab IS TABLE OF ar_cash_recos.pay_from_customer%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE customer_site_use_id_tab IS TABLE OF ar_cash_recos.customer_site_use_id%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE resolved_matching_number_tab IS TABLE OF ar_cash_recos.resolved_matching_number%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE resolved_matching_date_tab IS TABLE OF ar_cash_recos.resolved_matching_date%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE resolved_matching_class_tab IS TABLE OF ar_cash_recos.resolved_matching_class%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE resolved_match_currency_tab IS TABLE OF ar_cash_recos.resolved_match_currency%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE match_resolved_using_tab IS TABLE OF ar_cash_recos.match_resolved_using%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE cons_inv_id_tab IS TABLE OF ar_cash_recos.cons_inv_id%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE match_score_value_tab IS TABLE OF ar_cash_recos.match_score_value%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE match_reason_code_tab IS TABLE OF ar_cash_recos.match_reason_code%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE org_id_tab IS TABLE OF ar_cash_recos.org_id%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE automatch_id_tab IS TABLE OF ar_cash_recos.automatch_id%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE priority_tab IS TABLE OF ar_cash_recos.priority%TYPE
                               INDEX BY BINARY_INTEGER;


  TYPE reco_num_tab IS TABLE OF ar_cash_reco_lines.line_number%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE customer_trx_id_tab IS TABLE OF ar_cash_reco_lines.customer_trx_id%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE payment_schedule_id_tab IS TABLE OF ar_cash_reco_lines.payment_schedule_id%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE amount_applied_tab IS TABLE OF ar_cash_reco_lines.amount_applied%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE amount_applied_from_tab IS TABLE OF ar_cash_reco_lines.amount_applied_from%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE trans_to_receipt_rate_tab IS TABLE OF ar_cash_reco_lines.trans_to_receipt_rate%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE receipt_currency_code_tab IS TABLE OF ar_cash_reco_lines.receipt_currency_code%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE receipt_date_tab IS TABLE OF ar_cash_reco_lines.receipt_date%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE recommendation_reason_tab IS TABLE OF ar_cash_reco_lines.recommendation_reason%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE discount_taken_earned_tab IS TABLE OF ar_cash_reco_lines.discount_taken_earned%TYPE
                               INDEX BY BINARY_INTEGER;
  TYPE discount_taken_unearned_tab IS TABLE OF ar_cash_reco_lines.discount_taken_unearned%TYPE
                               INDEX BY BINARY_INTEGER;

  TYPE inv_num_tab IS TABLE OF ar_payments_interface.invoice1%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE mtch_date_tab IS TABLE OF ar_payments_interface.matching1_date%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE inst_num_tab IS TABLE OF ar_payments_interface.invoice1_installment%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE res_mtch_num_tab IS TABLE OF ar_payments_interface.resolved_matching_number1%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE amt_app_tab IS TABLE OF ar_payments_interface.amount_applied1%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE amt_app_frm_tab IS TABLE OF ar_payments_interface.amount_applied_from1%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE res_mtch_inst_tab IS TABLE OF ar_payments_interface.resolved_matching1_installment%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE res_mtch_date_tab IS TABLE OF ar_payments_interface.resolved_matching1_date%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE trns_to_rcpt_rt_tab IS TABLE OF ar_payments_interface.trans_to_receipt_rate1%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE inv_cur_code_tab IS TABLE OF ar_payments_interface.invoice_currency_code1%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE ussgl_trx_code_tab IS TABLE OF ar_payments_interface.ussgl_transaction_code1%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE inv_status_tab IS TABLE OF ar_payments_interface.invoice1_status%TYPE
                                          INDEX BY BINARY_INTEGER;
  TYPE line_num_tab IS TABLE OF ar_cash_remit_refs.line_number%TYPE
                                          INDEX BY BINARY_INTEGER;

  /* * This procedure is called from the concurrent request. This in turns *
     * spawns the child program if submitted with total_workers > 1.       * */
  PROCEDURE auto_apply_master ( P_ERRBUF              OUT NOCOPY VARCHAR2
                              , P_RETCODE             OUT NOCOPY NUMBER
                              , p_org_id                IN NUMBER
                              , p_receipt_no_l        IN VARCHAR2
                              , p_receipt_no_h        IN VARCHAR2
                              , p_batch_name_l        IN VARCHAR2
                              , p_batch_name_h        IN VARCHAR2
                              , p_min_unapp_amt       IN NUMBER
                              , p_receipt_date_l      IN VARCHAR2
                              , p_receipt_date_h      IN VARCHAR2
                              , p_receipt_method_l    IN VARCHAR2
                              , p_receipt_method_h    IN VARCHAR2
                              , p_customer_name_l     IN VARCHAR2
                              , p_customer_name_h     IN VARCHAR2
                              , p_customer_no_l       IN VARCHAR2
                              , p_customer_no_h       IN VARCHAR2
                              , p_batch_id            IN NUMBER
                              , p_transmission_id     IN NUMBER
                              , p_called_from         IN VARCHAR2
                              , p_total_workers       IN NUMBER);
  /* * This procedure makes a call to insert recommendations, validate and  *
     * apply recommendations.                                               * */
  PROCEDURE auto_apply_child( P_ERRBUF OUT NOCOPY VARCHAR2
                              , P_RETCODE OUT NOCOPY NUMBER
                              , p_worker_number IN NUMBER);
  /* * The procedure to delete records inserted in ar_cash_remit_ref_interim *
     * for the current run.                                                  * */
  PROCEDURE delete_interim_records;

  /* * This function returns a new sequence number                           * */
  FUNCTION get_next_reco_id( p_reco_num IN NUMBER)
  RETURN NUMBER;

  FUNCTION get_cross_curr_rate(p_amount_applied IN ar_cash_remit_refs.amount_applied%TYPE
                             , p_amount_applied_from IN ar_cash_remit_refs.amount_applied_from%TYPE
                             , p_inv_curr_code IN ar_payment_schedules.invoice_currency_code%TYPE
                             , p_rec_curr_code IN ar_cash_receipts.currency_code%TYPE)
  RETURN NUMBER;

END ARP_AUTOAPPLY_API;

/
