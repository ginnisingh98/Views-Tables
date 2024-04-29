--------------------------------------------------------
--  DDL for Package AS_LINK_LEAD_OPP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LINK_LEAD_OPP_PUB" AUTHID CURRENT_USER as
/* $Header: asxpllos.pls 115.1 2002/11/15 01:37:07 axavier ship $ */
-- Start of Comments
-- Package name     : AS_LINK_LEAD_OPP_PUB
-- Purpose          : Link/Copy Leads to Opportunity
-- NOTE             :
-- History          :
--     06/25/2002 FFANG  Created.
--
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;


--
--   API Name:  Get_Potential_Opportunity
--
PROCEDURE Get_Potential_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                          := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_rec             IN   AS_SALES_LEADS_PUB.SALES_LEAD_rec_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_OPPORTUNITY_TBL            OUT NOCOPY  AS_OPPORTUNITY_PUB.HEADER_TBL_TYPE,
    X_OPP_LINES_tbl              OUT NOCOPY  AS_OPPORTUNITY_PUB.LINE_TBL_TYPE
    );

--
--   API Name:  Copy_Lead_To_Opportunity
--
PROCEDURE Copy_Lead_To_Opportunity(
    P_Api_Version_Number        IN   NUMBER,
    P_Init_Msg_List             IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                    IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag         IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id            IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id    IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id    IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl    IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                         := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID             IN   NUMBER,
    P_SALES_LEAD_LINE_TBL       IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_TBL_TYPE
                              := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_LINE_TBL,
    P_OPPORTUNITY_ID            IN   NUMBER,
    X_Return_Status             OUT NOCOPY  VARCHAR2,
    X_Msg_Count                 OUT NOCOPY  NUMBER,
    X_Msg_Data                  OUT NOCOPY  VARCHAR2
    );

--
--   API Name:  Link_Lead_To_Opportunity
--
PROCEDURE Link_Lead_To_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                          := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPPORTUNITY_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--
--   API Name:  Create_Opportunity_For_Lead
--
PROCEDURE Create_Opportunity_For_Lead(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
								:= AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPP_STATUS                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_OPPORTUNITY_ID             OUT NOCOPY  NUMBER
    );


End AS_LINK_LEAD_OPP_PUB;

 

/
