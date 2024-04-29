--------------------------------------------------------
--  DDL for Package Body AR_AUTOREM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_AUTOREM_API" AS
/* $Header: ARATREMB.pls 120.23.12010000.27 2009/11/09 12:41:45 rasarasw ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
PG_PARALLEL varchar2(1) := NVL(FND_PROFILE.value('AR_USE_PARALLEL_HINT'), 'N');
PROCEDURE SUBMIT_FORMAT ( p_batch_id    ar_batches.batch_id%TYPE);
PROCEDURE CONTROL_CHECK ( p_batch_id    ar_batches.batch_id%TYPE);

G_ERROR  varchar2(1) := 'N';
TOTAL_WORKERS NUMBER := 0;
WORKER_NUMBER NUMBER := 0;
pg_approve_flag  ar_cash_receipts.confirmed_flag%TYPE ;
pg_format_flag   ar_cash_receipts.confirmed_flag%TYPE ;
pg_create_flag   ar_cash_receipts.confirmed_flag%TYPE ;

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
      /* Changes for Parallelization */
      p_worker_number                   IN NUMBER DEFAULT 0,
      p_total_workers                   IN NUMBER DEFAULT 0
      ) IS

      l_request_id                         ar_cash_receipts.request_id%TYPE;
      l_batch_date                         ar_cash_receipts.receipt_date%TYPE ;
      l_gl_date                            ar_cash_receipt_history.gl_date%TYPE;
      l_approve_flag                       ar_cash_receipts.confirmed_flag%TYPE ;
      l_format_flag                        ar_cash_receipts.confirmed_flag%TYPE ;
      l_create_flag                        ar_cash_receipts.confirmed_flag%TYPE ;
      l_currency_code                      ar_cash_receipts.currency_code%TYPE;
      l_remittance_method                  ar_receipt_classes.remit_method_code%TYPE;
      l_receipt_class_id                   ar_receipt_classes.receipt_class_id%TYPE ;
      l_receipt_method_id                  ar_cash_receipts.receipt_method_id%TYPE ;
      l_remittance_bank_branch_id          ap_bank_accounts.bank_branch_id%TYPE DEFAULT NULL;
      l_remittance_bank_account_id         ar_receipt_method_accounts.REMIT_BANK_ACCT_USE_ID%TYPE DEFAULT NULL;
      o_batch_id                           NUMBER;

      p_create_only                     VARCHAR2(1);
      l_flow1                           VARCHAR2(1);
      l_flow2                           VARCHAR2(1);
      l_flow3                           VARCHAR2(1);
      l_count                           NUMBER;

     /*bug 7352164 Parameter to store values*/
     l_control_count  number;
     l_control_amount number;

     cr_return_status                    VARCHAR2(1);
     l_return_status                     VARCHAR2(1);


     p_payment_type_code                  ar_receipt_methods.payment_type_code%type;
     p_sob_id                             ar_batches.set_of_books_id%type;

             l_last_updated_by         NUMBER;
             l_created_by              NUMBER;
             l_last_update_login       NUMBER;
             l_program_application_id  NUMBER;
             l_program_id              NUMBER;


      l_batch_applied_status          ar_batches.batch_applied_status%type;
      pl_return_status  VARCHAR2(1);
      pl_msg_count      NUMBER;
      pl_msg_data      VARCHAR2(240);
      l_instrument_type	     ar_receipt_methods.payment_channel_code%type;
BEGIN
--arp_standard.enable_debug;
--arp_standard.enable_file_debug('/appslog/fin_top/utl/finixud/out','chat67.log');
IF PG_DEBUG in ('Y', 'C') THEN
	fnd_file.put_line(FND_FILE.LOG,'autoremapi start ()+');
	fnd_file.put_line(FND_FILE.LOG,  'value of p_errbuf          ' ||  P_ERRBUF);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_retcode         ' ||  (P_RETCODE));
	fnd_file.put_line(FND_FILE.LOG,  'value of p_process_type    ' || p_process_type);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_create_flag     ' || p_create_flag);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_approve_flag    ' || p_approve_flag);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_format_flag     ' || p_format_flag);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_id        ' || (p_batch_id));
	fnd_file.put_line(FND_FILE.LOG,  'value of p_debug_mode_on   ' || p_debug_mode_on);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_receipt_class_id        ' || p_receipt_class_id);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_payment_method_id       ' || p_payment_method_id);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_currency  ' || p_batch_currency);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_date      ' || p_batch_date);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_gl_date   ' || p_batch_gl_date);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_comments        ' || p_comments);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_exchange_date   ' || p_exchange_date);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_exchange_rate   ' || p_exchange_rate);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_exchange_rate_type      ' || p_exchange_rate_type);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_media_reference         ' || p_media_reference);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_remit_method_code       ' || p_remit_method_code);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_remit_bank_branch_id    ' || p_remit_bank_branch_id);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_remit_bank_account_id   ' || p_remit_bank_account_id);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_remit_bank_deposit_number       ' || p_remit_bank_deposit_number);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_trx_date_l      ' || p_trx_date_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_trx_date_h      ' || p_trx_date_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_due_date_l      ' || p_due_date_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_due_date_h      ' || p_due_date_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_trx_num_l       ' || p_trx_num_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_trx_num_h       ' || p_trx_num_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_doc_num_l       ' || p_doc_num_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_doc_num_h       ' || p_doc_num_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_number_l       ' || p_customer_number_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_number_h       ' || p_customer_number_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_name_l       ' || p_customer_name_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_name_h         ' || p_customer_name_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_id     ' || (p_customer_id));
	fnd_file.put_line(FND_FILE.LOG,  'value of p_site_l          ' || p_site_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_site_h          ' || p_site_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_site_id         ' || (p_site_id));
	fnd_file.put_line(FND_FILE.LOG,  'value of p_remittance_total_from   ' || p_remittance_total_from);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_Remittance_total_to     ' || p_remittance_total_to);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_billing_number_l        ' || p_billing_number_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_billing_number_h        ' || p_billing_number_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_bank_acc_num_l         ' || p_customer_bank_acc_num_l);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_bank_acc_num_h         ' || p_customer_bank_acc_num_h);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_worker_number         ' || p_worker_number);
	fnd_file.put_line(FND_FILE.LOG,  'value of p_total_workers         ' || p_total_workers);
END IF;
     TOTAL_WORKERS := NVL(p_total_workers, 0);
     WORKER_NUMBER := NVL(p_worker_number, 0);

     l_batch_date := fnd_date.canonical_to_date(p_batch_date);
     l_gl_date := fnd_date.canonical_to_date(p_batch_gl_date);
     l_create_flag := p_create_flag;
     l_approve_flag := p_approve_flag;
     l_format_flag := p_format_flag;
     l_currency_code := p_batch_currency;
     l_remittance_method := p_remit_method_code;
     l_receipt_class_id := to_number(p_receipt_class_id);
     l_receipt_method_id := to_number(p_payment_method_id);
     l_remittance_bank_branch_id := to_number(p_remit_bank_branch_id);
     l_remittance_bank_account_id := to_number(p_remit_bank_account_id);
/* CONVERT INPUT DATE PARAMETERS */


IF PG_DEBUG in ('Y', 'C') THEN
  fnd_file.put_line(FND_FILE.LOG,  'Values taken in Local variables ');
  fnd_file.put_line(FND_FILE.LOG,  'value of l_gl_date '||l_gl_date);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_batch_date '||l_batch_date);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_create_flag '|| l_create_flag);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_approve_flag '|| l_approve_flag);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_format_flag '|| l_format_flag);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_currency_code '|| l_currency_code);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_remittance_method '|| l_remittance_method);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_receipt_class_id '|| l_receipt_class_id);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_receipt_method_id '|| l_receipt_method_id);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_remittance_bank_branch_id '|| l_remittance_bank_branch_id);
  fnd_file.put_line(FND_FILE.LOG,  'value of l_remittance_bank_account_id '|| l_remittance_bank_account_id);
END IF;

       l_request_id := arp_standard.profile.request_id;
       l_last_updated_by := arp_standard.profile.user_id ;
       l_created_by := arp_standard.profile.user_id ;
       l_last_update_login := arp_standard.profile.last_update_login ;
       l_program_application_id := arp_standard.application_id ;
       l_program_id := arp_standard.profile.program_id;
       pg_create_flag := p_create_flag;
       pg_approve_flag := p_approve_flag;
       pg_format_flag := p_format_flag;



IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value  l_request_id' || l_request_id);
   fnd_file.put_line(FND_FILE.LOG,  'value  l_last_updated_by ' || l_last_updated_by);
   fnd_file.put_line(FND_FILE.LOG,  'value  l_created_by' || l_created_by);
   fnd_file.put_line(FND_FILE.LOG,  'value  l_last_update_login'|| l_last_update_login);
   fnd_file.put_line(FND_FILE.LOG,  'value  l_program_application_id'|| l_program_application_id);
   fnd_file.put_line(FND_FILE.LOG,  'value  l_program_id' || l_program_id);

 END IF;

/* CHECK RUN AND CALLED FROM */
IF TOTAL_WORKERS > 1 THEN

   fnd_file.put_line(FND_FILE.LOG,  'Parallel Processing');
   o_batch_id := p_batch_id;


  IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  in FLOW3 '|| to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
  END IF;


 create_and_update_remit_rec_pa(
          p_batch_id      => o_batch_id,
          p_return_status => cr_return_status
                              );

/* CALL TO PROCESS PAY RECEIPTS */
 IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  bef call to process_pay ' || to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
 END IF;

    process_pay_receipt_parallel(
                p_batch_id => o_batch_id,
                p_called_from =>'AUTOREMAPI',
                x_msg_count               => pl_msg_count,
                x_msg_data                => pl_msg_data,
                x_return_status           => pl_return_status
                );

ELSE
BEGIN
   select count(*)
   INTO l_count
   from AR_CASH_RECEIPTS
   where selected_remittance_batch_id = p_batch_id;

EXCEPTION
when no_data_found THEN
l_count :=0;

END;


   IF p_batch_id is null then

   l_flow1 := 'Y';

   END IF;

   IF ( (l_count=0 ) AND ( p_batch_id is not null)) THEN

   l_flow2 := 'Y';

   END IF;

   IF ( (l_count >0 ) AND ( p_batch_id is not null)) THEN

   l_flow3 := 'Y';

   END IF;


  IF ( p_create_flag = 'Y' AND p_approve_flag = 'N' AND p_format_flag = 'N') THEN

     fnd_file.put_line(FND_FILE.LOG, 'This is a Create Only RUN ');

      p_create_only := 'Y';

  END IF;

/* CHECK RUN AND CALLED FORM END */

 fnd_file.put_line(FND_FILE.LOG,  'value  L_FLOW1' || l_flow1);
 fnd_file.put_line(FND_FILE.LOG,  'value  L_FLOW2' || l_flow2);
 fnd_file.put_line(FND_FILE.LOG,  'value  L_FLOW3' || l_flow3);

     IF ( (l_flow2 = 'Y') OR (l_flow3 = 'Y')) THEN

      select batch_date ,gl_date , remit_method_code, currency_code,
             receipt_method_id, REMITTANCE_BANK_BRANCH_ID,REMIT_BANK_ACCT_USE_ID
      into  l_batch_date,l_gl_date,l_remittance_method,l_currency_code,
            l_receipt_method_id,l_remittance_bank_branch_id,l_remittance_bank_account_id
      from  AR_BATCHES
      where batch_id = p_batch_id;

           IF PG_DEBUG in ('Y','C') THEN
	      fnd_file.put_line(FND_FILE.LOG,  'For l_flow2 and l_flow3');
              fnd_file.put_line(FND_FILE.LOG,  'value  batch_date' || l_batch_date);
              fnd_file.put_line(FND_FILE.LOG,  'value  gl_date ' || l_gl_date);
              fnd_file.put_line(FND_FILE.LOG,  'value  remit_method' || l_remittance_method);
              fnd_file.put_line(FND_FILE.LOG,  'value  currency_code' || l_currency_code);
              fnd_file.put_line(FND_FILE.LOG,  'value  receipt_method_id'|| l_receipt_method_id);
              fnd_file.put_line(FND_FILE.LOG,  'value  l_remittance_bank_branch_id'|| l_remittance_bank_branch_id);
              fnd_file.put_line(FND_FILE.LOG,  'value  l_remittance_bank_account_id' || l_remittance_bank_account_id);

            END IF;


     END IF;



IF l_flow1 = 'Y'  THEN

fnd_file.put_line(FND_FILE.LOG,'In if l_flow1');

IF p_create_only = 'Y' THEN

fnd_file.put_line(FND_FILE.LOG,'In if l_flow1: if p_create_only is Y');

/* insert batch */

    insert_batch(
       l_batch_date,
       l_gl_date,
       l_approve_flag,
       l_format_flag,
       l_currency_code,
       l_remittance_method,
       l_receipt_class_id,
       l_receipt_method_id,
       l_remittance_bank_branch_id,
       l_remittance_bank_account_id,
       o_batch_id
      );

/* select and update receipt */

if l_receipt_method_id is not null then /* bug7173199: subsituted p_payment_method_id with l_receipt_method_id*/
           select rm.payment_channel_code,b.set_of_books_id
             into  p_payment_type_code, p_sob_id
             from  ar_receipt_methods rm,
                   ar_batches b
             where rm.receipt_method_id = l_receipt_method_id /* bug7173199: subsituted p_payment_method_id with l_receipt_method_id*/
             and   b.receipt_method_id = rm.receipt_method_id
             and   b.batch_id = o_batch_id;
else
           p_payment_type_code := null;
           select b.set_of_books_id
             into  p_sob_id
             from  ar_batches b
             where b.batch_id = o_batch_id;
end if;



                          select_update_rec(
                                p_customer_number_l=> p_customer_number_l,
                                p_customer_number_h=>  p_customer_number_h,
                                p_customer_name_l=> p_customer_name_l,
                                p_customer_name_h=>  p_customer_name_h,
                                p_doc_num_l=> p_doc_num_l,
                                p_doc_num_h=>  p_doc_num_h,
                                p_trx_date_l=> fnd_date.canonical_to_date(p_trx_date_l),
                                p_trx_date_h=> fnd_date.canonical_to_date(p_trx_date_h),
                                p_due_date_l=> fnd_date.canonical_to_date(p_due_date_l),
                                p_due_date_h=> fnd_date.canonical_to_date(p_due_date_h),
                                p_trx_num_l=> p_trx_num_l,
                                p_trx_num_h=> p_trx_num_h,
                                p_remittance_total_to=> p_remittance_total_to,
                                p_remittance_total_from=> p_remittance_total_from,
                                p_batch_id=>  o_batch_id ,
                                p_receipt_method_id=>  l_receipt_method_id ,
                                p_currency_code=> p_batch_currency,
                                p_payment_type_code=> p_payment_type_code,
                                p_sob_id=>  p_sob_id ,
                                p_remit_method_code=> p_remit_method_code,
                                p_remit_bank_account_id=>  l_remittance_bank_account_id ,
                                p_return_status=>l_return_status);

       IF PG_DEBUG in ('Y', 'C') THEN
            fnd_file.put_line(FND_FILE.LOG,' COMMITING WORK - CREATE ONLY ');
       END IF;

      COMMIT;


ELSE

fnd_file.put_line(FND_FILE.LOG,'In if l_flow1: else P_create_only is Y');

/* CALL TO INSERT BATCH FROM MAIN */

    insert_batch(
       l_batch_date,
       l_gl_date,
       l_approve_flag,
       l_format_flag,
       l_currency_code,
       l_remittance_method,
       l_receipt_class_id,
       l_receipt_method_id,
       l_remittance_bank_branch_id,
       l_remittance_bank_account_id,
       o_batch_id
      );



/* CALL TO select_and_update receipts */

if l_receipt_method_id is not null then /* bug7173199: subsituted p_payment_method_id with l_receipt_method_id*/
             select rm.payment_channel_code,b.set_of_books_id
             into  p_payment_type_code, p_sob_id
             from  ar_receipt_methods rm,
                   ar_batches b
             where rm.receipt_method_id = l_receipt_method_id /* bug7173199: subsituted p_payment_method_id with l_receipt_method_id*/
             and   b.receipt_method_id = rm.receipt_method_id
             and   b.batch_id = o_batch_id;
else
           p_payment_type_code := null;
           select b.set_of_books_id
             into  p_sob_id
             from  ar_batches b
             where b.batch_id = o_batch_id;
end if;



                          select_update_rec(
                                p_customer_number_l=> p_customer_number_l,
                                p_customer_number_h=>  p_customer_number_h,
                                p_customer_name_l=> p_customer_name_l,
                                p_customer_name_h=>  p_customer_name_h,
                                p_doc_num_l=> p_doc_num_l,
                                p_doc_num_h=>  p_doc_num_h,
                                p_trx_date_l=> fnd_date.canonical_to_date(p_trx_date_l),
                                p_trx_date_h=> fnd_date.canonical_to_date(p_trx_date_h),
                                p_due_date_l=> fnd_date.canonical_to_date(p_due_date_l),
                                p_due_date_h=> fnd_date.canonical_to_date(p_due_date_h),
                                p_trx_num_l=> p_trx_num_l,
                                p_trx_num_h=> p_trx_num_h,
                                p_remittance_total_to=> p_remittance_total_to,
                                p_remittance_total_from=> p_remittance_total_from,
                                p_batch_id=>  o_batch_id ,
                                p_receipt_method_id=>  l_receipt_method_id ,
                                p_currency_code=> p_batch_currency,
                                p_payment_type_code=> p_payment_type_code,
                                p_sob_id=>  p_sob_id ,
                                p_remit_method_code=> p_remit_method_code,
                                p_remit_bank_account_id=>  l_remittance_bank_account_id ,
                                p_return_status=>l_return_status);


/* CALL TO CREATE AND UPDATE REM RECEIPTS */


 IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  bef call to create remit rec ' || to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
 END IF;


 create_and_update_remit_rec(
          p_batch_id      => o_batch_id,
          p_return_status => cr_return_status
                              );

/* CALL TO PROCESS PAY RECEIPTS */
 IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  bef call to process_pay ' || to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
 END IF;

    process_pay_receipt(
                p_batch_id => o_batch_id,
                p_called_from =>'AUTOREMAPI',
                x_msg_count               => pl_msg_count,
                x_msg_data                => pl_msg_data,
                x_return_status           => pl_return_status
                );


END IF ;    /* of else part of  p_create_only */

END IF ;  /* end if of l_flow1 */


IF l_flow2 = 'Y'  THEN

fnd_file.put_line(FND_FILE.LOG,'In if l_flow2');

            o_batch_id := p_batch_id;

  IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  in FLOW2 ' || to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
  END IF;


IF p_create_only = 'Y' THEN

fnd_file.put_line(FND_FILE.LOG,'In if l_flow2: if p_create_only is Y');

if l_receipt_method_id is not null then /* bug7173199: subsituted p_payment_method_id with l_receipt_method_id*/
            select rm.payment_channel_code,b.set_of_books_id
             into  p_payment_type_code, p_sob_id
             from  ar_receipt_methods rm,
                   ar_batches b
             where b.receipt_method_id = rm.receipt_method_id
             and   b.batch_id = o_batch_id;
else
           p_payment_type_code := null;
           select b.set_of_books_id
             into  p_sob_id
             from  ar_batches b
             where b.batch_id = o_batch_id;
end if;



                          select_update_rec(
                                p_customer_number_l=> p_customer_number_l,
                                p_customer_number_h=>  p_customer_number_h,
                                p_customer_name_l=> p_customer_name_l,
                                p_customer_name_h=>  p_customer_name_h,
                                p_doc_num_l=> p_doc_num_l,
                                p_doc_num_h=>  p_doc_num_h,
                                p_trx_date_l=> fnd_date.canonical_to_date(p_trx_date_l),
                                p_trx_date_h=> fnd_date.canonical_to_date(p_trx_date_h),
                                p_due_date_l=> fnd_date.canonical_to_date(p_due_date_l),
                                p_due_date_h=> fnd_date.canonical_to_date(p_due_date_h),
                                p_trx_num_l=> p_trx_num_l,
                                p_trx_num_h=> p_trx_num_h,
                                p_remittance_total_to=> p_remittance_total_to,
                                p_remittance_total_from=> p_remittance_total_from,
                                p_batch_id=>  o_batch_id ,
                                p_receipt_method_id=>  l_receipt_method_id ,
                                p_currency_code=> l_currency_code,
                                p_payment_type_code=> p_payment_type_code,
                                p_sob_id=>  p_sob_id ,
                                p_remit_method_code=> l_remittance_method,
                                p_remit_bank_account_id=>  l_remittance_bank_account_id ,
                                p_return_status=>l_return_status);

       IF PG_DEBUG in ('Y', 'C') THEN
            fnd_file.put_line(FND_FILE.LOG,' COMMITING WORK - CREATE ONLY ');
       END IF;

      COMMIT;



ELSE

fnd_file.put_line(FND_FILE.LOG,'In if l_flow2: else p_create_only is Y');

 IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  bef call to select update rec ' || to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
 END IF;

if l_receipt_method_id is not null then /* bug7173199: subsituted p_payment_method_id with l_receipt_method_id*/
            select rm.payment_channel_code,b.set_of_books_id
             into  p_payment_type_code, p_sob_id
             from  ar_receipt_methods rm,
                   ar_batches b
             where b.receipt_method_id = rm.receipt_method_id
             and   b.batch_id = o_batch_id;
else
           p_payment_type_code := null;
           select b.set_of_books_id
             into  p_sob_id
             from  ar_batches b
             where b.batch_id = o_batch_id;
end if;

IF p_create_flag = 'Y' THEN
                          select_update_rec(
                                p_customer_number_l=> p_customer_number_l,
                                p_customer_number_h=>  p_customer_number_h,
                                p_customer_name_l=> p_customer_name_l,
                                p_customer_name_h=>  p_customer_name_h,
                                p_doc_num_l=> p_doc_num_l,
                                p_doc_num_h=>  p_doc_num_h,
                                p_trx_date_l=> fnd_date.canonical_to_date(p_trx_date_l),
                                p_trx_date_h=> fnd_date.canonical_to_date(p_trx_date_h),
                                p_due_date_l=> fnd_date.canonical_to_date(p_due_date_l),
                                p_due_date_h=> fnd_date.canonical_to_date(p_due_date_h),
                                p_trx_num_l=> p_trx_num_l,
                                p_trx_num_h=> p_trx_num_h,
                                p_remittance_total_to=> p_remittance_total_to,
                                p_remittance_total_from=> p_remittance_total_from,
                                p_batch_id=>  o_batch_id ,
                                p_receipt_method_id=>  l_receipt_method_id ,
                                p_currency_code=> l_currency_code,
                                p_payment_type_code=> p_payment_type_code,
                                p_sob_id=>  p_sob_id ,
                                p_remit_method_code=> l_remittance_method,
                                p_remit_bank_account_id=>  l_remittance_bank_account_id ,
                                p_return_status=>l_return_status);




 IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  bef call to create remit rec ' || to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
 END IF;

END IF;


IF p_approve_flag = 'Y' THEN
 create_and_update_remit_rec(
          p_batch_id      => o_batch_id,
          p_return_status => cr_return_status
                              );

/* CALL TO PROCESS PAY RECEIPTS */
 IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  bef call to process_pay ' || to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
 END IF;

    process_pay_receipt(
                p_batch_id => o_batch_id,
                p_called_from =>'AUTOREMAPI',
                x_msg_count               => pl_msg_count,
                x_msg_data                => pl_msg_data,
                x_return_status           => pl_return_status
                );
END IF;

END IF ; /* end of the else part of create_only */

END IF ;  /* end if of l_flow2 */




IF l_flow3 = 'Y' THEN

IF p_approve_flag = 'Y' THEN

   o_batch_id := p_batch_id;


  IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  in FLOW3 '|| to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
  END IF;


 create_and_update_remit_rec(
          p_batch_id      => o_batch_id,
          p_return_status => cr_return_status
                              );

/* CALL TO PROCESS PAY RECEIPTS */
 IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG,  'value of o_batch_id  bef call to process_pay ' || to_char(o_batch_id));
   fnd_file.put_line(FND_FILE.LOG,  ' the error here is ' || SQLERRM );
 END IF;

    process_pay_receipt(
                p_batch_id => o_batch_id,
                p_called_from =>'AUTOREMAPI',
                x_msg_count               => pl_msg_count,
                x_msg_data                => pl_msg_data,
                x_return_status           => pl_return_status
                );

END IF;

END IF;   /* end if of l_flow3 */
END IF;  /* Check if Process is submitted from Master Program */

IF p_approve_flag = 'Y' THEN

/* CALL TO CONTROL_CHECK to detect bad receipts */

   control_check ( p_batch_id =>o_batch_id);

   fnd_file.put_line(FND_FILE.LOG,'reset selected_remittance_batch_id for all receipts after approval');

   update ar_cash_receipts
   set selected_remittance_batch_id = null
   where selected_remittance_batch_id = o_batch_id
   and cash_receipt_id in (select cash_receipt_id from
                       ar_cash_receipt_history
                       where request_id = l_request_id
                       and status = 'REMITTED'
                       and current_record_flag = 'Y');

   fnd_file.put_line(FND_FILE.LOG,'selected_remittance_batch_id reset for rows: '||sql%rowcount);

END IF;


/* CALL TO REC_RESET to delete bad rows */

IF G_ERROR = 'Y'  THEN

        fnd_file.put_line( FND_FILE.LOG, 'CALLING REC_RESET');

        rec_reset (p_request_id => l_request_id);

END IF;

/* Bug 5051186  Update the Batch Status  */
IF TOTAL_WORKERS < 1 THEN
       IF   l_format_flag = 'Y' THEN
            l_batch_applied_status := 'COMPLETED_FORMAT';
       ELSIF l_approve_flag = 'Y' then
             l_batch_applied_status := 'COMPLETED_APPROVAL';
       ELSIF l_create_flag = 'Y' then
          l_batch_applied_status := 'COMPLETED_CREATION';
       END IF;

       /*bug 7352164 update control count and control amount */
       IF p_create_only = 'Y' THEN
           SELECT
             nvl(sum(cr.amount),0),
             count(*) into
             l_control_amount,
             l_control_count
           FROM    ar_cash_receipts cr
           WHERE   cr.selected_remittance_batch_id = o_batch_id;

           update ar_batches
               SET batch_applied_status =  l_batch_applied_status,
                   control_count = l_control_count,
                   control_amount= l_control_amount
               where batch_id = o_batch_id;

       ELSIF l_approve_flag = 'Y' THEN
           SELECT
             nvl(sum(crh.amount),0),
             count(*) into
             l_control_amount,
             l_control_count
           FROM    ar_cash_receipt_history crh
           WHERE   crh.batch_id = o_batch_id
           AND     crh.status = 'REMITTED'
           AND     crh.current_record_flag = 'Y';

           update ar_batches
               SET batch_applied_status =  l_batch_applied_status,
                   control_count = l_control_count,
                   control_amount= l_control_amount
               where batch_id = o_batch_id;
        ELSE
        /* No need to update counts if the batch is submitted for format only */
            update ar_batches
               SET batch_applied_status =  l_batch_applied_status
               where batch_id = o_batch_id;
        END IF;
