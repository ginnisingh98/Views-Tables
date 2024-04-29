--------------------------------------------------------
--  DDL for Package Body IBE_PAYMENT_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PAYMENT_INT_PVT" as
/* $Header: IBEVPINB.pls 120.16.12010000.3 2009/12/03 11:09:11 scnagara ship $ */
-- Start of Comments
-- Package name     : IBE_Quote_Checkout_Pvt
-- Purpose	    :
-- NOTE 	    :

-- End of Comments


l_true VARCHAR2(1)                := FND_API.G_TRUE;
G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_PAYMENT_INT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'IBEVPMTB.pls';
l_debugon VARCHAR2(1)             := IBE_UTIL.G_DEBUGON;

procedure save_credit_card
(p_api_version           IN Number
,p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE
,p_commit                IN VARCHAR2 := FND_API.G_FALSE
,p_operation_code        IN VARCHAR2
,p_credit_card_id        IN NUMBER
,p_assignment_id         IN NUMBER
,p_currency_code         IN VARCHAR2
,p_credit_card_num       IN VARCHAR2
,p_card_holder_name      IN VARCHAR2
,p_exp_date              IN DATE
,p_credit_card_type_code IN VARCHAR2
,p_party_id              IN NUMBER
,p_cust_id               IN NUMBER
,p_statement_address_id  IN NUMBER := FND_API.G_MISS_NUM
,x_credit_card_id        OUT NOCOPY NUMBER
,x_assignment_id         OUT NOCOPY NUMBER
,x_return_status         OUT NOCOPY  VARCHAR2
,x_msg_count             OUT NOCOPY  NUMBER
,x_msg_data              OUT NOCOPY  VARCHAR2 )    is


l_api_name             CONSTANT VARCHAR2(30) := 'save_credit_card';
l_api_version          CONSTANT NUMBER       := 1.0;
l_trxn_date            DATE := sysdate;
l_site_use_id          NUMBER := NULL;
l_credit_card_id 	   NUMBER;
new_credit_card_id     NUMBER;
l_username		       VARCHAR2(100);
l_bank_account_uses_id NUMBER;
lx_response            IBY_FNDCPT_COMMON_PUB.Result_Rec_Type;
l_payer                IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_card_instrument      IBY_FNDCPT_SETUP_PUB.CreditCard_Rec_Type;
l_PmtInstrument        IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
l_assignment_attr      IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
lx_assign_id           NUMBER;
l_order_of_preference  NUMBER;
l_primary_card_present NUMBER;
l_location_party_id    NUMBER;
l_location_id          NUMBER;
l_location             HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
l_party_site           HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
lx_msg_data            VARCHAR2(2100);
l_billing_address_id   NUMBER;
l_oneclick_id          NUMBER :=  FND_API.G_MISS_NUM;
l_enabled_flag         VARCHAR2(1) :=  'N';
l_oneclick_enabled     VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IBE_USE_ONE_CLICK'),'Y');

cursor c_check_address_owner(c_party_site_id NUMBER) is
  select location_id, party_id
  from   hz_party_sites
  where  party_site_id = c_party_site_id;
Cursor c_get_oneclick_settings(c_party_id IN NUMBER,
                               c_cust_id IN NUMBER) is

  select ord_oneclick_id, enabled_flag
   from ibe_ord_oneclick
   where party_id = c_party_id and cust_account_id = c_cust_id;

rec_check_address_owner c_check_address_owner%rowtype;


BEGIN
  --IBE_UTIL.enable_debug();
  IF (l_debugon = l_true) THEN
     IBE_UTIL.debug('enter IBE_PAYMENT_INT_PVT.save_credit_card');
  END IF;
  -- standard start of API savepoint
  SAVEPOINT save_credit_card;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
    -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--8529175
  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('save_credit_card : Input parameters' );
    IBE_UTIL.debug('save_credit_card : p_operation_code '||p_operation_code );
    IBE_UTIL.debug('save_credit_card : p_credit_card_id '||p_credit_card_id );
    IBE_UTIL.debug('save_credit_card : p_assignment_id '||p_assignment_id );
    IBE_UTIL.debug('save_credit_card : p_currency_code '||p_currency_code );
 -- IBE_UTIL.debug('save_credit_card : p_credit_card_type_code '||p_credit_card_type_code );  -- bug 9169370, scnagara
    IBE_UTIL.debug('save_credit_card : p_party_id '||p_party_id );
    IBE_UTIL.debug('save_credit_card : p_cust_id '||p_cust_id );
    IBE_UTIL.debug('save_credit_card : p_statement_address_id '||p_statement_address_id );
   END IF;

  IF (l_debugon = l_true) THEN
     IBE_UTIL.debug('call process_credit_card - setup recStructs');
  END IF;

---------- calling IBY api: START ----------------------------------------------
     -- *.  Need to make sure that IBY takes in Gmiss values
-- 1.  CC Record
if  (p_operation_code = 'CREATE') then
  l_card_instrument.card_id          := NULL;

else
  l_card_instrument.card_id            := p_credit_card_id;

  /*CreditCard_rec_type IS RECORD
     (
     Card_Id                NUMBER,
     Owner_Id               NUMBER,
     Card_Holder_Name       VARCHAR2(80),
     Billing_Address_Id     NUMBER,
     Billing_Postal_Code    VARCHAR2(50),
     Billing_Address_Territory VARCHAR2(2),
     Card_Number            VARCHAR2(30),
     Expiration_Date        DATE,
     Instrument_Type        VARCHAR2(30),
     PurchaseCard_Flag      VARCHAR2(1),
     PurchaseCard_SubType   VARCHAR2(30),
     Card_Issuer            VARCHAR2(30),
     FI_Name                VARCHAR2(80),
     Single_Use_Flag        VARCHAR2(1),
     Info_Only_Flag         VARCHAR2(1),
     Card_Purpose           VARCHAR2(30),
     Card_Description       VARCHAR2(240),
     Active_Flag            VARCHAR2(1),
     Inactive_Date          DATE
     );*/
