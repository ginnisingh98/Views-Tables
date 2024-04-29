--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_BR_REMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_BR_REMIT" AS
/* $Header: ARBRRMAB.pls 120.7.12010000.2 2009/02/25 09:36:00 rvelidi ship $*/

G_PKG_NAME 	CONSTANT varchar2(30) 	:= 'ARP_PROCESS_BR_REMIT';

TYPE CUR_TYP	IS REF CURSOR;

/*-------------- Private procedures used by the package  --------------------*/


/*--------------------------- Public procedures   --------------------------*/

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_remit_batch                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to create automatically a remittance batch                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | VERSION : Current version 1.0                                             |
 |           Initial version 1.0                                             |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 23/05/2000           |
 |                                                                           |
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE create_remit_batch (
	p_api_version      		IN  NUMBER			,
        p_init_msg_list    		IN  VARCHAR2 := FND_API.G_FALSE	,
        p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
        p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status    		OUT NOCOPY VARCHAR2			,
        x_msg_count        		OUT NOCOPY NUMBER			,
        x_msg_data         		OUT NOCOPY VARCHAR2			,
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
	p_remit_total_low		IN	AR_BATCHES.control_amount%TYPE,
	p_remit_total_high		IN	AR_BATCHES.control_amount%TYPE,
	p_maturity_date_low		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_maturity_date_high		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_br_number_low			IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_number_high		IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_amount_low			IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_br_amount_high		IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_transaction_type1_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_transaction_type2_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_unsigned_flag			IN	varchar2,
	p_signed_flag			IN	RA_CUST_TRX_TYPES.signed_flag%TYPE,
	p_drawee_issued_flag		IN	RA_CUST_TRX_TYPES.drawee_issued_flag%TYPE,
	p_include_unpaid_flag		IN	varchar2,
	p_drawee_id			IN	AR_PAYMENT_SCHEDULES.customer_id%TYPE,
	p_drawee_number_low		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_number_high		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_class1_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class2_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class3_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_bank_name		IN	ce_bank_branches_v.bank_name%TYPE,
	p_drawee_bank_branch_id		IN	ce_bank_branches_v.branch_party_id%TYPE,
	p_drawee_branch_city		IN	ce_bank_branches_v.city%TYPE,
	p_br_sort_criteria		IN	varchar2,
	p_br_order			IN	varchar2,
	p_drawee_sort_criteria		IN	varchar2,
	p_drawee_order			IN	varchar2,
	p_batch_id			OUT NOCOPY	AR_BATCHES.batch_id%TYPE,
	p_batch_name			OUT NOCOPY	AR_BATCHES.name%TYPE,
	p_control_count			OUT NOCOPY	AR_BATCHES.control_count%TYPE,
	p_control_amount		OUT NOCOPY	AR_BATCHES.control_amount%TYPE,
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE) IS


l_api_name			CONSTANT varchar2(30) := 'create_remit_batch';
l_api_version			CONSTANT number	      := 1.0;

CUR_BR				CUR_TYP;
l_ps_rec			AR_PAYMENT_SCHEDULES%ROWTYPE;

l_batch_rec			AR_BATCHES%ROWTYPE;
l_batch_id			AR_BATCHES.batch_id%TYPE;
l_batch_name			AR_BATCHES.name%TYPE;
l_control_count			AR_BATCHES.control_count%TYPE;
l_control_amount		AR_BATCHES.control_amount%TYPE;
l_batch_applied_status		AR_BATCHES.batch_applied_status%TYPE;

l_select_detail			varchar2(25000) := NULL;
l_field				varchar2(30) := NULL;

total_count			number;
total_amount			number;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_PROCESS_BR_REMIT.create_remit_batch (+)');
END IF;

SAVEPOINT create_remit_batch_PVT;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

-- BR search criteria validation
ARP_PROCESS_BR_REMIT.validate_br_search_criteria(
	p_remit_total_low,
	p_remit_total_high,
	p_maturity_date_low,
	p_maturity_date_high,
	p_br_number_low,
	p_br_number_high,
	p_br_amount_low,
	p_br_amount_high,
	p_transaction_type1_id,
	p_transaction_type2_id,
	p_unsigned_flag,
	p_signed_flag,
	p_drawee_issued_flag,
	p_include_unpaid_flag,
	p_drawee_id,
	p_drawee_number_low,
	p_drawee_number_high,
	p_drawee_class1_code,
	p_drawee_class2_code,
	p_drawee_class3_code,
	p_drawee_bank_name,
	p_drawee_bank_branch_id,
	p_drawee_branch_city,
	p_br_sort_criteria,
	p_br_order,
	p_drawee_sort_criteria,
	p_drawee_order);

-- The necessary BR select statements are built
ARP_PROCESS_BR_REMIT.construct_select_br_for_remit (
	p_transaction_type1_id,
	p_transaction_type2_id,
	p_drawee_class1_code,
	p_drawee_class2_code,
	p_drawee_class3_code,
	p_drawee_bank_name,
	p_drawee_bank_branch_id,
	p_drawee_branch_city,
	p_unsigned_flag,
	p_signed_flag,
	p_drawee_issued_flag,
	p_br_sort_criteria,
	p_br_order,
	p_drawee_sort_criteria,
	p_drawee_order,
	l_select_detail);

-- IF some BR are selected with the user parameters,
-- the remittance is inserted in AR_BATCHES and the insert is committed
OPEN CUR_BR FOR l_select_detail
	USING  p_include_unpaid_flag,
	       p_batch_date,
	       p_gl_date,
               p_currency_code,
               p_remittance_bank_account_id,
	       p_maturity_date_low,
	       p_maturity_date_high,
	       p_br_number_low,
	       p_br_number_high,
	       p_br_amount_low,
	       p_br_amount_high,
	       p_drawee_id,
	       p_drawee_number_low,
	       p_drawee_number_high;

TOTAL_COUNT 		:= 0;
TOTAL_AMOUNT 		:= 0;

IF (p_remit_total_high IS NULL) THEN
   LOOP
     FETCH CUR_BR INTO l_ps_rec;
     EXIT WHEN CUR_BR%NOTFOUND;
     TOTAL_COUNT  := TOTAL_COUNT + 1;
     TOTAL_AMOUNT := TOTAL_AMOUNT + NVL(l_ps_rec.amount_due_remaining,0);
   END LOOP;
ELSE
   LOOP
     FETCH CUR_BR INTO l_ps_rec;
     EXIT WHEN CUR_BR%NOTFOUND;
     IF (TOTAL_AMOUNT + NVL(l_ps_rec.amount_due_remaining,0) <= p_remit_total_high)   THEN
         TOTAL_COUNT  := TOTAL_COUNT + 1;
         TOTAL_AMOUNT := TOTAL_AMOUNT + NVL(l_ps_rec.amount_due_remaining,0);
     END IF;
   END LOOP;
END IF;

CLOSE CUR_BR;

IF ((p_remit_total_low IS NULL) AND (TOTAL_COUNT > 0)) OR
   ((p_remit_total_low IS NOT NULL) AND (TOTAL_AMOUNT BETWEEN p_remit_total_low AND p_remit_total_high) AND (TOTAL_COUNT > 0)) THEN
-- Some BR have been selected -> Insert of the remittance batch row in the table AR_BATCHES
  ARP_BR_REMIT_BATCHES.insert_remit(
	p_batch_date,
	p_gl_date,
	p_currency_code,
	p_comments,
	p_attribute_category,
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_media_reference,
	p_receipt_method_id,
	p_remittance_bank_account_id,
	p_receipt_class_id,
	p_remittance_bank_branch_id,
	p_remit_method_code,
	p_with_recourse_flag,
	p_bank_deposit_number,
	p_auto_print_program_id,
	p_auto_trans_program_id,
	l_batch_id,
	l_batch_name,
	l_batch_applied_status);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('create_remit_batch: ' || 'Commit -- Insertion du Batch '||l_batch_id||' status '||l_batch_applied_status);
     arp_util.debug('create_remit_batch: ' || 'NB selected BR          :'|| TOTAL_COUNT);
     arp_util.debug('create_remit_batch: ' || 'Remittance total amount :'|| TOTAL_AMOUNT);
  END IF;
