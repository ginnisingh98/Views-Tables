--------------------------------------------------------
--  DDL for Package Body AR_PREPAYMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_PREPAYMENTS" AS
/* $Header: ARPREPYB.pls 120.21.12010000.4 2009/12/19 11:39:12 spdixit ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'AR_PREPAYMENTS';
G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;



/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

 --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
 PG_DEBUG varchar2(1) := 'Y';


/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/
  /*===========================================================================+
 | PORCEDURE                                                                 |
 |    check_rec_in_doubt                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function checks if given receipt is doubt                         |
 |    Given receipt can be in doubt for any of the following reasons         |
 |    . If receipt is a CC receipt and is not remitted                       |
 |    . If receipt has Special application of Claims Investigation           |
 |    . If the receipt is Debit Memo reversed                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN  : p_cash_receipt_id                                      |
 |                                                                           |
 |            : OUT : x_rec_in_doubt (Y/N)                                   |
 |              OUT : x_rid_reason                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |            This is same as arp_process_returns.check_rec_in_doubt         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     22-MAR-04    Jyoti Pandey    created                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE check_rec_in_doubt(p_cash_receipt_id IN NUMBER,
                             x_rec_in_doubt OUT NOCOPY VARCHAR2,
                             x_rid_reason OUT NOCOPY VARCHAR2) IS
BEGIN
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ar_prepayments.check_rec_in_doubt()+ ');
   END IF;
   ---
   x_rec_in_doubt := 'N';
   x_rid_reason   := null;
   ---
   --- For CC receipts, receipt should be remitted
   ---
    BEGIN
      SELECT 'Y', arp_standard.fnd_message('AR_RID_NOT_REMITTED_OR_CLEARED')
      INTO   x_rec_in_doubt, x_rid_reason
      FROM   dual
      WHERE
         (
           NOT EXISTS
           (
             SELECT 1
             FROM  AR_CASH_RECEIPT_HISTORY crh
             WHERE crh.cash_receipt_id = p_cash_receipt_id
             AND   crh.status IN ('REMITTED', 'CLEARED')
           )
         );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         arp_standard.debug('Unexpected error '||sqlerrm||
            ' occurred in ar_prepayments.check_rec_in_doubt');
         RAISE;
   END;

   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('After REFUND x_rec_in_doubt[x_rid_reason]: ' || x_rec_in_doubt ||
      '[' || x_rid_reason || ']');
   END IF;
   ---
   ---
   --- There should not be any Claims Investigation or CB special application
   ---
   BEGIN
      SELECT 'Y', arp_standard.fnd_message('AR_RID_CLAIM_OR_CB_APP_EXISTS')
      INTO   x_rec_in_doubt, x_rid_reason
      FROM   dual
      WHERE
           EXISTS
           (
             SELECT 1
             FROM   ar_receivable_applications ra
             WHERE  ra.cash_receipt_id = p_cash_receipt_id
             AND    applied_payment_schedule_id IN (-4,  -5)
             AND    display = 'Y'
           );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         arp_standard.debug('Unexpected error '||sqlerrm||
            ' occurred in ar_prepayments.check_rec_in_doubt');
         RAISE;
   END;

   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('After CLAIMS x_rec_in_doubt[x_rid_reason]: ' ||
         x_rec_in_doubt || '[' || x_rid_reason || ']');
   END IF;
   ---
   ---
   --- Receipt should not be reversed
   ---
    BEGIN
      SELECT 'Y', arp_standard.fnd_message('AR_RID_RECEIPT_REVERSED')
      INTO   x_rec_in_doubt, x_rid_reason
      FROM   dual
      WHERE
           EXISTS
           (
             SELECT 1
             FROM   ar_cash_receipts cr1
             WHERE  cr1.cash_receipt_id = p_cash_receipt_id
             AND    cr1.reversal_date is not null
           );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         arp_standard.debug('Unexpected error '||sqlerrm||
            ' occurred in ar_prepayments.check_rec_in_doubt');
         RAISE;
   END;

   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('After DM reverse x_rec_in_doubt[x_rid_reason]: ' ||
      x_rec_in_doubt || '[' || x_rid_reason || ']');
   END IF;
   ---
<<end_of_proc>>
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ar_prepayments.check_rec_in_doubt()- ');
   END IF;
   ---
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('Unexpected error '||sqlerrm||
         ' occurred in arp_process_returns.check_rec_in_doubt');
      RAISE;
END check_rec_in_doubt;


 PROCEDURE Process_Prepayments(
    -- Standard API parameters.
      p_api_version          IN  NUMBER,
      p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      p_receipt_number       IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_cash_receipt_id      IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receivable_application_id  IN  ar_receivable_applications.
                                   receivable_application_id%TYPE DEFAULT NULL,
      p_receivables_trx_id IN ar_receivable_applications.receivables_trx_id%TYPE,
      p_refund_amount IN ar_receivable_applications.amount_applied%TYPE
                         DEFAULT NULL,
      p_refund_date    IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_refund_gl_date IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code   IN ar_receivable_applications.
                                    ussgl_transaction_code%TYPE DEFAULT NULL,
      p_attribute_rec            IN ar_receipt_api_pub.attribute_rec_type
                                 DEFAULT ar_receipt_api_pub.attribute_rec_const,
    -- ******* Global Flexfield parameters *******
      p_global_attribute_rec IN ar_receipt_api_pub.global_attribute_rec_type
                             DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments         IN ar_receivable_applications.comments%TYPE DEFAULT NULL,

   --Multiple Prapayments project, refund of type Credit card or on account
      p_refund_type      IN VARCHAR2 DEFAULT NULL,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      p_prepay_application_id    OUT NOCOPY ar_receivable_applications.
                                            receivable_application_id%TYPE
    ) IS

l_ra_rec                        ar_receivable_applications%ROWTYPE;
l_attribute_rec                 ar_receipt_api_pub.attribute_rec_type;
l_global_attribute_rec          ar_receipt_api_pub.global_attribute_rec_type;

l_cash_receipt_id           NUMBER;
l_applied_ps_id             NUMBER;
l_receivable_application_id NUMBER;
l_receivables_trx_id         NUMBER;
l_apply_gl_date             DATE;
l_def_return_status         VARCHAR2(1);
l_def_activity_return_status VARCHAR2(1);
l_payment_type_return_status VARCHAR2(1);
l_val_return_status         VARCHAR2(1);
l_reapply_amount            ar_receivable_applications.amount_applied%TYPE;
l_payment_set_id            ar_receivable_applications.payment_set_id%TYPE;
l_refund_amount             NUMBER;
l_application_ref_type ar_receivable_applications.application_ref_type%TYPE;
l_application_ref_id   ar_receivable_applications.application_ref_id%TYPE;
l_application_ref_num  ar_receivable_applications.application_ref_num%TYPE;
l_secondary_application_ref_id ar_receivable_applications.secondary_application_ref_id%TYPE;

--Multiple Prepayments project
l_rec_in_doubt VARCHAR2(1) := 'N';
l_rid_reason   VARCHAR2(2000) := ' ';
l_comments ar_receivable_applications.comments%TYPE;
l_refund_type VARCHAR2(30) := null;

l_cr_unapp_amount   NUMBER; /* Bug fix 3569640 */

--Bug 3628401
l_ra_refund_rec        ar_receivable_applications%ROWTYPE;
l_on_acc_rec_app_id    ar_receivable_applications.receivable_application_id%type;
l_actual_refund_amount ar_receivable_applications.amount_applied%TYPE;

BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('process_prepayments: ' ||
                      'ar_prepayments.process prepayment (+)');
     END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_cash_receipt_id           := p_cash_receipt_id;
        l_receivable_application_id := p_receivable_application_id;
        l_refund_amount             := p_refund_amount;
        l_receivables_trx_id        := p_receivables_trx_id;
        l_refund_type               := p_refund_type;


        /*----------------------------------------------------
        Check if there is enough prepayment amount
        to refund on the receipt.
        ----------------------------------------------------*/
        ar_receipt_val_pvt.validate_prepay_amount(
                         p_receipt_number    ,
                         l_cash_receipt_id   ,
                        -7,--Prepayment
                         l_receivable_application_id ,
                         l_refund_amount  ,
                         l_val_return_status
                         );

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('process_prepayments: ' ||
                          'Validate Prepaymet amount return status :'||
                           l_val_return_status);
        END IF;

        ar_receipt_lib_pvt.derive_otheraccount_ids(
                         p_receipt_number   ,
                         l_cash_receipt_id  ,
                         -7,--Prepayment
                         l_receivable_application_id ,
                         l_apply_gl_date     ,
                         l_cr_unapp_amount   , /* Bug fix 3569640 */
                         l_def_return_status);

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('process_prepayments: ' ||
                          'Derive other accounts ids return status : '||
                           l_def_return_status);
        END IF;

       /*----------------------------------------------------
        Credit card refunds
       -----------------------------------------------------*/
       IF l_refund_type = 'CREDIT_CARD' THEN

          /*----------------------------------------------------
            Check the Receipt in doubt scenario
          -----------------------------------------------------*/
          check_rec_in_doubt(p_cash_receipt_id => l_cash_receipt_id,
                             x_rec_in_doubt    => l_rec_in_doubt,
                             x_rid_reason      => l_rid_reason);


          IF l_rec_in_doubt = 'Y' then
             l_refund_type:= 'ON_ACCOUNT';

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('process_prepayments:  '||
                 'Receipt is in doubt with following reason: '|| l_rid_reason);

              END IF;


           ELSE

            --Default the receivable_trx_id for credit card refund activity
            ar_receipt_lib_pvt.Default_prepay_cc_activity(
                         'CCREFUND',
                         l_receivables_trx_id,
                         l_def_activity_return_status);
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('process_prepayments: ' ||
                          'Default Refund Activity Return status  :'||
                          l_def_activity_return_status);
              END IF;

           END IF; --l_rec_in_doubt

       END IF; ----l_refund_type = CREDIT_CARD

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('process_prepayments: Refund type ' ||l_refund_type);
        END IF;



           IF l_val_return_status <> FND_API.G_RET_STS_SUCCESS OR
              l_def_return_status <> FND_API.G_RET_STS_SUCCESS OR
              l_def_activity_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('process_prepayments: ' ||
                                'Validation or Defaulting Failed' );
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;

           END IF;


           -- Fetch the details on the unapplied prepayment record.
             arp_app_pkg.fetch_p(l_receivable_application_id, l_ra_rec );

           /*----------------------------------------------------
              If the validations passed then
              Unapply prepayment
            -----------------------------------------------------*/
           IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('process_prepayments: ' ||
                ' Calling ar_receipt_api_pub.Unapply_other_account' );
             END IF;


             ar_receipt_api_pub.Unapply_other_account(
               --Standard API parameters.
                p_api_version               => p_api_version,
                p_init_msg_list             => p_init_msg_list,
                p_commit                    => p_commit ,
                p_validation_level          => p_validation_level,
                x_return_status             => x_return_status,
                x_msg_count                 => x_msg_count,
                x_msg_data                  => x_msg_data,
                p_receipt_number            => p_receipt_number,
                p_cash_receipt_id           => l_cash_receipt_id,
                p_receivable_application_id => l_receivable_application_id,
                p_reversal_gl_date          => p_refund_gl_date
                );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('process_prepayments: ' ||
                         'Unapply Other Account Return status  :'||
                         x_return_status);
             END IF;

           END IF;  ---x_return_status = FND_API.G_RET_STS_SUCCESS


          /*----------------------------------------------------
             Make sure there are no errors in unapplication.
             if there is any error,do not perform refund or
             reapplication
           -----------------------------------------------------*/
          IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
             l_refund_type = 'CREDIT_CARD' THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('process_prepayments: ' ||
                     ' Calling ar_receipt_api_pub.Activity_Application' );
                END IF;

               -- Issue a credit card Refund

               ar_receipt_api_pub.Activity_application(
               -- Standard API parameters.
               p_api_version               => p_api_version,
               p_init_msg_list             => p_init_msg_list,
               p_commit                    => p_commit ,
               p_validation_level          => p_validation_level,
               x_return_status             => x_return_status,
               x_msg_count                 => x_msg_count,
               x_msg_data                  => x_msg_data,
               p_cash_receipt_id           => p_cash_receipt_id,
               p_receipt_number            => p_receipt_number,
               p_amount_applied            => p_refund_amount,
               p_applied_payment_schedule_id  => -6, --this is for CC Refund
               p_link_to_customer_trx_id      => NULL,
               p_receivables_trx_id           => l_receivables_trx_id,
               p_apply_date                   => NVL(p_refund_date,sysdate),
               p_apply_gl_date                => NVL(p_refund_gl_date,sysdate),
               p_ussgl_transaction_code       => p_ussgl_transaction_code,
               p_attribute_rec                => p_attribute_rec,
            -- ******* Global Flexfield parameters *******
               p_global_attribute_rec         => p_global_attribute_rec,
               p_comments                     => p_comments,
               p_application_ref_type         => l_application_ref_type,
               p_application_ref_id           => l_application_ref_id,
               p_application_ref_num          => l_application_ref_num,
               p_secondary_application_ref_id => l_secondary_application_ref_id,
               p_receivable_application_id    => l_receivable_application_id,
               p_payment_set_id               => l_ra_rec.payment_set_id
               );

           IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('process_prepayments: ' ||
                                'Acticvity application  return status :'||
                                 x_return_status);

                 arp_util.debug('process_prepayments: '||
                                ' Receivable App. ID : '||
                                 l_receivable_application_id );
           END IF;


            /*----------------------------------------------------
                Bug 3628401
                Fetch the amount_applied for credit card refund
                application
               -----------------------------------------------------*/
               IF x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                 arp_app_pkg.fetch_p(l_receivable_application_id,
                                     l_ra_refund_rec);
                 l_actual_refund_amount := NVL(l_ra_refund_rec.amount_applied,0);
               END IF;

          /*----------------------------------------------------
           On Account refund Application
          -----------------------------------------------------*/
          ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS AND
             l_refund_type = 'ON_ACCOUNT' THEN

             /*----------------------------------------------------
               populate the message if the receipt was supposed
               be credit card but was placed on Acccount because of
               receipt in doubt condition
              -----------------------------------------------------*/
              if l_rec_in_doubt = 'Y' then

                l_comments := substrb( l_rid_reason, 1, 240);

              else
                 l_comments := substrb( p_comments, 1, 240);
             end if;


               IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('process_prepayments: ' ||
                 ' Calling ar_receipt_api_pub.Apply_On_Account' );
               END IF;

           --put the amount on account
            ar_receipt_api_pub.Apply_on_account(
               p_api_version        => 1.0,
               x_return_status      => x_return_status,
               x_msg_count          => x_msg_count,
               x_msg_data           => x_msg_data,
               p_cash_receipt_id    => p_cash_receipt_id,
               p_amount_applied     => p_refund_amount,
               p_comments           => l_comments,
               p_secondary_application_ref_id => l_application_ref_id,
               p_secondary_app_ref_type   => l_application_ref_type,
               p_secondary_app_ref_num    => l_application_ref_num
              );

               IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('process_prepayments: ' ||
                 ' Apply On Account return status: ' || x_return_status );
               END IF;

               /*----------------------------------------------------
               Bug 3628401
               Fetch the amount_applied on On Account refund record
              -----------------------------------------------------*/
             IF x_return_status = FND_API.G_RET_STS_SUCCESS  THEN

               l_on_acc_rec_app_id :=
                 ar_receipt_api_pub.g_apply_on_account_out_rec.receivable_application_id;
               arp_app_pkg.fetch_p(l_on_acc_rec_app_id, l_ra_refund_rec );
               l_actual_refund_amount := NVL(l_ra_refund_rec.amount_applied,0);
             END IF;

         END IF ;  --l_refund_type


         /*----------------------------------------------------
          Bug 3628401
          If the refund application was successful then evaluate
          whether any amount needs to be applied back on Prepayment
          -----------------------------------------------------*/
          IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

             l_reapply_amount := NVL(l_ra_rec.amount_applied,0)
                               - NVL(l_actual_refund_amount,0);

             IF l_reapply_amount > 0 THEN

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('process_prepayments: ' ||
                    ' Amount to be re-applied back on Prepayment: '||
                     l_reapply_amount );
                 END IF;


              --If the refund routine is called from sweeper program or any
              --other routine then we need to take the payment set id from
              --the old prepayment record and store in the new prepayment
              --re-application record.

                l_payment_set_id := l_ra_rec.payment_set_id;

              --Assign atributes
                l_attribute_rec.attribute_category := l_ra_rec.attribute_category;
                l_attribute_rec.attribute1         := l_ra_rec.attribute1;
                l_attribute_rec.attribute2         := l_ra_rec.attribute2;
                l_attribute_rec.attribute3         := l_ra_rec.attribute3;
                l_attribute_rec.attribute4         := l_ra_rec.attribute4;
                l_attribute_rec.attribute5         := l_ra_rec.attribute5;
                l_attribute_rec.attribute6         := l_ra_rec.attribute6;
                l_attribute_rec.attribute7         := l_ra_rec.attribute7;
                l_attribute_rec.attribute8         := l_ra_rec.attribute8;
                l_attribute_rec.attribute9         := l_ra_rec.attribute9;
                l_attribute_rec.attribute10        := l_ra_rec.attribute10;
                l_attribute_rec.attribute11        := l_ra_rec.attribute11;
                l_attribute_rec.attribute12        := l_ra_rec.attribute12;
                l_attribute_rec.attribute13        := l_ra_rec.attribute13;
                l_attribute_rec.attribute14        := l_ra_rec.attribute14;
                l_attribute_rec.attribute15        := l_ra_rec.attribute15;

                l_global_attribute_rec.global_attribute_category  :=
                                         l_ra_rec.global_attribute_category;
                l_global_attribute_rec.global_attribute1  :=
                                         l_ra_rec.global_attribute1;
                l_global_attribute_rec.global_attribute2  :=
                                          l_ra_rec.global_attribute2;
                l_global_attribute_rec.global_attribute3  :=
                                         l_ra_rec.global_attribute3;
                l_global_attribute_rec.global_attribute4  :=
                                         l_ra_rec.global_attribute4;
                l_global_attribute_rec.global_attribute5  :=
                                         l_ra_rec.global_attribute5;
                l_global_attribute_rec.global_attribute6  :=
                                         l_ra_rec.global_attribute6;
                l_global_attribute_rec.global_attribute7  :=
                                         l_ra_rec.global_attribute7;
                l_global_attribute_rec.global_attribute8  :=
                                         l_ra_rec.global_attribute8;
                l_global_attribute_rec.global_attribute9  :=
                                         l_ra_rec.global_attribute9;
                l_global_attribute_rec.global_attribute10 :=
                                         l_ra_rec.global_attribute10;
                l_global_attribute_rec.global_attribute11 :=
                                         l_ra_rec.global_attribute11;
                l_global_attribute_rec.global_attribute12 :=
                                         l_ra_rec.global_attribute12;
                l_global_attribute_rec.global_attribute13 :=
                                         l_ra_rec.global_attribute13;
                l_global_attribute_rec.global_attribute14 :=
                                         l_ra_rec.global_attribute14;
                l_global_attribute_rec.global_attribute15 :=
                                         l_ra_rec.global_attribute15;
                l_global_attribute_rec.global_attribute16 :=
                                         l_ra_rec.global_attribute16;
                l_global_attribute_rec.global_attribute17 :=
                                         l_ra_rec.global_attribute17;
                l_global_attribute_rec.global_attribute18 :=
                                         l_ra_rec.global_attribute18;
                l_global_attribute_rec.global_attribute19 :=
                                         l_ra_rec.global_attribute19;
                l_global_attribute_rec.global_attribute20 :=
                                         l_ra_rec.global_attribute20;

                /*----------------------------------------------------
                 Reapply to prepayment
                -----------------------------------------------------*/
                ar_receipt_api_pub.Apply_other_account(
                   --Standard API parameters.
                     p_api_version               => p_api_version,
                     p_init_msg_list             => p_init_msg_list,
                     p_commit                    => p_commit ,
                     p_validation_level          => p_validation_level,
                     x_return_status             => x_return_status,
                     x_msg_count                 => x_msg_count,
                     x_msg_data                  => x_msg_data,
                     p_receivable_application_id => p_prepay_application_id, --OUT
                   --Receipt application parameters.
                     p_cash_receipt_id           => p_cash_receipt_id,
                     p_receipt_number            => p_receipt_number,
                     p_amount_applied            => l_reapply_amount,
                     p_receivables_trx_id        => l_ra_rec.receivables_trx_id,
                     p_applied_payment_schedule_id  => -7,
                     p_apply_date               => p_refund_date,
                     p_apply_gl_date            => p_refund_gl_date,
                     p_ussgl_transaction_code   => l_ra_rec.ussgl_transaction_code,
                     p_application_ref_type     => l_ra_rec.application_ref_type,
                     p_application_ref_id       => l_ra_rec.application_ref_id,
                     p_application_ref_num      => l_ra_rec.application_ref_num,
                     p_secondary_application_ref_id => l_ra_rec.secondary_application_ref_id,
                     p_payment_set_id           => l_payment_set_id,
                     p_attribute_rec            => l_attribute_rec,
                  -- ******* Global Flexfield parameters *******
                     p_global_attribute_rec     => l_global_attribute_rec,
                     p_comments                 => l_ra_rec.comments
                      );

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('process_prepayments: ' ||
                                   'Prepay Application ID  :'||
                                    p_prepay_application_id);
                    arp_util.debug('process_prepayments: ' ||
                                   'Other account application  return status :'||
                                    x_return_status);
                 END IF;


              END IF; --l_reapply_amount


          END IF;  --x_return_status

          /*----------------------------------------------------
           Error Handling Finally
          -----------------------------------------------------*/
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              ---Bug 3628401 removed unexpected_error;
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count       =>      x_msg_count,
                                       p_data        =>      x_msg_data
                                         );
              RETURN;
          END IF;

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('process_prepayments: ' || 'ar_prepayments.process prepayment (-)');
          END IF;

     EXCEPTION

       WHEN OTHERS THEN
          x_return_status :=  FND_API.G_RET_STS_ERROR;
           FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('EXCEPTION :ar_prepayments.process_prepayments :'||SQLERRM);
          END IF;

