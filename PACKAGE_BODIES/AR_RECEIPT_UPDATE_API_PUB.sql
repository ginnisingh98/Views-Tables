--------------------------------------------------------
--  DDL for Package Body AR_RECEIPT_UPDATE_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RECEIPT_UPDATE_API_PUB" AS
/* $Header: ARXPREUB.pls 120.7.12010000.4 2010/06/16 10:31:38 npanchak ship $           */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
/* =======================================================================
 | Global Data Types
 * ======================================================================*/

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AR_RECEIPT_UPDATE_API_PUB';

--- Start Validate

PROCEDURE  Validate_id(p_customer_id        IN NUMBER,
              p_cash_receipt_id    IN NUMBER,
	      p_payment_trxn_extension_id  IN NUMBER,
	      p_customer_bank_account_id    IN NUMBER,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2,
              x_return_status      OUT NOCOPY VARCHAR2,
	      x_crv_rec	           OUT NOCOPY ar_cash_receipts_v%ROWTYPE
	      )
	    IS


 l_crv_rec ar_cash_receipts_v%ROWTYPE;
 l_payment_trxn_extension_id        ar_cash_receipts.payment_trxn_extension_id%TYPE;
 l_creation_method_code             ar_receipt_classes.creation_method_code%TYPE;
 l_cash_receipt_id   NUMBER	   := p_cash_receipt_id;
 l_customer_id       NUMBER	   := p_customer_id;
 l_customer_bank_account_id NUMBER := p_customer_bank_account_id;
 l_bank_chk          NUMBER        := 0;

  --- For site use id -----
