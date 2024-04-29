--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_BOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_BOE" AS
/* $Header: ARREBOEB.pls 120.15.12010000.2 2010/01/28 19:50:48 aghoraka ship $ */
l_debug  VARCHAR2(30);

/* ------------ Private procedures used by the package --------------------- */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
/* Bug fix 3927024 */
l_actual_amount_total NUMBER;
l_actual_count_total  NUMBER;
l_batch_id            NUMBER;

PROCEDURE val_args_add_or_rm_remit_rec(
        p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_crh_id      IN ar_cash_receipt_history.cash_receipt_history_id%TYPE,
        p_remittance_bank_account_id IN
                   ar_cash_receipts.remit_bank_acct_use_id%type,
        p_maturity_date IN
                   ar_payment_schedules.due_date%TYPE,
        p_batch_id	IN NUMBER );

PROCEDURE val_args_add_or_rm_txn_rec(
        p_ct_id       IN ra_customer_trx.customer_trx_id%TYPE,
        p_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_paying_customer_id IN ra_customer_trx.paying_customer_id%TYPE,
        p_customer_bank_account_id IN
                   ra_customer_trx.customer_bank_account_id%TYPE );

PROCEDURE Val_Create_Auto_Batch_Submit(p_batch_id ar_batches.batch_id%TYPE);

/* ---------------------- Public functions -------------------------------- */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    add_or_rm_remit_rec_to_batch                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the create remittance batch process to add     |
 |     or remove receipts from a batch. Besides adding or removing receipts  |
 |     from a batch, the user can also change certain receipt information    |
 |     such as remittance bank account, override_remit_account_flag, bank    |
 |     charges and maturity date.                                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |     arp_cr_history_pkg.update_p - Updates CRH table bank charges info     |
 |     arp_cash_receipts_pkg.update_p- Updates CR table with remittance bank |
 |                    account, customer bank account and                     |
 |                    override_remit_account_flag			     |
 |     arp_ps_pkg.update_p - Updates maturity date in PS table.              |
 |     arp_util.debug              					     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_cr_id - Cash receipt ID                                  |
 |                p_ps_id - Payment Schedule ID                              |
 |                p_crh_id - Cash receipt History ID                         |
 |                p_selected_remittance_batch_id - This field indicates if a |
 |                    receipt has been selected to belong to a remittance    |
 |                    batch. If the field is not NULL, then the field points |
 |                    to the remittance batch, the receipt belongs to, else  |
 |                    the field is NULL.                                     |
 |                p_remittance_bank_account_id - Remittance bank account id  |
 |                    of the receipt.                                        |
 |                p_override_remit_account_flag - override_remit_account_flag|
 |                    of the receipt.                                        |
 |                p_customer_bank_account_id - Custome bank account ID of the|
 |                    receipt.                                        	     |
 |                p_bank_charges- Bank charges, to update CRH row            |
 |                p_maturity_date - Maturity date to update DUE_DATE in PS   |
 |                p_module_name - Name of module that called this proc.      |
 |                p_module_version - Version of the module that called       |
 |                                       this procedure                      |
 |              OUT:                                                         |
 |                p_batch_applied_status - currenct batch aplied status if   |
 |                   conc. req was started.                                  |
 |                p_request_id  - Request id of conc. request.               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 10/05/95                |
 |      11/20/1995 -      The procedure now calls the conc. request to start |
 |                        approval or formatting of a batch if need be       |
 |                        depending on the p_call_conc_req flag              |
 |      07/11/1996 OSTEINME	Changed code to store bank charges in        |
 |				factor_discount_amount of ar_cash_receipts   |
 |				table instead of cash_receipt_history table. |
 |				(bug 376326)			             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE add_or_rm_remit_rec_to_batch (
        p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_crh_id      IN ar_cash_receipt_history.cash_receipt_history_id%TYPE,
        p_selected_remittance_batch_id   IN
                   ar_cash_receipts.selected_remittance_batch_id%TYPE,
        p_remittance_bank_account_id IN
                   ar_cash_receipts.remit_bank_acct_use_id%type,
        p_override_remit_account_flag IN
                   ar_cash_receipts.override_remit_account_flag%TYPE,
        p_customer_bank_account_id IN
                   ar_cash_receipts.customer_bank_account_id%TYPE,
        p_bank_charges IN
                   ar_cash_receipt_history.factor_discount_amount%TYPE,
        p_maturity_date IN
                   ar_payment_schedules.due_date%TYPE,
	p_batch_id		IN NUMBER,
        p_control_count		IN NUMBER,
        p_control_amount	IN NUMBER,
        p_module_name           IN VARCHAR2,
        p_module_version        IN VARCHAR2 ) IS
