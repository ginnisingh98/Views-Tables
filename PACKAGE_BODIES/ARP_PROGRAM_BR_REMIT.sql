--------------------------------------------------------
--  DDL for Package Body ARP_PROGRAM_BR_REMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROGRAM_BR_REMIT" AS
/* $Header: ARBRRMPB.pls 120.11.12010000.4 2009/02/02 06:31:36 dgaurab ship $*/

G_PKG_NAME 	CONSTANT varchar2(30) 	:= 'ARP_PROGRAM_BR_REMIT';

pg_Date_Format	CONSTANT VARCHAR2(20) := 'DD-MON-RR';

TYPE CUR_TYP	IS REF CURSOR;

/*
   bug 1810619 : define process_status, if value is EXCEPTION, process will not
   continue with the next step
*/

process_status  varchar2(80);
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

-- SSA - R12
g_org_id        AR_SYSTEM_PARAMETERS.org_id%TYPE;

/*-------------- Private procedures used by the package  --------------------*/

PROCEDURE create_remit_pvt(
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
	p_drawee_order		    	IN 	varchar2);

PROCEDURE approve_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE);

PROCEDURE format_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
        p_physical_bill			IN	varchar2);

PROCEDURE cancel_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE);

PROCEDURE print_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE);

PROCEDURE print_bills_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE);

PROCEDURE process_br_payment(
        p_batch_id                      IN      AR_BATCHES.batch_id%TYPE);


/*------------------------ Public procedures   ------------------------*/


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    auto_create_remit_program                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance process to create, approve and/or format the remittance     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_create_flag : Y or N                                               |
 |                   this flag is Y when the action Create is selected       |
 |      p_approve_flag : Y or N                                              |
 |                   this flag is Y when the action Approve is selected      |
 |      p_format_flag : Y or N                                               |
 |                   this flag is Y when the action Format is selected       |
 |                                                                           |
 |           : OUT NOCOPY : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY							     |
 | 14-APR-00    M Flahaut 	Created					     |
 | 22-AUG-01	V Crisostomo	Bug 1810619 : check for value in             |
 |				process_status prior to proceeding to next   |
 |				step 					     |:
 +===========================================================================*/
PROCEDURE auto_create_remit_program(
	errbuf				OUT NOCOPY	varchar2,
	retcode				OUT NOCOPY	varchar2,
	p_create_flag       		IN 	varchar2				DEFAULT 'N',
	p_cancel_flag            	IN 	varchar2				DEFAULT 'N',
	p_approve_flag           	IN 	varchar2				DEFAULT 'N',
	p_format_flag            	IN 	varchar2				DEFAULT 'N',
	p_print_flag	           	IN 	varchar2				DEFAULT 'N',
	p_print_bills_flag		IN	varchar2				DEFAULT 'N',
	p_batch_id			IN	varchar2				DEFAULT NULL,
	p_remit_total_low		IN	varchar2				DEFAULT NULL,
	p_remit_total_high		IN	varchar2				DEFAULT NULL,
	p_maturity_date_low		IN	varchar2				DEFAULT NULL,
	p_maturity_date_high		IN	varchar2				DEFAULT NULL,
	p_br_number_low			IN	varchar2				DEFAULT NULL,
	p_br_number_high		IN	varchar2				DEFAULT NULL,
	p_br_amount_low			IN	varchar2				DEFAULT NULL,
	p_br_amount_high		IN	varchar2				DEFAULT NULL,
	p_transaction_type1_id		IN	varchar2				DEFAULT NULL,
	p_transaction_type2_id		IN	varchar2				DEFAULT NULL,
	p_unsigned_flag			IN	varchar2				DEFAULT NULL,
	p_signed_flag			IN	varchar2				DEFAULT NULL,
	p_drawee_issued_flag		IN	varchar2				DEFAULT NULL,
	p_include_unpaid_flag    	IN 	varchar2				DEFAULT NULL,
	p_drawee_id			IN	varchar2				DEFAULT NULL,
	p_drawee_number_low		IN	varchar2				DEFAULT NULL,
	p_drawee_number_high		IN	varchar2				DEFAULT NULL,
	p_drawee_class1_code		IN	varchar2				DEFAULT NULL,
	p_drawee_class2_code		IN	varchar2				DEFAULT NULL,
	p_drawee_class3_code		IN	varchar2				DEFAULT NULL,
	p_drawee_bank_name		IN	varchar2				DEFAULT NULL,
	p_drawee_bank_branch_id		IN	varchar2				DEFAULT NULL,
	p_drawee_branch_city		IN	varchar2				DEFAULT NULL,
	p_br_sort_criteria	    	IN 	varchar2				DEFAULT NULL,
	p_br_order		    	IN 	varchar2				DEFAULT NULL,
	p_drawee_sort_criteria	    	IN 	varchar2				DEFAULT NULL,
	p_drawee_order		    	IN 	varchar2				DEFAULT NULL,
        p_physical_bill			IN	varchar2                                DEFAULT 'N') IS

l_batch_id			AR_BATCHES.batch_id%TYPE;
l_remit_total_low		AR_BATCHES.control_amount%TYPE;
l_remit_total_high		AR_BATCHES.control_amount%TYPE;
l_maturity_date_low		AR_PAYMENT_SCHEDULES.due_date%TYPE;
l_maturity_date_high		AR_PAYMENT_SCHEDULES.due_date%TYPE;
l_br_amount_low			AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
l_br_amount_high		AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
l_transaction_type1_id		AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE;
l_transaction_type2_id		AR_PAYMENT_SCHEDULES.cust_trx_type_id%TYPE;
l_drawee_id			AR_PAYMENT_SCHEDULES.customer_id%TYPE;
l_drawee_bank_branch_id		CE_BANK_BRANCHES_V.branch_party_id%TYPE;

BEGIN

-- SSA - R12 : set global variable
select org_id
  into g_org_id
  from ar_system_parameters;

process_status := 'STARTED AUTO_CREATE_REMIT_PROGRAM';