END Process_Prepayments;

/*=======================================================================
 | PUBLIC Procedure Create_Prepayment
 |
 | DESCRIPTION
 |      Create prepayment receipt and put it on prepayment
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 10-SEP-2001           S Nambiar      Created
 | 10-MAR-2002           S Nambiar      Bug 2315864 - Validate customer
 |                                      bank account id,raise error if
 |                                      NULL is passed
 | 08-AUG-2003           J Pandey       All the code has ben moved to the new
 |                                      prepayment API AR_PREPAYMNTS_PUB
 *=======================================================================*/
 PROCEDURE Create_Prepayment(
-- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
 -- Receipt info. parameters
      p_usr_currency_code IN  VARCHAR2 DEFAULT NULL, --the translated currency code
      p_currency_code     IN  ar_cash_receipts.currency_code%TYPE DEFAULT NULL,
      p_usr_exchange_rate_type  IN  VARCHAR2 DEFAULT NULL,
      p_exchange_rate_type IN  ar_cash_receipts.exchange_rate_type%TYPE DEFAULT NULL,
      p_exchange_rate      IN  ar_cash_receipts.exchange_rate%TYPE DEFAULT NULL,
      p_exchange_rate_date IN  ar_cash_receipts.exchange_date%TYPE DEFAULT NULL,
      p_amount                  IN  ar_cash_receipts.amount%TYPE,
      p_factor_discount_amount  IN  ar_cash_receipts.factor_discount_amount%TYPE DEFAULT NULL,

      --Bug 3106245
      p_receipt_number   IN  ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,

      p_receipt_date     IN  ar_cash_receipts.receipt_date%TYPE DEFAULT NULL,
      p_gl_date          IN  ar_cash_receipt_history.gl_date%TYPE DEFAULT NULL,
      p_maturity_date    IN  DATE DEFAULT NULL,
      p_postmark_date    IN  DATE DEFAULT NULL,
      p_customer_id      IN  ar_cash_receipts.pay_from_customer%TYPE DEFAULT NULL,
      p_customer_name    IN  hz_parties.party_name%TYPE DEFAULT NULL,
      p_customer_number  IN  hz_cust_accounts.account_number%TYPE DEFAULT NULL,
      p_customer_bank_account_id   IN  ar_cash_receipts.customer_bank_account_id%TYPE DEFAULT NULL,
      p_customer_bank_account_num  IN  ap_bank_accounts.bank_account_num%TYPE DEFAULT NULL,
      p_customer_bank_account_name IN  ap_bank_accounts.bank_account_name%TYPE DEFAULT NULL,
      p_location               IN  hz_cust_site_uses.location%TYPE DEFAULT NULL,
      p_customer_site_use_id   IN  hz_cust_site_uses.site_use_id%TYPE DEFAULT NULL,
      p_customer_receipt_reference       IN  ar_cash_receipts.customer_receipt_reference%TYPE DEFAULT NULL,
      p_override_remit_account_flag      IN  ar_cash_receipts.override_remit_account_flag%TYPE DEFAULT NULL,
      p_remittance_bank_account_id       IN  ar_cash_receipts.remit_bank_acct_use_id%TYPE DEFAULT NULL,
      p_remittance_bank_account_num      IN  ce_bank_accounts.bank_account_num%TYPE DEFAULT NULL,
      p_remittance_bank_account_name     IN  ce_bank_accounts.bank_account_name%TYPE DEFAULT NULL,
      p_deposit_date                     IN  ar_cash_receipts.deposit_date%TYPE DEFAULT NULL,
      p_receipt_method_id                IN  ar_cash_receipts.receipt_method_id%TYPE DEFAULT NULL,
      p_receipt_method_name              IN  ar_receipt_methods.name%TYPE DEFAULT NULL,
      p_doc_sequence_value               IN  NUMBER   DEFAULT NULL,
      p_ussgl_transaction_code           IN  ar_cash_receipts.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_anticipated_clearing_date        IN  ar_cash_receipts.anticipated_clearing_date%TYPE DEFAULT NULL,
      p_called_from                      IN VARCHAR2 DEFAULT NULL,
      p_attribute_rec                    IN ar_receipt_api_pub.attribute_rec_type
                                            DEFAULT ar_receipt_api_pub.attribute_rec_const,
   -- ******* Global Flexfield parameters *******
      p_global_attribute_rec  IN ar_receipt_api_pub.global_attribute_rec_type
                                 DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_receipt_comments      IN VARCHAR2 DEFAULT NULL,
   -- ***  Notes Receivable Additional Information  ***
      p_issuer_name           IN ar_cash_receipts.issuer_name%TYPE DEFAULT NULL,
      p_issue_date            IN ar_cash_receipts.issue_date%TYPE DEFAULT NULL,
      p_issuer_bank_branch_id IN ar_cash_receipts.issuer_bank_branch_id%TYPE DEFAULT NULL,
   -- ** OUT NOCOPY variables for Creating receipt
      p_cr_id                 OUT NOCOPY ar_cash_receipts.cash_receipt_id%TYPE,
   -- Receipt application parameters
      p_applied_payment_schedule_id     IN ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_application_ref_type IN VARCHAR2 DEFAULT NULL,
      p_application_ref_id   IN OUT NOCOPY NUMBER ,
      p_application_ref_num  IN OUT NOCOPY VARCHAR2 ,
      p_secondary_application_ref_id IN OUT NOCOPY NUMBER ,
      p_receivable_trx_id       IN ar_receivable_applications.receivables_trx_id%TYPE DEFAULT NULL,
      p_amount_applied_from     IN ar_receivable_applications.amount_applied_from%TYPE DEFAULT NULL,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date           IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      app_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_show_closed_invoices    IN VARCHAR2 DEFAULT 'FALSE',
      p_move_deferred_tax       IN VARCHAR2 DEFAULT 'Y',
      app_attribute_rec         IN ar_receipt_api_pub.attribute_rec_type
                                   DEFAULT ar_receipt_api_pub.attribute_rec_const,
   -- ******* Global Flexfield parameters *******
      app_global_attribute_rec  IN ar_receipt_api_pub.global_attribute_rec_type
                                   DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      app_comments              IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
   -- processor such as iPayments
      p_payment_server_order_num IN OUT NOCOPY ar_cash_receipts.payment_server_order_num%TYPE,
      p_approval_code            IN OUT NOCOPY ar_cash_receipts.approval_code%TYPE,
       --- Bug: 3220078 Change the p_call_payment_processor to TRUE ---
      p_call_payment_processor   IN VARCHAR2 DEFAULT FND_API.G_TRUE,

      p_payment_response_error_code OUT NOCOPY VARCHAR2,
   -- OUT NOCOPY parameter for the Application
      p_receivable_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_payment_set_id            IN OUT NOCOPY NUMBER,
      p_org_id                    IN NUMBER DEFAULT NULL,
      p_payment_trxn_extension_id IN ar_cash_receipts.payment_trxn_extension_id%TYPE
      ) IS

