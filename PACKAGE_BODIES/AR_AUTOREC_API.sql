--------------------------------------------------------
--  DDL for Package Body AR_AUTOREC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_AUTOREC_API" AS
/* $Header: ARATRECB.pls 120.40.12010000.69 2010/06/19 02:39:32 vpusulur ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PG_PARALLEL varchar2(1) := NVL(FND_PROFILE.value('AR_USE_PARALLEL_HINT'), 'N');

G_ERROR  varchar2(1) := 'N';

PROCEDURE CONTROL_CHECK ( p_batch_id ar_batches.batch_id%TYPE,p_gt_id NUMBER);

g_auth_fail varchar2(1) := 'N';

PROCEDURE SUBMIT_FORMAT ( p_batch_id    ar_batches.batch_id%TYPE);

PROCEDURE process_selected_receipts(
        p_receipt_method_id                in  ar_cash_receipts.receipt_method_id%type default null,
	p_batch_id                         in  ar_batches.batch_id%type,
        p_approval_mode                    IN  VARCHAR2 DEFAULT 'APPROVE'
	);

g_rcpt_info_rec	receipt_info_rec;


g_rcpt_creation_rec rcpt_creation_info;

g_approve_flag  ar_cash_receipts.confirmed_flag%TYPE ;
g_format_flag   ar_cash_receipts.confirmed_flag%TYPE ;
g_create_flag   ar_cash_receipts.confirmed_flag%TYPE ;

g_party_id                  NUMBER;
g_pmt_channel_code          VARCHAR2(30);
g_assignment_id             NUMBER;
g_auth_flag                 VARCHAR2(30);
g_batch_id		    NUMBER;
/*-----------------------------------------------------------------------+
 | Default bulk fetch size, and starting index                           |
 +-----------------------------------------------------------------------*/
MAX_ARRAY_SIZE          BINARY_INTEGER := 1000 ;
STARTING_INDEX          CONSTANT BINARY_INTEGER := 1;

 /* Bug 8903995 */
  pg_request_id              NUMBER;
  pg_last_updated_by         NUMBER;
  pg_created_by              NUMBER;
  pg_last_update_login       NUMBER;
  pg_program_application_id  NUMBER;
  pg_program_id              NUMBER;


  PROCEDURE process_events(p_gt_id     NUMBER,
			   p_batch_id  NUMBER)  IS

  l_xla_ev_rec             arp_xla_events.xla_events_type;
  l_from_doc_id            NUMBER;
  l_to_doc_id              NUMBER;
  l_from_ra_doc_id         NUMBER;
  l_to_ra_doc_id           NUMBER;

  l_paying_customer_id      NUMBER;
  l_reqid                   NUMBER;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('process_events()+');
    END IF;

    update ar_cash_receipts
    SET creation_date          = sysdate,
	created_by             = pg_created_by,
	last_update_date       = sysdate,
	last_updated_by        = pg_created_by,
	last_update_login      = pg_last_update_login,
	request_id             = pg_request_id,
	program_application_id = pg_program_application_id,
	program_id             = pg_program_id,
	program_update_date    = sysdate
    WHERE cash_receipt_id in
     ( select cash_receipt_id
       from AR_RECEIPTS_GT
       where gt_id = p_gt_id );

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( 'NO of Receipts updated =  '|| to_char(SQL%ROWCOUNT));
    END IF;

    update ar_cash_receipt_history SET
    batch_id   = p_batch_id,
    created_by =  pg_created_by,
    last_update_date = sysdate,
    last_updated_by =  pg_created_by,
    last_update_login = pg_last_update_login,
    request_id = pg_request_id,
    program_application_id = pg_program_application_id,
    program_id = pg_program_id,
    program_update_date = sysdate
    WHERE cash_receipt_id in
    ( select cash_receipt_id
      from AR_RECEIPTS_GT
      where gt_id = p_gt_id );

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( 'NO of Receipts updated CRH =  '|| to_char(SQL%ROWCOUNT));
    END IF;

    update AR_payment_schedules  SET
    created_by =  pg_created_by,
    last_update_date = sysdate,
    last_updated_by =  pg_created_by,
    last_update_login = pg_last_update_login,
    request_id = pg_request_id,
    program_application_id = pg_program_application_id,
    program_id = pg_program_id,
    program_update_date = sysdate
    WHERE cash_receipt_id in
    ( select cash_receipt_id
      from AR_RECEIPTS_GT
      where gt_id = p_gt_id );

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( 'NO of Receipts updated  PS =  '|| to_char(SQL%ROWCOUNT));
    END IF;

    update ar_receivable_applications SET
    created_by =  pg_created_by,
    last_update_date = sysdate,
    last_updated_by =  pg_created_by,
    last_update_login = pg_last_update_login,
    request_id = pg_request_id,
    program_application_id = pg_program_application_id,
    program_id = pg_program_id,
    program_update_date = sysdate
    WHERE cash_receipt_id in
    ( select cash_receipt_id
      from AR_RECEIPTS_GT
      where gt_id = p_gt_id );

    /* UPDATING INVOICE PS 7271561*/
    update ar_payment_schedules
    set selected_for_receipt_batch_id = NULL
    where payment_schedule_id  in
    ( select /*+ unnest */ r.payment_schedule_id
      from ar_receipts_gt r,
      ar_receivable_applications ra
      where r.gt_id = p_gt_id
      and ra.applied_customer_trx_id = r.customer_trx_id
      and ra.request_id = pg_request_id
      and ra.status = 'APP'
      UNION ALL
      select r.payment_schedule_id
      from ar_receipts_gt r,
      ra_customer_trx ct
      where r.gt_id = p_gt_id
      and ct.customer_trx_id = r.customer_trx_id
      and ct.cc_error_flag = 'Y'
     );

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( 'NO of RA updated =  '|| to_char(SQL%ROWCOUNT));
    END IF;

    select min(gt.cash_receipt_id),
	   max(gt.cash_receipt_id),
	   min(ra.receivable_application_id),
	   max(ra.receivable_application_id)
    into l_from_doc_id,
	 l_to_doc_id,
	 l_from_ra_doc_id,
	 l_to_ra_doc_id
    from AR_RECEIPTS_GT gt,
         ar_receivable_applications ra
    where gt.cash_receipt_id = ra.cash_receipt_id
    and gt_id = p_gt_id;

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( 'Calling XLA event creation procedures for');
      arp_debug.debug ( 'xla_req_id      '||pg_request_id);
      arp_debug.debug ( 'xla_from_doc_id '||l_from_doc_id);
      arp_debug.debug ( 'xla_to_doc_id   '||l_to_doc_id);
    END IF;

    /* Create events for the receipts associated to this request id and given range*/
    l_xla_ev_rec.xla_doc_table   := 'CRHAPP';
    l_xla_ev_rec.xla_req_id      := pg_request_id;
    l_xla_ev_rec.xla_from_doc_id := l_from_doc_id;
    l_xla_ev_rec.xla_to_doc_id   := l_to_doc_id;
    l_xla_ev_rec.xla_mode        := 'B';
    l_xla_ev_rec.xla_call        := 'C';

    arp_xla_events.Create_Events( l_xla_ev_rec );

    l_xla_ev_rec.xla_doc_table   := 'CRH';
    l_xla_ev_rec.xla_req_id      := pg_request_id;
    l_xla_ev_rec.xla_from_doc_id := l_from_doc_id;
    l_xla_ev_rec.xla_to_doc_id   := l_to_doc_id;
    l_xla_ev_rec.xla_mode        := 'B';
    l_xla_ev_rec.xla_call        := 'D';

    arp_xla_events.Create_Events( l_xla_ev_rec );

    l_xla_ev_rec.xla_doc_table   := 'APP';
    l_xla_ev_rec.xla_req_id      := pg_request_id;
    l_xla_ev_rec.xla_from_doc_id := l_from_ra_doc_id;
    l_xla_ev_rec.xla_to_doc_id   := l_to_ra_doc_id;
    l_xla_ev_rec.xla_mode        := 'B';
    l_xla_ev_rec.xla_call        := 'D';

    arp_xla_events.Create_Events( l_xla_ev_rec );

    Select min(ra.receivable_application_id),
           max(ra.receivable_application_id)
    into   l_from_ra_doc_id,
           l_to_ra_doc_id
    from   AR_RECEIPTS_GT gt,
           ar_receivable_applications ra
    where  gt.cash_receipt_id = ra.cash_receipt_id
    and    gt_id = p_gt_id
    and    ra.event_id is null ;

    IF l_from_ra_doc_id IS NOT NULL THEN

      IF PG_DEBUG in ('Y','C') THEN
        arp_debug.debug ( 'Calling XLA event creation procedure again in O mode');
        arp_debug.debug ( 'xla_req_id      '||pg_request_id);
        arp_debug.debug ( 'xla_from_doc_id '||l_from_doc_id);
        arp_debug.debug ( 'xla_to_doc_id   '||l_to_doc_id);
      END IF;

	l_xla_ev_rec.xla_doc_table   := 'APP';
	l_xla_ev_rec.xla_req_id      := pg_request_id;
	l_xla_ev_rec.xla_from_doc_id := l_from_ra_doc_id;
	l_xla_ev_rec.xla_to_doc_id   := l_to_ra_doc_id;
	l_xla_ev_rec.xla_mode        := 'O';
	l_xla_ev_rec.xla_call        := 'B';

	arp_xla_events.Create_Events( l_xla_ev_rec );

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('process_events()-');
    END IF;

    EXCEPTION
     WHEN others THEN
	 arp_debug.debug('Exception : process_events() '|| SQLERRM);

	insert_exceptions( p_batch_id   => p_batch_id,
	           p_request_id => pg_request_id,
		   p_exception_code  => 'AUTORECERR',
		   p_additional_message => 'process_events() '|| SQLERRM );

  END process_events;


PROCEDURE dump_ar_receipts_gt IS
BEGIN
  FOR rec IN (select * from ar_receipts_gt) LOOP
      arp_debug.debug( '------------------------------------------------------');
      arp_debug.debug( 'PAYMENT_SCHEDULE_ID       :'|| rec.payment_schedule_id );
      arp_debug.debug( 'CUSTOMER_TRX_ID           :'|| rec.customer_trx_id );
      arp_debug.debug( 'CASH_RECEIPT_ID           :'|| rec.cash_receipt_id);
      arp_debug.debug( 'PAYING_CUSTOMER_ID        :'|| rec.paying_customer_id);
      arp_debug.debug( 'PAYING_SITE_USE_ID        :'|| rec.paying_site_use_id);
      arp_debug.debug( 'PAYMENT_TRXN_EXTENSION_ID :'|| rec.payment_trxn_extension_id);
      arp_debug.debug( 'DUE_DATE                  :'|| rec.due_date);
      arp_debug.debug( 'AMOUNT_DUE_REMAINING      :'|| rec.amount_due_remaining);
      arp_debug.debug( 'CUSTOMER_BANK_ACCOUNT_ID  :'|| rec.customer_bank_account_id);
      arp_debug.debug( 'CUST_MIN_AMOUNT           :'|| rec.cust_min_amount);
      arp_debug.debug( 'RECEIPT_NUMBER            :'|| rec.receipt_number);
      arp_debug.debug( 'PAYMENT_CHANNEL_CODE      :'|| rec.payment_channel_code);
      arp_debug.debug( 'PAYMENT_INSTRUMENT        :'|| rec.payment_instrument);
      arp_debug.debug( 'AUTHORIZATION_ID          :'|| rec.authorization_id);
      arp_debug.debug( 'GT_ID                     :'|| rec.gt_id);
  END LOOP;

END dump_ar_receipts_gt;


PROCEDURE process_incomplete_receipts(p_batch_id NUMBER) IS
l_receipt_method_id ar_batches.receipt_method_id%type;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('process_incomplete_receipts()+');
    arp_debug.debug('p_batch_id '|| p_batch_id );
  END IF;

    select receipt_method_id
    into l_receipt_method_id
    from ar_batches
    where batch_id = p_batch_id;

    --process partial receipts created during previous run
    process_selected_receipts( p_receipt_method_id => l_receipt_method_id,
			       p_batch_id          => p_batch_id,
			       p_approval_mode     => 'RE-APPROVAL');


    --nullify the batch_id for closed invoices
    UPDATE ar_payment_schedules
    SET selected_for_receipt_batch_id = null
    WHERE selected_for_receipt_batch_id = p_batch_id
    AND status = 'CL';

    --cleanup gt table
    delete
    from ar_receipts_gt;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('process_incomplete_receipts()-');
  END IF;
END process_incomplete_receipts;



/*========================================================================+
 | PUBLIC PROCEDURE GET_PARAMETERS                                        |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to get the parameters from the Conc program   |
 |    and convert them to the type reqd for processing.                   |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 | 14-JAN-2010              MRAYMOND         9214328 - problems with
 |                                             batch locking
 *=========================================================================*/
PROCEDURE get_parameters(
      P_ERRBUF                          OUT NOCOPY VARCHAR2,
      P_RETCODE                         OUT NOCOPY NUMBER,
      p_process_type                    IN VARCHAR2,
      p_batch_date                      IN VARCHAR2,
      p_batch_gl_date                   IN VARCHAR2,
      p_create_flag                     IN VARCHAR2,
      p_approve_flag                    IN VARCHAR2,
      p_format_flag                     IN VARCHAR2,
      p_batch_id                        IN VARCHAR2,
      p_debug_mode_on                   IN VARCHAR2,
      p_batch_currency                  IN VARCHAR2,
      p_exchange_date                   IN VARCHAR2,
      p_exchange_rate                   IN VARCHAR2,
      p_exchange_rate_type              IN VARCHAR2,
      p_remit_method_code               IN VARCHAR2,
      p_receipt_class_id                IN VARCHAR2,
      p_payment_method_id               IN VARCHAR2,
      p_media_reference                 IN VARCHAR2,
      p_remit_bank_branch_id            IN VARCHAR2,
      p_remit_bank_account_id           IN VARCHAR2,
      p_remit_bank_deposit_number       IN VARCHAR2,
      p_comments                        IN VARCHAR2,
      p_trx_date_l                      IN VARCHAR2,
      p_trx_date_h                      IN VARCHAR2,
      p_due_date_l                      IN VARCHAR2,
      p_due_date_h                      IN VARCHAR2,
      p_trx_num_l                       IN VARCHAR2,
      p_trx_num_h                       IN VARCHAR2,
      p_doc_num_l                       IN VARCHAR2,
      p_doc_num_h                       IN VARCHAR2,
      p_customer_number_l               IN VARCHAR2,
      p_customer_number_h               IN VARCHAR2,
      p_customer_name_l                 IN VARCHAR2,
      p_customer_name_h                 IN VARCHAR2,
      p_customer_id                     IN VARCHAR2,
      p_site_l                          IN VARCHAR2,
      p_site_h                          IN VARCHAR2,
      p_site_id                         IN VARCHAR2,
      p_remittance_total_from           IN VARCHAR2,
      p_Remittance_total_to             IN VARCHAR2,
      p_billing_number_l                IN VARCHAR2,
      p_billing_number_h                IN VARCHAR2,
      p_customer_bank_acc_num_l         IN VARCHAR2,
      p_customer_bank_acc_num_h         IN VARCHAR2,
      p_current_worker_number           IN VARCHAR2 DEFAULT '0',
      p_total_workers                   IN VARCHAR2 DEFAULT '0'
      ) IS

      l_current_worker_number              NUMBER;
      l_total_workers                      NUMBER;
      l_request_id                         ar_cash_receipts.request_id%TYPE;
      l_gl_date                            ar_cash_receipt_history.gl_date%TYPE;
      l_batch_date                         ar_cash_receipts.receipt_date%TYPE ;
      l_receipt_class_id                   ar_receipt_classes.receipt_class_id%TYPE ;
      l_receipt_method_id                  ar_cash_receipts.receipt_method_id%TYPE ;
      l_currency_code                      ar_cash_receipts.currency_code%TYPE;
      l_approve_flag                       ar_cash_receipts.confirmed_flag%TYPE ;
      l_format_flag                        ar_cash_receipts.confirmed_flag%TYPE ;
      l_create_flag                        ar_cash_receipts.confirmed_flag%TYPE ;
      o_batch_id                           NUMBER;
      l_approve_only_flag                  VARCHAR2(1);
      l_batch_app_status                   VARCHAR2(200);

      l_batch_lock_msg                     VARCHAR2(200);
      l_batch_lock_flag                    BOOLEAN;
      l_batch_lock_excp                    EXCEPTION;

      /* selinv variables */
      op_payment_schedule_id         NUMBER;
      op_customer_trx_id             NUMBER;
      op_cash_receipt_id             NUMBER;
      op_paying_customer_id          NUMBER;
      op_paying_site_use_id          NUMBER;
      op_payment_server_order_num    VARCHAR2(200);
      op_due_date                    DATE;
      op_amount_due_remaining        VARCHAR2(200);
      op_cust_bank_account_id        NUMBER;
      op_cust_min_amt                VARCHAR2(20);
      op_return_status               VARCHAR2(20);
      op_payment_trxn_extension_id   NUMBER;
      op_payment_channel_code        VARCHAR2(30);
      op_instrument_type             VARCHAR2(30);

     /* selinv variables */

      /* apply variables*/
      al_return_status  VARCHAR2(1);
      al_msg_count      NUMBER;
      al_msg_data      VARCHAR2(240);
      al_count          NUMBER;
      al_attribute      ar_receipt_api_pub.attribute_rec_type;
      l_called_from    VARCHAR2(15);

      CURSOR c2 is
      select payment_schedule_id,
      receipt_number rec_num,
      amount_due_remaining amt
      from AR_RECEIPTS_GT;
     /* apply variables */


    /* reset variables */
      l_apply_fail       VARCHAR2(1);
      l_pay_process_fail VARCHAR2(1);
      l_rec_creation_rule_code   ar_receipt_methods.receipt_creation_rule_code%TYPE;

      /* Bug 7639165 - Declaration Begin. */
      l_instrument_type	VARCHAR2(30);
      /* Bug 7639165 - Declaration End. */

      /* 9214328 */
      l_error_message   fnd_new_messages.message_text%TYPE;
BEGIN
  l_apply_fail       := 'N';
  l_pay_process_fail := 'N';

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('autorecapi start ()+       ');
    arp_debug.debug('get_parameters()+          ');
    arp_debug.debug('p_errbuf                   ' ||  P_ERRBUF);
    arp_debug.debug('p_retcode                  ' ||  (P_RETCODE));
    arp_debug.debug('p_process_type             ' || p_process_type);
    arp_debug.debug('p_create_flag              ' || p_create_flag);
    arp_debug.debug('p_approve_flag             ' || p_approve_flag);
    arp_debug.debug('p_format_flag              ' || p_format_flag);
    arp_debug.debug('p_batch_id                 ' || (p_batch_id));
    arp_debug.debug('p_debug_mode_on            ' || p_debug_mode_on);
    arp_debug.debug('p_receipt_class_id         ' || p_receipt_class_id);
    arp_debug.debug('p_payment_method_id        ' || p_payment_method_id);
    arp_debug.debug('p_batch_currency           ' || p_batch_currency);
    arp_debug.debug('p_batch_date               ' || p_batch_date);
    arp_debug.debug('p_batch_gl_date            ' || p_batch_gl_date);
    arp_debug.debug('p_comments                 ' || p_comments);
    arp_debug.debug('p_exchnage_date            ' || p_exchange_date);
    arp_debug.debug('p_exchnage_rate            ' || p_exchange_rate);
    arp_debug.debug('p_exchnage_rate_type       ' || p_exchange_rate_type);
    arp_debug.debug('p_media_reference          ' || p_media_reference);
    arp_debug.debug('p_remit_method_code        ' || p_remit_method_code);
    arp_debug.debug('p_remit_bank_branch_id     ' || p_remit_bank_branch_id);
    arp_debug.debug('p_remit_bank_account_id    ' || p_remit_bank_account_id);
    arp_debug.debug('p_remit_bank_deposit_number' || p_remit_bank_deposit_number);
    arp_debug.debug('p_trx_date_l               ' || p_trx_date_l);
    arp_debug.debug('p_trx_date_h               ' || p_trx_date_h);
    arp_debug.debug('p_due_date_l               ' || p_due_date_l);
    arp_debug.debug('p_due_date_h               ' || p_due_date_h);
    arp_debug.debug('p_trx_num_l                ' || p_trx_num_l);
    arp_debug.debug('p_trx_num_h                ' || p_trx_num_h);
    arp_debug.debug('p_doc_num_l                ' || p_doc_num_l);
    arp_debug.debug('p_doc_num_h                ' || p_doc_num_h);
    arp_debug.debug('p_customer_number_l        ' || p_customer_number_l);
    arp_debug.debug('p_customer_number_h        ' || p_customer_number_h);
    arp_debug.debug('p_customer_name_l          ' || p_customer_name_l);
    arp_debug.debug('p_customer_name_h          ' || p_customer_name_h);
    arp_debug.debug('p_customer_id              ' || (p_customer_id));
    arp_debug.debug('p_site_l                   ' || p_site_l);
    arp_debug.debug('p_site_h                   ' || p_site_h);
    arp_debug.debug('p_site_id                  ' || (p_site_id));
    arp_debug.debug('p_remittance_total_from    ' || p_remittance_total_from);
    arp_debug.debug('p_Remittance_total_to      ' || p_Remittance_total_to);
    arp_debug.debug('p_billing_number_l         ' || p_billing_number_l);
    arp_debug.debug('p_billing_number_h         ' || p_billing_number_h);
    arp_debug.debug('p_customer_bank_acc_num_l  ' || p_customer_bank_acc_num_l);
    arp_debug.debug('p_customer_bank_acc_num_h  ' || p_customer_bank_acc_num_h);
  END IF;

  IF PG_DEBUG in ('Y','C') THEN
    arp_debug.debug( 'converting the parameters');
  END IF;

  l_gl_date            := fnd_date.canonical_to_date(p_batch_gl_date);
  l_batch_date         := fnd_date.canonical_to_date(p_batch_date);
  l_receipt_class_id   := to_number(p_receipt_class_id);
  l_receipt_method_id  := to_number(p_payment_method_id);
  l_currency_code      := p_batch_currency;
  l_create_flag        := p_create_flag;
  l_approve_flag       := p_approve_flag;
  l_format_flag        := p_format_flag;
  g_create_flag        := p_create_flag;
  g_approve_flag       := p_approve_flag;
  g_format_flag        := p_format_flag;

  l_current_worker_number := to_number(nvl(p_current_worker_number,0));
  l_total_workers         := to_number(nvl(p_total_workers,0));

