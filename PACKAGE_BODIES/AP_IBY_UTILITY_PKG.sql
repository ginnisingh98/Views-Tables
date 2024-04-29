--------------------------------------------------------
--  DDL for Package Body AP_IBY_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_IBY_UTILITY_PKG" as
/* $Header: apibexub.pls 120.5 2006/02/24 02:38:06 mswamina noship $ */

  -- Package global
-- FND_LOG related variables to enable logging for this package
   --
   G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_IBY_UTILITY_PKG';
   G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
   G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
   G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
   G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
   G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
   G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

   G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'AP.PLSQL.AP_IBY_UTILITY_PKG.';

  FUNCTION Get_Default_Iby_Bank_Acct_Id (
             X_Vendor_Id        IN      NUMBER,
             X_Vendor_Site_Id   IN      NUMBER    DEFAULT NULL,
             X_Payment_Function IN      VARCHAR2  DEFAULT NULL, /* bug 5000194 */
             X_Org_Id           IN      NUMBER    DEFAULT NULL,
             X_Currency_Code    IN      VARCHAR2,
             X_Calling_Sequence IN      VARCHAR2  DEFAULT NULL )
  RETURN NUMBER
  IS

    Iby_Trxn_Attributes_Rec       IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
    Iby_Payee_BankAccount_Rec     IBY_DISBURSEMENT_COMP_PUB.Payee_BankAccount_Rec_Type;

    l_default_bank_acct_id      NUMBER;
    l_current_calling_sequence  VARCHAR2(2000);
    l_debug_info                VARCHAR2(2000);
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER(15);
    l_msg_data                  VARCHAR2(2000);
    l_api_name         CONSTANT VARCHAR2(100) := 'GET_DEFAULT_IBY_BANK_ACCT_ID';
    l_error_msg                 VARCHAR2(2000);
    l_vendor_type_lookup_code   VARCHAR2(30);  -- bug 5000194

    IBY_API_ERROR               EXCEPTION;

  BEGIN

    l_current_calling_sequence := X_calling_sequence||'->'||
           'AP_IBY_UTILITY_PKG.Get_Default_Iby_Bank_Acct_Id';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' X_Vendor_Id: '|| X_Vendor_Id
                     ||', X_Vendor_Site_Id: '||X_Vendor_Site_Id
                     ||', X_Org_Id: '||X_Org_Id
                     ||', X_Currency_Code: '||X_Currency_Code);
    END IF;

    l_debug_info := 'Populating IBY_Txn_Attriibuytes_Rec';

    Iby_Trxn_Attributes_Rec.Application_Id   := 200;
    Iby_Trxn_Attributes_Rec.Payer_Org_Id     := X_org_id;
    Iby_Trxn_Attributes_Rec.Payer_Org_Type   := 'OPERATING_UNIT';
    Iby_Trxn_Attributes_Rec.Supplier_Site_Id := X_Vendor_Site_Id;
    Iby_Trxn_Attributes_Rec.Payment_Currency := X_Currency_Code;
    --
    /* Bug 5000194 */

    -- As per the discussion with Omar/Jayanta, we will only
    -- have payables payment function and no more employee expenses
    -- payment function.

    Begin
      Select party_id,  'PAYABLES_DISB',
          vendor_type_lookup_code
      Into Iby_Trxn_Attributes_Rec.Payee_Party_Id,
           Iby_Trxn_Attributes_Rec.Payment_Function,
           l_vendor_type_lookup_code
      From Ap_Suppliers
      Where vendor_id = X_Vendor_Id;
    Exception
      WHEN NO_DATA_FOUND THEN
      l_debug_info  := 'Supplier Does not exists';
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      Raise IBY_API_ERROR;
    End;


    /* Bug 500194. Based on bug 4965233 party_site_id will be null
       for employee */
    IF X_Vendor_Site_Id IS NOT NULL AND l_vendor_type_lookup_code  <> 'EMPLOYEE' THEN

      Select party_site_id
      Into Iby_Trxn_Attributes_Rec.Payee_Party_Site_Id
      From Ap_Supplier_Sites_All
      Where vendor_site_id = X_Vendor_Site_Id;

    END IF;

    l_debug_info := 'Calling IBY API';

    IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payee_Bank_Acc
      (p_api_version           =>  1.0,
       p_init_msg_list         =>  FND_API.G_TRUE,
       p_trxn_attributes_rec   =>  Iby_Trxn_Attributes_Rec,
       x_return_status         =>  l_return_status,
       x_msg_count             =>  l_msg_count,
       x_msg_data              =>  l_msg_data,
       x_payee_bankaccount     =>  Iby_Payee_BankAccount_Rec);

     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_debug_info  := 'Sucessfull IBY API Call ';
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        l_default_bank_acct_id := Iby_Payee_BankAccount_Rec.Payee_BankAccount_Id;

     ELSE

       Raise IBY_API_ERROR;

     END IF;

     RETURN(l_default_bank_acct_id);

  EXCEPTION
    --
    WHEN IBY_API_ERROR THEN
      RETURN (NULL);
      IF (NVL(l_msg_count, 0) > 1) THEN
        FOR I IN 1..l_msg_count
        LOOP
          l_error_msg := FND_MSG_PUB.Get(p_msg_index => I,
                                         p_encoded   => 'T');
          FND_MESSAGE.Set_Encoded(l_error_msg);
        END LOOP;
      END IF;

      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('MSG_COUNT', l_msg_count );
      FND_MESSAGE.SET_TOKEN('MSG_DATA', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS','X_Vendor_Id: '||X_Vendor_Id
                              ||',X_vendor_Site_id: '||X_vendor_site_id);
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'IBY_API_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM );
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
        FND_MESSAGE.SET_TOKEN('PARAMETERS','X_Vendor_Id: '||X_Vendor_Id
                              ||',X_vendor_Site_id: '||X_vendor_site_id);
      END IF;
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;

  END Get_Default_Iby_Bank_Acct_Id;

  FUNCTION Get_Default_Iby_Bank_Acct_Id (
             X_Party_Id         IN      NUMBER,
             X_Payment_Function IN      VARCHAR2,
             X_Party_Site_Id    IN      NUMBER    DEFAULT NULL,
             X_Org_Id           IN      NUMBER    DEFAULT NULL,
             X_Currency_Code    IN      VARCHAR2,
             X_Calling_Sequence IN      VARCHAR2  DEFAULT NULL )
  RETURN NUMBER
  IS

    Iby_Trxn_Attributes_Rec       IBY_DISBURSEMENT_COMP_PUB.Trxn_Attributes_Rec_Type;
    Iby_Payee_BankAccount_Rec     IBY_DISBURSEMENT_COMP_PUB.Payee_BankAccount_Rec_Type;

    l_default_bank_acct_id      NUMBER;
    l_current_calling_sequence  VARCHAR2(2000);
    l_debug_info                VARCHAR2(2000);
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER(15);
    l_msg_data                  VARCHAR2(2000);
    l_api_name         CONSTANT VARCHAR2(100) := 'GET_DEFAULT_IBY_BANK_ACCT_ID';
    l_error_msg                 VARCHAR2(2000);
    IBY_API_ERROR               EXCEPTION;

  BEGIN

    l_current_calling_sequence := X_calling_sequence||'->'||
           'AP_IBY_UTILITY_PKG.Get_Default_Iby_Bank_Acct_Id';
    --
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' X_Party_Id: '|| X_Party_Id
                     ||', X_Party_Site_Id: '||X_Party_Site_Id
                     ||', X_Org_Id: '||X_Org_Id
                     ||', X_Payment_Function: '||X_Payment_Function
                     ||', X_Currency_Code: '||X_Currency_Code);
    END IF;

    l_debug_info := 'Populating IBY_Txn_Attriibuytes_Rec';

    Iby_Trxn_Attributes_Rec.Application_Id   := 200;
    Iby_Trxn_Attributes_Rec.Payer_Org_Id     := X_org_id;
    Iby_Trxn_Attributes_Rec.Payer_Org_Type   := 'OPERATING_UNIT';
    Iby_Trxn_Attributes_Rec.Payment_Currency := X_Currency_Code;
    Iby_Trxn_Attributes_Rec.Payee_Party_Id   := X_Party_Id;
    Iby_Trxn_Attributes_Rec.Payee_Party_Site_Id := X_Party_Site_Id;
    Iby_Trxn_Attributes_Rec.Payment_Function := X_Payment_Function;
    --
    l_debug_info := 'Calling IBY API';

    IBY_DISBURSEMENT_COMP_PUB.Get_Default_Payee_Bank_Acc
      (p_api_version           =>  1.0,
       p_init_msg_list         =>  FND_API.G_TRUE,
       p_trxn_attributes_rec   =>  Iby_Trxn_Attributes_Rec,
       x_return_status         =>  l_return_status,
       x_msg_count             =>  l_msg_count,
       x_msg_data              =>  l_msg_data,
       x_payee_bankaccount     =>  Iby_Payee_BankAccount_Rec);

     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_debug_info  := 'Sucessfull IBY API Call ';
        --
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        l_default_bank_acct_id := Iby_Payee_BankAccount_Rec.Payee_BankAccount_Id;

     ELSE

       Raise IBY_API_ERROR;

     END IF;

     RETURN(l_default_bank_acct_id);

   EXCEPTION
    --
    WHEN IBY_API_ERROR THEN
      RETURN (NULL);
      IF (NVL(l_msg_count, 0) > 1) THEN
        FOR I IN 1..l_msg_count
        LOOP
          l_error_msg := FND_MSG_PUB.Get(p_msg_index => I,
                                         p_encoded   => 'T');
          FND_MESSAGE.Set_Encoded(l_error_msg);
        END LOOP;
      END IF;

      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('MSG_COUNT', l_msg_count );
      FND_MESSAGE.SET_TOKEN('MSG_DATA', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS','X_Party_Id: '||X_Party_Id
                              ||',X_Party_Site_id: '||X_Party_site_id);
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'IBY_API_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM );
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
        FND_MESSAGE.SET_TOKEN('PARAMETERS','X_Party_Id: '||X_Party_Id
                              ||',X_party_Site_id: '||X_party_site_id);
      END IF;
      --
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;

  END Get_Default_Iby_Bank_Acct_Id;

END AP_IBY_UTILITY_PKG;

/
