--------------------------------------------------------
--  DDL for Package Body AS_LINK_LEAD_OPP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LINK_LEAD_OPP_PUB" as
/* $Header: asxpllob.pls 120.1 2005/06/14 01:31:13 appldev  $ */
-- Start of Comments
-- Package name     : AS_LINK_LEAD_OPP_PUB
-- Purpose          : Link/Copy Leads to Opportunities
-- NOTE             :
-- History          :
--     06/25/2002 FFANG  Created.
--     08/27/2003 VEKAMATH Fix for Bug#3118674
--			   Changed the value being set to the variable
--			   l_api_name
--
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_LINK_LEAD_OPP_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxpllob.pls';
G_CREATE   NUMBER :=2;
G_UPDATE   NUMBER :=1;


--   API Name:  Get_Potential_Opportunity
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
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    X_OPPORTUNITY_TBL            OUT NOCOPY AS_OPPORTUNITY_PUB.HEADER_TBL_TYPE,
    X_OPP_LINES_tbl              OUT NOCOPY AS_OPPORTUNITY_PUB.LINE_TBL_TYPE

    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Get_Potential_Opportunity';
    l_api_version_number   CONSTANT NUMBER   := 2.0;
    l_debug  BOOLEAN;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.llop.Get_Potential_Opportunity';
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
      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Pub: ' || l_api_name || ' Start');
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling private API
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PUB: Call PVT.Get_Potential_Opportunity');
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
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Pub: ' || l_api_name || ' End');
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Get_Potential_Opportunity;


--   API Name:  Copy_Lead_To_Opportunity

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
    X_Return_Status             OUT NOCOPY VARCHAR2,
    X_Msg_Count                 OUT NOCOPY NUMBER,
    X_Msg_Data                  OUT NOCOPY VARCHAR2
    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Copy_Lead_To_Opportunity';
    l_api_version_number   CONSTANT NUMBER   := 2.0;

    l_call_pre_uhk   BOOLEAN;
    l_call_post_uhk  BOOLEAN;
    l_debug  BOOLEAN;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.llop.Copy_Lead_To_Opportunity';

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
      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Pub: ' || l_api_name || ' Start');
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Pre User Hook
      --
      l_call_pre_uhk := JTF_USR_HKS.Ok_to_execute('AS_LINK_LEAD_OPP_PUB',
                                                  'Copy_Lead_To_Opportunity',
                                                  'B','C');

      IF l_call_pre_uhk THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Call pre user hook is true');
        END IF;
          AS_LINK_LEAD_OPP_UHK.Copy_Lead_To_Opp_Pre (
              p_api_version_number    =>  2.0,
              p_init_msg_list         =>  FND_API.G_FALSE,
              p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
              p_commit                =>  FND_API.G_FALSE,
              p_sales_lead_id         =>  p_sales_lead_id,
              p_opportunity_id        =>  p_opportunity_id,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data);
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- API body
      --
      -- Calling private API
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PUB: Call PVT.Copy_Lead_To_Opportunity');
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

      --
      -- Post User Hook
      --
      l_call_post_uhk := JTF_USR_HKS.Ok_to_execute('AS_LINK_LEAD_OPP_PUB',
                                                  'Copy_Lead_To_Opportunity',
                                                  'A','C');

      IF l_call_post_uhk THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Call post user hook is true');
        END IF;
          AS_LINK_LEAD_OPP_UHK.Copy_Lead_To_Opp_Post (
              p_api_version_number    =>  2.0,
              p_init_msg_list         =>  FND_API.G_FALSE,
              p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
              p_commit                =>  FND_API.G_FALSE,
              p_sales_lead_id         =>  p_sales_lead_id,
              p_opportunity_id        =>  p_opportunity_id,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data);
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Pub: ' || l_api_name || ' End');
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
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
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                          := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPPORTUNITY_ID             IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
 IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Link_Lead_To_Opportunity';
    l_api_version_number   CONSTANT NUMBER   := 2.0;

    l_call_pre_uhk   BOOLEAN;
    l_call_post_uhk  BOOLEAN;
    l_debug  BOOLEAN;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.llop.Link_Lead_To_Opportunity';

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
      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Pub: ' || l_api_name || ' Start');
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Pre User Hook
      --
      l_call_pre_uhk := JTF_USR_HKS.Ok_to_execute('AS_LINK_LEAD_OPP_PUB',
                                                  'Link_Lead_To_Opportunity',
                                                  'B','C');

      IF l_call_pre_uhk THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Call pre user hook is true');
        END IF;
          AS_LINK_LEAD_OPP_UHK.Link_Lead_To_Opp_Pre (
              p_api_version_number    =>  2.0,
              p_init_msg_list         =>  FND_API.G_FALSE,
              p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
              p_commit                =>  FND_API.G_FALSE,
              p_sales_lead_id         =>  p_sales_lead_id,
              p_opportunity_id        =>  p_opportunity_id,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data);
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- API body
      --
      -- Calling private API
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PUB: Call PVT.Link_Lead_To_Opportunity');
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

      --
      -- Post User Hook
      --
      l_call_post_uhk := JTF_USR_HKS.Ok_to_execute('AS_LINK_LEAD_OPP_PUB',
                                                  'Link_Lead_To_Opportunity',
                                                  'A','C');

      IF l_call_post_uhk THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Call post user hook is true');
        END IF;
          AS_LINK_LEAD_OPP_UHK.Link_Lead_To_Opp_Post (
              p_api_version_number    =>  2.0,
              p_init_msg_list         =>  FND_API.G_FALSE,
              p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
              p_commit                =>  FND_API.G_FALSE,
              p_sales_lead_id         =>  p_sales_lead_id,
              p_opportunity_id        =>  p_opportunity_id,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data);
      END IF;

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
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Pub: ' || l_api_name || ' End');
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Link_Lead_To_Opportunity;


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
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    X_OPPORTUNITY_ID             OUT NOCOPY NUMBER
    )
 IS