end if;

l_card_instrument.owner_id                := p_party_id;

FOR rec_check_address_owner in c_check_address_owner(p_statement_address_id) LOOP
  l_location_id       := rec_check_address_owner.location_id;
  l_location_party_id := rec_check_address_owner.party_id;
  EXIT when c_check_address_owner%NOTFOUND;
END LOOP;

IF (l_debugon = l_true) THEN
  IBE_UTIL.debug('Save_Credit_card: l_location_id from cursor '||l_location_id);
  IBE_UTIL.debug('Save_Credit_card:l_location_party_id from cursor '||l_location_party_id);
END IF;

IF (p_party_id <> l_location_party_id) THEN

  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('Save_Credit_card: Input party id and location party id do not match');
  END IF;

  l_location.location_id            := l_location_id;
  l_location.address_effective_date := sysdate;

  l_party_site.party_id          := p_party_id;
  l_party_site.location_id       := l_location_id;
  l_party_site.status            := 'A';
  l_party_site.created_by_module := 'USER PROFILE';

  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('Save_Credit_card: Ready to call IBE_ADDRESS_V2PVT.create_address');
  END IF;


  /*IBE_ADDRESS_V2PVT.create_address(
    p_api_version    => 1.0
   ,p_location       => l_location
   ,p_party_site     => l_party_site
   ,x_return_status  => x_return_status
   ,x_msg_count      => x_msg_count
   ,x_msg_data       => x_msg_data
   ,x_location_id    => l_location_id
   ,x_party_site_id  => l_card_instrument.billing_address_id);*/

  IBE_ADDRESS_V2PVT.copy_party_site (
    p_api_version    => 1.0
    ,p_init_msg_list => FND_API.G_FALSE
    ,p_commit        => FND_API.G_FALSE
    ,p_party_site    => l_party_site
    ,p_location      => l_location
    ,x_party_site_id => l_billing_address_id
    ,x_return_status => x_return_status
    ,x_msg_count     => x_msg_count
    ,x_msg_data      => x_msg_data);

  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('Save_Credit_card: Done calling IBE_ADDRESS_V2PVT.create_address: x_return_status '||x_return_status);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('Save_Credit_card: Done calling IBE_ADDRESS_V2PVT.create_address: No error');
    IBE_UTIL.debug('Save_Credit_card: Done calling IBE_ADDRESS_V2PVT.create_address: new billing_address_id '||l_billing_address_id);
  END IF;

  l_card_instrument.billing_address_id := l_billing_address_id;

ELSE

  l_card_instrument.billing_address_id      := p_statement_address_id;
  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('Save_Credit_card: Party ids match');
  END IF;

END IF;

l_card_instrument.card_number             := p_credit_card_num;
l_card_instrument.expiration_date         := p_exp_date;
l_card_instrument.instrument_type         := 'CREDITCARD';
l_card_instrument.purchasecard_subtype    := NULL;
l_card_instrument.card_issuer             := p_credit_card_type_code;
l_card_instrument.Card_Holder_Name        := p_card_holder_name;
l_card_instrument.single_use_flag         :=  'N';
--l_card_instrument.info_only_flag        :=  <OPTIONAL>;
--l_card_instrument.card_purpose          := <OPTIONAL>;
--l_card_instrument.card_description      := <OPTIONAL>;


if (p_operation_code = 'UPDATE') then
  l_card_instrument.expiration_date       := p_exp_date;
end if;

if (p_operation_code = 'DELETE') then
  l_card_instrument.inactive_date         := SYSDATE;
end if;

-- 2. Payers
l_payer.Payment_Function                  := 'CUSTOMER_PAYMENT';
l_payer.Party_Id                          := p_party_id;
--l_payer.Org_Type                        := <OPTIONAL>;
--l_payer.Org_Id                          := <OPTIONAL>;
--l_payer.Cust_Account_Id                 := <OPTIONAL>;
--l_payer.Account_Site_Id                 := <OPTIONAL>;

-- 3.  Pmt Instruments
if  (p_operation_code = 'CREATE' or p_operation_code = 'CREATE_AND_SET_PRIMARY') then
  l_PmtInstrument.Instrument_Type         :='CREDITCARD';
  l_PmtInstrument.Instrument_Id           := null;
end if;

-- 4.  CC Assignment
if  (p_operation_code = 'CREATE' or p_operation_code = 'CREATE_AND_SET_PRIMARY') then
  l_assignment_attr.Assignment_Id         := NULL;
  l_assignment_attr.Instrument            := l_PmtInstrument;
  l_assignment_attr.Start_Date            := sysdate;


  select count(*) into l_primary_card_present
  from IBY_FNDCPT_PAYER_ASSGN_INSTR_V
  where party_id = p_party_id
  and order_of_preference = 1
  and cust_account_id is null
  and org_id is null
  and acct_site_use_id is null
  and instrument_type = 'CREDITCARD'
  and payment_function = 'CUSTOMER_PAYMENT'
  and card_number is not null;

  IF (l_primary_card_present >= 1) THEN

    select nvl(max(order_of_preference),0)+1 into l_order_of_preference
    from IBY_FNDCPT_PAYER_ASSGN_INSTR_V
    where party_id = p_party_id
    and cust_account_id is null
    and org_id is null
    and acct_site_use_id is null
    and instrument_type = 'CREDITCARD'
    and payment_function = 'CUSTOMER_PAYMENT'
    and card_number is not null;

    l_assignment_attr.Priority              := l_order_of_preference;
  ELSE
    l_assignment_attr.Priority              := 1;

  END IF;


