--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_UTILITY_PVT" as
/* $Header: ozfvcutb.pls 120.2.12010000.9 2009/08/25 09:30:31 kpatro ship $ */
-- Start of Comments
-- Package name     : OZF_claim_Utility_pvt
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME             CONSTANT  VARCHAR2(30) := 'OZF_CLAIM_UTILITY_PVT';

G_FILE_NAME            CONSTANT VARCHAR2(12) := 'ozfvcutb.pls';

OZF_DEBUG_HIGH_ON     CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON      CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
g_bulk_limit  CONSTANT NUMBER := 5000;  -- yzhao: Sep 8,2005 bulk fetch limit. It should get from profile.



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_Claim_Access
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_object_id               IN   NUMBER
--       P_object_type             IN   VARCHAR2
--       P_user_id                 IN   NUMBER
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_access                  OUT  VARCHAR2  F : FULL: User can update any data
--                                                R : RESTRICTED : User can only update data other than owner
--                                                N : NULL : User has no update priviledge
--   Version : Current version 1.0
--
--   Note: This procedure checks security access to a claim of a user
--
--   End of Comments
--
PROCEDURE Check_Claim_access(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
         P_object_id                  IN   NUMBER,
    P_object_type                IN   VARCHAR2,
         P_user_id                    IN   NUMBER,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    x_access                     OUT NOCOPY  VARCHAR2
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Check_Claim_access';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_profile_value           VARCHAR2(30);

l_access varchar2(1) :='N';  --  F : FULL: User can update sensitive metric data
                             --  R : RESTRICTED : User can only update data other than sensitive metric data
                             --  N : NULL : User is no
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Check_Claim_ACC;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

 /*     IF AMS_access_PVT.check_owner(
   p_object_id         IN  NUMBER,
   p_object_type       IN  VARCHAR2,
   p_user_or_role_id   IN  NUMBER,
   p_user_or_role_type ) OR
*/
   -- There is no need to check the owner since owner and group memeber has the same update priviledge.
   l_access :=AMS_access_PVT.check_update_access(
      p_object_id         => P_object_id,
      p_object_type       => P_object_type,
      p_user_or_role_id   => p_user_id,
      p_user_or_role_type => 'USER'
   );

   IF l_access = 'F' OR AMS_access_PVT.Check_Admin_access(p_resource_id => p_user_id) THEN
      x_access := 'F';
   ELSE
      l_profile_value :=  NVL(fnd_profile.value('OZF_CLAIM_UPDATE_ACCESS'), 'VIEW');
      IF l_profile_value = 'UPDATE' THEN
              x_access := 'R';
      ELSE
              x_access := 'N';
      END IF;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('user_id='||p_user_id||' update_access is '||l_access);
      OZF_Utility_PVT.debug_message('claim access is '||x_access);
   END IF;

   --
   -- End of API body
   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Check_Claim_ACC;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Check_Claim_ACC;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO Check_Claim_ACC;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CHK_ACS_ERR');
       FND_MSG_PUB.add;
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Check_Claim_access;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Normalize_Customer_Reference
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_customer_reference      IN   VARCHAR2
--
--   OUT:
--       x_normalized_reference    OUT  VARCHAR2
--   Version : Current version 1.0
--
--   Note: This procedure normalizes the customer reference number.
--
--   End of Comments
--
PROCEDURE  Normalize_Customer_Reference (
    p_customer_reference       IN   VARCHAR2
   ,x_normalized_reference     OUT NOCOPY  VARCHAR2
   )
IS

l_normalized_reference VARCHAR2(30) := '';
l_char                 VARCHAR2(1);

BEGIN
   -- loop over all characters
   FOR i IN 1..LENGTH(p_customer_reference) LOOP
      l_char := SUBSTRB(p_customer_reference, i, 1);

      -- change 'O' and 'o' to '0'
      IF l_char = 'O' OR l_char = 'o' THEN
         l_normalized_reference := l_normalized_reference || '0';

      -- change 'I' and 'l' to '1'
      ELSIF l_char = 'I' OR l_char = 'l' THEN
         l_normalized_reference := l_normalized_reference || '1';

      -- ignore special characters; change characters to upper case
      ELSIF INSTR(' !"#$%&''()*+,-./:;<>=?@[\]^{|}~', l_char) = 0 THEN
         l_normalized_reference := l_normalized_reference || UPPER(l_char);
      END IF;
   END LOOP;

   -- remove prefix 'DM'
   l_normalized_reference := LTRIM(l_normalized_reference, 'DM');

   -- remove leading '0's
   l_normalized_reference := LTRIM(l_normalized_reference, '0');

   x_normalized_reference := l_normalized_reference;
END Normalize_Customer_Reference;

/*=======================================================================*
 | Procedure
 |    Normalize_Credit_Reference
 |
 | PURPOSE
 |    Returns Normalized Credit Reference Number
 |
 | NOTES
 |
 | HISTORY
 |    20-JUN-2009  KPATRO  Create.
 *=======================================================================*/
FUNCTION Normalize_Credit_Reference (p_credit_ref  IN  VARCHAR2)
RETURN VARCHAR2
IS

l_credit_ref_norm VARCHAR2(30);

BEGIN

   Normalize_Customer_Reference(
             p_customer_reference => p_credit_ref
            ,x_normalized_reference => l_credit_ref_norm
          );

   return l_credit_ref_norm;

EXCEPTION
   WHEN OTHERS THEN
       return NULL;
END Normalize_Credit_Reference;

/*=======================================================================*
 | Procedure
 |    Create_Log
 |
 | PURPOSE
 |    This procedure wll help to audit the number of records
 |    processed by Rule Based Engine
 |
 | NOTES
 |
 | HISTORY
 |    20-JUN-2009  KPATRO  Create.
 |    19-Aug-2009  KPATRO  Removed the Bulk insert for Bug 8809877
 |
 *=======================================================================*/

PROCEDURE Create_Log(
    p_api_version         IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2  := FND_API.g_false,
    p_validation_level    IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_exact_match_tbl     IN  ozf_rule_match_tbl_type,
    p_possible_match_tbl  IN  ozf_rule_match_tbl_type,
    p_accrual_match_tbl   IN  ozf_accrual_match_tbl_type,
    x_Return_Status       OUT NOCOPY  VARCHAR2,
    x_Msg_Count           OUT NOCOPY  NUMBER,
    x_Msg_Data            OUT NOCOPY  VARCHAR2

 )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_Log';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_return_status VARCHAR2(10);

l_api_version   NUMBER := 1.0;


l_exactmatchTbl ozf_rule_match_tbl_type := p_exact_match_tbl;
l_possiblematchTbl ozf_rule_match_tbl_type := p_possible_match_tbl;
l_accrualmatchTbl ozf_accrual_match_tbl_type := p_accrual_match_tbl;

l_exact_match_rec_type  ozf_rule_match_rec_type;
l_poss_match_rec_type  ozf_rule_match_rec_type;
l_accrual_match_rec_type ozf_accrual_match_rec_type;

BEGIN
SAVEPOINT CREATE_LOG;

 IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
 END IF;

FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------ Rule Based Settlement Report --------------------------------_*');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Start Date & Time: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'End Date & Time: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '100% Credit Matches :' || l_exactmatchTbl.count);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Possible Credit Matches :' || l_possiblematchTbl.count);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Accrual Matches :' || l_accrualmatchTbl.count);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

 IF (l_exactmatchTbl.count >0) THEN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '100% Credit Matches ');
    FOR j IN l_exactmatchTbl.FIRST..l_exactmatchTbl.LAST  LOOP
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Deduction #', 40, ' ') || ': ' || l_exactmatchTbl(j).claim_number);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Credit Memo #', 40, ' ') || ': ' || l_exactmatchTbl(j).credit_memo_number);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Deduction Amount', 40, ' ') || ': ' || l_exactmatchTbl(j).claim_amount ||' ' || l_exactmatchTbl(j).currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Credit Amount', 40, ' ') || ': ' || l_exactmatchTbl(j).credit_amount || ' '|| l_exactmatchTbl(j).currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

        IF l_exactmatchTbl.exists(j) THEN
        l_exact_match_rec_type := l_exactmatchTbl(j);

          INSERT INTO OZF_RULE_BASED_LOG
               (
                     LOG_ID
                   , LAST_UPDATE_DATE
                   , LAST_UPDATED_BY
                   , CREATION_DATE
                   , CREATED_BY
                   , LAST_UPDATE_LOGIN
                   , REQUEST_ID
                   , PROGRAM_APPLICATION_ID
                   , CREATED_FROM
                   , CLAIM_ID
                   , QP_LIST_HEADER_ID
                   , CUSTOMER_TRX_ID
                   , PROCESSED_MATCH_TYPE
                  )
               VALUES
               (
                     OZF_RULE_BASED_LOG_S.nextval
                   , SYSDATE
                   , NVL(FND_GLOBAL.user_id,-1)
                   , SYSDATE
                   , NVL(FND_GLOBAL.user_id,-1)
                   , NVL(FND_GLOBAL.conc_login_id,-1)
                   , NVL(FND_GLOBAL.CONC_REQUEST_ID,-1)
                   , NVL(FND_GLOBAL.PROG_APPL_ID,-1)
                   , 'RULEBASED'
                   --, l_exactmatchTbl(I).claim_id
                   , l_exact_match_rec_type.claim_id
                   , null
                   --, l_exactmatchTbl(I).customer_trx_id
                   , l_exact_match_rec_type.customer_trx_id
                   , 'C'
               );

        END IF;

    END LOOP;
