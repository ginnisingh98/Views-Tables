--------------------------------------------------------
--  DDL for Package Body IBY_DISBURSEMENT_COMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DISBURSEMENT_COMP_PUB" AS
/*$Header: ibydiscb.pls 120.30.12010000.8 2010/03/11 19:29:21 vkarlapu ship $*/

 --
 -- Declare Global variables
 --
G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
 -- User Defined Exceptions
 g_abort_program EXCEPTION;

 -- Lookups for profile applicablility types (from IBY_PMT_PROF_LOV_APL_TYPES)
 APL_TYPE_PAYER_ORG      CONSTANT VARCHAR2(100) := 'PAYER_ORG';
 -- APL_TYPE_ORG_ID         CONSTANT VARCHAR2(100) := 'PAYER_ORG_ID';
 -- APL_TYPE_ORG_TYPE       CONSTANT VARCHAR2(100) := 'PAYER_ORG_TYPE';
 APL_TYPE_PMT_METHOD     CONSTANT VARCHAR2(100) := 'PAYMENT_METHOD';
 APL_TYPE_PMT_FORMAT     CONSTANT VARCHAR2(100) := 'PAYMENT_FORMAT';
 APL_TYPE_PMT_CURRENCY   CONSTANT VARCHAR2(100) := 'CURRENCY_CODE';
 APL_TYPE_INT_BANK_ACCT  CONSTANT VARCHAR2(100) := 'INTERNAL_BANK_ACCOUNT';

 --
 -- Forward Declarations
 --
 PROCEDURE print_debuginfo(p_module IN VARCHAR2,
                           p_debug_text IN VARCHAR2);

 FUNCTION ifelse(p_bool IN BOOLEAN,
                 x_true IN VARCHAR2,
                 x_false IN VARCHAR2)
                 RETURN VARCHAR2;

 PROCEDURE evaluate_Rule_Based_Default(
                   p_trxn_attributes   IN   Trxn_Attributes_Rec_Type,
                   x_pmt_method_rec    IN OUT NOCOPY  Payment_Method_Rec_Type);


  -- Start of comments
  --   API name     : Get_Applicable_Delivery_Channels
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Delivery Channels.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_delivery_channels_tbl    OUT Delivery_Channels_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Appl_Delivery_Channels (
     p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2 default FND_API.G_FALSE,
     p_trxn_attributes_rec   IN   Trxn_Attributes_Rec_Type,
     x_return_status         OUT  NOCOPY VARCHAR2,
     x_msg_count             OUT  NOCOPY NUMBER,
     x_msg_data              OUT  NOCOPY VARCHAR2,
     x_delivery_channels_tbl OUT  NOCOPY Delivery_Channel_Tab_Type
)
IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_Applicable_Dlvry_Channels';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.Get_Applicable_Dlvry_Channels';

   l_delivery_channels_tbl    Delivery_Channel_Tab_Type;
   l_payer_country VARCHAR2(35);

   CURSOR delivery_channels_csr(p_payer_country VARCHAR2)
   IS
      SELECT delivery_channel_code,
             meaning,
             description,
             territory_code
       FROM IBY_DELIVERY_CHANNELS_VL ibydlv
       WHERE (ibydlv.territory_code = p_payer_country OR ibydlv.territory_code is NULL)
       AND   (ibydlv.inactive_date is NULL OR ibydlv.inactive_date >= trunc(sysdate));

   CURSOR payer_country_csr(p_payer_le_id NUMBER)
   IS
      SELECT xle.country
      FROM XLE_FIRSTPARTY_INFORMATION_V xle
      WHERE xle.legal_entity_id = p_payer_le_id;

BEGIN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'ENTER');
	   print_debuginfo(l_module_name,'Application_id   : '|| p_trxn_attributes_rec.application_id);
	   print_debuginfo(l_module_name,'First party LE id  : '|| p_trxn_attributes_rec.payer_legal_entity_id);

   END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_trxn_attributes_rec.payer_legal_entity_id IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''First party legal entity Id'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_1PARTY_LE_ID'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN payer_country_csr(p_trxn_attributes_rec.payer_legal_entity_id);
   FETCH payer_country_csr INTO l_payer_country;
   CLOSE payer_country_csr;

   IF (l_payer_country IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: First party legal entity country not populated.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_DATA');
      FND_MESSAGE.SET_TOKEN('PARAM', 'First party legal entity country');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN delivery_channels_csr(l_payer_country);
   FETCH delivery_channels_csr BULK COLLECT INTO l_delivery_channels_tbl;
   CLOSE delivery_channels_csr;

   IF (l_delivery_channels_tbl.COUNT = 0) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Warning: No Delivery Channels Applicable');
      END IF;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Applicable Delivery Channels Count : '|| l_delivery_channels_tbl.COUNT);
      END IF;
      x_delivery_channels_tbl := l_delivery_channels_tbl;
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');

   END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Unexpected ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Other ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

END Get_Appl_Delivery_Channels;


  -- Start of comments
  --   API name     : Get_Applicable_Payee_BankAccts
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Payee Bank Accounts.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payee_bankaccounts_tbl   OUT Payee_BankAccount_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Applicable_Payee_BankAccts (
     p_api_version               IN   NUMBER,
     p_init_msg_list             IN   VARCHAR2 default FND_API.G_FALSE,
     p_trxn_attributes_rec       IN   Trxn_Attributes_Rec_Type,
     x_return_status             OUT  NOCOPY VARCHAR2,
     x_msg_count                 OUT  NOCOPY NUMBER,
     x_msg_data                  OUT  NOCOPY VARCHAR2,
     x_payee_bankaccounts_tbl    OUT  NOCOPY Payee_BankAccount_Tab_Type
)
IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_Applicable_Payee_BankAccts';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.Get_Applicable_Payee_BankAccts';

   l_payee_bankaccounts_tbl    Payee_BankAccount_Tab_Type;

   CURSOR payee_bankacct_csr(p_payee_party_id      NUMBER,
                             p_payee_party_site_id NUMBER,
                             p_supplier_site_id    NUMBER,
                             p_payer_org_id        NUMBER,
                             p_payer_org_type      VARCHAR2,
                             p_payment_currency    VARCHAR2,
                             p_payment_function    VARCHAR2)
   IS
      SELECT DISTINCT b.bank_account_name,
             b.ext_bank_account_id,
             b.bank_account_number,
	     b.currency_code,
 	     b.iban_number,
 	     b.bank_name,
 	     b.bank_number,
 	     b.bank_branch_name,
 	     b.branch_number,
 	     b.country_code,
 	     b.alternate_account_name,
 	     b.bank_account_type,
 	     b.account_suffix,
 	     b.description,
 	     b.foreign_payment_use_flag,
 	     b.payment_factor_flag,
 	     b.eft_swift_code
      FROM   IBY_PMT_INSTR_USES_ALL ibyu,
             IBY_EXT_BANK_ACCOUNTS_V b,
             IBY_EXTERNAL_PAYEES_ALL ibypayee
      WHERE ibyu.instrument_id = b.ext_bank_account_id
      AND ibyu.instrument_type = 'BANKACCOUNT'
      AND (b.currency_code = p_payment_currency OR b.currency_code is null)
      AND ibyu.ext_pmt_party_id = ibypayee.ext_payee_id
      AND ibypayee.payment_function = p_payment_function
      AND ibypayee.payee_party_id = p_payee_party_id
      AND trunc(sysdate) between
              NVL(ibyu.start_date,trunc(sysdate)) AND NVL(ibyu.end_date-1,trunc(sysdate))
      AND trunc(sysdate) between
              NVL(b.start_date,trunc(sysdate)) AND NVL(b.end_date-1,trunc(sysdate))
      AND (ibypayee.party_site_id is null OR ibypayee.party_site_id = p_payee_party_site_id)
      AND (ibypayee.supplier_site_id is null OR ibypayee.supplier_site_id = p_supplier_site_id)
      AND (ibypayee.org_id is null OR
           (ibypayee.org_id = p_payer_org_id AND ibypayee.org_type = p_payer_org_type));

BEGIN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name,'ENTER');
	   print_debuginfo(l_module_name,'Org Id           : '|| p_trxn_attributes_rec.payer_org_id);
	   print_debuginfo(l_module_name,'Org Type         : '|| p_trxn_attributes_rec.payer_org_type);
	   print_debuginfo(l_module_name,'Payee Id         : '|| p_trxn_attributes_rec.payee_party_id);
	   print_debuginfo(l_module_name,'Payee Site Id    : '|| p_trxn_attributes_rec.payee_party_site_id);
	   print_debuginfo(l_module_name,'Supplier Site Id : '|| p_trxn_attributes_rec.supplier_site_id);
	   print_debuginfo(l_module_name,'Payment Currency : '|| p_trxn_attributes_rec.payment_currency);
	   print_debuginfo(l_module_name,'Payment Amount   : '|| p_trxn_attributes_rec.payment_amount);
	   print_debuginfo(l_module_name,'Account Usage    : '|| p_trxn_attributes_rec.payment_function);

   END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check for mandatory params
   IF (p_trxn_attributes_rec.payee_party_id IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Payee Party Id'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_PAYEE_PARTY_ID_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_trxn_attributes_rec.payment_currency IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Payment Currency'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_PMT_CURR_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_trxn_attributes_rec.payment_function IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Account Usage'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_ACCT_USG_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Start of API body.
   OPEN payee_bankacct_csr(p_trxn_attributes_rec.Payee_Party_Id,
                           p_trxn_attributes_rec.Payee_Party_Site_Id,
                           p_trxn_attributes_rec.Supplier_Site_Id,
                           p_trxn_attributes_rec.Payer_Org_Id,
                           p_trxn_attributes_rec.Payer_Org_Type,
                           p_trxn_attributes_rec.Payment_Currency,
                           p_trxn_attributes_rec.Payment_Function);

   FETCH payee_bankacct_csr BULK COLLECT INTO l_payee_bankaccounts_tbl;
   CLOSE payee_bankacct_csr;

   IF (l_payee_bankaccounts_tbl.COUNT = 0) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Warning: No Payee Bank Accounts Applicable');
      END IF;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Applicable Payee Bank Accounts Count : '|| l_payee_bankaccounts_tbl.COUNT);
      END IF;
      x_payee_bankaccounts_tbl := l_payee_bankaccounts_tbl;
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');

   END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR))
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

END Get_Applicable_Payee_BankAccts;

  -- Start of comments
  --   API name     : Get_Applicable_Payment_Formats
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Delivery Channels.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_format_tbl       OUT Payment_Format_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments
  --
  -- As the payment format of a transaction is uniquely determined by the payment profie,
  -- this procedure to get the appliable payment formats is supposed to be rarely used.

PROCEDURE Get_Applicable_Payment_Formats(
     p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2 default FND_API.G_FALSE    ,
     x_return_status       OUT  NOCOPY VARCHAR2                     ,
     x_msg_count           OUT  NOCOPY NUMBER                       ,
     x_msg_data            OUT  NOCOPY VARCHAR2                     ,
     x_payment_formats_tbl OUT  NOCOPY Payment_Format_Tab_Type
)
IS
   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_Applicable_Payment_Formats';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.Get_Applicable_Payment_Formats';

   l_payment_formats_tbl    Payment_Format_Tab_Type;

   CURSOR payment_formats_csr
   IS
      SELECT f.format_name,
             f.format_code
      FROM IBY_PAYMENT_PROFILES p,
           IBY_FORMATS_VL f,
           IBY_APPLICABLE_PMT_PROFS apf,
           IBY_APPLICABLE_PMT_PROFS apm,
           IBY_PAYMENT_METHODS_B m
      WHERE f.format_code = p.payment_format_code
      AND   apf.system_profile_code = p.system_profile_code
      AND   (apf.applicable_type_code = APL_TYPE_PMT_FORMAT AND
                 (apf.applicable_value_to = f.format_code OR
                  apf.applicable_value_to IS NULL))
      AND   apm.system_profile_code = p.system_profile_code
      AND   (m.inactive_date is null OR m.inactive_date >= trunc(sysdate))
      AND   apm.applicable_type_code = APL_TYPE_PMT_METHOD
      AND   apm.applicable_value_to = m.payment_method_code;

BEGIN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'ENTER');

   END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API body.

    OPEN payment_formats_csr();
    FETCH payment_formats_csr BULK COLLECT INTO l_payment_formats_tbl;
    CLOSE payment_formats_csr;

    IF (l_payment_formats_tbl.COUNT = 0) THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'Warning: No Payment Formats Applicable');
       END IF;
    ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'Applicable Payment Formats Count : '|| l_payment_formats_tbl.COUNT);
       END IF;
       x_payment_formats_tbl := l_payment_formats_tbl;
    END IF;

    -- End of API body.

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'RETURN');

    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR))
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

