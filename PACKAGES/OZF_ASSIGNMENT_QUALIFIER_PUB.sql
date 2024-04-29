--------------------------------------------------------
--  DDL for Package OZF_ASSIGNMENT_QUALIFIER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ASSIGNMENT_QUALIFIER_PUB" AUTHID CURRENT_USER as
/* $Header: ozfpasqs.pls 115.1 2003/06/30 19:14:32 mchang noship $ */
-- Start of Comments
-- Package name     : OZF_ASSIGNMENT_QUALIFIER_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

TYPE Deduction_Rec_Type is record(
CLAIM_ID                     NUMBER ,
CLAIM_NUMBER                 VARCHAR2(30) ,
CLAIM_TYPE_ID                NUMBER ,
CLAIM_DATE                   DATE ,
DUE_DATE                     DATE ,
OWNER_ID                     NUMBER ,
AMOUNT                       NUMBER ,
CURRENCY_CODE                VARCHAR2(15) ,
EXCHANGE_RATE_TYPE           VARCHAR2(30) ,
EXCHANGE_RATE_DATE           DATE ,
EXCHANGE_RATE                NUMBER ,
SET_OF_BOOKS_ID              NUMBER ,
SOURCE_OBJECT_ID             NUMBER ,
SOURCE_OBJECT_CLASS          VARCHAR2(15) ,
SOURCE_OBJECT_TYPE_ID        NUMBER ,
SOURCE_OBJECT_NUMBER         VARCHAR2(30) ,
CUST_ACCOUNT_ID              NUMBER ,
CUST_BILLTO_ACCT_SITE_ID     NUMBER ,
CUST_SHIPTO_ACCT_SITE_ID     NUMBER ,
LOCATION_ID                  NUMBER ,
REASON_CODE_ID               NUMBER ,
STATUS_CODE                  VARCHAR2(30) ,
USER_STATUS_ID               NUMBER ,
SALES_REP_ID                 NUMBER ,
COLLECTOR_ID                 NUMBER ,
CONTACT_ID                   NUMBER ,
BROKER_ID                    NUMBER ,
CUSTOMER_REF_DATE            DATE ,
CUSTOMER_REF_NUMBER          VARCHAR2(30),
RECEIPT_ID                   NUMBER,
RECEIPT_NUMBER               VARCHAR2(30),
GL_DATE                      DATE,
COMMENTS                     VARCHAR2(2000),
DEDUCTION_ATTRIBUTE_CATEGORY VARCHAR2(30),
DEDUCTION_ATTRIBUTE1         VARCHAR2(150),
DEDUCTION_ATTRIBUTE2         VARCHAR2(150),
DEDUCTION_ATTRIBUTE3         VARCHAR2(150),
DEDUCTION_ATTRIBUTE4         VARCHAR2(150),
DEDUCTION_ATTRIBUTE5         VARCHAR2(150),
DEDUCTION_ATTRIBUTE6         VARCHAR2(150),
DEDUCTION_ATTRIBUTE7         VARCHAR2(150),
DEDUCTION_ATTRIBUTE8         VARCHAR2(150),
DEDUCTION_ATTRIBUTE9         VARCHAR2(150),
DEDUCTION_ATTRIBUTE10        VARCHAR2(150),
DEDUCTION_ATTRIBUTE11        VARCHAR2(150),
DEDUCTION_ATTRIBUTE12        VARCHAR2(150),
DEDUCTION_ATTRIBUTE13        VARCHAR2(150),
DEDUCTION_ATTRIBUTE14        VARCHAR2(150),
DEDUCTION_ATTRIBUTE15        VARCHAR2(150),
ORG_ID                       NUMBER
);

TYPE Qualifier_Rec_Type is record(
CLAIM_TYPE_ID                NUMBER,
CLAIM_DATE                   DATE,
DUE_DATE                     DATE,
OWNER_ID                     NUMBER,
CUST_BILLTO_ACCT_SITE_ID     NUMBER,
CUST_SHIPTO_ACCT_SITE_ID     NUMBER ,
REASON_CODE_ID               NUMBER ,
SALES_REP_ID                 NUMBER ,
CONTACT_ID                   NUMBER ,
BROKER_ID                    NUMBER ,
CUSTOMER_REF_DATE            DATE ,
CUSTOMER_REF_NUMBER          VARCHAR2(30) ,
GL_DATE                      DATE ,
COMMENTS                     VARCHAR2(2000)
);

---------------------------------------------------------------------
--   PROCEDURE:  Get_Deduction_Value
--
--   PURPOSE:
--   This procedure modifies the values of a deduction record.
--
--   PARAMETERS:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_deduction               IN   DEDUCTION_REC_TYPE  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_deduction               OUT  Qualifier_Rec_Type
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Get_Deduction_Value(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_deduction                  IN   DEDUCTION_REC_TYPE,
    X_qualifier                  OUT NOCOPY  Qualifier_Rec_Type
    );

End OZF_ASSIGNMENT_QUALIFIER_PUB;

 

/
