--------------------------------------------------------
--  DDL for Package Body ARP_PROC_RCT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROC_RCT_UTIL" AS
/* $Header: ARRURGWB.pls 120.29.12010000.3 2009/11/30 09:30:06 spdixit ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
SUBTYPE l_ae_doc_rec_type IS arp_acct_main.ae_doc_rec_type ;

/* =======================================================================
 | Global Data Types
 * ======================================================================*/

-- ***************** BEGIN Private Procedures: **********************
-- ***************** END Private Procedures: **********************

FUNCTION revision RETURN VARCHAR2 IS
BEGIN

   RETURN '$Revision: 120.29.12010000.3 $';

END revision;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_ps_rec_cash                          			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a payment schedule record for a cash receipt                   |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    8-SEP-95	OSTEINME	created					     |
 |   12-JUL-96  OSTEINME	now populates gl_date_closed with 12-31-4712 |
 | 				to avoid problems if DB trigger is not       |
 |				installed. Same for actual_date_closed.      |
 |                                                                           |
 +===========================================================================*/


Procedure insert_ps_rec_cash(
	p_cr_rec	IN  ar_cash_receipts%ROWTYPE,
	p_gl_date	IN  DATE,
	p_maturity_date IN  DATE,
	p_acctd_amount	IN
		ar_payment_schedules.acctd_amount_due_remaining%TYPE,
        p_ps_id		OUT NOCOPY
		ar_payment_schedules.payment_schedule_id%TYPE
				) IS

l_ps_rec	  ar_payment_schedules%ROWTYPE;
l_ps_id		  ar_payment_schedules.payment_schedule_id%TYPE;

l_status          ar_cash_receipt_history.status%TYPE;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_rct_util.insert_ps_rec_cash()+');
  END IF;

  -- fill record columns with data from cash receipt:

  l_ps_rec.due_date			:= p_maturity_date;
  l_ps_rec.gl_date			:= p_gl_date;
  l_ps_rec.amount_due_original 		:= -p_cr_rec.amount;
  l_ps_rec.amount_due_remaining		:= -p_cr_rec.amount;
  l_ps_rec.acctd_amount_due_remaining	:= -p_acctd_amount;
  l_ps_rec.number_of_due_dates		:= 1;
  l_ps_rec.status			:= 'OP';
  l_ps_rec.invoice_currency_code	:= p_cr_rec.currency_code;
  l_ps_rec.class			:= 'PMT';
  l_ps_rec.cust_trx_type_id		:= NULL;
  l_ps_rec.customer_id			:= p_cr_rec.pay_from_customer;
  l_ps_rec.customer_site_use_id		:= p_cr_rec.customer_site_use_id;
  l_ps_rec.cash_receipt_id		:= p_cr_rec.cash_receipt_id;
  l_ps_rec.associated_cash_receipt_id	:= p_cr_rec.cash_receipt_id;
  l_ps_rec.gl_date_closed		:= TO_DATE('12/31/4712','MM/DD/YYYY');
  l_ps_rec.actual_date_closed		:= TO_DATE('12/31/4712','MM/DD/YYYY');
  l_ps_rec.amount_applied		:= NULL;
  l_ps_rec.exchange_rate_type		:= p_cr_rec.exchange_rate_type;
  l_ps_rec.exchange_rate		:= p_cr_rec.exchange_rate;
  l_ps_rec.exchange_date		:= p_cr_rec.exchange_date;
  l_ps_rec.trx_number			:= p_cr_rec.receipt_number;
  l_ps_rec.trx_date			:= p_cr_rec.receipt_date;

  /* bug 5569488, set confirmed flag to N if the status is APPROVED */
  select status
  into l_status
  from  ar_cash_receipt_history
  where cash_receipt_id = p_cr_rec.cash_receipt_id
  and   current_record_flag = 'Y' ;

  IF l_status = 'APPROVED' THEN
    l_ps_rec.receipt_confirmed_flag := 'N' ;
  END IF ;

  --insert record into payment schedule table:

    arp_ps_pkg.insert_p(l_ps_rec, l_ps_id);

  p_ps_id := l_ps_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_rct_util.insert_ps_rec_cash()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION: arp_process_rct_util.insert_ps_rec_cash()');
      END IF;
      RAISE;

END insert_ps_rec_cash;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_crh_rec                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Creates a new record in AR_CASH_RECEIPT_HISTORY for a new cash or	     |
 |    misc receipt.							     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    08-SEP-95	OSTEINME	created					     |
 |    04-NOV-96 OSTEINME	modified for Japan enhancements:	     |
 |				added new parameters for bank charges        |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_crh_rec(
	p_cr_rec		IN  ar_cash_receipts%ROWTYPE,
	p_crh_amount		IN  ar_cash_receipt_history.amount%TYPE,
	p_acctd_amount		IN  ar_cash_receipt_history.acctd_amount%TYPE,
	p_factor_discount_amount IN
		ar_cash_receipt_history.factor_discount_amount%TYPE,
	p_acctd_factor_discount_amount IN
		ar_cash_receipt_history.acctd_factor_discount_amount%TYPE,
	p_gl_date		IN  DATE,
	p_creation_status 	IN  VARCHAR2,
	p_batch_id		IN  ar_cash_receipt_history.batch_id%TYPE,
	p_ccid			IN
		ar_cash_receipt_history.account_code_combination_id%TYPE,
	p_bank_charges_ccid	IN
		ar_cash_receipt_history.bank_charge_account_ccid%TYPE,
	p_crh_rec		OUT NOCOPY ar_cash_receipt_history%ROWTYPE,
	p_called_from      IN  VARCHAR2 DEFAULT NULL
				) IS

l_crh_rec	ar_cash_receipt_history%ROWTYPE;
l_crh_id	ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_dummy		NUMBER;
--Bug#2750340
l_xla_ev_rec   arp_xla_events.xla_events_type;

BEGIN
  arp_standard.debug('arp_process_rct_util.insert_crh_rec()+');

  -- fill record columns with data from cash receipt:

  l_crh_rec.amount			:= p_crh_amount;
  l_crh_rec.acctd_amount		:= p_acctd_amount;
  l_crh_rec.cash_receipt_id		:= p_cr_rec.cash_receipt_id;
  l_crh_rec.factor_flag			:= 'N';

  /* bug5569488, set the first_posted_record_flag and postable_flag to N,
  for receipts which requires confirmation, else set to Y. */
  IF p_creation_status = 'APPROVED' THEN
    l_crh_rec.first_posted_record_flag := 'N' ;
    l_crh_rec.postable_flag            := 'N' ;
  ELSE
    l_crh_rec.first_posted_record_flag  := 'Y' ;
    l_crh_rec.postable_flag             := 'Y' ;
  END IF ;

  l_crh_rec.gl_date			:= p_gl_date;
--  l_crh_rec.postable_flag		:= 'Y';                      -- bug 5569488, commented and replaced above
  l_crh_rec.status			:= p_creation_status;
  l_crh_rec.trx_date			:= p_cr_rec.receipt_date;
  l_crh_rec.acctd_factor_discount_amount:= p_acctd_factor_discount_amount;
  l_crh_rec.factor_discount_amount	:= p_factor_discount_amount;
  l_crh_rec.account_code_combination_id := p_ccid;
  l_crh_rec.batch_id			:= p_batch_id;
  l_crh_rec.current_record_flag		:= 'Y';
  l_crh_rec.exchange_date		:= p_cr_rec.exchange_date;
  l_crh_rec.exchange_rate		:= p_cr_rec.exchange_rate;
  l_crh_rec.exchange_rate_type		:= p_cr_rec.exchange_rate_type;
  l_crh_rec.gl_posted_date		:= NULL;
  l_crh_rec.posting_control_id		:= -3;
  l_crh_rec.reversal_cash_receipt_hist_id := NULL;
  l_crh_rec.reversal_gl_date		:= NULL;
  l_crh_rec.reversal_gl_posted_date	:= NULL;
  l_crh_rec.reversal_posting_control_id := NULL;
  l_crh_rec.request_id			:= NULL;
  l_crh_rec.program_application_id	:= NULL;
  l_crh_rec.program_id			:= NULL;
  l_crh_rec.program_update_date		:= NULL;

  --BUG 7555125
  IF p_called_from is null THEN
    l_crh_rec.created_from := 'ARRERGW';
  ELSE
    l_crh_rec.created_from := p_called_from;
  END IF;

  -- populate bank charge ccid only if there is actually a bank
  -- charge amount:

  IF (p_factor_discount_amount IS NULL) THEN
    l_crh_rec.bank_charge_account_ccid := NULL;
  ELSE
    l_crh_rec.bank_charge_account_ccid	:= p_bank_charges_ccid;
  END IF;

  arp_cr_history_pkg.insert_p(l_crh_rec, l_crh_id);

  l_crh_rec.cash_receipt_history_id := l_crh_id;

  p_crh_rec := l_crh_rec;	-- return crh record

  --Bug2750340
  IF NVL(p_called_from, 'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2','CUSTRECAPIBULK') THEN
       l_xla_ev_rec.xla_from_doc_id := p_cr_rec.cash_receipt_id;
       l_xla_ev_rec.xla_to_doc_id   := p_cr_rec.cash_receipt_id;
       l_xla_ev_rec.xla_doc_table   := 'CRH';
       l_xla_ev_rec.xla_mode        := 'O';
       l_xla_ev_rec.xla_call        := 'B';
       ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
   END IF;

  arp_standard.debug('arp_process_rct_util.insert_crh_rec()-');

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION: arp_process_rct_util.insert_crh_rec');
      RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_ra_rec_cash                               			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Creates a new record in AR_RECEIVABLE_APPLICATIONS table for a cash    |
 |    receipt.								     |
 |									     |
 | SCOPE : PRIVATE							     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    11-SEP-95	OSTEINME	created					     |
 |    13-MAY-97 KLAWRANC        Bug fix #487513.                             |
 |                              Added parameter p_reversal_gl_date. Reversal |
 |                              GL Date must be set for all reversed         |
 |                              receivable applications records.  Parameter  |
 |                              defaults to NULL, so that other packages that|
 |                              call this procedure do not need to be        |
 |                              modified.                                    |
 |    03-SEP-97	OSTEINME	Bug 547165: Changed                          |
 |				%type to %rowtype	                     |
 |									     |
 |  14-APR-2000 Jani Rautiainen Added parameter p_called_from. This is needed|
 |                              in the logic to decide whether first UNAPP   |
 |                              row is postable or not. In BR scenario when  |
 |                              Activity Application of Short Term Debt is   |
 |                              created the UNAPP rows are not postable.     |
 |                              This is an user requirement for BR.          |
 |                              The parameter is defaulted to NULL so no     |
 |                              impact for the existing functionality.       |
 |  03-Sep-2002 Debbie Jancis   Modified for MRC trigger replacement         |
 |                              Added calls to AR_MRC_ENGINE3 for            |
 |                              for processing inserts into                  |
 |                              AR_RECEIVABLE_APPLICATIONS                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_ra_rec_cash(
	p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_amount	IN ar_cash_receipts.amount%TYPE,
	p_apply_date	IN DATE,
	p_status	IN ar_cash_receipts.status%TYPE,
	p_acctd_amount	IN
		ar_receivable_applications.acctd_amount_applied_from%TYPE,
	p_gl_date  IN  DATE,
	p_ccid		IN
		ar_receivable_applications.code_combination_id%TYPE,
	p_payment_schedule_id 	IN
		ar_payment_schedules.payment_schedule_id%TYPE,
	p_application_rule	IN ar_receivable_applications.application_rule%TYPE,
        p_reversal_gl_date IN DATE default null,
        p_ra_id            OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
        p_called_from      IN  VARCHAR2 DEFAULT NULL -- jrautiai BR project
			) IS

