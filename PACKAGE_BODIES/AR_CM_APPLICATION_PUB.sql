--------------------------------------------------------
--  DDL for Package Body AR_CM_APPLICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CM_APPLICATION_PUB" AS
/* $Header: ARXPCMAB.pls 120.5.12010000.7 2010/01/08 08:47:23 npanchak ship $           */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

--Start of comments
--API name : Credit Memo Application API
--Type     : Public.
--Function : Apply and unapply credit memos
--Pre-reqs :
--
-- Notes :
--
-- Modification History
-- Date         Name          Description
-- 26-JAN-2005  J Beckett     Created.
-- End of comments

/* =======================================================================
 | Global Data Types
 * ======================================================================*/

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AR_CM_APPLICATION_PUB';

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

PROCEDURE activity_application(
    -- Standard API parameters.
      p_api_version                  IN  NUMBER,
      p_init_msg_list                IN  VARCHAR2,
      p_commit                       IN  VARCHAR2,
      p_validation_level             IN  NUMBER,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
    -- Credit Memo application parameters.
      p_customer_trx_id              IN ra_customer_trx.customer_trx_id%TYPE,
      p_amount_applied               IN ar_receivable_applications.amount_applied%TYPE,
      p_applied_payment_schedule_id  IN ar_payment_schedules.payment_schedule_id%TYPE, --this has no default
      p_receivables_trx_id           IN ar_receivable_applications.receivables_trx_id%TYPE, --this has no default
      p_apply_date                   IN ar_receivable_applications.apply_date%TYPE,
      p_apply_gl_date                IN ar_receivable_applications.gl_date%TYPE,
      p_ussgl_transaction_code       IN ar_receivable_applications.ussgl_transaction_code%TYPE,
      p_attribute_rec                IN attribute_rec_type,
    -- ******* Global Flexfield parameters *******
      p_global_attribute_rec         IN global_attribute_rec_type,
      p_comments                     IN ar_receivable_applications.comments%TYPE,
      p_chk_approval_limit_flag     IN VARCHAR2,
      p_application_ref_type IN OUT NOCOPY
                ar_receivable_applications.application_ref_type%TYPE,
      p_application_ref_id IN OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
      p_application_ref_num IN OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
      p_receivable_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_called_from		    IN VARCHAR2
     ,p_org_id             	IN  NUMBER
     ,p_pay_group_lookup_code	IN  FND_LOOKUPS.lookup_code%TYPE
     ,p_pay_alone_flag		IN  VARCHAR2
     ,p_payment_method_code	IN  ap_invoices.payment_method_code%TYPE
     ,p_payment_reason_code	IN  ap_invoices.payment_reason_code%TYPE
     ,p_payment_reason_comments	IN  ap_invoices.payment_reason_comments%TYPE
     ,p_delivery_channel_code	IN  ap_invoices.delivery_channel_code%TYPE
     ,p_remittance_message1	IN  ap_invoices.remittance_message1%TYPE
     ,p_remittance_message2	IN  ap_invoices.remittance_message2%TYPE
     ,p_remittance_message3	IN  ap_invoices.remittance_message3%TYPE
     ,p_party_id		IN  hz_parties.party_id%TYPE
     ,p_party_site_id		IN  hz_party_sites.party_site_id%TYPE
     ,p_bank_account_id		IN  ar_cash_receipts.customer_bank_account_id%TYPE
     ,p_payment_priority	IN  ap_invoices_interface.PAYMENT_PRIORITY%TYPE		--Bug8290172
     ,p_terms_id		IN  ap_invoices_interface.TERMS_ID%TYPE			--Bug8290172
      )
