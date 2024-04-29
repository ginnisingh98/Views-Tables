--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_JOB_XREF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_JOB_XREF_PVT" as
/* $Header: csdvdrjb.pls 115.13 2003/09/15 21:34:28 sragunat ship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_JOB_XREF_PVT
-- Purpose          :
-- History          : Added Inventory_Item_ID and Item_Revison Columns -- travi
-- History          : 01/17/2002, TRAVI added column OBJECT_VERSION_NUMBER
-- History          : 08/20/2003, Shiv Ragunathan, 11.5.10 Changes: Made
-- History          :   Changes to procedure Create_repjobxref to process
-- History          :   source_type_code, source_id1, ro_service_code_id
-- History          :   and job_name.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_REPAIR_JOB_XREF_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvrjxb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;
-- Hint: Primary key needs to be returned.
PROCEDURE CREATE_REPJOBXREF(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REPJOBXREF_Rec     IN    REPJOBXREF_Rec_Type  := G_MISS_REPJOBXREF_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_REPAIR_JOB_XREF_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_REPJOBXREF';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_REPJOBXREF_PVT;

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
          AS_CALLOUT_PKG.Create_repjobxref_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_REPJOBXREF_Rec      =>  P_REPJOBXREF_Rec,
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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Validate_repjobxref');

          -- Invoke validation procedures
          Validate_repjobxref(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_CREATE,
              P_REPJOBXREF_Rec  =>  P_REPJOBXREF_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Calling create table handler');

      -- Invoke table handler(CSD_REPAIR_JOB_XREF_PKG.Insert_Row)
      CSD_REPAIR_JOB_XREF_PKG.Insert_Row(
          px_REPAIR_JOB_XREF_ID  => x_REPAIR_JOB_XREF_ID,
          p_CREATED_BY  => G_USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REPAIR_LINE_ID  => p_REPJOBXREF_rec.REPAIR_LINE_ID,
          p_WIP_ENTITY_ID  => p_REPJOBXREF_rec.WIP_ENTITY_ID,
          p_GROUP_ID  => p_REPJOBXREF_rec.GROUP_ID,
          p_ORGANIZATION_ID  => p_REPJOBXREF_rec.ORGANIZATION_ID,
          p_QUANTITY  => p_REPJOBXREF_rec.QUANTITY,
          p_INVENTORY_ITEM_ID => p_REPJOBXREF_rec.INVENTORY_ITEM_ID,
          p_ITEM_REVISION  => p_REPJOBXREF_rec.ITEM_REVISION,
          p_SOURCE_TYPE_CODE => p_REPJOBXREF_rec.SOURCE_TYPE_CODE,
          p_SOURCE_ID1       => p_REPJOBXREF_rec.SOURCE_ID1,
          p_RO_SERVICE_CODE_ID => p_REPJOBXREF_rec.RO_SERVICE_CODE_ID,
          p_JOB_NAME       =>  p_REPJOBXREF_rec.JOB_NAME,
          p_OBJECT_VERSION_NUMBER => p_REPJOBXREF_rec.OBJECT_VERSION_NUMBER,
          p_ATTRIBUTE_CATEGORY  => p_REPJOBXREF_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_REPJOBXREF_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_REPJOBXREF_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_REPJOBXREF_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_REPJOBXREF_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_REPJOBXREF_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_REPJOBXREF_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_REPJOBXREF_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_REPJOBXREF_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_REPJOBXREF_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_REPJOBXREF_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_REPJOBXREF_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_REPJOBXREF_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_REPJOBXREF_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_REPJOBXREF_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_REPJOBXREF_rec.ATTRIBUTE15,
        p_QUANTITY_COMPLETED => p_REPJOBXREF_rec.QUANTITY_COMPLETED);
      -- Hint: Primary key should be returned.
      -- x_REPAIR_JOB_XREF_ID := px_REPAIR_JOB_XREF_ID;

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
          AS_CALLOUT_PKG.Create_repjobxref_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_REPJOBXREF_Rec      =>  P_REPJOBXREF_Rec,
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
--             RAISE;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--             RAISE;

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--             RAISE;
End Create_repjobxref;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_repjobxref(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REPJOBXREF_Rec     IN    REPJOBXREF_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_repjobxref(REPAIR_JOB_XREF_ID Number) IS
    Select rowid,
           REPAIR_JOB_XREF_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REPAIR_LINE_ID,
           WIP_ENTITY_ID,
           GROUP_ID,
           ORGANIZATION_ID,
           QUANTITY,
         INVENTORY_ITEM_ID,
         ITEM_REVISION,
         OBJECT_VERSION_NUMBER,
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
         QUANTITY_COMPLETED
    From  CSD_REPAIR_JOB_XREF
    -- Hint: Developer need to provide Where clause
    For Update OBJECT_VERSION_NUMBER NOWAIT;
    -- travi added the OBJECT_VERSION_NUMBER to above line
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_repjobxref';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_REPJOBXREF_rec  CSD_repair_job_xref_PVT.REPJOBXREF_Rec_Type;
l_tar_REPJOBXREF_rec  CSD_repair_job_xref_PVT.REPJOBXREF_Rec_Type := P_REPJOBXREF_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_REPJOBXREF_PVT;

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
          AS_CALLOUT_PKG.Update_repjobxref_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_REPJOBXREF_Rec      =>  P_REPJOBXREF_Rec,
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
      Open C_Get_repjobxref( l_tar_REPJOBXREF_rec.REPAIR_JOB_XREF_ID);

     -- travi changes
      Fetch C_Get_repjobxref into
               l_rowid,
               l_ref_REPJOBXREF_rec.REPAIR_JOB_XREF_ID,
               l_ref_REPJOBXREF_rec.CREATED_BY,
               l_ref_REPJOBXREF_rec.CREATION_DATE,
               l_ref_REPJOBXREF_rec.LAST_UPDATED_BY,
               l_ref_REPJOBXREF_rec.LAST_UPDATE_DATE,
               l_ref_REPJOBXREF_rec.LAST_UPDATE_LOGIN,
               l_ref_REPJOBXREF_rec.REPAIR_LINE_ID,
               l_ref_REPJOBXREF_rec.WIP_ENTITY_ID,
               l_ref_REPJOBXREF_rec.GROUP_ID,
               l_ref_REPJOBXREF_rec.ORGANIZATION_ID,
               l_ref_REPJOBXREF_rec.QUANTITY,
             l_ref_REPJOBXREF_rec.INVENTORY_ITEM_ID,
             l_ref_REPJOBXREF_rec.ITEM_REVISION,
             l_ref_REPJOBXREF_rec.OBJECT_VERSION_NUMBER,
               l_ref_REPJOBXREF_rec.ATTRIBUTE_CATEGORY,
               l_ref_REPJOBXREF_rec.ATTRIBUTE1,
               l_ref_REPJOBXREF_rec.ATTRIBUTE2,
               l_ref_REPJOBXREF_rec.ATTRIBUTE3,
               l_ref_REPJOBXREF_rec.ATTRIBUTE4,
               l_ref_REPJOBXREF_rec.ATTRIBUTE5,
               l_ref_REPJOBXREF_rec.ATTRIBUTE6,
               l_ref_REPJOBXREF_rec.ATTRIBUTE7,
               l_ref_REPJOBXREF_rec.ATTRIBUTE8,
               l_ref_REPJOBXREF_rec.ATTRIBUTE9,
               l_ref_REPJOBXREF_rec.ATTRIBUTE10,
               l_ref_REPJOBXREF_rec.ATTRIBUTE11,
               l_ref_REPJOBXREF_rec.ATTRIBUTE12,
               l_ref_REPJOBXREF_rec.ATTRIBUTE13,
               l_ref_REPJOBXREF_rec.ATTRIBUTE14,
               l_ref_REPJOBXREF_rec.ATTRIBUTE15,
            l_ref_REPJOBXREF_rec.QUANTITY_COMPLETED;

       If ( C_Get_repjobxref%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('CSD', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'repjobxref', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: - Close Cursor');
       Close     C_Get_repjobxref;
*/


      If (l_tar_REPJOBXREF_rec.last_update_date is NULL or
          l_tar_REPJOBXREF_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSD', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_REPJOBXREF_rec.last_update_date <> l_ref_REPJOBXREF_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('CSD', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'repjobxref', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Validate_repjobxref');

          -- Invoke validation procedures
          Validate_repjobxref(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => JTF_PLSQL_API.G_UPDATE,
              P_REPJOBXREF_Rec  =>  P_REPJOBXREF_Rec,
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

     -- travi changes
      -- Invoke table handler(CSD_REPAIR_JOB_XREF_PKG.Update_Row)
      CSD_REPAIR_JOB_XREF_PKG.Update_Row(
          p_REPAIR_JOB_XREF_ID  => p_REPJOBXREF_rec.REPAIR_JOB_XREF_ID,
          p_CREATED_BY  => G_USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REPAIR_LINE_ID  => p_REPJOBXREF_rec.REPAIR_LINE_ID,
          p_WIP_ENTITY_ID  => p_REPJOBXREF_rec.WIP_ENTITY_ID,
          p_GROUP_ID  => p_REPJOBXREF_rec.GROUP_ID,
          p_ORGANIZATION_ID  => p_REPJOBXREF_rec.ORGANIZATION_ID,
          p_QUANTITY  => p_REPJOBXREF_rec.QUANTITY,
          p_INVENTORY_ITEM_ID  => p_REPJOBXREF_rec.INVENTORY_ITEM_ID,
          p_ITEM_REVISION  => p_REPJOBXREF_rec.ITEM_REVISION,
          p_OBJECT_VERSION_NUMBER  => p_REPJOBXREF_rec.OBJECT_VERSION_NUMBER,
          p_ATTRIBUTE_CATEGORY  => p_REPJOBXREF_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => p_REPJOBXREF_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => p_REPJOBXREF_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => p_REPJOBXREF_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => p_REPJOBXREF_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => p_REPJOBXREF_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => p_REPJOBXREF_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => p_REPJOBXREF_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => p_REPJOBXREF_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => p_REPJOBXREF_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => p_REPJOBXREF_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => p_REPJOBXREF_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => p_REPJOBXREF_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => p_REPJOBXREF_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => p_REPJOBXREF_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => p_REPJOBXREF_rec.ATTRIBUTE15,
        p_QUANTITY_COMPLETED => p_REPJOBXREF_rec.QUANTITY_COMPLETED);
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
          AS_CALLOUT_PKG.Update_repjobxref_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_REPJOBXREF_Rec      =>  P_REPJOBXREF_Rec,
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
--             RAISE;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--             RAISE;

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--             RAISE;
End Update_repjobxref;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_repjobxref(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_REPJOBXREF_Rec     IN REPJOBXREF_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_repjobxref';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_REPJOBXREF_PVT;

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
          AS_CALLOUT_PKG.Delete_repjobxref_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_REPJOBXREF_Rec      =>  P_REPJOBXREF_Rec,
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

      -- Invoke table handler(CSD_REPAIR_JOB_XREF_PKG.Delete_Row)
      CSD_REPAIR_JOB_XREF_PKG.Delete_Row(
          p_REPAIR_JOB_XREF_ID  => p_REPJOBXREF_rec.REPAIR_JOB_XREF_ID);
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
          AS_CALLOUT_PKG.Delete_repjobxref_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_REPJOBXREF_Rec      =>  P_REPJOBXREF_Rec,
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
--             RAISE;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--             RAISE;

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--             RAISE;
End Delete_repjobxref;


-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_REPJOBXREF_Rec   IN  REPJOBXREF_Rec_Type,
    p_cur_get_REPJOBXREF   IN   NUMBER
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Define Columns Begins');

     -- travi changes
      -- define all columns for CSD_REPAIR_JOB_XREF_V view
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 1, P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 2, P_REPJOBXREF_Rec.REPAIR_LINE_ID);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 3, P_REPJOBXREF_Rec.WIP_ENTITY_ID);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 4, P_REPJOBXREF_Rec.GROUP_ID);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 5, P_REPJOBXREF_Rec.ORGANIZATION_ID);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 6, P_REPJOBXREF_Rec.QUANTITY);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 7, P_REPJOBXREF_Rec.INVENTORY_ITEM_ID);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 8, P_REPJOBXREF_Rec.ITEM_REVISION, 3);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 9, P_REPJOBXREF_Rec.OBJECT_VERSION_NUMBER);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 10, P_REPJOBXREF_Rec.ATTRIBUTE_CATEGORY, 30);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 11, P_REPJOBXREF_Rec.ATTRIBUTE1, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 12, P_REPJOBXREF_Rec.ATTRIBUTE2, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 13, P_REPJOBXREF_Rec.ATTRIBUTE3, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 14, P_REPJOBXREF_Rec.ATTRIBUTE4, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 15, P_REPJOBXREF_Rec.ATTRIBUTE5, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 16, P_REPJOBXREF_Rec.ATTRIBUTE6, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 17, P_REPJOBXREF_Rec.ATTRIBUTE7, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 18, P_REPJOBXREF_Rec.ATTRIBUTE8, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 19, P_REPJOBXREF_Rec.ATTRIBUTE9, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 20, P_REPJOBXREF_Rec.ATTRIBUTE10, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 21, P_REPJOBXREF_Rec.ATTRIBUTE11, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 22, P_REPJOBXREF_Rec.ATTRIBUTE12, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 23, P_REPJOBXREF_Rec.ATTRIBUTE13, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 24, P_REPJOBXREF_Rec.ATTRIBUTE14, 150);
      dbms_sql.define_column(p_cur_get_REPJOBXREF, 25, P_REPJOBXREF_Rec.ATTRIBUTE15, 150);

    dbms_sql.define_column(p_cur_get_REPJOBXREF, 26, P_REPJOBXREF_Rec.QUANTITY_COMPLETED);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Define Columns Ends');