END IF;

/* CALL TO SUBMIT_REPORT */

/* SUBMIT THE FINAL REPORT FULL WITH ERRORS AND EXECUTION */
fnd_file.put_line(FND_FILE.LOG,'calling the report- batch_id  for create only ' || o_batch_id);
fnd_file.put_line(FND_FILE.LOG,'calling the report ' || l_request_id);

submit_report ( p_batch_id =>o_batch_id,
          p_request_id => l_request_id);


/* START FORMATTING */
IF TOTAL_WORKERS < 1 THEN
        IF l_format_flag = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG,
                'calling the report- batch_id  format  ' || o_batch_id);
          submit_format ( p_batch_id =>o_batch_id);
        END IF;
END IF;
/* END FORMATTING */


        /* Bug 7639165 - Changes Begin. */
        BEGIN
                SELECT PC.INSTRUMENT_TYPE INTO l_instrument_type
                FROM   AR_RECEIPT_METHODS RM, IBY_FNDCPT_PMT_CHNNLS_B PC
                WHERE  RECEIPT_METHOD_ID = l_receipt_method_id
                AND    RM.PAYMENT_CHANNEL_CODE = PC.PAYMENT_CHANNEL_CODE;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN            -- Bug 9096913
                  l_instrument_type := Null ;
                  fnd_file.put_line(FND_FILE.LOG,'Payment Channel Code is NULL');
                WHEN OTHERS THEN
                RAISE;
        END;

        IF nvl(l_instrument_type,'XXXXXX') = 'CREDITCARD'
           AND nvl(p_approve_flag,'N') = 'Y'
        THEN
                arp_util.debug('Calling ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover');
                ARP_CORRECT_CC_ERRORS.cc_auto_correct_cover(l_request_id, 'REMITTANCE');
        END IF;
        /* Bug 7639165 - Changes End. */


IF PG_DEBUG in ('Y', 'C') THEN
    fnd_file.put_line(FND_FILE.LOG,' COMMITING WORK - ALL REMIT RECS ');
END IF;

COMMIT;






EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
 fnd_file.put_line(FND_FILE.LOG,'Exception : autoremapi() '|| SQLERRM);

     fnd_file.put_line(FND_FILE.LOG,'Exception : autoremapi() ');
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
fnd_file.put_line(FND_FILE.LOG,  'value of p_errbuf          ' ||  P_ERRBUF);
fnd_file.put_line(FND_FILE.LOG,  'value of p_retcode         ' ||  (P_RETCODE));
fnd_file.put_line(FND_FILE.LOG,  'value of p_process_type    ' || p_process_type);
fnd_file.put_line(FND_FILE.LOG,  'value of p_create_flag     ' || p_create_flag);
fnd_file.put_line(FND_FILE.LOG,  'value of p_approve_flag    ' || p_approve_flag);
fnd_file.put_line(FND_FILE.LOG,  'value of p_format_flag     ' || p_format_flag);
fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_id        ' || (p_batch_id));
fnd_file.put_line(FND_FILE.LOG,  'value of p_debug_mode_on   ' || p_debug_mode_on);
fnd_file.put_line(FND_FILE.LOG,  'value of p_receipt_class_id        ' || p_receipt_class_id);
fnd_file.put_line(FND_FILE.LOG,  'value of p_payment_method_id       ' || p_payment_method_id);
fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_currency  ' || p_batch_currency);
fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_date      ' || p_batch_date);
fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_gl_date   ' || p_batch_gl_date);
fnd_file.put_line(FND_FILE.LOG,  'value of p_comments        ' || p_comments);
fnd_file.put_line(FND_FILE.LOG,  'value of p_exchange_date   ' || p_exchange_date);
fnd_file.put_line(FND_FILE.LOG,  'value of p_exchange_rate   ' || p_exchange_rate);
fnd_file.put_line(FND_FILE.LOG,  'value of p_exchange_rate_type      ' || p_exchange_rate_type);
fnd_file.put_line(FND_FILE.LOG,  'value of p_media_reference         ' || p_media_reference);
fnd_file.put_line(FND_FILE.LOG,  'value of p_remit_method_code       ' || p_remit_method_code);
fnd_file.put_line(FND_FILE.LOG,  'value of p_remit_bank_branch_id    ' || p_remit_bank_branch_id);
fnd_file.put_line(FND_FILE.LOG,  'value of p_remit_bank_account_id   ' || p_remit_bank_account_id);
fnd_file.put_line(FND_FILE.LOG,  'value of p_remit_bank_deposit_number       ' || p_remit_bank_deposit_number);
fnd_file.put_line(FND_FILE.LOG,  'value of p_trx_date_l      ' || p_trx_date_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_trx_date_h      ' || p_trx_date_h);
fnd_file.put_line(FND_FILE.LOG,  'value of p_due_date_l      ' || p_due_date_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_due_date_h      ' || p_due_date_h);
fnd_file.put_line(FND_FILE.LOG,  'value of p_trx_num_l       ' || p_trx_num_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_trx_num_h       ' || p_trx_num_h);
fnd_file.put_line(FND_FILE.LOG,  'value of p_doc_num_l       ' || p_doc_num_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_doc_num_h       ' || p_doc_num_h);
fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_number_l       ' || p_customer_number_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_number_h       ' || p_customer_number_h);
fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_name_l       ' || p_customer_name_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_name_h         ' || p_customer_name_h);
fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_id     ' || (p_customer_id));
fnd_file.put_line(FND_FILE.LOG,  'value of p_site_l          ' || p_site_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_site_h          ' || p_site_h);
fnd_file.put_line(FND_FILE.LOG,  'value of p_site_id         ' || (p_site_id));
fnd_file.put_line(FND_FILE.LOG,  'value of p_remittance_total_from   ' || p_remittance_total_from);
fnd_file.put_line(FND_FILE.LOG,  'value of p_Remittance_total_to     ' || p_remittance_total_to);
fnd_file.put_line(FND_FILE.LOG,  'value of p_billing_number_l        ' || p_billing_number_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_billing_number_h        ' || p_billing_number_h);
fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_bank_acc_num_l         ' || p_customer_bank_acc_num_l);
fnd_file.put_line(FND_FILE.LOG,  'value of p_customer_bank_acc_num_h         ' || p_customer_bank_acc_num_h);
  END IF;
raise;

END get_parameters;

/*========================================================================+
 |  PROCEDURE submit_autorem_parallel                                     |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | Wraper to parallelize the Automatic Remittances creation program       |
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
 | 05-FEB-2008              aghoraka           Created                    |
 *=========================================================================*/
PROCEDURE submit_autorem_parallel(
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
			p_total_workers                   IN NUMBER default 1 )
AS

  l_worker_number              NUMBER ;
  l_complete			BOOLEAN := FALSE;
  l_count                       NUMBER;
  l_request_id                  ar_cash_receipts.request_id%TYPE;
  l_batch_date                  ar_cash_receipts.receipt_date%TYPE ;
  l_gl_date                     ar_cash_receipt_history.gl_date%TYPE;
  l_approve_flag                ar_cash_receipts.confirmed_flag%TYPE ;
  l_format_flag                 ar_cash_receipts.confirmed_flag%TYPE ;
  l_create_flag                 ar_cash_receipts.confirmed_flag%TYPE ;
  l_currency_code               ar_cash_receipts.currency_code%TYPE;
  l_remittance_method           ar_receipt_classes.remit_method_code%TYPE;
  l_receipt_class_id            ar_receipt_classes.receipt_class_id%TYPE ;
  l_receipt_method_id           ar_cash_receipts.receipt_method_id%TYPE ;
  l_remittance_bank_branch_id   ap_bank_accounts.bank_branch_id%TYPE DEFAULT NULL;
  l_remittance_bank_account_id	ar_receipt_method_accounts.REMIT_BANK_ACCT_USE_ID%TYPE DEFAULT NULL;
  l_batch_applied_status	ar_batches.batch_applied_status%TYPE;
  l_return_status		VARCHAR2(1);
  o_batch_id                    NUMBER;
  l_ins_stmt                    VARCHAR2(5000);
  ins_rec                       INTEGER;
  ignore                        INTEGER;
  /* bug 7352164*/
  l_control_count               number;
  l_control_amount              number;

  p_payment_type_code           ar_receipt_methods.payment_type_code%type;
  p_sob_id                      ar_batches.set_of_books_id%type;

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
    BEGIN
	fnd_file.put_line( FND_FILE.LOG, 'submit_subrequest()+' );

	FND_REQUEST.SET_ORG_ID(p_org_id);

	l_request_id := FND_REQUEST.submit_request( 'AR', 'AUTOREMAPI',
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

	IF (l_request_id = 0) THEN
	    arp_util.debug('Can not start for worker_id: ' ||p_worker_number );
	    P_ERRBUF := fnd_Message.get;
	    P_RETCODE := 2;
	    return;
	ELSE
	    commit;
	    arp_util.debug('Child request id: ' ||l_request_id || ' started for
                                worker_id: ' ||p_worker_number );
	END IF;

	 l_req_status_tab(p_worker_number).request_id := l_request_id;

	 fnd_file.put_line( FND_FILE.LOG, 'submit_subrequest()-');

    END submit_subrequest;

BEGIN
    fnd_file.put_line( FND_FILE.LOG, 'submit_autorem_parallel()+');

    l_batch_date := fnd_date.canonical_to_date(p_batch_date);
    l_gl_date := fnd_date.canonical_to_date(p_batch_gl_date);
    l_create_flag := p_create_flag;
    l_approve_flag := p_approve_flag;
    l_format_flag := p_format_flag;
    l_currency_code := p_batch_currency;
    l_remittance_method := p_remit_method_code;
    l_receipt_class_id := to_number(p_receipt_class_id);
    l_receipt_method_id := to_number(p_payment_method_id);
    l_remittance_bank_branch_id := to_number(p_remit_bank_branch_id);
    l_remittance_bank_account_id := to_number(p_remit_bank_account_id);

    -- These validations should ideally be performed at form level.
    IF p_batch_id IS NOT NULL THEN
      SELECT batch_applied_status
      INTO l_batch_applied_status
      FROM ar_batches
      WHERE batch_id = p_batch_id;

      fnd_file.put_line( FND_FILE.LOG, 'Batch_Applied_Status : ' || l_batch_applied_status);

      IF l_batch_applied_status = 'COMPLETED_CREATION' THEN
         IF l_create_flag = 'Y' THEN
          arp_standard.debug( 'This is an error condition');
          arp_standard.debug('Batch is already created.');
          fnd_file.put_line( FND_FILE.LOG, 'Batch is already Created.');
	  FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
          APP_EXCEPTION.raise_exception;
         ELSIF l_approve_flag = 'N' AND l_format_flag = 'Y' THEN
          arp_standard.debug( 'This is an error condition');
          arp_standard.debug('Batch should be Approved before Formatting.');
          fnd_file.put_line( FND_FILE.LOG, 'Batch should be Approved before Formatting.');
	  FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
          APP_EXCEPTION.raise_exception;
         END IF;
      ELSIF l_batch_applied_status = 'COMPLETED_APPROVAL' AND
            (l_create_flag = 'Y' OR l_approve_flag = 'Y') THEN
            arp_standard.debug( 'This is an error condition');
            arp_standard.debug( 'Batch is already Approved.');
            fnd_file.put_line( FND_FILE.LOG, 'Batch is already Approved.');
	    FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
      ELSIF l_batch_applied_status = 'COMPLETED_FORMAT' AND
            (l_create_flag = 'Y' OR l_approve_flag = 'Y' )THEN
            arp_standard.debug( 'This is an error condition');
            arp_standard.debug( 'Batch is already Formatted.');
            fnd_file.put_line( FND_FILE.LOG, 'Batch is already Formatted.');
	    FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
      END IF;

    END IF;
    --Create a batch if the batch id is null
    IF p_batch_id is NULL and l_create_flag = 'Y' THEN
	      insert_batch( l_batch_date,
				    l_gl_date,
				    l_approve_flag,
				    l_format_flag,
				    l_currency_code,
				    l_remittance_method,
				    l_receipt_class_id,
				    l_receipt_method_id,
				    l_remittance_bank_branch_id,
				    l_remittance_bank_account_id,
				    o_batch_id
				    );
		if p_payment_method_id is not null then
           select rm.payment_channel_code,b.set_of_books_id
             into  p_payment_type_code, p_sob_id
             from  ar_receipt_methods rm,
                   ar_batches b
             where rm.receipt_method_id = p_payment_method_id
             and   b.receipt_method_id = rm.receipt_method_id
             and   b.batch_id = o_batch_id;
    else
           p_payment_type_code := null;
           select b.set_of_books_id
             into  p_sob_id
             from  ar_batches b
             where b.batch_id = o_batch_id;
    end if;
                          select_update_rec(
                                p_customer_number_l=> p_customer_number_l,
                                p_customer_number_h=>  p_customer_number_h,
                                p_customer_name_l=> p_customer_name_l,
                                p_customer_name_h=>  p_customer_name_h,
                                p_doc_num_l=> p_doc_num_l,
                                p_doc_num_h=>  p_doc_num_h,
                                p_trx_date_l=> fnd_date.canonical_to_date(p_trx_date_l),
                                p_trx_date_h=> fnd_date.canonical_to_date(p_trx_date_h),
                                p_due_date_l=> fnd_date.canonical_to_date(p_due_date_l),
                                p_due_date_h=> fnd_date.canonical_to_date(p_due_date_h),
                                p_trx_num_l=> p_trx_num_l,
                                p_trx_num_h=> p_trx_num_h,
                                p_remittance_total_to=> p_remittance_total_to,
                                p_remittance_total_from=> p_remittance_total_from,
                                p_batch_id=>  o_batch_id ,
                                p_receipt_method_id=>  l_receipt_method_id ,
                                p_currency_code=> p_batch_currency,
                                p_payment_type_code=> p_payment_type_code,
                                p_sob_id=>  p_sob_id ,
                                p_remit_method_code=> p_remit_method_code,
                                p_remit_bank_account_id=>  l_remittance_bank_account_id ,
                                p_return_status=>l_return_status);

    ELSIF p_batch_id IS NULL and l_create_flag = 'N' THEN
		    arp_standard.debug( 'This is an error condition');
		    arp_standard.debug( 'Batch Name is not supplied.');
		    fnd_file.put_line( FND_FILE.LOG, 'Create is No and No Batch Name is Supplied.');
		    FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
                    APP_EXCEPTION.raise_exception;
     ELSE
	      o_batch_id := p_batch_id;
    END IF;

    --Error condition
    IF o_batch_id IS NULL THEN
	arp_standard.debug( 'This is an error condition');
	insert_exceptions( p_batch_id => -333,
			  p_request_id =>l_request_id,
			  p_exception_code => 'NO_BATCH',
			  p_additional_message => 'Error during inserting the
batch' );

	arp_standard.debug ( 'calling the report - batch_id  ' || -333 );
	arp_standard.debug ( 'calling the report ' || l_request_id);

	submit_report ( p_batch_id => o_batch_id,
		       p_request_id => l_request_id);
        RETURN;
    END IF;
    BEGIN
    l_count := 0;
   select count(*)
   INTO l_count
   from AR_CASH_RECEIPTS
   where selected_remittance_batch_id = o_batch_id;
  EXCEPTION
    when no_data_found THEN
      l_count :=0;
  END;
    --fetch org id,need to set it for child requests
    SELECT org_id
    INTO l_org_id
    FROM ar_system_parameters;
    fnd_file.put_line( FND_FILE.LOG, 'Populating interim table ....'||l_count);
    IF l_count > 0 THEN
    l_ins_stmt := 'INSERT  /*+ append */ INTO ar_autorem_interim
                        (receipt_number, --cr.receipt_number
                        cash_receipt_id,
                        creation_status,--rc.creation_status
                        org_id,    -- cr.org_id
                        party_id,
                        payment_channel_code,
                        merchant_ref,
                        currency_code,
                        pay_from_customer,
                        customer_site_use_id,
                        cash_receipt_history_id,
                        exchange_date,
                        exchange_rate,
                        exchange_rate_type,
                        amount1,
                        acctd_amount,
                        factor_discount_amount,
                        remittance_ccid,
                        bank_charges_ccid,
                        code_combination_id,
                        crh_gl_date,
                        crh_trx_date,
                        payment_server_order_num,
                        approval_code,
                        unique_ref,
                        customer_bank_account_id,
                        payment_trxn_extension_id,
                        amount2,
                        batch_id,
                        current_worker
                          )  ';
    IF PG_PARALLEL IN ('Y', 'C') THEN
        l_ins_stmt := l_ins_stmt ||
                'SELECT
/*+ leading(gtt,crh) cardinality(gtt 1000) swap_join_inputs(bat) use_hash(bat) parallel(gtt) parallel(crh) use_nl(crh,cr,hca,party,ps,d) index(cr AR_CASH_RECEIPTS_U1) */';
    ELSE
        l_ins_stmt := l_ins_stmt ||
                'SELECT
/*+ leading(gtt,crh) cardinality(gtt 1000) swap_join_inputs(bat) use_hash(bat) use_nl(crh,cr,hca,party,ps,d) */';
    END IF;
    l_ins_stmt := l_ins_stmt || ' cr.receipt_number,
            cr.cash_receipt_id,
            rc.creation_status,
            cr.org_id,
            party.party_id,
            rm.payment_channel_code,
            rm.merchant_ref,
            cr.currency_code,
            cr.pay_from_customer,
            cr.customer_site_use_id,
            crh.cash_receipt_history_id,
            crh.exchange_date,
            crh.exchange_rate,
            crh.exchange_rate_type,
            crh.amount amount1,
            crh.acctd_amount,
            nvl(cr.factor_discount_amount,0) factor_discount_amount,
            decode( bat.remit_method_code,
                       ''FACTORING'', rma.factor_ccid,
                       rma.remittance_ccid) remittance_ccid,
            rma.bank_charges_ccid,
            d.code_combination_id,
            greatest((bat.gl_date), (crh.trx_date)) crh_gl_date,
            greatest((bat.batch_date), (crh.trx_date)) crh_trx_date,
            cr.payment_server_order_num,
            cr.approval_code,
            DECODE(cr.unique_reference,
                         NULL,SYS_GUID(),
                         cr.unique_reference ) unique_ref,
            cr.customer_bank_account_id,
            cr.payment_trxn_extension_id,
            cr.amount amount2,
            cr.selected_remittance_batch_id,
            --MOD(cr.cash_receipt_id, p_total_workers) + 1
            --MOD(CEIL(cr.cash_receipt_id/10000), p_total_workers) + 1
            MOD(CEIL((DENSE_RANK() over(order by crh.cash_receipt_id))/5000), :b_total_workers) + 1
 FROM       ar_rem_cr_id_gtt gtt,
            ar_cash_receipts cr,
            ar_receipt_methods rm,
            ar_receipt_classes rc,
            hz_cust_accounts hca,
            hz_parties    party,
            /*ar_remit_gt g,*/
            ar_cash_receipt_history crh,
            ar_batches bat,
            ar_receipt_method_accounts rma,
            ar_distributions d
WHERE      cr.selected_remittance_batch_id = :b_batch_id
           AND cr.REMIT_BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID
           AND bat.batch_id = cr.selected_remittance_batch_id
           AND rm.receipt_method_id = cr.receipt_method_id
           AND rma.receipt_method_id = cr.receipt_method_id
           AND cr.cash_receipt_id = crh.cash_receipt_id
           AND crh.current_record_flag = ''Y''
           AND crh.status = ''CONFIRMED''
           AND crh.cash_receipt_history_id = d.source_id
           AND d.source_type = ''CONFIRMATION''
           AND d.source_table = ''CRH''
           AND hca.party_id = party.party_id(+)
           AND hca.cust_account_id(+) = cr.pay_from_customer
           AND cr.receipt_method_id = rm.receipt_method_id
           AND rm.receipt_class_id = rc.receipt_class_id
           and gtt.CASH_RECEIPT_HISTORY_ID = CRH.CASH_RECEIPT_HISTORY_ID ';

    commit;
    execute immediate 'alter session enable parallel dml';
    ins_rec := dbms_sql.open_cursor();
    dbms_sql.parse (ins_rec, l_ins_stmt, dbms_sql.v7);
    dbms_sql.bind_variable( ins_rec, ':b_total_workers', p_total_workers);
    dbms_sql.bind_variable( ins_rec, ':b_batch_id', o_batch_id);
    ignore := dbms_sql.execute(ins_rec);
    commit;

    --Invoke the child programs
    FOR l_worker_number IN 1..p_total_workers LOOP
	fnd_file.put_line(FND_FILE.LOG,'worker # : ' || l_worker_number );
	submit_subrequest (l_worker_number,l_org_id);
    END LOOP;

    arp_standard.debug ( 'The Master program waits for child processes');

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
	    P_RETCODE := 2;
	    arp_util.debug('Worker # '|| i||' has a phase
'||l_req_status_tab(i).dev_phase);

	ELSIF l_req_status_tab(i).dev_phase = 'COMPLETE'
	       AND l_req_status_tab(i).dev_status <> 'NORMAL' THEN
	    P_RETCODE := 2;
	    arp_util.debug('Worker # '|| i||' completed with status
'||l_req_status_tab(i).dev_status);
	ELSE
	    arp_util.debug('Worker # '|| i||' completed successfully');
	END IF;

    END LOOP;

    delete from ar_autorem_interim where batch_id = o_batch_id;
    END IF;
/* Bug 5051186  Update the Batch Status  */
    IF   l_format_flag = 'Y' THEN
         l_batch_applied_status := 'COMPLETED_FORMAT';
    ELSIF l_approve_flag = 'Y' then
         l_batch_applied_status := 'COMPLETED_APPROVAL';
    ELSIF l_create_flag = 'Y' then
         l_batch_applied_status := 'COMPLETED_CREATION';
    END IF;

    /* bug 7352164 update control count and control amount */
    IF ( l_create_flag = 'Y' AND l_approve_flag = 'N' AND l_format_flag = 'N') THEN
       SELECT
         nvl(sum(cr.amount),0),
         count(*) into
         l_control_amount,
         l_control_count
       FROM   ar_cash_receipts cr
       WHERE  cr.selected_remittance_batch_id = o_batch_id;

       UPDATE ar_batches
            SET batch_applied_status =  l_batch_applied_status,
                           control_count = l_control_count,
                           control_amount= l_control_amount
            WHERE batch_id = o_batch_id;

    ELSIF l_approve_flag = 'Y' THEN
       SELECT
             nvl(sum(crh.amount),0),
             count(*) into
             l_control_amount,
             l_control_count
       FROM    ar_cash_receipt_history crh
       WHERE   crh.batch_id = o_batch_id
       AND     crh.status = 'REMITTED'
       AND     crh.current_record_flag = 'Y';

       UPDATE ar_batches
            SET batch_applied_status =  l_batch_applied_status,
                           control_count = l_control_count,
                           control_amount= l_control_amount
            WHERE batch_id = o_batch_id;
   ELSE
   /* No need to update counts if the batch is submitted for format only */
        UPDATE ar_batches
            SET batch_applied_status =  l_batch_applied_status
        WHERE batch_id = o_batch_id;
   END IF;

/* START FORMATTING */
    IF l_format_flag = 'Y' THEN
         fnd_file.put_line(FND_FILE.LOG,'calling the report- batch_id  format  ' || o_batch_id);
         SUBMIT_FORMAT ( p_batch_id =>o_batch_id);
    END IF;
/* END FORMATTING */


    IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,' COMMITING WORK - ALL REMIT RECS ');
    END IF;

    COMMIT;

    fnd_file.put_line( FND_FILE.LOG, 'submit_autorem_parallel()-');

EXCEPTION

  WHEN OTHERS THEN
    RAISE ;

END submit_autorem_parallel;

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
      p_batch_date                       IN  ar_cash_receipts.receipt_date%TYPE DEFAULT NULL,
      p_batch_gl_date                    IN  ar_cash_receipt_history.gl_date%TYPE DEFAULT NULL,
      p_approve_flag                     IN  ar_cash_receipts.override_remit_account_flag%TYPE DEFAULT NULL,
      p_format_flag                      IN  ar_cash_receipts.override_remit_account_flag%TYPE DEFAULT NULL,
      p_currency_code                    IN  ar_batches.currency_code%TYPE,
      p_remmitance_method                IN  ar_batches.remit_method_code%TYPE,
      p_receipt_class_id                    IN  ar_receipt_classes.receipt_class_id%TYPE,
      p_payment_method_id                   IN  ar_receipt_methods.receipt_method_id%TYPE,
      p_remmitance_bank_branch_id           IN  ap_bank_accounts.bank_branch_id%TYPE DEFAULT NULL,
      p_remmitance_bank_account_id               IN  ar_receipt_method_accounts.REMIT_BANK_ACCT_USE_ID%TYPE DEFAULT NULL,
      p_batch_id                         OUT NOCOPY NUMBER
      ) IS
            l_batch_rec             ar_batches%ROWTYPE;
            l_row_id                VARCHAR2(50);
            l_batch_id              NUMBER := NULL;
            l_batch_name            VARCHAR2(30);
            l_batch_applied_status  VARCHAR2(30);
            batch_id                NUMBER := NULL;
            p_receipt_method_id     NUMBER;
            p_batch_remit_method_code VARCHAR2(30);
            p_batch_remit_bank_br_id  NUMBER (18);
            p_batch_remit_bank_acc_id  NUMBER(18);
            p_batch_bank_deposit_num  VARCHAR2(30);
            p_batch_exchange_date DATE ;
            p_batch_exchange_rate NUMBER;
            p_batch_exchange_rate_type VARCHAR2(10);

            psite_required           VARCHAR2(2);
            pinvoices_per_commit        NUMBER;
            preceipts_per_commit        NUMBER;
            pfunctional_currency     VARCHAR2(20);
            pacc_method              VARCHAR2(20);

            l_return_status  VARCHAR2(1);
            l_msg_count      NUMBER;
            l_msg_data      VARCHAR2(240);
            l_count          NUMBER;

             l_request_id              NUMBER;
             l_last_updated_by         NUMBER;
             l_created_by              NUMBER;
             l_last_update_login       NUMBER;
             l_program_application_id  NUMBER;
             l_program_id              NUMBER;




BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'autoremapi start ()+');
     fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_date '           ||p_batch_date);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_gl_date '              ||p_batch_gl_date);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_approve_flag '         ||p_approve_flag);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_format_flag '          ||p_format_flag);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_currency_code '        ||p_currency_code);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_remmitance_method '    ||p_remmitance_method);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_receipt_class '        ||p_receipt_class_id);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_payment_method '            ||p_payment_method_id);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_remmitance_bank_branch '    || p_remmitance_bank_branch_id);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_remmitance_bank_account '    || p_remmitance_bank_account_id);

  END IF;

 --p_batch_id := 10;


              l_request_id := arp_standard.profile.request_id;
       l_last_updated_by := arp_standard.profile.user_id ;
       l_created_by := arp_standard.profile.user_id ;
       l_last_update_login := arp_standard.profile.last_update_login ;
       l_program_application_id := arp_standard.application_id ;
       l_program_id := arp_standard.profile.program_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'autoremapi calling auto_batch ()+');
  END IF;




        /* here we will have to add something like this */


        /*
select bbt.bank_branch_id ,bbt.remit_account_id
from ap_bank_branches bbt
where bbt.bank_branch_id in
(select distinct bb.bank_branch_id
from ap_bank_accounts ba, ap_bank_branches bb, ar_receipt_method_accounts rma, ar_system_parameters asp
where rma.receipt_method_id = nvl(p_receipt_method_id, rma.receipt_method_id )
and rma.bank_account_id = ba.bank_account_id
and ( ba.currency_code = p_currency_code
or ba.receipt_multi_currency_flag = 'Y' )
and ba.set_of_books_id =  asp.set_of_books_id
and nvl(ba.inactive_date , fnd_date.canonical_to_date(p_batch_date) + 1 ) > fnd_date.canonical_to_date(p_batch_date)
and fnd_date.canonical_to_date(p_batch_date)
between rma.start_date
and nvl(rma.end_date,fnd_date.canonical_to_date(p_batch_date))
and ( bb.bank_branch_id = ba.bank_branch_id
or ( bb.institution_type = 'CLEARING HOUSE'
and exists
( select 1
from ar_receipt_method_accounts rma2, ap_bank_accounts ba2, ap_bank_branches bb2
where rma2.receipt_method_id = nvl(p_receipt_method_id, rma2.receipt_method_id)
and rma2.bank_account_id = ba2.bank_account_id
and ba2.set_of_books_id = asp.set_of_books_id
and ba2.currency_code = p_currency_code
and ba2.bank_branch_id = bb2.bank_branch_id
and bb2.clearing_house_id = bb.bank_branch_id) ) ) )
order by bbt.bank_branch_name, bbt.bank_name;

*/




       p_batch_exchange_date := p_batch_date;
       p_batch_exchange_rate := 1;
       p_batch_exchange_rate_type := 'User';
       p_batch_remit_method_code := p_remmitance_method ;
       p_batch_bank_deposit_num := null;

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'autoremapi start ()+');
     fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_date '           ||p_batch_date);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_gl_date '              ||p_batch_gl_date);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_receipt_class_id '         ||p_receipt_class_id);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_receipt_method_id'          ||p_payment_method_id);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_currency_code '        ||p_currency_code);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_remmitance_method '    ||p_batch_remit_method_code);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_rem_bank_br_id '        ||p_remmitance_bank_branch_id);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_remit_bank_acc_id '            ||p_remmitance_bank_account_id);
     fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_bank_deposit_num '    || p_batch_bank_deposit_num);

  END IF;


              l_batch_rec.receipt_class_id   := to_number(p_receipt_class_id);
              l_batch_rec.receipt_method_id  := to_number(p_payment_method_id);
              l_batch_rec.batch_date         := to_date(p_batch_date,'dd/mm/yy');
              l_batch_rec.gl_date            := to_date(p_batch_gl_date,'dd/mm/yy');
              l_batch_rec.currency_code      := p_currency_code;
              l_batch_rec.comments           := null;
              l_batch_rec.exchange_date      := to_date(p_batch_exchange_date,'dd/mm/yy');
              l_batch_rec.exchange_rate      := to_number(p_batch_exchange_rate);
              l_batch_rec.exchange_rate_type := p_batch_exchange_rate_type;

              l_batch_rec.remit_method_code  := p_batch_remit_method_code;
              l_batch_rec.remittance_bank_branch_id := to_number(p_remmitance_bank_branch_id);
              l_batch_rec.remittance_bank_account_id := to_number(p_remmitance_bank_account_id);
              l_batch_rec.bank_deposit_number := p_batch_bank_deposit_num;


                   arp_rw_batches_pkg.insert_remit_batch(
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
                               l_batch_rec.remit_method_code,
                               l_batch_rec.receipt_class_id,
                               l_batch_rec.receipt_method_id,
                               l_batch_rec.remittance_bank_account_id,
                               l_batch_rec.remittance_bank_branch_id,
                               l_batch_rec.bank_deposit_number,
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
                               'Y',
                               l_batch_applied_status, --Out
                               'AUTOREMSRS',
                               '1.0'
                               );

          batch_id := to_char(l_batch_id);

      IF batch_id IS NULL THEN
        arp_standard.debug ('WAIT HERE THE VALUE OF BATCH_ID IS NULL ERROR');
        -- G_ERROR := 'Y';
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
        fnd_file.put_line(FND_FILE.LOG,  'value of batch_id '||batch_id);
      END IF;


  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'autoremapi calling auto_batch  end ()-');
  END IF;

   p_batch_id := to_number(l_batch_id);

      IF p_batch_id IS NULL THEN
        arp_standard.debug ('WAIT HERE THE VALUE OF BATCH_ID IS NULL ERROR');
      END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,  'value of batch_id '||p_batch_id);
  END IF;
