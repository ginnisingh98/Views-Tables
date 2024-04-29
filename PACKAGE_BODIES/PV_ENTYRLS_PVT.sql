--------------------------------------------------------
--  DDL for Package Body PV_ENTYRLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTYRLS_PVT" as
/* $Header: pvrverab.pls 115.4 2002/12/19 05:54:09 dhii ship $ */
-- Start of Comments
-- Package name     : PV_ENTYRLS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ENTYRLS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvrverab.pls';


-- Hint: Primary key needs to be returned.
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_entyrls(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYRLS_Rec              IN   PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type
                                 := PV_RULE_RECTYPE_PUB.G_MISS_ENTYRLS_REC,
    X_ENTITY_RULE_APPLIED_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_entyrls';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ENTYRLS_PVT;

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
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
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
              FND_MESSAGE.Set_Name('PV', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_entyrls');
      END IF;

      -- Invoke validation procedures
      Validate_entyrls(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_ENTYRLS_Rec  =>  P_ENTYRLS_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(PV_ENTITY_RULES_APPLIED_PKG.Insert_Row)
      PV_ENTITY_RULES_APPLIED_PKG.Insert_Row(
          px_ENTITY_RULE_APPLIED_ID  => x_ENTITY_RULE_APPLIED_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => SYSDATE
         ,p_CREATED_BY  => FND_GLOBAL.USER_ID
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_ENTYRLS_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_ENTYRLS_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_ENTYRLS_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_ENTYRLS_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_ENTYRLS_rec.PROGRAM_UPDATE_DATE
         ,p_ENTITY  => p_ENTYRLS_rec.ENTITY
         ,p_ENTITY_ID  => p_ENTYRLS_rec.ENTITY_ID
         ,p_PROCESS_RULE_ID  => p_ENTYRLS_rec.PROCESS_RULE_ID
         ,p_PARENT_PROCESS_RULE_ID  => p_ENTYRLS_rec.PARENT_PROCESS_RULE_ID
         ,p_LATEST_FLAG  => p_ENTYRLS_rec.LATEST_FLAG
         ,p_ACTION_VALUE  => p_ENTYRLS_rec.ACTION_VALUE
         ,p_PROCESS_TYPE  => p_ENTYRLS_rec.PROCESS_TYPE
         ,p_WINNING_RULE_FLAG  => p_ENTYRLS_rec.WINNING_RULE_FLAG
         ,p_ENTITY_DETAIL  => p_ENTYRLS_rec.ENTITY_DETAIL
         ,p_ATTRIBUTE_CATEGORY  => p_ENTYRLS_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_ENTYRLS_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_ENTYRLS_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_ENTYRLS_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_ENTYRLS_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_ENTYRLS_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_ENTYRLS_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_ENTYRLS_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_ENTYRLS_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_ENTYRLS_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_ENTYRLS_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_ENTYRLS_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_ENTYRLS_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_ENTYRLS_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_ENTYRLS_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_ENTYRLS_rec.ATTRIBUTE15
         ,p_PROCESS_STATUS  => p_ENTYRLS_rec.PROCESS_STATUS);
      -- Hint: Primary key should be returned.
      -- x_ENTITY_RULE_APPLIED_ID := px_ENTITY_RULE_APPLIED_ID;

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
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;


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
End Create_entyrls;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_entyrls(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYRLS_Rec     IN    PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
Cursor C_Get_entyrls(pc_ENTITY_RULE_APPLIED_ID Number) IS
    Select object_version_number
    From  PV_ENTITY_RULES_APPLIED
    where entity_rule_applied_id = pc_entity_rule_applied_id
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_entyrls';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_ref_ENTYRLS_rec  PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type;
l_tar_ENTYRLS_rec  PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type := P_ENTYRLS_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_ENTYRLS_PVT;

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
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');
      END IF;

      Open C_Get_entyrls( l_tar_ENTYRLS_rec.ENTITY_RULE_APPLIED_ID);

      Fetch C_Get_entyrls into
               l_ref_ENTYRLS_rec.object_version_number;

       If ( C_Get_entyrls%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('PV', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'entyrls', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_entyrls;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AS_DEBUG_HIGH_ON) THEN

       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       END IF;
       Close     C_Get_entyrls;


      If (l_tar_ENTYRLS_rec.object_version_number is NULL or
          l_tar_ENTYRLS_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('PV', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'object_version_number', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ENTYRLS_rec.object_version_number <> l_ref_ENTYRLS_rec.object_version_number) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('PV', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'entyrls', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_entyrls');
      END IF;

      -- Invoke validation procedures
      Validate_entyrls(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_ENTYRLS_Rec  =>  P_ENTYRLS_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(PV_ENTITY_RULES_APPLIED_PKG.Update_Row)
      PV_ENTITY_RULES_APPLIED_PKG.Update_Row(
          p_ENTITY_RULE_APPLIED_ID  => p_ENTYRLS_rec.ENTITY_RULE_APPLIED_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => FND_API.G_MISS_DATE
         ,p_CREATED_BY     => FND_API.G_MISS_NUM
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_ENTYRLS_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_ENTYRLS_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_ENTYRLS_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_ENTYRLS_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_ENTYRLS_rec.PROGRAM_UPDATE_DATE
         ,p_ENTITY  => p_ENTYRLS_rec.ENTITY
         ,p_ENTITY_ID  => p_ENTYRLS_rec.ENTITY_ID
         ,p_PROCESS_RULE_ID  => p_ENTYRLS_rec.PROCESS_RULE_ID
         ,p_PARENT_PROCESS_RULE_ID  => p_ENTYRLS_rec.PARENT_PROCESS_RULE_ID
         ,p_LATEST_FLAG  => p_ENTYRLS_rec.LATEST_FLAG
         ,p_ACTION_VALUE  => p_ENTYRLS_rec.ACTION_VALUE
         ,p_PROCESS_TYPE  => p_ENTYRLS_rec.PROCESS_TYPE
         ,p_WINNING_RULE_FLAG  => p_ENTYRLS_rec.WINNING_RULE_FLAG
         ,p_ENTITY_DETAIL  => p_ENTYRLS_rec.ENTITY_DETAIL
         ,p_ATTRIBUTE_CATEGORY  => p_ENTYRLS_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_ENTYRLS_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_ENTYRLS_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_ENTYRLS_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_ENTYRLS_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_ENTYRLS_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_ENTYRLS_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_ENTYRLS_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_ENTYRLS_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_ENTYRLS_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_ENTYRLS_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_ENTYRLS_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_ENTYRLS_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_ENTYRLS_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_ENTYRLS_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_ENTYRLS_rec.ATTRIBUTE15
         ,p_PROCESS_STATUS  => p_ENTYRLS_rec.PROCESS_STATUS);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;


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
End Update_entyrls;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_entyrls(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYRLS_Rec     IN PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_entyrls';
l_api_version_number      CONSTANT NUMBER   := 2.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_ENTYRLS_PVT;

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
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(PV_ENTITY_RULES_APPLIED_PKG.Delete_Row)
      PV_ENTITY_RULES_APPLIED_PKG.Delete_Row(
          p_ENTITY_RULE_APPLIED_ID  => p_ENTYRLS_rec.ENTITY_RULE_APPLIED_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;


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
End Delete_entyrls;


-- Item-level validation procedures
PROCEDURE Validate_ENTY_RULE_APPLIED_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ENTITY_RULE_APPLIED_ID     IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
CURSOR C_entity_rule_applied_exists (pc_entity_rule_applied_id NUMBER) IS
    SELECT 'X'
    FROM  pv_entity_rules_applied
    WHERE entity_rule_applied_id = pc_entity_rule_applied_id;

l_val   VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          IF (p_entity_rule_applied_id IS NOT NULL) AND
             (p_entity_rule_applied_id <> FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'API_INVALID_ID',
                  p_token1       => 'ENTITY_RULE_APPLIED_ID',
                  p_token1_value => p_entity_rule_applied_id);

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_entity_rule_applied_id IS NULL) OR
             (p_entity_rule_applied_id = FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_entity_rule_applied_exists (p_entity_rule_applied_id);
              FETCH C_entity_rule_applied_exists into l_val;

              IF C_entity_rule_applied_exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_ID',
                      p_token1        => 'ENTITY_RULE_APPLIED_ID',
                      p_token1_value  => p_entity_rule_applied_id );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_entity_rule_applied_exists;
          END IF;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ENTY_RULE_APPLIED_ID;


PROCEDURE Validate_entyrls(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_ENTYRLS_Rec                IN   PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_entyrls';
 BEGIN

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN

          Validate_ENTY_RULE_APPLIED_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ENTITY_RULE_APPLIED_ID => P_ENTYRLS_Rec.ENTITY_RULE_APPLIED_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_OBJECT_VERSION_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_VERSION_NUMBER  => P_ENTYRLS_Rec.OBJECT_VERSION_NUMBER,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_Lookup(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TABLE_NAME             => 'PV_ENTITY_RULES_APPLIED',
              p_COLUMN_NAME            => 'ENTITY',
              p_lookup_type            => 'PV_RULE_APPLIED_ENTITY_TYPE',
              p_lookup_code            => P_ENTYRLS_Rec.ENTITY,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_PROCESS_RULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROCESS_RULE_ID        => P_ENTYRLS_Rec.PROCESS_RULE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_PROCESS_RULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROCESS_RULE_ID        => P_ENTYRLS_Rec.PARENT_PROCESS_RULE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_Lookup(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TABLE_NAME             => 'PV_ENTITY_RULES_APPLIED',
              p_COLUMN_NAME            => 'PROCESS_TYPE',
              p_lookup_type            => 'PV_PROCESS_TYPE',
              p_lookup_code            => P_ENTYRLS_Rec.PROCESS_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_FLAG                   => P_ENTYRLS_Rec.WINNING_RULE_FLAG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_FLAG                   => P_ENTYRLS_Rec.LATEST_FLAG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_Lookup(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TABLE_NAME             => 'PV_ENTITY_RULES_APPLIED',
              p_COLUMN_NAME            => 'PROCESS_STATUS',
              p_lookup_type            => 'PV_RULES_APPLIED_STATUS',
              p_lookup_code            => P_ENTYRLS_Rec.PROCESS_STATUS,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
      END IF;

END Validate_entyrls;

End PV_ENTYRLS_PVT;

/