END Get_Applicable_Payment_Formats;

  -- Start of comments
  --   API name     : Get_Applicable_Payment_Methods
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Payment Methods.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_ignore_payee_prefer      IN  VARCHAR2
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_methods_tbl      OUT Payment_Method_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

  PROCEDURE Get_Applicable_Payment_Methods(
       p_api_version         IN NUMBER,
       p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_ignore_payee_prefer IN VARCHAR2,
       p_trxn_attributes_rec IN Trxn_Attributes_Rec_Type,
       x_return_status       OUT NOCOPY VARCHAR2,
       x_msg_count           OUT NOCOPY NUMBER,
       x_msg_data            OUT NOCOPY VARCHAR2,
       x_payment_methods_tbl OUT NOCOPY Payment_Method_Tab_Type)
  IS
    l_api_name           CONSTANT VARCHAR2(30)            := 'Get_Applicable_Payment_Methods';
    l_api_version        CONSTANT NUMBER                  := 1.0;
    l_module_name        CONSTANT VARCHAR2(200)           := G_PKG_NAME || '.Get_Applicable_Payment_Methods';

    l_pmtmthd_table               Payment_Method_Tab_Type;
    l_pmt_mthds_rec               Payment_Method_Rec_Type;
    l_index                       NUMBER  := 1;

    l_payer_country               VARCHAR2(30);
    l_payee_country               VARCHAR2(30);
    l_accounting_curr             VARCHAR2(30);

    l_payer_le_match              BOOLEAN;
    l_payer_org_match             BOOLEAN;
    l_trxn_type_match             BOOLEAN;
    l_currency_match              BOOLEAN;
    l_cross_border_match          BOOLEAN;
    l_match                       BOOLEAN;

    CURSOR payment_methods(p_application_id    NUMBER,
                           p_payee_party_id    NUMBER,
                           p_payee_psite_id    NUMBER,
                           p_supplier_site_id  NUMBER,
                           p_org_id            NUMBER,
                           p_org_type          VARCHAR2,
                           p_payment_function  VARCHAR2,
                           p_ignore_flag       VARCHAR2)

    IS
      SELECT m.Payment_Method_Name,
             am.PAYMENT_METHOD_CODE,
             m.SUPPORT_BILLS_PAYABLE_FLAG,
             m.MATURITY_DATE_OFFSET_DAYS,
             m.DESCRIPTION
        FROM IBY_APPLICABLE_PMT_MTHDS am,
             IBY_PAYMENT_METHODS_VL m
       WHERE am.PAYMENT_FLOW = 'DISBURSEMENTS'
         AND am.APPLICABLE_TYPE_CODE = 'PAYEE'
         AND am.APPLICABLE_VALUE_TO is null
         AND (am.APPLICATION_ID is null OR am.APPLICATION_ID = p_application_id)
         AND (m.INACTIVE_DATE is null OR m.INACTIVE_DATE >= trunc(sysdate))
         AND (am.INACTIVE_DATE is null OR am.INACTIVE_DATE >= trunc(sysdate))
         AND am.PAYMENT_METHOD_CODE = m.PAYMENT_METHOD_CODE
         AND NOT EXISTS (select 1
                          from IBY_EXT_PARTY_PMT_MTHDS ppm,
                               IBY_EXTERNAL_PAYEES_ALL payee
                         where ppm.PAYMENT_FLOW = 'DISBURSEMENTS'
                           and ppm.PAYMENT_METHOD_CODE = am.PAYMENT_METHOD_CODE
                           and ppm.PAYMENT_FUNCTION = p_payment_function
                           and ppm.INACTIVE_DATE < trunc(sysdate)
                           and ppm.EXT_PMT_PARTY_ID = payee.EXT_PAYEE_ID
                           and payee.PAYEE_PARTY_ID = p_payee_party_id
                           AND (payee.PARTY_SITE_ID is null OR payee.PARTY_SITE_ID = p_payee_psite_id)
                           AND (payee.SUPPLIER_SITE_ID is null OR payee.SUPPLIER_SITE_ID = p_supplier_site_id)
                           AND (payee.ORG_ID is null OR (payee.ORG_ID = p_org_id AND payee.ORG_TYPE = p_org_type)))
         AND p_ignore_flag = 'N'
	 AND NOT (m.SUPPORT_BILLS_PAYABLE_FLAG = 'Y' AND p_payment_function = 'AR_CUSTOMER_REFUNDS')
      UNION
      SELECT m.Payment_Method_Name,
             ppm.PAYMENT_METHOD_CODE,
             m.SUPPORT_BILLS_PAYABLE_FLAG,
             m.MATURITY_DATE_OFFSET_DAYS,
             m.DESCRIPTION
        FROM IBY_EXT_PARTY_PMT_MTHDS ppm,
             IBY_EXTERNAL_PAYEES_ALL payee,
             IBY_PAYMENT_METHODS_VL m
       WHERE ppm.PAYMENT_FLOW = 'DISBURSEMENTS'
         AND ppm.PAYMENT_FUNCTION = p_payment_function
         AND (m.INACTIVE_DATE is null OR m.INACTIVE_DATE >= trunc(sysdate))
         AND (ppm.INACTIVE_DATE is null OR ppm.INACTIVE_DATE >= trunc(sysdate))
         AND ppm.PAYMENT_METHOD_CODE = m.PAYMENT_METHOD_CODE
         AND ppm.EXT_PMT_PARTY_ID = payee.EXT_PAYEE_ID
         AND payee.PAYEE_PARTY_ID = p_payee_party_id
         AND (payee.PARTY_SITE_ID is null OR payee.PARTY_SITE_ID = p_payee_psite_id)
         AND (payee.SUPPLIER_SITE_ID is null OR payee.SUPPLIER_SITE_ID = p_supplier_site_id)
         AND (payee.ORG_ID is null OR (payee.ORG_ID = p_org_id AND payee.ORG_TYPE = p_org_type))
         AND p_ignore_flag = 'N'
	 AND NOT (m.SUPPORT_BILLS_PAYABLE_FLAG = 'Y' AND p_payment_function = 'AR_CUSTOMER_REFUNDS')
      UNION
      SELECT pmthds.Payment_Method_Name,
             pmthds.Payment_Method_Code,
             pmthds.SUPPORT_BILLS_PAYABLE_FLAG,
             pmthds.MATURITY_DATE_OFFSET_DAYS,
             pmthds.DESCRIPTION
        FROM IBY_PAYMENT_METHODS_VL pmthds
       WHERE (pmthds.inactive_date is NULL OR pmthds.inactive_date >= trunc(sysdate))
         AND NOT EXISTS (select 1
                          from IBY_EXT_PARTY_PMT_MTHDS ppm,
                               IBY_EXTERNAL_PAYEES_ALL payee
                         where ppm.PAYMENT_FLOW = 'DISBURSEMENTS'
                           and PAYMENT_METHOD_CODE = pmthds.PAYMENT_METHOD_CODE
                           and ppm.PAYMENT_FUNCTION = p_payment_function
                           and ppm.INACTIVE_DATE < trunc(sysdate)
                           and ppm.EXT_PMT_PARTY_ID = payee.EXT_PAYEE_ID
                           and payee.PAYEE_PARTY_ID = p_payee_party_id
                           AND (payee.PARTY_SITE_ID is null OR payee.PARTY_SITE_ID = p_payee_psite_id)
                           AND (payee.SUPPLIER_SITE_ID is null OR payee.SUPPLIER_SITE_ID = p_supplier_site_id)
                           AND (payee.ORG_ID is null OR (payee.ORG_ID = p_org_id AND payee.ORG_TYPE = p_org_type)))
         AND p_ignore_flag = 'Y'
	 AND NOT (pmthds.SUPPORT_BILLS_PAYABLE_FLAG = 'Y' AND p_payment_function = 'AR_CUSTOMER_REFUNDS');

    CURSOR pmthd_drivers_csr(p_payment_method_code IN VARCHAR2,
                             p_application_id IN NUMBER)
    IS
      SELECT Payment_Method_Code,
             Applicable_Type_Code,
             Applicable_Value_From,
             Applicable_Value_To
        FROM IBY_APPLICABLE_PMT_MTHDS apmthds
       WHERE apmthds.Payment_method_code = p_payment_method_code
         AND (apmthds.application_id = p_application_id
             OR apmthds.application_id is NULL);

    CURSOR payer_info_csr(p_payer_le_id IN NUMBER)
    IS
      SELECT xlev.country,
             glv.currency_code
        FROM XLE_FIRSTPARTY_INFORMATION_V xlev,
             GL_LEDGER_LE_V glv
       WHERE xlev.legal_entity_id = glv.legal_entity_id
         AND glv.ledger_category_code = 'PRIMARY'
         AND xlev.legal_entity_id = p_payer_le_id;

    CURSOR payee_country_csr(p_payee_id IN NUMBER)
    IS
      SELECT country
        FROM HZ_PARTIES
       WHERE party_id = p_payee_id;

    CURSOR payeesite_country_csr(p_payee_id IN NUMBER,
                                 p_payee_site_id IN NUMBER)
    IS
      SELECT locs.country
        FROM HZ_PARTY_SITES sites,
             HZ_LOCATIONS locs
       WHERE sites.party_id = p_payee_id
         AND sites.party_site_id = p_payee_site_id
         AND sites.location_id = locs.location_id;

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');
	    print_debuginfo(l_module_name,'Application_id   : '|| p_trxn_attributes_rec.application_id);
	    print_debuginfo(l_module_name,'1st party LE id  : '|| p_trxn_attributes_rec.payer_legal_entity_id);
	    print_debuginfo(l_module_name,'Org Id           : '|| p_trxn_attributes_rec.payer_org_id);
	    print_debuginfo(l_module_name,'Org Type         : '|| p_trxn_attributes_rec.payer_org_type);
	    print_debuginfo(l_module_name,'Payer Id         : '|| p_trxn_attributes_rec.payee_party_id);
	    print_debuginfo(l_module_name,'Payee Site Id    : '|| p_trxn_attributes_rec.payee_party_site_id);
	    print_debuginfo(l_module_name,'Supplier Site Id : '|| p_trxn_attributes_rec.supplier_site_id);
	    print_debuginfo(l_module_name,'Trxn Type Code   : '|| p_trxn_attributes_rec.pay_proc_trxn_type_code);
	    print_debuginfo(l_module_name,'Payment Currency : '|| p_trxn_attributes_rec.payment_currency);
	    print_debuginfo(l_module_name,'Payment Amount   : '|| p_trxn_attributes_rec.payment_amount);
	    print_debuginfo(l_module_name,'Account Usage    : '|| p_trxn_attributes_rec.payment_function);

    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for mandatory params
    IF (p_trxn_attributes_rec.application_id IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Application Id'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_APP_ID'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_trxn_attributes_rec.payer_legal_entity_id IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''First party legal entity Id'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_1PARTY_LE_ID'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_trxn_attributes_rec.payee_party_id IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Payee Party Id'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_PAYEE_PARTY_ID_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_trxn_attributes_rec.pay_proc_trxn_type_code IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Transaction Type Id'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_TRANS_TYPE_ID'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_trxn_attributes_rec.payment_currency IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Payment Currency'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_PMT_CURR_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_trxn_attributes_rec.payment_function IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Account Usage'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_ACCT_USG_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Fetch Accounting Currency and 1st part Payer country
    IF (p_trxn_attributes_rec.payer_legal_entity_id IS NOT NULL) THEN
       OPEN payer_info_csr(p_trxn_attributes_rec.payer_legal_entity_id);
       FETCH payer_info_csr INTO l_payer_country, l_accounting_curr;
       CLOSE payer_info_csr;
    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name,'Accounting currency : '|| l_accounting_curr);
	    print_debuginfo(l_module_name,'First party legal entity country : '|| l_payer_country);

    END IF;
    IF (p_trxn_attributes_rec.payee_party_id IS NOT NULL) THEN
        IF (p_trxn_attributes_rec.payee_party_site_id IS NOT NULL) THEN
            -- Fetch Payee Site Country
            OPEN payeesite_country_csr(p_trxn_attributes_rec.payee_party_id,
                                       p_trxn_attributes_rec.payee_party_site_id);
            FETCH payeesite_country_csr INTO l_payee_country;
            CLOSE payeesite_country_csr;
        ELSE
          -- Fetch Payee Country
          OPEN payee_country_csr(p_trxn_attributes_rec.payee_party_site_id);
          FETCH payee_country_csr INTO l_payee_country;
          CLOSE payee_country_csr;
        END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Payee Country : '|| l_payee_country);

    END IF;
    --
    -- Pick up payment methods
    --
    OPEN payment_methods(p_trxn_attributes_rec.application_id,
                         p_trxn_attributes_rec.payee_party_id,
                         p_trxn_attributes_rec.payee_party_site_id,
                         p_trxn_attributes_rec.supplier_site_id,
                         p_trxn_attributes_rec.payer_org_id,
                         p_trxn_attributes_rec.payer_org_type,
                         p_trxn_attributes_rec.payment_function,
                         p_ignore_payee_prefer);

    LOOP
      l_payer_le_match     := FALSE;
      l_payer_org_match    := FALSE;
      l_trxn_type_match    := FALSE;
      l_currency_match     := FALSE;
      l_cross_border_match := FALSE;
      l_match              := FALSE;

      -- If no rows are returned, no Payment Methods are defined for this application

      FETCH payment_methods INTO l_pmt_mthds_rec;
      EXIT WHEN(payment_methods%NOTFOUND);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Payment Method : '|| l_pmt_mthds_rec.payment_method_code);

      END IF;
      -- Pick up all driving parameters for this Payment Method
      FOR pmthd_drivers_rec IN pmthd_drivers_csr(l_pmt_mthds_rec.payment_method_code,
                                                 p_trxn_attributes_rec.application_id)
        LOOP
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name,'   Applicable_Type_Code  : '|| pmthd_drivers_rec.Applicable_Type_Code);
	          print_debuginfo(l_module_name,'   Applicable_Type_Value : '|| pmthd_drivers_rec.Applicable_Value_To);

          END IF;
          CASE pmthd_drivers_rec.Applicable_Type_Code
            WHEN 'PAYER_LE' THEN
              l_payer_le_match := l_payer_le_match
                                  OR (pmthd_drivers_rec.Applicable_Value_To = p_trxn_attributes_rec.payer_legal_entity_id)
                                  OR (pmthd_drivers_rec.Applicable_Value_To IS NULL);

              IF (l_payer_le_match) THEN
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name,'   l_payer_le_match : TRUE');
                  END IF;
              END IF;

            WHEN 'PAYER_ORG' THEN
              l_payer_org_match := l_payer_org_match
                                   OR (pmthd_drivers_rec.Applicable_Value_To = p_trxn_attributes_rec.payer_org_id)
                                   OR (pmthd_drivers_rec.Applicable_Value_To IS NULL);

              IF (l_payer_org_match) THEN
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name,'   l_payer_org_match : TRUE');
                  END IF;
              END IF;

            WHEN 'PAY_PROC_TRXN_TYPE' THEN
              l_trxn_type_match := l_trxn_type_match
                                   OR (pmthd_drivers_rec.Applicable_Value_To =
                                       to_char(p_trxn_attributes_rec.pay_proc_trxn_type_code))
                                   OR (pmthd_drivers_rec.Applicable_Value_To IS NULL);

              IF (l_trxn_type_match) THEN
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name,'   l_trxn_type_match : TRUE');
                  END IF;
              END IF;

            WHEN 'FOREIGN_CURRENCY_FLAG' THEN
              l_currency_match := l_currency_match
                                  OR (l_accounting_curr = p_trxn_attributes_rec.payment_currency
                                      AND pmthd_drivers_rec.Applicable_Value_To = 'DOMESTIC')
                                  OR (l_accounting_curr <> p_trxn_attributes_rec.payment_currency
                                      AND pmthd_drivers_rec.Applicable_Value_To = 'FOREIGN')
                                  OR (pmthd_drivers_rec.Applicable_Value_To = 'FOREIGN_AND_DOMESTIC')
                                  OR (pmthd_drivers_rec.Applicable_Value_To IS NULL);

              IF (l_currency_match) THEN
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name,'   l_currency_match : TRUE');
                  END IF;
              END IF;

            WHEN 'CROSS_BORDER_FLAG' THEN
              l_cross_border_match := l_cross_border_match
                                      OR (NVL(l_payee_country,l_payer_country) = l_payer_country
                                          AND pmthd_drivers_rec.Applicable_Value_To = 'DOMESTIC')
                                      OR (NVL(l_payee_country,l_payer_country) <> l_payer_country
                                          AND pmthd_drivers_rec.Applicable_Value_To = 'FOREIGN')
                                      OR (pmthd_drivers_rec.Applicable_Value_To = 'FOREIGN_AND_DOMESTIC')
                                      OR (pmthd_drivers_rec.Applicable_Value_To IS NULL);

              IF (l_cross_border_match) THEN
                  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                  print_debuginfo(l_module_name,'   l_cross_border_match : TRUE');
                  END IF;
              END IF;

            ELSE
              NULL; -- Not a recognized driving parameter, hence ignoring it
          END CASE;

        -- driving parameters loop
        END LOOP;

      l_match := (l_payer_le_match     AND l_payer_org_match  AND
                  l_trxn_type_match    AND l_currency_match   AND
                  l_cross_border_match );

      -- insert matched Payment Method record into pl/sql table
      IF (l_match) THEN
         l_pmtmthd_table(l_index) := l_pmt_mthds_rec;
         l_index := l_index + 1;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Match Found');
         END IF;
      ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Not a Match');
         END IF;
      END IF;

    END LOOP;  -- applicable payment methods loop
    CLOSE payment_methods;

    IF (l_pmtmthd_table.COUNT = 0) THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'Error: No Payment Methods Applicable');

       END IF;
       FND_MESSAGE.set_name('IBY', 'IBY_NO_APPLICABLE_PAYMENT_METHODS');
       FND_MSG_PUB.Add;
       raise FND_API.G_EXC_ERROR;
    ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Applicable Payment Methods Count : '|| l_pmtmthd_table.COUNT);
      END IF;
      x_payment_methods_tbl := l_pmtmthd_table;
    END IF;

    -- End of API body.
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'RETURN');

    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Unexpected ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR))
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Other ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

