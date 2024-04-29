--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_HEADER_POST_COMMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_HEADER_POST_COMMIT" AS
/* $Header: ARTEHPCB.pls 120.13.12010000.2 2009/12/07 21:09:15 mraymond ship $ */

pg_base_precision            fnd_currencies.precision%type;
pg_base_min_acc_unit         fnd_currencies.minimum_accountable_unit%type;
pg_trx_header_level_rounding ar_system_parameters.trx_header_level_rounding%type;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    post_commit                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Performs logic that must occur after all of the other logic for the    |
 |    insertion or update of a transaction has occurred.                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_maintain_ps.maintain_payment_schedules                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      28-AUG-95  Charlie Tomberg     Created                               |
 |      19-FEB-96  Oliver Steinmeier   Changed logic in post-commit to       |
 |                                     make sure the payment schedule        |
 |                                     gets called for debit memos           |
 |	05-05-97  OSTEINME	       Changed post_commit logic to recreate |
 |				       payment schedules if the exchange     |
 |				       rate, exchange date, or exchange type |
 |				       was changed (bug 486369)  	     |
 |      08-26-97   D. Jancis           Changed post commit logic to recreate |
 |                                     payment schedules if the bill to      |
 |                                     customer or the bill to address was   |
 |                                     changed (Bug 520221 )                 |
 |      10-14-97   D. Jancis           Changed post commit logic to          |
 |                                     recreate payment schedules if the     |
 |                                     GL-Date or transaction type           |
 |                                     was changed (Bug 564308 and 562342)   |
 |      11-14-97   D. Jancis           Added code to retrieve necessary      |
 |                                     values to call the arpt_sql_func_util.|
 |                                     get_activity_flag routine.  If for    |
 |                                     some reason, the flag to recreate the |
 |                                     payment schedule is Y and there is    |
 |                                     activity against the trans., an error |
 |                                     is raised.  bug 586371                |
 |      11-19-97  Sai Rangarajan       Bug Fix 586968 - Changed logic to     |
 |                                     to check for recreation of payment    |
 |                                     schedules until after the             |
 |                                     gl_line_dist records are updated.     |
 |                                     also moved code written for bug 586371|
 |      12-17-97  D. Jancis            Bug Fix 598442 - changed logic to     |
 |                                     check for differences in exchange     |
 |                                     with the posibility of a value being  |
 |                                     NULL. also added addition check       |
 |                                     to see if there is activity against   |
 |                                     trans do not 'delete/recreate' ps     |
 |      03-23-98  Tasman Tang          Bug Fix 643716 - passed               |
 |                                     p_previous_customer_trx_id instead of |
 |                                     l_previous_customer_trx_id in first   |
 |                                     call to get_activity_flag since the   |
 |                                     local var is never initialized        |
 |      28-Sep-01 Pravin Pawar         Bug NO :1915785 - Added the message   |
 |                                     'AR_PLCRE_FHLR_CCID' , to prompt the  |
 |                                     user to  enable the Header Level      |
 |                                     Rounding Account                      |
 |      01-FEB-02 M Raymond            Bug 2164863 - added a parameter
 |                                     to do_completion_checking routine and
 |                                     added a second call to that routine
 |                                     after the rounding was completed.
 |                                     Also substituted arp_trx_complete_chk
 |                                     for arp_trx_validate.
 |      02-DEC-04 V Crisostomo         Bug3049044/3041195: Changed
 |                                     arp_trx_validate.check_sign_and_overapp
 |                                     to take p_error_mode and p_error_count
 |                                     to allow for better error handling.
 +===========================================================================*/
