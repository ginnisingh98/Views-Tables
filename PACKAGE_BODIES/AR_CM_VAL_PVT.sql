--------------------------------------------------------
--  DDL for Package Body AR_CM_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CM_VAL_PVT" AS
/* $Header: ARXVCMEB.pls 120.0.12010000.2 2009/03/17 15:04:39 spdixit ship $ */

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
PG_PROFILE_APPLN_GL_DATE_DEF varchar2(30)  := FND_PROFILE.value('AR_APPLICATION_GL_DATE_DEFAULT');

-- PRIVATE PROCEDURES/FUNCTIONS

PROCEDURE default_customer_trx_id(
                          p_customer_trx_id IN OUT NOCOPY NUMBER,
                          p_trx_number  IN VARCHAR,
                          p_return_status OUT NOCOPY VARCHAR2
                           ) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_customer_trx_id ()+');
     arp_util.debug(' Trx Number is '|| p_trx_number);
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

   ELSE -- p_customer_trx_id IS NOT NULL

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
      arp_util.debug('EXCEPTION: default_customer_trx_id()', G_MSG_UERROR);
   END IF;
END default_customer_trx_id;

PROCEDURE default_customer_trx_line_id(
                          p_inv_customer_trx_id IN OUT NOCOPY NUMBER,
                          p_inv_customer_trx_line_id IN OUT NOCOPY NUMBER,
                          p_inv_line_number  IN NUMBER,
                          p_return_status OUT NOCOPY VARCHAR2
                           ) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_customer_trx_line_id ()+');
  END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_inv_customer_trx_line_id IS NOT NULL AND
      p_inv_line_number IS NOT NULL
        THEN
        --give a warning message to indicate that the line number
        --entered by the user has been ignored.
          IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
           THEN
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LINE_NUM_IGN');
             FND_MSG_PUB.Add;
          END IF;
   END IF;

   IF p_inv_customer_trx_id IS NOT NULL THEN
     IF p_inv_customer_trx_line_id IS NULL THEN
        IF  p_inv_line_number IS NOT NULL THEN
           BEGIN
             SELECT customer_trx_line_id
             INTO   p_inv_customer_trx_line_id
             FROM   ra_customer_trx_lines
             WHERE  customer_trx_id = p_inv_customer_trx_id
               AND   line_number = p_inv_line_number
               AND   line_type =   'LINE';
           EXCEPTION
             WHEN no_data_found THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LINE_NO_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
           END;
        END IF;
    END IF;
   ELSE
     IF p_inv_customer_trx_line_id IS NOT NULL THEN
        BEGIN
             SELECT customer_trx_id
             INTO   p_inv_customer_trx_id
             FROM   ra_customer_trx_lines
             WHERE  customer_trx_line_id = p_inv_customer_trx_line_id
               AND  line_type =   'LINE';
        EXCEPTION
             WHEN no_data_found THEN
               FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LINE_ID_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
        END;
     END IF;
   END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_customer_trx_line_id ()-');
 END IF;
EXCEPTION
  WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Default_customer_trx_line_id()', G_MSG_UERROR);
   END IF;
END default_customer_trx_line_id;


PROCEDURE default_cm_info(
          p_cm_customer_trx_id   IN ra_customer_trx.customer_trx_id%TYPE,
          p_cm_gl_date           OUT NOCOPY DATE,
          p_cm_amount_rem        OUT NOCOPY ar_payment_schedules.amount_due_remaining%TYPE,
          p_cm_trx_date          OUT NOCOPY DATE,
          p_cm_ps_id             OUT NOCOPY ar_payment_schedules.payment_schedule_id%TYPE ,
          p_cm_currency_code     OUT NOCOPY fnd_currencies.currency_code%TYPE,
          p_cm_customer_id       OUT NOCOPY ra_customer_trx.paying_customer_id%TYPE,
          p_return_status         OUT NOCOPY VARCHAR2
    ) IS

BEGIN

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_CM_Info ()+');
   END IF;

   IF p_cm_customer_trx_id IS NOT NULL THEN
      BEGIN

        SELECT ps.payment_schedule_id,
               cm.trx_date,
               ps.gl_date,
               ps.amount_due_remaining,
               NVL(cm.paying_customer_id, cm.bill_to_customer_id),
               cm.invoice_currency_code
         INTO  p_cm_ps_id,
               p_cm_trx_date,
               p_cm_gl_date,
               p_cm_amount_rem,
               p_cm_customer_id,
               p_cm_currency_code
         FROM  ra_customer_trx cm,
               ar_payment_schedules ps
        WHERE  ps.customer_trx_id = cm.customer_trx_id
          AND  cm.customer_trx_id = p_cm_customer_trx_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME( 'AR','AR_CMAPI_CM_TRX_ID_INVALID');
         FND_MSG_PUB.ADD;
         p_return_status := FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('EXCEPTION: Default_CM_Info()');
        END IF;
      END;

   ELSE
       FND_MESSAGE.SET_NAME( 'AR','AR_CMAPI_CM_TRX_ID_NULL');
       FND_MSG_PUB.ADD;
         p_return_status := FND_API.G_RET_STS_ERROR ;
   END IF;


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_CM_Info ()-');
   END IF;

END default_cm_info;



