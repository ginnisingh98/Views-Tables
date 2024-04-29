--------------------------------------------------------
--  DDL for Package Body IBY_FNDCPT_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FNDCPT_SETUP_PUB" AS
/*$Header: ibyfcstb.pls 120.30.12010000.24 2010/04/21 12:08:37 sugottum ship $*/


  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_FNDCPT_SETUP_PUB';

  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FNDCPT_SETUP_PUB';
  G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;


 PROCEDURE print_debuginfo(
     p_debug_text IN VARCHAR2,
     p_level     IN VARCHAR2,
     p_module IN VARCHAR2
     )
 IS
 PRAGMA AUTONOMOUS_TRANSACTION;

 BEGIN

     /*
      * If FND_GLOBAL.conc_request_id is -1, it implies that
      * this method has not been invoked via the concurrent
      * manager. In that case, write to apps log else write
      * to concurrent manager log file.
      */
     /*Remove this 2 lines after debugging*/
    -- INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
    --        || p_debug_text, sysdate);
    -- commit;

     IF (FND_GLOBAL.conc_request_id = -1) THEN

         /*
          * OPTION I:
          * Write debug text to the common application log file.
          */
         IBY_DEBUG_PUB.add(
             substr(RPAD(p_module,55) || ' : ' || p_debug_text, 0, 150),
             FND_LOG.G_CURRENT_RUNTIME_LEVEL,
             'iby.plsql.IBY_FNDCPT_SETUP_PUB'
             );

         /*
          * OPTION II:
          * Write debug text to DBMS output file.
          */
         --DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,40)||' : '||
         --    p_debug_text, 0, 150));

         /*
          * OPTION III:
          * Write debug text to temporary table.
          *
          * Use this script to create a debug table.
          * CREATE TABLE TEMP_IBY_LOGS(TEXT VARCHAR2(4000), TIME DATE);
          */
         /* uncomment these two lines for debugging */
         --INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
         --    || p_debug_text, sysdate);

         --COMMIT;

     ELSE

         /*
          * OPTION I:
          * Write debug text to the concurrent manager log file.
          */
         FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || ': ' || p_debug_text);

         /*
          * OPTION II:
          * Write debug text to DBMS output file.
          */
         --DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,40)||' : '||
         --    p_debug_text, 0, 150));

         /*
          * OPTION III:
          * Write debug text to temporary table.
          *
          * Use this script to create a debug table.
          * CREATE TABLE TEMP_IBY_LOGS(TEXT VARCHAR2(4000), TIME DATE);
          */
         /* uncomment these two lines for debugging */
         --INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
         --    || p_debug_text, sysdate);

         --COMMIT;

     END IF;

 END print_debuginfo;



  FUNCTION Exists_Pmt_Channel(p_pmt_channel IN VARCHAR2)
  RETURN BOOLEAN
  IS
    l_code   VARCHAR2(30);
    l_exists BOOLEAN;

    CURSOR c_channel(ci_channel_code IN iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE)
    IS
    SELECT payment_channel_code
    FROM iby_fndcpt_pmt_chnnls_b
    WHERE (payment_channel_code = ci_channel_code)
      AND (NVL(inactive_date,SYSDATE-10)<SYSDATE);
  BEGIN

    IF (c_channel%ISOPEN) THEN
      CLOSE c_channel;
    END IF;
    OPEN c_channel(p_pmt_channel);
    FETCH c_channel INTO l_code;
    l_exists := NOT c_channel%NOTFOUND;
    CLOSE c_channel;

    RETURN l_exists;

  END Exists_Pmt_Channel;

  FUNCTION Exists_Instr(p_instr IN PmtInstrument_rec_type)
  RETURN BOOLEAN
  IS

    l_instr_count NUMBER := 0;

    CURSOR c_creditcard(ci_instrid IN iby_creditcard.instrid%TYPE)
    IS
      SELECT COUNT(instrid)
      FROM iby_creditcard
      WHERE (instrid = ci_instrid);

    CURSOR c_bankaccount
    (ci_instrid IN iby_ext_bank_accounts.ext_bank_account_id%TYPE)
    IS
      SELECT COUNT(ext_bank_account_id)
      FROM iby_ext_bank_accounts
      WHERE (ext_bank_account_id = ci_instrid);

  BEGIN

    IF (c_creditcard%ISOPEN) THEN
      CLOSE c_creditcard;
    END IF;
    IF (c_bankaccount%ISOPEN) THEN
      CLOSE c_bankaccount;
    END IF;

    IF (p_instr.Instrument_Type = IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_CREDITCARD)
    THEN
      OPEN c_creditcard(p_instr.Instrument_Id);
      FETCH c_creditcard INTO l_instr_count;
      CLOSE c_creditcard;
    ELSIF (p_instr.Instrument_Type = IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_BANKACCT)
    THEN
      OPEN c_bankaccount(p_instr.Instrument_Id);
      FETCH c_bankaccount INTO l_instr_count;
      CLOSE c_bankaccount;
    END IF;

    IF (l_instr_count < 1) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;

  END Exists_Instr;

  -- Validates the billing address passed for a credit card instrument
  FUNCTION Validate_CC_Billing
  ( p_is_update IN VARCHAR2, p_creditcard IN CreditCard_rec_type )
  RETURN BOOLEAN
  IS

    lx_return_status  VARCHAR2(1);
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(3000);
    lx_result         IBY_FNDCPT_COMMON_PUB.Result_rec_type;
    lx_channel_attribs PmtChannel_AttribUses_rec_type;

    l_addressid       iby_creditcard.addressid%TYPE;
    l_billing_zip     iby_creditcard.billing_addr_postal_code%TYPE;
    l_billing_terr    iby_creditcard.bill_addr_territory_code%TYPE;

  BEGIN

    IF (p_creditcard.Info_Only_Flag = 'Y') THEN
      RETURN TRUE;
    END IF;

    l_addressid := p_creditcard.Billing_Address_Id;
    l_billing_zip := p_creditcard.Billing_Postal_Code;
    l_billing_terr := p_creditcard.Billing_Address_Territory;

    IF FND_API.to_Boolean(p_is_update) THEN
      IF (l_addressid = FND_API.G_MISS_NUM) THEN
        l_addressid := NULL;
      ELSIF (l_addressid IS NULL) THEN
        l_addressid := FND_API.G_MISS_NUM;
      END IF;
      IF (l_billing_zip = FND_API.G_MISS_CHAR) THEN
        l_billing_zip := NULL;
      ELSIF (l_billing_zip IS NULL) THEN
        l_billing_zip := FND_API.G_MISS_CHAR;
      END IF;
      IF (l_billing_terr = FND_API.G_MISS_CHAR) THEN
        l_billing_terr := NULL;
      ELSIF (l_billing_terr IS NULL) THEN
        l_billing_terr := FND_API.G_MISS_CHAR;
      END IF;
    END IF;

    IF ( (NOT (l_addressid IS NULL OR l_addressid = FND_API.G_MISS_NUM))
        AND
         (NOT (l_billing_zip IS NULL OR l_billing_zip = FND_API.G_MISS_CHAR))
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ( (NOT (l_billing_zip IS NULL OR l_billing_zip = FND_API.G_MISS_CHAR))
        AND (l_billing_terr IS NULL OR l_billing_terr = FND_API.G_MISS_CHAR)
       )
    THEN
      RETURN FALSE;
    ELSIF ( (NOT (l_billing_terr IS NULL OR l_billing_terr = FND_API.G_MISS_CHAR))

           AND (l_billing_zip IS NULL OR l_billing_zip = FND_API.G_MISS_CHAR)
          )
    THEN
      RETURN FALSE;
    END IF;

    Get_Payment_Channel_Attribs
    (1.0, FND_API.G_FALSE, lx_return_status, lx_msg_count, lx_msg_data,
     G_CHANNEL_CREDIT_CARD, lx_channel_attribs, lx_result);

    IF ((lx_channel_attribs.Instr_Billing_Address = G_CHNNL_ATTRIB_USE_REQUIRED)
         AND ((l_addressid IS NULL) AND (l_billing_zip IS NULL))
       )
    THEN
      RETURN FALSE;
    END IF;

    IF ((lx_channel_attribs.Instr_Billing_Address = G_CHNNL_ATTRIB_USE_DISABLED)
        AND ((NOT l_addressid IS NULL) OR (NOT l_billing_zip IS NULL))
       )
    THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  END Validate_CC_Billing;

  PROCEDURE Get_Payer_Id
  (
   p_payer IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
   p_validation_level IN VARCHAR2,
   x_payer_level OUT NOCOPY VARCHAR2,
   x_payer_id    OUT NOCOPY iby_external_payers_all.ext_payer_id%TYPE,
   x_payer_attribs OUT NOCOPY PayerAttributes_rec_type
   )
  IS

    CURSOR c_payer
    (ci_pmt_function IN p_payer.Payment_Function%TYPE,
     ci_party_id IN p_payer.Party_Id%TYPE,
     ci_account_id IN p_payer.Cust_Account_Id%TYPE,
     ci_site_id IN p_payer.Account_Site_Id%TYPE,
     ci_org_type IN p_payer.Org_Type%TYPE,
     ci_org_id IN p_payer.Org_Id%TYPE,
     ci_payer_level IN VARCHAR2)
    IS
    SELECT ext_payer_id, bank_charge_bearer_code, dirdeb_instruction_code
    FROM iby_external_payers_all
    WHERE (payment_function = ci_pmt_function)
      AND (party_id = ci_party_id)
      AND ((cust_account_id = ci_account_id)
        OR (cust_account_id IS NULL AND ci_account_id IS NULL))
      AND ((org_type = ci_org_type AND org_id = ci_org_id)
        OR (org_type IS NULL AND org_id IS NULL AND ci_org_type IS NULL AND ci_org_id IS NULL))
      AND ((acct_site_use_id = ci_site_id)
        OR (acct_site_use_id IS NULL AND ci_site_id IS NULL));

  BEGIN

    IF (c_payer%ISOPEN) THEN
      CLOSE c_payer;
    END IF;

    x_payer_level :=
      IBY_FNDCPT_COMMON_PUB.Validate_Payer(p_payer,p_validation_level);

    IF (x_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_payer_id := NULL;
      RETURN;
    END IF;

    OPEN c_payer(p_payer.Payment_Function, p_payer.Party_Id,
      p_payer.Cust_Account_Id, p_payer.Account_Site_Id, p_payer.Org_Type,
      p_payer.Org_Id, x_payer_level);
    FETCH c_payer INTO x_payer_id, x_payer_attribs.Bank_Charge_Bearer,
      x_payer_attribs.DirectDebit_BankInstruction;
    IF c_payer%NOTFOUND THEN x_payer_id := NULL; END IF;
    CLOSE c_payer;

  END Get_Payer_Id;


  PROCEDURE Set_Payer_Attributes
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_attributes IN   PayerAttributes_rec_type,
            x_payer_attribs_id OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
          )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Set_Payer_Attributes';
    l_payer_level  VARCHAR2(30);
    l_payer_attribs  PayerAttributes_rec_type;
    l_prev_msg_count NUMBER;

  BEGIN

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,x_payer_attribs_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := l_payer_level;
    ELSIF (x_payer_attribs_id IS NULL) THEN

      SELECT iby_external_payers_all_s.nextval
      INTO x_payer_attribs_id
      FROM dual;

      INSERT INTO iby_external_payers_all
      (ext_payer_id, payment_function, party_id, org_type, org_id,
       cust_account_id, acct_site_use_id, bank_charge_bearer_code,
       dirdeb_instruction_code, created_by, creation_date, last_updated_by,
       last_update_date, last_update_login, object_version_number
       )
      VALUES
      (x_payer_attribs_id, p_payer.Payment_Function,
       p_payer.Party_Id, p_payer.Org_Type, p_payer.Org_Id,
       p_payer.Cust_Account_Id, p_payer.Account_Site_Id,
       p_payer_attributes.Bank_Charge_Bearer,
       p_payer_attributes.DirectDebit_BankInstruction,
       fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
       fnd_global.login_id, 1
      );
    ELSIF (NOT (p_payer_attributes.DirectDebit_BankInstruction IS NULL)
             AND (p_payer_attributes.Bank_Charge_Bearer IS NULL)
          )
    THEN

      UPDATE iby_external_payers_all
      SET
        dirdeb_instruction_code =
          DECODE(p_payer_attributes.DirectDebit_BankInstruction,
                 FND_API.G_MISS_CHAR,NULL, dirdeb_instruction_code),
        bank_charge_bearer_code =
          DECODE(p_payer_attributes.Bank_Charge_Bearer,
                 FND_API.G_MISS_CHAR,NULL, bank_charge_bearer_code),
        last_updated_by =  fnd_global.user_id,
        last_update_date = SYSDATE,
        last_update_login = fnd_global.login_id,
        object_version_number = object_version_number + 1
      WHERE (ext_payer_id = x_payer_attribs_id);
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

    x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

	iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );
  END Set_Payer_Attributes;

  PROCEDURE Get_Payer_Attributes
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            x_payer_attributes OUT NOCOPY PayerAttributes_rec_type,
            x_payer_attribs_id OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Payer_Attributes';
    l_payer_level  VARCHAR2(30);
    l_prev_msg_count NUMBER;

  BEGIN

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,x_payer_attribs_id,x_payer_attributes);
    IF (x_payer_attribs_id IS NULL) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

	iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_module);
         END IF;

         FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data
                                   );
  END Get_Payer_Attributes;

  PROCEDURE Get_Payment_Channel_Attribs
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_channel_code     IN   VARCHAR2,
            x_channel_attrib_uses OUT NOCOPY PmtChannel_AttribUses_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Payment_Channel_Attribs';
    l_prev_msg_count NUMBER;

    CURSOR c_appl_attribs
    (ci_pmt_channel iby_fndcpt_pmt_chnnls_b.payment_channel_code%TYPE)
    IS
      SELECT NVL(isec.attribute_applicability,G_CHNNL_ATTRIB_USE_OPTIONAL),
        NVL(ibill.attribute_applicability,G_CHNNL_ATTRIB_USE_OPTIONAL),
        NVL(vaflag.attribute_applicability,G_CHNNL_ATTRIB_USE_OPTIONAL),
        NVL(vacode.attribute_applicability,G_CHNNL_ATTRIB_USE_OPTIONAL),
        NVL(vadate.attribute_applicability,G_CHNNL_ATTRIB_USE_OPTIONAL),
        NVL(ponum.attribute_applicability,G_CHNNL_ATTRIB_USE_OPTIONAL),
        NVL(poline.attribute_applicability,G_CHNNL_ATTRIB_USE_OPTIONAL),
        NVL(addinfo.attribute_applicability,G_CHNNL_ATTRIB_USE_OPTIONAL)
      FROM iby_fndcpt_pmt_chnnls_b pc, iby_pmt_mthd_attrib_appl isec,
        iby_pmt_mthd_attrib_appl ibill, iby_pmt_mthd_attrib_appl vaflag,
        iby_pmt_mthd_attrib_appl vacode, iby_pmt_mthd_attrib_appl vadate,
        iby_pmt_mthd_attrib_appl ponum, iby_pmt_mthd_attrib_appl poline,
        iby_pmt_mthd_attrib_appl addinfo
      WHERE (pc.payment_channel_code = ci_pmt_channel)
        -- instrument security
        AND (pc.payment_channel_code = isec.payment_method_code(+))
        AND (isec.payment_flow(+) = 'FUNDS_CAPTURE')
        AND (isec.attribute_code(+) = 'INSTR_SECURITY_CODE')
        -- instrument billing address
        AND (pc.payment_channel_code = ibill.payment_method_code(+))
        AND (ibill.attribute_code(+) = 'INSTR_BILLING_ADDRESS')
        AND (ibill.payment_flow(+) = 'FUNDS_CAPTURE')
        -- voice auth flag
        AND (pc.payment_channel_code = vaflag.payment_method_code(+))
        AND (vaflag.attribute_code(+) = 'VOICE_AUTH_FLAG')
        AND (vaflag.payment_flow(+) = 'FUNDS_CAPTURE')
        -- voice auth code
        AND (pc.payment_channel_code = vacode.payment_method_code(+))
        AND (vacode.attribute_code(+) = 'VOICE_AUTH_CODE')
        AND (vacode.payment_flow(+) = 'FUNDS_CAPTURE')
        -- voice auth date
        AND (pc.payment_channel_code = vadate.payment_method_code(+))
        AND (vadate.attribute_code(+) = 'VOICE_AUTH_DATE')
        AND (vadate.payment_flow(+) = 'FUNDS_CAPTURE')
        -- purcharse order number
        AND (pc.payment_channel_code = ponum.payment_method_code(+))
        AND (ponum.attribute_code(+) = 'PO_NUMBER')
        AND (ponum.payment_flow(+) = 'FUNDS_CAPTURE')
        -- purchase order line
        AND (pc.payment_channel_code = poline.payment_method_code(+))
        AND (poline.attribute_code(+) = 'PO_LINE_NUMBER')
        AND (poline.payment_flow(+) = 'FUNDS_CAPTURE')
        -- additional info
        AND (pc.payment_channel_code = addinfo.payment_method_code(+))
        AND (addinfo.attribute_code(+) = 'ADDITIONAL_INFO')
        AND (addinfo.payment_flow(+) = 'FUNDS_CAPTURE');

  BEGIN

    IF (c_appl_attribs%ISOPEN) THEN CLOSE c_appl_attribs; END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    OPEN c_appl_attribs(p_channel_code);
    FETCH c_appl_attribs INTO
      x_channel_attrib_uses.Instr_SecCode_Use,
      x_channel_attrib_uses.Instr_Billing_Address,
      x_channel_attrib_uses.Instr_VoiceAuthFlag_Use,
      x_channel_attrib_uses.Instr_VoiceAuthCode_Use,
      x_channel_attrib_uses.Instr_VoiceAuthDate_Use,
      x_channel_attrib_uses.PO_Number_Use,
      x_channel_attrib_uses.PO_Line_Number_Use,
      x_channel_attrib_uses.AddInfo_Use;

    IF (c_appl_attribs%NOTFOUND) THEN
      x_response.Result_Code := G_RC_INVALID_CHNNL;
    ELSE
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    END IF;

    CLOSE c_appl_attribs;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

	iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                    p_data   =>  x_msg_data
                                  );
  END Get_Payment_Channel_Attribs;

  PROCEDURE Set_Payer_Default_Pmt_Channel
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_channel_assignment IN PmtChannelAssignment_rec_type,
            x_assignment_id    OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Set_Payer_Default_Pmt_Channel';
    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs PayerAttributes_rec_type;

    l_result       IBY_FNDCPT_COMMON_PUB.Result_rec_type;
    l_prev_msg_count NUMBER;

    CURSOR c_chnnl_assign
    (ci_payer_id IN iby_ext_party_pmt_mthds.ext_pmt_party_id%TYPE)
    IS
      SELECT ext_party_pmt_mthd_id
      FROM iby_ext_party_pmt_mthds
      WHERE (ext_pmt_party_id = ci_payer_id)
        AND (payment_flow = G_PMT_FLOW_FNDCPT)
        AND (primary_flag = 'Y')
        AND (NVL(inactive_date,SYSDATE-10)<SYSDATE);
  BEGIN

    IF (c_chnnl_assign%ISOPEN) THEN
      CLOSE c_chnnl_assign;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,l_payer_level,
      l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSIF (NOT Exists_Pmt_Channel(p_channel_assignment.Pmt_Channel_Code)) THEN
      x_response.Result_Code := G_RC_INVALID_CHNNL;
    ELSE

      SAVEPOINT Set_Payer_Default_Pmt_Channel;

      IF (l_payer_id IS NULL) THEN
        IBY_FNDCPT_SETUP_PUB.Set_Payer_Attributes
        (
        1.0,
        FND_API.G_FALSE,
        FND_API.G_FALSE,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_payer,
        l_payer_attribs,
        l_payer_id,
        l_result
        );

        IF (l_result.Result_Code <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS) THEN
          x_response := l_result;
          RETURN;
        END IF;
      END IF;

      OPEN c_chnnl_assign(l_payer_id);
      FETCH c_chnnl_assign INTO x_assignment_id;
      CLOSE c_chnnl_assign;
      IF (x_assignment_id IS NULL) THEN

        SELECT iby_ext_party_pmt_mthds_s.NEXTVAL
        INTO x_assignment_id
        FROM DUAL;

        INSERT INTO iby_ext_party_pmt_mthds
        (ext_party_pmt_mthd_id, payment_method_code, payment_flow,
        ext_pmt_party_id, payment_function, primary_flag, inactive_date,
        created_by, creation_date, last_updated_by, last_update_date,
        last_update_login, object_version_number)
        VALUES
        (x_assignment_id, p_channel_assignment.Pmt_Channel_Code,
        G_PMT_FLOW_FNDCPT, l_payer_id, p_payer.Payment_Function, 'Y',
        p_channel_assignment.Inactive_Date, fnd_global.user_id, SYSDATE,
        fnd_global.user_id, SYSDATE, fnd_global.login_id, 1);

      ELSE

        UPDATE iby_ext_party_pmt_mthds
        SET inactive_date = p_channel_assignment.Inactive_Date,
          payment_method_code =
            NVL(p_channel_assignment.Pmt_Channel_code,payment_method_code),
          last_updated_by =  fnd_global.user_id,
          last_update_date = SYSDATE,
          last_update_login = fnd_global.login_id,
          object_version_number = object_version_number + 1
        WHERE ext_party_pmt_mthd_id = x_assignment_id;

      END IF;

      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    END IF;


    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Set_Payer_Default_Pmt_Channel;
	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Set_Payer_Default_Pmt_Channel;
	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN
        ROLLBACK TO Set_Payer_Default_Pmt_Channel;

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );
  END Set_Payer_Default_Pmt_Channel;

  PROCEDURE Get_Payer_Default_Pmt_Channel
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            x_channel_assignment OUT NOCOPY PmtChannelAssignment_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Payer_Default_Pmt_Channel';
    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs PayerAttributes_rec_type;
    l_prev_msg_count NUMBER;

    CURSOR c_chnnl_assign
    (ci_payer_id IN iby_ext_party_pmt_mthds.ext_pmt_party_id%TYPE)
    IS
      SELECT payment_method_code, primary_flag, inactive_date
      FROM iby_ext_party_pmt_mthds
      WHERE (ext_pmt_party_id = ci_payer_id)
        AND (payment_flow = G_PMT_FLOW_FNDCPT)
        AND (primary_flag = 'Y')
        AND (NVL(inactive_date,SYSDATE-10)<SYSDATE);

  BEGIN

    IF (c_chnnl_assign%ISOPEN) THEN
      CLOSE c_chnnl_assign;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      OPEN c_chnnl_assign(l_payer_id);
      FETCH c_chnnl_assign INTO x_channel_assignment.Pmt_Channel_Code,
        x_channel_assignment.Default_Flag, x_channel_assignment.Inactive_Date;
      IF (c_chnnl_assign%NOTFOUND) THEN
        x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
      ELSE
        x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
      END IF;
      CLOSE c_chnnl_assign;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );
  END Get_Payer_Default_Pmt_Channel;

  PROCEDURE Get_Trxn_Appl_Pmt_Channels
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2
              := IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_conditions       IN  IBY_FNDCPT_COMMON_PUB.TrxnContext_rec_type,
            p_result_limit     IN  IBY_FNDCPT_COMMON_PUB.ResultLimit_rec_type,
            x_channels         OUT NOCOPY PmtChannel_tbl_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Trxn_Appl_Pmt_Channels';
    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs PayerAttributes_rec_type;
    l_prev_msg_count NUMBER;

    l_channel_count NUMBER;

    -- currently do not use any transaction values for applicability;
    -- all system channels are applicable that are not site-wide
    -- deactivated (end-dated)
    --
    CURSOR c_trxn_channels
           (ci_payer IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            ci_payer_level IN VARCHAR2,
            ci_payer_equiv IN VARCHAR2)
    IS
      SELECT c.payment_channel_code, c.instrument_type
      FROM iby_ext_party_pmt_mthds pm, iby_fndcpt_pmt_chnnls_b c
      WHERE (pm.payment_method_code = c.payment_channel_code)
        AND (NVL(pm.inactive_date,SYSDATE-10)<SYSDATE)
        AND (NVL(c.inactive_date,SYSDATE-10)<SYSDATE)
        AND (pm.payment_flow = G_PMT_FLOW_FNDCPT)
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
  BEGIN

    IF (c_trxn_channels%ISOPEN) THEN
      CLOSE c_trxn_channels;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      l_channel_count := 0;

      FOR channel_rec IN c_trxn_channels(p_payer,l_payer_level,
                                         p_payer_equivalency)
      LOOP
        l_channel_count := l_channel_count + 1;
        x_channels(l_channel_count).Pmt_Channel_Code :=
          channel_rec.payment_channel_code;
        x_channels(l_channel_count).Instrument_Type := channel_rec.instrument_type;
      END LOOP;

      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );
  END Get_Trxn_Appl_Pmt_Channels;


  PROCEDURE Set_Payer_Instr_Assignment
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_assignment_attribs IN PmtInstrAssignment_rec_type,
            x_assign_id        OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Set_Payer_Instr_Assignment';
    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs PayerAttributes_rec_type;
    l_prev_msg_count NUMBER;

    l_result       IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    l_assign_id    NUMBER;
    l_instr_id     NUMBER;
    l_priority     NUMBER;
    l_instrtype    IBY_PMT_INSTR_USES_ALL.instrument_type%TYPE;

    l_bnkacct_owner_cnt NUMBER;

    -- for call to TCA hook
    l_last_update  DATE;
    l_op_type      VARCHAR2(1);
    l_parent_type  VARCHAR2(50);
    l_parent_table VARCHAR2(50);
    l_parent_id    NUMBER;
    l_party_type   VARCHAR2(50);
    l_instr_type   VARCHAR2(50);

    -- lmallick (bugfix 8586083)
    -- Query the instrument_type as well, because this isn't passed to the API when the
    -- instrument assignment is passed.
    CURSOR c_instr_assignment
           (ci_assign_id IN iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE,
            ci_payer_id IN iby_pmt_instr_uses_all.ext_pmt_party_id%TYPE,
            ci_instr_type IN iby_pmt_instr_uses_all.instrument_type%TYPE,
            ci_instr_id IN iby_pmt_instr_uses_all.instrument_id%TYPE
           )
    IS
      SELECT instrument_payment_use_id, instrument_type
      FROM iby_pmt_instr_uses_all
      WHERE (payment_flow = G_PMT_FLOW_FNDCPT)
        AND ( (instrument_payment_use_id = NVL(ci_assign_id,-1))
              OR (ext_pmt_party_id = ci_payer_id
                    AND instrument_type = ci_instr_type
                    AND instrument_id = ci_instr_id
                 )
            );


    CURSOR c_bnkacct_owner
           (ci_party_id IN iby_pmt_instr_uses_all.ext_pmt_party_id%TYPE,
            ci_instr_id IN iby_pmt_instr_uses_all.instrument_id%TYPE
           )
    IS
      SELECT count(*)
      FROM IBY_ACCOUNT_OWNERS
      WHERE EXT_BANK_ACCOUNT_ID = ci_instr_id
        AND ACCOUNT_OWNER_PARTY_ID = ci_party_id;

    l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;
  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    iby_debug_pub.add('p_assignment_attribs.Assignment_Id = '|| p_assignment_attribs.Assignment_Id,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    iby_debug_pub.add('p_assignment_attribs.Priority = '|| p_assignment_attribs.Priority,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    iby_debug_pub.add('p_assignment_attribs.Instrument.Instrument_Id = '|| p_assignment_attribs.Instrument.Instrument_Id,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    iby_debug_pub.add('p_assignment_attribs.Instrument.Instrument_Type = '|| p_assignment_attribs.Instrument.Instrument_Type,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);


    IF (c_instr_assignment%ISOPEN) THEN CLOSE c_instr_assignment; END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    -- Bug# 8470581
    -- Do not allow an assignment if the payer party_id is not a joint
    -- account owner
    IF ((p_assignment_attribs.Assignment_Id IS NULL) AND
           (p_assignment_attribs.Instrument.Instrument_Type = 'BANKACCOUNT')) THEN
      IF(c_bnkacct_owner%ISOPEN) THEN CLOSE c_bnkacct_owner; END IF;
      OPEN c_bnkacct_owner(p_payer.Party_Id, p_assignment_attribs.Instrument.Instrument_Id);
      FETCH c_bnkacct_owner INTO l_bnkacct_owner_cnt;

      IF (l_bnkacct_owner_cnt <= 0) THEN
        x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
	RETURN;
      END IF;
    END IF;

    Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

   iby_debug_pub.add('l_payer_id = '|| l_payer_id,iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);


    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    --
    -- CHANGE?: does PL/SQL do logical short circuiting?  If not then
    --          change the condition evaluations as the exists_instrument
    --          function is relatively expensive
    --
    ELSIF ( (p_assignment_attribs.Assignment_Id IS NULL) AND
            (NOT Exists_Instr(p_assignment_attribs.Instrument)) ) THEN
      x_response.Result_Code := G_RC_INVALID_INSTRUMENT;
    ELSE
      SAVEPOINT Set_Payer_Instr_Assignment;
      -- create the payer entity if it does not exist
      IF (l_payer_id IS NULL) THEN
        IBY_FNDCPT_SETUP_PUB.Set_Payer_Attributes
        (
        1.0,
        FND_API.G_FALSE,
        FND_API.G_FALSE,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_payer,
        l_payer_attribs,
        l_payer_id,
        l_result
        );
        IF (l_result.Result_Code <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS) THEN
          x_response := l_result;
          RETURN;
        END IF;
      END IF;


      -- for the combined query cursor, only 1 query condition should be used,
      -- either the assingment id or the (payer id, instr type, instr id)
      -- combination
      --
      IF (NOT p_assignment_attribs.Assignment_Id IS NULL) THEN
        l_assign_id := p_assignment_attribs.Assignment_Id;
      ELSE
        l_instr_id := p_assignment_attribs.Instrument.Instrument_Id;
      END IF;

      OPEN c_instr_assignment(l_assign_id,l_payer_id,
                              p_assignment_attribs.Instrument.Instrument_Type,
                              l_instr_id);
      FETCH c_instr_assignment INTO x_assign_id, l_instrtype;

      IF (c_instr_assignment%NOTFOUND) THEN x_assign_id := NULL; END IF;
      CLOSE c_instr_assignment;


      iby_debug_pub.add('x_assign_id = '|| x_assign_id,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      iby_debug_pub.add('l_assign_id = '|| l_assign_id,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      iby_debug_pub.add('l_instrtype = '|| l_instrtype,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      -- assignment id passed is non-NULL but no instruments found
      IF ((x_assign_id IS NULL) AND (NOT l_assign_id IS NULL)) THEN
        x_response.Result_Code := G_RC_INVALID_INSTR_ASSIGN;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      l_priority := GREATEST(NVL(p_assignment_attribs.Priority,1),1);

      -- only need to shift instrument priorities if this is a new instrument
      -- or if this is an update with a non-NULL priority
      IF (x_assign_id IS NULL) OR
         ((NOT x_assign_id IS NULL) AND (NOT p_assignment_attribs.Priority IS NULL))
      THEN
          --Changing update statement to update priority of elements of only a particular
	      --instrument type instead of all instrument type.
          --Skipping execution with the expensive CONNECT BY clause
	      --when p_assignment_attribs.Priority is NULL or 1,
	      --also l_priority gets 1 when p_assignment_attribs.Priority is NULL

		    UPDATE iby_pmt_instr_uses_all
            SET order_of_preference = order_of_preference + 1,
                last_updated_by =  fnd_global.user_id,
                last_update_date = trunc(SYSDATE),
                last_update_login = fnd_global.login_id,
                object_version_number = object_version_number + 1
            WHERE ext_pmt_party_id = l_payer_id
            AND payment_flow = G_PMT_FLOW_FNDCPT
			AND instrument_type = l_instrtype
            AND order_of_preference >= l_priority;


	  iby_debug_pub.add('SQL%ROWCOUNT = '|| SQL%ROWCOUNT,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      END IF;

      l_last_update := SYSDATE;

      IF (x_assign_id IS NULL) THEN
        SELECT iby_pmt_instr_uses_all_s.nextval
        INTO x_assign_id
        FROM DUAL;

        INSERT INTO iby_pmt_instr_uses_all
          (instrument_payment_use_id, ext_pmt_party_id, instrument_type,
           instrument_id, payment_function, payment_flow, order_of_preference,
           debit_auth_flag, debit_auth_method, debit_auth_reference,
           debit_auth_begin, debit_auth_end, start_date, end_date,
           created_by, creation_date, last_updated_by, last_update_date,
           last_update_login, object_version_number)
        VALUES
          (x_assign_id, l_payer_id,
           p_assignment_attribs.Instrument.Instrument_Type,
           p_assignment_attribs.Instrument.Instrument_Id,
           p_payer.Payment_Function, G_PMT_FLOW_FNDCPT, l_priority,
           null, null, null, null, null,
           NVL(p_assignment_attribs.Start_Date,SYSDATE),
           p_assignment_attribs.End_Date,
           fnd_global.user_id, SYSDATE, fnd_global.user_id, l_last_update,
           fnd_global.login_id, 1);

        l_op_type := 'I';
      ELSE
        UPDATE iby_pmt_instr_uses_all
          SET
            order_of_preference =
              NVL(p_assignment_attribs.Priority,order_of_preference),
            start_date = NVL(p_assignment_attribs.Start_Date,start_date),
            end_date = p_assignment_attribs.End_Date,
            last_updated_by =  fnd_global.user_id,
            last_update_date = l_last_update,
            last_update_login = fnd_global.login_id,
            object_version_number = object_version_number + 1
        WHERE instrument_payment_use_id = x_assign_id;

        l_op_type := 'U';
      END IF;

      iby_debug_pub.add('begin HZ hook',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      IF (NOT p_payer.Account_Site_Id IS NULL) THEN
        l_parent_type := 'CUST_ACCT_SITE_USE';
        l_parent_table := 'HZ_CUST_SITE_USES_ALL';
        l_parent_id := p_payer.Account_Site_Id;
      ELSIF (NOT p_payer.Cust_Account_Id IS NULL) THEN
        l_parent_type := 'CUST_ACCT';
        l_parent_table := 'HZ_CUST_ACCOUNTS';
        l_parent_id := p_payer.Cust_Account_Id;
      END IF;

      SELECT instrument_type
      INTO l_instr_type
      FROM iby_pmt_instr_uses_all
      WHERE instrument_payment_use_id = x_assign_id;

      IF (l_instr_type = 'BANKACCOUNT') THEN
        SELECT party_type INTO l_party_type
        FROM hz_parties WHERE party_id = p_payer.Party_Id;

        HZ_BES_BO_TRACKING_PVT.Create_Bot
        (p_init_msg_list       => fnd_api.g_false,
         p_child_bo_code       => NULL,
         p_child_tbl_name      => 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V',
         p_child_id            => x_assign_id,
         p_child_opr_flag      => l_op_type,
         p_child_update_dt     => l_last_update,
         p_parent_bo_code      => l_parent_type,
         p_parent_tbl_name     => l_parent_table,
         p_parent_id           => l_parent_id,
         p_parent_opr_flag     => NULL,
         p_gparent_bo_code     => l_party_type,
         p_gparent_tbl_name    => 'HZ_PARTIES',
         p_gparent_id          => p_payer.Party_Id,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data
         );
      END IF;

      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Set_Payer_Instr_Assignment;
	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Set_Payer_Instr_Assignment;
	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN
        ROLLBACK TO Set_Payer_Instr_Assignment;
        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );
  END Set_Payer_Instr_Assignment;


  PROCEDURE Get_Payer_Instr_Assignments
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            x_assignments      OUT NOCOPY PmtInstrAssignment_tbl_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Payer_Instr_Assignments';
    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs PayerAttributes_rec_type;
    l_assign_count NUMBER := 0;
    l_prev_msg_count NUMBER;

    CURSOR c_instr_assignments
           (ci_payer_id IN iby_pmt_instr_uses_all.ext_pmt_party_id%TYPE)
    IS
      SELECT instrument_payment_use_id, instrument_type, instrument_id,
        order_of_preference, start_date, end_date
      FROM iby_pmt_instr_uses_all
      WHERE (payment_flow = G_PMT_FLOW_FNDCPT)
        AND (ext_pmt_party_id = ci_payer_id);

  BEGIN

    IF (c_instr_assignments%ISOPEN) THEN
      CLOSE c_instr_assignments;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      l_assign_count := 0;
      FOR assign_rec IN c_instr_assignments(l_payer_id) LOOP
        l_assign_count := l_assign_count + 1;

        x_assignments(l_assign_count).Assignment_Id :=
          assign_rec.instrument_payment_use_id;
        x_assignments(l_assign_count).Instrument.Instrument_Type :=
          assign_rec.instrument_type;
        x_assignments(l_assign_count).Instrument.Instrument_Id :=
          assign_rec.instrument_id;
        x_assignments(l_assign_count).Priority := assign_rec.order_of_preference;
        x_assignments(l_assign_count).Start_Date := assign_rec.start_date;
        x_assignments(l_assign_count).End_Date := assign_rec.end_date;
      END LOOP;

      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;

    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );
  END Get_Payer_Instr_Assignments;


  PROCEDURE Get_Payer_All_Instruments
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_party_id         IN   NUMBER,
            x_instruments      OUT NOCOPY PmtInstrument_tbl_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Payer_All_Assignments';
    l_prev_msg_count NUMBER;

    l_instr_count NUMBER := 0;

    CURSOR c_instr_assignments
           (ci_party_id IN iby_external_payers_all.party_id%TYPE)
    IS
      SELECT DISTINCT u.instrument_type, u.instrument_id
      FROM iby_pmt_instr_uses_all u, iby_external_payers_all p
      WHERE (u.payment_flow = G_PMT_FLOW_FNDCPT)
        AND (u.ext_pmt_party_id = p.ext_payer_id)
        AND (p.party_id = ci_party_id);

  BEGIN

    IF (c_instr_assignments%ISOPEN) THEN
      CLOSE c_instr_assignments;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    l_instr_count := 0;
    FOR assign_rec IN c_instr_assignments(p_party_id) LOOP
      l_instr_count := l_instr_count + 1;

      x_instruments(l_instr_count).Instrument_Type :=
        assign_rec.instrument_type;
      x_instruments(l_instr_count).Instrument_Id :=
        assign_rec.instrument_id;
    END LOOP;

    x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
  END Get_Payer_All_Instruments;


  PROCEDURE Get_Trxn_Appl_Instr_Assign
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_payer_equivalency IN  VARCHAR2 :=
              IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_conditions       IN  IBY_FNDCPT_COMMON_PUB.TrxnContext_rec_type,
            p_result_limit     IN  IBY_FNDCPT_COMMON_PUB.ResultLimit_rec_type,
            x_assignments      OUT NOCOPY PmtInstrAssignment_tbl_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Trxn_Appl_Instr_Assign';
    l_prev_msg_count NUMBER;

    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs PayerAttributes_rec_type;

    l_assign_count NUMBER;

    CURSOR c_instr_assigns
           (ci_payer IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            ci_payer_level IN VARCHAR2,
            ci_payer_equiv IN VARCHAR2,
	    ci_instrument_type IN VARCHAR2)
    IS
      SELECT instrument_payment_use_id, instrument_type, instrument_id,
             order_of_preference, start_date, end_date
        FROM (SELECT instrument_payment_use_id, instrument_type, instrument_id,
                     order_of_preference, start_date, end_date,
                     rank() over (partition by instrument_type, instrument_id
                                  order by order_of_preference, instrument_payment_use_id) dup_rank
                FROM iby_pmt_instr_uses_all
               WHERE (payment_flow = G_PMT_FLOW_FNDCPT)
                 AND instrument_type = NVL(ci_instrument_type,instrument_type)
                 AND sysdate >= start_date
                 AND sysdate < NVL(end_date, sysdate+1)
                 AND ext_pmt_party_id IN
                     (SELECT ext_payer_id
                        FROM iby_external_payers_all
                       WHERE (payment_function = ci_payer.Payment_Function)
                         AND (party_id = ci_payer.Party_Id)
                         AND (IBY_FNDCPT_COMMON_PUB.Compare_Payer
                               (ci_payer.org_type, ci_payer.org_id,
                                ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
                                ci_payer_level,ci_payer_equiv,org_type,org_id,
                                cust_account_id,acct_site_use_id) = 'T')
                     )) x
       WHERE x.dup_rank = 1
       ORDER BY order_of_preference;
  BEGIN

    IF (c_instr_assigns%ISOPEN) THEN
      CLOSE c_instr_assigns;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    IF (l_payer_level = IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER) THEN
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_INVALID_PAYER;
    ELSE
      l_assign_count := 1;
      FOR assign_rec IN c_instr_assigns(p_payer,l_payer_level,p_payer_equivalency,p_conditions.payment_instrtype)
      LOOP
        x_assignments(l_assign_count).Assignment_Id := assign_rec.instrument_payment_use_id;
        x_assignments(l_assign_count).Instrument.Instrument_Type := assign_rec.instrument_type;
        x_assignments(l_assign_count).Instrument.Instrument_Id := assign_rec.instrument_id;
        x_assignments(l_assign_count).Priority := assign_rec.order_of_preference;
        x_assignments(l_assign_count).Start_Date := assign_rec.start_date;
        x_assignments(l_assign_count).End_Date := assign_rec.end_date;
        l_assign_count := l_assign_count + 1;

	EXIT WHEN p_result_limit.default_flag='Y';
      END LOOP;

      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

  END Get_Trxn_Appl_Instr_Assign;

   PROCEDURE Create_Card_Wrapper
          (p_commit           IN   VARCHAR2,
           p_owner_id         IN   iby_creditcard.card_owner_id%TYPE,
           p_holder_name      IN   iby_creditcard.chname%TYPE,
           p_billing_address_id IN iby_creditcard.addressid%TYPE,
           p_address_type     IN   VARCHAR2,
           p_billing_zip      IN   iby_creditcard.billing_addr_postal_code%TYPE,
           p_billing_country  IN   iby_creditcard.bill_addr_territory_code%TYPE,
           p_card_number      IN   iby_creditcard.ccnumber%TYPE,
           p_expiry_date      IN   iby_creditcard.expirydate%TYPE,
           p_instr_type       IN   iby_creditcard.instrument_type%TYPE,
           p_pcard_flag       IN   iby_creditcard.purchasecard_flag%TYPE,
           p_pcard_type       IN   iby_creditcard.purchasecard_subtype%TYPE,
           p_issuer           IN   iby_creditcard.card_issuer_code%TYPE,
           p_fi_name          IN   iby_creditcard.finame%TYPE,
           p_single_use       IN   iby_creditcard.single_use_flag%TYPE,
           p_info_only        IN   iby_creditcard.information_only_flag%TYPE,
           p_purpose          IN   iby_creditcard.card_purpose%TYPE,
           p_desc             IN   iby_creditcard.description%TYPE,
           p_active_flag      IN   iby_creditcard.active_flag%TYPE,
           p_inactive_date    IN   iby_creditcard.inactive_date%TYPE,
           p_sys_sec_key      IN   iby_security_pkg.DES3_KEY_TYPE,
	   p_attribute_category IN iby_creditcard.attribute_category%TYPE,
	   p_attribute1	IN 	iby_creditcard.attribute1%TYPE,
	   p_attribute2	IN 	iby_creditcard.attribute2%TYPE,
	   p_attribute3	IN 	iby_creditcard.attribute3%TYPE,
	   p_attribute4	IN 	iby_creditcard.attribute4%TYPE,
	   p_attribute5	IN 	iby_creditcard.attribute5%TYPE,
	   p_attribute6	IN 	iby_creditcard.attribute6%TYPE,
	   p_attribute7	IN 	iby_creditcard.attribute7%TYPE,
	   p_attribute8	IN 	iby_creditcard.attribute8%TYPE,
	   p_attribute9	IN 	iby_creditcard.attribute9%TYPE,
	   p_attribute10	IN 	iby_creditcard.attribute10%TYPE,
	   p_attribute11	IN 	iby_creditcard.attribute11%TYPE,
	   p_attribute12	IN 	iby_creditcard.attribute12%TYPE,
	   p_attribute13	IN 	iby_creditcard.attribute13%TYPE,
	   p_attribute14	IN 	iby_creditcard.attribute14%TYPE,
	   p_attribute15	IN 	iby_creditcard.attribute15%TYPE,
	   p_attribute16	IN 	iby_creditcard.attribute16%TYPE,
	   p_attribute17	IN 	iby_creditcard.attribute17%TYPE,
	   p_attribute18	IN 	iby_creditcard.attribute18%TYPE,
	   p_attribute19	IN 	iby_creditcard.attribute19%TYPE,
	   p_attribute20	IN 	iby_creditcard.attribute20%TYPE,
	   p_attribute21	IN 	iby_creditcard.attribute21%TYPE,
	   p_attribute22	IN 	iby_creditcard.attribute22%TYPE,
	   p_attribute23	IN 	iby_creditcard.attribute23%TYPE,
	   p_attribute24	IN 	iby_creditcard.attribute24%TYPE,
	   p_attribute25	IN 	iby_creditcard.attribute25%TYPE,
	   p_attribute26	IN 	iby_creditcard.attribute26%TYPE,
	   p_attribute27	IN 	iby_creditcard.attribute27%TYPE,
	   p_attribute28	IN 	iby_creditcard.attribute28%TYPE,
	   p_attribute29	IN 	iby_creditcard.attribute29%TYPE,
	   p_attribute30	IN 	iby_creditcard.attribute30%TYPE,
           x_result_code      OUT  NOCOPY VARCHAR2,
           x_return_status    OUT  NOCOPY VARCHAR2,
           x_instr_id         OUT  NOCOPY iby_creditcard.instrid%TYPE
          )
IS
   -- create a record type and populate it
        x_response         IBY_FNDCPT_COMMON_PUB.Result_rec_type;
        x_card_instrument  CreditCard_rec_type;
        x_msg_count        NUMBER;
        x_msg_data         VARCHAR2(3000);
Begin
       x_card_instrument.Owner_Id := p_owner_id;
       x_card_instrument.Card_Holder_Name := p_holder_name;
       x_card_instrument.Billing_Address_Id  := p_billing_address_id;
       x_card_instrument.Address_Type  := p_address_type;
       x_card_instrument.Billing_Postal_Code  := p_billing_zip;
       x_card_instrument.Billing_Address_Territory := p_billing_country;
       x_card_instrument.Card_Number := p_card_number;
       x_card_instrument.Expiration_Date := p_expiry_date;
       x_card_instrument.Instrument_Type := p_instr_type;
       x_card_instrument.PurchaseCard_Flag := p_pcard_flag;
       x_card_instrument.PurchaseCard_SubType := p_pcard_type;
       x_card_instrument.FI_Name := p_fi_name;
       x_card_instrument.Single_Use_Flag := p_single_use;
       x_card_instrument.Info_Only_Flag := p_info_only;
       x_card_instrument.Card_Purpose := p_purpose;
       x_card_instrument.Card_Description := p_desc;
       x_card_instrument.Active_Flag := p_active_flag;
       x_card_instrument.Inactive_Date := p_inactive_date;
       x_card_instrument.card_issuer := p_issuer;
       x_card_instrument.attribute_category := p_attribute_category;
       x_card_instrument.attribute1 := p_attribute1;
       x_card_instrument.attribute2 := p_attribute2;
       x_card_instrument.attribute3 := p_attribute3;
       x_card_instrument.attribute4 := p_attribute4;
       x_card_instrument.attribute5 := p_attribute5;
       x_card_instrument.attribute6 := p_attribute6;
       x_card_instrument.attribute7 := p_attribute7;
       x_card_instrument.attribute8 := p_attribute8;
       x_card_instrument.attribute9 := p_attribute9;
       x_card_instrument.attribute10 := p_attribute10;
       x_card_instrument.attribute11 := p_attribute11;
       x_card_instrument.attribute12 := p_attribute12;
       x_card_instrument.attribute13 := p_attribute13;
       x_card_instrument.attribute14 := p_attribute14;
       x_card_instrument.attribute15 := p_attribute15;
       x_card_instrument.attribute16 := p_attribute16;
       x_card_instrument.attribute17 := p_attribute17;
       x_card_instrument.attribute18 := p_attribute18;
       x_card_instrument.attribute19 := p_attribute19;
       x_card_instrument.attribute20 := p_attribute20;
       x_card_instrument.attribute21 := p_attribute21;
       x_card_instrument.attribute22 := p_attribute22;
       x_card_instrument.attribute23 := p_attribute23;
       x_card_instrument.attribute24 := p_attribute24;
       x_card_instrument.attribute25 := p_attribute25;
       x_card_instrument.attribute26 := p_attribute26;
       x_card_instrument.attribute27 := p_attribute27;
       x_card_instrument.attribute28 := p_attribute28;
       x_card_instrument.attribute29 := p_attribute29;
       x_card_instrument.attribute30 := p_attribute30;


        -- call Create_Card
        Create_Card(1.0,
            FND_API.G_FALSE,
            p_commit,
            x_return_status,
            x_msg_count,
            x_msg_data,
            x_card_instrument,
            x_instr_id,
            x_response);
        -- Map things back
        x_result_code := x_response.Result_Code;

End Create_Card_Wrapper;


  PROCEDURE Create_Card
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_card_instrument  IN   CreditCard_rec_type,
            x_card_id          OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS

    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Create_Card';
    l_prev_msg_count NUMBER;

    lx_result_code VARCHAR2(30);
    lx_result      IBY_FNDCPT_COMMON_PUB.Result_rec_type;
    lx_card_rec    CreditCard_rec_type;

    l_info_only    iby_creditcard.information_only_flag%TYPE := NULL;
    l_sec_mode     iby_sys_security_options.cc_encryption_mode%TYPE;
    l_cc_reg       IBY_INSTRREG_PUB.CreditCardInstr_rec_type;
    l_instr_reg    IBY_INSTRREG_PUB.PmtInstr_rec_type;

    l_billing_site      hz_party_site_uses.party_site_use_id%TYPE;

    l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

    CURSOR c_sec_mode
    IS
      SELECT cc_encryption_mode
      FROM iby_sys_security_options;

  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (c_sec_mode%ISOPEN) THEN CLOSE c_sec_mode; END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    --SAVEPOINT Create_Card;

    IBY_FNDCPT_SETUP_PUB.Card_Exists
    (
    1.0,
    FND_API.G_FALSE,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_card_instrument.Owner_Id,
    p_card_instrument.Card_Number,
    lx_card_rec,
    lx_result,
    NVL(p_card_instrument.Instrument_Type,IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_CREDITCARD)
    );

    iby_debug_pub.add('fetched card id:='||lx_card_rec.Card_Id,
      iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

    IF (lx_card_rec.Card_Id IS NULL) THEN

      iby_debug_pub.add('p_card_instrument.Register_Invalid_Card: '|| p_card_instrument.Register_Invalid_Card,
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      -- validate billing address information
      IF (NOT Validate_CC_Billing(FND_API.G_FALSE,p_card_instrument)) THEN
        x_response.Result_Code := iby_creditcard_pkg.G_RC_INVALID_ADDRESS;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      -- lmallick (bug# 8721435)
      -- These validations have been moved from iby_creditcard_pkg because the TCA
      -- data might not have been committed to the db before invoking the Create_card API
      iby_debug_pub.add('Starting address validation ..',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      -- If Site use id is already provied then no need to call get_billing address
      iby_debug_pub.add('p_card_instrument.Address_Type = '||p_card_instrument.Address_Type,
                                        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      IF (p_card_instrument.Address_Type = IBY_CREDITCARD_PKG.G_PARTY_SITE_USE_ID) AND
         (NOT (p_card_instrument.Billing_Address_Id  IS NULL)) THEN
        l_billing_site := p_card_instrument.Billing_Address_Id;
      ELSE
        IF (p_card_instrument.Billing_Address_Id = FND_API.G_MISS_NUM ) THEN
           l_billing_site := FND_API.G_MISS_NUM;
        ELSIF (NOT (p_card_instrument.Billing_Address_Id IS NULL)) THEN
           l_billing_site :=
	     IBY_CREDITCARD_PKG.Get_Billing_Site(p_card_instrument.Billing_Address_Id,
	                                         p_card_instrument.Owner_Id);
           IF (l_billing_site IS NULL) THEN
              x_response.Result_Code := IBY_CREDITCARD_PKG.G_RC_INVALID_ADDRESS;
	      iby_debug_pub.add('Invalid Billing site.',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
              iby_fndcpt_common_pub.Prepare_Result
             (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
              RETURN;
           END IF;
        END IF;
      END IF;

      iby_debug_pub.add('l_billing_site = '||l_billing_site,
                                        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      IF (NOT ( (p_card_instrument.Billing_Address_Territory IS NULL)
            OR (p_card_instrument.Billing_Address_Territory = FND_API.G_MISS_CHAR) )
         )
      THEN
        IF (NOT iby_utility_pvt.Validate_Territory(p_card_instrument.Billing_Address_Territory)) THEN
          x_response.Result_Code := IBY_CREDITCARD_PKG.G_RC_INVALID_ADDRESS;
	  iby_debug_pub.add('Invalid Territory '|| p_card_instrument.Billing_Address_Territory,
	                 iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	  iby_fndcpt_common_pub.Prepare_Result
          (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
          RETURN;
        END IF;
      END IF;

      IF (NOT p_card_instrument.Owner_Id IS NULL) THEN
        IF (NOT iby_utility_pvt.validate_party_id(p_card_instrument.Owner_Id)) THEN
          x_response.Result_Code := IBY_CREDITCARD_PKG.G_RC_INVALID_PARTY;
	  iby_debug_pub.add('Invalid Owner party '||p_card_instrument.Owner_Id,
	                                   iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	  iby_fndcpt_common_pub.Prepare_Result
          (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
          RETURN;
        END IF;
      END IF;
      -- End of Bug fix for 8721435 --

      OPEN c_sec_mode;
      FETCH c_sec_mode INTO l_sec_mode;
      CLOSE c_sec_mode;

      IF (l_sec_mode = iby_security_pkg.G_ENCRYPT_MODE_INSTANT) THEN

        iby_debug_pub.add('online registration',
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

        l_cc_reg.FIName := p_card_instrument.FI_Name;
        l_cc_reg.CC_Type := p_card_instrument.Card_Issuer;
        l_cc_reg.CC_Num := p_card_instrument.Card_Number;
        l_cc_reg.CC_ExpDate := p_card_instrument.Expiration_Date;
        l_cc_reg.Instrument_Type := NVL(p_card_instrument.Instrument_Type,IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_CREDITCARD);
        l_cc_reg.Owner_Id := p_card_instrument.Owner_Id;
        l_cc_reg.CC_HolderName := p_card_instrument.Card_Holder_Name;
        l_cc_reg.CC_Desc := p_card_instrument.Card_Description;
        l_cc_reg.Billing_Address_Id := l_billing_site;
        l_cc_reg.Billing_PostalCode := p_card_instrument.Billing_Postal_Code;
        l_cc_reg.Billing_Country := p_card_instrument.Billing_Address_Territory;
        l_cc_reg.Single_Use_Flag := p_card_instrument.Single_Use_Flag;
        l_cc_reg.Info_Only_Flag := p_card_instrument.Info_Only_Flag;
        l_cc_reg.Card_Purpose := p_card_instrument.Card_Purpose;
        l_cc_reg.CC_Desc := p_card_instrument.Card_Description;
        l_cc_reg.Active_Flag := p_card_instrument.Active_Flag;
        l_cc_reg.Inactive_Date := p_card_instrument.Inactive_Date;

        -- lmallick
	-- New parameter introduced to allow registration of invalid credit cards
	-- This is currently used by the OIE product and its only this product that
	-- passes the value as 'Y'
	l_cc_reg.Register_Invalid_Card := p_card_instrument.Register_Invalid_Card;

        l_instr_reg.CreditCardInstr := l_cc_reg;
        l_instr_reg.InstrumentType := IBY_INSTRREG_PUB.C_INSTRTYPE_CREDITCARD;

	iby_debug_pub.add('before calling OraInstrAdd',
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

        IBY_INSTRREG_PUB.OraInstrAdd
        (1.0, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
         l_instr_reg, x_return_status, x_msg_count, x_msg_data,
         x_card_id, lx_result
        );

        -- should not be a validation error at this point
        IF ((NVL(x_card_id,-1)<0))
--OR (x_return_status <> FND_API.G_RET_STS_ERROR))
        THEN
          iby_debug_pub.add('instrument reg failed',
            iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
          iby_debug_pub.add('result code:=' || lx_result.Result_Code,
            iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
          IF (lx_result.Result_Code IS NULL) THEN
            x_response.Result_Code := 'COMMUNICATION_ERROR';
--IBY_FNDCPT_COMMON_PUB.G_RC_GENERIC_SYS_ERROR;
            iby_fndcpt_common_pub.Prepare_Result
            (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,
             x_response);
          ELSE
            x_response.Result_Code := lx_result.Result_Code;

            iby_fndcpt_common_pub.Prepare_Result
            (IBY_INSTRREG_PUB.G_INTERFACE_CODE,lx_result.Result_Message,
             l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,
             x_response);
          END IF;
          RETURN;
        END IF;
      ELSE
        iby_debug_pub.add('database registration',
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

        iby_creditcard_pkg.Create_Card
        (FND_API.G_FALSE,
         p_card_instrument.Owner_Id, p_card_instrument.Card_Holder_Name,
         l_billing_site,
         p_card_instrument.Address_Type,
         p_card_instrument.Billing_Postal_Code,
         p_card_instrument.Billing_Address_Territory,
         p_card_instrument.Card_Number, p_card_instrument.Expiration_Date,
         NVL(p_card_instrument.Instrument_Type,IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_CREDITCARD),
         p_card_instrument.PurchaseCard_Flag,
         p_card_instrument.PurchaseCard_SubType, p_card_instrument.Card_Issuer,
         p_card_instrument.FI_Name, p_card_instrument.Single_Use_Flag,
         p_card_instrument.Info_Only_Flag, p_card_instrument.Card_Purpose,
         p_card_instrument.Card_Description, p_card_instrument.Active_Flag,
         p_card_instrument.Inactive_Date, NULL,
 	 p_card_instrument.attribute_category,
	 p_card_instrument.attribute1,
	 p_card_instrument.attribute2,
	 p_card_instrument.attribute3,
	 p_card_instrument.attribute4,
	 p_card_instrument.attribute5,
	 p_card_instrument.attribute6,
	 p_card_instrument.attribute7,
	 p_card_instrument.attribute8,
	 p_card_instrument.attribute9,
	 p_card_instrument.attribute10,
	 p_card_instrument.attribute11,
	 p_card_instrument.attribute12,
	 p_card_instrument.attribute13,
	 p_card_instrument.attribute14,
	 p_card_instrument.attribute15,
	 p_card_instrument.attribute16,
	 p_card_instrument.attribute17,
	 p_card_instrument.attribute18,
	 p_card_instrument.attribute19,
	 p_card_instrument.attribute20,
	 p_card_instrument.attribute21,
	 p_card_instrument.attribute22,
	 p_card_instrument.attribute23,
	 p_card_instrument.attribute24,
	 p_card_instrument.attribute25,
	 p_card_instrument.attribute26,
	 p_card_instrument.attribute27,
	 p_card_instrument.attribute28,
	 p_card_instrument.attribute29,
	 p_card_instrument.attribute30,
	 lx_result_code, x_card_id,
         p_card_instrument.Register_Invalid_Card,
	 fnd_global.user_id,
         fnd_global.login_id
        );
      END IF;

    ELSE

      -- card cannot become info only once this flag is turned off
      IF (NOT p_card_instrument.Info_Only_Flag = 'Y') THEN
        l_info_only := p_card_instrument.Info_Only_Flag;
      END IF;

      -- validate billing address information
      IF (NOT Validate_CC_Billing(FND_API.G_TRUE,p_card_instrument)) THEN
        x_response.Result_Code := iby_creditcard_pkg.G_RC_INVALID_ADDRESS;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;
      -- validate expiration date
      IF (TRUNC(p_card_instrument.Expiration_Date,'DD') < TRUNC(SYSDATE,'DD'))
      THEN
        x_response.Result_Code := iby_creditcard_pkg.G_RC_INVALID_CCEXPIRY;
        iby_fndcpt_common_pub.Prepare_Result
        (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
        RETURN;
      END IF;

      iby_creditcard_pkg.Update_Card
      (FND_API.G_FALSE, lx_card_rec.Card_Id, p_card_instrument.Owner_Id,
       p_card_instrument.Card_Holder_Name,
       p_card_instrument.Billing_Address_Id,
       p_card_instrument.Address_Type,
       p_card_instrument.Billing_Postal_Code,
       p_card_instrument.Billing_Address_Territory,
       p_card_instrument.Expiration_Date, p_card_instrument.Instrument_Type,
       p_card_instrument.PurchaseCard_Flag, p_card_instrument.PurchaseCard_SubType,
       p_card_instrument.FI_Name, p_card_instrument.Single_Use_Flag,
       l_info_only, p_card_instrument.Card_Purpose,
       p_card_instrument.Card_Description, p_card_instrument.Active_Flag,
       NVL(p_card_instrument.Inactive_Date,FND_API.G_MISS_DATE),
     p_card_instrument.attribute_category,
     p_card_instrument.attribute1,  p_card_instrument.attribute2,
     p_card_instrument.attribute3,  p_card_instrument.attribute4,
     p_card_instrument.attribute5,  p_card_instrument.attribute6,
     p_card_instrument.attribute7,  p_card_instrument.attribute8,
     p_card_instrument.attribute9,  p_card_instrument.attribute10,
     p_card_instrument.attribute11,  p_card_instrument.attribute12,
     p_card_instrument.attribute13,  p_card_instrument.attribute14,
     p_card_instrument.attribute15,  p_card_instrument.attribute16,
     p_card_instrument.attribute17,  p_card_instrument.attribute18,
     p_card_instrument.attribute19,  p_card_instrument.attribute20,
     p_card_instrument.attribute21,  p_card_instrument.attribute22,
     p_card_instrument.attribute23,  p_card_instrument.attribute24,
     p_card_instrument.attribute25,  p_card_instrument.attribute26,
     p_card_instrument.attribute27,  p_card_instrument.attribute28,
     p_card_instrument.attribute29,  p_card_instrument.attribute30,
     lx_result_code,
     null);
       x_card_id := lx_card_rec.Card_Id;
    END IF;

    x_response.Result_Code := NVL(lx_result_code,IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS);
    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_Card;
	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO Create_Card;
	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN
        --ROLLBACK TO Create_Card;
        iby_debug_pub.add(debug_msg => 'In OTHERS Exception'||SQLERRM,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

  END Create_Card;

  PROCEDURE Update_Card_Wrapper
      (
              p_commit           IN   VARCHAR2,
              p_instr_id         IN   iby_creditcard.instrid%TYPE,
              p_owner_id         IN   iby_creditcard.card_owner_id%TYPE,
              p_holder_name      IN   iby_creditcard.chname%TYPE,
              p_billing_address_id IN iby_creditcard.addressid%TYPE,
              p_address_type     IN   VARCHAR2,
              p_billing_zip      IN   iby_creditcard.billing_addr_postal_code%TYPE,
              p_billing_country  IN   iby_creditcard.bill_addr_territory_code%TYPE,
              p_expiry_date      IN   iby_creditcard.expirydate%TYPE,
              p_instr_type       IN   iby_creditcard.instrument_type%TYPE,
              p_pcard_flag       IN   iby_creditcard.purchasecard_flag%TYPE,
              p_pcard_type       IN   iby_creditcard.purchasecard_subtype%TYPE,
              p_fi_name          IN   iby_creditcard.finame%TYPE,
              p_single_use       IN   iby_creditcard.single_use_flag%TYPE,
              p_info_only        IN   iby_creditcard.information_only_flag%TYPE,
              p_purpose          IN   iby_creditcard.card_purpose%TYPE,
              p_desc             IN   iby_creditcard.description%TYPE,
              p_active_flag      IN   iby_creditcard.active_flag%TYPE,
              p_inactive_date    IN   iby_creditcard.inactive_date%TYPE,
	   p_attribute_category IN iby_creditcard.attribute_category%TYPE,
	   p_attribute1	IN 	iby_creditcard.attribute1%TYPE,
	   p_attribute2	IN 	iby_creditcard.attribute2%TYPE,
	   p_attribute3	IN 	iby_creditcard.attribute3%TYPE,
	   p_attribute4	IN 	iby_creditcard.attribute4%TYPE,
	   p_attribute5	IN 	iby_creditcard.attribute5%TYPE,
	   p_attribute6	IN 	iby_creditcard.attribute6%TYPE,
	   p_attribute7	IN 	iby_creditcard.attribute7%TYPE,
	   p_attribute8	IN 	iby_creditcard.attribute8%TYPE,
	   p_attribute9	IN 	iby_creditcard.attribute9%TYPE,
	   p_attribute10	IN 	iby_creditcard.attribute10%TYPE,
	   p_attribute11	IN 	iby_creditcard.attribute11%TYPE,
	   p_attribute12	IN 	iby_creditcard.attribute12%TYPE,
	   p_attribute13	IN 	iby_creditcard.attribute13%TYPE,
	   p_attribute14	IN 	iby_creditcard.attribute14%TYPE,
	   p_attribute15	IN 	iby_creditcard.attribute15%TYPE,
	   p_attribute16	IN 	iby_creditcard.attribute16%TYPE,
	   p_attribute17	IN 	iby_creditcard.attribute17%TYPE,
	   p_attribute18	IN 	iby_creditcard.attribute18%TYPE,
	   p_attribute19	IN 	iby_creditcard.attribute19%TYPE,
	   p_attribute20	IN 	iby_creditcard.attribute20%TYPE,
	   p_attribute21	IN 	iby_creditcard.attribute21%TYPE,
	   p_attribute22	IN 	iby_creditcard.attribute22%TYPE,
	   p_attribute23	IN 	iby_creditcard.attribute23%TYPE,
	   p_attribute24	IN 	iby_creditcard.attribute24%TYPE,
	   p_attribute25	IN 	iby_creditcard.attribute25%TYPE,
	   p_attribute26	IN 	iby_creditcard.attribute26%TYPE,
	   p_attribute27	IN 	iby_creditcard.attribute27%TYPE,
	   p_attribute28	IN 	iby_creditcard.attribute28%TYPE,
	   p_attribute29	IN 	iby_creditcard.attribute29%TYPE,
	   p_attribute30	IN 	iby_creditcard.attribute30%TYPE,
              x_result_code      OUT NOCOPY VARCHAR2,
              x_return_status    OUT  NOCOPY VARCHAR2
      )
  IS
        -- create a record type and populate it
        x_response         IBY_FNDCPT_COMMON_PUB.Result_rec_type;
        x_card_instrument  CreditCard_rec_type;
        x_msg_count        NUMBER;
        x_msg_data         VARCHAR2(3000);
Begin
       x_card_instrument.Card_Id := p_instr_id;
       x_card_instrument.Owner_Id := p_owner_id;
       x_card_instrument.Card_Holder_Name := p_holder_name;
       x_card_instrument.Billing_Address_Id  := p_billing_address_id;
       x_card_instrument.Address_Type  := p_address_type;
       x_card_instrument.Billing_Postal_Code  := p_billing_zip;
       x_card_instrument.Billing_Address_Territory := p_billing_country;
       x_card_instrument.Expiration_Date := p_expiry_date;
       x_card_instrument.Instrument_Type := p_instr_type;
       x_card_instrument.PurchaseCard_Flag := p_pcard_flag;
       x_card_instrument.PurchaseCard_SubType := p_pcard_type;
       x_card_instrument.FI_Name := p_fi_name;
       x_card_instrument.Single_Use_Flag := p_single_use;
       x_card_instrument.Info_Only_Flag := p_info_only;
       x_card_instrument.Card_Purpose := p_purpose;
       x_card_instrument.Card_Description := p_desc;
       x_card_instrument.Active_Flag := p_active_flag;
       x_card_instrument.Inactive_Date := p_inactive_date;
       x_card_instrument.attribute_category := p_attribute_category;
       x_card_instrument.attribute1 := p_attribute1;
       x_card_instrument.attribute2 := p_attribute2;
       x_card_instrument.attribute3 := p_attribute3;
       x_card_instrument.attribute4 := p_attribute4;
       x_card_instrument.attribute5 := p_attribute5;
       x_card_instrument.attribute6 := p_attribute6;
       x_card_instrument.attribute7 := p_attribute7;
       x_card_instrument.attribute8 := p_attribute8;
       x_card_instrument.attribute9 := p_attribute9;
       x_card_instrument.attribute10 := p_attribute10;
       x_card_instrument.attribute11 := p_attribute11;
       x_card_instrument.attribute12 := p_attribute12;
       x_card_instrument.attribute13 := p_attribute13;
       x_card_instrument.attribute14 := p_attribute14;
       x_card_instrument.attribute15 := p_attribute15;
       x_card_instrument.attribute16 := p_attribute16;
       x_card_instrument.attribute17 := p_attribute17;
       x_card_instrument.attribute18 := p_attribute18;
       x_card_instrument.attribute19 := p_attribute19;
       x_card_instrument.attribute20 := p_attribute20;
       x_card_instrument.attribute21 := p_attribute21;
       x_card_instrument.attribute22 := p_attribute22;
       x_card_instrument.attribute23 := p_attribute23;
       x_card_instrument.attribute24 := p_attribute24;
       x_card_instrument.attribute25 := p_attribute25;
       x_card_instrument.attribute26 := p_attribute26;
       x_card_instrument.attribute27 := p_attribute27;
       x_card_instrument.attribute28 := p_attribute28;
       x_card_instrument.attribute29 := p_attribute29;
       x_card_instrument.attribute30 := p_attribute30;


        -- call Update_Card
        Update_Card(1.0,
            FND_API.G_FALSE,
            p_commit,
            x_return_status,
            x_msg_count,
            x_msg_data,
            x_card_instrument,
            x_response);
        -- Map things back
        x_result_code := x_response.Result_Code;

  END Update_Card_Wrapper;

  PROCEDURE Update_Card
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_card_instrument  IN   CreditCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS

    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Update_Card';
    l_prev_msg_count NUMBER;

    lx_result_code VARCHAR2(30);

    l_info_only    iby_creditcard.information_only_flag%TYPE := NULL;

  BEGIN
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    SAVEPOINT Update_Card;

    -- card cannot become info only once this flag is turned off
    IF (NOT p_card_instrument.Info_Only_Flag = 'Y') THEN
      l_info_only := p_card_instrument.Info_Only_Flag;
    END IF;
    -- validate billing address information
    IF (NOT Validate_CC_Billing(FND_API.G_TRUE,p_card_instrument)) THEN
      x_response.Result_Code := iby_creditcard_pkg.G_RC_INVALID_ADDRESS;
      iby_fndcpt_common_pub.Prepare_Result
      (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
      RETURN;
    END IF;

    iby_creditcard_pkg.Update_Card
    (FND_API.G_FALSE, p_card_instrument.Card_Id, p_card_instrument.Owner_Id,
     p_card_instrument.Card_Holder_Name,
     p_card_instrument.Billing_Address_Id,
     p_card_instrument.Address_Type,
     p_card_instrument.Billing_Postal_Code,
     p_card_instrument.Billing_Address_Territory,
     p_card_instrument.Expiration_Date, p_card_instrument.Instrument_Type,
     p_card_instrument.PurchaseCard_Flag, p_card_instrument.PurchaseCard_SubType,
     p_card_instrument.FI_Name, p_card_instrument.Single_Use_Flag,
     l_info_only, p_card_instrument.Card_Purpose,
     p_card_instrument.Card_Description, p_card_instrument.Active_Flag,
     p_card_instrument.Inactive_Date,
     p_card_instrument.attribute_category,
     p_card_instrument.attribute1,  p_card_instrument.attribute2,
     p_card_instrument.attribute3,  p_card_instrument.attribute4,
     p_card_instrument.attribute5,  p_card_instrument.attribute6,
     p_card_instrument.attribute7,  p_card_instrument.attribute8,
     p_card_instrument.attribute9,  p_card_instrument.attribute10,
     p_card_instrument.attribute11,  p_card_instrument.attribute12,
     p_card_instrument.attribute13,  p_card_instrument.attribute14,
     p_card_instrument.attribute15,  p_card_instrument.attribute16,
     p_card_instrument.attribute17,  p_card_instrument.attribute18,
     p_card_instrument.attribute19,  p_card_instrument.attribute20,
     p_card_instrument.attribute21,  p_card_instrument.attribute22,
     p_card_instrument.attribute23,  p_card_instrument.attribute24,
     p_card_instrument.attribute25,  p_card_instrument.attribute26,
     p_card_instrument.attribute27,  p_card_instrument.attribute28,
     p_card_instrument.attribute29,  p_card_instrument.attribute30,
     lx_result_code,
     p_card_instrument.Register_Invalid_Card);


    x_response.Result_Code :=
      NVL(lx_result_code,IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS);
    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Update_Card;
	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_Card;
	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN
        ROLLBACK TO Update_Card;
        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

  END Update_Card;

  PROCEDURE Get_Card
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_card_id               NUMBER,
            x_card_instrument  OUT NOCOPY CreditCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Get_Card';
    l_prev_msg_count NUMBER;

    l_card_count NUMBER;

    CURSOR c_card(ci_card_id IN iby_creditcard.instrid%TYPE)
    IS
      SELECT card_owner_id, chname, addressid, masked_cc_number,
        expirydate, DECODE(expirydate, null,expired_flag, decode(sign(expirydate-sysdate),-1,'Y','N')),
	instrument_type,purchasecard_subtype, card_issuer_code, finame, single_use_flag,
        information_only_flag, card_purpose, description, inactive_date
      FROM iby_creditcard
      WHERE (instrid = ci_card_id);
  BEGIN
    IF (c_card%ISOPEN) THEN
      CLOSE c_card;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    OPEN c_card(p_card_id);
    FETCH c_card INTO x_card_instrument.Owner_Id, x_card_instrument.Card_Holder_Name,
      x_card_instrument.Billing_Address_Id, x_card_instrument.Card_Number,
      x_card_instrument.Expiration_Date,
      x_card_instrument.Expired_Flag, x_card_instrument.Instrument_Type,
      x_card_instrument.Purchasecard_Subtype, x_card_instrument.Card_Issuer,
      x_card_instrument.FI_Name, x_card_instrument.Single_Use_Flag,
      x_card_instrument.Info_Only_Flag, x_card_instrument.Card_Purpose,
      x_card_instrument.Card_Description, x_card_instrument.Inactive_Date;

    IF (c_card%NOTFOUND) THEN
       x_response.Result_Code := G_RC_INVALID_INSTRUMENT;
    ELSE
       x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
       x_card_instrument.Card_Id := p_card_id;
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
  END;

  PROCEDURE Card_Exists
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_owner_id              NUMBER,
            p_card_number           VARCHAR2,
            x_card_instrument  OUT NOCOPY CreditCard_rec_type,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type,
            p_card_instr_type       VARCHAR2 DEFAULT NULL
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Card_Exists';
    l_prev_msg_count NUMBER;

    l_card_id   iby_creditcard.instrid%TYPE;
    l_cc_hash1  iby_creditcard.cc_number_hash1%TYPE;
    l_cc_hash2  iby_creditcard.cc_number_hash2%TYPE;
    l_char_allowed  VARCHAR2(1) := 'N';
    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(200);
    lx_cc_number        iby_creditcard.ccnumber%TYPE;
    lx_result           IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    CURSOR c_card
    (ci_cc_hash1 IN iby_creditcard.cc_number_hash1%TYPE,
     ci_cc_hash2 IN iby_creditcard.cc_number_hash2%TYPE,
     ci_card_owner IN iby_creditcard.card_owner_id%TYPE
    )
    IS
      SELECT instrid
      FROM iby_creditcard
      WHERE (cc_number_hash1 = ci_cc_hash1)
        AND (cc_number_hash2 = ci_cc_hash2)
        AND ( (card_owner_id = NVL(ci_card_owner,card_owner_id))
          OR (card_owner_id IS NULL AND ci_card_owner IS NULL) )
        AND (NVL(single_use_flag,'N')='N');
  BEGIN

    IF (c_card%ISOPEN) THEN
      CLOSE c_card;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;
    IF (nvl(p_card_instr_type,IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_CREDITCARD ) = IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_PAYMENTCARD) THEN
          l_char_allowed := 'Y';
    END IF;

    iby_cc_validate.StripCC
    (1.0, FND_API.G_FALSE, p_card_number,
     lx_return_status, lx_msg_count, lx_msg_data, lx_cc_number
    );

    IF (lx_cc_number IS NULL) THEN
      x_response.Result_Code := iby_creditcard_pkg.G_RC_INVALID_CCNUMBER;
      iby_fndcpt_common_pub.Prepare_Result
      (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);
      RETURN;
    END IF;

    l_cc_hash1 := iby_security_pkg.get_hash(lx_cc_number,'F');
    l_cc_hash2 := iby_security_pkg.get_hash(lx_cc_number,'T');

    OPEN c_card(l_cc_hash1,l_cc_hash2,p_owner_id);
    FETCH c_card INTO l_card_id;
    CLOSE c_card;

    IF (l_card_id IS NULL) THEN
       x_response.Result_Code := G_RC_UNKNOWN_CARD;
    ELSE
      IBY_FNDCPT_SETUP_PUB.Get_Card
      (
      1.0,
      FND_API.G_FALSE,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_card_id,
      x_card_instrument,
      lx_result
      );
      x_response.Result_Code := IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS;
    END IF;
    iby_fndcpt_common_pub.Prepare_Result
    (l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN

        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

        iby_debug_pub.add(debug_msg => 'x_return_status=' || x_return_status,
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
        iby_debug_pub.add(debug_msg => 'Exit Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);
  END Card_Exists;

  PROCEDURE Process_Credit_Card
            (
            p_api_version      IN   NUMBER,
            p_init_msg_list    IN   VARCHAR2  := FND_API.G_FALSE,
            p_commit           IN   VARCHAR2  := FND_API.G_TRUE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
            p_credit_card      IN   CreditCard_rec_type,
            p_assignment_attribs IN PmtInstrAssignment_rec_type,
            x_assign_id        OUT NOCOPY NUMBER,
            x_response         OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
            )
  IS
    l_api_version  CONSTANT  NUMBER := 1.0;
    l_module       CONSTANT  VARCHAR2(30) := 'Process_Credit_Card';
    l_prev_msg_count NUMBER;

    l_existing_msgs     NUMBER;
    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(2000);

    lx_response         IBY_FNDCPT_COMMON_PUB.Result_rec_type;
    lx_assign_attribs   PmtInstrAssignment_rec_type;

    l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;
  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_module,
                                        G_PKG_NAME)
    THEN
      iby_debug_pub.add(debug_msg => 'Incorrect API Version:=' || p_api_version,
                        debug_level => FND_LOG.LEVEL_ERROR,
                        module => G_DEBUG_MODULE || l_module);
      FND_MESSAGE.SET_NAME('IBY', 'IBY_204400_API_VER_MISMATCH');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    l_prev_msg_count := FND_MSG_PUB.Count_Msg;

    l_existing_msgs := NVL(x_msg_count,0);

    SAVEPOINT Process_Credit_Card;

    lx_assign_attribs := p_assignment_attribs;

    iby_debug_pub.add('create card',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

    Create_Card
    (1.0, FND_API.G_FALSE, FND_API.G_FALSE, lx_return_status, lx_msg_count,
     lx_msg_data, p_credit_card,
     lx_assign_attribs.Instrument.Instrument_Id,
     lx_response
    );

    IF (lx_response.Result_Code <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS) THEN
      iby_debug_pub.add('rollback',iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);
      ROLLBACK TO Process_Credit_Card;
      x_response := lx_response;
    ELSE

      lx_assign_attribs.Instrument.Instrument_Type :=
        IBY_FNDCPT_COMMON_PUB.G_INSTR_TYPE_CREDITCARD;
      Set_Payer_Instr_Assignment
      (1.0, FND_API.G_FALSE, FND_API.G_FALSE, x_return_status, x_msg_count,
       x_msg_data, p_payer, lx_assign_attribs, x_assign_id,
       x_response
      );
    END IF;

    iby_fndcpt_common_pub.Prepare_Result
    (iby_fndcpt_common_pub.G_INTERFACE_CODE,x_response.Result_Message,
     l_prev_msg_count,x_return_status,x_msg_count,x_msg_data,x_response);

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT;
    END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Process_Credit_Card;
	iby_debug_pub.add(debug_msg => 'In G_EXC_ERROR Exception',
              debug_level => FND_LOG.LEVEL_ERROR,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Process_Credit_Card;
	iby_debug_pub.add(debug_msg => 'In G_EXC_UNEXPECTED_ERROR Exception',
              debug_level => FND_LOG.LEVEL_UNEXPECTED,
              module => G_DEBUG_MODULE || l_module);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get ( p_count  =>   x_msg_count,
                                     p_data   =>   x_msg_data
                                   );
      WHEN OTHERS THEN
        ROLLBACK TO Process_Credit_Card;
        iby_debug_pub.add(debug_msg => 'In OTHERS Exception',
          debug_level => FND_LOG.LEVEL_UNEXPECTED,
          module => G_DEBUG_MODULE || l_module);

        iby_fndcpt_common_pub.Clear_Msg_Stack(l_prev_msg_count);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_module, SUBSTR(SQLERRM,1,100));
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count  =>  x_msg_count,
                                   p_data   =>  x_msg_data
                                  );

  END Process_Credit_Card;

  FUNCTION Get_Hash(p_number IN VARCHAR2, p_salt IN VARCHAR2) RETURN VARCHAR2
  IS
    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(200);
    lx_cc_number        iby_creditcard.ccnumber%TYPE;
  BEGIN
    iby_cc_validate.StripCC
    (1.0, FND_API.G_FALSE, p_number,
     lx_return_status, lx_msg_count, lx_msg_data, lx_cc_number
    );
    RETURN iby_security_pkg.get_hash(lx_cc_number,p_salt);
  END Get_Hash;

  FUNCTION Get_Hash(p_number IN VARCHAR2, p_salt IN VARCHAR2, p_site_salt IN VARCHAR2)
  RETURN VARCHAR2
  IS
    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(200);
    lx_cc_number        iby_creditcard.ccnumber%TYPE;
  BEGIN
    iby_cc_validate.StripCC
    (1.0, FND_API.G_FALSE, p_number,
     lx_return_status, lx_msg_count, lx_msg_data, lx_cc_number
    );
    RETURN iby_security_pkg.get_hash(lx_cc_number,p_salt,p_site_salt);
  END Get_Hash;

  PROCEDURE Get_Trxn_Payer_Attributes
  (
   p_payer            IN   IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
   p_payer_equivalency IN  VARCHAR2
     := IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
   x_payer_attributes OUT NOCOPY PayerAttributes_rec_type
  )
  IS

    l_payer_level  VARCHAR2(30);
    l_payer_id     iby_external_payers_all.ext_payer_id%TYPE;
    l_payer_attribs IBY_FNDCPT_SETUP_PUB.PayerAttributes_rec_type;

    CURSOR l_payer_attr_cur (
     ci_payer        IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type,
     ci_payer_level  IN VARCHAR2,
     ci_payer_equiv  IN VARCHAR2
    )
    IS
    SELECT bank_charge_bearer_code, dirdeb_instruction_code
      FROM iby_external_payers_all p
     WHERE p.party_id = ci_payer.Party_Id
       AND IBY_FNDCPT_COMMON_PUB.Compare_Payer
           (ci_payer.org_type, ci_payer.org_id,
           ci_payer.Cust_Account_Id, ci_payer.Account_Site_Id,
           ci_payer_level,ci_payer_equiv,p.org_type,p.org_id,
           p.cust_account_id,p.acct_site_use_id) = 'T'
  ORDER BY p.acct_site_use_id, p.cust_account_id, p.org_id;

  BEGIN

    IBY_FNDCPT_SETUP_PUB.Get_Payer_Id(p_payer,FND_API.G_VALID_LEVEL_FULL,
      l_payer_level,l_payer_id,l_payer_attribs);

    FOR l_payer_attr_rec in l_payer_attr_cur(p_payer,l_payer_level,p_payer_equivalency) LOOP
      IF (x_payer_attributes.Bank_Charge_Bearer is NULL) THEN
        x_payer_attributes.Bank_Charge_Bearer := l_payer_attr_rec.bank_charge_bearer_code;
      END IF;

      IF (x_payer_attributes.DirectDebit_BankInstruction is NULL) THEN
        x_payer_attributes.DirectDebit_BankInstruction := l_payer_attr_rec.dirdeb_instruction_code;
      END IF;
    END LOOP;

  END Get_Trxn_Payer_Attributes;


  --
  -- USE: Gets the card expiration status w.r.t an input date
  --
  --
  PROCEDURE Get_Card_Expiration_Status
  (p_instrid      IN   IBY_CREDITCARD.instrid%TYPE,
   p_input_date   IN DATE,
   x_expired      OUT NOCOPY VARCHAR2,
   x_result_code  OUT NOCOPY VARCHAR2
  )
  IS
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(300);
    l_return_status VARCHAR2(1);
    l_resp_rec      IBY_INSTRREG_PUB.GetExpStatusResp_rec_type;

    l_exp_sec_segment_id NUMBER;
    l_expiry_date        DATE;

    l_dbg_mod       VARCHAR2(100) := 'iby.plsql.IBY_FNDCPT_SETUP_PUB' || '.' || 'Get_Expiration_Status';
  BEGIN
       iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
       x_result_code := FND_API.G_RET_STS_SUCCESS;

       SELECT expirydate, expiry_sec_segment_id
       INTO l_expiry_date, l_exp_sec_segment_id
       FROM iby_creditcard
       WHERE instrid = p_instrid;

       IF ((l_expiry_date IS NULL) AND (l_exp_sec_segment_id IS NULL)) THEN
         RETURN;
       END IF;

       IF(l_expiry_date IS NOT NULL)THEN
         IF (TRUNC(l_expiry_date,'DD') < TRUNC(p_input_date,'DD')) THEN
            x_expired := 'Y';
         ELSE
            x_expired := 'N';
         END IF;
	 RETURN;
       END IF;

       IBY_INSTRREG_PUB.Get_Expiration_Status(p_instrid,
                                      p_input_date,
                                      l_return_status,
                                      l_msg_count,
                                      l_msg_data,
                                      l_resp_rec
				      );
        IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
	  iby_debug_pub.add('Error during http call out',iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);
	  x_result_code := FND_API.G_RET_STS_ERROR;
	  RETURN;
	END IF;
	x_expired := l_resp_rec.Expired;
        iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
  END Get_Card_Expiration_Status;

  FUNCTION Get_Encryption_Patch_Level
  RETURN VARCHAR2
  IS
   enc_level VARCHAR2(30);
  BEGIN
    SELECT NVL(encryption_patch_level, G_ENC_PATCH_LEVEL_NORMAL)
    INTO enc_level
    FROM iby_sys_security_options;

    RETURN enc_level;
  END Get_Encryption_Patch_Level;

--SEPA DD Project changes
  PROCEDURE Create_Debit_Authorization
  (p_debit_auth_id IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTHORIZATION_ID%TYPE,
   p_bank_use_id IN IBY_DEBIT_AUTHORIZATIONS.EXTERNAL_BANK_ACCOUNT_USE_ID%TYPE,
   p_auth_ref_number IN IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REFERENCE_NUMBER%TYPE,
   p_initial_debit_auth_id IN IBY_DEBIT_AUTHORIZATIONS.INITIAL_DEBIT_AUTHORIZATION_ID%TYPE,
   p_auth_rev_number IN IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REVISION_NUMBER%TYPE,
   p_payment_code IN IBY_DEBIT_AUTHORIZATIONS.PAYMENT_TYPE_CODE%TYPE,
   p_amend_readon_code IN IBY_DEBIT_AUTHORIZATIONS.AMENDMENT_REASON_CODE%TYPE,
   p_auth_sign_date IN IBY_DEBIT_AUTHORIZATIONS.AUTH_SIGN_DATE%TYPE,
   p_auth_cancel_date IN IBY_DEBIT_AUTHORIZATIONS.AUTH_CANCEL_DATE%TYPE,
   p_debit_auth_method IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_METHOD%TYPE,
   p_pre_notif_flag IN IBY_DEBIT_AUTHORIZATIONS.PRE_NOTIFICATION_REQUIRED_FLAG%TYPE,
   p_creditor_id IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LEGAL_ENTITY_ID%TYPE,
   p_creditor_name IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LE_NAME%TYPE,
   p_debit_auth_begin IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_BEGIN%TYPE,
   p_cust_addr_id IN IBY_DEBIT_AUTHORIZATIONS.CUST_ADDR_ID%TYPE,
   p_debit_auth_flag IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_FLAG%TYPE,
   p_debit_auth_ref IN  IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_REFERENCE%TYPE,
   p_cust_id_code IN IBY_DEBIT_AUTHORIZATIONS.CUST_IDENTIFICATION_CODE%TYPE,
   p_creditor_identifer IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_IDENTIFIER%TYPE,
   p_debit_auth_end IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_END%TYPE,
   p_mandate_file IN IBY_DEBIT_AUTHORIZATIONS.MANDATE_FILE%TYPE,
   x_result OUT NOCOPY NUMBER)
IS

l_module       CONSTANT  VARCHAR2(30) := 'Create_Debit_Authorization';
l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

BEGIN
	print_debuginfo('Enter',iby_debug_pub.G_LEVEL_PROCEDURE, l_dbg_mod);
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo('DEBIT_AUTHORIZATION_ID:'||
				p_debit_auth_id,iby_debug_pub.G_LEVEL_INFO, l_dbg_mod);
		print_debuginfo('EXTERNAL_BANK_ACCOUNT_USE_ID:'||
				p_bank_use_id,iby_debug_pub.G_LEVEL_INFO, l_dbg_mod);
		print_debuginfo('AUTHORIZATION_REFERENCE_NUMBER:'||
				p_auth_ref_number,iby_debug_pub.G_LEVEL_INFO, l_dbg_mod);
		print_debuginfo('INITIAL_DEBIT_AUTHORIZATION_ID:'||
				p_initial_debit_auth_id,iby_debug_pub.G_LEVEL_INFO, l_dbg_mod);
		print_debuginfo('AUTHORIZATION_REVISION_NUMBER:'||
				p_auth_rev_number,iby_debug_pub.G_LEVEL_INFO, l_dbg_mod);
		print_debuginfo('AUTH_SIGN_DATE:'||
				p_auth_sign_date,iby_debug_pub.G_LEVEL_INFO, l_dbg_mod);
		print_debuginfo('DEBIT_AUTH_BEGIN'||
				p_debit_auth_begin,iby_debug_pub.G_LEVEL_INFO, l_dbg_mod);
	END IF;

	INSERT INTO IBY_DEBIT_AUTHORIZATIONS
		(DEBIT_AUTHORIZATION_ID,
		EXTERNAL_BANK_ACCOUNT_USE_ID, AUTHORIZATION_REFERENCE_NUMBER,
		INITIAL_DEBIT_AUTHORIZATION_ID, AUTHORIZATION_REVISION_NUMBER,
		PAYMENT_TYPE_CODE,AMENDMENT_REASON_CODE,
		AUTH_SIGN_DATE,AUTH_CANCEL_DATE,DEBIT_AUTH_METHOD,
		PRE_NOTIFICATION_REQUIRED_FLAG,CREDITOR_LEGAL_ENTITY_ID,
		CREDITOR_LE_NAME,DEBIT_AUTH_BEGIN,created_by,
		creation_date, last_updated_by, last_update_date,
		last_update_login, object_version_number,CUST_ADDR_ID,
		DEBIT_AUTH_FLAG,DEBIT_AUTH_REFERENCE,CUST_IDENTIFICATION_CODE,
		CREDITOR_IDENTIFIER,DEBIT_AUTH_END, CURR_REC_INDI,MANDATE_FILE)

		VALUES

		(p_debit_auth_id,
		p_bank_use_id, p_auth_ref_number,
		p_initial_debit_auth_id,p_auth_rev_number,
		p_payment_code,p_amend_readon_code,
		p_auth_sign_date,p_auth_cancel_date,p_debit_auth_method,
		p_pre_notif_flag,p_creditor_id,
		p_creditor_name,p_debit_auth_begin,fnd_global.user_id,
		SYSDATE, fnd_global.user_id, SYSDATE,
		fnd_global.login_id, 1,p_cust_addr_id,
		p_debit_auth_flag,p_debit_auth_ref,p_cust_id_code,
		p_creditor_identifer,p_debit_auth_end, 'Y', p_mandate_file);
	COMMIT;
	x_result:=1;
	print_debuginfo('x_result:'|| x_result,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
EXCEPTION
WHEN OTHERS THEN
x_result:=0;
print_debuginfo('Exception occured while inserting the mandate:' ||
	sqlerrm,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
raise;
print_debuginfo('End',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
END Create_Debit_Authorization;

  -- Procedure to update the existing Mandate
PROCEDURE Update_Debit_Authorization
  (p_debit_auth_id IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTHORIZATION_ID%TYPE,
   p_bank_use_id IN IBY_DEBIT_AUTHORIZATIONS.EXTERNAL_BANK_ACCOUNT_USE_ID%TYPE,
   p_auth_ref_number IN IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REFERENCE_NUMBER%TYPE,
   p_initial_debit_auth_id IN IBY_DEBIT_AUTHORIZATIONS.INITIAL_DEBIT_AUTHORIZATION_ID%TYPE,
   p_auth_rev_number IN IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REVISION_NUMBER%TYPE,
   p_payment_code IN IBY_DEBIT_AUTHORIZATIONS.PAYMENT_TYPE_CODE%TYPE,
   p_amend_readon_code IN IBY_DEBIT_AUTHORIZATIONS.AMENDMENT_REASON_CODE%TYPE,
   p_auth_sign_date IN IBY_DEBIT_AUTHORIZATIONS.AUTH_SIGN_DATE%TYPE,
   p_auth_cancel_date IN IBY_DEBIT_AUTHORIZATIONS.AUTH_CANCEL_DATE%TYPE,
   p_debit_auth_method IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_METHOD%TYPE,
   p_pre_notif_flag IN IBY_DEBIT_AUTHORIZATIONS.PRE_NOTIFICATION_REQUIRED_FLAG%TYPE,
   p_creditor_id IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LEGAL_ENTITY_ID%TYPE,
   p_creditor_name IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LE_NAME%TYPE,
   p_debit_auth_begin IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_BEGIN%TYPE,
   p_cust_addr_id IN IBY_DEBIT_AUTHORIZATIONS.CUST_ADDR_ID%TYPE,
   p_debit_auth_flag IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_FLAG%TYPE,
   p_debit_auth_ref IN  IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_REFERENCE%TYPE,
   p_cust_id_code IN IBY_DEBIT_AUTHORIZATIONS.CUST_IDENTIFICATION_CODE%TYPE,
   p_creditor_identifer IN IBY_DEBIT_AUTHORIZATIONS.CREDITOR_IDENTIFIER%TYPE,
   p_debit_auth_end IN IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_END%TYPE,
   p_mandate_file IN IBY_DEBIT_AUTHORIZATIONS.MANDATE_FILE%TYPE,
   x_result OUT NOCOPY NUMBER)
IS
l_module       CONSTANT  VARCHAR2(30) := 'Update_Debit_Authorization';
l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;
l_seq_number NUMBER;

l_debit_auth_flag IBY_DEBIT_AUTHORIZATIONS.DEBIT_AUTH_FLAG%TYPE;
l_auth_ref_number IBY_DEBIT_AUTHORIZATIONS.AUTHORIZATION_REFERENCE_NUMBER%TYPE;
l_creditor_name IBY_DEBIT_AUTHORIZATIONS.CREDITOR_LE_NAME%TYPE;
l_creditor_identifer IBY_DEBIT_AUTHORIZATIONS.CREDITOR_IDENTIFIER%TYPE;

BEGIN
	print_debuginfo('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo('p_debit_auth_flag:'||
				p_debit_auth_flag,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		print_debuginfo('p_creditor_name:'||
				p_creditor_name,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		print_debuginfo('p_creditor_identifer:'||
				p_creditor_identifer,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	END IF;

	SELECT AUTHORIZATION_REFERENCE_NUMBER, CREDITOR_LE_NAME, CREDITOR_IDENTIFIER
		into l_auth_ref_number, l_creditor_name, l_creditor_identifer
		FROM IBY_DEBIT_AUTHORIZATIONS
		WHERE
		DEBIT_AUTHORIZATION_ID = p_debit_auth_id;

	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo('l_auth_ref_number:'||
				l_auth_ref_number,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		print_debuginfo('L_creditor_name:'||
				l_creditor_name,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		print_debuginfo('L_creditor_identifer:'||
				l_creditor_identifer,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	END IF;
        -- Bug# 9508632
	-- Comparing the unique auth ref number
	IF(p_auth_ref_number <>l_auth_ref_number OR
	   p_creditor_name <> l_creditor_name OR
	   p_creditor_identifer <> l_creditor_identifer)
	 THEN
		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo('Before Updating mandate',
					iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		END IF;

		UPDATE IBY_DEBIT_AUTHORIZATIONS SET DEBIT_AUTH_END = SYSDATE,
		CURR_REC_INDI = 'N'
		WHERE DEBIT_AUTHORIZATION_ID = p_debit_auth_id;

		select IBY_DEBIT_AUTHORIZATIONS_S.nextval into l_seq_number from dual;

		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo('Creating the new Mandate:',
					iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		END IF;

		Create_Debit_Authorization(l_seq_number,
					       p_bank_use_id,
					       p_auth_ref_number,
					       p_debit_auth_id,
					       p_auth_rev_number+1,
					       p_payment_code,
					       p_amend_readon_code,
					       p_auth_sign_date,
					       p_auth_cancel_date,
					       p_debit_auth_method,
					       p_pre_notif_flag,
					       p_creditor_id,
					       p_creditor_name,
					       p_debit_auth_begin,
					       p_cust_addr_id,
					       p_debit_auth_flag,
					       p_debit_auth_ref,
					       p_cust_id_code,
					       p_creditor_identifer,
					       p_debit_auth_end,
					       p_mandate_file,
					       x_result);
		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo('After creating the new Mandate:',
					iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		END IF;

	ELSE
		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo('Updating mandate12:',
					iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		END IF;

		UPDATE IBY_DEBIT_AUTHORIZATIONS
		SET
		EXTERNAL_BANK_ACCOUNT_USE_ID = p_bank_use_id,
		AUTHORIZATION_REFERENCE_NUMBER = p_auth_ref_number,
		INITIAL_DEBIT_AUTHORIZATION_ID = p_initial_debit_auth_id,
		AUTHORIZATION_REVISION_NUMBER = p_auth_rev_number,
		AMENDMENT_REASON_CODE = p_amend_readon_code,
		AUTH_SIGN_DATE = p_auth_sign_date,
		AUTH_CANCEL_DATE = p_auth_cancel_date,
		DEBIT_AUTH_METHOD = p_debit_auth_method,
		PRE_NOTIFICATION_REQUIRED_FLAG = p_pre_notif_flag,
		CREDITOR_LEGAL_ENTITY_ID = p_creditor_id,
		CREDITOR_LE_NAME = p_creditor_name,
		DEBIT_AUTH_BEGIN = p_debit_auth_begin,
			   last_updated_by = fnd_global.user_id,
			   last_update_date = SYSDATE ,
			   last_update_login = fnd_global.user_id,
			   object_version_number = object_version_number+1,
			   CUST_ADDR_ID = p_cust_addr_id,
			   DEBIT_AUTH_FLAG = p_debit_auth_flag ,DEBIT_AUTH_REFERENCE = p_debit_auth_ref,
			   CUST_IDENTIFICATION_CODE = p_cust_id_code,
			   CREDITOR_IDENTIFIER = p_creditor_identifer,DEBIT_AUTH_END = p_debit_auth_end
		WHERE
		DEBIT_AUTHORIZATION_ID = p_debit_auth_id;
		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo('Mandate has been updated:',
					iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
		END IF;
	END IF;
	COMMIT;
	x_result:=1;
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			print_debuginfo('x_result:' || x_result,
					iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
	END IF;
EXCEPTION
WHEN OTHERS THEN
x_result:=0;
print_debuginfo('Exception occured while updating the mandate:' ||
		sqlerrm,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

print_debuginfo('End:',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
END;

END IBY_FNDCPT_SETUP_PUB;

/
