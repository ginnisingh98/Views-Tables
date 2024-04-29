--------------------------------------------------------
--  DDL for Package AS_OPP_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OPP_LINE_PVT" AUTHID CURRENT_USER as
/* $Header: asxvldls.pls 115.13 2003/11/13 10:11:15 gbatra ship $ */
-- Start of Comments
-- Package name     : AS_OPP_LINE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_opp_lines
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--     p_api_version_number IN   NUMBER     Required
--     p_init_msg_list      IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--     p_commit             IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level   IN   NUMBER     Optional  Default =
--                                                  FND_API.G_VALID_LEVEL_FULL
--     P_Line_Tbl           IN   AS_OPPORTUNITY_PUB.Line_Tbl_Type  Required
--
--   OUT:
--     X_LINE_OUT_TBL       OUT  AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
--     x_return_status      OUT  VARCHAR2
--     x_msg_count          OUT  NUMBER
--     x_msg_data           OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Create_opp_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    p_salesgroup_id      IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Line_Tbl                   IN   AS_OPPORTUNITY_PUB.Line_Tbl_Type  :=
                                             AS_OPPORTUNITY_PUB.G_MISS_Line_Tbl,
    p_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_LINE_OUT_TBL               OUT NOCOPY  AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_opp_lines
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default =
--                                                             FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default =
--                                                             FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default =
--                                                   FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_Line_Tbl                IN   AS_OPPORTUNITY_PUB.Line_Tbl_Type
--                                                 Required
--
--   OUT:
--       X_LINE_OUT_TBL            OUT  AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Update_opp_lines(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN  VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN  VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN  NUMBER,
    P_identity_salesforce_id     IN   NUMBER      := NULL,
    P_profile_tbl                IN  AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Line_Tbl                   IN  AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    p_Header_Rec                 IN  AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_LINE_OUT_TBL               OUT NOCOPY AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_opp_lines
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default =
--                                                              FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default =
--                                                              FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default =
--                                                   FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_Line_Tbl                IN   AS_OPPORTUNITY_PUB.Line_Tbl_Type
--                                                 Required
--
--   OUT:
--       X_LINE_OUT_TBL            OUT  AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Delete_opp_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_identity_salesforce_id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Line_Tbl                   IN   AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    p_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_LINE_OUT_TBL               OUT NOCOPY  AS_OPPORTUNITY_PUB.Line_out_Tbl_type,
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
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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
/*
PROCEDURE Validate_INTEREST_TYPE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INTEREST_TYPE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
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
/*
PROCEDURE Validate_P_INTEREST_CODE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRIMARY_INTEREST_CODE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
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
/*
PROCEDURE Validate_S_INTEREST_CODE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SECONDARY_INTEREST_CODE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
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

PROCEDURE Validate_INVENTORY_ITEM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INVENTORY_ITEM_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_ORGANIZATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORGANIZATION_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_UOM_CODE                IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUANTITY                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_TOTAL_AMOUNT (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TOTAL_AMOUNT                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_QUOTED_LINE_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUOTED_LINE_FLAG                IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_PRICE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRICE                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_PRICE_VOLUME_MARGIN (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRICE_VOLUME_MARGIN                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_SHIP_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIP_DATE                IN   DATE,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_O_OPPORTUNITY_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_O_OPPORTUNITY_LINE_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_SOURCE_PROMOTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_OFFER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OFFER_ID                IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
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

PROCEDURE Validate_Line_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Line_Rec     IN    AS_OPPORTUNITY_PUB.Line_Rec_Type,
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

PROCEDURE Validate_opp_line(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Line_Rec     IN    AS_OPPORTUNITY_PUB.Line_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
-- Product Category validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_PRODUCT_CATEGORY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CATEGORY_SET_ID        IN   NUMBER,
    P_CATEGORY_ID                IN   NUMBER,
    P_LEAD_LINE_ID               IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

  -- Procedure validates product category ids and returns SUCCESS if all ids are
  -- valid, ERROR otherwise
  -- Procedure assumes that at least the product category exists
  -- The validation level can have one of two values 'L' or 'H'
  -- The validation level determines whether the validation will be low or high
  -- If the validation level is High, the procedure determines that the product
  -- category exists and is valid
  -- If the validation level is Low, the procedure only determines that the product
  -- category exists
  --
  PROCEDURE Validate_Prod_Cat_Fields (  p_product_category_id         IN  NUMBER,
                                        p_product_cat_set_id          IN  NUMBER,
                                        p_validation_level            IN  VARCHAR2 := 'L',
                                        x_return_status               OUT NOCOPY VARCHAR2
                                     );

End AS_OPP_LINE_PVT;

 

/