FND_FILE.PUT_LINE(FND_FILE.LOG,'auto_create_remit_program(+)');
FND_FILE.PUT_LINE(FND_FILE.LOG,'----------- ACTIONS ----------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'create_flag  	 ' || p_create_flag);
FND_FILE.PUT_LINE(FND_FILE.LOG,'approve_flag 	 ' || p_approve_flag);
FND_FILE.PUT_LINE(FND_FILE.LOG,'format_flag  	 ' || p_format_flag);
FND_FILE.PUT_LINE(FND_FILE.LOG,'print_flag   	 ' || p_print_flag);
FND_FILE.PUT_LINE(FND_FILE.LOG,'print_bills_flag ' || p_print_bills_flag);
FND_FILE.PUT_LINE(FND_FILE.LOG,'cancel_flag  	 ' || p_cancel_flag);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Batch ID    	 ' || p_batch_id);

--------------------------------------------------------------
-- Convert parameters passed to the appropriate datatype   ---
--------------------------------------------------------------

l_batch_id			:= to_number(p_batch_id);
l_remit_total_low		:= to_number(p_remit_total_low);
l_remit_total_high		:= to_number(p_remit_total_high);
l_maturity_date_low		:= to_date(p_maturity_date_low,pg_Date_Format);
l_maturity_date_high		:= to_date(p_maturity_date_high,pg_Date_Format);
l_br_amount_low			:= to_number(p_br_amount_low);
l_br_amount_high		:= to_number(p_br_amount_high);
l_transaction_type1_id		:= to_number(p_transaction_type1_id);
l_transaction_type2_id		:= to_number(p_transaction_type2_id);
l_drawee_id			:= to_number(p_drawee_id);
l_drawee_bank_branch_id		:= to_number(p_drawee_bank_branch_id);

---------------------------------------------------
-----              Process                    -----
---------------------------------------------------

-- Create remittance
IF (p_create_flag = 'Y') THEN

   ARP_PROGRAM_BR_REMIT.create_remit_pvt(
		l_batch_id,
		l_remit_total_low,
		l_remit_total_high,
		l_maturity_date_low,
		l_maturity_date_high,
		p_br_number_low,
		p_br_number_high,
		l_br_amount_low,
		l_br_amount_high,
		l_transaction_type1_id,
		l_transaction_type2_id,
		p_unsigned_flag,
		p_signed_flag,
		p_drawee_issued_flag,
		p_include_unpaid_flag,
		l_drawee_id,
		p_drawee_number_low,
		p_drawee_number_high,
		p_drawee_class1_code,
		p_drawee_class2_code,
		p_drawee_class3_code,
		p_drawee_bank_name,
		l_drawee_bank_branch_id,
		p_drawee_branch_city,
		p_br_sort_criteria,
		p_br_order,
		p_drawee_sort_criteria,
		p_drawee_order);

END IF;

-- Bug 1810619 : For all the following steps, check value in process_status, if it sees
-- an EXCEPTION do not proceed

-- Cancel remittance
IF p_cancel_flag = 'Y' and instr(process_status,'EXCEPTION') = 0 THEN
   ARP_PROGRAM_BR_REMIT.cancel_remit_pvt(l_batch_id);
END IF;

-- Approve remittance
IF p_approve_flag = 'Y' and instr(process_status,'EXCEPTION') = 0 THEN
   ARP_PROGRAM_BR_REMIT.approve_remit_pvt(l_batch_id);
END IF;

-- Process Payment
  /* Payment uptake call the iby api for AUTH and settlement */

   ARP_PROGRAM_BR_REMIT.process_br_payment(l_batch_id);

-- Format remittance
IF p_format_flag = 'Y' and instr(process_status,'EXCEPTION') = 0 THEN
   ARP_PROGRAM_BR_REMIT.format_remit_pvt(l_batch_id,p_physical_bill);
END IF;

-- Print remittance
IF p_print_flag = 'Y' and instr(process_status,'EXCEPTION') = 0 THEN
   ARP_PROGRAM_BR_REMIT.print_remit_pvt(l_batch_id);
END IF;

-- Print Remittance 's Bills receivable
IF p_print_bills_flag = 'Y' and instr(process_status,'EXCEPTION') = 0 THEN
   ARP_PROGRAM_BR_REMIT.print_bills_remit_pvt(l_batch_id);
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG,'auto_create_remit_program(-)');

process_status := 'COMPLETED AUTO_CREATE_REMIT_PROGRAM';

EXCEPTION
 WHEN OTHERS THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_BR_REMIT.auto_create_remit_program');
   RAISE;

END auto_create_remit_program;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_remit_pvt                                                       |
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
 | 22-AUG-01	V Crisostomo	Bug 1810619 : set process_status 	     |
 +===========================================================================*/
PROCEDURE create_remit_pvt(
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
	p_drawee_bank_name		IN	CE_BANK_BRANCHES_V.bank_name%TYPE,
	p_drawee_bank_branch_id		IN	CE_BANK_BRANCHES_V.branch_party_id%TYPE,
	p_drawee_branch_city		IN	CE_BANK_BRANCHES_V.city%TYPE,
	p_br_sort_criteria	    	IN 	varchar2,
	p_br_order		    	IN 	varchar2,
	p_drawee_sort_criteria	    	IN 	varchar2,
	p_drawee_order		    	IN 	varchar2) IS


l_batch_rec		AR_BATCHES%ROWTYPE;

l_select_detail		varchar2(25000);

l_control_count		AR_BATCHES.control_count%TYPE;
l_control_amount	AR_BATCHES.control_amount%TYPE;

BEGIN

process_status := 'STARTED CREATE_REMIT_PVT';

FND_FILE.PUT_LINE(FND_FILE.LOG,'create_remit_pvt (+)');

SAVEPOINT create_remit_PVT;

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

FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------- ACTION CREATE --------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'BR Remittance number :'||l_batch_rec.name);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Count                :'||l_control_count);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount               :'||l_control_amount);
FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------------------------------------');

COMMIT;

FND_FILE.PUT_LINE(FND_FILE.LOG,'create_remit_pvt (-)');

process_status := 'COMPLETED CREATE_REMIT_PVT';

EXCEPTION
 WHEN OTHERS THEN

   process_status := 'EXCEPTION CREATE_REMIT_PVT';

   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_BR_REMIT.create_remit_pvt - ROLLBACK');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO create_remit_PVT;
   RAISE;