END Get_Applicable_Payment_Methods;

  --   Start of comments
  --   API name     : Get_Applicable_Pmt_Profiles
  --   Type         : Public
  --   Pre-reqs     : None
  --   Function     : Get the list of applicable payment profiles
  --                  based on the given profile drivers
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_ppp_drivers_rec          IN  PPP_Drivers_Rec_Type
  --                                                       Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_profiles_tbl     OUT
  --                                                 Payment_Profiles_Tab_Type
  --                                                     Required
  --   Version      : Current version   1.0
  --                  Previous version  None
  --                  Initial version   1.0
  --   End of comments

  PROCEDURE Get_Applicable_Pmt_Profiles(
       p_api_version          IN         NUMBER,
       p_init_msg_list        IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_ppp_drivers_rec      IN         PPP_Drivers_Rec_Type,
       x_return_status        OUT NOCOPY VARCHAR2,
       x_msg_count            OUT NOCOPY NUMBER,
       x_msg_data             OUT NOCOPY VARCHAR2,
       x_payment_profiles_tbl OUT NOCOPY Payment_Profile_Tab_Type)
  IS
    l_api_name           CONSTANT VARCHAR2(30)    := 'Get_Applicable_Pmt_Profiles';
    l_api_version        CONSTANT NUMBER          := 1.0;
    l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.Get_Applicable_Pmt_Profiles';

    l_pmt_profs_tab      Payment_Profile_Tab_Type;
    l_pmt_profs_rec      Payment_Profile_Rec_Type;
    l_index              NUMBER  := 1;

     /*
      * We need to select payment profiles that are applicable to
      * given (payment method, org, format, currency, int bank account).
      *
      *
      *     |  Profiles      |
      *     |  applicable to |
      *     |  given pmt     |    Profiles applicable to
      *     |  method        |    given payment currency
      *     |                |     /
      *     |     |          |    /
      *     |     V          |  L
      *     |                |
      *     |----------------|--------------------------
      *     |/              \|            Profiles
      *     |                |            applicable to
      *     |  Intersection  |     <--    given
      *     |                |            org
      *     |\              /|
      *     |----------------|--------------------------
      *     |                |
      *     |                |  .__
      *     |     ^          |  |\
      *     |     |          |    \
      *     |     |          |
      *     |                |   Profiles applicable to
      *     | Profiles       |   given internal bank
      *     | applicable to  |   account
      *     | given format   |
      *     |                |
      *
      * We need the intersection of (profiles applicable to
      * a given payment method) and (profiles applicable to
      * a given org) and (profiles applicable to a given
      * format) and (profiles applicable to given payment
      * currency) and (profiles applicable to given internal
      * bank account) as shown in the graphic.
      *
      * Therefore, we need to join with the IBY_APPLICABLE_PMT_PROFS
      * five times - once to get the profiles for the method, once to get
      * the profiles for the org, and once to get the profiles for the
      * format etc. If we are able to get a non-null intersect for these
      * five queries, it means that there is a profile that matches the
      * (org, method, format, currency, bank acct) combination.
      *
      * If the 'applicable_value_to' is set to NULL, it means that the
      * profile is applicable to 'all orgs' | 'all methods' |
      * 'all formats' etc., depending upon the applicable_type_code.
      * Therefore, we need to factor this condition in the join.
      *
      * Payment format is not a driving item for payment profile.
      */
     CURSOR c_profiles(
                p_pmt_method_cd     IN IBY_DOCS_PAYABLE_ALL.
                                           payment_method_code%TYPE,
                p_org_id            IN IBY_DOCS_PAYABLE_ALL.org_id%TYPE,
                p_org_type          IN IBY_DOCS_PAYABLE_ALL.org_type%TYPE,
                p_pmt_currency      IN IBY_DOCS_PAYABLE_ALL.
                                           payment_currency_code%TYPE,
                p_int_bank_acct_id  IN IBY_DOCS_PAYABLE_ALL.
                                           internal_bank_account_id%TYPE
                )
     IS

     SELECT
         prof.payment_profile_id,
         prof.payment_profile_name,
         prof.processing_type
     FROM
         IBY_APPLICABLE_PMT_PROFS app1,
         IBY_APPLICABLE_PMT_PROFS app2,
         IBY_APPLICABLE_PMT_PROFS app3,
         IBY_APPLICABLE_PMT_PROFS app4,
         IBY_PAYMENT_PROFILES     prof
     WHERE
         (app1.applicable_type_code=APL_TYPE_PAYER_ORG AND
             ((app1.applicable_value_to=TO_CHAR(p_org_id) AND
                 app1.applicable_value_from=p_org_type) OR
             (app1.applicable_value_to IS NULL AND
                 app1.applicable_value_from IS NULL)) )
     AND (app2.applicable_type_code=APL_TYPE_PMT_METHOD AND
             (app2.applicable_value_to=p_pmt_method_cd OR
                 app2.applicable_value_to IS NULL))
     AND (app3.applicable_type_code=APL_TYPE_PMT_CURRENCY AND
             (app3.applicable_value_to=p_pmt_currency OR
                 app3.applicable_value_to IS NULL))
     AND (app4.applicable_type_code=APL_TYPE_INT_BANK_ACCT AND
             (app4.applicable_value_to=TO_CHAR(p_int_bank_acct_id) OR
                 app4.applicable_value_to IS NULL))
     AND app1.system_profile_code=app2.system_profile_code
     AND app2.system_profile_code=app3.system_profile_code
     AND app3.system_profile_code=app4.system_profile_code
     AND app4.system_profile_code=app1.system_profile_code
     AND app1.system_profile_code=prof.system_profile_code
     /*
      * Fix for bug 5929889:
      *
      * Filter profiles by inactive date so that we do not
      * pick up end-dated profiles.
      */
     AND NVL(prof.inactive_date, SYSDATE + 1) > SYSDATE
     ;

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');

	    print_debuginfo(l_module_name, 'Checking for profiles '
	        || 'applicable for given org '
	        || p_ppp_drivers_rec.Payer_Org_Id
	        || ' and org type '
	        || p_ppp_drivers_rec.Payer_Org_Type
	        || ' and payment method '
	        || p_ppp_drivers_rec.Payment_Method_Code
	        || ' and payment currency '
	        || p_ppp_drivers_rec.Payment_Currency
	        || ' and internal bank account '
	        || p_ppp_drivers_rec.Int_Bank_Account_Id
	        || ' combination ...'
	        );

    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
                       l_api_version,
                       p_api_version,
                       l_api_name,
                       G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Pick up all payment profiles that match the given profile drivers.
    --
    OPEN  c_profiles(p_ppp_drivers_rec.Payment_Method_Code,
              p_ppp_drivers_rec.Payer_Org_Id,
              p_ppp_drivers_rec.Payer_Org_Type,
              p_ppp_drivers_rec.Payment_Currency,
              p_ppp_drivers_rec.Int_Bank_Account_Id
              );
    FETCH c_profiles BULK COLLECT INTO l_pmt_profs_tab;
    CLOSE c_profiles;

    IF (l_pmt_profs_tab.COUNT = 0) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: No applicable payment profiles '
	          || 'were found.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_NO_APPLICABLE_PAYMENT_PROFILES');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'Count of applicable payment profiles: '
	        || l_pmt_profs_tab.COUNT);
      END IF;
      x_payment_profiles_tbl := l_pmt_profs_tab;

    END IF;

    -- End of API body.

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'RETURN');

    END IF;
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'ERROR: Exception occured '
	          || 'during call to API ');
	      print_debuginfo(l_module_name, 'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));

      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'ERROR: Exception occured during '
	          || 'call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));

      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'ERROR: Exception occured during '
	          || 'call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

END Get_Applicable_Pmt_Profiles;

  --   Start of comments
  --   API name     : Get_Pmt_Profiles_Intersect
  --   Type         : Public
  --   Pre-reqs     : None
  --   Function     : Get the list of applicable payment profiles
  --                  that are applicable across the given profile
  --                  drivers list.
  --
  --                  We already have a method to get the payment
  --                  profiles for a single set of profile drivers;
  --                  This method will attempt to get the payment profiles
  --                  for every given set of payment drivers in the list
  --                  and return their intersection.
  --
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_ppp_drivers_tab          IN  PPP_Drivers_Tab_Type
  --                                                       Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_profiles_tbl     OUT
  --                                                 Payment_Profiles_Tab_Type
  --                                                     Required
  --   Version      : Current version   1.0
  --                  Previous version  None
  --                  Initial version   1.0
  --   End of comments

  PROCEDURE Get_Pmt_Profiles_Intersect(
                p_api_version          IN         NUMBER,
                p_init_msg_list        IN         VARCHAR2 DEFAULT
                                                      FND_API.G_FALSE,
                p_ppp_drivers_tab      IN         PPP_Drivers_Tab_Type,
                x_return_status        OUT NOCOPY VARCHAR2,
                x_msg_count            OUT NOCOPY NUMBER,
                x_msg_data             OUT NOCOPY VARCHAR2,
                x_payment_profiles_tbl OUT NOCOPY Payment_Profile_Tab_Type)
  IS
    l_api_name           CONSTANT VARCHAR2(30)    :=
                             'Get_Pmt_Profiles_Intersect';
    l_api_version        CONSTANT NUMBER          := 1.0;
    l_module_name        CONSTANT VARCHAR2(200)   :=
                             G_PKG_NAME || '.Get_Pmt_Profiles_Intersect';

    l_prof_intsct_tab         Payment_Profile_Tab_Type;
    l_prof_tab                Payment_Profile_Tab_Type;
    l_pmt_prof_rec            Payment_Profile_Rec_Type;

    l_prof_tabs_list          Payment_Profile_2D_Tab_Type;
    l_index                   NUMBER  := 1;
    l_first_set               BOOLEAN := FALSE;
    l_match                   BOOLEAN := FALSE;

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');

    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
                       l_api_version,
                       p_api_version,
                       l_api_name,
                       G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- If no driver sets are given, do nothing
    --
    IF (p_ppp_drivers_tab.COUNT = 0) THEN

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'No profile drivers were '
	            || 'specified. Exiting .. ');
	        print_debuginfo(l_module_name, 'RETURN');

        END IF;
        RETURN;

    END IF;

    --
    -- Call the applicable payment profiles API for each set
    -- of profile drivers.
    --
    FOR i IN p_ppp_drivers_tab.FIRST .. p_ppp_drivers_tab.LAST LOOP

        Get_Applicable_Pmt_Profiles(
            p_api_version,
            p_init_msg_list ,
            p_ppp_drivers_tab(i),
            x_return_status,
            x_msg_count,
            x_msg_data,
            l_prof_tab
            );

        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

            /*
             * Add the returned list of payment profiles into
             * our list of payment profile tables.
             */
            l_prof_tabs_list(l_prof_tabs_list.COUNT + 1) := l_prof_tab;

        ELSE

            /*
             * We cannot proceed because the API call to get payment
             * profiles for a particular set of payment profile
             * drivers has failed. Raise an exception.
             */
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;


    END LOOP;

    /*
     * Start processing the list of profile drivers for each document
     * one-by-one.
     */

    /* find intersect profiles */
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Finding intersect profiles .. ');

    END IF;
    l_first_set := TRUE;
    FOR i in l_prof_tabs_list.FIRST .. l_prof_tabs_list.LAST LOOP

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Popping table: ' || i);

        END IF;
        l_prof_tab := l_prof_tabs_list(i);

        IF (l_first_set = TRUE) THEN

            /* Add the first table to the intersect list */
            /*
             * We'll start eliminating those elements from
             * this intersect list that are not found in the
             * comparison list.
             */
            l_prof_intsct_tab := l_prof_tab;

            IF (l_prof_intsct_tab.COUNT > 0) THEN

                FOR n in l_prof_intsct_tab.FIRST .. l_prof_intsct_tab.LAST LOOP

                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                    print_debuginfo(l_module_name, 'Seeded intersect '
	                        || 'profile id: '
	                        || l_prof_intsct_tab(n).Payment_Profile_Id
	                        );

                    END IF;
                END LOOP;

            END IF;

            l_first_set := FALSE;

        END IF;

        /* eliminate from the intersect list */

        IF (l_prof_intsct_tab.COUNT > 0) THEN
        FOR k in l_prof_intsct_tab.FIRST .. l_prof_intsct_tab.LAST
            LOOP

            /*
             * Since we are eliminating rows from the intersect
             * table, we have to ensure that the rows exists before
             * each iteration begins.
             */
            IF (l_prof_intsct_tab.EXISTS(k)) THEN

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                print_debuginfo(l_module_name, 'Current intersect '
	                    || 'profile id: '
	                    || l_prof_intsct_tab(k).Payment_Profile_Id
	                    );

                END IF;
                /*
                 * Loop through all the given profiles searching
                 * if any of them is stored in the intersect
                 * table.
                 */
                l_match := FALSE;

                IF (l_prof_tab.COUNT > 0) THEN

                    FOR m in l_prof_tab.FIRST .. l_prof_tab.LAST LOOP

                        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                        print_debuginfo(l_module_name, 'Comparing intersect '
	                            || 'profile id: '
	                            || l_prof_intsct_tab(k).Payment_Profile_Id
	                            || ' with profile '
	                            || l_prof_tab(m).Payment_Profile_Id
	                            );

                        END IF;
                        IF (l_prof_intsct_tab(k).Payment_Profile_Id =
                            l_prof_tab(m).Payment_Profile_Id) THEN

                            l_match := TRUE;

                            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                            print_debuginfo(l_module_name, 'Profile id: '
	                                || l_prof_intsct_tab(k).Payment_Profile_Id
	                                || ' matched.'
	                                );

                            END IF;
                        ELSE

                            IF (l_match <> TRUE) THEN
                                l_match := FALSE;
                            END IF;

                        END IF;

                    END LOOP; -- for each profile in current set

                ELSE

                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                    print_debuginfo(l_module_name, 'Comparison list is empty. '
	                        || 'This means that there are no intersection '
	                        || 'elements. Emptying out intersection list ..'
	                        );

                    END IF;
                    l_match := FALSE;

                END IF;

                IF (l_match = FALSE) THEN
                    /*
                     * This means that the current profile
                     * from the intersect was not found
                     * in the entire list of profiles
                     * that we were comparing with.
                     *
                     * Therefore, this profile is no longer
                     * in the intersection. Eliminate this
                     * profile from the intersect list.
                     */
                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                    print_debuginfo(l_module_name, 'Eliminating profile id: '
	                        || l_prof_intsct_tab(k).Payment_Profile_Id);

                    END IF;
                    l_prof_intsct_tab.DELETE(k);

                    IF (l_prof_intsct_tab.COUNT = 0) THEN

                        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                        print_debuginfo(l_module_name, 'Intersect list '
	                            || 'is empty. '
	                            || 'Exiting ..');

                        END IF;
                        GOTO label_finish;

                    END IF;

                END IF;

            END IF; -- if row exists in intersect table

        END LOOP; -- for each profile in intersect
        END IF; -- if intersect is non-zero

    END LOOP;

    <<label_finish>>

    /* Finally print the profile intersection */
    IF (l_prof_intsct_tab.COUNT = 0) THEN

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, 'Profile intersection is NULL');

        END IF;
    ELSE

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, '-----------------------');
        END IF;
        FOR i IN l_prof_intsct_tab.FIRST .. l_prof_intsct_tab.LAST LOOP

            IF (l_prof_intsct_tab.EXISTS(i)) THEN

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                print_debuginfo(l_module_name, 'Intersection profile: '
	                    || l_prof_intsct_tab(i).Payment_Profile_Id);

                END IF;
            END IF;

        END LOOP;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo(l_module_name, '-----------------------');

        END IF;
    END IF;

    /*
     * Copy back the payment profiles intersect onto
     * the output param.
     */
    x_payment_profiles_tbl := l_prof_intsct_tab;

    -- End of API body.
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'RETURN');

    END IF;
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'ERROR: Exception occured '
	          || 'during call to API ');
	      print_debuginfo(l_module_name, 'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));

      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'ERROR: Exception occured during '
	          || 'call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));

      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR))
          THEN

          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'ERROR: Exception occured during '
	          || 'call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

