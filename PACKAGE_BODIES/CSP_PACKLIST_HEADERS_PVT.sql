--------------------------------------------------------
--  DDL for Package Body CSP_PACKLIST_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PACKLIST_HEADERS_PVT" AS
/* $Header: cspvtahb.pls 115.10 2003/05/02 17:13:31 phegde ship $ */
-- Start of Comments
-- Package name     : CSP_Packlist_Headers_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_Packlist_Headers_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvtahb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_packlist_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_PLH_Rec     IN    PLH_Rec_Type  := G_MISS_PLH_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_PACKLIST_HEADER_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_packlist_headers';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Packlist_Headers_PVT;

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
          AS_CALLOUT_PKG.Create_packlist_headers_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_PLH_Rec      =>  P_PLH_Rec,
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

/*
      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 1.0
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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Validate_packlist_headers');

          -- Invoke validation procedures
          Validate_packlist_headers(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_PLH_Rec  =>  P_PLH_Rec,
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

      -- Invoke table handler(CSP_PACKLIST_HEADERS_PKG.Insert_Row)
      CSP_PACKLIST_HEADERS_PKG.Insert_Row(
          px_PACKLIST_HEADER_ID  => x_PACKLIST_HEADER_ID,
          p_CREATED_BY  => p_PLH_rec.CREATED_BY,
          p_CREATION_DATE  => p_PLH_rec.CREATION_DATE,
          p_LAST_UPDATED_BY  => p_PLH_rec.LAST_UPDATED_BY,
          p_LAST_UPDATE_DATE  => p_PLH_rec.LAST_UPDATE_DATE,
          p_LAST_UPDATE_LOGIN  => p_PLH_rec.LAST_UPDATE_LOGIN,
          p_ORGANIZATION_ID  => p_PLH_rec.ORGANIZATION_ID,
          p_PACKLIST_NUMBER  => p_PLH_rec.PACKLIST_NUMBER,
          p_SUBINVENTORY_CODE  => p_PLH_rec.SUBINVENTORY_CODE,
          p_PACKLIST_STATUS  => p_PLH_rec.PACKLIST_STATUS,
          p_DATE_CREATED  => p_PLH_rec.DATE_CREATED,
          p_DATE_PACKED  => p_PLH_rec.DATE_PACKED,
          p_DATE_SHIPPED  => p_PLH_rec.DATE_SHIPPED,
          p_DATE_RECEIVED  => p_PLH_rec.DATE_RECEIVED,
          p_CARRIER  => p_PLH_rec.CARRIER,
          p_SHIPMENT_METHOD  => p_PLH_rec.SHIPMENT_METHOD,
          p_WAYBILL  => p_PLH_rec.WAYBILL,
          p_COMMENTS  => p_PLH_rec.COMMENTS,
          p_LOCATION_ID  => p_PLH_rec.LOCATION_ID,
          p_PARTY_SITE_ID  => p_PLH_rec.PARTY_SITE_ID,
          p_ATTRIBUTE_CATEGORY  => p_PLH_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_PLH_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_PLH_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_PLH_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_PLH_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_PLH_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_PLH_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_PLH_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_PLH_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_PLH_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_PLH_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_PLH_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_PLH_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_PLH_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_PLH_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_PLH_rec.ATTRIBUTE15);
      -- Hint: Primary key should be returned.
      -- x_PACKLIST_HEADER_ID := px_PACKLIST_HEADER_ID;

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
          AS_CALLOUT_PKG.Create_packlist_headers_AC(
                  p_api_version_number => 1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_PLH_Rec      =>  P_PLH_Rec,
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
End Create_packlist_headers;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_packlist_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_PLH_Rec     IN    PLH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_packlist_headers(PACKLIST_HEADER_ID Number) IS
    Select rowid,
           PACKLIST_HEADER_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PACKLIST_NUMBER,
           SUBINVENTORY_CODE,
           PACKLIST_STATUS,
           DATE_CREATED,
           DATE_PACKED,
           DATE_SHIPPED,
           DATE_RECEIVED,
           CARRIER,
           SHIPMENT_METHOD,
           WAYBILL,
           COMMENTS,
           LOCATION_ID,
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
    From  CSP_PACKLIST_HEADERS
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_packlist_headers';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_PLH_rec  CSP_packlist_headers_PVT.PLH_Rec_Type;
l_tar_PLH_rec  CSP_packlist_headers_PVT.PLH_Rec_Type := P_PLH_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Packlist_Headers_PVT;
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
          AS_CALLOUT_PKG.Update_packlist_headers_BU(
                  p_api_version_number => 1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PLH_Rec      =>  P_PLH_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
/*
      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 1.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;*/

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: - Open Cursor to Select');

