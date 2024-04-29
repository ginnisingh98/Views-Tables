--------------------------------------------------------
--  DDL for Package Body AS_OPP_OBSTACLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_OBSTACLE_PVT" as
/* $Header: asxvobsb.pls 120.1 2005/06/14 01:36:54 appldev  $ */
-- Start of Comments
-- Package name     : AS_OPP_OBSTACLE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_OPP_OBSTACLE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvobsb.pls';

-- Hint: Primary key needs to be returned.
PROCEDURE Create_obstacles(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   VARCHAR2     := FND_API.G_FALSE,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    p_partner_cont_party_id      IN   NUMBER  := FND_API.G_MISS_NUM,
    P_Obstacle_tbl               IN   AS_OPPORTUNITY_PUB.Obstacle_tbl_Type  := AS_OPPORTUNITY_PUB.G_MISS_Obstacle_tbl,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_LEAD_OBSTACLE_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.obstacle_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )


 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_obstacles';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full      VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_OBSTACLE_rec            AS_OPPORTUNITY_PUB.OBSTACLE_Rec_Type;
l_LEAD_OBSTACLE_ID        NUMBER;
l_access_profile_rec      AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
l_access_flag             VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lobpv.Create_obstacles';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OBSTACLES_PVT;

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
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_obstacle_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Obstacle_Rec      =>  P_Obstacle_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF ( P_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN
         AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
		p_profile_tbl         => p_profile_tbl,
		x_access_profile_rec  => l_access_profile_rec);

      IF( p_check_access_flag = 'Y' )
	 THEN
        AS_ACCESS_PUB.Has_updateOpportunityAccess(
              p_api_version_number     => 2.0
             ,p_init_msg_list          => p_init_msg_list
             ,p_validation_level       => p_validation_level
             ,p_access_profile_rec     => l_access_profile_rec
             ,p_admin_flag             => p_admin_flag
             ,p_admin_group_id         => p_admin_group_id
             ,p_person_id              => l_identity_sales_member_rec.employee_person_id
             ,p_opportunity_id         => P_Obstacle_tbl(1).LEAD_ID
             ,p_check_access_flag      => 'Y'
             ,p_identity_salesforce_id => p_identity_salesforce_id
             ,p_partner_cont_party_id  => NULL
             ,x_return_status          => x_return_status
             ,x_msg_count              => x_msg_count
             ,x_msg_data               => x_msg_data
             ,x_update_access_flag     => l_access_flag);
      END IF;

	 IF l_access_flag <> 'Y' THEN
		AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
		'API_NO_UPDATE_PRIVILEGE');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(AS_LEAD_OBSTACLES_PKG.Insert_Row)
    FOR I in 1 .. P_OBSTACLE_tbl.count LOOP

        X_LEAD_OBSTACLE_out_tbl(I).return_status := FND_API.G_RET_STS_SUCCESS;
        l_LEAD_OBSTACLE_ID := P_OBSTACLE_Tbl(I).LEAD_OBSTACLE_ID;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_OPP_OBSTACLE', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(I), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_OBSTACLE_rec := P_OBSTACLE_Tbl(I);

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF l_debug THEN
	          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_obstacle');
	  END IF;


          -- Invoke validation procedures
          Validate_obstacle(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
              P_Obstacle_Rec  =>  l_Obstacle_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');
      END IF;


      AS_LEAD_OBSTACLES_PKG.Insert_Row(
          px_LEAD_OBSTACLE_ID  => l_LEAD_OBSTACLE_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => p_Obstacle_tbl(I).REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_Obstacle_tbl(I).PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_Obstacle_tbl(I).PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_Obstacle_tbl(I).PROGRAM_UPDATE_DATE,
          p_LEAD_ID  => p_Obstacle_tbl(I).LEAD_ID,
          p_OBSTACLE_CODE  => p_Obstacle_tbl(I).OBSTACLE_CODE,
          p_OBSTACLE  => p_Obstacle_tbl(I).OBSTACLE,
          p_OBSTACLE_STATUS  => p_Obstacle_tbl(I).OBSTACLE_STATUS,
          p_COMMENTS  => p_Obstacle_tbl(I).COMMENTS,
          p_ATTRIBUTE_CATEGORY  => p_Obstacle_tbl(I).ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_Obstacle_tbl(I).ATTRIBUTE1,
          p_ATTRIBUTE2  => p_Obstacle_tbl(I).ATTRIBUTE2,
          p_ATTRIBUTE3  => p_Obstacle_tbl(I).ATTRIBUTE3,
          p_ATTRIBUTE4  => p_Obstacle_tbl(I).ATTRIBUTE4,
          p_ATTRIBUTE5  => p_Obstacle_tbl(I).ATTRIBUTE5,
          p_ATTRIBUTE6  => p_Obstacle_tbl(I).ATTRIBUTE6,
          p_ATTRIBUTE7  => p_Obstacle_tbl(I).ATTRIBUTE7,
          p_ATTRIBUTE8  => p_Obstacle_tbl(I).ATTRIBUTE8,
          p_ATTRIBUTE9  => p_Obstacle_tbl(I).ATTRIBUTE9,
          p_ATTRIBUTE10  => p_Obstacle_tbl(I).ATTRIBUTE10,
          p_ATTRIBUTE11  => p_Obstacle_tbl(I).ATTRIBUTE11,
          p_ATTRIBUTE12  => p_Obstacle_tbl(I).ATTRIBUTE12,
          p_ATTRIBUTE13  => p_Obstacle_tbl(I).ATTRIBUTE13,
          p_ATTRIBUTE14  => p_Obstacle_tbl(I).ATTRIBUTE14,
          p_ATTRIBUTE15  => p_Obstacle_tbl(I).ATTRIBUTE15);
-- ?          p_SECURITY_GROUP_ID  => p_Obstacle_tbl(I).SECURITY_GROUP_ID);
      -- Hint: Primary key should be returned.
      -- x_LEAD_OBSTACLE_ID := px_LEAD_OBSTACLE_ID;

      X_LEAD_OBSTACLE_out_tbl(I).LEAD_OBSTACLE_ID := l_LEAD_OBSTACLE_ID;
      X_LEAD_OBSTACLE_out_tbl(I).return_status := x_return_status;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
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
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_obstacle_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Obstacle_Rec      =>  P_Obstacle_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION

	  WHEN DUP_VAL_ON_INDEX THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
              	  FND_MESSAGE.Set_Name('AS', 'API_DUP_ISSUES');
              	  FND_MSG_PUB.ADD;
              END IF;

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_obstacles;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_obstacles(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_profile_tbl              IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    p_partner_cont_party_id      IN  NUMBER  := FND_API.G_MISS_NUM,
    P_Obstacle_tbl               IN    AS_OPPORTUNITY_PUB.Obstacle_tbl_type,
    X_LEAD_OBSTACLE_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.obstacle_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

Cursor C_Get_obstacle(c_LEAD_OBSTACLE_ID Number) IS
    Select rowid,
           LEAD_OBSTACLE_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           LEAD_ID,
           OBSTACLE_CODE,
           OBSTACLE,
           OBSTACLE_STATUS,
           COMMENTS,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15
-- ?           SECURITY_GROUP_ID
    From  AS_LEAD_OBSTACLES
    WHERE LEAD_OBSTACLE_ID = c_LEAD_OBSTACLE_ID
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_obstacles';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_Obstacle_rec  AS_OPPORTUNITY_PUB.Obstacle_Rec_Type;
l_tar_Obstacle_rec  AS_OPPORTUNITY_PUB.Obstacle_Rec_Type;
l_Obstacle_rec            AS_OPPORTUNITY_PUB.Obstacle_Rec_Type;
l_rowid  ROWID;
l_access_profile_rec      AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
l_access_flag             VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lobpv.Update_obstacles';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OBSTACLES_PVT;

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
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_obstacle_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Obstacle_Rec      =>  P_Obstacle_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

      IF ( P_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
          p_profile_tbl         => p_profile_tbl,
          x_access_profile_rec  => l_access_profile_rec);

      IF( p_check_access_flag = 'Y' )
	 THEN
        AS_ACCESS_PUB.Has_updateOpportunityAccess(
              p_api_version_number     => 2.0
             ,p_init_msg_list          => p_init_msg_list
             ,p_validation_level       => p_validation_level
             ,p_access_profile_rec     => l_access_profile_rec
             ,p_admin_flag             => p_admin_flag
             ,p_admin_group_id         => p_admin_group_id
             ,p_person_id              => l_identity_sales_member_rec.employee_person_id
             ,p_opportunity_id         => P_Obstacle_tbl(1).LEAD_ID
             ,p_check_access_flag      => 'Y'
             ,p_identity_salesforce_id => p_identity_salesforce_id
             ,p_partner_cont_party_id  => NULL
             ,x_return_status          => x_return_status
             ,x_msg_count              => x_msg_count
             ,x_msg_data               => x_msg_data
             ,x_update_access_flag     => l_access_flag);
      END IF;

	 IF l_access_flag <> 'Y' THEN
		AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
		'API_NO_UPDATE_PRIVILEGE');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   FOR I in 1 .. P_Obstacle_tbl.count LOOP

      l_tar_Obstacle_rec := P_Obstacle_tbl(I);
      X_LEAD_OBSTACLE_out_tbl(I).return_status := FND_API.G_RET_STS_SUCCESS;

      -- Progress Message
      --
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
       THEN
          FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
          FND_MESSAGE.Set_Token ('ROW', 'AS_OPP_OBSTACLE', TRUE);
          FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(I), FALSE);
          FND_MSG_PUB.Add;
       END IF;

       l_OBSTACLE_rec := P_OBSTACLE_Tbl(I);

      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');
      END IF;


      Open C_Get_obstacle( l_tar_Obstacle_rec.LEAD_OBSTACLE_ID);

      Fetch C_Get_obstacle into
               l_rowid,
               l_ref_Obstacle_rec.LEAD_OBSTACLE_ID,
               l_ref_Obstacle_rec.LAST_UPDATE_DATE,
               l_ref_Obstacle_rec.LAST_UPDATED_BY,
               l_ref_Obstacle_rec.CREATION_DATE,
               l_ref_Obstacle_rec.CREATED_BY,
               l_ref_Obstacle_rec.LAST_UPDATE_LOGIN,
               l_ref_Obstacle_rec.REQUEST_ID,
               l_ref_Obstacle_rec.PROGRAM_APPLICATION_ID,
               l_ref_Obstacle_rec.PROGRAM_ID,
               l_ref_Obstacle_rec.PROGRAM_UPDATE_DATE,
               l_ref_Obstacle_rec.LEAD_ID,
               l_ref_Obstacle_rec.OBSTACLE_CODE,
               l_ref_Obstacle_rec.OBSTACLE,
               l_ref_Obstacle_rec.OBSTACLE_STATUS,
               l_ref_Obstacle_rec.COMMENTS,
               l_ref_Obstacle_rec.ATTRIBUTE_CATEGORY,
               l_ref_Obstacle_rec.ATTRIBUTE1,
               l_ref_Obstacle_rec.ATTRIBUTE2,
               l_ref_Obstacle_rec.ATTRIBUTE3,
               l_ref_Obstacle_rec.ATTRIBUTE4,
               l_ref_Obstacle_rec.ATTRIBUTE5,
               l_ref_Obstacle_rec.ATTRIBUTE6,
               l_ref_Obstacle_rec.ATTRIBUTE7,
               l_ref_Obstacle_rec.ATTRIBUTE8,
               l_ref_Obstacle_rec.ATTRIBUTE9,
               l_ref_Obstacle_rec.ATTRIBUTE10,
               l_ref_Obstacle_rec.ATTRIBUTE11,
               l_ref_Obstacle_rec.ATTRIBUTE12,
               l_ref_Obstacle_rec.ATTRIBUTE13,
               l_ref_Obstacle_rec.ATTRIBUTE14,
               l_ref_Obstacle_rec.ATTRIBUTE15;
