--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_WRITEOFF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_WRITEOFF" AS
/* $Header: ARPWRTFB.pls 120.8.12000000.4 2007/09/27 11:42:30 nemani ship $ */
/*========================================================================
 | PRIVATE PROCEDURE submit_report
 |
 | DESCRIPTION
 |      This procedure submits the receipt write-off report.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      arp_process_writeoff.create_receipt_writeoff()
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 | PARAMETERS
 |      p_currency_code     IN Currency code
 |
 | RETURNS    :  NONE
 |
 | KNOWN ISSUES
 |
 | NOTES
 |     This concurrent request for receipt write-off report is submitted
 |     after the write_off records are processed.
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-AUG-00             S.Nambiar         Created
 | 21-MAY-01             S.Nambiar         Bug 1784850 - Modified to pass apply
 |                                         date apply_gl_date to the report.
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE submit_report(p_currency_code  IN VARCHAR2,
                        p_apply_date     IN DATE,
                        p_apply_gl_date  IN DATE) IS

m_request_id      NUMBER;
l_request_id      NUMBER;
l_options_ok      BOOLEAN;
l_org_id          NUMBER;

BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_process_writeoff.submit_report()+');
      END IF;

      l_request_id := fnd_global.conc_request_id;

      --Bug 5094139
      select org_id
      into l_org_id
      from fnd_concurrent_requests
      where request_id = l_request_id;

      fnd_request.set_org_id(l_org_id);

      l_options_ok := FND_REQUEST.SET_OPTIONS (
                      implicit      => 'NO'
                    , protected     => 'YES'
                    , language      => ''
                    , territory     => '');
      IF (l_options_ok)
      THEN
           m_request_id := FND_REQUEST.SUBMIT_REQUEST(
                 application   => 'AR'
                , program       => 'ARWRTRPT'
                , description   => ''
                , start_time    => ''
                , sub_request   => FALSE
                , argument1     => 'P_APPLY_DATE='||fnd_date.date_to_canonical(p_apply_date)
                , argument2     => 'P_CUSTOMER_NUMBER='||''
                , argument3     => 'P_GL_DATE='||fnd_date.date_to_canonical(p_apply_gl_date)
                , argument4     => 'P_RECEIPT_CURRENCY_CODE='||p_currency_code
                , argument5     => 'P_RECEIPT_DATE_FROM='||''
                , argument6     => 'P_RECEIPT_DATE_TO='||''
                , argument7     => 'P_RECEIPT_GL_DATE_FROM='||''
                , argument8     => 'P_RECEIPT_GL_DATE_TO='||''
                , argument9     => 'P_RECEIPT_METHOD_ID='||''
                , argument10    => 'P_RECEIPT_NUMBER='||''
                , argument11    => 'P_REQUEST_ID='||fnd_number.number_to_canonical(l_request_id)
                , argument12    => 'P_UNAPP_AMOUNT='||''
                , argument13    => 'P_UNAPP_AMOUNT_PERCENT='||''
                , argument14    => 'P_USER_ID='||''
                , argument15    => chr(0)
                , argument16    => ''
                , argument17    => ''
                , argument18    => ''
                , argument19    => ''
                , argument20    => ''
                , argument21    => ''
                , argument22    => ''
                , argument23    => ''
                , argument24    => ''
                , argument25    => ''
                , argument26    => ''
                , argument27    => ''
                , argument28    => ''
                , argument29    => ''
                , argument30    => ''
                , argument31    => ''
                , argument32    => ''
                , argument33    => ''
                , argument34    => ''
                , argument35    => ''
                , argument36    => ''
                , argument37    => ''
                , argument38    => ''
                , argument39    => ''
                , argument40    => ''
                , argument41    => ''
                , argument42    => ''
                , argument43    => ''
                , argument44    => ''
                , argument45    => ''
                , argument46    => ''
                , argument47    => ''
                , argument48    => ''
                , argument49    => ''
                , argument50    => ''
                , argument51    => ''
                , argument52    => ''
                , argument53    => ''
                , argument54    => ''
                , argument55    => ''
                , argument56    => ''
                , argument57    => ''
                , argument58    => ''
                , argument59    => ''
                , argument60    => ''
                , argument61    => ''
                , argument62    => ''
                , argument63    => ''
                , argument64    => ''
                , argument65    => ''
                , argument66    => ''
                , argument67    => ''
                , argument68    => ''
                , argument69    => ''
                , argument70    => ''
                , argument71    => ''
                , argument72    => ''
                , argument73    => ''
                , argument74    => ''
                , argument75    => ''
                , argument76    => ''
                , argument77    => ''
                , argument78    => ''
                , argument79    => ''
                , argument80    => ''
                , argument81    => ''
                , argument82    => ''
                , argument83    => ''
                , argument84    => ''
                , argument85    => ''
                , argument86    => ''
                , argument87    => ''
                , argument88    => ''
                , argument89    => ''
                , argument90    => ''
                , argument91    => ''
                , argument92    => ''
                , argument93    => ''
                , argument94    => ''
                , argument95    => ''
                , argument96    => ''
                , argument97    => ''
                , argument98    => ''
                , argument99    => ''
                , argument100   => '');
     END IF;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('arp_process_writeoff.submit_report()-');
     END IF;

EXCEPTION
    WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('arp_process_writeoff.submit_report() '||SQLERRM);
     END IF;

END submit_report;
/*========================================================================
 | PUBLIC PROCEDURE create_receipt_writeoff
 |
 | DESCRIPTION
 |      This procedure proccess the write-off records according to the
 |      criteria passed
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      arp_process_writeoff.unapplied_amount()
 |
 | PARAMETERS
 |      p_receipt_currency_code     IN   Receipt currency code
 |      p_unapp_amount              IN   Unapplied amount
 |      p_unapp_amount_percent      IN   Unapplied amount percent
 |      p_receipt_date_from         IN   Receipt date from
 |      p_receipt_date_to           IN   Receipt date to
 |      p_receipt_gl_date_from      IN   Receipt GL date from
 |      p_receipt_gl_date_to        IN   Receipt GL date to
 |      p_receipt_method_id         IN   Receipt payment method id
 |      p_customer_number           IN   Customer Number
 |      p_receipt_number            IN   Receipt Number
 |      p_receivable_trx_id         IN   Receivable trx id of the activity
 |      p_apply_date                IN   Apply Date
 |      p_gl_date                   IN   GL Date
 |      p_comments                  IN   Comments
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-AUG-00             S.Nambiar         Created
 | 18-MAY-01             S.Nambiar         Bug 1784818 -  Modified the fetch
 |                                         validate receipt_date to be less
 |                                         than apply date and gl_date
 | 19-JUL-01             S.Nambiar         Bug 1893041 - When unapp_amount parameter
 |                                         is not null and unapp_amount_percentage is
 |                                         null, in unapp_amount_percent calculation
 |                                         the value should be 100 insted of 0.
 | 26-SEP-01             R.Jose            Bug 1981698
 |                                         Changed the variable name
 |                                         c_customer_number to c_customer_id
 |                                         and modified the definition of
 |                                         l_customer_number.
 | 16-JUL-02             S.Nambiar         Bug 2276353,Code restructuring done
 |                                         to addresses performance issues.
 *=======================================================================*/