END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_REPJOBXREF   IN   NUMBER,
    X_REPJOBXREF_Rec   OUT NOCOPY  REPJOBXREF_Rec_Type
)
IS
BEGIN
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Get Column Values Begins');

     -- travi changes
      -- get all column values for CSD_REPAIR_JOB_XREF_V table
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 1, X_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 2, X_REPJOBXREF_Rec.REPAIR_LINE_ID);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 3, X_REPJOBXREF_Rec.WIP_ENTITY_ID);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 4, X_REPJOBXREF_Rec.GROUP_ID);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 5, X_REPJOBXREF_Rec.ORGANIZATION_ID);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 6, X_REPJOBXREF_Rec.QUANTITY);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 7, X_REPJOBXREF_Rec.INVENTORY_ITEM_ID);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 8, X_REPJOBXREF_Rec.ITEM_REVISION);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 9, X_REPJOBXREF_Rec.OBJECT_VERSION_NUMBER);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 10, X_REPJOBXREF_Rec.ATTRIBUTE_CATEGORY);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 11, X_REPJOBXREF_Rec.ATTRIBUTE1);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 12, X_REPJOBXREF_Rec.ATTRIBUTE2);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 13, X_REPJOBXREF_Rec.ATTRIBUTE3);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 14, X_REPJOBXREF_Rec.ATTRIBUTE4);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 15, X_REPJOBXREF_Rec.ATTRIBUTE5);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 16, X_REPJOBXREF_Rec.ATTRIBUTE6);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 17, X_REPJOBXREF_Rec.ATTRIBUTE7);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 18, X_REPJOBXREF_Rec.ATTRIBUTE8);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 19, X_REPJOBXREF_Rec.ATTRIBUTE9);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 20, X_REPJOBXREF_Rec.ATTRIBUTE10);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 21, X_REPJOBXREF_Rec.ATTRIBUTE11);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 22, X_REPJOBXREF_Rec.ATTRIBUTE12);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 23, X_REPJOBXREF_Rec.ATTRIBUTE13);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 24, X_REPJOBXREF_Rec.ATTRIBUTE14);
      dbms_sql.column_value(p_cur_get_REPJOBXREF, 25, X_REPJOBXREF_Rec.ATTRIBUTE15);

      dbms_sql.column_value(p_cur_get_REPJOBXREF, 26, X_REPJOBXREF_Rec.QUANTITY_COMPLETED);

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Get Column Values Ends');
END Get_Column_Values;

