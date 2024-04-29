--------------------------------------------------------
--  DDL for Package IEX_WRITEOFFS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WRITEOFFS_PVT" AUTHID CURRENT_USER as
/* $Header: iexvwros.pls 120.1 2007/10/31 14:45:25 ehuh ship $ */
-- Start of Comments
-- Package name     : IEX_writeoffs_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:writeoffs_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    WRITEOFF_ID
--    PARTY_ID
--    DELINQUENCY_ID
--    CAS_ID
--    CUST_ACCOUNT_ID
--    DISPOSITION_CODE
--    OBJECT_ID
--    OBJECT_CODE
--    WRITEOFF_TYPE
--    ACTIVE_FLAG
--    OBJECT_VERSION_NUMBER
--    WRITEOFF_REASON
--    WRITEOFF_AMOUNT
--    WRITEOFF_CURRENCY_CODE
--    WRITEOFF_DATE
--    WRITEOFF_REQUEST_DATE
--    WRITEOFF_PROCESS
--    WRITEOFF_SCORE
--    BAD_DEBT_REASON
--    LEASING_CODE
--    REPOSSES_SCH_DATE
--    REPOSSES_COMP_DATE
--    CREDIT_HOLD_YN
--    APPROVER_ID
--    EXTERNAL_AGENT_ID
--    PROCEDURE_CODE
--    CHECKLIST_CODE
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
--    SUGGESTION_APPROVED_FLAG
--
--
--   End of Comments

TYPE writeoffs_Rec_Type IS RECORD
(
       WRITEOFF_ID                     NUMBER := FND_API.G_MISS_NUM,
       PARTY_ID                        NUMBER := FND_API.G_MISS_NUM,
       DELINQUENCY_ID                  NUMBER := FND_API.G_MISS_NUM,
       CAS_ID                          NUMBER := FND_API.G_MISS_NUM,
       CUST_ACCOUNT_ID                 NUMBER := FND_API.G_MISS_NUM,
       DISPOSITION_CODE                VARCHAR2(240) := FND_API.G_MISS_CHAR,
       OBJECT_ID                       NUMBER := FND_API.G_MISS_NUM,
       OBJECT_CODE                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       WRITEOFF_TYPE                   VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ACTIVE_FLAG                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM,
       WRITEOFF_REASON                 VARCHAR2(240) := FND_API.G_MISS_CHAR,
       WRITEOFF_AMOUNT                 NUMBER := FND_API.G_MISS_NUM,
       WRITEOFF_CURRENCY_CODE          VARCHAR2(240) := FND_API.G_MISS_CHAR,
       WRITEOFF_DATE                   DATE := FND_API.G_MISS_DATE,
       WRITEOFF_REQUEST_DATE           DATE := FND_API.G_MISS_DATE,
       WRITEOFF_PROCESS                VARCHAR2(240) := FND_API.G_MISS_CHAR,
       WRITEOFF_SCORE                  VARCHAR2(240) := FND_API.G_MISS_CHAR,
       BAD_DEBT_REASON                 VARCHAR2(240) := FND_API.G_MISS_CHAR,
       LEASING_CODE                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
       REPOSSES_SCH_DATE               DATE := FND_API.G_MISS_DATE,
       REPOSSES_COMP_DATE              DATE := FND_API.G_MISS_DATE,
       CREDIT_HOLD_YN                  VARCHAR2(240) := FND_API.G_MISS_CHAR,
       APPROVER_ID                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       EXTERNAL_AGENT_ID               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PROCEDURE_CODE                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CHECKLIST_CODE                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       ATTRIBUTE_CATEGORY              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,      CREDIT_HOLD_REQUEST_FLAG        VARCHAR2(1) := FND_API.G_MISS_CHAR
,      CREDIT_HOLD_APPROVED_FLAG       VARCHAR2(1) := FND_API.G_MISS_CHAR
,      SERVICE_HOLD_REQUEST_FLAG       VARCHAR2(1) := FND_API.G_MISS_CHAR
,      SERVICE_HOLD_APPROVED_FLAG      VARCHAR2(1) := FND_API.G_MISS_CHAR
,      SUGGESTION_APPROVED_FLAG        VARCHAR2(1) := FND_API.G_MISS_CHAR
,       CUSTOMER_SITE_USE_ID            NUMBER := FND_API.G_MISS_NUM
,       ORG_ID                          NUMBER := FND_API.G_MISS_NUM
,       CONTRACT_ID                     NUMBER := FND_API.G_MISS_NUM
,       CONTRACT_NUMBER                 VARCHAR2(250) := FND_API.G_MISS_CHAR
);

G_MISS_writeoffs_REC          writeoffs_Rec_Type;
TYPE  writeoffs_Tbl_Type      IS TABLE OF writeoffs_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_writeoffs_TBL          writeoffs_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_writeoffs
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_writeoffs_Rec           IN writeoffs_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
PROCEDURE Create_writeoffs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_writeoffs_Rec              IN    writeoffs_Rec_Type  := G_MISS_writeoffs_REC,
    X_WRITEOFF_ID                OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_writeoffs
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_writeoffs_Rec           IN writeoffs_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Update_writeoffs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_writeoffs_Rec              IN    writeoffs_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    xo_object_version_number     OUT NOCOPY NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_writeoffs
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_writeoff_id             IN   NUMBER required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_writeoffs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_writeoff_id                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End IEX_WRITEOFFS_PVT;

/
