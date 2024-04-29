--------------------------------------------------------
--  DDL for Package Body AR_OM_PREPAY_REFUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_OM_PREPAY_REFUND_PVT" AS
/* $Header: AROMRFNB.pls 115.3 2004/05/03 19:49:26 jypandey noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'AR_OM_PREPAY_REFUND_PVT';
G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

 PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/
/*=======================================================================
 | PUBLIC Procedure refund_prepayment_wrapper
 |
 | DESCRIPTION
 |      This wrapper is same as ar_prepayments except this accepts 1 additional
 |      parameter p_bank_account_id  : This paramter along with p_receipt_method_id
 |       if having a value populate the global  variables in
 |       AR_PREPAYMENTS.Refund_Prepayment
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
 | Aug-13-2003         Jyoti Pandey    Created
 | May-03-2004         Jyoti Pandey    Bug:3605509 Global variables for
 |                                     receipt methos and bank account ID
 |                                     not getting defaulted properly.
 *=======================================================================*/
 PROCEDURE Refund_Prepayment_Wrapper(
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
    -------Multiple prepayments projecti Additional parameter for credit card
    -------refunds to be populated as global variables
      p_bank_account_id   IN NUMBER,
      p_receipt_method_id IN NUMBER,

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

BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('AR_OM_PREPAY_REFUND_PVT.refund_prepayment_wrapper ()+');
      END IF;

      -- first reinitialize ARP_GLOBAL
        arp_global.init_global;


      /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;


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
        arp_global.init_global;
        arp_standard.init_standard;


       -----------------------------------------------+
       -- Multiple Prepay project, Check if p_receipt_method_id and p_bank_account_id
       -- are passed. If one is passed then other must be passed to. This is the
       -- desired by the OM for Credit card refunds to a particular Credit card
       -- based on the receipt method



       if p_bank_account_id is not NULL then

          --make sure the receipt_method_id is passed
          if p_receipt_method_id is NULL then
             FND_MESSAGE.SET_NAME('AR','AR_MAND_PARAMETER_NULL');
             FND_MESSAGE.SET_TOKEN('PARAM','p_receipt_method_id');
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
          end if;

         --make sure the payment_set_id is passed
          if p_payment_set_id is NULL then
             FND_MESSAGE.SET_NAME('AR','AR_MAND_PARAMETER_NULL');
             FND_MESSAGE.SET_TOKEN('PARAM','p_payment_set_id');
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
          end if;

       end if;

        ---Bug 3605509 The global variables for Prepayments API should
        --- be initialized even if the passed parameters p_receipt_method_id
        --- and p_bank_account_id are null

         AR_PREPAYMENTS.G_REFUND_RECEIPT_METHOD_ID := p_receipt_method_id;
         AR_PREPAYMENTS.G_REFUND_BANK_ACCOUNT_ID   := p_bank_account_id;


        ---Make a callout the AR_PREPAYMENTS.REFUND_PREPYMENTS
       AR_PREPAYMENTS.Refund_Prepayments(
        -- Standard API parameters.
           p_api_version    ,
           p_init_msg_list  ,
           p_commit         ,
           p_validation_level ,
           x_return_status ,
           x_msg_count     ,
           x_msg_data      ,
           p_prepay_application_id ,
           p_number_of_refund_receipts ,
           p_receipt_number            ,
           p_cash_receipt_id           ,
           p_receivable_application_id ,
           p_receivables_trx_id        ,
           p_refund_amount             ,
           p_refund_date               ,
           p_refund_gl_date            ,
           p_ussgl_transaction_code    ,
           p_attribute_rec             ,
         -- ******* Global Flexfield parameters *******
           p_global_attribute_rec      ,
           p_comments                  ,
           p_payment_set_id            );



        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('ar_prepayments_pub.Create_Prepayment ()-');
            END IF;

EXCEPTION
WHEN OTHERS THEN
   IF (SQLCODE = -20001) THEN
       ROLLBACK TO Create_Prepayment_PVT;

       --  Display_Parameters;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','REFUND_PREPAYMENTS : '||SQLERRM);
       FND_MSG_PUB.Add;

       FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                  p_count  =>  x_msg_count,
                                  p_data   => x_msg_data
                                                );
       RETURN;
   ELSE
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','REFUND_PREPAYMENTS : '||SQLERRM);
         FND_MSG_PUB.Add;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('REFUND_PREPAYMENTS: ' || SQLCODE, G_MSG_ERROR);
      arp_util.debug('REFUND_PREPAYMENTS: ' || SQLERRM, G_MSG_ERROR);
   END IF;




    --   Display_Parameters;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count       =>      x_msg_count,
                              p_data        =>      x_msg_data);


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('AR_OM_PREPAY_REFUND_PVT.refund_prepayment_wrapper ()-');
    END IF;

END Refund_Prepayment_Wrapper;

END AR_OM_PREPAY_REFUND_PVT;

/