PROCEDURE default_trx_info(
            p_inv_customer_trx_id     IN ra_customer_trx.customer_trx_id%TYPE,
            p_inv_customer_trx_line_id IN NUMBER,
            p_show_closed_invoices     IN VARCHAR2,
            p_cm_gl_date               IN DATE,
            p_cm_customer_id           IN ra_customer_trx.paying_customer_id%TYPE,
            p_cm_currency_code         IN fnd_currencies.currency_code%TYPE,
            p_cm_ps_id                 IN NUMBER,
            p_cm_trx_date              IN DATE,
            p_inv_customer_id          OUT NOCOPY NUMBER, --customer on transaction
            p_inv_cust_trx_type_id     OUT NOCOPY ra_customer_trx.cust_trx_type_id%TYPE ,
            p_inv_due_date             OUT NOCOPY DATE,
            p_inv_trx_date             OUT NOCOPY DATE,
            p_inv_gl_date              OUT NOCOPY DATE,
            p_allow_overappln_flag     OUT NOCOPY VARCHAR2,
            p_natural_appln_only_flag  OUT NOCOPY VARCHAR2,
            p_creation_sign            OUT NOCOPY VARCHAR2,
            p_applied_payment_schedule_id  IN OUT NOCOPY NUMBER,
            p_app_gl_date              OUT NOCOPY DATE, --this is the application gl_date
            p_installment              IN OUT NOCOPY NUMBER,
            p_inv_amount_rem              OUT NOCOPY NUMBER,
            p_inv_currency_code           OUT NOCOPY VARCHAR,
            p_return_status            OUT NOCOPY VARCHAR2
         )

IS

l_applied_payment_schedule_id  NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_Trx_Info ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_inv_customer_trx_id IS NOT NULL AND
     p_installment IS NOT NULL THEN
    IF arp_global.sysparam.pay_unrelated_invoices_flag = 'Y' THEN
        SELECT
          ot.customer_id ,
          ot.cust_trx_type_id ,
          ot.trx_due_date ,
          ot.trx_date,
          ot.trx_gl_date ,
          ot.allow_overapplication_flag ,
          ot.natural_application_only_flag ,
          ot.creation_sign ,
          ot.payment_schedule_id ,
          greatest(p_cm_gl_date,ot.trx_gl_date,
                   decode(pg_profile_appln_gl_date_def,
                          'INV_REC_SYS_DT', sysdate, 'INV_REC_DT', ot.trx_gl_date,
                           ot.trx_gl_date)) gl_date,
          ot.balance_due_functional,
          ot.invoice_currency_code
        INTO
          p_inv_customer_id ,
          p_inv_cust_trx_type_id ,
          p_inv_due_date ,
          p_inv_trx_date,
          p_inv_gl_date ,
          p_allow_overappln_flag ,
          p_natural_appln_only_flag ,
          p_creation_sign ,
          l_applied_payment_schedule_id ,
          p_app_gl_date, --this is the application gl_date
          p_inv_amount_rem,
          p_inv_currency_code
        FROM
          ar_open_trx_v ot
        WHERE
          ot.customer_trx_id =  p_inv_customer_trx_id and
          ot.invoice_currency_code = p_cm_currency_code and
          ot.status=decode(p_show_closed_invoices,'Y',ot.status,'OP') and
          ot.terms_sequence_number = p_installment;

     ELSE
     --This is the case where pay_unrelated_invoices_flag is 'N'
        SELECT
          ot.customer_id ,
          ot.cust_trx_type_id ,
          ot.trx_due_date ,
          ot.trx_date,
          ot.trx_gl_date ,
          ot.allow_overapplication_flag ,
          ot.natural_application_only_flag ,
          ot.creation_sign ,
          ot.payment_schedule_id ,
          greatest(p_cm_gl_date,ot.trx_gl_date,
                   decode(pg_profile_appln_gl_date_def,
                          'INV_REC_SYS_DT', sysdate, 'INV_REC_DT', ot.trx_gl_date,
                 ot.trx_gl_date)) gl_date,
          ot.balance_due_functional,
          ot.invoice_currency_code
        INTO
          p_inv_customer_id ,
          p_inv_cust_trx_type_id ,
          p_inv_due_date ,
          p_inv_trx_date,
          p_inv_gl_date ,
          p_allow_overappln_flag,
          p_natural_appln_only_flag,
          p_creation_sign,
          l_applied_payment_schedule_id,
          p_app_gl_date, --this is the defaulted application gl_date
          p_inv_amount_rem,
          p_inv_currency_code
        FROM
          ar_open_trx_v ot
        WHERE
          ot.customer_trx_id =  p_inv_customer_trx_id and
          ot.invoice_currency_code = p_cm_currency_code and
          ot.status=decode(p_show_closed_invoices,'Y',ot.status,'OP') and
          ot.terms_sequence_number = p_installment and
          ot.customer_id IN (
          SELECT rcr.related_cust_account_id
          FROM hz_cust_acct_relate rcr
          WHERE rcr.status='A' and
                rcr.cust_account_id= p_cm_customer_id
            and rcr.bill_to_flag = 'Y'
          UNION
          SELECT p_cm_customer_id
          FROM dual
          UNION
          SELECT rel.related_cust_account_id
          FROM ar_paying_relationships_v rel,
               hz_cust_accounts acc
          WHERE rel.party_id = acc.party_id
            AND acc.cust_account_id = p_cm_customer_id
            AND p_cm_trx_date BETWEEN effective_start_date
                              AND effective_end_date
          );

     END IF;



 --If the defaulted payment_schedule_id does not match the
 --applied_ps_id entered by the user, then raise error.
 IF p_applied_payment_schedule_id IS NOT NULL THEN
   IF l_applied_payment_schedule_id <>
                             p_applied_payment_schedule_id THEN
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_PS_ID_X_INVALID');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR ;
   END IF;
 ELSE
      p_applied_payment_schedule_id := l_applied_payment_schedule_id;
 END IF;


ELSE --case when p_customer_trx_id is null
  --no further validation done in the validation routines for customer_trx_id
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_NULL');
  FND_MSG_PUB.Add;
  p_return_status := FND_API.G_RET_STS_ERROR ;

END IF;

IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_Trx_Info: ' || 'p_applied_payment_schedule_id : '||to_char(p_applied_payment_schedule_id));
     arp_util.debug('Default_Trx_Info: ' || 'p_allow_overappln_flag         : '||p_allow_overappln_flag);
     arp_util.debug('Default_Trx_Info: ' || 'p_natural_appln_only_flag      : '||p_natural_appln_only_flag);
     arp_util.debug('Default_Trx_Info: ' || 'p_creation_sign                : '||p_creation_sign);
   arp_util.debug('Default_Trx_Info ()-');
END IF;
EXCEPTION
  WHEN no_data_found THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_Trx_Info : No data found ');
    END IF;
  WHEN others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Default_Trx_Info()');
    END IF;
    raise;

END default_trx_info;

PROCEDURE default_amt_applied(
                 p_inv_currency_code IN fnd_currencies.currency_code%TYPE,
                 p_cm_currency_code  IN fnd_currencies.currency_code%TYPE,
                 p_cm_amount_rem        IN ar_payment_schedules.amount_due_remaining%TYPE,
                 p_inv_amount_rem       IN ar_payment_schedules.amount_due_Remaining%TYPE,
                 p_amount_applied    IN OUT NOCOPY NUMBER,
                 p_return_status     OUT NOCOPY VARCHAR2
      )

IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_amt_applied ()+');
  END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF  p_amount_applied  IS NULL THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_amt_applied: ' || 'p_amount_applied is NULL ');
       arp_util.debug('Invoice currency code: ' || p_inv_currency_code);
       arp_util.debug('CM currency code: ' || p_cm_currency_code);
    END IF;

    IF p_inv_currency_code = p_cm_currency_code  -- Same currency case
      THEN

       IF (sign(p_inv_amount_rem) <> sign(p_cm_amount_rem) ) THEN
         IF abs(p_inv_amount_rem) > abs(p_cm_amount_rem)  THEN
            p_amount_applied := abs(p_cm_amount_rem)*sign(p_inv_amount_rem);
         ELSE
           p_amount_applied := p_inv_amount_rem;
         END IF;
       END IF;
       p_amount_applied := arp_util.CurrRound(p_amount_applied,
                                         p_inv_currency_code);
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_amt_applied: ' || p_amount_applied );
    END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_amt_applied ()-');
  END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_amt_applied: ' || 'EXCEPTION: Default_amt_applied()');
  END IF;
  raise;


END default_amt_applied;


PROCEDURE validate_apply_date(
                   p_apply_date  IN DATE,
                         p_inv_trx_date IN DATE,
                         p_cm_trx_date  IN DATE,
                         p_return_status OUT NOCOPY VARCHAR2
                         )
IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_date ()+');
    END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_apply_date IS NOT NULL THEN

       -- check that the apply  date is not before the invoice date.
       IF p_apply_date < p_inv_trx_date THEN
          FND_MESSAGE.SET_NAME('AR','AR_APPLY_BEFORE_TRANSACTION');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;

        -- check that the application date is not before the CM trx date.
       END IF;

       IF p_apply_date < p_cm_trx_date  THEN
          FND_MESSAGE.SET_NAME('AR','AR_APPLY_BEFORE_CM');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_date ()-');
    END IF;


END validate_apply_date;

PROCEDURE  validate_apply_gl_date(p_apply_gl_date IN DATE,
                           p_inv_gl_date IN DATE,
                           p_cm_gl_date  IN DATE,
                           p_return_status OUT NOCOPY VARCHAR2
                                 )

IS

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_apply_gl_date ()+');
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_apply_gl_date IS NOT NULL THEN

       -- Check that the application GL Date is not before the invoice GL Date.
       IF p_apply_gl_date < p_inv_gl_date THEN
          FND_MESSAGE.SET_NAME('AR','AR_VAL_GL_INV_GL');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR;

        -- Check that the application GL Date is not before the CM GL Date.
       END IF;
       IF p_apply_gl_date < p_cm_gl_date  THEN
          FND_MESSAGE.SET_NAME('AR','AR_RW_GL_DATE_BEFORE_CM_GL');
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


END validate_apply_gl_date;

PROCEDURE validate_amount_applied(
                      p_amount_applied IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_customer_trx_line_id IN NUMBER,
                      p_inv_line_amount      IN NUMBER,
                      p_creation_sign       IN VARCHAR2 ,
                      p_allow_overappln_flag IN VARCHAR2,
                      p_natural_appln_only_flag IN VARCHAR2,
                      p_amount_due_remaining IN NUMBER,
                      p_return_status OUT NOCOPY VARCHAR2
                       )
IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_amount_applied ()+');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;


  IF p_amount_applied IS NULL THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_APPLIED_AMT_NULL');
     FND_MSG_PUB.Add;
     return;
  END IF;


  -- Should we check for natural application here???

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_amount_applied ()-');
  END IF;

END validate_amount_applied;



FUNCTION Get_trx_ps_id(p_inv_customer_trx_id IN OUT NOCOPY NUMBER,
                       p_installment     IN NUMBER,
                       p_return_status   OUT NOCOPY VARCHAR2
                       ) RETURN NUMBER IS
l_inv_ps_id  NUMBER;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_trx_ps_id ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_installment IS NOT NULL THEN
        BEGIN
         SELECT ps.payment_schedule_id
         INTO   l_inv_ps_id
         FROM   ra_customer_trx ct,
                ar_payment_schedules ps
         WHERE  ct.customer_trx_id = p_inv_customer_trx_id
           AND  ct.customer_trx_id = ps.customer_trx_id
           --AND  ps.class  IN ('CB','CM','DEP','DM','INV','BR')
           AND  ps.terms_sequence_number = p_installment
                ;
         EXCEPTION
          WHEN no_data_found THEN
            IF ar_cm_api_pub.Original_cm_unapp_info.inv_customer_trx_id IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_ID_INST_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF ar_cm_api_pub.Original_cm_unapp_info.inv_trx_number IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_INST_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

         END;
   ELSE
      --if the user has not entered the installment then if the transaction
      --has only one installment, get the ps_id for that installment
         BEGIN
           SELECT ps.payment_schedule_id
           INTO   l_inv_ps_id
           FROM   ra_customer_trx ct,
                  ar_payment_schedules ps
           WHERE  ct.customer_trx_id = p_inv_customer_trx_id
             AND  ct.customer_trx_id = ps.customer_trx_id
             --AND  ps.class  IN ('CB','CM','DEP','DM','INV','BR')
                  ;
         EXCEPTION
           WHEN no_data_found THEN
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
             FND_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
           WHEN too_many_rows THEN
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_INSTALL_NULL');
             FND_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
         END;


  END IF;

 RETURN(l_inv_ps_id);

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Get_trx_ps_id ()-');
 END IF;

EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Get_trx_ps_id()');
   END IF;
   raise;
END Get_trx_ps_id;

PROCEDURE get_ra_info(
                                   p_ra_id           IN NUMBER,
                                   p_ra_app_ps_id    OUT NOCOPY NUMBER,
                                   p_inv_customer_trx_id OUT NOCOPY NUMBER,
                                   p_apply_gl_date   OUT NOCOPY DATE,
                                   p_return_status   OUT NOCOPY VARCHAR2
                                       ) IS
CURSOR rec_apppln IS
SELECT ra.applied_customer_trx_id, ra.applied_payment_schedule_id, ra.gl_date
FROM   ar_receivable_applications ra,
       ar_payment_schedules ps
WHERE  ra.applied_payment_schedule_id = ps.payment_schedule_id
  AND  ra.receivable_application_id = p_ra_id
  AND  ra.display = 'Y'
  AND  ra.status = 'APP'
  AND  ps.reserved_value IS NULL
  AND  ps.reserved_type IS NULL;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('get_ra_info ()+');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN rec_apppln;
   FETCH rec_apppln INTO p_inv_customer_trx_id, p_ra_app_ps_id,p_apply_gl_date;
       IF rec_apppln%NOTFOUND  THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    CLOSE rec_apppln;


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_ra_info ()-');
     arp_util.debug('Applied PS ID: '|| p_ra_app_ps_id ||
                    'Applied Trx ID: '|| p_inv_customer_trx_id ||
                    'Apply GL date: '|| p_apply_gl_date);
  END IF;



END get_ra_info;

PROCEDURE default_ra_id(
                           p_cm_customer_trx_id          IN NUMBER,
                           p_applied_payment_schedule_id IN NUMBER,
                           p_apply_gl_date               OUT NOCOPY DATE,
                           p_receivable_application_id   OUT NOCOPY NUMBER,
                           p_return_status               OUT NOCOPY VARCHAR2
                           )  IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_ra_id ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_cm_customer_trx_id IS NOT NULL AND
     p_applied_payment_schedule_id IS NOT NULL
   THEN
      SELECT receivable_application_id, gl_date
      INTO   p_receivable_application_id, p_apply_gl_date
      FROM   ar_receivable_applications ra
      WHERE  ra.customer_trx_id = p_cm_customer_trx_id
        AND  ra.applied_payment_schedule_id = p_applied_payment_schedule_id
        AND  ra.display = 'Y'
        AND  ra.status = 'APP'
        AND  ra.application_type = 'CM';

   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_ra_id ()+');
  END IF;
EXCEPTION
 WHEN no_data_found THEN
  FND_MESSAGE.SET_NAME('AR','AR_CMAPI_CM_NOT_APP_TO_INV');
  FND_MSG_PUB.Add;
  p_return_status := FND_API.G_RET_STS_ERROR;
   raise;
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_ra_id: ' || 'EXCEPTION: Get_ra_id()');
   END IF;
   raise;
END default_ra_id;

PROCEDURE default_reversal_gl_date(
                        p_receivable_application_id IN NUMBER,
                        p_reversal_gl_date IN OUT NOCOPY DATE,
                        p_apply_gl_date IN OUT NOCOPY DATE,
                        p_cm_customer_trx_id IN OUT NOCOPY NUMBER
                                   ) IS
l_apply_gl_date     DATE;
l_default_gl_date   DATE;
l_defaulting_rule_used  VARCHAR2(100);
l_error_message  VARCHAR2(240);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_reversal_gl_date ()+');
  END IF;

    l_apply_gl_date := p_apply_gl_date;

    IF p_receivable_application_id IS NOT NULL THEN
     IF p_apply_gl_date  IS NULL THEN
      --get the gl_date for the application
      BEGIN
        SELECT gl_date, customer_trx_id
          INTO   l_apply_gl_date, p_cm_customer_trx_id
          FROM   ar_receivable_applications
         WHERE  receivable_application_id =
                   p_receivable_application_id;
       EXCEPTION
         WHEN OTHERS THEN
           NULL;
       END;
     END IF;

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
    END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_reversal_gl_date ()-');
  END IF;
EXCEPTION
 When others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Default_reversal_gl_date()');
    END IF;
    raise;
END Default_reversal_gl_date;


PROCEDURE Validate_ra_id(
                       p_receivable_application_id  IN  NUMBER,
                       p_application_type  IN VARCHAR2,
                       p_return_status OUT NOCOPY VARCHAR2) IS
