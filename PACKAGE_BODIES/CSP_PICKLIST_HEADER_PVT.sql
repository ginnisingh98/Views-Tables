--------------------------------------------------------
--  DDL for Package Body CSP_PICKLIST_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PICKLIST_HEADER_PVT" AS
/* $Header: cspvtphb.pls 115.8 2003/05/02 17:18:34 phegde ship $ */
-- Start of Comments
-- Package name     : CSP_picklist_header_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_picklist_header_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvtphb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_picklist_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_PICK_HEADER_Rec     IN    PICK_HEADER_Rec_Type  := G_MISS_PICK_HEADER_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_picklist_header_id     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_picklist_header';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
--l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_picklist_header_PVT;

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
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Create_picklist_header_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_PICK_HEADER_Rec      =>  P_PICK_HEADER_Rec,
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


/*      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
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
         -- JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_picklist_header');

          -- Invoke validation procedures
          Validate_picklist_header(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_PICK_HEADER_Rec  =>  P_PICK_HEADER_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');


      -- assign p_pick_header_rec.picklist_header_id to x_picklist_header_id
      x_picklist_header_id := p_pick_header_rec.picklist_header_id;

      -- Invoke table handler(CSP_PICKLIST_HEADERS_PKG.Insert_Row)
      CSP_PICKLIST_HEADERS_PKG.Insert_Row(
          px_picklist_header_id  => x_picklist_header_id,
          p_CREATED_BY  => p_PICK_HEADER_rec.CREATED_BY,
          p_CREATION_DATE  => p_PICK_HEADER_rec.CREATION_DATE,
          p_LAST_UPDATED_BY  => p_PICK_HEADER_rec.LAST_UPDATED_BY,
          p_LAST_UPDATE_DATE  => p_PICK_HEADER_rec.LAST_UPDATE_DATE,
          p_LAST_UPDATE_LOGIN  => p_PICK_HEADER_rec.LAST_UPDATE_LOGIN,
          p_ORGANIZATION_ID  => p_PICK_HEADER_rec.ORGANIZATION_ID,
          p_PICKLIST_NUMBER  => p_PICK_HEADER_rec.PICKLIST_NUMBER,
          p_PICKLIST_STATUS  => p_PICK_HEADER_rec.PICKLIST_STATUS,
          p_DATE_CREATED  => p_PICK_HEADER_rec.DATE_CREATED,
          p_DATE_CONFIRMED  => p_PICK_HEADER_rec.DATE_CONFIRMED,
          p_ATTRIBUTE_CATEGORY  => p_PICK_HEADER_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_PICK_HEADER_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_PICK_HEADER_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_PICK_HEADER_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_PICK_HEADER_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_PICK_HEADER_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_PICK_HEADER_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_PICK_HEADER_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_PICK_HEADER_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_PICK_HEADER_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_PICK_HEADER_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_PICK_HEADER_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_PICK_HEADER_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_PICK_HEADER_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_PICK_HEADER_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_PICK_HEADER_rec.ATTRIBUTE15);
      -- Hint: Primary key should be returned.
      -- x_picklist_header_id := px_picklist_header_id;

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
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Create_picklist_header_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_PICK_HEADER_Rec      =>  P_PICK_HEADER_Rec,
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
End Create_picklist_header;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_picklist_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    --P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_PICK_HEADER_Rec     IN    PICK_HEADER_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_picklist_header(picklist_header_id Number) IS
    Select rowid,
           picklist_header_id,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PICKLIST_NUMBER,
           PICKLIST_STATUS,
           DATE_CREATED,
           DATE_CONFIRMED,
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
    From  CSP_PICKLIST_HEADERS
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_picklist_header';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
--l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_PICK_HEADER_rec  CSP_picklist_header_PVT.PICK_HEADER_Rec_Type;
l_tar_PICK_HEADER_rec  CSP_picklist_header_PVT.PICK_HEADER_Rec_Type := P_PICK_HEADER_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_picklist_header_PVT;

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
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Update_picklist_header_BU(
                  p_api_version_number   =>  1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PICK_HEADER_Rec      =>  P_PICK_HEADER_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

/*      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 1.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');

/*
      Open C_Get_picklist_header( l_tar_PICK_HEADER_rec.picklist_header_id);

      Fetch C_Get_picklist_header into
               l_rowid,
               l_ref_PICK_HEADER_rec.picklist_header_id,
               l_ref_PICK_HEADER_rec.CREATED_BY,
               l_ref_PICK_HEADER_rec.CREATION_DATE,
               l_ref_PICK_HEADER_rec.LAST_UPDATED_BY,
               l_ref_PICK_HEADER_rec.LAST_UPDATE_DATE,
               l_ref_PICK_HEADER_rec.LAST_UPDATE_LOGIN,
               l_ref_PICK_HEADER_rec.ORGANIZATION_ID,
               l_ref_PICK_HEADER_rec.PICKLIST_NUMBER,
               l_ref_PICK_HEADER_rec.PICKLIST_STATUS,
               l_ref_PICK_HEADER_rec.DATE_CREATED,
               l_ref_PICK_HEADER_rec.DATE_CONFIRMED,
               l_ref_PICK_HEADER_rec.ATTRIBUTE_CATEGORY,
               l_ref_PICK_HEADER_rec.ATTRIBUTE1,
               l_ref_PICK_HEADER_rec.ATTRIBUTE2,
               l_ref_PICK_HEADER_rec.ATTRIBUTE3,
               l_ref_PICK_HEADER_rec.ATTRIBUTE4,
               l_ref_PICK_HEADER_rec.ATTRIBUTE5,
               l_ref_PICK_HEADER_rec.ATTRIBUTE6,
               l_ref_PICK_HEADER_rec.ATTRIBUTE7,
               l_ref_PICK_HEADER_rec.ATTRIBUTE8,
               l_ref_PICK_HEADER_rec.ATTRIBUTE9,
               l_ref_PICK_HEADER_rec.ATTRIBUTE10,
               l_ref_PICK_HEADER_rec.ATTRIBUTE11,
               l_ref_PICK_HEADER_rec.ATTRIBUTE12,
               l_ref_PICK_HEADER_rec.ATTRIBUTE13,
               l_ref_PICK_HEADER_rec.ATTRIBUTE14,
               l_ref_PICK_HEADER_rec.ATTRIBUTE15;

       If ( C_Get_picklist_header%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'picklist_header', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       Close     C_Get_picklist_header;
*/


 /*     If (l_tar_PICK_HEADER_rec.last_update_date is NULL or
          l_tar_PICK_HEADER_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_PICK_HEADER_rec.last_update_date <> l_ref_PICK_HEADER_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'picklist_header', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_picklist_header');

          -- Invoke validation procedures
          Validate_picklist_header(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_PICK_HEADER_Rec  =>  P_PICK_HEADER_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(CSP_PICKLIST_HEADERS_PKG.Update_Row)
      CSP_PICKLIST_HEADERS_PKG.Update_Row(
          p_picklist_header_id  => p_PICK_HEADER_rec.picklist_header_id,
          p_CREATED_BY  => p_PICK_HEADER_rec.CREATED_BY,
          p_CREATION_DATE  => p_PICK_HEADER_rec.CREATION_DATE,
          p_LAST_UPDATED_BY  => p_PICK_HEADER_rec.LAST_UPDATED_BY ,
          p_LAST_UPDATE_DATE  => p_PICK_HEADER_rec.LAST_UPDATE_DATE,
          p_LAST_UPDATE_LOGIN  => p_PICK_HEADER_rec.LAST_UPDATE_LOGIN ,
          p_ORGANIZATION_ID  => p_PICK_HEADER_rec.ORGANIZATION_ID,
          p_PICKLIST_NUMBER  => p_PICK_HEADER_rec.PICKLIST_NUMBER,
          p_PICKLIST_STATUS  => p_PICK_HEADER_rec.PICKLIST_STATUS,
          p_DATE_CREATED  => p_PICK_HEADER_rec.DATE_CREATED,
          p_DATE_CONFIRMED  => p_PICK_HEADER_rec.DATE_CONFIRMED,
          p_ATTRIBUTE_CATEGORY  => p_PICK_HEADER_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_PICK_HEADER_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_PICK_HEADER_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_PICK_HEADER_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_PICK_HEADER_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_PICK_HEADER_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_PICK_HEADER_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_PICK_HEADER_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_PICK_HEADER_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_PICK_HEADER_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_PICK_HEADER_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_PICK_HEADER_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_PICK_HEADER_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_PICK_HEADER_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_PICK_HEADER_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_PICK_HEADER_rec.ATTRIBUTE15);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Update_picklist_header_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PICK_HEADER_Rec      =>  P_PICK_HEADER_Rec,
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
End Update_picklist_header;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_picklist_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    --P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_PICK_HEADER_Rec     IN PICK_HEADER_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_picklist_header';
l_api_version_number      CONSTANT NUMBER   := 1.0;
--l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_picklist_header_PVT;

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
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Delete_picklist_header_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PICK_HEADER_Rec      =>  P_PICK_HEADER_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

/*      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
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
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');

      -- Invoke table handler(CSP_PICKLIST_HEADERS_PKG.Delete_Row)
      CSP_PICKLIST_HEADERS_PKG.Delete_Row(
          p_picklist_header_id  => p_PICK_HEADER_rec.picklist_header_id);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Delete_picklist_header_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PICK_HEADER_Rec      =>  P_PICK_HEADER_Rec,
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
End Delete_picklist_header;

/*
-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_PICK_HEADER_Rec   IN  CSP_picklist_header_PUB.PICK_HEADER_Rec_Type,
    p_cur_get_PICK_HEADER   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Begins');

      -- define all columns for CSP_PICKLIST_HEADERS_V view
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 1, P_PICK_HEADER_Rec.picklist_header_id);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 2, P_PICK_HEADER_Rec.ORGANIZATION_ID);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 3, P_PICK_HEADER_Rec.PICKLIST_NUMBER, 30);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 4, P_PICK_HEADER_Rec.PICKLIST_STATUS, 30);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 5, P_PICK_HEADER_Rec.DATE_CREATED);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 6, P_PICK_HEADER_Rec.DATE_CONFIRMED);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 7, P_PICK_HEADER_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 8, P_PICK_HEADER_Rec.ATTRIBUTE1, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 9, P_PICK_HEADER_Rec.ATTRIBUTE2, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 10, P_PICK_HEADER_Rec.ATTRIBUTE3, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 11, P_PICK_HEADER_Rec.ATTRIBUTE4, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 12, P_PICK_HEADER_Rec.ATTRIBUTE5, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 13, P_PICK_HEADER_Rec.ATTRIBUTE6, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 14, P_PICK_HEADER_Rec.ATTRIBUTE7, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 15, P_PICK_HEADER_Rec.ATTRIBUTE8, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 16, P_PICK_HEADER_Rec.ATTRIBUTE9, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 17, P_PICK_HEADER_Rec.ATTRIBUTE10, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 18, P_PICK_HEADER_Rec.ATTRIBUTE11, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 19, P_PICK_HEADER_Rec.ATTRIBUTE12, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 20, P_PICK_HEADER_Rec.ATTRIBUTE13, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 21, P_PICK_HEADER_Rec.ATTRIBUTE14, 240);
      dbms_sql.define_column(p_cur_get_PICK_HEADER, 22, P_PICK_HEADER_Rec.ATTRIBUTE15, 240);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_PICK_HEADER   IN   NUMBER,
    X_PICK_HEADER_Rec   OUT NOCOPY  CSP_picklist_header_PUB.PICK_HEADER_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Begins');

      -- get all column values for CSP_PICKLIST_HEADERS_V table
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 1, X_PICK_HEADER_Rec.picklist_header_id);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 2, X_PICK_HEADER_Rec.ORGANIZATION_ID);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 3, X_PICK_HEADER_Rec.PICKLIST_NUMBER);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 4, X_PICK_HEADER_Rec.PICKLIST_STATUS);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 5, X_PICK_HEADER_Rec.DATE_CREATED);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 6, X_PICK_HEADER_Rec.DATE_CONFIRMED);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 7, X_PICK_HEADER_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 8, X_PICK_HEADER_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 9, X_PICK_HEADER_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 10, X_PICK_HEADER_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 11, X_PICK_HEADER_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 12, X_PICK_HEADER_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 13, X_PICK_HEADER_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 14, X_PICK_HEADER_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 15, X_PICK_HEADER_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 16, X_PICK_HEADER_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 17, X_PICK_HEADER_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 18, X_PICK_HEADER_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 19, X_PICK_HEADER_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 20, X_PICK_HEADER_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 21, X_PICK_HEADER_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_PICK_HEADER, 22, X_PICK_HEADER_Rec.ATTRIBUTE15);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_PICK_HEADER_order_cl(
    p_order_by_rec   IN   CSP_picklist_header_PUB.PICK_HEADER_sort_rec_type,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Order by Begins');

      -- Hint: Developer should add more statements according to CSP_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Invoke JTF_PLSQL_API.Translate_OrderBy');

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Order by Ends');
END Gen_PICK_HEADER_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_PICK_HEADER_Rec   IN   CSP_picklist_header_PUB.PICK_HEADER_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_PICK_HEADER   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_PICK_HEADER_Rec.picklist_header_id IS NOT NULL) AND (P_PICK_HEADER_Rec.picklist_header_id <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_PICK_HEADER, ':p_picklist_header_id', P_PICK_HEADER_Rec.picklist_header_id);
      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Bind Variables Ends');
END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Begins');

      x_select_cl := 'Select ' ||
                'CSP_PICKLIST_HEADERS_V.picklist_header_id,' ||
                'CSP_PICKLIST_HEADERS_V.CREATED_BY,' ||
                'CSP_PICKLIST_HEADERS_V.CREATION_DATE,' ||
                'CSP_PICKLIST_HEADERS_V.LAST_UPDATED_BY,' ||
                'CSP_PICKLIST_HEADERS_V.LAST_UPDATE_DATE,' ||
                'CSP_PICKLIST_HEADERS_V.LAST_UPDATE_LOGIN,' ||
                'CSP_PICKLIST_HEADERS_V.ORGANIZATION_ID,' ||
                'CSP_PICKLIST_HEADERS_V.PICKLIST_NUMBER,' ||
                'CSP_PICKLIST_HEADERS_V.PICKLIST_STATUS,' ||
                'CSP_PICKLIST_HEADERS_V.DATE_CREATED,' ||
                'CSP_PICKLIST_HEADERS_V.DATE_CONFIRMED,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE_CATEGORY,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE1,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE2,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE3,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE4,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE5,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE6,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE7,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE8,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE9,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE10,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE11,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE12,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE13,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE14,' ||
                'CSP_PICKLIST_HEADERS_V.ATTRIBUTE15,' ||
                'from CSP_PICKLIST_HEADERS_V';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_PICK_HEADER_Where(
    P_PICK_HEADER_Rec     IN   CSP_picklist_header_PUB.PICK_HEADER_Rec_Type,
    x_PICK_HEADER_where   OUT NOCOPY   VARCHAR2
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Begins');

      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_PICK_HEADER_Rec.picklist_header_id IS NOT NULL) AND (P_PICK_HEADER_Rec.picklist_header_id <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_PICK_HEADER_where IS NULL) THEN
              x_PICK_HEADER_where := 'Where';
          ELSE
              x_PICK_HEADER_where := x_PICK_HEADER_where || ' AND ';
          END IF;
          x_PICK_HEADER_where := x_PICK_HEADER_where || 'P_PICK_HEADER_Rec.picklist_header_id = :p_picklist_header_id';
      END IF;

      -- example for DATE datatype
      IF( (P_PICK_HEADER_Rec.CREATION_DATE IS NOT NULL) AND (P_PICK_HEADER_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_PICK_HEADER_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_PICK_HEADER_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_PICK_HEADER_where IS NULL) THEN
              x_PICK_HEADER_where := 'Where ';
          ELSE
              x_PICK_HEADER_where := x_PICK_HEADER_where || ' AND ';
          END IF;
          x_PICK_HEADER_where := x_PICK_HEADER_where || 'P_PICK_HEADER_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_PICK_HEADER_Rec.PICKLIST_NUMBER IS NOT NULL) AND (P_PICK_HEADER_Rec.PICKLIST_NUMBER <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_PICK_HEADER_Rec.PICKLIST_NUMBER);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_PICK_HEADER_Rec.PICKLIST_NUMBER);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_PICK_HEADER_where IS NULL) THEN
              x_PICK_HEADER_where := 'Where ';
          ELSE
              x_PICK_HEADER_where := x_PICK_HEADER_where || ' AND ';
          END IF;
          x_PICK_HEADER_where := x_PICK_HEADER_where || 'P_PICK_HEADER_Rec.PICKLIST_NUMBER ' || l_operator || ' :p_PICKLIST_NUMBER';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Generate Where Ends');

END Gen_PICK_HEADER_Where;

*/
-- Item-level validation procedures
PROCEDURE Validate_picklist_header_id (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_picklist_header_id                IN   NUMBER,
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
      IF(p_picklist_header_id is NULL)
      THEN
          --JTF_PLSQL_API.Debug_Message('ERROR', 'Private picklist_header API: -Violate NOT NULL constraint(picklist_header_id)');

          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'ERROR', 'Private picklist_header API: -Violate NOT NULL constraint(picklist_header_id)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode =JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_picklist_header_id is not NULL and p_picklist_header_id <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_picklist_header_id <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_picklist_header_id;


PROCEDURE Validate_ORGANIZATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORGANIZATION_ID                IN   NUMBER,
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
      IF(p_ORGANIZATION_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'ERROR', 'Private picklist_header API: -Violate NOT NULL constraint(ORGANIZATION_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORGANIZATION_ID is not NULL and p_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ORGANIZATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORGANIZATION_ID;


PROCEDURE Validate_PICKLIST_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PICKLIST_NUMBER                IN   VARCHAR2,
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
          -- IF p_PICKLIST_NUMBER is not NULL and p_PICKLIST_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICKLIST_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PICKLIST_NUMBER;


PROCEDURE Validate_PICKLIST_STATUS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PICKLIST_STATUS                IN   VARCHAR2,
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
      IF(p_PICKLIST_STATUS is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'ERROR', 'Private picklist_header API: -Violate NOT NULL constraint(PICKLIST_STATUS)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICKLIST_STATUS is not NULL and p_PICKLIST_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICKLIST_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PICKLIST_STATUS;


PROCEDURE Validate_DATE_CREATED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DATE_CREATED                IN   DATE,
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
          -- IF p_DATE_CREATED is not NULL and p_DATE_CREATED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DATE_CREATED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DATE_CREATED;


PROCEDURE Validate_DATE_CONFIRMED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DATE_CONFIRMED                IN   DATE,
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
          -- IF p_DATE_CONFIRMED is not NULL and p_DATE_CONFIRMED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DATE_CONFIRMED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DATE_CONFIRMED;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_PLSQL_API.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_PICK_HEADER_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PICK_HEADER_Rec     IN    PICK_HEADER_Rec_Type,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Error', 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PICK_HEADER_Rec;

PROCEDURE Validate_picklist_header(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PICK_HEADER_Rec     IN    PICK_HEADER_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_picklist_header';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Error', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_picklist_header_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_picklist_header_id   => P_PICK_HEADER_Rec.picklist_header_id,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORGANIZATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ORGANIZATION_ID   => P_PICK_HEADER_Rec.ORGANIZATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PICKLIST_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PICKLIST_NUMBER   => P_PICK_HEADER_Rec.PICKLIST_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PICKLIST_STATUS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PICKLIST_STATUS   => P_PICK_HEADER_Rec.PICKLIST_STATUS,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DATE_CREATED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DATE_CREATED   => P_PICK_HEADER_Rec.DATE_CREATED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DATE_CONFIRMED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DATE_CONFIRMED   => P_PICK_HEADER_Rec.DATE_CONFIRMED,
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
          Validate_PICK_HEADER_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_PICK_HEADER_Rec     =>    P_PICK_HEADER_Rec,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Error', 'Private API: ' || l_api_name || 'end');

END Validate_picklist_header;

End CSP_picklist_header_PVT;

/
