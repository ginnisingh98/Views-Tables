--------------------------------------------------------
--  DDL for Package Body ARP_DEDUCTION_COVER2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DEDUCTION_COVER2" AS
/* $Header: ARXDC2VB.pls 120.2 2005/10/30 03:59:28 appldev noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
  G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ARP_DEDUCTION_COVER2';
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/


/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE reapply_credit_memo
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure calls entity handlers to unapply and reapply a
 |      credit memo with a revised amount applied.
 |      Typically for an on account credit memo used to settle
 |	more than 1 deduction on the same receipt.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_customer_trx_id    IN    Transaction  being reapplied
 |      p_cash_receipt_id    IN    Receipt to which it is applied
 |      p_amount_applied     IN    New amount applied
 |      p_init_msg_list      IN
 |      x_return_status      OUT NOCOPY
 |      x_msg_count          OUT NOCOPY
 |      x_msg_data           OUT NOCOPY
 |
 | KNOWN ISSUES                                                                  |
 | NOTES:  This is a group API intended for use by Trade Management only
 |
 | MODIFICATION HISTORY
 | Date          Author            Description of Changes
 | 01-APR-2005   jbeckett          Created
 |
 *=======================================================================*/
PROCEDURE reapply_credit_memo(
                p_customer_trx_id IN  NUMBER,
                p_cash_receipt_id IN  NUMBER,
                p_amount_applied  IN  NUMBER,
                p_init_msg_list   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                x_return_status   OUT NOCOPY VARCHAR2,
                x_msg_count       OUT NOCOPY NUMBER,
                x_msg_data        OUT NOCOPY VARCHAR2)