/*  select nvl(max(order_of_preference),0)+1 into l_order_of_preference
  from IBY_FNDCPT_PAYER_ASSGN_INSTR_V
  where party_id = p_party_id;

  l_assignment_attr.Priority              := l_order_of_preference;*/

  if ( p_operation_code = 'CREATE_AND_SET_PRIMARY') then
    l_assignment_attr.Priority            := 1;
  end if;

else
  l_assignment_attr.Assignment_Id         := p_assignment_id;
end if;

if (p_operation_code = 'SETPRIMARY') then
  l_assignment_attr.Priority              := 1;
  l_assignment_attr.assignment_id         := p_assignment_id;

  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('SaveCC: Set primary opration: l_assignment_attr.assignment_id '||l_assignment_attr.assignment_id);
    IBE_UTIL.debug('call IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment - before calling api');
  END IF;


  IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment (
        p_api_version          => p_api_version
        ,p_init_msg_list       => p_init_msg_list
        ,p_commit              => p_commit
        ,x_return_status       => x_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
        ,p_payer               => l_payer
        ,p_assignment_attribs  => l_assignment_attr
        ,x_assign_id           => lx_assign_id
        ,x_response            => lx_response );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('call IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment - after calling api');
  END IF;

end if;

IF (l_debugon = l_true) THEN
  IBE_UTIL.debug('call process_credit_card - before calling api');
END IF;

if (p_operation_code = 'CREATE_AND_SET_PRIMARY' or p_operation_code = 'CREATE' ) then

      IBY_FNDCPT_SETUP_PUB.process_credit_card (
            p_api_version          => p_api_version
            ,p_init_msg_list       => p_init_msg_list
            ,p_commit              => p_commit
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
            ,p_payer               => l_payer
            ,p_credit_card         => l_card_instrument
            ,p_assignment_attribs  => l_assignment_attr
            ,x_assign_id           => lx_assign_id
            ,x_response            => lx_response );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        IF (l_debugon = l_true) THEN
          IBE_UTIL.debug('call process_credit_card - Expected error');
          IBE_UTIL.debug('call process_credit_card - Expected error: '||lx_response.Result_Code);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF (l_debugon = l_true) THEN
          IBE_UTIL.debug('call process_credit_card - UnExpected error');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
	 x_assignment_id := lx_assign_id;
end if;
if (p_operation_code = 'UPDATE' or p_operation_code = 'DELETE') then

  IBY_FNDCPT_SETUP_PUB.Update_Card(
             p_api_version      => p_api_version
            ,p_init_msg_list    => p_init_msg_list
            ,p_commit           => p_commit
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data
            ,p_card_instrument  => l_card_instrument
            ,x_response         => lx_response);


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- We need to call the Experss Checkout api to check if the Express Chkout CC is the same
      -- as the one deleted. If so, disable the Express Chkout

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('p_operation_code   :'||p_operation_code);
        ibe_util.debug('l_oneclick_enabled :'||l_oneclick_enabled);
        ibe_util.debug('p_party_id         :'||p_party_id);
        ibe_util.debug('p_cust_id          :'||p_cust_id);
      END IF;

      if l_oneclick_enabled = 'Y' and p_operation_code = 'DELETE' then

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('Entering the loop   :'||p_operation_code);
          END IF;

          OPEN c_get_oneclick_settings(p_party_id, p_cust_id);
          FETCH c_get_oneclick_settings
           INTO
             l_oneclick_id,
             l_enabled_flag;

          if c_get_oneclick_settings%NOTFOUND then
             l_oneclick_id := FND_API.g_miss_num;
          end if;
          CLOSE c_get_oneclick_settings;

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             ibe_util.debug('l_oneclick_id           :'||l_oneclick_id);
             ibe_util.debug('l_enabled_flag          :'||l_enabled_flag);
          END IF;

          IF l_oneclick_id <> FND_API.g_miss_num and l_enabled_flag = 'Y' then
             IF (l_debugon = l_true) THEN
                IBE_UTIL.debug('call process_credit_card - Going to call ibe_ord_oneclick_pvt.Update_Settings()');
                IBE_UTIL.debug('call process_credit_card - p_party_id ' ||p_party_id);
                IBE_UTIL.debug('call process_credit_card - p_cust_id '||p_cust_id);
                IBE_UTIL.debug('call process_credit_card - p_assignment_id'||l_assignment_attr.Assignment_Id);
             END IF;

             ibe_ord_oneclick_pvt.Update_Settings(
               p_api_version      => p_api_version
              ,p_init_msg_list    => p_init_msg_list
              ,p_commit           => p_commit
              ,x_return_status    => x_return_status
              ,x_msg_count        => x_msg_count
              ,x_msg_data         => x_msg_data
              ,p_party_id         => p_party_id
              ,p_acct_id          => p_cust_id
              ,p_assignment_id    => l_assignment_attr.Assignment_Id);

             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;
      END IF;  --l_oneclick_enabled
end if;

IF FND_API.to_boolean(p_commit) THEN
  commit;
END IF;

  -- standard call to get message count and if count is 1, get message info
FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data => x_msg_data  );

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
    -- IBE_UTIL.enable_debug();
     ROLLBACK TO save_credit_card;
     IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
     END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Add;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   for k in 1..x_msg_count loop
     lx_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                   p_encoded => 'F');
     IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('Error msg: '||substr(lx_msg_data,1,240));
     END IF;
   end loop;

    IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;
    --IBE_UTIL.disable_debug();
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --IBE_UTIL.enable_debug();
     ROLLBACK TO save_credit_card;

     IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('G_UNEXC_ERROR exception');
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Add;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');
    IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('G_EXC_UNEXPECTED_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;
    --IBE_UTIL.disable_debug();
    WHEN OTHERS THEN
    --IBE_UTIL.enable_debug();
     ROLLBACK TO save_credit_card;
     IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('Others exception');
     END IF;

     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count   =>  x_msg_count,
                               p_data    =>  x_msg_data,
                               p_encoded =>  'F');
     --bug 2617273
     --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('outside -20001 error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('outside -20001 error text : '|| SQLERRM);
    END IF;
    IF (l_debugon = l_true) THEN
      IBE_UTIL.debug('OTHER exception');
      IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
      IBE_UTIL.debug('x_msg_data ' || x_msg_data);
      IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
      IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;
    --IBE_UTIL.disable_debug();

END save_credit_card;

PROCEDURE check_Payment_channel_setups(
 p_api_version              IN Number
,p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE
,p_commit                  IN VARCHAR2 := FND_API.G_FALSE
,x_cvv2_setup              OUT NOCOPY  VARCHAR2
,x_statement_address_setup OUT NOCOPY  VARCHAR2
,x_return_status           OUT NOCOPY  VARCHAR2
,x_msg_count               OUT NOCOPY  NUMBER
,x_msg_data                OUT NOCOPY  VARCHAR2 ) is

lx_channel_attrib_uses IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;
l_api_name             CONSTANT VARCHAR2(30) := 'save_credit_card';
l_api_version          CONSTANT NUMBER       := 1.0;
l_return_status        VARCHAR2(2000);
l_cvv2_status          VARCHAR2(1);
l_msg_count            NUMBER(10);
l_msg_data             VARCHAR2(2000);
l_result_rec_type      IBY_FNDCPT_COMMON_PUB.Result_rec_type;
BEGIN
  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('check_Payment_channel_setups: Begin ');
  END IF;

  IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs(
					p_api_version         => l_api_version,
					x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
					x_msg_data            => l_msg_data,
					p_channel_code        => 'CREDIT_CARD',
                    x_channel_attrib_uses => lx_channel_attrib_uses,
					x_response            => l_result_rec_type);

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('check_Payment_channel_setups:lx_channel_attrib_uses.Instr_SecCode_Use  '||lx_channel_attrib_uses.Instr_SecCode_Use);
  END IF;

  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('check_Payment_channel_setups:lx_channel_attrib_uses.Instr_Billing_Address  '||lx_channel_attrib_uses.Instr_Billing_Address);
  END IF;


  IF(lx_channel_attrib_uses.Instr_SecCode_Use = 'REQUIRED') then
    x_cvv2_setup := FND_API.G_TRUE;

  ELSIF(lx_channel_attrib_uses.Instr_SecCode_Use = 'OPTIONAL') then
    x_cvv2_setup := FND_API.G_FALSE;
  END IF;

  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('check_Payment_channel_setups: lx_channel_attrib_uses.Instr_SecCode_Use '||lx_channel_attrib_uses.Instr_SecCode_Use);
    IBE_UTIL.debug('check_Payment_channel_setups: x_cvv2_status '||x_cvv2_setup);
  END IF;

  IF(lx_channel_attrib_uses.Instr_Billing_Address = 'REQUIRED') then
    x_statement_address_setup := FND_API.G_TRUE;
  ELSIF(lx_channel_attrib_uses.Instr_Billing_Address = 'OPTIONAL') then
    x_statement_address_setup := FND_API.G_FALSE;
  END IF;

  IF (l_debugon = l_true) THEN
    IBE_UTIL.debug('check_Payment_channel_setups: lx_channel_attrib_uses.Instr_Billing_Address '||lx_channel_attrib_uses.Instr_Billing_Address);
    IBE_UTIL.debug('check_Payment_channel_setups: x_statement_address_setup '||x_statement_address_setup);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;
    --IBE_UTIL.disable_debug();
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('G_EXC_UNEXPECTED_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;
    --IBE_UTIL.disable_debug();
    WHEN OTHERS THEN
     IF (l_debugon = l_true) THEN
        IBE_UTIL.debug('outside -20001 error code : '|| to_char(SQLCODE));
        IBE_UTIL.debug('outside -20001 error text : '|| SQLERRM);
     END IF;
    IF (l_debugon = l_true) THEN
       IBE_UTIL.debug('OTHER exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;
END check_Payment_channel_setups;

PROCEDURE print_debug_log(p_debug_str IN VARCHAR2)	IS

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_str);
    IBE_UTIL.debug(p_debug_str);

END print_Debug_Log;

PROCEDURE print_output(p_message IN VARCHAR2) IS
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_message);
END print_Output;


PROCEDURE mig_exp_checkout_pay_setup(errbuf        OUT NOCOPY VARCHAR2,
                                     retcode       OUT NOCOPY NUMBER,
                                     p_debug_flag  IN VARCHAR2,
                                     p_commit_size IN NUMBER)


IS
  l_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_counter NUMBER :=0;
  l_iby_debug VARCHAR2(1);
  l_assignment_id NUMBER(15);
  l_instrument_id NUMBER(15);
  l_instr_assignment_id NUMBER( 15);
  l_oneclick_payment_id    NUMBER(15);

CURSOR c_oneclick_data is
SELECT payment_id, party_id, cust_account_id, org_id
FROM     ibe_ord_oneclick_all;

CURSOR c_assignment_data(c_pmt_id NUMBER,
                         c_party_id NUMBER,
                         c_org_id NUMBER,
                         c_cust_accnt_id NUMBER) is

SELECT instr_assignment_id
FROM   IBY_FNDCPT_PAYER_ASSGN_INSTR_V
WHERE  instr_assignment_id = c_pmt_id
AND    party_id = c_party_id
AND    org_id = c_org_id
AND    cust_account_id = c_cust_accnt_id
AND    acct_site_use_id IS NULL
AND    instrument_type = 'CREDITCARD'
AND    payment_function = 'CUSTOMER_PAYMENT';

CURSOR c_instrument_data(c_pmt_id NUMBER ) is
SELECT instrument_id
FROM    IBY_UPG_INSTRUMENTS
WHERE bank_account_id = c_pmt_id
and rownum <2 ;

CURSOR c_assignment_for_instrument(c_instr_id NUMBER, c_party_id NUMBER, c_org_id NUMBER, c_cust_accnt_id NUMBER ) is
SELECT instr_assignment_id
FROM   IBY_FNDCPT_PAYER_ASSGN_INSTR_V
WHERE  instrument_id = c_instr_id
AND    party_id = c_party_id
AND    cust_account_id = c_cust_accnt_id
AND    org_id = c_org_id
AND    acct_site_use_id IS NULL;

rec_oneclick_data             c_oneclick_data%rowtype;
rec_assignment_data           c_assignment_data%rowtype;
rec_instrument_data           c_instrument_data%rowtype;
rec_assignment_for_instrument c_assignment_for_instrument%rowtype;

BEGIN

/*IF p_debug_flag = 'Y' THEN
  IBE_PAYMENT_INT_PVT.g_debug := p_debug_flag;

END IF;*/
l_iby_debug := p_debug_flag;
-- logging statements
IF l_iby_debug = 'T' THEN
  print_debug_log('Parameter list:');
  print_debug_log('  p_commit_size = '||p_commit_size);
  print_debug_log('  start_time = ' ||to_char(sysdate,'DD-MON-RRRR HH24:MI:SS'));
END IF;
--l_msg_data populated with different event points

-- IBE_ORD_ONECLICK_ALL table currently stores the express checkout preferences. The preferred credit card is
-- stored in the column payment_id. Going forward this column will store the assignment_id.
--1. Cursor query to retrive the records in the one click table

FOR rec_oneclick_data in c_oneclick_data LOOP

--2. Loop on the cursor query above.
  l_oneclick_payment_id := rec_oneclick_data.payment_id;
  IF l_iby_debug = 't' THEN
    print_debug_log('Dealing with dataset party_id: '||rec_oneclick_data.party_id);
    print_debug_log('Dealing with dataset org_id: '||rec_oneclick_data.org_id);
    print_debug_log('Dealing with dataset cust_account_id: '||rec_oneclick_data.cust_account_id);
  END IF;

--Program should be re-runnable

--a) Check if there exists a record in the assignment table with the same value of payment_id
--for the above party, account and org. If so, then this is already migrated data
--and we should skip it
  IF l_iby_debug = 'T' THEN
    print_debug_log('Trying to see if we have an assignment already for the record in oneclick_all');
  END IF;
  FOR rec_assignment_data in c_assignment_data(rec_oneclick_data.payment_id,
                                               rec_oneclick_data.party_id,
                                               rec_oneclick_data.org_id,
                                               rec_oneclick_data.cust_account_id) LOOP
    l_assignment_id := rec_assignment_data.instr_assignment_id;
    IF l_iby_debug = 'T' THEN
      print_debug_log('Assignment already exists for the record in oneclick_all.Assignment_id is '||l_assignment_id);
    END IF;
    EXIT when c_assignment_data%NOTFOUND;
  END LOOP;
  -- if there is a record returned above, then skip the loop
  --Otherwise
  --b) we have to also look to get the corresponding (new) credit card id from the IBY schema
  --   from the IBY Mapping table.

  IF (l_assignment_id is null) THEN

    IF l_iby_debug = 'T' THEN
      print_debug_log('No assignment present for the record in oneclick_all');
    END IF;

    FOR rec_instrument_data in c_instrument_data(rec_oneclick_data.payment_id) LOOP
      l_instrument_id := rec_instrument_data.instrument_id;
    EXIT when c_instrument_data%NOTFOUND;
    END LOOP;