/* inserted the batch record end */


/* GET THE VALUES from SYSTEM PARAMETERS */
IF PG_DEBUG in ('Y','C') THEN
   fnd_file.put_line(FND_FILE.LOG, 'get info from system parameters');
     fnd_file.put_line(FND_FILE.LOG,  'value of batch_id '||p_batch_id);
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
fnd_file.put_line(FND_FILE.LOG, 'ERROR NO DATA FOUND IN SYSTEM OPTION');
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
END;


  IF PG_DEBUG in ('Y', 'C') THEN
   fnd_file.put_line(FND_FILE.LOG,'value of site_req_flag ' || psite_required);
   fnd_file.put_line(FND_FILE.LOG,'value of the invoices per commit' || pinvoices_per_commit);
   fnd_file.put_line(FND_FILE.LOG,'value of receipts per_commit ' || preceipts_per_commit);
   fnd_file.put_line(FND_FILE.LOG,'value of currency code' || pfunctional_currency);
   fnd_file.put_line(FND_FILE.LOG,'value of acc_method ' || pacc_method );
  END IF;

/* END FROM SYSTEM PARAMETERS*/

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'insert_batch ()-');
  END IF;


EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'Exception : insert_batch() ');
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
  END IF;
  raise;


END insert_batch;

/*========================================================================+
 |  PROCEDURE create_and_update_remit_rec                                 |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
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
PROCEDURE create_and_update_remit_rec(
          p_batch_id       IN  NUMBER,
          p_return_status  OUT NOCOPY  VARCHAR2
                              ) IS

l_rows_processed INTEGER;
l_rows_fetched INTEGER;
l_sel_stmt long;
sel_receipts INTEGER;
/* declare the cursor variables */

p_cash_receipt_id                    ar_cash_receipts.cash_receipt_id%TYPE;
p_payment_type_code                  ar_receipt_methods.payment_type_code%TYPE;
p_merchant_ref                       ar_receipt_methods.merchant_ref%TYPE;
p_currency_code                      ar_cash_receipts.currency_code%TYPE;
p_pay_from_customer                  ar_cash_receipts.pay_from_customer%TYPE;
p_customer_site_use_id               ar_cash_receipts.customer_site_use_id%TYPE;
p_prv_cash_receipt_hist_id           ar_cash_receipt_history.cash_receipt_history_id%TYPE;
p_exchange_date                      ar_cash_receipt_history.exchange_date%TYPE;
p_exchange_rate                      ar_cash_receipt_history.exchange_rate%TYPE;
p_exchange_type                      ar_cash_receipt_history.exchange_rate_type%TYPE;
p_cr_amount                          ar_cash_receipts.amount%TYPE;
p_cr_acctd_amount                    ar_cash_receipt_history.acctd_amount%TYPE;
p_cr_factor_discount_amount          ar_cash_receipts.factor_discount_amount%TYPE;
p_remmitance_ccid                    ar_receipt_method_accounts.remittance_ccid%TYPE;
p_bank_charges_ccid                  ar_receipt_method_accounts.bank_charges_ccid%TYPE;
p_code_combination_id                ar_distributions.code_combination_id%TYPE;
p_cash_receipt_history_id            ar_cash_receipt_history.cash_receipt_history_id%TYPE;
p_crh_gl_date                        ar_cash_receipt_history.gl_date%TYPE;
p_crh_trx_date                       ar_cash_receipt_history.trx_date%TYPE;
p_payment_server_order_num           ar_cash_receipts.payment_server_order_num%TYPE;
p_approval_code                      ar_cash_receipts.approval_code%TYPE;
p_receipt_number                     ar_cash_receipts.receipt_number%TYPE;
p_unique_ref                         ar_cash_receipts.unique_reference%TYPE;
p_customer_bank_account_id           ar_cash_receipts.customer_bank_account_id%TYPE;
p_payment_trxn_extension_id          ar_cash_receipts.payment_trxn_extension_id%TYPE;

/* end declare */

/* declare the insert array elements */
i                              NUMBER;
dummy                              NUMBER;
inst_stmt                      varchar2(2000);
cash_receipt_id_array                dbms_sql.Number_Table;
payment_type_CODE_array              dbms_sql.varchar2_Table;
merchant_ref_array                   dbms_sql.varchar2_Table;
currency_code_array                  dbms_sql.varchar2_Table;
pay_from_customer_array              dbms_sql.varchar2_Table;
customer_site_use_id_array           dbms_sql.Number_Table;
prv_cash_receipt_hist_id_array       dbms_sql.Number_Table;
exchange_date_array                  dbms_sql.date_Table;
exchange_rate_array                  dbms_sql.Number_Table;
exchange_type_array                  dbms_sql.varchar2_Table;
cr_amount_array                      dbms_sql.Number_Table;
cr_acctd_amount_array                dbms_sql.Number_Table;
cr_factor_discount_amt_array      dbms_sql.Number_Table;
remmitance_ccid_array                dbms_sql.Number_Table;
bank_charges_ccid_array              dbms_sql.Number_Table;
code_combination_id_array            dbms_sql.Number_Table;
cash_receipt_history_id_array        dbms_sql.Number_Table;
crh_gl_date_array                    dbms_sql.date_Table;
crh_trx_date_array                   dbms_sql.date_Table;
payment_server_order_num_array       dbms_sql.varchar2_Table;
approval_code_array                  dbms_sql.varchar2_Table;
receipt_number_array                 dbms_sql.varchar2_Table;
unique_ref_array                     dbms_sql.varchar2_Table;
customer_bank_account_id_array       dbms_sql.Number_Table;
payment_trxn_extn_id_array      dbms_sql.Number_Table;
rem_t                          NUMBER;
/* end declare */


-- update variables
   upd_stmt1                   varchar2(1000);
   rem_t1                      number;
   dum                      number;

-- insert CRH variables.
   ins_crh1               long;
   rem_t3                 number;
   d1                     number;

-- XLA uptake
   CURSOR c_rec is
     select hist.cash_receipt_id cr_id
     from ar_cash_receipt_history hist,
          AR_REMIT_GT rec
     where hist.STATUS = 'REMITTED'
     and   hist.cash_receipt_id = rec.cash_receipt_id;

l_xla_ev_rec             ARP_XLA_EVENTS.XLA_EVENTS_TYPE;

-- insert DIST  variables.
   ins_dist1               long;
   rem_t4                 number;
   d2                     number;

             l_factor_flag             varchar2(1);
             l_request_id              NUMBER;
             l_last_updated_by         NUMBER;
             l_created_by              NUMBER;
             l_last_update_login       NUMBER;
             l_program_application_id  NUMBER;
             l_program_id              NUMBER;
             l_org_id              NUMBER;




BEGIN

 IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'create and upd  start ()+');
     fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_id          ' || p_batch_id);
 END IF;

   select decode(remit_method_code, 'FACTORING', 'Y', 'N')
   into l_factor_flag
   from ar_batches
   where batch_id = p_batch_id;


              l_request_id := arp_standard.profile.request_id;
       l_last_updated_by := arp_standard.profile.user_id ;
       l_created_by := arp_standard.profile.user_id ;
       l_last_update_login := arp_standard.profile.last_update_login ;
       l_program_application_id := arp_standard.application_id ;
       l_program_id := arp_standard.profile.program_id;
       l_org_id := arp_standard.sysparm.org_id;


    l_sel_stmt := ' SELECT cr.cash_receipt_id,
               rm.payment_channel_code,
               rm.merchant_ref,
               cr.currency_code,
               cr.pay_from_customer,
               cr.customer_site_use_id,
               crh.cash_receipt_history_id,
               crh.exchange_date,
               crh.exchange_rate,
               crh.exchange_rate_type,
               crh.amount,
               crh.acctd_amount,
               nvl(cr.factor_discount_amount,0),
               decode( bat.remit_method_code,
                       ''FACTORING'', rma.factor_ccid,
                       rma.remittance_ccid),
               rma.bank_charges_ccid,
               d.code_combination_id,
               ar_cash_receipt_history_s.nextval,
               greatest((bat.gl_date), (crh.gl_date)),
               greatest((bat.batch_date), (crh.trx_date)),
               cr.payment_server_order_num,
               cr.approval_code,
               cr.receipt_number,
               DECODE(cr.unique_reference,
                         NULL,SYS_GUID(),
                         cr.unique_reference ),
               cr.customer_bank_account_id,
               cr.payment_trxn_extension_id
          FROM ar_cash_receipts cr, ar_cash_receipt_history crh,
               ar_receipt_methods rm,
               ar_batches bat,
               ar_receipt_method_accounts rma,
               ar_payment_schedules ps,
               ar_distributions d
          WHERE cr.selected_remittance_batch_id = :ab_batch_id
           AND cr.REMIT_BANK_ACCT_USE_ID = rma.REMIT_BANK_ACCT_USE_ID
           AND bat.batch_id = cr.selected_remittance_batch_id
           AND rm.receipt_method_id = cr.receipt_method_id
           AND rma.receipt_method_id = cr.receipt_method_id
           AND cr.cash_receipt_id = crh.cash_receipt_id
           AND crh.current_record_flag = ''Y''
           AND ps.cash_receipt_id(+) = cr.cash_receipt_id
           AND crh.status = ''CONFIRMED''
           AND crh.cash_receipt_history_id = d.source_id
           AND d.source_type = ''CONFIRMATION''
           AND d.source_table = ''CRH''
	   ';

           sel_receipts := dbms_sql.open_cursor;

           dbms_sql.parse (sel_receipts,l_sel_stmt,dbms_sql.v7);

           dbms_sql.bind_variable (sel_receipts,':ab_batch_id',p_batch_id);

           dbms_sql.define_column (sel_receipts, 1,  p_cash_receipt_id);
           dbms_sql.define_column (sel_receipts, 2,  p_payment_type_code,30);
           dbms_sql.define_column (sel_receipts, 3,  p_merchant_ref,80);
           dbms_sql.define_column (sel_receipts, 4,  p_currency_code,15);
           dbms_sql.define_column (sel_receipts, 5,  p_pay_from_customer);
           dbms_sql.define_column (sel_receipts, 6,  p_customer_site_use_id);
           dbms_sql.define_column (sel_receipts, 7,  p_prv_cash_receipt_hist_id);
           dbms_sql.define_column (sel_receipts, 8,  p_exchange_date);
           dbms_sql.define_column (sel_receipts, 9,  p_exchange_rate);
           dbms_sql.define_column (sel_receipts, 10, p_exchange_type,30);
           dbms_sql.define_column (sel_receipts, 11, p_cr_amount);
           dbms_sql.define_column (sel_receipts, 12, p_cr_acctd_amount);
           dbms_sql.define_column (sel_receipts, 13, p_cr_factor_discount_amount);
           dbms_sql.define_column (sel_receipts, 14, p_remmitance_ccid );
           dbms_sql.define_column (sel_receipts, 15, p_bank_charges_ccid);
           dbms_sql.define_column (sel_receipts, 16, p_code_combination_id);
           dbms_sql.define_column (sel_receipts, 17, p_cash_receipt_history_id);
           dbms_sql.define_column (sel_receipts, 18, p_crh_gl_date);
           dbms_sql.define_column (sel_receipts, 19, p_crh_trx_date);
           dbms_sql.define_column (sel_receipts, 20, p_payment_server_order_num,80);
           dbms_sql.define_column (sel_receipts, 21, p_approval_code,80);
           dbms_sql.define_column (sel_receipts, 22, p_receipt_number,30);
           dbms_sql.define_column (sel_receipts, 23, p_unique_ref,32);
           dbms_sql.define_column (sel_receipts, 24, p_customer_bank_account_id);
           dbms_sql.define_column (sel_receipts, 25, p_payment_trxn_extension_id);

             IF PG_DEBUG in ('Y', 'C') THEN
             fnd_file.put_line(FND_FILE.LOG, 'the select statemnt' || l_sel_stmt);
             END IF;

            l_rows_processed := dbms_sql.execute( sel_receipts);

            i:= 0;

     WHILE dbms_sql.fetch_rows( sel_receipts) > 0 LOOP
             fnd_file.put_line(FND_FILE.LOG,'the value of i- ent ' || to_char(i));

           dbms_sql.column_value (sel_receipts, 1,  p_cash_receipt_id);
           dbms_sql.column_value (sel_receipts, 2,  p_payment_type_code);
           dbms_sql.column_value (sel_receipts, 3,  p_merchant_ref);
           dbms_sql.column_value (sel_receipts, 4,  p_currency_code);
           dbms_sql.column_value (sel_receipts, 5,  p_pay_from_customer);
           dbms_sql.column_value (sel_receipts, 6,  p_customer_site_use_id);
           dbms_sql.column_value (sel_receipts, 7,  p_prv_cash_receipt_hist_id);
           dbms_sql.column_value (sel_receipts, 8,  p_exchange_date);
           dbms_sql.column_value (sel_receipts, 9,  p_exchange_rate);
           dbms_sql.column_value (sel_receipts, 10, p_exchange_type);
           dbms_sql.column_value (sel_receipts, 11, p_cr_amount);
           dbms_sql.column_value (sel_receipts, 12, p_cr_acctd_amount);
           dbms_sql.column_value (sel_receipts, 13, p_cr_factor_discount_amount);
           dbms_sql.column_value (sel_receipts, 14, p_remmitance_ccid );
           dbms_sql.column_value (sel_receipts, 15, p_bank_charges_ccid);
           dbms_sql.column_value (sel_receipts, 16, p_code_combination_id);
           dbms_sql.column_value (sel_receipts, 17, p_cash_receipt_history_id);
           dbms_sql.column_value (sel_receipts, 18, p_crh_gl_date);
           dbms_sql.column_value (sel_receipts, 19, p_crh_trx_date);
           dbms_sql.column_value (sel_receipts, 20, p_payment_server_order_num);
           dbms_sql.column_value (sel_receipts, 21, p_approval_code);
           dbms_sql.column_value (sel_receipts, 22, p_receipt_number);
           dbms_sql.column_value (sel_receipts, 23, p_unique_ref);
           dbms_sql.column_value (sel_receipts, 24, p_customer_bank_account_id);
           dbms_sql.column_value (sel_receipts, 25, p_payment_trxn_extension_id);



               IF PG_DEBUG in ( 'Y','C') THEN
              fnd_file.put_line(FND_FILE.LOG,'the value of ps_id ' || p_cash_receipt_id);
              fnd_file.put_line(FND_FILE.LOG,'the value of i ' || to_char(i));
               END IF;


        cash_receipt_id_array(i)     := p_cash_receipt_id ;
        payment_type_code_array(i)   := p_payment_type_code;
        merchant_ref_array(i)        := p_merchant_ref;
        currency_code_array(i)       := p_currency_code;
        pay_from_customer_array(i)   := p_pay_from_customer;
        customer_site_use_id_array(i)     := p_customer_site_use_id;
        prv_cash_receipt_hist_id_array(i)  := p_prv_cash_receipt_hist_id;
        exchange_date_array(i)             := p_exchange_date ;
        exchange_rate_array(i)             := p_exchange_rate;
        exchange_type_array(i)             :=p_exchange_type;
        cr_amount_array(i)                 :=p_cr_amount;
        cr_acctd_amount_array(i)           :=p_cr_acctd_amount;
        cr_factor_discount_amt_array(i)    :=p_cr_factor_discount_amount;
        remmitance_ccid_array(i)           :=p_remmitance_ccid;
        bank_charges_ccid_array(i)         :=p_bank_charges_ccid;
        code_combination_id_array(i)       :=p_code_combination_id;
        cash_receipt_history_id_array(i)   :=p_cash_receipt_history_id;
        crh_gl_date_array(i)               :=p_crh_gl_date;
        crh_trx_date_array(i)              :=p_crh_trx_date;
        payment_server_order_num_array(i)  :=p_payment_server_order_num;
        approval_code_array(i)             :=p_approval_code;
        receipt_number_array(i)            :=p_receipt_number;
        unique_ref_array(i)                :=p_unique_ref;
        customer_bank_account_id_array(i)  :=p_customer_bank_account_id;
        payment_trxn_extn_id_array(i) :=p_payment_trxn_extension_id;

            i := i + 1;

            IF PG_DEBUG in ('Y', 'C') THEN
                fnd_file.put_line(FND_FILE.LOG,'the value of i- lea ' || to_char(i));
             END IF;

    END LOOP;

     l_rows_fetched := dbms_sql.last_row_count ;

  IF PG_DEBUG in ('Y', 'C') THEN
  fnd_file.put_line(FND_FILE.LOG,'the no of rows fetched ' || l_rows_fetched);
  END IF;

  dbms_sql.close_cursor( sel_receipts);

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'selrem and create and upd 1()-');
  END IF;

-- Bulk Insert into AR_REMIT_GT

/* CHECK AND CORRECT FROM HERE DONE UPTILL HERE */
IF nvl(l_rows_fetched,0) > 0 THEN --BUG 7418725
  BEGIN

     inst_stmt := 'insert into AR_REMIT_GT values ( :c1_array,:c2_array,:c3_array,:c4_array,:c5_array,
                                               :c6_array,:c7_array,:c8_array,:c9_array,:c10_array,:c11_array,:c12_array,
                                               :c13_array,:c14_array,:c15_array,:c16_array,:c17_array,:c18_array,
                                               :c19_array,:c20_array,:c21_array,:c22_array,:c23_array,:c24_array,:c25_array)';

     rem_t := dbms_sql.open_cursor;

  dbms_sql.parse (rem_t,inst_stmt,dbms_sql.v7);

       dbms_sql.bind_array (rem_t,':c1_array',cash_receipt_id_array);
       dbms_sql.bind_array (rem_t,':c2_array',payment_type_CODE_array);
       dbms_sql.bind_array (rem_t,':c3_array',merchant_ref_array);
       dbms_sql.bind_array (rem_t,':c4_array',currency_code_array);
       dbms_sql.bind_array (rem_t,':c5_array',pay_from_customer_array);
       dbms_sql.bind_array (rem_t,':c6_array',customer_site_use_id_array);
       dbms_sql.bind_array (rem_t,':c7_array',prv_cash_receipt_hist_id_array);
       dbms_sql.bind_array (rem_t,':c8_array',exchange_date_array);
       dbms_sql.bind_array (rem_t,':c9_array',exchange_rate_array);
       dbms_sql.bind_array (rem_t,':c10_array',exchange_type_array);
       dbms_sql.bind_array (rem_t,':c11_array',cr_amount_array);
       dbms_sql.bind_array (rem_t,':c12_array',cr_acctd_amount_array);
       dbms_sql.bind_array (rem_t,':c13_array',cr_factor_discount_amt_array);
       dbms_sql.bind_array (rem_t,':c14_array',remmitance_ccid_array);
       dbms_sql.bind_array (rem_t,':c15_array',bank_charges_ccid_array);
       dbms_sql.bind_array (rem_t,':c16_array',code_combination_id_array);
       dbms_sql.bind_array (rem_t,':c17_array',cash_receipt_history_id_array);
       dbms_sql.bind_array (rem_t,':c18_array',crh_gl_date_array);
       dbms_sql.bind_array (rem_t,':c19_array',crh_trx_date_array);
       dbms_sql.bind_array (rem_t,':c20_array',payment_server_order_num_array);
       dbms_sql.bind_array (rem_t,':c21_array',approval_code_array);
       dbms_sql.bind_array (rem_t,':c22_array',receipt_number_array);
       dbms_sql.bind_array (rem_t,':c23_array',unique_ref_array);
       dbms_sql.bind_array (rem_t,':c24_array',customer_bank_account_id_array);
       dbms_sql.bind_array (rem_t,':c25_array',payment_trxn_extn_id_array);


    dummy := dbms_sql.execute(rem_t);

    dbms_sql.close_cursor(rem_t);

  EXCEPTION WHEN OTHERS THEN
    if dbms_sql.is_open(rem_t) then
      dbms_sql.close_cursor(rem_t);
    end if;
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
    raise;

  END;

/* the update and inserts */

  BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'upd-crh1 ()+');

  END IF;


/* the first update into ar_cash_receipt_history */

  upd_stmt1 := ' UPDATE ar_cash_receipt_history
                SET reversal_cash_receipt_hist_id = :ucrh_id_array,
                reversal_gl_date = :ucrh_gl_date_array,
                reversal_created_from = ''ARZARM'',
                current_record_flag = NULL,
                        last_update_date              = sysdate,
                        last_updated_by               = :i_last_updated_by,
                        last_update_login             = :i_last_update_login,
                        request_id                    = :i_request_id,
                        program_application_id        = :i_program_application_id,
                        program_id                    = :i_program_id,
                        program_update_date           = sysdate
                  WHERE cash_receipt_id = :cr_id_array
                  AND current_record_flag = ''Y''
                  AND status = ''CONFIRMED''
		  ';


  rem_t1 := dbms_sql.open_cursor;

  dbms_sql.parse (rem_t1,upd_stmt1,dbms_sql.v7);

  dbms_sql.bind_array (rem_t1,':ucrh_id_array', cash_receipt_history_id_array);
  dbms_sql.bind_array (rem_t1,':ucrh_gl_date_array',crh_gl_date_array );
  dbms_sql.bind_array (rem_t1,':cr_id_array', cash_receipt_id_array);
/* who cols*/

  dbms_sql.bind_variable (rem_t1,':i_last_updated_by',l_last_updated_by);
  dbms_sql.bind_variable (rem_t1,':i_last_update_login',l_last_update_login);
  dbms_sql.bind_variable (rem_t1,':i_request_id',l_request_id);
  dbms_sql.bind_variable (rem_t1,':i_program_application_id',l_program_application_id);
  dbms_sql.bind_variable (rem_t1,':i_program_id',l_program_id);

    dummy := dbms_sql.execute(rem_t1);

    dbms_sql.close_cursor(rem_t1);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug (to_char(SQL%ROWCOUNT) || ' row(s) updated.');
     fnd_file.put_line(FND_FILE.LOG,'upd-crh1 ()-');
  END IF;

  EXCEPTION WHEN OTHERS THEN
    if dbms_sql.is_open(rem_t1) then
      dbms_sql.close_cursor(rem_t1);
    end if;
  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'failed to update() '|| to_char(SQLCODE));
  END IF;
    raise;


  END;