--
l_cr_rec   ar_cash_receipts%ROWTYPE;
l_ps_rec   ar_payment_schedules%ROWTYPE;
l_crh_rec   ar_cash_receipt_history%ROWTYPE;
l_batch_rec	ar_batches%ROWTYPE;
--
l_approve_flag VARCHAR2(1) DEFAULT 'N';
l_format_flag VARCHAR2(1) DEFAULT 'N';
--
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'arp_process_boe.add_or_rm_remit_rec_to_batch()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'cr_id = '||to_char( p_cr_id ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'ps_id = '||to_char( p_ps_id ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'crh_id = '||to_char( p_crh_id ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'selected_remittance_batch_id = '||
				to_char( p_selected_remittance_batch_id ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'remit_bank_acct_use_id = '||
				to_char( p_remittance_bank_account_id ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'override_remit_account_flag = '||
				p_override_remit_account_flag );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'customer_bank_account_id = '||
				to_char( p_customer_bank_account_id ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'bank_charges = '||
				to_char( p_bank_charges ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'maturity_date = '||
				to_char( p_maturity_date ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'batch_id = '||
				to_char( p_batch_id ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'control_count = '||
				to_char( p_control_count ) );
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'control_amount = '||
				to_char( p_control_amount ) );
    END IF;
    --
    -- Validate input arguments
    --
    IF ( p_module_name IS NOT NULL and  p_module_version IS NOT NULL ) THEN
         val_args_add_or_rm_remit_rec( p_cr_id, p_ps_id,
                        p_crh_id, p_remittance_bank_account_id,
                        p_maturity_date, p_batch_id );
    END IF;
    --
    -- Update Cash receipts table
    --
    l_cr_rec.cash_receipt_id := p_cr_id;
    arp_cash_receipts_pkg.fetch_p( l_cr_rec );
    l_cr_rec.selected_remittance_batch_id := p_selected_remittance_batch_id;
    l_cr_rec.remit_bank_acct_use_id := p_remittance_bank_account_id;
    l_cr_rec.override_remit_account_flag := p_override_remit_account_flag;
    l_cr_rec.customer_bank_account_id := p_customer_bank_account_id;

    -- The following line was added to fix bug 376326 (see below):

    l_cr_rec.factor_discount_amount := p_bank_charges;

    arp_cash_receipts_pkg.update_p( l_cr_rec );

/* -------------------------------------------------------------------------

   Bug 376326:

   The following code has been removed, because it incorrectly
   updates the crh record of a confirmed receipt, instead of
   updating the actual cr record.  Instead, I've added the update
   of the cr.factor_discount_amount column above.  OSTEINME, 7/11/96

    --
    -- Update CRH table with bank charges
    --
    arp_cr_history_pkg.set_to_dummy( l_crh_rec );
    l_crh_rec.cash_receipt_history_id := p_crh_id;
    l_crh_rec.factor_discount_amount := p_bank_charges;
    l_crh_rec.amount := l_cr_rec.amount - NVL( p_bank_charges, 0 );
    arp_cr_history_pkg.update_p( l_crh_rec, l_crh_rec.cash_receipt_history_id );

 --------------------------------------------------------------------------*/
    --
    -- Update PS table with due date
    --
    /*--------------------------------------------------------------------
      Modified for MISC receipts remittance 377583
      Payment Schedule should be updated only for CASH receipts
     --------------------------------------------------------------------*/

    IF (p_ps_id IS NOT NULL)
    THEN
       arp_ps_pkg.set_to_dummy( l_ps_rec );
       l_ps_rec.payment_schedule_id := p_ps_id;
       l_ps_rec.due_date := p_maturity_date;
       arp_ps_pkg.update_p( l_ps_rec, l_ps_rec.payment_schedule_id );
    END IF;

    --
    -- Update Batch table with control count and control cmount
    --
  /* Bug fix 3927024 */
    IF l_batch_id IS NULL OR l_batch_id <> p_batch_id  THEN

       select nvl(control_amount,0), nvl(control_count,0)
       into l_actual_amount_total,l_actual_count_total
       from  ar_batches
       where batch_id  = p_batch_id;

       l_batch_id := p_batch_id;

    END IF;

       l_actual_count_total := l_actual_count_total + p_control_count;
       l_actual_amount_total := l_actual_amount_total + p_control_amount;

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('l_actual_count_total = '||to_char(l_actual_count_total));
       arp_standard.debug('l_actual_amount_total = '||to_char(l_actual_amount_total));
    END IF;
    /* End Bug fix 3927024 */

    arp_cr_batches_pkg.set_to_dummy( l_batch_rec );
    l_batch_rec.batch_id := p_batch_id;
    l_batch_rec.control_count := l_actual_count_total; /* Bug 3927024 */
    l_batch_rec.control_amount := l_actual_amount_total; /* bug 3927024 */
    arp_cr_batches_pkg.update_p( l_batch_rec, l_batch_rec.batch_id );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||  'arp_process_boe.add_or_rm_remit_rec_to_batch()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||
		'EXCEPTION: arp_process_boe.add_or_rm_remit_rec_to_batch' );
              END IF;
              RAISE;
              --
END add_or_rm_remit_rec_to_batch;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_args_add_or_rm_remit_rec                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to add_or_rm_remit_rec_to_batch procedure    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 10/05/95                |
 |       11/20/1995     - Added code to check batch id and which action if   |
 |                        conc. req flag is set to 'Y'                       |
 |                                                                           |
 +===========================================================================*/
PROCEDURE val_args_add_or_rm_remit_rec(
        p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_crh_id      IN ar_cash_receipt_history.cash_receipt_history_id%TYPE,
        p_remittance_bank_account_id IN
                   ar_cash_receipts.remit_bank_acct_use_id%type,
        p_maturity_date IN
                   ar_payment_schedules.due_date%TYPE,
        p_batch_id 	IN NUMBER ) IS

cr_type ar_cash_receipts.type%TYPE;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.val_args_add_or_rm_remit_rec() +');
    END IF;
    --
    /*---------------------------------------------------------------------
      Modified by Nilesh for MISC receipt remittance 377583
      Payment Schedule should exist only for CASH receipts
     ---------------------------------------------------------------------*/
--    IF ( p_cr_id is NULL OR p_ps_id is NULL OR
    IF ( p_cr_id is NULL OR
         p_crh_id is NULL OR p_remittance_bank_account_id is NULL OR
         p_maturity_date is NULL OR p_batch_id is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;

    SELECT type INTO cr_type FROM ar_cash_receipts WHERE cash_receipt_id = p_cr_id;

    IF (cr_type = 'CASH' AND p_ps_id is NULL) THEN

       FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
       APP_EXCEPTION.raise_exception;
    END IF;

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.val_args_add_or_rm_remit_rec() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
 	      IF PG_DEBUG in ('Y', 'C') THEN
 	         arp_standard.debug('val_args_add_or_rm_remit_rec: ' ||
		'EXCEPTION: arp_process_boe.val_args_add_or_rm_remit_rec' );
 	      END IF;
              RAISE;
END val_args_add_or_rm_remit_rec;
--
PROCEDURE create_remit_batch_conc_req( p_create_flag IN VARCHAR2,
              p_approve_flag IN VARCHAR2,
              p_format_flag IN VARCHAR2,
              p_batch_id IN ar_batches.batch_id%TYPE,
              p_due_date_low IN ar_payment_schedules.due_date%TYPE,
              p_due_date_high IN ar_payment_schedules.due_date%TYPE,
              p_receipt_date_low IN ar_cash_receipts.receipt_date%TYPE,
              p_receipt_date_high IN ar_cash_receipts.receipt_date%TYPE,
              p_receipt_number_low IN ar_cash_receipts.receipt_number%TYPE,
              p_receipt_number_high IN ar_cash_receipts.receipt_number%TYPE,
              p_document_number_low IN NUMBER,
              p_document_number_high IN NUMBER,
              p_customer_number_low IN hz_cust_accounts.account_number%TYPE,
              p_customer_number_high IN hz_cust_accounts.account_number%TYPE,
              p_customer_name_low IN hz_parties.party_name%TYPE,
              p_customer_name_high IN hz_parties.party_name%TYPE,
              p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
              p_location_low IN hz_cust_site_uses.location%TYPE,
              p_location_high IN hz_cust_site_uses.location%TYPE,
              p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
              p_remit_total_low IN NUMBER,
              p_remit_total_high IN NUMBER,
              p_request_id  OUT NOCOPY NUMBER,
	      p_batch_applied_status OUT NOCOPY VARCHAR2,
              p_module_name IN VARCHAR2,
              p_module_version IN VARCHAR2 ) IS
l_request_id   NUMBER;
l_bat_rec ar_batches%ROWTYPE;
l_org_id     NUMBER;
BEGIN
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.create_remit_batch_conc_req()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'Batch Id '||p_batch_id );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'create_flag = '||p_create_flag );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'Approve_flag = '||p_approve_flag );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'Format_flag = '||p_format_flag );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'batch Id = '||to_char( p_batch_id ) );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'receipt_num_low = '||p_receipt_number_low );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'receipt_nue_hi  = '||p_receipt_number_high );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'receipt_date_low = '||to_char( p_receipt_date_low ));
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'receipt_date_hi  = '||to_char( p_receipt_date_high));
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'due_date_low  = '||to_char( p_due_date_low));
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'due_date_high  = '||to_char( p_due_date_high));
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'doc_num_low  = '||to_char( p_document_number_low));
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'doc_num_high   = '||to_char( p_document_number_high));
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'cust_num_low = '||p_document_number_low );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'cust_num_high = '||p_customer_number_high );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'cust_name_low = '||p_customer_name_low );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'cust_name_high = '||p_customer_name_high );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'customer_id  = '||to_char( p_customer_id ) );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'site_use_low = '||p_location_low );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'site_use_high = '||p_location_high );
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'site_use_id  = '||to_char( p_site_use_id ) );
    END IF;
    --
    -- Validate input arguments
    --
    IF ( p_module_name IS NOT NULL and  p_module_version IS NOT NULL ) THEN
        IF ( p_batch_id IS NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    END IF;
    --
    -- Call the concurrent program
    --
    -- Shiv Ragunat , 9/11/96 ,Modified the Date parameters to convert it
    -- to DD-MON-YYYY format, so that the call succeeds for any
    -- NLS date format.
    --
    /* Bug 5190715 */
    /* Bug 5699734 - Changed the logic of getting the org_id - Getting from ar_system_parameters is more reliable */
    IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Selecting org_id from ar_system_parameters and p_batch_id : '||p_batch_id);
    END IF;
    -- l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
    SELECT org_id
      INTO l_org_id
      FROM ar_system_parameters;
    --l_org_id := nvl(mo_global.get_current_org_id, mo_utils.get_default_org_id);

    fnd_request.set_org_id(l_org_id);
    l_request_id := FND_REQUEST.submit_request( 'AR',
                                 'AUTOREMAPI', --PAYMENT_UPTAKE ARZCAR_REMIT
				 NULL,
                                 -- 'Create Automatic remittance receipt Batch',
                                 TO_CHAR(SYSDATE,'DD-MON-YYYY'),
                                 FALSE, 'REMIT',
                                 NULL, -- Batch Date
                                 NULL, -- Batch GL Date
				 p_create_flag,
				 p_approve_flag, p_format_flag, p_batch_id,
				 l_debug,
                                 NULL, -- Batch Currency
                                 NULL, -- Exchange Date
                                 NULL, -- Exchange Rate
                                 NULL, -- Exchange Rate Type
                                 NULL, -- Remit Method Code
                                 NULL, -- Receipt Class
                                 NULL, -- Payment Method
                                 NULL, -- Media Reference
                                 NULL, -- Remit Bank Branch
                                 NULL, -- Remit Bank Account
                                 NULL, -- Bank Deposit Number
                                 NULL, -- Batch Comments
                                 fnd_date.date_to_canonical(p_receipt_date_low),
				 fnd_date.date_to_canonical(p_receipt_date_high),
                                 fnd_date.date_to_canonical(p_due_date_low),
			 	 fnd_date.date_to_canonical(p_due_date_high),
                                 p_receipt_number_low,
				 p_receipt_number_high,
				 p_document_number_low,
				 p_document_number_high,
                                 p_customer_number_low,
				 p_customer_number_high,
                                 p_customer_name_low, p_customer_name_high,
                                 p_customer_id,
                                 p_location_low, p_location_high,
                                 p_site_use_id,
                                 fnd_number.number_to_canonical(p_remit_total_low),
				 fnd_number.number_to_canonical(p_remit_total_high),
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL
                                 );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_remit_batch_conc_req: ' ||  'Out Request ID = '||to_char( l_request_id ) );
    END IF;
    p_request_id := l_request_id;
    --
    --
    -- Update batches row with payment method id and batch applied status
    --
    arp_cr_batches_pkg.set_to_dummy( l_bat_rec );
    l_bat_rec.batch_id := p_batch_id;
    l_bat_rec.operation_request_id := l_request_id;
    IF ( p_create_flag = 'Y' ) THEN
        l_bat_rec.batch_applied_status := 'STARTED_CREATION';
    ELSIF ( p_approve_flag = 'Y' ) THEN
        l_bat_rec.batch_applied_status := 'STARTED_APPROVAL';
    ELSE
        l_bat_rec.batch_applied_status := 'STARTED_FORMAT';
    END IF;
    --
    arp_cr_batches_pkg.update_p( l_bat_rec, l_bat_rec.batch_id );
    p_batch_applied_status := l_bat_rec.batch_applied_status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.create_remit_batch_conc_req()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('create_remit_batch_conc_req: ' ||
                'EXCEPTION: arp_process_boe.create_remit_batch_conc_req' );
              END IF;
              RAISE;
              --
END create_remit_batch_conc_req;
--
--
--
PROCEDURE app_fmt_remit_batch_conc_req( p_approve_flag IN VARCHAR2,
              p_format_flag IN VARCHAR2,
              p_batch_id IN ar_batches.batch_id%TYPE,
              p_request_id  OUT NOCOPY NUMBER,
	      p_batch_applied_status OUT NOCOPY VARCHAR2,
              p_module_name IN VARCHAR2,
              p_module_version IN VARCHAR2 ) IS
l_request_id  NUMBER;
l_bat_rec  ar_batches%ROWTYPE;
l_org_id     NUMBER;
BEGIN
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.app_fmt_remit_batch_conc_req()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('app_fmt_remit_batch_conc_req: ' ||  'Batch Id '||p_batch_id );
       arp_standard.debug('app_fmt_remit_batch_conc_req: ' ||  'Approve_flag = '||p_approve_flag );
       arp_standard.debug('app_fmt_remit_batch_conc_req: ' ||  'Format_flag = '||p_format_flag );
    END IF;
    --
    IF ( p_module_name IS NOT NULL and  p_module_version IS NOT NULL ) THEN
        IF ( p_batch_id IS NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    END IF;
    --
    -- Call the concurrent program
    --
  /* Additional Fix identified as a part of Bug 5699734 */
  /* Bug 5699734 - Changed logic to get org_id - Getting from ar_system_parameters would be more reliable */
--l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
   IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Selecting org_id from ar_system_parameters and p_batch_id : '||p_batch_id);
   END IF;
   SELECT org_id
     INTO l_org_id
     FROM ar_system_parameters;
--  l_org_id := nvl(mo_global.get_current_org_id, mo_utils.get_default_org_id);
  /* Fix bug 5699734 ends */

  fnd_request.set_org_id(l_org_id);

  /* Adding additional debug messages - As a part of Bug 5699734 */
  IF  PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('app_fmt_remit_batch_conc_req: Submitting Conc Req for Approve/Format Remittance Receipt Batch with org : ' ||l_org_id);
  END IF;
  /* End of additional Debug messages */
    l_request_id := FND_REQUEST.submit_request( 'AR',
                                 'AUTOREMAPI', --PAYMENT_UPTAKE ARZCAR_REMIT
				 NULL,
                                 -- 'Approve/Format Remittance Receipt Batch',
                                 SYSDATE, FALSE, 'REMIT',
                                 NULL, -- Batch Date
                                 NULL, -- Batch GL Date
				 'N', -- p_create_flag,
				 p_approve_flag, p_format_flag, p_batch_id,
				 l_debug,
                                 NULL, -- Batch Currency
                                 NULL, -- Exchange Date
                                 NULL, -- Exchange Rate
                                 NULL, -- Exchange Rate Type
                                 NULL, -- Remit Method Code
                                 NULL, -- Receipt Class
                                 NULL, -- Payment Method
                                 NULL, -- Media Reference
                                 NULL, -- Remit Bank Branch
                                 NULL, -- Remit Bank Account
                                 NULL, -- Bank Deposit Number
                                 NULL, -- Batch Comments
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL,
                                 NULL, NULL,
                                 NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL
                                  );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('app_fmt_remit_batch_conc_req: ' ||  'Out Request ID = '||to_char( l_request_id ) );
    END IF;
    p_request_id := l_request_id;
    --
    -- Update batch to set batch applied_status
    --
    arp_cr_batches_pkg.set_to_dummy( l_bat_rec );
    l_bat_rec.batch_id := p_batch_id;
    l_bat_rec.operation_request_id := l_request_id;
    IF ( p_approve_flag = 'Y' ) THEN
        l_bat_rec.batch_applied_status := 'STARTED_APPROVAL';
    ELSE
        l_bat_rec.batch_applied_status := 'STARTED_FORMAT';
    END IF;
    arp_cr_batches_pkg.update_p( l_bat_rec, l_bat_rec.batch_id );
    p_batch_applied_status := l_bat_rec.batch_applied_status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.app_fmt_remit_batch_conc_req()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('app_fmt_remit_batch_conc_req: ' ||
                'EXCEPTION: arp_process_boe.app_fmt_remit_batch_conc_req' );
              END IF;
              RAISE;
              --
END app_fmt_remit_batch_conc_req;
--
PROCEDURE app_fmt_auto_batch_conc_req( p_approve_flag IN VARCHAR2,
              p_format_flag IN VARCHAR2,
              p_batch_id IN ar_batches.batch_id%TYPE,
              p_request_id  OUT NOCOPY NUMBER,
	      p_batch_applied_status OUT NOCOPY VARCHAR2,
              p_module_name IN VARCHAR2,
              p_module_version IN VARCHAR2 ) IS
l_request_id  NUMBER;
l_bat_rec  ar_batches%ROWTYPE;
l_org_id     NUMBER;
BEGIN
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.app_fmt_auto_batch_conc_req()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('app_fmt_auto_batch_conc_req: ' ||  'Batch Id '||p_batch_id );
       arp_standard.debug('app_fmt_auto_batch_conc_req: ' ||  'Approve_flag = '||p_approve_flag );
       arp_standard.debug('app_fmt_auto_batch_conc_req: ' ||  'Format_flag = '||p_format_flag );
    END IF;
    --
    IF ( p_module_name IS NOT NULL and  p_module_version IS NOT NULL ) THEN
        IF ( p_batch_id IS NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    END IF;
    --
    -- Call the concurrent program
    --
/* Additional Fix identified as a part of Bug 5699734*/
/* Bug 5699734 - Changed the logic of getting org_id - Getting from ar_system_parameters would be more reliable */
--l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
 IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Selecting org_id from ar_system_parameters and p_batch_id : '||p_batch_id);
 END IF;
 SELECT org_id
   INTO l_org_id
   FROM ar_system_parameters;
--l_org_id := nvl(mo_global.get_current_org_id, mo_utils.get_default_org_id);
/* Fix for bug 5699734 ends */

fnd_request.set_org_id(l_org_id);

/* Additional Debug Messages as a part of bug 5699734*/
IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug('app_fmt_auto_batch_conc_req: Submitting Conc Req Approve/Format Automatic receipt Batch with org :'||l_org_id);
END IF;
/* Additional debug messages ends */

    l_request_id := FND_REQUEST.submit_request( 'AR',
                                 'AR_AUTORECAPI', -- PAYMENT_UPTAKE ARZCAR_RECEIPT
				 NULL,
                                 -- 'Approve/Format Automatic receipt Batch',
                                 SYSDATE, FALSE, 'RECEIPT',
                                 NULL, -- Batch Date
                                 NULL, -- Batch GL Date
				 'N', -- p_create_flag,
				 p_approve_flag, p_format_flag, p_batch_id,
				 l_debug,
                                 NULL, -- Batch Currency
                                 NULL, -- Exchange Date
                                 NULL, -- Exchange Rate
                                 NULL, -- Exchange Rate Type
                                 NULL, -- Remit Method Code
                                 NULL, -- Receipt Class
                                 NULL, -- Payment Method
                                 NULL, -- Media Reference
                                 NULL, -- Remit Bank Branch
                                 NULL, -- Remit Bank Account
                                 NULL, -- Bank Deposit Number
                                 NULL, -- Batch Comments
 				 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL,
                                 NULL, NULL,
                                 NULL,
                                 NULL, NULL,
                                 NULL, NULL,
                                 NULL, NULL
                                 );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('app_fmt_auto_batch_conc_req: ' ||  'Out Request ID = '||to_char( l_request_id ) );
    END IF;
    p_request_id := l_request_id;
    --
    --
    -- Update batch to set batch applied_status
    --
    arp_cr_batches_pkg.set_to_dummy( l_bat_rec );
    l_bat_rec.batch_id := p_batch_id;
    l_bat_rec.operation_request_id := l_request_id;
    IF ( p_approve_flag = 'Y' ) THEN
        l_bat_rec.batch_applied_status := 'STARTED_APPROVAL';
    ELSE
        l_bat_rec.batch_applied_status := 'STARTED_FORMAT';
    END IF;
    arp_cr_batches_pkg.update_p( l_bat_rec, l_bat_rec.batch_id );
    p_batch_applied_status := l_bat_rec.batch_applied_status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.app_fmt_auto_batch_conc_req()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('app_fmt_auto_batch_conc_req: ' ||
                'EXCEPTION: arp_process_boe.app_fmt_auto_batch_conc_req' );
              END IF;
              RAISE;
              --
END app_fmt_auto_batch_conc_req;
--
PROCEDURE create_auto_batch_conc_req( p_create_flag IN VARCHAR2,
              p_approve_flag IN VARCHAR2,
              p_format_flag IN VARCHAR2,
              p_batch_id IN ar_batches.batch_id%TYPE,
              p_due_date_low IN ar_payment_schedules.due_date%TYPE,
              p_due_date_high IN ar_payment_schedules.due_date%TYPE,
              p_trx_date_low IN ra_customer_trx.trx_date%TYPE,
              p_trx_date_high IN ra_customer_trx.trx_date%TYPE,
              p_trx_number_low IN ra_customer_trx.trx_number%TYPE,
              p_trx_number_high IN ra_customer_trx.trx_number%TYPE,
              p_document_number_low IN NUMBER,
              p_document_number_high IN NUMBER,
              p_customer_number_low IN hz_cust_accounts.account_number%TYPE,
              p_customer_number_high IN hz_cust_accounts.account_number%TYPE,
              p_customer_name_low IN hz_parties.party_name%TYPE,
              p_customer_name_high IN hz_parties.party_name%TYPE,
              p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
              p_location_low IN hz_cust_site_uses.location%TYPE,
              p_location_high IN hz_cust_site_uses.location%TYPE,
              p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
              p_billing_number_low IN ar_cons_inv.cons_billing_number%TYPE,
              p_billing_number_high IN ar_cons_inv.cons_billing_number%TYPE,
              p_request_id  OUT NOCOPY NUMBER,
	      p_batch_applied_status OUT NOCOPY VARCHAR2,
              p_module_name IN VARCHAR2,
              p_module_version IN VARCHAR2,
	      p_bank_account_low IN VARCHAR2,
	      p_bank_account_high IN VARCHAR2 ) IS

l_request_id   NUMBER;
l_bat_rec ar_batches%ROWTYPE;
l_org_id     NUMBER;
l_program_name   ap_payment_programs.program_name%TYPE;
l_batch_app_status ar_batches.batch_applied_status%TYPE;
BEGIN
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.create_auto_batch_conc_req()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'create_flag = '||p_create_flag );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'Approve_flag = '||p_approve_flag );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'Format_flag = '||p_format_flag );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'batch Id = '||to_char( p_batch_id ) );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'trx_num_low = '||p_trx_number_low );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'trx_num_hi  = '||p_trx_number_high );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'trx_date_low = '||to_char( p_trx_date_low ));
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'trx_date_hi      = '||to_char( p_trx_date_high));
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'due_date_low  = '||to_char( p_due_date_low));
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'due_date_high  = '||to_char( p_due_date_high));
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'doc_num_low  = '||to_char( p_document_number_low));
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'doc_num_high   = '||to_char( p_document_number_high));
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'cust_num_low = '||p_document_number_low );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'cust_num_high = '||p_customer_number_high );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'cust_name_low = '||p_customer_name_low );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'cust_name_high = '||p_customer_name_high );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'customer_id  = '||to_char( p_customer_id ) );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'site_use_low = '||p_location_low );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'site_use_high = '||p_location_high );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'site_use_id  = '||to_char( p_site_use_id ) );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'billing_number_low  = '||  p_billing_number_low );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'billing_number_high  = '||  p_billing_number_high );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'bank_account_low  = '||  p_bank_account_low );
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'bank_account_high  = '||  p_bank_account_high );
    END IF;
    --
    -- Validate input arguments
    --
    IF ( p_module_name IS NOT NULL ) THEN
        IF ( p_batch_id IS NULL ) THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
        END IF;
    END IF;

    ARP_PROCESS_BOE.Val_Create_Auto_Batch_Submit(p_batch_id);

    --
    -- Call the concurrent program
    --
    -- Shiv Ragunat , 9/11/96 ,Modified the Date parameters to convert it
    -- to DD-MON-YYYY format, so that the call succeeds for any
    -- NLS date format.
    --
