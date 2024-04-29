--------------------------------------------------------
--  DDL for Package Body IBY_FNDCPT_TRXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FNDCPT_TRXN_PUB" AS
/*$Header: ibyfctxb.pls 120.57.12010000.37 2010/01/25 08:33:43 sgogula ship $*/

/* ======================================================================*
| Global Data Types                                                     |
* ======================================================================*/
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;


  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_FNDCPT_TRXN_PUB';

  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FNDCPT_TRXN_PUB';

 --
 -- Constants
 --
 CC_CAPTURE_TRXNTYPE     CONSTANT NUMBER(15,0) := 8;
 BA_CAPTURE_TRXNTYPE     CONSTANT NUMBER(15,0) := 100;
 CC_PMTCHANNEL_CODE      CONSTANT VARCHAR2(30) := 'CREDIT_CARD';
 DC_PMTCHANNEL_CODE      CONSTANT VARCHAR2(30) := 'PINLESS_DEBIT_CARD';
 BA_PMT_CHANNEL_CODE     CONSTANT VARCHAR2(30) := 'BANK_ACCT_XFER';
 CC_INSTR_TYPE           CONSTANT VARCHAR2(30) :='CREDITCARD';
 DC_INSTR_TYPE           CONSTANT VARCHAR2(30) :='DEBITCARD';
 BA_INSTR_TYPE           CONSTANT VARCHAR2(30) :='BANKACCOUNT';
 GATEWAY_SETTLEMENT_STATUS   CONSTANT VARCHAR2(30) := '11';
 PROCESSOR_SETTLEMENT_STATUS CONSTANT VARCHAR2(30) := '100';

-------------------------------------------------------------------------
-- II. Record Types
-------------------------------------------------------------------------

  -- Bug : 8763944
  --Added last two columns in rec to get trxn_core info.
   TYPE FuncCaptureOrder_rec_type IS RECORD (
     TRXNMID                    IBY_TRXN_SUMMARIES_ALL.TRXNMID%TYPE,
     -- From IBY_FNDCPT_TX_EXTENSIONS
     TRXN_REF_NUMBER1           IBY_FNDCPT_TX_EXTENSIONS.TRXN_REF_NUMBER1%TYPE,
     TRXN_REF_NUMBER2           IBY_FNDCPT_TX_EXTENSIONS.TRXN_REF_NUMBER2%TYPE,
     PAYMENT_CHANNEL_CODE       IBY_FNDCPT_TX_EXTENSIONS.PAYMENT_CHANNEL_CODE%TYPE,
     PO_NUMBER                  IBY_FNDCPT_TX_EXTENSIONS.PO_NUMBER%TYPE,
     VOICE_AUTHORIZATION_FLAG   IBY_FNDCPT_TX_EXTENSIONS.VOICE_AUTHORIZATION_FLAG%TYPE,
     PAYMENT_FUNCTION           IBY_EXTERNAL_PAYERS_ALL.PAYMENT_FUNCTION%TYPE,
     -- From the ORDERS View
     CALL_APP_SERVICE_REQ_CODE  IBY_TRXN_SUMMARIES_ALL.CALL_APP_SERVICE_REQ_CODE%TYPE,
     --CALLING_APP_DOC_REF_NUMBER IBY_TRXN_SUMMARIES_ALL.CALLING_APP_DOC_REF_NUMBER%TYPE,
     SETTLEMENT_DATE            IBY_TRXN_SUMMARIES_ALL.SETTLEDATE%TYPE,
     SETTLEMENT_DUE_DATE        IBY_TRXN_SUMMARIES_ALL.SETTLEMENT_DUE_DATE%TYPE,
     BR_MATURITY_DATE           IBY_TRXN_SUMMARIES_ALL.BR_MATURITY_DATE%TYPE,
     ORDER_DESCRIPTION          VARCHAR2(255),
     SETTLEMENT_CURRENCY_CODE   IBY_TRXN_SUMMARIES_ALL.CURRENCYNAMECODE%TYPE,
     SETTLEMENT_AMOUNT          IBY_TRXN_SUMMARIES_ALL.AMOUNT%TYPE,
     PAYMENT_TRXN_EXTENSION_ID  IBY_FNDCPT_TX_EXTENSIONS.TRXN_EXTENSION_ID%TYPE,
     INTERNAL_BANK_ACCOUNT_ID   CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
     PAYER_PARTY_ID             IBY_EXTERNAL_PAYERS_ALL.PARTY_ID%TYPE,
     CUST_ACCOUNT_ID            IBY_TRXN_SUMMARIES_ALL.CUST_ACCOUNT_ID%TYPE,
     ACCT_SITE_USE_ID           IBY_TRXN_SUMMARIES_ALL.ACCT_SITE_USE_ID%TYPE,
     ORG_ID                     IBY_TRXN_SUMMARIES_ALL.ORG_ID%TYPE,
     ORG_TYPE                   IBY_TRXN_SUMMARIES_ALL.ORG_TYPE%TYPE,
     LEGAL_ENTITY_ID            IBY_TRXN_SUMMARIES_ALL.LEGAL_ENTITY_ID%TYPE,
     BILL_TO_ADDRESS_ID         IBY_TRXN_SUMMARIES_ALL.BILL_TO_ADDRESS_ID%TYPE,
     SETTLEMENT_CUSTOMER_REFERENCE IBY_TRXN_SUMMARIES_ALL.SETTLEMENT_CUSTOMER_REFERENCE%TYPE,
     AR_RECEIPT_METHOD_ID       IBY_TRXN_SUMMARIES_ALL.AR_RECEIPT_METHOD_ID%TYPE,
     BR_DRAWEE_ISSUED_FLAG      IBY_TRXN_SUMMARIES_ALL.BR_DRAWEE_ISSUED_FLAG%TYPE,
     BR_SIGNED_FLAG             IBY_TRXN_SUMMARIES_ALL.BR_SIGNED_FLAG%TYPE,
     BR_DISPUTED_FLAG	        VARCHAR2(1),
     ATTRIBUTE_CATEGORY         VARCHAR2(150),
     ATTRIBUTE1                 VARCHAR2(150),
     ATTRIBUTE2                 VARCHAR2(150),
     ATTRIBUTE3                 VARCHAR2(150),
     ATTRIBUTE4                 VARCHAR2(150),
     ATTRIBUTE5                 VARCHAR2(150),
     ATTRIBUTE6                 VARCHAR2(150),
     ATTRIBUTE7                 VARCHAR2(150),
     ATTRIBUTE8                 VARCHAR2(150),
     ATTRIBUTE9                 VARCHAR2(150),
     ATTRIBUTE10                VARCHAR2(150),
     ATTRIBUTE11                VARCHAR2(150),
     ATTRIBUTE12                VARCHAR2(150),
     ATTRIBUTE13                VARCHAR2(150),
     ATTRIBUTE14                VARCHAR2(150),
     ATTRIBUTE15                VARCHAR2(150),
     CREATED_BY                 IBY_TRXN_SUMMARIES_ALL.CREATED_BY%TYPE,
     CREATION_DATE              IBY_TRXN_SUMMARIES_ALL.CREATION_DATE%TYPE,
     LAST_UPDATED_BY            IBY_TRXN_SUMMARIES_ALL.LAST_UPDATED_BY%TYPE,
     LAST_UPDATE_DATE           IBY_TRXN_SUMMARIES_ALL.LAST_UPDATE_DATE%TYPE,
     LAST_UPDATE_LOGIN          IBY_TRXN_SUMMARIES_ALL.LAST_UPDATE_LOGIN%TYPE,
     OBJECT_VERSION_NUMBER      IBY_TRXN_SUMMARIES_ALL.OBJECT_VERSION_NUMBER%TYPE,
     -- From auth table
     auth_transactionid         IBY_TRXN_SUMMARIES_ALL.transactionid%TYPE,
     auth_sales_rep_party_id    IBY_TRXN_SUMMARIES_ALL.sales_rep_party_id%TYPE,
     auth_tangibleid            IBY_TRXN_SUMMARIES_ALL.tangibleid%TYPE,
     auth_bepkey                IBY_TRXN_SUMMARIES_ALL.bepkey%TYPE,
     auth_payeeid               IBY_TRXN_SUMMARIES_ALL.payeeid%TYPE,
     auth_bepid                 IBY_TRXN_SUMMARIES_ALL.bepid%TYPE,
     auth_mpayeeid              IBY_TRXN_SUMMARIES_ALL.mpayeeid%TYPE,
     auth_ecappid               IBY_TRXN_SUMMARIES_ALL.ecappid%TYPE,
     auth_paymentmethodname     IBY_TRXN_SUMMARIES_ALL.paymentmethodname%TYPE,
     auth_mtangibleid           IBY_TRXN_SUMMARIES_ALL.mtangibleid%TYPE,
     auth_payeeinstrid          IBY_TRXN_SUMMARIES_ALL.payeeinstrid%TYPE,
     auth_payerid               IBY_TRXN_SUMMARIES_ALL.payerid%TYPE,
     auth_payerinstrid          IBY_TRXN_SUMMARIES_ALL.payerinstrid%TYPE,
     auth_detaillookup          IBY_TRXN_SUMMARIES_ALL.detaillookup%TYPE,
     auth_instrnumber           IBY_TRXN_SUMMARIES_ALL.instrnumber%TYPE,
     auth_instrtype             IBY_TRXN_SUMMARIES_ALL.instrtype%TYPE,
     auth_instrsubtype          IBY_TRXN_SUMMARIES_ALL.instrsubtype%TYPE,
     auth_currencynamecode      IBY_TRXN_SUMMARIES_ALL.currencynamecode%TYPE,
     auth_desturl               IBY_TRXN_SUMMARIES_ALL.desturl%TYPE,
     auth_nlslang               IBY_TRXN_SUMMARIES_ALL.nlslang%TYPE,
     auth_amount                IBY_TRXN_SUMMARIES_ALL.amount%TYPE,
     auth_process_profile_code  IBY_TRXN_SUMMARIES_ALL.process_profile_code%TYPE,
     auth_payment_channel_code  IBY_TRXN_SUMMARIES_ALL.payment_channel_code%TYPE,
     auth_proc_reference_code   IBY_TRXN_SUMMARIES_ALL.proc_reference_code%TYPE,
     auth_proc_reference_amount IBY_TRXN_SUMMARIES_ALL.proc_reference_amount%TYPE,
     auth_legal_entity_id       IBY_TRXN_SUMMARIES_ALL.legal_entity_id%TYPE,
     auth_settlement_due_date   IBY_TRXN_SUMMARIES_ALL.settlement_due_date%TYPE,
     auth_bill_to_address_id    IBY_TRXN_SUMMARIES_ALL.bill_to_address_id%TYPE,
     auth_br_maturity_date      IBY_TRXN_SUMMARIES_ALL.br_maturity_date%TYPE,
     auth_factored_flag         IBY_TRXN_SUMMARIES_ALL.factored_flag%TYPE,
     -- From Payers table
     auth_payment_function      IBY_EXTERNAL_PAYERS_ALL.PAYMENT_FUNCTION%TYPE,
     auth_payer_party_id        IBY_EXTERNAL_PAYERS_ALL.PARTY_ID%TYPE,
     auth_cust_account_id       IBY_EXTERNAL_PAYERS_ALL.CUST_ACCOUNT_ID%TYPE,
     auth_acct_site_use_id      IBY_EXTERNAL_PAYERS_ALL.ACCT_SITE_USE_ID%TYPE,
     auth_org_id                IBY_EXTERNAL_PAYERS_ALL.ORG_ID%TYPE,
     auth_org_type              IBY_EXTERNAL_PAYERS_ALL.ORG_TYPE%TYPE,
     bep_type                   IBY_BEPINFO.bep_type%TYPE,
     payer_instr_assignment_id  IBY_TRXN_SUMMARIES_ALL.payer_instr_assignment_id%TYPE,
     debit_auth_flag            IBY_TRXN_SUMMARIES_ALL.debit_auth_flag%TYPE,
     debit_auth_method          IBY_TRXN_SUMMARIES_ALL.debit_auth_method%TYPE,
     debit_auth_reference       IBY_TRXN_SUMMARIES_ALL.debit_auth_reference%TYPE,
     capture_transaction_id     IBY_TRXN_SUMMARIES_ALL.transactionid%TYPE,
     int_bank_country           VARCHAR2(60),
     settle_req_vrfy            IBY_FNDCPT_SYS_EFT_PF_B.SETTLE_REQUIRE_VRFY_FLAG%TYPE,
     auth_count                 PLS_INTEGER,
     auth_dirdeb_instruction_code       IBY_TRXN_SUMMARIES_ALL.dirdeb_instruction_code%TYPE,
     card_subtype_code          IBY_TRXN_CORE.card_subtype_code%TYPE,
     card_data_level            IBY_TRXN_CORE.card_data_level%TYPE
   );




