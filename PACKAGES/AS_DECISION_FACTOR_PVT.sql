--------------------------------------------------------
--  DDL for Package AS_DECISION_FACTOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_DECISION_FACTOR_PVT" AUTHID CURRENT_USER as
/* $Header: asxvdfcs.pls 115.8 2002/12/13 12:28:38 nkamble ship $ */
-- Start of Comments
-- Package name     : AS_DECISION_FACTOR_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_decision_factors
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number    IN   NUMBER     Required
--       p_init_msg_list         IN   VARCHAR2   Optional
--                                                 Default = FND_API_G_FALSE
--       p_commit                IN   VARCHAR2   Optional
--                                                 Default = FND_API.G_FALSE
--       p_validation_level      IN   NUMBER     Optional
--                                    Default = FND_API.G_VALID_LEVEL_FULL
--       P_decision_factor_Tbl        IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type
--                                    Required
--
--   OUT:
--       x_decision_factor_out_tbl    OUT  as_opportunity_pub.decision_factor_out_tbl_type
--       x_return_status         OUT  VARCHAR2
--       x_msg_count             OUT  NUMBER
--       x_msg_data              OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Create_decision_factors(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id          IN   NUMBER,
    P_Identity_Salesforce_Id  IN   NUMBER      := NULL,

    P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_decision_factor_Tbl          IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type :=
                                     AS_OPPORTUNITY_PUB.G_MISS_decision_factor_Tbl,
    X_decision_factor_out_tbl      OUT NOCOPY as_opportunity_pub.decision_factor_out_tbl_type,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_decision_factors
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional
--                                                 Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional
--                                                 Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_decision_factor_Tbl        IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type
--                                    Required
--
--   OUT:
--       x_decision_factor_out_tbl    OUT  as_opportunity_pub.decision_factor_out_tbl_type
--       x_return_status         OUT  VARCHAR2
--       x_msg_count             OUT  NUMBER
--       x_msg_data              OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Update_decision_factors(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id          IN   NUMBER,
    P_Identity_Salesforce_Id  IN   NUMBER,
    P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_decision_factor_Tbl          IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type,
    X_decision_factor_out_tbl      OUT NOCOPY  as_opportunity_pub.decision_factor_out_tbl_type,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_decision_factor
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional
--                                                 Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional
--                                                 Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_decision_factor_Tbl        IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type
--                                    Required
--
--   OUT:
--       x_decision_factor_out_tbl    OUT  as_opportunity_pub.decision_factor_out_tbl_type
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Delete_decision_factors(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id          IN   NUMBER,
    P_identity_salesforce_id  IN   NUMBER      := NULL,
    P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_decision_factor_Tbl          IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type,
    X_decision_factor_out_tbl      OUT NOCOPY  as_opportunity_pub.decision_factor_out_tbl_type,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
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


PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
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

PROCEDURE Validate_DECISION_RANK (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_RANK                IN   NUMBER,
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

PROCEDURE Validate_DECISION_PRIOR_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_PRIORITY_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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

PROCEDURE Validate_DECISION_FACTOR_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_FACTOR_CODE                IN   VARCHAR2,
    P_LEAD_LINE_ID               IN NUMBER,
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

PROCEDURE Validate_L_DECISION_FACTOR_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_DECISION_FACTOR_ID                IN   NUMBER,
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

PROCEDURE Validate_LEAD_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_LINE_ID                IN   NUMBER,
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

PROCEDURE Validate_CREATE_BY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CREATE_BY                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_Decision_Factor_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Decision_Factor_Rec     IN    as_opportunity_pub.Decision_Factor_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_decision_factor(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Decision_Factor_Rec     IN    as_opportunity_pub.Decision_Factor_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End AS_DECISION_FACTOR_PVT;

 

/