CURSOR c_default_location IS
      SELECT
             site.site_use_id,
             site.location
      FROM
             hz_cust_site_uses site,
             hz_cust_acct_sites acct_site
      WHERE
             acct_site.cust_account_id   =  l_customer_id
        AND  acct_site.status        = 'A'
        AND  site.cust_acct_site_id    = acct_site.cust_acct_site_id
        AND  site.site_use_code = 'BILL_TO'
        AND  site.status        = 'A'
        AND  site.primary_flag  = 'Y';

	l_location		  	VARCHAR2(40) := NULL;
        l_customer_site_use_id  	NUMBER;
	l_valid                         NUMBER;

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

	arp_util.debug('EXCEPTION: Validate_id()+ ');

	--- Cash receipt validation

        begin

	      IF l_cash_receipt_id is NUll THEN
	        arp_standard.debug('Null Cash_receipt_id passed .');

		FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_NULL');
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);
                return;

	      ELSE

		SELECT count(*)
		INTO   l_valid
		FROM AR_CASH_RECEIPTS_V
		WHERE cash_receipt_id = p_cash_receipt_id;

		IF l_valid = 0 THEN
		          arp_standard.debug('Invlaid Cash_receipt_id passed .');
			 FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_INVALID');
			 FND_MSG_PUB.Add;
			 x_return_status := FND_API.G_RET_STS_ERROR;
			 FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);
                         return;
                END IF;


	      END IF;

	        SELECT * INTO l_crv_rec
		FROM AR_CASH_RECEIPTS_V
		WHERE cash_receipt_id = p_cash_receipt_id;

		x_crv_rec := l_crv_rec;

        Exception
	   When others then
	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('EXCEPTION: Validate_cash_receipt_id() ');
	     END IF;
	     raise;
        End; --- Cash receipt validation END




	------------------------- Getting the site use id ------------------------
      OPEN  c_default_location;
      FETCH c_default_location INTO
  		l_customer_site_use_id,
  		l_location;
      CLOSE c_default_location;

      ------------------------- Getting the site use id END --------------------

      IF l_customer_site_use_id IS NULL
      AND arp_global.sysparam.site_required_flag = 'Y'  THEN

			 FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_STE_USE_ID_NOT_DEF');
			 FND_MSG_PUB.Add;
			 x_return_status := FND_API.G_RET_STS_ERROR;
			 FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);
                         return;

      END IF;

      --x_crv_rec.customer_site_use_id := l_customer_site_use_id;


      ----- Checking Receipt Status

      IF l_crv_rec.receipt_status <> 'UNID' THEN
         arp_standard.debug('Receipt Status is not UNID.');
	 x_return_status := FND_API.G_RET_STS_ERROR ;
		       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Only receipt with Status UNID can be updated');
                       FND_MSG_PUB.Add;

                       FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                                  p_count  =>  x_msg_count,
                                                  p_data   => x_msg_data
                                                );
                       return;

      END IF;


       ----- Checking Receipt Status  END


      -- Validating payemnt Ext id


        l_creation_method_code            := l_crv_rec.CREATION_METHOD_CODE;
	l_payment_trxn_extension_id       := p_payment_trxn_extension_id;


	IF ( l_creation_method_code = 'AUTOMATIC' and l_payment_trxn_extension_id is NULL) THEN

               arp_standard.debug('payment_trxn_extension_id is null for Automatic receipt');
               x_return_status := FND_API.G_RET_STS_ERROR ;

              FND_MESSAGE.SET_NAME('AR','AR_CC_AUTH_FAILED');
              FND_MSG_PUB.Add;

	       FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                                  p_count  =>  x_msg_count,
                                                  p_data   => x_msg_data
                                                );
                       return;

        END IF;

	IF ( l_creation_method_code <> 'AUTOMATIC' and l_payment_trxn_extension_id is NOT NULL) THEN

               arp_standard.debug('payment_trxn_extension_id is not null for Manual receipt');
               x_return_status := FND_API.G_RET_STS_ERROR ;

              FND_MESSAGE.SET_NAME('AR','AR_CC_AUTH_FAILED');
              FND_MSG_PUB.Add;

	       FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                                  p_count  =>  x_msg_count,
                                                  p_data   => x_msg_data
                                                );
                       return;

        END IF;

	-- Validating payemnt Ext id END

	-- Validating Bank Account Id


	IF ( l_creation_method_code = 'AUTOMATIC' and l_customer_bank_account_id is NOT NULL) THEN

               arp_standard.debug('Customer Bank id is not required for Automatic receipt');
	       arp_standard.debug('Ignoring Customer Bank Id');
               l_customer_bank_account_id := NULL;
        END IF;

	IF ( l_creation_method_code <> 'AUTOMATIC' and l_customer_bank_account_id is NOT NULL) THEN


	      begin
		select 1 INTO l_bank_chk
		from iby_fndcpt_payer_assgn_instr_v a,
		       iby_ext_bank_accounts_v bb
		where a.cust_account_id = l_customer_id
		and a.instrument_type = 'BANKACCOUNT'
		and ( a.acct_site_use_id = l_customer_site_use_id or a.acct_site_use_id is null)
		and a.currency_code = l_crv_rec.CURRENCY_CODE
		and bb.ext_bank_account_id = a.instrument_id
		and bb.ext_bank_account_id = l_customer_bank_account_id;
             exception
	         when no_data_found then
		    l_bank_chk := 0;
                 when too_many_rows then
		    l_bank_chk := 1;
                 when others then
		    l_bank_chk := -1;
	     end;

		IF NVL(l_bank_chk,0) = 0 THEN

		      arp_standard.debug('Bank id is incorrect for provided customer details');
		      x_return_status := FND_API.G_RET_STS_ERROR ;

		      FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_ID_INVALID');
		      FND_MSG_PUB.Add;

		      FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
							  p_count  =>  x_msg_count,
							  p_data   => x_msg_data
							);
		      return;
                 ELSIF NVL(l_bank_chk,0) = -1 THEN
		      arp_standard.debug('Unknown error occur for bank details');
		      x_return_status := FND_API.G_RET_STS_ERROR ;

		       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Unknown error occur for bank details');
                       FND_MSG_PUB.Add;
                END IF;

        END IF;

	-- Validating Bank Account Id END

        x_crv_rec.customer_site_use_id     := l_customer_site_use_id;
	x_crv_rec.customer_bank_account_id := l_customer_bank_account_id;

	arp_util.debug('EXCEPTION: Validate_id() - ');


EXCEPTION

  WHEN OTHERS THEN
        IF c_default_location%ISOPEN THEN     CLOSE c_default_location;   END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('EXCEPTION: Validate_id() ');
	END IF;
	     raise;

END  Validate_id;