END IF;

IF (l_possiblematchTbl.count >0) THEN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Possible Credit Matches');
    FOR k IN l_possiblematchTbl.FIRST..l_possiblematchTbl.LAST LOOP
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Deduction #', 40, ' ') || ': ' || l_possiblematchTbl(k).claim_number);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Credit Memo #', 40, ' ') || ': ' || l_possiblematchTbl(k).credit_memo_number);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Deduction Amount', 40, ' ') || ': ' || l_possiblematchTbl(k).claim_amount || ' ' || l_possiblematchTbl(k).currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Credit Amount', 40, ' ') || ': ' || l_possiblematchTbl(k).credit_amount || ' ' || l_possiblematchTbl(k).currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

        IF l_possiblematchTbl.exists(k) THEN
        l_poss_match_rec_type := l_possiblematchTbl(k);

           INSERT INTO OZF_RULE_BASED_LOG
               (
                     LOG_ID
                   , LAST_UPDATE_DATE
                   , LAST_UPDATED_BY
                   , CREATION_DATE
                   , CREATED_BY
                   , LAST_UPDATE_LOGIN
                   , REQUEST_ID
                   , PROGRAM_APPLICATION_ID
                   , CREATED_FROM
                   , CLAIM_ID
                   , QP_LIST_HEADER_ID
                   , CUSTOMER_TRX_ID
                   , PROCESSED_MATCH_TYPE
                  )
              VALUES
               (
                     OZF_RULE_BASED_LOG_S.nextval
                   , SYSDATE
                   , NVL(FND_GLOBAL.user_id,-1)
                   , SYSDATE
                   , NVL(FND_GLOBAL.user_id,-1)
                   , NVL(FND_GLOBAL.conc_login_id,-1)
                   , NVL(FND_GLOBAL.CONC_REQUEST_ID,-1)
                   , NVL(FND_GLOBAL.PROG_APPL_ID,-1)
                   , 'RULEBASED'
                   --, l_possiblematchTbl(J).claim_id
                   , l_poss_match_rec_type.claim_id
                   , null
                   --, l_possiblematchTbl(J).customer_trx_id
                   , l_poss_match_rec_type.customer_trx_id
                   , 'P'
               );
       END IF;
    END LOOP;
END IF;

 IF (l_accrualmatchTbl.count >0) THEN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Accrual Matches :');
    FOR i IN l_accrualmatchTbl.FIRST..l_accrualmatchTbl.LAST LOOP
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Deduction #', 40, ' ') || ': ' || l_accrualmatchTbl(i).claim_number);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Offer Code', 40, ' ') || ': ' || l_accrualmatchTbl(i).Offer_Code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Claim Amount', 40, ' ') || ': ' || l_accrualmatchTbl(i).claim_amount || ' ' || l_accrualmatchTbl(i).currency_code);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
        IF l_accrualmatchTbl.exists(i) THEN
           l_accrual_match_rec_type := l_accrualmatchTbl(i);

            INSERT INTO OZF_RULE_BASED_LOG
                       (
                             LOG_ID
                           , LAST_UPDATE_DATE
                           , LAST_UPDATED_BY
                           , CREATION_DATE
                           , CREATED_BY
                           , LAST_UPDATE_LOGIN
                           , REQUEST_ID
                           , PROGRAM_APPLICATION_ID
                           , CREATED_FROM
                           , CLAIM_ID
                           , QP_LIST_HEADER_ID
                           , CUSTOMER_TRX_ID
                           , PROCESSED_MATCH_TYPE
                          )
                       VALUES
                       (
                             OZF_RULE_BASED_LOG_S.nextval
                           , SYSDATE
                           , NVL(FND_GLOBAL.user_id,-1)
                           , SYSDATE
                           , NVL(FND_GLOBAL.user_id,-1)
                           , NVL(FND_GLOBAL.conc_login_id,-1)
                           , NVL(FND_GLOBAL.CONC_REQUEST_ID,-1)
                           , NVL(FND_GLOBAL.PROG_APPL_ID,-1)
                           , 'RULEBASED'
                           , l_accrual_match_rec_type.claim_id
                           , l_accrual_match_rec_type.qp_list_header_id
                           , null
                           , 'A'
                       );

           END IF;
    END LOOP;

END IF;

FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Successful' );
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*----------------------------------------------------------------------------------------------*');

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_LOG;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_LOG;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO CREATE_LOG;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CHK_ACS_ERR');
       FND_MSG_PUB.add;
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
    );

END Create_Log;

