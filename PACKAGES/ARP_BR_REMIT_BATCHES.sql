--------------------------------------------------------
--  DDL for Package ARP_BR_REMIT_BATCHES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BR_REMIT_BATCHES" AUTHID CURRENT_USER AS
/* $Header: ARBRRM1S.pls 120.2.12010000.2 2009/12/16 12:48:05 pbapna ship $*/

PROCEDURE insert_remit(
	p_batch_date			IN	AR_BATCHES.batch_date%TYPE,
	p_gl_date			IN	AR_BATCHES.gl_date%TYPE,
	p_currency_code			IN	AR_BATCHES.currency_code%TYPE,
	p_comments			IN	AR_BATCHES.comments%TYPE,
	p_attribute_category		IN	AR_BATCHES.attribute_category%TYPE,
	p_attribute1			IN	AR_BATCHES.attribute1%TYPE,
	p_attribute2			IN	AR_BATCHES.attribute2%TYPE,
	p_attribute3			IN	AR_BATCHES.attribute3%TYPE,
	p_attribute4			IN	AR_BATCHES.attribute4%TYPE,
	p_attribute5			IN	AR_BATCHES.attribute5%TYPE,
	p_attribute6			IN	AR_BATCHES.attribute6%TYPE,
	p_attribute7			IN	AR_BATCHES.attribute7%TYPE,
	p_attribute8			IN	AR_BATCHES.attribute8%TYPE,
	p_attribute9			IN	AR_BATCHES.attribute9%TYPE,
	p_attribute10			IN	AR_BATCHES.attribute10%TYPE,
	p_media_reference		IN	AR_BATCHES.media_reference%TYPE,
	p_receipt_method_id		IN	AR_BATCHES.receipt_method_id%TYPE,
	p_remittance_bank_account_id	IN	AR_BATCHES.remit_bank_acct_use_id%TYPE,
	p_receipt_class_id		IN	AR_BATCHES.receipt_class_id%TYPE,
	p_remittance_bank_branch_id	IN	AR_BATCHES.remittance_bank_branch_id%TYPE,
	p_remit_method_code		IN	AR_BATCHES.remit_method_code%TYPE,
	p_with_recourse_flag		IN	AR_BATCHES.with_recourse_flag%TYPE,
	p_bank_deposit_number		IN	AR_BATCHES.bank_deposit_number%TYPE,
	p_auto_print_program_id		IN	AR_BATCHES.auto_print_program_id%TYPE,
	p_auto_trans_program_id		IN	AR_BATCHES.auto_trans_program_id%TYPE,
	p_batch_id			OUT NOCOPY	AR_BATCHES.batch_id%TYPE,
	p_batch_name			OUT NOCOPY	AR_BATCHES.name%TYPE,
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE);


PROCEDURE update_remit(
	p_api_version      		IN  NUMBER			,
        p_init_msg_list    		IN  VARCHAR2 := FND_API.G_FALSE	,
        p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
        p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status    		OUT NOCOPY VARCHAR2			,
        x_msg_count        		OUT NOCOPY NUMBER			,
        x_msg_data         		OUT NOCOPY VARCHAR2			,
	p_batch_id			IN AR_BATCHES.batch_id%TYPE,
        p_status			IN AR_BATCHES.status%TYPE,
        p_control_count			IN AR_BATCHES.control_count%TYPE,
        p_control_amount		IN AR_BATCHES.control_amount%TYPE,
	p_batch_applied_status		IN AR_BATCHES.batch_applied_status%TYPE,
	p_comments			IN AR_BATCHES.comments%TYPE,
        p_media_reference		IN AR_BATCHES.media_reference%TYPE,
        p_operation_request_id		IN AR_BATCHES.operation_request_id%TYPE,
        p_remittance_bank_account_id	IN AR_BATCHES.remit_bank_acct_use_id%TYPE,
        p_remittance_bank_branch_id	IN AR_BATCHES.remittance_bank_branch_id%TYPE,
        p_bank_deposit_number		IN AR_BATCHES.bank_deposit_number%TYPE,
        p_auto_print_program_id		IN AR_BATCHES.auto_print_program_id%TYPE,
        p_auto_trans_program_id		IN AR_BATCHES.auto_trans_program_id%TYPE);

