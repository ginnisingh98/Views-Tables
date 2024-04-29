--------------------------------------------------------
--  DDL for Package ARP_CALCULATE_DISCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CALCULATE_DISCOUNT" AUTHID CURRENT_USER AS
/* $Header: ARRUDISS.pls 120.3 2006/07/26 07:29:44 naneja ship $ */
--
-- CONSTANTS
--
        AR_NO_TERM           CONSTANT       NUMBER := 0;
        AR_DIRECT_DISC       CONSTANT       NUMBER := 0;
        AR_DEFAULT_DISC      CONSTANT       NUMBER := 1;
        AR_DIRECT_NEW_DISC   CONSTANT       NUMBER := 2;
        AR_DEFAULT_NEW_DISC  CONSTANT       NUMBER := 3;
        AR_EARNED_INDICATOR  CONSTANT       CHAR := 'E';
        AR_BOTH_INDICATOR    CONSTANT       CHAR := 'B';
        FIELD_LENGTH         CONSTANT       NUMBER := 30;
        --AR_M_FAILURE         CONSTANT       NUMBER := 0;
        --AR_M_NO_RECORD       CONSTANT       NUMBER := 4;
        --AR_M_SUCCESS         CONSTANT       NUMBER := 1;
--
--  AR/TA Changes
--  Global variables included as part of TA customization for enhanced
--  discount Calculation
--
      g_error_buf             VARCHAR2(2000) ;
      g_called_from           VARCHAR2(20) ;
      g_profile_id            NUMBER ;
      g_discount_basis        VARCHAR2(1);
      g_discount_date_basis   VARCHAR2(30) ;
      g_discount_date_value   DATE ;
      g_grace_days_used       NUMBER(15) ;
      g_full_discount_flag    VARCHAR2(1) ;
      g_max_allowed_discount  NUMBER ;
      g_discount_percentage   NUMBER ;
      g_org_seg_val           VARCHAR2(30) ;
      g_cust_seg_val          VARCHAR2(30) ;
      g_lob_seg_val           VARCHAR2(30) ;
      g_flex_seg_val          VARCHAR2(30) ;
      g_flex_comments         ra_cust_trx_line_gl_dist_all.comments%TYPE;
      g_rec_account_id        ra_cust_trx_line_gl_dist.code_combination_id%TYPE;
      g_batch_name            VARCHAR2(25) ;
      g_transmission_request_id NUMBER ;

--
   TYPE discount_record_type IS RECORD
  (
    input_amt                           NUMBER,
    grace_days                          NUMBER,
    apply_date                          DATE,
    disc_partial_pmt_flag               VARCHAR2(2),
    calc_disc_on_lines                  VARCHAR2(2),
    earned_both_flag                    VARCHAR2(2),
    earned_disc_pct                     NUMBER,
    best_disc_pct                       NUMBER,
    adjusted_ado                        NUMBER,
    max_disc                            NUMBER,
    out_earned_disc                     NUMBER,
    out_unearned_disc                   NUMBER,
    out_amt_to_apply                    NUMBER,
    out_discount_date                   DATE,
    use_max_cash_flag                   VARCHAR2(2),
    default_amt_app                     VARCHAR2(241),
    close_invoice_flag                  VARCHAR2(2)
   );
--

PROCEDURE get_discount_percentages(
	  p_disc_rec IN OUT NOCOPY arp_calculate_discount.discount_record_type,
	  p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE
);

PROCEDURE get_payment_schedule_info(
	  p_disc_rec IN OUT NOCOPY arp_calculate_discount.discount_record_type,
	  p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE
);

PROCEDURE correct_lines_only_discounts(
	p_disc_rec IN OUT NOCOPY arp_calculate_discount.discount_record_type,
	p_ps_rec IN ar_payment_schedules%ROWTYPE );

PROCEDURE determine_max_allowed_disc(
	p_mode IN number,
	p_disc_rec IN OUT NOCOPY arp_calculate_discount.discount_record_type,
	p_ps_rec IN ar_payment_schedules%ROWTYPE );

