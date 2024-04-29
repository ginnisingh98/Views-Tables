--------------------------------------------------------
--  DDL for Package Body ARP_PROC_RECEIPTS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROC_RECEIPTS1" AS
/* $Header: ARRERG1B.pls 120.22.12010000.9 2010/07/01 18:18:29 rravikir ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION revision RETURN VARCHAR2 IS
BEGIN

   RETURN '$Revision: 120.22.12010000.9 $';

END revision;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_cash_receipt                              			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Entity handler that updates cash transactions.		     	     |
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
 |    21-AUG-95	OSTEINME	created					     |
 |    15-MAR-96 OSTEINME	removed calls to procedure                   |
 |				arp_cr_util.get_creation_info as they cause  |
 | 				problems if the receipt is created as        |
 |				approved (in this case it doesn't have       |
 |				entries in AR_DISTRIBUTIONS yet.	     |
 |    05-APR-96 OSTEINME	added functionality (and parameters) to      |
 |				return receipt state and status info after   |
 |				update.					     |
 |    30-MAY-96 OSTEINME	added parameter p_status for bug 370072      |
 |    19-NOV-96  OSTEINME	modified update_cash_receipts procedure to   |
 |				support changing the amount even if apps     |
 |				exist.					     |
 |    27-DEC-96 OSTEINME	added global flexfield parameters            |
 |    05-MAY-97 KLAWRANC        Added section to determine a valid GL and    |
 |                              Reversal GL date for receivable applications.|
 |                              This date is then used for update and        |
 |                              creation of application records.             |
 |    01-JUL-97 KLAWRANC        Bug fixes #511576, 511312.                   |
 |                              Use valid GL date when updating and creating |
 |                              receipt records.                             |
 |                              Corrected calculation of amount due remain   |
 |                              used to update receipt payment schedule row. |
 |    29-AUG-97 KLAWRANC        Bug fix #462056.                             |
 |                              Added update of AP Bank Uses for MICR #      |
 |                              functionality.                               |
 |    04-DEC-97 KLAWRANC        Bug #590256.  Modified calls to              |
 |                              calc_acctd_amount.  Now passes NULL for the  |
 |                              currency code parameter, therefore the acctd |
 |                              amount will be calculated based on the       |
 |                              functional currency.
 |    20-FEB-97 KLAWRANC        Bugs #616531, 625124, 625132.                |
 |                              Moved the update of receipt payment          |
 |                              schedule amounts to outside the              |
 |                              posted/not posted check.                     |
 |                              Corrected the calculation of                 |
 |                              l_crh_fda_delta and l_crh_acctd_fda_delta.   |
 |                              This did not use nvl in calculations which   |
 |                              caused an incorrect result if the bank       |
 |                              was initially null or changed to null.       |
 |                              Created a select statement to check for      |
 |                              the existance of a bank charges row in the   |
 |                              distributions table.  This is used to        |
 |                              determine if a row needs to be created or    |
 |                              we can simply update the existing one.       |
 |                              If a bank charges row already exists and     |
 |                              bank charges is set to NULL, update the row  |
 |                              with zero amounts.                           |
 |                              Included select statement to sum existing    |
 |                              bank charge DR and CR entries.  This is used |
 |                              to calculate the new DR and CR amounts       |
 |                              (taking into account previously posted rows).|
 |     16-APR-1998 GJWANG       Bug # 635872 Added condition checking whether|
 |                              amount_due_remaining <> 0 and update cash    |
 |                              receipt status to UNAPP and payment schedule |
 |                              status to UNAPP and payment schedule staus to|
 |                              'OP' and call populate_closed_dates to       |
 |                              determine correct gl_date_closed and         |
 |                              actual_date_closed                           |
 |     21-MAY-1998 KTANG	For all calls to calc_acctd_amount which     |
 |				calculates header accounted amounts, if the  |
 |				exchange_rate_type is not user, call 	     |
 |				gl_currency_api.convert_amount instead. This |
 |				is for triangulation.			     |
 |     29-JUL-1998 K.Murphy     Bug #667450.  Modified calculation of acctd  |
 |                              factor discount amount.                      |
 |     28-MAY-1999 J Rautiainen Bug #894443. The status of unidentified      |
 |                              receipts cannot be changed to unapp.         |
 |     12-OCT-2001 R Muthuraman Bug #2024016. Rate adjustment fail when      |
 |				rate type is changed from 'User' to another  |
 |				rate type.                                   |
 |     25-03-2003  Ravi Sharma  Bug 2855253.debit and credit mismatch when   |
 |                              the bank charges are updated.                |
 |     07-MAY-2003 Jon Beckett  Bug 2946734 - moved claim update from        |
 |                              ARXRWRCT.pld                                 |
 |     30-JUL-2004 Jon Beckett  Bug 3796142 - removed unnecessary calls to   |
 | 				gl_currency_api to convert receipt amount    |
 |                              to functional currency. Receipt rate used    |
 |				instead of GL daily rate in all cases.       |
 |				Currency conversion only performed if amount |
 |				has changed, otherwise acctd amount retrieved|
 |                              from receipt history.                        |
 |                                                                           |
 |     01-JUN-2006  Herve Yu    BUG#4353362 Third Party Merge api uptake     |
 +===========================================================================*/


PROCEDURE update_cash_receipt(
	p_cash_receipt_id	IN NUMBER,
--	p_batch_id		IN NUMBER,
	p_status		IN VARCHAR2,
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
--
	p_confirm_date		      IN  DATE,
	p_confirm_gl_date	      IN  DATE,
	p_unconfirm_gl_date	      IN DATE,
        p_postmark_date               IN date, -- ARTA Changes
-- ******* Rate Adjustment parameters: ********
	p_rate_adjust_gl_date	      IN DATE,
	p_new_exchange_date	      IN DATE,
	p_new_exchange_rate	      IN NUMBER,
	p_new_exchange_rate_type      IN VARCHAR2,
	p_gain_loss		      IN NUMBER,
	p_exchange_rate_attr_cat      IN VARCHAR2,
 	p_exchange_rate_attr1	      IN VARCHAR2,
 	p_exchange_rate_attr2	      IN VARCHAR2,
 	p_exchange_rate_attr3	      IN VARCHAR2,
 	p_exchange_rate_attr4	      IN VARCHAR2,
 	p_exchange_rate_attr5	      IN VARCHAR2,
 	p_exchange_rate_attr6	      IN VARCHAR2,
 	p_exchange_rate_attr7	      IN VARCHAR2,
 	p_exchange_rate_attr8	      IN VARCHAR2,
 	p_exchange_rate_attr9	      IN VARCHAR2,
 	p_exchange_rate_attr10	      IN VARCHAR2,
 	p_exchange_rate_attr11	      IN VARCHAR2,
 	p_exchange_rate_attr12	      IN VARCHAR2,
 	p_exchange_rate_attr13	      IN VARCHAR2,
 	p_exchange_rate_attr14	      IN VARCHAR2,
 	p_exchange_rate_attr15	      IN VARCHAR2,
--
-- ********* Reversal Info ***********
--
	p_reversal_date		IN DATE,
	p_reversal_gl_date	IN DATE,
	p_reversal_category	IN VARCHAR2,
	p_reversal_comments	IN VARCHAR2,
	p_reversal_reason_code  IN VARCHAR2,
	p_dm_reversal_flag  	IN varchar2,
	p_dm_cust_trx_type_id	IN NUMBER,
	p_dm_cust_trx_type	IN VARCHAR2,
	p_cc_id			IN NUMBER,
	p_dm_number		OUT NOCOPY VARCHAR2,
	p_dm_doc_sequence_value IN NUMBER,
	p_dm_doc_sequence_id	IN NUMBER,
	p_tw_status		IN OUT NOCOPY VARCHAR2,

	p_anticipated_clearing_date	IN DATE,
	p_customer_bank_branch_id	IN NUMBER,
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
-- ******* Notes Receivable Information *******
        p_issuer_name           	IN VARCHAR2,
        p_issue_date            	IN DATE,
        p_issuer_bank_branch_id 	IN NUMBER,
--
-- ******* enhancement 2074220 *****************
        p_application_notes             IN VARCHAR2,
--
-- ******* Receipt State/Status Return information ******
--
	p_new_state		OUT NOCOPY VARCHAR2,
	p_new_state_dsp		OUT NOCOPY VARCHAR2,
	p_new_status		OUT NOCOPY VARCHAR2,
	p_new_status_dsp	OUT NOCOPY VARCHAR2,
--
--
-- ******* Form information ********
        p_form_name                     IN  VARCHAR2,
        p_form_version                  IN  VARCHAR2,
--
-- ******* Credit Card changes
        p_payment_server_order_num      IN  VARCHAR2,
        p_approval_code                 IN  VARCHAR2,
        p_legal_entity_id               IN  NUMBER default NULL,
        p_payment_trxn_extension_id     IN  NUMBER default NULL,   /* PAYMENT_UPTAKE */
	p_automatch_set_id             IN NUMBER  DEFAULT NULL, /* ER Automatch Application */
        p_autoapply_flag               IN VARCHAR2  DEFAULT NULL

			) IS

