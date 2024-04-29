--------------------------------------------------------
--  DDL for Package Body CSP_TASK_PART_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_TASK_PART_PUB" AS
/* $Header: cspptapb.pls 115.3 2003/05/02 17:29:02 phegde noship $ */
-- Start of Comments
-- Package name     : CSP_TASK_PART_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_TASK_PART_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspptapb.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public TASK_PART record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private TASK_PARTrecord is returned for the private
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
PROCEDURE Convert_TASK_PART_Values(
         P_TASK_PART_Rec        IN   CSP_task_part_PUB.TASK_PART_Rec_Type,
         x_pvt_TASK_PART_rec    OUT NOCOPY   CSP_task_part_PVT.TASK_PART_Rec_Type
)
IS
-- Hint: Declare cursor and local variables
-- Example: CURSOR C_Get_Lookup_Code(X_Lookup_Type VARCHAR2, X_Meaning VARCHAR2) IS
--          SELECT lookup_code
--          FROM   as_lookups
--          WHERE  lookup_type = X_Lookup_Type and nls_upper(meaning) = nls_upper(X_Meaning);
l_any_errors       BOOLEAN   := FALSE;
BEGIN
  -- Hint: Add logic to process value-id verification for TASK_PART record.
  --       Value based parameters should be converted to their equivalent ids.
  --       Each value should resolve into one and only one id.
  --       If this condition is not satisfied, API must report an error and assign l_any_errors to TRUE.
  -- Example: Process Lead Source/Lead Source Code
  -- If(p_opp_rec.lead_source_code is NOT NULL and p_opp_rec.lead_source_code <> FND_API.G_MISS_CHAR)
  -- THEN
  --     p_pvt_opp_rec.lead_source_code := p_opp_rec.lead_source_code;
  --     IF(p_opp_rec.lead_source is NOT NULL and p_opp_rec.lead_source <> FND_API.G_MISS_CHAR)
  --     THEN
  --         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  --         THEN
  --             FND_MESSAGE.Set_Name('AS','API_ATTRIBUTE_IGNORED');
  --             FND_MESSAGE.Set_Token('COLUMN','LEAD_SOURCE',FALSE);
  --             FND_MSG_PUB.Add;
  --         END IF;
  --     END IF;
  -- ELSIF(p_opp_rec.lead_source is NOT NULL and p_opp_rec.lead_source <> FND_API.G_MISS_CHAR)
  -- THEN
  --     OPEN C_Get_Lookup_Code('LEAD_SOURCE', p_opp_rec.lead_source);
  --     FETCH C_Get_Lookup_Code INTO l_val;
  --     CLOSE C_Get_Lookup_Code;
  --     p_pvt_opp_rec.lead_source_code := l_val;
  --     IF(l_val IS NULL)
  --     THEN
  --         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
  --         THEN
  --             FND_MESSAGE.Set_Name('AS','API_ATTRIBUTE_CONVERSION_ERROR'
  --             FND_MESSAGE.Set_Token('COLUMN','LEAD_SOURCE', FALSE
  --             FND_MESSAGE.Set_Token('VALUE', p_opp_rec.lead_source, FALSE
  --             FND_MSG_PUB.Add;
  --         END IF;
  --         l_any_errors := TRUE;
  --     END IF;
  -- ELSE
  --     p_pvt_opp_rec.lead_source_code := NULL;
  -- END IF;


  -- Now copy the rest of the columns to the private record
  -- Hint: We provide copy all columns to the private record.
  --       Developer should delete those fields which are used by Value-Id conversion above
    -- Hint: Developer should remove some of the following statements because of inconsistent column name between table and view.
/*
    x_pvt_TASK_PART_rec.TASK_PART_ID := P_TASK_PART_Rec.TASK_PART_ID;
    x_pvt_TASK_PART_rec.PRODUCT_TASK_ID := P_TASK_PART_Rec.PRODUCT_TASK_ID;
    x_pvt_TASK_PART_rec.INVENTORY_ITEM_ID := P_TASK_PART_Rec.INVENTORY_ITEM_ID;
    x_pvt_TASK_PART_rec.MANUAL_QUANTITY := P_TASK_PART_Rec.MANUAL_QUANTITY;
    x_pvt_TASK_PART_rec.MANUAL_PERCENTAGE := P_TASK_PART_Rec.MANUAL_PERCENTAGE;
    x_pvt_TASK_PART_rec.QUANTITY_USED := P_TASK_PART_Rec.QUANTITY_USED;
    x_pvt_TASK_PART_rec.ACTUAL_TIMES_USED := P_TASK_PART_Rec.ACTUAL_TIMES_USED;
    x_pvt_TASK_PART_rec.CALCULATED_QUANTITY := P_TASK_PART_Rec.CALCULATED_QUANTITY;
    x_pvt_TASK_PART_rec.PART_PERCENTAGE := P_TASK_PART_Rec.PART_PERCENTAGE;
    x_pvt_TASK_PART_rec.CREATED_BY := P_TASK_PART_Rec.CREATED_BY;
    x_pvt_TASK_PART_rec.CREATION_DATE := P_TASK_PART_Rec.CREATION_DATE;
    x_pvt_TASK_PART_rec.LAST_UPDATED_BY := P_TASK_PART_Rec.LAST_UPDATED_BY;
    x_pvt_TASK_PART_rec.LAST_UPDATE_DATE := P_TASK_PART_Rec.LAST_UPDATE_DATE;
    x_pvt_TASK_PART_rec.LAST_UPDATE_LOGIN := P_TASK_PART_Rec.LAST_UPDATE_LOGIN;
    x_pvt_TASK_PART_rec.ATTRIBUTE_CATEGORY := P_TASK_PART_Rec.ATTRIBUTE_CATEGORY;
    x_pvt_TASK_PART_rec.ATTRIBUTE1 := P_TASK_PART_Rec.ATTRIBUTE1;
    x_pvt_TASK_PART_rec.ATTRIBUTE2 := P_TASK_PART_Rec.ATTRIBUTE2;
    x_pvt_TASK_PART_rec.ATTRIBUTE3 := P_TASK_PART_Rec.ATTRIBUTE3;
    x_pvt_TASK_PART_rec.ATTRIBUTE4 := P_TASK_PART_Rec.ATTRIBUTE4;
    x_pvt_TASK_PART_rec.ATTRIBUTE5 := P_TASK_PART_Rec.ATTRIBUTE5;
    x_pvt_TASK_PART_rec.ATTRIBUTE6 := P_TASK_PART_Rec.ATTRIBUTE6;
    x_pvt_TASK_PART_rec.ATTRIBUTE7 := P_TASK_PART_Rec.ATTRIBUTE7;
    x_pvt_TASK_PART_rec.ATTRIBUTE8 := P_TASK_PART_Rec.ATTRIBUTE8;
    x_pvt_TASK_PART_rec.ATTRIBUTE9 := P_TASK_PART_Rec.ATTRIBUTE9;
    x_pvt_TASK_PART_rec.ATTRIBUTE10 := P_TASK_PART_Rec.ATTRIBUTE10;
    x_pvt_TASK_PART_rec.ATTRIBUTE11 := P_TASK_PART_Rec.ATTRIBUTE11;
    x_pvt_TASK_PART_rec.ATTRIBUTE12 := P_TASK_PART_Rec.ATTRIBUTE12;
    x_pvt_TASK_PART_rec.ATTRIBUTE13 := P_TASK_PART_Rec.ATTRIBUTE13;
    x_pvt_TASK_PART_rec.ATTRIBUTE14 := P_TASK_PART_Rec.ATTRIBUTE14;
    x_pvt_TASK_PART_rec.ATTRIBUTE15 := P_TASK_PART_Rec.ATTRIBUTE15;
    x_pvt_TASK_PART_rec.PRIMARY_UOM_CODE := P_TASK_PART_Rec.PRIMARY_UOM_CODE;
    x_pvt_TASK_PART_rec.REVISION := P_TASK_PART_Rec.REVISION;
    x_pvt_TASK_PART_rec.START_DATE := P_TASK_PART_Rec.START_DATE;
    x_pvt_TASK_PART_rec.END_DATE := P_TASK_PART_Rec.END_DATE;

*/
  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;


END Convert_TASK_PART_Values;

PROCEDURE Create_task_part(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_TASK_PART_Rec     IN    TASK_PART_Rec_Type  := G_MISS_TASK_PART_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_TASK_PART_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_task_part';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_TASK_PART_rec    CSP_TASK_PART_PVT.TASK_PART_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_TASK_PART_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP','Public API: ' || l_api_name || 'start');

      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP','Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','AS: Public API: Convert_TASK_PART_Values_To_Ids');

      -- Convert the values to ids
      --
      --      Convert_TASK_PART_Values_To_Ids (
      --           p_TASK_PART_rec       =>  p_TASK_PART_rec,
      --           x_pvt_TASK_PART_rec   =>  l_pvt_TASK_PART_rec
      --           );


-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Create_task_part','B','C'))
      THEN
          AS_task_part_CUHK.Create_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Create_task_part','B','V'))
      THEN
          AS_task_part_VUHK.Create_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
    -- Calling Private package: Create_TASK_PART
    -- Hint: Primary key needs to be returned
      CSP_task_part_PVT.Create_task_part(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => P_Validation_Level,
      P_TASK_PART_Rec  =>  l_pvt_TASK_PART_Rec ,
    -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
      X_TASK_PART_ID     => x_TASK_PART_ID,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP','Public API: ' || l_api_name || 'end');

      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP','End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOK standard : vertical industry post-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Create_task_part','A','V'))
      THEN
          AS_task_part_VUHK.Create_task_part_Post(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Create_task_part','A','C'))
      THEN
          AS_task_part_CUHK.Create_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
End Create_task_part;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_task_part(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_TASK_PART_Rec     IN    TASK_PART_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_task_part';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_TASK_PART_rec  CSP_TASK_PART_PVT.TASK_PART_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_TASK_PART_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP','Public API: ' || l_api_name || 'start');

      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP','Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','AS: Public API: Convert_TASK_PART_Values_To_Ids');

      -- Convert the values to ids
      --
/*      Convert_TASK_PART_Values_To_Ids (
            p_TASK_PART_rec       =>  p_TASK_PART_rec,
            x_pvt_TASK_PART_rec   =>  l_pvt_TASK_PART_rec
      );
*/

-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Update_task_part','B','C'))
      THEN
          AS_task_part_CUHK.Update_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Update_task_part','B','V'))
      THEN
          AS_task_part_VUHK.Update_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
    CSP_task_part_PVT.Update_task_part(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => P_Validation_Level,
    P_TASK_PART_Rec  =>  l_pvt_TASK_PART_Rec ,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Public API: ' || l_api_name || 'end');

      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOK standard : vertical industry post-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Update_task_part','A','V'))
      THEN
          AS_task_part_VUHK.Update_task_part_Post(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Update_task_part','A','C'))
      THEN
          AS_task_part_CUHK.Update_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
End Update_task_part;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_task_part(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_TASK_PART_Rec     IN TASK_PART_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_task_part';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_TASK_PART_rec  CSP_TASK_PART_PVT.TASK_PART_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_TASK_PART_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Public API: ' || l_api_name || 'start');

      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','AS: Public API: Convert_TASK_PART_Values_To_Ids');

      -- Convert the values to ids
      --
/*      Convert_TASK_PART_Values_To_Ids (
            p_TASK_PART_rec       =>  p_TASK_PART_rec,
            x_pvt_TASK_PART_rec   =>  l_pvt_TASK_PART_rec
      );
*/
    CSP_task_part_PVT.Delete_task_part(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => p_Validation_Level,
    P_TASK_PART_Rec  => l_pvt_TASK_PART_Rec,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);

-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOKS standard : customer pre-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Delete_task_part','B','C'))
      THEN
          AS_task_part_CUHK.Delete_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Delete_task_part','B','V'))
      THEN
          AS_task_part_VUHK.Delete_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Public API: ' || l_api_name || 'end');

      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP','End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when user hooks is ready.
/*
      -- USER HOOK standard : vertical industry post-processing section - mandatory
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Delete_task_part','A','V'))
      THEN
          AS_task_part_VUHK.Delete_task_part_Post(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
      IF(JTF_USR_HKS.Ok_to_execute('AS_task_part_PUB', 'Delete_task_part','A','C'))
      THEN
          AS_task_part_CUHK.Delete_task_part_Pre(
                  p_api_version_number   =>  1.0,
                  p_validation_level     =>  p_validation_level,
                  p_commit               =>  FND_API.G_FALSE,
                  p_profile_tbl          =>  p_profile_tbl,
                  p_check_access_flag    =>  p_check_access_flag,
                  p_admin_flag           =>  p_admin_flag,
                  p_admin_group_id       =>  p_admin_group_id,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_TASK_PART_Rec      =>  P_TASK_PART_Rec,
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
End Delete_task_part;


PROCEDURE Get_task_part(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_TASK_PART_Rec     IN    CSP_task_part_PUB.TASK_PART_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   CSP_task_part_PUB.TASK_PART_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_TASK_PART_Tbl  OUT NOCOPY  CSP_task_part_PUB.TASK_PART_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_task_part';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_TASK_PART_PUB;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Public API: ' || l_api_name || 'start');

      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Public API: - Calling PVT.Get_TASK_PART');
/*
    CSP_task_part_PVT.Get_task_part(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    p_validation_level           => p_validation_level,
    P_TASK_PART_Rec  =>  P_TASK_PART_Rec,
    p_rec_requested              => p_rec_requested,
    p_start_rec_prt              => p_start_rec_prt,
    p_return_tot_count           => p_return_tot_count,
  -- Hint: user defined record type
    p_order_by_rec               => p_order_by_rec,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data,
    X_TASK_PART_Tbl  => X_TASK_PART_Tbl,
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

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Public API: ' || l_api_name || 'end');

      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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
End Get_task_part;


End CSP_TASK_PART_PUB;

/
