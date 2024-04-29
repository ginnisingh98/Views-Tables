--------------------------------------------------------
--  DDL for Package Body AST_RS_CAMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_RS_CAMP_PVT" as
/* $Header: astvrcab.pls 120.1 2005/06/01 04:27:51 appldev  $ */
-- Start of Comments
-- Package name     : AST_rs_camp_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AST_rs_camp_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'astvrcab.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- FUNCTION to return initialized variables to forms

FUNCTION get_Campaign_rec RETURN ast_rs_camp_pvt.rs_camp_rec_type IS
  l_variable ast_rs_camp_pvt.rs_camp_rec_type := ast_rs_camp_pvt.g_miss_rs_camp_rec;
BEGIN
      return (l_variable);
END;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_rs_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_rs_camp_Rec                IN   rs_camp_Rec_Type  := G_MISS_rs_camp_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_RS_CAMPAIGN_ID             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )

 IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Create_rs_camp';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_return_status_full        VARCHAR2(1);
  l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_rs_camp_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'start');
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
          AS_CALLOUT_PKG.Create_rs_camp_BC(
                  p_api_version_number   =>  1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_rs_camp_Rec      =>  P_rs_camp_Rec,
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

    /*  AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Validate_rs_camp');


          -- Invoke validation procedures
          Validate_rs_camp(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_rs_camp_Rec  =>  P_rs_camp_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Calling create table handler');

      -- Invoke table handler(AST_RS_CAMPAIGNS_PKG.Insert_Row)
      AST_RS_CAMPAIGNS_PKG.Insert_Row(
          px_RS_CAMPAIGN_ID  => x_RS_CAMPAIGN_ID,
          p_RESOURCE_ID  => p_rs_camp_rec.RESOURCE_ID,
          p_CAMPAIGN_ID  => p_rs_camp_rec.CAMPAIGN_ID,
          p_START_DATE  => p_rs_camp_rec.START_DATE,
          p_END_DATE  => p_rs_camp_rec.END_DATE,
          p_STATUS  => p_rs_camp_rec.STATUS,
          p_ENABLED_FLAG  => p_rs_camp_rec.ENABLED_FLAG,
          p_CREATED_BY  => G_USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_rs_camp_rec.LAST_UPDATE_LOGIN);
      -- Hint: Primary key should be returned.
      -- x_RS_CAMPAIGN_ID := px_RS_CAMPAIGN_ID;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Create_rs_camp_AC(
                  p_api_version_number   =>  1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_rs_camp_Rec      =>  P_rs_camp_Rec,
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
End Create_rs_camp;

-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_rs_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_rs_camp_Rec     IN    rs_camp_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )

 IS

Cursor C_Get_rs_camp(p_RS_CAMPAIGN_ID Number) IS
    Select rowid,
           RS_CAMPAIGN_ID,
           RESOURCE_ID,
           CAMPAIGN_ID,
           START_DATE,
           END_DATE,
           STATUS,
           ENABLED_FLAG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
    From  AST_RS_CAMPAIGNS
    Where rs_campaign_id = p_RS_CAMPAIGN_ID
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_rs_camp';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_rs_camp_rec  AST_rs_camp_PVT.rs_camp_Rec_Type;
l_tar_rs_camp_rec  AST_rs_camp_PVT.rs_camp_Rec_Type := P_rs_camp_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_rs_camp_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'start');

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
          AS_CALLOUT_PKG.Update_rs_camp_BU(
                  p_api_version_number   =>  1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_rs_camp_Rec      =>  P_rs_camp_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

      /*AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 1.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);*/

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: - Open Cursor to Select');
      Open C_Get_rs_camp( l_tar_rs_camp_rec.RS_CAMPAIGN_ID);

      Fetch C_Get_rs_camp into
               l_rowid,
               l_ref_rs_camp_rec.RS_CAMPAIGN_ID,
               l_ref_rs_camp_rec.RESOURCE_ID,
               l_ref_rs_camp_rec.CAMPAIGN_ID,
               l_ref_rs_camp_rec.START_DATE,
               l_ref_rs_camp_rec.END_DATE,
               l_ref_rs_camp_rec.STATUS,
               l_ref_rs_camp_rec.ENABLED_FLAG,
               l_ref_rs_camp_rec.CREATED_BY,
               l_ref_rs_camp_rec.CREATION_DATE,
               l_ref_rs_camp_rec.LAST_UPDATED_BY,
               l_ref_rs_camp_rec.LAST_UPDATE_DATE,
               l_ref_rs_camp_rec.LAST_UPDATE_LOGIN;

       If ( C_Get_rs_camp%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AST', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'rs_camp', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: - Close Cursor');

       Close     C_Get_rs_camp;



     If (l_tar_rs_camp_rec.last_update_date is NULL or
          l_tar_rs_camp_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AST', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
/*      If (l_tar_rs_camp_rec.last_update_date <> l_ref_rs_camp_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AST', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'rs_camp', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Validate_rs_camp');


          -- Invoke validation procedures
          Validate_rs_camp(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_rs_camp_Rec  =>  P_rs_camp_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Calling update table handler');


      -- Invoke table handler(AST_RS_CAMPAIGNS_PKG.Update_Row)
      AST_RS_CAMPAIGNS_PKG.Update_Row(
          p_RS_CAMPAIGN_ID  => p_rs_camp_rec.RS_CAMPAIGN_ID,
          p_RESOURCE_ID  => p_rs_camp_rec.RESOURCE_ID,
          p_CAMPAIGN_ID  => p_rs_camp_rec.CAMPAIGN_ID,
          p_START_DATE  => p_rs_camp_rec.START_DATE,
          p_END_DATE  => p_rs_camp_rec.END_DATE,
          p_STATUS  => p_rs_camp_rec.STATUS,
          p_ENABLED_FLAG  => p_rs_camp_rec.ENABLED_FLAG,
          p_CREATED_BY  => G_USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => p_rs_camp_rec.LAST_UPDATE_LOGIN);

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'end');
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
          AS_CALLOUT_PKG.Update_rs_camp_AU(
                  p_api_version_number   =>  1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_rs_camp_Rec      =>  P_rs_camp_Rec,
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
End Update_rs_camp;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_rs_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_rs_camp_Rec     IN rs_camp_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_rs_camp';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_rs_camp_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'start');



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
          AS_CALLOUT_PKG.Delete_rs_camp_BD(
                  p_api_version_number   =>  1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_rs_camp_Rec      =>  P_rs_camp_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

      /*AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST',  'Private API: Calling delete table handler');


      -- Invoke table handler(AST_RS_CAMPAIGNS_PKG.Delete_Row)
      AST_RS_CAMPAIGNS_PKG.Delete_Row(
          p_RS_CAMPAIGN_ID  => p_rs_camp_rec.RS_CAMPAIGN_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'end');



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
          AS_CALLOUT_PKG.Delete_rs_camp_AD(
                  p_api_version_number   =>  1.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_rs_camp_Rec      =>  P_rs_camp_Rec,
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
End Delete_rs_camp;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_rs_camp_Rec   IN  AST_rs_camp_PUB.rs_camp_Rec_Type,
    p_cur_get_rs_camp   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Define Columns Begins');


      -- define all columns for AST_TEST view
      dbms_sql.define_column(p_cur_get_rs_camp, 1, P_rs_camp_Rec.RS_CAMPAIGN_ID);
      dbms_sql.define_column(p_cur_get_rs_camp, 2, P_rs_camp_Rec.RESOURCE_ID);
      dbms_sql.define_column(p_cur_get_rs_camp, 3, P_rs_camp_Rec.CAMPAIGN_ID);
      dbms_sql.define_column(p_cur_get_rs_camp, 4, P_rs_camp_Rec.START_DATE);
      dbms_sql.define_column(p_cur_get_rs_camp, 5, P_rs_camp_Rec.END_DATE);
      dbms_sql.define_column(p_cur_get_rs_camp, 6, P_rs_camp_Rec.STATUS, 1);
      dbms_sql.define_column(p_cur_get_rs_camp, 7, P_rs_camp_Rec.ENABLED_FLAG, 1);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Define Columns Ends');

END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_rs_camp   IN   NUMBER,
    X_rs_camp_Rec   OUT NOCOPY /* file.sql.39 change */  AST_rs_camp_PUB.rs_camp_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Get Column Values Begins');


      -- get all column values for AST_TEST table
      dbms_sql.column_value(p_cur_get_rs_camp, 1, X_rs_camp_Rec.RS_CAMPAIGN_ID);
      dbms_sql.column_value(p_cur_get_rs_camp, 2, X_rs_camp_Rec.RESOURCE_ID);
      dbms_sql.column_value(p_cur_get_rs_camp, 3, X_rs_camp_Rec.CAMPAIGN_ID);
      dbms_sql.column_value(p_cur_get_rs_camp, 4, X_rs_camp_Rec.START_DATE);
      dbms_sql.column_value(p_cur_get_rs_camp, 5, X_rs_camp_Rec.END_DATE);
      dbms_sql.column_value(p_cur_get_rs_camp, 6, X_rs_camp_Rec.STATUS);
      dbms_sql.column_value(p_cur_get_rs_camp, 7, X_rs_camp_Rec.ENABLED_FLAG);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Get Column Values Ends');

END Get_Column_Values;

PROCEDURE Gen_rs_camp_order_cl(
    p_order_by_rec   IN   AST_rs_camp_PUB.rs_camp_sort_rec_type,
    x_order_by_cl    OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_return_status  OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count      OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_order_by_cl        VARCHAR2(1000)   := NULL;
l_util_order_by_tbl  JTF_PLSQL_API.Util_order_by_tbl_type;
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Generate Order by Begins');


      -- Hint: Developer should add more statements according to AST_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Invoke JTF_PLSQL_API.Translate_OrderBy');


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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Generate Order by Ends');

END Gen_rs_camp_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_rs_camp_Rec   IN   AST_rs_camp_PUB.rs_camp_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_rs_camp   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Bind Variables Begins');


      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_rs_camp_Rec.RS_CAMPAIGN_ID IS NOT NULL) AND (P_rs_camp_Rec.RS_CAMPAIGN_ID <> FND_API.G_MISS_NUM) )

      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_rs_camp, ':p_RS_CAMPAIGN_ID', P_rs_camp_Rec.RS_CAMPAIGN_ID);

      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Bind Variables Ends');

