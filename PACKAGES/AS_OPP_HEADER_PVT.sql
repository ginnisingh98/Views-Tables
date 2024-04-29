--------------------------------------------------------
--  DDL for Package AS_OPP_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OPP_HEADER_PVT" AUTHID CURRENT_USER as
/* $Header: asxvldhs.pls 115.21 2003/09/03 08:56:55 nkamble ship $ */
-- Start of Comments
-- Package name     : AS_OPP_HEADER_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_opp_header
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN:
--      p_api_version_number IN NUMBER   Required
--      p_init_msg_list      IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit             IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level   IN NUMBER   Optional Default =
--                                                   FND_API.G_VALID_LEVEL_FULL
--      P_Header_Rec         IN AS_OPPORTUNITY_PUB.Header_Rec_Type  Required
--
--   OUT:
--      x_return_status      OUT  VARCHAR2
--      x_msg_count          OUT  NUMBER
--      x_msg_data           OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments

PROCEDURE Create_opp_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_salesgroup_id              IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type
                                      := AS_OPPORTUNITY_PUB.G_MISS_Header_REC,
    X_LEAD_ID                    OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_opp_header
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--      p_api_version_number     IN NUMBER   Required
--      p_init_msg_list          IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit                 IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level       IN NUMBER   Optional Default =
--                                                    FND_API.G_VALID_LEVEL_FULL
--      p_identity_salesforce_id IN NUMBER   Optional Default = NULL
--      P_Header_Rec             IN AS_OPPORTUNITY_PUB.Header_Rec_Type
--                                           Required
--
--   OUT:
--      x_return_status           OUT  VARCHAR2
--      x_msg_count               OUT  NUMBER
--      x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments

PROCEDURE Update_opp_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_opp_header
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--      p_api_version_number     IN NUMBER   Required
--      p_init_msg_list          IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit                 IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level       IN NUMBER   Optional Default =
--                                                    FND_API.G_VALID_LEVEL_FULL
--      p_identity_salesforce_id IN NUMBER   Optional Default = NULL
--      P_lead_id                IN NUMBER   Required
--
--   OUT:
--      x_return_status           OUT  VARCHAR2
--      x_msg_count               OUT  NUMBER
--      x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments

PROCEDURE Delete_opp_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_lead_id                    IN   NUMBER,
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

PROCEDURE Validate_LEAD_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_LEAD_ID                IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );


/*
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

PROCEDURE Validate_LEAD_NUMBER (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_LEAD_NUMBER            IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );
*/

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

PROCEDURE Validate_STATUS (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_STATUS                 IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_SALES_STAGE_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_SALES_STAGE_ID         IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_CHANNEL_CODE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_CHANNEL_CODE           IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_CURRENCY_CODE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_CURRENCY_CODE          IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_WIN_PROBABILITY (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_WIN_PROBABILITY        IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_CLOSE_REASON (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_CLOSE_REASON           IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_SOURCE_PROMOTION_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID    IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_NO_OPP_ALLOWED_FLAG (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_NO_OPP_ALLOWED_FLAG    IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_DELETE_ALLOWED_FLAG (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_DELETE_ALLOWED_FLAG    IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_LEAD_SOURCE_CODE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_LEAD_SOURCE_CODE       IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_PRICE_LIST_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_PRICE_LIST_ID          IN   NUMBER,
    P_CURRENCY_CODE          IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_DELETED_FLAG (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_DELETED_FLAG           IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_METHODOLOGY_CODE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_METHODOLOGY_CODE       IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_ORIGINAL_LEAD_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_ORIGINAL_LEAD_ID       IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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
    P_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode         IN   VARCHAR2,
    P_DECISION_TIMEFRAME_CODE IN   VARCHAR2,
    X_Item_Property_Rec       OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_OFFER_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID    IN   NUMBER,
    P_OFFER_ID               IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_VEHICLE_RESPONSE_CODE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_VEHICLE_RESPONSE_CODE  IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_BUDGET_STATUS_CODE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_BUDGET_STATUS_CODE     IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_PRM_LEAD_TYPE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_PRM_LEAD_TYPE          IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_CUSTOMER_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_CUSTOMER_ID            IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_INC_PARTNER_PARTY_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_INC_PARTNER_PARTY_ID   IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_CLOSE_COMPETITOR_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_CLOSE_COMPETITOR_ID    IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_END_USER_CUSTOMER_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_END_USER_CUSTOMER_ID   IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_OPP_OWNER (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_OWNER_SALESFORCE_ID    IN   NUMBER,
    P_OWNER_SALES_GROUP_ID   IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_ADDRESS_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_ADDRESS_ID             IN   NUMBER,
    P_CUSTOMER_ID            IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_END_USER_ADDRESS_ID (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_END_USER_ADDRESS_ID    IN   NUMBER,
    P_END_USER_CUSTOMER_ID   IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_AUTO_ASGN_TYPE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_AUTO_ASSIGNMENT_TYPE   IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_PRM_ASGN_TYPE (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_PRM_ASSIGNMENT_TYPE    IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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


PROCEDURE Validate_INC_PRTNR_RESOURCE_ID (
    P_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode         IN   VARCHAR2,
    P_INC_PARTNER_RESOURCE_ID IN   NUMBER,
    X_Item_Property_Rec       OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_PRM_IND_CLS_CODE (
    P_Init_Msg_List               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode             IN   VARCHAR2,
    P_PRM_IND_CLASSIFICATION_CODE IN   VARCHAR2,
    X_Item_Property_Rec           OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status               OUT NOCOPY  VARCHAR2,
    X_Msg_Count                   OUT NOCOPY  NUMBER,
    X_Msg_Data                    OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_PRM_EXEC_SPONSOR_FLAG (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_PRM_EXEC_SPONSOR_FLAG  IN   VARCHAR2,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_PRM_PRJ_LDINPLE_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRM_PRJ_LEAD_IN_PLACE_FLAG IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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
--
-- 091200 ffang, for bug , description is a mandatory column
-- End of Comments
PROCEDURE Validate_Description (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_Description        IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2 );



-- Start of Comments
--
-- Record level validation procedure
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--
-- End of Comments

PROCEDURE Validate_WinPorb_StageID (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_SALES_METHODOLOGY_ID IN NUMBER,
    P_SALES_STAGE_ID     IN   NUMBER,
    P_WIN_PROBABILITY    IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedure
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--
-- End of Comments

PROCEDURE Validate_Status_CloseReason (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_STATUS             IN   VARCHAR2,
    P_CLOSE_REASON       IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    );

/*
-- Start of Comments
--
-- Record level validation procedure
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--
-- End of Comments

PROCEDURE Validate_Status_DecisionDate (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_STATUS             IN   VARCHAR2,
    P_DECISION_DATE      IN   DATE,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    );
*/


-- Start of Comments
--
-- Record level validation procedure
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--
-- End of Comments

PROCEDURE Validate_DecisionDate (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_DECISION_DATE      IN   DATE,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    );



-- Start of Comments
--
-- Record level validation procedure
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--
-- End of Comments

PROCEDURE Validate_BudgetAmt_Currency (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_TOTAL_AMOUNT       IN   NUMBER,
    P_CURRENCY_CODE      IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_opp_header(
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level       IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode        IN   VARCHAR2,
    P_Header_Rec             IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    );



End AS_OPP_HEADER_PVT;

 

/
