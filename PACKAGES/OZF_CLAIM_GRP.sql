--------------------------------------------------------
--  DDL for Package OZF_CLAIM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_GRP" AUTHID CURRENT_USER AS
/* $Header: ozfgclas.pls 120.3 2005/12/15 01:42:35 azahmed ship $ */
-- Start of Comments
-- Package name     : OZF_CLAIM_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

G_DEBUG_MODE             BOOLEAN := FALSE;

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:DEDUCTION_REC_TYPE
--   -------------------------------------------------------
--       CLAIM_ID
--       OBJECT_VERSION_NUMBER   --Bug:2781186
--       CLAIM_NUMBER
--       CLAIM_TYPE_ID
--       CLAIM_DATE
--       DUE_DATE
--       OWNER_ID
--       AMOUNT
--       CURRENCY_CODE
--       EXCHANGE_RATE_TYPE
--       EXCHANGE_RATE_DATE
--       EXCHANGE_RATE
--       SET_OF_BOOKS_ID
--       SOURCE_OBJECT_ID
--       SOURCE_OBJECT_CLASS
--       SOURCE_OBJECT_TYPE_ID
--       SOURCE_OBJECT_NUMBER
--       CUST_ACCOUNT_ID
--       CUST_BILLTO_ACCT_SITE_ID
--       CUST_SHIPTO_ACCT_SITE_ID
--       LOCATION_ID
--       REASON_CODE_ID
--       STATUS_CODE
--       SALES_REP_ID
--       COLLECTOR_ID
--       CONTACT_ID
--       BROKER_ID
--       CUSTOMER_REF_DATE
--       CUSTOMER_REF_NUMBER
--       RECEIPT_ID
--       RECEIPT_NUMBER
--       GL_DATE
--       COMMENTS
--       DEDUCTION_ATTRIBUTE_CATEGORY
--       DEDUCTION_ATTRIBUTE1
--       DEDUCTION_ATTRIBUTE2
--       DEDUCTION_ATTRIBUTE3
--       DEDUCTION_ATTRIBUTE4
--       DEDUCTION_ATTRIBUTE5
--       DEDUCTION_ATTRIBUTE6
--       DEDUCTION_ATTRIBUTE7
--       DEDUCTION_ATTRIBUTE8
--       DEDUCTION_ATTRIBUTE9
--       DEDUCTION_ATTRIBUTE10
--       DEDUCTION_ATTRIBUTE11
--       DEDUCTION_ATTRIBUTE12
--       DEDUCTION_ATTRIBUTE13
--       DEDUCTION_ATTRIBUTE14
--       DEDUCTION_ATTRIBUTE15
--       ORG_ID
--       CUSTOMER_REASON
--       APPLIED_DATE
--       APPLIED_ACTION_TYPE
--       AMOUNT_APPLIED
--       APPLIED_RECEIPT_ID
--       APPLIED_RECEIPT_NUMBER
--
--    Required:
--    Defaults:
--    Note:
--
--   End of Comments