/*=======================================================================*
 | Procedure
 |    Start_Rule_Based_Settlement
 |
 | PURPOSE
 |    This procedure will process the deduction records
 |    that is eligible by Rule Based Engine.
 |       If 100% Credit Match found, then deduction offset with CM
 |       If 100% Match not found and possible match found based on setup
 |                    it will go to possible queue.
 |       If 100% Credit Match or possible match not found then it will
 |       look for PAD number. If found then utilized the unbalance accruals
 |       and initiate the settlement.
 |
 | NOTES
 |
 | HISTORY
 |    20-JUN-2009  KPATRO  Create.
 |    06-Aug-2009  KPATRO  Changed the Synonyms to base tables
 |    07-Aug-2009  KPATRO  Need to Consider all the bill to site's of cudtomer
 |                         creditmemo along with related customer
 |                         in case of include related customer
 |    19-Aug-2009  KPATRO  Changed CONTINURE to GOTO for Bug 8809877
 |    19-Aug-2009  KPATRO  Changed the Customer Reference Information for Bug 8814596
 |    25-Aug-2009  KPATRO  Fix for Bug 8834586
 *=======================================================================*/
PROCEDURE Start_Rule_Based_Settlement (
    ERRBUF                           OUT NOCOPY VARCHAR2,
    RETCODE                          OUT NOCOPY NUMBER,
    --p_org_id                         IN NUMBER   DEFAULT NULL,
    p_start_date                     IN VARCHAR2,
    p_end_date                       IN VARCHAR2,
    p_pay_to_customer                IN VARCHAR2 := NULL
 )
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Start_Rule_Based_Settlement';
l_api_version   CONSTANT NUMBER := 1.0;
l_full_name     CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_return_status VARCHAR2(10);

l_claim_rec      OZF_CLAIM_PVT.claim_rec_type;

TYPE claimTbl                IS TABLE OF ozf_claims_all.claim_number%TYPE;
TYPE amountTbl               IS TABLE OF ozf_claims_all.amount%TYPE;
TYPE acctdamountTbl          IS TABLE OF ozf_claims_all.acctd_amount%TYPE;
TYPE claimidTbl              IS TABLE OF ozf_claims_all.claim_id%TYPE;
TYPE custrefdTbl             IS TABLE OF ozf_claims_all.customer_ref_number%TYPE;
TYPE custrefnormTbl          IS TABLE OF ozf_claims_all.customer_ref_normalized%TYPE;
TYPE custaccountTbl          IS TABLE OF ozf_claims_all.cust_account_id%TYPE;
TYPE custbilltositeTbl       IS TABLE OF ozf_claims_all.cust_billto_acct_site_id%TYPE;
TYPE claimobjverTbl          IS TABLE OF ozf_claims_all.object_version_number%TYPE;
TYPE curcodeTbl              IS TABLE OF ozf_claims_all.currency_code%TYPE;
TYPE padTbl                  IS TABLE OF ozf_claims_all.pre_auth_deduction_number%TYPE;
TYPE padnormTbl              IS TABLE OF ozf_claims_all.pre_auth_deduction_normalized%TYPE;
TYPE siteUseIdTbl            IS TABLE OF ozf_claims_all.cust_billto_acct_site_id%TYPE;
TYPE offerIdTbl              IS TABLE OF ozf_claims_all.offer_id%TYPE;


-- For System Parameter Check
l_enable_rule_based VARCHAR2(1);
l_cre_threshold_type VARCHAR2(50);
l_cre_threshold_val  NUMBER;
l_cust_name_match_type VARCHAR2(50);


-- For Input Parameter from CC Job
l_start_date       date;
l_end_date         date;
l_cust_account_number  NUMBER;

-- Get the Default Org
l_org_id NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();

-- Fetch the System Parameter Details
CURSOR chk_rule_based_csr  IS
SELECT NVL(rule_based, 'F'),
       NVL(cust_name_match_type,'EXCLUDE_REL_CUST'),
       credit_matching_thold_type,
       credit_tolerance_operand
FROM   ozf_sys_parameters_all
WHERE  org_id = l_org_id;

-- Fix for Bug 8834586 : truncating the dates if not passed from cc job.
CURSOR open_ded_csr(p_cust_account_id IN NUMBER,p_start_date IN DATE , p_end_date IN DATE) IS
SELECT claim_id,
       claim_number,
       amount,
       acctd_amount,
       customer_ref_number,
       customer_ref_normalized,
       cust_account_id,
       cust_billto_acct_site_id,
       object_version_number,
       currency_code,
       pre_auth_deduction_number,
       pre_auth_deduction_normalized,
       cust_billto_acct_site_id,
       offer_id
FROM  ozf_claims_all
WHERE
      status_code = 'OPEN'
AND   claim_class = 'DEDUCTION'
AND   (customer_ref_number IS NOT NULL
OR    pre_auth_deduction_number IS NOT NULL)
AND   org_id = l_org_id
AND   cust_account_id = nvl(p_cust_account_id,cust_account_id)
AND   trunc(creation_date) between nvl(p_start_date, trunc(creation_date)) AND nvl(p_end_date, trunc(creation_date))
ORDER BY creation_date ASC;

-- Exact Match with Exclude related Customer
CURSOR csr_exact_cm_exc_cust(p_cust_account_id IN NUMBER,p_currency_code IN VARCHAR2, p_site_use_id IN NUMBER,
                                p_deduction_amount IN NUMBER, p_ref_number IN VARCHAR2) IS
SELECT ps.customer_trx_id,
       ps.trx_number,
       ps.amount_due_remaining
FROM   ar_payment_schedules_all ps,
       ra_cust_trx_types_all ctt,
       ra_customer_trx_all ct
WHERE
       ps.class in ('CM') --class = Credit Memo
 AND   ps.status = 'OP' -- status = Open
 AND   ps.customer_id = p_cust_account_id
 AND   ps.invoice_currency_code = p_currency_code --deduction currency code
 AND   ps.customer_site_use_id = p_site_use_id --deduction site_use_id
 AND   ctt.type = 'CM'
 AND   ABS(ps.amount_due_remaining) = p_deduction_amount --deduction amount
 AND   ctt.cust_trx_type_id = ps.cust_trx_type_id --transaction type = Credit Memo
 AND   Normalize_Credit_Reference(ct.customer_reference) = p_ref_number
 AND   ct.customer_trx_id = ps.customer_trx_id
 AND   ps.org_id = l_org_id
 AND   rownum = 1 -- for 100% match it should be one
 ORDER BY ct.creation_date ASC;

-- Exact Match with Include related Customer
CURSOR csr_exact_cm_rel_cust(p_cust_account_id IN NUMBER,p_claim_id IN NUMBER,p_currency_code IN VARCHAR2,
                                p_deduction_amount IN NUMBER, p_ref_number IN VARCHAR2) IS
SELECT ps.customer_trx_id,
       ps.trx_number,
       ps.amount_due_remaining
FROM   ar_payment_schedules_all ps,
       ra_cust_trx_types_all ctt,
       ra_customer_trx_all ct,
