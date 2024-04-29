--------------------------------------------------------
--  DDL for Package Body CSP_ORDERLINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_ORDERLINES_PVT" AS
/* $Header: cspvtmlb.pls 115.11 2003/05/02 17:17:58 phegde ship $ */
-- Start of Comments
-- Package name     : CSP_ORDERLINES_PVT
-- Purpose          :
-- History          :
-- NOTE             : CSP: api_version_number is 1.0
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_ORDERLINES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvtmlb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_orderlines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_mol_Rec     IN    mol_Rec_Type  := G_MISS_mol_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_LINE_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_orderlines';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ORDERLINES_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Create_orderlines_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_mol_Rec      =>  P_mol_Rec,
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

/* commented out by CSP DEC 06, 1999.

      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => NULL
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

*/
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Validate_orderlines');

          -- Invoke validation procedures
          Validate_orderlines(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_mol_Rec  =>  P_mol_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Calling create table handler');

      -- Invoke table handler(CSP_MOVEORDER_LINES_PKG.Insert_Row)
      CSP_MOVEORDER_LINES_PKG.Insert_Row(
          p_LINE_ID  => p_mol_rec.LINE_ID,
          p_CREATED_BY  => G_USER_ID,
          p_CREATION_DATE  => sysdate,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => sysdate,
          p_LAST_UPDATED_LOGIN  => G_LOGIN_ID,
          p_HEADER_ID  => p_mol_rec.HEADER_ID,
          p_CUSTOMER_PO  => p_mol_rec.CUSTOMER_PO,
          p_INCIDENT_ID  => p_mol_rec.INCIDENT_ID,
          p_TASK_ID  => p_mol_rec.TASK_ID,
          p_TASK_ASSIGNMENT_ID  => p_mol_rec.TASK_ASSIGNMENT_ID,
          p_COMMENTS  => p_mol_rec.COMMENTS,
          p_ATTRIBUTE_CATEGORY  => p_mol_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_mol_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_mol_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_mol_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_mol_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_mol_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_mol_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_mol_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_mol_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_mol_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_mol_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_mol_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_mol_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_mol_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_mol_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_mol_rec.ATTRIBUTE15);
      -- Hint: Primary key should be returned.
      -- x_LINE_ID := px_LINE_ID;
         x_LINE_ID := p_mol_rec.LINE_ID;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Create_orderlines_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_mol_Rec      =>  P_mol_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_orderlines;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_orderlines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_mol_Rec     IN    mol_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_orderlines(LINE_ID Number) IS
    Select rowid,
           LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_LOGIN,
           HEADER_ID,
           CUSTOMER_PO,
           INCIDENT_ID,
           TASK_ID,
           TASK_ASSIGNMENT_ID,
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
    From  CSP_MOVEORDER_LINES
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_orderlines';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_mol_rec  CSP_orderlines_PVT.mol_Rec_Type;
l_tar_mol_rec  CSP_orderlines_PVT.mol_Rec_Type := P_mol_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_ORDERLINES_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Update_orderlines_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_mol_Rec      =>  P_mol_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

/* comment out by CSP DEC 06, 1999.
      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

*/

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: - Open Cursor to Select');

/*
      Open C_Get_orderlines( l_tar_mol_rec.LINE_ID);

      Fetch C_Get_orderlines into
               l_rowid,
               l_ref_mol_rec.LINE_ID,
               l_ref_mol_rec.CREATED_BY,
               l_ref_mol_rec.CREATION_DATE,
               l_ref_mol_rec.LAST_UPDATED_BY,
               l_ref_mol_rec.LAST_UPDATE_DATE,
               l_ref_mol_rec.LAST_UPDATED_LOGIN,
               l_ref_mol_rec.HEADER_ID,
               l_ref_mol_rec.CUSTOMER_PO,
               l_ref_mol_rec.INCIDENT_ID,
               l_ref_mol_rec.TASK_ID,
               l_ref_mol_rec.TASK_ASSIGNMENT_ID,
               l_ref_mol_rec.COMMENTS,
               l_ref_mol_rec.ATTRIBUTE_CATEGORY,
               l_ref_mol_rec.ATTRIBUTE1,
               l_ref_mol_rec.ATTRIBUTE2,
               l_ref_mol_rec.ATTRIBUTE3,
               l_ref_mol_rec.ATTRIBUTE4,
               l_ref_mol_rec.ATTRIBUTE5,
               l_ref_mol_rec.ATTRIBUTE6,
               l_ref_mol_rec.ATTRIBUTE7,
               l_ref_mol_rec.ATTRIBUTE8,
               l_ref_mol_rec.ATTRIBUTE9,
               l_ref_mol_rec.ATTRIBUTE10,
               l_ref_mol_rec.ATTRIBUTE11,
               l_ref_mol_rec.ATTRIBUTE12,
               l_ref_mol_rec.ATTRIBUTE13,
               l_ref_mol_rec.ATTRIBUTE14,
               l_ref_mol_rec.ATTRIBUTE15;

       If ( C_Get_orderlines%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'orderlines', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: - Close Cursor');
       Close     C_Get_orderlines;
*/

/* commented out by klou, 01/07/00
      If (l_tar_mol_rec.last_update_date is NULL or
          l_tar_mol_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_mol_rec.last_update_date <> l_ref_mol_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'orderlines', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Validate_orderlines');

          -- Invoke validation procedures
          Validate_orderlines(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_mol_Rec  =>  P_mol_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Calling update table handler');

      -- Invoke table handler(CSP_MOVEORDER_LINES_PKG.Update_Row)
      CSP_MOVEORDER_LINES_PKG.Update_Row(
          p_LINE_ID  => p_mol_rec.LINE_ID,
          p_CREATED_BY  => p_mol_rec.created_by,
          p_CREATION_DATE  => p_mol_rec.creation_date,
          p_LAST_UPDATED_BY  => p_mol_rec.last_updated_by,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_LOGIN  =>p_mol_rec.last_updated_login,
          p_HEADER_ID  => p_mol_rec.HEADER_ID,
          p_CUSTOMER_PO  => p_mol_rec.CUSTOMER_PO,
          p_INCIDENT_ID  => p_mol_rec.INCIDENT_ID,
          p_TASK_ID  => p_mol_rec.TASK_ID,
          p_TASK_ASSIGNMENT_ID  => p_mol_rec.TASK_ASSIGNMENT_ID,
          p_COMMENTS  => p_mol_rec.COMMENTS,
          p_ATTRIBUTE_CATEGORY  => p_mol_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_mol_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_mol_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_mol_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_mol_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_mol_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_mol_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_mol_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_mol_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_mol_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_mol_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_mol_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_mol_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_mol_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_mol_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_mol_rec.ATTRIBUTE15);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Update_orderlines_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_mol_Rec      =>  P_mol_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_orderlines;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_orderlines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_mol_Rec     IN mol_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_orderlines';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_ORDERLINES_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Delete_orderlines_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_mol_Rec      =>  P_mol_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

/* comment out by CSP DEC 06, 1999.
      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP',  'Private API: Calling delete table handler');

      -- Invoke table handler(CSP_MOVEORDER_LINES_PKG.Delete_Row)
      CSP_MOVEORDER_LINES_PKG.Delete_Row(
          p_LINE_ID  => p_mol_rec.LINE_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Delete_orderlines_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_mol_Rec      =>  P_mol_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_orderlines;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_mol_Rec   IN  CSP_ORDERLINES_PUB.mol_Rec_Type,
    p_cur_get_mol   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Define Columns Begins');

      -- define all columns for CSP_MOVEORDER_LINES_V view
      dbms_sql.define_column(p_cur_get_mol, 1, P_mol_Rec.LINE_ID);
      dbms_sql.define_column(p_cur_get_mol, 2, P_mol_Rec.LAST_UPDATED_LOGIN);
      dbms_sql.define_column(p_cur_get_mol, 3, P_mol_Rec.HEADER_ID);
      dbms_sql.define_column(p_cur_get_mol, 4, P_mol_Rec.CUSTOMER_PO, 30);
      dbms_sql.define_column(p_cur_get_mol, 5, P_mol_Rec.INCIDENT_ID);
      dbms_sql.define_column(p_cur_get_mol, 6, P_mol_Rec.TASK_ID);
      dbms_sql.define_column(p_cur_get_mol, 7, P_mol_Rec.TASK_ASSIGNMENT_ID);
      dbms_sql.define_column(p_cur_get_mol, 8, P_mol_Rec.COMMENTS, 240);
      dbms_sql.define_column(p_cur_get_mol, 9, P_mol_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_mol, 10, P_mol_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_mol, 11, P_mol_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_mol, 12, P_mol_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_mol, 13, P_mol_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_mol, 14, P_mol_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_mol, 15, P_mol_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_mol, 16, P_mol_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_mol, 17, P_mol_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_mol, 18, P_mol_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_mol, 19, P_mol_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_mol, 20, P_mol_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_mol, 21, P_mol_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_mol, 22, P_mol_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_mol, 23, P_mol_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_mol, 24, P_mol_Rec.ATTRIBUTE15, 150);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_mol   IN   NUMBER,
    X_mol_Rec   OUT NOCOPY  CSP_ORDERLINES_PUB.mol_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Get Column Values Begins');

      -- get all column values for CSP_MOVEORDER_LINES_V table
      dbms_sql.column_value(p_cur_get_mol, 1, X_mol_Rec.LINE_ID);
      dbms_sql.column_value(p_cur_get_mol, 2, X_mol_Rec.LAST_UPDATED_LOGIN);
      dbms_sql.column_value(p_cur_get_mol, 3, X_mol_Rec.HEADER_ID);
      dbms_sql.column_value(p_cur_get_mol, 4, X_mol_Rec.CUSTOMER_PO);
      dbms_sql.column_value(p_cur_get_mol, 5, X_mol_Rec.INCIDENT_ID);
      dbms_sql.column_value(p_cur_get_mol, 6, X_mol_Rec.TASK_ID);
      dbms_sql.column_value(p_cur_get_mol, 7, X_mol_Rec.TASK_ASSIGNMENT_ID);
      dbms_sql.column_value(p_cur_get_mol, 8, X_mol_Rec.COMMENTS);
      dbms_sql.column_value(p_cur_get_mol, 9, X_mol_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_mol, 10, X_mol_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_mol, 11, X_mol_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_mol, 12, X_mol_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_mol, 13, X_mol_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_mol, 14, X_mol_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_mol, 15, X_mol_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_mol, 16, X_mol_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_mol, 17, X_mol_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_mol, 18, X_mol_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_mol, 19, X_mol_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_mol, 20, X_mol_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_mol, 21, X_mol_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_mol, 22, X_mol_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_mol, 23, X_mol_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_mol, 24, X_mol_Rec.ATTRIBUTE15);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_mol_order_cl(
    p_order_by_rec   IN   CSP_ORDERLINES_PUB.mol_sort_rec_type,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Order by Begins');

      -- Hint: Developer should add more statements according to CSP_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Invoke JTF_PLSQL_API.Translate_OrderBy');

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Order by Ends');
END Gen_mol_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_mol_Rec   IN   CSP_ORDERLINES_PUB.mol_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_mol   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_mol_Rec.LINE_ID IS NOT NULL) AND (P_mol_Rec.LINE_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_mol, ':p_LINE_ID', P_mol_Rec.LINE_ID);
      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Bind Variables Ends');
END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Select Begins');

      x_select_cl := 'Select ' ||
                'CSP_MOVEORDER_LINES_V.LINE_ID,' ||
                'CSP_MOVEORDER_LINES_V.CREATED_BY,' ||
                'CSP_MOVEORDER_LINES_V.CREATION_DATE,' ||
                'CSP_MOVEORDER_LINES_V.LAST_UPDATED_BY,' ||
                'CSP_MOVEORDER_LINES_V.LAST_UPDATE_DATE,' ||
                'CSP_MOVEORDER_LINES_V.LAST_UPDATED_LOGIN,' ||
                'CSP_MOVEORDER_LINES_V.HEADER_ID,' ||
                'CSP_MOVEORDER_LINES_V.CUSTOMER_PO,' ||
                'CSP_MOVEORDER_LINES_V.INCIDENT_ID,' ||
                'CSP_MOVEORDER_LINES_V.TASK_ID,' ||
                'CSP_MOVEORDER_LINES_V.TASK_ASSIGNMENT_ID,' ||
                'CSP_MOVEORDER_LINES_V.COMMENTS,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE_CATEGORY,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE1,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE2,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE3,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE4,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE5,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE6,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE7,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE8,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE9,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE10,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE11,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE12,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE13,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE14,' ||
                'CSP_MOVEORDER_LINES_V.ATTRIBUTE15,' ||
                'from CSP_MOVEORDER_LINES_V';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_mol_Where(
    P_mol_Rec     IN   CSP_ORDERLINES_PUB.mol_Rec_Type,
    x_mol_where   OUT NOCOPY   VARCHAR2
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Where Begins');

      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_mol_Rec.LINE_ID IS NOT NULL) AND (P_mol_Rec.LINE_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_mol_where IS NULL) THEN
              x_mol_where := 'Where';
          ELSE
              x_mol_where := x_mol_where || ' AND ';
          END IF;
          x_mol_where := x_mol_where || 'P_mol_Rec.LINE_ID = :p_LINE_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_mol_Rec.CREATION_DATE IS NOT NULL) AND (P_mol_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_mol_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_mol_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_mol_where IS NULL) THEN
              x_mol_where := 'Where ';
          ELSE
              x_mol_where := x_mol_where || ' AND ';
          END IF;
          x_mol_where := x_mol_where || 'P_mol_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_mol_Rec.CUSTOMER_PO IS NOT NULL) AND (P_mol_Rec.CUSTOMER_PO <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_mol_Rec.CUSTOMER_PO);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_mol_Rec.CUSTOMER_PO);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_mol_where IS NULL) THEN
              x_mol_where := 'Where ';
          ELSE
              x_mol_where := x_mol_where || ' AND ';
          END IF;
          x_mol_where := x_mol_where || 'P_mol_Rec.CUSTOMER_PO ' || l_operator || ' :p_CUSTOMER_PO';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Where Ends');

END Gen_mol_Where;

-- Item-level validation procedures
PROCEDURE Validate_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LINE_ID                IN   NUMBER,
    P_HEADER_ID                  IN   NUMBER,       -- added for valiation of line_id 06-DEC-99, VL.
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    l_check_line_id NUMBER;
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_LINE_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private orderlines API: -Violate NOT NULL constraint(LINE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
        NULL;
          -- Hint: Validate data
          -- IF p_LINE_ID is not NULL and p_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
        /* Removed by klou. This block of validations is moved to the csp_to_form_molines.validate_and_write.
          -- CSP line_id validation
          BEGIN
            SELECT organization_id into l_check_line_id
            from mtl_txn_request_lines
            where header_id = p_header_id
            and line_id = p_line_id;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_count := x_msg_count + 1;
                x_msg_data := 'The Line ID is not valid for the Header ID. Or Header ID does not exists.';
            WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_count := x_msg_count + 1;
                x_msg_data := 'Unexpected errors found. Please check the Line ID and Header ID.';
          END;
        */
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LINE_ID;


PROCEDURE Validate_LAST_UPDATED_LOGIN (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LAST_UPDATED_LOGIN                IN   NUMBER,
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
          -- IF p_LAST_UPDATED_LOGIN is not NULL and p_LAST_UPDATED_LOGIN <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LAST_UPDATED_LOGIN <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LAST_UPDATED_LOGIN;


PROCEDURE Validate_HEADER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_HEADER_ID                IN   NUMBER,
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
      IF(p_HEADER_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private orderlines API: -Violate NOT NULL constraint(HEADER_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_HEADER_ID is not NULL and p_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_HEADER_ID;


PROCEDURE Validate_CUSTOMER_PO (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_PO                IN   VARCHAR2,
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
          -- IF p_CUSTOMER_PO is not NULL and p_CUSTOMER_PO <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CUSTOMER_PO <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CUSTOMER_PO;


PROCEDURE Validate_INCIDENT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INCIDENT_ID                IN   NUMBER,
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
          -- IF p_INCIDENT_ID is not NULL and p_INCIDENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_INCIDENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INCIDENT_ID;


PROCEDURE Validate_TASK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_ID                IN   NUMBER,
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
          -- IF p_TASK_ID is not NULL and p_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TASK_ID;


PROCEDURE Validate_TASK_ASSIGNMENT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TASK_ASSIGNMENT_ID                IN   NUMBER,
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
          -- IF p_TASK_ASSIGNMENT_ID is not NULL and p_TASK_ASSIGNMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TASK_ASSIGNMENT_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TASK_ASSIGNMENT_ID;


PROCEDURE Validate_COMMENTS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COMMENTS                IN   VARCHAR2,
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
          -- IF p_COMMENTS is not NULL and p_COMMENTS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_COMMENTS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COMMENTS;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_PLSQL_API.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_mol_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_mol_Rec     IN    mol_Rec_Type,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_mol_Rec;

PROCEDURE Validate_orderlines(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_mol_Rec     IN    mol_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_orderlines';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LINE_ID   => P_mol_Rec.LINE_ID,
              P_HEADER_ID => P_mol_Rec.HEADER_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LAST_UPDATED_LOGIN(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LAST_UPDATED_LOGIN   => P_mol_Rec.LAST_UPDATED_LOGIN,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_HEADER_ID   => P_mol_Rec.HEADER_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CUSTOMER_PO(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CUSTOMER_PO   => P_mol_Rec.CUSTOMER_PO,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_INCIDENT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_INCIDENT_ID   => P_mol_Rec.INCIDENT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TASK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_ID   => P_mol_Rec.TASK_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_TASK_ASSIGNMENT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TASK_ASSIGNMENT_ID   => P_mol_Rec.TASK_ASSIGNMENT_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_COMMENTS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COMMENTS   => P_mol_Rec.COMMENTS,
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
          Validate_mol_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_mol_Rec     =>    P_mol_Rec,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'end');

END Validate_orderlines;

End CSP_ORDERLINES_PVT;

/