l_receipt_number ar_cash_receipts.receipt_number%TYPE;
l_org_id NUMBER;
l_org_return_status VARCHAR2(1);


BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('ar_prepayments.Create_Prepayment ()+');
      END IF;

      /*--------------------------------------------------------------+
      |   Initialize message list if p_init_msg_list is set to TRUE  |
      +--------------------------------------------------------------*/
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE


    --Initialize the return status
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     --get the value of receipt_number into local variable
       l_receipt_number := p_receipt_number;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('ar_prepayments.Create_Prepayment ()+'|| p_org_id);
         arp_util.debug('Create_Prepayment: payment_trxn_extension_id' || to_char(p_payment_trxn_extension_id) );
      END IF;


      ----Call the AR_PREPAYMENTS_PUB.Create_Prepayment API----
      AR_PREPAYMENTS_PUB.Create_Prepayment(
     -- Standard API parameters.
      p_api_version     ,
      p_init_msg_list   ,
      p_commit          ,
      p_validation_level ,

      x_return_status,
      x_msg_count   ,
      x_msg_data    ,

      -- Receipt info. parameters
      p_usr_currency_code ,
      p_currency_code     ,
      p_usr_exchange_rate_type  ,
      p_exchange_rate_type ,
      p_exchange_rate      ,
      p_exchange_rate_date ,
      p_amount                  ,
      p_factor_discount_amount  ,

      ---Bug 3106245 pass the local variable value to IN OUT
      l_receipt_number   ,

      p_receipt_date     ,
      p_gl_date          ,
      p_maturity_date    ,
      p_postmark_date    ,
      p_customer_id      ,
      p_customer_name    ,
      p_customer_number  ,
      p_customer_bank_account_id   ,
      p_customer_bank_account_num  ,
      p_customer_bank_account_name ,
      p_location               ,
      p_customer_site_use_id   ,
      p_customer_receipt_reference       ,
      p_override_remit_account_flag      ,
      p_remittance_bank_account_id       ,
      p_remittance_bank_account_num      ,
      p_remittance_bank_account_name     ,
      p_deposit_date                     ,
      p_receipt_method_id                ,
      p_receipt_method_name              ,
      p_doc_sequence_value               ,
      p_ussgl_transaction_code           ,
      p_anticipated_clearing_date        ,
      p_called_from                      ,
      p_attribute_rec                    ,
        -- ******* Global Flexfield parameters *******
      p_global_attribute_rec  ,
      p_receipt_comments      ,
        -- ***  Notes Receivable Additional Information  ***
      p_issuer_name           ,
      p_issue_date            ,
      p_issuer_bank_branch_id ,
        -- ** OUT variables for Creating receipt
      p_cr_id                 ,
        -- Receipt application parameters
      p_applied_payment_schedule_id     ,
      p_amount_applied          ,
      p_application_ref_type ,
      p_application_ref_id   ,
      p_application_ref_num  ,
      p_secondary_application_ref_id ,
      p_receivable_trx_id       ,
      p_amount_applied_from     ,
      p_apply_date              ,
      p_apply_gl_date           ,
      app_ussgl_transaction_code  ,
      p_show_closed_invoices    ,
      p_move_deferred_tax       ,
      app_attribute_rec         ,
        -- ******* Global Flexfield parameters *******
      app_global_attribute_rec  ,
      app_comments              ,
        -- processor such as iPayments
      p_payment_server_order_num ,
      p_approval_code            ,
      p_call_payment_processor  ,
      p_payment_response_error_code ,
        -- OUT NOCOPY parameter for the Application
      p_receivable_application_id ,
      p_payment_set_id,
      p_org_id,
      p_payment_trxn_extension_id);


      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('AR_PREPAYMENTS.Create_Prepayment ()-');
      END IF;


END IF; /* SSA changes */

EXCEPTION
 WHEN others THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('EXCEPTION : ar_prepayment.create_prepayment ||SQLERRM');
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END Create_Prepayment;

PROCEDURE Refund_Prepayments(
    -- Standard API parameters.
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_prepay_application_id      OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_number_of_refund_receipts  OUT NOCOPY NUMBER,
      p_receipt_number             IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_cash_receipt_id            IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receivable_application_id  IN  ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL,
      p_receivables_trx_id         IN ar_receivable_applications.receivables_trx_id%TYPE DEFAULT NULL,
      p_refund_amount              IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_refund_date                IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_refund_gl_date             IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code     IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_attribute_rec              IN ar_receipt_api_pub.attribute_rec_type
                                      DEFAULT ar_receipt_api_pub.attribute_rec_const,
    -- ******* Global Flexfield parameters *******
      p_global_attribute_rec       IN ar_receipt_api_pub.global_attribute_rec_type
                                      DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments                   IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
      p_payment_set_id             IN NUMBER DEFAULT NULL
    ) IS

