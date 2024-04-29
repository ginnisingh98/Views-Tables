--------------------------------------------------------
--  DDL for Package Body CSP_ORDERHEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_ORDERHEADERS_PVT" AS
/* $Header: cspvtmhb.pls 115.14 2003/05/02 17:17:21 phegde ship $ */
-- Start of Comments
-- Package name     : CSP_ORDERHEADERS_PVT
-- Purpose          :
-- History          :
-- NOTE             : CSP - api_version_number 1.0
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_ORDERHEADERS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvtmhb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_orderheaders(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_MOH_Rec     IN    MOH_Rec_Type  := G_MISS_MOH_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_HEADER_ID                 OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_orderheaders';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ORDERHEADERS_PVT;

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
          AS_CALLOUT_PKG.Create_orderheaders_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_MOH_Rec      =>  P_MOH_Rec,
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
       The following codes of geting the current user associtated with a saleforce_id is commented out.
       by CSP. 06-DEC-99.

      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => NULL
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_error := 'In as_sales';
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    */

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Validate_orderheaders');

          -- Invoke validation procedures
          Validate_orderheaders(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_MOH_Rec  =>  P_MOH_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data
              );
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Calling create table handler');


      -- Invoke table handler(CSP_MOVEORDER_HEADERS_PKG.Insert_Row)
      CSP_MOVEORDER_HEADERS_PKG.Insert_Row(
          p_HEADER_ID  => p_MOH_rec.HEADER_ID,
          p_CREATED_BY  => p_MOH_rec.created_by,
          p_CREATION_DATE  => p_MOH_rec.creation_date,
          p_LAST_UPDATED_BY  => p_MOH_rec.last_updated_by,
          p_LAST_UPDATE_DATE  => p_MOH_rec.last_update_date,
          p_LAST_UPDATE_LOGIN  => p_MOH_rec.last_update_login,
          p_CARRIER  => p_MOH_rec.CARRIER,
          p_SHIPMENT_METHOD  => p_MOH_rec.SHIPMENT_METHOD,
          p_AUTORECEIPT_FLAG  => p_MOH_rec.AUTORECEIPT_FLAG,
          p_ATTRIBUTE_CATEGORY  => p_MOH_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_MOH_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_MOH_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_MOH_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_MOH_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_MOH_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_MOH_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_MOH_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_MOH_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_MOH_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_MOH_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_MOH_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_MOH_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_MOH_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_MOH_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_MOH_rec.ATTRIBUTE15,
          P_LOCATION_ID => P_MOH_REC.LOCATION_ID,
          p_PARTY_SITE_ID => P_MOH_REC.PARTY_SITE_ID
          );
      -- Hint: Primary key should be returned.
      -- x_HEADER_ID := px_HEADER_ID;

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
          AS_CALLOUT_PKG.Create_orderheaders_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_MOH_Rec      =>  P_MOH_Rec,
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
End Create_orderheaders;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_orderheaders(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_MOH_Rec     IN    MOH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

/*
Cursor C_Get_orderheaders(HEADER_ID Number) IS
    Select rowid,
           HEADER_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LOCATION_ID,
           CARRIER,
           SHIPMENT_METHOD,
           AUTORECEIPT_FLAG,
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
           ADDRESS1,
           ADDRESS2,
           ADDRESS3,
           ADDRESS4,
           CITY,
           POSTAL_CODE,
           STATE,
           PROVINCE,
           COUNTRY
    From  CSP_MOVEORDER_HEADERS
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_orderheaders';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_MOH_rec  CSP_orderheaders_PVT.MOH_Rec_Type;
l_tar_MOH_rec  CSP_orderheaders_PVT.MOH_Rec_Type := P_MOH_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_ORDERHEADERS_PVT;

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
          AS_CALLOUT_PKG.Update_orderheaders_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_MOH_Rec      =>  P_MOH_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/


/* Comment out the Get_CurrentUser by CSP. 06-DEC-99.

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
      Open C_Get_orderheaders( l_tar_MOH_rec.HEADER_ID);

      Fetch C_Get_orderheaders into
               l_rowid,
               l_ref_MOH_rec.HEADER_ID,
               l_ref_MOH_rec.CREATED_BY,
               l_ref_MOH_rec.CREATION_DATE,
               l_ref_MOH_rec.LAST_UPDATED_BY,
               l_ref_MOH_rec.LAST_UPDATE_DATE,
               l_ref_MOH_rec.LAST_UPDATE_LOGIN,
               l_ref_MOH_rec.LOCATION_ID,
               l_ref_MOH_rec.CARRIER,
               l_ref_MOH_rec.SHIPMENT_METHOD,
               l_ref_MOH_rec.AUTORECEIPT_FLAG,
               l_ref_MOH_rec.ATTRIBUTE_CATEGORY,
               l_ref_MOH_rec.ATTRIBUTE1,
               l_ref_MOH_rec.ATTRIBUTE2,
               l_ref_MOH_rec.ATTRIBUTE3,
               l_ref_MOH_rec.ATTRIBUTE4,
               l_ref_MOH_rec.ATTRIBUTE5,
               l_ref_MOH_rec.ATTRIBUTE6,
               l_ref_MOH_rec.ATTRIBUTE7,
               l_ref_MOH_rec.ATTRIBUTE8,
               l_ref_MOH_rec.ATTRIBUTE9,
               l_ref_MOH_rec.ATTRIBUTE10,
               l_ref_MOH_rec.ATTRIBUTE11,
               l_ref_MOH_rec.ATTRIBUTE12,
               l_ref_MOH_rec.ATTRIBUTE13,
               l_ref_MOH_rec.ATTRIBUTE14,
               l_ref_MOH_rec.ATTRIBUTE15,
               l_ref_MOH_rec.ADDRESS1,
               l_ref_MOH_rec.ADDRESS2,
               l_ref_MOH_rec.ADDRESS3,
               l_ref_MOH_rec.ADDRESS4,
               l_ref_MOH_rec.CITY,
               l_ref_MOH_rec.POSTAL_CODE,
               l_ref_MOH_rec.STATE,
               l_ref_MOH_rec.PROVINCE,
               l_ref_MOH_rec.COUNTRY;

       If ( C_Get_orderheaders%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'orderheaders', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: - Close Cursor');
       Close     C_Get_orderheaders;
*/

/*  uncommented out and will
      If (l_tar_MOH_rec.last_update_date is NULL or
          l_tar_MOH_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_MOH_rec.last_update_date <> l_ref_MOH_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'orderheaders', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Validate_orderheaders');

         -- Invoke validation procedures
          Validate_orderheaders(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_MOH_Rec  =>  P_MOH_Rec,
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

      -- Invoke table handler(CSP_MOVEORDER_HEADERS_PKG.Update_Row)
      CSP_MOVEORDER_HEADERS_PKG.Update_Row(
          p_HEADER_ID  => p_MOH_rec.HEADER_ID,
          p_CREATED_BY  => p_MOH_rec.created_by,
          p_CREATION_DATE  => p_MOH_rec.creation_date,
          p_LAST_UPDATED_BY  => p_MOH_rec.LAST_UPDATED_BY,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_MOH_rec.LAST_UPDATE_LOGIN,
           p_CARRIER  => p_MOH_rec.CARRIER,
          p_SHIPMENT_METHOD  => p_MOH_rec.SHIPMENT_METHOD,
          p_AUTORECEIPT_FLAG  => p_MOH_rec.AUTORECEIPT_FLAG,
          p_ATTRIBUTE_CATEGORY  => p_MOH_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_MOH_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_MOH_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_MOH_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_MOH_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_MOH_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_MOH_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_MOH_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_MOH_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_MOH_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_MOH_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_MOH_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_MOH_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_MOH_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_MOH_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_MOH_rec.ATTRIBUTE15,
          P_LOCATION_ID => P_MOH_REC.LOCATION_ID,
          p_PARTY_SITE_ID => P_MOH_REC.PARTY_SITE_ID
          /*
          p_ADDRESS1  => p_MOH_rec.ADDRESS1,
          p_ADDRESS2  => p_MOH_rec.ADDRESS2,
          p_ADDRESS3  => p_MOH_rec.ADDRESS3,
          p_ADDRESS4  => p_MOH_rec.ADDRESS4,
          p_CITY  => p_MOH_rec.CITY,
          p_POSTAL_CODE  => p_MOH_rec.POSTAL_CODE,
          p_STATE  => p_MOH_rec.STATE,
          p_PROVINCE  => p_MOH_rec.PROVINCE,
          p_COUNTRY  => p_MOH_rec.COUNTRY */
          );
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
          AS_CALLOUT_PKG.Update_orderheaders_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_MOH_Rec      =>  P_MOH_Rec,
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
End Update_orderheaders;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_orderheaders(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_MOH_Rec     IN MOH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_orderheaders';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_ORDERHEADERS_PVT;

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
          AS_CALLOUT_PKG.Delete_orderheaders_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_MOH_Rec      =>  P_MOH_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

/* Comment out by CSP. 06-DEC-1999.

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

      -- Invoke table handler(CSP_MOVEORDER_HEADERS_PKG.Delete_Row)
      CSP_MOVEORDER_HEADERS_PKG.Delete_Row(
          p_HEADER_ID  => p_MOH_rec.HEADER_ID);
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
          AS_CALLOUT_PKG.Delete_orderheaders_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_MOH_Rec      =>  P_MOH_Rec,
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
End Delete_orderheaders;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_MOH_Rec   IN  CSP_ORDERHEADERS_PUB.MOH_Rec_Type,
    p_cur_get_MOH   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Define Columns Begins');

      -- define all columns for CSP_MOVEORDER_HEADERS_V view
      dbms_sql.define_column(p_cur_get_MOH, 1, P_MOH_Rec.HEADER_ID);
      dbms_sql.define_column(p_cur_get_MOH, 2, P_MOH_Rec.CARRIER, 50);
      dbms_sql.define_column(p_cur_get_MOH, 3, P_MOH_Rec.SHIPMENT_METHOD, 50);
      dbms_sql.define_column(p_cur_get_MOH, 4, P_MOH_Rec.AUTORECEIPT_FLAG, 10);
      dbms_sql.define_column(p_cur_get_MOH, 5, P_MOH_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_MOH, 6, P_MOH_Rec.LOCATION_ID);
      /*
      dbms_sql.define_column(p_cur_get_MOH, 7, P_MOH_Rec.ADDRESS1, 240);
      dbms_sql.define_column(p_cur_get_MOH, 8, P_MOH_Rec.ADDRESS2, 240);
      dbms_sql.define_column(p_cur_get_MOH, 9, P_MOH_Rec.ADDRESS3, 240);
      dbms_sql.define_column(p_cur_get_MOH, 10, P_MOH_Rec.ADDRESS4, 240);
      dbms_sql.define_column(p_cur_get_MOH, 11, P_MOH_Rec.CITY, 60);
      dbms_sql.define_column(p_cur_get_MOH, 12, P_MOH_Rec.POSTAL_CODE, 60);
      dbms_sql.define_column(p_cur_get_MOH, 13, P_MOH_Rec.STATE, 60);
      dbms_sql.define_column(p_cur_get_MOH, 14, P_MOH_Rec.PROVINCE, 60);
      dbms_sql.define_column(p_cur_get_MOH, 15, P_MOH_Rec.COUNTRY, 60); */

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_MOH   IN   NUMBER,
    X_MOH_Rec   OUT NOCOPY  CSP_ORDERHEADERS_PUB.MOH_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Get Column Values Begins');

      -- get all column values for CSP_MOVEORDER_HEADERS_V table
      dbms_sql.column_value(p_cur_get_MOH, 1, X_MOH_Rec.HEADER_ID);
      dbms_sql.column_value(p_cur_get_MOH, 2, X_MOH_Rec.CARRIER);
      dbms_sql.column_value(p_cur_get_MOH, 3, X_MOH_Rec.SHIPMENT_METHOD);
      dbms_sql.column_value(p_cur_get_MOH, 4, X_MOH_Rec.AUTORECEIPT_FLAG);
      dbms_sql.column_value(p_cur_get_MOH, 5, X_MOH_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_MOH, 6, X_MOH_Rec.LOCATION_ID);
      /*
      dbms_sql.column_value(p_cur_get_MOH, 7, X_MOH_Rec.ADDRESS1);
      dbms_sql.column_value(p_cur_get_MOH, 8, X_MOH_Rec.ADDRESS2);
      dbms_sql.column_value(p_cur_get_MOH, 9, X_MOH_Rec.ADDRESS3);
      dbms_sql.column_value(p_cur_get_MOH, 10, X_MOH_Rec.ADDRESS4);
      dbms_sql.column_value(p_cur_get_MOH, 11, X_MOH_Rec.CITY);
      dbms_sql.column_value(p_cur_get_MOH, 12, X_MOH_Rec.POSTAL_CODE);
      dbms_sql.column_value(p_cur_get_MOH, 13, X_MOH_Rec.STATE);
      dbms_sql.column_value(p_cur_get_MOH, 14, X_MOH_Rec.PROVINCE);
      dbms_sql.column_value(p_cur_get_MOH, 15, X_MOH_Rec.COUNTRY); */

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_MOH_order_cl(
    p_order_by_rec   IN   CSP_ORDERHEADERS_PUB.MOH_sort_rec_type,
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
END Gen_MOH_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_MOH_Rec   IN   CSP_ORDERHEADERS_PUB.MOH_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_MOH   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_MOH_Rec.HEADER_ID IS NOT NULL) AND (P_MOH_Rec.HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_MOH, ':p_HEADER_ID', P_MOH_Rec.HEADER_ID);
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
                'CSP_MOVEORDER_HEADERS_V.HEADER_ID,' ||
                'CSP_MOVEORDER_HEADERS_V.CREATED_BY,' ||
                'CSP_MOVEORDER_HEADERS_V.CREATION_DATE,' ||
                'CSP_MOVEORDER_HEADERS_V.LAST_UPDATED_BY,' ||
                'CSP_MOVEORDER_HEADERS_V.LAST_UPDATE_DATE,' ||
                'CSP_MOVEORDER_HEADERS_V.LAST_UPDATE_LOGIN,' ||
                'CSP_MOVEORDER_HEADERS_V.LOCATION_ID,' ||
                'CSP_MOVEORDER_HEADERS_V.CARRIER,' ||
                'CSP_MOVEORDER_HEADERS_V.SHIPMENT_METHOD,' ||
                'CSP_MOVEORDER_HEADERS_V.AUTORECEIPT_FLAG,' ||
                'CSP_MOVEORDER_HEADERS_V.ATTRIBUTE_CATEGORY,' ||
               /* 'CSP_MOVEORDER_HEADERS_V.ADDRESS1,' ||
                'CSP_MOVEORDER_HEADERS_V.ADDRESS2,' ||
                'CSP_MOVEORDER_HEADERS_V.ADDRESS3,' ||
                'CSP_MOVEORDER_HEADERS_V.ADDRESS4,' ||
                'CSP_MOVEORDER_HEADERS_V.CITY,' ||
                'CSP_MOVEORDER_HEADERS_V.POSTAL_CODE,' ||
                'CSP_MOVEORDER_HEADERS_V.STATE,' ||
                'CSP_MOVEORDER_HEADERS_V.PROVINCE,' ||
                'CSP_MOVEORDER_HEADERS_V.COUNTRY,' || */
                'from CSP_MOVEORDER_HEADERS_V';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_MOH_Where(
    P_MOH_Rec     IN   CSP_ORDERHEADERS_PUB.MOH_Rec_Type,
    x_MOH_where   OUT NOCOPY   VARCHAR2
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
      IF( (P_MOH_Rec.HEADER_ID IS NOT NULL) AND (P_MOH_Rec.HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_MOH_where IS NULL) THEN
              x_MOH_where := 'Where';
          ELSE
              x_MOH_where := x_MOH_where || ' AND ';
          END IF;
          x_MOH_where := x_MOH_where || 'P_MOH_Rec.HEADER_ID = :p_HEADER_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_MOH_Rec.CREATION_DATE IS NOT NULL) AND (P_MOH_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_MOH_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_MOH_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_MOH_where IS NULL) THEN
              x_MOH_where := 'Where ';
          ELSE
              x_MOH_where := x_MOH_where || ' AND ';
          END IF;
          x_MOH_where := x_MOH_where || 'P_MOH_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_MOH_Rec.CARRIER IS NOT NULL) AND (P_MOH_Rec.CARRIER <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_MOH_Rec.CARRIER);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_MOH_Rec.CARRIER);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_MOH_where IS NULL) THEN
              x_MOH_where := 'Where ';
          ELSE
              x_MOH_where := x_MOH_where || ' AND ';
          END IF;
          x_MOH_where := x_MOH_where || 'P_MOH_Rec.CARRIER ' || l_operator || ' :p_CARRIER';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Where Ends');

END Gen_MOH_Where;

-- Item-level validation procedures
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
    l_check_header_id   number;
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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private orderheaders API: -Violate NOT NULL constraint(HEADER_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
         NULL;
          -- Hint: Validate data
          -- IF p_HEADER_ID is not NULL and p_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;

          -- Check whether the p_header_id exists in the mtl_txn_request_headers. If not, raise an exception.
        /* 04/05/00: the following block is moved to csp_to_form_moheaders.validate_and_write.
         begin
            select header_id into l_check_header_id
            from mtl_txn_request_headers
            where header_id = p_header_id;

            exception
            when no_data_found then
              x_msg_count := x_msg_count + 1;
              x_msg_data := x_msg_data || 'Invalid Header ID.';
              x_return_status := FND_API.G_RET_STS_ERROR;
            when others then
              x_msg_count := x_msg_count + 1;
              x_msg_data := x_msg_data || 'Unexpected errors found while validating the Header ID. Please check the Header ID.';
              x_return_status := FND_API.G_RET_STS_ERROR;
          end;
        */
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_HEADER_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
            begin
            select header_id into l_check_header_id
            from mtl_txn_request_headers
            where header_id = p_header_id;

            exception
            when no_data_found then
              x_msg_count := x_msg_count + 1;
              x_msg_data := x_msg_data || 'Invalid Header ID.';
              x_return_status := FND_API.G_RET_STS_ERROR;
            when others then
              x_msg_count := x_msg_count + 1;
              x_msg_data := x_msg_data || 'Unexpected errors found while validating the Header ID. Please check the Header ID.';
              x_return_status := FND_API.G_RET_STS_ERROR;
          end;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_HEADER_ID;


PROCEDURE Validate_LOCATION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LOCATION_ID                IN   NUMBER,
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
      IF(p_LOCATION_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private orderheaders API: -Violate NOT NULL constraint(LOCATION_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOCATION_ID is not NULL and p_LOCATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_LOCATION_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LOCATION_ID;


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


PROCEDURE Validate_AUTORECEIPT_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_AUTORECEIPT_FLAG                IN   VARCHAR2,
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
          -- IF p_AUTORECEIPT_FLAG is not NULL and p_AUTORECEIPT_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_AUTORECEIPT_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_AUTORECEIPT_FLAG;


/* PROCEDURE Validate_ADDRESS1 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ADDRESS1                IN   VARCHAR2,
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
          -- IF p_ADDRESS1 is not NULL and p_ADDRESS1 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ADDRESS1 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ADDRESS1;


PROCEDURE Validate_ADDRESS2 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ADDRESS2                IN   VARCHAR2,
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
          -- IF p_ADDRESS2 is not NULL and p_ADDRESS2 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ADDRESS2 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ADDRESS2;


PROCEDURE Validate_ADDRESS3 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ADDRESS3                IN   VARCHAR2,
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
          -- IF p_ADDRESS3 is not NULL and p_ADDRESS3 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ADDRESS3 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ADDRESS3;


PROCEDURE Validate_ADDRESS4 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ADDRESS4                IN   VARCHAR2,
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
          -- IF p_ADDRESS4 is not NULL and p_ADDRESS4 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ADDRESS4 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ADDRESS4;


PROCEDURE Validate_CITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CITY                IN   VARCHAR2,
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
          -- IF p_CITY is not NULL and p_CITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CITY;


PROCEDURE Validate_POSTAL_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_POSTAL_CODE                IN   VARCHAR2,
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
          -- IF p_POSTAL_CODE is not NULL and p_POSTAL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_POSTAL_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_POSTAL_CODE;


PROCEDURE Validate_STATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_STATE                IN   VARCHAR2,
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
          -- IF p_STATE is not NULL and p_STATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_STATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_STATE;


PROCEDURE Validate_PROVINCE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROVINCE                IN   VARCHAR2,
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
          -- IF p_PROVINCE is not NULL and p_PROVINCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PROVINCE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROVINCE;


PROCEDURE Validate_COUNTRY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COUNTRY                IN   VARCHAR2,
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
          -- IF p_COUNTRY is not NULL and p_COUNTRY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_COUNTRY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COUNTRY;
*/

-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_PLSQL_API.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_MOH_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MOH_Rec     IN    MOH_Rec_Type,
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

END Validate_MOH_Rec;

PROCEDURE Validate_orderheaders(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_MOH_Rec     IN    MOH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_orderheaders';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_HEADER_ID   => P_MOH_Rec.HEADER_ID,
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
              p_CARRIER   => P_MOH_Rec.CARRIER,
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
              p_SHIPMENT_METHOD   => P_MOH_Rec.SHIPMENT_METHOD,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_AUTORECEIPT_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_AUTORECEIPT_FLAG   => P_MOH_Rec.AUTORECEIPT_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

         /* Validate_ADDRESS1(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ADDRESS1   => P_MOH_Rec.ADDRESS1,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ADDRESS2(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ADDRESS2   => P_MOH_Rec.ADDRESS2,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ADDRESS3(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ADDRESS3   => P_MOH_Rec.ADDRESS3,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ADDRESS4(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ADDRESS4   => P_MOH_Rec.ADDRESS4,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CITY   => P_MOH_Rec.CITY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_POSTAL_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_POSTAL_CODE   => P_MOH_Rec.POSTAL_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_STATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_STATE   => P_MOH_Rec.STATE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROVINCE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROVINCE   => P_MOH_Rec.PROVINCE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_COUNTRY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COUNTRY   => P_MOH_Rec.COUNTRY,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
        */
      END IF;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_MOH_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_MOH_Rec     =>    P_MOH_Rec,
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

END Validate_orderheaders;

End CSP_ORDERHEADERS_PVT;

/
