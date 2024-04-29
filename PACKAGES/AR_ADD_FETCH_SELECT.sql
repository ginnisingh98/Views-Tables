--------------------------------------------------------
--  DDL for Package AR_ADD_FETCH_SELECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ADD_FETCH_SELECT" AUTHID CURRENT_USER as
/* $Header: ARXRWAFS.pls 120.4 2005/10/30 03:59:51 appldev ship $ */

PROCEDURE on_select (
                    p_select_type          VARCHAR2
                   ,p_apply_date           DATE
                   ,p_receipt_gl_date      DATE
                   ,p_customer_id          NUMBER
                   ,p_bill_to_site_use_id  NUMBER
                   ,p_receipt_currency     VARCHAR2
                   ,p_cm_customer_trx_id   NUMBER
                   ,p_trx_type_name_find   VARCHAR2
                   ,p_due_date_find        VARCHAR2
                   ,p_trx_date_find        VARCHAR2
                   ,p_amt_due_rem_find     VARCHAR2
                   ,p_trx_number_find      VARCHAR2
                   ,p_include_disputed     VARCHAR2
                   ,p_include_cross_curr   VARCHAR2
                   ,p_inv_class            VARCHAR2
                   ,p_chb_class            VARCHAR2
                   ,p_cm_class             VARCHAR2
                   ,p_dm_class             VARCHAR2
                   ,p_dep_class            VARCHAR2
                   ,p_status               VARCHAR2
                   ,p_order_by             VARCHAR2
                   ,p_trx_bill_number_find VARCHAR2
                   ,p_purchase_order_find  VARCHAR2 default NULL
                   ,p_transaction_category_find VARCHAR2 default NULL
                   ,p_br_class             VARCHAR2 DEFAULT NULL/* 01-JUN-2000 J Rautiainen BR Implementation */
		   ,p_related_cust_flag    VARCHAR2
);