l_ra_rec	ar_receivable_applications%ROWTYPE;
l_ra_id		ar_receivable_applications.receivable_application_id%TYPE;
--BUG#2750340
l_xla_ev_rec   arp_xla_events.xla_events_type;

BEGIN

  arp_standard.debug('arp_process_rct_util.insert_ra_rec_cash()+');

  -- create new receivable applications record:

  l_ra_rec.amount_applied 		:= p_amount;
  l_ra_rec.acctd_amount_applied_from	:= p_acctd_amount;
  l_ra_rec.cash_receipt_id		:= p_cash_receipt_id;
  l_ra_rec.gl_date			:= p_gl_date;
  l_ra_rec.reversal_gl_date             := p_reversal_gl_date;
  l_ra_rec.apply_date			:= p_apply_date;
  l_ra_rec.display			:= 'N';
  l_ra_rec.application_type		:= 'CASH';
  l_ra_rec.payment_schedule_id		:= p_payment_schedule_id;
  l_ra_rec.posting_control_id		:= -3;
  l_ra_rec.application_rule		:= p_application_rule;

  /* 14-APR-2000 jrautiai BR implementation
   * In this BR specific situation the first UNAPP row created is not POSTABLE
   * see procedure description for more information */

  IF nvl(p_called_from,'NONE') = 'BR_FACTORED_WITH_RECOURSE' THEN  -- jrautiai BR project
    l_ra_rec.postable := 'N';
  END IF;

--bug 5298846 For Receipts which require confirmation the following needs to be set
  IF nvl(p_called_from,'NONE') = 'AUTORECAPI' THEN  -- jrautiai BR project
    l_ra_rec.application_rule:= '97.0';
    l_ra_rec.confirmed_flag := 'N';
  END IF;

  -- based on receipt status, set application rule:

  l_ra_rec.status			:= p_status;
  l_ra_rec.code_combination_id		:= p_ccid;

  -- call table handler to insert record

arp_standard.debug('amount_applied = ' || to_char(l_ra_rec.amount_applied));
arp_standard.debug('acctd_amount_applied_from = ' || to_char(l_ra_rec.acctd_amount_applied_from));
arp_standard.debug('cash_receipt_id = ' || to_char(l_ra_rec.cash_receipt_id));
arp_standard.debug('gl_date = ' || to_char(l_ra_rec.gl_date));
arp_standard.debug('apply_date = ' || to_char(l_ra_rec.apply_date));
arp_standard.debug('display = ' || l_ra_rec.display);
arp_standard.debug('application_type = ' || l_ra_rec.application_type);
arp_standard.debug('payment_schedule_id = ' || to_char(l_ra_rec.payment_schedule_id));
arp_standard.debug('status = ' || l_ra_rec.status);
arp_standard.debug('ccid = ' || to_char(l_ra_rec.code_combination_id));
arp_standard.debug('sob id = ' || TO_CHAR(arp_global.set_of_books_id));
arp_standard.debug('application_rule = ' || TO_CHAR(l_ra_rec.application_rule));
arp_standard.debug('confirmed_flag = ' || TO_CHAR(l_ra_rec.confirmed_flag));
arp_standard.debug('p_called_from = ' || TO_CHAR(p_called_from));
  arp_app_pkg.insert_p(l_ra_rec, l_ra_id);

  p_ra_id := l_ra_id;

  --
  --Release 11.5 VAT changes, create receivable application accounting
  --in ar_distributions. Note tax accounting must be created after a call
  --to this function. It is due to this reason that the app id is returned
  --as output to the parent procedure to enable a call to the tax accounting
  --routine

  --  CAll MRC ENGINE for Processing Insert into rec apps.
--{BUG#4301323
--      ar_mrc_engine3.insert_ra_rec_cash(
--                         p_ra_id,
--                         l_ra_rec,
--                         l_ra_rec.cash_receipt_id,
--                         p_amount,
--                         l_ra_rec.payment_schedule_id);
--}
--BUG#2750340
  --Autoreceipts performance changes nproddut
  IF NVL(p_called_from, 'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2','CUSTRECAPIBULK') THEN
      l_xla_ev_rec.xla_from_doc_id := l_ra_id;
      l_xla_ev_rec.xla_to_doc_id   := l_ra_id;
      l_xla_ev_rec.xla_doc_table   := 'APP';
      l_xla_ev_rec.xla_mode        := 'O';
      l_xla_ev_rec.xla_call        := 'B';
      ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
  END IF;
  arp_standard.debug('arp_process_rct_util.insert_ra_rec_cash()-');

END; -- insert_ra_rec_cash()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_dist_rec                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    inserts ar_distributions record for a cash/misc receipt		     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    19-AUG-95	OSTEINME	created					     |
 |    05-Jan-98 DJancis         added p_cr_id so we can get additional info  |
 |                              required for 11.5 VAT changes                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_dist_rec(
	p_amount		IN ar_cash_receipts.amount%TYPE,
        p_acctd_amount		IN ar_cash_receipt_history.acctd_amount%TYPE,
        p_crh_id		IN
			ar_cash_receipt_history.cash_receipt_history_id%TYPE,
	p_source_type		IN ar_distributions.source_type%TYPE,
	p_ccid			IN ar_distributions.code_combination_id%TYPE,
	p_called_from      IN  VARCHAR2 DEFAULT NULL -- jrautiai BR project
			) IS

l_dist_rec	ar_distributions%ROWTYPE;
l_source_type   ar_distributions.source_type%TYPE;
l_ccid		ar_distributions.code_combination_id%TYPE;
l_dummy		ar_distributions.line_id%TYPE;
l_cr_rec        ar_cash_receipts%ROWTYPE;
l_crh_rec       ar_cash_receipt_history%ROWTYPE;
--bug#2750340
l_xla_ev_rec   arp_xla_events.xla_events_type;

BEGIN
  arp_standard.debug('arp_process_rct_util.insert_dist_rec()+');

  arp_standard.debug('-- getting infomation from cash receipt --');

  -- Fetch the history record
  arp_cr_history_pkg.fetch_p( p_crh_id, l_crh_rec );

  -- Fetch the cash receipt record
  l_cr_rec.cash_receipt_id := l_crh_rec.cash_receipt_id;
  arp_cash_receipts_pkg.fetch_p( l_cr_rec );


  --  11.5 VAT changes:
  l_dist_rec.currency_code            := l_cr_rec.currency_code;
  l_dist_rec.currency_conversion_rate := l_crh_rec.exchange_rate;
  l_dist_rec.currency_conversion_type := l_crh_rec.exchange_rate_type;
  l_dist_rec.currency_conversion_date := l_crh_rec.exchange_date;
  l_dist_rec.third_party_id           := l_cr_rec.pay_from_customer;
  l_dist_rec.third_party_sub_id       := l_cr_rec.customer_site_use_id;


  l_dist_rec.source_id		:= p_crh_id;
  l_dist_rec.source_table	:= 'CRH';
  l_dist_rec.source_type	:= p_source_type;
  l_dist_rec.code_combination_id:= p_ccid;
  /* Bug 44188117 : Added the 'or' condition below */
 IF (p_amount < 0) or (p_amount = 0 and p_acctd_amount < 0) THEN
    l_dist_rec.amount_dr := NULL;
    l_dist_rec.amount_cr := - p_amount;
    l_dist_rec.acctd_amount_dr := NULL;
    l_dist_rec.acctd_amount_cr := - p_acctd_amount;

  ELSE
    l_dist_rec.amount_dr := p_amount;
    l_dist_rec.amount_cr := NULL;
    l_dist_rec.acctd_amount_dr := p_acctd_amount;
    l_dist_rec.acctd_amount_cr := NULL;

  END IF;
/* Bug No 3635076 JVARKEY */
/* Commented out as same code is shifted to the above if loop IF (p_amount < 0) THEN.. */
/*IF (p_acctd_amount < 0) THEN
    l_dist_rec.acctd_amount_dr := NULL;
    l_dist_rec.acctd_amount_cr := - p_acctd_amount;
  ELSE
    l_dist_rec.acctd_amount_dr := p_acctd_amount;
    l_dist_rec.acctd_amount_cr := NULL;
  END IF;*/

  arp_distributions_pkg.insert_p(l_dist_rec, l_dummy);

   /* store l_dummy into the rec for use for mrc */
   l_dist_rec.line_id := l_dummy;

 /* need to insert records into the MRC table.  Calling new
    mrc engine */