PROCEDURE create_receipt_writeoff (
       errbuf                   IN OUT NOCOPY VARCHAR2,
       retcode                  IN OUT NOCOPY VARCHAR2,
       p_receipt_currency_code  IN ar_cash_receipts.currency_code%type,
       p_unapp_amount           IN VARCHAR2,
       p_unapp_amount_percent	IN VARCHAR2,
       p_receipt_date_from      IN VARCHAR2,
       p_receipt_date_to        IN VARCHAR2,
       p_receipt_gl_date_from   IN VARCHAR2,
       p_receipt_gl_date_to     IN VARCHAR2,
       p_receipt_method_id 		IN VARCHAR2,
       p_customer_number  		IN VARCHAR2,
       p_receipt_number			IN ar_cash_receipts.receipt_number%type,
       p_receivable_trx_id  		IN VARCHAR2,
       p_apply_date   			IN VARCHAR2,
       p_gl_date          		IN VARCHAR2,
       p_comments    			IN ar_receivable_applications.comments%type
       ) IS

    --Declare Local Variables
      l_msg_count                       NUMBER;
      l_msg_data                        VARCHAR2(240);
      l_return_status                   VARCHAR2(1);

      l_unapp_amount          ar_receivable_applications.amount_applied%type;
      l_unapp_amount_percent  NUMBER;
      l_receipt_date_from     ar_cash_receipts.receipt_date%type;
      l_receipt_date_to       ar_cash_receipts.receipt_date%type;
      l_receipt_gl_date_from  ar_receivable_applications.gl_date%type;
      l_receipt_gl_date_to    ar_receivable_applications.gl_date%type;
      l_receipt_method_id     ar_cash_receipts.receipt_method_id%type;

   -- Bug 1981698 Changed the definition for l_customer_number.

      l_customer_number       hz_cust_accounts.account_number%type;
      l_customer_id    	      hz_cust_accounts.cust_account_id%type;
      l_receivable_trx_id     ar_receivable_applications.receivables_trx_id%type;
      l_apply_date   	      ar_cash_receipts.receipt_date%type;
      l_gl_date               ar_cash_receipts.receipt_date%type;
      l_receipt_currency_code ar_cash_receipts.currency_code%type;
      l_receipt_number	      ar_cash_receipts.receipt_number%type;
      l_comments    	      ar_receivable_applications.comments%type;
      l_user_id               NUMBER;
      l_application_ref_type ar_receivable_applications.application_ref_type%TYPE;
      l_application_ref_id   ar_receivable_applications.application_ref_id%TYPE;
      l_application_ref_num  ar_receivable_applications.application_ref_num%TYPE;
      l_secondary_application_ref_id ar_receivable_applications.secondary_application_ref_id%TYPE;
      l_receivable_application_id NUMBER;

      l_unapp_amount_balance    NUMBER := 0;
      l_written_off_amount      ar_receivable_applications.amount_applied%TYPE;
      l_tot_write_off_amount    ar_receivable_applications.amount_applied%TYPE;
      l_min_wrt_off_amount      ar_receivable_applications.amount_applied%TYPE;
      l_max_wrt_off_amount      ar_receivable_applications.amount_applied%TYPE;
      l_tot_writeoff_amt_func   ar_receivable_applications.amount_applied%TYPE;
      l_exchange_rate           ar_cash_receipts.exchange_rate%TYPE;
      l_actual_writeoff_amount  NUMBER := 0;
      l_rcpt_percent_amount     NUMBER;

      l_amount_to               NUMBER;
      l_amount_from             NUMBER;
      l_functional_currency     ar_cash_receipts.currency_code%TYPE;
      l_request_id              NUMBER;
      l_number_of_records_writtenoff NUMBER := 0;

      /*5444407*/
      l_batch_id		ar_batches.batch_id%type;
      i 			NUMBER;
      l_cnt 			NUMBER;

    --Declare Cursor
      CURSOR writeoff_cur(c_receipt_currency_code   ar_cash_receipts.currency_code%type,
             c_receipt_date_from       ar_cash_receipts.receipt_date%type,
             c_receipt_date_to         ar_cash_receipts.receipt_date%type,
             c_receipt_gl_date_from    ar_receivable_applications.gl_date%type,
             c_receipt_gl_date_to      ar_receivable_applications.gl_date%type,
             c_receipt_method_id       ar_cash_receipts.receipt_method_id%type,
           --Bug 1981698 Changed c_customer_number to c_customer_id.
             c_customer_id             ar_cash_receipts.pay_from_customer%type,
             c_receipt_number          ar_cash_receipts.receipt_number%type,
             c_apply_date              ar_cash_receipts.receipt_date%type,
             c_gl_date                 ar_cash_receipts.receipt_date%type,
             c_user_id                 ar_receivable_applications.created_by%Type
             ) IS

      /*5444407*/
      SELECT acr.cash_receipt_id cash_receipt_id,
             acr.receipt_number receipt_number,
             acr.amount,
             NVL(acr.exchange_rate,1) exchange_rate,
             SUM(DECODE(app.status,'UNAPP',NVL(app.amount_applied_from,app.amount_applied),0)) unapplied_amount,
             SUM(DECODE(app.status,'ACTIVITY',DECODE(applied_payment_schedule_id,-3,
                 DECODE(app.created_by,c_user_id,
                 NVL(app.amount_applied_from,app.amount_applied),0),0),0)) written_off_amount,
		crh.batch_id batch_id
      FROM   ar_payment_schedules ps,
             ar_cash_receipts acr,
	     ar_cash_receipt_history crh,
             ar_receivable_applications app
      WHERE  ps.invoice_currency_code   =   c_receipt_currency_code
      AND    acr.cash_receipt_id =   ps.cash_receipt_id
      AND    acr.cash_receipt_id =   crh.cash_receipt_id
      AND    crh.current_record_flag = 'Y'
      AND    acr.cash_receipt_id =   app.cash_receipt_id
      AND    ps.status           =   'OP'
      AND    ps.class            =   'PMT'
      AND    ps.trx_date BETWEEN NVL(c_receipt_date_from,ps.trx_date)
                              AND     NVL(c_receipt_date_to,ps.trx_date)
      AND    ps.gl_date       BETWEEN NVL(c_receipt_gl_date_from,ps.gl_date)
                              AND NVL(c_receipt_gl_date_to,ps.gl_date)
      AND    ps.trx_date <= c_apply_date
      AND    ps.gl_date       <= c_gl_date
      AND    acr.receipt_method_id = NVL(c_receipt_method_id,acr.receipt_method_id)
      AND    acr.pay_from_customer = NVL(c_customer_id,acr.pay_from_customer)
      AND    acr.receipt_number    = NVL(c_receipt_number,acr.receipt_number)
      group  by acr.cash_receipt_id,acr.receipt_number,acr.amount,
	acr.exchange_rate,crh.batch_id;