--c) Next, we look at IBY_FNDCPT_PAYER_ASSGN_INSTR_V to get the corresponding assignment_id.
    FOR rec_assignment_for_instrument in c_assignment_for_instrument(l_instrument_id,
                                                                     rec_oneclick_data.party_id,
                                                                     rec_oneclick_data.cust_account_id,
                                                                     rec_oneclick_data.org_id) LOOP
      l_instr_assignment_id := rec_assignment_for_instrument.instr_assignment_id;
      EXIT when c_assignment_for_instrument%NOTFOUND;
    END LOOP;
-- if we don't get any assignment_id from the above query, we will log it in the concurrent
-- program log

--d) We will store assignment_id value for the Express Checkout Settings going forward because:
--   we eventually have to pass the assignment_id to the ASO api's to create the Express
--   Checkout cart and, using cc_id, it's difficult to derive the assignment_id because one
--   cc_id might have many rows in the IBY_pmt_instr_uses_all table
--   because it might be assigned to the party or party-acct or party-org combinations.

-- log old and new values before the update
   IF l_iby_debug = 'T' THEN
     print_debug_log('Before updating IBE_ORD_ONECLICK_ALL');
     print_debug_log('Original payment id before update: '||l_oneclick_payment_id);
     print_debug_log('New payment id(actually assignment_id) after update: '||l_instr_assignment_id);
   END IF;

    UPDATE IBE_ORD_ONECLICK_ALL
    SET PAYMENT_ID = l_instr_assignment_id
    WHERE party_id = rec_oneclick_data.party_id
    AND cust_account_id = rec_oneclick_data.cust_account_id
    AND org_id = rec_oneclick_data.org_id;

  END IF;
  EXIT when c_oneclick_data%NOTFOUND;

