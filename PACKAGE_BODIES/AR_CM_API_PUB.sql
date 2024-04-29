--------------------------------------------------------
--  DDL for Package Body AR_CM_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CM_API_PUB" AS
/* $Header: ARXPCMEB.pls 120.0.12010000.3 2008/12/24 06:24:51 dgaurab ship $ */
/*#
 * Credit Memo APIs allow users to apply/unapply on account credit memo
 * against a debit memo or invoice using simple calls to PL/SQL functions.
  */

G_PKG_NAME   CONSTANT VARCHAR2(30)      := 'AR_CM_API_PUB';

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE apply_on_account(
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_cm_app_rec       IN  cm_app_rec_type,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_out_rec_application_id        OUT NOCOPY NUMBER,
      x_acctd_amount_applied_from OUT NOCOPY ar_receivable_applications.acctd_amount_applied_from%TYPE,
      x_acctd_amount_applied_to OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
      p_org_id           IN   NUMBER   DEFAULT NULL)

IS

    l_api_name       CONSTANT  VARCHAR2(30) := 'Apply_on_account';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_cm_customer_trx_id  NUMBER;
    l_inv_customer_trx_id  NUMBER;
    l_inv_customer_trx_line_id  NUMBER;
    l_installment  NUMBER(15);
    l_applied_payment_schedule_id  NUMBER(15);
    l_def_ids_return_status VARCHAR(1);
    l_def_return_status VARCHAR(1);
    l_val_return_status VARCHAR(1);
    l_dflex_val_return_status  VARCHAR2(1);
    l_return_status   VARCHAR2(1);
    l_cm_gl_date      DATE;
    l_cm_amount_rem   NUMBER;
    l_cm_trx_date     DATE;
    l_cm_ps_id        NUMBER;
    l_cm_currency_code     fnd_currencies.currency_code%TYPE;
    l_inv_due_date             DATE;
    l_inv_currency_code     fnd_currencies.currency_code%TYPE;
    l_inv_trx_date             DATE;
    l_inv_gl_date              DATE;
    l_allow_overappln_flag     VARCHAR2(1);
    l_natural_appln_only_flag  VARCHAR2(1);
    l_creation_sign            VARCHAR2(1);
    l_inv_line_amount           NUMBER;
    l_inv_amount_rem           NUMBER;

    l_apply_date DATE;
    l_apply_gl_date DATE;
    l_show_closed_invoices VARCHAR2(1);
    l_amount_applied NUMBER;


    l_rec_application_id   NUMBER;
    l_acctd_amount_applied_from  NUMBER;
    l_acctd_amount_applied_to   NUMBER;

    l_attribute_rec      ar_receipt_api_pub.attribute_rec_type;
    l_org_return_status  VARCHAR2(1); --bug7641800
    l_org_id             NUMBER;

BEGIN


      IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('AR_CM_API_PUB.APPLY_ON_ACCOUNT(+)');
      END IF;

      /*------------------------------------+
      |   Standard start of API savepoint  |
      +------------------------------------*/

      SAVEPOINT Apply_CM;

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
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
        END IF;

       /*-------------------------------------------------+
        | Initialize SOB/org dependent variables          |
        +-------------------------------------------------*/
/* bug7641800, Added parameter to accept org_id from customer and added
   code to set ORG accordingly. */
	l_org_id            := p_org_id;
        l_org_return_status := FND_API.G_RET_STS_SUCCESS;
        ar_mo_cache_utils.set_org_context_in_api
        (
          p_org_id =>l_org_id,
          p_return_status =>l_org_return_status
        );

   IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
   ELSE