BEGIN
     arp_util.debug('arp_process_writeoff.creare_receipt_writeoff()+');

     arp_util.debug('p_receipt curreny '||p_receipt_currency_code);
     arp_util.debug('p_unapp_amount '||p_unapp_amount);
     arp_util.debug('p_unapp_amount_percent '||p_unapp_amount_percent);
     arp_util.debug('p_receipt_date_from '||p_receipt_date_from);
     arp_util.debug('p_receipt_date_to '||p_receipt_date_to);
     arp_util.debug('p_receipt_gl_date_from '||p_receipt_gl_date_from);
     arp_util.debug('p_receipt_gl_date_to '||p_receipt_gl_date_to);
     arp_util.debug('p_receipt_method_id '||p_receipt_method_id);
     arp_util.debug('p_customer_number '||p_customer_number);
     arp_util.debug('p_receivable_trx_id '||p_receivable_trx_id);
     arp_util.debug('p_apply_date '||p_apply_date);
     arp_util.debug('p_gl_date '||p_gl_date);
     arp_util.debug('p_receipt_number '||p_receipt_number);
     arp_util.debug('p_comments '||p_comments);

   --Convert the IN variables
     l_unapp_amount          := FND_NUMBER.CANONICAL_TO_NUMBER(p_unapp_amount);
     l_unapp_amount_percent  := FND_NUMBER.CANONICAL_TO_NUMBER(p_unapp_amount_percent);
     l_receipt_date_from     := FND_DATE.CANONICAL_TO_DATE(p_receipt_date_from);
     l_receipt_date_to       := FND_DATE.CANONICAL_TO_DATE(p_receipt_date_to);
     l_receipt_gl_date_from  := FND_DATE.CANONICAL_TO_DATE(p_receipt_gl_date_from);
     l_receipt_gl_date_to    := FND_DATE.CANONICAL_TO_DATE(p_receipt_gl_date_to);
     l_receipt_method_id     := FND_NUMBER.CANONICAL_TO_NUMBER(p_receipt_method_id);
     l_customer_number       := p_customer_number;
     l_receivable_trx_id     := FND_NUMBER.CANONICAL_TO_NUMBER(p_receivable_trx_id) ;
     l_apply_date   	     := FND_DATE.CANONICAL_TO_DATE(p_apply_date);
     l_gl_date               := FND_DATE.CANONICAL_TO_DATE(p_gl_date);

     l_receipt_currency_code := p_receipt_currency_code;
     l_receipt_number	     := p_receipt_number;
     l_comments    	     := p_comments;
     l_user_id    	     := arp_global.user_id;
     l_request_id            := fnd_global.conc_request_id;


   --Intialize the out NOCOPY variable

     l_return_status :=  FND_API.G_RET_STS_SUCCESS;

   --Get the approval limits of the user
     BEGIN
          SELECT NVL(amount_from,0),
                 NVL(amount_to,0)
          INTO   l_amount_from,
                 l_amount_to
          FROM   ar_approval_user_limits
          WHERE  currency_code = l_receipt_currency_code
          AND    user_id = arp_global.user_id
          AND    document_type ='WRTOFF';
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
          l_amount_from := 0;
          l_amount_to   := 0;
     END;

    /* Bug fix 3385020
       The validations should be done only if both the amount and percentage are
       not zero or NULL */
   IF l_unapp_amount_percent = 0
      OR l_unapp_amount = 0
      OR (l_unapp_amount_percent IS NULL AND l_unapp_amount IS NULL) THEN
        null;
   ELSE
   --Get the customer id for the customer number
     IF p_customer_number IS NOT NULL
     THEN
        l_customer_id := to_number(arp_util.Get_Id( 'CUSTOMER_NUMBER',
                                            l_customer_number,
                                            l_return_status));
        IF l_customer_id IS NULL THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NUM_INVALID');
           FND_MSG_PUB.Add;
           l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
     END IF;

     arp_util.debug('Customer ID '||to_char(l_customer_id));

     arp_util.debug('User Approval Limits From : '||to_char(l_amount_from)||
                                         'To   : '||to_char(l_amount_to));


   --Get the functional currency
     l_functional_currency := arp_global.functional_currency;
     l_min_wrt_off_amount := arp_global.sysparam.min_wrtoff_amount;
     arp_util.debug('Minimum write-off limit :'||to_char(l_min_wrt_off_amount));
     l_max_wrt_off_amount := arp_global.sysparam.max_wrtoff_amount;
     arp_util.debug('Maximum write-off limit :'||to_char(l_max_wrt_off_amount));

     IF l_max_wrt_off_amount IS NULL THEN
        fnd_message.set_name ('AR','AR_SYSTEM_WR_NO_LIMIT_SET');
        app_exception.raise_exception;
     END IF;

     arp_util.debug('Functional Currency :'||l_functional_currency);

     FOR writeoff_rec IN writeoff_cur(l_receipt_currency_code,
                         l_receipt_date_from,
                         l_receipt_date_to,
                         l_receipt_gl_date_from,
                         l_receipt_gl_date_to,
                         l_receipt_method_id,
                         l_customer_id,
                         l_receipt_number,
                         l_apply_date,
                         l_gl_date,
                         l_user_id
                         )
     LOOP

      IF writeoff_rec.unapplied_amount > 0 THEN

         --Get Unapplied amount on the receipt
           l_unapp_amount_balance := writeoff_rec.unapplied_amount ;

	 --Get written off amount by the use logged in.
           l_written_off_amount := writeoff_rec.written_off_amount;

           l_tot_write_off_amount := l_written_off_amount + l_unapp_amount_balance;
           -- Bug 3136127 - moved check on user limits to before system checks
           -- to prevent system limit check being overridden

           IF  (l_tot_write_off_amount >= l_amount_from)
           AND (l_tot_write_off_amount <= l_amount_to) THEN
               l_actual_writeoff_amount := NVL(l_unapp_amount_balance,0);
           ELSE
               l_actual_writeoff_amount := 0;
           END IF;

           -- Bug 3136127 - included checks on minimum system limit
   	   IF l_tot_write_off_amount < 0 THEN
              IF l_min_wrt_off_amount IS NULL THEN
                 fnd_message.set_name ('AR','AR_SYSTEM_WR_NO_LIMIT_SET');
                 app_exception.raise_exception;
              END IF;
           END IF;

           IF l_functional_currency <> l_receipt_currency_code THEN

              l_exchange_rate := writeoff_rec.exchange_rate;

              l_tot_writeoff_amt_func := arpcurr.functional_amount(
	                          l_tot_write_off_amount,
                                  l_functional_currency,
                                  l_exchange_rate,
                                  arp_global.base_precision,
                                  arp_global.base_min_acc_unit);

       	      IF (NVL(l_tot_writeoff_amt_func,0)) > l_max_wrt_off_amount THEN
                 l_actual_writeoff_amount := 0;
              END IF;
       	      IF (NVL(l_tot_writeoff_amt_func,0) < 0) THEN
       	        IF (NVL(l_tot_writeoff_amt_func,0) < l_min_wrt_off_amount) THEN
                   l_actual_writeoff_amount := 0;
                END IF;
              END IF;
           ELSE
              IF (l_tot_write_off_amount > l_max_wrt_off_amount) THEN
                 l_actual_writeoff_amount := 0;
              END IF;
       	      IF (l_tot_write_off_amount < 0) THEN
       	        IF (l_tot_write_off_amount < l_min_wrt_off_amount) THEN
                   l_actual_writeoff_amount := 0;
                END IF;
              END IF;
           END IF;

         --If the write-off amount total including the amount already written-off previously
         --for this receipt, is not within the limit then this receipt can't be written off
         --So return 0. Otherwise, return the balance unapplied amount.

        --Check whether the write-off amount is less than the passed amount
        /* Bug fix 3385020 : The comparison should be made only if the amount is passed */
          IF l_unapp_amount IS NOT NULL  and  l_actual_writeoff_amount > l_unapp_amount  THEN
              l_actual_writeoff_amount := 0;
          END IF;

        --Check whether the write-off amount is less than the passed amount
         /* Bug fix 3385020 : Changed the condition to check for NULL value alone */
          IF l_unapp_amount_percent IS NOT NULL THEN
             l_rcpt_percent_amount := ((NVL(writeoff_rec.amount,0) * l_unapp_amount_percent)/100);

             IF  l_actual_writeoff_amount > NVL(l_rcpt_percent_amount,0)  THEN
                 l_actual_writeoff_amount := 0;
             END IF;
          END IF;

          IF l_actual_writeoff_amount <> 0 THEN

          /*5444407*/
	  IF NOT (arp_process_writeoff.gt_rec_wrt_off_type.EXISTS(writeoff_rec.batch_id)) AND
		writeoff_rec.batch_id is not null THEN
		arp_process_writeoff.gt_rec_wrt_off_type(writeoff_rec.batch_id).batch_id:=writeoff_rec.batch_id;
	  END IF;

           --Calling Activity_application Procedure
             ar_receipt_api_pub.activity_application(
               p_api_version                  => 1.0                          ,
               x_return_status                => l_return_status              ,
               x_msg_count                    => l_msg_count                  ,
               x_msg_data                     => l_msg_data                   ,
               p_cash_receipt_id              => writeoff_rec.cash_receipt_id ,
               p_receipt_number               => '',
               p_amount_applied               => l_actual_writeoff_amount     ,
               p_applied_payment_schedule_id  => -3                           ,
               p_receivables_trx_id           => l_receivable_trx_id          ,
               p_apply_date                   => l_apply_date                 ,
               p_apply_gl_date                => l_gl_date                    ,
               p_comments                     => l_comments                   ,
               p_application_ref_type         => l_application_ref_type       ,
               p_application_ref_id           => l_application_ref_id         ,
               p_application_ref_num          => l_application_ref_num        ,
               p_secondary_application_ref_id => l_secondary_application_ref_id,
               p_receivable_application_id    => l_receivable_application_id,
	       p_called_from		      => 'WRITEOFF'
              );


              l_number_of_records_writtenoff := l_number_of_records_writtenoff + 1;

          END IF;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS )
          THEN

            arp_util.debug('arp_process_writeoff - Failed for Receipt : '||
                            writeoff_rec.receipt_number );
            arp_util.debug('p_return_status : ' || l_return_status);
            arp_util.debug('p_msg_count     : ' || l_msg_count);
            arp_util.debug('p_msg_data      : ' || l_msg_data);

           --Bug 1788596 - begin changes

             IF l_msg_count  = 1 THEN

                  FND_MESSAGE.SET_NAME ('AR', 'GENERIC_MESSAGE');
                  FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_msg_data);
                  app_exception.raise_exception;
             ELSIF l_msg_count > 1 THEN
              --retrive only first messages from the stack and display it .

                   l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);

                   FND_MESSAGE.SET_NAME ('AR', 'GENERIC_MESSAGE');
                   FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_msg_data);
                   app_exception.raise_exception;

             END IF;

        END IF;

      END IF; --if unapplied amount > 0

     END LOOP;

     /*5444407*/
     IF arp_process_writeoff.gt_rec_wrt_off_type.COUNT <> 0 THEN
	l_cnt:=arp_process_writeoff.gt_rec_wrt_off_type.COUNT;
        arp_util.debug(' Count of records in PL/SQL table :' || to_char(l_cnt));
        i := arp_process_writeoff.gt_rec_wrt_off_type.FIRST;
        WHILE i IS NOT NULL LOOP
	l_batch_id:=arp_process_writeoff.gt_rec_wrt_off_type(i).batch_id;
	arp_rw_batches_check_pkg.update_batch_status(l_batch_id);
        i:=arp_process_writeoff.gt_rec_wrt_off_type.NEXT(i);
        END LOOP;
     END IF;

     IF l_number_of_records_writtenoff > 0 THEN
      --Since report submission is another concurrent program,
      --commit the records processed before submitting the report

        COMMIT;

     --for 1644863
       arp_process_writeoff.submit_report(l_receipt_currency_code,l_apply_date,l_gl_date);
     END IF;
   END IF;
     arp_util.debug('Total Number of Receipts written off :'||to_char(l_number_of_records_writtenoff));

     arp_util.debug('arp_process_writeoff.creare_receipt_writeoff()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:arp_process_writeoff.cretre_receipt_writeoff()'||SQLERRM);
     RAISE;

