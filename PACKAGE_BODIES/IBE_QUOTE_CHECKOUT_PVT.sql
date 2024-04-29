--------------------------------------------------------
--  DDL for Package Body IBE_QUOTE_CHECKOUT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_QUOTE_CHECKOUT_PVT" as
/* $Header: IBEVQASB.pls 120.12.12010000.4 2013/01/18 05:37:04 amaheshw ship $ */
-- Start of Comments
-- Package name     : IBE_Quote_Checkout_Pvt
-- Purpose	    :
-- NOTE 	    :

-- End of Comments

-- Default number of records fetch per call
l_true VARCHAR2(1)               := FND_API.G_TRUE;
G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_Quote_Checkout_Pvt';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVQASB.pls';
G_AUTH_ERROR CONSTANT NUMBER     :=3;
PROCEDURE Authorize_Credit_Card(
   p_qte_Header_Id      IN  NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
) IS

l_trxn_extension_id      NUMBER;
l_payer                 IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_payee_rec             IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
l_party_id              NUMBER;
l_resource_id           NUMBER := FND_API.G_MISS_NUM;
l_org_type              VARCHAR2(30) := 'OPERATING_UNIT';
l_payment_function      VARCHAR2(30) := 'CUSTOMER_PAYMENT';
l_auth_result           IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type;
l_amount                IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
l_auth_attribs          IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
l_response              IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_trxn_currency_code    VARCHAR2(30) := 'USD';
l_return_status         VARCHAR2(30) := NULL;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_auth_amount           NUMBER;
L_API_NAME              CONSTANT VARCHAR2(30) := 'Authorize_Credit_Card';
l_quote_source_code     VARCHAR2(40);
l_org_id                NUMBER;

 -- bug 15972783
l_cust_account_id                NUMBER;


Cursor c_get_trxn_extn_id (c_quote_header_id number)
   IS
    select trxn_extension_id
    from aso_payments
    where quote_header_id = c_quote_header_id and quote_line_id is null;

Cursor c_get_quote_details (c_quote_header_id number)
IS
 -- bug 15972783   select  total_quote_price, currency_code, party_id, resource_id, quote_source_code
  select  total_quote_price, currency_code, party_id, resource_id, quote_source_code, cust_account_id
    from ibe_quote_headers_v
    where quote_header_id = c_quote_header_id;

Cursor c_get_org_id (c_party_id number)
IS
    select object_id
    from hz_relationships
    where party_id = c_party_id and directional_flag='F'
    and relationship_code in ('EMPLOYEE_OF','CONTACT_OF') and rownum <2;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Inside Authorize_Credit_Card api');
     IBE_UTIL.DEBUG('PRAGMA AUTONOMOUS_TRANSACTION');
   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Authorize_Credit_Card:FND_MSG_PUB.initialized');
   END IF;

   open c_get_trxn_extn_id(p_qte_Header_Id);
   fetch c_get_trxn_extn_id into l_trxn_extension_id;
   close c_get_trxn_extn_id;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Authorize_Credit_Card: After trxn query - l_trxn_extension_id' || l_trxn_extension_id);
   END IF;

   open c_get_quote_details(p_qte_Header_Id);
-- bug  15972783  fetch c_get_quote_details into l_auth_amount, l_trxn_currency_code, l_party_id, l_resource_id, l_quote_source_code;
    fetch c_get_quote_details into l_auth_amount, l_trxn_currency_code, l_party_id, l_resource_id, l_quote_source_code, l_cust_account_id;
   close c_get_quote_details;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Authorize_Credit_Card:l_trxn_currency_code'|| l_trxn_currency_code);
      IBE_UTIL.DEBUG('Authorize_Credit_Card:Amount populated...'|| l_auth_amount);
      IBE_UTIL.DEBUG('Authorize_Credit_Card:l_party_id populated...'|| l_party_id);
      IBE_UTIL.DEBUG('Authorize_Credit_Card:l_resource_id populated...'|| l_resource_id);
      IBE_UTIL.DEBUG('Authorize_Credit_Card:l_quote_source_code...'|| l_quote_source_code);
      IBE_UTIL.DEBUG(' bug 15972783 Authorize_Credit_Card:l_cust_account_id...'|| l_cust_account_id);
   END IF;

   IF(l_resource_id is not null AND l_resource_id <> FND_API.G_MISS_NUM AND l_party_id is not null
      and l_quote_source_code = 'Order Capture Quotes') THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Authorize_Credit_Card: l_resource_id not null and is Order Capture Quote. Get the org_id');
      END IF;

      open c_get_org_id(l_party_id);
      fetch c_get_org_id into l_org_id;
      if c_get_org_id%NOTFOUND THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('Authorize_Credit_Card: l_org_id not found');
          END IF;
      else
          l_party_id :=  l_org_id;
      end if;
      close c_get_org_id;


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Authorize_Credit_Card: After getting the org_id- party_id is '||l_party_id);
      END IF;
   END IF;

    l_payer.payment_function := 'CUSTOMER_PAYMENT';
    l_payer.party_id         := l_party_id;
    l_payee_rec.Org_Type     := 'OPERATING_UNIT';
    l_payee_rec.Org_Id       := MO_GLOBAL.get_current_org_id;
    l_amount.value           := l_auth_amount;
    l_amount.currency_code   := l_trxn_currency_code;
    l_auth_attribs.RiskEval_Enable_Flag := 'N';  -- Risk Validation should not be done

