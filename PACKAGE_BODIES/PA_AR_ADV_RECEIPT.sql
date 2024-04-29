--------------------------------------------------------
--  DDL for Package Body PA_AR_ADV_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AR_ADV_RECEIPT" AS
--$Header: PAGARADB.pls 120.4 2006/12/20 09:15:06 rkchoudh noship $


PROCEDURE 	Apply_receipt(
			   p_receipt_id         IN     NUMBER,
                           p_gl_date            IN     DATE,
                           p_agreement_id       IN     NUMBER,
                           p_agreement_number   IN     VARCHAR2,
                           x_payment_set_id     IN OUT NOCOPY   NUMBER,
                           x_return_status      IN OUT NOCOPY   VARCHAR2,
                           x_msg_count          IN OUT NOCOPY   NUMBER,
                           x_msg_data           IN OUT NOCOPY   VARCHAR2 ) is
CURSOR APPLY_cur IS
 select app.amount_applied,
        app.receivable_application_id
   from ar_receivable_applications app
  where app.cash_receipt_id = p_receipt_id
    and app.STATUS ='ACC'
    and app.display='Y';
l_api_version     		NUMBER := 1.0;
l_applied_payment_schedule_id   NUMBER := -7;
l_payment_set_id 		NUMBER;
l_receivable_application_id     NUMBER(15);
l_amount_applied                NUMBER;
l_receivable_trx_id 	  	NUMBER(15);
l_application_ref_type          VARCHAR2(30):= 'PROJECTS AGREEMENT';
l_application_ref_id    	NUMBER(15)  := p_agreement_id;
l_application_ref_num  		VARCHAR2(30):= p_agreement_number;
l_secondary_application_ref_id	NUMBER(15);
l_rec_apps_id     		NUMBER(15) ;
l_return_status   		VARCHAR2(30);
l_msg_count       		NUMBER;
l_msg_data        		VARCHAR2(30);
l_position                      VARCHAR2(2);
AP_ERROR 			exception;

BEGIN

l_return_status := 'S';
l_msg_count     := NULL;
l_msg_data      := NULL;

l_position := '1';
ar_receipt_lib_pvt.default_prepay_cc_activity(p_appl_type         => 'PREPAYMENT',
                                              p_receivable_trx_id => l_receivable_trx_id,
                                              p_return_status     => l_return_status);
IF l_return_status <> 'S' then
       l_msg_data := 'PA_RECV_ACTY_CHECK';
       l_msg_count:= 1;
       RAISE AP_ERROR;
END IF;

l_position := '2';
IF x_payment_set_id is null then
    select ar_receivable_applications_s1.nextval into l_payment_set_id  from dual;
ELSE
    l_payment_set_id := x_payment_set_id;
END IF;

l_position := '3';
FOR i in APPLY_cur
    loop
      l_receivable_application_id := i.receivable_application_id;
      l_amount_applied  := i.amount_applied;

l_position := '4';
     -- Calling the AR package to Unapply the on account ammount
      	ar_receipt_api_pub.unapply_on_account(P_API_VERSION     	  => l_api_version,
    	                                      p_cash_receipt_id 	  => p_receipt_id,
					      p_receivable_application_id => l_receivable_application_id,
					      p_reversal_gl_date	  => p_gl_date,
					      X_return_status 		  => l_return_status,
					      X_msg_count       	  => l_msg_count,
					      X_msg_data        	  => l_msg_data
					      );
	IF l_return_status <> 'S' then
	   RAISE AP_ERROR;
        END IF;

l_position := '5';
     -- Calling AR package to apply the Amount to prepayment
	ar_receipt_api_pub.apply_other_account(P_API_VERSION  		      => l_api_version,
        	                               p_cash_receipt_id 	      => p_receipt_id,
					       p_receivable_application_id    => l_receivable_application_id,
					       X_return_status   	      => l_return_status,
				               X_msg_count       	      => l_msg_count,
					       X_msg_data   		      => l_msg_data,
					       P_APPLIED_PAYMENT_SCHEDULE_ID  => l_applied_payment_schedule_id,
--                                               P_APPLICATION_REF_TYPE         => l_application_ref_type,
					       P_APPLICATION_REF_ID 	      => l_application_ref_id,
					       P_application_ref_num          => l_application_ref_num,
					       P_secondary_application_ref_id => l_secondary_application_ref_id,
			                       P_payment_set_id 	      => l_payment_set_id,
					       P_RECEIVABLES_TRX_ID 	      => l_receivable_trx_id,
					       P_AMOUNT_APPLIED               => l_amount_applied
					      );
	IF l_return_status <> 'S' then
                RAISE AP_ERROR;
	END IF;

       exit when APPLY_cur%notfound;
   end loop;

