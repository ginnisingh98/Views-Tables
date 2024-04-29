--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_LINES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_LINES_PUB" AUTHID CURRENT_USER AS
/* $Header: cspprqls.pls 120.0.12010000.1 2010/03/17 16:47:52 htank noship $ */
-- Start of Comments
-- Package name     : CSP_Requirement_Lines_PUB
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

TYPE RQL_Rec_Type IS RECORD
(
    ROW_ID                          ROWID := FND_API.G_MISS_CHAR,
    REQUIREMENT_LINE_ID             NUMBER := FND_API.G_MISS_NUM,
    CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
    CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
    LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
    LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
    LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
    REQUIREMENT_HEADER_ID           NUMBER := FND_API.G_MISS_NUM,
    INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
    UOM_CODE                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
    REQUIRED_QUANTITY               NUMBER := FND_API.G_MISS_NUM,
    SHIP_COMPLETE_FLAG              VARCHAR2(3) := FND_API.G_MISS_CHAR,
    LIKELIHOOD                      NUMBER := FND_API.G_MISS_NUM,
    REVISION                        VARCHAR2(3) := FND_API.G_MISS_CHAR,
    SOURCE_ORGANIZATION_ID          NUMBER := FND_API.G_MISS_NUM,
    SOURCE_SUBINVENTORY             VARCHAR2(30) := FND_API.G_MISS_CHAR,
    ORDERED_QUANTITY                NUMBER := FND_API.G_MISS_NUM,
    ORDER_LINE_ID                 NUMBER := FND_API.G_MISS_NUM,
    RESERVATION_ID                  NUMBER := FND_API.G_MISS_NUM,
    LOCAL_RESERVATION_ID            NUMBER := FND_API.G_MISS_NUM,
    ORDER_BY_DATE                   DATE := FND_API.G_MISS_DATE,
    ARRIVAL_DATE                    DATE := FND_API.G_MISS_DATE,
    ITEM_SCRATCHPAD                 VARCHAR2(1996) := FND_API.G_MISS_CHAR,
    SHIPPING_METHOD_CODE            VARCHAR2(30) := FND_API.G_MISS_CHAR,
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
    SOURCED_FROM                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
    SEGMENT1                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT2                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT3                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT4                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT5                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT6                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT7                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT8                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT9                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT10                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT11                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT12                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT13                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT14                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT15                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT16                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT17                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT18                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT19                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
    SEGMENT20                       VARCHAR2(240) := FND_API.G_MISS_CHAR
);

G_MISS_RQL_REC          RQL_Rec_Type;
TYPE  RQL_Tbl_Type      IS TABLE OF RQL_Rec_Type
    INDEX BY BINARY_INTEGER;
G_MISS_RQL_TBL          RQL_Tbl_Type;

TYPE RQL_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      REQUIREMENT_LINE_ID   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_requirement_lines
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_RQL_Rec                 IN   RQL_Rec_Type  Required
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
PROCEDURE Create_requirement_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQL_Tbl                    IN   RQL_Tbl_Type  := G_MISS_RQL_TBL,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_REQUIREMENT_LINE_Tbl       OUT NOCOPY  RQL_Tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_requirement_lines
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_RQL_Rec                 IN   RQL_Rec_Type  Required
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
PROCEDURE Update_requirement_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQL_Tbl                    IN    RQL_Tbl_Type := G_MISS_RQL_TBL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_requirement_lines
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_RQL_Rec                 IN   RQL_Rec_Type  Required
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
PROCEDURE Delete_requirement_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQL_Tbl                    IN   RQL_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

END CSP_REQUIREMENT_LINES_PUB; -- Package spec


/