-- bug  15972783
    l_payer.cust_account_id         := l_cust_account_id;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Authorize_Credit_Card:Before call to create auth trxn_extension_id is: '||l_trxn_extension_id);
       IBE_UTIL.DEBUG('Authorize_Credit_Card:Payer context values ...');
       IBE_UTIL.DEBUG('Authorize_Credit_Card:payment function'||l_payment_function);
       IBE_UTIL.DEBUG('Authorize_Credit_Card:l_payer.party_id'||l_party_id);
       IBE_UTIL.DEBUG('Authorize_Credit_Card:amount is '||l_amount.value);
       IBE_UTIL.DEBUG('Authorize_Credit_Card:currency is '||l_amount.currency_code);
       IBE_UTIL.DEBUG('Authorize_Credit_Card:risk eval flag is '||l_auth_attribs.RiskEval_Enable_Flag);
       IBE_UTIL.DEBUG(' bug 15972783  Authorize_Credit_Card:l_cust_account_id is '||l_cust_account_id);
       IBE_UTIL.DEBUG(' bug 15972783  Authorize_Credit_Card:l_payer.cust_account_id is '||l_payer.cust_account_id);
       IBE_UTIL.DEBUG('Authorize_Credit_Card:Calling IBY_Fndcpt_Trxn_Pub.Create_Authorization ');
    END IF;


    IBY_Fndcpt_Trxn_Pub.Create_Authorization
        (p_api_version        => 1.0,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data,
         p_payer              => l_payer,
         p_payer_equivalency  => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
         p_payee              => l_payee_rec,
         p_trxn_entity_id     => l_trxn_extension_id,
         p_auth_attribs       => l_auth_attribs,
         p_amount             => l_amount,
         x_auth_result        => l_auth_result,
         x_response           => l_response);


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Authorize_Credit_Card: After call to IBY_Fndcpt_Trxn_Pub.Create_Authorization');
         IBE_UTIL.DEBUG('Authorize_Credit_Card: l_return_status:'||l_return_status);
         IBE_UTIL.DEBUG('Authorize_Credit_Card: CC l_response.result_code '||l_response.result_code);
         IBE_UTIL.DEBUG('Authorize_Credit_Card: x_msg_data:'|| l_msg_data);

         if(l_response.result_code = 'IBY_0001' or l_response.result_code = 'COMMUNICATION_ERROR') then
             IBE_UTIL.DEBUG('Authorize_Credit_Card: There was some communication error');
             IBE_UTIL.DEBUG('Authorize_Credit_Card: x_msg_data:'|| l_msg_data);
         end if;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS AND  l_response.result_code = 'AUTH_SUCCESS' THEN

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('Authorize_Credit_Card:Authorization successful....Commiting the data');
       END IF;
       COMMIT;

    ELSE
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Authorize_Credit_Card:CC Auth failed...!');
         IBE_UTIL.DEBUG('Authorize_Credit_Card:l_response.result_code = '|| l_response.result_code);
       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR;

       FND_MSG_PUB.initialize;
       FND_MESSAGE.CLEAR;

       IF l_response.result_code = 'IBY_0020' or l_response.result_code = 'PAYMENT_SYS_REJECT' THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('Authorize_Credit_Card: Payment Decline - PAYMENT_SYS_REJECT ');
            IBE_UTIL.DEBUG('Authorize_Credit_Card: x_msg_count '|| x_msg_count);
            IBE_UTIL.DEBUG('Authorize_Credit_Card: x_msg_data '|| x_msg_data);
          END IF;

          FND_MESSAGE.SET_NAME('IBE','IBE_ERR_CC_AUTH_DECLINE');
          FND_MSG_PUB.ADD;

       ELSE
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('Authorize_Credit_Card:Had some problem while processing the CC Auth.Setting common error msg ');
          END IF;

	  FND_MESSAGE.SET_NAME('IBE','IBE_ERR_CC_AUTH_PROCESSING');
          FND_MSG_PUB.ADD;

    END IF;

    RAISE FND_API.G_EXC_ERROR;