END Get_Pmt_Profiles_Intersect;

  -- Start of comments
  --   API name     : Get_Applicable_Payment_Reasons
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of applicable Payment Reasons.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payment_reason_tbl       OUT Payment_Reason_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Applicable_Payment_Reasons(
     p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2 default FND_API.G_FALSE    ,
     p_trxn_attributes_rec IN   Trxn_Attributes_Rec_Type,
     x_return_status       OUT  NOCOPY VARCHAR2                     ,
     x_msg_count           OUT  NOCOPY NUMBER                       ,
     x_msg_data            OUT  NOCOPY VARCHAR2                     ,
     x_payment_reason_tbl  OUT  NOCOPY Payment_Reason_Tab_Type
)
IS

   l_api_name           CONSTANT VARCHAR2(30)    := 'Get_Applicable_Payment_Reason';
   l_api_version        CONSTANT NUMBER          := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.Get_Applicable_Payment_Reason';

   l_payment_reason_tbl Payment_Reason_Tab_Type;
   l_payer_country VARCHAR2(35);

   CURSOR payment_reason_csr(p_payer_country VARCHAR2)
   IS
      SELECT payment_reason_code,
             description,
             meaning,
             territory_code
      FROM IBY_PAYMENT_REASONS_VL ibypr
      WHERE (ibypr.territory_code = p_payer_country OR ibypr.territory_code is NULL)
      AND   (ibypr.inactive_date is NULL OR ibypr.inactive_date >= trunc(sysdate));

   CURSOR payer_country_csr(p_payer_le_id NUMBER)
   IS
      SELECT xle.country
      FROM XLE_FIRSTPARTY_INFORMATION_V xle
      WHERE xle.legal_entity_id = p_payer_le_id;