l_cr_rec		ar_cash_receipts%ROWTYPE;
l_crh_rec		ar_cash_receipt_history%ROWTYPE;
l_crh_rec_new		ar_cash_receipt_history%ROWTYPE;
l_ps_rec		ar_payment_schedules%ROWTYPE;
l_dist_rec		ar_distributions%ROWTYPE;
l_crh_id_new		ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_ra_id_unapp           ar_receivable_applications.receivable_application_id%TYPE;
l_ra_id_unid            ar_receivable_applications.receivable_application_id%TYPE;
l_ae_doc_rec            ae_doc_rec_type;

-- boolean flags:

l_cr_amount_changed_flag	BOOLEAN := FALSE;
l_crh_fda_changed_flag		BOOLEAN	:= FALSE;
l_crh_acctd_fda_changed_flag    BOOLEAN := FALSE;
l_crh_rec_posted_flag		BOOLEAN := FALSE;
l_crh_rec_gl_date_changed       BOOLEAN := FALSE;
l_rct_identified_flag		BOOLEAN := FALSE;
l_rct_unidentified_flag		BOOLEAN := FALSE;

-- accounts:

l_crh_ccid			NUMBER;
l_bank_charges_ccid		NUMBER;
l_unidentified_ccid		NUMBER;
l_unapplied_ccid		NUMBER;
l_dummy_ccid			NUMBER;		-- dummy ccid parameter

-- amounts:

l_cr_acctd_amount_new		NUMBER;
l_cr_acctd_amount_old		NUMBER;
l_cr_amount_delta		NUMBER;
l_cr_acctd_amount_delta		NUMBER;
l_crh_amount_new		NUMBER;
l_crh_amount_delta		NUMBER;
l_crh_acctd_amount_new		NUMBER;
l_crh_acctd_amount_delta	NUMBER;
l_crh_acctd_fda_new		NUMBER;
l_crh_acctd_fda_delta		NUMBER;
l_crh_fda_delta			NUMBER;
l_sum_fda_debits                NUMBER;
l_sum_fda_credits               NUMBER;
l_sum_acctd_fda_debits          NUMBER;
l_sum_acctd_fda_credits         NUMBER;

-- other stuff:

l_source_type			ar_distributions.source_type%TYPE;
l_creation_status		ar_cash_receipt_history.status%TYPE;
l_rev_crh_id			ar_cash_receipt_history.reversal_cash_receipt_hist_id%TYPE;

-- dummy variables:

l_override_dummy		ar_cash_receipts.override_remit_account_flag%TYPE;
l_number_dummy			NUMBER;

-- GL date defaulting variables
l_error_message                 VARCHAR2(128);
l_defaulting_rule_used          VARCHAR2(50);
l_valid_gl_date                 DATE;
error_defaulting_gl_date        EXCEPTION;

l_bank_charges_row_exists       VARCHAR2(1);
l_bcharge_row_on_current_crh    VARCHAR2(1); /* Bug fix 3677912 */
l_dist_row_on_current_crh       VARCHAR2(1); /* Bug fix 3677912 */


-- old stuff:
/*
l_source_type_old	ar_distributions.source_type%TYPE;
l_creation_status_old	ar_cash_receipt_history.status%TYPE;
l_acctd_amount_old	ar_cash_receipt_history.acctd_amount%TYPE;
l_ccid_old		ar_cash_receipt_history.account_code_combination_id%TYPE;
l_source_type_new	ar_distributions.source_type%TYPE;
l_creation_status_new	ar_cash_receipt_history.status%TYPE;
l_acctd_amount_new	ar_cash_receipt_history.acctd_amount%TYPE;
l_ccid_new		ar_cash_receipt_history.account_code_combination_id%TYPE;
l_ps_id			ar_payment_schedules.payment_schedule_id%TYPE;
l_id_dummy		NUMBER;
l_amount_changed	BOOLEAN := FALSE;
l_rev_crh_id		ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_ra_unapp_ccid		NUMBER;
l_ra_unid_ccid		NUMBER;
l_ra_unapp_ccid_old	NUMBER;
l_ra_unid_ccid_old	NUMBER;

*/

/* Bug8422361 - Variable Declaration - Start. */
l_no_of_accounts        NUMBER;
l_no_of_other_accounts  NUMBER;
l_no_of_other_party_accounts NUMBER;
l_bank_assign_flag      BOOLEAN := FALSE;
l_party_id              NUMBER;
l_api_version           NUMBER := 1.0;
l_init_msg_list         VARCHAR2(30) DEFAULT FND_API.G_TRUE;
l_joint_acct_owner_id   NUMBER;
l_iby_return_status     VARCHAR2(30);
l_iby_msg_count         NUMBER;
l_iby_msg_data          VARCHAR2(2000);
l_response_rec          IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_instr_assign_id       NUMBER;
/* Bug8422361 - Variable Declaration - End. */


/*added for the bug 2641517 */
l_rct_site_changed_flag     BOOLEAN := FALSE;
l_rct_customer_changed_flag BOOLEAN := FALSE;
l_trx_sum_hist_rec          AR_TRX_SUMMARY_HIST%rowtype;
l_history_id     NUMBER;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

