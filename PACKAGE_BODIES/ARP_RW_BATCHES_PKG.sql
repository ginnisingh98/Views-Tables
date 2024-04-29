--------------------------------------------------------
--  DDL for Package Body ARP_RW_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RW_BATCHES_PKG" AS
/* $Header: ARERBATB.pls 120.13.12010000.2 2009/08/25 05:58:20 nproddut ship $ */
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


PROCEDURE validate_args_insert_manual(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_type IN ar_batches.type%TYPE,
        p_batch_source_id IN ar_batches.batch_source_id%TYPE,
        p_set_of_books_id IN ar_batches.set_of_books_id%TYPE,
        p_name IN ar_batches.name%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_batch_applied_status IN ar_batches.batch_applied_status%TYPE,
        p_auto_batch_numbering IN ar_batch_sources.auto_batch_numbering%TYPE);
--
PROCEDURE validate_args_insert_remit(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_type IN ar_batches.type%TYPE,
        p_set_of_books_id IN ar_batches.set_of_books_id%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_remit_method_code IN ar_batches.remit_method_code%TYPE,
        p_remittance_bank_branch_id IN
                       ar_batches.remittance_bank_branch_id%TYPE,
        p_batch_applied_status IN ar_batches.batch_applied_status%TYPE );
--
PROCEDURE validate_args_insert_auto(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_type IN ar_batches.type%TYPE,
        p_set_of_books_id IN ar_batches.set_of_books_id%TYPE,
        p_name IN ar_batches.name%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_receipt_class_id IN
                       ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN
                       ar_batches.receipt_method_id%TYPE,
        p_batch_applied_status IN ar_batches.batch_applied_status%TYPE );
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_manual_batch - Insert a row  AR_BATCHES table after checking for|
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row in AR_BATCHES table after checking for     |
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
 |         check_unique_media_ref procedures                                 |
 |                                                                           |
 | MODIFICATION HISTORY -  07/12/95 - Created by Ganesh Vaidee	     	     |
 | 19-MAR-96	Simon Leung	Set batch status to 'NB' for new batch.      |
 +===========================================================================*/
PROCEDURE insert_manual_batch(
        p_row_id IN OUT NOCOPY VARCHAR2,
        p_batch_type IN VARCHAR2,
        p_batch_id IN OUT NOCOPY ar_batches.batch_id%TYPE,
        p_batch_source_id IN ar_batches.batch_source_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_name IN OUT NOCOPY ar_batches.name%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_control_amount IN ar_batches.control_amount%TYPE,
        p_control_count IN ar_batches.control_count%TYPE,
        p_deposit_date IN ar_batches.deposit_date%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                   IN ar_batches.remit_bank_acct_use_id%TYPE,
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
        p_batch_applied_status OUT NOCOPY ar_batches.batch_applied_status%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2 ) IS
