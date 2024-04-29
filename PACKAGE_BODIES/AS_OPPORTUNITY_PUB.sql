--------------------------------------------------------
--  DDL for Package Body AS_OPPORTUNITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPPORTUNITY_PUB" as
/* $Header: asxpoppb.pls 120.3 2005/09/06 17:58:14 appldev ship $ */
-- Start of Comments
-- Package name     : AS_OPPORTUNITY_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME 	CONSTANT VARCHAR2(30)	:= 'AS_OPPORTUNITY_PUB';
G_FILE_NAME 	CONSTANT VARCHAR2(12) 	:= 'asxpoppb.pls';

-- Start of Comments
--
--    API name    : Create_Opp_header
--    Type        : Public.
--
-- End of Comments

PROCEDURE Create_Opp_Header
(   p_api_version_number            IN    NUMBER,
    p_init_msg_list                 IN    VARCHAR2  	DEFAULT FND_API.G_FALSE,
    p_commit                        IN    VARCHAR2   	DEFAULT  FND_API.G_FALSE,
    p_validation_level      	    IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_header_rec                    IN    HEADER_REC_TYPE   DEFAULT  G_MISS_HEADER_REC,
    p_check_access_flag     	    IN 	  VARCHAR2,
    p_admin_flag	    	    IN 	  VARCHAR2,
    p_admin_group_id	    	    IN	  NUMBER,
    p_identity_salesforce_id 	    IN	  NUMBER,
    p_salesgroup_id		    IN    NUMBER        DEFAULT  NULL,
    p_partner_cont_party_id	    IN    NUMBER,
    p_profile_tbl	    	    IN	  AS_UTILITY_PUB.Profile_Tbl_Type
					  DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status                 OUT NOCOPY   VARCHAR2,
    x_msg_count                     OUT NOCOPY   NUMBER,
    x_msg_data                      OUT NOCOPY   VARCHAR2,
    x_lead_id                       OUT NOCOPY   NUMBER
)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_opp_header';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_header_rec		  HEADER_REC_TYPE   := p_header_rec;
l_lead_id 		  NUMBER;
l_warning_msg		  VARCHAR2(2000)     := '';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Create_Opp_Header';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_HEADER_PUB;

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
      IF l_debug THEN
      	IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
					'Public API: ' || l_api_name || ' start');

      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
					'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      	END IF;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Header_Values_To_Ids');

      END IF;

      -- Convert the values to ids
      --
      Convert_Header_Values_To_Ids (
            p_Header_rec       =>  p_Header_rec,
            x_pvt_Header_rec   =>  l_pvt_Header_rec
      );

     *****/

    -- Calling Private package: Create_OPP_HEADER
    -- Hint: Primary key needs to be returned
      AS_OPP_header_PVT.Create_opp_header(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => P_Validation_Level ,
      P_Check_Access_Flag          => p_check_access_flag,
      P_Admin_Flag                 => P_Admin_Flag ,
      P_Admin_Group_Id             => P_Admin_Group_Id,
      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      p_salesgroup_id		   => p_salesgroup_id,
      P_Profile_Tbl                => P_Profile_tbl,
      P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      P_Header_Rec  		   => l_Header_Rec ,
      X_LEAD_ID     		   => x_LEAD_ID,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	l_warning_msg := X_Msg_Data;
      END IF;

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- USER HOOK standard : vertical industry post-processing section
      IF(JTF_USR_HKS.Ok_to_execute('AS_OPPORTUNITY_PUB', 'Create_Opp_Header','A','V'))
      THEN
	  l_Header_Rec.lead_id := x_LEAD_ID;
          l_lead_id	:= x_LEAD_ID;

          AS_OPPORTUNITY_VUHK.Create_opp_header_Post(
      	    P_Api_Version_Number         => 2.0,
      	    P_Init_Msg_List              => FND_API.G_FALSE,
      	    P_Commit                     => p_commit,
      	    P_Validation_Level           => P_Validation_Level ,
      	    P_Check_Access_Flag          => p_check_access_flag,
      	    P_Admin_Flag                 => P_Admin_Flag ,
      	    P_Admin_Group_Id             => P_Admin_Group_Id,
      	    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      	    p_salesgroup_id		   => p_salesgroup_id,
      	    P_Profile_Tbl                => P_Profile_tbl,
      	    P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      	    P_Header_Rec  		   => l_Header_Rec ,
      	    X_LEAD_ID     		   => l_lead_id,
      	    X_Return_Status              => x_return_status,
      	    X_Msg_Count                  => x_msg_count,
      	    X_Msg_Data                   => x_msg_data);

          -- Debug Message
	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		   'Create_opp_header_Post fail');
	      END IF;

 	  END IF;

          -- Check return status from the above procedure call
          IF x_return_status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;


      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;



      -- Standard call to get message count and if count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	X_Msg_Data := l_warning_msg;
      END IF;

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_opp_header;


-- Start of Comments
--
--    API name    : Update_Opp_Header
--    Type        : Public
--    Function    : Update Opportunity Information
--

PROCEDURE Update_Opp_header
(   p_api_version_number    	IN     NUMBER,
    p_init_msg_list         	IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                	IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      	IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_header_rec               	IN     AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag     	IN     VARCHAR2,
    p_admin_flag	    	IN     VARCHAR2,
    p_admin_group_id	    	IN     NUMBER,
    p_identity_salesforce_id 	IN     NUMBER,
    p_partner_cont_party_id	IN     NUMBER,
    p_profile_tbl	    	IN     AS_UTILITY_PUB.Profile_Tbl_Type
				       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status         	OUT NOCOPY    VARCHAR2,
    x_msg_count             	OUT NOCOPY    NUMBER,
    x_msg_data              	OUT NOCOPY    VARCHAR2,
    x_lead_id               	OUT NOCOPY    NUMBER)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_opp_header';