--{BUG#4353362
CURSOR cu_current_customer IS
SELECT pay_from_customer,
       customer_site_use_id
  FROM ar_cash_receipts
 WHERE cash_receipt_id = p_cash_receipt_id;
l_current_customer_id     NUMBER;
l_current_csu_id          NUMBER;
x_errbuf                  VARCHAR2(2000);
x_retcode                 VARCHAR2(10);
x_event_ids               xla_third_party_merge_pub.t_event_ids;
x_request_id              NUMBER;
--}
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.update_cash_receipt()+');
  END IF;

  -- --------------------------------------------------------------
  -- First fetch and lock existing records from database for update
  -- --------------------------------------------------------------

  -- get current cash_receipt_history record:

  l_crh_rec.cash_receipt_id	:= p_cash_receipt_id;
  arp_cr_history_pkg.nowaitlock_fetch_f_cr_id(l_crh_rec);

  -- get cash receipt record:

  l_cr_rec.cash_receipt_id 	:= p_cash_receipt_id;
  arp_cash_receipts_pkg.nowaitlock_fetch_p(l_cr_rec);

  -- get payment schedule record for receipt:

  arp_proc_rct_util.get_ps_rec(l_cr_rec.cash_receipt_id,
	     l_ps_rec);

   --apandit
   --Bug 2641517, populating the history rec.
   l_trx_sum_hist_rec.cash_receipt_id := l_ps_rec.cash_receipt_id;
   l_trx_sum_hist_rec.site_use_id   := l_ps_rec.customer_site_use_id;
   l_trx_sum_hist_rec.customer_id   := l_ps_rec.customer_id;
   l_trx_sum_hist_rec.currency_code := l_ps_rec.invoice_currency_code;
   l_trx_sum_hist_rec.amount_due_original := l_ps_rec.amount_due_original;
   l_trx_sum_hist_rec.amount_due_remaining := l_ps_rec.amount_due_remaining;
   l_trx_sum_hist_rec.payment_schedule_id := l_ps_rec.payment_schedule_id;
   l_trx_sum_hist_rec.trx_date            := l_ps_rec.trx_date;

    IF nvl(p_customer_site_use_id,0) <> nvl(l_ps_rec.customer_site_use_id,0)
     THEN
        l_rct_site_changed_flag := TRUE;
    END IF;

    IF p_pay_from_customer IS NOT NULL AND
       l_ps_rec.customer_id IS NOT NULL AND
       p_pay_from_customer <> l_ps_rec.customer_id  THEN
      l_rct_customer_changed_flag := TRUE;
    END IF;

  -- KML 05-13-97
  -----------------------------------------------------
  -- Determine a valid GL date for receipt and apps
  -- use the receipt gl_date as a base
  -- need to make sure that it is in a valid GL period
  -----------------------------------------------------
  IF (arp_util.validate_and_default_gl_date(
                l_crh_rec.gl_date,
                NULL,
                NULL,
                NULL,
                NULL,
                l_crh_rec.gl_date,
                NULL,
                NULL,
                'N',
                NULL,
                arp_global.set_of_books_id,
                222,
                l_valid_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE) THEN
     null;
  ELSE
     RAISE error_defaulting_gl_date;
  END IF;

  -- -------------------------------------------------------------
  -- Now compare parameters with database values to find out NOCOPY what
  -- has changed and what needs to be done.  Depending on whether
  -- the amounts have changed and whether the receipt was already
  -- posted, more or less complicated things need to be done.
  -- -------------------------------------------------------------

  -- check if cr.amount has changed

  IF (p_amount <> l_cr_rec.amount)
    THEN
      l_cr_amount_changed_flag := TRUE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'l_cr_amount_changed_flag = TRUE');
      END IF;
  END IF;

  -- check if the gl date of the receipt is still valid

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('update_cash_receipt: ' || 'P_GL_DATE is:' || to_char(p_gl_date, 'DD-MM-YYYY:HH:SS'));
     arp_standard.debug('update_cash_receipt: ' || 'l_valid_gl_date is:' || to_char(l_valid_gl_date, 'DD-MM-YYYY:HH:SS'));
  END IF;

  IF (p_gl_date <> l_valid_gl_date)
    THEN
      l_crh_rec_gl_date_changed := TRUE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'l_crh_rec_gl_date_changed = TRUE');
      END IF;
  END IF;


  -- check if crh.factor_discount_amount has changed

  IF (NVL(p_factor_discount_amount,0) <>
      NVL(l_crh_rec.factor_discount_amount,0))
    THEN
      l_crh_fda_changed_flag := TRUE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'l_crh_fda_changed_flag = TRUE');
      END IF;

  END IF;

  -- check if crh record was posted to GL

  IF (l_crh_rec.posting_control_id <> -3)
    THEN
      l_crh_rec_posted_flag := TRUE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'l_crh_rec_posted_flag = TRUE');
      END IF;
  END IF;

  -- check if receipt was identified  (UNID -> UNAPP)

  IF (l_cr_rec.pay_from_customer IS NULL AND
      p_pay_from_customer IS NOT NULL)
    THEN
      l_rct_identified_flag := TRUE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'l_rct_identified_flag = TRUE');
      END IF;
  END IF;

  -- check if receipt was "un-identified" (UNAPP -> UNID)

  IF (l_cr_rec.pay_from_customer IS NOT NULL AND
      p_pay_from_customer IS NULL)
    THEN
      l_rct_unidentified_flag := TRUE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'l_rct_unidentified_flag = TRUE');
      END IF;
  END IF;

  -- -------------------------------------------------------------
  -- determine account code combination ids
  -- -------------------------------------------------------------

  arp_proc_rct_util.get_ccids(
		p_receipt_method_id,
		p_remittance_bank_account_id,
		l_unidentified_ccid,
		l_unapplied_ccid,
		l_dummy_ccid,		-- on account
		l_dummy_ccid,		-- earned ccid
		l_dummy_ccid,		-- unearned ccid
		l_bank_charges_ccid,
		l_dummy_ccid,		-- factor ccid
		l_dummy_ccid,		-- confirmation_ccid
		l_dummy_ccid,		-- remittance ccid
		l_dummy_ccid		-- cash ccid
	   );

  -- -------------------------------------------------------------
  -- determine the source type and creation status
  -- -------------------------------------------------------------

  -- the source type is needed for AR_DISTRIBUTIONS records

  arp_cr_util.get_creation_info(p_receipt_method_id,
				p_remittance_bank_account_id,
	      			l_creation_status,
				l_source_type,
				l_crh_ccid,
				l_override_dummy);

  -- -------------------------------------------------------------
  -- determine the amounts
  -- -------------------------------------------------------------

  -- convert new cr.amount into functional currency:

  /* Bug 3796142 - receipt exchange rate should be used for updates, but
     only if amount has actually changed */
  l_cr_acctd_amount_old := (NVL(l_crh_rec.acctd_amount,0) + NVL(l_crh_rec.acctd_factor_discount_amount,0));
  IF (l_cr_amount_changed_flag) THEN
    arp_util.calc_acctd_amount(	NULL,
				NULL,
				NULL,
				l_cr_rec.exchange_rate,
				'+',
				p_amount,
				l_cr_acctd_amount_new,
				0,
				l_number_dummy,
				l_number_dummy,
				l_number_dummy);
  ELSE
     l_cr_acctd_amount_new := l_cr_acctd_amount_old;
  END IF;

  -- determine the new cash_receipt_history amount:

  l_crh_amount_new := p_amount - NVL(p_factor_discount_amount,0);

  /* Bug 3796142 - receipt exchange rate should be used for updates, but
     only if amount has actually changed */

  IF (l_cr_amount_changed_flag OR l_crh_fda_changed_flag) THEN
    arp_util.calc_acctd_amount(	NULL,
				NULL,
				NULL,
				l_cr_rec.exchange_rate,
				'+',
				l_crh_amount_new,
				l_crh_acctd_amount_new,
				0,
				l_number_dummy,
				l_number_dummy,
				l_number_dummy);
  ELSE
    l_crh_acctd_amount_new := l_crh_rec.acctd_amount;
  END IF;

  -- acctd_factor_discount_amount = triangulated(amount +
  --				      factor_discount_amount) -
  --				      triangulated(amount)

  l_crh_acctd_fda_new := l_cr_acctd_amount_new -
                 	 l_crh_acctd_amount_new;

  -- This will help us to identify the situation where the fda has not
  -- changed but the acctd fda has as a result of a receipt amount change.

  IF (NVL(l_crh_rec.acctd_factor_discount_amount,0) <>
      NVL(l_crh_acctd_fda_new,0)) THEN
     l_crh_acctd_fda_changed_flag := TRUE;
  END IF;

  -- determine deltas:

  l_cr_amount_delta 		:= p_amount -
				   l_cr_rec.amount;

  l_cr_acctd_amount_delta 	:= l_cr_acctd_amount_new -
				   l_cr_acctd_amount_old;

  l_crh_amount_delta		:= l_crh_amount_new -
				   l_crh_rec.amount;

  l_crh_acctd_amount_delta	:= l_crh_acctd_amount_new -
				   l_crh_rec.acctd_amount;

  l_crh_fda_delta		:= p_factor_discount_amount -
				   l_crh_rec.factor_discount_amount;

  l_crh_acctd_fda_delta		:= l_crh_acctd_fda_new -
				   l_crh_rec.acctd_factor_discount_amount;

  --
  -- Factor Discount Amount
  -- Need to use NVL as the Bank Charges may be null or modified to
  -- be null.
  --
  l_crh_fda_delta               := nvl(p_factor_discount_amount,0) -
                                   nvl(l_crh_rec.factor_discount_amount,0);

  l_crh_acctd_fda_delta         := nvl(l_crh_acctd_fda_new,0) -
                                   nvl(l_crh_rec.acctd_factor_discount_amount,0);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('update_cash_receipt: ' || 'p_amount = 		'|| to_char(p_amount));
     arp_standard.debug('update_cash_receipt: ' || 'l_crh_amount_new =	'|| to_char(l_crh_amount_new));
     arp_standard.debug('update_cash_receipt: ' || 'l_crh_acctd_amount_new =  '|| to_char(l_crh_acctd_amount_new));
  END IF;

  -- -------------------------------------------------------------
  -- handle changes in rct identification status
  -- -------------------------------------------------------------

  -- customer information:  can be updated as long as receipt has no
  --			    applications.  Form checks this; no check
  --			    required here.

  -- check if receipt status changed from UNID to UNAPP (i.e, receipt is
  -- now identified.  In this case, the UNID record
  -- needs to be reversed, and a new UNAPP record needs to be created.

  IF (l_rct_identified_flag = TRUE) THEN

    -- first reverse existing UNID record by setting reversal GL Date:

    UPDATE	ar_receivable_applications
    SET 	reversal_gl_date = l_valid_gl_date
    WHERE	cash_receipt_id  = p_cash_receipt_id
    AND	        reversal_gl_date IS NULL
    AND 	status = 'UNID';

    -- now create matching UNID record with negative amount

    arp_proc_rct_util.insert_ra_rec_cash(
			p_cash_receipt_id,
			-l_cr_rec.amount,
			p_receipt_date,
			'UNID',
			-l_cr_acctd_amount_old,
			l_valid_gl_date,
			l_unidentified_ccid,
			l_ps_rec.payment_schedule_id,
			'60.5',
                        l_valid_gl_date,
                        l_ra_id_unid     );

    --
    --Release 11.5 VAT changes, create UNID receivable application accounting
    --in ar_distributions
    --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_id_unid;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    -- now create new UNAPP record for this receipt:

    arp_proc_rct_util.insert_ra_rec_cash(
		      p_cash_receipt_id,
		      l_cr_rec.amount,
		      p_receipt_date,
		      'UNAPP',
		      l_cr_acctd_amount_old,
		      l_valid_gl_date,
		      l_unapplied_ccid,
		      l_ps_rec.payment_schedule_id,
		      '60.2',
                      '',
                      l_ra_id_unapp);

    -- 6924942 - Start
    update ar_receivable_applications
      set include_in_accumulation ='N'
    where cash_receipt_id = p_cash_receipt_id
    and   status = 'UNAPP';
    -- 6924942 - End

    --
    --Release 11.5 VAT changes, create Paired UNAPP receivable application accounting
    --in ar_distributions
    --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_id_unapp;
    l_ae_doc_rec.source_id_old             := l_ra_id_unid;
    l_ae_doc_rec.other_flag                := 'PAIR';

  /* We need to set the third party id and sub id as the cash receipt
     is updated later */
    l_ae_doc_rec.miscel5                   := p_pay_from_customer;
    l_ae_doc_rec.miscel6                   := p_customer_site_use_id;
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    -- also don't forget to set the pay_from_customer column in
    -- ar_cash_receipts to new customer and the status of the receipt:

    l_cr_rec.pay_from_customer := p_pay_from_customer;
    l_cr_rec.status := 'UNAPP';

  ELSIF	(l_rct_unidentified_flag = TRUE) THEN

    -- now take care of the case where the user NULL'ed out NOCOPY the customer
    -- fields:

    -- In this case, first reverse the UNAPP record and then create an
    -- UNID record.

    UPDATE	ar_receivable_applications
    SET 	reversal_gl_date = l_valid_gl_date
    WHERE	cash_receipt_id  = p_cash_receipt_id
    AND	        reversal_gl_date IS NULL
    AND 	status = 'UNAPP';

    -- now create matching UNAPP record with negative amount

    arp_proc_rct_util.insert_ra_rec_cash(
			p_cash_receipt_id,
			-l_cr_rec.amount,
			p_receipt_date,
			'UNAPP',
			-l_cr_acctd_amount_old,
			l_valid_gl_date,
			l_unapplied_ccid,
			l_ps_rec.payment_schedule_id,
			'60.3',
                        l_valid_gl_date,
                        l_ra_id_unapp);

    -- now create new UNID record for this receipt:

    arp_proc_rct_util.insert_ra_rec_cash(
		      p_cash_receipt_id,
		      l_cr_rec.amount,
		      p_receipt_date,
		      'UNID',
		      l_cr_acctd_amount_old,
		      l_valid_gl_date,
		      l_unidentified_ccid,
		      l_ps_rec.payment_schedule_id,
		      '60.4',
              '',
              l_ra_id_unid);

    -- 6924942 - Start
    update ar_receivable_applications
      set include_in_accumulation ='N'
    where cash_receipt_id = p_cash_receipt_id
    and   status = 'UNAPP';
    -- 6924942 - End

    --
    --Release 11.5 VAT changes, create UNID receivable application accounting
    --in ar_distributions
    --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_id_unid;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    --
    --Release 11.5 VAT changes, create paired UNAPP receivable application accounting
    --in ar_distributions
    --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_id_unapp;
    l_ae_doc_rec.source_id_old             := l_ra_id_unid;
    l_ae_doc_rec.other_flag                := 'PAIR';

  /* In this case as the receipt is unidentified, the third party id
     and sub id is from the cash receipt, so no need to pass these */
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    -- also don't forget to set the pay_from_customer column in
    -- ar_cash_receipts to NULL and the status to UNID.

    l_cr_rec.pay_from_customer := NULL;
    l_cr_rec.status := 'UNID';

    --
  ELSIF (l_cr_rec.pay_from_customer IS NOT NULL AND
         p_pay_from_customer IS NOT NULL) THEN
    --
    -- in this case the user has changed the customer; applications
    -- do not exist (otherwise the form would not have allowed the
    -- update).  So just update the pay_from_customer column.

    l_cr_rec.pay_from_customer := p_pay_from_customer;
    --
  END IF;

  -- -------------------------------------------------------------
  -- deal with amount changes
  -- -------------------------------------------------------------

  -- if the receipt status is APPROVED, we only update the amounts in
  -- ar_cash_receipts, ar_cash_receipt_history, and ar_payment_schedules,
  -- but not ar_receivable_applications, since this is being taken
  -- care of by the applications form and its server-side code:


  IF (l_crh_rec.status = 'APPROVED') THEN

    l_cr_rec.amount 			:= p_amount;
    l_crh_rec.amount 			:= p_amount;
    l_crh_rec.acctd_amount		:= l_cr_acctd_amount_new;
    l_ps_rec.amount_due_original	:= - p_amount;
    l_ps_rec.amount_due_remaining 	:= - p_amount;
    l_ps_rec.acctd_amount_due_remaining := - l_cr_acctd_amount_new;

    /* Bug fix 2964295
       The cash_receipt_history record needs to be updated for APPROVED receipts */
    arp_cr_history_pkg.update_p(l_crh_rec);

  ELSE  -- (l_crh_rec.status <> 'APPROVED')

    IF (l_cr_amount_changed_flag = TRUE or l_crh_fda_changed_flag = TRUE) THEN

      -- Update of the receipt payment schedule row and cr.amount is the same
      -- regardless of the posting status of the receipt so we will do the
      -- calculations now.

      -- ps.amount_due_remaining is defined as:

      -- ps.adr = - (unapplied amount + unid amount + on_account amount)
      -- of course, the unapplied amount should be null if there is an
      -- unidentified amount and vice versa.
      -- Thus an amount update means that we take the previous ps.adr
      -- and subtract (since adr is negative) the difference between
      -- the new receipt amount and the old receipt amount.

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'l_ps_rec.amount_due_remaining: ' || to_char(l_ps_rec.amount_due_remaining));
         arp_standard.debug('update_cash_receipt: ' || 'p_amount: ' || to_char(p_amount));
         arp_standard.debug('update_cash_receipt: ' || 'l_cr_rec.amount: ' || to_char(l_cr_rec.amount));
         arp_standard.debug('update_cash_receipt: ' || 'l_cr_acctd_amount_delta: ' || to_char(l_cr_acctd_amount_delta));
      END IF;

      l_ps_rec.amount_due_remaining             :=
                                l_ps_rec.amount_due_remaining -
                                (p_amount - l_cr_rec.amount) ;

      l_ps_rec.acctd_amount_due_remaining       :=
                                l_ps_rec.acctd_amount_due_remaining -
                                l_cr_acctd_amount_delta;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'l_ps_rec.amount_due_remaining: ' || to_char(l_ps_rec.amount_due_remaining));
         arp_standard.debug('update_cash_receipt: ' || 'l_ps_rec.acctd_amount_due_remaining: ' || to_char(l_ps_rec.acctd_amount_due_remaining));
      END IF;

      l_ps_rec.amount_due_original              := -p_amount;

      l_cr_rec.amount                           := p_amount;

      /* Bug 4294346 : In populating closed dates ,We should also consider the new RA
         records which will be created to account for Difference in Receipt Amount */
   /* arp_ps_util.populate_closed_dates( NULL, NULL, 'PMT', l_ps_rec ); */
      IF ( NVL(l_ps_rec.amount_due_remaining,0)= 0) THEN
        l_cr_rec.status := 'APP';
        l_ps_rec.status := 'CL';
      /* 28-MAY-1999 J Rautiainen
       * The status of unidentified receipts cannot be changed to unapp.
       * Bugfix for 894443 Start */
      ELSIF (l_cr_rec.pay_from_customer IS NULL AND
         p_pay_from_customer IS NULL) THEN
        l_cr_rec.status := 'UNID';
        l_ps_rec.status := 'OP';
      /* Bugfix for 894443 end */
      ELSE
        l_cr_rec.status := 'UNAPP';
        l_ps_rec.status := 'OP';
      END IF;


      IF (l_crh_rec_posted_flag = FALSE and l_crh_rec_gl_date_changed = FALSE ) THEN

        -- amount changes are fairly straight-forward if the current
        -- history record has not been posted yet and gl period is stil
        -- valid. We just update the cash receipt history record and
        -- distribution records.

        IF (l_crh_amount_new <> l_crh_rec.amount) THEN
 /* modified the parameter values passed for bug 2311742 */

          /* Bug fix 3677912 */
          /* The distribution record can be updated only if the current CRH record has
             one record in ARD corresponding to the l_source_type. Else we need to create one */
           BEGIN
            select 'Y'
            into   l_dist_row_on_current_crh
            from   ar_distributions dis
            where  dis.source_id = l_crh_rec.cash_receipt_history_id
            and    dis.source_table = 'CRH'
            and    dis.source_type = l_source_type;
          EXCEPTION
            WHEN no_data_found THEN
              l_dist_row_on_current_crh := 'N';
          END;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('update_cash_receipt: '||'l_dist_row_on_current_crh : '||l_dist_row_on_current_crh);
          END IF;
          IF l_dist_row_on_current_crh = 'Y' THEN
            arp_proc_rct_util.update_dist_rec(
			l_crh_rec.cash_receipt_history_id,
			l_source_type,
			l_crh_amount_new - l_crh_rec.amount,
			l_crh_acctd_amount_new - l_crh_rec.acctd_amount);
          ELSE
            IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('update_cash_receipt: ' || 'l_crh_amount_delta : ' || to_char(l_crh_amount_delta));
              arp_standard.debug('update_cash_receipt: ' || 'l_crh_acctd_amount_delta : ' || to_char(l_crh_acctd_amount_delta));
              arp_standard.debug('update_cash_receipt: ' || 'cash_receipt_history_id : ' || to_char(l_crh_rec.cash_receipt_history_id));
              arp_standard.debug('update_cash_receipt: ' || 'l_source_type : ' || l_source_type);
              arp_standard.debug('update_cash_receipt: ' || 'l_crh_ccid : ' || l_crh_ccid);
           END IF;

            arp_proc_rct_util.insert_dist_rec(l_crh_amount_delta,
                        l_crh_acctd_amount_delta,
                        l_crh_rec.cash_receipt_history_id,
                        l_source_type,
                        l_crh_ccid);
          END IF;

        END IF;

        -- Need to check the acctd fda flag.  The fda may not have
        -- changed but the acctd fda may have been altered implicitly
        -- as a result of a receipt amount change.

        IF (l_crh_fda_changed_flag = TRUE OR
            l_crh_acctd_fda_changed_flag = TRUE) THEN

          --
          -- Check to see if a Bank Charges distribution row
          -- already exists.
          --

          BEGIN
            /* Bug fix 3677912
               Bank charges record can be present for any CRH record */
             select 'Y'
             into   l_bank_charges_row_exists
             from dual
             where exists (select crh.cash_receipt_history_id
                           from ar_cash_receipt_history crh, ar_distributions dis
                            where crh.cash_receipt_id = l_crh_rec.cash_receipt_id
                              and   dis.source_id = crh.cash_receipt_history_id
                              and   dis.source_table  = 'CRH'
                              and   dis.source_type ='BANK_CHARGES');
          EXCEPTION
            WHEN no_data_found THEN
              l_bank_charges_row_exists := 'N';
          END;

          /* Bug fix 3677912
             Check if the Bank Charge distribution exists for the current CRH record
             If not, we have to create it */

          BEGIN
            select 'Y'
            into   l_bcharge_row_on_current_crh
            from   ar_distributions dis
            where  dis.source_id = l_crh_rec.cash_receipt_history_id
            and    dis.source_table = 'CRH'
            and    dis.source_type = 'BANK_CHARGES';
          EXCEPTION
            WHEN no_data_found THEN
              l_bcharge_row_on_current_crh := 'N';
          END;

          IF l_bank_charges_row_exists = 'Y' THEN

             --
             -- If bank charge record existed before, then we can go ahead and
             -- update this record.
             --
             -- Firstly, we need to calculate what the updated amount should be.
             -- To do this we need to check if there are any existing (posted)
             -- distribution amounts for BANK_CHARGES.
             --
             -- Consider the following example:
             -- Cash Receipt: 'A'
             --                Posted   Amount   FDA   Dist Source   Amt DR  Amt CR
             --    History 1:    Y      10000    2000  BANK_CAHRGES  2000
             --    History 2:    N      10000    1500  BANK_CHARGES          500
             --
             -- If the Bank Charges are modified from 1500 to 2500, the result should
             -- be a DR entry of 500 (Total DR of 1500) which will replace the CR entry
             -- of 500.
             --
             -- Resulting in:
             -- Cash Receipt: 'A'
             --                Posted   Amount   FDA   Dist Source   Amt DR  Amt CR
             --    History 1:    Y      10000    2000  BANK_CAHRGES  2000
             --    History 2:    N      10000    2500  BANK_CHARGES   500
             --
             -- It is not sufficient to use the Factor Discount Amount for the current
             -- Cash Receipt History row as this doesn't take into account any prior/posted
             -- FDA amounts.
             --

             select nvl(sum(dis.amount_dr),0),
                    nvl(sum(dis.amount_cr),0),
                    nvl(sum(dis.acctd_amount_dr),0),
                    nvl(sum(dis.acctd_amount_cr),0)
             into   l_sum_fda_debits,
                    l_sum_fda_credits,
                    l_sum_acctd_fda_debits,
                    l_sum_acctd_fda_credits
             from   ar_distributions dis
             where  dis.source_id in
                    (select crh.cash_receipt_history_id
                     from   ar_cash_receipt_history crh
                     where  crh.cash_receipt_id = p_cash_receipt_id ) /* Bug2855253 removed  and    crh.current_record_flag ='N' */

             and    dis.source_table = 'CRH'
             and    dis.source_type = 'BANK_CHARGES';

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('update_cash_receipt: ' || 'p_factor_discount_amount: ' || to_char(p_factor_discount_amount));
                arp_standard.debug('update_cash_receipt: ' || 'l_sum_fda_debits : ' || to_char(l_sum_fda_debits));
                arp_standard.debug('update_cash_receipt: ' || 'l_sum_fda_credits: ' || to_char(l_sum_fda_credits));
                arp_standard.debug('update_cash_receipt: ' || 'l_sum_acctd_fda_debits: ' || to_char(l_sum_acctd_fda_debits));
                arp_standard.debug('update_cash_receipt: ' || 'l_sum_acctd_fda_credits: ' || to_char(l_sum_acctd_fda_credits));
             END IF;

             -- Positive result will create a DR entry, negative a CR entry.

            /* Bug fix 3677912 */
            IF l_bcharge_row_on_current_crh = 'Y' THEN
               arp_proc_rct_util.update_dist_rec(
                        l_crh_rec.cash_receipt_history_id,
                        'BANK_CHARGES',
                        nvl(p_factor_discount_amount,0) - (l_sum_fda_debits - l_sum_fda_credits),
                        nvl(l_crh_acctd_fda_new,0) - (l_sum_acctd_fda_debits - l_sum_acctd_fda_credits) );
            ELSE
                arp_proc_rct_util.insert_dist_rec(
                   nvl(p_factor_discount_amount,0) - (l_sum_fda_debits - l_sum_fda_credits),
                   nvl(l_crh_acctd_fda_new,0) - (l_sum_acctd_fda_debits - l_sum_acctd_fda_credits),
                   l_crh_rec.cash_receipt_history_id,
                   'BANK_CHARGES',
                    l_bank_charges_ccid);
            END IF;

          ELSE          -- (NVL(l_crh_rec.factor_discount_amount,0) <= 0)

             --
             -- If no bank charge record existed before, we need to create one.
             --

             arp_proc_rct_util.insert_dist_rec(
                        p_factor_discount_amount,
                        l_crh_acctd_fda_new,
                        l_crh_rec.cash_receipt_history_id,
                        'BANK_CHARGES',
                        l_bank_charges_ccid);

          END IF;

        END IF;         -- (l_crh_fda_changed_flag = TRUE)

        -- now update amount columns in l_cr_rec

        l_crh_rec.amount 			:= l_crh_amount_new;
        l_crh_rec.acctd_amount  		:= l_crh_acctd_amount_new;
	l_crh_rec.factor_discount_amount	:= p_factor_discount_amount;
	l_crh_rec.acctd_factor_discount_amount  := l_crh_acctd_fda_new;

        -- populate the bank charge ccid only if there is a bank charge amount

	IF (l_crh_rec.factor_discount_amount IS NOT NULL) THEN
          l_crh_rec.bank_charge_account_ccid	:= l_bank_charges_ccid;
	ELSE
          l_crh_rec.bank_charge_account_ccid    := NULL;
        END IF;

        arp_cr_history_pkg.update_p(l_crh_rec);

      ELSE

	-- Current cash receipt history record was posted.
        -- Date of the receipt is no longer valid
	-- That means we need to create a new cash receipt history
        -- record and distribution records for it.

        -- make copy of cash receipt history record and null out/update
        -- columns that will be different in the new record.

        l_crh_rec_new := l_crh_rec;

	l_crh_rec_new.cash_receipt_history_id 	:= NULL;
	l_crh_rec_new.posting_control_id	:= -3;
	l_crh_rec_new.gl_posted_date		:= NULL;
        -- #511576  Set the gl date for the new record.
	l_crh_rec_new.gl_date		        := l_valid_gl_date;
	l_crh_rec_new.first_posted_record_flag	:= 'N';

	l_crh_rec_new.amount 			:= l_crh_amount_new;
	l_crh_rec_new.acctd_amount 		:= l_crh_acctd_amount_new;
	l_crh_rec_new.factor_discount_amount	:= p_factor_discount_amount;
	l_crh_rec_new.acctd_factor_discount_amount := l_crh_acctd_fda_new;

        arp_cr_history_pkg.insert_p(l_crh_rec_new, l_crh_id_new);

        l_crh_rec_new.cash_receipt_history_id := l_crh_id_new;

	-- modify the previously current cash receipt history record:

	l_crh_rec.current_record_flag		:= 'N';
	l_crh_rec.reversal_cash_receipt_hist_id := l_crh_id_new;
        -- #511576  Set the reversal gl date for the updated record.
	l_crh_rec.reversal_gl_date		:= l_valid_gl_date;
	l_crh_rec.reversal_created_from		:= 'ARRERG1B';

	arp_cr_history_pkg.update_p(l_crh_rec);

	-- from now on the new record is the current one:

        l_crh_rec := l_crh_rec_new;

        -- create new distributions for the new record.  These
	-- distribution records are for the difference between the
	-- amounts and factor_discount_amounts in the old and new
	-- cash_receipt_history records.

        IF (l_crh_amount_delta <> 0) THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('update_cash_receipt: ' || 'l_crh_amount_delta : ' || to_char(l_crh_amount_delta));
             arp_standard.debug('update_cash_receipt: ' || 'l_crh_acctd_amount_delta : ' || to_char(l_crh_acctd_amount_delta));
             arp_standard.debug('update_cash_receipt: ' || 'cash_receipt_history_id : ' || to_char(l_crh_rec.cash_receipt_history_id));
             arp_standard.debug('update_cash_receipt: ' || 'l_source_type : ' || l_source_type);
             arp_standard.debug('update_cash_receipt: ' || 'l_crh_ccid : ' || l_crh_ccid);
          END IF;

  	  arp_proc_rct_util.insert_dist_rec(l_crh_amount_delta,
			l_crh_acctd_amount_delta,
			l_crh_rec.cash_receipt_history_id,
			l_source_type,
			l_crh_ccid);
        END IF;

        -- Need to check the acctd fda change also.  The fda may not have
        -- changed but the acctd fda may have been altered implicitly
        -- as a result of a receipt amount change.

        IF (l_crh_fda_delta <> 0 OR
            l_crh_acctd_fda_delta <> 0) THEN

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('update_cash_receipt: ' || 'l_crh_fda_delta : ' || to_char(l_crh_fda_delta));
	    arp_standard.debug('update_cash_receipt: ' || 'l_crh_acctd_fda_delta : ' || to_char(l_crh_acctd_fda_delta));
            arp_standard.debug('update_cash_receipt: ' || 'cash_receipt_history_id : ' || to_char(l_crh_rec.cash_receipt_history_id));
             arp_standard.debug('update_cash_receipt: ' || 'l_crh_ccid : ' || l_bank_charges_ccid);
          END IF;

          arp_proc_rct_util.insert_dist_rec(
			l_crh_fda_delta,
			l_crh_acctd_fda_delta,
			l_crh_rec.cash_receipt_history_id,
			'BANK_CHARGES',
			l_bank_charges_ccid);
        END IF;

      END IF;

      -- now create receivable applications record to account for
      -- the difference in the receipt amount:

      IF (l_cr_rec.pay_from_customer IS NULL) THEN

 	-- receipt is unidentified; create UNID record in
	-- AR_RECEIVABLE_APPLICATIONS

	arp_proc_rct_util.insert_ra_rec_cash(
			p_cash_receipt_id,
			l_cr_amount_delta,
			p_receipt_date,
			'UNID',
			l_cr_acctd_amount_delta,
			l_valid_gl_date,
			l_unidentified_ccid,
			l_ps_rec.payment_schedule_id,
			'60.4',
                        '',
                        l_ra_id_unid);

          /*mrc trigger elimination project*/
           ar_mrc_engine3.update_ra_rec_cash_diff(
                        p_rec_app_id           => l_ra_id_unid,
                        p_cash_receipt_id      => p_cash_receipt_id,
                        p_diff_amount          => l_cr_amount_delta,
                        p_old_rcpt_amount      => l_cr_rec.amount,
                        p_payment_schedule_id  =>l_ps_rec.payment_schedule_id
                        );

     --
     --Release 11.5 VAT changes, create UNID receivable application accounting
     --in ar_distributions
     --
       l_ae_doc_rec.document_type             := 'RECEIPT';
       l_ae_doc_rec.document_id               := p_cash_receipt_id;
       l_ae_doc_rec.accounting_entity_level   := 'ONE';
       l_ae_doc_rec.source_table              := 'RA';
       l_ae_doc_rec.source_id                 := l_ra_id_unid;
       l_ae_doc_rec.source_id_old             := '';
       l_ae_doc_rec.other_flag                := '';
       arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

      ELSE

 	-- receipt is identified; create UNAPP record in
	-- AR_RECEIVABLE_APPLICATIONS

	arp_proc_rct_util.insert_ra_rec_cash(
			p_cash_receipt_id,
			l_cr_amount_delta,
			p_receipt_date,
			'UNAPP',
			l_cr_acctd_amount_delta,
			l_valid_gl_date,
			l_unapplied_ccid,
			l_ps_rec.payment_schedule_id,
			'60.2',
            '',
            l_ra_id_unapp);

     -- 6924942 - Start
     update ar_receivable_applications
      set include_in_accumulation ='N'
     where cash_receipt_id = p_cash_receipt_id
     and   status = 'UNAPP';
     -- 6924942 - End

     --
     --Release 11.5 VAT changes, create UNAPP receivable application accounting
     --in ar_distributions
     --
       l_ae_doc_rec.document_type             := 'RECEIPT';
       l_ae_doc_rec.document_id               := p_cash_receipt_id;
       l_ae_doc_rec.accounting_entity_level   := 'ONE';
       l_ae_doc_rec.source_table              := 'RA';
       l_ae_doc_rec.source_id                 := l_ra_id_unapp;
       l_ae_doc_rec.source_id_old             := '';
       l_ae_doc_rec.other_flag                := '';

  /* We need to set the third party id and sub id as the cash receipt
     is updated later */
       l_ae_doc_rec.miscel5                   := p_pay_from_customer;
       l_ae_doc_rec.miscel6                   := p_customer_site_use_id;
       arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

      END IF;

     arp_ps_util.populate_closed_dates( NULL, NULL, 'PMT', l_ps_rec ); /* Bug 4294346 */

    END IF;

  END IF;

  -- -------------------------------------------------------------
  -- Now update columns that don't require any special logic
  -- -------------------------------------------------------------

  -- update the 'easy stuff':

  l_cr_rec.customer_bank_branch_id := p_customer_bank_branch_id;
  l_cr_rec.anticipated_clearing_date := p_anticipated_clearing_date;
  l_cr_rec.receipt_number := p_receipt_number;
  l_cr_rec.doc_sequence_value := p_doc_sequence_value;
  l_cr_rec.doc_sequence_id := p_doc_sequence_id;
  l_cr_rec.customer_site_use_id := p_customer_site_use_id;
  l_cr_rec.customer_receipt_reference := p_customer_receipt_reference;
  l_cr_rec.customer_bank_account_id := p_customer_bank_account_id;
  l_cr_rec.comments := nvl(p_comments,l_cr_rec.comments);
  l_cr_rec.attribute1 := p_attribute1;
  l_cr_rec.attribute2 := p_attribute2;
  l_cr_rec.attribute3 := p_attribute3;
  l_cr_rec.attribute4 := p_attribute4;
  l_cr_rec.attribute5 := p_attribute5;
  l_cr_rec.attribute6 := p_attribute6;
  l_cr_rec.attribute7 := p_attribute7;
  l_cr_rec.attribute8 := p_attribute8;
  l_cr_rec.attribute9 := p_attribute9;
  l_cr_rec.attribute10 := p_attribute10;
  l_cr_rec.attribute11 := p_attribute11;
  l_cr_rec.attribute12 := p_attribute12;
  l_cr_rec.attribute13 := p_attribute13;
  l_cr_rec.attribute14 := p_attribute14;
  l_cr_rec.attribute15 := p_attribute15;
  l_cr_rec.attribute_category := p_attribute_category;
  l_cr_rec.ussgl_transaction_code := p_ussgl_transaction_code;
  l_cr_rec.override_remit_account_flag := p_override_remit_account_flag;
  l_cr_rec.deposit_date	:= p_deposit_date;
  l_cr_rec.remit_bank_acct_use_id := p_remittance_bank_account_id;
  l_cr_rec.vat_tax_id	:= p_vat_tax_id;

  l_cr_rec.global_attribute1	:= p_global_attribute1;
  l_cr_rec.global_attribute2	:= p_global_attribute2;
  l_cr_rec.global_attribute3	:= p_global_attribute3;
  l_cr_rec.global_attribute4	:= p_global_attribute4;
  l_cr_rec.global_attribute5	:= p_global_attribute5;
  l_cr_rec.global_attribute6	:= p_global_attribute6;
  l_cr_rec.global_attribute7	:= p_global_attribute7;
  l_cr_rec.global_attribute8	:= p_global_attribute8;
  l_cr_rec.global_attribute9	:= p_global_attribute9;
  l_cr_rec.global_attribute10	:= p_global_attribute10;
  l_cr_rec.global_attribute11	:= p_global_attribute11;
  l_cr_rec.global_attribute12	:= p_global_attribute12;
  l_cr_rec.global_attribute13	:= p_global_attribute13;
  l_cr_rec.global_attribute14	:= p_global_attribute14;
  l_cr_rec.global_attribute15	:= p_global_attribute15;
  l_cr_rec.global_attribute16	:= p_global_attribute16;
  l_cr_rec.global_attribute17	:= p_global_attribute17;
  l_cr_rec.global_attribute18	:= p_global_attribute18;
  l_cr_rec.global_attribute19	:= p_global_attribute19;
  l_cr_rec.global_attribute20	:= p_global_attribute20;
  l_cr_rec.global_attribute_category	:= p_global_attribute_category;

  l_cr_rec.issuer_name           := p_issuer_name;
  l_cr_rec.issue_date            := p_issue_date;
  l_cr_rec.issuer_bank_branch_id := p_issuer_bank_branch_id;

  -- Credit Card changes.

  l_cr_rec.payment_server_order_num := p_payment_server_order_num;
  l_cr_rec.approval_code            := p_approval_code;

  -- ARTA Changes
  l_cr_rec.postmark_date        := p_postmark_date;

  -- Enhancement 2074220
  l_cr_rec.application_notes   := p_application_notes;

  -- LE
  l_cr_rec.legal_entity_id := p_legal_entity_id;
  -- PAYMENT_UPTAKE
  l_cr_rec.payment_trxn_extension_id := p_payment_trxn_extension_id;
  l_cr_rec.automatch_set_id             := p_automatch_set_id; /* ER Automatch Application */
  l_cr_rec.autoapply_flag               := p_autoapply_flag;



  IF (l_crh_rec.status = 'APPROVED' AND
      p_status = 'CONFIRMED') THEN
    l_cr_rec.confirmed_flag := 'Y';
  ELSIF (l_crh_rec.status = 'CONFIRMED' AND
      p_status = 'APPROVED') THEN
    l_cr_rec.confirmed_flag := 'N';
  END IF;

  -- update payment schedule customer columns:

  l_ps_rec.customer_id := p_pay_from_customer;
  l_ps_rec.customer_site_use_id := p_customer_site_use_id;

  -- set payment schedule due date

  l_ps_rec.due_date := NVL(p_maturity_date, p_deposit_date);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Before Inserting CR/CRH record in update_cash_receipt.');
  END IF;

