--------------------------------------------------------
--  DDL for Package Body CSP_PRODUCT_TASK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PRODUCT_TASK_PUB" as
/* $Header: csppptab.pls 115.3 2003/05/02 17:24:25 phegde noship $ */
-- Start of Comments
-- Package name     : CSP_PRODUCT_TASK_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PRODUCT_TASK_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csppptab.pls';
-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public PRODUCT_TASK record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private PRODUCT_TASKrecord is returned for the private
-- API call.
--
-- Conversions:
--
-- Notes
--
-- 1. IDs take precedence over values. If both are present for a field, ID is used,
--    the value based parameter is ignored and a warning message is created.
-- 2. This is automatically generated procedure, it converts public record type to
--    private record type for all attributes.
--    Developer must manually add conversion logic to the attributes.
--
-- End of Comments
PROCEDURE Create_product_task(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_PROD_TASK_Rec     IN    PROD_TASK_Rec_Type  := G_MISS_PROD_TASK_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_PRODUCT_TASK_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_product_task';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_PROD_TASK_rec    CSP_PRODUCT_TASK_PVT.PROD_TASK_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PRODUCT_TASK_PUB;
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
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Create_product_task','B','C'))
      THEN
          AS_product_task_CUHK.Create_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Create_product_task','B','V'))
      THEN
          AS_product_task_VUHK.Create_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
    -- Calling Private package: Create_PRODUCT_TASK
    -- Hint: Primary key needs to be returned
      CSP_product_task_PVT.Create_product_task(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => P_Validation_Level,
      P_PROD_TASK_Rec  =>  l_pvt_PROD_TASK_Rec ,
    -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
      X_PRODUCT_TASK_ID     => x_PRODUCT_TASK_ID,
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
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOK standard : vertical industry post-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Create_product_task','A','V'))
      THEN
          AS_product_task_VUHK.Create_product_task_Post(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Create_product_task','A','C'))
      THEN
          AS_product_task_CUHK.Create_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_product_task;
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_product_task(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_PROD_TASK_Rec     IN    PROD_TASK_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_product_task';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_PROD_TASK_rec  CSP_PRODUCT_TASK_PVT.PROD_TASK_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PRODUCT_TASK_PUB;
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
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Update_product_task','B','C'))
      THEN
          AS_product_task_CUHK.Update_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Update_product_task','B','V'))
      THEN
          AS_product_task_VUHK.Update_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
    CSP_product_task_PVT.Update_product_task(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_PROD_TASK_Rec  =>  l_pvt_PROD_TASK_Rec ,
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
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOK standard : vertical industry post-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Update_product_task','A','V'))
      THEN
          AS_product_task_VUHK.Update_product_task_Post(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Update_product_task','A','C'))
      THEN
          AS_product_task_CUHK.Update_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_product_task;
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_product_task(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_PROD_TASK_Rec     IN PROD_TASK_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_product_task';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_PROD_TASK_rec  CSP_PRODUCT_TASK_PVT.PROD_TASK_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PRODUCT_TASK_PUB;
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
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
    CSP_product_task_PVT.Delete_product_task(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => p_Validation_Level,
    P_PROD_TASK_Rec  => l_pvt_PROD_TASK_Rec,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);
-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Delete_product_task','B','C'))
      THEN
          AS_product_task_CUHK.Delete_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Delete_product_task','B','V'))
      THEN
          AS_product_task_VUHK.Delete_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOK standard : vertical industry post-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Delete_product_task','A','V'))
      THEN
          AS_product_task_VUHK.Delete_product_task_Post(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_product_task_PUB', 'Delete_product_task','A','C'))
      THEN
          AS_product_task_CUHK.Delete_product_task_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PROD_TASK_Rec      =>  P_PROD_TASK_Rec,
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
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_product_task;
PROCEDURE Get_product_task(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_PROD_TASK_Rec     IN    CSP_product_task_PUB.PROD_TASK_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   CSP_product_task_PUB.PROD_TASK_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_PROD_TASK_Tbl  OUT NOCOPY  CSP_product_task_PUB.PROD_TASK_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY  NUMBER
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_product_task';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_PRODUCT_TASK_PUB;
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
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
/*    CSP_product_task_PVT.Get_product_task(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    p_validation_level           => p_validation_level,
    P_PROD_TASK_Rec  =>  P_PROD_TASK_Rec,
    p_rec_requested              => p_rec_requested,
    p_start_rec_prt              => p_start_rec_prt,
    p_return_tot_count           => p_return_tot_count,
  -- Hint: user defined record type
    p_order_by_rec               => p_order_by_rec,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data,
    X_PROD_TASK_Tbl  => X_PROD_TASK_Tbl,
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
*/
      --
      -- End of API body
      --
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Get_product_task;
End CSP_PRODUCT_TASK_PUB;

/