END;
/*========================================================================
 | PUBLIC FUNCTIONS unapplied_amount
 |
 | DESCRIPTION
 |      This procedure calculates the unapplied amount for the given receipt
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      arp_process_writeoff.create_receipt_writeoff()
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 | PARAMETERS
 |      p_cash_receipt_id     IN    Cash Receipt ID of the receipt
 |      p_request_id          IN    Concurrent Request Id
 |
 | RETURNS    :  unapplied_amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |     This functiona is also called from the Report ARXRCWRT.
 |     When request id is passed, then this functions returns the
 |     unapplied amount for the particular request id.When request id is not
 |     passed then it return the unapplied amount for the whole receipt.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-AUG-00             S.Nambiar         Created
 | 19-MAY-01             S.Nambiar         Bug 1784778 - UNPPP sum should not
 |                                         include OTHER ACC paired UNAPP
 | 01-JUN-00             S.Nambiar         Bug 1809395 - Write-off should check
 |                                         the system level limit setup.
 | 01-JUN-00             S.Nambiar         Bug 1788614 - auto Write-off should check
 |                                         how much the user has already written off
 |                                         on the receipt.
 +===========================================================================*/
FUNCTION unapplied_amount(p_cash_receipt_id IN NUMBER,
                          p_currency_code   IN ar_cash_receipts.currency_code%TYPE,
                          p_user_id         IN ar_approval_user_limits.user_id%TYPE,
                          p_request_id      IN NUMBER DEFAULT NULL, /*5444407*/
			  p_exchange_rate   IN ar_cash_receipts.exchange_rate%TYPE
					default NULL,
			  p_amount_from     IN NUMBER default null,
			  p_amount_to       IN NUMBER default null)
