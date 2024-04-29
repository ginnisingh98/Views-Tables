--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_LIBRARY_1_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzrl1s.pls 120.9 2006/11/21 18:57:21 appradha ship $ */


PROCEDURE get_customer_trx_id (pay_sched_id IN     NUMBER,
                               cust_trx_id  IN OUT NOCOPY NUMBER,
                               trans_date   IN OUT NOCOPY DATE,
                               row_number   IN     NUMBER,
                               Errcd        IN OUT NOCOPY NUMBER);

PROCEDURE get_amt_within_approval_limits (userid       IN     NUMBER,
                                          amt          IN     NUMBER,
                                          approved_amt IN OUT NOCOPY VARCHAR2,
                                          row_number   IN     NUMBER,
                                          Errcd IN OUT NOCOPY NUMBER);

  PROCEDURE get_bank_account_amounts (rcpt_mthd          IN NUMBER,
                                      bnk_acct           IN NUMBER,
                                      perc_tol           IN OUT NOCOPY NUMBER,
                                      amt_tol            IN OUT NOCOPY NUMBER,
                                      writeoff_rectrx    IN OUT NOCOPY NUMBER,
                                      writeoff_ccid      IN OUT NOCOPY NUMBER,
                                      rev_rectrx         IN OUT NOCOPY NUMBER,
                                      rev_ccid           IN OUT NOCOPY NUMBER,
					        calc_intr_ccid     IN OUT NOCOPY NUMBER,
                                      calc_intr_rectx_id IN OUT NOCOPY NUMBER,
                                      row_number         IN     NUMBER,
                                      Errcd              IN OUT NOCOPY NUMBER);

  PROCEDURE get_sum_adjustment_amounts (pay_sched_id    IN     NUMBER,
                                        amount_adjusted IN OUT NOCOPY NUMBER,
                                        row_number      IN     NUMBER,
                                        Errcd           IN OUT NOCOPY NUMBER);

  PROCEDURE get_idm_profiles_from_syspa (trx_type       IN OUT NOCOPY VARCHAR2,
                                         batch_source   IN OUT NOCOPY VARCHAR2,
                                         receipt_method IN OUT NOCOPY VARCHAR2,
                                         row_number     IN     NUMBER,
                                         Errcd          IN OUT NOCOPY NUMBER);

  PROCEDURE get_interest_payment_date (pay_schd_id           IN    NUMBER,
                                       interest_payment_date IN OUT NOCOPY VARCHAR2,
                                       row_number            IN     NUMBER,
                                       Errcd                 IN OUT NOCOPY NUMBER);

  PROCEDURE get_customer_interest_dtls (cust_trx_id          IN     NUMBER,
                                        interest_type        IN OUT NOCOPY VARCHAR2,
                                        interest_rate_amount IN OUT NOCOPY NUMBER,
                                        interest_period      IN OUT NOCOPY NUMBER,
                                        interest_formula     IN OUT NOCOPY VARCHAR2,
                                        interest_grace_days  IN OUT NOCOPY NUMBER,
                                        penalty_type         IN OUT NOCOPY VARCHAR2,
                                        penalty_rate_amount  IN OUT NOCOPY NUMBER,
                                        row_number           IN     NUMBER,
                                        Errcd                IN OUT NOCOPY NUMBER);

  PROCEDURE get_city_from_ra_addresses (pay_sched_id IN     NUMBER,
                                        city         IN OUT NOCOPY VARCHAR2,
                                        row_number   IN     NUMBER,
                                        Errcd        IN OUT NOCOPY NUMBER);

  PROCEDURE get_total_receipts (cash_rcpt_id IN     NUMBER,
                                tot_rec      IN OUT NOCOPY NUMBER,
                                row_number   IN     NUMBER,
                                Errcd        IN OUT NOCOPY NUMBER);

  PROCEDURE get_status_amount_due (amt_due_remain_char IN     VARCHAR2,
                                   status              IN OUT NOCOPY VARCHAR2,
                                   row_number          IN     NUMBER,
                                   Errcd               IN OUT NOCOPY NUMBER);

  PROCEDURE get_gl_date_closed (amt_due_remain_char IN     VARCHAR2,
                                gl_date             IN     VARCHAR2,
                                gl_date_closed      IN OUT NOCOPY VARCHAR2,
                                row_number          IN     NUMBER,
                                Errcd               IN OUT NOCOPY NUMBER);

  PROCEDURE get_actual_date_closed (amt_due_remain_char IN     VARCHAR2,
                                    gl_date             IN     VARCHAR2,
                                    actual_date_closed  IN OUT NOCOPY VARCHAR2,
                                    row_number          IN     NUMBER,
                                    Errcd               IN OUT NOCOPY NUMBER);

  PROCEDURE get_count_of_receipt_methods (rcpt_class_id IN     NUMBER,
                                          total_rec     IN OUT NOCOPY NUMBER,
                                          row_number    IN     NUMBER,
                                          Errcd         IN OUT NOCOPY NUMBER);

  PROCEDURE get_collection_method (rcpt_class_id     IN     NUMBER,
                                   collection_method IN OUT NOCOPY NUMBER,
                                   row_number        IN     NUMBER,
                                   Errcd             IN OUT NOCOPY NUMBER);

  PROCEDURE get_print_immediately_flag (print_immediately_flag IN OUT NOCOPY VARCHAR2,
                                        row_number             IN     NUMBER,
                                        Errcd                  IN OUT NOCOPY NUMBER);

  PROCEDURE get_count_complete_flag (total_records IN OUT NOCOPY NUMBER,
                                     row_number    IN     NUMBER,
                                     Errcd         IN OUT NOCOPY NUMBER);

  PROCEDURE get_cust_trx_type_status (p_cust_trx_type_id IN     NUMBER,
                                      class            IN OUT NOCOPY VARCHAR2,
                                      dfstatus         IN OUT NOCOPY VARCHAR2,
                                      row_number       IN     NUMBER,
                                      Errcd            IN OUT NOCOPY NUMBER);

 PROCEDURE update_doc_status(p_cash_receipt_id IN NUMBER);
  -- Bug 3610797
  PROCEDURE get_inv_item_details (fcc_code_type IN VARCHAR2,
                                  tran_nat_type IN     VARCHAR2,
                                  so_org_id     IN     VARCHAR2,
                                  inv_item_id   IN     NUMBER,
                                  fcc_code      IN OUT NOCOPY VARCHAR2,
                                  tran_nat      IN OUT NOCOPY VARCHAR2,
                                  item_org      IN OUT NOCOPY VARCHAR2,
                                  item_ft       IN OUT NOCOPY VARCHAR2,
                                  fed_trib      IN OUT NOCOPY VARCHAR2,
                                  sta_trib      IN OUT NOCOPY VARCHAR2,
                                  row_number    IN     NUMBER,
                                  Errcd         IN OUT NOCOPY NUMBER);

  PROCEDURE get_memo_line_details (p_memo_line_id IN     NUMBER,
                                   item_org     IN OUT NOCOPY VARCHAR2,
                                   item_ft      IN OUT NOCOPY VARCHAR2,
                                   fed_trib     IN OUT NOCOPY VARCHAR2,
                                   sta_trib     IN OUT NOCOPY VARCHAR2,
                                   row_number   IN     NUMBER,
                                   Errcd        IN OUT NOCOPY NUMBER);

  PROCEDURE get_next_seq_number (seq_name   IN     VARCHAR2,
                                 seq_no     IN OUT NOCOPY NUMBER,
                                 row_number IN     NUMBER,
                                 Errcd      IN OUT NOCOPY NUMBER);

  PROCEDURE get_bearer_of_trade_note (pay_sched_id   IN     NUMBER,
                                      bearer_tr_note IN OUT NOCOPY VARCHAR2,
                                      row_number     IN     NUMBER,
                                      Errcd          IN OUT NOCOPY NUMBER);

  PROCEDURE get_customer_profile_dtls (bill_to_cust_id   IN     NUMBER,
                                       interest_type     IN OUT NOCOPY VARCHAR2,
                                       interest_rate_amt IN OUT NOCOPY VARCHAR2,
                                       interest_period   IN OUT NOCOPY VARCHAR2,
                                       interest_formula  IN OUT NOCOPY VARCHAR2,
                                       interest_grace    IN OUT NOCOPY VARCHAR2,
                                       penalty_type      IN OUT NOCOPY VARCHAR2,
                                       penalty_rate_amt  IN OUT NOCOPY VARCHAR2,
                                       row_number        IN     NUMBER,
                                       Errcd             IN OUT NOCOPY NUMBER);

  PROCEDURE get_batch_id (p_batch_source_id IN     NUMBER,
                          batch_id          IN OUT NOCOPY NUMBER,
                          row_number        IN     NUMBER,
                          Errcd             IN OUT NOCOPY NUMBER);

  PROCEDURE get_tax_base_rate_amt (cust_trx_id IN     NUMBER,
                                   base_amt    IN OUT NOCOPY NUMBER,
                                   base_rate   IN OUT NOCOPY NUMBER,
                                   row_number  IN     NUMBER,
                                   Errcd       IN OUT NOCOPY NUMBER);

  PROCEDURE get_issue_date (cust_trx_id IN     NUMBER,
                            iss_date    IN OUT NOCOPY DATE,
                            row_number  IN     NUMBER,
                            Errcd       IN OUT NOCOPY NUMBER);

  PROCEDURE get_customer_trx_dtls (cust_trx_id IN     NUMBER,
                                   status      IN OUT NOCOPY VARCHAR2,
                                   typ_class   IN OUT NOCOPY VARCHAR2,
                                   row_number  IN     NUMBER,
                                   Errcd       IN OUT NOCOPY NUMBER);

  PROCEDURE get_class      (p_trx_number IN     VARCHAR2,
                            p_class      IN OUT NOCOPY VARCHAR2,
                            row_number   IN     NUMBER,
                            Errcd        IN OUT NOCOPY NUMBER);

  PROCEDURE get_prev_interest_values(p_applied_payment_schedule_id IN NUMBER,
                                     p_cash_receipt_id IN NUMBER,
                                     p_apply_date IN DATE,
                                     p_main_amnt_rec OUT NOCOPY VARCHAR2,
                                     p_base_int_calc OUT NOCOPY VARCHAR2,
                                     p_calculated_interest OUT NOCOPY VARCHAR2,
                                     p_received_interest OUT NOCOPY VARCHAR2,
                                     p_int_diff_action OUT NOCOPY VARCHAR2,
                                     p_int_writeoff_reason OUT NOCOPY VARCHAR2,
                                     p_payment_date OUT NOCOPY VARCHAR2,
                                     p_writeoff_date OUT NOCOPY VARCHAR2,
                                     Errcd IN OUT NOCOPY NUMBER);

  PROCEDURE get_interest_reversal_flag(p_cash_receipt_id IN NUMBER,
                                       p_interest_reversal OUT NOCOPY BOOLEAN,
                                       Errcd IN OUT NOCOPY NUMBER);

  PROCEDURE get_adjustment_record(p_adj_rec      IN OUT NOCOPY ar_adjustments%ROWTYPE,
                                  p_user_id         IN NUMBER,
                                  p_amount          IN NUMBER,
                                  p_receipt_date    IN DATE,
                                  p_cash_receipt_id IN NUMBER,
                                  p_customer_trx_id IN NUMBER,
                                  p_pay_sched_id    IN NUMBER,
                                  p_rectrx_id       IN NUMBER,
                                  p_status          IN VARCHAR2,
                                  Errcd          IN OUT NOCOPY NUMBER);

 PROCEDURE get_warehouse_info(p_customer_trx_id IN NUMBER,
                              p_warehouse_count OUT NOCOPY NUMBER);

 PROCEDURE get_warehouse_id(p_customer_trx_id IN NUMBER,
                            p_warehouse_id OUT NOCOPY NUMBER);

 PROCEDURE get_void_trx_type_id(p_country_code IN VARCHAR2,
                                p_void_trx_type_id OUT NOCOPY NUMBER,
                                Errcd          IN OUT NOCOPY NUMBER);

 PROCEDURE get_city_from_ra_addresses (pay_sched_id IN     NUMBER,
                                       city         IN OUT NOCOPY VARCHAR2,
                                       row_number   IN     NUMBER,
                                       Errcd        IN OUT NOCOPY NUMBER,
                                       state        IN OUT NOCOPY VARCHAR2);

 PROCEDURE get_dbms_sql_native (x_dbms_sql_native OUT NOCOPY INTEGER); --Bugs 2952004 / 2939830

END JL_ZZ_AR_LIBRARY_1_PKG;

 

/
