--------------------------------------------------------
--  DDL for Package CSP_TASK_PART_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_TASK_PART_PVT" AUTHID CURRENT_USER as
/* $Header: cspvtaps.pls 115.3 2003/05/02 16:36:44 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_TASK_PART_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:TASK_PART_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    TASK_PART_ID
--    PRODUCT_TASK_ID
--    INVENTORY_ITEM_ID
--    MANUAL_QUANTITY
--    MANUAL_PERCENTAGE
--    QUANTITY_USED
--    ACTUAL_TIMES_USED
--    CALCULATED_QUANTITY
--    PART_PERCENTAGE
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
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
--    PRIMARY_UOM_CODE
--    REVISION
--    START_DATE
--    END_DATE
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments
TYPE TASK_PART_Rec_Type IS RECORD
(
       TASK_PART_ID                    NUMBER := FND_API.G_MISS_NUM,
       PRODUCT_TASK_ID                 NUMBER := FND_API.G_MISS_NUM,
       INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
       MANUAL_QUANTITY                 NUMBER := FND_API.G_MISS_NUM,
       MANUAL_PERCENTAGE               NUMBER := FND_API.G_MISS_NUM,
       QUANTITY_USED                   NUMBER := FND_API.G_MISS_NUM,
       ACTUAL_TIMES_USED               NUMBER := FND_API.G_MISS_NUM,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       PRIMARY_UOM_CODE                VARCHAR2(3) := FND_API.G_MISS_CHAR,
       REVISION                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       START_DATE                      DATE := FND_API.G_MISS_DATE,
       END_DATE                        DATE := FND_API.G_MISS_DATE,
       ROLLUP_QUANTITY_USED            NUMBER := FND_API.G_MISS_NUM,
       ROLLUP_TIMES_USED               NUMBER := FND_API.G_MISS_NUM,
       SUBSTITUTE_ITEM                 NUMBER := FND_API.G_MISS_NUM
);
G_MISS_TASK_PART_REC          TASK_PART_Rec_Type;
TYPE  TASK_PART_Tbl_Type      IS TABLE OF TASK_PART_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_TASK_PART_TBL          TASK_PART_Tbl_Type;
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_task_part
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
--       P_TASK_PART_Rec     IN TASK_PART_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
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
PROCEDURE Create_task_part(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_TASK_PART_Rec     IN    TASK_PART_Rec_Type  := G_MISS_TASK_PART_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_TASK_PART_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_task_part
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
--       P_TASK_PART_Rec     IN TASK_PART_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
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
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_task_part(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_TASK_PART_Rec     IN    TASK_PART_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_task_part
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
--       P_TASK_PART_Rec     IN TASK_PART_Rec_Type  Required
--       p_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE     Required
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
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_task_part(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_TASK_PART_Rec     IN TASK_PART_Rec_Type,
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
PROCEDURE Validate_TASK_PART_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_PART_ID                IN   NUMBER,
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
PROCEDURE Validate_PRODUCT_TASK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRODUCT_TASK_ID                IN   NUMBER,
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
PROCEDURE Validate_INVENTORY_ITEM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INVENTORY_ITEM_ID                IN   NUMBER,
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
PROCEDURE Validate_MANUAL_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MANUAL_QUANTITY                IN   NUMBER,
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
PROCEDURE Validate_MANUAL_PERCENTAGE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MANUAL_PERCENTAGE                IN   NUMBER,
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
PROCEDURE Validate_QUANTITY_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUANTITY_USED                IN   NUMBER,
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
PROCEDURE Validate_ACTUAL_TIMES_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ACTUAL_TIMES_USED                IN   NUMBER,
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

PROCEDURE Validate_PRIMARY_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRIMARY_UOM_CODE                IN   VARCHAR2,
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
PROCEDURE Validate_REVISION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REVISION                IN   VARCHAR2,
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
PROCEDURE Validate_START_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_START_DATE                IN   DATE,
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
PROCEDURE Validate_END_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_END_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_ROLLUP_QUANTITY_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ROLLUP_QUANTITY_USED                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_ROLLUP_TIMES_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ROLLUP_TIMES_USED          IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_SUBSTITUTE_ITEM (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SUBSTITUTE_ITEM          IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
PROCEDURE Validate_TASK_PART_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_PART_Rec     IN    TASK_PART_Rec_Type,
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
PROCEDURE Validate_task_part(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_PART_Rec     IN    TASK_PART_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
End CSP_TASK_PART_PVT;

 

/