function on_fetch (
   p_select_type                  IN   VARCHAR2,
   row_id                         OUT NOCOPY  VARCHAR2,
   cash_receipt_id                OUT NOCOPY  NUMBER,
   customer_trx_id                OUT NOCOPY  NUMBER,
   cm_customer_trx_id             OUT NOCOPY  NUMBER,
   last_update_date               OUT NOCOPY  DATE,
   last_updated_by                OUT NOCOPY  NUMBER,
   creation_date                  OUT NOCOPY  DATE,
   created_by                     OUT NOCOPY  NUMBER,
   last_update_login              OUT NOCOPY  NUMBER,
   program_application_id         OUT NOCOPY  NUMBER,
   program_id                     OUT NOCOPY  NUMBER,
   program_update_date            OUT NOCOPY  DATE,
   request_id                     OUT NOCOPY  NUMBER,
   receipt_number                 OUT NOCOPY  VARCHAR2,
   applied_flag                   OUT NOCOPY  VARCHAR2,
   customer_id                    OUT NOCOPY  NUMBER,
   customer_name                  OUT NOCOPY  VARCHAR2,
   customer_number                OUT NOCOPY  VARCHAR2,
   trx_number                     OUT NOCOPY  VARCHAR2,
   installment                    OUT NOCOPY  NUMBER,
   amount_applied                 OUT NOCOPY  NUMBER,
   amount_applied_from            OUT NOCOPY  NUMBER,
   trans_to_receipt_rate	  OUT NOCOPY  NUMBER,
   discount                       OUT NOCOPY  NUMBER,
   discounts_earned               OUT NOCOPY  NUMBER,
   discounts_unearned             OUT NOCOPY  NUMBER,
   discount_taken_earned          OUT NOCOPY  NUMBER,
   discount_taken_unearned        OUT NOCOPY  NUMBER,
   amount_due_remaining           OUT NOCOPY  NUMBER,
   due_date                       OUT NOCOPY  DATE,
   status                         OUT NOCOPY  VARCHAR2,
   term_id                        OUT NOCOPY  NUMBER,
   trx_class_name                 OUT NOCOPY  VARCHAR2,
   trx_class_code                 OUT NOCOPY  VARCHAR2,
   trx_type_name                  OUT NOCOPY  VARCHAR2,
   cust_trx_type_id               OUT NOCOPY  NUMBER,
   trx_date                       OUT NOCOPY  DATE,
   location_name                  OUT NOCOPY  VARCHAR2,
   bill_to_site_use_id            OUT NOCOPY  NUMBER,
   days_late                      OUT NOCOPY  NUMBER,
   line_number                    OUT NOCOPY  NUMBER,
   customer_trx_line_id           OUT NOCOPY  NUMBER,
   apply_date                     OUT NOCOPY  DATE,
   gl_date                        OUT NOCOPY  DATE,
   gl_posted_date                 OUT NOCOPY  DATE,
   reversal_gl_date               OUT NOCOPY  DATE,
   exchange_rate                  OUT NOCOPY  NUMBER,
   invoice_currency_code          OUT NOCOPY  VARCHAR2,
   amount_due_original            OUT NOCOPY  NUMBER,
   amount_in_dispute              OUT NOCOPY  NUMBER,
   amount_line_items_original     OUT NOCOPY  NUMBER,
   acctd_amount_due_remaining     OUT NOCOPY  NUMBER,
   acctd_amount_applied_to        OUT NOCOPY  NUMBER,
   acctd_amount_applied_from      OUT NOCOPY  NUMBER,
   exchange_gain_loss             OUT NOCOPY  NUMBER,
   discount_remaining             OUT NOCOPY  NUMBER,
   calc_discount_on_lines_flag    OUT NOCOPY  VARCHAR2,
   partial_discount_flag          OUT NOCOPY  VARCHAR2,
   allow_overapplication_flag     OUT NOCOPY  VARCHAR2,
   natural_application_only_flag  OUT NOCOPY  VARCHAR2,
   creation_sign                  OUT NOCOPY  VARCHAR2,
   applied_payment_schedule_id    OUT NOCOPY  NUMBER,
   ussgl_transaction_code         OUT NOCOPY  VARCHAR2,
   ussgl_transaction_code_context OUT NOCOPY  VARCHAR2,
   purchase_order                 OUT NOCOPY  VARCHAR2,
   trx_doc_sequence_id            OUT NOCOPY  NUMBER,
   trx_doc_sequence_value         OUT NOCOPY  VARCHAR2,
   trx_batch_source_name          OUT NOCOPY  VARCHAR2,
   amount_adjusted                OUT NOCOPY  NUMBER,
   amount_adjusted_pending        OUT NOCOPY  NUMBER,
   amount_line_items_remaining    OUT NOCOPY  NUMBER,
   freight_original               OUT NOCOPY  NUMBER,
   freight_remaining              OUT NOCOPY  NUMBER,
   receivables_charges_remaining  OUT NOCOPY  NUMBER,
   tax_original                   OUT NOCOPY  NUMBER,
   tax_remaining                  OUT NOCOPY  NUMBER,
   selected_for_receipt_batch_id  OUT NOCOPY  NUMBER,
   receivable_application_id      OUT NOCOPY  NUMBER,
   attribute_category             OUT NOCOPY  VARCHAR2,
   attribute1                     OUT NOCOPY  VARCHAR2,
   attribute2                     OUT NOCOPY  VARCHAR2,
   attribute3                     OUT NOCOPY  VARCHAR2,
   attribute4                     OUT NOCOPY  VARCHAR2,
   attribute5                     OUT NOCOPY  VARCHAR2,
   attribute6                     OUT NOCOPY  VARCHAR2,
   attribute7                     OUT NOCOPY  VARCHAR2,
   attribute8                     OUT NOCOPY  VARCHAR2,
   attribute9                     OUT NOCOPY  VARCHAR2,
   attribute10                    OUT NOCOPY  VARCHAR2,
   attribute11                    OUT NOCOPY  VARCHAR2,
   attribute12                    OUT NOCOPY  VARCHAR2,
   attribute13                    OUT NOCOPY  VARCHAR2,
   attribute14                    OUT NOCOPY  VARCHAR2,
   attribute15                    OUT NOCOPY  VARCHAR2,
   trx_billing_number             OUT NOCOPY  VARCHAR2,
   global_attribute_category      OUT NOCOPY  VARCHAR2,
   global_attribute1              OUT NOCOPY  VARCHAR2,
   global_attribute2              OUT NOCOPY  VARCHAR2,
   global_attribute3              OUT NOCOPY  VARCHAR2,
   global_attribute4              OUT NOCOPY  VARCHAR2,
   global_attribute5              OUT NOCOPY  VARCHAR2,
   global_attribute6              OUT NOCOPY  VARCHAR2,
   global_attribute7              OUT NOCOPY  VARCHAR2,
   global_attribute8              OUT NOCOPY  VARCHAR2,
   global_attribute9              OUT NOCOPY  VARCHAR2,
   global_attribute10             OUT NOCOPY  VARCHAR2,
   global_attribute11             OUT NOCOPY  VARCHAR2,
   global_attribute12             OUT NOCOPY  VARCHAR2,
   global_attribute13             OUT NOCOPY  VARCHAR2,
   global_attribute14             OUT NOCOPY  VARCHAR2,
   global_attribute15             OUT NOCOPY  VARCHAR2,
   global_attribute16             OUT NOCOPY  VARCHAR2,
   global_attribute17             OUT NOCOPY  VARCHAR2,
   global_attribute18             OUT NOCOPY  VARCHAR2,
   global_attribute19             OUT NOCOPY  VARCHAR2,
   global_attribute20             OUT NOCOPY  VARCHAR2,
--   purchase_order                 OUT NOCOPY  VARCHAR2,
   transaction_category           OUT NOCOPY  VARCHAR2,
   trx_gl_date                    OUT NOCOPY  DATE,
   comments                    OUT NOCOPY VARCHAR2, --- bug 2662270
   receivables_trx_id		  OUT NOCOPY NUMBER,
   rec_activity_name		  OUT NOCOPY VARCHAR,
   application_ref_id		  OUT NOCOPY NUMBER,
   application_ref_num		  OUT NOCOPY VARCHAR2,
   application_ref_type		  OUT NOCOPY VARCHAR2,
   application_ref_type_meaning   OUT NOCOPY VARCHAR2
					  ) return BOOLEAN;
end ar_add_fetch_select;

 

/