--- End   Validate

	PROCEDURE update_receipt_unid_to_unapp (
-- Standard API parameters.
                 p_api_version       IN  NUMBER,
                 p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                 p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 x_return_status     OUT NOCOPY VARCHAR2,
                 x_msg_count         OUT NOCOPY NUMBER,
                 x_msg_data          OUT NOCOPY VARCHAR2,
-- Receipt info. parameters
                 p_cash_receipt_id   IN NUMBER,
		 p_pay_from_customer IN NUMBER,
		 p_comments          IN VARCHAR2 DEFAULT NULL,
		 p_payment_trxn_extension_id  IN NUMBER DEFAULT NULL,
		 x_status	     OUT NOCOPY VARCHAR2,
 		 p_customer_bank_account_id    IN NUMBER DEFAULT NULL
		 )
IS

l_api_name       CONSTANT VARCHAR2(50) := 'update_receipt_unid_to_unapp';
l_api_version    CONSTANT NUMBER       := 1.0;

l_crv_rec ar_cash_receipts_v%ROWTYPE;
l_payment_trxn_extension_id        ar_cash_receipts.payment_trxn_extension_id%TYPE;
l_creation_method_code             ar_receipt_classes.creation_method_code%TYPE;

l_cash_receipt_id   NUMBER	  := p_cash_receipt_id;
l_customer_id       NUMBER	  := p_pay_from_customer;
l_customer_bank_account_id NUMBER := p_customer_bank_account_id;
l_org_return_status VARCHAR2(1);
l_org_id            NUMBER;


 -- OUT PARAMETER FOR UPDATE CALL --
 x_NEW_STATE VARCHAR2(255);
 x_NEW_STATE_DSP VARCHAR2(255);
 X_NEW_STATUS VARCHAR2(255);
 X_NEW_STATUS_DSP VARCHAR2(255);
 x_dm_number  VARCHAR2(255);
 x_tw_Status VARCHAR2(255);

-- Create payment_trxn_extension_id
l_create_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_create_msg_count     NUMBER;
l_create_msg_data      VARCHAR2(2000);
l_create_pmt_trxn_extension_id        ar_cash_receipts.payment_trxn_extension_id%TYPE;
l_valid_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_valid_msg_count     NUMBER;
l_valid_msg_data      VARCHAR2(2000);



BEGIN

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

      SAVEPOINT Create_cash_PVT;

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
            arp_standard.debug('ar_receipt_update_api_pub.update_receipt_unid_to_unapp()+');
        END IF;
       /*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        x_return_status := FND_API.G_RET_STS_SUCCESS;

	 /*-----------------------------------------+
        |   Initialize ORG ID			   |
        +-----------------------------------------*/

       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);

       IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       l_payment_trxn_extension_id  := p_payment_trxn_extension_id;

	-- Package body start --

	Validate_id(p_customer_id		=> l_customer_id,
              p_cash_receipt_id			=> l_cash_receipt_id,
	      p_payment_trxn_extension_id	=> l_payment_trxn_extension_id,
	      p_customer_bank_account_id        => l_customer_bank_account_id,
              x_msg_count			=> l_valid_msg_count,
              x_msg_data			=> l_valid_msg_data,
              x_return_status			=> l_valid_return_status,
	      x_crv_rec				=> l_crv_rec
            );







IF l_valid_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   arp_standard.debug('Validation of input parametrs fails ' );
   arp_standard.debug('Customer ID :  '||l_customer_id);
   arp_standard.debug('Cash Receipt ID :  '||l_cash_receipt_id);
   arp_standard.debug('Payment trxn extension id : '||l_payment_trxn_extension_id);
   x_return_status := FND_API.G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                                  p_count  =>  x_msg_count,
                                                  p_data   => x_msg_data
                                                );
   return;

