--------------------------------------------------------
--  DDL for Package OZF_CLAIM_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvcuts.pls 120.0.12010000.2 2009/07/23 17:20:10 kpatro ship $ */
-- Start of Comments
-- Package name     : OZF_claim_Utility_pvt
-- Purpose          :
-- History          :
--          20-=May-2009  KPATRO Rule Based Settlement Enhancement
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
G_AUTO_MODE  CONSTANT VARCHAR2(4) := 'AUTO';
G_MANU_MODE  CONSTANT VARCHAR2(4) := 'MANU';
G_REQUEST_MODE  CONSTANT VARCHAR2(7) := 'REQUEST';

TYPE ozf_rule_match_rec_type IS RECORD(
      claim_id               NUMBER,
      claim_number           VARCHAR2(30),
      credit_memo_number     VARCHAR2(30),
      claim_amount           NUMBER,
      credit_amount          NUMBER,
      currency_code          VARCHAR2(30),
      customer_trx_id        NUMBER
   );

TYPE ozf_rule_match_tbl_type IS TABLE OF ozf_rule_match_rec_type
INDEX BY BINARY_INTEGER;


TYPE ozf_accrual_match_rec_type IS RECORD(
      claim_id               NUMBER,
      claim_number           VARCHAR2(30),
      Offer_Code             VARCHAR2(30),
      claim_amount           NUMBER,
      currency_code          VARCHAR2(30),
      qp_list_header_id      NUMBER
    );

TYPE ozf_accrual_match_tbl_type IS TABLE OF ozf_accrual_match_rec_type
INDEX BY BINARY_INTEGER;

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
--       x_access                  OUT  VARCHAR2
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
    );

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
PROCEDURE Normalize_Customer_Reference(
    p_customer_reference         IN   VARCHAR2,
    x_normalized_reference       OUT NOCOPY  VARCHAR2
    );

-- Added For Rule Based Settlement
---------------------------------------------------------------------
-- FUNCTION
--    Normalize_Credit_Reference
--
-- PURPOSE
--    Returns the normalized for Customer Reference.
--
-- PARAMETERS
--    p_credit_ref
--
-- NOTES

-- HISTORY
--   21-MAY-2009  KPATRO  Create.
---------------------------------------------------------------------
FUNCTION Normalize_Credit_Reference
        (p_credit_ref  IN  VARCHAR2)
RETURN VARCHAR2;

---------------------------------------------------------------------
-- PROCEDURE
--   Start_Rule_Based_Settlement
--
-- PARAMETERS
--    ERRBUF             : Standard Concurrenct Progarm's parameter
--    RETCODE            : Standard Concurrenct Progarm's parameter
--    p_start_date       : Deduction Start Date
--    p_end_date         : Deduction Start Date
--    p_pay_to_customer  : Customer Name
--
--
-- NOTE
--   This program will process the deductions based on the input parameter to Rule
--   Based Engine.
--
--
-- HISTORY
--   21-MAY-2009  KPATRO  Create.
---------------------------------------------------------------------
PROCEDURE Start_Rule_Based_Settlement (
    ERRBUF                           OUT NOCOPY VARCHAR2,
    RETCODE                          OUT NOCOPY NUMBER,
    p_start_date                     IN VARCHAR2,
    p_end_date                       IN VARCHAR2,
    p_pay_to_customer                IN VARCHAR2 := NULL
);

---------------------------------------------------------------------
-- PROCEDURE
--   Create_Log
--
-- PARAMETERS
--    p_exact_match_tbl     : Exact Matched Deductions
--    p_possible_match_tbl  : Possible Matched Deductions
--    p_accrual_match_tbl   : Accrual Matched Deductions
--
--
-- NOTE
--   1. This is to create a audit trail for all the deduction
--    processed by Rule Based Engine.
--
-- HISTORY
--   21-MAY-2009  KPATRO  Create.
---------------------------------------------------------------------


PROCEDURE Create_Log(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,p_exact_match_tbl     IN  ozf_rule_match_tbl_type
  ,p_possible_match_tbl  IN  ozf_rule_match_tbl_type
  ,p_accrual_match_tbl   IN  ozf_accrual_match_tbl_type
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
);



End OZF_claim_Utility_pvt;

/
