--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_WORK_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_WORK_ITEMS_PVT" AUTHID CURRENT_USER as
/* $Header: iexvswis.pls 120.0.12010000.2 2008/08/06 09:04:55 schekuri ship $ */

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:strategy_work_item_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    WORK_ITEM_ID
--    STRATEGY_ID
--    RESOURCE_ID
--    STATUS_CODE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    CREATION_DATE
--    CREATED_BY
--    PROGRAM_ID
--    OBJECT_VERSION_NUMBER
--    REQUEST_ID
--    LAST_UPDATE_DATE
--    WORK_ITEM_TEMPLATE_ID
--   PROGRAM_APPLICATION_ID
--   PROGRAM_UPDATE_DATE
--   EXECUTE_START
--   EXECUTE_END
--  schedule_start          in  DATE
--  schedule_end            in  DATE
--  strategy_temp_id        in NUMBER
--  work_item_order         in NUMBER

--    Required:
--    Defaults:
--   End of Comments

TYPE strategy_work_item_Rec_Type IS RECORD
(
       WORK_ITEM_ID                    NUMBER := FND_API.G_MISS_NUM
,       STRATEGY_ID                     NUMBER := FND_API.G_MISS_NUM
,       RESOURCE_ID                     NUMBER := FND_API.G_MISS_NUM
,       STATUS_CODE                     VARCHAR2(30) := FND_API.G_MISS_CHAR
,       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
,       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
,       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM
,       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM
,       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM
,       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE
,       WORK_ITEM_TEMPLATE_ID           NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM
,       PROGRAM_UPDATE_DATE            DATE := FND_API.G_MISS_DATE
,       EXECUTE_START                  DATE := FND_API.G_MISS_DATE
,       EXECUTE_END                    DATE := FND_API.G_MISS_DATE
,       SCHEDULE_START                 DATE := FND_API.G_MISS_DATE
,       SCHEDULE_END                   DATE := FND_API.G_MISS_DATE
,       STRATEGY_TEMP_ID               NUMBER := FND_API.G_MISS_NUM
,       WORK_ITEM_ORDER                NUMBER := FND_API.G_MISS_NUM
,	ESCALATED_YN		        CHAR := FND_API.G_MISS_CHAR
);

G_MISS_strategy_work_item_REC          strategy_work_item_Rec_Type;
TYPE  strategy_work_item_Tbl_Type      IS TABLE OF strategy_work_item_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_strategy_work_item_TBL          strategy_work_item_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_strategy_work_items
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_strategy_work_item_Rec     IN strategy_work_item_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
PROCEDURE Create_strategy_work_items(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_TRUE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_strategy_work_item_Rec     IN    strategy_work_item_Rec_Type  := G_MISS_strategy_work_item_REC,
    X_WORK_ITEM_ID               OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_strategy_work_items
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_strategy_work_item_Rec     IN strategy_work_item_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_strategy_work_items(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_TRUE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_strategy_work_item_Rec     IN    strategy_work_item_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    XO_OBJECT_VERSION_NUMBER     OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_strategy_work_items
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_strategy_work_item_Rec     IN strategy_work_item_Rec_Type  Required

--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--

PROCEDURE Delete_strategy_work_items(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_WORK_ITEM_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End IEX_strategy_work_items_PVT;

/
