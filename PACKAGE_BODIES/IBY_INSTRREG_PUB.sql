--------------------------------------------------------
--  DDL for Package Body IBY_INSTRREG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_INSTRREG_PUB" AS
/*$Header: ibypregb.pls 120.14.12010000.16 2009/07/30 08:43:10 lmallick ship $*/


     G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_INSTRREG_PUB';

     g_validation_level CONSTANT NUMBER  := FND_API.G_VALID_LEVEL_FULL;
     -- Owner Type is actually 'PAYER' but it has been kept as 'USER'
     -- as the java API uses it as the hardcoded value.
     -- Bug 4298732
     -- g_owner_type CONSTANT VARCHAR2(10)  := 'USER';
     g_owner_type CONSTANT VARCHAR2(10)  := 'PAYER';

-------------------------------------------------------------------------------
   /* UTILITY FUNCTION#2: ENCODE
      NOTE: Encoding method was moved to the utility package iby_utility_pvt;
            this now-wrapper function has not been completely removed b/c
            it was defined in the spec file and so is public and thus
            possibly used by existing customers
   */
-------------------------------------------------------------------------------

   FUNCTION encode(s IN VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
        RETURN iby_utility_pvt.encode64(s);
   END encode;

-------------------------------------------------------------------------------
   /* UTILITY FUNCTION#3: DECODE
      NOTE: See note for the ENCODE() function
   */
-------------------------------------------------------------------------------

   FUNCTION decode(s IN VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
       RETURN iby_utility_pvt.decode64(s);
   END decode;


-------------------------------------------------------------------------------
   /* UTILITY PROCEDURE #1: GET_INSTRUMENT_DETAILS
      This procedure will return all the instruments that it can find for a
      payer_id and instr_id.If the instr_id is NULL then it will return all the
      instruments for the payer_id alone. Each of the 3 PL/SQL tables that is
      returned will have a collection of a particular instrument.
      If instr_id is passed then only one instrument detail is returned.
   */
-------------------------------------------------------------------------------
  PROCEDURE Get_Instrument_Details ( payer_id            IN    VARCHAR2,
                                      instr_id            IN    NUMBER,
                                     sys_master_key      IN    IBY_SECURITY_PKG.DES3_KEY_TYPE,
                           creditcard_tbl      OUT NOCOPY CreditCard_tbl_type,
                      purchasecard_tbl    OUT NOCOPY PurchaseCard_tbl_type,
                 bankacct_tbl        OUT NOCOPY BankAcct_tbl_type
                          ) IS
        l_count INTEGER;
        l_ccsubtype iby_creditcard.subtype%TYPE;

        lx_pcard_flag  iby_creditcard.purchasecard_flag%TYPE;
        lx_pcard_type  iby_creditcard.purchasecard_subtype%TYPE;

        lx_result_code VARCHAR(30);

        -- only query wanted instrument id's; then use these
        -- in calls to the iby_creditcard_pkg which will take
        -- care of decryption, etc.
        --
        CURSOR load_creditcard_csr( l_instr_id NUMBER ) IS
           SELECT instrid
           FROM   iby_creditcard_v
           WHERE  ownerid = payer_id
           AND    instrid = nvl(l_instr_id, instrid);
        CURSOR load_purchasecard_csr( l_instr_id NUMBER ) IS
           SELECT instrid
           FROM   iby_purchasecard_v
           WHERE  ownerid = payer_id
           AND    instrid = nvl(l_instr_id, instrid);

        CURSOR load_bankacct_csr( l_instr_id NUMBER ) IS
           SELECT b.ext_bank_account_id
           FROM   iby_ext_bank_accounts_v b,
                  iby_account_owners ao
           WHERE  ao.account_owner_party_id = payer_id
           AND    ao.ext_bank_account_id = b.ext_bank_account_id
           AND    b.ext_bank_account_id = nvl(l_instr_id, b.ext_bank_account_id);

BEGIN

        -- close the cursors, if they are already open.
        IF( load_creditcard_csr%ISOPEN ) THEN
           CLOSE load_creditcard_csr;
        END IF;

        IF( load_purchasecard_csr%ISOPEN ) THEN
           CLOSE load_purchasecard_csr;
        END IF;

        IF( load_bankacct_csr%ISOPEN ) THEN
           CLOSE load_bankacct_csr;
        END IF;

        /*  --- Processing Credit Card information ---- */

        l_count := 1; -- Initialize the counter for the loop

        -- fetch all the credit card instruments for the payer
        FOR t_creditcard IN load_creditcard_csr(instr_id) LOOP

          iby_creditcard_pkg.Query_Card
          (
          t_creditcard.instrid,
          NULL,
          creditcard_tbl(l_count).Owner_Id,
          creditcard_tbl(l_count).CC_HolderName,
          creditcard_tbl(l_count).Billing_Address_Id,
          creditcard_tbl(l_count).Billing_Address1,
          creditcard_tbl(l_count).Billing_Address2,
          creditcard_tbl(l_count).Billing_Address3,
          creditcard_tbl(l_count).Billing_City,
          creditcard_tbl(l_count).Billing_County,
          creditcard_tbl(l_count).Billing_State,
          creditcard_tbl(l_count).Billing_PostalCode,
          creditcard_tbl(l_count).Billing_Country,
          creditcard_tbl(l_count).CC_Num,
          creditcard_tbl(l_count).CC_ExpDate,
          creditcard_tbl(l_count).Instrument_Type,
          lx_pcard_flag,
          lx_pcard_type,
          creditcard_tbl(l_count).CC_Type,
          creditcard_tbl(l_count).FIName,
          creditcard_tbl(l_count).Single_Use_Flag,
          creditcard_tbl(l_count).Info_Only_Flag,
          creditcard_tbl(l_count).Card_Purpose,
          creditcard_tbl(l_count).CC_Desc,
          creditcard_tbl(l_count).Active_Flag,
          creditcard_tbl(l_count).Inactive_Date,
          lx_result_code
          );

          l_count := l_count + 1;
        END LOOP;    -- For the load_creditcard_csr

        /*  --- Processing Purchase Card information ---- */

        l_count := 1; -- Initialize the counter for the next loop

        -- fetch all the purchase card instruments for the payer
        FOR t_purchasecard IN load_purchasecard_csr(instr_id) LOOP

          iby_creditcard_pkg.Query_Card
          (
          t_purchasecard.instrid,
          NULL,
          purchasecard_tbl(l_count).Owner_Id,
          purchasecard_tbl(l_count).PC_HolderName,
          purchasecard_tbl(l_count).Billing_Address_Id,
          purchasecard_tbl(l_count).Billing_Address1,
          purchasecard_tbl(l_count).Billing_Address2,
          purchasecard_tbl(l_count).Billing_Address3,
          purchasecard_tbl(l_count).Billing_City,
          purchasecard_tbl(l_count).Billing_County,
          purchasecard_tbl(l_count).Billing_State,
          purchasecard_tbl(l_count).Billing_PostalCode,
          purchasecard_tbl(l_count).Billing_Country,
          purchasecard_tbl(l_count).PC_Num,
          purchasecard_tbl(l_count).PC_ExpDate,
          purchasecard_tbl(l_count).Instrument_Type,
          lx_pcard_flag,
          purchasecard_tbl(l_count).PC_Subtype,
          purchasecard_tbl(l_count).PC_Type,
          purchasecard_tbl(l_count).FIName,
          purchasecard_tbl(l_count).Single_Use_Flag,
          purchasecard_tbl(l_count).Info_Only_Flag,
          purchasecard_tbl(l_count).Card_Purpose,
          purchasecard_tbl(l_count).PC_Desc,
          purchasecard_tbl(l_count).Active_Flag,
          purchasecard_tbl(l_count).Inactive_Date,
          lx_result_code
          );

          l_count := l_count + 1;

        END LOOP;  -- For the load_purchasecard_csr

        /*  --- Processing Bank Account information ---- */

        l_count := 1; -- Initialize the counter for the next loop

        -- fetch all the bank account instruments for the payer
        FOR t_bankacct IN load_bankacct_csr(instr_id) LOOP
/*
           iby_bankacct_pkg.queryBankAcct
           (
           673,
           null,
           payer_id,
           t_bankacct.instrid,
           sys_master_key,
           bankacct_tbl(l_count).FIName,
           bankacct_tbl(l_count).Bank_ID,
           bankacct_tbl(l_count).Branch_ID,
           bankacct_tbl(l_count).BankAcct_Type,
           bankacct_tbl(l_count).BankAcct_Num,
           bankacct_tbl(l_count).BankAcct_HolderName,
           bankacct_tbl(l_count).Bank_Desc,
           bankacct_tbl(l_count).BankAcct_Checkdigits
           );
*/
           l_count := l_count + 1;

        END LOOP;


END Get_Instrument_Details;

/* UTILITY FUNCTION # 4: ECAPP_RETURN_STATUS_SUCCESS

   Returns true if and only if the given transaction
   status indicates a success.

 */
   FUNCTION ecapp_return_status_success( p_ret_status NUMBER )
   RETURN BOOLEAN
   IS
   BEGIN
        IF (p_ret_status IS NULL) THEN
          iby_debug_pub.add(debug_msg => 'ECApp servlet trxn status is NULL!',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.ecapp_return_status_success');
          RETURN FALSE;
        ELSIF ((IBY_PAYMENT_ADAPTER_PUB.C_TRXN_STATUS_SUCCESS = p_ret_status) OR
               (IBY_PAYMENT_ADAPTER_PUB.C_TRXN_STATUS_INFO = p_ret_status) OR
               (IBY_PAYMENT_ADAPTER_PUB.C_TRXN_STATUS_WARNING = p_ret_status)
              )
        THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
   END ecapp_return_status_success;


-------------------------------------------------------------------------------
                       ---*** APIS START BELOW ---***
-------------------------------------------------------------------------------
        -- 1. OraInstrAdd
        -- Start of comments
        --   API name        : OraInstrAdd
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Adds new Payment Instruments to iPayment.
        --   Parameters      :
        --   IN              : p_api_version       IN    NUMBER              Required
        --                     p_init_msg_list     IN    VARCHAR2            Optional
        --                     p_commit            IN    VARCHAR2            Optional
        --                     p_validation_level  IN    NUMBER              Optional
        --                     p_payer_id          IN    VARCHAR2            Required
        --                     p_pmtInstrRec       IN    PmtInstr_rec_type   Required
        --
        --   OUT             : x_return_status     OUT   VARCHAR2
        --                     x_msg_count         OUT   VARCHAR2
        --                     x_msg_data          OUT   NUMBER
        --                     x_instr_id          OUT   NUMBER
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
-------------------------------------------------------------------------------

  PROCEDURE OraInstrAdd
  (
  p_api_version      IN   NUMBER,
  p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
  p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
  p_validation_level IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_pmtInstrRec      IN   PmtInstr_rec_type,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_instr_id         OUT NOCOPY NUMBER,
  x_result           OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  )
  IS
        l_api_name      CONSTANT  VARCHAR2(30) := 'OraInstrAdd';
        l_oapf_action   CONSTANT  VARCHAR2(30) := 'oraInstrAdd';
        l_api_version   CONSTANT  NUMBER := 1.0;

        l_url           VARCHAR2(30000) ;
        l_get_baseurl   VARCHAR2(2000);

        l_pos           NUMBER := 0;
        l_post_body     VARCHAR2(30000);
        l_html          VARCHAR2(32767) ;
        l_names         IBY_NETUTILS_PVT.v240_tbl_type;
        l_values        IBY_NETUTILS_PVT.v240_tbl_type;

        l_status        NUMBER := 0;
        l_errcode       NUMBER := 0;
        l_index         NUMBER := 1;
        l_errmessage    VARCHAR2(2000) := 'Success';

        -- for NLS bug fix #1692300 - 4/3/2001 jleybovi
        --
        l_db_nls        VARCHAR2(80) := NULL;
        l_ecapp_nls     VARCHAR2(80) := NULL;

        l_instrument_type  VARCHAR2(80) := C_INSTRTYPE_UNREG;
        l_sec_cred NUMBER;

        ERROR_FROM_SUBPROC Exception;

        -- This will catch all the exceptions from the procedure which is
        -- subsequently called.This will trap all exceptions that have
        -- SQLCODE = -20000 and name it as 'ERROR_FROM_SUBPROC'.
        PRAGMA EXCEPTION_INIT( ERROR_FROM_SUBPROC, -20000 );

        l_dbg_mod       VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_api_name;
BEGIN
        iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        -- Verifying if validation level is FULL, which is expected for PUBLIC APIs.
        IF (p_validation_level <> g_validation_level) THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204401_VAL_LEVEL_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- START OF BODY OF API

        -- Checks whether the instrument type passed is valid or not
        l_instrument_type := p_pmtInstrRec.InstrumentType;
        IF( ( l_instrument_type <> C_INSTRTYPE_CREDITCARD ) AND
            ( l_instrument_type <> C_INSTRTYPE_PURCHASECARD ) AND
            ( l_instrument_type <> C_INSTRTYPE_BANKACCT ) ) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_20487');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'Invalid instrument type passed'.
        END IF;

        -- Check whether Instrid is passed. It should not be passed for 'Add'.
        IF( ( p_pmtInstrRec.CreditCardInstr.Instr_Id is not NULL ) OR
               ( p_pmtInstrRec.PurchaseCardInstr.Instr_Id is not NULL ) OR
               ( p_pmtInstrRec.BankAcctInstr.Instr_Id is not NULL ) ) THEN
              FND_MESSAGE.SET_NAME('IBY', 'IBY_20488');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
              --Returns message 'INSTR_ID should not be passed'
        END IF;

        IF( l_instrument_type = C_INSTRTYPE_PURCHASECARD ) THEN
           -- Purchase Subtype is mandatory.
           IF( p_pmtInstrRec.PurchaseCardInstr.PC_SubType is NULL ) THEN
              FND_MESSAGE.SET_NAME('IBY', 'IBY_20483');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
              -- Returns message 'Mandatory field(s) missing'
           END IF;

        END IF;

      -- Finally call the procedures that will add the instrument.
      --IBY_NETUTILS_PVT.get_baseurl(l_get_baseurl);

      IBY_NETUTILS_PVT.get_baseurl(l_get_baseurl);

      iby_debug_pub.add('GetBaseUrl :' || l_get_baseurl,
        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      -- Construct the full URL to send to the ECServlet.
      l_url := l_get_baseurl;

      l_db_nls := IBY_NETUTILS_PVT.get_local_nls();
      l_ecapp_nls := NULL; -- not passed in this api??

      IBY_NETUTILS_PVT.check_mandatory('OapfAction', l_oapf_action, l_url, l_db_nls, l_ecapp_nls);
      IF ( l_instrument_type <> C_INSTRTYPE_UNREG) THEN
         IBY_NETUTILS_PVT.check_mandatory('OapfPmtInstrType',  l_instrument_type, l_url, l_db_nls, l_ecapp_nls);
      END IF;

      -- lmallick: PA-DSS fixes
      -- For IMMEDIATE mode of encryption, pass the login_id and user_id to the
      -- ecapp servlet. This would ensure that the audit trail is maintained even when the
      -- requested is routed through the ecapp servlet
      IBY_NETUTILS_PVT.check_mandatory('OapfLoginId', fnd_global.login_id, l_url, l_db_nls, l_ecapp_nls);
      IBY_NETUTILS_PVT.check_mandatory('OapfUserId', fnd_global.user_id, l_url, l_db_nls, l_ecapp_nls);


      IF ( l_instrument_type = C_INSTRTYPE_BANKACCT) THEN
         IBY_NETUTILS_PVT.check_optional('OapfInstrOwnerType',  p_pmtInstrRec.BankAcctInstr.BankAcct_HolderType, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfInstrFIName',  p_pmtInstrRec.BankAcctInstr.FIName, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfInstrBankId',  p_pmtInstrRec.BankAcctInstr.Branch_ID, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfInstrBankSwiftCode',  p_pmtInstrRec.BankAcctInstr.Bank_SwiftCode, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfInstrBranchId',  p_pmtInstrRec.BankAcctInstr.Bank_ID, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfInstrAcctType',  p_pmtInstrRec.BankAcctInstr.BankAcct_Type, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfInstrNum',  p_pmtInstrRec.BankAcctInstr.BankAcct_Num, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfInstrCheckDigits',  p_pmtInstrRec.BankAcctInstr.BankAcct_Checkdigits, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_mandatory('OapfInstrHolderName',  p_pmtInstrRec.BankAcctInstr.BankAcct_HolderName, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfInstrBuf',  p_pmtInstrRec.BankAcctInstr.Bank_Desc, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfInstrCurrency',  p_pmtInstrRec.BankAcctInstr.BankAcct_Currency, l_url, l_db_nls, l_ecapp_nls);
         IBY_NETUTILS_PVT.check_optional('OapfInstrOwnerAddrId',  p_pmtInstrRec.BankAcctInstr.Acct_HolderAddrId, l_url, l_db_nls, l_ecapp_nls);
         IF ( p_pmtInstrRec.BankAcctInstr.Bank_AddrId is NOT null ) THEN
        IBY_NETUTILS_PVT.check_optional('OapfInstrAddrId',  p_pmtInstrRec.BankAcctInstr.Bank_AddrId, l_url, l_db_nls, l_ecapp_nls);
         ELSIF ( p_pmtInstrRec.BankAcctInstr.Bank_Address1 is NOT NULL) THEN
       IBY_NETUTILS_PVT.check_mandatory('OapfInstrAddrLine1', p_pmtInstrRec.BankAcctInstr.Bank_Address1, l_url, l_db_nls, l_ecapp_nls);
       IBY_NETUTILS_PVT.check_optional('OapfInstrAddrLine2', p_pmtInstrRec.BankAcctInstr.Bank_Address2, l_url, l_db_nls, l_ecapp_nls);
            IBY_NETUTILS_PVT.check_optional('OapfInstrAddrLine3', p_pmtInstrRec.BankAcctInstr.Bank_Address3, l_url, l_db_nls, l_ecapp_nls);
            IBY_NETUTILS_PVT.check_optional('OapfInstrCity', p_pmtInstrRec.BankAcctInstr.Bank_City, l_url, l_db_nls, l_ecapp_nls);
            IBY_NETUTILS_PVT.check_optional('OapfInstrCounty', p_pmtInstrRec.BankAcctInstr.Bank_County, l_url, l_db_nls, l_ecapp_nls);
            IBY_NETUTILS_PVT.check_optional('OapfInstrState', p_pmtInstrRec.BankAcctInstr.Bank_State, l_url, l_db_nls, l_ecapp_nls);
            IBY_NETUTILS_PVT.check_mandatory('OapfInstrCountry', p_pmtInstrRec.BankAcctInstr.Bank_Country, l_url, l_db_nls, l_ecapp_nls);
            IBY_NETUTILS_PVT.check_optional('OapfInstrPostalCode', p_pmtInstrRec.BankAcctInstr.Bank_PostalCode, l_url, l_db_nls, l_ecapp_nls);
    END IF;

      ELSIF( l_instrument_type = C_INSTRTYPE_PURCHASECARD ) THEN

           IBY_NETUTILS_PVT.check_optional('OapfInstrFIName',  p_pmtInstrRec.PurchaseCardInstr.FIName, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_mandatory('OapfCCType',p_pmtInstrRec.PurchaseCardInstr.PC_Type, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_mandatory('OapfPmtInstrExp',to_char(p_pmtInstrRec.PurchaseCardInstr.PC_ExpDate,'YYYY-MM-DD'), l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_mandatory('OapfInstrNum',  p_pmtInstrRec.PurchaseCardInstr.PC_Num, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_mandatory('OapfInstrHolderName',  p_pmtInstrRec.PurchaseCardInstr.PC_HolderName , l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfInstrOwnerId', p_pmtInstrRec.PurchaseCardInstr.Owner_Id, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfInstrOwnerType',  p_pmtInstrRec.PurchaseCardInstr.PC_HolderType, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_mandatory('OapfCardSubType', p_pmtInstrRec.PurchaseCardInstr.PC_Subtype, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfInstrBuf',  p_pmtInstrRec.PurchaseCardInstr.PC_Desc, l_url, l_db_nls, l_ecapp_nls);
           IF ( p_pmtInstrRec.PurchaseCardInstr.Billing_Address1 is NOT NULL) THEN
          IBY_NETUTILS_PVT.check_mandatory('OapfInstrAddrLine1', p_pmtInstrRec.PurchaseCardInstr.Billing_Address1, l_url, l_db_nls, l_ecapp_nls);
          IBY_NETUTILS_PVT.check_optional('OapfInstrAddrLine2', p_pmtInstrRec.PurchaseCardInstr.Billing_Address2, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_optional('OapfInstrAddrLine3', p_pmtInstrRec.PurchaseCardInstr.Billing_Address3, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_mandatory('OapfInstrCity', p_pmtInstrRec.PurchaseCardInstr.Billing_City, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_optional('OapfInstrCounty', p_pmtInstrRec.PurchaseCardInstr.Billing_County, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_optional('OapfInstrState', p_pmtInstrRec.PurchaseCardInstr.Billing_State, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_mandatory('OapfInstrCountry', p_pmtInstrRec.PurchaseCardInstr.Billing_Country, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_optional('OapfInstrPostalCode', p_pmtInstrRec.PurchaseCardInstr.Billing_PostalCode, l_url, l_db_nls, l_ecapp_nls);
    END IF;

      ELSIF( l_instrument_type = C_INSTRTYPE_CREDITCARD ) THEN

           IBY_NETUTILS_PVT.check_optional('OapfInstrFIName',  p_pmtInstrRec.CreditCardInstr.FIName, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfCCType', p_pmtInstrRec.CreditCardInstr.CC_Type, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_mandatory('OapfInstrNum',  p_pmtInstrRec.CreditCardInstr.CC_Num, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfPmtInstrExp', to_char(p_pmtInstrRec.CreditCardInstr.CC_ExpDate,'YYYY-MM-DD'), l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfInstrHolderName',  p_pmtInstrRec.CreditCardInstr.CC_HolderName , l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfInstrOwnerType',  p_pmtInstrRec.CreditCardInstr.CC_HolderType, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfInstrBuf',  p_pmtInstrRec.CreditCardInstr.CC_Desc, l_url, l_db_nls, l_ecapp_nls);

	   --lmallick
	   --ownerid is optional (OIE registers cards without passing an ownerid)
	   IBY_NETUTILS_PVT.check_optional('OapfInstrOwnerId', p_pmtInstrRec.CreditCardInstr.Owner_Id, l_url, l_db_nls, l_ecapp_nls);

           IBY_NETUTILS_PVT.check_optional('OapfSingleUseFlag', p_pmtInstrRec.CreditCardInstr.Single_Use_Flag, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfInfoOnlyFlag', p_pmtInstrRec.CreditCardInstr.Info_Only_Flag, l_url, l_db_nls, l_ecapp_nls);

	   iby_debug_pub.add('Card_purpose passed is :' || p_pmtInstrRec.CreditCardInstr.Card_Purpose, iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
           IBY_NETUTILS_PVT.check_optional('OapfCardPurpose', p_pmtInstrRec.CreditCardInstr.Card_Purpose, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfActiveFlag', p_pmtInstrRec.CreditCardInstr.Active_Flag, l_url, l_db_nls, l_ecapp_nls);
           IBY_NETUTILS_PVT.check_optional('OapfInactiveDate', TO_CHAR(p_pmtInstrRec.CreditCardInstr.Inactive_Date,'YYYY-MM-DD'), l_url, l_db_nls, l_ecapp_nls);

	   --bug 8423951
	   iby_debug_pub.add('Address ID is :' || p_pmtInstrRec.CreditCardInstr.Billing_Address_Id, iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	   IBY_NETUTILS_PVT.check_optional('OapfInstrAddrId',  p_pmtInstrRec.CreditCardInstr.Billing_Address_Id, l_url, l_db_nls, l_ecapp_nls);

          IF ( p_pmtInstrRec.CreditCardInstr.Billing_Address1 is NOT NULL) THEN
          IBY_NETUTILS_PVT.check_mandatory('OapfInstrAddrLine1', p_pmtInstrRec.CreditCardInstr.Billing_Address1, l_url, l_db_nls, l_ecapp_nls);
          IBY_NETUTILS_PVT.check_optional('OapfInstrAddrLine2', p_pmtInstrRec.CreditCardInstr.Billing_Address2, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_optional('OapfInstrAddrLine3', p_pmtInstrRec.CreditCardInstr.Billing_Address3, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_mandatory('OapfInstrCity', p_pmtInstrRec.CreditCardInstr.Billing_City, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_optional('OapfInstrCounty', p_pmtInstrRec.CreditCardInstr.Billing_County, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_optional('OapfInstrState', p_pmtInstrRec.CreditCardInstr.Billing_State, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_mandatory('OapfInstrCountry', p_pmtInstrRec.CreditCardInstr.Billing_Country, l_url, l_db_nls, l_ecapp_nls);
               IBY_NETUTILS_PVT.check_optional('OapfInstrPostalCode', p_pmtInstrRec.CreditCardInstr.Billing_PostalCode, l_url, l_db_nls, l_ecapp_nls);

	  END IF;

	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttCategory', p_pmtInstrRec.CreditCardInstr.Attribute_category, l_url, l_db_nls, l_ecapp_nls);
          IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute1', p_pmtInstrRec.CreditCardInstr.Attribute1, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute2', p_pmtInstrRec.CreditCardInstr.Attribute2, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute3', p_pmtInstrRec.CreditCardInstr.Attribute3, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute4', p_pmtInstrRec.CreditCardInstr.Attribute4, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute5', p_pmtInstrRec.CreditCardInstr.Attribute5, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute6', p_pmtInstrRec.CreditCardInstr.Attribute6, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute7', p_pmtInstrRec.CreditCardInstr.Attribute7, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute8', p_pmtInstrRec.CreditCardInstr.Attribute8, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute9', p_pmtInstrRec.CreditCardInstr.Attribute9, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute10', p_pmtInstrRec.CreditCardInstr.Attribute10, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute11', p_pmtInstrRec.CreditCardInstr.Attribute11, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute12', p_pmtInstrRec.CreditCardInstr.Attribute12, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute13', p_pmtInstrRec.CreditCardInstr.Attribute13, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute14', p_pmtInstrRec.CreditCardInstr.Attribute14, l_url, l_db_nls, l_ecapp_nls);
          IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute15', p_pmtInstrRec.CreditCardInstr.Attribute15, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute16', p_pmtInstrRec.CreditCardInstr.Attribute16, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute17', p_pmtInstrRec.CreditCardInstr.Attribute17, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute18', p_pmtInstrRec.CreditCardInstr.Attribute18, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute19', p_pmtInstrRec.CreditCardInstr.Attribute19, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute20', p_pmtInstrRec.CreditCardInstr.Attribute20, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute21', p_pmtInstrRec.CreditCardInstr.Attribute21, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute22', p_pmtInstrRec.CreditCardInstr.Attribute22, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute23', p_pmtInstrRec.CreditCardInstr.Attribute23, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute24', p_pmtInstrRec.CreditCardInstr.Attribute24, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute25', p_pmtInstrRec.CreditCardInstr.Attribute25, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute26', p_pmtInstrRec.CreditCardInstr.Attribute26, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute27', p_pmtInstrRec.CreditCardInstr.Attribute27, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute28', p_pmtInstrRec.CreditCardInstr.Attribute28, l_url, l_db_nls, l_ecapp_nls);
          IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute29', p_pmtInstrRec.CreditCardInstr.Attribute29, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfInstrAttribute30', p_pmtInstrRec.CreditCardInstr.Attribute30, l_url, l_db_nls, l_ecapp_nls);
	  IBY_NETUTILS_PVT.check_optional('OapfRegstrInvalidCard', p_pmtInstrRec.CreditCardInstr.Register_Invalid_Card, l_url, l_db_nls, l_ecapp_nls);

     END IF;

   -- Send http request to the payment server
   --l_html := UTL_HTTP.REQUEST(l_url);

/* Bug 6318167 */
   IF p_pmtInstrRec.nls_lang_param IS NOT NULL THEN
      IBY_NETUTILS_PVT.check_optional('OapfNlsLang', p_pmtInstrRec.nls_lang_param, l_url, l_db_nls, l_ecapp_nls);
   END IF;

   -- set the security token
   iby_security_pkg.store_credential(l_url,l_sec_cred);
   iby_netutils_pvt.check_mandatory('OapfSecurityToken', TO_CHAR(l_sec_cred),
       l_url, l_db_nls, l_ecapp_nls);

        --   iby_debug_pub.add(debug_msg => 'OraInstrAdd => full url: '|| l_url,
        --  debug_level => iby_debug_pub.G_LEVEL_INFO,
        --  module => l_dbg_mod);

   l_pos := INSTR(l_url,'?');
   l_post_body := SUBSTR(l_url,l_pos+1,length(l_url));
   l_post_body := RTRIM(l_post_body,'&');
   l_url := SUBSTR(l_url,1,l_pos-1);

        --dbms_output.put_line('l_pos : '||l_pos);
        --dbms_output.put_line('l_url : '||l_url);
        --dbms_output.put_line('l_post_body : '||l_post_body);

   -- sending Post Request
   IBY_NETUTILS_PVT.POST_REQUEST(l_url,l_post_body,l_html);

   -- Unpack the results
   IBY_NETUTILS_PVT.UNPACK_RESULTS_URL(l_html,l_names,l_values, l_status, l_errcode, l_errmessage);

        iby_debug_pub.add('Return Parameter count : '|| l_values.COUNT,
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

        --Raising Exception to handle errors in unpacking resulting html file.
        IF (l_status = -1) THEN
            iby_debug_pub.add('Unpack status error',
                                FND_LOG.LEVEL_UNEXPECTED,
                                G_DEBUG_MODULE || l_api_name);

           FND_MESSAGE.SET_NAME('IBY', 'IBY_204403_HTML_UNPACK_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Raising Exception to handle Servlet related errors.
        IF (l_values.COUNT = 0 ) THEN
          iby_debug_pub.add('Names count=0',
            iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

           FND_MESSAGE.SET_NAME('IBY', 'IBY_204402_JSERVLET_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
iby_debug_pub.add('l_names count = ' ||l_names.COUNT,
        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
   FOR i IN 1..l_names.COUNT LOOP

      iby_debug_pub.add(l_names(i) || ':  ' ||l_values(i),
        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      IF l_names(i) = 'OapfStatus' THEN
        iby_debug_pub.add('OapfStatus = '||l_values(i),
                              iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	-- Setting API return status to 'U' if iPayment response status is not 0.
        IF (NOT ecapp_return_status_success(TO_NUMBER(l_values(i)))) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      ELSIF l_names(i) = 'OapfInstrId' THEN
        x_instr_id := l_values(i);
      ELSIF l_names(i) = 'OapfCode' THEN
        x_result.Result_Code := l_values(i);
      ELSIF l_names(i) = 'OapfCause' THEN
        x_result.Result_Message := l_values(i);
              --
              -- simply copy the mesg returned verbatim;
              -- this is done rather than reconstructing via 'OapfCode'
              -- as msg tokens will not otherwise be filled
              --
              FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
              FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT', l_values(i));
              FND_MSG_PUB.ADD;
      END IF;

   END LOOP;

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          -- op completed successfully
          FND_MESSAGE.SET_NAME('IBY','IBY_204170');
          FND_MSG_PUB.ADD;
   END IF;

        FND_MSG_PUB.Count_And_Get
        (
        p_count => x_msg_count,
        p_data => x_msg_data
        );

   iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
EXCEPTION

   -- Catch for version mismatch and
   -- if the validation level is not full.
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   -- Catch for all the known errors
   -- thrown from this procedure only.
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   -- Catch for all the known errors
   -- thrown from the procedures that are called by this procedure.
   -- Whenever there is an error in the procedures that are called,
   -- this exception is raised as long as the SQLCODE is -20000.
   WHEN ERROR_FROM_SUBPROC THEN
        iby_debug_pub.add('Subproc exception..',
        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      --dbms_output.put_line('ERROR: ERROR_FROM_SUBPROC during call to API ');
      --dbms_output.put_line('SQLerr is :'||substr(SQLERRM,1,150));
      x_return_status := FND_API.G_RET_STS_ERROR;
      iby_utility_pvt.handleException(SQLERRM,SQLCODE);
      FND_MSG_PUB.Count_And_Get
                  (      p_count        =>       x_msg_count,
                         p_data         =>       x_msg_data
                  );

   WHEN OTHERS THEN
     iby_debug_pub.add('Others exception..'||SQLERRM||' code: '||SQLCODE,
        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      --dbms_output.put_line('ERROR: Exception occured during call to API ' );
      --dbms_output.put_line('SQLerr is :'||substr(SQLERRM,1,150));
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
                  (      p_count        =>       x_msg_count,
                         p_data         =>       x_msg_data
                  );

  END OraInstrAdd;


-------------------------------------------------------------------------------
        -- 2. OraInstrMod
        -- Start of comments
        --   API name        : OraInstrMod
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Modifies an existing payment instruments in iPayment.
        --   Parameters      :
        --   IN              : p_api_version       IN    NUMBER              Required
        --                     p_init_msg_list     IN    VARCHAR2            Optional
        --                     p_commit            IN    VARCHAR2            Optional
        --                     p_validation_level  IN    NUMBER              Optional
        --                     p_payer_id          IN    VARCHAR2            Required
        --                     p_pmtInstrRec       IN    PmtInstr_rec_type   Required
        --
        --   OUT             : x_return_status     OUT   VARCHAR2
        --                     x_msg_count         OUT   VARCHAR2
        --                     x_msg_data          OUT   NUMBER
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
-------------------------------------------------------------------------------


  PROCEDURE OraInstrMod (p_api_version          IN      NUMBER,
                         p_init_msg_list        IN      VARCHAR2  := FND_API.G_FALSE,
                         p_commit               IN      VARCHAR2  := FND_API.G_TRUE,
                         p_validation_level     IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                         p_payer_id             IN      VARCHAR2,
                         p_pmtInstrRec          IN      PmtInstr_rec_type,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_result               OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
                        ) IS

        l_api_name     CONSTANT  VARCHAR2(30) := 'OraInstrMod';
        l_api_version  CONSTANT  NUMBER := 1.0;

        l_instrument_type  VARCHAR2(80) := C_INSTRTYPE_UNREG;
        l_cnt              INTEGER;

        ERROR_FROM_SUBPROC Exception;

        -- This will catch all the exceptions from the procedure which is
        -- subsequently called.This will trap all exceptions that have
        -- SQLCODE = -20000 and name it as 'ERROR_FROM_SUBPROC'.
        PRAGMA EXCEPTION_INIT( ERROR_FROM_SUBPROC, -20000 );

BEGIN

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        -- Verifying if validation level is FULL, which is expected for PUBLIC APIs.
        IF (p_validation_level <> g_validation_level) THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204401_VAL_LEVEL_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- START OF BODY OF API

        -- check whether the payer_id is missing.
        IF( TRIM( p_payer_id ) is NULL ) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_20486');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'PAYER_ID is mandatory'
        END IF;

        -- Checks whether the instrument type passed is valid or not
        l_instrument_type := p_pmtInstrRec.InstrumentType;
        IF( ( l_instrument_type <> C_INSTRTYPE_CREDITCARD ) AND
            ( l_instrument_type <> C_INSTRTYPE_PURCHASECARD ) AND
            ( l_instrument_type <> C_INSTRTYPE_BANKACCT ) ) THEN
      FND_MESSAGE.SET_NAME('IBY', 'IBY_20487');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'Invalid instrument type passed'.
        END IF;

        -- Check whether card number is passed for type Credit card.
        IF( l_instrument_type = C_INSTRTYPE_CREDITCARD ) THEN

           -- Card number should NOT be passed as it is an existing instrument.
           IF( (p_pmtInstrRec.CreditCardInstr.CC_Num is not NULL) OR
               (p_pmtInstrRec.CreditCardInstr.CC_Type is not NULL) ) THEN
              FND_MESSAGE.SET_NAME('IBY', 'IBY_20489');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
              -- Returns message 'Neither Card number nor Card Type should be passed'
           END IF;

        -- Check whether mandatory/not desirable is passed for type Purchase card.
        ELSIF( l_instrument_type = C_INSTRTYPE_PURCHASECARD ) THEN

           -- Card number should NOT be passed as it is an existing instrument.
           IF( (p_pmtInstrRec.PurchaseCardInstr.PC_Num is not NULL) OR
               (p_pmtInstrRec.PurchaseCardInstr.PC_Type is not NULL) ) THEN
              FND_MESSAGE.SET_NAME('IBY', 'IBY_20489');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
              -- Returns message 'Neither Card number nor Card Type should be passed'
           END IF;

           -- Subtype is mandatory.
           IF( p_pmtInstrRec.PurchaseCardInstr.PC_SubType is NULL ) THEN
              FND_MESSAGE.SET_NAME('IBY', 'IBY_20483');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
              -- Returns message 'Mandatory field(s) missing'
           END IF;

        -- Bank_Id and BankAcct_Num may NOT be modified for type Bank Account.
        ELSIF( l_instrument_type = C_INSTRTYPE_BANKACCT ) THEN

           -- Bank Id and BankAcct_Num should NOT be passed as it is an existing instrument.
           IF( ( p_pmtInstrRec.BankAcctInstr.Bank_Id is not NULL ) OR
               ( p_pmtInstrRec.BankAcctInstr.BankAcct_Num is not NULL ) ) THEN
              FND_MESSAGE.SET_NAME('IBY', 'IBY_20490');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
              -- Returns message 'Neither Bank Id nor Bank Account Number should be passed'
           END IF;

        END IF;

        -- Finally call the procedures that will modify the instrument.
        IF( l_instrument_type = C_INSTRTYPE_BANKACCT ) THEN
null;
/*
           IBY_BANKACCT_PKG.modifyBankAcct( NULL,
                                            g_owner_type,
                                            p_payer_id,
                                            p_pmtInstrRec.BankAcctInstr.FIName,
                                            NULL,
                                            p_pmtInstrRec.BankAcctInstr.Bank_Id,
                                            p_pmtInstrRec.BankAcctInstr.Branch_Id,
                                            UPPER(p_pmtInstrRec.BankAcctInstr.BankAcct_Type),
                                            p_pmtInstrRec.BankAcctInstr.BankAcct_Num,
                                            p_pmtInstrRec.BankAcctInstr.BankAcct_HolderName,
                                            p_pmtInstrRec.BankAcctInstr.Bank_Desc,
                                            p_pmtInstrRec.Encryption_Key,
                                            p_pmtInstrRec.BankAcctInstr.Instr_Id
                                           );

*/
        ELSIF( l_instrument_type = C_INSTRTYPE_PURCHASECARD ) THEN
          IBY_CREDITCARD_PKG.Update_Card
          (FND_API.G_FALSE,
           p_pmtInstrRec.PurchaseCardInstr.Instr_Id,
           p_pmtInstrRec.PurchaseCardInstr.Owner_Id,
           p_pmtInstrRec.PurchaseCardInstr.PC_HolderName,
           p_pmtInstrRec.PurchaseCardInstr.Billing_Address_Id,
           'S',
           p_pmtInstrRec.PurchaseCardInstr.Billing_PostalCode,
           p_pmtInstrRec.PurchaseCardInstr.Billing_Country,
           p_pmtInstrRec.PurchaseCardInstr.PC_ExpDate,
           'CREDITCARD',
           'Y',
           p_pmtInstrRec.PurchaseCardInstr.PC_Subtype,
           p_pmtInstrRec.PurchaseCardInstr.FIName,
           p_pmtInstrRec.PurchaseCardInstr.Single_Use_Flag,
           p_pmtInstrRec.PurchaseCardInstr.Info_Only_Flag,
           p_pmtInstrRec.PurchaseCardInstr.Card_Purpose,
           p_pmtInstrRec.PurchaseCardInstr.PC_Desc,
           p_pmtInstrRec.PurchaseCardInstr.Active_Flag,
           p_pmtInstrRec.PurchaseCardInstr.Inactive_Date,
	   p_pmtInstrRec.PurchaseCardInstr.attribute_category,
	   p_pmtInstrRec.PurchaseCardInstr.attribute1,
	   p_pmtInstrRec.PurchaseCardInstr.attribute2,
	   p_pmtInstrRec.PurchaseCardInstr.attribute3,
	   p_pmtInstrRec.PurchaseCardInstr.attribute4,
	   p_pmtInstrRec.PurchaseCardInstr.attribute5,
	   p_pmtInstrRec.PurchaseCardInstr.attribute6,
	   p_pmtInstrRec.PurchaseCardInstr.attribute7,
	   p_pmtInstrRec.PurchaseCardInstr.attribute8,
	   p_pmtInstrRec.PurchaseCardInstr.attribute9,
	   p_pmtInstrRec.PurchaseCardInstr.attribute10,
	   p_pmtInstrRec.PurchaseCardInstr.attribute11,
	   p_pmtInstrRec.PurchaseCardInstr.attribute12,
	   p_pmtInstrRec.PurchaseCardInstr.attribute13,
	   p_pmtInstrRec.PurchaseCardInstr.attribute14,
	   p_pmtInstrRec.PurchaseCardInstr.attribute15,
	   p_pmtInstrRec.PurchaseCardInstr.attribute16,
	   p_pmtInstrRec.PurchaseCardInstr.attribute17,
	   p_pmtInstrRec.PurchaseCardInstr.attribute18,
	   p_pmtInstrRec.PurchaseCardInstr.attribute19,
	   p_pmtInstrRec.PurchaseCardInstr.attribute20,
	   p_pmtInstrRec.PurchaseCardInstr.attribute21,
	   p_pmtInstrRec.PurchaseCardInstr.attribute22,
	   p_pmtInstrRec.PurchaseCardInstr.attribute23,
	   p_pmtInstrRec.PurchaseCardInstr.attribute24,
	   p_pmtInstrRec.PurchaseCardInstr.attribute25,
	   p_pmtInstrRec.PurchaseCardInstr.attribute26,
	   p_pmtInstrRec.PurchaseCardInstr.attribute27,
	   p_pmtInstrRec.PurchaseCardInstr.attribute28,
	   p_pmtInstrRec.PurchaseCardInstr.attribute29,
	   p_pmtInstrRec.PurchaseCardInstr.attribute30,
           x_result.Result_Code,
	   null
          );
        ELSIF( l_instrument_type = C_INSTRTYPE_CREDITCARD ) THEN
          IBY_CREDITCARD_PKG.Update_Card
          (FND_API.G_FALSE,
           p_pmtInstrRec.CreditCardInstr.Instr_Id,
           p_pmtInstrRec.CreditCardInstr.Owner_Id,
           p_pmtInstrRec.CreditCardInstr.CC_HolderName,
           p_pmtInstrRec.CreditCardInstr.Billing_Address_Id,
           'S',
           p_pmtInstrRec.CreditCardInstr.Billing_PostalCode,
           p_pmtInstrRec.CreditCardInstr.Billing_Country,
           p_pmtInstrRec.CreditCardInstr.CC_ExpDate,
           'CREDITCARD',
           'N',
           NULL,
           p_pmtInstrRec.CreditCardInstr.FIName,
           p_pmtInstrRec.CreditCardInstr.Single_Use_Flag,
           p_pmtInstrRec.CreditCardInstr.Info_Only_Flag,
           p_pmtInstrRec.CreditCardInstr.Card_Purpose,
           p_pmtInstrRec.CreditCardInstr.CC_Desc,
           p_pmtInstrRec.CreditCardInstr.Active_Flag,
           p_pmtInstrRec.CreditCardInstr.Inactive_Date,
	   p_pmtInstrRec.CreditCardInstr.attribute_category,
	   p_pmtInstrRec.CreditCardInstr.attribute1,
	   p_pmtInstrRec.CreditCardInstr.attribute2,
	   p_pmtInstrRec.CreditCardInstr.attribute3,
	   p_pmtInstrRec.CreditCardInstr.attribute4,
	   p_pmtInstrRec.CreditCardInstr.attribute5,
	   p_pmtInstrRec.CreditCardInstr.attribute6,
	   p_pmtInstrRec.CreditCardInstr.attribute7,
	   p_pmtInstrRec.CreditCardInstr.attribute8,
	   p_pmtInstrRec.CreditCardInstr.attribute9,
	   p_pmtInstrRec.CreditCardInstr.attribute10,
	   p_pmtInstrRec.CreditCardInstr.attribute11,
	   p_pmtInstrRec.CreditCardInstr.attribute12,
	   p_pmtInstrRec.CreditCardInstr.attribute13,
	   p_pmtInstrRec.CreditCardInstr.attribute14,
	   p_pmtInstrRec.CreditCardInstr.attribute15,
	   p_pmtInstrRec.CreditCardInstr.attribute16,
	   p_pmtInstrRec.CreditCardInstr.attribute17,
	   p_pmtInstrRec.CreditCardInstr.attribute18,
	   p_pmtInstrRec.CreditCardInstr.attribute19,
	   p_pmtInstrRec.CreditCardInstr.attribute20,
	   p_pmtInstrRec.CreditCardInstr.attribute21,
	   p_pmtInstrRec.CreditCardInstr.attribute22,
	   p_pmtInstrRec.CreditCardInstr.attribute23,
	   p_pmtInstrRec.CreditCardInstr.attribute24,
	   p_pmtInstrRec.CreditCardInstr.attribute25,
	   p_pmtInstrRec.CreditCardInstr.attribute26,
	   p_pmtInstrRec.CreditCardInstr.attribute27,
	   p_pmtInstrRec.CreditCardInstr.attribute28,
	   p_pmtInstrRec.CreditCardInstr.attribute29,
	   p_pmtInstrRec.CreditCardInstr.attribute30,
           x_result.Result_Code,
	   null
          );
        END IF;


      -- Return success when everything is fine.
      x_msg_count := 1;

       -- Returns message 'operation completed successfully.'
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204170' );
      FND_MSG_PUB.Add;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

EXCEPTION

   -- Catch for version mismatch and
   -- if the validation level is not full.
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count   := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   -- Catch for all the known errors
   -- thrown from this procedure only.
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count   := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   -- Catch for all the known errors
   -- thrown from the procedures that are called by this procedure.
   -- Whenever there is an error in the procedures that are called,
   -- this exception is raised as long as the SQLCODE is -20000.
   WHEN ERROR_FROM_SUBPROC THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      iby_utility_pvt.handleException(SQLERRM,SQLCODE);
      FND_MSG_PUB.Count_And_Get
                  (      p_count        =>       x_msg_count,
                         p_data         =>       x_msg_data
                  );

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
                  (      p_count        =>       x_msg_count,
                         p_data         =>       x_msg_data
                  );


  END OraInstrMod;


-------------------------------------------------------------------------------
        -- 3. OraInstrDel
        -- Start of comments
        --   API name        : OraInstrDel
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Deletes an existing payment instruments in iPayment.
        --   Parameters      :
        --   IN              : p_api_version       IN    NUMBER              Required
        --                     p_init_msg_list     IN    VARCHAR2            Optional
        --                     p_commit            IN    VARCHAR2            Optional
        --                     p_validation_level  IN    NUMBER              Optional
        --                     p_payer_id          IN    VARCHAR2            Required
        --                     p_instr_id          IN    NUMBER              Required
        --
        --   OUT             : x_return_status     OUT   VARCHAR2
        --                     x_msg_count         OUT   VARCHAR2
        --                     x_msg_data          OUT   NUMBER
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
-------------------------------------------------------------------------------


  PROCEDURE OraInstrDel ( p_api_version         IN      NUMBER,
                          p_init_msg_list       IN      VARCHAR2  := FND_API.G_FALSE,
                          p_commit              IN      VARCHAR2  := FND_API.G_TRUE,
                          p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                          p_payer_id            IN      VARCHAR2,
                          p_instr_id            IN      NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          x_msg_data            OUT NOCOPY VARCHAR2
         ) IS

        l_api_name     CONSTANT  VARCHAR2(30) := 'OraInstrDel';
        l_api_version  CONSTANT  NUMBER := 1.0;

        ERROR_FROM_SUBPROC Exception;

        -- This will catch all the exceptions from the procedure which is
        -- subsequently called.This will trap all exceptions that have
        -- SQLCODE = -20000 and name it as 'ERROR_FROM_SUBPROC'.
        PRAGMA EXCEPTION_INIT( ERROR_FROM_SUBPROC, -20000 );

BEGIN

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        -- Verifying if validation level is FULL, which is expected for PUBLIC APIs.
        IF (p_validation_level <> g_validation_level) THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204401_VAL_LEVEL_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- START OF BODY OF API

        -- check whether the payer_id is missing.
        IF( TRIM( p_payer_id ) is NULL ) THEN
             FND_MESSAGE.SET_NAME('IBY', 'IBY_20486');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'PAYER_ID is mandatory'
        END IF;

        -- check whether the instr_id is missing.
        IF( p_instr_id is NULL ) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_20483');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'Mandatory field(s) missing'
        END IF;

        -- Call the procedure that will delete the instrument.
        IBY_INSTRHOLDER_PKG.deleteHolderInstr( NULL,
                                               g_owner_type,
                                               p_payer_id,
                                               NULL,
                                               p_instr_id
                                             );

      -- Return success when everything is fine.
   x_msg_count   := 1;

       -- Returns message 'operation completed successfully.'
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204170' );
      FND_MSG_PUB.Add;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

EXCEPTION

   -- Catch for version mismatch and
   -- if the validation level is not full.
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count   := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   -- Catch for all the known errors
   -- thrown from this procedure only.
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count   := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   -- Catch for all the known errors
   -- thrown from the procedures that are called by this procedure.
   -- Whenever there is an error in the procedures that are called,
   -- this exception is raised as long as the SQLCODE is -20000.
   WHEN ERROR_FROM_SUBPROC THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      iby_utility_pvt.handleException(SQLERRM,SQLCODE);
      FND_MSG_PUB.Count_And_Get
                  (      p_count        =>       x_msg_count,
                         p_data         =>       x_msg_data
                  );

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
                  (      p_count        =>       x_msg_count,
                         p_data         =>       x_msg_data
                  );


  END OraInstrDel;

-------------------------------------------------------------------------------
        -- 4. OraInstrInq
        -- Start of comments
        --   API name        : OraInstrInq
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Returns all the payment instruments that a payer may have.
        --                     This is based on the payer_id only.
        --   Parameters      :
        --   IN              : p_api_version       IN    NUMBER              Required
        --                     p_init_msg_list     IN    VARCHAR2            Optional
        --                     p_commit            IN    VARCHAR2            Optional
        --                     p_validation_level  IN    NUMBER              Optional
        --                     p_payer_id          IN    VARCHAR2            Required
        --
        --   OUT             : x_return_status     OUT   VARCHAR2
        --                     x_msg_count         OUT   VARCHAR2
        --                     x_msg_data          OUT   NUMBER
        --                     x_creditcard_tbl    OUT   CreditCard_tbl_type
        --                     x_purchasecard_tbl  OUT   PurchaseCard_tbl_type
        --                     x_bankacct_tbl      OUT   BankAcct_tbl_type
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
-------------------------------------------------------------------------------

  PROCEDURE OraInstrInq ( p_api_version         IN    NUMBER,
           p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
           p_commit              IN    VARCHAR2  := FND_API.G_TRUE,
           p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                          p_payer_id            IN    VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                    x_msg_data            OUT NOCOPY VARCHAR2,
                x_creditcard_tbl      OUT NOCOPY CreditCard_tbl_type,
           x_purchasecard_tbl    OUT NOCOPY PurchaseCard_tbl_type,
           x_bankacct_tbl        OUT NOCOPY BankAcct_tbl_type
                        )
  IS
  BEGIN
        OraInstrInq(p_api_version,p_init_msg_list,p_commit,p_validation_level,p_payer_id,
                    NULL,x_return_status,x_msg_count,x_msg_data,x_creditcard_tbl,
                    x_purchasecard_tbl,x_bankacct_tbl);
  END OraInstrInq;


  PROCEDURE OraInstrInq ( p_api_version         IN    NUMBER,
                          p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
                          p_commit              IN    VARCHAR2  := FND_API.G_TRUE,
                          p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                          p_payer_id            IN    VARCHAR2,
                          p_sys_sec_key         IN    VARCHAR2,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          x_msg_data            OUT NOCOPY VARCHAR2,
                          x_creditcard_tbl      OUT NOCOPY CreditCard_tbl_type,
                          x_purchasecard_tbl    OUT NOCOPY PurchaseCard_tbl_type,
                          x_bankacct_tbl        OUT NOCOPY BankAcct_tbl_type
                         ) IS

        l_api_name     CONSTANT  VARCHAR2(30) := 'OraInstrInq';
        l_api_version  CONSTANT  NUMBER := 1.0;

        l_count INTEGER;

BEGIN

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        -- Verifying if validation level is FULL, which is expected for PUBLIC APIs.
        IF (p_validation_level <> g_validation_level) THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204401_VAL_LEVEL_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- START OF BODY OF API

        -- check whether the payer_id is missing.
        IF( TRIM( p_payer_id ) is NULL ) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_20486');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'PAYER_ID is mandatory'
        END IF;

        -- Check whether the payer exists.If not,
        -- then we don't even try to fetch the records.
        SELECT count(*) INTO l_count
        FROM IBY_INSTRHOLDER
        WHERE ownerid = p_payer_id
        AND   activestatus = 1;

        -- If nothing is found throw an error.
        IF( l_count = 0 ) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_20491');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'PAYER_ID does not exist'
        END IF;

        -- Call the utility procedure that will do the job
        -- of returning all the instruments.
        Get_Instrument_Details ( payer_id       =>   p_payer_id,
                                  instr_id           =>   NULL,
                                 sys_master_key     =>   p_sys_sec_key,
                       creditcard_tbl     =>   x_creditcard_tbl,
                  purchasecard_tbl   =>   x_purchasecard_tbl,
             bankacct_tbl       =>   x_bankacct_tbl
                     );


      -- Return success when everything is fine.
   x_msg_count   := 1;

      IF( x_creditcard_tbl.count = 0 AND
          x_purchasecard_tbl.count = 0 AND
          x_bankacct_tbl.count = 0 ) THEN
         -- Returns message 'No records found matching the given criteria.'
         FND_MESSAGE.SET_NAME('IBY', 'IBY_204041' );
      ELSE
         -- Returns message 'operation completed successfully.'
         FND_MESSAGE.SET_NAME('IBY', 'IBY_204170' );
      END IF;

      FND_MSG_PUB.Add;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

EXCEPTION

   -- Catch for version mismatch and
   -- if the validation level is not full.
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count   := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   -- Catch for all the known errors
   -- thrown from this procedure only.
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count   := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      iby_utility_pvt.handleException(SQLERRM,SQLCODE);
      FND_MSG_PUB.Count_And_Get
                  (      p_count        =>       x_msg_count,
                         p_data         =>       x_msg_data
                  );

  END OraInstrInq;

-------------------------------------------------------------------------------
        -- 5. OraInstrInq
        -- Start of comments
        --   API name        : OraInstrInq
        --   Type            : Public
        --   Pre-reqs        : None
        --   Function        : Returns the payment instrument information for an instr_id.
        --                     This is based on the payer_id and instr_id.
        --   Parameters      :
        --   IN              : p_api_version       IN    NUMBER              Required
        --                     p_init_msg_list     IN    VARCHAR2            Optional
        --                     p_commit            IN    VARCHAR2            Optional
        --                     p_validation_level  IN    NUMBER              Optional
        --                     p_payer_id          IN    VARCHAR2            Required
        --                     p_instr_id          IN    NUMBER              Required
        --
        --   OUT             : x_return_status     OUT   VARCHAR2
        --                     x_msg_count         OUT   VARCHAR2
        --                     x_msg_data          OUT   NUMBER
        --                     x_pmtInstrRec       OUT   PmtInstr_rec_type
        --   Version         :
        --                     Current version      1.0
        --                     Previous version     1.0
        --                     Initial version      1.0
        -- End of comments
-------------------------------------------------------------------------------

  PROCEDURE OraInstrInq ( p_api_version         IN    NUMBER,
                          p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
                          p_commit              IN    VARCHAR2  := FND_API.G_TRUE,
                          p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                          p_payer_id            IN    VARCHAR2,
                          p_instr_id            IN    NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          x_msg_data            OUT NOCOPY VARCHAR2,
                          x_pmtInstrRec         OUT NOCOPY PmtInstr_rec_type
                        )
  IS
  BEGIN
        OraInstrInq(p_api_version,p_init_msg_list,p_commit,p_validation_level,p_payer_id,
                    p_instr_id,NULL,x_return_status,x_msg_count,x_msg_data,x_pmtInstrRec);
  END OraInstrInq;


  PROCEDURE OraInstrInq ( p_api_version         IN    NUMBER,
                          p_init_msg_list       IN    VARCHAR2  := FND_API.G_FALSE,
                          p_commit              IN    VARCHAR2  := FND_API.G_TRUE,
                          p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                          p_payer_id            IN    VARCHAR2,
                          p_instr_id            IN    NUMBER,
                          p_sys_sec_key         IN    VARCHAR2,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          x_msg_data            OUT NOCOPY VARCHAR2,
                          x_pmtInstrRec         OUT NOCOPY PmtInstr_rec_type
                        ) IS

        l_api_name     CONSTANT  VARCHAR2(30) := 'OraInstrInq';
        l_api_version  CONSTANT  NUMBER := 1.0;

        l_count INTEGER;

        l_creditcard_tbl     CreditCard_tbl_type;
        l_purchasecard_tbl   PurchaseCard_tbl_type;
        l_bankacct_tbl       BankAcct_tbl_type;

BEGIN

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
        THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        -- Verifying if validation level is FULL, which is expected for PUBLIC APIs.
        IF (p_validation_level <> g_validation_level) THEN
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204401_VAL_LEVEL_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- START OF BODY OF API

        -- Initialize the instrument type
        x_pmtInstrRec.InstrumentType := C_INSTRTYPE_UNREG;

        -- check whether the payer_id is missing.
        IF( TRIM( p_payer_id ) is NULL ) THEN
             FND_MESSAGE.SET_NAME('IBY', 'IBY_20486');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'PAYER_ID is mandatory'
        END IF;

        -- check whether the instr_id is missing.
        IF( p_instr_id is NULL ) THEN
             FND_MESSAGE.SET_NAME('IBY', 'IBY_20483');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'Mandatory field(s) missing'
        END IF;

        -- Check whether the payer exists.
        -- If not, then we don't even try to fetch the records.
        SELECT count(*) INTO l_count
        FROM   IBY_INSTRHOLDER
        WHERE  ownerid = p_payer_id
        AND    activestatus = 1;

        -- Throw an exception when payer not found.
        IF( l_count = 0 ) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_20491');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'PAYER_ID does not exist'
        END IF;

        -- Check whether the instrument exists.
        -- If not, then we don't even try to fetch the records.
        SELECT count(*) INTO l_count
        FROM   IBY_INSTRHOLDER
        WHERE  instrid = p_instr_id
        AND    activestatus = 1;

        -- Throw an exception.
        IF( l_count = 0 ) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_20492');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'Instrument does not exist'
        END IF;

        -- Check whether the payer holds the instrument.
        -- If not, then we don't even try to fetch the records.
        SELECT count(*) INTO l_count
        FROM   IBY_INSTRHOLDER
        WHERE  instrid = p_instr_id
        AND    ownerid = p_payer_id
        AND    activestatus = 1;

        -- Throw an exception when nothing is found.
        IF( l_count = 0 ) THEN
        FND_MESSAGE.SET_NAME('IBY', 'IBY_20511');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
           -- Returns message 'User does not hold instr'
        END IF;

        -- Call the utility procedure that will do the job
        -- of returning the instrument information.
        Get_Instrument_Details ( payer_id       =>   p_payer_id,
                                  instr_id           =>   p_instr_id,
                                 sys_master_key     =>   p_sys_sec_key,
                       creditcard_tbl     =>   l_creditcard_tbl,
                  purchasecard_tbl   =>   l_purchasecard_tbl,
             bankacct_tbl       =>   l_bankacct_tbl
                     );

        IF( l_creditcard_tbl.count <> 0 ) THEN
           x_pmtInstrRec.InstrumentType := C_INSTRTYPE_CREDITCARD;
           x_pmtInstrRec.CreditCardInstr := l_creditcard_tbl(1);
        ELSIF( l_purchasecard_tbl.count <> 0 ) THEN
           x_pmtInstrRec.InstrumentType := C_INSTRTYPE_PURCHASECARD;
           x_pmtInstrRec.PurchaseCardInstr := l_purchasecard_tbl(1);
        ELSIF( l_bankacct_tbl.count <> 0 ) THEN
           x_pmtInstrRec.InstrumentType := C_INSTRTYPE_BANKACCT;
           x_pmtInstrRec.BankAcctInstr := l_bankacct_tbl(1);
        END IF;

      -- Return success when everything is fine.
   x_msg_count   := 1;

       -- Returns message 'operation completed successfully.'
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204170' );
      FND_MSG_PUB.Add;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

EXCEPTION

   -- Catch for version mismatch and
   -- if the validation level is not full.
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count   := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   -- Catch for all the known errors
   -- thrown from this procedure only.
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count   := 1;
      x_msg_data := FND_MSG_PUB.GET(
                                p_encoded       =>  FND_API.g_false,
                                P_MSG_INDEX     =>  FND_MSG_PUB.Count_msg
                                );

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      iby_utility_pvt.handleException(SQLERRM,SQLCODE);
      FND_MSG_PUB.Count_And_Get
                  (      p_count        =>       x_msg_count,
                         p_data         =>       x_msg_data
                  );

  END OraInstrInq;


        -- Start of comments
        --   API name        : SecureCardInfo
        --   Type            : Private
        --   Function        : Secures other sensitive card data and returns the
	--                     respective segment_IDs.
        --   Parameters      :
        --     IN            : p_cardExpiryDate     IN    DATE            Optional
        --                     p_cardHolderName     IN    VARCHAR2        Optional
        --
  PROCEDURE SecureCardInfo (p_cardExpiryDate     IN  DATE,
		            p_expSegmentId       IN  NUMBER,
	                    p_cardHolderName     IN  VARCHAR2,
		            p_chnameSegmentId    IN  NUMBER,
		            p_chnameMaskSetting  IN  VARCHAR2,
		            p_chnameUnmaskLength IN  NUMBER,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_msg_count          OUT NOCOPY NUMBER,
                            x_msg_data           OUT NOCOPY VARCHAR2,
                            x_resp_rec           OUT NOCOPY SecureCardInfoResp_rec_type
                           ) IS


        --The following 3 variables are meant for output of
        --get_baseurl procedure.
        l_status_url    VARCHAR2(2000);
        l_msg_count_url NUMBER := 0;
        l_msg_data_url  VARCHAR2(2000);

        l_api_name      CONSTANT  VARCHAR2(30) := 'SecureCardInfo';
        l_oapf_action   CONSTANT  VARCHAR2(30) := 'secureCardInfo';
        l_api_version   CONSTANT  NUMBER := 1.0;

	l_url           VARCHAR2(30000) ;
        l_get_baseurl   VARCHAR2(2000);

	l_db_nls        VARCHAR2(80) := NULL;
        l_ecapp_nls     VARCHAR2(80) := NULL;

	l_sec_cred NUMBER;

        l_pos           NUMBER := 0;
        l_post_body     VARCHAR2(30000);
        l_html          VARCHAR2(32767) ;
        l_names         IBY_NETUTILS_PVT.v240_tbl_type;
        l_values        IBY_NETUTILS_PVT.v240_tbl_type;


        --The following 3 variables are meant for output of
        --unpack_results_url procedure.
        l_status        NUMBER := 0;
        l_errcode       NUMBER := 0;
        l_errmessage    VARCHAR2(2000) := 'Success';

  BEGIN

        iby_debug_pub.add(debug_msg => 'Enter',
          debug_level => FND_LOG.LEVEL_PROCEDURE,
          module => G_DEBUG_MODULE || '.SecureCardInfo');

        -- test_debug('SecureCardInfo=> Enter');
        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- START OF BODY OF API

	IF (p_cardExpiryDate IS NULL
	    AND p_cardHolderName IS NULL) THEN
	   RETURN;
	END IF;

        IBY_NETUTILS_PVT.get_baseurl(l_get_baseurl);
         --dbms_output.put_line('l_get_baseurl= ' || l_get_baseurl);
         --test_debug('SecureCardInfo l_get_baseurl= '|| l_get_baseurl);
        -- dbms_output.put_line('l_status_url= ' || l_status_url);
        -- dbms_output.put_line('l_msg_count_url= ' || l_msg_count_url);
        -- dbms_output.put_line('l_msg_data_url= ' || l_msg_data_url);

        -- Construct the full URL to send to the ECServlet.
        l_url := l_get_baseurl;

	l_db_nls := IBY_NETUTILS_PVT.get_local_nls();
        l_ecapp_nls := NULL; -- not passed in this api??

        --MANDATORY INPUT PARAMETERS
        IBY_NETUTILS_PVT.check_mandatory('OapfAction', l_oapf_action, l_url, l_db_nls, l_ecapp_nls);

	--OPTIONAL INPUT PARAMETERS
        IBY_NETUTILS_PVT.check_optional('OapfExpDate', to_char(p_cardExpiryDate,'YYYY-MM-DD'), l_url, l_db_nls, l_ecapp_nls);
	IBY_NETUTILS_PVT.check_optional('OapfExpSegmentId', p_expSegmentId, l_url, l_db_nls, l_ecapp_nls);
	IBY_NETUTILS_PVT.check_optional('OapfChname', p_cardHolderName, l_url, l_db_nls, l_ecapp_nls);
	IBY_NETUTILS_PVT.check_optional('OapfChnameSegmentId', p_chnameSegmentId, l_url, l_db_nls, l_ecapp_nls);
	IBY_NETUTILS_PVT.check_optional('OapfChnameMaskSetting', p_chnameMaskSetting, l_url, l_db_nls, l_ecapp_nls);
	IBY_NETUTILS_PVT.check_optional('OapfChnameUnmaskLen', p_chnameUnmaskLength, l_url, l_db_nls, l_ecapp_nls);

   -- set the security token
   iby_security_pkg.store_credential(l_url,l_sec_cred);
   iby_netutils_pvt.check_mandatory('OapfSecurityToken', TO_CHAR(l_sec_cred),
       l_url, l_db_nls, l_ecapp_nls);

   --test_debug('SecureCardInfo=> full url: '|| l_url);
   --        iby_debug_pub.add(debug_msg => 'SecureCardInfo=> full url: '|| l_url,
   --       debug_level => FND_LOG.LEVEL_PROCEDURE,
   --       module => G_DEBUG_MODULE || '.SecureCardInfo');
   l_pos := INSTR(l_url,'?');
   l_post_body := SUBSTR(l_url,l_pos+1,length(l_url));
   l_post_body := RTRIM(l_post_body,'&');
   l_url := SUBSTR(l_url,1,l_pos-1);
  -- test_debug('SecureCardInfo=> url after stripping: '|| l_url);
  -- test_debug('SecureCardInfo=> post body: '|| l_post_body);


   IBY_NETUTILS_PVT.POST_REQUEST(l_url,l_post_body,l_html);

-- Unpack the results
        IBY_NETUTILS_PVT.UNPACK_RESULTS_URL(l_html,l_names,l_values, l_status, l_errcode, l_errmessage);


        --Raising Exception to handle errors in unpacking resulting html file.
        IF (l_status = -1) THEN
           --test_debug('unpack error !!');
           iby_debug_pub.add(debug_msg => 'Unpack status error; HTML resp. invalid!',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.SecureCardInfo');
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204403_HTML_UNPACK_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Raising Exception to handle Servlet related errors.
        IF (l_names.COUNT = 0) THEN
           --test_debug('response count is 0 !!');
           iby_debug_pub.add(debug_msg => 'HTML response names count=0',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.SecureCardInfo');
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204402_JSERVLET_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        /* Retrieve name-value pairs stored in l_names and l_values, and assign
           them to the output record: x_reqresp_rec.
        */
        --test_debug('Setting fields from unpacked response');
        iby_debug_pub.add(debug_msg => 'Setting fields from unpacked response',
              debug_level => FND_LOG.LEVEL_STATEMENT,
              module => G_DEBUG_MODULE || '.SecureCardInfo');


        FOR i IN 1..l_names.COUNT LOOP
            --Payment Server Related Generic Response
            IF l_names(i) = 'OapfStatus' THEN
               x_resp_rec.Response.Status := TO_NUMBER(l_values(i));
               iby_debug_pub.add(debug_msg => 'Response status=' || x_resp_rec.Response.Status,
                debug_level => FND_LOG.LEVEL_STATEMENT,
                module => G_DEBUG_MODULE || '.SecureCardInfo');
                --test_debug('OapfStatus: '||x_resp_rec.Response.Status);
            ELSIF l_names(i) = 'OapfCode' THEN
               x_resp_rec.Response.ErrCode := l_values(i);
               iby_debug_pub.add(debug_msg => 'Response code=' || x_resp_rec.Response.ErrCode,
                debug_level => FND_LOG.LEVEL_STATEMENT,
                module => G_DEBUG_MODULE || '.SecureCardInfo');
                --test_debug('OapfCode: '||x_resp_rec.Response.ErrCode);
            ELSIF l_names(i) = 'OapfCause' THEN
               x_resp_rec.Response.ErrMessage := l_values(i);
               iby_debug_pub.add(debug_msg => 'Response message=' || x_resp_rec.Response.ErrMessage,
                debug_level => FND_LOG.LEVEL_STATEMENT,
                module => G_DEBUG_MODULE || '.SecureCardInfo');
                --test_debug('OapfCause: '||x_resp_rec.Response.ErrMessage);
            ELSIF l_names(i) = 'OapfNlsLang' THEN
               x_resp_rec.Response.NLS_LANG := l_values(i);

            --SecureCardInfo Response Related Response
            ELSIF l_names(i) = 'OapfExpSegmentId' THEN
               x_resp_rec.ExpiryDateSegmentId := TO_NUMBER(l_values(i));
                       --test_debug('OapfExpSegmentId: '||x_resp_rec.ExpiryDateSegmentId);
	    ELSIF l_names(i) = 'OapfMaskedChname' THEN
               x_resp_rec.MaskedChname := l_values(i);
	    ELSIF l_names(i) = 'OapfChnameSegmentId' THEN
               x_resp_rec.ChnameSegmentId := TO_NUMBER(l_values(i));
                       --test_debug('OapfChnameSegmentId: '||x_resp_rec.ChnameSegmentId);
	    ELSIF l_names(i) = 'OapfChnameMaskSetting' THEN
               x_resp_rec.ChnameMaskSetting := l_values(i);
	    ELSIF l_names(i) = 'OapfChnameUnmaskLen' THEN
               x_resp_rec.ChnameUnmaskLength := TO_NUMBER(l_values(i));
            END IF;

        END LOOP;

        -- Use for Debugging
        --dbms_output.put_line('after successfully mapping results');

        -- Standard check of p_commit.
        /*
        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;
        */

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                    p_data   =>   x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
              debug_level => FND_LOG.LEVEL_STATEMENT,
              module => G_DEBUG_MODULE || '.SecureCardInfo');
        iby_debug_pub.add(debug_msg => 'req response status=' || x_resp_rec.Response.Status,
              debug_level => FND_LOG.LEVEL_STATEMENT,
              module => G_DEBUG_MODULE || '.SecureCardInfo');

        iby_debug_pub.add(debug_msg => 'Exit',
              debug_level => FND_LOG.LEVEL_PROCEDURE,
              module => G_DEBUG_MODULE || '.SecureCardInfo');
        --test_debug('Exit*******');

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || '.SecureCardInfo');
         --ROLLBACK TO OraPmtReq_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.SecureCardInfo');
         --ROLLBACK TO OraPmtReq_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.SecureCardInfo');
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data
                                   );

      iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.SecureCardInfo');
      iby_debug_pub.add(debug_msg => 'Exit Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.SecureCardInfo');

   END SecureCardInfo;

   PROCEDURE Get_Expiration_Status
                    ( p_instrid     IN  NUMBER,
		      p_inputDate   IN  DATE,
	              x_return_status      OUT NOCOPY VARCHAR2,
                      x_msg_count          OUT NOCOPY NUMBER,
                      x_msg_data           OUT NOCOPY VARCHAR2,
                      x_resp_rec           OUT NOCOPY GetExpStatusResp_rec_type
                    )
   IS
        --The following 3 variables are meant for output of
        --get_baseurl procedure.
        l_status_url    VARCHAR2(2000);
        l_msg_count_url NUMBER := 0;
        l_msg_data_url  VARCHAR2(2000);

        l_api_name      CONSTANT  VARCHAR2(30) := 'Get_Expiration_Status';
        l_oapf_action   CONSTANT  VARCHAR2(30) := 'checkCCExpiry';
        l_api_version   CONSTANT  NUMBER := 1.0;

	l_url           VARCHAR2(30000) ;
        l_get_baseurl   VARCHAR2(2000);

	l_db_nls        VARCHAR2(80) := NULL;
        l_ecapp_nls     VARCHAR2(80) := NULL;

	l_sec_cred NUMBER;

        l_pos           NUMBER := 0;
        l_post_body     VARCHAR2(30000);
        l_html          VARCHAR2(32767) ;
        l_names         IBY_NETUTILS_PVT.v240_tbl_type;
        l_values        IBY_NETUTILS_PVT.v240_tbl_type;


        --The following 3 variables are meant for output of
        --unpack_results_url procedure.
        l_status        NUMBER := 0;
        l_errcode       NUMBER := 0;
        l_errmessage    VARCHAR2(2000) := 'Success';
   BEGIN
          iby_debug_pub.add(debug_msg => 'Enter',
          debug_level => FND_LOG.LEVEL_PROCEDURE,
          module => G_DEBUG_MODULE || '.Get_Expiration_Status');

        -- test_debug('SecureCardInfo=> Enter');
        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- START OF BODY OF API


        IBY_NETUTILS_PVT.get_baseurl(l_get_baseurl);
         --dbms_output.put_line('l_get_baseurl= ' || l_get_baseurl);
         --test_debug('SecureCardInfo l_get_baseurl= '|| l_get_baseurl);
        -- dbms_output.put_line('l_status_url= ' || l_status_url);
        -- dbms_output.put_line('l_msg_count_url= ' || l_msg_count_url);
        -- dbms_output.put_line('l_msg_data_url= ' || l_msg_data_url);

        -- Construct the full URL to send to the ECServlet.
        l_url := l_get_baseurl;

	l_db_nls := IBY_NETUTILS_PVT.get_local_nls();
        l_ecapp_nls := NULL; -- not passed in this api??

        --MANDATORY INPUT PARAMETERS
        IBY_NETUTILS_PVT.check_mandatory('OapfAction', l_oapf_action, l_url, l_db_nls, l_ecapp_nls);

        IBY_NETUTILS_PVT.check_mandatory('OapfInstrid', p_instrid, l_url, l_db_nls, l_ecapp_nls);
	IBY_NETUTILS_PVT.check_mandatory('OapfInputDate', to_char(p_inputDate,'YYYY-MM-DD'), l_url, l_db_nls, l_ecapp_nls);

   -- set the security token
   iby_security_pkg.store_credential(l_url,l_sec_cred);
   iby_netutils_pvt.check_mandatory('OapfSecurityToken', TO_CHAR(l_sec_cred),
       l_url, l_db_nls, l_ecapp_nls);

   --test_debug('Get_Expiration_Status=> full url: '|| l_url);
           iby_debug_pub.add(debug_msg => 'Get_Expiration_Status=> full url: '|| l_url,
          debug_level => FND_LOG.LEVEL_PROCEDURE,
          module => G_DEBUG_MODULE || '.Get_Expiration_Status');
   l_pos := INSTR(l_url,'?');
   l_post_body := SUBSTR(l_url,l_pos+1,length(l_url));
   l_post_body := RTRIM(l_post_body,'&');
   l_url := SUBSTR(l_url,1,l_pos-1);
  -- test_debug('SecureCardInfo=> url after stripping: '|| l_url);
  -- test_debug('SecureCardInfo=> post body: '|| l_post_body);


   IBY_NETUTILS_PVT.POST_REQUEST(l_url,l_post_body,l_html);

-- Unpack the results
        IBY_NETUTILS_PVT.UNPACK_RESULTS_URL(l_html,l_names,l_values, l_status, l_errcode, l_errmessage);


        --Raising Exception to handle errors in unpacking resulting html file.
        IF (l_status = -1) THEN
           --test_debug('unpack error !!');
           iby_debug_pub.add(debug_msg => 'Unpack status error; HTML resp. invalid!',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204403_HTML_UNPACK_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Raising Exception to handle Servlet related errors.
        IF (l_names.COUNT = 0) THEN
           --test_debug('response count is 0 !!');
           iby_debug_pub.add(debug_msg => 'HTML response names count=0',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
           FND_MESSAGE.SET_NAME('IBY', 'IBY_204402_JSERVLET_ERROR');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        /* Retrieve name-value pairs stored in l_names and l_values, and assign
           them to the output record: x_reqresp_rec.
        */
        --test_debug('Setting fields from unpacked response');
        iby_debug_pub.add(debug_msg => 'Setting fields from unpacked response',
              debug_level => FND_LOG.LEVEL_STATEMENT,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');


        FOR i IN 1..l_names.COUNT LOOP
            --Payment Server Related Generic Response
            IF l_names(i) = 'OapfStatus' THEN
               x_resp_rec.Response.Status := TO_NUMBER(l_values(i));
               iby_debug_pub.add(debug_msg => 'Response status=' || x_resp_rec.Response.Status,
                debug_level => FND_LOG.LEVEL_STATEMENT,
                module => G_DEBUG_MODULE || '.Get_Expiration_Status');
                --test_debug('OapfStatus: '||x_resp_rec.Response.Status);
            ELSIF l_names(i) = 'OapfCode' THEN
               x_resp_rec.Response.ErrCode := l_values(i);
               iby_debug_pub.add(debug_msg => 'Response code=' || x_resp_rec.Response.ErrCode,
                debug_level => FND_LOG.LEVEL_STATEMENT,
                module => G_DEBUG_MODULE || '.Get_Expiration_Status');
                --test_debug('OapfCode: '||x_resp_rec.Response.ErrCode);
            ELSIF l_names(i) = 'OapfCause' THEN
               x_resp_rec.Response.ErrMessage := l_values(i);
               iby_debug_pub.add(debug_msg => 'Response message=' || x_resp_rec.Response.ErrMessage,
                debug_level => FND_LOG.LEVEL_STATEMENT,
                module => G_DEBUG_MODULE || '.Get_Expiration_Status');
                --test_debug('OapfCause: '||x_resp_rec.Response.ErrMessage);
            ELSIF l_names(i) = 'OapfNlsLang' THEN
               x_resp_rec.Response.NLS_LANG := l_values(i);

            --GetExpStatusResp_rec_type Response Related Response
            ELSIF l_names(i) = 'OapfExpired' THEN
               x_resp_rec.Expired := l_values(i);
                       --test_debug('OapfExpSegmentId: '||x_resp_rec.ExpiryDateSegmentId);
	    END IF;

        END LOOP;

        -- Use for Debugging
        --dbms_output.put_line('after successfully mapping results');

        -- Standard check of p_commit.
        /*
        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;
        */

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                    p_data   =>   x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
              debug_level => FND_LOG.LEVEL_STATEMENT,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
        iby_debug_pub.add(debug_msg => 'req response status=' || x_resp_rec.Response.Status,
              debug_level => FND_LOG.LEVEL_STATEMENT,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');

        iby_debug_pub.add(debug_msg => 'Exit',
              debug_level => FND_LOG.LEVEL_PROCEDURE,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
        --test_debug('Exit*******');

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
         --ROLLBACK TO OraPmtReq_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
         --ROLLBACK TO OraPmtReq_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data
                                   );

      iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
      iby_debug_pub.add(debug_msg => 'Exit Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || '.Get_Expiration_Status');
   END Get_Expiration_Status;



END IBY_INSTRREG_PUB;

/