/* Fix for Bug 5699734 - Wrong org being set because of FND_PROFILE.value('ORG_ID') */
/* Bug 5699734 - Changed logic for getting the org_id - Getting from ar_system_parameters would be more reliable */
--l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
  IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Selecting org_id from ar_system_parameters and p_batch_id : '||p_batch_id);
  END IF;
   SELECT org_id
     INTO l_org_id
     FROM ar_system_parameters;
--l_org_id := nvl(mo_global.get_current_org_id, mo_utils.get_default_org_id);
/* Fix for Bug 5699734 ends */

fnd_request.set_org_id(l_org_id);

/* Additional Debug Messages as a part of Bug 5699734 */
IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug('create_auto_batch_conc_req: Submitting Conc Req Create Automatic Receipts with org :'||l_org_id);
END IF;
/* Additional Debug Messages ends */

    l_request_id := FND_REQUEST.submit_request( 'AR',
                                 'AR_AUTORECAPI', -- PAYMENT_UPTAKE ARZCAR_RECEIPT
				 NULL,
                                 -- 'Create Automatic Receipts',
                                 TO_CHAR(SYSDATE,'DD-MON-YYYY'),
                                 FALSE, 'RECEIPT',
                                 NULL, -- Batch Date
                                 NULL, -- Batch GL Date
				 p_create_flag,
				 p_approve_flag, p_format_flag, p_batch_id,
				 l_debug,
                                 NULL, -- Batch Currency
                                 NULL, -- Exchange Date
                                 NULL, -- Exchange Rate
                                 NULL, -- Exchange Rate Type
                                 NULL, -- Remit Method Code
                                 NULL, -- Receipt Class
                                 NULL, -- Payment Method
                                 NULL, -- Media Reference
                                 NULL, -- Remit Bank Branch
                                 NULL, -- Remit Bank Account
                                 NULL, -- Bank Deposit Number
                                 NULL, -- Batch Comments
                                 fnd_date.date_to_canonical(p_trx_date_low),
                                 fnd_date.date_to_canonical(p_trx_date_high),
                                 fnd_date.date_to_canonical(p_due_date_low),
                                 fnd_date.date_to_canonical(p_due_date_high),
                                 p_trx_number_low, p_trx_number_high,
                                 p_document_number_low, p_document_number_high,
                                 p_customer_number_low, p_customer_number_high,
                                 p_customer_name_low, p_customer_name_high,
                                 p_customer_id,
                                 p_location_low, p_location_high,
                                 p_site_use_id,
                                 NULL, NULL,
                                 p_billing_number_low, p_billing_number_high,
                                 p_bank_account_low, p_bank_account_high
                                );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('create_auto_batch_conc_req: ' ||  'Out Request ID = '||to_char( l_request_id ) );
    END IF;
    p_request_id := l_request_id;
    --
    -- Update batch record to set batch applied status
    --
    arp_cr_batches_pkg.set_to_dummy( l_bat_rec );
    l_bat_rec.batch_id := p_batch_id;
    l_bat_rec.operation_request_id := l_request_id;
    --
    IF ( p_create_flag = 'Y' ) THEN
        l_bat_rec.batch_applied_status := 'STARTED_CREATION';
    ELSIF ( p_approve_flag = 'Y' ) THEN
        l_bat_rec.batch_applied_status := 'STARTED_APPROVAL';
    ELSE
    	SELECT 	bat.batch_applied_status,
               	app.program_name
  	INTO   	l_batch_app_status,
	        l_program_name
  	FROM   	ar_batches bat,
	        ar_receipt_methods rm,
		ap_payment_programs app
  	WHERE  	bat.batch_id = p_batch_id
  	AND	bat.receipt_method_id = rm.receipt_method_id
  	AND	rm.auto_print_program_id = app.program_id;

 	IF ( l_program_name = 'ARSEPADNT')  THEN
      	  IF l_batch_app_status <> 'COMPLETED_FORMAT' THEN
            UPDATE  ar_cash_receipts
            SET     seq_type_last = 'Y'
            WHERE   cash_receipt_id IN (
		SELECT crh.cash_receipt_id
		FROM   ar_cash_receipt_history crh,
		       ar_receivable_applications ra,
                       ra_customer_trx ct,
                       iby_fndcpt_tx_extensions ext
               	WHERE crh.batch_id = p_batch_id
		AND   crh.current_record_flag = 'Y'
		AND   crh.status = 'CONFIRMED'
		AND   ra.cash_receipt_id = crh.cash_receipt_id
                AND   ra.application_type = 'CASH'
                AND   ra.status = 'APP'
                AND   ct.customer_trx_id = ra.applied_customer_trx_id
                AND   ext.trxn_extension_id = ct.payment_trxn_extension_id
                AND   NVL(ext.seq_type_last, 'N') = 'Y');
          END IF;
      END IF;
        l_bat_rec.batch_applied_status := 'STARTED_FORMAT';
    END IF;
    --
    arp_cr_batches_pkg.update_p( l_bat_rec, l_bat_rec.batch_id );
    p_batch_applied_status := l_bat_rec.batch_applied_status;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.create_auto_batch_conc_req()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('create_auto_batch_conc_req: ' ||
                'EXCEPTION: arp_process_boe.create_auto_batch_conc_req' );
              END IF;
              RAISE;
              --
