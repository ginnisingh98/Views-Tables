--------------------------------------------------------
--  DDL for Package AS_COMPETITOR_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_COMPETITOR_PROD_PVT" AUTHID CURRENT_USER as
/* $Header: asxvcpds.pls 115.6 2002/12/13 12:24:09 nkamble ship $ */
-- Start of Comments
-- Package name     : AS_COMPETITOR_PROD_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_competitor_prods
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
--       P_competitor_prod_Tbl        IN   As_Opportunity_Pub.Competitor_Prod_Tbl_Type
--                                    Required
--
--   OUT:
--       x_competitor_prod_out_tbl    OUT  as_opportunity_pub.competitor_prod_out_tbl_type
--       x_return_status         OUT  VARCHAR2
--       x_msg_count             OUT  NUMBER
--       x_msg_data              OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Create_competitor_prods(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN   NUMBER,
    P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_competitor_prod_Tbl          IN   As_Opportunity_Pub.Competitor_Prod_Tbl_Type :=
                                     AS_OPPORTUNITY_PUB.G_MISS_competitor_prod_Tbl,
    X_competitor_prod_out_tbl      OUT NOCOPY  as_opportunity_pub.competitor_prod_out_tbl_type,
    P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Identity_Salesforce_Id  IN   NUMBER      := NULL,
    P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_competitor_prods
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
--       P_competitor_prod_Tbl        IN   As_Opportunity_Pub.Competitor_Prod_Tbl_Type
--                                    Required
--
--   OUT:
--       x_competitor_prod_out_tbl    OUT  as_opportunity_pub.competitor_prod_out_tbl_type
--       x_return_status         OUT  VARCHAR2
--       x_msg_count             OUT  NUMBER
--       x_msg_data              OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Update_competitor_prods(
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
    P_competitor_prod_Tbl          IN   As_Opportunity_Pub.Competitor_Prod_Tbl_Type,
    X_competitor_prod_out_tbl      OUT NOCOPY  as_opportunity_pub.competitor_prod_out_tbl_type,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_competitor_prod
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
--       P_competitor_prod_Tbl        IN   As_Opportunity_Pub.Competitor_Prod_Tbl_Type
--                                    Required
--
--   OUT:
--       x_competitor_prod_out_tbl    OUT  as_opportunity_pub.competitor_prod_out_tbl_type
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
PROCEDURE Delete_competitor_prods(
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
    P_competitor_prod_Tbl          IN   As_Opportunity_Pub.Competitor_Prod_Tbl_Type,
    X_competitor_prod_out_tbl      OUT NOCOPY  as_opportunity_pub.competitor_prod_out_tbl_type,
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

PROCEDURE Validate_WIN_LOSS_STATUS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_WIN_LOSS_STATUS                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE Validate_COMPETITOR_PRODUCT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COMPETITOR_PRODUCT_ID                IN   NUMBER,
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

PROCEDURE Validate_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_ID                IN   NUMBER,
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

PROCEDURE Validate_L_COMPETITOR_PROD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_COMPETITOR_PROD_ID                IN   NUMBER,
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

PROCEDURE Validate_Competitor_Prod_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Competitor_Prod_Rec     IN    As_Opportunity_Pub.Competitor_Prod_Rec_Type,
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

PROCEDURE Validate_competitor_prod(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Competitor_Prod_Rec     IN    As_Opportunity_Pub.Competitor_Prod_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End AS_COMPETITOR_PROD_PVT;

 

/
