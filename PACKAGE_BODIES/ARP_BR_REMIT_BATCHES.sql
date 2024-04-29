--------------------------------------------------------
--  DDL for Package Body ARP_BR_REMIT_BATCHES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_BR_REMIT_BATCHES" AS
/* $Header: ARBRRM1B.pls 120.4.12010000.6 2009/12/22 13:07:42 pbapna ship $*/

G_PKG_NAME 	CONSTANT varchar2(30) 	:= 'ARP_BR_REMIT_BATCHES';

TYPE CUR_TYP	IS REF CURSOR;

/*-------------- Private procedures used by the package  --------------------*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE validate_args_insert_remit(
	p_batch_rec			IN	AR_BATCHES%ROWTYPE);

PROCEDURE validate_args_update_remit(
	p_batch_rec			IN	AR_BATCHES%ROWTYPE);

PROCEDURE validate_receipt_method(
	p_receipt_method_id		IN	AR_BATCHES.receipt_method_id%TYPE,
        p_batch_date			IN	AR_BATCHES.batch_date%TYPE);

PROCEDURE validate_currency_code(
	p_currency_code			IN	AR_BATCHES.currency_code%TYPE,
        p_batch_date			IN	AR_BATCHES.batch_date%TYPE);

PROCEDURE validate_remit_bank_branch(
	p_remittance_bank_branch_id	IN	AR_BATCHES.remittance_bank_branch_id%TYPE,
        p_batch_date			IN	AR_BATCHES.batch_date%TYPE);

PROCEDURE validate_remit_bank_account(
	p_remittance_bank_account_id	IN	AR_BATCHES.remit_bank_acct_use_id%TYPE,
        p_batch_date			IN	AR_BATCHES.batch_date%TYPE);

PROCEDURE validate_remit_method_code(
	p_remit_method_code		IN	AR_BATCHES.remit_method_code%TYPE,
	p_with_recourse_flag		IN	AR_BATCHES.with_recourse_flag%TYPE);

PROCEDURE validate_auto_program(
	p_auto_trans_program_id		IN	AR_BATCHES.auto_trans_program_id%TYPE);

/*------------------------ Public procedures   ------------------------*/


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_remit                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to insert the remittance batch row in the table AR_BATCHES  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
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
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE) IS


l_batch_rec	AR_BATCHES%ROWTYPE;
l_row_id	varchar2(20) := NULL;


BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug( 'ARP_BR_REMIT_BATCHES.insert_remit (+)');
END IF;

l_batch_rec.batch_date			:= p_batch_date;
l_batch_rec.gl_date			:= p_gl_date;
l_batch_rec.currency_code		:= p_currency_code;
l_batch_rec.comments			:= p_comments;
l_batch_rec.attribute_category		:= p_attribute_category;
l_batch_rec.attribute1			:= p_attribute1;
l_batch_rec.attribute2			:= p_attribute2;
l_batch_rec.attribute3			:= p_attribute3;
l_batch_rec.attribute4			:= p_attribute4;
l_batch_rec.attribute5			:= p_attribute5;
l_batch_rec.attribute6			:= p_attribute6;
l_batch_rec.attribute7			:= p_attribute7;
l_batch_rec.attribute8			:= p_attribute8;
l_batch_rec.attribute9			:= p_attribute9;
l_batch_rec.attribute10			:= p_attribute10;
l_batch_rec.media_reference		:= p_media_reference;
l_batch_rec.receipt_method_id		:= p_receipt_method_id;
l_batch_rec.remit_bank_acct_use_id	:= p_remittance_bank_account_id;
l_batch_rec.receipt_class_id		:= p_receipt_class_id;
l_batch_rec.remittance_bank_branch_id	:= p_remittance_bank_branch_id;
l_batch_rec.remit_method_code		:= p_remit_method_code;
l_batch_rec.with_recourse_flag		:= p_with_recourse_flag;
l_batch_rec.bank_deposit_number		:= p_bank_deposit_number;
l_batch_rec.auto_print_program_id	:= p_auto_print_program_id;
l_batch_rec.auto_trans_program_id	:= p_auto_trans_program_id;
l_batch_rec.control_count               := 0;
l_batch_rec.control_amount              := 0;