END create_auto_batch_conc_req;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    add_or_rm_txn_from_auto_batch                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure called during the create/approve of automatic receipts batch |
 |     to remove or add an invoice to be automatically paid.                 |
 |     The user can change certain invoice information such as paying custome|
 |     and customer bank account.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |     arp_ct_pkg.update_p - Updates paying_customer_id and                  |
 |                           p_customer_bank_account_id in RA_CUSTOMER_TRX   |
 |     arp_ps_pkg.update_p - Updates selected_for_receipt_batch_id in PS tab.|
 |     arp_util.debug                                                        |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_ct_id - Customer Trx ID                                  |
 |                p_ps_id - Payment Schedule ID                              |
 |                p_selected_for_rec_batch_id - This field indicates if an   |
 |                    invoice has been selected to be paid by a receipt e    |
 |                    belonging to an automatic batch. Note: This field is   |
 |		      used to update the PS table and the RA_CUSTOMER_TRX    |
 |		      table.                                                 |
 |                p_paying_customer_id - Paying customer of the invoice.     |
 |                p_customer_bank_account_id - Custome bank account ID of the|
 |                    invoice.                                               |
 |                p_module_version - Version of the module that called       |
 |                                       this procedure                      |
 |              OUT:                                                         |
 |                p_batch_applied_status - currenct batch aplied status if   |
 |                   conc. req was started.                                  |
 |                p_request_id  - Request id of conc. request.               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 10/05/95                |
 |       11/20/1995 -     The procedure now calls the conc. request to start |
 |                        approval or formatting of a batch if need be       |
 |                        depending on the p_call_conc_req flag              |
 |                                                                           |
 +===========================================================================*/