ELSE
-- NO BR have been selected -> the remittance batch row isn't inserted in the table AR_BATCHES
    FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CREATE_REMIT');
    APP_EXCEPTION.raise_exception;
END IF;

p_batch_id		:= l_batch_id;
p_batch_name		:= l_batch_name;
p_batch_applied_status	:= l_batch_applied_status;
p_control_count		:= 0;
p_control_amount	:= 0;

COMMIT;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_PROCESS_BR_REMIT.create_remit_batch (-)');
END IF;


EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_ERROR: ARP_PROCESS_BR_REMIT.create_remit_batch');
   END IF;
   ROLLBACK TO create_remit_batch_PVT;

   IF CUR_BR%ISOPEN THEN
      CLOSE CUR_BR;
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR: ARP_PROCESS_BR_REMIT.create_remit_batch');
   END IF;
   ROLLBACK TO create_remit_batch_PVT;

   IF CUR_BR%ISOPEN THEN
      CLOSE CUR_BR;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_PROCESS_BR_REMIT.create_remit_batch');
      arp_util.debug('create_remit_batch: ' || SQLERRM);
   END IF;
   ROLLBACK TO create_remit_batch_PVT;

   IF CUR_BR%ISOPEN THEN
      CLOSE CUR_BR;
   END IF;

   IF (SQLCODE = -20001) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE;


END create_remit_batch;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_and_assign_br_to_remit                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance process, to select the bills and assign them                |
 |    to the remittance                                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |           : OUT NOCOPY : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 15/06/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE select_and_assign_br_to_remit(
	p_api_version      		IN  NUMBER			,
        p_init_msg_list    		IN  VARCHAR2 := FND_API.G_FALSE	,
        p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
        p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status    		OUT NOCOPY VARCHAR2			,
        x_msg_count        		OUT NOCOPY NUMBER			,
        x_msg_data         		OUT NOCOPY VARCHAR2			,
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
	p_remit_total_low		IN	AR_BATCHES.control_amount%TYPE,
	p_remit_total_high		IN	AR_BATCHES.control_amount%TYPE,
	p_maturity_date_low		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_maturity_date_high		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_br_number_low			IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_number_high		IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_amount_low			IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_br_amount_high		IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_transaction_type1_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_transaction_type2_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_unsigned_flag			IN	varchar2,
	p_signed_flag			IN	RA_CUST_TRX_TYPES.signed_flag%TYPE,
	p_drawee_issued_flag		IN	RA_CUST_TRX_TYPES.drawee_issued_flag%TYPE,
	p_include_unpaid_flag    	IN 	varchar2,
	p_drawee_id			IN	AR_PAYMENT_SCHEDULES.customer_id%TYPE,
	p_drawee_number_low		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_number_high		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_class1_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class2_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class3_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_bank_name		IN	ce_bank_branches_v.bank_name%TYPE,
	p_drawee_bank_branch_id		IN	ce_bank_branches_v.branch_party_id%TYPE,
	p_drawee_branch_city		IN	ce_bank_branches_v.city%TYPE,
	p_br_sort_criteria	    	IN 	varchar2,
	p_br_order		    	IN 	varchar2,
	p_drawee_sort_criteria	    	IN 	varchar2,
	p_drawee_order		    	IN 	varchar2,
	p_control_count			OUT NOCOPY	AR_BATCHES.control_count%TYPE,
	p_control_amount		OUT NOCOPY	AR_BATCHES.control_amount%TYPE,
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE) IS

l_api_name			CONSTANT varchar2(30) := 'select_and_assign_br_to_remit';
l_api_version			CONSTANT number	      := 1.0;

l_batch_rec		AR_BATCHES%ROWTYPE;

l_select_detail		varchar2(25000);

l_control_count		AR_BATCHES.control_count%TYPE;
l_control_amount	AR_BATCHES.control_amount%TYPE;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'ARP_PROCESS_BR_REMIT.select_and_assign_br_to_remit (+)');
END IF;

SAVEPOINT select_and_assign_PVT;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

-- lock and fetch of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

-- The action Create is enabled only if the batch status is STARTED_CREATION
IF l_batch_rec.batch_applied_status NOT IN ('STARTED_CREATION') THEN
   FND_MESSAGE.set_name('AR','AR_BR_CANNOT_RECREATE_REMIT');
   APP_EXCEPTION.raise_exception;
END IF;

-- BR search criteria validation
ARP_PROCESS_BR_REMIT.validate_br_search_criteria(
	p_remit_total_low,
	p_remit_total_high,
	p_maturity_date_low,
	p_maturity_date_high,
	p_br_number_low,
	p_br_number_high,
	p_br_amount_low,
	p_br_amount_high,
	p_transaction_type1_id,
	p_transaction_type2_id,
	p_unsigned_flag,
	p_signed_flag,
	p_drawee_issued_flag,
	p_include_unpaid_flag,
	p_drawee_id,
	p_drawee_number_low,
	p_drawee_number_high,
	p_drawee_class1_code,
	p_drawee_class2_code,
	p_drawee_class3_code,
	p_drawee_bank_name,
	p_drawee_bank_branch_id,
	p_drawee_branch_city,
	p_br_sort_criteria,
	p_br_order,
	p_drawee_sort_criteria,
	p_drawee_order);

-- The necessary BR select statements are built
ARP_PROCESS_BR_REMIT.construct_select_br_for_remit (
	p_transaction_type1_id,
	p_transaction_type2_id,
	p_drawee_class1_code,
	p_drawee_class2_code,
	p_drawee_class3_code,
	p_drawee_bank_name,
	p_drawee_bank_branch_id,
	p_drawee_branch_city,
	p_unsigned_flag,
	p_signed_flag,
	p_drawee_issued_flag,
	p_br_sort_criteria,
	p_br_order,
	p_drawee_sort_criteria,
	p_drawee_order,
	l_select_detail);

-- The selected BR are assigned to the remittance by updating the reserved columns in the table AR_PAYMENT_SCHEDULES
-- until the parameter remittance maximum amount is reached (If it is filled of course).
ARP_PROCESS_BR_REMIT.assign_br_to_remit(
	l_select_detail,
        l_batch_rec.batch_id,
        p_remit_total_high,
	p_include_unpaid_flag,
        l_batch_rec.batch_date,
        l_batch_rec.gl_date,
	l_batch_rec.currency_code,
	l_batch_rec.remit_bank_acct_use_id,
	p_maturity_date_low,
	p_maturity_date_high,
	p_br_number_low,
	p_br_number_high,
	p_br_amount_low,
	p_br_amount_high,
	p_unsigned_flag,
	p_signed_flag,
	p_drawee_issued_flag,
	p_drawee_id,
	p_drawee_number_low,
	p_drawee_number_high,
        l_control_count,
        l_control_amount);

-- update the batch row with the control count and the control amount
l_batch_rec.control_count        := l_control_count;
l_batch_rec.control_amount       := l_control_amount;
l_batch_rec.batch_applied_status := 'COMPLETED_CREATION';
arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

