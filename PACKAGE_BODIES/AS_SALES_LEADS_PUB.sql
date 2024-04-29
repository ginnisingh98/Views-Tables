--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEADS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEADS_PUB" as
/* $Header: asxpslmb.pls 115.68 2003/11/17 19:41:45 chchandr ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEADS_PUB
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--     06/05/2000 FFANG  Created.
--     06/06/2000 FFANG  Modified according data schema changes.
--     09/21/2000 FFANG  Add two lines to others exception handling to meet
--                       coding standard
--     12/12/2000 FFANG  For bug 1529886, add one parameter P_OPP_STATUS in
--                       create_opportunity_for_lead to get opportunity status
--                       when creating opportunity
--     06/05/2001 SOLIN  Add API Build_Lead_Sales_Team and
--                       Rebuild_Lead_Sales_Team.
--     12/10/2001 SOLIN  Bug 2102901.
--                       Add salesgroup_id for current user in
--                       Build_Lead_Sales_Team and Rebuild_Lead_Sales_Team
--     03/05/2002 JRAMAN Added the Create_Opp_Entity_Attributes
--                       and Create_Opp_PSS_Lead_Lines procedures to populate
--                       the entity attributes when a lead gets converted
--			          to opportunity.
--     03/21/2002 SOLIN  Change API Run_Lead_Engines signature
--                       Add API Start_Partner_Matching
--     03/26/2002 AJOY   Add Route_Lead_To_Marketing API for assigning to
--                       marketing owner for the lead that does not have owner.
--     06/13/2002 SOLIN  Add AS_SALES_LEAD_RATINGS API.
--     07/10/2002 AJOY   Modify Route_Lead_To_Marketing API to see if the owner is specified.
--                       if so, ignore the process and use the owner provided.
--     07/19/2002 AJOY   Code changes due to decommission of Referral System and Attribute functionality.
--     08/06/2002 SOLIN  Comment out API Get_Potential_Opportunity because
--                       it's moved to package AS_LINK_LEAD_OPP_PUB.
--     11/04/2002 SOLIN  Add API Lead_Process_After_Create and
--                       Lead_Process_After_Update
--     02/06/2003 AJOY   Skipped looking into AS_ACCESSES_ALL for immature owner
--                       Manual access is taken care before calling ROUTE_LEAD_TO_MARKETING
--     03/07/2003 SOLIN  Bug 2822580
--                       Route_Lead_To_Marketing should remove access records
--                       when lead is updated.
--     03/14/2003 SOLIN  Bug 2852597
--                       Port 11.5.8 fix to 11.5.9.
--     03/20/2003 SOLIN  Bug 2858785
--                       Update address_id when user change address.
--                       To avoid duplicate record.
--     03/26/2003 SOLIN  Bug 2863580
--                       Update as_accesses_all when owner has record already
--                       in route_lead_to_marketing.
--     04/23/2003 SOLIN  Bug 2921021
--                       Route_Lead_To_Marketing should log lead_rank_id,
--                       assign_sales_group_id, qualified_flag in
--                       as_sales_leads_log.
--     04/24/2003 SOLIN  Bug 2923708
--                       Route_Lead_To_Marketing should set accept_flag to 'N'
--                       if owner is changed.
--     06/16/2003 SOLIN  Bug 3007246
--                       Route_Lead_To_Marketing should update sales_group_id
--                       for as_accesses_all table once a new owner is found.
--     08/19/2003 SOLIN  Bug 3102332
--                       Use type JTF_NUMBER_TABLE, instead of NUMBER_TABLE
--
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_SALES_LEADS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxpslmb.pls';
G_CREATE   NUMBER :=2;
G_UPDATE   NUMBER :=1;


-- *******************
--  Sales Lead Header
-- *******************

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Create_sales_lead(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag      IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag             IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id         IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                      := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec         IN   SALES_LEAD_Rec_Type := G_MISS_SALES_LEAD_REC,
    P_SALES_LEAD_LINE_tbl    IN   SALES_LEAD_LINE_tbl_type
                                        DEFAULT G_MISS_SALES_LEAD_LINE_tbl,
    P_SALES_LEAD_CONTACT_tbl IN   SALES_LEAD_CONTACT_tbl_type
                                        DEFAULT G_MISS_SALES_LEAD_CONTACT_tbl,
    X_SALES_LEAD_ID          OUT NOCOPY  NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl OUT NOCOPY SALES_LEAD_LINE_OUT_Tbl_Type,
    X_SALES_LEAD_CNT_OUT_Tbl OUT NOCOPY  SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Create_sales_lead';
    l_api_version_number      CONSTANT NUMBER   := 2.0;

BEGIN
      SAVEPOINT CREATE_SALES_LEAD_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Create_SALES_LEADS
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Call PVT.Create_sales_lead');
      END IF;

      AS_SALES_LEADS_PVT.Create_sales_lead(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_Rec             => P_SALES_LEAD_Rec,
            P_SALES_LEAD_LINE_tbl        => P_SALES_LEAD_LINE_tbl,
            P_SALES_LEAD_CONTACT_tbl     => P_SALES_LEAD_CONTACT_tbl,
            X_SALES_LEAD_ID              => x_SALES_LEAD_ID,
            X_SALES_LEAD_LINE_OUT_Tbl    => X_SALES_LEAD_LINE_OUT_Tbl,
            X_SALES_LEAD_CNT_OUT_Tbl     => X_SALES_LEAD_CNT_OUT_Tbl,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Create_sales_lead;


PROCEDURE Update_sales_lead(
    P_Api_Version_Number IN   NUMBER,
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit             IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level   IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag  IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag         IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id     IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                      := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec     IN   SALES_LEAD_Rec_Type DEFAULT G_MISS_SALES_LEAD_REC,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Update_sales_lead';
    l_api_version_number      CONSTANT NUMBER   := 2.0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SALES_LEAD_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'PUB: Calling PVT.Update_sales_lead');

      END IF;
      AS_SALES_LEADS_PVT.Update_sales_lead(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,   -- p_commit,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_Rec             => P_SALES_LEAD_Rec,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_sales_lead;


-- *******************
--  Sales Lead Lines
-- *******************

PROCEDURE Create_sales_lead_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER     := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER     := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl        IN   SALES_LEAD_LINE_Tbl_type
                                              := G_MISS_SALES_LEAD_LINE_Tbl,
    p_SALES_LEAD_ID              IN   NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl    OUT NOCOPY  SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Create_sales_lead_lines';
    l_api_version_number    CONSTANT NUMBER   := 2.0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SALES_LEAD_LINES_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Create_SALES_LEAD_LINE
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Calling PVT.Create_lines');
      END IF;
      AS_SALES_LEAD_LINES_PVT.Create_sales_lead_lines(
          P_Api_Version_Number         => 2.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          P_Validation_Level           => P_Validation_Level,
          P_Check_Access_Flag          => P_Check_Access_Flag,
          P_Admin_Flag                 => P_Admin_Flag,
          P_Admin_Group_Id             => P_Admin_Group_Id,
          P_identity_salesforce_id     => P_identity_salesforce_id,
          P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
          P_SALES_LEAD_LINE_Tbl        => P_SALES_LEAD_LINE_Tbl,
	  p_SALES_LEAD_ID              => p_sales_lead_id,
          X_SALES_LEAD_LINE_OUT_tbl    => x_SALES_LEAD_LINE_OUT_tbl,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Create_sales_lead_lines;


PROCEDURE Update_sales_lead_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER     := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER     := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl        IN   SALES_LEAD_LINE_Tbl_Type,
    X_SALES_LEAD_LINE_OUT_Tbl    OUT NOCOPY  SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Update_sales_lead_lines';
    l_api_version_number    CONSTANT NUMBER   := 2.0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SALES_LEAD_LINES_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'PUB: Calling PVT.Update_lines');

      END IF;

      AS_SALES_LEAD_LINES_PVT.Update_sales_lead_lines(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,   -- p_commit,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_LINE_Tbl        => P_SALES_LEAD_LINE_Tbl,
            X_SALES_LEAD_LINE_OUT_Tbl    => X_Sales_Lead_Line_Out_tbl,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Update_sales_lead_lines;


PROCEDURE Delete_sales_lead_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER     := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER     := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_LINE_Tbl        IN   SALES_LEAD_LINE_Tbl_Type,
    X_SALES_LEAD_LINE_OUT_Tbl    OUT NOCOPY  SALES_LEAD_LINE_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Delete_sales_lead_lines';
    l_api_version_number   CONSTANT NUMBER   := 2.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SALES_LEAD_LINES_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Calling PVT.Delete_lines');

      END IF;
      AS_SALES_LEAD_LINES_PVT.Delete_sales_lead_lines(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,   -- p_commit,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_LINE_Tbl        => P_SALES_LEAD_LINE_Tbl,
            X_SALES_LEAD_LINE_OUT_Tbl    => X_Sales_Lead_Line_Out_tbl,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Delete_sales_lead_lines;


-- *********************
--  Sales Lead Contacts
-- *********************

PROCEDURE Create_sales_lead_contacts(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag               IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id           IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id   IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl   IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl   IN   SALES_LEAD_CONTACT_Tbl_Type
                                         := G_MISS_SALES_LEAD_CONTACT_Tbl,
    p_SALES_LEAD_ID            IN   NUMBER,
    X_SALES_LEAD_CNT_OUT_Tbl   OUT NOCOPY  SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name            CONSTANT VARCHAR2(30) := 'Create_sales_lead_contacts';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SALES_LEAD_CONTACTS_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Create_SALES_LEAD_LINE
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Calling PVT.Create_contacts');
      END IF;
      AS_SALES_LEAD_CONTACTS_PVT.Create_sales_lead_contacts(
          P_Api_Version_Number         => 2.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          P_Validation_Level           => P_Validation_Level,
          P_Check_Access_Flag          => P_Check_Access_Flag,
          P_Admin_Flag                 => P_Admin_Flag,
          P_Admin_Group_Id             => P_Admin_Group_Id,
          P_identity_salesforce_id     => P_identity_salesforce_id,
          P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
          P_SALES_LEAD_CONTACT_Tbl     => P_SALES_LEAD_CONTACT_Tbl,
	  p_SALES_LEAD_ID              => p_sales_lead_id,
          x_SALES_LEAD_CNT_OUT_Tbl     => X_SALES_LEAD_CNT_OUT_Tbl,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_sales_lead_contacts;


--   API Name:  Update_sales_lead_contact
--
PROCEDURE Update_sales_lead_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl     IN   SALES_LEAD_CONTACT_Tbl_Type,
    X_SALES_LEAD_CNT_OUT_Tbl     OUT NOCOPY  SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name            CONSTANT VARCHAR2(30) := 'Update_sales_lead_contacts';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SALES_LEAD_CONTACTS_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Calling PVT.Update_contacts');

      END IF;
      AS_SALES_LEAD_CONTACTS_PVT.Update_sales_lead_contacts(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,   -- p_commit,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_CONTACT_Tbl     => P_SALES_LEAD_CONTACT_Tbl,
            x_SALES_LEAD_CNT_OUT_Tbl => X_SALES_LEAD_CNT_OUT_Tbl,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Update_sales_lead_contacts;



--   API Name:  Delete_sales_lead_contacts
PROCEDURE Delete_sales_lead_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_CONTACT_Tbl     IN   SALES_LEAD_CONTACT_Tbl_Type,
    X_SALES_LEAD_CNT_OUT_Tbl     OUT NOCOPY  SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Delete_sales_lead_contacts';
    l_api_version_number   CONSTANT NUMBER   := 2.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SALES_LEAD_CONTACTS_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Calling PVT.Delete_contacts');

      END IF;
      AS_SALES_LEAD_CONTACTS_PVT.Delete_sales_lead_contacts(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,   -- p_commit,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_CONTACT_Tbl     => P_SALES_LEAD_CONTACT_Tbl,
            x_SALES_LEAD_CNT_OUT_Tbl     => X_SALES_LEAD_CNT_OUT_Tbl,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Delete_sales_lead_contacts;

--   API Name:  Get_Potential_Opportunity
--     08/06/2002 SOLIN  Comment out API Get_Potential_Opportunity because
--                       it's moved to package AS_LINK_LEAD_OPP_PUB.
/*
PROCEDURE Get_Potential_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_rec             IN   SALES_LEAD_rec_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_OPPORTUNITY_TBL            OUT NOCOPY  AS_OPPORTUNITY_PUB.HEADER_TBL_TYPE,
    X_OPP_LINES_tbl              OUT NOCOPY  AS_OPPORTUNITY_PUB.LINE_TBL_TYPE

    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Get_Potential_Opportunity';
    l_api_version_number   CONSTANT NUMBER   := 2.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_POTENTIAL_OPPORTUNITY_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling private API
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Call PVT.Get_Potential_Opportunity');
      END IF;
      AS_SALES_LEAD_OPP_PVT.Get_Potential_Opportunity(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_Rec             => P_SALES_LEAD_Rec,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data,
            X_OPPORTUNITY_TBL            => X_OPPORTUNITY_TBL,
            X_OPP_LINES_tbl              => X_OPP_LINES_tbl
      );

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);



End Get_Potential_Opportunity;
*/

