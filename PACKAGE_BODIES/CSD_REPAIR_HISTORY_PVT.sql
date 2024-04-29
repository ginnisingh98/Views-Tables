--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_HISTORY_PVT" as
/* $Header: csdvdrhb.pls 120.0.12010000.3 2009/09/03 00:47:41 takwong ship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_HISTORY_PVT
-- Purpose          :
-- History          :
-- 02/05/02   travi  Added Object Version Number Column
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_REPAIR_HISTORY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvrehb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_repair_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REPH_Rec     IN    REPH_Rec_Type  := G_MISS_REPH_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_REPAIR_HISTORY_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_repair_history';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_REPAIR_HISTORY_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Create_repair_history_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_REPH_Rec      =>  P_REPH_Rec,
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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Validate_repair_history');

          -- Invoke validation procedures
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Create_repair_history before Validate_repair_history');
END IF;


          Validate_repair_history(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_REPH_Rec  =>  P_REPH_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);

IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Create_repair_history after Validate_repair_history x_return_status'||x_return_status);
END IF;


      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Calling create table handler');

      -- Invoke table handler(CSD_REPAIR_HISTORY_PKG.Insert_Row)
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Create_repair_history before CSD_REPAIR_HISTORY_PKG.Insert_Row');
END IF;


      CSD_REPAIR_HISTORY_PKG.Insert_Row(
          px_REPAIR_HISTORY_ID  => x_REPAIR_HISTORY_ID,
          p_OBJECT_VERSION_NUMBER  => 1, -- travi p_REPH_rec.OBJECT_VERSION_NUMBER,
          p_REQUEST_ID  => p_REPH_rec.REQUEST_ID,
          p_PROGRAM_ID  => p_REPH_rec.PROGRAM_ID,
          p_PROGRAM_APPLICATION_ID  => p_REPH_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_UPDATE_DATE  => p_REPH_rec.PROGRAM_UPDATE_DATE,
          p_CREATED_BY  => G_USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_REPAIR_LINE_ID  => p_REPH_rec.REPAIR_LINE_ID,
          p_EVENT_CODE  => p_REPH_rec.EVENT_CODE,
          p_EVENT_DATE  => p_REPH_rec.EVENT_DATE,
          p_QUANTITY  => p_REPH_rec.QUANTITY,
          p_PARAMN1  => p_REPH_rec.PARAMN1,
          p_PARAMN2  => p_REPH_rec.PARAMN2,
          p_PARAMN3  => p_REPH_rec.PARAMN3,
          p_PARAMN4  => p_REPH_rec.PARAMN4,
          p_PARAMN5  => p_REPH_rec.PARAMN5,
          p_PARAMN6  => p_REPH_rec.PARAMN6,
          p_PARAMN7  => p_REPH_rec.PARAMN7,
          p_PARAMN8  => p_REPH_rec.PARAMN8,
          p_PARAMN9  => p_REPH_rec.PARAMN9,
          p_PARAMN10  => p_REPH_rec.PARAMN10,
          p_PARAMC1  => p_REPH_rec.PARAMC1,
          p_PARAMC2  => p_REPH_rec.PARAMC2,
          p_PARAMC3  => p_REPH_rec.PARAMC3,
          p_PARAMC4  => p_REPH_rec.PARAMC4,
          p_PARAMC5  => p_REPH_rec.PARAMC5,
          p_PARAMC6  => p_REPH_rec.PARAMC6,
          p_PARAMC7  => p_REPH_rec.PARAMC7,
          p_PARAMC8  => p_REPH_rec.PARAMC8,
          p_PARAMC9  => p_REPH_rec.PARAMC9,
          p_PARAMC10  => p_REPH_rec.PARAMC10,
          p_PARAMD1  => p_REPH_rec.PARAMD1,
          p_PARAMD2  => p_REPH_rec.PARAMD2,
          p_PARAMD3  => p_REPH_rec.PARAMD3,
          p_PARAMD4  => p_REPH_rec.PARAMD4,
          p_PARAMD5  => p_REPH_rec.PARAMD5,
          p_PARAMD6  => p_REPH_rec.PARAMD6,
          p_PARAMD7  => p_REPH_rec.PARAMD7,
          p_PARAMD8  => p_REPH_rec.PARAMD8,
          p_PARAMD9  => p_REPH_rec.PARAMD9,
          p_PARAMD10  => p_REPH_rec.PARAMD10,
          p_ATTRIBUTE_CATEGORY  => p_REPH_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_REPH_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_REPH_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_REPH_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_REPH_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_REPH_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_REPH_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_REPH_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_REPH_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_REPH_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_REPH_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_REPH_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_REPH_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_REPH_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_REPH_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_REPH_rec.ATTRIBUTE15,
          p_LAST_UPDATE_LOGIN  => p_REPH_rec.LAST_UPDATE_LOGIN);
      -- Hint: Primary key should be returned.
      -- x_REPAIR_HISTORY_ID := px_REPAIR_HISTORY_ID;
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Create_repair_history after CSD_REPAIR_HISTORY_PKG.Insert_Row x_return_status'||x_return_status);
END IF;



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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Create_repair_history_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_REPH_Rec      =>  P_REPH_Rec,
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
--   RAISE;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
End Create_repair_history;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_repair_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REPH_Rec     IN    REPH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_repair_history(REPAIR_HISTORY_ID Number) IS
    Select rowid,
           REPAIR_HISTORY_ID,
           OBJECT_VERSION_NUMBER,
           REQUEST_ID,
           PROGRAM_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           REPAIR_LINE_ID,
           EVENT_CODE,
           EVENT_DATE,
           QUANTITY,
           PARAMN1,
           PARAMN2,
           PARAMN3,
           PARAMN4,
           PARAMN5,
           PARAMN6,
           PARAMN7,
           PARAMN8,
           PARAMN9,
           PARAMN10,
           PARAMC1,
           PARAMC2,
           PARAMC3,
           PARAMC4,
           PARAMC5,
           PARAMC6,
           PARAMC7,
           PARAMC8,
           PARAMC9,
           PARAMC10,
           PARAMD1,
           PARAMD2,
           PARAMD3,
           PARAMD4,
           PARAMD5,
           PARAMD6,
           PARAMD7,
           PARAMD8,
           PARAMD9,
           PARAMD10,
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
           LAST_UPDATE_LOGIN
    From  CSD_REPAIR_HISTORY
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
  l_api_name                CONSTANT VARCHAR2(30) := 'Update_repair_history';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  -- Local Variables
  l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
  l_ref_REPH_rec  CSD_repair_history_PVT.REPH_Rec_Type;
  l_tar_REPH_rec  CSD_repair_history_PVT.REPH_Rec_Type := P_REPH_Rec;
  l_rowid  ROWID;

  --  travi ovn validation
  l_OBJECT_VERSION_NUMBER NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_REPAIR_HISTORY_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Update_repair_history_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_REPH_Rec      =>  P_REPH_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
/*
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: - Open Cursor to Select');

/*
      Open C_Get_repair_history( l_tar_REPH_rec.REPAIR_HISTORY_ID);

      Fetch C_Get_repair_history into
               l_rowid,
               l_ref_REPH_rec.REPAIR_HISTORY_ID,
               l_ref_REPH_rec.OBJECT_VERSION_NUMBER,
               l_ref_REPH_rec.REQUEST_ID,
               l_ref_REPH_rec.PROGRAM_ID,
               l_ref_REPH_rec.PROGRAM_APPLICATION_ID,
               l_ref_REPH_rec.PROGRAM_UPDATE_DATE,
               l_ref_REPH_rec.CREATED_BY,
               l_ref_REPH_rec.CREATION_DATE,
               l_ref_REPH_rec.LAST_UPDATED_BY,
               l_ref_REPH_rec.LAST_UPDATE_DATE,
               l_ref_REPH_rec.REPAIR_LINE_ID,
               l_ref_REPH_rec.EVENT_CODE,
               l_ref_REPH_rec.EVENT_DATE,
               l_ref_REPH_rec.QUANTITY,
               l_ref_REPH_rec.PARAMN1,
               l_ref_REPH_rec.PARAMN2,
               l_ref_REPH_rec.PARAMN3,
               l_ref_REPH_rec.PARAMN4,
               l_ref_REPH_rec.PARAMN5,
               l_ref_REPH_rec.PARAMN6,
               l_ref_REPH_rec.PARAMN7,
               l_ref_REPH_rec.PARAMN8,
               l_ref_REPH_rec.PARAMN9,
               l_ref_REPH_rec.PARAMN10,
               l_ref_REPH_rec.PARAMC1,
               l_ref_REPH_rec.PARAMC2,
               l_ref_REPH_rec.PARAMC3,
               l_ref_REPH_rec.PARAMC4,
               l_ref_REPH_rec.PARAMC5,
               l_ref_REPH_rec.PARAMC6,
               l_ref_REPH_rec.PARAMC7,
               l_ref_REPH_rec.PARAMC8,
               l_ref_REPH_rec.PARAMC9,
               l_ref_REPH_rec.PARAMC10,
               l_ref_REPH_rec.PARAMD1,
               l_ref_REPH_rec.PARAMD2,
               l_ref_REPH_rec.PARAMD3,
               l_ref_REPH_rec.PARAMD4,
               l_ref_REPH_rec.PARAMD5,
               l_ref_REPH_rec.PARAMD6,
               l_ref_REPH_rec.PARAMD7,
               l_ref_REPH_rec.PARAMD8,
               l_ref_REPH_rec.PARAMD9,
               l_ref_REPH_rec.PARAMD10,
               l_ref_REPH_rec.ATTRIBUTE_CATEGORY,
               l_ref_REPH_rec.ATTRIBUTE1,
               l_ref_REPH_rec.ATTRIBUTE2,
               l_ref_REPH_rec.ATTRIBUTE3,
               l_ref_REPH_rec.ATTRIBUTE4,
               l_ref_REPH_rec.ATTRIBUTE5,
               l_ref_REPH_rec.ATTRIBUTE6,
               l_ref_REPH_rec.ATTRIBUTE7,
               l_ref_REPH_rec.ATTRIBUTE8,
               l_ref_REPH_rec.ATTRIBUTE9,
               l_ref_REPH_rec.ATTRIBUTE10,
               l_ref_REPH_rec.ATTRIBUTE11,
               l_ref_REPH_rec.ATTRIBUTE12,
               l_ref_REPH_rec.ATTRIBUTE13,
               l_ref_REPH_rec.ATTRIBUTE14,
               l_ref_REPH_rec.ATTRIBUTE15,
               l_ref_REPH_rec.LAST_UPDATE_LOGIN;

       If ( C_Get_repair_history%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSD', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'repair_history', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: - Close Cursor');
       Close     C_Get_repair_history;
*/


      If (l_tar_REPH_rec.last_update_date is NULL or
          l_tar_REPH_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSD', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_REPH_rec.last_update_date <> l_ref_REPH_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSD', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'repair_history', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Validate_repair_history');

          -- Invoke validation procedures
          Validate_repair_history(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_REPH_Rec  =>  P_REPH_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Calling update table handler');

      -- travi OBJECT_VERSION_NUMBER validation
     l_OBJECT_VERSION_NUMBER := p_REPH_rec.OBJECT_VERSION_NUMBER + 1;

      -- Invoke table handler(CSD_REPAIR_HISTORY_PKG.Update_Row)
      CSD_REPAIR_HISTORY_PKG.Update_Row(
          p_REPAIR_HISTORY_ID  => p_REPH_rec.REPAIR_HISTORY_ID,
          p_OBJECT_VERSION_NUMBER  => l_OBJECT_VERSION_NUMBER, -- travi p_REPH_rec.OBJECT_VERSION_NUMBER,
          p_REQUEST_ID  => p_REPH_rec.REQUEST_ID,
          p_PROGRAM_ID  => p_REPH_rec.PROGRAM_ID,
          p_PROGRAM_APPLICATION_ID  => p_REPH_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_UPDATE_DATE  => p_REPH_rec.PROGRAM_UPDATE_DATE,
          p_CREATED_BY  => G_USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_REPAIR_LINE_ID  => p_REPH_rec.REPAIR_LINE_ID,
          p_EVENT_CODE  => p_REPH_rec.EVENT_CODE,
          p_EVENT_DATE  => p_REPH_rec.EVENT_DATE,
          p_QUANTITY  => p_REPH_rec.QUANTITY,
          p_PARAMN1  => p_REPH_rec.PARAMN1,
          p_PARAMN2  => p_REPH_rec.PARAMN2,
          p_PARAMN3  => p_REPH_rec.PARAMN3,
          p_PARAMN4  => p_REPH_rec.PARAMN4,
          p_PARAMN5  => p_REPH_rec.PARAMN5,
          p_PARAMN6  => p_REPH_rec.PARAMN6,
          p_PARAMN7  => p_REPH_rec.PARAMN7,
          p_PARAMN8  => p_REPH_rec.PARAMN8,
          p_PARAMN9  => p_REPH_rec.PARAMN9,
          p_PARAMN10  => p_REPH_rec.PARAMN10,
          p_PARAMC1  => p_REPH_rec.PARAMC1,
          p_PARAMC2  => p_REPH_rec.PARAMC2,
          p_PARAMC3  => p_REPH_rec.PARAMC3,
          p_PARAMC4  => p_REPH_rec.PARAMC4,
          p_PARAMC5  => p_REPH_rec.PARAMC5,
          p_PARAMC6  => p_REPH_rec.PARAMC6,
          p_PARAMC7  => p_REPH_rec.PARAMC7,
          p_PARAMC8  => p_REPH_rec.PARAMC8,
          p_PARAMC9  => p_REPH_rec.PARAMC9,
          p_PARAMC10  => p_REPH_rec.PARAMC10,
          p_PARAMD1  => p_REPH_rec.PARAMD1,
          p_PARAMD2  => p_REPH_rec.PARAMD2,
          p_PARAMD3  => p_REPH_rec.PARAMD3,
          p_PARAMD4  => p_REPH_rec.PARAMD4,
          p_PARAMD5  => p_REPH_rec.PARAMD5,
          p_PARAMD6  => p_REPH_rec.PARAMD6,
          p_PARAMD7  => p_REPH_rec.PARAMD7,
          p_PARAMD8  => p_REPH_rec.PARAMD8,
          p_PARAMD9  => p_REPH_rec.PARAMD9,
          p_PARAMD10  => p_REPH_rec.PARAMD10,
          p_ATTRIBUTE_CATEGORY  => p_REPH_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_REPH_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_REPH_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_REPH_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_REPH_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_REPH_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_REPH_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_REPH_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_REPH_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_REPH_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_REPH_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_REPH_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_REPH_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_REPH_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_REPH_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_REPH_rec.ATTRIBUTE15,
          p_LAST_UPDATE_LOGIN  => p_REPH_rec.LAST_UPDATE_LOGIN);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Update_repair_history_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_REPH_Rec      =>  P_REPH_Rec,
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
--   RAISE;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
End Update_repair_history;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_repair_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REPH_Rec     IN REPH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_repair_history';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_REPAIR_HISTORY_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'start');


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
          AS_CALLOUT_PKG.Delete_repair_history_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_REPH_Rec      =>  P_REPH_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
/*
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD',  'Private API: Calling delete table handler');

      -- Invoke table handler(CSD_REPAIR_HISTORY_PKG.Delete_Row)
      CSD_REPAIR_HISTORY_PKG.Delete_Row(
          p_REPAIR_HISTORY_ID  => p_REPH_rec.REPAIR_HISTORY_ID,
          p_OBJECT_VERSION_NUMBER  => p_REPH_rec.OBJECT_VERSION_NUMBER);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'end');


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
          AS_CALLOUT_PKG.Delete_repair_history_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_REPH_Rec      =>  P_REPH_Rec,
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
--   RAISE;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
End Delete_repair_history;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_REPH_Rec   IN  CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type,
    p_cur_get_REPH   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Define Columns Begins');

      -- define all columns for CSD_REPAIR_HISTORY_V view
      dbms_sql.define_column(p_cur_get_REPH, 1, P_REPH_Rec.REPAIR_HISTORY_ID);
      dbms_sql.define_column(p_cur_get_REPH, 2, P_REPH_Rec.REQUEST_ID);
      dbms_sql.define_column(p_cur_get_REPH, 3, P_REPH_Rec.REPAIR_LINE_ID);
      dbms_sql.define_column(p_cur_get_REPH, 4, P_REPH_Rec.EVENT_CODE, 30);
      dbms_sql.define_column(p_cur_get_REPH, 5, P_REPH_Rec.EVENT_MEANING, 80);
      dbms_sql.define_column(p_cur_get_REPH, 6, P_REPH_Rec.EVENT_DATE);
      dbms_sql.define_column(p_cur_get_REPH, 7, P_REPH_Rec.QUANTITY);
      dbms_sql.define_column(p_cur_get_REPH, 8, P_REPH_Rec.PARAMN1);
      dbms_sql.define_column(p_cur_get_REPH, 9, P_REPH_Rec.PARAMN2);
      dbms_sql.define_column(p_cur_get_REPH, 10, P_REPH_Rec.PARAMN3);
      dbms_sql.define_column(p_cur_get_REPH, 11, P_REPH_Rec.PARAMN4);
      dbms_sql.define_column(p_cur_get_REPH, 12, P_REPH_Rec.PARAMN5);
      dbms_sql.define_column(p_cur_get_REPH, 13, P_REPH_Rec.PARAMN6);
      dbms_sql.define_column(p_cur_get_REPH, 14, P_REPH_Rec.PARAMN7);
      dbms_sql.define_column(p_cur_get_REPH, 15, P_REPH_Rec.PARAMN8);
      dbms_sql.define_column(p_cur_get_REPH, 16, P_REPH_Rec.PARAMN9);
      dbms_sql.define_column(p_cur_get_REPH, 17, P_REPH_Rec.PARAMN10);
      dbms_sql.define_column(p_cur_get_REPH, 18, P_REPH_Rec.PARAMC1, 240);
      dbms_sql.define_column(p_cur_get_REPH, 19, P_REPH_Rec.PARAMC2, 240);
      dbms_sql.define_column(p_cur_get_REPH, 20, P_REPH_Rec.PARAMC3, 240);
      dbms_sql.define_column(p_cur_get_REPH, 21, P_REPH_Rec.PARAMC4, 240);
      dbms_sql.define_column(p_cur_get_REPH, 22, P_REPH_Rec.PARAMC5, 240);
      dbms_sql.define_column(p_cur_get_REPH, 23, P_REPH_Rec.PARAMC6, 240);
      dbms_sql.define_column(p_cur_get_REPH, 24, P_REPH_Rec.PARAMC7, 240);
      dbms_sql.define_column(p_cur_get_REPH, 25, P_REPH_Rec.PARAMC8, 240);
      dbms_sql.define_column(p_cur_get_REPH, 26, P_REPH_Rec.PARAMC9, 240);
      dbms_sql.define_column(p_cur_get_REPH, 27, P_REPH_Rec.PARAMC10, 240);
      dbms_sql.define_column(p_cur_get_REPH, 28, P_REPH_Rec.PARAMD1);
      dbms_sql.define_column(p_cur_get_REPH, 29, P_REPH_Rec.PARAMD2);
      dbms_sql.define_column(p_cur_get_REPH, 30, P_REPH_Rec.PARAMD3);
      dbms_sql.define_column(p_cur_get_REPH, 31, P_REPH_Rec.PARAMD4);
      dbms_sql.define_column(p_cur_get_REPH, 32, P_REPH_Rec.PARAMD5);
      dbms_sql.define_column(p_cur_get_REPH, 33, P_REPH_Rec.PARAMD6);
      dbms_sql.define_column(p_cur_get_REPH, 34, P_REPH_Rec.PARAMD7);
      dbms_sql.define_column(p_cur_get_REPH, 35, P_REPH_Rec.PARAMD8);
      dbms_sql.define_column(p_cur_get_REPH, 36, P_REPH_Rec.PARAMD9);
      dbms_sql.define_column(p_cur_get_REPH, 37, P_REPH_Rec.PARAMD10);
      dbms_sql.define_column(p_cur_get_REPH, 38, P_REPH_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_REPH, 39, P_REPH_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_REPH, 40, P_REPH_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_REPH, 41, P_REPH_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_REPH, 42, P_REPH_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_REPH, 43, P_REPH_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_REPH, 44, P_REPH_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_REPH, 45, P_REPH_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_REPH, 46, P_REPH_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_REPH, 47, P_REPH_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_REPH, 48, P_REPH_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_REPH, 49, P_REPH_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_REPH, 50, P_REPH_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_REPH, 51, P_REPH_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_REPH, 52, P_REPH_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_REPH, 53, P_REPH_Rec.ATTRIBUTE15, 150);
      dbms_sql.define_column(p_cur_get_REPH, 54, P_REPH_Rec.OBJECT_VERSION_NUMBER);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_REPH   IN   NUMBER,
    X_REPH_Rec   OUT NOCOPY  CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Get Column Values Begins');

      -- get all column values for CSD_REPAIR_HISTORY_V table
      dbms_sql.column_value(p_cur_get_REPH, 1, X_REPH_Rec.REPAIR_HISTORY_ID);
      dbms_sql.column_value(p_cur_get_REPH, 2, X_REPH_Rec.REQUEST_ID);
      dbms_sql.column_value(p_cur_get_REPH, 3, X_REPH_Rec.REPAIR_LINE_ID);
      dbms_sql.column_value(p_cur_get_REPH, 4, X_REPH_Rec.EVENT_CODE);
      dbms_sql.column_value(p_cur_get_REPH, 5, X_REPH_Rec.EVENT_MEANING);
      dbms_sql.column_value(p_cur_get_REPH, 6, X_REPH_Rec.EVENT_DATE);
      dbms_sql.column_value(p_cur_get_REPH, 7, X_REPH_Rec.QUANTITY);
      dbms_sql.column_value(p_cur_get_REPH, 8, X_REPH_Rec.PARAMN1);
      dbms_sql.column_value(p_cur_get_REPH, 9, X_REPH_Rec.PARAMN2);
      dbms_sql.column_value(p_cur_get_REPH, 10, X_REPH_Rec.PARAMN3);
      dbms_sql.column_value(p_cur_get_REPH, 11, X_REPH_Rec.PARAMN4);
      dbms_sql.column_value(p_cur_get_REPH, 12, X_REPH_Rec.PARAMN5);
      dbms_sql.column_value(p_cur_get_REPH, 13, X_REPH_Rec.PARAMN6);
      dbms_sql.column_value(p_cur_get_REPH, 14, X_REPH_Rec.PARAMN7);
      dbms_sql.column_value(p_cur_get_REPH, 15, X_REPH_Rec.PARAMN8);
      dbms_sql.column_value(p_cur_get_REPH, 16, X_REPH_Rec.PARAMN9);
      dbms_sql.column_value(p_cur_get_REPH, 17, X_REPH_Rec.PARAMN10);
      dbms_sql.column_value(p_cur_get_REPH, 18, X_REPH_Rec.PARAMC1);
      dbms_sql.column_value(p_cur_get_REPH, 19, X_REPH_Rec.PARAMC2);
      dbms_sql.column_value(p_cur_get_REPH, 20, X_REPH_Rec.PARAMC3);
      dbms_sql.column_value(p_cur_get_REPH, 21, X_REPH_Rec.PARAMC4);
      dbms_sql.column_value(p_cur_get_REPH, 22, X_REPH_Rec.PARAMC5);
      dbms_sql.column_value(p_cur_get_REPH, 23, X_REPH_Rec.PARAMC6);
      dbms_sql.column_value(p_cur_get_REPH, 24, X_REPH_Rec.PARAMC7);
      dbms_sql.column_value(p_cur_get_REPH, 25, X_REPH_Rec.PARAMC8);
      dbms_sql.column_value(p_cur_get_REPH, 26, X_REPH_Rec.PARAMC9);
      dbms_sql.column_value(p_cur_get_REPH, 27, X_REPH_Rec.PARAMC10);
      dbms_sql.column_value(p_cur_get_REPH, 28, X_REPH_Rec.PARAMD1);
      dbms_sql.column_value(p_cur_get_REPH, 29, X_REPH_Rec.PARAMD2);
      dbms_sql.column_value(p_cur_get_REPH, 30, X_REPH_Rec.PARAMD3);
      dbms_sql.column_value(p_cur_get_REPH, 31, X_REPH_Rec.PARAMD4);
      dbms_sql.column_value(p_cur_get_REPH, 32, X_REPH_Rec.PARAMD5);
      dbms_sql.column_value(p_cur_get_REPH, 33, X_REPH_Rec.PARAMD6);
      dbms_sql.column_value(p_cur_get_REPH, 34, X_REPH_Rec.PARAMD7);
      dbms_sql.column_value(p_cur_get_REPH, 35, X_REPH_Rec.PARAMD8);
      dbms_sql.column_value(p_cur_get_REPH, 36, X_REPH_Rec.PARAMD9);
      dbms_sql.column_value(p_cur_get_REPH, 37, X_REPH_Rec.PARAMD10);
      dbms_sql.column_value(p_cur_get_REPH, 38, X_REPH_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_REPH, 39, X_REPH_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_REPH, 40, X_REPH_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_REPH, 41, X_REPH_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_REPH, 42, X_REPH_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_REPH, 43, X_REPH_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_REPH, 44, X_REPH_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_REPH, 45, X_REPH_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_REPH, 46, X_REPH_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_REPH, 47, X_REPH_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_REPH, 48, X_REPH_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_REPH, 49, X_REPH_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_REPH, 50, X_REPH_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_REPH, 51, X_REPH_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_REPH, 52, X_REPH_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_REPH, 53, X_REPH_Rec.ATTRIBUTE15);
      dbms_sql.column_value(p_cur_get_REPH, 54, X_REPH_Rec.OBJECT_VERSION_NUMBER);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_REPH_order_cl(
    p_order_by_rec   IN   CSD_REPAIR_HISTORY_PVT.REPH_sort_rec_type,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generate Order by Begins');

      -- Hint: Developer should add more statements according to CSD_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Invoke JTF_PLSQL_API.Translate_OrderBy');

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generate Order by Ends');
END Gen_REPH_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_REPH_Rec   IN   CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_REPH   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_REPH_Rec.REPAIR_HISTORY_ID IS NOT NULL) AND (P_REPH_Rec.REPAIR_HISTORY_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_REPH, ':p_REPAIR_HISTORY_ID', P_REPH_Rec.REPAIR_HISTORY_ID);
      END IF;

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Bind Variables Ends');
END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY   VARCHAR2
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generate Select Begins');

      x_select_cl := 'Select ' ||
                'CSD_REPAIR_HISTORY_V.REPAIR_HISTORY_ID,' ||
                'CSD_REPAIR_HISTORY_V.REQUEST_ID,' ||
                'CSD_REPAIR_HISTORY_V.PROGRAM_ID,' ||
                'CSD_REPAIR_HISTORY_V.PROGRAM_APPLICATION_ID,' ||
                'CSD_REPAIR_HISTORY_V.PROGRAM_UPDATE_DATE,' ||
                'CSD_REPAIR_HISTORY_V.CREATED_BY,' ||
                'CSD_REPAIR_HISTORY_V.CREATION_DATE,' ||
                'CSD_REPAIR_HISTORY_V.LAST_UPDATED_BY,' ||
                'CSD_REPAIR_HISTORY_V.LAST_UPDATE_DATE,' ||
                'CSD_REPAIR_HISTORY_V.LAST_UPDATE_LOGIN,' ||
                'CSD_REPAIR_HISTORY_V.REPAIR_LINE_ID,' ||
                'CSD_REPAIR_HISTORY_V.EVENT_CODE,' ||
                'CSD_REPAIR_HISTORY_V.EVENT_MEANING,' ||
                'CSD_REPAIR_HISTORY_V.EVENT_DATE,' ||
                'CSD_REPAIR_HISTORY_V.QUANTITY,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN1,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN2,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN3,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN4,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN5,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN6,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN7,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN8,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN9,' ||
                'CSD_REPAIR_HISTORY_V.PARAMN10,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC1,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC2,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC3,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC4,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC5,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC6,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC7,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC8,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC9,' ||
                'CSD_REPAIR_HISTORY_V.PARAMC10,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD1,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD2,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD3,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD4,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD5,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD6,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD7,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD8,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD9,' ||
                'CSD_REPAIR_HISTORY_V.PARAMD10,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE_CATEGORY,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE1,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE2,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE3,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE4,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE5,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE6,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE7,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE8,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE9,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE10,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE11,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE12,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE13,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE14,' ||
                'CSD_REPAIR_HISTORY_V.ATTRIBUTE15,' ||
                'CSD_REPAIR_HISTORY_V.OBJECT_VERSION_NUMBER' ||
                'from CSD_REPAIR_HISTORY_V';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_REPH_Where(
    P_REPH_Rec     IN   CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type,
    x_REPH_where   OUT NOCOPY   VARCHAR2
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generate Where Begins');

      -- There are three examples for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_REPH_Rec.REPAIR_HISTORY_ID IS NOT NULL) AND (P_REPH_Rec.REPAIR_HISTORY_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_REPH_where IS NULL) THEN
              x_REPH_where := 'Where';
          ELSE
              x_REPH_where := x_REPH_where || ' AND ';
          END IF;
          x_REPH_where := x_REPH_where || 'P_REPH_Rec.REPAIR_HISTORY_ID = :p_REPAIR_HISTORY_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_REPH_Rec.PROGRAM_UPDATE_DATE IS NOT NULL) AND (P_REPH_Rec.PROGRAM_UPDATE_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_REPH_Rec.PROGRAM_UPDATE_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_REPH_Rec.PROGRAM_UPDATE_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_REPH_where IS NULL) THEN
              x_REPH_where := 'Where ';
          ELSE
              x_REPH_where := x_REPH_where || ' AND ';
          END IF;
          x_REPH_where := x_REPH_where || 'P_REPH_Rec.PROGRAM_UPDATE_DATE ' || l_operator || ' :p_PROGRAM_UPDATE_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_REPH_Rec.EVENT_CODE IS NOT NULL) AND (P_REPH_Rec.EVENT_CODE <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_REPH_Rec.EVENT_CODE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_REPH_Rec.EVENT_CODE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_REPH_where IS NULL) THEN
              x_REPH_where := 'Where ';
          ELSE
              x_REPH_where := x_REPH_where || ' AND ';
          END IF;
          x_REPH_where := x_REPH_where || 'P_REPH_Rec.EVENT_CODE ' || l_operator || ' :p_EVENT_CODE';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generate Where Ends');

END Gen_REPH_Where;

PROCEDURE Get_repair_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_REPH_Rec     IN    REPH_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   REPH_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_REPH_Tbl  OUT NOCOPY  REPH_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_repair_history';
l_api_version_number      CONSTANT NUMBER   := 2.0;

-- Local identity variables
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

-- Local record counters
l_returned_rec_count     NUMBER := 0; -- number of records returned in x_X_REPH_Rec
l_next_record_ptr        NUMBER := 1;
l_ignore                 NUMBER;

-- total number of records accessable by caller
l_tot_rec_count          NUMBER := 0;
l_tot_rec_amount         NUMBER := 0;

-- Status local variables
l_return_status          VARCHAR2(1); -- Return value from procedures
l_return_status_full     VARCHAR2(1); -- Calculated return status from

-- Dynamic SQL statement elements
l_cur_get_REPH           NUMBER;
l_select_cl              VARCHAR2(2000) := '';
l_order_by_cl            VARCHAR2(2000);
l_REPH_where    VARCHAR2(2000) := '';

-- For flex field query
l_flex_where_tbl_type    AS_FOUNDATION_PVT.flex_where_tbl_type;
l_flex_where             VARCHAR2(2000) := NULL;
l_counter                NUMBER;

-- Local scratch record
l_REPH_rec CSD_REPAIR_HISTORY_Pvt.REPH_Rec_Type;
l_crit_REPH_rec CSD_REPAIR_HISTORY_Pvt.REPH_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_REPAIR_HISTORY_PVT;

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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
/*
      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
          p_api_version_number => 2.0
         ,p_salesforce_id => p_identity_salesforce_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,x_sales_member_rec => l_identity_sales_member_rec);
*/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- *************************************************
      -- Generate Dynamic SQL based on criteria passed in.
      -- Doing this for performance. Indexes are disabled when using NVL within static SQL statement.
      -- Ignore condition when criteria is NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generating Dsql');
      -- Generate Select clause and From clause
      -- Hint: Developer should modify Gen_Select procedure.
      Gen_Select(l_select_cl);

      -- Hint: Developer should modify and implement Gen_Where precedure.
      Gen_REPH_Where(l_crit_REPH_rec, l_REPH_where);

      -- Generate Where clause for flex fields
      -- Hint: Developer can use table/view alias in the From clause generated in Gen_Select procedure

      FOR l_counter IN 1..15 LOOP
          l_flex_where_tbl_type(l_counter).name := 'CSD_REPAIR_HISTORY_V.attribute' || l_counter;
      END LOOP;

      l_flex_where_tbl_type(16).name := 'CSD_REPAIR_HISTORY_V.attribute_category';
      l_flex_where_tbl_type(1).value := P_REPH_Rec.attribute1;
      l_flex_where_tbl_type(2).value := P_REPH_Rec.attribute2;
      l_flex_where_tbl_type(3).value := P_REPH_Rec.attribute3;
      l_flex_where_tbl_type(4).value := P_REPH_Rec.attribute4;
      l_flex_where_tbl_type(5).value := P_REPH_Rec.attribute5;
      l_flex_where_tbl_type(6).value := P_REPH_Rec.attribute6;
      l_flex_where_tbl_type(7).value := P_REPH_Rec.attribute7;
      l_flex_where_tbl_type(8).value := P_REPH_Rec.attribute8;
      l_flex_where_tbl_type(9).value := P_REPH_Rec.attribute9;
      l_flex_where_tbl_type(10).value := P_REPH_Rec.attribute10;
      l_flex_where_tbl_type(11).value := P_REPH_Rec.attribute11;
      l_flex_where_tbl_type(12).value := P_REPH_Rec.attribute12;
      l_flex_where_tbl_type(13).value := P_REPH_Rec.attribute13;
      l_flex_where_tbl_type(14).value := P_REPH_Rec.attribute14;
      l_flex_where_tbl_type(15).value := P_REPH_Rec.attribute15;
      l_flex_where_tbl_type(16).value := P_REPH_Rec.attribute_category;

      AS_FOUNDATION_PVT.Gen_Flexfield_Where(
          p_flex_where_tbl_type   => l_flex_where_tbl_type,
          x_flex_where_clause     => l_flex_where);

      -- Hint: if master/detail relationship, generate Where clause for lines level criteria
      -- Generate order by clause
      Gen_REPH_order_cl(p_order_by_rec, l_order_by_cl, l_return_status, x_msg_count, x_msg_data);

      -- Debug Message
      JTF_PLSQL_API.Debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Open and Parse Cursor');

      l_cur_get_REPH := dbms_sql.open_cursor;

      -- Hint: concatenate all where clause (include flex field/line level if any applies)
      --    dbms_sql.parse(l_cur_get_REPH, l_select_cl || l_head_where || l_flex_where || l_lines_where
      --    || l_steam_where || l_order_by_cl, dbms_sql.native);

      -- Hint: Developer should implement Bind Variables procedure according to bind variables in the parameter list
      -- Bind(l_crit_REPH_rec, l_crit_exp_purchase_rec, p_start_date, p_end_date,
      --      p_crit_exp_salesforce_id, p_crit_ptr_salesforce_id,
      --      p_crit_salesgroup_id, p_crit_ptr_manager_person_id,
      --      p_win_prob_ceiling, p_win_prob_floor,
      --      p_total_amt_ceiling, p_total_amt_floor,
      --      l_cur_get_REPH);

      -- Bind flexfield variables
      AS_FOUNDATION_PVT.Bind_Flexfield_Where(
          p_cursor_id   =>   l_cur_get_REPH,
          p_flex_where_tbl_type => l_flex_where_tbl_type);

      -- Define all Select Columns
      Define_Columns(l_crit_REPH_rec, l_cur_get_REPH);

      -- Execute
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Execute Dsql');

      l_ignore := dbms_sql.execute(l_cur_get_REPH);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Fetch Results');

      -- This loop is here to avoid calling a function in the main
      -- cursor. Basically, calling this function seems to disable
      -- index, but verification is needed. This is a good
      -- place to optimize the code if required.

      LOOP
      -- 1. There are more rows in the cursor.
      -- 2. User does not care about total records, and we need to return more.
      -- 3. Or user cares about total number of records.
      IF((dbms_sql.fetch_rows(l_cur_get_REPH)>0) AND ((p_return_tot_count = FND_API.G_TRUE)
        OR (l_returned_rec_count<p_rec_requested) OR (p_rec_requested=FND_API.G_MISS_NUM)))
      THEN
          -- Debug Message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: found');

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
--          IF(l_REPH_rec.member_access <> 'N' OR l_REPH_rec.member_role <> 'N') THEN
              Get_Column_Values(l_cur_get_REPH, l_REPH_rec);
              l_tot_rec_count := l_tot_rec_count + 1;
              IF(l_returned_rec_count < p_rec_requested) AND (l_tot_rec_count >= p_start_rec_prt) THEN
                  l_returned_rec_count := l_returned_rec_count + 1;
                  -- insert into resultant tables
                  X_REPH_Tbl(l_returned_rec_count) := l_REPH_rec;
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'end');


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
--   RAISE;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--   RAISE;
End Get_repair_history;


-- Item-level validation procedures
PROCEDURE Validate_REPAIR_HISTORY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REPAIR_HISTORY_ID                IN   NUMBER,
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
      IF(p_REPAIR_HISTORY_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repair_history API: -Violate NOT NULL constraint(REPAIR_HISTORY_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REPAIR_HISTORY_ID is not NULL and p_REPAIR_HISTORY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REPAIR_HISTORY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REPAIR_HISTORY_ID;


PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
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
          -- IF p_REQUEST_ID is not NULL and p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUEST_ID;


PROCEDURE Validate_REPAIR_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REPAIR_LINE_ID                IN   NUMBER,
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
      IF(p_REPAIR_LINE_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repair_history API: -Violate NOT NULL constraint(REPAIR_LINE_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REPAIR_LINE_ID is not NULL and p_REPAIR_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REPAIR_LINE_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REPAIR_LINE_ID;


PROCEDURE Validate_EVENT_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_EVENT_CODE                IN   VARCHAR2,
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
      IF(p_EVENT_CODE is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repair_history API: -Violate NOT NULL constraint(EVENT_CODE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_EVENT_CODE is not NULL and p_EVENT_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_EVENT_CODE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_EVENT_CODE;




PROCEDURE Validate_EVENT_meaning (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_EVENT_meaning                IN   VARCHAR2,
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
      IF(p_EVENT_meaning is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repair_history API: -Violate NOT NULL constraint(EVENT_MEANING)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_EVENT_meaning is not NULL and p_EVENT_meaning <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_EVENT_meaning <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_EVENT_meaning;


PROCEDURE Validate_EVENT_DATE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_EVENT_DATE                IN   DATE,
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
      IF(p_EVENT_DATE is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repair_history API: -Violate NOT NULL constraint(EVENT_DATE)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_EVENT_DATE is not NULL and p_EVENT_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_EVENT_DATE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_EVENT_DATE;


PROCEDURE Validate_QUANTITY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_QUANTITY                IN   NUMBER,
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
          -- IF p_QUANTITY is not NULL and p_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_QUANTITY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_QUANTITY;


PROCEDURE Validate_PARAMN1 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN1                IN   NUMBER,
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
          -- IF p_PARAMN1 is not NULL and p_PARAMN1 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN1 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN1;


PROCEDURE Validate_PARAMN2 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN2                IN   NUMBER,
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
          -- IF p_PARAMN2 is not NULL and p_PARAMN2 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN2 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN2;


PROCEDURE Validate_PARAMN3 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN3                IN   NUMBER,
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
          -- IF p_PARAMN3 is not NULL and p_PARAMN3 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN3 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN3;


PROCEDURE Validate_PARAMN4 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN4                IN   NUMBER,
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
          -- IF p_PARAMN4 is not NULL and p_PARAMN4 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN4 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN4;


PROCEDURE Validate_PARAMN5 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN5                IN   NUMBER,
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
          -- IF p_PARAMN5 is not NULL and p_PARAMN5 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN5 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN5;


PROCEDURE Validate_PARAMN6 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN6                IN   NUMBER,
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
          -- IF p_PARAMN6 is not NULL and p_PARAMN6 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN6 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN6;


PROCEDURE Validate_PARAMN7 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN7                IN   NUMBER,
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
          -- IF p_PARAMN7 is not NULL and p_PARAMN7 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN7 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN7;


PROCEDURE Validate_PARAMN8 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN8                IN   NUMBER,
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
          -- IF p_PARAMN8 is not NULL and p_PARAMN8 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN8 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN8;


PROCEDURE Validate_PARAMN9 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN9                IN   NUMBER,
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
          -- IF p_PARAMN9 is not NULL and p_PARAMN9 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN9 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN9;


PROCEDURE Validate_PARAMN10 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMN10                IN   NUMBER,
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
          -- IF p_PARAMN10 is not NULL and p_PARAMN10 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMN10 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMN10;


PROCEDURE Validate_PARAMC1 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC1                IN   VARCHAR2,
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
          -- IF p_PARAMC1 is not NULL and p_PARAMC1 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC1 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC1;


PROCEDURE Validate_PARAMC2 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC2                IN   VARCHAR2,
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
          -- IF p_PARAMC2 is not NULL and p_PARAMC2 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC2 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC2;


PROCEDURE Validate_PARAMC3 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC3                IN   VARCHAR2,
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
          -- IF p_PARAMC3 is not NULL and p_PARAMC3 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC3 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC3;


PROCEDURE Validate_PARAMC4 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC4                IN   VARCHAR2,
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
          -- IF p_PARAMC4 is not NULL and p_PARAMC4 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC4 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC4;


PROCEDURE Validate_PARAMC5 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC5                IN   VARCHAR2,
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
          -- IF p_PARAMC5 is not NULL and p_PARAMC5 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC5 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC5;


PROCEDURE Validate_PARAMC6 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC6                IN   VARCHAR2,
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
          -- IF p_PARAMC6 is not NULL and p_PARAMC6 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC6 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC6;


PROCEDURE Validate_PARAMC7 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC7                IN   VARCHAR2,
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
          -- IF p_PARAMC7 is not NULL and p_PARAMC7 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC7 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC7;


PROCEDURE Validate_PARAMC8 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC8                IN   VARCHAR2,
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
          -- IF p_PARAMC8 is not NULL and p_PARAMC8 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC8 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC8;


PROCEDURE Validate_PARAMC9 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC9                IN   VARCHAR2,
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
          -- IF p_PARAMC9 is not NULL and p_PARAMC9 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC9 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC9;


PROCEDURE Validate_PARAMC10 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMC10                IN   VARCHAR2,
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
          -- IF p_PARAMC10 is not NULL and p_PARAMC10 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMC10 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMC10;


PROCEDURE Validate_PARAMD1 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD1                IN   DATE,
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
          -- IF p_PARAMD1 is not NULL and p_PARAMD1 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD1 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD1;


PROCEDURE Validate_PARAMD2 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD2                IN   DATE,
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
          -- IF p_PARAMD2 is not NULL and p_PARAMD2 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD2 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD2;


PROCEDURE Validate_PARAMD3 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD3                IN   DATE,
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
          -- IF p_PARAMD3 is not NULL and p_PARAMD3 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD3 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD3;


PROCEDURE Validate_PARAMD4 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD4                IN   DATE,
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
          -- IF p_PARAMD4 is not NULL and p_PARAMD4 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD4 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD4;


PROCEDURE Validate_PARAMD5 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD5                IN   DATE,
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
          -- IF p_PARAMD5 is not NULL and p_PARAMD5 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD5 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD5;


PROCEDURE Validate_PARAMD6 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD6                IN   DATE,
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
          -- IF p_PARAMD6 is not NULL and p_PARAMD6 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD6 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD6;


PROCEDURE Validate_PARAMD7 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD7                IN   DATE,
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
          -- IF p_PARAMD7 is not NULL and p_PARAMD7 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD7 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD7;


PROCEDURE Validate_PARAMD8 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD8                IN   DATE,
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
          -- IF p_PARAMD8 is not NULL and p_PARAMD8 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD8 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD8;


PROCEDURE Validate_PARAMD9 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD9                IN   DATE,
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
          -- IF p_PARAMD9 is not NULL and p_PARAMD9 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD9 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD9;


PROCEDURE Validate_PARAMD10 (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARAMD10                IN   DATE,
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
          -- IF p_PARAMD10 is not NULL and p_PARAMD10 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARAMD10 <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARAMD10;

-- travi OBJECT_VERSION_NUMBER validation
PROCEDURE Validate_OBJECT_VERSION_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    P_REPAIR_HISTORY_ID          IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

   l_OBJECT_VERSION_NUMBER NUMBER;

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
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Validate_OBJECT_VERSION_NUMBER in create we get null ovn');
END IF;

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Validate_OBJECT_VERSION_NUMBER ovn '||to_char(p_OBJECT_VERSION_NUMBER));
END IF;


      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN

IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Validate_OBJECT_VERSION_NUMBER in update');
END IF;

IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Validate_OBJECT_VERSION_NUMBER ovn from form '||to_char(p_OBJECT_VERSION_NUMBER));
END IF;


          -- verify if data is valid
        SELECT OBJECT_VERSION_NUMBER
          INTO l_OBJECT_VERSION_NUMBER
          FROM CSD_REPAIR_HISTORY
           WHERE REPAIR_HISTORY_ID = P_REPAIR_HISTORY_ID;

IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Validate_OBJECT_VERSION_NUMBER ovn from db '||to_char(l_OBJECT_VERSION_NUMBER));
END IF;


        if (l_OBJECT_VERSION_NUMBER <> p_OBJECT_VERSION_NUMBER) then
            -- data is not valid
          x_return_status := FND_API.G_RET_STS_ERROR;

IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PVT.Validate_OBJECT_VERSION_NUMBER ovn mismatch error');
END IF;


          end if;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OBJECT_VERSION_NUMBER;



-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = JTF_PLSQL_API.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_REPH_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REPH_Rec     IN    REPH_Rec_Type,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'API_INVALID_RECORD');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REPH_Rec;

PROCEDURE Validate_repair_history(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_REPH_Rec     IN    REPH_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_repair_history';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_REPAIR_HISTORY_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REPAIR_HISTORY_ID   => P_REPH_Rec.REPAIR_HISTORY_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REQUEST_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUEST_ID   => P_REPH_Rec.REQUEST_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REPAIR_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REPAIR_LINE_ID   => P_REPH_Rec.REPAIR_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_EVENT_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_EVENT_CODE   => P_REPH_Rec.EVENT_CODE,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_EVENT_DATE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_EVENT_DATE   => P_REPH_Rec.EVENT_DATE,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_QUANTITY(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_QUANTITY   => P_REPH_Rec.QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN1(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN1   => P_REPH_Rec.PARAMN1,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN2(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN2   => P_REPH_Rec.PARAMN2,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


        Validate_PARAMN3(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN3   => P_REPH_Rec.PARAMN3,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN4(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN4   => P_REPH_Rec.PARAMN4,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN5(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN5   => P_REPH_Rec.PARAMN5,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN6(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN6   => P_REPH_Rec.PARAMN6,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN7(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN7   => P_REPH_Rec.PARAMN7,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN8(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN8   => P_REPH_Rec.PARAMN8,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN9(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN9   => P_REPH_Rec.PARAMN9,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMN10(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMN10   => P_REPH_Rec.PARAMN10,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMC1(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC1   => P_REPH_Rec.PARAMC1,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMC2(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC2   => P_REPH_Rec.PARAMC2,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
/*
          Validate_PARAMC3(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC3   => P_REPH_Rec.PARAMC3,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

*/

          Validate_PARAMC4(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC4   => P_REPH_Rec.PARAMC4,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMC5(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC5   => P_REPH_Rec.PARAMC5,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMC6(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC6   => P_REPH_Rec.PARAMC6,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMC7(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC7   => P_REPH_Rec.PARAMC7,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMC8(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC8   => P_REPH_Rec.PARAMC8,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMC9(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC9   => P_REPH_Rec.PARAMC9,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMC10(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMC10   => P_REPH_Rec.PARAMC10,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD1(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD1   => P_REPH_Rec.PARAMD1,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD2(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD2   => P_REPH_Rec.PARAMD2,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD3(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD3   => P_REPH_Rec.PARAMD3,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD4(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD4   => P_REPH_Rec.PARAMD4,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD5(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD5   => P_REPH_Rec.PARAMD5,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD6(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD6   => P_REPH_Rec.PARAMD6,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD7(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD7   => P_REPH_Rec.PARAMD7,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD8(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD8   => P_REPH_Rec.PARAMD8,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD9(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD9   => P_REPH_Rec.PARAMD9,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARAMD10(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARAMD10   => P_REPH_Rec.PARAMD10,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          -- travi OBJECT_VERSION_NUMBER validation
          Validate_OBJECT_VERSION_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_VERSION_NUMBER  => P_REPH_Rec.OBJECT_VERSION_NUMBER,
              p_REPAIR_HISTORY_ID       => P_REPH_Rec.REPAIR_HISTORY_ID,
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
          Validate_REPH_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_REPH_Rec     =>    P_REPH_Rec,
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
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'end');

END Validate_repair_history;

/*
This function will start with a basic sql query that will get the details of
a repair history row, and then construct the appropriate text using fnd_messages,
the repair history event code, and the parameters stored in the repair history table.
*/
FUNCTION GET_HISTORY_DETAIL(p_repair_history_id IN NUMBER)
       RETURN VARCHAR2
    IS

    -- variables --
    l_repair_detail                 VARCHAR2(2000);
    l_attachments_copied            VARCHAR2(1000);
    l_attachments_not_copied        VARCHAR2(1000);
    l_ref_REPH_rec                  CSD_REPAIR_HISTORY_Pvt.REPH_Rec_Type;
    l_user_name                     VARCHAR2(100);
    l_status_meaning                VARCHAR2(80);


    Cursor c_get_repair_history(p_REPAIR_HISTORY_ID Number) IS
    Select
         REPAIR_HISTORY_ID
        ,REQUEST_ID
        ,PROGRAM_ID
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_UPDATE_DATE
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,REPAIR_LINE_ID
        ,EVENT_CODE
        ,EVENT_DATE
        ,QUANTITY
        ,PARAMN1
        ,PARAMN2
        ,PARAMN3
        ,PARAMN4
        ,PARAMN5
        ,PARAMN6
        ,PARAMN7
        ,PARAMN8
        ,PARAMN9
        ,PARAMN10
        ,PARAMC1
        ,PARAMC2
        ,PARAMC3
        ,PARAMC4
        ,PARAMC5
        ,PARAMC6
        ,PARAMC7
        ,PARAMC8
        ,PARAMC9
        ,PARAMC10
        ,PARAMD1
        ,PARAMD2
        ,PARAMD3
        ,PARAMD4
        ,PARAMD5
        ,PARAMD6
        ,PARAMD7
        ,PARAMD8
        ,PARAMD9
        ,PARAMD10
        ,ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,OBJECT_VERSION_NUMBER
    From  CSD_REPAIR_HISTORY
    where repair_history_id = p_REPAIR_HISTORY_ID;

    Cursor c_get_user_name(p_user_id  number) is
    select user_name
    from fnd_user
    where user_id = p_user_id;

    Cursor c_get_status_meaning(p_status_code VARCHAR2, p_lookup_type VARCHAR2) IS
    select meaning
    from fnd_lookups
    where lookup_type = p_lookup_type
    and lookup_code = p_status_code;

BEGIN

    Open C_Get_repair_history(p_repair_history_id);

    Fetch C_Get_repair_history into
            l_ref_REPH_rec.REPAIR_HISTORY_ID     ,
            l_ref_REPH_rec.REQUEST_ID            ,
            l_ref_REPH_rec.PROGRAM_ID            ,
            l_ref_REPH_rec.PROGRAM_APPLICATION_ID,
            l_ref_REPH_rec.PROGRAM_UPDATE_DATE   ,
            l_ref_REPH_rec.CREATED_BY            ,
            l_ref_REPH_rec.CREATION_DATE         ,
            l_ref_REPH_rec.LAST_UPDATED_BY       ,
            l_ref_REPH_rec.LAST_UPDATE_DATE      ,
            l_ref_REPH_rec.LAST_UPDATE_LOGIN     ,
            l_ref_REPH_rec.REPAIR_LINE_ID        ,
            l_ref_REPH_rec.EVENT_CODE            ,
            l_ref_REPH_rec.EVENT_DATE            ,
            l_ref_REPH_rec.QUANTITY              ,
            l_ref_REPH_rec.PARAMN1               ,
            l_ref_REPH_rec.PARAMN2               ,
            l_ref_REPH_rec.PARAMN3               ,
            l_ref_REPH_rec.PARAMN4               ,
            l_ref_REPH_rec.PARAMN5               ,
            l_ref_REPH_rec.PARAMN6               ,
            l_ref_REPH_rec.PARAMN7               ,
            l_ref_REPH_rec.PARAMN8               ,
            l_ref_REPH_rec.PARAMN9               ,
            l_ref_REPH_rec.PARAMN10              ,
            l_ref_REPH_rec.PARAMC1               ,
            l_ref_REPH_rec.PARAMC2               ,
            l_ref_REPH_rec.PARAMC3               ,
            l_ref_REPH_rec.PARAMC4               ,
            l_ref_REPH_rec.PARAMC5               ,
            l_ref_REPH_rec.PARAMC6               ,
            l_ref_REPH_rec.PARAMC7               ,
            l_ref_REPH_rec.PARAMC8               ,
            l_ref_REPH_rec.PARAMC9               ,
            l_ref_REPH_rec.PARAMC10              ,
            l_ref_REPH_rec.PARAMD1               ,
            l_ref_REPH_rec.PARAMD2               ,
            l_ref_REPH_rec.PARAMD3               ,
            l_ref_REPH_rec.PARAMD4               ,
            l_ref_REPH_rec.PARAMD5               ,
            l_ref_REPH_rec.PARAMD6               ,
            l_ref_REPH_rec.PARAMD7               ,
            l_ref_REPH_rec.PARAMD8               ,
            l_ref_REPH_rec.PARAMD9               ,
            l_ref_REPH_rec.PARAMD10              ,
            l_ref_REPH_rec.ATTRIBUTE_CATEGORY    ,
            l_ref_REPH_rec.ATTRIBUTE1            ,
            l_ref_REPH_rec.ATTRIBUTE2            ,
            l_ref_REPH_rec.ATTRIBUTE3            ,
            l_ref_REPH_rec.ATTRIBUTE4            ,
            l_ref_REPH_rec.ATTRIBUTE5            ,
            l_ref_REPH_rec.ATTRIBUTE6            ,
            l_ref_REPH_rec.ATTRIBUTE7            ,
            l_ref_REPH_rec.ATTRIBUTE8            ,
            l_ref_REPH_rec.ATTRIBUTE9            ,
            l_ref_REPH_rec.ATTRIBUTE10           ,
            l_ref_REPH_rec.ATTRIBUTE11           ,
            l_ref_REPH_rec.ATTRIBUTE12           ,
            l_ref_REPH_rec.ATTRIBUTE13           ,
            l_ref_REPH_rec.ATTRIBUTE14           ,
            l_ref_REPH_rec.ATTRIBUTE15           ,
            l_ref_REPH_rec.OBJECT_VERSION_NUMBER ;

    If ( C_Get_repair_history%NOTFOUND) Then
       return null;
    END IF;
    Close     C_Get_repair_history;


    --get user name
    Open c_get_user_name(l_ref_REPH_rec.CREATED_BY);
    FETCH c_get_user_name into l_user_name;
    Close  c_get_user_name;

    --This is a special case for attachment message details on Repair Order Split
    if (l_ref_REPH_rec.event_code = 'SLT') then
        -- standard naming in fnd_new_messages for Attachments message
        --ATTACHMENTS_PARAMC2 based on paramc2 value:'Y' => 'Attachments Copied
        --'else 'Attachments Not Copied'
        fnd_message.set_name('CSD','CSD_ATTACHMENTS_COPIED');
        l_attachments_copied := FND_MESSAGE.GET;
        fnd_message.set_name('CSD','CSD_ATTACHMENTS_NOT_COPIED');
        l_attachments_not_copied := FND_MESSAGE.GET;
    end if;


    -- standard naming in fnd_new_messages for activity details
    fnd_message.set_name('CSD','CSD_ACTIVITY_DETAIL_' || l_ref_REPH_rec.EVENT_CODE);

    -- set the tokens for each respective event --

    --RMA Received
    if (l_ref_REPH_rec.event_code = 'RR') then
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('QUANTITY' , l_ref_REPH_rec.QUANTITY );
	      FND_MESSAGE.SET_TOKEN('CREATED_BY' , l_user_name);
    --Repair Job Completed
    elsif (l_ref_REPH_rec.event_code = 'JC') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('QUANTITY' , l_ref_REPH_rec.QUANTITY );

         --Only show PARAMN5 if PARAMN6 > 1
         if (l_ref_REPH_rec.PARAMN6 > 1) then
	         FND_MESSAGE.SET_TOKEN('QTY_PARAMN5_6' , l_ref_REPH_rec.PARAMN5 );
         else
            FND_MESSAGE.SET_TOKEN('QTY_PARAMN5_6' , l_ref_REPH_rec.PARAMN6 );
         end if;

    --Shipment
    elsif (l_ref_REPH_rec.event_code = 'PS') then
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMC4' , l_ref_REPH_rec.PARAMC4 );
	      FND_MESSAGE.SET_TOKEN('QUANTITY' , l_ref_REPH_rec.QUANTITY );
	      FND_MESSAGE.SET_TOKEN('CREATED_BY' , l_user_name );
    --Status Changed
    elsif (l_ref_REPH_rec.event_code = 'SC') then

         --get flow status meaning
         Open c_get_status_meaning(l_ref_REPH_rec.PARAMC2, 'CSD_REPAIR_FLOW_STATUS' );
         FETCH c_get_status_meaning into l_status_meaning;
         Close c_get_status_meaning;
	      FND_MESSAGE.SET_TOKEN('OLD_STATUS_PARAMC2' , l_status_meaning );

         --get flow status meaning
         Open c_get_status_meaning(l_ref_REPH_rec.PARAMC1, 'CSD_REPAIR_FLOW_STATUS');
         FETCH c_get_status_meaning into l_status_meaning;
         Close c_get_status_meaning;
	      FND_MESSAGE.SET_TOKEN('NEW_STATUS_PARAMC1' , l_status_meaning );

	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('CREATED_BY' , l_user_name );
    --WIP Job Created
    elsif (l_ref_REPH_rec.event_code = 'JS') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('QUANTITY' , l_ref_REPH_rec.QUANTITY );
	      FND_MESSAGE.SET_TOKEN('PARAMN5' , l_ref_REPH_rec.PARAMN5 );
	      FND_MESSAGE.SET_TOKEN('PARAMC5' , l_ref_REPH_rec.PARAMC5 );
    --RMA Serial Number Changed
    elsif (l_ref_REPH_rec.event_code = 'RSC') then
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMC4' , l_ref_REPH_rec.PARAMC4 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMN2' , l_ref_REPH_rec.PARAMN2 );
    --Shipment Serial Number Changed
    elsif (l_ref_REPH_rec.event_code = 'SSC') then
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMC4' , l_ref_REPH_rec.PARAMC4 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
   --Inspection Performed
   elsif (l_ref_REPH_rec.event_code = 'IP') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMN3' , l_ref_REPH_rec.PARAMN3 );
	      FND_MESSAGE.SET_TOKEN('PARAMN4' , l_ref_REPH_rec.PARAMN4 );
   --Repair Order Split
   elsif (l_ref_REPH_rec.event_code = 'SLT') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMN1' , l_ref_REPH_rec.PARAMN1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );

         --ATTACHMENTS_PARAMC2 based on paramc2 value:'Y' => 'Attachments Copied'
         --else 'Attachments Not Copied'
         if (l_ref_REPH_rec.PARAMC2 = 'Y') then
	         FND_MESSAGE.SET_TOKEN('ATTACHMENTS_PARAMC2' , l_attachments_copied );
         else
            FND_MESSAGE.SET_TOKEN('ATTACHMENTS_PARAMC2' , l_attachments_not_copied );
         end if;

   --Estimate Status Updated
   elsif (l_ref_REPH_rec.event_code = 'ESU') then
         --get status meaning
         Open c_get_status_meaning(l_ref_REPH_rec.PARAMC2, 'CSD_APPROVAL_STATUS');
         FETCH c_get_status_meaning into l_status_meaning;
         Close c_get_status_meaning;
	      FND_MESSAGE.SET_TOKEN('OLD_STATUS_PARAMC2' , l_status_meaning );

         --get status meaning
         Open c_get_status_meaning(l_ref_REPH_rec.PARAMC1, 'CSD_APPROVAL_STATUS');
         FETCH c_get_status_meaning into l_status_meaning;
         Close c_get_status_meaning;
	      FND_MESSAGE.SET_TOKEN('NEW_STATUS_PARAMC1' , l_status_meaning );

	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMN2' , l_ref_REPH_rec.PARAMN2 );
	      FND_MESSAGE.SET_TOKEN('CREATED_BY' , l_user_name );
   --Charges Manually Updated for RO
   elsif (l_ref_REPH_rec.event_code = 'CM') then
	      FND_MESSAGE.SET_TOKEN('CREATED_BY' , l_user_name );
   --Default Contract Updated
   elsif (l_ref_REPH_rec.event_code = 'CONU') then
	      FND_MESSAGE.SET_TOKEN('PARAMC10' , l_ref_REPH_rec.PARAMC10 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('CREATED_BY' , l_user_name );
   --Job Submitted
   elsif (l_ref_REPH_rec.event_code = 'JSU') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('QUANTITY' , l_ref_REPH_rec.QUANTITY );
	      FND_MESSAGE.SET_TOKEN('PARAMN5' , l_ref_REPH_rec.PARAMN5 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMN6' , l_ref_REPH_rec.PARAMN6 );
	      FND_MESSAGE.SET_TOKEN('PARAMN7' , l_ref_REPH_rec.PARAMN7 );
   --Job Completed Alert
   elsif (l_ref_REPH_rec.event_code = 'JCA') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
   --Sales Order Received
   elsif (l_ref_REPH_rec.event_code = 'RRI') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMC4' , l_ref_REPH_rec.PARAMC4 );
	      FND_MESSAGE.SET_TOKEN('QUANTITY' , l_ref_REPH_rec.QUANTITY );
   --Sales Order Completed
   elsif (l_ref_REPH_rec.event_code = 'PSI') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMC4' , l_ref_REPH_rec.PARAMC4 );
	      FND_MESSAGE.SET_TOKEN('PARAMC5' , l_ref_REPH_rec.PARAMC5 );
	      FND_MESSAGE.SET_TOKEN('PARAMC6' , l_ref_REPH_rec.PARAMC6 );
   --Repair Order Owner Updated
   elsif (l_ref_REPH_rec.event_code = 'DROC') then
        fnd_message.set_token('PARAMC1',l_ref_REPH_rec.PARAMC1);
        fnd_message.set_token('PARAMC2',l_ref_REPH_rec.PARAMC2);
        fnd_message.set_token('CREATED_BY',l_user_name);
   --Service Request Status Updated
   elsif (l_ref_REPH_rec.event_code = 'SRU') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMC4' , l_ref_REPH_rec.PARAMC4 );
	      FND_MESSAGE.SET_TOKEN('CREATED_BY' , l_user_name );
   --RO Type Updated
   elsif (l_ref_REPH_rec.event_code = 'RTU') then
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMC4' , l_ref_REPH_rec.PARAMC4 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
	      FND_MESSAGE.SET_TOKEN('CREATED_BY' , l_user_name );
   --Repair Order Alert
   elsif (l_ref_REPH_rec.event_code = 'OA') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC2' , l_ref_REPH_rec.PARAMC2 );
   --Task Created
   elsif (l_ref_REPH_rec.event_code = 'TC') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC7' , l_ref_REPH_rec.PARAMC7 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
	      FND_MESSAGE.SET_TOKEN('PARAMC5' , l_ref_REPH_rec.PARAMC5 );
	      FND_MESSAGE.SET_TOKEN('PARAMC6' , l_ref_REPH_rec.PARAMC6 );
   --Task Owner Updated
   elsif (l_ref_REPH_rec.event_code = 'TOC') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC7' , l_ref_REPH_rec.PARAMC7 );
	      FND_MESSAGE.SET_TOKEN('PARAMC9' , l_ref_REPH_rec.PARAMC9 );
	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
   --Task Status Updated
   elsif (l_ref_REPH_rec.event_code = 'TSC') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC7' , l_ref_REPH_rec.PARAMC7 );
	      FND_MESSAGE.SET_TOKEN('PARAMC8' , l_ref_REPH_rec.PARAMC8 );
	      FND_MESSAGE.SET_TOKEN('PARAMC6' , l_ref_REPH_rec.PARAMC6 );
   --Task Assignee Updated
   elsif (l_ref_REPH_rec.event_code = 'TAC') then
	      FND_MESSAGE.SET_TOKEN('PARAMC1' , l_ref_REPH_rec.PARAMC1 );
	      FND_MESSAGE.SET_TOKEN('PARAMC7' , l_ref_REPH_rec.PARAMC7 );
	      FND_MESSAGE.SET_TOKEN('PARAMC9' , l_ref_REPH_rec.PARAMC9 );
	      FND_MESSAGE.SET_TOKEN('PARAMC5' , l_ref_REPH_rec.PARAMC5 );
   --Customer Approved
   elsif (l_ref_REPH_rec.event_code = 'A') then
         --get status meaning
         Open c_get_status_meaning(l_ref_REPH_rec.PARAMC2, 'CSD_APPROVAL_STATUS');
         FETCH c_get_status_meaning into l_status_meaning;
         Close c_get_status_meaning;
	      FND_MESSAGE.SET_TOKEN('OLD_STATUS_PARAMC2' , l_ref_REPH_rec.PARAMC2 );

         --get flow status meaning
         Open c_get_status_meaning(l_ref_REPH_rec.PARAMC1,'CSD_APPROVAL_STATUS' );
         FETCH c_get_status_meaning into l_status_meaning;
         Close c_get_status_meaning;
	      FND_MESSAGE.SET_TOKEN('NEW_STATUS_PARAMC1' , l_ref_REPH_rec.PARAMC1 );

	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
   --Customer Rejected
   elsif (l_ref_REPH_rec.event_code = 'R') then

         --get status meaning
         Open c_get_status_meaning(l_ref_REPH_rec.PARAMC2, 'CSD_APPROVAL_STATUS');
         FETCH c_get_status_meaning into l_status_meaning;
         Close c_get_status_meaning;
	      FND_MESSAGE.SET_TOKEN('OLD_STATUS_PARAMC2' , l_status_meaning );

         --get flow status meaning
         Open c_get_status_meaning(l_ref_REPH_rec.PARAMC1,'CSD_APPROVAL_STATUS' );
         FETCH c_get_status_meaning into l_status_meaning;
         Close c_get_status_meaning;
	      FND_MESSAGE.SET_TOKEN('NEW_STATUS_PARAMC1' , l_status_meaning);

	      FND_MESSAGE.SET_TOKEN('PARAMC3' , l_ref_REPH_rec.PARAMC3 );
    end if;


    -- get the message string and return it  --
    l_repair_detail := FND_MESSAGE.GET;
    return l_repair_detail;

END GET_HISTORY_DETAIL;



End CSD_REPAIR_HISTORY_PVT;

/