END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Generate Select Begins');


      x_select_cl := 'Select ' ||
                'AST_TEST.RS_CAMPAIGN_ID,' ||
                'AST_TEST.RESOURCE_ID,' ||
                'AST_TEST.CAMPAIGN_ID,' ||
                'AST_TEST.START_DATE,' ||
                'AST_TEST.END_DATE,' ||
                'AST_TEST.STATUS,' ||
                'AST_TEST.ENABLED_FLAG,' ||
                'AST_TEST.CREATED_BY,' ||
                'AST_TEST.CREATION_DATE,' ||
                'AST_TEST.LAST_UPDATED_BY,' ||
                'AST_TEST.LAST_UPDATE_DATE,' ||
                'AST_TEST.LAST_UPDATE_LOGIN,' ||
                'from AST_TEST';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Generate Select Ends');


END Gen_Select;

PROCEDURE Gen_rs_camp_Where(
    P_rs_camp_Rec     IN   AST_rs_camp_PUB.rs_camp_Rec_Type,
    x_rs_camp_where   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Generate Where Begins');


      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_rs_camp_Rec.RS_CAMPAIGN_ID IS NOT NULL) AND (P_rs_camp_Rec.RS_CAMPAIGN_ID <> FND_API.G_MISS_NUM) )

      THEN
          IF(x_rs_camp_where IS NULL) THEN
              x_rs_camp_where := 'Where';
          ELSE
              x_rs_camp_where := x_rs_camp_where || ' AND ';
          END IF;
          x_rs_camp_where := x_rs_camp_where || 'P_rs_camp_Rec.RS_CAMPAIGN_ID = :p_RS_CAMPAIGN_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_rs_camp_Rec.START_DATE IS NOT NULL) AND (P_rs_camp_Rec.START_DATE <> FND_API.G_MISS_DATE) )

      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_rs_camp_Rec.START_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_rs_camp_Rec.START_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_rs_camp_where IS NULL) THEN
              x_rs_camp_where := 'Where ';
          ELSE
              x_rs_camp_where := x_rs_camp_where || ' AND ';
          END IF;
          x_rs_camp_where := x_rs_camp_where || 'P_rs_camp_Rec.START_DATE ' || l_operator || ' :p_START_DATE';

      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_rs_camp_Rec.STATUS IS NOT NULL) AND (P_rs_camp_Rec.STATUS <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_rs_camp_Rec.STATUS);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_rs_camp_Rec.STATUS);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_rs_camp_where IS NULL) THEN
              x_rs_camp_where := 'Where ';
          ELSE
              x_rs_camp_where := x_rs_camp_where || ' AND ';
          END IF;
          x_rs_camp_where := x_rs_camp_where || 'P_rs_camp_Rec.STATUS ' || l_operator || ' :p_STATUS';

      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Generate Where Ends');