ELSE

   IF l_crv_rec.creation_method_code = 'AUTOMATIC'  THEN
    arp_standard.debug('calling CREATE  Extension....');
    AR_RECEIPT_API_PUB.Create_payment_extension (
       p_payment_trxn_extension_id	=> l_payment_trxn_extension_id,
       p_customer_id			=> l_customer_id,
       p_receipt_method_id		=> l_crv_rec.receipt_method_id,
       p_org_id				=> l_org_id,
       p_customer_site_use_id		=> l_crv_rec.customer_site_use_id,
       p_cash_receipt_id		=> l_cash_receipt_id,
       p_receipt_number			=> l_crv_rec.receipt_number,
       x_msg_count			=> l_create_msg_count,
       x_msg_data			=> l_create_msg_data,
       x_return_status			=> l_create_return_status,
       o_payment_trxn_extension_id	=> l_create_pmt_trxn_extension_id
	 );

	 IF l_create_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
              arp_standard.debug('update_receipt_unid_to_unapp: Payment_trxn_extension_id creation fails ' );
	      FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
	      FND_MSG_PUB.Add;
	      x_return_status := FND_API.G_RET_STS_ERROR ;
	      FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                                  p_count  =>  x_msg_count,
                                                  p_data   => x_msg_data
                                                );
                       return;
	 END IF;

	 l_payment_trxn_extension_id := l_create_pmt_trxn_extension_id;

	  IF l_payment_trxn_extension_id IS NULL THEN
                       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Unable to create Payment_trxn_extension_id');
                       FND_MSG_PUB.Add;
		       x_return_status := FND_API.G_RET_STS_ERROR ;
                       FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                                  p_count  =>  x_msg_count,
                                                  p_data   => x_msg_data
                                                );
                       return;
          END IF;

     END IF;

  END IF;



 ------------------------- payment_trxn_extension_id  END ------------------------


       --- Calling procedure to update the Receipt ------