(
  SELECT SITE.site_use_id site_use_id
  FROM   HZ_CUST_ACCT_RELATE_ALL REL, HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
         HZ_CUST_SITE_USES_ALL SITE
  WHERE
         REL.status = 'A'
    AND  REL.cust_account_id = p_cust_account_id --cust_account_id from deduction
    AND  REL.relationship_type IN ('ALL','Reciprocal','Parent')
    AND  REL.related_cust_account_id = ACCT_SITE.cust_account_id
    AND  ACCT_SITE.cust_acct_site_id = SITE.cust_acct_site_id
    AND  SITE.SITE_USE_CODE = 'BILL_TO'
    AND  SITE.status = 'A'
    AND  REL.org_id = l_org_id
UNION
 SELECT  SITE.site_use_id site_use_id
 FROM    HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
         HZ_CUST_SITE_USES_ALL SITE
 WHERE
         ACCT_SITE.cust_account_id = p_cust_account_id
    AND  ACCT_SITE.cust_acct_site_id = SITE.cust_acct_site_id
    AND  SITE.SITE_USE_CODE = 'BILL_TO'
    AND  SITE.status = 'A'
    AND  SITE.org_id = l_org_id
) site_use
WHERE
      ps.class in ('CM') --class = Credit Memo
 AND  ps.status = 'OP' -- status = Open
 AND  ps.invoice_currency_code = p_currency_code --deduction currency code
 AND  ABS(ps.amount_due_remaining) = p_deduction_amount --deduction amount
 AND  ps.customer_site_use_id = site_use.site_use_id --deduction site_use_id / related customer site_use_id
 AND  ctt.type = 'CM'
 AND  ctt.cust_trx_type_id = ps.cust_trx_type_id --transaction type = Credit Memo
 AND  Normalize_Credit_Reference(ct.customer_reference) = p_ref_number
 AND  ct.customer_trx_id = ps.customer_trx_id
 AND  ps.org_id = l_org_id
 AND  rownum = 1 -- for 100% match it should be one.
 ORDER BY ct.creation_date ASC;

-- Possible Match with Exclude related Customer
CURSOR csr_poss_cm_exc_cust(p_cust_account_id IN NUMBER,p_currency_code IN VARCHAR2, p_site_use_id IN NUMBER,
                                p_deduction_lower_amount IN NUMBER,p_deduction_upper_amount IN NUMBER,
                                p_ref_number IN VARCHAR2) IS
SELECT ps.customer_trx_id,
       ps.trx_number,
       ps.amount_due_remaining
FROM
       ar_payment_schedules_all ps,
       ra_cust_trx_types_all ctt,
       ra_customer_trx_all ct
WHERE
       ps.class in ('CM') --class = Credit Memo
  AND  ps.status = 'OP' -- status = Open
  AND  ps.customer_id = p_cust_account_id
  AND  ps.invoice_currency_code = p_currency_code --deduction currency code
  AND  ps.customer_site_use_id = p_site_use_id --deduction site_use_id
  AND  ctt.type = 'CM'
  AND  ABS(ps.amount_due_remaining) between  p_deduction_lower_amount AND p_deduction_upper_amount --deduction amount
  AND  ctt.cust_trx_type_id = ps.cust_trx_type_id --transaction type = Credit Memo
  AND  Normalize_Credit_Reference(ct.customer_reference) = p_ref_number
  AND  ct.customer_trx_id = ps.customer_trx_id
  AND  ps.org_id = l_org_id
  ORDER BY ct.creation_date ASC;

-- Possible Match with Include related Customer
CURSOR csr_poss_cm_rel_cust(p_cust_account_id IN NUMBER,p_claim_id IN NUMBER,p_currency_code IN VARCHAR2,
                                p_deduction_lower_amount IN NUMBER,p_deduction_upper_amount IN NUMBER, p_ref_number IN VARCHAR2) IS
SELECT ps.customer_trx_id,
       ps.trx_number,
       ps.amount_due_remaining
FROM
       ar_payment_schedules_all ps,
       ra_cust_trx_types_all ctt,
       ra_customer_trx_all ct,
(
  SELECT SITE.site_use_id site_use_id
  FROM   HZ_CUST_ACCT_RELATE_ALL REL,
         HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
         HZ_CUST_SITE_USES_ALL SITE
  WHERE  REL.status = 'A'
   AND   REL.cust_account_id = p_cust_account_id --cust_account_id from deduction
   AND   REL.relationship_type IN ('ALL','Reciprocal','Parent')
   AND   REL.related_cust_account_id = ACCT_SITE.cust_account_id
   AND   ACCT_SITE.cust_acct_site_id = SITE.cust_acct_site_id
   AND   SITE.SITE_USE_CODE = 'BILL_TO'
   AND   SITE.status = 'A'
   AND   REL.org_id = l_org_id
 UNION
  SELECT SITE.site_use_id site_use_id
  FROM   HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
         HZ_CUST_SITE_USES_ALL SITE
  WHERE  ACCT_SITE.cust_account_id = p_cust_account_id
   AND   ACCT_SITE.cust_acct_site_id = SITE.cust_acct_site_id
   AND   SITE.SITE_USE_CODE = 'BILL_TO'
   AND   SITE.status = 'A'
   AND   SITE.org_id = l_org_id
) site_use
WHERE
      ps.class in ('CM') --class = Credit Memo
 AND  ps.status = 'OP' -- status = Open
 AND  ps.invoice_currency_code = p_currency_code --deduction currency code
 AND  ABS(ps.amount_due_remaining) BETWEEN  p_deduction_lower_amount AND p_deduction_upper_amount --deduction amount
 AND  ps.customer_site_use_id = site_use.site_use_id --deduction site_use_id / related customer site_use_id
 AND  ctt.type = 'CM'
 AND  ctt.cust_trx_type_id = ps.cust_trx_type_id --transaction type = Credit Memo
 AND  Normalize_Credit_Reference(ct.customer_reference) = p_ref_number
 AND  ct.customer_trx_id = ps.customer_trx_id
 AND  ps.org_id = l_org_id
 ORDER BY ct.creation_date ASC;


CURSOR csr_offer_info(p_ref_number VARCHAR2) IS
SELECT qp_list_header_id,offer_code
FROM   ozf_offers
WHERE  offer_code =p_ref_number;

CURSOR csr_claim_line_info (p_claim_id NUMBER) IS
SELECT claim_line_id,object_version_number
FROM   ozf_claim_lines_all
WHERE  claim_id = p_claim_id;

CURSOR csr_claim_line_util_info (p_claim_line_id NUMBER) IS
SELECT COUNT(*)
FROM   ozf_claim_lines_util_all
WHERE  claim_line_id = p_claim_line_id;

-- For PAD
l_offer_code VARCHAR2(30);
l_list_header_id NUMBER;
l_object_version_number NUMBER;
l_claim_line_id NUMBER;
l_claim_line_object_version NUMBER;
l_funds_util_flt      OZF_Claim_Accrual_PVT.funds_util_flt_type;
l_claim_line_tbl      OZF_CLAIM_LINE_PVT.claim_line_tbl_type;
l_claim_line_rec      OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_error_index         NUMBER;
l_ind NUMBER :=1;
l_count_earnings NUMBER := 0;