--{BUG4301323
--    ar_mrc_engine2.maintain_mrc_data2(
--                p_event_mode => 'INSERT',
--                p_table_name => 'AR_DISTRIBUTIONS',
--                p_mode       => 'SINGLE',
--                p_key_value  =>  l_dist_rec.line_id,
--                p_row_info   =>  l_dist_rec);
--}
  --BUG#2750340
  --Autoreceipts performance changes nproddut
  IF NVL(p_called_from, 'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2','CUSTRECAPIBULK') THEN
	l_xla_ev_rec.xla_from_doc_id := l_crh_rec.cash_receipt_id;
	l_xla_ev_rec.xla_to_doc_id   := l_crh_rec.cash_receipt_id;
	l_xla_ev_rec.xla_doc_table   := 'CRH';
	l_xla_ev_rec.xla_mode        := 'O';
	l_xla_ev_rec.xla_call        := 'B';
	ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
  END IF;

  arp_standard.debug('arp_process_rct_util.insert_dist_rec()-');

END; -- insert_dist_rec()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    round_mcd_recs                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function takes care of rounding errors in ar_misc_cash_distr.     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    09-OCT-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE round_mcd_recs(
	p_cash_receipt_id	IN ar_cash_receipts.cash_receipt_id%TYPE
			) IS

  l_rounding_diff	NUMBER;
  l_misc_cash_key_value_list  gl_ca_utility_pkg.r_key_value_arr; /* MRC */

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.round_mcd_recs()+');
  END IF;

  SELECT ROUND(100 - sum(mcd.percent),3)
  INTO   l_rounding_diff
  FROM   ar_misc_cash_distributions mcd
  WHERE  mcd.cash_receipt_id = p_cash_receipt_id;

  IF (l_rounding_diff <> 0) THEN
    -- rounding error must be added to first record so that percent
    -- values add up to 100
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('round_mcd_recs: ' || 'Rounding difference = ' || TO_CHAR(l_rounding_diff));
    END IF;
    --
    /*----------------------------------+
     | Added bulk collect of misc cash  |
     | distribution id for use in MRC   |
     | engine for trigger replacement   |
     +----------------------------------*/

    UPDATE ar_misc_cash_distributions mcd
    SET    mcd.percent = mcd.percent + l_rounding_diff
    WHERE  cash_receipt_id = p_cash_receipt_id
    AND    ROWNUM =1
    RETURNING misc_cash_distribution_id
    BULK COLLECT INTO l_misc_cash_key_value_list;
    --

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*BUG4301323
   BEGIN
    ar_mrc_engine.maintain_mrc_data(
                 p_event_mode        => 'UPDATE',
                 p_table_name        => 'AR_MISC_CASH_DISTRIBUTIONS',
                 p_mode              => 'BATCH',
                 p_key_value_list    => l_misc_cash_key_value_list);
   EXCEPTION
      WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('round_mcd_recs: ' || 'error updating ar_mc_misc_cash_dists');
             arp_util.debug('round_mcd_recs: ' || 'SQLCODE = ' || SQLCODE || SQLERRM);
          END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;
   END;
*/
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.round_mcd_recs()-');
  END IF;

END round_mcd_recs;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_misc_dist                          			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts distributions for miscellaneous transactions		     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |   21-SEP-95	OSTEINME	created					     |
 |   28-SEP-98  K.Murphy        Bug #705078.  Added code to validate the key |
 |                              flex before the MISC distribution is         |
 |                              created.  Checks both the enabled flag and   |
 |                              From/To dates.                               |
 |   30-SEP-98  K.Murphy        Cash Management Enhancement: Allow creation  |
 |                              of Misc Receipts with distribution set.      |
 |                              Added p_created_from parameter and included  |
 |                              "default NULL" for p_distribution_set_id.    |
 |                              Modified code so that the distribution set   |
 |                              is selected along with the cc id (as in the  |
 |                              form you can no longer choose a different    |
 |                              distribution set for a given activity.       |
 |   03-Mar-05  JASSING 	Added the code to check for the profile      |
 |				option 'AR:Disable Receivable Activity       |
 |				Balancing Segment Substitution' for the      |
 |				misc receipt creation during Credit Card     |
 |				Refunds. Bug fix 4025652.		     |
 +===========================================================================*/


PROCEDURE insert_misc_dist(
	p_cash_receipt_id	IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
	p_amount		IN ar_cash_receipts.amount%TYPE,
	p_currency_code		IN ar_cash_receipts.currency_code%TYPE,
	p_exchange_rate		IN ar_cash_receipts.exchange_rate%TYPE,
	p_acctd_amount		IN ar_cash_receipt_history.acctd_amount%TYPE,
	p_receipt_date		IN ar_cash_receipts.receipt_date%TYPE,
	p_receivables_trx_id	IN ar_cash_receipts.receivables_trx_id%TYPE,
        p_distribution_set_id   IN ar_cash_receipts.distribution_set_id%TYPE default NULL,
        p_ussgl_trx_code        IN ar_cash_receipts.ussgl_transaction_code%TYPE default NULL,
        p_created_from          IN ar_misc_cash_distributions.created_from%TYPE default 'ARRERCT'
				) IS

  l_trx_code_combination_id	ar_receivables_trx.code_combination_id%TYPE;
  l_distribution_set_id         ar_receivables_trx.default_acctg_distribution_set%TYPE;
  l_dummy			ar_misc_cash_distributions.misc_cash_distribution_id%TYPE;
  l_misc_cash_dist_rec		ar_misc_cash_distributions%ROWTYPE;
  l_misc_cash_key_value_list    gl_ca_utility_pkg.r_key_value_arr; /* MRC */
  l_crh_ccid			ar_cash_receipt_history.account_code_combination_id%TYPE; /*Bug fix 4025652 */
  l_type                        ar_receivables_trx.type%TYPE;   /*4726219 */

l_xla_ev_rec   arp_xla_events.xla_events_type;

CURSOR c_hist IS
SELECT cash_receipt_history_id
FROM ar_cash_receipt_history
WHERE current_record_flag = 'Y'
AND   cash_receipt_id = p_cash_receipt_id;

l_crh_id    NUMBER;

BEGIN

  arp_standard.debug('arp_process_receipts.insert_misc_dist()+');

  arp_standard.debug('ussgl_trx code = ' || p_ussgl_trx_code);
  -- delete existing distributions records

   /*----------------------------------+
     | Added bulk collect of misc cash  |
     | distribution id for use in MRC   |
     | engine for trigger replacement   |
     +----------------------------------*/

  DELETE ar_misc_cash_distributions
  WHERE  cash_receipt_id = p_cash_receipt_id
  RETURNING misc_cash_distribution_id
  BULK COLLECT INTO l_misc_cash_key_value_list;
  --

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*BUG4301323
   BEGIN
    ar_mrc_engine.maintain_mrc_data(
                 p_event_mode        => 'DELETE',
                 p_table_name        => 'AR_MISC_CASH_DISTRIBUTIONS',
                 p_mode              => 'BATCH',
                 p_key_value_list    => l_misc_cash_key_value_list);
   EXCEPTION
      WHEN OTHERS THEN
          arp_util.debug('error deleting ar_mc_misc_cash_dists');
          arp_util.debug('SQLCODE = ' || SQLCODE || SQLERRM);
          APP_EXCEPTION.RAISE_EXCEPTION;
   END;
*/
  -- check if receipt amount is zero.  If yes, don't create any
  -- distributions
-------------------------------------------------------------
-- Commented the following 'if' as part of bug fix 868448
----------------------------------------------
  --IF (p_amount <> 0) THEN

    -- determine if distribution set or single account

    -- Now selecting both the code combination id and the distribution set id.
    -- Previously you could create a receipt with a different distribution set
    -- for the choosen activity (i.e. other than the default).  This is no
    -- longer permitted.  Cash Management have added the ability to create
    -- Misc Receipts with distribution sets but we won't require them to pass
    -- in the distribution set id as se will get it ourselves based on the
    -- activity.
    /* Bug4726219 */
    SELECT rt.code_combination_id,
           rt.default_acctg_distribution_set,
           rt.type
    INTO   l_trx_code_combination_id,
           l_distribution_set_id,
           l_type
    FROM   ar_receivables_trx rt
    WHERE  rt.type in
          ('MISCCASH', 'BANK_ERROR', 'CCREFUND', 'CM_REFUND','CC_CHARGEBACK')
    AND    NVL( rt.status, 'A' ) = 'A'
    AND    rt.RECEIVABLES_TRX_ID = p_receivables_trx_id;


    IF (l_trx_code_combination_id IS NOT NULL) THEN

        -- Default account ccid exists.  Create misc cash distribution
        -- record with 100% for this account

       /* bug fix 4025652 */
       select account_code_combination_id
       into   l_crh_ccid
       from   ar_cash_receipt_history
       where  cash_receipt_id = p_cash_receipt_id
       and    current_record_flag = 'Y';

       /* -------------------------------------------------------------------+
       | Balancing segment of ACTIVITY application should be replaced with  |
       | that of CRH record's CCID.                                    |
       +--------------------------------------------------------------------*/
       /* Bug4726219 */
       IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'),
           'N') = 'N'  AND l_type <> 'MISCCASH' THEN
          arp_util.Substitute_Ccid(
                             p_coa_id        => arp_global.chart_of_accounts_id,
                             p_original_ccid => l_trx_code_combination_id,
                             p_subs_ccid     => l_crh_ccid,
                             p_actual_ccid   => l_misc_cash_dist_rec.code_combination_id );
       ELSE
          l_misc_cash_dist_rec.code_combination_id := l_trx_code_combination_id;
       END IF;

   	l_misc_cash_dist_rec.cash_receipt_id	:= p_cash_receipt_id;
  	l_misc_cash_dist_rec.gl_date		:= p_gl_date;
  	l_misc_cash_dist_rec.apply_date		:= p_receipt_date;
  /*	l_misc_cash_dist_rec.code_combination_id:= l_trx_code_combination_id; Bug fix 4025652 */
  	l_misc_cash_dist_rec.percent		:= 100;
  	l_misc_cash_dist_rec.amount		:= p_amount;
  	l_misc_cash_dist_rec.acctd_amount	:= p_acctd_amount;
  	l_misc_cash_dist_rec.posting_control_id	:= -3;
  	l_misc_cash_dist_rec.created_from	:= p_created_from;
	l_misc_cash_dist_rec.set_of_books_id	:= arp_global.set_of_books_id;