/* Bug 8903995 */
  pg_request_id             := arp_standard.profile.request_id;
  pg_last_updated_by        := arp_standard.profile.last_update_login ;
  pg_created_by             := arp_standard.profile.user_id ;
  pg_last_update_login      := arp_standard.profile.last_update_login ;
  pg_program_application_id := arp_standard.application_id ;
  pg_program_id             := arp_standard.profile.program_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('pg_request_id             ' || pg_request_id);
     arp_debug.debug('pg_last_updated_by        ' || pg_last_updated_by);
     arp_debug.debug('pg_created_by             ' || pg_created_by);
     arp_debug.debug('pg_last_update_login      ' || pg_last_update_login);
     arp_debug.debug('pg_program_application_id ' || pg_program_application_id);
     arp_debug.debug('pg_program_id             ' || pg_program_id);
  END IF;

    --fetch the max commit size set for receipts
    SELECT CASE WHEN (NVL(auto_rec_receipts_per_commit,0) <= 0) THEN 1000
           ELSE auto_rec_receipts_per_commit END
    INTO MAX_ARRAY_SIZE
    FROM ar_system_parameters;

  IF p_batch_id is NULL THEN
    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug('p_batch_id  is null,Calling insert_batch..');
    END IF;

    /* CALL TO INSERT BATCH FROM MAIN */
    insert_batch(
    l_gl_date,
    l_batch_date,
    l_receipt_class_id,
    l_receipt_method_id,
    l_currency_code,
    l_approve_flag,
    l_format_flag,
    l_create_flag,
    o_batch_id
    );

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug('Batch got created batch_id:'||o_batch_id);
    END IF;

  ELSE
    o_batch_id := p_batch_id;

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug('Batch id passed,fetching details of batch_id:'|| p_batch_id);
    END IF;

    select batch_date ,
	  gl_date ,
	  currency_code,
	  receipt_method_id,
	  batch_applied_status
    into  l_batch_date,
	  l_gl_date,
	  l_currency_code,
	  l_receipt_method_id,
	  l_batch_app_status
    from  AR_BATCHES
    where batch_id = p_batch_id;

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug('batch_date           '|| l_batch_date);
      arp_debug.debug('gl_date              '|| l_gl_date);
      arp_debug.debug('currency_code        '|| l_currency_code);
      arp_debug.debug('receipt_method_id    '|| l_receipt_method_id);
      arp_debug.debug('l_batch_app_status   '|| l_batch_app_status);
    END IF;
  END IF;

    g_batch_id := o_batch_id;

  IF o_batch_id is null THEN
    arp_debug.debug( 'o_batch_id is null  This is an error condition');

    insert_exceptions(
    p_batch_id =>-333,
    p_request_id =>pg_request_id,
    p_exception_code => 'NO_BATCH',
    p_additional_message => 'error during insert batch' );

  IF PG_DEBUG in ('Y','C') THEN
    arp_debug.debug ( 'calling the report- batch_id  ' || -333 );
    arp_debug.debug ( 'calling the report ' || pg_request_id);
  END IF;

    submit_report ( p_batch_id   => o_batch_id,
		    p_request_id => pg_request_id);

    RETURN;
  END IF;

  /*lock the batch record to prevent multiple submissions for the same batch while a request
    is running.In case the request is spanned from master process,master will hold the lock*/
  IF l_total_workers = 0 AND p_approve_flag  = 'Y' THEN
    l_batch_lock_flag := ARP_RW_BATCHES_PKG.request_lock(o_batch_id ,l_batch_lock_msg);

    IF l_batch_app_status = 'STARTED_APPROVAL' THEN
      process_incomplete_receipts( o_batch_id );
    END IF;

    IF l_batch_lock_flag = FALSE THEN
      RAISE l_batch_lock_excp;
    END IF;
  END IF;

  IF  p_create_flag = 'Y' THEN
    l_approve_only_flag := 'N';
  ELSE
    l_approve_only_flag := 'A';
  END IF;

  /**In the case of new batch being created in the current run ,the below logic
     stamps batch_id on all the selected invoices and populates the data into
     interim and GT tables.
     If the batch exists prior to this run then it selects all the invoices
     associated to the current batch and populates the data into interim and
     GT tables.
     This distinction is done based on l_approve_only_flag being passed to
     procedure select_valid_invoices */
  IF  ( p_create_flag = 'Y'  OR
        p_approve_flag = 'Y' ) AND
      G_ERROR = 'N' THEN

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug('l_approve_only_flag             :' || l_approve_only_flag);
      arp_debug.debug('selecting the data for batch_id :' || to_char(o_batch_id));
    END IF;

    /** If the worker count is other than zero,master program populates the interim
     *  table with the selected data.*/
    IF l_total_workers = 0 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug ( ' l_total_workers :'||l_total_workers);
	arp_debug.debug ( ' Calling select_valid_invoices..');
      END IF;

      select_valid_invoices
      ( p_trx_date_l =>fnd_date.canonical_to_date(p_trx_date_l),
	p_trx_date_h =>fnd_date.canonical_to_date(p_trx_date_h),
	p_due_date_l =>fnd_date.canonical_to_date(p_due_date_l),
	p_due_date_h =>fnd_date.canonical_to_date(p_due_date_h),
	p_trx_num_l =>p_trx_num_l,
	p_trx_num_h => p_trx_num_h,
	p_doc_num_l =>p_doc_num_l,
	p_doc_num_h => p_doc_num_h,
	p_customer_number_l => p_customer_number_l,
	p_customer_number_h => p_customer_number_h,
	p_customer_name_l => p_customer_name_l,
	p_customer_name_h => p_customer_name_h,
	p_batch_id => o_batch_id,
	p_approve_only_flag => l_approve_only_flag,
	p_receipt_method_id => l_receipt_method_id,
	p_total_workers => 1 );

      IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug ( ' Returned from select_valid_invoices..');
      END IF;
    END IF;

    --Populating the data allocated to current worker from interim table to GT
    insert into ar_receipts_gt(
	  payment_schedule_id,
	  customer_trx_id,
	  cash_receipt_id,
	  paying_customer_id,
	  paying_site_use_id,
	  payment_trxn_extension_id,
	  due_date,
	  amount_due_remaining,
	  customer_bank_account_id,
	  cust_min_amount,
	  receipt_number,
	  payment_channel_code,
	  payment_instrument,
	  authorization_id,
	  gt_id)
    select distinct payment_schedule_id,
	 customer_trx_id,
	 cash_receipt_id,
	 paying_customer_id,
	 paying_site_use_id,
	 payment_trxn_extension_id,
	 due_date,
	 amount_due_remaining,
	 customer_bank_account_id,
	 cust_min_amount,
	 null,
	 payment_channel_code,
	 payment_instrument,
	 null,
	 null
    from ar_autorec_interim a
    where a.worker_id =  decode(l_current_worker_number,0,a.worker_id,
			       l_current_worker_number)
    and a.batch_id = o_batch_id;

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug ( 'NO of rows inserted into ar_receipts_gt :'|| to_char(SQL%ROWCOUNT));
    END IF;

    IF  l_total_workers = 0 THEN
      IF p_approve_flag = 'Y' THEN
	UPDATE ar_batches
	SET batch_applied_status = 'STARTED_APPROVAL'
	WHERE batch_id = o_batch_id;
      ELSIF p_create_flag = 'Y' THEN
	UPDATE ar_batches
	SET batch_applied_status = 'COMPLETED_CREATION'
	WHERE batch_id = o_batch_id;
      END IF;

      --Commit the creation process
      COMMIT;

      IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('Batch status set to COMPLETED_CREATION');
	arp_debug.debug('Batches updated '||SQL%ROWCOUNT);
      END IF;
    END IF;

  END IF;

  --Approval process
  IF p_approve_flag = 'Y' AND G_ERROR = 'N' THEN
    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug('Inside approve section ');
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('CALLING process_selected_receipts()');
    END IF;

    process_selected_receipts( p_receipt_method_id => l_receipt_method_id,
			       p_batch_id          => o_batch_id,
			       p_approval_mode     => 'APPROVAL');

    --If the current run is with only single worker then set the batch status else
    --this is done in the master program
    IF l_total_workers = 0 AND G_ERROR = 'N' THEN
      update ar_batches
      set batch_applied_status = 'COMPLETED_APPROVAL'
      where batch_id = o_batch_id;

      IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('Batch status set to COMPLETED_APPROVAL ');
	arp_debug.debug('Batches updated '||SQL%ROWCOUNT);
      END IF;
    END IF;
  END IF;

  /** If the current run is with only single worker then set the batch status and
      invoke the report  */
  IF l_total_workers = 0 THEN
    --cleanup the interim table
    delete
    from ar_autorec_interim
    where batch_id = o_batch_id;

    --release the lock on batch record
    l_batch_lock_flag :=
         ARP_RW_BATCHES_PKG.release_lock(o_batch_id ,l_batch_lock_msg);

    IF PG_DEBUG in ('Y','C')
    THEN
       arp_debug.debug('Releasing lock - ' || l_batch_lock_msg);
    END IF;

    IF l_format_flag = 'Y' THEN
      arp_debug.debug('Submitting format report- batch_id :' || o_batch_id);
      submit_format ( p_batch_id =>o_batch_id);
    END IF;

    /* SUBMIT THE FINAL REPORT FULL WITH ERRORS AND EXECUTION */
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug ( 'Submitting report- batch_id :' || o_batch_id);
       arp_debug.debug ( 'request id : ' || pg_request_id);
    END IF;

    submit_report ( p_batch_id   => o_batch_id,
		    p_request_id => pg_request_id);

    /* Bug 7639165 - Changes Begin. */
    BEGIN
      SELECT PC.INSTRUMENT_TYPE
      INTO l_instrument_type
      FROM AR_RECEIPT_METHODS RM,
           IBY_FNDCPT_PMT_CHNNLS_B PC
      WHERE RECEIPT_METHOD_ID = l_receipt_method_id
      AND RM.PAYMENT_CHANNEL_CODE = PC.PAYMENT_CHANNEL_CODE;

    EXCEPTION
      WHEN OTHERS THEN
	RAISE;
    END;

    IF nvl(l_instrument_type,'XXXXXX') = 'CREDITCARD' AND
       nvl(p_approve_flag,'N') = 'Y' THEN
       arp_debug.debug('Calling ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover');
       ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover(pg_request_id,'CREATION');
    END IF;
    /* Bug 7639165 - Changes End. */

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug ( 'Cleaning interim table  Rows deleted:'|| SQL%ROWCOUNT);
    END IF;
  END IF;

  arp_debug.debug (' FINALLY COMMITING WORK ');
  COMMIT;

  arp_debug.debug('get_parameters()-');

  IF G_ERROR = 'Y'  THEN
    P_RETCODE := 1;
  END IF;

  EXCEPTION
   WHEN l_batch_lock_excp THEN

     l_error_message := FND_MESSAGE.GET_STRING('AR','AR_UNABLE_LOCK_BATCH');

     IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', l_error_message) = FALSE)
     THEN
        arp_debug.debug('Unable to set WARNING return status');
     END IF;

     fnd_file.put_line( FND_FILE.LOG,
        'Not able to lock the batch record, '||
	'Please try submitting the request again..');

     arp_debug.debug('Exception : Not able to lock the batch record,seems record is '||
		   'already locked by other session ');
     arp_debug.debug('  batch_id = ' || o_batch_id );
     arp_debug.debug('  message: ' || l_batch_lock_msg);

   WHEN others THEN
    --incase of any exception thrown,cleanup the interim table as the next run will
    --anyway repopulate the needed data
    IF l_total_workers = 0
    THEN
      delete
      from ar_autorec_interim
      where batch_id = o_batch_id;

      IF p_approve_flag = 'Y'
      THEN
         /* release the lock */
         l_batch_lock_flag := ARP_RW_BATCHES_PKG.release_lock(o_batch_id ,l_batch_lock_msg);

         IF PG_DEBUG in ('Y','C')
         THEN
            arp_debug.debug('Releasing lock - ' || l_batch_lock_msg);
         END IF;
      END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('Exception : get_parameters() '|| SQLERRM);
    END IF;
    IF G_ERROR = 'Y'  THEN
      P_RETCODE := 1;
    END IF;

    RAISE;
END get_parameters;


/*========================================================================+
 |  PROCEDURE submit_autorec_parallel                                     |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | Wraper to parallelize the Automatic Receipts creation program          |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 30-NOV-2007              nproddut          Created                     |
 *=========================================================================*/
PROCEDURE submit_autorec_parallel(
                          P_ERRBUF                          OUT NOCOPY VARCHAR2,
			  P_RETCODE                         OUT NOCOPY NUMBER,
			  p_process_type                    IN VARCHAR2,
			  p_batch_date                      IN VARCHAR2,
			  p_batch_gl_date                   IN VARCHAR2,
			  p_create_flag                     IN VARCHAR2,
			  p_approve_flag                    IN VARCHAR2,
			  p_format_flag                     IN VARCHAR2,
			  p_batch_id                        IN VARCHAR2,
			  p_debug_mode_on                   IN VARCHAR2,
			  p_batch_currency                  IN VARCHAR2,
			  p_exchange_date                   IN VARCHAR2,
			  p_exchange_rate                   IN VARCHAR2,
			  p_exchange_rate_type              IN VARCHAR2,
			  p_remit_method_code               IN VARCHAR2,
			  p_receipt_class_id                IN VARCHAR2,
			  p_payment_method_id               IN VARCHAR2,
			  p_media_reference                 IN VARCHAR2,
			  p_remit_bank_branch_id            IN VARCHAR2,
			  p_remit_bank_account_id           IN VARCHAR2,
			  p_remit_bank_deposit_number       IN VARCHAR2,
			  p_comments                        IN VARCHAR2,
			  p_trx_date_l                      IN VARCHAR2,
			  p_trx_date_h                      IN VARCHAR2,
			  p_due_date_l                      IN VARCHAR2,
			  p_due_date_h                      IN VARCHAR2,
			  p_trx_num_l                       IN VARCHAR2,
			  p_trx_num_h                       IN VARCHAR2,
			  p_doc_num_l                       IN VARCHAR2,
			  p_doc_num_h                       IN VARCHAR2,
			  p_customer_number_l               IN VARCHAR2,
			  p_customer_number_h               IN VARCHAR2,
			  p_customer_name_l                 IN VARCHAR2,
			  p_customer_name_h                 IN VARCHAR2,
			  p_customer_id                     IN VARCHAR2,
			  p_site_l                          IN VARCHAR2,
			  p_site_h                          IN VARCHAR2,
			  p_site_id                         IN VARCHAR2,
			  p_remittance_total_from           IN VARCHAR2,
			  p_Remittance_total_to             IN VARCHAR2,
			  p_billing_number_l                IN VARCHAR2,
			  p_billing_number_h                IN VARCHAR2,
			  p_customer_bank_acc_num_l         IN VARCHAR2,
			  p_customer_bank_acc_num_h         IN VARCHAR2,
                          p_total_workers                   IN NUMBER default 1 ) AS

   l_worker_number              NUMBER ;
   l_complete			BOOLEAN := FALSE;

  l_request_id                  ar_cash_receipts.request_id%TYPE;
  l_gl_date                     ar_cash_receipt_history.gl_date%TYPE;
  l_batch_date                  ar_cash_receipts.receipt_date%TYPE ;
  l_receipt_class_id            ar_receipt_classes.receipt_class_id%TYPE ;
  l_receipt_method_id           ar_cash_receipts.receipt_method_id%TYPE ;
  l_currency_code               ar_cash_receipts.currency_code%TYPE;
  l_approve_flag                ar_cash_receipts.confirmed_flag%TYPE ;
  l_format_flag                 ar_cash_receipts.confirmed_flag%TYPE ;
  l_create_flag                 ar_cash_receipts.confirmed_flag%TYPE ;
  l_approve_only_flag           ar_cash_receipts.confirmed_flag%TYPE;
  o_batch_id                    NUMBER;
  l_batch_lock_msg              VARCHAR2(200);
  l_batch_lock_flag             BOOLEAN;
  l_batch_lock_excp             EXCEPTION;
  l_batch_app_status            ar_batches.batch_applied_status%TYPE;

  /* Bug 7639165 - Declaration Begin. */
  l_instrument_type	VARCHAR2(30);
  /* Bug 7639165 - Declaration End. */

  TYPE req_status_typ  IS RECORD (
  request_id       NUMBER(15),
  dev_phase        VARCHAR2(255),
  dev_status       VARCHAR2(255),
  message          VARCHAR2(2000),
  phase            VARCHAR2(255),
  status           VARCHAR2(255));
  l_org_id         NUMBER;

  TYPE req_status_tab_typ   IS TABLE OF req_status_typ INDEX BY BINARY_INTEGER;

  l_req_status_tab   req_status_tab_typ;

  PROCEDURE submit_subrequest (p_worker_number IN NUMBER,
			       p_org_id IN NUMBER) IS
  l_request_id  NUMBER;
  BEGIN
      arp_debug.debug('submit_subrequest()+');

      FND_REQUEST.SET_ORG_ID(p_org_id);

      l_request_id := FND_REQUEST.submit_request( 'AR', 'AR_AUTORECAPI',
				      '',
				      SYSDATE,
				      FALSE,
				      p_process_type ,
				      p_batch_date ,
				      p_batch_gl_date ,
				      p_create_flag ,
				      p_approve_flag ,
				      p_format_flag,
				      to_char(o_batch_id) ,
				      p_debug_mode_on ,
				      p_batch_currency,
				      p_exchange_date,
				      p_exchange_rate,
				      p_exchange_rate_type ,
				      p_remit_method_code,
				      p_receipt_class_id,
				      p_payment_method_id,
				      p_media_reference,
				      p_remit_bank_branch_id,
				      p_remit_bank_account_id,
				      p_remit_bank_deposit_number,
				      p_comments,
				      p_trx_date_l,
				      p_trx_date_h,
				      p_due_date_l,
				      p_due_date_h,
				      p_trx_num_l,
				      p_trx_num_h,
				      p_doc_num_l,
				      p_doc_num_h,
				      p_customer_number_l,
				      p_customer_number_h,
				      p_customer_name_l,
				      p_customer_name_h,
				      p_customer_id,
				      p_site_l,
				      p_site_h,
				      p_site_id,
				      p_remittance_total_from,
				      p_Remittance_total_to,
				      p_billing_number_l,
				      p_billing_number_h,
				      p_customer_bank_acc_num_l,
				      p_customer_bank_acc_num_h,
				      p_worker_number,
				      p_total_workers );

      IF (pg_request_id = 0) THEN
	  arp_debug.debug('can not start for worker_id: ' ||p_worker_number );
	  P_ERRBUF := fnd_Message.get;
	  P_RETCODE := 2;
	  return;
      ELSE
	  commit;
	  arp_debug.debug('child request id: ' ||l_request_id || ' started for worker_id: ' ||p_worker_number );
      END IF;

       l_req_status_tab(p_worker_number).request_id := l_request_id;
       arp_debug.debug('submit_subrequest()-');

  END submit_subrequest;

BEGIN
  fnd_file.put_line( FND_FILE.LOG, 'submit_autorec_parallel()+');
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('ar_autorec_api.submit_autorec_parallel()+');
  END IF;

  l_gl_date           := fnd_date.canonical_to_date(p_batch_gl_date);
  l_batch_date        := fnd_date.canonical_to_date(p_batch_date);
  l_receipt_class_id  := to_number(p_receipt_class_id);
  l_receipt_method_id := to_number(p_payment_method_id);
  l_currency_code     := p_batch_currency;
  l_create_flag       := p_create_flag;
  l_approve_flag      := p_approve_flag;
  l_format_flag       := p_format_flag;

/* Bug 8903995 */
  pg_request_id             := arp_standard.profile.request_id;
  pg_last_updated_by        := arp_standard.profile.last_update_login ;
  pg_created_by             := arp_standard.profile.user_id ;
  pg_last_update_login      := arp_standard.profile.last_update_login ;
  pg_program_application_id := arp_standard.application_id ;
  pg_program_id             := arp_standard.profile.program_id;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('pg_request_id             ' || pg_request_id);
    arp_debug.debug('pg_last_updated_by        ' || pg_last_updated_by);
    arp_debug.debug('pg_created_by             ' || pg_created_by);
    arp_debug.debug('pg_last_update_login      ' || pg_last_update_login);
    arp_debug.debug('pg_program_application_id ' || pg_program_application_id);
    arp_debug.debug('pg_program_id             ' || pg_program_id);
    arp_debug.debug('l_gl_date                 ' ||l_gl_date);
    arp_debug.debug('l_batch_date              ' ||l_batch_date);
    arp_debug.debug('l_receipt_class_id        ' ||l_receipt_class_id);
    arp_debug.debug('l_receipt_method_id       ' ||l_receipt_method_id);
    arp_debug.debug('l_currency_code           ' ||l_currency_code);
    arp_debug.debug('l_create_flag             ' ||l_create_flag);
    arp_debug.debug('l_approve_flag            ' ||l_approve_flag);
    arp_debug.debug('l_format_flag             ' ||l_format_flag);
    arp_debug.debug('p_batch_id                ' ||p_batch_id);
  END IF;

  IF p_batch_id IS NOT NULL THEN
     l_approve_only_flag := 'A';
  ELSIF ( p_create_flag = 'N' AND p_approve_flag = 'Y' AND p_format_flag = 'N') THEN
    l_approve_only_flag := 'A';
  ELSE
    l_approve_only_flag := 'N';
  END IF;

  --Create a batch if the batch id is null
  IF p_batch_id is NULL THEN
      insert_batch(l_gl_date,
		   l_batch_date,
		   l_receipt_class_id,
		   l_receipt_method_id,
		   l_currency_code,
		   l_approve_flag,
		   l_format_flag,
		   l_create_flag,
		   o_batch_id
		   );
  ELSE
    o_batch_id := p_batch_id;
  END IF;

  --Error condition
  IF o_batch_id IS NULL THEN
      arp_debug.debug( 'This is an error condition');
      insert_exceptions( p_batch_id => -333,
			p_request_id =>pg_request_id,
			p_exception_code => 'NO_BATCH',
			p_additional_message => 'error during insert batch' );

      arp_debug.debug ( 'calling the report- batch_id  ' || -333 );
      arp_debug.debug ( 'calling the report ' || pg_request_id);

      submit_report ( p_batch_id => o_batch_id,
		     p_request_id => pg_request_id);
      RETURN;
  END IF;

  /*lock the batch record to prevent multiple submissions for the same batch while a request
    is running.In case the request is spanned from master process,master will hold the lock*/
  l_batch_lock_flag := ARP_RW_BATCHES_PKG.request_lock(o_batch_id ,l_batch_lock_msg);

  IF l_batch_lock_flag = FALSE THEN
    RAISE l_batch_lock_excp;
  END IF;

  --fetch org id,need to set it for child requests
  l_org_id      := mo_global.get_current_org_id;
  pg_request_id  := arp_standard.profile.request_id;


  IF p_approve_flag = 'Y' THEN
    BEGIN
      SELECT batch_applied_status
      INTO l_batch_app_status
      FROM ar_batches
      WHERE batch_id = o_batch_id;
    EXCEPTION
       WHEN OTHERS THEN
          NULL;
    END;

   IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('l_batch_app_status :'||l_batch_app_status);
   END IF;

   IF l_batch_app_status = 'STARTED_APPROVAL' THEN
      process_incomplete_receipts( o_batch_id );
    END IF;

    select_valid_invoices
       (  p_trx_date_l =>fnd_date.canonical_to_date(p_trx_date_l),
	  p_trx_date_h =>fnd_date.canonical_to_date(p_trx_date_h),
	  p_due_date_l =>fnd_date.canonical_to_date(p_due_date_l),
	  p_due_date_h =>fnd_date.canonical_to_date(p_due_date_h),
	  p_trx_num_l =>p_trx_num_l,
	  p_trx_num_h => p_trx_num_h,
	  p_doc_num_l =>p_doc_num_l,
	  p_doc_num_h => p_doc_num_h,
	  p_customer_number_l => p_customer_number_l,
	  p_customer_number_h => p_customer_number_h,
	  p_customer_name_l => p_customer_name_l,
	  p_customer_name_h => p_customer_name_h,
	  p_batch_id => o_batch_id,
	  p_approve_only_flag => l_approve_only_flag,
	  p_receipt_method_id => l_receipt_method_id,
	  p_total_workers => p_total_workers
	   );
  END IF;

  IF p_approve_flag = 'Y' AND
     NVL(l_batch_app_status,'NONE') <> 'STARTED_APPROVAL' THEN
      UPDATE ar_batches
      SET batch_applied_status = 'STARTED_APPROVAL'
      WHERE batch_id = o_batch_id;

  ELSIF p_create_flag = 'Y' THEN
      UPDATE ar_batches
      SET batch_applied_status = 'COMPLETED_CREATION'
      WHERE batch_id = o_batch_id;
  END IF;

  COMMIT;

  IF p_approve_flag = 'Y' THEN
    --Invoke the child programs
    FOR l_worker_number IN 1..p_total_workers LOOP
	fnd_file.put_line(FND_FILE.LOG,'worker # : ' || l_worker_number );
	submit_subrequest (l_worker_number,l_org_id);
    END LOOP;

    arp_debug.debug ( 'The Master program waits for child processes');

    P_RETCODE := 0;

    -- Wait for the completion of the submitted requests
    FOR i in 1..p_total_workers LOOP
	l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
		   request_id   => l_req_status_tab(i).request_id,
		   interval     => 30,
		   max_wait     =>144000,
		   phase        =>l_req_status_tab(i).phase,
		   status       =>l_req_status_tab(i).status,
		   dev_phase    =>l_req_status_tab(i).dev_phase,
		   dev_status   =>l_req_status_tab(i).dev_status,
		   message      =>l_req_status_tab(i).message);

	IF l_req_status_tab(i).dev_phase <> 'COMPLETE' THEN
	    P_RETCODE := 1;
	    arp_debug.debug('Worker # '|| i||' has a phase '||l_req_status_tab(i).dev_phase);

	ELSIF l_req_status_tab(i).dev_phase = 'COMPLETE'
	       AND l_req_status_tab(i).dev_status <> 'NORMAL' THEN
	    P_RETCODE := 1;
	    arp_debug.debug('Worker # '|| i||' completed with status '||l_req_status_tab(i).dev_status);
	ELSE
	    arp_debug.debug('Worker # '|| i||' completed successfully');
	END IF;
    END LOOP;

    IF P_RETCODE = 0  THEN
      UPDATE ar_batches
      SET batch_applied_status = 'COMPLETED_APPROVAL'
      WHERE batch_id = o_batch_id;
    END IF;
  END IF;

  IF l_format_flag = 'Y' THEN
      arp_debug.debug('calling the report- batch_id  format  ' || o_batch_id);
      submit_format ( p_batch_id =>o_batch_id);
  END IF;

  submit_report ( p_batch_id =>o_batch_id,
		  p_request_id => pg_request_id);

  /* Bug 7639165 - Changes Begin. */
  BEGIN
    SELECT PC.INSTRUMENT_TYPE
    INTO l_instrument_type
    FROM AR_RECEIPT_METHODS RM,
       IBY_FNDCPT_PMT_CHNNLS_B PC
    WHERE RECEIPT_METHOD_ID = l_receipt_method_id
    AND RM.PAYMENT_CHANNEL_CODE = PC.PAYMENT_CHANNEL_CODE;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  IF nvl(l_instrument_type,'XXXXXX') = 'CREDITCARD' AND
     nvl(p_approve_flag,'N') = 'Y' THEN
     arp_debug.debug('Calling ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover');
     ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover(pg_request_id,'CREATION');
  END IF;
  /* Bug 7639165 - Changes End. */

  commit;

  --cleanup interim table
  delete
  from ar_autorec_interim
  where batch_id = o_batch_id;

  l_batch_lock_flag := ARP_RW_BATCHES_PKG.release_lock( o_batch_id, l_batch_lock_msg);

  fnd_file.put_line( FND_FILE.LOG, 'submit_autorec_parallel()-');

  EXCEPTION
    WHEN OTHERS THEN
      --incase of any exception thrown,cleanup the interim table as the next run will
      --anyway repopulate the needed data
      delete
      from ar_autorec_interim
      where batch_id = o_batch_id;

      --release the lock on batch record
      l_batch_lock_flag :=
         ARP_RW_BATCHES_PKG.release_lock(o_batch_id ,l_batch_lock_msg);

      IF PG_DEBUG in ('Y','C')
      THEN
         arp_debug.debug('Releasing lock - ' || l_batch_lock_msg);
      END IF;

      RAISE ;
END submit_autorec_parallel;