BEGIN
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name,'ENTER');

   END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_trxn_attributes_rec.payer_legal_entity_id IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''First party legal entity Id'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_1PARTY_LE_ID'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN payer_country_csr(p_trxn_attributes_rec.payer_legal_entity_id);
   FETCH payer_country_csr INTO l_payer_country;
   CLOSE payer_country_csr;

   IF (l_payer_country IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: First party country Not populated.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_DATA');
      FND_MESSAGE.SET_TOKEN('PARAM', 'First party country');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN payment_reason_csr(l_payer_country);
   FETCH payment_reason_csr BULK COLLECT INTO l_payment_reason_tbl;
   CLOSE payment_reason_csr;

   IF (l_payment_reason_tbl.COUNT = 0) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Warning: No Payment Reasons Applicable');
      END IF;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Applicable Payment Reasons Count : '|| l_payment_reason_tbl.COUNT);
      END IF;
      x_payment_reason_tbl := l_payment_reason_tbl;
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');

   END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

END Get_Applicable_Payment_Reasons;

-- Start of comments
--   API name     : Get_Default_Payment_Attributes
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : get the default values of all Payment attributes.
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_application_id           IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type Required
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--                    x_default_pmt_attrs_rec    OUT Default_Pmt_Attrs_Rec_Type Required
--
--   Version   : Current version   1.0
--                      Previous version   None
--                      Initial version    1.0
-- End of comments

PROCEDURE Get_Default_Payment_Attributes(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 default FND_API.G_FALSE,
    p_ignore_payee_pref       IN   VARCHAR2,
    p_trxn_attributes_rec     IN   Trxn_Attributes_Rec_Type,
    x_return_status           OUT  NOCOPY VARCHAR2,
    x_msg_count               OUT  NOCOPY NUMBER,
    x_msg_data                OUT  NOCOPY VARCHAR2,
    x_default_pmt_attrs_rec   OUT  NOCOPY Default_Pmt_Attrs_Rec_Type
)
IS
   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_Default_Payment_Attributes';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.Get_Default_Payment_Attributes';

   l_payee_override_flag   VARCHAR2(1);

   l_payment_method_rec    Payment_Method_Rec_Type;
   l_payment_format_rec    Payment_Format_Rec_Type;
   l_payee_bankaccount_rec Payee_BankAccount_Rec_Type;
   l_payment_reason_rec    Payment_Reason_Rec_Type;
   l_delivery_channel_rec  Delivery_Channel_Rec_Type;
   l_bank_charge_bearer    Bank_Charge_Bearer_Rec_Type;
   l_settlement_priority   Settlement_Priority_Rec_Type;

   l_pay_alone             VARCHAR2(1);
   l_payment_reason_comments VARCHAR2(240);

   l_payee1                IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE;
   l_payee2                IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE;
   l_payee3                IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE;
   l_payee4                IBY_EXTERNAL_PAYEES_ALL.ext_payee_id%TYPE;


   CURSOR payee_override_ent_cur IS
     SELECT payment_method_at_payee_flag
       FROM IBY_INTERNAL_PAYERS_ALL
      WHERE org_id is null;

   CURSOR payee_override_org_cur(p_org_id NUMBER,
                                 p_org_type VARCHAR2) IS
     SELECT payment_method_at_payee_flag
       FROM IBY_INTERNAL_PAYERS_ALL
      WHERE org_id = p_org_id
        AND org_type = p_org_type;

  /*
   * OBSOLETE:
   *
   * Left here for reference purposes.
   *
   * This cursor has been split into two parts;
   * payee_defaults_curA1 and payee_defaults_curB1
   * below are it's replacements.
   *
   * The split has been done to improve performance
   * and legibility.
   */
   CURSOR payee_defaults_cur (p_payee_party_id      NUMBER,
                              p_payee_party_site_id NUMBER,
                              p_supplier_site_id    NUMBER,
                              p_org_id              NUMBER,
                              p_org_type            VARCHAR2,
                              p_payment_function    VARCHAR2,
			      p_Pay_Proc_Trxn_Type_Code VARCHAR2,
			      p_payer_le_id NUMBER) IS
     SELECT pm.payment_method_code,
            m.payment_method_name,
            m.SUPPORT_BILLS_PAYABLE_FLAG,
            m.MATURITY_DATE_OFFSET_DAYS,
            payee.payment_format_code,
            f.format_name,
            payee.bank_charge_bearer,
            payee.delivery_channel_code,
            d.meaning delivery_channel_meaning,
            d.description delivery_channel_description,
            payee.payment_reason_code,
            r.meaning payment_reason,
            r.description payment_reason_description,
            payee.payment_reason_comments,
            payee.exclusive_payment_flag,
            payee.settlement_priority,
            d.territory_code delivery_channel_country,
            r.territory_code payment_reason_country
     FROM IBY_EXTERNAL_PAYEES_ALL payee,
     	  IBY_EXT_PARTY_PMT_MTHDS pm,
          IBY_PAYMENT_METHODS_VL m,
          IBY_FORMATS_VL f,
          IBY_DELIVERY_CHANNELS_VL d,
          IBY_PAYMENT_REASONS_VL r,
	IBY_APPLICABLE_PMT_MTHDS am1,
	IBY_APPLICABLE_PMT_MTHDS am2,
	IBY_APPLICABLE_PMT_MTHDS am3
     WHERE payee.payee_party_id = p_payee_party_id
     AND am1.PAYMENT_METHOD_CODE(+) = m.PAYMENT_METHOD_CODE
     AND am1.PAYMENT_FLOW(+) = 'DISBURSEMENTS'
     AND am1.APPLICABLE_TYPE_CODE(+) = 'PAY_PROC_TRXN_TYPE'
     AND (am1.APPLICABLE_VALUE_TO is null OR
	  am1.APPLICABLE_VALUE_TO=p_Pay_Proc_Trxn_Type_Code )
     AND (am1.INACTIVE_DATE is null OR am1.INACTIVE_DATE >= trunc(sysdate))
     AND am2.PAYMENT_METHOD_CODE(+) = am1.PAYMENT_METHOD_CODE
     AND am2.APPLICABLE_TYPE_CODE(+) = 'PAYER_LE'
     AND (am2.APPLICABLE_VALUE_TO is null OR am2.APPLICABLE_VALUE_TO=p_payer_le_id )
     AND (am2.INACTIVE_DATE is null OR am2.INACTIVE_DATE >= trunc(sysdate))
     AND am3.PAYMENT_METHOD_CODE(+) = am2.PAYMENT_METHOD_CODE
     AND am3.APPLICABLE_TYPE_CODE(+) = 'PAYER_ORG'
     AND (am3.APPLICABLE_VALUE_TO is null OR 	am3.APPLICABLE_VALUE_TO=p_org_id )
     AND (am3.INACTIVE_DATE is null OR am3.INACTIVE_DATE >= trunc(sysdate))
     AND   payee.payment_function = p_payment_function
     AND   payee.ext_payee_id = pm.ext_pmt_party_id(+)
     AND   pm.payment_method_code = m.payment_method_code(+)
     AND   pm.payment_function(+) = p_payment_function
     AND   pm.primary_flag(+) = 'Y'
     AND   (pm.inactive_date is null OR pm.inactive_date >= trunc(sysdate))
     AND   payee.payment_format_code = f.format_code(+)
     AND   payee.delivery_channel_code = d.delivery_channel_code(+)
     AND   payee.payment_reason_code = r.payment_reason_code(+)
     AND   (payee.org_id is NULL
            OR (payee.org_id = p_org_id AND payee.org_type = p_org_type))
     AND   (payee.party_site_id is NULL OR payee.party_site_id = p_payee_party_site_id)
     AND   (payee.supplier_site_id is NULL OR payee.supplier_site_id = p_supplier_site_id)
     ORDER by payee.supplier_site_id,
              payee.party_site_id,
              payee.org_id;

   /*
    * Fix for performance bug 5548886:
    *
    * Use the ext payee id as the key to drive this
    * cursor as it will significantly improve
    * performance and improve maintainability.
    */
   CURSOR payee_defaults_curA1 (
                              p_payee_party_id          NUMBER,
                              p_payee_party_site_id     NUMBER,
                              p_supplier_site_id        NUMBER,
                              p_org_id                  NUMBER,
                              p_org_type                VARCHAR2,
                              p_payment_function        VARCHAR2,
                              p_Pay_Proc_Trxn_Type_Code VARCHAR2,
                              p_payer_le_id             NUMBER,
                              p_payee1                  NUMBER,
                              p_payee2                  NUMBER,
                              p_payee3                  NUMBER,
                              p_payee4                  NUMBER
                              )
     IS
     SELECT
            payee.payment_format_code,
            f.format_name,
            payee.bank_charge_bearer,
            payee.delivery_channel_code,
            d.meaning delivery_channel_meaning,
            d.description delivery_channel_description,
            payee.payment_reason_code,
            r.meaning payment_reason,
            r.description payment_reason_description,
            payee.payment_reason_comments,
            payee.exclusive_payment_flag,
            payee.settlement_priority,
            d.territory_code delivery_channel_country,
            r.territory_code payment_reason_country
     FROM
          IBY_EXTERNAL_PAYEES_ALL  payee,
          IBY_FORMATS_VL           f,
          IBY_DELIVERY_CHANNELS_VL d,
          IBY_PAYMENT_REASONS_VL   r
     WHERE
     payee.ext_payee_id                  IN
                                         (
                                         p_payee1,
                                         p_payee2,
                                         p_payee3,
                                         p_payee4
                                         )
     AND   payee.payment_format_code   = f.format_code(+)
     AND   payee.delivery_channel_code = d.delivery_channel_code(+)
     AND   payee.payment_reason_code   = r.payment_reason_code(+)
     ORDER BY
         payee.supplier_site_id,
         payee.party_site_id,
         payee.org_id
     ;

   /*
    * Fix for performance bug 5548886:
    *
    * Use the ext payee id as the key to drive this
    * cursor as it will significantly improve
    * performance and improve maintainability.
    */
   CURSOR payee_defaults_curB1 (
                              p_payee_party_id          NUMBER,
                              p_payee_party_site_id     NUMBER,
                              p_supplier_site_id        NUMBER,
                              p_org_id                  NUMBER,
                              p_org_type                VARCHAR2,
                              p_payment_function        VARCHAR2,
                              p_Pay_Proc_Trxn_Type_Code VARCHAR2,
                              p_payer_le_id             NUMBER,
                              p_payee1                  NUMBER,
                              p_payee2                  NUMBER,
                              p_payee3                  NUMBER,
                              p_payee4                  NUMBER
                              )
     IS
     SELECT
         pm.payment_method_code,
         m.payment_method_name,
         m.support_bills_payable_flag,
         m.maturity_date_offset_days
     FROM
         IBY_EXTERNAL_PAYEES_ALL payee,
         IBY_EXT_PARTY_PMT_MTHDS pm,
         IBY_PAYMENT_METHODS_VL  m
     WHERE
     payee.ext_payee_id  IN         (
                                    p_payee1,
                                    p_payee2,
                                    p_payee3,
                                    p_payee4
                                    )
     AND   payee.payment_function = p_payment_function
     AND   payee.ext_payee_id     = pm.ext_pmt_party_id
     AND   pm.payment_method_code = m.payment_method_code
     AND   pm.payment_function    = p_payment_function
     AND   pm.primary_flag        = 'Y'
     AND   (pm.inactive_date IS NULL OR pm.inactive_date >= trunc(sysdate))
     AND EXISTS (SELECT 1 FROM IBY_APPLICABLE_PMT_MTHDS am1
                 WHERE am1.payment_method_code = m.payment_method_code
                 AND am1.payment_flow(+) = 'DISBURSEMENTS'
                 AND am1.applicable_type_code = 'PAY_PROC_TRXN_TYPE'
                 AND (am1.applicable_value_to IS NULL OR
                         am1.applicable_value_to=p_pay_proc_trxn_type_code)
                 AND (am1.inactive_date IS null OR
                         am1.inactive_date >= trunc(sysdate)))
     AND EXISTS (SELECT 1 FROM IBY_APPLICABLE_PMT_MTHDS am2
                 WHERE am2.payment_method_code = m.payment_method_code
                 AND am2.applicable_type_code = 'PAYER_LE'
                 AND (am2.applicable_value_to IS NULL OR
                         am2.applicable_value_to=p_payer_le_id)
                 AND (am2.inactive_date IS NULL OR
                         am2.inactive_date >= trunc(sysdate)))
     AND EXISTS (SELECT 1 FROM IBY_APPLICABLE_PMT_MTHDS am3
                 WHERE am3.payment_method_code = m.payment_method_code
                 AND am3.applicable_type_code = 'PAYER_ORG'
                 AND (am3.applicable_value_to IS NULL OR
                         am3.applicable_value_to=p_org_id)
                 AND (am3.inactive_date IS NULL OR
                         am3.inactive_date >= trunc(sysdate))
                 )
     ORDER BY
         payee.supplier_site_id,
         payee.party_site_id,
         payee.org_id
     ;


     CURSOR payee_bankaccount_cur(p_payee_party_id      NUMBER,
                                  p_payee_party_site_id NUMBER,
                                  p_supplier_site_id    NUMBER,
                                  p_payer_org_id        NUMBER,
                                  p_payer_org_type      VARCHAR2,
                                  p_payment_function    VARCHAR2,
                                  p_payment_currency    VARCHAR2) IS
     SELECT b.bank_account_name,
            b.ext_bank_account_id,
            b.bank_account_number,
            b.currency_code,
            b.iban_number,
            b.bank_name,
            b.bank_number,
            b.bank_branch_name,
            b.branch_number,
            b.country_code,
            b.alternate_account_name,
            b.bank_account_type,
            b.account_suffix,
            b.description,
            b.foreign_payment_use_flag,
            b.payment_factor_flag,
            b.eft_swift_code
       FROM IBY_PMT_INSTR_USES_ALL ibyu,
            IBY_EXT_BANK_ACCOUNTS_V b,
            IBY_EXTERNAL_PAYEES_ALL ibypayee
       WHERE ibyu.instrument_id = b.ext_bank_account_id
       AND ibyu.instrument_type = 'BANKACCOUNT'
       AND (b.currency_code = p_payment_currency
            OR b.currency_code is null
	    OR NVL(b.foreign_payment_use_flag,'N')='Y')
       AND ibyu.payment_function = p_payment_function
       AND ibyu.ext_pmt_party_id = ibypayee.ext_payee_id
       AND ibypayee.payee_party_id = p_payee_party_id
       AND trunc(sysdate) between NVL(trunc(ibyu.start_date),trunc(sysdate)) AND
                                  NVL(trunc(ibyu.end_date-1),trunc(sysdate))
       AND trunc(sysdate) between NVL(trunc(b.start_date),trunc(sysdate)) AND
                                  NVL(trunc(b.end_date-1),trunc(sysdate))
       AND (ibypayee.party_site_id is NULL OR ibypayee.party_site_id = p_payee_party_site_id)
       AND (ibypayee.supplier_site_id is NULL OR ibypayee.supplier_site_id = p_supplier_site_id)
       AND (ibypayee.org_id is null
            OR (ibypayee.org_id = p_payer_org_id AND ibypayee.org_type = p_payer_org_type) )

       /*
        * Fix for bug 5505267:
        *
        * Add payment flow predicate to improve
        * performance.
        */
       AND ibyu.payment_flow='DISBURSEMENTS'
       ORDER by ibypayee.supplier_site_id,
                ibypayee.party_site_id,
                ibypayee.org_id,
                ibyu.order_of_preference;

       CURSOR get_fnd_lookup(p_lookup_type VARCHAR2,
                             p_lookup_code VARCHAR2)
       IS
       SELECT lookup_code,
              meaning,
              description
         FROM FND_LOOKUP_VALUES_VL
        WHERE lookup_type = p_lookup_type
          AND lookup_code = p_lookup_code
          AND (trunc(sysdate) BETWEEN NVL(start_date_active,trunc(sysdate)) AND
                                NVL(end_date_active,trunc(sysdate)));

BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name,'ENTER');
	    print_debuginfo(l_module_name,'Application_id   : '|| p_trxn_attributes_rec.application_id);
	    print_debuginfo(l_module_name,'1st party LE id  : '|| p_trxn_attributes_rec.payer_legal_entity_id);
	    print_debuginfo(l_module_name,'Org Id           : '|| p_trxn_attributes_rec.payer_org_id);
	    print_debuginfo(l_module_name,'Org Type         : '|| p_trxn_attributes_rec.payer_org_type);
	    print_debuginfo(l_module_name,'Payer Id         : '|| p_trxn_attributes_rec.payee_party_id);
	    print_debuginfo(l_module_name,'Payee Site Id    : '|| p_trxn_attributes_rec.payee_party_site_id);
	    print_debuginfo(l_module_name,'Supplier Site Id : '|| p_trxn_attributes_rec.supplier_site_id);
	    print_debuginfo(l_module_name,'Trxn Type Code   : '|| p_trxn_attributes_rec.pay_proc_trxn_type_code);
	    print_debuginfo(l_module_name,'Payment Currency : '|| p_trxn_attributes_rec.payment_currency);
	    print_debuginfo(l_module_name,'Payment Amount   : '|| p_trxn_attributes_rec.payment_amount);
	    print_debuginfo(l_module_name,'Payment Function : '|| p_trxn_attributes_rec.payment_function);

    END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   /*
    * Fix for bug 5682499:
    *
    * Payment methods can be set up at the supplier level or
    * the supplier site level.
    *
    * If no payment method is setup at the supplier site level
    * then the payment method at the supplier level should be
    * used for defaulting.
    *
    * This means that we need to pick up two possible ext
    * payee ids - one ext payee id with exact context including
    * supplier site id, and one ext payee id with partial context
    * where supplier site id is null.
    *
    * The only purpose of the second ext payee id is to pick up
    * payment methods that are defaulted at the supplier level.
    *
    * The where clause below uses the IN syntax to pick up
    * these two ext payee ids.
    */

   /*
    * Update:
    *
    * We need to pick up all possible ext payee ids based on the
    * following chart. This means that there can be upto 4 possible
    * ext payee ids in the select statement.
    *
    *  EXT PARTY ID PRECEDENCE CHART
    * -------------------------------------------------------------
    *                      |         |         |         |         |
    *                      | supp    | org     | party   | party   |
    *                      | site    |         | site    |         |
    * -------------------------------------------------------------
    *                      |         |         |         |         |
    *  supp site           |   Y     |   Y     |   Y     |   Y     |
    *                      |         |         |         |         |
    * -------------------------------------------------------------
    *                      |         |         |         |         |
    *  party site (org)    |  null   |   Y     |   Y     |   Y     |
    *                      |         |         |         |         |
    * -------------------------------------------------------------
    *                      |         |         |         |         |
    *  party site (no org) |  null   |   null  |   Y     |   Y     |
    *                      |         |         |         |         |
    * -------------------------------------------------------------
    *                      |         |         |         |         |
    *  party               |  null   |   null  |   null  |   Y     |
    *                      |         |         |         |         |
    * --------------------------------------------------------------
    *
    * Y = value provided, null = no value provided
    *
    * Matching by supp site has the highest precedence
    * Matching by party alone has the lowest precedence
    *
    */

   /*
    * exact context:
    * supplier site level
    */
   l_payee1 := IBY_DISBURSE_SUBMIT_PUB_PKG.deriveExactPayeeIdFromContext(
                   p_trxn_attributes_rec.Payee_Party_Id,
                   p_trxn_attributes_rec.Payee_Party_Site_Id,
                   p_trxn_attributes_rec.Supplier_Site_Id,
                   p_trxn_attributes_rec.Payer_Org_Id,
                   p_trxn_attributes_rec.Payer_Org_Type,
                   p_trxn_attributes_rec.Payment_Function
                   );

   /*
    * partial context:
    * party site level with org
    */
   l_payee2 := IBY_DISBURSE_SUBMIT_PUB_PKG.deriveExactPayeeIdFromContext(
                   p_trxn_attributes_rec.Payee_Party_Id,
                   p_trxn_attributes_rec.Payee_Party_Site_Id,
                   null,
                   p_trxn_attributes_rec.Payer_Org_Id,
                   p_trxn_attributes_rec.Payer_Org_Type,
                   p_trxn_attributes_rec.Payment_Function
                   );


  /*
   * partial context:
   * party site level without org
   */
   l_payee3 := IBY_DISBURSE_SUBMIT_PUB_PKG.deriveExactPayeeIdFromContext(
                   p_trxn_attributes_rec.Payee_Party_Id,
                   p_trxn_attributes_rec.Payee_Party_Site_Id,
                   null,
                   null,
                   null,
                   p_trxn_attributes_rec.Payment_Function
                   );


   /*
    * partial context:
    * party level
    */
   l_payee4 := IBY_DISBURSE_SUBMIT_PUB_PKG.deriveExactPayeeIdFromContext(
                   p_trxn_attributes_rec.Payee_Party_Id,
                   null,
                   null,
                   null,
                   null,
                   p_trxn_attributes_rec.Payment_Function
                   );


   -- Start of API body
    FOR payee_defaults_rec in payee_defaults_curA1(
				p_trxn_attributes_rec.Payee_Party_Id,
                                p_trxn_attributes_rec.Payee_Party_Site_Id,
                                p_trxn_attributes_rec.Supplier_Site_Id,
                                p_trxn_attributes_rec.Payer_Org_Id,
                                p_trxn_attributes_rec.Payer_Org_Type,
                                p_trxn_attributes_rec.payment_function,
				p_trxn_attributes_rec.Pay_Proc_Trxn_Type_Code,
				p_trxn_attributes_rec.payer_legal_entity_id,
                                l_payee1,
                                l_payee2,
                                l_payee3,
                                l_payee4
                                )
   LOOP

      -- Payment Format
      IF (l_payment_format_rec.Payment_Format_Code is NULL) THEN
         l_payment_format_rec.Payment_Format_Name := payee_defaults_rec.format_name;
         l_payment_format_rec.Payment_Format_Code :=  payee_defaults_rec.payment_format_code;
      END IF;

      -- Payment Reason
      IF (l_payment_reason_rec.Code is NULL) THEN
  -- bug 4880032
         l_payment_reason_rec.Code := payee_defaults_rec.payment_reason_code;
         l_payment_reason_rec.Meaning := payee_defaults_rec.payment_reason;
         l_payment_reason_rec.Description := payee_defaults_rec.payment_reason_description;
          l_payment_reason_rec.Country := payee_defaults_rec.payment_reason_country;
      END IF;


      -- Delivery Channel
      IF (l_delivery_channel_rec.Code is NULL) THEN
         l_delivery_channel_rec.Code := payee_defaults_rec.delivery_channel_code;
         l_delivery_channel_rec.Meaning := payee_defaults_rec.delivery_channel_meaning;
         l_delivery_channel_rec.Description := payee_defaults_rec.delivery_channel_description;
   l_delivery_channel_rec.Country := payee_defaults_rec.delivery_channel_Country;

      END IF;

      -- Bank Charge Bearer
      IF (l_bank_charge_bearer.Code is NULL) THEN
         l_bank_charge_bearer.Code := payee_defaults_rec.bank_charge_bearer;

      END IF;

      -- Pay Alone Flag
      IF (l_pay_alone is NULL) THEN
         l_pay_alone := payee_defaults_rec.exclusive_payment_flag;
      END IF;

      -- Payment reason comments

      IF(l_payment_reason_comments is NULL) THEN
       l_payment_reason_comments :=payee_defaults_rec.payment_reason_comments;
      END IF;

      -- Express Payment Flag
      IF (l_settlement_priority.code is NULL) THEN
         l_settlement_priority.code := payee_defaults_rec.settlement_priority;
      END IF;

   END LOOP;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name,'Default Payment Format Name    : '|| l_payment_format_rec.Payment_Format_Name);
	   print_debuginfo(l_module_name,'Default Payment Reason Code    : '|| l_payment_reason_rec.Code);
	   print_debuginfo(l_module_name,'Default Delivery Channel Code  : '|| l_delivery_channel_rec.Code);
	   print_debuginfo(l_module_name,'Default Bank Charge Bearer     : '|| l_bank_charge_bearer.Code);
	   print_debuginfo(l_module_name,'Default Exclusive Payment Flag : '|| l_pay_alone);
	   print_debuginfo(l_module_name,'Default Settlement Priority    : '|| l_settlement_priority.code);
	     print_debuginfo(l_module_name,'Default Payment Reason Comments    : '|| l_payment_reason_comments);

     END IF;
   -- Start of API body
    FOR payee_defaults_rec in payee_defaults_curB1(
				p_trxn_attributes_rec.Payee_Party_Id,
                                p_trxn_attributes_rec.Payee_Party_Site_Id,
                                p_trxn_attributes_rec.Supplier_Site_Id,
                                p_trxn_attributes_rec.Payer_Org_Id,
                                p_trxn_attributes_rec.Payer_Org_Type,
                                p_trxn_attributes_rec.payment_function,
				p_trxn_attributes_rec.Pay_Proc_Trxn_Type_Code,
				p_trxn_attributes_rec.payer_legal_entity_id,
                                l_payee1,
                                l_payee2,
                                l_payee3,
                                l_payee4
                                )
   LOOP

      -- Payment Method
      IF (l_payment_method_rec.Payment_Method_Name is NULL) THEN
         l_payment_method_rec.Payment_Method_Name := payee_defaults_rec.payment_method_name;
         l_payment_method_rec.Payment_Method_Code :=  payee_defaults_rec.payment_method_code;
         l_payment_method_rec.Bill_Payable_Flag := payee_defaults_rec.support_bills_payable_flag;
         l_payment_method_rec.Maturity_Date_Offset :=  payee_defaults_rec.maturity_date_offset_days;
      END IF;

   END LOOP;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name,'Default Payment Method Name    : '|| l_payment_method_rec.Payment_Method_Name);

   END IF;
   -- Get Default Bank Charge Bearer record
   OPEN get_fnd_lookup(BANK_CHARGE_BEARER_LOOKUP,l_bank_charge_bearer.Code);
   FETCH get_fnd_lookup into l_bank_charge_bearer;
   CLOSE get_fnd_lookup;

   -- Get Default Express Payment record
   OPEN get_fnd_lookup(SETTLEMENT_PRIORITY_LOOKUP,l_settlement_priority.code);
   FETCH get_fnd_lookup into l_settlement_priority;
   CLOSE get_fnd_lookup;

   -- Change the default payment method according to the override setup
   OPEN payee_override_org_cur(p_trxn_attributes_rec.Payer_Org_Id,
                               p_trxn_attributes_rec.Payer_Org_Type);
   FETCH payee_override_org_cur into l_payee_override_flag;
   CLOSE payee_override_org_cur;

   IF (l_payee_override_flag is null) THEN
      OPEN payee_override_ent_cur;
      FETCH payee_override_ent_cur into l_payee_override_flag;
      CLOSE payee_override_ent_cur;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name,'Payee OverRide Flag            : '|| l_payee_override_flag);

   END IF;