/* insert into crh  */

 BEGIN


 IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'insert-crh1 ()+');
             fnd_file.put_line(FND_FILE.LOG, 'the batch_id ' || p_batch_id);

  END IF;


/* the first update into ar_cash_receipt_history */

   ins_crh1 := 'INSERT into ar_cash_receipt_history
         (cash_receipt_history_id,
          cash_receipt_id,
          status,
          trx_date,
          amount,
          acctd_amount,
          first_posted_record_flag,
          postable_flag,
          factor_flag,
          gl_date,
          current_record_flag,
          batch_id,
          exchange_date,
          exchange_rate,
          exchange_rate_type,
          account_code_combination_id,
          reversal_gl_date,
          reversal_cash_receipt_hist_id,
          prv_stat_cash_receipt_hist_id,
          factor_discount_amount,
          acctd_factor_discount_amount,
          bank_charge_account_ccid,
          posting_control_id,
          created_from,
          reversal_posting_control_id,
          gl_posted_date,
          reversal_gl_posted_date,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          request_id,
          org_id,
          program_application_id,
          program_id,
          program_update_date
         )
    select
           r.CASH_RECEIPT_HISTORY_ID,
           r.CASH_RECEIPT_ID,
          ''REMITTED'',
           r.CRH_TRX_DATE,
           r.cr_amount - r.cr_factor_discount_amount,
           r.cr_acctd_amount - DECODE(r.exchange_type, null, r.cr_factor_discount_amount,
               ''User'', arp_util.functional_amount(
                            r.cr_factor_discount_amount,
                            '''||ARP_GLOBAL.functional_currency||''',
                            nvl(r.exchange_rate,1),
                            NULL, NULL),
               gl_currency_api.convert_amount(
                       r.currency_code,
                       '''||ARP_GLOBAL.functional_currency||''',
                       r.exchange_date,
                       r.exchange_type,
                       r.cr_factor_discount_amount)),
          ''N'',
          ''Y'',
           :factor_flag,
           r.crh_gl_date,
          ''Y'',
           :i_batch_id,
           r.exchange_date,
           r.exchange_rate,
           r.exchange_type,
           r.remmitance_ccid,
          NULL,
          NULL,
           r.prv_cash_receipt_hist_id,
           r.cr_factor_discount_amount,
           DECODE(r.exchange_type, null, r.cr_factor_discount_amount,
           ''User'', arp_util.functional_amount(
                            r.cr_factor_discount_amount,
                            '''||ARP_GLOBAL.functional_currency||''',
                            nvl(r.exchange_rate,1),
                            NULL, NULL),
               gl_currency_api.convert_amount(
                       r.currency_code,
                       '''||ARP_GLOBAL.functional_currency||''',
                       r.exchange_date,
                       r.exchange_type,
                       r.cr_factor_discount_amount)),
           r.bank_charges_ccid,
          ''-3'',
          ''ARZARM'',
          NULL,
          NULL,
          NULL,
          :i_created_by,
          sysdate,
          :i_last_updated_by,
          sysdate,
          :i_last_update_login,
          :i_request_id,
          :i_org_id,
          :i_program_application_id,
          :i_program_id,
          sysdate
          FROM AR_REMIT_GT r
          WHERE r.cash_receipt_history_id is not null';

  rem_t3 := dbms_sql.open_cursor;

  dbms_sql.parse (rem_t3,ins_crh1,dbms_sql.v7);

             IF PG_DEBUG in ('Y', 'C') THEN
             fnd_file.put_line(FND_FILE.LOG, 'the batch_id ' || p_batch_id);
             END IF;


  dbms_sql.bind_variable (rem_t3,':i_batch_id',p_batch_id);                 -- NOTE THIS ONE
  dbms_sql.bind_variable (rem_t3,':factor_flag',l_factor_flag);                 -- NOTE THIS ONE
/* who cols */
  dbms_sql.bind_variable (rem_t3,':i_created_by',l_created_by);
  dbms_sql.bind_variable (rem_t3,':i_last_updated_by',l_last_updated_by);
  dbms_sql.bind_variable (rem_t3,':i_last_update_login',l_last_update_login);
  dbms_sql.bind_variable (rem_t3,':i_request_id',l_request_id);
  dbms_sql.bind_variable (rem_t3,':i_org_id',l_org_id);
  dbms_sql.bind_variable (rem_t3,':i_program_application_id',l_program_application_id);
  dbms_sql.bind_variable (rem_t3,':i_program_id',l_program_id);


             IF PG_DEBUG in ('Y', 'C') THEN
             fnd_file.put_line(FND_FILE.LOG, 'the insert statemnt' || ins_crh1);
             END IF;

    dummy := dbms_sql.execute(rem_t3);

    dbms_sql.close_cursor(rem_t3);


/* BICHATTE after the insert into crh we have to fire the XLA event */

   FOR rec in c_rec LOOP

          l_xla_ev_rec.xla_from_doc_id := rec.cr_id;
          l_xla_ev_rec.xla_to_doc_id := rec.cr_id;
          l_xla_ev_rec.xla_doc_table := 'CRH';
          l_xla_ev_rec.xla_mode := 'O';
          l_xla_ev_rec.xla_call := 'B';

  		IF PG_DEBUG in ('Y', 'C') THEN
     			fnd_file.put_line(FND_FILE.LOG,'xla_from_doc_id= '|| to_char(rec.cr_id));
     			fnd_file.put_line(FND_FILE.LOG,'xla_to_doc_id= '|| to_char(rec.cr_id));
     			fnd_file.put_line(FND_FILE.LOG,'xla_doc_table= '|| 'CRH');
     			fnd_file.put_line(FND_FILE.LOG,'xla_from_doc_id= '|| 'O');
     			fnd_file.put_line(FND_FILE.LOG,'xla_from_doc_id= '|| 'B');
  		END IF;

          arp_xla_events.create_events(l_xla_ev_rec);


  		IF PG_DEBUG in ('Y', 'C') THEN
                   fnd_file.put_line(FND_FILE.LOG,'RETURN STATUS FROM XLA () '|| to_char(SQLCODE));
                END IF;


  END LOOP;




 EXCEPTION WHEN OTHERS THEN
             fnd_file.put_line(FND_FILE.LOG, 'the insert statemnt' || ins_crh1);
    if dbms_sql.is_open(rem_t3) then
      dbms_sql.close_cursor(rem_t3);
    end if;
  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'failed to insert() '|| to_char(SQLCODE));
             fnd_file.put_line(FND_FILE.LOG, 'the insert statemnt' || ins_crh1);
  END IF;
    raise;

 END;

/* end insert into crh */

/* insert into dist */
 BEGIN


 IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'insert-dist1 ()+');

  END IF;


/* the first update into ar_cash_receipt_history */

   ins_dist1 := 'INSERT into ar_distributions
		(line_id,
                source_id,
                source_table,
                source_type,
                code_combination_id,
                currency_code,
                third_party_id,
                third_party_sub_id,
                currency_conversion_date,
                currency_conversion_rate,
                currency_conversion_type,
                amount_dr,
                amount_cr,
                acctd_amount_dr,
                acctd_amount_cr,
		creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                org_id,
                last_update_login)
	select
                ar_distributions_s.nextval,
                r.cash_receipt_history_id,
                ''CRH'',
                decode(:factor_flag,
                       ''N'',decode(l.lookup_code,
				''1'',''REMITTANCE'',
				''2'',''CONFIRMATION''),
                       ''Y'',decode(l.lookup_code,
				''1'',''FACTOR'',
				''2'',''CONFIRMATION'')),
		decode(l.lookup_code,
			''1'',r.REMMITANCE_CCID,
			''2'',r.code_combination_id),  /* its confirmation_ccid */
                r.currency_code,
                r.pay_from_customer,
                r.customer_site_use_id,
                r.exchange_date,
                r.exchange_rate,
                r.exchange_type,
		decode(l.lookup_code,
			''1'',decode(sign(to_number(r.cr_amount)),
                                   ''-1'',null,
                                  to_number(r.cr_amount)),
			''2'',decode(sign(to_number(r.cr_amount)),
                                   ''1'',null,
                                  -(to_number(r.cr_amount)))),
		decode(l.lookup_code,
			''1'',decode(sign(to_number(r.cr_amount)),
                                   ''1'',null,
                                  -(to_number(r.cr_amount))),
			''2'',decode(sign(to_number(r.cr_amount)),
                                   ''-1'',null,
                                  to_number(r.cr_amount))),
		decode(l.lookup_code,
			''1'',decode(sign(to_number(r.cr_acctd_amount)),
                                   ''-1'',null,
                                  to_number(r.cr_acctd_amount)),
			''2'',decode(sign(to_number(r.cr_acctd_amount)),
                                   ''1'',null,
                                  -(to_number(r.cr_acctd_amount)))),
		decode(l.lookup_code,
			''1'',decode(sign(to_number(r.cr_acctd_amount)),
                                   ''1'',null,
                                  -(to_number(r.cr_acctd_amount))),
			''2'',decode(sign(to_number(r.cr_acctd_amount)),
                                   ''-1'',null,
                                  to_number(r.cr_acctd_amount))),
                sysdate,
                :i_created_by,
                sysdate,
                :i_last_updated_by,
                :i_org_id,
                :i_last_update_login
        FROM    ar_cash_receipt_history crh,AR_REMIT_GT r,
		    ar_lookups l
	WHERE	crh.cash_receipt_history_id = r.cash_receipt_history_id
	AND	l.lookup_type = ''AR_CARTESIAN_JOIN''
	AND	l.lookup_code IN (''1'',''2'')';

  rem_t4 := dbms_sql.open_cursor;

  dbms_sql.parse (rem_t4,ins_dist1,dbms_sql.v7);

   IF PG_DEBUG in ('Y', 'C') THEN
      fnd_file.put_line(FND_FILE.LOG, 'the insert dist statement is ' || ins_dist1);
   END IF;

  dbms_sql.bind_variable (rem_t4,':factor_flag',l_factor_flag);                 -- NOTE THIS ONE
/* who cols */
  dbms_sql.bind_variable (rem_t4,':i_created_by',l_created_by);
  dbms_sql.bind_variable (rem_t4,':i_last_updated_by',l_last_updated_by);
  dbms_sql.bind_variable (rem_t4,':i_org_id',l_org_id);
  dbms_sql.bind_variable (rem_t4,':i_last_update_login',l_last_update_login);


    d2 := dbms_sql.execute(rem_t4);

    dbms_sql.close_cursor(rem_t4);

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'ins_dist1 ()-');
  END IF;

 EXCEPTION WHEN OTHERS THEN
    if dbms_sql.is_open(rem_t4) then
      dbms_sql.close_cursor(rem_t4);
    end if;
  IF PG_DEBUG in ('Y', 'C') THEN
   fnd_file.put_line(FND_FILE.LOG, 'the insert dist statement is ' || ins_dist1);
     fnd_file.put_line(FND_FILE.LOG,'DIST failed to insert() '|| to_char(SQLCODE));
  END IF;
    raise;

 END;

/* end insert into dist */
END IF;--check for rows returned > 0

EXCEPTION
 WHEN others THEN
  --IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'Exception : create_and_update_remit_rec() ');
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
  --END IF;
  RAISE;

END create_and_update_remit_rec ;


/*========================================================================+
 |  PROCEDURE create_and_update_remit_rec_pa                              |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
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
 | 10-JUN-2008              AGHORAKA         Created for Parallelization  |
 *=========================================================================*/
PROCEDURE create_and_update_remit_rec_pa(
          p_batch_id       IN  NUMBER,
          p_return_status  OUT NOCOPY  VARCHAR2
                              ) IS

l_rows_processed INTEGER;
l_rows_fetched INTEGER;
l_sel_stmt long;
sel_receipts INTEGER;
/* declare the cursor variables */

p_cash_receipt_id                    ar_cash_receipts.cash_receipt_id%TYPE;
p_payment_type_code                  ar_receipt_methods.payment_type_code%TYPE;
p_merchant_ref                       ar_receipt_methods.merchant_ref%TYPE;
p_currency_code                      ar_cash_receipts.currency_code%TYPE;
p_pay_from_customer                  ar_cash_receipts.pay_from_customer%TYPE;
p_customer_site_use_id               ar_cash_receipts.customer_site_use_id%TYPE;
p_prv_cash_receipt_hist_id           ar_cash_receipt_history.cash_receipt_history_id%TYPE;
p_exchange_date                      ar_cash_receipt_history.exchange_date%TYPE;
p_exchange_rate                      ar_cash_receipt_history.exchange_rate%TYPE;
p_exchange_type                      ar_cash_receipt_history.exchange_rate_type%TYPE;
p_cr_amount                          ar_cash_receipts.amount%TYPE;
p_cr_acctd_amount                    ar_cash_receipt_history.acctd_amount%TYPE;
p_cr_factor_discount_amount          ar_cash_receipts.factor_discount_amount%TYPE;
p_remmitance_ccid                    ar_receipt_method_accounts.remittance_ccid%TYPE;
p_bank_charges_ccid                  ar_receipt_method_accounts.bank_charges_ccid%TYPE;
p_code_combination_id                ar_distributions.code_combination_id%TYPE;
p_cash_receipt_history_id            ar_cash_receipt_history.cash_receipt_history_id%TYPE;
p_crh_gl_date                        ar_cash_receipt_history.gl_date%TYPE;
p_crh_trx_date                       ar_cash_receipt_history.trx_date%TYPE;
p_payment_server_order_num           ar_cash_receipts.payment_server_order_num%TYPE;
p_approval_code                      ar_cash_receipts.approval_code%TYPE;
p_receipt_number                     ar_cash_receipts.receipt_number%TYPE;
p_unique_ref                         ar_cash_receipts.unique_reference%TYPE;
p_customer_bank_account_id           ar_cash_receipts.customer_bank_account_id%TYPE;
p_payment_trxn_extension_id          ar_cash_receipts.payment_trxn_extension_id%TYPE;

/* end declare */

/* declare the insert array elements */
i                              NUMBER;
dummy                              NUMBER;
inst_stmt                      varchar2(2000);
cash_receipt_id_array                dbms_sql.Number_Table;
payment_type_CODE_array              dbms_sql.varchar2_Table;
merchant_ref_array                   dbms_sql.varchar2_Table;
currency_code_array                  dbms_sql.varchar2_Table;
pay_from_customer_array              dbms_sql.varchar2_Table;
customer_site_use_id_array           dbms_sql.Number_Table;
prv_cash_receipt_hist_id_array       dbms_sql.Number_Table;
exchange_date_array                  dbms_sql.date_Table;
exchange_rate_array                  dbms_sql.Number_Table;
exchange_type_array                  dbms_sql.varchar2_Table;
cr_amount_array                      dbms_sql.Number_Table;
cr_acctd_amount_array                dbms_sql.Number_Table;
cr_factor_discount_amt_array      dbms_sql.Number_Table;
remmitance_ccid_array                dbms_sql.Number_Table;
bank_charges_ccid_array              dbms_sql.Number_Table;
code_combination_id_array            dbms_sql.Number_Table;
cash_receipt_history_id_array        dbms_sql.Number_Table;
crh_gl_date_array                    dbms_sql.date_Table;
crh_trx_date_array                   dbms_sql.date_Table;
payment_server_order_num_array       dbms_sql.varchar2_Table;
approval_code_array                  dbms_sql.varchar2_Table;
receipt_number_array                 dbms_sql.varchar2_Table;
unique_ref_array                     dbms_sql.varchar2_Table;
customer_bank_account_id_array       dbms_sql.Number_Table;
payment_trxn_extn_id_array      dbms_sql.Number_Table;
rem_t                          NUMBER;
/* end declare */


-- update variables
   upd_stmt1                   varchar2(1000);
   rem_t1                      number;
   dum                      number;

-- insert CRH variables.
   ins_crh1               long;
   rem_t3                 number;
   d1                     number;

-- XLA uptake
   CURSOR c_rec is
     select hist.cash_receipt_id cr_id
     from ar_cash_receipt_history hist,
          AR_REMIT_GT rec
     where hist.STATUS = 'REMITTED'
     and   hist.cash_receipt_id = rec.cash_receipt_id;

l_xla_ev_rec             ARP_XLA_EVENTS.XLA_EVENTS_TYPE;

-- insert DIST  variables.
   ins_dist1               long;
   rem_t4                 number;
   d2                     number;

             l_factor_flag             varchar2(1);
             l_request_id              NUMBER;
             l_last_updated_by         NUMBER;
             l_created_by              NUMBER;
             l_last_update_login       NUMBER;
             l_program_application_id  NUMBER;
             l_program_id              NUMBER;
             l_org_id              NUMBER;




BEGIN

 IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'create and upd  start parallel()+');
     fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_id ' || p_batch_id);
 END IF;

   select decode(remit_method_code, 'FACTORING', 'Y', 'N')
   into l_factor_flag
   from ar_batches
   where batch_id = p_batch_id;

       l_request_id := arp_standard.profile.request_id;
       l_last_updated_by := arp_standard.profile.user_id ;
       l_created_by := arp_standard.profile.user_id ;
       l_last_update_login := arp_standard.profile.last_update_login ;
       l_program_application_id := arp_standard.application_id ;
       l_program_id := arp_standard.profile.program_id;
       l_org_id := arp_standard.sysparm.org_id;


    l_sel_stmt := ' SELECT cash_receipt_id,
               payment_channel_code,
               merchant_ref,
               currency_code,
               pay_from_customer,
               customer_site_use_id,
               cash_receipt_history_id,
               exchange_date,
               exchange_rate,
               exchange_rate_type,
               amount1,
               acctd_amount,
               nvl(factor_discount_amount,0),
               remittance_ccid,
               bank_charges_ccid,
               code_combination_id,
               ar_cash_receipt_history_s.nextval,
               crh_gl_date,
               crh_trx_date,
               payment_server_order_num,
               approval_code,
               receipt_number,
               unique_ref,
               customer_bank_account_id,
               payment_trxn_extension_id
          FROM ar_autorem_interim
          WHERE batch_id = :ab_batch_id
          AND current_worker = :h_worker_number
            ';

           sel_receipts := dbms_sql.open_cursor;

           dbms_sql.parse (sel_receipts,l_sel_stmt,dbms_sql.v7);

           dbms_sql.bind_variable (sel_receipts,':ab_batch_id',p_batch_id);
	   dbms_sql.bind_variable (sel_receipts,':h_worker_number', WORKER_NUMBER);


           dbms_sql.define_column (sel_receipts, 1,  p_cash_receipt_id);
           dbms_sql.define_column (sel_receipts, 2,  p_payment_type_code,30);
           dbms_sql.define_column (sel_receipts, 3,  p_merchant_ref,80);
           dbms_sql.define_column (sel_receipts, 4,  p_currency_code,15);
           dbms_sql.define_column (sel_receipts, 5,  p_pay_from_customer);
           dbms_sql.define_column (sel_receipts, 6,  p_customer_site_use_id);
           dbms_sql.define_column (sel_receipts, 7,  p_prv_cash_receipt_hist_id);
           dbms_sql.define_column (sel_receipts, 8,  p_exchange_date);
           dbms_sql.define_column (sel_receipts, 9,  p_exchange_rate);
           dbms_sql.define_column (sel_receipts, 10, p_exchange_type,30);
           dbms_sql.define_column (sel_receipts, 11, p_cr_amount);
           dbms_sql.define_column (sel_receipts, 12, p_cr_acctd_amount);
           dbms_sql.define_column (sel_receipts, 13, p_cr_factor_discount_amount);
           dbms_sql.define_column (sel_receipts, 14, p_remmitance_ccid );
           dbms_sql.define_column (sel_receipts, 15, p_bank_charges_ccid);
           dbms_sql.define_column (sel_receipts, 16, p_code_combination_id);
           dbms_sql.define_column (sel_receipts, 17, p_cash_receipt_history_id);
           dbms_sql.define_column (sel_receipts, 18, p_crh_gl_date);
           dbms_sql.define_column (sel_receipts, 19, p_crh_trx_date);
           dbms_sql.define_column (sel_receipts, 20, p_payment_server_order_num,80);
           dbms_sql.define_column (sel_receipts, 21, p_approval_code,80);
           dbms_sql.define_column (sel_receipts, 22, p_receipt_number,30);
           dbms_sql.define_column (sel_receipts, 23, p_unique_ref,32);
           dbms_sql.define_column (sel_receipts, 24, p_customer_bank_account_id);
           dbms_sql.define_column (sel_receipts, 25, p_payment_trxn_extension_id);

             IF PG_DEBUG in ('Y', 'C') THEN
             fnd_file.put_line(FND_FILE.LOG, 'the select statemnt' || l_sel_stmt);
             END IF;

            l_rows_processed := dbms_sql.execute( sel_receipts);

            i:= 0;

     WHILE dbms_sql.fetch_rows( sel_receipts) > 0 LOOP
           dbms_sql.column_value (sel_receipts, 1,  p_cash_receipt_id);
           dbms_sql.column_value (sel_receipts, 2,  p_payment_type_code);
           dbms_sql.column_value (sel_receipts, 3,  p_merchant_ref);
           dbms_sql.column_value (sel_receipts, 4,  p_currency_code);
           dbms_sql.column_value (sel_receipts, 5,  p_pay_from_customer);
           dbms_sql.column_value (sel_receipts, 6,  p_customer_site_use_id);
           dbms_sql.column_value (sel_receipts, 7,  p_prv_cash_receipt_hist_id);
           dbms_sql.column_value (sel_receipts, 8,  p_exchange_date);
           dbms_sql.column_value (sel_receipts, 9,  p_exchange_rate);
           dbms_sql.column_value (sel_receipts, 10, p_exchange_type);
           dbms_sql.column_value (sel_receipts, 11, p_cr_amount);
           dbms_sql.column_value (sel_receipts, 12, p_cr_acctd_amount);
           dbms_sql.column_value (sel_receipts, 13, p_cr_factor_discount_amount);
           dbms_sql.column_value (sel_receipts, 14, p_remmitance_ccid );
           dbms_sql.column_value (sel_receipts, 15, p_bank_charges_ccid);
           dbms_sql.column_value (sel_receipts, 16, p_code_combination_id);
           dbms_sql.column_value (sel_receipts, 17, p_cash_receipt_history_id);
           dbms_sql.column_value (sel_receipts, 18, p_crh_gl_date);
           dbms_sql.column_value (sel_receipts, 19, p_crh_trx_date);
           dbms_sql.column_value (sel_receipts, 20, p_payment_server_order_num);
           dbms_sql.column_value (sel_receipts, 21, p_approval_code);
           dbms_sql.column_value (sel_receipts, 22, p_receipt_number);
           dbms_sql.column_value (sel_receipts, 23, p_unique_ref);
           dbms_sql.column_value (sel_receipts, 24, p_customer_bank_account_id);
           dbms_sql.column_value (sel_receipts, 25, p_payment_trxn_extension_id);

        IF PG_DEBUG in ( 'Y','C') THEN
                fnd_file.put_line(FND_FILE.LOG,
                                'the value of ps_id ' || p_cash_receipt_id);
                fnd_file.put_line(FND_FILE.LOG,'the value of i ' || to_char(i));
        END IF;


        cash_receipt_id_array(i)     := p_cash_receipt_id ;
        payment_type_code_array(i)   := p_payment_type_code;
        merchant_ref_array(i)        := p_merchant_ref;
        currency_code_array(i)       := p_currency_code;
        pay_from_customer_array(i)   := p_pay_from_customer;
        customer_site_use_id_array(i)     := p_customer_site_use_id;
        prv_cash_receipt_hist_id_array(i)  := p_prv_cash_receipt_hist_id;
        exchange_date_array(i)             := p_exchange_date ;
        exchange_rate_array(i)             := p_exchange_rate;
        exchange_type_array(i)             :=p_exchange_type;
        cr_amount_array(i)                 :=p_cr_amount;
        cr_acctd_amount_array(i)           :=p_cr_acctd_amount;
        cr_factor_discount_amt_array(i)    :=p_cr_factor_discount_amount;
        remmitance_ccid_array(i)           :=p_remmitance_ccid;
        bank_charges_ccid_array(i)         :=p_bank_charges_ccid;
        code_combination_id_array(i)       :=p_code_combination_id;
        cash_receipt_history_id_array(i)   :=p_cash_receipt_history_id;
        crh_gl_date_array(i)               :=p_crh_gl_date;
        crh_trx_date_array(i)              :=p_crh_trx_date;
        payment_server_order_num_array(i)  :=p_payment_server_order_num;
        approval_code_array(i)             :=p_approval_code;
        receipt_number_array(i)            :=p_receipt_number;
        unique_ref_array(i)                :=p_unique_ref;
        customer_bank_account_id_array(i)  :=p_customer_bank_account_id;
        payment_trxn_extn_id_array(i) :=p_payment_trxn_extension_id;

            i := i + 1;

            IF PG_DEBUG in ('Y', 'C') THEN
                fnd_file.put_line(FND_FILE.LOG,'the value of i- lea ' || to_char(i));
             END IF;

    END LOOP;

     l_rows_fetched := dbms_sql.last_row_count ;

  IF PG_DEBUG in ('Y', 'C') THEN
  fnd_file.put_line(FND_FILE.LOG,'the no of rows fetched ' || l_rows_fetched);
  END IF;

  dbms_sql.close_cursor( sel_receipts);

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'selrem and create and upd 1()-');
  END IF;

  /* 8617474 - if this worker has no rows, do not proceed as it
     will result in an ORA-6569.  So we're just going to set
     p_return_status and RETURN */
  IF l_rows_fetched = 0
  THEN
     IF PG_DEBUG in ('Y','C')
     THEN
        fnd_file.put_line(FND_FILE.LOG,'No rows to process.  Ending worker');
     END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     RETURN;
  END IF;