-- II.2 Table Types

  TYPE caFundcaptureOrdersTabType IS TABLE OF FuncCaptureOrder_rec_type
    INDEX BY BINARY_INTEGER;

  --
  -- Use: Determines cause of the instrument assignments view returning no
  --      data
  FUNCTION Get_Payer_Instr_Assgn_Fail
  (p_instr_assign_id IN iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE,
   p_payer           IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type
  )
  RETURN VARCHAR2
  IS
    l_msg             VARCHAR2(100);
    l_payer_id        iby_pmt_instr_uses_all.ext_pmt_party_id%TYPE;
    l_party_id        iby_external_payers_all.party_id%TYPE;

    l_count NUMBER;

    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Get_Payer_Instr_Assgn_Fail';
  BEGIN

    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    iby_debug_pub.add('instr assignment id:=' || p_instr_assign_id,
                      G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;

    l_msg := 'IBY_INVALID_INSTR_ASSIGN';

    -- Bug: 7719030
    -- Handling Exceptions in a different way
    BEGIN

    SELECT ext_pmt_party_id
    INTO l_payer_id
    FROM iby_pmt_instr_uses_all
    WHERE (instrument_payment_use_id = p_instr_assign_id);

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    iby_debug_pub.add('payer id:=' || l_payer_id,G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
     iby_debug_pub.add('Exception: No Instrument found',G_LEVEL_EXCEPTION,l_dbg_mod);
    END IF;
    RETURN l_msg;
   END;


    l_msg := 'IBY_20491';
    SELECT party_id
    INTO l_party_id
    FROM iby_external_payers_all
    WHERE (ext_payer_id = l_payer_id);

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('external payer count:=' || SQL%ROWCOUNT,G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;

    IF (SQL%ROWCOUNT < 1) THEN RETURN l_msg; END IF;

    l_msg := 'IBY_INVALID_PARTY_CONTEXT';
    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     iby_debug_pub.add('party id:=' || l_party_id,G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    IF (l_party_id <> p_payer.Party_Id) THEN RETURN l_msg; END IF;

    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    RETURN null;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN l_msg;
  END Get_Payer_Instr_Assgn_Fail;

  --
  -- Use: Determine the reason extension lookup failed in the auth API
  --
  FUNCTION Get_Extension_Auth_Fail
  (p_trxn_extension_id  IN  iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
   p_payer              IN  IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type
  )
  RETURN VARCHAR2
  IS
    l_msg  VARCHAR2(100);
    l_instr_assign_id iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE;
    l_ext_payer_id    iby_fndcpt_tx_extensions.ext_payer_id%TYPE;

    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Get_Extension_Auth_Fail';
  BEGIN

    l_msg := 'IBY_INVALID_TXN_EXTENSION';
   -- Bug: 7719030.
   --Changing exception handling.
    BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;


    SELECT instr_assignment_id, ext_payer_id
    INTO l_instr_assign_id, l_ext_payer_id
    FROM iby_fndcpt_tx_extensions
    WHERE (p_trxn_extension_id = trxn_extension_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN l_msg;
    END;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('checking instrument assignment',G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    l_msg := Get_Payer_Instr_Assgn_Fail(l_instr_assign_id,p_payer);

    IF (NOT l_msg IS NULL) THEN RETURN l_msg; END IF;

    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('EXIT',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN l_msg;
  END Get_Extension_Auth_Fail;

  --
  -- Use: Gets the encryption mode for transaction extensions
  --
  FUNCTION Get_Extension_Encrypt_Mode
  RETURN iby_sys_security_options.instr_sec_code_encryption_mode%TYPE
  IS
    l_mode iby_sys_security_options.instr_sec_code_encryption_mode%TYPE;
    CURSOR c_encrypt_mode
    IS
      SELECT instr_sec_code_encryption_mode
      FROM iby_sys_security_options;
    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Get_Extension_Encrypt_Mode';
  BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    IF (c_encrypt_mode%ISOPEN) THEN CLOSE c_encrypt_mode; END IF;

    OPEN c_encrypt_mode;
    FETCH c_encrypt_mode INTO l_mode;
    CLOSE c_encrypt_mode;

    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    RETURN l_mode;
  END Get_Extension_Encrypt_Mode;

  FUNCTION Get_Tangible_Id
  (p_app_short_name    IN fnd_application.application_short_name%TYPE,
   p_order_id          IN iby_fndcpt_tx_extensions.order_id%TYPE,
   p_trxn_ref1         IN iby_fndcpt_tx_extensions.trxn_ref_number1%TYPE,
   p_trxn_ref2         IN iby_fndcpt_tx_extensions.trxn_ref_number2%TYPE
  )
  RETURN iby_trxn_summaries_all.tangibleid%TYPE
  IS
    l_tangible_id      iby_trxn_summaries_all.tangibleid%TYPE;
    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Get_Tangible_Id';
  BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter with 4 params',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    l_tangible_id := p_app_short_name || '_' || p_order_id;

    IF (NOT p_trxn_ref1 IS NULL) THEN
      l_tangible_id := l_tangible_id || '_' || p_trxn_ref1;
    END IF;
    IF (NOT p_trxn_ref2 IS NULL) THEN
      l_tangible_id := l_tangible_id || '_' || p_trxn_ref2;
    END IF;

    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    RETURN l_tangible_id;
  END Get_Tangible_Id;

  --Overloading this function for bug : 7628586
  FUNCTION Get_Tangible_Id
  (p_app_short_name    IN fnd_application.application_short_name%TYPE,
   p_trxn_extn_id         IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE
  )
  RETURN iby_trxn_summaries_all.tangibleid%TYPE
  IS
    l_tangible_id      iby_trxn_summaries_all.tangibleid%TYPE;
    l_cust_pson        VARCHAR2(30);
    l_msg              VARCHAR2(10);
    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Get_Tangible_Id';
  BEGIN
   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter with 2 params',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;

   -- Bug# 8544953
   -- This API returns customized PSON if the customer had implemented the custome code
   IBY_PSON_CUSTOMIZER_PKG.Get_Custom_Tangible_Id(p_app_short_name, p_trxn_extn_id, l_cust_pson, l_msg);
   IF( l_msg = IBY_PSON_CUSTOMIZER_PKG.G_CUST_PSON_YES ) THEN
      l_tangible_id := l_cust_pson;
      iby_debug_pub.add('Customized PSON :='||l_tangible_id,G_LEVEL_PROCEDURE,l_dbg_mod);
   ELSE
      --Bug# 8535868
      --Removing '_' since this is not accepted by FDC
      -- l_tangible_id := p_app_short_name || '_' || p_trxn_extn_id;
      l_tangible_id := p_app_short_name || p_trxn_extn_id;
      iby_debug_pub.add('PSON:' ||l_tangible_id || ' was not customized',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;

   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;
    RETURN l_tangible_id;
  END Get_Tangible_Id;
  --End of Overloaded Function

  --
  -- Use: Gets the internal payee id from a payee context
  --
  FUNCTION Get_Internal_Payee(p_payee IN PayeeContext_rec_type)
  RETURN iby_payee.payeeid%TYPE
  IS
    l_payeeid  iby_payee.payeeid%TYPE;

    CURSOR c_payeeid
    (ci_org_type IN iby_fndcpt_payee_appl.org_type%TYPE,
     ci_org_id   IN iby_fndcpt_payee_appl.org_id%TYPE
    )
    IS
      SELECT p.payeeid
      FROM iby_payee p, iby_fndcpt_payee_appl a
      WHERE (p.mpayeeid = a.mpayeeid)
        AND ((a.org_type = ci_org_type) AND (a.org_id = ci_org_id));

    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Get_Internal_Payee';
  BEGIN
   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;

    IF (c_payeeid%ISOPEN) THEN CLOSE c_payeeid; END IF;

    OPEN c_payeeid(p_payee.Org_Type, p_payee.Org_Id);
    FETCH c_payeeid INTO l_payeeid;
    IF (c_payeeid%NOTFOUND) THEN
      l_payeeid := NULL;
    END IF;
    CLOSE c_payeeid;

   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;

    RETURN l_payeeid;
  END Get_Internal_Payee;

  FUNCTION Get_Tx_Extension_Copy_Count
  (p_trxn_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
  RETURN NUMBER
  IS
    l_copy_count    NUMBER;

    CURSOR c_xe_copies(ci_x_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
    IS
      SELECT COUNT(copy_trxn_extension_id)
      FROM iby_fndcpt_tx_xe_copies
      WHERE (source_trxn_extension_id = ci_x_id);

    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Get_Tx_Extension_Copy_Count';
  BEGIN
   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;

    IF (c_xe_copies%ISOPEN) THEN CLOSE c_xe_copies; END IF;

    OPEN c_xe_copies(p_trxn_extension_id);
    FETCH c_xe_copies INTO l_copy_count;
    CLOSE c_xe_copies;
   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;


    RETURN NVL(l_copy_count,0);
  END Get_Tx_Extension_Copy_Count;

  --
  -- Use: Validates the transaction extension attributes based upon their
  --      use by the payment channel
  --
  FUNCTION Extension_Valid
  (p_pmt_channel IN VARCHAR2,
   p_trxn_attribs IN TrxnExtension_rec_type,
   p_update      IN BOOLEAN,
   p_consumed_cvv2 IN BOOLEAN
  )
  RETURN BOOLEAN
  IS
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(100);
    l_channel_attribs IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;
    l_response IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.Extension_Valid';
  BEGIN
   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;


    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('validating xtension',G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Call -> IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs',
                        G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs
    (1.0, FND_API.G_FALSE, l_return_status, l_msg_count, l_msg_data,
     p_pmt_channel, l_channel_attribs, l_response);

     IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       iby_debug_pub.add('Return from IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs',
                    G_LEVEL_STATEMENT,l_dbg_mod);
     END IF;
    IF (l_response.Result_Code <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS) THEN
      RETURN FALSE;
    END IF;

    IF ( (l_channel_attribs.Instr_SecCode_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_REQUIRED)
        AND
          ( ((p_trxn_attribs.Instrument_Security_Code IS NULL)
             AND (NOT p_update)
             AND (NOT p_consumed_cvv2)
            )
          OR (p_trxn_attribs.Instrument_Security_Code = FND_API.G_MISS_CHAR)
          )
       )
    THEN
      RETURN FALSE;
    END IF;
    IF ( (l_channel_attribs.Instr_SecCode_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_DISABLED)
        AND NOT ( (p_trxn_attribs.Instrument_Security_Code IS NULL) OR
                  (p_trxn_attribs.Instrument_security_Code = FND_API.G_MISS_CHAR)
                )
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (l_channel_attribs.Instr_VoiceAuthFlag_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_REQUIRED)
        AND ( (p_trxn_attribs.VoiceAuth_Flag IS NULL AND (NOT p_update))
         OR (p_trxn_attribs.VoiceAuth_Flag = FND_API.G_MISS_CHAR) )
       )
    THEN
      RETURN FALSE;
    END IF;
    --Fix for bug# 6404912: Voice Auth flag 'N' and NULL treated similarly
    IF ( (l_channel_attribs.Instr_VoiceAuthFlag_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_DISABLED)
        AND NOT ( ( nvl(p_trxn_attribs.VoiceAuth_Flag, 'N') = 'N') OR
                  (p_trxn_attribs.VoiceAuth_Flag = FND_API.G_MISS_CHAR)
                )
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (l_channel_attribs.Instr_VoiceAuthCode_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_REQUIRED)
        AND ( (p_trxn_attribs.VoiceAuth_Code IS NULL AND (NOT p_update))
            OR (p_trxn_attribs.VoiceAuth_Code = FND_API.G_MISS_CHAR)
            )
       )
    THEN
      RETURN FALSE;
    END IF;
    IF ( (l_channel_attribs.Instr_VoiceAuthCode_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_DISABLED)
        AND NOT ( (p_trxn_attribs.VoiceAuth_Code IS NULL) OR
                  (p_trxn_attribs.VoiceAuth_Code = FND_API.G_MISS_CHAR)
                )
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (l_channel_attribs.Instr_VoiceAuthDate_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_REQUIRED)
        AND ( (p_trxn_attribs.VoiceAuth_Date IS NULL AND (NOT p_update)) OR
              (p_trxn_attribs.VoiceAuth_Date = FND_API.G_MISS_DATE) )
       )
    THEN
      RETURN FALSE;
    END IF;
    IF ( (l_channel_attribs.Instr_VoiceAuthDate_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_DISABLED)
        AND NOT ( (p_trxn_attribs.VoiceAuth_Date IS NULL) OR
                  (p_trxn_attribs.VoiceAuth_Date = FND_API.G_MISS_DATE)
                )
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (l_channel_attribs.PO_Number_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_REQUIRED)
        AND ( (p_trxn_attribs.PO_Number IS NULL AND (NOT p_update))
            OR (p_trxn_attribs.PO_Number = FND_API.G_MISS_CHAR) )
       )
    THEN
      RETURN FALSE;
    END IF;
    IF ( (l_channel_attribs.PO_Number_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_DISABLED)
        AND NOT ( (p_trxn_attribs.PO_Number IS NULL) OR
                  (p_trxn_attribs.PO_Number = FND_API.G_MISS_CHAR)
                )
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (l_channel_attribs.PO_Line_Number_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_REQUIRED)
        AND ( (p_trxn_attribs.PO_Line_Number IS NULL OR (NOT p_update))
            OR (p_trxn_attribs.PO_Line_Number = FND_API.G_MISS_CHAR) )
       )
    THEN
      RETURN FALSE;
    END IF;
    IF ( (l_channel_attribs.PO_Line_Number_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_DISABLED)
        AND NOT ( (p_trxn_attribs.PO_Line_Number IS NULL) OR
                  (p_trxn_attribs.PO_Line_Number = FND_API.G_MISS_CHAR)
                )
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (l_channel_attribs.AddInfo_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_REQUIRED)
        AND ( (p_trxn_attribs.Additional_Info IS NULL OR (NOT p_update))
            OR (p_trxn_attribs.Additional_Info = FND_API.G_MISS_CHAR) )
       )
    THEN
      RETURN FALSE;
    END IF;
    IF ( (l_channel_attribs.AddInfo_Use =
          IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_DISABLED)
        AND NOT ( (p_trxn_attribs.Additional_Info IS NULL) OR
                  (p_trxn_attribs.Additional_Info = FND_API.G_MISS_CHAR)
                )
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (p_trxn_attribs.Order_Id IS NULL AND (NOT p_update)) OR
         (p_trxn_attribs.Order_id = FND_API.G_MISS_CHAR)
       )
    THEN
      RETURN FALSE;
    END IF;

    IF (NOT iby_utility_pvt.Validate_App_Id(p_trxn_attribs.Originating_Application_Id))
    THEN
      RETURN FALSE;
    END IF;

   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;

    RETURN TRUE;
  END Extension_Valid;

  --
  -- USE: Validates the payment channel for the payer;
  --   the given payer or an equivalent must be assigned this payment
  --   channel
  --
  FUNCTION Payer_Channel_Valid
  (p_payer       IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
   p_payer_level IN VARCHAR2,
   p_payer_equiv IN VARCHAR2,
   p_pmt_channel IN iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE
  )
  RETURN BOOLEAN
  IS
    l_channel_instr iby_fndcpt_pmt_chnnls_b.instrument_type%TYPE;

    CURSOR c_trxn_channel
           (ci_payer IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            ci_payer_level IN VARCHAR2,
            ci_payer_equiv IN VARCHAR2,
            ci_channel_code IN iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE)
    IS
      SELECT c.instrument_type
      FROM iby_ext_party_pmt_mthds pm, iby_fndcpt_pmt_chnnls_b c
      WHERE (c.payment_channel_code = ci_channel_code)
        AND (pm.payment_method_code = c.payment_channel_code)
        AND (NVL(pm.inactive_date,SYSDATE-10)<SYSDATE)
        AND (NVL(c.inactive_date,SYSDATE-10)<SYSDATE)
        AND (pm.payment_flow = IBY_FNDCPT_SETUP_PUB.G_PMT_FLOW_FNDCPT)
        AND pm.ext_pmt_party_id IN
          (
            SELECT ext_payer_id
            FROM iby_external_payers_all
            WHERE (payment_function = ci_payer.Payment_Function)
              AND (party_id = ci_payer.Party_Id)
              AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
                   (ci_payer.org_type, ci_payer.org_id,
                   ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
                   ci_payer_level,ci_payer_equiv,org_type,org_id,
                   cust_account_id,acct_site_use_id) = 'T')
          );

     l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Payer_Channel_Valid';
  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;


    -- ENHANCEMENT:
    --   Applicability rules for payer-assigned payment channels
    --   not currently supported

    RETURN TRUE;

    IF (c_trxn_channel%ISOPEN) THEN CLOSE c_trxn_channel; END IF;

    OPEN c_trxn_channel(p_payer,p_payer_level,p_payer_equiv,p_pmt_channel);
    --
    -- should only return the same payment channel and thus only
    -- one instrument type value; storing this saves a later fetch
    --
    FETCH c_trxn_channel INTO l_channel_instr;
    CLOSE c_trxn_channel;

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    IF (l_channel_instr<1) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END Payer_Channel_Valid;

  FUNCTION Channel_InstrAssignment_Appl
  (p_channel  IN iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE)
  RETURN iby_pmt_mthd_attrib_appl.attribute_applicability%TYPE
  IS
    l_assign_appl     iby_pmt_mthd_attrib_appl.attribute_applicability%TYPE;

    CURSOR c_pmt_instr
    (ci_pmt_channel iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE)
    IS
      SELECT attribute_applicability
      FROM iby_pmt_mthd_attrib_appl
      WHERE (payment_flow = 'FUNDS_CAPTURE')
        AND (payment_method_code = ci_pmt_channel)
        AND (attribute_code = 'PAYMENT_INSTRUMENT');

    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.Channel_InstrAssignment_Appl';
  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    IF (c_pmt_instr%ISOPEN) THEN CLOSE c_pmt_instr; END IF;

    OPEN c_pmt_instr(p_channel);
    FETCH c_pmt_instr INTO l_assign_appl;
    CLOSE c_pmt_instr;

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    RETURN l_assign_appl;
  END Channel_InstrAssignment_Appl;

  -- Verifies that the channel is correct for the given
  -- instrument assignment
  --
  FUNCTION InstrAssignment_Channel_Valid
  (p_channel  IN iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE,
   p_assign   IN iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE,
   x_channel_instr OUT NOCOPY iby_fndcpt_pmt_chnnls_b.instrument_type%TYPE
  )
  RETURN BOOLEAN
  IS
    l_assign_id       iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE;
    l_assign_appl     iby_pmt_mthd_attrib_appl.attribute_applicability%TYPE;

    -- cursor def changes for bug 5117954
    CURSOR c_channel_assign
    (ci_channel_code IN iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE,
     ci_assign_id    IN iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE
    )
    IS
      SELECT c.instrument_type, u.instrument_payment_use_id
      FROM iby_fndcpt_pmt_chnnls_b c, iby_pmt_instr_uses_all u
      WHERE (payment_channel_code = ci_channel_code)
        AND (u.instrument_payment_use_id (+) = ci_assign_id)
        AND (c.instrument_type = u.instrument_type(+))
        AND (NVL(payment_flow,IBY_FNDCPT_SETUP_PUB.G_PMT_FLOW_FNDCPT)
               = IBY_FNDCPT_SETUP_PUB.G_PMT_FLOW_FNDCPT);

    l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.InstrAssignment_Channel_Valid';
  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    IF (c_channel_assign%ISOPEN) THEN CLOSE c_channel_assign; END IF;

    OPEN c_channel_assign(p_channel,p_assign);
    FETCH c_channel_assign INTO x_channel_instr, l_assign_id;
    CLOSE c_channel_assign;

    l_assign_appl := Channel_InstrAssignment_Appl(p_channel);

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    IF ((x_channel_instr = IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_MANUAL)
      AND (l_assign_id IS NULL))
    THEN
      RETURN TRUE;
    ELSIF (l_assign_appl = IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_OPTIONAL)
    THEN
      RETURN TRUE;
    ELSIF (NOT l_assign_id IS NULL) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END InstrAssignment_Channel_Valid;

  --
  -- USE: Validates the payment instrument assignment for the given payer
  --
  FUNCTION Payer_InstrAssignment_Valid
  (p_payer            IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
   p_payer_level      IN VARCHAR2,
   p_payer_equiv      IN VARCHAR2,
   p_channel_code     IN iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE,
   p_instr_assign     IN iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE,
   p_new_extension    IN BOOLEAN
  )
  RETURN BOOLEAN
  IS
    l_assign_id       iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE;
    l_instr_req       iby_pmt_mthd_attrib_appl.attribute_applicability%TYPE;
    l_instr_type      iby_fndcpt_payer_assgn_instr_v.instrument_type%TYPE;
    l_instr_id        iby_fndcpt_payer_assgn_instr_v.instrument_id%TYPE;
    l_info_only       iby_fndcpt_payer_assgn_instr_v.card_info_only_flag%TYPE;
    l_single_use      iby_fndcpt_payer_assgn_instr_v.card_single_use_flag%TYPE;
    l_auth_flag       iby_trxn_extensions_v.authorized_flag%TYPE;

    CURSOR c_instr_assigns
    (ci_payer IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
     ci_payer_level IN VARCHAR2,
     ci_payer_equiv IN VARCHAR2,
     ci_instr_assign IN iby_fndcpt_payer_assgn_instr_v.instr_assignment_id%TYPE
    )
    IS
      SELECT instr_assignment_id, instrument_type, instrument_id,
        NVL(card_info_only_flag,'N'), NVL(card_single_use_flag,'N')
      FROM iby_fndcpt_payer_assgn_instr_v
      WHERE
        (instr_assignment_id = ci_instr_assign)
        AND ext_payer_id IN
          (
            SELECT ext_payer_id
            FROM iby_external_payers_all
            WHERE (payment_function = ci_payer.Payment_Function)
              AND (party_id = ci_payer.Party_Id)
              AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
                   (ci_payer.org_type, ci_payer.org_id,
                   ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
                   ci_payer_level,ci_payer_equiv,org_type,org_id,
                   cust_account_id,acct_site_use_id) = 'T')
          );

    CURSOR c_instr_extensions
    (ci_instr_type IN iby_trxn_extensions_v.instrument_type%TYPE,
     ci_instr_id   IN iby_trxn_extensions_v.instrument_id%TYPE
    )
    IS
      SELECT NVL(authorized_flag,'N')
      FROM iby_trxn_extensions_v
      WHERE (instrument_id = ci_instr_id)
        AND (instrument_type = ci_instr_type);

    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.Payer_InstrAssignment_Valid';
  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;


    IF (c_instr_assigns%ISOPEN) THEN CLOSE c_instr_assigns; END IF;
    IF (c_instr_extensions%ISOPEN) THEN CLOSE c_instr_extensions; END IF;

    l_instr_req := Channel_InstrAssignment_Appl(p_channel_code);

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('instrument applicability:=' || l_instr_req,G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;

    IF ((l_instr_req = IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_OPTIONAL)
      AND (p_instr_assign IS NULL))
    THEN
      RETURN TRUE;
    ELSIF (l_instr_req = IBY_FNDCPT_SETUP_PUB.G_CHNNL_ATTRIB_USE_DISABLED) THEN
      RETURN (p_instr_assign IS NULL);
    END IF;

    OPEN c_instr_assigns(p_payer,p_payer_level,p_payer_equiv,p_instr_assign);
    FETCH c_instr_assigns INTO l_assign_id, l_instr_type, l_instr_id,
      l_info_only, l_single_use;
    CLOSE c_instr_assigns;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('fetched assignment id:=' || l_assign_id,
                        G_LEVEL_STATEMENT,l_dbg_mod);
      iby_debug_pub.add('info only:=' || l_info_only,
                        G_LEVEL_STATEMENT,l_dbg_mod);
      iby_debug_pub.add('single use:=' || l_single_use,
                        G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    IF ((l_assign_id IS NULL) OR (l_info_only = 'Y')) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;

    -- cannot use a single-use instrument for a new trxn extension which
    -- has already been used
    IF ((l_single_use = 'Y') AND p_new_extension) THEN
      OPEN c_instr_extensions(l_instr_type,l_instr_id);
      FETCH c_instr_extensions INTO l_auth_flag;
      CLOSE c_instr_extensions;

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

      RETURN (NVL(l_auth_flag,'N') = 'N');
    END IF;
  END Payer_InstrAssignment_Valid;


  FUNCTION Extension_Operation_Exists
  (p_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
  RETURN BOOLEAN
  IS
    l_count   NUMBER;
    l_dbg_mod                  VARCHAR2(100) := G_DEBUG_MODULE || '.Extension_Valid';

    CURSOR c_operation
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
    IS
      SELECT count(1)
      FROM iby_trxn_extensions_v
      WHERE (trxn_extension_id = ci_extension_id)
        AND (authorization_status IN ( 'AUTH_SUCCESS', 'AUTH_PENDING' ));

  BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    IF (c_operation%ISOPEN) THEN CLOSE c_operation; END IF;

    OPEN c_operation(p_extension_id);
    FETCH c_operation INTO l_count;
    IF (c_operation%NOTFOUND) THEN
      l_count := 0;
    END IF;
    CLOSE c_operation;
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;


    RETURN (l_count > 0);
  END Extension_Operation_Exists;

  PROCEDURE Create_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_pmt_channel      IN   VARCHAR2,
            p_instr_assignment IN   NUMBER,
            p_trxn_attribs     IN   TrxnExtension_rec_type,
            x_entity_id        OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Create_Transaction_Extension';
    l_prev_msg_count NUMBER;

    l_payer_level     VARCHAR2(30);
    l_payer_id        iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs   IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;

    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(300);
    l_return_status VARCHAR2(1);
    l_resp_rec      IBY_PAYMENT_ADAPTER_PUB.SecureCVVResp_rec_type;
    l_sec_code      VARCHAR2(10);
    l_encrypted     VARCHAR2(1) := 'N';
    l_segment_id    NUMBER;

    lx_channel_instr  iby_fndcpt_pmt_chnnls_b.instrument_type%TYPE;

    lx_result         IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;
  BEGIN
   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;

   -- test_debug('Create_Transaction_Extension=> Enter..');

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                          debug_level => G_LEVEL_ERROR,
                          module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     iby_debug_pub.add('checking payer context',G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
 --         test_debug('Create_Transaction_Extension=> Checking Payer context..');

    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      -- We do not need to check against the MAX_TANGIBLEID_LEN, because
      -- we now generate the tangibleid using <apps short name>_<trxn_extension_id>
      IF (p_trxn_attribs.Order_Id IS NULL)
        -- OR (LENGTH(Get_Tangible_Id(p_trxn_attribs.Originating_Application_Id,
        --                            p_trxn_attribs.Order_Id,
        --                            p_trxn_attribs.Trxn_Ref_Number1,
        --                            p_trxn_attribs.Trxn_Ref_Number2))
        --      > iby_bill_pkg.G_MAX_TANGIBLEID_LEN
        --    )
      THEN
 --     test_debug('invalid order id');
        IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
  	  iby_debug_pub.add('invalid order id',G_LEVEL_ERROR,l_dbg_mod);
        END IF;
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ATTRIB;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      --  channel must be assigned to an equivalent payer
      --
      IF (NOT Payer_Channel_Valid(p_payer,l_payer_level,
                                  p_payer_equivalency,p_pmt_channel))
      THEN
        x_response.Result_Code := IBY_FNDCPT_SETUP_PUB.G_RC_INVALID_CHNNL;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      --
      -- instrument assignment must be to an instrument of the same type
      -- as the payment channel's
      --
      IF (NOT InstrAssignment_Channel_Valid(p_pmt_channel,p_instr_assignment,
                                            lx_channel_instr))
      THEN
--      test_debug('instrument asssignment not valid for channel');
        IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
 	 iby_debug_pub.add('instrument asssignment not valid for channel',
                           G_LEVEL_ERROR,l_dbg_mod);
        END IF;
        x_response.Result_Code := IBY_FNDCPT_SETUP_PUB.G_RC_INVALID_INSTR_ASSIGN;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      --
      -- instrument must be assigned to an equivalent payer
      --
      IF (NOT Payer_InstrAssignment_Valid(p_payer,l_payer_level,
                                          p_payer_equivalency,
                                          p_pmt_channel,
                                          p_instr_assignment,TRUE))
      THEN
--test_debug('instrument asssignment not valid payer');
        IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
 	  iby_debug_pub.add('instrument asssignment not valid payer',
                            G_LEVEL_ERROR,l_dbg_mod);
        END IF;
        x_response.Result_Code := IBY_FNDCPT_SETUP_PUB.G_RC_INVALID_INSTR_ASSIGN;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      -- validate bank end-dates
      IF (lx_channel_instr = IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_BANKACCT) THEN
null;
      END IF;

      IF (NOT Extension_Valid(p_pmt_channel,p_trxn_attribs,FALSE,FALSE)) THEN
       --test_debug('invalid trxn extension attributes');
        IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add('invalid trxn extension attributes',
                             G_LEVEL_ERROR,l_dbg_mod);
        END IF;
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ATTRIB;
      ELSE

        -- create payer on the fly if necessary
        IF (l_payer_id IS NULL) THEN
          IBY_FNDCPT_SETUP_PUB.Set_Payer_Attributes
          (1.0, FND_API.G_FALSE, FND_API.G_FALSE,
          x_return_status, x_msg_count, x_msg_data,
          p_payer, l_payer_attribs, l_payer_id, lx_result
          );

          IF (lx_result.Result_Code <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS) THEN
           --test_debug('could not set payer attributes');
            IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add('could not set payer attributes',
                                 G_LEVEL_ERROR,l_dbg_mod);
            END IF;
            x_response := lx_result;
            RETURN;
          END IF;
        END IF;

	-- PABP: For IMMEDIATE mode of encryption, make an http callout --
	-- to the ECApp and encrypt the CVV value                       --
	IF (NOT ((p_trxn_attribs.Instrument_Security_Code IS NULL) OR
	        (p_trxn_attribs.Instrument_security_Code = FND_API.G_MISS_CHAR))
           ) THEN
	   -- Security code must be numeric
	   IF('Y' <> IBY_UTILITY_PVT.isNumeric(l_sec_code)) THEN
	      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                iby_debug_pub.add(debug_msg => 'Invalid CVV format',
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
              END IF;
              FND_MESSAGE.SET_NAME('IBY', 'IBY_204900');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
	   END IF;

	   -- Security code should be 3-4 digits
	   IF((LENGTH(l_sec_code) > 4) OR (LENGTH(l_sec_code) < 3) ) THEN
	      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                iby_debug_pub.add(debug_msg => 'Invalid CVV length',
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
              END IF;
              FND_MESSAGE.SET_NAME('IBY', 'IBY_204901');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
	   END IF;
	   IF ('IMMEDIATE' = IBY_CREDITCARD_PKG.Get_CC_Encrypt_Mode()) THEN
	     -- Make an HTTP call out to the middle tier
	     -- test_debug('calling secure_extension..');
	     IBY_PAYMENT_ADAPTER_PUB.OraSecureExtension
	                       (FND_API.G_FALSE,
                                p_trxn_attribs.Instrument_security_Code,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_resp_rec
				);

	     --test_debug('after call to ora secure: respRec: '|| l_resp_rec.Segment_ID);
	     IF (NOT (l_resp_rec.Segment_ID IS NULL)) THEN
               --  test_debug('cvv encryption successful..');
  	       l_segment_id := l_resp_rec.Segment_ID;
	       l_encrypted  := 'Y';
	       l_sec_code   := LPAD('X',LENGTH(p_trxn_attribs.Instrument_Security_Code),'X');
             ELSE
	       -- test_debug('Unknown error occurred while cvv encryption !!');
	       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                     iby_debug_pub.add(debug_msg => 'Unknown error occurred while cvv encryption !!',
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
                  END IF;
                  FND_MESSAGE.SET_NAME('IBY', 'IBY_204902');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
	       END IF;
	       l_segment_id := null;
	       l_encrypted  := 'N';
	       l_sec_code   := null;
	     END IF;

	   ELSE
             l_segment_id := null;
	     l_encrypted  := 'N';
	     l_sec_code   := p_trxn_attribs.Instrument_Security_Code;
           END IF;
   	END IF;
 --	 test_debug('l_segment_id: '|| l_segment_id);
 --   	    test_debug('l_encrypted: '|| l_encrypted);
 --   	    test_debug('l_sec_code: '|| l_sec_code);

        SELECT iby_fndcpt_tx_extensions_s.NEXTVAL INTO x_entity_id FROM DUAL;

	INSERT INTO iby_fndcpt_tx_extensions
          (trxn_extension_id, payment_channel_code, ext_payer_id,
           instr_assignment_id, origin_application_id, instrument_security_code,
           voice_authorization_flag, voice_authorization_date,
           voice_authorization_code, order_id, po_number,
           po_line_number, trxn_ref_number1, trxn_ref_number2, additional_info,
           instr_sec_code_length, encrypted, instr_code_sec_segment_id,
           created_by, creation_date, last_updated_by, last_update_date,
           last_update_login, object_version_number,seq_type_last
          )
          VALUES
          (
           x_entity_id, p_pmt_channel, l_payer_id, p_instr_assignment,
           p_trxn_attribs.Originating_Application_Id,
           l_sec_code,
           p_trxn_attribs.VoiceAuth_Flag,
           p_trxn_attribs.VoiceAuth_Date, p_trxn_attribs.VoiceAuth_Code,
           p_trxn_attribs.Order_Id, p_trxn_attribs.PO_Number,
           p_trxn_attribs.PO_Line_Number,
           p_trxn_attribs.Trxn_Ref_Number1, p_trxn_attribs.Trxn_Ref_Number2,
           p_trxn_attribs.Additional_Info,
           length(p_trxn_attribs.Instrument_Security_Code), l_encrypted,
	   l_segment_id,
           fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
           fnd_global.login_id, 1, p_trxn_attribs.seq_type_last
          );
        END IF;

        x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
      END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;


   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => G_LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => G_LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

	iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
              debug_level => G_LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;
        FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                    p_data   =>  x_msg_data
                                   );
  END Create_Transaction_Extension;


  PROCEDURE Update_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_entity_id        IN   NUMBER,
            p_pmt_channel      IN   VARCHAR2,
            p_instr_assignment IN   NUMBER,
            p_trxn_attribs     IN   TrxnExtension_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Update_Transaction_Extension';
    l_prev_msg_count NUMBER;

    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;

    l_xtension_id  iby_fndcpt_tx_extensions.trxn_extension_id%TYPE;
    l_pmt_channel  iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE;
    l_instr_assign iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE;
    l_order_id     iby_fndcpt_tx_extensions.order_id%TYPE;
    l_trxn_ref1    iby_fndcpt_tx_extensions.trxn_ref_number1%TYPE;
    l_trxn_ref2    iby_fndcpt_tx_extensions.trxn_ref_number2%TYPE;
    l_app_id       iby_fndcpt_tx_extensions.origin_application_id%TYPE;
   -- l_segment_id   iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE;

    lx_channel_instr  iby_fndcpt_pmt_chnnls_b.instrument_type%TYPE;

    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(300);
    l_return_status VARCHAR2(1);
    l_resp_rec      IBY_PAYMENT_ADAPTER_PUB.SecureCVVResp_rec_type;
    l_sec_code      VARCHAR2(10);
    l_encrypted     VARCHAR2(1) := 'N';
    l_segment_id    NUMBER;

    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || l_module;

    CURSOR c_extension
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
     ci_payer        IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
     ci_payer_level  IN VARCHAR2,
     ci_payer_equiv  IN VARCHAR2
    )
    IS
      SELECT
        x.trxn_extension_id, x.payment_channel_code, x.instr_assignment_id,
        x.order_id, x.trxn_ref_number1, x.trxn_ref_number2,
        x.origin_application_id, x.instr_code_sec_segment_id
      FROM iby_fndcpt_tx_extensions x, iby_external_payers_all p
      WHERE (x.ext_payer_id = p.ext_payer_id)
        AND (x.trxn_extension_id = ci_extension_id)
        AND (p.party_id = ci_payer.Party_Id)
        AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
             (ci_payer.org_type, ci_payer.org_id,
             ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
             ci_payer_level,ci_payer_equiv,p.org_type,p.org_id,
             p.cust_account_id,p.acct_site_use_id) = 'T');

  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

  --  test_debug('update_extension called..');

    IF (c_extension%ISOPEN) THEN CLOSE c_extension; END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                            debug_level => G_LEVEL_ERROR,
                            module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('checking payer context',G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      -- verify the transaction id is for a payer equivalent to the
      -- given one
      OPEN c_extension(p_entity_id,p_payer,l_payer_level,p_payer_equivalency);
      FETCH c_extension INTO l_xtension_id, l_pmt_channel, l_instr_assign,
        l_order_id, l_trxn_ref1, l_trxn_ref2, l_app_id, l_segment_id;
      CLOSE c_extension;

      l_order_id := NVL(p_trxn_attribs.Order_Id,l_order_id);
      l_trxn_ref1 := NVL(p_trxn_attribs.Trxn_Ref_Number1,l_trxn_ref1);
      l_trxn_ref2 := NVL(p_trxn_attribs.Trxn_Ref_Number2,l_trxn_ref2);
      l_app_id := NVL(p_trxn_attribs.Originating_Application_Id,l_app_id);

      IF (LENGTH(Get_Tangible_Id(l_app_id,l_order_id,l_trxn_ref1,
                                 l_trxn_ref2))
           > iby_bill_pkg.G_MAX_TANGIBLEID_LEN
         )
      THEN
        IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add('invalid order id',G_LEVEL_ERROR,l_dbg_mod);
        END IF;
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ATTRIB;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      l_pmt_channel := NVL(p_pmt_channel,l_pmt_channel);
      IF (p_instr_assignment = FND_API.G_MISS_NUM) THEN
        l_instr_assign := NULL;
      ELSIF (NOT p_instr_assignment IS NULL) THEN
        l_instr_ASSIGN := p_instr_assignment;
      END IF;

      IF (NOT l_xtension_id IS NULL) THEN
        --
        -- validate the trxn attributes; note that mandatory ones
        -- may be NULL in which case the current values will be used
        --
        IF (NOT Extension_Valid(l_pmt_channel,p_trxn_attribs,TRUE,FALSE)) THEN
          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
 	    iby_debug_pub.add('invalid extension attributes',G_LEVEL_ERROR,l_dbg_mod);
          END IF;
          x_response.Result_Code := G_RC_INVALID_EXTENSION_ATTRIB;
        --
        -- make sure no operations already performed on the extension;
        --
        ELSIF ( Extension_Operation_Exists(p_entity_id) ) THEN
          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add('operations exist for extension; cannot update',
	                      G_LEVEL_ERROR,l_dbg_mod);
          END IF;
          x_response.Result_Code := G_RC_EXTENSION_IMMUTABLE;
        ELSE

          IF (NOT p_pmt_channel IS NULL) OR (NOT p_instr_assignment IS NULL)
          THEN
            IF (NOT Payer_Channel_Valid(p_payer,l_payer_level,
                                        p_payer_equivalency,l_pmt_channel))
            THEN
              IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	        iby_debug_pub.add('invalid payment channel for payer',G_LEVEL_ERROR,l_dbg_mod);
              END IF;
              x_response.Result_Code := IBY_FNDCPT_SETUP_PUB.G_RC_INVALID_CHNNL;
              iby_fndcpt_common_pub.Prepare_Result
              (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,
               x_response);
              RETURN;
            END IF;

            IF (NOT InstrAssignment_Channel_Valid(l_pmt_channel,l_instr_assign,
                                                  lx_channel_instr))
               OR
               (NOT Payer_InstrAssignment_Valid(p_payer,l_payer_level,
                                                p_payer_equivalency,
                                                l_pmt_channel,
                                                l_instr_assign,FALSE))
            THEN
              IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add('invalid payment channel for instrument or payer',
				G_LEVEL_ERROR,l_dbg_mod);
              END IF;
              x_response.Result_Code := IBY_FNDCPT_SETUP_PUB.G_RC_INVALID_INSTR_ASSIGN;
              iby_fndcpt_common_pub.Prepare_Result
              (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,
               x_response);
              RETURN;
            END IF;
          END IF;


        -- PABP: For IMMEDIATE mode of encryption, make an http callout --
	-- to the ECApp and encrypt the CVV value                       --
	IF (NOT ((p_trxn_attribs.Instrument_Security_Code IS NULL) OR
	        (p_trxn_attribs.Instrument_security_Code = FND_API.G_MISS_CHAR))
           ) THEN
	   IF('Y' <> IBY_UTILITY_PVT.isNumeric(l_sec_code)) THEN
	      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                iby_debug_pub.add(debug_msg => 'Invalid CVV format',
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
              END IF;
              FND_MESSAGE.SET_NAME('IBY', 'IBY_204900');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
	   END IF;

	   -- Security code should be 3-4 digits
	   IF((LENGTH(l_sec_code) > 4) OR (LENGTH(l_sec_code) < 3) ) THEN
	      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                iby_debug_pub.add(debug_msg => 'Invalid CVV length',
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
              END IF;
              FND_MESSAGE.SET_NAME('IBY', 'IBY_204901');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
	   END IF;

	   IF ('IMMEDIATE' = IBY_CREDITCARD_PKG.Get_CC_Encrypt_Mode()) THEN
	     -- Make an HTTP call out to the middle tier
	   --  test_debug('calling secure_extension..');
	     IBY_PAYMENT_ADAPTER_PUB.OraSecureExtension
	                       (FND_API.G_FALSE,
                                p_trxn_attribs.Instrument_security_Code,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_resp_rec
				);
	    IF (NOT (l_resp_rec.Segment_ID IS NULL) )
	    THEN

	     --  test_debug('cvv encryption successful..');

	     l_segment_id := l_resp_rec.Segment_ID;
	     l_encrypted  := 'Y';
	     l_sec_code   := LPAD('X',LENGTH(p_trxn_attribs.Instrument_Security_Code),'X');
            ELSE
	       --  test_debug('Unknown error occurred while cvv encryption !!');
 	       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                     iby_debug_pub.add(debug_msg => 'Unknown error occurred while cvv encryption !!',
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
                  END IF;
                  FND_MESSAGE.SET_NAME('IBY', 'IBY_204902');
                  FND_MSG_PUB.Add;
                  RAISE FND_API.G_EXC_ERROR;
	       END IF;
  	       l_segment_id := null;
	       l_encrypted  := 'N';
	       l_sec_code   := null;
	    END IF;

	  ELSE
            l_segment_id := null;
	    l_encrypted  := 'N';
	    l_sec_code   := p_trxn_attribs.Instrument_Security_Code;
          END IF;
   	END IF;
 	-- test_debug('l_segment_id: '|| l_segment_id);
    	--    test_debug('l_encrypted: '|| l_encrypted);
    	--    test_debug('l_sec_code: '|| l_sec_code);


          --
          -- trxn attrib validation ensures that required columns will
          -- not be null'd out; note that GSCC standard File.Sql.48
          -- defines NULL values as missing and G_MISS_XXX values
          -- as an intention to NULL-out
          --
	--  test_debug('p_trxn_attribs.Instrument_Security_Code: '||p_trxn_attribs.Instrument_Security_Code);
--	  test_debug('encrypted: '||);
          UPDATE iby_fndcpt_tx_extensions
          SET
            payment_channel_code = NVL(p_pmt_channel,payment_channel_code),
            instr_assignment_id =
              DECODE(p_instr_assignment, FND_API.G_MISS_NUM,NULL,
                     NULL,instr_assignment_id, p_instr_assignment),
            origin_application_id =
              NVL(p_trxn_attribs.Originating_Application_Id,
                  origin_application_id),
            instrument_security_code =
              DECODE(p_trxn_attribs.Instrument_Security_Code,
                FND_API.G_MISS_CHAR,NULL, NULL,instrument_security_code,
                l_sec_code),
            instr_sec_code_length =
              length(DECODE(p_trxn_attribs.Instrument_Security_Code,
                            FND_API.G_MISS_CHAR,NULL,
                            NULL,instrument_security_code,
                            l_sec_code)
                    ),
            encrypted =
              DECODE(p_trxn_attribs.Instrument_Security_Code,
                FND_API.G_MISS_CHAR,'N', NULL,encrypted, l_encrypted),
	    instr_code_sec_segment_id =
	      NVL(l_segment_id, instr_code_sec_segment_id),
            voice_authorization_flag =
              DECODE(p_trxn_attribs.VoiceAuth_Flag, FND_API.G_MISS_CHAR,NULL,
                NULL,voice_authorization_flag, p_trxn_attribs.VoiceAuth_Flag),
            voice_authorization_date =
              DECODE(p_trxn_attribs.VoiceAuth_Date, FND_API.G_MISS_DATE,NULL,
                NULL,voice_authorization_date, p_trxn_attribs.VoiceAuth_Date),
            voice_authorization_code =
              DECODE(p_trxn_attribs.VoiceAuth_Code, FND_API.G_MISS_CHAR,NULL,
                NULL,voice_authorization_code, p_trxn_attribs.VoiceAuth_Code),
            order_id = NVL(p_trxn_attribs.Order_Id, order_id),
            po_number = DECODE(p_trxn_attribs.PO_Number, FND_API.G_MISS_CHAR,NULL,
              NULL,po_number, p_trxn_attribs.PO_Number),
            po_line_number = DECODE(p_trxn_attribs.PO_Line_Number,
              FND_API.G_MISS_CHAR,NULL, NULL,po_line_number,
              p_trxn_attribs.PO_Line_Number),
            trxn_ref_number1 = DECODE(p_trxn_attribs.Trxn_Ref_Number1,
              FND_API.G_MISS_CHAR,NULL, NULL,trxn_ref_number1,
              p_trxn_attribs.Trxn_Ref_Number1),
            trxn_ref_number2 = DECODE(p_trxn_attribs.Trxn_Ref_Number2,
              FND_API.G_MISS_CHAR,NULL, NULL,trxn_ref_number2,
              p_trxn_attribs.Trxn_Ref_Number2),
            additional_info = DECODE(p_trxn_attribs.Additional_Info,
              FND_API.G_MISS_CHAR,NULL, NULL,additional_info,
              p_trxn_attribs.Additional_Info),
            last_updated_by = fnd_global.user_id,
            last_update_date = SYSDATE,
            last_update_login = fnd_global.login_id,
            object_version_number = object_version_number + 1
          WHERE (trxn_extension_id = p_entity_id);

          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add('updating extension',G_LEVEL_STATEMENT,l_dbg_mod);
	  END IF;
          IF (NOT p_trxn_attribs.Instrument_Security_Code IS NULL) AND
             (p_trxn_attribs.Instrument_Security_Code <> FND_API.G_MISS_CHAR)
          THEN
            DELETE FROM iby_security_segments
            WHERE (sec_segment_id = l_segment_id);
          END IF;

          x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
        END IF;
      ELSE
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ID;
      END IF;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => G_LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => G_LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

	iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
              debug_level => G_LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                    p_data   =>  x_msg_data
                                  );

  END Update_Transaction_Extension;


  PROCEDURE Get_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_entity_id        IN   NUMBER,
            x_trxn_attribs     OUT NOCOPY TrxnExtension_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Transaction_Extension';
    l_prev_msg_count NUMBER;

    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;

    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || l_module;

    CURSOR c_extension
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
    IS
      SELECT
        origin_application_id, RPAD('X',instr_sec_code_length,'X'),
        voice_authorization_flag, voice_authorization_date,
        voice_authorization_code, order_id, po_number,
        po_line_number, trxn_ref_number1, trxn_ref_number2, additional_info
      FROM iby_fndcpt_tx_extensions
      WHERE trxn_extension_id = ci_extension_id;

  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    IF (c_extension%ISOPEN) THEN
      CLOSE c_extension;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => G_LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       iby_debug_pub.add('checking payer contxt',G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      OPEN c_extension(p_entity_id);
      FETCH c_extension INTO
        x_trxn_attribs.Originating_Application_Id,
        x_trxn_attribs.Instrument_Security_Code,
        x_trxn_attribs.VoiceAuth_Flag, x_trxn_attribs.VoiceAuth_Date,
        x_trxn_attribs.VoiceAuth_Code, x_trxn_attribs.Order_Id,
        x_trxn_attribs.PO_Number, x_trxn_attribs.PO_Line_Number,
        x_trxn_attribs.Trxn_Ref_Number1, x_trxn_attribs.Trxn_Ref_Number2,
        x_trxn_attribs.Additional_Info;

        x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
      IF (c_extension%NOTFOUND) THEN
       IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         iby_debug_pub.add('could not find extension',G_LEVEL_ERROR,l_dbg_mod);
       END IF;
       x_response.Result_Code := G_RC_INVALID_EXTENSION_ID;
      ELSE
       x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
      END IF;
      CLOSE c_extension;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;
   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
                            debug_level => G_LEVEL_EXCEPTION,
                            module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
                            debug_level => G_LEVEL_UNEXPECTED,
                            module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
                          debug_level => G_LEVEL_UNEXPECTED,
                          module => G_DEBUG_MODULE || l_module);
        END IF;

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                 );

      IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
                          debug_level => G_LEVEL_EXCEPTION,
                          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
                          debug_level => G_LEVEL_EXCEPTION,
                          module => G_DEBUG_MODULE || l_module);
      END IF;

  END Get_Transaction_Extension;


  PROCEDURE Delete_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_entity_id        IN   NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version   CONSTANT  NUMBER := 1.0;
    l_module        CONSTANT  VARCHAR2(30) := 'Delete_Transaction_Extension';
    l_prev_msg_count NUMBER;

    l_payer_level   VARCHAR2(30);
    l_payer_id      iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;

    l_extension_id  NUMBER;
    l_copy_count    NUMBER;

    l_dbg_mod       VARCHAR2(100) := G_DEBUG_MODULE || l_module;

    CURSOR c_extension
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
     ci_payer        IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
     ci_payer_level  IN VARCHAR2,
     ci_payer_equiv  IN VARCHAR2
    )
    IS
      SELECT x.trxn_extension_id
      FROM iby_fndcpt_tx_extensions x, iby_external_payers_all p,
        iby_pmt_instr_uses_all i
      WHERE (x.trxn_extension_id = ci_extension_id)
        AND (x.instr_assignment_id = i.instrument_payment_use_id(+))
        AND (NVL(x.ext_payer_id,i.ext_pmt_party_id) = p.ext_payer_id)
        AND (p.party_id = ci_payer.Party_Id)
        AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
             (ci_payer.org_type, ci_payer.org_id,
             ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
             ci_payer_level,ci_payer_equiv,p.org_type,p.org_id,
             p.cust_account_id,p.acct_site_use_id) = 'T');

  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    IF (c_extension%ISOPEN) THEN
      CLOSE c_extension;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('checking payer contxt',G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      -- verify the transaction id is for a payer equivalent to the
      -- given one
      OPEN c_extension(p_entity_id,p_payer,l_payer_level,p_payer_equivalency);
      FETCH c_extension INTO l_extension_id;
      IF (NOT c_extension%NOTFOUND) THEN
        -- if trxn extension copied or associated with a payment operation,
        -- cannot be deleted
        l_copy_count := Get_Tx_Extension_Copy_Count(p_entity_id);
        IF ( Extension_Operation_Exists(p_entity_id)
           OR (l_copy_count>0) )
        THEN
          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add('extension copied or operation done; cannot delete',
			      G_LEVEL_ERROR,l_dbg_mod);
          END IF;
          x_response.Result_Code := G_RC_EXTENSION_IMMUTABLE;
        ELSE
          SAVEPOINT Delete_Transaction_Extension;

          -- delete all links to its source extensions
          DELETE iby_fndcpt_tx_xe_copies
          WHERE (copy_trxn_extension_id = p_entity_id);

          DELETE iby_fndcpt_tx_extensions
          WHERE (trxn_extension_id = p_entity_id);
          x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
        END IF;
      ELSE
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ID;
      END IF;
      CLOSE c_extension;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;
    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_Transaction_Extension;
	IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
                            debug_level => G_LEVEL_EXCEPTION,
                            module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_Transaction_Extension;
	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
                             debug_level => G_LEVEL_UNEXPECTED,
                             module => G_DEBUG_MODULE || l_module);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );

      WHEN OTHERS THEN
        ROLLBACK TO Delete_Transaction_Extension;
	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
                            debug_level => G_LEVEL_UNEXPECTED,
                            module => G_DEBUG_MODULE || l_module);
        END IF;

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                 );

      IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
                           debug_level => G_LEVEL_EXCEPTION,
                           module => G_DEBUG_MODULE || l_module);
         iby_debug_pub.add(debug_msg => 'Exit Exception',
                           debug_level => G_LEVEL_EXCEPTION,
                           module => G_DEBUG_MODULE || l_module);
      END IF;

  END Delete_Transaction_Extension;

  PROCEDURE Copy_Transaction_Extension
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_entities         IN   IBY_FNDCPT_COMMON_PUB.Id_tbl_type,
            p_trxn_attribs     IN   TrxnExtension_rec_type,
            x_entity_id        OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version     CONSTANT  NUMBER := 1.0;
    l_module          CONSTANT  VARCHAR2(30) := 'Copy_Transaction_Extension';
    l_prev_msg_count  NUMBER;

    l_payer_level     VARCHAR2(30);
    l_payer_id        iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs   IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;

    l_pmt_channel     iby_fndcpt_tx_extensions.payment_channel_code%TYPE;
    l_instr_assign_id iby_fndcpt_tx_extensions.instr_assignment_id%TYPE;
    lc_pmt_channel    iby_fndcpt_tx_extensions.payment_channel_code%TYPE;
    lc_instr_assign_id iby_fndcpt_tx_extensions.instr_assignment_id%TYPE;
    lc_sec_code       iby_fndcpt_tx_extensions.instrument_security_code%TYPE;
    lc_sec_code_len   iby_fndcpt_tx_extensions.instr_sec_code_length%TYPE;
    lc_va_flag        iby_fndcpt_tx_extensions.voice_authorization_flag%TYPE;
    lc_va_code        iby_fndcpt_tx_extensions.voice_authorization_code%TYPE;
    lc_va_date        iby_fndcpt_tx_extensions.voice_authorization_date%TYPE;
    lc_encrypted      iby_fndcpt_tx_extensions.encrypted%TYPE;
    lc_instr_code_sec_segment_id iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE;

    l_extension       TrxnExtension_rec_type;
    l_x_not_found     BOOLEAN;
    -- whether the new instrument assignment (if passed) was validated
    l_val_instr       BOOLEAN;
    l_consumed_cvv2   BOOLEAN;
    l_copy_count      NUMBER;
    l_persist_auth    VARCHAR2(1);

    lx_result         IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    -- Variables to be used for IMMEDIATE security code
    -- Encryption
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(300);
    l_return_status VARCHAR2(1);
    l_resp_rec      IBY_PAYMENT_ADAPTER_PUB.SecureCVVResp_rec_type;
    l_sec_code      VARCHAR2(10);
    l_encrypted     VARCHAR2(1) := 'N';
    l_segment_id    NUMBER;


    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || l_module;
    lc_PSON           iby_fndcpt_tx_extensions.payment_system_order_number%TYPE;

    -- Bug : 8612180
    -- Changing cursor to get PSON Number with other information.
    CURSOR c_extension
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
     ci_payer        IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
     ci_payer_level  IN VARCHAR2,
     ci_payer_equiv  IN VARCHAR2,
     ci_copy_instr_assign_id IN
       iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE
    )
    IS
      SELECT x.payment_channel_code, x.instr_assignment_id,
        x.instrument_security_code, x.instr_sec_code_length,
        x.voice_authorization_flag, x.voice_authorization_code,
        x.voice_authorization_date, x.encrypted, x.instr_code_sec_segment_id,
	x.payment_system_order_number
      FROM iby_fndcpt_tx_extensions x, iby_pmt_instr_uses_all i,
        iby_pmt_instr_uses_all cpi, iby_external_payers_all p
      WHERE (x.instr_assignment_id = i.instrument_payment_use_id)
        -- can assume this assignment is for funds capture
-- bug 7017004 - use the payer information on the trxn extension
--AND (i.ext_pmt_party_id = p.ext_payer_id)
        AND (x.ext_payer_id = p.ext_payer_id)
        AND (x.trxn_extension_id = ci_extension_id)
        AND (NVL(ci_copy_instr_assign_id,x.instr_assignment_id) = cpi.instrument_payment_use_id)
--
--   payer may change during copy; thus allow the instrument assignment id
--   to change so long as the underlying instrument is the same
--
        AND (
--
--            EXCLUSIVE OR: NULL-out the payer party id if a new
--            instrument assignment id is passed so that the clause does
--            not succeed should the new assignment's instrument id not match
--            put its payer does
--
              ((p.party_id = ci_payer.Party_Id)
              AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
                    (ci_payer.org_type, ci_payer.org_id,
                     ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
                     ci_payer_level,ci_payer_equiv,p.org_type,p.org_id,
                     p.cust_account_id,p.acct_site_use_id) = 'T'
                  )
              AND (ci_copy_instr_assign_id IS NULL)
              )
            OR
              (
                (i.instrument_type = cpi.instrument_type)
                AND (i.instrument_id = cpi.instrument_id)
                AND (NOT ci_copy_instr_assign_id IS NULL)
              )
            )
      ORDER BY x.creation_date DESC;

    CURSOR c_auths
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
    IS
      SELECT NVL(sp.settle_require_vrfy_flag,'Y')
      FROM iby_trxn_ext_auths_v x, iby_fndcpt_sys_eft_pf_b sp,
        iby_fndcpt_user_eft_pf_b up
      WHERE (x.trxn_extension_id = ci_extension_id)
        AND (DECODE(x.instrument_type,
                    IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_BANKACCT,x.process_profile_code,
                    NULL) = up.user_eft_profile_code(+)
            )
        AND (up.sys_eft_profile_code = sp.sys_eft_profile_code(+));

  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

    IF (c_extension%ISOPEN) THEN CLOSE c_extension; END IF;
    IF (c_auths%ISOPEN) THEN CLOSE c_auths; END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                           debug_level => G_LEVEL_ERROR,
                           module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    SAVEPOINT Copy_Txn_Extension_Merge;

    l_extension := p_trxn_attribs;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('checking payer context',G_LEVEL_STATEMENT,l_dbg_mod);
      iby_debug_pub.add('party id =' || p_payer.Party_Id,G_LEVEL_STATEMENT,l_dbg_mod);
      iby_debug_pub.add('account id =' || p_payer.Cust_Account_Id,G_LEVEL_STATEMENT,l_dbg_mod);
      iby_debug_pub.add('account site use id =' || p_payer.Account_Site_Id,G_LEVEL_STATEMENT,l_dbg_mod);
      iby_debug_pub.add('org id =' || p_payer.Org_Id,G_LEVEL_STATEMENT,l_dbg_mod);
      iby_debug_pub.add('org type =' || p_payer.Org_Type,G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;

    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      IF (l_extension.Order_Id IS NULL)
         OR (LENGTH(Get_Tangible_Id(l_extension.Originating_Application_Id,
                                    l_extension.Order_Id,
                                    l_extension.Trxn_Ref_Number1,
                                    l_extension.Trxn_Ref_Number2))
              > iby_bill_pkg.G_MAX_TANGIBLEID_LEN
            )
      THEN
        IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          iby_debug_pub.add('order id invalid',G_LEVEL_ERROR,l_dbg_mod);
	END IF;
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ATTRIB;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
        l_payer_level,l_payer_id,l_payer_attribs);

      -- create external payer if necessary
      IF (l_payer_id IS NULL) THEN
        IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          iby_debug_pub.add('setting payer attribs',G_LEVEL_STATEMENT,l_dbg_mod);
	END IF;
        IBY_FNDCPT_SETUP_PUB.Set_Payer_Attributes
        (1.0, FND_API.G_FALSE, FND_API.G_FALSE,
        x_return_status, x_msg_count, x_msg_data,
        p_payer, l_payer_attribs, l_payer_id, lx_result
        );

        IF (lx_result.Result_Code <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS) THEN
          x_response := lx_result;
          RETURN;
        END IF;
      END IF;

      l_val_instr := (NOT p_trxn_attribs.Copy_Instr_Assign_Id IS NULL);

      FOR i IN p_entities.FIRST..p_entities.LAST  LOOP
        IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add('trxn entity id:=' || p_entities(i),
                             G_LEVEL_STATEMENT,l_dbg_mod);
           iby_debug_pub.add('copy instr assignment:=' || p_trxn_attribs.Copy_Instr_Assign_Id,
                             G_LEVEL_STATEMENT,l_dbg_mod);
        END IF;

        OPEN c_extension(p_entities(i), p_payer, l_payer_level,
                         p_payer_equivalency,
                         p_trxn_attribs.Copy_Instr_Assign_Id);
        FETCH c_extension
        INTO lc_pmt_channel, lc_instr_assign_id,
          lc_sec_code, lc_sec_code_len,
          lc_va_flag, lc_va_code, lc_va_date, lc_encrypted,
	  lc_instr_code_sec_segment_id, lc_PSON;
        l_x_not_found := c_extension%NOTFOUND;
        CLOSE c_extension;

        l_copy_count := Get_Tx_Extension_Copy_Count(p_entities(i));

	-- Bug 8612180
	-- In split shipment scenario we will not inherit the PSON number
	-- Nulling out the lc_PSON for this case.
        IF (l_copy_count>0) THEN
            lc_PSON := NULL;
	END IF;
       -- End of 8612180


        l_pmt_channel := NVL(l_pmt_channel,lc_pmt_channel);
        l_instr_assign_id := NVL(l_instr_assign_id,lc_instr_assign_id);

        -- validate new instrument assignment here as payment channel
        -- is required

        IF (l_val_instr) THEN
          IF (NOT Payer_InstrAssignment_Valid(p_payer,l_payer_level,
                                              p_payer_equivalency,
                                              l_pmt_channel,
                                              p_trxn_attribs.Copy_Instr_Assign_Id,
                                              TRUE
                                             )
             )
          THEN
            IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add('payer instr assignment invalid ' ||
                               p_trxn_attribs.Copy_Instr_Assign_Id ||
                              ' for channel ' || l_pmt_channel,
                               G_LEVEL_ERROR,l_dbg_mod);
	      END IF;
            x_response.Result_Code :=
              IBY_FNDCPT_SETUP_PUB.G_RC_INVALID_INSTR_ASSIGN;
            iby_fndcpt_common_pub.Prepare_Result
            (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
            RETURN;
          END IF;
          l_instr_assign_id := p_trxn_attribs.Copy_Instr_Assign_Id;
          l_val_instr := FALSE;
        END IF;
        IF (l_x_not_found) THEN
          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          iby_debug_pub.add('extension invalid for payer, or non-existant',
                            G_LEVEL_ERROR,l_dbg_mod);
          END IF;
          x_response.Result_Code := G_RC_INVALID_EXTENSION_ID;
          iby_fndcpt_common_pub.Prepare_Result
          (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
          RETURN;
        ELSIF ( (l_pmt_channel<>lc_pmt_channel)
-- instr assignment may change;
--OR (l_instr_assign_id<>lc_instr_assign_id)
              )
        THEN
          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add('incompatible pmt chanenel ' || l_pmt_channel,
                            G_LEVEL_ERROR,l_dbg_mod);
          END IF;
          x_response.Result_Code := G_RC_INCMP_EXTENSION_GROUP;
          iby_fndcpt_common_pub.Prepare_Result
          (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
          RETURN;
/*
        ELSIF (l_copy_count>0) THEN
          x_response.Result_Code := G_RC_DUP_EXTENSION_COPY;
          iby_fndcpt_common_pub.Prepare_Result
          (x_return_status,x_msg_count,x_msg_data,x_response);
          RETURN;
*/
        ELSE
          -- inherit from the first extension with non-NULL values
          l_extension.Instrument_Security_Code :=
            NVL(l_extension.Instrument_Security_Code,lc_sec_code);
	  -- We don't expect the upstream product to pass a segment id.
	  -- So, we will inherit the segment id if the security code is passed
	  -- as NULL or 'XXX' or 'XXXX'
	  IF ((l_extension.Instrument_Security_Code IS NULL) OR
	     (l_extension.Instrument_Security_Code = 'XXX') OR
	     (l_extension.Instrument_Security_Code = 'XXXX'))
          THEN
	    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add('l_extension.Instrument_Security_Code is NULL, XXX or XXXX. Inherit the segmentid.',
                                           G_LEVEL_STATEMENT,l_dbg_mod);
	    END IF;
            l_segment_id := lc_instr_code_sec_segment_id;
	  ELSE
            -- New CVV value passed. Need to encrypt it if encryption
	    -- is turned ON
            iby_debug_pub.add('New CVV passed for the copied extension.',
                                           G_LEVEL_ERROR,l_dbg_mod);
	    IF ('IMMEDIATE' = IBY_CREDITCARD_PKG.Get_CC_Encrypt_Mode()) THEN
	      IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        iby_debug_pub.add('Encryption is IMMEDIATE.',G_LEVEL_STATEMENT,l_dbg_mod);
	      END IF;
              -- Make an HTTP call out to the middle tier
              IBY_PAYMENT_ADAPTER_PUB.OraSecureExtension
                               (FND_API.G_FALSE,
                                l_extension.Instrument_security_Code,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_resp_rec
                                );

              lc_sec_code_len := length(p_trxn_attribs.Instrument_Security_Code);
              IF (NOT (l_resp_rec.Segment_ID IS NULL)) THEN
                IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		  iby_debug_pub.add('encryption successful!!',
                                    G_LEVEL_STATEMENT,l_dbg_mod);
                END IF;
                l_segment_id := l_resp_rec.Segment_ID;
                lc_encrypted  := 'Y';
                l_extension.Instrument_Security_Code :=
		              LPAD('X',LENGTH(p_trxn_attribs.Instrument_Security_Code),'X');
              ELSE
                IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
		   iby_debug_pub.add('Unknown error occurred while cvv encryption !!',
                                           G_LEVEL_ERROR,l_dbg_mod);
                END IF;
                l_segment_id := null;
                lc_encrypted  := 'N';
                l_sec_code   := null;
              END IF;
            ELSE
	      IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        iby_debug_pub.add('Encryption mode is not IMMEDIATE. Clear text CVV would be stored',
                                           G_LEVEL_STATEMENT,l_dbg_mod);
              END IF;
              l_segment_id := null;
              l_encrypted  := 'N';
              l_sec_code   := p_trxn_attribs.Instrument_Security_Code;
            END IF;
          END IF;

	   l_extension.VoiceAuth_Flag :=
            NVL(l_extension.VoiceAuth_Flag,lc_va_flag);
          l_extension.VoiceAuth_Code :=
            NVL(l_extension.VoiceAuth_Code,lc_va_code);
          l_extension.VoiceAuth_Date :=
            NVL(l_extension.VoiceAuth_Date,lc_va_date);

          -- new security codes always passed as clear-text; old
          -- ones will have the extensions existing encryptions state
          --
          --IF (NOT p_trxn_attribs.Instrument_Security_Code IS NULL) THEN
          --  lc_encrypted := 'N';
          --  lc_sec_code_len := length(p_trxn_attribs.Instrument_Security_Code);
          --END IF;
        END IF;

        IF (p_entities.count > 1) THEN
         l_persist_auth := NULL;

         OPEN c_auths(p_entities(i));
         FETCH c_auths INTO l_persist_auth;
         CLOSE c_auths;

         IF (l_persist_auth = 'Y') THEN
	 IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          iby_debug_pub.add('persistent auth; cannot do 1-to-many copy',
                             G_LEVEL_ERROR,l_dbg_mod);
          END IF;
          x_response.Result_Code := G_RC_INCMP_EXTENSION_GROUP;
          iby_fndcpt_common_pub.Prepare_Result
          (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
          RETURN;
         END IF;
        END IF;

      END LOOP;

      IF (NVL(lc_sec_code_len,0)>0)
         AND (l_extension.Instrument_Security_Code IS NULL)
      THEN
        l_consumed_cvv2 := TRUE;
      ELSE
        l_consumed_cvv2 := FALSE;
      END IF;

      IF (NOT Extension_Valid(l_pmt_channel,l_extension,FALSE,
                              l_consumed_cvv2)) THEN
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ATTRIB;
      ELSE
        SELECT iby_fndcpt_tx_extensions_s.NEXTVAL INTO x_entity_id FROM DUAL;
	-- Bug: 8612180
	-- Insert PSON Number from parent record when copying transaction extension.
        INSERT INTO iby_fndcpt_tx_extensions
        (trxn_extension_id, payment_channel_code,
         ext_payer_id, instr_assignment_id,
         origin_application_id, instrument_security_code,
         instr_sec_code_length, encrypted, instr_code_sec_segment_id,
         voice_authorization_flag, voice_authorization_date,
         voice_authorization_code, order_id, po_number,
         po_line_number, trxn_ref_number1, trxn_ref_number2, additional_info,
         created_by, creation_date, last_updated_by, last_update_date,
         last_update_login, object_version_number,payment_system_order_number,
	 seq_type_last
        )
        VALUES
        (
         x_entity_id, l_pmt_channel, l_payer_id, l_instr_assign_id,
         l_extension.Originating_Application_Id,
         l_extension.Instrument_Security_Code,
         lc_sec_code_len, lc_encrypted, l_segment_id,
         l_extension.VoiceAuth_Flag,
         l_extension.VoiceAuth_Date, l_extension.VoiceAuth_Code,
         l_extension.Order_Id, l_extension.PO_Number,
         l_extension.PO_Line_Number,
         l_extension.Trxn_Ref_Number1, l_extension.Trxn_Ref_Number2,
         l_extension.Additional_Info,
         fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
         fnd_global.login_id, 1, lc_PSON,
	 p_trxn_attribs.seq_type_last
        );
	--End of Bug : 8612180

        FOR i IN p_entities.FIRST..p_entities.LAST  LOOP

          -- associate the merged copy with all its sources
          INSERT INTO iby_fndcpt_tx_xe_copies
          (source_trxn_extension_id, copy_trxn_extension_id,
           created_by, creation_date, last_updated_by, last_update_date,
           last_update_login, object_version_number
          )
          VALUES
          (p_entities(i), x_entity_id,
           fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
           fnd_global.login_id, 1
          );

          -- only the first copy receives an operations for the extension
          IF (l_copy_count < 1) THEN
            -- note this assumes all operations have already been
            -- propogated to the immediate copy source from the extensions
            -- which THEY copied
            --
            INSERT INTO iby_fndcpt_tx_operations
            (trxn_extension_id, transactionid,
             created_by, creation_date, last_updated_by, last_update_date,
             last_update_login, object_version_number
            )
            -- instrument may change during copy
            SELECT
             x_entity_id, transactionid,
             fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
             fnd_global.login_id, 1
            FROM iby_fndcpt_tx_operations
            WHERE trxn_extension_id = p_entities(i);
          END IF;
        END LOOP;

        x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
      END IF;

    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;
    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Copy_Txn_Extension_Merge;
	IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	 iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
                           debug_level => G_LEVEL_ERROR,
                           module => G_DEBUG_MODULE || l_module);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Copy_Txn_Extension_Merge;
	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
                            debug_level => G_LEVEL_UNEXPECTED,
                            module => G_DEBUG_MODULE || l_module);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );

      WHEN OTHERS THEN
        ROLLBACK TO Copy_Txn_Extension_Merge;

	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
                          debug_level => G_LEVEL_UNEXPECTED,
                          module => G_DEBUG_MODULE || l_module);
        END IF;

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                 );

      IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
                        debug_level => G_LEVEL_STATEMENT,
                        module => G_DEBUG_MODULE || l_module);
      iby_debug_pub.add(debug_msg => 'Exit Exception',
                        debug_level => G_LEVEL_STATEMENT,
                        module => G_DEBUG_MODULE || l_module);
       END IF;

  END Copy_Transaction_Extension;

  --
  -- This is a Private utility procedure.
  -- Used to securely wipe out the CVV after
  -- the first authorization.
  -- As the PABP guidelines, a secure wipeout of data could be essentially achieved
  -- by updating the column with a randomly generated value, issuing a commit, and
  -- then updating the value with NULL (or deleting the row) and then issuing another
  -- commit.
  -- We achieve this through the following autonomous transaction block
  --
  PROCEDURE Secure_Wipe_Segment
            (
	      p_segment_id IN iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE
	    )
  IS PRAGMA AUTONOMOUS_TRANSACTION;
   l_random_val NUMBER;

   l_module       CONSTANT  VARCHAR2(30) := 'Secure_Wipe_Segment';
   l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;
  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;
    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('p_segment_id = '|| p_segment_id,G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    IF (p_segment_id IS NOT NULL) THEN
      SELECT trunc(DBMS_RANDOM.VALUE(1000,9999)) INTO l_random_val FROM dual;

      IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         iby_debug_pub.add('Updating the security code with random value.',
                           G_LEVEL_STATEMENT,l_dbg_mod);
      END IF;
      UPDATE iby_security_segments
      SET segment_cipher_text = RAWTOHEX(fnd_crypto.randombytes(32))
      WHERE sec_segment_id = p_segment_id;

      COMMIT;

      UPDATE iby_security_segments
      SET segment_cipher_text = null
      WHERE sec_segment_id = p_segment_id;

      -- DELETE iby_security_segments
      -- WHERE sec_segment_id = p_segment_id;

      COMMIT;
    END IF;
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

  END Secure_Wipe_Segment;

  PROCEDURE Create_Authorization
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_payee            IN   PayeeContext_rec_type,
            p_trxn_entity_id   IN   NUMBER,
            p_auth_attribs     IN   AuthAttribs_rec_type,
            p_amount           IN   Amount_rec_type,
            x_auth_result      OUT NOCOPY AuthResult_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Create_Authorization';
    l_prev_msg_count NUMBER;

    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;

    l_copy_count    NUMBER;
    l_auth_flag     iby_trxn_extensions_v.authorized_flag%TYPE;
    l_instr_auth_flag iby_trxn_extensions_v.authorized_flag%TYPE;
    l_single_use    iby_fndcpt_payer_assgn_instr_v.card_single_use_flag%TYPE;

    l_ecapp_id      NUMBER;
    l_app_short_name fnd_application.application_short_name%TYPE;
    l_order_id      iby_fndcpt_tx_extensions.order_id%TYPE;
    l_trxn_ref1     iby_fndcpt_tx_extensions.trxn_ref_number1%TYPE;
    l_trxn_ref2     iby_fndcpt_tx_extensions.trxn_ref_number2%TYPE;
    l_encrypted     iby_fndcpt_tx_extensions.encrypted%TYPE;
    l_code_segment_id iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE;
    l_sec_code_len  iby_fndcpt_tx_extensions.instr_sec_code_length%TYPE;
    l_payee         IBY_PAYMENT_ADAPTER_PUB.Payee_rec_type;
    l_payer         IBY_PAYMENT_ADAPTER_PUB.Payer_rec_type;
    l_tangible      IBY_PAYMENT_ADAPTER_PUB.Tangible_rec_type;
    l_pmt_instr     IBY_PAYMENT_ADAPTER_PUB.PmtInstr_rec_type;
    l_pmt_trxn      IBY_PAYMENT_ADAPTER_PUB.PmtReqTrxn_rec_type;
    l_riskinfo      IBY_PAYMENT_ADAPTER_PUB.RiskInfo_rec_type;
    l_reqresp       IBY_PAYMENT_ADAPTER_PUB.ReqResp_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(300);
    l_fail_msg      VARCHAR2(500);
    l_op_count      NUMBER;
    l_rec_mth_id    NUMBER;

    l_tmp_segmdnt_id iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE;
    l_ext_not_found BOOLEAN;

    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

    CURSOR c_extension
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
     ci_payer        IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
     ci_payer_level  IN VARCHAR2,
     ci_payer_equiv  IN VARCHAR2
    )
    IS
      SELECT NVL(i.instrument_type,pc.instrument_type),
        NVL(i.instrument_id,0),
        x.origin_application_id, a.application_short_name,
        x.order_id, x.trxn_ref_number1, x.trxn_ref_number2,
        x.instrument_security_code, x.instr_code_sec_segment_id,
	x.instr_sec_code_length, x.encrypted,
        x.po_number, x.voice_authorization_flag, x.voice_authorization_code,
        x.voice_authorization_date, i.card_single_use_flag,
        NVL(x.instr_assignment_id,0), x.payment_channel_code
      FROM iby_fndcpt_tx_extensions x, iby_fndcpt_payer_assgn_instr_v i,
        iby_external_payers_all p, fnd_application a,
        iby_fndcpt_pmt_chnnls_b pc
      WHERE (x.instr_assignment_id = i.instr_assignment_id(+))
        AND (x.payment_channel_code = pc.payment_channel_code)
        AND (x.origin_application_id = a.application_id)
        -- can assume this assignment is for funds capture
        AND (x.ext_payer_id = p.ext_payer_id)
        AND (x.trxn_extension_id = ci_extension_id)
        AND (p.party_id = ci_payer.Party_Id)
        AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
             (ci_payer.org_type, ci_payer.org_id,
             ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
             ci_payer_level,ci_payer_equiv,p.org_type,p.org_id,
             p.cust_account_id,p.acct_site_use_id) = 'T');

     CURSOR c_auth
     (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
     IS
       SELECT authorized_flag
       FROM iby_trxn_extensions_v
       WHERE (trxn_extension_id = ci_extension_id);

    CURSOR c_instr_extensions
    (ci_instr_type IN iby_trxn_extensions_v.instrument_type%TYPE,
     ci_instr_id   IN iby_trxn_extensions_v.instrument_id%TYPE,
     ci_trxn_x_id  IN iby_trxn_extensions_v.trxn_extension_id%TYPE
    )
    IS
      SELECT NVL(authorized_flag,'N')
      FROM iby_trxn_extensions_v
      WHERE (instrument_id = ci_instr_id)
        AND (instrument_type = ci_instr_type)
        AND (trxn_extension_id <> ci_trxn_x_id);

    CURSOR c_operation_count
    (ci_trxn_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
     ci_trxn_id           IN iby_trxn_summaries_all.transactionid%TYPE)
    IS
      SELECT count(1)
      FROM iby_fndcpt_tx_operations o
      WHERE o.transactionid = ci_trxn_id
        AND o.trxn_extension_id = ci_trxn_extension_id;

    CURSOR c_source_extns
    (
     ci_trxn_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE
    )
    IS
      SELECT cp.source_trxn_extension_id, ex.instr_code_sec_segment_id, ex.instrument_security_code
      FROM iby_fndcpt_tx_xe_copies cp, iby_fndcpt_tx_extensions ex
      WHERE cp.source_trxn_extension_id = ex.trxn_extension_id
      START WITH cp.copy_trxn_extension_id = ci_trxn_extension_id
      CONNECT BY PRIOR source_trxn_extension_id = copy_trxn_extension_id;

  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_module);
     END IF;

    IF (c_extension%ISOPEN) THEN CLOSE c_extension; END IF;
    IF (c_auth%ISOPEN) THEN CLOSE c_auth; END IF;
    IF (c_instr_extensions%ISOPEN) THEN CLOSE c_instr_extensions; END IF;
    IF (c_operation_count%ISOPEN) THEN CLOSE c_operation_count; END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                          debug_level => G_LEVEL_ERROR,
                          module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('checking payer context',G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      -- verify transaction entity is for a payer equivalent to the
      -- given one
      OPEN c_extension(p_trxn_entity_id,p_payer,l_payer_level,p_payer_equivalency);
      FETCH c_extension INTO l_pmt_instr.PmtInstr_Type,
            l_pmt_instr.PmtInstr_Id, l_ecapp_id, l_app_short_name,
            l_order_id, l_trxn_ref1, l_trxn_ref2,
            l_pmt_trxn.CVV2, l_code_segment_id,
	    l_sec_code_len, l_encrypted,
            l_pmt_trxn.PONum, l_pmt_trxn.VoiceAuthFlag,
            l_pmt_trxn.AuthCode, l_pmt_trxn.DateOfVoiceAuthorization,
            l_single_use,
            l_pmt_instr.Pmtinstr_assignment_id,
            l_pmt_trxn.payment_channel_code;
      l_ext_not_found := c_extension%NOTFOUND;
      CLOSE c_extension;

    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      iby_debug_pub.add('channel code:=' || l_pmt_trxn.payment_channel_code,
                        G_LEVEL_STATEMENT,l_dbg_mod);
      iby_debug_pub.add('instrument type:=' || l_pmt_instr.pmtinstr_type,
                        G_LEVEL_STATEMENT,l_dbg_mod);
    END IF;
      IF (NOT l_ext_not_found) THEN

        -- map the records
        l_payee.Payee_Id := Get_Internal_Payee(p_payee);
        -- create on the fly??
        l_payer.Party_Id := p_payer.Party_Id;

        l_copy_count := Get_Tx_Extension_Copy_Count(p_trxn_entity_id);

        IF (l_payee.Payee_Id IS NULL) THEN
          x_response.Result_Code := G_RC_INVALID_PAYEE;

          iby_fndcpt_common_pub.Prepare_Result
          (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
          RETURN;
        -- cannot do operations on a trxn entity already copied
        ELSIF (l_copy_count>0) THEN
          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             iby_debug_pub.add('extension has been copied ' || l_copy_count
                               || ' times; cannot auth',G_LEVEL_ERROR,l_dbg_mod);
          END IF;
          x_response.Result_Code := G_RC_EXTENSION_IMMUTABLE;
          iby_fndcpt_common_pub.Prepare_Result
          (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
          RETURN;
        END IF;

        --Changing the function here to generate new tangible_id
	l_tangible.Tangible_Id :=
	    Get_Tangible_Id(l_app_short_name,p_trxn_entity_id);
        --l_tangible.Tangible_Id :=
        --  Get_Tangible_Id(l_app_short_name,l_order_id,l_trxn_ref1,l_trxn_ref2);

        IF (l_pmt_instr.PmtInstr_Type =
            IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_BANKACCT)
        THEN
          l_pmt_trxn.Auth_Type := IBY_PAYMENT_ADAPTER_PUB.G_AUTHTYPE_VERIFY;
        ELSE
          l_pmt_trxn.Auth_Type := IBY_PAYMENT_ADAPTER_PUB.G_AUTHTYPE_AUTHONLY;
        END IF;

        l_tangible.Tangible_Amount := p_amount.Value;
        l_tangible.Currency_Code := p_amount.Currency_Code;
        l_tangible.Memo := p_auth_attribs.Memo;
        l_tangible.OrderMedium := p_auth_attribs.Order_Medium;

        l_pmt_trxn.Org_Id := p_payee.Org_Id;
	l_pmt_trxn.Int_Bank_Country_Code := p_payee.Int_Bank_Country_Code;
        l_pmt_trxn.TaxAmount := p_auth_attribs.Tax_Amount.Value;
        l_pmt_trxn.ShipFromZip := p_auth_attribs.ShipFrom_PostalCode;
        l_pmt_trxn.ShipToZip := p_auth_attribs.ShipTo_PostalCode;
        l_pmt_trxn.Payment_Factor_Flag := p_auth_attribs.Payment_Factor_Flag;

        -- ciphertext; get clear-text value in the engine
        IF (l_encrypted = 'Y') THEN
          l_pmt_trxn.CVV2 := NULL;
          l_pmt_trxn.Trxn_Extension_Id := p_trxn_entity_id;
	  l_pmt_trxn.CVV2_Segment_id := l_code_segment_id;
	  l_pmt_trxn.CVV2_Length := l_sec_code_len;
        END IF;

        -- cannot use a single use instrument which already has
        -- an authorization
        IF (l_single_use = 'Y') THEN
          OPEN c_instr_extensions(l_pmt_instr.PmtInstr_Type,
                                  l_pmt_instr.PmtInstr_Id, p_trxn_entity_id);
          FETCH c_instr_extensions INTO l_instr_auth_flag;
          CLOSE c_instr_extensions;
          IF (NVL(l_instr_auth_flag,'N') = 'Y') THEN
          IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            iby_debug_pub.add('single use instrument cannot be reused',G_LEVEL_ERROR,l_dbg_mod);
          END IF;
            x_response.Result_Code := IBY_FNDCPT_SETUP_PUB.G_RC_INVALID_INSTRUMENT;
            iby_fndcpt_common_pub.Prepare_Result
            (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
            RETURN;
          END IF;
        END IF;

        OPEN c_auth(p_trxn_entity_id);
        FETCH c_auth INTO l_auth_flag;
        IF (l_auth_flag = 'Y') THEN
	  IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             iby_debug_pub.add('extension already authorized',G_LEVEL_ERROR,l_dbg_mod);
          END IF;
          x_response.Result_Code := G_RC_DUPLICATE_AUTHORIZATION;
        ELSE
          IF (p_auth_attribs.RiskEval_Enable_Flag = 'Y') THEN
            l_pmt_trxn.AnalyzeRisk := 'TRUE';
          END IF;

       --  Bug# 7707005. PAYEE ROUTING RULES BASED ON RECEIPT METHOD QUALIFIER ARE NOT WORKING.

	 l_rec_mth_id := p_auth_attribs.Receipt_Method_Id;
         IF (l_rec_mth_id IS NULL)
	 THEN
	  Begin
	    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add('fetching the rec method id from AR',G_LEVEL_STATEMENT,l_dbg_mod);
	    END IF;
	    select RECEIPT_METHOD_ID
	      into l_rec_mth_id
	      from ar_cash_receipts_all
	     where payment_trxn_extension_id = p_trxn_entity_id;
            IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add('fetched method id '||l_rec_mth_id ,G_LEVEL_STATEMENT,l_dbg_mod);
	    END IF;
           Exception
	     When Others then
	      l_rec_mth_id := NULL;
          End;
	 END IF;

        -- After fetching the receipt method id,populating in p_pmtreqtrxn_rec and sending in orapmtreq

	  l_pmt_trxn.Receipt_Method_Id := l_rec_mth_id;

          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    	    iby_debug_pub.add('send auth',G_LEVEL_STATEMENT,l_dbg_mod);
          END IF;
          IBY_PAYMENT_ADAPTER_PUB.OraPmtReq
          (1.0,
           p_init_msg_list,
           FND_API.G_FALSE,
           FND_API.G_VALID_LEVEL_FULL,
           l_ecapp_id,
           l_payee,
           l_payer,
           l_pmt_instr,
           l_tangible,
           l_pmt_trxn,
           l_return_status,
           l_msg_count,
           l_msg_data,
           l_reqresp
          );

          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          iby_debug_pub.add('status :=' || l_return_status,
                            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('auth status :=' ||
            to_char(l_reqresp.Response.Status),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('auth engine code :=' ||
            to_char(l_reqresp.Response.ErrCode),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('auth engine msg :=' ||
            to_char(l_reqresp.Response.ErrMessage),
            G_LEVEL_STATEMENT,l_dbg_mod);

          iby_debug_pub.add('payment system code :=' ||
            to_char(l_reqresp.BEPErrCode),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('payment system msg :=' ||
            to_char(l_reqresp.BEPErrMessage),
            G_LEVEL_STATEMENT,l_dbg_mod);

          iby_debug_pub.add('trxn id :=' ||
            to_char(l_reqresp.Trxn_ID),
            G_LEVEL_STATEMENT,l_dbg_mod);
          END IF;
          IF (p_auth_attribs.RiskEval_Enable_Flag = 'Y') THEN
            x_auth_result.Risk_Result.Risk_Score :=
              l_reqresp.RiskResponse.Risk_Score;
            x_auth_result.Risk_Result.Risk_Threshold_Val :=
              l_reqresp.RiskResponse.Risk_Threshold_Val;
            IF (l_reqresp.RiskResponse.Risky_Flag = 'YES') THEN
              x_auth_result.Risk_Result.Risky_Flag := 'Y';
            ELSE
              x_auth_result.Risk_Result.Risky_Flag := 'N';
            END IF;
          END IF;

          -- consume the security code
          UPDATE iby_fndcpt_tx_extensions
          SET instrument_security_code = NULL,
          --instr_sec_code_length = NULL,
            encrypted = 'N',
            last_updated_by = fnd_global.user_id,
            last_update_date = SYSDATE,
            last_update_login = fnd_global.login_id,
            object_version_number = object_version_number + 1
          WHERE trxn_extension_id = p_trxn_entity_id;

	  UPDATE iby_fndcpt_tx_extensions
	  SET instrument_security_code = NULL,
          --instr_sec_code_length = NULL,
            encrypted = 'N',
            last_updated_by = fnd_global.user_id,
            last_update_date = SYSDATE,
            last_update_login = fnd_global.login_id,
            object_version_number = object_version_number + 1
	  WHERE trxn_extension_id IN
	           (SELECT source_trxn_extension_id
                    FROM iby_fndcpt_tx_xe_copies
                    START WITH copy_trxn_extension_id = p_trxn_entity_id
                    CONNECT BY PRIOR source_trxn_extension_id = copy_trxn_extension_id
		   );

          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add('No. of source extensions updated= :'||SQL%ROWCOUNT,
                          G_LEVEL_STATEMENT,l_dbg_mod);
          END IF;

	  -- As per PABP guidelines, the cvv value should be consumed
	  -- securely. i.e, first update with a random value, do a commit
	  -- then update with null and issue another commit.
	  -- This is handled through the below procedure call.
          IF (l_code_segment_id IS NOT NULL) THEN
	    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add('Call to Securely_Wipe_Segment.',
                                G_LEVEL_STATEMENT,l_dbg_mod);
            END IF;
	    Secure_Wipe_Segment(l_code_segment_id);
	    FOR extn_rec IN c_source_extns(p_trxn_entity_id) LOOP
	      Secure_Wipe_Segment(extn_rec.instr_code_sec_segment_id);
	    END LOOP;
	  END IF;


          IF (NOT l_reqresp.Trxn_Id IS NULL) THEN

            -- populate the dirdeb_instruction_code column
            -- for settlement
            BEGIN
              IBY_FNDCPT_SETUP_PUB.Get_Trxn_Payer_Attributes(p_payer,p_payer_equivalency, l_payer_attribs);

              UPDATE iby_trxn_summaries_all
                 SET dirdeb_instruction_code = l_payer_attribs.DirectDebit_BankInstruction
               WHERE transactionid = l_reqresp.Trxn_Id;

               IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          iby_debug_pub.add('Set DirectDebit_BankInstruction for trxn',
                                    G_LEVEL_STATEMENT,l_dbg_mod);
               END IF;

            EXCEPTION
              WHEN OTHERS THEN
                IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
		   iby_debug_pub.add('Unable to retrieve/set payer attribs for trxn',
                                     G_LEVEL_EXCEPTION,l_dbg_mod);
                END IF;
            END;

	    -- Fix for bug# 7377455. Stamp the tangibleid on the PSON column of
 	    -- IBY_FNDCPT_TX_EXTENSIONS table
 	    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       iby_debug_pub.add( 'Stamping the PSON on the extension as '||
 	                         l_tangible.Tangible_Id,
                         	 G_LEVEL_STATEMENT,l_dbg_mod);
            END IF;

 	    UPDATE iby_fndcpt_tx_extensions
 	    SET payment_system_order_number = l_tangible.Tangible_Id
 	    WHERE trxn_extension_id = p_trxn_entity_id;

	    -- Fix for bug# 7530578. Stamp the initiator transaction extension id
	    -- on the corresponding record in iby_trxn_summaries_all
	    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add( 'Stamping '||p_trxn_entity_id ||' as the initiator_extension_id'
	                       ||'on the auth record', G_LEVEL_STATEMENT,l_dbg_mod);
            END IF;
	    UPDATE iby_trxn_summaries_all
	    SET initiator_extension_id = p_trxn_entity_id
	    WHERE transactionid = l_reqresp.Trxn_Id
	    AND   reqtype = 'ORAPMTREQ';

            IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add('creating extension operation record for=' ||
                                p_trxn_entity_id,G_LEVEL_STATEMENT,l_dbg_mod);
            END IF;

            -- check to see if the operation is already recorded
            OPEN c_operation_count(p_trxn_entity_id,l_reqresp.Trxn_Id);
            FETCH c_operation_count INTO l_op_count;
            CLOSE c_operation_count;
            l_op_count := NVL(l_op_count,0);

            IF ( l_op_count > 0 ) THEN
              IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        iby_debug_pub.add( 'operation already recorded',G_LEVEL_STATEMENT,l_dbg_mod);
              END IF;
            ELSE
              INSERT INTO iby_fndcpt_tx_operations
              (trxn_extension_id, transactionid,
               created_by, creation_date, last_updated_by, last_update_date,
               last_update_login, object_version_number
              )
              VALUES
              (p_trxn_entity_id, l_reqresp.Trxn_Id,
               fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
               fnd_global.login_id, 1
              );

              --
              -- back-propagate the authorization
              --
              INSERT INTO iby_fndcpt_tx_operations
              (trxn_extension_id, transactionid,
               created_by, creation_date, last_updated_by, last_update_date,
               last_update_login, object_version_number
              )
              SELECT source_trxn_extension_id, l_reqresp.Trxn_Id,
                fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
                fnd_global.login_id, 1
              FROM iby_fndcpt_tx_xe_copies
              START WITH copy_trxn_extension_id = p_trxn_entity_id
              CONNECT BY PRIOR source_trxn_extension_id = copy_trxn_extension_id;

              IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        iby_debug_pub.add('back-propogated rows:='||SQL%ROWCOUNT,G_LEVEL_STATEMENT,l_dbg_mod);
	      END IF;

              --
              -- forward propogate the authorization
              --
              INSERT INTO iby_fndcpt_tx_operations
              (trxn_extension_id, transactionid,
               created_by, creation_date, last_updated_by, last_update_date,
               last_update_login, object_version_number
              )
              SELECT copy_trxn_extension_id, l_reqresp.Trxn_Id,
                fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
                fnd_global.login_id, 1
              FROM iby_fndcpt_tx_xe_copies
              START WITH source_trxn_extension_id = p_trxn_entity_id
              CONNECT BY source_trxn_extension_id = PRIOR copy_trxn_extension_id;

              IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         iby_debug_pub.add('forward-propogated rows:='||SQL%ROWCOUNT,G_LEVEL_STATEMENT,l_dbg_mod);
              END IF;

            END IF;

            x_auth_result.Auth_Id := l_reqresp.Trxn_Id;
            x_auth_result.Auth_Date := l_reqresp.Trxn_Date;
            x_auth_result.Auth_Code := l_reqresp.Authcode;
            x_auth_result.AVS_Code := l_reqresp.AVSCode;
            x_auth_result.Instr_SecCode_Check := l_reqresp.CVV2Result;
            x_auth_result.PaymentSys_Code := l_reqresp.BEPErrCode;
            x_auth_result.PaymentSys_Msg := l_reqresp.BEPErrMessage;
            --x_auth_result.Risk_Result;

          END IF;

          --COMMIT;

          IF (l_reqresp.Response.Status = 0) THEN
            x_response.Result_Code := G_RC_AUTH_SUCCESS;
          ELSE
--x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR);

            -- check if the result code is seeded in the result definitions
            -- table
            --
            IF (IBY_FNDCPT_COMMON_PUB.Get_Result_Category(x_response.Result_Code,iby_payment_adapter_pub.G_INTERFACE_CODE) IS NULL)
            THEN
              x_response.Result_Code := 'COMMUNICATION_ERROR';
--IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR;
            END IF;

            IF ( (NOT l_reqresp.Response.ErrMessage IS NULL)
               OR (NOT l_reqresp.Response.ErrCode IS NULL) )
            THEN
	    --Commenting this for Bug: 8368913
	    /*
                l_reqresp.Response.ErrMessage :=
                l_reqresp.Response.ErrMessage || ' (' ||
                l_reqresp.Response.ErrCode || ')';
            */
	    --Changing Error Message that is displayed
	    --This conveys more appropriate than generic msg
	    --displayed previously.
	      l_reqresp.Response.ErrMessage :=
                l_reqresp.BEPErrMessage || ' (' ||
		l_reqresp.BEPErrCode || ')';
             --End of Bug:8368913.
            END IF;

            iby_fndcpt_common_pub.Prepare_Result(
                iby_payment_adapter_pub.G_INTERFACE_CODE,
                l_reqresp.Response.ErrMessage,
                l_prev_msg_count,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_response
                );

            RETURN;
          END IF;

        END IF;
      ELSE
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ID;

        l_fail_msg := Get_Extension_Auth_Fail(p_trxn_entity_id,p_payer);
        IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add('fail msg code:=' || l_fail_msg,G_LEVEL_ERROR,l_dbg_mod);
        END IF;
        IF (NOT l_fail_msg IS NULL) THEN
          FND_MESSAGE.SET_NAME('IBY',l_fail_msg);
          l_fail_msg := FND_MESSAGE.GET();

          iby_fndcpt_common_pub.Prepare_Result
          (iby_payment_adapter_pub.G_INTERFACE_CODE,
           l_fail_msg,l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,
           x_response);

           RETURN;
        END IF;
      END IF;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_module);
     END IF;
    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
                            debug_level => G_LEVEL_EXCEPTION,
                            module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
                             debug_level => G_LEVEL_UNEXPECTED,
                             module => G_DEBUG_MODULE || l_module);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );

      WHEN OTHERS THEN

	IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
                              debug_level => G_LEVEL_UNEXPECTED,
                              module => G_DEBUG_MODULE || l_module);
        END IF;

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

  END Create_Authorization;




  PROCEDURE Get_Authorization
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_trxn_entity_id   IN   NUMBER,
            x_auth_result      OUT NOCOPY AuthResult_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Authorization';
    l_prev_msg_count NUMBER;

    CURSOR c_auth
     (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
    IS
      SELECT authorization_id, authorization_date, authorization_code,
        avs_code, instr_sec_code_check, pmt_sys_err_code, pmt_sys_err_msg
      FROM iby_trxn_ext_auths_v
      WHERE (trxn_extension_id = ci_extension_id)
      ORDER BY
        DECODE(authorization_result_code, 'AUTH_SUCCESS',10,
          'AUTH_PENDING',5, 0) DESC;
  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_module);
     END IF;


    IF (c_auth%ISOPEN) THEN CLOSE c_auth; END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                           debug_level => G_LEVEL_ERROR,
                           module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    OPEN c_auth(p_trxn_entity_id);
    FETCH c_auth INTO
      x_auth_result.Auth_Id, x_auth_result.Auth_Date,
      x_auth_result.Auth_Code, x_auth_result.AVS_Code,
      x_auth_result.Instr_SecCode_Check, x_auth_result.PaymentSys_Code,
      x_auth_result.PaymentSys_Msg;
    IF (c_auth%NOTFOUND) THEN
      x_response.Result_Code := G_RC_INVALID_EXTENSION_ID;
    ELSE
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_module);
     END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
                            debug_level => G_LEVEL_EXCEPTION,
                            module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
                             debug_level => G_LEVEL_UNEXPECTED,
                             module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );

      WHEN OTHERS THEN

	IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
                             debug_level => G_LEVEL_UNEXPECTED,
                             module => G_DEBUG_MODULE || l_module);
        END IF;

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

  END Get_Authorization;


  PROCEDURE Cancel_Authorization
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_auth_id          IN   NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Cancel_Authorization';
    l_prev_msg_count NUMBER;
  BEGIN
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_module);
     END IF;


    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => G_LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    x_response.Result_Code := G_RC_AUTH_CANCEL_UNSUPPORTED;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_module);
     END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
                             debug_level => G_LEVEL_UNEXPECTED,
                             module => G_DEBUG_MODULE || l_module);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );

      WHEN OTHERS THEN

	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
                             debug_level => G_LEVEL_UNEXPECTED,
                             module => G_DEBUG_MODULE || l_module);
        END IF;

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

  END Cancel_Authorization;




 PROCEDURE Create_Settlement
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT  NOCOPY VARCHAR2,
            x_msg_count        OUT  NOCOPY NUMBER,
            x_msg_data         OUT  NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_trxn_entity_id   IN   NUMBER,
            p_amount           IN   Amount_rec_type,
	    p_receipt_attribs  IN   ReceiptAttribs_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Create_Settlement';
    l_prev_msg_count NUMBER;

    l_payer_level     VARCHAR2(30);
    l_payer_id        iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs   IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;

    l_extension_count NUMBER;
    l_transactionid   iby_fndcpt_tx_operations.transactionid%TYPE;

    l_ecapp_id        NUMBER;
    l_capture_trxn    IBY_PAYMENT_ADAPTER_PUB.CaptureTrxn_rec_type;
    lx_capresp        IBY_PAYMENT_ADAPTER_PUB.CaptureResp_rec_type;
    lx_return_status  VARCHAR2(1);
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(3000);


    l_app_short_name  fnd_application.application_short_name%TYPE;
    l_order_id        iby_fndcpt_tx_extensions.order_id%TYPE;
    l_trxn_ref1       iby_fndcpt_tx_extensions.trxn_ref_number1%TYPE;
    l_trxn_ref2       iby_fndcpt_tx_extensions.trxn_ref_number2%TYPE;
    l_encrypted       iby_fndcpt_tx_extensions.encrypted%TYPE;
    l_code_segment_id iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE;
    l_payee           IBY_PAYMENT_ADAPTER_PUB.Payee_rec_type;
    l_payer           IBY_PAYMENT_ADAPTER_PUB.Payer_rec_type;
    l_tangible        IBY_PAYMENT_ADAPTER_PUB.Tangible_rec_type;
    l_pmt_instr       IBY_PAYMENT_ADAPTER_PUB.PmtInstr_rec_type;
    l_pmt_trxn        IBY_PAYMENT_ADAPTER_PUB.PmtReqTrxn_rec_type;
    l_reqresp         IBY_PAYMENT_ADAPTER_PUB.ReqResp_rec_type;
    l_single_use      iby_fndcpt_payer_assgn_instr_v.card_single_use_flag%TYPE;

    l_op_count        NUMBER;

    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

    CURSOR c_extension
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
     ci_payer        IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
     ci_payer_level  IN VARCHAR2,
     ci_payer_equiv  IN VARCHAR2
    )
    IS
      SELECT NVL(i.instrument_type,pc.instrument_type), NVL(i.instrument_id,0),
        x.origin_application_id, a.application_short_name,
        x.order_id, x.trxn_ref_number1, x.trxn_ref_number2,
        x.instrument_security_code, x.instr_code_sec_segment_id, x.encrypted,
        x.po_number, x.voice_authorization_flag, x.voice_authorization_code,
        x.voice_authorization_date, NVL(x.instr_assignment_id,0),
        x.payment_channel_code
      FROM iby_fndcpt_tx_extensions x, iby_pmt_instr_uses_all i,
        iby_external_payers_all p, fnd_application a,
        iby_fndcpt_pmt_chnnls_b pc
      WHERE (x.instr_assignment_id = i.instrument_payment_use_id(+))
        AND (x.payment_channel_code = pc.payment_channel_code)
        -- can assume this assignment is for funds capture
        AND (x.ext_payer_id = p.ext_payer_id)
        AND (x.trxn_extension_id = ci_extension_id)
	AND (x.origin_application_id = a.application_id)
        AND (p.party_id = ci_payer.Party_Id)
        AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
             (ci_payer.org_type, ci_payer.org_id,
             ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
             ci_payer_level,ci_payer_equiv,p.org_type,p.org_id,
             p.cust_account_id,p.acct_site_use_id) = 'T');

    CURSOR c_auth
     (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
    IS
      SELECT authorization_id
      FROM iby_trxn_ext_auths_v
        WHERE (trxn_extension_id = ci_extension_id)
          AND (authorization_status = 0);


    CURSOR C_PAYEE (ci_trxn_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE) IS
      select s.payeeid, s.org_id, s.org_type
      from iby_trxn_summaries_all s, iby_fndcpt_tx_operations o
      where s.trxntypeid = 20
      and s.transactionid = o.transactionid
      and o.trxn_extension_id = ci_trxn_extension_id;

    CURSOR c_operation_count
    (ci_trxn_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
     ci_trxn_id           IN iby_trxn_summaries_all.transactionid%TYPE)
    IS
      SELECT count(1)
      FROM iby_fndcpt_tx_operations o
      WHERE o.transactionid = ci_trxn_id
        AND o.trxn_extension_id = ci_trxn_extension_id;

  BEGIN

     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;


    IF (c_extension%ISOPEN) THEN CLOSE c_extension; END IF;
    IF (c_auth%ISOPEN) THEN CLOSE c_auth; END IF;
    IF (c_payee%ISOPEN) THEN CLOSE c_payee; END IF;
    IF (c_operation_count%ISOPEN) THEN CLOSE c_operation_count; END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                           debug_level => G_LEVEL_ERROR,
                           module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('invalid payer',G_LEVEL_ERROR,l_dbg_mod);
      END IF;
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add('Create Settlemnet- Valid Payer',G_LEVEL_STATEMENT,l_dbg_mod);
	  END IF;
      OPEN c_extension(p_trxn_entity_id,p_payer,l_payer_level,p_payer_equivalency);
      FETCH c_extension INTO l_pmt_instr.PmtInstr_Type,
            l_pmt_instr.PmtInstr_Id, l_ecapp_id, l_app_short_name,
            l_order_id, l_trxn_ref1, l_trxn_ref2,
            l_pmt_trxn.CVV2, l_code_segment_id, l_encrypted,
            l_pmt_trxn.PONum, l_pmt_trxn.VoiceAuthFlag,
            l_pmt_trxn.AuthCode, l_pmt_trxn.DateOfVoiceAuthorization,
            l_pmt_instr.Pmtinstr_assignment_id,
            l_pmt_trxn.payment_channel_code;
      CLOSE c_extension;

        IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          iby_debug_pub.add('retrieveing extn attrs rows' || SQL%ROWCOUNT,G_LEVEL_STATEMENT,l_dbg_mod);
        END IF;


      IF (l_ecapp_id IS NULL) THEN
      IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Create Settlemnet. l_ecapp_id is null ',G_LEVEL_STATEMENT,l_dbg_mod);
      END IF;
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ID;
      ELSE
          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             iby_debug_pub.add('Create Settlemnet. l_ecapp_id is not null. l_pmt_instr.PmtInstr_Type  ' || l_pmt_instr.PmtInstr_Type,G_LEVEL_STATEMENT,l_dbg_mod);
	  END IF;
        IF (l_pmt_instr.PmtInstr_Type =  IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_BANKACCT) THEN
          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              iby_debug_pub.add('Create Settlemnet. Entered Bank Account flow. p_trxn_entity_id  ' || p_trxn_entity_id,G_LEVEL_STATEMENT,l_dbg_mod);
          END IF;
	  OPEN C_PAYEE(p_trxn_entity_id);
          FETCH C_PAYEE INTO l_payee.Payee_Id, l_pmt_trxn.org_id, l_pmt_trxn.org_type;
	  IF C_PAYEE%NOTFOUND THEN
            CLOSE C_PAYEE;
                IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add('Invalid Payee ',G_LEVEL_STATEMENT,l_dbg_mod);
                END IF;
	           x_response.Result_Code := G_RC_INVALID_PAYEE;

                iby_fndcpt_common_pub.Prepare_Result
                 (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
                RETURN;

	  END IF;
          CLOSE C_PAYEE;
         IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add('Payee id '  || l_payee.Payee_Id || ' org id ' || l_pmt_trxn.org_id || ' org type ' ||  l_pmt_trxn.org_type  ,G_LEVEL_STATEMENT,l_dbg_mod);
         END IF;


	  l_pmt_trxn.Auth_Type := IBY_PAYMENT_ADAPTER_PUB.G_AUTHTYPE_AUTHONLY;
          l_pmt_trxn.PmtMode := 'OFFLINE';
          l_pmt_trxn.Settlement_Date := sysdate;

	  l_payer.Party_Id := p_payer.Party_Id;

          --Changing the way we generate tangible_id :Bug: 7628586
          l_tangible.Tangible_Id :=
	       Get_Tangible_Id(l_app_short_name,p_trxn_entity_id);
	  --l_tangible.Tangible_Id :=
          --Get_Tangible_Id(l_app_short_name,l_order_id,l_trxn_ref1,l_trxn_ref2);

          l_tangible.Tangible_Amount := p_amount.Value;
          l_tangible.Currency_Code := p_amount.Currency_Code;



          -- ciphertext; get clear-text value in the engine
          IF (l_encrypted = 'Y') THEN
            l_pmt_trxn.CVV2 := NULL;
            l_pmt_trxn.Trxn_Extension_Id := p_trxn_entity_id;
          END IF;

         IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add('calling IBY_PAYMENT_ADAPTER_PUB.oraPmtReq ',G_LEVEL_STATEMENT,l_dbg_mod);
         END IF;
           IBY_PAYMENT_ADAPTER_PUB.OraPmtReq
          (1.0,  p_init_msg_list, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
           l_ecapp_id, l_payee, l_payer, l_pmt_instr,
           l_tangible,
           l_pmt_trxn,
           lx_return_status,
           lx_msg_count,
           lx_msg_data,
           l_reqresp
          );

         IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add('status :=' || lx_return_status,
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('auth status :=' ||
            to_char(l_reqresp.Response.Status),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('auth engine code :=' ||
            to_char(l_reqresp.Response.ErrCode),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('auth engine msg :=' ||
            to_char(l_reqresp.Response.ErrMessage),
            G_LEVEL_STATEMENT,l_dbg_mod);

          iby_debug_pub.add('payment system code :=' ||
            to_char(l_reqresp.BEPErrCode),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('payment system msg :=' ||
            to_char(l_reqresp.BEPErrMessage),
            G_LEVEL_STATEMENT,l_dbg_mod);

          iby_debug_pub.add('trxn id :=' ||
            to_char(l_reqresp.Trxn_ID),
            G_LEVEL_STATEMENT,l_dbg_mod);

          -- Fix for bug# 7377455. Stamp the tangibleid on the PSON column of
 	  -- IBY_FNDCPT_TX_EXTENSIONS table
 	  iby_debug_pub.add( 'Stamping the PSON on the extension as '||
 	           l_tangible.Tangible_Id,
 	               G_LEVEL_STATEMENT,l_dbg_mod);
 	 END IF;

 	  UPDATE iby_fndcpt_tx_extensions
 	  SET payment_system_order_number = l_tangible.Tangible_Id
 	  WHERE trxn_extension_id = p_trxn_entity_id;

	  -- Fix for bug# 7530578. Stamp the initiator transaction extension id
	  -- on the corresponding record in iby_trxn_summaries_all
	  IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     iby_debug_pub.add( 'Stamping '||p_trxn_entity_id ||' as the initiator_extension_id'
	                     ||'on the auth record', G_LEVEL_STATEMENT,l_dbg_mod);
          END IF;

	  UPDATE iby_trxn_summaries_all
	  SET initiator_extension_id = p_trxn_entity_id
	  WHERE transactionid = l_reqresp.Trxn_Id
	  AND   reqtype = 'ORAPMTREQ';

	   IF (l_reqresp.Response.Status = 0) THEN
             --x_response.Result_Code := G_RC_AUTH_SUCCESS;
             x_response.Result_Code := 'SETTLEMENT_SUCCESS';
           ELSE
             --x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR);

            -- check if the result code is seeded in the result definitions
            -- table
            --
            IF (IBY_FNDCPT_COMMON_PUB.Get_Result_Category(x_response.Result_Code,iby_payment_adapter_pub.G_INTERFACE_CODE) IS NULL)
            THEN
              x_response.Result_Code := 'COMMUNICATION_ERROR';
              --IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR;
            END IF;

            IF ( (NOT l_reqresp.Response.ErrMessage IS NULL)
               OR (NOT l_reqresp.Response.ErrCode IS NULL) )
            THEN
              l_reqresp.Response.ErrMessage :=
                l_reqresp.Response.ErrMessage || ' (' ||
                l_reqresp.Response.ErrCode || ')';
            END IF;

            iby_fndcpt_common_pub.Prepare_Result(
                iby_payment_adapter_pub.G_INTERFACE_CODE,
                l_reqresp.Response.ErrMessage,
                l_prev_msg_count,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_response
                );

            RETURN;

	  END IF;

          OPEN c_operation_count(p_trxn_entity_id,l_reqresp.Trxn_Id);
          FETCH c_operation_count INTO l_op_count;
          CLOSE c_operation_count;

          IF (NVL(l_op_count,0) = 0) THEN
            IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       iby_debug_pub.add('inserting into iby_fndcpt_tx_operations.',
                                 G_LEVEL_STATEMENT,l_dbg_mod);
            END IF;
            INSERT INTO iby_fndcpt_tx_operations
            (trxn_extension_id, transactionid,
             created_by, creation_date, last_updated_by, last_update_date,
             last_update_login, object_version_number
            )
            VALUES
            (p_trxn_entity_id, l_reqresp.Trxn_Id,
             fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
             fnd_global.login_id, 1
            );

            --
            -- back-propagate the authorization
            --
            INSERT INTO iby_fndcpt_tx_operations
            (trxn_extension_id, transactionid,
             created_by, creation_date, last_updated_by, last_update_date,
             last_update_login, object_version_number
            )
            SELECT source_trxn_extension_id, l_reqresp.Trxn_Id,
              fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
              fnd_global.login_id, 1
            FROM iby_fndcpt_tx_xe_copies
            START WITH copy_trxn_extension_id = p_trxn_entity_id
            CONNECT BY PRIOR source_trxn_extension_id = copy_trxn_extension_id;

	    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              iby_debug_pub.add('back-propogated rows:='||SQL%ROWCOUNT,
                                G_LEVEL_STATEMENT,l_dbg_mod);
            END IF;

            --
            -- forward propogate the authorization
            --
            INSERT INTO iby_fndcpt_tx_operations
            (trxn_extension_id, transactionid,
             created_by, creation_date, last_updated_by, last_update_date,
             last_update_login, object_version_number
            )
            SELECT copy_trxn_extension_id, l_reqresp.Trxn_Id,
              fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
              fnd_global.login_id, 1
            FROM iby_fndcpt_tx_xe_copies
            START WITH source_trxn_extension_id = p_trxn_entity_id
            CONNECT BY source_trxn_extension_id = PRIOR copy_trxn_extension_id;

            IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       iby_debug_pub.add('forward-propogated rows:='||SQL%ROWCOUNT,G_LEVEL_STATEMENT,l_dbg_mod);
            END IF;
          END IF;
        ELSE
           IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              iby_debug_pub.add('not bank account settlement ',G_LEVEL_STATEMENT,l_dbg_mod);
           END IF;

	OPEN c_auth(p_trxn_entity_id);
        FETCH c_auth INTO l_transactionid;
        CLOSE c_auth;
        IF (l_transactionid IS NULL) THEN
          x_response.Result_Code := G_RC_INVALID_AUTHORIZATION;
        ELSE
          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     iby_debug_pub.add('calling capture',G_LEVEL_STATEMENT,l_dbg_mod);
          END IF;
          l_capture_trxn.PmtMode := 'ONLINE';
          l_capture_trxn.Trxn_Id := l_transactionid;
          l_capture_trxn.Price := p_amount.Value;
          l_capture_trxn.Currency := p_amount.Currency_Code;

          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add('Settlement_Date passed as: '||p_receipt_attribs.Settlement_Date,G_LEVEL_STATEMENT,l_dbg_mod);
 	      iby_debug_pub.add('Settlement_Due_Date passed as: '||p_receipt_attribs.Settlement_Due_Date,G_LEVEL_STATEMENT,l_dbg_mod);
	  END IF;
 	  l_capture_trxn.Settlement_Date := p_receipt_attribs.Settlement_Date;

          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     iby_debug_pub.add('Create Settlement- calling OraPmtCapture ' ,G_LEVEL_STATEMENT,l_dbg_mod);
          END IF;
          IBY_PAYMENT_ADAPTER_PUB.OraPmtCapture
          (1.0, p_init_msg_list, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
           l_ecapp_id, l_capture_trxn,
           lx_return_status, lx_msg_count, lx_msg_data, lx_capresp
          );

         IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          iby_debug_pub.add('status :=' || lx_return_status,
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('capture status :=' ||
            to_char(lx_capresp.Response.Status),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('engine code :=' ||
            to_char(lx_capresp.Response.ErrCode),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('engine msg :=' ||
            to_char(lx_capresp.Response.ErrMessage),
            G_LEVEL_STATEMENT,l_dbg_mod);

          iby_debug_pub.add('payment system code :=' ||
            to_char(lx_capresp.BEPErrCode),
            G_LEVEL_STATEMENT,l_dbg_mod);
          iby_debug_pub.add('payment system msg :=' ||
            to_char(lx_capresp.BEPErrMessage),
            G_LEVEL_STATEMENT,l_dbg_mod);

	  -- Fix for bug# 7530578. Stamp the initiator transaction extension id
	  -- on the corresponding record in iby_trxn_summaries_all
	  iby_debug_pub.add( 'Stamping '||p_trxn_entity_id ||' as the initiator_extension_id'
	                      ||'on the capture record', G_LEVEL_STATEMENT,l_dbg_mod);
         END IF;

	  UPDATE iby_trxn_summaries_all
	  SET initiator_extension_id = p_trxn_entity_id
	  WHERE transactionid = l_reqresp.Trxn_Id
	  AND   reqtype = 'ORAPMTCAPTURE';

          IF (lx_capresp.Response.Status = 0) THEN
            x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
          ELSE
            x_response.Result_Code :=
              NVL(lx_capresp.Response.ErrCode,IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR);
            -- check if the result code is seeded in the result definitions
            -- table
            --
            IF (IBY_FNDCPT_COMMON_PUB.Get_Result_Category(x_response.Result_Code,iby_payment_adapter_pub.G_INTERFACE_CODE) IS NULL)
            THEN
              x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR;
            END IF;

            IF ( (NOT lx_capresp.Response.ErrMessage IS NULL)
               OR (NOT lx_capresp.Response.ErrCode IS NULL) )
            THEN
              lx_capresp.Response.ErrMessage :=
                lx_capresp.Response.ErrMessage || ' (' ||
                lx_capresp.Response.ErrCode || ')';
            END IF;

            iby_fndcpt_common_pub.Prepare_Result(
                iby_payment_adapter_pub.G_INTERFACE_CODE,
                lx_capresp.Response.ErrMessage,
                l_prev_msg_count,
                x_return_status,
                x_msg_count,
                x_msg_data,
                x_response
                );
            RETURN;
          END IF;
        END IF;
      END IF;

    END IF;
    END IF;



    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;


    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

       IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
                            debug_level => G_LEVEL_EXCEPTION,
                            module => G_DEBUG_MODULE || l_module);
       END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
                          debug_level => G_LEVEL_UNEXPECTED,
                          module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );

      WHEN OTHERS THEN

       IF( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
                            debug_level => G_LEVEL_UNEXPECTED,
                            module => G_DEBUG_MODULE || l_module);
       END IF;
        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

  END Create_Settlement;


   --Overloaded API for backward compatibility
    PROCEDURE Create_Settlement
              (
              p_api_version      IN   NUMBER,
              p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
              x_return_status    OUT  NOCOPY VARCHAR2,
              x_msg_count        OUT  NOCOPY NUMBER,
              x_msg_data         OUT  NOCOPY VARCHAR2,
              p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
              p_payer_equivalency IN  VARCHAR2 :=
                IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
              p_trxn_entity_id   IN   NUMBER,
              p_amount           IN   Amount_rec_type,
              x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
              )
    IS
      p_receipt_attribs ReceiptAttribs_rec_type;
      l_module          CONSTANT  VARCHAR2(30) := 'Create_Settlement(2)';
      l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;
    BEGIN
         IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
         END IF;

      IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add( 'Overloaded API invoked. ReceiptAttribs_rec_type will be defaulted to Null',
                             G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
      END IF;

      p_receipt_attribs.Settlement_Date := NULL;
      p_receipt_attribs.Settlement_Due_Date := NULL;

      Create_Settlement
              (
              p_api_version,
              p_init_msg_list,
              x_return_status,
              x_msg_count,
              x_msg_data,
              p_payer,
              p_payer_equivalency,
              p_trxn_entity_id,
              p_amount,
              p_receipt_attribs,
              x_response
              );
         IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
         END IF;

    END Create_Settlement;

   -- Create_Settlements
   --
   --   API name        : create_settlements
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Pick up bulk settlment data from the the application
   --                     views to insert the settlement record in
   --                     IBY_TRXN_SUMMARIES_ALL
   --   Current version : 1.0
   --   Previous version: 1.0
   --   Initial version : 1.0
   --

   PROCEDURE Create_Settlements (
    p_api_version	            IN NUMBER,
    p_init_msg_list	            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_calling_app_id            IN NUMBER,
    p_calling_app_request_code	IN IBY_TRXN_SUMMARIES_ALL.CALL_APP_SERVICE_REQ_CODE%TYPE,
    p_order_view_name           IN VARCHAR2,
    x_return_status	        OUT NOCOPY VARCHAR2,
    x_msg_count	                OUT NOCOPY NUMBER,
    x_msg_data	                OUT NOCOPY VARCHAR2,
    x_responses	                OUT NOCOPY SettlementResult_tbl_type
   ) IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'Create_Settlements';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_DEBUG_MODULE || '.' ||
                                                   l_api_name;
   l_prev_msg_count NUMBER;

   --
   -- This record are used to insert into the funds capture orders
   --
   TYPE TrxnTabType IS TABLE OF IBY_TRXN_SUMMARIES_ALL%ROWTYPE
      INDEX BY BINARY_INTEGER;

   l_Trxn_Tab           TrxnTabType;
   empty_Trxn_Tab       TrxnTabType;

   TYPE TrxnCoreTabType IS TABLE OF IBY_TRXN_CORE%ROWTYPE
      INDEX BY BINARY_INTEGER;

   l_TrxnCore_Tab       TrxnCoreTabType;
   empty_TrxnCore_Tab   TrxnCoreTabType;

   TYPE TangibleTabType IS TABLE OF IBY_TANGIBLE%ROWTYPE
      INDEX BY BINARY_INTEGER;

   -- This record would be used in the create_settlements API to update the PSON
   -- attribute of an extension.
   -- This is the only attribute that we are populating in this table after a settlement
   -- so we will keep only this record in the record. We may add more in future
   TYPE Pson_rec_type IS RECORD (
     extension_id               IBY_FNDCPT_TX_EXTENSIONS.trxn_extension_id%TYPE,
     tangibleid                 IBY_FNDCPT_TX_EXTENSIONS.payment_system_order_number%TYPE
     );

   TYPE PsonTabType IS TABLE OF Pson_rec_type
 	       INDEX BY BINARY_INTEGER;

   l_pson_Tab           PsonTabType;

   l_Tangible_Tab       TangibleTabType;
   empty_Tangible_Tab   TangibleTabType;

   l_where_clause_index VARCHAR2(2000);
   l_view_name          VARCHAR2(200);
   l_app_short_name     VARCHAR2(200);

   TYPE dyn_order_select IS REF CURSOR;
   l_orders_cursor       dyn_order_select;
   l_orders_query       VARCHAR2(32767);

   l_settlement_trxn_rec FuncCaptureOrder_rec_type;
   l_caOrdersTab         caFundcaptureOrdersTabType;
   emptyOrdersTab        caFundcaptureOrdersTabType;

   prev_trxn_ext_id      NUMBER(15);
   current_trxn_ext_id   NUMBER(15);
   l_mtangible           NUMBER(15);
   l_tangibleid          VARCHAR2(80);

   indx                  PLS_INTEGER := 0;
   order_index           PLS_INTEGER := 1;
   trxnCoreIndx          PLS_INTEGER := 0;
   tangibleIndx          PLS_INTEGER := 0;

   -- Bug# 7658675.REMITTANCE BATCH (IBY_FNDCPT_TRXN_PUB.CREATE_SETTLEMENTS) LTD TO 1000 RECORDS
   -- new variables defined for inserting all the remitted records
   -- in the iby_trxn_summaries_all table.
   -- variable l is used to initialize the record# in the inner loop.
   -- rec_limit is the no of fecords processed in each fetch(iteration).It is
   -- initialized to 1000 as per design.

   l                     PLS_INTEGER := 0;
   rec_limit             NUMBER := 1000;

   -- routing out parameters

   lx_bep_id             iby_bepinfo.bepid%TYPE;
   lx_process_profile    iby_fndcpt_user_cc_pf_b.USER_CC_PROFILE_CODE %TYPE;
   lx_bep_key            iby_bepkeys.key%TYPE;
   l_routing_failure     BOOLEAN;
   l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || 'Create_Settlements';

   BEGIN

     --iby_debug_pub.add('ENTER',iby_debug_pub.G_LEVEL_PROCEDURE,l_module_name);
     IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
     END IF;

     -- Close the cursors if open due to previous error
     IF (l_orders_cursor%ISOPEN) THEN CLOSE l_orders_cursor; END IF;


     SAVEPOINT create_settlements_pub;

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
     l_prev_msg_count := FND_MSG_PUB.Count_Msg;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

        --
        -- Get the shortname of the calling app from the calling
        -- app id.
        --
        SELECT
           fnd.application_short_name
        INTO
           l_app_short_name
        FROM
           FND_APPLICATION fnd
        WHERE
           fnd.application_id = p_calling_app_id;

     -- Read view name from parameter p_order_view_name
     -- if present
     IF (p_order_view_name is null) THEN

        -- Remove 'SQL' FROM the Name of the view if the application short name
        -- begins with 'SQL' for e.g. SQLAP
        IF (INSTR(l_app_short_name, 'SQL') > 0) THEN
           l_app_short_name := SUBSTR(l_app_short_name, INSTR(l_app_short_name, 'SQL')+3,LENGTH(l_app_short_name));
        END IF;

        print_debuginfo(l_module_name, 'Calling app short name: '
           || l_app_short_name);

        --
        -- Dynamically form the view name.
        --
        -- The view name is dependent upon the calling
        -- app name and will be of the form
        -- <calling app name>_DOCUMENTS_PAYABLE.
        --
        l_view_name := l_app_short_name || '_FUNDS_CAPTURE_ORDERS_V';
     ELSE
        l_view_name := p_order_view_name;
     END IF;

     IF l_view_name = 'AR_FUNDS_CAPTURE_ORDERS_V' THEN
        l_where_clause_index :=
--          ' AND orders.selected_remittance_batch_id = decode(substr(:1,1,3),' ||
--                          '''AR_''' || ',to_number(substr(:2,4)),-99999)
--            AND orders.worker_id = to_number(substr(:3,INSTR(:4,''_'',4) + 1)) ';
         ' AND orders.selected_remittance_batch_id = decode(substr(:1,1,3),' ||
                         '''AR_''' || ',to_number(substr(substr(:2,1,INSTR(:3,''_'',4)-1),4)),-99999)
           AND orders.worker_id = to_number(substr(:4,INSTR(:5,''_'',4) + 1)) ';
     ELSE
        l_where_clause_index :=
          ' AND orders.CALL_APP_SERVICE_REQ_CODE = :1 ' ;
     END IF;
     --
     -- Read the documents for this payment service request
     -- from the calling app's view. The calling app's view
     -- will be prefixed with the application short name.
     --
     print_debuginfo(l_module_name, 'Fetching documents from '
         || l_view_name
         || ' view using CALL_APP_SERVICE_REQ_CODE '
         || p_calling_app_request_code
         || ' as key');

     l_orders_query :=
     --OPEN l_orders_cursor FOR
           'SELECT
             IBY_TRXNSUMM_MID_S.NEXTVAL TRXNMID,
             TRXN_REF_NUMBER1,
             TRXN_REF_NUMBER2,
             PAYMENT_CHANNEL_CODE,
             PO_NUMBER,
             VOICE_AUTHORIZATION_FLAG,
             PAYMENT_FUNCTION,
             CALL_APP_SERVICE_REQ_CODE,
             SETTLEMENT_DATE,
             SETTLEMENT_DUE_DATE,
             BR_MATURITY_DATE,
             ORDER_DESCRIPTION,
             SETTLEMENT_CURRENCY_CODE,
             SETTLEMENT_AMOUNT,
             PAYMENT_TRXN_EXTENSION_ID,
             INTERNAL_BANK_ACCOUNT_ID,
             PAYER_PARTY_ID,
             CUST_ACCOUNT_ID,
             ACCT_SITE_USE_ID,
             ORG_ID,
             ORG_TYPE,
             LEGAL_ENTITY_ID,
             BILL_TO_ADDRESS_ID,
             SETTLEMENT_CUSTOMER_REFERENCE,
             AR_RECEIPT_METHOD_ID,
             BR_DRAWEE_ISSUED_FLAG,
             BR_SIGNED_FLAG,
             BR_DISPUTED_FLAG,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             OBJECT_VERSION_NUMBER,
             AUTH_TRANSACTION_ID,
             auth_sales_rep_party_id,
             auth_tangibleid,
             auth_bepkey,
             auth_payeeid,
             auth_bepid,
             auth_mpayeeid,
             auth_ecappid,
             auth_paymentmethodname,
             auth_mtangibleid,
             auth_payeeinstrid,
             auth_payerid,
             auth_payerinstrid,
             auth_detaillookup,
             auth_instrnumber,
             auth_instrtype,
             auth_instrsubtype,
             auth_currencynamecode,
             auth_desturl,
             auth_nlslang,
             auth_amount,
             auth_process_profile_code,
             auth_payment_channel_code,
             auth_proc_reference_code,
             auth_proc_reference_amount,
             auth_legal_entity_id,
             auth_settlement_due_date,
             auth_bill_to_address_id,
             auth_br_maturity_date,
             auth_factored_flag,
             auth_payment_function,
             auth_payer_party_id,
             auth_cust_account_id,
             auth_acct_site_use_id,
             auth_org_id,
             auth_org_type,
             bep_type,
             payer_instr_assignment_id,
             debit_auth_flag,
             debit_auth_method,
             debit_auth_reference,
             CAPTURE_TRANSACTION_ID,
             int_bank_country,
             settle_require_vrfy_flag,
             auth_count,
             auth_dirdeb_instruction_code,
             card_subtype_code,
	     card_data_level
             FROM
             (SELECT  /*+ leading(orders.intrm) cardinality(orders.intrm 10) */
             trxnext.TRXN_REF_NUMBER1,
             trxnext.TRXN_REF_NUMBER2,
             trxnext.PAYMENT_CHANNEL_CODE,
             trxnext.PO_NUMBER,
             trxnext.VOICE_AUTHORIZATION_FLAG,
             payer.PAYMENT_FUNCTION,
             SUBSTR(orders.CALL_APP_SERVICE_REQ_CODE, 1, 255) CALL_APP_SERVICE_REQ_CODE,
             orders.SETTLEMENT_DATE,
             orders.SETTLEMENT_DUE_DATE,
             orders.BR_MATURITY_DATE,
             SUBSTR(orders.ORDER_DESCRIPTION, 1, 255) ORDER_DESCRIPTION,
             SUBSTR(orders.SETTLEMENT_CURRENCY_CODE, 1, 10) SETTLEMENT_CURRENCY_CODE,
             orders.SETTLEMENT_AMOUNT,
             orders.PAYMENT_TRXN_EXTENSION_ID,
             orders.INTERNAL_BANK_ACCOUNT_ID,
             orders.PAYER_PARTY_ID,
             orders.CUST_ACCOUNT_ID,
             orders.ACCT_SITE_USE_ID,
             orders.ORG_ID,
             SUBSTR(orders.ORG_TYPE, 1, 30) ORG_TYPE,
             orders.LEGAL_ENTITY_ID,
             orders.BILL_TO_ADDRESS_ID,
             orders.SETTLEMENT_CUSTOMER_REFERENCE,
             orders.AR_RECEIPT_METHOD_ID,
             orders.BR_DRAWEE_ISSUED_FLAG,
             orders.BR_SIGNED_FLAG,
             orders.BR_DISPUTED_FLAG,
             SUBSTR(orders.ATTRIBUTE_CATEGORY, 1, 150) ATTRIBUTE_CATEGORY,
             SUBSTR(orders.ATTRIBUTE1, 1, 150) ATTRIBUTE1,
             SUBSTR(orders.ATTRIBUTE2, 1, 150) ATTRIBUTE2,
             SUBSTR(orders.ATTRIBUTE3, 1, 150) ATTRIBUTE3,
             SUBSTR(orders.ATTRIBUTE4, 1, 150) ATTRIBUTE4,
             SUBSTR(orders.ATTRIBUTE5, 1, 150) ATTRIBUTE5,
             SUBSTR(orders.ATTRIBUTE6, 1, 150) ATTRIBUTE6,
             SUBSTR(orders.ATTRIBUTE7, 1, 150) ATTRIBUTE7,
             SUBSTR(orders.ATTRIBUTE8, 1, 150) ATTRIBUTE8,
             SUBSTR(orders.ATTRIBUTE9, 1, 150) ATTRIBUTE9,
             SUBSTR(orders.ATTRIBUTE10, 1, 150) ATTRIBUTE10,
             SUBSTR(orders.ATTRIBUTE11, 1, 150) ATTRIBUTE11,
             SUBSTR(orders.ATTRIBUTE12, 1, 150) ATTRIBUTE12,
             SUBSTR(orders.ATTRIBUTE13, 1, 150) ATTRIBUTE13,
             SUBSTR(orders.ATTRIBUTE14, 1, 150) ATTRIBUTE14,
             SUBSTR(orders.ATTRIBUTE15, 1, 150) ATTRIBUTE15,
             orders.CREATED_BY,
             orders.CREATION_DATE,
             orders.LAST_UPDATED_BY,
             orders.LAST_UPDATE_DATE,
             orders.LAST_UPDATE_LOGIN,
             orders.OBJECT_VERSION_NUMBER,
             auth.transactionid AUTH_TRANSACTION_ID,
             auth.sales_rep_party_id auth_sales_rep_party_id,
             auth.tangibleid auth_tangibleid,
             auth.bepkey auth_bepkey,
             auth.payeeid auth_payeeid,
             auth.bepid auth_bepid,
             auth.mpayeeid auth_mpayeeid,
             auth.ecappid auth_ecappid,
             auth.paymentmethodname auth_paymentmethodname,
             auth.mtangibleid auth_mtangibleid,
             auth.payeeinstrid auth_payeeinstrid,
             auth.payerid auth_payerid,
             auth.payerinstrid auth_payerinstrid,
             auth.detaillookup auth_detaillookup,
             auth.instrnumber auth_instrnumber,
             auth.instrtype auth_instrtype,
             auth.instrsubtype auth_instrsubtype,
             auth.currencynamecode auth_currencynamecode,
             auth.desturl auth_desturl,
             auth.nlslang auth_nlslang,
             auth.amount auth_amount,
             auth.process_profile_code auth_process_profile_code,
             auth.payment_channel_code auth_payment_channel_code,
             auth.proc_reference_code auth_proc_reference_code,
             auth.proc_reference_amount auth_proc_reference_amount,
             auth.legal_entity_id auth_legal_entity_id,
             auth.settlement_due_date auth_settlement_due_date,
             auth.bill_to_address_id auth_bill_to_address_id,
             auth.br_maturity_date auth_br_maturity_date,
             auth.factored_flag  auth_factored_flag,
             auth_payer.payment_function auth_payment_function,
             auth_payer.party_id auth_payer_party_id,
             auth_payer.cust_account_id auth_cust_account_id,
             auth_payer.acct_site_use_id auth_acct_site_use_id,
             auth_payer.org_id auth_org_id,
             auth_payer.org_type auth_org_type,
             bep.bep_type,
             auth.payer_instr_assignment_id,
             auth.debit_auth_flag,
             auth.debit_auth_method,
             auth.debit_auth_reference,
             captures.transactionid CAPTURE_TRANSACTION_ID,
             BranchParty.country int_bank_country,
             eft_sys.settle_require_vrfy_flag,
             COUNT(auth.transactionid) OVER (PARTITION BY
                orders.PAYMENT_TRXN_EXTENSION_ID) auth_count,
             auth.dirdeb_instruction_code auth_dirdeb_instruction_code,
	     auth_trxn_core.card_subtype_code  card_subtype_code,
	     auth_trxn_core.card_data_level card_data_level
        FROM '||l_view_name||' orders,
			 IBY_FNDCPT_TX_EXTENSIONS trxnext,
             IBY_EXTERNAL_PAYERS_ALL payer,
             IBY_TRXN_SUMMARIES_ALL auth,
             IBY_FNDCPT_TX_OPERATIONS trxnop,
             IBY_TRXN_SUMMARIES_ALL captures,
             IBY_EXTERNAL_PAYERS_ALL auth_payer,
             IBY_BEPINFO bep,
             IBY_FNDCPT_USER_EFT_PF_B eft_user,
             IBY_FNDCPT_SYS_EFT_PF_B eft_sys,
             CE_BANK_ACCOUNTS int_ba,
             --CE_BANK_BRANCHES_V branch
             HZ_PARTIES BranchParty,
             HZ_ORGANIZATION_PROFILES BranchOrgProfile,
	     IBY_TRXN_CORE auth_trxn_core
       WHERE orders.PAYMENT_TRXN_EXTENSION_ID = trxnext.TRXN_EXTENSION_ID(+)
         AND trxnop.transactionid = auth.transactionid(+)
         AND auth.payerid = auth_payer.ext_payer_id(+)
         AND auth.bepid = bep.bepid(+)
         AND auth.reqtype(+) = ''ORAPMTREQ''
         AND DECODE(auth.status(+),''0'',1,''100'',1,''31'',1,''32'',1,0) = 1
         AND orders.PAYMENT_TRXN_EXTENSION_ID = trxnop.TRXN_EXTENSION_ID(+)
         AND trxnop.transactionid = captures.transactionid(+)
         AND DECODE(captures.reqtype(+), ''ORAPMTCAPTURE'',1, ''ORAPMTBATCHREQ'',1, 0) = 1
         AND DECODE(captures.status(+), 0,1, 100,1, 11,1, 0) = 1
         AND trxnext.EXT_PAYER_ID = payer.EXT_PAYER_ID(+)
         AND DECODE(auth.instrtype, ''BANKACCOUNT'',auth.PROCESS_PROFILE_CODE,
                                     NULL) = eft_user.USER_EFT_PROFILE_CODE(+)
         AND eft_user.SYS_EFT_PROFILE_CODE = eft_sys.SYS_EFT_PROFILE_CODE(+)
         AND orders.INTERNAL_BANK_ACCOUNT_ID = int_ba.BANK_ACCOUNT_ID(+)
         --AND int_ba.BANK_BRANCH_ID = branch.BRANCH_PARTY_ID(+)
         AND int_ba.BANK_BRANCH_ID = BranchParty.party_id(+)
         AND BranchOrgProfile.party_id(+) = BranchParty.party_id
         AND BranchParty.status(+) = ''A''
         AND SYSDATE BETWEEN TRUNC(BranchOrgProfile.effective_start_date(+))
         AND NVL(TRUNC(BranchOrgProfile.effective_end_date(+)),SYSDATE + 1 )
	 AND auth_trxn_core.trxnmid(+) = auth.trxnmid
         '||l_where_clause_index||'
         ORDER BY orders.PAYMENT_TRXN_EXTENSION_ID)';
         --USING p_calling_app_request_code,p_calling_app_request_code,
           --    p_calling_app_request_code,p_calling_app_request_code,
             --  p_calling_app_request_code;
        IF l_view_name = 'AR_FUNDS_CAPTURE_ORDERS_V' THEN
          OPEN l_orders_cursor FOR
          l_orders_query
          USING p_calling_app_request_code,p_calling_app_request_code,
                p_calling_app_request_code,p_calling_app_request_code,
                p_calling_app_request_code;
        ELSE
          OPEN l_orders_cursor FOR
          l_orders_query
          USING p_calling_app_request_code;
       END IF;

      LOOP
        -- process only a limited number of records per iteration
        FETCH l_orders_cursor BULK COLLECT INTO l_caOrdersTab LIMIT rec_limit;

        print_debuginfo(l_module_name, 'Fetch '
            || order_index||' : '||l_caOrdersTab.COUNT
            || ' order rows fetched');

        order_index := order_index + 1;

        EXIT WHEN l_caOrdersTab.COUNT = 0;

        FOR j in l_caOrdersTab.FIRST..l_caOrdersTab.LAST LOOP

            l_routing_failure := FALSE;

            l_settlement_trxn_rec := l_caOrdersTab(j);

            current_trxn_ext_id := l_settlement_trxn_rec.PAYMENT_TRXN_EXTENSION_ID;
            print_debuginfo(l_module_name, 'Transaction Extension Id : '||
              current_trxn_ext_id);
            IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       iby_debug_pub.add('processing extensionid: '|| current_trxn_ext_id,
 	                         G_LEVEL_STATEMENT,l_module_name);
            END IF;

            /*
             Bug7658675# REMITTANCE BATCH (IBY_FNDCPT_TRXN_PUB.CREATE_SETTLEMENTS) LTD TO 1000 RECORDS
	     l is the new variable defined to initailize the x_responses recrod TYPE.
             All the occurrences of  x_responses(j) are replaced by  x_responses(l).
	     This will allow the remittance batch to process the records more than the 1000(i,e Limit) records.
	    */

	    l := (order_index - 2)*rec_limit + j;
            x_responses(l).Trxn_Extension_Id := current_trxn_ext_id;

            print_debuginfo(l_module_name, 'settlement no-reroute:='
              || l_settlement_trxn_rec.settle_req_vrfy
              );

            -- if the profile allows it, reroute based upon additional
            -- data at settlement time
            IF (l_settlement_trxn_rec.settle_req_vrfy = 'N') THEN

              print_debuginfo(l_module_name, 'rerouting trxn:=' ||
                l_settlement_trxn_rec.TRXNMID);

              DECLARE
               lx_payeeid            iby_payee.payeeid%TYPE;
               lx_order_id           iby_trxn_summaries_all.tangibleid%TYPE;
               lx_pmt_name           VARCHAR2(100);
               lx_bep_lang           iby_bepinfo.nls_language%TYPE;
               lx_payee_user_name    iby_payee.username%TYPE;
               lx_payee_passwd       iby_payee.password%TYPE;
               lx_payee_opt          NUMBER;
               lx_bep_suffix         iby_bepinfo.suffix%TYPE;
               lx_bep_url            iby_bepinfo.baseurl%TYPE;
               lx_bep_pmtscheme      iby_pmtschemes.pmtschemename%TYPE;
               lx_bep_username       iby_bepinfo.bepusername%TYPE;
               lx_bep_passwd         iby_bepinfo.beppassword%TYPE;
               lx_bep_security       NUMBER;
               lx_bep_setinit        NUMBER;
               lx_bep_leadtime       iby_bepinfo.leadtime%TYPE;
               lx_bep_type           iby_bepinfo.bep_type%TYPE;
              BEGIN

                IBY_PAYMENTMANAGERDB_PKG.LISTBEP
                (l_settlement_trxn_rec.SETTLEMENT_AMOUNT,
                 l_settlement_trxn_rec.PAYMENT_CHANNEL_CODE,
                 l_settlement_trxn_rec.SETTLEMENT_CURRENCY_CODE,
                 l_settlement_trxn_rec.AUTH_PAYEEID,
                 l_settlement_trxn_rec.AUTH_INSTRSUBTYPE,
                 l_settlement_trxn_rec.AUTH_INSTRNUMBER,
                 NULL, -- ABA routing #
                 l_settlement_trxn_rec.AUTH_ORG_ID,
                 NULL, -- fin app type
                 NULL, -- no transaction id
                 'ORAPMTREQ',
                 l_settlement_trxn_rec.AUTH_ECAPPID,
                 l_settlement_trxn_rec.AUTH_INSTRSUBTYPE,
                 l_settlement_trxn_rec.int_bank_country,
                 l_settlement_trxn_rec.AUTH_FACTORED_FLAG,
                 l_settlement_trxn_rec.INTERNAL_BANK_ACCOUNT_ID,
                 l_settlement_trxn_rec.BR_SIGNED_FLAG,
                 l_settlement_trxn_rec.BR_DRAWEE_ISSUED_FLAG,
                 l_settlement_trxn_rec.AR_RECEIPT_METHOD_ID,
                 lx_payeeid,
                 lx_order_id,
                 lx_pmt_name,
                 lx_bep_lang,
                 lx_payee_user_name,
                 lx_payee_passwd,
                 lx_payee_opt,
                 lx_bep_id,
                 lx_bep_suffix,
                 lx_bep_url,
                 lx_bep_key,
                 lx_bep_pmtscheme,
                 lx_bep_username,
                 lx_bep_passwd,
                 lx_bep_security,
                 lx_bep_setinit,
                 lx_bep_leadtime,
                 lx_bep_type,
                 lx_process_profile
                );
              EXCEPTION
                WHEN OTHERS THEN
                  l_routing_failure := TRUE;
                  print_debuginfo(l_module_name, 'Exception : '
                    || SQLERRM);
              END;

              print_debuginfo(l_module_name, 'new process profile:='
                || lx_process_profile);
              print_debuginfo(l_module_name, 'new bep id:=' || lx_bep_id);
              print_debuginfo(l_module_name, 'new bep key:=' || lx_bep_key);

            END IF;

            -- Perform the necessary validations on the data
            --
            -- 1. No duplicate settlement capture must exist.
            -- 2. The transaction/order id must belong to an existing, successful authorization
            -- 3. Transaction amount is a positive number no greater than the amount of the previous authorization
            -- 4. Currency of the amount is the same as for the preceding auth
            --

            print_debuginfo(l_module_name,'related capture is:=' ||
              l_settlement_trxn_rec.CAPTURE_TRANSACTION_ID);

	    IF (l_settlement_trxn_rec.bep_type IS NULL) THEN
 	         print_debuginfo(l_module_name,'Extension '||
 	                         l_settlement_trxn_rec.PAYMENT_TRXN_EXTENSION_ID
 	                         ||' (auth transactionid='||l_settlement_trxn_rec.auth_transactionid||
 	                         ') has bep_type as null');
	    END IF;

            -- Transaction Extension Id Check
            IF(current_trxn_ext_id is NULL) THEN
                x_responses(l).Result.Result_Code := G_RC_INVALID_EXTENSION_ID;
            ELSIF (l_routing_failure) THEN
                x_responses(l).Result.Result_Code := 'ROUTING_FAILURE';

            ELSIF(current_trxn_ext_id = prev_trxn_ext_id) THEN
                --ignore duplicate record due to multiple auths or multiple
                -- duplicate settlements
                NULL;
            ELSIF(NOT l_settlement_trxn_rec.CAPTURE_TRANSACTION_ID IS NULL) THEN
                --flag a duplicate settlement
                x_responses(l).Result.Result_Code := G_RC_DUPLICATE_SETTLEMENT;
            ELSIF(l_settlement_trxn_rec.auth_count = 0) THEN
                --flag no auth record present
                x_responses(l).Result.Result_Code := G_RC_INVALID_AUTHORIZATION;
            ELSIF(l_settlement_trxn_rec.auth_count > 1 AND
                  l_settlement_trxn_rec.PAYMENT_CHANNEL_CODE in  ('CC_PMTCHANNEL_CODE', 'DC_PMTCHANNEL_CODE')) THEN
                --only one auth allowed for CreditCards and DebitCards
                x_responses(l).Result.Result_Code := G_RC_AUTH_GROUPING_ERROR;
            ELSIF(l_settlement_trxn_rec.PAYMENT_CHANNEL_CODE in  ('CC_PMTCHANNEL_CODE', 'DC_PMTCHANNEL_CODE')
                  AND (l_settlement_trxn_rec.auth_amount < l_settlement_trxn_rec.SETTLEMENT_AMOUNT OR
                       l_settlement_trxn_rec.auth_currencynamecode <> l_settlement_trxn_rec.SETTLEMENT_CURRENCY_CODE)) THEN
                -- Settlement amount check
                x_responses(l).Result.Result_Code := G_RC_INVALID_AMOUNT;
            ELSE
                -- Map to transaction table
                IF (x_responses(l).Result.Result_Code IS NULL) THEN

                   l_Trxn_Tab(indx).SALES_REP_PARTY_ID    := l_settlement_trxn_rec.auth_SALES_REP_PARTY_ID;
                   l_Trxn_Tab(indx).TRXNMID               := l_settlement_trxn_rec.TRXNMID;
                   l_Trxn_Tab(indx).TRANSACTIONID         := l_settlement_trxn_rec.auth_transactionid;
                   -- In the case of Bank Accounts and multiple authorizations,
                   -- get tangible id from API and populate IBY_TANGIBLE table
                   CASE (l_settlement_trxn_rec.auth_instrtype = BA_INSTR_TYPE
                         AND l_settlement_trxn_rec.auth_count > 1)
                      WHEN (TRUE) THEN
                         print_debuginfo(l_module_name,'Calling IBY_FNDCPT_TRXN_PUB.Get_Tangible_Id...');
                         print_debuginfo(l_module_name,'with data '||l_app_short_name
                           ||', '|| l_settlement_trxn_rec.auth_tangibleid ||
                           ', '|| l_settlement_trxn_rec.TRXN_REF_NUMBER1 ||
                           ', '|| l_settlement_trxn_rec.TRXN_REF_NUMBER2);

                      --Bug: 7628586 :: New Functions for creating Tangible id
                      l_tangibleid :=
		              IBY_FNDCPT_TRXN_PUB.Get_Tangible_Id
		                 (p_app_short_name   => l_app_short_name,
				  p_trxn_extn_id     => l_settlement_trxn_rec.PAYMENT_TRXN_EXTENSION_ID
				 );
                      --   l_tangibleid :=
                      --      IBY_FNDCPT_TRXN_PUB.Get_Tangible_Id
                      --         (p_app_short_name    => l_app_short_name,
                      --          p_order_id          => l_settlement_trxn_rec.auth_tangibleid,
                      --          p_trxn_ref1         => l_settlement_trxn_rec.TRXN_REF_NUMBER1,
                      --          p_trxn_ref2         => l_settlement_trxn_rec.TRXN_REF_NUMBER2
                      --         );
                         l_Trxn_Tab(indx).TANGIBLEID    := substr(l_tangibleid,0,80);
                         print_debuginfo(l_module_name, 'Got Tangible Id '||
                           l_Trxn_Tab(indx).TANGIBLEID);

                         -- insert row into IBY_TANGIBLE
                         SELECT IBY_TANGIBLE_S.NEXTVAL
                           INTO l_mtangible
                           FROM DUAL;

                         print_debuginfo(l_module_name, 'Got MTtangible Id '
                           ||l_mtangible);

                         l_Trxn_Tab(indx).MTANGIBLEID                       := l_mtangible;
                         l_Tangible_Tab(tangibleIndx).MTANGIBLEID           := l_mtangible;
                         l_Tangible_Tab(tangibleIndx).TANGIBLEID            := l_Trxn_Tab(indx).TANGIBLEID;
                         l_Tangible_Tab(tangibleIndx).AMOUNT                := l_settlement_trxn_rec.SETTLEMENT_AMOUNT;
                         l_Tangible_Tab(tangibleIndx).CURRENCYNAMECODE      := l_settlement_trxn_rec.SETTLEMENT_CURRENCY_CODE;
                         l_Tangible_Tab(tangibleIndx).CREATED_BY            := FND_GLOBAL.user_id;
                         l_Tangible_Tab(tangibleIndx).CREATION_DATE         := sysdate;
                         l_Tangible_Tab(tangibleIndx).LAST_UPDATED_BY       := FND_GLOBAL.user_id;
                         l_Tangible_Tab(tangibleIndx).LAST_UPDATE_DATE      := sysdate;
                         l_Tangible_Tab(tangibleIndx).LAST_UPDATE_LOGIN     := FND_GLOBAL.login_id;
                         l_Tangible_Tab(tangibleIndx).OBJECT_VERSION_NUMBER := 1.0;


                         --l_Tangible_Tab(tangibleIndx).SOURCE_OBJECT_TYPE_CODE :=
                         --l_Tangible_Tab(tangibleIndx).SOURCE_OBJECT_ID    :=
                         --l_Tangible_Tab(tangibleIndx).ACCTNO              :=
                         --l_Tangible_Tab(tangibleIndx).MEMO                :=
                         --l_Tangible_Tab(tangibleIndx).ISSUEDATE           :=
                         --l_Tangible_Tab(tangibleIndx).ORDER_MEDIUM        :=
                         --l_Tangible_Tab(tangibleIndx).EFT_AUTH_METHOD     :=
                         --l_Tangible_Tab(tangibleIndx).SECURITY_GROUP_ID   :=

                         tangibleIndx := tangibleIndx + 1;

                         print_debuginfo(l_module_name, 'Created Tangible record');

                         ELSE
                         l_Trxn_Tab(indx).TANGIBLEID         := l_settlement_trxn_rec.auth_tangibleid;
                         l_Trxn_Tab(indx).MTANGIBLEID        := l_settlement_trxn_rec.auth_mtangibleid;

                   END CASE;
		   l_pson_Tab(indx).extension_id    := l_settlement_trxn_rec.PAYMENT_TRXN_EXTENSION_ID;
 	           l_pson_Tab(indx).tangibleid      := l_Trxn_Tab(indx).TANGIBLEID;

                   l_Trxn_Tab(indx).CALL_APP_SERVICE_REQ_CODE
                                                          := l_settlement_trxn_rec.CALL_APP_SERVICE_REQ_CODE;
                   l_Trxn_Tab(indx).PAYEEID               := l_settlement_trxn_rec.auth_payeeid;
                   l_Trxn_Tab(indx).BEPID :=
                     NVL(lx_bep_id,l_settlement_trxn_rec.auth_bepid);
                   l_Trxn_Tab(indx).BEPKEY :=
                     NVL(lx_bep_key,l_settlement_trxn_rec.auth_bepkey);
                   l_Trxn_Tab(indx).MPAYEEID              := l_settlement_trxn_rec.auth_mpayeeid;
                   l_Trxn_Tab(indx).ECAPPID               := l_settlement_trxn_rec.auth_ecappid;
                   l_Trxn_Tab(indx).PAYMENTMETHODNAME     := l_settlement_trxn_rec.auth_paymentmethodname;
                   l_Trxn_Tab(indx).PAYEEINSTRID          := l_settlement_trxn_rec.auth_payeeinstrid;
                   l_Trxn_Tab(indx).PAYERID               := l_settlement_trxn_rec.auth_payerid;
                   l_Trxn_Tab(indx).PAYERINSTRID          := l_settlement_trxn_rec.auth_payerinstrid;
                   l_Trxn_Tab(indx).DETAILLOOKUP          := l_settlement_trxn_rec.auth_detaillookup;
                   l_Trxn_Tab(indx).AMOUNT                := l_settlement_trxn_rec.SETTLEMENT_AMOUNT;
                   l_Trxn_Tab(indx).INSTRNUMBER           := l_settlement_trxn_rec.auth_instrnumber;
                   l_Trxn_Tab(indx).INSTRTYPE             := l_settlement_trxn_rec.auth_instrtype;
                   l_Trxn_Tab(indx).INSTRSUBTYPE          := l_settlement_trxn_rec.auth_instrsubtype;
                   l_Trxn_Tab(indx).CURRENCYNAMECODE      := l_settlement_trxn_rec.auth_currencynamecode;
                   -- Payer Context fields
                   -- Note: The payer context should not be copied from the auth record but from
                   -- orders view as Settlement can have a different payer context than the Auth.
                   l_Trxn_Tab(indx).ORG_TYPE              := l_settlement_trxn_rec.ORG_TYPE;
                   l_Trxn_Tab(indx).ORG_ID                := l_settlement_trxn_rec.org_id;
                   l_Trxn_Tab(indx).CUST_ACCOUNT_ID       := l_settlement_trxn_rec.cust_account_id;
                   l_Trxn_Tab(indx).ACCT_SITE_USE_ID      := l_settlement_trxn_rec.ACCT_SITE_USE_ID;
                   l_Trxn_Tab(indx).BR_DRAWEE_ISSUED_FLAG := l_settlement_trxn_rec.BR_DRAWEE_ISSUED_FLAG;
                   l_Trxn_Tab(indx).BR_SIGNED_FLAG        := l_settlement_trxn_rec.BR_SIGNED_FLAG;
                   l_Trxn_Tab(indx).AR_RECEIPT_METHOD_ID  := l_settlement_trxn_rec.AR_RECEIPT_METHOD_ID;
                   l_Trxn_Tab(indx).PAYEEINSTRID          := l_settlement_trxn_rec.INTERNAL_BANK_ACCOUNT_ID;
		   --Bug 7170445
	           l_Trxn_Tab(indx).NEEDSUPDT             := 'Y' ;
                   CASE l_settlement_trxn_rec.bep_type
                      WHEN 'GATEWAY' THEN
                      l_Trxn_Tab(indx).STATUS            := GATEWAY_SETTLEMENT_STATUS;
                      WHEN 'PROCESSOR' THEN
                      l_Trxn_Tab(indx).STATUS            := PROCESSOR_SETTLEMENT_STATUS;
                   END CASE;
                   l_Trxn_Tab(indx).UPDATEDATE            := sysdate;
                   CASE l_settlement_trxn_rec.auth_instrtype
                      WHEN BA_INSTR_TYPE THEN
                      l_Trxn_Tab(indx).TRXNTYPEID         := BA_CAPTURE_TRXNTYPE;
                      ELSE
                      l_Trxn_Tab(indx).TRXNTYPEID         := CC_CAPTURE_TRXNTYPE;
                   END CASE;

                   --
                   -- No Sources for the following columns or the columns are not
                   -- relevant at this stage.
                   --
                   --l_Trxn_Tab(indx).ERRORLOCATION       := NULL;
                   --l_Trxn_Tab(indx).BEPCODE             := NULL;
                   --l_Trxn_Tab(indx).BEPMESSAGE          := NULL;
                   --l_Trxn_Tab(indx).BATCHID             := NULL;
                   --l_Trxn_Tab(indx).MBATCHID            := NULL;
                   --l_Trxn_Tab(indx).ECBATCHID           := NULL;
                   --l_Trxn_Tab(indx).REQDATE             := NULL;
                   --l_Trxn_Tab(indx).REQSEQ              := NULL;
                   --l_Trxn_Tab(indx).NEEDSUPDT           := NULL;
                   --l_Trxn_Tab(indx).OVERALL_SCORE       := NULL;
                   --l_Trxn_Tab(indx).SUB_KEY_ID          := NULL;
                   --l_Trxn_Tab(indx).SECURITY_GROUP_ID   := NULL;

                   l_Trxn_Tab(indx).SETTLEDATE             := l_settlement_trxn_rec.settlement_date;

                   CASE l_settlement_trxn_rec.auth_instrtype
                      WHEN BA_INSTR_TYPE THEN
                      l_Trxn_Tab(indx).REQTYPE            := 'ORAPMTBATCHREQ';
                      ELSE
                      l_Trxn_Tab(indx).REQTYPE            := 'ORAPMTCAPTURE';
                   END CASE;
                   l_trxn_Tab(indx).REQDATE               := sysdate;
                   l_Trxn_Tab(indx).DESTURL               := l_settlement_trxn_rec.auth_desturl;
                   l_Trxn_Tab(indx).NLSLANG               := l_settlement_trxn_rec.auth_nlslang;

                   l_Trxn_Tab(indx).OBJECT_VERSION_NUMBER := 1.0;

                   l_Trxn_Tab(indx).TRXNREF               := l_settlement_trxn_rec.TRXN_REF_NUMBER1;
                   l_Trxn_Tab(indx).LAST_UPDATE_DATE      := sysdate;
                   l_Trxn_Tab(indx).LAST_UPDATED_BY       := FND_GLOBAL.user_id;
                   l_Trxn_Tab(indx).CREATION_DATE         := sysdate;
                   l_Trxn_Tab(indx).CREATED_BY            := FND_GLOBAL.user_id;
                   l_Trxn_Tab(indx).LAST_UPDATE_LOGIN     := FND_GLOBAL.login_id;


                   -- New columns start here
                   l_Trxn_Tab(indx).PAYER_PARTY_ID        := l_settlement_trxn_rec.payer_party_id;
                   l_Trxn_Tab(indx).PROCESS_PROFILE_CODE  :=
                     NVL(lx_process_profile,l_settlement_trxn_rec.auth_PROCESS_PROFILE_CODE);
                   l_Trxn_Tab(indx).PAYMENT_CHANNEL_CODE  := l_settlement_trxn_rec.PAYMENT_CHANNEL_CODE;
                   l_Trxn_Tab(indx).PROC_REFERENCE_CODE   := l_settlement_trxn_rec.auth_PROC_REFERENCE_CODE;
                   l_Trxn_Tab(indx).PROC_REFERENCE_AMOUNT := l_settlement_trxn_rec.auth_PROC_REFERENCE_AMOUNT;
                --   l_Trxn_Tab(indx).SETTLEMENT_DUE_DATE   := l_settlement_trxn_rec.auth_SETTLEMENT_DUE_DATE;
		   l_Trxn_Tab(indx).SETTLEMENT_DUE_DATE   := l_settlement_trxn_rec.SETTLEMENT_DUE_DATE;
		   l_Trxn_Tab(indx).CALL_APP_SERVICE_REQ_CODE
                                                          := l_settlement_trxn_rec.CALL_APP_SERVICE_REQ_CODE;
                   l_Trxn_Tab(indx).SETTLEMENT_CUSTOMER_REFERENCE
                                                          := l_settlement_trxn_rec.SETTLEMENT_CUSTOMER_REFERENCE;
                   l_Trxn_Tab(indx).BILL_TO_ADDRESS_ID    := l_settlement_trxn_rec.BILL_TO_ADDRESS_ID;
                   l_Trxn_Tab(indx).BR_MATURITY_DATE      := l_settlement_trxn_rec.BR_MATURITY_DATE;
                   l_Trxn_Tab(indx).FACTORED_FLAG         := l_settlement_trxn_rec.auth_FACTORED_FLAG;
                   l_Trxn_Tab(indx).payer_instr_assignment_id := l_settlement_trxn_rec.payer_instr_assignment_id;

                   l_Trxn_Tab(indx).debit_auth_flag       := l_settlement_trxn_rec.debit_auth_flag;

                   l_Trxn_Tab(indx).debit_auth_method     := l_settlement_trxn_rec.debit_auth_method;

                   l_Trxn_Tab(indx).debit_auth_reference  := l_settlement_trxn_rec.debit_auth_reference;
                   l_Trxn_Tab(indx).dirdeb_instruction_code  := l_settlement_trxn_rec.auth_dirdeb_instruction_code;

		   -- Fix for bug# 7530578. Stamp the initiator transaction extension id
                   -- on the corresponding record in iby_trxn_summaries_all
		   l_Trxn_Tab(indx).initiator_extension_id  := l_settlement_trxn_rec.PAYMENT_TRXN_EXTENSION_ID;

                   /*
                    * Fix for bug 5614670:
                    *
                    * Populate the LE id on the settlement
                    * transaction based on the internal bank
                    * account id.
                    */
                   l_Trxn_Tab(indx).legal_entity_id :=
                       get_le_from_bankacct_id(l_Trxn_Tab(indx).payeeinstrid);

                   indx := indx + 1;

                   IF (l_settlement_trxn_rec.PAYMENT_CHANNEL_CODE = CC_PMTCHANNEL_CODE) THEN
                      -- populate Trxn Core record
                      l_TrxnCore_Tab(trxnCoreIndx).TrxnMID               := l_settlement_trxn_rec.TRXNMID;
                      l_TrxnCore_Tab(trxnCoreIndx).REFERENCECODE         := l_settlement_trxn_rec.TRXN_REF_NUMBER1;
                      l_TrxnCore_Tab(trxnCoreIndx).PONumber              := l_settlement_trxn_rec.PO_NUMBER;
                      l_TrxnCore_Tab(trxnCoreIndx).last_update_date      := sysdate;
                      l_TrxnCore_Tab(trxnCoreIndx).last_updated_by       := FND_GLOBAL.user_id;
                      l_TrxnCore_Tab(trxnCoreIndx).creation_date         := sysdate;
                      l_TrxnCore_Tab(trxnCoreIndx).created_by            := FND_GLOBAL.user_id;
                      l_TrxnCore_Tab(trxnCoreIndx).last_update_login     := FND_GLOBAL.login_id;
                      l_TrxnCore_Tab(trxnCoreIndx).object_version_number := 1.0;
		      l_TrxnCore_Tab(trxnCoreIndx).card_subtype_code     := l_settlement_trxn_rec.card_subtype_code ;
		      l_TrxnCore_Tab(trxnCoreIndx).card_data_level       := l_settlement_trxn_rec.card_data_level;

                      trxnCoreIndx := trxnCoreIndx + 1;
                   END IF;
                END IF;

                /*
                 * Fix for bug 4770275. Set the result code
                 * and result message before exiting the loop.
                 */
                x_responses(l).Result.Result_Code :=
                    IBY_FNDCPT_COMMON_PUB.G_RC_SETTLE_PENDING;
                IBY_FNDCPT_COMMON_PUB.Prepare_Result
                    (
                    l_prev_msg_count,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    x_responses(l).Result
                    );

             END IF;
             -- save the current transaction id to compare
             -- in next iteration
             prev_trxn_ext_id := current_trxn_ext_id;

             print_debuginfo(l_module_name, 'Transaction No: '||j||', '||'Result Code: '||
               x_responses(l).Result.Result_Code);

          END LOOP; -- Settlement transaction loop

          --
          -- Bulk Insert settlement records in IBY_TRXN_SUMMARIES_ALL
          --
          --
          print_debuginfo(l_module_name, 'Inserting ' || l_Trxn_Tab.count ||
            ' transactions');

          IF (l_Trxn_Tab.COUNT > 0) THEN
             -- insert into IBY_TRXN_SUMMARIES_ALL
             FORALL j IN l_Trxn_Tab.first..l_Trxn_Tab.last
                INSERT INTO IBY_TRXN_SUMMARIES_ALL VALUES l_Trxn_Tab(j);
          END IF;

          print_debuginfo(l_module_name, 'Inserted ' || SQL%ROWCOUNT
              || ' transactions');

	  IF (l_pson_Tab.COUNT > 0) THEN

 	     -- Fix for bug# 7377455. Stamp the tangibleid on the PSON column of
 	     -- IBY_FNDCPT_TX_EXTENSIONS table
 	     --   FORALL j IN l_pson_Tab.first..l_pson_Tab.last
 	     --        UPDATE iby_fndcpt_tx_extensions
 	     --        SET payment_system_order_number = TREAT(l_pson_Tab(j) AS Pson_rec_type).tangibleid
 	     --        WHERE trxn_extension_id = TREAT(l_pson_Tab(j) AS Pson_rec_type).extension_id;

 	     FOR i IN 0..(l_pson_Tab.COUNT-1) LOOP --index starts from 0 and ends at (COUNT-1)

		IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		    iby_debug_pub.add('updating extension '|| l_pson_Tab(i).extension_id
 	                              ||' with PSON '||l_pson_Tab(i).tangibleid, G_LEVEL_STATEMENT,l_module_name);
                END IF;
 	        UPDATE iby_fndcpt_tx_extensions
 	        SET payment_system_order_number = l_pson_Tab(i).tangibleid,
 	            object_version_number = object_version_number + 1
 	        WHERE trxn_extension_id = l_pson_Tab(i).extension_id;
 	     END LOOP;
	     IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
 	          iby_debug_pub.add('updating extension complete..'
 	                       , G_LEVEL_STATEMENT,l_module_name);
 	     END IF;
 	  END IF;

          IF (l_TrxnCore_Tab.COUNT > 0) THEN
              -- insert into IBY_TRXN_CORE
              FORALL j IN l_Trxn_Tab.first..l_Trxn_Tab.last
                INSERT INTO IBY_TRXN_CORE VALUES l_TrxnCore_Tab(j);
          END IF;

          IF (l_Tangible_Tab.COUNT > 0) THEN
              -- insert into IBY_TANGIBLE
              FORALL j IN l_Tangible_Tab.first..l_Tangible_Tab.last
                INSERT INTO IBY_TANGIBLE VALUES l_Tangible_Tab(j);
          END IF;

          l_caOrdersTab         := emptyOrdersTab;
          l_Trxn_Tab            := empty_Trxn_Tab;
          l_Tangible_Tab        := empty_Tangible_Tab;

     END LOOP; -- Bulk Clause loop

     CLOSE l_orders_cursor;

     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

     print_debuginfo(l_module_name, 'RETURN');

     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      --ROLLBACK TO create_settlements_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      print_debuginfo(l_module_name, 'Exception : ' || SQLERRM);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
      --ROLLBACK TO create_settlements_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      print_debuginfo(l_module_name, 'Exception : ' || SQLERRM);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN OTHERS THEN
      --ROLLBACK TO create_settlements_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      print_debuginfo(l_module_name, 'Exception : ' || SQLERRM);

      fnd_message.set_name('IBY', 'IBY_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   END Create_Settlements;

  PROCEDURE Create_Return
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_trxn_entity_id   IN   NUMBER,
            p_amount           IN   Amount_rec_type,
	    p_receipt_attribs  IN   ReceiptAttribs_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version     CONSTANT  NUMBER := 1.0;
    l_module          CONSTANT  VARCHAR2(30) := 'Create_Return';
    l_prev_msg_count  NUMBER;

    l_payer_level     VARCHAR2(30);
    l_payer_id        iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs   IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;
    l_settled_flag    VARCHAR2(1);
    l_returned_flag   VARCHAR2(1);
    l_extension_found BOOLEAN;

    l_ecapp_id        NUMBER;
    l_app_short_name  fnd_application.application_short_name%TYPE;
    l_order_id        iby_fndcpt_tx_extensions.order_id%TYPE;
    l_trxn_ref1       iby_fndcpt_tx_extensions.trxn_ref_number1%TYPE;
    l_trxn_ref2       iby_fndcpt_tx_extensions.trxn_ref_number2%TYPE;
    l_payee           IBY_PAYMENT_ADAPTER_PUB.Payee_rec_type;
    l_tangible        IBY_PAYMENT_ADAPTER_PUB.Tangible_rec_type;
    l_pmt_instr       IBY_PAYMENT_ADAPTER_PUB.PmtInstr_rec_type;
    l_return_trxn     IBY_PAYMENT_ADAPTER_PUB.ReturnTrxn_rec_type;
    l_credit_trxn     IBY_PAYMENT_ADAPTER_PUB.CreditTrxn_rec_type;

    lx_creditresp     IBY_PAYMENT_ADAPTER_PUB.CreditResp_rec_type;
    lx_returnresp     IBY_PAYMENT_ADAPTER_PUB.ReturnResp_rec_type;
    lx_return_status  VARCHAR2(1);
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(3000);

    l_result_category iby_result_codes.result_category%TYPE;
    l_interface_code  iby_result_codes.request_interface_code%TYPE;

    l_return_pson     VARCHAR2(100);
    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;


    CURSOR c_extension
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
     ci_payer        IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
     ci_payer_level  IN VARCHAR2,
     ci_payer_equiv  IN VARCHAR2
    )
    IS
      SELECT NVL(settled_flag,'N'), NVL(returned_flag,'N'),
        x.instrument_type, x.instrument_id,
        x.origin_application_id, a.application_short_name,
        x.order_id, x.trxn_ref_number1, x.trxn_ref_number2,
        x.payment_channel_code
      FROM iby_trxn_extensions_v x, iby_pmt_instr_uses_all i,
        iby_external_payers_all p, fnd_application a
      WHERE (x.instr_assignment_id = i.instrument_payment_use_id)
        -- can assume this assignment is for funds capture
        AND (x.origin_application_id = a.application_id)
        AND (i.ext_pmt_party_id = p.ext_payer_id)
        AND (x.trxn_extension_id = ci_extension_id)
        AND (p.party_id = ci_payer.Party_Id)
        AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
             (ci_payer.org_type, ci_payer.org_id,
             ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
             ci_payer_level,ci_payer_equiv,p.org_type,p.org_id,
             p.cust_account_id,p.acct_site_use_id) = 'T');

    CURSOR c_settlement
     (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
    IS
      SELECT settlement_id, payee_id, org_id, payment_system_order_number
      FROM iby_trxn_ext_settlements_v
        WHERE (trxn_extension_id = ci_extension_id)
        ORDER BY settlement_id DESC;
  BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    IF (c_extension%ISOPEN) THEN CLOSE c_extension; END IF;
    IF (c_settlement%ISOPEN) THEN CLOSE c_settlement; END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                          debug_level => G_LEVEL_ERROR,
                          module => G_DEBUG_MODULE || l_module);
      END IF;
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      OPEN c_extension(p_trxn_entity_id,p_payer,l_payer_level,
                       p_payer_equivalency);
      FETCH c_extension INTO l_settled_flag, l_returned_flag,
        l_pmt_instr.PmtInstr_Type, l_pmt_instr.PmtInstr_Id, l_ecapp_id,
        l_app_short_name, l_order_id, l_trxn_ref1, l_trxn_ref2,
        l_credit_trxn.payment_channel_code;
      l_extension_found := NOT c_extension%NOTFOUND;
      CLOSE c_extension;

      IF (l_settled_flag IS NULL) THEN
        x_response.Result_Code := G_RC_INVALID_EXTENSION_ID;
      ELSIF (l_settled_flag = 'N') THEN
        x_response.Result_Code := G_RC_INVALID_SETTLEMENT;
      ELSE

        OPEN c_settlement(p_trxn_entity_id);
        FETCH c_settlement INTO l_return_trxn.Trxn_ID, l_payee.Payee_ID,
          l_credit_trxn.Org_ID, l_return_pson;
        CLOSE c_settlement;

        IF (l_returned_flag = 'Y') THEN
	  --Using overloaded trxn_extension_id :: 7628586
	  l_tangible.Tangible_Id :=
	      Get_Tangible_Id(l_app_short_name,p_trxn_entity_id);
          --l_tangible.Tangible_Id :=
          --  Get_Tangible_Id(l_app_short_name,l_order_id,l_trxn_ref1,l_trxn_ref2);

	  IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     iby_debug_pub.add('Settlement_Date passed as: '||p_receipt_attribs.Settlement_Date,G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
 	     iby_debug_pub.add('Settlement_Due_Date passed as: '||p_receipt_attribs.Settlement_Due_Date,G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
          END IF;
          l_tangible.Tangible_Amount := p_amount.Value;
          l_tangible.Currency_Code := p_amount.Currency_Code;
          l_credit_trxn.PmtMode := 'ONLINE';
          l_credit_trxn.Payer_Party_Id := p_payer.Party_Id;
	  l_credit_trxn.Settlement_Date := p_receipt_attribs.Settlement_Date;

          IBY_PAYMENT_ADAPTER_PUB.OraPmtCredit
          (1.0, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
           l_ecapp_id, l_payee, l_pmt_instr, l_tangible, l_credit_trxn,
           lx_return_status, lx_msg_count, lx_msg_data, lx_creditresp
          );

          IF (NOT lx_creditresp.Trxn_Id IS NULL) THEN
            INSERT INTO iby_fndcpt_tx_operations
            (trxn_extension_id, transactionid,
             created_by, creation_date, last_updated_by, last_update_date,
             last_update_login, object_version_number
            )
            VALUES
            (p_trxn_entity_id, lx_creditresp.Trxn_Id,
             fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
             fnd_global.login_id, 1
            );
            --
            -- back-propagate the credit
            --
            INSERT INTO iby_fndcpt_tx_operations
            (trxn_extension_id, transactionid,
             created_by, creation_date, last_updated_by, last_update_date,
             last_update_login, object_version_number
            )
            SELECT source_trxn_extension_id, lx_creditresp.Trxn_Id,
              fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
              fnd_global.login_id, 1
            FROM iby_fndcpt_tx_xe_copies
            START WITH copy_trxn_extension_id = p_trxn_entity_id
            CONNECT BY source_trxn_extension_id = PRIOR copy_trxn_extension_id;

	    -- Fix for bug# 7377455. Stamp the tangibleid on the PSON column of
 	    -- IBY_FNDCPT_TX_EXTENSIONS table
 	    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    	      iby_debug_pub.add( 'Stamping the PSON on the extension as '||
 	                         l_tangible.Tangible_Id,
 	                         G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
 	    END IF;
 	    UPDATE iby_fndcpt_tx_extensions
 	    SET payment_system_order_number = l_tangible.Tangible_Id
 	    WHERE trxn_extension_id = p_trxn_entity_id;

	    -- Fix for bug# 7530578. Stamp the initiator transaction extension id
	    -- on the corresponding record in iby_trxn_summaries_all
	    IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add( 'Stamping '||p_trxn_entity_id ||' as the initiator_extension_id'
	                       ||'on the credit record', G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
            END IF;
	    UPDATE iby_trxn_summaries_all
	    SET initiator_extension_id = p_trxn_entity_id
	    WHERE transactionid = lx_creditresp.Trxn_Id
	    AND   reqtype = 'ORAPMTCREDIT';

            COMMIT;
          END IF;

          IF (lx_creditresp.Response.Status = 0) THEN
            x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
          ELSE
            x_response.Result_Code :=
              NVL(lx_creditresp.Response.ErrCode,IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR);
          END IF;
        ELSE
          IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     iby_debug_pub.add('Settlement_Date passed as: '||p_receipt_attribs.Settlement_Date,G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
 	     iby_debug_pub.add('Settlement_Due_Date passed as: '||p_receipt_attribs.Settlement_Due_Date,G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
          END IF;
          l_return_trxn.Currency := p_amount.Currency_Code;
          l_return_trxn.Price := p_amount.Value;
          l_return_trxn.PmtMode := 'ONLINE';
	  l_return_trxn.Settlement_Date := p_receipt_attribs.Settlement_Date;

          IBY_PAYMENT_ADAPTER_PUB.OraPmtReturn
          (1.0, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
           l_ecapp_id, l_return_trxn, lx_return_status, lx_msg_count,
           lx_msg_data, lx_returnresp
          );

          x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR;
          l_interface_code := IBY_FNDCPT_COMMON_PUB.G_INTERFACE_CODE;

	  -- Fix for bug# 7377455. Stamp the tangibleid on the PSON column of
 	  -- IBY_FNDCPT_TX_EXTENSIONS table
 	  IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add( 'Stamping the PSON on the extension as '||
 	                     l_return_pson,
 	                     G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
 	  END IF;
 	  UPDATE iby_fndcpt_tx_extensions
 	  SET payment_system_order_number = l_return_pson
 	  WHERE trxn_extension_id = p_trxn_entity_id;

	  -- Fix for bug# 7530578. Stamp the initiator transaction extension id
	  -- on the corresponding record in iby_trxn_summaries_all
	  IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
 	     iby_debug_pub.add( 'Stamping '||p_trxn_entity_id ||' as the initiator_extension_id'
	                     ||'on the return record', G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
          END IF;
	    UPDATE iby_trxn_summaries_all
	    SET initiator_extension_id = p_trxn_entity_id
	    WHERE transactionid = lx_returnresp.Trxn_Id
	    AND   reqtype = 'ORAPMTRETURN';

          IF (lx_returnresp.Response.Status = 0) THEN
            x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
          ELSIF (NOT lx_returnresp.Response.ErrCode IS NULL) THEN
            x_response.Result_Code := lx_returnresp.Response.ErrCode;
            l_interface_code := iby_payment_adapter_pub.G_INTERFACE_CODE;
          END IF;
        END IF;

        IF (l_interface_code = iby_payment_adapter_pub.G_INTERFACE_CODE) THEN
          l_result_category :=
          IBY_FNDCPT_COMMON_PUB.Get_Result_Category
          (x_response.Result_Code,l_interface_code);
          -- check if the result code is seeded in the result definitions
          -- table
          --
          IF (l_result_category IS NULL) THEN
            x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR;
          ELSIF (l_result_category = IBY_FNDCPT_COMMON_PUB.G_RCAT_DUP_REQ) THEN
            x_response.Result_Code := G_RC_DUPLICATE_RETURN;
          END IF;
        END IF;
      END IF;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	IF( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
                             debug_level => G_LEVEL_ERROR,
                             module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	  iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
			    debug_level => G_LEVEL_UNEXPECTED,
                            module => G_DEBUG_MODULE || l_module);
        END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );

      WHEN OTHERS THEN

	IF( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
	   iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
                             debug_level => G_LEVEL_UNEXPECTED,
                             module => G_DEBUG_MODULE || l_module);
        END IF;

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

  END Create_Return;

  PROCEDURE Create_Return
 	             (
 	             p_api_version      IN   NUMBER,
 	             p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
 	             x_return_status    OUT NOCOPY VARCHAR2,
 	             x_msg_count        OUT NOCOPY NUMBER,
 	             x_msg_data         OUT NOCOPY VARCHAR2,
 	             p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
 	             p_payer_equivalency IN  VARCHAR2 :=
 	               IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
 	             p_trxn_entity_id   IN   NUMBER,
 	             p_amount           IN   Amount_rec_type,
 	             x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
 	             )
 	   IS
 	     p_receipt_attribs     ReceiptAttribs_rec_type;
 	     l_module     CONSTANT  VARCHAR2(30) := 'Create_Return(2)';
             l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

 	   BEGIN
              IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
              END IF;

	     IF( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        iby_debug_pub.add( 'Overloaded API invoked. ReceiptAttribs_rec_type will be defaulted to Null',
 	                          G_LEVEL_STATEMENT,G_DEBUG_MODULE || l_module);
 	     END IF;
 	     p_receipt_attribs.Settlement_Date := NULL;
 	     p_receipt_attribs.Settlement_Due_Date := NULL;

 	     --Call the overloaded API with ReceiptAttribs_rec_type IN parameter
 	     Create_Return
 	             (
 	             p_api_version,
 	             p_init_msg_list,
 	             x_return_status,
 	             x_msg_count,
 	             x_msg_data,
 	             p_payer,
 	             p_payer_equivalency,
 	             p_trxn_entity_id,
 	             p_amount,
 	             p_receipt_attribs,
 	             x_response
 	             );
              IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
              END IF;

  END Create_Return;

  PROCEDURE Encrypt_Extensions
  (p_commit           IN   VARCHAR2,
   p_sys_security_key IN   iby_security_pkg.DES3_KEY_TYPE,
   x_err_code         OUT NOCOPY VARCHAR2
  )
  IS
    l_mode       iby_sys_security_options.instr_sec_code_encryption_mode%TYPE;
    l_cvv2       VARCHAR2(100);
    lx_segment_id iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE;
    l_subkey     iby_security_pkg.DES3_KEY_TYPE;
    l_module     CONSTANT  VARCHAR2(30) := 'Encrypt_Extensions';
    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;
    CURSOR c_extensions
    IS
      SELECT x.trxn_extension_id, x.instrument_security_code
      FROM iby_fndcpt_tx_extensions x
      WHERE (NVL(x.encrypted,'N') = 'N')
        AND (NOT instrument_security_code IS NULL);

  BEGIN
    l_mode := Get_Extension_Encrypt_Mode;

    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    IF (l_mode = iby_security_pkg.G_ENCRYPT_MODE_NONE) THEN
      RETURN;
    END IF;

    iby_security_pkg.validate_sys_key(p_sys_security_key,x_err_code);
    IF (NOT x_err_code IS NULL) THEN
      RETURN;
    END IF;

    FOR c_ext_rec IN c_extensions LOOP
      -- The CVV value should be padded upto 32 bytes of data
      -- as per the PABP norms. So, use the new Encode_CVV API
      -- instead of the previous Encode_Number API.
      IF('Y' = IBY_UTILITY_PVT.isNumeric(c_ext_rec.instrument_security_code)) THEN
        l_cvv2 :=
          IBY_SECURITY_PKG.Encode_CVV(c_ext_rec.instrument_security_code,TRUE);

        IBY_SECURITY_PKG.Create_Segment
        (FND_API.G_FALSE,l_cvv2,iby_security_pkg.G_ENCODING_NUMERIC,
         p_sys_security_key,lx_segment_id);

        UPDATE iby_fndcpt_tx_extensions
        SET
          instrument_security_code = LPAD('X',LENGTH(instrument_security_code),'X'),
          encrypted = 'Y',
          instr_code_sec_segment_id = lx_segment_id,
          last_updated_by = fnd_global.user_id,
          last_update_date = SYSDATE,
          last_update_login = fnd_global.login_id,
          object_version_number = object_version_number + 1
        WHERE trxn_extension_id = c_ext_rec.trxn_extension_id;
      ELSE
	fnd_file.put_line(fnd_file.log,'Could not encrypt the extension '|| c_ext_rec.trxn_extension_id
	                      || ' as the instrument security code value is invalid');
      END IF;
    END LOOP;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;
  END Encrypt_Extensions;

  PROCEDURE Encrypt_Security_Code
  (p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_security_key IN   iby_security_pkg.DES3_KEY_TYPE,
   p_security_code    IN   iby_fndcpt_tx_extensions.instrument_security_code%TYPE,
   x_segment_id       OUT NOCOPY NUMBER,
   x_err_code         OUT NOCOPY VARCHAR2
  )
  IS
  l_mode       iby_sys_security_options.instr_sec_code_encryption_mode%TYPE;
  l_cvv2       VARCHAR2(100);
  lx_segment_id iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE;
  l_subkey     iby_security_pkg.DES3_KEY_TYPE;
  l_module     CONSTANT  VARCHAR2(30) := 'Encrypt_Security_Code';
  l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

  BEGIN
   IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
   END IF;

--  test_debug('Inside Encrypt_Security_Code.. ');
  l_mode := Get_Extension_Encrypt_Mode;
  IF (l_mode = iby_security_pkg.G_ENCRYPT_MODE_NONE) THEN
      RETURN;
  END IF;
  iby_security_pkg.validate_sys_key(p_sys_security_key,x_err_code);
--  test_debug('sysKey valid.. ');
  IF (NOT x_err_code IS NULL) THEN
      RETURN;
  END IF;
  l_cvv2 := IBY_SECURITY_PKG.Encode_CVV(p_security_code,TRUE);
--  test_debug('encoded cvv: '|| l_cvv2);
  IBY_SECURITY_PKG.Create_Segment
      (FND_API.G_FALSE,l_cvv2,iby_security_pkg.G_ENCODING_NUMERIC,
       p_sys_security_key,lx_segment_id);
--   test_debug('segmentId: '|| lx_segment_id);

  x_segment_id := lx_segment_id;

  IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
  END IF;
  IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
  END IF;

  END Encrypt_Security_Code;

  PROCEDURE Decrypt_Extensions
  (p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
   p_sys_security_key IN   iby_security_pkg.DES3_KEY_TYPE,
   x_err_code         OUT NOCOPY VARCHAR2
  )
  IS
   l_mode       iby_sys_security_options.instr_sec_code_encryption_mode%TYPE;
   l_module     CONSTANT  VARCHAR2(30) := 'Decrypt_Extensions';
   l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

    CURSOR c_extensions
    IS
      SELECT x.trxn_extension_id, x.instr_sec_code_length,
        NVL(x.encrypted,'N'), s.segment_cipher_text, k.subkey_cipher_text,
        s.sec_segment_id
      FROM iby_fndcpt_tx_extensions x, iby_security_segments s,
        iby_sys_security_subkeys k
      WHERE (NVL(x.encrypted,'N') = 'Y')
        AND (NOT instrument_security_code IS NULL)
        AND (x.instr_code_sec_segment_id = s.sec_segment_id(+))
        AND (s.sec_subkey_id = k.sec_subkey_id(+));

  BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    l_mode := Get_Extension_Encrypt_Mode;
    IF (NOT (l_mode = iby_security_pkg.G_ENCRYPT_MODE_NONE)) THEN
      RETURN;
    END IF;

    iby_security_pkg.validate_sys_key(p_sys_security_key,x_err_code);
    IF (NOT x_err_code IS NULL) THEN
      RETURN;
    END IF;

    FOR c_ext_rec IN c_extensions LOOP
      UPDATE iby_fndcpt_tx_extensions
      SET
        instrument_security_code =
          Get_Security_Code(p_sys_security_key,
                            c_ext_rec.subkey_cipher_text,
                            c_ext_rec.segment_cipher_text,
                            c_ext_rec.instr_sec_code_length),
        encrypted = 'N',
        instr_code_sec_segment_id = NULL,
        last_updated_by = fnd_global.user_id,
        last_update_date = SYSDATE,
        last_update_login = fnd_global.login_id,
        object_version_number = object_version_number + 1
      WHERE trxn_extension_id = c_ext_rec.trxn_extension_id;

      DELETE iby_security_segments
      WHERE sec_segment_id = c_ext_rec.sec_segment_id;
    END LOOP;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

  END Decrypt_Extensions;

  FUNCTION Get_Security_Code
  (p_sys_sec_key       IN iby_security_pkg.DES3_KEY_TYPE,
   p_subkey_cipher     IN iby_sys_security_subkeys.subkey_cipher_text%TYPE,
   p_sec_code_cipher   IN iby_security_segments.segment_cipher_text%TYPE,
   p_sec_code_len      IN iby_fndcpt_tx_extensions.instr_sec_code_length%TYPE
  )
  RETURN iby_fndcpt_tx_extensions.instrument_security_code%TYPE
  IS
    --Increased the varchar2 size from 30 to 100 since we now
    --pad the cvv to 32 bytes of data.
    l_sec_code        VARCHAR2(100);
    l_subkey          iby_security_pkg.DES3_KEY_TYPE;
    l_module     CONSTANT  VARCHAR2(30) := 'Get_Security_Code(4)';
    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

  BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    l_subkey :=
      IBY_SECURITY_PKG.Get_Sys_Subkey(p_sys_sec_key,p_subkey_cipher);

    l_sec_code :=
      dbms_obfuscation_toolkit.des3decrypt
      ( input => p_sec_code_cipher, key => l_subkey,
        which => dbms_obfuscation_toolkit.ThreeKeyMode
      );

    l_sec_code := IBY_SECURITY_PKG.Decode_Number(l_sec_code,p_sec_code_len,TRUE);

    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    RETURN l_sec_code;
  END Get_Security_Code;

  FUNCTION Get_Security_Code
  (p_trxn_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
   p_sys_sec_key       IN iby_security_pkg.DES3_KEY_TYPE
  )
  RETURN iby_fndcpt_tx_extensions.instrument_security_code%TYPE
  IS
    l_sec_code        iby_fndcpt_tx_extensions.instrument_security_code%TYPE;
    l_sec_code_len    iby_fndcpt_tx_extensions.instr_sec_code_length%TYPE;
    l_segment_cipher  iby_security_segments.segment_cipher_text%TYPE;
    l_subkey_cipher   iby_sys_security_subkeys.subkey_cipher_text%TYPE;
    l_encrypted       iby_fndcpt_tx_extensions.encrypted%TYPE;
    lx_err_code       VARCHAR2(100);
    l_module     CONSTANT  VARCHAR2(30) := 'Get_Security_Code(2)';
    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

    CURSOR c_extension
    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE)
    IS
      SELECT x.instrument_security_code, x.instr_sec_code_length,
        NVL(x.encrypted,'N'), s.segment_cipher_text, k.subkey_cipher_text
      FROM iby_fndcpt_tx_extensions x, iby_security_segments s,
        iby_sys_security_subkeys k
      WHERE (trxn_extension_id = ci_extension_id)
        AND (x.instr_code_sec_segment_id = s.sec_segment_id(+))
        AND (s.sec_subkey_id = k.sec_subkey_id(+));

  BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    IF (c_extension%ISOPEN) THEN CLOSE c_extension; END IF;

    OPEN c_extension(p_trxn_extension_id);
    FETCH c_extension
    INTO l_sec_code, l_sec_code_len, l_encrypted, l_segment_cipher,
      l_subkey_cipher;
    CLOSE c_extension;

    IF (l_encrypted = 'N') THEN
      RETURN l_sec_code;
    ELSE
      iby_security_pkg.validate_sys_key(p_sys_sec_key,lx_err_code);
      IF (NOT lx_err_code IS NULL) THEN
        raise_application_error(-20000, lx_err_code, FALSE);
        RETURN NULL;
      END IF;
      RETURN Get_Security_Code(p_sys_sec_key,l_subkey_cipher,
                               l_segment_cipher,l_sec_code_len);
    END IF;
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

  END Get_Security_Code;

  FUNCTION Get_Security_Code
  (
   p_segment_id   IN iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE,
   p_sec_code_len IN iby_fndcpt_tx_extensions.instr_sec_code_length%TYPE,
   p_sys_sec_key  IN iby_security_pkg.DES3_KEY_TYPE
  )
  RETURN iby_fndcpt_tx_extensions.instrument_security_code%TYPE
  IS
    l_segment_cipher  iby_security_segments.segment_cipher_text%TYPE;
    l_subkey_cipher   iby_sys_security_subkeys.subkey_cipher_text%TYPE;
    lx_err_code       VARCHAR2(100);
    l_module     CONSTANT  VARCHAR2(30) := 'Get_Security_Code(3)';
    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

    CURSOR c_segment
    (ci_segment_id IN iby_fndcpt_tx_extensions.instr_code_sec_segment_id%TYPE)
    IS
      SELECT s.segment_cipher_text, k.subkey_cipher_text
      FROM iby_security_segments s, iby_sys_security_subkeys k
      WHERE (s.sec_segment_id = ci_segment_id)
        AND (s.sec_subkey_id = k.sec_subkey_id);

  BEGIN
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Enter',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    IF (c_segment%ISOPEN) THEN CLOSE c_segment; END IF;

    OPEN c_segment(p_segment_id);
    FETCH c_segment
    INTO l_segment_cipher, l_subkey_cipher;
    CLOSE c_segment;

    iby_security_pkg.validate_sys_key(p_sys_sec_key,lx_err_code);
    IF (NOT lx_err_code IS NULL) THEN
        raise_application_error(-20000, lx_err_code, FALSE);
        RETURN NULL;
    END IF;
    IF( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add('Exit',G_LEVEL_PROCEDURE,l_dbg_mod);
    END IF;

    RETURN Get_Security_Code(p_sys_sec_key,l_subkey_cipher,
                               l_segment_cipher,p_sec_code_len);

  END Get_Security_Code;


/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |     This procedure prints the debug message to the concurrent manager
 |     log file.
 |
 | PARAMETERS:
 |     IN
 |      p_debug_text - The debug message to be printed
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(
     p_module     IN VARCHAR2,
     p_debug_text IN VARCHAR2
     )
 IS
 BEGIN

     IBY_TRANSACTIONCC_PKG.print_debuginfo(p_module, p_debug_text);

 END print_debuginfo;


/*--------------------------------------------------------------------
 | NAME:
 |     get_le_from_bankacct_id
 |
 |
 | PURPOSE:
 |
 |
 | PARAMETERS:
 |     IN
 |
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 FUNCTION get_le_from_bankacct_id(
     l_intbankacct_id IN IBY_TRXN_SUMMARIES_ALL.payeeinstrid%TYPE)
     RETURN NUMBER
 IS

 l_le_id             NUMBER;
 l_module_name       CONSTANT VARCHAR2(200) := G_PKG_NAME ||
                                                   '.get_le_from_bankacct_id';

 BEGIN

     IF (l_intbankacct_id IS NOT NULL) THEN

         SELECT
             iba.account_owner_org_id  -- legal_entity_id
         INTO
             l_le_id
         FROM
             CE_BANK_ACCOUNTS iba
         WHERE
             iba.bank_account_id = l_intbankacct_id
         ;

     END IF;

     RETURN l_le_id;

 EXCEPTION
     WHEN OTHERS THEN
         print_debuginfo(l_module_name, 'Exception occured when '
             || 'retrieving LE id for '
             || 'internal bank account id: '
             || l_intbankacct_id
             );

         print_debuginfo(l_module_name, 'SQLCODE: ' || SQLCODE);
         print_debuginfo(l_module_name, 'SQLERRM: ' || SQLERRM);
         print_debuginfo(l_module_name, 'Returning NULL for LE id');
         RETURN NULL;

 END get_le_from_bankacct_id;

END IBY_FNDCPT_TRXN_PUB;

/
