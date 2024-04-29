--------------------------------------------------------
--  DDL for Package Body ARP_RW_BATCHES_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RW_BATCHES_CHECK_PKG" AS
/* $Header: ARERBA1B.pls 120.9.12010000.7 2009/10/13 07:11:37 naneja ship $ */
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE validate_args_cu_batch_name(
                    p_batch_source_id IN ar_batch_sources.batch_source_id%TYPE,
                    p_batch_name IN ar_batches.name%TYPE );
--
PROCEDURE validate_args_cu_batch_name(
                    p_batch_source_name IN ar_batch_sources.name%TYPE,
                    p_batch_name IN ar_batches.name%TYPE );
--
PROCEDURE validate_args_cu_media_ref(
		p_media_ref IN ar_batches.media_reference%TYPE );
--
PROCEDURE validate_args_update_manual(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE );
--
PROCEDURE validate_args_update_remit(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE );
--
PROCEDURE validate_args_update_auto(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE );
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_manual_batch - Updates a row in AR_BATCHES    after checking for|
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row in AR_BATCHES table after checking for     |
 |    uniqueness for items such as NAME, MEDIA_REFERENCE, GL_DATE            |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id - Row ID                                         |
 |                 p_batch_source_id - Batch Source Id                       |
 |                 p_batch_name  - Batch Name                                |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This procedure calls the check_unique_batch_name and              |
 |         check_unique_media_ref and arp_rw_icr_pkg.update_batch procedures |
 |                                                                           |
 | MODIFICATION HISTORY -  07/12/95 - Created by Ganesh Vaidee	     	     |
 | 19-MAR-96   Simon Leung	Call update_batch to update batch status.    |
 | 27-NOV-96   Karen Lawrance   Bug fix #423518.  Added GL Date, Deposit     |
 |                              Date and Batch Source to update list.        |
 +===========================================================================*/
PROCEDURE update_manual_batch(
        p_row_id IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_batch_source_id IN ar_batches.batch_source_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_deposit_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_control_amount IN ar_batches.control_amount%TYPE,
        p_control_count IN ar_batches.control_count%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                   IN ar_batches.remit_bank_acct_use_id%type,
        p_remittance_bank_branch_id
                   IN ar_batches.remittance_bank_branch_id%TYPE,
        p_attribute_category IN ar_batches.attribute_category%TYPE,
        p_attribute1 IN ar_batches.attribute1%TYPE,
        p_attribute2 IN ar_batches.attribute2%TYPE,
        p_attribute3 IN ar_batches.attribute3%TYPE,
        p_attribute4 IN ar_batches.attribute4%TYPE,
        p_attribute5 IN ar_batches.attribute5%TYPE,
        p_attribute6 IN ar_batches.attribute6%TYPE,
        p_attribute7 IN ar_batches.attribute7%TYPE,
        p_attribute8 IN ar_batches.attribute8%TYPE,
        p_attribute9 IN ar_batches.attribute9%TYPE,
        p_attribute10 IN ar_batches.attribute10%TYPE,
        p_attribute11 IN ar_batches.attribute11%TYPE,
        p_attribute12 IN ar_batches.attribute12%TYPE,
        p_attribute13 IN ar_batches.attribute13%TYPE,
        p_attribute14 IN ar_batches.attribute14%TYPE,
        p_attribute15 IN ar_batches.attribute15%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2 ) IS
--
l_batch_rec     ar_batches%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.update_manual_batch()+' );
       arp_util.debug(   'Row Id            : '||p_row_id );
       arp_util.debug(   'Batch ID          : '||p_batch_id );
       arp_util.debug(   'Batch Date        : '||TO_CHAR( p_batch_date ) );
    END IF;
    --
    -- Set local batch record fields to DUMMY
    --
    arp_cr_batches_pkg.set_to_dummy( l_batch_rec );
    --
    -- Populate the local batch record, so that it can be passed to update
    -- table handler
    l_batch_rec.batch_id := p_batch_id;
    l_batch_rec.batch_source_id := p_batch_source_id;
    l_batch_rec.batch_date := p_batch_date;
    l_batch_rec.gl_date := p_gl_date;
    l_batch_rec.deposit_date := p_deposit_date;
    l_batch_rec.currency_code := p_currency_code;
    l_batch_rec.comments := p_comments;
    l_batch_rec.control_amount := p_control_amount;
    l_batch_rec.control_count := p_control_count;
    l_batch_rec.exchange_date := p_exchange_date;
    l_batch_rec.exchange_rate := p_exchange_rate;
    l_batch_rec.exchange_rate_type := p_exchange_rate_type;
    l_batch_rec.receipt_class_id := p_receipt_class_id;
    l_batch_rec.receipt_method_id := p_receipt_method_id;
    l_batch_rec.remit_bank_acct_use_id := p_remittance_bank_account_id;
    l_batch_rec.remittance_bank_branch_id := p_remittance_bank_branch_id;
    l_batch_rec.attribute_category := p_attribute_category;
    l_batch_rec.attribute1 := p_attribute1;
    l_batch_rec.attribute2 := p_attribute2;
    l_batch_rec.attribute3 := p_attribute3;
    l_batch_rec.attribute4 := p_attribute4;
    l_batch_rec.attribute5 := p_attribute5;
    l_batch_rec.attribute6 := p_attribute6;
    l_batch_rec.attribute7 := p_attribute7;
    l_batch_rec.attribute8 := p_attribute8;
    l_batch_rec.attribute9 := p_attribute9;
    l_batch_rec.attribute10 := p_attribute10;
    l_batch_rec.attribute11 := p_attribute11;
    l_batch_rec.attribute12 := p_attribute12;
    l_batch_rec.attribute13 := p_attribute13;
    l_batch_rec.attribute14 := p_attribute14;
    l_batch_rec.attribute15 := p_attribute15;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_update_manual( p_row_id, l_batch_rec.batch_id,
				   l_batch_rec.batch_date );
    END IF;
    --
    -- call update table handler
    --
    arp_cr_batches_pkg.update_p( l_batch_rec, l_batch_rec.batch_id );
    --
    -- update the batch status
    --
    arp_rw_batches_check_pkg.update_batch_status( l_batch_rec.batch_id );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.update_manual_batch()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(   'EXCEPTION: arp_rw_batches_pkg.update_manual_batch' );
             END IF;
             RAISE;
END update_manual_batch;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_remit_batch						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row in AR_BATCHES table after checking for     |
 |    uniqueness for items such as NAME, MEDIA_REFERENCE, GL_DATE.  Used for |
 |    Remittance Batches only.						     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id          - Row ID                                |
 |                 p_batch_source_id - Batch Source Id                       |
 |                 p_batch_name      - Batch Name                            |
 |                 p_module_name     - Module that called this procedure     |
 |                 p_module_version  - Version of the module that called     |
 |                                     this procedure                        |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This procedure calls the check_unique_batch_name and check_       |
 |         unique_media_ref and arp_rw_icr_pkg.update_batch procedures.      |
 |                                                                           |
 | MODIFICATION HISTORY -  Created by Caroline M Clyde     (21 MAY 1997)     |
 +===========================================================================*/
