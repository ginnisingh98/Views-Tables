--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_HEADERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_HEADERS_PUB" AUTHID CURRENT_USER AS
/* $Header: cspprqhs.pls 120.0.12010000.1 2010/03/17 16:45:05 htank noship $ */
-- Start of Comments
-- Package name     : CSP_Requirement_Headers_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:RQ_Rec_Type
--   -------------------------------------------------------
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE RQH_Rec_Type IS RECORD
(
    ROW_ID                          ROWID := FND_API.G_MISS_CHAR,
    REQUIREMENT_HEADER_ID           NUMBER := FND_API.G_MISS_NUM,
    CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
    CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
    LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
    LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
    LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
    OPEN_REQUIREMENT                VARCHAR2(240) := FND_API.G_MISS_CHAR,
    ADDRESS_TYPE                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
    SHIP_TO_LOCATION_ID             NUMBER := FND_API.G_MISS_NUM,
    TIMEZONE_ID                     NUMBER := FND_API.G_MISS_NUM,
    TASK_ID                         NUMBER := FND_API.G_MISS_NUM,
    TASK_NUMBER                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
    TASK_ASSIGNMENT_ID              NUMBER := FND_API.G_MISS_NUM,
    RESOURCE_TYPE                   VARCHAR2(240) := FND_API.G_MISS_CHAR,
    RESOURCE_TYPE_NAME              VARCHAR2(240) := FND_API.G_MISS_CHAR,
    RESOURCE_ID                     NUMBER := FND_API.G_MISS_NUM,
    RESOURCE_NAME                   VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SHIPPING_METHOD_CODE            VARCHAR2(30) := FND_API.G_MISS_CHAR,
    NEED_BY_DATE                    DATE := FND_API.G_MISS_DATE,
    DESTINATION_ORGANIZATION_ID     NUMBER := FND_API.G_MISS_NUM,
    DESTINATION_ORGANIZATION_CODE   VARCHAR2(30) := FND_API.G_MISS_CHAR,
    ORDER_TYPE_ID                   NUMBER := FND_API.G_MISS_NUM,
    ORDER_TYPE                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
    PARTS_DEFINED                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
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
    SECURITY_GROUP_ID               NUMBER := FND_API.G_MISS_NUM,
    DESTINATION_SUBINVENTORY        VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_RQH_REC          RQH_Rec_Type;
TYPE  RQH_Tbl_Type      IS TABLE OF RQH_Rec_Type
    INDEX BY BINARY_INTEGER;
G_MISS_RQH_TBL          RQH_Tbl_Type;

TYPE RQH_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      REQUIREMENT_HEADER_ID   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_requirement_headers
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_RQH_Rec                 IN   RQH_Rec_Type  Required
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
PROCEDURE Create_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQH_Rec                    IN   RQH_Rec_Type  := G_MISS_RQH_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_REQUIREMENT_HEADER_ID      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_requirement_headers
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_RQH_Rec                 IN   RQH_Rec_Type  Required
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
PROCEDURE Update_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQH_Rec                    IN    RQH_Rec_Type := G_MISS_RQH_REC,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_requirement_headers
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_RQH_Rec                 IN   RQH_Rec_Type  Required
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
PROCEDURE Delete_requirement_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQH_Rec                    IN   RQH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

END CSP_REQUIREMENT_HEADERS_PUB; -- Package spec

/