RETURN number IS

l_unapp_amount_balance    NUMBER := 0;
l_written_off_amount      ar_receivable_applications.amount_applied%TYPE;
l_tot_write_off_amount    ar_receivable_applications.amount_applied%TYPE;
l_max_wrt_off_amount      ar_receivable_applications.amount_applied%TYPE;
l_tot_writeoff_amt_func   ar_receivable_applications.amount_applied%TYPE;
l_exchange_rate           ar_cash_receipts.exchange_rate%TYPE;

l_amount_to               NUMBER;
l_amount_from             NUMBER;
l_functional_currency     ar_cash_receipts.currency_code%TYPE;

BEGIN
  arp_util.debug('arp_process_writeoff.unapplied_amount()+');
  l_functional_currency := arp_global.functional_currency;

  IF nvl(p_request_id,0) = 0
   THEN
    SELECT SUM(DECODE(ra.status,'UNAPP',NVL(ra.amount_applied, 0),0)) unapplied_amount,
	   SUM(decode(ra.status,'ACTIVITY',decode(ra.applied_payment_schedule_id,-3,
    decode(ra.created_by,p_user_id,NVL(ra.amount_applied,0),0),0),0)) written_off_amount
    INTO   l_unapp_amount_balance,l_written_off_amount
    FROM   ar_receivable_applications ra
    WHERE  ra.cash_receipt_id = p_cash_receipt_id
    AND    ra.status          in ('UNAPP','ACTIVITY');

  --Check how much amount has been written-off by this user for this receipt