p_batch_applied_status	:= l_batch_rec.batch_applied_status;
p_control_count		:= l_batch_rec.control_count;
p_control_amount	:= l_batch_rec.control_amount;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'BR Remittance number :'||l_batch_rec.name);
   arp_util.debug('create_remit_batch: ' || 'Count                :'||l_control_count);
   arp_util.debug('create_remit_batch: ' || 'Amount               :'||l_control_amount);
   arp_util.debug('create_remit_batch: ' || 'ARP_PROCESS_BR_REMIT.select_and_assign_br_to_remit (+)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'EXCEPTION : ARP_PROGRAM_BR_REMIT.select_and_assign_br_to_remit - ROLLBACK');
   END IF;
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO select_and_assign_PVT;
   RAISE;

END select_and_assign_br_to_remit;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_select_br_for_remit                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to build the BR select statement according the entered      |
 |    criteria                                                               |
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
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 20/04/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE construct_select_br_for_remit (
	p_transaction_type1_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_transaction_type2_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_drawee_class1_code	IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class2_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class3_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_bank_name		IN	ce_bank_branches_v.bank_name%TYPE,
	p_drawee_bank_branch_id		IN	ce_bank_branches_v.branch_party_id%TYPE,
	p_drawee_branch_city		IN	ce_bank_branches_v.city%TYPE,
	p_unsigned_flag			IN	varchar2,
	p_signed_flag			IN	RA_CUST_TRX_TYPES.signed_flag%TYPE,
	p_drawee_issued_flag		IN	RA_CUST_TRX_TYPES.drawee_issued_flag%TYPE,
	p_br_sort_criteria		IN	varchar2,
	p_br_order			IN	varchar2,
	p_drawee_sort_criteria		IN	varchar2,
	p_drawee_order			IN	varchar2,
	p_select_detail			OUT NOCOPY	varchar2) IS

l_field		                varchar2(30) := NULL;

l_where_clause		        varchar2(5000);
l_order_clause		        varchar2(5000);

l_flag_yes			varchar2(1) := 'Y';
l_flag_no			varchar2(1) := 'N';

l_ps_status_opened		AR_BATCHES.status%TYPE     := 'OP';
l_ps_class              	AR_PAYMENT_SCHEDULES.CLASS%TYPE := 'BR';

l_pending_remittance		AR_TRANSACTION_HISTORY.status%TYPE := 'PENDING_REMITTANCE';
l_unpaid			AR_TRANSACTION_HISTORY.status%TYPE := 'UNPAID';

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || '-----------ARP_PROCESS_BR_REMIT.construct_select_br_for_remit (+)-------------');
END IF;

/*-------------------------------------------------------------------------------------*/
/* clause Where set up                                                                 */
/*-------------------------------------------------------------------------------------*/
l_where_clause := 'WHERE PS.status LIKE '||''''|| l_ps_status_opened || ''' ';
l_where_clause := l_where_clause || 'AND PS.class LIKE '||''''|| l_ps_class || ''' ';
l_where_clause := l_where_clause || 'AND PS.customer_trx_id = TRX.customer_trx_id ';
l_where_clause := l_where_clause || 'AND TRX.drawee_id = CUST.cust_account_id ';
l_where_clause := l_where_clause || 'AND CUST.party_id = PARTY.party_id ';
l_where_clause := l_where_clause || 'AND PS.cust_trx_type_id = TRX_TYPE.cust_trx_type_id ';
l_where_clause := l_where_clause || 'AND PS.customer_trx_id = HS.customer_trx_id ';
l_where_clause := l_where_clause || 'AND HS.current_record_flag = '||''''|| l_flag_yes || ''' ';
l_where_clause := l_where_clause || 'AND TRX.drawee_bank_account_id = ACC.bank_account_id(+) ';
l_where_clause := l_where_clause || 'AND ACC.bank_branch_id = BRANCH.branch_party_id(+) ';
l_where_clause := l_where_clause || 'AND ((HS.status LIKE '||''''|| l_pending_remittance ||''') '||
                                      'OR (HS.status LIKE '||''''|| l_unpaid ||''' '||'AND :include_unpaid_flag = '||''''|| l_flag_yes ||''' )) ';
l_where_clause := l_where_clause || 'AND PS.reserved_type IS NULL ';
l_where_clause := l_where_clause || 'AND PS.reserved_value IS NULL ';
-- bug6050275
/*
l_where_clause := l_where_clause || 'AND :batch_date >= HS.trx_date ';
l_where_clause := l_where_clause || 'AND :batch_gl_date >= HS.gl_date ';
                                                                          */

l_where_clause := l_where_clause || 'AND ( (:batch_date >= HS.trx_date  ' || 'AND :batch_gl_date >= HS.gl_date) '||
 	                                        'OR HS.EVENT = ' || '''DESELECTED_REMITTANCE'')';

-- Batch parameters
l_where_clause := l_where_clause || 'AND PS.invoice_currency_code = :currency_code ';
l_where_clause := l_where_clause || 'AND (( TRX.remit_bank_acct_use_id IS NULL) OR '
         ||'(TRX.remit_bank_acct_use_id = :remittance_bank_account_id AND TRX.override_remit_account_flag = '||''''|| l_flag_no ||''''||') OR '
         ||'(TRX.override_remit_account_flag = '||''''|| l_flag_yes ||''''||')) ';

-- BR parameters
l_where_clause := l_where_clause || 'AND PS.due_date BETWEEN NVL(:maturity_date_low,PS.due_date) AND NVL(:maturity_date_high,PS.due_date) ';
l_where_clause := l_where_clause || 'AND PS.trx_number BETWEEN NVL(:br_number_low,PS.trx_number) AND NVL(:br_number_high,PS.trx_number) ';
l_where_clause := l_where_clause || 'AND PS.amount_due_remaining BETWEEN NVL(:br_amount_low,PS.amount_due_remaining) AND NVL(:br_amount_high,PS.amount_due_remaining) ';

-- Criteria Signed_flag and Drawee_issued_flag
-- If both are N, All types (Signed, drawee_issued and unsigned) are selected
IF (p_unsigned_flag = 'Y' AND p_signed_flag = 'Y' AND p_drawee_issued_flag = 'Y') THEN
    NULL;
ELSIF (p_unsigned_flag = 'Y' AND p_signed_flag = 'Y') THEN
    l_where_clause := l_where_clause || 'AND ((TRX_TYPE.signed_flag = ''N'' AND TRX_TYPE.drawee_issued_flag = ''N'') OR (TRX_TYPE.signed_flag = ''Y'')) ';
ELSIF (p_unsigned_flag = 'Y' AND p_drawee_issued_flag = 'Y') THEN
    l_where_clause := l_where_clause || 'AND ((TRX_TYPE.signed_flag = ''N'' AND TRX_TYPE.drawee_issued_flag = ''N'') OR (TRX_TYPE.drawee_issued_flag = ''Y'')) ';
ELSIF (p_signed_flag = 'Y' AND p_drawee_issued_flag = 'Y') THEN
    l_where_clause := l_where_clause || 'AND (TRX_TYPE.signed_flag = ''Y'' OR TRX_TYPE.drawee_issued_flag = ''Y'') ';
ELSIF (p_unsigned_flag = 'Y') THEN
    l_where_clause := l_where_clause || 'AND (TRX_TYPE.signed_flag = ''N'' AND TRX_TYPE.drawee_issued_flag = ''N'') ';
ELSIF (p_signed_flag = 'Y') THEN
    l_where_clause := l_where_clause || 'AND TRX_TYPE.signed_flag = ''Y'' ';
ELSIF (p_drawee_issued_flag = 'Y') THEN
    l_where_clause := l_where_clause || 'AND TRX_TYPE.drawee_issued_flag = ''Y'' ';
END IF;

-- Transaction types
IF (p_transaction_type1_id IS NOT NULL) AND (p_transaction_type2_id IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND PS.cust_trx_type_id IN ('||p_transaction_type1_id||','||p_transaction_type2_id||') ';
ELSIF (p_transaction_type1_id IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND PS.cust_trx_type_id IN ('||p_transaction_type1_id||') ';
ELSIF (p_transaction_type2_id IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND PS.cust_trx_type_id IN ('||p_transaction_type2_id||') ';
END IF;

----------------------------------------------------
-- Drawee parameters
----------------------------------------------------

l_where_clause := l_where_clause || 'AND TRX.drawee_id LIKE NVL(:drawee_id,TRX.drawee_id) ';
l_where_clause := l_where_clause || 'AND CUST.account_number BETWEEN NVL(:drawee_number_low,CUST.account_number) AND NVL(:drawee_number_high,CUST.account_number) ';

-- the drawee bank account information is optional on a BR
IF (p_drawee_bank_name IS NOT NULL) THEN
    l_where_clause := l_where_clause || 'AND BRANCH.bank_name LIKE '||''''||p_drawee_bank_name||''' ';