PROCEDURE add_or_rm_txn_from_auto_batch(
        p_ct_id       IN ra_customer_trx.customer_trx_id%TYPE,
        p_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_selected_for_rec_batch_id   IN
                   ar_payment_schedules.selected_for_receipt_batch_id%TYPE,
        p_paying_customer_id IN ra_customer_trx.paying_customer_id%TYPE,
        p_customer_bank_account_id IN
                   ra_customer_trx.customer_bank_account_id%TYPE,
        p_module_name           IN VARCHAR2,
        p_module_version        IN VARCHAR2 ) IS
l_ct_rec    ra_customer_trx%ROWTYPE;
l_ps_rec    ar_payment_schedules%ROWTYPE;
--
l_approve_flag VARCHAR2(1) DEFAULT 'N';
l_format_flag VARCHAR2(1) DEFAULT 'N';
--
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.add_or_rm_txn_from_auto_batch()+');
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('add_or_rm_txn_from_auto_batch: ' ||  'ct_id = '||to_char( p_ct_id ) );
       arp_standard.debug('add_or_rm_txn_from_auto_batch: ' ||  'ps_id = '||to_char( p_ps_id ) );
       arp_standard.debug('add_or_rm_txn_from_auto_batch: ' ||  'p_selected_for_rec_batch_id = '||
                                to_char( p_selected_for_rec_batch_id ) );
       arp_standard.debug('add_or_rm_txn_from_auto_batch: ' ||  'customer_bank_account_id = '||
                                to_char( p_customer_bank_account_id ) );
       arp_standard.debug('add_or_rm_txn_from_auto_batch: ' ||  'paying_customer_id = '||
                                to_char( p_paying_customer_id ) );
    END IF;
    --
    -- Validate input arguments
    --
    IF ( p_module_name IS NOT NULL and  p_module_version IS NOT NULL ) THEN
         val_args_add_or_rm_txn_rec( p_ct_id, p_ps_id,
                        p_paying_customer_id, p_customer_bank_account_id );

    END IF;
    --
    -- Update Cash receipts table
    --
    arp_ct_pkg.set_to_dummy( l_ct_rec );
    l_ct_rec.customer_trx_id := p_ct_id;
    l_ct_rec.paying_customer_id := p_paying_customer_id;
    l_ct_rec.customer_bank_account_id := p_customer_bank_account_id;
    arp_ct_pkg.update_p( l_ct_rec, l_ct_rec.customer_trx_id );
    --
    -- Update PS table with due date
    --
    arp_ps_pkg.set_to_dummy( l_ps_rec );
    l_ps_rec.payment_schedule_id := p_ps_id;
    l_ps_rec.selected_for_receipt_batch_id := p_selected_for_rec_batch_id;
    arp_ps_pkg.update_p( l_ps_rec, l_ps_rec.payment_schedule_id );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.add_or_rm_txn_from_auto_batch()-');
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('add_or_rm_txn_from_auto_batch: ' ||
                'EXCEPTION: arp_process_boe.add_or_rm_txn_from_auto_batch');
              END IF;
              RAISE;
              --
