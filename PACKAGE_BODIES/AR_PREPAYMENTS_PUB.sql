--------------------------------------------------------
--  DDL for Package Body AR_PREPAYMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_PREPAYMENTS_PUB" AS
/* $Header: ARPPAYAB.pls 120.12.12010000.4 2009/02/24 11:30:23 spdixit ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'AR_PREPAYMENTS_PUB';
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
 | 09-DEC-2003           J Pandey       Bug3230122 forward port of 3220078
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

     -------Multiple Prepay project: Receipt Number should be IN OUT
      p_receipt_number   IN OUT NOCOPY  ar_cash_receipts.receipt_number%TYPE ,

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
      p_remittance_bank_account_id       IN  ar_cash_receipts.remit_bank_acct_use_id%type DEFAULT NULL,
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

      ---Bug 3220078 Change the parameter to TRUE
      p_call_payment_processor  IN VARCHAR2 DEFAULT FND_API.G_TRUE,

      p_payment_response_error_code OUT NOCOPY VARCHAR2,
   -- OUT NOCOPY parameter for the Application
      p_receivable_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_payment_set_id            IN OUT NOCOPY NUMBER ,
      p_org_id                    IN NUMBER DEFAULT NULL,
      p_payment_trxn_extension_id IN ar_cash_receipts.payment_trxn_extension_id%TYPE
      ) IS


l_cash_receipt_id  	NUMBER(15);
l_create_return_status  VARCHAR2(1);
l_remit_return_status   VARCHAR2(1);
l_payment_set_id   	NUMBER;
l_cc_return_status 	VARCHAR2(1);         -- credit card return status
l_activity_return_status VARCHAR2(1);        -- credit card return status
l_cc_check         	VARCHAR2(1);
l_receivables_trx_id 	NUMBER;
l_response_error_code  	VARCHAR2(80);

--Bug 3220078 --
l_cash_receipt_status  ar_receipt_classes.creation_status%type;
l_payment_type         ar_receipt_methods.payment_type_code%type;

l_api_name       CONSTANT VARCHAR2(20) := 'Create_Prepayment';
l_api_version    CONSTANT NUMBER       := 1.0;
l_org_return_status VARCHAR2(1);
l_org_id                           NUMBER;

-- payment uptake
   CURSOR rct_info_cur IS
     SELECT cr.receipt_number,
            cr.amount,
            cr.currency_code,
            rm.PAYMENT_CHANNEL_CODE,       /* NEW ADDED */
            rc.creation_status,            /* AR USE */
            cr.org_id,
            cr.payment_trxn_extension_id,
            party.party_id,
            cr.pay_from_customer,
            cr.customer_site_use_id
     FROM   ar_cash_receipts_all cr,
            ar_receipt_methods rm,
            ar_receipt_classes rc,
            hz_cust_accounts hca,
            hz_parties    party
     WHERE  cr.cash_receipt_id = l_cash_receipt_id
     AND    hca.party_id = party.party_id
     AND    hca.cust_account_id = cr.pay_from_customer
     AND  cr.receipt_method_id = rm.receipt_method_id
     and  rm.receipt_class_id = rc.receipt_class_id;

            rct_info    rct_info_cur%ROWTYPE;
            l_cr_rec    ar_cash_receipts_all%ROWTYPE;
            l_org_type  HR_ALL_ORGANIZATION_UNITS.TYPE%TYPE;
            l_action VARCHAR2(80);
            l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
            l_msg_count NUMBER;
            l_msg_data  VARCHAR2(2000);
            l_iby_msg_data VARCHAR2(2000);
            l_vend_msg_data VARCHAR2(2000);
           l_payment_trxn_extension_id  ar_cash_receipts.payment_trxn_extension_id%TYPE;

