--------------------------------------------------------
--  DDL for Package IEX_BANKRUPTCIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_BANKRUPTCIES_PVT" AUTHID CURRENT_USER as
/* $Header: iexvbkrs.pls 120.0 2004/01/24 03:24:45 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_BANKRUPTCIES_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:BANKRUPTCY_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    BANKRUPTCY_ID
--    CAS_ID
--    DELINQUENCY_ID
--    PARTY_ID
--    ACTIVE_FLAG
--    TRUSTEE_CONTACT_ID
--    COURT_ID
--    FIRM_CONTACT_ID
--    COUNSEL_CONTACT_ID
--    OBJECT_VERSION_NUMBER
--    CHAPTER_CODE
--    ASSET_AMOUNT
--    ASSET_CURRENCY_CODE
--    PAYOFF_AMOUNT
--    PAYOFF_CURRENCY_CODE
--    BANKRUPTCY_FILE_DATE
--    COURT_ORDER_DATE
--    FUNDING_DATE
--    OBJECT_BAR_DATE
--    REPOSSESSION_DATE
--    DISMISSAL_DATE
--    DATE_341A
--    DISCHARGE_DATE
--    WITHDRAW_DATE
--    CLOSE_DATE
--    PROCEDURE_CODE
--    MOTION_CODE
--    CHECKLIST_CODE
--    CEASE_COLLECTIONS_YN
--    TURN_OFF_INVOICING_YN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    CREDIT_HOLD_REQUEST_FLAG
--    CREDIT_HOLD_APPROVED_FLAG
--    SERVICE_HOLD_REQUEST_FLAG
--    SERVICE_HOLD_APPROVED_FLAG
--
--    Required:

--
--   End of Comments

TYPE bankruptcy_Rec_Type IS RECORD
(
       BANKRUPTCY_ID                   NUMBER := FND_API.G_MISS_NUM,
       CAS_ID                          NUMBER := FND_API.G_MISS_NUM,
       DELINQUENCY_ID                  NUMBER := FND_API.G_MISS_NUM,
       PARTY_ID                        NUMBER := FND_API.G_MISS_NUM,
       ACTIVE_FLAG                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       TRUSTEE_CONTACT_ID              NUMBER := FND_API.G_MISS_NUM,
       COURT_ID                        NUMBER := FND_API.G_MISS_NUM,
       FIRM_CONTACT_ID                 NUMBER := FND_API.G_MISS_NUM,
       COUNSEL_CONTACT_ID              NUMBER := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM,
       CHAPTER_CODE                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ASSET_AMOUNT                    NUMBER := FND_API.G_MISS_NUM,
       ASSET_CURRENCY_CODE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PAYOFF_AMOUNT                   NUMBER := FND_API.G_MISS_NUM,
       PAYOFF_CURRENCY_CODE            VARCHAR2(240) := FND_API.G_MISS_CHAR,
       BANKRUPTCY_FILE_DATE            DATE := FND_API.G_MISS_DATE,
       COURT_ORDER_DATE                DATE := FND_API.G_MISS_DATE,
       FUNDING_DATE                    DATE := FND_API.G_MISS_DATE,
       OBJECT_BAR_DATE                 DATE := FND_API.G_MISS_DATE,
       REPOSSESSION_DATE               DATE := FND_API.G_MISS_DATE,
       DISMISSAL_DATE                  DATE := FND_API.G_MISS_DATE,
       DATE_341A                       DATE := FND_API.G_MISS_DATE,
       DISCHARGE_DATE                  DATE := FND_API.G_MISS_DATE,
       WITHDRAW_DATE                   DATE := FND_API.G_MISS_DATE,
       CLOSE_DATE                      DATE := FND_API.G_MISS_DATE,
       PROCEDURE_CODE                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       MOTION_CODE                         VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CHECKLIST_CODE                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CEASE_COLLECTIONS_YN            VARCHAR2(1) := FND_API.G_MISS_CHAR,
       TURN_OFF_INVOICING_YN           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       ATTRIBUTE_CATEGORY              VARCHAR2(90) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(450) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(450) := FND_API.G_MISS_CHAR,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,      CREDIT_HOLD_REQUEST_FLAG        VARCHAR2(1) := FND_API.G_MISS_CHAR
,      CREDIT_HOLD_APPROVED_FLAG       VARCHAR2(1) := FND_API.G_MISS_CHAR
,      SERVICE_HOLD_REQUEST_FLAG       VARCHAR2(1) := FND_API.G_MISS_CHAR
,      SERVICE_HOLD_APPROVED_FLAG      VARCHAR2(1) := FND_API.G_MISS_CHAR
,      DISPOSITION_CODE                VARCHAR2(30):= FND_API.G_MISS_CHAR,
       TURN_OFF_INVOICE_YN             VARCHAR2(1) := FND_API.G_MISS_CHAR,
       NOTICE_ASSIGNMENT_YN            VARCHAR2(1) := FND_API.G_MISS_CHAR,
       FILE_PROOF_CLAIM_YN             VARCHAR2(1) := FND_API.G_MISS_CHAR,
       REQUEST_REPURCHASE_YN           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       FEE_PAID_DATE                   DATE := FND_API.G_MISS_DATE,
       REAFFIRMATION_DATE              DATE := FND_API.G_MISS_DATE,
       RELIEF_STAY_DATE                DATE := FND_API.G_MISS_DATE,
       FILE_CONTACT_ID                 NUMBER := FND_API.G_MISS_NUM,
       CASE_NUMBER                     VARCHAR2(100) := FND_API.G_MISS_CHAR
);

G_MISS_bankruptcy_REC          bankruptcy_Rec_Type;
TYPE  bankruptcy_Tbl_Type      IS TABLE OF bankruptcy_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_bankruptcy_TBL          bankruptcy_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_bankruptcy
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_bankruptcy_Rec     IN bankruptcy_Rec_Type  Required
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
PROCEDURE Create_bankruptcy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_bankruptcy_Rec             IN    bankruptcy_Rec_Type  := G_MISS_bankruptcy_REC,
    X_BANKRUPTCY_ID              OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_bankruptcy
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_bankruptcy_Rec     IN bankruptcy_Rec_Type  Required
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       xo_object_version_number  OUT NOCOPY NUMBER
--   Version : Current version 2.0
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_bankruptcy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_bankruptcy_Rec             IN    bankruptcy_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    xo_object_version_number     OUT NOCOPY NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_bankruptcy
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_bankruptcy_Rec     IN bankruptcy_Rec_Type  Required
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_bankruptcy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_bankruptcy_Id              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End IEX_BANKRUPTCIES_PVT;

 

/
