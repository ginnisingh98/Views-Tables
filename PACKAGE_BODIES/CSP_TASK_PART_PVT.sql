--------------------------------------------------------
--  DDL for Package Body CSP_TASK_PART_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_TASK_PART_PVT" as
/* $Header: cspvtapb.pls 115.4 2003/05/02 17:15:36 phegde noship $ */
-- Start of Comments
-- Package name     : CSP_TASK_PART_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_TASK_PART_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvtapb.pls';
-- Hint: Primary key needs to be returned.
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
l_return_status_full        VARCHAR2(1);
--l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_access_flag               VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_TASK_PART_PVT;
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Debug message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: Validate_task_part');
      -- Invoke validation procedures
      Validate_task_part(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => JTF_PLSQL_API.G_CREATE,
          P_TASK_PART_Rec  =>  P_TASK_PART_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
--        AS_ACCESS_PUB.Has_???Access(
--            p_api_version_number     => 2.0
--           ,p_init_msg_list          => p_init_msg_list
--           ,p_validation_level       => p_validation_level
--           ,p_profile_tbl            => p_profile_tbl
--           ,p_admin_flag             => p_admin_flag
--           ,p_admin_group_id         => p_admin_group_id
--           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
--           ,p_customer_id            =>
--           ,p_check_access_flag      => 'Y'
--           ,p_identity_salesforce_id => p_identity_salesforce_id
--           ,p_partner_cont_party_id  => NULL
--           ,x_return_status          => x_return_status
--           ,x_msg_count              => x_msg_count
--           ,x_msg_data               => x_msg_data
--           ,x_access_flag            => l_access_flag);
--          IF l_access_flag <> 'Y' THEN
--              JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
--                  'API_NO_CREATE_PRIVILEGE');
--          END IF;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
*/
      -- Hint: Add corresponding Master-Detail business logic here if necessary.
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Calling create table handler');
      -- Invoke table handler(CSP_TASK_PARTS_PKG.Insert_Row)
      CSP_TASK_PARTS_PKG.Insert_Row(
          px_TASK_PART_ID  => x_TASK_PART_ID,
          p_PRODUCT_TASK_ID  => p_TASK_PART_rec.PRODUCT_TASK_ID,
          p_INVENTORY_ITEM_ID  => p_TASK_PART_rec.INVENTORY_ITEM_ID,
          p_MANUAL_QUANTITY  => p_TASK_PART_rec.MANUAL_QUANTITY,
          p_MANUAL_PERCENTAGE  => p_TASK_PART_rec.MANUAL_PERCENTAGE,
          p_QUANTITY_USED  => p_TASK_PART_rec.QUANTITY_USED,
          p_ACTUAL_TIMES_USED  => p_TASK_PART_rec.ACTUAL_TIMES_USED,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE_CATEGORY  => p_TASK_PART_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_TASK_PART_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_TASK_PART_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_TASK_PART_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_TASK_PART_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_TASK_PART_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_TASK_PART_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_TASK_PART_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_TASK_PART_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_TASK_PART_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_TASK_PART_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_TASK_PART_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_TASK_PART_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_TASK_PART_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_TASK_PART_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_TASK_PART_rec.ATTRIBUTE15,
          p_PRIMARY_UOM_CODE  => p_TASK_PART_rec.PRIMARY_UOM_CODE,
          p_REVISION  => p_TASK_PART_rec.REVISION,
          p_START_DATE  => p_TASK_PART_rec.START_DATE,
          p_END_DATE  => p_TASK_PART_rec.END_DATE,
          p_ROLLUP_QUANTITY_USED  => p_TASK_PART_rec.ROLLUP_QUANTITY_USED,
          p_ROLLUP_TIMES_USED  => p_TASK_PART_rec.ROLLUP_TIMES_USED,
          p_SUBSTITUTE_ITEM => p_TASK_PART_rec.SUBSTITUTE_ITEM );
      -- Hint: Primary key should be returned.
      -- x_TASK_PART_ID := px_TASK_PART_ID;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: ' || l_api_name || 'end');
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
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
/*
Cursor C_Get_task_part(TASK_PART_ID Number) IS
    Select rowid,
           TASK_PART_ID,
           PRODUCT_TASK_ID,
           INVENTORY_ITEM_ID,
           MANUAL_QUANTITY,
           MANUAL_PERCENTAGE,
           QUANTITY_USED,
           ACTUAL_TIMES_USED,
           CALCULATED_QUANTITY,
           PART_PERCENTAGE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
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
           ATTRIBUTE15,
           PRIMARY_UOM_CODE,
           REVISION,
           START_DATE,
           END_DATE
    From  CSP_TASK_PARTS
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_task_part';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
--l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_TASK_PART_rec  CSP_task_part_PVT.TASK_PART_Rec_Type;
l_tar_TASK_PART_rec  CSP_task_part_PVT.TASK_PART_Rec_Type := P_TASK_PART_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_TASK_PART_PVT;
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- Api body
      --
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: - Open Cursor to Select');
/*
      Open C_Get_task_part( l_tar_TASK_PART_rec.TASK_PART_ID);
      Fetch C_Get_task_part into
               l_rowid,
               l_ref_TASK_PART_rec.TASK_PART_ID,
               l_ref_TASK_PART_rec.PRODUCT_TASK_ID,
               l_ref_TASK_PART_rec.INVENTORY_ITEM_ID,
               l_ref_TASK_PART_rec.MANUAL_QUANTITY,
               l_ref_TASK_PART_rec.MANUAL_PERCENTAGE,
               l_ref_TASK_PART_rec.QUANTITY_USED,
               l_ref_TASK_PART_rec.ACTUAL_TIMES_USED,
               l_ref_TASK_PART_rec.CALCULATED_QUANTITY,
               l_ref_TASK_PART_rec.PART_PERCENTAGE,
               l_ref_TASK_PART_rec.CREATED_BY,
               l_ref_TASK_PART_rec.CREATION_DATE,
               l_ref_TASK_PART_rec.LAST_UPDATED_BY,
               l_ref_TASK_PART_rec.LAST_UPDATE_DATE,
               l_ref_TASK_PART_rec.LAST_UPDATE_LOGIN,
               l_ref_TASK_PART_rec.ATTRIBUTE_CATEGORY,
               l_ref_TASK_PART_rec.ATTRIBUTE1,
               l_ref_TASK_PART_rec.ATTRIBUTE2,
               l_ref_TASK_PART_rec.ATTRIBUTE3,
               l_ref_TASK_PART_rec.ATTRIBUTE4,
               l_ref_TASK_PART_rec.ATTRIBUTE5,
               l_ref_TASK_PART_rec.ATTRIBUTE6,
               l_ref_TASK_PART_rec.ATTRIBUTE7,
               l_ref_TASK_PART_rec.ATTRIBUTE8,
               l_ref_TASK_PART_rec.ATTRIBUTE9,
               l_ref_TASK_PART_rec.ATTRIBUTE10,
               l_ref_TASK_PART_rec.ATTRIBUTE11,
               l_ref_TASK_PART_rec.ATTRIBUTE12,
               l_ref_TASK_PART_rec.ATTRIBUTE13,
               l_ref_TASK_PART_rec.ATTRIBUTE14,
               l_ref_TASK_PART_rec.ATTRIBUTE15,
               l_ref_TASK_PART_rec.PRIMARY_UOM_CODE,
               l_ref_TASK_PART_rec.REVISION,
               l_ref_TASK_PART_rec.START_DATE,
               l_ref_TASK_PART_rec.END_DATE;
       If ( C_Get_task_part%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'task_part', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_task_part;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: - Close Cursor');
       Close     C_Get_task_part;
      If (l_tar_TASK_PART_rec.last_update_date is NULL or
          l_tar_TASK_PART_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_TASK_PART_rec.last_update_date <> l_ref_TASK_PART_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'task_part', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/
      -- Debug message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: Validate_task_part');
      -- Invoke validation procedures
      Validate_task_part(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
          P_TASK_PART_Rec  =>  P_TASK_PART_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
--        AS_ACCESS_PUB.Has_???Access(
--            p_api_version_number     => 2.0
--           ,p_init_msg_list          => p_init_msg_list
--           ,p_validation_level       => p_validation_level
--           ,p_profile_tbl            => p_profile_tbl
--           ,p_admin_flag             => p_admin_flag
--           ,p_admin_group_id         => p_admin_group_id
--           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
--           ,p_customer_id            =>
--           ,p_check_access_flag      => 'Y'
--           ,p_identity_salesforce_id => p_identity_salesforce_id
--           ,p_partner_cont_party_id  => NULL
--           ,x_return_status          => x_return_status
--           ,x_msg_count              => x_msg_count
--           ,x_msg_data               => x_msg_data
--           ,x_access_flag            => l_access_flag);
--          IF l_access_flag <> 'Y' THEN
--              JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
--                  'API_NO_UPDATE_PRIVILEGE');
--          END IF;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
*/
      -- Hint: Add corresponding Master-Detail business logic here if necessary.
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Calling update table handler');
      -- Invoke table handler(CSP_TASK_PARTS_PKG.Update_Row)
      CSP_TASK_PARTS_PKG.Update_Row(
          p_TASK_PART_ID  => p_TASK_PART_rec.TASK_PART_ID,
          p_PRODUCT_TASK_ID  => p_TASK_PART_rec.PRODUCT_TASK_ID,
          p_INVENTORY_ITEM_ID  => p_TASK_PART_rec.INVENTORY_ITEM_ID,
          p_MANUAL_QUANTITY  => p_TASK_PART_rec.MANUAL_QUANTITY,
          p_MANUAL_PERCENTAGE  => p_TASK_PART_rec.MANUAL_PERCENTAGE,
          p_QUANTITY_USED  => p_TASK_PART_rec.QUANTITY_USED,
          p_ACTUAL_TIMES_USED  => p_TASK_PART_rec.ACTUAL_TIMES_USED,
          p_CREATED_BY     => FND_API.G_MISS_NUM,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE_CATEGORY  => p_TASK_PART_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_TASK_PART_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_TASK_PART_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_TASK_PART_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_TASK_PART_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_TASK_PART_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_TASK_PART_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_TASK_PART_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_TASK_PART_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_TASK_PART_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_TASK_PART_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_TASK_PART_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_TASK_PART_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_TASK_PART_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_TASK_PART_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_TASK_PART_rec.ATTRIBUTE15,
          p_PRIMARY_UOM_CODE  => p_TASK_PART_rec.PRIMARY_UOM_CODE,
          p_REVISION  => p_TASK_PART_rec.REVISION,
          p_START_DATE  => p_TASK_PART_rec.START_DATE,
          p_END_DATE  => p_TASK_PART_rec.END_DATE,
          p_ROLLUP_QUANTITY_USED  => p_TASK_PART_rec.ROLLUP_QUANTITY_USED,
          p_ROLLUP_TIMES_USED  => p_TASK_PART_rec.ROLLUP_TIMES_USED,
          p_SUBSTITUTE_ITEM => p_TASK_PART_rec.SUBSTITUTE_ITEM );

      --
      -- End of API body.
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: ' || l_api_name || 'end');
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
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
--l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_TASK_PART_PVT;
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- Api body
      --