--Multiple Prepayments project, get all the receipts
CURSOR prepay_rcpt_cur(c_payment_set_id NUMBER,
                       c_receipt_method_id IN NUMBER,
                       c_bank_account_id IN NUMBER) IS
       SELECT ra.cash_receipt_id,
              SUM(DECODE(ra.status,'OTHER ACC',DECODE(applied_payment_schedule_id,
                -7,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) prepayment_amount
        FROM  ar_receivable_applications ra , ar_cash_receipts cr
        WHERE  ra.payment_set_id= c_payment_set_id
        AND cr.cash_receipt_id = ra.cash_receipt_id
        AND ra.display = 'Y'
        AND decode(c_receipt_method_id, null,'1',cr.receipt_method_id ) =
        nvl(c_receipt_method_id,'1')
        AND decode(c_bank_account_id,null,1,cr.customer_bank_account_id ) =
        nvl(c_bank_account_id,1)
        GROUP by ra.cash_receipt_id
        order by prepayment_amount desc;

l_api_name       CONSTANT VARCHAR2(20) := 'Refund_Prepayment';
l_api_version    CONSTANT NUMBER       := 1.0;

l_ra_rec                        ar_receivable_applications%ROWTYPE;
l_attribute_rec                 ar_receipt_api_pub.attribute_rec_type;
l_global_attribute_rec          ar_receipt_api_pub.global_attribute_rec_type;

l_cash_receipt_id           NUMBER;
l_applied_ps_id             NUMBER;
l_receivable_application_id NUMBER;
l_receivables_trx_id        NUMBER;
l_apply_gl_date             DATE;
l_def_return_status         VARCHAR2(1);
l_def_activity_return_status VARCHAR2(1);
l_val_return_status         VARCHAR2(1);
l_reapply_amount            ar_receivable_applications.amount_applied%TYPE;
l_payment_set_id            NUMBER;
l_refund_amount             NUMBER;
l_rcpt_refund_amount        NUMBER;
l_number_of_refund_receipts NUMBER :=0;

------Multiple Prepayments
l_total_pmt_types NUMBER := 0;
l_credit_pmt_type_count  NUMBER := 0;
l_refund_type VARCHAR2(30) := null;
l_payment_type ar_receipt_methods.PAYMENT_TYPE_CODE%TYPE;
l_receipt_id_def_status VARCHAR2(1);
t_bank_account_id NUMBER := null;
t_receipt_method_id  NUMBER := null;
l_max_refund_amt NUMBER := 0;
l_dummy number := null;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('ar_prepayment.refund_prepayments (+)');
        END IF;

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

         SAVEPOINT refund_prepay_PVT;

       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;

       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        END IF;

       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Refund_Prepayments: ' || 'Activity_application()+ ');
        END IF;


       /*-------------------------------------------------+
        | Initialize SOB/org dependent variables          |
        +-------------------------------------------------*/
        arp_global.init_global;
        arp_standard.init_standard;


   --If receivable_application_id is NOT passed, get the id and details
   --and fetch the record and keep it in local variable before unapplying it

     l_cash_receipt_id           := p_cash_receipt_id;
     l_receivable_application_id := p_receivable_application_id;
     l_refund_amount             := p_refund_amount;
     l_payment_set_id            := p_payment_set_id;
     l_receivables_trx_id        := p_receivables_trx_id;
     l_receipt_id_def_status := FND_API.G_RET_STS_SUCCESS;

     IF (l_payment_set_id IS NULl   AND p_receipt_number IS NULL
        AND l_cash_receipt_id IS NULL AND l_receivable_application_id IS NULL)
     THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_NULL');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
     END IF;



     --if receipt number is passed and cash_receipt_id is not then
     --derive the cash_receipt_id
     IF p_receipt_number IS NOT NULL AND l_cash_receipt_id is NULL THEN
        ar_receipt_lib_pvt.Default_cash_receipt_id(l_cash_receipt_id ,
                           p_receipt_number ,
                           l_receipt_id_def_status);


       IF l_receipt_id_def_status <> FND_API.G_RET_STS_SUCCESS OR
          l_cash_receipt_id is NULL THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('refund_prepayments: ' || 'Validation or Defaulting Failed' ) ;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    -------------------------------------------------------------
    ----------Refund using Receipt Info ------------------------
    -------------------------------------------------------------
    IF l_cash_receipt_id is not null then

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('refund_prepayments: refund using cash_receipt_id:  '
                         || l_cash_receipt_id ) ;
       END IF;

       BEGIN
           --Check the payment_method
            select  nvl(rm.payment_channel_code, 'CHECK')
            into l_payment_type
            from ar_receipt_methods rm , ar_cash_receipts cr
            WHERE  cr.cash_receipt_id = l_cash_receipt_id
            AND    cr.receipt_method_id = rm.receipt_method_id;

          -------------Validate the refund amount for payment_set_id-------
          SELECT
          SUM(DECODE(ra.status,'OTHER ACC',DECODE(applied_payment_schedule_id,
          -7,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) max_refund_amt
          into l_max_refund_amt
          FROM  ar_receivable_applications ra
          WHERE  ra.cash_receipt_id = l_cash_receipt_id
          AND ra.display = 'Y';

          ---Bug: 3504678
          if nvl(l_refund_amount,0) > nvl(l_max_refund_amt,0) then
              --raise error X validation failed
            FND_MESSAGE.SET_NAME('AR','AR_RW_CCR_REFUND_AMOUNT');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN;
          end if;


            ---Deriive the refund type from payment type
            if l_payment_type <> 'CREDIT_CARD' THEN
               l_refund_type :=  'ON_ACCOUNT';
            else
               l_refund_type := 'CREDIT_CARD';
            end if;

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('refund_prepayments: Refund type :  ' ||
                                l_refund_type);
            END IF;

            EXCEPTION
              when no_data_found then
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_INVALID');
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;
              RETURN ;

              when others then
              x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE;
       END;

      IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('refund_prepayments: Calling process_prepayments');
      END IF;

      --call process prepayment
       process_prepayments(
              p_api_version                => p_api_version,
              p_init_msg_list              => p_init_msg_list,
              p_commit                     => p_commit,
              p_validation_level           => p_validation_level,
              p_receipt_number             => p_receipt_number,
              p_cash_receipt_id            => l_cash_receipt_id,
              p_receivable_application_id  => l_receivable_application_id,
              p_receivables_trx_id         => l_receivables_trx_id,
              p_refund_amount              => l_refund_amount,
              p_refund_date                => p_refund_date,
              p_refund_gl_date             => p_refund_gl_date,
              p_ussgl_transaction_code     => p_ussgl_transaction_code,
              p_attribute_rec              => p_attribute_rec,
              -- ******* Global Flexfield parameters *******
              p_global_attribute_rec       => p_global_attribute_rec,
              p_comments                   => p_comments,
              p_refund_type                => l_refund_type,
              x_return_status              => x_return_status,
              x_msg_count                  => x_msg_count,
              x_msg_data                   => x_msg_data,
              p_prepay_application_id      => p_prepay_application_id
              );


          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('refund_prepayments: process_prepayments ' ||
                            ' return status: '|| x_return_status  );
          END IF;

     ELSE ---if refund is via payment_set_id

     --Check if the global variables are populated, that means
     --the credit card refund need to be done for a particular
     --receipt_method to a particular credit card bank
     IF l_payment_set_id is not null THEN

        IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('refund_prepayments: refund using payment_set_id:  ' ||
                          l_payment_set_id ) ;
        END IF;

        /*--------------------------------------
         Check if payment set id is valid
       ---------------------------------------*/
          select count(*) into l_dummy
          from ar_cash_receipts_all cr, ar_receivable_applications ra
          where  ra.payment_set_id= l_payment_set_id
          AND cr.cash_receipt_id = ra.cash_receipt_id;

          if l_dummy = 0 then
              FND_MESSAGE.SET_NAME('AR','AR_CUST_INVALID_PARAMETER');
              FND_MESSAGE.SET_TOKEN('PARAMETER','P_PAYMENT_SET_ID');
              FND_MESSAGE.SET_TOKEN('VALUE',l_payment_set_id);
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;
          end if;


        if G_REFUND_BANK_ACCOUNT_ID is not NULL then
           t_bank_account_id := G_REFUND_BANK_ACCOUNT_ID;

            if PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('refund_prepayments: ' ||
                             'refund to the bank account id:  ' ||
                              t_bank_account_id ) ;
            end if;

            /*--------------------------------------
             Check if t_bank_account_id  is valid
            ---------------------------------------*/
                select count(*)  into l_dummy
                from ar_cash_receipts_all cr, ar_receivable_applications ra
                where  ra.payment_set_id= l_payment_set_id
                AND cr.cash_receipt_id = ra.cash_receipt_id
                and cr.customer_bank_account_id = t_bank_account_id;

              if l_dummy = 0 then
                 FND_MESSAGE.SET_NAME('AR','AR_CUST_INVALID_PARAMETER');
                 FND_MESSAGE.SET_TOKEN('PARAMETER','P_BANK_ACCOUNT_ID');
                 FND_MESSAGE.SET_TOKEN('VALUE',t_bank_account_id);
                 FND_MSG_PUB.Add;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              end if;

        end if;

        if G_REFUND_RECEIPT_METHOD_ID is not null then
          t_receipt_method_id := G_REFUND_RECEIPT_METHOD_ID;

          if PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('refund_prepayments: '||
                             ' refund  for the receipt method :  ' ||
                               t_receipt_method_id ) ;
           end if;

           /*--------------------------------------
             Check if t_receipt_method_id  is valid
            ---------------------------------------*/
                select count(*)  into l_dummy
                from ar_cash_receipts_all cr, ar_receivable_applications ra
                where  ra.payment_set_id= l_payment_set_id
                AND cr.cash_receipt_id = ra.cash_receipt_id
                and cr.receipt_method_id = t_receipt_method_id;

              if l_dummy = 0 then
                 FND_MESSAGE.SET_NAME('AR','AR_CUST_INVALID_PARAMETER');
                 FND_MESSAGE.SET_TOKEN('PARAMETER','P_RECEIPT_METHOD_ID');
                 FND_MESSAGE.SET_TOKEN('VALUE',t_receipt_method_id);
                 FND_MSG_PUB.Add;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              end if;


        end if;

         -------------Validate the refund amount for payment_set_id-------
          SELECT
          SUM(DECODE(ra.status,'OTHER ACC',DECODE(applied_payment_schedule_id,
          -7,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) max_refund_amt
          into l_max_refund_amt
          FROM  ar_receivable_applications ra , ar_cash_receipts cr
          WHERE  ra.payment_set_id= l_payment_set_id
          AND cr.cash_receipt_id = ra.cash_receipt_id
          AND ra.display = 'Y'
          AND decode(t_receipt_method_id, null,'1',cr.receipt_method_id ) =
              nvl(t_receipt_method_id,'1')
          AND decode(t_bank_account_id,null,1,cr.customer_bank_account_id ) =
              nvl(t_bank_account_id,1);

          ---Bug 3504678
          if nvl(l_refund_amount,0) > nvl(l_max_refund_amt,0) then
              --raise error X validation failed
            FND_MESSAGE.SET_NAME('AR','AR_RW_CCR_REFUND_AMOUNT');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN;
          end if;

          if PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('refund_prepayments: refund amount : ' ||
                             l_refund_amount);
          end if;


          --Refunding across Prepaid receipts using Payment_Set_Id
          ----check whether refund should be ON ACCOUNT or to CREDIT CARD----
           SELECT count(distinct NVL(rm.payment_channel_code, 'CHECK'))
               as pmt_type_count,
              sum(DECODE(rm.payment_channel_code, 'CREDIT_CARD', 1, 0))
               as credit_pmt_type_count
          INTO     l_total_pmt_types, l_credit_pmt_type_count
          FROM   ar_receivable_applications ra,
                 ar_cash_receipts cr,
                 ar_receipt_methods rm
          WHERE  ra.payment_set_id = l_payment_set_id
          AND    ra.cash_receipt_id = cr.cash_receipt_id
          AND    cr.receipt_method_id = rm.receipt_method_id
          AND    decode(t_bank_account_id,null,1,cr.customer_bank_account_id ) =
                 nvl(t_bank_account_id,1)
          AND    decode(t_receipt_method_id,null,1,cr.receipt_method_id ) =
                 nvl(t_receipt_method_id,1);

         ----- If there are no payment types-------
         IF l_total_pmt_types = 0 THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Refund_Prepayments: ' || 'Could not find payment type()+ ');
            END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;


         -----if there is one payment type --------
         ELSIF  l_total_pmt_types = 1 and l_credit_pmt_type_count > 0 then

                l_refund_type          := 'CREDIT_CARD';

                 if PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('Refund_Prepayments: '||'One Payment type '||
                       ' Refund: '|| l_refund_type);
                 end if;

         ELSE    --- Greater than 1 payment types
            l_refund_type           := 'ON_ACCOUNT'; -- No CC Applications

            if PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Refund_Prepayments: ' || 'Many Payment types '||
                        ' Refund: '|| l_refund_type);
            end if;

         END IF; -- total_pmt_types

         FOR prepay_rcpt_rec IN prepay_rcpt_cur(l_payment_set_id,
                                t_receipt_method_id, t_bank_account_id )
         LOOP

           l_cash_receipt_id           := prepay_rcpt_rec.cash_receipt_id;

           IF l_refund_amount > 0 THEN

             IF NVL(l_refund_amount,0) <= prepay_rcpt_rec.prepayment_amount  THEN
                l_rcpt_refund_amount := l_refund_amount;
             ELSE
                l_rcpt_refund_amount := prepay_rcpt_rec.prepayment_amount;
             END IF;

           if PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Refund_Prepayments: ' ||
                              ' Calling process_prepayments' ||
                              ' For Receipt ID: '|| l_cash_receipt_id ||
                              ' To issue Refund of type '|| l_refund_type ||
                              'For Amount: '|| l_rcpt_refund_amount);
            end if;

         --call process prepayment

           process_prepayments(
                  p_api_version                => p_api_version,
                  p_init_msg_list              => p_init_msg_list,
                  p_commit                     => p_commit,
                  p_validation_level           => p_validation_level,
                  p_receipt_number             => p_receipt_number,
                  p_cash_receipt_id            => l_cash_receipt_id,
                  p_receivable_application_id  => l_receivable_application_id,
                  p_receivables_trx_id         => l_receivables_trx_id,
                  p_refund_amount              => l_rcpt_refund_amount,
                  p_refund_date                => p_refund_date,
                  p_refund_gl_date             => p_refund_gl_date,
                  p_ussgl_transaction_code     => p_ussgl_transaction_code,
                  p_attribute_rec              => p_attribute_rec,
               -- ******* Global Flexfield parameters *******
                  p_global_attribute_rec       => p_global_attribute_rec,
                  p_comments                   => p_comments,

               --Multiple Prepayments project
                  p_refund_type                => l_refund_type,

                  x_return_status              => x_return_status,
                  x_msg_count                  => x_msg_count,
                  x_msg_data                   => x_msg_data,
                  p_prepay_application_id      => p_prepay_application_id
                  );

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('Refund_Prepayments: ' || 'Receivable App ID  : '||p_prepay_application_id);
              arp_util.debug('Refund_Prepayments: ' || 'Process Payments status : '||x_return_status);
           END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              EXIT;
           END IF;

              l_refund_amount := l_refund_amount - l_rcpt_refund_amount;

            --This is to indicate how many receipt this amount has been prorated.
              l_number_of_refund_receipts := l_number_of_refund_receipts + 1;
           ELSE
               EXIT; -- Exit out NOCOPY the loop
           END IF;  --refund_amount > 0
         END LOOP;

    END IF;   ---payment_set_id not null

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Refund_Prepayments: ' || 'Process Payments status : '||x_return_status);
         END IF;

    l_number_of_refund_receipts := 1;

    END IF; --cash receipt_id or payment_set_id

     /*-------------------------------------------------
          Finally error Handling
          Moved it down fron before the end if
        --------------------------------------------------*/
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            ---Bug 3628401 raising expected error
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;

         END IF;


        p_number_of_refund_receipts := l_number_of_refund_receipts;

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Refund_Prepayments: ' || 'committing');
            END IF;
              Commit;
        END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data);

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('ar_prepayments.refund_prepayments(-)');
      END IF;


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  SQLCODE, G_MSG_ERROR);
                   arp_util.debug(  SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO refund_prepay_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

               -- Display_Parameters;
                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );

       WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

       IF (SQLCODE = -20001) THEN
           ROLLBACK TO refund_prepay_PVT;

           --  Display_Parameters;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','AR_PREPAYMENTS_PUB.refund : '||SQLERRM);
           FND_MSG_PUB.Add;
           FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                      p_count  =>  x_msg_count,
                                      p_data   => x_msg_data);
           RETURN;
       ELSE
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','REFUND_PREPAYMENT : '||SQLERRM);
         FND_MSG_PUB.Add;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Refund_Prepayment: ' || SQLCODE, G_MSG_ERROR);
      arp_util.debug('Refund_Prepayment: ' || SQLERRM, G_MSG_ERROR);
   END IF;

   ROLLBACK TO refund_prepay_PVT;

   IF      FND_MSG_PUB.Check_Msg_Level THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                   l_api_name
                                   );
   END IF;

   --   Display_Parameters;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count       =>      x_msg_count,
                                  p_data        =>      x_msg_data);


