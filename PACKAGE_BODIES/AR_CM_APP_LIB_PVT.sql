--------------------------------------------------------
--  DDL for Package Body AR_CM_APP_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CM_APP_LIB_PVT" AS
/* $Header: ARXCMALB.pls 120.2 2005/07/22 15:40:30 naneja ship $           */

G_PKG_NAME   CONSTANT VARCHAR2(30)      := 'AR_CM_APP_LIB_PVT';

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Default_customer_trx_id(
                          p_customer_trx_id IN OUT NOCOPY NUMBER,
                          p_trx_number  IN VARCHAR,
                          p_return_status OUT NOCOPY VARCHAR2
                           ) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_customer_trx_id ()+');
  END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_customer_trx_id IS NULL THEN
     IF  p_trx_number IS NOT NULL THEN
       BEGIN
         SELECT customer_trx_id
         INTO   p_customer_trx_id
         FROM   ra_customer_trx
         WHERE   trx_number = p_trx_number;
       EXCEPTION
         WHEN no_data_found THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_INVALID');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR ;
       END;
     END IF;

   ELSE

      IF p_trx_number IS NOT NULL
      THEN
       --give a warning message to indicate that the trx number
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_IGN');
         FND_MSG_PUB.Add;
       END IF;
     END IF;
   END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_customer_trx_id ()-');
 END IF;
EXCEPTION
  WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Default_customer_trx_id()', G_MSG_UERROR);
   END IF;
END Default_customer_trx_id;

PROCEDURE Default_gl_date(p_entered_date IN  DATE,
                          p_gl_date      OUT NOCOPY DATE,
                          p_validation_date IN DATE,
                          p_return_status OUT NOCOPY VARCHAR2) IS