/* Bug 2479793 : The index on applied_payment_schedule_id is supressed as
   CBO sometimes find this better than index on cash_receipt_id */
    /*SELECT NVL(SUM(NVL(ra.amount_applied, 0)),0) written_off_amount
    INTO   l_written_off_amount
    FROM   ar_receivable_applications ra
    WHERE  ra.cash_receipt_id = p_cash_receipt_id
    AND    ra.status = 'ACTIVITY'
    AND    ra.applied_payment_schedule_id + 0 = -3
    AND    ra.created_by = p_user_id;*/

  --Get the approval limits of the user
    l_amount_from := p_amount_from;
    l_amount_to   := p_amount_to;
   If l_amount_from is null and l_amount_to is null then
   BEGIN
          SELECT NVL(amount_from,0),
                 NVL(amount_to,0)
          INTO   l_amount_from,
                 l_amount_to
          FROM   ar_approval_user_limits
          WHERE  currency_code = p_currency_code
          AND    user_id = p_user_id
          AND    document_type ='WRTOFF';
    EXCEPTION
          WHEN NO_DATA_FOUND THEN
          l_amount_from := 0;
          l_amount_to   := 0;
    END;
   end if;

  --In case of cross currency,the write-off amount should not exceed the maximum
  --write-off limit set at the system level. For that, we need to take the exchange
  --rate from the receipt and calculate the write-off amount and validate with
  --system limit setup.

    /*5444407*/
    l_max_wrt_off_amount:=arp_global.sysparam.max_wrtoff_amount;

    l_tot_write_off_amount := l_written_off_amount + l_unapp_amount_balance;

    IF l_functional_currency <> p_currency_code THEN

     /*5444407*/
     IF p_exchange_rate is null then
       SELECT nvl(exchange_rate,1)
       INTO   l_exchange_rate
       FROM   ar_cash_receipts
       WHERE  cash_receipt_id = p_cash_receipt_id;
     END IF;

       l_tot_writeoff_amt_func := arpcurr.functional_amount(
	                          l_tot_write_off_amount,
                                  l_functional_currency,
                                  l_exchange_rate,
                                  arp_global.base_precision,
                                  arp_global.base_min_acc_unit);

       IF (NVL(l_tot_writeoff_amt_func,0)) > l_max_wrt_off_amount THEN
          RETURN (0);
       END IF;
    ELSE
       IF (l_tot_write_off_amount > l_max_wrt_off_amount) THEN
          RETURN (0);
       END IF;

    END IF;

  --If the write-off amount total including the amount already written-off previously
  --for this receipt, is not within the limit then this receipt can't be written off
  --So return 0. Otherwise, return the balance unapplied amount.

    IF  (l_tot_write_off_amount >= l_amount_from)
    AND (l_tot_write_off_amount <= l_amount_to) THEN
    	RETURN (l_unapp_amount_balance);
    ELSE
        RETURN (0);
    END IF;

  ELSE
    SELECT NVL(SUM(NVL(ra.amount_applied,0)),10) l_unapplied_amount
    INTO   l_unapp_amount_balance
    FROM   ar_receivable_applications ra
    WHERE  ra.cash_receipt_id = p_cash_receipt_id
    AND    status = 'ACTIVITY'
    AND    ra.request_id = p_request_id;

   RETURN (l_unapp_amount_balance);
  END IF;

   arp_util.debug('arp_process_writeoff.unapplied_amount()+');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION :arp_process_writeoff.unapplied_amount()'
                   ||SQLERRM);
     RETURN (0);