PROCEDURE post_commit( p_form_name                    IN varchar2,
                       p_form_version                 IN number,
                       p_customer_trx_id              IN
                                      ra_customer_trx.customer_trx_id%type,
                       p_previous_customer_trx_id     IN
                               ra_customer_trx.previous_customer_trx_id%type,
                       p_complete_flag                IN
                               ra_customer_trx.complete_flag%type,
                       p_trx_open_receivables_flag    IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                       p_prev_open_receivables_flag   IN
                                 ra_cust_trx_types.accounting_affect_flag%type,
                       p_creation_sign                IN
                                 ra_cust_trx_types.creation_sign%type,
                       p_allow_overapplication_flag   IN
                             ra_cust_trx_types.allow_overapplication_flag%type,
                       p_natural_application_flag     IN
                          ra_cust_trx_types.natural_application_only_flag%type,
                       p_cash_receipt_id              IN
                          ar_cash_receipts.cash_receipt_id%type DEFAULT NULL,
                       p_error_mode                   IN VARCHAR2
                     ) IS

   l_scredit_count            NUMBER;
   l_dist_count               NUMBER;
   l_error_count              NUMBER;
   l_error_message            VARCHAR2(128);

   l_open_receivables_flag       ra_cust_trx_types.accounting_affect_flag%type;
   l_true_open_receivables_flag  ra_cust_trx_types.accounting_affect_flag%type;
   l_old_complete_flag           VARCHAR2(1);
   l_recreate_ps_flag            VARCHAR2(1);
   l_applied_commitment_amt      NUMBER;

    /* added for Bug 586371 */

   l_activity_flag               VARCHAR2(1);
   l_previous_customer_trx_id    NUMBER(15);
   l_initial_customer_trx_id     NUMBER(15);
   l_type                        VARCHAR(20);
   l_called_from_api             VARCHAR2(1);

  /*added for the bug 2641517 */
   l_term_changed_flag           VARCHAR2(1);
   l_trx_sum_hist_rec            AR_TRX_SUMMARY_HIST%rowtype;
   l_history_id                  NUMBER;
   CURSOR get_existing_ps (p_cust_trx_id IN NUMBER) IS
   SELECT customer_trx_id,
          payment_schedule_id,
          invoice_currency_code,
          due_date,
          amount_in_dispute,
          amount_due_original,
          amount_due_remaining,
          amount_adjusted,
          customer_id,
          customer_site_use_id,
          trx_date,
          amount_credited,
          status
   FROM   ar_payment_schedules
   WHERE  customer_trx_id = p_cust_trx_id;
  l_counter  NUMBER := 0;
  l_amt_credited  NUMBER;
  l_stat    VARCHAR2(10);

l_prev_cust_old_state AR_BUS_EVENT_COVER.prev_cust_old_state_tab;

/*3463885*/
 l_ps_rev_cash_id               NUMBER;
 l_ct_rev_cash_id               NUMBER;