END IF;

IF (p_drawee_bank_branch_id IS NOT NULL) THEN
    l_where_clause := l_where_clause || 'AND BRANCH.branch_party_id = '||p_drawee_bank_branch_id||' ';
END IF;

IF (p_drawee_branch_city IS NOT NULL) THEN
    l_where_clause := l_where_clause || 'AND BRANCH.city LIKE '||''''||p_drawee_branch_city||''' ';
END IF;

-- Drawee classes
IF (p_drawee_class1_code IS NOT NULL) AND (p_drawee_class2_code IS NOT NULL) AND (p_drawee_class3_code IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND CUST.customer_class_code IN ('||
                              ''''||p_drawee_class1_code||''','''||p_drawee_class2_code||''','''|| p_drawee_class3_code||''') ';
ELSIF (p_drawee_class1_code IS NOT NULL) AND (p_drawee_class2_code IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND CUST.customer_class_code IN ('||
                              ''''||p_drawee_class1_code||''','''||p_drawee_class2_code||''') ';
ELSIF (p_drawee_class1_code IS NOT NULL) AND (p_drawee_class3_code IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND CUST.customer_class_code IN ('||
                              ''''||p_drawee_class1_code||''','''||p_drawee_class3_code||''') ';
ELSIF (p_drawee_class2_code IS NOT NULL) AND (p_drawee_class3_code IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND CUST.customer_class_code IN ('||
                              ''''||p_drawee_class2_code||''','''||p_drawee_class3_code||''') ';
ELSIF (p_drawee_class1_code IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND CUST.customer_class_code IN ('||
                              ''''||p_drawee_class1_code||''') ';
ELSIF (p_drawee_class2_code IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND CUST.customer_class_code IN ('||
                              ''''||p_drawee_class2_code||''') ';
ELSIF (p_drawee_class3_code IS NOT NULL) THEN
   l_where_clause := l_where_clause || 'AND CUST.customer_class_code IN ('||
                              ''''||p_drawee_class3_code||''') ';
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'Where clause completed.');
END IF;


/*-------------------------------------------------------------------------------------*/
/* clause Order set up                                                                 */
/*-------------------------------------------------------------------------------------*/
l_order_clause := 'ORDER BY PS.due_date ASC';

IF (NOT p_br_sort_criteria IS NULL) THEN
   l_order_clause := l_order_clause || ',' || p_br_sort_criteria || ' ' || p_br_order;
END IF;

IF (NOT p_drawee_sort_criteria IS NULL) THEN
   l_order_clause := l_order_clause || ',' || p_drawee_sort_criteria || ' ' || p_drawee_order;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'Order by clause completed.');
END IF;


/*-------------------------------------------------------------------------------------*/
/* Select                                                                              */
/*-------------------------------------------------------------------------------------*/
/* Bug 3424656 Modified the following SELECT to pick all
   the columns from PS rather than all the columns using
   the wildcard character. This was giving ORA-00932
   Inconsitent Datatypes errors in 10g. */

p_select_detail := 'SELECT PS.* ' ||
                   'FROM AR_PAYMENT_SCHEDULES PS, ' ||
                        'AR_TRANSACTION_HISTORY HS, ' ||
                        'HZ_CUST_ACCOUNTS CUST, ' ||
                        'HZ_PARTIES PARTY, ' ||
                        'RA_CUST_TRX_TYPES TRX_TYPE, ' ||
                        'RA_CUSTOMER_TRX TRX, ' ||
                        'AP_BANK_ACCOUNTS ACC, ' ||
                        'CE_BANK_BRANCHES_V BRANCH ' ||
		         l_where_clause ||
                         l_order_clause;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || '-----------ARP_PROCESS_BR_REMIT.construct_select_br_for_remit (-)-------------');
END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'EXCEPTION OTHERS: ARP_PROCESS_BR_REMIT.construct_select_br_for_remit ');
   END IF;
   RAISE;

END construct_select_br_for_remit;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_br_search_criteria                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to validate the br search criteria                          |
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
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 26/04/2000           |
 |                                                                           |
 | 20-Apr-2004  Debbie Sue Jancis       Fixed Bug 3550612, changed the check |
 |                                      on p_drawee_sort_criteria to check   |
 |                                      for party_name and account_number    |
 |                                      instead of customer name and         |
 |                                      customer number                      |
 +===========================================================================*/
PROCEDURE validate_br_search_criteria(
	p_remit_total_low		IN	AR_BATCHES.control_amount%TYPE,
	p_remit_total_high		IN	AR_BATCHES.control_amount%TYPE,
	p_maturity_date_low		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_maturity_date_high		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_br_number_low			IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_number_high		IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_amount_low			IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_br_amount_high		IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_transaction_type1_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_transaction_type2_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_unsigned_flag			IN	varchar2,
	p_signed_flag			IN	RA_CUST_TRX_TYPES.signed_flag%TYPE,
	p_drawee_issued_flag		IN	RA_CUST_TRX_TYPES.drawee_issued_flag%TYPE,
	p_include_unpaid_flag		IN	varchar2,
	p_drawee_id			IN	AR_PAYMENT_SCHEDULES.customer_id%TYPE,
	p_drawee_number_low		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_number_high		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_class1_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class2_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class3_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_bank_name		IN	ce_bank_branches_v.bank_name%TYPE,
	p_drawee_bank_branch_id		IN	ce_bank_branches_v.branch_party_id%TYPE,
	p_drawee_branch_city		IN	ce_bank_branches_v.city%TYPE,
	p_br_sort_criteria		IN	varchar2,
	p_br_order			IN	varchar2,
	p_drawee_sort_criteria		IN	varchar2,
	p_drawee_order			IN	varchar2) IS

l_field		varchar2(30) := NULL;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'ARP_PROCESS_BR_REMIT.validate_br_search_criteria (+)');
END IF;

-- remittance total amount
IF (p_remit_total_low IS NULL) AND (p_remit_total_high IS NULL) THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'p_remit_total_low and p_remit_total_high are NULL');
   END IF;
ELSIF (p_remit_total_low IS NULL) OR
      (p_remit_total_high IS NULL) OR
      (p_remit_total_high < p_remit_total_low) THEN
       FND_MESSAGE.set_name('AR','AR_BR_BAD_PARAM_REMIT_AMOUNT');
       APP_EXCEPTION.raise_exception;
END IF;

-- maturity date
IF (p_maturity_date_low IS NULL) AND (p_maturity_date_high IS NULL) THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'p_maturity_date_low and p_maturity_date_high are NULL');
   END IF;
ELSIF (p_maturity_date_low IS NULL) OR
      (p_maturity_date_high IS NULL) OR
      (p_maturity_date_high < p_maturity_date_low) THEN
       FND_MESSAGE.set_name('AR','AR_BR_BAD_PARAM_BR_DUE_DATE');
       APP_EXCEPTION.raise_exception;
END IF;

-- BR number
IF (p_br_number_low IS NULL) AND (p_br_number_high IS NULL) THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'p_br_number_low and p_br_number_high are NULL');
   END IF;
ELSIF (p_br_number_low IS NULL) OR
      (p_br_number_high IS NULL) OR
      (p_br_number_high < p_br_number_low) THEN
       FND_MESSAGE.set_name('AR','AR_BR_BAD_PARAM_BR_NUMBER');
       APP_EXCEPTION.raise_exception;