/*FP bug 5335376 for Bug 5223829 introduced new parameters for handling iReceivables case*/
PROCEDURE calculate_discounts (
        p_input_amt         IN NUMBER,
        p_grace_days         IN NUMBER,
        p_apply_date         IN DATE,
        p_disc_partial_pmt_flag IN VARCHAR2,
        p_calc_disc_on_lines IN VARCHAR2,
        p_earned_both_flag IN VARCHAR2,
        p_use_max_cash_flag IN VARCHAR2,
        p_default_amt_app IN VARCHAR2,
        p_earned_disc_pct IN OUT NOCOPY NUMBER,
        p_best_disc_pct IN OUT NOCOPY NUMBER,
        p_out_earned_disc IN OUT NOCOPY NUMBER,
        p_out_unearned_disc IN OUT NOCOPY NUMBER,
        p_out_discount_date IN OUT NOCOPY DATE,
        p_out_amt_to_apply IN OUT NOCOPY NUMBER,
        p_close_invoice_flag IN VARCHAR2,
        p_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_term_id IN ar_payment_schedules.term_id%TYPE,
        p_terms_sequence_number IN ar_payment_schedules.terms_sequence_number%TYPE,
        p_trx_date IN ar_payment_schedules.trx_date%TYPE,
        p_amt_due_original IN ar_payment_schedules.amount_due_original%TYPE,
        p_amt_due_remaining IN ar_payment_schedules.amount_due_remaining%TYPE,
        p_disc_earned IN ar_payment_schedules.discount_taken_earned%TYPE,
        p_disc_unearned IN ar_payment_schedules.discount_taken_unearned%TYPE,
        p_lines_original IN ar_payment_schedules.amount_line_items_original%TYPE,
        p_invoice_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
        p_select_flag IN VARCHAR2,
        p_mode IN NUMBER,
        p_error_code IN OUT NOCOPY NUMBER,
        p_cash_receipt_id IN NUMBER,
        p_called_from IN VARCHAR2 DEFAULT 'AR',
        p_amt_in_dispute IN ar_payment_schedules.amount_in_dispute%TYPE DEFAULT NULL);
--

--  Bug 627518:  original routine will now call the overloaded function which
--               will take cash_receipt_id as an additional argument for CPG


PROCEDURE discounts_cover(
     p_mode          IN VARCHAR2,
     p_invoice_currency_code IN ar_cash_receipts.currency_code%TYPE,
     p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
     p_term_id IN ra_terms.term_id%TYPE,
     p_terms_sequence_number IN ar_payment_schedules.terms_sequence_number%TYPE,
     p_trx_date IN ar_payment_schedules.trx_date%TYPE,
     p_apply_date IN ar_cash_receipts.receipt_date%TYPE,
     p_grace_days IN NUMBER,
     p_default_amt_apply_flag  IN VARCHAR2,
     p_partial_discount_flag IN VARCHAR2,
     p_calc_discount_on_lines_flag IN VARCHAR2,
     p_allow_overapp_flag IN VARCHAR2,
     p_close_invoice_flag IN VARCHAR2,
     p_earned_disc_pct IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_best_disc_pct IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_input_amount   IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_due_original IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_due_remaining IN ar_payment_schedules.amount_due_remaining%TYPE,
     p_discount_taken_earned IN ar_payment_schedules.amount_due_original%TYPE,
     p_discount_taken_unearned IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_line_items_original IN ar_payment_schedules.amount_line_items_original%TYPE,
     p_out_discount_date    IN OUT NOCOPY DATE,
     p_out_earned_discount IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_out_unearned_discount IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_out_amount_to_apply  IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_out_discount_to_take  IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_module_name  IN VARCHAR2,
     p_module_version IN VARCHAR2,
     p_allow_discount IN VARCHAR2 DEFAULT 'Y' ); /* Bug fix 3450317 */
--
PROCEDURE discounts_cover(
     p_mode          IN VARCHAR2,
     p_invoice_currency_code IN ar_cash_receipts.currency_code%TYPE,
     p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
     p_term_id IN ra_terms.term_id%TYPE,
     p_terms_sequence_number IN ar_payment_schedules.terms_sequence_number%TYPE,
     p_trx_date IN ar_payment_schedules.trx_date%TYPE,
     p_apply_date IN ar_cash_receipts.receipt_date%TYPE,
     p_grace_days IN NUMBER,
     p_default_amt_apply_flag  IN VARCHAR2,
     p_partial_discount_flag IN VARCHAR2,
     p_calc_discount_on_lines_flag IN VARCHAR2,
     p_allow_overapp_flag IN VARCHAR2,
     p_close_invoice_flag IN VARCHAR2,
     p_earned_disc_pct IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_best_disc_pct IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_input_amount   IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_due_original IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_due_remaining IN ar_payment_schedules.amount_due_remaining%TYPE,
     p_discount_taken_earned IN ar_payment_schedules.amount_due_original%TYPE,
     p_discount_taken_unearned IN ar_payment_schedules.amount_due_original%TYPE,
     p_amount_line_items_original IN ar_payment_schedules.amount_line_items_original%TYPE,
     p_out_discount_date    IN OUT NOCOPY DATE,
     p_out_earned_discount IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_out_unearned_discount IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_out_amount_to_apply  IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_out_discount_to_take  IN OUT NOCOPY ar_payment_schedules.amount_due_original%TYPE,
     p_module_name  IN VARCHAR2,
     p_module_version IN VARCHAR2,
     p_cash_receipt_id IN NUMBER,
     p_allow_discount IN VARCHAR2 DEFAULT 'Y' ); /* Bug fix 3450317 */

/* AR/TA Changes : added this procedure to initialize the value of
   the package variable  g_called_from */

PROCEDURE set_g_called_from(p_called_from IN varchar2);

        ar_m_fail         EXCEPTION;
        ar_m_no_rec       EXCEPTION;
END ARP_CALCULATE_DISCOUNT;

 

/