/* Bug 6045110: When Allow Payee Override system option is set to 'Y',
   but, payment method is not set at supplier or supplier site level,
   it is expected that payment method needs to be defaulted from the
   defaulting rules.
*/
   IF (p_ignore_payee_pref = 'Y'
       OR (l_payee_override_flag = 'Y' AND l_payment_method_rec.Payment_Method_Code is null)  -- Bug 6045110
       OR l_payee_override_flag <> 'Y') THEN
      -- Initialize the payment method record as it will be purely rule-based
      l_payment_method_rec.Payment_Method_Name := null;
      l_payment_method_rec.Payment_Method_Code := null;
      l_payment_method_rec.Bill_Payable_Flag := null;
      l_payment_method_rec.Maturity_Date_Offset := null;
      evaluate_Rule_Based_Default(p_trxn_attributes_rec,l_payment_method_rec);
   END IF;

   -- Get Default Payee BankAccount cursor
   OPEN payee_bankaccount_cur(p_trxn_attributes_rec.Payee_Party_Id,
                              p_trxn_attributes_rec.Payee_Party_Site_Id,
                              p_trxn_attributes_rec.Supplier_Site_Id,
                              p_trxn_attributes_rec.Payer_Org_Id,
                              p_trxn_attributes_rec.Payer_Org_Type,
                              p_trxn_attributes_rec.Payment_Function,
                              p_trxn_attributes_rec.Payment_Currency);
   FETCH payee_bankaccount_cur INTO l_payee_bankaccount_rec;
   CLOSE payee_bankaccount_cur;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name,'Default payee bank account     : '|| l_payee_bankaccount_rec.Payee_BankAccount_Name);

   END IF;
   -- Assign to ouput nested record structure
   x_default_pmt_attrs_rec.Payment_Method := l_payment_method_rec;
   x_default_pmt_attrs_rec.Payment_Format := l_payment_format_rec;
   x_default_pmt_attrs_rec.Payee_BankAccount := l_payee_bankaccount_rec;
   x_default_pmt_attrs_rec.Payment_Reason := l_payment_reason_rec;
   x_default_pmt_attrs_rec.Delivery_Channel := l_delivery_channel_rec;
   x_default_pmt_attrs_rec.Bank_Charge_Bearer := l_bank_charge_bearer;
   x_default_pmt_attrs_rec.Pay_Alone := l_pay_alone;
   x_default_pmt_attrs_rec.Settlement_Priority := l_settlement_priority;
   x_default_pmt_attrs_rec.payment_reason_comments :=l_payment_reason_comments;
   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');

   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                  l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

END Get_Default_Payment_Attributes;

-- Start of comments
--   API name     : Get_Default_Payee_Bank_Acc
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : get the default payee bank account attributes.
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type Required
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--                    x_payee_bankaccount        OUT Payee_BankAccount_Rec_Type Required
--
--   Version   : Current version   1.0
--               Previous version   None
--               Initial version    1.0
-- End of comments

PROCEDURE Get_Default_Payee_Bank_Acc(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 default FND_API.G_FALSE,
    p_trxn_attributes_rec     IN   Trxn_Attributes_Rec_Type,
    x_return_status           OUT  NOCOPY VARCHAR2,
    x_msg_count               OUT  NOCOPY NUMBER,
    x_msg_data                OUT  NOCOPY VARCHAR2,
    x_payee_bankaccount       OUT  NOCOPY Payee_BankAccount_Rec_Type
)
IS
   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_Default_Payment_Attributes';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.Get_Default_Payee_Bank_Acc';

   l_payee_bankaccount_rec Payee_BankAccount_Rec_Type;

   CURSOR payee_bankaccount_cur(p_payee_party_id VARCHAR2,
                                p_payee_party_site_id VARCHAR2,
                                p_payer_org_id NUMBER,
                                p_payer_org_type VARCHAR2,
                                p_payment_function VARCHAR2,
                                p_payment_currency  VARCHAR2)
     IS
     SELECT b.bank_account_name,
            b.ext_bank_account_id,
            b.bank_account_number,
            b.currency_code,
            b.iban_number,
            b.bank_name,
            b.bank_number,
            b.bank_branch_name,
            b.branch_number,
            b.country_code,
            b.alternate_account_name,
            b.bank_account_type,
            b.account_suffix,
            b.description,
            b.foreign_payment_use_flag,
            b.payment_factor_flag,
            b.eft_swift_code
       FROM IBY_PMT_INSTR_USES_ALL ibyu,
            IBY_EXT_BANK_ACCOUNTS_V b,
            IBY_EXTERNAL_PAYEES_ALL ibypayee
       WHERE ibyu.instrument_id = b.ext_bank_account_id
       AND ibyu.instrument_type = 'BANKACCOUNT'
       AND (b.currency_code = p_payment_currency
            OR b.currency_code is null
	    OR NVL(b.foreign_payment_use_flag,'N')='Y')
       AND ibyu.payment_function = p_payment_function
       AND ibyu.ext_pmt_party_id = ibypayee.ext_payee_id
       AND ibypayee.payee_party_id = p_payee_party_id
       AND trunc(sysdate) between NVL(ibyu.start_date,trunc(sysdate)) AND
                                  NVL(ibyu.end_date-1,trunc(sysdate))
       AND trunc(sysdate) between NVL(b.start_date,trunc(sysdate)) AND
                                  NVL(b.end_date-1,trunc(sysdate))
       AND (ibypayee.party_site_id is null
            OR ibypayee.party_site_id = p_payee_party_site_id)
       AND (ibypayee.org_id is null
            OR (ibypayee.org_id = p_payer_org_id AND ibypayee.org_type = p_payer_org_type) )
       ORDER by ibypayee.party_site_id, ibypayee.org_id, ibyu.order_of_preference;

BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name,'ENTER');
	    print_debuginfo(l_module_name,'Application_id   : '|| p_trxn_attributes_rec.application_id);
	    print_debuginfo(l_module_name,'Org Id           : '|| p_trxn_attributes_rec.payer_org_id);
	    print_debuginfo(l_module_name,'Org Type         : '|| p_trxn_attributes_rec.payer_org_type);
	    print_debuginfo(l_module_name,'Payee Id         : '|| p_trxn_attributes_rec.payee_party_id);
	    print_debuginfo(l_module_name,'Payee Site Id    : '|| p_trxn_attributes_rec.payee_party_site_id);
	    print_debuginfo(l_module_name,'Payment Currency : '|| p_trxn_attributes_rec.payment_currency);
	    print_debuginfo(l_module_name,'Payment Function : '|| p_trxn_attributes_rec.payment_function);

    END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start of API body
   OPEN payee_bankaccount_cur(p_trxn_attributes_rec.Payee_Party_Id,
                              p_trxn_attributes_rec.Payee_Party_Site_Id,
                              p_trxn_attributes_rec.Payer_Org_Id,
                              p_trxn_attributes_rec.Payer_Org_Type,
                              p_trxn_attributes_rec.Payment_Function,
                              p_trxn_attributes_rec.Payment_Currency);
   FETCH payee_bankaccount_cur INTO l_payee_bankaccount_rec;
   CLOSE payee_bankaccount_cur;

   x_payee_bankaccount := l_payee_bankaccount_rec;
   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');

   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                  l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

