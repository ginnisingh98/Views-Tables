--------------------------------------------------------
--  DDL for Package AST_RS_CAMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_RS_CAMP_PVT" AUTHID CURRENT_USER as
/* $Header: astvrcas.pls 120.1 2005/06/01 04:29:25 appldev  $ */
-- Start of Comments
-- Package name     : AST_rs_camp_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:rs_camp_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    RS_CAMPAIGN_ID
--    RESOURCE_ID
--    CAMPAIGN_ID
--    START_DATE
--    END_DATE
--    STATUS
--    ENABLED_FLAG
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE rs_camp_Rec_Type IS RECORD
(
       RS_CAMPAIGN_ID                  NUMBER := FND_API.G_MISS_NUM,
       RESOURCE_ID                     NUMBER := FND_API.G_MISS_NUM,
       CAMPAIGN_ID                     NUMBER := FND_API.G_MISS_NUM,
       START_DATE                      DATE := FND_API.G_MISS_DATE,
       END_DATE                        DATE := FND_API.G_MISS_DATE,
       STATUS                          VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ENABLED_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               VARCHAR2(240) := FND_API.G_MISS_CHAR
);

G_MISS_rs_camp_REC          rs_camp_Rec_Type;
TYPE  rs_camp_Tbl_Type      IS TABLE OF rs_camp_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_rs_camp_TBL          rs_camp_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_rs_camp
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_rs_camp_Rec     IN rs_camp_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT   VARCHAR2
--       x_msg_count               OUT   NUMBER
--       x_msg_data                OUT   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.

--
--   End of Comments
--
FUNCTION get_CAMPAIGN_REC RETURN AST_RS_CAMP_PVT.rs_camp_rec_type;

PROCEDURE Create_rs_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_rs_camp_Rec     IN    rs_camp_Rec_Type  := G_MISS_rs_camp_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_RS_CAMPAIGN_ID     OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_rs_camp
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_rs_camp_Rec     IN rs_camp_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT   VARCHAR2
--       x_msg_count               OUT   NUMBER
--       x_msg_data                OUT   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.

--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_rs_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_rs_camp_Rec     IN    rs_camp_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_rs_camp
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_rs_camp_Rec     IN rs_camp_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT   VARCHAR2
--       x_msg_count               OUT   NUMBER
--       x_msg_data                OUT   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.

--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_rs_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_rs_camp_Rec     IN rs_camp_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_rs_camp
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_rs_camp_Rec     IN rs_camp_Rec_Type  Required
--   Hint: Add List of bind variables here
--       p_rec_requested           IN   NUMBER     Optional  Default = 30
--       p_start_rec_ptr           IN   NUMBER     Optional  Default = 1
--
--       Return Total Records Count Flag. This flag controls whether the total record count
--       and total record amount is returned.
--
--       p_return_tot_count        IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   Hint: User defined record type
--       p_order_by_tbl            IN   JTF_PLSQL_API.UTIL_ORDER_BY_TBL_TYPE;
--
--   OUT:
--       x_return_status           OUT   VARCHAR2
--       x_msg_count               OUT   NUMBER
--       x_msg_data                OUT   VARCHAR2
--       X_rs_camp_Tbl     OUT  rs_camp_Rec_Type
--       x_returned_rec_count      OUT    NUMBER
--       x_next_rec_ptr            OUT    NUMBER
--       x_tot_rec_count           OUT    NUMBER
--  other optional OUT  parameters
--       x_tot_rec_amount          OUT    NUMBER
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.

--
--   End of Comments
--
PROCEDURE Get_rs_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_rs_camp_Rec     IN    AST_rs_camp_PUB.rs_camp_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   AST_rs_camp_PUB.rs_camp_sort_rec_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_rs_camp_Tbl  OUT NOCOPY /* file.sql.39 change */  AST_rs_camp_PUB.rs_camp_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_next_rec_ptr               OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_tot_rec_count              OUT NOCOPY /* file.sql.39 change */  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY /* file.sql.39 change */  NUMBER
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_RS_CAMPAIGN_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RS_CAMPAIGN_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_RESOURCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESOURCE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_CAMPAIGN_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CAMPAIGN_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_START_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_START_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_END_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_END_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_STATUS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_STATUS                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_ENABLED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ENABLED_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_rs_camp_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_rs_camp_Rec     IN    rs_camp_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in  package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.

-- End of Comments

PROCEDURE Validate_rs_camp(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_rs_camp_Rec     IN    rs_camp_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );
End AST_rs_camp_PVT;

 

/