l_api_version_number      CONSTANT NUMBER   := 2.0;
--l_pvt_Header_rec  AS_OPP_HEADER_PVT.Header_Rec_Type;
l_header_rec		  HEADER_REC_TYPE   := p_header_rec;
l_warning_msg		  VARCHAR2(2000)     := '';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Opp_header';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OPP_HEADER_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Header_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Header_Values_To_Ids (
            p_Header_rec       =>  p_Header_rec,
            x_pvt_Header_rec   =>  l_pvt_Header_rec
      );
      *****/

      -- USER HOOK standard : vertical industry pre-processing section
      IF(JTF_USR_HKS.Ok_to_execute('AS_OPPORTUNITY_PUB', 'Update_Opp_Header','B','V'))
      THEN
          AS_OPPORTUNITY_VUHK.Update_opp_header_Pre(
    	    P_Api_Version_Number         => 2.0,
    	    P_Init_Msg_List              => FND_API.G_FALSE,
    	    P_Commit                     => FND_API.G_FALSE,
    	    P_Validation_Level           => P_Validation_Level,
    	    P_Check_Access_Flag          => p_check_access_flag,
    	    P_Admin_Flag                 => P_Admin_Flag ,
    	    P_Admin_Group_Id             => P_Admin_Group_Id,
    	    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    	    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    	    P_Profile_Tbl                => P_Profile_tbl,
    	    P_Header_Rec  		 => l_Header_Rec ,
    	    X_Return_Status              => x_return_status,
    	    X_Msg_Count                  => x_msg_count,
    	    X_Msg_Data                   => x_msg_data);

          -- Debug Message
	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		   'Update_opp_header_Pre fail');
	      END IF;

 	  END IF;

          -- Check return status from the above procedure call
          IF x_return_status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;

      -- Opp private API call
      AS_OPP_header_PVT.Update_opp_header(
    	P_Api_Version_Number         => 2.0,
    	P_Init_Msg_List              => FND_API.G_FALSE,
    	P_Commit                     => FND_API.G_FALSE,
    	P_Validation_Level           => P_Validation_Level,
    	P_Check_Access_Flag          => p_check_access_flag,
    	P_Admin_Flag                 => P_Admin_Flag ,
    	P_Admin_Group_Id             => P_Admin_Group_Id,
    	P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    	P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    	P_Profile_Tbl                => P_Profile_tbl,
    	P_Header_Rec  		 => l_Header_Rec ,
    	X_Return_Status              => x_return_status,
    	X_Msg_Count                  => x_msg_count,
    	X_Msg_Data                   => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	l_warning_msg := X_Msg_Data;
      END IF;

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- USER HOOK standard : vertical industry post-processing section
      IF(JTF_USR_HKS.Ok_to_execute('AS_OPPORTUNITY_PUB', 'Update_Opp_Header','A','V'))
      THEN
          AS_OPPORTUNITY_VUHK.Update_opp_header_Post(
    	    P_Api_Version_Number         => 2.0,
    	    P_Init_Msg_List              => FND_API.G_FALSE,
    	    P_Commit                     => FND_API.G_FALSE,
    	    P_Validation_Level           => P_Validation_Level,
    	    P_Check_Access_Flag          => p_check_access_flag,
    	    P_Admin_Flag                 => P_Admin_Flag ,
    	    P_Admin_Group_Id             => P_Admin_Group_Id,
    	    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    	    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    	    P_Profile_Tbl                => P_Profile_tbl,
    	    P_Header_Rec  		 => l_Header_Rec ,
    	    X_Return_Status              => x_return_status,
    	    X_Msg_Count                  => x_msg_count,
    	    X_Msg_Data                   => x_msg_data);

          -- Debug Message
	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		   'Update_opp_header_Post fail');
	      END IF;
 	  END IF;

          -- Check return status from the above procedure call
          IF x_return_status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	X_Msg_Data := l_warning_msg;
      END IF;

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_opp_header;


-- Start of Comments
--
--    API name    : Delete_Opp_Header
--    Type        : Public
--    Function    : Delete Opportunity Record
--

