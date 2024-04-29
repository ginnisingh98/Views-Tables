--------------------------------------------------------
--  DDL for Package Body AR_CM_APP_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CM_APP_VAL_PVT" AS
/* $Header: ARXCMAVB.pls 120.5.12010000.2 2008/11/11 13:28:35 npanchak ship $    */
--Validation procedures are contained in this package

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Validate_apply_gl_date(p_apply_gl_date IN DATE,
                                 p_trx_gl_date IN DATE,
                                 p_return_status OUT NOCOPY VARCHAR2
                                 ) IS
l_bool  BOOLEAN;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_gl_date ()+');
    END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_apply_gl_date IS NOT NULL THEN

       -- Check that the application GL Date is not before the invoice GL Date.
       IF p_apply_gl_date < p_trx_gl_date THEN
          FND_MESSAGE.SET_NAME('AR','AR_VAL_GL_INV_GL');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Check that the Application GL Date is in an open or future GL period.
       IF ( NOT arp_util.is_gl_date_valid( p_apply_gl_date )) THEN
         FND_MESSAGE.set_name( 'AR', 'AR_INVALID_APP_GL_DATE' );
         FND_MESSAGE.set_token( 'GL_DATE', TO_CHAR( p_apply_gl_date ));
         FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_gl_date ()-');
    END IF;

END Validate_apply_gl_date;