--{BUG#4353362
OPEN cu_current_customer;
FETCH cu_current_customer INTO l_current_customer_id, l_current_csu_id;
IF cu_current_customer%FOUND THEN
arp_acct_event_pkg.update_cr_dist
( p_ledger_id                 => arp_global.set_of_books_id
 ,p_source_id_int_1           => p_cash_receipt_id
 ,p_third_party_merge_date    => l_valid_gl_date
 ,p_original_third_party_id   => l_current_customer_id
 ,p_original_site_id          => l_current_csu_id
 ,p_new_third_party_id        => p_pay_from_customer
 ,p_new_site_id               => p_customer_site_use_id
 ,p_create_update             => 'U'
 ,p_entity_code               => 'RECEIPTS'
 ,p_type_of_third_party_merge => 'PARTIAL'
 ,p_mapping_flag              => 'N'
 ,p_execution_mode            => 'SYNC'
 ,p_accounting_mode           => 'F'
 ,p_transfer_to_gl_flag       => 'Y'
 ,p_post_in_gl_flag           => 'Y'
 ,p_third_party_type          => 'C'
 ,x_errbuf                    => x_errbuf
 ,x_retcode                   => x_retcode
 ,x_event_ids                 => x_event_ids
 ,x_request_id                => x_request_id);
END IF;
CLOSE cu_current_customer;
--}


  -- update actual receipt record:

  arp_cash_receipts_pkg.update_p(l_cr_rec);