IS
 l_api_name       CONSTANT VARCHAR2(20) := 'activity_application';
 l_api_version    CONSTANT NUMBER       := 1.0;
 l_customer_trx_id NUMBER;
 l_applied_ps_id   NUMBER;
 l_amount_applied  NUMBER;
 l_cm_unapp_amount  NUMBER;
 l_apply_date      DATE;
 l_apply_gl_date   DATE;
 l_trx_date        DATE;
 l_cm_gl_date      DATE;
 l_return_status      VARCHAR2(1);
 l_def_return_status  VARCHAR2(1);
 l_val_return_status  VARCHAR2(1);
 l_id_conv_return_status  VARCHAR2(1);
 l_cm_currency_code fnd_currencies.currency_code%TYPE;
 l_rec_app_id  NUMBER;
 l_cm_ps_id NUMBER;
 l_cm_receipt_method_id NUMBER;
 l_application_ref_type ar_receivable_applications.application_ref_type%TYPE;
 l_application_ref_id   ar_receivable_applications.application_ref_id%TYPE;
 l_application_ref_num  ar_receivable_applications.application_ref_num%TYPE;
 l_acctd_amount_applied_from  NUMBER;
 l_acctd_amount_applied_to    NUMBER;
 l_msg_count		NUMBER;
 l_msg_data             VARCHAR2(2000);

 l_org_return_status VARCHAR2(1);
 l_org_id                           NUMBER;
 l_party_id hz_parties.party_id%TYPE;
 l_party_name hz_parties.party_name%TYPE;
 l_party_number hz_parties.party_number%TYPE;
 l_party_site_id hz_party_sites.party_site_id%TYPE;
 l_party_address VARCHAR2(360);
 l_payment_method_code iby_payment_methods_vl.payment_method_code%TYPE;
 l_payment_method_name iby_payment_methods_vl.payment_method_name%TYPE;
 l_bank_account_id iby_ext_bank_accounts.ext_bank_account_id%TYPE;
 l_bank_account_num iby_ext_bank_accounts.bank_account_num%TYPE;
 l_payment_reason_code iby_payment_reasons_vl.payment_reason_code%TYPE;
 l_payment_reason_name iby_payment_reasons_vl.meaning%TYPE;
 l_delivery_channel_code iby_delivery_channels_vl.delivery_channel_code%TYPE;
 l_delivery_channel_name iby_delivery_channels_vl.meaning%TYPE;
 l_pay_alone_flag VARCHAR2(1);
 l_legal_entity_id ar_cash_receipts.legal_entity_id%TYPE;
 l_exchange_rate ar_cash_receipts.exchange_rate%TYPE;
 l_exchange_rate_type ar_cash_receipts.exchange_rate_type%TYPE;
 l_exchange_date ar_cash_receipts.exchange_date%TYPE;
 l_invoice_id ap_invoices.invoice_id%TYPE;
 l_dft_ref_return_status  VARCHAR2(1);

  --Bug8290172 Changes Start Here
  l_term_id			ap_invoices_interface.TERMS_ID%TYPE;
  l_pay_term_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_pay_priority_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 --Bug8290172 Changes End Here