ARP_PROC_RECEIPTS1.UPDATE_CASH_RECEIPT(
    P_CASH_RECEIPT_ID	=> l_cash_receipt_id,
    P_STATUS		=> l_crv_rec.STATE,
    P_CURRENCY_CODE	=> l_crv_rec.CURRENCY_CODE,
    P_AMOUNT		=> l_crv_rec.AMOUNT,
    P_PAY_FROM_CUSTOMER => l_customer_id,
    P_RECEIPT_NUMBER	=> l_crv_rec.RECEIPT_NUMBER,
    P_RECEIPT_DATE	=> l_crv_rec.RECEIPT_DATE,
    P_GL_DATE		=> l_crv_rec.GL_DATE,
    P_MATURITY_DATE	=> l_crv_rec.MATURITY_DATE,
    P_COMMENTS		=> p_comments,
    P_EXCHANGE_RATE_TYPE => l_crv_rec.EXCHANGE_RATE_TYPE,
    P_EXCHANGE_RATE	=> l_crv_rec.EXCHANGE_RATE,
    P_EXCHANGE_DATE	=> l_crv_rec.EXCHANGE_RATE_DATE,
    P_ATTRIBUTE_CATEGORY => l_crv_rec.ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1	=> l_crv_rec.ATTRIBUTE1,
    P_ATTRIBUTE2	=> l_crv_rec.ATTRIBUTE2,
    P_ATTRIBUTE3	=> l_crv_rec.ATTRIBUTE3,
    P_ATTRIBUTE4	=> l_crv_rec.ATTRIBUTE4,
    P_ATTRIBUTE5	=> l_crv_rec.ATTRIBUTE5,
    P_ATTRIBUTE6	=> l_crv_rec.ATTRIBUTE6,
    P_ATTRIBUTE7	=> l_crv_rec.ATTRIBUTE7,
    P_ATTRIBUTE8	=> l_crv_rec.ATTRIBUTE8,
    P_ATTRIBUTE9	=> l_crv_rec.ATTRIBUTE9,
    P_ATTRIBUTE10	=> l_crv_rec.ATTRIBUTE10,
    P_ATTRIBUTE11	=> l_crv_rec.ATTRIBUTE11,
    P_ATTRIBUTE12	=> l_crv_rec.ATTRIBUTE12,
    P_ATTRIBUTE13	=> l_crv_rec.ATTRIBUTE13,
    P_ATTRIBUTE14	=> l_crv_rec.ATTRIBUTE14,
    P_ATTRIBUTE15	=> l_crv_rec.ATTRIBUTE15,
    P_OVERRIDE_REMIT_ACCOUNT_FLAG	=> l_crv_rec.OVERRIDE_REMIT_BANK,
    P_REMITTANCE_BANK_ACCOUNT_ID	=> l_crv_rec.REMIT_BANK_ACCT_USE_ID,
    P_CUSTOMER_BANK_ACCOUNT_ID		=> l_crv_rec.CUSTOMER_BANK_ACCOUNT_ID,
    P_CUSTOMER_SITE_USE_ID		=> l_crv_rec.customer_site_use_id,
    P_CUSTOMER_RECEIPT_REFERENCE	=> l_crv_rec.CUSTOMER_RECEIPT_REFERENCE,
    P_FACTOR_DISCOUNT_AMOUNT		=> l_crv_rec.FACTOR_DISCOUNT_AMOUNT,
    P_DEPOSIT_DATE		=> l_crv_rec.DEPOSIT_DATE,
    P_RECEIPT_METHOD_ID		=> l_crv_rec.RECEIPT_METHOD_ID,
    P_DOC_SEQUENCE_VALUE	=> l_crv_rec.DOCUMENT_NUMBER,
    P_DOC_SEQUENCE_ID		=> l_crv_rec.DOC_SEQUENCE_ID,
    P_USSGL_TRANSACTION_CODE	=> l_crv_rec.USSGL_TRANSACTION_CODE,
    P_VAT_TAX_ID	=> l_crv_rec.VAT_TAX_ID,
    P_CONFIRM_DATE	=> null,
    P_CONFIRM_GL_DATE	=> null,
    P_UNCONFIRM_GL_DATE => NULL,
    P_POSTMARK_DATE	=> NULL,
    P_RATE_ADJUST_GL_DATE => null,
    P_NEW_EXCHANGE_DATE	=> null,
    P_NEW_EXCHANGE_RATE => null,
    P_NEW_EXCHANGE_RATE_TYPE => null,
    P_GAIN_LOSS		=> null,
    P_EXCHANGE_RATE_ATTR_CAT => null,
    P_EXCHANGE_RATE_ATTR1 => null,
    P_EXCHANGE_RATE_ATTR2 => null,
    P_EXCHANGE_RATE_ATTR3 => null,
    P_EXCHANGE_RATE_ATTR4 => null,
    P_EXCHANGE_RATE_ATTR5 => null,
    P_EXCHANGE_RATE_ATTR6 => null,
    P_EXCHANGE_RATE_ATTR7 => null,
    P_EXCHANGE_RATE_ATTR8 => null,
    P_EXCHANGE_RATE_ATTR9 => null,
    P_EXCHANGE_RATE_ATTR10 => null,
    P_EXCHANGE_RATE_ATTR11 => null,
    P_EXCHANGE_RATE_ATTR12 => null,
    P_EXCHANGE_RATE_ATTR13 => null,
    P_EXCHANGE_RATE_ATTR14 => null,
    P_EXCHANGE_RATE_ATTR15 => null,
    P_REVERSAL_DATE	=> null,
    P_REVERSAL_GL_DATE	=> null,
    P_REVERSAL_CATEGORY => null,
    P_REVERSAL_COMMENTS => null,
    P_REVERSAL_REASON_CODE => null,
    P_DM_REVERSAL_FLAG	=> null,
    P_DM_CUST_TRX_TYPE_ID => null,
    P_DM_CUST_TRX_TYPE	=> null,
    P_CC_ID		=> null,
    P_DM_NUMBER		=> x_dm_number,
    P_DM_DOC_SEQUENCE_VALUE => null,
    P_DM_DOC_SEQUENCE_ID => null,
    P_TW_STATUS		=> x_tw_Status,
    P_ANTICIPATED_CLEARING_DATE => l_crv_rec.ANTICIPATED_CLEARING_DATE,
    P_CUSTOMER_BANK_BRANCH_ID	=> l_crv_rec.CUSTOMER_BANK_BRANCH_ID,
    P_GLOBAL_ATTRIBUTE1 => l_crv_rec.GLOBAL_ATTRIBUTE1,
    P_GLOBAL_ATTRIBUTE2 => l_crv_rec.GLOBAL_ATTRIBUTE2,
    P_GLOBAL_ATTRIBUTE3 => l_crv_rec.GLOBAL_ATTRIBUTE3,
    P_GLOBAL_ATTRIBUTE4 => l_crv_rec.GLOBAL_ATTRIBUTE4,
    P_GLOBAL_ATTRIBUTE5 => l_crv_rec.GLOBAL_ATTRIBUTE5,
    P_GLOBAL_ATTRIBUTE6 => l_crv_rec.GLOBAL_ATTRIBUTE6,
    P_GLOBAL_ATTRIBUTE7 => l_crv_rec.GLOBAL_ATTRIBUTE7,
    P_GLOBAL_ATTRIBUTE8 => l_crv_rec.GLOBAL_ATTRIBUTE8,
    P_GLOBAL_ATTRIBUTE9 => l_crv_rec.GLOBAL_ATTRIBUTE9,
    P_GLOBAL_ATTRIBUTE10 => l_crv_rec.GLOBAL_ATTRIBUTE10,
    P_GLOBAL_ATTRIBUTE11 => l_crv_rec.GLOBAL_ATTRIBUTE11,
    P_GLOBAL_ATTRIBUTE12 => l_crv_rec.GLOBAL_ATTRIBUTE12,
    P_GLOBAL_ATTRIBUTE13 => l_crv_rec.GLOBAL_ATTRIBUTE13,
    P_GLOBAL_ATTRIBUTE14 => l_crv_rec.GLOBAL_ATTRIBUTE14,
    P_GLOBAL_ATTRIBUTE15 => l_crv_rec.GLOBAL_ATTRIBUTE15,
    P_GLOBAL_ATTRIBUTE16 => l_crv_rec.GLOBAL_ATTRIBUTE16,
    P_GLOBAL_ATTRIBUTE17 => l_crv_rec.GLOBAL_ATTRIBUTE17,
    P_GLOBAL_ATTRIBUTE18 => l_crv_rec.GLOBAL_ATTRIBUTE18,
    P_GLOBAL_ATTRIBUTE19 => l_crv_rec.GLOBAL_ATTRIBUTE19,
    P_GLOBAL_ATTRIBUTE20 => l_crv_rec.GLOBAL_ATTRIBUTE20,
    P_GLOBAL_ATTRIBUTE_CATEGORY		=> l_crv_rec.GLOBAL_ATTRIBUTE_CATEGORY,
    P_ISSUER_NAME	=> l_crv_rec.ISSUER_NAME,
    P_ISSUE_DATE	=> l_crv_rec.ISSUE_DATE,
    P_ISSUER_BANK_BRANCH_ID		=> l_crv_rec.ISSUER_BANK_BRANCH_ID,
    P_APPLICATION_NOTES			=> l_crv_rec.APPLICATION_NOTES,
    P_NEW_STATE		=> x_NEW_STATE,
    P_NEW_STATE_DSP	=> x_NEW_STATE_DSP,
    P_NEW_STATUS	=> X_NEW_STATUS,
    P_NEW_STATUS_DSP	=> X_NEW_STATUS_DSP,
    P_FORM_NAME		=> null,
    P_FORM_VERSION	=> null,
    P_PAYMENT_SERVER_ORDER_NUM	=> l_crv_rec.PAYMENT_SERVER_ORDER_NUM,
    P_APPROVAL_CODE	=> l_crv_rec.APPROVAL_CODE,
    P_LEGAL_ENTITY_ID	=> l_crv_rec.LEGAL_ENTITY_ID,
    P_PAYMENT_TRXN_EXTENSION_ID	=> l_payment_trxn_extension_id
  );

   IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('update_receipt_unid_to_unapp: ' || 'New Status : ' || to_char(X_NEW_STATUS));
	arp_standard.debug('update_receipt_unid_to_unapp: ' || 'New Status Displayed : ' || to_char(X_NEW_STATUS_DSP));
   END IF;

    -- Updating Return Status for Receipt ----

       x_status :=  X_NEW_STATUS_DSP;



	/*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('update_receipt_unid_to_unapp : ' || 'committing');
            END IF;
            Commit;
        END IF;


	IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('ar_receipt_update_api_pub.update_receipt_unid_to_unapp()-');
        END IF;

  EXCEPTION
        WHEN OTHERS THEN

                     ROLLBACK TO Create_Cash_PVT;
		     --  Display_Parameters;
                       x_return_status := FND_API.G_RET_STS_ERROR ;
		       x_status :=  'XXX';
                       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','UPDATE_RECEIPT_UNID_TO_UNAPP : '||SQLERRM);
                       FND_MSG_PUB.Add;

                       FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                                  p_count  =>  x_msg_count,
                                                  p_data   => x_msg_data
                                                );
                      RETURN;
END update_receipt_unid_to_unapp;
END;

/