--   API Name:  Copy_Lead_To_Opportunity
/* API renamed by Francis on 06/26/2001 from Link_Lead_To_Opportunity to Copy_Lead_To_Opportunity */

PROCEDURE Copy_Lead_To_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id	 IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_SALES_LEAD_LINE_TBL        IN   SALES_LEAD_LINE_TBL_TYPE
                                                  := G_MISS_SALES_LEAD_LINE_TBL,
    P_OPPORTUNITY_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Copy_Lead_To_Opportunity';
    l_api_version_number   CONSTANT NUMBER   := 2.0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_LEAD_TO_OPPORTUNITY_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Calling private API
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Call PVT.Copy_Lead_To_Opportunity');
      END IF;
      AS_SALES_LEAD_OPP_PVT.Copy_Lead_To_Opportunity(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_identity_salesgroup_id	 => P_identity_salesgroup_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_ID              => p_SALES_LEAD_ID ,
            P_SALES_LEAD_LINE_TBL        => P_SALES_LEAD_LINE_TBL,
            P_OPPORTUNITY_ID             => P_OPPORTUNITY_ID,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Copy_Lead_To_Opportunity;






--   API Name:  Link_Lead_To_Opportunity
/* API added by Francis on 06/26/2001 */

PROCEDURE Link_Lead_To_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id	 IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPPORTUNITY_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Link_Lead_To_Opportunity';
    l_api_version_number   CONSTANT NUMBER   := 2.0;
    l_SALES_LEAD_Rec         AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                      DEFAULT AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC;
    CURSOR C_Get_Sales_Lead (X_Sales_Lead_Id NUMBER) IS
      SELECT sales_lead_id
             ,last_update_date
             ,last_updated_by
             ,creation_date
             ,created_by
             ,last_update_login
             ,request_id
             ,program_application_id
             ,program_id
             ,program_update_date
             ,lead_number
             ,status_code
             ,customer_id
             ,address_id
             ,source_promotion_id
             ,initiating_contact_id
             ,orig_system_reference
             ,contact_role_code
             ,channel_code
             ,budget_amount
             ,currency_code
             ,decision_timeframe_code
             ,close_reason
             ,lead_rank_code
             ,parent_project
             ,description
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,assign_to_person_id
             ,assign_to_salesforce_id
             ,budget_status_code
             ,assign_date
             ,accept_flag
             ,vehicle_response_code
             ,total_score
             ,scorecard_id
             ,keep_flag
             ,urgent_flag
             ,import_flag
             ,reject_reason_code
             ,lead_rank_id
             ,deleted_flag
             ,assign_sales_group_id
             ,offer_id
             -- ,security_group_id
             ,incumbent_partner_party_id
             ,incumbent_partner_resource_id
             ,PRM_EXEC_SPONSOR_FLAG
             ,PRM_PRJ_LEAD_IN_PLACE_FLAG
             ,PRM_SALES_LEAD_TYPE
             ,PRM_IND_CLASSIFICATION_CODE
             ,QUALIFIED_FLAG
             ,ORIG_SYSTEM_CODE
             ,PRM_ASSIGNMENT_TYPE
             ,AUTO_ASSIGNMENT_TYPE
             ,PRIMARY_CONTACT_PARTY_ID

             ,PRIMARY_CNT_PERSON_PARTY_ID
             ,PRIMARY_CONTACT_PHONE_ID


             ,REFERRED_BY
             ,REFERRAL_TYPE
             ,REFERRAL_STATUS
             ,REF_DECLINE_REASON
             ,REF_COMM_LTR_STATUS
             ,REF_ORDER_NUMBER
             ,REF_ORDER_AMT
             ,REF_COMM_AMT
-- bug No.2341515, 2368075
	     ,LEAD_DATE
	     ,SOURCE_SYSTEM
	     ,COUNTRY

-- 11.5.9
	, TOTAL_AMOUNT
	,EXPIRATION_DATE
	,LEAD_RANK_IND
	,LEAD_ENGINE_RUN_DATE
	,CURRENT_REROUTES

      FROM as_sales_leads
      WHERE sales_lead_id = X_Sales_Lead_Id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT LINK_LEAD_TO_OPPORTUNITY_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Calling private API
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: Call PVT.Link_Lead_To_Opportunity');
      END IF;
      AS_SALES_LEAD_OPP_PVT.Link_Lead_To_Opportunity(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_identity_salesgroup_id	 => P_identity_salesgroup_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_ID              => p_SALES_LEAD_ID ,
            P_OPPORTUNITY_ID             => P_OPPORTUNITY_ID,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

--- Anji's code starts here
-- Ajoy, Referral functionality decommissioned - start, 07/19/02
/*
      OPEN  C_Get_Sales_Lead (P_Sales_Lead_Id);
      FETCH C_Get_Sales_Lead INTO
            l_Sales_Lead_Rec.sales_lead_id
           ,l_Sales_Lead_Rec.last_update_date
           ,l_Sales_Lead_Rec.last_updated_by
           ,l_Sales_Lead_Rec.creation_date
           ,l_Sales_Lead_Rec.created_by
           ,l_Sales_Lead_Rec.last_update_login
           ,l_Sales_Lead_Rec.request_id
           ,l_Sales_Lead_Rec.program_application_id
           ,l_Sales_Lead_Rec.program_id
           ,l_Sales_Lead_Rec.program_update_date
           ,l_Sales_Lead_Rec.lead_number
           ,l_Sales_Lead_Rec.status_code
           ,l_Sales_Lead_Rec.customer_id
           ,l_Sales_Lead_Rec.address_id
           ,l_Sales_Lead_Rec.source_promotion_id
           ,l_Sales_Lead_Rec.initiating_contact_id
           ,l_Sales_Lead_Rec.orig_system_reference
           ,l_Sales_Lead_Rec.contact_role_code
           ,l_Sales_Lead_Rec.channel_code
           ,l_Sales_Lead_Rec.budget_amount
           ,l_Sales_Lead_Rec.currency_code
           ,l_Sales_Lead_Rec.decision_timeframe_code
           ,l_Sales_Lead_Rec.close_reason
           ,l_Sales_Lead_Rec.lead_rank_code
           ,l_Sales_Lead_Rec.parent_project
           ,l_Sales_Lead_Rec.description
           ,l_Sales_Lead_Rec.attribute_category
           ,l_Sales_Lead_Rec.attribute1
           ,l_Sales_Lead_Rec.attribute2
           ,l_Sales_Lead_Rec.attribute3
           ,l_Sales_Lead_Rec.attribute4
           ,l_Sales_Lead_Rec.attribute5
           ,l_Sales_Lead_Rec.attribute6
           ,l_Sales_Lead_Rec.attribute7
           ,l_Sales_Lead_Rec.attribute8
           ,l_Sales_Lead_Rec.attribute9
           ,l_Sales_Lead_Rec.attribute10
           ,l_Sales_Lead_Rec.attribute11
           ,l_Sales_Lead_Rec.attribute12
           ,l_Sales_Lead_Rec.attribute13
           ,l_Sales_Lead_Rec.attribute14
           ,l_Sales_Lead_Rec.attribute15
           ,l_Sales_Lead_Rec.assign_to_person_id
           ,l_Sales_Lead_Rec.assign_to_salesforce_id
           ,l_Sales_Lead_Rec.budget_status_code
           ,l_Sales_Lead_Rec.assign_date
           ,l_Sales_Lead_Rec.accept_flag
           ,l_Sales_Lead_Rec.vehicle_response_code
           ,l_Sales_Lead_Rec.total_score
           ,l_Sales_Lead_Rec.scorecard_id
           ,l_Sales_Lead_Rec.keep_flag
           ,l_Sales_Lead_Rec.urgent_flag
           ,l_Sales_Lead_Rec.import_flag
           ,l_Sales_Lead_Rec.reject_reason_code
           ,l_Sales_Lead_Rec.lead_rank_id
           ,l_Sales_Lead_Rec.deleted_flag
           ,l_Sales_Lead_Rec.assign_sales_group_id
           ,l_Sales_Lead_Rec.offer_id
           -- ,l_Sales_Lead_Rec.security_group_id
           ,l_Sales_Lead_Rec.incumbent_partner_party_id
           ,l_Sales_Lead_Rec.incumbent_partner_resource_id
           ,l_Sales_Lead_Rec.PRM_EXEC_SPONSOR_FLAG
            ,l_Sales_Lead_Rec.PRM_PRJ_LEAD_IN_PLACE_FLAG
            ,l_Sales_Lead_Rec.PRM_SALES_LEAD_TYPE
            ,l_Sales_Lead_Rec.PRM_IND_CLASSIFICATION_CODE
            ,l_Sales_Lead_Rec.QUALIFIED_FLAG
            ,l_Sales_Lead_Rec.ORIG_SYSTEM_CODE
            ,l_Sales_Lead_Rec.PRM_ASSIGNMENT_TYPE
             ,l_Sales_Lead_Rec.AUTO_ASSIGNMENT_TYPE
             ,l_Sales_Lead_Rec.PRIMARY_CONTACT_PARTY_ID

             ,l_Sales_Lead_Rec.PRIMARY_CNT_PERSON_PARTY_ID
             ,l_Sales_Lead_Rec.PRIMARY_CONTACT_PHONE_ID


             ,l_Sales_Lead_Rec.REFERRED_BY
             ,l_Sales_Lead_Rec.REFERRAL_TYPE
             ,l_Sales_Lead_Rec.REFERRAL_STATUS
             ,l_Sales_Lead_Rec.REF_DECLINE_REASON
             ,l_Sales_Lead_Rec.REF_COMM_LTR_STATUS
             ,l_Sales_Lead_Rec.REF_ORDER_NUMBER
             ,l_Sales_Lead_Rec.REF_ORDER_AMT
             ,l_Sales_Lead_Rec.REF_COMM_AMT
-- bug No.2341515, 2368075
	     ,l_Sales_Lead_Rec.LEAD_DATE
	     ,l_Sales_Lead_Rec.SOURCE_SYSTEM
	     ,l_Sales_Lead_Rec.COUNTRY

	     -- 11.5.9
	     	, l_Sales_Lead_Rec.TOTAL_AMOUNT
	     	,l_Sales_Lead_Rec.EXPIRATION_DATE
	     	,l_Sales_Lead_Rec.LEAD_RANK_IND
	     	,l_Sales_Lead_Rec.LEAD_ENGINE_RUN_DATE
		,l_Sales_Lead_Rec.CURRENT_REROUTES

           ;

     l_sales_lead_rec.SALES_LEAD_ID:=P_SALES_LEAD_ID;
     l_sales_lead_rec.referral_status:=fnd_profile.value('REF_STATUS_FOR_LINK_LEAD');

   AS_SALES_LEAD_REFERRAL.Update_sales_referral_lead(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_Rec		     => l_sales_lead_rec,
            p_overriding_usernames       => AS_SALES_LEAD_REFERRAL.G_MISS_OVER_USERNAMES_TBL,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data
        );
*/
-- Ajoy, Referral functionality decommissioned - end, 07/19/02

--REF_STATUS_FOR_LINK_LEAD
--- Anji's code ends here
      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Link_Lead_To_Opportunity;


/* API added by Jaya Raman on 03/05/2002 */
--   API Name:  Create_Opp_Entity_Attributes
PROCEDURE Create_Opp_Entity_Attributes(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPPORTUNITY_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name         	   	CONSTANT VARCHAR2(30) := 'Create_Opp_Entity_Attributes';
    l_api_version_number   	CONSTANT NUMBER   := 2.0;
    l_validation_level   	CONSTANT NUMBER   := FND_API.G_VALID_LEVEL_FULL;

    l_enty_attr_val_rec 		PV_ENTY_ATTR_VALUE_PVT.enty_attr_val_rec_type ;
    x_enty_attr_val_id        PV_ENTY_ATTR_VALUES.ENTY_ATTR_VAL_ID%TYPE;

     CURSOR C_Get_Entity_Attributes (X_Sales_Lead_Id NUMBER) IS
      SELECT  attribute_id
             ,attr_value
	        ,party_id
	        ,score
      FROM pv_enty_attr_values PVAV
      WHERE entity_id = X_Sales_Lead_Id
	 AND   entity = 'SALES_LEAD'
	 AND   enabled_flag = 'Y'
	 AND   attribute_id in  (Select    ATTRIBUTE_ID
						FROM 	PV_ENTITY_ATTRS pva
	 		     		where  	entity='LEAD'
						and 		pva.ATTRIBUTE_ID = pvav.attribute_id
					     and       enabled_flag = 'Y'
						);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_ENTITY_ATTRIBUTE;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Calling private API
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                               'PUB: Calling PVT.PV_Enty_Attr_Values_PVT.Create_Attr_Value');
      END IF;


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      OPEN  C_Get_Entity_Attributes (P_Sales_Lead_Id);
	 LOOP
      	FETCH C_Get_Entity_Attributes INTO
				l_enty_attr_val_rec.attribute_id
			,	l_enty_attr_val_rec.attr_value
			,	l_enty_attr_val_rec.party_id
			,	l_enty_attr_val_rec.score;
		EXIT WHEN C_Get_Entity_Attributes%NOTFOUND;


		l_enty_attr_val_rec.entity := 'LEAD';
		l_enty_attr_val_rec.entity_id := p_Opportunity_Id;
		l_enty_attr_val_rec.enabled_flag := 'Y';

		 PV_ENTY_ATTR_VALUE_PVT.Create_Attr_Value(
			    p_api_version_number => 1.0,
			    p_init_msg_list      => p_init_msg_list,
			    p_commit             => p_commit,
			    p_validation_level   => l_validation_level,
			    x_return_status      => x_return_status,
			    x_msg_count          => x_msg_count,
			    x_msg_data           => x_msg_data,
			    p_enty_attr_val_rec  => l_enty_attr_val_rec,
			    x_enty_attr_val_id   => x_enty_attr_val_id
			 );
	END LOOP;

      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_Opp_Entity_Attributes;

/* API added by Jaya Raman on 03/05/2002 */
--   API Name:  Create_Opp_Lead_PSS_Lines
PROCEDURE Create_Opp_Lead_PSS_Lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPPORTUNITY_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name         	   CONSTANT VARCHAR2(30) := 'Create_Opp_Lead_PSS_Lines';
    l_api_version_number   CONSTANT NUMBER   := 2.0;

    l_lead_pss_line_rec    PVX_LEAD_PSS_LINES_PVT.lead_pss_lines_rec_type ;
    x_lead_pss_line_id	   PV_LEAD_PSS_LINES.LEAD_PSS_LINE_ID%TYPE;

     CURSOR C_Get_pss_lead_lines (X_Sales_Lead_Id NUMBER) IS
      SELECT   	uom_code
			,	quantity
			,	amount
			,	attr_code_id
			,	partner_id
			,	attribute_category
			,	attribute1
			,	attribute2
			,	attribute3
			,	attribute4
			,	attribute5
			,	attribute6
			,	attribute7
			,	attribute8
			,	attribute9
			,	attribute10
			,	attribute11
			,	attribute12
			,	attribute13
			,	attribute14
			,	attribute15
      FROM PV_LEAD_PSS_LINES
      WHERE object_id = X_Sales_Lead_Id
	 AND   object_name = 'SALES_LEAD';
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_PSS_LEAD_LINE;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Calling private API
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                               'PUB: Calling PVT.PV_PSS_LEAD_LINES.Create_Lead_PSS_Line');
      END IF;


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      OPEN  C_Get_PSS_Lead_Lines (P_Sales_Lead_Id);
	 LOOP
      	FETCH C_Get_PSS_Lead_Lines INTO
		      			l_lead_pss_line_rec.uom_code
					,	l_lead_pss_line_rec.quantity
					,	l_lead_pss_line_rec.amount
					,	l_lead_pss_line_rec.attr_code_id
					,	l_lead_pss_line_rec.partner_id
					,	l_lead_pss_line_rec.attribute_category
					,	l_lead_pss_line_rec.attribute1
					,	l_lead_pss_line_rec.attribute2
					,	l_lead_pss_line_rec.attribute3
					,	l_lead_pss_line_rec.attribute4
					,	l_lead_pss_line_rec.attribute5
					,	l_lead_pss_line_rec.attribute6
					,	l_lead_pss_line_rec.attribute7
					,	l_lead_pss_line_rec.attribute8
					,	l_lead_pss_line_rec.attribute9
					,	l_lead_pss_line_rec.attribute10
					,	l_lead_pss_line_rec.attribute11
					,	l_lead_pss_line_rec.attribute12
					,	l_lead_pss_line_rec.attribute13
					,	l_lead_pss_line_rec.attribute14
					,	l_lead_pss_line_rec.attribute15;
		EXIT WHEN C_Get_PSS_Lead_Lines%NOTFOUND;

		l_lead_pss_line_rec.lead_id := p_opportunity_id;
		l_lead_pss_line_rec.object_id := p_opportunity_id;
		l_lead_pss_line_rec.object_name := 'OPPORTUNITY';

		PVX_lead_pss_lines_PVT.create_lead_pss_line(
			p_api_version_number => 1.0,
			p_init_msg_list      => p_init_msg_list,
			p_commit             => p_commit,
			p_validation_level   => p_validation_level,
			x_return_status      => x_return_status,
			x_msg_count          => x_msg_count,
			x_msg_data           => x_msg_data,
			p_lead_pss_lines_rec => l_lead_pss_line_rec,
			x_lead_pss_line_id   => x_lead_pss_line_id
			);
	END LOOP;

      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_Opp_Lead_PSS_Lines;

--   API Name:  Create_Opportunity_For_Lead
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
    )
 IS
    l_api_name         CONSTANT VARCHAR2(30) := 'Create_Opp_For_Lead';
    l_api_version_number   CONSTANT NUMBER   := 2.0;
    l_SALES_LEAD_Rec         AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                      DEFAULT AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC;
     CURSOR C_Get_Sales_Lead (X_Sales_Lead_Id NUMBER) IS
      SELECT sales_lead_id
             ,last_update_date
             ,last_updated_by
             ,creation_date
             ,created_by
             ,last_update_login
             ,request_id
             ,program_application_id
             ,program_id
             ,program_update_date
             ,lead_number
             ,status_code
             ,customer_id
             ,address_id
             ,source_promotion_id
             ,initiating_contact_id
             ,orig_system_reference
             ,contact_role_code
             ,channel_code
             ,budget_amount
             ,currency_code
             ,decision_timeframe_code
             ,close_reason
             ,lead_rank_code
             ,parent_project
             ,description
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,assign_to_person_id
             ,assign_to_salesforce_id
             ,budget_status_code
             ,assign_date
             ,accept_flag
             ,vehicle_response_code
             ,total_score
             ,scorecard_id
             ,keep_flag
             ,urgent_flag
             ,import_flag
             ,reject_reason_code
             ,lead_rank_id
             ,deleted_flag
             ,assign_sales_group_id
             ,offer_id
             -- ,security_group_id
             ,incumbent_partner_party_id
             ,incumbent_partner_resource_id
             ,PRM_EXEC_SPONSOR_FLAG
             ,PRM_PRJ_LEAD_IN_PLACE_FLAG
             ,PRM_SALES_LEAD_TYPE
             ,PRM_IND_CLASSIFICATION_CODE
             ,QUALIFIED_FLAG
             ,ORIG_SYSTEM_CODE
             ,PRM_ASSIGNMENT_TYPE
             ,AUTO_ASSIGNMENT_TYPE
             ,PRIMARY_CONTACT_PARTY_ID

             ,PRIMARY_CNT_PERSON_PARTY_ID
             ,PRIMARY_CONTACT_PHONE_ID


             ,REFERRED_BY
             ,REFERRAL_TYPE
             ,REFERRAL_STATUS
             ,REF_DECLINE_REASON
             ,REF_COMM_LTR_STATUS
             ,REF_ORDER_NUMBER
             ,REF_ORDER_AMT
             ,REF_COMM_AMT

