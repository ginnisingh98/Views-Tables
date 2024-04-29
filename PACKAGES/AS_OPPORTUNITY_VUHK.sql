--------------------------------------------------------
--  DDL for Package AS_OPPORTUNITY_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OPPORTUNITY_VUHK" AUTHID CURRENT_USER as
/* $Header: asxvhops.pls 115.5 2002/12/13 12:45:59 nkamble ship $ */
-- Start of Comments
-- Package name     : AS_OPPORTUNITY_VUHK
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_opp_header_Post
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN:
--      p_api_version_number IN NUMBER   Required
--      p_init_msg_list      IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit             IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level   IN NUMBER   Optional Default =
--                                                   FND_API.G_VALID_LEVEL_FULL
--      P_Header_Rec         IN AS_OPPORTUNITY_PUB.Header_Rec_Type  Required
--
--   OUT:
--      x_return_status      OUT  VARCHAR2
--      x_msg_count          OUT  NUMBER
--      x_msg_data           OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments

PROCEDURE Create_opp_header_Post(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_salesgroup_id              IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type
                                      := AS_OPPORTUNITY_PUB.G_MISS_Header_REC,
    X_LEAD_ID                    OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_opp_header_Pre
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--      p_api_version_number     IN NUMBER   Required
--      p_init_msg_list          IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit                 IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level       IN NUMBER   Optional Default =
--                                                    FND_API.G_VALID_LEVEL_FULL
--      p_identity_salesforce_id IN NUMBER   Optional Default = NULL
--      P_Header_Rec             IN AS_OPPORTUNITY_PUB.Header_Rec_Type
--                                           Required
--
--   OUT:
--      x_return_status           OUT  VARCHAR2
--      x_msg_count               OUT  NUMBER
--      x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments

PROCEDURE Update_opp_header_Pre(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_opp_header_Post
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--      p_api_version_number     IN NUMBER   Required
--      p_init_msg_list          IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit                 IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level       IN NUMBER   Optional Default =
--                                                    FND_API.G_VALID_LEVEL_FULL
--      p_identity_salesforce_id IN NUMBER   Optional Default = NULL
--      P_Header_Rec             IN AS_OPPORTUNITY_PUB.Header_Rec_Type
--                                           Required
--
--   OUT:
--      x_return_status           OUT  VARCHAR2
--      x_msg_count               OUT  NUMBER
--      x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments

PROCEDURE Update_opp_header_Post(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_opp_header
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--      p_api_version_number     IN NUMBER   Required
--      p_init_msg_list          IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit                 IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level       IN NUMBER   Optional Default =
--                                                    FND_API.G_VALID_LEVEL_FULL
--      p_identity_salesforce_id IN NUMBER   Optional Default = NULL
--      P_lead_id                IN NUMBER   Required
--
--   OUT:
--      x_return_status           OUT  VARCHAR2
--      x_msg_count               OUT  NUMBER
--      x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments

/*
PROCEDURE Delete_opp_header_Pre(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_lead_id                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

*/

End AS_OPPORTUNITY_VUHK;

 

/