l_batch_rec.status			:= 'OP';
l_batch_rec.type			:= 'BR_REMITTANCE';
l_batch_rec.operation_request_id	:= NULL;

l_batch_rec.batch_applied_status 	:= 'STARTED_CREATION';

------------------------------------------
-- Automatic batch numbering
------------------------------------------
l_batch_rec.batch_source_id		:= 1;

UPDATE ar_batch_sources
SET last_batch_num = NVL(last_batch_num,0) + 1
WHERE batch_source_id = l_batch_rec.batch_source_id;

-- Check that the Batch source is valid
IF (SQL%ROWCOUNT = 0) THEN
    FND_MESSAGE.set_name('AR','AR_UPDNA_LAST_BATCH_NO');
    APP_EXCEPTION.raise_exception;
END IF;

SELECT NVL(last_batch_num,0)
INTO l_batch_rec.name
FROM ar_batch_sources
WHERE batch_source_id = l_batch_rec.batch_source_id;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug(  'ARP_BR_REMIT_BATCHES.insert_remit ... last_batch_num:'||l_batch_rec.name);
END IF;


------------------------------------------
-- Validation
------------------------------------------
arp_br_remit_batches.validate_args_insert_remit(l_batch_rec);

------------------------------------------
-- Call insert table handler
------------------------------------------
arp_cr_batches_pkg.insert_p(l_batch_rec, l_row_id, p_batch_id);

p_batch_name           := l_batch_rec.name;
p_batch_applied_status := l_batch_rec.batch_applied_status;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug(  'ARP_BR_REMIT_BATCHES.insert_remit (-)');
END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.insert_remit');
   END IF;
   RAISE;

END insert_remit;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_insert_remit                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to validate the remittance batch row                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_insert_remit(
	p_batch_rec			IN	AR_BATCHES%ROWTYPE) IS

l_row_id	varchar2(20) := NULL;
l_field		varchar2(30) := NULL;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_args_insert_remit (+)');
END IF;

-- Check that the main columns are filled
IF (p_batch_rec.type IS NULL) THEN
	l_field := 'TYPE';
ELSIF (p_batch_rec.currency_code IS NULL) THEN
    	l_field := 'CURRENCY_CODE';
ELSIF (p_batch_rec.batch_date IS NULL) THEN
	l_field := 'BATCH_DATE';
ELSIF (p_batch_rec.gl_date IS NULL) THEN
	l_field := 'GL_DATE';
ELSIF (p_batch_rec.remit_method_code IS NULL) THEN
	l_field := 'REMIT_METHOD_CODE';
ELSIF (p_batch_rec.remittance_bank_branch_id IS NULL) THEN
	l_field := 'REMITTANCE_BANK_BRANCH_ID';
ELSIF (p_batch_rec.batch_applied_status IS NULL) THEN
	l_field := 'BATCH_APPLIED_STATUS';
ELSIF (NVL(p_batch_rec.with_recourse_flag,'T') NOT IN ('Y','N')) THEN
	l_field := 'WITH_RECOURSE_FLAG';
END IF;

IF (l_field IS NOT NULL) THEN
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','validate_args_insert_remit');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

-- Check that the Batch Name is unique for the batch source
arp_rw_batches_check_pkg.check_unique_batch_name(l_row_id,
                                                 p_batch_rec.batch_source_id,
                                                 p_batch_rec.name,
                                                 NULL,
                                                 NULL);

-- Check that the gl date is valid
arp_util.validate_gl_date(p_batch_rec.gl_date, NULL, NULL);

-- Check that the currency is valid
arp_br_remit_batches.validate_currency_code(p_batch_rec.currency_code,p_batch_rec.batch_date);

-- Check that the receipt method is valid
arp_br_remit_batches.validate_receipt_method(p_batch_rec.receipt_method_id, p_batch_rec.batch_date);

-- Check that the remittance bank branch is valid
arp_br_remit_batches.validate_remit_bank_branch(p_batch_rec.remittance_bank_branch_id,p_batch_rec.batch_date);

-- Check that the remittance account is valid
arp_br_remit_batches.validate_remit_bank_account(p_batch_rec.remit_bank_acct_use_id,p_batch_rec.batch_date);

