--------------------------------------------------------
--  DDL for Package IEX_COSTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_COSTS_PVT" AUTHID CURRENT_USER as
/* $Header: iexvcoss.pls 120.0 2004/01/24 03:25:08 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_COSTS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:costs_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    COST_ID
--    CASE_ID
--    DELINQUENCY_ID
--    COST_TYPE_CODE
--    COST_ITEM_TYPE_CODE
--    COST_ITEM_TYPE_DESC
--    COST_ITEM_AMOUNT
--    COST_ITEM_CURRENCY_CODE
--    COST_ITEM_QTY
--    COST_ITEM_DATE
--    FUNCTIONAL_AMOUNT
--    EXCHANGE_TYPE
--    EXCHANGE_RATE
--    EXCHANGE_DATE
--    COST_ITEM_APPROVED
--    ACTIVE_FLAG
--    OBJECT_VERSION_NUMBER
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
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
--    LAST_UPDATE_LOGIN
--
--
--   End of Comments

TYPE costs_Rec_Type IS RECORD
(
       COST_ID                         NUMBER := FND_API.G_MISS_NUM,
       CASE_ID                         NUMBER := FND_API.G_MISS_NUM,
       DELINQUENCY_ID                  NUMBER := FND_API.G_MISS_NUM,
       COST_TYPE_CODE                  VARCHAR2(240) := FND_API.G_MISS_CHAR,
       COST_ITEM_TYPE_CODE             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       COST_ITEM_TYPE_DESC             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       COST_ITEM_AMOUNT                NUMBER := FND_API.G_MISS_NUM,
       COST_ITEM_CURRENCY_CODE         VARCHAR2(15) := FND_API.G_MISS_CHAR,
       COST_ITEM_QTY                   NUMBER := FND_API.G_MISS_NUM,
       COST_ITEM_DATE                  DATE := FND_API.G_MISS_DATE,
       FUNCTIONAL_AMOUNT               NUMBER := FND_API.G_MISS_NUM,
       EXCHANGE_TYPE                   VARCHAR2(15) := FND_API.G_MISS_CHAR,
       EXCHANGE_RATE                   NUMBER := FND_API.G_MISS_NUM,
       EXCHANGE_DATE                   DATE := FND_API.G_MISS_DATE,
       COST_ITEM_APPROVED            VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ACTIVE_FLAG                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
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
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM
);

G_MISS_costs_REC          costs_Rec_Type;
TYPE  costs_Tbl_Type      IS TABLE OF costs_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_costs_TBL          costs_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_costs
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_costs_Rec     IN costs_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   End of Comments
--
PROCEDURE Create_costs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_costs_Rec                  IN    costs_Rec_Type  := G_MISS_costs_REC,
    X_COST_ID                    OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_costs
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_costs_Rec               IN costs_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_costs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_costs_Rec                  IN    costs_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    xo_object_version_number     OUT NOCOPY NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_costs
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_cost_ID                 IN NUMBER  Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
PROCEDURE Delete_costs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_cost_ID                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
End IEX_costs_PVT;

 

/