PROCEDURE Validate_apply_date(p_apply_date IN DATE,
                              p_trx_date IN DATE,
                              p_return_status OUT NOCOPY VARCHAR2
                               ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_date ()+');
    END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_apply_date IS NOT NULL THEN

       -- check that the apply  date is not before the invoice date.
       IF p_apply_date < p_trx_date THEN
          FND_MESSAGE.SET_NAME('AR','AR_APPLY_BEFORE_TRANSACTION');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_date ()-');
    END IF;
END Validate_apply_date;

PROCEDURE Validate_amount_applied_from(
                               p_receivable_application_id IN NUMBER,
			       p_cm_unapp_amount IN NUMBER,
                               p_return_status OUT NOCOPY VARCHAR2
			       ) IS
l_amount_applied NUMBER;
l_amount_applied_from NUMBER;
l_remaining_unapp_cm_amt NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_amount_applied_from ()+');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT amount_applied,
           amount_applied_from INTO l_amount_applied,l_amount_applied_from
    FROM  ar_receivable_applications
    WHERE receivable_application_id = p_receivable_application_id;

    l_remaining_unapp_cm_amt := p_cm_unapp_amount + nvl(l_amount_applied_from, l_amount_applied);

    IF l_remaining_unapp_cm_amt < 0 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_amount_applied_from: ' || 'l_remaining_unapp_cm_amt :'||to_char(l_remaining_unapp_cm_amt));
      END IF;
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR','AR_CKAP_OVERAPP');
      FND_MSG_PUB.Add;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_amount_applied_from ()-');
    END IF;
END  Validate_amount_applied_from;


PROCEDURE Validate_Rev_gl_date(p_reversal_gl_date IN DATE,
                               p_apply_gl_date  IN DATE,
                               p_cm_gl_date IN DATE,
                               p_return_status  OUT NOCOPY VARCHAR2
                               ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_Rev_gl_date ()+');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_reversal_gl_date IS NOT NULL THEN

    IF  p_reversal_gl_date < NVL(p_apply_gl_date,p_reversal_gl_date)  THEN
        FND_MESSAGE.SET_NAME('AR','AR_RW_BEFORE_APP_GL_DATE');
        FND_MESSAGE.SET_TOKEN('GL_DATE', p_apply_gl_date);
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    IF p_reversal_gl_date < nvl(p_cm_gl_date,p_reversal_gl_date) THEN
        FND_MESSAGE.SET_NAME('AR','AR_REF_BEFORE_CM_GL_DATE');
        FND_MESSAGE.SET_TOKEN('GL_DATE', p_cm_gl_date);
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF ( NOT arp_util.is_gl_date_valid(p_reversal_gl_date)) THEN
        FND_MESSAGE.set_name( 'AR', 'AR_INVALID_APP_GL_DATE' );
        FND_MESSAGE.set_token( 'GL_DATE', TO_CHAR( p_reversal_gl_date ));
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  ELSE
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_GL_DATE_NULL');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Rev_gl_date: ' || 'The Reversal gl date is null ');
      END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_Rev_gl_date ()-');
  END IF;
EXCEPTION
  WHEN others THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION: Validate_rev_gl_date() ');
      END IF;
      raise;
END Validate_Rev_gl_date;

PROCEDURE Validate_receivable_appln_id(
                       p_receivable_application_id  IN  NUMBER,
                       p_application_type  IN VARCHAR2,
                       p_return_status OUT NOCOPY VARCHAR2) IS
l_valid NUMBER;
BEGIN
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_receivable_appln_id ()+');
  END IF;
   IF p_receivable_application_id IS NOT NULL
     THEN
       SELECT count(*)
       INTO   l_valid
       FROM   AR_RECEIVABLE_APPLICATIONS ra
       WHERE  ra.receivable_application_id = p_receivable_application_id
         and  ra.display = 'Y'
         and  ra.status = p_application_type
         and  ra.application_type = 'CM';

     IF  l_valid = 0 THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSIF p_receivable_application_id IS NULL  THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_NULL');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;

   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_receivable_appln_id ()-');
  END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Validate_receivable_appln_id()');
   END IF;
   raise;
END Validate_receivable_appln_id;

PROCEDURE validate_activity(p_receivables_trx_id IN NUMBER,
			    p_customer_trx_id IN NUMBER,
                            p_applied_ps_id IN NUMBER,
                            p_amount_applied IN NUMBER,
                            p_currency_code IN VARCHAR2,
                            p_chk_approval_limit_flag IN VARCHAR2,
                            p_return_status IN OUT NOCOPY VARCHAR2
                            ) IS
l_activity_type   VARCHAR2(30);
l_amount_from           NUMBER;
l_amount_to             NUMBER;
l_user_id               NUMBER;
l_existing_cmref_amount    NUMBER;
l_tot_cmref_amt     NUMBER;

cursor activity_type is
 select type
 from   ar_receivables_trx rt
 where  receivables_trx_id = p_receivables_trx_id;

BEGIN

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('validate_activity (+)');
 END IF;

 OPEN activity_type;
 FETCH activity_type INTO l_activity_type;
 IF activity_type%NOTFOUND THEN
   FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_TRX_ID_INVALID');
   FND_MSG_PUB.Add;
   p_return_status := FND_API.G_RET_STS_ERROR;
 END IF;
 CLOSE activity_type;

 IF l_activity_type IS NOT NULL THEN
  --Validate applied ps_id
    IF p_applied_ps_id = -8 THEN
--6865230
      IF l_activity_type <> 'CM_REFUND' THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       l_user_id       := to_number(fnd_profile.value('USER_ID'));

       --get the existing refund amount on the CM.

         BEGIN
          SELECT sum(amount_applied)
          INTO l_existing_cmref_amount
  	  FROM ar_receivable_applications
  	  WHERE applied_payment_schedule_id = -8
          AND   status = 'ACTIVITY'
          AND   NVL(confirmed_flag,'Y') = 'Y'
          AND   customer_trx_id = p_customer_trx_id;

          l_tot_cmref_amt := NVL(l_existing_cmref_amount,0) + NVL(p_amount_applied,0);

         EXCEPTION
           WHEN no_data_found THEN
             l_tot_cmref_amt := p_amount_applied;
         END;

       IF NVL(p_chk_approval_limit_flag,'Y') <> 'N' THEN
         BEGIN
          SELECT NVL(amount_from,0),
                 NVL(amount_to,0)
          INTO   l_amount_from,
                 l_amount_to
          FROM   ar_approval_user_limits
          where  currency_code = p_currency_code
          and    user_id = l_user_id
          and    document_type ='CMREF';
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
           l_amount_from := NVL(l_tot_cmref_amt,0);
           l_amount_to := NVL(l_tot_cmref_amt,0);
         END;

         IF (NVL(l_tot_cmref_amt,0) > l_amount_to) OR
            (NVL(l_tot_cmref_amt,l_amount_from) < l_amount_from)
          THEN
           fnd_message.set_name ('AR','AR_REF_USR_LMT_OUT_OF_RANGE');
           fnd_message.set_token('FROM_AMOUNT', to_char(l_amount_from), FALSE);
           fnd_message.set_token('TO_AMOUNT', to_char(l_amount_to), FALSE);
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

       END IF;

    ELSE
      --the applied payment schedule id is invalid
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
    END IF; --additional control structures to be added for new activity types.
  END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('validate_activity (-)');
 END IF;
END validate_activity;

PROCEDURE validate_activity_app( p_receivables_trx_id IN NUMBER,
                                 p_applied_ps_id  IN NUMBER,
                                 p_customer_trx_id IN NUMBER,
                                 p_cm_gl_date  IN DATE,
                                 p_cm_unapp_amount IN NUMBER,
                                 p_trx_date IN DATE,
                                 p_amount_applied IN NUMBER,
                                 p_apply_gl_date IN DATE,
                                 p_apply_date IN DATE,
                                 p_cm_currency_code IN VARCHAR2,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_chk_approval_limit_flag IN VARCHAR2,
                                 p_called_from IN VARCHAR2
                                 ) IS
l_valid   VARCHAR2(1) DEFAULT 'N';
l_cm_return_status  VARCHAR2(1);
l_act_return_status VARCHAR2(1);
l_amt_return_status VARCHAR2(1);
l_gl_date_return_status VARCHAR2(1);
l_apply_date_return_status  VARCHAR2(1);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('validate_activity_app ()+');
  END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;

     l_act_return_status := FND_API.G_RET_STS_SUCCESS;
     l_amt_return_status := FND_API.G_RET_STS_SUCCESS;
     l_cm_return_status  := FND_API.G_RET_STS_SUCCESS;
     l_gl_date_return_status := FND_API.G_RET_STS_SUCCESS;
     l_apply_date_return_status := FND_API.G_RET_STS_SUCCESS;

     validate_activity(
                   p_receivables_trx_id,
		   p_customer_trx_id,
                   p_applied_ps_id,
                   p_amount_applied,
                   p_cm_currency_code,
                   p_chk_approval_limit_flag,
                   l_act_return_status
                    );
     -- if this routine is called for cmrefund,this routine will check whether
     -- the credit memo is suitable for refund

        validate_credit_memo(FND_API.G_FALSE,
                             p_customer_trx_id,
                             l_cm_return_status);

        validate_apply_date (p_apply_date,
                             p_trx_date,
                             l_apply_date_return_status
                            			);

       --  validate amount applied
          IF  p_amount_applied IS NULL  THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_APPLIED_AMT_NULL');
              FND_MSG_PUB.Add;
              l_amt_return_status := FND_API.G_RET_STS_ERROR;

          ELSIF  (p_amount_applied < 0 AND NVL(p_applied_ps_id,-8) = -8) THEN
              FND_MESSAGE.SET_NAME('AR','AR_REF_CM_APP_NEG');
              FND_MSG_PUB.Add;
              l_amt_return_status := FND_API.G_RET_STS_ERROR;
          -- Bug 2897244 - amount not checked if called from form
          ELSIF ((nvl(p_cm_unapp_amount,0)- p_amount_applied) < 0 AND
                 NVL(p_called_from,'RAPI') <> 'ARXRWAPP') THEN
              FND_MESSAGE.SET_NAME('AR','AR_CKAP_OVERAPP');
              FND_MSG_PUB.Add;
              l_amt_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          validate_apply_gl_date(
				p_apply_gl_date,
                               	p_cm_gl_date,
                                l_gl_date_return_status
                                );

          IF  l_cm_return_status <> FND_API.G_RET_STS_SUCCESS  OR
              l_amt_return_status <> FND_API.G_RET_STS_SUCCESS OR
              l_gl_date_return_status <> FND_API.G_RET_STS_SUCCESS OR
              l_apply_date_return_status <> FND_API.G_RET_STS_SUCCESS OR
	      l_act_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('validate_activity_app ()-');
        END IF;
EXCEPTION
WHEN others  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  validate_activity_app()');
    END IF;
    raise;
END validate_activity_app;


PROCEDURE validate_unapp_activity(
                              p_trx_gl_date  IN DATE,
                              p_receivable_application_id  IN NUMBER,
                              p_reversal_gl_date  IN DATE,
                              p_apply_gl_date    IN DATE,
                              p_cm_unapp_amt     IN NUMBER,
                              p_return_status  OUT NOCOPY VARCHAR2
                               ) IS
l_amt_app_from_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('validate_unapp_activity  ()+');
     END IF;

          Validate_rev_gl_date( p_reversal_gl_date ,
                                p_apply_gl_date ,
                                p_trx_gl_date,
                                p_return_status
                                  );

         IF p_receivable_application_id IS NOT NULL
           AND p_cm_unapp_amt IS NOT NULL THEN
            Validate_amount_applied_from( p_receivable_application_id,
                                          p_cm_unapp_amt,
                                          l_amt_app_from_return_status);
         END IF;
         IF l_amt_app_from_return_status <> FND_API.G_RET_STS_SUCCESS OR
            p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            p_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('validate_unapp_activity: ' || 'p_return_status :'||p_return_status);
       arp_util.debug('validate_unapp_activity ()-');
    END IF;
END validate_unapp_activity;


PROCEDURE validate_credit_memo (
          p_init_msg_list IN VARCHAR2,
          p_customer_trx_id IN NUMBER,
          p_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR c_cm IS
    SELECT ct.receipt_method_id,
	   ct.customer_bank_account_id,
	   ct.previous_customer_trx_id,
	   ct.complete_flag,
	   rc.remit_flag,
	   rma.remittance_ccid
    FROM   ra_customer_trx ct,
           ar_receipt_methods rm,
	   ar_receipt_classes rc,
           ar_receipt_method_accounts rma
    WHERE  ct.customer_trx_id = p_customer_trx_id
    AND    ct.receipt_method_id = rm.receipt_method_id(+)
    AND    rm.receipt_class_id = rc.receipt_class_id(+)
    AND    rm.receipt_method_id = rma.receipt_method_id(+)
    AND    ROWNUM = 1;

    CURSOR c_ps IS
    SELECT SUM(amount_due_original), SUM(amount_due_remaining)
    FROM   ar_payment_schedules
    WHERE  customer_trx_id = p_customer_trx_id;

   l_receipt_method_id		NUMBER;
   l_customer_bank_account_id	NUMBER;
   l_previous_customer_trx_id	NUMBER;
   l_complete_flag		ra_customer_trx.complete_flag%TYPE;
   l_remit_flag			ar_receipt_classes.remit_flag%TYPE;
   l_remittance_ccid		NUMBER;
   l_amount_due_original        NUMBER;
   l_amount_due_remaining       NUMBER;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('validate_credit_memo (+)');
 END IF;
       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
        END IF;
       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        p_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_cm;
   FETCH c_cm INTO l_receipt_method_id,
		   l_customer_bank_account_id,
		   l_previous_customer_trx_id,
		   l_complete_flag,
		   l_remit_flag,
 		   l_remittance_ccid;
   CLOSE c_cm;
   IF l_previous_customer_trx_id IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('AR','AR_REF_NOT_OACM');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   IF NVL(l_complete_flag,'N') <> 'Y' THEN
      FND_MESSAGE.SET_NAME('AR','AR_REF_CM_INCOMPLETE');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
   ELSE
     OPEN c_ps;
     FETCH c_ps INTO l_amount_due_original, l_amount_due_remaining;
     CLOSE c_ps;
     /* Bug 4203308 - checks the original amount for positive CM condition
        instead of amount due which may be positive due to overapplication */
     IF l_amount_due_original > 0 THEN
        FND_MESSAGE.SET_NAME('AR','AR_REF_CM_POSITIVE');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     IF l_amount_due_remaining >= 0 THEN
        FND_MESSAGE.SET_NAME('AR','AR_REF_MORE_THAN_CM_AMT');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('validate_credit_memo (-)');
 END IF;
EXCEPTION
  WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;

END validate_credit_memo;

END AR_CM_APP_VAL_PVT;

/