-- bug No.2341515, 2368075
	     ,LEAD_DATE
	     ,SOURCE_SYSTEM
	     ,COUNTRY

	     -- 11.5.9
	     	, TOTAL_AMOUNT
	     	,EXPIRATION_DATE
	     	,LEAD_RANK_IND
	     	,LEAD_ENGINE_RUN_DATE
	,CURRENT_REROUTES




      FROM as_sales_leads
      WHERE sales_lead_id = X_Sales_Lead_Id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_FOR_LEAD_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Calling private API
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                               'PUB: Calling PVT.Create_Opportunity_For_Lead');
      END IF;

      AS_SALES_LEAD_OPP_PVT.Create_Opportunity_For_Lead(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,   -- 100,
            P_Check_Access_Flag          => P_Check_Access_Flag,   -- 'N',
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_identity_salesgroup_id	 => P_identity_salesgroup_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_ID              => p_SALES_LEAD_ID ,
            P_OPP_STATUS                 => P_OPP_STATUS,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data,
            X_OPPORTUNITY_ID             => X_OPPORTUNITY_ID);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --  Jaya Raman The following code will create the Entity Attributes
      --             and  PSS Lead Lines for the opportunity.

      -- Ajoy, commented out as this functionality is required now.
      /*
	Create_Opp_Entity_Attributes(
            	P_Api_Version_Number         => 2.0,
            	P_Init_Msg_List              => FND_API.G_FALSE,
            	P_Commit                     => FND_API.G_TRUE,
            	P_Validation_Level           => P_Validation_Level,
    			P_SALES_LEAD_ID              => p_SALES_LEAD_ID,
    			P_OPPORTUNITY_ID             => X_OPPORTUNITY_ID,
    			X_Return_Status              => x_return_status,
    			X_Msg_Count                  => x_msg_count,
    			X_Msg_Data                   => x_msg_data
    			);
        */

	/*Jaya Raman Commented this OUT NOCOPY for possible use in the future
	Create_Opp_Lead_PSS_Lines(
            	P_Api_Version_Number         => 2.0,
            	P_Init_Msg_List              => FND_API.G_FALSE,
            	P_Commit                     => FND_API.G_FALSE,
            	P_Validation_Level           => P_Validation_Level,
    			P_SALES_LEAD_ID              => p_SALES_LEAD_ID,
    			P_OPPORTUNITY_ID             => X_OPPORTUNITY_ID,
    			X_Return_Status              => x_return_status,
    			X_Msg_Count                  => x_msg_count,
    			X_Msg_Data                   => x_msg_data
    			);
	*/