END Gen_rs_camp_Where;

PROCEDURE Get_rs_camp(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_rs_camp_Rec     IN    AST_rs_camp_PUB.rs_camp_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   AST_rs_camp_PUB.rs_camp_sort_rec_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_rs_camp_Tbl  OUT NOCOPY /* file.sql.39 change */  AST_rs_camp_PUB.rs_camp_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_next_rec_ptr               OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_tot_rec_count              OUT NOCOPY /* file.sql.39 change */  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY /* file.sql.39 change */  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_rs_camp';
l_api_version_number      CONSTANT NUMBER   := 1.0;

-- Local identity variables
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

-- Local record counters
l_returned_rec_count     NUMBER := 0; -- number of records returned in x_X_rs_camp_Rec
l_next_record_ptr        NUMBER := 1;
l_ignore                 NUMBER;

-- total number of records accessable by caller
l_tot_rec_count          NUMBER := 0;
l_tot_rec_amount         NUMBER := 0;

-- Status local variables
l_return_status          VARCHAR2(1); -- Return value from procedures
l_return_status_full     VARCHAR2(1); -- Calculated return status from

-- Dynamic SQL statement elements
l_cur_get_rs_camp           NUMBER;
l_select_cl              VARCHAR2(2000) := '';
l_order_by_cl            VARCHAR2(2000);
l_rs_camp_where    VARCHAR2(2000) := '';

-- For flex field query
l_flex_where_tbl_type    AS_FOUNDATION_PVT.flex_where_tbl_type;
l_flex_where             VARCHAR2(2000) := NULL;
l_counter                NUMBER;

-- Local scratch record
l_rs_camp_rec AST_rs_camp_PUB.rs_camp_Rec_Type;
l_crit_rs_camp_rec AST_rs_camp_PUB.rs_camp_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_rs_camp_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      /*AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 1.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);*/

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- *************************************************
      -- Generate Dynamic SQL based on criteria passed in.
      -- Doing this for performance. Indexes are disabled when using NVL within static SQL statement.

      -- Ignore condition when criteria is NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Generating Dsql');

      -- Generate Select clause and From clause
      -- Hint: Developer should modify Gen_Select procedure.
      Gen_Select(l_select_cl);

      -- Hint: Developer should modify and implement Gen_Where precedure.
      Gen_rs_camp_Where(l_crit_rs_camp_rec, l_rs_camp_where);

      -- Generate Where clause for flex fields
      -- Hint: Developer can use table/view alias in the From clause generated in Gen_Select procedure

/*
      FOR l_counter IN 1..15 LOOP
          l_flex_where_tbl_type(l_counter).name := 'AST_TEST.attribute' || l_counter;
      END LOOP;

      l_flex_where_tbl_type(16).name := 'AST_TEST.attribute_category';
      l_flex_where_tbl_type(1).value := P_rs_camp_Rec.attribute1;
      l_flex_where_tbl_type(2).value := P_rs_camp_Rec.attribute2;
      l_flex_where_tbl_type(3).value := P_rs_camp_Rec.attribute3;
      l_flex_where_tbl_type(4).value := P_rs_camp_Rec.attribute4;
      l_flex_where_tbl_type(5).value := P_rs_camp_Rec.attribute5;
      l_flex_where_tbl_type(6).value := P_rs_camp_Rec.attribute6;
      l_flex_where_tbl_type(7).value := P_rs_camp_Rec.attribute7;
      l_flex_where_tbl_type(8).value := P_rs_camp_Rec.attribute8;
      l_flex_where_tbl_type(9).value := P_rs_camp_Rec.attribute9;
      l_flex_where_tbl_type(10).value := P_rs_camp_Rec.attribute10;
      l_flex_where_tbl_type(11).value := P_rs_camp_Rec.attribute11;
      l_flex_where_tbl_type(12).value := P_rs_camp_Rec.attribute12;
      l_flex_where_tbl_type(13).value := P_rs_camp_Rec.attribute13;
      l_flex_where_tbl_type(14).value := P_rs_camp_Rec.attribute14;
      l_flex_where_tbl_type(15).value := P_rs_camp_Rec.attribute15;
      l_flex_where_tbl_type(16).value := P_rs_camp_Rec.attribute_category;

      AS_FOUNDATION_PVT.Gen_Flexfield_Where(
          p_flex_where_tbl_type   => l_flex_where_tbl_type,
          x_flex_where_clause     => l_flex_where);
		*/


      -- Hint: if master/detail relationship, generate Where clause for lines level criteria
      -- Generate order by clause
      Gen_rs_camp_order_cl(p_order_by_rec, l_order_by_cl, l_return_status, x_msg_count, x_msg_data);



      -- Debug Message
      JTF_PLSQL_API.Debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Open and Parse Cursor');


      l_cur_get_rs_camp := dbms_sql.open_cursor;

      -- Hint: concatenate all where clause (include flex field/line level if any applies)
      --    dbms_sql.parse(l_cur_get_rs_camp, l_select_cl || l_head_where || l_flex_where || l_lines_where

      --    || l_steam_where || l_order_by_cl, dbms_sql.native);

      -- Hint: Developer should implement Bind Variables procedure according to bind variables in the parameter list

      -- Bind(l_crit_rs_camp_rec, l_crit_exp_purchase_rec, p_start_date, p_end_date,
      --      p_crit_exp_salesforce_id, p_crit_ptr_salesforce_id,
      --      p_crit_salesgroup_id, p_crit_ptr_manager_person_id,
      --      p_win_prob_ceiling, p_win_prob_floor,
      --      p_total_amt_ceiling, p_total_amt_floor,
      --      l_cur_get_rs_camp);

      -- Bind flexfield variables
      AS_FOUNDATION_PVT.Bind_Flexfield_Where(
          p_cursor_id   =>   l_cur_get_rs_camp,
          p_flex_where_tbl_type => l_flex_where_tbl_type);

      -- Define all Select Columns
      Define_Columns(l_crit_rs_camp_rec, l_cur_get_rs_camp);

      -- Execute
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Execute Dsql');


      l_ignore := dbms_sql.execute(l_cur_get_rs_camp);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: Fetch Results');


      -- This loop is here to avoid calling a function in the main
      -- cursor. Basically, calling this function seems to disable
      -- index, but verification is needed. This is a good
      -- place to optimize the code if required.

      LOOP
      -- 1. There are more rows in the cursor.
      -- 2. User does not care about total records, and we need to return more.
      -- 3. Or user cares about total number of records.
      IF((dbms_sql.fetch_rows(l_cur_get_rs_camp)>0) AND ((p_return_tot_count = FND_API.G_TRUE)
        OR (l_returned_rec_count<p_rec_requested) OR (p_rec_requested=FND_API.G_MISS_NUM)))
      THEN
          -- Debug Message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: found');



          -- Hint: Developer need to implement this part
          --      dbms_sql.column_value(l_cur_get_opp, 1, l_opp_rec.lead_id);
          --      dbms_sql.column_value(l_cur_get_opp, 7, l_opp_rec.customer_id);
          --      dbms_sql.column_value(l_cur_get_opp, 8, l_opp_rec.address_id);

          -- Hint: Check access for this record (e.x. AS_ACCESS_PVT.Has_OpportunityAccess)
          -- Return this particular record if
          -- 1. The caller has access to record.
          -- 2. The number of records returned < number of records caller requested in this run.
          -- 3. The record comes AFTER or Equal to the start index the caller requested.

          -- Developer should check whether there is access privilege here
--          IF(l_rs_camp_rec.member_access <> 'N' OR l_rs_camp_rec.member_role <> 'N') THEN
              Get_Column_Values(l_cur_get_rs_camp, l_rs_camp_rec);
              l_tot_rec_count := l_tot_rec_count + 1;
              IF(l_returned_rec_count < p_rec_requested) AND (l_tot_rec_count >= p_start_rec_prt) THEN

                  l_returned_rec_count := l_returned_rec_count + 1;
                  -- insert into resultant tables
                  X_rs_camp_Tbl(l_returned_rec_count) := l_rs_camp_rec;
              END IF;
--          END IF;
      ELSE
          EXIT;
      END IF;
      END LOOP;
      --
      -- End of API body
      --

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'end');



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
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Get_rs_camp;