END LOOP; --close c_oneclick_data

--commit for every 'x' records specified by the parameter p_commit_size
l_counter := nvl(l_counter,0) + 1;
IF (mod(l_counter,nvl(p_commit_size, 2000)) = 0) THEN
  COMMIT;
END IF;

--Output success message
--print_output('<Success Message>');

retcode := 0;
errbuf := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    IF l_iby_debug = 'T' THEN
      print_debug_log('Exception occured');
      print_debug_log(l_msg_data||' '||SQLCODE||'-'||SQLERRM);
    END IF;
    print_output(l_msg_data||' '||SQLCODE||'-'||SQLERRM);
    retcode := 2;
    errbuf := l_msg_data||' '||SQLCODE||'-'||SQLERRM;
END mig_exp_checkout_pay_setup;


PROCEDURE migrate_primary_CC(errbuf OUT NOCOPY VARCHAR2,
                              retcode OUT NOCOPY NUMBER,
                              p_debug_flag IN VARCHAR2,
                              p_commit_size IN NUMBER)

IS

  CURSOR c_get_users_w_primary_cc_set  IS
  SELECT user_name, preference_value
  FROM   fnd_user_preferences
  WHERE  module_name = 'IBE'
  AND    preference_name = 'PRIMARY_CARD';

  cursor c_check_assignment_id (c_instrument_id NUMBER, c_party_id NUMBER) is
  SELECT INSTR_ASSIGNMENT_ID, order_of_preference
  FROM   IBY_FNDCPT_PAYER_ASSGN_INSTR_V
  WHERE  instrument_id = c_instrument_id
  AND    party_id = c_party_id
  AND    org_id IS NULL
  AND    cust_account_id IS NULL
  AND    acct_site_use_id IS NULL;

  cursor c_find_instr_payment_use(c_assignment_id NUMBER) is
  Select INSTRUMENT_PAYMENT_USE_ID
  from IBY_PMT_INSTR_USES_ALL
  where INSTRUMENT_PAYMENT_USE_ID = c_assignment_id;

  cursor c_check_ext_payer_id (c_party_id NUMBER) is
    select EXT_PAYER_ID
    from IBY_EXTERNAL_PAYERS_ALL
    where party_id = c_party_id
    AND  org_id IS NULL
    AND  cust_account_id IS NULL
    AND  acct_site_use_id IS NULL;


 cursor c_find_fnd_user (c_user_name VARCHAR2) is
   SELECT customer_id, person_party_id
   FROM    fnd_user
   WHERE  user_name = c_user_name;


  l_status                        VARCHAR2(1);
  l_msg_data                      VARCHAR2(2000);
  l_counter                       NUMBER :=0;
  l_instrument_id                 NUMBER(15);
  l_instrument_assignment_id      NUMBER(15);
  l_order_of_preference           NUMBER(15);
  l_customer_id                   NUMBER(15);
  l_person_party_id               NUMBER(15);
  l_party_to_use                  NUMBER(15);
  l_ext_payer_id                  NUMBER(15);
  l_ext_payer_id_verify           NUMBER(15);
  l_instrument_payment_use_id     NUMBER(15);

  rec_get_users_w_primary_cc_set  c_get_users_w_primary_cc_set%rowtype;
  rec_check_assignment_id         c_check_assignment_id%rowtype;
  rec_find_instr_payment_use      c_find_instr_payment_use%rowtype;
  rec_check_ext_payer_id          c_check_ext_payer_id%rowtype;
  rec_find_fnd_user               c_find_fnd_user%rowtype;
  --Define the global variable g_debug VARCHAR2(1) := 'N'

BEGIN
  /*IF p_debug_flag = 'Y' THEN
    IBE_PAYMENT_INT_PVT.g_debug := p_debug_flag;
  END IF;*/

-- logging statements
  IF p_debug_flag = 'T' THEN
    print_debug_log('Parameter list:');
    print_debug_log('  p_commit_size = '||p_commit_size);
    print_debug_log('  start_time = '||to_char(sysdate,'DD-MON-RRRR HH24:MI:SS'));
  END IF;
  --l_msg_data populated with different event points
  --1. Cursor query to retrieve all the iStore users who have a primary credit card setting

  --2. Loop: on the users
  FOR rec_get_users_w_primary_cc_set in c_get_users_w_primary_cc_set LOOP

  --a) Get the equivalent identifier for the credit card from the IBY mapping table
  --   (IBY_UPG_INSTRUMENTS)
    SELECT instrument_id into l_instrument_id
    FROM   IBY_UPG_INSTRUMENTS
    WHERE  bank_account_id = rec_get_users_w_primary_cc_set.preference_value
    and rownum < 2;

    IF p_debug_flag = 'T' THEN
      print_debug_log('Instrument id obtained from Upg_Instruments : '||l_instrument_id);
    END IF;