l_trx_id   NUMBER;
l_trx_number VARCHAR2(400);
l_crditmemo_amount NUMBER;
l_reference_number VARCHAR2(30);
l_refer_norm_number VARCHAR2(30);

l_possible_count NUMBER :=0;
l_exactfound_count NUMBER :=0;
l_accrual_count NUMBER :=0;

l_upper_thres_amount NUMBER :=0;
l_lower_thres_amount NUMBER :=0;

l_claimTbl               claimTbl;
l_amountTbl              amountTbl;
l_acctdamountTbl         acctdamountTbl;
l_claimidTbl             claimidTbl;
l_custrefdTbl            custrefdTbl;
l_custrefnormTbl         custrefnormTbl;
l_custaccountTbl         custaccountTbl;
l_custbilltositeTbl      custbilltositeTbl;
l_claimobjverTbl         claimobjverTbl;
l_curcodeTbl             curcodeTbl;
l_padTbl                 padTbl;
l_padnormTbl             padnormTbl;
l_siteUseIdTbl           siteUseIdTbl;
l_offerIdTbl               offerIdTbl;

l_possiblematchTbl      ozf_rule_match_tbl_type;
l_exactmatchTbl         ozf_rule_match_tbl_type;
l_accrualmatchTbl       ozf_accrual_match_tbl_type;


l_count NUMBER :=0;
l_rel_cust_account_id NUMBER;
l_found  BOOLEAN := false;

l_cm_match_found VARCHAR2(1) := 'F';


BEGIN

SAVEPOINT RuleBased;