OPEN c_hist;
FETCH c_hist INTO l_misc_cash_dist_rec.cash_receipt_history_id;
CLOSE c_hist;

        -- Bug 2641258:  USSGL TRX code not being defaulted
        l_misc_cash_dist_rec.ussgl_transaction_code := p_ussgl_trx_code;

        -- Bug fix #705078
        -- Verify that account is valid before doing insert.
        --
        -- Using the flex field server APIs to do this ...
        -- (note also that we are using the same error message
        -- for each case.
        --
        -- Firstly, call fnd_flex_keyval.validate_ccid to populate
        -- all of the relevant global variables.
        --
        IF fnd_flex_keyval.validate_ccid(
                         appl_short_name  => 'SQLGL',
                         key_flex_code    => 'GL#',
                         structure_number => arp_global.chart_of_accounts_id,
                         combination_id   => l_trx_code_combination_id ) THEN
          -- Secondly, check is the key flex is enabled.
          -- Fix 1341201, Added rollback
          IF not fnd_flex_keyval.enabled_flag THEN
            rollback;
            FND_MESSAGE.Set_Name('AR', 'AR_GL_ACCOUNT_INVALID');
            APP_EXCEPTION.Raise_Exception;
          -- Thirdly, check if the key flex is valid for this date.
          --
          ELSIF p_gl_date NOT between nvl(fnd_flex_keyval.start_date,p_gl_date)
                                and nvl(fnd_flex_keyval.end_date,p_gl_date) THEN
            rollback;
            FND_MESSAGE.Set_Name('AR', 'AR_GL_ACCOUNT_INVALID');
            APP_EXCEPTION.Raise_Exception;
          END IF;
        END IF;

	arp_misc_cash_dist_pkg.insert_p(l_misc_cash_dist_rec, l_dummy);


  --
   l_xla_ev_rec.xla_from_doc_id := p_cash_receipt_id;
   l_xla_ev_rec.xla_to_doc_id   := p_cash_receipt_id;
   l_xla_ev_rec.xla_doc_table   := 'MCD';
   l_xla_ev_rec.xla_mode        := 'O';
   l_xla_ev_rec.xla_call        := 'D';
   ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

    ELSIF  (l_distribution_set_id is not null) THEN

      -- 941243: insert distributions records
      -- do not create ar_misc_cash_distributions if receipt amount = 0
     /* Bug fix 2272461
     When the MISC receipt amount is changed to zero, the MISCCASH accounting
     Record is not created in ar_distributions table. Commented out NOCOPY the condition
     which check for the receipt amount before creating the record.
      IF (p_amount <> 0) THEN */

	  create_mcd_recs(p_cash_receipt_id,
		      p_amount,
		      p_acctd_amount,
		      p_exchange_rate,
		      p_currency_code,
		      p_gl_date,
		      p_receipt_date,
		      p_distribution_set_id,
                      p_ussgl_trx_code);


      /*END IF; */
    END IF;

  --END IF; -- p_amount <> 0
-------------------------------------------------------------
-- Commented out NOCOPY the above 'END IF' as part of bug fix 868448
--------------------------------------------------------------

  arp_standard.debug('arp_process_receipts.insert_misc_dist()-');

END; -- arp_process_receipts.insert_misc_dist()



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_misc_dist                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    updates distribution in ar_misc_cash_distributions		     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    22-SEP-95	OSTEINME	created					     |
 |    30-MAY-01 MRAMANAT        Added an ELSIF condition to handle Case# 6   |
 |                              to fix bug 1792989   			     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_misc_dist(
	p_cash_receipt_id	IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_amount		IN ar_cash_receipts.amount%TYPE,
	p_acctd_amount		IN ar_cash_receipt_history.acctd_amount%TYPE,
	p_amount_changed_flag	IN BOOLEAN,
	p_distribution_set_id	IN ar_cash_receipts.distribution_set_id%TYPE,
	p_receivables_trx_id	IN ar_cash_receipts.receivables_trx_id%TYPE,
	p_old_distribution_set_id IN ar_cash_receipts.distribution_set_id%TYPE,
	p_old_receivables_trx_id  IN ar_cash_receipts.receivables_trx_id%TYPE,
	p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
	p_gl_date_changed_flag  IN BOOLEAN,
	p_currency_code		IN ar_cash_receipts.currency_code%TYPE,
	p_exchange_rate		IN ar_cash_receipts.exchange_rate%TYPE,
	p_receipt_date		IN ar_cash_receipts.receipt_date%TYPE,
	p_receipt_date_changed_flag IN BOOLEAN,
	p_gl_tax_acct		IN ar_distributions.code_combination_id%TYPE
				) IS

  l_trx_code_combination_id	ar_receivables_trx.code_combination_id%TYPE;
  l_old_trx_code_combination_id	ar_receivables_trx.code_combination_id%TYPE;
  l_dummy			ar_misc_cash_distributions.misc_cash_distribution_id%TYPE;
  l_misc_cash_dist_rec		ar_misc_cash_distributions%ROWTYPE;
  l_old_recs_auto_flag		BOOLEAN;
  l_new_recs_auto_flag		BOOLEAN;
  l_count                       NUMBER;
  l_posted                      ar_cash_receipt_history.posting_control_id%TYPE;
  l_ae_doc_rec                  l_ae_doc_rec_type;
  l_misc_cash_key_value_list    gl_ca_utility_pkg.r_key_value_arr;
  l_old_default_distribution_set NUMBER; --Bug 6416611
  l_default_distribution_set	 NUMBER; --Bug 6416611
  dummy				varchar2(1); --Bug 6416611
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.update_misc_dist()+');
  END IF;


  -- The following cases need to be distinguished with regard to
  -- an update of the distribution set and/or the amount:
  --
  -- 1. old distribution set	: NULL
  --    default ccid of activity: NULL
  --    new distribution set	: NULL
  --    amount 			: unchanged
  --
  --    In this case the manually created distribution records
  --    do not require any changes (trivial case).
  --
  -- 2. old distribution set	: NULL
  --    default ccid of activity: NULL
  --    new distribution set	: NULL
  --    amount 			: changed
  --
  --    In this case the manually created distribution records
  --    need to be updated.  The percent values must remain
  --    unchanged, but the corresponding amounts need to be
  --    adapted to the new total amount.
  --
  -- 3. old distribution set    : automatically created
  --    new distribution set    : NULL (manually created)
  --    amount 			: changed or unchanged
  --
  --    Was:
  --    The old (automatically created) distribution records must
  --    be deleted.  The distribution set must be entered
  --    manually by the user.
  --
  --    As of 11/20/95:  distribution window is semi-modal, and user
  --    can no longer null out NOCOPY distribution set in receipt window.
  --    Is:
  --    The user has manually modified the distribution set in the
  --    distributions window. Nothing needs to be done.
  --
  --
  -- 4. old distribution set    : NULL (manually created)
  --    new distribution set    : automatically created
  --    amount			: changed or unchanged
  --
  --    The old (manually created) distribution records must
  --    be deleted; new records must be created according to
  --    the new distribution_set/activity.
  --
  -- 5. old distribution set	: automatically created
  --    new distribution set	: automatically created, but changed
  --    amount 			: changed or unchanged
  --
  --    The old (automatically created) records must be deleted,
  --    new records need to be created automatically based on
  --    ccid or distribution set
  --
  -- 6. old distribution set    : automatically created
  --    new distribution set    : unchanged
  --    amount			: changed
  --
  --    The old records must be deleted, new ones created for the
  --    new amount.
  --
  -- 7. old distribution set	: automatically created
  --    new distribution set	: unchanged
  --    amount			: unchanged
  --
  --    Trivial case -- no change required
  --
  -- 8. amount			: 0 (zero)
  --
  --    super-trivial case:  just delete existing distributions (if any)
  --                         and exit.
  --
  -- ... here we go...

  -- first determine if current (=old) set of distribution records is
  -- based on default account/distribution set

  /* Bug fix 2272461
     When the MISC receipt amount is changed to zero, the MISCCASH accounting
     Record is not created in ar_distributions table. Commented out NOCOPY the portion
     of the code which handles the zero receipt amount separately.
  IF (p_amount = 0) THEN
    --
    -- Handle case 8 right away:
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('update_misc_dist: ' || '=====> Case 8: amount is zero -- deleting applications');
    END IF;

    SELECT  count(mcd.misc_cash_distribution_id)
      INTO  l_count
      FROM  ar_misc_cash_distributions mcd
    WHERE   mcd.cash_receipt_id = p_cash_receipt_id
    AND     mcd.reversal_gl_date IS NULL  --For rate adjustments picks up records with new rate
    AND     mcd.posting_control_id = -3   --Not posted
    AND EXISTS (SELECT 'x'
               FROM  ar_distributions ard
               WHERE ard.source_id = mcd.misc_cash_distribution_id
               AND   ard.source_table = 'MCD');

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_misc_dist: ' || ' l_count ' || TO_CHAR(l_count));
    END IF;

    IF (l_count > 0) THEN
        SELECT distinct posting_control_id
        INTO   l_posted
        FROM   ar_cash_receipt_history
        WHERE  cash_receipt_id = p_cash_receipt_id
        AND  current_record_flag = 'Y';
    END IF;
            l_ae_doc_rec.document_type           := 'RECEIPT';
            l_ae_doc_rec.document_id             := p_cash_receipt_id;
            l_ae_doc_rec.accounting_entity_level := 'ONE';
            l_ae_doc_rec.source_table            := 'MCD';
            l_ae_doc_rec.source_id               := '';

    --
    IF (l_count > 0) then
        IF (l_posted = -3) then
            arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
        END IF;
    END IF; */
    --
     /*----------------------------------+
     | Added bulk collect of misc cash  |
     | distribution id for use in MRC   |
     | engine for trigger replacement   |
     +----------------------------------*/

    /*DELETE ar_misc_cash_distributions
    WHERE cash_receipt_id = p_cash_receipt_id
    RETURNING misc_cash_distribution_id
    BULK COLLECT INTO l_misc_cash_key_value_list; */

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/

   /* ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'DELETE',
                        p_table_name        => 'AR_MISC_CASH_DISTRIBTIONS',
                        p_mode              => 'BATCH',
                        p_key_value_list    => l_misc_cash_key_value_list);

    RETURN;
  END IF; */

  IF (p_old_distribution_set_id IS NOT NULL) THEN
    l_old_recs_auto_flag := TRUE;
  ELSE
    --
    BEGIN
    /* For bug2221221 modified the query to handle when receivable
      activity is inactivated on the same date as the receipt date */
    /* Start Bug 6416611 - modified query to handle case of receivable activity
	with distribution set */
       SELECT   rt.code_combination_id, rt.default_acctg_distribution_set
       INTO     l_old_trx_code_combination_id, l_old_default_distribution_set
       FROM     ar_receivables_trx                 rt
       WHERE    rt.type in
            ('MISCCASH', 'BANK_ERROR', 'CCREFUND', 'CM_REFUND', 'CC_CHARGEBACK')
      -- AND  ( (NVL( rt.status, 'A' )     = 'A') or (rt.end_date_active=p_receipt_date))
      AND          rt.RECEIVABLES_TRX_ID     = p_old_receivables_trx_id;

       IF l_old_default_distribution_set IS NULL then
		SELECT 'x' INTO dummy from gl_code_combinations
		where   code_combination_id = l_old_trx_code_combination_id
		AND  ENABLED_FLAG='Y';
	END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name('AR', 'AR_NO_ACTIVITY_FOUND');
      APP_EXCEPTION.Raise_Exception;
    END;
    --
    IF (l_old_trx_code_combination_id IS NOT NULL) THEN
      l_old_recs_auto_flag := TRUE;
    ELSE
      l_old_recs_auto_flag := FALSE;
    END IF;
  END IF;
  -- now determine if new set of distribution records is
  -- based on default account/distribution set

  IF (p_distribution_set_id IS NOT NULL) THEN
    l_new_recs_auto_flag := TRUE;
  ELSE
    --
    BEGIN
    /* For bug2221221 modified the query to handle when receivable
      activity is inactivated on the same date as the receipt date */
    /* Start Bug 6416611 - modified query to handle case of receivable activity
	with distribution set */
       SELECT   rt.code_combination_id, rt.default_acctg_distribution_set
       INTO     l_trx_code_combination_id, l_default_distribution_set
       FROM     ar_receivables_trx                 rt
       WHERE    rt.type  in
          ('MISCCASH', 'BANK_ERROR', 'CCREFUND', 'CM_REFUND' , 'CC_CHARGEBACK')
--       AND          ((NVL( rt.status, 'A' )     = 'A') or (rt.end_date_active=p_receipt_date))
       AND          rt.RECEIVABLES_TRX_ID     = p_receivables_trx_id;

       IF l_default_distribution_set IS NULL then
		SELECT 'x' INTO dummy from gl_code_combinations
		where   code_combination_id = l_trx_code_combination_id
		AND  ENABLED_FLAG='Y';
	END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name('AR', 'AR_NO_ACTIVITY_FOUND');
      APP_EXCEPTION.Raise_Exception;
    END;
    --
    IF (l_trx_code_combination_id IS NOT NULL) THEN
      l_new_recs_auto_flag := TRUE;
    ELSE
      l_new_recs_auto_flag := FALSE;
    END IF;
  END IF;

  IF (l_new_recs_auto_flag) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_misc_dist: ' || 'l_new_recs_auto_flag = TRUE');
    END IF;
  ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_misc_dist: ' || 'l_new_recs_auto_flag = FALSE');
    END IF;
  END IF;

  IF (l_old_recs_auto_flag) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_misc_dist: ' || 'l_old_recs_auto_flag = TRUE');
    END IF;
  ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_misc_dist: ' || 'l_old_recs_auto_flag = FALSE');
    END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('update_misc_dist: ' || 'p_distribution_set_id = ' ||
		to_char(p_distribution_set_id));
     arp_standard.debug('update_misc_dist: ' || 'p_old_distribution_set_id = ' ||
		to_char(p_old_distribution_set_id));
     arp_standard.debug('update_misc_dist: ' || 'l_trx_code_combination_id = ' ||
		to_char(l_trx_code_combination_id));
     arp_standard.debug('update_misc_dist: ' || 'l_old_trx_code_combination_id = ' ||
		to_char(l_old_trx_code_combination_id));
  END IF;


  --
  -- now handle different cases as outlined above:
  --
  IF ((p_amount_changed_flag = FALSE) AND
      ((l_old_recs_auto_flag = TRUE and l_new_recs_auto_flag = TRUE and
	(p_distribution_set_id = p_old_distribution_set_id OR
	l_trx_code_combination_id = l_old_trx_code_combination_id)) OR
       (l_old_recs_auto_flag = FALSE and l_new_recs_auto_flag = FALSE))) THEN
    --
    -- Handle cases 1 / 7:
    --
    -- check if gl_date or receipt date has changed.  If one of them has
    -- changed, simply update the dates in all existing distribution records:
    --
    IF (p_receipt_date_changed_flag = TRUE OR
        p_gl_date_changed_flag = TRUE) THEN
      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('update_misc_dist: ' || '=====> Case 1/7: updating distributions with new date(s)');
      END IF;
      --
    /*----------------------------------+
     | Added bulk collect of misc cash  |
     | distribution id for use in MRC   |
     | engine for trigger replacement   |
     +----------------------------------*/
/* Bug 5980036 */
      UPDATE ar_misc_cash_distributions
      SET -- gl_date = p_gl_date,
          apply_date = p_receipt_date
      WHERE cash_receipt_id = p_cash_receipt_id
      RETURNING misc_cash_distribution_id
      BULK COLLECT INTO l_misc_cash_key_value_list;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*BUG4301323
    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'UPDATE',
                        p_table_name        => 'AR_MISC_CASH_DISTRIBTIONS',
                        p_mode              => 'BATCH',
                        p_key_value_list    => l_misc_cash_key_value_list);