--b) Get the party_id corresponding to the fnd_user using the following query
    FOR rec_find_fnd_user in c_find_fnd_user(rec_get_users_w_primary_cc_set.user_name) LOOP

      l_customer_id     := rec_find_fnd_user.customer_id;
      l_person_party_id := rec_find_fnd_user.person_party_id;
      EXIT WHEN c_find_fnd_user%NOTFOUND;
    END LOOP;

    IF p_debug_flag = 'T' THEN
      print_debug_log('CUstomer Id and person party id from FND USER  : '||l_customer_id ||','||l_person_party_id);
    END IF;


-- If the customer_id does not have any value, use the person_party_id value instead.
    IF (l_customer_id is null) THEN
      l_party_to_use := l_person_party_id;
      IF p_debug_flag = 'T' THEN
        print_debug_log('customer_id does not have any value, using the person_party_id');
      END IF;
    ELSE
      IF p_debug_flag = 'T' THEN
        print_debug_log('customer_id has a value,l_party_to_use: '||l_customer_id);
      END IF;
      l_party_to_use := l_customer_id;
    END IF;

--c) next, use the new cc_id and the partyId to find the corresponding row in the
--   IBY_PMT_INSTR_USES_ALL table

    FOR rec_check_assignment_id in c_check_assignment_id(l_instrument_id, l_party_to_use) LOOP
      l_instrument_assignment_id := rec_check_assignment_id.instr_assignment_id;
      l_order_of_preference      := rec_check_assignment_id.order_of_preference;
      print_debug_log('l_instrument_assignment_id '||l_instrument_assignment_id);
      print_debug_log('l_order_of_preference '||l_order_of_preference);
      EXIT WHEN c_check_assignment_id%NOTFOUND;
    END LOOP;