END IF;

-- BR amount
IF (p_br_amount_low IS NULL) AND (p_br_amount_high IS NULL) THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'p_br_amount_low and p_br_amount_high are NULL');
   END IF;
ELSIF (p_br_amount_low IS NULL) OR
      (p_br_amount_high IS NULL) OR
      (p_br_amount_high < p_br_amount_low) THEN
       FND_MESSAGE.set_name('AR','AR_BR_BAD_PARAM_BR_AMOUNT');
       APP_EXCEPTION.raise_exception;
END IF;

-- Drawee number
IF (p_drawee_number_low IS NULL) AND (p_drawee_number_high IS NULL) THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'p_drawee_number_low and p_drawee_number_high are NULL');
   END IF;
ELSIF (p_drawee_number_low IS NULL) OR
      (p_drawee_number_high IS NULL) OR
      (p_drawee_number_high < p_drawee_number_low) THEN
       FND_MESSAGE.set_name('AR','AR_BR_BAD_PARAM_DRAWEE_NUMBER');
       APP_EXCEPTION.raise_exception;
END IF;

-- parameter unsigned_flag
IF (NVL(p_unsigned_flag,'T') NOT IN ('Y','N')) THEN
   l_field := 'p_unsigned_flag';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','validate_br_search_criteria');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- parameter signed_flag
IF (NVL(p_signed_flag,'T') NOT IN ('Y','N')) THEN
   l_field := 'p_signed_flag';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','validate_br_search_criteria');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- parameter drawee_issued_flag
IF (NVL(p_drawee_issued_flag,'T') NOT IN ('Y','N')) THEN
   l_field := 'p_drawee_issued_flag';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','validate_br_search_criteria');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- parameter include_unpaid_flag
IF (NVL(p_include_unpaid_flag,'T') NOT IN ('Y','N')) THEN
   l_field := 'p_include_unpaid_flag';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','validate_br_search_criteria');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- parameter br_order
IF (NVL(p_br_order,'T') NOT IN ('ASC','DESC')) THEN
   l_field := 'p_br_order';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','validate_br_search_criteria');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- parameter drawee_order
IF (NVL(p_drawee_order,'T') NOT IN ('ASC','DESC')) THEN
   l_field := 'p_drawee_order';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','validate_br_search_criteria');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- parameter BR sort criteria
IF p_br_sort_criteria IS NULL THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'p_br_sort_criteria is NULL');
   END IF;
ELSIF p_br_sort_criteria NOT IN ('PS.TRX_NUMBER',
                                 'PS.AMOUNT_DUE_REMAINING',
                                 'TRX_TYPE.NAME') THEN
   l_field := 'p_br_sort_criteria';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','validate_br_search_criteria');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

-- parameter drawee sort criteria
IF p_drawee_sort_criteria IS NULL THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'p_drawee_sort_criteria is NULL');
   END IF;

 /* Bug 3550612, should check for party_name and account_number instead of
    Customer_name and Customer Number */
ELSIF p_drawee_sort_criteria NOT IN ('PARTY.PARTY_NAME',
                                     'CUST.ACCOUNT_NUMBER',
                                     'CUST.CUSTOMER_CLASS_CODE',
                                     'BRANCH.BANK_NAME',
                                     'BRANCH.BANK_BRANCH_NAME',
                                     'BRANCH.CITY')   THEN
   l_field := 'p_drawee_sort_criteria';
   FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
   FND_MESSAGE.set_token('PROCEDURE','validate_br_search_criteria');
   FND_MESSAGE.set_token('PARAMETER', l_field);
   APP_EXCEPTION.raise_exception;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'ARP_PROCESS_BR_REMIT.validate_br_search_criteria (-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'EXCEPTION OTHERS: ARP_PROCESS_BR_REMIT.validate_br_search_criteria ');
   END IF;
   RAISE;


END validate_br_search_criteria;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |     assign_br_to_remit                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to select the BR and assign them to the remittance          |
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
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 30/05/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE assign_br_to_remit(
	p_select_detail			IN	varchar2,
        p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
        p_remit_total_high		IN	AR_BATCHES.control_amount%TYPE,
	p_include_unpaid_flag		IN	varchar2,
        p_batch_date			IN	AR_BATCHES.batch_date%TYPE,
        p_gl_date			IN	AR_BATCHES.gl_date%TYPE,
	p_currency_code			IN	AR_BATCHES.currency_code%TYPE,
	p_remittance_bank_account_id	IN	AR_BATCHES.remit_bank_acct_use_id%TYPE,
	p_maturity_date_low		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_maturity_date_high		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_br_number_low			IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_number_high		IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_amount_low			IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_br_amount_high		IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_unsigned_flag			IN	varchar2,
	p_signed_flag			IN	RA_CUST_TRX_TYPES.signed_flag%TYPE,
	p_drawee_issued_flag		IN	RA_CUST_TRX_TYPES.drawee_issued_flag%TYPE,
	p_drawee_id			IN	AR_PAYMENT_SCHEDULES.customer_id%TYPE,
	p_drawee_number_low		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_number_high		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
        p_control_count			OUT NOCOPY	AR_BATCHES.control_count%TYPE,
        p_control_amount		OUT NOCOPY	AR_BATCHES.control_amount%TYPE) IS

CUR_BR			CUR_TYP;
l_ps_rec		AR_PAYMENT_SCHEDULES%ROWTYPE;

TOTAL_COUNT		AR_BATCHES.control_count%TYPE;
TOTAL_AMOUNT		AR_BATCHES.control_amount%TYPE;

l_new_status		AR_TRANSACTION_HISTORY.status%TYPE;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'ARP_PROCESS_BR_REMIT.assign_br_to_remit(+)');
END IF;

SAVEPOINT assign_br_to_remit_PVT;

OPEN CUR_BR FOR p_select_detail
	USING  p_include_unpaid_flag,
               p_batch_date,
               p_gl_date,
               p_currency_code,
               p_remittance_bank_account_id,
	       p_maturity_date_low,
	       p_maturity_date_high,
	       p_br_number_low,
	       p_br_number_high,
	       p_br_amount_low,
	       p_br_amount_high,
	       p_drawee_id,
	       p_drawee_number_low,
	       p_drawee_number_high;

TOTAL_COUNT 		:= 0;
TOTAL_AMOUNT 		:= 0;

IF (p_remit_total_high IS NULL) THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'no limit for the remittance');
   END IF;
   LOOP
     FETCH CUR_BR INTO l_ps_rec;
     EXIT WHEN CUR_BR%NOTFOUND;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('create_remit_batch: ' || 'BR '||l_ps_rec.payment_schedule_id||' assign to the remittance '||p_batch_id);
     END IF;
     AR_BILLS_MAINTAIN_PUB.Select_BR_Remit(p_batch_id,l_ps_rec.payment_schedule_id,l_new_status);
     TOTAL_COUNT := TOTAL_COUNT + 1;
     TOTAL_AMOUNT := TOTAL_AMOUNT + NVL(l_ps_rec.amount_due_remaining,0);
   END LOOP;
ELSE
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'limit for the remittance '||p_remit_total_high);
   END IF;
   LOOP
     FETCH CUR_BR INTO l_ps_rec;
     EXIT WHEN CUR_BR%NOTFOUND;
     IF (TOTAL_AMOUNT + NVL(l_ps_rec.amount_due_remaining,0) <= p_remit_total_high)   THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('create_remit_batch: ' || 'BR '||l_ps_rec.payment_schedule_id||' assign to the remittance '||p_batch_id);
         END IF;
         AR_BILLS_MAINTAIN_PUB.Select_BR_Remit(p_batch_id,l_ps_rec.payment_schedule_id,l_new_status);
         TOTAL_COUNT := TOTAL_COUNT + 1;
         TOTAL_AMOUNT := TOTAL_AMOUNT + NVL(l_ps_rec.amount_due_remaining,0);
     END IF;
   END LOOP;