-- Bulk Insert into AR_REMIT_GT

  BEGIN

     inst_stmt := 'insert into AR_REMIT_GT values
        ( :c1_array,:c2_array,:c3_array,:c4_array,:c5_array,
       :c6_array,:c7_array,:c8_array,:c9_array,:c10_array,:c11_array,:c12_array,
       :c13_array,:c14_array,:c15_array,:c16_array,:c17_array,:c18_array,
       :c19_array,:c20_array,:c21_array,:c22_array,:c23_array,:c24_array,:c25_array)';

     rem_t := dbms_sql.open_cursor;

  dbms_sql.parse (rem_t,inst_stmt,dbms_sql.v7);

       dbms_sql.bind_array (rem_t,':c1_array',cash_receipt_id_array);
       dbms_sql.bind_array (rem_t,':c2_array',payment_type_CODE_array);
       dbms_sql.bind_array (rem_t,':c3_array',merchant_ref_array);
       dbms_sql.bind_array (rem_t,':c4_array',currency_code_array);
       dbms_sql.bind_array (rem_t,':c5_array',pay_from_customer_array);
       dbms_sql.bind_array (rem_t,':c6_array',customer_site_use_id_array);
       dbms_sql.bind_array (rem_t,':c7_array',prv_cash_receipt_hist_id_array);
       dbms_sql.bind_array (rem_t,':c8_array',exchange_date_array);
       dbms_sql.bind_array (rem_t,':c9_array',exchange_rate_array);
       dbms_sql.bind_array (rem_t,':c10_array',exchange_type_array);
       dbms_sql.bind_array (rem_t,':c11_array',cr_amount_array);
       dbms_sql.bind_array (rem_t,':c12_array',cr_acctd_amount_array);
       dbms_sql.bind_array (rem_t,':c13_array',cr_factor_discount_amt_array);
       dbms_sql.bind_array (rem_t,':c14_array',remmitance_ccid_array);
       dbms_sql.bind_array (rem_t,':c15_array',bank_charges_ccid_array);
       dbms_sql.bind_array (rem_t,':c16_array',code_combination_id_array);
       dbms_sql.bind_array (rem_t,':c17_array',cash_receipt_history_id_array);
       dbms_sql.bind_array (rem_t,':c18_array',crh_gl_date_array);
       dbms_sql.bind_array (rem_t,':c19_array',crh_trx_date_array);
       dbms_sql.bind_array (rem_t,':c20_array',payment_server_order_num_array);
       dbms_sql.bind_array (rem_t,':c21_array',approval_code_array);
       dbms_sql.bind_array (rem_t,':c22_array',receipt_number_array);
       dbms_sql.bind_array (rem_t,':c23_array',unique_ref_array);
       dbms_sql.bind_array (rem_t,':c24_array',customer_bank_account_id_array);
       dbms_sql.bind_array (rem_t,':c25_array',payment_trxn_extn_id_array);


    dummy := dbms_sql.execute(rem_t);

    dbms_sql.close_cursor(rem_t);

  EXCEPTION WHEN OTHERS THEN
    if dbms_sql.is_open(rem_t) then
      dbms_sql.close_cursor(rem_t);
    end if;
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
    raise;

  END;

/* the update and inserts */

  BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'upd-crh1 ()+');

  END IF;


/* the first update into ar_cash_receipt_history */

  upd_stmt1 := ' UPDATE ar_cash_receipt_history
                SET reversal_cash_receipt_hist_id = :ucrh_id_array,
                reversal_gl_date = :ucrh_gl_date_array,
                reversal_created_from = ''ARZARM'',
                current_record_flag = NULL,
                        last_update_date              = sysdate,
                        last_updated_by               = :i_last_updated_by,
                        last_update_login             = :i_last_update_login,
                        request_id                    = :i_request_id,
                        program_application_id        = :i_program_application_id,
                        program_id                    = :i_program_id,
                        program_update_date           = sysdate
                  WHERE cash_receipt_id = :cr_id_array
                  AND current_record_flag = ''Y''
                  AND status = ''CONFIRMED''
		  ';


  rem_t1 := dbms_sql.open_cursor;

  dbms_sql.parse (rem_t1,upd_stmt1,dbms_sql.v7);

  dbms_sql.bind_array (rem_t1,':ucrh_id_array', cash_receipt_history_id_array);
  dbms_sql.bind_array (rem_t1,':ucrh_gl_date_array',crh_gl_date_array );
  dbms_sql.bind_array (rem_t1,':cr_id_array', cash_receipt_id_array);
/* who cols*/

  dbms_sql.bind_variable (rem_t1,':i_last_updated_by',l_last_updated_by);
  dbms_sql.bind_variable (rem_t1,':i_last_update_login',l_last_update_login);
  dbms_sql.bind_variable (rem_t1,':i_request_id',l_request_id);
  dbms_sql.bind_variable (rem_t1,':i_program_application_id',l_program_application_id);
  dbms_sql.bind_variable (rem_t1,':i_program_id',l_program_id);

    dummy := dbms_sql.execute(rem_t1);

    dbms_sql.close_cursor(rem_t1);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug (to_char(SQL%ROWCOUNT) || ' row(s) updated.');
     fnd_file.put_line(FND_FILE.LOG,'upd-crh1 ()-');
  END IF;

  EXCEPTION WHEN OTHERS THEN
    if dbms_sql.is_open(rem_t1) then
      dbms_sql.close_cursor(rem_t1);
    end if;
  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'failed to update() '|| to_char(SQLCODE));
  END IF;
    raise;


  END;

/* insert into crh  */

 BEGIN


 IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'insert-crh1 ()+');
             fnd_file.put_line(FND_FILE.LOG, 'the batch_id ' || p_batch_id);

  END IF;


/* the first update into ar_cash_receipt_history */

   ins_crh1 := 'INSERT into ar_cash_receipt_history
         (cash_receipt_history_id,
          cash_receipt_id,
          status,
          trx_date,
          amount,
          acctd_amount,
          first_posted_record_flag,
          postable_flag,
          factor_flag,
          gl_date,
          current_record_flag,
          batch_id,
          exchange_date,
          exchange_rate,
          exchange_rate_type,
          account_code_combination_id,
          reversal_gl_date,
          reversal_cash_receipt_hist_id,
          prv_stat_cash_receipt_hist_id,
          factor_discount_amount,
          acctd_factor_discount_amount,
          bank_charge_account_ccid,
          posting_control_id,
          created_from,
          reversal_posting_control_id,
          gl_posted_date,
          reversal_gl_posted_date,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          request_id,
          org_id,
          program_application_id,
          program_id,
          program_update_date
         )
    select
           r.CASH_RECEIPT_HISTORY_ID,
           r.CASH_RECEIPT_ID,
          ''REMITTED'',
           r.CRH_TRX_DATE,
           r.cr_amount - r.cr_factor_discount_amount,
           r.cr_acctd_amount - DECODE(r.exchange_type, null, r.cr_factor_discount_amount,
               ''User'', arp_util.functional_amount(
                            r.cr_factor_discount_amount,
                            '''||ARP_GLOBAL.functional_currency||''',
                            nvl(r.exchange_rate,1),
                            NULL, NULL),
               gl_currency_api.convert_amount(
                       r.currency_code,
                       '''||ARP_GLOBAL.functional_currency||''',
                       r.exchange_date,
                       r.exchange_type,
                       r.cr_factor_discount_amount)),
          ''N'',
          ''Y'',
           :factor_flag,
           r.crh_gl_date,
          ''Y'',
           :i_batch_id,
           r.exchange_date,
           r.exchange_rate,
           r.exchange_type,
           r.remmitance_ccid,
          NULL,
          NULL,
           r.prv_cash_receipt_hist_id,
           r.cr_factor_discount_amount,
           DECODE(r.exchange_type, null, r.cr_factor_discount_amount,
           ''User'', arp_util.functional_amount(
                            r.cr_factor_discount_amount,
                            '''||ARP_GLOBAL.functional_currency||''',
                            nvl(r.exchange_rate,1),
                            NULL, NULL),
               gl_currency_api.convert_amount(
                       r.currency_code,
                       '''||ARP_GLOBAL.functional_currency||''',
                       r.exchange_date,
                       r.exchange_type,
                       r.cr_factor_discount_amount)),
           r.bank_charges_ccid,
          ''-3'',
          ''ARZARM'',
          NULL,
          NULL,
          NULL,
          :i_created_by,
          sysdate,
          :i_last_updated_by,
          sysdate,
          :i_last_update_login,
          :i_request_id,
          :i_org_id,
          :i_program_application_id,
          :i_program_id,
          sysdate
          FROM AR_REMIT_GT r
          WHERE r.cash_receipt_history_id is not null';

  rem_t3 := dbms_sql.open_cursor;

  dbms_sql.parse (rem_t3,ins_crh1,dbms_sql.v7);

             IF PG_DEBUG in ('Y', 'C') THEN
             fnd_file.put_line(FND_FILE.LOG, 'the batch_id ' || p_batch_id);
             END IF;


  dbms_sql.bind_variable (rem_t3,':i_batch_id',p_batch_id);
  dbms_sql.bind_variable (rem_t3,':factor_flag',l_factor_flag);
/* who cols */
  dbms_sql.bind_variable (rem_t3,':i_created_by',l_created_by);
  dbms_sql.bind_variable (rem_t3,':i_last_updated_by',l_last_updated_by);
  dbms_sql.bind_variable (rem_t3,':i_last_update_login',l_last_update_login);
  dbms_sql.bind_variable (rem_t3,':i_request_id',l_request_id);
  dbms_sql.bind_variable (rem_t3,':i_org_id',l_org_id);
  dbms_sql.bind_variable (rem_t3,':i_program_application_id',l_program_application_id);
  dbms_sql.bind_variable (rem_t3,':i_program_id',l_program_id);


             IF PG_DEBUG in ('Y', 'C') THEN
             fnd_file.put_line(FND_FILE.LOG, 'the insert statemnt' || ins_crh1);
             END IF;

    dummy := dbms_sql.execute(rem_t3);

    dbms_sql.close_cursor(rem_t3);


/* BICHATTE after the insert into crh we have to fire the XLA event */

   FOR rec in c_rec LOOP

          l_xla_ev_rec.xla_from_doc_id := rec.cr_id;
          l_xla_ev_rec.xla_to_doc_id := rec.cr_id;
          l_xla_ev_rec.xla_doc_table := 'CRH';
          l_xla_ev_rec.xla_mode := 'O';
          l_xla_ev_rec.xla_call := 'B';

  		IF PG_DEBUG in ('Y', 'C') THEN
     			fnd_file.put_line(FND_FILE.LOG,'xla_from_doc_id= '|| to_char(rec.cr_id));
     			fnd_file.put_line(FND_FILE.LOG,'xla_to_doc_id= '|| to_char(rec.cr_id));
     			fnd_file.put_line(FND_FILE.LOG,'xla_doc_table= '|| 'CRH');
     			fnd_file.put_line(FND_FILE.LOG,'xla_from_doc_id= '|| 'O');
     			fnd_file.put_line(FND_FILE.LOG,'xla_from_doc_id= '|| 'B');
  		END IF;

          arp_xla_events.create_events(l_xla_ev_rec);


  		IF PG_DEBUG in ('Y', 'C') THEN
                   fnd_file.put_line(FND_FILE.LOG,'RETURN STATUS FROM XLA () '|| to_char(SQLCODE));
                END IF;


  END LOOP;




 EXCEPTION WHEN OTHERS THEN
             fnd_file.put_line(FND_FILE.LOG, 'the insert statemnt' || ins_crh1);
    if dbms_sql.is_open(rem_t3) then
      dbms_sql.close_cursor(rem_t3);
    end if;
  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'failed to insert() '|| to_char(SQLCODE));
             fnd_file.put_line(FND_FILE.LOG, 'the insert statemnt' || ins_crh1);
  END IF;
    raise;

 END;

/* end insert into crh */

/* insert into dist */
 BEGIN


 IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'insert-dist1 ()+');

  END IF;


/* the first update into ar_cash_receipt_history */

   ins_dist1 := 'INSERT into ar_distributions
		(line_id,
                source_id,
                source_table,
                source_type,
                code_combination_id,
                currency_code,
                third_party_id,
                third_party_sub_id,
                currency_conversion_date,
                currency_conversion_rate,
                currency_conversion_type,
                amount_dr,
                amount_cr,
                acctd_amount_dr,
                acctd_amount_cr,
		creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                org_id,
                last_update_login)
	select
                ar_distributions_s.nextval,
                r.cash_receipt_history_id,
                ''CRH'',
                decode(:factor_flag,
                       ''N'',decode(l.lookup_code,
				''1'',''REMITTANCE'',
				''2'',''CONFIRMATION''),
                       ''Y'',decode(l.lookup_code,
				''1'',''FACTOR'',
				''2'',''CONFIRMATION'')),
		decode(l.lookup_code,
			''1'',r.REMMITANCE_CCID,
			''2'',r.code_combination_id),  /* its confirmation_ccid */
                r.currency_code,
                r.pay_from_customer,
                r.customer_site_use_id,
                r.exchange_date,
                r.exchange_rate,
                r.exchange_type,
		decode(l.lookup_code,
			''1'',decode(sign(to_number(r.cr_amount)),
                                   ''-1'',null,
                                  to_number(r.cr_amount)),
			''2'',decode(sign(to_number(r.cr_amount)),
                                   ''1'',null,
                                  -(to_number(r.cr_amount)))),
		decode(l.lookup_code,
			''1'',decode(sign(to_number(r.cr_amount)),
                                   ''1'',null,
                                  -(to_number(r.cr_amount))),
			''2'',decode(sign(to_number(r.cr_amount)),
                                   ''-1'',null,
                                  to_number(r.cr_amount))),
		decode(l.lookup_code,
			''1'',decode(sign(to_number(r.cr_acctd_amount)),
                                   ''-1'',null,
                                  to_number(r.cr_acctd_amount)),
			''2'',decode(sign(to_number(r.cr_acctd_amount)),
                                   ''1'',null,
                                  -(to_number(r.cr_acctd_amount)))),
		decode(l.lookup_code,
			''1'',decode(sign(to_number(r.cr_acctd_amount)),
                                   ''1'',null,
                                  -(to_number(r.cr_acctd_amount))),
			''2'',decode(sign(to_number(r.cr_acctd_amount)),
                                   ''-1'',null,
                                  to_number(r.cr_acctd_amount))),
                sysdate,
                :i_created_by,
                sysdate,
                :i_last_updated_by,
                :i_org_id,
                :i_last_update_login
        FROM    ar_cash_receipt_history crh,AR_REMIT_GT r,
		    ar_lookups l
	WHERE	crh.cash_receipt_history_id = r.cash_receipt_history_id
	AND	l.lookup_type = ''AR_CARTESIAN_JOIN''
	AND	l.lookup_code IN (''1'',''2'')';

  rem_t4 := dbms_sql.open_cursor;

  dbms_sql.parse (rem_t4,ins_dist1,dbms_sql.v7);

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG, 'the insert dist statement is ' || ins_dist1);
  END IF;

  dbms_sql.bind_variable (rem_t4,':factor_flag',l_factor_flag);
/* who cols */
  dbms_sql.bind_variable (rem_t4,':i_created_by',l_created_by);
  dbms_sql.bind_variable (rem_t4,':i_last_updated_by',l_last_updated_by);
  dbms_sql.bind_variable (rem_t4,':i_org_id',l_org_id);
  dbms_sql.bind_variable (rem_t4,':i_last_update_login',l_last_update_login);


    d2 := dbms_sql.execute(rem_t4);

    dbms_sql.close_cursor(rem_t4);

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'ins_dist1 ()-');
  END IF;

 EXCEPTION WHEN OTHERS THEN
    if dbms_sql.is_open(rem_t4) then
      dbms_sql.close_cursor(rem_t4);
    end if;
  IF PG_DEBUG in ('Y', 'C') THEN
   fnd_file.put_line(FND_FILE.LOG, 'the insert dist statement is ' || ins_dist1);
     fnd_file.put_line(FND_FILE.LOG,'DIST failed to insert() '|| to_char(SQLCODE));
  END IF;
    raise;

 END;

/* end insert into dist */


EXCEPTION
 WHEN others THEN
  --IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'Exception : create_and_update_remit_rec_pa() ');
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
  --END IF;
  RAISE;

END create_and_update_remit_rec_pa ;


/*========================================================================+
 |  PROCEDURE select_and_update_rec                                       |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
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

PROCEDURE select_update_rec(
                                p_customer_number_l             IN hz_cust_accounts.account_number%TYPE,
                                p_customer_number_h             IN hz_cust_accounts.account_number%TYPE,
                                p_customer_name_l               IN hz_parties.party_name%type,
                                p_customer_name_h               IN hz_parties.party_name%type,
                                p_doc_num_l                     IN ar_cash_receipts.doc_sequence_value%type,
                                p_doc_num_h                     IN ar_cash_receipts.doc_sequence_value%type,
                                p_trx_date_l                    IN ar_payment_schedules.trx_date%TYPE,
                                p_trx_date_h                    IN ar_payment_schedules.trx_date%TYPE,
                                p_due_date_l                    IN ar_payment_schedules.due_date%TYPE,
                                p_due_date_h                    IN ar_payment_schedules.due_date%TYPE,
                                p_trx_num_l                     IN ar_payment_schedules.trx_number%TYPE,
                                p_trx_num_h                     IN ar_payment_schedules.trx_number%TYPE,
                                p_remittance_total_to           IN ar_cash_receipts.amount%TYPE,
                                p_remittance_total_from         IN ar_cash_receipts.amount%TYPE,
                                p_batch_id                      IN ar_batches.batch_id%TYPE,
                                p_receipt_method_id             IN ar_receipt_methods.receipt_method_id%TYPE,
                                p_currency_code                 IN ar_cash_receipts.currency_code%TYPE,
                                p_payment_type_code             IN ar_receipt_methods.payment_type_code%TYPE,
                                p_sob_id                        IN ar_cash_receipts.set_of_books_id%TYPE,
                                p_remit_method_code             IN ar_receipt_classes.remit_method_code%TYPE,
                                p_remit_bank_account_id         IN ar_cash_receipts.remittance_bank_account_id%TYPE,
                                p_return_status                 OUT NOCOPY  VARCHAR2
                                 ) IS

    remit_recs                INTEGER;
    l_sel_stmt                long;
    l_rows_processed          INTEGER;
    l_rows_fetched            INTEGER;
    p_cash_receipt_id         NUMBER(15);
    p_amount                  ar_cash_receipts.amount%TYPE;
    p_payment_method_id       ar_receipt_methods.receipt_method_id%TYPE;
    cash_receipt_id_array     dbms_sql.Number_Table;
    cr_id_array               dbms_sql.Number_Table;
    amt_array                 dbms_sql.Number_Table;
    ins_recs                  INTEGER;

    i                           number;
    dummy                       number;
    upd_stmt2                   varchar2(1000);
    rem_t2                      number;
    dum                         number;
    ins_stmt                    varchar2(1000);
    ignore                      INTEGER;

    l_request_id              NUMBER;
    l_last_updated_by         NUMBER;
    l_created_by              NUMBER;
    l_last_update_login       NUMBER;
    l_program_application_id  NUMBER;
    l_program_id              NUMBER;

BEGIN
    l_request_id := arp_standard.profile.request_id;
    l_last_updated_by := arp_standard.profile.user_id ;
    l_created_by := arp_standard.profile.user_id ;
    l_last_update_login := arp_standard.profile.last_update_login ;
    l_program_application_id := arp_standard.application_id ;
    l_program_id := arp_standard.profile.program_id;

    IF PG_DEBUG in ('Y', 'C') THEN
      fnd_file.put_line(FND_FILE.LOG,'sel and upd   receipts start ()+');
      fnd_file.put_line(FND_FILE.LOG,'the input parameters are ');
      fnd_file.put_line(FND_FILE.LOG,' the value of p_customer_number_l '||       p_customer_number_l);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_customer_number_h '||       p_customer_number_h );
      fnd_file.put_line(FND_FILE.LOG,' the value of p_trx_date_l'        ||       p_trx_date_l);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_trx_date_h'        ||       p_trx_date_h);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_due_date_l'        ||       p_due_date_l);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_due_date_h'        ||       p_due_date_h);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_trx_num_l'         ||       p_trx_num_l);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_trx_num_h'         ||       p_trx_num_h);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_remittance_total_to'  ||       p_remittance_total_to);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_remittance_total_from'||       p_remittance_total_from);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_batch_id '            ||       p_batch_id );
      fnd_file.put_line(FND_FILE.LOG,' the value of p_receipt_method_id '   ||       p_receipt_method_id );
      fnd_file.put_line(FND_FILE.LOG,' the value of p_currency_code'        ||       p_currency_code);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_payment_type_code'    ||       p_payment_type_code);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_sob_id '              ||       p_sob_id );
      fnd_file.put_line(FND_FILE.LOG,' the value of p_remit_method_code'    ||       p_remit_method_code);
      fnd_file.put_line(FND_FILE.LOG,' the value of p_remit_bank_account_id'||       p_remit_bank_account_id );
    END IF;

    IF PG_PARALLEL IN ('Y', 'C') THEN
        ins_stmt := 'insert /*+ append parallel(gtt) */ into ar_rem_cr_id_gtt gtt ';
    ELSE
        ins_stmt := 'insert /*+ append */ into ar_rem_cr_id_gtt gtt ';
    END IF;
    ins_stmt := ins_stmt ||' select /*+ index(crh AR_CASH_RECEIPT_HISTORY_N6) */
                                        CASH_RECEIPT_HISTORY_ID,
                                        cash_receipt_id
                            from    ar_cash_receipt_history crh
                            where   crh.status = ''CONFIRMED'' AND
                                        crh.current_record_flag = ''Y'' ';
   commit;
   execute immediate 'alter session enable parallel dml';
   --move all the receipts in confirmed status to GT table
   ins_recs := dbms_sql.open_cursor;
   dbms_sql.parse (ins_recs, ins_stmt, dbms_sql.v7);
   ignore := dbms_sql.execute(ins_recs);
  commit;

    IF PG_PARALLEL IN ('Y', 'C') THEN
      l_sel_stmt := ' SELECT /*+ unnest LEADING(crh,crh1,cr) parallel(crh) parallel(crh1) parallel(cr) parallel(ps) swap_join_inputs(rm) swap_join_inputs(rclass) use_hash(rm,rclass) use_nl(crh1,cr,ps,rma1,rma2) cardinality(crh,10000) */';
    ELSE
      l_sel_stmt := ' SELECT /*+ unnest LEADING(crh,crh1,cr) swap_join_inputs(rm) swap_join_inputs(rclass) use_hash(rm,rclass) use_nl(crh1,cr,ps,rma1,rma2) cardinality(crh,10000) */';
    END IF;
    l_sel_stmt := l_sel_stmt || ' cr.cash_receipt_id
          FROM ar_rem_cr_id_gtt crh,
               ar_cash_receipt_history crh1,
               ar_cash_receipts cr,
               ar_payment_schedules ps,
               ar_receipt_classes rclass,
               ar_receipt_methods rm,
               ar_receipt_method_accounts rma1,
               ar_receipt_method_accounts rma2
         WHERE crh1.status = ''CONFIRMED''
           AND crh1.current_record_flag = ''Y''
           AND crh1.cash_receipt_history_id = crh.cash_receipt_history_id
           AND crh.cash_receipt_id = cr.cash_receipt_id
           AND NOT EXISTS
           (SELECT 1 FROM ar_lookups l
            WHERE NVL(cr.reversal_category,''~'')    = l.lookup_code
            AND l.lookup_type           = ''REVERSAL_CATEGORY_TYPE'')
           AND cr.receipt_method_id = nvl(:bs_receipt_method_id,cr.receipt_method_id)
           AND cr.currency_code = :bs_currency
           AND cr.cash_receipt_id = ps.cash_receipt_id(+)
           AND cr.receipt_method_id = rm.receipt_method_id
	   AND (nvl(rm.payment_channel_code,''~'')<>''CREDIT_CARD'' OR (rm.payment_channel_code=''CREDIT_CARD'' AND cr.cc_error_flag IS NULL))
	   AND cr.selected_remittance_batch_id is null
           AND (( cr.amount >= 0) OR
                (cr.type = ''MISC'' and cr.amount < 0))
           AND cr.set_of_books_id = :bs_sob_id
           AND rm.receipt_class_id = rclass.receipt_class_id
           AND (rclass.remit_method_code = :bs_remit_method_code
               OR rclass.remit_method_code = ''STANDARD_AND_FACTORING''
               )
           AND rma1.receipt_method_id = cr.receipt_method_id
           AND rma1.REMIT_BANK_ACCT_USE_ID = cr.REMIT_BANK_ACCT_USE_ID
           AND rma2.receipt_method_id = rma1.receipt_method_id
           AND rma2.REMIT_BANK_ACCT_USE_ID= :bs_remit_account_id
           AND ((
                (nvl(cr.override_remit_account_flag,''Y'') = ''Y'')
                AND rma1.unapplied_ccid = rma2.unapplied_ccid
                AND rma1.on_account_ccid = rma2.on_account_ccid
                AND rma1.unidentified_ccid = rma2.unidentified_ccid
               )
               OR
               (
                (nvl(cr.override_remit_account_flag,''Y'') = ''N'')
                and cr.REMIT_BANK_ACCT_USE_ID = :bs_remit_account_id
               ))' ;

  IF p_receipt_method_id IS NOT NULL THEN
     l_sel_stmt := l_sel_stmt || '
                  AND decode(nvl(rm.payment_channel_code,''~''),''CREDIT_CARD'',''CREDIT_CARD'',''OTHER'')
                   = decode(nvl(:bs_payment_type_code,''~''),''CREDIT_CARD'',''CREDIT_CARD'',''OTHER'') ';
  END IF;

  IF p_customer_number_l IS NOT NULL OR p_customer_number_h IS NOT NULL THEN

     l_sel_stmt := l_sel_stmt || '
           AND EXISTS ( select ''x''
                        from    hz_cust_accounts rc
                        where   rc.cust_account_id = cr.pay_from_customer  ' ;

     IF p_customer_number_l IS NOT NULL THEN
        l_sel_stmt := l_sel_stmt || ' and rc.account_number >= :customer_number_l ';
     END IF ;
     IF p_customer_number_h IS NOT NULL THEN
        l_sel_stmt := l_sel_stmt || ' and rc.account_number <= :customer_number_h ';
     END IF;

     l_sel_stmt := l_sel_stmt || ' ) ';

  ELSE

  /* Bug 8473259  If we give customer name then customer  number cannot be provided in form
     similarly otherway around.*/

    IF p_customer_name_l IS NOT NULL OR p_customer_name_h IS NOT NULL THEN

      l_sel_stmt := l_sel_stmt || '
           AND EXISTS ( select ''x''
                        from    hz_cust_accounts rc, HZ_PARTIES party
                        where   rc.cust_account_id = cr.pay_from_customer
                        and     rc.party_id = party.party_id  ' ;

      IF p_customer_name_l IS NOT NULL THEN
        l_sel_stmt := l_sel_stmt || ' and party.party_name >= :customer_name_l ';
      END IF ;
      IF p_customer_name_h IS NOT NULL THEN
        l_sel_stmt := l_sel_stmt || ' and party.party_name <= :customer_name_h ';
      END IF;

      l_sel_stmt := l_sel_stmt || ' ) ';

    END IF ;

  END IF ;

  IF p_due_date_l IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' AND DECODE(cr.type,''CASH'',ps.due_date,''MISC'',cr.deposit_date,NULL) >= trunc(:due_date_l) ';
  END IF;

  IF p_due_date_h IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' AND DECODE(cr.type,''CASH'',ps.due_date,''MISC'',cr.deposit_date,NULL) <= trunc(:due_date_h) ';
  END IF;

  IF p_trx_date_l IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' AND cr.receipt_date >= trunc(:trx_date_l)';
  END IF;

  IF p_trx_date_h IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' AND cr.receipt_date <= trunc(:trx_date_h)';
  END IF;

  IF p_trx_num_l IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' AND cr.receipt_number >= :rcpt_number_l';
  END IF;


  IF p_trx_num_h IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' AND cr.receipt_number <= :rcpt_number_h';
  END IF;

/*Bug 8473259 check for document number*/
  IF p_doc_num_l IS NOT NULL OR p_doc_num_h IS NOT NULL THEN

     IF p_doc_num_l = p_doc_num_h THEN
        l_sel_stmt := l_sel_stmt || ' AND cr.doc_sequence_value = :doc_num_l';
     ELSE
         IF p_doc_num_l IS NOT NULL THEN
                l_sel_stmt := l_sel_stmt || ' AND cr.doc_sequence_value >= :doc_num_l ' ;
         END IF ;
         IF p_doc_num_h IS NOT NULL THEN
                l_sel_stmt := l_sel_stmt || ' AND cr.doc_sequence_value <= :doc_num_h ' ;
         END IF;
     END IF;

  END IF ;

  IF p_remittance_total_to IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' AND cr.amount >= to_number(:remittance_total_to)';
  END IF;


  IF p_remittance_total_from IS NOT NULL THEN
    l_sel_stmt := l_sel_stmt || ' AND cr.amount <= to_number(:remittance_total_from)';
  END IF;
  IF PG_PARALLEL IN ('Y', 'C') THEN
    upd_stmt2 := ' UPDATE /*+ parallel(R) index(R) */ ar_cash_receipts R';
  ELSE
    upd_stmt2 := ' UPDATE /*+ index(R) */ ar_cash_receipts R';
  END IF;
  upd_stmt2 := upd_stmt2 ||' SET selected_remittance_batch_id  = :u_batch_id,
			REMIT_BANK_ACCT_USE_ID        = :u_remit_bank_account_id,
			last_update_date              = sysdate,
			last_updated_by               = :i_last_updated_by,
			last_update_login             = :i_last_update_login,
			request_id                    = :i_request_id,
			program_application_id        = :i_program_application_id,
			program_id                    = :i_program_id,
			program_update_date           = sysdate
		WHERE selected_remittance_batch_id is null ';

  l_sel_stmt := upd_stmt2 ||' AND cash_receipt_id IN ( '|| l_sel_stmt || ')';

  remit_recs := dbms_sql.open_cursor;

  dbms_sql.parse (remit_recs,l_sel_stmt,dbms_sql.v7);

  /* bind the variables used in update statement */
  dbms_sql.bind_variable (remit_recs,':u_batch_id',p_batch_id);
  dbms_sql.bind_variable (remit_recs,':u_remit_bank_account_id',p_remit_bank_account_id);

  /* who cols */
  dbms_sql.bind_variable (remit_recs,':i_last_updated_by',l_last_updated_by);
  dbms_sql.bind_variable (remit_recs,':i_last_update_login',l_last_update_login);
  dbms_sql.bind_variable (remit_recs,':i_request_id',l_request_id);
  dbms_sql.bind_variable (remit_recs,':i_program_application_id',l_program_application_id);
  dbms_sql.bind_variable (remit_recs,':i_program_id',l_program_id);

  /* bind the variables */
  dbms_sql.bind_variable (remit_recs,':bs_receipt_method_id',p_receipt_method_id);
  dbms_sql.bind_variable (remit_recs,':bs_currency',p_currency_code);

  IF p_receipt_method_id IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':bs_payment_type_code', p_payment_type_code);
  END IF;

  dbms_sql.bind_variable (remit_recs,':bs_sob_id', p_sob_id);
  dbms_sql.bind_variable (remit_recs,':bs_remit_method_code',p_remit_method_code);
  dbms_sql.bind_variable (remit_recs,':bs_remit_account_id', p_remit_bank_account_id);

  IF p_customer_number_l IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':customer_number_l',p_customer_number_l);
  END IF;

  IF p_customer_number_h IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':customer_number_h',p_customer_number_h);
  END IF;

  /*Bug 8473259 binding variables for name */
  IF p_customer_name_l IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':customer_name_l',p_customer_name_l);
  END IF;

  IF p_customer_name_h IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':customer_name_h',p_customer_name_h);
  END IF;

  IF p_due_date_l IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':due_date_l',p_due_date_l);
  END IF;

  IF p_due_date_h IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':due_date_h',p_due_date_h);
  END IF;

  IF p_trx_date_l IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':trx_date_l',p_trx_date_l);
  END IF;

  IF p_trx_date_h IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':trx_date_h',p_trx_date_h);
  END IF;

  IF p_trx_num_l IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':rcpt_number_l',p_trx_num_l);
  END IF;

  IF p_trx_num_h IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':rcpt_number_h',p_trx_num_h);
  END IF;

  /*bug 8473259 binding variable for document number*/
  IF p_doc_num_l IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':doc_num_l',p_doc_num_l);
  END IF;

  IF p_doc_num_h IS NOT NULL AND nvl(p_doc_num_l,-1) <> p_doc_num_h THEN
    dbms_sql.bind_variable (remit_recs,':doc_num_h',p_doc_num_h);
  END IF;

  IF p_remittance_total_to  IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':remittance_total_to',p_remittance_total_to );
  END IF;

  IF p_remittance_total_from IS NOT NULL THEN
    dbms_sql.bind_variable (remit_recs,':remittance_total_from',p_remittance_total_from );
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG, 'the select statemnt' || l_sel_stmt);
  END IF;

  commit;
  execute immediate 'alter session enable parallel dml';
  l_rows_processed := dbms_sql.execute( remit_recs );
  commit;

  l_rows_fetched := dbms_sql.last_row_count ;

  IF PG_DEBUG in ('Y', 'C') THEN
    fnd_file.put_line(FND_FILE.LOG,'the no of rows fetched ' || l_rows_fetched);
  END IF;

  dbms_sql.close_cursor( remit_recs );

  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'sel_and_update recs ()-');
  END IF;