-- ?               l_ref_Obstacle_rec.SECURITY_GROUP_ID;

       If ( C_Get_obstacle%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'obstacle', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF l_debug THEN
       	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       END IF;

       Close     C_Get_obstacle;

      If (l_tar_Obstacle_rec.last_update_date is NULL or
          l_tar_Obstacle_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_Obstacle_rec.last_update_date <> l_ref_Obstacle_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'obstacle', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_obstacle');
          END IF;


          -- Invoke validation procedures
          Validate_obstacle(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
              P_Obstacle_Rec  =>  l_Obstacle_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;


      -- Invoke table handler(AS_LEAD_OBSTACLES_PKG.Update_Row)
      AS_LEAD_OBSTACLES_PKG.Update_Row(
          p_LEAD_OBSTACLE_ID  => p_Obstacle_tbl(I).LEAD_OBSTACLE_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => p_Obstacle_tbl(I).REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_Obstacle_tbl(I).PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => p_Obstacle_tbl(I).PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_Obstacle_tbl(I).PROGRAM_UPDATE_DATE,
          p_LEAD_ID  => p_Obstacle_tbl(I).LEAD_ID,
          p_OBSTACLE_CODE  => p_Obstacle_tbl(I).OBSTACLE_CODE,
          p_OBSTACLE  => p_Obstacle_tbl(I).OBSTACLE,
          p_OBSTACLE_STATUS  => p_Obstacle_tbl(I).OBSTACLE_STATUS,
          p_COMMENTS  => p_Obstacle_tbl(I).COMMENTS,
          p_ATTRIBUTE_CATEGORY  => p_Obstacle_tbl(I).ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_Obstacle_tbl(I).ATTRIBUTE1,
          p_ATTRIBUTE2  => p_Obstacle_tbl(I).ATTRIBUTE2,
          p_ATTRIBUTE3  => p_Obstacle_tbl(I).ATTRIBUTE3,
          p_ATTRIBUTE4  => p_Obstacle_tbl(I).ATTRIBUTE4,
          p_ATTRIBUTE5  => p_Obstacle_tbl(I).ATTRIBUTE5,
          p_ATTRIBUTE6  => p_Obstacle_tbl(I).ATTRIBUTE6,
          p_ATTRIBUTE7  => p_Obstacle_tbl(I).ATTRIBUTE7,
          p_ATTRIBUTE8  => p_Obstacle_tbl(I).ATTRIBUTE8,
          p_ATTRIBUTE9  => p_Obstacle_tbl(I).ATTRIBUTE9,
          p_ATTRIBUTE10  => p_Obstacle_tbl(I).ATTRIBUTE10,
          p_ATTRIBUTE11  => p_Obstacle_tbl(I).ATTRIBUTE11,
          p_ATTRIBUTE12  => p_Obstacle_tbl(I).ATTRIBUTE12,
          p_ATTRIBUTE13  => p_Obstacle_tbl(I).ATTRIBUTE13,
          p_ATTRIBUTE14  => p_Obstacle_tbl(I).ATTRIBUTE14,
          p_ATTRIBUTE15  => p_Obstacle_tbl(I).ATTRIBUTE15);
-- ?          p_SECURITY_GROUP_ID  => p_Obstacle_tbl(I).SECURITY_GROUP_ID);

      X_LEAD_OBSTACLE_out_tbl(I).LEAD_OBSTACLE_ID := p_Obstacle_tbl(I).LEAD_OBSTACLE_ID;
      X_LEAD_OBSTACLE_out_tbl(I).return_status := x_return_status;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
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
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_obstacle_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Obstacle_Rec      =>  P_Obstacle_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
	  WHEN DUP_VAL_ON_INDEX THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
              	  FND_MESSAGE.Set_Name('AS', 'API_DUP_ISSUES');
              	  FND_MSG_PUB.ADD;
              END IF;

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_obstacles;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_obstacles(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    p_partner_cont_party_id      IN  NUMBER  := FND_API.G_MISS_NUM,
    P_Obstacle_tbl               IN    AS_OPPORTUNITY_PUB.Obstacle_tbl_type,
    X_LEAD_OBSTACLE_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.obstacle_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_obstacles';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_Obstacle_rec            AS_OPPORTUNITY_PUB.Obstacle_Rec_Type;
l_access_profile_rec      AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
l_access_flag             VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lobpv.Delete_obstacles';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_OBSTACLES_PVT;

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
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_obstacle_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Obstacle_Rec      =>  P_Obstacle_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

      IF ( P_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
          p_profile_tbl         => p_profile_tbl,
          x_access_profile_rec  => l_access_profile_rec);

      IF( p_check_access_flag = 'Y' )
	 THEN
        AS_ACCESS_PUB.Has_updateOpportunityAccess(
              p_api_version_number     => 2.0
             ,p_init_msg_list          => p_init_msg_list
             ,p_validation_level       => p_validation_level
             ,p_access_profile_rec     => l_access_profile_rec
             ,p_admin_flag             => p_admin_flag
             ,p_admin_group_id         => p_admin_group_id
             ,p_person_id              => l_identity_sales_member_rec.employee_person_id
             ,p_opportunity_id         => P_Obstacle_tbl(1).LEAD_ID
             ,p_check_access_flag      => 'Y'
             ,p_identity_salesforce_id => p_identity_salesforce_id
             ,p_partner_cont_party_id  => NULL
             ,x_return_status          => x_return_status
             ,x_msg_count              => x_msg_count
             ,x_msg_data               => x_msg_data
             ,x_update_access_flag     => l_access_flag);
      END IF;

	 IF l_access_flag <> 'Y' THEN
		AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
		'API_NO_UPDATE_PRIVILEGE');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(AS_LEAD_OBSTACLES_PKG.Delete_Row)
    FOR I in 1 .. P_Obstacle_tbl.count LOOP

    X_LEAD_OBSTACLE_out_tbl(I).return_status := FND_API.G_RET_STS_SUCCESS;

     -- Progress Message
     --
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
     THEN
         FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
         FND_MESSAGE.Set_Token ('ROW', 'AS_OPP_OBSTACLE', TRUE);
         FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(I), FALSE);
         FND_MSG_PUB.Add;
     END IF;

    -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');
      END IF;


      AS_LEAD_OBSTACLES_PKG.Delete_Row(
          p_LEAD_OBSTACLE_ID  => p_Obstacle_tbl(I).LEAD_OBSTACLE_ID);

      X_LEAD_OBSTACLE_out_tbl(I).LEAD_OBSTACLE_ID := p_Obstacle_tbl(I).LEAD_OBSTACLE_ID;
      X_LEAD_OBSTACLE_out_tbl(I).return_status := x_return_status;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
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
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_obstacle_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Obstacle_Rec      =>  P_Obstacle_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_obstacles;




-- Item-level validation procedures
PROCEDURE Validate_LEAD_OBSTACLE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_OBSTACLE_ID           IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Lead_Obstacle_Id_Exists (c_Lead_Obstacle_Id NUMBER) IS
	 SELECT 'X'
	 FROM as_lead_obstacles
	 WHERE lead_Obstacle_id = c_Lead_Obstacle_Id;

  l_val   VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.lobpv.Validate_LEAD_OBSTACLE_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN

          IF (p_LEAD_OBSTACLE_ID is not NULL) and (p_LEAD_OBSTACLE_ID <> FND_API.G_MISS_NUM)
		THEN
		    OPEN C_Lead_Obstacle_Id_Exists (p_Lead_Obstacle_Id);
		    FETCH C_Lead_Obstacle_Id_Exists into l_val;

		    IF C_Lead_Obstacle_Id_Exists%FOUND THEN
			   AS_UTILITY_PVT.Set_Message(
				  p_module        => l_module,
				  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
				  p_msg_name      => 'API_DUPLICATE_LEAD_OBSTACLE_ID');

			   x_return_status := FND_API.G_RET_STS_ERROR;
		    END IF;

		    CLOSE C_Lead_Obstacle_Id_Exists;
		END IF;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN

		IF (p_LEAD_OBSTACLE_ID is NULL) or (p_LEAD_OBSTACLE_ID = FND_API.G_MISS_NUM)
		THEN
		    AS_UTILITY_PVT.Set_Message(
			   p_module        => l_module,
			   p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			   p_msg_name      => 'API_MISSING_LEAD_OBSTACLE_ID');

		    x_return_status := FND_API.G_RET_STS_ERROR;
		ELSE
		    OPEN  C_Lead_Obstacle_Id_Exists (p_Lead_Obstacle_Id);
		    FETCH C_Lead_Obstacle_Id_Exists into l_val;

		    IF C_Lead_Obstacle_Id_Exists%NOTFOUND
		    THEN
			   AS_UTILITY_PVT.Set_Message(
				  p_module        => l_module,
				  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
				  p_msg_name      => 'API_INVALID_LEAD_OBSTACLE_ID',
				  p_token1        => 'VALUE',
				  p_token1_value  => p_LEAD_OBSTACLE_ID );

			   x_return_status := FND_API.G_RET_STS_ERROR;
		    END IF;

		    CLOSE C_Lead_Obstacle_Id_Exists;
		END IF;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_OBSTACLE_ID;


PROCEDURE Validate_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_ID                    IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Lead_Id_Exists (c_Lead_Id NUMBER) IS
	 SELECT 'X'
	 FROM as_leads_all
	 WHERE lead_id = c_Lead_Id;

  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.lobpv.Validate_LEAD_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_LEAD_ID is NULL)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module,
		    'ERROR',
		    'Private obstacle API: -Violate NOT NULL constraint(LEAD_ID)');
	  END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF (p_LEAD_ID is NULL) or (p_LEAD_ID = FND_API.G_MISS_NUM)
	 THEN
		AS_UTILITY_PVT.Set_Message(
		    p_module        => l_module,
		    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		    p_msg_name      => 'API_MISSING_LEAD_ID');

		x_return_status := FND_API.G_RET_STS_ERROR;
	 ELSE
		OPEN  C_Lead_Id_Exists (p_Lead_Id);
		FETCH C_Lead_Id_Exists into l_val;

		IF C_Lead_Id_Exists%NOTFOUND
		THEN
		    AS_UTILITY_PVT.Set_Message(
			   p_module        => l_module,
			   p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			   p_msg_name      => 'API_INVALID_LEAD_ID',
			   p_token1        => 'VALUE',
			   p_token1_value  => p_LEAD_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		CLOSE C_Lead_Id_Exists;
	 END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_ID;


PROCEDURE Validate_OBSTACLE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OBSTACLE_CODE              IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_OBSTACLE_CODE_Exists (c_lookup_type VARCHAR2,
						  c_OBSTACLE_CODE VARCHAR2) IS
     SELECT  'X'
	FROM  as_lookups
	WHERE lookup_type = c_lookup_type
		 and lookup_code = c_OBSTACLE_CODE
		 and enabled_flag = 'Y';

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.lobpv.Validate_OBSTACLE_CODE';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_OBSTACLE_CODE is NOT NULL) and (p_OBSTACLE_CODE <> FND_API.G_MISS_CHAR)
      THEN
		-- OBSTACLE_CODE should exist in as_lookups
		OPEN  C_OBSTACLE_CODE_Exists ('ISSUE', p_OBSTACLE_CODE);
		FETCH C_OBSTACLE_CODE_Exists into l_val;

		IF C_OBSTACLE_CODE_Exists%NOTFOUND THEN
		    -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
		    --                     'Private API: OBSTACLE_CODE is invalid');

		    AS_UTILITY_PVT.Set_Message(
			   p_module        => l_module,
			   p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			   p_msg_name      => 'API_INVALID_OBSTACLE_CODE',
			   p_token1        => 'VALUE',
			   p_token1_value  => p_OBSTACLE_CODE );

		    x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		CLOSE C_OBSTACLE_CODE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OBSTACLE_CODE;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_Obstacle_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Obstacle_Rec               IN    AS_OPPORTUNITY_PUB.Obstacle_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lobpv.Validate_Obstacle_rec';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'API_INVALID_RECORD');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Obstacle_Rec;

PROCEDURE Validate_obstacle(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Obstacle_Rec               IN    AS_OPPORTUNITY_PUB.Obstacle_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_obstacle';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lobpv.Validate_obstacle';
 BEGIN

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_LEAD_OBSTACLE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_OBSTACLE_ID       => P_Obstacle_Rec.LEAD_OBSTACLE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LEAD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_ID                => P_Obstacle_Rec.LEAD_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OBSTACLE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBSTACLE_CODE          => P_Obstacle_Rec.OBSTACLE_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

	 /*
      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_Obstacle_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_Obstacle_Rec           =>    P_Obstacle_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;
	 */

	 /*
      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;
	 */

	 /*
      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;
	 */


      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;


END Validate_obstacle;

End AS_OPP_OBSTACLE_PVT;

/
