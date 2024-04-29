--------------------------------------------------------
--  DDL for Package Body CSP_RS_CUST_RELATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_RS_CUST_RELATION_PVT" as
/* $Header: cspvrcrb.pls 115.6 2003/05/02 00:26:48 phegde noship $ */
-- Start of Comments
-- Package name     : CSP_RS_CUST_RELATION_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_RS_CUST_RELATION_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvrcrb.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_rs_cust_relation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_RCR_Rec     IN    RCR_Rec_Type  := G_MISS_RCR_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_RS_CUST_RELATION_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_rs_cust_relation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_access_flag               VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_RS_CUST_RELATION_PVT;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


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


 /*     IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => NULL
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
*/
      -- Debug message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_rs_cust_relation');

      -- Invoke validation procedures
      Validate_rs_cust_relation(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_RCR_Rec  =>  P_RCR_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');

      -- Invoke table handler(CSP_RS_CUST_RELATIONS_PKG.Insert_Row)
      CSP_RS_CUST_RELATIONS_PKG.Insert_Row(
          px_RS_CUST_RELATION_ID  => x_RS_CUST_RELATION_ID,
          p_RESOURCE_TYPE  => p_RCR_rec.RESOURCE_TYPE,
          p_RESOURCE_ID  => p_RCR_rec.RESOURCE_ID,
          p_CUSTOMER_ID  => p_RCR_rec.CUSTOMER_ID,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE_CATEGORY  => p_RCR_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_RCR_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_RCR_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_RCR_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_RCR_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_RCR_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_RCR_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_RCR_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_RCR_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_RCR_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_RCR_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_RCR_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_RCR_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_RCR_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_RCR_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_RCR_rec.ATTRIBUTE15);
      -- Hint: Primary key should be returned.
      -- x_RS_CUST_RELATION_ID := px_RS_CUST_RELATION_ID;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_rs_cust_relation;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_rs_cust_relation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_RCR_Rec     IN    RCR_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_rs_cust_relation(RS_CUST_RELATION_ID Number) IS
    Select rowid,
           RS_CUST_RELATION_ID,
           RESOURCE_TYPE,
           RESOURCE_ID,
           CUSTOMER_ID,
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
           ATTRIBUTE15
    From  CSP_RS_CUST_RELATIONS
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_rs_cust_relation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_RCR_rec  CSP_rs_cust_relation_PVT.RCR_Rec_Type;
l_tar_RCR_rec  CSP_rs_cust_relation_PVT.RCR_Rec_Type := P_RCR_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_RS_CUST_RELATION_PVT;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

/*      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
*/
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');

/*
      Open C_Get_rs_cust_relation( l_tar_RCR_rec.RS_CUST_RELATION_ID);

      Fetch C_Get_rs_cust_relation into
               l_rowid,
               l_ref_RCR_rec.RS_CUST_RELATION_ID,
               l_ref_RCR_rec.RESOURCE_TYPE,
               l_ref_RCR_rec.RESOURCE_ID,
               l_ref_RCR_rec.CUSTOMER_ID,
               l_ref_RCR_rec.CREATED_BY,
               l_ref_RCR_rec.CREATION_DATE,
               l_ref_RCR_rec.LAST_UPDATED_BY,
               l_ref_RCR_rec.LAST_UPDATE_DATE,
               l_ref_RCR_rec.LAST_UPDATE_LOGIN,
               l_ref_RCR_rec.ATTRIBUTE_CATEGORY,
               l_ref_RCR_rec.ATTRIBUTE1,
               l_ref_RCR_rec.ATTRIBUTE2,
               l_ref_RCR_rec.ATTRIBUTE3,
               l_ref_RCR_rec.ATTRIBUTE4,
               l_ref_RCR_rec.ATTRIBUTE5,
               l_ref_RCR_rec.ATTRIBUTE6,
               l_ref_RCR_rec.ATTRIBUTE7,
               l_ref_RCR_rec.ATTRIBUTE8,
               l_ref_RCR_rec.ATTRIBUTE9,
               l_ref_RCR_rec.ATTRIBUTE10,
               l_ref_RCR_rec.ATTRIBUTE11,
               l_ref_RCR_rec.ATTRIBUTE12,
               l_ref_RCR_rec.ATTRIBUTE13,
               l_ref_RCR_rec.ATTRIBUTE14,
               l_ref_RCR_rec.ATTRIBUTE15;

       If ( C_Get_rs_cust_relation%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'rs_cust_relation', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_rs_cust_relation;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       Close     C_Get_rs_cust_relation;
*/


      If (l_tar_RCR_rec.last_update_date is NULL or
          l_tar_RCR_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_RCR_rec.last_update_date <> l_ref_RCR_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'rs_cust_relation', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_rs_cust_relation');

      -- Invoke validation procedures
      Validate_rs_cust_relation(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_RCR_Rec  =>  P_RCR_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(CSP_RS_CUST_RELATIONS_PKG.Update_Row)
      CSP_RS_CUST_RELATIONS_PKG.Update_Row(
          p_RS_CUST_RELATION_ID  => p_RCR_rec.RS_CUST_RELATION_ID,
          p_RESOURCE_TYPE  => p_RCR_rec.RESOURCE_TYPE,
          p_RESOURCE_ID  => p_RCR_rec.RESOURCE_ID,
          p_CUSTOMER_ID  => p_RCR_rec.CUSTOMER_ID,
          p_CREATED_BY     => FND_API.G_MISS_NUM,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE_CATEGORY  => p_RCR_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_RCR_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_RCR_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_RCR_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_RCR_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_RCR_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_RCR_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_RCR_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_RCR_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_RCR_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_RCR_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_RCR_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_RCR_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_RCR_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_RCR_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_RCR_rec.ATTRIBUTE15);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_rs_cust_relation;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_rs_cust_relation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_RCR_Rec     IN RCR_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_rs_cust_relation';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_RS_CUST_RELATION_PVT;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

/*      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
*/

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');

      -- Invoke table handler(CSP_RS_CUST_RELATIONS_PKG.Delete_Row)
      CSP_RS_CUST_RELATIONS_PKG.Delete_Row(
          p_RS_CUST_RELATION_ID  => p_RCR_rec.RS_CUST_RELATION_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_rs_cust_relation;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_RCR_Rec   IN  CSP_RS_CUST_RELATION_PUB.RCR_Rec_Type,
    p_cur_get_RCR   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Begins');

      -- define all columns for CSP_RS_CUST_RELATIONS view
      dbms_sql.define_column(p_cur_get_RCR, 1, P_RCR_Rec.RS_CUST_RELATION_ID);
      dbms_sql.define_column(p_cur_get_RCR, 2, P_RCR_Rec.RESOURCE_TYPE, 30);
      dbms_sql.define_column(p_cur_get_RCR, 3, P_RCR_Rec.RESOURCE_ID);
      dbms_sql.define_column(p_cur_get_RCR, 5, P_RCR_Rec.CUSTOMER_ID);
      dbms_sql.define_column(p_cur_get_RCR, 6, P_RCR_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_RCR, 7, P_RCR_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_RCR, 8, P_RCR_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_RCR, 9, P_RCR_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_RCR, 10, P_RCR_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_RCR, 11, P_RCR_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_RCR, 12, P_RCR_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_RCR, 13, P_RCR_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_RCR, 14, P_RCR_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_RCR, 15, P_RCR_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_RCR, 16, P_RCR_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_RCR, 17, P_RCR_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_RCR, 18, P_RCR_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_RCR, 19, P_RCR_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_RCR, 20, P_RCR_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_RCR, 21, P_RCR_Rec.ATTRIBUTE15, 150);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_RCR   IN   NUMBER,
    X_RCR_Rec   OUT NOCOPY  CSP_RS_CUST_RELATION_PUB.RCR_Rec_Type
)
IS
BEGIN
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Begins');

      -- get all column values for CSP_RS_CUST_RELATIONS table
      dbms_sql.column_value(p_cur_get_RCR, 1, X_RCR_Rec.RS_CUST_RELATION_ID);
      dbms_sql.column_value(p_cur_get_RCR, 2, X_RCR_Rec.RESOURCE_TYPE);
      dbms_sql.column_value(p_cur_get_RCR, 3, X_RCR_Rec.RESOURCE_ID);
      dbms_sql.column_value(p_cur_get_RCR, 5, X_RCR_Rec.CUSTOMER_ID);
      dbms_sql.column_value(p_cur_get_RCR, 6, X_RCR_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_RCR, 7, X_RCR_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_RCR, 8, X_RCR_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_RCR, 9, X_RCR_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_RCR, 10, X_RCR_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_RCR, 11, X_RCR_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_RCR, 12, X_RCR_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_RCR, 13, X_RCR_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_RCR, 14, X_RCR_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_RCR, 15, X_RCR_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_RCR, 16, X_RCR_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_RCR, 17, X_RCR_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_RCR, 18, X_RCR_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_RCR, 19, X_RCR_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_RCR, 20, X_RCR_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_RCR, 21, X_RCR_Rec.ATTRIBUTE15);

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_RCR_order_cl(
    p_order_by_rec   IN   CSP_RS_CUST_RELATION_PUB.RCR_sort_rec_type,
    x_order_by_cl    OUT NOCOPY  VARCHAR2,
    x_return_status  OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2
)
IS
l_order_by_cl        VARCHAR2(1000)   := NULL;
l_util_order_by_tbl  AS_UTILITY_PVT.Util_order_by_tbl_type;
BEGIN
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Order by Begins');

      -- Hint: Developer should add more statements according to CSP_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Invoke AS_UTILITY_PVT.Translate_OrderBy');

      AS_UTILITY_PVT.Translate_OrderBy(
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Order by Ends');
END Gen_RCR_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_RCR_Rec   IN   CSP_RS_CUST_RELATION_PUB.RCR_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_RCR   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_RCR_Rec.RS_CUST_RELATION_ID IS NOT NULL) AND (P_RCR_Rec.RS_CUST_RELATION_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_RCR, ':p_RS_CUST_RELATION_ID', P_RCR_Rec.RS_CUST_RELATION_ID);
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Ends');
END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Begins');

      x_select_cl := 'Select ' ||
                'CSP_RS_CUST_RELATIONS.RS_CUST_RELATION_ID,' ||
                'CSP_RS_CUST_RELATIONS.RESOURCE_TYPE,' ||
                'CSP_RS_CUST_RELATIONS.RESOURCE_ID,' ||
                'CSP_RS_CUST_RELATIONS.CUSTOMER_ID,' ||
                'CSP_RS_CUST_RELATIONS.CREATED_BY,' ||
                'CSP_RS_CUST_RELATIONS.CREATION_DATE,' ||
                'CSP_RS_CUST_RELATIONS.LAST_UPDATED_BY,' ||
                'CSP_RS_CUST_RELATIONS.LAST_UPDATE_DATE,' ||
                'CSP_RS_CUST_RELATIONS.LAST_UPDATE_LOGIN,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE_CATEGORY,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE1,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE2,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE3,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE4,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE5,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE6,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE7,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE8,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE9,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE10,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE11,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE12,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE13,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE14,' ||
                'CSP_RS_CUST_RELATIONS.ATTRIBUTE15 ' ||
                'from CSP_RS_CUST_RELATIONS';
      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_RCR_Where(
    P_RCR_Rec     IN   CSP_RS_CUST_RELATION_PUB.RCR_Rec_Type,
    x_RCR_where   OUT NOCOPY   VARCHAR2
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Begins');

      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_RCR_Rec.RS_CUST_RELATION_ID IS NOT NULL) AND (P_RCR_Rec.RS_CUST_RELATION_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_RCR_where IS NULL) THEN
              x_RCR_where := 'Where';
          ELSE
              x_RCR_where := x_RCR_where || ' AND ';
          END IF;
          x_RCR_where := x_RCR_where || 'P_RCR_Rec.RS_CUST_RELATION_ID = :p_RS_CUST_RELATION_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_RCR_Rec.CREATION_DATE IS NOT NULL) AND (P_RCR_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_RCR_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_RCR_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_RCR_where IS NULL) THEN
              x_RCR_where := 'Where ';
          ELSE
              x_RCR_where := x_RCR_where || ' AND ';
          END IF;
          x_RCR_where := x_RCR_where || 'P_RCR_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_RCR_Rec.RESOURCE_TYPE IS NOT NULL) AND (P_RCR_Rec.RESOURCE_TYPE <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_RCR_Rec.RESOURCE_TYPE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_RCR_Rec.RESOURCE_TYPE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_RCR_where IS NULL) THEN
              x_RCR_where := 'Where ';
          ELSE
              x_RCR_where := x_RCR_where || ' AND ';
          END IF;
          x_RCR_where := x_RCR_where || 'P_RCR_Rec.RESOURCE_TYPE ' || l_operator || ' :p_RESOURCE_TYPE';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Ends');

END Gen_RCR_Where;


-- Item-level validation procedures
PROCEDURE Validate_RS_CUST_RELATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RS_CUST_RELATION_ID                IN   NUMBER,
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
      IF(p_RS_CUST_RELATION_ID is NULL)
      THEN
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private rs_cust_relation API: -Violate NOT NULL constraint(RS_CUST_RELATION_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RS_CUST_RELATION_ID is not NULL and p_RS_CUST_RELATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RS_CUST_RELATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RS_CUST_RELATION_ID;


PROCEDURE Validate_RESOURCE_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESOURCE_TYPE                IN   VARCHAR2,
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
      IF(p_RESOURCE_TYPE is NULL)
      THEN
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private rs_cust_relation API: -Violate NOT NULL constraint(RESOURCE_TYPE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESOURCE_TYPE is not NULL and p_RESOURCE_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESOURCE_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RESOURCE_TYPE;


PROCEDURE Validate_RESOURCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESOURCE_ID                IN   NUMBER,
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
      IF(p_RESOURCE_ID is NULL)
      THEN
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private rs_cust_relation API: -Violate NOT NULL constraint(RESOURCE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESOURCE_ID is not NULL and p_RESOURCE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESOURCE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RESOURCE_ID;


PROCEDURE Validate_CUSTOMER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID                IN   NUMBER,
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
      IF(p_CUSTOMER_ID is NULL)
      THEN
          AS_UTILITY_PVT.Debug_Message('ERROR', 'Private rs_cust_relation API: -Violate NOT NULL constraint(CUSTOMER_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CUSTOMER_ID is not NULL and p_CUSTOMER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CUSTOMER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CUSTOMER_ID;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_RCR_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RCR_Rec     IN    RCR_Rec_Type,
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RCR_Rec;

PROCEDURE Validate_rs_cust_relation(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_RCR_Rec     IN    RCR_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_rs_cust_relation';
 BEGIN

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_RS_CUST_RELATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RS_CUST_RELATION_ID   => P_RCR_Rec.RS_CUST_RELATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RESOURCE_TYPE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RESOURCE_TYPE   => P_RCR_Rec.RESOURCE_TYPE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RESOURCE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RESOURCE_ID   => P_RCR_Rec.RESOURCE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CUSTOMER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CUSTOMER_ID   => P_RCR_Rec.CUSTOMER_ID,
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
          Validate_RCR_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_RCR_Rec     =>    P_RCR_Rec,
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');

END Validate_rs_cust_relation;

End CSP_RS_CUST_RELATION_PVT;

/