END IF;

CLOSE CUR_BR;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'NB remitted BR          :'|| TOTAL_COUNT);
   arp_util.debug('create_remit_batch: ' || 'Remittance total amount :'|| TOTAL_AMOUNT);
END IF;

p_control_count  := TOTAL_COUNT;
p_control_amount := TOTAL_AMOUNT;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'ARP_PROCESS_BR_REMIT.assign_br_to_remit(-)');
END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'EXCEPTION OTHERS: ARP_PROCESS_BR_REMIT.assign_br_to_remit');
   END IF;
   ROLLBACK TO assign_br_to_remit_PVT;

   IF CUR_BR%ISOPEN THEN
      CLOSE CUR_BR;
   END IF;

   RAISE;

END assign_br_to_remit;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    add_or_rm_br_to_remit                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to attach or detach a BR from a remittance                  |
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
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 26/04/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE add_or_rm_br_to_remit (
	p_api_version      		IN  NUMBER			,
        p_init_msg_list    		IN  VARCHAR2 := FND_API.G_FALSE	,
        p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
        p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status    		OUT NOCOPY VARCHAR2			,
        x_msg_count        		OUT NOCOPY NUMBER			,
        x_msg_data         		OUT NOCOPY VARCHAR2			,
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
	p_ps_id				IN	AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE,
        p_action_flag			IN	varchar2,
        p_control_count			OUT NOCOPY	AR_BATCHES.control_count%TYPE,
	p_control_amount		OUT NOCOPY	AR_BATCHES.control_amount%TYPE) IS

l_api_name		CONSTANT varchar2(30) := 'add_or_rm_br_to_remit';
l_api_version		CONSTANT number	      := 1.0;

l_field			varchar2(30) := NULL;

l_new_status		AR_TRANSACTION_HISTORY.status%TYPE;

l_batch_rec		AR_BATCHES%ROWTYPE;
l_ps_rec		AR_PAYMENT_SCHEDULES%ROWTYPE;

l_control_count		AR_BATCHES.control_count%TYPE;
l_control_amount	AR_BATCHES.control_amount%TYPE;
l_br_amount		AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'ARP_PROCESS_BR_REMIT.add_or_rm_br_to_remit(+)');
END IF;

SAVEPOINT add_or_rm_br_to_remit_PVT;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

-- the flag action value is S for 'Select' or D for 'Deselect' or E for 'Erase'
IF (p_action_flag NOT IN ('S','D','E')) THEN
    l_field := 'p_action_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','add_or_rm_br_to_remit');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

-- the batch id isn't NULL ??
IF (p_batch_id IS NULL) THEN
    l_field := 'p_batch_id';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','add_or_rm_br_to_remit');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

-- fetch the remittance batch row
ARP_CR_BATCHES_PKG.fetch_p(p_batch_id,l_batch_rec);
l_control_count		:= l_batch_rec.control_count;
l_control_amount	:= l_batch_rec.control_amount;

-- The remittance has been approved; no changes are allowed
IF (l_batch_rec.batch_applied_status NOT IN ('STARTED_CREATION','COMPLETED_CREATION','STARTED_APPROVAL')) THEN
    FND_MESSAGE.set_name('AR','AR_BR_CANNOT_UPDATE_REMIT');
    APP_EXCEPTION.raise_exception;
END IF;

-- the payment schedule isn't NULL ??
IF (p_ps_id IS NULL) THEN
    l_field := 'p_ps_id';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','add_or_rm_br_to_remit');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

-- fetch the assigned trx payment schedule row
ARP_PS_PKG.fetch_p(p_ps_id,l_ps_rec);
l_br_amount	:= l_ps_rec.amount_due_remaining;

IF (p_action_flag = 'D') THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('create_remit_batch: ' || 'Action Deselect - Remove the BR '||p_ps_id||' from its remittance');
    END IF;
    AR_BILLS_MAINTAIN_PUB.DeSelect_BR_Remit(p_ps_id,l_new_status);
    l_control_count  := l_control_count - 1;
    l_control_amount := l_control_amount - l_br_amount;
ELSIF (p_action_flag = 'E') THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('create_remit_batch: ' || 'Action Erase - Remove the BR '||p_ps_id||' from its remittance');
    END IF;
    AR_BILLS_MAINTAIN_PUB.cancel_br_remit(p_ps_id);
    l_control_count  := l_control_count - 1;
    l_control_amount := l_control_amount - l_br_amount;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('create_remit_batch: ' || 'Action Select - BR '||l_ps_rec.payment_schedule_id||' assign to the remittance '||p_batch_id);
    END IF;
    AR_BILLS_MAINTAIN_PUB.Select_BR_Remit(p_batch_id,p_ps_id,l_new_status);
    l_control_count  := l_control_count + 1;
    l_control_amount := l_control_amount + l_br_amount;
END IF;

-- update the batch row with the control count and the control amount
l_batch_rec.control_count  := l_control_count;
l_batch_rec.control_amount := l_control_amount;
arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

IF FND_API.To_Boolean(p_commit) THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'commit');
   END IF;
   COMMIT;
END IF;

p_control_count  := l_control_count;
p_control_amount := l_control_amount;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('create_remit_batch: ' || 'ARP_PROCESS_BR_REMIT.add_or_rm_br_to_remit(-)');
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'EXCEPTION FND_API.G_EXC_ERROR: ARP_PROCESS_BR_REMIT.add_or_rm_br_to_remit');
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO add_or_rm_br_to_remit_PVT;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR: ARP_PROCESS_BR_REMIT.add_or_rm_br_to_remit');
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO add_or_rm_br_to_remit_PVT;

 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('create_remit_batch: ' || 'EXCEPTION OTHERS: ARP_PROCESS_BR_REMIT.add_or_rm_br_to_remit');
      arp_util.debug('create_remit_batch: ' || SQLERRM);
   END IF;
   ROLLBACK TO add_or_rm_br_to_remit_PVT;
   IF (SQLCODE = -20001) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END add_or_rm_br_to_remit;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_remit_batch_conc_req                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to submit the BR Remittance concurrent program              |
 |    as a concurrent request                                                |
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
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 26/04/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE create_remit_batch_conc_req (
	p_api_version			IN	number,
	p_init_msg_list			IN	varchar2 := FND_API.G_FALSE,
	p_commit			IN	varchar2 := FND_API.G_FALSE,
	p_validation_level		IN	number   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2,
	p_create_flag			IN	varchar2,
	p_approve_flag			IN	varchar2,
	p_format_flag			IN	varchar2,
	p_print_flag			IN	varchar2,
	p_cancel_flag			IN	varchar2,
	p_print_bills_flag		IN	varchar2,
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
        p_physical_bill			IN	varchar2,
	p_remit_total_low		IN	AR_BATCHES.control_amount%TYPE,
	p_remit_total_high		IN	AR_BATCHES.control_amount%TYPE,
	p_maturity_date_low		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_maturity_date_high		IN	AR_PAYMENT_SCHEDULES.due_date%TYPE,
	p_br_number_low			IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_number_high		IN	AR_PAYMENT_SCHEDULES.trx_number%TYPE,
	p_br_amount_low			IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_br_amount_high		IN	AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE,
	p_transaction_type1_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_transaction_type2_id		IN	AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE,
	p_unsigned_flag			IN	varchar2,
	p_signed_flag			IN	RA_CUST_TRX_TYPES.signed_flag%TYPE,
	p_drawee_issued_flag		IN	RA_CUST_TRX_TYPES.drawee_issued_flag%TYPE,
	p_include_unpaid_flag		IN	varchar2,
	p_drawee_id			IN	AR_PAYMENT_SCHEDULES.customer_id%TYPE,
	p_drawee_number_low		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_number_high		IN	HZ_CUST_ACCOUNTS.account_number%TYPE,
	p_drawee_class1_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class2_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_class3_code		IN	HZ_CUST_ACCOUNTS.customer_class_code%TYPE,
	p_drawee_bank_name		IN	ce_bank_branches_v.bank_name%TYPE,
	p_drawee_bank_branch_id		IN	ce_bank_branches_v.branch_party_id%TYPE,
	p_drawee_branch_city		IN	ce_bank_branches_v.city%TYPE,
	p_br_sort_criteria		IN	varchar2,
	p_br_order			IN	varchar2,
	p_drawee_sort_criteria		IN	varchar2,
	p_drawee_order			IN	varchar2,
	p_control_count			OUT NOCOPY	AR_BATCHES.control_count%TYPE,
	p_control_amount		OUT NOCOPY	AR_BATCHES.control_amount%TYPE,
	p_request_id			OUT NOCOPY	AR_BATCHES.operation_request_id%TYPE,
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE) IS