l_error_message        VARCHAR2(128);
l_defaulting_rule_used VARCHAR2(100);
l_default_gl_date      DATE;
BEGIN
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_gl_date ()+');
  END IF;
    IF p_gl_date IS NULL THEN
     IF (arp_util.validate_and_default_gl_date(
                p_entered_date,
                NULL,
                p_validation_date,
                NULL,
                NULL,
                p_entered_date,
                NULL,
                NULL,
                'N',
                NULL,
                arp_global.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE)
     THEN
        p_gl_date := l_default_gl_date;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_gl_date: ' || 'Defaulted GL Date : '||to_char(p_gl_date,'DD-MON-YYYY'));
      END IF;
     ELSE
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_gl_date: ' || 'GL Date could not be defaulted ');
      END IF;
      -- Raise error message if failure in defaulting the gl_date
      FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_gl_date ()-');
  END IF;
END default_gl_date;

PROCEDURE Default_CM_Info(
              p_customer_trx_id             IN ra_customer_trx.customer_trx_id%TYPE,
	      p_cm_ps_id		    OUT NOCOPY NUMBER,
              p_cm_currency_code            OUT NOCOPY VARCHAR2,
              p_trx_date                    OUT NOCOPY DATE,
              p_cm_gl_date                  OUT NOCOPY DATE,
	      p_cm_unapp_amount		    OUT NOCOPY NUMBER,
	      p_cm_receipt_method_id	    OUT NOCOPY NUMBER,
              p_return_status               OUT NOCOPY VARCHAR2
                          ) IS

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_CM_Info ()+');
 END IF;
 p_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_customer_trx_id IS NOT NULL THEN

        SELECT
	   ps.payment_schedule_id
         , ps.invoice_currency_code
         , ct.trx_date
         , ps.gl_date
	 , (ps.amount_due_remaining * -1)
	 , ct.receipt_method_id
        INTO
	  p_cm_ps_id,
          p_cm_currency_code,
          p_trx_date,
          p_cm_gl_date ,
	  p_cm_unapp_amount,
	  p_cm_receipt_method_id
       FROM
           ra_customer_trx  ct
         , ar_payment_schedules  ps
      WHERE
           ps.class                    = 'CM'
       AND ct.customer_trx_id(+)       = ps.customer_trx_id
       AND ct.previous_customer_trx_id is null
       AND ct.customer_trx_id =  p_customer_trx_id
       ;

ELSE --case when p_customer_trx_id is null
  --no further validation done in the validation routines for customer_trx_id
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_NULL');
  FND_MSG_PUB.Add;
  p_return_status := FND_API.G_RET_STS_ERROR ;

END IF;

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Default_CM_Info ()-');
END IF;
EXCEPTION
  WHEN no_data_found THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_CM_Info : No data found ');
    END IF;

     p_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
     FND_MSG_PUB.ADD;

 WHEN others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Default_CM_Info: sqlerrm()');
    END IF;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    raise;
END Default_CM_Info;

PROCEDURE Default_activity_info(
                         p_customer_trx_id  IN NUMBER,
			 p_cm_ps_id OUT NOCOPY  NUMBER,
                         p_cm_currency_code OUT NOCOPY VARCHAR2,
                         p_cm_gl_date OUT NOCOPY DATE,
                         p_cm_unapp_amount OUT NOCOPY NUMBER,
			 p_cm_receipt_method_id OUT NOCOPY NUMBER,
                         p_trx_date OUT NOCOPY DATE,
                         p_amount_applied IN OUT NOCOPY NUMBER,
                         p_apply_date    IN OUT NOCOPY DATE,
                         p_apply_gl_date IN OUT NOCOPY DATE,
                         p_return_status  OUT NOCOPY VARCHAR2
                              ) IS
l_cm_amount   NUMBER;
l_cm_return_status  VARCHAR2(1);
l_gl_date_return_status  VARCHAR2(1);
l_trx_date   DATE;
l_amount_applied  NUMBER;
l_cm_unapp_amount NUMBER;

BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_activity_info ()+');
      END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    l_cm_return_status := FND_API.G_RET_STS_SUCCESS;
    l_gl_date_return_status := FND_API.G_RET_STS_SUCCESS;

    l_amount_applied := p_amount_applied;

    Default_CM_Info( p_customer_trx_id ,
		     p_cm_ps_id,
                     p_cm_currency_code,
                     p_trx_date,
                     p_cm_gl_date,
                     p_cm_unapp_amount,
		     p_cm_receipt_method_id,
                     l_cm_return_status
                                  );
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_activity_info: ' || 'CM defaulting return status :'||l_cm_return_status);
    END IF;

    IF p_apply_date IS NULL THEN
	p_apply_date := GREATEST(SYSDATE,(NVL(p_trx_date,SYSDATE)));
    END IF;

    IF p_apply_gl_date IS NULL THEN
        Default_gl_date(p_cm_gl_date,
                        p_apply_gl_date,
                        NULL,
                        l_gl_date_return_status);
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_activity_info: ' || 'Defaulting apply gl date return status :'|| l_gl_date_return_status);
    END IF;

    --default the amount applied
    IF l_amount_applied IS NULL THEN
                 l_amount_applied := p_cm_unapp_amount;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Amount applied: ' || l_amount_applied );
    END IF;

    --do the precision
    p_amount_applied :=  arp_util.CurrRound(
                                      l_amount_applied,
                                      p_cm_currency_code
                                        );
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Amount applied: ' || p_amount_applied );
    END IF;


    IF l_cm_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_gl_date_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
       p_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_activity_info: ' || '***************Default Values *****************');
         arp_util.debug('Default_activity_info: ' || 'p_customer_trx_id       : '||to_char(p_customer_trx_id));
         arp_util.debug('Default_activity_info: ' || 'p_cm_gl_date            : '||to_char(p_cm_gl_date,'DD-MON-YYYY'));
         arp_util.debug('Default_activity_info: ' || 'p_cm_unapp_amount       : '||to_char(p_cm_unapp_amount));
         arp_util.debug('Default_activity_info: ' || 'p_amount_applied        : '||to_char(p_amount_applied));
         arp_util.debug('Default_activity_info: ' || 'p_apply_gl_date         : '||to_char(p_apply_gl_date,'DD-MON-YYYY'));
         arp_util.debug('Default_activity_info: ' || 'p_apply_date            : '||to_char(p_apply_date,'DD-MON-YYYY'));
         arp_util.debug('Default_activity_info ()-');
      END IF;
EXCEPTION
WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_activity_info() ');
  END IF;
  raise;
END  Default_activity_info;

PROCEDURE Derive_activity_unapp_ids(
                         p_trx_number    IN VARCHAR2,
                         p_customer_trx_id   IN OUT NOCOPY NUMBER,
                         p_receivable_application_id   IN OUT NOCOPY NUMBER,
                         p_apply_gl_date     OUT NOCOPY DATE,
                         p_return_status  OUT NOCOPY VARCHAR2
                               ) IS
l_rec_appln_id  NUMBER ;
l_apply_gl_date  DATE;
l_customer_trx_id   NUMBER;
BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_activity_unapp_ids ()+');
   END IF;
    --derive the customer_trx_id from the trx_number
    IF p_trx_number IS NOT NULL THEN
        Default_customer_trx_id (p_customer_trx_id ,
                                 p_trx_number ,
                                 p_return_status);
    END IF;
    l_customer_trx_id := p_customer_trx_id;

        --get the receivable application id for the activity application
        --on this credit memo. If more than one activity application exists
        --raise error.
      IF p_customer_trx_id IS NOT NULL THEN

           BEGIN
              SELECT receivable_application_id, gl_date
              INTO   l_rec_appln_id , p_apply_gl_date
              FROM   ar_receivable_applications
              WHERE  customer_trx_id = p_customer_trx_id
                AND  display = 'Y'
		AND applied_payment_schedule_id = -8
                AND  status = 'ACTIVITY';
           EXCEPTION
             WHEN no_data_found THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
             WHEN too_many_rows THEN
              IF p_receivable_application_id IS NULL THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_MULTIPLE_ACTIVITY_APP');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
              END IF;

           END;

      END IF;

       IF p_receivable_application_id IS NOT NULL THEN

          BEGIN
           SELECT  customer_trx_id, gl_date
           INTO    l_customer_trx_id , p_apply_gl_date
           FROM    ar_receivable_applications
           WHERE   receivable_application_id = p_receivable_application_id
             and   display = 'Y'
             and   applied_payment_schedule_id = -8
             and   status = 'ACTIVITY';
          EXCEPTION
            WHEN no_data_found THEN
               FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR ;
          END;

         --Compare the two customer_trx_ids
         IF p_customer_trx_id IS NOT NULL THEN
            IF p_customer_trx_id <> NVL(l_customer_trx_id,p_customer_trx_id) THEN
                --raise error X validation failed
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_RA_ID_X_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
         END IF;

       ELSE
        p_receivable_application_id := l_rec_appln_id ;
       END IF;

       IF p_customer_trx_id IS NULL THEN
          p_customer_trx_id := l_customer_trx_id;
       END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_activity_unapp_ids ()+');
   END IF;
END Derive_activity_unapp_ids;

PROCEDURE Default_unapp_activity_info(
                         p_receivable_application_id IN NUMBER,
                         p_apply_gl_date             IN DATE,
                         p_customer_trx_id           IN NUMBER,
                         p_reversal_gl_date          IN OUT NOCOPY DATE,
                         p_cm_gl_date                OUT NOCOPY DATE,
			 p_cm_ps_id                  OUT NOCOPY NUMBER,
			 p_cm_unapp_amount           OUT NOCOPY NUMBER,
			 p_return_status             OUT NOCOPY VARCHAR2
                          ) IS
l_apply_date DATE;
l_apply_gl_date DATE;
l_customer_trx_id  NUMBER;
l_rec_appln_id     NUMBER;
l_default_gl_date  DATE;
l_defaulting_rule_used  VARCHAR2(100);
l_error_message  VARCHAR2(240);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_unapp_activity_info: ' || 'Default_unapp_activity_info ()+');
  END IF;
  l_apply_gl_date := p_apply_gl_date;
  l_customer_trx_id := p_customer_trx_id;

      IF p_reversal_gl_date is null THEN
         IF (arp_util.validate_and_default_gl_date(
                nvl(l_apply_gl_date,trunc(sysdate)),
                NULL,
                l_apply_gl_date,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                NULL,
                arp_global.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE) THEN

           p_reversal_gl_date := l_default_gl_date;
         ELSE
         --we were not able to default the gl_date put the message
         --here on the stack, but the return status will be set
         --to FND_API.G_RET_STS_ERROR in the validation phase.
           FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
           FND_MSG_PUB.Add;
         END IF;
      END IF;

   IF p_receivable_application_id IS NOT NULL THEN
      BEGIN
        SELECT customer_trx_id
        INTO   l_customer_trx_id
        FROM   ar_receivable_applications
        WHERE  receivable_application_id = p_receivable_application_id
        AND    applied_payment_schedule_id = -8
        AND    status = 'ACTIVITY'
        and    display = 'Y';
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR ;
      END;
   ELSIF p_customer_trx_id IS NOT NULL THEN
         BEGIN
              SELECT receivable_application_id
              INTO   l_rec_appln_id
              FROM   ar_receivable_applications
              WHERE  customer_trx_id = p_customer_trx_id
	      AND    applied_payment_schedule_id = -8
              AND    display = 'Y'
	      AND    status = 'ACTIVITY';
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
             WHEN TOO_MANY_ROWS THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_MULTIPLE_ACTIVITY_APP');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;

         END;
    END IF;

   IF l_customer_trx_id IS NOT NULL
      THEN
       BEGIN
         SELECT gl_date,
                payment_schedule_id,
                (amount_due_remaining * -1)
         INTO   p_cm_gl_date,
                p_cm_ps_id,
		p_cm_unapp_amount
         FROM   ar_payment_schedules
         WHERE  customer_trx_id = l_customer_trx_id;
       EXCEPTION
         WHEN no_data_found THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_unapp_activity_info: ' || 'Could not get the cm_gl_date. ');
          END IF;
          RAISE;
       END;
   END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_unapp_activity_info: ' || '*****Defaulted Values *********');
       arp_util.debug('Default_unapp_activity_info: ' || 'p_customer_trx_id            : '||to_char(p_customer_trx_id));
       arp_util.debug('Default_unapp_activity_info: ' || 'p_receivable_application_id  : '||to_char(p_receivable_application_id));
       arp_util.debug('Default_unapp_activity_info: ' || 'p_apply_gl_date              : '||to_char(p_apply_gl_date,'DD-MON-YYYY'));
       arp_util.debug('Default_unapp_activity_info: ' || 'p_reversal_gl_date           : '||to_char(p_reversal_gl_date,'DD-MON-YYYY'));
       arp_util.debug('Default_unapp_activity_info: ' || 'p_cm_unapp_amount  : '||p_cm_unapp_amount);
       arp_util.debug('Default_unapp_activity_info: ' || 'p_cm_ps_id  : '||p_cm_ps_id);
       arp_util.debug('Default_unapp_activity_info: ' || 'Default_unapp_on_acc_act_info ()-');
    END IF;

END Default_unapp_activity_info;

END ar_cm_app_lib_pvt;

/