END add_or_rm_txn_from_auto_batch;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_args_add_or_rm_txn_rec                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to dd_or_rm_txn_from_auto_batch procedure    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_ct_id - Customer Trx ID                                  |
 |                p_ps_id - Payment Schedule ID                              |
 |                p_paying_customer_id - Paying customer of the invoice.     |
 |                p_customer_bank_account_id - Custome bank account ID of the|
 |                    invoice.                                               |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 10/05/95                |
 |       11/20/1995     - Added code to check batch id and which action if   |
 |                        conc. req flag is set to 'Y'                       |
 |                                                                           |
 +===========================================================================*/
PROCEDURE val_args_add_or_rm_txn_rec(
        p_ct_id       IN ra_customer_trx.customer_trx_id%TYPE,
        p_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_paying_customer_id IN ra_customer_trx.paying_customer_id%TYPE,
        p_customer_bank_account_id IN
                   ra_customer_trx.customer_bank_account_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.val_args_add_or_rm_txn_rec() +');
    END IF;
    --
    IF ( p_ct_id is NULL OR p_ps_id is NULL OR
         p_paying_customer_id is NULL) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_process_boe.val_args_add_or_rm_txn_rec() -');
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   arp_standard.debug('val_args_add_or_rm_txn_rec: ' ||
		 'EXCEPTION: arp_process_boe.val_args_add_or_rm_txn_rec' );
		END IF;
              RAISE;
END val_args_add_or_rm_txn_rec;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Val_Create_Auto_Batch_Submit                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks whether Automatic Receipt Creation Batch can be submitted       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_batch_id                                               |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by J Rautiainen BugFix 951138 - 15-SEP-1999|
 |                                                                           |
 +===========================================================================*/
PROCEDURE Val_Create_Auto_Batch_Submit(p_batch_id ar_batches.batch_id%TYPE) IS

  /* 15-SEP-1999 J Rautiainen BugFix 951138 Start
   * Need the payment method name and batch date in order to check
   * whether an active document sequence assignment exists for the
   * payment method. Automatic Receipt Creation process cannot submitted
   * if an active document sequence assignment does not exist */

  CURSOR batch_cursor IS
    select rm.name rm_name, b.batch_date batch_date
    from ar_receipt_methods rm,
         ar_batches b
    where b.batch_id = p_batch_id
    AND rm.receipt_method_id = b.receipt_method_id;

  l_batch_rec batch_cursor%ROWTYPE;
  l_doc_seq_result NUMBER :=0;
  l_Doc_Sequence_ID number;
  l_Sequence_Type char;
  l_Sequence_Name varchar2(30);
  l_DB_Seq_Gen_Name varchar2(30);
  l_Sequence_Assignment_Id number;
  l_Product_Table_Name varchar2(30);
  l_Audit_Table_name varchar2(30);
  l_Message_Flag char;

BEGIN

  /* Automatic Receipt Creation process cannot submitted
   * if an active document sequence assignment does not exist
   * or the profile option Sequential Numbering is set to 'Not Used' */

  IF (fnd_profile.value('UNIQUE:SEQ_NUMBERS') in (NULL, 'N' )) THEN

    /* Cannot submit Automatic Receipt Creation process because the profile option
     * Sequential Numbering is set to Not Used. Please set this option to Always Used
     * or Partially Used, then resubmit.  */

    FND_MESSAGE.set_name ('AR', 'AR_RW_AUTOBAT_SEQ_NOT_USED');
    APP_EXCEPTION.raise_exception;

  ELSE
    /* Fetch the payment method code and batch date */

    OPEN batch_cursor;
    FETCH batch_cursor INTO l_batch_rec;

    IF batch_cursor%FOUND THEN
      /* If an payment method was found check that an active automatic document
       * sequence assignment exists for it */

      l_doc_seq_result := FND_SEQNUM.GET_SEQ_INFO(
                                222,
                                l_batch_rec.rm_name,
                                arp_global.set_of_books_id,
                                'A',
                                l_batch_rec.batch_date,
                                l_Doc_Sequence_ID,
                                l_Sequence_Type,
                                l_Sequence_Name,
                                l_DB_Seq_Gen_Name,
                                l_Sequence_Assignment_Id,
                                l_Product_Table_Name,
                                l_Audit_Table_name,
                                l_Message_Flag,
                                'Y',
                                'Y');

      /* If 0 is returned an assignment exists, otherwise an error occured */
      IF l_doc_seq_result <> 0 THEN

        /* Cannot submit Automatic Receipt Creation process because an active document
         * sequence assignment does not exist for this payment method. Please define a
         * document sequence assignment or enter a different payment method. */
        CLOSE batch_cursor;
        FND_MESSAGE.set_name ('AR', 'AR_RW_AUTOBAT_NO_PM_ASSIGNMENT');
        APP_EXCEPTION.raise_exception;

      END IF;
    END IF;

    CLOSE batch_cursor;
  END IF;

END Val_Create_Auto_Batch_Submit;
--
BEGIN
  l_debug := fnd_profile.value('AFLOG_ENABLED');
  IF (l_debug <> 'Y') THEN
     l_debug := 'N';
  END IF;
END ARP_PROCESS_BOE;

/
