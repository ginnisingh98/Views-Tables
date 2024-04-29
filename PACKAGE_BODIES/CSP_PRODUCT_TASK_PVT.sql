--------------------------------------------------------
--  DDL for Package Body CSP_PRODUCT_TASK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PRODUCT_TASK_PVT" as
/* $Header: cspvptab.pls 115.3 2003/05/02 00:25:32 phegde noship $ */
-- Start of Comments
-- Package name     : CSP_PRODUCT_TASK_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PRODUCT_TASK_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvptab.pls';
-- Hint: Primary key needs to be returned.
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
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PRODUCT_TASK_PVT;
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
      -- Invoke validation procedures
      Validate_product_task(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => JTF_PLSQL_API.G_CREATE,
          P_PROD_TASK_Rec  =>  P_PROD_TASK_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Invoke table handler(CSP_PRODUCT_TASKS_PKG.Insert_Row)
      CSP_PRODUCT_TASKS_PKG.Insert_Row(
          px_PRODUCT_TASK_ID  => x_PRODUCT_TASK_ID,
          p_PRODUCT_ID  => p_PROD_TASK_rec.PRODUCT_ID,
          p_TASK_TEMPLATE_ID  => p_PROD_TASK_rec.TASK_TEMPLATE_ID,
          p_AUTO_MANUAL  => p_PROD_TASK_rec.AUTO_MANUAL,
          p_ACTUAL_TIMES_USED  => p_PROD_TASK_rec.ACTUAL_TIMES_USED,
          p_TASK_PERCENTAGE  => p_PROD_TASK_rec.TASK_PERCENTAGE,
          p_ATTRIBUTE_CATEGORY  => p_PROD_TASK_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_PROD_TASK_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_PROD_TASK_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_PROD_TASK_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_PROD_TASK_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_PROD_TASK_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_PROD_TASK_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_PROD_TASK_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_PROD_TASK_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_PROD_TASK_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_PROD_TASK_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_PROD_TASK_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_PROD_TASK_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_PROD_TASK_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_PROD_TASK_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_PROD_TASK_rec.ATTRIBUTE15,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_PROD_TASK_rec.LAST_UPDATE_LOGIN);
      -- Hint: Primary key should be returned.
      -- x_PRODUCT_TASK_ID := px_PRODUCT_TASK_ID;
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
End Create_product_task;
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_product_task(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_PROD_TASK_Rec              IN   PROD_TASK_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS

Cursor C_Get_product_task(L_PRODUCT_TASK_ID Number) IS
    Select rowid,
           PRODUCT_TASK_ID,
           PRODUCT_ID,
           TASK_TEMPLATE_ID,
           AUTO_MANUAL,
           ACTUAL_TIMES_USED,
           TASK_PERCENTAGE,
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
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
    From  CSP_PRODUCT_TASKS
    WHERE PRODUCT_TASK_ID = L_PRODUCT_TASK_ID
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_product_task';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_ref_PROD_TASK_rec  CSP_product_task_PVT.PROD_TASK_Rec_Type;
l_tar_PROD_TASK_rec  CSP_product_task_PVT.PROD_TASK_Rec_Type := P_PROD_TASK_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PRODUCT_TASK_PVT;
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
      -- Api body
      --
/*
      Open C_Get_product_task( l_tar_PROD_TASK_rec.PRODUCT_TASK_ID);
      Fetch C_Get_product_task into
               l_rowid,
               l_ref_PROD_TASK_rec.PRODUCT_TASK_ID,
               l_ref_PROD_TASK_rec.PRODUCT_ID,
               l_ref_PROD_TASK_rec.TASK_TEMPLATE_ID,
               l_ref_PROD_TASK_rec.AUTO_MANUAL,
               l_ref_PROD_TASK_rec.ACTUAL_TIMES_USED,
               l_ref_PROD_TASK_rec.TASK_PERCENTAGE,
               l_ref_PROD_TASK_rec.ATTRIBUTE_CATEGORY,
               l_ref_PROD_TASK_rec.ATTRIBUTE1,
               l_ref_PROD_TASK_rec.ATTRIBUTE2,
               l_ref_PROD_TASK_rec.ATTRIBUTE3,
               l_ref_PROD_TASK_rec.ATTRIBUTE4,
               l_ref_PROD_TASK_rec.ATTRIBUTE5,
               l_ref_PROD_TASK_rec.ATTRIBUTE6,
               l_ref_PROD_TASK_rec.ATTRIBUTE7,
               l_ref_PROD_TASK_rec.ATTRIBUTE8,
               l_ref_PROD_TASK_rec.ATTRIBUTE9,
               l_ref_PROD_TASK_rec.ATTRIBUTE10,
               l_ref_PROD_TASK_rec.ATTRIBUTE11,
               l_ref_PROD_TASK_rec.ATTRIBUTE12,
               l_ref_PROD_TASK_rec.ATTRIBUTE13,
               l_ref_PROD_TASK_rec.ATTRIBUTE14,
               l_ref_PROD_TASK_rec.ATTRIBUTE15,
               l_ref_PROD_TASK_rec.CREATED_BY,
               l_ref_PROD_TASK_rec.CREATION_DATE,
               l_ref_PROD_TASK_rec.LAST_UPDATED_BY,
               l_ref_PROD_TASK_rec.LAST_UPDATE_DATE,
               l_ref_PROD_TASK_rec.LAST_UPDATE_LOGIN;

       If ( C_Get_product_task%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'product_task', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_product_task;
           raise FND_API.G_EXC_ERROR;
       END IF;
       Close     C_Get_product_task;

      If (l_tar_PROD_TASK_rec.last_update_date is NULL or
          l_tar_PROD_TASK_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
          DBMS_OUTPUT.PUT_LINE('UPDATE DATE2 '||l_tar_PROD_TASK_rec.last_update_date);
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_PROD_TASK_rec.last_update_date <> l_ref_PROD_TASK_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'product_task', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

*/

      -- Invoke validation procedures
      Validate_product_task(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
          P_PROD_TASK_Rec  =>  P_PROD_TASK_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Hint: Add corresponding Master-Detail business logic here if necessary.
      -- Invoke table handler(CSP_PRODUCT_TASKS_PKG.Update_Row)

      CSP_PRODUCT_TASKS_PKG.Update_Row(
          p_PRODUCT_TASK_ID  => p_PROD_TASK_rec.PRODUCT_TASK_ID,
          p_PRODUCT_ID  => p_PROD_TASK_rec.PRODUCT_ID,
          p_TASK_TEMPLATE_ID  => p_PROD_TASK_rec.TASK_TEMPLATE_ID,
          p_AUTO_MANUAL  => p_PROD_TASK_rec.AUTO_MANUAL,
          p_ACTUAL_TIMES_USED  => p_PROD_TASK_rec.ACTUAL_TIMES_USED,
          p_TASK_PERCENTAGE  => p_PROD_TASK_rec.TASK_PERCENTAGE,
          p_ATTRIBUTE_CATEGORY  => p_PROD_TASK_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_PROD_TASK_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_PROD_TASK_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_PROD_TASK_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_PROD_TASK_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_PROD_TASK_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_PROD_TASK_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_PROD_TASK_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_PROD_TASK_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_PROD_TASK_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_PROD_TASK_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_PROD_TASK_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_PROD_TASK_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_PROD_TASK_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_PROD_TASK_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_PROD_TASK_rec.ATTRIBUTE15,
          p_CREATED_BY     => FND_API.G_MISS_NUM,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_PROD_TASK_rec.LAST_UPDATE_LOGIN);

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
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PRODUCT_TASK_PVT;
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
      -- Api body
      --
      -- Invoke table handler(CSP_PRODUCT_TASKS_PKG.Delete_Row)
      CSP_PRODUCT_TASKS_PKG.Delete_Row(
          p_PRODUCT_TASK_ID  => p_PROD_TASK_rec.PRODUCT_TASK_ID);
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
End Delete_product_task;
-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_PROD_TASK_Rec   IN  CSP_PRODUCT_TASK_PUB.PROD_TASK_Rec_Type,
    p_cur_get_PROD_TASK   IN   NUMBER
)
IS
BEGIN
      -- define all columns for CSP_PRODUCT_TASKS view
      dbms_sql.define_column(p_cur_get_PROD_TASK, 1, P_PROD_TASK_Rec.PRODUCT_TASK_ID);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 2, P_PROD_TASK_Rec.PRODUCT_ID);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 3, P_PROD_TASK_Rec.TASK_TEMPLATE_ID);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 4, P_PROD_TASK_Rec.AUTO_MANUAL, 6);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 5, P_PROD_TASK_Rec.ACTUAL_TIMES_USED);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 6, P_PROD_TASK_Rec.TASK_PERCENTAGE);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 7, P_PROD_TASK_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 8, P_PROD_TASK_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 9, P_PROD_TASK_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 10, P_PROD_TASK_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 11, P_PROD_TASK_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 12, P_PROD_TASK_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 13, P_PROD_TASK_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 14, P_PROD_TASK_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 15, P_PROD_TASK_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 16, P_PROD_TASK_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 17, P_PROD_TASK_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 18, P_PROD_TASK_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 19, P_PROD_TASK_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 20, P_PROD_TASK_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 21, P_PROD_TASK_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_PROD_TASK, 22, P_PROD_TASK_Rec.ATTRIBUTE15, 150);