END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Expected exception in IBE_Quote_Checkout_Pvt.Authorize_Credit_Card');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Expected exception count and data'||x_msg_count||'data = '||x_msg_data);
     END IF;
     RAISE FND_API.G_EXC_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Unexpected exception in IBE_Quote_Checkout_Pvt.Authorize_Credit_Card');
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN OTHERS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unknown exception in IBE_Quote_Checkout_Pvt.Authorize_Credit_Card');
     END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                  L_API_NAME);
     END IF;
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count   ,
                                p_data    => x_msg_data);

END Authorize_Credit_Card;


PROCEDURE Default_Order_State(
   p_qte_Header_Id           IN  NUMBER
  ,px_submit_Control_Rec     IN OUT NOCOPY ASO_QUOTE_PUB.Submit_Control_Rec_Type
) IS
  l_qte_payment_tbl          ASO_QUOTE_PUB.Payment_Tbl_Type;

  FUNCTION Boolean_To_GBoolean(p_Cond IN BOOLEAN) RETURN VARCHAR2 IS
  BEGIN
    IF p_Cond THEN
     RETURN FND_API.G_TRUE;
    ELSE
     RETURN FND_API.G_FALSE;
    END IF;
  END Boolean_To_GBoolean;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('IBE_Quote_Checkout_Pvt.Default_Order_State Start');
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Submit_Control_Rec.Book_Flag=' || px_submit_control_rec.book_flag);
     IBE_Util.Debug('Submit_Control_Rec.Book_Flag=(' || px_submit_control_rec.book_flag || ')');
     IBE_Util.Debug('FND_PROFILE(ASO_DEFAULT_ORDER_STATE)=(' || FND_PROFILE.Value('ASO_DEFAULT_ORDER_STATE') || ')');
  END IF;

  IF px_submit_control_rec.book_flag = FND_API.G_MISS_CHAR --OR
--	px_submit_control_rec.book_flag = 'F'
-- shouldn't be defaulting if F is passed in
  THEN
    l_qte_payment_tbl := IBE_Quote_Misc_pvt.getHeaderPaymentTbl(p_qte_header_id);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('qte_payment_tbl.COUNT=' || l_qte_payment_tbl.COUNT);
    END IF;
    IF l_qte_payment_tbl.COUNT = 1 THEN
	 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	 IBE_UTIL.Debug('qte_payment_tbl(1).payment_type_code = ' || l_qte_payment_tbl(1).payment_type_code);
	 END IF;
      IF l_qte_payment_tbl(1).payment_type_code IN ('CREDIT_CARD', 'PO') THEN
  	   /*IF l_qte_payment_tbl(1).payment_ref_number IS NOT NULL THEN
	     px_submit_control_rec.book_flag :=
		   Boolean_To_GBoolean(FND_PROFILE.Value('ASO_DEFAULT_ORDER_STATE') = 'BOOKED');
        ELSE
	     px_submit_control_rec.book_flag := FND_API.G_FALSE;
	   END IF;*/

        /*mannamra: Credit Card Consolidation changes: 1. We will no longer use payment_ref_number, which would
                                                       be the credit card number when payment type is credit_card,
                                                       because only assignment id will be sufficient for ASO to
                                                       retrieve the credit card details.
                                                       2. PO number cannot be an independent payment type hence
                                                       not taking into consideration the case when only PO number
                                                       is passed.
                                                       */
        IF (l_qte_payment_tbl(1).instr_assignment_id is not null
           AND l_qte_payment_tbl(1).instr_assignment_id <> FND_API.G_MISS_NUM) THEN
          px_submit_control_rec.book_flag :=
          Boolean_To_GBoolean(FND_PROFILE.Value('ASO_DEFAULT_ORDER_STATE') = 'BOOKED');
        ELSE
          px_submit_control_rec.book_flag := FND_API.G_FALSE;
        END IF;

      ELSIF NVL(l_qte_payment_tbl(1).payment_type_code, 'CASH') IN ('CASH', 'CHECK') THEN
	   px_submit_control_rec.book_flag :=
		   Boolean_To_GBoolean(FND_PROFILE.Value('ASO_DEFAULT_ORDER_STATE') = 'BOOKED');
      END IF;
    ELSE -- Handles INVOICE payment type code
	   px_submit_control_rec.book_flag :=
		   Boolean_To_GBoolean(FND_PROFILE.Value('ASO_DEFAULT_ORDER_STATE') = 'BOOKED');
    END IF;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Updated Submit_Control_Rec.Book_Flag=' || px_submit_control_rec.book_flag);
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('IBE_Quote_Checkout_Pvt.Default_Order_State Finishes');
  END IF;