END refund_prepayments;

------Multiple Prepayments project-------------------------------------------
---Removing the procedure  Process_Credit_Card to charge the Credit card------

PROCEDURE match_prepayment (p_payment_schedule_id   IN  NUMBER,
                            p_apply_date            IN  DATE,
                            p_apply_gl_date         IN  DATE,
                            p_cash_receipt_id       OUT NOCOPY NUMBER,
                            ps_amt_due_remain       OUT NOCOPY NUMBER,
                            x_return_status         OUT NOCOPY VARCHAR2
                            ) IS

CURSOR paymentset_cur(c_customer_trx_id  NUMBER) IS
       SELECT distinct ctl.payment_set_id
       FROM   ra_customer_trx_lines ctl
       WHERE  ctl.payment_set_id is not null
       AND    ctl.customer_trx_id= c_customer_trx_id;

CURSOR prepayapp_cur(c_payment_set_id  NUMBER) IS
       SELECT *
       FROM   ar_receivable_applications
       WHERE  display ='Y'
       AND    applied_payment_schedule_id = -7
       AND    payment_set_id = c_payment_set_id
       order by amount_applied;

l_payment_schedule_id           ar_payment_schedules.payment_schedule_id%TYPE;
l_ps_rec                        ar_payment_schedules%ROWTYPE;
l_api_version                   CONSTANT NUMBER       := 1.0;
l_api_name                      CONSTANT VARCHAR2(20) := 'MATCH_PREPAYMENT';
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_amount_applied                ar_receivable_applications.amount_applied%TYPE := 0;
l_prepay_amount_reapplied       ar_receivable_applications.amount_applied%TYPE := 0;
l_receivable_application_id     ar_receivable_applications.receivable_application_id%TYPE;
l_attribute_rec                 ar_receipt_api_pub.attribute_rec_type;
l_global_attribute_rec          ar_receipt_api_pub.global_attribute_rec_type;
l_prepayment_exist_flag         VARCHAR2(1);
l_complete_applied_flag         BOOLEAN := FALSE;

BEGIN
  SAVEPOINT match_prepayment_PVT;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_prepayments.match_prepayment (+)');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_payment_schedule_id := p_payment_schedule_id;

  BEGIN
     SELECT 'Y'
     INTO   l_prepayment_exist_flag
     FROM  ar_payment_schedules ps,
           ra_customer_trx ct
     WHERE ps.customer_trx_id =ct.customer_trx_id
     AND   NVL(ct.prepayment_flag,'N') = 'Y'
     AND   ps.payment_schedule_id=l_payment_schedule_id;

  EXCEPTION
     WHEN no_data_found THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('ar_prepayments.match_prepayment No prepayment exists');
         END IF;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         RETURN;
     WHEN others THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('EXCEPTION :ar_prepayments.match_prepayment Check ');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
  END;