/*========================================================================+
 |  PROCEDURE insert_batch                                                |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to insert the batch record when called from   |
 |   srs. It also gets the other required parameters from sysparm         |
 |   and conc program                                                     |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/


PROCEDURE insert_batch(
      p_gl_date                          IN  ar_cash_receipt_history.gl_date%TYPE DEFAULT NULL,
      p_batch_date                       IN  ar_cash_receipts.receipt_date%TYPE DEFAULT NULL,
      p_receipt_class_id                 IN  ar_receipt_classes.receipt_class_id%TYPE DEFAULT NULL,
      p_receipt_method_id                IN  ar_cash_receipts.receipt_method_id%TYPE DEFAULT NULL,
      p_currency_code                    IN  ar_cash_receipts.currency_code%TYPE DEFAULT NULL,
      p_approve_flag                     IN  ar_cash_receipts.confirmed_flag%TYPE DEFAULT NULL,
      p_format_flag                      IN  ar_cash_receipts.confirmed_flag%TYPE DEFAULT NULL,
      p_create_flag                      IN  ar_cash_receipts.confirmed_flag%TYPE DEFAULT NULL,
      p_batch_id                         OUT NOCOPY NUMBER
      ) IS
  l_batch_rec             ar_batches%ROWTYPE;
  l_row_id                VARCHAR2(50);
  l_batch_id              NUMBER := NULL;
  l_request_id            NUMBER;
  l_batch_name            VARCHAR2(30);
  l_batch_applied_status  VARCHAR2(30);
  l_bank_account_id_low   NUMBER;
  l_bank_account_id_high  NUMBER;
  l_call_conc_request     VARCHAR2(30);
  batch_id                VARCHAR2(30);
  psite_required          VARCHAR2(2);
  pinvoices_per_commit    NUMBER;
  preceipts_per_commit    NUMBER;
  pfunctional_currency    VARCHAR2(20);
  pacc_method             VARCHAR2(20);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('insert_batch()+');
    arp_debug.debug('p_gl_date           '||p_gl_date);
    arp_debug.debug('batch_date          '||p_batch_date);
    arp_debug.debug('p_receipt_method_id '|| to_char(p_receipt_method_id));
    arp_debug.debug('p_receipt_class_id  '|| to_char(p_receipt_class_id));
    arp_debug.debug('p_currency_code     '||p_currency_code);
    arp_debug.debug('p_approve_flag      '||p_approve_flag);
    arp_debug.debug('p_format_flag       '||p_format_flag);
    arp_debug.debug('p_create_flag       '||p_create_flag);
  END IF;

  /* insert the batch record here */
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('autorecapi calling auto_batch ()+');
  END IF;

  l_batch_rec.receipt_class_id   := to_number(p_receipt_class_id);
  l_batch_rec.receipt_method_id  := to_number(p_receipt_method_id);
  l_batch_rec.batch_date         := to_date(p_batch_date,'DD/MM/YY');
  l_batch_rec.gl_date            := to_date(p_gl_date,'DD/MM/YY');
  l_batch_rec.currency_code      := p_currency_code;
  l_batch_rec.comments           := null;
  l_batch_rec.exchange_date      := null;
  l_batch_rec.exchange_rate      := null;
  l_batch_rec.exchange_rate_type := null;

  arp_rw_batches_pkg.insert_auto_batch(
		   l_row_id,
		   l_batch_id,
		   l_batch_rec.batch_date,
		   l_batch_rec.currency_code,
		   l_batch_name, --out
		   l_batch_rec.comments,
		   l_batch_rec.exchange_date,
		   l_batch_rec.exchange_rate,
		   l_batch_rec.exchange_rate_type,
		   l_batch_rec.gl_date,
		   l_batch_rec.media_reference,
		   l_batch_rec.receipt_class_id,
		   l_batch_rec.receipt_method_id,
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
		   l_call_conc_request,
		   l_batch_applied_status, --Out
		   l_request_id,--OUT
		   'AUTORECSRS',
		   '1.0',
		   l_bank_account_id_low,
		   l_bank_account_id_high
		   );

  p_batch_id := to_char(l_batch_id);

  IF p_batch_id IS NULL THEN
    arp_debug.debug ('WAIT HERE THE VALUE OF BATCH_ID IS NULL ERROR');
    G_ERROR := 'Y';
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('value of batch_id '||p_batch_id);
    arp_debug.debug('value of l_request_id '||l_request_id);
    arp_debug.debug('value of pg_request_id '||pg_request_id);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('autorecapi calling auto_batch  end ()-');
  END IF;
  /* inserted the batch record end */

  /* GET THE VALUES from SYSTEM PARAMETERS */
  IF PG_DEBUG in ('Y','C') THEN
    arp_debug.debug( 'get info from system parameters');
  END IF;

  BEGIN
    SELECT asp.site_required_flag,
	asp.auto_rec_invoices_per_commit,
	asp.auto_rec_receipts_per_commit,
	gsob.currency_code,
	asp.accounting_method
    INTO psite_required,
	pinvoices_per_commit,
	preceipts_per_commit,
	pfunctional_currency,
	pacc_method
    FROM ar_system_parameters asp,
	gl_sets_of_books gsob,
	ar_batches ab
    WHERE ab.batch_id = p_batch_id
    AND ab.set_of_books_id = gsob.set_of_books_id
    AND gsob.set_of_books_id = asp.set_of_books_id;

  EXCEPTION
    WHEN no_data_found THEN
      arp_debug.debug( 'ERROR NO DATA FOUND IN SYSTEM OPTION');
      G_ERROR := 'Y';
  END;

  IF PG_DEBUG in ('Y', 'C') THEN
   arp_debug.debug ( 'site_req_flag            ' || psite_required);
   arp_debug.debug ( 'the invoices per commit  ' || pinvoices_per_commit);
   arp_debug.debug ( 'receipts per_commit      ' || preceipts_per_commit);
   arp_debug.debug ( 'currency code            ' || pfunctional_currency);
   arp_debug.debug ( 'acc_method               ' || pacc_method );
  END IF;

  /* END FROM SYSTEM PARAMETERS*/
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('insert_batch()-');
  END IF;

  EXCEPTION
    WHEN others THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	 arp_debug.debug('Exception : insert_batch() ');
      END IF;
      G_ERROR := 'Y';
END insert_batch;

/*========================================================================+
 | PUBLIC PROCEDURE SELECT_VALID_INVOICES                                 |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select the valied invoices and insert them |
 |   into the GT table AR_RECEIPTS_GT                                     |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/

PROCEDURE select_valid_invoices(
                                p_trx_date_l                     IN ar_payment_schedules.trx_date%TYPE,
                                p_trx_date_h                     IN ar_payment_schedules.trx_date%TYPE,
                                p_due_date_l                     IN ar_payment_schedules.due_date%TYPE,
                                p_due_date_h                     IN ar_payment_schedules.due_date%TYPE,
                                p_trx_num_l                      IN ar_payment_schedules.trx_number%TYPE,
                                p_trx_num_h                      IN ar_payment_schedules.trx_number%TYPE,
                                p_doc_num_l                      IN ra_customer_trx.doc_sequence_value%TYPE,
                                p_doc_num_h                      IN ra_customer_trx.doc_sequence_value%TYPE,
				p_customer_number_l		 IN hz_cust_accounts.account_number%TYPE,  --Bug6734688
				p_customer_number_h		 IN hz_cust_accounts.account_number%TYPE,  --Bug6734688
				p_customer_name_l		 IN hz_parties.party_name%TYPE,  --Bug6734688
				p_customer_name_h		 IN hz_parties.party_name%TYPE,  --Bug6734688
                                p_batch_id                       IN ar_batches.batch_id%TYPE,
				p_approve_only_flag              IN VARCHAR2 ,--Bug5344405
                                p_receipt_method_id              IN ar_receipt_methods.receipt_method_id%TYPE,
                                p_total_workers                  IN NUMBER DEFAULT 1
                                 ) IS

      trx_invoices                INTEGER;
      l_rows_processed            INTEGER;
      l_rows_fetched              INTEGER;
      l_sel_stmt                  long;
      p_lead_days                 NUMBER;
      p_batch_date                DATE;
      p_creation_rule             ar_receipt_methods.receipt_creation_rule_code%TYPE;
      p_currency_code             VARCHAR2(20);

      l_total_workers             NUMBER;

   -- insert variables
      inst_stmt                   varchar2(1000);
      ps_id_array                 dbms_sql.NUmber_Table;
      trx_id_array                dbms_sql.NUmber_Table;
      cr_id_array                 dbms_sql.Number_Table;
      paying_customer_id_array    dbms_sql.Number_Table;
      paying_site_use_id_array    dbms_sql.Number_Table;
      due_date_array              dbms_sql.date_Table;
      adr_array                   dbms_sql.Number_Table;
      cust_bank_acct_id_array     dbms_sql.Number_Table;
      cust_min_amt_array          dbms_sql.Number_Table;
      pmt_trxn_ext_id_array       dbms_sql.Number_Table;
      pmt_channel_array           dbms_sql.varchar2_Table;
      pmt_instrument_type_array   dbms_sql.varchar2_Table;
      rec_t                       number;
      dummy                       number;
      i                           number;

BEGIN

   --- Print the parameters in the debug file
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('select_valid_invoices start ()+');
     arp_debug.debug(  'p_batch_id          '||p_batch_id);
     arp_debug.debug(  'p_trx_date_l        '||p_trx_date_l);
     arp_debug.debug(  'p_trx_date_h        '||p_trx_date_h);
     arp_debug.debug(  'p_due_date_l        '||p_due_date_l);
     arp_debug.debug(  'p_due_date_h        '||p_due_date_h);
     arp_debug.debug(  'p_trx_num_l         '||p_trx_num_l);
     arp_debug.debug(  'p_trx_num_h         '||p_trx_num_h);
     arp_debug.debug(  'p_doc_num_l         '||p_doc_num_l);
     arp_debug.debug(  'p_doc_num_h         '||p_doc_num_h);
     arp_debug.debug(  'p_customer_number_l '||p_customer_number_l);
     arp_debug.debug(  'p_customer_number_h '||p_customer_number_h);
     arp_debug.debug(  'p_customer_name_l   '||p_customer_name_l);
     arp_debug.debug(  'p_customer_name_h   '||p_customer_name_h);
     arp_debug.debug(  'p_approve_only_flag '||p_approve_only_flag);
     arp_debug.debug(  'p_receipt_method_id '||p_receipt_method_id);
     arp_debug.debug(  'p_total_workers     '||p_total_workers);
  END IF;

  l_total_workers   := nvl(p_total_workers,1);

  SELECT b.currency_code,
       b.batch_date,
       r.lead_days,
       r.receipt_creation_rule_code
  INTO p_currency_code,
       p_batch_date,
       p_lead_days,
       p_creation_rule
  from ar_batches b,
       ar_receipt_methods r
  WHERE b.batch_id = p_batch_id
  AND   b.receipt_method_id = r.receipt_method_id
  AND   r.receipt_method_id = p_receipt_method_id;

   --- Print the parameters in the debug file
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(  'p_currency_code     '||p_currency_code);
     arp_debug.debug(  'p_batch_date        '||p_batch_date);
     arp_debug.debug(  'p_lead_days         '||p_lead_days);
     arp_debug.debug(  'p_receipt_method_id '||p_receipt_method_id);
     arp_debug.debug(  'p_batch_id          '||p_batch_id);
     arp_debug.debug(  'p_creation_rule     '||p_creation_rule);
     arp_debug.debug(  'l_total_workers     '||l_total_workers);
  END IF;

    -- Build the query dynamically based on the input parameters
    IF PG_PARALLEL IN ('Y', 'C') THEN
      l_sel_stmt := 'INSERT /*+ parallel(a) append */ into ar_autorec_interim a ';
    ELSE
      l_sel_stmt := 'INSERT into ar_autorec_interim a ';
    END IF;

    l_sel_stmt := l_sel_stmt ||
       ' SELECT /*+ leading(PS1) use_nl(ps,cust_cp,site_cp,cust_cpa,site_cpa,ct,x,u,p) rowid(ps) index_ffs(ps1) parallel_index(ps1) */
       '||p_batch_id||',
       ps.payment_schedule_id,
       ps.customer_trx_id,
       ps.cash_receipt_id,
       ct.paying_customer_id,
       ct.paying_site_use_id,
       ct.payment_trxn_extension_id,
       ps.due_date,
       AR_AUTOREC_API.Get_Invoice_Bal_After_Disc(ps.payment_schedule_id, greatest(:apply_date,ct.trx_date)) amount_due_remaining,
       ct.customer_bank_account_id,
       DECODE(:creation_rule,
              ''PER_CUSTOMER'', NVL(cust_cpa.auto_rec_min_receipt_amount,0),
              ''PER_CUSTOMER_DUE_DATE'', NVL(cust_cpa.auto_rec_min_receipt_amount,0),
              nvl(nvl(site_cpa.auto_rec_min_receipt_amount,cust_cpa.auto_rec_min_receipt_amount),0)),
       p.payment_channel_code,
       u.instrument_id,
       mod(ct.paying_customer_id,:l_total_workers) + 1  worker_id
       FROM   hz_customer_profiles cust_cp,
              hz_customer_profiles site_cp,
              hz_cust_profile_amts cust_cpa,
              hz_cust_profile_amts site_cpa,
              ra_customer_trx ct,
              IBY_FNDCPT_TX_EXTENSIONS X,
              IBY_PMT_INSTR_USES_ALL U,
              IBY_FNDCPT_PMT_CHNNLS_B P,
              ar_payment_schedules ps,
              ar_payment_schedules_all ps1 ';

    --Bug6734688
      IF p_customer_number_l IS NOT NULL OR p_customer_number_h IS NOT NULL
	 OR p_customer_name_l IS NOT NULL OR p_customer_name_h IS NOT NULL THEN
	   l_sel_stmt := l_sel_stmt|| ', hz_cust_accounts cust_acct ';

	IF p_customer_name_l IS NOT NULL OR p_customer_name_h IS NOT NULL THEN
	   l_sel_stmt := l_sel_stmt|| ', hz_parties party ';
	END IF;
      END IF;

    l_sel_stmt := l_sel_stmt ||   --Bug6734688
    '  WHERE  ps1.status                     = ''OP''
       AND    ps1.gl_date_closed             = TO_DATE(''4712/12/31'', ''YYYY/MM/DD'')
       AND    ps1.rowid = ps.rowid  ';

    --jyothi
       if p_approve_only_flag = 'A' then
         l_sel_stmt := l_sel_stmt|| ' AND    ps.selected_for_receipt_batch_id = :batch_id';
       else
	 l_sel_stmt := l_sel_stmt|| ' AND    ps.selected_for_receipt_batch_id  IS NULL ';
       end if;

      l_sel_stmt  := l_sel_stmt ||
      ' AND   ps1.due_date                 <= :batch_date + TO_NUMBER(:lead_days)
       AND    ps1.invoice_currency_code      = :currency_code
       AND    ps.customer_trx_id            = ct.customer_trx_id
       AND    ps.reserved_type             IS NULL
       AND    ps.reserved_value            IS NULL
       AND    ct.receipt_method_id          = TO_NUMBER(:receipt_method_id)
       AND    nvl(ct.cc_error_flag,''N'')    = ''N''
       AND    ct.paying_customer_id         = cust_cp.cust_account_id
--       AND    ct.payment_trxn_extension_id  = extn.trxn_extension_id
--       AND    extn.trxn_ref_number1   = ''TRANSACTION''  /*bug 5707963*/
--       AND    extn.trxn_ref_number2   = ct.customer_trx_id
       AND    ct.payment_trxn_extension_id = x.trxn_extension_id
       AND    x.instr_assignment_id = u.instrument_payment_use_id(+)
       AND    x.payment_channel_code = p.payment_channel_code
       AND    cust_cp.site_use_id           IS NULL
       AND    cust_cp.cust_account_profile_id  = cust_cpa.cust_account_profile_id(+)
       AND    cust_cpa.currency_code(+)     = :currency_code
       AND    ct.paying_site_use_id         = site_cp.site_use_id(+)
       AND    site_cp.cust_account_profile_id  = site_cpa.cust_account_profile_id(+)
       AND    site_cpa.currency_code(+)     = :currency_code
       AND    ( NVL(ps.amount_in_dispute,0) = 0
               OR
              ( NVL(ps.amount_in_dispute,0)  != 0
               AND
               NVL(site_cp.auto_rec_incl_disputed_flag,cust_cp.auto_rec_incl_disputed_flag) = ''Y'')
               )
               ';


  IF p_trx_num_l IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' and ps1.trx_number >= :trx_num_l ';
  END IF;

  IF p_trx_num_h IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' and ps1.trx_number <= :trx_num_h ';
  END IF;

  IF p_due_date_l IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' and ps1.due_date >= :due_date_l ';
  END IF;

  IF p_due_date_h IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' and ps1.due_date <= :due_date_h ';
  END IF;

  IF p_doc_num_l IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' and ct.doc_sequence_value >= :doc_num_l ';
  END IF;

  IF p_doc_num_h IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' and ct.doc_sequence_value <= :doc_num_h ';
  END IF;

  IF p_trx_date_l IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' and ps1.trx_date >= :trx_date_l ';
  END IF;

  IF p_trx_date_h IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' and ps1.trx_date <= :trx_date_h ';
  END IF;

  --Bug6734688
  IF p_customer_number_l IS NOT NULL OR p_customer_number_h IS NOT NULL
     OR p_customer_name_l IS NOT NULL OR p_customer_name_h IS NOT NULL THEN

     l_sel_stmt := l_sel_stmt || ' and cust_acct.cust_account_id = ct.paying_customer_id ' ;

     IF p_customer_name_l IS NOT NULL OR p_customer_name_h IS NOT NULL THEN
	l_sel_stmt := l_sel_stmt || ' and cust_acct.party_id = party.party_id ' ;
     END IF;

     IF p_customer_number_l IS NOT NULL THEN
        l_sel_stmt := l_sel_stmt || ' and cust_acct.account_number >= :customer_number_l ';
     END IF ;
     IF p_customer_number_h IS NOT NULL THEN
        l_sel_stmt := l_sel_stmt || ' and cust_acct.account_number <= :customer_number_h ';
     END IF;

     IF p_customer_name_l IS NOT NULL THEN
        l_sel_stmt := l_sel_stmt || ' and party.party_name >= :customer_name_l ';
     END IF ;
     IF p_customer_name_h IS NOT NULL THEN
        l_sel_stmt := l_sel_stmt || ' and party.party_name <= :customer_name_h ';
     END IF;

  END IF ;
  --Bug6734688, end.
  --l_sel_stmt := l_sel_stmt || ' FOR UPDATE OF ps.selected_for_receipt_batch_id ';

 trx_invoices := dbms_sql.open_cursor;

 dbms_sql.parse (trx_invoices,l_sel_stmt,dbms_sql.v7);

 IF p_approve_only_flag = 'A' THEN
   dbms_sql.bind_variable (trx_invoices,':batch_id',p_batch_id);
 END IF;

 dbms_sql.bind_variable (trx_invoices,':batch_date',p_batch_date);
 dbms_sql.bind_variable (trx_invoices,':lead_days',p_lead_days);
 dbms_sql.bind_variable (trx_invoices,':currency_code',p_currency_code);
 dbms_sql.bind_variable (trx_invoices,':currency_code',p_currency_code);
 dbms_sql.bind_variable (trx_invoices,':currency_code',p_currency_code);
 dbms_sql.bind_variable (trx_invoices,':receipt_method_id',p_receipt_method_id);
 dbms_sql.bind_variable (trx_invoices,':creation_rule',p_creation_rule);
 dbms_sql.bind_variable (trx_invoices,':apply_date',p_batch_date);

  IF p_trx_num_l IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':trx_num_l',p_trx_num_l);
  END IF;

  IF p_trx_num_h IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':trx_num_h',p_trx_num_h);
  END IF;

  IF p_due_date_l IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':due_date_l',p_due_date_l);
  END IF;
  IF p_due_date_h IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':due_date_h',p_due_date_h);
  END IF;

  IF p_trx_date_l IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':trx_date_l',p_trx_date_l);
  END IF;
  IF p_trx_date_h IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':trx_date_h',p_trx_date_h);
  END IF;

  IF p_doc_num_l IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':doc_num_l',p_doc_num_l);
  END IF;
  IF p_doc_num_h IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':doc_num_h',p_doc_num_h);
  END IF;

  --Bug6734688
  IF p_customer_number_l IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':customer_number_l',p_customer_number_l);
  END IF;
  IF p_customer_number_h IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':customer_number_h',p_customer_number_h);
  END IF;

  IF p_customer_name_l IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':customer_name_l',p_customer_name_l);
  END IF;
  IF p_customer_name_h IS NOT NULL THEN
    dbms_sql.bind_variable (trx_invoices,':customer_name_h',p_customer_name_h);
  END IF;
  --Bug6734688, end.

 dbms_sql.bind_variable (trx_invoices,':l_total_workers',l_total_workers);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug( 'the select statement ' || l_sel_stmt);
  END IF;

  BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'PG_PARALLEL  ' || PG_PARALLEL);
    END IF;

    --Enable parallel DML at the session level if the profile is set
    IF PG_PARALLEL IN ('Y', 'C') THEN
      COMMIT;
      EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
    END IF;

    l_rows_processed := dbms_sql.execute( trx_invoices );

    IF PG_PARALLEL IN ('Y', 'C') THEN
      COMMIT; /* Bug 8249909 */
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('Number of invoices selected : '||l_rows_processed);
    END IF;

    dbms_sql.close_cursor( trx_invoices);

    IF p_approve_only_flag = 'N' THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('Stamping batch_id to PS : '||l_rows_processed);
      END IF;
      update ar_payment_schedules
      set selected_for_receipt_batch_id = p_batch_id
      where payment_schedule_id  in
      ( select /*+ cardinality(a 10) */
	    payment_schedule_id
	from ar_autorec_interim a
	where batch_id = p_batch_id);

      IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('Number of PS records stamped : '||SQL%ROWCOUNT);
      END IF;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      G_ERROR := 'Y';
      dbms_sql.close_cursor( trx_invoices);
      IF PG_DEBUG in ('Y', 'C') THEN
	 arp_debug.debug('Exception : select_valid_invoices() '|| SQLERRM);
	 arp_debug.debug('Error while executing>' || l_sel_stmt);
      END IF;
      RAISE; /* Bug 8249909 */
  END;

EXCEPTION
 WHEN others THEN
    G_ERROR := 'Y';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(' Exception : select_valid_invoices '|| SQLERRM);
     arp_debug.debug( 'the select statement ' || l_sel_stmt);
  END IF;
  RAISE; -- Changed as per Bug:5331158 for returning the error to environment

END select_valid_invoices;


FUNCTION Get_Invoice_Bal_After_Disc( p_applied_payment_schedule_id  IN  NUMBER,
		                     p_apply_date                   IN  DATE ) RETURN NUMBER IS

	l_return_status              VARCHAR2(200);
	l_discount_max_allowed       NUMBER;
        l_discount_earned_allowed    NUMBER;
        l_discount_earned            NUMBER;
        l_discount_unearned          NUMBER;
        l_new_amount_due_remaining   NUMBER;
	l_amount_to_be_applied       NUMBER;
        l_discount                   NUMBER;

        l_customer_id                 NUMBER;
        l_bill_to_site_use_id         NUMBER;
        l_applied_payment_schedule_id NUMBER;
        l_term_id                     NUMBER;
        l_installment                 NUMBER;
        l_trx_date                    DATE;
	l_apply_date                  DATE;
        l_amount_due_original         NUMBER;
        l_amount_due_remaining        NUMBER;
	l_trx_currency_code           VARCHAR2(10);
	l_discount_taken_unearned     NUMBER;
        l_discount_taken_earned       NUMBER;
	l_trx_exchange_rate           NUMBER;
	l_allow_overappln_flag        VARCHAR2(2);

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	  arp_debug.debug( 'Get_Invoice_Bal_After_Disc()+' );
	  arp_debug.debug( 'p_applied_payment_schedule_id :-' || p_applied_payment_schedule_id );
	  arp_debug.debug( 'p_apply_date :-'                  || p_apply_date );
	END IF;

	l_applied_payment_schedule_id := p_applied_payment_schedule_id;
	l_apply_date                  := p_apply_date;

	select ps.customer_id,
	       ps.customer_site_use_id,
	       ps.term_id,
	       ps.terms_sequence_number,
	       ps.trx_date,
	       ps.amount_due_original,
	       ps.amount_due_remaining,
	       ps.invoice_currency_code,
	       ps.discount_taken_unearned,
	       ps.discount_taken_earned,
	       ps.exchange_rate,
	       ctt.allow_overapplication_flag
	into
		l_customer_id,
		l_bill_to_site_use_id,
		l_term_id,
		l_installment,
		l_trx_date,
		l_amount_due_original,
		l_amount_due_remaining,
		l_trx_currency_code,
		l_discount_taken_unearned,
		l_discount_taken_earned,
		l_trx_exchange_rate,
		l_allow_overappln_flag
	from ar_payment_schedules ps,
	     ra_cust_trx_types ctt
	where ps.payment_schedule_id  = l_applied_payment_schedule_id
	      AND ps.cust_trx_type_id = ctt.cust_trx_type_id;

	ar_receipt_lib_pvt.Default_disc_and_amt_applied(
           p_customer_id                 => l_customer_id,
           p_bill_to_site_use_id         => l_bill_to_site_use_id,
           p_applied_payment_schedule_id => l_applied_payment_schedule_id,
           p_term_id                     => l_term_id,
           p_installment                 => l_installment,
           p_trx_date                    => l_trx_date,
	   p_apply_date                  => l_apply_date,
           p_amount_due_original         => l_amount_due_original,
           p_amount_due_remaining        => l_amount_due_remaining,
	   p_trx_currency_code           => l_trx_currency_code,
	   p_allow_overappln_flag        => l_allow_overappln_flag,
	   p_discount_taken_unearned     => l_discount_taken_unearned,
           p_discount_taken_earned       => l_discount_taken_earned,
	   p_trx_exchange_rate           => l_trx_exchange_rate,
           p_cr_date                     => NULL,
           p_cr_currency_code            => NULL,
           p_cr_exchange_rate            => NULL,
           p_cr_unapp_amount             => NULL,
           p_calc_discount_on_lines_flag => NULL,
           p_partial_discount_flag       => NULL,
           p_amount_line_items_original  => NULL,
           p_customer_trx_line_id        => NULL,
           p_trx_line_amount             => NULL,
           p_llca_type                   => NULL,
	   p_amount_applied              => l_amount_to_be_applied,
           p_discount                    => l_discount,
           p_discount_max_allowed        => l_discount_max_allowed,
           p_discount_earned_allowed     => l_discount_earned_allowed,
           p_discount_earned             => l_discount_earned,
           p_discount_unearned           => l_discount_unearned,
           p_new_amount_due_remaining    => l_new_amount_due_remaining,
           p_return_status               => l_return_status
        );

	IF PG_DEBUG in ('Y', 'C') THEN
	  arp_debug.debug( 'l_amount_to_be_applied           :- '|| l_amount_to_be_applied );
	  arp_debug.debug( 'l_discount                 :- '|| l_discount );
	  arp_debug.debug( 'l_discount_max_allowed     :- '|| l_discount_max_allowed );
	  arp_debug.debug( 'l_discount_earned_allowed  :- '|| l_discount_earned_allowed );
	  arp_debug.debug( 'l_discount_earned          :- '|| l_discount_earned );
	  arp_debug.debug( 'l_discount_unearned        :- '|| l_discount_unearned );
	  arp_debug.debug( 'l_new_amount_due_remaining :- '|| l_new_amount_due_remaining );
	  arp_debug.debug( 'l_return_status            :- '|| l_return_status );
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	  arp_debug.debug( 'Get_Invoice_Bal_After_Disc()-' );
	END IF;

	RETURN l_amount_to_be_applied;