END;
/*========================================================================
 | PUBLIC FUNCTIONS applied_amount
 |
 | DESCRIPTION
 |      This procedure calculates the applied amount for the given receipt
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      arp_process_writeoff.create_receipt_writeoff()
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 | PARAMETERS
 |      p_cash_receipt_id     IN    Cash Receipt ID of the receipt
 |      p_request_id          IN    Concurrent Request Id
 |
 | RETURNS    :  applied_amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |     This functiona is also called from the Report ARXRCWRT.
 |     When request id is passed, then this functions returns the
 |     applied amount for the particular request id.When request id is not
 |     passed then it return the applied amount for the whole receipt.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-AUG-00             S.Nambiar         Created
 +===========================================================================*/
FUNCTION applied_amount(p_cash_receipt_id IN NUMBER,
                        p_request_id      IN NUMBER DEFAULT 0)
RETURN number IS

l_applied_amount  NUMBER;

BEGIN
   arp_util.debug('arp_process_writeoff.applied_amount()+');

   IF NVL(p_request_id,0) <> 0
   THEN
     --Sum of the applied amount excluding the current one with the request id
     SELECT
        SUM(DECODE(ra.status,
                   'APP',DECODE(ra.confirmed_flag,
                        'N', 0,
                         NVL(nvl(ra.amount_applied_from, ra.amount_applied),0)),
                   'ACTIVITY',DECODE(ra.applied_payment_schedule_id,
                       -2,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                       -3,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                       -5,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                                     0)
                   ,0)) applied_amount

    INTO l_applied_amount
    FROM
        ar_receivable_applications ra
    WHERE ra.cash_receipt_id = p_cash_receipt_id
    AND   ra.request_id <> p_request_id;
  ELSE
     --Sum of the all the applied amounts for a receipt
     SELECT
        SUM(DECODE(ra.status,
                   'APP',DECODE(ra.confirmed_flag,
                        'N', 0,
                        NVL(nvl(ra.amount_applied_from, ra.amount_applied),0)),
                   'ACTIVITY',DECODE(ra.applied_payment_schedule_id,
                      -2,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                      -3,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                      -5,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                        0)
                   ,0)) applied_amount

    INTO l_applied_amount
    FROM
        ar_receivable_applications ra
    WHERE ra.cash_receipt_id = p_cash_receipt_id;
  END IF;

    arp_util.debug('arp_process_writeoff.applied_amount()-');
    RETURN (l_applied_amount);

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION :arp_process_writeoff.applied_amount()'||SQLERRM);
     RETURN (0);

