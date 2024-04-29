--------------------------------------------------------
--  DDL for Package AST_GRP_CAMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_GRP_CAMP_PUB" AUTHID CURRENT_USER as
/* $Header: astpgcas.pls 115.3 2002/02/05 17:26:38 pkm ship   $ */
-- Start of Comments
-- Package name     : ast_grp_camp_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:grp_camp_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    GROUP_CAMPAIGN_ID
--    GROUP_ID
--    CAMPAIGN_ID
--    START_DATE
--    END_DATE
--    ENABLED_FLAG
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    CREATED_BY
--    CREATION_DATE
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE grp_camp_Rec_Type IS RECORD
(
       GROUP_CAMPAIGN_ID               NUMBER := FND_API.G_MISS_NUM,
       GROUP_ID                        NUMBER := FND_API.G_MISS_NUM,
       CAMPAIGN_ID                     NUMBER := FND_API.G_MISS_NUM,
       START_DATE                      DATE := FND_API.G_MISS_DATE,
       END_DATE                        DATE := FND_API.G_MISS_DATE,
       ENABLED_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE
);

G_MISS_grp_camp_REC          grp_camp_Rec_Type;
TYPE  grp_camp_Tbl_Type      IS TABLE OF grp_camp_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_grp_camp_TBL          grp_camp_Tbl_Type;

TYPE grp_camp_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      GROUP_ID   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_grp_camp
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_grp_camp_Rec     IN grp_camp_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_grp_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_grp_camp_Rec     IN    grp_camp_Rec_Type  := G_MISS_grp_camp_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_GROUP_CAMPAIGN_ID     OUT  NUMBER,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_grp_camp
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_grp_camp_Rec     IN grp_camp_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_grp_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_grp_camp_Rec     IN    grp_camp_Rec_Type,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_grp_camp
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_grp_camp_Rec     IN grp_camp_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_grp_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_grp_camp_Rec     IN grp_camp_Rec_Type,
    X_Return_Status              OUT  VARCHAR2,
    X_Msg_Count                  OUT  NUMBER,
    X_Msg_Data                   OUT  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_grp_camp
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_grp_camp_Rec     IN grp_camp_Rec_Type  Required
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
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       X_grp_camp_Tbl     OUT grp_camp_Rec_Type
--       x_returned_rec_count      OUT   NUMBER
--       x_next_rec_ptr            OUT   NUMBER
--       x_tot_rec_count           OUT   NUMBER
--  other optional out parameters
--       x_tot_rec_amount          OUT   NUMBER
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Get_grp_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_grp_camp_Rec     IN    ast_grp_camp_PUB.grp_camp_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   ast_grp_camp_PUB.grp_camp_sort_rec_type,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,
    X_grp_camp_Tbl  OUT  ast_grp_camp_PUB.grp_camp_Tbl_Type,
    x_returned_rec_count         OUT  NUMBER,
    x_next_rec_ptr               OUT  NUMBER,
    x_tot_rec_count              OUT  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT  NUMBER
    );

End ast_grp_camp_PUB;

 

/
