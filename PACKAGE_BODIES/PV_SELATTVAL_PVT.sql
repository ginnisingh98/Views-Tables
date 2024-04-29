--------------------------------------------------------
--  DDL for Package Body PV_SELATTVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_SELATTVAL_PVT" as
/* $Header: pvrvsavb.pls 120.1 2005/12/06 14:17:00 amaram noship $ */
-- Start of Comments
-- Package name     : PV_SELATTVAL_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_SELATTVAL_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvrvsavb.pls';


-- Hint: Primary key needs to be returned.
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_selattval(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_SELATTVAL_Rec              IN   PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type
                                   := PV_RULE_RECTYPE_PUB.G_MISS_SELATTVAL_REC,
    X_ATTR_VALUE_ID              OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_selattval';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SELATTVAL_PVT;

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

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_selattval');
      END IF;

      -- Invoke validation procedures
      Validate_selattval(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_SELATTVAL_Rec    => P_SELATTVAL_Rec,
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

      -- Invoke table handler(PV_SELECTED_ATTR_VALUES_PKG.Insert_Row)
      PV_SELECTED_ATTR_VALUES_PKG.Insert_Row(
          px_ATTR_VALUE_ID  => x_ATTR_VALUE_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => SYSDATE
         ,p_CREATED_BY  => FND_GLOBAL.USER_ID
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_SELATTVAL_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_SELATTVAL_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_SELATTVAL_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_SELATTVAL_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_SELATTVAL_rec.PROGRAM_UPDATE_DATE
         ,p_SELECTION_CRITERIA_ID  => p_SELATTVAL_rec.SELECTION_CRITERIA_ID
         ,p_ATTRIBUTE_VALUE  => p_SELATTVAL_rec.ATTRIBUTE_VALUE
         ,p_ATTRIBUTE_TO_VALUE  => p_SELATTVAL_rec.ATTRIBUTE_TO_VALUE
         ,p_ATTRIBUTE_CATEGORY  => p_SELATTVAL_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_SELATTVAL_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_SELATTVAL_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_SELATTVAL_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_SELATTVAL_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_SELATTVAL_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_SELATTVAL_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_SELATTVAL_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_SELATTVAL_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_SELATTVAL_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_SELATTVAL_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_SELATTVAL_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_SELATTVAL_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_SELATTVAL_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_SELATTVAL_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_SELATTVAL_rec.ATTRIBUTE15
         ,p_SCORE        => p_SELATTVAL_rec.SCORE);
      -- Hint: Primary key should be returned.
      -- x_ATTR_VALUE_ID := px_ATTR_VALUE_ID;

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
End Create_selattval;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_selattval(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_SELATTVAL_Rec              IN    PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

Cursor C_Get_selattval(pc_ATTR_VALUE_ID Number) IS
    Select object_version_number
    From  PV_SELECTED_ATTR_VALUES
    where attr_value_id = pc_attr_value_id
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_selattval';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_ref_SELATTVAL_rec  PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type;
l_tar_SELATTVAL_rec  PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type := P_SELATTVAL_Rec;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SELATTVAL_PVT;

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

      Open C_Get_selattval( l_tar_SELATTVAL_rec.ATTR_VALUE_ID);
      Fetch C_Get_selattval into
               l_ref_SELATTVAL_rec.OBJECT_VERSION_NUMBER;

       If ( C_Get_selattval%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('PV', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'selattval', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           Close C_Get_selattval;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AS_DEBUG_HIGH_ON) THEN

       AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       END IF;
       Close     C_Get_selattval;


      If (l_tar_SELATTVAL_rec.object_version_number is NULL or
          l_tar_SELATTVAL_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('PV', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'object_version_number', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_SELATTVAL_rec.object_version_number <> l_ref_SELATTVAL_rec.object_version_number) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('PV', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'selattval', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_selattval');
      END IF;

      -- Invoke validation procedures
      Validate_selattval(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_SELATTVAL_Rec  =>  P_SELATTVAL_Rec,
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

      -- Invoke table handler(PV_SELECTED_ATTR_VALUES_PKG.Update_Row)
      PV_SELECTED_ATTR_VALUES_PKG.Update_Row(
          p_ATTR_VALUE_ID  => p_SELATTVAL_rec.ATTR_VALUE_ID
         ,p_LAST_UPDATE_DATE  => SYSDATE
         ,p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,p_CREATION_DATE  => FND_API.G_MISS_DATE
         ,p_CREATED_BY     => FND_API.G_MISS_NUM
         ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,p_OBJECT_VERSION_NUMBER  => p_SELATTVAL_rec.OBJECT_VERSION_NUMBER
         ,p_REQUEST_ID  => p_SELATTVAL_rec.REQUEST_ID
         ,p_PROGRAM_APPLICATION_ID  => p_SELATTVAL_rec.PROGRAM_APPLICATION_ID
         ,p_PROGRAM_ID  => p_SELATTVAL_rec.PROGRAM_ID
         ,p_PROGRAM_UPDATE_DATE  => p_SELATTVAL_rec.PROGRAM_UPDATE_DATE
         ,p_SELECTION_CRITERIA_ID  => p_SELATTVAL_rec.SELECTION_CRITERIA_ID
         ,p_ATTRIBUTE_VALUE  => p_SELATTVAL_rec.ATTRIBUTE_VALUE
         ,p_ATTRIBUTE_TO_VALUE  => p_SELATTVAL_rec.ATTRIBUTE_TO_VALUE
         ,p_ATTRIBUTE_CATEGORY  => p_SELATTVAL_rec.ATTRIBUTE_CATEGORY
         ,p_ATTRIBUTE1  => p_SELATTVAL_rec.ATTRIBUTE1
         ,p_ATTRIBUTE2  => p_SELATTVAL_rec.ATTRIBUTE2
         ,p_ATTRIBUTE3  => p_SELATTVAL_rec.ATTRIBUTE3
         ,p_ATTRIBUTE4  => p_SELATTVAL_rec.ATTRIBUTE4
         ,p_ATTRIBUTE5  => p_SELATTVAL_rec.ATTRIBUTE5
         ,p_ATTRIBUTE6  => p_SELATTVAL_rec.ATTRIBUTE6
         ,p_ATTRIBUTE7  => p_SELATTVAL_rec.ATTRIBUTE7
         ,p_ATTRIBUTE8  => p_SELATTVAL_rec.ATTRIBUTE8
         ,p_ATTRIBUTE9  => p_SELATTVAL_rec.ATTRIBUTE9
         ,p_ATTRIBUTE10  => p_SELATTVAL_rec.ATTRIBUTE10
         ,p_ATTRIBUTE11  => p_SELATTVAL_rec.ATTRIBUTE11
         ,p_ATTRIBUTE12  => p_SELATTVAL_rec.ATTRIBUTE12
         ,p_ATTRIBUTE13  => p_SELATTVAL_rec.ATTRIBUTE13
         ,p_ATTRIBUTE14  => p_SELATTVAL_rec.ATTRIBUTE14
         ,p_ATTRIBUTE15  => p_SELATTVAL_rec.ATTRIBUTE15
	 ,p_SCORE        => p_SELATTVAL_rec.SCORE);
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
End Update_selattval;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_selattval(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_SELATTVAL_Rec            IN PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_selattval';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SELATTVAL_PVT;

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

      -- Invoke table handler(PV_SELECTED_ATTR_VALUES_PKG.Delete_Row)
      PV_SELECTED_ATTR_VALUES_PKG.Delete_Row(
          p_ATTR_VALUE_ID  => p_SELATTVAL_rec.ATTR_VALUE_ID);
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
End Delete_selattval;


-- Item-level validation procedures
PROCEDURE Validate_ATTR_VALUE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ATTR_VALUE_ID              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_attr_value_Id_Exists (pc_attr_value_id NUMBER) IS
      SELECT 'X'
      FROM  pv_selected_attr_values
      WHERE attr_value_id = pc_attr_value_id;

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
          IF (p_attr_value_id IS NOT NULL) AND
             (p_attr_value_id <> FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name     => 'API_INVALID_ID',
                  p_token1       => 'attr_value_id',
                  p_token1_value => p_attr_value_id);

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_attr_value_id IS NULL) OR
             (p_attr_value_id = FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_attr_value_id_exists (p_attr_value_id);
              FETCH C_attr_value_id_exists into l_val;

              IF C_attr_value_id_exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_ID',
                      p_token1        => 'attr_value_id',
                      p_token1_value  => p_attr_value_id );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_attr_value_id_exists;
          END IF;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ATTR_VALUE_ID;


PROCEDURE Validate_SELECTION_CRITERIA_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SELECTION_CRITERIA_ID      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_select_criteria_id_Exists (c_select_criteria_id NUMBER) IS
      SELECT 'X'
      FROM  pv_enty_select_criteria
      WHERE selection_criteria_id = c_select_criteria_id;

  l_val   VARCHAR2(1);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_selection_criteria_id is NULL)
      THEN
          IF (AS_DEBUG_HIGH_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'Private API: -Violate NOT NULL constraint(selection_criteria_id)');
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      OPEN  C_select_criteria_id_Exists (p_selection_criteria_id);
      FETCH C_select_criteria_id_Exists into l_val;

      IF C_select_criteria_id_Exists%NOTFOUND
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'selection_criteria_id',
              p_token2        => 'VALUE',
              p_token2_value  => p_selection_criteria_id );

          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE C_select_criteria_id_Exists;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SELECTION_CRITERIA_ID;


PROCEDURE Validate_selattval(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SELATTVAL_Rec              IN   PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   --ryellapu duplicated check for criterian
   cursor lc_criterion_dup_values_check (pc_rule_id number,pc_attribute_id number,pc_attribute_value varchar2,pc_selection_type_code varchar2) is
   select attribute_value
   from
      pv_selected_attr_values sav, pv_enty_select_criteria esc
   where
      sav.selection_criteria_id = esc.selection_criteria_id and
      esc.process_rule_id = pc_rule_id and
      esc.attribute_id = pc_attribute_id and
      esc.selection_type_code = pc_selection_type_code and
      sav.attribute_value = pc_attribute_value;

l_api_name   CONSTANT VARCHAR2(30) := 'Validate_selattval';
l_rule_id number;
l_attribute_id number;
l_attribute_value varchar2(2000);
l_selection_type_code varchar2(30);
 BEGIN

      -- Debug Message
      IF (AS_DEBUG_HIGH_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN

          Validate_ATTR_VALUE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ATTR_VALUE_ID          => P_SELATTVAL_Rec.ATTR_VALUE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          pv_common_checks_pvt.Validate_OBJECT_VERSION_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_OBJECT_VERSION_NUMBER  => P_SELATTVAL_Rec.OBJECT_VERSION_NUMBER,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SELECTION_CRITERIA_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SELECTION_CRITERIA_ID  => P_SELATTVAL_Rec.SELECTION_CRITERIA_ID,
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
-- 	if p_validation_mode = AS_UTILITY_PVT.G_CREATE then
           select process_rule_id,attribute_id,selection_type_code into l_rule_id,l_attribute_id,l_selection_type_code from pv_enty_select_criteria
	   where selection_criteria_id = P_SELATTVAL_Rec.selection_criteria_id;

          open lc_criterion_dup_values_check (pc_rule_id      => l_rule_id,
                                              pc_attribute_id => l_attribute_id,
					      pc_attribute_value => P_SELATTVAL_Rec.attribute_value,
					      pc_selection_type_code => l_selection_type_code);

            fetch lc_criterion_dup_values_check into l_attribute_value;
            close lc_criterion_dup_values_check;

	    if l_attribute_value is not null then
	        FND_MESSAGE.Set_Name('PV', 'PV_DUPLICATE_CRITERIA');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
                raise FND_API.G_EXC_ERROR;
            end if;
--        end if;
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

END Validate_selattval;

End PV_SELATTVAL_PVT;

/
