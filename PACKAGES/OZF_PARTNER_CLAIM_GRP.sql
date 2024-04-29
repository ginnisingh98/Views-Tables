--------------------------------------------------------
--  DDL for Package OZF_PARTNER_CLAIM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PARTNER_CLAIM_GRP" AUTHID CURRENT_USER AS
/* $Header: ozfgpcls.pls 115.0 2003/11/11 03:13:34 mchang noship $ */
-- Start of Comments
-- Package name     : OZF_PARTNER_CLAIM_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: CLAIM_REC_TYPE
--   -------------------------------------------------------
--       CLAIM_ID
--       CLAIM_NUMBER
--       CLAIM_TYPE_ID
--       CLAIM_DATE
--       DUE_DATE
--       GL_DATE
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
--       RELATED_CUST_ACCOUNT_ID
--       REASON_CODE_ID
--       CUSTOMER_REASON
--       STATUS_CODE
--       USER_STATUS_ID
--       SALES_REP_ID
--       COLLECTOR_ID
--       CONTACT_ID
--       BROKER_ID
--       CUSTOMER_REF_DATE
--       CUSTOMER_REF_NUMBER
--       COMMENTS
--       ATTRIBUTE_CATEGORY
--       ATTRIBUTE1
--       ATTRIBUTE2
--       ATTRIBUTE3
--       ATTRIBUTE4
--       ATTRIBUTE5
--       ATTRIBUTE6
--       ATTRIBUTE7
--       ATTRIBUTE8
--       ATTRIBUTE9
--       ATTRIBUTE10
--       ATTRIBUTE11
--       ATTRIBUTE12
--       ATTRIBUTE13
--       ATTRIBUTE14
--       ATTRIBUTE15
--       ORG_ID
--    Required:
--    Defaults:
--    Note:
--
--   End of Comments

TYPE CLAIM_REC_TYPE IS RECORD
(
    CLAIM_ID                     NUMBER
   ,CLAIM_NUMBER                 VARCHAR2(30)
   ,CLAIM_TYPE_ID                NUMBER
   ,CLAIM_DATE                   DATE
   ,DUE_DATE                     DATE
   ,GL_DATE                      DATE
   ,OWNER_ID                     NUMBER
   ,AMOUNT                       NUMBER
   ,CURRENCY_CODE                VARCHAR2(15)
   ,EXCHANGE_RATE_TYPE           VARCHAR2(30)
   ,EXCHANGE_RATE_DATE           DATE
   ,EXCHANGE_RATE                NUMBER
   ,SET_OF_BOOKS_ID              NUMBER
   ,SOURCE_OBJECT_ID             NUMBER
   ,SOURCE_OBJECT_CLASS          VARCHAR2(15)
   ,SOURCE_OBJECT_TYPE_ID        NUMBER
   ,SOURCE_OBJECT_NUMBER         VARCHAR2(30)
   ,CUST_ACCOUNT_ID              NUMBER
   ,CUST_BILLTO_ACCT_SITE_ID     NUMBER
   ,CUST_SHIPTO_ACCT_SITE_ID     NUMBER
   ,PAY_TO_CUST_ACCOUNT_ID       NUMBER
   ,REASON_CODE_ID               NUMBER
   ,CUSTOMER_REASON              VARCHAR2(30)
   ,STATUS_CODE                  VARCHAR2(30)
   ,USER_STATUS_ID               NUMBER
   ,SALES_REP_ID                 NUMBER
   ,COLLECTOR_ID                 NUMBER
   ,CONTACT_ID                   NUMBER
   ,BROKER_ID                    NUMBER
   ,CUSTOMER_REF_DATE            DATE
   ,CUSTOMER_REF_NUMBER          VARCHAR2(30)
   ,COMMENTS                     VARCHAR2(2000)
   ,ATTRIBUTE_CATEGORY           VARCHAR2(30)
   ,ATTRIBUTE1                   VARCHAR2(150)
   ,ATTRIBUTE2                   VARCHAR2(150)
   ,ATTRIBUTE3                   VARCHAR2(150)
   ,ATTRIBUTE4                   VARCHAR2(150)
   ,ATTRIBUTE5                   VARCHAR2(150)
   ,ATTRIBUTE6                   VARCHAR2(150)
   ,ATTRIBUTE7                   VARCHAR2(150)
   ,ATTRIBUTE8                   VARCHAR2(150)
   ,ATTRIBUTE9                   VARCHAR2(150)
   ,ATTRIBUTE10                  VARCHAR2(150)
   ,ATTRIBUTE11                  VARCHAR2(150)
   ,ATTRIBUTE12                  VARCHAR2(150)
   ,ATTRIBUTE13                  VARCHAR2(150)
   ,ATTRIBUTE14                  VARCHAR2(150)
   ,ATTRIBUTE15                  VARCHAR2(150)
   ,ORG_ID                       NUMBER
);

TYPE CLAIM_TBL_TYPE IS TABLE OF CLAIM_REC_TYPE
  INDEX BY BINARY_INTEGER;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: PROMOTION_ACTIVITY_REC_TYPE
--   -------------------------------------------------------
--       OFFER_ID
--       ITEM_ID
--       AMOUNT
--
--    Required:
--    Defaults:
--    Note:
--
--   End of Comments


TYPE PROMOTION_ACTIVITY_REC_TYPE IS RECORD
(
    OFFER_ID                     NUMBER
   ,ITEM_ID                      NUMBER
   ,REFERENCE_TYPE               VARCHAR2(30)
   ,REFERENCE_ID                 NUMBER
   ,AMOUNT                       NUMBER
);

TYPE PROMOTION_ACTIVITY_TBL_TYPE IS TABLE OF PROMOTION_ACTIVITY_REC_TYPE
  INDEX BY BINARY_INTEGER;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Claim
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER                      Required
--       p_init_msg_list           IN   VARCHAR2                    Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2                    Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER                      Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claim_rec               IN   CLAIM_REC_TYPE              Required
--       p_promotion_activity_tbl  IN   PROMOTION_ACTIVITY_TBL_TYPE Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER
--       x_claim_number            OUT  VARCHAR2
--       x_claim_amount            OUT  NUMBER
--
--   Version : Current version 1.0
--
--   Note:
--
--   End of Comments
--  *******************************************************
PROCEDURE Create_Claim(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_claim_rec                  IN   CLAIM_REC_TYPE,
    p_promotion_activity_rec     IN   PROMOTION_ACTIVITY_REC_TYPE,
    x_claim_id                   OUT  NOCOPY NUMBER,
    x_claim_number               OUT  NOCOPY VARCHAR2,
    x_claim_amount               OUT  NOCOPY NUMBER
);


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Claim
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claim_id                IN   NUMBER     Required
--       p_status_code             IN   VARCHAR2   Required
--       p_note_type               IN   VARCHAR2   Optional
--       p_note_detail             IN   VARCHAR2   Optional
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   Note:
--
--   End of Comments
--  *******************************************************
PROCEDURE Update_Claim(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_claim_id                   IN   NUMBER,
    p_status_code                IN   VARCHAR2,
    p_comments                   IN   VARCHAR2     := NULL,
    p_note_type                  IN   VARCHAR2     := NULL,
    p_note_detail                IN   VARCHAR2     := NULL
);


END OZF_PARTNER_CLAIM_GRP;

 

/