END Get_Default_Payee_Bank_Acc;

-- Start of comments
--   API name     : Get_Payment_Field_Properties
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : get the list of applicable Payment attributes.
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_application_id           IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_validation_level         IN  NUMBER   Optional
--                    p_payment_method_id        IN  BY_PAYMENT_METHODS_VL.payment_method_id%TYPE Required
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--                    x_Payment_Field_Properties OUT Payment_Field_Properties_Rec_Type Required
--
--   Version   : Current version   1.0
--                      Previous version   None
--                      Initial version    1.0
-- End of comments

PROCEDURE Get_Payment_Field_Properties (
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_payment_method_id        IN
                        IBY_PAYMENT_METHODS_VL.payment_method_code%TYPE,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2,
     x_Payment_Field_Properties OUT  NOCOPY Applicable_Pmt_Attrs_Rec_Type
)
IS
   l_api_name         CONSTANT VARCHAR2(30)   := 'Get_Payment_Field_Properties';
   l_api_version      CONSTANT NUMBER         := 1.0;
   l_module_name      CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.Get_Payment_Field_Properties';

   l_Payment_Field_Properties Applicable_Pmt_Attrs_Rec_Type;

   cursor pmt_field_prop_csr(p_payment_method_code varchar2)
   IS
   SELECT payment_reason_comnt_apl_flag,
          remittance_message1_apl_flag,
          remittance_message2_apl_flag,
          remittance_message3_apl_flag,

          unique_remittance_id_apl_flag,
          uri_check_digit_apl_flag,
          payment_format_apl_flag,
           delivery_channel_apl_flag,
          bank_charge_bearer_apl_flag,
          settlement_priority_apl_flag,
          payment_reason_apl_flag,
          external_bank_acct_apl_flag,
          exclusive_pmt_apl_flag,
          inactive_date
   FROM IBY_PAYMENT_METHODS_B
   WHERE payment_method_code = p_payment_method_code;

BEGIN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'ENTER');
	   print_debuginfo(l_module_name,'Payment Method Id : '|| p_payment_method_id);

   END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
 --  print_debuginfo(l_module_name,'Before fetch');
   OPEN pmt_field_prop_csr(p_payment_method_id);
   FETCH pmt_field_prop_csr INTO l_Payment_Field_Properties;

    --    print_debuginfo(l_module_name,'After fetch');
   IF (trunc(sysdate) < NVL(l_Payment_Field_Properties.inactive_date, trunc(sysdate))) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Payment Method is inactive.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_INACTIVE_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('PARAM', 'Payment Method');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      x_Payment_Field_Properties := l_Payment_Field_Properties;
   END IF;

   CLOSE pmt_field_prop_csr;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');
   END IF;
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                  l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

END Get_Payment_Field_Properties;


-- Start of comments
--   API name     : ValidateDocument
--   Type         : Public
--   Pre-reqs     : None.
--   Function     : validates the documents in the global temporary table
--                  IBY_DOCUMENTS_PAYABLE_GT
--   Parameters   :
--   IN           :   p_api_version              IN  NUMBER   Required
--                    p_application_id           IN  NUMBER   Required
--                    p_init_msg_list            IN  VARCHAR2 Optional
--                    p_validation_level         IN  NUMBER   Optional
--
--   OUT          :   x_return_status            OUT VARCHAR2 Required
--                    x_msg_count                OUT NUMBER   Required
--                    x_msg_data                 OUT VARCHAR2 Required
--
--
--   Version   : Current version   1.0
--                      Previous version   None
--                      Initial version    1.0
-- End of comments

PROCEDURE Validate_Documents(
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_document_id              IN   IBY_DOCS_PAYABLE_ALL.document_payable_id%TYPE,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2
)
IS
   l_api_name         CONSTANT VARCHAR2(30)   := 'ValidateDocument';
   l_api_version      CONSTANT NUMBER         := 1.0;
   l_module_name      CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.ValidateDocument';

   l_return_status    VARCHAR2(10);

BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'ENTER');

    END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start of API body.

   IBY_VALIDATIONSETS_PUB.performOnlineValidations(p_document_id,l_return_status);

   IF (l_return_status = -1) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
   ELSE
       x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');

   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	       print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
       END IF;
       IF (FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                  l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data => x_msg_data);

END Validate_Documents;

--
--
--

Procedure evaluate_Rule_Based_Default(
                   p_trxn_attributes   IN   Trxn_Attributes_Rec_Type,
                   x_pmt_method_rec    IN OUT  NOCOPY Payment_Method_Rec_Type)
IS

  l_module_name      CONSTANT VARCHAR2(200) := G_PKG_NAME || '.Evaluate_Rule_Based_Default';

  l_payer_le_flag             BOOLEAN      := FALSE;
  l_payer_org_flag            BOOLEAN      := FALSE;
  l_trxn_type_flag            BOOLEAN      := FALSE;
  l_currency_flag             BOOLEAN      := FALSE;
  l_cross_border_flag         BOOLEAN      := FALSE;
  l_pmt_amount_flag           BOOLEAN      := FALSE;

  l_match                     BOOLEAN      := FALSE;

  -- the cummulative flags for each driver type
  l_cumm_payer_le_match       BOOLEAN      := TRUE;
  l_cumm_payer_org_match      BOOLEAN      := TRUE;
  l_cumm_trxn_type_match      BOOLEAN      := TRUE;
  l_cumm_currency_match       BOOLEAN      := TRUE;
  l_cumm_cross_border_match   BOOLEAN      := TRUE;
  l_cumm_pmt_amount_match     BOOLEAN      := TRUE;


  l_payer_country               VARCHAR2(30);
  l_payee_country               VARCHAR2(30);
  l_accounting_curr             VARCHAR2(30);

    -- Pick up all rules for active payment methods.
CURSOR DefaultingRules_csr( p_application_id NUMBER,
			        p_pay_proc_trxn_type VARCHAR2,
				p_payer_le_id NUMBER,
				p_payer_org_id NUMBER)
    IS
      SELECT ibypmtrules.payment_rule_id,
             ibypmtmthds.payment_method_code,
             ibypmtmthds.payment_method_name,
             ibypmtmthds.support_bills_payable_flag,
             ibypmtmthds.maturity_date_offset_days
      FROM  IBY_PAYMENT_RULES ibypmtrules,
            IBY_PAYMENT_METHODS_VL ibypmtmthds,
	    IBY_APPLICABLE_PMT_MTHDS am1,
	    IBY_APPLICABLE_PMT_MTHDS am2,
	    IBY_APPLICABLE_PMT_MTHDS am3
      WHERE ibypmtrules.payment_method_code = ibypmtmthds.payment_method_code
      AND   ibypmtrules.application_id = p_application_id
      AND   NVL(ibypmtmthds.inactive_date,trunc(sysdate)) >= trunc(sysdate)
      AND   am1.payment_method_code=ibypmtmthds.payment_method_code
      AND   am1.applicable_type_code='PAY_PROC_TRXN_TYPE'
      AND   am1.application_id= p_application_id
      AND   (am1.applicable_value_to is null or
		am1.applicable_value_to=p_pay_proc_trxn_type)
      AND   am2.payment_method_code=am1.payment_method_code
      AND   am2.applicable_type_code='PAYER_LE'
      AND   am2.application_id= p_application_id
      AND   (am2.applicable_value_to is null or
		am2.applicable_value_to=p_payer_le_id)
      AND   am3.payment_method_code=am2.payment_method_code
      AND   am3.applicable_type_code='PAYER_ORG'
      AND   am3.application_id= p_application_id
      AND   (am3.applicable_value_to is null or
		am3.applicable_value_to=p_payer_org_id)
      ORDER BY ibypmtrules.payment_rule_priority;


     -- Pick up all conditions for a given payment rule.
    CURSOR DefaultingCondt_csr(p_payment_rule_id NUMBER)
    IS
      SELECT rule_condition_type_code,
             operator_code,
             rule_condition_value
      FROM IBY_RULE_CONDITIONS ibyruleconds
      WHERE ibyruleconds.payment_rule_id = p_payment_rule_id;

    CURSOR payer_info_csr(p_le_id IN NUMBER)
    IS
      SELECT xlev.country,
             glv.currency_code
        FROM XLE_FIRSTPARTY_INFORMATION_V xlev,
             GL_LEDGER_LE_V glv
       WHERE xlev.legal_entity_id = glv.legal_entity_id
         AND glv.ledger_category_code = 'PRIMARY'
         AND xlev.legal_entity_id = p_le_id;

    CURSOR payee_country_csr(p_payee_id IN NUMBER)
    IS
      SELECT country
        FROM HZ_PARTIES
       WHERE party_id = p_payee_id;

    CURSOR payeesite_country_csr(p_payee_id IN NUMBER,
                                 p_payee_site_id IN NUMBER)
    IS
      SELECT locs.country
        FROM HZ_PARTY_SITES sites,
             HZ_LOCATIONS locs
       WHERE sites.party_id = p_payee_id
         AND sites.party_site_id = p_payee_site_id
         AND sites.location_id = locs.location_id;