/*
  -- update the history record:

  -- this should've happened earlier if the amount changed.

  arp_cr_history_pkg.update_p(l_crh_rec);

*/

  -- update payment schedule record:

  arp_ps_pkg.update_p(l_ps_rec);

  --apandit
  --Bug 2641517 creating a history record for the modification
  --and raising the business event.
  IF (l_cr_amount_changed_flag) OR
     (l_crh_fda_changed_flag) OR
     (l_rct_identified_flag) OR
     (l_rct_unidentified_flag) OR
     (l_rct_site_changed_flag) OR
     (l_rct_customer_changed_flag)
    THEN
   --Insert the history record
   AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                            l_history_id,
                                            'PMT',
                                            'MODIFY_PMT');

   --Raise the business event
   AR_BUS_EVENT_COVER.Raise_Rcpt_Modify_Event(l_ps_rec.cash_receipt_id,
                                        l_ps_rec.payment_schedule_id,
                                        l_history_id);
  END IF;

  -- check if receipt has been confirmed:

  IF (l_crh_rec.status = 'APPROVED' AND
      p_status = 'CONFIRMED') THEN

    arp_confirmation.confirm(
		p_cash_receipt_id,
		p_confirm_gl_date,
		p_confirm_date,
		p_form_name,
		p_form_version);

  ELSIF (l_crh_rec.status = 'CONFIRMED' AND
      p_status = 'APPROVED') THEN

    arp_confirmation.unconfirm(
		p_cash_receipt_id,
		p_unconfirm_gl_date,
		SYSDATE,
		p_form_name,
		p_form_version);

  END IF;

  IF (p_reversal_date IS NOT NULL AND
      l_cr_rec.reversal_date IS NULL) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('update_cash_receipt: ' || 'Receipt needs to be reversed.');
    END IF;
    IF (p_dm_reversal_flag = 'Y') THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'Debit memo reversal required');
      END IF;

      arp_reverse_receipt.debit_memo_reversal(
		l_cr_rec,
		p_cc_id,
		p_dm_cust_trx_type_id,
		p_dm_cust_trx_type,
		p_reversal_gl_date,
		p_reversal_date,
		p_reversal_category,
		p_reversal_reason_code,
                p_reversal_comments,
                p_attribute_category, p_attribute1,
                p_attribute2, p_attribute3, p_attribute4,
                p_attribute5, p_attribute6, p_attribute7,
                p_attribute8, p_attribute9, p_attribute10,
                p_attribute11, p_attribute12, p_attribute13,
                p_attribute14, p_attribute15,
		p_dm_number,
		p_dm_doc_sequence_value,
		p_dm_doc_sequence_id,
		p_tw_status,
		p_form_name,
		p_form_version);
       --apandit
       --Bug 2641517 Insert the history record and raising
       --the business event
       AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                                l_history_id,
                                                'PMT',
                                                'DM_REVERSE_PMT');

       --Raise the business event

       AR_BUS_EVENT_COVER.Raise_Rcpt_DMReverse_Event(l_ps_rec.cash_receipt_id,
                                             l_ps_rec.payment_schedule_id,
                                             l_history_id);
    ELSE
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('update_cash_receipt: ' || 'Regular reversal required');
      END IF;

      -- Bug 2946734 - update all claims on this receipt
      arp_reverse_receipt.cancel_claims(
                 p_cr_id               => l_cr_rec.cash_receipt_id
               , p_include_trx_claims  => 'Y'
               , x_return_status       => l_return_status
               , x_msg_count           => l_msg_count
               , x_msg_data            => l_msg_data);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         APP_EXCEPTION.raise_exception;
      END IF;

      arp_reverse_receipt.reverse(
		l_cr_rec.cash_receipt_id,
		p_reversal_category,
		p_reversal_gl_date,
		p_reversal_date,
		p_reversal_reason_code,
		p_reversal_comments,
		NULL,			-- clear_batch_id
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
		p_attribute11,
		p_attribute12,
		p_attribute13,
		p_attribute14,
		p_attribute15,
		p_form_name,
		p_form_version,
		l_rev_crh_id);

   --apandit
   --Bug 2641517 Insert the history record and raising
   --the business event
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('update_cash_receipt: ' || 'before creating the history rec for BusinessEvent');
   END IF;
   AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                            l_history_id,
                                            'PMT',
                                            'REVERSE_PMT');

   --Raise the business event
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('update_cash_receipt: ' || 'before raising the new business event');
   END IF;
   AR_BUS_EVENT_COVER.Raise_Rcpt_Reverse_Event(l_ps_rec.cash_receipt_id,
                                        l_ps_rec.payment_schedule_id,
                                        l_history_id);
    END IF;

  END IF;

  -- check if receipt needs to be rate-adjusted:

  IF (p_rate_adjust_gl_date IS NOT NULL) THEN
    arp_proc_rct_util.rate_adjust(
		p_cash_receipt_id,
		p_rate_adjust_gl_date,
		p_new_exchange_date,
		p_new_exchange_rate,
		p_new_exchange_rate_type,
		l_cr_rec.exchange_date,
		l_cr_rec.exchange_rate,
		l_cr_rec.exchange_rate_type,
		p_gain_loss,
		p_exchange_rate_attr_cat,
 		p_exchange_rate_attr1,
 		p_exchange_rate_attr2,
 		p_exchange_rate_attr3,
 		p_exchange_rate_attr4,
 		p_exchange_rate_attr5,
 		p_exchange_rate_attr6,
 		p_exchange_rate_attr7,
 		p_exchange_rate_attr8,
 		p_exchange_rate_attr9,
 		p_exchange_rate_attr10,
 		p_exchange_rate_attr11,
		p_exchange_rate_attr12,
 		p_exchange_rate_attr13,
 		p_exchange_rate_attr14,
 		p_exchange_rate_attr15);
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.update_cash_receipt()+');
  END IF;


    /* Bug8422361 - Code Changes - Start.
       Added logic to assign the bank account present on an unidentified
       receipt created via lockbox to the customer once the receipt is
       identified from the Receipt UI. This functionality is restored
       back from 11i to R12, which is lost due to Payment Uptake.
    */
    IF p_pay_from_customer IS NOT NULL AND
       p_customer_bank_account_id IS NOT NULL AND
       l_rct_identified_flag = TRUE
    THEN

        SELECT PARTY_ID INTO l_party_id
        FROM   HZ_CUST_ACCOUNTS
        WHERE  CUST_ACCOUNT_ID = p_pay_from_customer;

        SELECT COUNT(*) INTO l_no_of_accounts
        FROM   IBY_FNDCPT_PAYER_ASSGN_INSTR_V
        WHERE  CUST_ACCOUNT_ID    =    p_pay_from_customer
        AND    INSTRUMENT_ID      =    p_customer_bank_account_id;

	IF PG_DEBUG in ('Y', 'C') THEN
	    ARP_STANDARD.DEBUG('p_pay_from_customer :- ' || p_pay_from_customer );
	    ARP_STANDARD.DEBUG('p_customer_bank_account_id :- ' || p_customer_bank_account_id );
	    ARP_STANDARD.DEBUG('l_no_of_accounts :- ' || l_no_of_accounts );
	    ARP_STANDARD.DEBUG('l_party_id :- ' || l_party_id );
        END IF;

	IF l_no_of_accounts = 0 THEN
	    SELECT COUNT(*) INTO l_no_of_other_accounts
            FROM   IBY_FNDCPT_PAYER_ASSGN_INSTR_V
            WHERE  NVL(CUST_ACCOUNT_ID, -99) <> p_pay_from_customer
            AND    INSTRUMENT_ID      =    p_customer_bank_account_id;

	    IF PG_DEBUG in ('Y', 'C') THEN
                ARP_STANDARD.DEBUG('l_no_of_other_accounts :- ' || l_no_of_other_accounts );
            END IF;

	    IF l_no_of_other_accounts = 0 THEN
		l_bank_assign_flag := TRUE;
	    ELSE
	        SELECT COUNT(*) INTO l_no_of_other_party_accounts
                FROM   IBY_FNDCPT_PAYER_ASSGN_INSTR_V
		WHERE  PARTY_ID           <>   l_party_id
                AND    INSTRUMENT_ID      =    p_customer_bank_account_id;

                IF PG_DEBUG in ('Y', 'C') THEN
                    ARP_STANDARD.DEBUG('l_no_of_other_party_accounts :- ' || l_no_of_other_party_accounts );
                END IF;

		IF l_no_of_other_party_accounts = 0 THEN
		    l_bank_assign_flag := TRUE;
		ELSE

		    UPDATE AR_CASH_RECEIPTS SET
                        CUSTOMER_BANK_ACCOUNT_ID = NULL,
			APPLICATION_NOTES = (SELECT DISTINCT 'Removed Bank Account: '||BANK_NAME||'-'||ACCOUNT_NUMBER||
                                                             ' from this receipt.'
                                             FROM IBY_FNDCPT_PAYER_ASSGN_INSTR_V
					     WHERE INSTRUMENT_ID = p_customer_bank_account_id)
		    WHERE CASH_RECEIPT_ID = p_cash_receipt_id;

		END IF;
	    END IF;
	END IF;

        IF l_bank_assign_flag = TRUE THEN

	    IBY_EXT_BANKACCT_PUB.ADD_JOINT_ACCOUNT_OWNER(
                p_api_version          =>  l_api_version,
                p_init_msg_list        =>  l_init_msg_list,
                p_bank_account_id      =>  p_customer_bank_account_id,
                p_acct_owner_party_id  =>  l_party_id,
                x_joint_acct_owner_id  =>  l_joint_acct_owner_id,
                x_return_status        =>  l_iby_return_status,
                x_msg_count            =>  l_msg_count,
                x_msg_data             =>  l_msg_data,
                x_response             =>  l_response_rec );

	    IF PG_DEBUG in ('Y', 'C') THEN
	        ARP_STANDARD.DEBUG('IBY_EXT_BANKACCT_PUB.ADD_JOINT_ACCOUNT_OWNER: Return Status :- ' || l_iby_return_status);
	    END IF;

            IF l_iby_return_status  = fnd_api.g_ret_sts_error OR
               l_iby_return_status  = fnd_api.g_ret_sts_unexp_error THEN

                ARP_STANDARD.DEBUG('Errors Reported By IBY Add Joint Account Owner API :-');

                FOR i in 1..l_msg_count LOOP
                    FND_MSG_PUB.GET(fnd_msg_pub.g_first, fnd_api.g_false, l_msg_data, l_msg_count);
                    ARP_STANDARD.DEBUG(l_msg_data);
	        END LOOP;

	    ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
                    ARP_STANDARD.DEBUG('Joint Account Owner Id :- ' || l_joint_acct_owner_id );
		END IF;
	    END IF;

	    ARP_EXT_BANK_PKG.INSERT_ACCT_INSTR_ASSIGNMENT(
		p_party_id        =>  l_party_id,
		p_customer_id     =>  p_pay_from_customer,
		p_instr_id        =>  p_customer_bank_account_id,
		x_instr_assign_id =>  l_instr_assign_id,
		x_return_status   =>  l_iby_return_status );

	    IF PG_DEBUG in ('Y', 'C') THEN
		ARP_STANDARD.DEBUG('Instrument Assignment: l_instr_assign_id :- '||l_instr_assign_id);
		ARP_STANDARD.DEBUG('Instrument Assignment: l_iby_return_status :- '||l_iby_return_status);
	    END IF;

        END IF;
    END IF;
    /* Bug8422361 - Code Changes - End. */


  -- determine receipt's new state and status and return it to form:

  -- Bug no 968913 SRAJASEK   Modified the sql statement to retrieve the data
  -- from the base tables rather than the ar_cash_receipt_v view for
  -- performance reasons

  SELECT cr.status,
	 l_cr_status.meaning,
	 crh_current.status ,
	 l_crh_status.meaning
  INTO   p_new_status,
	 p_new_status_dsp,
	 p_new_state,
	 p_new_state_dsp
  FROM
        ar_cash_receipt_history crh_current,
        ar_cash_receipts        cr,
        ar_lookups              l_cr_status,
        ar_lookups              l_crh_status
  WHERE
        cr.cash_receipt_id = p_cash_receipt_id
  AND   l_cr_status.lookup_type = 'CHECK_STATUS'
  AND   l_cr_status.lookup_code = cr.status
  AND   l_crh_status.lookup_type = 'RECEIPT_CREATION_STATUS'
  AND   l_crh_status.lookup_code = crh_current.status
  AND   crh_current.cash_receipt_id     = cr.cash_receipt_id
  AND   crh_current.current_record_flag = 'Y';

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Exception in arp_process_receipts.update_cash_receipts');
         arp_standard.debug('update_cash_receipt: ' || 'p_cash_receipt_id =		'|| to_char(p_cash_receipt_id));
         arp_standard.debug('update_cash_receipt: ' || 'p_amount =			'|| to_char(p_amount));
         arp_standard.debug('update_cash_receipt: ' || 'p_factor_discount_amount =	'|| to_char(p_factor_discount_amount));
      END IF;
      RAISE;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_rct_util.update_cash_receipts()-');
  END IF;

END update_cash_receipt;

END ARP_PROC_RECEIPTS1;

/