l_api_name			CONSTANT varchar2(30) := 'create_remit_batch_conc_req';
l_api_version			CONSTANT number	      := 1.0;

l_program			varchar2(30) := 'ARBRRMCP';

l_field				varchar2(30) := NULL;

l_batch_rec			AR_BATCHES%ROWTYPE;
l_control_count			AR_BATCHES.control_count%TYPE;
l_control_amount		AR_BATCHES.control_amount%TYPE;
l_request_id			AR_BATCHES.operation_request_id%TYPE;
l_batch_applied_status		AR_BATCHES.batch_applied_status%TYPE;
 l_org_id  number;
BEGIN

SAVEPOINT create_conc_req_PVT;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_PROCESS_BR_REMIT.create_remit_batch_conc_req (+)');
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

--------------------------------------------------
--                validations
--------------------------------------------------
IF  p_create_flag <> 'Y' THEN
    l_field := 'p_create_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','create_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;


IF p_approve_flag NOT IN ('Y','N') THEN
    l_field := 'p_approve_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','create_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

IF p_format_flag NOT IN ('Y','N') THEN
    l_field := 'p_format_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','create_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

IF p_print_flag NOT IN ('Y','N') THEN
    l_field := 'p_print_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','create_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

IF p_cancel_flag NOT IN ('Y','N') THEN
    l_field := 'p_cancel_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','create_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

IF p_print_bills_flag NOT IN ('Y','N') THEN
    l_field := 'p_print_bills_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','create_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

select org_id into l_org_id
from ar_system_parameters;

-- Fetch of the remittance batch
ARP_CR_BATCHES_PKG.fetch_p(p_batch_id,l_batch_rec);

 --MOAC changes
 FND_REQUEST.SET_ORG_ID(l_org_id);
-- Submit the BR Remittance auto Create concurrent program as a concurrent request
l_request_id := FND_REQUEST.SUBMIT_REQUEST(
					application => 'AR',
					program     =>l_program,
                                        description => NULL,
                                        start_time  => NULL,
                                        sub_request => NULL,
					argument1   =>p_create_flag,
					argument2   =>p_cancel_flag,
					argument3   =>p_approve_flag,
					argument4   =>p_format_flag,
					argument5   =>p_print_flag,
					argument6   =>p_print_bills_flag,
					argument7   =>p_batch_id,
                  			argument8   =>p_remit_total_low,
					argument9   =>p_remit_total_high,
					argument10  =>p_maturity_date_low,
					argument11  =>p_maturity_date_high,
					argument12  =>p_br_number_low,
					argument13  =>p_br_number_high,
					argument14  =>p_br_amount_low,
					argument15  =>p_br_amount_high,
					argument16  =>p_transaction_type1_id,
					argument17  =>p_transaction_type2_id,
					argument18  =>p_unsigned_flag,
					argument19  =>p_signed_flag,
					argument20  =>p_drawee_issued_flag,
					argument21  =>p_include_unpaid_flag,
					argument22  =>p_drawee_id,
					argument23  =>p_drawee_number_low,
					argument24  =>p_drawee_number_high,
					argument25  =>p_drawee_class1_code,
					argument26  =>p_drawee_class2_code,
					argument27  =>p_drawee_class3_code,
					argument28  =>p_drawee_bank_name,
					argument29  =>p_drawee_bank_branch_id,
					argument30  =>p_drawee_branch_city,
					argument31  =>p_br_sort_criteria,
					argument32  =>p_br_order,
					argument33  =>p_drawee_sort_criteria,
					argument34  =>p_drawee_order,
					argument35  =>p_physical_bill);