/* DECLARE the variables required for the payment engine (CPY ) all the REC TYPES */
           p_trxn_entity_id    NUMBER;
           lc_trxn_entity_id   IBY_FNDCPT_COMMON_PUB.Id_tbl_type;
           l_auth_flag         VARCHAR2(1);
           l_auth_id           NUMBER;

/* END DECLARE the variables required for the payment engine (CPY ) all the REC TYPES */
/* DECLARE the variables required for the payment engine (CPY AND AUTH) all the REC TYPES */

            l_payer_rec             IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
            l_payee_rec             IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
            l_trxn_entity_id        NUMBER;
            l_auth_attribs_rec      IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
            l_trxn_attribs_rec      IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
            l_amount_rec            IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
            l_authresult_rec       IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type; /* OUT AUTH RESULT STRUCTURE */
            l_response_rec          IBY_FNDCPT_COMMON_PUB.Result_rec_type;   /* OUT RESPONSE STRUCTURE */
            l_entity_id             NUMBER;  -- OUT FROM COPY
/* END DECLARE the variables required for the payment engine (AUTH) all the REC TYPES */



BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('ar_prepayments_pub.Create_Prepayment ()+'|| p_org_id);
         arp_util.debug('Create_Prepayment: payment_trxn_extension_id' || to_char(p_payment_trxn_extension_id) );
         arp_util.debug('Create_Prepayment receipt method id' || to_char(p_receipt_method_id) );
      END IF;

      -- first reinitialize ARP_GLOBAL
        arp_global.init_global;

     /*------------------------------------+
      |   Standard start of API savepoint  |
      +------------------------------------*/
      SAVEPOINT Create_Prepayment_PVT;

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
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
      ----Multiple prepayments allow payment types other than credit card
     /*--------------------------------------------------------------------
      IF p_receipt_method_id is not null THEN
         BEGIN
             SELECT 'Y' into l_cc_check
             FROM  ar_receipt_methods
             WHERE receipt_method_id=p_receipt_method_id
             AND   payment_type_code = 'CREDIT_CARD';
         EXCEPTION
            WHEN no_data_found THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('Create_Prepayment: ' || 'Prepayment only allowed for credit card');
               END IF;
               FND_MESSAGE.SET_NAME('AR','AR_RAPI_PREPAY_ONLYFOR_CC');
               FND_MSG_PUB.Add;
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
         END;

      END IF;
    ---------------------------------------------------------------------*/
/* PAYMENT UPTAKE COMMENTED BY BICHATTE
     --Check whether customer bank account details are passed
       IF ((p_customer_bank_account_id is null) AND
           (p_customer_bank_account_num is null) AND
           (p_customer_bank_account_name is null)) THEN

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Create_Prepayment: ' || 'For Prepayment, customer banks account details must be passed');
             END IF;
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_2_INVALID');
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
       END IF;

*/
     l_receivables_trx_id := p_receivable_trx_id;

                arp_util.debug('Create_Prepayment: payment_trxn_extension_id' || to_char(p_payment_trxn_extension_id) );