-- Item-level validation procedures
PROCEDURE Validate_RS_CAMPAIGN_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RS_CAMPAIGN_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
      IF(p_RS_CAMPAIGN_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'AST', 'Private rs_camp API: -Violate NOT NULL constraint(RS_CAMPAIGN_ID)');

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RS_CAMPAIGN_ID is not NULL and p_RS_CAMPAIGN_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_RS_CAMPAIGN_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RS_CAMPAIGN_ID;


PROCEDURE Validate_RESOURCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESOURCE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT       JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'AST', 'Private rs_camp API: -Violate NOT NULL constraint(RESOURCE_ID)');

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_RESOURCE_ID is not NULL and p_RESOURCE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
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


PROCEDURE Validate_CAMPAIGN_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CAMPAIGN_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
      IF(p_CAMPAIGN_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'AST', 'Private rs_camp API: -Violate NOT NULL constraint(CAMPAIGN_ID)');

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CAMPAIGN_ID is not NULL and p_CAMPAIGN_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CAMPAIGN_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CAMPAIGN_ID;


PROCEDURE Validate_START_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_START_DATE                IN   DATE,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
    -- Hint: You may add 'X_Item_Property_Rec  OUT     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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


PROCEDURE Validate_STATUS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_STATUS                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
      IF(p_STATUS is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'AST', 'Private rs_camp API: -Violate NOT NULL constraint(STATUS)');

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_STATUS is not NULL and p_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_STATUS <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_STATUS;


