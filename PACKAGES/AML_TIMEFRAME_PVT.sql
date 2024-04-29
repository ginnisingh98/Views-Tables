--------------------------------------------------------
--  DDL for Package AML_TIMEFRAME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_TIMEFRAME_PVT" AUTHID CURRENT_USER as
/* $Header: amlvtfrs.pls 115.5 2002/12/05 00:27:00 ckapoor noship $ */
-- Start of Comments
-- Package name     : AML_TIMEFRAME_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_timeframe
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_check_access_flag       IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_flag              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_group_id          IN   NUMBER     Required
--       P_timeframe_Rec     IN timeframe_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN    AML_TIMEFRAME_PUB.timeframe_Rec_Type  ,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_TIMEFRAME_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_timeframe
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_check_access_flag       IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_flag              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_group_id          IN   NUMBER     Required
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_timeframe_Rec     IN timeframe_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN     AML_TIMEFRAME_PUB.timeframe_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_timeframe
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_check_access_flag       IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_flag              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_admin_group_id          IN   NUMBER     Required
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_timeframe_Rec     IN timeframe_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_Profile_Tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN  AML_TIMEFRAME_PUB.timeframe_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_TIMEFRAME_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TIMEFRAME_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_DECN_TIMEFRAME_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_TIMEFRAME_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_TIMEFRAME_DAYS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TIMEFRAME_DAYS                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End AML_TIMEFRAME_PVT;

 

/