TYPE DEDUCTION_REC_TYPE IS RECORD
(
        CLAIM_ID                        NUMBER
       ,OBJECT_VERSION_NUMBER           NUMBER
       ,CLAIM_NUMBER                    VARCHAR2(30)
       ,CLAIM_TYPE_ID                   NUMBER
       ,CLAIM_DATE                      DATE
       ,DUE_DATE                        DATE
       ,OWNER_ID                        NUMBER
       ,AMOUNT                          NUMBER
       ,AMOUNT_ADJUSTED                 NUMBER
       ,AMOUNT_REMAINING                NUMBER
       ,AMOUNT_SETTLED                  NUMBER
       ,CURRENCY_CODE                   VARCHAR2(15)
       ,EXCHANGE_RATE_TYPE              VARCHAR2(30)
       ,EXCHANGE_RATE_DATE              DATE
       ,EXCHANGE_RATE                   NUMBER
       ,SET_OF_BOOKS_ID                 NUMBER
       ,SOURCE_OBJECT_ID                NUMBER
       ,SOURCE_OBJECT_CLASS             VARCHAR2(15)
       ,SOURCE_OBJECT_TYPE_ID           NUMBER
       ,SOURCE_OBJECT_NUMBER            VARCHAR2(30)
       ,CUST_ACCOUNT_ID                 NUMBER
       ,SHIP_TO_CUST_ACCOUNT_ID         NUMBER
       ,CUST_BILLTO_ACCT_SITE_ID        NUMBER
       ,CUST_SHIPTO_ACCT_SITE_ID        NUMBER
       ,LOCATION_ID                     NUMBER
       ,REASON_CODE_ID                  NUMBER
       ,STATUS_CODE                     VARCHAR2(30)
       ,USER_STATUS_ID                  NUMBER
       ,SALES_REP_ID                    NUMBER
       ,COLLECTOR_ID                    NUMBER
       ,CONTACT_ID                      NUMBER
       ,BROKER_ID                       NUMBER
       ,CUSTOMER_REF_DATE               DATE
       ,CUSTOMER_REF_NUMBER             VARCHAR2(30)
       ,RECEIPT_ID                      NUMBER
       ,RECEIPT_NUMBER                  VARCHAR2(30)
       ,GL_DATE                         DATE
       ,COMMENTS                        VARCHAR2(2000)
       ,DEDUCTION_ATTRIBUTE_CATEGORY    VARCHAR2(30)
       ,DEDUCTION_ATTRIBUTE1            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE2            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE3            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE4            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE5            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE6            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE7            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE8            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE9            VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE10           VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE11           VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE12           VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE13           VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE14           VARCHAR2(150)
       ,DEDUCTION_ATTRIBUTE15           VARCHAR2(150)
       ,ORG_ID                          NUMBER
       ,CUSTOMER_REASON                 VARCHAR2(30)
       ,APPLIED_DATE                    DATE
       ,APPLIED_ACTION_TYPE             VARCHAR2(1)
       ,AMOUNT_APPLIED                  NUMBER
       ,APPLIED_RECEIPT_ID              NUMBER
       ,APPLIED_RECEIPT_NUMBER          VARCHAR2(30)
       ,LEGAL_ENTITY_ID                 NUMBER
);


G_DEDUCTION_REC               DEDUCTION_REC_TYPE;

TYPE DEDUCTION_TBL_TYPE IS TABLE OF DEDUCTION_REC_TYPE INDEX BY BINARY_INTEGER;
G_DEDUCTION_TBL                DEDUCTION_TBL_TYPE;

TYPE CLAIM_NOTES_REC_TYPE IS RECORD
(
       CLAIM_NOTES                      VARCHAR2(2000)
);

TYPE  CLAIM_NOTES_TBL_TYPE   IS TABLE OF CLAIM_NOTES_REC_TYPE
INDEX BY BINARY_INTEGER;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Deduction
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER             Required
--       p_init_msg_list           IN   VARCHAR2           Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2           Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER             Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_deduction               IN   DEDUCTION_REC_TYPE Required  Default = G_DEDUCTION_REC
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER,
--       x_claim_number            OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   Note: This procedure checks information passed from AR to Trade Mgt Claim module
--         and then calls Creat_claim function in the private package to create a
--         claim record. It returns a claim_id and cliam_number as the result.
--
--   End of Comments
--  *******************************************************
PROCEDURE Create_Deduction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_deduction                  IN   DEDUCTION_REC_TYPE  := G_DEDUCTION_REC,
    x_claim_id                   OUT  NOCOPY NUMBER,
    x_claim_number               OUT  NOCOPY VARCHAR2
);


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Deduction
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER              Required
--       p_init_msg_list           IN   VARCHAR2            Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2            Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER              Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_Deduction               IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER,
--       x_claim_number            OUT  VARCHAR2
--       x_claim_reason_code_id    OUT  NUMBER
--       x_claim_reason_name       OUT  NAME

