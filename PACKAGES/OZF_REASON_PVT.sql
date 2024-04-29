--------------------------------------------------------
--  DDL for Package OZF_REASON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_REASON_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvreas.pls 120.1 2005/06/30 23:43:30 appldev ship $ */
-- Start of Comments
-- Package name     : OZF_Reason_PVT
-- Purpose          :
-- History          : 30-AUG-2001  MCHANG   Add one more column: REASON_TYPE  VARCHAR2(30)
--                    28-OCT-2002  UPOLURI   Add one more column: ORDER_TYPE_ID  NUMBER
-- History          : 28-SEP-2003  ANUJGUPT  Add one more column: PARTNER_ACCESS_FLAG  VARCHAR2(1)
-- History          : 22-Jun-2005  KDHULIPA  Add one more column: INVOICING_REASON_CODE  VARCHAR2(30)
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:reason_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    REASON_CODE_ID
--    OBJECT_VERSION_NUMBER
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    REASON_CODE
--    START_DATE_ACTIVE
--    END_DATE_ACTIVE
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
--    ORG_ID
--    REASON_TYPE
--    ADJUSTMENT_REASON_CODE
--    INVOICING_REASON_CODE
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE action_Rec_Type IS RECORD
(
       REASON_TYPE_ID                  NUMBER,
       OBJECT_VERSION_NUMBER           NUMBER,
       REASON_CODE_ID                  NUMBER,
       TASK_TEMPLATE_GROUP_ID          NUMBER,
       ACTIVE_FLAG                     VARCHAR2(1),
       DEFAULT_FLAG                  VARCHAR2(1)
);

G_MISS_action_REC                 action_Rec_Type;

TYPE  action_Tbl_Type      IS TABLE OF action_Rec_Type;
G_MISS_action_TBL          action_Tbl_Type;

TYPE reason_Rec_Type IS RECORD
(
       REASON_CODE_ID                  NUMBER ,
       OBJECT_VERSION_NUMBER           NUMBER ,
       LAST_UPDATE_DATE                DATE ,
       LAST_UPDATED_BY                 NUMBER ,
       CREATION_DATE                   DATE ,
       CREATED_BY                      NUMBER ,
       LAST_UPDATE_LOGIN               NUMBER ,
       REASON_CODE                     VARCHAR2(30) ,
       START_DATE_ACTIVE               DATE ,
       END_DATE_ACTIVE                 DATE ,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) ,
       ATTRIBUTE1                      VARCHAR2(150),
       ATTRIBUTE2                      VARCHAR2(150),
       ATTRIBUTE3                      VARCHAR2(150),
       ATTRIBUTE4                      VARCHAR2(150),
       ATTRIBUTE5                      VARCHAR2(150),
       ATTRIBUTE6                      VARCHAR2(150),
       ATTRIBUTE7                      VARCHAR2(150),
       ATTRIBUTE8                      VARCHAR2(150),
       ATTRIBUTE9                      VARCHAR2(150),
       ATTRIBUTE10                     VARCHAR2(150),
       ATTRIBUTE11                     VARCHAR2(150),
       ATTRIBUTE12                     VARCHAR2(150),
       ATTRIBUTE13                     VARCHAR2(150),
       ATTRIBUTE14                     VARCHAR2(150),
       ATTRIBUTE15                     VARCHAR2(150),
       NAME                            VARCHAR2(80) ,
       DESCRIPTION                     VARCHAR2(2000) ,
       ORG_ID                          NUMBER ,
       REASON_TYPE                     VARCHAR2(30),
       ADJUSTMENT_REASON_CODE          VARCHAR2(30),
       INVOICING_REASON_CODE           VARCHAR2 (30),
       ORDER_TYPE_ID                   NUMBER ,
       PARTNER_ACCESS_FLAG             VARCHAR2(1)
);