l_position := '6';
 x_payment_set_id := l_payment_set_id;

-- HANDLE EXCEPTIONS
   EXCEPTION
        WHEN AP_ERROR THEN
             x_return_status   := l_return_status;
             x_msg_count       := l_msg_count;
             x_msg_data        := l_msg_data;
        WHEN OTHERS THEN
             RAISE;

END Apply_receipt;

PROCEDURE    Unapply_receipt(
                           p_receipt_id         IN     NUMBER,
			   p_payment_set_id     IN     NUMBER,
                           x_return_status      IN OUT NOCOPY   VARCHAR2,
                           x_msg_count          IN OUT NOCOPY   NUMBER,
                           x_msg_data           IN OUT NOCOPY   VARCHAR2) is

CURSOR UNAPPLY_recpt_cur IS
 select app.amount_applied,
        app.receivable_application_id,
        app.cash_receipt_id
   from ar_receivable_applications app
  where app.cash_receipt_id = p_receipt_id
    and app.STATUS ='OTHER ACC'
    and app.display='Y';


CURSOR UNAPPLY_pay_cur IS
 select app.amount_applied,
        app.receivable_application_id,
	app.cash_receipt_id
   from ar_receivable_applications app
  where app.STATUS ='OTHER ACC'
    and app.display='Y'
    and app.payment_set_id = p_payment_set_id;

l_api_version                   NUMBER := 1.0;
l_rec_app_id                    NUMBER(15);
l_amount_applied                NUMBER;
l_cash_receipt_id               NUMBER;
l_return_status                 VARCHAR2(30);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(30);
l_position                      VARCHAR2(2);
AP_ERROR                        exception;

BEGIN

l_return_status := 'S';
l_msg_count     := NULL;
l_msg_data      := NULL;
l_position      := '0';

 IF p_receipt_id IS NOT NULL THEN
  OPEN UNAPPLY_recpt_cur;
 ELSE
  OPEN UNAPPLY_pay_cur;
 END IF;

 l_position := '1';

 LOOP
   IF p_receipt_id IS NOT NULL THEN

       FETCH UNAPPLY_recpt_cur INTO l_amount_applied,
                                    l_rec_app_id,
				    l_cash_receipt_id;

       EXIT WHEN UNAPPLY_recpt_cur%NOTFOUND;

   ELSE

       FETCH UNAPPLY_pay_cur INTO   l_amount_applied,
                                    l_rec_app_id,
				    l_cash_receipt_id;

       EXIT WHEN UNAPPLY_pay_cur%NOTFOUND;

   END IF;


   l_position := '2';

   -- Calling the AR package to Unapply the prepayment Amount
   ar_receipt_api_pub.unapply_other_account(
                                P_API_VERSION               => l_api_version,
        	                p_cash_receipt_id           => l_cash_receipt_id,
                        	p_receivable_application_id => l_rec_app_id,
    		                X_return_status             => l_return_status,
				X_msg_count                 => l_msg_count,
			        X_msg_data                  => l_msg_data);

        IF l_return_status <> 'S' then
                RAISE AP_ERROR;
        END IF;

   l_position := '3';

   -- Calling the AR package to Apply the On Account Amount
   ar_receipt_api_pub.apply_on_account(P_API_VERSION      => l_api_version,
      	                               p_cash_receipt_id  => l_cash_receipt_id,
  		        	       X_return_status    => l_return_status,
			               X_msg_count        => l_msg_count,
				       X_msg_data         => l_msg_data,
				       P_AMOUNT_APPLIED   => l_amount_applied);

	IF l_return_status <> 'S' then
                RAISE AP_ERROR;
        END IF;

   l_position := '4';

 END LOOP;

 l_position := '5';

 IF p_receipt_id IS NOT NULL THEN
  CLOSE UNAPPLY_recpt_cur;
 ELSE
  CLOSE UNAPPLY_pay_cur;
 END IF;

 l_position := '6';


-- HANDLE EXCEPTIONS
   EXCEPTION
        WHEN AP_ERROR THEN
             x_return_status   := l_return_status;
             x_msg_count       := l_msg_count;
             x_msg_data        := l_msg_data;
        WHEN OTHERS THEN
             RAISE;

END Unapply_receipt;

END PA_AR_ADV_RECEIPT;

/