PROCEDURE Validate_ENABLED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ENABLED_FLAG                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT      JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.

    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
      IF(p_ENABLED_FLAG is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'AST', 'Private rs_camp API: -Violate NOT NULL constraint(ENABLED_FLAG)');

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_ENABLED_FLAG is not NULL and p_ENABLED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_ENABLED_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ENABLED_FLAG;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_PLSQL_API.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value

--       stored in database table.
PROCEDURE Validate_rs_camp_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_rs_camp_Rec     IN    rs_camp_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_rs_camp_Rec;

PROCEDURE Validate_rs_camp(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_rs_camp_Rec     IN    rs_camp_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_rs_camp';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_RS_CAMPAIGN_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RS_CAMPAIGN_ID   => P_rs_camp_Rec.RS_CAMPAIGN_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT  parameter if you'd like to pass back item property.

              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RESOURCE_ID(
              p_init_msg_list          => FND_API.G_FALSE,

              p_validation_mode        => p_validation_mode,
              p_RESOURCE_ID   => P_rs_camp_Rec.RESOURCE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT  parameter if you'd like to pass back item property.

              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CAMPAIGN_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CAMPAIGN_ID   => P_rs_camp_Rec.CAMPAIGN_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT  parameter if you'd like to pass back item property.

              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_START_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_START_DATE   => P_rs_camp_Rec.START_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT  parameter if you'd like to pass back item property.

              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_END_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_END_DATE   => P_rs_camp_Rec.END_DATE,
              -- Hint: You may add x_item_property_rec as one of your OUT  parameter if you'd like to pass back item property.

              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_STATUS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_STATUS   => P_rs_camp_Rec.STATUS,
              -- Hint: You may add x_item_property_rec as one of your OUT  parameter if you'd like to pass back item property.

              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ENABLED_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ENABLED_FLAG   => P_rs_camp_Rec.ENABLED_FLAG,
              -- Hint: You may add x_item_property_rec as one of your OUT  parameter if you'd like to pass back item property.

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
          Validate_rs_camp_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_rs_camp_Rec     =>    P_rs_camp_Rec,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AST', 'Private API: ' || l_api_name || 'end');


END Validate_rs_camp;

End AST_rs_camp_PVT;

/