G_MISS_reason_REC          reason_Rec_Type;
TYPE  reason_Tbl_Type      IS TABLE OF reason_Rec_Type;
G_MISS_reason_TBL          reason_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_reason
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER     Required
--       p_init_msg_list           IN  VARCHAR2   Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2   Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER     Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       P_reason_Rec     IN reason_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT VARCHAR2
--       x_msg_count               OUT NUMBER
--       x_msg_data                OUT VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_reason_Rec     IN      reason_Rec_Type  := G_MISS_reason_REC,
    X_REASON_CODE_ID              OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_reason
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN  NUMBER    Required
--       p_init_msg_list           IN  VARCHAR2  Optional  Default=FND_API_G_FALSE
--       p_commit                  IN  VARCHAR2  Optional  Default=FND_API.G_FALSE
--       p_validation_level        IN  NUMBER    Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       P_reason_Rec     IN reason_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT VARCHAR2
--       x_msg_count               OUT NUMBER
--       x_msg_data                OUT VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_reason(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,

    P_reason_Rec     IN    reason_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_reason
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number    IN  NUMBER   Required
--       p_init_msg_list         IN  VARCHAR2 Optional  Default=FND_API_G_FALSE
--       p_commit                IN  VARCHAR2 Optional  Default=FND_API.G_FALSE
--       p_validation_level      IN  NUMBER   Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_REASON_CODE_ID        IN  NUMBER
--       p_object_version_number IN  NUMBER   Optional  Default=NULL
--
--   OUT:
--       x_return_status         OUT VARCHAR2
--       x_msg_count             OUT NUMBER
--       x_msg_data              OUT VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it
--         includes standard IN/OUT parameters and basic operation,
--         developer must manually add parameters and business
--         logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_REASON_CODE_ID  IN  NUMBER,
    P_Object_Version_Number      IN   NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_actions
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number    IN  NUMBER   Required
--       p_init_msg_list         IN  VARCHAR2 Optional  Default=FND_API_G_FALSE
--       p_commit                IN  VARCHAR2 Optional  Default=FND_API.G_FALSE
--       p_validation_level      IN  NUMBER   Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_action_Tbl            IN  action_Tbl_Type
--
--   OUT:
--       x_return_status         OUT VARCHAR2
--       x_msg_count             OUT NUMBER
--       x_msg_data              OUT VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it
--         includes standard IN/OUT parameters and basic operation,
--         developer must manually add parameters and business
--         logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_actions(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_action_Tbl                 IN  action_Tbl_Type
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_action
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number    IN  NUMBER   Required
--       p_init_msg_list         IN  VARCHAR2 Optional  Default=FND_API_G_FALSE
--       p_commit                IN  VARCHAR2 Optional  Default=FND_API.G_FALSE
--       p_validation_level      IN  NUMBER   Optional  Default=FND_API.G_VALID_LEVEL_FULL
--       p_reason_type_id        IN  NUMBER
--       p_object_version_number IN  NUMBER
--
--   OUT:
--       x_return_status         OUT VARCHAR2
--       x_msg_count             OUT NUMBER
--       x_msg_data              OUT VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it
--         includes standard IN/OUT parameters and basic operation,
--         developer must manually add parameters and business
--         logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_action(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_reason_type_id             IN  NUMBER,
    p_object_version_number       IN  NUMBER
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_unique_Action
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       P_action_Rec            IN  action_Rec_Type   Required
--       p_validation_mode       IN  VARCHAR2 Optional  Default=JTF_PLSQL_API.g_create
--
--   OUT:
--       x_return_status         OUT VARCHAR2
--
--   Version : Current version 1.0
--   Description : Checks the uniqueness of the action record for a reason.
--
--   End of Comments
PROCEDURE Check_unique_Action(
    P_action_Rec       IN    action_Rec_Type,
    p_validation_mode  IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status    OUT NOCOPY   VARCHAR2
);

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_reason_rec(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_reason_Rec     IN    reason_Rec_Type
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record.
--          There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_reason(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_reason_Rec     IN    reason_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_Rec
--
-- PURPOSE
--    For Update_Claim, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_claim_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Reason_Rec (
   p_reason_rec        IN   reason_Rec_Type
  ,x_complete_rec     OUT NOCOPY  reason_Rec_Type
  ,x_return_status    OUT NOCOPY  varchar2
);

End OZF_Reason_PVT;


 

/
