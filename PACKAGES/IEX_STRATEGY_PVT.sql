--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_PVT" AUTHID CURRENT_USER as
/* $Header: iexvstrs.pls 120.0.12010000.2 2008/08/11 10:58:35 pnaveenk ship $ */

-- Default number of records fetch per call

G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:STRATEGY_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    STRATEGY_ID
--    STATUS_CODE
--    STRATEGY_TEMPLATE_ID
--    DELINQUENCY_ID
--    OBJECT_TYPE
--    OBJECT_ID
--    CUST_ACCOUNT_ID
--    PARTY_ID
--    SCORE_VALUE
--    NEXT_WORK_ITEM_ID
--    USER_WORK_ITEM_YN
--   LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    CREATION_DATE
--    CREATED_BY
--    OBJECT_VERSION_NUMBER
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    CHECKLIST_STRATEGY_ID
--    CHECKLIST_YN
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE STRATEGY_Rec_Type IS RECORD
(
       STRATEGY_ID                     NUMBER
,       STATUS_CODE                     VARCHAR2(30)
,       STRATEGY_TEMPLATE_ID            NUMBER
,       DELINQUENCY_ID                  NUMBER
,       OBJECT_TYPE                     VARCHAR2(30)
,       OBJECT_ID                       NUMBER
,       CUST_ACCOUNT_ID                 NUMBER
,       PARTY_ID                        NUMBER
,       SCORE_VALUE                     NUMBER
,       NEXT_WORK_ITEM_ID               NUMBER
,       USER_WORK_ITEM_YN               VARCHAR2(2)
,       LAST_UPDATE_DATE                DATE
,       LAST_UPDATED_BY                 NUMBER
,       LAST_UPDATE_LOGIN               NUMBER
,       CREATION_DATE                   DATE
,       CREATED_BY                      NUMBER
,       OBJECT_VERSION_NUMBER           NUMBER
,       REQUEST_ID                      NUMBER
,       PROGRAM_APPLICATION_ID          NUMBER
,       PROGRAM_ID                      NUMBER
,       PROGRAM_UPDATE_DATE             DATE
,       CHECKLIST_STRATEGY_ID           NUMBER
,       CHECKLIST_YN                    VARCHAR2(10)
,       STRATEGY_LEVEL                  NUMBER
,       JTF_OBJECT_TYPE                 VARCHAR2(30)
,       JTF_OBJECT_ID                   NUMBER
,       CUSTOMER_SITE_USE_ID            NUMBER
 ,       ORG_ID                          NUMBER        --Bug# 6870773 Naveen
);

-- G_MISS_STRATEGY_REC          STRATEGY_Rec_Type;
TYPE  STRATEGY_Tbl_Type      IS TABLE OF STRATEGY_Rec_Type
                                    INDEX BY BINARY_INTEGER;
-- G_MISS_STRATEGY_TBL          STRATEGY_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_strategy
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_STRATEGY_Rec     IN STRATEGY_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
PROCEDURE Create_strategy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_STRATEGY_Rec               IN    STRATEGY_Rec_Type,
    X_STRATEGY_ID                OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_strategy
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_STRATEGY_Rec     IN STRATEGY_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--    XO_OBJECT_VERSION_NUMBER     OUT NOCOPY  NUMBER
--   Version : Current version 2.0
--   End of Comments
--
PROCEDURE Update_strategy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_STRATEGY_Rec               IN    STRATEGY_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    XO_OBJECT_VERSION_NUMBER     OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_strategy
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_STRATEGY_Rec            IN STRATEGY_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--

PROCEDURE Delete_strategy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_STRATEGY_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End IEX_STRATEGY_PVT;

/