END Define_Columns;
-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_PROD_TASK   IN   NUMBER,
    X_PROD_TASK_Rec   OUT NOCOPY  CSP_PRODUCT_TASK_PUB.PROD_TASK_Rec_Type
)
IS
BEGIN
      -- get all column values for CSP_PRODUCT_TASKS table
      dbms_sql.column_value(p_cur_get_PROD_TASK, 1, X_PROD_TASK_Rec.PRODUCT_TASK_ID);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 2, X_PROD_TASK_Rec.PRODUCT_ID);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 3, X_PROD_TASK_Rec.TASK_TEMPLATE_ID);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 4, X_PROD_TASK_Rec.AUTO_MANUAL);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 5, X_PROD_TASK_Rec.ACTUAL_TIMES_USED);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 6, X_PROD_TASK_Rec.TASK_PERCENTAGE);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 7, X_PROD_TASK_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 8, X_PROD_TASK_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 9, X_PROD_TASK_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 10, X_PROD_TASK_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 11, X_PROD_TASK_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 12, X_PROD_TASK_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 13, X_PROD_TASK_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 14, X_PROD_TASK_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 15, X_PROD_TASK_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 16, X_PROD_TASK_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 17, X_PROD_TASK_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 18, X_PROD_TASK_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 19, X_PROD_TASK_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 20, X_PROD_TASK_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 21, X_PROD_TASK_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_PROD_TASK, 22, X_PROD_TASK_Rec.ATTRIBUTE15);
