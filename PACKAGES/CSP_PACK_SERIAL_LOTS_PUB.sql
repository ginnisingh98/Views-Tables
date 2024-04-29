--------------------------------------------------------
--  DDL for Package CSP_PACK_SERIAL_LOTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PACK_SERIAL_LOTS_PUB" AUTHID CURRENT_USER AS
/* $Header: cspptsps.pls 115.4 2002/11/26 07:01:31 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_Pack_Serial_Lots_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:plsl_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    ROW_ID
--    PACKLIST_SERIAL_LOT_ID
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    PACKLIST_LINE_ID
--    ORGANIZATION_ID
--    INVENTORY_ITEM_ID
--    QUANTITY
--    LOT_NUMBER
--    SERIAL_NUMBER
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE plsl_Rec_Type IS RECORD
(
       ROW_ID                          ROWID := FND_API.G_MISS_CHAR,
       PACKLIST_SERIAL_LOT_ID          NUMBER := FND_API.G_MISS_NUM,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE   := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE   := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       PACKLIST_LINE_ID                NUMBER := FND_API.G_MISS_NUM,
       ORGANIZATION_ID                 NUMBER := FND_API.G_MISS_NUM,
       INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
       QUANTITY                        NUMBER := FND_API.G_MISS_NUM,
       LOT_NUMBER                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SERIAL_NUMBER                   VARCHAR2(240) := FND_API.G_MISS_CHAR
);

G_MISS_plsl_REC          plsl_Rec_Type;
TYPE  plsl_Tbl_Type      IS TABLE OF plsl_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_plsl_TBL          plsl_Tbl_Type;

TYPE plsl_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      PACKLIST_SERIAL_LOT_ID   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_pack_serial_lots
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_plsl_Rec     IN plsl_Rec_Type  Required
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
PROCEDURE Create_pack_serial_lots(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_plsl_Rec     IN    plsl_Rec_Type  := G_MISS_plsl_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_PACKLIST_SERIAL_LOT_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_pack_serial_lots
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_plsl_Rec     IN plsl_Rec_Type  Required
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
PROCEDURE Update_pack_serial_lots(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_plsl_Rec     IN    plsl_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_pack_serial_lots
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_plsl_Rec     IN plsl_Rec_Type  Required
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
PROCEDURE Delete_pack_serial_lots(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_plsl_Rec     IN plsl_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_pack_serial_lots
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_plsl_Rec     IN plsl_Rec_Type  Required
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
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       X_plsl_Tbl     OUT NOCOPY plsl_Rec_Type
--       x_returned_rec_count      OUT NOCOPY   NUMBER
--       x_next_rec_ptr            OUT NOCOPY   NUMBER
--       x_tot_rec_count           OUT NOCOPY   NUMBER
--  other optional OUT NOCOPY parameters
--       x_tot_rec_amount          OUT NOCOPY   NUMBER
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Get_pack_serial_lots(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_plsl_Rec     IN    CSP_pack_serial_lots_PUB.plsl_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   CSP_pack_serial_lots_PUB.plsl_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_plsl_Tbl  OUT NOCOPY  CSP_pack_serial_lots_PUB.plsl_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY  NUMBER
    );

End CSP_Pack_Serial_Lots_PUB;

 

/
