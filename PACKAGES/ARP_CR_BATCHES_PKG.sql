--------------------------------------------------------
--  DDL for Package ARP_CR_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CR_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARRIBATS.pls 120.4 2003/10/24 19:44:37 orashid ship $*/
PROCEDURE set_to_dummy( p_bat_rec OUT NOCOPY ar_batches%rowtype);
PROCEDURE insert_p( p_bat_rec    IN ar_batches%ROWTYPE,
        p_row_id OUT NOCOPY VARCHAR2,
        p_bat_id OUT NOCOPY ar_batches.batch_id%TYPE );
PROCEDURE insert_p( p_bat_rec    IN ar_batches%ROWTYPE,
        p_bat_id OUT NOCOPY ar_batches.batch_id%TYPE );
PROCEDURE update_p( p_bat_rec IN ar_batches%ROWTYPE,
                    p_batch_id IN
                           ar_batches.batch_id%TYPE);

PROCEDURE update_p( p_bat_rec    IN ar_batches%ROWTYPE );

PROCEDURE delete_p(
	p_bat_id IN ar_batches.batch_id%TYPE );

PROCEDURE lock_p(
        p_row_id        VARCHAR2,
        p_set_of_books_id  ar_batches.set_of_books_id%TYPE,
        p_batch_id  ar_batches.batch_id%TYPE,
        p_batch_applied_status  ar_batches.batch_applied_status%TYPE,
        p_batch_date  ar_batches.batch_date%TYPE,
        p_batch_source_id  ar_batches.batch_source_id%TYPE,
        p_comments  ar_batches.comments%TYPE,
        p_control_amount  ar_batches.control_amount%TYPE,
        p_control_count  ar_batches.control_count%TYPE,
        p_exchange_date  ar_batches.exchange_date%TYPE,
        p_exchange_rate  ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type  ar_batches.exchange_rate_type%TYPE,
        p_lockbox_batch_name  ar_batches.lockbox_batch_name%TYPE,
        p_media_reference  ar_batches.media_reference%TYPE,
        p_operation_request_id  ar_batches.operation_request_id%TYPE,
        p_receipt_class_id  ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id  ar_batches.receipt_method_id%TYPE,
        p_remit_method_code  ar_batches.remit_method_code%TYPE,
        p_remittance_bank_account_id  ar_batches.remit_bank_acct_use_id%type,
        p_remittance_bank_branch_id  ar_batches.remittance_bank_branch_id%TYPE,
        p_attribute_category  ar_batches.attribute_category%TYPE,
        p_attribute1  ar_batches.attribute1%TYPE,
        p_attribute2  ar_batches.attribute2%TYPE,
        p_attribute3  ar_batches.attribute3%TYPE,
        p_attribute4  ar_batches.attribute4%TYPE,
        p_attribute5  ar_batches.attribute5%TYPE,
        p_attribute6  ar_batches.attribute6%TYPE,
        p_attribute7  ar_batches.attribute7%TYPE,
        p_attribute8  ar_batches.attribute8%TYPE,
        p_attribute9  ar_batches.attribute9%TYPE,
        p_attribute10  ar_batches.attribute10%TYPE,
        p_attribute11  ar_batches.attribute11%TYPE,
        p_attribute12  ar_batches.attribute12%TYPE,
        p_attribute13  ar_batches.attribute13%TYPE,
        p_attribute14  ar_batches.attribute14%TYPE,
        p_attribute15  ar_batches.attribute15%TYPE,
        p_request_id  ar_batches.request_id%TYPE,
        p_transmission_id  ar_batches.transmission_id%TYPE,
        p_bank_deposit_number  ar_batches.bank_deposit_number%TYPE );


PROCEDURE nowaitlock_p(
	p_bat_id IN ar_batches.batch_id%TYPE );

PROCEDURE fetch_p( p_batch_id IN ar_batches.batch_id%TYPE,
                   p_batch_rec OUT NOCOPY ar_batches%ROWTYPE );
PROCEDURE lock_fetch_p(
                   p_batch_rec IN OUT NOCOPY ar_batches%ROWTYPE );

PROCEDURE nowaitlock_fetch_p(
                   p_batch_rec IN OUT NOCOPY ar_batches%ROWTYPE );

END  ARP_CR_BATCHES_PKG;
--

 

/
