--------------------------------------------------------
--  DDL for Package Body PV_ENTYATTMAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTYATTMAP_PVT" as
/* $Header: pvrveamb.pls 120.0 2005/05/27 16:09:55 appldev noship $ */
-- Start of Comments
-- Package name     : PV_ENTYATTMAP_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ENTYATTMAP_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvrveamb.pls';


-- Hint: Primary key needs to be returned.
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_entyattmap(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_ENTYATTMAP_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type
                                   := PV_RULE_RECTYPE_PUB.G_MISS_ENTYATTMAP_REC,
    X_MAPPING_ID                 OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_entyattmap';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ENTYATTMAP_PVT;

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

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_entyattmap');
      END IF;

      -- Invoke validation procedures
      Validate_entyattmap(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_ENTYATTMAP_Rec   => P_ENTYATTMAP_Rec,
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

      -- Invoke table handler(PV_ENTITY_ATTR_MAPPINGS_PKG.Insert_Row)
      PV_ENTITY_ATTR_MAPPINGS_PKG.Insert_Row(
          px_MAPPING_ID  => x_MAPPING_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => SYSDATE
         ,p_CREATED_BY  => FND_GLOBAL.USER_ID
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_ENTYATTMAP_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_ENTYATTMAP_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_ENTYATTMAP_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_ENTYATTMAP_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_ENTYATTMAP_rec.PROGRAM_UPDATE_DATE
         ,p_PROCESS_RULE_ID  => p_ENTYATTMAP_rec.PROCESS_RULE_ID
         ,p_SOURCE_ATTR_TYPE  => p_ENTYATTMAP_rec.SOURCE_ATTR_TYPE
         ,p_SOURCE_ATTR_ID  => p_ENTYATTMAP_rec.SOURCE_ATTR_ID
         ,p_TARGET_ATTR_TYPE  => p_ENTYATTMAP_rec.TARGET_ATTR_TYPE
         ,p_TARGET_ATTR_ID  => p_ENTYATTMAP_rec.TARGET_ATTR_ID
         ,p_OPERATOR  => p_ENTYATTMAP_rec.OPERATOR
         ,p_ATTRIBUTE_CATEGORY  => p_ENTYATTMAP_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_ENTYATTMAP_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_ENTYATTMAP_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_ENTYATTMAP_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_ENTYATTMAP_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_ENTYATTMAP_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_ENTYATTMAP_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_ENTYATTMAP_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_ENTYATTMAP_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_ENTYATTMAP_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_ENTYATTMAP_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_ENTYATTMAP_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_ENTYATTMAP_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_ENTYATTMAP_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_ENTYATTMAP_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_ENTYATTMAP_rec.ATTRIBUTE15
);

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
End Create_entyattmap;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_entyattmap(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2  := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_ENTYATTMAP_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
Cursor C_Get_entyattmap(pc_MAPPING_ID Number) IS
    Select object_version_number
    From  PV_ENTITY_ATTR_MAPPINGS
    where mapping_id = pc_mapping_id
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_entyattmap';
l_api_version_number      CONSTANT NUMBER   := 2.0;

-- Local Variables
l_ref_ENTYATTMAP_rec  PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type;
l_tar_ENTYATTMAP_rec  PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type := P_ENTYATTMAP_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_ENTYATTMAP_PVT;

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

      Open C_Get_entyattmap( l_tar_ENTYATTMAP_rec.MAPPING_ID);
      Fetch C_Get_entyattmap into
               l_ref_ENTYATTMAP_rec.object_version_number;

       If ( C_Get_entyattmap%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('PV', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'entyattmap', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_entyattmap;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AS_DEBUG_HIGH_ON) THEN

       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       END IF;
       Close     C_Get_entyattmap;


      If (l_tar_ENTYATTMAP_rec.object_version_number is NULL or
          l_tar_ENTYATTMAP_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('PV', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'object_version_number', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ENTYATTMAP_rec.object_version_number <> l_ref_ENTYATTMAP_rec.object_version_number) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('PV', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'entyattmap', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_entyattmap');
      END IF;

      -- Invoke validation procedures
      Validate_entyattmap(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_ENTYATTMAP_Rec   =>  P_ENTYATTMAP_Rec,
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

      -- Invoke table handler(PV_ENTITY_ATTR_MAPPINGS_PKG.Update_Row)
      PV_ENTITY_ATTR_MAPPINGS_PKG.Update_Row(
          p_MAPPING_ID  => p_ENTYATTMAP_rec.MAPPING_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => FND_API.G_MISS_DATE
         ,p_CREATED_BY     => FND_API.G_MISS_NUM
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_ENTYATTMAP_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_ENTYATTMAP_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_ENTYATTMAP_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_ENTYATTMAP_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_ENTYATTMAP_rec.PROGRAM_UPDATE_DATE
         ,p_PROCESS_RULE_ID  => p_ENTYATTMAP_rec.PROCESS_RULE_ID
         ,p_SOURCE_ATTR_TYPE  => p_ENTYATTMAP_rec.SOURCE_ATTR_TYPE
         ,p_SOURCE_ATTR_ID  => p_ENTYATTMAP_rec.SOURCE_ATTR_ID
         ,p_TARGET_ATTR_TYPE  => p_ENTYATTMAP_rec.TARGET_ATTR_TYPE
         ,p_TARGET_ATTR_ID  => p_ENTYATTMAP_rec.TARGET_ATTR_ID
         ,p_OPERATOR  => p_ENTYATTMAP_rec.OPERATOR
         ,p_ATTRIBUTE_CATEGORY  => p_ENTYATTMAP_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_ENTYATTMAP_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_ENTYATTMAP_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_ENTYATTMAP_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_ENTYATTMAP_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_ENTYATTMAP_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_ENTYATTMAP_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_ENTYATTMAP_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_ENTYATTMAP_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_ENTYATTMAP_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_ENTYATTMAP_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_ENTYATTMAP_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_ENTYATTMAP_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_ENTYATTMAP_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_ENTYATTMAP_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_ENTYATTMAP_rec.ATTRIBUTE15
);      --
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
End Update_entyattmap;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_entyattmap(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_ENTYATTMAP_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_entyattmap';
l_api_version_number      CONSTANT NUMBER   := 2.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_ENTYATTMAP_PVT;

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

      -- Invoke table handler(PV_ENTITY_ATTR_MAPPINGS_PKG.Delete_Row)
      PV_ENTITY_ATTR_MAPPINGS_PKG.Delete_Row(
          p_MAPPING_ID  => p_ENTYATTMAP_rec.MAPPING_ID);
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
End Delete_entyattmap;


-- Item-level validation procedures
PROCEDURE Validate_MAPPING_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MAPPING_ID                 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_mapping_id_exists (pc_mapping_id NUMBER) IS
      SELECT 'X'
      FROM  pv_entity_attr_mappings
      WHERE mapping_id = pc_mapping_id;

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
          IF (p_mapping_id IS NOT NULL) AND
             (p_mapping_id <> FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'API_INVALID_ID',
                  p_token1       => 'MAPPING_ID',
                  p_token1_value => p_mapping_id);

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_mapping_id IS NULL) OR
             (p_mapping_id = FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_mapping_id_exists (p_mapping_id);
              FETCH C_mapping_id_exists into l_val;

              IF C_mapping_id_exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_ID',
                      p_token1        => 'MAPPING_ID',
                      p_token1_value  => p_mapping_id );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_mapping_id_exists;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MAPPING_ID;


PROCEDURE Validate_MAPPING_OPERATOR (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ATTRIBUTE_ID               IN   NUMBER,
    P_OPERATOR                   IN   VARCHAR2,
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

      if p_operator is NULL or p_operator = FND_API.G_MISS_CHAR then

         AS_UTILITY_PVT.Set_Message(
             p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
             p_msg_name      => 'API_MISSING_OPERATOR');

         x_return_status := FND_API.G_RET_STS_ERROR;

      elsif p_operator not in ('EQUALS', 'NOT_EQUALS',
                               'LESS_THAN', 'GREATER_THAN',
                               'LESS_THAN_OR_EQUALS', 'GREATER_THAN_OR_EQUALS')
      then
         FND_MESSAGE.SET_NAME('PV', 'API_INVALID_MAPPING_OPERATOR');
         FND_MESSAGE.SET_TOKEN('OPERATOR', p_operator);
         FND_MSG_PUB.ADD;

         x_return_status := FND_API.G_RET_STS_ERROR;

      else
          pv_common_checks_pvt.Validate_OPERATOR(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TABLE_NAME             => 'PV_ENTITY_ATTR_MAPPINGS',
              p_COLUMN_NAME            => 'OPERATOR',
              p_attribute_id           => p_ATTRIBUTE_ID,
              p_OPERATOR_CODE          => p_operator,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MAPPING_OPERATOR;


PROCEDURE Validate_entyattmap(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_ENTYATTMAP_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_entyattmap';
 BEGIN

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN

          Validate_MAPPING_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MAPPING_ID             => P_ENTYATTMAP_Rec.MAPPING_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_OBJECT_VERSION_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_VERSION_NUMBER   => p_ENTYATTMAP_rec.OBJECT_VERSION_NUMBER,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_PROCESS_RULE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PROCESS_RULE_ID        => P_ENTYATTMAP_Rec.PROCESS_RULE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_Lookup(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TABLE_NAME             => 'PV_ENTITY_ATTR_MAPPINGS',
              p_COLUMN_NAME            => 'SOURCE_ATTR_TYPE',
              p_LOOKUP_TYPE            => 'PV_ATTRIBUTE_ENTITY_TYPE',
              p_LOOKUP_CODE            => P_ENTYATTMAP_Rec.SOURCE_ATTR_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_attribute_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_attribute_id           => P_ENTYATTMAP_Rec.SOURCE_ATTR_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_Lookup(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_TABLE_NAME             => 'PV_ENTITY_ATTR_MAPPINGS',
              p_COLUMN_NAME            => 'TARGET_ATTR_TYPE',
              p_LOOKUP_TYPE            => 'PV_ATTRIBUTE_ENTITY_TYPE',
              p_LOOKUP_CODE            => P_ENTYATTMAP_Rec.TARGET_ATTR_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_attribute_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_attribute_id           => P_ENTYATTMAP_Rec.TARGET_ATTR_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_MAPPING_OPERATOR(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_attribute_id           => P_ENTYATTMAP_Rec.SOURCE_ATTR_ID,
              p_OPERATOR               => P_ENTYATTMAP_Rec.OPERATOR,
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

          if (p_validation_mode = AS_UTILITY_PVT.G_CREATE) then

              if (P_ENTYATTMAP_Rec.SOURCE_ATTR_ID IS NULL or
                 P_ENTYATTMAP_Rec.SOURCE_ATTR_ID = FND_API.G_MISS_NUM or
                 P_ENTYATTMAP_Rec.OPERATOR IS NULL or
                 P_ENTYATTMAP_Rec.OPERATOR = FND_API.G_MISS_CHAR or
                 P_ENTYATTMAP_Rec.TARGET_ATTR_ID IS NULL or
                 P_ENTYATTMAP_Rec.TARGET_ATTR_ID = FND_API.G_MISS_NUM) then

                    FND_MESSAGE.Set_Name('PV', 'PV_INVALID_ENTITY_MAPPING');
                    FND_MSG_PUB.Add;
                    x_return_status := FND_API.G_RET_STS_ERROR;

              END IF;
          END IF;

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

END Validate_entyattmap;

End PV_ENTYATTMAP_PVT;

/