END Get_Column_Values;
-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_PROD_TASK_Rec   IN   CSP_PRODUCT_TASK_PUB.PROD_TASK_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_PROD_TASK   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_PROD_TASK_Rec.PRODUCT_TASK_ID IS NOT NULL) AND (P_PROD_TASK_Rec.PRODUCT_TASK_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_PROD_TASK, ':p_PRODUCT_TASK_ID', P_PROD_TASK_Rec.PRODUCT_TASK_ID);
      END IF;
END Bind;
PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      x_select_cl := 'Select ' ||
                'CSP_PRODUCT_TASKS.PRODUCT_TASK_ID,' ||
                'CSP_PRODUCT_TASKS.PRODUCT_ID,' ||
                'CSP_PRODUCT_TASKS.TASK_TEMPLATE_ID,' ||
                'CSP_PRODUCT_TASKS.AUTO_MANUAL,' ||
                'CSP_PRODUCT_TASKS.ACTUAL_TIMES_USED,' ||
                'CSP_PRODUCT_TASKS.TASK_PERCENTAGE,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE_CATEGORY,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE1,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE2,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE3,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE4,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE5,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE6,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE7,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE8,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE9,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE10,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE11,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE12,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE13,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE14,' ||
                'CSP_PRODUCT_TASKS.ATTRIBUTE15,' ||
                'CSP_PRODUCT_TASKS.CREATED_BY,' ||
                'CSP_PRODUCT_TASKS.CREATION_DATE,' ||
                'CSP_PRODUCT_TASKS.LAST_UPDATED_BY,' ||
                'CSP_PRODUCT_TASKS.LAST_UPDATE_DATE,' ||
                'CSP_PRODUCT_TASKS.LAST_UPDATE_LOGIN,' ||
                'from CSP_PRODUCT_TASKS';