--   Version : Current version 1.0
--
--   Note: This procedure checks information passed from AR to Claim module and then
--   calls Creat_claim function in the private package to create a claim record.
--   It returns a claim_id,cliam_number,reason_code_id,reason_name as the result.
--
--   End of Comments
--  *******************************************************
PROCEDURE Create_Deduction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_deduction                  IN   DEDUCTION_REC_TYPE  := G_DEDUCTION_REC,
    x_claim_id                   OUT  NOCOPY NUMBER,
    x_claim_number               OUT  NOCOPY VARCHAR2,
    x_claim_reason_code_id       OUT  NOCOPY NUMBER,
    x_claim_reason_name          OUT  NOCOPY VARCHAR2
);



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Deduction
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_Deduction              IN Deduction_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_object_version_number   OUT  NUMBER
--
--   Version : Current version 1.0
--
--   Note: This procedure update a deduction. It calls the Update_Deduction function in the private
--   package.
--
--   End of Comments
--  *******************************************************
PROCEDURE Update_Deduction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_deduction                  IN   DEDUCTION_REC_TYPE,
    x_object_version_number      OUT  NOCOPY NUMBER
);


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Deduction
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER              Required
--       p_init_msg_list           IN   VARCHAR2            Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2            Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER              Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_Deduction               IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_object_version_number   OUT  NUMBER
--       x_claim_reason_code_id    OUT  NUMBER
--       x_claim_reason_name       OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   Note: This procedure update a deduction. It calls the Update_Deduction function in the private
--   package.
--
--   End of Comments
--  *******************************************************
PROCEDURE Update_Deduction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_deduction                  IN   Deduction_Rec_Type,
    x_object_version_number      OUT  NOCOPY NUMBER,
    x_claim_reason_code_id       OUT  NOCOPY NUMBER,
    x_claim_reason_name          OUT  NOCOPY VARCHAR2,
    x_claim_id                   OUT  NOCOPY NUMBER,
    x_claim_number               OUT  NOCOPY VARCHAR2
);


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_Cancell_Deduction
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       P_Claim_Id  NUMBER     Required
--
--   Version : Current version 1.0
--
--   Note: This function checks whether a claims can be cancelled or not.
--
--   End of Comments
--  *******************************************************
FUNCTION Check_Cancell_Deduction(
    p_claim_id   NUMBER
)
RETURN BOOLEAN;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_Open_Claims
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_object_source_id      IN   NUMBER
--       p_receipt_id            IN   NUMBER  Required

--   Version : Current version 1.0
--
--   Note: This function checks whether a claim exists in TM in OPEN status.
--
--   End of Comments
--  *******************************************************
FUNCTION Check_Open_Claims(
    p_customer_trx_id   NUMBER,
    p_receipt_id        NUMBER
)
RETURN BOOLEAN;


--  ******************************************************
--   Start of Comments
--  *******************************************************
--   API Name:  Get_Claim_Addtional_Info
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN :
--       p_source_object_id  IN   NUMBER     Required
--
--   OUT:
--       x_application_ref_num
--       x_secondary_appl_ref_id
--       x_customer_referenc
--
--   Note: The procedure returns claim number, claim id, customer reference
--         for invoice related deduction.
--
--   Version : Current version 1.0
--
--  End of Comments
--  *******************************************************
PROCEDURE Get_Claim_Additional_Info(
    p_customer_trx_id         IN   NUMBER,
    x_application_ref_num     OUT  NOCOPY VARCHAR2,
    x_secondary_appl_ref_id   OUT  NOCOPY NUMBER,
    x_customer_reference      OUT  NOCOPY VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Build_Note
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_message_name      IN   VARCHAR2  Required
--       p_token_1           IN   VARCHAR2  Optional Default:= null
--       p_token_2           IN   VARCHAR2  Optional Default:= null
--       p_token_3           IN   VARCHAR2  Optional Default:= null
--       p_token_4           IN   VARCHAR2  Optional Default:= null
--       p_token_5           IN   VARCHAR2  Optional Default:= null
--       p_token_6           IN   VARCHAR2  Optional Default:= null

--   Version : Current version 1.0
--
--   Note: This function builds a message given the name of the message and tokens
--   bugfix 4869928
--   End of Comments
--  *******************************************************

FUNCTION Build_Note (
  p_message_name IN    VARCHAR2
, p_token_1        IN    VARCHAR2:= NULL
, p_token_2        IN    VARCHAR2:= NULL
, p_token_3        IN    VARCHAR2:= NULL
, p_token_4        IN    VARCHAR2:= NULL
, p_token_5        IN    VARCHAR2:= NULL
, p_token_6        IN    VARCHAR2:= NULL
)
RETURN VARCHAR2;


END OZF_CLAIM_GRP;

 

/