END create_remit_pvt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    cancel_remit_pvt                                                       |
 |                                                                           |
 |    Procedure called during the process create bills receivable            |
 |    remittance process, to cancel the BR remittance batch                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_batch_id : remittance batch identifier                             |
 |                                                                           |
 |           : OUT NOCOPY : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 18/04/2000           |
 | 22-AUG-01	V Crisostomo	Bug 1810619 : define process_status	     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE cancel_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE) IS

l_batch_rec			AR_BATCHES%ROWTYPE;
l_batch_applied_status		AR_BATCHES.batch_applied_status%TYPE;

BEGIN

process_status := 'STARTED CANCEL_REMIT_PVT';

FND_FILE.PUT_LINE(FND_FILE.LOG,'cancel_remit_pvt (+)');

SAVEPOINT cancel_remit_PVT;

-- lock and fetch of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

-- The action Cancel is enabled only if the batch status is STARTED_CANCELLATION
IF l_batch_rec.batch_applied_status NOT IN ('STARTED_CANCELLATION') THEN
   FND_MESSAGE.set_name('AR','AR_BR_CANNOT_CANCEL_REMIT');
   APP_EXCEPTION.raise_exception;
END IF;

ARP_BR_REMIT_BATCHES.cancel_remit(p_batch_id,l_batch_applied_status);

-- the batch row is updated in the procedure ARP_BR_REMIT_BATCHES.cancel_remit
-- with the status set to 'CL', the control count and the control amount set to zero
-- and the batch applied status set to 'completed_cancellation'

FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------- ACTION CANCEL ---------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'BR Remittance number : ' || l_batch_rec.name);
FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------');

FND_FILE.PUT_LINE(FND_FILE.LOG,'cancel_remit_pvt (-)');

process_status := 'COMPLETED CANCEL_REMIT_PVT';

EXCEPTION
 WHEN OTHERS THEN

   process_status := 'EXCEPTION CANCEL_REMIT_PVT';

   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_BR_REMIT.cancel_remit_pvt - ROLLBACK');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO cancel_remit_PVT;

END cancel_remit_pvt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    approve_remit_pvt                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance process, to approve the remittance                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_batch_id : remittance batch identifier                             |
 |                                                                           |
 |           : OUT NOCOPY : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 15/06/2000           |
 |                                                                           |
 | 22-AUG-01	V Crisostomo	Bug 1810619 : set process_status	     |
 +===========================================================================*/
PROCEDURE approve_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE) IS

l_batch_rec		AR_BATCHES%ROWTYPE;
l_ps_id			AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;

l_new_status		AR_TRANSACTION_HISTORY.status%TYPE;

CURSOR cur_br IS
SELECT payment_schedule_id
FROM AR_PAYMENT_SCHEDULES
WHERE reserved_type = 'REMITTANCE'
AND   reserved_value = p_batch_id;

BEGIN

process_status := 'STARTED APPROVE_REMIT_PVT';

FND_FILE.PUT_LINE(FND_FILE.LOG,'approve_remit_pvt (+)');

SAVEPOINT approve_remit_PVT;

-- lock and fetch of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

-- The action Approve is enabled only if the batch status is COMPLETED_CREATION and STARTED_APPROVAL
IF l_batch_rec.batch_applied_status NOT IN ('COMPLETED_CREATION','STARTED_APPROVAL') THEN
   FND_MESSAGE.set_name('AR','AR_BR_CANNOT_APPROVE_REMIT');
   APP_EXCEPTION.raise_exception;
END IF;

-- The remitted BR are approved
OPEN cur_br;

LOOP
 FETCH cur_br INTO l_ps_id;
 EXIT WHEN cur_br%NOTFOUND;
 AR_BILLS_MAINTAIN_PUB.Approve_BR_Remit(p_batch_id,l_ps_id,l_new_status);
END LOOP;

CLOSE cur_br;

-- update the batch row with the batch applied status
l_batch_rec.status := 'CL';
l_batch_rec.batch_applied_status := 'COMPLETED_APPROVAL';
arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

commit;

FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------- ACTION APPROVE --------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'BR Remittance number :'||l_batch_rec.name);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Count                :'||l_batch_rec.control_count);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Amount               :'||l_batch_rec.control_amount);
FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------');

FND_FILE.PUT_LINE(FND_FILE.LOG,'approve_remit_pvt (-)');

process_status := 'COMPLETED APPROVE_REMIT_PVT';

EXCEPTION
 WHEN OTHERS THEN

   process_status := 'EXCEPTION APPROVE_REMIT_PVT';

   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_BR_REMIT.approve_remit_pvt - ROLLBACK');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO approve_remit_PVT;

   IF cur_br%ISOPEN THEN
      CLOSE cur_br;
   END IF;

END approve_remit_pvt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    format_remit_pvt                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance process, to format the remittance                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |     TIEN API : update ??                                                  |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_batch_id : remittance batch identifier                             |
 |                                                                           |
 |           : OUT NOCOPY : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 18/04/2000           |
 |									     |
 | 22-AUG-01	V Crisostomo	Bug 1810619 : set process_status	     |
 | 05-OCT-05	Surendra Rajan  Bug 4609222 : Removed the auto trans program |
 |                              validation.                                  |
 +===========================================================================*/
PROCEDURE format_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE,
        p_physical_bill			IN	varchar2) IS

l_batch_rec		AR_BATCHES%ROWTYPE;

format_program		AP_PAYMENT_PROGRAMS.program_name%TYPE;

l_request_id		number;

BEGIN

process_status := 'STARTED FORMAT_REMIT_PVT';

FND_FILE.PUT_LINE(FND_FILE.LOG,'format_remit_pvt (+)');

SAVEPOINT format_remit_PVT;

-- lock and fetch of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

-- The action Format is enabled only if the transmission program field is filled
/*
IF l_batch_rec.auto_trans_program_id IS NULL THEN
   FND_MESSAGE.set_name('AR','AR_BR_NO_TRANS_PROGRAM');
   APP_EXCEPTION.raise_exception;
END IF;
*/