EXCEPTION
	WHEN OTHERS THEN
		l_return_status := 'E';
		IF PG_DEBUG in ('Y', 'C') THEN
		  arp_debug.debug( 'l_return_status :- '|| l_return_status );
		  arp_debug.debug( 'Exception in Get_Invoice_Bal_After_Disc()!!!' );
		END IF;
		RAISE;
END Get_Invoice_Bal_After_Disc;


/*========================================================================+
 |  PROCEDURE insert_exceptions                                           |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to insert the exception record when           |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/
PROCEDURE insert_exceptions(
             p_batch_id               IN  ar_batches.batch_id%TYPE DEFAULT NULL,
             p_request_id             IN  ar_cash_receipts.request_id%TYPE DEFAULT NULL,
             p_cash_receipt_id        IN  ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
             p_payment_schedule_id    IN  ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL,
             p_paying_customer_id     IN  ar_cash_receipts.pay_from_customer%TYPE DEFAULT NULL,
             p_paying_site_use_id     IN  ar_cash_receipts.customer_site_use_id%TYPE DEFAULT NULL,
             p_due_date               IN  ar_payment_schedules.due_date%TYPE DEFAULT NULL,
             p_cust_min_rec_amount    IN  NUMBER DEFAULT NULL,
             p_bank_min_rec_amount    IN NUMBER DEFAULT NULL,
             p_exception_code         IN VARCHAR2,
             p_additional_message     IN VARCHAR2
             ) IS

  l_paying_customer_id      NUMBER;
  l_reqid                   NUMBER;

BEGIN

  IF PG_DEBUG in ('Y','C') THEN
    arp_debug.debug('insert_exceptions()+');
    arp_debug.debug('p_batch_id            '|| p_batch_id);
    arp_debug.debug('p_request_id          '|| p_request_id);
    arp_debug.debug('p_cash_receipt_id     '|| p_cash_receipt_id);
    arp_debug.debug('p_payment_schedule_id '|| p_payment_schedule_id);
    arp_debug.debug('p_paying_customer_id  '|| p_paying_customer_id);
    arp_debug.debug('p_paying_site_use_id  '|| p_paying_site_use_id);
    arp_debug.debug('p_due_date            '|| p_due_date);
    arp_debug.debug('p_cust_min_rec_amount '|| p_cust_min_rec_amount);
    arp_debug.debug('p_bank_min_rec_amount '|| p_bank_min_rec_amount);
    arp_debug.debug('p_exception_code      '||p_exception_code);
    arp_debug.debug('p_additional_message  '||p_additional_message);
  END IF;

  l_paying_customer_id     := p_paying_customer_id;

  IF l_paying_customer_id is null and
     p_cash_receipt_id is not null THEN
    select pay_from_customer
    into l_paying_customer_id
    from ar_cash_receipts
    where cash_receipt_id = p_cash_receipt_id;
  END IF;

  IF PG_DEBUG in ('Y','C') THEN
    arp_debug.debug('l_request_id             '|| pg_request_id );
    arp_debug.debug('l_last_updated_by        '|| pg_last_updated_by );
    arp_debug.debug('l_created_by             '|| pg_created_by );
    arp_debug.debug('l_last_update_login      '|| pg_last_update_login );
    arp_debug.debug('l_program_application_id '|| to_char(pg_program_application_id) );
    arp_debug.debug('l_program_id             '|| to_char(pg_program_id) );
  END IF;

  INSERT INTO ar_autorec_exceptions
      (batch_id,
      request_id,
      cash_receipt_id,
      payment_schedule_id,
      paying_customer_id,
      paying_site_use_id,
      due_date,
      cust_min_rec_amount,
      bank_min_rec_amount,
      exception_code,
      additional_message,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      program_application_id,
      program_id,
      program_update_date)
  SELECT
      p_batch_id,
      pg_request_id,
      p_cash_receipt_id,
      p_payment_schedule_id,
      l_paying_customer_id,
      p_paying_site_use_id,
      p_due_date,
      p_cust_min_rec_amount,
      p_bank_min_rec_amount,
      p_exception_code,
      substr(p_additional_message, 1, 240),
      sysdate,
      pg_last_updated_by,
      sysdate,
      pg_created_by,
      pg_last_update_login,
      pg_program_application_id,
      pg_program_id,
      sysdate
   FROM DUAL;

   IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( 'the rows in exceptions = ' || SQL%ROWCOUNT );
      arp_debug.debug ( 'insert_exceptions()-');
   END IF;

  EXCEPTION
   WHEN OTHERS THEN

   IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( 'ERROR IN insert_exceptions '||SQLERRM );
   END IF;
END insert_exceptions;


/*========================================================================+
 | PUBLIC PROCEDURE SUBMIT_REPORT                                         |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to get the parameters from the Conc program   |
 |    and convert them to the type reqd for processing.                   |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/

PROCEDURE SUBMIT_REPORT ( p_batch_id    ar_batches.batch_id%TYPE,
                          p_request_id  ar_cash_receipts.request_id%TYPE ) IS

  l_reqid   NUMBER(15);
  l_org_id  NUMBER;
  l_complete BOOLEAN := FALSE;
  l_uphase VARCHAR2(255);
  l_dphase VARCHAR2(255);
  l_ustatus VARCHAR2(255);
  l_dstatus VARCHAR2(255);
  l_message VARCHAR2(32000);


BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('SUBMIT_REPORT()+');
  END IF;

  --l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
  --setting the Org context before calling the conc prg Bug 5519913
  l_org_id := mo_global.get_current_org_id;

  if l_org_id is null then
    BEGIN
      select org_id into l_org_id
      from ar_batches_all
      where batch_id = p_batch_id;
    EXCEPTION
      when others then
      arp_debug.debug('Submit Report ...OTHERS');
      l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
    END;
  end if;

  fnd_request.set_org_id(l_org_id);

  l_reqid := FND_REQUEST.SUBMIT_REQUEST (
		      application=>'AR',
		      program=>'ARZCARPO',
		      sub_request=>FALSE,
		      argument1=>'P_PROCESS_TYPE=RECEIPT',
		      argument2=>'P_BATCH_ID='|| p_batch_id,
		      argument3=>'P_CREATE_FLAG='||g_create_flag,
		      argument4=>'P_APPROVE_FLAG='||g_approve_flag,
		      argument5=>'P_FORMAT_FLAG='||g_format_flag,
		      argument6=>'P_REQUEST_ID_MAIN=' || p_request_id
		      ) ;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('Request Id :' || l_reqid);
  END IF;

  arp_debug.debug (' COMMITING WORK ');
  commit;  -- This is there to commit the conc request.

  l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
	request_id   => l_reqid,
	interval     => 30,
	max_wait     => 144000,
	phase        => l_uphase,
	status       => l_ustatus,
	dev_phase    => l_dphase,
	dev_status   => l_dstatus,
	message      => l_message);


  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('SUBMIT_REPORT()-');
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
	   arp_debug.debug('Submitting the report.iN ERROR.'||SQLERRM);
   END IF;
   RAISE;
END SUBMIT_REPORT;



PROCEDURE rec_reset( p_apply_fail       IN  VARCHAR2,
                     p_pay_process_fail IN  VARCHAR2,
		     p_gt_id            IN  NUMBER )IS


BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('rec_reset()+');
  END IF;


  IF  p_pay_process_fail = 'Y' THEN

    UPDATE /*+ index(ct ra_customer_trx_u1) */ ra_customer_trx_all ct
    SET cc_error_flag = null,
    cc_error_code = null,
    cc_error_text = null
    WHERE customer_trx_id in
    (
      SELECT r.customer_trx_id
      FROM ar_receipts_gt r,
	         ar_cash_receipts cr,
	         ar_cash_receipt_history crh,
           iby_fndcpt_tx_operations op,
           iby_trxn_summaries_all summ
      WHERE  r.gt_id = p_gt_id
      AND cr.cash_receipt_id = r.cash_receipt_id
      AND crh.cash_receipt_id = cr.cash_receipt_id
      AND crh.status = 'CONFIRMED'
      AND crh.current_record_flag = 'Y'
      AND cr.payment_trxn_extension_id = op.trxn_extension_id
      AND op.transactionid = summ.transactionid
      AND summ.reqtype = 'ORAPMTREQ'
      AND summ.status IN(0, 100, 111)
      AND((trxntypeid IN(2,    3)) OR((trxntypeid = 20)
      AND(summ.trxnmid =
            (SELECT MAX(trxnmid)
               FROM iby_trxn_summaries_all
             WHERE transactionid = summ.transactionid
               AND(reqtype = 'ORAPMTREQ')
               AND(status IN(0,    100,    111))
               AND(trxntypeid = 20)))))
      )
      AND cc_error_flag = 'Y';

    IF PG_DEBUG in ('Y', 'C') THEN
      fnd_file.put_line(FND_FILE.LOG,'receipt rows updated to reset cc_error_flag : '||sql%rowcount);
    END IF;

      delete from ar_autorec_exceptions
      where cash_receipt_id in
      ( SELECT cr.cash_receipt_id
      FROM ar_receipts_gt r,
	         ar_cash_receipts cr,
	         ar_cash_receipt_history crh,
           iby_fndcpt_tx_operations op,
           iby_trxn_summaries_all summ
      WHERE  r.gt_id = p_gt_id
      AND cr.cash_receipt_id = r.cash_receipt_id
      AND crh.cash_receipt_id = cr.cash_receipt_id
      AND crh.status = 'CONFIRMED'
      AND crh.current_record_flag = 'Y'
      AND cr.payment_trxn_extension_id = op.trxn_extension_id
      AND op.transactionid = summ.transactionid
      AND summ.reqtype = 'ORAPMTREQ'
      AND summ.status IN(0, 100, 111)
      AND((trxntypeid IN(2,    3)) OR((trxntypeid = 20)
      AND(summ.trxnmid =
            (SELECT MAX(trxnmid)
               FROM iby_trxn_summaries_all
             WHERE transactionid = summ.transactionid
               AND(reqtype = 'ORAPMTREQ')
               AND(status IN(0,    100,    111))
               AND(trxntypeid = 20)))))
       )
        and request_id = pg_request_id;

      IF PG_DEBUG in ('Y', 'C') THEN
	fnd_file.put_line(FND_FILE.LOG,'rows deleted from ar_autorec_exceptions: '||sql%rowcount);
      END IF;

    /* Note here - the apply process was succesful but auth failed so here we have to unapply the
    payment_schedule_id before going in for the delete */

    /* start unapply */
    DECLARE

    ul_return_status  VARCHAR2(1);
    ul_msg_count      NUMBER;
    ul_msg_data      VARCHAR2(240);
    ul_count          NUMBER;
    l_called_from    VARCHAR2(15);

    CURSOR UNAPP is
      select ps.payment_schedule_id ps_id,
      ps.trx_number trx_num,
      nvl(ps.terms_sequence_number,1) inst_num,
      ps.customer_trx_id trx_id,
      r.receipt_number rec_num,
      r.cash_receipt_id cash_receipt_id
      from ar_payment_schedules ps,
      ra_customer_trx trx,
      ar_receipts_gt r
      where trx.customer_trx_id = ps.customer_trx_id
      and    trx.cc_error_flag = 'Y'
      and    r.payment_schedule_id = ps.payment_schedule_id
      and    r.gt_id = p_gt_id;

    BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('l_called_from'|| l_called_from);
      arp_debug.debug('Calling UNAPP ()+');
    END IF;

    FOR PS  in UNAPP  LOOP
	/* INITILIAZE the OUT variables */
	ul_msg_count     := 0;
	ul_msg_data      := NULL;
	ul_return_status := NULL;
	ul_count      := 0;
	l_called_from := 'AUTORECAPI';

	AR_RECEIPT_API_PUB.unapply
	    ( p_api_version => 1.0,
	    p_init_msg_list => FND_API.G_TRUE,
	    p_commit => FND_API.G_FALSE,
	    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	    x_return_status => ul_return_status,
	    x_msg_count => ul_msg_count,
	    x_msg_data =>  ul_msg_data,
	    p_cash_receipt_id => PS.cash_receipt_id,
	    p_customer_trx_id =>PS.trx_id,
	    p_installment =>PS.inst_num,
	    p_applied_payment_schedule_id =>PS.ps_id,
	    p_called_from => l_called_from
	    );

	arp_debug.debug('x_return_status: '||ul_return_status);

	IF ul_return_status <> 'S' THEN

	  IF ul_msg_count  = 1 Then
	    arp_debug.debug('ul_msg_data '||ul_msg_data);
	  ELSIF ul_msg_count  > 1 Then
	    LOOP
	      IF nvl(ul_count,0) < ul_msg_count THEN
		ul_count := nvl(ul_count,0) +1 ;
		ul_msg_data :=FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);

		arp_debug.debug ( 'the number is  ' || ul_count );
		arp_debug.debug ( 'the message data is ' || ul_msg_data );
	      ELSE
		EXIT;
	      END IF;
	    END LOOP;
	  END IF;
	END IF;
    END LOOP;

    EXCEPTION
    WHEN others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('Exception :In the UNAPPLY routine '|| SQLERRM);
    END IF;

    END ;

    /* end unapply */
    arp_debug.debug('delete the bad receipts');

    /* Start of delete XLA events code. Doing this is bulk */
    Begin
         IF PG_DEBUG in ('Y','C') THEN
             arp_debug.debug ( 'Start calling xla delete_bulk_events');
	     arp_debug.debug ( 'Inserting into xla_events_int_gt...');
         END IF;

	INSERT INTO xla_events_int_gt
           (event_id
	   ,ledger_id
	   ,entity_code
           ,application_id
           ,event_type_code
           ,entity_id
           ,event_number
           ,event_status_code
           ,process_status_code
           ,event_date
           ,transaction_date
           ,budgetary_control_flag
           ,reference_num_1
           ,reference_num_2
           ,reference_num_3
           ,reference_num_4
           ,reference_char_1
           ,reference_char_2
           ,reference_char_3
           ,reference_char_4
           ,reference_date_1
           ,reference_date_2
           ,reference_date_3
           ,reference_date_4
           ,on_hold_flag)
	( SELECT  event_id
	   ,ledger_id
	   ,entity_code
	   ,xte.application_id
	   ,event_type_code
	   ,xte.entity_id
	   ,event_number
	   ,event_status_code
	   ,process_status_code
	   ,TRUNC(event_date)
	   ,nvl(transaction_date, TRUNC(event_date))
	   ,'N'
	   ,reference_num_1
	   ,reference_num_2
	   ,reference_num_3
	   ,reference_num_4
	   ,reference_char_1
	   ,reference_char_2
	   ,reference_char_3
	   ,reference_char_4
	   ,reference_date_1
	   ,reference_date_2
	   ,reference_date_3
	   ,reference_date_4
	   ,on_hold_flag
	from  xla_transaction_entities_upg xte,
	      xla_events xe
	where xte.application_id = 222
	and   xte.entity_code    = 'RECEIPTS'
	and   xe.application_id  = 222
	and   xe.event_number    > 0
	and   xe.entity_id       = xte.entity_id
	and   xte.ledger_id  = ARP_STANDARD.sysparm.set_of_books_id
	and   NVL(xte.source_id_int_1, -99) IN
				(select distinct cash_receipt_id
		                 from ar_autorec_exceptions
				 where request_id = pg_request_id));

         IF PG_DEBUG in ('Y','C') THEN
             arp_debug.debug ( 'rows inserted into xla gt table = '|| sql%rowcount);
	     arp_debug.debug ( 'Calling xla_events_pub_pkg.delete_bulk_events()');
         END IF;

	xla_events_pub_pkg.delete_bulk_events(222);

         IF PG_DEBUG in ('Y','C') THEN
             arp_debug.debug ( 'End calling xla delete_bulk_events');
         END IF;

    EXCEPTION
	WHEN OTHERS THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	     arp_debug.debug('Error in call to xla_events_pub_pkg.delete_bulk_events ' || sqlerrm);
	END IF;
    END;
    /* End of delete XLA events code */

    update ar_payment_schedules
    set selected_for_receipt_batch_id = null,
    gl_date_closed = TO_DATE('4712/12/31', 'YYYY/MM/DD'),
    actual_date_closed = TO_DATE('4712/12/31', 'YYYY/MM/DD'),
    status = 'OP'
    where payment_schedule_id in
    ( select ps.payment_schedule_id
      from ar_payment_schedules ps,
	   ra_customer_trx trx,
	   ar_receipts_gt r
      where r.gt_id = p_gt_id
      AND  r.payment_schedule_id = ps.payment_schedule_id
      AND  trx.customer_trx_id = ps.customer_trx_id
      and  trx.cc_error_flag = 'Y');

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( ' rows updated PS = ' || SQL%ROWCOUNT );
    END IF;

    delete
    from ar_payment_schedules
    where cash_receipt_id
    in ( select distinct ex.cash_receipt_id
	 from ar_autorec_exceptions ex,
	      ar_receipts_gt r
	 where r.gt_id = p_gt_id
	 AND r.cash_receipt_id = ex.cash_receipt_id);

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( ' rows DELETED PS = ' || SQL%ROWCOUNT );
    END IF;

    delete
    from ar_distributions
    where source_table = 'CRH'
    and source_id in
    ( select cash_receipt_history_id
      from ar_cash_receipt_history
      where cash_receipt_id in
       ( select distinct ex.cash_receipt_id
	 from ar_autorec_exceptions ex,
	      ar_receipts_gt r
	 where r.gt_id = p_gt_id
	 AND r.cash_receipt_id = ex.cash_receipt_id
       )
    );

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( ' rows DELETED AR_DIST = ' || SQL%ROWCOUNT );
    END IF;

    delete
    from ar_distributions
    where source_table = 'RA'
    and source_id in
    ( select receivable_application_id
      from ar_receivable_applications
      where cash_receipt_id in
       ( select distinct ex.cash_receipt_id
	 from ar_autorec_exceptions ex,
	      ar_receipts_gt r
	 where r.gt_id = p_gt_id
	 AND r.cash_receipt_id = ex.cash_receipt_id
       )
    );

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( ' rows DELETED AR_DIST2 = ' || SQL%ROWCOUNT );
    END IF;

    delete
    from ar_receivable_applications
    where cash_receipt_id in
       ( select distinct ex.cash_receipt_id
	 from ar_autorec_exceptions ex,
	      ar_receipts_gt r
	 where r.gt_id = p_gt_id
	 AND r.cash_receipt_id = ex.cash_receipt_id);

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( ' rows DELETED REC_APPS = ' || SQL%ROWCOUNT );
    END IF;

    delete
    from ar_cash_receipt_history
    where cash_receipt_id in
       ( select distinct ex.cash_receipt_id
	 from ar_autorec_exceptions ex,
	      ar_receipts_gt r
	 where r.gt_id = p_gt_id
	 AND r.cash_receipt_id = ex.cash_receipt_id);

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( ' rows DELETED CRH = ' || SQL%ROWCOUNT );
    END IF;

    delete from ar_cash_receipts
    where cash_receipt_id in
       ( select distinct ex.cash_receipt_id
	 from ar_autorec_exceptions ex,
	      ar_receipts_gt r
	 where r.gt_id = p_gt_id
	 AND r.cash_receipt_id = ex.cash_receipt_id);

    IF PG_DEBUG in ('Y','C') THEN
      arp_debug.debug ( ' rows DELETED CR  = ' || SQL%ROWCOUNT );
    END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('rec_reset()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('rec_reset .iN ERROR.'||SQLERRM);
    END IF;

    insert_exceptions( p_batch_id   => nvl(g_batch_id, -333),
	           p_request_id => pg_request_id,
		   p_exception_code  => 'AUTORECERR',
		   p_additional_message => 'rec_reset() '|| SQLERRM );
END rec_reset;


/* START SUBMIT_FORMAT */
PROCEDURE SUBMIT_FORMAT ( p_batch_id    ar_batches.batch_id%TYPE ) IS
  l_org_id         NUMBER;
  l_reqid          NUMBER;
  dev_phase        VARCHAR2(255);
  dev_status       VARCHAR2(255);
  message          VARCHAR2(2000);
  phase            VARCHAR2(255);
  status           VARCHAR2(255);
  l_complete	   BOOLEAN := FALSE;
  l_program_name   ap_payment_programs.program_name%TYPE;
  l_batch_app_status ar_batches.batch_applied_status%TYPE;
  l_xml_output     BOOLEAN;
  l_iso_language   FND_LANGUAGES.iso_language%TYPE;
  l_iso_territory  FND_LANGUAGES.iso_territory%TYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(FND_FILE.LOG,'Submitting the report..');
  END IF;

  --setting the Org context before calling the conc prg Bug 5519913
  l_org_id := mo_global.get_current_org_id;

  IF l_org_id IS NULL THEN
    BEGIN
      select org_id
      into l_org_id
      from ar_batches_all
      where batch_id = p_batch_id;
    EXCEPTION
      WHEN OTHERS THEN
      arp_debug.debug('Submit Format ...OTHERS');
      l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
    END;
  END IF;

  fnd_request.set_org_id(l_org_id);

/* Modified the code as per SEPA Project. We need to check the
   program attached to the receipt method and call it accordingly */
/*  l_reqid := FND_REQUEST.SUBMIT_REQUEST (
		      application=>'AR',
		      program=>'ARXAPFRC',
		      sub_request=>FALSE,
		      argument1=>'P_BATCH_ID='|| p_batch_id
		      ) ;*/
  SELECT bat.batch_applied_status,
         app.program_name
  INTO   l_batch_app_status,
         l_program_name
  FROM   ar_batches bat,
         ar_receipt_methods rm,
	 ap_payment_programs app
  WHERE  bat.batch_id = p_batch_id
  AND	 bat.receipt_method_id = rm.receipt_method_id
  AND	 rm.auto_print_program_id = app.program_id;

  IF ( l_program_name = 'ARSEPADNT')  THEN
      IF l_batch_app_status <> 'COMPLETED_FORMAT' AND l_batch_app_status <> 'STARTED_FORMAT' THEN
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
      SELECT lower(iso_language),iso_territory
      INTO l_iso_language,l_iso_territory
      FROM FND_LANGUAGES
      WHERE language_code = USERENV('LANG');

      l_xml_output:=  fnd_request.add_layout(
                            template_appl_name  => 'AR',
                            template_code       => 'ARSEPADNT',
                            template_language   => l_iso_language,
                            template_territory  => l_iso_territory,
                            output_format       => 'RTF'
                          );
   END IF;
  l_reqid := FND_REQUEST.SUBMIT_REQUEST (
                      application=>'AR',
                      program=>l_program_name,
		      sub_request=>FALSE,
                      argument1=>'P_BATCH_ID='|| p_batch_id
                      ) ;
  commit;  -- commit the conc request  bug6630799.

  l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
		 request_id   => l_reqid,
		 interval     => 15,
		 max_wait     =>1800,
		 phase        =>phase,
		 status       =>status,
		 dev_phase    =>dev_phase,
		 dev_status   =>dev_status,
		 message      =>message);

  IF dev_phase <> 'COMPLETE' THEN
    arp_debug.debug('Format Program has a phase '||dev_phase);
    update ar_batches
    SET batch_applied_status = 'COMPLETED_APPROVAL'
    where batch_id = p_batch_id;
  ELSIF dev_phase = 'COMPLETE' AND
        dev_status <> 'NORMAL' THEN
    arp_debug.debug('Format Program completed with status '||dev_status);
    update ar_batches
    SET  batch_applied_status = 'COMPLETED_APPROVAL'
    where batch_id = p_batch_id;
  ELSE
    arp_debug.debug('Format Program completed successfully');
    update ar_batches
    SET  batch_applied_status = 'COMPLETED_FORMAT'
    where batch_id = p_batch_id;
  END IF;

  commit;  -- This is there to commit the Format status.

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('Request Id :' || l_reqid);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('Exception in SUBMIT_FORMAT '||SQLERRM);
    END IF;
    RAISE;
END SUBMIT_FORMAT;



