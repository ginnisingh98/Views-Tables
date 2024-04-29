--------------------------------------------------------
--  DDL for Package AMS_CLAIM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CLAIM_GRP" AUTHID CURRENT_USER as
/* $Header: amsgclas.pls 115.13 2004/04/06 19:33:41 julou ship $ */
-- Start of Comments
-- Package name     : AMS_claim_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:DEDUCTION_REC_TYPE
--   -------------------------------------------------------
--       CLAIM_ID
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
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments


TYPE DEDUCTION_REC_TYPE IS RECORD
(
       CLAIM_ID                        NUMBER := FND_API.G_MISS_NUM,
       CLAIM_NUMBER                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CLAIM_TYPE_ID                   NUMBER := FND_API.G_MISS_NUM,
       CLAIM_DATE                      DATE := FND_API.G_MISS_DATE,
       DUE_DATE                        DATE := FND_API.G_MISS_DATE,
       OWNER_ID                        NUMBER := FND_API.G_MISS_NUM,
       AMOUNT                          NUMBER := FND_API.G_MISS_NUM,
       CURRENCY_CODE                   VARCHAR2(15) := FND_API.G_MISS_CHAR,
       EXCHANGE_RATE_TYPE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       EXCHANGE_RATE_DATE              DATE := FND_API.G_MISS_DATE,
       EXCHANGE_RATE                   NUMBER := FND_API.G_MISS_NUM,
       SET_OF_BOOKS_ID                 NUMBER := FND_API.G_MISS_NUM,
       SOURCE_OBJECT_ID                NUMBER := FND_API.G_MISS_NUM,
       SOURCE_OBJECT_CLASS             VARCHAR2(15) := FND_API.G_MISS_CHAR,
       SOURCE_OBJECT_TYPE_ID           NUMBER := FND_API.G_MISS_NUM,
       SOURCE_OBJECT_NUMBER            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CUST_ACCOUNT_ID                 NUMBER := FND_API.G_MISS_NUM,
       CUST_BILLTO_ACCT_SITE_ID        NUMBER := FND_API.G_MISS_NUM,
       CUST_SHIPTO_ACCT_SITE_ID        NUMBER := FND_API.G_MISS_NUM,
       LOCATION_ID                     NUMBER := FND_API.G_MISS_NUM,
       REASON_CODE_ID                  NUMBER := FND_API.G_MISS_NUM,
       STATUS_CODE                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       USER_STATUS_ID                  NUMBER := FND_API.G_MISS_NUM,
       SALES_REP_ID                    NUMBER := FND_API.G_MISS_NUM,
       COLLECTOR_ID                    NUMBER := FND_API.G_MISS_NUM,
       CONTACT_ID                      NUMBER := FND_API.G_MISS_NUM,
       BROKER_ID                       NUMBER := FND_API.G_MISS_NUM,
       CUSTOMER_REF_DATE               DATE := FND_API.G_MISS_DATE,
       CUSTOMER_REF_NUMBER             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       RECEIPT_ID                      NUMBER := FND_API.G_MISS_NUM,
       RECEIPT_NUMBER                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
       GL_DATE                         DATE := FND_API.G_MISS_DATE,
       COMMENTS                        VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE_CATEGORY    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE1            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE2            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE3            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE4            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE5            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE6            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE7            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE8            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE9            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE10           VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE11           VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE12           VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE13           VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE14           VARCHAR2(150) := FND_API.G_MISS_CHAR,
       DEDUCTION_ATTRIBUTE15           VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ORG_ID                          NUMBER := FND_API.G_MISS_NUM
);


G_MISS_DEDUCTION_REC          DEDUCTION_REC_TYPE;
TYPE  DEDUCTION_TBL_TYPE      IS TABLE OF DEDUCTION_REC_TYPE INDEX BY BINARY_INTEGER;
G_MISS_DEDUCTION_TBL          DEDUCTION_TBL_TYPE;


TYPE DEDUCTION_SORT_REC_TYPE IS RECORD
(
      -- PLEASE DEFINE YOUR OWN SORT BY RECORD HERE.
      OBJECT_VERSION_NUMBER   NUMBER := NULL
);





--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Deduction
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_Deduction               IN Deduction_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER,
--       x_claim_number            OUT  VARCHAR2
--   Version : Current version 1.0
--
--   Note: This procedure checks information passed from AR to Claim module and then
--   calls Creat_claim function in the private package to create a claim record.
--   It returns a claim_id and cliam_number as the result.
--
--   End of Comments
--
PROCEDURE Create_Deduction(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_Deduction                  IN   Deduction_Rec_Type  := G_MISS_deduction_REC,
    X_CLAIM_ID                   OUT NOCOPY  NUMBER,
    X_CLAIM_NUMBER               OUT NOCOPY  VARCHAR2
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
--   Version : Current version 1.0
--
--   Note: This procedure update a deduction. It calls the Update_Deduction function in the private
--   package.
--
--   End of Comments
--
PROCEDURE Update_Deduction(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_Deduction                  IN    Deduction_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER
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
--   OUT:
--       x_status                OUT  BOOLEAN
--   Version : Current version 1.0
--
--   Note: This function checks whether a claims can be cancelled or not.
--
--   End of Comments
--
FUNCTION Check_Cancell_Deduction(
    P_Claim_Id   NUMBER
) return boolean;

End AMS_claim_GRP;

 

/