PROCEDURE lock_remit (
        p_api_version      		IN 	NUMBER			,
        p_init_msg_list    		IN 	VARCHAR2 := FND_API.G_FALSE	,
        p_commit           		IN 	VARCHAR2 := FND_API.G_FALSE	,
        p_validation_level 		IN 	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status    		OUT NOCOPY	VARCHAR2			,
        x_msg_count        		OUT NOCOPY 	NUMBER			,
        x_msg_data         		OUT NOCOPY 	VARCHAR2			,
	p_rowid				IN	varchar2,
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
	p_batch_name			IN	AR_BATCHES.name%TYPE,
        p_status			IN 	AR_BATCHES.status%TYPE,
	p_batch_date			IN	AR_BATCHES.batch_date%TYPE,
	p_gl_date			IN	AR_BATCHES.gl_date%TYPE,
	p_currency_code			IN	AR_BATCHES.currency_code%TYPE,
	p_comments			IN	AR_BATCHES.comments%TYPE,
	p_attribute_category		IN	AR_BATCHES.attribute_category%TYPE,
	p_attribute1			IN	AR_BATCHES.attribute1%TYPE,
	p_attribute2			IN	AR_BATCHES.attribute2%TYPE,
	p_attribute3			IN	AR_BATCHES.attribute3%TYPE,
	p_attribute4			IN	AR_BATCHES.attribute4%TYPE,
	p_attribute5			IN	AR_BATCHES.attribute5%TYPE,
	p_attribute6			IN	AR_BATCHES.attribute6%TYPE,
	p_attribute7			IN	AR_BATCHES.attribute7%TYPE,
	p_attribute8			IN	AR_BATCHES.attribute8%TYPE,
	p_attribute9			IN	AR_BATCHES.attribute9%TYPE,
	p_attribute10			IN	AR_BATCHES.attribute10%TYPE,
	p_media_reference		IN	AR_BATCHES.media_reference%TYPE,
	p_receipt_method_id		IN	AR_BATCHES.receipt_method_id%TYPE,
	p_remittance_bank_account_id	IN	AR_BATCHES.remit_bank_acct_use_id%TYPE,
	p_receipt_class_id		IN	AR_BATCHES.receipt_class_id%TYPE,
	p_remittance_bank_branch_id	IN	AR_BATCHES.remittance_bank_branch_id%TYPE,
	p_remit_method_code		IN	AR_BATCHES.remit_method_code%TYPE,
	p_with_recourse_flag		IN	AR_BATCHES.with_recourse_flag%TYPE,
	p_bank_deposit_number		IN	AR_BATCHES.bank_deposit_number%TYPE,
	p_auto_print_program_id		IN	AR_BATCHES.auto_print_program_id%TYPE,
	p_auto_trans_program_id		IN	AR_BATCHES.auto_trans_program_id%TYPE,
	p_batch_applied_status		IN	AR_BATCHES.batch_applied_status%TYPE);

PROCEDURE cancel_remit(
	p_batch_id			IN 	AR_BATCHES.batch_id%TYPE,
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE);

PROCEDURE update_br_remit_batch_to_crh(p_cr_id    IN  ar_cash_receipts.cash_receipt_id%TYPE,
                                       p_batch_id IN  ar_cash_receipt_history.batch_id%TYPE);



PROCEDURE delete_remit(
        p_batch_id IN ar_batches.batch_id%TYPE );



FUNCTION revision RETURN VARCHAR2;


END  ARP_BR_REMIT_BATCHES;
--

/