IF (l_request_id = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_BATCH_SUBMIT_FAILED');
    FND_MESSAGE.set_token('PROCEDURE','ARP_PROCESS_BR_REMIT.create_remit_batch_conc_req');
    APP_EXCEPTION.raise_exception;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('create_remit_batch: ' || 'Submitted Request - '||l_program||'. Request ID ='||to_char(l_request_id));
    END IF;
END IF;

p_control_count		:= l_batch_rec.control_count;
p_control_amount	:= l_batch_rec.control_amount;
p_request_id		:= l_request_id;
p_batch_applied_status	:= l_batch_rec.batch_applied_status;

-- Update the batch row with the request id
l_batch_rec.operation_request_id := l_request_id;
arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

COMMIT;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_PROCESS_BR_REMIT.create_remit_batch_conc_req (-)');
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_ERROR: ARP_PROCESS_BR_REMIT.create_remit_batch_conc_req');
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO create_conc_req_PVT;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR: ARP_PROCESS_BR_REMIT.create_remit_batch_conc_req');
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO create_conc_req_PVT;

 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_PROCESS_BR_REMIT.create_remit_batch_conc_req');
      arp_util.debug('create_remit_batch: ' || SQLERRM);
   END IF;
   ROLLBACK TO create_conc_req_PVT;
   IF (SQLCODE = -20001) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END create_remit_batch_conc_req;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    maintain_remit_batch_conc_req                                          |
 |                                                                           |
 | DESCRIPTION
 |    Procedure called during the process create bills receivable            |
 |    remittance to submit the BR Remittance concurrent program              |
 |    as a concurrent request                                                |
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
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 26/04/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE maintain_remit_batch_conc_req (
	p_api_version			IN	number,
	p_init_msg_list			IN	varchar2 := FND_API.G_FALSE,
	p_commit			IN	varchar2 := FND_API.G_FALSE,
	p_validation_level		IN	number   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2,
	p_approve_flag			IN	varchar2,
	p_format_flag			IN	varchar2,
	p_print_flag			IN	varchar2,
	p_cancel_flag			IN	varchar2,
	p_print_bills_flag		IN	varchar2,
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
        p_physical_bill			IN	varchar2,
	p_control_count			OUT NOCOPY	AR_BATCHES.control_count%TYPE,
	p_control_amount		OUT NOCOPY	AR_BATCHES.control_amount%TYPE,
	p_request_id			OUT NOCOPY	AR_BATCHES.operation_request_id%TYPE,
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE) IS

l_api_name			CONSTANT varchar2(30) := 'maintain_remit_batch_conc_req';
l_api_version			CONSTANT number	      := 1.0;

l_program			varchar2(30) := 'ARBRRMCP';

l_batch_rec			AR_BATCHES%ROWTYPE;
l_control_count			AR_BATCHES.control_count%TYPE;
l_control_amount		AR_BATCHES.control_amount%TYPE;
l_request_id			AR_BATCHES.operation_request_id%TYPE;
l_batch_applied_status		AR_BATCHES.batch_applied_status%TYPE;

l_field				varchar2(30) := NULL;

p_create_flag			varchar2(1) := 'N';
l_org_id     number;
BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_PROCESS_BR_REMIT.maintain_remit_batch_conc_req (+)');
END IF;

SAVEPOINT maintain_conc_req_PVT;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

--------------------------------------------------
--                validations
--------------------------------------------------
IF p_approve_flag NOT IN ('Y','N') THEN
    l_field := 'p_approve_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','maintain_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

IF p_format_flag NOT IN ('Y','N') THEN
    l_field := 'p_format_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','maintain_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

IF p_print_flag NOT IN ('Y','N') THEN
    l_field := 'p_print_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','maintain_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

IF p_cancel_flag NOT IN ('Y','N') THEN
    l_field := 'p_cancel_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','maintain_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

IF p_print_bills_flag NOT IN ('Y','N') THEN
    l_field := 'p_print_bills_flag';
    FND_MESSAGE.set_name('AR','AR_PROCEDURE_VALID_ARGS_FAIL');
    FND_MESSAGE.set_token('PROCEDURE','maintain_remit_batch_conc_req');
    FND_MESSAGE.set_token('PARAMETER', l_field);
    APP_EXCEPTION.raise_exception;
END IF;

--MOAC changes
select org_id into l_org_id
from ar_system_parameters;

-- Fetch of the remittance batch
ARP_CR_BATCHES_PKG.fetch_p(p_batch_id,l_batch_rec);

-- Validation
IF (p_cancel_flag = 'Y') AND (l_batch_rec.batch_applied_status NOT IN ('STARTED_CREATION','COMPLETED_CREATION','STARTED_APPROVAL','STARTED_CANCELLATION')) THEN
    FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CANCEL_REMIT');
    APP_EXCEPTION.raise_exception;
END IF;

IF (p_approve_flag = 'Y') AND (l_batch_rec.batch_applied_status NOT IN ('STARTED_CREATION','COMPLETED_CREATION','STARTED_APPROVAL')) THEN
    FND_MESSAGE.set_name('AR','AR_BR_CANNOT_APPROVE_REMIT');
    APP_EXCEPTION.raise_exception;
END IF;

 --MOAC changes
  FND_REQUEST.SET_ORG_ID(l_org_id);

-- Submit the BR Remittance auto Create concurrent program as a concurrent request
l_request_id := FND_REQUEST.SUBMIT_REQUEST(
					application => 'AR',
					program     =>'ARBRRMCP',
                                        description => NULL,
                                        start_time  => NULL,
                                        sub_request => NULL,
					argument1   =>p_create_flag,
					argument2   =>p_cancel_flag,
					argument3   =>p_approve_flag,
					argument4   =>p_format_flag,
					argument5   =>p_print_flag,
					argument6   =>p_print_bills_flag,
					argument7   =>p_batch_id,
                  			argument8   =>'',
					argument9   =>'',
					argument10  =>'',
					argument11  =>'',
					argument12  =>'',
					argument13  =>'',
					argument14  =>'',
					argument15  =>'',
					argument16  =>'',
					argument17  =>'',
					argument18  =>'',
					argument19  =>'',
					argument20  =>'',
					argument21  =>'',
					argument22  =>'',
					argument23  =>'',
					argument24  =>'',
					argument25  =>'',
					argument26  =>'',
					argument27  =>'',
					argument28  =>'',
					argument29  =>'',
					argument30  =>'',
					argument31  =>'',
					argument32  =>'',
					argument33  =>'',
					argument34  =>'',
					argument35  =>p_physical_bill);

IF (l_request_id = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_BATCH_SUBMIT_FAILED');
    FND_MESSAGE.set_token('PROCEDURE','ARP_PROCESS_BR_REMIT.maintain_remit_batch_conc_req');
    APP_EXCEPTION.raise_exception;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('maintain_remit_batch_conc_req: ' || 'Submitted Request - '||l_program||'. Request ID ='||to_char(l_request_id));
    END IF;
END IF;

-- Update the batch row with the request id and the batch applied status
l_batch_rec.operation_request_id := l_request_id;

IF (p_cancel_flag = 'Y') THEN
    l_batch_rec.batch_applied_status := 'STARTED_CANCELLATION';
ELSIF (p_approve_flag = 'Y') THEN
    l_batch_rec.batch_applied_status := 'STARTED_APPROVAL';
ELSIF (p_format_flag = 'Y') AND (l_batch_rec.auto_trans_program_id IS NOT NULL) THEN
    l_batch_rec.batch_applied_status := 'STARTED_FORMAT';
END IF;

arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

p_control_count			:= l_batch_rec.control_count;
p_control_amount		:= l_batch_rec.control_amount;
p_request_id			:= l_request_id;
p_batch_applied_status		:= l_batch_rec.batch_applied_status;

COMMIT;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_PROCESS_BR_REMIT.maintain_remit_batch_conc_req (-)');
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_ERROR: ARP_PROCESS_BR_REMIT.maintain_remit_batch_conc_req');
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO maintain_conc_req_PVT;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR: ARP_PROCESS_BR_REMIT.maintain_remit_batch_conc_req');
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO maintain_conc_req_PVT;

 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION OTHERS: ARP_PROCESS_BR_REMIT.maintain_remit_batch_conc_req');
      arp_util.debug('maintain_remit_batch_conc_req: ' || SQLERRM);
   END IF;
   ROLLBACK TO maintain_conc_req_PVT;
   IF (SQLCODE = -20001) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END maintain_remit_batch_conc_req;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_batch_status_after_create                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to update the batch status to Completed_creation            |
 |    if the batch is created manually                                       |
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
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 21/09/2000           |
 |  bug 1407469 : Actions Window Create doesn't update batch applied_status  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_batch_status (
	p_api_version			IN	number,
	p_init_msg_list			IN	varchar2 := FND_API.G_FALSE,
	p_commit			IN	varchar2 := FND_API.G_FALSE,
	p_validation_level		IN	number   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY	varchar2,
	x_msg_count			OUT NOCOPY	number,
	x_msg_data			OUT NOCOPY	varchar2,
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
	p_batch_applied_status		OUT NOCOPY	AR_BATCHES.batch_applied_status%TYPE) IS

l_api_name			CONSTANT varchar2(30) := 'update_batch_status';
l_api_version			CONSTANT number	      := 1.0;

l_batch_rec			AR_BATCHES%ROWTYPE;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_PROCESS_BR_REMIT.update_batch_status (+)');
END IF;

SAVEPOINT update_batch_status_PVT;

-- Standard call to check for call compatability
IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

-- lock and fetch of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

p_batch_applied_status := l_batch_rec.batch_applied_status;

-- The batch status is updated only if the batch status is STARTED_CREATION
IF l_batch_rec.batch_applied_status NOT IN ('STARTED_CREATION') THEN
   return;
END IF;

-- update the batch status to 'COMPLETED_CREATION'
l_batch_rec.batch_applied_status := 'COMPLETED_CREATION';
arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

p_batch_applied_status := l_batch_rec.batch_applied_status;

commit;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ARP_PROCESS_BR_REMIT.update_batch_status (-)');
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_ERROR:ARP_PROCESS_BR_REMIT.update_batch_status');
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO update_batch_status_PVT;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR:ARP_PROCESS_BR_REMIT.update_batch_status');
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO update_batch_status_PVT;

 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR:ARP_PROCESS_BR_REMIT.update_batch_status');
      arp_util.debug('update_batch_status: ' || SQLERRM);
   END IF;
   ROLLBACK TO update_batch_status_PVT;
   IF (SQLCODE = -20001) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END update_batch_status;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    test_rollback                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance to rollback the BR assignment                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | VERSION : Current version 1.0                                             |
 |           Initial version 1.0                                             |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 12/07/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE test_rollback IS
BEGIN
 rollback;
END test_rollback;


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
  RETURN '$Revision: 120.7.12010000.2 $';
END revision;
--




END  ARP_PROCESS_BR_REMIT;


/