/*
      Open C_Get_packlist_headers( l_tar_PLH_rec.PACKLIST_HEADER_ID);

      Fetch C_Get_packlist_headers into
               l_rowid,
               l_ref_PLH_rec.PACKLIST_HEADER_ID,
               l_ref_PLH_rec.CREATED_BY,
               l_ref_PLH_rec.CREATION_DATE,
               l_ref_PLH_rec.LAST_UPDATED_BY,
               l_ref_PLH_rec.LAST_UPDATE_DATE,
               l_ref_PLH_rec.LAST_UPDATE_LOGIN,
               l_ref_PLH_rec.ORGANIZATION_ID,
               l_ref_PLH_rec.PACKLIST_NUMBER,
               l_ref_PLH_rec.SUBINVENTORY_CODE,
               l_ref_PLH_rec.PACKLIST_STATUS,
               l_ref_PLH_rec.DATE_CREATED,
               l_ref_PLH_rec.DATE_PACKED,
               l_ref_PLH_rec.DATE_SHIPPED,
               l_ref_PLH_rec.DATE_RECEIVED,
               l_ref_PLH_rec.CARRIER,
               l_ref_PLH_rec.SHIPMENT_METHOD,
               l_ref_PLH_rec.WAYBILL,
               l_ref_PLH_rec.COMMENTS,
               l_ref_PLH_rec.LOCATION_ID,
               l_ref_PLH_rec.ATTRIBUTE_CATEGORY,
               l_ref_PLH_rec.ATTRIBUTE1,
               l_ref_PLH_rec.ATTRIBUTE2,
               l_ref_PLH_rec.ATTRIBUTE3,
               l_ref_PLH_rec.ATTRIBUTE4,
               l_ref_PLH_rec.ATTRIBUTE5,
               l_ref_PLH_rec.ATTRIBUTE6,
               l_ref_PLH_rec.ATTRIBUTE7,
               l_ref_PLH_rec.ATTRIBUTE8,
               l_ref_PLH_rec.ATTRIBUTE9,
               l_ref_PLH_rec.ATTRIBUTE10,
               l_ref_PLH_rec.ATTRIBUTE11,
               l_ref_PLH_rec.ATTRIBUTE12,
               l_ref_PLH_rec.ATTRIBUTE13,
               l_ref_PLH_rec.ATTRIBUTE14,
               l_ref_PLH_rec.ATTRIBUTE15;

       If ( C_Get_packlist_headers%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'packlist_headers', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: - Close Cursor');
       Close     C_Get_packlist_headers;



      If (l_tar_PLH_rec.last_update_date is NULL or
          l_tar_PLH_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_PLH_rec.last_update_date <> l_ref_PLH_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'packlist_headers', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Validate_packlist_headers');

          -- Invoke validation procedures
          Validate_packlist_headers(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_PLH_Rec  =>  P_PLH_Rec,
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

      -- Invoke table handler(CSP_PACKLIST_HEADERS_PKG.Update_Row)
      CSP_PACKLIST_HEADERS_PKG.Update_Row(
          p_PACKLIST_HEADER_ID  => p_PLH_rec.PACKLIST_HEADER_ID,
          p_CREATED_BY  => p_PLH_rec.CREATED_BY,
          p_CREATION_DATE  => p_PLH_rec.CREATION_DATE,
          p_LAST_UPDATED_BY  => p_PLH_rec.LAST_UPDATED_BY,
          p_LAST_UPDATE_DATE  => p_PLH_rec.LAST_UPDATE_DATE,
          p_LAST_UPDATE_LOGIN  => p_PLH_rec.LAST_UPDATE_LOGIN,
          p_ORGANIZATION_ID  => p_PLH_rec.ORGANIZATION_ID,
          p_PACKLIST_NUMBER  => p_PLH_rec.PACKLIST_NUMBER,
          p_SUBINVENTORY_CODE  => p_PLH_rec.SUBINVENTORY_CODE,
          p_PACKLIST_STATUS  => p_PLH_rec.PACKLIST_STATUS,
          p_DATE_CREATED  => p_PLH_rec.DATE_CREATED,
          p_DATE_PACKED  => p_PLH_rec.DATE_PACKED,
          p_DATE_SHIPPED  => p_PLH_rec.DATE_SHIPPED,
          p_DATE_RECEIVED  => p_PLH_rec.DATE_RECEIVED,
          p_CARRIER  => p_PLH_rec.CARRIER,
          p_SHIPMENT_METHOD  => p_PLH_rec.SHIPMENT_METHOD,
          p_WAYBILL  => p_PLH_rec.WAYBILL,
          p_COMMENTS  => p_PLH_rec.COMMENTS,
          p_LOCATION_ID  => p_PLH_rec.LOCATION_ID,
          p_PARTY_SITE_ID  => p_PLH_rec.PARTY_SITE_ID,
          p_ATTRIBUTE_CATEGORY  => p_PLH_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_PLH_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_PLH_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_PLH_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_PLH_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_PLH_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_PLH_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_PLH_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_PLH_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_PLH_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_PLH_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_PLH_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_PLH_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_PLH_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_PLH_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_PLH_rec.ATTRIBUTE15);
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
          AS_CALLOUT_PKG.Update_packlist_headers_AU(
                  p_api_version_number => 1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PLH_Rec      =>  P_PLH_Rec,
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
End Update_packlist_headers;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_packlist_headers(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_PLH_Rec     IN PLH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_packlist_headers';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Packlist_Headers_PVT;

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
          AS_CALLOUT_PKG.Delete_packlist_headers_BD(
                  p_api_version_number => 1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PLH_Rec      =>  P_PLH_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
/*
      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 1.0
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

      -- Invoke table handler(CSP_PACKLIST_HEADERS_PKG.Delete_Row)
      CSP_PACKLIST_HEADERS_PKG.Delete_Row(
          p_PACKLIST_HEADER_ID  => p_PLH_rec.PACKLIST_HEADER_ID);
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
          AS_CALLOUT_PKG.Delete_packlist_headers_AD(
                  p_api_version_number => 1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PLH_Rec      =>  P_PLH_Rec,
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
End Delete_packlist_headers;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_PLH_Rec   IN  CSP_Packlist_Headers_PUB.PLH_Rec_Type,
    p_cur_get_PLH   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Define Columns Begins');

      -- define all columns for CSP_PACKLIST_HEADERS_V view
      dbms_sql.define_column(p_cur_get_PLH, 1, P_PLH_Rec.PACKLIST_HEADER_ID);
      dbms_sql.define_column(p_cur_get_PLH, 2, P_PLH_Rec.ORGANIZATION_ID);
      dbms_sql.define_column(p_cur_get_PLH, 3, P_PLH_Rec.PACKLIST_NUMBER, 10);
      dbms_sql.define_column(p_cur_get_PLH, 4, P_PLH_Rec.SUBINVENTORY_CODE, 10);
      dbms_sql.define_column(p_cur_get_PLH, 5, P_PLH_Rec.PACKLIST_STATUS, 30);
      dbms_sql.define_column(p_cur_get_PLH, 6, P_PLH_Rec.DATE_CREATED);
      dbms_sql.define_column(p_cur_get_PLH, 7, P_PLH_Rec.DATE_PACKED);
      dbms_sql.define_column(p_cur_get_PLH, 8, P_PLH_Rec.DATE_SHIPPED);
      dbms_sql.define_column(p_cur_get_PLH, 9, P_PLH_Rec.DATE_RECEIVED);
      dbms_sql.define_column(p_cur_get_PLH, 10, P_PLH_Rec.CARRIER, 60);
      dbms_sql.define_column(p_cur_get_PLH, 11, P_PLH_Rec.SHIPMENT_METHOD, 60);
      dbms_sql.define_column(p_cur_get_PLH, 12, P_PLH_Rec.WAYBILL, 60);
      dbms_sql.define_column(p_cur_get_PLH, 13, P_PLH_Rec.COMMENTS, 240);
      dbms_sql.define_column(p_cur_get_PLH, 15, P_PLH_Rec.LOCATION_ID);
      dbms_sql.define_column(p_cur_get_PLH, 16, P_PLH_Rec.PARTY_SITE_ID);
      dbms_sql.define_column(p_cur_get_PLH, 23, P_PLH_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_PLH, 24, P_PLH_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_PLH, 25, P_PLH_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_PLH, 26, P_PLH_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_PLH, 27, P_PLH_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_PLH, 28, P_PLH_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_PLH, 29, P_PLH_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_PLH, 30, P_PLH_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_PLH, 31, P_PLH_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_PLH, 32, P_PLH_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_PLH, 33, P_PLH_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_PLH, 34, P_PLH_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_PLH, 35, P_PLH_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_PLH, 36, P_PLH_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_PLH, 37, P_PLH_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_PLH, 38, P_PLH_Rec.ATTRIBUTE15, 150);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_PLH   IN   NUMBER,
    X_PLH_Rec   OUT NOCOPY  CSP_Packlist_Headers_PUB.PLH_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Get Column Values Begins');

      -- get all column values for CSP_PACKLIST_HEADERS_V table
      dbms_sql.column_value(p_cur_get_PLH, 1, X_PLH_Rec.ROW_ID);
      dbms_sql.column_value(p_cur_get_PLH, 2, X_PLH_Rec.PACKLIST_HEADER_ID);
      dbms_sql.column_value(p_cur_get_PLH, 3, X_PLH_Rec.ORGANIZATION_ID);
      dbms_sql.column_value(p_cur_get_PLH, 4, X_PLH_Rec.PACKLIST_NUMBER);
      dbms_sql.column_value(p_cur_get_PLH, 5, X_PLH_Rec.SUBINVENTORY_CODE);
      dbms_sql.column_value(p_cur_get_PLH, 6, X_PLH_Rec.PACKLIST_STATUS);
      dbms_sql.column_value(p_cur_get_PLH, 7, X_PLH_Rec.DATE_CREATED);
      dbms_sql.column_value(p_cur_get_PLH, 8, X_PLH_Rec.DATE_PACKED);
      dbms_sql.column_value(p_cur_get_PLH, 9, X_PLH_Rec.DATE_SHIPPED);
      dbms_sql.column_value(p_cur_get_PLH, 10, X_PLH_Rec.DATE_RECEIVED);
      dbms_sql.column_value(p_cur_get_PLH, 11, X_PLH_Rec.CARRIER);
      dbms_sql.column_value(p_cur_get_PLH, 12, X_PLH_Rec.SHIPMENT_METHOD);
      dbms_sql.column_value(p_cur_get_PLH, 13, X_PLH_Rec.WAYBILL);
      dbms_sql.column_value(p_cur_get_PLH, 14, X_PLH_Rec.COMMENTS);
      dbms_sql.define_column(p_cur_get_PLH,15, x_PLH_Rec.LOCATION_ID);
      dbms_sql.define_column(p_cur_get_PLH,16, x_PLH_Rec.PARTY_SITE_ID);
      dbms_sql.column_value(p_cur_get_PLH, 24, X_PLH_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_PLH, 25, X_PLH_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_PLH, 26, X_PLH_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_PLH, 27, X_PLH_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_PLH, 28, X_PLH_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_PLH, 29, X_PLH_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_PLH, 30, X_PLH_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_PLH, 31, X_PLH_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_PLH, 32, X_PLH_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_PLH, 33, X_PLH_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_PLH, 34, X_PLH_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_PLH, 35, X_PLH_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_PLH, 36, X_PLH_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_PLH, 37, X_PLH_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_PLH, 38, X_PLH_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_PLH, 39, X_PLH_Rec.ATTRIBUTE15);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_PLH_order_cl(
    p_order_by_rec   IN   CSP_Packlist_Headers_PUB.PLH_sort_rec_type,
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
END Gen_PLH_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_PLH_Rec   IN   CSP_Packlist_Headers_PUB.PLH_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_PLH   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_PLH_Rec.PACKLIST_HEADER_ID IS NOT NULL) AND (P_PLH_Rec.PACKLIST_HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_PLH, ':p_PACKLIST_HEADER_ID', P_PLH_Rec.PACKLIST_HEADER_ID);
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
                'CSP_PACKLIST_HEADERS_V.ROW_ID,' ||
                'CSP_PACKLIST_HEADERS_V.PACKLIST_HEADER_ID,' ||
                'CSP_PACKLIST_HEADERS_V.CREATED_BY,' ||
                'CSP_PACKLIST_HEADERS_V.CREATION_DATE,' ||
                'CSP_PACKLIST_HEADERS_V.LAST_UPDATED_BY,' ||
                'CSP_PACKLIST_HEADERS_V.LAST_UPDATE_DATE,' ||
                'CSP_PACKLIST_HEADERS_V.LAST_UPDATE_LOGIN,' ||
                'CSP_PACKLIST_HEADERS_V.ORGANIZATION_ID,' ||
                'CSP_PACKLIST_HEADERS_V.PACKLIST_NUMBER,' ||
                'CSP_PACKLIST_HEADERS_V.SUBINVENTORY_CODE,' ||
                'CSP_PACKLIST_HEADERS_V.PACKLIST_STATUS,' ||
                'CSP_PACKLIST_HEADERS_V.DATE_CREATED,' ||
                'CSP_PACKLIST_HEADERS_V.DATE_PACKED,' ||
                'CSP_PACKLIST_HEADERS_V.DATE_SHIPPED,' ||
                'CSP_PACKLIST_HEADERS_V.DATE_RECEIVED,' ||
                'CSP_PACKLIST_HEADERS_V.CARRIER,' ||
                'CSP_PACKLIST_HEADERS_V.SHIPMENT_METHOD,' ||
                'CSP_PACKLIST_HEADERS_V.WAYBILL,' ||
                'CSP_PACKLIST_HEADERS_V.COMMENTS,' ||
                'CSP_PACKLIST_HEADERS_V.LOCATION_ID,' ||
                'CSP_PACKLIST_HEADERS_V.PARTY_SITE_ID,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE_CATEGORY,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE1,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE2,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE3,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE4,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE5,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE6,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE7,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE8,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE9,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE10,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE11,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE12,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE13,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE14,' ||
                'CSP_PACKLIST_HEADERS_V.ATTRIBUTE15,' ||
                'from CSP_PACKLIST_HEADERS_V';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_PLH_Where(
    P_PLH_Rec     IN   CSP_Packlist_Headers_PUB.PLH_Rec_Type,
    x_PLH_where   OUT NOCOPY   VARCHAR2
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
      IF( (P_PLH_Rec.PACKLIST_HEADER_ID IS NOT NULL) AND (P_PLH_Rec.PACKLIST_HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_PLH_where IS NULL) THEN
              x_PLH_where := 'Where';
          ELSE
              x_PLH_where := x_PLH_where || ' AND ';
          END IF;
          x_PLH_where := x_PLH_where || 'P_PLH_Rec.PACKLIST_HEADER_ID = :p_PACKLIST_HEADER_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_PLH_Rec.CREATION_DATE IS NOT NULL) AND (P_PLH_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_PLH_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_PLH_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_PLH_where IS NULL) THEN
              x_PLH_where := 'Where ';
          ELSE
              x_PLH_where := x_PLH_where || ' AND ';
          END IF;
          x_PLH_where := x_PLH_where || 'P_PLH_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_PLH_Rec.PACKLIST_NUMBER IS NOT NULL) AND (P_PLH_Rec.PACKLIST_NUMBER <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_PLH_Rec.PACKLIST_NUMBER);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_PLH_Rec.PACKLIST_NUMBER);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_PLH_where IS NULL) THEN
              x_PLH_where := 'Where ';
          ELSE
              x_PLH_where := x_PLH_where || ' AND ';
          END IF;
          x_PLH_where := x_PLH_where || 'P_PLH_Rec.PACKLIST_NUMBER ' || l_operator || ' :p_PACKLIST_NUMBER';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Where Ends');

END Gen_PLH_Where;

-- Item-level validation procedures
PROCEDURE Validate_PACKLIST_HEADER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PACKLIST_HEADER_ID                IN   NUMBER,
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
      IF(p_PACKLIST_HEADER_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_headers API: -Violate NOT NULL
constraint(PACKLIST_HEADER_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_HEADER_ID is not NULL and p_PACKLIST_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PACKLIST_HEADER_ID;


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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_headers API: -Violate NOT NULL
constraint(ORGANIZATION_ID)');
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


PROCEDURE Validate_PACKLIST_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PACKLIST_NUMBER                IN   VARCHAR2,
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
      IF(p_PACKLIST_NUMBER is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_headers API: -Violate NOT NULL
constraint(PACKLIST_NUMBER)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_NUMBER is not NULL and p_PACKLIST_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PACKLIST_NUMBER;


PROCEDURE Validate_SUBINVENTORY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SUBINVENTORY_CODE                IN   VARCHAR2,
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
      IF(p_SUBINVENTORY_CODE is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_headers API: -Violate NOT NULL
constraint(SUBINVENTORY_CODE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUBINVENTORY_CODE is not NULL and p_SUBINVENTORY_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SUBINVENTORY_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SUBINVENTORY_CODE;


PROCEDURE Validate_PACKLIST_STATUS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PACKLIST_STATUS                IN   VARCHAR2,
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
      IF(p_PACKLIST_STATUS is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_headers API: -Violate NOT NULL
constraint(PACKLIST_STATUS)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_STATUS is not NULL and p_PACKLIST_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PACKLIST_STATUS;


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

      -- validate NOT NULL column
      IF(p_DATE_CREATED is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_headers API: -Violate NOT NULL
constraint(DATE_CREATED)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

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


PROCEDURE Validate_DATE_PACKED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DATE_PACKED                IN   DATE,
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
          -- IF p_DATE_PACKED is not NULL and p_DATE_PACKED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DATE_PACKED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DATE_PACKED;


PROCEDURE Validate_DATE_SHIPPED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DATE_SHIPPED                IN   DATE,
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
          -- IF p_DATE_SHIPPED is not NULL and p_DATE_SHIPPED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DATE_SHIPPED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DATE_SHIPPED;


PROCEDURE Validate_DATE_RECEIVED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DATE_RECEIVED                IN   DATE,
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
          -- IF p_DATE_RECEIVED is not NULL and p_DATE_RECEIVED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DATE_RECEIVED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DATE_RECEIVED;


PROCEDURE Validate_CARRIER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CARRIER                IN   VARCHAR2,
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
          -- IF p_CARRIER is not NULL and p_CARRIER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CARRIER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CARRIER;


PROCEDURE Validate_SHIPMENT_METHOD (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SHIPMENT_METHOD                IN   VARCHAR2,
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
          -- IF p_SHIPMENT_METHOD is not NULL and p_SHIPMENT_METHOD <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_SHIPMENT_METHOD <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SHIPMENT_METHOD;


PROCEDURE Validate_WAYBILL (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_WAYBILL                IN   VARCHAR2,
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
          -- IF p_WAYBILL is not NULL and p_WAYBILL <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_WAYBILL <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_WAYBILL;


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
PROCEDURE Validate_PLH_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PLH_Rec     IN    PLH_Rec_Type,
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

END Validate_PLH_Rec;

PROCEDURE Validate_packlist_headers(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PLH_Rec     IN    PLH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_packlist_headers';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_PACKLIST_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PACKLIST_HEADER_ID   => P_PLH_Rec.PACKLIST_HEADER_ID,
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
              p_ORGANIZATION_ID   => P_PLH_Rec.ORGANIZATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PACKLIST_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PACKLIST_NUMBER   => P_PLH_Rec.PACKLIST_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SUBINVENTORY_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SUBINVENTORY_CODE   => P_PLH_Rec.SUBINVENTORY_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PACKLIST_STATUS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PACKLIST_STATUS   => P_PLH_Rec.PACKLIST_STATUS,
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
              p_DATE_CREATED   => P_PLH_Rec.DATE_CREATED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DATE_PACKED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DATE_PACKED   => P_PLH_Rec.DATE_PACKED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DATE_SHIPPED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DATE_SHIPPED   => P_PLH_Rec.DATE_SHIPPED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DATE_RECEIVED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DATE_RECEIVED   => P_PLH_Rec.DATE_RECEIVED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CARRIER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CARRIER   => P_PLH_Rec.CARRIER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SHIPMENT_METHOD(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SHIPMENT_METHOD   => P_PLH_Rec.SHIPMENT_METHOD,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_WAYBILL(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_WAYBILL   => P_PLH_Rec.WAYBILL,
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
              p_COMMENTS   => P_PLH_Rec.COMMENTS,
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
          Validate_PLH_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_PLH_Rec     =>    P_PLH_Rec,
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

END Validate_packlist_headers;

End CSP_Packlist_Headers_PVT;

/