PROCEDURE update_remit_batch(
        p_row_id               IN VARCHAR2,
        p_batch_id             IN ar_batches.batch_id%TYPE,
        p_batch_source_id      IN ar_batches.batch_source_id%TYPE,
        p_batch_date           IN ar_batches.batch_date%TYPE,
        p_gl_date              IN ar_batches.gl_date%TYPE,
        p_deposit_date         IN ar_batches.batch_date%TYPE,
        p_currency_code        IN ar_batches.currency_code%TYPE,
        p_comments             IN ar_batches.comments%TYPE,
        p_control_amount       IN ar_batches.control_amount%TYPE,
        p_control_count        IN ar_batches.control_count%TYPE,
        p_exchange_date        IN ar_batches.exchange_date%TYPE,
        p_exchange_rate        IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type   IN ar_batches.exchange_rate_type%TYPE,
        p_receipt_class_id     IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id    IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                               IN ar_batches.remit_bank_acct_use_id%type,
        p_remittance_bank_branch_id
                               IN ar_batches.remittance_bank_branch_id%TYPE,
        p_media_reference      IN ar_batches.media_reference%TYPE,
        p_bank_deposit_number  IN ar_batches.bank_deposit_number%TYPE,
        p_request_id           IN ar_batches.request_id%TYPE,
        p_operation_request_id IN ar_batches.operation_request_id%TYPE,
        p_attribute_category   IN ar_batches.attribute_category%TYPE,
        p_attribute1           IN ar_batches.attribute1%TYPE,
        p_attribute2           IN ar_batches.attribute2%TYPE,
        p_attribute3           IN ar_batches.attribute3%TYPE,
        p_attribute4           IN ar_batches.attribute4%TYPE,
        p_attribute5           IN ar_batches.attribute5%TYPE,
        p_attribute6           IN ar_batches.attribute6%TYPE,
        p_attribute7           IN ar_batches.attribute7%TYPE,
        p_attribute8           IN ar_batches.attribute8%TYPE,
        p_attribute9           IN ar_batches.attribute9%TYPE,
        p_attribute10          IN ar_batches.attribute10%TYPE,
        p_attribute11          IN ar_batches.attribute11%TYPE,
        p_attribute12          IN ar_batches.attribute12%TYPE,
        p_attribute13          IN ar_batches.attribute13%TYPE,
        p_attribute14          IN ar_batches.attribute14%TYPE,
        p_attribute15          IN ar_batches.attribute15%TYPE,
        p_module_name          IN VARCHAR2,
        p_module_version       IN VARCHAR2 ) IS

l_batch_rec     ar_batches%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.update_remit_batch()+' );
       arp_util.debug(   'Row Id            : '||p_row_id );
       arp_util.debug(   'Batch ID          : '||p_batch_id );
       arp_util.debug(   'Batch Date        : '||TO_CHAR( p_batch_date ) );
    END IF;

    -- Set local batch record fields to DUMMY.  This clears out NOCOPY any unwanted
    -- values from a previous update.

    arp_cr_batches_pkg.set_to_dummy( l_batch_rec );


    -- Populate the local batch record, so that it can be passed to update
    -- table handler.  Local variables are populated with the values passed
    -- in through the parameters.

    l_batch_rec.batch_id                   := p_batch_id;
    l_batch_rec.batch_source_id            := p_batch_source_id;
    l_batch_rec.batch_date                 := p_batch_date;
    l_batch_rec.gl_date                    := p_gl_date;
    l_batch_rec.deposit_date               := p_deposit_date;
    l_batch_rec.currency_code              := p_currency_code;
    l_batch_rec.comments                   := p_comments;
    l_batch_rec.control_amount             := p_control_amount;
    l_batch_rec.control_count              := p_control_count;
    l_batch_rec.exchange_date              := p_exchange_date;
    l_batch_rec.exchange_rate              := p_exchange_rate;
    l_batch_rec.exchange_rate_type         := p_exchange_rate_type;
    l_batch_rec.receipt_class_id           := p_receipt_class_id;
    l_batch_rec.receipt_method_id          := p_receipt_method_id;
    l_batch_rec.remit_bank_acct_use_id     := p_remittance_bank_account_id;
    l_batch_rec.remittance_bank_branch_id  := p_remittance_bank_branch_id;
    l_batch_rec.media_reference            := p_media_reference;
    l_batch_rec.bank_deposit_number        := p_bank_deposit_number;
    l_batch_rec.request_id                 := p_request_id;
    l_batch_rec.operation_request_id       := p_operation_request_id;
    l_batch_rec.attribute_category         := p_attribute_category;
    l_batch_rec.attribute1                 := p_attribute1;
    l_batch_rec.attribute2                 := p_attribute2;
    l_batch_rec.attribute3                 := p_attribute3;
    l_batch_rec.attribute4                 := p_attribute4;
    l_batch_rec.attribute5                 := p_attribute5;
    l_batch_rec.attribute6                 := p_attribute6;
    l_batch_rec.attribute7                 := p_attribute7;
    l_batch_rec.attribute8                 := p_attribute8;
    l_batch_rec.attribute9                 := p_attribute9;
    l_batch_rec.attribute10                := p_attribute10;
    l_batch_rec.attribute11                := p_attribute11;
    l_batch_rec.attribute12                := p_attribute12;
    l_batch_rec.attribute13                := p_attribute13;
    l_batch_rec.attribute14                := p_attribute14;
    l_batch_rec.attribute15                := p_attribute15;

    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_update_remit( p_row_id, l_batch_rec.batch_id,
				     l_batch_rec.batch_date );
    END IF;


    -- Call update table handler to update the record in AR_BATCHES.

    arp_cr_batches_pkg.update_p( l_batch_rec, l_batch_rec.batch_id );


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.update_remit_batch()-' );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug(   'EXCEPTION: arp_rw_batches_pkg.update_remit_batch' );
         END IF;
         RAISE;
END update_remit_batch;
---

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_auto_batch		  				             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row in AR_BATCHES table after checking for     |
 |    uniqueness for items such as NAME, MEDIA_REFERENCE, GL_DATE.  Used for |
 |    Automatic Batches only.						     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id          - Row ID                                |
 |                 p_batch_source_id - Batch Source Id                       |
 |                 p_batch_name      - Batch Name                            |
 |                 p_module_name     - Module that called this procedure     |
 |                 p_module_version  - Version of the module that called     |
 |                                     this procedure                        |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This procedure calls the check_unique_batch_name and check_       |
 |         unique_media_ref and arp_rw_icr_pkg.update_batch procedures.      |
 |                                                                           |
 | MODIFICATION HISTORY -  Created by Caroline M Clyde     (21 MAY 1997)     |
 +===========================================================================*/