--calling the internal create_cash routine
     ar_receipt_api_pub.Create_Cash(
                 p_api_version            => p_api_version,
                 p_init_msg_list          => p_init_msg_list,
                 p_commit                 => FND_API.G_FALSE,
                 p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                 x_return_status          => l_create_return_status,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data,
              -- Receipt info. parameters
                 p_usr_currency_code      => p_usr_currency_code,
                 p_currency_code          => p_currency_code,
                 p_usr_exchange_rate_type => p_usr_exchange_rate_type,
                 p_exchange_rate_type     => p_exchange_rate_type,
                 p_exchange_rate          => p_exchange_rate,
                 p_exchange_rate_date     => p_exchange_rate_date,
                 p_amount                 => p_amount,
                 p_factor_discount_amount => p_factor_discount_amount,
                 p_receipt_number         => p_receipt_number,
                 p_receipt_date           => p_receipt_date,
                 p_gl_date                => p_gl_date,
                 p_maturity_date          => p_maturity_date,
                 p_postmark_date          => p_postmark_date,
                 p_customer_id            => p_customer_id,
                 p_customer_name          => p_customer_name,
                 p_customer_number        => p_customer_number,
                 p_customer_bank_account_id   => p_customer_bank_account_id,
                 p_customer_bank_account_num  => p_customer_bank_account_num,
                 p_customer_bank_account_name => p_customer_bank_account_name,
                 p_payment_trxn_extension_id  => p_payment_trxn_extension_id,
                 p_location                   => p_location,
                 p_customer_site_use_id       => p_customer_site_use_id,
                 p_customer_receipt_reference => p_customer_receipt_reference,
                 p_override_remit_account_flag => p_override_remit_account_flag,
                 p_remittance_bank_account_id  => p_remittance_bank_account_id,
                 p_remittance_bank_account_num => p_remittance_bank_account_num,
                 p_remittance_bank_account_name => p_remittance_bank_account_name,
                 p_deposit_date                 => p_deposit_date,
                 p_receipt_method_id            => p_receipt_method_id,
                 p_receipt_method_name          => p_receipt_method_name,
                 p_doc_sequence_value           => p_doc_sequence_value,
                 p_ussgl_transaction_code       => p_ussgl_transaction_code,
                 p_anticipated_clearing_date    => p_anticipated_clearing_date,
                 p_called_from                  => p_called_from,
                 p_attribute_rec                => p_attribute_rec,
                 p_global_attribute_rec         => p_global_attribute_rec ,
                 p_comments                     => p_receipt_comments,
                 p_issuer_name                  => p_issuer_name,
                 p_issue_date                   => p_issue_date,
                 p_issuer_bank_branch_id        => p_issuer_bank_branch_id,
                 p_org_id                       => p_org_id,
                 p_cr_id                        => l_cash_receipt_id --out variable
                 );

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Create_Prepayment: ' || 'Receipt create_return_status '||l_create_return_status);
         END IF;

        --IF the receipt creation part returns no errors then
        --call the application routine.

         IF l_create_return_status = FND_API.G_RET_STS_SUCCESS THEN

              IF x_msg_count = 1 THEN
                /* If one message, like warning, then put this back on stack as the
                   Create routine must have removed it from the stack and put it on x_msg_data
                 */
                  FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                  FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Create_Prepayment : '||x_msg_data);
                  FND_MSG_PUB.Add;
              END IF;
              --While applying to prepayment, generate payment_set_id from the
              --sequence and pass to apply routine.
              --IF payment set id is passed, then do not generate.
             IF p_payment_set_id is null THEN
              BEGIN
                SELECT ar_receivable_applications_s1.nextval
                INTO   l_payment_set_id
                FROM   dual;
              EXCEPTION
                WHEN others THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('Create_Prepayment: ' || 'Payment set id sequence generation failed'||sqlerrm);
                     END IF;
                     FND_MESSAGE.SET_NAME('AR','AR_RAPI_PREPAY_SEQ_FAILED');
                     FND_MSG_PUB.Add;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     RETURN;
              END;
             ELSE
                l_payment_set_id := p_payment_set_id;
             END IF;

          --Default receivable_trx_id for prepayment .

            ar_receipt_lib_pvt.Default_prepay_cc_activity(
                         'PREPAYMENT',
                         l_receivables_trx_id,
                         l_activity_return_status);

            IF l_activity_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          ROLLBACK TO Create_Prepayment_PVT;
                          x_return_status := l_activity_return_status;

                          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data);

                          RETURN; -- exit back to caller
            END IF;