BEGIN

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

      SAVEPOINT activity_app_PVT;

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

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('ar_cm_application_pub.activity_application()+ ');
        END IF;

       /*-------------------------------------------------+
        | Initialize SOB/org dependent variables          |
        +-------------------------------------------------*/
        arp_global.init_global;
        arp_standard.init_standard;

       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_org_id            := p_org_id;
        l_org_return_status := FND_API.G_RET_STS_SUCCESS;
        ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                 p_return_status =>l_org_return_status);
        IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

       /*---------------------------------------------+
        |   ========== Start of API Body ==========   |
        +---------------------------------------------*/

     l_customer_trx_id := p_customer_trx_id;
     l_applied_ps_id   := p_applied_payment_schedule_id;
     l_amount_applied  := p_amount_applied;
     l_apply_date      := trunc(p_apply_date);
     l_apply_gl_date   := trunc(p_apply_gl_date);
     l_application_ref_type         := p_application_ref_type;
     l_application_ref_id           := p_application_ref_id;
     l_application_ref_num          := p_application_ref_num;
     l_party_id		:= p_party_id;
     l_party_site_id	:= p_party_site_id;

     ar_cm_app_lib_pvt.default_activity_info
			( p_customer_trx_id => l_customer_trx_id
			, p_cm_ps_id => l_cm_ps_id
			, p_cm_currency_code => l_cm_currency_code
			, p_cm_gl_date => l_cm_gl_date
			, p_cm_unapp_amount => l_cm_unapp_amount
			, p_cm_receipt_method_id => l_cm_receipt_method_id
			, p_trx_date => l_trx_date
			, p_amount_applied => l_amount_applied
			, p_apply_date => l_apply_date
			, p_apply_gl_date => l_apply_gl_date
			, p_return_status => l_def_return_status
			);

     IF p_applied_payment_schedule_id = -8 THEN
         /* Default the refund attributes from IBY */
         ar_receipt_lib_pvt.default_refund_attributes(
            	 p_cash_receipt_id	=>  NULL
            	,p_customer_trx_id	=>  l_customer_trx_id
		,p_currency_code	=>  l_cm_currency_code
		,p_amount		=>  l_amount_applied
		,p_party_id		=>  l_party_id
		,p_party_site_id	=>  l_party_site_id
		,x_party_name		=>  l_party_name
		,x_party_number		=>  l_party_number
		,x_party_address	=>  l_party_address
		,x_exchange_rate	=>  l_exchange_rate
		,x_exchange_rate_type	=>  l_exchange_rate_type
		,x_exchange_date	=>  l_exchange_date
		,x_legal_entity_id	=>  l_legal_entity_id
		,x_payment_method_code	=>  l_payment_method_code
		,x_payment_method_name	=>  l_payment_method_name
		,x_bank_account_id	=>  l_bank_account_id
          	,x_bank_account_num	=>  l_bank_account_num
          	,x_payment_reason_code => l_payment_reason_code
          	,x_payment_reason_name => l_payment_reason_name
          	,x_delivery_channel_code => l_delivery_channel_code
          	,x_delivery_channel_name => l_delivery_channel_name
		,x_pay_alone_flag	=>  l_pay_alone_flag
		,x_return_status	=> l_dft_ref_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data );

         /* If values have been passed in they should be used instead */
         IF p_payment_method_code IS NOT NULL THEN
            l_payment_method_code := p_payment_method_code;
	 ELSIF p_payment_method_code IS NULL AND l_payment_method_code IS NULL THEN/*Bug 8624954*/
            l_payment_method_code := 'CHECK';
	 END IF;
         IF p_bank_account_id IS NOT NULL THEN
            l_bank_account_id := p_bank_account_id;
	 END IF;
         IF p_payment_reason_code IS NOT NULL THEN
            l_payment_reason_code := p_payment_reason_code;
	 END IF;
         IF p_delivery_channel_code IS NOT NULL THEN
            l_delivery_channel_code := p_delivery_channel_code;
	 END IF;
         IF p_pay_alone_flag IS NOT NULL THEN
            l_pay_alone_flag := p_pay_alone_flag;
	 ELSIF l_pay_alone_flag IS NULL AND p_pay_alone_flag IS NULL THEN /*Bug 8624954*/
            l_pay_alone_flag := 'N';
	 END IF;

      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Activity_application: ' || 'Default_activity_info return status :'||l_def_return_status);
         arp_util.debug('Activity_application: ' || 'Default_refund_attributes return status :'||l_dft_ref_return_status);
      END IF;

     ar_cm_app_val_pvt.validate_activity_app
		( p_receivables_trx_id => p_receivables_trx_id,
                  p_applied_ps_id  => l_applied_ps_id,
                  p_customer_trx_id => l_customer_trx_id,
                  p_cm_gl_date  => l_cm_gl_date,
                  p_cm_unapp_amount => l_cm_unapp_amount,
                  p_trx_date => l_trx_date,
                  p_amount_applied => l_amount_applied,
                  p_apply_gl_date => l_apply_gl_date,
                  p_apply_date => l_apply_date,
                  p_cm_currency_code => l_cm_currency_code,
                  p_return_status => l_val_return_status,
                  p_chk_approval_limit_flag => p_chk_approval_limit_flag,
                  p_called_from => p_called_from
                                 );

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Activity_application: ' || 'Validation return status :'||l_val_return_status);
         arp_util.debug('Activity_application: ' || '*****DUMPING ALL THE ENTITY HANDLER PARAMETERS  ***');
         arp_util.debug('Activity_application: ' || 'l_cm_unapp_amount : '||l_cm_unapp_amount);
         arp_util.debug('Activity_application: ' || 'l_amount_applied         : '||to_char(l_amount_applied));
         arp_util.debug('Activity_application: ' || 'l_apply_date             : '||to_char(l_apply_date,'DD-MON-YY'));
         arp_util.debug('Activity_application: ' || 'l_apply_gl_date          : '||to_char(l_apply_gl_date,'DD-MON-YY'));
      END IF;

      -- Bug8290172 Changes Start Here
      -- Validate Payment Term Id
      IF p_terms_id IS NOT NULL THEN
	      BEGIN
		SELECT term_id
		INTO l_term_id
		FROM ap_terms_bat_pay_terms_v
		WHERE term_id = p_terms_id;
	      EXCEPTION
	      WHEN OTHERS THEN
		     l_pay_term_return_status := FND_API.G_RET_STS_ERROR ;

                     FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                     FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Invalid Payment Term');
                     FND_MSG_PUB.Add;

		     IF PG_DEBUG in ('Y', 'C') THEN
			arp_util.debug('Activity_application: ' || 'Invalid Payment Term. Rolling back and setting status to ERROR');
		     END IF;
	      END;
      END IF;

      -- Validate Payment Priority. It Should be between 1 to 99
      IF p_payment_priority IS NOT NULL THEN
      	IF p_payment_priority < 1 OR p_payment_priority > 99 THEN

	     l_pay_priority_return_status := FND_API.G_RET_STS_ERROR ;

	     FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
	     FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Payment Priority Not In Range(1-99)');
	     FND_MSG_PUB.Add;

	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('Activity_application: ' || 'Payment Priority Not In Range(1-99). Rolling back and setting status to ERROR');
	     END IF;
	 END IF;
      END IF;
      -- Bug8290172 Changes End Here

      IF l_val_return_status <> FND_API.G_RET_STS_SUCCESS  OR
         l_def_return_status <> FND_API.G_RET_STS_SUCCESS OR
         l_dft_ref_return_status <> FND_API.G_RET_STS_SUCCESS OR
         l_id_conv_return_status <> FND_API.G_RET_STS_SUCCESS OR
         l_pay_term_return_status <> FND_API.G_RET_STS_SUCCESS OR	-- Bug8290172
         l_pay_priority_return_status <> FND_API.G_RET_STS_SUCCESS THEN	-- Bug8290172

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Activity_application: ' || 'Validation FAILED ');
          END IF;
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN

            ROLLBACK TO Activity_app_PVT;

             x_return_status := FND_API.G_RET_STS_ERROR ;

             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data
                                       );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Activity_application: ' || 'Error(s) occurred. Rolling back and setting status to ERROR');
             END IF;
             Return;
       END IF;

      -- CM payment schedule locked before calling entity handler
      arp_ps_pkg.nowaitlock_p (p_ps_id => l_cm_ps_id);

       --call the entity handler
      BEGIN
        arp_process_application.cm_activity_application     (
	p_cm_ps_id => l_cm_ps_id
      , p_application_ps_id => l_applied_ps_id
      , p_amount_applied => l_amount_applied
      , p_apply_date                =>  l_apply_date
      , p_gl_date                   =>  l_apply_gl_date
      , p_ussgl_transaction_code    =>  p_ussgl_transaction_code
      , p_attribute_category=> p_attribute_rec.attribute_category
      , p_attribute1        => p_attribute_rec.attribute1
      , p_attribute2        => p_attribute_rec.attribute2
      , p_attribute3        => p_attribute_rec.attribute3
      , p_attribute4        => p_attribute_rec.attribute4
      , p_attribute5        => p_attribute_rec.attribute5
      , p_attribute6        => p_attribute_rec.attribute6
      , p_attribute7        => p_attribute_rec.attribute7
      , p_attribute8        => p_attribute_rec.attribute8
      , p_attribute9        => p_attribute_rec.attribute9
      , p_attribute10       => p_attribute_rec.attribute10
      , p_attribute11       => p_attribute_rec.attribute11
      , p_attribute12       => p_attribute_rec.attribute12
      , p_attribute13       => p_attribute_rec.attribute13
      , p_attribute14       => p_attribute_rec.attribute14
      , p_attribute15       => p_attribute_rec.attribute15
      , p_global_attribute_category => p_global_attribute_rec.global_attribute_category
      , p_global_attribute1 => p_global_attribute_rec.global_attribute1
      , p_global_attribute2 => p_global_attribute_rec.global_attribute2
      , p_global_attribute3 => p_global_attribute_rec.global_attribute3
      , p_global_attribute4 => p_global_attribute_rec.global_attribute4
      , p_global_attribute5 => p_global_attribute_rec.global_attribute5
      , p_global_attribute6 => p_global_attribute_rec.global_attribute6
      , p_global_attribute7 => p_global_attribute_rec.global_attribute7
      , p_global_attribute8 => p_global_attribute_rec.global_attribute8
      , p_global_attribute9 => p_global_attribute_rec.global_attribute9
      , p_global_attribute10 => p_global_attribute_rec.global_attribute10
      , p_global_attribute11 => p_global_attribute_rec.global_attribute11
      , p_global_attribute12 => p_global_attribute_rec.global_attribute12
      , p_global_attribute13 => p_global_attribute_rec.global_attribute13
      , p_global_attribute14 => p_global_attribute_rec.global_attribute14
      , p_global_attribute15 => p_global_attribute_rec.global_attribute15
      , p_global_attribute16 => p_global_attribute_rec.global_attribute16
      , p_global_attribute17 => p_global_attribute_rec.global_attribute17
      , p_global_attribute18 => p_global_attribute_rec.global_attribute18
      , p_global_attribute19 => p_global_attribute_rec.global_attribute19
      , p_global_attribute20 => p_global_attribute_rec.global_attribute20
      , p_receivables_trx_id		=> p_receivables_trx_id
      , p_receipt_method_id		=> l_cm_receipt_method_id
      , p_comments			=> p_comments
      , p_module_name			=> 'CMAAPI'
      , p_module_version		=> p_api_version
      , p_application_ref_id         => l_application_ref_id
      , p_application_ref_num       =>  l_application_ref_num
      , p_out_rec_application_id    => l_rec_app_id
        , p_acctd_amount_applied_from => l_acctd_amount_applied_from
        , p_acctd_amount_applied_to => l_acctd_amount_applied_to
      , x_return_status                =>  l_return_status
      , x_msg_count                    =>  l_msg_count
      , x_msg_data                     =>  l_msg_data);
     EXCEPTION
       WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                     ROLLBACK TO Activity_app_PVT;

                      --  Display_Parameters;
                      x_return_status := FND_API.G_RET_STS_ERROR ;
                       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ARP_PROCESS_APPLICATION.CM_ACTIVITY_APPLICATION : '||SQLERRM);
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

     /* Call AP API's to create payment request if refund */
     IF p_applied_payment_schedule_id = -8 THEN
	BEGIN
	  ar_refunds_pvt.create_refund
      		(p_receivable_application_id    =>  l_rec_app_id
		,p_amount			=>  l_amount_applied
		,p_currency_code		=>  l_cm_currency_code
		,p_exchange_rate		=>  l_exchange_rate
		,p_exchange_rate_type		=>  l_exchange_rate_type
		,p_exchange_date		=>  l_exchange_date
		,p_description			=>  NULL
          	,p_pay_group_lookup_code	=>  p_pay_group_lookup_code
          	,p_pay_alone_flag		=>  l_pay_alone_flag
		,p_org_id			=>  l_org_id
	  	,p_legal_entity_id        	=>  l_legal_entity_id
          	,p_payment_method_code		=>  l_payment_method_code
          	,p_payment_reason_code		=>  l_payment_reason_code
          	,p_payment_reason_comments	=>  p_payment_reason_comments
          	,p_delivery_channel_code	=>  l_delivery_channel_code
          	,p_remittance_message1		=>  p_remittance_message1
          	,p_remittance_message2		=>  p_remittance_message2
          	,p_remittance_message3		=>  p_remittance_message3
          	,p_party_id			=>  l_party_id
          	,p_party_site_id		=>  l_party_site_id
                ,p_bank_account_id		=>  l_bank_account_id
		,p_called_from			=>  'CM_APPLICATION_API'
		,x_invoice_id			=>  l_invoice_id
		,x_return_status		=>  x_return_status
		,x_msg_count			=>  x_msg_count
		,x_msg_data			=>  x_msg_data
		,p_payment_priority		=> NVL(p_payment_priority,99)	--Bug8290172  Default 99 of no Payment Proirity is passed
		,p_terms_id			=> p_terms_id		 	--Bug8290172
		,p_invoice_date                 => l_apply_date                 --Bug9258845
		);

   /* 6865230 */
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN

            ROLLBACK TO Activity_app_PVT;

             x_return_status := FND_API.G_RET_STS_ERROR ;

             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data
                                       );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('create_refund: ' || 'Error(s) occurred. Rolling back and setting status to ERROR');
             END IF;
             Return;
       END IF;

       l_application_ref_id := l_invoice_id;
       l_application_ref_num := l_invoice_id;

        EXCEPTION
       WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                     ROLLBACK TO Activity_app_PVT;

                      --  Display_Parameters;
                      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','AR_REFUNDS_PVT.Create_Refund : '||SQLERRM);
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
      END IF;

        p_receivable_application_id   := l_rec_app_id;
        p_application_ref_type := l_application_ref_type;
        p_application_ref_id   := l_application_ref_id;
        p_application_ref_num  := l_application_ref_num;

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Activity_application: ' || 'committing');
            END IF;
              Commit;
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('ar_cm_application_pub.Activity_application()- ');
        END IF;
EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Activity_application: ' || SQLCODE, G_MSG_ERROR);
                   arp_util.debug('Activity_application: ' || SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO Activity_app_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

               -- Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Activity_application: ' || SQLERRM, G_MSG_ERROR);
                END IF;
                ROLLBACK TO Activity_app_PVT;
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

                      ROLLBACK TO Activity_app_PVT;

                      --If only one error message on the stack,
                      --retrive it

                      x_return_status := FND_API.G_RET_STS_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ACTIVITY_APPLICATION : '||SQLERRM);
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
                     FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ACTIVITY_APPLICATION : '||SQLERRM);
                     FND_MSG_PUB.Add;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Activity_application: ' || SQLCODE, G_MSG_ERROR);
                   arp_util.debug('Activity_application: ' || SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO Activity_app_PVT;

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
END Activity_application;


PROCEDURE Activity_unapplication(
    -- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2,
      p_commit           IN  VARCHAR2,
      p_validation_level IN  NUMBER,
      x_return_status    OUT NOCOPY VARCHAR2 ,
      x_msg_count        OUT NOCOPY NUMBER ,
      x_msg_data         OUT NOCOPY VARCHAR2 ,
   -- *** Credit Memo Info. parameters *****
      p_customer_trx_id  IN ra_customer_trx.customer_trx_id%TYPE,
      p_receivable_application_id   IN ar_receivable_applications.receivable_application_id%TYPE,
      p_reversal_gl_date IN ar_receivable_applications.reversal_gl_date%TYPE,
      p_called_from      IN VARCHAR2,
      p_org_id		 IN NUMBER
      ) IS
l_api_name       CONSTANT VARCHAR2(20) := 'Activity_unapp';
l_api_version    CONSTANT NUMBER       := 1.0;
l_customer_trx_id               NUMBER;
l_receivable_application_id     NUMBER;
l_cm_gl_date                    DATE;
l_reversal_gl_date              DATE;
l_apply_gl_date                 DATE;
l_receipt_gl_date               DATE;
l_id_return_status              VARCHAR2(1);
l_def_return_status             VARCHAR2(1);
l_val_return_status             VARCHAR2(1);
l_cm_unapp_amt                  NUMBER;
l_cm_ps_id                      NUMBER;
l_org_id			NUMBER;
l_org_return_status		VARCHAR2(1);
l_refund_return_status		VARCHAR2(1);
l_applied_ps_id			ar_payment_schedules.payment_schedule_id%TYPE;
l_application_ref_id		ar_receivable_applications.application_ref_id%TYPE;

BEGIN
       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

        SAVEPOINT Activity_unapplication_PVT;

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

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('ar_cm_application_pub.activity_unapplication()+ ');
        END IF;

       /*-------------------------------------------------+
        | Initialize SOB/org dependent variables          |
        +-------------------------------------------------*/
        arp_global.init_global;
        arp_standard.init_standard;

       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_org_id            := p_org_id;
        l_org_return_status := FND_API.G_RET_STS_SUCCESS;
        ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                 p_return_status =>l_org_return_status);
        IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;
       /*---------------------------------------------+
        |   ========== Start of API Body ==========   |
        +---------------------------------------------*/


        --Assign IN parameter values to local variables
        --which are also used as assignment targets.

         l_customer_trx_id   := p_customer_trx_id;
         l_receivable_application_id  := p_receivable_application_id;
         l_reversal_gl_date := trunc(p_reversal_gl_date);


        /*------------------------------------------------+
         |  Derive the IDs for the entered values.        |
         |  If both the values and the IDs are specified, |
         |  the IDs supercede the values                  |
         +------------------------------------------------*/

         ar_cm_app_lib_pvt.derive_activity_unapp_ids(
                         NULL   ,
                         l_customer_trx_id  ,
                         l_receivable_application_id ,
                         l_apply_gl_date     ,
                         l_id_return_status
                               );
         ar_cm_app_lib_pvt.default_unapp_activity_info(
                         l_receivable_application_id ,
                         l_apply_gl_date            ,
                         l_customer_trx_id          ,
                         l_reversal_gl_date         ,
                         l_cm_gl_date,
			 l_cm_ps_id,
                         l_cm_unapp_amt,
			 l_def_return_status
                          );

         ar_cm_app_val_pvt.validate_unapp_activity(
                                      l_cm_gl_date,
                                      l_receivable_application_id,
                                      l_reversal_gl_date,
                                      l_apply_gl_date,
                                      l_cm_unapp_amt,
                                      l_val_return_status);

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Activity_Unapplication: ' || 'validation return status :'||l_val_return_status);
         END IF;

	/* Refunds - check for refund and cancel if refund application */
        SELECT applied_payment_schedule_id, application_ref_id
	INTO   l_applied_ps_id, l_application_ref_id
	FROM   ar_receivable_applications
  	WHERE  receivable_application_id = l_receivable_application_id;

        IF (l_applied_ps_id = -8 AND p_called_from <> 'AR_REFUNDS_GRP') THEN
           ar_refunds_pvt.cancel_refund(
		  p_application_ref_id  => l_application_ref_id
		, p_gl_date		=> l_reversal_gl_date
		, x_return_status	=> l_refund_return_status
		, x_msg_count		=> x_msg_count
		, x_msg_data		=> x_msg_data);
        END IF;

        IF l_val_return_status <> FND_API.G_RET_STS_SUCCESS OR
           l_id_return_status <> FND_API.G_RET_STS_SUCCESS  OR
	   l_refund_return_status <> FND_API.G_RET_STS_SUCCESS  OR
           l_def_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN

            ROLLBACK TO Activity_unapplication_PVT;

             x_return_status := FND_API.G_RET_STS_ERROR ;

             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data
                                       );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Activity_Unapplication: ' || 'Error(s) occurred. Rolling back and setting status to ERROR');
             END IF;
             Return;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Activity_Unapplication: ' || '*******DUMP THE INPUT PARAMETERS ********');
           arp_util.debug('Activity_Unapplication: ' || 'l_receivable_application_id :'||to_char(l_receivable_application_id));
           arp_util.debug('Activity_Unapplication: ' || 'l_reversal_gl_date :'||to_char(l_reversal_gl_date,'DD-MON-YY'));
        END IF;

        -- CM payment schedule locked before calling entity handler
        arp_ps_pkg.nowaitlock_p (p_ps_id => l_cm_ps_id);

        --call the entity handler.
      BEGIN
          arp_process_application.reverse_cm_app(
                                l_receivable_application_id,
                                -8,
                                l_reversal_gl_date,
                                trunc(sysdate),
                                'CMAAPI',
                                p_api_version,
				p_called_from);
      EXCEPTION
        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                     ROLLBACK TO Activity_unapplication_PVT;

                      --  Display_Parameters;
                      x_return_status := FND_API.G_RET_STS_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ARP_PROCESS_APPLICATION.REVERSE : '||SQLERRM);
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
               arp_util.debug('Activity_Unapplication: ' || 'committing');
            END IF;
              Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('ar_cm_application_pub.Activity_unapplication()- ');
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Activity_Unapplication: ' || SQLCODE, G_MSG_ERROR);
                   arp_util.debug('Activity_Unapplication: ' || SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO Activity_unapplication_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

              --  Display_Parameters;

                FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                           p_count       =>      x_msg_count,
                                           p_data        =>      x_msg_data
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Activity_Unapplication: ' || SQLERRM, G_MSG_ERROR);
                END IF;
                ROLLBACK TO Activity_unapplication_PVT;
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

                      ROLLBACK TO Activity_unapplication_PVT;

                      x_return_status := FND_API.G_RET_STS_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ACTIVITY_UNAPPLICATION : '||SQLERRM);
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
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ACTIVITY_UNAPPLICATION : '||SQLERRM);
                      FND_MSG_PUB.Add;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Activity_Unapplication: ' || SQLCODE, G_MSG_ERROR);
                   arp_util.debug('Activity_Unapplication: ' || SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO Activity_unapplication_PVT;

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
END Activity_unapplication;

END AR_CM_APPLICATION_PUB;

/