--fetch invoice payment schedule
  arp_ps_pkg.fetch_p(l_payment_schedule_id,l_ps_rec);

  FOR paymentset_rec in paymentset_cur(l_ps_rec.customer_trx_id) LOOP

      FOR prepayapp_rec in prepayapp_cur(paymentset_rec.payment_set_id) LOOP

            p_cash_receipt_id := prepayapp_rec.cash_receipt_id;

          --Unapply the prepayment
            ar_receipt_api_pub.Unapply_other_account(
              --Standard API parameters.
                p_api_version               => 1.0,
                x_return_status             => l_return_status,
                x_msg_count                 => l_msg_count,
                x_msg_data                  => l_msg_data,
                p_receipt_number            => NULL,
                p_cash_receipt_id           => prepayapp_rec.cash_receipt_id,
                p_receivable_application_id => prepayapp_rec.receivable_application_id,
                p_reversal_gl_date          => p_apply_gl_date,
                p_called_from               => 'PREPAYMENT'  --Bug7194951
                );

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('match_prepayment: ' || 'unapply_other_account retun status : '||l_return_status);
            END IF;
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	       FND_FILE.put_line(fnd_file.log,'Prepayment is not getting unapplied Cash Receipt ID : ' || prepayapp_rec.cash_receipt_id);
               x_return_status := FND_API.G_RET_STS_ERROR;
               EXIT;
            END IF;

            IF NVL(l_ps_rec.amount_due_remaining,0) < NVL(prepayapp_rec.amount_applied,0)
            THEN
               l_amount_applied := NVL(l_ps_rec.amount_due_remaining,0);
               l_prepay_amount_reapplied := prepayapp_rec.amount_applied - l_ps_rec.amount_due_remaining;
            ELSE
               l_amount_applied := NVL(prepayapp_rec.amount_applied,0);
            END IF;

          --Apply to invoice
            ar_receipt_api_pub.Apply(p_api_version  => l_api_version,
                     x_return_status                => l_return_status,
                     x_msg_count                    => l_msg_count,
                     x_msg_data                     => l_msg_data,
                     p_cash_receipt_id              => prepayapp_rec.cash_receipt_id,
                     p_trx_number                   => l_ps_rec.trx_number,
                     p_customer_trx_id              => l_ps_rec.customer_trx_id,
                     p_installment                  => l_ps_rec.terms_sequence_number,
                     p_applied_payment_schedule_id  => l_ps_rec.payment_schedule_id,
                     p_amount_applied               => l_amount_applied,
                     p_apply_date                   => p_apply_date,
                     p_apply_gl_date                => p_apply_gl_date,
                     p_called_from                  => 'PREPAYMENT',
                     p_payment_set_id               => prepayapp_rec.payment_set_id
                      );

            l_ps_rec.amount_due_remaining := (l_ps_rec.amount_due_remaining - l_amount_applied);

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('match_prepayment: ' || 'Apply retun status : '||l_return_status);
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_FILE.put_line(fnd_file.log,'Prepayment is not getting applied to Invoice ');
               FND_FILE.put_line(fnd_file.log,'Cash receipt ID : ' || prepayapp_rec.cash_receipt_id);
               FND_FILE.put_line(fnd_file.log,'Customer Trx ID : ' || l_ps_rec.customer_trx_id);
               FND_FILE.put_line(fnd_file.log,'Payment Schedule ID: ' || l_ps_rec.payment_schedule_id);
               FND_FILE.put_line(fnd_file.log,'Transaction Number: ' || l_ps_rec.trx_number);
               FND_FILE.put_line(fnd_file.log,'Payment Set ID: ' ||  prepayapp_rec.payment_set_id);
            END IF;

          --Apply rest of the amount back to prepayment
           IF (l_prepay_amount_reapplied > 0) AND (x_return_status <> FND_API.G_RET_STS_ERROR) THEN
              --Assign atributes
                l_attribute_rec.attribute_category := prepayapp_rec.attribute_category;
                l_attribute_rec.attribute1         := prepayapp_rec.attribute1;
                l_attribute_rec.attribute2         := prepayapp_rec.attribute2;
                l_attribute_rec.attribute3         := prepayapp_rec.attribute3;
                l_attribute_rec.attribute4         := prepayapp_rec.attribute4;
                l_attribute_rec.attribute5         := prepayapp_rec.attribute5;
                l_attribute_rec.attribute6         := prepayapp_rec.attribute6;
                l_attribute_rec.attribute7         := prepayapp_rec.attribute7;
                l_attribute_rec.attribute8         := prepayapp_rec.attribute8;
                l_attribute_rec.attribute9         := prepayapp_rec.attribute9;
                l_attribute_rec.attribute10        := prepayapp_rec.attribute10;
                l_attribute_rec.attribute11        := prepayapp_rec.attribute11;
                l_attribute_rec.attribute12        := prepayapp_rec.attribute12;
                l_attribute_rec.attribute13        := prepayapp_rec.attribute13;
                l_attribute_rec.attribute14        := prepayapp_rec.attribute14;
                l_attribute_rec.attribute15        := prepayapp_rec.attribute15;
                l_global_attribute_rec.global_attribute_category  :=
                                         prepayapp_rec.global_attribute_category;
                l_global_attribute_rec.global_attribute1  :=  prepayapp_rec.global_attribute1;
                l_global_attribute_rec.global_attribute2  :=  prepayapp_rec.global_attribute2;
                l_global_attribute_rec.global_attribute3  :=  prepayapp_rec.global_attribute3;
                l_global_attribute_rec.global_attribute4  :=  prepayapp_rec.global_attribute4;
                l_global_attribute_rec.global_attribute5  :=  prepayapp_rec.global_attribute5;
                l_global_attribute_rec.global_attribute6  :=  prepayapp_rec.global_attribute6;
                l_global_attribute_rec.global_attribute7  :=  prepayapp_rec.global_attribute7;
                l_global_attribute_rec.global_attribute8  :=  prepayapp_rec.global_attribute8;
                l_global_attribute_rec.global_attribute9  :=  prepayapp_rec.global_attribute9;
                l_global_attribute_rec.global_attribute10 :=  prepayapp_rec.global_attribute10;
                l_global_attribute_rec.global_attribute11 :=  prepayapp_rec.global_attribute11;
                l_global_attribute_rec.global_attribute12 :=  prepayapp_rec.global_attribute12;
                l_global_attribute_rec.global_attribute13 :=  prepayapp_rec.global_attribute13;
                l_global_attribute_rec.global_attribute14 :=  prepayapp_rec.global_attribute14;
                l_global_attribute_rec.global_attribute15 :=  prepayapp_rec.global_attribute15;
                l_global_attribute_rec.global_attribute16 :=  prepayapp_rec.global_attribute16;
                l_global_attribute_rec.global_attribute17 :=  prepayapp_rec.global_attribute17;
                l_global_attribute_rec.global_attribute18 :=  prepayapp_rec.global_attribute18;
                l_global_attribute_rec.global_attribute19 :=  prepayapp_rec.global_attribute19;
                l_global_attribute_rec.global_attribute20 :=  prepayapp_rec.global_attribute20;

                ar_receipt_api_pub.Apply_other_account(
                 -- Standard API parameters.
                   p_api_version      => l_api_version,
                   x_return_status    => l_return_status,
                   x_msg_count        => l_msg_count,
                   x_msg_data         => l_msg_data,
                   p_receivable_application_id => l_receivable_application_id,
                 --Receipt application parameters.
                   p_cash_receipt_id           => prepayapp_rec.cash_receipt_id,
                   p_amount_applied            => l_prepay_amount_reapplied,
                   p_receivables_trx_id        => prepayapp_rec.receivables_trx_id,
                   p_applied_payment_schedule_id => -7,
                   p_apply_date                => prepayapp_rec.apply_date,
                   p_apply_gl_date             => p_apply_gl_date,
                   p_ussgl_transaction_code    => prepayapp_rec.ussgl_transaction_code,
                   p_application_ref_type      => prepayapp_rec.application_ref_type,
                   p_application_ref_id        => prepayapp_rec.application_ref_id,
                   p_application_ref_num       => prepayapp_rec.application_ref_num,
                   p_secondary_application_ref_id => prepayapp_rec.secondary_application_ref_id,
                   p_payment_set_id               => prepayapp_rec.payment_set_id,
                   p_attribute_rec             => l_attribute_rec,
                -- ******* Global Flexfield parameters *******
                   p_global_attribute_rec      => l_global_attribute_rec
                 );

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('match_prepayment: ' || 'apply_other_account retun status : '||l_return_status);
                 END IF;

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
               	    FND_FILE.put_line(fnd_file.log,'Leftover amount is not getting applied back to Prepayment ');
                    FND_FILE.put_line(fnd_file.log,'Cash receipt ID : ' || prepayapp_rec.cash_receipt_id);
                    FND_FILE.put_line(fnd_file.log,'Payment Set ID: ' ||  prepayapp_rec.payment_set_id);
                 END IF;

           END IF;

           ps_amt_due_remain       := l_ps_rec.amount_due_remaining;

           IF l_ps_rec.amount_due_remaining <= 0 THEN
              l_complete_applied_flag := TRUE;
              EXIT;
           END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              EXIT;
           END IF;


      END LOOP;

      IF (l_complete_applied_flag)  THEN
          EXIT;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         EXIT;
      END IF;

  END LOOP;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     ROLLBACK to match_prepayment_PVT;
     IF NVL(l_msg_count,0)  > 0 Then
        IF l_msg_count  = 1 Then
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('match_prepayment: ' || l_msg_data);
           END IF;

        ELSIF l_msg_count > 1 Then
              FOR l_count IN 1..l_msg_count LOOP

                  l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('match_prepayment: ' || to_char(l_count)||' : '||l_msg_data);
                  END IF;
              END LOOP;

        END IF; -- l_msg_count
     END IF; -- NVL(l_msg_count,0)
  ELSE
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_prepayments.match_prepayment (-)');
  END IF;

 EXCEPTION
    WHEN others THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('EXCEPTION : ar_prepayments.match_prepayment ||SQLERRM');
         END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END match_prepayment;

/*=======================================================================
 | PUBLIC Procedure get_installment
 |
 | DESCRIPTION
 |      Gets the installment number and the amount due for a payment term
 |      -----------------------------------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 10-JUL-2003           Jyoti Pandey   o Created
 | 12-DEC-2003           Jyoti Pandey   o Forward Port Bug 3316165 for Base bug
 |                                        3248093. Changing p_installment_tbl
 |                                        ar_prepayments_pub.installment_tbl
 |
 *=======================================================================*/
 PROCEDURE get_installment(
      p_term_id         IN  NUMBER,
      p_amount          IN  NUMBER,
      p_currency_code   IN  VARCHAR2,
      --bug 3248093 --
      p_installment_tbl OUT NOCOPY ar_prepayments_pub.installment_tbl,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2) IS

l_dummy VARCHAR2(1);
i BINARY_INTEGER;

--Gets the installment amount and the installment number based
--on the functional currency
CURSOR get_installment_amount (l_term_id IN NUMBER, l_amount IN NUMBER ,
                               l_currency_code IN VARCHAR2) IS
select sequence_num as installment_number,
       arp_util.CurrRound( (relative_amount/base_amount ) * l_amount ,
                          l_currency_code) as installment_amount
from ra_terms t , ra_terms_lines tl
where t.term_id = tl.term_id
and   t.term_id =  l_term_id;

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('ar_prepayment.get_installment (+)');
     END IF;

     ---- first reinitialize ARP_GLOBAL
     arp_global.init_global;

    /*-------------------------------------+
      |   Standard start of API savepoint  |
      +------------------------------------*/
     SAVEPOINT get_installment_PVT;

     /*----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*-------Validate the p_term_id---------------*/
     IF p_term_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_PPAY_PAY_TERM_INVALID');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     ELSE
        BEGIN
           SELECT 1 into l_dummy
           FROM RA_TERMS_B
           WHERE  term_id = p_term_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('AR','AR_PPAY_PAY_TERM_INVALID');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END;
     END IF;

     -----Input amount should not be null or 0 -------
     IF (  (p_amount is null) or (p_amount <= 0) ) THEN
          FND_MESSAGE.SET_NAME('AR','AR_PPAY_BASE_AMOUNT_INVALID');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

      -----Input currency code  should not be invalid  -------
      IF p_currency_code IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CURR_CODE_INVALID');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     ELSE
        BEGIN
           SELECT 1 into l_dummy
           FROM fnd_currencies
           WHERE  currency_code = p_currency_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_CURR_CODE_INVALID');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END;
     END IF;


     i := 1;
     OPEN get_installment_amount(p_term_id, p_amount , p_currency_code);
     loop
          fetch get_installment_amount  into
            p_installment_tbl(i).installment_number,
            p_installment_tbl(i).installment_amount;

              exit when get_installment_amount%NOTFOUND;

            i := i + 1;
           end loop;
           close get_installment_amount;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('ar_prepayment.get_installment (-)');
     END IF;

     EXCEPTION
     WHEN fnd_api.g_exc_error THEN


      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);


     WHEN others THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

     --Bug 3107679 removed to_char call
     FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','GET_INSTALLMENT : '||SQLERRM);
     FND_MSG_PUB.Add;
     FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

     ROLLBACK to get_installment_PVT;

END get_installment;

/*-------------------------------------------------------------------------+
 | FUNCTION NAME                                                           |
 |      rule_select_prepayments                                                 |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Subscription to the business event AutoInvoice
 |                                                                         |
 | PARAMETERS                                                              |
 |                                                                         |
 | MODIFIES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |
 |                                                                         |
 +-------------------------------------------------------------------------*/
 FUNCTION rule_select_prepayments(
                             p_subscription_guid  in raw,
                             p_event  in out NOCOPY wf_event_t)RETURN VARCHAR2 IS

  l_request_id          NUMBER := null;
  l_conc_request_id     NUMBER := null;

  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_org_id           NUMBER;

