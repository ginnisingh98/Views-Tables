--------------------------------------------------------
--  DDL for Package Body AML_TIMEFRAME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_TIMEFRAME_PUB" as
/* $Header: amlptfrb.pls 115.3 2002/12/05 00:26:43 ckapoor noship $ */
-- Start of Comments
-- Package name     : AML_TIMEFRAME_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AML_TIMEFRAME_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlptfrb.pls';




AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Create_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN    timeframe_Rec_Type  ,
    X_TIMEFRAME_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_timeframe';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_timeframe_rec    AML_TIMEFRAME_PUB.timeframe_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_TIMEFRAME_PUB;

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

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

l_pvt_timeframe_rec := p_timeframe_rec;


    -- Calling Private package: Create_TIMEFRAME
    -- Hint: Primary key needs to be returned
      AML_timeframe_PVT.Create_timeframe(
          P_Api_Version_Number         => 2.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          P_Validation_Level           => P_Validation_Level,
          P_Check_Access_Flag          => P_Check_Access_Flag,
          P_Admin_Flag                 => P_Admin_Flag,
          P_Admin_Group_Id             => P_Admin_Group_Id,
          P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
          P_Profile_Tbl                => P_Profile_tbl,
          P_timeframe_Rec  =>  l_pvt_timeframe_Rec ,
        -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
          X_TIMEFRAME_ID     => x_TIMEFRAME_ID,
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
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
End Create_timeframe;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN    timeframe_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_timeframe';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_timeframe_rec  AML_TIMEFRAME_PUB.timeframe_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_TIMEFRAME_PUB;

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

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
l_pvt_timeframe_rec := p_timeframe_rec;


    AML_timeframe_PVT.Update_timeframe(
        P_Api_Version_Number         => 2.0,
        P_Init_Msg_List              => FND_API.G_FALSE,
        P_Commit                     => p_commit,
        P_Validation_Level           => P_Validation_Level,
        P_Check_Access_Flag          => P_Check_Access_Flag,
        P_Admin_Flag                 => P_Admin_Flag,
        P_Admin_Group_Id             => P_Admin_Group_Id,
        P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
        P_Profile_Tbl                => P_Profile_tbl,
        P_timeframe_Rec  =>  l_pvt_timeframe_Rec ,
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
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOK standard : vertical industry post-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_timeframe_PUB', 'Update_timeframe','A','V'))
      THEN
          AS_timeframe_VUHK.Update_timeframe_Post(
                  p_api_version_number   =>  2.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_timeframe_Rec      =>  P_timeframe_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
          ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_timeframe_PUB', 'Update_timeframe','A','C'))
      THEN
          AS_timeframe_CUHK.Update_timeframe_Pre(
                  p_api_version_number   =>  2.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_timeframe_Rec      =>  P_timeframe_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
          ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;
*/
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
End Update_timeframe;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_Profile_Tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN timeframe_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_timeframe';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_pvt_timeframe_rec  AML_TIMEFRAME_PUB.timeframe_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_TIMEFRAME_PUB;

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

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

l_pvt_timeframe_rec := p_timeframe_rec;

    AML_timeframe_PVT.Delete_timeframe(
        P_Api_Version_Number         => 2.0,
        P_Init_Msg_List              => FND_API.G_FALSE,
        P_Commit                     => p_commit,
        P_Validation_Level           => p_Validation_Level,
        P_Check_Access_Flag          => P_Check_Access_Flag,
        P_Admin_Flag                 => P_Admin_Flag,
        P_Admin_Group_Id             => P_Admin_Group_Id,
        P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
        P_Profile_Tbl                => P_Profile_tbl,
        P_timeframe_Rec  => l_pvt_timeframe_Rec,
        X_Return_Status              => x_return_status,
        X_Msg_Count                  => x_msg_count,
        X_Msg_Data                   => x_msg_data);

-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_timeframe_PUB', 'Delete_timeframe','B','C'))
      THEN
          AS_timeframe_CUHK.Delete_timeframe_Pre(
                  p_api_version_number   =>  2.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_timeframe_Rec      =>  P_timeframe_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
          ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;
      -- USER HOOKS standard : vertical industry pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_timeframe_PUB', 'Delete_timeframe','B','V'))
      THEN
          AS_timeframe_VUHK.Delete_timeframe_Pre(
                  p_api_version_number   =>  2.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_timeframe_Rec      =>  P_timeframe_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
          ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END IF;
*/



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
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOK standard : vertical industry post-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_timeframe_PUB', 'Delete_timeframe','A','V'))
      THEN
          AS_timeframe_VUHK.Delete_timeframe_Post(
                  p_api_version_number   =>  2.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_timeframe_Rec      =>  P_timeframe_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
          ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_timeframe_PUB', 'Delete_timeframe','A','C'))
      THEN
          AS_timeframe_CUHK.Delete_timeframe_Pre(
                  p_api_version_number   =>  2.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_timeframe_Rec      =>  P_timeframe_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
          ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END IF;
*/
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
End Delete_timeframe;


/*
PROCEDURE Get_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_id             IN   NUMBER,
    P_identity_salesforce_id     IN   NUMBER     := NULL,
    P_timeframe_Rec     IN    timeframe_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   AML_timeframe_PUB.timeframe_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_timeframe_Tbl  OUT NOCOPY  AML_timeframe_PUB.timeframe_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_timeframe';
l_api_version_number      CONSTANT NUMBER   := 2.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_TIMEFRAME_PUB;

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

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'start');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Public API: - Calling PVT.Get_TIMEFRAME');
      END IF;
    AML_timeframe_PVT.Get_timeframe(
        P_Api_Version_Number         => 2.0,
        P_Init_Msg_List              => FND_API.G_FALSE,
        p_validation_level           => p_validation_level,
        P_Identity_Salesforce_id     => p_identity_salesforce_id,
        P_timeframe_Rec  =>  P_timeframe_Rec,
        p_rec_requested              => p_rec_requested,
        p_start_rec_prt              => p_start_rec_prt,
        p_return_tot_count           => p_return_tot_count,
      -- Hint: user defined record type
        p_order_by_rec               => p_order_by_rec,
        X_Return_Status              => x_return_status,
        X_Msg_Count                  => x_msg_count,
        X_Msg_Data                   => x_msg_data,
        X_timeframe_Tbl  => X_timeframe_Tbl,
        x_returned_rec_count         => x_returned_rec_count,
        x_next_rec_ptr               => x_next_rec_ptr,
        x_tot_rec_count              => x_tot_rec_count
        -- other optional parameters
        -- x_tot_rec_amount             => x_tot_rec_amount
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

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
End Get_timeframe;

*/
End AML_TIMEFRAME_PUB;

/
