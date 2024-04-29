--------------------------------------------------------
--  DDL for Package ARP_PROCESS_RCTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_RCTS" AUTHID CURRENT_USER AS
/* $Header: ARRERGWS.pls 120.9.12010000.2 2009/02/02 16:44:19 mpsingh ship $ */

FUNCTION revision RETURN VARCHAR2;

PROCEDURE lock_cash_receipt(
  	p_cash_receipt_id	IN NUMBER,
	p_currency_code		IN VARCHAR2,
	p_amount		IN NUMBER,
	p_pay_from_customer	IN NUMBER,
	p_receipt_number	IN VARCHAR2,
	p_receipt_date		IN DATE,
	p_gl_date		IN DATE,
	p_maturity_date		IN DATE,
	p_comments		IN VARCHAR2,
	p_exchange_rate_type	IN VARCHAR2,
	p_exchange_rate		IN NUMBER,
	p_exchange_date		IN DATE,
	p_batch_id		IN NUMBER,
	p_attribute_category	IN VARCHAR2,
	p_attribute1		IN VARCHAR2,
	p_attribute2		IN VARCHAR2,
	p_attribute3		IN VARCHAR2,
	p_attribute4		IN VARCHAR2,
	p_attribute5		IN VARCHAR2,
	p_attribute6		IN VARCHAR2,
	p_attribute7		IN VARCHAR2,
	p_attribute8		IN VARCHAR2,
	p_attribute9		IN VARCHAR2,
	p_attribute10		IN VARCHAR2,
	p_attribute11		IN VARCHAR2,
	p_attribute12		IN VARCHAR2,
	p_attribute13		IN VARCHAR2,
	p_attribute14		IN VARCHAR2,
	p_attribute15		IN VARCHAR2,
	p_override_remit_account_flag IN VARCHAR2,
	p_remittance_bank_account_id  IN NUMBER,
	p_customer_bank_account_id    IN NUMBER,
	p_customer_site_use_id	      IN NUMBER,
	p_customer_receipt_reference  IN VARCHAR2,
	p_factor_discount_amount      IN NUMBER,
	p_deposit_date		      IN DATE,
	p_receipt_method_id	      IN NUMBER,
	p_doc_sequence_value	      IN NUMBER,
	p_doc_sequence_id	      IN NUMBER,
	p_ussgl_transaction_code      IN VARCHAR2,
        p_vat_tax_id		      IN NUMBER,
	p_anticipated_clearing_date   IN DATE,
	p_customer_bank_branch_id     IN NUMBER,
--
-- ******* Global Flexfield parameters *******
--
	p_global_attribute1		IN VARCHAR2,
	p_global_attribute2		IN VARCHAR2,
	p_global_attribute3		IN VARCHAR2,
	p_global_attribute4		IN VARCHAR2,
	p_global_attribute5		IN VARCHAR2,
	p_global_attribute6		IN VARCHAR2,
	p_global_attribute7		IN VARCHAR2,
	p_global_attribute8		IN VARCHAR2,
	p_global_attribute9		IN VARCHAR2,
	p_global_attribute10		IN VARCHAR2,
	p_global_attribute11		IN VARCHAR2,
	p_global_attribute12		IN VARCHAR2,
	p_global_attribute13		IN VARCHAR2,
	p_global_attribute14		IN VARCHAR2,
	p_global_attribute15		IN VARCHAR2,
	p_global_attribute16		IN VARCHAR2,
	p_global_attribute17		IN VARCHAR2,
	p_global_attribute18		IN VARCHAR2,
	p_global_attribute19		IN VARCHAR2,
	p_global_attribute20		IN VARCHAR2,
	p_global_attribute_category	IN VARCHAR2,
--
--  	Notes Receivable
--
        p_issuer_name			IN VARCHAR2,
	p_issue_date			IN DATE,
	p_issuer_bank_branch_id		IN NUMBER,
--
--      Enh: 2974220
        p_application_notes             IN VARCHAR2,
--
	p_form_name		        IN VARCHAR2,
	p_form_version		        IN VARCHAR2,
        p_payment_server_order_num      IN VARCHAR2,
        p_approval_code                 IN VARCHAR2,
        p_receipt_status                IN VARCHAR2,   /* Bug 2688648 */
        p_rec_version_number            IN NUMBER, /* Bug fix 3032059 */
        p_payment_trxn_extension_id     IN NUMBER, /* Bug fix 3032059 */
	p_automatch_set_id              IN NUMBER, /* ER Automatch Application */
	p_autoapply_flag                IN VARCHAR2
			);