END Default_Order_State;

PROCEDURE SubmitQuote(
  p_api_version_number        IN  NUMBER
  ,p_commit                   IN  VARCHAR2 := FND_API.g_false
  ,p_init_msg_list            IN  VARCHAR2 := FND_API.g_false
  ,p_quote_Header_Id          IN  NUMBER
  ,p_last_update_date         in  DATE     := FND_API.G_MISS_DATE

  ,p_sharee_party_Id          IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_sharee_number	      IN  NUMBER   := FND_API.G_MISS_NUM

  ,p_submit_Control_Rec       IN  ASO_QUOTE_PUB.Submit_Control_Rec_Type
				           := ASO_QUOTE_PUB.G_MISS_Submit_Control_Rec

  ,p_customer_comments        IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_reason_code              IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_salesrep_email_id        IN  VARCHAR2 := FND_API.G_MISS_CHAR

  -- 9/17/02: added to control calling validate_user_update
  ,p_validate_user            IN  VARCHAR2 := FND_API.G_TRUE
  ,p_minisite_id	      IN  NUMBER   := FND_API.G_MISS_NUM

  ,x_order_header_rec         OUT NOCOPY ASO_QUOTE_PUB.Order_Header_Rec_Type
     --Mannamra: Added for bug 4716044
  ,x_hold_flag                OUT NOCOPY VARCHAR2
  ,x_return_status            OUT NOCOPY VARCHAR2
  ,x_msg_count                OUT NOCOPY NUMBER
  ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
   L_API_NAME                 CONSTANT VARCHAR2(30)	:= 'SUBMITQUOTE';
   L_API_VERSION              CONSTANT NUMBER 	:= 1.0;

   l_privilege_type_code      VARCHAR2(30);
   l_qte_header_rec           ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE;
   l_submit_control_rec       ASO_QUOTE_PUB.Submit_Control_Rec_Type
                             := ASO_QUOTE_PUB.G_MISS_Submit_Control_Rec;
   l_return_status            VARCHAR2(1);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(2000);

   PLACE_ORDER              NUMBER := 6;


   l_contract_id              NUMBER;
   l_related_obj_id           NUMBER;
   l_contract_number          VARCHAR2(120);
   l_current_state            NUMBER;

   l_contract_template_id     NUMBER;
   l_check_terms              VARCHAR2(240) := null;

   -- temp vars for NOCOPY OUT params
   l_quote_header_id_tmp NUMBER;
   l_last_update_date_tmp DATE;

   l_quote_source_code    ASO_QUOTE_HEADERS.QUOTE_SOURCE_CODE%TYPE;
   l_sold_to_party_id     NUMBER;
   l_party_id             NUMBER;
   lx_party_id            NUMBER;
   l_last_updated_by      NUMBER;
   l_person_first_name    HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
   l_person_last_name     HZ_PARTIES.PERSON_LAST_NAME%TYPE;
   l_hold_flag            VARCHAR2(1);
   --CC Auth
   l_CC_Auth_Prof         VARCHAR2(1) := NVL(FND_PROFILE.Value('IBE_PERFORM_CC_AUTH'), 'Y');
   l_qte_payment_tbl      ASO_QUOTE_PUB.Payment_Tbl_Type;
   l_auth_flag            VARCHAR2(1);
   l_trxn_extension_id    NUMBER;
   l_payment_type_code  VARCHAR2(30);

  Cursor c_get_quote_details(c_quote_header_id number) IS
    select quote_source_code, party_id, last_updated_by
    from aso_quote_headers
    where quote_header_id = c_quote_header_id;

  Cursor c_get_party_id  (c_user_id number) is
    select customer_id
    from fnd_user
    where user_id = c_user_id;
  Cursor c_get_auth_details (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
     IS
       SELECT authorized_flag
       FROM iby_trxn_extensions_v
       WHERE (trxn_extension_id = ci_extension_id);

   Cursor c_get_trxn_extn_id (c_quote_header_id number)
     IS
    select trxn_extension_id
    FROM ASO_PAYMENTS
    WHERE quote_HEADER_ID = c_quote_header_id and QUOTE_LINE_ID is null;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    SUBMITQUOTE_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
        	    	    	       P_Api_Version_Number,
   	       	                       L_API_NAME,
		    	    	       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('SUBMITQUOTE: Before Calling log_environment_info');
   END IF;
   IBE_Quote_Misc_pvt.log_environment_info();
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('SUBMITQUOTE: After Calling log_environment_info');
   END IF;
   --ibe_util.enable_debug;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Begin IBE_Quote_Checkout_Pvt.SubmitQuote()');
   END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Submit_Quote: p_validate_user flag='||p_validate_user);
  END IF;
  if (fnd_api.to_boolean(p_validate_user)) then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Submit_Quote: before calling validate_user_update()');
    END IF;
     -- User Authentication
    IBE_Quote_Misc_pvt.Validate_User_Update(
	   p_init_msg_list          => FND_API.G_TRUE
	  ,p_quote_header_id        => p_quote_Header_Id
	  ,p_quote_retrieval_number => p_sharee_number
	  ,p_validate_user	        => FND_API.G_TRUE
	  ,p_privilege_type_code    => 'A'
      ,p_save_type              => PLACE_ORDER
      ,p_last_update_date       => p_last_update_date
      ,x_return_status          => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('SUBmit_quote: after calling validate_user_update()');
    END IF;
  end if;

   l_qte_header_rec.quote_header_id := p_quote_header_id;
   /*IF  p_sharee_number IS NOT NULL
   AND p_sharee_number  <> FND_API.G_MISS_NUM THEN
      -- save cart check permisson
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('IBE_Quote_Save_pvt.Save() starts');
      END IF;

      IBE_Quote_Save_pvt.Save(
         p_api_version_number        => p_api_version_number
        ,p_init_msg_list            => FND_API.G_TRUE
        ,p_commit                   => FND_API.G_FALSE
        ,p_sharee_number            => p_sharee_number
        ,p_sharee_party_id          => p_sharee_party_id
        ,p_sharee_cust_account_id   => p_sharee_cust_account_id
        ,p_changeowner              => fnd_api.g_true
        ,p_qte_header_rec           => l_qte_header_rec
        ,x_quote_header_id          => l_quote_header_id_tmp
        ,x_last_update_date         => l_last_update_date_tmp
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('IBE_Quote_Save_pvt.Save() finishes');
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_qte_header_rec.quote_header_id := l_quote_header_id_tmp;
      l_qte_header_rec.last_update_date := l_last_update_date_tmp;

   END IF;*/

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('ASO_Quote_Pub.Default_Order_State starts');
   END IF;

   l_submit_control_rec := p_submit_control_rec;
   Default_Order_State(p_qte_header_id         => l_qte_header_rec.quote_header_id,
				   px_submit_control_Rec   => l_submit_control_rec);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('ASO_Quote_Pub.Default_Order_State finishes. Control_Rec.book_flag = ' ||
			   l_submit_control_rec.book_flag);
   END IF;

   -- Added for Contracts Integration

   IF (FND_Profile.Value('OKC_ENABLE_SALES_CONTRACTS') = 'Y' ) THEN
   -- check if the contract is associated to the quote. If not then retrieve the template id and pass it in header rec.
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Contracts feature is turned ON, before calling Contract get_terms_template');
      END IF;
      l_check_terms := OKC_TERMS_UTIL_GRP.Get_Terms_Template( p_doc_type => 'QUOTE',
                                                              p_doc_id => l_qte_header_rec.quote_header_id);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('After get_terms_template api, l_check_terms='||l_check_terms);
      END IF;

      IF (l_check_terms is null) THEN
        /*mannamra: changes for MOAC*/
        --l_contract_template_id := FND_PROFILE.VALUE('ASO_DEFAULT_CONTRACT_TEMPLATE'); old style
        l_contract_template_id := to_number(ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_CONTRACT_TEMPLATE)); --New style
        /*mannamra: end of changes for MOAC*/
      END IF;

      -- Get the quote details like last_updated_by, quote_source_code, party_id
      open c_get_quote_details(l_qte_header_rec.quote_header_id);
      fetch c_get_quote_details into l_quote_source_code,
                                     l_sold_to_party_id,
                                     l_last_updated_by;
      close c_get_quote_details;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Quote Source Code = '||l_quote_source_code);
        IBE_Util.Debug('Sold To Party Id  = '||l_sold_to_party_id);
        IBE_Util.Debug('last updated by   = '||l_last_updated_by);
      END IF;

      -- for Express Checkout carts, use the last_updated_by column to get the Party Id. If the party Id is null then
      -- use the Sold To Party Id.
      -- For Other Carts, get the party Id depending on the fnd_global.user_id

      IF (l_quote_source_code = 'IStore Oneclick') THEN
         open c_get_party_id(l_last_updated_by);
         fetch c_get_party_id into l_party_id;
         close c_get_party_id;

         IF l_party_id is null THEN
            l_party_id := l_sold_to_party_id;
         END IF;
      ELSE
         open c_get_party_id(FND_GLOBAL.USER_ID);
         fetch c_get_party_id into l_party_id;
         close c_get_party_id;
      END IF;

      -- Get the First Name and Last Name for the derived party id.
      -- Call ibe_workflow_pvt.get_name_details.
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Before calling get_name_details, partyId = '||l_party_id);
      END IF;

      IF (l_party_id is not null) THEN
        IBE_WORKFLOW_PVT.get_name_details(
            p_party_id           => l_party_id,
            p_user_type          => FND_API.G_MISS_CHAR,
            x_contact_first_name => l_person_first_name,
            x_contact_last_name  => l_person_last_name,
            x_party_id           => lx_party_id);
      END IF;

      -- set the header record with all the required data.
      l_qte_header_rec.Customer_Name_And_Title := l_person_first_name ||' '||l_person_last_name;
      l_qte_header_rec.Customer_Signature_Date := sysdate;
      l_qte_header_rec.Contract_Template_Id := l_contract_template_id;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Customer Name and Title ='||l_qte_header_rec.Customer_Name_And_Title);
        IBE_Util.Debug('Customer Name and Title ='||l_qte_header_rec.Customer_Signature_Date);
        IBE_Util.Debug('Customer Name and Title ='||l_qte_header_rec.Contract_Template_Id);
        IBE_Util.Debug('Before calling new ASO Submit Quote api with Header Rec');
      END IF;

      -- Added for CC Authorization
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.Debug('l_CC_Auth_Prof = ' || l_CC_Auth_Prof);
        IBE_Util.Debug('Checking if Authorize_Credit_Card() need to be called');
      END IF;

      IF l_CC_Auth_Prof = 'Y' THEN

	  l_qte_payment_tbl := IBE_Quote_Misc_pvt.getHeaderPaymentTbl(p_quote_Header_Id);
          IF l_qte_payment_tbl.COUNT = 1 THEN
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.Debug('qte_payment_tbl(1).payment_type_code = ' || l_qte_payment_tbl(1).payment_type_code);
              END IF;
              l_payment_type_code := l_qte_payment_tbl(1).payment_type_code;
          END IF;

          open c_get_trxn_extn_id(l_qte_header_rec.quote_header_id);
          fetch c_get_trxn_extn_id into l_trxn_extension_id;
          close c_get_trxn_extn_id;

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('l_trxn_extension_id from aso_payments = '||l_trxn_extension_id);
          END IF;

          open c_get_auth_details(l_trxn_extension_id);
          fetch c_get_auth_details into l_auth_flag;
          close c_get_auth_details;

      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_trxn_extension_id Auth Flag = '||l_auth_flag);
      END IF;

      IF l_CC_Auth_Prof = 'Y' and l_auth_flag = 'N' and l_payment_type_code='CREDIT_CARD' THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('Going to call Authorize_Credit_Card');
         END IF;
         Authorize_Credit_Card(p_qte_header_id => l_qte_header_rec.quote_header_id
                               ,x_return_status         => x_return_status
                               ,x_msg_count             => x_msg_count
                               ,x_msg_data              => x_msg_data);

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('After Authorize_Credit_Card checking the returned status');
         END IF;

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('IBE_Quote_Checkout_Pvt.Authorize_Credit_Card(): Exp Error while entering the quote ');
            END IF;

            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote(): Unexp Error while entering the quote ');
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('After Authorize_Credit_Card');
      END IF;

      ASO_Quote_Pub.Submit_quote(
         P_Api_Version_Number     => p_api_version_number
         ,P_Init_Msg_List         => FND_API.G_TRUE
         ,P_Commit                => FND_API.G_FALSE
         ,p_control_rec           => l_submit_control_rec
         ,P_Qte_Header_Rec        => l_qte_header_rec
         ,x_order_header_rec      => x_Order_Header_Rec
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote() New api with Header Rec finishes, x_Order_Header_Rec.header_id '||x_Order_Header_Rec.ORDER_header_id);
      END IF;
   ELSE
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote() starts');
     END IF;


  --CC Authorization when OKC_ENABLE_SALES_CONTRACTS is no starts
  IF l_CC_Auth_Prof = 'Y' THEN
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	  IBE_Util.Debug('Credit card authorization when OKC profile isset to no starts');
       END IF;
  l_qte_payment_tbl := IBE_Quote_Misc_pvt.getHeaderPaymentTbl(p_quote_Header_Id);
       IF l_qte_payment_tbl.COUNT = 1 THEN
	   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	      IBE_UTIL.Debug('Else: qte_payment_tbl(1).payment_type_code = ' || l_qte_payment_tbl(1).payment_type_code);
	   END IF;
	   l_payment_type_code := l_qte_payment_tbl(1).payment_type_code;
       END IF;

       open c_get_trxn_extn_id(l_qte_header_rec.quote_header_id);
       fetch c_get_trxn_extn_id into l_trxn_extension_id;
       close c_get_trxn_extn_id;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	 IBE_Util.Debug('Else:l_trxn_extension_id from aso_payments = '||l_trxn_extension_id);
       END IF;

       open c_get_auth_details(l_trxn_extension_id);
       fetch c_get_auth_details into l_auth_flag;
       close c_get_auth_details;

   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Else : l_trxn_extension_id Auth Flag = '||l_auth_flag);
   END IF;

   IF l_CC_Auth_Prof = 'Y' and l_auth_flag = 'N' and l_payment_type_code='CREDIT_CARD' THEN

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	 IBE_Util.Debug('Going to call Authorize_Credit_Card');
      END IF;
      Authorize_Credit_Card(p_qte_header_id => l_qte_header_rec.quote_header_id
			    ,x_return_status         => x_return_status
			    ,x_msg_count             => x_msg_count
			    ,x_msg_data              => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	 IBE_Util.Debug('Else:After Authorize_Credit_Card checking the returned status');
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	   IBE_Util.Debug('Else:IBE_Quote_Checkout_Pvt.Authorize_Credit_Card(): Exp Error while entering the quote ');
	 END IF;

	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	   IBE_Util.Debug('Else:ASO_Quote_Pub.Submit_Quote(): Unexp Error while entering the quote ');
	 END IF;

	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	IBE_Util.Debug('Else:After Authorize_Credit_Card');
   END IF;

   --CC Authorization when OKC_ENABLE_SALES_CONTRACTS is no ends



     ASO_Quote_Pub.Submit_Quote(
        p_api_version_number    => p_api_version_number
       ,p_Init_Msg_List         => FND_API.G_TRUE
       ,p_control_rec           => l_submit_control_rec
       ,p_Qte_Header_Id         => l_qte_header_rec.quote_header_id
       ,x_order_header_rec      => x_Order_Header_Rec
       ,x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote() finishes x_Order_Header_Rec.header_id '||x_Order_Header_Rec.ORDER_header_id);
      END IF;
   END IF;
   l_msg_data      := x_msg_data;
   l_msg_count     := x_msg_count;
   l_return_status := x_return_status;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote(): Error in submit quote');
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      IF ( l_submit_control_rec.book_flag = FND_API.G_TRUE
         AND FND_PROFILE.VALUE('IBE_ENTER_ORDER_ON_ERROR') = 'Y')
      THEN
--         l_submit_control_rec := p_submit_control_rec;
         l_submit_control_rec.book_flag := fnd_api.g_false;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote() after book failure starts');
         END IF;

         ASO_Quote_Pub.Submit_Quote(
            p_api_version_number    => p_api_version_number
           ,p_Init_Msg_List         => FND_API.G_TRUE
           ,p_control_rec           => l_submit_control_rec
           ,p_Qte_Header_Id         => l_qte_header_rec.quote_header_id
           ,x_order_header_rec      => x_Order_Header_Rec
           ,x_return_status         => x_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data);

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote() after book failure finishes x_Order_Header_Rec.header_id '||x_Order_Header_Rec.ORDER_header_id);
         END IF;

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN  -- bug 12754581, scnagara
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote(): Exp Error while entering the quote ');
           END IF;

           RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote(): Unexp Error while entering the quote ');
           END IF;

           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('ASO_Quote_Pub.Submit_Quote(): Error in submit quote');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -------------------------------------------------------------------------------------
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('submitQuote: Calling oe_holds_pub.check_holds with header id '||x_Order_Header_Rec.ORDER_HEADER_ID);
   END IF;

   oe_holds_pub.check_holds(p_api_version    => 1
                           ,p_header_id      => x_Order_Header_Rec.ORDER_HEADER_ID
                           ,x_result_out     => l_hold_flag
                           ,x_return_status  => x_return_status
                           ,x_msg_count      => x_msg_count
                           ,x_msg_data       => x_msg_data);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('submitQuote: oe_holds_pub.check_holds has returned with an error '||x_msg_data);
    END IF;

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('submitQuote: oe_holds_pub.check_holds has returned with an error '||x_msg_data);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_hold_flag := l_hold_flag;

   -------------------------------------------------------------------------------------

  IBE_QUOTE_SAVESHARE_V2_PVT.stop_sharing (
      p_quote_header_id => p_quote_header_id    ,
      p_delete_context  => 'IBE_SC_CART_ORDERED',
      P_minisite_id     => p_minisite_id        ,
      p_api_version     => p_api_version_number ,
      p_init_msg_list   => fnd_api.g_false      ,
      p_commit          => fnd_api.g_false      ,
      x_return_status   => x_return_status      ,
      x_msg_count       => x_msg_count          ,
      x_msg_data        => x_msg_data           );


  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


   IF p_reason_code <> FND_API.G_MISS_CHAR
   AND p_reason_code IS NOT NULL THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('IBE_Workflow_Pvt.NotifyForSalesAssistance() starts');
      END IF;

      IBE_Workflow_Pvt.NotifyForSalesAssistance(
         p_api_version         => p_api_version_number
        ,p_init_msg_list      => FND_API.G_TRUE
        ,p_quote_id           => l_qte_header_rec.quote_header_id
        ,p_customer_comments  => p_customer_comments
        ,p_reason_code        => p_reason_code
        ,p_salesrep_email_id  => p_salesrep_email_id
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('IBE_Workflow_Pvt.NotifyForSalesAssistance() finishes');
      END IF;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   ELSE

  		/*This part is to bock notifications for application in maintenance mode(High Availability)*/
		/*If the state of application is among 2,3,4,5 then notifications are disabled*/
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		IBE_Util.Debug('JTF_HA_STATE_PKG.Get_Current_state begins');
		END IF;

		JTF_HA_STATE_PKG.Get_Current_state(x_current_state => l_current_state,
                                           x_return_status => x_return_status);

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		IBE_Util.Debug('JTF_HA_STATE_PKG.Get_Current_state finishes');
		END IF;
		IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        	RAISE FND_API.G_EXC_ERROR;
	    END IF;

      	IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      	END IF;
  		IF(l_current_state NOT IN (2,3,4,5)) THEN

			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			IBE_Util.Debug('IBE_Workflow_Pvt.NotifyOrderStatus() starts');
			END IF;
			/*This part is a fix for sending notifications to sharee*/
			IF (p_sharee_party_id  = fnd_api.g_miss_num  OR p_sharee_party_id  IS NULL) THEN
				IBE_Workflow_Pvt.NotifyOrderStatus(
   		      	p_api_version        => p_api_version_number
	    	   ,p_init_msg_list      => FND_API.G_TRUE
 	    	   ,p_quote_id           => l_qte_header_rec.quote_header_id
  	    	   ,p_status             => l_return_status
   	    	   ,p_errmsg_count       => l_msg_count
    	  	   ,p_errmsg_data        => l_msg_data
  		   	   ,x_return_status      => x_return_status
           	   ,x_msg_count          => x_msg_count
           	   ,x_msg_data           => x_msg_data);

			ELSE
				/*Sharee is present*/
				IBE_Workflow_Pvt.NotifyOrderStatus(
   		      	p_api_version        => p_api_version_number
	    	   ,p_init_msg_list      => FND_API.G_TRUE
 	    	   ,p_quote_id           => l_qte_header_rec.quote_header_id
  	    	   ,p_status             => l_return_status
   	    	   ,p_errmsg_count       => l_msg_count
    	   	   ,p_errmsg_data        => l_msg_data
  		   	   ,p_sharee_partyId     => p_sharee_party_Id
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data);

  			END IF;

               /* Book Order Error - Enter Order Success should notify user */
               IF (l_return_status = 'E' and x_return_status = 'S') THEN
                    IBE_Workflow_Pvt.NotifyOrderStatus(
                     p_api_version        => p_api_version_number
                    ,p_init_msg_list      => FND_API.G_TRUE
                    ,p_quote_id           => l_qte_header_rec.quote_header_id
                    ,p_status             => 'S'
                    ,p_errmsg_count       => l_msg_count
                    ,p_errmsg_data        => l_msg_data
                    ,x_return_status      => x_return_status
                    ,x_msg_count          => x_msg_count
                    ,x_msg_data           => x_msg_data);
               END IF;


		END IF;--for l_current_state(HA)
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('IBE_Workflow_Pvt.NotifyOrderStatus() finishes');
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End   IBE_Quote_Checkout_Pvt.SubmitQuote()');
   END IF;
   --ibe_util.disable_debug;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Expected exception in IBE_Quote_Checkout_Pvt.SubmitQuote');
     END IF;
      ROLLBACK TO SUBMITQUOTE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unexpected exception in IBE_Quote_Checkout_Pvt.SubmitQuote');
     END IF;

      ROLLBACK TO SUBMITQUOTE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unknown exception in IBE_Quote_Checkout_Pvt.SubmitQuote');
     END IF;

       ROLLBACK TO SUBMITQUOTE_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
END SubmitQuote;
END IBE_Quote_Checkout_Pvt;

/