END;

/*========================================================================
 | PUBLIC FUNCTIONS on_account_amount
 |
 | DESCRIPTION
 |      This procedure calculates the on_account_amount for the given
 |      receipt
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 | PARAMETERS
 |      p_cash_receipt_id     IN    Cash Receipt ID of the receipt
 |
 | RETURNS    :  applied_amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |     This functiona is called from the Report ARXRCWRT.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-AUG-00             S.Nambiar         Created
 +=======================================================================*/
FUNCTION on_account_amount(p_cash_receipt_id IN NUMBER)
RETURN number IS

l_on_account_amount  NUMBER;

BEGIN
    arp_util.debug('arp_process_writeoff.on_account_amount()+');

    SELECT
        SUM(DECODE(ra.status,'ACC', NVL(ra.amount_applied, 0),
         0)) on_account_amount
    INTO l_on_account_amount
    FROM
        ar_receivable_applications ra
    WHERE ra.cash_receipt_id = p_cash_receipt_id;

    arp_util.debug('arp_process_writeoff.on_account_amount()-');

    RETURN (l_on_account_amount);
EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('arp_process_writeoff.on_account_amount() '||SQLERRM);
     RETURN (0);

END;

/*========================================================================
 | PUBLIC FUNCTIONS balancing_segment
 |
 | DESCRIPTION
 |    This utility returns the balancing segment for a code combination id
 |    passed
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      NONE
 | PARAMETERS
 |      p_code_combination_id     IN    Code combination ID
 |
 | RETURNS    :  Balancing_segment value
 |
 | KNOWN ISSUES
 |
 | NOTES
 |     This functiona is called from the Rxi:Other Applications Report.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-AUG-00             S.Nambiar         Created
 +========================================================================*/
FUNCTION balancing_segment(p_code_combination_id IN NUMBER)
RETURN VARCHAR2 IS

l_balancing_segment  varchar2(25);
l_str                varchar2(500);
l_segment_value      varchar2(25);

BEGIN

   arp_util.debug('arp_process_writeoff.balancing_segment()+');

   SELECT fa_rx_flex_pkg.flex_sql(101,'GL#',chart_of_accounts_id,NULL,
          'SELECT','GL_BALANCING')
   INTO   l_balancing_segment
   FROM   gl_code_combinations
   WHERE  code_combination_id= p_code_combination_id;

   l_str := 'SELECT '||l_balancing_segment||' INTO :bnd_segment_value
             FROM gl_code_combinations where code_combination_id=:bind_ccid';

   EXECUTE IMMEDIATE l_str INTO l_segment_value USING p_code_combination_id;

   arp_util.debug('arp_process_writeoff.balancing_segment()-');

   RETURN l_segment_value;

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('arp_process_writeoff.balancing_segment() '||SQLERRM);
     RETURN (NULL);
END;
BEGIN
arp_global.init_global;
END ARP_PROCESS_WRITEOFF;

/