--- Anji's code starts here
-- Ajoy, Referral functionality decommissioned - start, 07/19/02
/*
      OPEN  C_Get_Sales_Lead (P_Sales_Lead_Id);
      FETCH C_Get_Sales_Lead INTO
            l_Sales_Lead_Rec.sales_lead_id
           ,l_Sales_Lead_Rec.last_update_date
           ,l_Sales_Lead_Rec.last_updated_by
           ,l_Sales_Lead_Rec.creation_date
           ,l_Sales_Lead_Rec.created_by
           ,l_Sales_Lead_Rec.last_update_login
           ,l_Sales_Lead_Rec.request_id
           ,l_Sales_Lead_Rec.program_application_id
           ,l_Sales_Lead_Rec.program_id
           ,l_Sales_Lead_Rec.program_update_date
           ,l_Sales_Lead_Rec.lead_number
           ,l_Sales_Lead_Rec.status_code
           ,l_Sales_Lead_Rec.customer_id
           ,l_Sales_Lead_Rec.address_id
           ,l_Sales_Lead_Rec.source_promotion_id
           ,l_Sales_Lead_Rec.initiating_contact_id
           ,l_Sales_Lead_Rec.orig_system_reference
           ,l_Sales_Lead_Rec.contact_role_code
           ,l_Sales_Lead_Rec.channel_code
           ,l_Sales_Lead_Rec.budget_amount
           ,l_Sales_Lead_Rec.currency_code
           ,l_Sales_Lead_Rec.decision_timeframe_code
           ,l_Sales_Lead_Rec.close_reason
           ,l_Sales_Lead_Rec.lead_rank_code
           ,l_Sales_Lead_Rec.parent_project
           ,l_Sales_Lead_Rec.description
           ,l_Sales_Lead_Rec.attribute_category
           ,l_Sales_Lead_Rec.attribute1
           ,l_Sales_Lead_Rec.attribute2
           ,l_Sales_Lead_Rec.attribute3
           ,l_Sales_Lead_Rec.attribute4
           ,l_Sales_Lead_Rec.attribute5
           ,l_Sales_Lead_Rec.attribute6
           ,l_Sales_Lead_Rec.attribute7
           ,l_Sales_Lead_Rec.attribute8
           ,l_Sales_Lead_Rec.attribute9
           ,l_Sales_Lead_Rec.attribute10
           ,l_Sales_Lead_Rec.attribute11
           ,l_Sales_Lead_Rec.attribute12
           ,l_Sales_Lead_Rec.attribute13
           ,l_Sales_Lead_Rec.attribute14
           ,l_Sales_Lead_Rec.attribute15
           ,l_Sales_Lead_Rec.assign_to_person_id
           ,l_Sales_Lead_Rec.assign_to_salesforce_id
           ,l_Sales_Lead_Rec.budget_status_code
           ,l_Sales_Lead_Rec.assign_date
           ,l_Sales_Lead_Rec.accept_flag
           ,l_Sales_Lead_Rec.vehicle_response_code
           ,l_Sales_Lead_Rec.total_score
           ,l_Sales_Lead_Rec.scorecard_id
           ,l_Sales_Lead_Rec.keep_flag
           ,l_Sales_Lead_Rec.urgent_flag
           ,l_Sales_Lead_Rec.import_flag
           ,l_Sales_Lead_Rec.reject_reason_code
           ,l_Sales_Lead_Rec.lead_rank_id
           ,l_Sales_Lead_Rec.deleted_flag
           ,l_Sales_Lead_Rec.assign_sales_group_id
           ,l_Sales_Lead_Rec.offer_id
           -- ,l_Sales_Lead_Rec.security_group_id
           ,l_Sales_Lead_Rec.incumbent_partner_party_id
           ,l_Sales_Lead_Rec.incumbent_partner_resource_id
           ,l_Sales_Lead_Rec.PRM_EXEC_SPONSOR_FLAG
            ,l_Sales_Lead_Rec.PRM_PRJ_LEAD_IN_PLACE_FLAG
            ,l_Sales_Lead_Rec.PRM_SALES_LEAD_TYPE
            ,l_Sales_Lead_Rec.PRM_IND_CLASSIFICATION_CODE
            ,l_Sales_Lead_Rec.QUALIFIED_FLAG
            ,l_Sales_Lead_Rec.ORIG_SYSTEM_CODE
            ,l_Sales_Lead_Rec.PRM_ASSIGNMENT_TYPE
             ,l_Sales_Lead_Rec.AUTO_ASSIGNMENT_TYPE
             ,l_Sales_Lead_Rec.PRIMARY_CONTACT_PARTY_ID

             ,l_Sales_Lead_Rec.PRIMARY_CNT_PERSON_PARTY_ID
             ,l_Sales_Lead_Rec.PRIMARY_CONTACT_PHONE_ID


             ,l_Sales_Lead_Rec.REFERRED_BY
             ,l_Sales_Lead_Rec.REFERRAL_TYPE
             ,l_Sales_Lead_Rec.REFERRAL_STATUS
             ,l_Sales_Lead_Rec.REF_DECLINE_REASON
             ,l_Sales_Lead_Rec.REF_COMM_LTR_STATUS
             ,l_Sales_Lead_Rec.REF_ORDER_NUMBER
             ,l_Sales_Lead_Rec.REF_ORDER_AMT
             ,l_Sales_Lead_Rec.REF_COMM_AMT
 -- bug No.2341515, 2368075
	     ,l_Sales_Lead_Rec.LEAD_DATE
	     ,l_Sales_Lead_Rec.SOURCE_SYSTEM
	     ,l_Sales_Lead_Rec.COUNTRY

	     -- 11.5.9
	     	,l_Sales_Lead_Rec.TOTAL_AMOUNT
	     	,l_Sales_Lead_Rec.EXPIRATION_DATE
	     	,l_Sales_Lead_Rec.LEAD_RANK_IND
	     	,l_Sales_Lead_Rec.LEAD_ENGINE_RUN_DATE
		,l_Sales_Lead_Rec.CURRENT_REROUTES

           ;
     l_sales_lead_rec.SALES_LEAD_ID:=P_SALES_LEAD_ID;
     l_sales_lead_rec.referral_status:=fnd_profile.value('REF_STATUS_FOR_CONV_LEAD');

   AS_SALES_LEAD_REFERRAL.Update_sales_referral_lead(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_Rec		     => l_sales_lead_rec,
            p_overriding_usernames       => AS_SALES_LEAD_REFERRAL.G_MISS_OVER_USERNAMES_TBL,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data
        );
*/
-- Ajoy, Referral functionality decommissioned - end, 07/19/02
--REF_STATUS_FOR_CONV_LEAD
--- Anji's code ends here

      --
      -- End of API body
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_Opportunity_For_Lead;