--fix for bug#3118674
/*
Changed the value being set to the variable l_api_name from
Create_Opportunity_For_Lead to Create_Opp_For_Lead.
This was done because the rollback statement in the Handle_Exception API
was using this value and appending it with PUB. Because of which the
rollback statement was throwing and error as the length of the save point
was more than 30.
So set the l_api_name to be same as the savepoint with out the "_PUB"
*/


    l_api_name         CONSTANT VARCHAR2(30) := 'Create_Opp_For_Lead';
    l_api_version_number   CONSTANT NUMBER   := 2.0;

    l_call_pre_uhk   BOOLEAN;
    l_call_post_uhk  BOOLEAN;
    l_debug  BOOLEAN;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.llop.Create_Opportunity_For_Lead';

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
      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Pub: ' || l_api_name || ' Start');
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Pre User Hook
      --
      l_call_pre_uhk := JTF_USR_HKS.Ok_to_execute('AS_LINK_LEAD_OPP_PUB',
                                                  'Create_Opportunity_For_Lead',
                                                  'B','C');

      IF l_call_pre_uhk THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Call pre user hook is true');
        END IF;
          AS_LINK_LEAD_OPP_UHK.Create_Opp_For_Lead_Pre (
              p_api_version_number    =>  2.0,
              p_init_msg_list         =>  FND_API.G_FALSE,
              p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
              p_commit                =>  FND_API.G_FALSE,
              p_sales_lead_id         =>  p_sales_lead_id,
              p_opportunity_id        =>  null,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data);
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- API body
      --
      -- Calling private API
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PUB: Calling PVT.Create_Opportunity_For_Lead');
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


      --
      -- Post User Hook
      --
      l_call_post_uhk := JTF_USR_HKS.Ok_to_execute('AS_LINK_LEAD_OPP_PUB',
                                                  'Create_Opportunity_For_Lead',
                                                  'A','C');

      IF l_call_post_uhk THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Call post user hook is true');
        END IF;
          AS_LINK_LEAD_OPP_UHK.Create_Opp_For_Lead_Post (
              p_api_version_number    =>  2.0,
              p_init_msg_list         =>  FND_API.G_FALSE,
              p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
              p_commit                =>  FND_API.G_FALSE,
              p_sales_lead_id         =>  p_sales_lead_id,
              p_opportunity_id        =>  x_opportunity_id,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data);
      END IF;

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
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Pub: ' || l_api_name || ' End');
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_Opportunity_For_Lead;



End AS_LINK_LEAD_OPP_PUB;

/