*/
    ELSE
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('update_misc_dist: ' || '=====> Case 1/7: no update required');
      END IF;
    END IF;
  --
    /* Bug 1792989. When only the receipt amount is changed with no change
       to receivable activity, then distribution accounting should not be
       affected and only the amounts should be updated in
       AR_MISC_CASH_DISTRIBUTIONS. Also Accounting engine is called to
       recreate accounting in AR_DISTRIBUTIONS for the new amounts.
       This is done by
       1. Calling the Accounting engine to delete the MCD records
          from AR_DISTRIBUTIONS for the passed cash_receipt_id.
       2. Update the amount in AR_MISC_CASH_DISTRIBUTIONS by calling
          procedure update_manual_dist.
       3. Calling the Accounting engine to recreate the MCD records
          taking the new amount into consideration.
      */
        /* bug 3324670 : modified the below ELSIF */
    ELSIF (p_amount_changed_flag = TRUE AND
           (l_old_recs_auto_flag = TRUE AND
            l_new_recs_auto_flag = TRUE AND
               (p_distribution_set_id     = p_old_distribution_set_id OR
                l_trx_code_combination_id = l_old_trx_code_combination_id)) OR
		(l_old_recs_auto_flag = FALSE AND
                 l_new_recs_auto_flag = FALSE)) THEN

	IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('update_misc_dist: ' || '=====> Case 2: updating amounts');
       END IF;
    SELECT  count(mcd.misc_cash_distribution_id)
      INTO  l_count
      FROM  ar_misc_cash_distributions mcd
    WHERE   mcd.cash_receipt_id = p_cash_receipt_id
    AND     mcd.reversal_gl_date IS NULL
    AND     mcd.posting_control_id = -3
    AND EXISTS (SELECT 'x'
               FROM  ar_distributions ard
               WHERE ard.source_id = mcd.misc_cash_distribution_id
               AND   ard.source_table = 'MCD');

    l_ae_doc_rec.document_type           := 'RECEIPT';
    l_ae_doc_rec.document_id             := p_cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level := 'ONE';
    l_ae_doc_rec.source_table            := 'MCD';
    l_ae_doc_rec.source_id               := '';
    /* Bugfix 2753644. */
    l_ae_doc_rec.gl_tax_acct             := p_gl_tax_acct;

    IF (l_count > 0) then
        SELECT distinct posting_control_id
        INTO   l_posted
        FROM   ar_cash_receipt_history
        WHERE  cash_receipt_id = p_cash_receipt_id
        AND    current_record_flag = 'Y';

        IF (l_posted = -3) THEN

            -- Call accounting entry library begins
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('update_misc_dist: ' ||  'Delete Misc Cash Receipt start () +');
            END IF;
            arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('update_misc_dist: ' ||  'Delete Misc Cash Receipt start () -');
            END IF;
        END IF;
    END IF;

    update_manual_dist( p_cash_receipt_id,
                        p_amount,
                        p_acctd_amount,
                        p_exchange_rate,
                        p_currency_code,
                        p_gl_date,
                        p_receipt_date );

    SELECT distinct posting_control_id
        INTO   l_posted
        FROM   ar_cash_receipt_history
        WHERE  cash_receipt_id = p_cash_receipt_id
        AND    current_record_flag = 'Y';
    IF (l_posted = -3) then
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('update_misc_dist: ' || ' Create Acct Entry');
        END IF;
        arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
    END IF;
  --
    /* bug 3324670 : commenting below code.Case 2 has been handled Above */
    /*
  ELSIF (p_amount_changed_flag = TRUE AND
	 l_old_recs_auto_flag = FALSE AND
         l_new_recs_auto_flag = TRUE) THEN
    --
    -- Handle case 2:
    --
    -- if distribution was and still is created manually, just update
    -- the amounts for each record.
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('update_misc_dist: ' || '=====> Case 2: updating amounts');
    END IF;
    --
    update_manual_dist( p_cash_receipt_id,
			p_amount,
			p_acctd_amount,
			p_exchange_rate,
			p_currency_code,
			p_gl_date,
			p_receipt_date );
    --
    */
  ELSIF (l_old_recs_auto_flag = TRUE AND
         l_new_recs_auto_flag = FALSE) THEN
    --
    -- Handle case 3:
    --
    -- was:
    -- Delete old (automatically created records).  User has to enter
    -- new records manually.
    --
    -- now: do nothing (see above)
    --