l_valid NUMBER;
BEGIN
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_ra_id ()+');
  END IF;
   --validate the receivable application id only if it was passed in
   --directly as a parameter. No need to validate if it was derived.
   IF p_receivable_application_id IS NOT NULL AND
      ar_cm_api_pub.original_cm_unapp_info.receivable_application_id IS NOT NULL
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
    IF ar_cm_api_pub.original_cm_unapp_info.cm_trx_number IS NULL AND
       ar_cm_api_pub.original_cm_unapp_info.cm_customer_trx_id IS NULL AND
       ar_cm_api_pub.original_cm_unapp_info.applied_ps_id IS NULL AND
       ar_cm_api_pub.original_cm_unapp_info.inv_customer_trx_id IS NULL AND
       ar_cm_api_pub.original_cm_unapp_info.inv_trx_number  IS NULL
     THEN
     --receivable application id is null
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_NULL');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF ar_cm_api_pub.original_cm_unapp_info.inv_trx_number IS NULL AND
       ar_cm_api_pub.original_cm_unapp_info.inv_customer_trx_id IS NULL AND
       ar_cm_api_pub.original_cm_unapp_info.applied_ps_id IS NULL AND
       (ar_cm_api_pub.original_cm_unapp_info.cm_customer_trx_id IS NOT NULL OR
       ar_cm_api_pub.original_cm_unapp_info.cm_trx_number IS NOT NULL)
     THEN
     --the transaction was not specified
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_NULL');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF (ar_cm_api_pub.original_cm_unapp_info.inv_trx_number IS NOT NULL OR
       ar_cm_api_pub.original_cm_unapp_info.inv_customer_trx_id IS NOT NULL OR
       ar_cm_api_pub.original_cm_unapp_info.applied_ps_id IS NOT NULL) AND
       ar_cm_api_pub.original_cm_unapp_info.cm_customer_trx_id IS  NULL AND
       ar_cm_api_pub.original_cm_unapp_info.cm_trx_number IS  NULL
    THEN
    --the credit memo was not specified
        FND_MESSAGE.SET_NAME('AR','AR_CMAPI_CM_TRX_ID_NULL');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_receivable_appln_id ()-');
  END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Validate_ra_id(-)');
   END IF;
   raise;

END Validate_ra_id;


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
        FND_MESSAGE.SET_NAME('AR','AR_RW_BEFORE_CM_GL_DATE');
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
     arp_util.debug('Validate_Rev_gl_date ()+');
  END IF;
EXCEPTION
  WHEN others THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION: Validate_rev_gl_date() ');
      END IF;
      raise;
END Validate_Rev_gl_date;

-- PUBLIC PROCEDURES/FUNCTIONS

PROCEDURE default_app_ids(
                p_cm_customer_trx_id   IN OUT NOCOPY NUMBER,
                p_cm_trx_number        IN VARCHAR2,
                p_inv_customer_trx_id  IN OUT NOCOPY NUMBER,
                p_inv_trx_number       IN VARCHAR2,
                p_inv_customer_trx_line_id  IN OUT NOCOPY NUMBER,
                p_inv_line_number          IN NUMBER,
                p_installment       IN OUT NOCOPY NUMBER,
                p_applied_payment_schedule_id   IN NUMBER,
                p_return_status     OUT NOCOPY VARCHAR2 )

IS


CURSOR c_pay_sched IS
SELECT customer_trx_id, terms_sequence_number
FROM   ar_payment_schedules
WHERE  payment_schedule_id = p_applied_payment_schedule_id and
       payment_schedule_id >0 and
       class in ('INV','DM');  -- Should we include DM, DEP, GUAR, CB?