-- The action Format is enabled only if the batch status is COMPLETED_APPROVAL or STARTED_FORMAT
IF l_batch_rec.batch_applied_status NOT IN ('COMPLETED_APPROVAL','STARTED_FORMAT') THEN
   FND_MESSAGE.set_name('AR','AR_BR_CANNOT_FORMAT_REMIT');
   APP_EXCEPTION.raise_exception;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------- ACTION FORMAT ---------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'BR Remittance number : ' || l_batch_rec.name);

----------------------------------------------------------------------
-- Submit the transmission program as a concurrent request
----------------------------------------------------------------------

-- SSA - R12 : set org id prior to calling submit_request
FND_REQUEST.set_org_id(g_org_id);

IF format_program IN ('ARBRCS32') THEN
-- Submit the spanish CSB file format program as a concurrent request
l_request_id := FND_REQUEST.submit_request('AR'
                                         ,format_program
                                         ,NULL
                                         ,NULL
                                         ,NULL
                                         ,'P_BATCH_ID='''||p_batch_id||''''
                                         ,'P_PHYSICAL_BILL='''||p_physical_bill||'''');

ELSIF ( format_program = 'ARBRIBYFMT' ) THEN

-- Submit the iPayment BR remittance format prg as a concurrent request
l_request_id := FND_REQUEST.submit_request('AR'
                                         ,format_program
                                         ,'iPayment Bills Receivable Remittance'
                                         ,NULL
                                         ,NULL
                                         ,p_batch_id);
ELSE

-- Submit another format program as a concurrent request
l_request_id := FND_REQUEST.submit_request('AR'
                                         ,format_program
                                         ,NULL
                                         ,NULL
                                         ,NULL
                                         ,'P_BATCH_ID='''||p_batch_id||'''');

END IF;

IF (l_request_id = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_BATCH_SUBMIT_FAILED');
    FND_MESSAGE.set_token('PROCEDURE','ARP_PROGRAM_BR_REMIT.format_remit_pvt');
    APP_EXCEPTION.raise_exception;
ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted Request -'||format_program||'. Request ID ='||to_char(l_request_id));
END IF;

-- update the batch row with the control count and the control amount
l_batch_rec.batch_applied_status := 'COMPLETED_FORMAT';
arp_cr_batches_pkg.update_p(l_batch_rec,l_batch_rec.batch_id);

commit;

FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------');

FND_FILE.PUT_LINE(FND_FILE.LOG,'format_remit_pvt (-)');

process_status := 'COMPLETED FORMAT_REMIT_PVT';

EXCEPTION
 WHEN OTHERS THEN

   process_status := 'EXCEPTION FORMAT_REMIT_PVT';

   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_BR_REMIT.format_remit_pvt - ROLLBACK');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO format_remit_PVT;


END format_remit_pvt;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    print_remit_pvt                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance process, to submit the BR remittance report                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_batch_id : remittance batch identifier                             |
 |                                                                           |
 |           : OUT NOCOPY : NONE                                                    |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 18/04/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE print_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE) IS

l_batch_rec		AR_BATCHES%ROWTYPE;

-- Report 'BR Remittance Batch Management Report'
print_program		AP_PAYMENT_PROGRAMS.program_name%TYPE	:= 'ARBRRMBM';

l_request_id		number;

l_sort_by		varchar2(30);
l_sum_or_det		varchar2(30);
l_include_formatted	varchar2(30);
l_remit_bank		ce_bank_branches_v.bank_name%TYPE;
l_remit_bank_branch	ce_bank_branches_v.bank_branch_name%TYPE;

CURSOR prt_program IS
Select program_name
From AP_PAYMENT_PROGRAMS
Where program_id = l_batch_rec.auto_print_program_id;

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'print_remit_pvt (+)');

SAVEPOINT print_remit_PVT;

-- lock and fetch of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

-- parameter sort_by value must be BATCH NAME
select lookup_code
into l_sort_by
from ar_lookups
WHERE LOOKUP_TYPE = 'SORT_BY_ARXAPRMB'
AND   ENABLED_FLAG = 'Y'
AND   lookup_code = 'BATCH NAME';

-- parameter Summary_or_Detailed value must be 'DETAILED'
select lookup_code
into l_sum_or_det
from ar_lookups
where lookup_type = 'ARXAPRMB_SD' and lookup_code = 'DETAILED';

-- parameter include_formatted must be 'Y'
select lookup_code
into l_include_formatted
from fnd_lookups
WHERE LOOKUP_TYPE = 'YES_NO' and lookup_code = 'Y';

-- retrieve the remittance bank name and bank branch name
SELECT bank.bank_name,
       bank.bank_branch_name
INTO   l_remit_bank,
       l_remit_bank_branch
FROM   ce_bank_branches_v bank,
       ce_bank_accounts cba,
       ce_bank_acct_uses cbau
WHERE  cbau.bank_acct_use_id = l_batch_rec.remit_bank_acct_use_id
AND    cbau.bank_account_id  = cba.bank_account_id
AND    cba.bank_branch_id    = bank.branch_party_id;

OPEN prt_program;
FETCH prt_program INTO print_program;
IF prt_program%NOTFOUND THEN
   print_program := 'ARBRRMBM';
END IF;
CLOSE prt_program;

FND_FILE.PUT_LINE(FND_FILE.LOG,'----------- ACTION Print Report ------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'BR Remittance number : ' || l_batch_rec.name);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Report '||print_program||' parameters');
FND_FILE.PUT_LINE(FND_FILE.LOG,'SOB ID        '||arp_global.set_of_books_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'SORT BY       '||l_sort_by);
FND_FILE.PUT_LINE(FND_FILE.LOG,'status        '||l_batch_rec.batch_applied_status);
FND_FILE.PUT_LINE(FND_FILE.LOG,'SUM OR DET    '||l_sum_or_det);
FND_FILE.PUT_LINE(FND_FILE.LOG,'BATCH DATE    '||fnd_date.date_to_canonical(l_batch_rec.batch_date));
FND_FILE.PUT_LINE(FND_FILE.LOG,'DEPOSIT       '||l_batch_rec.bank_deposit_number);
FND_FILE.PUT_LINE(FND_FILE.LOG,'NAME          '||l_batch_rec.name);
FND_FILE.PUT_LINE(FND_FILE.LOG,'INCLUDE       '||l_include_formatted);
FND_FILE.PUT_LINE(FND_FILE.LOG,'REMIT METHOD  '||l_batch_rec.remit_method_code);
FND_FILE.PUT_LINE(FND_FILE.LOG,'REMIT BANK    '||l_remit_bank);
FND_FILE.PUT_LINE(FND_FILE.LOG,'REMIT BRANCH  '||l_remit_bank_branch);
FND_FILE.PUT_LINE(FND_FILE.LOG,'REMIT ACCOUNT USE  '||l_batch_rec.remit_bank_acct_use_id);


-- SSA - R12 : set org id prior to calling submit_request
FND_REQUEST.set_org_id(g_org_id);

-- Submit the Standard Print program 'BR Remittance Batch Management Report' as a concurrent request

        --Bug 5391515 as the arguments being passed  in the below commented code does not exist in the reports
--Bug7246266, handled the call for 'BR Remittance Batch Management Report'
IF (print_program = 'ARBRRMBM') Then
         l_request_id := FND_REQUEST.submit_request('AR'
                                        ,print_program
                                        ,NULL
                                        ,NULL
                                        ,NULL
					,arp_global.set_of_books_id
					,l_sort_by
					,l_batch_rec.batch_applied_status
					,l_sum_or_det
					,fnd_date.date_to_canonical(l_batch_rec.batch_date)
					,fnd_date.date_to_canonical(l_batch_rec.batch_date)
					,l_batch_rec.bank_deposit_number
					,l_batch_rec.bank_deposit_number
					,l_batch_rec.name
					,l_batch_rec.name
					,l_include_formatted
					,l_batch_rec.remit_method_code
					,l_remit_bank
					,l_remit_bank_branch
					,l_batch_rec.remit_bank_acct_use_id);

Else
         l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                              application=>'AR',
                              program=>print_program,
                              sub_request=>FALSE,
                              argument1=>'P_BATCH_ID='|| p_batch_id
                              ) ;
End If;

IF (l_request_id = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_BATCH_SUBMIT_FAILED');
    FND_MESSAGE.set_token('PROCEDURE','ARP_PROGRAM_BR_REMIT.print_remit_pvt');
    APP_EXCEPTION.raise_exception;
ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted Request - '||print_program||'. Request ID ='||to_char(l_request_id));
END IF;

commit;

FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------');

FND_FILE.PUT_LINE(FND_FILE.LOG,'print_remit_pvt (-)');

EXCEPTION
 WHEN OTHERS THEN

   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_BR_REMIT.print_remit_pvt - ROLLBACK');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO print_remit_PVT;

END print_remit_pvt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    print_bills_remit_pvt                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |    remittance process, to print the remittance 's bills receivable        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_batch_id : remittance batch identifier                             |
 |                                                                           |
 |           : OUT NOCOPY : NONE                                             |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 15/06/2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE print_bills_remit_pvt(
	p_batch_id			IN	AR_BATCHES.batch_id%TYPE) IS

l_batch_rec		AR_BATCHES%ROWTYPE;
l_request_id		NUMBER;
l_format                VARCHAR2(30) := 'REMIT BATCH';

BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'print_bills_remit_pvt (+)');

SAVEPOINT print_bills_remit_PVT;

-- lock and fetch of the batch row
l_batch_rec.batch_id := p_batch_id;
ARP_CR_BATCHES_PKG.lock_fetch_p(l_batch_rec);

FND_FILE.PUT_LINE(FND_FILE.LOG,'----------- ACTION Print Bills -------------');
FND_FILE.PUT_LINE(FND_FILE.LOG,'BR Remittance number : ' || l_batch_rec.name);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Program ARBRFMTW parameters');
FND_FILE.PUT_LINE(FND_FILE.LOG,'BATCH ID      '||p_batch_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'SOB ID        '||arp_global.set_of_books_id);

-- SSA - R12 : set org id prior to calling submit_request
FND_REQUEST.set_org_id(g_org_id);

l_request_id := FND_REQUEST.submit_request('AR'
                                         ,'ARBRFMTW'
                                         ,NULL
					 ,NULL
                                         ,NULL
                                         ,l_format
                                         ,p_batch_id
                                         ,NULL
                                         ,NULL
                                         ,arp_global.set_of_books_id);

IF (l_request_id = 0) THEN
    FND_MESSAGE.set_name('AR','AR_BR_BATCH_SUBMIT_FAILED');
    FND_MESSAGE.set_token('PROCEDURE','ARP_PROGRAM_BR_REMIT.print_bills_remit_pvt');
    APP_EXCEPTION.raise_exception;
ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted Request - ARBRFMTW. Request ID ='||to_char(l_request_id));
END IF;

commit;

FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------');

FND_FILE.PUT_LINE(FND_FILE.LOG,'print_bills_remit_pvt (-)');

EXCEPTION
 WHEN OTHERS THEN

   FND_FILE.PUT_LINE(FND_FILE.LOG,'EXCEPTION : ARP_PROGRAM_BR_REMIT.print_bills_remit_pvt - ROLLBACK');
   FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
   ROLLBACK TO print_bills_remit_PVT;

END print_bills_remit_pvt;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    process_br_payment                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the process create bills receivable            |
 |                                                                           |
 |    remittance process, to process the payment                             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                             |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |      p_batch_id : remittance batch identifier                             |
 |                                                                           |
 |           : OUT NOCOPY : NONE                                             |
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Mireille Flahaut - 15/06/2000           |
 |                                                                           |
 | 22-AUG-01    V Crisostomo    Bug 1810619 : set process_status             |
 +===========================================================================*/
PROCEDURE process_br_payment(
        p_batch_id                      IN      AR_BATCHES.batch_id%TYPE) IS

CURSOR br_rem_info_cur  IS
     SELECT br.trx_number,
            br.customer_trx_id,
            br.br_amount,
            br.invoice_currency_code,
            br.org_id,
            party.party_id,
            br.drawee_id,
            br.drawee_site_use_id,
            br.payment_trxn_extension_id
     FROM   ra_customer_trx br,
            hz_cust_accounts hca,
            hz_parties    party
     WHERE  br.remittance_batch_id = p_batch_id
     and    hca.party_id = party.party_id
     and    hca.cust_account_id = br.drawee_id ;

            br_rem_info    br_rem_info_cur%ROWTYPE;
            l_action VARCHAR2(80);
            l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
            l_msg_count NUMBER;
            l_msg_data  VARCHAR2(2000);
            l_iby_msg_data VARCHAR2(2000);
            l_vend_msg_data VARCHAR2(2000);
            l_cpy_msg_data VARCHAR2(2000);

/* DECLARE the variables required for the payment engine (CPY ) all the REC TYPES */
            p_trxn_entity_id    NUMBER;
            lc_trxn_entity_id   IBY_FNDCPT_COMMON_PUB.Id_tbl_type;

           l_auth_flag         VARCHAR2(1);
           l_auth_id           NUMBER;
/* END DECLARE the variables required for the payment engine (CPY ) all the REC TYPES */

/* DECLARE the variables required for the payment engine (CPY AND AUTH) all the REC TYPES */

            l_payer_rec             IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
            l_payee_rec             IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
            l_trxn_entity_id        NUMBER;
            l_auth_attribs_rec      IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
            l_trxn_attribs_rec      IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
            l_amount_rec            IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
            l_authresult_rec       IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type; /* OUT AUTH RESULT STRUCTURE */
            l_response_rec          IBY_FNDCPT_COMMON_PUB.Result_rec_type;   /* OUT RESPONSE STRUCTURE */
            l_entity_id             NUMBER;  -- OUT FROM COPY
/* END DECLARE the variables required for the payment engine (AUTH) all the REC TYPES */


/* DECLARE the variables required for the payment engine (SETTLEMENT) all the REC TYPES */
            ls_response_rec_tab   IBY_FNDCPT_TRXN_PUB.SettlementResult_tbl_type;
            ls_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
            ls_msg_count NUMBER;
            ls_msg_data  VARCHAR2(2000);
            ls_iby_msg_data VARCHAR2(2000);
           l_call_settlement VARCHAR2(1) := 'N';
           l_program_application_id NUMBER;


/* END DECLARE the variables required for the payment engine (SETTLEMENT) all the REC TYPES */
            x_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
            x_msg_count NUMBER;
            x_msg_data  VARCHAR2(2000);


BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,  'Entering payment processing...');
  END IF;



  FOR  br_rem_info  in br_rem_info_cur  LOOP



 -- Step 1: (always performed):

        -- set up payee record:
          l_payee_rec.org_id   := br_rem_info.org_id;
          l_payee_rec.org_type := 'OPERATING_UNIT' ;                                -- ( HR_ORGANIZATION_UNITS )


        -- set up payer (=customer) record:

        l_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
        l_payer_rec.Party_Id :=        br_rem_info.party_id;     -- receipt customer party id mandatory
        l_payer_rec.org_id   :=        br_rem_info.org_id ;
        l_payer_rec.org_type :=       'OPERATING_UNIT';
        l_payer_rec.Cust_Account_Id := br_rem_info.drawee_id;  -- receipt customer account_id
        l_payer_rec.Account_Site_Id := br_rem_info.drawee_site_use_id; -- receipt customer site_id


        if br_rem_info.drawee_site_use_id is NULL  THEN

          l_payer_rec.org_id := NULL;
          l_payer_rec.org_type := NULL;

	ELSE
	  l_payer_rec.Account_Site_Id := NVL(
	                  get_site_use_id(
	                   p_cust_account_id   => br_rem_info.drawee_id,
			   p_org_id            => br_rem_info.org_id,
			   p_pay_trxn_extn_id  => br_rem_info.payment_trxn_extension_id),
			  br_rem_info.drawee_site_use_id);
        end if;
        -- set up trxn_attribs record:
        l_trxn_attribs_rec.Originating_Application_Id := arp_standard.application_id;
        l_trxn_attribs_rec.order_id :=  br_rem_info.trx_number;
        l_trxn_attribs_rec.Trxn_Ref_Number1 := 'BRINVOICE';
        l_trxn_attribs_rec.Trxn_Ref_Number2 := br_rem_info.customer_trx_id;

        -- set up auth_attribs record:
        l_auth_attribs_rec.RiskEval_Enable_Flag := 'N';

        -- set up amounts

        l_amount_rec.value := br_rem_info.br_amount;
        l_amount_rec.currency_code   := br_rem_info.invoice_currency_code;


        -- assign the value for payment_trxn_extension record

                 l_trxn_entity_id := br_rem_info.payment_trxn_extension_id;



        IF PG_DEBUG in ('Y', 'C') THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,  'check and then call Auth');
           FND_FILE.PUT_LINE(FND_FILE.LOG,  'Calling get auth for  pmt_trxn_extn_id ');
           FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_trxn_entity_id  '             || to_char(l_trxn_entity_id ) );

       END IF;

         IF l_trxn_entity_id IS NOT NULL THEN


             l_call_settlement := 'Y';

             Begin
                SELECT decode(summ.status,   NULL,   'N',   'Y') AUTHORIZED_FLAG
                   into l_auth_flag
                 FROM iby_trxn_summaries_all summ,
                      iby_fndcpt_tx_operations op
                WHERE summ.transactionid = op.transactionid
                      AND reqtype = 'ORAPMTREQ'
                      AND status IN(0,    100)
                      AND trxntypeid IN(2,   3, 20)
                      AND op.trxn_extension_id = l_trxn_entity_id
                      AND summ.trxnmid =
                           (SELECT MAX(trxnmid)
                                FROM iby_trxn_summaries_all
                            WHERE transactionid = summ.transactionid
                            AND reqtype = 'ORAPMTREQ'
                            AND status IN(0, 100)
                            AND trxntypeid IN(2,    3,   20));
             Exception
               when others then
                 l_auth_flag := 'N';
             End;

              arp_standard.debug ( 'the value of auth_flag is = ' || l_auth_flag);

                If l_auth_flag = 'Y' then
                 arp_standard.debug ( 'the value of auth_flag is = ' || l_auth_flag);

                   select AUTHORIZATION_ID
                   into l_auth_id
                   from IBY_TRXN_EXT_AUTHS_V
                   where TRXN_EXTENSION_ID = l_trxn_entity_id;

                    update ra_customer_trx
                     set approval_code = 'AR'||to_char(l_auth_id)
                    where customer_trx_id = br_rem_info.customer_trx_id ;


                end if;

            IF  l_auth_flag <> 'Y'  then
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'auth needs to called');

                  IF PG_DEBUG in ('Y', 'C') THEN
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  'Calling get auth for  pmt_trxn_extn_id ');
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  ' l_payee_rec.org_id '           || to_char(l_payee_rec.org_id) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  ' l_payee_rec.org_type '         || to_char( l_payee_rec.org_type) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  ' l_payer_rec.Payment_Function ' || to_char( l_payer_rec.Payment_Function) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  ' l_payer_rec.Party_Id '         || to_char( l_payer_rec.Party_Id) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  ' l_payer_rec.org_id '           || to_char(l_payer_rec.org_id) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  ' l_payer_rec.org_type  '        || to_char( l_payer_rec.org_type) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_payer_rec.Cust_Account_Id '   || to_char(l_payer_rec.Cust_Account_Id) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_payer_rec.Account_Site_Id '   || to_char(l_payer_rec.Account_Site_Id) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_trxn_entity_id  '             || to_char(l_trxn_entity_id ) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_amount_rec.value: ' || to_char(l_amount_rec.value) );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_amount_rec.currency_code: '   || l_amount_rec.currency_code );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_auth_attribs_rec.RiskEval_Enable_Flag: '   || l_auth_attribs_rec.RiskEval_Enable_Flag);

                    FND_FILE.PUT_LINE(FND_FILE.LOG,  'Calling get_auth for  pmt_trxn_extn_id ');
                  END IF;


                 IBY_FNDCPT_TRXN_PUB.Create_Authorization(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data,
                         p_payer              => l_payer_rec,
                         p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                         p_payee              => l_payee_rec,
                         p_trxn_entity_id     => l_trxn_entity_id,
                         p_auth_attribs       => l_auth_attribs_rec,
                         p_amount             => l_amount_rec,
                         x_auth_result        => l_authresult_rec, -- out auth result struct
                         x_response           => l_response_rec );   -- out response struct


                  x_msg_count           := l_msg_count;
                  x_msg_data            := l_msg_data;

                        FND_FILE.PUT_LINE(FND_FILE.LOG,'x_return_status  :<' || l_return_status || '>');
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'x_msg_count      :<' || l_msg_count || '>');

                  FOR i IN 1..l_msg_count LOOP
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'x_msg #' || TO_CHAR(i) || ' = <' ||
                      SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,150) || '>');
                  END LOOP;

                     IF PG_DEBUG in ('Y', 'C') THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  '-------------------------------------');
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_response_rec.Result_Code:     ' || l_response_rec.Result_Code);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_response_rec.Result_Category: ' || l_response_rec.Result_Category);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_response_rec.Result_message : ' || l_response_rec.Result_message );
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_authresult_rec.Auth_Id:     '       || l_authresult_rec.Auth_Id);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_authresult_rec.Auth_Date: '         || l_authresult_rec.Auth_Date);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_authresult_rec.Auth_Code:     '     || l_authresult_rec.Auth_Code);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_authresult_rec.AVS_Code: '          || l_authresult_rec.AVS_Code);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_authresult_rec.PaymentSys_Code: '   || l_authresult_rec.PaymentSys_Code);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_authresult_rec.PaymentSys_Msg: '    || l_authresult_rec.PaymentSys_Msg);
                     -- FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_authresult_rec.Risk_Result: '       || l_authresult_rec.Risk_Result);

                    END IF;

                     IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                        -- update trx record with authorization code

                             update ra_customer_trx
                             set approval_code = l_authresult_rec.Auth_code ||'AR'||to_char(l_authresult_rec.Auth_Id)
                             where customer_trx_id = br_rem_info.customer_trx_id ;

                              IF PG_DEBUG in ('Y', 'C') THEN
                                FND_FILE.PUT_LINE(FND_FILE.LOG,'TRX updated with auth_id and auth code ');
                               END IF;

                        END IF;


                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                           FND_FILE.PUT_LINE(FND_FILE.LOG,'in AR AUTH FAILED.');
                                FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
                            FND_MSG_PUB.Add;

                           IF  l_response_rec.Result_Code is NOT NULL THEN

                                 ---Raise the PAYMENT error code concatenated with the message

                                   l_iby_msg_data := substrb( l_response_rec.Result_Code || ': '|| l_response_rec.Result_Message , 1, 240);

                               FND_FILE.PUT_LINE(FND_FILE.LOG,  'l_iby_msg_data: ' || l_iby_msg_data);
                               FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                               FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_iby_msg_data);

                               FND_MSG_PUB.Add;

                            END IF;

                            IF l_authresult_rec.PaymentSys_Code is not null THEN

                              ---Raise the VENDOR error code concatenated with the message

                              l_vend_msg_data := substrb(l_authresult_rec.PaymentSys_Code || ': '||
                                   l_authresult_rec.PaymentSys_Msg , 1, 240 );

                                FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                                FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_vend_msg_data);

                                FND_MSG_PUB.Add;

                            END IF;
                               FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                      p_count  =>  x_msg_count,
                                      p_data   => x_msg_data );

                              x_return_status := l_return_status;
                           RETURN;

                     END IF; /* End the error handling CREATE */

               END IF;  /* END if of auth flag N  */


    END IF ; /* l_trxn_entity_id IS NOT NULL*/

   END LOOP ; /* if cursor found */


    /* NOW WE HAVE TO CALL BULK SETTLEMENT  START */

     IF l_call_settlement = 'Y' THEN

       l_program_application_id := arp_standard.application_id ;


                   FND_FILE.PUT_LINE(FND_FILE.LOG, 'CALL THE SETTLEMENT API');
          IF PG_DEBUG in ('Y', 'C') THEN
                  fnd_file.put_line(FND_FILE.LOG,  'Calling bulk settlement');
                  fnd_file.put_line(FND_FILE.LOG,  ' p_calling_app_request_code  '           || to_char( p_batch_id ) );
                  fnd_file.put_line(FND_FILE.LOG,  'p_order_view_name  '         || 'ARBR_FUNDS_CAPTURE_ORDERS_V' );
          END IF;

                 IBY_FNDCPT_TRXN_PUB.Create_Settlements(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         p_calling_app_id     => l_program_application_id,
                         p_calling_app_request_code => 'ARBR_'||p_batch_id,
                         p_order_view_name  => 'ARBR_FUNDS_CAPTURE_ORDERS_V',
                         x_return_status      => ls_return_status,
                         x_msg_count          => ls_msg_count,
                         x_msg_data           => ls_msg_data,
                         x_responses           => ls_response_rec_tab );


                        fnd_file.put_line(FND_FILE.LOG,'x_return_status  :<' || ls_return_status || '>');
                        fnd_file.put_line(FND_FILE.LOG,'x_msg_count      :<' || ls_msg_count || '>');

                  FOR i IN 1..ls_msg_count LOOP
                      fnd_file.put_line(FND_FILE.LOG,'x_msg #' || TO_CHAR(i) || ' = <' ||
                      SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,150) || '>');
                  END LOOP;

            IF   PG_DEBUG  in ('Y' , 'C')  THEN

              FOR i IN ls_response_rec_tab.FIRST..ls_response_rec_tab.LAST LOOP

                 fnd_file.put_line(FND_FILE.LOG, '--------- START -----------------');
                 fnd_file.put_line(FND_FILE.LOG, 'ls_response_rec.Trxn_Extension_Id :    ' || ls_response_rec_tab(i).Trxn_extension_id);
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_code :    '       || ls_response_rec_tab(i).Result.Result_code);
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_Category :  ' || ls_response_rec_tab(i).Result.Result_Category);
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_Message :    '  || ls_response_rec_tab(i).Result.Result_Message);
                 fnd_file.put_line(FND_FILE.LOG, '--------- END -----------------');

              END LOOP;

            END IF;
             IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

               FOR  i IN ls_response_rec_tab.FIRST..ls_response_rec_tab.LAST   LOOP

              fnd_file.put_line(FND_FILE.LOG,'the value of ls_response_rec.Trxn_Extension_Id =   ' || (ls_response_rec_tab(i).Trxn_Extension_Id ));
               END LOOP;

             END IF;



                 FOR  i IN ls_response_rec_tab.FIRST..ls_response_rec_tab.LAST   LOOP


                        IF ls_response_rec_tab(i).Result.Result_code in ( 'SETTLEMENT_SUCCESS','SETTLEMENT_PENDING') THEN

                           fnd_file.put_line(FND_FILE.LOG,'SETTLEMENT SUCCESS FOR Trxn_Extension_Id =   '
                                 || (ls_response_rec_tab(i).Trxn_Extension_Id ));


                        ELSE
                                   ls_iby_msg_data := null;    /* initialize here */

                                   FND_MESSAGE.set_name('AR', 'AR_CC_CAPTURE_FAILED');
                                   FND_MSG_PUB.Add;
                                         ---Raise the PAYMENT error code concatenated with the message

                                          ls_iby_msg_data := substrb( ls_response_rec_tab(i).Result.Result_Code || ': '||
                                                        ls_response_rec_tab(i).Result.Result_Message , 1, 240);

                                           fnd_file.put_line(FND_FILE.LOG,  'ls_iby_msg_data: ' || ls_iby_msg_data);
                                           FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                                           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_iby_msg_data);

                                           FND_MSG_PUB.Add;

                        END IF;
                  END LOOP;

        END IF; /* l_call_settlemnt */






   /* SETTLEMENT END */

EXCEPTION
  WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Exception : process_br_payment() '|| SQLERRM );
  END IF;


END process_br_payment;


/* This Function will return the site_use_id of the site with which the bank
   account is associated. If the bank account is associated at customer
   level, then this function will return NULL. */

FUNCTION get_site_use_id(
           p_cust_account_id NUMBER,
           p_org_id NUMBER,
           p_instr_id NUMBER DEFAULT NULL,
           p_pay_trxn_extn_id NUMBER DEFAULT NULL)
RETURN NUMBER
IS
   l_cust_acct_site_id    NUMBER;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ARP_PROGRAM_BR_REMIT.get_site_use_id (+)');
   END IF;

   IF p_pay_trxn_extn_id IS NOT NULL THEN

       BEGIN
          select ep.acct_site_use_id
	  into l_cust_acct_site_id
	  from iby_pmt_instr_uses_all iu,
               iby_external_payers_all ep,
	       iby_trxn_extensions_v iby
          where iby.trxn_extension_id = p_pay_trxn_extn_id
	  and iby.instr_assignment_id = iu.instrument_payment_use_id
	  and iu.ext_pmt_party_id = ep.ext_payer_id
	  and ep.cust_account_id = p_cust_account_id
	  and ep.acct_site_use_id IS NOT NULL
	  and ep.org_id = p_org_id
	  and rownum < 2;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
	       l_cust_acct_site_id := NULL;
      END;

   ELSIF p_instr_id IS NOT NULL THEN

       BEGIN
          select ep.acct_site_use_id
	  into l_cust_acct_site_id
	  from iby_pmt_instr_uses_all iu,
               iby_external_payers_all ep
          where iu.ext_pmt_party_id = ep.ext_payer_id
	  and ep.cust_account_id = p_cust_account_id
	  and iu.instrument_payment_use_id = p_instr_id
	  and ep.acct_site_use_id IS NOT NULL
	  and ep.org_id = p_org_id
	  and rownum < 2;
       EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	       l_cust_acct_site_id := NULL;
       END;

   ELSE
       IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Error: In ARP_PROGRAM_BR_REMIT.get_site_use_id');
        arp_util.debug('>>.Payment_trxn_extn_id and instrument_assignment_id are NULL');
	arp_util.debug('>>.Either one of two should be passed while calling this function.');
       END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Site_Use_ID: '|| l_cust_acct_site_id);
      arp_util.debug('ARP_PROGRAM_BR_REMIT.get_site_use_id (-)');
   END IF;

   RETURN l_cust_acct_site_id;
END;


END  ARP_PROGRAM_BR_REMIT;

/