/*
      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
--        AS_ACCESS_PUB.Has_???Access(
--            p_api_version_number     => 2.0
--           ,p_init_msg_list          => p_init_msg_list
--           ,p_validation_level       => p_validation_level
--           ,p_profile_tbl            => p_profile_tbl
--           ,p_admin_flag             => p_admin_flag
--           ,p_admin_group_id         => p_admin_group_id
--           ,p_person_id              => l_identity_sales_member_rec.employee_person_id
--           ,p_customer_id            =>
--           ,p_check_access_flag      => 'Y'
--           ,p_identity_salesforce_id => p_identity_salesforce_id
--           ,p_partner_cont_party_id  => NULL
--           ,x_return_status          => x_return_status
--           ,x_msg_count              => x_msg_count
--           ,x_msg_data               => x_msg_data
--           ,x_access_flag            => l_access_flag);
--          IF l_access_flag <> 'Y' THEN
--              JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
--                  'API_NO_DELETE_PRIVILEGE');
--          END IF;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
*/
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Calling delete table handler');
      -- Invoke table handler(CSP_TASK_PARTS_PKG.Delete_Row)
      CSP_TASK_PARTS_PKG.Delete_Row(
          p_TASK_PART_ID  => p_TASK_PART_rec.TASK_PART_ID);
      --
      -- End of API body
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: ' || l_api_name || 'end');
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_task_part;
-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_TASK_PART_Rec   IN  CSP_TASK_PART_PUB.TASK_PART_Rec_Type,
    p_cur_get_TASK_PART   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Define Columns Begins');
      -- define all columns for CSP_TASK_PARTS view
      dbms_sql.define_column(p_cur_get_TASK_PART, 1, P_TASK_PART_Rec.TASK_PART_ID);
      dbms_sql.define_column(p_cur_get_TASK_PART, 2, P_TASK_PART_Rec.PRODUCT_TASK_ID);
      dbms_sql.define_column(p_cur_get_TASK_PART, 3, P_TASK_PART_Rec.INVENTORY_ITEM_ID);
      dbms_sql.define_column(p_cur_get_TASK_PART, 4, P_TASK_PART_Rec.MANUAL_QUANTITY);
      dbms_sql.define_column(p_cur_get_TASK_PART, 5, P_TASK_PART_Rec.MANUAL_PERCENTAGE);
      dbms_sql.define_column(p_cur_get_TASK_PART, 6, P_TASK_PART_Rec.QUANTITY_USED);
      dbms_sql.define_column(p_cur_get_TASK_PART, 7, P_TASK_PART_Rec.ACTUAL_TIMES_USED);
      dbms_sql.define_column(p_cur_get_TASK_PART, 10, P_TASK_PART_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_TASK_PART, 11, P_TASK_PART_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 12, P_TASK_PART_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 13, P_TASK_PART_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 14, P_TASK_PART_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 15, P_TASK_PART_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 16, P_TASK_PART_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 17, P_TASK_PART_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 18, P_TASK_PART_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 19, P_TASK_PART_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 20, P_TASK_PART_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 21, P_TASK_PART_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 22, P_TASK_PART_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 23, P_TASK_PART_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 24, P_TASK_PART_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 25, P_TASK_PART_Rec.ATTRIBUTE15, 150);
      dbms_sql.define_column(p_cur_get_TASK_PART, 26, P_TASK_PART_Rec.PRIMARY_UOM_CODE, 3);
      dbms_sql.define_column(p_cur_get_TASK_PART, 27, P_TASK_PART_Rec.REVISION, 30);
      dbms_sql.define_column(p_cur_get_TASK_PART, 28, P_TASK_PART_Rec.START_DATE);
      dbms_sql.define_column(p_cur_get_TASK_PART, 29, P_TASK_PART_Rec.END_DATE);
      dbms_sql.define_column(p_cur_get_TASK_PART, 29, P_TASK_PART_Rec.ROLLUP_QUANTITY_USED);
      dbms_sql.define_column(p_cur_get_TASK_PART, 29, P_TASK_PART_Rec.ROLLUP_TIMES_USED);
      dbms_sql.define_column(p_cur_get_TASK_PART, 30, p_TASK_PART_Rec.SUBSTITUTE_ITEM );
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Define Columns Ends');
END Define_Columns;
-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_TASK_PART   IN   NUMBER,
    X_TASK_PART_Rec   OUT NOCOPY  CSP_TASK_PART_PUB.TASK_PART_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: Get Column Values Begins');
      -- get all column values for CSP_TASK_PARTS table
      dbms_sql.column_value(p_cur_get_TASK_PART, 1, X_TASK_PART_Rec.TASK_PART_ID);
      dbms_sql.column_value(p_cur_get_TASK_PART, 2, X_TASK_PART_Rec.PRODUCT_TASK_ID);
      dbms_sql.column_value(p_cur_get_TASK_PART, 3, X_TASK_PART_Rec.INVENTORY_ITEM_ID);
      dbms_sql.column_value(p_cur_get_TASK_PART, 4, X_TASK_PART_Rec.MANUAL_QUANTITY);
      dbms_sql.column_value(p_cur_get_TASK_PART, 5, X_TASK_PART_Rec.MANUAL_PERCENTAGE);
      dbms_sql.column_value(p_cur_get_TASK_PART, 6, X_TASK_PART_Rec.QUANTITY_USED);
      dbms_sql.column_value(p_cur_get_TASK_PART, 7, X_TASK_PART_Rec.ACTUAL_TIMES_USED);
      dbms_sql.column_value(p_cur_get_TASK_PART, 10, X_TASK_PART_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_TASK_PART, 11, X_TASK_PART_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_TASK_PART, 12, X_TASK_PART_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_TASK_PART, 13, X_TASK_PART_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_TASK_PART, 14, X_TASK_PART_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_TASK_PART, 15, X_TASK_PART_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_TASK_PART, 16, X_TASK_PART_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_TASK_PART, 17, X_TASK_PART_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_TASK_PART, 18, X_TASK_PART_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_TASK_PART, 19, X_TASK_PART_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_TASK_PART, 20, X_TASK_PART_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_TASK_PART, 21, X_TASK_PART_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_TASK_PART, 22, X_TASK_PART_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_TASK_PART, 23, X_TASK_PART_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_TASK_PART, 24, X_TASK_PART_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_TASK_PART, 25, X_TASK_PART_Rec.ATTRIBUTE15);
      dbms_sql.column_value(p_cur_get_TASK_PART, 26, X_TASK_PART_Rec.PRIMARY_UOM_CODE);
      dbms_sql.column_value(p_cur_get_TASK_PART, 27, X_TASK_PART_Rec.REVISION);
      dbms_sql.column_value(p_cur_get_TASK_PART, 28, X_TASK_PART_Rec.START_DATE);
      dbms_sql.column_value(p_cur_get_TASK_PART, 29, X_TASK_PART_Rec.END_DATE);
      dbms_sql.column_value(p_cur_get_TASK_PART, 29, X_TASK_PART_Rec.ROLLUP_QUANTITY_USED);
      dbms_sql.column_value(p_cur_get_TASK_PART, 29, X_TASK_PART_Rec.ROLLUP_TIMES_USED);
      dbms_sql.column_value(p_cur_get_TASK_PART, 30, X_TASK_PART_Rec.SUBSTITUTE_ITEM );

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: Get Column Values Ends');
END Get_Column_Values;
PROCEDURE Gen_TASK_PART_order_cl(
    p_order_by_rec   IN   CSP_TASK_PART_PUB.TASK_PART_sort_rec_type,
    x_order_by_cl    OUT NOCOPY  VARCHAR2,
    x_return_status  OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2
)
IS
l_order_by_cl        VARCHAR2(1000)   := NULL;
l_util_order_by_tbl  JTF_PLSQL_API.Util_order_by_tbl_type;
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: Generate Order by Begins');
      -- Hint: Developer should add more statements according to CSP_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Invoke JTF_PLSQL_API.Translate_OrderBy');
      JTF_PLSQL_API.Translate_OrderBy(
          p_api_version_number   =>   1.0
         ,p_init_msg_list        =>   FND_API.G_FALSE
         ,p_validation_level     =>   FND_API.G_VALID_LEVEL_FULL
         ,p_order_by_tbl         =>   l_util_order_by_tbl
         ,x_order_by_clause      =>   l_order_by_cl
         ,x_return_status        =>   x_return_status
         ,x_msg_count            =>   x_msg_count
         ,x_msg_data             =>   x_msg_data);
      IF(l_order_by_cl IS NOT NULL) THEN
          x_order_by_cl := 'order by' || l_order_by_cl;
      ELSE
          x_order_by_cl := NULL;
      END IF;
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: Generate Order by Ends');
END Gen_TASK_PART_order_cl;
-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_TASK_PART_Rec   IN   CSP_TASK_PART_PUB.TASK_PART_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_TASK_PART   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: Bind Variables Begins');
      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_TASK_PART_Rec.TASK_PART_ID IS NOT NULL) AND (P_TASK_PART_Rec.TASK_PART_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_TASK_PART, ':p_TASK_PART_ID', P_TASK_PART_Rec.TASK_PART_ID);
      END IF;
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP','Private API: Bind Variables Ends');
END Bind;
PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Generate Select Begins');
      x_select_cl := 'Select ' ||
                'CSP_TASK_PARTS.TASK_PART_ID,' ||
                'CSP_TASK_PARTS.PRODUCT_TASK_ID,' ||
                'CSP_TASK_PARTS.INVENTORY_ITEM_ID,' ||
                'CSP_TASK_PARTS.MANUAL_QUANTITY,' ||
                'CSP_TASK_PARTS.MANUAL_PERCENTAGE,' ||
                'CSP_TASK_PARTS.QUANTITY_USED,' ||
                'CSP_TASK_PARTS.ACTUAL_TIMES_USED,' ||
                'CSP_TASK_PARTS.CREATED_BY,' ||
                'CSP_TASK_PARTS.CREATION_DATE,' ||
                'CSP_TASK_PARTS.LAST_UPDATED_BY,' ||
                'CSP_TASK_PARTS.LAST_UPDATE_DATE,' ||
                'CSP_TASK_PARTS.LAST_UPDATE_LOGIN,' ||
                'CSP_TASK_PARTS.ATTRIBUTE_CATEGORY,' ||
                'CSP_TASK_PARTS.ATTRIBUTE1,' ||
                'CSP_TASK_PARTS.ATTRIBUTE2,' ||
                'CSP_TASK_PARTS.ATTRIBUTE3,' ||
                'CSP_TASK_PARTS.ATTRIBUTE4,' ||
                'CSP_TASK_PARTS.ATTRIBUTE5,' ||
                'CSP_TASK_PARTS.ATTRIBUTE6,' ||
                'CSP_TASK_PARTS.ATTRIBUTE7,' ||
                'CSP_TASK_PARTS.ATTRIBUTE8,' ||
                'CSP_TASK_PARTS.ATTRIBUTE9,' ||
                'CSP_TASK_PARTS.ATTRIBUTE10,' ||
                'CSP_TASK_PARTS.ATTRIBUTE11,' ||
                'CSP_TASK_PARTS.ATTRIBUTE12,' ||
                'CSP_TASK_PARTS.ATTRIBUTE13,' ||
                'CSP_TASK_PARTS.ATTRIBUTE14,' ||
                'CSP_TASK_PARTS.ATTRIBUTE15,' ||
                'CSP_TASK_PARTS.PRIMARY_UOM_CODE,' ||
                'CSP_TASK_PARTS.REVISION,' ||
                'CSP_TASK_PARTS.START_DATE,' ||
                'CSP_TASK_PARTS.END_DATE,' ||
                'from CSP_TASK_PARTS';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Generate Select Ends');