PROCEDURE Gen_REPJOBXREF_order_cl(
    p_order_by_rec   IN   REPJOBXREF_sort_rec_type,
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
END Gen_REPJOBXREF_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_REPJOBXREF_Rec   IN   REPJOBXREF_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_REPJOBXREF   IN   NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Bind Variables Begins');

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID IS NOT NULL) AND (P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID <> FND_API.G_MISS_NUM) )
      THEN
          DBMS_SQL.BIND_VARIABLE(p_cur_get_REPJOBXREF, ':p_REPAIR_JOB_XREF_ID', P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID);
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

     -- travi changes
      x_select_cl := 'Select ' ||
                'CSD_REPAIR_JOB_XREF_V.REPAIR_JOB_XREF_ID,' ||
                'CSD_REPAIR_JOB_XREF_V.CREATED_BY,' ||
                'CSD_REPAIR_JOB_XREF_V.CREATION_DATE,' ||
                'CSD_REPAIR_JOB_XREF_V.LAST_UPDATED_BY,' ||
                'CSD_REPAIR_JOB_XREF_V.LAST_UPDATE_DATE,' ||
                'CSD_REPAIR_JOB_XREF_V.LAST_UPDATE_LOGIN,' ||
                'CSD_REPAIR_JOB_XREF_V.REPAIR_LINE_ID,' ||
                'CSD_REPAIR_JOB_XREF_V.WIP_ENTITY_ID,' ||
                'CSD_REPAIR_JOB_XREF_V.GROUP_ID,' ||
                'CSD_REPAIR_JOB_XREF_V.ORGANIZATION_ID,' ||
                'CSD_REPAIR_JOB_XREF_V.QUANTITY,' ||
                'CSD_REPAIR_JOB_XREF_V.INVENTORY_ITEM_ID,' ||
                'CSD_REPAIR_JOB_XREF_V.ITEM_REVISION,' ||
                'CSD_REPAIR_JOB_XREF_V.OBJECT_VERSION_NUMBER,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE_CATEGORY,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE1,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE2,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE3,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE4,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE5,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE6,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE7,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE8,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE9,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE10,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE11,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE12,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE13,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE14,' ||
                'CSD_REPAIR_JOB_XREF_V.ATTRIBUTE15,' ||
                'CSD_REPAIR_JOB_XREF_V.QUANTITY_COMPLETED,' ||
                'from CSD_REPAIR_JOB_XREF_V';
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generate Select Ends');