PROCEDURE update_auto_batch(
        p_row_id               IN VARCHAR2,
        p_batch_id             IN ar_batches.batch_id%TYPE,
        p_batch_source_id      IN ar_batches.batch_source_id%TYPE,
        p_batch_date           IN ar_batches.batch_date%TYPE,
        p_gl_date              IN ar_batches.gl_date%TYPE,
        p_deposit_date         IN ar_batches.batch_date%TYPE,
        p_currency_code        IN ar_batches.currency_code%TYPE,
        p_comments             IN ar_batches.comments%TYPE,
        p_control_amount       IN ar_batches.control_amount%TYPE,
        p_control_count        IN ar_batches.control_count%TYPE,
        p_exchange_date        IN ar_batches.exchange_date%TYPE,
        p_exchange_rate        IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type   IN ar_batches.exchange_rate_type%TYPE,
        p_receipt_class_id     IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id    IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                               IN ar_batches.remit_bank_acct_use_id%type,
        p_remittance_bank_branch_id
                               IN ar_batches.remittance_bank_branch_id%TYPE,
        p_media_reference      IN ar_batches.media_reference%TYPE,
        p_bank_deposit_number  IN ar_batches.bank_deposit_number%TYPE,
        p_request_id           IN ar_batches.request_id%TYPE,
        p_operation_request_id IN ar_batches.operation_request_id%TYPE,
        p_attribute_category   IN ar_batches.attribute_category%TYPE,
        p_attribute1           IN ar_batches.attribute1%TYPE,
        p_attribute2           IN ar_batches.attribute2%TYPE,
        p_attribute3           IN ar_batches.attribute3%TYPE,
        p_attribute4           IN ar_batches.attribute4%TYPE,
        p_attribute5           IN ar_batches.attribute5%TYPE,
        p_attribute6           IN ar_batches.attribute6%TYPE,
        p_attribute7           IN ar_batches.attribute7%TYPE,
        p_attribute8           IN ar_batches.attribute8%TYPE,
        p_attribute9           IN ar_batches.attribute9%TYPE,
        p_attribute10          IN ar_batches.attribute10%TYPE,
        p_attribute11          IN ar_batches.attribute11%TYPE,
        p_attribute12          IN ar_batches.attribute12%TYPE,
        p_attribute13          IN ar_batches.attribute13%TYPE,
        p_attribute14          IN ar_batches.attribute14%TYPE,
        p_attribute15          IN ar_batches.attribute15%TYPE,
        p_module_name          IN VARCHAR2,
        p_module_version       IN VARCHAR2 ) IS

l_batch_rec     ar_batches%ROWTYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.update_auto_batch()+' );
       arp_util.debug(   'Row Id            : '||p_row_id );
       arp_util.debug(   'Batch ID          : '||p_batch_id );
       arp_util.debug(   'Batch Date        : '||TO_CHAR( p_batch_date ) );
    END IF;

    -- Set local batch record fields to DUMMY.  This clears out NOCOPY any unwanted
    -- values from a previous update.

    arp_cr_batches_pkg.set_to_dummy( l_batch_rec );


    -- Populate the local batch record, so that it can be passed to update
    -- table handler.  Local variables are populated with the values passed
    -- in through the parameters.

    l_batch_rec.batch_id                   := p_batch_id;
    l_batch_rec.batch_source_id            := p_batch_source_id;
    l_batch_rec.batch_date                 := p_batch_date;
    l_batch_rec.gl_date                    := p_gl_date;
    l_batch_rec.deposit_date               := p_deposit_date;
    l_batch_rec.currency_code              := p_currency_code;
    l_batch_rec.comments                   := p_comments;
    l_batch_rec.control_amount             := p_control_amount;
    l_batch_rec.control_count              := p_control_count;
    l_batch_rec.exchange_date              := p_exchange_date;
    l_batch_rec.exchange_rate              := p_exchange_rate;
    l_batch_rec.exchange_rate_type         := p_exchange_rate_type;
    l_batch_rec.receipt_class_id           := p_receipt_class_id;
    l_batch_rec.receipt_method_id          := p_receipt_method_id;
    l_batch_rec.remit_bank_acct_use_id     := p_remittance_bank_account_id;
    l_batch_rec.remittance_bank_branch_id  := p_remittance_bank_branch_id;
    l_batch_rec.media_reference            := p_media_reference;
    l_batch_rec.bank_deposit_number        := p_bank_deposit_number;
    l_batch_rec.request_id                 := p_request_id;
    l_batch_rec.operation_request_id       := p_operation_request_id;
    l_batch_rec.attribute_category         := p_attribute_category;
    l_batch_rec.attribute1                 := p_attribute1;
    l_batch_rec.attribute2                 := p_attribute2;
    l_batch_rec.attribute3                 := p_attribute3;
    l_batch_rec.attribute4                 := p_attribute4;
    l_batch_rec.attribute5                 := p_attribute5;
    l_batch_rec.attribute6                 := p_attribute6;
    l_batch_rec.attribute7                 := p_attribute7;
    l_batch_rec.attribute8                 := p_attribute8;
    l_batch_rec.attribute9                 := p_attribute9;
    l_batch_rec.attribute10                := p_attribute10;
    l_batch_rec.attribute11                := p_attribute11;
    l_batch_rec.attribute12                := p_attribute12;
    l_batch_rec.attribute13                := p_attribute13;
    l_batch_rec.attribute14                := p_attribute14;
    l_batch_rec.attribute15                := p_attribute15;

    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_update_auto( p_row_id, l_batch_rec.batch_id,
				    l_batch_rec.batch_date );
    END IF;


    -- Call update table handler to update the record in AR_BATCHES.

    arp_cr_batches_pkg.update_p( l_batch_rec, l_batch_rec.batch_id );


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.update_auto_batch()-' );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug(   'EXCEPTION: arp_rw_batches_pkg.update_auto_batch' );
         END IF;
         RAISE;
END update_auto_batch;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |       update_batch_status - Update the receipt batch with the status      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |        Update the receipt batch with the status                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_batch_id - Batch Id                                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES - This procedure will be called by update_row, insert_row procedure |
 |         and update_manual_batch procedure.                                |
 |                                                                           |
 | MODIFICATION HISTORY -  08/09/95 - Created by Ganesh Vaidee               |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_batch_status( p_batch_id IN ar_batches.batch_id%TYPE,
			       p_called_from IN VARCHAR2 DEFAULT NULL) IS