--        arp_global.init_global;
--        arp_standard.init_standard;

       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;

       /*---------------------------------------------+
        |   ========== Start of API Body ==========   |
        +---------------------------------------------*/

          l_cm_customer_trx_id := p_cm_app_rec.cm_customer_trx_id;
          l_inv_customer_trx_id := p_cm_app_rec.inv_customer_trx_id;
          l_inv_customer_trx_line_id := p_cm_app_rec.inv_customer_trx_line_id;
          l_installment := p_cm_app_rec.installment;
          l_applied_payment_schedule_id := p_cm_app_rec.applied_payment_schedule_id;
          l_apply_date := p_cm_app_Rec.apply_date;
          l_apply_gl_date := p_cm_app_rec.gl_date;
          l_show_closed_invoices := p_cm_app_rec.show_closed_invoices;
          l_amount_applied := p_cm_app_rec.amount_applied;

         /*-----------------------+
           |                       |
           |ID TO VALUE CONVERSION |
           |                       |
           +-----------------------*/

        -- Call Defaulting API here to get IDs based on input parameters
        ar_cm_val_pvt.default_app_ids(
                       l_cm_customer_trx_id,
                       p_cm_app_rec.cm_trx_number,
                       l_inv_customer_trx_id,
                       p_cm_app_rec.inv_trx_number,
                       l_inv_customer_trx_line_id,
                       p_cm_app_rec.inv_line_number,
                       l_installment,
                       l_applied_payment_schedule_id,
                       l_def_ids_return_status);


        IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug(  'Defaulting Ids Return_status = '||l_def_ids_return_status);
        END IF;
          /*---------------------+
           |                     |
           |    DEFAULTING       |
           |                     |
           +---------------------*/

       -- Call API for defaulting
       ar_cm_val_pvt.default_app_info(
              l_cm_customer_trx_id  ,
              l_inv_customer_trx_id ,
              l_inv_customer_trx_line_id  ,
              l_show_closed_invoices  ,
              l_installment         ,
              l_apply_date           ,
              l_apply_gl_date        ,
              l_amount_applied       ,
              l_applied_payment_schedule_id ,
              l_cm_gl_date          ,
              l_cm_trx_date         ,
              l_cm_amount_rem       ,
              l_cm_currency_code    ,
              l_inv_due_date         ,
              l_inv_currency_code    ,
              l_inv_amount_rem       ,
              l_inv_trx_date         ,
              l_inv_gl_date          ,
              l_allow_overappln_flag ,
              l_natural_appln_only_flag  ,
              l_creation_sign        ,
              l_cm_ps_id  ,
              l_inv_line_amount       ,
              l_def_return_status
               );
        IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug(  'Default Info Return_status = '||l_def_return_status);
          arp_util.debug(  'Applied PS ID = '||l_applied_payment_schedule_id);
        END IF;


         /*---------------------+
           |                     |
           |    VALIDATION       |
           |                     |
           +---------------------*/
      -- Call new PVT API for validation
      IF l_def_return_status = FND_API.G_RET_STS_SUCCESS  AND
         l_def_ids_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
         ar_cm_val_pvt.validate_app_info(
                      l_apply_date,
                      l_cm_trx_date,
                      l_inv_trx_date,
                      l_apply_gl_date,
                      l_cm_gl_date,
                      l_inv_gl_date,
                      l_amount_applied,
                      l_applied_payment_schedule_id,
                      l_inv_customer_trx_line_id,
                      l_inv_line_amount,
                      l_creation_sign,
                      l_allow_overappln_flag,
                      l_natural_appln_only_flag,
                      l_cm_amount_rem,
                      l_inv_amount_rem,
                      l_cm_currency_code ,
                      l_inv_currency_code,
                      l_val_return_status
                          );
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug(  'Validation Return_status = '||l_val_return_status);
                         arp_util.debug(  'Applied PS ID = '||l_applied_payment_schedule_id);
                      END IF;
     END IF;

     -- Validate DFF

     l_attribute_rec.attribute_category := p_cm_app_rec.attribute_category;
     l_attribute_rec.attribute1 := p_cm_app_rec.attribute1;
     l_attribute_rec.attribute2 := p_cm_app_rec.attribute2;
     l_attribute_rec.attribute3 := p_cm_app_rec.attribute3;
     l_attribute_rec.attribute4 := p_cm_app_rec.attribute4;
     l_attribute_rec.attribute5 := p_cm_app_rec.attribute5;
     l_attribute_rec.attribute6 := p_cm_app_rec.attribute6;
     l_attribute_rec.attribute7 := p_cm_app_rec.attribute7;
     l_attribute_rec.attribute8 := p_cm_app_rec.attribute8;
     l_attribute_rec.attribute9 := p_cm_app_rec.attribute9;
     l_attribute_rec.attribute10 := p_cm_app_rec.attribute10;
     l_attribute_rec.attribute11 := p_cm_app_rec.attribute11;
     l_attribute_rec.attribute12 := p_cm_app_rec.attribute12;
     l_attribute_rec.attribute13 := p_cm_app_rec.attribute13;
     l_attribute_rec.attribute14 := p_cm_app_rec.attribute14;
     l_attribute_rec.attribute15 := p_cm_app_rec.attribute15;

     -- Call existing receipt api that does this validation
     -- for populating RA
     ar_receipt_lib_pvt.Validate_Desc_Flexfield(
                                        l_attribute_rec,
                                        'AR_RECEIVABLE_APPLICATIONS',
                                        l_dflex_val_return_status
                                                );

      IF l_def_ids_return_status <> FND_API.G_RET_STS_SUCCESS OR
          l_val_return_status     <> FND_API.G_RET_STS_SUCCESS OR
          l_def_return_status     <> FND_API.G_RET_STS_SUCCESS  OR
          l_dflex_val_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data
                                       );

  END IF; -- Closing IF for ORG_RET_STATUS

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN

            ROLLBACK TO Apply_CM;

             x_return_status := FND_API.G_RET_STS_ERROR ;


             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(  'Error(s) occurred. Rolling back and setting status to ERROR');
             END IF;
             Return;
        END IF;


         /*---------------------+
           |                    |
           | ENTITY HANDLER     |
           |                    |
           +--------------------*/

      -- Display inputs to entity handler
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug(  'CM PS ID = '||l_cm_ps_id ||
                          ' Invoice PS ID = '|| l_applied_payment_schedule_id ||
                          ' AMount applied = '|| l_amount_applied ||
                          ' Apply date = ' || l_apply_date||
                          ' GL date = '|| l_apply_gl_date);
      END IF;

      -- Lock the PS of the CM transaction
      arp_ps_pkg.nowaitlock_p (p_ps_id => l_cm_ps_id);

      -- Lock the PS of the transaction to be applied
      arp_ps_pkg.nowaitlock_p (p_ps_id => l_applied_payment_schedule_id);

       l_return_status := FND_API.G_RET_STS_SUCCESS;


   BEGIN
     --call the entity handler
    arp_process_application.cm_application(
        p_cm_ps_id    => l_cm_ps_id,
        p_invoice_ps_id   => l_applied_payment_schedule_id,
        p_amount_applied  => l_amount_applied,
        p_apply_date      => l_apply_date,
        p_gl_date         => l_apply_gl_date,
        p_ussgl_transaction_code   => p_cm_app_rec.ussgl_transaction_code,
        p_attribute_category   => p_cm_app_rec.attribute_category,
        p_attribute1 => p_cm_app_rec.attribute1,
        p_attribute2 => p_cm_app_rec.attribute2,
        p_attribute3 => p_cm_app_rec.attribute3,
        p_attribute4 => p_cm_app_rec.attribute4,
        p_attribute5 => p_cm_app_rec.attribute5,
        p_attribute6 => p_cm_app_rec.attribute6,
        p_attribute7 => p_cm_app_rec.attribute7,
        p_attribute8 => p_cm_app_rec.attribute8,
        p_attribute9 => p_cm_app_rec.attribute9,
        p_attribute10 => p_cm_app_rec.attribute10,
        p_attribute11 => p_cm_app_rec.attribute11,
        p_attribute12 => p_cm_app_rec.attribute12,
        p_attribute13 => p_cm_app_rec.attribute13,
        p_attribute14 => p_cm_app_rec.attribute14,
        p_attribute15 => p_cm_app_rec.attribute15,
        p_global_attribute_category => p_cm_app_rec.global_attribute_category,
        p_global_attribute1 => p_cm_app_rec.global_attribute1,
        p_global_attribute2 => p_cm_app_rec.global_attribute2,
        p_global_attribute3 => p_cm_app_rec.global_attribute3,
        p_global_attribute4 => p_cm_app_rec.global_attribute4,
        p_global_attribute5 => p_cm_app_rec.global_attribute5,
        p_global_attribute6 => p_cm_app_rec.global_attribute6,
        p_global_attribute7 => p_cm_app_rec.global_attribute7,
        p_global_attribute8 => p_cm_app_rec.global_attribute8,
        p_global_attribute9 => p_cm_app_rec.global_attribute9,
        p_global_attribute10 => p_cm_app_rec.global_attribute10,
        p_global_attribute11 => p_cm_app_rec.global_attribute11,
        p_global_attribute12 => p_cm_app_rec.global_attribute12,
        p_global_attribute13 => p_cm_app_rec.global_attribute13,
        p_global_attribute14 => p_cm_app_rec.global_attribute14,
        p_global_attribute15 => p_cm_app_rec.global_attribute15,
        p_global_attribute16 => p_cm_app_rec.global_attribute16,
        p_global_attribute17 => p_cm_app_rec.global_attribute17,
        p_global_attribute18 => p_cm_app_rec.global_attribute18,
        p_global_attribute19 => p_cm_app_rec.global_attribute19,
        p_global_attribute20 => p_cm_app_rec.global_attribute20,
        p_customer_trx_line_id => l_inv_customer_trx_line_id ,
        p_comments => p_cm_app_rec.comments,
        p_module_name => 'CMAPI',
        p_module_version => p_api_version,
        p_out_rec_application_id  => l_rec_application_id,
        p_acctd_amount_applied_from => l_acctd_amount_applied_from,
        p_acctd_amount_applied_to => l_acctd_amount_applied_to
    );

     x_out_rec_application_id := l_rec_application_id;
     x_acctd_amount_applied_from := l_acctd_amount_applied_from;
     x_acctd_amount_applied_to := l_acctd_amount_applied_to;

   EXCEPTION
     WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                     ROLLBACK TO Apply_CM;

                      --  Display_Parameters;
                      x_return_status := FND_API.G_RET_STS_ERROR ;
                       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ARP_PROCESS_APPLICATION.CM_APPLICATION'||SQLERRM);
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

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(  'committing');
            END IF;
              Commit;
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Apply ()- ');
        END IF;
     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  SQLCODE, G_MSG_ERROR);
                   arp_util.debug(  SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO Apply_CM;
                x_return_status := FND_API.G_RET_STS_ERROR ;

               -- Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  SQLERRM, G_MSG_ERROR);
                END IF;
                ROLLBACK TO Apply_CM;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

               --  Display_Parameters;

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

                IF (SQLCODE = -20001)
                THEN

                      ROLLBACK TO Apply_CM;

                      --If only one error message on the stack,
                      --retrive it

                      x_return_status := FND_API.G_RET_STS_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','APPLY : '||SQLERRM);
                      FND_MSG_PUB.Add;

                      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                                 p_count  =>  x_msg_count,
                                                 p_data   => x_msg_data
                                                );

                      RETURN;

                ELSE
                      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','APPLY : '||SQLERRM);
                      FND_MSG_PUB.Add;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  SQLCODE, G_MSG_ERROR);
                   arp_util.debug(  SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO Apply_CM;

                IF      FND_MSG_PUB.Check_Msg_Level
                THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                        l_api_name
                                       );
                END IF;

             --   Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );


END apply_on_account;

PROCEDURE unapply_on_account(
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_cm_unapp_rec     IN  cm_unapp_rec_type,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      p_org_id           IN   NUMBER   DEFAULT NULL)

IS

l_api_name       CONSTANT VARCHAR2(20) := 'Unapply_on_account';
l_api_version    CONSTANT NUMBER       := 1.0;


l_cm_customer_trx_id     NUMBER;
l_inv_customer_trx_id    NUMBER;
l_applied_payment_schedule_id  NUMBER;
l_receivable_application_id    NUMBER;
l_reversal_gl_date       DATE;
l_apply_gl_date          DATE;
l_cm_gl_date             DATE;

l_def_ids_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_val_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

l_org_return_status  VARCHAR2(1); --bug7641800
l_org_id             NUMBER;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('ar_cm_api_pub.Unapply_on_account()+ ');
        END IF;

        /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

        SAVEPOINT Unapply_CM;

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
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        /*--------------------------------------------------------------+
        |   Initialize message list if p_init_msg_list is set to TRUE  |
        +--------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
        END IF;


         original_cm_unapp_info.cm_trx_number := p_cm_unapp_rec.cm_trx_number;
         original_cm_unapp_info.cm_customer_trx_id := p_cm_unapp_rec.cm_customer_trx_id;
         original_cm_unapp_info.applied_ps_id := p_cm_unapp_rec.applied_payment_schedule_id;
         original_cm_unapp_info.inv_customer_trx_id:= p_cm_unapp_rec.inv_customer_trx_id;
         original_cm_unapp_info.inv_trx_number := p_cm_unapp_rec.inv_trx_number;
         original_cm_unapp_info.receivable_application_id := p_cm_unapp_rec.receivable_application_id;


        /*-------------------------------------------------+
        | Initialize SOB/org dependent variables          |
        +-------------------------------------------------*/