begin

   arp_util.print_fcn_label( 'arp_process_header.post_commit()+ ');

  /*-----------------------------------------------------------------+
   |  check form version to determine if it is compatible with the   |
   |  entity handler.                                                |
   +-----------------------------------------------------------------*/

   arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);


  /*---------------------------------------------------------+
   |  Derive flags for maintain payment schedule procedure   |
   +---------------------------------------------------------*/

 /*----------------------------------------------------------------------------------+
  | Bug Fix 586968 - srangara --  Removing check for re-creation of payment schedules|
  | so that it is done after the gl_line_dist records are created                    |
  | Also moved logic for bug 586371 so that activity_flag is deduced                 |
  | after l_recreate_ps_flag is found out.                                           |
  +----------------------------------------------------------------------------------*/

   /*3463885 Added two cols reversed_cash_receipt_id to be selected*/
   SELECT DECODE(
                  ctt.accounting_affect_flag,
                  'Y', 'Y',
                       DECODE(
                                COUNT(ps.payment_schedule_id),
                                0, 'N',
                                   'Y'
                             )
                ),                             -- Open Receivables Flag
          DECODE(
                  ctt.accounting_affect_flag,
                  'Y', DECODE(
                                 COUNT(ps.payment_schedule_id),
                                       0, 'N',
                                          'Y'
                              ),
                       'N' -- 9177128: was NULL
                ),
          ctt.accounting_affect_flag,
	  ps.reversed_cash_receipt_id,
	  ct.reversed_cash_receipt_id
   INTO      l_open_receivables_flag,
             l_old_complete_flag,
             l_true_open_receivables_flag,
	     l_ps_rev_cash_id,
	     l_ct_rev_cash_id
   FROM      ar_payment_schedules      ps,
             ra_cust_trx_types         ctt,
             ra_cust_trx_line_gl_dist  lgd,
             ra_customer_trx           ct
   WHERE     ct.customer_trx_id   = ps.customer_trx_id(+)
   AND       ct.cust_trx_type_id  = ctt.cust_trx_type_id
   AND       ct.customer_trx_id   = lgd.customer_trx_id
   AND       lgd.account_class    = 'REC'
   AND       lgd.latest_rec_flag  = 'Y'
   AND       ct.customer_trx_id   = p_customer_trx_id
   GROUP BY  ctt.accounting_affect_flag,
             ct.complete_flag,
             ct.term_id,
             ct.invoice_currency_code,
             lgd.amount,
	     ct.exchange_rate,
	     ct.exchange_date,
	     ct.exchange_rate_type,
             ct.bill_to_customer_id,
             ct.bill_to_site_use_id,
             lgd.gl_date,
             ct.cust_trx_type_id,
	     ps.reversed_cash_receipt_id,
	     ct.reversed_cash_receipt_id;

   arp_util.debug('Open Receivables Flag    = ' || l_open_receivables_flag);
   arp_util.debug('Complete Flag Old Value  = ' || l_old_complete_flag);
   arp_util.debug('Complete Flag New Value  = ' || p_complete_flag);

   -- code enclosed in IF clause is NOT necessary when calling program is ARPBFBIB
   if p_form_name <> 'ARPBFBIB' then

  /*----------------------------------------------------------------------+
   |  Ensure that the transaction can be completed if it is now complete  |
   |  but previously was incomplete. This is necessary because something  |
   |  could have changed since the completion check was done in the form  |
   |  to make it incorrect to complete the transaction.                   |
   +----------------------------------------------------------------------*/

   IF    (
              P_complete_flag     = 'Y'
          AND
              l_old_complete_flag = 'N'
         )
   THEN

     /* Bug 2164863 - Do not execute tax and accounting validation
          at this point.  We will recall this procedure after
          rounding has occurred for those tests */

         arp_trx_complete_chk.do_completion_checking(
                                            p_customer_trx_id,
                                            NULL,
                                            NULL,
                                            p_error_mode,
                                            l_error_count,
                                            'N'
                                          );

         IF (l_error_count > 0)
         THEN
               app_exception.raise_exception;
         END IF;

    END IF;

  /*-------------------------------------------------------+
   |  Correct rounding errors in the salescredit records.  |
   +-------------------------------------------------------*/

   /*3463885*/
   IF l_ps_rev_cash_id is not null and l_ct_rev_cash_id is null THEN
       UPDATE RA_CUSTOMER_TRX SET REVERSED_CASH_RECEIPT_ID = l_ps_rev_cash_id
       WHERE  CUSTOMER_TRX_ID = p_customer_trx_id;
   END IF;

   arp_rounding.correct_scredit_rounding_errs( p_customer_trx_id,
                                                     l_scredit_count);


  /*------------------------------------------------------------+
   | Header level Rounding					|
   | the following code is redundant - eventually the code	|
   | should be studied so that l_activity_flag is set only once |
   |								|
   | l_activity_flag to be used in correct_dist_rounding        |
   +------------------------------------------------------------*/

     SELECT  ctt.type,
             ct.initial_customer_trx_id,
             ct.previous_customer_trx_id
     INTO
             l_type,
             l_initial_customer_trx_id,
             l_previous_customer_trx_id
     from
             ra_customer_trx ct,
             ra_cust_trx_types ctt
     WHERE
             ct.customer_trx_id = p_customer_trx_id
     and
             ct.cust_trx_type_id = ctt.cust_trx_type_id;


     l_activity_flag := arpt_sql_func_util.get_activity_flag(
                        p_customer_trx_id,
                        l_true_open_receivables_flag,
                        p_complete_flag,
                        l_type,
                        l_initial_customer_trx_id,
                        l_previous_customer_trx_id );

  /*---------------------------------------------------+
   |  Correct rounding errors in the account set and   |
   |  account assignments records.                     |
   +---------------------------------------------------*/

   /* 6774561 - do not call Header Level rounding blindly
      if the transaction is a chargeback.

      Reason:  Receipt chargebacks have amounts/acctds that
      are specific to the receipt and may not total out
      to the converted amount.  If we round them, then the
      CB could be for a different amount than the original
      receipt.  */
   IF (l_type <> 'CB')
   THEN
        IF (arp_rounding.correct_dist_rounding_errors
                 ( null,                   -- request_id
                   p_customer_trx_id,
                   null,                   -- customer_trx_line_id
                   l_dist_count,
                   l_error_message,
                   arp_global.base_precision,
                   arp_global.base_min_acc_unit,
                   'ALL',
                   'N',
                   null,                   -- debug_mode
                   arp_global.sysparam.trx_header_level_rounding,
                   l_activity_flag
                 ) = 0 -- FALSE
            )
        THEN
           arp_util.debug('EXCEPTION:  arp_process_header.post_commit()');
           arp_util.debug(l_error_message);
             fnd_message.set_name('AR', 'AR_PLCRE_FHLR_CCID');

           APP_EXCEPTION.raise_exception;
        END IF;
   ELSE
      arp_util.debug('call to arp_rounding bypassed due to trx_type');
   END IF; -- end CB

   /* Bug 2164863 - The tax and accounting validations were postponed
      until after the rounding routines were called.  This was due to
      the fact that some localizations will recalculate the tax and
      distributions within do_completion_checking.

      Note that the last parameter on the call is 'Y' which means
      that only the validation of tax and accounting will execute
      at this point. */

   IF    (
              P_complete_flag     = 'Y'
          AND
              l_old_complete_flag = 'N'
         )
   THEN

         arp_trx_complete_chk.do_completion_checking(
                                            p_customer_trx_id,
                                            NULL,
                                            NULL,
                                            p_error_mode,
                                            l_error_count,
                                            'Y'
                                          );

         IF (l_error_count > 0)
         THEN
               app_exception.raise_exception;
         END IF;

    END IF;

  /*-------------------------------------------------------------+
   |  if complete then                                           |
   |  check that the invoice total's sign is correct according   |
   |  to the sign constraint on the type                         |
   +-------------------------------------------------------------*/

   -- in order to get debit memo reversal to work, this code is not
   -- executed if p_cash_receipt_id is NOT NULL.  This needs to be
   -- changed when Charlie is around to help figure out the proper
   -- value for the creation sign.

   IF (p_cash_receipt_id IS NULL) THEN
     IF ( p_complete_flag = 'Y' )
     THEN
         /*Bug3049044/3041195: Changed arp_trx_validate.check_sign_and_overapp
         to take p_error_mode and p_error_count to allow for better
         error handling */

         arp_trx_validate.check_sign_and_overapp( p_customer_trx_id,
                                                  p_previous_customer_trx_id,
                                                  p_trx_open_receivables_flag,
                                                  p_prev_open_receivables_flag,
                                                  p_creation_sign,
                                                  p_allow_overapplication_flag,
                                                  p_natural_application_flag,
                                                  p_error_mode,
                                                  l_error_count
                                                );
         IF (l_error_count > 0)
         THEN
               app_exception.raise_exception;
         END IF;

     END IF;
   END IF;

   /* Bug fix 4910860
      Check if the accounting entries of this transaction balance */

    IF p_form_name in ('AR_INVOICE_API','AR_TRANSACTION_GRP','AR_DEPOSIT_API_PUB') THEN
       l_called_from_api := 'Y';
    ELSE
       l_called_from_api := 'N';
    END IF;
    arp_balance_check.check_transaction_balance(p_customer_trx_id,l_called_from_api);

    -----------------------------------------------------------------------
    -- Maintain transaction payment schedules:
    --
    -- open_receivable_flag: if open_rec = Y or payment schedules exist
    -- complete_changed_flag:
    --          if open_rec = Y  and complete = Y and no PS exist ==> Y
    --          if open_rec = Y  and complete = N and PS exists   ==> N
    -- amount_or_terms_changed_flag:
    --          if open_rec = Y sum of lines <> sum of ps
    -----------------------------------------------------------------------


    -----------------------------------------------------------------------
    -- IF complete flag has changed to Y
    --    AND   open_rec_flag = 'Y'
    -- THEN
    --       Create payment schedules
    --       IF  CM against transaction
    --       THEN
    --          update the invoice's payment schedules
    --          create receivable application record
    --       END IF;
    -- END IF;
    -----------------------------------------------------------------------

    IF( p_complete_flag <> l_old_complete_flag AND
        P_complete_flag  = 'Y' AND
        l_open_receivables_flag = 'Y' ) THEN

      --apandit : populating summary table using business events
      --for regular credit memo get the ps status information for prev_cust_trx_id
      IF l_previous_customer_trx_id IS NOT NULL THEN


         FOR i in get_existing_ps(l_previous_customer_trx_id) LOOP
           l_prev_cust_old_state(i.payment_schedule_id).amount_due_remaining := i.amount_due_remaining;
           l_prev_cust_old_state(i.payment_schedule_id).status := i.status;
           l_prev_cust_old_state(i.payment_schedule_id).amount_credited := i.amount_credited;

         END LOOP;


      END IF;

        arp_standard.debug('Calling maintain_payment_schedules EH in insert mode');
        arp_maintain_ps.maintain_payment_schedules(
                'I',
                p_customer_trx_id,
                NULL,   -- ps_id
                NULL,   -- line_amount
                NULL,   -- tax_amount
                NULL,   -- frt_amount
                NULL,   -- charge_amount
                l_applied_commitment_amt,
                p_cash_receipt_id
        );
          --apandit
          --Bug 2641517 Raise the Complete business event.
          AR_BUS_EVENT_COVER.Raise_Trx_Creation_Event
                                             (l_type,
                                              p_customer_trx_id,
                                              l_prev_cust_old_state);

    END IF;


    -----------------------------------------------------------------------
    -- IF    complete_flag has changed to N
    --     AND   open_rec_flag = 'Y'
    --     OR open receivables has been changed to N
    -- THEN
    --     delete payment schedules
    --     IF   CM against transaction
    --     THEN
    --         update the invoice's payment schedules
    --         delete receivable application record
    --     END IF;
    -- END IF;
    -----------------------------------------------------------------------

    IF(
          (
                p_complete_flag         <> l_old_complete_flag
            AND p_complete_flag          = 'N'
            AND l_open_receivables_flag  = 'Y'
          )
        OR
          (
                p_complete_flag               = 'Y'
            AND l_open_receivables_flag       = 'Y'
            AND l_true_open_receivables_flag  = 'N'
          )
      ) THEN
      /* now we want to make the call to check the activity flag */
      /* Bug 643716: pass p_previous_customer_trx_id instead of  */
      /* l_previous_customer_trx_id */

        l_activity_flag := arpt_sql_func_util.get_activity_flag(
                           p_customer_trx_id,
                           l_true_open_receivables_flag,
                           p_complete_flag,
                           l_type,
                           l_initial_customer_trx_id,
                           p_previous_customer_trx_id );

        /*  if there is activity, we do not want the ps recreated */

        IF (l_activity_flag = 'N') then

         --apandit : Bug 2641517
         --Before calls to any maintain payment schedules routine
         --insert the ps image in the history table.

           l_counter := 0;
          OPEN get_existing_ps (p_customer_trx_id);
           LOOP
            FETCH get_existing_ps INTO
             l_trx_sum_hist_rec.customer_trx_id,
             l_trx_sum_hist_rec.payment_schedule_id,
             l_trx_sum_hist_rec.currency_code,
             l_trx_sum_hist_rec.due_date,
             l_trx_sum_hist_rec.amount_in_dispute,
             l_trx_sum_hist_rec.amount_due_original,
             l_trx_sum_hist_rec.amount_due_remaining,
             l_trx_sum_hist_rec.amount_adjusted,
             l_trx_sum_hist_rec.customer_id,
             l_trx_sum_hist_rec.site_use_id,
             l_trx_sum_hist_rec.trx_date,
             l_amt_credited,
             l_stat;

             l_trx_sum_hist_rec.installments := null;

             IF get_existing_ps%NOTFOUND THEN
               EXIT;
             END IF;

             l_counter := nvl(l_counter,0) + 1;

             /* This second select on the ar_payment_schedules
                has been placed here temporarily. Going forward this
                needs to be changed, we need to use analytic function in the
                cursor get_existing_ps and get the count from there itself
              */
             IF l_counter = 1 THEN

               select count(*)
               into l_trx_sum_hist_rec.installments
               from ar_payment_schedules_all
               where customer_trx_id = p_customer_trx_id;

             END IF;

             AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                                      l_history_id,
                                                      l_type,
                                                      'INCOMPLETE_TRX');
             -- for credit memos... since we have only one payment schedule
             -- so raising the business event outside this loop is ok.
             IF l_type <> 'CM' THEN
              AR_BUS_EVENT_COVER.Raise_Trx_Incomplete_Event
                                             (l_type,
                                              p_customer_trx_id,
                                              l_trx_sum_hist_rec.payment_schedule_id,
                                              l_history_id,
                                              l_prev_cust_old_state --contains null value
                                             );
             END IF;

            END LOOP;

           CLOSE get_existing_ps;

           IF l_previous_customer_trx_id IS NOT NULL THEN


            FOR i in get_existing_ps(l_previous_customer_trx_id) LOOP
              l_prev_cust_old_state(i.payment_schedule_id).amount_due_remaining
                                                         := i.amount_due_remaining;
              l_prev_cust_old_state(i.payment_schedule_id).status := i.status;
              l_prev_cust_old_state(i.payment_schedule_id).amount_credited
                                                              := i.amount_credited;

            END LOOP;

           END IF;


            arp_maintain_ps.maintain_payment_schedules(
                    'D',
                     p_customer_trx_id,
                     NULL,   -- ps_id
                     NULL,   -- line_amount
                     NULL,   -- tax_amount
                     NULL,   -- frt_amount
                     NULL,   -- charge_amount
                     l_applied_commitment_amt
                  );

             IF l_type = 'CM' THEN
              AR_BUS_EVENT_COVER.Raise_Trx_Incomplete_Event
                                             (l_type,
                                              p_customer_trx_id,
                                              l_trx_sum_hist_rec.payment_schedule_id,
                                              l_history_id,
                                              l_prev_cust_old_state);
             END IF;

       ELSE
          FND_MESSAGE.Set_Name('AR','AR_TW_NO_RECREATE_PS');
          APP_EXCEPTION.Raise_Exception;
       END IF;

    END IF;

    end if; /* if p_form_name <> 'ARPBFBIB' */

    -----------------------------------------------------------------------
    -- IF    complete flag is unchanged
    --     AND   complete flag is Y
    --     AND   amount, currency or term has changed
    --     AND   open_rec_flag = 'Y'
    -- THEN
    --     update payment schedules
    --     IF   CM against transaction  THEN
    --         update the invoice's payment schedules
    --         update receivable application record
    --     END IF;
    -- END IF;
    -----------------------------------------------------------------------

 /*----------------------------------------------------------------------------------+
  | Bug Fix 586968 - srangara --  Get l_recreate_ps_flag to check if payment         |
  | schedules need to be re-created                                                  |
  | Logic for bug 586371 has been moved so that it is done after we get the          |
  | l_recreate_ps_flag.                                                              |
  +----------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------+
 |  Bug Fix 620760:  when no-post-to-GL, the gl_date in                     |
 |                   ra_cust_trx_line_gl_dist is NULL.  We need to check    |
 |                   for this before comparing to see if the gl_date has    |
 |                   changed.                                               |
 +--------------------------------------------------------------------------*/

   select  DECODE(
            ctt.accounting_affect_flag,
            'Y', DECODE(
                   SUM( ps.amount_due_original ),
                   lgd.amount,
                     DECODE( ct.term_id,
                       MAX( ps.term_id ),
                         DECODE(ct.invoice_currency_code,
                           MAX(ps.invoice_currency_code),
                             DECODE(NVL(ct.exchange_rate,1),
                               NVL(MAX(ps.exchange_rate),1),
                                DECODE(ct.exchange_date,
                                   MAX(ps.exchange_date),
                                     DECODE(ct.exchange_rate_type,
                                       MAX(ps.exchange_rate_type),
                                         DECODE(ct.bill_to_customer_id,
                                           MAX(ps.customer_id),
                                              DECODE(ct.bill_to_site_use_id,
                                                MAX(ps.customer_site_use_id),
                                                  DECODE(ct.cust_trx_type_id,
                                                    MAX(ps.cust_trx_type_id),
                                                     DECODE(ctt.post_to_gl, 'Y',
                                                       DECODE(lgd.gl_date,
                                                          MAX(ps.gl_date),
                                                          'N', 'Y'),
                                                        'N'),
                                                     'Y'),
                                                  'Y'),
                                             'Y'),
                                        'Y'),
                                   'Y'),
                                'Y'),
                            'Y'),
                        'Y'),
                     'Y'),
              'N'
                 ),         -- amount, currency, terms, bill to address or customer changed
   DECODE(ctt.accounting_affect_flag,
             'Y', DECODE( ct.term_id,
                       MAX( ps.term_id ),'N', 'Y'))
   INTO      l_recreate_ps_flag,
             l_term_changed_flag
   FROM      ar_payment_schedules      ps,
             ra_cust_trx_types         ctt,
             ra_cust_trx_line_gl_dist  lgd,
             ra_customer_trx           ct
   WHERE     ct.customer_trx_id   = ps.customer_trx_id(+)
   AND       ct.cust_trx_type_id  = ctt.cust_trx_type_id
   AND       ct.customer_trx_id   = lgd.customer_trx_id
   AND       lgd.account_class    = 'REC'
   AND       lgd.latest_rec_flag  = 'Y'
   AND       ct.customer_trx_id   = p_customer_trx_id
   GROUP BY  ctt.accounting_affect_flag,
             ct.complete_flag,
             ct.term_id,
             ct.invoice_currency_code,
             lgd.amount,
             ct.exchange_rate,
             ct.exchange_date,
             ct.exchange_rate_type,
             ct.bill_to_customer_id,
             ct.bill_to_site_use_id,
             lgd.gl_date,
             ct.cust_trx_type_id,
             ctt.post_to_gl;


   arp_util.debug('Recreate Paysched Flag   = ' || l_recreate_ps_flag );

  /*  if the l_recreate_ps_flag is set to Y then we want to see if there
      the transaction has any activity.  To do this, we need to get some
      information about the transaction and then get the activity flag.
      This is for Bug 586371   */

   IF ( l_recreate_ps_flag = 'Y' ) then

     -- check on activity is already done in ARPBFBIB, we don't need to do it again
     IF p_form_name = 'ARPBFBIB' THEN
        l_activity_flag := 'N';
     ELSE

        SELECT  ctt.type,
             ct.initial_customer_trx_id,
             ct.previous_customer_trx_id
        INTO
             l_type,
             l_initial_customer_trx_id,
             l_previous_customer_trx_id
        from
             ra_customer_trx ct,
             ra_cust_trx_types ctt
        WHERE
             ct.customer_trx_id = p_customer_trx_id
        and
             ct.cust_trx_type_id = ctt.cust_trx_type_id;

        /* now we want to make the call to get the activity flag */

        l_activity_flag := arpt_sql_func_util.get_activity_flag(
                              p_customer_trx_id,
                              l_true_open_receivables_flag,
                              p_complete_flag,
                              l_type,
                              l_initial_customer_trx_id,
                              l_previous_customer_trx_id );
     END IF;

   END IF;

    IF( p_complete_flag = l_old_complete_flag AND
        p_complete_flag = 'Y' AND
        l_recreate_ps_flag = 'Y' AND
        l_open_receivables_flag = 'Y' AND
        l_activity_flag = 'N' ) THEN

       --Bug 2641517 : apandit
        IF nvl(l_term_changed_flag,0) = 'Y'  THEN
          OPEN get_existing_ps (p_customer_trx_id);

           l_counter := 0;
           LOOP
            FETCH get_existing_ps INTO
             l_trx_sum_hist_rec.customer_trx_id,
             l_trx_sum_hist_rec.payment_schedule_id,
             l_trx_sum_hist_rec.currency_code,
             l_trx_sum_hist_rec.due_date,
             l_trx_sum_hist_rec.amount_in_dispute,
             l_trx_sum_hist_rec.amount_due_original,
             l_trx_sum_hist_rec.amount_due_remaining,
             l_trx_sum_hist_rec.amount_adjusted,
             l_trx_sum_hist_rec.customer_id,
             l_trx_sum_hist_rec.site_use_id,
             l_trx_sum_hist_rec.trx_date,
             l_amt_credited,
             l_stat;

             l_trx_sum_hist_rec.installments := null;

             IF get_existing_ps%NOTFOUND THEN
               EXIT;
             END IF;
             l_counter := nvl(l_counter,0) +1;

             /* This second select on the ar_payment_schedules
                has been placed here temporarily. Going forward this
                needs to be changed, we need to use analytic function in the
                cursor get_existing_ps and get the count from there itself
              */

             IF l_counter = 1 THEN

               select count(*)
               into l_trx_sum_hist_rec.installments
               from ar_payment_schedules_all
               where customer_trx_id = p_customer_trx_id;

             END IF;


            --This flow will never be executed for the credit memo case
            --as we do not change term on the credit memo.

             AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                                      l_history_id,
                                                      l_type,
                                                      'INCOMPLETE_TRX');

             --Raise the Incompletion business event.
             AR_BUS_EVENT_COVER.Raise_Trx_Incomplete_Event
                                             (l_type,
                                              p_customer_trx_id,
                                              l_trx_sum_hist_rec.payment_schedule_id,
                                              l_history_id,
                                              l_prev_cust_old_state --null value
                                              );
            END LOOP;
            CLOSE get_existing_ps;

         END IF; --l_term_changed_flag

        arp_maintain_ps.maintain_payment_schedules(
                'U',
                p_customer_trx_id,
                NULL,   -- ps_id
                NULL,   -- line_amount
                NULL,   -- tax_amount
                NULL,   -- frt_amount
                NULL,   -- charge_amount
                l_applied_commitment_amt
        );

      --apandit
      --Bug 2641517
      IF nvl(l_term_changed_flag,0) = 'Y'  THEN
          --Raise the Complete business event.
          AR_BUS_EVENT_COVER.Raise_Trx_Creation_Event
                                             (l_type,
                                              p_customer_trx_id,
                                              l_prev_cust_old_state);
      END IF;

    END IF;

    /*  if the recreation flag is Y but there is activity then raise an
        exception.  for Bug 586371 */

    IF ( l_recreate_ps_flag = 'Y' and l_activity_flag = 'Y') then
       FND_MESSAGE.Set_Name('AR','AR_TW_NO_RECREATE_PS');
       APP_EXCEPTION.Raise_Exception;
    END IF;

    -----------------------------------------------------------------------
    -- IF    complete flag is unchanged AND complete flag is N
    -- THEN  do nothing
    -- END IF;
    -----------------------------------------------------------------------

   arp_util.print_fcn_label( 'arp_process_header.post_commit()- ');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_header.post_commit()');

        arp_util.debug('');
        arp_util.debug('---------- parameters for post_commit() ---------');

        arp_util.debug('p_form_name                      = ' ||
                       p_form_name);
        arp_util.debug('p_form_version                   = ' ||
                        p_form_version);
        arp_util.debug('p_customer_trx_id                = ' ||
                       p_customer_trx_id);
        arp_util.debug('p_previous_customer_trx_id       = ' ||
                       p_previous_customer_trx_id);
        arp_util.debug('p_complete_flag                  = ' ||
                       p_complete_flag);
        arp_util.debug('p_trx_open_receivables_flag      = ' ||
                       p_trx_open_receivables_flag);
        arp_util.debug('p_prev_open_receivables_flag     = ' ||
                       p_prev_open_receivables_flag);
        arp_util.debug('p_creation_sign                  = ' ||
                       p_creation_sign);
        arp_util.debug('p_allow_overapplication_flag     = ' ||
                       p_allow_overapplication_flag);
        arp_util.debug('p_natural_application_flag       = ' ||
                       p_natural_application_flag);

        RAISE;

END;


  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/
PROCEDURE init IS
BEGIN

  pg_base_precision    		:= arp_global.base_precision;
  pg_base_min_acc_unit 		:= arp_global.base_min_acc_unit;
  pg_trx_header_level_rounding 	:= arp_global.sysparam.trx_header_level_rounding;
END init;

BEGIN
   init;
END ARP_PROCESS_HEADER_POST_COMMIT;

/