IS
   l_receipt_number                ar_cash_receipts.receipt_number%TYPE;
   l_receipt_date                  DATE;
   l_currency_code                 ar_cash_receipts.currency_code%TYPE;
   l_cr_gl_date                    DATE;
   l_cr_payment_schedule_id        NUMBER;
   l_customer_id                   NUMBER;
   l_ra_id			   NUMBER;
   l_ra_rec                        ar_receivable_applications%ROWTYPE;
   l_default_gl_date               DATE;
   l_defaulting_rule_used          VARCHAR2(100);
   l_bal_due_remaining             NUMBER;
   l_attribute_rec                 ar_receipt_api_pub.attribute_rec_type;
   l_global_attribute_rec          ar_receipt_api_pub.global_attribute_rec_type;

   l_error_message                 VARCHAR2(2000);
   l_error_count                   NUMBER := 0;
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000);
   l_return_status                 VARCHAR2(1);
   l_api_name                      CONSTANT VARCHAR2(30)
                                            := 'reapply_credit_memo';

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER2.reapply_credit_memo()+');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT	reapply_credit_memo_pvt;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*  initialize global variables */
  arp_global.init_global;
  arp_standard.init_standard;

 /*---------------------------------------------------------------------+
  | 1) Check that a valid receipt has been passed                       |
  +---------------------------------------------------------------------*/
  IF NOT arp_deduction_cover.receipt_valid
       (p_cash_receipt_id          =>  p_cash_receipt_id,
        x_receipt_number           =>  l_receipt_number,
        x_receipt_date             =>  l_receipt_date,
        x_cr_gl_date               =>  l_cr_gl_date,
        x_customer_id              =>  l_customer_id,
	x_currency_code            =>  l_currency_code,
        x_cr_payment_schedule_id   =>  l_cr_payment_schedule_id)
  THEN
    l_error_count := l_error_count + 1;
  END IF;

 /*---------------------------------------------------------------------+
  | 2) Check that a valid applied credit memo has been passed           |
  +---------------------------------------------------------------------*/
  BEGIN
    SELECT ra.receivable_application_id
    INTO   l_ra_id
    FROM   ar_receivable_applications ra
         , ar_payment_schedules ps
    WHERE  ps.payment_schedule_id = ra.applied_payment_schedule_id
    AND    ra.cash_receipt_id =  p_cash_receipt_id
    AND    ra.status = 'APP'
    AND    ps.customer_trx_id = p_customer_trx_id
    AND    ra.display = 'Y'
    AND    ps.class = 'CM';
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR','ARTA_PAYMENT_SCHEDULE_NO_FOUND');
      FND_MSG_PUB.Add;
      l_error_count := l_error_count + 1;
  END;

  arp_app_pkg.fetch_p( l_ra_id, l_ra_rec );
  l_ra_rec.amount_applied_from := p_amount_applied * l_ra_rec.trans_to_receipt_rate;

 /*---------------------------------------------------------------------+
  | 3) Default the GL date
  +---------------------------------------------------------------------*/
  IF (arp_util.validate_and_default_gl_date(
                nvl(l_ra_rec.gl_date,trunc(sysdate)),
                NULL,
                l_ra_rec.gl_date,
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
           NULL;
  ELSE
         --we were not able to default the gl_date
         --message put on the stack
           FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
           FND_MSG_PUB.Add;
           l_error_count := l_error_count + 1;
  END IF;

 /*---------------------------------------------------------------------+
  | 4) Raise error if validation errors found                           |
  +---------------------------------------------------------------------*/
  IF (l_error_count > 0)
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 /*---------------------------------------------------------------------+
  | 5) Call the entity handler to unapply                               |
  +---------------------------------------------------------------------*/
  --lock the receipt before calling the entity handler
       arp_cash_receipts_pkg.nowaitlock_p(p_cr_id => p_cash_receipt_id);
  /* lock the payment schedule of the applied transaction */
       arp_ps_pkg.nowaitlock_p (p_ps_id => l_ra_rec.applied_payment_schedule_id);


  BEGIN
    --call the entity handler.
    arp_process_application.reverse(
                                l_ra_id,
                                l_default_gl_date,
                                trunc(sysdate),
                                'RAPI',
                                1.0,
                                l_bal_due_remaining,
                                'TRADE_MANAGEMENT'  );
  EXCEPTION
      WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                     ROLLBACK TO reapply_credit_memo_pvt;

                      --  Display_Parameters;
                      x_return_status := FND_API.G_RET_STS_ERROR ;
                       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ARP_DEDUCTION_COVER2.reapply_credit_memo : '||SQLERRM);
                       FND_MSG_PUB.Add;

                       FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                                  p_count  =>  x_msg_count,
                                                  p_data   => x_msg_data
                                                );
                      RETURN;
                ELSE
                   RAISE;
                END IF;

       END;

 /*---------------------------------------------------------------------+
  | 6) Call the receipt API to reapply                               |
  +---------------------------------------------------------------------*/
      l_attribute_rec.attribute_category := l_ra_rec.attribute_category;
      l_attribute_rec.attribute1 := l_ra_rec.attribute1;
      l_attribute_rec.attribute2 := l_ra_rec.attribute2;
      l_attribute_rec.attribute3 := l_ra_rec.attribute3;
      l_attribute_rec.attribute4 := l_ra_rec.attribute4;
      l_attribute_rec.attribute5 := l_ra_rec.attribute5;
      l_attribute_rec.attribute6 := l_ra_rec.attribute6;
      l_attribute_rec.attribute7 := l_ra_rec.attribute7;
      l_attribute_rec.attribute8 := l_ra_rec.attribute8;
      l_attribute_rec.attribute9 := l_ra_rec.attribute9;
      l_attribute_rec.attribute10 := l_ra_rec.attribute10;
      l_attribute_rec.attribute11 := l_ra_rec.attribute11;
      l_attribute_rec.attribute12 := l_ra_rec.attribute12;
      l_attribute_rec.attribute13 := l_ra_rec.attribute13;
      l_attribute_rec.attribute14 := l_ra_rec.attribute14;
      l_attribute_rec.attribute15 := l_ra_rec.attribute15;

      l_global_attribute_rec.global_attribute_category := l_ra_rec.global_attribute_category;
      l_global_attribute_rec.global_attribute1 := l_ra_rec.global_attribute1;
      l_global_attribute_rec.global_attribute2 := l_ra_rec.global_attribute2;
      l_global_attribute_rec.global_attribute3 := l_ra_rec.global_attribute3;
      l_global_attribute_rec.global_attribute4 := l_ra_rec.global_attribute4;
      l_global_attribute_rec.global_attribute5 := l_ra_rec.global_attribute5;
      l_global_attribute_rec.global_attribute6 := l_ra_rec.global_attribute6;
      l_global_attribute_rec.global_attribute7 := l_ra_rec.global_attribute7;
      l_global_attribute_rec.global_attribute8 := l_ra_rec.global_attribute8;
      l_global_attribute_rec.global_attribute9 := l_ra_rec.global_attribute9;
      l_global_attribute_rec.global_attribute10 := l_ra_rec.global_attribute10;
      l_global_attribute_rec.global_attribute11 := l_ra_rec.global_attribute11;
      l_global_attribute_rec.global_attribute12 := l_ra_rec.global_attribute12;
      l_global_attribute_rec.global_attribute13 := l_ra_rec.global_attribute13;
      l_global_attribute_rec.global_attribute14 := l_ra_rec.global_attribute14;
      l_global_attribute_rec.global_attribute15 := l_ra_rec.global_attribute15;
      l_global_attribute_rec.global_attribute16 := l_ra_rec.global_attribute16;
      l_global_attribute_rec.global_attribute17 := l_ra_rec.global_attribute17;
      l_global_attribute_rec.global_attribute18 := l_ra_rec.global_attribute18;
      l_global_attribute_rec.global_attribute19 := l_ra_rec.global_attribute19;
      l_global_attribute_rec.global_attribute20 := l_ra_rec.global_attribute20;

      ar_receipt_api_pub.apply     (
      p_api_version                  =>  1.0,
      p_init_msg_list                =>  FND_API.G_FALSE,
      x_return_status                =>  l_return_status,
      x_msg_count                    =>  l_msg_count,
      x_msg_data                     =>  l_msg_data,
      p_cash_receipt_id              =>  p_cash_receipt_id,
      p_customer_trx_id              =>  p_customer_trx_id,
      p_amount_applied               =>  p_amount_applied,
      p_amount_applied_from          =>  l_ra_rec.amount_applied_from,
      p_trans_to_receipt_rate        =>  l_ra_rec.trans_to_receipt_rate ,
      p_apply_date                   =>  l_ra_rec.apply_date,
      p_apply_gl_date                =>  l_default_gl_date,
      p_called_from		     =>  'TRADE_MANAGEMENT',
      p_attribute_rec                =>  l_attribute_rec,
      p_global_attribute_rec         =>  l_global_attribute_rec,
      p_comments                     =>  l_ra_rec.comments);
  IF l_return_status = 'E'
  THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = 'U'
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_DEDUCTION_COVER2.reapply_credit_memo()-');
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO reapply_credit_memo_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('reapply_credit_memo: ' || 'Unexpected error '||sqlerrm||
                ' at arp_deduction_cover2.reapply_credit_memo()+');
                END IF;
                ROLLBACK TO reapply_credit_memo_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                           (p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count,
                            p_data    => x_msg_data);
    WHEN OTHERS THEN
                IF (SQLCODE = -20001)
                THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('reapply_credit_memo: ' || '20001 error '||
                    ' at arp_deduction_cover2.reapply_credit_memo()+');
                  END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR ;
               ELSE
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('reapply_credit_memo: ' || 'Unexpected error '||sqlerrm||
                   ' at arp_deduction_cover2.reapply_credit_memo()+');
                 END IF;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                 IF    FND_MSG_PUB.Check_Msg_Level
                       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                 THEN
                       FND_MSG_PUB.Add_Exc_Msg
                       (       G_PKG_NAME          ,
                               l_api_name
                       );
                 END IF;
               END IF;
               ROLLBACK TO reapply_credit_memo_pvt;
               FND_MSG_PUB.Count_And_Get
                          (p_encoded => FND_API.G_FALSE,
                           p_count   => x_msg_count,
                           p_data    => x_msg_data);
END reapply_credit_memo;


END ARP_DEDUCTION_COVER2;

/