--   API Name:  Assign_Sales_Lead
PROCEDURE Assign_Sales_Lead(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_Sales_Lead_Id              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_Assign_Id_Tbl              OUT NOCOPY  Assign_Id_Tbl_Type
    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Assign_Sales_Lead';
    l_api_version_number   CONSTANT NUMBER   := 2.0;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT ASSIGN_SALES_LEAD_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Pub: ' || l_api_name || ' Start');
    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --
    -- Calling private API
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PUB: Call PVT.Assign_Sales_Lead');
    END IF;

    AS_SALES_LEAD_ASSIGN_PVT.Assign_Sales_Lead(
          P_Api_Version_Number         => l_api_version_number,
          P_Init_Msg_List              => FND_API.G_FALSE,
          p_commit                     => FND_API.G_FALSE,
          p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
          P_Check_Access_Flag          => P_Check_Access_Flag,
          P_Admin_Flag                 => P_Admin_Flag,
          P_Admin_Group_Id             => P_Admin_Group_Id,
          P_identity_salesforce_id     => P_identity_salesforce_id,
          P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
          P_resource_type              => NULL,
          P_role                       => NULL,
          P_no_of_resources            => 1,
          P_auto_select_flag           => NULL,
          P_effort_duration            => NULL,
          P_effort_uom                 => NULL,
          P_start_date                 => NULL,
          p_end_date                   => NULL,
          P_territory_flag             => 'Y',
          P_calendar_flag              => 'Y',
          P_Sales_Lead_Id              => P_Sales_Lead_Id,
          X_Return_Status              => X_Msg_Count,
          X_Msg_Count                  => X_Msg_Count,
          X_Msg_Data                   => X_Msg_Data,
          X_Assign_Id_Tbl              => X_Assign_Id_Tbl
    );

    -- Check return status from the above procedure call
    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body
    --
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Pub: ' || l_api_name || ' End');
    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                 || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
End Assign_Sales_Lead;

PROCEDURE Get_Access_Profiles(
	p_profile_tbl			IN	AS_UTILITY_PUB.Profile_Tbl_Type,
	x_access_profile_rec OUT NOCOPY AS_ACCESS_PUB.Access_Profile_Rec_Type)
IS

    l_profile_count           CONSTANT NUMBER := p_profile_tbl.count;
    l_profile_value			VARCHAR2(1);

BEGIN
    FOR l_curr IN 1..l_profile_count LOOP
	l_profile_value := SUBSTR(p_profile_tbl(l_curr).PROFILE_VALUE, 1, 1);

	IF p_profile_tbl(l_curr).PROFILE_NAME = 'AS_OPP_ACCESS' THEN
	    x_access_profile_rec.opp_access_profile_value := l_profile_value;
	END IF;

	IF p_profile_tbl(l_curr).PROFILE_NAME = 'AS_LEAD_ACCESS' THEN
	    x_access_profile_rec.lead_access_profile_value := l_profile_value;
	END IF;

	IF p_profile_tbl(l_curr).PROFILE_NAME = 'AS_CUST_ACCESS' THEN
	    x_access_profile_rec.cust_access_profile_value := l_profile_value;
	END IF;

	IF p_profile_tbl(l_curr).PROFILE_NAME = 'AS_MGR_UPDATE' THEN
	    x_access_profile_rec.mgr_update_profile_value := l_profile_value;
	END IF;

	IF p_profile_tbl(l_curr).PROFILE_NAME = 'AS_ADMIN_UPDATE' THEN
	    x_access_profile_rec.admin_update_profile_value := l_profile_value;
	END IF;

    END LOOP;

    IF x_access_profile_rec.opp_access_profile_value IS NULL OR
       x_access_profile_rec.opp_access_profile_value = FND_API.G_MISS_CHAR
    THEN
	x_access_profile_rec.opp_access_profile_value
		:= FND_PROFILE.Value('AS_OPP_ACCESS');
    END IF;

    IF x_access_profile_rec.lead_access_profile_value IS NULL OR
       x_access_profile_rec.lead_access_profile_value = FND_API.G_MISS_CHAR
    THEN
	x_access_profile_rec.lead_access_profile_value
		:= FND_PROFILE.Value('AS_LEAD_ACCESS');
    END IF;

    IF x_access_profile_rec.cust_access_profile_value IS NULL OR
       x_access_profile_rec.cust_access_profile_value = FND_API.G_MISS_CHAR
    THEN
	x_access_profile_rec.cust_access_profile_value
		:= FND_PROFILE.Value('AS_CUST_ACCESS');
    END IF;

    IF x_access_profile_rec.mgr_update_profile_value IS NULL OR
       x_access_profile_rec.mgr_update_profile_value = FND_API.G_MISS_CHAR
    THEN
	x_access_profile_rec.mgr_update_profile_value
		:= FND_PROFILE.Value('AS_MGR_UPDATE');
    END IF;

    IF x_access_profile_rec.admin_update_profile_value IS NULL OR
       x_access_profile_rec.admin_update_profile_value = FND_API.G_MISS_CHAR
    THEN
	x_access_profile_rec.admin_update_profile_value
		:= FND_PROFILE.Value('AS_ADMIN_UPDATE');
    END IF;

END Get_Access_Profiles;


FUNCTION Get_Profile(
	p_profile_tbl		IN	AS_UTILITY_PUB.Profile_Tbl_Type,
	p_profile_name		IN 	VARCHAR2 )
  RETURN VARCHAR2
  IS
    l_profile_count                 CONSTANT NUMBER := p_profile_tbl.count;

BEGIN
    FOR l_curr IN 1..l_profile_count LOOP
	IF p_profile_tbl(l_curr).PROFILE_NAME = p_profile_name THEN
	    IF p_profile_tbl(l_curr).PROFILE_VALUE IS NOT NULL AND
	       p_profile_tbl(l_curr).PROFILE_VALUE <> FND_API.G_MISS_CHAR
	    THEN
		RETURN p_profile_tbl(l_curr).PROFILE_VALUE;
	    END IF;
	ELSE
	    NULL;
	END IF;
    END LOOP;
    RETURN NULL;
END;


PROCEDURE CALL_WF_TO_ASSIGN (
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    P_Sales_Lead_Id              IN  NUMBER,
    P_assigned_resource_id       IN  NUMBER DEFAULT NULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'CALL_WF_TO_ASSIGN';
    l_api_version_number   CONSTANT NUMBER   := 2.0;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT CALL_WF_TO_ASSIGN_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Pub: ' || l_api_name || ' Start');
    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --
    -- Calling private API
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PUB: Call PVT.CALL_WF_TO_ASSIGN');
    END IF;

    AS_SALES_LEAD_ASSIGN_PVT.CALL_WF_TO_ASSIGN(
          P_Api_Version_Number         => l_api_version_number,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Sales_Lead_Id              => P_Sales_Lead_Id,
          -- P_assigned_resource_id       => P_assigned_resource_id,
          P_assigned_resource_id       => NULL,
          X_Return_Status              => X_Return_Status,
          X_Msg_Count                  => X_Msg_Count,
          X_Msg_Data                   => X_Msg_Data
    );

    -- Check return status from the above procedure call
    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body
    --
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'Pub: ' || l_api_name || ' End');
    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                 || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
END CALL_WF_TO_ASSIGN;


PROCEDURE Build_Lead_Sales_Team(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id         IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Salesgroup_id          IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id          IN   NUMBER,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Build_Lead_Sales_Team';
    l_api_version_number      CONSTANT NUMBER   := 2.0;
    l_request_id              NUMBER;

BEGIN
      SAVEPOINT BUILD_LEAD_SALES_TEAM_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Build_Lead_Sales_Team
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PUB: Call PVT.Build_Lead_Sales_Team');
      END IF;

      AS_SALES_LEAD_ASSIGN_PVT.Build_Lead_Sales_Team(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Salesgroup_Id              => P_Salesgroup_Id,
            P_Sales_Lead_Id              => P_Sales_Lead_Id,
            X_Request_Id                 => l_request_id,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
          || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Build_Lead_Sales_Team;

PROCEDURE Rebuild_Lead_Sales_Team(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id         IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Salesgroup_id          IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id          IN   NUMBER,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Rebuild_Lead_Sales_Team';
    l_api_version_number     CONSTANT NUMBER   := 2.0;
    l_request_id             NUMBER;

BEGIN
      SAVEPOINT REBUILD_LEAD_SALES_TEAM_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Rebuild_Lead_Sales_Team
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PUB: Call PVT.Rebuild_Lead_Sales_Team');
      END IF;

      AS_SALES_LEAD_ASSIGN_PVT.Rebuild_Lead_Sales_Team(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Salesgroup_Id              => P_Salesgroup_Id,
            P_Sales_Lead_Id              => P_Sales_Lead_Id,
            X_Request_Id                 => l_request_id,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
          || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Rebuild_Lead_Sales_Team;


PROCEDURE Run_Lead_Engines(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id         IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Salesgroup_id          IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id          IN   NUMBER,
    X_Sales_Team_Flag        OUT NOCOPY VARCHAR2,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Run_Lead_Engines';
    l_api_version_number     CONSTANT NUMBER   := 2.0;
    l_Lead_Engines_Out_Rec   Lead_Engines_Out_Rec_Type;

BEGIN
      SAVEPOINT RUN_LEAD_ENGINES_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Run_Lead_Engines
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PUB: Call PVT.Run_Lead_Engines');
      END IF;

      AS_SALES_LEAD_ENGINE_PVT.Run_Lead_Engines(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Salesgroup_Id              => P_Salesgroup_Id,
            P_Sales_Lead_Id              => P_Sales_Lead_Id,
            -- ckapoor Phase 2 filtering project 11.5.10   IS THIS OK????
    	    --P_Is_Create_Mode	      	 => 'N',

            X_Lead_Engines_Out_Rec       => l_Lead_Engines_Out_Rec,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      x_sales_team_flag := l_Lead_Engines_Out_Rec.sales_team_flag;

      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
          || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Run_Lead_Engines;


PROCEDURE Run_Lead_Engines(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id         IN   NUMBER       := FND_API.G_MISS_NUM,
    P_identity_salesforce_id IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Salesgroup_id          IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id          IN   NUMBER,
    X_Lead_Engines_Out_Rec   OUT NOCOPY  LEAD_ENGINES_OUT_Rec_Type,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    )
 IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Run_Lead_Engines';
    l_api_version_number     CONSTANT NUMBER   := 2.0;

BEGIN
      SAVEPOINT RUN_LEAD_ENGINES_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Run_Lead_Engines
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PUB: Call PVT.Run_Lead_Engines');
      END IF;

      AS_SALES_LEAD_ENGINE_PVT.Run_Lead_Engines(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Salesgroup_Id              => P_Salesgroup_Id,
            P_Sales_Lead_Id              => P_Sales_Lead_Id,
            -- ckapoor Phase 2 filtering project 11.5.10
    	   -- P_Is_Create_Mode	      	 => 'N',

            X_Lead_Engines_Out_Rec       => X_Lead_Engines_Out_Rec,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
          || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Run_Lead_Engines;

PROCEDURE Start_Partner_Matching(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id  IN  NUMBER,
    P_Salesgroup_Id           IN  NUMBER,
    P_Lead_id                 IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2)
 IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Start_Partner_Matching';
    l_api_version_number     CONSTANT NUMBER   := 2.0;

BEGIN
      SAVEPOINT START_PARTNER_MATCHING_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' Start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Run_Lead_Engines
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PUB: Call PVT.Run_Lead_Engines');
      END IF;

      PV_BG_PARTNER_MATCHING_PUB.Start_Partner_Matching(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Salesgroup_Id              => P_Salesgroup_Id,
            P_Lead_Id                    => P_Lead_Id,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Pub: ' || l_api_name || ' End');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
          || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Start_Partner_Matching;

--
--   API Name:  Route_Lead_To_Marketing
--
PROCEDURE Route_Lead_To_Marketing(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id  IN  NUMBER,
    P_Sales_Lead_id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )

 IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Route_Lead_To_Marketing';
    l_api_version_number     CONSTANT NUMBER   := 2.0;
    l_Sales_Team_Rec         AS_ACCESS_PUB.Sales_Team_Rec_Type := AS_ACCESS_PUB.G_MISS_SALES_TEAM_REC;
    l_access_profile_rec     AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_sales_lead_profile_tbl AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL;
    l_sales_lead_rec         AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC;

    l_assign_sales_group_id  NUMBER;
    l_assign_to_person_id    NUMBER;
    l_assign_to_salesforce_id         NUMBER;
    l_salesforce_id          NUMBER;
    l_owner_id               NUMBER;
    l_person_id              NUMBER;
    l_customer_id            NUMBER;
    l_address_id             NUMBER;
    l_access_id              NUMBER;
    l_group_id               NUMBER;
    l_last_update_date       DATE;
    l_sales_lead_log_id      NUMBER;

    l_status_code            as_sales_leads.status_code%type;
    l_reject_reason_code     as_sales_leads.reject_reason_code%type;
    l_qualified_flag         VARCHAR2(1);
    l_lead_rank_id           NUMBER;

    -- Bug 2822580, SOLIN, 03/07/2003
    -- The following variables are for as_territory_accesses
    l_ta_access_id_tbl       JTF_NUMBER_TABLE;
    l_ta_terr_id_tbl         JTF_NUMBER_TABLE;
    l_owner_exists_flag      VARCHAR2(1);

    -- Get access_id, terr_id for the records that come from LEAD territory.
    -- Delete these records before new resource records are created in
    -- AS_ACCESSES_ALL table.
    CURSOR C_Get_Acc_Terr(c_sales_lead_id NUMBER) IS
      SELECT ACC.ACCESS_ID, TERRACC.TERRITORY_ID
      FROM AS_ACCESSES_ALL ACC, AS_TERRITORY_ACCESSES TERRACC
      WHERE  ACC.FREEZE_FLAG = 'N'
      AND    ACC.SALES_LEAD_ID = c_sales_lead_id
      AND    ACC.ACCESS_ID = TERRACC.ACCESS_ID;
    -- Bug 2822580, SOLIN, 03/07/2003, end

-- bugfix# 2770000
/*
CURSOR get_sales_lead_owner (c_sales_lead_id NUMBER) IS
    SELECT asl.ASSIGN_TO_SALESFORCE_ID
    FROM   AS_SALES_LEADS asl
    WHERE  asl.sales_lead_id = c_sales_lead_id;
*/

CURSOR get_person_id_csr (c_resource_id NUMBER) IS
      SELECT js.source_id
      FROM JTF_RS_RESOURCE_EXTNS js
      WHERE js.resource_id = c_resource_id;

CURSOR get_sales_lead_csr (c_sales_lead_id NUMBER) IS
    SELECT asl.customer_id, asl.address_id, asl.status_code,
           asl.reject_reason_code, asl.assign_to_salesforce_id,
           asl.qualified_flag, asl.lead_rank_id
    FROM   AS_SALES_LEADS asl
    WHERE  asl.sales_lead_id = c_sales_lead_id;

CURSOR c_get_group_id (c_resource_id NUMBER, c_rs_group_member VARCHAR2,
                       c_sales VARCHAR2, c_telesales VARCHAR2,
                       c_fieldsales VARCHAR2, c_prm VARCHAR2, c_y VARCHAR2) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = c_rs_group_member --'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code in (c_sales, c_telesales, c_fieldsales, c_prm) --'SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> c_y --'Y'
      AND rrel.delete_flag <> c_y --'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = c_sales --'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    -- Check whether owner exists or not
    CURSOR c_check_owner_exists(c_sales_lead_id NUMBER) IS
      SELECT 'Y'
      FROM as_accesses_all acc
      WHERE acc.sales_lead_id = c_sales_lead_id
      AND acc.owner_flag = 'Y';

    -- Check whether the resource is in the sales team or not.
    -- Group_id is not required to check here because no group_id is always
    -- from c_get_group_id cursor.
    CURSOR c_check_sales_team(c_resource_id NUMBER, c_sales_lead_id NUMBER) IS
      SELECT acc.access_id
      FROM  as_accesses_all acc
      WHERE acc.salesforce_id = c_resource_id
      AND   acc.sales_lead_id = c_sales_lead_id;
BEGIN
      SAVEPOINT ROUTE_LEAD_TO_MARKETING_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Pub: ' || l_api_name || ' Start');
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Bug 2822580, SOLIN, 03/07/2003
      OPEN C_Get_Acc_Terr(p_sales_lead_id);
      FETCH C_Get_Acc_Terr BULK COLLECT INTO
          l_ta_access_id_tbl, l_ta_terr_id_tbl;
      CLOSE C_Get_Acc_Terr;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'l_ta_access_id_tbl.count:' || l_ta_access_id_tbl.count);
      END IF;

      IF l_ta_access_id_tbl.count > 0
      THEN
          IF (AS_DEBUG_LOW_ON) THEN
              FOR l_i IN 1..l_ta_access_id_tbl.count
              LOOP
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Delete acc_id:' || l_ta_access_id_tbl(l_i)
                      || ' terr_id:' || l_ta_terr_id_tbl(l_i));
              END LOOP;
          END IF;

          FORALL l_i IN 1..l_ta_access_id_tbl.count
              DELETE FROM AS_ACCESSES_ALL
              WHERE ACCESS_ID = l_ta_access_id_tbl(l_i);

          FORALL l_i IN 1..l_ta_terr_id_tbl.count
              DELETE FROM AS_TERRITORY_ACCESSES
              WHERE ACCESS_ID = l_ta_access_id_tbl(l_i)
              AND   TERRITORY_ID = l_ta_terr_id_tbl(l_i);
      END IF;

      -- Delete non-frozen resources who are not from territory.
      DELETE FROM as_accesses_all acc
      WHERE acc.sales_lead_id = p_sales_lead_id
      AND acc.freeze_flag = 'N'
      --AND acc.salesforce_id <> p_identity_salesforce_id
      AND NOT EXISTS (
          SELECT 1
          FROM as_territory_accesses terracc
          WHERE terracc.access_id = acc.access_id);
      -- Bug 2822580, SOLIN, 03/07/2003, end


-- bugfix# 2770000, do not look for owner in the lead record. Validation is done before that.
/*
      -- Checking if the owner is provided from UI
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Opening cursor get_sales_lead_owner');
      END IF;

      OPEN  get_sales_lead_owner(P_Sales_Lead_id);
      FETCH get_sales_lead_owner
      INTO  l_owner_id;
      CLOSE get_sales_lead_owner;

      -- If owner is found, use the owner given and ignore the rest of the processing.
      IF (l_owner_id IS NOT NULL) THEN
          return;
      END IF;
*/

      OPEN  get_sales_lead_csr(p_sales_lead_id);
      FETCH get_sales_lead_csr
      INTO  l_customer_id, l_address_id, l_status_code,
            l_reject_reason_code, l_salesforce_id, l_qualified_flag,
            l_lead_rank_id;
      CLOSE get_sales_lead_csr;

      -- Check owner again here because the above delete may
      -- remove owner in as_accesses_all
      l_owner_exists_flag := 'N';
      OPEN c_check_owner_exists(p_sales_lead_id);
      FETCH c_check_owner_exists INTO l_owner_exists_flag;
      CLOSE c_check_owner_exists;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'assign to=' || l_salesforce_id);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'reject reason=' || l_reject_reason_code);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'owner exist?' || l_owner_exists_flag);
      END IF;

      -- Bug 2858785
      -- Update address_id when user change address.
      UPDATE as_accesses_all
      SET address_id = l_address_id
      WHERE sales_lead_id = p_sales_lead_id;
      -- end Bug 2858785

      IF l_salesforce_id IS NULL OR
         l_reject_reason_code IS NOT NULL OR
         l_owner_exists_flag = 'N'
      THEN
          -- Calling Private package to get immature lead owner
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'PUB: Call AS_SALES_LEAD_OWNER.Get_Immatured_Lead_Owner');
          END IF;

          AS_SALES_LEAD_OWNER.Get_Immatured_Lead_Owner(
                P_Api_Version                => 2.0,
                P_Init_Msg_List              => FND_API.G_FALSE,
                P_Commit                     => FND_API.G_FALSE,
                P_Validation_Level           => P_Validation_Level,
                P_Sales_Lead_id              => P_Sales_Lead_id,
                X_salesforce_id              => L_Salesforce_id,
                X_Return_Status              => x_return_status,
                X_Msg_Count                  => x_msg_count,
                X_Msg_Data                   => x_msg_data);

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              raise FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF (l_salesforce_id IS NULL)
          THEN
              l_salesforce_id := fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
          END IF;

          IF (l_salesforce_id IS NOT NULL)
          THEN
              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Marketing Owner id=' || l_salesforce_id);
              END IF;

              OPEN c_check_sales_team (l_salesforce_id, p_sales_lead_id);
              FETCH c_check_sales_team INTO l_access_id;
              CLOSE c_check_sales_team;

              -- Find the sales group of the person being added
              -- bugfix # 2538741
              OPEN c_get_group_id (l_salesforce_id, 'RS_GROUP_MEMBER',
                  'SALES', 'TELESALES', 'FIELDSALES', 'PRM', 'Y');
              FETCH c_get_group_id INTO l_group_id;
              CLOSE c_get_group_id;

              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'group_id=' || l_group_id);
              END IF;

              OPEN  get_person_id_csr(l_salesforce_id);
              FETCH get_person_id_csr
              INTO  l_person_id;
              CLOSE get_person_id_csr;

              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'person_id=' || l_person_id);
              END IF;

              IF l_access_id IS NULL
              THEN
                  --
                  -- Call Create_Salesteam
                  --

                  l_Sales_Team_Rec.person_id := l_person_id;
                  l_sales_team_rec.sales_group_id := NULL;
                  l_Sales_Team_Rec.salesforce_id := l_salesforce_id;
                  -- ckapoor 052902 Bug that owner is not set in as_accesses_all
                  -- Also created by TAP flag explicitly marked as 'N'
                  l_Sales_Team_Rec.owner_flag := 'Y';
                  l_Sales_Team_Rec.created_by_TAP_flag := 'N';
                  l_Sales_Team_Rec.team_leader_flag := 'Y';
                  l_Sales_Team_Rec.reassign_flag := 'N';
                  -- bugfix# 2795679, keep the owner in sales team so that the
                  -- owner is not removed by TAP
                  l_Sales_Team_Rec.freeze_flag := 'Y';
                  l_Sales_Team_Rec.customer_id := l_customer_id;
                  l_Sales_Team_Rec.address_id := l_address_id;
                  l_Sales_Team_Rec.lead_id := NULL;
                  l_Sales_Team_Rec.sales_lead_id := p_sales_lead_id;
                  l_Sales_Team_Rec.sales_group_id := l_group_id;

                  l_access_profile_rec.cust_access_profile_value :=
                      fnd_profile.value( 'AS_CUST_ACCESS');

                  AS_ACCESS_PUB.Create_SalesTeam (
                       p_api_version_number  => 2.0
                      ,p_init_msg_list => FND_API.G_FALSE
                      ,p_commit => FND_API.G_FALSE
                      ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                      ,p_access_profile_rec => l_access_profile_rec
                      ,p_check_access_flag => 'N'
                      ,p_admin_flag => 'N'
                      ,p_admin_group_id => P_Admin_Group_Id
                      ,p_identity_salesforce_id => P_Identity_Salesforce_Id
                      ,p_sales_team_rec => l_Sales_Team_Rec
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data
                      ,x_access_id => l_Access_Id
                    );
              ELSE
                  UPDATE as_accesses_all
                  SET owner_flag = 'Y',
                      sales_group_id = l_group_id
                  WHERE access_id = l_access_id;
              END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  raise FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              --
              -- Call Update sales lead
              --

              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Before calling Update Saleslead');
	      END IF;

              -- Call API to create log entry

              AS_SALES_LEADS_LOG_PKG.Insert_Row(
                  px_log_id                 => l_sales_lead_log_id ,
                  p_sales_lead_id           => p_sales_lead_id,
                  p_created_by              => fnd_global.user_id,
                  p_creation_date           => SYSDATE,
                  p_last_updated_by         => fnd_global.user_id,
                  p_last_update_date        => SYSDATE,
                  p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
                  p_request_id              => FND_GLOBAL.Conc_Request_Id,
                  p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
                  p_program_id              => FND_GLOBAL.Conc_Program_Id,
                  p_program_update_date     => SYSDATE,
                  p_status_code             => l_status_code,
                  p_assign_to_person_id     => l_person_id,
                  p_assign_to_salesforce_id => l_salesforce_id,
                  p_reject_reason_code      => l_reject_reason_code,
                  p_assign_sales_group_id   => l_group_id,
                  p_lead_rank_id            => l_lead_rank_id,
                  p_qualified_flag          => l_qualified_flag,
                  p_category                => NULL);

              -- Call table handler directly, not calling Update_Sales_Lead,
              -- in case current user doesn't have update privilege.
              AS_SALES_LEADS_PKG.Sales_Lead_Update_Row(
                  p_SALES_LEAD_ID  => p_SALES_LEAD_ID,
                  p_LAST_UPDATE_DATE  => SYSDATE,
                  p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
                  p_CREATION_DATE  => FND_API.G_MISS_DATE,
                  p_CREATED_BY  => FND_API.G_MISS_NUM,
                  p_LAST_UPDATE_LOGIN  => FND_API.G_MISS_NUM,
                  p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
                  p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
                  p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
                  p_PROGRAM_UPDATE_DATE  => SYSDATE,
                  p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,
                  p_STATUS_CODE => FND_API.G_MISS_CHAR,
                  p_CUSTOMER_ID  => FND_API.G_MISS_NUM,
                  p_ADDRESS_ID  => FND_API.G_MISS_NUM,
                  p_SOURCE_PROMOTION_ID  => FND_API.G_MISS_NUM,
                  p_INITIATING_CONTACT_ID => FND_API.G_MISS_NUM,
                  p_ORIG_SYSTEM_REFERENCE => FND_API.G_MISS_CHAR,
                  p_CONTACT_ROLE_CODE  => FND_API.G_MISS_CHAR,
                  p_CHANNEL_CODE  => FND_API.G_MISS_CHAR,
                  p_BUDGET_AMOUNT  => FND_API.G_MISS_NUM,
                  p_CURRENCY_CODE  => FND_API.G_MISS_CHAR,
                  p_DECISION_TIMEFRAME_CODE => FND_API.G_MISS_CHAR,
                  p_CLOSE_REASON  => FND_API.G_MISS_CHAR,
                  p_LEAD_RANK_ID  => FND_API.G_MISS_NUM,
                  p_LEAD_RANK_CODE  => FND_API.G_MISS_CHAR,
                  p_PARENT_PROJECT  => FND_API.G_MISS_CHAR,
                  p_DESCRIPTION  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE_CATEGORY  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE1  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE2  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE3  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE4  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE5  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE6  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE7  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE8  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE9  => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE10 => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE11 => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE12 => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE13 => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE14 => FND_API.G_MISS_CHAR,
                  p_ATTRIBUTE15 => FND_API.G_MISS_CHAR,
                  p_ASSIGN_TO_PERSON_ID  => l_person_id,
                  p_ASSIGN_TO_SALESFORCE_ID => l_salesforce_id,
                  p_ASSIGN_SALES_GROUP_ID => l_group_id,
                  p_ASSIGN_DATE  => SYSDATE,
                  p_BUDGET_STATUS_CODE  => FND_API.G_MISS_CHAR,
                  p_ACCEPT_FLAG  => 'N',
                  p_VEHICLE_RESPONSE_CODE => FND_API.G_MISS_CHAR,
                  p_TOTAL_SCORE  => FND_API.G_MISS_NUM,
                  p_SCORECARD_ID  => FND_API.G_MISS_NUM,
                  p_KEEP_FLAG  => FND_API.G_MISS_CHAR,
                  p_URGENT_FLAG  => FND_API.G_MISS_CHAR,
                  p_IMPORT_FLAG  => FND_API.G_MISS_CHAR,
                  p_REJECT_REASON_CODE  => NULL, --l_reject_reason_code,
                  p_DELETED_FLAG => FND_API.G_MISS_CHAR,
                  p_OFFER_ID  =>  FND_API.G_MISS_NUM,
                  p_QUALIFIED_FLAG => FND_API.G_MISS_CHAR,
                  p_ORIG_SYSTEM_CODE => FND_API.G_MISS_CHAR,
                  -- p_SECURITY_GROUP_ID    => FND_API.G_MISS_NUM,
                  p_INC_PARTNER_PARTY_ID => FND_API.G_MISS_NUM,
                  p_INC_PARTNER_RESOURCE_ID => FND_API.G_MISS_NUM,
                  p_PRM_EXEC_SPONSOR_FLAG   => FND_API.G_MISS_CHAR,
                  p_PRM_PRJ_LEAD_IN_PLACE_FLAG => FND_API.G_MISS_CHAR,
                  p_PRM_SALES_LEAD_TYPE     => FND_API.G_MISS_CHAR,
                  p_PRM_IND_CLASSIFICATION_CODE => FND_API.G_MISS_CHAR,
                  p_PRM_ASSIGNMENT_TYPE => FND_API.G_MISS_CHAR,
                  p_AUTO_ASSIGNMENT_TYPE => FND_API.G_MISS_CHAR,
                  p_PRIMARY_CONTACT_PARTY_ID => FND_API.G_MISS_NUM,
                  p_PRIMARY_CNT_PERSON_PARTY_ID => FND_API.G_MISS_NUM,
                  p_PRIMARY_CONTACT_PHONE_ID => FND_API.G_MISS_NUM,
                  p_REFERRED_BY => FND_API.G_MISS_NUM,
                  p_REFERRAL_TYPE => FND_API.G_MISS_CHAR,
                  p_REFERRAL_STATUS => FND_API.G_MISS_CHAR,
                  p_REF_DECLINE_REASON => FND_API.G_MISS_CHAR,
                  p_REF_COMM_LTR_STATUS => FND_API.G_MISS_CHAR,
                  p_REF_ORDER_NUMBER => FND_API.G_MISS_NUM,
                  p_REF_ORDER_AMT => FND_API.G_MISS_NUM,
                  p_REF_COMM_AMT => FND_API.G_MISS_NUM,
                  -- bug No.2341515, 2368075
                  p_LEAD_DATE => FND_API.G_MISS_DATE,
                  p_SOURCE_SYSTEM => FND_API.G_MISS_CHAR,
                  p_COUNTRY => FND_API.G_MISS_CHAR,
                  -- 11.5.9

                  p_TOTAL_AMOUNT => FND_API.G_MISS_NUM,
                  p_EXPIRATION_DATE => FND_API.G_MISS_DATE,
                  p_LEAD_RANK_IND => FND_API.G_MISS_CHAR,
                  p_LEAD_ENGINE_RUN_DATE => FND_API.G_MISS_DATE,
                  p_CURRENT_REROUTES => FND_API.G_MISS_NUM,

                  -- new columns for appsperf CRMAP denorm project bug 2928041
                  p_STATUS_OPEN_FLAG =>  FND_API.G_MISS_CHAR,
                  p_LEAD_RANK_SCORE => FND_API.G_MISS_NUM

                  -- 11.5.10 new columns ckapoor


                , p_MARKETING_SCORE	=> FND_API.G_MISS_NUM
		, p_INTERACTION_SCORE   => FND_API.G_MISS_NUM
		, p_SOURCE_PRIMARY_REFERENCE	=> FND_API.G_MISS_CHAR
		, p_SOURCE_SECONDARY_REFERENCE	=> FND_API.G_MISS_CHAR
		, p_SALES_METHODOLOGY_ID	=> FND_API.G_MISS_NUM
		, p_SALES_STAGE_ID		=> FND_API.G_MISS_NUM




              );

          END IF; -- IF (X_salesforce_id IS NOT NULL) THEN
      END IF; -- if there's no owner

      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Pub: ' || l_api_name || ' End');
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Route_Lead_To_Marketing;

PROCEDURE Lead_Process_After_Create (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    p_Admin_Flag              IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
 IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Lead_Process_After_Create';
    l_api_version_number     CONSTANT NUMBER   := 2.0;

BEGIN
      SAVEPOINT LEAD_PROCESS_AFTER_CREATE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Pub: ' || l_api_name || ' Start');
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Run_Lead_Engines
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'PUB: Call PVT.Lead_Process_After_Create');
      END IF;

      AS_SALES_LEAD_ENGINE_PVT.Lead_Process_After_Create(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            p_Admin_Flag                 => p_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Salesgroup_Id              => P_Salesgroup_Id,
            P_Sales_Lead_Id              => P_Sales_Lead_Id,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Pub: ' || l_api_name || ' End');
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      IF x_return_status = 'W'
      THEN
          FND_MSG_PUB.Count_And_Get
          (  p_encoded        =>   FND_API.G_FALSE,
             p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );
      ELSE
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );
      END IF;

      EXCEPTION

          WHEN AS_SALES_LEADS_PUB.Filter_Exception THEN
	               RAISE AS_SALES_LEADS_PUB.Filter_Exception;

          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Lead_Process_After_Create;


PROCEDURE Lead_Process_After_Update (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    p_Admin_Flag              IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
 IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Lead_Process_After_Update';
    l_api_version_number     CONSTANT NUMBER   := 2.0;

BEGIN
      SAVEPOINT LEAD_PROCESS_AFTER_UPDATE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Pub: ' || l_api_name || ' Start');
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Run_Lead_Engines
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'PUB: Call PVT.Lead_Process_After_Update');
      END IF;

      AS_SALES_LEAD_ENGINE_PVT.Lead_Process_After_Update(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            p_Admin_Flag                 => p_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Salesgroup_Id              => P_Salesgroup_Id,
            P_Sales_Lead_Id              => P_Sales_Lead_Id,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Pub: ' || l_api_name || ' End');
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      IF x_return_status = 'W'
      THEN
          FND_MSG_PUB.Count_And_Get
          (  p_encoded        =>   FND_API.G_FALSE,
             p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );
      ELSE
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data
          );
      END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Lead_Process_After_Update;


End AS_SALES_LEADS_PUB;

/