/* Notes -- bichatte we dont need the check for p_call_payment_processor */


                   SELECT payment_channel_code
                   INTO   l_payment_type
                   FROM  ar_receipt_methods
                   WHERE  receipt_method_id = p_receipt_method_id;


    l_payment_trxn_extension_id := p_payment_trxn_extension_id;

                 IF ((l_payment_trxn_extension_id IS NULL) AND ( l_payment_type in ( 'CREDIT_CARD', 'BANK_ACCT_XFER')))  THEN

                     IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('ERROR: payment_trxn_extension is NULL ' ||nvl(l_payment_trxn_extension_id,-9999));
                     END IF;

                    FND_MESSAGE.set_name('AR', 'AR_PAY_PROCESS_INVALID_STATUS');
                    FND_MSG_PUB.Add;

                    x_return_status := FND_API.G_RET_STS_ERROR;  -- should never happen

                    RETURN;
                 END IF;

/* bichatte start */
   -- Payment uptake
   -- i) here we will check if the l_payment_trxn_extension_id is already authorised or not
   --      accordingly call Auth
   -- ii) pass the l_payment_trxn_extension_id to create_cash so that its gets copied and stamped
   --     on the cash receipt.



   IF  l_payment_trxn_extension_id IS  NOT NULL  THEN
                           IF PG_DEBUG in ('Y', 'C') THEN
                            arp_util.debug('Process_Credit_Card: ' || 'COPY the trx_extension_id');
                           END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(  'Entering payment processing...');
  END IF;


  OPEN rct_info_cur;
  FETCH rct_info_cur INTO rct_info;

 IF rct_info_cur%FOUND THEN

 -- Step 1: (always performed):

          -- set up payee record:
          l_payee_rec.org_id   := rct_info.org_id;                            -- receipt's org_id
          l_payee_rec.org_type := 'OPERATING_UNIT' ;                                -- ( HR_ORGANIZATION_UNITS )


        -- set up payer (=customer) record:

        l_payer_rec.Payment_Function := 'CUSTOMER_PAYMENT';
        l_payer_rec.Party_Id :=   rct_info.party_id;     -- receipt customer party id mandatory
        l_payer_rec.org_id   := rct_info.org_id ;
        l_payer_rec.org_type := 'OPERATING_UNIT';
        l_payer_rec.Cust_Account_Id :=rct_info.pay_from_customer;  -- receipt customer account_id
        l_payer_rec.Account_Site_Id :=rct_info.customer_site_use_id; -- receipt customer site_id




        -- set up trx_entity record: /* NOTE HERE we have to call  Copy_Transaction_Extension */


        -- set up auth_attribs record:
            l_auth_attribs_rec.RiskEval_Enable_Flag := 'N';
        -- set up trxn_attribs record:
        l_trxn_attribs_rec.Originating_Application_Id := arp_standard.application_id;
        l_trxn_attribs_rec.order_id :=  rct_info.receipt_number;
        l_trxn_attribs_rec.Trxn_Ref_Number1 := 'RECEIPT';
        l_trxn_attribs_rec.Trxn_Ref_Number2 := l_cash_receipt_id;

        -- set up amounts

        l_amount_rec.value := rct_info.amount;
        l_amount_rec.currency_code   := rct_info.currency_code;

       IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(  'check and then call Auth');
        END IF;

        -- determine whether to AUTHORIZE

        -- assign the value for payment_trxn_extension record the copied value

                 l_trxn_entity_id := rct_info.payment_trxn_extension_id;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(  'Calling get auth for  pmt_trxn_extn_id ');
           arp_standard.debug(  'l_trxn_entity_id  '             || to_char(l_trxn_entity_id ) );

       END IF;

             Begin
                SELECT decode(summ.status,   NULL,   'N',   'Y') AUTHORIZED_FLAG
                   into l_auth_flag
                 FROM iby_trxn_summaries_all summ,
                      iby_fndcpt_tx_operations op
                WHERE summ.transactionid = op.transactionid
                      AND reqtype = 'ORAPMTREQ'
                      AND status IN(0,    100)
                      AND trxntypeid IN(2,   3, 20)
                      AND op.trxn_extension_id = l_trxn_entity_id
                      AND summ.trxnmid =
                           (SELECT MAX(trxnmid)
                                FROM iby_trxn_summaries_all
                            WHERE transactionid = summ.transactionid
                            AND reqtype = 'ORAPMTREQ'
                            AND status IN(0, 100)
                            AND trxntypeid IN(2,    3,   20));
             Exception
               when others then
                 l_auth_flag := 'N';
             End;

              arp_standard.debug ( 'the value of auth_flag is = ' || l_auth_flag);

                If l_auth_flag = 'Y' then

                  select AUTHORIZATION_ID
                   into l_auth_id
                   from IBY_TRXN_EXT_AUTHS_V
                   where TRXN_EXTENSION_ID = p_payment_trxn_extension_id;

                  arp_standard.debug ( 'the value of auth_id is = ' || l_auth_id);

                  ARP_CASH_RECEIPTS_PKG.set_to_dummy(l_cr_rec);

                  l_cr_rec.approval_code := 'AR'||to_char(l_auth_Id);

                  ARP_CASH_RECEIPTS_PKG.update_p(l_cr_rec, l_cash_receipt_id);

               arp_standard.debug('CR rec updated with auth_id and auth code ');
                end if;




           IF  l_auth_flag <> 'Y'  then
                 arp_standard.debug('auth needs to called');

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug(  'Calling get auth for  pmt_trxn_extn_id ');
                  arp_standard.debug(  ' l_payee_rec.org_id '           || to_char(l_payee_rec.org_id) );
                  arp_standard.debug(  ' l_payee_rec.org_type '         || to_char( l_payee_rec.org_type) );
                  arp_standard.debug(  ' l_payer_rec.Payment_Function ' || to_char( l_payer_rec.Payment_Function) );
                  arp_standard.debug(  ' l_payer_rec.Party_Id '         || to_char( l_payer_rec.Party_Id) );
                  arp_standard.debug(  ' l_payer_rec.org_id '           || to_char(l_payer_rec.org_id) );
                  arp_standard.debug(  ' l_payer_rec.org_type  '        || to_char( l_payer_rec.org_type) );
                  arp_standard.debug(  'l_payer_rec.Cust_Account_Id '   || to_char(l_payer_rec.Cust_Account_Id) );
                  arp_standard.debug(  'l_payer_rec.Account_Site_Id '   || to_char(l_payer_rec.Account_Site_Id) );
                  arp_standard.debug(  'l_trxn_entity_id  '             || to_char(l_trxn_entity_id ) );
                  arp_standard.debug(  'l_amount_rec.value: ' || to_char(l_amount_rec.value) );
                  arp_standard.debug(  'l_amount_rec.currency_code: '   || l_amount_rec.currency_code );

                  arp_standard.debug(  'Calling get_auth for  pmt_trxn_extn_id ');
               END IF;

                   IBY_FNDCPT_TRXN_PUB.Create_Authorization(
                         p_api_version        => 1.0,
                         p_init_msg_list      => FND_API.G_TRUE,
                         x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data,
                         p_payer              => l_payer_rec,
                         p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                         p_payee              => l_payee_rec,
                         p_trxn_entity_id     => l_trxn_entity_id,
                         p_auth_attribs       => l_auth_attribs_rec,
                         p_amount             => l_amount_rec,
                         x_auth_result        => l_authresult_rec, -- out auth result struct
                         x_response           => l_response_rec );   -- out response struct


                  x_msg_count           := l_msg_count;
                  x_msg_data            := l_msg_data;

                        arp_standard.debug('x_return_status  :<' || l_return_status || '>');
                        arp_standard.debug('x_msg_count      :<' || l_msg_count || '>');

                  FOR i IN 1..l_msg_count LOOP
                      arp_standard.debug('x_msg #' || TO_CHAR(i) || ' = <' ||
                      SUBSTR(fnd_msg_pub.get(p_msg_index => i,p_encoded => FND_API.G_FALSE),1,150) || '>');
                  END LOOP;

                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_standard.debug(  '-------------------------------------');
                        arp_standard.debug(  'l_response_rec.Result_Code:     ' || l_response_rec.Result_Code);
                        arp_standard.debug(  'l_response_rec.Result_Category: ' || l_response_rec.Result_Category);
                        arp_standard.debug(  'l_response_rec.Result_message : ' || l_response_rec.Result_message );
                        arp_standard.debug(  'l_authresult_rec.Auth_Id:     '       || l_authresult_rec.Auth_Id);
                        arp_standard.debug(  'l_authresult_rec.Auth_Date: '         || l_authresult_rec.Auth_Date);
                        arp_standard.debug(  'l_authresult_rec.Auth_Code:     '     || l_authresult_rec.Auth_Code);
                        arp_standard.debug(  'l_authresult_rec.AVS_Code: '          || l_authresult_rec.AVS_Code);
                        arp_standard.debug(  'l_authresult_rec.Instr_SecCode_Check:'|| l_authresult_rec.Instr_SecCode_Check);
                        arp_standard.debug(  'l_authresult_rec.PaymentSys_Code: '   || l_authresult_rec.PaymentSys_Code);
                        arp_standard.debug(  'l_authresult_rec.PaymentSys_Msg: '    || l_authresult_rec.PaymentSys_Msg);
                     -- arp_standard.debug(  'l_authresult_rec.Risk_Result: '       || l_authresult_rec.Risk_Result);

                    END IF;

             IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              -- update cash receipt with authorization code and

                ARP_CASH_RECEIPTS_PKG.set_to_dummy(l_cr_rec);
                 l_cr_rec.approval_code := l_authresult_rec.Auth_code ||'AR'||to_char(l_authresult_rec.Auth_Id);

               ARP_CASH_RECEIPTS_PKG.update_p(l_cr_rec, l_cash_receipt_id);

               IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('CR rec updated with auth_id and auth code ');
               END IF;

             END IF;

                    -- check if call was successful
                    --Add message to message stack only it it is called from iReceivables
                    --if not pass the message stack received from iPayment

                    IF (NVL(p_called_from,'NONE') = 'IREC') THEN
                      IF PG_DEBUG in ('Y', 'C') THEN
                          arp_standard.debug(  'l_MSG_COUNT=>'||to_char(l_MSG_COUNT));
                    END IF;
                    fnd_msg_pub.dump_list;
                    IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug(  'Errors: ');
                    END IF;
                      IF(l_MSG_COUNT=1) THEN
                         IF PG_DEBUG in ('Y', 'C') THEN
                          arp_standard.debug(  l_MSG_DATA);
                         END IF;
                      ELSIF(l_MSG_COUNT>1)THEN
                           LOOP
                           l_MSG_DATA:=FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
                               IF (l_MSG_DATA IS NULL)THEN
                               EXIT;
                               END IF;
                              IF PG_DEBUG in ('Y', 'C') THEN
                              arp_standard.debug(  l_MSG_DATA);
                              END IF;
                           END LOOP;
                      END IF;
                    END IF;

                 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                 AND (NVL(p_called_from,'NONE') = 'IREC')  then

		  ROLLBACK TO Create_Prepayment_Pvt;
                  FND_MESSAGE.set_name('AR', 'AR_PAY_PROCESS_AUTHFAILURE');
                  FND_MSG_PUB.Add;
                  x_return_status := l_return_status;
                  RETURN;

                ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

		  ROLLBACK TO Create_Prepayment_Pvt;
		  arp_standard.debug('create_cash_126');
                  FND_MESSAGE.set_name('AR', 'AR_CC_AUTH_FAILED');
                  FND_MSG_PUB.Add;

                     IF  l_response_rec.Result_Code is NOT NULL THEN

                       ---Raise the PAYMENT error code concatenated with the message

                        l_iby_msg_data := substrb( l_response_rec.Result_Code || ': '||
                                   l_response_rec.Result_Message , 1, 240);

                        arp_standard.debug(  'l_iby_msg_data: ' || l_iby_msg_data);
                        FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_iby_msg_data);

                        FND_MSG_PUB.Add;

                     END IF;

                     IF l_authresult_rec.PaymentSys_Code is not null THEN

                       ---Raise the VENDOR error code concatenated with the message

                        l_vend_msg_data := substrb(l_authresult_rec.PaymentSys_Code || ': '||
                                   l_authresult_rec.PaymentSys_Msg , 1, 240 );

                        FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT',l_vend_msg_data);

                      FND_MSG_PUB.Add;

                    END IF;


                    FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count  =>  x_msg_count,
                               p_data   => x_msg_data );

                    x_return_status := l_return_status;
                    RETURN;

                  END IF; /* End the error handling CREATE */

          END IF;  /* END if of auth flag N  */


       END IF; -- rct_info_cur%FOUND

                 END IF; --- l_payment_trxn_extension_id is not null.