EXCEPTION
 WHEN others THEN
     fnd_file.put_line(FND_FILE.LOG,'Exception : select and upd  err () ');
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
     fnd_file.put_line(FND_FILE.LOG, 'the select statemnt' || l_sel_stmt);
     raise;
END select_update_rec;

/*========================================================================+
 |  PROCEDURE process_pay_receipt                                        |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
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

PROCEDURE process_pay_receipt(
                p_batch_id            IN  NUMBER,
                p_called_from         IN  VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2
                ) IS

  CURSOR rct_info_cur IS
     SELECT cr.receipt_number,
            cr.amount,
            cr.cash_receipt_id,
            cr.currency_code,
            rm.PAYMENT_CHANNEL_CODE,       /* NEW ADDED */
            rc.creation_status,            /* AR USE */
            cr.org_id,
            party.party_id,
            cr.pay_from_customer,
            cr.customer_site_use_id,
            cr.payment_trxn_extension_id,
            cr.selected_remittance_batch_id,
            cr.receipt_date
     FROM   ar_cash_receipts cr,
            ar_receipt_methods rm,
            ar_receipt_classes rc,
            hz_cust_accounts hca,
            hz_parties    party,
            ar_remit_gt g
     WHERE  cr.selected_remittance_batch_id = p_batch_id
     AND    g.cash_receipt_id = cr.cash_receipt_id
     AND    hca.party_id = party.party_id
     AND    hca.cust_account_id = cr.pay_from_customer
     AND    cr.receipt_method_id = rm.receipt_method_id
     AND    rm.receipt_class_id = rc.receipt_class_id;

     --       rct_info    rct_info_cur%ROWTYPE;
            l_cr_rec    ar_cash_receipts_all%ROWTYPE;
            l_org_type  HR_ALL_ORGANIZATION_UNITS.TYPE%TYPE;
            l_action VARCHAR2(80);
            l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
            l_msg_count NUMBER;
            l_msg_data  VARCHAR2(2000);
            pl_msg_data  VARCHAR2(240);
           l_payment_trxn_extension_id  NUMBER;
           l_amount   NUMBER;
           l_calling_app_req_code   NUMBER;
           l_iby_msg_data  VARCHAR2(2000);
           l_amount_rec    IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
           l_payer_rec             IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
           l_response_rec          IBY_FNDCPT_COMMON_PUB.Result_rec_type;   /* OUT RESPONSE STRUCTURE */


/* DECLARE the variables required for the payment engine (AUTH) all the REC TYPES */

            l_payee_rec             IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
            l_auth_attribs_rec      IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
            l_trxn_attribs_rec      IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
            l_authresult_rec       IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type; /* OUT AUTH RESULT STRUCTURE */
            l_auth_flag         VARCHAR2(1);
            l_auth_id           NUMBER;
            l_vend_msg_data VARCHAR2(2000);

/* END DECLARE the variables required for the payment engine (AUTH) all the REC TYPES */


/* declare variables for settlement */

                       ls_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
                       ls_msg_count NUMBER;
                       ls_msg_data  VARCHAR2(2000);
                       ls_response_rec_tab       IBY_FNDCPT_TRXN_PUB.SettlementResult_tbl_type;
                       ls_iby_msg_data  VARCHAR2(2000);
                       l_cr_id               ar_cash_receipts.cash_receipt_id%type;
                       l_paying_customer_id  ar_cash_receipts.pay_from_customer%type;
                       l_cust_site_id        ar_cash_receipts.customer_site_use_id%type;
                       l_count1    NUMBER;

/* end declare varaibles for settlement */




                       lc_payer_rec             IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
                       lc_amount_rec            IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
                       lc_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
                       lc_msg_count NUMBER;
                       lc_msg_data  VARCHAR2(2000);
                       lc_iby_msg_data  VARCHAR2(2000);
                       lc_response_rec       IBY_FNDCPT_COMMON_PUB.Result_rec_type;



             l_request_id   NUMBER;
             l_last_updated_by         NUMBER;
             l_created_by              NUMBER;
             l_last_update_login       NUMBER;
             l_program_application_id  NUMBER;
             l_program_id              NUMBER;
             l_call_settlement VARCHAR2(1) := 'N';

             /* 7666285 - for passing settlement_date on returns */
             lcr_receipt_attr      IBY_FNDCPT_TRXN_PUB.receiptattribs_rec_type;

BEGIN


  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,  'Entering payment processing...');
  END IF;


              l_request_id := arp_standard.profile.request_id;
       l_last_updated_by := arp_standard.profile.user_id ;
       l_created_by := arp_standard.profile.user_id ;
       l_last_update_login := arp_standard.profile.last_update_login ;
       l_program_application_id := arp_standard.application_id ;
       l_program_id := arp_standard.profile.program_id;




      FOR  rct_info  in rct_info_cur  LOOP

             l_payment_trxn_extension_id := rct_info.payment_trxn_extension_id;
             l_amount := rct_info.amount;

/*  CHECK for AUTH here and do it if necessary  start */


         IF ((l_payment_trxn_extension_id is not null ) AND (l_amount >0) )  THEN


                 l_call_settlement := 'Y'; /* set the flag for calling settlement */


                  IF PG_DEBUG in ('Y', 'C') THEN
                     fnd_file.put_line(FND_FILE.LOG,  'check and then call Auth');
                  END IF;

        -- Step 1: (always performed):

          -- set up payee record:

          l_payee_rec.org_id   := rct_info.org_id;                            -- receipt's org_id
          l_payee_rec.org_type := 'OPERATING_UNIT' ;                                -- ( HR_ORGANIZATION_UNITS )


        -- set up payer (=customer) record:

        l_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
        l_payer_rec.Party_Id :=   rct_info.party_id;     -- receipt customer party id mandatory
        l_payer_rec.org_id   := rct_info.org_id ;
        l_payer_rec.org_type := 'OPERATING_UNIT';
        l_payer_rec.Cust_Account_Id :=rct_info.pay_from_customer;  -- receipt customer account_id
        l_payer_rec.Account_Site_Id :=rct_info.customer_site_use_id; -- receipt customer site_id


        if rct_info.customer_site_use_id is NULL  THEN

          l_payer_rec.org_id := NULL;
          l_payer_rec.org_type := NULL;

        end if;

        -- set up auth_attribs record:
        l_auth_attribs_rec.RiskEval_Enable_Flag := 'N';
        -- set up trxn_attribs record:
        l_trxn_attribs_rec.Originating_Application_Id := arp_standard.application_id;
        l_trxn_attribs_rec.order_id :=  rct_info.receipt_number;
        l_trxn_attribs_rec.Trxn_Ref_Number1 := 'RECEIPT';
        l_trxn_attribs_rec.Trxn_Ref_Number2 := rct_info.cash_receipt_id;

        -- set up amounts


        l_amount_rec.value := rct_info.amount;
        l_amount_rec.currency_code   := rct_info.currency_code;





        -- determine whether to AUTHORIZE

        IF PG_DEBUG in ('Y', 'C') THEN
           fnd_file.put_line(FND_FILE.LOG,  'Calling get auth for  pmt_trxn_extn_id ');
           fnd_file.put_line(FND_FILE.LOG,  'l_trxn_entity_id  ' || to_char(l_payment_trxn_extension_id) );
       END IF;

              BEGIN

	      IBY_AR_UTILS.get_authorization_status(l_payment_trxn_extension_id,l_auth_flag);

	       EXCEPTION
	         WHEN OTHERS THEN
		    fnd_file.put_line(FND_FILE.LOG,'Exception in IBY_AR_UTILS.get_authorization_status');
		        l_auth_flag := 'N';
               END;

               fnd_file.put_line(FND_FILE.LOG,'the value of auth_flag is = ' || l_auth_flag);

           IF  nvl(l_auth_flag,'N') <> 'Y' then
                 fnd_file.put_line(FND_FILE.LOG,'auth needs to called');

               IF PG_DEBUG in ('Y', 'C') THEN
                  fnd_file.put_line(FND_FILE.LOG,  'Calling get auth for  pmt_trxn_extn_id ');
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payee_rec.org_id '           || to_char( l_payee_rec.org_id) );
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payee_rec.org_type '         || to_char( l_payee_rec.org_type) );
                  fnd_file.put_line(FND_FILE.LOG, 'l_payer_rec.Payment_Function '|| to_char( l_payer_rec.Payment_Function));
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.Party_Id '         || to_char( l_payer_rec.Party_Id) );
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.org_id '           || to_char( l_payer_rec.org_id) );
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.org_type  '        || to_char( l_payer_rec.org_type) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_payer_rec.Cust_Account_Id ' || to_char(l_payer_rec.Cust_Account_Id) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_payer_rec.Account_Site_Id ' || to_char(l_payer_rec.Account_Site_Id) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_trxn_entity_id  '           || to_char(l_payment_trxn_extension_id) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_amount_rec.value: ' || to_char(l_amount_rec.value) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_amount_rec.currency_code: '   || l_amount_rec.currency_code );

                  fnd_file.put_line(FND_FILE.LOG,  'Calling get_auth for  pmt_trxn_extn_id ');
               END IF;

              BEGIN

		 fnd_file.put_line(FND_FILE.LOG, 'Before Call Create_Authorization()+');

                 IBY_FNDCPT_TRXN_PUB.Create_Authorization(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data,
                         p_payer              => l_payer_rec,
                         p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                         p_payee              => l_payee_rec,
                         p_trxn_entity_id     => l_payment_trxn_extension_id,
                         p_auth_attribs       => l_auth_attribs_rec,
                         p_amount             => l_amount_rec,
                         x_auth_result        => l_authresult_rec,   -- out auth result struct
                         x_response           => l_response_rec );   -- out response struct

		 fnd_file.put_line(FND_FILE.LOG, 'After Call Create_Authorization()-');

                  x_msg_count           := l_msg_count;
                  x_msg_data            := substr(l_msg_data,1,240);

                        fnd_file.put_line(FND_FILE.LOG,'x_return_status  :<' || l_return_status || '>');
                        fnd_file.put_line(FND_FILE.LOG,'x_msg_count      :<' || l_msg_count || '>');

                  FOR i IN 1..l_msg_count LOOP

                      fnd_file.put_line(FND_FILE.LOG,'x_msg #' || TO_CHAR(i) || ' = <' ||
                      SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,150) || '>');

		      IF i <= 2 THEN
		      	pl_msg_data := SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,240) ;
		      END if;

                  END LOOP;

                     IF PG_DEBUG in ('Y', 'C') THEN
                        fnd_file.put_line(FND_FILE.LOG, '-------------------------------------');
                        fnd_file.put_line(FND_FILE.LOG, 'l_response_rec.Result_Code:     ' || l_response_rec.Result_Code);
                        fnd_file.put_line(FND_FILE.LOG, 'l_response_rec.Result_Category: '|| l_response_rec.Result_Category);
                        fnd_file.put_line(FND_FILE.LOG,  'l_response_rec.Result_message :'|| l_response_rec.Result_message );
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.Auth_Id:     ' || l_authresult_rec.Auth_Id);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.Auth_Date: '   || l_authresult_rec.Auth_Date);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.Auth_Code:     '  || l_authresult_rec.Auth_Code);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.AVS_Code: '       || l_authresult_rec.AVS_Code);
                        fnd_file.put_line(FND_FILE.LOG,'l_authresult_rec.Instr_SecCode_Check:'||l_authresult_rec.Instr_SecCode_Check);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.PaymentSys_Code: '   || l_authresult_rec.PaymentSys_Code);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.PaymentSys_Msg: '    || l_authresult_rec.PaymentSys_Msg);

                    END IF;

             IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

              fnd_file.put_line(FND_FILE.LOG,'the value of auth_id is = ' || (l_authresult_rec.Auth_Id));

             END IF;


             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                            G_ERROR := 'Y' ;

                  FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
                  FND_MSG_PUB.Add;

                     IF  l_response_rec.Result_Code is NOT NULL THEN

                       ---Raise the PAYMENT error code concatenated with the message

                        l_iby_msg_data := substrb( l_response_rec.Result_Code || ': '||
                                   l_response_rec.Result_Message , 1, 240);

                        fnd_file.put_line(FND_FILE.LOG,  'l_iby_msg_data: ' || l_iby_msg_data);

                       UPDATE ar_cash_receipts
        		SET cc_error_flag = 'Y',
                 	cc_error_code = l_response_rec.Result_Code,
                 	cc_error_text = pl_msg_data,
                 	last_updated_by = l_last_updated_by,
           		last_update_date = sysdate,
           		last_update_login = l_last_update_login,
         		request_id = l_request_id,
                 	program_application_id= l_program_application_id,
                	program_id = l_program_id,
             		program_update_date = sysdate
           	       WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                                fnd_file.put_line(FND_FILE.LOG,'UPDATE CR with cc_err_flag ' || SQL%ROWCOUNT );



                     END IF;

                     IF l_authresult_rec.PaymentSys_Code is not null THEN

                       ---Raise the VENDOR error code concatenated with the message

                        l_vend_msg_data := substrb(l_authresult_rec.PaymentSys_Code || ': '||
                                   l_authresult_rec.PaymentSys_Msg , 1, 240 );

                        FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_vend_msg_data);

                       UPDATE ar_cash_receipts
        	        SET cc_error_flag = 'Y',
                        cc_error_code = l_authresult_rec.PaymentSys_Code,
                        cc_error_text = substr(l_authresult_rec.PaymentSys_Msg,1,240),
                        last_updated_by = l_last_updated_by,
           	        last_update_date = sysdate,
           	        last_update_login = l_last_update_login,
         	        request_id = l_request_id,
                        program_application_id= l_program_application_id,
                        program_id = l_program_id,
             	        program_update_date = sysdate
           	       WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                      fnd_file.put_line(FND_FILE.LOG,'UPDATE CR with cc_err_flag ' || SQL%ROWCOUNT );

                    END IF;

                        insert_exceptions(
                           p_batch_id   =>p_batch_id,
                           p_request_id =>l_request_id,
                           p_paying_customer_id =>l_payer_rec.cust_account_id,
                           p_cash_receipt_id => rct_info.cash_receipt_id,
                           p_exception_code  => 'AR_CC_AUTH_FAILED',
                           p_additional_message => substrb(l_iby_msg_data||l_vend_msg_data,1,240)
                             );

                    x_return_status := l_return_status;

             END IF; /* End the error handling CREATE */
	        EXCEPTION
	           WHEN OTHERS THEN
		           G_ERROR := 'Y' ;

               fnd_file.put_line(FND_FILE.LOG,'Exception : Create_Authorization () ');
               fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));

                     insert_exceptions(
                           p_batch_id   =>p_batch_id,
                           p_request_id =>l_request_id,
                           p_paying_customer_id =>l_payer_rec.cust_account_id,
                           p_cash_receipt_id => rct_info.cash_receipt_id,
                           p_exception_code  => 'AR_CC_AUTH_FAILED',
                           p_additional_message => l_iby_msg_data
                             );

                     UPDATE ar_cash_receipts
        	      SET cc_error_flag = 'Y',
                      last_updated_by = l_last_updated_by,
           	      last_update_date = sysdate,
           	      last_update_login = l_last_update_login,
         	      request_id = l_request_id,
                      program_application_id= l_program_application_id,
                      program_id = l_program_id,
             	      program_update_date = sysdate
           	     WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                     fnd_file.put_line(FND_FILE.LOG,'UPDATE CR with cc_err_flag ' || SQL%ROWCOUNT );
           END;  /* END of BEGIN */


          END IF;  /* END if of auth flag <>'Y'  */

         END IF ; /* end if of pmt_etx is not null and amt >0 */
/*  CHECK for AUTH here and do it if necessary  end  */

           IF ((l_payment_trxn_extension_id is not null ) AND (l_amount <0) )  THEN

             /* HERE WE HAVE TO CALL RETURN */

                   -- set up payer (=customer) record:

                     lc_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
                     lc_payer_rec.Party_Id :=   rct_info.party_id;     -- receipt customer party id mandatory
                     lc_payer_rec.org_id   := rct_info.org_id ;
                     lc_payer_rec.org_type := 'OPERATING_UNIT';
                     lc_payer_rec.Cust_Account_Id :=rct_info.pay_from_customer;  -- receipt customer account_id
                     lc_payer_rec.Account_Site_Id :=rct_info.customer_site_use_id; -- receipt customer site_id

                            -- set up amounts

                       lc_amount_rec.value := ABS(rct_info.amount);
                       lc_amount_rec.currency_code   := rct_info.currency_code;

                     /* 7666285 - settlement_date */
                     lcr_receipt_attr.settlement_date := rct_info.receipt_date;


                      if rct_info.customer_site_use_id is NULL  THEN

                       lc_payer_rec.org_id := NULL;
                       lc_payer_rec.org_type := NULL;

                      end if;

                      IF PG_DEBUG in ('Y', 'C') THEN
                       fnd_file.put_line(FND_FILE.LOG,  'Calling return for  pmt_trxn_extn_id ');
                       fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.Payment_Function ' || to_char( lc_payer_rec.Payment_Function) );
                       fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.Party_Id '         || to_char( lc_payer_rec.Party_Id) );
                       fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.org_id '           || to_char(lc_payer_rec.org_id) );
                       fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.org_type  '        || to_char( lc_payer_rec.org_type) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_payer_rec.Cust_Account_Id '   || to_char(lc_payer_rec.Cust_Account_Id) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_payer_rec.Account_Site_Id '   || to_char(lc_payer_rec.Account_Site_Id) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_trxn_entity_id  '             || to_char(l_payment_trxn_extension_id ) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_amount_rec.value: '           || to_char(lc_amount_rec.value) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_amount_rec.currency_code: '   || lc_amount_rec.currency_code );
                       fnd_file.put_line(FND_FILE.LOG,  'settlement_date: ' || lcr_receipt_attr.settlement_date);
                     END IF;


                   BEGIN
                     IBY_FNDCPT_TRXN_PUB.Create_Return(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         x_return_status      => lc_return_status,
                         x_msg_count          => lc_msg_count,
                         x_msg_data           => lc_msg_data,
                         p_payer              => lc_payer_rec,
                         p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                         p_trxn_entity_id     => l_payment_trxn_extension_id,
                         p_amount             => lc_amount_rec,
                         p_receipt_attribs    => lcr_receipt_attr,
                         x_response           => lc_response_rec );   -- out response struct

                                  x_msg_count           := lc_msg_count;
                                  x_msg_data            := lc_msg_data;

                        fnd_file.put_line(FND_FILE.LOG,'x_return_status  :<' || lc_return_status || '>');
                        fnd_file.put_line(FND_FILE.LOG,'x_msg_count      :<' || lc_msg_count || '>');

                  FOR i IN 1..lc_msg_count LOOP
                      fnd_file.put_line(FND_FILE.LOG,'x_msg #' || TO_CHAR(i) || ' = <' ||
                      SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,150) || '>');

		      IF i <= 2 THEN
		      	pl_msg_data := SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,240) ;
		      END if;

                  END LOOP;

                     IF PG_DEBUG in ('Y', 'C') THEN
                        fnd_file.put_line(FND_FILE.LOG,  '-------------------------------------');
                        fnd_file.put_line(FND_FILE.LOG,  'l_response_rec.Result_Code:     ' || lc_response_rec.Result_Code);
                        fnd_file.put_line(FND_FILE.LOG,  'l_response_rec.Result_Category: ' || lc_response_rec.Result_Category);
                        fnd_file.put_line(FND_FILE.LOG,  'l_response_rec.Result_message : ' || lc_response_rec.Result_message );
                     END IF;

                 IF (lc_return_status <> FND_API.G_RET_STS_SUCCESS) THEN


                            G_ERROR := 'Y' ;

                     fnd_file.put_line(FND_FILE.LOG,'create_cash_126');
                     FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
                      FND_MSG_PUB.Add;

                     IF  lc_response_rec.Result_Code is NOT NULL THEN

                       ---Raise the PAYMENT error code concatenated with the message

                        lc_iby_msg_data := substrb( lc_response_rec.Result_Code || ': '|| lc_response_rec.Result_Message , 1, 240);

                        fnd_file.put_line(FND_FILE.LOG,  'lc_iby_msg_data: ' || lc_iby_msg_data);
                        FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',lc_iby_msg_data);

                        FND_MSG_PUB.Add;

                     END IF;

                      insert_exceptions(
                           p_batch_id   =>p_batch_id,
                           p_request_id =>l_request_id,
                           p_paying_customer_id =>l_payer_rec.cust_account_id,
                           p_cash_receipt_id => rct_info.cash_receipt_id,
                           p_exception_code  => 'AR_CC_AUTH_FAILED',
                           p_additional_message => lc_iby_msg_data
                             );

                      UPDATE ar_cash_receipts
          	       SET cc_error_flag = 'Y',
                       cc_error_code = lc_response_rec.Result_Code,
                       cc_error_text = pl_msg_data,
                       last_updated_by = l_last_updated_by,
             	       last_update_date = sysdate,
            	       last_update_login = l_last_update_login,
          	       request_id = l_request_id,
                       program_application_id= l_program_application_id,
                       program_id = l_program_id,
              	       program_update_date = sysdate
           	      WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                    FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count  =>  x_msg_count,
                               p_data   => x_msg_data );

                    x_return_status := lc_return_status;

                END IF;
	        EXCEPTION
	           WHEN OTHERS THEN
		           G_ERROR := 'Y' ;

                   fnd_file.put_line(FND_FILE.LOG,'Exception : Create_Return () ');
                   fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));

                     insert_exceptions(
                           p_batch_id   =>p_batch_id,
                           p_request_id =>l_request_id,
                           p_paying_customer_id =>l_payer_rec.cust_account_id,
                           p_cash_receipt_id => rct_info.cash_receipt_id,
                           p_exception_code  => 'AR_CC_AUTH_FAILED',
                           p_additional_message => l_iby_msg_data
                             );

                     UPDATE ar_cash_receipts
        	      SET cc_error_flag = 'Y',
                      last_updated_by = l_last_updated_by,
           	      last_update_date = sysdate,
           	      last_update_login = l_last_update_login,
         	      request_id = l_request_id,
                      program_application_id= l_program_application_id,
                      program_id = l_program_id,
             	      program_update_date = sysdate
           	     WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                     fnd_file.put_line(FND_FILE.LOG,'UPDATE CR with cc_err_flag ' || SQL%ROWCOUNT );
           END;  /* END of BEGIN */
        END IF;


    END LOOP ; /* for the rct_cur */