PROCEDURE Delete_Opp_Header
(   p_api_version_number    	IN     NUMBER,
    p_init_msg_list         	IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                	IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      	IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_header_rec               	IN     AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag     	IN     VARCHAR2,
    p_admin_flag	    	IN     VARCHAR2,
    p_admin_group_id	    	IN     NUMBER,
    p_identity_salesforce_id 	IN     NUMBER,
    p_partner_cont_party_id	IN     NUMBER,
    p_profile_tbl	    	IN     AS_UTILITY_PUB.Profile_Tbl_Type
				       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status         	OUT NOCOPY    VARCHAR2,
    x_msg_count             	OUT NOCOPY    NUMBER,
    x_msg_data              	OUT NOCOPY    VARCHAR2,
    x_lead_id               	OUT NOCOPY    NUMBER)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_opp_Header';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_header_rec		  Header_Rec_Type := p_header_rec;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Opp_Header';
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_OPP_HEADER_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

       /*****

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Header_Values_To_Ids');

      END IF;

      -- Convert the values to ids
      --
      Convert_Header_Values_To_Ids (
            p_Header_rec       =>  p_Header_rec,
            x_pvt_Header_rec   =>  l_pvt_Header_rec
      );
      *****/

      AS_OPP_header_PVT.Delete_opp_header(
    	P_Api_Version_Number         => 2.0,
    	P_Init_Msg_List              => FND_API.G_FALSE,
    	P_Commit                     => p_commit,
    	P_Validation_Level           => P_Validation_Level,
    	P_Check_Access_Flag          => p_check_access_flag,
    	P_Admin_Flag                 => P_Admin_Flag ,
    	P_Admin_Group_Id             => P_Admin_Group_Id,
    	P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    	P_Partner_Cont_Party_Id	     => p_partner_cont_party_id,
    	P_Profile_Tbl                => P_Profile_tbl,
    	P_Lead_Id  		     => l_Header_Rec.lead_id ,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Delete_Opp_Header;

-- Start of Comments
--
--    API name    : Create_Opp_Lines
--    Type        : Public
--    Function    : Create Opportunity Lines for an Opportunity
--
--
--

PROCEDURE Create_Opp_Lines
(   p_api_version_number    	IN     NUMBER,
    p_init_msg_list         	IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                	IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      	IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_line_tbl      		IN     AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    p_header_rec               	IN     AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag     	IN     VARCHAR2,
    p_admin_flag	    	IN     VARCHAR2,
    p_admin_group_id	    	IN     NUMBER,
    p_identity_salesforce_id 	IN     NUMBER,
    p_salesgroup_id		IN    NUMBER        DEFAULT  NULL,
    p_partner_cont_party_id	IN     NUMBER,
    p_profile_tbl	    	IN     AS_UTILITY_PUB.Profile_Tbl_Type
				       DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_line_out_tbl		OUT NOCOPY    Line_Out_Tbl_Type,
    x_return_status         	OUT NOCOPY    VARCHAR2,
    x_msg_count             	OUT NOCOPY    NUMBER,
    x_msg_data              	OUT NOCOPY    VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_opp_lines';
l_api_version_number      CONSTANT NUMBER   := 2.0;
--l_pvt_Line_rec    	  AS_OPP_LINE_PVT.Line_Rec_Type;

l_line_tbl      	  Line_Tbl_Type := p_line_tbl;
l_header_rec		  Header_Rec_Type := p_header_rec;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Create_Opp_Lines';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_LINES_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Line_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Line_Values_To_Ids (
            p_Line_rec       =>  p_Line_rec,
            x_pvt_Line_rec   =>  l_pvt_Line_rec
      );
     *****/

    -- Calling Private package: Create_OPP_LINES
    -- Hint: Primary key needs to be returned
      AS_OPP_line_PVT.Create_opp_lines(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => P_Validation_Level,
      P_Check_Access_Flag          => p_check_access_flag,
      P_Admin_Flag                 => P_Admin_Flag ,
      P_Admin_Group_Id             => P_Admin_Group_Id,
      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      p_salesgroup_id	           => p_salesgroup_id,
      P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      P_Profile_Tbl                => P_Profile_tbl,
      P_Line_Tbl 		   => l_line_tbl ,
      P_Header_Rec		   => l_header_rec,
      X_line_out_tbl    	   => x_line_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_opp_lines;



-- Start of Comments
--
--    API name    : Update_Opp_Lines
--    Type        : Public
--    Function    : Update Opp_Line Information for an Opportunity
--
--

PROCEDURE Update_Opp_Lines
(   p_api_version_number    	IN    NUMBER,
    p_init_msg_list         	IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                	IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      	IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id 	IN    NUMBER DEFAULT  NULL,
    p_line_tbl       		IN    AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    p_header_rec               	IN    AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag	    	IN    VARCHAR2,
    p_admin_flag	    	IN    VARCHAR2,
    p_admin_group_id	    	IN    NUMBER,
    p_partner_cont_party_id	IN    NUMBER,
    p_profile_tbl	    	IN    AS_UTILITY_PUB.Profile_Tbl_Type
				      DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_line_out_tbl		OUT NOCOPY   Line_Out_Tbl_Type,
    x_return_status         	OUT NOCOPY   VARCHAR2,
    x_msg_count             	OUT NOCOPY   NUMBER,
    x_msg_data              	OUT NOCOPY   VARCHAR2)
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_opp_lines';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_line_tbl      	  Line_Tbl_Type := p_line_tbl;
l_header_rec		  Header_Rec_Type := p_header_rec;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Opp_Lines';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OPP_LINES_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

     /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Line_Values_To_Ids');

      END IF;

      -- Convert the values to ids
      --
      Convert_Line_Values_To_Ids (
            p_Line_rec       =>  p_Line_rec,
            x_pvt_Line_rec   =>  l_pvt_Line_rec
      );
     *****/

    AS_OPP_line_PVT.Update_opp_lines(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 =>  P_Admin_Flag ,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Line_Tbl  		 => l_line_tbl ,
    P_Header_Rec		 => l_header_rec,
    X_Line_Out_Tbl		 => x_line_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_opp_lines;


-- Start of Comments
--
--    API name    : Delete_Opp_Lines
--    Type        : Public
--    Function    : Delete Lines for an Opportunity
--
--

PROCEDURE Delete_Opp_Lines
(   p_api_version_number    	IN    NUMBER,
    p_init_msg_list         	IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                	IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level          IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id 	IN    NUMBER DEFAULT  NULL,
    p_line_tbl      		IN    AS_OPPORTUNITY_PUB.Line_Tbl_Type,
    p_header_rec               	IN    AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_check_access_flag     	IN    VARCHAR2,
    p_admin_flag	    	IN    VARCHAR2,
    p_admin_group_id	    	IN    NUMBER,
    p_partner_cont_party_id	IN    NUMBER,
    p_profile_tbl	    	IN    AS_UTILITY_PUB.Profile_Tbl_Type
				      DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_line_out_tbl		OUT NOCOPY   Line_Out_Tbl_Type,
    x_return_status         	OUT NOCOPY   VARCHAR2,
    x_msg_count             	OUT NOCOPY   NUMBER,
    x_msg_data              	OUT NOCOPY   VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_opp_lines';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_line_tbl      	  Line_Tbl_Type := p_line_tbl;
l_header_rec		  Header_Rec_Type := p_header_rec;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Opp_Lines';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_OPP_LINES_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

     /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Line_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Line_Values_To_Ids (
            p_Line_rec       =>  p_Line_rec,
            x_pvt_Line_rec   =>  l_pvt_Line_rec
      );
     *****/

    AS_OPP_line_PVT.Delete_opp_lines(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 =>  P_Admin_Flag ,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Identity_Salesforce_Id      => p_identity_salesforce_id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Line_Tbl  		 => l_line_tbl ,
    P_Header_Rec		 => l_header_rec,
    X_Line_Out_Tbl		 => x_line_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_opp_lines;



PROCEDURE Create_Sales_Credits
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_sales_credit_tbl      IN     AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_sales_credit_out_tbl  OUT NOCOPY    Sales_Credit_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_sales_credits';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_sales_credit_tbl	  Sales_Credit_Tbl_type := p_sales_credit_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Create_Sales_Credits';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SALES_CREDITS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_SALES_CREDIT_Values_To_Ids');

      END IF;

      -- Convert the values to ids
      --
      Convert_SALES_CREDIT_Values_To_Ids (
            p_SALES_CREDIT_rec       =>  p_SALES_CREDIT_rec,
            x_pvt_SALES_CREDIT_rec   =>  l_pvt_SALES_CREDIT_rec
      );
      *****/

    -- Calling Private package: Create_SALES_CREDITS
    -- Hint: Primary key needs to be returned
      AS_OPP_sales_credit_PVT.Create_sales_credits(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => P_Validation_Level,
      P_Check_Access_Flag          => p_check_access_flag,
      P_Admin_Flag                 =>  P_Admin_Flag ,
      P_Admin_Group_Id             => P_Admin_Group_Id,
      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      P_Profile_Tbl                => P_Profile_tbl,
      P_Sales_Credit_Tbl	   => l_sales_credit_tbl,
      X_Sales_Credit_Out_Tbl	   => x_sales_credit_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_sales_credits;


PROCEDURE Update_Sales_Credits
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_sales_credit_tbl      IN     AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_sales_credit_out_tbl  OUT NOCOPY    Sales_Credit_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_sales_credits';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_sales_credit_tbl	  Sales_Credit_Tbl_type := p_sales_credit_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Sales_Credits';
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SALES_CREDITS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_SALES_CREDIT_Values_To_Ids');

      END IF;

      -- Convert the values to ids
      --
      Convert_SALES_CREDIT_Values_To_Ids (
            p_SALES_CREDIT_rec       =>  p_SALES_CREDIT_rec,
            x_pvt_SALES_CREDIT_rec   =>  l_pvt_SALES_CREDIT_rec
      );
     *****/

    AS_OPP_sales_credit_PVT.Update_sales_credits(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag ,
    P_Admin_Flag                 =>  P_Admin_Flag ,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Sales_Credit_Tbl	         => l_sales_credit_tbl,
    X_Sales_Credit_Out_Tbl	 => x_sales_credit_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_sales_credits;



PROCEDURE Modify_Sales_Credits
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_sales_credit_tbl      IN     AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_sales_credit_out_tbl  OUT NOCOPY    Sales_Credit_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

IS
l_api_name                CONSTANT VARCHAR2(30) := 'Modify_Sales_Credits';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_sales_credit_tbl	  Sales_Credit_Tbl_type := p_sales_credit_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Modify_Sales_Credits';
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT MODIFY_SALES_CREDITS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_SALES_CREDIT_Values_To_Ids');
      END IF;


      -- Convert the values to ids
      --
      Convert_SALES_CREDIT_Values_To_Ids (
            p_SALES_CREDIT_rec       =>  p_SALES_CREDIT_rec,
            x_pvt_SALES_CREDIT_rec   =>  l_pvt_SALES_CREDIT_rec
      );
     *****/

    AS_OPP_sales_credit_PVT.Modify_Sales_Credits(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag ,
    P_Admin_Flag                 =>  P_Admin_Flag ,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Sales_Credit_Tbl	         => l_sales_credit_tbl,
    X_Sales_Credit_Out_Tbl	 => x_sales_credit_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Modify_Sales_Credits;


PROCEDURE Delete_Sales_Credits
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_sales_credit_tbl      IN     AS_OPPORTUNITY_PUB.Sales_Credit_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_sales_credit_out_tbl  OUT NOCOPY    Sales_Credit_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_sales_credits';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_sales_credit_tbl	  Sales_Credit_Tbl_type := p_sales_credit_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Sales_Credits';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SALES_CREDITS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_SALES_CREDIT_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_SALES_CREDIT_Values_To_Ids (
            p_SALES_CREDIT_rec       =>  p_SALES_CREDIT_rec,
            x_pvt_SALES_CREDIT_rec   =>  l_pvt_SALES_CREDIT_rec
      );
      *****/
    AS_OPP_sales_credit_PVT.Delete_sales_credits(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Identity_Salesforce_Id     => p_identity_salesforce_id,
    P_Sales_Credit_Tbl	         => l_sales_credit_tbl,
    X_Sales_Credit_Out_Tbl	 => x_sales_credit_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_sales_credits;


PROCEDURE Update_Orders
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_lead_order_tbl        IN     AS_OPPORTUNITY_PUB.Order_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_order_out_tbl	    OUT NOCOPY    Order_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_orders';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_order_tbl		  Order_Tbl_Type  := p_lead_order_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Orders';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_ORDERS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Order_Values_To_Ids');
      END IF;


      -- Convert the values to ids
      --
      Convert_Order_Values_To_Ids (
            p_Order_rec       =>  p_Order_rec,
            x_pvt_Order_rec   =>  l_pvt_Order_rec
      );
      *****/
  -- Commenting the following call and obsolete AS_OPP_order_PVT for R12

    /*AS_OPP_order_PVT.Update_orders(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Order_Tbl	                 => l_order_tbl,
    X_Lead_Order_Out_Tbl	 => x_order_out_tbl,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_orders;


PROCEDURE Delete_Orders
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_lead_order_tbl        IN     AS_OPPORTUNITY_PUB.Order_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_order_out_tbl	    OUT NOCOPY    Order_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_orders';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_order_tbl		  Order_Tbl_Type  := p_lead_order_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Orders';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_ORDERS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Order_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Order_Values_To_Ids (
            p_Order_rec       =>  p_Order_rec,
            x_pvt_Order_rec   =>  l_pvt_Order_rec
      );
      *****/
 -- Commenting the following call and obsolete AS_OPP_order_PVT for R12
/*    AS_OPP_order_PVT.Delete_orders(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => p_identity_salesforce_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Order_Tbl	                 => l_order_tbl,
    X_Lead_Order_Out_Tbl	 => x_order_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;*/


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_orders;


PROCEDURE Create_Competitors
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_competitor_tbl        IN     AS_OPPORTUNITY_PUB.Competitor_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_out_tbl    OUT NOCOPY    Competitor_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_competitors';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_competitor_tbl	  Competitor_Tbl_Type := p_competitor_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Create_Competitors';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_COMPETITORS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Competitor_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Competitor_Values_To_Ids (
            p_Competitor_rec       =>  p_Competitor_rec,
            x_pvt_Competitor_rec   =>  l_pvt_Competitor_rec
      );
      *****/

    -- Calling Private package: Create_COMPETITOR
    -- Hint: Primary key needs to be returned
      AS_OPP_competitor_PVT.Create_competitors(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => P_Validation_Level,
      P_Check_Access_Flag          => p_check_access_flag,
      P_Admin_Flag                 => P_Admin_Flag,
      P_Admin_Group_Id             => P_Admin_Group_Id,
      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      P_Profile_Tbl                => P_Profile_tbl,
      P_Competitor_Tbl             => l_competitor_tbl,
      X_Competitor_Out_Tbl         => x_competitor_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_competitors;


PROCEDURE Update_Competitors
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_competitor_tbl        IN     AS_OPPORTUNITY_PUB.Competitor_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_out_tbl    OUT NOCOPY    Competitor_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_competitors';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_competitor_tbl	  Competitor_Tbl_Type := p_competitor_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Competitors';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_COMPETITORS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Competitor_Values_To_Ids');


      END IF;

      -- Convert the values to ids
      --
      Convert_Competitor_Values_To_Ids (
            p_Competitor_rec       =>  p_Competitor_rec,
            x_pvt_Competitor_rec   =>  l_pvt_Competitor_rec
      );
      *****/

    AS_OPP_competitor_pvt.Update_competitors(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag ,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Competitor_Tbl             => l_competitor_tbl,
    X_Competitor_Out_Tbl         => x_competitor_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_competitors;


PROCEDURE Delete_Competitors
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_competitor_tbl        IN     AS_OPPORTUNITY_PUB.Competitor_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_out_tbl    OUT NOCOPY    Competitor_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_competitors';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_competitor_tbl	  Competitor_Tbl_Type := p_competitor_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Competitors';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_COMPETITORS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Competitor_Values_To_Ids');

      END IF;

      -- Convert the values to ids
      --
      Convert_Competitor_Values_To_Ids (
            p_Competitor_rec       =>  p_Competitor_rec,
            x_pvt_Competitor_rec   =>  l_pvt_Competitor_rec
      );
     *****/

    AS_OPP_competitor_pvt.Delete_competitors(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Identity_Salesforce_Id      => p_identity_salesforce_id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Competitor_Tbl             => l_competitor_tbl,
    X_Competitor_Out_Tbl         => x_competitor_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_competitors;


PROCEDURE Create_Competitor_Prods
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_competitor_prod_tbl        IN     AS_OPPORTUNITY_PUB.Competitor_Prod_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_prod_out_tbl    OUT NOCOPY    Competitor_Prod_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_competitor_prods';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_competitor_prod_tbl	  Competitor_Prod_Tbl_Type := p_competitor_prod_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Create_Competitor_Prods';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_COMPETITOR_PRODS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Competitor_Prod_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Competitor_Prod_Values_To_Ids (
            p_Competitor_Prod_rec       =>  p_Competitor_Prod_rec,
            x_pvt_Competitor_Prod_rec   =>  l_pvt_Competitor_Prod_rec
      );
      *****/

    -- Calling Private package: Create_COMPETITOR_PROD
    -- Hint: Primary key needs to be returned
      AS_competitor_prod_PVT.Create_competitor_prods(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => P_Validation_Level,
      P_Check_Access_Flag          => p_check_access_flag,
      P_Admin_Flag                 => P_Admin_Flag,
      P_Admin_Group_Id             => P_Admin_Group_Id,
      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      P_Profile_Tbl                => P_Profile_tbl,
      P_Competitor_Prod_Tbl             => l_competitor_prod_tbl,
      X_Competitor_Prod_Out_Tbl         => x_competitor_prod_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_competitor_prods;


PROCEDURE Update_Competitor_Prods
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_competitor_prod_tbl        IN     AS_OPPORTUNITY_PUB.Competitor_Prod_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_prod_out_tbl    OUT NOCOPY    Competitor_Prod_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_competitor_prods';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_competitor_prod_tbl	  Competitor_Prod_Tbl_Type := p_competitor_prod_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Competitor_Prods';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_COMPETITOR_PRODS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Competitor_Prod_Values_To_Ids');
      END IF;


      -- Convert the values to ids
      --
      Convert_Competitor_Prod_Values_To_Ids (
            p_Competitor_Prod_rec       =>  p_Competitor_Prod_rec,
            x_pvt_Competitor_Prod_rec   =>  l_pvt_Competitor_Prod_rec
      );
      *****/

    AS_competitor_prod_pvt.Update_competitor_prods(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag ,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Competitor_Prod_Tbl             => l_competitor_prod_tbl,
    X_Competitor_Prod_Out_Tbl         => x_competitor_prod_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_competitor_prods;


PROCEDURE Delete_Competitor_Prods
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_competitor_prod_tbl        IN     AS_OPPORTUNITY_PUB.Competitor_Prod_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_competitor_prod_out_tbl    OUT NOCOPY    Competitor_Prod_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_competitor_prods';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_competitor_prod_tbl	  Competitor_Prod_Tbl_Type := p_competitor_prod_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Competitor_Prods';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_COMPETITOR_PRODS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Competitor_Prod_Values_To_Ids');
      END IF;


      -- Convert the values to ids
      --
      Convert_Competitor_Prod_Values_To_Ids (
            p_Competitor_Prod_rec       =>  p_Competitor_Prod_rec,
            x_pvt_Competitor_Prod_rec   =>  l_pvt_Competitor_Prod_rec
      );
     *****/

    AS_competitor_prod_pvt.Delete_competitor_prods(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Identity_Salesforce_Id      => p_identity_salesforce_id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Competitor_Prod_Tbl             => l_competitor_prod_tbl,
    X_Competitor_Prod_Out_Tbl         => x_competitor_prod_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_competitor_prods;


PROCEDURE Create_Decision_Factors
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_decision_factor_tbl        IN     AS_OPPORTUNITY_PUB.Decision_Factor_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_decision_factor_out_tbl    OUT NOCOPY    Decision_Factor_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_decision_factors';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_decision_factor_tbl	  Decision_Factor_Tbl_Type := p_decision_factor_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Create_Decision_Factors';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_DECISION_FACTORS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Decision_Factor_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Decision_Factor_Values_To_Ids (
            p_Decision_Factor_rec       =>  p_Decision_Factor_rec,
            x_pvt_Decision_Factor_rec   =>  l_pvt_Decision_Factor_rec
      );
      *****/

    -- Calling Private package: Create_DECISION_FACTOR
    -- Hint: Primary key needs to be returned
      AS_decision_factor_PVT.Create_decision_factors(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => P_Validation_Level,
      P_Check_Access_Flag          => p_check_access_flag,
      P_Admin_Flag                 => P_Admin_Flag,
      P_Admin_Group_Id             => P_Admin_Group_Id,
      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      P_Profile_Tbl                => P_Profile_tbl,
      P_Decision_Factor_Tbl             => l_decision_factor_tbl,
      X_Decision_Factor_Out_Tbl         => x_decision_factor_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_decision_factors;


PROCEDURE Update_Decision_Factors
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_decision_factor_tbl        IN     AS_OPPORTUNITY_PUB.Decision_Factor_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_decision_factor_out_tbl    OUT NOCOPY    Decision_Factor_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_decision_factors';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_decision_factor_tbl	  Decision_Factor_Tbl_Type := p_decision_factor_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Decision_Factors';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_DECISION_FACTORS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Decision_Factor_Values_To_Ids');
      END IF;


      -- Convert the values to ids
      --
      Convert_Decision_Factor_Values_To_Ids (
            p_Decision_Factor_rec       =>  p_Decision_Factor_rec,
            x_pvt_Decision_Factor_rec   =>  l_pvt_Decision_Factor_rec
      );
      *****/

    AS_decision_factor_pvt.Update_decision_factors(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag ,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Decision_Factor_Tbl             => l_decision_factor_tbl,
    X_Decision_Factor_Out_Tbl         => x_decision_factor_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_decision_factors;


PROCEDURE Delete_Decision_Factors
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER   DEFAULT  NULL,
    p_decision_factor_tbl        IN     AS_OPPORTUNITY_PUB.Decision_Factor_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_decision_factor_out_tbl    OUT NOCOPY    Decision_Factor_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_decision_factors';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_decision_factor_tbl	  Decision_Factor_Tbl_Type := p_decision_factor_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Decision_Factors';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_DECISION_FACTORS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Decision_Factor_Values_To_Ids');
      END IF;


      -- Convert the values to ids
      --
      Convert_Decision_Factor_Values_To_Ids (
            p_Decision_Factor_rec       =>  p_Decision_Factor_rec,
            x_pvt_Decision_Factor_rec   =>  l_pvt_Decision_Factor_rec
      );
     *****/

    AS_decision_factor_pvt.Delete_decision_factors(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Identity_Salesforce_Id      => p_identity_salesforce_id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Decision_Factor_Tbl             => l_decision_factor_tbl,
    X_Decision_Factor_Out_Tbl         => x_decision_factor_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_decision_factors;


PROCEDURE Create_Contacts
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_contact_tbl           IN     AS_OPPORTUNITY_PUB.Contact_tbl_Type,
    p_header_rec            IN     HEADER_REC_TYPE DEFAULT  G_MISS_HEADER_REC,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_contact_out_tbl	    OUT NOCOPY    Contact_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_contacts';
l_api_version_number      CONSTANT NUMBER   := 2.0;

l_contact_tbl		  Contact_Tbl_type := p_contact_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Create_Contacts';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CONTACTS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Contact_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Contact_Values_To_Ids (
            p_Contact_rec       =>  p_Contact_rec,
            x_pvt_Contact_rec   =>  l_pvt_Contact_rec
      );
      *****/

    -- Calling Private package: Create_OPP_CONTACT
    -- Hint: Primary key needs to be returned
      AS_OPP_contact_PVT.Create_opp_contacts(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => P_Validation_Level,
      P_Check_Access_Flag          => p_check_access_flag,
      P_Admin_Flag                 => P_Admin_Flag,
      P_Admin_Group_Id             => P_Admin_Group_Id,
      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      P_Profile_Tbl                => P_Profile_tbl,
      P_Contact_Tbl 	    	   => l_contact_tbl,
      X_Contact_Out_Tbl     	   => x_contact_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_contacts;


PROCEDURE Update_Contacts
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_contact_tbl           IN     AS_OPPORTUNITY_PUB.Contact_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_contact_out_tbl	    OUT NOCOPY    Contact_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_contacts';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_contact_tbl	 	  Contact_Tbl_Type := p_contact_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Contacts';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CONTACTS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Contact_Values_To_Ids');
      END IF;


      -- Convert the values to ids
      --
      Convert_Contact_Values_To_Ids (
            p_Contact_rec       =>  p_Contact_rec,
            x_pvt_Contact_rec   =>  l_pvt_Contact_rec
      );
      *****/

    AS_OPP_contact_PVT.Update_opp_contacts(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Contact_Tbl                => l_contact_tbl ,
    X_Contact_Out_Tbl		 => x_contact_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_contacts;


PROCEDURE Delete_Contacts
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_contact_tbl           IN     AS_OPPORTUNITY_PUB.Contact_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_contact_out_tbl	    OUT NOCOPY    Contact_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_contacts';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_contact_tbl             Contact_Tbl_Type  := p_contact_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Contacts';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CONTACTS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Contact_Values_To_Ids');
      END IF;


      -- Convert the values to ids
      --
      Convert_Contact_Values_To_Ids (
            p_Contact_rec       =>  p_Contact_rec,
            x_pvt_Contact_rec   =>  l_pvt_Contact_rec
      );
     *****/

    AS_OPP_contact_PVT.Delete_opp_contacts(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => p_identity_salesforce_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Partner_Cont_Party_Id    => p_partner_cont_party_id,
    P_Contact_Tbl                => l_contact_tbl,
    X_Contact_Out_Tbl		 => x_contact_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_contacts;


PROCEDURE Create_Obstacles
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_obstacle_tbl          IN     AS_OPPORTUNITY_PUB.Obstacle_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_obstacle_out_tbl	    OUT NOCOPY    Obstacle_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_obstacles';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_obstacle_tbl		  Obstacle_Tbl_Type := p_obstacle_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Create_Obstacles';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OBSTACLES_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Obstacle_Values_To_Ids');

      END IF;

      -- Convert the values to ids
      --
      Convert_Obstacle_Values_To_Ids (
            p_Obstacle_rec       =>  p_Obstacle_rec,
            x_pvt_Obstacle_rec   =>  l_pvt_Obstacle_rec
      );
      *****/

    -- Calling Private package: Create_OBSTACLE
    -- Hint: Primary key needs to be returned
      AS_OPP_obstacle_PVT.Create_obstacles(
      P_Api_Version_Number         => 2.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => P_Validation_Level,
      P_Check_Access_Flag          => p_check_access_flag,
      P_Admin_Flag                 => P_Admin_Flag,
      P_Admin_Group_Id             => P_Admin_Group_Id,
      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      P_Partner_Cont_Party_Id	   => p_partner_cont_party_id,
      P_Profile_Tbl                => P_Profile_tbl,
      P_Obstacle_Tbl		   => l_obstacle_tbl,
      X_Lead_Obstacle_Out_Tbl	   => x_obstacle_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_obstacles;



PROCEDURE Update_Obstacles
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_obstacle_tbl          IN     AS_OPPORTUNITY_PUB.Obstacle_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_obstacle_out_tbl	    OUT NOCOPY    Obstacle_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_obstacles';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_obstacle_tbl		  Obstacle_Tbl_Type := p_obstacle_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Update_Obstacles';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OBSTACLES_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

     /*****
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Obstacle_Values_To_Ids');
      END IF;

      -- Convert the values to ids
      --
      Convert_Obstacle_Values_To_Ids (
            p_Obstacle_rec       =>  p_Obstacle_rec,
            x_pvt_Obstacle_rec   =>  l_pvt_Obstacle_rec
      );
       *****/

    AS_OPP_obstacle_PVT.Update_obstacles(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Obstacle_Tbl		 => l_obstacle_tbl,
    X_Lead_Obstacle_Out_Tbl	 => x_obstacle_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_obstacles;


PROCEDURE Delete_Obstacles
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_identity_salesforce_id IN    NUMBER DEFAULT  NULL,
    p_obstacle_tbl          IN     AS_OPPORTUNITY_PUB.Obstacle_tbl_Type,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_obstacle_out_tbl	    OUT NOCOPY    Obstacle_Out_Tbl_Type,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_obstacles';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_obstacle_tbl		  Obstacle_Tbl_Type := p_obstacle_tbl;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_Obstacles';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_OBSTACLES_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /*****

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'AS: Public API: Convert_Obstacle_Values_To_Ids');

      END IF;

      -- Convert the values to ids
      --
      Convert_Obstacle_Values_To_Ids (
            p_Obstacle_rec       =>  p_Obstacle_rec,
            x_pvt_Obstacle_rec   =>  l_pvt_Obstacle_rec
      );
      *****/

    AS_OPP_obstacle_PVT.Delete_obstacles(
    P_Api_Version_Number         => 2.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level ,
    P_Check_Access_Flag          => p_check_access_flag,
    P_Admin_Flag                 => P_Admin_Flag,
    P_Admin_Group_Id             => P_Admin_Group_Id,
    P_Identity_Salesforce_Id      => p_identity_salesforce_id,
    P_Profile_Tbl                => P_Profile_tbl,
    P_Partner_Cont_Party_Id	 => p_partner_cont_party_id,
    P_Obstacle_Tbl		 => l_obstacle_tbl,
    X_Lead_Obstacle_Out_Tbl	 => x_obstacle_out_tbl,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_obstacles;

PROCEDURE Delete_SalesTeams
(       p_api_version_number            IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2	DEFAULT  FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2	DEFAULT  FND_API.G_FALSE,
    	p_validation_level      	IN      NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
        p_sales_team_tbl                IN      AS_ACCESS_PUB.SALES_TEAM_TBL_TYPE,
    	p_check_access_flag     	IN 	VARCHAR2,
    	p_admin_flag	    		IN 	VARCHAR2,
    	p_admin_group_id	    	IN	NUMBER,
    	p_identity_salesforce_id 	IN	NUMBER,
        p_partner_cont_party_id           IN      NUMBER,
     	p_profile_tbl	    		IN     	AS_UTILITY_PUB.Profile_Tbl_Type
				 		DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
)
IS

  Cursor c_sales_team(p_access_id number) IS
	select lead_id, salesforce_id, sales_group_id
   	from as_accesses_all
	where access_id = p_access_id;

  Cursor C_SalesCredit_Exist (X_SalesForceID NUMBER,
			      X_LeadID NUMBER,
			      X_salesGroupID NUMBER)
  IS
    SELECT  sales_credit_id
    FROM    as_sales_credits
    WHERE   salesforce_id = X_SalesForceID
    AND     lead_id = X_LeadID
    AND     NVL(SALESGROUP_ID, -99) = NVL(X_salesGroupID, -99);

  Cursor C_GetPersonName(X_personID per_people_f.person_id%type)
  IS
    SELECT first_name||' '||last_name
    FROM per_people_f
    WHERE person_id = X_personID;

  l_salesforce_id           NUMBER;
  l_lead_id                 NUMBER;
  l_sales_credit_id         NUMBER;
  l_sales_group_id          NUMBER;
  l_person_name             VARCHAR2(65);
  l_api_name                CONSTANT VARCHAR2(30) := 'Delete_SalesTeams';
  l_api_version_number      CONSTANT NUMBER := 2.0;
  l_sales_team_rec		   AS_ACCESS_PUB.Sales_Team_Rec_Type;
  l_access_profile_rec      AS_ACCESS_PUB.Access_Profile_Rec_Type;
  l_line_count              CONSTANT NUMBER := p_sales_team_tbl.count;
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Delete_SalesTeams';
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SALESTEAMS_PUB;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
	     p_profile_tbl => p_profile_tbl,
	     x_access_profile_rec => l_access_profile_rec);

      --
      -- API body
      --

	 -- AS_ACCESS_PUB.Delete_SalesTeam handles single records.
	 -- This procedure needs to be able to handle tables.
      FOR l_curr_row IN 1..l_line_count LOOP

	     -- Check whether the Sales Person has Sales Credit
	     BEGIN
	       l_sales_team_rec := p_sales_team_tbl(l_curr_row);

	       IF(l_sales_team_rec.lead_id IS NULL OR
	          l_sales_team_rec.lead_id = FND_API.G_MISS_NUM) OR
	 	 (l_sales_team_rec.salesforce_id IS NULL OR
		  l_sales_team_rec.salesforce_id = FND_API.G_MISS_NUM)
  	       THEN
		   open c_sales_team(l_sales_team_rec.access_id);
		   fetch c_sales_team into l_lead_id, l_salesforce_id, l_sales_group_id;
		   close c_sales_team;
	       ELSE
	           l_salesforce_id := l_sales_team_rec.salesforce_id;
	           l_lead_id := l_sales_team_rec.lead_id;
                   l_sales_group_id := l_sales_team_rec.sales_group_id;
	       END IF;
                   IF l_debug THEN
                   AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'sales group id: '||l_sales_group_id );
                   END IF;


		      OPEN C_SalesCredit_Exist (l_salesforce_id,l_lead_id, l_sales_group_id);
		      FETCH C_SalesCredit_Exist INTO l_sales_credit_id;

		      IF C_SalesCredit_Exist%NOTFOUND THEN
			     -- Call the AS_ACCESS_PUB.Delete_SalesTeam API
			     AS_ACCESS_PUB.Delete_SalesTeam(
			         p_api_version_number     =>  l_api_version_number,
                        p_init_msg_list          =>  FND_API.G_FALSE,
                        p_commit                 =>  p_commit,
				    p_validation_level       =>  p_validation_level,
				    p_access_profile_rec     =>  l_access_profile_rec,
				    p_check_access_flag      =>  p_check_access_flag,
				    p_admin_flag             =>  p_admin_flag,
				    p_admin_group_id         =>  p_admin_group_id,
				    p_identity_salesforce_id =>  p_identity_salesforce_id,
                        p_sales_team_rec         =>  l_sales_team_rec,
                        x_return_status          =>  x_return_status,
                        x_msg_count              =>  x_msg_count,
                        x_msg_data               =>  x_msg_data
                    );

		      ELSE

			     -- Raise message
			     OPEN C_GetPersonName(l_sales_team_rec.person_id);
			     FETCH C_GetPersonName INTO l_person_name;
			     CLOSE C_GetPersonName;

			     --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
			     --THEN
				--    FND_MESSAGE.Set_Name('AS', 'AS_DELETE_SALESTEAM_NOTALLOWED');
				--    FND_MESSAGE.Set_Token ('salesrep', l_person_name, FALSE);
				--    FND_MSG_PUB.Add;
			    -- END IF;

              	    	    AS_UTILITY_PVT.Set_Message(l_module,
                  			p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  			p_msg_name      => 'AS_DELETE_SALESTEAM_NOTALLOWED',
                      			p_token1        => 'SALESREP',
                      			p_token1_value  => l_person_name );


			     x_return_status := FND_API.G_RET_STS_ERROR;

			     FND_MSG_PUB.Count_And_Get(
				    p_count => x_msg_count,
				    p_data  => x_msg_data
				    );

		      END IF;

		      CLOSE C_SalesCredit_Exist;

          END;

	     -- Check return status from the above procedure call
	     IF x_return_status = FND_API.G_RET_STS_ERROR
	     THEN
		    raise FND_API.G_EXC_ERROR;
	     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	     THEN
		    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;

      END LOOP;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Public API: ' || l_api_name || ' end');

	 AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
                  ,P_ROLLBACK_FLAG => 'Y'
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Delete_SalesTeams;


-- Start of Comments
--
--    API name    : Copy_Opportunity
--    Type        : Public.
--
-- End of Comments

PROCEDURE Copy_Opportunity
(   p_api_version_number            IN    NUMBER,
    p_init_msg_list                 IN    VARCHAR2  	DEFAULT FND_API.G_FALSE,
    p_commit                        IN    VARCHAR2   	DEFAULT  FND_API.G_FALSE,
    p_validation_level      	    IN    NUMBER   	DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                       IN    NUMBER,
    p_description                   IN    VARCHAR2,
    p_copy_salesteam		    IN    VARCHAR2	DEFAULT FND_API.G_FALSE,
    p_copy_opp_lines		    IN    VARCHAR2	DEFAULT FND_API.G_FALSE,
    p_copy_lead_contacts     	    IN    VARCHAR2	DEFAULT FND_API.G_FALSE,
    p_copy_lead_competitors         IN    VARCHAR2	DEFAULT FND_API.G_FALSE,
    p_copy_sales_credits	    IN    VARCHAR2	DEFAULT FND_API.G_FALSE,
    p_copy_methodology	    	    IN    VARCHAR2     	DEFAULT FND_API.G_FALSE,
    p_new_customer_id		    IN 	  NUMBER,
    p_new_address_id		    IN    NUMBER,
    p_check_access_flag     	    IN 	  VARCHAR2,
    p_admin_flag	    	    IN 	  VARCHAR2,
    p_admin_group_id	    	    IN	  NUMBER,
    p_identity_salesforce_id 	    IN	  NUMBER,
    p_salesgroup_id		    IN    NUMBER        DEFAULT  NULL,
    p_partner_cont_party_id	    IN    NUMBER,
    p_profile_tbl	    	    IN	  AS_UTILITY_PUB.Profile_Tbl_Type
					  DEFAULT AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status                 OUT NOCOPY   VARCHAR2,
    x_msg_count                     OUT NOCOPY   NUMBER,
    x_msg_data                      OUT NOCOPY   VARCHAR2,
    x_lead_id                       OUT NOCOPY   NUMBER
)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Copy_Opportunity';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.oppb.Copy_Opportunity';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_OPPORTUNITY_PUB;

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

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Create_OPP_HEADER
      -- Hint: Primary key needs to be returned
      AS_OPP_COPY_PVT.Copy_Opportunity(
      	P_Api_Version_Number         => 2.0,
      	P_Init_Msg_List              => FND_API.G_FALSE,
      	P_Commit                     => p_commit,
      	P_Validation_Level           => P_Validation_Level ,
    	P_Lead_Id                    => p_lead_id,
        P_Description                => p_description,
    	P_Copy_Salesteam	     => p_copy_salesteam,
    	P_Copy_Opp_Lines	     => p_copy_opp_lines,
    	p_copy_lead_contacts         => p_copy_lead_contacts,
    	p_copy_lead_competitors      => p_copy_lead_competitors,
    	p_copy_sales_credits	     => p_copy_sales_credits,
        p_copy_methodology	     => p_copy_methodology,
        p_new_customer_id	     => p_new_customer_id,
        p_new_address_id	     => p_new_address_id,
      	P_Check_Access_Flag          => p_check_access_flag,
      	P_Admin_Flag                 => P_Admin_Flag ,
      	P_Admin_Group_Id             => P_Admin_Group_Id,
      	P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      	p_salesgroup_id		     => p_salesgroup_id,
      	P_Profile_Tbl                => P_Profile_tbl,
      	P_Partner_Cont_Party_Id	     => p_partner_cont_party_id,
      	X_LEAD_ID     		     => x_LEAD_ID,
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

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Public API: ' || l_api_name || ' end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Copy_Opportunity;


PROCEDURE Get_Access_Profiles(
	p_profile_tbl			IN	AS_UTILITY_PUB.Profile_Tbl_Type,
	x_access_profile_rec		OUT NOCOPY	AS_ACCESS_PUB.Access_Profile_Rec_Type
)

IS

l_profile_count                 CONSTANT NUMBER := p_profile_tbl.count;
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
    RETURN FND_PROFILE.Value(p_profile_name);
END;

End AS_OPPORTUNITY_PUB;

/
