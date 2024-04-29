--------------------------------------------------------
--  DDL for Package JL_AR_RECEIVABLE_APPLICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_RECEIVABLE_APPLICATIONS" AUTHID CURRENT_USER as
/* $Header: jlbrrras.pls 120.7 2005/10/30 02:05:13 appldev ship $ */


/*----------------------------------------------------------------------------*
 |   PRIVATE FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

  PROCEDURE adjustment_generation ( x_user_id IN NUMBER,
                                    x_rectrx_id IN NUMBER,
	                            x_acc_id IN NUMBER,
                            	    x_amount IN NUMBER,
	                            x_receipt_date IN DATE,
	                            x_payment_schedule_id IN NUMBER,
	                            x_cash_receipt_id IN NUMBER,
	                            x_customer_trx_id IN NUMBER);

  PROCEDURE get_accounts (x_rcpt_method_id IN NUMBER,
                          x_bank_acct_id IN NUMBER,
                          x_writeoff_tolerance IN OUT NOCOPY NUMBER,
                          x_writeoff_amount IN OUT NOCOPY NUMBER,
                          x_writeoff_ccid IN OUT NOCOPY NUMBER,
                          x_writeoff_rectrx_id IN OUT NOCOPY NUMBER,
                          x_calc_interest_ccid IN OUT NOCOPY NUMBER,
                          x_calc_interest_rectrx_id IN OUT NOCOPY NUMBER,
                          x_int_revenue_ccid IN OUT NOCOPY NUMBER,
                          x_int_revenue_rectrx_id IN OUT NOCOPY NUMBER,
                          x_return IN OUT NOCOPY NUMBER);

  PROCEDURE get_ps_parameters(x_payment_schedule_id IN NUMBER,
                              x_amount_due_original IN OUT NOCOPY NUMBER,
                              x_amount_due_remaining IN OUT NOCOPY NUMBER,
                              x_return IN OUT NOCOPY NUMBER);

  PROCEDURE calc_greaterthan_rec( x_writeoff_tolerance IN NUMBER,
                                  x_writeoff_amount IN NUMBER,
                                  x_calculated_interest IN NUMBER,
                                  x_received_interest IN NUMBER,
                                  x_payment_amount IN NUMBER,
                                  x_rcpt_date IN DATE,
                                  x_invoice_amount IN NUMBER,
                                  x_payment_schedule_id IN NUMBER,
                                  x_writeoff_ccid IN NUMBER,
                                  x_writeoff_rectrx_id IN NUMBER,
                                  x_calc_interest_ccid IN NUMBER,
                                  x_calc_interest_rectrx_id IN NUMBER,
                                  x_cash_receipt_id IN NUMBER,
                                  x_trx_type_idm IN NUMBER,
                                  x_batch_source_idm IN NUMBER,
                                  x_receipt_method_idm IN NUMBER,
                                  x_user_id IN NUMBER,
                                  x_customer_trx_id IN NUMBER,
                                  x_interest_difference_action IN VARCHAR2,
                                  x_writeoff_date OUT NOCOPY VARCHAR2,
                                  x_int_revenue_ccid IN NUMBER);

 PROCEDURE calc_greaterthan_rec_tol( x_writeoff_tolerance IN NUMBER,
                                     x_writeoff_amount IN NUMBER,
                                     x_calculated_interest IN NUMBER,
                                     x_received_interest IN NUMBER,
                                     x_payment_amount IN NUMBER,
                                     x_rcpt_date IN DATE,
                                     x_invoice_amount IN NUMBER,
                                     x_payment_schedule_id IN NUMBER,
                                     x_writeoff_ccid IN NUMBER,
                                     x_writeoff_rectrx_id IN NUMBER,
                                     x_calc_interest_ccid IN NUMBER,
                                     x_calc_interest_rectrx_id IN NUMBER,
                                     x_cash_receipt_id IN NUMBER,
                                     x_trx_type_idm IN NUMBER,
                                     x_batch_source_idm IN NUMBER,
                                     x_receipt_method_idm IN NUMBER,
                                     x_user_id IN NUMBER,
                                     x_customer_trx_id IN NUMBER,
                                     x_writeoff_date OUT NOCOPY VARCHAR2,
                                     x_int_revenue_ccid IN NUMBER);

  PROCEDURE calc_lessthan_rec( x_writeoff_tolerance IN NUMBER,
                               x_writeoff_amount IN NUMBER,
                               x_calculated_interest IN NUMBER,
                               x_received_interest IN NUMBER,
                               x_payment_amount IN NUMBER,
                               x_rcpt_date IN DATE,
                               x_payment_schedule_id IN NUMBER,
                               x_int_revenue_ccid IN NUMBER,
                               x_int_revenue_rectrx_id IN NUMBER,
                               x_calc_interest_ccid IN NUMBER,
                               x_calc_interest_rectrx_id IN NUMBER,
                               x_cash_receipt_id IN NUMBER,
                               x_user_id IN NUMBER,
                               x_customer_trx_id IN NUMBER);

  PROCEDURE calc_equal_rec( x_writeoff_tolerance IN NUMBER,
                            x_writeoff_amount IN NUMBER,
                            x_calculated_interest IN NUMBER,
                            x_received_interest IN NUMBER,
                            x_payment_amount IN NUMBER,
                            x_rcpt_date IN DATE,
                            x_payment_schedule_id IN NUMBER,
                            x_int_revenue_ccid IN NUMBER,
                            x_int_revenue_rectrx_id IN NUMBER,
                            x_calc_interest_ccid IN NUMBER,
                            x_calc_interest_rectrx_id IN NUMBER,
                            x_cash_receipt_id IN NUMBER,
                            x_user_id IN NUMBER,
                            x_customer_trx_id IN NUMBER);

  PROCEDURE interest_treatment (
        x_payment_schedule_id IN NUMBER,
	x_customer_trx_id IN NUMBER,
	x_payment_amount  IN NUMBER,
	x_due_date IN DATE,
	x_calc_interest IN VARCHAR2,
	x_rec_interest IN VARCHAR2,
        x_main_amount_received IN VARCHAR2,
        x_base_interest_calc IN VARCHAR2,
        x_interest_payment_date IN VARCHAR2,
        x_interest_diff_action VARCHAR2,
        x_cash_receipt_id IN NUMBER,
	x_rcpt_date IN DATE,
	x_rcpt_method_id IN NUMBER,
        x_trx_type_idm IN NUMBER,
        x_batch_source_idm IN NUMBER,
        x_receipt_method_idm IN NUMBER,
	x_user_id IN NUMBER,
	x_remit_bank_acct_id IN NUMBER,
        x_writeoff_date OUT NOCOPY VARCHAR2);

  PROCEDURE Apply_br(p_apply_before_after          IN     VARCHAR2 ,
                     p_global_attribute_category   IN     VARCHAR2 ,
                     p_set_of_books_id             IN     NUMBER   ,
                     p_cash_receipt_id             IN     VARCHAR2 ,
                     p_receipt_date                IN     DATE     ,
                     p_applied_payment_schedule_id IN     NUMBER   ,
                     p_amount_applied              IN     NUMBER   ,
                     p_unapplied_amount            IN     NUMBER   ,
                     p_due_date                    IN     DATE     ,
                     p_receipt_method_id           IN     NUMBER   ,
                     p_remittance_bank_account_id  IN     NUMBER   ,
                     p_global_attribute1           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute2           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute3           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute4           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute5           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute6           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute7           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute8           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute9           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute10          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute11          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute12          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute13          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute14          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute15          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute16          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute17          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute18          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute19          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute20          IN OUT NOCOPY VARCHAR2 ,
                     p_return_status               OUT NOCOPY    VARCHAR2);

  PROCEDURE Unapply_br(
                       p_cash_receipt_id             IN     VARCHAR2 ,
                       p_applied_payment_schedule_id IN     NUMBER   ,
                       p_return_status               OUT NOCOPY    VARCHAR2);

  PROCEDURE Reverse_br(
                       p_cash_receipt_id             IN     NUMBER,
                       p_return_status               OUT NOCOPY    VARCHAR2);

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

PROCEDURE   Apply(p_apply_before_after          IN     VARCHAR2 ,
                  p_global_attribute_category   IN     VARCHAR2 ,
                  p_set_of_books_id             IN     NUMBER   ,
                  p_cash_receipt_id             IN     VARCHAR2 ,
                  p_receipt_date                IN     DATE     ,
                  p_applied_payment_schedule_id IN     NUMBER   ,
                  p_amount_applied              IN     NUMBER   ,
                  p_unapplied_amount            IN     NUMBER   ,
                  p_due_date                    IN     DATE     ,
                  p_receipt_method_id           IN     NUMBER   ,
                  p_remittance_bank_account_id  IN     NUMBER   ,
                  p_global_attribute1           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute2           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute3           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute4           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute5           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute6           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute7           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute8           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute9           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute10          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute11          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute12          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute13          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute14          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute15          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute16          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute17          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute18          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute19          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute20          IN OUT NOCOPY VARCHAR2 ,
                  p_return_status               OUT NOCOPY    VARCHAR2);

PROCEDURE Unapply(
                  p_cash_receipt_id             IN     VARCHAR2 ,
                  p_applied_payment_schedule_id IN     NUMBER   ,
                  p_return_status               OUT NOCOPY    VARCHAR2);

PROCEDURE Reverse(
                  p_cash_receipt_id             IN     NUMBER,
                  p_return_status               OUT NOCOPY    VARCHAR2);


PROCEDURE  create_interest_adjustment(
                   p_post_quickcash_req_id IN NUMBER,
                   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE delete_interest_adjustment(
                   p_cash_receipt_id IN NUMBER,
                   x_return_status OUT NOCOPY VARCHAR2);

END JL_AR_RECEIVABLE_APPLICATIONS;

 

/