/* HERE WE WILL CALL THE BULK SETTLEMENT PROCESS START */

    IF l_call_settlement = 'Y'  THEN

           IF PG_DEBUG in ( 'Y','C') THEN

                  fnd_file.put_line(FND_FILE.LOG,  'Calling bulk settlement');


                    select count(*)
                    into l_count1
                    from AR_FUNDS_CAPTURE_ORDERS_V
                    where CALL_APP_SERVICE_REQ_CODE = 'AR_'||p_batch_id;

                  fnd_file.put_line(FND_FILE.LOG,  ' No of records in AR_FUNDS_CAPTURE_ORDERS_V  ' || l_count1 );
                  fnd_file.put_line(FND_FILE.LOG,  'p_calling_app_id  '         || to_char(l_program_application_id) );
                  fnd_file.put_line(FND_FILE.LOG,  ' p_calling_app_request_code  '           ||  'AR_'||p_batch_id);
                  fnd_file.put_line(FND_FILE.LOG,  'p_order_view_name  '         || 'AR_FUNDS_CAPTURE_ORDERS_V' );
            END IF;

                 IBY_FNDCPT_TRXN_PUB.Create_Settlements(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         p_calling_app_id     => l_program_application_id,
                         p_calling_app_request_code => 'AR_'||p_batch_id||'_'||WORKER_NUMBER,
                         p_order_view_name  => 'AR_FUNDS_CAPTURE_ORDERS_V',
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

          IF PG_DEBUG in ('Y', 'C') THEN

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
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_code :    '       || ls_response_rec_tab(i).Result.Result_code);
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_Category :  ' || ls_response_rec_tab(i).Result.Result_Category);
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_Message :    '  || ls_response_rec_tab(i).Result.Result_Message);

               END LOOP;

             END IF;



                 FOR  i IN ls_response_rec_tab.FIRST..ls_response_rec_tab.LAST   LOOP


                        IF ls_response_rec_tab(i).Result.Result_code in ( 'SETTLEMENT_SUCCESS','SETTLEMENT_PENDING') THEN

                           fnd_file.put_line(FND_FILE.LOG,'SETTLEMENT SUCCESS FOR Trxn_Extension_Id =   '
                                 || (ls_response_rec_tab(i).Trxn_Extension_Id ));


                        ELSE

                                 G_ERROR := 'Y';

                                   ls_iby_msg_data := null;    /* initialize here */

                                   FND_MESSAGE.set_name('AR', 'AR_CC_CAPTURE_FAILED');
                                   FND_MSG_PUB.Add;
                                         ---Raise the PAYMENT error code concatenated with the message

                                          ls_iby_msg_data := substrb( ls_response_rec_tab(i).Result.Result_Code || ': '||
                                                        ls_response_rec_tab(i).Result.Result_Message , 1, 240);

                                           fnd_file.put_line(FND_FILE.LOG,  'ls_iby_msg_data: ' || ls_iby_msg_data);

                                   Begin
                                      select /*+ INDEX(ar_cash_receipts ar_cash_receipts_n15) */
                                             cash_receipt_id,pay_from_customer,customer_site_use_id
                                      into   l_cr_id,l_paying_customer_id,l_cust_site_id
                                      from ar_cash_receipts
                                      where  selected_remittance_batch_id = p_batch_id and
                                      payment_trxn_extension_id = ls_response_rec_tab(i).Trxn_Extension_Id;



                                           insert_exceptions(
                                           p_batch_id   =>p_batch_id,
                                           p_request_id =>l_request_id,
                                           p_cash_receipt_id => l_cr_id,
                                           p_paying_customer_id =>l_paying_customer_id,
                                           p_paying_site_use_id => l_cust_site_id,
                                           p_exception_code  => 'AR_CC_CAPTURE_FAILED',
                                           p_additional_message => ls_iby_msg_data
                                           );


                                UPDATE ar_cash_receipts
                                   SET cc_error_flag = 'Y',
                                         cc_error_code = ls_response_rec_tab(i).Result.Result_Code,
                                         cc_error_text = substr(ls_response_rec_tab(i).Result.Result_Message,1,240),
                                         last_updated_by = l_last_updated_by,
                                         last_update_date = sysdate,
                                         last_update_login = l_last_update_login,
                                         request_id = l_request_id,
                                         program_application_id= l_program_application_id,
                                         program_id = l_program_id,
                                         program_update_date = sysdate
                                        WHERE cash_receipt_id  = l_cr_id;
                                   Exception
                                      when others then
                                        fnd_file.put_line(FND_FILE.LOG,'Exception : no data for ls_response_rec.Trxn_Extension_Id =   ' || (ls_response_rec_tab(i).Trxn_Extension_Id ));
                                   End;


                          END IF;
                  END LOOP;

   END IF; /* l_call_settlement is yes */




/* END CALL TO THE BULK SETTLEMENT PROCESS */


 IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,' end process_pay_receipt ');
  END IF;


EXCEPTION
 WHEN others THEN

     G_ERROR := 'Y';
  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'Exception : process_pay_receipt err () ');
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
  END IF;


END process_pay_receipt;
/*========================================================================+
 |  PROCEDURE process_pay_receipt_parallel                                |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
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
 | 10-JUN-2008             AGHORAKA           Created for Parallelization |
 *=========================================================================*/

PROCEDURE process_pay_receipt_parallel(
                p_batch_id            IN  NUMBER,
                p_called_from         IN  VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2
                ) IS

  CURSOR rct_info_cur IS
     SELECT a.receipt_number,
            a.amount2 amount,
            a.cash_receipt_id,
            a.currency_code,
            a.PAYMENT_CHANNEL_CODE,       /* NEW ADDED */
            a.creation_status,            /* AR USE */
            a.org_id,
            a.party_id,
            a.pay_from_customer,
            a.customer_site_use_id,
            a.payment_trxn_extension_id,
            a.batch_id
     FROM   ar_autorem_interim a
     WHERE  a.batch_id = p_batch_id
     AND    a.current_worker = WORKER_NUMBER;


  /*Bug 7666285*/
  CURSOR rct_date_cur (c_cash_receipt_id  ar_cash_receipts_all.cash_receipt_id%TYPE)
  IS
  SELECT receipt_date
  FROM  ar_cash_receipts
  WHERE cash_receipt_id = c_cash_receipt_id;



     --       rct_info    rct_info_cur%ROWTYPE;
            l_cr_rec    ar_cash_receipts_all%ROWTYPE;
            l_org_type  HR_ALL_ORGANIZATION_UNITS.TYPE%TYPE;
            l_action VARCHAR2(80);
            l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
            l_msg_count NUMBER;
            l_msg_data  VARCHAR2(2000);
            pl_msg_data  VARCHAR2(240);
           l_payment_trxn_extension_id  NUMBER;
           l_amount   NUMBER;
           l_calling_app_req_code   NUMBER;
           l_iby_msg_data  VARCHAR2(2000);
           l_amount_rec    IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
           l_payer_rec             IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
           l_response_rec          IBY_FNDCPT_COMMON_PUB.Result_rec_type;   /* OUT RESPONSE STRUCTURE */

           l_receipt_date         ar_cash_receipts_all.receipt_date%TYPE; /*Bug7666285*/

/* DECLARE the variables required for the payment engine (AUTH) all the REC TYPES */

            l_payee_rec             IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
            l_auth_attribs_rec      IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
            l_trxn_attribs_rec      IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
            l_authresult_rec       IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type; /* OUT AUTH RESULT STRUCTURE */
            l_auth_flag         VARCHAR2(1);
            l_auth_id           NUMBER;
            l_vend_msg_data VARCHAR2(2000);

/* END DECLARE the variables required for the payment engine (AUTH) all the REC TYPES */


/* declare variables for settlement */

                       ls_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
                       ls_msg_count NUMBER;
                       ls_msg_data  VARCHAR2(2000);
                       ls_response_rec_tab       IBY_FNDCPT_TRXN_PUB.SettlementResult_tbl_type;
                       ls_iby_msg_data  VARCHAR2(2000);
                       l_cr_id               ar_cash_receipts.cash_receipt_id%type;
                       l_paying_customer_id  ar_cash_receipts.pay_from_customer%type;
                       l_cust_site_id        ar_cash_receipts.customer_site_use_id%type;
                       l_count1    NUMBER;

/* end declare varaibles for settlement */


             /* 7666285 - for passing settlement_date on returns */
             lcr_receipt_attr      IBY_FNDCPT_TRXN_PUB.receiptattribs_rec_type;

                       lc_payer_rec             IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
                       lc_amount_rec            IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
                       lc_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
                       lc_msg_count NUMBER;
                       lc_msg_data  VARCHAR2(2000);
                       lc_iby_msg_data  VARCHAR2(2000);
                       lc_response_rec       IBY_FNDCPT_COMMON_PUB.Result_rec_type;



             l_request_id   NUMBER;
             l_last_updated_by         NUMBER;
             l_created_by              NUMBER;
             l_last_update_login       NUMBER;
             l_program_application_id  NUMBER;
             l_program_id              NUMBER;
             l_call_settlement VARCHAR2(1) := 'N';

BEGIN


  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,  'Entering payment processing parallel...');
  END IF;


       l_request_id := arp_standard.profile.request_id;
       l_last_updated_by := arp_standard.profile.user_id ;
       l_created_by := arp_standard.profile.user_id ;
       l_last_update_login := arp_standard.profile.last_update_login ;
       l_program_application_id := arp_standard.application_id ;
       l_program_id := arp_standard.profile.program_id;




      FOR  rct_info  in rct_info_cur  LOOP

             l_payment_trxn_extension_id := rct_info.payment_trxn_extension_id;
             l_amount := rct_info.amount;

/*  CHECK for AUTH here and do it if necessary  start */


         IF ((l_payment_trxn_extension_id is not null ) AND (l_amount >0) )  THEN


                 l_call_settlement := 'Y'; /* set the flag for calling settlement */


                  IF PG_DEBUG in ('Y', 'C') THEN
                     fnd_file.put_line(FND_FILE.LOG,  'check and then call Auth');
                  END IF;

        -- Step 1: (always performed):

          -- set up payee record:

          l_payee_rec.org_id   := rct_info.org_id;                            -- receipt's org_id
          l_payee_rec.org_type := 'OPERATING_UNIT' ;                                -- ( HR_ORGANIZATION_UNITS )


        -- set up payer (=customer) record:

        l_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
        l_payer_rec.Party_Id :=   rct_info.party_id;     -- receipt customer party id mandatory
        l_payer_rec.org_id   := rct_info.org_id ;
        l_payer_rec.org_type := 'OPERATING_UNIT';
        l_payer_rec.Cust_Account_Id :=rct_info.pay_from_customer;  -- receipt customer account_id
        l_payer_rec.Account_Site_Id :=rct_info.customer_site_use_id; -- receipt customer site_id


        if rct_info.customer_site_use_id is NULL  THEN

          l_payer_rec.org_id := NULL;
          l_payer_rec.org_type := NULL;

        end if;

        -- set up auth_attribs record:
        l_auth_attribs_rec.RiskEval_Enable_Flag := 'N';
        -- set up trxn_attribs record:
        l_trxn_attribs_rec.Originating_Application_Id := arp_standard.application_id;
        l_trxn_attribs_rec.order_id :=  rct_info.receipt_number;
        l_trxn_attribs_rec.Trxn_Ref_Number1 := 'RECEIPT';
        l_trxn_attribs_rec.Trxn_Ref_Number2 := rct_info.cash_receipt_id;

        -- set up amounts
        l_amount_rec.value := rct_info.amount;
        l_amount_rec.currency_code   := rct_info.currency_code;

        -- determine whether to AUTHORIZE
        IF PG_DEBUG in ('Y', 'C') THEN
           fnd_file.put_line(FND_FILE.LOG,  'Calling get auth for  pmt_trxn_extn_id ');
           fnd_file.put_line(FND_FILE.LOG,  'l_trxn_entity_id  '             || to_char(l_payment_trxn_extension_id) );

        END IF;

              BEGIN
               IBY_AR_UTILS.get_authorization_status(l_payment_trxn_extension_id,l_auth_flag);

	       EXCEPTION
	         WHEN OTHERS THEN
		    fnd_file.put_line(FND_FILE.LOG,'Exception in IBY_AR_UTILS.get_authorization_status');
		        l_auth_flag := 'N';
               END;
               fnd_file.put_line(FND_FILE.LOG,'the value of auth_flag is = ' || l_auth_flag);

           IF  nvl(l_auth_flag,'N') <> 'Y' then
                 fnd_file.put_line(FND_FILE.LOG,'auth needs to called');

               IF PG_DEBUG in ('Y', 'C') THEN
                  fnd_file.put_line(FND_FILE.LOG,  'Calling get auth for  pmt_trxn_extn_id ');
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payee_rec.org_id '           || to_char( l_payee_rec.org_id) );
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payee_rec.org_type '         || to_char( l_payee_rec.org_type) );
                  fnd_file.put_line(FND_FILE.LOG, 'l_payer_rec.Payment_Function '|| to_char( l_payer_rec.Payment_Function));
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.Party_Id '         || to_char( l_payer_rec.Party_Id) );
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.org_id '           || to_char( l_payer_rec.org_id) );
                  fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.org_type  '        || to_char( l_payer_rec.org_type) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_payer_rec.Cust_Account_Id ' || to_char(l_payer_rec.Cust_Account_Id) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_payer_rec.Account_Site_Id ' || to_char(l_payer_rec.Account_Site_Id) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_trxn_entity_id  '           || to_char(l_payment_trxn_extension_id) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_amount_rec.value: ' || to_char(l_amount_rec.value) );
                  fnd_file.put_line(FND_FILE.LOG,  'l_amount_rec.currency_code: '   || l_amount_rec.currency_code );

                  fnd_file.put_line(FND_FILE.LOG,  'Calling get_auth for  pmt_trxn_extn_id ');
               END IF;

              BEGIN
                 IBY_FNDCPT_TRXN_PUB.Create_Authorization(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data,
                         p_payer              => l_payer_rec,
                         p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                         p_payee              => l_payee_rec,
                         p_trxn_entity_id     => l_payment_trxn_extension_id,
                         p_auth_attribs       => l_auth_attribs_rec,
                         p_amount             => l_amount_rec,
                         x_auth_result        => l_authresult_rec,   -- out auth result struct
                         x_response           => l_response_rec );   -- out response struct


                  x_msg_count           := l_msg_count;
                  x_msg_data            := l_msg_data;

                   IF PG_DEBUG in ('Y', 'C') THEN
                        fnd_file.put_line(FND_FILE.LOG,'x_return_status  :<' || l_return_status || '>');
                        fnd_file.put_line(FND_FILE.LOG,'x_msg_count      :<' || l_msg_count || '>');
                   END IF;

                  FOR i IN 1..l_msg_count LOOP
                      fnd_file.put_line(FND_FILE.LOG,'x_msg #' || TO_CHAR(i) || ' = <' ||
                      SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,150) || '>');

		      IF i <= 2 THEN
		          pl_msg_data := SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,240) ;
		      END if;

                  END LOOP;

                     IF PG_DEBUG in ('Y', 'C') THEN
                        fnd_file.put_line(FND_FILE.LOG, '-------------------------------------');
                        fnd_file.put_line(FND_FILE.LOG, 'l_response_rec.Result_Code:     ' || l_response_rec.Result_Code);
                        fnd_file.put_line(FND_FILE.LOG, 'l_response_rec.Result_Category: '|| l_response_rec.Result_Category);
                        fnd_file.put_line(FND_FILE.LOG,  'l_response_rec.Result_message :'|| l_response_rec.Result_message );
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.Auth_Id:     ' || l_authresult_rec.Auth_Id);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.Auth_Date: '   || l_authresult_rec.Auth_Date);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.Auth_Code:     '  || l_authresult_rec.Auth_Code);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.AVS_Code: '       || l_authresult_rec.AVS_Code);
                        fnd_file.put_line(FND_FILE.LOG,'l_authresult_rec.Instr_SecCode_Check:'||l_authresult_rec.Instr_SecCode_Check);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.PaymentSys_Code: '   || l_authresult_rec.PaymentSys_Code);
                        fnd_file.put_line(FND_FILE.LOG,  'l_authresult_rec.PaymentSys_Msg: '    || l_authresult_rec.PaymentSys_Msg);

                    END IF;

             IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 fnd_file.put_line(FND_FILE.LOG,'the value of auth_id is = ' || (l_authresult_rec.Auth_Id));
              END IF;

             END IF;


             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                            G_ERROR := 'Y' ;

                  FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
                  FND_MSG_PUB.Add;

                     IF  l_response_rec.Result_Code is NOT NULL THEN

                       ---Raise the PAYMENT error code concatenated with the message

                        l_iby_msg_data := substrb( l_response_rec.Result_Code || ': '||
                                   l_response_rec.Result_Message , 1, 240);

                        fnd_file.put_line(FND_FILE.LOG,  'l_iby_msg_data: ' || l_iby_msg_data);

                       UPDATE ar_cash_receipts
        		SET cc_error_flag = 'Y',
                 	cc_error_code = l_response_rec.Result_Code,
                 	cc_error_text = pl_msg_data,
                 	last_updated_by = l_last_updated_by,
           		last_update_date = sysdate,
           		last_update_login = l_last_update_login,
         		request_id = l_request_id,
                 	program_application_id= l_program_application_id,
                	program_id = l_program_id,
             		program_update_date = sysdate
           	       WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                       fnd_file.put_line(FND_FILE.LOG,'UPDATE CR with cc_err_flag ' || SQL%ROWCOUNT );

                     END IF;

                     IF l_authresult_rec.PaymentSys_Code is not null THEN

                       ---Raise the VENDOR error code concatenated with the message

                        l_vend_msg_data := substrb(l_authresult_rec.PaymentSys_Code || ': '||
                                   l_authresult_rec.PaymentSys_Msg , 1, 240 );

                        FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_vend_msg_data);

                       UPDATE ar_cash_receipts
        	        SET cc_error_flag = 'Y',
                        cc_error_code = l_authresult_rec.PaymentSys_Code,
                        cc_error_text = substr(l_authresult_rec.PaymentSys_Msg,1,240),
                        last_updated_by = l_last_updated_by,
           	        last_update_date = sysdate,
           	        last_update_login = l_last_update_login,
         	          request_id = l_request_id,
                        program_application_id= l_program_application_id,
                        program_id = l_program_id,
             	        program_update_date = sysdate
           	       WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                      fnd_file.put_line(FND_FILE.LOG,'UPDATE CR with cc_err_flag ' || SQL%ROWCOUNT );

                    END IF;

                        insert_exceptions(
                           p_batch_id   =>p_batch_id,
                           p_request_id =>l_request_id,
                           p_paying_customer_id =>l_payer_rec.cust_account_id,
                           p_cash_receipt_id => rct_info.cash_receipt_id,
                           p_exception_code  => 'AR_CC_AUTH_FAILED',
                           p_additional_message => substrb(l_iby_msg_data||l_vend_msg_data,1,240)
                             );

                    x_return_status := l_return_status;

             END IF; /* End the error handling CREATE */
	        EXCEPTION
	           WHEN OTHERS THEN
		           G_ERROR := 'Y' ;

               fnd_file.put_line(FND_FILE.LOG,'Exception : Create_Authorization () ');
               fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));

                     insert_exceptions(
                           p_batch_id   =>p_batch_id,
                           p_request_id =>l_request_id,
                           p_paying_customer_id =>l_payer_rec.cust_account_id,
                           p_cash_receipt_id => rct_info.cash_receipt_id,
                           p_exception_code  => 'AR_CC_AUTH_FAILED',
                           p_additional_message => l_iby_msg_data
                             );

                     UPDATE ar_cash_receipts
        	      SET cc_error_flag = 'Y',
                      last_updated_by = l_last_updated_by,
           	      last_update_date = sysdate,
           	      last_update_login = l_last_update_login,
         	      request_id = l_request_id,
                      program_application_id= l_program_application_id,
                      program_id = l_program_id,
             	      program_update_date = sysdate
           	     WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                     fnd_file.put_line(FND_FILE.LOG,'UPDATE CR with cc_err_flag ' || SQL%ROWCOUNT );
           END;  /* END of BEGIN */


          END IF;  /* END if of auth flag <>'Y'  */

         END IF ; /* end if of pmt_etx is not null and amt >0 */
/*  CHECK for AUTH here and do it if necessary  end  */

           IF ((l_payment_trxn_extension_id is not null ) AND (l_amount <0) )  THEN

             /* HERE WE HAVE TO CALL RETURN */

                   -- set up payer (=customer) record:

                     lc_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
                     lc_payer_rec.Party_Id :=   rct_info.party_id;     -- receipt customer party id mandatory
                     lc_payer_rec.org_id   := rct_info.org_id ;
                     lc_payer_rec.org_type := 'OPERATING_UNIT';
                     lc_payer_rec.Cust_Account_Id :=rct_info.pay_from_customer;  -- receipt customer account_id
                     lc_payer_rec.Account_Site_Id :=rct_info.customer_site_use_id; -- receipt customer site_id

                            -- set up amounts

                       lc_amount_rec.value := ABS(rct_info.amount);
                       lc_amount_rec.currency_code   := rct_info.currency_code;

                     /* 7666285 - Selecting settlement_date*/
                IF (rct_info.cash_receipt_id IS NOT NULL) THEN
                      OPEN rct_date_cur(rct_info.cash_receipt_id);
                      FETCH rct_date_cur INTO l_receipt_date;
                      CLOSE rct_date_cur;
                 IF PG_DEBUG in ('Y', 'C') THEN
                 fnd_file.put_line(FND_FILE.LOG,'Receipt Date:'||l_receipt_date||' cash_receipt_id: '||rct_info.cash_receipt_id);
		 END IF;
                ELSE
                 IF PG_DEBUG in ('Y', 'C') THEN
                   fnd_file.put_line(FND_FILE.LOG,'rct_info.cash_receipt_id is NULL');
		 END IF;
                END IF;



                    /*7666285-Assigning the Receipt Date*/
                    lcr_receipt_attr.settlement_date := l_receipt_date;


                      if rct_info.customer_site_use_id is NULL  THEN

                       lc_payer_rec.org_id := NULL;
                       lc_payer_rec.org_type := NULL;

                      end if;

                      IF PG_DEBUG in ('Y', 'C') THEN
                       fnd_file.put_line(FND_FILE.LOG,  'Calling return for  pmt_trxn_extn_id ');
                       fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.Payment_Function ' || to_char( lc_payer_rec.Payment_Function) );
                       fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.Party_Id '         || to_char( lc_payer_rec.Party_Id) );
                       fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.org_id '           || to_char(lc_payer_rec.org_id) );
                       fnd_file.put_line(FND_FILE.LOG,  ' l_payer_rec.org_type  '        || to_char( lc_payer_rec.org_type) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_payer_rec.Cust_Account_Id '   || to_char(lc_payer_rec.Cust_Account_Id) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_payer_rec.Account_Site_Id '   || to_char(lc_payer_rec.Account_Site_Id) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_trxn_entity_id  '             || to_char(l_payment_trxn_extension_id ) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_amount_rec.value: '           || to_char(lc_amount_rec.value) );
                       fnd_file.put_line(FND_FILE.LOG,  'l_amount_rec.currency_code: '   || lc_amount_rec.currency_code );
                       fnd_file.put_line(FND_FILE.LOG,  'settlement_date: ' || lcr_receipt_attr.settlement_date);

                     END IF;

                   BEGIN
                     IBY_FNDCPT_TRXN_PUB.Create_Return(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         x_return_status      => lc_return_status,
                         x_msg_count          => lc_msg_count,
                         x_msg_data           => lc_msg_data,
                         p_payer              => lc_payer_rec,
                         p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                         p_trxn_entity_id     => l_payment_trxn_extension_id,
                         p_amount             => lc_amount_rec,
                         p_receipt_attribs    => lcr_receipt_attr,
                         x_response           => lc_response_rec );   -- out response struct

                                  x_msg_count           := lc_msg_count;
                                  x_msg_data            := lc_msg_data;

              IF PG_DEBUG in ('Y', 'C') THEN
                        fnd_file.put_line(FND_FILE.LOG,'x_return_status  :<' || lc_return_status || '>');
                        fnd_file.put_line(FND_FILE.LOG,'x_msg_count      :<' || lc_msg_count || '>');

                  FOR i IN 1..lc_msg_count LOOP
                      fnd_file.put_line(FND_FILE.LOG,'x_msg #' || TO_CHAR(i) || ' = <' ||
                      SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,150) || '>');
                  END LOOP;
              END IF;

                     IF PG_DEBUG in ('Y', 'C') THEN
                        fnd_file.put_line(FND_FILE.LOG,  '-------------------------------------');
                        fnd_file.put_line(FND_FILE.LOG,  'l_response_rec.Result_Code:     ' || lc_response_rec.Result_Code);
                        fnd_file.put_line(FND_FILE.LOG,  'l_response_rec.Result_Category: ' || lc_response_rec.Result_Category);
                        fnd_file.put_line(FND_FILE.LOG,  'l_response_rec.Result_message : ' || lc_response_rec.Result_message );
                     END IF;

                 IF (lc_return_status <> FND_API.G_RET_STS_SUCCESS) THEN


                            G_ERROR := 'Y' ;

                     IF PG_DEBUG in ('Y', 'C') THEN
                     fnd_file.put_line(FND_FILE.LOG,'create_cash_126');
                     END IF;

                     FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
                      FND_MSG_PUB.Add;

                     IF  lc_response_rec.Result_Code is NOT NULL THEN

                       ---Raise the PAYMENT error code concatenated with the message

                        lc_iby_msg_data := substrb( lc_response_rec.Result_Code || ': '|| lc_response_rec.Result_Message , 1, 240);

                        IF PG_DEBUG in ('Y', 'C') THEN
                          fnd_file.put_line(FND_FILE.LOG,  'lc_iby_msg_data: ' || lc_iby_msg_data);
                        END IF;

                        FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',lc_iby_msg_data);

                        FND_MSG_PUB.Add;

                     END IF;

                      insert_exceptions(
                           p_batch_id   =>p_batch_id,
                           p_request_id =>l_request_id,
                           p_paying_customer_id =>l_payer_rec.cust_account_id,
                           p_cash_receipt_id => rct_info.cash_receipt_id,
                           p_exception_code  => 'AR_CC_AUTH_FAILED',
                           p_additional_message => lc_iby_msg_data
                             );

                      UPDATE ar_cash_receipts
          	       SET cc_error_flag = 'Y',
                       cc_error_code = lc_response_rec.Result_Code,
                       cc_error_text = pl_msg_data,
                       last_updated_by = l_last_updated_by,
             	       last_update_date = sysdate,
            	       last_update_login = l_last_update_login,
          	       request_id = l_request_id,
                       program_application_id= l_program_application_id,
                       program_id = l_program_id,
              	       program_update_date = sysdate
           	      WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                    FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count  =>  x_msg_count,
                               p_data   => x_msg_data );

                    x_return_status := lc_return_status;

                END IF;
	        EXCEPTION
	           WHEN OTHERS THEN
		           G_ERROR := 'Y' ;

                   fnd_file.put_line(FND_FILE.LOG,'Exception : Create_Return () ');
                   fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));

                     insert_exceptions(
                           p_batch_id   =>p_batch_id,
                           p_request_id =>l_request_id,
                           p_paying_customer_id =>l_payer_rec.cust_account_id,
                           p_cash_receipt_id => rct_info.cash_receipt_id,
                           p_exception_code  => 'AR_CC_AUTH_FAILED',
                           p_additional_message => l_iby_msg_data
                             );

                     UPDATE ar_cash_receipts
        	      SET cc_error_flag = 'Y',
                      last_updated_by = l_last_updated_by,
           	      last_update_date = sysdate,
           	      last_update_login = l_last_update_login,
         	      request_id = l_request_id,
                      program_application_id= l_program_application_id,
                      program_id = l_program_id,
             	      program_update_date = sysdate
           	     WHERE cash_receipt_id  = rct_info.cash_receipt_id;

                     fnd_file.put_line(FND_FILE.LOG,'UPDATE CR with cc_err_flag ' || SQL%ROWCOUNT );
           END;  /* END of BEGIN */
        END IF;


    END LOOP ; /* for the rct_cur */