/* bug7641800, Added parameter to accept org_id from customer and added
   code to set ORG accordingly. */
	l_org_id            := p_org_id;
        l_org_return_status := FND_API.G_RET_STS_SUCCESS;
        ar_mo_cache_utils.set_org_context_in_api
        (
          p_org_id =>l_org_id,
          p_return_status =>l_org_return_status
        );

    IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
--        arp_global.init_global;
--        arp_standard.init_standard;

       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;
       /*---------------------------------------------+
        |   ========== Start of API Body ==========   |
        +---------------------------------------------*/

        --Assign IN parameter values to local variables
        --which are also used as assignment targets.

         l_cm_customer_trx_id := p_cm_unapp_rec.cm_customer_trx_id;
         l_inv_customer_trx_id   := p_cm_unapp_rec.inv_customer_trx_id;
         l_applied_payment_schedule_id := p_cm_unapp_rec.applied_payment_schedule_id;
         l_receivable_application_id  := p_cm_unapp_rec.receivable_application_id;
         l_reversal_gl_date := trunc(p_cm_unapp_rec.reversal_gl_date);


        --Derive the id's for the entered values and if both the
        --values and the id's superceed the values

        ar_cm_val_pvt.default_unapp_ids(
                               p_cm_unapp_rec.cm_trx_number ,
                               l_cm_customer_trx_id ,
                               p_cm_unapp_rec.inv_trx_number ,
                               l_inv_customer_trx_id ,
                               l_receivable_application_id,
                               p_cm_unapp_rec.installment ,
                               l_applied_payment_schedule_id ,
                               l_apply_gl_date,
                               l_def_ids_return_status
                                  );
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug(  'Cm customer trx id : '|| l_cm_customer_trx_id );
          arp_util.debug(  'receivable app id : '|| l_receivable_application_id );
       END IF;

        ar_cm_val_pvt.default_unapp_info(
                           l_receivable_application_id,
                           l_apply_gl_date,
                           l_cm_customer_trx_id,
                           l_reversal_gl_date,
                           l_cm_gl_date);

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug(  'Cm customer trx id : '|| l_cm_customer_trx_id );
          arp_util.debug(  'receivable app id : '|| l_receivable_application_id );
          arp_util.debug(  'reversal date : '|| l_reversal_gl_date );
       END IF;
        ar_cm_val_pvt.validate_unapp_info(
                                      l_cm_gl_date,
                                      l_receivable_application_id,
                                      l_reversal_gl_date,
                                      l_apply_gl_date,
                                      l_val_return_status);

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug(  'validation return status :'||l_val_return_status);
       END IF;

       IF l_def_ids_return_status <> FND_API.G_RET_STS_SUCCESS OR
            l_val_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
         END IF;

    END IF; -- Closing IF for ORG_RET_STATUS

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN

            ROLLBACK TO Unapply_CM;

             x_return_status := FND_API.G_RET_STS_ERROR ;

             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data
                                       );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug(  'Error(s) occurred. Rolling back and setting status to ERROR');
             END IF;
             Return;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  '*******DUMP THE INPUT PARAMETERS ********');
           arp_util.debug(  'l_receivable_application_id :'||to_char(l_receivable_application_id));
           arp_util.debug(  'l_applied_payment_schedule_id :'||to_char(l_applied_payment_schedule_id));
           arp_util.debug(  'l_reversal_gl_date :'||to_char(l_reversal_gl_date,'DD-MON-YY'));
        END IF;


       BEGIN
        --call the entity handler.
          arp_process_application.reverse_cm_app(
                                l_receivable_application_id,
                                l_applied_payment_schedule_id,
                                l_reversal_gl_date,
                                trunc(sysdate),
                                'CMAPI',
                                p_api_version);
       EXCEPTION
         WHEN OTHERS THEN


               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                     ROLLBACK TO Unapply_CM;

                      --  Display_Parameters;
                      x_return_status := FND_API.G_RET_STS_ERROR ;
                       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ARP_PROCESS_APPLICATION.REVERSE_CM_APP : '||SQLERRM);
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

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug(  'committing');
            END IF;
              Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('ar_cm_api.Unapply_on_account ()- ');
        END IF;
     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  SQLCODE, G_MSG_ERROR);
                   arp_util.debug(  SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO Unapply_CM;
                x_return_status := FND_API.G_RET_STS_ERROR ;

              --  Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  SQLERRM, G_MSG_ERROR);
                END IF;
                ROLLBACK TO Unapply_CM;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

               --  Display_Parameters;

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

                IF (SQLCODE = -20001)
                THEN

                      ROLLBACK TO Unapply_CM;

                      x_return_status := FND_API.G_RET_STS_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','UNAPPLY : '||SQLERRM);
                      FND_MSG_PUB.Add;

                      --If only one error message on the stack,
                      --retrive it

                      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                                 p_count  =>  x_msg_count,
                                                 p_data   => x_msg_data
                                                );

                      RETURN;

                ELSE
                      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','UNAPPLY : '||SQLERRM);
                      FND_MSG_PUB.Add;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(  SQLCODE, G_MSG_ERROR);
                   arp_util.debug(  SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO Unapply_CM;

                IF      FND_MSG_PUB.Check_Msg_Level
                THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                        l_api_name
                                       );
                END IF;

             --   Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );

END unapply_on_account;


END AR_CM_API_PUB;

/