/* bichatte end */


            ar_receipt_api_pub.Apply_other_account(
                -- Standard API parameters.
                   p_api_version      => p_api_version,
                   p_init_msg_list    => FND_API.G_FALSE, --message stack is not initialized
                   p_commit           => p_commit,
                   p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status    => l_create_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data,
                   p_receivable_application_id => p_receivable_application_id,
                 --Receipt application parameters.
                   p_cash_receipt_id           => l_cash_receipt_id,
                   p_receipt_number            => p_receipt_number,
                   p_amount_applied            => p_amount_applied,
                   p_receivables_trx_id        => l_receivables_trx_id,
                   p_applied_payment_schedule_id => p_applied_payment_schedule_id,
                   p_apply_date                => p_apply_date,
                   p_apply_gl_date             => p_apply_gl_date,
                   p_ussgl_transaction_code    => app_ussgl_transaction_code,
                   p_application_ref_type      => p_application_ref_type,
                   p_application_ref_id        => p_application_ref_id,
                   p_application_ref_num       => p_application_ref_num,
                   p_secondary_application_ref_id => p_secondary_application_ref_id,
                   p_org_id                       => p_org_id,
                   p_payment_set_id               => l_payment_set_id,
                   p_attribute_rec             => app_attribute_rec,
                -- ******* Global Flexfield parameters *******
                   p_global_attribute_rec      => app_global_attribute_rec,
                   p_comments                  => app_comments
                 );

                 --If the application fails then we need to rollback all the changes
                 --made in the create() routine also.
                  IF l_create_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     ROLLBACK TO Create_Prepayment_Pvt;
                     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data);
                     x_return_status := l_create_return_status;
                     RETURN;
                  ELSE

                  ------Mult. Prepay remittance based on receipt class setup---
                  --Prepayment Receipt needs to be remitted eventhough the receipt
                  -- class status does not require remittance immediatly.

                  --Bug 3220078 no need to remit the receipts from 'CONFIRMED'
                  --status but ipayment calls need to be made acc. to receipt
                  --class setup


                   ----get the status and payment method of of the receipt -----
                   SELECT rc.creation_status ,  nvl(rm.payment_channel_code, 'CHECK')
                   INTO   l_cash_receipt_status,  l_payment_type
                   FROM  ar_cash_receipts cr, ar_receipt_classes rc,
                         ar_receipt_methods rm
                   WHERE cr.cash_receipt_id = l_cash_receipt_id
                   AND   cr.receipt_method_id = rm.receipt_method_id
                   AND   rm.receipt_class_id = rc.receipt_class_id;


                    -- charge credit card if needed.  Note: this only
                    -- happens if the receipt and application creation
                    -- was successful.  All relevant information for the
                    -- payment can be derived from the cash receipt.

                    --for CONFIRMED auth only
                    --REMITTED,CLEARED  auth and capture

                   IF ( (l_payment_type = 'CREDIT_CARD')  AND
                        l_cash_receipt_status IN ('CONFIRMED', 'REMITTED', 'CLEARED')
                      )
                   THEN

                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_standard.debug('Create_Prepayment: ' || 'Checking p_call_payment_processor: ' || p_call_payment_processor);
                     END IF;
                   /*  if (p_call_payment_processor = FND_API.G_TRUE) then

                         Process_Credit_Card(
                               p_cash_receipt_id          => l_cash_receipt_id,
                               p_payment_server_order_num =>
                                                  p_payment_server_order_num,
                               p_auth_code               => p_approval_code,
                               p_response_error_code     => l_response_error_code,
                               x_msg_count               => x_msg_count,
                               x_msg_data                => x_msg_data,
                               x_return_status           => l_cc_return_status);


                       -- If the payment processor call fails, then we
                       -- need to rollback all the changes
                       -- made in the create() and apply() routines also.

                       IF l_cc_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          x_return_status := l_cc_return_status;
                          p_payment_response_error_code := l_response_error_code;

                          ROLLBACK TO Create_Prepayment_PVT;
                          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data);

                          RETURN; -- exit back to caller
                       END IF;

                    end if;  -- if p_call_payment_processor = fnd_api.g_true */
                  END IF; --l_payment_type

                     -- need to pass back cr_id
                     p_cr_id := l_cash_receipt_id;
                     p_payment_set_id := l_payment_set_id;

                  END IF;
            ELSE  --after create_cash success status
             x_return_status := l_create_return_status;
            END IF;