-- Check that the remittance method and the flag with_recouse are consistent
arp_br_remit_batches.validate_remit_method_code(p_batch_rec.remit_method_code,p_batch_rec.with_recourse_flag);

-- Check that the format program is a type 'REMIT_TRANSMIT' program
arp_br_remit_batches.validate_auto_program(p_batch_rec.auto_trans_program_id);

-- IF media reference is filled, Check that it is unique
IF (p_batch_rec.media_reference IS NOT NULL) THEN
	arp_rw_batches_check_pkg.check_unique_media_ref(l_row_id,
                                                        p_batch_rec.media_reference,
                                               		NULL,
                                                 	NULL);
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_args_insert_remit (-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.validate_args_insert_remit');
   END IF;
   RAISE;

END validate_args_insert_remit;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_currency                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the validation before inserting a batch row    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_currency_code(
	p_currency_code		IN	AR_BATCHES.currency_code%TYPE,
        p_batch_date		IN	AR_BATCHES.batch_date%TYPE) IS

NB		number;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_currency_code (+)');
END IF;

SELECT COUNT(*)
INTO   NB
FROM   FND_CURRENCIES_VL
WHERE  currency_code = p_currency_code
AND    p_batch_date BETWEEN NVL(start_date_active,p_batch_date) and NVL(end_date_active,p_batch_date);

IF (NB = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_INVALID_CURRENCY');
    APP_EXCEPTION.raise_exception;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_currency_code (-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.validate_currency_code');
   END IF;
   RAISE;

END validate_currency_code;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_receipt_method                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the validation before inserting a batch row    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 | 31/07/00 - MFLAHAUT                                                       |
 |  Receipt method on the remittance batch has to have the document sequence |
 |  defined, or the receipt_inherit_inv_num_flag has to be set to 'Y'.       |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_receipt_method(
	p_receipt_method_id	IN	AR_BATCHES.receipt_method_id%TYPE,
        p_batch_date		IN	AR_BATCHES.batch_date%TYPE) IS

CURSOR Receipt_method IS
 SELECT NVL(MT.receipt_inherit_inv_num_flag,'N'), MT.name
 FROM   AR_RECEIPT_METHODS MT,
       AR_RECEIPT_CLASSES CL,
       AR_LOOKUPS LK
 WHERE  MT.receipt_method_id = p_receipt_method_id
 AND    p_batch_date BETWEEN NVL(start_date,p_batch_date) and NVL(end_date,p_batch_date)
 AND    MT.receipt_class_id = CL.receipt_class_id
 AND    CL.creation_method_code = LK.lookup_code
 AND    LK.lookup_type = 'RECEIPT_CREATION_METHOD'
 AND    LK.lookup_code = 'BR_REMIT';

l_receipt_inherit_inv_num_flag	AR_RECEIPT_METHODS.receipt_inherit_inv_num_flag%TYPE;
l_receipt_name			AR_RECEIPT_METHODS.name%TYPE;

l_doc_seq_ret_stat		VARCHAR2(10);
l_doc_sequence_id		NUMBER;
l_doc_sequence_value            NUMBER;
l_doc_sequence_type		VARCHAR2(50);
l_doc_sequence_name		VARCHAR2(50);
l_db_sequence_name		VARCHAR2(50);
l_seq_ass_id			NUMBER;
l_prd_tab_name			VARCHAR2(50);
l_aud_tab_name			VARCHAR2(50);
l_msg_flag			VARCHAR2(1);

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_receipt_method (+)');
END IF;

OPEN Receipt_method;
FETCH Receipt_method INTO l_receipt_inherit_inv_num_flag, l_receipt_name;

IF (Receipt_method%NOTFOUND) THEN
    FND_MESSAGE.set_name('AR','AR_BR_INVALID_RECEIPT_METHOD');
    APP_EXCEPTION.raise_exception;
END IF;

CLOSE Receipt_method;

-- IS the receipt method flag receipt_inherit_inv_num_flag set to 'Y' ?
IF (l_receipt_inherit_inv_num_flag = 'Y') THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('validate_receipt_method: ' || 'the flag l_receipt_inherit_inv_num_flag is Y');
    END IF;
    return;
END IF;

l_doc_seq_ret_stat := fnd_seqnum.get_seq_info(
				app_id=>222,
				cat_code=>l_receipt_name,
				sob_id=>arp_global.set_of_books_id,
				met_code=>'M',
				trx_date=>TRUNC(p_batch_date),
				docseq_id=>l_doc_sequence_id,
				docseq_type=>l_doc_sequence_type,
				docseq_name=>l_doc_sequence_name,
				db_seq_name=>l_db_sequence_name,
				seq_ass_id=>l_seq_ass_id,
				prd_tab_name=>l_prd_tab_name,
				aud_tab_name=>l_aud_tab_name,
				msg_flag=>l_msg_flag ,
				suppress_error=>'N' ,
				suppress_warn=>'Y');

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('validate_receipt_method: ' || 'Return status :'||l_doc_seq_ret_stat||' for the receipt method '||l_receipt_name);
END IF;

	/* If the function returns 'partially used but not assigned' return the exception
	   AR_RAPI_DOC_SEQ_NOT_EXIST_P
	   All other exceptions raised by the get_seq_info procedure will be raised to
	   give the standard information.						*/

IF (l_doc_seq_ret_stat = -2) THEN
    FND_MESSAGE.set_name('AR','AR_RAPI_DOC_SEQ_NOT_EXIST_P');
    APP_EXCEPTION.raise_exception;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_receipt_method (-)');
END IF;

EXCEPTION

 WHEN NO_DATA_FOUND THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('exception NO_DATA_FOUND in ARP_BR_REMIT_BATCHES.validate_receipt_method');
    END IF;
    FND_MESSAGE.set_name('AR','AR_BR_INVALID_RECEIPT_METHOD');

    IF Receipt_method%ISOPEN THEN
       CLOSE Receipt_method;
    END IF;

    RAISE;

 WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Unhandled exception in ARP_BR_REMIT_BATCHES.validate_receipt_method');
       arp_util.debug('validate_receipt_method: ' || 'Return status :'||l_doc_seq_ret_stat||' for the receipt method '||l_receipt_name);
    END IF;

    IF Receipt_method%ISOPEN THEN
       CLOSE Receipt_method;
    END IF;

    RAISE;

END validate_receipt_method;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_remit_bank_branch                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the validation before inserting a batch row    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_remit_bank_branch(
	p_remittance_bank_branch_id	IN	AR_BATCHES.remittance_bank_branch_id%TYPE,
        p_batch_date			IN	AR_BATCHES.batch_date%TYPE) IS

NB		number;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_remit_bank_branch (+)');
END IF;

SELECT COUNT(*)
INTO   NB
FROM   ce_bank_branches_v
WHERE  branch_party_id = p_remittance_bank_branch_id
AND    p_batch_date BETWEEN p_batch_date and NVL(end_date,p_batch_date);

IF (NB = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_INVALID_REMIT_BRANCH');
    APP_EXCEPTION.raise_exception;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_remit_bank_branch (-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.validate_remit_bank_branch');
   END IF;
   RAISE;

END validate_remit_bank_branch;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_remit_account                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the validation before inserting a batch row    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_remit_bank_account(
  p_remittance_bank_account_id	IN AR_BATCHES.remit_bank_acct_use_id%TYPE,
  p_batch_date			IN	AR_BATCHES.batch_date%TYPE) IS

  nb NUMBER;

  CURSOR accounts (p_bank_acct_use_id NUMBER, p_date DATE) IS
    SELECT COUNT(*)
    FROM   ce_bank_accounts cba,
           ce_bank_acct_uses cbau
    WHERE  cbau.bank_acct_use_id = p_remittance_bank_account_id
    AND    cbau.bank_account_id = cba.bank_account_id
    AND    p_date BETWEEN p_date AND
           NVL(cbau.end_date,p_date);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ARP_BR_REMIT_BATCHES.validate_remit_bank_account (+)');
  END IF;

  OPEN accounts(p_remittance_bank_account_id, p_batch_date);
  FETCH accounts INTO nb;
  CLOSE accounts;

  IF (NB = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_INVALID_REMIT_ACCOUNT');
    APP_EXCEPTION.raise_exception;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ARP_BR_REMIT_BATCHES.validate_remit_bank_account (-)');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.validate_remit_bank_account');
      END IF;
      RAISE;

END validate_remit_bank_account;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_remit_method_code                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the validation before inserting a batch row    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_remit_method_code(
	p_remit_method_code		IN	AR_BATCHES.remit_method_code%TYPE,
	p_with_recourse_flag		IN	AR_BATCHES.with_recourse_flag%TYPE) IS


BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_remit_method_code (+)');
END IF;

-- the with recourse flag must be 'N' with the remittance method Standard
IF (p_remit_method_code = 'STANDARD' AND p_with_recourse_flag = 'Y') THEN
    FND_MESSAGE.set_name('AR','AR_BR_INVALID_REMIT_METHOD');
    APP_EXCEPTION.raise_exception;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_remit_method_code (-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.validate_remit_method_code');
   END IF;
   RAISE;

END validate_remit_method_code;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_auto_program                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the validation before inserting a batch row    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_auto_program(
        p_auto_trans_program_id		IN	AR_BATCHES.auto_trans_program_id%TYPE) IS

NB		number;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_auto_program (+)');
END IF;

IF p_auto_trans_program_id IS NOT NULL THEN

   SELECT COUNT(*)
   INTO   NB
   FROM	  ap_payment_programs
   WHERE  program_id = p_auto_trans_program_id
   AND	  program_type like 'REMIT_TRANSMIT';

   IF (NB = 0) THEN
       FND_MESSAGE.set_name('AR','AR_BR_INVALID_REMIT_PROGRAM');
       APP_EXCEPTION.raise_exception;
   END IF;

END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_auto_program (-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.validate_auto_program');
   END IF;
   RAISE;

END validate_auto_program;

 /*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_remit                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process delete bills receivable            |
 |    remittance to delete the remittance batch row in the table AR_BATCHES  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created as part of bug 9147689                     |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE delete_remit( p_batch_id IN ar_batches.batch_id%TYPE ) IS
   l_id	NUMBER;
   BEGIN
       -- lock the records.
       SELECT batch_id
       INTO   l_id
       FROM   ar_batches
       WHERE  batch_id = p_batch_id
       FOR UPDATE NOWAIT;

       ARP_CR_BATCHES_PKG.delete_p(p_batch_id);


   EXCEPTION
       WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('EXCEPTION: ARP_BR_REMIT_BATCHES.delete_remit');
            END IF;
            RAISE;
   END delete_remit;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_remit                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to update the remittance batch row in the table AR_BATCHES  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
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
                p_auto_trans_program_id		IN AR_BATCHES.auto_trans_program_id%TYPE) IS

l_api_name	CONSTANT varchar2(30) := 'update_remit';
l_api_version	CONSTANT number	      := 1.0;

l_row_id	varchar2(20) := NULL;
l_field		varchar2(30);

l_batch_rec	AR_BATCHES%ROWTYPE;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.update_remit (+)');
END IF;

SAVEPOINT update_remit_PVT;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;


IF (p_batch_id IS NULL) THEN
   l_field := 'P_BATCH_ID';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','batch id');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- fetch and lock of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

l_batch_rec.status			:= p_status;
l_batch_rec.control_count		:= p_control_count;
l_batch_rec.control_amount		:= p_control_amount;
l_batch_rec.batch_applied_status	:= p_batch_applied_status;
l_batch_rec.comments			:= p_comments;
l_batch_rec.media_reference		:= p_media_reference;
l_batch_rec.operation_request_id	:= p_operation_request_id;
l_batch_rec.remit_bank_acct_use_id	:= p_remittance_bank_account_id;
l_batch_rec.remittance_bank_branch_id	:= p_remittance_bank_branch_id;
l_batch_rec.bank_deposit_number		:= p_bank_deposit_number;
l_batch_rec.auto_print_program_id	:= p_auto_print_program_id;
l_batch_rec.auto_trans_program_id	:= p_auto_trans_program_id;

------------------------------------------
-- Validation
------------------------------------------
arp_br_remit_batches.validate_args_update_remit(l_batch_rec);

------------------------------------------
-- Call update table handler
------------------------------------------
arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.update_remit (-)');
END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_ERROR:ARP_BR_REMIT_BATCHES.update_remit');
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO update_remit_PVT;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR:ARP_BR_REMIT_BATCHES.update_remit');
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO update_remit_PVT;

 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS:ARP_BR_REMIT_BATCHES.update_remit');
      arp_util.debug('update_remit: ' || SQLERRM);
   END IF;
   ROLLBACK TO update_remit_PVT;
   IF (SQLCODE = -20001) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END update_remit;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_update_remit                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to validate the remittance batch row                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_update_remit(
	p_batch_rec			IN	AR_BATCHES%ROWTYPE) IS

l_row_id	varchar2(20) := NULL;
l_field		varchar2(30) := NULL;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_args_update_remit (+)');
END IF;

-- Check that the main columns are filled
IF (p_batch_rec.type IS NULL) THEN
	l_field := 'TYPE';
ELSIF (p_batch_rec.currency_code IS NULL) THEN
    	l_field := 'CURRENCY_CODE';
ELSIF (p_batch_rec.batch_date IS NULL) THEN
	l_field := 'BATCH_DATE';
ELSIF (p_batch_rec.gl_date IS NULL) THEN
	l_field := 'GL_DATE';
ELSIF (p_batch_rec.remit_method_code IS NULL) THEN
	l_field := 'REMIT_METHOD_CODE';
ELSIF (p_batch_rec.remittance_bank_branch_id IS NULL) THEN
	l_field := 'REMITTANCE_BANK_BRANCH_ID';
ELSIF (p_batch_rec.batch_applied_status IS NULL) THEN
	l_field := 'BATCH_APPLIED_STATUS';
ELSIF (NVL(p_batch_rec.with_recourse_flag,'T') NOT IN ('Y','N')) THEN
	l_field := 'WITH_RECOURSE_FLAG';
END IF;

IF (l_field IS NOT NULL) THEN
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','validate_args_insert_remit');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

-- Check that the gl date is valid
arp_util.validate_gl_date(p_batch_rec.gl_date, NULL, NULL);

-- Check that the currency is valid
arp_br_remit_batches.validate_currency_code(p_batch_rec.currency_code,p_batch_rec.batch_date);

-- Check that the receipt method is valid
arp_br_remit_batches.validate_receipt_method(p_batch_rec.receipt_method_id, p_batch_rec.batch_date);

-- Check that the remittance bank branch is valid
arp_br_remit_batches.validate_remit_bank_branch(p_batch_rec.remittance_bank_branch_id,p_batch_rec.batch_date);

-- Check that the remittance account is valid
arp_br_remit_batches.validate_remit_bank_account(p_batch_rec.remit_bank_acct_use_id,p_batch_rec.batch_date);

-- Check that the remittance method and the flag with_recouse are consistent
arp_br_remit_batches.validate_remit_method_code(p_batch_rec.remit_method_code,p_batch_rec.with_recourse_flag);

-- Check that the format program is a type 'REMIT_TRANSMIT' program
arp_br_remit_batches.validate_auto_program(p_batch_rec.auto_trans_program_id);

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.validate_args_update_remit (-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.validate_args_update_remit');
   END IF;
   RAISE;

END validate_args_update_remit;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    cancel_remit                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to update the remittance batch row in the table AR_BATCHES  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE cancel_remit(
	p_batch_id			IN 	AR_BATCHES.batch_id%TYPE,
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE) IS

l_batch_rec		AR_BATCHES%ROWTYPE;
l_ps_id			AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;

l_new_status		AR_TRANSACTION_HISTORY.status%TYPE;


CURSOR cur_br IS
SELECT payment_schedule_id
FROM AR_PAYMENT_SCHEDULES
WHERE reserved_type = 'REMITTANCE'
AND   reserved_value = p_batch_id;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.cancel_remit (+)');
END IF;

-- fetch and lock of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

-- The remitted BR are removed from the remittance batch
OPEN cur_br;

LOOP
 FETCH cur_br INTO l_ps_id;
 EXIT WHEN cur_br%NOTFOUND;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('cancel_remit: ' || 'BR '|| l_ps_id ||' removed from the remittance '||p_batch_id);
 END IF;
 AR_BILLS_MAINTAIN_PUB.Deselect_BR_Remit(l_ps_id,l_new_status);
END LOOP;

CLOSE cur_br;

-- update the batch row with the batch applied status
l_batch_rec.status := 'CL';
l_batch_rec.batch_applied_status := 'COMPLETED_CANCELLATION';
l_batch_rec.control_count  := 0;
l_batch_rec.control_amount := 0;
arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

COMMIT;

p_batch_applied_status := l_batch_rec.batch_applied_status;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.cancel_remit (-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_BR_REMIT_BATCHES.cancel_remit');
   END IF;

   IF cur_br%ISOPEN THEN
      CLOSE cur_br;
   END IF;

   RAISE;


END cancel_remit;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_remit                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to lock the remittance batch row in the table AR_BATCHES    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 22/05/2000           |
 |                                                                           |
 +===========================================================================*/
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
	p_batch_applied_status		IN	AR_BATCHES.batch_applied_status%TYPE) IS

l_api_name	CONSTANT varchar2(30) := 'lock_remit';
l_api_version	CONSTANT number	      := 1.0;

l_batch_rec	AR_BATCHES%ROWTYPE;


BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.lock_remit (+)');
END IF;

SAVEPOINT lock_remit_PVT;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

arp_cr_batches_pkg.fetch_p(p_batch_id,l_batch_rec);

l_batch_rec.name			:=p_batch_name;
l_batch_rec.status			:=p_status;
l_batch_rec.batch_date			:=p_batch_date;
l_batch_rec.gl_date			:=p_gl_date;
l_batch_rec.currency_code		:=p_currency_code;
l_batch_rec.comments			:=p_comments;
l_batch_rec.attribute_category		:=p_attribute_category;
l_batch_rec.attribute1			:=p_attribute1;
l_batch_rec.attribute2			:=p_attribute2;
l_batch_rec.attribute3			:=p_attribute3;
l_batch_rec.attribute4			:=p_attribute4;
l_batch_rec.attribute5			:=p_attribute5;
l_batch_rec.attribute6			:=p_attribute6;
l_batch_rec.attribute7			:=p_attribute7;
l_batch_rec.attribute8			:=p_attribute8;
l_batch_rec.attribute9			:=p_attribute9;
l_batch_rec.attribute10			:=p_attribute10;
l_batch_rec.media_reference		:=p_media_reference;
l_batch_rec.receipt_method_id		:=p_receipt_method_id;
l_batch_rec.remit_bank_acct_use_id	:=p_remittance_bank_account_id;
l_batch_rec.receipt_class_id		:=p_receipt_class_id;
l_batch_rec.remittance_bank_branch_id	:=p_remittance_bank_branch_id;
l_batch_rec.remit_method_code		:=p_remit_method_code;
l_batch_rec.with_recourse_flag		:=p_with_recourse_flag;
l_batch_rec.bank_deposit_number		:=p_bank_deposit_number;
l_batch_rec.auto_print_program_id	:=p_auto_print_program_id;
l_batch_rec.auto_trans_program_id	:=p_auto_trans_program_id;
l_batch_rec.batch_applied_status	:=p_batch_applied_status;

/*-----------------------------------------------+
|   Call the Table Handler    			|
+-----------------------------------------------*/
arp_cr_batches_pkg.lock_p(
			p_rowid,
			l_batch_rec.set_of_books_id,
			l_batch_rec.batch_id,
			l_batch_rec.batch_applied_status,
			l_batch_rec.batch_date,
			l_batch_rec.batch_source_id,
			l_batch_rec.comments,
			l_batch_rec.control_amount,
			l_batch_rec.control_count,
			l_batch_rec.exchange_date,
			l_batch_rec.exchange_rate,
			l_batch_rec.exchange_rate_type,
			l_batch_rec.lockbox_batch_name,
			l_batch_rec.media_reference,
			l_batch_rec.operation_request_id,
			l_batch_rec.receipt_class_id,
			l_batch_rec.receipt_method_id,
			l_batch_rec.remit_method_code,
			l_batch_rec.remit_bank_acct_use_id,
			l_batch_rec.remittance_bank_branch_id,
			l_batch_rec.attribute_category,
			l_batch_rec.attribute1,
			l_batch_rec.attribute2,
			l_batch_rec.attribute3,
			l_batch_rec.attribute4,
			l_batch_rec.attribute5,
			l_batch_rec.attribute6,
			l_batch_rec.attribute7,
			l_batch_rec.attribute8,
			l_batch_rec.attribute9,
			l_batch_rec.attribute10,
			l_batch_rec.attribute11,
			l_batch_rec.attribute12,
			l_batch_rec.attribute13,
			l_batch_rec.attribute14,
			l_batch_rec.attribute15,
			l_batch_rec.request_id,
			l_batch_rec.transmission_id,
			l_batch_rec.bank_deposit_number);


IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_BR_REMIT_BATCHES.lock_remit (-)');
END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_ERROR:ARP_BR_REMIT_BATCHES.lock_remit');
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO lock_remit_PVT;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR:ARP_BR_REMIT_BATCHES.lock_remit');
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO lock_remit_PVT;

 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS:ARP_BR_REMIT_BATCHES.lock_remit');
      arp_util.debug('lock_remit: ' || SQLERRM);
   END IF;
   ROLLBACK TO lock_remit_PVT;
   IF (SQLCODE = -20001) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END lock_remit;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_br_remit_batch_to_crh                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function is used to update the BR remittance batch id on the      |
 |    current cash receipt history record of the receipt created by BR       |
 |    remittance batch.                                                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_cr_id    Cash receipt id of the receipt to be updated |
 |                   p_batch_id Value to be updated                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     5-SEP-2000  Jani Rautiainen      Created                              |
 |                                                                           |
 +===========================================================================*/
  PROCEDURE update_br_remit_batch_to_crh(p_cr_id    IN  ar_cash_receipts.cash_receipt_id%TYPE,
                                         p_batch_id IN  ar_cash_receipt_history.batch_id%TYPE) IS

 /*--------------------------------------------+
  |  Cursor to fetch the current cash receipt  |
  |  history record                            |
  +--------------------------------------------*/
  CURSOR receipt_cur IS
    SELECT cash_receipt_history_id
    FROM   ar_cash_receipt_history
    WHERE  cash_receipt_id = p_cr_id
    AND    current_record_flag = 'Y';

  receipt_rec receipt_cur%ROWTYPE;
  l_crh_rec   ar_cash_receipt_history%ROWTYPE;
  l_crh_id    ar_cash_receipt_history.cash_Receipt_history_id%TYPE;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('arp_br_remit_batches.update_br_remit_batch_to_crh()+');
    END IF;

   /*--------------------------------------------+
    |  If either of the parameters is null, skip |
    |  processing                                |
    +--------------------------------------------*/
    IF p_batch_id is not null and p_cr_id is not null THEN

     /*------------------------------------------------+
      |  Fetch the current cash receipt history record |
      +------------------------------------------------*/
      OPEN receipt_cur;
      FETCH receipt_cur INTO receipt_rec;

      IF receipt_cur%NOTFOUND THEN

       /*------------------------------------------------+
        |  Current cash receipt history record cannot be |
        |  found, raise an error.                        |
        +------------------------------------------------*/
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('update_br_remit_batch_to_crh: ' || 'current receipt history record cannot be found cr_id = '||to_char(p_cr_id));
        END IF;
        CLOSE receipt_cur;
        APP_EXCEPTION.raise_exception;

      END IF;

      CLOSE receipt_cur;

     /*-----------------------------------+
      |  Set local record to dummy values |
      +-----------------------------------*/
      ARP_CR_HISTORY_PKG.set_to_dummy(l_crh_rec);

      l_crh_rec.batch_id                := p_batch_id;
      l_crh_rec.cash_receipt_history_id := receipt_rec.cash_receipt_history_id;

     /*-----------------------------------------+
      |  Update the cash receipt history record |
      +-----------------------------------------*/
      ARP_CR_HISTORY_PKG.update_p(l_crh_rec,
                                  receipt_rec.cash_receipt_history_id);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('arp_br_remit_batches.update_br_remit_batch_to_crh()-');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_br_remit_batches.update_br_remit_batch_to_crh');
        END IF;

        IF receipt_cur%ISOPEN THEN
           CLOSE receipt_cur;
        END IF;

        RAISE;

  END update_br_remit_batch_to_crh;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    revision                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the revision number of this package.             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | RETURNS    : Revision number of this package                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      10 JAN 2001 John HALL           Created                              |
 +===========================================================================*/
FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 120.4.12010000.6 $';
END revision;
--



END  ARP_BR_REMIT_BATCHES;
--

/