END Gen_Select;
PROCEDURE Gen_TASK_PART_Where(
    P_TASK_PART_Rec     IN   CSP_TASK_PART_PUB.TASK_PART_Rec_Type,
    x_TASK_PART_where   OUT NOCOPY   VARCHAR2
)
IS
-- cursors to check if wildcard values '%' and '_' have been passed
-- as item values
CURSOR c_chk_str1(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '%', 1, 1)
    FROM DUAL;
CURSOR c_chk_str2(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '_', 1, 1)
    FROM DUAL;
-- return values from cursors
str_csr1   NUMBER;
str_csr2   NUMBER;
l_operator VARCHAR2(10);
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Generate Where Begins');
      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.
      -- example for NUMBER datatype
      IF( (P_TASK_PART_Rec.TASK_PART_ID IS NOT NULL) AND (P_TASK_PART_Rec.TASK_PART_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_TASK_PART_where IS NULL) THEN
              x_TASK_PART_where := 'Where';
          ELSE
              x_TASK_PART_where := x_TASK_PART_where || ' AND ';
          END IF;
          x_TASK_PART_where := x_TASK_PART_where || 'P_TASK_PART_Rec.TASK_PART_ID = :p_TASK_PART_ID';
      END IF;
      -- example for DATE datatype
      IF( (P_TASK_PART_Rec.CREATION_DATE IS NOT NULL) AND (P_TASK_PART_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_TASK_PART_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;
          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_TASK_PART_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;
          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
          IF(x_TASK_PART_where IS NULL) THEN
              x_TASK_PART_where := 'Where ';
          ELSE
              x_TASK_PART_where := x_TASK_PART_where || ' AND ';
          END IF;
          x_TASK_PART_where := x_TASK_PART_where || 'P_TASK_PART_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;
      -- example for VARCHAR2 datatype
      IF( (P_TASK_PART_Rec.ATTRIBUTE_CATEGORY IS NOT NULL) AND (P_TASK_PART_Rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_TASK_PART_Rec.ATTRIBUTE_CATEGORY);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;
          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_TASK_PART_Rec.ATTRIBUTE_CATEGORY);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;
          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
          IF(x_TASK_PART_where IS NULL) THEN
              x_TASK_PART_where := 'Where ';
          ELSE
              x_TASK_PART_where := x_TASK_PART_where || ' AND ';
          END IF;
          x_TASK_PART_where := x_TASK_PART_where || 'P_TASK_PART_Rec.ATTRIBUTE_CATEGORY ' || l_operator || ' :p_ATTRIBUTE_CATEGORY';
      END IF;
      -- Add more IF statements for each column below
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: Generate Where Ends');
END Gen_TASK_PART_Where;

-- Item-level validation procedures
PROCEDURE Validate_TASK_PART_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_PART_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- validate NOT NULL column
      IF(p_TASK_PART_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR','CSP', 'Private task_part API: -Violate NOT NULL constraint(TASK_PART_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_PART_ID is not NULL and p_TASK_PART_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_PART_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_TASK_PART_ID;
PROCEDURE Validate_PRODUCT_TASK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRODUCT_TASK_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- validate NOT NULL column
      IF(p_PRODUCT_TASK_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR','CSP', 'Private task_part API: -Violate NOT NULL constraint(PRODUCT_TASK_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRODUCT_TASK_ID is not NULL and p_PRODUCT_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRODUCT_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_PRODUCT_TASK_ID;
PROCEDURE Validate_INVENTORY_ITEM_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INVENTORY_ITEM_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- validate NOT NULL column
      IF(p_INVENTORY_ITEM_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message('ERROR','CSP', 'Private task_part API: -Violate NOT NULL constraint(INVENTORY_ITEM_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_INVENTORY_ITEM_ID is not NULL and p_INVENTORY_ITEM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_INVENTORY_ITEM_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_INVENTORY_ITEM_ID;
PROCEDURE Validate_MANUAL_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MANUAL_QUANTITY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MANUAL_QUANTITY is not NULL and p_MANUAL_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MANUAL_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_MANUAL_QUANTITY;
PROCEDURE Validate_MANUAL_PERCENTAGE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MANUAL_PERCENTAGE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MANUAL_PERCENTAGE is not NULL and p_MANUAL_PERCENTAGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MANUAL_PERCENTAGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_MANUAL_PERCENTAGE;
PROCEDURE Validate_QUANTITY_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUANTITY_USED                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY_USED is not NULL and p_QUANTITY_USED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY_USED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_QUANTITY_USED;
PROCEDURE Validate_ACTUAL_TIMES_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ACTUAL_TIMES_USED                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ACTUAL_TIMES_USED is not NULL and p_ACTUAL_TIMES_USED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ACTUAL_TIMES_USED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ACTUAL_TIMES_USED;

PROCEDURE Validate_PRIMARY_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRIMARY_UOM_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRIMARY_UOM_CODE is not NULL and p_PRIMARY_UOM_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRIMARY_UOM_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_PRIMARY_UOM_CODE;
PROCEDURE Validate_REVISION (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REVISION                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REVISION is not NULL and p_REVISION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REVISION <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_REVISION;
PROCEDURE Validate_START_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_START_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_START_DATE is not NULL and p_START_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_START_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_START_DATE;
PROCEDURE Validate_END_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_END_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_END_DATE is not NULL and p_END_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_END_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_END_DATE;

PROCEDURE Validate_ROLLUP_QUANTITY_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ROLLUP_QUANTITY_USED                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ROLLUP_QUANTITY_USED is not NULL and p_ROLLUP_QUANTITY_USED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ROLLUP_QUANTITY_USED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ROLLUP_QUANTITY_USED;

PROCEDURE Validate_ROLLUP_TIMES_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ROLLUP_TIMES_USED          IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ROLLUP_TIMES_USED is not NULL and p_ROLLUP_TIMES_USED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ROLLUP_TIMES_USED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ROLLUP_TIMES_USED;

PROCEDURE Validate_SUBSTITUTE_ITEM (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SUBSTITUTE_ITEM          IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUBSTITUTE_ITEM is not NULL and p_SUBSTITUTE_ITEM <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUBSTITUTE_ITEM <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_SUBSTITUTE_ITEM;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_PLSQL_API.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_TASK_PART_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_PART_Rec     IN    TASK_PART_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'API_INVALID_RECORD');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_TASK_PART_Rec;
PROCEDURE Validate_task_part(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_PART_Rec     IN    TASK_PART_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_task_part';
 BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_TASK_PART_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_PART_ID   => P_TASK_PART_Rec.TASK_PART_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_PRODUCT_TASK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRODUCT_TASK_ID   => P_TASK_PART_Rec.PRODUCT_TASK_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_INVENTORY_ITEM_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_INVENTORY_ITEM_ID   => P_TASK_PART_Rec.INVENTORY_ITEM_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_MANUAL_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MANUAL_QUANTITY   => P_TASK_PART_Rec.MANUAL_QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_MANUAL_PERCENTAGE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MANUAL_PERCENTAGE   => P_TASK_PART_Rec.MANUAL_PERCENTAGE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_QUANTITY_USED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUANTITY_USED   => P_TASK_PART_Rec.QUANTITY_USED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_ACTUAL_TIMES_USED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ACTUAL_TIMES_USED   => P_TASK_PART_Rec.ACTUAL_TIMES_USED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRIMARY_UOM_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRIMARY_UOM_CODE   => P_TASK_PART_Rec.PRIMARY_UOM_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_REVISION(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REVISION   => P_TASK_PART_Rec.REVISION,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_START_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_START_DATE   => P_TASK_PART_Rec.START_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_END_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_END_DATE   => P_TASK_PART_Rec.END_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ROLLUP_QUANTITY_USED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ROLLUP_QUANTITY_USED   => P_TASK_PART_Rec.ROLLUP_QUANTITY_USED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_ROLLUP_TIMES_USED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ROLLUP_TIMES_USED   => P_TASK_PART_Rec.ROLLUP_TIMES_USED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_SUBSTITUTE_ITEM(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SUBSTITUTE_ITEM        => P_TASK_PART_Rec.SUBSTITUTE_ITEM,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_TASK_PART_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_TASK_PART_Rec          => P_TASK_PART_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;
      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'CSP', 'Private API: ' || l_api_name || 'end');
END Validate_task_part;
End CSP_TASK_PART_PVT;

/
