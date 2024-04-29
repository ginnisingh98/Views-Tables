--------------------------------------------------------
--  DDL for Package IEX_CASE_DEFINITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CASE_DEFINITIONS_PVT" AUTHID CURRENT_USER as
/* $Header: iexvcdfs.pls 120.0 2004/01/24 03:24:53 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_CASE_DEFINITIONS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:CASE_DEFINITION_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    CASE_DEFINITION_ID
--    COLUMN_NAME
--    COLUMN_VALUE
--    ACTIVE_FLAG
--    TABLE_NAME
--    OBJECT_VERSION_NUMBER
--    CAS_ID
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
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
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--
--    Required:
--   End of Comments

TYPE CASE_DEFINITION_Rec_Type IS RECORD
(
       CASE_DEFINITION_ID              NUMBER := FND_API.G_MISS_NUM,
       COLUMN_NAME                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
       COLUMN_VALUE                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ACTIVE_FLAG                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
       TABLE_NAME                      VARCHAR2(30) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM,
       CAS_ID                          NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       ATTRIBUTE_CATEGORY              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
);

G_MISS_CASE_DEFINITION_REC          CASE_DEFINITION_Rec_Type;
TYPE  CASE_DEFINITION_Tbl_Type      IS TABLE OF CASE_DEFINITION_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_CASE_DEFINITION_TBL          CASE_DEFINITION_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_CASE_DEFINITIONS
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CASE_DEFINITION_Rec         IN CASE_DEFINITION_Rec_Type  Required

--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       x_CASE_DEFINITION_id          OUT NOCOPY NUMBER

--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_CASE_DEFINITIONS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_CASE_DEFINITION_Rec        IN    CASE_DEFINITION_Rec_Type  := G_MISS_CASE_DEFINITION_REC,
    X_CASE_DEFINITION_ID         OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_CASE_DEFINITIONS
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CASE_DEFINITION_Rec     IN CASE_DEFINITION_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_CASE_DEFINITIONS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_CASE_DEFINITION_Rec        IN    CASE_DEFINITION_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    XO_OBJECT_VERSION_NUMBER     OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_CASE_DEFINITIONS
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CASE_DEFINITION_Rec     IN CASE_DEFINITION_Rec_Type  Required
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
PROCEDURE Delete_CASE_DEFINITIONS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_CASE_DEFINITION_Id         IN NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End IEX_CASE_DEFINITIONS_PVT;

 

/