OZF_Utility_PVT.write_conc_log('*------------------------------ Claims Rule Based Settlement Log ------------------------------*');
OZF_Utility_PVT.write_conc_log('Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
OZF_Utility_PVT.write_conc_log('*-------------------------------------------------------------------------------------------------*');

IF OZF_DEBUG_HIGH_ON THEN
   FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
   FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
   FND_MSG_PUB.Add;
END IF;



 IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.write_conc_log('Start Rule Based Settlement');
      OZF_Utility_PVT.write_conc_log('--- Start Parameter List ---');
      OZF_Utility_PVT.write_conc_log('l_org_id: '          || l_org_id);
      OZF_Utility_PVT.write_conc_log('p_start_date: '      || p_start_date);
      OZF_Utility_PVT.write_conc_log('p_end_date: '        || p_end_date);
      OZF_Utility_PVT.write_conc_log('p_pay_to_customer: ' || p_pay_to_customer);
      OZF_Utility_PVT.write_conc_log('--- End Parameter List -----');


   END IF;

  -- Check For Rule Based Settlemnet setup in System Parameter.
  OPEN chk_rule_based_csr;
  FETCH chk_rule_based_csr INTO l_enable_rule_based,l_cust_name_match_type,l_cre_threshold_type,l_cre_threshold_val;
  CLOSE chk_rule_based_csr;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.write_conc_log('Processing Claims for Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id));
      OZF_Utility_PVT.write_conc_log('Rule Based Settlement : '|| l_enable_rule_based);
      OZF_Utility_PVT.write_conc_log('Customer Name Matching Type : ' || l_cust_name_match_type);
      OZF_Utility_PVT.write_conc_log('Cr Threshold Type : ' || l_cre_threshold_type);
      OZF_Utility_PVT.write_conc_log('Cr Threshold Value : ' || l_cre_threshold_val);
    END IF;


  IF(l_enable_rule_based = 'F') THEN

        OZF_Utility_PVT.write_conc_log('Rule Based Flag is disabled in System Parameter page for Operating unit :' ||MO_GLOBAL.get_ou_name(l_org_id));
        OZF_Utility_PVT.write_conc_log('Please Enable the Rule Based Settlement checkbox to process the deductions');

  ELSE

        OZF_Utility_PVT.write_conc_log('Proceed with Rule Based Engine');


        IF p_start_date IS NOT NULL THEN
           l_start_date  := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
        ELSE
           l_start_date :=NULL;
        END IF ;

        IF p_end_date IS NOT NULL THEN
            l_end_date := to_date(p_end_date,  'YYYY/MM/DD HH24:MI:SS');
        ELSE
            l_end_date := NULL;
        END IF ;

        IF p_pay_to_customer IS NOT NULL THEN
            l_cust_account_number      := p_pay_to_customer ;
        ELSE
            l_cust_account_number := NULL;
        END IF ;


           IF OZF_DEBUG_HIGH_ON THEN
              OZF_Utility_PVT.write_conc_log('Operating Unit: ' || l_org_id);
              OZF_Utility_PVT.write_conc_log('Start Date: ' || l_start_date);
              OZF_Utility_PVT.write_conc_log('End Date: ' || l_end_date);
              OZF_Utility_PVT.write_conc_log('Customer Account: ' || l_cust_account_number);
           END IF;

        OPEN  open_ded_csr (l_cust_account_number,l_start_date,l_end_date);
        LOOP
           FETCH open_ded_csr BULK COLLECT INTO l_claimidTbl,l_claimTbl,l_amountTbl, l_acctdamountTbl,
                                                       l_custrefdTbl,l_custrefnormTbl,l_custaccountTbl,
                                                       l_custbilltositeTbl,l_claimobjverTbl,l_curcodeTbl,l_padTbl,
                                                       l_padnormTbl,l_siteUseIdTbl, l_offerIdTbl
                                                       LIMIT g_bulk_limit;

          FOR i IN NVL(l_claimidTbl.FIRST, 1) .. NVL(l_claimidTbl.LAST, 0) LOOP

             l_trx_id := null;
             l_trx_number := null;
             l_crditmemo_amount := null;
             l_reference_number := null;
             l_refer_norm_number := null;
	     l_cm_match_found := 'F';



            IF OZF_DEBUG_HIGH_ON THEN
              OZF_Utility_PVT.write_conc_log('-------------------------------------------------');
              OZF_Utility_PVT.write_conc_log('START : Fetching Claim ' || i);
              OZF_Utility_PVT.write_conc_log('-------------------------------------------------');
              OZF_Utility_PVT.write_conc_log('Claim ID: ' || l_claimidTbl(i));
              OZF_Utility_PVT.write_conc_log('Claim Number: ' || l_claimTbl(i));
              OZF_Utility_PVT.write_conc_log('Claim Amount: ' || l_amountTbl(i));
              OZF_Utility_PVT.write_conc_log('Claim Acctd Amount: ' || l_acctdamountTbl(i));
              OZF_Utility_PVT.write_conc_log('Customer Reference: ' || l_custrefdTbl(i));
              OZF_Utility_PVT.write_conc_log('Customer Reference Norm: ' || l_custrefnormTbl(i));
              OZF_Utility_PVT.write_conc_log('Customer Account: ' || l_custaccountTbl(i));
              OZF_Utility_PVT.write_conc_log('Customer Bill To: ' || l_custbilltositeTbl(i));
              OZF_Utility_PVT.write_conc_log('Claim Obj Version#: ' || l_claimobjverTbl(i));
              OZF_Utility_PVT.write_conc_log('Claim Currency Code: ' || l_curcodeTbl(i));
              OZF_Utility_PVT.write_conc_log('Claim PAD#: ' || l_padTbl(i));
              OZF_Utility_PVT.write_conc_log('Claim PAD NORM#: ' || l_padnormTbl(i));
              OZF_Utility_PVT.write_conc_log('Claim Site Used Id: ' || l_siteUseIdTbl(i));
              OZF_Utility_PVT.write_conc_log('Offer ID: ' || l_offerIdTbl(i));
            END IF;

             -- For 100% Credit Match
             IF(l_cust_name_match_type = 'EXCLUDE_REL_CUST') THEN
                OPEN csr_exact_cm_exc_cust(l_custaccountTbl(i),l_curcodeTbl(i),l_siteUseIdTbl(i),l_amountTbl(i),l_custrefnormTbl(i));
                   FETCH csr_exact_cm_exc_cust INTO l_trx_id,l_trx_number,l_crditmemo_amount;
                   IF OZF_DEBUG_HIGH_ON THEN
                        OZF_Utility_PVT.write_conc_log('100% Credit Match - Exclude Related Customer ');
                        OZF_Utility_PVT.write_conc_log('l_trx_id: ' ||l_trx_id);
                        OZF_Utility_PVT.write_conc_log('l_trx_number: ' || l_trx_number);
                        OZF_Utility_PVT.write_conc_log('l_crditmemo_amount: ' || l_crditmemo_amount);
                   END IF;
                CLOSE csr_exact_cm_exc_cust;
             ELSIF(l_cust_name_match_type = 'INCLUDE_REL_CUST') THEN
                OPEN csr_exact_cm_rel_cust(l_custaccountTbl(i),l_claimidTbl(i),l_curcodeTbl(i),l_amountTbl(i),l_custrefnormTbl(i));
                   FETCH csr_exact_cm_rel_cust INTO l_trx_id,l_trx_number,l_crditmemo_amount;
                   IF OZF_DEBUG_HIGH_ON THEN
                        OZF_Utility_PVT.write_conc_log('100% Credit Match - Include Related Customer');
                        OZF_Utility_PVT.write_conc_log('l_trx_id: ' ||l_trx_id);
                        OZF_Utility_PVT.write_conc_log('l_trx_number: ' || l_trx_number);
                        OZF_Utility_PVT.write_conc_log('l_crditmemo_amount: ' || l_crditmemo_amount);
                   END IF;
                CLOSE csr_exact_cm_rel_cust;
             END IF;

             IF (l_trx_id IS NOT NULL) THEN

                  l_claim_rec.claim_id := l_claimidTbl(i);
                  l_claim_rec.payment_method := 'PREV_OPEN_CREDIT';
                  l_claim_rec.payment_reference_number := l_trx_number;
                  l_claim_rec.payment_reference_id := l_trx_id;
                  l_claim_rec.object_version_number := l_claimobjverTbl(i);
                  l_claim_rec.status_code := 'CLOSED';
                  l_claim_rec.user_status_id := to_number(
                                              ozf_utility_pvt.get_default_user_status(
                                              p_status_type   => 'OZF_CLAIM_STATUS',
                                              p_status_code   => l_claim_rec.status_code));
                  l_claim_rec.request_id := NVL(FND_GLOBAL.CONC_REQUEST_ID,-1);
                  l_claim_rec.program_id := NVL(FND_GLOBAL.PROG_APPL_ID,-1);
                  l_claim_rec.settled_from := 'RULEBASED';

                      OZF_Claim_PVT.Update_Claim(
                                 p_api_version           => l_api_version
                                ,p_init_msg_list         => FND_API.g_false
                                ,p_commit                => FND_API.g_false
                                ,p_validation_level      => FND_API.g_valid_level_full
                                ,x_return_status         => l_return_status
                                ,x_msg_data              => l_msg_data
                                ,x_msg_count             => l_msg_count
                                ,p_claim                 => l_claim_rec
                                ,p_event                 => 'UPDATE'
                                ,p_mode                  => 'AUTO'
                                ,x_object_version_number => l_object_version_number
                                );
                 OZF_Utility_PVT.write_conc_log('Return Status for 100%: ' || l_return_status);

		  IF l_return_status = fnd_api.g_ret_sts_success THEN
                        l_cm_match_found := 'T';
                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                 l_exactfound_count := l_exactfound_count +1;
                 l_exactmatchTbl(l_exactfound_count).claim_id :=  l_claimidTbl(i);
                 l_exactmatchTbl(l_exactfound_count).claim_number :=  l_claimTbl(i);
                 l_exactmatchTbl(l_exactfound_count).credit_memo_number :=  l_trx_number;
                 l_exactmatchTbl(l_exactfound_count).claim_amount :=  l_amountTbl(i);
                 l_exactmatchTbl(l_exactfound_count).credit_amount :=  l_crditmemo_amount;
                 l_exactmatchTbl(l_exactfound_count).currency_code := l_curcodeTbl(i);
                 l_exactmatchTbl(l_exactfound_count).customer_trx_id :=  l_trx_id;

               -- If exact match found then go to next deduction
               GOTO END_OF_DEDUCTION;

             END IF;
             -- End For 100% Credit Match

             -- For Possible Match
              -- Find the threshold
             IF l_cre_threshold_type = '%' THEN
                l_upper_thres_amount := l_amountTbl(i) + (l_amountTbl(i) * l_cre_threshold_val / 100);
                l_lower_thres_amount := l_amountTbl(i) - (l_amountTbl(i) * l_cre_threshold_val / 100);
             ELSIF l_cre_threshold_type = 'AMT' THEN
                l_upper_thres_amount := l_amountTbl(i) + l_cre_threshold_val;
                l_lower_thres_amount := l_amountTbl(i) - l_cre_threshold_val;
             END IF;


             IF(l_cust_name_match_type = 'EXCLUDE_REL_CUST') THEN
                IF OZF_DEBUG_HIGH_ON THEN
                    OZF_Utility_PVT.write_conc_log('Possible Match - Exclude Related Customer');
                 END IF;

                OPEN csr_poss_cm_exc_cust(l_custaccountTbl(i),l_curcodeTbl(i),l_siteUseIdTbl(i),l_lower_thres_amount,l_upper_thres_amount,l_custrefnormTbl(i));
                  LOOP
                   FETCH csr_poss_cm_exc_cust INTO l_trx_id,l_trx_number,l_crditmemo_amount;
                   EXIT WHEN csr_poss_cm_exc_cust%NOTFOUND;
                   -- Populate the possible records
                   l_possible_count := l_possible_count +1;
                   l_possiblematchTbl(l_possible_count).claim_id :=  l_claimidTbl(i);
                   l_possiblematchTbl(l_possible_count).claim_number :=  l_claimTbl(i);
                   l_possiblematchTbl(l_possible_count).credit_memo_number :=  l_trx_number;
                   l_possiblematchTbl(l_possible_count).claim_amount :=  l_amountTbl(i);
                   l_possiblematchTbl(l_possible_count).credit_amount :=  l_crditmemo_amount;
                   l_possiblematchTbl(l_possible_count).currency_code := l_curcodeTbl(i);
                   l_possiblematchTbl(l_possible_count).customer_trx_id :=  l_trx_id;

		   IF OZF_DEBUG_HIGH_ON THEN
                    OZF_Utility_PVT.write_conc_log('Possible Match - l_trx_id :' || l_trx_id);
                   END IF;

		   IF(l_trx_id IS NOT NULL) THEN
		        l_cm_match_found := 'T';
		   END IF;

		   END LOOP;

                CLOSE csr_poss_cm_exc_cust;

              ELSIF(l_cust_name_match_type = 'INCLUDE_REL_CUST') THEN
                IF OZF_DEBUG_HIGH_ON THEN
                    OZF_Utility_PVT.write_conc_log('Possible Match - Include Related Customer');
                END IF;


                OPEN csr_poss_cm_rel_cust(l_custaccountTbl(i),l_claimidTbl(i),l_curcodeTbl(i),l_lower_thres_amount,l_upper_thres_amount,l_custrefnormTbl(i));
                  LOOP
                   FETCH csr_poss_cm_rel_cust INTO l_trx_id,l_trx_number,l_crditmemo_amount;
                   EXIT WHEN csr_poss_cm_rel_cust%NOTFOUND;
                   l_possible_count := l_possible_count +1;
                   l_possiblematchTbl(l_possible_count).claim_id :=  l_claimidTbl(i);
                   l_possiblematchTbl(l_possible_count).claim_number :=  l_claimTbl(i);
                   l_possiblematchTbl(l_possible_count).credit_memo_number :=  l_trx_number;
                   l_possiblematchTbl(l_possible_count).claim_amount :=  l_amountTbl(i);
                   l_possiblematchTbl(l_possible_count).credit_amount :=  l_crditmemo_amount;
                   l_possiblematchTbl(l_possible_count).currency_code := l_curcodeTbl(i);
                   l_possiblematchTbl(l_possible_count).customer_trx_id :=  l_trx_id;

		   IF OZF_DEBUG_HIGH_ON THEN
                    OZF_Utility_PVT.write_conc_log('Possible Match - l_trx_id :' || l_trx_id);
                   END IF;

		   IF(l_trx_id IS NOT NULL) THEN
		        l_cm_match_found := 'T';
		   END IF;

		  END LOOP;

                 CLOSE csr_poss_cm_rel_cust;

                END IF;
                -- If possible match found then go to next deduction
		 IF OZF_DEBUG_HIGH_ON THEN
                    OZF_Utility_PVT.write_conc_log('l_possiblematchTbl.count :' || l_possiblematchTbl.count);
		    OZF_Utility_PVT.write_conc_log('l_cm_match_found :' || l_cm_match_found);
                END IF;

		IF (l_possiblematchTbl.count > 0 AND l_cm_match_found = 'T' )THEN
		   GOTO END_OF_DEDUCTION;
                END IF;

        BEGIN
         SAVEPOINT  Update_Claim_From_Association;

        IF (l_padnormTbl(i) IS NOT NULL) THEN

          l_list_header_id := l_offerIdTbl(i);
          l_offer_code := l_padnormTbl(i);

            IF OZF_DEBUG_HIGH_ON THEN
                 OZF_Utility_PVT.write_conc_log('Offer Found: ' || l_offer_code);
                 OZF_Utility_PVT.write_conc_log('Offer ID: ' || l_list_header_id);
            END IF;


           IF l_list_header_id IS NULL THEN
             IF OZF_DEBUG_HIGH_ON THEN
                 OZF_Utility_PVT.write_conc_log('Invalid PAD Number ' || l_padnormTbl(i));
            END IF;

           ELSE

           l_ind :=1;
           OPEN csr_claim_line_info(l_claimidTbl(i));
            LOOP
              FETCH csr_claim_line_info into l_claim_line_id, l_claim_line_object_version;
              EXIT when csr_claim_line_info%NOTFOUND;
              l_claim_line_tbl(l_ind).claim_line_id := l_claim_line_id;
              l_claim_line_tbl(l_ind).object_version_number := l_claim_line_object_version;
              l_ind := l_ind +1;
            END LOOP;
           CLOSE csr_claim_line_info;


          IF(l_claim_line_tbl.COUNT > 0 ) THEN
           -- delete the claim line if there is any
           OZF_Claim_Line_PVT.Delete_Claim_Line_Tbl(
                     p_api_version            => l_api_version
                    ,p_init_msg_list          => FND_API.g_false
                    ,p_commit                 => FND_API.g_false
                    ,p_validation_level       => FND_API.g_valid_level_full
                    ,x_return_status          => l_return_status
                    ,x_msg_count              => l_msg_count
                    ,x_msg_data               => l_msg_data
                    ,p_claim_line_tbl         => l_claim_line_tbl
                    ,p_change_object_version  => FND_API.g_false
                    ,x_error_index            => l_error_index
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
          END IF; -- End of delete claim line

          IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.write_conc_log('Claim Line Deleted');
          END IF;

          l_claim_line_rec.claim_id              := l_claimidTbl(i);
          l_claim_line_rec.activity_type         := 'OFFR';
          l_claim_line_rec.activity_id           := l_list_header_id;
          l_claim_line_rec.currency_code         := l_curcodeTbl(i);
          l_claim_line_rec.amount                := l_amountTbl(i);
          l_claim_line_rec.acctd_amount          := l_acctdamountTbl(i);
          l_claim_line_rec.claim_currency_amount := l_amountTbl(i);

          -- New claim line creation
          OZF_Claim_Line_PVT.Create_Claim_Line(
                 p_api_version       => 1.0
               , p_init_msg_list     => FND_API.g_false
               , p_commit            => FND_API.g_false
               , p_validation_level  => FND_API.g_valid_level_full
               , x_return_status     => l_return_status
               , x_msg_data          => l_msg_data
               , x_msg_count         => l_msg_count
               , p_claim_line_rec    => l_claim_line_rec
               , p_mode              => OZF_CLAIM_UTILITY_PVT.g_auto_mode
               , x_claim_line_id     => l_claim_line_id
          );
          IF l_return_status =  fnd_api.g_ret_sts_error THEN
                 RAISE FND_API.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
          END IF;

          IF OZF_DEBUG_HIGH_ON THEN
                OZF_Utility_PVT.write_conc_log('Claim Line Created');
                OZF_Utility_PVT.write_conc_log('New Claim Line Created' || l_claim_line_id);
          END IF;

          -- Associate Accruals to Claim Line
          OZF_Claim_Accrual_PVT.Asso_Accruals_To_Claim_Line(
                         p_api_version         => 1.0
                        ,p_init_msg_list       => FND_API.g_false
                        ,p_commit              => FND_API.g_false
                        ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                        ,x_return_status       => l_return_status
                        ,x_msg_count           => l_msg_count
                        ,x_msg_data            => l_msg_data
                        ,p_claim_line_id       => l_claim_line_id
                      );

              OZF_Utility_PVT.write_conc_log('Return Status for Asso_Accruals_To_Claim_Line: ' || l_return_status);

              IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_error;
              END IF;


             OPEN csr_claim_line_util_info (l_claim_line_id);
              FETCH csr_claim_line_util_info INTO l_count_earnings;
             CLOSE csr_claim_line_util_info;

              -- Need to check here add the return status check as yes
              IF (l_count_earnings = 0) THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                      FND_MESSAGE.set_name('OZF', 'OZF_EARN_AVAIL_AMT_ZERO');
                      FND_MSG_PUB.add;
                 END IF;
                    ROLLBACK TO Update_Claim_From_Association;
              ELSE
              -- Initiate the Settlement
                  l_claim_rec.claim_id := l_claimidTbl(i);
                  l_claim_rec.payment_method := 'CREDIT_MEMO';
                  l_claim_rec.object_version_number := l_claimobjverTbl(i);
                  l_claim_rec.status_code := 'CLOSED';
                  l_claim_rec.user_status_id := to_number(
                                              ozf_utility_pvt.get_default_user_status(
                                              p_status_type   => 'OZF_CLAIM_STATUS',
                                              p_status_code   => l_claim_rec.status_code));
                  l_claim_rec.request_id := NVL(FND_GLOBAL.CONC_REQUEST_ID,-1);
                  l_claim_rec.program_id := NVL(FND_GLOBAL.PROG_APPL_ID,-1);
                  l_claim_rec.settled_from := 'RULEBASED';

                        OZF_Claim_PVT.Update_Claim(
                                 p_api_version           => l_api_version
                                ,p_init_msg_list         => FND_API.g_false
                                ,p_commit                => FND_API.g_false
                                ,p_validation_level      => FND_API.g_valid_level_full
                                ,x_return_status         => l_return_status
                                ,x_msg_data              => l_msg_data
                                ,x_msg_count             => l_msg_count
                                ,p_claim                 => l_claim_rec
                                ,p_event                 => 'UPDATE'
                                ,p_mode                  => 'AUTO'
                                ,x_object_version_number => l_object_version_number
                                );
                          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          END IF;

                 END IF; -- End of Association check
                     -- Populate the accrual records
                      l_accrual_count := l_accrual_count +1;
                      l_accrualmatchTbl(l_accrual_count).claim_id  :=  l_claimidTbl(i);
                      l_accrualmatchTbl(l_accrual_count).claim_number  :=  l_claimTbl(i);
                      l_accrualmatchTbl(l_accrual_count).Offer_Code        :=  l_offer_code;
                      l_accrualmatchTbl(l_accrual_count).claim_amount  :=  l_amountTbl(i);
                      l_accrualmatchTbl(l_accrual_count).currency_code  :=  l_curcodeTbl(i);
                      l_accrualmatchTbl(l_accrual_count).qp_list_header_id :=  l_list_header_id;

          END IF; -- End of Offer Check

        END IF; -- End of PAD check

       EXCEPTION
          WHEN FND_API.g_exc_error THEN
          ROLLBACK TO Update_Claim_From_Association;
          OZF_Utility_PVT.write_conc_log('Expected errors:l_msg_count' || l_msg_count);
           IF OZF_DEBUG_HIGH_ON THEN
            OZF_UTILITY_PVT.write_conc_log;
           ELSE
             FOR I IN 1..l_msg_count LOOP
               IF I = l_msg_count THEN
                OZF_Utility_PVT.write_conc_log(SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254));
               END IF;
             END LOOP;
           END IF;

         WHEN FND_API.g_exc_unexpected_error THEN
          ROLLBACK TO Update_Claim_From_Association;
          OZF_Utility_PVT.write_conc_log('Unexpected errors:l_msg_count' || l_msg_count);
          IF OZF_DEBUG_HIGH_ON THEN
            OZF_UTILITY_PVT.write_conc_log;
          ELSE
             FOR I IN 1..l_msg_count LOOP
               IF I = l_msg_count THEN
                OZF_Utility_PVT.write_conc_log(SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254));
               END IF;
             END LOOP;
          END IF;

          WHEN OTHERS THEN
          ROLLBACK TO Update_Claim_From_Association;
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.write_conc_log('Fail For Deduction OTHERS : ' || l_claimTbl(i) || ' - Error Message: ' || SQLERRM);
            END IF;

            FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => l_msg_count
          ,p_data    => l_msg_data
          );

        END;

    <<END_OF_DEDUCTION>>
    NULL;
    END LOOP;
   EXIT WHEN open_ded_csr%NOTFOUND;
  END LOOP;
     -- Need to Call the Log procedure
        IF OZF_DEBUG_HIGH_ON THEN
                OZF_Utility_PVT.write_conc_log('Credit Count' || l_exactmatchTbl.count);
                OZF_Utility_PVT.write_conc_log('Credit Possible Count' || l_possiblematchTbl.count);
                OZF_Utility_PVT.write_conc_log('Accrual Count' || l_accrualmatchTbl.count);
        END IF;

        -- For logging
                Create_Log(
                           p_api_version         => 1.0
                          ,p_init_msg_list       => FND_API.g_false
                          ,p_commit              => FND_API.g_false
                          ,p_validation_level    => FND_API.g_valid_level_full
                          ,p_exact_match_tbl     => l_exactmatchTbl
                          ,p_possible_match_tbl  => l_possiblematchTbl
                          ,p_accrual_match_tbl   => l_accrualmatchTbl
                          ,x_return_status       => l_return_status
                          ,x_msg_count           => l_msg_data
                          ,x_msg_data            => l_msg_count
                        );

                 IF l_return_status =  fnd_api.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                         RAISE FND_API.g_exc_unexpected_error;
                 END IF;

     CLOSE open_ded_csr;


  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO RuleBased;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '===> Failed.');
        OZF_UTILITY_PVT.write_conc_log;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Rule Based Engine Failed. ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : ' || FND_MSG_PUB.get(FND_MSG_PUB.count_msg, FND_API.g_false));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO RuleBased;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '===> Failed.');
        OZF_UTILITY_PVT.write_conc_log;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Rule Based Engine Failed. ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : ' || FND_MSG_PUB.get(FND_MSG_PUB.count_msg, FND_API.g_false));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

 WHEN OTHERS THEN
        ROLLBACK TO RuleBased;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '===> Failed.');
        IF OZF_DEBUG_HIGH_ON THEN
           FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
           FND_MESSAGE.Set_Token('TEXT',sqlerrm);
           FND_MSG_PUB.Add;
        END IF;
        OZF_UTILITY_PVT.write_conc_log;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Rule Based Engine Failed. ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : ' || SQLCODE||SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
 END Start_Rule_Based_Settlement;


End OZF_claim_Utility_pvt;


/