/* HERE WE WILL CALL THE BULK SETTLEMENT PROCESS START */

    IF l_call_settlement = 'Y'  THEN

           IF PG_DEBUG in ( 'Y','C') THEN

                  IF PG_DEBUG in ('Y', 'C') THEN
                    fnd_file.put_line(FND_FILE.LOG,  'Calling bulk settlement');
                  END IF;


                    select count(*)
                    into l_count1
                    from AR_FUNDS_CAPTURE_ORDERS_V
                    where CALL_APP_SERVICE_REQ_CODE = 'AR_'||p_batch_id;

                  IF PG_DEBUG in ('Y', 'C') THEN
                  fnd_file.put_line(FND_FILE.LOG,  ' No of records in AR_FUNDS_CAPTURE_ORDERS_V  ' || l_count1 );
                  fnd_file.put_line(FND_FILE.LOG,  'p_calling_app_id  '         || to_char(l_program_application_id) );
                  fnd_file.put_line(FND_FILE.LOG,  ' p_calling_app_request_code  '           ||  'AR_'||p_batch_id);
                  fnd_file.put_line(FND_FILE.LOG,  'p_order_view_name  '         || 'AR_FUNDS_CAPTURE_ORDERS_V' );
                  END IF;
            END IF;

                 IBY_FNDCPT_TRXN_PUB.Create_Settlements(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         p_calling_app_id     => l_program_application_id,
                         p_calling_app_request_code => 'AR_'||p_batch_id||'_'||WORKER_NUMBER,
                         p_order_view_name  => 'AR_FUNDS_CAPTURE_ORDERS_V',
                         x_return_status      => ls_return_status,
                         x_msg_count          => ls_msg_count,
                         x_msg_data           => ls_msg_data,
                         x_responses           => ls_response_rec_tab );


                        IF PG_DEBUG in ('Y', 'C') THEN
                        fnd_file.put_line(FND_FILE.LOG,'x_return_status  :<' || ls_return_status || '>');
                        fnd_file.put_line(FND_FILE.LOG,'x_msg_count      :<' || ls_msg_count || '>');

                  FOR i IN 1..ls_msg_count LOOP
                      fnd_file.put_line(FND_FILE.LOG,'x_msg #' || TO_CHAR(i) || ' = <' ||
                                        SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,150) || '>');
                  END LOOP;
                  END IF;

          IF PG_DEBUG in ('Y', 'C') THEN

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
               IF PG_DEBUG in ('Y', 'C') THEN
               fnd_file.put_line(FND_FILE.LOG,'the value of ls_response_rec.Trxn_Extension_Id =   ' || (ls_response_rec_tab(i).Trxn_Extension_Id ));
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_code :    '       || ls_response_rec_tab(i).Result.Result_code);
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_Category :  ' || ls_response_rec_tab(i).Result.Result_Category);
                 fnd_file.put_line (FND_FILE.LOG, 'ls_response_rec.Result.Result_Message :    '  || ls_response_rec_tab(i).Result.Result_Message);
               END IF;
               END LOOP;

             END IF;



                 FOR  i IN ls_response_rec_tab.FIRST..ls_response_rec_tab.LAST   LOOP


                        IF ls_response_rec_tab(i).Result.Result_code in ( 'SETTLEMENT_SUCCESS','SETTLEMENT_PENDING') THEN
                           IF PG_DEBUG in ('Y', 'C') THEN
                           fnd_file.put_line(FND_FILE.LOG,'SETTLEMENT SUCCESS FOR Trxn_Extension_Id =   '
                                 || (ls_response_rec_tab(i).Trxn_Extension_Id ));
                           END IF;

                        ELSE

                                 G_ERROR := 'Y';

                                   ls_iby_msg_data := null;    /* initialize here */

                                   FND_MESSAGE.set_name('AR', 'AR_CC_CAPTURE_FAILED');
                                   FND_MSG_PUB.Add;
                                         ---Raise the PAYMENT error code concatenated with the message

                                          ls_iby_msg_data := substrb( ls_response_rec_tab(i).Result.Result_Code || ': '||
                                                        ls_response_rec_tab(i).Result.Result_Message , 1, 240);

                                           IF PG_DEBUG in ('Y', 'C') THEN
                                           fnd_file.put_line(FND_FILE.LOG,  'ls_iby_msg_data: ' || ls_iby_msg_data);
                                           END IF;

                                   Begin
                                      select /*+ INDEX(ar_cash_receipts ar_cash_receipts_n15) */
                                      	     cash_receipt_id,pay_from_customer,customer_site_use_id
                                      into   l_cr_id,l_paying_customer_id,l_cust_site_id
                                      from ar_cash_receipts
                                      where  selected_remittance_batch_id = p_batch_id and
                                      payment_trxn_extension_id = ls_response_rec_tab(i).Trxn_Extension_Id;



                                           insert_exceptions(
                                           p_batch_id   =>p_batch_id,
                                           p_request_id =>l_request_id,
                                           p_cash_receipt_id => l_cr_id,
                                           p_paying_customer_id =>l_paying_customer_id,
                                           p_paying_site_use_id => l_cust_site_id,
                                           p_exception_code  => 'AR_CC_CAPTURE_FAILED',
                                           p_additional_message => ls_iby_msg_data
                                           );


                                UPDATE ar_cash_receipts
                                   SET cc_error_flag = 'Y',
                                         cc_error_code = ls_response_rec_tab(i).Result.Result_Code,
                                         cc_error_text = ls_response_rec_tab(i).Result.Result_Message,
                                         last_updated_by = l_last_updated_by,
                                         last_update_date = sysdate,
                                         last_update_login = l_last_update_login,
                                         request_id = l_request_id,
                                         program_application_id= l_program_application_id,
                                         program_id = l_program_id,
                                         program_update_date = sysdate
                                        WHERE cash_receipt_id  = l_cr_id;
                                   Exception
                                      when others then
                                        fnd_file.put_line(FND_FILE.LOG,'Exception : no data for ls_response_rec.Trxn_Extension_Id =   ' || (ls_response_rec_tab(i).Trxn_Extension_Id ));
                                   End;


                          END IF;
                  END LOOP;

   END IF; /* l_call_settlement is yes */




/* END CALL TO THE BULK SETTLEMENT PROCESS */


 IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,' end process_pay_receipt ');
  END IF;


EXCEPTION
 WHEN others THEN

     G_ERROR := 'Y';
  IF PG_DEBUG in ('Y', 'C') THEN
     fnd_file.put_line(FND_FILE.LOG,'Exception : process_pay_receipt err () ');
     fnd_file.put_line(FND_FILE.LOG,'error code() '|| to_char(SQLCODE));
  END IF;


END process_pay_receipt_parallel;



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



             l_request_id              NUMBER;
             l_last_updated_by         NUMBER;
             l_created_by              NUMBER;
             l_last_update_login       NUMBER;
             l_program_application_id  NUMBER;
             l_program_id              NUMBER;

             l_reqid                   NUMBER;
BEGIN

   IF PG_DEBUG in ('Y','C') THEN

             fnd_file.put_line(FND_FILE.LOG, 'enter insert exceptions');
             fnd_file.put_line(FND_FILE.LOG,  'value of p_batch_id'               || p_batch_id);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_request_id'             || p_request_id);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_cash_receipt_id'        || p_cash_receipt_id);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_payment_schedule_id'    || p_payment_schedule_id);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_paying_customer_id'     || p_paying_customer_id);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_paying_site_use_id'     || p_paying_site_use_id);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_due_date'               || p_due_date);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_cust_min_rec_amount'     || p_cust_min_rec_amount);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_bank_min_rec_amount'     || p_bank_min_rec_amount);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_exception_code'           ||p_exception_code);
             fnd_file.put_line(FND_FILE.LOG,  'value of p_additional_message'       ||p_additional_message);

  END IF;




              l_request_id := arp_standard.profile.request_id;
       l_last_updated_by := arp_standard.profile.user_id ;
       l_created_by := arp_standard.profile.user_id ;
       l_last_update_login := arp_standard.profile.last_update_login ;
       l_program_application_id := arp_standard.application_id ;
       l_program_id := arp_standard.profile.program_id;

IF PG_DEBUG in ('Y','C') THEN

fnd_file.put_line(FND_FILE.LOG,  'value of l_request_id  '           || l_request_id );
fnd_file.put_line(FND_FILE.LOG,  'value of l_last_updated_by  '      || l_last_updated_by );
fnd_file.put_line(FND_FILE.LOG,  'value of l_created_by     '        || l_created_by );
fnd_file.put_line(FND_FILE.LOG,  'value of l_last_update_login '     || l_last_update_login );
fnd_file.put_line(FND_FILE.LOG,  'value of l_program_application_id '|| to_char(l_program_application_id) );
fnd_file.put_line(FND_FILE.LOG,  'value of l_program_id   '          || to_char(l_program_id) );

END IF;


 INSERT
        INTO ar_autorec_exceptions
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
             l_request_id,
             p_cash_receipt_id,
             p_payment_schedule_id,
             p_paying_customer_id,
             p_paying_site_use_id,
             p_due_date,
             p_cust_min_rec_amount,
             p_bank_min_rec_amount,
             p_exception_code,
             p_additional_message,
             sysdate,
             l_last_updated_by,
             sysdate,
             l_created_by,
             l_last_update_login,
             l_program_application_id,
             l_program_id,
             sysdate  FROM DUAL;

   IF PG_DEBUG in ('Y','C') THEN
      fnd_file.put_line(FND_FILE.LOG,'the rows in exceptions = ' || SQL%ROWCOUNT );
   END IF;



  EXCEPTION
   WHEN OTHERS THEN

   IF PG_DEBUG in ('Y','C') THEN
      fnd_file.put_line(FND_FILE.LOG,'ERROR IN INSERT_AUTOREC_EXCEPTIONS' );
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

PROCEDURE SUBMIT_REPORT (
                          p_batch_id    ar_batches.batch_id%TYPE,
                          p_request_id  ar_cash_receipts.request_id%TYPE
                        ) IS

               l_reqid   NUMBER(15);
               l_org_id  NUMBEr;
               l_complete BOOLEAN := FALSE;
               l_uphase VARCHAR2(255);
               l_dphase VARCHAR2(255);
               l_ustatus VARCHAR2(255);
               l_dstatus VARCHAR2(255);
               l_message VARCHAR2(32000);

BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'Submitting the report..');
      END IF;

--Start of Bug 5519913

--l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
l_org_id := mo_global.get_current_org_id;

if l_org_id is null then

BEGIN
select org_id into l_org_id
from ar_batches_all
where batch_id = p_batch_id;
EXCEPTION
when others then
arp_util.debug('ar_autorem_api.submit Report ...OTHERS');
l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
end;

end if;
-- end of Bug 5519913

fnd_request.set_org_id(l_org_id);

         l_reqid := FND_REQUEST.SUBMIT_REQUEST (
                              application=>'AR',
                              program=>'ARZCARPO',
                              sub_request=>FALSE,
                              argument1=>'P_PROCESS_TYPE=REMIT',
                              argument2=>'P_BATCH_ID='|| p_batch_id,
                              argument3=>'P_CREATE_FLAG='||pg_create_flag,
                              argument4=>'P_APPROVE_FLAG='||pg_approve_flag,
                              argument5=>'P_FORMAT_FLAG='||pg_format_flag,
                              argument6=>'P_REQUEST_ID_MAIN=' || p_request_id
                              ) ;


      IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'Request Id :' || l_reqid);
      END IF;


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

EXCEPTION
WHEN OTHERS THEN
 IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'Submitting the report.iN ERROR.');
  END IF;

END SUBMIT_REPORT;


/* START SUBMIT_FORMAT */
PROCEDURE SUBMIT_FORMAT ( p_batch_id    ar_batches.batch_id%TYPE
                        ) IS

                l_org_id  NUMBER;
                l_reqid  NUMBER;
                l_prog_name VARCHAR2(30);


BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'Submitting the report..');
      END IF;

--Start of Bug 5519913
--l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
l_org_id := mo_global.get_current_org_id;

if l_org_id is null then
BEGIN

select org_id into l_org_id
from ar_batches_all
where batch_id = p_batch_id;
EXCEPTION
when others then
arp_util.debug('ar_autorem_api.submit Report ...OTHERS');
l_org_id := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
end;
end if;
--End of Bug fix 5519913

fnd_request.set_org_id(l_org_id);

select nvl(decode(ab.remit_method_code,'FACTORING',appfactor.program_name,appremit.program_name),'ARXAPFRM')
into  l_prog_name
from ar_batches ab,
     ar_receipt_method_accounts rma,
     ap_payment_programs appremit,
     ap_payment_programs appfactor
where ab.type = 'REMITTANCE'
and ab.batch_id = p_batch_id
and ab.receipt_method_id = rma.receipt_method_id
and ab.remit_bank_acct_use_id = rma.remit_bank_acct_use_id
and rma.factor_print_program_id= appfactor.program_id(+)
and rma.remit_print_program_id = appremit.program_id(+);

         l_reqid := FND_REQUEST.SUBMIT_REQUEST (
                              application=>'AR',
                              program=>l_prog_name,
                              sub_request=>FALSE,
                              argument1=>'P_BATCH_ID='|| p_batch_id
                              ) ;


      IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'Request Id :' || l_reqid);
      END IF;


 commit;  -- This is there to commit the conc request.

EXCEPTION
WHEN OTHERS THEN
 IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'Submitting the report.iN ERROR.');
  END IF;

END SUBMIT_FORMAT;

/* END SUBMIT_FORMAT */


/* START CONTROL_CHECK */
PROCEDURE CONTROL_CHECK ( p_batch_id    ar_batches.batch_id%TYPE
                        ) IS
   l_request_id   NUMBER;
   l_last_updated_by         NUMBER;
   l_created_by              NUMBER;
   l_last_update_login       NUMBER;
   l_program_application_id  NUMBER;
   l_program_id              NUMBER;
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         fnd_file.put_line(FND_FILE.LOG,'control_check()+');
      END IF;

    l_request_id := arp_standard.profile.request_id;
    l_last_updated_by := arp_standard.profile.user_id ;
    l_created_by := arp_standard.profile.user_id ;
    l_last_update_login := arp_standard.profile.last_update_login ;
    l_program_application_id := arp_standard.application_id ;
    l_program_id := arp_standard.profile.program_id;

UPDATE ar_cash_receipts
SET cc_error_flag = 'Y',
  last_updated_by = l_last_updated_by,
  last_update_date = sysdate,
  last_update_login = l_last_update_login,
  request_id = l_request_id,
  program_application_id = l_program_application_id,
  program_id = l_program_id,
  program_update_date = sysdate
WHERE cash_receipt_id in (
SELECT cr.cash_receipt_id
FROM ar_cash_receipts cr,
  ar_cash_receipt_history crh,
  iby_trxn_extensions_v trxn_ext
WHERE crh.request_id = l_request_id
 AND crh.status = 'REMITTED'
 AND crh.current_record_flag = 'Y'
 AND crh.cash_receipt_id = cr.cash_receipt_id
 AND cr.type = 'CASH'
 AND cr.payment_trxn_extension_id = trxn_ext.trxn_extension_id
 AND trxn_ext.settled_flag = 'N'
 AND NOT EXISTS (SELECT 'x'
   FROM iby_fndcpt_tx_operations op,    iby_trxn_summaries_all summ
   WHERE cr.payment_trxn_extension_id = op.trxn_extension_id
   AND op.transactionid = summ.transactionid
   AND summ.reqtype in ('ORAPMTCAPTURE','ORAPMTBATCHREQ')
   AND summ.status IN(0, 11, 100, 111))
  ) AND selected_remittance_batch_id = p_batch_id;

 fnd_file.put_line(FND_FILE.LOG,'Bad CASH receipt rows detected : '||sql%rowcount);

 if sql%rowcount > 0 then
   G_ERROR := 'Y' ;
  INSERT INTO ar_autorec_exceptions
            (batch_id,
             request_id,
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
        SELECT
             p_batch_id,
             l_request_id,
             cr.cash_receipt_id,
             cr.pay_from_customer,
             'AR_CC_AUTH_FAILED',
             'Failure in settlements',
             sysdate,
             l_last_updated_by,
             sysdate,
             l_created_by,
             l_last_update_login,
             l_program_application_id,
             l_program_id,
             sysdate
          FROM ar_cash_receipts cr,
               ar_cash_receipt_history crh,
               iby_trxn_extensions_v trxn_ext
          WHERE crh.request_id = l_request_id
                AND crh.status = 'REMITTED'
                AND crh.current_record_flag = 'Y'
                AND crh.cash_receipt_id = cr.cash_receipt_id
                AND cr.type = 'CASH'
                AND cr.payment_trxn_extension_id = trxn_ext.trxn_extension_id
                AND trxn_ext.settled_flag = 'N'
                AND NOT EXISTS (SELECT 'x'
                  FROM iby_fndcpt_tx_operations op,    iby_trxn_summaries_all summ
                  WHERE cr.payment_trxn_extension_id = op.trxn_extension_id
                  AND op.transactionid = summ.transactionid
                  AND summ.reqtype in ('ORAPMTCAPTURE','ORAPMTBATCHREQ')
                  AND summ.status IN(0, 11, 100, 111));
 end if;

UPDATE ar_cash_receipts
SET cc_error_flag = 'Y',
  last_updated_by = l_last_updated_by,
  last_update_date = sysdate,
  last_update_login = l_last_update_login,
  request_id = l_request_id,
  program_application_id = l_program_application_id,
  program_id = l_program_id,
  program_update_date = sysdate
WHERE cash_receipt_id in (
SELECT cr.cash_receipt_id
FROM ar_cash_receipts cr,
  ar_cash_receipt_history crh,
  iby_trxn_extensions_v trxn_ext
WHERE crh.request_id = l_request_id
 AND crh.status = 'REMITTED'
 AND crh.current_record_flag = 'Y'
 AND crh.cash_receipt_id = cr.cash_receipt_id
 AND cr.type = 'MISC'
 AND cr.payment_trxn_extension_id = trxn_ext.trxn_extension_id
 AND trxn_ext.returned_flag = 'N'
 AND NOT EXISTS (SELECT 'x'
     FROM iby_fndcpt_tx_operations op,    iby_trxn_summaries_all summ
     WHERE cr.payment_trxn_extension_id = op.trxn_extension_id
     AND op.transactionid = summ.transactionid
     AND summ.reqtype in ('ORAPMTRETURN','ORAPMTCREDIT')
     AND status IN(0, 11, 100, 111))
 ) AND selected_remittance_batch_id = p_batch_id;

 fnd_file.put_line(FND_FILE.LOG,'Bad MISC receipt rows detected : '||sql%rowcount);

 if sql%rowcount > 0 then
   G_ERROR := 'Y' ;
  INSERT INTO ar_autorec_exceptions
            (batch_id,
             request_id,
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
        SELECT
             p_batch_id,
             l_request_id,
             cr.cash_receipt_id,
             cr.pay_from_customer,
             'AR_CC_AUTH_FAILED',
             'Failure in settlements',
             sysdate,
             l_last_updated_by,
             sysdate,
             l_created_by,
             l_last_update_login,
             l_program_application_id,
             l_program_id,
             sysdate
          FROM ar_cash_receipts cr,
               ar_cash_receipt_history crh,
               iby_trxn_extensions_v trxn_ext
          WHERE crh.request_id = l_request_id
                AND crh.status = 'REMITTED'
                AND crh.current_record_flag = 'Y'
                AND crh.cash_receipt_id = cr.cash_receipt_id
                AND cr.type = 'MISC'
                AND cr.payment_trxn_extension_id = trxn_ext.trxn_extension_id
                AND trxn_ext.returned_flag = 'N'
                AND NOT EXISTS (SELECT 'x'
                  FROM iby_fndcpt_tx_operations op,    iby_trxn_summaries_all summ
                  WHERE cr.payment_trxn_extension_id = op.trxn_extension_id
                  AND op.transactionid = summ.transactionid
                  AND summ.reqtype in ('ORAPMTRETURN','ORAPMTCREDIT')
                  AND status IN(0, 11, 100, 111));
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

/* END CONTROL_CHECK */

PROCEDURE rec_reset (  p_request_id  NUMBER
                        ) IS


BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
          fnd_file.put_line(FND_FILE.LOG,'inside rec reset. value of G_ERROR = '|| G_ERROR );
      END IF;

     IF G_ERROR = 'Y' THEN

UPDATE ar_cash_receipts
SET cc_error_flag = null
WHERE cash_receipt_id in (
SELECT cr.cash_receipt_id
FROM ar_cash_receipts cr,
  ar_cash_receipt_history crh,
  iby_trxn_extensions_v trxn_ext
WHERE cr.request_id = p_request_id
 AND cr.cc_error_flag = 'Y'
 AND cr.type = 'CASH'
 AND crh.cash_receipt_id = cr.cash_receipt_id
 AND crh.status = 'REMITTED'
 AND crh.current_record_flag = 'Y'
 AND cr.payment_trxn_extension_id = trxn_ext.trxn_extension_id
 AND trxn_ext.settled_flag = 'Y'
 AND EXISTS (SELECT 'x'
   FROM iby_fndcpt_tx_operations op,    iby_trxn_summaries_all summ
   WHERE cr.payment_trxn_extension_id = op.trxn_extension_id
   AND op.transactionid = summ.transactionid
   AND summ.reqtype in ('ORAPMTCAPTURE','ORAPMTBATCHREQ')
   AND summ.status IN(0, 11, 100, 111))
  ) AND request_id = p_request_id
    AND cc_error_flag = 'Y';

 fnd_file.put_line(FND_FILE.LOG,'CASH receipt rows updated : '||sql%rowcount);


UPDATE ar_cash_receipts
SET cc_error_flag = null
WHERE cash_receipt_id in (
SELECT cr.cash_receipt_id
FROM ar_cash_receipts cr,
  ar_cash_receipt_history crh,
  iby_trxn_extensions_v trxn_ext
WHERE cr.request_id = p_request_id
 AND cr.cc_error_flag = 'Y'
 AND cr.type = 'MISC'
 AND crh.cash_receipt_id = cr.cash_receipt_id
 AND crh.status = 'REMITTED'
 AND crh.current_record_flag = 'Y'
 AND cr.payment_trxn_extension_id = trxn_ext.trxn_extension_id
 AND trxn_ext.returned_flag = 'Y'
 AND EXISTS (SELECT 'x'
   FROM iby_fndcpt_tx_operations op,    iby_trxn_summaries_all summ
   WHERE cr.payment_trxn_extension_id = op.trxn_extension_id
   AND op.transactionid = summ.transactionid
   AND summ.reqtype in ('ORAPMTRETURN','ORAPMTCREDIT')
   AND status IN(0, 11, 100, 111))
  ) AND request_id = p_request_id
    AND cc_error_flag = 'Y';

 fnd_file.put_line(FND_FILE.LOG,'MISC receipt rows updated : '||sql%rowcount);

           fnd_file.put_line(FND_FILE.LOG,'delete the bad receipts');

             update ar_cash_receipts
             set selected_remittance_batch_id = null
             where request_id = p_request_id
             and   cc_error_flag = 'Y';

         IF PG_DEBUG in ('Y','C') THEN
             fnd_file.put_line(FND_FILE.LOG,' rows updated CR = ' || SQL%ROWCOUNT );
         END IF;


                UPDATE ar_cash_receipt_history
                SET reversal_cash_receipt_hist_id = null,
                reversal_gl_date = null,
                reversal_created_from = null,
                current_record_flag = 'Y'
                where request_id = p_request_id
                and  status = 'CONFIRMED'
                and cash_receipt_id in ( select cash_receipt_id
                              from ar_cash_receipts
                              where request_id = p_request_id
                              and   cc_error_flag = 'Y');

         IF PG_DEBUG in ('Y','C') THEN
             fnd_file.put_line(FND_FILE.LOG,' rows UPDATED CRH = ' || SQL%ROWCOUNT );
         END IF;

		delete from ar_distributions
		where source_table = 'CRH'
		and source_id in ( select crh.cash_receipt_history_id
		from ar_cash_receipt_history crh,
                     ar_cash_receipts cr
		where crh.STATUS = 'REMITTED'
                and crh.request_id = p_request_id
                and cr.cash_receipt_id = crh.cash_receipt_id
                and cr.request_id = p_request_id
                and cr.cc_error_flag = 'Y' );

         IF PG_DEBUG in ('Y','C') THEN
             fnd_file.put_line(FND_FILE.LOG,' rows DELETED AR_DIST = ' || SQL%ROWCOUNT );
         END IF;

		delete from ar_cash_receipt_history
		where STATUS = 'REMITTED'
            and request_id = p_request_id
            and cash_receipt_id in ( select cash_receipt_id
                                     from ar_cash_receipts
                                     where request_id = p_request_id
                                     and cc_error_flag = 'Y');


         IF PG_DEBUG in ('Y','C') THEN
             fnd_file.put_line(FND_FILE.LOG,' rows DELETED CRH = ' || SQL%ROWCOUNT );
         END IF;


      END IF;

EXCEPTION
WHEN OTHERS THEN
 IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('rec_reset ERROR.'|| SQLERRM );
  END IF;

END rec_reset;

END AR_AUTOREM_API;

/