--
l_batch_rec  ar_batches%ROWTYPE;
l_auto_batch_numbering  ar_batch_sources.auto_batch_numbering%TYPE;
l_request_id            ar_batches.request_id%TYPE;
l_batch_applied_status  ar_batches.batch_applied_status%TYPE;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('validate_args_insert_manual: ' ||  'arp_rw_batches_pkg.insert_manual_batch()+' );
       arp_util.debug('validate_args_insert_manual: ' ||  'Row Id            : '||p_row_id );
       arp_util.debug('validate_args_insert_manual: ' ||  'Batch Id          : '||p_batch_id );
       arp_util.debug('validate_args_insert_manual: ' ||  'Batch Source Id   : '||TO_CHAR( p_batch_source_id ) );
       arp_util.debug('validate_args_insert_manual: ' ||  'Batch Name        : '||p_name );
       arp_util.debug('validate_args_insert_manual: ' ||  'GL Date           : '||p_gl_date );
    END IF;
    --
    -- Populate local batch record to be passed onto insert table handler
    --
    l_batch_rec.type := 'MANUAL';
    l_batch_rec.status := 'NB';
    --
    IF ( p_batch_type = 'MANUAL_REGULAR' ) THEN
        l_batch_rec.batch_applied_status := 'PROCESSED';
    ELSE
        l_batch_rec.batch_applied_status := 'POSTBATCH_WAITING';
    END IF;
    --
    l_batch_rec.batch_date := p_batch_date;
    l_batch_rec.batch_source_id := p_batch_source_id;
    l_batch_rec.set_of_books_id := arp_global.set_of_books_id;
    l_batch_rec.currency_code := p_currency_code;
    l_batch_rec.name := p_name;
    l_batch_rec.comments := p_comments;
    l_batch_rec.control_amount := p_control_amount;
    l_batch_rec.control_count := p_control_count;
    l_batch_rec.deposit_date := p_deposit_date;
    l_batch_rec.exchange_date := p_exchange_date;
    l_batch_rec.exchange_rate := p_exchange_rate;
    l_batch_rec.exchange_rate_type := p_exchange_rate_type;
    l_batch_rec.gl_date := p_gl_date;
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
    -- Get the batch numbering type from AR_BATCH_SOURCES
    --
    SELECT auto_batch_numbering
    INTO l_auto_batch_numbering
    FROM ar_batch_sources
    WHERE batch_source_id = l_batch_rec.batch_source_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('validate_args_insert_manual: ' ||  'Auto Batch Num    : '||l_auto_batch_numbering );
    END IF;
    --
    -- Make sure that the row_id is null and a batch type is passed in
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_insert_manual( p_row_id,
				   l_batch_rec.batch_id,
				   l_batch_rec.type,
				   l_batch_rec.batch_source_id,
                                   l_batch_rec.set_of_books_id,
				   l_batch_rec.name,
                                   l_batch_rec.currency_code,
				   l_batch_rec.gl_date,
				   l_batch_rec.batch_date,
                                   l_batch_rec.batch_applied_status,
				   l_auto_batch_numbering );
    END IF;
    --
    -- If automatic batch numbering is set to ON, then get the next
    -- batch name from LAST_BATCH_NUM  from AR_BATCH_SOURCES
    --
    IF ( l_auto_batch_numbering = 'AUTOMATIC' ) THEN
        UPDATE ar_batch_sources
        SET last_batch_num = NVL( LAST_BATCH_NUM, 0 ) + 1
        WHERE batch_source_id = l_batch_rec.batch_source_id;
        --
        IF ( SQL%ROWCOUNT = 0 ) THEN
            FND_MESSAGE.set_name( 'AR', 'AR_UPDNA_LAST_BATCH_NO' );
            APP_EXCEPTION.raise_exception;
       END IF;
       --
       SELECT NVL( LAST_BATCH_NUM, 0 )
       INTO   l_batch_rec.name
       FROM   ar_batch_sources
       WHERE  batch_source_id = l_batch_rec.batch_source_id;
       --
       p_name := l_batch_rec.name;
    ELSE
       l_batch_rec.name := p_name;
    END IF;
    --
    -- Check for valid GL date
    --
    arp_util.validate_gl_date( l_batch_rec.gl_date,
                               NULL, NULL );
    --
    --
    -- Call Check Unique Batch Name is unique for a given batch source id
    --
    arp_rw_batches_check_pkg.check_unique_batch_name( p_row_id,
                                            l_batch_rec.batch_source_id,
				 	    l_batch_rec.name,
                                            NULL,
					    NULL );
    --
    --  Call insert table handler
    --
    arp_cr_batches_pkg.insert_p( l_batch_rec,
                                 p_row_id,
                                 p_batch_id );
    --
    -- Populate output batch applied status
    --
    p_batch_applied_status := l_batch_rec.batch_applied_status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('validate_args_insert_manual: ' ||  'arp_rw_batches_pkg.insert_manual_batch()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('validate_args_insert_manual: ' ||  'EXCEPTION: arp_rw_batches_pkg.insert_manual_batch' );
             END IF;
             RAISE;
END insert_manual_batch;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_insert_manual                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to insert_manual_batch procedure             |
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
PROCEDURE validate_args_insert_manual(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_type IN ar_batches.type%TYPE,
        p_batch_source_id IN ar_batches.batch_source_id%TYPE,
        p_set_of_books_id IN ar_batches.set_of_books_id%TYPE,
        p_name IN ar_batches.name%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
	p_gl_date IN ar_batches.gl_date%TYPE,
	p_batch_date IN ar_batches.batch_date%TYPE,
	p_batch_applied_status IN ar_batches.batch_applied_status%TYPE,
        p_auto_batch_numbering IN ar_batch_sources.auto_batch_numbering%TYPE) IS
l_field	VARCHAR2(30);
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_insert_manual()+' );
    END IF;
    --
    IF ( p_row_id IS NOT NULL ) THEN
       l_field := 'ROW_ID';
    ELSIF ( p_batch_id IS NOT NULL ) THEN
       l_field := 'BATCH_ID';
    ELSIF ( p_type IS NULL ) THEN
       l_field := 'TYPE';
    ELSIF ( p_set_of_books_id IS NULL ) THEN
       l_field := 'SET_OF_BOOKS_ID';
    ELSIF ( p_batch_date IS NULL ) THEN
       l_field := 'BATCH_DATE';
    ELSIF ( p_batch_applied_status IS NULL ) THEN
       l_field := 'BATCH_APPLIED_STATUS';
    ELSE
       l_field := NULL;
    END IF;
    --
    IF ( p_auto_batch_numbering = 'AUTOMATIC' ) THEN
        IF ( p_name IS NOT NULL ) THEN
           l_field := 'NAME';
        END IF;
    ELSE
        IF ( p_name IS NULL ) THEN
           l_field := 'NAME';
        END IF;
    END IF;
    --
    IF ( l_field IS NOT NULL ) THEN
          FND_MESSAGE.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          FND_MESSAGE.set_token('PROCEDURE', 'VALIDATE_ARGS_INSERT_MANUAL');
          FND_MESSAGE.set_token('PARAMETER', l_field);
          APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_insert_manual()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('validate_args_insert_manual: ' ||
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_insert_manual' );
              END IF;
              RAISE;
END validate_args_insert_manual;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_auto_batch   - Insert a row  AR_BATCHES table after checking for|
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row in AR_BATCHES table after checking for     |
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
 |         check_unique_media_ref procedures                                 |
 |                                                                           |
 | MODIFICATION HISTORY -  07/12/95 - Created by Ganesh Vaidee	     	     |
 | 09-FEB-96 Simon Leung	If confirm is required, gl_date should be    |
 |                              null.                                        |
 | 16-DEC-03 K Mahajan          Added Batch-related validations to the       |
 |                              insert_auto_batch procedure as part          |
 |                              of the changes for bug 3167260               |
 +===========================================================================*/
PROCEDURE insert_auto_batch(
        p_row_id IN OUT NOCOPY VARCHAR2,
        p_batch_id IN OUT NOCOPY ar_batches.batch_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_name IN OUT NOCOPY ar_batches.name%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_media_reference IN ar_batches.media_reference%TYPE,
        p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
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
        p_call_conc_req IN VARCHAR2,
        p_batch_applied_status OUT NOCOPY ar_batches.batch_applied_status%TYPE,
        p_request_id OUT NOCOPY ar_batches.request_id%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
        p_bank_account_low IN VARCHAR2,
        p_bank_account_high IN VARCHAR2 ) IS
--
l_batch_rec  ar_batches%ROWTYPE;
l_batch_applied_status ar_batches.batch_applied_status%TYPE;
l_request_id ar_batches.request_id%TYPE;
l_confirm_required VARCHAR2(1);
CURSOR	c_receipt_class IS
        SELECT	confirm_flag
	FROM	ar_receipt_classes
        WHERE	receipt_class_id = p_receipt_class_id;

CURSOR  c_valid_receipt_class IS
        SELECT  rc.receipt_class_id
        FROM    ar_receipt_classes rc
        WHERE   rc.receipt_class_id = l_batch_rec.receipt_class_id
        AND     rc.creation_method_code = 'AUTOMATIC';


CURSOR  c_valid_receipt_method IS
        SELECT  rm.receipt_method_id
        FROM    ar_receipt_methods rm
        WHERE   rm.receipt_method_id = l_batch_rec.receipt_method_id
        AND     rm.receipt_class_id = l_batch_rec.receipt_class_id
        AND     l_batch_rec.batch_date between rm.start_date and nvl(rm.end_date, l_batch_rec.batch_date)
        AND EXISTS (SELECT 1
                FROM    ar_receipt_method_accounts rma,
                        ce_bank_accounts cba,
                        ce_bank_acct_uses ba
                WHERE   rma.receipt_method_id = l_batch_rec.receipt_method_id
                AND     rma.remit_bank_acct_use_id = ba.bank_acct_use_id
                AND     cba.bank_account_id = ba.bank_account_id
                AND     cba.currency_code = decode( cba.receipt_multi_currency_flag, 'Y', cba.currency_code,l_batch_rec.currency_code)
                AND     l_batch_rec.batch_date <= nvl(ba.end_date, l_batch_rec.batch_date)
                AND     l_batch_rec.batch_date between rma.start_date and nvl(rma.end_date, l_batch_rec.batch_date));

  l_valid               NUMBER;
  l_func_curr_code      VARCHAR2(15);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.insert_auto_batch()+' );
       arp_util.debug('insert_auto_batch: ' ||  'Row Id            : '||p_row_id );
       arp_util.debug('insert_auto_batch: ' ||  'Batch Id          : '||p_batch_id );
       arp_util.debug('insert_auto_batch: ' ||  'GL Date           : '||p_gl_date );
       arp_util.debug('insert_auto_batch: ' ||  'Bank_account_low  : '||p_bank_account_low );
       arp_util.debug('insert_auto_batch: ' ||  'Bank_account_high : '||p_bank_account_high );
    END IF;

    --
    -- Populate local batch record to be passed onto insert table handler
    --
    l_batch_rec.type := 'CREATION';
    l_batch_rec.batch_applied_status := 'STARTED_CREATION';
    l_batch_rec.batch_date := p_batch_date;
    l_batch_rec.set_of_books_id := arp_global.set_of_books_id;
    l_batch_rec.currency_code := p_currency_code;
    l_batch_rec.comments := p_comments;
    l_batch_rec.exchange_date := p_exchange_date;
    l_batch_rec.exchange_rate := p_exchange_rate;
    l_batch_rec.exchange_rate_type := p_exchange_rate_type;
    l_batch_rec.gl_date := p_gl_date;
    l_batch_rec.media_reference := p_media_reference;
    -- l_batch_rec.operation_request_id := FND_GLOBAL.request_id;
    l_batch_rec.receipt_class_id := p_receipt_class_id;
    l_batch_rec.receipt_method_id := p_receipt_method_id;
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
    -- Make sure that the row_id is null and a batch type is passed in
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_insert_auto( p_row_id,
				   l_batch_rec.batch_id,
				   l_batch_rec.type,
                                   l_batch_rec.set_of_books_id,
				   l_batch_rec.name,
                                   l_batch_rec.currency_code,
				   l_batch_rec.batch_date,
				   l_batch_rec.receipt_class_id,
				   l_batch_rec.receipt_method_id,
                                   l_batch_rec.batch_applied_status );
    END IF;
    --
    OPEN c_receipt_class;
    FETCH c_receipt_class INTO l_confirm_required;
    CLOSE c_receipt_class;
    --

/* bug3451722 */
        IF ( l_confirm_required = 'Y' and p_module_name = 'AUTORECSRS') THEN
                    l_batch_rec.gl_date := null;
        END IF;
    IF (l_confirm_required = 'Y') THEN
	--bug 5465097
	l_batch_rec.gl_date := null;
    ELSE
       -- Check for valid GL date
       --
       arp_util.validate_gl_date( l_batch_rec.gl_date,
                               NULL, NULL );
    END IF;

    -- check Receipt Class ID is valid
    if (l_batch_rec.receipt_class_id is not null) then
        open c_valid_receipt_class;
        fetch c_valid_receipt_class into l_valid;
        if c_valid_receipt_class%NOTFOUND then
          close c_valid_receipt_class;
          fnd_message.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          fnd_message.set_token('PROCEDURE', 'INSERT_AUTO_BATCH');
          fnd_message.set_token('PARAMETER', 'RECEIPT_CLASS_ID' );
          app_exception.raise_exception;
        end if;
        close c_valid_receipt_class;
    end if;

    -- check Receipt Payment Method ID is valid
    if (l_batch_rec.receipt_method_id is not null) then
        open c_valid_receipt_method;
        fetch c_valid_receipt_method into l_valid;
        if c_valid_receipt_method%NOTFOUND then
          close c_valid_receipt_method;
          fnd_message.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          fnd_message.set_token('PROCEDURE', 'INSERT_AUTO_BATCH');
          fnd_message.set_token('PARAMETER', 'RECEIPT_METHOD_ID' );
          app_exception.raise_exception;
        end if;
        close c_valid_receipt_method;
    end if;

    -- check if Exchange Rates are required and derive them, if needed
    l_func_curr_code := arpcurr.getfunctcurr(l_batch_rec.set_of_books_id);
    if (l_func_curr_code <> l_batch_rec.currency_code) then
        if (l_batch_rec.exchange_date is null) then
            l_batch_rec.exchange_date := l_batch_rec.batch_date;
        end if;
        if (l_batch_rec.exchange_rate_type is null) then
            l_batch_rec.exchange_rate_type := fnd_profile.value('AR_DEFAULT_EXCHANGE_RATE_TYPE');
        end if;
        if (l_batch_rec.exchange_rate is null) then
            l_batch_rec.exchange_rate := arpcurr.getrate(l_batch_rec.currency_code,
                        l_func_curr_code, l_batch_rec.exchange_date, l_batch_rec.exchange_rate_type);
            if ( gl_currency_api.is_fixed_rate(l_batch_rec.currency_code,
                        l_func_curr_code, l_batch_rec.exchange_date) = 'Y') then                l_batch_rec.exchange_rate_type := 'EMU FIXED';
            end if;
        end if;
        if (nvl(l_batch_rec.exchange_rate, -1) = -1) then
            fnd_message.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
            fnd_message.set_token('PROCEDURE', 'INSERT_AUTO_BATCH');
            fnd_message.set_token('PARAMETER', 'EXCHANGE_RATE(_TYPE)' );
            app_exception.raise_exception;
        end if;
    end if;

    --
    -- Call Check Unique Media Reference procedure, if the Batch Type is
    -- not 'MANUAL' and media reference is not NULL
    --
    IF ( l_batch_rec.media_reference IS NOT NULL ) THEN
        arp_rw_batches_check_pkg.check_unique_media_ref( p_row_id,
                                             l_batch_rec.media_reference,
                                             NULL, NULL );
    END IF;
    --
    -- IF type is not manual, then set batch_source_id to 1 and
    -- get the batch source name to populate the form field
    --
    l_batch_rec.batch_source_id := 1;
    --
    -- automatic batch numbering is set to ON, so get the next
    -- batch name from LAST_BATCH_NUM  from AR_BATCH_SOURCES
    --
    UPDATE ar_batch_sources
    SET last_batch_num = NVL( LAST_BATCH_NUM, 0 ) + 1
    WHERE batch_source_id = l_batch_rec.batch_source_id;
    --
    IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name( 'AR', 'AR_UPDNA_LAST_BATCH_NO' );
        APP_EXCEPTION.raise_exception;
    END IF;
       --
    SELECT NVL( LAST_BATCH_NUM, 0 )
    INTO   l_batch_rec.name
    FROM   ar_batch_sources
    WHERE  batch_source_id = l_batch_rec.batch_source_id;
    --
    p_name := l_batch_rec.name;
    --
    -- Call Check Unique Batch Name is unique for a given batch source id
    --
    arp_rw_batches_check_pkg.check_unique_batch_name( p_row_id,
                                            l_batch_rec.batch_source_id,
				 	    l_batch_rec.name,
                                            NULL,
					    NULL );
    --
    --  Call insert table handler
    --
    arp_cr_batches_pkg.insert_p( l_batch_rec,
                                 p_row_id,
                                 p_batch_id );
    --
    -- Call the concurrent program to create receipts under the batch,
    -- if the procedure is not called from BOE
    --
    --
    IF ( p_call_conc_req = 'Y' ) THEN
        arp_process_boe.create_auto_batch_conc_req(
          'Y',
          'N',
          'N',
          p_batch_id,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          l_request_id, l_batch_applied_status,
          p_module_name, p_module_version,
	  p_bank_account_low, p_bank_account_high );
        --
        -- Populate operation_request_id
        --
        arp_cr_batches_pkg.set_to_dummy( l_batch_rec );
        p_request_id := l_request_id;
        l_batch_rec.operation_request_id := l_request_id;
        arp_cr_batches_pkg.update_p( l_batch_rec, p_batch_id );
    END IF;
    --
    p_batch_applied_status := l_batch_applied_status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.insert_auto_batch()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug( 'EXCEPTION: arp_rw_batches_pkg.insert_auto_batch' );
             END IF;
             RAISE;
END insert_auto_batch;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_insert_auto                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to insert_auto_batch  procedure              |
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
PROCEDURE validate_args_insert_auto(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_type IN ar_batches.type%TYPE,
        p_set_of_books_id IN ar_batches.set_of_books_id%TYPE,
        p_name IN ar_batches.name%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
	p_batch_date IN ar_batches.batch_date%TYPE,
	p_receipt_class_id IN
                       ar_batches.receipt_class_id%TYPE,
	p_receipt_method_id IN
                       ar_batches.receipt_method_id%TYPE,
	p_batch_applied_status IN ar_batches.batch_applied_status%TYPE ) IS
l_field	VARCHAR2(30);
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_insert_auto()+' );
    END IF;
    --
    IF ( p_row_id IS NOT NULL ) THEN
       l_field := 'ROW_ID';
    ELSIF ( p_batch_id IS NOT NULL ) THEN
       l_field := 'BATCH_ID';
    ELSIF ( p_type IS NULL ) THEN
       l_field := 'TYPE';
    ELSIF ( p_set_of_books_id IS NULL ) THEN
       l_field := 'SET_OF_BOOKS_ID';
    ELSIF ( p_currency_code IS NULL ) THEN
       l_field := 'CURRENCY_CODE';
    ELSIF ( p_batch_date IS NULL ) THEN
       l_field := 'BATCH_DATE';
    ELSIF ( p_batch_applied_status IS NULL ) THEN
       l_field := 'BATCH_APPLIED_STATUS';
    ELSIF ( p_receipt_class_id IS NULL ) THEN
       l_field := 'RECEIPT_CLASS_ID';
    ELSIF ( p_receipt_method_id IS NULL ) THEN
       l_field := 'RECEIPT_METHOD_ID';
    ELSE
       l_field := NULL;
    END IF;
    --
    IF ( l_field IS NOT NULL ) THEN
       FND_MESSAGE.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
       FND_MESSAGE.set_token('PROCEDURE', 'VALIDATE_ARGS_INSERT_AUTO');
       FND_MESSAGE.set_token('PARAMETER', l_field );
       APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_insert_auto()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('validate_args_insert_auto: ' ||
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_insert_auto' );
              END IF;
              RAISE;
END validate_args_insert_auto;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_remit_batch -  Insert a row  AR_BATCHES table after checking for|
 |                    uniqueness                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row in AR_BATCHES table after checking for     |
 |    uniqueness for items such as NAME, MEDIA_REFERENCE, GL_DATE            |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_util.debug - debug procedure                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                     				     |
 |                 p_row_id - Row ID                                         |
 |                 p_batch_name  - Batch Name                                |
 |                 p_module_name - Module that called this procedure         |
 |                 p_module_version - Version of the module that called this |
 |                                    procedure                              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                    				     |
 |                                                                           |
 | NOTES - This procedure calls the check_unique_batch_name and              |
 |         check_unique_media_ref procedures                                 |
 |                                                                           |
 | MODIFICATION HISTORY -  07/12/95 - Created by Ganesh Vaidee	     	     |
 | 25-JAN-96 Simon Leung	Implemented logic to set batch_applied_status|
 |				for auto-creation and manual-creation batch  |
 |				Removed logic to submit conc req process.    |
 | 09-FEB-96 Simon Leung	If the bank is a clearing house, no remit    |
 |				bank account should be specified.            |
 | 13-MAY-96 Simon Leung        Added new parameter receipt_class_id.        |
 | 16-DEC-03 K Mahajan          Added validations for Auto-Remit SRS program |
 |                              as part of the fix for bug / enh. 3167260    |
 | 12-JAN-04 M Ryzhikova        Modified fix for 3157260 to incorporate      |
 |                              consolidated bank accounts changes           |
 +===========================================================================*/
PROCEDURE insert_remit_batch(
        p_row_id IN OUT NOCOPY VARCHAR2,
        p_batch_id IN OUT NOCOPY ar_batches.batch_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_name IN OUT NOCOPY ar_batches.name%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_media_reference IN ar_batches.media_reference%TYPE,
        p_remit_method_code IN ar_batches.remit_method_code%TYPE,
        p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                   IN ar_batches.remit_bank_acct_use_id%TYPE,
        p_remittance_bank_branch_id
                   IN ar_batches.remittance_bank_branch_id%TYPE,
        p_bank_deposit_number IN ar_batches.bank_deposit_number%TYPE,
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
        p_auto_creation IN VARCHAR2,
        p_batch_applied_status OUT NOCOPY ar_batches.batch_applied_status%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2 ) IS
--
l_batch_rec  ar_batches%ROWTYPE;
l_institution_type	VARCHAR2(30);
CURSOR  c_bank_branches	IS
        SELECT	bank_institution_type
        FROM	ce_bank_branches_v
        WHERE	branch_party_id = p_remittance_bank_branch_id;

CURSOR  c_valid_receipt_class IS
        SELECT  rc.receipt_class_id
        FROM    ar_receipt_classes rc
        WHERE   rc.receipt_class_id = l_batch_rec.receipt_class_id
        AND     rc.remit_flag = 'Y'
        AND     rc.creation_method_code not in ('BR','BR_REMIT')
        AND     (rc.remit_method_code = l_batch_rec.remit_method_code
          OR     rc.remit_method_code = 'STANDARD_AND_FACTORING');

CURSOR  c_valid_receipt_method IS
        SELECT  rm.receipt_method_id
        FROM    ar_receipt_methods rm
        WHERE   rm.receipt_method_id = l_batch_rec.receipt_method_id
        AND     rm.receipt_class_id = l_batch_rec.receipt_class_id
        AND     l_batch_rec.batch_date between rm.start_date and nvl(rm.end_date, l_batch_rec.batch_date);


CURSOR  c_valid_bank_branch  IS
        SELECT  distinct bb.branch_party_id
        FROM    ce_bank_branches_v bb
        WHERE   bb.branch_party_id = l_batch_rec.remittance_bank_branch_id
        AND     ( bb.branch_party_id in
                       (SELECT cba.bank_branch_id
                        FROM    ce_bank_accounts cba,
                                ce_bank_acct_uses ba
                        WHERE   cba.bank_account_id = ba.bank_account_id
                        AND ba.bank_acct_use_id =l_batch_rec.remit_bank_acct_use_id)
                AND l_batch_rec.remit_bank_acct_use_id is not null)
          OR    (bb.bank_institution_type = 'CLEARING HOUSE'
                AND l_batch_rec.remit_bank_acct_use_id is null
                AND EXISTS (SELECT 1
                        FROM    ar_receipt_method_accounts rma2,
                                ce_bank_accounts cba2,
                                ce_bank_acct_uses ba2,
                                ce_bank_branches_v bb2,
                                hz_parties CHParty,
                                hz_parties RelParty,
                                hz_relationships BCRel,
                                hz_contact_points Eft
                        WHERE   rma2.receipt_method_id = l_batch_rec.receipt_method_id
                        AND     rma2.remit_bank_acct_use_id = ba2.bank_acct_use_id
                        AND     cba2.bank_account_id = ba2.bank_account_id
                        AND     cba2.currency_code = l_batch_rec.currency_code
                        AND     cba2.bank_branch_id = bb2.branch_party_id
                        AND   BCRel.subject_id = bb2.branch_party_id
                        AND    BCRel.subject_type = 'ORGANIZATION'
                        AND    BCRel.subject_table_name = 'HZ_PARTIES'
                        AND    BCRel.object_id = CHParty.party_id
                        AND    BCRel.object_type = 'ORGANIZATION'
                        AND    BCRel.object_table_name = 'HZ_PARTIES'
                        AND    BCRel.relationship_type = 'CLEARINGHOUSE_BANK'
                        AND    BCRel.relationship_code = 'USES_CLEARINGHOUSE'
                        AND    BCRel.status = 'A'
                        AND    RelParty.party_id = BCRel.party_id
                        AND    Eft.owner_table_name(+) = 'HZ_PARTIES'
                        AND    Eft.owner_table_id(+) = CHParty.party_id
                        AND    Eft.contact_point_type(+) = 'EFT'
                        AND    Eft.status(+) = 'A'
                        AND    CHParty.party_id = bb.branch_party_id));

CURSOR  c_valid_bank_account IS
        SELECT  ba.bank_acct_use_id
        FROM    ce_bank_accounts cba,
                ce_bank_acct_uses ba,
                ce_bank_branches_v br,
                ar_receipt_method_accounts rma
        WHERE   ba.bank_acct_use_id = l_batch_rec.remit_bank_acct_use_id
        AND     rma.receipt_method_id = nvl(l_batch_rec.receipt_method_id, rma.receipt_method_id)
        AND     rma.remit_bank_acct_use_id = ba.bank_acct_use_id
        AND     cba.bank_account_id = ba.bank_account_id
        AND     cba.bank_branch_id = l_batch_rec.remittance_bank_branch_id
        AND     cba.bank_branch_id = br.branch_party_id
        AND     (cba.currency_code = l_batch_rec.currency_code
          OR     cba.receipt_multi_currency_flag = 'Y')
        AND     l_batch_rec.batch_date <= nvl(ba.end_date, l_batch_rec.batch_date)
        AND     l_batch_rec.batch_date between rma.start_date and nvl(rma.end_date, l_batch_rec.batch_date);

  l_valid               NUMBER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.insert_remit_batch()+' );
       arp_util.debug('insert_remit_batch: ' ||  'Row Id            : '||p_row_id );
       arp_util.debug('insert_remit_batch: ' ||  'Batch Id          : '||p_batch_id );
       arp_util.debug('insert_remit_batch: ' ||  'GL Date           : '||p_gl_date );
    END IF;
    --
    -- Populate local batch record to be passed onto insert table handler
    --
    l_batch_rec.type := 'REMITTANCE';
    --
    -- For automatic creation, set status to STARTED_CREATION and let
    -- the concurrent process set the status to COMPLETED_CREATION when
    -- it finishes.  For manual creation, set it to COMPLETED_CREATION.
    --
    IF ( p_auto_creation = 'Y' ) THEN
       l_batch_rec.batch_applied_status := 'STARTED_CREATION';
    ELSE
       l_batch_rec.batch_applied_status := 'COMPLETED_CREATION';
    END IF;
    --
    l_batch_rec.batch_date := p_batch_date;
    l_batch_rec.set_of_books_id := arp_global.set_of_books_id;
    l_batch_rec.currency_code := p_currency_code;
    l_batch_rec.comments := p_comments;
    l_batch_rec.exchange_date := p_exchange_date;
    l_batch_rec.exchange_rate := p_exchange_rate;
    l_batch_rec.exchange_rate_type := p_exchange_rate_type;
    l_batch_rec.gl_date := p_gl_date;
    l_batch_rec.media_reference := p_media_reference;
    l_batch_rec.remit_method_code := p_remit_method_code;
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
    l_batch_rec.bank_deposit_number := p_bank_deposit_number;
    --
    -- Make sure that the row_id is null and a batch type is passed in
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_args_insert_remit( p_row_id,
				   l_batch_rec.batch_id,
				   l_batch_rec.type,
                                   l_batch_rec.set_of_books_id,
                                   l_batch_rec.currency_code,
				   l_batch_rec.gl_date,
				   l_batch_rec.batch_date,
				   l_batch_rec.remit_method_code,
				   l_batch_rec.remittance_bank_branch_id,
                                   l_batch_rec.batch_applied_status );
    END IF;
    --
    OPEN c_bank_branches;
    FETCH c_bank_branches INTO l_institution_type;
    CLOSE c_bank_branches;
    --
    IF ( l_institution_type = 'CLEARING HOUSE' ) THEN
       IF ( l_batch_rec.remit_bank_acct_use_id IS NOT NULL ) THEN
          FND_MESSAGE.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          FND_MESSAGE.set_token('PROCEDURE', 'INSERT_REMIT_BATCH');
          FND_MESSAGE.set_token('PARAMETER', 'REMITTANCE_BANK_ACCOUNT_ID' );
          APP_EXCEPTION.raise_exception;
       END IF;
    ELSIF (l_batch_rec.remit_bank_acct_use_id IS NULL) THEN
          FND_MESSAGE.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          FND_MESSAGE.set_token('PROCEDURE', 'INSERT_REMIT_BATCH');
          FND_MESSAGE.set_token('PARAMETER', 'REMITTANCE_BANK_ACCOUNT_ID' );
          APP_EXCEPTION.raise_exception;
    END IF;
    -- Check for valid GL date
    --
    arp_util.validate_gl_date( l_batch_rec.gl_date,
                               NULL, NULL );


    -- check Receipt Class ID is valid
    if (l_batch_rec.receipt_class_id is not null) then
        open c_valid_receipt_class;
        fetch c_valid_receipt_class into l_valid;
        if c_valid_receipt_class%NOTFOUND then
          close c_valid_receipt_class;
          fnd_message.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          fnd_message.set_token('PROCEDURE', 'INSERT_REMIT_BATCH');
          fnd_message.set_token('PARAMETER', 'RECEIPT_CLASS_ID' );
          app_exception.raise_exception;
        end if;
        close c_valid_receipt_class;
    end if;

    -- check Receipt Payment Method ID is valid
    if (l_batch_rec.receipt_method_id is not null) then
        open c_valid_receipt_method;
        fetch c_valid_receipt_method into l_valid;
        if c_valid_receipt_method%NOTFOUND then
          close c_valid_receipt_method;
          fnd_message.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          fnd_message.set_token('PROCEDURE', 'INSERT_REMIT_BATCH');
          fnd_message.set_token('PARAMETER', 'RECEIPT_METHOD_ID' );
          app_exception.raise_exception;
        end if;
        close c_valid_receipt_method;
    end if;

    -- check Bank Branch ID is valid
    if (l_batch_rec.remittance_bank_branch_id is not null) then
        open c_valid_bank_branch ;
        fetch c_valid_bank_branch into l_valid;
        if c_valid_bank_branch%NOTFOUND then
          close c_valid_bank_branch;
          fnd_message.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          fnd_message.set_token('PROCEDURE', 'INSERT_REMIT_BATCH');
          fnd_message.set_token('PARAMETER', 'BANK_BRANCH_ID' );
          app_exception.raise_exception;
        end if;
        close c_valid_bank_branch;
    end if;

    -- check Bank Account ID is valid
    if (l_batch_rec.remit_bank_acct_use_id is not null) then
        open c_valid_bank_account;
        fetch c_valid_bank_account into l_valid;
        if c_valid_bank_account%NOTFOUND then
          close c_valid_bank_account;
          fnd_message.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
          fnd_message.set_token('PROCEDURE', 'INSERT_REMIT_BATCH');
          fnd_message.set_token('PARAMETER', 'BANK_ACCOUNT_ID' );
          app_exception.raise_exception;
        end if;
        close c_valid_bank_account;
    end if;


    --
    -- Call Check Unique Media Reference procedure, if the Batch Type is
    -- not 'MANUAL' and media reference is not NULL
    --
    IF ( l_batch_rec.media_reference IS NOT NULL ) THEN
        arp_rw_batches_check_pkg.check_unique_media_ref( p_row_id,
                                             l_batch_rec.media_reference,
                                             NULL, NULL );
    END IF;
    --
    -- IF type is not manual, then set batch_source_id to 1 and
    -- get the batch source name to populate the form field
    --
    l_batch_rec.batch_source_id := 1;
    --
    -- automatic batch numbering is set to ON, so get the next
    -- batch name from LAST_BATCH_NUM  from AR_BATCH_SOURCES
    --
    UPDATE ar_batch_sources
    SET last_batch_num = NVL( LAST_BATCH_NUM, 0 ) + 1
    WHERE batch_source_id = l_batch_rec.batch_source_id;
    --
    IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name( 'AR', 'AR_UPDNA_LAST_BATCH_NO' );
        APP_EXCEPTION.raise_exception;
    END IF;
       --
    SELECT NVL( LAST_BATCH_NUM, 0 )
    INTO   l_batch_rec.name
    FROM   ar_batch_sources
    WHERE  batch_source_id = l_batch_rec.batch_source_id;
    --
    p_name := l_batch_rec.name;
    p_batch_applied_status := l_batch_rec.batch_applied_status;
    --
    -- Call Check Unique Batch Name is unique for a given batch source id
    --
    arp_rw_batches_check_pkg.check_unique_batch_name( p_row_id,
                                            l_batch_rec.batch_source_id,
				 	    l_batch_rec.name,
                                            NULL,
					    NULL );
    --
    --  Call insert table handler
    --
    arp_cr_batches_pkg.insert_p( l_batch_rec,
                                 p_row_id,
                                 p_batch_id );
    --
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.insert_remit_batch()-' );
    END IF;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug( 'EXCEPTION: arp_rw_batches_pkg.insert_remit_batch' );
             END IF;
             RAISE;
END insert_remit_batch;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_insert_remit                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to insert_remit_remit procedure              |
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
PROCEDURE validate_args_insert_remit(
        p_row_id  IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_type IN ar_batches.type%TYPE,
        p_set_of_books_id IN ar_batches.set_of_books_id%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
	p_gl_date IN ar_batches.gl_date%TYPE,
	p_batch_date IN ar_batches.batch_date%TYPE,
	p_remit_method_code IN ar_batches.remit_method_code%TYPE,
	p_remittance_bank_branch_id IN
                       ar_batches.remittance_bank_branch_id%TYPE,
	p_batch_applied_status IN ar_batches.batch_applied_status%TYPE ) IS
l_field	VARCHAR2(30);
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_insert_remit()+' );
    END IF;
    --
    IF ( p_row_id IS NOT NULL ) THEN
       l_field := 'ROW_ID';
    ELSIF ( p_batch_id IS NOT NULL ) THEN
       l_field := 'BATCH_ID';
    ELSIF ( p_type IS NULL ) THEN
       l_field := 'TYPE';
    ELSIF ( p_set_of_books_id IS NULL ) THEN
       l_field := 'SET_OF_BOOKS_ID';
    ELSIF ( p_currency_code IS NULL ) THEN
       l_field := 'CURRENCY_CODE';
    ELSIF ( p_gl_date IS NULL ) THEN
       l_field := 'GL_DATE';
    ELSIF ( p_batch_date IS NULL ) THEN
       l_field := 'BATCH_DATE';
    ELSIF ( p_batch_applied_status IS NULL ) THEN
       l_field := 'BATCH_APPLIED_STATUS';
    ELSIF ( p_remit_method_code IS NULL ) THEN
       l_field := 'REMIT_METHOD_CODE';
    ELSIF ( p_remittance_bank_branch_id IS NULL ) THEN
       l_field := 'REMITTANCE_BANK_BRANCH_ID';
    ELSIF ( p_remit_method_code IS NULL ) THEN
       l_field := 'REMIT_METHOD_CODE';
    ELSIF ( p_remittance_bank_branch_id IS NULL ) THEN
       l_field := 'REMITTANCE_BANK_BRANCH_ID';
    ELSE
       l_field := NULL;
    END IF;
    --
    IF ( l_field IS NOT NULL ) THEN
       FND_MESSAGE.set_name( 'AR', 'AR_PROCEDURE_VALID_ARGS_FAIL' );
       FND_MESSAGE.set_token('PROCEDURE', 'VALIDATE_ARGS_INSERT_REMIT');
       FND_MESSAGE.set_token('PARAMETER', l_field );
       APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug( 'arp_rw_batches_pkg.validate_args_insert_remit()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('validate_args_insert_remit: ' ||
		     'EXCEPTION: arp_rw_batches_pkg.validate_args_insert_remit' );
              END IF;
              RAISE;
END validate_args_insert_remit;
--
PROCEDURE delete_batch( p_batch_id IN ar_batches.batch_id%TYPE ) IS
l_id	NUMBER;
BEGIN
    -- lock the records.
    SELECT batch_id
    INTO   l_id
    FROM   ar_batches
    WHERE  batch_id = p_batch_id
    FOR UPDATE;

    -- detach the transactions assoicated with the batch and delete the batch.
    UPDATE ar_payment_schedules
    SET selected_for_receipt_batch_id = NULL
    WHERE selected_for_receipt_batch_id = p_batch_id;

    -- Call the table handler for ar_batches instead of doing delete here
    -- Bug: 2028370
    ARP_CR_BATCHES_PKG.delete_p(p_batch_id);

--    DELETE ar_batches
--    WHERE  batch_id = p_batch_id;

EXCEPTION
    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('EXCEPTION: arp_rw_batches_pkg.delete_batch');
         END IF;
         RAISE;
END delete_batch;


PROCEDURE default_batch_source_pay_mthds(p_batch_source_name IN OUT NOCOPY ar_batch_sources.name%TYPE,
                        p_batch_date         IN ar_batch_sources.start_date_active%TYPE,
                        p_batch_source_id IN OUT NOCOPY ar_batch_sources.batch_source_id%TYPE,
                        p_batch_number OUT NOCOPY ar_batch_sources.auto_batch_numbering%TYPE,
                        p_rec_class_id OUT NOCOPY ar_receipt_classes.receipt_class_id%TYPE,
                        p_rec_class_name OUT NOCOPY ar_receipt_classes.name%TYPE,
                        p_pay_method_id OUT NOCOPY ar_receipt_methods.receipt_method_id%TYPE,
                        p_pay_method_name OUT NOCOPY ar_receipt_methods.name%TYPE,
                        p_bank_name OUT NOCOPY ce_bank_branches_v.bank_name%TYPE,
                        p_bank_account_num OUT NOCOPY ce_bank_accounts.bank_account_num%TYPE,
                        p_bank_account_id OUT NOCOPY ce_bank_accounts.bank_account_id%TYPE,
                        p_currency_code IN OUT NOCOPY ce_bank_accounts.currency_code%TYPE,
                        p_bank_branch_name OUT NOCOPY ce_bank_branches_v.bank_branch_name%TYPE,
                        p_bank_branch_id   OUT NOCOPY ce_bank_accounts.bank_branch_id%TYPE,
                        p_override_remit_flag OUT NOCOPY ar_receipt_method_accounts.override_remit_account_flag%TYPE,
                        p_remit_flag OUT NOCOPY ar_receipt_classes.remit_flag%TYPE,
                        p_creation_status  OUT NOCOPY ar_receipt_classes.creation_status%TYPE,
                        p_meaning OUT NOCOPY ar_lookups.meaning%TYPE) IS

l_batch_source_id       ar_batch_sources.batch_source_id%TYPE;
l_batch_number          ar_batch_sources.auto_batch_numbering%TYPE;
l_rec_class_id          ar_receipt_classes.receipt_class_id%TYPE;
l_rec_class_name        ar_receipt_classes.name%TYPE;
l_pay_method_id         ar_receipt_methods.receipt_method_id%TYPE;
l_pay_method_name       ar_receipt_methods.name%TYPE;
l_bank_name             ce_bank_branches_v.bank_name%TYPE;
l_bank_account_num      ce_bank_accounts.bank_account_num%TYPE;
l_bank_account_id       ce_bank_accounts.bank_account_id%TYPE;
l_currency_code         ce_bank_accounts.currency_code%TYPE;
l_bank_branch_name      ce_bank_branches_v.bank_branch_name%TYPE;
l_bank_branch_id        ce_bank_accounts.bank_branch_id%TYPE;
l_override_remit_flag   ar_receipt_method_accounts.override_remit_account_flag%TYPE;
l_remit_flag            ar_receipt_classes.remit_flag%TYPE;
l_creation_status       ar_receipt_classes.creation_status%TYPE;
l_meaning               ar_lookups.meaning%TYPE;
l_num                   NUMBER;
--Bug fix 5647335 starts
l_default_org_id        NUMBER;
l_defaulted_flag        VARCHAR2(3);
l_org_id                NUMBER;
l_count                 NUMBER;
cursor c is
SELECT  bs.batch_source_id,
        bs.auto_batch_numbering,
        bs.default_receipt_class_id,
        bs.default_receipt_method_id,
        bs.default_remit_bank_account_id,
        bs.org_id
FROM    ar_batch_sources bs
WHERE   bs.name = p_batch_source_name
AND     bs.type <> 'AUTOMATIC'
AND     p_batch_date BETWEEN bs.start_date_active AND NVL(bs.end_date_active,p_batch_date);
BEGIN
                    l_rec_class_name:=NULL;
                    l_pay_method_name:=NULL;
                    l_bank_name:=NULL;
                    l_bank_account_num:=NULL;
                    l_bank_branch_name:=NULL;
                    l_bank_branch_id:=NULL;
                    l_creation_status:=NULL;
                    l_override_remit_flag:=NULL;
                    l_remit_flag:=NULL;
                    l_org_id := NULL;
                    l_default_org_id := fnd_profile.value('DEFAULT_ORG_ID');
                    l_defaulted_flag := 'N';
    IF PG_DEBUG IN ('Y', 'C') THEN
      arp_debug.debug('arp_rw_batches_pkg.default_batch_source_pay_mthds()+');
      arp_debug.debug(' default_org_id: ' || l_default_org_id);
      arp_debug.debug('  p_batch_source_name: ' ||  p_batch_source_name);
    END IF;
    /* Fetch Data from Default Batch Source */
    BEGIN
--Bug fix 5647335 starts
         FOR bsource in c LOOP
             IF(C%ROWCOUNT>1) THEN
                 l_defaulted_flag := 'N';
                 IF (l_default_org_id IS NULL) THEN
                  p_batch_source_name := NULL;
                  l_rec_class_id:=NULL;
                 ELSE
                  IF (l_org_id = l_default_org_id) THEN
                   l_defaulted_flag  := 'Y';
                   EXIT;
                  END IF;
                 END IF;
             END IF;
               l_batch_source_id := bsource.batch_source_id;
               l_batch_number    := bsource.auto_batch_numbering;
               l_rec_class_id    := bsource.default_receipt_class_id;
               l_pay_method_id   := bsource.default_receipt_method_id;
               l_bank_account_id := bsource.default_remit_bank_account_id;
               l_org_id          := bsource.org_id;
               l_defaulted_flag  := 'Y';
         END LOOP;
       IF (l_defaulted_flag <> 'Y') THEN
         p_batch_source_name:=NULL;
         l_rec_class_id:=NULL;
       END IF;
       IF PG_DEBUG IN ('Y', 'C') THEN
         arp_debug.debug(' l_batch_source_id: ' || l_batch_source_id);
         arp_debug.debug(' l_batch_number: '    || l_batch_number);
         arp_debug.debug(' l_rec_class_id: '    || l_rec_class_id);
         arp_debug.debug(' l_bank_account_id: ' || l_bank_account_id);
         arp_debug.debug(' l_pay_method_id: '   || l_pay_method_id);
         arp_debug.debug(' l_org_id: '          || l_org_id);
       END IF;
--Bug fix 5647335 ends
--Commenting out sql query as part of bug fix 5647335
       /*SELECT   bs.batch_source_id,
                bs.auto_batch_numbering,
                bs.default_receipt_class_id,
                bs.default_receipt_method_id,
                bs.default_remit_bank_account_id
                INTO l_batch_source_id,
                l_batch_number,
                l_rec_class_id,
                l_pay_method_id,
                l_bank_account_id
        FROM    ar_batch_sources bs
        WHERE   bs.name = p_batch_source_name
        AND     bs.type <> 'AUTOMATIC'
        AND     p_batch_date BETWEEN bs.start_date_active AND NVL(bs.end_date_active,p_batch_date);*/
   EXCEPTION
        /*WHEN NO_DATA_FOUND THEN
                p_batch_source_name:=NULL;
                l_rec_class_id:=NULL;
        WHEN TOO_MANY_ROWS THEN --Added for Bug:5477927
                p_batch_source_name := NULL;
                l_rec_class_id := NULL;*/
        WHEN OTHERS THEN
                p_batch_source_name:=NULL;
                l_rec_class_id:=NULL;
                RAISE;
    END;

    /* We can attach PM , Bank Account and RC to batch source
       or RC only or RC AND PM only
       1. If Bank Account is defaulted then first validate it
       2. IF PM is defaulted then validate as such atleast 1 bank account
          should exists for that PM.
       3. Then check for RC to be defaulted.
       4. else do not default RC. */

    /* Validating default Bank Account id */
    IF l_bank_account_id IS NOT NULL THEN
       BEGIN
          SELECT
             bb.bank_name,
             cba.bank_account_num,
             cba.currency_code,
             bb.bank_branch_name,
             bb.branch_party_id,
             rma.override_remit_account_flag
          INTO
             l_bank_name,
             l_bank_account_num,
             l_currency_code,
             l_bank_branch_name,
             l_bank_branch_id,
             l_override_remit_flag
          FROM ce_bank_accounts cba,
               ce_bank_branches_v bb,
               ar_receipt_method_accounts rma,
               ce_bank_acct_uses_ou_v ba
          WHERE         cba.bank_account_id = l_bank_account_id
              AND       rma.receipt_method_id = l_pay_method_id
              AND       rma.remit_bank_acct_use_id = ba.bank_acct_use_id
              AND       cba.bank_account_id = ba.bank_account_id
              AND       cba.bank_branch_id = bb.branch_party_id
              AND       p_batch_date between rma.start_date and NVL(rma.end_date,p_batch_date)
              AND       to_Date(p_batch_date,'DD/MM/RRRR') <
                        NVL(cba.end_date,to_date(p_batch_date,'DD/MM/RRRR')+1)
              AND       p_batch_date <=NVL(bb.end_date,p_batch_date)
              AND   ROWNUM <=1;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_bank_account_id:=NULL;
             l_bank_name:=NULL;
             l_bank_account_num:=NULL;
             l_currency_code:=NULL;
             l_bank_branch_name:=NULL;
             l_bank_branch_id:=NULL;
             l_override_remit_flag:=NULL;
       END;
    END IF;
    /* Validate PM */
    IF l_pay_method_id IS NOT NULL THEN
       BEGIN
       SELECT
          rc.name,
          rm.name,
          rc.creation_status,
          l.meaning,
           rc.remit_flag
       INTO
          l_rec_class_name,
          l_pay_method_name,
          l_creation_status,
          l_meaning,
          l_remit_flag
       FROM ar_receipt_classes rc,
            ar_receipt_methods rm,
            ar_lookups l
       WHERE  rc.receipt_class_id=l_rec_class_id
       AND    rc.receipt_class_id = rm.receipt_class_id
       AND    rm.receipt_method_id = l_pay_method_id
       AND    p_batch_date between rm.start_date and NVL(rm.end_date,p_batch_date)
       AND    rc.creation_status = l.lookup_code(+)
       AND    l.lookup_type(+) = 'RECEIPT_CREATION_STATUS'
       AND    EXISTS
          (SELECT
             rma.receipt_method_id
             FROM ce_bank_accounts cba,
                  ce_bank_branches_v bb,
                  ar_receipt_method_accounts rma,
                  ce_bank_acct_uses_ou_v ba
          WHERE         rma.receipt_method_id = l_pay_method_id
              AND       rma.remit_bank_acct_use_id = ba.bank_acct_use_id
              AND       cba.bank_account_id = ba.bank_account_id
              AND       (cba.currency_code=NVL(l_currency_code,p_currency_code)
                           OR cba.receipt_multi_currency_flag='Y')
              AND       bb.branch_party_id = cba.bank_branch_id
              AND       p_batch_date between rma.start_date and NVL(rma.end_date,p_batch_date)
              AND       to_date(p_batch_date,'DD/MM/RRRR') <
                        NVL(cba.end_date,to_date(p_batch_date,'DD/MM/RRRR')+1)
              AND       p_batch_date <=NVL(bb.end_date,p_batch_date))
       AND   ROWNUM <=1;
   EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_pay_method_name:=NULL;
              l_pay_method_id:=NULL;
              l_bank_account_id:=NULL;
              l_bank_name:=NULL;
              l_bank_account_num:=NULL;
              l_currency_code:=NULL;
              l_bank_branch_name:=NULL;
              l_bank_branch_id:=NULL;
              l_override_remit_flag:=NULL;
              l_rec_class_name:=NULL;
              l_creation_status:=NULL;
              l_meaning:=NULL;
              l_remit_flag:=NULL;
       END;
    END IF;
              /* Validate RC such that 1 PM exists atleast */
    IF l_rec_class_id is NOT NULL AND l_rec_class_name is NULL THEN
              BEGIN
                 SELECT
                    rc.name,
                    rc.creation_status,
                    l.meaning,
                    rc.remit_flag
                 INTO
                    l_rec_class_name,
                    l_creation_status,
                    l_meaning,
                    l_remit_flag
                FROM ar_receipt_classes rc,
                     ar_lookups l
       WHERE  rc.receipt_class_id=l_rec_class_id
                AND    rc.creation_status = l.lookup_code(+)
                AND    l.lookup_type(+) = 'RECEIPT_CREATION_STATUS'
                AND    EXISTS
                   (SELECT
                      rm.receipt_class_id
                    FROM ar_receipt_methods rm,
                      ce_bank_accounts cba,
                      ce_bank_branches_v bb,
                      ar_receipt_method_accounts rma,
                      ce_bank_acct_uses ba
                    WHERE       rm.receipt_class_id = l_rec_class_id
                       AND     rm.receipt_method_id = rma.receipt_method_id
                       AND       rma.remit_bank_acct_use_id = ba.bank_acct_use_id
                       AND       cba.bank_account_id = ba.bank_account_id
                       AND     (cba.currency_code=NVL(l_currency_code,p_currency_code) OR
                                cba.receipt_multi_currency_flag='Y')
                        AND     bb.branch_party_id = cba.bank_branch_id
                        AND     p_batch_date between rm.start_date and
                                      NVL(rm.end_date,p_batch_date)
                        AND     p_batch_date between
                                rma.start_date and NVL(rma.end_date,p_batch_date)
                              AND       to_Date(p_batch_date,'DD/MM/RRRR') <
                                  NVL(cba.end_date,to_date(p_batch_date,'DD/MM/RRRR')+1)
                        AND     p_batch_date <=NVL(bb.end_date,p_batch_date))
                AND ROWNUM <=1;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    l_pay_method_name:=NULL;
                    l_pay_method_id:=NULL;
                    l_bank_account_id:=NULL;
                    l_bank_name:=NULL;
                    l_bank_account_num:=NULL;
                    l_currency_code:=NULL;
                    l_bank_branch_name:=NULL;
                    l_bank_branch_id:=NULL;
                    l_override_remit_flag:=NULL;
                    l_rec_class_name:=NULL;
                    l_creation_status:=NULL;
                    l_meaning:=NULL;
                    l_remit_flag:=NULL;
              END;
    END IF;

    /* Assign the values fetched from Various select stmts to parameter variables */

   IF p_batch_source_name IS NOT NULL THEN
       p_batch_number:=l_batch_number;
       p_batch_source_id:=l_batch_source_id;
    END IF;
    IF l_rec_class_name IS NOT NULL AND l_rec_class_id is NOT NULL THEN
       p_rec_class_id:=l_rec_class_id;
       p_rec_class_name:=l_rec_class_name;
       p_remit_flag :=l_remit_flag;
       p_creation_status:=l_creation_status;
       p_meaning:=l_meaning;
    END IF;
    IF l_pay_method_name IS NOT NULL and l_pay_method_id IS NOT NULL THEN
       p_pay_method_id:=l_pay_method_id;
       p_pay_method_name:=l_pay_method_name;
    END IF;
    IF l_bank_name is NOT NULL AND l_bank_account_id IS NOT NULL THEN
       p_bank_name:=l_bank_name;
       p_bank_account_num :=l_bank_account_num;
       p_bank_account_id :=l_bank_account_id;
       IF l_currency_code is NOT NULL THEN
          p_currency_code :=l_currency_code;
       END IF;
       p_bank_branch_name:=l_bank_branch_name;
       p_bank_branch_id :=l_bank_branch_id;
       p_override_remit_flag :=l_override_remit_flag;
    END IF;
    IF PG_DEBUG IN ('Y', 'C') THEN
      arp_debug.debug('arp_rw_batches_pkg.default_batch_source_pay_mthds()-');
    END IF;

END default_batch_source_pay_mthds;


/**The lock is released at the end of current session or explicit call out to
   release_lock function
*/
FUNCTION request_lock(p_batch_id  NUMBER,
                      x_message   OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_lock_name     VARCHAR2(50);
l_lock_handle   VARCHAR2(256);
v_result        NUMBER;

BEGIN
  IF PG_DEBUG IN ('Y', 'C') THEN
    arp_debug.debug('arp_rw_batches_pkg.request_lock()+');
    arp_debug.debug('p_batch_id '||p_batch_id);
  END IF;

  l_lock_name := 'AR_RECEIPTS_BATCH_'||p_batch_id;

  DBMS_LOCK.allocate_unique( l_lock_name,
                             l_lock_handle);

  v_result := dbms_lock.request( l_lock_handle,
                                 dbms_lock.x_mode,
				 0);
  CASE v_result
    WHEN 0 THEN  x_message := 'success';
    WHEN 1 THEN  x_message := 'timeout';
    WHEN 2 THEN  x_message := 'deadlock';
    WHEN 3 THEN  x_message := 'parameter error';
    WHEN 4 THEN  x_message := 'already own lock specified by ''id'' or ''lockhandle''';
    WHEN 5 THEN  x_message := 'illegal lockhandle';
  END CASE;

  IF PG_DEBUG IN ('Y', 'C') THEN
    arp_debug.debug('v_result '||v_result);
    arp_debug.debug('arp_rw_batches_pkg.request_lock()-');
  END IF;

  IF v_result IN (0,4) THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;

END request_lock;



FUNCTION release_lock(p_batch_id  NUMBER,
                      x_message   OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_lock_name     VARCHAR2(50);
l_lock_handle   VARCHAR2(256);
v_result        NUMBER;
BEGIN
  IF PG_DEBUG IN ('Y', 'C') THEN
    arp_debug.debug('arp_rw_batches_pkg.release_lock()+');
    arp_debug.debug('p_batch_id '||p_batch_id);
  END IF;

  l_lock_name := 'AR_RECEIPTS_BATCH_'||p_batch_id;

  DBMS_LOCK.allocate_unique( l_lock_name,
                             l_lock_handle);

  v_result := dbms_lock.release( l_lock_handle );

  CASE v_result
    WHEN 0 THEN  x_message := 'success';
    WHEN 3 THEN  x_message := 'parameter error';
    WHEN 4 THEN  x_message := 'don''t own lock specified by ''id'' or ''lockhandle''';
    WHEN 5 THEN  x_message := 'illegal lockhandle';
  END CASE;

  IF PG_DEBUG IN ('Y', 'C') THEN
    arp_debug.debug('v_result '||v_result);
    arp_debug.debug('arp_rw_batches_pkg.release_lock()-');
  END IF;

  IF v_result = 0 THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;

END release_lock;



END ARP_RW_BATCHES_PKG;


/