PROCEDURE create_receipt ( p_amount              IN NUMBER,
			   p_receipt_number      IN VARCHAR2,
			   p_receipt_date        IN DATE,
			   p_customer_id         IN NUMBER,
			   p_installment         IN NUMBER,
			   p_cust_site_use_id    IN NUMBER,
			   p_receipt_method_id   IN  ar_cash_receipts.receipt_method_id%TYPE,
			   p_pmt_trxn_ext_id     IN  RA_CUSTOMER_TRX.PAYMENT_TRXN_EXTENSION_ID%TYPE,
			   p_called_from         IN VARCHAR2,
			   p_request_id          IN NUMBER,
			   p_batch_id            IN NUMBER,
			   p_exchange_rate	 IN ar_batches.exchange_rate%TYPE,
			   p_exchange_date	 IN ar_batches.exchange_date%TYPE,
			   p_exchange_rate_type	 IN ar_batches.exchange_rate_type%TYPE,
			   p_currency_code       IN VARCHAR2,
			   p_remittance_bank_account_id IN ar_receipt_method_accounts_all.remit_bank_acct_use_id%TYPE,
			   p_cash_receipt_id     OUT NOCOPY ar_cash_receipts.cash_receipt_id%TYPE,
			   p_return_status       OUT NOCOPY VARCHAR2) IS

    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(240);
    l_count          NUMBER;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('create_receipt()+');
	arp_debug.debug('l_called_from'|| p_called_from);
	arp_debug.debug('Calling create_cash API ()+');
    END IF;

    AR_RECEIPT_API_PUB.create_cash (p_api_version               => 1.0,
				    p_init_msg_list             => FND_API.G_TRUE,
				    p_commit                    => FND_API.G_FALSE,
				    p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
				    x_return_status             => p_return_status,
				    x_msg_count                 => l_msg_count,
				    x_msg_data                  => l_msg_data,
				    p_currency_code             => p_currency_code,
				    p_exchange_rate_type        => p_exchange_rate_type,
				    p_exchange_rate             => p_exchange_rate,
				    p_exchange_rate_date        => p_exchange_date,
				    p_amount                    => p_amount,
				    p_receipt_number            => p_receipt_number,
				    p_receipt_method_id         => p_receipt_method_id,
				    p_receipt_date              => p_receipt_date,
				    p_customer_id               => p_customer_id,
				    p_installment               => p_installment,
				    p_customer_site_use_id      => p_cust_site_use_id,
				    p_payment_trxn_extension_id => p_pmt_trxn_ext_id,
				    p_remittance_bank_account_id => p_remittance_bank_account_id,
				    p_cr_id                     => p_cash_receipt_id,
				    p_called_from               => p_called_from );

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('x_return_status: '||p_return_status);
    END IF;

    --check for the exceptions raised
    IF p_return_status <> 'S' THEN

	IF l_msg_count  = 1 THEN
	    arp_debug.debug('l_msg_count '||l_msg_count);

	    insert_exceptions( p_batch_id   => p_batch_id,
			       p_request_id => p_request_id,
			       p_paying_customer_id => p_customer_id,
			       p_exception_code  => 'AUTORECERR',
			       p_additional_message => l_count||l_msg_data );

	ELSIF l_msg_count  > 1 THEN
	    LOOP
		IF nvl(l_count,0) < l_msg_count THEN
		    l_count := nvl(l_count,0) +1 ;
		    l_msg_data :=FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);

		    arp_debug.debug ( 'the number is  ' || l_count );
		    arp_debug.debug ( 'the message data is ' || l_msg_data );

		    insert_exceptions( p_batch_id   => p_batch_id,
		                       p_request_id => p_request_id,
		                       p_paying_customer_id => p_customer_id,
		                       p_exception_code  => 'AUTORECERR',
		                       p_additional_message => l_count||l_msg_data );
		ELSE
		    EXIT;
		END IF;
	    END LOOP;
	 END IF;
   END IF;  /* end of return status */

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('create_receipt()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
     arp_debug.debug('create_receipt : error code() '|| to_char(SQLCODE));

	    insert_exceptions( p_batch_id   => p_batch_id,
			       p_request_id => p_request_id,
			       p_paying_customer_id => p_customer_id,
			       p_exception_code  => 'AUTORECERR',
			       p_additional_message => 'create_receipt() '||sqlerrm );
END create_receipt;


PROCEDURE receipt_application(  p_cash_receipt_id IN NUMBER,
				p_applied_ps_id   IN NUMBER,
				p_amount_applied  IN NUMBER,
			        p_request_id      IN NUMBER,
			        p_batch_id        IN NUMBER,
			        p_apply_date      IN DATE,
				p_called_from     IN VARCHAR2,
				p_return_status   OUT NOCOPY VARCHAR2)  IS
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_count          NUMBER;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('AR_AUTOREC_API.receipt_application()+');
	arp_debug.debug('l_called_from         '|| p_called_from);
	arp_debug.debug('p_cash_receipt_id     '|| p_cash_receipt_id);
	arp_debug.debug('p_applied_ps_id       '|| p_applied_ps_id);
	arp_debug.debug('p_amount_applied      '|| p_amount_applied);
	arp_debug.debug('p_batch_id            '|| p_batch_id);
    END IF;

    AR_RECEIPT_API_PUB.apply (  p_api_version                 => 1.0,
				p_init_msg_list               => FND_API.G_TRUE,
				p_commit                      => FND_API.G_FALSE,
				p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
				x_return_status               => p_return_status,
				x_msg_count                   => l_msg_count,
				x_msg_data                    => l_msg_data,
				p_cash_receipt_id             => p_cash_receipt_id,
				p_applied_payment_schedule_id => p_applied_ps_id,
				p_amount_applied              => p_amount_applied,
				p_apply_date                  => p_apply_date,
				p_called_from                 => p_called_from );

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('x_return_status: '||p_return_status);
    END IF;

    IF p_return_status <> 'S' THEN

	IF l_msg_count  = 1 Then
	    arp_debug.debug('al_msg_data '||l_msg_data);
	    l_msg_data := 'Application failure. You need to nullify the SELECTED FOR RECEIPT BATCH ID on the invoice'||
	                   ' when the invoice is fixed. Then apply the invoice manually to the receipt'||
	                   ' with receipt id: '||p_cash_receipt_id||', created by automatic receipts for that invoice';

	    insert_exceptions( p_batch_id             => p_batch_id,
				p_request_id          => p_request_id,
				p_payment_schedule_id => p_applied_ps_id,
				p_exception_code      => 'AUTORECERR',
				p_additional_message  => l_count||l_msg_data );

	ELSIF l_msg_count  > 1 THEN
	    LOOP
		IF nvl(l_count,0) < l_msg_count THEN
		    l_count := nvl(l_count,0) +1 ;

		IF l_count = 1 THEN
	    l_msg_data := 'Application failure. You need to nullify the SELECTED FOR RECEIPT BATCH ID on the invoice'||
	                   ' when the invoice is fixed. Then apply the invoice manually to the receipt'||
	                   ' with receipt id: '||p_cash_receipt_id||', created by automatic receipts for that invoice';
		ELSE
			l_msg_data :=FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
		END IF;
			arp_debug.debug ( 'the number is  ' || l_count );
			arp_debug.debug ( 'the message data is ' || l_msg_data );

		    insert_exceptions( p_batch_id            => p_batch_id,
				       p_request_id          => p_request_id,
				       p_payment_schedule_id => p_applied_ps_id,
				       p_exception_code      => 'AUTORECERR',
				       p_additional_message  => l_count||l_msg_data );
		ELSE
		    EXIT;
		END IF;
	    END LOOP;
	 END IF;
   END IF;  /* end of return status */

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('p_return_status      :'|| p_return_status);
      arp_debug.debug('AR_AUTOREC_API.receipt_application()-');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
     arp_debug.debug('Exception OTHERS : AR_AUTOREC_API.receipt_application : error code() '|| to_char(SQLCODE));

    insert_exceptions( p_batch_id            => p_batch_id,
		       p_request_id          => p_request_id,
		       p_payment_schedule_id => p_applied_ps_id,
		       p_exception_code      => 'AUTORECERR',
		       p_additional_message  => 'receipt_application() '||sqlerrm );

END receipt_application;


PROCEDURE process_payments( p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE,
                            p_pmt_trxn_id     IN RA_CUSTOMER_TRX.PAYMENT_TRXN_EXTENSION_ID%TYPE,
			    p_request_id      IN NUMBER,
			    p_batch_id        IN NUMBER,
			    p_called_from     IN VARCHAR2,
			    p_cc_error_code   OUT NOCOPY VARCHAR2,
                            p_cc_error_text   OUT NOCOPY VARCHAR2,
			    p_return_status   OUT NOCOPY VARCHAR2)  IS
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(240);
    l_count                NUMBER;
    l_response_error_code  VARCHAR2(20);
    l_pmt_trxn_id             RA_CUSTOMER_TRX.PAYMENT_TRXN_EXTENSION_ID%TYPE;

    /* Bug 7639165 - Declaration Begin. */
    l_first_msg	              VARCHAR2(240);
    /* Bug 7639165 - Declaration End. */
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('AR_AUTOREC_API.process_payments()+');
    arp_debug.debug('p_cash_receipt_id  :'||p_cash_receipt_id);
  END IF;

  select payment_trxn_extension_id
  into l_pmt_trxn_id
  from ar_cash_receipts
  where cash_receipt_id = p_cash_receipt_id;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('l_pmt_trxn_id   :'||l_pmt_trxn_id);
  END IF;

  AR_RECEIPT_API_PUB.Process_Payment_1(
		  p_cash_receipt_id          => p_cash_receipt_id,
		  p_called_from              => p_called_from,
		  p_response_error_code      => l_response_error_code,
		  x_msg_count                => l_msg_count,
		  x_msg_data                 => l_msg_data,
		  x_return_status            => p_return_status,
		  p_payment_trxn_extension_id => l_pmt_trxn_id);

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('Process_payment return status: ' || p_return_status);
  END IF;

  /*------------------------------------------------------+
  | Check the return status from Process_Payment         |
  +------------------------------------------------------*/
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      IF l_msg_count  = 1 Then
	  arp_debug.debug('l_msg_data '||l_msg_data);

	  insert_exceptions(  p_batch_id           => p_batch_id,
			      p_request_id         => p_request_id,
			      p_cash_receipt_id    => p_cash_receipt_id,
			      p_exception_code     => 'AR_CC_AUTH_FAILED',
			      p_additional_message => l_count||l_msg_data );

	  p_cc_error_code := l_response_error_code;
          p_cc_error_text := l_msg_data;

      ELSIF l_msg_count  > 1 THEN

	  LOOP
	      IF nvl(l_count,0) < l_msg_count THEN
		  l_count := nvl(l_count,0) +1 ;
		  l_msg_data :=FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);

		  arp_debug.debug ( 'the number is  ' || l_count );
		  arp_debug.debug ( 'the message data is ' || l_msg_data );

		  /* Bug 7639165 - Changes Begin. */
		  IF  l_count = 2  THEN
		    l_first_msg := l_msg_data;
		  END IF;
	 	  /* Bug 7639165 - Chages End. */

		  insert_exceptions(  p_batch_id           => p_batch_id,
				      p_request_id         => p_request_id,
				      p_cash_receipt_id    => p_cash_receipt_id,
				      p_exception_code     => 'AR_CC_AUTH_FAILED',
				      p_additional_message => l_count||l_msg_data );

	          p_cc_error_code := l_response_error_code;
                  p_cc_error_text := l_first_msg;
	      ELSE
		  EXIT;
	      END IF;
	  END LOOP;
      END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug('AR_AUTOREC_API.process_payments()-');
  END IF;

  EXCEPTION
     WHEN OTHERS THEN
     arp_debug.debug('AR_AUTOREC_API.process_payments : error code() '|| to_char(SQLCODE));
     insert_exceptions(  p_batch_id           => p_batch_id,
		      p_request_id         => p_request_id,
		      p_cash_receipt_id    => p_cash_receipt_id,
		      p_exception_code     => 'AR_CC_AUTH_FAILED',
		      p_additional_message => 'process_payments() '|| sqlerrm);

END  process_payments;