END IF;

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit )
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Create_Prepayments: ' || 'committing');
            END IF;
              Commit;
        END IF;

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
       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','CREATE_PREPAYMENT : '||SQLERRM);
       FND_MSG_PUB.Add;

       FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                                  p_count  =>  x_msg_count,
                                  p_data   => x_msg_data
                                                );
       RETURN;
   ELSE
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','CREATE_PREPAYMENT : '||SQLERRM);
         FND_MSG_PUB.Add;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Create_Prepayment: ' || SQLCODE, G_MSG_ERROR);
      arp_util.debug('Create_Prepayment: ' || SQLERRM, G_MSG_ERROR);
   END IF;

   ROLLBACK TO Create_Prepayment_PVT;

   IF      FND_MSG_PUB.Check_Msg_Level THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                   l_api_name
                                   );
   END IF;

    --   Display_Parameters;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count       =>      x_msg_count,
                              p_data        =>      x_msg_data);


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('ar_prepayments_pub.Create_Prepayment ()-');
    END IF;

END Create_Prepayment;

/*=======================================================================
 | PUBLIC Procedure Get_Installment
 |
 | DESCRIPTION
 |      Gets the installment number and amount for a payment term
 |      ----------------------------------------------------------
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
 | 12-DEC-2003           Jyoti Pandey   Bug 3248093 Add get_installment
 |                                      procedure in this package
 *=======================================================================*/

PROCEDURE get_installment(
      p_term_id         IN  NUMBER,
      p_amount          IN  NUMBER,
      p_currency_code   IN  VARCHAR2,
      p_org_id          IN NUMBER DEFAULT NULL,
      p_installment_tbl OUT NOCOPY ar_prepayments_pub.installment_tbl,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2) IS

 l_installment_tbl installment_tbl;
 l_return_status   VARCHAR2(1);
 l_msg_count       NUMBER;
 l_msg_data        VARCHAR2(255);
 l_org_return_status VARCHAR2(1);
 l_org_id                           NUMBER;

 BEGIN

/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
 ELSE

  AR_PREPAYMENTS.get_installment(
              p_term_id,
              p_amount,
              p_currency_code,
              p_installment_tbl,
              x_return_status,
              x_msg_count,
              x_msg_data);
  END IF;

 END get_installment;


END AR_PREPAYMENTS_PUB;

/