l_icr_count     NUMBER := 0;
l_icr_amount    NUMBER := 0;
--
l_batch_status    VARCHAR2( 30 );
l_batch_rec      ar_batches%ROWTYPE;
--Bug7194951
l_exists         VARCHAR2(1);
l_bat_id         ar_batches.batch_id%TYPE;
l_type           ar_batches.type%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_check_pkg.update_batch_status()+' );
       arp_util.debug(   'Batch ID          : '||p_batch_id );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_check_pkg.update_batch_status()-' );
    END IF;
    --
    -- Set batch record values to dummy
    --
    arp_cr_batches_pkg.set_to_dummy( l_batch_rec );
    --
    --  determine if the batch has any unposted quick cash receipts
    --  in the AR_INTERIM_CASH_RECEIPTS table
    --
    SELECT  NVL(SUM(DECODE
                   (
                        icr.status,
                        NULL, 0,
                        'UNAPP', 1,
                        1
                   )),0),
            NVL(SUM( icr.amount ), 0 )
    INTO    l_icr_count, l_icr_amount
    FROM    ar_interim_cash_receipts icr,
            ar_batches b
    WHERE   b.batch_id = p_batch_id
    AND     b.batch_id = icr.batch_id(+);
    --
    -- select if the batch has the required count and that all the
    -- cash receipts are 'APP'
    -- This statement now counts the quickcash receipts
    --  OOB - when actual does not match control
    --  OP  - when actual matches control but not all receipts applied
    --  CL  - when actual matches control and everything applied
    --
    -- Bug 8944419 changed logic for creating batch status
    SELECT  DECODE
            (
                ABS((NVL(SUM(DECODE
                                 (
                                     cr.status,
                                     NULL, 0,
                                     'REV', 0, 'CC_CHARGEBACK_REV',0,
                                     1
                                 )), 0) +
                             l_icr_count -
                         b.control_count )) +
                ABS((NVL(SUM(DECODE
                                 (
                                     cr.status,
                                     NULL, 0,
                                     'REV', 0, 'CC_CHARGEBACK_REV',0,
                                     cr.amount
                                 )),0) +
                             l_icr_amount -
                         b.control_amount )) -
                    ABS((NVL(SUM(DECODE
                                     (
                                         cr.status,
                                         'APP', cr.amount,
                                         'NSF', cr.amount,
                                         'STOP', cr.amount,
                                         0
                                     )),0) -
                             b.control_amount )) -
                ABS((NVL(SUM(DECODE
                                 (
                                      cr.status,
                                      'APP', 1,
                                      'NSF', 1,
                                      'STOP', 1,
                                      0
                                 )),0) -
                         b.control_count )),
                0, 'CL',
                DECODE
                (
                    ABS(SIGN(NVL(SUM(DECODE
                                     (
                                         cr.status,
                                        NULL, 0,
/*                                         'REV', 1, 'CC_CHARGEBACK_REV',1,*/
                                         1
                                     )),0) +
                             l_icr_count -
                             b.control_count )) +
                    ABS(SIGN(NVL(SUM(DECODE
                                     (
                                         cr.status,
                                        NULL, 0,
/*                                         'REV', cr.amount, 'CC_CHARGEBACK_REV',cr.amount,*/
                                         cr.amount
                                     )),0) +
                             l_icr_amount -
                             b.control_amount )),
                    0, 'OP',
                    'OOB'
                 )
            )
    INTO    l_batch_status
    FROM    ar_cash_receipt_history          crh,
            ar_cash_receipts                 cr,
            ar_batches                       b
    WHERE   b.batch_id                       = p_batch_id
    AND     crh.batch_id(+)                  = b.batch_id
    AND     crh.first_posted_record_flag(+)  = 'Y'
    AND     cr.cash_receipt_id(+)            = crh.cash_receipt_id
    GROUP BY b.batch_id,
             b.control_count,
             b.control_amount;
    --
    l_batch_rec.status := l_batch_status;
    --
    -- Update batch status
    --
    --Bug7194951 Changes Start Here (FP of 7138001 and 7146916)

    /* Chages are put to block updation of status field for remittace batch.
       Earlier changes for bug 7138001 were made to avoid completion of
       prepayment matching program in error due to lock of batch of remittance with
       different program running in concurrent mode.
       This resulted in perofrmance due to lock contention.
       Finally prevented updation of batch for status as currently
       status field is not significant for remittance batch. Prevented for call from prepayment only
       Also didnot get for lock in case of exisitng code to avoid any regression*/

    arp_standard.debug('arp_rw_batches_check_pkg.update_batch_status: Before locking');
    l_exists := NULL;
    BEGIN
      SELECT 'Y',TYPE
      INTO l_exists,l_type
      FROM ar_batches
      WHERE batch_id = p_batch_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
            arp_standard.debug('arp_rw_batches_check_pkg.update_batch_status: No data with new status');
        WHEN OTHERS THEN
            arp_standard.debug( 'EXCEPTION: arp_rw_batches_check_pkg.update_batch_status lock batch' );
            RAISE;
    END;

    IF nvl(p_called_from,'NONE') =  'PREPAYMENT' AND l_type = 'REMITTANCE' THEN
       l_exists := NULL;
    END IF;
    IF nvl(l_exists,'N') = 'Y'  THEN
/*
      SELECT batch_id
      INTO   l_bat_id
      FROM  ar_batches
      WHERE batch_id = p_batch_id
      FOR UPDATE OF STATUS;
*/
       arp_standard.debug('arp_rw_batches_check_pkg.update_batch_status: Before calling update for batch');
       arp_cr_batches_pkg.update_p( l_batch_rec, p_batch_id );
    END IF;
    --Bug7194951 Changes End Here (FP of 7138001 and 7146916)

    --
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
                   'EXCEPTION: arp_rw_batches_check_pkg.update_batch_status' );
              END IF;
        RAISE;