l_inv_customer_trx_id  NUMBER;
l_installment      NUMBER;
p_inv_return_status_lines  VARCHAR2(100);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('default_app_ids(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Step 1: Get a valid value for CM customer_trx_id
  IF  p_cm_trx_number  IS NOT NULL THEN
    default_customer_trx_id(p_cm_customer_trx_id ,
                            p_cm_trx_number ,
                            p_return_status);
  END IF;

  -- Step 2: Get a valid value for DM customer_trx_id
  IF  p_inv_trx_number  IS NOT NULL THEN
    default_customer_trx_id(p_inv_customer_trx_id ,
                            p_inv_trx_number ,
                            p_return_status);
  END IF;

   -- Step 3: Get a valid value for DM customer trx line id
   default_customer_trx_line_id(p_inv_customer_trx_id,
                                 p_inv_customer_trx_line_id,
                                 p_inv_line_number,
                                 p_inv_return_status_lines);

   -- Step 4: Get inv_customer_trx_id from applied_payment_schedule_id and
   --         installment

   IF p_applied_payment_schedule_id IS NOT NULL THEN
     OPEN c_pay_sched;
     FETCH c_pay_sched
      INTO l_inv_customer_trx_id,
           l_installment;
     IF c_pay_sched%NOTFOUND THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR ;
     END IF;
     CLOSE c_pay_sched;

     IF  p_return_status = FND_API.G_RET_STS_SUCCESS  THEN
      IF nvl(p_inv_customer_trx_id,nvl(l_inv_customer_trx_id,-99)) = nvl(l_inv_customer_trx_id,-99) THEN
        p_inv_customer_trx_id := l_inv_customer_trx_id;
      END IF;
      IF nvl(p_installment,nvl(l_installment,-99)) = nvl(l_installment,-99) THEN
         p_installment := l_installment;
      END IF;
    END IF;
   ELSE -- p_payment_schedule_id is null
     --default the installment from the customer_trx_id if not entered
     IF p_inv_customer_trx_id IS NOT NULL THEN
       IF p_installment IS NULL THEN
         BEGIN
          SELECT terms_sequence_number
          INTO   p_installment
          FROM   ar_payment_schedules
          WHERE  customer_trx_id = p_inv_customer_trx_id;
         EXCEPTION
          WHEN no_data_found THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
          WHEN too_many_rows THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_INSTALL_NULL');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
         END;
       END IF;
     END IF;
   END IF;


   IF (p_inv_return_status_lines = FND_API.G_RET_STS_ERROR OR
       p_return_status = FND_API.G_RET_STS_ERROR) THEN
       p_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_app_ids: ' || 'Defaulted Value for the application ids');
     arp_util.debug('Default_app_ids: ' || 'p_cm_customer_trx_id             :'||to_char(p_cm_customer_trx_id));
     arp_util.debug('Default_app_ids: ' || 'p_inv_customer_trx_id             :'||to_char(p_inv_customer_trx_id));
     arp_util.debug('Default_appln_ids: ' || 'p_installment                 :'||to_char(p_installment));
     arp_util.debug('Default_app_ids: ' || 'p_applied_payment_schedule_id :'||to_char(p_applied_payment_schedule_id));
     arp_util.debug('Default_app_ids ()- ');
  END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Default_appln_ids()');
   END IF;
   RAISE;

END Default_app_ids;


PROCEDURE default_app_info(
              p_cm_customer_trx_id  IN NUMBER,
              p_inv_customer_trx_id IN  NUMBER,
              p_inv_customer_trx_line_id  IN NUMBER,
              p_show_closed_invoices  IN VARCHAR2,
              p_installment         IN OUT NOCOPY NUMBER,
              p_apply_date           IN OUT NOCOPY DATE,
              p_apply_gl_date        IN OUT NOCOPY DATE,
              p_amount_applied       IN OUT NOCOPY NUMBER,
              p_applied_payment_schedule_id IN OUT NOCOPY NUMBER,
              p_cm_gl_date          OUT NOCOPY DATE,
              p_cm_trx_date         OUT NOCOPY DATE,
              p_cm_amount_rem       OUT NOCOPY NUMBER,
              p_cm_currency_code    OUT NOCOPY VARCHAR2,
              p_inv_due_date         OUT NOCOPY DATE,
              p_inv_currency_code    OUT NOCOPY VARCHAR2,
              p_inv_amount_rem       OUT NOCOPY NUMBER,
              p_inv_trx_date         OUT NOCOPY DATE,
              p_inv_gl_date          OUT NOCOPY DATE,
              p_allow_overappln_flag OUT NOCOPY VARCHAR2,
              p_natural_appln_only_flag  OUT NOCOPY VARCHAR2,
              p_creation_sign        OUT NOCOPY VARCHAR2,
              p_cm_payment_schedule_id  OUT NOCOPY NUMBER,
              p_inv_line_amount       OUT NOCOPY NUMBER,
              p_return_status    OUT NOCOPY VARCHAR2
               )
IS

l_cm_gl_date      DATE;
l_cm_amount_rem   NUMBER;
l_cm_trx_date     DATE;
l_cm_ps_id        NUMBER;
l_cm_currency_code     fnd_currencies.currency_code%TYPE;
l_cm_customer_id      NUMBER;
l_cm_info_return_status  VARCHAR2(1);

l_inv_customer_id    NUMBER;  --customer on transaction
l_inv_cust_trx_type_id     NUMBER;
l_inv_due_date             DATE;
l_inv_trx_date             DATE;
l_inv_gl_date              DATE;
l_allow_overappln_flag     VARCHAR2(1);
l_natural_appln_only_flag  VARCHAR2(1);
l_creation_sign            VARCHAR2(1);
--l_applied_payment_schedule_id  NUMBER;
l_app_gl_date              DATE;
l_inv_amount_rem           NUMBER;
l_trx_info_return_status   VARCHAR2(1);
l_inv_line_amount           NUMBER;

l_inv_currency_code     fnd_currencies.currency_code%TYPE;
l_def_amt_return_status VARCHAR2(1);

l_return  BOOLEAN;
l_default_gl_date  DATE;
l_defaulting_rule_used VARCHAR2(100);
l_error_message  VARCHAR2(200);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_app_info ()+');
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Step 1: Default CM Info:
   default_cm_info(
          p_cm_customer_trx_id,
          l_cm_gl_date,
          l_cm_amount_rem,
          l_cm_trx_date,
          l_cm_ps_id,
          l_cm_currency_code,
          l_cm_customer_id,
          l_cm_info_return_status );

   IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_app_info: ' || 'Default_CM_Info return status = '||l_cm_info_return_status);
   END IF;

   -- Step 2: Default DM info

   IF l_cm_info_return_status = FND_API.G_RET_STS_SUCCESS  THEN
      Default_Trx_Info(
            p_inv_customer_trx_id     ,
            p_inv_customer_trx_line_id ,
            p_show_closed_invoices     ,
            l_cm_gl_date               ,
            l_cm_customer_id           ,
            l_cm_currency_code         ,
            l_cm_ps_id                 ,
            l_cm_trx_date              ,
            --- Out variables
            l_inv_customer_id          , --customer on transaction
            l_inv_cust_trx_type_id     ,
            l_inv_due_date             ,
            l_inv_trx_date             ,
            l_inv_gl_date              ,
            l_allow_overappln_flag     ,
            l_natural_appln_only_flag  ,
            l_creation_sign            ,
            p_applied_payment_schedule_id  ,
            l_app_gl_date              , --this is the application gl_date
            p_installment              ,
            l_inv_amount_rem             ,
            l_inv_currency_code        ,
            l_trx_info_return_status
      );


   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_app_info: ' || 'Default trx info return status = '||l_trx_info_return_status);
      arp_util.debug('Applied PS ID : ' || p_applied_payment_schedule_id);
   END IF;


   -- Step 3: Default apply date

    IF p_apply_date IS NULL THEN
      p_apply_date := GREATEST(sysdate,
                               GREATEST(NVL(l_cm_trx_date,sysdate),
                                        NVL(l_inv_trx_date,sysdate)));
    END IF;


   -- Step 4: Default GL Date

   IF p_apply_gl_date IS NULL THEN
      l_return :=
              arp_util.validate_and_default_gl_date(
                  gl_date                => l_app_gl_date,
                  trx_date               => null,
                  validation_date1       => null,
                  validation_date2       => null,
                  validation_date3       => null,
                  default_date1          => l_app_gl_date,
                  default_date2          => null,
                  default_date3          => null,
                  p_allow_not_open_flag  => 'N',
                  p_invoicing_rule_id    => null,
                  p_set_of_books_id      => arp_global.set_of_books_id,
                  p_application_id       => 222,
                  default_gl_date        => l_default_gl_date ,
                  defaulting_rule_used   => l_defaulting_rule_used,
                  error_message          => l_error_message);

             IF l_return = TRUE  THEN
               p_apply_gl_date := l_default_gl_date;
             END IF;

    END IF;


   -- Step 5: Default amount applied
   default_amt_applied(
                 l_inv_currency_code ,
                 l_cm_currency_code  ,
                 l_cm_amount_rem        ,
                 l_inv_amount_rem       ,
                 p_amount_applied    ,
                 l_def_amt_return_status
     );


              p_cm_gl_date         := l_cm_gl_date;
              p_cm_trx_date        := l_cm_trx_date;
              p_cm_amount_rem      := l_cm_amount_rem;
              p_cm_currency_code   := l_cm_currency_code;
              p_inv_due_date       := l_inv_due_date;
              p_inv_currency_code  := l_inv_currency_code;
              p_inv_amount_rem      := l_inv_amount_rem;
              p_inv_trx_date       := l_inv_trx_date;
              p_inv_gl_date        := l_inv_gl_date;
              p_allow_overappln_flag := l_allow_overappln_flag;
              p_natural_appln_only_flag  := l_natural_appln_only_flag;
              p_creation_sign        := l_creation_sign;
              p_cm_payment_schedule_id  := l_cm_ps_id;
              p_inv_line_amount       := l_inv_line_amount;



    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_appl_info: ' || 'Default amount return status :'||l_def_amt_return_status );
    END IF;


END default_app_info;


PROCEDURE validate_app_info(
                      p_apply_date   IN DATE,
                      p_cm_trx_date  IN DATE,
                      p_inv_trx_date IN DATE,
                      p_apply_gl_date IN DATE,
                      p_cm_gl_date    IN DATE,
                      p_inv_gl_date   IN DATE,
                      p_amount_applied IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_customer_trx_line_id  IN NUMBER,
                      p_inv_line_amount   IN NUMBER,
                      p_creation_sign   IN VARCHAR2,
                      p_allow_overappln_flag  IN VARCHAR2,
                      p_natural_appln_only_flag  IN VARCHAR2,
                      p_cm_amount_rem    IN NUMBER,
                      p_inv_amount_rem   IN NUMBER,
                      p_cm_currency_code IN VARCHAR2,
                      p_inv_currency_code IN VARCHAR2,
                      p_return_status     OUT NOCOPY VARCHAR2
     ) IS

l_gl_date_return_status  VARCHAR2(1);
l_amt_applied_return_status VARCHAR2(1);
l_apply_date_return_status   VARCHAR2(1);


BEGIN

    -- Validations of cm_customer_trx_id, inv_customer_trx_id,
    -- applied_payment_schedule_id are done in defaulting routines

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_App_info ()+');
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    validate_apply_date(p_apply_date,
                         p_inv_trx_date,
                         p_cm_trx_date,
                         l_apply_date_return_status
                         );

    validate_apply_gl_date(p_apply_gl_date ,
                           p_inv_gl_date ,
                           p_cm_gl_date  ,
                           l_gl_date_return_status
                                 );

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_Application_info: ' || 'Apply gl_date return status :'||l_gl_date_return_status);
   END IF;
        validate_amount_applied(
                     p_amount_applied ,
                      p_applied_payment_schedule_id ,
                      p_customer_trx_line_id ,
                      p_inv_line_amount      ,
                      p_creation_sign        ,
                      p_allow_overappln_flag ,
                      p_natural_appln_only_flag ,
                      p_inv_amount_rem ,
                      l_amt_applied_return_status
                       );
    IF l_gl_date_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_amt_applied_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_apply_date_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_App_info ()-');
    END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Validate_App_Info() ');
  END IF;
  raise;


END validate_app_info;

PROCEDURE Default_unapp_ids(
                   p_cm_trx_number                   IN VARCHAR2,
                   p_cm_customer_trx_id              IN OUT NOCOPY NUMBER,
                   p_inv_trx_number                   IN VARCHAR2,
                   p_inv_customer_trx_id              IN OUT NOCOPY NUMBER,
                   p_receivable_application_id    IN OUT NOCOPY NUMBER,
                   p_installment                  IN NUMBER,
                   p_applied_payment_schedule_id  IN OUT NOCOPY NUMBER,
                   p_apply_gl_date                OUT NOCOPY DATE,
                   p_return_status                OUT NOCOPY VARCHAR2
                   ) IS

CURSOR c_pay_sched IS
SELECT customer_trx_id, terms_sequence_number
FROM   ar_payment_schedules
WHERE  payment_schedule_id = p_applied_payment_schedule_id and
       payment_schedule_id >0 and
       class in ('INV','DM');  -- Should we include BR, DEP, GUAR, CB?


l_cm_cust_trx_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_inv_cust_trx_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_applied_ps_id_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_inv_customer_trx_id    NUMBER;
l_applied_payment_schedule_id NUMBER;
l_ra_app_ps_id                NUMBER;
l_receivable_application_id   NUMBER;
l_installment                 NUMBER(15);
l_ra_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_unapp_ids ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --Step 1: Get a valid value for the CM customer_trx_id
  IF p_cm_trx_number IS NOT NULL THEN
    Default_customer_trx_id(p_cm_customer_trx_id ,
                            p_cm_trx_number ,
                            l_cm_cust_trx_return_status);
  END IF;

  -- Step 2: Get a valid value for DM customer_trx_id
  IF  p_inv_trx_number  IS NOT NULL THEN
    default_customer_trx_id(p_inv_customer_trx_id ,
                            p_inv_trx_number ,
                            l_inv_cust_trx_return_status);
  END IF;


  -- Step 3: Get payment schedule info
  --if error is raised in deriving the customer_trx_id from the trx_number,
  --do not process the applied_payment_schedule_id any further.
  IF l_cm_cust_trx_return_status= FND_API.G_RET_STS_SUCCESS AND
     l_inv_cust_trx_return_status= FND_API.G_RET_STS_SUCCESS THEN
    IF  p_applied_payment_schedule_id IS NOT NULL THEN
      OPEN c_pay_sched;
      FETCH c_pay_sched
       INTO l_inv_customer_trx_id,
            l_installment;
      IF c_pay_sched%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
      CLOSE c_pay_sched;

     IF  p_return_status = FND_API.G_RET_STS_SUCCESS  THEN
        IF (nvl(p_inv_customer_trx_id,l_inv_customer_trx_id) <> l_inv_customer_trx_id OR
          nvl(p_installment,l_installment)  <>  l_installment) THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_PS_ID_X_INVALID');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
           p_inv_customer_trx_id := l_inv_customer_trx_id;
       END IF;

     END IF;
   ELSE -- p_applied_ayment_schedule_id is null
      IF p_inv_customer_trx_id IS NOT NULL THEN
        l_applied_payment_schedule_id :=
                      Get_trx_ps_id(p_inv_customer_trx_id,
                                    p_installment,
                                    l_applied_ps_id_return_status);
        p_applied_payment_schedule_id
                          :=l_applied_payment_schedule_id;
      END IF;
   END IF;

  END IF;

  -- Step 4: get related info for receivable_application_id

  IF p_receivable_application_id IS NOT NULL THEN
       get_ra_info(p_receivable_application_id,
                   l_ra_app_ps_id,
                   l_inv_customer_trx_id,
                   p_apply_gl_date,
                   l_ra_return_status);

      IF nvl( l_ra_app_ps_id,-99) <> nvl(p_applied_payment_schedule_id,
                                                    nvl( l_ra_app_ps_id,-99))
       THEN
        IF ar_cm_api_pub.original_cm_unapp_info.inv_customer_trx_id IS NOT NULL OR
           ar_cm_api_pub.original_cm_unapp_info.inv_trx_number IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_RA_ID_X_INVALID');
            FND_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF ar_cm_api_pub.original_cm_unapp_info.applied_ps_id IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_RA_ID_X_INVALID');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      ELSE
        p_applied_payment_schedule_id := l_ra_app_ps_id;
      END IF;

       IF nvl(l_inv_customer_trx_id,-99) <> nvl(p_inv_customer_trx_id,nvl(l_inv_customer_trx_id,-99)) THEN
        --Invalid receivable application identifier for the entered
        -- invoice customer trx id
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_RA_ID_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        p_inv_customer_trx_id := l_inv_customer_trx_id;
      END IF;
  ELSE --the user has not passed in the receivable application id
   --
   -- derive receivable_application_id
   --
   --If app_ps_id and the cash_receipt_id are not null then
   --get the default receivable_application_id which will be
   --used for defaulting or cross-validation
    IF p_cm_customer_trx_id IS NOT NULL AND
       p_applied_payment_schedule_id IS NOT NULL
     THEN
       --derive the receivable application id using the CM customer trx id
       --and the applied payment schedule id
                    default_ra_id(
                                  p_cm_customer_trx_id,
                                  p_applied_payment_schedule_id,
                                  p_apply_gl_date,
                                  l_receivable_application_id,
                                  l_ra_return_status);
              p_receivable_application_id := l_receivable_application_id;
    END IF;

  END IF;


END default_unapp_ids;


PROCEDURE Default_unapp_info(
                        p_receivable_application_id IN NUMBER,
                        p_apply_gl_date    IN  DATE,
                        p_cm_customer_trx_id  IN  NUMBER,
                        p_reversal_gl_date IN OUT NOCOPY DATE,
                        p_cm_gl_date  OUT NOCOPY DATE
                          ) IS
l_cm_customer_trx_id   NUMBER(15);
l_apply_gl_date        DATE;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_unapp_info ()+');
  END IF;

  l_apply_gl_date := p_apply_gl_date;
  l_cm_customer_trx_id := p_cm_customer_trx_id;

  default_reversal_gl_date(p_receivable_application_id,
                           p_reversal_gl_date,
                           l_apply_gl_date,
                           l_cm_customer_trx_id);

  --default the cm gl date which is to be used later
  --in the validation of the reversal gl date.
    IF  p_cm_gl_date IS NULL AND
        l_cm_customer_trx_id IS NOT NULL
      THEN
       BEGIN
         SELECT gl_date
         INTO   p_cm_gl_date
         FROM   ar_payment_schedules
         WHERE  customer_trx_id  = l_cm_customer_trx_id;
       EXCEPTION
         WHEN no_data_found THEN
          null;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_unapp_info: ' || 'Could not get the cm_gl_date. ');
          END IF;
       END;
    END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_unapp_info ()-');
  END IF;

END default_unapp_info;

PROCEDURE Validate_unapp_info(
                      p_cm_gl_date             IN DATE,
                      p_receivable_application_id   IN NUMBER,
                      p_reversal_gl_date            IN DATE,
                      p_apply_gl_date               IN DATE,
                      p_return_status               OUT NOCOPY VARCHAR2
                      ) IS
l_rec_app_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_rev_gl_date_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_unapp_info ()+');
   END IF;

   --In case the user has entered the receivable application id
   -- as well as the receipt and transaction info, then the cross validation
   --is done at the defaulting phase itself so no need to do that here.
                  Validate_ra_id(
                                p_receivable_application_id,
                                'APP',
                               l_rec_app_return_status);

     Validate_rev_gl_date( p_reversal_gl_date ,
                                p_apply_gl_date ,
                                p_cm_gl_date,
                                l_rev_gl_date_return_status
                                  );
END validate_unapp_info;

END AR_CM_VAL_PVT;

/