/*
    *****   IF THIS EVER IS UNCOMMENTED, THEN A CALL TO THE MRC ENGINE IS
    REQUIRED.....

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('update_misc_dist: ' || 'Case 3: deleting old records');
    END IF;

    DELETE ar_misc_cash_distributions
    WHERE cash_receipt_id = p_cash_receipt_id;

*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('update_misc_dist: ' || '=====> Case 3: do nothing');
    END IF;
    NULL;

  ELSE

/* ((l_old_recs_auto_flag = FALSE AND
         l_new_recs_auto_flag = TRUE) OR
         (l_old_recs_auto_flag = TRUE AND
         l_new_recs_auto_flag = TRUE)) THEN
    --
    -- the above condition can obviously simplified, but was left the
    -- way it is to more closely match the conditions associated with
    -- cases 4, 5, and 6 (for maintenance purposes).

*/
    --
    -- Handle case 4, 5, 6:
    --
    -- the old records need to be deleted (no matter how they were
    -- created, and new ones will created automatically based on the
    -- ccid or distribution set.

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_misc_dist: ' || ' =====> CASE 4, 5, 6');
    END IF;

    SELECT  count(mcd.misc_cash_distribution_id)
      INTO  l_count
      FROM  ar_misc_cash_distributions mcd
    WHERE   mcd.cash_receipt_id = p_cash_receipt_id
    AND     mcd.reversal_gl_date IS NULL  --For rate adjustments picks up records with new rate
    AND     mcd.posting_control_id = -3   --Not posted
    AND EXISTS (SELECT 'x'
               FROM  ar_distributions ard
               WHERE ard.source_id = mcd.misc_cash_distribution_id
               AND   ard.source_table = 'MCD');

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_misc_dist: ' || ' l_count ' || TO_CHAR(l_count));
    END IF;

    l_ae_doc_rec.document_type           := 'RECEIPT';
    l_ae_doc_rec.document_id             := p_cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level := 'ONE';
    l_ae_doc_rec.source_table            := 'MCD';
    l_ae_doc_rec.source_id               := '';
    /* Bugfix 2753644 */
    l_ae_doc_rec.gl_tax_acct             := p_gl_tax_acct;

    IF (l_count > 0) then

	SELECT distinct posting_control_id
  	INTO   l_posted
  	FROM   ar_cash_receipt_history
  	WHERE  cash_receipt_id = p_cash_receipt_id
    	AND  current_record_flag = 'Y';

  	IF (l_posted = -3) THEN

  	    -- Call accounting entry library begins
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('update_misc_dist: ' ||  'Delete Misc Cash Receipt start () +');
            END IF;

            -- Calling accounting entry library
      	    arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
      	    IF PG_DEBUG in ('Y', 'C') THEN
      	       arp_standard.debug('update_misc_dist: ' ||  'Delete Misc Cash Receipt start () -');
      	    END IF;
        END IF;
    END IF;

    insert_misc_dist(	p_cash_receipt_id,
			p_gl_date,
			p_amount,
			p_currency_code,
			p_exchange_rate,
			p_acctd_amount,
			p_receipt_date,
			p_receivables_trx_id,
			p_distribution_set_id);

    SELECT distinct posting_control_id
        INTO   l_posted
        FROM   ar_cash_receipt_history
        WHERE  cash_receipt_id = p_cash_receipt_id
        AND  current_record_flag = 'Y';
    IF (l_posted = -3) then
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_misc_dist: ' || ' Create Acct Entry');
    END IF;
    	    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    END IF;
    --
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.update_misc_dist()-');
  END IF;

END update_misc_dist;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_mcd_recs                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    creates distribution in ar_misc_cash_distributions based on a pre-     |
 |    defined distribution set. This function also takes care of possible    |
 |    rounding errors.                      				     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    22-SEP-95	OSTEINME	created					     |
 |    28-SEP-98  K.Murphy       Bug #705078.  Added code to validate the key |
 |                              flex before the MISC distributions are       |
 |                              created.  Checks both the enabled flag and   |
 |                              From/To dates.                               |
 |                              Shuffled the code around a bit in order to do|
 |                              this.  Changed the insert from "insert as    |
 |                              select" to using a cursor.                   |
 |                                                                           |
 +===========================================================================*/


PROCEDURE create_mcd_recs(
		p_cash_receipt_id  IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_amount	   IN ar_cash_receipts.amount%TYPE,
		p_acctd_amount	   IN ar_cash_receipt_history.acctd_amount%TYPE,
		p_exchange_rate    IN ar_cash_receipts.exchange_rate%TYPE,
		p_currency_code    IN ar_cash_receipts.currency_code%TYPE,
		p_gl_date	   IN ar_cash_receipt_history.gl_date%TYPE,
		p_receipt_date	   IN ar_cash_receipts.receipt_date%TYPE,
		p_distribution_set_id IN ar_cash_receipts.distribution_set_id%TYPE,
                p_ussgl_trx_code   IN ar_cash_receipts.ussgl_transaction_code%TYPE
			) IS

l_min_unit		NUMBER;
l_precision		NUMBER;
l_acctd_rounding_diff	NUMBER;
l_rounding_diff		NUMBER;
l_misc_cash_dist_id     ar_misc_cash_distributions.misc_cash_distribution_id%TYPE;   /*  added for mrc changes */
l_misc_cash_key_value_list gl_ca_utility_pkg.r_key_value_arr;

l_xla_ev_rec   arp_xla_events.xla_events_type;

/* Bug fix 2843634
   Modified the cursor to take care of the situation where the receipt amount is  zero */

CURSOR c_dist IS
  SELECT
        dist_code_combination_id,
        DECODE(p_amount,0,ROUND(percent_distribution,3),
        ROUND
        (
            ROUND((percent_distribution/100.0) * p_amount,3) * 100/
                p_amount,
            3
        )) percent,
        decode
        (
          l_min_unit, null,
          round(p_amount * percent_distribution/100,
                            l_precision),
          round(p_amount * (percent_distribution/100)/l_min_unit)
                     * l_min_unit
        ) amount,
        decode
        (
          arp_global.base_min_acc_unit, null,
          round((p_amount * percent_distribution/100) * nvl(p_exchange_rate,1),
                            arp_global.base_precision),
          round(p_amount * (percent_distribution/100) * nvl(p_exchange_rate,1)
		/ arp_global.base_precision) * arp_global.base_precision
        ) acctd_amount
  FROM
 	ar_distribution_set_lines
  WHERE
	distribution_set_id = p_distribution_set_id;

CURSOR c_hist IS
SELECT cash_receipt_history_id
FROM ar_cash_receipt_history
WHERE current_record_flag = 'Y'
AND   cash_receipt_id = p_cash_receipt_id;

l_crh_id    NUMBER;

BEGIN

  arp_standard.debug('arp_process_receipts.create_mcd_recs()+');

  SELECT minimum_accountable_unit,precision
  INTO   l_min_unit, l_precision
  FROM   fnd_currencies
  WHERE  currency_code = p_currency_code;

  OPEN c_hist;
  FETCH c_hist INTO l_crh_id;
  CLOSE c_hist;


  FOR dist in c_dist LOOP
    -- Bug fix #705078
    -- Verify that account is valid before doing insert.
    --
    -- Using the flex field server APIs to do this ...
    -- (note also that we are using the same error message
    -- for each case.
    --
    -- Firstly, call fnd_flex_keyval.validate_ccid to populate
    -- all of the relevant global variables.
    --
    IF fnd_flex_keyval.validate_ccid(
                     appl_short_name  => 'SQLGL',
                     key_flex_code    => 'GL#',
                     structure_number => arp_global.chart_of_accounts_id,
                     combination_id   => dist.dist_code_combination_id) THEN
      -- Secondly, check is the key flex is enabled.
      --
      IF not fnd_flex_keyval.enabled_flag THEN
        FND_MESSAGE.Set_Name('AR', 'AR_GL_ACCOUNT_INVALID');
        APP_EXCEPTION.Raise_Exception;
      -- Thirdly, check if the key flex is valid for this date.
      --
      ELSIF p_gl_date NOT between nvl(fnd_flex_keyval.start_date,p_gl_date)
                            and nvl(fnd_flex_keyval.end_date,p_gl_date) THEN
        FND_MESSAGE.Set_Name('AR', 'AR_GL_ACCOUNT_INVALID');
        APP_EXCEPTION.Raise_Exception;
      END IF;
    END IF;

    /*  store the misc cash dist id for use in MRC call */

    SELECT ar_misc_cash_distributions_s.nextval
      INTO l_misc_cash_dist_id
    FROM DUAL;

    INSERT INTO ar_misc_cash_distributions (
	misc_cash_distribution_id,
    	last_updated_by,
    	last_update_date,
    	created_by,
    	creation_date,
    	cash_receipt_id,
    	gl_date,
    	apply_date,
    	code_combination_id,
    	percent,
    	amount,
    	set_of_books_id,
    	acctd_amount,
    	posting_control_id,
    	created_from,
        ussgl_transaction_code,org_id,
		cash_receipt_history_id)
    VALUES
        (
	l_misc_cash_dist_id,
        arp_global.user_id,
        arp_global.last_update_date,
        arp_global.created_by,
        arp_global.creation_date,
        p_cash_receipt_id,
        p_gl_date,
        p_receipt_date,
        dist.dist_code_combination_id,
        dist.percent,
        dist.amount,
        arp_global.set_of_books_id,
        dist.acctd_amount,
        -3,
        'ARRERCT',
        p_ussgl_trx_code, arp_standard.sysparm.org_id,
		l_crh_id);


   l_xla_ev_rec.xla_from_doc_id := p_cash_receipt_id;
   l_xla_ev_rec.xla_to_doc_id   := p_cash_receipt_id;
   l_xla_ev_rec.xla_doc_table   := 'MCD';
   l_xla_ev_rec.xla_mode        := 'O';
   l_xla_ev_rec.xla_call        := 'D';
   ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);


       /*---------------------------------+
        | Calling central MRC library     |
        | for MRC Integration             |
        +---------------------------------*/
/*4301323
        ar_mrc_engine.maintain_mrc_data(
                   p_event_mode        => 'INSERT',
                   p_table_name        => 'AR_MISC_CASH_DISTRIBUTIONS',
                   p_mode              => 'SINGLE',
                   p_key_value         => l_misc_cash_dist_id );
*/
  END LOOP;

  -- determine if there is a rounding error

  SELECT  NVL(p_amount, 0) -
        NVL(SUM
        (
        	decode
        	(
          	  l_min_unit, null,
          	  round(p_amount * percent_distribution/100,
                            l_precision),
          	  round(p_amount*(percent_distribution/100)/l_min_unit)
			*l_min_unit
        	)
        ),0)
        ,
        NVL(p_acctd_amount, 0) -
        NVL(SUM
        (
        	decode
        	(
        	  arp_global.base_min_acc_unit, null,
          	  round((p_amount * percent_distribution/100)
                                        * nvl(p_exchange_rate,1),
                            arp_global.base_precision),
                  round(p_amount * (percent_distribution/100)
                                        * nvl(p_exchange_rate ,1) /
                            arp_global.base_precision)
			    * arp_global.base_precision
        	)
        ),0)

  INTO    l_rounding_diff,
          l_acctd_rounding_diff
  FROM    ar_distribution_set_lines
  WHERE   distribution_set_id = p_distribution_set_id;

  arp_util.debug('Rounding error = ' || to_char(l_rounding_diff));
  arp_util.debug('Rounding error (acctd) = ' || to_char(l_acctd_rounding_diff));


  IF (l_acctd_rounding_diff <> 0 OR l_rounding_diff <>0) THEN

     /*----------------------------------+
     | Added bulk collect of misc cash  |
     | distribution id for use in MRC   |
     | engine for trigger replacement   |
     +----------------------------------*/

    UPDATE  ar_misc_cash_distributions
    SET     amount  		= amount + l_rounding_diff,
            acctd_amount	= acctd_amount + l_acctd_rounding_diff,
            percent =  ROUND (
                         (amount + l_rounding_diff)*100/p_amount,
                          3 )
    WHERE   cash_receipt_id = p_cash_receipt_id
      AND   ROWNUM = 1
     RETURNING misc_cash_distribution_id
     BULK COLLECT INTO l_misc_cash_key_value_list;

    /*---------------------------------+
     | Calling central MRC library     |
     | for MRC Integration             |
     +---------------------------------*/
/*BUG4301323
     ar_mrc_engine.maintain_mrc_data(
             p_event_mode        => 'UPDATE',
             p_table_name        => 'AR_MISC_CASH_DISTRIBUTIONS',
             p_mode              => 'BATCH',
             p_key_value_list    => l_misc_cash_key_value_list);
*/

  END IF;

  -- round percentages if necessary

  round_mcd_recs(p_cash_receipt_id);

  arp_standard.debug('arp_process_receipts.create_mcd_recs()-');

END; -- create_mcd_recs()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_manual_dist                          			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    creates distribution in ar_misc_cash_distributions based on a pre-     |
 |    defined distribution set. This function also takes care of possible    |
 |    rounding errors.                      				     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    22-SEP-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_manual_dist(
		p_cash_receipt_id  IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_amount	   IN ar_cash_receipts.amount%TYPE,
		p_acctd_amount	   IN ar_cash_receipt_history.acctd_amount%TYPE,
		p_exchange_rate    IN ar_cash_receipts.exchange_rate%TYPE,
		p_currency_code    IN ar_cash_receipts.currency_code%TYPE,
		p_gl_date	   IN ar_cash_receipt_history.gl_date%TYPE,
		p_receipt_date	   IN ar_cash_receipts.receipt_date%TYPE
			) IS

l_min_unit		NUMBER;
l_precision		NUMBER;
l_acctd_rounding_diff	NUMBER;
l_rounding_diff		NUMBER;
l_misc_cash_key_value_list      gl_ca_utility_pkg.r_key_value_arr;

BEGIN

  arp_standard.debug('arp_process_receipts.update_manual_dist()+');

  SELECT minimum_accountable_unit,precision
  INTO   l_min_unit, l_precision
  FROM   fnd_currencies
  WHERE  currency_code = p_currency_code;

   /*----------------------------------+
     | Added bulk collect of misc cash  |
     | distribution id for use in MRC   |
     | engine for trigger replacement   |
     +----------------------------------*/

  UPDATE ar_misc_cash_distributions
  SET  gl_date = p_gl_date,
       apply_date = p_receipt_date,
       amount = decode
          (
            l_min_unit, null,
            round(p_amount * percent/100,
                             l_precision),
            round(p_amount * (percent/100)/l_min_unit)
                       * l_min_unit
           ),
       acctd_amount = decode
          (
           arp_global.base_min_acc_unit, null,
           round((p_amount * percent/100) * nvl(p_exchange_rate,1),
                            arp_global.base_precision),
           round(p_amount * (percent/100) * nvl(p_exchange_rate,1)
 		/ arp_global.base_precision) * arp_global.base_precision
        ),
    	last_updated_by = arp_global.user_id,
    	last_update_date = arp_global.last_update_date
  WHERE cash_receipt_id = p_cash_receipt_id
  RETURNING misc_cash_distribution_id
  BULK COLLECT INTO l_misc_cash_key_value_list;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*BUG4301323
    ar_mrc_engine.maintain_mrc_data(
               p_event_mode        => 'UPDATE',
               p_table_name        => 'AR_MISC_CASH_DISTRIBUTIONS',
               p_mode              => 'BATCH',
               p_key_value_list    => l_misc_cash_key_value_list);
*/
  -- determine if there is a rounding error

  SELECT  NVL(p_amount, 0) -
        NVL(SUM
        (
        	decode
        	(
          	  l_min_unit, null,
          	  round(p_amount * percent/100,
                            l_precision),
          	  round(p_amount*(percent/100)/l_min_unit)
			*l_min_unit
        	)
        ),0)
        ,
        NVL(p_acctd_amount, 0) -
        NVL(SUM
        (
        	decode
        	(
        	  arp_global.base_min_acc_unit, null,
          	  round((p_amount * percent/100)
                                        * nvl(p_exchange_rate,1),
                            arp_global.base_precision),
                  round(p_amount * (percent/100)
                                        * nvl(p_exchange_rate ,1) /
                            arp_global.base_precision)
			    * arp_global.base_precision
        	)
        ),0)

  INTO    l_rounding_diff,
          l_acctd_rounding_diff
  FROM    ar_misc_cash_distributions
  WHERE   cash_receipt_id = p_cash_receipt_id;

  arp_util.debug('Rounding error = ' || to_char(l_rounding_diff));
  arp_util.debug('Rounding error (acctd) = ' || to_char(l_acctd_rounding_diff));


  IF (l_acctd_rounding_diff <> 0 OR l_rounding_diff <>0) THEN

     /*----------------------------------+
     | Added bulk collect of misc cash  |
     | distribution id for use in MRC   |
     | engine for trigger replacement   |
     +----------------------------------*/
    UPDATE  ar_misc_cash_distributions
    SET     amount  		= amount + l_rounding_diff,
            acctd_amount	= acctd_amount + l_acctd_rounding_diff,
            percent =  ROUND (
                         (amount + l_rounding_diff)*100/p_amount,
                          3 )
    WHERE   cash_receipt_id = p_cash_receipt_id
      AND   ROWNUM = 1
      RETURNING misc_cash_distribution_id
      BULK COLLECT INTO l_misc_cash_key_value_list;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*BUG4301323
    ar_mrc_engine.maintain_mrc_data(
               p_event_mode        => 'UPDATE',
               p_table_name        => 'AR_MISC_CASH_DISTRIBUTIONS',
               p_mode              => 'BATCH',
               p_key_value_list    => l_misc_cash_key_value_list);
*/

  END IF;

  -- round percent columns if necessary

  round_mcd_recs(p_cash_receipt_id);

  arp_standard.debug('arp_process_receipts.update_manual_dist()-');

END; -- update_manual_dist()
--


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    rate_adjust  	                           			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a record into the rate adjustments table by      |
 |    calling the rate adjustments table handler.  The INSERT will cause     |
 |    a database trigger to fire, which will update related tables.          |
 |    This function is being called from update_cash_receipts and from       |
 |    update_misc_receipts.						     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    26-JAN-96	OSTEINME	created					     |
 |    08-AUG-97 KLAWRANC        Added call to arp_rate_adj.main as the rate  |
 |                              adjustments trigger has been removed in      |
 |                              Release 11.                                  |
 |                                                                           |
 +===========================================================================*/

PROCEDURE rate_adjust(
	p_cash_receipt_id	      IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_rate_adjust_gl_date	      IN DATE,
	p_new_exchange_date	      IN DATE,
	p_new_exchange_rate	      IN ar_rate_adjustments.new_exchange_rate%TYPE,
	p_new_exchange_rate_type      IN ar_rate_adjustments.new_exchange_rate_type%TYPE,
	p_old_exchange_date	      IN DATE,
	p_old_exchange_rate	      IN ar_rate_adjustments.old_exchange_rate%TYPE,
	p_old_exchange_rate_type      IN ar_rate_adjustments.old_exchange_rate_type%TYPE,
	p_gain_loss		      IN ar_rate_adjustments.gain_loss%TYPE,
	p_exchange_rate_attr_cat      IN ar_rate_adjustments.attribute_category%TYPE,
 	p_exchange_rate_attr1	      IN ar_rate_adjustments.attribute1%TYPE,
 	p_exchange_rate_attr2	      IN ar_rate_adjustments.attribute2%TYPE,
 	p_exchange_rate_attr3	      IN ar_rate_adjustments.attribute3%TYPE,
 	p_exchange_rate_attr4	      IN ar_rate_adjustments.attribute4%TYPE,
 	p_exchange_rate_attr5	      IN ar_rate_adjustments.attribute5%TYPE,
 	p_exchange_rate_attr6	      IN ar_rate_adjustments.attribute6%TYPE,
 	p_exchange_rate_attr7	      IN ar_rate_adjustments.attribute7%TYPE,
 	p_exchange_rate_attr8	      IN ar_rate_adjustments.attribute8%TYPE,
 	p_exchange_rate_attr9	      IN ar_rate_adjustments.attribute9%TYPE,
 	p_exchange_rate_attr10	      IN ar_rate_adjustments.attribute10%TYPE,
 	p_exchange_rate_attr11	      IN ar_rate_adjustments.attribute11%TYPE,
 	p_exchange_rate_attr12	      IN ar_rate_adjustments.attribute12%TYPE,
 	p_exchange_rate_attr13	      IN ar_rate_adjustments.attribute13%TYPE,
 	p_exchange_rate_attr14	      IN ar_rate_adjustments.attribute14%TYPE,
 	p_exchange_rate_attr15	      IN ar_rate_adjustments.attribute15%TYPE) IS

  l_radj_rec	ar_rate_adjustments%ROWTYPE;
  l_radj_id	ar_rate_adjustments.rate_adjustment_id%TYPE;
  l_crh_id_out	ar_cash_receipt_history.cash_receipt_history_id%TYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_rct_util.rate_adjust()+');
  END IF;

  l_radj_rec.cash_receipt_id		:= p_cash_receipt_id;
  l_radj_rec.old_exchange_rate		:= p_old_exchange_rate;
  l_radj_rec.old_exchange_date		:= p_old_exchange_date;
  l_radj_rec.old_exchange_rate_type	:= p_old_exchange_rate_type;
  l_radj_rec.new_exchange_rate		:= p_new_exchange_rate;
  l_radj_rec.new_exchange_date		:= p_new_exchange_date;
  l_radj_rec.new_exchange_rate_type	:= p_new_exchange_rate_type;
  l_radj_rec.gain_loss			:= p_gain_loss;
  l_radj_rec.gl_date			:= p_rate_adjust_gl_date;
  l_radj_rec.attribute_category		:= p_exchange_rate_attr_cat;
  l_radj_rec.attribute1			:= p_exchange_rate_attr1;
  l_radj_rec.attribute2			:= p_exchange_rate_attr2;
  l_radj_rec.attribute3			:= p_exchange_rate_attr3;
  l_radj_rec.attribute4			:= p_exchange_rate_attr4;
  l_radj_rec.attribute5			:= p_exchange_rate_attr5;
  l_radj_rec.attribute6			:= p_exchange_rate_attr6;
  l_radj_rec.attribute7			:= p_exchange_rate_attr7;
  l_radj_rec.attribute8			:= p_exchange_rate_attr8;
  l_radj_rec.attribute9			:= p_exchange_rate_attr9;
  l_radj_rec.attribute10		:= p_exchange_rate_attr10;
  l_radj_rec.attribute11		:= p_exchange_rate_attr11;
  l_radj_rec.attribute12		:= p_exchange_rate_attr12;
  l_radj_rec.attribute13		:= p_exchange_rate_attr13;
  l_radj_rec.attribute14		:= p_exchange_rate_attr14;
  l_radj_rec.attribute15		:= p_exchange_rate_attr15;

  l_radj_rec.created_from		:= 'ARXCAACI';

  arp_rate_adjustments_pkg.insert_p(
	l_radj_rec,
	l_radj_id);

  -- Call procedure that performs the rate adjustment processing,
  -- e.g. updates receivable applications etc.
  arp_rate_adj.main(
    p_cash_receipt_id,
    p_new_exchange_date,
    p_new_exchange_rate,
    p_new_exchange_rate_type,
    p_rate_adjust_gl_date,
    arp_standard.profile.user_id,
    sysdate,
    arp_standard.profile.user_id,
    sysdate,
    arp_standard.profile.last_update_login,
    TRUE,
    l_crh_id_out);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_rct_util.rate_adjust()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Exception in arp_process_rct_util.rate_adjust');
      END IF;
      RAISE;

END rate_adjust;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   get_ccids		              					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    	determines the ccid's a given remittance bank account and            |
 |	payment method combination.   			                     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |   29-AUG-95	OSTEINME	created					     |
 |                                                                           |
 |   04-NOV-96  OSTEINME	changed name from get_ra_ccid to get_ccids   |
 |				and added parameters to allow procedure to   |
 |				return all ccid's for the IN parameters      |
 |   07-JAN-98  DJANCIS         selected code combination id's for earned    |
 |                              and unearnd ccids from                       |
 |                              ar_receivables_trx instead of                |
 |                              ar_receipt_method_accounts for               |
 |                              11.5 VAT changes                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE  get_ccids(
	p_receipt_method_id		IN 	NUMBER,
	p_remittance_bank_account_id	IN 	NUMBER,
	p_unidentified_ccid		OUT NOCOPY	NUMBER,
	p_unapplied_ccid		OUT NOCOPY	NUMBER,
	p_on_account_ccid		OUT NOCOPY	NUMBER,
	p_earned_ccid			OUT NOCOPY	NUMBER,
	p_unearned_ccid			OUT NOCOPY	NUMBER,
	p_bank_charges_ccid		OUT NOCOPY	NUMBER,
	p_factor_ccid			OUT NOCOPY	NUMBER,
	p_confirmation_ccid		OUT NOCOPY	NUMBER,
	p_remittance_ccid		OUT NOCOPY 	NUMBER,
	p_cash_ccid			OUT NOCOPY	NUMBER
	) IS
BEGIN

 /* selected code combination id's for earned and unearnd ccids from
    ar_receivables_trx instead of ar_receipt_method_accounts for
    11.5 VAT changes  */

    SELECT
		rma.unidentified_ccid,
		rma.unapplied_ccid,
		rma.on_account_ccid,
		ed.code_combination_id,    /* earned_ccid   */
		uned.code_combination_id,  /* unearned_ccid */
		rma.bank_charges_ccid,
		rma.factor_ccid,
		rma.receipt_clearing_ccid,
		rma.remittance_ccid,
		rma.cash_ccid
    INTO
		p_unidentified_ccid,
		p_unapplied_ccid,
		p_on_account_ccid,
		p_earned_ccid,
		p_unearned_ccid,
		p_bank_charges_ccid,
		p_factor_ccid,
		p_confirmation_ccid,
		p_remittance_ccid,
		p_cash_ccid
    FROM
		AR_RECEIPT_METHOD_ACCOUNTS rma,
                AR_RECEIVABLES_TRX ed,
                AR_RECEIVABLES_TRX uned
    WHERE       remit_bank_acct_use_id = p_remittance_bank_account_id
    AND   	receipt_method_id = p_receipt_method_id
    AND         rma.edisc_receivables_trx_id   = ed.receivables_trx_id (+)
    AND         rma.unedisc_receivables_trx_id = uned.receivables_trx_id (+);

    EXCEPTION
      WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: arp_process_receipts.get_ccids');
       END IF;
       RAISE;

END get_ccids;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   get_ps_rec		              					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   gets the payment schedule record of a receipt given a cash_receipt_id   |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |   19-NOV-96	OSTEINME	created					     |
 +===========================================================================*/

PROCEDURE get_ps_rec(	p_cash_receipt_id 	IN NUMBER,
			p_ps_rec		OUT NOCOPY ar_payment_schedules%ROWTYPE) IS

  l_ps_id NUMBER;

BEGIN

  SELECT payment_schedule_id
  INTO   l_ps_id
  FROM   ar_payment_schedules
  WHERE  cash_receipt_id = p_cash_receipt_id;

  -- the following should utimately be done with nowaitlock_fetch_p (but
  -- it didn't exist yet when this function was written and tested).

  arp_ps_pkg.fetch_p(	l_ps_id,
			p_ps_rec);

END get_ps_rec;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   update_dist_rec	              					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   updates a record in AR_DISTRIBUTIONS table				     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |   19-NOV-96	OSTEINME	created					     |
 +===========================================================================*/

PROCEDURE update_dist_rec( p_crh_id		IN NUMBER,
			   p_source_type	IN ar_distributions.source_type%TYPE,
			   p_amount		IN NUMBER,
			   p_acctd_amount	IN NUMBER) IS

  l_dist_rec		AR_DISTRIBUTIONS%ROWTYPE;
  l_amount		number;
  l_acctd_amount	number;
BEGIN

    -- fetch existing distributions record for update:

    arp_distributions_pkg.nowaitlock_fetch_pk(
			p_crh_id,
			'CRH',
			p_source_type,
			l_dist_rec);

      /* Commented the following code for bug 2311742
	IF (p_amount < 0) THEN
          l_dist_rec.amount_dr := NULL;
          l_dist_rec.amount_cr := - p_amount;
        ELSE
          l_dist_rec.amount_dr := p_amount;
          l_dist_rec.amount_cr := NULL;
        END IF;

        IF (p_acctd_amount < 0) THEN
          l_dist_rec.acctd_amount_dr := NULL;
          l_dist_rec.acctd_amount_cr := - p_acctd_amount;
        ELSE
          l_dist_rec.acctd_amount_dr := p_acctd_amount;
          l_dist_rec.acctd_amount_cr := NULL;
        END IF; */

	/* Added the following code for bug 2311742 */

	IF (l_dist_rec.amount_dr is not null) THEN
          l_amount := l_dist_rec.amount_dr + p_amount;

          If (l_amount > 0) then
                l_dist_rec.amount_dr := l_amount;
                l_dist_rec.amount_cr := null;
          else
                l_dist_rec.amount_cr := - l_amount;
                l_dist_rec.amount_dr := null;
          End if;
        ELSE
          l_amount := l_dist_rec.amount_cr - p_amount;

          If ( l_amount >= 0) then
                l_dist_rec.amount_dr := null;
                l_dist_rec.amount_cr := l_amount;
	  Else
                l_dist_rec.amount_dr := - l_amount;
                l_dist_rec.amount_cr := null;
          End if;
        END IF;

        IF (l_dist_rec.acctd_amount_dr is not null) THEN
	  l_acctd_amount := l_dist_rec.acctd_amount_dr + p_acctd_amount;

	  If (l_acctd_amount > 0) then
                l_dist_rec.acctd_amount_dr := l_acctd_amount;
                l_dist_rec.acctd_amount_cr := null;
          Else
                l_dist_rec.acctd_amount_cr := - l_acctd_amount;
                l_dist_rec.acctd_amount_dr := null;
          End if;

        ELSE
          l_acctd_amount := l_dist_rec.acctd_amount_cr - p_acctd_amount;

          If (l_acctd_amount >= 0) then
                l_dist_rec.acctd_amount_dr := null;
                l_dist_rec.acctd_amount_cr :=  l_acctd_amount;
	  Else
                l_dist_rec.acctd_amount_dr := - l_acctd_amount;
                l_dist_rec.acctd_amount_cr := null;
          End if;
        END IF;
	/* End of bug 2311742 */

	arp_distributions_pkg.update_p(l_dist_rec);

        /* need to update records into the MRC table.  Calling new
           mrc engine */
/*4301323
        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'UPDATE',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);
*/
END update_dist_rec;
END ARP_PROC_RCT_UTIL;

/