--i) if this row exists and the order_of_preference is 1, DO NOT call the update routine
--   program should be re-runnable
--ii) if this row exists and the order_of_preference is not set to 1, update
--log the old and new values for the order_of_preference and the assignment_id
    IF( (l_instrument_assignment_id is not null) and (l_order_of_preference <> 1)) THEN

      IF p_debug_flag = 'T' THEN
        print_debug_log('Order of preference is not 1 for instr assignment id '||l_instrument_assignment_id);
      END IF;

      FOR rec_find_instr_payment_use in c_find_instr_payment_use(l_instrument_assignment_id) LOOP

        l_instrument_payment_use_id := rec_find_instr_payment_use.instrument_payment_use_id;
        EXIT WHEN c_find_instr_payment_use%NOTFOUND;
      END LOOP;

      IF(l_instrument_payment_use_id is not null) THEN

        UPDATE IBY_PMT_INSTR_USES_ALL
        SET    order_of_preference = 1
        WHERE  INSTRUMENT_PAYMENT_USE_ID = l_INSTRUMENT_PAYMENT_USE_ID;

        IF p_debug_flag = 'T' THEN
          print_debug_log('Updated IBY_PMT_INSTR_USES_ALL');
          print_debug_log('  Old value of Order_of_preference = '||l_order_of_preference);
          print_debug_log('  New value of Order_of_preference = 1');
          print_debug_log('  INSTRUMENT_PAYMENT_USE_ID Record updated:  '||l_instrument_assignment_id);
        END IF;

         UPDATE iby_pmt_instr_uses_all
         SET order_of_preference = order_of_preference + 1,
         last_updated_by =  fnd_global.user_id,
         last_update_date = SYSDATE,
         last_update_login = fnd_global.login_id,
         object_version_number = object_version_number + 1
         WHERE instrument_payment_use_id IN
         (
           SELECT instrument_payment_use_id
           FROM iby_pmt_instr_uses_all
           WHERE (ext_pmt_party_id = l_party_to_use)
           AND (payment_flow = 'FUNDS_CAPTURE')
                   START WITH order_of_preference = l_order_of_preference
                     AND (ext_pmt_party_id = l_party_to_use)
                     AND (payment_flow = 'FUNDS_CAPTURE')
                   CONNECT BY order_of_preference = PRIOR (order_of_preference + 1)
                     AND (ext_pmt_party_id = PRIOR ext_pmt_party_id)
                     AND (payment_flow = PRIOR payment_flow)                   );

      ELSE

    /*--iii) if this row does not exist, create an assignment for the partyId of the user
    --    with order_of_preference = 1 by directly inserting into IBY assignment table:
    --    IBY_PMT_INSTR_USES_ALL. A record might also need to be created in
    --    IBY_EXTERNAL_PAYERS_ALL table so that the corresponding identifer could be
    --    substitued in ext_pmt_party_id column of the iby_pmt_instr_uses all table.*/
        IF p_debug_flag = 'T' THEN
          print_debug_log('Going for direct inserts into IBY_EXTERNAL_PAYERS_ALL');
        END IF;

        FOR rec_check_ext_payer_id in c_check_ext_payer_id(l_party_to_use) LOOP

          l_EXT_PAYER_ID := rec_check_ext_payer_id.EXT_PAYER_ID;
          EXIT WHEN c_check_ext_payer_id%NOTFOUND;
        END LOOP;

        IF (l_EXT_PAYER_ID is NULL ) THEN


          select IBY_EXTERNAL_PAYERS_ALL_S.Nextval into l_ext_payer_id
          from dual;

          INSERT INTO IBY_EXTERNAL_PAYERS_ALL(
          EXT_PAYER_ID          ,
          PAYMENT_FUNCTION      ,
          PARTY_ID              ,
          CREATED_BY            ,
          CREATION_DATE         ,
          LAST_UPDATED_BY       ,
          LAST_UPDATE_DATE      ,
          LAST_UPDATE_LOGIN     ,
          OBJECT_VERSION_NUMBER )

          VALUES(
          l_ext_payer_id        ,
          'CUSTOMER_PAYMENT'    ,
          l_party_to_use        ,
          fnd_global.USER_ID    ,
          SYSDATE               ,
          fnd_global.USER_ID    ,
          SYSDATE               ,
          fnd_global.USER_ID    ,
          1                     );

          Select ext_payer_id into l_ext_payer_id_verify
          from IBY_EXTERNAL_PAYERS_ALL
          where ext_payer_id = l_ext_payer_id;

          IF p_debug_flag = 'T' THEN
            print_debug_log('Successfully inserted into IBY_EXTERNAL_PAYERS_ALL');
            print_debug_log('Record ID inserted : '||l_ext_payer_id_verify);
          END IF;



        -- if the above query returns any value, use that in the insert to  IBY_PMT_INSTR_USES_ALL
        -- as mentioned in (iii) above.
        --log the new values inserted

          IF(l_ext_payer_id_verify is not null) THEN

            IF p_debug_flag = 'T' THEN
              print_debug_log('Doing a direct insert into IBY_PMT_INSTR_USES_ALL');
            END IF;

            INSERT INTO IBY_PMT_INSTR_USES_ALL(
              INSTRUMENT_PAYMENT_USE_ID ,
              PAYMENT_FLOW              ,
              EXT_PMT_PARTY_ID          ,
              INSTRUMENT_TYPE           ,
              INSTRUMENT_ID             ,
              PAYMENT_FUNCTION          ,
              ORDER_OF_PREFERENCE       ,
              CREATED_BY                ,
              CREATION_DATE             ,
              LAST_UPDATED_BY           ,
              LAST_UPDATE_DATE          ,
              LAST_UPDATE_LOGIN         ,
              OBJECT_VERSION_NUMBER     ,
              START_DATE                )

            VALUES(
              l_instrument_assignment_id,
              'FUNDS_CAPTURE'        ,
              l_party_to_use         ,
              'CREDITCARD'           ,
              l_instrument_id        ,
              'CUSTOMER_PAYMENT'     ,
              1                      ,
              fnd_global.USER_ID     ,
              SYSDATE                ,
              fnd_global.USER_ID     ,
              SYSDATE                ,
              fnd_global.USER_ID     ,
              1                      ,
              SYSDATE                );

          END IF; --l_ext_payer_id_verify is not null

          IF p_debug_flag = 'T' THEN
            print_debug_log('Inserted a record in IBY_PMT_INSTR_USES_ALL');
            print_debug_log('Inserted a record for l_instrument_assignment_use_id '||l_instrument_assignment_id);
            print_debug_log('Inserted a record for l_instrument_id '||l_instrument_id);
          END IF;
        END IF; -- l_EXT_PAYER_ID

      END IF; --l_instrument_payment_use_id is not null

    END IF; --l_instrument_assignment_id is not null) and (l_order_of_preference <> 1
    --commit for every 'x' records specified by the parameter p_commit_size
    l_counter := nvl(l_counter,0) + 1;
    IF (mod(l_counter,nvl(p_commit_size, 2000)) = 0) THEN
      COMMIT;
    END IF;

    EXIT WHEN c_get_users_w_primary_cc_set%NOTFOUND;
  END LOOP;


--Output success message
print_debug_log('Done with all processing . Returning a success status ');

retcode := 0;
--errbuf := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    IF p_debug_flag = 'T' THEN
      print_debug_log('Exception occured');
      print_debug_log(l_msg_data||' '||SQLCODE||'-'||SQLERRM);
    END IF;
    print_output(l_msg_data||' '||SQLCODE||'-'||SQLERRM);
    retcode := 2;
    errbuf := l_msg_data||' '||SQLCODE||'-'||SQLERRM;

END migrate_primary_CC;

PROCEDURE migrate_ibe_cc_data(
p_cut_off_date date
,errbuf OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY NUMBER) is

BEGIN


  print_debug_log('IBE_PAYMENT_INT_PVT.Migrate_ibe_cc_data: Begin');

  print_debug_log('IBE_PAYMENT_INT_PVT.Migrate_ibe_cc_data: Calling mig_exp_checkout_pay_setup');


mig_exp_checkout_pay_setup
(errbuf         => errbuf
 ,retcode       => retcode
 ,p_debug_flag  => FND_API.G_TRUE
 ,p_commit_size => 2000);

  print_debug_log('IBE_PAYMENT_INT_PVT.Migrate_ibe_cc_data: Calling migrate_primary_CC');

 migrate_primary_CC
 (errbuf         =>  errbuf
 ,retcode       => retcode
 ,p_debug_flag  => FND_API.G_TRUE
 ,p_commit_size => 2000);

 print_debug_log('migrate_ibe_cc_data: Done with all processing . Returning a success status ');

EXCEPTION
WHEN OTHERS THEN
  print_debug_log('In the exception block. Need to get outta here!');
  print_debug_log(SQLCODE||'-'||SQLERRM);
  retcode := 2;
  errbuf := SQLCODE||'-'||SQLERRM;
END migrate_ibe_cc_data;

END IBE_PAYMENT_INT_PVT ;

/