BEGIN

  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');

  SAVEPOINT  Select_Prepay_Event;

   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);


   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('The rule_select_prepayments Subscription to AutoInvoice  ''');
     arp_util.debug('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
   END IF;


   ---get the parameter request_id
   l_request_id := p_event.GetValueForParameter('REQUEST_ID');
   -- bug 9027940

   IF l_request_id <> 0 AND l_request_id is not null THEN

      BEGIN
          select org_id into l_org_id
          from fnd_concurrent_requests
          where request_id = l_request_id;

      EXCEPTION
      WHEN OTHERS  THEN
          ROLLBACK TO Select_Prepay_Event;

          FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
          FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
          FND_MSG_PUB.ADD;

	  RETURN 'ERROR';
      END;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
	FND_FILE.put_line(fnd_file.log, 'Request id is ' || l_request_id);
	arp_util.debug('Request id is' ||  l_request_id);

        FND_FILE.put_line(fnd_file.log, 'ORGANISATION ID is ' || l_org_id);
        arp_util.debug('ORG id is' ||  l_org_id);
   END IF;

    IF l_request_id <> 0 AND l_request_id is not null THEN
       ---Make a callout to Concurrent program
       fnd_request.set_org_id(l_org_id);
       l_conc_request_id := fnd_request.submit_request('AR',
                         'ARPREMAT',
                         'Prepayment Matching Program',
                          to_char(sysdate,'DD-MON-YY HH:MI:SS'),
                          FALSE,
                          'AutoInvoice Batch',
                          l_request_id );

       IF l_conc_request_id = 0 THEN
           FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

   RETURN 'SUCCESS';


   EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO Select_Prepay_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_PREPAYMENTS', 'RULE_SELECT_PREPAYMENTS', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';


 END rule_select_prepayments;

/*=======================================================================
 | PUBLIC Procedure Select_Prepayments
 |
 | DESCRIPTION
 |      Called from Concurrent program 'Prepayments Matching Program' to
 |      match the prepaid receipts to their invoices
 |      -----------------------------------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |     p_batch_source :  'All Invoices' for matching all the invoices
 |                       'AutoInvoice Batch' for matching invoices in a
 |                        particular AutoInvoice Batch
 |     p_request_id  : Populated only if p_batch_source =  'AutoInvoice Batch'
 |                     Request ID for the AutoInvoice Batch
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 10-JUL-2003           Jyoti Pandey   o Created
 |
 *=======================================================================*/
  PROCEDURE Select_Prepayments ( errbuf      OUT NOCOPY    VARCHAR2,
                                 retcode     OUT  NOCOPY   VARCHAR2,
                                 p_batch_source IN VARCHAR2,
                                 p_request_id   IN NUMBER )

    IS

     l_retcode             NUMBER := 0;
     l_request_id  NUMBER := null;
     l_payment_schedule_id NUMBER;
     l_amt_due_remaining   NUMBER;
     l_cash_receipt_id     NUMBER;
     l_ps_amt_due_remain   NUMBER;
     l_ps_due_date         DATE;	--Bug7194951
     l_return_status       VARCHAR2(1);
     l_msg_data VARCHAR2(2000);
     lb_request_status BOOLEAN;
     ---identify all invoices in the autoinvoice batch that are prepaid
     ---for an auto invoice batch
     ---Bug: 3717795 Remove check on receipt methods
     ---Bug7194951(FP of 7146916) use union to use index for improving performance
     TYPE prepay_invoices_type IS REF CURSOR;
     get_prepay_invoices prepay_invoices_type;
/*
     CURSOR get_prepay_invoices(p_req_id IN NUMBER ,p_batch_src IN VARCHAR2) IS
     SELECT
       ps.payment_schedule_id,
       ps.amount_due_remaining
    FROM
       ra_customer_trx ct,
       ar_payment_schedules ps
    WHERE  ps.status             = 'OP'
    AND    ps.amount_due_remaining > 0
    AND    ps.gl_date_closed     = TO_DATE('4712/12/31', 'YYYY/MM/DD')
     ---  Bug : 917451 in order to force the use of AR_PAYMENT_SCHEDULES_N9 --
    AND    ps.selected_for_receipt_batch_id IS NULL
    ---AND    ps.due_date +0       <= TO_DATE(SYSDATE) + TO_NUMBER(rm.lead_days)
    AND    nvl(ct.prepayment_flag, 'N') = 'Y'
    AND    ps.customer_trx_id    = ct.customer_trx_id
    AND    decode(p_batch_src,'All Invoices', '1', ct.request_id) =
           decode(p_batch_src,'All Invoices', '1' , p_req_id)
    ORDER BY ps.due_date;
*/
BEGIN

  -- Initialize message stack
  FND_MSG_PUB.initialize;
  FND_FILE.put_line(fnd_file.log,'Starting Concurrent Program ''Prepayment Matching  ''');
  FND_FILE.put_line(fnd_file.log,'Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS' ));

 ---get the parameter request_id
 l_request_id := p_request_id;

 ---Validate that if p_batch_source is NOT 'ALL' then there is request_id
   if p_batch_source <> 'All Invoices' then

      IF( l_request_id IS NULL OR l_request_id = 0 )THEN
       FND_MESSAGE.SET_NAME('AR','AR_PPAY_INVALID_REQ_ID');
       FND_MSG_PUB.Add;
       l_retcode := 10;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   end if;

 SAVEPOINT prepay_start;
  --Bug7194951 (FP of Bug7146916) Start Here
  IF p_batch_source = 'All Invoices' then
    OPEN get_prepay_invoices for
     SELECT
       ps.payment_schedule_id,
       ps.amount_due_remaining,
       ps.due_date
    FROM
       ra_customer_trx ct,
       ar_payment_schedules ps
    WHERE  ps.status             = 'OP'
    AND    ps.amount_due_remaining > 0
    AND    ps.gl_date_closed     = TO_DATE('4712/12/31', 'YYYY/MM/DD')
    AND    ps.selected_for_receipt_batch_id IS NULL
    AND    nvl(ct.prepayment_flag, 'N') = 'Y'
    AND    ps.customer_trx_id    = ct.customer_trx_id
    order by ps.due_date;
  ELSE
    OPEN get_prepay_invoices for
     SELECT
       ps.payment_schedule_id,
       ps.amount_due_remaining,
       ps.due_date
    FROM
       ra_customer_trx ct,
       ar_payment_schedules ps
    WHERE  ps.status             = 'OP'
    AND    ps.amount_due_remaining > 0
    AND    ps.gl_date_closed     = TO_DATE('4712/12/31', 'YYYY/MM/DD')
    AND    ps.selected_for_receipt_batch_id IS NULL
    AND    nvl(ct.prepayment_flag, 'N') = 'Y'
    AND    ps.customer_trx_id    = ct.customer_trx_id
    AND    p_batch_source  = 'AutoInvoice Batch'
    AND    ct.request_id = p_request_id
    order by ps.due_date;
  END IF;
  --Bug7194951 (FP of Bug7146916) End Here

  LOOP
    fetch get_prepay_invoices into
     l_payment_schedule_id  ,
     l_amt_due_remaining,l_ps_due_date;	  --Bug7194951
  EXIT when get_prepay_invoices%NOTFOUND;

   ---Ajay, since there is no report exposing what happened? should be have them
   ---as regular log messages as fnd_file.put_line or this?

   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('AR-ARZPREPAY-bef: Payment Schedule Id '||
            l_payment_schedule_id);
     arp_util.debug('AR-ARZPREPAY-bef: PS Amt Due Remaining' ||
            l_amt_due_remaining);
  END IF;

 /*-------------------------------------------------------------------------+
  |Call the match prepay routine
  +-------------------------------------------------------------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Starting ar_prepayments.match_prepayment Routine(+) ');
   END IF;

   begin
   SAVEPOINT match_start;

      ---Recipt API apply or unapply
      ar_prepayments.match_prepayment (
        p_payment_schedule_id   => l_payment_schedule_id,
        p_apply_date            => null,
        p_apply_gl_date         => null,
        p_cash_receipt_id       => l_cash_receipt_id,
        ps_amt_due_remain       => l_ps_amt_due_remain,
        x_return_status         => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         l_retcode := 10;
      END IF;

      IF PG_DEBUG in ('Y', 'C') then
       arp_util.debug('ar_prepayments.match_prepayment-after:  P Cash Receipt Id >'                      || l_cash_receipt_id);
       arp_util.debug('AR-ARZPREPAY-after:  PS Amt Due Remaining>'
                      || l_ps_amt_due_remain);
     END IF;

  EXCEPTION

     WHEN others THEN
       fnd_file.put_line(fnd_file.log,'EXCEPTION :AR_PREPAYMENTS_PUB.MATCH_PREPAYMENT Routine'||SQLERRM);
       l_retcode := 10;
       ROLLBACK to match_start;

 end;  ---end to call to match_prepayment


   if (l_ps_amt_due_remain = -1) then
        fnd_file.put_line(fnd_file.log,' Payment Schedule Id '|| l_payment_schedule_id);
   end if;


 END LOOP;
 close get_prepay_invoices;
/*bug 8372888*/
COMMIT;
 IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('End ar_prepayments.match_prepayment Routine (-)');
 END IF;

 if (l_retcode <> 0) then
     FND_FILE.put_line(fnd_file.log,'There are few prepayments which could not match. Pl check log file for details');
     lb_request_status := FND_CONCURRENT.set_completion_status('WARNING', '');
--     RAISE FND_API.G_EXC_ERROR;
 end if;


  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
     FND_MESSAGE.SET_NAME ('AR','AR_PREPAY_ERROR');
     FND_MSG_PUB.Add;

        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         l_msg_data :=
               substr(l_msg_data || ' ' || FND_MSG_PUB.Get(p_encoded =>
                                           FND_API.G_FALSE ),  1,255);
        END LOOP;

        fnd_file.put_line(fnd_file.log, l_msg_data);
        FND_MSG_PUB.Delete_Msg;
        retcode  := l_retcode;

 END select_prepayments;

END AR_PREPAYMENTS;

/