END  update_batch_status;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_update_manual                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to update_manual_batch procedure             |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_type - Batch Type                                       |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 07/12/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_update_manual(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
	p_batch_date IN ar_batches.batch_date%TYPE ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.validate_args_update_manual()+' );
    END IF;
    --
    IF ( p_row_id IS NULL OR p_batch_id IS NULL OR
         p_batch_date IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.validate_args_update_manual()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_update_manual' );
              END IF;
              RAISE;
END validate_args_update_manual;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_update_remit                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to update_remit_batch procedure              |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_type - Batch Type                                       |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Caroline M Clyde   (21 MAY 1997)        |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_update_remit(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
	p_batch_date IN ar_batches.batch_date%TYPE ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.validate_args_update_remit()+' );
    END IF;
    --
    IF ( p_row_id IS NULL OR p_batch_id IS NULL OR
         p_batch_date IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.validate_args_update_remit()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_update_remit' );
              END IF;
              RAISE;
END validate_args_update_remit;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_update_auto                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to update_auto_batch procedure               |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_type - Batch Type                                       |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Caroline M Clyde   (21 MAY 1997)        |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_update_auto(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
	p_batch_date IN ar_batches.batch_date%TYPE ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.validate_args_update_auto()+' );
    END IF;
    --
    IF ( p_row_id IS NULL OR p_batch_id IS NULL OR
         p_batch_date IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.validate_args_update_auto()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_update_auto' );
              END IF;
              RAISE;
END validate_args_update_auto;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_unique_batch_name - Check uniqueness of a batch for a particular |
 |                              batch source.                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function Check uniqueness of a batch for a particular batch source|
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_row_id - Row ID                                         |
 |                 p_batch_source_id - Batch Source Id                       |
 |                 p_batch_name  - Batch Name                                |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES - This is an overlaoded procedure                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  07/12/95 - Created by Ganesh Vaidee               |
 +===========================================================================*/
PROCEDURE check_unique_batch_name(
                p_row_id IN VARCHAR2,
                p_batch_source_id IN ar_batch_sources.batch_source_id%TYPE,
                p_batch_name IN ar_batches.name%TYPE,
                p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 ) IS
l_count    NUMBER := 0;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.check_unique_batch_name()+' );
       arp_util.debug(   'Row Id            : '||p_row_id );
       arp_util.debug(   'Batch Source Id   : '||TO_CHAR( p_batch_source_id ) );
       arp_util.debug(   'Batch Name        : '||p_batch_name );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_cu_batch_name( p_batch_source_id, p_batch_name );
    END IF;
    --
    SELECT  COUNT(*)
    INTO    l_count
    FROM    AR_BATCHES bat
    WHERE   bat.batch_source_id = p_batch_source_id
    AND     bat.name = p_batch_name
    AND     (     p_row_id IS NULL
              OR  bat.rowid <> p_row_id );
    IF ( l_count <> 0 ) THEN
         FND_MESSAGE.set_name( 'AR', 'AR_DUP_BATCH_NAME' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.check_unique_batch_name()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(
		     'EXCEPTION: arp_rw_batches_pkg.check_unique_batch_name' );
             END IF;
             RAISE;
END check_unique_batch_name;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_cu_batch_name                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to check_unique_batch_name procedure         |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_batch_source_id - Batch source ID                       |
 |                 p_batch_name  - Batch Name                                |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This is an overlaoded procedure                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 07/12/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_cu_batch_name(
		    p_batch_source_id IN ar_batch_sources.batch_source_id%TYPE,
		    p_batch_name IN ar_batches.name%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_cu_batch_name()+' );
    END IF;
    --
    IF ( p_batch_source_id is NULL OR p_batch_name is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_cu_batch_name()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_cu_batch_name' );
              END IF;
              RAISE;
END validate_args_cu_batch_name;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_unique_batch_name - Check uniqueness of a batch for a particular |
 |                              batch source.                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function Check uniqueness of a batch for a particular batch source|
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id - Row ID                                         |
 |                 p_batch_source_name - Batch source Name                   |
 |                 p_batch_name  - Batch Name                                |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This is an OVERLAODED procedure                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  07/12/95 - Created by Ganesh Vaidee	     	     |
 +===========================================================================*/
PROCEDURE check_unique_batch_name(
		p_row_id IN VARCHAR2,
		p_batch_source_name IN ar_batch_sources.name%TYPE,
		p_batch_name IN ar_batches.name%TYPE,
                p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 ) IS
l_count    NUMBER := 0;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.check_unique_batch_name()+' );
       arp_util.debug(   'Row Id            : '||p_row_id );
       arp_util.debug(   'Batch Source Name : '||p_batch_source_name );
       arp_util.debug(   'Batch Name        : '||p_batch_name );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_cu_batch_name( p_batch_source_name, p_batch_name );
    END IF;
    --
    SELECT  COUNT(*)
    INTO    l_count
    FROM    AR_BATCH_SOURCES bs,
            AR_BATCHES bat
    WHERE   bat.batch_source_id = bs.batch_source_id
    AND     bs.name = p_batch_source_name
    AND     bat.name = p_batch_name
    AND     (     p_row_id IS NULL
              OR  bat.rowid <> p_row_id );
    IF ( l_count <> 0 ) THEN
         FND_MESSAGE.set_name( 'AR', 'AR_DUP_BATCH_NAME' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug(   'arp_rw_batches_pkg.check_unique_batch_name()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(
		     'EXCEPTION: arp_rw_batches_pkg.check_unique_batch_name' );
             END IF;
             RAISE;
END check_unique_batch_name;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_cu_batch_name                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to check_unique_batch_name procedure         |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_batch_source_name - Batch source Name                   |
 |                 p_batch_name  - Batch Name                                |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This is an OVERLAODED procedure                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 07/12/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_cu_batch_name(
		    p_batch_source_name IN ar_batch_sources.name%TYPE,
		    p_batch_name IN ar_batches.name%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_cu_batch_name()+' );
    END IF;
    --
    IF ( p_batch_source_name is NULL OR p_batch_name is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_cu_batch_name()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_cu_batch_name' );
              END IF;
              RAISE;
END validate_args_cu_batch_name;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_unique_media_ref  - Check uniqueness of a Media reference        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function Check uniqueness of Media reference in AR_BATCHES table  |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id - Row ID                                         |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  07/12/95 - Created by Ganesh Vaidee	     	     |
 +===========================================================================*/
PROCEDURE check_unique_media_ref(
		p_row_id IN VARCHAR2,
		p_media_ref IN ar_batches.media_reference%TYPE,
                p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 ) IS
l_count    NUMBER := 0;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.check_unique_media_ref()+' );
       arp_util.debug('check_unique_media_ref: ' ||  'Row Id            : '||p_row_id );
       arp_util.debug('check_unique_media_ref: ' ||  'Media Reference   : '||p_media_ref );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_cu_media_ref( p_media_ref );
    END IF;
    --
    SELECT  COUNT(*)
    INTO    l_count
    FROM    AR_BATCHES bat
    WHERE   bat.media_reference = p_media_ref
    AND     (     p_row_id IS NULL
              OR  bat.rowid <> p_row_id );
    IF ( l_count <> 0 ) THEN
         FND_MESSAGE.set_name( 'AR', 'AR_DUP_MEDIA_REFERENCE' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.check_unique_media_ref()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('check_unique_media_ref: ' ||
		     'EXCEPTION: arp_rw_batches_pkg.check_unique_media_ref' );
             END IF;
             RAISE;
END check_unique_media_ref;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_cu_media_ref                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to check_unique_media_ref  procedure         |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_media_ref - Media reference                             |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This is an overlaoded procedure                                   |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 07/12/95		     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_cu_media_ref(
		p_media_ref IN ar_batches.media_reference%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_cu_media_ref()+' );
    END IF;
    --
    IF ( p_media_ref is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_cu_media_ref()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('validate_args_cu_media_ref: ' ||
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_cu_media_ref' );
              END IF;
              RAISE;
END validate_args_cu_media_ref;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    post_batch_conc_req - Starts the post batch conc. request.             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure starts the post batch conc. request.                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_batch_id - Batch Id associated with the batch           |
 |                 p_set_of_books_id - set of books id                       |
 |                 p_transmission_id - Transmission Id if batch was created  |
 |                                     thro' Lockbox.                        |
 |                 p_module_name    - Module name that called this procedure |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  11/22/95 - Created by Ganesh Vaidee               |
 | 18-JAN-96 	scleung		Added the p_set_of_books_id argument.        |
 +===========================================================================*/
PROCEDURE post_batch_conc_req( p_batch_id IN ar_batches.batch_id%TYPE,
                               p_set_of_books_id IN
                                        ar_batches.set_of_books_id%TYPE,
                               p_transmission_id IN
                                        ar_batches.transmission_id%TYPE,
                               p_batch_applied_status  OUT NOCOPY
                                        ar_batches.batch_applied_status%TYPE,
                               p_request_id  OUT NOCOPY ar_batches.request_id%TYPE,
			       p_module_name IN VARCHAR2,
                               p_module_version IN VARCHAR2 ) IS
--
l_request_id ar_batches.request_id%TYPE;
l_org_id  number;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rw_batches_check_pkg.post_batch_conc_req()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'Batch Id '||p_batch_id );
       arp_standard.debug(   'Set Of Books Id '||p_set_of_books_id );
       arp_standard.debug(   'Transmission_id = '||p_transmission_id );
    END IF;
    --
    -- Make sure that a batch id has been passed.
    --
    IF ( p_batch_id IS NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    -- Call the concurrent program
    --
    --MOAC changes
    select org_id into l_org_id from ar_system_parameters;

    FND_REQUEST.SET_ORG_ID(l_org_id);
  l_request_id := FND_REQUEST.submit_request( 'AR', 'ARCABP',
                                    'Submit Post Batch',
                                    SYSDATE, FALSE,
                                    '1',
                                    p_batch_id,
                                    p_set_of_books_id,
				    0,
				    0,
                                    p_transmission_id ,
                                    ARP_GLOBAL.sysparam.ORG_ID);
    --
    p_request_id := l_request_id;
    p_batch_applied_status := 'IN_PROCESS';
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rw_batches_check_pkg.post_batch_conc_req()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug(
                'EXCEPTION: arp_rw_batches_check_pkg.post_batch_conc_req' );
              END IF;
              RAISE;
              --
END post_batch_conc_req;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_quick_amount_totals - gets the applied,unapplied,unid. amounts     |
 |                              and totals                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure gets the applied,unapplied,unid. amounts and totals     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_batch_id - Batch Id associated with the batch           |
 |                 p_module_name    - Module name that called this procedure |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                 p_applied_amount_total - applied Amount total             |
 |                 p_applied_count_total - applied Amount count              |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY -  11/28/95 - Created by Ganesh Vaidee               |
 | 29-JAN-96 Simon Leung	Fixed the applied_amount/count logics.       |
 | 01-APR-96 Simon Leung	Added debug message l_break_point.           |
 | 15-OCT-98 Karen Murphy	Cross Currency Lockbox.  Modified select     |
 |                              statements that look at payment_amount in    |
 |                              interim cash receipt lines.  Need to consider|
 |                              the amount applied from column as this stores|
 |                              the amount in receipt currency for cross     |
 |                              currency applications.                       |
 | 01-JUN-01 Muthuraman. R      Added an NVL condition so that Unapplied     |
 |                              Receipt counts are correct prior to          |
 |                              postquick cash in receipt batches window.    |
 | 07-JAN-03    K Dhaliwal      Bug 2707190 added Claim Amount and Count     |
 |                              to get_quick_amount_totals                   |
 +===========================================================================*/
PROCEDURE get_quick_amount_totals( p_batch_id IN ar_batches.batch_id%TYPE,
                             p_actual_amount_total OUT NOCOPY NUMBER,
                             p_actual_count_total OUT NOCOPY NUMBER,
                             p_unidentified_amount_total OUT NOCOPY NUMBER,
                             p_unidentified_count_total OUT NOCOPY NUMBER,
                             p_on_account_amount_total OUT NOCOPY NUMBER,
                             p_on_account_count_total OUT NOCOPY NUMBER,
                             p_unapplied_amount_total OUT NOCOPY NUMBER,
                             p_unapplied_count_total OUT NOCOPY NUMBER,
                             p_applied_amount_total OUT NOCOPY NUMBER,
                             p_applied_count_total OUT NOCOPY NUMBER,
                             p_claim_amount_total OUT NOCOPY NUMBER,
                             p_claim_count_total OUT NOCOPY NUMBER,
                             p_module_name IN VARCHAR2,
                             p_module_version IN VARCHAR2 ) IS
--
l_unapplied_amount_total NUMBER := 0;
l_unapplied_count_total NUMBER := 0;
l_applied_amount_total NUMBER := 0;
l_applied_count_total NUMBER := 0;
l_actual_amount_total NUMBER := 0;
l_actual_count_total NUMBER := 0;
l_claim_amount_total_header NUMBER := 0;
l_claim_amount_total_lines NUMBER := 0;
l_onacct_amount_total_header NUMBER := 0;
l_onacct_amount_total_lines NUMBER := 0;
l_break_point VARCHAR2(20);
l_claim_count_total_header NUMBER := 0;
l_claim_count_total_lines NUMBER := 0;
l_onacct_count_total_header NUMBER := 0;
l_onacct_count_total_lines NUMBER := 0;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rw_batches_check_pkg.get_quick_amount_totals()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('get_quick_amount_totals: ' ||  'Batch Id '||p_batch_id );
    END IF;
    --
    IF ( p_batch_id IS NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    l_break_point := '1st SELECT';
    -- Bug #443266
    -- Modified this query so that this shows correct on-account
    -- receipt count.
    --
    -- Bug #1560911 mramanat 15/01/2001
    -- Added NVL Clause for calculation of applied amount and applied count
    -- so that these show up correctly for receipts imported through lockbox.

    SELECT SUM( NVL( icr.amount, 0 ) ), COUNT(*),
           NVL( SUM( DECODE( icr.special_type,
			'CLAIM',  icr.amount,
                             0
                           )
                   ), 0
              ),
           NVL( COUNT( DECODE( icr.special_type,
                               'CLAIM', 1,
                               ''
                             )
                     ), 0
              ),
           NVL( SUM( DECODE( icr.special_type,
			'ON_ACCOUNT',  icr.amount,
                             0
                           )
                   ), 0
              ),
           NVL( COUNT( DECODE( icr.special_type,
                               'ON_ACCOUNT', 1,
                               ''
                             )
                     ), 0
              ),

           NVL( SUM( DECODE( NVL(icr.special_type,'SINGLE'),
                       		'RECEIPT_RULE',  icr.amount,
                       		'SINGLE',  icr.amount,
                             0
                           )
                   ), 0
              ),
           NVL( COUNT( DECODE( NVL(icr.special_type,'SINGLE'),
                               'RECEIPT_RULE', 1,
                               'SINGLE', 1,
                               ''
                             )
                     ), 0
              ),

           NVL( SUM( DECODE( icr.special_type,
                             'UNAPPLIED',  icr.amount,
                             'MULTIPLE',  icr.amount,
                             0
                           )
                   ), 0
              ),
           NVL( COUNT( DECODE( icr.special_type,
                               'UNAPPLIED', 1,
                               ''
                             )
                     ), 0
              ),
           NVL( SUM( DECODE( icr.special_type,
                             'UNIDENTIFIED',  icr.amount,
                             0
                           )
                   ), 0
              ),
           NVL( COUNT( DECODE( icr.special_type,
                               'UNIDENTIFIED', 1,
                               ''
                             )
                     ), 0
              )
    INTO   l_actual_amount_total,
           l_actual_count_total,
           l_claim_amount_total_header,
           l_claim_count_total_header,
           l_onacct_amount_total_header,
           l_onacct_count_total_header,
           l_applied_amount_total,
           l_applied_count_total,
           l_unapplied_amount_total,
           l_unapplied_count_total,
           p_unidentified_amount_total,
           p_unidentified_count_total
    FROM   ar_interim_cash_receipts icr
    WHERE  icr.batch_id = p_batch_id;
    --
    --
    --
    l_break_point := '2nd SELECT';
        SELECT l_applied_amount_total + NVL(SUM( nvl(icrl.amount_applied_from, icrl.payment_amount) ),0),
               l_unapplied_amount_total - NVL(SUM( nvl(icrl.amount_applied_from, icrl.payment_amount) ),0),
                NVL( SUM(decode(icrl.payment_schedule_id,-4,nvl(icrl.amount_applied_from, icrl.payment_amount),0 )),0),
                NVL( SUM(decode(icrl.payment_schedule_id,-1,nvl(icrl.amount_applied_from, icrl.payment_amount),0 )),0)
        INTO l_applied_amount_total,
             l_unapplied_amount_total,
             l_claim_amount_total_lines,
             l_onacct_amount_total_lines
        FROM ar_interim_cash_receipts icr,
             ar_interim_cash_receipt_lines icrl
        WHERE  icrl.cash_receipt_id = icr.cash_receipt_id
        AND    icr.batch_id = p_batch_id;
    --
    -- Add to unapplied count if all amounts of receipt has not been paid off
    --

    /* 01-Jun-2001 Bugfix 1773585.
       Added an NVL condition so that Unapplied Receipt counts are correct
       prior to postquick cash in receipt batches window.
    */

    l_break_point := '3rd SELECT';
       SELECT NVL(l_applied_count_total,0) +
              COUNT( DECODE( SIGN(rec.amount - SUM( nvl(ln.amount_applied_from, ln.payment_amount) ) ),
                             0, 1, '' )),
              NVL(l_unapplied_count_total,0) +
              COUNT( DECODE( SIGN(rec.amount - NVL( SUM( nvl(ln.amount_applied_from, ln.payment_amount) ) , 0 )),
                             1, 1, '' ))
       INTO   l_applied_count_total,
              l_unapplied_count_total
       FROM   ar_interim_cash_receipt_lines ln,
              ar_interim_cash_receipts rec
       WHERE  rec.batch_id = p_batch_id
       AND    rec.cash_receipt_id = ln.cash_receipt_id
       GROUP BY
              rec.cash_receipt_id,
              rec.amount;

    l_break_point := '4th SELECT';
       SELECT sum(sign(CLAIM))  Claims_Count
             ,sum(sign(ON_ACC)) On_Account_Count
             --,sum(nvl(TRX,0)) + nvl(l_applied_count_total,0)   Trx_Count
       INTO    l_claim_count_total_lines
              ,l_onacct_count_total_lines
              --,l_applied_count_total
       FROM (select sum(decode(payment_schedule_id,-4,1,0)) CLAIM
              , SUM(decode(payment_schedule_id,-1,1,0)) ON_ACC
              , sum(decode(sign(payment_schedule_id),1,1,0)) TRX
             from ar_interim_cash_receipt_lines ln
	     where  ln.batch_id = p_batch_id
	    );

    --
    -- Copy local valued to OUT NOCOPY parameters
    --
    p_claim_amount_total := nvl(l_claim_amount_total_header,0) + nvl(l_claim_amount_total_lines,0);
    p_on_account_amount_total := nvl(l_onacct_amount_total_header,0) + nvl(l_onacct_amount_total_lines,0);
    p_claim_count_total := nvl(l_claim_count_total_header,0) + nvl(l_claim_count_total_lines,0);
    p_on_account_count_total := nvl(l_onacct_count_total_header,0) + nvl(l_onacct_count_total_lines,0);
    --
    p_actual_amount_total := nvl(l_actual_amount_total,0);
    p_actual_count_total := nvl(l_actual_count_total,0);
    --
    p_applied_amount_total := nvl(l_applied_amount_total,0) - nvl(l_claim_amount_total_lines ,0)- nvl(l_onacct_amount_total_lines,0);
    p_applied_count_total := nvl(l_applied_count_total,0);
    --
    p_unapplied_amount_total := nvl(l_unapplied_amount_total,0);
    p_unapplied_count_total := nvl(l_unapplied_count_total,0);
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Get Quick Cash Totals - Claim Count Header='||to_char(l_claim_count_total_header));
       arp_standard.debug('Get Quick Cash Totals - Claim Count Lines='||to_char(l_claim_count_total_lines));
       arp_standard.debug('Get Quick Cash Totals - onacct Count Header='||to_char(l_onacct_count_total_header));
       arp_standard.debug('Get Quick Cash Totals - Onacct Count Lines='||to_char(l_onacct_count_total_lines));
       arp_standard.debug('Get Quick Cash Totals - Claim Count='||to_char(p_claim_count_total));
       arp_standard.debug( 'arp_rw_batches_check_pkg.get_quick_amount_totals()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('get_quick_amount_totals: ' ||
                'EXCEPTION: arp_rw_batches_check_pkg.get_quick_amount_totals '||
                            l_break_point );
              END IF;
              RAISE;
              --
END get_quick_amount_totals;
--

PROCEDURE get_reg_amount_totals( p_batch_id IN ar_batches.batch_id%TYPE,
                             p_actual_amount_total OUT NOCOPY NUMBER,
                             p_actual_count_total OUT NOCOPY NUMBER,
                             p_unidentified_amount_total OUT NOCOPY NUMBER,
                             p_unidentified_count_total OUT NOCOPY NUMBER,
                             p_on_account_amount_total OUT NOCOPY NUMBER,
                             p_on_account_count_total OUT NOCOPY NUMBER,
			     p_returned_amount_total OUT NOCOPY NUMBER,
                             p_returned_count_total OUT NOCOPY NUMBER,
                             p_reversed_amount_total OUT NOCOPY NUMBER,
                             p_reversed_count_total OUT NOCOPY NUMBER,
                             p_unapplied_amount_total OUT NOCOPY NUMBER,
                             p_unapplied_count_total OUT NOCOPY NUMBER,
                             p_applied_amount_total OUT NOCOPY NUMBER,
                             p_applied_count_total OUT NOCOPY NUMBER,
                             p_claim_amount_total OUT NOCOPY NUMBER,
                             p_claim_count_total OUT NOCOPY NUMBER,
                             p_prepayment_amount_total OUT NOCOPY NUMBER,
                             p_prepayment_count_total OUT NOCOPY NUMBER,
                             p_misc_amount_total OUT NOCOPY NUMBER,
                             p_misc_count_total OUT NOCOPY NUMBER,
                             p_module_name IN VARCHAR2,
                             p_module_version IN VARCHAR2 ) IS
--
l_unapplied_amount_total NUMBER := 0;
l_unapplied_count_total NUMBER := 0;
l_applied_amount_total NUMBER := 0;
l_applied_count_total NUMBER := 0;
l_actual_amount_total NUMBER := 0;
l_actual_count_total NUMBER := 0;
l_on_account_count_total NUMBER :=0;
l_on_account_amount_total NUMBER :=0;
l_claim_amount_total NUMBER := 0;
l_claim_count_total NUMBER := 0;
l_prepayment_amount_total NUMBER := 0;
l_prepayment_count_total NUMBER := 0;
l_misc_count_total NUMBER := 0;
l_misc_amount_total NUMBER := 0;
l_break_point VARCHAR2(20);
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rw_batches_check_pkg.get_reg_amount_totals()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('get_reg_amount_totals: ' ||  'Batch Id '||p_batch_id );
    END IF;
    --
    IF ( p_batch_id IS NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    --
    -- Shiv Ragunat - 10/22/96
    -- As part of fix for Bug 398344
    -- Actual amount now is sum(cr.amount) for that batch_id
    -- Actual Count is count(cr.status) for that batch_id.
    --
    --
   l_break_point := '1st SELECT';
    -- Fixed following query for Bug #435632.
    --
    -- Bug 8944419 Included receipt reversed using newly added reversal type
    -- in Reversed category as per PM input.
   SELECT  NVL( SUM( cr.amount ),0),
           NVL( COUNT( cr.status ) ,0 ),
	   NVL( SUM(DECODE( cr.status, 'NSF', cr.amount, 'STOP', cr.amount,0)),0),
	   NVL( COUNT(DECODE( cr.status, 'NSF', 1, 'STOP', 1,'')),0),
           NVL( SUM(DECODE( cr.status, 'REV', cr.amount, 'CC_CHARGEBACK_REV', cr.amount, 0)), 0),
           NVL( COUNT(DECODE( cr.status, 'REV', 1, 'CC_CHARGEBACK_REV', 1, '')), 0),
           NVL( COUNT(DECODE( cr.status , 'UNAPP', 1, '')),0),
	   NVL(COUNT (DECODE(cr.status,
                             'APP', DECODE( cr.type, 'MISC', '', 1),
                             '')), 0),
	   NVL( SUM( DECODE( cr.status, 'UNID',  cr.amount,0)), 0),
	   NVL( COUNT(DECODE( cr.status , 'UNID', 1, '')),0),
           NVL( SUM( DECODE( cr.type,
                             'MISC', DECODE( cr.status, 'REV', 0,
                                                        'NSF', 0,
                                                        'STOP', 0, cr.amount),
                             0 )), 0),
           NVL( COUNT(DECODE( cr.type,
                             'MISC', DECODE( cr.status, 'REV', '',
                                                        'NSF', '',
                                                        'STOP', '',  1),
                             '')), 0)
   INTO    l_actual_amount_total,
	   l_actual_count_total,
           p_returned_amount_total,
	   p_returned_count_total,
           p_reversed_amount_total,
           p_reversed_count_total,
	   l_unapplied_count_total,
	   l_applied_count_total,
           p_unidentified_amount_total,
	   p_unidentified_count_total,
           l_misc_amount_total,
           l_misc_count_total
   FROM    ar_cash_receipts cr,
	   ar_cash_receipt_history crh
   WHERE   cr.cash_receipt_id = crh.cash_receipt_id
   AND     crh.first_posted_record_flag = 'Y'
   AND     crh.batch_id = p_batch_id;
    --
    --
    --

   l_break_point := '2nd SELECT';
   SELECT 	NVL(SUM(DECODE(ra.STATUS, 'APP', nvl(ra.amount_applied_from, ra.amount_applied),
                                          'ACTIVITY',--Added for bug 1647470
                                           DECODE(ra.applied_payment_schedule_id,
                                                  -3,ra.amount_applied,
                                                  -8,ra.amount_applied
                                                  ,Decode(ra.RECEIVABLES_TRX_ID,-16,ra.amount_applied,0)),
                                           0)),0),
	  	NVL( SUM( DECODE( ra.status, 'UNAPP', ra.amount_applied,0)), 0),
		NVL(SUM(DECODE(ra.STATUS, 'ACC', ra.amount_applied, 0)),0),
                NVL(SUM(DECODE(ra.STATUS, 'OTHER ACC',DECODE(applied_payment_schedule_id,
                                   -4,NVL(ra.amount_applied_from, ra.amount_applied),0),0)),0),
                NVL(SUM(DECODE(ra.STATUS, 'OTHER ACC',DECODE(applied_payment_schedule_id,
                                   -7,NVL(ra.amount_applied_from, ra.amount_applied),0),0)),0)
   INTO   	l_applied_amount_total,
		l_unapplied_amount_total,
	       	l_on_account_amount_total,
	       	l_claim_amount_total,
	       	l_prepayment_amount_total
   FROM   	ar_receivable_applications ra,
	       	ar_cash_receipt_history crh
   WHERE  	ra.cash_receipt_id = crh.cash_receipt_id
   AND	        crh.first_posted_record_flag = 'Y'
   AND	        crh.batch_id = p_batch_id;
    --
    -- Added this query for Bug #443266.
    -- Get the receipt counts for the fully on-account receipts.
    --
   l_break_point := '3rd SELECT';
   --
   Begin
   --
   SELECT   nvl(count(cr.cash_receipt_id), 0)
   INTO     l_on_account_count_total
   FROM     ar_cash_receipts cr,
            ar_cash_receipt_history crh
   WHERE    crh.cash_receipt_id = cr.cash_receipt_id
   AND      crh.first_posted_record_flag = 'Y'
   AND      crh.batch_id = p_batch_id
   AND      cr.amount = (SELECT sum(ra.amount_applied)
                         FROM   ar_receivable_applications ra
                         WHERE  ra.cash_receipt_id = cr.cash_receipt_id
                         AND    ra.status = 'ACC'
			 AND    ra.display = 'Y'); -- Fix 1178963
--
   exception
       when no_data_found then
           l_on_account_count_total := 0;
       when others then
           raise;
   End;
    --
    /* jbeckett 04-apr-01 following query added for deductions */
    --
    -- Get the receipt count for receipts that are under claim investigation.
    --
    -- Bug 1811239 - only receipts totally applied to claim investigation


   l_break_point := '4th SELECT';
   --
   Begin
   --
 --Bug 2645671-Show the count only when the whole receipt is applied to claim
-- Bug 3590163: disabled index on applied_payment_schedule_id

   SELECT   nvl(count(cr.cash_receipt_id), 0)
   INTO     l_claim_count_total
   FROM     ar_cash_receipts cr,
            ar_cash_receipt_history crh
   WHERE    crh.cash_receipt_id = cr.cash_receipt_id
   AND      crh.first_posted_record_flag = 'Y'
   AND      crh.batch_id = p_batch_id
   AND      cr.amount = (SELECT
                         sum(ra.amount_applied)
                         FROM   ar_receivable_applications ra
                         WHERE  ra.cash_receipt_id = cr.cash_receipt_id
                         AND    ra.status = 'OTHER ACC'
                         AND    ra.applied_payment_schedule_id + 0 = -4
			 AND    ra.display = 'Y');
--
   exception
       when no_data_found then
           l_claim_count_total := 0;
       when others then
           raise;
   End;

   l_break_point := '5th SELECT';
   --
   Begin
   --
 --Bug 2645671-Show the count only when the whole receipt is applied to prepayment
-- Bug 3590163: disabled index on applied_payment_schedule_id

   SELECT   nvl(count(cr.cash_receipt_id), 0)
   INTO     l_prepayment_count_total
   FROM     ar_cash_receipts cr,
            ar_cash_receipt_history crh
   WHERE    crh.cash_receipt_id = cr.cash_receipt_id
   AND      crh.first_posted_record_flag = 'Y'
   AND      crh.batch_id = p_batch_id
   AND      cr.amount = (SELECT
                         sum(ra.amount_applied)
                         FROM   ar_receivable_applications ra
                         WHERE  ra.cash_receipt_id = cr.cash_receipt_id
                         AND    ra.status = 'OTHER ACC'
                         AND    ra.applied_payment_schedule_id + 0 = -7
			 AND    ra.display = 'Y');
--
   exception
       when no_data_found then
           l_prepayment_count_total := 0;
       when others then
           raise;
   end;
       --
       --
    -- Copy local valued to OUT NOCOPY pacrmeters
    --
    p_actual_amount_total := l_actual_amount_total;
    p_actual_count_total := l_actual_count_total;
    --
    p_applied_amount_total := l_applied_amount_total;
    --  Bug #443266
    --  Reduced the value by l_on_account_count_total, as
    --  p_applied_count_total also shows the fully on-account receipts.
    --
    p_applied_count_total := (l_applied_count_total - l_on_account_count_total
                                                    - l_claim_count_total);
    --
    p_unapplied_amount_total := l_unapplied_amount_total;
    p_unapplied_count_total := l_unapplied_count_total;
    --
    p_on_account_amount_total := l_on_account_amount_total;
    --  Bug #443266
    --  Earlier p_on_account_count_total was assigned value zero,
    --  Now it shows the count of fully on-account receipts.
    p_on_account_count_total := l_on_account_count_total;
    --
    p_claim_amount_total := l_claim_amount_total;
    p_claim_count_total := l_claim_count_total;
    --
    p_prepayment_amount_total := l_prepayment_amount_total;
    p_prepayment_count_total := l_prepayment_count_total;
    --
    p_misc_amount_total := l_misc_amount_total;
    p_misc_count_total := l_misc_count_total;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rw_batches_check_pkg.get_reg_amount_totals()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('get_reg_amount_totals: ' ||
                 'EXCEPTION: arp_rw_batches_check_pkg.get_reg_amount_totals '||
                             l_break_point );
              END IF;
              RAISE;
              --
END get_reg_amount_totals;

END ARP_RW_BATCHES_CHECK_PKG;

/
