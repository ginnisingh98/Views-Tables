--------------------------------------------------------
--  DDL for Package Body IBY_FNDCPT_COMMON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FNDCPT_COMMON_PUB" AS
/*$Header: ibyfccmb.pls 120.16.12010000.1 2008/07/28 05:40:31 appldev ship $*/


  FUNCTION Validate_Payer
  (
  p_payer            IN   PayerContext_rec_type,
  p_val_level        IN   VARCHAR2
  )
  RETURN VARCHAR2
  IS
    l_count  NUMBER;

    CURSOR c_cust_acct
    (ci_party_id IN hz_parties.party_id%TYPE,
     ci_cust_acct_id IN hz_cust_accounts.cust_account_id%TYPE
    )
    IS
      SELECT COUNT(cust_account_id)
      FROM hz_cust_accounts
      WHERE (cust_account_id = ci_cust_acct_id)
        AND ( (party_id = ci_party_id)
            OR ci_party_id IN
              ( SELECT DISTINCT a.party_id
                FROM hz_cust_account_roles a,
                  hz_cust_accounts b, hz_party_preferences c
                WHERE (b.cust_account_id = ci_cust_acct_id)
                  AND (NVL(a.status,'A')= 'A')
                  AND (NVL(b.status, 'A') = 'A')
                  AND (a.cust_account_id = b.cust_account_id)
                  AND (a.party_id = c.party_id(+))
                  AND (c.category(+) ='PRIMARY_ACCOUNT')
                  AND (c.preference_code(+) = 'CUSTOMER_ACCOUNT_ID')
              )
            );

    CURSOR c_site_use
    (ci_party_id IN hz_parties.party_id%TYPE,
     ci_cust_acct_id IN hz_cust_accounts.cust_account_id%TYPE,
     ci_cust_site_id IN hz_cust_site_uses_all.site_use_id%TYPE
    )
    IS
      SELECT COUNT(site_use_id)
      FROM hz_cust_site_uses_all u, hz_cust_acct_sites_all s,
        hz_cust_accounts a
      WHERE (u.site_use_id = ci_cust_site_id)
        AND (a.cust_account_id = ci_cust_acct_id)
        AND (u.cust_acct_site_id = s.cust_acct_site_id)
        AND (s.cust_account_id = a.cust_account_id);

  BEGIN

    IF (c_cust_acct%ISOPEN) THEN CLOSE c_cust_acct; END IF;
    IF (c_site_use%ISOPEN) THEN CLOSE c_site_use; END IF;

    -- party id and payment function always mandatory
    IF ( (p_payer.Party_Id IS NULL) OR
         (NOT iby_utility_pvt.check_lookup_val(p_payer.Payment_Function,
                                               G_LKUP_PMT_FUNCTION))
       )
    THEN
      RETURN G_RC_INVALID_PAYER;
    END IF;

    IF (p_val_level = FND_API.G_VALID_LEVEL_FULL) THEN
      IF (NOT iby_utility_pvt.validate_party_id(p_payer.Party_Id)) THEN
        RETURN G_RC_INVALID_PAYER;
      END IF;
    END IF;

    IF (NOT p_payer.Cust_Account_Id IS NULL) THEN
      IF (p_val_level = FND_API.G_VALID_LEVEL_FULL) THEN
        OPEN c_cust_acct(p_payer.Party_Id,p_payer.Cust_Account_Id);
        FETCH c_cust_acct INTO l_count;
        CLOSE c_cust_acct;
        IF (l_count<1) THEN RETURN G_RC_INVALID_PAYER; END IF;
      END IF;
    ELSE
      IF (p_payer.Account_Site_Id IS NULL) AND (p_payer.Org_Id IS NULL)
        AND (p_payer.Org_Type IS NULL)
      THEN
        RETURN G_PAYER_LEVEL_PARTY;
      ELSE
        RETURN G_RC_INVALID_PAYER;
      END IF;
    END IF;

    IF (NOT p_payer.Account_Site_Id IS NULL) THEN
      -- customer account id is required if account site id is used
      IF (p_payer.Cust_Account_Id IS NULL) THEN RETURN G_RC_INVALID_PAYER; END IF;

      IF (p_val_level = FND_API.G_VALID_LEVEL_FULL) THEN
        OPEN c_site_use(p_payer.Party_Id,p_payer.Cust_Account_Id,
          p_payer.Account_Site_Id);
        FETCH c_site_use INTO l_count;
        CLOSE c_site_use;
        IF (l_count<1) THEN RETURN G_RC_INVALID_PAYER; END IF;
      END IF;

      -- if account site id is set then payer must be org-striped
      IF ((p_payer.Org_Type IS NULL) OR (p_payer.Org_Id IS NULL)) THEN
        RETURN G_RC_INVALID_PAYER;
      ELSE
        RETURN G_PAYER_LEVEL_CUSTOMER_SITE;
      END IF;
    ELSE
      IF (p_payer.Org_Id IS NULL) AND (p_payer.Org_Type IS NULL) THEN
        RETURN G_PAYER_LEVEL_CUSTOMER_ACCT;
      ELSE
        RETURN G_RC_INVALID_PAYER;
      END IF;
    END IF;

  END Validate_Payer;

  FUNCTION Compare_Payer
  (
  p_payer_org_type  IN    iby_external_payers_all.org_type%TYPE,
  p_payer_org_id    IN    iby_external_payers_all.org_id%TYPE,
  p_payer_cust_acct_id IN iby_external_payers_all.cust_account_id%TYPE,
  p_payer_acct_site_id IN iby_external_payers_all.acct_site_use_id%TYPE,
  p_payer_level     IN    VARCHAR2,
  p_equiv_type      IN    VARCHAR2,
  p_compare_org_type IN   iby_external_payers_all.org_type%TYPE,
  p_compare_org_id  IN    iby_external_payers_all.org_id%TYPE,
  p_compare_cust_acct_id IN iby_external_payers_all.cust_account_id%TYPE,
  p_compare_acct_site_id IN iby_external_payers_all.acct_site_use_id%TYPE
  )
  RETURN VARCHAR2
  IS
  BEGIN
    --
    -- party id and payment function assumed to already match before
    -- call to function
    --
    IF (p_payer_level = G_PAYER_LEVEL_PARTY) THEN
      IF (p_equiv_type = G_PAYER_EQUIV_FULL) OR
         (p_equiv_type = G_PAYER_EQUIV_DOWNWARD)
      THEN
        RETURN FND_API.G_TRUE;
      ELSE
        IF (p_compare_org_type IS NULL) AND (p_compare_org_id IS NULL)
           AND (p_compare_cust_acct_id IS NULL)
           AND (p_compare_acct_site_id IS NULL)
        THEN
          RETURN FND_API.G_TRUE;
        END IF;
      END IF;
    ELSIF (p_payer_level = G_PAYER_LEVEL_CUSTOMER_ACCT) THEN
      IF (p_equiv_type = G_PAYER_EQUIV_FULL) OR
         (p_equiv_type = G_PAYER_EQUIV_DOWNWARD)
      THEN
        IF (p_payer_cust_acct_id = p_compare_cust_acct_id) THEN
          RETURN FND_API.G_TRUE;
        END IF;
      END IF;
      IF (p_equiv_type = G_PAYER_EQUIV_FULL) OR
         (p_equiv_type = G_PAYER_EQUIV_UPWARD) THEN
        IF (NVL(p_compare_cust_acct_id,p_payer_cust_acct_id) = p_payer_cust_acct_id)
           AND (p_compare_acct_site_id IS NULL)
        THEN RETURN FND_API.G_TRUE; END IF;
      END IF;
      IF (p_equiv_type = G_PAYER_EQUIV_IMMEDIATE) THEN
        IF (p_compare_cust_acct_id = p_compare_cust_acct_id)
           AND (p_compare_acct_site_id IS NULL)
        THEN RETURN FND_API.G_TRUE; END IF;
      END IF;
    ELSIF (p_payer_level = G_PAYER_LEVEL_CUSTOMER_SITE) THEN
      IF (p_equiv_type = G_PAYER_EQUIV_FULL) OR
         (p_equiv_type = G_PAYER_EQUIV_UPWARD)
      THEN
        IF (p_payer_org_type = NVL(p_compare_org_type,p_payer_org_type))
           AND (p_payer_org_id = NVL(p_compare_org_id,p_payer_org_id))
           AND (p_payer_cust_acct_id = NVL(p_compare_cust_acct_id,p_payer_cust_acct_id))
           AND (p_payer_acct_site_id = NVL(p_compare_acct_site_id,p_payer_acct_site_id))
        THEN
          RETURN FND_API.G_TRUE;
        END IF;
      END IF;
      IF (p_equiv_type = G_PAYER_EQUIV_FULL) OR
         (p_equiv_type = G_PAYER_EQUIV_DOWNWARD) OR
         (p_equiv_type = G_PAYER_EQUIV_IMMEDIATE)
      THEN

        IF (p_payer_org_type = p_compare_org_type)
           AND (p_payer_org_id = p_compare_org_id)
           AND (p_payer_cust_acct_id = p_compare_cust_acct_id)
           AND (p_payer_acct_site_id = p_compare_acct_site_id)
        THEN
          RETURN FND_API.G_TRUE;
        END IF;
      END IF;
    END IF;

    RETURN FND_API.G_FALSE;
  END Compare_Payer;

  PROCEDURE Prepare_Result
  (
  p_interface_code   IN  VARCHAR2,
  p_existing_msg     IN  VARCHAR2,
  p_prev_msg_count   IN  NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_result           IN OUT NOCOPY Result_rec_type
  )
  IS
    l_msg_name  iby_result_codes.message_name%TYPE;
    l_category  iby_result_codes.result_category%TYPE;
    l_msg_stack_size NUMBER;

    l_module         VARCHAR2(30) := 'Prepare_Result(7 ARG)';
    l_dbg_mod        VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;

    CURSOR c_result
    (ci_result_code IN iby_result_codes.result_code%TYPE)
    IS
      SELECT result_category, message_name
      FROM iby_result_codes
      WHERE (result_code = ci_result_code)
        AND (request_interface_code = 'FNDCPT_PUB');
  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    IF (c_result%ISOPEN) THEN CLOSE c_result; END IF;

    -- map to an equivalent generic result based upon result category
    IF (p_interface_code <> G_INTERFACE_CODE) THEN
      l_category := Get_Result_Category(x_result.Result_Code,p_interface_code);
      IF (l_category = G_RCAT_CONFIG_ERR ) THEN
        x_result.Result_Code := G_RC_GENERIC_CONFIG_ERROR;
      ELSIF (l_category = G_RCAT_SYS_ERROR ) THEN
        x_result.Result_Code := G_RC_GENERIC_SYS_ERROR;
      ELSIF (l_category = G_RCAT_INV_PARAM ) THEN
        x_result.Result_Code := G_RC_GENERIC_INVALID_PARAM;
      ELSIF (l_category = G_RCAT_DATA_CORRUPT ) THEN
        x_result.Result_Code := G_RC_GENERIC_DATA_CORRUPTION;
      ELSIF (l_category = G_RCAT_SUCCESS ) THEN
        x_result.Result_Code := G_RC_SUCCESS;
      END IF;
    END IF;

    OPEN c_result(x_result.Result_Code);
    FETCH c_result INTO x_result.Result_Category, l_msg_name;
    CLOSE c_result;

    -- put the existing msg on the stack instead of the generic
    -- one for the result code
    IF (NOT p_existing_msg IS NULL) THEN
      l_msg_name := 'IBY_9999';
    END IF;

    IF (x_result.Result_Category = G_RCAT_SUCCESS) OR
       (x_result.Result_Category = G_RCAT_SUCCESS_RISK) OR
       (x_result.Result_Category = G_RCAT_PENDING)
    THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- remove extra messages from the stack added
    -- by calls to APIs within other APIs; do not
    -- remove messages already on the stack at the
    -- time of invocation, though
    l_msg_stack_size := FND_MSG_PUB.Count_Msg;
    WHILE (l_msg_stack_size > p_prev_msg_count) LOOP
      FND_MSG_PUB.Delete_Msg(p_prev_msg_count+1);
      l_msg_stack_size := l_msg_stack_size - 1;
    END LOOP;

    IF (p_existing_msg IS NULL) THEN
      FND_MESSAGE.SET_NAME('IBY',l_msg_name);
      x_result.Result_Message := FND_MESSAGE.GET();
    ELSE
      FND_MESSAGE.SET_NAME('IBY','IBY_9999');
      FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT', p_existing_msg);
      x_result.Result_Message := FND_MESSAGE.GET();
    END IF;

    -- IBY_9999 means use the message returned by the engine
    -- or sub-moudule
    FND_MESSAGE.SET_NAME('IBY',l_msg_name);
    IF (l_msg_name = 'IBY_9999') THEN
      FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT',x_result.Result_Message);
    END IF;
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get( p_count  =>   x_msg_count,
                               p_data   =>   x_msg_data
                             );

    iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
  END Prepare_Result;

  PROCEDURE Prepare_Result
  (
  p_prev_msg_count   IN  NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_result           IN OUT NOCOPY Result_rec_type
  )
  IS
    l_module         VARCHAR2(30) := 'Prepare_Result(5 ARG)';
    l_dbg_mod        VARCHAR2(100) := G_DEBUG_MODULE || '.' || l_module;
  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    Prepare_Result
    (G_INTERFACE_CODE,NULL,p_prev_msg_count,x_return_status,x_msg_count,
     x_msg_data,x_result);

    iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
  END Prepare_Result;

  FUNCTION Get_Result_Category
  (p_result     IN iby_result_codes.result_code%TYPE,
   p_interface  IN iby_result_codes.request_interface_code%TYPE)
  RETURN iby_result_codes.result_category%TYPE
  IS
    l_category  iby_result_codes.result_category%TYPE;

    CURSOR c_category
    (ci_result IN iby_result_codes.result_code%TYPE,
     ci_interface IN iby_result_codes.request_interface_code%TYPE)
    IS
      SELECT result_category
      FROM iby_result_codes
      WHERE (result_code = ci_result)
        AND (request_interface_code = ci_interface);
  BEGIN
    IF (c_category%ISOPEN) THEN CLOSE c_category; END IF;

    OPEN c_category(p_result,p_interface);
    FETCH c_category INTO l_category;
    CLOSE c_category;

    RETURN l_category;
  END Get_Result_Category;

  PROCEDURE Clear_Msg_Stack( p_prev_msg_count IN  NUMBER )
  IS
    l_msg_stack_size NUMBER;
    l_dbg_mod        VARCHAR2(100) := G_DEBUG_MODULE || '.Clear_Msg_Stack';
  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    l_msg_stack_size := FND_MSG_PUB.Count_Msg;
    WHILE (l_msg_stack_size > p_prev_msg_count) LOOP
      FND_MSG_PUB.Delete_Msg(p_prev_msg_count+1);
      l_msg_stack_size := l_msg_stack_size - 1;
    END LOOP;
  END Clear_Msg_Stack;

END IBY_FNDCPT_COMMON_PUB;

/