BEGIN
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'ENTER');

   END IF;
    -- Fetch 1st party Payer country
    IF (p_trxn_attributes.payer_legal_entity_id IS NOT NULL) THEN
        OPEN payer_info_csr(p_trxn_attributes.payer_legal_entity_id);
        FETCH payer_info_csr INTO l_payer_country, l_accounting_curr;
        CLOSE payer_info_csr;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name,'Accounting currency : '|| l_accounting_curr);
	    print_debuginfo(l_module_name,'First party country : '|| l_payer_country);

    END IF;
    IF (p_trxn_attributes.payee_party_id IS NOT NULL) THEN
        IF (p_trxn_attributes.payee_party_site_id IS NOT NULL) THEN
            -- Fetch Payee Site Country
            OPEN payeesite_country_csr(p_trxn_attributes.payee_party_id,
                                       p_trxn_attributes.payee_party_site_id);
            FETCH payeesite_country_csr INTO l_payee_country;
            CLOSE payeesite_country_csr;
        ELSE
          -- Fetch Payee Country
          OPEN payee_country_csr(p_trxn_attributes.payee_party_site_id);
          FETCH payee_country_csr INTO l_payee_country;
          CLOSE payee_country_csr;
        END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo(l_module_name, 'Payee Country : '|| l_payee_country);

    END IF;
     FOR v_defaultingRules IN DefaultingRules_csr(
				p_trxn_attributes.application_id,
				p_trxn_attributes.pay_proc_trxn_type_code,
				p_trxn_attributes.Payer_Legal_Entity_Id,
				p_trxn_attributes.payer_org_id)
      LOOP
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name,'Evaluate Rule:' || v_defaultingRules.payment_rule_id);
            END IF;
      FOR v_ruleCondt IN DefaultingCondt_csr(v_defaultingRules.payment_rule_id)
         LOOP
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name,'Evaluate Rule Condition:' || v_ruleCondt.rule_condition_value);
              END IF;
         --
         -- evaluate rule condition based on 'PAYMENT_AMOUNT'
         -- and the operators are "EQ", "NE", "LE", "LT",  "GE", "GT"
         --
         IF (v_ruleCondt.rule_condition_type_code = 'PAYMENT_AMOUNT') THEN

	        CASE v_ruleCondt.operator_code
            WHEN 'EQ' THEN
               l_pmt_amount_flag := l_pmt_amount_flag
	                                OR (p_trxn_attributes.payment_amount =
				                        v_ruleCondt.rule_condition_value);
            WHEN 'NE' THEN
               l_pmt_amount_flag := l_pmt_amount_flag
	                                OR (p_trxn_attributes.payment_amount <>
				                        v_ruleCondt.rule_condition_value);
            WHEN 'LE' THEN
               l_pmt_amount_flag := l_pmt_amount_flag
	                                OR (p_trxn_attributes.payment_amount <=
				                        v_ruleCondt.rule_condition_value);
            WHEN 'LT' THEN
               l_pmt_amount_flag := l_pmt_amount_flag
	                                OR (p_trxn_attributes.payment_amount <
				                        v_ruleCondt.rule_condition_value);
            WHEN 'GE' THEN
               l_pmt_amount_flag := l_pmt_amount_flag
	                                OR (p_trxn_attributes.payment_amount >=
				                        v_ruleCondt.rule_condition_value);
            WHEN 'GT' THEN
               l_pmt_amount_flag := l_pmt_amount_flag
	                                OR (p_trxn_attributes.payment_amount >
		    	                        v_ruleCondt.rule_condition_value);
            ELSE
               NULL; -- Not a recognized operator code
            END CASE;

            l_cumm_pmt_amount_match := l_pmt_amount_flag;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'l_cumm_pmt_amount_match   :'
	                            || ifelse(l_cumm_pmt_amount_match,'true','false'));
            END IF;

         --
         -- evaluate rule condition based on 'PAYER_ORG'
         -- and the operators are "EQ" , "NE"
         --
         ELSIF (v_ruleCondt.rule_condition_type_code = 'PAYER_ORG') THEN

            CASE v_ruleCondt.operator_code
            WHEN 'EQ' THEN
	           l_payer_org_flag := l_payer_org_flag
                                         OR (v_ruleCondt.rule_condition_value is NULL)
	                                OR (p_trxn_attributes.Payer_Org_Id =
				                        v_ruleCondt.rule_condition_value);
            WHEN 'NE' THEN
               l_payer_org_flag := l_payer_org_flag
	                                OR (p_trxn_attributes.Payer_Org_Id <>
				                        v_ruleCondt.rule_condition_value);
            ELSE
               NULL; -- Not a recognized operator code
            END CASE;

            l_cumm_payer_org_match := l_payer_org_flag;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'l_cumm_payer_org_match    :'
	                            || ifelse(l_cumm_payer_org_match,'true','false'));

            END IF;
         --
         -- evaluate rule condition based on 'PAYER_lE'
         -- and the operators are "EQ" , "NE"
         --
         ELSIF (v_ruleCondt.rule_condition_type_code = 'PAYER_LE') THEN

            CASE v_ruleCondt.operator_code
            WHEN 'EQ' THEN
	           l_payer_le_flag := l_payer_le_flag
                                           OR (v_ruleCondt.rule_condition_value is NULL)
	                                OR (p_trxn_attributes.payer_legal_entity_id =
				                        v_ruleCondt.rule_condition_value);
            WHEN 'NE' THEN
               l_payer_le_flag := l_payer_le_flag
	                                OR (p_trxn_attributes.payer_legal_entity_id <>
				                        v_ruleCondt.rule_condition_value);
            ELSE
               NULL; -- Not a recognized operator code
            END CASE;

            l_cumm_payer_le_match := l_payer_le_flag;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'l_cumm_payer_le_match     :'
	                            || ifelse(l_cumm_payer_le_match,'true','false'));

            END IF;
         --
         -- evaluate rule condition based on 'PAY_PROC_TRXN_TYPE'
         -- and the operators are "EQ" , "NE"
         --
         ELSIF (v_ruleCondt.rule_condition_type_code = 'PAY_PROC_TRXN_TYPE') THEN

            CASE v_ruleCondt.operator_code
            WHEN 'EQ' THEN
	           l_trxn_type_flag := l_trxn_type_flag
                                           OR (v_ruleCondt.rule_condition_value is NULL)
	                                OR (p_trxn_attributes.Pay_Proc_Trxn_Type_Code =
				                        v_ruleCondt.rule_condition_value);
            WHEN 'NE' THEN
               l_trxn_type_flag := l_trxn_type_flag
	                                OR (p_trxn_attributes.Pay_Proc_Trxn_Type_Code <>
				                        v_ruleCondt.rule_condition_value);
            ELSE
               NULL; -- Not a recognized operator code
            END CASE;

            l_cumm_trxn_type_match := l_trxn_type_flag;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name, 'l_cumm_trxn_type_match    :'
	                            || ifelse(l_cumm_trxn_type_match,'true','false'));


            END IF;
         --
         -- evaluate rule condition based on 'CROSS_BORDER_FLAG'
         -- and the operators are "EQ"
         --
         ELSIF (v_ruleCondt.rule_condition_type_code = 'CROSS_BORDER_FLAG') THEN

            CASE v_ruleCondt.operator_code
            WHEN 'EQ' THEN
	           l_cross_border_flag := l_cross_border_flag
                                          OR (v_ruleCondt.rule_condition_value='FOREIGN_AND_DOMESTIC')
	                                  OR (v_ruleCondt.rule_condition_value = 'DOMESTIC'
				                          AND NVL(l_payee_country,l_payer_country) = l_payer_country)
                                      OR (v_ruleCondt.rule_condition_value = 'FOREIGN'
				                          AND NVL(l_payee_country,l_payer_country) <> l_payer_country);
            ELSE
               NULL; -- Not a recognized operator code
            END CASE;

            l_cumm_cross_border_match := l_cross_border_flag;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name,'l_cumm_cross_border_match    :'
	                            || ifelse(l_cumm_cross_border_match,'true','false'));


            END IF;
         --
         -- evaluate rule condition based on 'FOREIGN_CURRENCY_FLAG'
         -- and the operators are "EQ"
         --
         ELSIF (v_ruleCondt.rule_condition_type_code = 'FOREIGN_CURRENCY_FLAG') THEN

            CASE v_ruleCondt.operator_code
            WHEN 'EQ' THEN
	           l_currency_flag := l_currency_flag
                                        OR (v_ruleCondt.rule_condition_value='FOREIGN_AND_DOMESTIC')
	                              OR (v_ruleCondt.rule_condition_value = 'DOMESTIC'
                                      AND p_trxn_attributes.Payment_Currency = l_accounting_curr)
                                  OR (v_ruleCondt.rule_condition_value = 'FOREIGN'
                                      AND p_trxn_attributes.Payment_Currency <> l_accounting_curr);

            ELSE
               NULL; -- Not a recognized operator code
            END CASE;

            l_cumm_currency_match := l_currency_flag;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_module_name,'l_cumm_currency_match    :'
	                            || ifelse(l_cumm_currency_match,'true','false'));
            END IF;
         END IF; -- if v_ruleCondt.parameter_code = 'PAYMENT_AMOUNT'

      END LOOP;

      l_match := (l_cumm_payer_le_match AND l_cumm_payer_org_match AND
                  l_cumm_trxn_type_match AND l_cumm_currency_match AND
	              l_cumm_cross_border_match AND l_cumm_pmt_amount_match);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'l_match                   :'
	                      ||ifelse(l_match,'true','false'));

      END IF;
      IF (l_match = TRUE) THEN
         x_pmt_method_rec.Payment_Method_Name :=
                          v_DefaultingRules.payment_method_name;
         x_pmt_method_rec.Payment_Method_Code :=
                          v_DefaultingRules.payment_method_code;
         x_pmt_method_rec.Bill_Payable_Flag :=
                          v_DefaultingRules.support_bills_payable_flag;
         x_pmt_method_rec.Maturity_Date_Offset :=
                          v_DefaultingRules.maturity_date_offset_days;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'Default Payment Method Name :'
	                         ||v_DefaultingRules.payment_method_name);
         END IF;
         EXIT;
      END IF;
   END LOOP;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');

   END IF;
END Evaluate_Rule_Based_Default;


 --
 --
 --
 PROCEDURE print_debuginfo(p_module IN VARCHAR2,
                           p_debug_text IN VARCHAR2)
 IS

 l_default_debug_level VARCHAR2(200) := FND_LOG.LEVEL_STATEMENT;

 BEGIN

     --
     -- Writing debug text to the pl/sql debug file.
     --
     -- FND_FILE.PUT_LINE(FND_FILE.LOG, p_module||p_debug_text);
     --

     /*
      * Fix for bug 5578607:
      *
      * Call the underlying routine only if the current debug
      * level exceeds the runtime debug level.
      */
     IF (l_default_debug_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

         iby_debug_pub.add(substr(RPAD(p_module,55)||' : '||
                           p_debug_text, 0, 150),
                           iby_debug_pub.G_LEVEL_INFO,
                           G_DEBUG_MODULE);

     END IF;

 END print_debuginfo;

 --
 --
 --
 FUNCTION ifelse(p_bool IN BOOLEAN,
                 x_true IN VARCHAR2,
                 x_false IN VARCHAR2)
 RETURN VARCHAR2
 IS
 BEGIN
     --
     --
     --
     IF (p_bool) THEN
        RETURN x_true;
     ELSE
        RETURN x_false;
     END IF;

 END ifelse;


   -- Start of comments
  --   API name     : Get_Applicable_Payee_Acc_list
  --   Type         : Public
  --   Pre-reqs     : None.
  --   Function     : get the list of all applicable Payee Bank Accounts.
  --   Parameters   :
  --   IN           :   p_api_version              IN  NUMBER   Required
  --                    p_init_msg_list            IN  VARCHAR2 Optional
  --                    p_trxn_attributes_rec      IN  Trxn_Attributes_Rec_Type  Required
  --   OUT          :   x_return_status            OUT VARCHAR2 Required
  --                    x_msg_count                OUT NUMBER   Required
  --                    x_msg_data                 OUT VARCHAR2 Required
  --                    x_payee_bankaccounts_tbl   OUT Payee_BankAccount_Tab_Type Required
  --
  --   Version   : Current version   1.0
  --                      Previous version   None
  --                      Initial version    1.0
  -- End of comments

PROCEDURE Get_Applicable_Payee_Acc_list (
     p_api_version               IN   NUMBER,
     p_init_msg_list             IN   VARCHAR2 default FND_API.G_FALSE,
     p_trxn_attributes_rec       IN   Trxn_Attributes_Rec_Type,
     x_return_status             OUT  NOCOPY VARCHAR2,
     x_msg_count                 OUT  NOCOPY NUMBER,
     x_msg_data                  OUT  NOCOPY VARCHAR2,
     x_payee_bankaccounts_tbl    OUT  NOCOPY Payee_BankAccount_Tab_Type
)
IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_Applicable_Payee_BankAccts';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.Get_Applicable_Payee_BankAccts';

   l_payee_bankaccounts_tbl    Payee_BankAccount_Tab_Type;

   CURSOR payee_bankacct_csr(p_payee_party_id      NUMBER,
                             p_payee_party_site_id NUMBER,
                             p_supplier_site_id    NUMBER,
                             p_payer_org_id        NUMBER,
                             p_payer_org_type      VARCHAR2,
                             p_payment_currency    VARCHAR2,
                             p_payment_function    VARCHAR2)
   IS
      SELECT b.bank_account_name,
             b.ext_bank_account_id,
             b.bank_account_number,
	     b.currency_code,
 	     b.iban_number,
 	     b.bank_name,
 	     b.bank_number,
 	     b.bank_branch_name,
 	     b.branch_number,
 	     b.country_code,
 	     b.alternate_account_name,
 	     b.bank_account_type,
 	     b.account_suffix,
 	     b.description,
 	     b.foreign_payment_use_flag,
 	     b.payment_factor_flag,
 	     b.eft_swift_code
      FROM   IBY_PMT_INSTR_USES_ALL ibyu,
             IBY_EXT_BANK_ACCOUNTS_V b,
             IBY_EXTERNAL_PAYEES_ALL ibypayee
      WHERE ibyu.instrument_id = b.ext_bank_account_id
      AND ibyu.instrument_type = 'BANKACCOUNT'
      AND (b.currency_code = p_payment_currency OR b.currency_code is null
           OR NVL(b.foreign_payment_use_flag,'N')='Y')
      AND ibyu.ext_pmt_party_id = ibypayee.ext_payee_id
      AND ibypayee.payment_function = p_payment_function
      AND ibypayee.payee_party_id = p_payee_party_id
      AND trunc(sysdate) between
              NVL(ibyu.start_date,trunc(sysdate)) AND NVL(ibyu.end_date-1,trunc(sysdate))
      AND trunc(sysdate) between
              NVL(b.start_date,trunc(sysdate)) AND NVL(b.end_date-1,trunc(sysdate))
      AND (ibypayee.party_site_id is null OR ibypayee.party_site_id = p_payee_party_site_id)
      AND (ibypayee.supplier_site_id is null OR ibypayee.supplier_site_id = p_supplier_site_id)
      AND (ibypayee.org_id is null OR
           (ibypayee.org_id = p_payer_org_id AND ibypayee.org_type = p_payer_org_type))
       AND ibyu.payment_flow='DISBURSEMENTS'
	          ORDER BY
		          ibypayee.supplier_site_id,
		          ibypayee.party_site_id,
			  ibypayee.org_id,
			  ibyu.order_of_preference;

BEGIN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name,'ENTER');
	   print_debuginfo(l_module_name,'Org Id           : '|| p_trxn_attributes_rec.payer_org_id);
	   print_debuginfo(l_module_name,'Org Type         : '|| p_trxn_attributes_rec.payer_org_type);
	   print_debuginfo(l_module_name,'Party Id         : '|| p_trxn_attributes_rec.payee_party_id);
	   print_debuginfo(l_module_name,'Party Site Id    : '|| p_trxn_attributes_rec.payee_party_site_id);
	   print_debuginfo(l_module_name,'Supplier Site Id : '|| p_trxn_attributes_rec.supplier_site_id);
	   print_debuginfo(l_module_name,'Payment Currency : '|| p_trxn_attributes_rec.payment_currency);
	   print_debuginfo(l_module_name,'Payment Amount   : '|| p_trxn_attributes_rec.payment_amount);
	   print_debuginfo(l_module_name,'Account Usage    : '|| p_trxn_attributes_rec.payment_function);

   END IF;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check for mandatory params
   IF (p_trxn_attributes_rec.payee_party_id IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Payee Party Id'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_PAYEE_PARTY_ID_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_trxn_attributes_rec.payment_currency IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Payment Currency'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_PMT_CURR_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_trxn_attributes_rec.payment_function IS NULL) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Error: Mandatory Parameter ''Account Usage'' missing.');
      END IF;
      FND_MESSAGE.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', fnd_message.GET_String('IBY','IBY_ACCT_USG_FIELD'));
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Start of API body.
   OPEN payee_bankacct_csr(p_trxn_attributes_rec.Payee_Party_Id,
                           p_trxn_attributes_rec.Payee_Party_Site_Id,
                           p_trxn_attributes_rec.Supplier_Site_Id,
                           p_trxn_attributes_rec.Payer_Org_Id,
                           p_trxn_attributes_rec.Payer_Org_Type,
                           p_trxn_attributes_rec.Payment_Currency,
                           p_trxn_attributes_rec.Payment_Function);

   FETCH payee_bankacct_csr BULK COLLECT INTO l_payee_bankaccounts_tbl;
   CLOSE payee_bankacct_csr;

   IF (l_payee_bankaccounts_tbl.COUNT = 0) THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Warning: No Payee Bank Accounts Applicable');
      END IF;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'Applicable Payee Bank Accounts Count : '|| l_payee_bankaccounts_tbl.COUNT);
      END IF;
      x_payee_bankaccounts_tbl := l_payee_bankaccounts_tbl;
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'RETURN');

   END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR))
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
	      print_debuginfo(l_module_name,'SQLerr is :'
	                           || substr(SQLERRM, 1, 150));
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

END Get_Applicable_Payee_Acc_list;

END IBY_DISBURSEMENT_COMP_PUB;

/