END Gen_Select;

PROCEDURE Gen_REPJOBXREF_Where(
    P_REPJOBXREF_Rec     IN   REPJOBXREF_Rec_Type,
    x_REPJOBXREF_where   OUT NOCOPY   VARCHAR2
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
      IF( (P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID IS NOT NULL) AND (P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID <> FND_API.G_MISS_NUM) )
      THEN
          IF(x_REPJOBXREF_where IS NULL) THEN
              x_REPJOBXREF_where := 'Where';
          ELSE
              x_REPJOBXREF_where := x_REPJOBXREF_where || ' AND ';
          END IF;
          x_REPJOBXREF_where := x_REPJOBXREF_where || 'P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID = :p_REPAIR_JOB_XREF_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_REPJOBXREF_Rec.CREATION_DATE IS NOT NULL) AND (P_REPJOBXREF_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_REPJOBXREF_Rec.CREATION_DATE);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_REPJOBXREF_Rec.CREATION_DATE);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_REPJOBXREF_where IS NULL) THEN
              x_REPJOBXREF_where := 'Where ';
          ELSE
              x_REPJOBXREF_where := x_REPJOBXREF_where || ' AND ';
          END IF;
          x_REPJOBXREF_where := x_REPJOBXREF_where || 'P_REPJOBXREF_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_REPJOBXREF_Rec.ATTRIBUTE_CATEGORY IS NOT NULL) AND (P_REPJOBXREF_Rec.ATTRIBUTE_CATEGORY <> FND_API.G_MISS_CHAR) )
      THEN
          -- check if item value contains '%' wildcard
          OPEN c_chk_str1(P_REPJOBXREF_Rec.ATTRIBUTE_CATEGORY);
          FETCH c_chk_str1 INTO str_csr1;
          CLOSE c_chk_str1;

          IF(str_csr1 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          -- check if item value contains '_' wildcard
          OPEN c_chk_str2(P_REPJOBXREF_Rec.ATTRIBUTE_CATEGORY);
          FETCH c_chk_str2 INTO str_csr2;
          CLOSE c_chk_str2;

          IF(str_csr2 <> 0) THEN
              l_operator := ' LIKE ';
          ELSE
              l_operator := ' = ';
          END IF;

          IF(x_REPJOBXREF_where IS NULL) THEN
              x_REPJOBXREF_where := 'Where ';
          ELSE
              x_REPJOBXREF_where := x_REPJOBXREF_where || ' AND ';
          END IF;
          x_REPJOBXREF_where := x_REPJOBXREF_where || 'P_REPJOBXREF_Rec.ATTRIBUTE_CATEGORY ' || l_operator || ' :p_ATTRIBUTE_CATEGORY';
      END IF;

      -- Add more IF statements for each column below

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Generate Where Ends');

END Gen_REPJOBXREF_Where;

PROCEDURE Get_repjobxref(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    P_REPJOBXREF_Rec     IN    REPJOBXREF_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   REPJOBXREF_sort_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    X_REPJOBXREF_Tbl  OUT NOCOPY  REPJOBXREF_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY  NUMBER,
    x_next_rec_ptr               OUT NOCOPY  NUMBER,
    x_tot_rec_count              OUT NOCOPY  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY  NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Get_repjobxref';
l_api_version_number      CONSTANT NUMBER   := 2.0;

-- Local identity variables
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

-- Local record counters
l_returned_rec_count     NUMBER := 0; -- number of records returned in x_X_REPJOBXREF_Rec
l_next_record_ptr        NUMBER := 1;
l_ignore                 NUMBER;

-- total number of records accessable by caller
l_tot_rec_count          NUMBER := 0;
l_tot_rec_amount         NUMBER := 0;

-- Status local variables
l_return_status          VARCHAR2(1); -- Return value from procedures
l_return_status_full     VARCHAR2(1); -- Calculated return status from

-- Dynamic SQL statement elements
l_cur_get_REPJOBXREF           NUMBER;
l_select_cl              VARCHAR2(2000) := '';
l_order_by_cl            VARCHAR2(2000);
l_REPJOBXREF_where    VARCHAR2(2000) := '';

-- For flex field query
l_flex_where_tbl_type    AS_FOUNDATION_PVT.flex_where_tbl_type;
l_flex_where             VARCHAR2(2000) := NULL;
l_counter                NUMBER;

-- Local scratch record
l_REPJOBXREF_rec REPJOBXREF_Rec_Type;
l_crit_REPJOBXREF_rec REPJOBXREF_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_REPJOBXREF_PVT;

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

/*      AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
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
      Gen_REPJOBXREF_Where(l_crit_REPJOBXREF_rec, l_REPJOBXREF_where);

      -- Generate Where clause for flex fields
      -- Hint: Developer can use table/view alias in the From clause generated in Gen_Select procedure

      FOR l_counter IN 1..15 LOOP
          l_flex_where_tbl_type(l_counter).name := 'CSD_REPAIR_JOB_XREF_V.attribute' || l_counter;
      END LOOP;

      l_flex_where_tbl_type(16).name := 'CSD_REPAIR_JOB_XREF_V.attribute_category';
      l_flex_where_tbl_type(1).value := P_REPJOBXREF_Rec.attribute1;
      l_flex_where_tbl_type(2).value := P_REPJOBXREF_Rec.attribute2;
      l_flex_where_tbl_type(3).value := P_REPJOBXREF_Rec.attribute3;
      l_flex_where_tbl_type(4).value := P_REPJOBXREF_Rec.attribute4;
      l_flex_where_tbl_type(5).value := P_REPJOBXREF_Rec.attribute5;
      l_flex_where_tbl_type(6).value := P_REPJOBXREF_Rec.attribute6;
      l_flex_where_tbl_type(7).value := P_REPJOBXREF_Rec.attribute7;
      l_flex_where_tbl_type(8).value := P_REPJOBXREF_Rec.attribute8;
      l_flex_where_tbl_type(9).value := P_REPJOBXREF_Rec.attribute9;
      l_flex_where_tbl_type(10).value := P_REPJOBXREF_Rec.attribute10;
      l_flex_where_tbl_type(11).value := P_REPJOBXREF_Rec.attribute11;
      l_flex_where_tbl_type(12).value := P_REPJOBXREF_Rec.attribute12;
      l_flex_where_tbl_type(13).value := P_REPJOBXREF_Rec.attribute13;
      l_flex_where_tbl_type(14).value := P_REPJOBXREF_Rec.attribute14;
      l_flex_where_tbl_type(15).value := P_REPJOBXREF_Rec.attribute15;
      l_flex_where_tbl_type(16).value := P_REPJOBXREF_Rec.attribute_category;


      AS_FOUNDATION_PVT.Gen_Flexfield_Where(
          p_flex_where_tbl_type   => l_flex_where_tbl_type,
          x_flex_where_clause     => l_flex_where);

      -- Hint: if master/detail relationship, generate Where clause for lines level criteria
      -- Generate order by clause
      Gen_REPJOBXREF_order_cl(p_order_by_rec, l_order_by_cl, l_return_status, x_msg_count, x_msg_data);

      -- Debug Message
      JTF_PLSQL_API.Debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Open and Parse Cursor');

      l_cur_get_REPJOBXREF := dbms_sql.open_cursor;

      -- Hint: concatenate all where clause (include flex field/line level if any applies)
      --    dbms_sql.parse(l_cur_get_REPJOBXREF, l_select_cl || l_head_where || l_flex_where || l_lines_where
      --    || l_steam_where || l_order_by_cl, dbms_sql.native);

      -- Hint: Developer should implement Bind Variables procedure according to bind variables in the parameter list
      -- Bind(l_crit_REPJOBXREF_rec, l_crit_exp_purchase_rec, p_start_date, p_end_date,
      --      p_crit_exp_salesforce_id, p_crit_ptr_salesforce_id,
      --      p_crit_salesgroup_id, p_crit_ptr_manager_person_id,
      --      p_win_prob_ceiling, p_win_prob_floor,
      --      p_total_amt_ceiling, p_total_amt_floor,
      --      l_cur_get_REPJOBXREF);

      -- Bind flexfield variables
      AS_FOUNDATION_PVT.Bind_Flexfield_Where(
          p_cursor_id   =>   l_cur_get_REPJOBXREF,
          p_flex_where_tbl_type => l_flex_where_tbl_type);

      -- Define all Select Columns
      Define_Columns(l_crit_REPJOBXREF_rec, l_cur_get_REPJOBXREF);

      -- Execute
      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: Execute Dsql');

      l_ignore := dbms_sql.execute(l_cur_get_REPJOBXREF);

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
      IF((dbms_sql.fetch_rows(l_cur_get_REPJOBXREF)>0) AND ((p_return_tot_count = FND_API.G_TRUE)
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
--          IF(l_REPJOBXREF_rec.member_access <> 'N' OR l_REPJOBXREF_rec.member_role <> 'N') THEN
              Get_Column_Values(l_cur_get_REPJOBXREF, l_REPJOBXREF_rec);
              l_tot_rec_count := l_tot_rec_count + 1;
              IF(l_returned_rec_count < p_rec_requested) AND (l_tot_rec_count >= p_start_rec_prt) THEN
                  l_returned_rec_count := l_returned_rec_count + 1;
                  -- insert into resultant tables
                  X_REPJOBXREF_Tbl(l_returned_rec_count) := l_REPJOBXREF_rec;
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
--             RAISE;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--             RAISE;

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
--             RAISE;
End Get_repjobxref;


-- Item-level validation procedures
PROCEDURE Validate_REPAIR_JOB_XREF_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REPAIR_JOB_XREF_ID                IN   NUMBER,
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
      IF(p_REPAIR_JOB_XREF_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repjobxref API: -Violate NOT NULL constraint(REPAIR_JOB_XREF_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_REPAIR_JOB_XREF_ID is not NULL and p_REPAIR_JOB_XREF_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REPAIR_JOB_XREF_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REPAIR_JOB_XREF_ID;


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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repjobxref API: -Violate NOT NULL constraint(REPAIR_LINE_ID)');
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


PROCEDURE Validate_WIP_ENTITY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_WIP_ENTITY_ID                IN   NUMBER,
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
      IF(p_WIP_ENTITY_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repjobxref API: -Violate NOT NULL constraint(WIP_ENTITY_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_WIP_ENTITY_ID is not NULL and p_WIP_ENTITY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_WIP_ENTITY_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_WIP_ENTITY_ID;


PROCEDURE Validate_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_ID                IN   NUMBER,
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
      IF(p_GROUP_ID is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repjobxref API: -Violate NOT NULL constraint(GROUP_ID)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = JTF_PLSQL_API.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_ID is not NULL and p_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_GROUP_ID;


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
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repjobxref API: -Violate NOT NULL constraint(ORGANIZATION_ID)');
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

      -- validate NOT NULL column
      IF(p_QUANTITY is NULL)
      THEN
          JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'CSD', 'Private repjobxref API: -Violate NOT NULL constraint(QUANTITY)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

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


PROCEDURE Validate_OBJECT_VERSION_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    P_REPAIR_JOB_XREF_ID         IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     JTF_PLSQL_API.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

   l_OBJECT_VERSION_NUMBER NUMBER;

BEGIN

IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PVT.Validate_OBJECT_VERSION_NUMBER in procedure');
END IF;


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
     csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PVT.Validate_OBJECT_VERSION_NUMBER in create');
END IF;

IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PVT.Validate_OBJECT_VERSION_NUMBER ovn '||to_char(p_OBJECT_VERSION_NUMBER));
END IF;


          -- verify if data is valid
        --IF(p_OBJECT_VERSION_NUMBER is NULL) THEN
            -- set object_version_number to 1 for create
          --    p_OBJECT_VERSION_NUMBER := 1;
        --END IF;
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF(p_validation_mode = JTF_PLSQL_API.G_UPDATE)
      THEN

IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PVT.Validate_OBJECT_VERSION_NUMBER in update');
END IF;

IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PVT.Validate_OBJECT_VERSION_NUMBER ovn from form '||to_char(p_OBJECT_VERSION_NUMBER));
END IF;


          -- verify if data is valid
        SELECT OBJECT_VERSION_NUMBER
          INTO l_OBJECT_VERSION_NUMBER
          FROM CSD_REPAIR_JOB_XREF
           WHERE REPAIR_JOB_XREF_ID = P_REPAIR_JOB_XREF_ID;

IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PVT.Validate_OBJECT_VERSION_NUMBER ovn from db '||to_char(l_OBJECT_VERSION_NUMBER));
END IF;


        if (l_OBJECT_VERSION_NUMBER <> p_OBJECT_VERSION_NUMBER) then
            -- data is not valid
          x_return_status := FND_API.G_RET_STS_ERROR;

IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('CSD_REPAIR_JOB_XREF_PVT.Validate_OBJECT_VERSION_NUMBER ovn mismatch error');
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
PROCEDURE Validate_REPJOBXREF_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REPJOBXREF_Rec     IN    REPJOBXREF_Rec_Type,
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

END Validate_REPJOBXREF_Rec;

PROCEDURE Validate_repjobxref(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_REPJOBXREF_Rec     IN    REPJOBXREF_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_repjobxref';
 BEGIN

      -- Debug Message
      JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSD', 'Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.
          Validate_REPAIR_JOB_XREF_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REPAIR_JOB_XREF_ID   => P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID,
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
              p_REPAIR_LINE_ID   => P_REPJOBXREF_Rec.REPAIR_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_WIP_ENTITY_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_WIP_ENTITY_ID   => P_REPJOBXREF_Rec.WIP_ENTITY_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_GROUP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_GROUP_ID   => P_REPJOBXREF_Rec.GROUP_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORGANIZATION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ORGANIZATION_ID   => P_REPJOBXREF_Rec.ORGANIZATION_ID,
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
              p_QUANTITY   => P_REPJOBXREF_Rec.QUANTITY,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

        -- travi OBJECT_VERSION_NUMBER validation
          Validate_OBJECT_VERSION_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_VERSION_NUMBER   => P_REPJOBXREF_Rec.OBJECT_VERSION_NUMBER,
              p_REPAIR_JOB_XREF_ID      => P_REPJOBXREF_Rec.REPAIR_JOB_XREF_ID,
              -- Hint: You may add x_item_property_rec as one of your out parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      IF (p_validation_level >= JTF_PLSQL_API.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_REPJOBXREF_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_REPJOBXREF_Rec     =>    P_REPJOBXREF_Rec,
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

END Validate_repjobxref;

End CSD_REPair_JOB_XREF_PVT;

/