PROCEDURE delete_cash_receipt(
	p_cash_receipt_id	IN NUMBER,
	p_batch_id		IN NUMBER);

Procedure post_query_logic(
   p_cr_id		IN	ar_cash_receipts.cash_receipt_id%TYPE,
   p_receipt_type	IN	VARCHAR2,
   p_reference_type	IN 	VARCHAR2,
   p_reference_id	IN	NUMBER,
   p_std_reversal_possible OUT NOCOPY  VARCHAR2,
   p_apps_exist_flag	OUT NOCOPY 	VARCHAR2,
   p_rec_moved_state_flag OUT NOCOPY	VARCHAR2,
   p_amount_applied	OUT NOCOPY	NUMBER,
   p_amount_unapplied   OUT NOCOPY     NUMBER,
   p_write_off_amount   OUT NOCOPY     NUMBER,
   p_cc_refund_amount   OUT NOCOPY     NUMBER,
   p_cc_chargeback_amount   OUT NOCOPY    NUMBER,
   p_chargeback_amount   OUT NOCOPY    NUMBER,
   p_amount_on_account  OUT NOCOPY     NUMBER,
   p_amount_in_claim    OUT NOCOPY     NUMBER,
   p_prepayment_amount  OUT NOCOPY     NUMBER,
   p_amount_unidentified OUT NOCOPY    NUMBER,
   p_discounts_earned    OUT NOCOPY    NUMBER,
   p_discounts_unearned  OUT NOCOPY    NUMBER,
   p_tot_exchange_gain_loss OUT NOCOPY NUMBER,
   p_statement_number    OUT NOCOPY    VARCHAR2,
   p_line_number	 OUT NOCOPY	VARCHAR2,
   p_statement_date	 OUT NOCOPY    DATE,
   p_reference_id_dsp	 OUT NOCOPY	VARCHAR2,
   p_cross_curr_apps_flag OUT NOCOPY	VARCHAR2,
   p_reversal_date          IN  DATE,
   p_reversal_gl_date       OUT NOCOPY DATE,
   p_debit_memo             OUT NOCOPY VARCHAR2,
   p_debit_memo_ccid        OUT NOCOPY NUMBER,
   p_debit_memo_type        OUT NOCOPY VARCHAR2,
   p_debit_memo_number      OUT NOCOPY VARCHAR2,
   p_debit_memo_doc_number  OUT NOCOPY NUMBER,
   p_confirm_date           OUT NOCOPY DATE,
   p_confirm_gl_date        OUT NOCOPY DATE
			);
PROCEDURE set_posted_flag( p_cash_receipt_id  IN number,
                           p_posted_flag   OUT NOCOPY BOOLEAN);

--Bug 5033971
PROCEDURE Delete_Transaction_Extension(

           --   *****  Standard API parameters *****
                p_api_version                   IN  NUMBER                      ,
                p_init_msg_list                 IN  VARCHAR2 := FND_API.G_TRUE  ,
                p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,
                x_return_status                 OUT NOCOPY VARCHAR2             ,
                x_msg_count                     OUT NOCOPY NUMBER               ,
                x_msg_data                      OUT NOCOPY VARCHAR2             ,

           --   *****  Receipt  Header information parameters *****
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_cust_Account_id               IN  NUMBER      DEFAULT NULL    ,
                p_account_site_use_id           IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  IBY_TRXN_EXTENSIONS_V.TRXN_EXTENSION_ID%TYPE    );

----------------- Private functions/procedures ------------------


END ARP_PROCESS_RCTS;

/