PROCEDURE update_ar_receipts_gt(p_creation_rule             IN VARCHAR2,
				p_update_stmt              IN VARCHAR2,
				p_cr_id_array              IN DBMS_SQL.NUMBER_TABLE,
				p_cr_number_array          IN DBMS_SQL.VARCHAR2_TABLE,
				p_gt_id_array              IN DBMS_SQL.NUMBER_TABLE,
				p_ps_id_array              IN DBMS_SQL.NUMBER_TABLE,
				p_paying_customer_id_array IN DBMS_SQL.NUMBER_TABLE,
				p_pmt_instrument_array     IN DBMS_SQL.VARCHAR2_TABLE,
				p_paying_site_use_id_array IN DBMS_SQL.NUMBER_TABLE,
				p_due_date_array           IN DBMS_SQL.DATE_TABLE,
				p_pmt_channel_code_array   IN DBMS_SQL.VARCHAR2_TABLE,
				p_cust_bank_acct_id_array  IN DBMS_SQL.NUMBER_TABLE,
				p_trxn_extension_id_array  IN DBMS_SQL.NUMBER_TABLE,
				p_authorization_id_array   IN DBMS_SQL.NUMBER_TABLE )IS
 l_update_cursor  NUMBER;
 l_dummy          NUMBER;

 BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('update_ar_receipts_gt()+');
	arp_debug.debug('p_creation_rule   '||p_creation_rule);
	arp_debug.debug('p_update_stmt     '||p_update_stmt);
    END IF;

   l_update_cursor := dbms_sql.open_cursor;

   dbms_sql.parse (l_update_cursor, p_update_stmt,dbms_sql.v7);

   dbms_sql.bind_array (l_update_cursor,':l_receipt_num_array',p_cr_number_array);
   dbms_sql.bind_array (l_update_cursor,':l_receipt_id_array',p_cr_id_array);
   dbms_sql.bind_array (l_update_cursor,':l_gt_id_array',p_gt_id_array);

   IF p_creation_rule = 'PER_INVOICE' THEN
     dbms_sql.bind_array (l_update_cursor,':l_ps_id_array',p_ps_id_array);

   ELSIF p_creation_rule = 'PER_CUSTOMER' THEN
     dbms_sql.bind_array (l_update_cursor,':l_paying_customer_id_array',p_paying_customer_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_pmt_instrument_array',p_pmt_instrument_array);

   ELSIF p_creation_rule = 'PER_SITE' THEN
     dbms_sql.bind_array (l_update_cursor,':l_paying_customer_id_array',p_paying_customer_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_pmt_instrument_array',p_pmt_instrument_array);
     dbms_sql.bind_array (l_update_cursor,':l_paying_site_use_id_array',p_paying_site_use_id_array);

   ELSIF (p_creation_rule = 'PER_SITE_DUE_DATE') THEN
     dbms_sql.bind_array (l_update_cursor,':l_paying_customer_id_array',p_paying_customer_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_pmt_instrument_array',p_pmt_instrument_array);
     dbms_sql.bind_array (l_update_cursor,':l_paying_site_use_id_array',p_paying_site_use_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_due_date_array',p_due_date_array);

   ELSIF (p_creation_rule = 'PER_CUSTOMER_DUE_DATE') THEN
     dbms_sql.bind_array (l_update_cursor,':l_paying_customer_id_array',p_paying_customer_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_pmt_instrument_array',p_pmt_instrument_array);
     dbms_sql.bind_array (l_update_cursor,':l_due_date_array',p_due_date_array);

   ELSIF (p_creation_rule = 'PAYMENT_CHANNEL_CODE') THEN
     dbms_sql.bind_array (l_update_cursor,':l_paying_customer_id_array',p_paying_customer_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_trxn_extension_id_array',p_trxn_extension_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_pmt_channel_code_array',p_pmt_channel_code_array);
     dbms_sql.bind_array (l_update_cursor,':l_cust_bank_acct_id_array',p_cust_bank_acct_id_array);

   ELSIF (p_creation_rule = 'PAYMENT_INSTRUMENT') THEN
     dbms_sql.bind_array (l_update_cursor,':l_paying_customer_id_array',p_paying_customer_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_trxn_extension_id_array',p_trxn_extension_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_pmt_instrument_array',p_pmt_instrument_array);

   ELSIF (p_creation_rule = 'AUTHORIZATION_ID') THEN
     dbms_sql.bind_array (l_update_cursor,':l_paying_customer_id_array',p_paying_customer_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_trxn_extension_id_array',p_trxn_extension_id_array);
     dbms_sql.bind_array (l_update_cursor,':l_authorization_id_array',p_authorization_id_array);
   END IF;

   l_dummy := dbms_sql.execute(l_update_cursor);

   dbms_sql.close_cursor(l_update_cursor);

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('Rows updated :'||SQL%ROWCOUNT);
      arp_debug.debug('update_ar_receipts_gt()-');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      if dbms_sql.is_open(l_update_cursor) then
	dbms_sql.close_cursor(l_update_cursor);
      end if;
       arp_debug.debug('update_ar_receipts_gt : error code() '|| to_char(SQLCODE));

	insert_exceptions( p_batch_id   => NVL(g_batch_id, -333),
	           p_request_id => arp_standard.profile.request_id,
		   p_exception_code  => 'AUTORECERR',
		   p_additional_message => 'update_ar_receipts_gt() '|| SQLERRM );

 END update_ar_receipts_gt;


PROCEDURE build_queries(p_creation_rule  IN ar_receipt_methods.receipt_creation_rule_code%TYPE,
                        p_approval_mode  IN VARCHAR2,
			p_create_query   OUT NOCOPY VARCHAR2,
                        p_update_stmt    OUT NOCOPY VARCHAR2,
			p_inv_rct_mp_qry OUT NOCOPY VARCHAR2 )  IS

l_update_where_clause  VARCHAR2(2000);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('build_queries()+');
	arp_debug.debug('p_creation_rule   '||p_creation_rule);
	arp_debug.debug('p_approval_mode   '||p_approval_mode);
    END IF;

    p_update_stmt := 'UPDATE /*+INDEX(ar_receipts_gt AR_RECEIPTS_GT_N2)*/ '||
		     ' ar_receipts_gt '||
		     ' SET receipt_number = :l_receipt_num_array, '||
		     ' cash_receipt_id = :l_receipt_id_array, '||
		     ' gt_id           = :l_gt_id_array ';

    IF p_approval_mode = 'RE-APPROVAL' THEN
      p_inv_rct_mp_qry := '
	insert into ar_receipts_gt
	  ( payment_schedule_id,
	    customer_trx_id,
	    cash_receipt_id,
	    amount_due_remaining,
	    gt_id
	  ) ';

      p_create_query := '
	select paying_customer_id,
		  null paying_site_use_id,
		  null due_date,
		  null payment_instrument,
		  null payment_channel_code,
		  null payment_trxn_extension_id,
		  null authorization_id,
		  null amount,
		  payment_schedule_id,
		  null customer_bank_account_id,
		  null instr_assignment_id,
		  null party_id,
		  null trx_number,
		  null cust_min_amount,
		  cash_receipt_id
	  from ar_receipts_gt gt ';

    END IF;

    --set 1
    IF (p_creation_rule = 'PER_INVOICE') THEN
	IF p_approval_mode = 'RE-APPROVAL' THEN
	  p_inv_rct_mp_qry := p_inv_rct_mp_qry || '
	    select /*+ leading(crh) */
	      ps.payment_schedule_id,
	      ct.customer_trx_id,
	      cr.cash_receipt_id,
	      ps.amount_due_remaining,
	      -1 gt_id
	    from ar_cash_receipt_history crh,
	    ar_cash_receipts cr,
	    ar_payment_schedules ps,
	    ra_customer_trx ct,
	    iby_fndcpt_tx_xe_copies cp
	    where crh.batch_id = :p_batch_id
	    and cr.status = ''UNAPP''
	    and ps.customer_trx_id = ct.customer_trx_id
	    and ps.selected_for_receipt_batch_id = crh.batch_id
	    and ct.bill_to_customer_id = cr.pay_from_customer
	    and crh.cash_receipt_id  = cr.cash_receipt_id
	    and cp.source_trxn_extension_id = ct.payment_trxn_extension_id
	    and cp.copy_trxn_extension_id = cr.payment_trxn_extension_id';
	ELSE
	  p_create_query :=
	  'select	paying_customer_id,
		  gt.paying_site_use_id,
		  null due_date,
		  null payment_instrument,
		  gt.payment_channel_code,
		  gt.payment_trxn_extension_id,
		  null authorization_id,
		  sum(gt.amount_due_remaining) amount,
		  gt.payment_schedule_id,
		  null customer_bank_account_id,
		  ext.instr_assignment_id,
		  hca.party_id,
		  trx_number||''-''||to_char(terms_sequence_number) trx_number,
		  MAX(gt.cust_min_amount) cust_min_amount,
		  null cash_receipt_id
	  from ar_receipts_gt gt,
	       iby_fndcpt_tx_extensions ext,
	       hz_cust_accounts hca,
	       ar_payment_schedules ps
	  where ext.trxn_extension_id = gt.payment_trxn_extension_id
	  and hca.cust_account_id =  gt.paying_customer_id
	  and ps.payment_schedule_id = gt.payment_schedule_id
	  group by gt.customer_trx_id,
		   gt.payment_schedule_id,
		   gt.paying_customer_id,
		   gt.payment_trxn_extension_id,
		   gt.payment_channel_code,
		   ext.instr_assignment_id,
		   hca.party_id,
		   trx_number||''-''||to_char(terms_sequence_number),
		   gt.paying_site_use_id';


	  l_update_where_clause :=  ' WHERE  payment_schedule_id = :l_ps_id_array ';
        END IF;

    --set 2
    ELSIF (p_creation_rule = 'PER_CUSTOMER') THEN
	IF p_approval_mode = 'RE-APPROVAL' THEN
	  p_inv_rct_mp_qry := p_inv_rct_mp_qry || '
	    select /*+ leading(crh) */
	      ps.payment_schedule_id,
	      ct.customer_trx_id,
	      cr.cash_receipt_id,
	      ps.amount_due_remaining,
	      -1 gt_id
	    from ar_cash_receipt_history crh,
	    ar_cash_receipts cr,
	    ar_payment_schedules ps,
	    ra_customer_trx ct
	    where crh.batch_id = :p_batch_id
	    and cr.status = ''UNAPP''
	    and ps.customer_trx_id = ct.customer_trx_id
	    and ps.selected_for_receipt_batch_id = crh.batch_id
	    and ct.bill_to_customer_id = cr.pay_from_customer
	    and crh.cash_receipt_id  = cr.cash_receipt_id ';
	ELSE
	  p_create_query :=
	  'select	gt.paying_customer_id,
		  null paying_site_use_id,
		  null due_date,
		  gt.payment_instrument,
		  null payment_channel_code,
		  gt.payment_trxn_extension_id,
		  null authorization_id,
		  gt.amount,
		  null payment_schedule_id,
		  null customer_bank_account_id,
		  ext.instr_assignment_id,
		  hca.party_id,
		  null trx_number,
		  gt.cust_min_amount,
		  null cash_receipt_id
	   from hz_cust_accounts hca,
	       iby_fndcpt_tx_extensions ext,
	   ( select paying_customer_id,
		   payment_instrument,
		  MIN(payment_trxn_extension_id) payment_trxn_extension_id,
		  sum(amount_due_remaining) amount,
		  MAX(cust_min_amount) cust_min_amount
	     from ar_receipts_gt
	     group by paying_customer_id,
		      payment_instrument ) gt
	   where ext.trxn_extension_id = gt.payment_trxn_extension_id
	   and hca.cust_account_id =  gt.paying_customer_id ';

	  l_update_where_clause :=  ' WHERE paying_customer_id =:l_paying_customer_id_array '||
				    ' AND   payment_instrument =:l_pmt_instrument_array ' ;
	END IF;

    --set 3
    ELSIF (p_creation_rule = 'PER_SITE') THEN
	IF p_approval_mode = 'RE-APPROVAL' THEN
	  p_inv_rct_mp_qry := p_inv_rct_mp_qry || '
	    select /*+ leading(crh) */
	      ps.payment_schedule_id,
	      ct.customer_trx_id,
	      cr.cash_receipt_id,
	      ps.amount_due_remaining,
	      -1 gt_id
	    from ar_cash_receipt_history crh,
	    ar_cash_receipts cr,
	    ar_payment_schedules ps,
	    ra_customer_trx ct
	    where crh.batch_id = :p_batch_id
	    and cr.status = ''UNAPP''
	    and ps.customer_trx_id = ct.customer_trx_id
	    and ps.selected_for_receipt_batch_id = crh.batch_id
	    and ct.bill_to_customer_id = cr.pay_from_customer
	    and crh.cash_receipt_id  = cr.cash_receipt_id
	    AND cr.customer_site_use_id = ct.bill_to_site_use_id ';
	ELSE
	  p_create_query :=
	  ' select gt.paying_customer_id,
		  gt.paying_site_use_id,
		  null due_date,
		  gt.payment_instrument,
		  null payment_channel_code,
		  gt.payment_trxn_extension_id,
		  null authorization_id,
		  gt.amount,
		  null payment_schedule_id,
		  null customer_bank_account_id,
		  ext.instr_assignment_id,
		  hca.party_id,
		  null trx_number,
		  gt.cust_min_amount,
		  null cash_receipt_id
	   from hz_cust_accounts hca,
	       iby_fndcpt_tx_extensions ext,
	   ( select  paying_customer_id,
		 paying_site_use_id,
		 payment_instrument,
		 MIN(payment_trxn_extension_id) payment_trxn_extension_id,
		 sum(amount_due_remaining) amount,
		 MAX(cust_min_amount) cust_min_amount
	     from AR_RECEIPTS_GT
	     group by paying_customer_id,
			    paying_site_use_id,
			    payment_instrument ) gt
	   where ext.trxn_extension_id = gt.payment_trxn_extension_id
	   and hca.cust_account_id =  gt.paying_customer_id ';

	  l_update_where_clause :=  ' WHERE paying_customer_id =:l_paying_customer_id_array '||
				    ' AND   paying_site_use_id =:l_paying_site_use_id_array '||
				    ' AND   payment_instrument =:l_pmt_instrument_array ' ;
	END IF;
    --set 4
    ELSIF (p_creation_rule = 'PER_SITE_DUE_DATE') THEN
	IF p_approval_mode = 'RE-APPROVAL' THEN
	  p_inv_rct_mp_qry := p_inv_rct_mp_qry || '
	    SELECT payment_schedule_id,
		  customer_trx_id,
		  cash_receipt_id,
		  amount_due_remaining,
		  -1 gt_id
            FROM
	     (
	      select /*+ leading(ps) */
		    ps.payment_schedule_id,
		    ps.customer_trx_id,
		    cr.cash_receipt_id,
		    ps.amount_due_remaining,
	            RANK( ) OVER (PARTITION BY cr.cash_receipt_id
		    ORDER BY ps.customer_trx_id, cr.amount) rct_rank,
		    RANK( ) OVER (PARTITION BY ps.customer_trx_id
		    ORDER BY cr.cash_receipt_id, cr.amount) inv_rank
	      from ar_cash_receipt_history crh,
	      ar_cash_receipts cr,
	      ( SELECT ps.payment_schedule_id,
		       ps.selected_for_receipt_batch_id,
		       ct.bill_to_customer_id,
		       ps.amount_due_remaining,
		       SUM( ps.amount_due_remaining )
		       OVER( PARTITION BY ct.bill_to_site_use_id,ps.due_date) group_amount,
		       ct.bill_to_site_use_id,
		       ps.customer_trx_id
		FROM ar_payment_schedules ps,
		     ra_customer_trx ct
		WHERE ps.customer_trx_id = ct.customer_trx_id
		AND ps.selected_for_receipt_batch_id = :batch_id
	      ) ps
	      where crh.batch_id = ps.selected_for_receipt_batch_id
	      and cr.status = ''UNAPP''
	      and ps.bill_to_customer_id = cr.pay_from_customer
	      AND ps.group_amount      = cr.amount
	      and crh.cash_receipt_id  = cr.cash_receipt_id
	      AND cr.customer_site_use_id = ps.bill_to_site_use_id
	    )
	    WHERE rct_rank = inv_rank ';
	ELSE
	p_create_query :=
        ' select gt.paying_customer_id,
		gt.paying_site_use_id,
		gt.due_date,
		gt.payment_instrument,
		null payment_channel_code,
		gt.payment_trxn_extension_id,
		null authorization_id,
		gt.amount,
		null payment_schedule_id,
		null customer_bank_account_id,
		ext.instr_assignment_id,
		hca.party_id,
		null trx_number,
		gt.cust_min_amount,
		null cash_receipt_id
	 from hz_cust_accounts hca,
	     iby_fndcpt_tx_extensions ext,
	 ( select  paying_customer_id,
	       paying_site_use_id,
               payment_instrument,
	       due_date,
	       MIN(payment_trxn_extension_id) payment_trxn_extension_id,
	       sum(amount_due_remaining) amount,
	       MAX(cust_min_amount) cust_min_amount
	   from AR_RECEIPTS_GT
	   group by paying_customer_id,
	            due_date,
		    paying_site_use_id,
		    payment_instrument ) gt
	 where ext.trxn_extension_id = gt.payment_trxn_extension_id
	 and hca.cust_account_id =  gt.paying_customer_id ';

        l_update_where_clause :=  ' WHERE paying_customer_id =:l_paying_customer_id_array '||
	                          ' AND   paying_site_use_id =:l_paying_site_use_id_array '||
	                          ' AND   due_date =:l_due_date_array'||
	                          ' AND   payment_instrument =:l_pmt_instrument_array ' ;
        END IF;
    --set 5
    ELSIF (p_creation_rule = 'PER_CUSTOMER_DUE_DATE') THEN
	IF p_approval_mode = 'RE-APPROVAL' THEN
	  p_inv_rct_mp_qry := p_inv_rct_mp_qry || '
	    SELECT payment_schedule_id,
		  customer_trx_id,
		  cash_receipt_id,
		  amount_due_remaining,
		  -1 gt_id
            FROM
	     (
	      select /*+ leading(ps) */
		    ps.payment_schedule_id,
		    ps.customer_trx_id,
		    cr.cash_receipt_id,
		    ps.amount_due_remaining,
		    RANK( ) OVER (PARTITION BY cr.cash_receipt_id
		    ORDER BY ps.customer_trx_id, cr.amount) rct_rank,
		    RANK( ) OVER (PARTITION BY ps.customer_trx_id
		    ORDER BY cr.cash_receipt_id, cr.amount) inv_rank
	      from ar_cash_receipt_history crh,
	      ar_cash_receipts cr,
	      ( SELECT ps.payment_schedule_id,
		       ps.selected_for_receipt_batch_id,
		       ct.bill_to_customer_id,
		       ps.amount_due_remaining,
		       SUM( ps.amount_due_remaining )
		       OVER( PARTITION BY ct.bill_to_customer_id,ps.due_date) group_amount,
		       ps.customer_trx_id
		FROM ar_payment_schedules ps,
		     ra_customer_trx ct
		WHERE ps.customer_trx_id = ct.customer_trx_id
		AND ps.selected_for_receipt_batch_id = :batch_id
	      ) ps
	      where crh.batch_id = ps.selected_for_receipt_batch_id
	      and cr.status = ''UNAPP''
	      and ps.bill_to_customer_id = cr.pay_from_customer
	      AND ps.group_amount      = cr.amount
	      and crh.cash_receipt_id  = cr.cash_receipt_id
	    )
	    WHERE rct_rank = inv_rank ';
	ELSE
	  p_create_query :=
	  ' select gt.paying_customer_id,
		  null paying_site_use_id,
		  gt.due_date,
		  gt.payment_instrument,
		  null payment_channel_code,
		  gt.payment_trxn_extension_id,
		  null authorization_id,
		  gt.amount,
		  null payment_schedule_id,
		  null customer_bank_account_id,
		  ext.instr_assignment_id,
		  hca.party_id,
		  null trx_number,
		  gt.cust_min_amount,
		  null cash_receipt_id
	   from hz_cust_accounts hca,
	       iby_fndcpt_tx_extensions ext,
	   ( select  paying_customer_id,
		 payment_instrument,
		 due_date,
		 MIN(payment_trxn_extension_id) payment_trxn_extension_id,
		 sum(amount_due_remaining) amount,
		 MAX(cust_min_amount) cust_min_amount
	     from AR_RECEIPTS_GT
	     group by paying_customer_id,
		      due_date,
		      payment_instrument ) gt
	   where ext.trxn_extension_id = gt.payment_trxn_extension_id
	   and hca.cust_account_id =  gt.paying_customer_id ';

	  l_update_where_clause :=  ' WHERE paying_customer_id =:l_paying_customer_id_array '||
				    ' AND   due_date =:l_due_date_array'||
				    ' AND   payment_instrument =:l_pmt_instrument_array ' ;
        END IF;
    --set 6
    ELSIF (p_creation_rule = 'PAYMENT_CHANNEL_CODE') THEN
	p_create_query :=
        ' select gt.paying_customer_id,
		null paying_site_use_id,
		null due_date,
		null payment_instrument,
		gt.payment_channel_code,
		gt.payment_trxn_extension_id,
		null authorization_id,
		gt.amount,
		null payment_schedule_id,
		gt.customer_bank_account_id,
		ext.instr_assignment_id,
		hca.party_id,
		null trx_number,
		gt.cust_min_amount,
		null cash_receipt_id
	 from hz_cust_accounts hca,
	     iby_fndcpt_tx_extensions ext,
	 ( select  paying_customer_id,
	       payment_trxn_extension_id,
	       sum(amount_due_remaining) amount,
	       customer_bank_account_id,
               payment_channel_code,
	       MAX(cust_min_amount) cust_min_amount
	   from AR_RECEIPTS_GT
	   group by paying_customer_id,
	            payment_trxn_extension_id,
		    customer_bank_account_id,
		    payment_channel_code) gt
	 where ext.trxn_extension_id = gt.payment_trxn_extension_id
	 and hca.cust_account_id =  gt.paying_customer_id ';

        l_update_where_clause :=  ' WHERE paying_customer_id =:l_paying_customer_id_array '||
	                          ' AND   payment_trxn_extension_id =:l_trxn_extension_id_array'||
	                          ' AND   payment_channel_code =:l_pmt_channel_code_array'||
	                          ' AND   customer_bank_account_id =:l_cust_bank_acct_id_array' ;
    --set 7
    ELSIF (p_creation_rule = 'PAYMENT_INSTRUMENT') THEN
	p_create_query :=
        ' select gt.paying_customer_id,
		null paying_site_use_id,
		null due_date,
		gt.payment_instrument,
		null payment_channel_code,
		gt.payment_trxn_extension_id,
		null authorization_id,
		gt.amount,
		null payment_schedule_id,
		null customer_bank_account_id,
		ext.instr_assignment_id,
		hca.party_id,
		null trx_number,
		gt.cust_min_amount,
		null cash_receipt_id
	 from hz_cust_accounts hca,
	     iby_fndcpt_tx_extensions ext,
	 ( select paying_customer_id,
	       payment_trxn_extension_id,
	       sum(amount_due_remaining) amount,
	       payment_instrument,
	       MAX(cust_min_amount) cust_min_amount
	   from AR_RECEIPTS_GT
	   group by paying_customer_id,
	            payment_trxn_extension_id,
		    payment_instrument) gt
	 where ext.trxn_extension_id = gt.payment_trxn_extension_id
	 and hca.cust_account_id =  gt.paying_customer_id ';

        l_update_where_clause :=  ' WHERE paying_customer_id =:l_paying_customer_id_array '||
	                          ' AND   payment_trxn_extension_id =:l_trxn_extension_id_array'||
	                          ' AND   payment_instrument =:l_pmt_instrument_array ' ;
    --set 8
    ELSIF (p_creation_rule = 'AUTHORIZATION_ID') THEN
	p_create_query :=
        ' select gt.paying_customer_id,
		null paying_site_use_id,
		null due_date,
		null payment_instrument,
		null payment_channel_code,
		gt.payment_trxn_extension_id,
		gt.authorization_id,
		gt.amount,
		null payment_schedule_id,
		null customer_bank_account_id,
		ext.instr_assignment_id,
		hca.party_id,
		null trx_number,
		gt.cust_min_amount,
		null cash_receipt_id
	 from hz_cust_accounts hca,
	     iby_fndcpt_tx_extensions ext,
	 ( select paying_customer_id,
	       payment_trxn_extension_id,
	       sum(amount_due_remaining) amount,
	       authorization_id,
	       MAX(cust_min_amount) cust_min_amount
	   from AR_RECEIPTS_GT
	   group by paying_customer_id,
	            payment_trxn_extension_id,
		    authorization_id) gt
	 where ext.trxn_extension_id = gt.payment_trxn_extension_id
	 and hca.cust_account_id =  gt.paying_customer_id ';

	l_update_where_clause :=  ' WHERE paying_customer_id =:l_paying_customer_id_array '||
	                          ' AND   payment_trxn_extension_id =:l_trxn_extension_id_array'||
	                          ' AND   authorization_id =:l_authorization_id_array' ;
    END IF;

    p_update_stmt := p_update_stmt || l_update_where_clause;

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('p_create_query   '||p_create_query);
	arp_debug.debug('p_update_stmt    '||p_update_stmt);
	arp_debug.debug('p_inv_rct_mp_qry '||p_inv_rct_mp_qry);
	arp_debug.debug('build_queries()-');
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
      arp_debug.debug('build_queries : error code() '|| to_char(SQLCODE));
      raise;
END build_queries;



--validate and populate the receipt numbers
PROCEDURE populate_receipt_numbers(  p_rcpt_method_name  IN  ar_receipt_methods.name%TYPE,
                                     p_sob_id            IN  ar_batches.set_of_books_id%TYPE,
				     p_batch_date        IN  DATE,
				     p_receipt_method_id IN  NUMBER,
                                     p_receipt_num_array OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
                                     p_count             IN  NUMBER) IS
   l_error_flag               VARCHAR2(1) := 'N';
   l_status                   NUMBER;
   l_doc_sequence_value       ra_customer_trx.doc_sequence_value%TYPE;
   l_doc_sequence_id          ra_customer_trx.doc_sequence_id%TYPE;
 BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('populate_receipt_numbers()+');
	arp_debug.debug('p_rcpt_method_name  :'||p_rcpt_method_name);
	arp_debug.debug('p_receipt_method_id :'||p_receipt_method_id);
	arp_debug.debug('p_sob_id            :'||p_sob_id);
	arp_debug.debug('p_batch_date        :'||p_batch_date);
    END IF;

    FOR i IN 1..p_count LOOP
	l_status := FND_SEQNUM.GET_SEQ_VAL(
		    222,
		    p_rcpt_method_name,
		    p_sob_id,
		    'A',
		    p_batch_date,
		    l_doc_sequence_value,
		    l_doc_sequence_id,
		    'Y',
		    'Y');

	l_error_flag := 'N';

	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_debug.debug(' l_status  '||l_status);
	END IF;

	IF l_status = FND_SEQNUM.SEQSUCC AND
	   l_doc_sequence_value is NULL THEN
	    arp_debug.debug ( 'ERROR!!!! l_doc_sequence_value is not generated');
	    l_error_flag := 'Y';

	ELSIF  l_status = FND_SEQNUM.NOASSIGN  THEN
	    arp_debug.debug ( 'ERROR  THERE ARE NO DOC SEQ ASSIGNMENT!!!!');
	    l_error_flag := 'Y';
	ELSIF l_status <> FND_SEQNUM.SEQSUCC THEN
	    arp_debug.debug ( 'ERROR  ERROR IN FND ROUTINE !!!!');
	    l_error_flag := 'Y';
	END IF;

	IF l_error_flag = 'Y' THEN
	    exit;
	END IF;

	--Bug 7242683 removed concatenation of receipt_method_id
	p_receipt_num_array(i) := l_doc_sequence_value;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('populate_receipt_numbers()-');
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
	 arp_debug.debug('Exception : populate_receipt_numbers() '|| SQLERRM);
	 G_ERROR := 'Y';
END populate_receipt_numbers;




PROCEDURE process_selected_receipts( p_receipt_method_id   IN  ar_cash_receipts.receipt_method_id%TYPE,
	                             p_batch_id            IN  ar_batches.batch_id%TYPE,
				     p_approval_mode       IN  VARCHAR2 DEFAULT 'APPROVE' ) IS

    l_set_of_books_id          ar_batches.set_of_books_id%TYPE;
    l_name                     ar_receipt_methods.name%TYPE;
    l_batch_date               ar_batches.batch_date%TYPE;
    l_currency_code            ar_batches.currency_code%TYPE;
    l_rec_creation_rule_code   ar_receipt_methods.receipt_creation_rule_code%TYPE;
    l_receipt_number           ar_cash_receipts.receipt_number%TYPE;
    l_called_from              VARCHAR2(15);
    l_cash_receipt_id          NUMBER(15);
    l_installment              NUMBER;
    l_create_stmt              VARCHAR2(2000);
    l_update_stmt              VARCHAR2(2000);
    l_error_flag               VARCHAR2(1) := 'N';
    l_return_status            VARCHAR2(1);
    l_err_code                 VARCHAR2(240);
    l_process_payment_flag     NUMBER;
    l_create_stmt_c            INTEGER;
    l_rows_fetched             INTEGER;
    l_index                    INTEGER;
    l_gt_id                    INTEGER;

    l_amt_applied             NUMBER;
    l_cust_site_min_rec_amt   NUMBER;
    l_rec_method_min_rec_amt  NUMBER;
    l_min_rec_amount_allowed  NUMBER;
    l_creation_method_code	    ar_receipt_classes.creation_method_code%type;
    l_remittance_bank_account_id    ar_receipt_method_accounts_all.remit_bank_acct_use_id%TYPE;
    l_state			    ar_receipt_classes.creation_status%TYPE;
    l_old_cash_receipt_id	    ar_cash_receipts.cash_receipt_id%TYPE;

    l_paying_customer_id_array    DBMS_SQL.NUMBER_TABLE;
    l_paying_site_use_id_array    DBMS_SQL.NUMBER_TABLE;
    l_due_date_array              DBMS_SQL.DATE_TABLE;
    l_pmt_instrument_array        DBMS_SQL.VARCHAR2_TABLE;
    l_pmt_channel_code_array      DBMS_SQL.VARCHAR2_TABLE;
    l_pmt_trxn_extn_id_array      DBMS_SQL.NUMBER_TABLE;
    l_authorization_id_array      DBMS_SQL.NUMBER_TABLE;
    l_cust_bank_acct_id_array     DBMS_SQL.NUMBER_TABLE;
    l_amount_array                DBMS_SQL.NUMBER_TABLE;
    l_receipt_id_array            DBMS_SQL.NUMBER_TABLE;
    l_receipt_num_array           DBMS_SQL.VARCHAR2_TABLE;
    l_ps_id_array		  DBMS_SQL.NUMBER_TABLE;
    l_gt_id_array                 DBMS_SQL.NUMBER_TABLE;

    l_err_rcpt_num_array          DBMS_SQL.VARCHAR2_TABLE;
    l_err_code_array              DBMS_SQL.VARCHAR2_TABLE;
    l_err_rcpt_index              INTEGER;
    l_cc_err_code_array           DBMS_SQL.VARCHAR2_TABLE;
    l_cc_err_text_array           DBMS_SQL.VARCHAR2_TABLE;

    l_apply_fail                  VARCHAR2(1) := 'N';
    l_pay_process_fail            VARCHAR2(1) := 'N';
    l_exchange_rate	          ar_batches.exchange_rate%TYPE;
    l_exchange_date	          ar_batches.exchange_date%TYPE;
    l_exchange_rate_type	  ar_batches.exchange_rate_type%TYPE;
    l_rec_inher_inv_num_flag      VARCHAR2(1) := 'N';

    l_cc_error_code               VARCHAR2(30);
    l_cc_error_text               VARCHAR2(2000);

    l_inv_rct_mp_qry              VARCHAR2(2000);

    TYPE rcpt_info_type  IS REF CURSOR;
    rcpt_info_cursor    rcpt_info_type;

    TYPE rcpt_info_rec_type IS RECORD
    (   paying_customer_id         number,
	paying_site_use_id         number,
	due_date                   date,
	payment_instrument         varchar2(30),
	payment_channel_code       varchar2(30),
	payment_trxn_extension_id  number,
	authorization_id           number,
	amount                     number,
	payment_schedule_id        number,
	customer_bank_account_id   number,
	instr_assignment_id        number,
	party_id                   number,
	trx_number                 varchar2(30),
	cust_min_amount		   number,
	cash_receipt_id            number);

    TYPE rcpt_info_rec IS TABLE OF rcpt_info_rec_type INDEX BY BINARY_INTEGER;
    l_rcpt_info_tab rcpt_info_rec;

    TYPE rcpt_appl_tab IS TABLE OF receipt_info_rec INDEX BY BINARY_INTEGER;
    l_rcpt_appl_tab rcpt_appl_tab;

    l_from_cr_id NUMBER;
    l_to_cr_id   NUMBER;
    l_cnt        NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_unbal_rcpt_tab  ARP_BALANCE_CHECK.unbalanced_receipts;

    CURSOR unbal_rec_applns( p_cr_id NUMBER, p_gt_id NUMBER) IS
    SELECT ard.source_id, ard.source_id_secondary, trx.upgrade_method,
           ra.applied_customer_trx_id, ra.payment_schedule_id, ra.applied_payment_schedule_id
    FROM   ar_receivable_applications ra,
           ar_distributions ard,
           ra_customer_trx trx,
           ar_receipts_gt rgt
    WHERE  ra.cash_receipt_id         = p_cr_id
    AND    ra.applied_customer_trx_id IS NOT NULL
    AND    ard.source_id_secondary    = ra.receivable_application_id
    AND    ard.source_table_secondary = 'RA'
    AND    ard.source_table           = 'RA'
    AND    trx.customer_trx_id        = ra.applied_customer_trx_id
    AND    rgt.cash_receipt_id        = p_cr_id
    AND    rgt.gt_id                  = p_gt_id;


    CURSOR appl_rec_cur( p_gt_id NUMBER) IS
    SELECT /*+INDEX(rgt AR_RECEIPTS_GT_N1) INDEX(inv_ps AR_PAYMENT_SCHEDULES_U1) INDEX(ps AR_PAYMENT_SCHEDULES_U2) */
           cr.pay_from_customer customer_id,
	   crh.gl_date cr_gl_date,
	   cr.amount cr_amount,
	   cr.customer_site_use_id cust_site_use_id,
	   cr.receipt_date ,
	   cr.currency_code cr_currency_code,
	   cr.exchange_rate cr_exchange_rate,
	   ps.payment_schedule_id cr_payment_schedule_id,
	   cr.remit_bank_acct_use_id remittance_bank_account_id,
	   cr.receipt_method_id,
	   cr.cash_receipt_id,
	   inv_ps.amount_due_remaining inv_bal_amount,
	   inv_ps.amount_due_original inv_orig_amount,
	   ctt.allow_overapplication_flag allow_over_app,
	   rma.unapplied_ccid,
	   ed.code_combination_id ed_disc_ccid,
	   uned.code_combination_id uned_disc_ccid,
	   crh.batch_id,
	   rgt.customer_trx_id,
	   (select 'Y' rev_rec_flag
	    from ra_customer_trx_lines ctl
	    where ctl.customer_trx_id = rgt.customer_trx_id
	    and ctl.autorule_complete_flag||'' = 'N'
	    and rownum = 1 ) rev_rec_flag,
	   (select 'Y' def_tax_flag
	    from  ra_cust_trx_line_gl_dist gld
	    where gld.account_class = 'TAX'
	    and   gld.customer_trx_id = rgt.customer_trx_id
	    and   gld.collected_tax_ccid IS NOT NULL
	    and rownum = 1 ) def_tax_flag,
	   ot.cust_trx_type_id cust_trx_type_id ,
	   ot.trx_due_date trx_due_date,
	   ot.invoice_currency_code trx_currency_code,
	   ot.trx_exchange_rate trx_exchange_rate,
	   ot.trx_date trx_date ,
	   ot.trx_gl_date trx_gl_date,
	   ot.calc_discount_on_lines_flag calc_discount_on_lines_flag,
	   ot.partial_discount_flag partial_discount_flag,
	   ot.allow_overapplication_flag allow_overappln_flag,
	   ot.natural_application_only_flag natural_appln_only_flag,
	   ot.creation_sign creation_sign,
	   ot.payment_schedule_id applied_payment_schedule_id,
	   greatest(crh.gl_date,ot.trx_gl_date,
		    decode(ar_receipt_lib_pvt.pg_profile_appln_gl_date_def,
			   'INV_REC_SYS_DT', sysdate,
			   'INV_REC_DT', ot.trx_gl_date,
                           ot.trx_gl_date)) ot_gl_date,
	   ot.term_id term_id,
	   ot.amount_due_original amount_due_original,
	   ot.amount_line_items_original amount_line_items_original,
	   arp_util.CurrRound(ot.balance_due_curr_unformatted,
			     ot.invoice_currency_code) amount_due_remaining,
	   ot.discount_taken_earned discount_taken_earned,
	   ot.discount_taken_unearned discount_taken_unearned,
  	   ot.amount_line_items_original line_items_original,
	   ot.amount_line_items_remaining line_items_remaining,
	   ot.tax_original tax_original,
	   ot.tax_remaining tax_remaining,
	   ot.freight_original freight_original,
	   ot.freight_remaining freight_remaining,
	   Null rec_charges_charged,
	   ot.receivables_charges_remaining rec_charges_remaining,
	   ot.location location,
	   rgt.amount_due_remaining amount_apply
    FROM   ar_cash_receipts cr,
	   ar_cash_receipt_history crh,
	   ar_payment_schedules ps,
	   ra_cust_trx_types ctt,
	   ar_payment_schedules inv_ps,
	   ar_receipt_method_accounts rma,
	   ar_receivables_trx ed,
	   ar_receivables_trx uned,
	   ar_open_trx_v ot,
	   ar_receipts_gt rgt
    WHERE rgt.cash_receipt_id IS NOT NULL
    AND  rgt.cash_receipt_id = cr.cash_receipt_id
    AND  cr.cash_receipt_id = crh.cash_receipt_id
    AND  cr.cash_receipt_id = ps.cash_receipt_id
    AND  inv_ps.payment_schedule_id = rgt.payment_schedule_id
    AND  inv_ps.cust_trx_type_id = ctt.cust_trx_type_id
    AND  crh.current_record_flag	= 'Y'
    AND  rma.receipt_method_id	= cr.receipt_method_id
    AND  rma.remit_bank_acct_use_id	= cr.remit_bank_acct_use_id
    AND  ot.payment_schedule_id       = rgt.payment_schedule_id
    AND  rgt.gt_id = p_gt_id
    AND  rma.edisc_receivables_trx_id = ed.receivables_trx_id (+)
    AND  rma.unedisc_receivables_trx_id = uned.receivables_trx_id (+)
    ORDER BY rgt.cash_receipt_id,
             rgt.amount_due_remaining;


  CURSOR rec_ps_cur(l_rec_num VARCHAR2) IS
    SELECT payment_schedule_id,
           paying_customer_id,
	   customer_trx_id
    FROM ar_receipts_gt
    WHERE gt_id = l_gt_id
    AND receipt_number = l_rec_num
    AND cash_receipt_id is NULL;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('process_selected_receipts()+');
	arp_debug.debug('batch_id             '||p_batch_id);
	arp_debug.debug('p_receipt_method_id  '||p_receipt_method_id);
    END IF;

    pg_request_id             := arp_standard.profile.request_id;

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('request_id :'||pg_request_id);
    END IF;

    /** set the called_from value based on receipt method properties.If confirm_flag
        value associated to current receipt method is N then l_called_from value is
	set to AUTORECAPI2, this will enable us to skip certain flows like accounting
	creation and payment processing. */
    SELECT DECODE(rc.confirm_flag,'Y','AUTORECAPI','AUTORECAPI2'),
           nvl(rm.receipt_creation_rule_code,'MANUAL'),
	   nvl(rm.receipt_inherit_inv_num_flag,'N')
    INTO   l_called_from,
           l_rec_creation_rule_code,
           l_rec_inher_inv_num_flag
    FROM   ar_receipt_classes rc,
	   ar_receipt_methods rm
    WHERE rm.receipt_method_id = p_receipt_method_id
    AND rm.receipt_class_id = rc.receipt_class_id;

    SELECT b.set_of_books_id,
           r.name,
           b.batch_date,
           b.currency_code,
	   DECODE(exchange_rate_type,'User',exchange_rate,NULL),
           exchange_date,
           exchange_rate_type
    INTO   l_set_of_books_id,
           l_name,
           l_batch_date,
           l_currency_code,
           l_exchange_rate,
           l_exchange_date,
	   l_exchange_rate_type
    FROM   ar_batches b,
           ar_receipt_methods r
    WHERE  b.batch_id = p_batch_id
    AND    r.receipt_method_id = p_receipt_method_id
    AND    b.receipt_method_id = r.receipt_method_id;

    --set the process payment flag
    IF   nvl(l_called_from,'NONE') <> 'AUTORECAPI' THEN
         l_process_payment_flag := 1;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('p_creation_rule         '|| l_rec_creation_rule_code);
	arp_debug.debug('l_called_from           '|| l_called_from);
	arp_debug.debug('l_process_payment_flag  '|| l_process_payment_flag);
	arp_debug.debug('l_rec_inher_inv_num_flag '|| l_rec_inher_inv_num_flag);
	arp_debug.debug('l_set_of_books_id       '|| l_set_of_books_id);
	arp_debug.debug('l_name                  '|| l_name);
	arp_debug.debug('l_batch_date            '|| l_batch_date);
	arp_debug.debug('l_currency_code         '|| l_currency_code);
	arp_debug.debug('l_exchange_rate         '|| l_exchange_rate);
	arp_debug.debug('l_exchange_date         '|| l_exchange_date);
	arp_debug.debug('l_exchange_rate_type    '|| l_exchange_rate_type);
    END IF;

    --populate the query string based on creation_rule_code
    build_queries( l_rec_creation_rule_code,
                   p_approval_mode,
                   l_create_stmt,
		   l_update_stmt,
		   l_inv_rct_mp_qry );

    IF p_approval_mode = 'RE-APPROVAL' THEN
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('Executing invoice receipt mapping query for batch '||p_batch_id);
      END IF;

      EXECUTE IMMEDIATE l_inv_rct_mp_qry USING p_batch_id;
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_debug.debug('Number of rows inserted '||SQL%ROWCOUNT);
      END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        arp_debug.debug('ar_receipts_gt dump 1');
	dump_ar_receipts_gt;
    END IF;

    OPEN rcpt_info_cursor FOR  l_create_stmt;

    l_index := 0;

    LOOP
        FETCH  rcpt_info_cursor BULK COLLECT INTO l_rcpt_info_tab LIMIT MAX_ARRAY_SIZE;

	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_debug.debug('current fetch count   '|| l_rcpt_info_tab.count);
	END IF;

	IF l_rcpt_info_tab.count = 0 THEN
	    EXIT;
	END IF;

	/**In order to have intermediate commits with in the process(for better performance and
	   to support processing of large volumes of data),we have devided the data into various
	   logical batches based on value of MAX_ARRAY_SIZE.Each of these batch gets processed
	   and committed to the database before continuing the loop for remaining set of data.

   	   The field gt_id is used for logically seperating the data among different batches.*/
	l_gt_id := nvl(l_gt_id,1) + 1;

	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_debug.debug('Value of l_gt_id '|| l_gt_id );
	END IF;

	IF  p_approval_mode <> 'RE-APPROVAL' THEN
/*	  IF l_rec_creation_rule_code <> 'PER_INVOICE' OR
	     l_rec_inher_inv_num_flag <> 'Y' THEN
	    --validate and populate the receipt numbers
	    populate_receipt_numbers( l_name,
				      l_set_of_books_id,
				      l_batch_date,
				      p_receipt_method_id,
				      l_receipt_num_array,
				      l_rcpt_info_tab.count );
	  END IF;

	  IF PG_DEBUG in ('Y', 'C') THEN
	      arp_debug.debug('Receipt numbers populated are   '|| l_receipt_num_array.count);
	      arp_debug.debug('l_rcpt_info_tab.FIRST '|| l_rcpt_info_tab.FIRST);
	      arp_debug.debug('l_rcpt_info_tab.LAST  '|| l_rcpt_info_tab.LAST);
	  END IF;
*/
	  --reset the MIN AMOUNT CHECK array
	  l_err_rcpt_index := 0;
	  l_err_rcpt_num_array.DELETE;

	  l_from_cr_id := NULL;
	  l_to_cr_id   := NULL;
	  l_cnt        := 0;

	  --loop over the array to create receipts
	  FOR i IN l_rcpt_info_tab.FIRST..l_rcpt_info_tab.LAST LOOP

	      l_receipt_id_array(i)	  := null;

	      IF l_rec_creation_rule_code = 'PER_INVOICE' AND
		 l_rec_inher_inv_num_flag = 'Y' THEN
		 l_receipt_num_array( i ) := l_rcpt_info_tab(i).trx_number;
              ELSE
                 -- Stamp receipt_number with dummy increasing varaible so that
                 -- l_err_rcpt_num_array will have receipt_number populated
                 l_index := l_index + 1;
                 l_receipt_num_array(i)  := l_index;
	      END IF;

	      IF PG_DEBUG in ('Y', 'C') THEN
		arp_debug.debug('Checking minimum receipt amount setup at customer level');
	      END IF;

	      /* Set the minimum receipt amount got from main select query */
	      l_cust_site_min_rec_amt := l_rcpt_info_tab(i).cust_min_amount;

	      /* Get the minimum receipt amount for per_customer / due_date from site level */
	      IF  l_rec_creation_rule_code = 'PER_CUSTOMER' OR
		  l_rec_creation_rule_code = 'PER_CUSTOMER_DUE_DATE' THEN

	       BEGIN

	      /* Defaulting paying site for per_customer and per_customer_due_date as it is always NULL*/
		  IF l_rcpt_info_tab(i).paying_site_use_id IS NULL then

		  IF PG_DEBUG in ('Y', 'C') THEN
		     arp_debug.debug('Default paying_site_use_id');
		  END IF;

		    SELECT site_use.site_use_id
		    INTO   l_rcpt_info_tab(i).paying_site_use_id
		    FROM   hz_cust_site_uses site_use,
			   hz_cust_acct_sites acct_site
		    WHERE  acct_site.cust_account_id   =  l_rcpt_info_tab(i).paying_customer_id
		    AND  acct_site.status        = 'A'
		    AND  site_use.cust_acct_site_id  = acct_site.cust_acct_site_id
		    AND  site_use.site_use_code = nvl('BILL_TO', site_use.site_use_code)
		    AND  site_use.status        = 'A'
		    AND  site_use.primary_flag  = 'Y';

		  END IF;
	      /* Get the minimum receipt amount for per_customer / due_date defined at site level */
	      IF PG_DEBUG in ('Y', 'C') THEN
		     arp_debug.debug('Get Minimum Receipt Amount for the paying_site_use_id');
	      END IF;

		  Select  cpa.auto_rec_min_receipt_amount
		  into	l_cust_site_min_rec_amt
		  From	hz_customer_profiles cp,
			  hz_cust_profile_amts cpa
		  WHERE	cp.cust_account_profile_id = cpa.cust_account_profile_id
		  AND	cpa.currency_code = l_currency_code
		  AND	cp.site_use_id = l_rcpt_info_tab(i).paying_site_use_id;

		  IF l_cust_site_min_rec_amt IS NULL THEN

		      IF PG_DEBUG in ('Y', 'C') THEN
			arp_debug.debug('Min Receipt Amount allowed at site is NULL');
			arp_debug.debug('Defaulting Min Receipt Amount allowed from Cust Account Level');
		      END IF;

		      l_cust_site_min_rec_amt := l_rcpt_info_tab(i).cust_min_amount;
		  END IF;

	       EXCEPTION
		  WHEN NO_DATA_FOUND THEN
			  l_err_code := NULL;
		  WHEN OTHERS THEN
			  null;
	       END;
	      END IF;


	      BEGIN

	      IF PG_DEBUG in ('Y', 'C') THEN
		  arp_debug.debug('Checking minimum receipt amount setup at receipt method bank level');
		  arp_debug.debug('Calling Default_Receipt_Method_Info');
	      END IF;

		  ar_receipt_lib_pvt.Default_Receipt_Method_Info(
					  p_receipt_method_id	=> p_receipt_method_id,
					  p_currency_code		=> l_currency_code,
					  p_receipt_date		=> l_batch_date,
					  p_remittance_bank_account_id => l_remittance_bank_account_id,
					  p_state			=> l_state,
					  p_creation_method_code	=> l_creation_method_code,
					  p_called_from		=> l_called_from,
					  p_return_status		=> l_return_status);

		  Select min_receipt_amount
		  into l_rec_method_min_rec_amt
		  from ar_receipt_method_accounts
		  where receipt_method_id = p_receipt_method_id
		  and remit_bank_acct_use_id = l_remittance_bank_account_id;

	       EXCEPTION
		  WHEN NO_DATA_FOUND THEN
			  l_err_code := NULL;
		  WHEN OTHERS THEN
			  null;
	      END;

	     /* Error if the receipt amount is less than greater of the minimum receipt amount
		defined at customer site/account level or receipt method bank level.*/
	      IF PG_DEBUG in ('Y', 'C') THEN
		  arp_debug.debug('l_cust_site_min_rec_amt '|| l_cust_site_min_rec_amt);
		  arp_debug.debug('l_rec_method_min_rec_amt '|| l_rec_method_min_rec_amt);
	      END IF;

		  IF nvl(l_cust_site_min_rec_amt,0) > nvl(l_rec_method_min_rec_amt,0) THEN
		      l_min_rec_amount_allowed := l_cust_site_min_rec_amt;
		      l_err_code		 := 'ARZCAR_CUST_MIN_AMT';
		  ELSE
		      l_min_rec_amount_allowed := l_rec_method_min_rec_amt;
		      l_err_code		 := 'ARZCAR_BANK_MIN_AMT';
		  END IF;

		  IF l_rcpt_info_tab(i).amount < nvl(l_min_rec_amount_allowed,0) THEN
		      l_err_rcpt_index                         := l_err_rcpt_index + 1;
		      l_err_rcpt_num_array( l_err_rcpt_index ) := l_receipt_num_array(i);
		      l_err_code_array( l_err_rcpt_index )     := l_err_code;
		  ELSE
		      l_err_code := NULL;
		  END IF;


	      IF PG_DEBUG in ('Y', 'C') THEN
		  arp_debug.debug('l_err_code  '|| l_err_code );
		  arp_debug.debug('l_rcpt_info_tab(i).amount ' || l_rcpt_info_tab(i).amount);
	      END IF;

	      l_ps_id_array(i)              := l_rcpt_info_tab(i).payment_schedule_id;
	      l_gt_id_array(i)              := l_gt_id;
	      l_cust_bank_acct_id_array(i)  := l_rcpt_info_tab(i).customer_bank_account_id;
	      l_paying_customer_id_array(i) := l_rcpt_info_tab(i).paying_customer_id;
	      l_paying_site_use_id_array(i) := l_rcpt_info_tab(i).paying_site_use_id;
	      l_due_date_array(i)           := l_rcpt_info_tab(i).due_date;
	      l_pmt_instrument_array(i)     := l_rcpt_info_tab(i).payment_instrument;
	      l_pmt_channel_code_array(i)   := l_rcpt_info_tab(i).payment_channel_code;
	      l_pmt_trxn_extn_id_array(i)   := l_rcpt_info_tab(i).payment_trxn_extension_id;
	      l_authorization_id_array(i)   := l_rcpt_info_tab(i).authorization_id;



	      --if the minimum amount check of customer's profile succeeds then continue with the process
	      IF nvl(l_err_code,' ') <> 'ARZCAR_CUST_MIN_AMT' AND
		 nvl(l_err_code,' ') <> 'ARZCAR_BANK_MIN_AMT' THEN

		  IF l_rcpt_info_tab(i).payment_schedule_id IS NOT NULL THEN
		      select nvl(terms_sequence_number,1)
		      into l_installment
		      from ar_payment_schedules
		      where payment_schedule_id = l_rcpt_info_tab(i).payment_schedule_id;
		  END IF;

		  IF PG_DEBUG in ('Y', 'C') THEN
		      arp_debug.debug( 'l_installment = '|| l_installment);
		  END IF;

		  --set the variables to cache
		  g_rcpt_creation_rec.party_id         := l_rcpt_info_tab(i).party_id;
		  g_rcpt_creation_rec.pmt_channel_code := l_rcpt_info_tab(i).payment_channel_code;
		  g_rcpt_creation_rec.assignment_id    := l_rcpt_info_tab(i).instr_assignment_id;

		  IF PG_DEBUG in ('Y', 'C') THEN
		      arp_debug.debug('Calling create receipt ');
		  END IF;

          -- Stamp receipt_number as null, so that receipt API copies
          -- doc seq to receipt_number when inher_inv_num_flag is not set
          IF l_rec_creation_rule_code <> 'PER_INVOICE' OR
             l_rec_inher_inv_num_flag <> 'Y' THEN
             l_receipt_num_array(i)  := null;
          END IF;

		  --receipt creation
		  create_receipt (l_rcpt_info_tab(i).amount,
				  l_receipt_num_array( i ),
				  l_batch_date,
				  l_rcpt_info_tab(i).paying_customer_id,
				  l_installment,
				  l_rcpt_info_tab(i).paying_site_use_id,
				  p_receipt_method_id,
				  l_rcpt_info_tab(i).payment_trxn_extension_id,
				  l_called_from,
				  pg_request_id,
				  p_batch_id,
				  l_exchange_rate,
				  l_exchange_date,
				  l_exchange_rate_type,
				  l_currency_code,
				  l_remittance_bank_account_id,
				  l_cash_receipt_id,
				  l_return_status );

          -- Error handling depends on receipt_number, so stamp back the value
          IF l_rec_creation_rule_code <> 'PER_INVOICE' OR
             l_rec_inher_inv_num_flag <> 'Y' THEN
             l_receipt_num_array(i)  := l_index;
          END IF;

		  IF PG_DEBUG in ('Y', 'C') THEN
		      arp_debug.debug( 'Returning from create_receipt ');
		      arp_debug.debug( 'l_cash_receipt_id = '|| l_cash_receipt_id);
		      arp_debug.debug( 'l_return_status   = '|| l_return_status);
		  END IF;

		  IF nvl(l_return_status,'N') = 'S' THEN
		      l_receipt_id_array(i) := l_cash_receipt_id;

		      IF l_cnt = 0 THEN
		       l_cnt        := l_cnt + 1;
		       l_from_cr_id := l_receipt_id_array(i);
		       l_to_cr_id   := l_receipt_id_array(i);
		      END IF;

		      IF l_from_cr_id > l_receipt_id_array(i) THEN
		       l_from_cr_id := l_receipt_id_array(i);
		      END IF;

		      IF l_to_cr_id < l_receipt_id_array(i) THEN
		       l_to_cr_id   := l_receipt_id_array(i);
		      END IF;

                      /* need to stamp the batch_id immediately inorder to succesfully execute the reapproval
		         process in case  the program gets errored/terminated before the receipt is processed
			completely  */
		      UPDATE ar_cash_receipt_history
		      SET batch_id             = p_batch_id,
			created_by             =  pg_created_by,
			last_update_date       = sysdate,
			last_updated_by        =  pg_created_by,
			last_update_login      = pg_last_update_login,
			request_id             = pg_request_id,
			program_application_id = pg_program_application_id,
			program_id             = pg_program_id,
			program_update_date    = sysdate
		      WHERE cash_receipt_id = l_cash_receipt_id;
		  ELSE
		      l_err_rcpt_index                         := l_err_rcpt_index + 1;
		      l_err_rcpt_num_array( l_err_rcpt_index ) := l_receipt_num_array(i);
		      l_err_code_array( l_err_rcpt_index )     := 'RCPT_CREATION_FAILED';
		      l_receipt_id_array( i ) := null;
		  END IF;
	      END IF;

	  END LOOP; -- end of create/process receipts loop

	    l_unbal_rcpt_tab.delete;

		arp_standard.debug('Receipt_create: Min receipt id: '||l_from_cr_id);
		arp_standard.debug('Receipt_create: Max receipt id: '||l_to_cr_id);

  IF l_from_cr_id IS NOT NULL AND l_to_cr_id IS NOT NULL THEN

		arp_standard.debug(' Checking Journal Balance in Bulk: for receipt_create');
		ARP_BALANCE_CHECK.CHECK_RECP_BALANCE_BULK(
			p_cr_id_low          => l_from_cr_id,
			p_cr_id_high         => l_to_cr_id,
			p_unbalanced_cr_tbl  => l_unbal_rcpt_tab );

		arp_standard.debug('Receipt_create: Count of unbalanced receipts:'||l_unbal_rcpt_tab.COUNT);

    --loop over the array to mark unbalanced receipts
    IF l_unbal_rcpt_tab.COUNT > 0 THEN

     IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Receipt_create: inside, l_unbal_rcpt_tab.FIRST : '||l_unbal_rcpt_tab.FIRST);
      arp_standard.debug('Receipt_create: inside, l_unbal_rcpt_tab.LAST : '||l_unbal_rcpt_tab.LAST);
     END IF;

     FOR i IN l_unbal_rcpt_tab.FIRST..l_unbal_rcpt_tab.LAST LOOP
	    FOR j IN l_rcpt_info_tab.FIRST..l_rcpt_info_tab.LAST LOOP

	     IF PG_DEBUG in ('Y', 'C') THEN
	      arp_standard.debug('Receipt_create: inside, l_unbal_rcpt_tab(i).cash_receipt_id : '||l_unbal_rcpt_tab(i).cash_receipt_id);
	      arp_standard.debug('Receipt_create: inside, l_receipt_id_array(j) : '||l_receipt_id_array(j));
	     END IF;

	     IF l_receipt_id_array(j) = l_unbal_rcpt_tab(i).cash_receipt_id THEN
		    l_err_rcpt_index                         := l_err_rcpt_index + 1;
		    l_err_rcpt_num_array( l_err_rcpt_index ) := l_receipt_num_array(j);
		    l_err_code_array( l_err_rcpt_index )     := 'RCPT_CREATION_FAILED';
		    IF PG_DEBUG in ('Y','C') THEN
		     arp_standard.debug('Delete unbalanced receipt with receipt_id : '||l_receipt_id_array(j));
		    END IF;

		    delete from ar_payment_schedules
		    where cash_receipt_id = l_receipt_id_array(j);

		    IF PG_DEBUG in ('Y','C') THEN
		     arp_standard.debug ( ' rows DELETED PS = ' || SQL%ROWCOUNT );
		    END IF;

		    delete from ar_distributions
		    where source_table = 'CRH'
		    and source_id in
		    ( select cash_receipt_history_id
		      from ar_cash_receipt_history
		      where cash_receipt_id = l_receipt_id_array(j));

		    IF PG_DEBUG in ('Y','C') THEN
		      arp_standard.debug ( ' rows DELETED AR_DIST = ' || SQL%ROWCOUNT );
		    END IF;

		    delete from ar_distributions
		    where source_table = 'RA'
		    and source_id in
		    ( select receivable_application_id
		      from ar_receivable_applications
		      where cash_receipt_id = l_receipt_id_array(j));

		    IF PG_DEBUG in ('Y','C') THEN
		     arp_standard.debug ( ' rows DELETED AR_DIST2 = ' || SQL%ROWCOUNT );
		    END IF;

		    delete from ar_receivable_applications
		    where cash_receipt_id = l_receipt_id_array(j);

		    IF PG_DEBUG in ('Y','C') THEN
		     arp_standard.debug ( ' rows DELETED REC_APPS = ' || SQL%ROWCOUNT );
		    END IF;

		    delete from ar_cash_receipt_history
		    where cash_receipt_id = l_receipt_id_array(j);

		    IF PG_DEBUG in ('Y','C') THEN
		     arp_standard.debug ( ' rows DELETED CRH = ' || SQL%ROWCOUNT );
		    END IF;

		    delete from ar_cash_receipts
		    where cash_receipt_id = l_receipt_id_array(j);

		    IF PG_DEBUG in ('Y','C') THEN
		     arp_standard.debug ( ' rows DELETED CR  = ' || SQL%ROWCOUNT );
		    END IF;

		    l_receipt_id_array(j)                    := null;
		    EXIT;
	     END IF;
      END LOOP;
	   END LOOP;
    END IF;
  END IF;

	  --loop over the array to do payment processing if needed
	  FOR i IN l_rcpt_info_tab.FIRST..l_rcpt_info_tab.LAST LOOP

/*      IF l_unbal_rcpt_tab.EXISTS(l_receipt_id_array(i)) THEN
		    l_err_rcpt_index                         := l_err_rcpt_index + 1;
		    l_err_rcpt_num_array( l_err_rcpt_index ) := l_receipt_num_array(i);
		    l_err_code_array( l_err_rcpt_index )     := 'RCPT_CREATION_FAILED';
		    l_receipt_id_array( i ) := null;
		  END IF;
*/
		  --payment processing
		  IF l_process_payment_flag = 1 AND l_receipt_id_array(i) is not null THEN

		      IF PG_DEBUG in ('Y', 'C') THEN
			  arp_debug.debug( 'Calling process_payments ');
			  arp_standard.debug( 'l_receipt_id_array(i)= '|| l_receipt_id_array(i));
		      END IF;

		      l_cc_error_code := null;
		      l_cc_error_text := null;

		      process_payments(l_receipt_id_array(i),
				       null,--p_pmt_trxn_id,
				       pg_request_id,
				       p_batch_id,
				       l_called_from,
				       l_cc_error_code,
				       l_cc_error_text,
				       l_return_status);

		      IF PG_DEBUG in ('Y', 'C') THEN
			  arp_debug.debug( 'Returning from process_payments ');
			  arp_debug.debug( 'l_return_status = '|| l_return_status);
		      END IF;

		     /*------------------------------------------------------+
		      | Check the return status from Process_Payment         |
		      +------------------------------------------------------*/
		     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			 l_pay_process_fail := 'Y';

			 l_err_rcpt_index                         := l_err_rcpt_index + 1;
			 l_err_rcpt_num_array( l_err_rcpt_index ) := l_receipt_num_array(i);
			 l_err_code_array( l_err_rcpt_index )     := 'PROCESS_PAYMENT_FAILED';
			 l_cc_err_code_array( l_err_rcpt_index )  := l_cc_error_code;
			 l_cc_err_text_array( l_err_rcpt_index )  := l_cc_error_text;
		     END IF;
		  END IF;

	  END LOOP; -- end of process receipts loop

	  IF PG_DEBUG in ('Y', 'C') THEN
	      arp_debug.debug( 'Updating ar_receipts_gt with receipt number');
	  END IF;

	  /**Stamp receipt_id and receipt number to the gt table*/
	  update_ar_receipts_gt ( p_creation_rule            => l_rec_creation_rule_code,
				  p_update_stmt              => l_update_stmt,
				  p_cr_id_array              => l_receipt_id_array,
				  p_cr_number_array          => l_receipt_num_array,
				  p_gt_id_array              => l_gt_id_array,
				  p_ps_id_array              => l_ps_id_array,
				  p_paying_customer_id_array => l_paying_customer_id_array,
				  p_pmt_instrument_array     => l_pmt_instrument_array,
				  p_paying_site_use_id_array => l_paying_site_use_id_array,
				  p_due_date_array           => l_due_date_array,
				  p_pmt_channel_code_array   => l_pmt_channel_code_array,
				  p_cust_bank_acct_id_array  => l_cust_bank_acct_id_array,
				  p_trxn_extension_id_array  => l_pmt_trxn_extn_id_array,
				  p_authorization_id_array   => l_authorization_id_array );

	  --loop through all the receipts which failed the min amount condition and insert
	  --them into exceptions table
	  FOR k IN 1..l_err_rcpt_index LOOP
	    IF PG_DEBUG in ('Y', 'C') THEN
		arp_debug.debug( 'loop through errored receipts '||l_err_rcpt_index);
	    END IF;

	    FOR rec IN rec_ps_cur( l_err_rcpt_num_array(k) ) LOOP
	      IF PG_DEBUG in ('Y', 'C') THEN
		  arp_debug.debug( 'l_err_rcpt_num_array '||l_err_rcpt_num_array(k));
		  arp_debug.debug( 'l_err_code_array     '||l_err_code_array(k));
	      END IF;

	      IF l_err_code_array(k) in( 'ARZCAR_CUST_MIN_AMT', 'ARZCAR_BANK_MIN_AMT',
	                                 'RCPT_CREATION_FAILED') THEN
		insert_exceptions(
		   p_batch_id   => p_batch_id,
		   p_request_id => pg_request_id,
		   p_payment_schedule_id => rec.payment_schedule_id,
		   p_paying_customer_id => rec.paying_customer_id,
		   p_exception_code  => l_err_code_array(k),
		   p_additional_message => l_err_code_array(k) );

	      --make the errored receipts avaliable for future runs
	      UPDATE ar_payment_schedules
	      SET selected_for_receipt_batch_id = NULL
	      WHERE payment_schedule_id = rec.payment_schedule_id;

	      ELSIF l_err_code_array(k) = 'PROCESS_PAYMENT_FAILED' THEN
		 /* update the error flag in ra_customer_trx */
		 UPDATE ra_customer_trx
		    SET cc_error_flag = 'Y',
			cc_error_code = l_cc_err_code_array(k),
			cc_error_text = l_cc_err_text_array(k),
			last_updated_by = pg_last_updated_by,
			last_update_date = sysdate,
			last_update_login = pg_last_update_login,
			request_id = pg_request_id,
			program_application_id= pg_program_application_id,
			program_id = pg_program_id,
			program_update_date = sysdate
		    WHERE customer_trx_id = rec.customer_trx_id;

		  IF PG_DEBUG in ('Y', 'C') THEN
		      arp_debug.debug( 'Invoice stamped with cc error '||rec.customer_trx_id);
		      arp_debug.debug( 'l_cc_err_code_array     '||l_cc_err_code_array(k));
		      arp_debug.debug( 'l_cc_err_text_array     '||l_cc_err_text_array(k));
		  END IF;
	     END IF;

	    END LOOP;
	  END LOOP;
        ELSE --flow related to Re-approval of receipt batch
	  FOR i IN l_rcpt_info_tab.FIRST..l_rcpt_info_tab.LAST LOOP
	    UPDATE ar_receipts_gt
	    SET gt_id = l_gt_id
	    WHERE cash_receipt_id = l_rcpt_info_tab(i).cash_receipt_id
	    AND gt_id = -1 ;

	    IF l_old_cash_receipt_id <> l_rcpt_info_tab(i).cash_receipt_id THEN
	      l_old_cash_receipt_id := l_rcpt_info_tab(i).cash_receipt_id;

	      process_payments(l_rcpt_info_tab(i).cash_receipt_id,
			       null,--p_pmt_trxn_id,
			       pg_request_id,
			       p_batch_id,
			       l_called_from,
			       l_cc_error_code,
			       l_cc_error_text,
			       l_return_status);

	      IF PG_DEBUG in ('Y', 'C') THEN
		  arp_debug.debug( 'Returning from process_payments ');
		  arp_debug.debug( 'l_return_status = '|| l_return_status);
	      END IF;

	     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		 l_pay_process_fail := 'Y';

		 UPDATE ra_customer_trx
		    SET cc_error_flag = 'Y',
			cc_error_code = l_cc_error_code,
			cc_error_text = l_cc_error_text,
			last_updated_by = pg_last_updated_by,
			last_update_date = sysdate,
			last_update_login = pg_last_update_login,
			request_id = pg_request_id,
			program_application_id= pg_program_application_id,
			program_id = pg_program_id,
			program_update_date = sysdate
		    WHERE customer_trx_id IN
		    ( SELECT customer_trx_id
		      FROM ar_payment_schedules
		      WHERE payment_schedule_id = l_rcpt_info_tab(i).payment_schedule_id
		    );
	     END IF;
	   END IF;
	 END LOOP;

	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_debug.debug('ar_receipts_gt dump 2');
	    dump_ar_receipts_gt;
	END IF;

	/*--------------------------------------------------
	Set the variable so that ar_open_trx_v will NOT
	excecute ps.selected_for_receipt_batch_id is null
	---------------------------------------------------*/
	arp_view_constants.set_ps_selected_in_batch('Y');

	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_debug.debug( 'Opening receipt application cursor');
	END IF;

	--cursor to fetch the application data
	OPEN appl_rec_cur( l_gt_id );


	FETCH  appl_rec_cur BULK COLLECT INTO l_rcpt_appl_tab;

	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_debug.debug('applications fetch count   '|| l_rcpt_appl_tab.count);
	END IF;

	l_amt_applied := 0;
	l_old_cash_receipt_id	:= -99;
	IF l_rcpt_appl_tab.count > 0 THEN
	--loop over the array and apply receipts
	FOR i IN  l_rcpt_appl_tab.FIRST..l_rcpt_appl_tab.LAST LOOP

	    --set it to global variable
	    IF l_rcpt_appl_tab(i).cash_receipt_id <> l_old_cash_receipt_id then
			l_amt_applied := 0;
	    ELSE
			l_rcpt_appl_tab(i).cr_amount := g_rcpt_info_rec.cr_amount;
	    END IF;

	    l_rcpt_appl_tab(i).cr_amount := l_rcpt_appl_tab(i).cr_amount - l_amt_applied;
	    g_rcpt_info_rec := l_rcpt_appl_tab(i);

	    receipt_application(l_rcpt_appl_tab(i).cash_receipt_id,
				l_rcpt_appl_tab(i).applied_payment_schedule_id,
				l_rcpt_appl_tab(i).amount_apply,
				pg_request_id,
				p_batch_id,
				greatest(l_rcpt_appl_tab(i).receipt_date,l_rcpt_appl_tab(i).trx_date),
				l_called_from,
				l_return_status);

		l_amt_applied := l_rcpt_appl_tab(i).amount_apply;
		l_old_cash_receipt_id := l_rcpt_appl_tab(i).cash_receipt_id;

	    IF PG_DEBUG in ('Y', 'C') THEN
		arp_debug.debug( 'Returing from receipt_application ');
		arp_debug.debug( 'l_return_status = '|| l_return_status);
	    END IF;

	    IF l_return_status <> 'S' THEN
		l_apply_fail := 'Y' ;
	    END IF;
	END LOOP;

	    l_from_cr_id := NULL;
	    l_to_cr_id   := NULL;
	    l_unbal_rcpt_tab.delete;

	    select min(gt.cash_receipt_id),
		   max(gt.cash_receipt_id)
    	    into l_from_cr_id,
         	 l_to_cr_id
    	    from AR_RECEIPTS_GT gt
    	    where gt.gt_id = l_gt_id;

	    IF l_from_cr_id IS NOT NULL AND l_to_cr_id IS NOT NULL THEN

		arp_standard.debug('Checking Journal Balance in Bulk: After Application');
		ARP_BALANCE_CHECK.CHECK_RECP_BALANCE_BULK(
			p_cr_id_low          => l_from_cr_id,
			p_cr_id_high         => l_to_cr_id,
			p_unbalanced_cr_tbl  => l_unbal_rcpt_tab );

		IF l_unbal_rcpt_tab.count > 0 THEN
        		FOR i IN  l_unbal_rcpt_tab.FIRST..l_unbal_rcpt_tab.LAST LOOP

				arp_standard.debug('Check Journal Balance for each application for balance failed receipts');
				FOR unbal_rec_appln IN unbal_rec_applns(l_unbal_rcpt_tab(i).cash_receipt_id, l_gt_id) LOOP

				    BEGIN
			 		ARP_BALANCE_CHECK.CHECK_APPLN_BALANCE(
    					    p_receivable_application_id1  => unbal_rec_appln.source_id_secondary,
    					    p_receivable_application_id2  => unbal_rec_appln.source_id,
					    p_request_id                  => pg_request_id,
					    p_called_from_api             => 'Y' );
				    EXCEPTION
					WHEN OTHERS THEN
					arp_standard.debug('Exception: Application Balance Failure');
					arp_standard.debug('Exception: Invoice PS ID: '||unbal_rec_appln.applied_payment_schedule_id);
					arp_standard.debug('Exception: CR ID: '||l_unbal_rcpt_tab(i).cash_receipt_id);

					arp_standard.debug('Update Invoice PS Before deleting Application');
					UPDATE AR_PAYMENT_SCHEDULES PS SET (
						PS.AMOUNT_DUE_REMAINING,
						PS.AMOUNT_APPLIED,
						PS.AMOUNT_LINE_ITEMS_REMAINING,
						PS.RECEIVABLES_CHARGES_REMAINING,
						PS.FREIGHT_REMAINING,
						PS.TAX_REMAINING,
						PS.ACCTD_AMOUNT_DUE_REMAINING,
						PS.STATUS,
						PS.GL_DATE_CLOSED,
						PS.ACTUAL_DATE_CLOSED,
						PS.DISCOUNT_REMAINING,
						PS.DISCOUNT_TAKEN_EARNED ) =
					( SELECT
						NVL(PS.AMOUNT_DUE_REMAINING, 0)
							+ NVL(RA1.AMOUNT_APPLIED, 0)
							+ NVL(RA1.EARNED_DISCOUNT_TAKEN, 0),
						NVL(PS.AMOUNT_APPLIED, 0)
							- NVL(RA1.AMOUNT_APPLIED, 0),
						NVL(PS.AMOUNT_LINE_ITEMS_REMAINING, 0)
							+ NVL(RA1.LINE_APPLIED, 0)
							+ NVL(LINE_EDISCOUNTED, 0),
						NVL(PS.RECEIVABLES_CHARGES_REMAINING, 0)
							+ NVL(RA1.RECEIVABLES_CHARGES_APPLIED, 0)
							+ NVL(CHARGES_EDISCOUNTED, 0),
						NVL(PS.FREIGHT_REMAINING, 0)
							+ NVL(RA1.FREIGHT_APPLIED, 0)
							+ NVL(FREIGHT_EDISCOUNTED, 0),
						NVL(PS.TAX_REMAINING, 0)
							+ NVL(RA1.TAX_APPLIED, 0)
							+ NVL(TAX_EDISCOUNTED, 0),
						NVL(PS.ACCTD_AMOUNT_DUE_REMAINING, 0)
							+ NVL(RA1.ACCTD_AMOUNT_APPLIED_TO, 0)
							+ NVL(RA1.ACCTD_EARNED_DISCOUNT_TAKEN, 0),
						DECODE((NVL(PS.AMOUNT_DUE_REMAINING, 0)
							+ NVL(RA1.AMOUNT_APPLIED, 0)
							+ NVL(RA1.EARNED_DISCOUNT_TAKEN, 0)), 0, 'CL', 'OP'),
						DECODE((NVL(PS.AMOUNT_DUE_REMAINING, 0)
							+ NVL(RA1.AMOUNT_APPLIED, 0)
							+ NVL(RA1.EARNED_DISCOUNT_TAKEN, 0)),
								0, PS.GL_DATE_CLOSED, to_date('12/31/4712', 'MM/DD/YYYY')),
						DECODE((NVL(PS.AMOUNT_DUE_REMAINING, 0)
							+ NVL(RA1.AMOUNT_APPLIED, 0)
							+ NVL(RA1.EARNED_DISCOUNT_TAKEN, 0)),
								0, PS.ACTUAL_DATE_CLOSED, to_date('12/31/4712', 'MM/DD/YYYY')),
						NVL(PS.DISCOUNT_REMAINING, 0)
							+ NVL(RA1.EARNED_DISCOUNT_TAKEN, 0),
						NVL(PS.DISCOUNT_TAKEN_EARNED, 0)
							- NVL(RA1.EARNED_DISCOUNT_TAKEN, 0)
					  FROM  AR_RECEIVABLE_APPLICATIONS RA1
					  WHERE RA1.APPLIED_PAYMENT_SCHEDULE_ID = PS.PAYMENT_SCHEDULE_ID
					  AND   RA1.CASH_RECEIPT_ID = l_unbal_rcpt_tab(i).cash_receipt_id
					  AND   RA1.RECEIVABLE_APPLICATION_ID = unbal_rec_appln.source_id_secondary )
					WHERE  PS.PAYMENT_SCHEDULE_ID = unbal_rec_appln.applied_payment_schedule_id;

					arp_standard.debug('Update Receipt PS Before deleting Application');
					UPDATE AR_PAYMENT_SCHEDULES PS SET (
        					PS.AMOUNT_DUE_REMAINING,
        					PS.AMOUNT_APPLIED,
        					PS.ACCTD_AMOUNT_DUE_REMAINING,
        					PS.STATUS,
        					PS.GL_DATE_CLOSED,
        					PS.ACTUAL_DATE_CLOSED ) =
					( SELECT
        					NVL(PS.AMOUNT_DUE_REMAINING, 0)          - NVL(RA1.AMOUNT_APPLIED, 0),
        					NVL(PS.AMOUNT_APPLIED, 0)                + NVL(RA1.AMOUNT_APPLIED, 0),
        					NVL(PS.ACCTD_AMOUNT_DUE_REMAINING, 0)    - NVL(RA1.ACCTD_AMOUNT_APPLIED_TO, 0),
        					DECODE((NVL(PS.AMOUNT_DUE_REMAINING, 0) - NVL(RA1.AMOUNT_APPLIED, 0)), 0, 'CL', 'OP'),
        					DECODE((NVL(PS.AMOUNT_DUE_REMAINING, 0) - NVL(RA1.AMOUNT_APPLIED, 0)),
                					0, PS.GL_DATE_CLOSED, to_date('12/31/4712', 'MM/DD/YYYY')),
        					DECODE((NVL(PS.AMOUNT_DUE_REMAINING, 0) - NVL(RA1.AMOUNT_APPLIED, 0)),
                					0, PS.ACTUAL_DATE_CLOSED, to_date('12/31/4712', 'MM/DD/YYYY'))
  					  FROM  AR_RECEIVABLE_APPLICATIONS RA1
					  WHERE RA1.PAYMENT_SCHEDULE_ID = PS.PAYMENT_SCHEDULE_ID
					  AND   RA1.RECEIVABLE_APPLICATION_ID = unbal_rec_appln.source_id_secondary )
					WHERE  PS.PAYMENT_SCHEDULE_ID = unbal_rec_appln.payment_schedule_id;

					arp_standard.debug('Delete Application Distribution Entires');
					DELETE FROM AR_DISTRIBUTIONS WHERE SOURCE_ID IN
						(unbal_rec_appln.source_id,
	 					 unbal_rec_appln.source_id_secondary)
					AND SOURCE_TABLE = 'RA';

					arp_standard.debug('Delete Application Entries');
					DELETE FROM AR_RECEIVABLE_APPLICATIONS WHERE RECEIVABLE_APPLICATION_ID IN
						(unbal_rec_appln.source_id,
						 unbal_rec_appln.source_id_secondary);

					arp_standard.debug('Reset Invoice Line Level Balances If maintained on the invoice');
					IF unbal_rec_appln.upgrade_method IN ('R12', 'R12_11IMFAR') THEN

						UPDATE RA_CUSTOMER_TRX_LINES TL SET (
							AMOUNT_DUE_REMAINING,
							ACCTD_AMOUNT_DUE_REMAINING,
							CHRG_AMOUNT_REMAINING,
							CHRG_ACCTD_AMOUNT_REMAINING,
							FRT_ADJ_REMAINING,
							FRT_ADJ_ACCTD_REMAINING,
							FRT_ED_AMOUNT,
							FRT_ED_ACCTD_AMOUNT,
							FRT_UNED_AMOUNT,
							FRT_UNED_ACCTD_AMOUNT) = (
						SELECT
							TL.AMOUNT_DUE_ORIGINAL + REM_TYPE_LINE,
							TL.ACCTD_AMOUNT_DUE_ORIGINAL + ACCTD_REM_TYPE_LINE,
							CHRG_ON_REV_LINE,
							ACCTD_CHRG_ON_REV_LINE,
							FRT_ON_REV_LINE,
							ACCTD_FRT_ON_REV_LINE,
							ED_FRT_REV_LINE,
							ACCTD_ED_FRT_REV_LINE,
							UNED_FRT_REV_LINE,
							ACCTD_UNED_FRT_REV_LINE
						FROM (SELECT
							SUM((decode(a.activity_bucket, 'ADJ_CHRG',
								amt, 'APP_CHRG', decode(a.line_type,
								'LINE', amt, 0) * -1, 0))) chrg_on_rev_line,
							SUM((decode(a.activity_bucket, 'ADJ_CHRG',
								acctd_amt, 'APP_CHRG', decode(a.line_type,
								'LINE', acctd_amt, 0) * -1, 0)))
								acctd_chrg_on_rev_line,
							SUM((decode(a.activity_bucket, 'ADJ_FRT',
								amt, 'APP_FRT', decode(a.line_type, 'LINE',
								amt, 0) * -1, 0))) frt_on_rev_line,
							SUM((decode(a.activity_bucket, 'ADJ_FRT', amt,
								'APP_FRT', decode(a.line_type, 'LINE',
								acctd_amt, 0) * -1, 0))) acctd_frt_on_rev_line,
							SUM((decode(a.activity_bucket,
								'ED_FRT', amt, 0))) ed_frt_rev_line,
							SUM((decode(a.activity_bucket, 'ED_FRT',
								acctd_amt, 0))) acctd_ed_frt_rev_line,
							SUM((decode(a.activity_bucket, 'UNED_FRT',
								amt, 0))) uned_frt_rev_line,
							SUM((decode(a.activity_bucket, 'UNED_FRT',
								acctd_amt, 0))) acctd_uned_frt_rev_line,
							SUM((decode(a.activity_bucket, 'ADJ_LINE', amt,
								'APP_LINE', (amt * -1), 'ED_LINE', amt,
								'UNED_LINE', amt,'ADJ_TAX', amt,
								'APP_TAX', (amt * -1), 'ED_TAX', amt,
								'UNED_TAX', amt, 'APP_FRT',
								(decode(a.line_type, 'FREIGHT', amt, 0) * -1),
								'APP_CHRG', (decode(a.line_type, 'CHARGES',
								amt, 0) * -1), 0))) rem_type_line,
							SUM((decode(a.activity_bucket, 'ADJ_LINE', acctd_amt,
								'APP_LINE', (acctd_amt * -1), 'ED_LINE',
								acctd_amt, 'UNED_LINE', acctd_amt, 'ADJ_TAX',
								acctd_amt, 'APP_TAX', (acctd_amt * -1), 'ED_TAX',
								acctd_amt, 'UNED_TAX', acctd_amt,'APP_FRT',
								(decode(a.line_type, 'FREIGHT',
								acctd_amt, 0) * -1), 'APP_CHRG',
								(decode(a.line_type, 'CHARGES',
								acctd_amt, 0) * -1), 0))) acctd_rem_type_line,
							a.customer_trx_line_id customer_trx_line_id
						      FROM	(
							 SELECT
								SUM(nvl(ard.amount_cr, 0)
									- nvl(ard.amount_dr, 0)) amt,
					  			SUM(nvl(ard.acctd_amount_cr, 0)
									- nvl(ard.acctd_amount_dr, 0)) acctd_amt,
								ctl.customer_trx_line_id,
								ard.ref_account_class,
								ard.activity_bucket,
								ctl.line_type
							 FROM   ar_distributions ard,
								ra_customer_trx_lines ctl
							 WHERE ctl.customer_trx_id =
								unbal_rec_appln.applied_customer_trx_id
							 AND   ctl.customer_trx_line_id = ard.ref_customer_trx_line_id (+)
							 GROUP BY ctl.customer_trx_line_id,
								  ard.ref_account_class,
								  ard.activity_bucket,
								  ctl.line_type) a
						      GROUP BY a.customer_trx_line_id) bal
					        WHERE bal.customer_trx_line_id = TL.customer_trx_line_id)
						WHERE TL.CUSTOMER_TRX_ID = unbal_rec_appln.applied_customer_trx_id;

					END IF;

				l_msg_data := 'Application failure. You need to nullify the SELECTED FOR RECEIPT BATCH ID on the invoice.'||
              				' When the invoice is fixed, then apply the invoice manually to the receipt with receipt id: '||
              				l_unbal_rcpt_tab(i).cash_receipt_id||', created by automatic receipts for that invoice';

					arp_standard.debug('Inserting Exception');

					insert_exceptions(
						p_batch_id            => p_batch_id,
						p_request_id          => pg_request_id,
						p_payment_schedule_id => unbal_rec_appln.applied_payment_schedule_id,
						p_exception_code      => 'AUTORECERR',
						p_additional_message  => l_msg_data );

				    END;

				END LOOP;

			END LOOP;
		END IF;

	    END IF;

        END IF;

	CLOSE appl_rec_cur;

	/* reset the variable back to null  */
	arp_view_constants.set_ps_selected_in_batch( null);

	/* CALL TO CONTROL_CHECK to detect bad receipts */
	control_check ( p_batch_id => p_batch_id ,
	                p_gt_id    => l_gt_id );

	IF g_auth_fail = 'Y' THEN
           l_pay_process_fail := 'Y';
        END IF;

	/* CALL To reset in the case there were failures */
	IF l_apply_fail = 'Y' OR l_pay_process_fail = 'Y' THEN

	  IF PG_DEBUG in ('Y', 'C') THEN
	    arp_debug.debug('calling rec reset.'|| l_apply_fail || l_pay_process_fail);
	  END IF;

	  rec_reset( p_apply_fail       => l_apply_fail,
		     p_pay_process_fail => l_pay_process_fail,
		     p_gt_id            => l_gt_id );

	  l_apply_fail       := 'N';
	  l_pay_process_fail := 'N';
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_debug.debug( 'End of loop ');
	    arp_debug.debug( 'Commiting the batch...');
	END IF;

	/*Update the receipt_number with the value of trx_number,this update is needed
	  sine we considered concatenated string of trx_number and term_sequence as
	  receipt_number during receipt creation.*/
	IF l_rec_creation_rule_code = 'PER_INVOICE' AND
	   l_rec_inher_inv_num_flag = 'Y' THEN
	      update ar_cash_receipts cr
	      SET receipt_number =
	         NVL(SUBSTR(RECEIPT_NUMBER, 1, INSTR(RECEIPT_NUMBER,'-', -1) -1), RECEIPT_NUMBER)
	      WHERE cash_receipt_id in
	      ( select cr.cash_receipt_id
	        from ar_cash_receipts cr,
		     ar_receipts_gt arg
	        where arg.gt_id = l_gt_id
		AND cr.cash_receipt_id = arg.cash_receipt_id
	      );
	      arp_debug.debug ( 'NO of Receipts updated =  '|| to_char(SQL%ROWCOUNT));

	      update ar_payment_schedules
	      SET TRX_NUMBER =
	         NVL(SUBSTR(TRX_NUMBER, 1, INSTR(TRX_NUMBER,'-', -1) -1), TRX_NUMBER)
	      WHERE cash_receipt_id in
	      ( select ps.cash_receipt_id
	        from ar_payment_schedules ps,
		     ar_receipts_gt arg
	        where arg.gt_id = l_gt_id
		AND ps.cash_receipt_id = arg.cash_receipt_id
	      );
	      arp_debug.debug ( 'NO of Receipts updated =  '|| to_char(SQL%ROWCOUNT));

	END IF;

	--initiate the event processing
	process_events( l_gt_id, p_batch_id );

	--commit after processing a batch
	COMMIT;

	-- no more rows to fetch
	IF l_rows_fetched < MAX_ARRAY_SIZE THEN
	    IF( dbms_sql.is_open( l_create_stmt_c) ) THEN
		dbms_sql.close_cursor( l_create_stmt_c );
	    END IF;

	    IF PG_DEBUG in ('Y', 'C') THEN
		arp_debug.debug('l_rows_fetched  < MAX_ARRAY_SIZE Cursor closed');
	    END IF;
	    EXIT;
	END IF; --no more rows to fetch

	l_receipt_num_array.delete;
	l_receipt_id_array.delete;
	l_ps_id_array.delete;

	EXIT WHEN rcpt_info_cursor%NOTFOUND;

    END LOOP;--main select cursor loop

    IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('process_selected_receipts()-');
    END IF;

    EXCEPTION
	WHEN others THEN
	 G_ERROR := 'Y';
	 insert_exceptions(
		   p_batch_id   =>p_batch_id,
		   p_request_id =>pg_request_id,
		   p_paying_customer_id =>-3,
		   p_exception_code  => 'AUTORECERR',
		   p_additional_message => SQLERRM
		     );
	IF PG_DEBUG in ('Y', 'C') THEN
	 arp_debug.debug('Exception : process_selected_receipts() '|| SQLERRM);
	END IF;
END process_selected_receipts;


/* START CONTROL_CHECK */
PROCEDURE CONTROL_CHECK ( p_batch_id    ar_batches.batch_id%TYPE,
                          p_gt_id       NUMBER ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       fnd_file.put_line(FND_FILE.LOG,'control_check()+');
       fnd_file.put_line(FND_FILE.LOG,'Detect receipts with Auth failure');
    END IF;

    UPDATE /*+ index(ct ra_customer_trx_u1) */ ra_customer_trx_all ct
    SET cc_error_flag = 'Y',
      last_updated_by = pg_last_updated_by,
      last_update_date = sysdate,
      last_update_login = pg_last_update_login,
      request_id = pg_request_id,
      program_application_id = pg_program_application_id,
      program_id = pg_program_id,
      program_update_date = sysdate
    WHERE customer_trx_id in
    (
     SELECT /*+ push_pred(trxn_ext) */ r.customer_trx_id
      FROM ar_receipts_gt r,
           ar_cash_receipts cr,
           ar_cash_receipt_history crh,
      (SELECT op.trxn_extension_id, summ.status
        FROM iby_trxn_summaries_all summ,
         iby_fndcpt_tx_operations op
       WHERE(summ.transactionid = op.transactionid)
        AND(reqtype = 'ORAPMTREQ')
        AND(status IN(0,  100,  111,  31,  32))
        AND((trxntypeid IN(2,    3)) OR((trxntypeid = 20)
        AND(summ.trxnmid =
            (SELECT MAX(trxnmid)
               FROM iby_trxn_summaries_all
             WHERE transactionid = summ.transactionid
               AND(reqtype = 'ORAPMTREQ')
               AND(status IN(0,  100,  111,  31,  32))
             AND(trxntypeid = 20)))))
      ) trxn_ext
      WHERE r.gt_id = p_gt_id
      AND cr.cash_receipt_id = r.cash_receipt_id
      AND crh.cash_receipt_id = cr.cash_receipt_id
      AND crh.status = 'CONFIRMED'
      AND crh.current_record_flag = 'Y'
      AND cr.payment_trxn_extension_id = trxn_ext.trxn_extension_id(+)
      AND trxn_ext.status IS NULL
    );

   if sql%rowcount > 0 then
      g_auth_fail := 'Y';
      INSERT INTO ar_autorec_exceptions
		(batch_id,
		 request_id,
		 payment_schedule_id,
		 cash_receipt_id,
		 paying_customer_id,
		 exception_code,
		 additional_message,
		 last_update_date,
		 last_updated_by,
		 creation_date,
		 created_by,
		 last_update_login,
		 program_application_id,
		 program_id,
		 program_update_date)
      SELECT /*+ push_pred(trxn_ext) */ p_batch_id,
	   pg_request_id,
	   r.payment_schedule_id,
	   cr.cash_receipt_id,
	   cr.pay_from_customer,
	   'AR_CC_AUTH_FAILED',
	   'Failure in Authorization',
	   sysdate,
	   pg_last_updated_by,
	   sysdate,
	   pg_created_by,
	   pg_last_update_login,
	   pg_program_application_id,
	   pg_program_id,
	   sysdate
      FROM ar_receipts_gt r,
	         ar_cash_receipts cr,
           ar_cash_receipt_history crh,
      (SELECT op.trxn_extension_id, summ.status
        FROM iby_trxn_summaries_all summ,
         iby_fndcpt_tx_operations op
       WHERE(summ.transactionid = op.transactionid)
        AND(reqtype = 'ORAPMTREQ')
        AND(status IN(0, 100,  111,  31,  32))
        AND((trxntypeid IN(2,    3)) OR((trxntypeid = 20)
        AND(summ.trxnmid =
            (SELECT MAX(trxnmid)
               FROM iby_trxn_summaries_all
             WHERE transactionid = summ.transactionid
               AND(reqtype = 'ORAPMTREQ')
               AND(status IN(0,  100,  111,  31,  32))
             AND(trxntypeid = 20)))))
      ) trxn_ext
      WHERE r.gt_id = p_gt_id
      AND cr.cash_receipt_id = r.cash_receipt_id
      AND crh.cash_receipt_id = cr.cash_receipt_id
      AND crh.status = 'CONFIRMED'
      AND crh.current_record_flag = 'Y'
      AND cr.payment_trxn_extension_id = trxn_ext.trxn_extension_id(+)
      AND trxn_ext.status IS NULL;

      IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'insert into autorec_exceptions count : '||sql%rowcount);
      END IF;
   end if;

    IF PG_DEBUG in ('Y', 'C') THEN
       fnd_file.put_line(FND_FILE.LOG,'control_check()-');
    END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'Error in Control check routine.');
  END IF;
END CONTROL_CHECK;



procedure populate_cached_data(p_rcpt_creation_rec OUT NOCOPY rcpt_creation_info) IS
BEGIN
   p_rcpt_creation_rec := g_rcpt_creation_rec;
END;

procedure populate_cached_data(p_receipt_info_rec OUT NOCOPY receipt_info_rec) IS
BEGIN
   p_receipt_info_rec := g_rcpt_info_rec;
END;


END AR_AUTOREC_API;

/