END Gen_Select;
PROCEDURE Gen_PROD_TASK_Where(
    P_PROD_TASK_Rec     IN   CSP_PRODUCT_TASK_PUB.PROD_TASK_Rec_Type,
    x_PROD_TASK_where   OUT NOCOPY   VARCHAR2
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
      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.
      -- example for NUMBER datatype
      IF( (P_PROD_TASK_Rec.PRODUCT_TASK_ID IS NOT NULL) AND (P_PROD_TASK_Rec.PRODUCT_TASK_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_PROD_TASK_where IS NULL) THEN
              x_PROD_TASK_where := 'Where';
          ELSE
              x_PROD_TASK_where := x_PROD_TASK_where || ' AND ';
          END IF;
          x_PROD_TASK_where := x_PROD_TASK_where || 'P_PROD_TASK_Rec.PRODUCT_TASK_ID = :p_PRODUCT_TASK_ID';
      END IF;
      -- example for DATE datatype
      IF( (P_PROD_TASK_Rec.CREATION_DATE IS NOT NULL) AND (P_PROD_TASK_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_PROD_TASK_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;
          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_PROD_TASK_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;
          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
          IF(x_PROD_TASK_where IS NULL) THEN
              x_PROD_TASK_where := 'Where ';
          ELSE
              x_PROD_TASK_where := x_PROD_TASK_where || ' AND ';
          END IF;
          x_PROD_TASK_where := x_PROD_TASK_where || 'P_PROD_TASK_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;
      -- example for VARCHAR2 datatype
      IF( (P_PROD_TASK_Rec.AUTO_MANUAL IS NOT NULL) AND (P_PROD_TASK_Rec.AUTO_MANUAL <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_PROD_TASK_Rec.AUTO_MANUAL);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;
          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_PROD_TASK_Rec.AUTO_MANUAL);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;
          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;
          IF(x_PROD_TASK_where IS NULL) THEN
              x_PROD_TASK_where := 'Where ';
          ELSE
              x_PROD_TASK_where := x_PROD_TASK_where || ' AND ';
          END IF;
          x_PROD_TASK_where := x_PROD_TASK_where || 'P_PROD_TASK_Rec.AUTO_MANUAL ' || l_operator || ' :p_AUTO_MANUAL';
      END IF;
      -- Add more IF statements for each column below
END Gen_PROD_TASK_Where;

-- Item-level validation procedures
PROCEDURE Validate_PRODUCT_TASK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRODUCT_TASK_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
PROCEDURE Validate_PRODUCT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRODUCT_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
      IF(p_PRODUCT_ID is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRODUCT_ID is not NULL and p_PRODUCT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PRODUCT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_PRODUCT_ID;
PROCEDURE Validate_TASK_TEMPLATE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_TEMPLATE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
      IF(p_TASK_TEMPLATE_ID is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_TEMPLATE_ID is not NULL and p_TASK_TEMPLATE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_TEMPLATE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_TASK_TEMPLATE_ID;
PROCEDURE Validate_AUTO_MANUAL (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_AUTO_MANUAL                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
      IF(p_AUTO_MANUAL is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_AUTO_MANUAL is not NULL and p_AUTO_MANUAL <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_AUTO_MANUAL <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_AUTO_MANUAL;
PROCEDURE Validate_ACTUAL_TIMES_USED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ACTUAL_TIMES_USED                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
PROCEDURE Validate_TASK_PERCENTAGE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_PERCENTAGE                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
          -- IF p_TASK_PERCENTAGE is not NULL and p_TASK_PERCENTAGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_PERCENTAGE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_TASK_PERCENTAGE;
-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_PROD_TASK_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROD_TASK_Rec     IN    PROD_TASK_Rec_Type,
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
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_PROD_TASK_Rec;
PROCEDURE Validate_product_task(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PROD_TASK_Rec     IN    PROD_TASK_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_product_task';
 BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_PRODUCT_TASK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRODUCT_TASK_ID   => P_PROD_TASK_Rec.PRODUCT_TASK_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_PRODUCT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRODUCT_ID   => P_PROD_TASK_Rec.PRODUCT_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_TASK_TEMPLATE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_TEMPLATE_ID   => P_PROD_TASK_Rec.TASK_TEMPLATE_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_AUTO_MANUAL(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_AUTO_MANUAL   => P_PROD_TASK_Rec.AUTO_MANUAL,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_ACTUAL_TIMES_USED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ACTUAL_TIMES_USED   => P_PROD_TASK_Rec.ACTUAL_TIMES_USED,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          Validate_TASK_PERCENTAGE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_PERCENTAGE   => P_PROD_TASK_Rec.TASK_PERCENTAGE,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
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
          Validate_PROD_TASK_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_PROD_TASK_Rec     =>    P_PROD_TASK_Rec,
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
END Validate_product_task;
End CSP_PRODUCT_TASK_PVT;


/
