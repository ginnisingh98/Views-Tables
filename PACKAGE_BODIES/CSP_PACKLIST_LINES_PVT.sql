--------------------------------------------------------
--  DDL for Package Body CSP_PACKLIST_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PACKLIST_LINES_PVT" AS
/* $Header: cspvtalb.pls 115.8 2003/05/02 17:14:15 phegde ship $ */
-- Start of Comments
-- Package name     : CSP_PACKLIST_LINES_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PACKLIST_LINES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvtalb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_packlist_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_PLL_Rec     IN    PLL_Rec_Type  := G_MISS_PLL_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_PACKLIST_LINE_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_packlist_lines';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PACKLIST_LINES_PVT;

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
          AS_CALLOUT_PKG.Create_packlist_lines_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_PLL_Rec      =>  P_PLL_Rec,
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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Validate_packlist_lines');

          -- Invoke validation procedures
          Validate_packlist_lines(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_PLL_Rec  =>  P_PLL_Rec,
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

      -- Invoke table handler(CSP_PACKLIST_LINES_PKG.Insert_Row)
      CSP_PACKLIST_LINES_PKG.Insert_Row(
          px_PACKLIST_LINE_ID  => x_PACKLIST_LINE_ID,
          p_CREATED_BY  => p_PLL_rec.CREATED_BY,
          p_CREATION_DATE  => p_PLL_rec.CREATION_DATE,
          p_LAST_UPDATED_BY  => p_PLL_rec.LAST_UPDATED_BY,
          p_LAST_UPDATE_DATE  => p_PLL_rec.LAST_UPDATE_DATE,
          p_LAST_UPDATE_LOGIN  => p_PLL_rec.LAST_UPDATE_LOGIN,
          p_ORGANIZATION_ID  => p_PLL_rec.ORGANIZATION_ID,
          p_PACKLIST_LINE_NUMBER  => p_PLL_rec.PACKLIST_LINE_NUMBER,
          p_PACKLIST_HEADER_ID  => p_PLL_rec.PACKLIST_HEADER_ID,
          p_BOX_ID  => p_PLL_rec.BOX_ID,
          p_PICKLIST_LINE_ID  => p_PLL_rec.PICKLIST_LINE_ID,
          p_PACKLIST_LINE_STATUS  => p_PLL_rec.PACKLIST_LINE_STATUS,
          p_INVENTORY_ITEM_ID  => p_PLL_rec.INVENTORY_ITEM_ID,
          p_QUANTITY_PACKED  => p_PLL_rec.QUANTITY_PACKED,
          p_QUANTITY_SHIPPED  => p_PLL_rec.QUANTITY_SHIPPED,
          p_QUANTITY_RECEIVED  => p_PLL_rec.QUANTITY_RECEIVED,
          p_ATTRIBUTE_CATEGORY  => p_PLL_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_PLL_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_PLL_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_PLL_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_PLL_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_PLL_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_PLL_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_PLL_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_PLL_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_PLL_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_PLL_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_PLL_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_PLL_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_PLL_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_PLL_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_PLL_rec.ATTRIBUTE15,
          p_UOM_CODE  => p_PLL_rec.UOM_CODE,
          p_LINE_ID  => p_PLL_rec.LINE_ID);
      -- Hint: Primary key should be returned.
      -- x_PACKLIST_LINE_ID := px_PACKLIST_LINE_ID;

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
          AS_CALLOUT_PKG.Create_packlist_lines_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_PLL_Rec      =>  P_PLL_Rec,
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
End Create_packlist_lines;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_packlist_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_PLL_Rec     IN    PLL_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_packlist_lines(PACKLIST_LINE_ID Number) IS
    Select rowid,
           PACKLIST_LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PACKLIST_LINE_NUMBER,
           PACKLIST_HEADER_ID,
           BOX_ID,
           PICKLIST_LINE_ID,
           PACKLIST_LINE_STATUS,
           INVENTORY_ITEM_ID,
           QUANTITY_PACKED,
           QUANTITY_SHIPPED,
           QUANTITY_RECEIVED,
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
           UOM_CODE,
           LINE_ID
    From  CSP_PACKLIST_LINES
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_packlist_lines';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_PLL_rec  CSP_packlist_lines_PVT.PLL_Rec_Type;
l_tar_PLL_rec  CSP_packlist_lines_PVT.PLL_Rec_Type := P_PLL_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PACKLIST_LINES_PVT;

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
          AS_CALLOUT_PKG.Update_packlist_lines_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PLL_Rec      =>  P_PLL_Rec,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: - Open Cursor to Select');

/*
      Open C_Get_packlist_lines( l_tar_PLL_rec.PACKLIST_LINE_ID);

      Fetch C_Get_packlist_lines into
               l_rowid,
               l_ref_PLL_rec.PACKLIST_LINE_ID,
               l_ref_PLL_rec.CREATED_BY,
               l_ref_PLL_rec.CREATION_DATE,
               l_ref_PLL_rec.LAST_UPDATED_BY,
               l_ref_PLL_rec.LAST_UPDATE_DATE,
               l_ref_PLL_rec.LAST_UPDATE_LOGIN,
               l_ref_PLL_rec.ORGANIZATION_ID,
               l_ref_PLL_rec.PACKLIST_LINE_NUMBER,
               l_ref_PLL_rec.PACKLIST_HEADER_ID,
               l_ref_PLL_rec.BOX_ID,
               l_ref_PLL_rec.PICKLIST_LINE_ID,
               l_ref_PLL_rec.PACKLIST_LINE_STATUS,
               l_ref_PLL_rec.INVENTORY_ITEM_ID,
               l_ref_PLL_rec.QUANTITY_PACKED,
               l_ref_PLL_rec.QUANTITY_SHIPPED,
               l_ref_PLL_rec.QUANTITY_RECEIVED,
               l_ref_PLL_rec.ATTRIBUTE_CATEGORY,
               l_ref_PLL_rec.ATTRIBUTE1,
               l_ref_PLL_rec.ATTRIBUTE2,
               l_ref_PLL_rec.ATTRIBUTE3,
               l_ref_PLL_rec.ATTRIBUTE4,
               l_ref_PLL_rec.ATTRIBUTE5,
               l_ref_PLL_rec.ATTRIBUTE6,
               l_ref_PLL_rec.ATTRIBUTE7,
               l_ref_PLL_rec.ATTRIBUTE8,
               l_ref_PLL_rec.ATTRIBUTE9,
               l_ref_PLL_rec.ATTRIBUTE10,
               l_ref_PLL_rec.ATTRIBUTE11,
               l_ref_PLL_rec.ATTRIBUTE12,
               l_ref_PLL_rec.ATTRIBUTE13,
               l_ref_PLL_rec.ATTRIBUTE14,
               l_ref_PLL_rec.ATTRIBUTE15,
               l_ref_PLL_rec.UOM_CODE,
               l_ref_PLL_rec.LINE_ID;

       If ( C_Get_packlist_lines%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSP', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'packlist_lines', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: - Close Cursor');
       Close     C_Get_packlist_lines;



      If (l_tar_PLL_rec.last_update_date is NULL or
          l_tar_PLL_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_PLL_rec.last_update_date <> l_ref_PLL_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSP', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'packlist_lines', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Validate_packlist_lines');

          -- Invoke validation procedures
          Validate_packlist_lines(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_PLL_Rec  =>  P_PLL_Rec,
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

      -- Invoke table handler(CSP_PACKLIST_LINES_PKG.Update_Row)
      CSP_PACKLIST_LINES_PKG.Update_Row(
          p_PACKLIST_LINE_ID  => p_PLL_rec.PACKLIST_LINE_ID,
          p_CREATED_BY  => p_PLL_rec.CREATED_BY,
          p_CREATION_DATE  => p_PLL_rec.creation_date,
          p_LAST_UPDATED_BY  => p_PLL_rec.LAST_UPDATED_BY,
          p_LAST_UPDATE_DATE  => p_PLL_rec.LAST_UPDATE_DATE,
          p_LAST_UPDATE_LOGIN  => p_PLL_rec.LAST_UPDATE_LOGIN,
          p_ORGANIZATION_ID  => p_PLL_rec.ORGANIZATION_ID,
          p_PACKLIST_LINE_NUMBER  => p_PLL_rec.PACKLIST_LINE_NUMBER,
          p_PACKLIST_HEADER_ID  => p_PLL_rec.PACKLIST_HEADER_ID,
          p_BOX_ID  => p_PLL_rec.BOX_ID,
          p_PICKLIST_LINE_ID  => p_PLL_rec.PICKLIST_LINE_ID,
          p_PACKLIST_LINE_STATUS  => p_PLL_rec.PACKLIST_LINE_STATUS,
          p_INVENTORY_ITEM_ID  => p_PLL_rec.INVENTORY_ITEM_ID,
          p_QUANTITY_PACKED  => p_PLL_rec.QUANTITY_PACKED,
          p_QUANTITY_SHIPPED  => p_PLL_rec.QUANTITY_SHIPPED,
          p_QUANTITY_RECEIVED  => p_PLL_rec.QUANTITY_RECEIVED,
          p_ATTRIBUTE_CATEGORY  => p_PLL_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_PLL_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_PLL_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_PLL_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_PLL_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_PLL_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_PLL_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_PLL_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_PLL_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_PLL_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_PLL_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_PLL_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_PLL_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_PLL_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_PLL_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_PLL_rec.ATTRIBUTE15,
          p_UOM_CODE  => p_PLL_rec.UOM_CODE,
          p_LINE_ID  => p_PLL_rec.LINE_ID);
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
          AS_CALLOUT_PKG.Update_packlist_lines_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PLL_Rec      =>  P_PLL_Rec,
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
End Update_packlist_lines;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_packlist_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_PLL_Rec     IN PLL_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_packlist_lines';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PACKLIST_LINES_PVT;

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
          AS_CALLOUT_PKG.Delete_packlist_lines_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PLL_Rec      =>  P_PLL_Rec,
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

      -- Invoke table handler(CSP_PACKLIST_LINES_PKG.Delete_Row)
      CSP_PACKLIST_LINES_PKG.Delete_Row(
          p_PACKLIST_LINE_ID  => p_PLL_rec.PACKLIST_LINE_ID);
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
          AS_CALLOUT_PKG.Delete_packlist_lines_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_PLL_Rec      =>  P_PLL_Rec,
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
End Delete_packlist_lines;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_PLL_Rec   IN  CSP_PACKLIST_LINES_PUB.PLL_Rec_Type,
    p_cur_get_PLL   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Define Columns Begins');

      -- define all columns for CSP_PACKLIST_LINES_V view
      dbms_sql.define_column(p_cur_get_PLL, 1, P_PLL_Rec.PACKLIST_LINE_ID);
      dbms_sql.define_column(p_cur_get_PLL, 2, P_PLL_Rec.ORGANIZATION_ID);
      dbms_sql.define_column(p_cur_get_PLL, 3, P_PLL_Rec.PACKLIST_LINE_NUMBER);
      dbms_sql.define_column(p_cur_get_PLL, 4, P_PLL_Rec.PACKLIST_HEADER_ID);
      dbms_sql.define_column(p_cur_get_PLL, 5, P_PLL_Rec.BOX_ID);
      dbms_sql.define_column(p_cur_get_PLL, 6, P_PLL_Rec.PICKLIST_LINE_ID);
      dbms_sql.define_column(p_cur_get_PLL, 7, P_PLL_Rec.PACKLIST_LINE_STATUS, 30);
      dbms_sql.define_column(p_cur_get_PLL, 8, P_PLL_Rec.INVENTORY_ITEM_ID);
      dbms_sql.define_column(p_cur_get_PLL, 9, P_PLL_Rec.QUANTITY_PACKED);
      dbms_sql.define_column(p_cur_get_PLL, 10, P_PLL_Rec.QUANTITY_SHIPPED);
      dbms_sql.define_column(p_cur_get_PLL, 11, P_PLL_Rec.QUANTITY_RECEIVED);
      dbms_sql.define_column(p_cur_get_PLL, 12, P_PLL_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_PLL, 13, P_PLL_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_PLL, 14, P_PLL_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_PLL, 15, P_PLL_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_PLL, 16, P_PLL_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_PLL, 17, P_PLL_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_PLL, 18, P_PLL_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_PLL, 19, P_PLL_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_PLL, 20, P_PLL_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_PLL, 21, P_PLL_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_PLL, 22, P_PLL_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_PLL, 23, P_PLL_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_PLL, 24, P_PLL_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_PLL, 25, P_PLL_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_PLL, 26, P_PLL_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_PLL, 27, P_PLL_Rec.ATTRIBUTE15, 150);
      dbms_sql.define_column(p_cur_get_PLL, 28, P_PLL_Rec.UOM_CODE, 3);
      dbms_sql.define_column(p_cur_get_PLL, 29, P_PLL_Rec.LINE_ID);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_PLL   IN   NUMBER,
    X_PLL_Rec   OUT NOCOPY  CSP_PACKLIST_LINES_PUB.PLL_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Get Column Values Begins');

      -- get all column values for CSP_PACKLIST_LINES_V table
      dbms_sql.column_value(p_cur_get_PLL, 1, X_PLL_Rec.PACKLIST_LINE_ID);
      dbms_sql.column_value(p_cur_get_PLL, 2, X_PLL_Rec.ORGANIZATION_ID);
      dbms_sql.column_value(p_cur_get_PLL, 3, X_PLL_Rec.PACKLIST_LINE_NUMBER);
      dbms_sql.column_value(p_cur_get_PLL, 4, X_PLL_Rec.PACKLIST_HEADER_ID);
      dbms_sql.column_value(p_cur_get_PLL, 5, X_PLL_Rec.BOX_ID);
      dbms_sql.column_value(p_cur_get_PLL, 6, X_PLL_Rec.PICKLIST_LINE_ID);
      dbms_sql.column_value(p_cur_get_PLL, 7, X_PLL_Rec.PACKLIST_LINE_STATUS);
      dbms_sql.column_value(p_cur_get_PLL, 8, X_PLL_Rec.INVENTORY_ITEM_ID);
      dbms_sql.column_value(p_cur_get_PLL, 9, X_PLL_Rec.QUANTITY_PACKED);
      dbms_sql.column_value(p_cur_get_PLL, 10, X_PLL_Rec.QUANTITY_SHIPPED);
      dbms_sql.column_value(p_cur_get_PLL, 11, X_PLL_Rec.QUANTITY_RECEIVED);
      dbms_sql.column_value(p_cur_get_PLL, 12, X_PLL_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_PLL, 13, X_PLL_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_PLL, 14, X_PLL_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_PLL, 15, X_PLL_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_PLL, 16, X_PLL_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_PLL, 17, X_PLL_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_PLL, 18, X_PLL_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_PLL, 19, X_PLL_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_PLL, 20, X_PLL_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_PLL, 21, X_PLL_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_PLL, 22, X_PLL_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_PLL, 23, X_PLL_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_PLL, 24, X_PLL_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_PLL, 25, X_PLL_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_PLL, 26, X_PLL_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_PLL, 27, X_PLL_Rec.ATTRIBUTE15);
      dbms_sql.column_value(p_cur_get_PLL, 28, X_PLL_Rec.UOM_CODE);
      dbms_sql.column_value(p_cur_get_PLL, 29, X_PLL_Rec.LINE_ID);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_PLL_order_cl(
    p_order_by_rec   IN   CSP_PACKLIST_LINES_PUB.PLL_sort_rec_type,
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
END Gen_PLL_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_PLL_Rec   IN   CSP_PACKLIST_LINES_PUB.PLL_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_PLL   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_PLL_Rec.PACKLIST_LINE_ID IS NOT NULL) AND (P_PLL_Rec.PACKLIST_LINE_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_PLL, ':p_PACKLIST_LINE_ID', P_PLL_Rec.PACKLIST_LINE_ID);
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
                'CSP_PACKLIST_LINES_V.PACKLIST_LINE_ID,' ||
                'CSP_PACKLIST_LINES_V.CREATED_BY,' ||
                'CSP_PACKLIST_LINES_V.CREATION_DATE,' ||
                'CSP_PACKLIST_LINES_V.LAST_UPDATED_BY,' ||
                'CSP_PACKLIST_LINES_V.LAST_UPDATE_DATE,' ||
                'CSP_PACKLIST_LINES_V.LAST_UPDATE_LOGIN,' ||
                'CSP_PACKLIST_LINES_V.ORGANIZATION_ID,' ||
                'CSP_PACKLIST_LINES_V.PACKLIST_LINE_NUMBER,' ||
                'CSP_PACKLIST_LINES_V.PACKLIST_HEADER_ID,' ||
                'CSP_PACKLIST_LINES_V.BOX_ID,' ||
                'CSP_PACKLIST_LINES_V.PICKLIST_LINE_ID,' ||
                'CSP_PACKLIST_LINES_V.PACKLIST_LINE_STATUS,' ||
                'CSP_PACKLIST_LINES_V.INVENTORY_ITEM_ID,' ||
                'CSP_PACKLIST_LINES_V.QUANTITY_PACKED,' ||
                'CSP_PACKLIST_LINES_V.QUANTITY_SHIPPED,' ||
                'CSP_PACKLIST_LINES_V.QUANTITY_RECEIVED,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE_CATEGORY,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE1,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE2,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE3,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE4,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE5,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE6,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE7,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE8,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE9,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE10,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE11,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE12,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE13,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE14,' ||
                'CSP_PACKLIST_LINES_V.ATTRIBUTE15,' ||
                'CSP_PACKLIST_LINES_V.UOM_CODE,' ||
                'CSP_PACKLIST_LINES_V.LINE_ID,' ||
                'from CSP_PACKLIST_LINES_V';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_PLL_Where(
    P_PLL_Rec     IN   CSP_PACKLIST_LINES_PUB.PLL_Rec_Type,
    x_PLL_where   OUT NOCOPY   VARCHAR2
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
      IF( (P_PLL_Rec.PACKLIST_LINE_ID IS NOT NULL) AND (P_PLL_Rec.PACKLIST_LINE_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_PLL_where IS NULL) THEN
              x_PLL_where := 'Where';
          ELSE
              x_PLL_where := x_PLL_where || ' AND ';
          END IF;
          x_PLL_where := x_PLL_where || 'P_PLL_Rec.PACKLIST_LINE_ID = :p_PACKLIST_LINE_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_PLL_Rec.CREATION_DATE IS NOT NULL) AND (P_PLL_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_PLL_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_PLL_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_PLL_where IS NULL) THEN
              x_PLL_where := 'Where ';
          ELSE
              x_PLL_where := x_PLL_where || ' AND ';
          END IF;
          x_PLL_where := x_PLL_where || 'P_PLL_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_PLL_Rec.PACKLIST_LINE_STATUS IS NOT NULL) AND (P_PLL_Rec.PACKLIST_LINE_STATUS <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_PLL_Rec.PACKLIST_LINE_STATUS);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_PLL_Rec.PACKLIST_LINE_STATUS);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_PLL_where IS NULL) THEN
              x_PLL_where := 'Where ';
          ELSE
              x_PLL_where := x_PLL_where || ' AND ';
          END IF;
          x_PLL_where := x_PLL_where || 'P_PLL_Rec.PACKLIST_LINE_STATUS ' || l_operator || ' :p_PACKLIST_LINE_STATUS';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: Generate Where Ends');

END Gen_PLL_Where;

-- Item-level validation procedures
PROCEDURE Validate_PACKLIST_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PACKLIST_LINE_ID                IN   NUMBER,
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
      IF(p_PACKLIST_LINE_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(PACKLIST_LINE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_LINE_ID is not NULL and p_PACKLIST_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PACKLIST_LINE_ID;


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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(ORGANIZATION_ID)');
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


PROCEDURE Validate_PACKLIST_LINE_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PACKLIST_LINE_NUMBER                IN   NUMBER,
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
      IF(p_PACKLIST_LINE_NUMBER is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(PACKLIST_LINE_NUMBER)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_LINE_NUMBER is not NULL and p_PACKLIST_LINE_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_LINE_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PACKLIST_LINE_NUMBER;


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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(PACKLIST_HEADER_ID)');
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


PROCEDURE Validate_BOX_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_BOX_ID                IN   NUMBER,
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
      IF(p_BOX_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(BOX_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_BOX_ID is not NULL and p_BOX_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_BOX_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_BOX_ID;


PROCEDURE Validate_PICKLIST_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PICKLIST_LINE_ID                IN   NUMBER,
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
          -- IF p_PICKLIST_LINE_ID is not NULL and p_PICKLIST_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PICKLIST_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PICKLIST_LINE_ID;


PROCEDURE Validate_PACKLIST_LINE_STATUS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PACKLIST_LINE_STATUS                IN   VARCHAR2,
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
      IF(p_PACKLIST_LINE_STATUS is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(PACKLIST_LINE_STATUS)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_LINE_STATUS is not NULL and p_PACKLIST_LINE_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PACKLIST_LINE_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PACKLIST_LINE_STATUS;


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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(INVENTORY_ITEM_ID)');
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


PROCEDURE Validate_QUANTITY_PACKED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUANTITY_PACKED                IN   NUMBER,
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
      IF(p_QUANTITY_PACKED is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(QUANTITY_PACKED)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY_PACKED is not NULL and p_QUANTITY_PACKED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY_PACKED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUANTITY_PACKED;


PROCEDURE Validate_QUANTITY_SHIPPED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUANTITY_SHIPPED                IN   NUMBER,
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
          -- IF p_QUANTITY_SHIPPED is not NULL and p_QUANTITY_SHIPPED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY_SHIPPED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUANTITY_SHIPPED;


PROCEDURE Validate_QUANTITY_RECEIVED (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUANTITY_RECEIVED                IN   NUMBER,
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
          -- IF p_QUANTITY_RECEIVED is not NULL and p_QUANTITY_RECEIVED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY_RECEIVED <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUANTITY_RECEIVED;


PROCEDURE Validate_UOM_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_UOM_CODE                IN   VARCHAR2,
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
      IF(p_UOM_CODE is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSP', 'Private packlist_lines API: -Violate NOT NULL constraint(UOM_CODE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_UOM_CODE is not NULL and p_UOM_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_UOM_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_UOM_CODE;


PROCEDURE Validate_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LINE_ID                IN   NUMBER,
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
          -- IF p_LINE_ID is not NULL and p_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
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


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_PLSQL_API.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_PLL_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PLL_Rec     IN    PLL_Rec_Type,
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

END Validate_PLL_Rec;

PROCEDURE Validate_packlist_lines(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PLL_Rec     IN    PLL_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_packlist_lines';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_PACKLIST_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PACKLIST_LINE_ID   => P_PLL_Rec.PACKLIST_LINE_ID,
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
              p_ORGANIZATION_ID   => P_PLL_Rec.ORGANIZATION_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PACKLIST_LINE_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PACKLIST_LINE_NUMBER   => P_PLL_Rec.PACKLIST_LINE_NUMBER,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PACKLIST_HEADER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PACKLIST_HEADER_ID   => P_PLL_Rec.PACKLIST_HEADER_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_BOX_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_BOX_ID   => P_PLL_Rec.BOX_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PICKLIST_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PICKLIST_LINE_ID   => P_PLL_Rec.PICKLIST_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PACKLIST_LINE_STATUS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PACKLIST_LINE_STATUS   => P_PLL_Rec.PACKLIST_LINE_STATUS,
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
              p_INVENTORY_ITEM_ID   => P_PLL_Rec.INVENTORY_ITEM_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QUANTITY_PACKED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUANTITY_PACKED   => P_PLL_Rec.QUANTITY_PACKED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QUANTITY_SHIPPED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUANTITY_SHIPPED   => P_PLL_Rec.QUANTITY_SHIPPED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QUANTITY_RECEIVED(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUANTITY_RECEIVED   => P_PLL_Rec.QUANTITY_RECEIVED,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_UOM_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_UOM_CODE   => P_PLL_Rec.UOM_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LINE_ID   => P_PLL_Rec.LINE_ID,
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
          Validate_PLL_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_PLL_Rec     =>    P_PLL_Rec,
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

END Validate_packlist_lines;

End CSP_PACKLIST_LINES_PVT;

/
